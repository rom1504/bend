#!/usr/bin/env python3
"""Compose Wave 4B general backend passes cleanly on top of Wave 4A unified/compiler.bend:
  1. W4-5: apply_gol_opt.py (bottom-up const-arg inlining, bitop const-fold, GPR spill killer) [optional]
  2. W4-6: apply_arrprod.py ($direct->$product boxed-entry adapter, 2-pass p113i, x86 shll/testq peepholes)
  3. W4-7: apply_loopxmm.py (dynamic call-free XMM loop partition, CFG copy peephole, magic LICM, bottom-tested loops)

Usage:
  python3 -B research/agy/compose_wave4b.py <out_compiler.bend> [--no-gol]
"""
import argparse
import subprocess
import tempfile
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
WAVE4A_COMPILER = ROOT / "selfhost/build/agy/wave4a_unified/compiler.bend"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("out", type=Path)
    ap.add_argument("--src", type=Path, default=WAVE4A_COMPILER)
    ap.add_argument("--no-gol", action="store_true")
    args = ap.parse_args()

    steps = []
    if not args.no_gol and (ROOT / "research/agy/wave4b_gol/apply_gol_opt.py").exists():
        steps.append((
            "W4-5 (Bottom-Up Const-Arg Inlining, Bitop Const-Fold & GPR Spill Killer)",
            lambda i, o: ["python3", "-B", str(ROOT / "research/agy/wave4b_gol/apply_gol_opt.py"), "--src", str(i), "--dst", str(o)],
        ))
    steps.extend([
        ("W4-6 ($direct->$product Entry Adapter + 2-Pass p113i + x86 Peepholes)",
         lambda i, o: ["python3", "-B", str(ROOT / "research/agy/wave4b_arrprod/apply_arrprod.py"), "--src", str(i), "--dst", str(o)]),
        ("W4-7 (Call-Free XMM Partition + CFG Copy Peep + Magic LICM + Bottom-Tested Loops)",
         lambda i, o: ["python3", "-B", str(ROOT / "research/agy/wave4b_loopxmm/apply_loopxmm.py"), "--src", str(i), "--dst", str(o)]),
    ])

    args.out.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory() as td:
        cur = args.src
        for idx, (label, mk_cmd) in enumerate(steps):
            nxt = args.out if idx == len(steps) - 1 else Path(td) / f"step_{idx:02d}.bend"
            cmd = mk_cmd(cur, nxt)
            print(f"[{idx+1}/{len(steps)}] {label} ...", flush=True)
            subprocess.run(cmd, check=True)
            cur = nxt
    print(f"\nComposed Wave 4B unified compiler: {args.out} ({args.out.stat().st_size} bytes)", flush=True)


if __name__ == "__main__":
    main()
