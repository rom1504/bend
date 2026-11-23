#!/usr/bin/env python3
"""P5-E: Compiled-Program Runtime Benchmark Audit on Native n3_w10 (x86-object -O2)
vs Pre-Modularization Native wave8-native-self/n1, Prior Waves (4C/5C/6), and C.

Strictly isolated to CPU 4 (taskset -c 4, ulimit -s 262144).
Scratch directory: /tmp/agy_p5_rtbench/ (removed on completion).
Read-only on all compilers, runtime, bench/runtime/, and experiments/ledger.md.
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
N3_W10 = ROOT / "selfhost/build/agy/wave10-native-mod/n3_w10"
W8_N1 = ROOT / "selfhost/build/agy/wave8-native-self/n1"
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

OUT_DIR = ROOT / "research/agy/w10_mod_bend/p5_runtime_bench"
RESULTS_JSON = OUT_DIR / "results.json"
TMP = Path("/tmp/agy_p5_rtbench")
CPU = 4

UPSTREAM_FAMILIES = ("histogram", "gameoflife", "nbody")
TUNED_FAMILIES = ("list", "expression", "bst", "editdist")
ALL_PROXY = UPSTREAM_FAMILIES + TUNED_FAMILIES

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

HOLDOUTS = [
    ("terrain", "2572468224", 6.7841, 31.6880, 39.51),
    ("tree-radix", "1998173798", 4.6657, 16.42, 14.37),
    ("hashmap", "1307803744", 1.2050, 11.21, 11.19),
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


def compile_native(compiler: Path, src: Path, out_obj: Path, timeout: int = 180) -> dict:
    cmd = [
        "bash",
        "-c",
        'ulimit -s 262144 && exec taskset -c "$1" "$2" "${@:3}"',
        "_",
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
        r = subprocess.run(cmd, stdout=f, stderr=subprocess.PIPE, cwd=ROOT, timeout=timeout)
    ms = round((time.perf_counter() - t0) * 1000.0, 1)
    stderr = r.stderr.decode("utf-8", errors="replace")
    if r.returncode != 0:
        return {"ok": False, "rc": r.returncode, "compile_ms": ms, "stderr": stderr[:400]}
    obj_bytes = out_obj.stat().st_size
    nm = subprocess.run(["nm", "--defined-only", str(out_obj)], capture_output=True, text=True)
    product_syms = [
        line.split()[-1]
        for line in nm.stdout.splitlines()
        if "$product." in line or "_product_" in line
    ]
    direct_syms = sum(1 for line in nm.stdout.splitlines() if " p113d_" in line)
    return {
        "ok": True,
        "compile_ms": ms,
        "obj_bytes": obj_bytes,
        "product_sym_count": len(product_syms),
        "product_syms_sample": product_syms[:10],
        "direct_sym_count": direct_syms,
    }


def link_obj(obj: Path, exe: Path) -> None:
    subprocess.run(
        ["taskset", "-c", str(CPU), CC, "-O2", "-no-pie", str(obj), str(AGY_RT), "-lm", "-pthread", "-o", str(exe)],
        check=True,
        capture_output=True,
        text=True,
    )


def run_upstream_once(argv: list[str], expected: int, timeout: float = 90.0) -> tuple[bool, float, str | None]:
    cmd = ["taskset", "-c", str(CPU), *argv]
    t0 = time.monotonic_ns()
    res = subprocess.run(cmd, env=clean_env(), capture_output=True, text=True, timeout=timeout)
    ms = (time.monotonic_ns() - t0) / 1e6
    if res.returncode != 0:
        return False, ms, f"rc={res.returncode} stderr={res.stderr.strip()[:200]}"
    if res.stderr:
        return False, ms, f"stderr={res.stderr.strip()[:200]}"
    if res.stdout != f"{expected}\n":
        return False, ms, f"mismatch: got {res.stdout.strip()!r}, want {expected}"
    return True, ms, None


def measure_upstream(argv: list[str], fam: str, runs: int = 3) -> dict:
    expected = UPSTREAM_EXPECTED[fam]
    samples = []
    for _ in range(runs):
        ok, ms, err = run_upstream_once(argv, expected)
        if not ok:
            return {"ok": False, "error": err}
        samples.append(ms)
    return {"ok": True, "samples_ms": [round(x, 3) for x in samples], "ms": round(float(median(samples)), 4)}


def run_tuned_once(argv: list[str], n: int, seed: int, values: list[int], reps: int, warm: int = 32) -> tuple[bool, int, str | None]:
    cmd = ["taskset", "-c", str(CPU), *argv, str(reps), str(warm), str(n), str(seed)]
    res = subprocess.run(cmd, env=clean_env(), capture_output=True, text=True, timeout=60.0)
    if res.returncode != 0:
        return False, 0, f"rc={res.returncode} stderr={res.stderr.strip()[:200]}"
    if res.stderr:
        return False, 0, f"stderr={res.stderr.strip()[:200]}"
    lines = res.stdout.splitlines()
    want = [str(values[0]), str(batch_hash(values, warm)), str(batch_hash(values, reps))]
    if len(lines) != 4 or lines[:3] != want:
        return False, 0, f"mismatch: got {lines[:3]!r}, want {want!r}"
    return True, int(lines[3]), None


def measure_tuned(argv: list[str], fam: str, values: list[int], init_reps: int, runs: int = 3) -> dict:
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
        "reps": reps,
        "raw_samples_ms": samples,
        "raw_median_ms": med_ms,
        "ms": round(norm_ms, 4),
    }


def geomean(vals: list[float]) -> float:
    return math.exp(sum(math.log(max(v, 1e-9)) for v in vals) / len(vals))


def main() -> int:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    if TMP.exists():
        shutil.rmtree(TMP)
    TMP.mkdir(parents=True, exist_ok=True)

    try:
        up_spec = json.loads((INPUTS_UP / "suite.json").read_text())
        seed_banks = load_tuned_seed_banks()
        w5_proxy = json.loads((ROOT / "experiments/agy/receipts/wave5-final-proxy.json").read_text())
        w5_by_name = {b["name"]: b for b in w5_proxy["benchmarks"]}
        w4c_proxy = json.loads((ROOT / "selfhost/build/agy/wave4_bench/wave4c.json").read_text())
        w4c_by_name = {b["name"]: b for b in w4c_proxy["benchmarks"]}

        print("=== Suite A: 7-Family Wave 4/5/6 Proxy Suite (CPU 4, 3 runs) ===", flush=True)
        proxy_rows = []

        for fam in ALL_PROXY:
            src_path = TMP / f"{fam}.bend"
            if fam in UPSTREAM_FAMILIES:
                src_path.write_text(prepare_upstream_bend(fam, up_spec))
                c_bin = C_REF_DIR / f"{fam}-medium"
                c_res = measure_upstream([str(c_bin)], fam, runs=3)
            else:
                src_path.write_text(prepare_tuned_bend(fam))
                c_bin = C_REF_DIR / f"{fam}-tuned"
                c_res = measure_tuned([str(c_bin)], fam, seed_banks[fam], TUNED_POINTS[fam]["init_reps_c"], runs=3)

            comp_results = {}
            for label, compiler in (("wave8_n1", W8_N1), ("n3_w10", N3_W10)):
                obj = TMP / f"{fam}_{label}.o"
                exe = TMP / f"{fam}_{label}.bin"
                cinfo = compile_native(compiler, src_path, obj)
                if not cinfo["ok"]:
                    comp_results[label] = {"compile": cinfo, "run": {"ok": False, "error": "compile failed"}}
                    continue
                link_obj(obj, exe)
                if fam in UPSTREAM_FAMILIES:
                    rinfo = measure_upstream([str(exe), *RTS_ARGS], fam, runs=3)
                else:
                    rinfo = measure_tuned([str(exe), *RTS_ARGS], fam, seed_banks[fam], TUNED_POINTS[fam]["init_reps_bend"], runs=3)
                comp_results[label] = {"compile": cinfo, "run": rinfo}

            w8_ms = comp_results["wave8_n1"]["run"].get("ms")
            w10_ms = comp_results["n3_w10"]["run"].get("ms")
            c_ms = c_res.get("ms")
            c16_ms = CLANG16_REF_MS[fam]
            w5_ms = w5_by_name[fam]["bend_ms"]
            w4c_ms = w4c_by_name[fam]["bend_ms"]

            ratio_w10_vs_w8 = round(w10_ms / w8_ms, 4) if (w8_ms and w10_ms) else None
            ratio_w10_vs_c = round(w10_ms / c_ms, 4) if (c_ms and w10_ms) else None
            ratio_w8_vs_c = round(w8_ms / c_ms, 4) if (c_ms and w8_ms) else None
            ratio_w10_vs_c16 = round(w10_ms / c16_ms, 4) if w10_ms else None
            ratio_w8_vs_c16 = round(w8_ms / c16_ms, 4) if w8_ms else None

            row = {
                "name": fam,
                "group": "upstream" if fam in UPSTREAM_FAMILIES else "tuned",
                "c_gcc10_cpu4_ms": c_ms,
                "c_clang16_ref_ms": round(c16_ms, 4),
                "wave4c_cpu2_ms": w4c_ms,
                "wave5c_cpu2_ms": w5_ms,
                "wave8_n1_cpu4_ms": w8_ms,
                "n3_w10_cpu4_ms": w10_ms,
                "ratio_n3_vs_w8": ratio_w10_vs_w8,
                "ratio_n3_vs_c": ratio_w10_vs_c,
                "ratio_w8_vs_c": ratio_w8_vs_c,
                "ratio_n3_vs_c16": ratio_w10_vs_c16,
                "ratio_w8_vs_c16": ratio_w8_vs_c16,
                "w8_product_syms": comp_results["wave8_n1"]["compile"].get("product_sym_count", 0),
                "n3_product_syms": comp_results["n3_w10"]["compile"].get("product_sym_count", 0),
                "w8_obj_bytes": comp_results["wave8_n1"]["compile"].get("obj_bytes", 0),
                "n3_obj_bytes": comp_results["n3_w10"]["compile"].get("obj_bytes", 0),
                "details": {"c": c_res, **comp_results},
            }
            proxy_rows.append(row)
            print(
                f"  {fam:12s} | C(gcc10)={c_ms:8.3f}ms | W5C={w5_ms:8.3f}ms | W8={w8_ms:8.3f}ms ($prod={row['w8_product_syms']:2d}) | "
                f"n3_w10={w10_ms:8.3f}ms ($prod={row['n3_product_syms']:2d}) | n3/W8={ratio_w10_vs_w8:.3f}x | n3/C={ratio_w10_vs_c:.3f}x",
                flush=True,
            )

        gm_n3_vs_w8 = round(geomean([r["ratio_n3_vs_w8"] for r in proxy_rows if r["ratio_n3_vs_w8"]]), 4)
        gm_w8_vs_c = round(geomean([r["ratio_w8_vs_c"] for r in proxy_rows if r["ratio_w8_vs_c"]]), 4)
        gm_n3_vs_c = round(geomean([r["ratio_n3_vs_c"] for r in proxy_rows if r["ratio_n3_vs_c"]]), 4)
        gm_w8_vs_c16 = round(geomean([r["ratio_w8_vs_c16"] for r in proxy_rows if r["ratio_w8_vs_c16"]]), 4)
        gm_n3_vs_c16 = round(geomean([r["ratio_n3_vs_c16"] for r in proxy_rows if r["ratio_n3_vs_c16"]]), 4)
        print(
            f"\nProxy 7-Family Geomean: n3_w10/W8={gm_n3_vs_w8:.4f}x | W8/C={gm_w8_vs_c:.4f}x -> n3_w10/C={gm_n3_vs_c:.4f}x | "
            f"W8/C16={gm_w8_vs_c16:.4f}x -> n3_w10/C16={gm_n3_vs_c16:.4f}x\n",
            flush=True,
        )

        print("=== Suite B: Selected bench/runtime/ Holdouts (CPU 4, 1 run) ===", flush=True)
        holdout_rows = []
        for name, expected_str, c_ref_s, w5_s, w6_s in HOLDOUTS:
            src_path = ROOT / "bench/runtime" / name / "main.bend"
            c_src = ROOT / "bench/runtime" / name / "main.c"
            c_exe = TMP / f"{name}.c.bin"
            subprocess.run(
                ["taskset", "-c", str(CPU), CC, "-O3", "-ffp-contract=off", str(c_src), "-lm", "-o", str(c_exe)],
                check=True,
                capture_output=True,
                text=True,
            )
            t0 = time.monotonic()
            cr = subprocess.run(["taskset", "-c", str(CPU), str(c_exe)], capture_output=True, text=True, timeout=60)
            c_live_s = round(time.monotonic() - t0, 4)
            assert cr.returncode == 0 and cr.stdout.strip() == expected_str, (name, cr.returncode, cr.stdout)

            comp_results = {}
            for label, compiler in (("wave8_n1", W8_N1), ("n3_w10", N3_W10)):
                obj = TMP / f"holdout_{name}_{label}.o"
                exe = TMP / f"holdout_{name}_{label}.bin"
                cinfo = compile_native(compiler, src_path, obj, timeout=180)
                if not cinfo["ok"]:
                    comp_results[label] = {"compile": cinfo, "run": {"ok": False, "error": "compile failed"}}
                    continue
                link_obj(obj, exe)
                t0 = time.monotonic()
                try:
                    rr = subprocess.run(
                        ["taskset", "-c", str(CPU), str(exe), *RTS_ARGS],
                        env=clean_env(),
                        capture_output=True,
                        text=True,
                        timeout=120,
                    )
                    dt = round(time.monotonic() - t0, 4)
                    if rr.returncode == 0 and rr.stdout.strip() == expected_str and not rr.stderr:
                        rinfo = {"ok": True, "s": dt, "out": rr.stdout.strip()}
                    else:
                        rinfo = {"ok": False, "s": dt, "error": f"rc={rr.returncode} out={rr.stdout.strip()!r} err={rr.stderr[:120]!r}"}
                except subprocess.TimeoutExpired:
                    rinfo = {"ok": False, "error": "TIMEOUT>120s"}
                comp_results[label] = {"compile": cinfo, "run": rinfo}

            w8_s = comp_results["wave8_n1"]["run"].get("s") if comp_results["wave8_n1"]["run"].get("ok") else None
            n3_s = comp_results["n3_w10"]["run"].get("s") if comp_results["n3_w10"]["run"].get("ok") else None
            ratio_n3_w8 = round(n3_s / w8_s, 4) if (w8_s and n3_s) else None
            ratio_n3_c = round(n3_s / c_live_s, 4) if n3_s else None
            ratio_w8_c = round(w8_s / c_live_s, 4) if w8_s else None

            hrow = {
                "name": name,
                "expected": expected_str,
                "c_gcc10_cpu4_s": c_live_s,
                "wave5c_ref_s": w5_s,
                "wave6_cpu4_ref_s": w6_s,
                "wave8_n1_cpu4_s": w8_s,
                "n3_w10_cpu4_s": n3_s,
                "ratio_n3_vs_w8": ratio_n3_w8,
                "ratio_n3_vs_c": ratio_n3_c,
                "ratio_w8_vs_c": ratio_w8_c,
                "w8_product_syms": comp_results["wave8_n1"]["compile"].get("product_sym_count", 0),
                "n3_product_syms": comp_results["n3_w10"]["compile"].get("product_sym_count", 0),
                "w8_obj_bytes": comp_results["wave8_n1"]["compile"].get("obj_bytes", 0),
                "n3_obj_bytes": comp_results["n3_w10"]["compile"].get("obj_bytes", 0),
                "details": comp_results,
            }
            holdout_rows.append(hrow)
            print(
                f"  {name:12s} | C(gcc10)={c_live_s:7.3f}s | W6={w6_s:6.2f}s | W8={str(w8_s):>7s}s ($prod={hrow['w8_product_syms']:2d}) | "
                f"n3_w10={str(n3_s):>7s}s ($prod={hrow['n3_product_syms']:2d}) | n3/W8={str(ratio_n3_w8):>6s}x | n3/C={str(ratio_n3_c):>6s}x",
                flush=True,
            )

        out = {
            "cpu": CPU,
            "compilers": {
                "wave8_n1": str(W8_N1),
                "n3_w10": str(N3_W10),
                "runtime": str(AGY_RT),
                "cc": CC,
            },
            "proxy_summary": {
                "geomean_n3_vs_w8": gm_n3_vs_w8,
                "geomean_w8_vs_c": gm_w8_vs_c,
                "geomean_n3_vs_c": gm_n3_vs_c,
                "geomean_w8_vs_c16": gm_w8_vs_c16,
                "geomean_n3_vs_c16": gm_n3_vs_c16,
            },
            "proxy_7": proxy_rows,
            "holdouts": holdout_rows,
        }
        RESULTS_JSON.write_text(json.dumps(out, indent=2) + "\n")
        print(f"\nWrote {RESULTS_JSON}", flush=True)
        return 0
    finally:
        if TMP.exists():
            shutil.rmtree(TMP)


if __name__ == "__main__":
    raise SystemExit(main())
