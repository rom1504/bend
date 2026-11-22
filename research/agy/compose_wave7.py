#!/usr/bin/env python3
"""Compose Wave 7 Unified Compiler from Wave 6 Unified + Wave 7 General Tracks.

Pipeline:
  1. selfhost/build/agy/wave6_unified/compiler.bend
  2. + research/agy/w7_fe_hash/apply_w7_fe_hash.py       (Frontend O(1) ctor hash-trie + 1-step dispatch + 993 Bool helpers)
  3. + research/agy/w7_lower_fast/apply_w7_lower_fast.py (Lowering single-pass p113i + W6-P1/p113k cap + hash-trie p118c)
  4. + research/agy/w7_elf_fast/apply_w7_elf_fast.py     (Backend -O2 fast-path + x86-object-fast -O0 tier)
  5. -> selfhost/build/agy/wave7_unified/compiler.bend
  6. -> selfhost/build/agy/wave7_unified/api.mjs (via locked_bun.sh)
"""
from __future__ import annotations

import argparse
import subprocess
import tempfile
import time
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
W6_SRC = ROOT / "selfhost/build/agy/wave6_unified/compiler.bend"
DEFAULT_OUT = ROOT / "selfhost/build/agy/wave7_unified"


def run_step(cmd: list[str], label: str) -> None:
    t0 = time.perf_counter()
    print(f"[compose_wave7] {label}: {' '.join(cmd)}", flush=True)
    res = subprocess.run(cmd, cwd=ROOT)
    if res.returncode != 0:
        raise SystemExit(f"[compose_wave7] FAILED ({res.returncode}) at {label}")
    print(f"[compose_wave7] {label} OK ({time.perf_counter() - t0:.2f}s)", flush=True)


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--src", type=Path, default=W6_SRC)
    ap.add_argument("--out-dir", type=Path, default=DEFAULT_OUT)
    ap.add_argument("--skip-build", action="store_true")
    args = ap.parse_args()

    out_dir = args.out_dir.resolve()
    out_dir.mkdir(parents=True, exist_ok=True)
    dst_bend = out_dir / "compiler.bend"
    dst_api = out_dir / "api.mjs"

    with tempfile.TemporaryDirectory(prefix="agy_compose_w7_") as tmp:
        tdir = Path(tmp)
        s1 = tdir / "step1_fe_hash.bend"
        s2 = tdir / "step2_lower_fast.bend"

        run_step(
            [
                "python3", "-B",
                str(ROOT / "research/agy/w7_fe_hash/apply_w7_fe_hash.py"),
                "--src", str(args.src),
                "--dst", str(s1),
            ],
            "Track 1 (w7_fe_hash)",
        )
        run_step(
            [
                "python3", "-B",
                str(ROOT / "research/agy/w7_lower_fast/apply_w7_lower_fast.py"),
                "--src", str(s1),
                "--dst", str(s2),
            ],
            "Track 2 (w7_lower_fast)",
        )
        run_step(
            [
                "python3", "-B",
                str(ROOT / "research/agy/w7_elf_fast/apply_w7_elf_fast.py"),
                "--src", str(s2),
                "--dst", str(dst_bend),
            ],
            "Track 3 (w7_elf_fast)",
        )

    print(f"[compose_wave7] Composed {dst_bend} ({dst_bend.stat().st_size:,} bytes)", flush=True)

    if not args.skip_build:
        run_step(
            [
                "bash", str(ROOT / "research/agy/locked_bun.sh"),
                str(dst_bend), "-o", str(dst_api),
            ],
            "Build wave7_unified/api.mjs (locked_bun.sh)",
        )
        print(f"[compose_wave7] Built {dst_api} ({dst_api.stat().st_size:,} bytes)", flush=True)


if __name__ == "__main__":
    main()
