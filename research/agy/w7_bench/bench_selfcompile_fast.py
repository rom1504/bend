#!/usr/bin/env python3
"""Shared Tier-0 fast self-compile benchmark harness (<15s per run, hard 120s timeout).

Usage:
  python3 -B research/agy/w7_bench/bench_selfcompile_fast.py --api <path/to/api.mjs> [--cpu 0]
  python3 -B research/agy/w7_bench/bench_selfcompile_fast.py --native <path/to/n1> [--cpu 0]
"""
from __future__ import annotations

import argparse
import json
import resource
import subprocess
import tempfile
import time
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
SLICE = ROOT / "research/agy/w7_bench/compiler_slice.bend"
RT = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
BASE = ROOT / "selfhost/dist/base.bend"
CARRIER = ROOT / "selfhost/build/agy/bootstrap/base.p130"
STAMP = "p130-word-pair-v1:p88-private-base-text-1:2dd93239749b4f1e3ee2f4e9617e31aeb5df4cc0200a4c14054a6591e2f74212"
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"
EXPECTED_SLICE_OUT = "34"


def verify_obj(obj_path: Path, exe_path: Path) -> str:
    subprocess.run([CC, "-no-pie", str(obj_path), str(RT), "-o", str(exe_path), "-lm", "-lpthread"], check=True)
    got = subprocess.run([str(exe_path)], capture_output=True, text=True, check=True, timeout=15).stdout.strip()
    if got != EXPECTED_SLICE_OUT:
        raise RuntimeError(f"compiler_slice.bend wrong output: got {got!r}, expected {EXPECTED_SLICE_OUT!r}")
    return got


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--api", type=Path, default=None)
    ap.add_argument("--native", type=Path, default=None)
    ap.add_argument("--cpu", type=str, default="0")
    ap.add_argument("--timeout", type=int, default=120)
    args = ap.parse_args()

    with tempfile.TemporaryDirectory(prefix="agy_w7_t0_") as td:
        tdir = Path(td)
        obj_p = tdir / "slice.o"
        exe_p = tdir / "slice"

        if args.native:
            t0 = time.perf_counter()
            err_p = tdir / "err.txt"
            with open(obj_p, "wb") as fo, open(err_p, "wb") as fe:
                r = subprocess.run(
                    ["timeout", str(args.timeout), "taskset", "-c", args.cpu, str(args.native),
                     "x86-object", str(SLICE), str(BASE), "cache", str(CARRIER), STAMP],
                    stdout=fo, stderr=fe,
                )
            wall_ms = round((time.perf_counter() - t0) * 1000, 1)
            rss_mib = round(resource.getrusage(resource.RUSAGE_CHILDREN).ru_maxrss / 1024, 1)
            if r.returncode != 0:
                raise SystemExit(f"native failed (rc={r.returncode}): {err_p.read_text()[:400]}")
            got = verify_obj(obj_p, exe_p)
            res = {
                "mode": "native",
                "compiler": str(args.native),
                "ok": True,
                "out": got,
                "objBytes": obj_p.stat().st_size,
                "totalMs": wall_ms,
                "peakRssMib": rss_mib,
            }
            print(json.dumps(res, indent=2))
            return

        api = args.api or (ROOT / "selfhost/build/agy/wave6_unified/api.mjs")
        cmd = [
            "timeout", str(args.timeout), "taskset", "-c", args.cpu,
            "bash", str(ROOT / "research/agy/locked_node.sh"),
            str(ROOT / "research/agy/w7_bench/stage_bench.mjs"),
            "--api", str(api), "--src", str(SLICE), "--out-obj", str(obj_p),
        ]
        r = subprocess.run(cmd, capture_output=True, text=True)
        if r.returncode != 0:
            raise SystemExit(f"stage_bench failed (rc={r.returncode}):\n{r.stderr}\n{r.stdout}")
        res = json.loads(r.stdout.strip().splitlines()[-1])
        got = verify_obj(obj_p, exe_p)
        res["out"] = got
        print(json.dumps(res, indent=2))


if __name__ == "__main__":
    main()
