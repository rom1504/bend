#!/usr/bin/env python3
"""Compose Wave 7C Unified Compiler from Wave 7 Unified + Wave 7B/7C Surgical O(N^2) Killers.

Pipeline:
  1. selfhost/build/agy/wave7_unified/compiler.bend
  2. + research/agy/w7b_annotate/apply_w7b_annotate.py       (O(1) w7b_wnf, zero-alloc subst, jl_checked_error, gameoflife leaf fix)
  3. + research/agy/w7c_nr_prepare/apply_w7c_nr_prepare.py   (O(1) hash-trie p144o ownership + zero-alloc norm_max_book)
  4. + research/agy/w7c_check_parse/apply_w7c_check_parse.py (O(1) BookCache check_program + fast subst + fast parse)
  5. + research/agy/w7c_pw_full/apply_w7c_pw_full.py         (x198pw_plan full-compiler O(N^2) killer)
  6. + research/agy/w7c_elf_public/apply_w7c_elf_public.py   (P134Public + ELF O(N^2) killer)
  7. + research/agy/w7c_p130_scale/apply_w7c_p130_scale.py   (.p130 carrier bounds 65k->1M nodes, 4k->64k strings)
  8. -> selfhost/build/agy/wave7c_unified/{compiler.bend,api.mjs}
"""
from __future__ import annotations

import argparse
import subprocess
import tempfile
import time
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
W7_SRC = ROOT / "selfhost/build/agy/wave7_unified/compiler.bend"
DEFAULT_OUT = ROOT / "selfhost/build/agy/wave7c_unified"

STEPS = [
    ("w7b_annotate",   ROOT / "research/agy/w7b_annotate/apply_w7b_annotate.py"),
    ("w7c_nr_prepare", ROOT / "research/agy/w7c_nr_prepare/apply_w7c_nr_prepare.py"),
    ("w7c_check_parse",ROOT / "research/agy/w7c_check_parse/apply_w7c_check_parse.py"),
    ("w7c_pw_full",    ROOT / "research/agy/w7c_pw_full/apply_w7c_pw_full.py"),
    ("w7c_elf_public", ROOT / "research/agy/w7c_elf_public/apply_w7c_elf_public.py"),
    ("w7c_p130_scale", ROOT / "research/agy/w7c_p130_scale/apply_w7c_p130_scale.py"),
]


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--src", type=Path, default=W7_SRC)
    ap.add_argument("--out-dir", type=Path, default=DEFAULT_OUT)
    ap.add_argument("--skip", nargs="*", default=[])
    ap.add_argument("--skip-build", action="store_true")
    args = ap.parse_args()

    out_dir = args.out_dir.resolve()
    out_dir.mkdir(parents=True, exist_ok=True)
    dst_bend = out_dir / "compiler.bend"
    dst_api = out_dir / "api.mjs"

    with tempfile.TemporaryDirectory(prefix="agy_compose_w7c_") as tmp:
        tdir = Path(tmp)
        cur = args.src
        for i, (name, script) in enumerate(STEPS):
            if name in args.skip:
                print(f"[compose_wave7c] SKIP {name}", flush=True)
                continue
            nxt = dst_bend if i == len(STEPS) - 1 else (tdir / f"s{i}_{name}.bend")
            t0 = time.perf_counter()
            res = subprocess.run(["python3", "-B", str(script), "--src", str(cur), "--dst", str(nxt)], cwd=ROOT)
            if res.returncode != 0:
                raise SystemExit(f"[compose_wave7c] FAILED at {name} (rc={res.returncode})")
            print(f"[compose_wave7c] {name} OK ({time.perf_counter()-t0:.2f}s, {nxt.stat().st_size:,} B)", flush=True)
            cur = nxt
        if cur != dst_bend:
            dst_bend.write_bytes(cur.read_bytes())

    if not args.skip_build:
        t0 = time.perf_counter()
        res = subprocess.run(["bash", str(ROOT / "research/agy/locked_bun.sh"), str(dst_bend), "-o", str(dst_api)], cwd=ROOT)
        if res.returncode != 0:
            raise SystemExit(f"[compose_wave7c] Build FAILED (rc={res.returncode})")
        print(f"[compose_wave7c] Built {dst_api} ({dst_api.stat().st_size:,} B) in {time.perf_counter()-t0:.2f}s", flush=True)


if __name__ == "__main__":
    main()
