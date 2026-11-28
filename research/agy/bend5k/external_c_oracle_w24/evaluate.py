#!/usr/bin/env python3
"""Sealed External C Corpus Distribution Estimator (Wave 24: N = 20 Stratified Programs).

Compares Proven-23 `bend5k_o2 -O2` (safe Bend, 0 @unsafe, upstream `locked_bun.sh --check-only`)
against unmodified real-world external C benchmark programs across 5 balanced strata (4 each):
  - Stratum 1: Bit / Integer / Crypto (Embench-IoT crc32, nettle-sha256, nettle-aes; Cyan4973 xxHash XXH32)
  - Stratum 2: Numeric / F32 / Stencil / Linear Algebra (PolyBench/C 4.2.1 gemm, jacobi-2d, seidel-2d, bicg)
  - Stratum 3: Array / Graph / String / Sort / DP (PolyBench/C floyd-warshall, nussinov; Embench matmult-int; CLBG nsieve)
  - Stratum 4: Trees / Allocator / Symbolic / Regex (CLBG binary-trees; Embench slre, sglib-rbtree, sglib-listsort)
  - Stratum 5: Real Mini-Apps / Parsers / Codecs (zserge/jsmn; Embench huffbench, tarfind, edn)

C baselines: `gcc-10 -O2`, `gcc-10 -O3 -march=native`, and `clang -O3 -march=native` (if installed).
Measurements: CPU-pinned (default CPU 3), 1 warmup + 5 timed runs (median wall time in ms) +
per-child peak RSS (`ru_maxrss` in KiB via `os.wait4`).
"""
from __future__ import annotations

import argparse
import datetime
import hashlib
import json
import math
import os
import random
import shutil
import statistics
import subprocess
import sys
import tempfile
import time
from pathlib import Path
from typing import Any

HERE = Path(__file__).resolve().parent
REPO_ROOT = HERE.parents[3]
BEND5K_DEFAULT = Path("/home/ai/bend2_agy/selfhost/build/agy/bend5k/bend5k_o2")
RUNTIME_DEFAULT = Path("/home/ai/bend2_agy/selfhost/build/agy/unified/runtime-agy.o")
LOCKED_BUN = REPO_ROOT / "research/agy/locked_bun.sh"
VENDOR = HERE / "vendor"
HARNESSES = VENDOR / "harnesses"
BEND_DIR = HERE / "bend"

STRATA_NAMES = {
    "S1": "Bit / Integer / Crypto",
    "S2": "Numeric / F32 / Stencil / Linear Algebra",
    "S3": "Array / Graph / String / Sort / DP",
    "S4": "Trees / Allocator / Symbolic / Regex",
    "S5": "Real Mini-Apps / Parsers / Codecs",
}

BENCHMARKS: list[dict[str, Any]] = [
    # Stratum 1 — Bit / Integer / Crypto
    {
        "id": "s1_embench_crc32",
        "stratum": "S1",
        "upstream_repo": "embench/embench-iot",
        "upstream_file": "vendor/embench-iot/src/crc32/crc_32.c",
        "license": "GPL-3.0-or-later",
        "description": "Table-driven IEEE 802.3 CRC-32 (3000 rounds x 1024 bytes)",
    },
    {
        "id": "s1_embench_sha256",
        "stratum": "S1",
        "upstream_repo": "embench/embench-iot",
        "upstream_file": "vendor/embench-iot/src/nettle-sha256/nettle-sha256.c",
        "license": "GPL-3.0-or-later",
        "description": "Nettle SHA-256 iterated 24,000 times on 32-byte state",
    },
    {
        "id": "s1_embench_aes",
        "stratum": "S1",
        "upstream_repo": "embench/embench-iot",
        "upstream_file": "vendor/embench-iot/src/nettle-aes/nettle-aes.c",
        "license": "GPL-3.0-or-later",
        "description": "Nettle AES-256 ECB (3000 rounds x 256 bytes)",
    },
    {
        "id": "s1_xxhash32",
        "stratum": "S1",
        "upstream_repo": "Cyan4973/xxHash",
        "upstream_file": "vendor/xxHash/xxhash.h",
        "license": "BSD-2-Clause",
        "description": "XXH32 non-cryptographic hash (24,000 rounds x 4096 bytes)",
    },
    # Stratum 2 — Numeric / F32 / Stencil / Linear Algebra
    {
        "id": "s2_polybench_gemm",
        "stratum": "S2",
        "upstream_repo": "MatthiasJReisinger/PolyBenchC-4.2.1",
        "upstream_file": "vendor/PolyBenchC-4.2.1/linear-algebra/blas/gemm/gemm.c",
        "license": "BSD-style (OSU)",
        "description": "PolyBench/C gemm (MEDIUM_DATASET NI=200,NJ=220,NK=240, float/F32)",
    },
    {
        "id": "s2_polybench_jacobi2d",
        "stratum": "S2",
        "upstream_repo": "MatthiasJReisinger/PolyBenchC-4.2.1",
        "upstream_file": "vendor/PolyBenchC-4.2.1/stencils/jacobi-2d/jacobi-2d.c",
        "license": "BSD-style (OSU)",
        "description": "PolyBench/C jacobi-2d (MEDIUM_DATASET TSTEPS=100,N=250, float/F32)",
    },
    {
        "id": "s2_polybench_seidel2d",
        "stratum": "S2",
        "upstream_repo": "MatthiasJReisinger/PolyBenchC-4.2.1",
        "upstream_file": "vendor/PolyBenchC-4.2.1/stencils/seidel-2d/seidel-2d.c",
        "license": "BSD-style (OSU)",
        "description": "PolyBench/C seidel-2d (SMALL_DATASET TSTEPS=40,N=120, float/F32)",
    },
    {
        "id": "s2_polybench_bicg",
        "stratum": "S2",
        "upstream_repo": "MatthiasJReisinger/PolyBenchC-4.2.1",
        "upstream_file": "vendor/PolyBenchC-4.2.1/linear-algebra/kernels/bicg/bicg.c",
        "license": "BSD-style (OSU)",
        "description": "PolyBench/C bicg (MEDIUM_DATASET M=390,N=410 x 40 rounds, float/F32)",
    },
    # Stratum 3 — Array / Graph / String / Sort / DP
    {
        "id": "s3_polybench_floyd_warshall",
        "stratum": "S3",
        "upstream_repo": "MatthiasJReisinger/PolyBenchC-4.2.1",
        "upstream_file": "vendor/PolyBenchC-4.2.1/medley/floyd-warshall/floyd-warshall.c",
        "license": "BSD-style (OSU)",
        "description": "PolyBench/C floyd-warshall (SMALL_DATASET N=180 integer APSP)",
    },
    {
        "id": "s3_polybench_nussinov",
        "stratum": "S3",
        "upstream_repo": "MatthiasJReisinger/PolyBenchC-4.2.1",
        "upstream_file": "vendor/PolyBenchC-4.2.1/medley/nussinov/nussinov.c",
        "license": "BSD-style (OSU)",
        "description": "PolyBench/C nussinov (MEDIUM_DATASET N=500 RNA folding 2D DP)",
    },
    {
        "id": "s3_embench_matmult_int",
        "stratum": "S3",
        "upstream_repo": "embench/embench-iot",
        "upstream_file": "vendor/embench-iot/src/matmult-int/matmult-int.c",
        "license": "GPL-3.0-or-later",
        "description": "Embench-IoT matmult-int (20x20 integer matmul x 2000 rounds)",
    },
    {
        "id": "s3_clbg_nsieve",
        "stratum": "S3",
        "upstream_repo": "hanabi1224/Programming-Language-Benchmarks",
        "upstream_file": "vendor/clbg/bench/algorithm/nsieve/1.c",
        "license": "MIT",
        "description": "CLBG nsieve (m=7: primes up to 1.28M, 640K, 320K)",
    },
    # Stratum 4 — Trees / Allocator / Symbolic / Regex
    {
        "id": "s4_clbg_binary_trees",
        "stratum": "S4",
        "upstream_repo": "hanabi1224/Programming-Language-Benchmarks",
        "upstream_file": "vendor/clbg/bench/algorithm/binarytrees/2.c",
        "license": "MIT",
        "description": "CLBG binary-trees (min=4, max=14 recursive tree alloc/check)",
    },
    {
        "id": "s4_embench_slre",
        "stratum": "S4",
        "upstream_repo": "embench/embench-iot",
        "upstream_file": "vendor/embench-iot/src/slre/libslre.c",
        "license": "GPL-3.0-or-later",
        "description": "Embench-IoT slre regex matcher (4000 rotations x 4 patterns)",
    },
    {
        "id": "s4_embench_sglib_rbtree",
        "stratum": "S4",
        "upstream_repo": "embench/embench-iot",
        "upstream_file": "vendor/embench-iot/src/sglib-combined/sglib.h",
        "license": "GPL-3.0-or-later",
        "description": "Embench-IoT sglib Red-Black Tree (300 rounds x 512 inserts + inorder)",
    },
    {
        "id": "s4_embench_sglib_listsort",
        "stratum": "S4",
        "upstream_repo": "embench/embench-iot",
        "upstream_file": "vendor/embench-iot/src/sglib-combined/sglib.h",
        "license": "GPL-3.0-or-later",
        "description": "Embench-IoT sglib singly-linked list mergesort (400 rounds x 512 nodes)",
    },
    # Stratum 5 — Real Mini-Apps / Parsers / Codecs
    {
        "id": "s5_jsmn_json",
        "stratum": "S5",
        "upstream_repo": "zserge/jsmn",
        "upstream_file": "vendor/jsmn/jsmn.h",
        "license": "MIT",
        "description": "zserge/jsmn JSON tokenizer (4000 rounds x 448-byte nested JSON)",
    },
    {
        "id": "s5_embench_huffbench",
        "stratum": "S5",
        "upstream_repo": "embench/embench-iot",
        "upstream_file": "vendor/embench-iot/src/huffbench/libhuffbench.c",
        "license": "GPL-3.0-or-later",
        "description": "Embench-IoT huffbench Huffman compress + decompress (80 rounds x 500 bytes)",
    },
    {
        "id": "s5_embench_tarfind",
        "stratum": "S5",
        "upstream_repo": "embench/embench-iot",
        "upstream_file": "vendor/embench-iot/src/tarfind/tarfind.c",
        "license": "MIT",
        "description": "Embench-IoT tarfind POSIX TAR header archive scanner (800 rounds x 35 files)",
    },
    {
        "id": "s5_embench_edn",
        "stratum": "S5",
        "upstream_repo": "embench/embench-iot",
        "upstream_file": "vendor/embench-iot/src/edn/libedn.c",
        "license": "GPL-3.0-or-later",
        "description": "Embench-IoT edn DSP filterbank (1200 rounds: vec_mpy1, mac, fir, latsynth, iir1, dct)",
    },
]


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(65536), b""):
            h.update(chunk)
    return h.hexdigest()


def geomean(vals: list[float]) -> float:
    return math.exp(sum(math.log(v) for v in vals) / len(vals))


def percentile(vals: list[float], p: float) -> float:
    """Linear-interpolated percentile (p in [0, 100])."""
    s = sorted(vals)
    if len(s) == 1:
        return s[0]
    k = (len(s) - 1) * (p / 100.0)
    f = math.floor(k)
    c = math.ceil(k)
    if f == c:
        return s[int(k)]
    return s[f] + (s[c] - s[f]) * (k - f)


def bootstrap_geomean_ci(vals: list[float], n_resamples: int = 10000, seed: int = 20261128) -> tuple[float, float]:
    rng = random.Random(seed)
    n = len(vals)
    logs = [math.log(v) for v in vals]
    gms: list[float] = []
    for _ in range(n_resamples):
        s = sum(logs[rng.randrange(n)] for _ in range(n))
        gms.append(math.exp(s / n))
    gms.sort()
    lo = gms[int(0.025 * n_resamples)]
    hi = gms[int(0.975 * n_resamples)]
    return round(lo, 4), round(hi, 4)


RSS_RUNNER_C = r'''
#define _GNU_SOURCE
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/resource.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <time.h>
#include <unistd.h>

int main(int argc, char **argv) {
  if (argc < 2) return 2;
  struct timespec t0, t1;
  clock_gettime(CLOCK_MONOTONIC, &t0);
  pid_t pid = vfork();
  if (pid == 0) {
    execvp(argv[1], &argv[1]);
    _exit(127);
  }
  if (pid < 0) return 3;
  int status = 0;
  struct rusage ru;
  if (wait4(pid, &status, 0, &ru) < 0) return 4;
  clock_gettime(CLOCK_MONOTONIC, &t1);
  double ms = (t1.tv_sec - t0.tv_sec) * 1000.0 + (t1.tv_nsec - t0.tv_nsec) / 1e6;
  int rc = WIFEXITED(status) ? WEXITSTATUS(status) : 128;
  fprintf(stderr, "RSS_RUNNER_META %.3f %ld %d\n", ms, ru.ru_maxrss, rc);
  return rc;
}
'''


def run_pinned_measure(runner: Path, cmd: list[str], cpu_pin: str, runs: int, timeout_s: float = 30.0) -> dict[str, Any]:
    """Measure 1 warmup + `runs` timed runs pinned to `cpu_pin`, collecting exact child wall time & ru_maxrss via vfork+wait4."""
    full = ([str(runner), "taskset", "-c", cpu_pin] if cpu_pin else [str(runner)]) + cmd

    def exec_once() -> tuple[bool, str, float, int, str]:
        try:
            p = subprocess.run(full, capture_output=True, text=True, timeout=timeout_s)
        except subprocess.TimeoutExpired:
            return False, "", 0.0, 0, f"TIMEOUT after {timeout_s}s"
        ms = 0.0
        rss_kib = 0
        err_lines = []
        for line in p.stderr.splitlines():
            if line.startswith("RSS_RUNNER_META "):
                parts = line.split()
                ms = round(float(parts[1]), 2)
                rss_kib = int(parts[2])
            else:
                err_lines.append(line)
        return (p.returncode == 0), p.stdout.strip(), ms, rss_kib, "\n".join(err_lines).strip()

    ok0, out0, _, rss0, err0 = exec_once()
    if not ok0:
        return {"ok": False, "error": f"warmup_failed: {err0[:300]}", "checksum": None, "median_ms": None, "raw_ms": [], "peak_rss_kib": None}

    raw_ms: list[float] = []
    rss_vals: list[int] = [rss0]
    for _ in range(runs):
        ok, out, ms, rss, err = exec_once()
        if not ok:
            return {"ok": False, "error": f"run_failed: {err[:300]}", "checksum": out0, "median_ms": None, "raw_ms": raw_ms, "peak_rss_kib": None}
        if out != out0:
            return {"ok": False, "error": f"nondeterministic: {out0!r} vs {out!r}", "checksum": out0, "median_ms": None, "raw_ms": raw_ms, "peak_rss_kib": None}
        raw_ms.append(ms)
        rss_vals.append(rss)

    return {
        "ok": True,
        "error": "",
        "checksum": out0,
        "median_ms": round(statistics.median(raw_ms), 2),
        "raw_ms": raw_ms,
        "peak_rss_kib": int(statistics.median(rss_vals)),
        "raw_rss_kib": rss_vals[1:],
    }


def summarize_ratios(ratios: list[float]) -> dict[str, Any]:
    lo, hi = bootstrap_geomean_ci(ratios)
    return {
        "n": len(ratios),
        "geomean": round(geomean(ratios), 4),
        "bootstrap_95_ci": [lo, hi],
        "min": round(min(ratios), 4),
        "p10": round(percentile(ratios, 10), 4),
        "p25": round(percentile(ratios, 25), 4),
        "p50_median": round(percentile(ratios, 50), 4),
        "p75": round(percentile(ratios, 75), 4),
        "p90": round(percentile(ratios, 90), 4),
        "max": round(max(ratios), 4),
    }


def main() -> int:
    ap = argparse.ArgumentParser(description="Wave 24 External C Oracle Distribution Estimator")
    ap.add_argument("--compiler", type=Path, default=BEND5K_DEFAULT)
    ap.add_argument("--runtime", type=Path, default=RUNTIME_DEFAULT)
    ap.add_argument("--cpu", default="3")
    ap.add_argument("--runs", type=int, default=5)
    ap.add_argument("--skip-bun", action="store_true")
    ap.add_argument("--out", type=Path, default=HERE / "proven23_c_distribution.json")
    args = ap.parse_args()

    clang_bin = shutil.which("clang")
    c_includes = [
        f"-I{HARNESSES}",
        f"-I{VENDOR}/embench-iot/support",
        f"-I{VENDOR}/embench-iot/src/slre",
        f"-I{VENDOR}/PolyBenchC-4.2.1/utilities",
    ]

    results: list[dict[str, Any]] = []
    all_ok = True
    bun_passed = 0
    checksum_matched = 0

    with tempfile.TemporaryDirectory(prefix="agy_ext_oracle_") as td:
        tdir = Path(td)
        runner_c = tdir / "rss_runner.c"
        runner_bin = tdir / "rss_runner"
        runner_c.write_text(RSS_RUNNER_C)
        subprocess.run(["gcc-10", "-O2", str(runner_c), "-o", str(runner_bin)], check=True)
        for spec in BENCHMARKS:
            bid = spec["id"]
            bend_src = BEND_DIR / f"{bid}.bend"
            c_harness = HARNESSES / f"h_{bid}.c"
            bend_text = bend_src.read_text()
            has_unsafe = "@unsafe" in bend_text

            # 1. Upstream typecheck
            bun_ok = True
            bun_err = ""
            if has_unsafe:
                bun_ok = False
                bun_err = "FORBIDDEN: @unsafe found"
            elif not args.skip_bun:
                r = subprocess.run([str(LOCKED_BUN), "--check-only", str(bend_src)], cwd=REPO_ROOT, capture_output=True, text=True, timeout=95)
                out = (r.stdout + "\n" + r.stderr).strip()
                if r.returncode != 0 or "ALL PROOFS CHECK" not in out:
                    bun_ok = False
                    bun_err = out[:400]
            if bun_ok:
                bun_passed += 1

            # 2. Build C baselines
            co2_bin = tdir / f"{bid}_co2"
            co3_bin = tdir / f"{bid}_co3"
            r2 = subprocess.run(["gcc-10", "-O2", *c_includes, str(c_harness), "-lm", "-o", str(co2_bin)], capture_output=True, text=True)
            r3 = subprocess.run(["gcc-10", "-O3", "-march=native", *c_includes, str(c_harness), "-lm", "-o", str(co3_bin)], capture_output=True, text=True)
            if r2.returncode != 0 or r3.returncode != 0:
                raise RuntimeError(f"C build failed for {bid}: O2={r2.stderr[:200]} O3={r3.stderr[:200]}")

            co2_res = run_pinned_measure(runner_bin, [str(co2_bin)], args.cpu, args.runs)
            co3_res = run_pinned_measure(runner_bin, [str(co3_bin)], args.cpu, args.runs)
            if not co2_res["ok"] or not co3_res["ok"] or co2_res["checksum"] != co3_res["checksum"]:
                raise RuntimeError(f"C oracle failed on {bid}: O2={co2_res} O3={co3_res}")

            clang_res = None
            if clang_bin:
                cl_bin = tdir / f"{bid}_clang"
                rcl = subprocess.run([clang_bin, "-O3", "-march=native", *c_includes, str(c_harness), "-lm", "-o", str(cl_bin)], capture_output=True, text=True)
                if rcl.returncode == 0:
                    clang_res = run_pinned_measure(runner_bin, [str(cl_bin)], args.cpu, args.runs)

            # 3. Build & measure Proven-23 bend5k_o2 -O2
            b_obj = tdir / f"{bid}.o"
            b_bin = tdir / f"{bid}_bend"
            rbc = subprocess.run([str(args.compiler), "-O2", str(bend_src), "-o", str(b_obj)], cwd=REPO_ROOT, capture_output=True, text=True, timeout=60)
            if rbc.returncode != 0:
                bend_res = {"ok": False, "error": f"compile_failed: {(rbc.stderr or rbc.stdout)[:300]}", "checksum": None, "median_ms": None, "raw_ms": [], "peak_rss_kib": None}
            else:
                rbl = subprocess.run(["gcc-10", "-O2", str(b_obj), str(args.runtime), "-lm", "-lpthread", "-o", str(b_bin)], capture_output=True, text=True, timeout=30)
                if rbl.returncode != 0:
                    bend_res = {"ok": False, "error": f"link_failed: {rbl.stderr[:300]}", "checksum": None, "median_ms": None, "raw_ms": [], "peak_rss_kib": None}
                else:
                    bend_res = run_pinned_measure(runner_bin, [str(b_bin), "+RTS", "--threads", "1", "--gpu", "off", "-RTS"], args.cpu, args.runs)

            chk_match = bool(bend_res["ok"] and bend_res["checksum"] == co2_res["checksum"])
            if chk_match:
                checksum_matched += 1
            else:
                all_ok = False
            if not bun_ok:
                all_ok = False

            ratio_o2 = round(bend_res["median_ms"] / co2_res["median_ms"], 4) if (chk_match and co2_res["median_ms"] > 0) else None
            ratio_o3 = round(bend_res["median_ms"] / co3_res["median_ms"], 4) if (chk_match and co3_res["median_ms"] > 0) else None
            rss_ratio = round(bend_res["peak_rss_kib"] / co2_res["peak_rss_kib"], 4) if (chk_match and co2_res["peak_rss_kib"] > 0) else None

            entry = {
                **spec,
                "zero_unsafe": not has_unsafe,
                "bun_check_ok": bun_ok,
                "bun_check_err": bun_err,
                "checksum_match": chk_match,
                "oracle_checksum_u32": co2_res["checksum"],
                "bend_o2": bend_res,
                "c_gcc10_o2": co2_res,
                "c_gcc10_o3_native": co3_res,
                "c_clang_o3_native": clang_res,
                "bend_vs_c_o2": ratio_o2,
                "bend_vs_c_o3_native": ratio_o3,
                "bend_vs_c_rss_ratio": rss_ratio,
            }
            results.append(entry)
            print(
                f"{bid:28s} [{spec['stratum']}] "
                f"Bend={bend_res['median_ms']:6.2f}ms  C-O2={co2_res['median_ms']:5.2f}ms ({ratio_o2:5.2f}x)  "
                f"C-O3={co3_res['median_ms']:5.2f}ms ({ratio_o3:5.2f}x)  "
                f"RSS={bend_res['peak_rss_kib']}K/{co2_res['peak_rss_kib']}K ({rss_ratio:.2f}x)  "
                f"{'PASS' if (bun_ok and chk_match) else 'FAIL'}",
                flush=True,
            )

    r_o2 = [e["bend_vs_c_o2"] for e in results if e["bend_vs_c_o2"] is not None]
    r_o3 = [e["bend_vs_c_o3_native"] for e in results if e["bend_vs_c_o3_native"] is not None]
    r_rss = [e["bend_vs_c_rss_ratio"] for e in results if e["bend_vs_c_rss_ratio"] is not None]

    per_stratum: dict[str, Any] = {}
    for sk, sname in STRATA_NAMES.items():
        se = [e for e in results if e["stratum"] == sk]
        so2 = [e["bend_vs_c_o2"] for e in se if e["bend_vs_c_o2"] is not None]
        so3 = [e["bend_vs_c_o3_native"] for e in se if e["bend_vs_c_o3_native"] is not None]
        srss = [e["bend_vs_c_rss_ratio"] for e in se if e["bend_vs_c_rss_ratio"] is not None]
        per_stratum[sk] = {
            "name": sname,
            "n": len(se),
            "bend_vs_c_o2_geomean": round(geomean(so2), 4) if so2 else None,
            "bend_vs_c_o2_median": round(statistics.median(so2), 4) if so2 else None,
            "bend_vs_c_o3_native_geomean": round(geomean(so3), 4) if so3 else None,
            "bend_vs_c_o3_native_median": round(statistics.median(so3), 4) if so3 else None,
            "bend_vs_c_rss_median": round(statistics.median(srss), 4) if srss else None,
        }

    gcc_ver = subprocess.check_output(["gcc-10", "--version"], text=True).splitlines()[0]
    cpu_model = ""
    for line in Path("/proc/cpuinfo").read_text().splitlines():
        if line.startswith("model name"):
            cpu_model = line.split(":", 1)[1].strip()
            break

    report = {
        "schema_version": "external_c_oracle_w24_v1",
        "timestamp_utc": datetime.datetime.now(datetime.timezone.utc).isoformat(),
        "environment": {
            "cpu_model": cpu_model,
            "cpu_pin": args.cpu,
            "runs_per_program": args.runs,
            "gcc_version": gcc_ver,
            "clang_available": bool(clang_bin),
            "bend5k_compiler": str(args.compiler),
            "bend5k_sha256": sha256_file(args.compiler),
            "runtime_obj": str(args.runtime),
            "runtime_sha256": sha256_file(args.runtime),
        },
        "verification": {
            "total_programs": len(results),
            "zero_unsafe_all": all(e["zero_unsafe"] for e in results),
            "bun_check_passed": bun_passed,
            "checksum_matched": checksum_matched,
            "all_passed": all_ok,
        },
        "distribution": {
            "bend_vs_c_o2": summarize_ratios(r_o2) if len(r_o2) == len(results) else None,
            "bend_vs_c_o3_native": summarize_ratios(r_o3) if len(r_o3) == len(results) else None,
            "bend_vs_c_rss": {
                "n": len(r_rss),
                "min": round(min(r_rss), 4),
                "p50_median": round(percentile(r_rss, 50), 4),
                "p90": round(percentile(r_rss, 90), 4),
                "max": round(max(r_rss), 4),
                "geomean": round(geomean(r_rss), 4),
            } if len(r_rss) == len(results) else None,
        },
        "per_stratum": per_stratum,
        "programs": results,
    }

    args.out.write_text(json.dumps(report, indent=2) + "\n")
    print("\n=== EMPIRICAL DISTRIBUTION SUMMARY ===")
    d_o2 = report["distribution"]["bend_vs_c_o2"]
    d_o3 = report["distribution"]["bend_vs_c_o3_native"]
    d_rss = report["distribution"]["bend_vs_c_rss"]
    print(f"Verification: {bun_passed}/20 bun-checked, {checksum_matched}/20 checksum-matched, zero_unsafe={report['verification']['zero_unsafe_all']}")
    print(f"Bend / C-O2        : geomean={d_o2['geomean']:.2f}x (95% CI {d_o2['bootstrap_95_ci'][0]:.2f}x–{d_o2['bootstrap_95_ci'][1]:.2f}x), "
          f"p10={d_o2['p10']:.2f}x, p25={d_o2['p25']:.2f}x, p50={d_o2['p50_median']:.2f}x, p75={d_o2['p75']:.2f}x, p90={d_o2['p90']:.2f}x, max={d_o2['max']:.2f}x")
    print(f"Bend / C-O3-native : geomean={d_o3['geomean']:.2f}x (95% CI {d_o3['bootstrap_95_ci'][0]:.2f}x–{d_o3['bootstrap_95_ci'][1]:.2f}x), "
          f"p10={d_o3['p10']:.2f}x, p25={d_o3['p25']:.2f}x, p50={d_o3['p50_median']:.2f}x, p75={d_o3['p75']:.2f}x, p90={d_o3['p90']:.2f}x, max={d_o3['max']:.2f}x")
    print(f"Bend / C Peak RSS  : median={d_rss['p50_median']:.2f}x, p90={d_rss['p90']:.2f}x, max={d_rss['max']:.2f}x, geomean={d_rss['geomean']:.2f}x")
    return 0 if all_ok else 1


if __name__ == "__main__":
    sys.exit(main())
