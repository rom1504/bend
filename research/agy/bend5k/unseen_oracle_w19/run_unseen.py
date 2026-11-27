#!/usr/bin/env python3
"""Runner & 5-run median benchmark harness for the 6 unseen W19 Silicon Oracle programs.

Compares Proven-18 `bend5k_o2 -O2` against BOTH `gcc-10 -O2 -ffp-contract=off`
and `gcc-10 -O3 -march=native -ffp-contract=off` on CPU 0, verifying exact
checksums and upstream `locked_bun.sh --check-only` compliance.
"""
from __future__ import annotations

import argparse
import json
import statistics
import subprocess
import sys
import tempfile
import time
from pathlib import Path

HERE = Path(__file__).resolve().parent
REPO_ROOT = HERE.parents[3]
BEND5K_DEFAULT = Path("/home/ai/bend2_agy/selfhost/build/agy/bend5k/bend5k_o2")
RUNTIME_DEFAULT = Path("/home/ai/bend2_agy/selfhost/build/agy/unified/runtime-agy.o")
LOCKED_BUN = REPO_ROOT / "research/agy/locked_bun.sh"

BENCHMARKS = [
    "u1_stencil2d",
    "u2_radix_hist",
    "u3_bytecode_vm",
    "u4_mergesort_list",
    "u5_matvec_f32",
    "u6_crc32_lut",
]


def run_cmd(cmd: list[str], cwd: Path | None = None) -> str:
    p = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True)
    if p.returncode != 0:
        raise RuntimeError(
            f"Command failed ({p.returncode}): {' '.join(cmd)}\n"
            f"STDOUT:\n{p.stdout}\nSTDERR:\n{p.stderr}"
        )
    return p.stdout.strip()


def time_runs(cmd: list[str], cpu_pin: str, runs: int) -> tuple[str, list[float], float]:
    full = (["taskset", "-c", cpu_pin] if cpu_pin else []) + cmd
    # 1 warmup run
    out0 = run_cmd(full)
    times: list[float] = []
    for _ in range(runs):
        t0 = time.perf_counter()
        out = run_cmd(full)
        t1 = time.perf_counter()
        if out != out0:
            raise RuntimeError(f"Nondeterministic output: {out0!r} vs {out!r}")
        times.append(round((t1 - t0) * 1000.0, 2))
    return out0, times, round(statistics.median(times), 2)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--bend5k", type=Path, default=BEND5K_DEFAULT)
    ap.add_argument("--runtime", type=Path, default=RUNTIME_DEFAULT)
    ap.add_argument("--cpu-pin", default="0")
    ap.add_argument("--runs", type=int, default=5)
    ap.add_argument("--skip-bun-check", action="store_true")
    ap.add_argument("--only", nargs="*", default=None)
    ap.add_argument("--json-out", type=Path, default=None)
    args = ap.parse_args()

    selected = args.only if args.only else BENCHMARKS
    results = []

    with tempfile.TemporaryDirectory(prefix="l19_or_run_") as td:
        tdir = Path(td)
        for name in selected:
            bend_src = HERE / f"{name}.bend"
            c_src = HERE / f"{name}.c"
            if not args.skip_bun_check:
                run_cmd([str(LOCKED_BUN), "--check-only", str(bend_src)], cwd=REPO_ROOT)

            obj = tdir / f"{name}.o"
            bend_bin = tdir / f"{name}_bend"
            co2_bin = tdir / f"{name}_co2"
            co3_bin = tdir / f"{name}_co3"

            run_cmd([str(args.bend5k), "-O2", str(bend_src), str(obj)], cwd=REPO_ROOT)
            run_cmd(
                ["gcc-10", "-O2", str(obj), str(args.runtime), "-lm", "-lpthread", "-o", str(bend_bin)]
            )
            run_cmd(
                ["gcc-10", "-O2", "-ffp-contract=off", str(c_src), "-lm", "-o", str(co2_bin)]
            )
            run_cmd(
                [
                    "gcc-10",
                    "-O3",
                    "-march=native",
                    "-ffp-contract=off",
                    str(c_src),
                    "-lm",
                    "-o",
                    str(co3_bin),
                ]
            )

            ob, tb_raw, tb_med = time_runs(
                [str(bend_bin), "+RTS", "--threads", "1", "--gpu", "off", "-RTS"],
                args.cpu_pin,
                args.runs,
            )
            oc2, tc2_raw, tc2_med = time_runs([str(co2_bin)], args.cpu_pin, args.runs)
            oc3, tc3_raw, tc3_med = time_runs([str(co3_bin)], args.cpu_pin, args.runs)

            if not (ob == oc2 == oc3):
                raise RuntimeError(
                    f"Checksum mismatch on {name}: bend={ob}, c_o2={oc2}, c_o3={oc3}"
                )

            r_o2 = round(tb_med / tc2_med, 3) if tc2_med > 0 else 0.0
            r_o3 = round(tb_med / tc3_med, 3) if tc3_med > 0 else 0.0
            rec = {
                "name": name,
                "checksum": ob,
                "bend_ms": tb_med,
                "c_o2_ms": tc2_med,
                "c_o3_native_ms": tc3_med,
                "vs_c_o2": r_o2,
                "vs_c_o3_native": r_o3,
                "raw_bend_ms": tb_raw,
                "raw_c_o2_ms": tc2_raw,
                "raw_c_o3_native_ms": tc3_raw,
            }
            results.append(rec)
            print(
                f"{name:20s} | chk={ob:10s} | bend={tb_med:7.2f}ms | "
                f"c_o2={tc2_med:6.2f}ms ({r_o2:5.2f}x) | "
                f"c_o3={tc3_med:6.2f}ms ({r_o3:5.2f}x)"
            )

    if args.json_out:
        args.json_out.write_text(json.dumps(results, indent=2) + "\n", encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
