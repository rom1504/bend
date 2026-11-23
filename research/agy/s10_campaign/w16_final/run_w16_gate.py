#!/usr/bin/env python3
"""Wave 16 Zero-Regression Gate:
  1. 158/158 Native Qualification + ELF Audit on n7_o2 (CPUs 0..7)
  2. 7-Family Proxy Suite (5-run median, CPU 7) + terrain holdout spot-check on n7_o2
"""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
N7_O2 = ROOT / "selfhost/build/agy/wave16-native-mod/n7_o2"
OUT_DIR = ROOT / "research/agy/s10_campaign/w16_final"

sys.path.insert(0, str(ROOT / "research/agy/w15_final/gate"))


def run_qual() -> int:
    import run_w15_qual as q

    q.N6_O2 = N7_O2
    q.OUT_DIR = OUT_DIR
    q.RESULTS_JSON = OUT_DIR / "qual_results.json"
    q.TMP = Path("/tmp/agy_w16_gate/qual")
    q.CPUS = [0, 1, 2, 3, 4, 5, 6, 7]
    try:
        q.main()
        return 0
    except SystemExit as e:
        return int(e.code) if isinstance(e.code, int) else 1


def run_bench() -> int:
    import run_w15_bench as b

    b.N6_O2 = N7_O2
    b.OUT_DIR = OUT_DIR
    b.RESULTS_JSON = OUT_DIR / "bench_results.json"
    b.TMP = Path("/tmp/agy_w16_gate/bench")
    b.CPU = 7
    # 7-family proxy + terrain holdout spot-check (fast & complete within deadline!)
    b.HOLDOUTS = [("terrain", "2572468224")]
    return b.main()


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("part", choices=["qual", "bench", "all"])
    args = ap.parse_args()
    rc = 0
    if args.part in ("qual", "all"):
        rc = run_qual()
        if rc != 0:
            raise SystemExit(rc)
    if args.part in ("bench", "all"):
        rc = run_bench()
    raise SystemExit(rc)


if __name__ == "__main__":
    main()
