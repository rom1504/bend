#!/usr/bin/env python3
"""Compose Wave 3B passes cleanly on top of Wave 2 unified/compiler.bend:
  1. Wave 3A Track S1: apply_sc_algo.py (String.eq -> agy_str_eq, O(1) kr_parent/dr_walk/stops, x185 guards)
  2. Wave 3B Track B1: apply_rtdrain.py (inline x86-64 special_ctor, borrow_guard, sink/keep, rfc_take1..4, borrow_scalar_safe)
  3. Wave 3B Track B2: apply_strhash.py (native x86-64 p88_string_eq/agy_str_eq, index_hash, p98_tag_eq) [optional]
  4. Wave 3B Track B3: apply_parcg.py (parallel sharded x181-x188 ELF emit; N=1 bit-exact default) [optional]

Usage:
  python3 -B research/agy/compose_wave3b.py <out_compiler.bend> [--no-strhash] [--no-parcg]
"""
import argparse
import subprocess
import tempfile
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
WAVE2_COMPILER = ROOT / "selfhost/build/agy/wave2_unified/compiler.bend"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("out", type=Path)
    ap.add_argument("--src", type=Path, default=WAVE2_COMPILER)
    ap.add_argument("--no-strhash", action="store_true")
    ap.add_argument("--no-parcg", action="store_true")
    args = ap.parse_args()

    steps = [
        ("Wave3B-B1 (Runtime Drainer: inline special_ctor/borrow/sink/keep/rfc_take)",
         lambda i, o: ["python3", "-B", str(ROOT / "research/agy/wave3b_rtdrain/apply_rtdrain.py"), "--src", str(i), "--dst", str(o)]),
    ]
    if not args.no_strhash:
        steps.append((
            "Wave3B-B2 (Native x86-64 String Eq / FNV-1a Hash / Tag Eq)",
            lambda i, o: ["python3", "-B", str(ROOT / "research/agy/wave3b_strhash/apply_strhash.py"), "--src", str(i), "--dst", str(o)],
        ))
    if not args.no_parcg:
        steps.append((
            "Wave3B-B3 (Parallel Sharded x181-x188 ELF Codegen)",
            lambda i, o: ["python3", "-B", str(ROOT / "research/agy/wave3b_parcg/apply_parcg.py"), str(i), str(o)],
        ))
    steps.append((
        "Wave3A-S1 (Algo Opts: String.eq->agy_str_eq, O(1) kr_parent/dr_walk, x185 guards)",
        lambda i, o: ["python3", "-B", str(ROOT / "research/agy/wave3_sc_algo/apply_sc_algo.py"), str(i), str(o)],
    ))

    args.out.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory() as td:
        cur = args.src
        for idx, (label, mk_cmd) in enumerate(steps):
            nxt = args.out if idx == len(steps) - 1 else Path(td) / f"step_{idx:02d}.bend"
            cmd = mk_cmd(cur, nxt)
            print(f"[{idx+1}/{len(steps)}] {label} ...", flush=True)
            subprocess.run(cmd, check=True)
            cur = nxt
    print(f"\nComposed Wave 3B unified compiler: {args.out} ({args.out.stat().st_size} bytes)", flush=True)


if __name__ == "__main__":
    main()
