#!/usr/bin/env python3
"""W15-GATE Part 2 & 3: Official 7-Family (5-run median) + 3-Holdout (3-run median) Scorecard on Native n6_o2.

Strictly isolated to CPU 7 (taskset -c 7, ulimit -s 262144), run sequentially AFTER Gate 1 finishes
so there is zero CPU/cache contention.
  - Gate 2: 7-Family Proxy Suite (5-run median, n6_o2 -O2 vs gcc-10 -O2, plus clang-16 ref & W11/W14A refs)
  - Gate 3: 3-Holdout Suite (3-run median, n6_o2 -O2 vs gcc-10 -O2, plus W11 refs)
Hard timeout: 60s per test/compile/link/run.
Scratch directory: /tmp/agy_w15_gate/bench/
"""
from __future__ import annotations

import json
import math
import os
import re
import shutil
import subprocess
import sys
import time
from pathlib import Path
from statistics import median

ROOT = Path("/home/ai/bend2_agy")
N6_O2 = ROOT / "selfhost/build/agy/wave15-native-mod/n6_o2"
BASE_FILE = ROOT / "selfhost/dist/base.bend"
BASE_CARRIER = ROOT / "selfhost/build/agy/bootstrap/base.p130"
BASE_STAMP = "p130-word-pair-v1:p88-private-base-text-1:2dd93239749b4f1e3ee2f4e9617e31aeb5df4cc0200a4c14054a6591e2f74212"
AGY_RT = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"
RTS_ARGS = ["+RTS", "--threads", "1", "--gpu", "off", "-RTS"]

PROXY_DIR = ROOT / "research/agy/wave4_bench"
INPUTS_UP = PROXY_DIR / "inputs/upstream"
INPUTS_TUNED = PROXY_DIR / "inputs/tuned"
C_REF_DIR = ROOT / "selfhost/build/agy/wave4_bench/c_ref"

OUT_DIR = ROOT / "research/agy/w15_final/gate"
RESULTS_JSON = OUT_DIR / "bench_results.json"
TMP = Path("/tmp/agy_w15_gate/bench")
CPU = 7
HARD_TIMEOUT = 60

UPSTREAM_FAMILIES = ("gameoflife", "nbody", "histogram")
TUNED_FAMILIES = ("expression", "list", "bst", "editdist")
ALL_PROXY = ("gameoflife", "expression", "list", "nbody", "histogram", "bst", "editdist")

UPSTREAM_EXPECTED = {
    "histogram": 3307081914,
    "gameoflife": 3681094808,
    "nbody": 728502159,
}

TUNED_POINTS = {
    "list": {
        "id": "coverage-list-pipeline-128",
        "n": 128,
        "seed": 17,
        "expected": 1904,
        "fixed_reps": 99496,
        "init_reps_bend": 12_000_000,
        "init_reps_c": 20_000_000,
    },
    "expression": {
        "id": "coverage-expression-128",
        "n": 128,
        "seed": 123,
        "expected": 3393903617,
        "fixed_reps": 37732,
        "init_reps_bend": 128_000,
        "init_reps_c": 320_000,
    },
    "bst": {
        "id": "coverage-bst-64",
        "n": 64,
        "seed": 17,
        "expected": 861157620,
        "fixed_reps": 27184,
        "init_reps_bend": 32_000,
        "init_reps_c": 160_000,
    },
    "editdist": {
        "id": "editdist",
        "n": 2,
        "seed": 0,
        "expected": 2065873279,
        "fixed_reps": 240,
        "init_reps_bend": 128,
        "init_reps_c": 1536,
    },
}

CLANG16_REF_MS = {
    "histogram": 24.0,
    "gameoflife": 241.5,
    "nbody": 74.7,
    "list": 0.0027 * 99496 / 1000.0,
    "expression": 0.1918 * 37732 / 1000.0,
    "bst": 0.3986 * 27184 / 1000.0,
    "editdist": 38.4115 * 240 / 1000.0,
}

W11_N4_PROXY_MS = {
    "histogram": 42.38,
    "gameoflife": 470.25,
    "nbody": 93.46,
    "list": 0.390,
    "expression": 9.14,
    "bst": 30.58,
    "editdist": 23.13,
}

W11_N4_HOLDOUT_S = {
    "terrain": 21.731,
    "hashmap": 7.166,
    "tree-radix": 11.699,
}

HOLDOUTS = [
    ("terrain", "2572468224"),
    ("hashmap", "1307803744"),
    ("tree-radix", "1998173798"),
]

MASK32 = (1 << 32) - 1


def clean_env() -> dict[str, str]:
    env = dict(os.environ)
    env.pop("BENDRTS", None)
    return env


def replace_once(text: str, pattern: str, repl: str) -> str:
    out, n = re.subn(pattern, repl, text, flags=re.M)
    if n != 1:
        raise ValueError(f"expected 1 match for {pattern!r}, found {n}")
    return out


def prepare_upstream_bend(family: str, up_spec: dict) -> str:
    desc = up_spec[family]
    text = (INPUTS_UP / family / "main.bend").read_text()
    for bname, old, new in zip(desc["bendKnobs"], desc["upstream"], desc["medium"]):
        text = replace_once(
            text,
            rf"(^def {bname}\(\) -> Nat:\n  ){old}n$",
            rf"\g<1>{new}n",
        )
    return text


def prepare_tuned_bend(family: str) -> str:
    kernel = (INPUTS_TUNED / "kernels" / f"{family}.bend").read_text()
    driver = (INPUTS_TUNED / "driver.bend").read_text()
    return kernel.rstrip() + "\n\n" + driver


def load_tuned_seed_banks() -> dict[str, list[int]]:
    data = json.loads((INPUTS_TUNED / "results.json").read_text())
    by_id = {row["id"]: row for row in data.get("rows", [])}
    banks = {}
    for fam, spec in TUNED_POINTS.items():
        row = by_id[spec["id"]]
        assert row["input"] == [spec["n"], spec["seed"]]
        assert row["expected"] == spec["expected"]
        banks[fam] = row["seed_bank"]
    return banks


def batch_hash(values: list[int], count: int) -> int:
    mult = 16777619
    block = 0
    for v in values:
        block = (mult * block + v) & MASK32
    factor = pow(mult, 32, 1 << 32)
    repeats, tail = divmod(count, 32)
    h = 0
    while repeats:
        if repeats & 1:
            h = (factor * h + block) & MASK32
        block = (factor * block + block) & MASK32
        factor = (factor * factor) & MASK32
        repeats >>= 1
    for v in values[:tail]:
        h = (mult * h + v) & MASK32
    return h


def compile_native(compiler: Path, src: Path, out_obj: Path, timeout: int = HARD_TIMEOUT) -> dict:
    cmd = [
        "bash",
        "-c",
        'ulimit -s 262144 && exec timeout -k 5 "$1" taskset -c "$2" "$3" "${@:4}"',
        "_",
        str(timeout),
        str(CPU),
        str(compiler),
        "x86-object",
        str(src),
        str(BASE_FILE),
        "cache",
        str(BASE_CARRIER),
        BASE_STAMP,
    ]
    t0 = time.perf_counter()
    with out_obj.open("wb") as f:
        r = subprocess.run(cmd, stdout=f, stderr=subprocess.PIPE, cwd=ROOT, timeout=timeout + 10)
    ms = round((time.perf_counter() - t0) * 1000.0, 1)
    stderr = r.stderr.decode("utf-8", errors="replace")
    if r.returncode != 0:
        return {"ok": False, "rc": r.returncode, "compile_ms": ms, "stderr": stderr[:400]}
    obj_bytes = out_obj.stat().st_size
    nm = subprocess.run(["nm", "--defined-only", str(out_obj)], capture_output=True, text=True)
    direct_syms = sum(1 for line in nm.stdout.splitlines() if " p113d_" in line)
    return {
        "ok": True,
        "compile_ms": ms,
        "obj_bytes": obj_bytes,
        "direct_sym_count": direct_syms,
    }


def link_obj(obj: Path, exe: Path) -> None:
    subprocess.run(
        ["timeout", "-k", "5", str(HARD_TIMEOUT), "taskset", "-c", str(CPU), CC, "-O2", "-no-pie", str(obj), str(AGY_RT), "-lm", "-pthread", "-o", str(exe)],
        check=True,
        capture_output=True,
        text=True,
        timeout=HARD_TIMEOUT + 10,
    )


def run_upstream_once(argv: list[str], expected: int, timeout: int = HARD_TIMEOUT) -> tuple[bool, float, str | None]:
    cmd = ["timeout", "-k", "5", str(timeout), "taskset", "-c", str(CPU), *argv]
    t0 = time.monotonic_ns()
    res = subprocess.run(cmd, env=clean_env(), capture_output=True, text=True, timeout=timeout + 10)
    ms = (time.monotonic_ns() - t0) / 1e6
    if res.returncode != 0:
        return False, ms, f"rc={res.returncode} stderr={res.stderr.strip()[:200]}"
    if res.stderr:
        return False, ms, f"stderr={res.stderr.strip()[:200]}"
    if res.stdout != f"{expected}\n":
        return False, ms, f"mismatch: got {res.stdout.strip()!r}, want {expected}"
    return True, ms, None


def measure_upstream(argv: list[str], fam: str, runs: int = 5) -> dict:
    expected = UPSTREAM_EXPECTED[fam]
    samples = []
    for _ in range(runs):
        ok, ms, err = run_upstream_once(argv, expected)
        if not ok:
            return {"ok": False, "error": err}
        samples.append(ms)
    return {
        "ok": True,
        "expected": expected,
        "samples_ms": [round(x, 3) for x in samples],
        "ms": round(float(median(samples)), 4),
    }


def run_tuned_once(argv: list[str], n: int, seed: int, values: list[int], reps: int, warm: int = 32) -> tuple[bool, int, str | None]:
    cmd = ["timeout", "-k", "5", str(HARD_TIMEOUT), "taskset", "-c", str(CPU), *argv, str(reps), str(warm), str(n), str(seed)]
    res = subprocess.run(cmd, env=clean_env(), capture_output=True, text=True, timeout=HARD_TIMEOUT + 10)
    if res.returncode != 0:
        return False, 0, f"rc={res.returncode} stderr={res.stderr.strip()[:200]}"
    if res.stderr:
        return False, 0, f"stderr={res.stderr.strip()[:200]}"
    lines = res.stdout.splitlines()
    want = [str(values[0]), str(batch_hash(values, warm)), str(batch_hash(values, reps))]
    if len(lines) != 4 or lines[:3] != want:
        return False, 0, f"mismatch: got {lines[:3]!r}, want {want!r}"
    return True, int(lines[3]), None


def measure_tuned(argv: list[str], fam: str, values: list[int], init_reps: int, runs: int = 5) -> dict:
    spec = TUNED_POINTS[fam]
    n, seed = spec["n"], spec["seed"]
    reps = init_reps
    samples = []
    for _ in range(5):
        ok, ms, err = run_tuned_once(argv, n, seed, values, reps)
        if not ok:
            return {"ok": False, "error": err}
        if ms >= 30 or reps >= 100_000_000:
            samples.append(ms)
            break
        scale = min(16, max(2, math.ceil(64 / max(ms, 1))))
        reps = min(100_000_000, ((reps * scale + 31) // 32) * 32)
    else:
        samples.append(ms)
    while len(samples) < runs:
        ok, ms, err = run_tuned_once(argv, n, seed, values, reps)
        if not ok:
            return {"ok": False, "error": err}
        samples.append(ms)
    med_ms = float(median(samples))
    us_per_call = (med_ms * 1000.0) / reps
    norm_ms = us_per_call * spec["fixed_reps"] / 1000.0
    return {
        "ok": True,
        "expected": spec["expected"],
        "reps": reps,
        "raw_samples_ms": samples,
        "raw_median_ms": med_ms,
        "ms": round(norm_ms, 4),
    }


def measure_holdout(argv: list[str], expected_str: str, runs: int = 3, timeout: int = HARD_TIMEOUT) -> dict:
    samples = []
    for _ in range(runs):
        cmd = ["timeout", "-k", "5", str(timeout), "taskset", "-c", str(CPU), *argv]
        t0 = time.monotonic()
        try:
            rr = subprocess.run(cmd, env=clean_env(), capture_output=True, text=True, timeout=timeout + 10)
            dt = round(time.monotonic() - t0, 4)
            if rr.returncode == 0 and rr.stdout.strip() == expected_str and not rr.stderr:
                samples.append(dt)
            else:
                return {
                    "ok": False,
                    "samples_s": samples,
                    "error": f"rc={rr.returncode} out={rr.stdout.strip()!r} err={rr.stderr[:120]!r}",
                }
        except subprocess.TimeoutExpired:
            return {"ok": False, "samples_s": samples, "error": f"TIMEOUT>{timeout}s"}
    return {
        "ok": True,
        "samples_s": samples,
        "s": round(float(median(samples)), 4),
        "out": expected_str,
    }


def geomean(vals: list[float]) -> float:
    return math.exp(sum(math.log(max(v, 1e-9)) for v in vals) / len(vals))


def main() -> int:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    if TMP.exists():
        shutil.rmtree(TMP)
    TMP.mkdir(parents=True, exist_ok=True)

    t_all = time.perf_counter()
    try:
        up_spec = json.loads((INPUTS_UP / "suite.json").read_text())
        seed_banks = load_tuned_seed_banks()

        print(f"=== Gate 2: Official 7-Family Suite (CPU {CPU}, 5-run median, n6_o2 -O2 vs gcc-10 -O2) ===", flush=True)
        proxy_rows = []

        for fam in ALL_PROXY:
            src_path = TMP / f"{fam}.bend"
            if fam in UPSTREAM_FAMILIES:
                src_path.write_text(prepare_upstream_bend(fam, up_spec))
                c_bin = C_REF_DIR / f"{fam}-medium"
                c_res = measure_upstream([str(c_bin)], fam, runs=5)
                expected = UPSTREAM_EXPECTED[fam]
            else:
                src_path.write_text(prepare_tuned_bend(fam))
                c_bin = C_REF_DIR / f"{fam}-tuned"
                c_res = measure_tuned([str(c_bin)], fam, seed_banks[fam], TUNED_POINTS[fam]["init_reps_c"], runs=5)
                expected = TUNED_POINTS[fam]["expected"]

            obj = TMP / f"{fam}_n6_o2.o"
            exe = TMP / f"{fam}_n6_o2.bin"
            cinfo = compile_native(N6_O2, src_path, obj)
            if not cinfo["ok"]:
                rinfo = {"ok": False, "error": "compile failed"}
            else:
                link_obj(obj, exe)
                if fam in UPSTREAM_FAMILIES:
                    rinfo = measure_upstream([str(exe), *RTS_ARGS], fam, runs=5)
                else:
                    rinfo = measure_tuned([str(exe), *RTS_ARGS], fam, seed_banks[fam], TUNED_POINTS[fam]["init_reps_bend"], runs=5)
            obj.unlink(missing_ok=True)
            exe.unlink(missing_ok=True)

            n6_ms = rinfo.get("ms") if rinfo.get("ok") else None
            c_ms = c_res.get("ms") if c_res.get("ok") else None
            c16_ms = CLANG16_REF_MS[fam]
            w11_ms = W11_N4_PROXY_MS[fam]

            ratio_n6_vs_c = round(n6_ms / c_ms, 4) if (c_ms and n6_ms) else None
            ratio_n6_vs_c16 = round(n6_ms / c16_ms, 4) if n6_ms else None
            speedup_vs_w11 = round(w11_ms / n6_ms, 4) if (w11_ms and n6_ms) else None

            row = {
                "name": fam,
                "group": "upstream" if fam in UPSTREAM_FAMILIES else "tuned",
                "expected_checksum": expected,
                "checksum_ok": bool(rinfo.get("ok") and c_res.get("ok")),
                "n6_o2_ms": n6_ms,
                "c_gcc10_ms": c_ms,
                "c_clang16_ref_ms": round(c16_ms, 4),
                "w11_n4_ref_ms": w11_ms,
                "ratio_n6_vs_c": ratio_n6_vs_c,
                "ratio_n6_vs_c16": ratio_n6_vs_c16,
                "speedup_vs_w11": speedup_vs_w11,
                "n6_compile_ms": cinfo.get("compile_ms"),
                "n6_obj_bytes": cinfo.get("obj_bytes", 0),
                "n6_direct_syms": cinfo.get("direct_sym_count", 0),
                "details": {"c_gcc10": c_res, "n6_o2": {"compile": cinfo, "run": rinfo}},
            }
            proxy_rows.append(row)
            print(
                f"  {fam:12s} | n6_o2={str(n6_ms):>9s} ms | gcc10={str(c_ms):>9s} ms | "
                f"n6/gcc10={str(ratio_n6_vs_c):>7s}x | n6/c16ref={str(ratio_n6_vs_c16):>7s}x | "
                f"vsW11={str(speedup_vs_w11):>6s}x | syms={row['n6_direct_syms']:2d} | obj={row['n6_obj_bytes']} B | ok={row['checksum_ok']}",
                flush=True,
            )

        gm_n6_vs_c = round(geomean([r["ratio_n6_vs_c"] for r in proxy_rows if r["ratio_n6_vs_c"]]), 4)
        gm_n6_vs_c16 = round(geomean([r["ratio_n6_vs_c16"] for r in proxy_rows if r["ratio_n6_vs_c16"]]), 4)
        gm_speedup_w11 = round(geomean([r["speedup_vs_w11"] for r in proxy_rows if r["speedup_vs_w11"]]), 4)
        print(
            f"\n=> Gate 2 7-Family Geomean: n6_o2 / gcc-10 -O2 = {gm_n6_vs_c:.4f}x | "
            f"n6_o2 / clang-16 ref = {gm_n6_vs_c16:.4f}x | speedup vs W11 = {gm_speedup_w11:.4f}x\n",
            flush=True,
        )

        print(f"=== Gate 3: Official 3-Holdout Suite (CPU {CPU}, 3-run median, n6_o2 -O2 vs gcc-10 -O2) ===", flush=True)
        holdout_rows = []
        for name, expected_str in HOLDOUTS:
            src_path = ROOT / "bench/runtime" / name / "main.bend"
            c_src = ROOT / "bench/runtime" / name / "main.c"
            c_exe = TMP / f"{name}.c_o2.bin"
            subprocess.run(
                ["timeout", "-k", "5", str(HARD_TIMEOUT), "taskset", "-c", str(CPU), CC, "-O2", "-ffp-contract=off", str(c_src), "-lm", "-o", str(c_exe)],
                check=True,
                capture_output=True,
                text=True,
                timeout=HARD_TIMEOUT + 10,
            )
            c_res = measure_holdout([str(c_exe)], expected_str, runs=3, timeout=HARD_TIMEOUT)
            c_exe.unlink(missing_ok=True)
            assert c_res["ok"], (name, c_res)
            c_live_s = c_res["s"]

            obj = TMP / f"holdout_{name}_n6_o2.o"
            exe = TMP / f"holdout_{name}_n6_o2.bin"
            cinfo = compile_native(N6_O2, src_path, obj, timeout=HARD_TIMEOUT)
            if not cinfo["ok"]:
                n6_run = {"ok": False, "error": "compile failed"}
            else:
                link_obj(obj, exe)
                n6_run = measure_holdout([str(exe), *RTS_ARGS], expected_str, runs=3, timeout=HARD_TIMEOUT)
            obj.unlink(missing_ok=True)
            exe.unlink(missing_ok=True)

            n6_s = n6_run.get("s") if n6_run.get("ok") else None
            w11_s = W11_N4_HOLDOUT_S[name]
            ratio_n6_c = round(n6_s / c_live_s, 4) if n6_s else None
            speedup_vs_w11 = round(w11_s / n6_s, 4) if n6_s else None

            hrow = {
                "name": name,
                "expected": expected_str,
                "checksum_ok": bool(n6_run.get("ok") and c_res.get("ok")),
                "n6_o2_s": n6_s,
                "c_gcc10_o2_s": c_live_s,
                "w11_n4_ref_s": w11_s,
                "ratio_n6_vs_c_o2": ratio_n6_c,
                "speedup_vs_w11": speedup_vs_w11,
                "n6_compile_ms": cinfo.get("compile_ms"),
                "n6_obj_bytes": cinfo.get("obj_bytes", 0),
                "n6_direct_syms": cinfo.get("direct_sym_count", 0),
                "details": {"c_o2": c_res, "n6_o2": {"compile": cinfo, "run": n6_run}},
            }
            holdout_rows.append(hrow)
            print(
                f"  {name:12s} | n6_o2={str(n6_s):>8s} s | gcc10={c_live_s:7.4f} s | "
                f"n6/gcc10={str(ratio_n6_c):>7s}x | vsW11({w11_s:.3f}s)={str(speedup_vs_w11):>6s}x | "
                f"syms={hrow['n6_direct_syms']:2d} | obj={hrow['n6_obj_bytes']} B | ok={hrow['checksum_ok']}",
                flush=True,
            )

        gm_holdout_n6_c = (
            round(geomean([r["ratio_n6_vs_c_o2"] for r in holdout_rows if r["ratio_n6_vs_c_o2"]]), 4)
            if all(r["ratio_n6_vs_c_o2"] for r in holdout_rows)
            else None
        )
        gm_holdout_speedup_w11 = (
            round(geomean([r["speedup_vs_w11"] for r in holdout_rows if r["speedup_vs_w11"]]), 4)
            if all(r["speedup_vs_w11"] for r in holdout_rows)
            else None
        )
        print(
            f"\n=> Gate 3 3-Holdout Geomean: n6_o2 / gcc-10 -O2 = {gm_holdout_n6_c:.4f}x | "
            f"speedup vs W11 = {gm_holdout_speedup_w11:.4f}x\n",
            flush=True,
        )

        all_proxy_ok = all(r["checksum_ok"] for r in proxy_rows)
        all_holdout_ok = all(r["checksum_ok"] for r in holdout_rows)
        total_wall_s = round(time.perf_counter() - t_all, 2)

        out = {
            "cpu": CPU,
            "hard_timeout_s": HARD_TIMEOUT,
            "proxy_runs": 5,
            "holdout_runs": 3,
            "clang16_installed": False,
            "compilers": {
                "n6_o2": str(N6_O2),
                "runtime": str(AGY_RT),
                "cc": CC,
            },
            "all_proxy_ok": all_proxy_ok,
            "all_holdout_ok": all_holdout_ok,
            "total_wall_s": total_wall_s,
            "proxy_summary": {
                "geomean_n6_vs_gcc10": gm_n6_vs_c,
                "geomean_n6_vs_clang16_ref": gm_n6_vs_c16,
                "geomean_speedup_vs_w11": gm_speedup_w11,
            },
            "holdout_summary": {
                "geomean_n6_vs_gcc10_o2": gm_holdout_n6_c,
                "geomean_speedup_vs_w11": gm_holdout_speedup_w11,
            },
            "proxy_7": proxy_rows,
            "holdouts": holdout_rows,
        }
        RESULTS_JSON.write_text(json.dumps(out, indent=2) + "\n")
        print(
            f"Wrote {RESULTS_JSON} (all_proxy_ok={all_proxy_ok}, all_holdout_ok={all_holdout_ok}, wall={total_wall_s:.2f}s)",
            flush=True,
        )
        return 0 if (all_proxy_ok and all_holdout_ok) else 1
    finally:
        if TMP.exists():
            shutil.rmtree(TMP, ignore_errors=True)


if __name__ == "__main__":
    raise SystemExit(main())
