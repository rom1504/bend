#!/usr/bin/env python3
"""Benchmark harness for selfhost/bend5k on the 7-family proxy suite + terrain holdout.

Measures compile time, object size, and 3-run median execution time on CPU 7
against gcc-10 -O2 with exact output/checksum verification. Reusable for both
-O0 baseline and Milestone 4 -O2 comparisons.
"""
from __future__ import annotations

import argparse
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
RT_OBJ = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"
RTS_ARGS = ["+RTS", "--threads", "1", "--gpu", "off", "-RTS"]

PROXY_DIR = ROOT / "research/agy/wave4_bench"
INPUTS_UP = PROXY_DIR / "inputs/upstream"
INPUTS_TUNED = PROXY_DIR / "inputs/tuned"
C_REF_DIR = ROOT / "selfhost/build/agy/wave4_bench/c_ref"

UPSTREAM_FAMILIES = ("gameoflife", "nbody", "histogram")
TUNED_FAMILIES = ("expression", "list", "bst", "editdist")
ALL_PROXY = ("expression", "nbody", "histogram", "editdist", "list", "gameoflife", "bst")

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
        "init_reps_bend": 100_000,
        "init_reps_c": 20_000_000,
    },
    "expression": {
        "id": "coverage-expression-128",
        "n": 128,
        "seed": 123,
        "expected": 3393903617,
        "fixed_reps": 37732,
        "init_reps_bend": 4_000,
        "init_reps_c": 320_000,
    },
    "bst": {
        "id": "coverage-bst-64",
        "n": 64,
        "seed": 17,
        "expected": 861157620,
        "fixed_reps": 27184,
        "init_reps_bend": 2_000,
        "init_reps_c": 160_000,
    },
    "editdist": {
        "id": "editdist",
        "n": 2,
        "seed": 0,
        "expected": 2065873279,
        "fixed_reps": 240,
        "init_reps_bend": 32,
        "init_reps_c": 1536,
    },
}

HOLDOUT_SPECS = {
    "terrain": ("bench/runtime/terrain/main.bend", "bench/runtime/terrain/main.c", "2572468224"),
}

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
    text = (INPUTS_UP / family / "main.bend").read_text(encoding="utf-8")
    for bname, old, new in zip(desc["bendKnobs"], desc["upstream"], desc["medium"]):
        text = replace_once(
            text,
            rf"(^def {bname}\(\) -> Nat:\n  ){old}n$",
            rf"\g<1>{new}n",
        )
    return text


def prepare_tuned_bend(family: str) -> str:
    kernel = (INPUTS_TUNED / "kernels" / f"{family}.bend").read_text(encoding="utf-8")
    driver = (INPUTS_TUNED / "driver.bend").read_text(encoding="utf-8")
    return kernel.rstrip() + "\n\n" + driver


def load_tuned_seed_banks() -> dict[str, list[int]]:
    data = json.loads((INPUTS_TUNED / "results.json").read_text(encoding="utf-8"))
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


def compile_bend5k(
    compiler: Path,
    src: Path,
    out_obj: Path,
    cpu: int,
    timeout: int,
    extra_args: list[str],
) -> dict:
    cmd = [
        "bash",
        "-c",
        'ulimit -s 262144 && exec timeout -k 5 "$1" taskset -c "$2" "$3" "${@:4}"',
        "_",
        str(timeout),
        str(cpu),
        str(compiler),
        *extra_args,
        str(src),
        str(out_obj),
    ]
    t0 = time.perf_counter()
    try:
        r = subprocess.run(cmd, capture_output=True, text=True, cwd=ROOT, timeout=timeout + 10)
    except subprocess.TimeoutExpired:
        return {"ok": False, "rc": -1, "compile_ms": round((time.perf_counter() - t0) * 1000.0, 2), "stderr": f"TIMEOUT>{timeout}s"}
    ms = round((time.perf_counter() - t0) * 1000.0, 2)
    if r.returncode != 0 or not out_obj.exists():
        return {"ok": False, "rc": r.returncode, "compile_ms": ms, "stderr": (r.stderr or r.stdout)[:400]}
    return {"ok": True, "compile_ms": ms, "obj_bytes": out_obj.stat().st_size}


def link_obj(obj: Path, exe: Path, cpu: int, timeout: int) -> float:
    t0 = time.perf_counter()
    subprocess.run(
        ["timeout", "-k", "5", str(timeout), "taskset", "-c", str(cpu), CC, "-O2", "-no-pie", str(obj), str(RT_OBJ), "-lm", "-pthread", "-o", str(exe)],
        check=True,
        capture_output=True,
        text=True,
        timeout=timeout + 10,
    )
    return round((time.perf_counter() - t0) * 1000.0, 2)


def run_upstream_once(argv: list[str], expected: int, cpu: int, timeout: int) -> tuple[bool, float, str | None]:
    cmd = ["timeout", "-k", "5", str(timeout), "taskset", "-c", str(cpu), *argv]
    t0 = time.monotonic_ns()
    try:
        res = subprocess.run(cmd, env=clean_env(), capture_output=True, text=True, timeout=timeout + 10)
    except subprocess.TimeoutExpired:
        return False, (time.monotonic_ns() - t0) / 1e6, f"TIMEOUT>{timeout}s"
    ms = (time.monotonic_ns() - t0) / 1e6
    if res.returncode != 0:
        return False, ms, f"rc={res.returncode} stderr={res.stderr.strip()[:200]}"
    if res.stderr:
        return False, ms, f"stderr={res.stderr.strip()[:200]}"
    if res.stdout != f"{expected}\n":
        return False, ms, f"mismatch: got {res.stdout.strip()!r}, want {expected}"
    return True, ms, None


def measure_upstream(argv: list[str], fam: str, cpu: int, runs: int, timeout: int) -> dict:
    expected = UPSTREAM_EXPECTED[fam]
    samples = []
    for _ in range(runs):
        ok, ms, err = run_upstream_once(argv, expected, cpu, timeout)
        if not ok:
            return {"ok": False, "error": err, "samples_ms": [round(x, 3) for x in samples]}
        samples.append(ms)
    return {
        "ok": True,
        "expected": expected,
        "samples_ms": [round(x, 3) for x in samples],
        "ms": round(float(median(samples)), 4),
    }


def run_tuned_once(argv: list[str], n: int, seed: int, values: list[int], reps: int, cpu: int, timeout: int, warm: int = 32) -> tuple[bool, int, str | None]:
    cmd = ["timeout", "-k", "5", str(timeout), "taskset", "-c", str(cpu), *argv, str(reps), str(warm), str(n), str(seed)]
    try:
        res = subprocess.run(cmd, env=clean_env(), capture_output=True, text=True, timeout=timeout + 10)
    except subprocess.TimeoutExpired:
        return False, 0, f"TIMEOUT>{timeout}s"
    if res.returncode != 0:
        return False, 0, f"rc={res.returncode} stderr={res.stderr.strip()[:200]}"
    if res.stderr:
        return False, 0, f"stderr={res.stderr.strip()[:200]}"
    lines = res.stdout.splitlines()
    want = [str(values[0]), str(batch_hash(values, warm)), str(batch_hash(values, reps))]
    if len(lines) != 4 or lines[:3] != want:
        return False, 0, f"mismatch: got {lines[:3]!r}, want {want!r}"
    return True, int(lines[3]), None


def measure_tuned(argv: list[str], fam: str, values: list[int], init_reps: int, cpu: int, runs: int, timeout: int) -> dict:
    spec = TUNED_POINTS[fam]
    n, seed = spec["n"], spec["seed"]
    reps = init_reps
    samples = []
    ms = 0
    for _ in range(6):
        ok, ms, err = run_tuned_once(argv, n, seed, values, reps, cpu, timeout)
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
        ok, ms, err = run_tuned_once(argv, n, seed, values, reps, cpu, timeout)
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


def measure_holdout(argv: list[str], expected_str: str, cpu: int, runs: int, timeout: int) -> dict:
    samples = []
    for _ in range(runs):
        cmd = ["timeout", "-k", "5", str(timeout), "taskset", "-c", str(cpu), *argv]
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


def geomean(vals: list[float]) -> float | None:
    if not vals:
        return None
    return math.exp(sum(math.log(max(v, 1e-9)) for v in vals) / len(vals))


def main() -> int:
    ap = argparse.ArgumentParser(description="Benchmark bend5k on 7-family proxy suite + terrain holdout")
    ap.add_argument("--bend5k", type=Path, required=True, help="Path to bend5k compiler binary")
    ap.add_argument("--work-dir", type=Path, default=Path("/tmp/agy_b5k_bench"))
    ap.add_argument("--cpu", type=int, default=7)
    ap.add_argument("--runs", type=int, default=3)
    ap.add_argument("--timeout", type=int, default=60)
    ap.add_argument("--holdout-timeout", type=int, default=180)
    ap.add_argument("--opt-flag", type=str, default="", help="Optional flag passed before <src> <obj>, e.g. -O2")
    ap.add_argument("--label", type=str, default="bend5k-O0")
    ap.add_argument("--json-out", type=Path, default=None)
    ap.add_argument("--keep-work-dir", action="store_true")
    args = ap.parse_args()

    extra_args = [args.opt_flag] if args.opt_flag else []
    if args.work_dir.exists():
        shutil.rmtree(args.work_dir)
    args.work_dir.mkdir(parents=True, exist_ok=True)

    t_all = time.perf_counter()
    try:
        up_spec = json.loads((INPUTS_UP / "suite.json").read_text(encoding="utf-8"))
        seed_banks = load_tuned_seed_banks()

        print(f"=== {args.label}: 7-Family Proxy Suite (CPU {args.cpu}, {args.runs}-run median vs gcc-10 -O2) ===", flush=True)
        proxy_rows = []
        for fam in ALL_PROXY:
            src_path = args.work_dir / f"{fam}.bend"
            if fam in UPSTREAM_FAMILIES:
                src_path.write_text(prepare_upstream_bend(fam, up_spec), encoding="utf-8")
                c_bin = C_REF_DIR / f"{fam}-medium"
                c_res = measure_upstream([str(c_bin)], fam, args.cpu, args.runs, args.timeout)
                expected = UPSTREAM_EXPECTED[fam]
            else:
                src_path.write_text(prepare_tuned_bend(fam), encoding="utf-8")
                c_bin = C_REF_DIR / f"{fam}-tuned"
                c_res = measure_tuned([str(c_bin)], fam, seed_banks[fam], TUNED_POINTS[fam]["init_reps_c"], args.cpu, args.runs, args.timeout)
                expected = TUNED_POINTS[fam]["expected"]

            obj = args.work_dir / f"{fam}.o"
            exe = args.work_dir / f"{fam}.bin"
            cinfo = compile_bend5k(args.bend5k, src_path, obj, args.cpu, args.timeout, extra_args)
            link_ms = None
            if not cinfo["ok"]:
                rinfo = {"ok": False, "error": f"compile failed: {cinfo.get('stderr', '')[:120]}"}
            else:
                try:
                    link_ms = link_obj(obj, exe, args.cpu, args.timeout)
                    if fam in UPSTREAM_FAMILIES:
                        rinfo = measure_upstream([str(exe), *RTS_ARGS], fam, args.cpu, args.runs, args.timeout)
                    else:
                        rinfo = measure_tuned([str(exe), *RTS_ARGS], fam, seed_banks[fam], TUNED_POINTS[fam]["init_reps_bend"], args.cpu, args.runs, args.timeout)
                except subprocess.CalledProcessError as e:
                    rinfo = {"ok": False, "error": f"link failed: {(e.stderr or '')[:160]}"}
            obj.unlink(missing_ok=True)
            exe.unlink(missing_ok=True)

            b_ms = rinfo.get("ms") if rinfo.get("ok") else None
            c_ms = c_res.get("ms") if c_res.get("ok") else None
            ratio = round(b_ms / c_ms, 4) if (b_ms is not None and c_ms) else None
            row = {
                "name": fam,
                "group": "upstream" if fam in UPSTREAM_FAMILIES else "tuned",
                "expected_checksum": expected,
                "checksum_ok": bool(rinfo.get("ok") and c_res.get("ok")),
                "bend5k_ms": b_ms,
                "c_gcc10_ms": c_ms,
                "ratio_vs_gcc10": ratio,
                "compile_ms": cinfo.get("compile_ms"),
                "link_ms": link_ms,
                "obj_bytes": cinfo.get("obj_bytes", 0),
                "error": None if rinfo.get("ok") else rinfo.get("error"),
                "details": {"c_gcc10": c_res, "bend5k": {"compile": cinfo, "run": rinfo}},
            }
            proxy_rows.append(row)
            status = "OK" if row["checksum_ok"] else f"FAIL ({row['error']})"
            print(
                f"  {fam:12s} | b5k={str(b_ms):>10s} ms | gcc10={str(c_ms):>9s} ms | "
                f"ratio={str(ratio):>8s}x | cmp={str(cinfo.get('compile_ms')):>7s} ms | "
                f"obj={row['obj_bytes']:>7d} B | {status}",
                flush=True,
            )

        gm_proxy = geomean([r["ratio_vs_gcc10"] for r in proxy_rows if r["ratio_vs_gcc10"] is not None])
        gm_proxy = round(gm_proxy, 4) if gm_proxy is not None else None
        print(f"\n=> 7-Family Geomean ({args.label} / gcc-10 -O2): {gm_proxy}x (ok={sum(r['checksum_ok'] for r in proxy_rows)}/7)\n", flush=True)

        print(f"=== {args.label}: Terrain Holdout (CPU {args.cpu}, {args.runs}-run median vs gcc-10 -O2) ===", flush=True)
        holdout_rows = []
        for name, (b_rel, c_rel, expected_str) in HOLDOUT_SPECS.items():
            src_path = ROOT / b_rel
            c_src = ROOT / c_rel
            c_exe = args.work_dir / f"{name}_c_o2.bin"
            subprocess.run(
                ["timeout", "-k", "5", str(args.timeout), "taskset", "-c", str(args.cpu), CC, "-O2", "-ffp-contract=off", str(c_src), "-lm", "-o", str(c_exe)],
                check=True,
                capture_output=True,
                text=True,
                timeout=args.timeout + 10,
            )
            c_res = measure_holdout([str(c_exe)], expected_str, args.cpu, args.runs, args.holdout_timeout)
            c_exe.unlink(missing_ok=True)

            obj = args.work_dir / f"{name}.o"
            exe = args.work_dir / f"{name}.bin"
            cinfo = compile_bend5k(args.bend5k, src_path, obj, args.cpu, args.timeout, extra_args)
            link_ms = None
            if not cinfo["ok"]:
                b_run = {"ok": False, "error": f"compile failed: {cinfo.get('stderr', '')[:120]}"}
            else:
                try:
                    link_ms = link_obj(obj, exe, args.cpu, args.timeout)
                    b_run = measure_holdout([str(exe), *RTS_ARGS], expected_str, args.cpu, args.runs, args.holdout_timeout)
                except subprocess.CalledProcessError as e:
                    b_run = {"ok": False, "error": f"link failed: {(e.stderr or '')[:160]}"}
            obj.unlink(missing_ok=True)
            exe.unlink(missing_ok=True)

            b_s = b_run.get("s") if b_run.get("ok") else None
            c_s = c_res.get("s") if c_res.get("ok") else None
            ratio = round(b_s / c_s, 4) if (b_s is not None and c_s) else None
            hrow = {
                "name": name,
                "expected": expected_str,
                "checksum_ok": bool(b_run.get("ok") and c_res.get("ok")),
                "bend5k_s": b_s,
                "c_gcc10_o2_s": c_s,
                "ratio_vs_gcc10": ratio,
                "compile_ms": cinfo.get("compile_ms"),
                "link_ms": link_ms,
                "obj_bytes": cinfo.get("obj_bytes", 0),
                "error": None if b_run.get("ok") else b_run.get("error"),
                "details": {"c_o2": c_res, "bend5k": {"compile": cinfo, "run": b_run}},
            }
            holdout_rows.append(hrow)
            status = "OK" if hrow["checksum_ok"] else f"FAIL ({hrow['error']})"
            print(
                f"  {name:12s} | b5k={str(b_s):>8s} s | gcc10={str(c_s):>7s} s | "
                f"ratio={str(ratio):>8s}x | cmp={str(cinfo.get('compile_ms')):>7s} ms | "
                f"obj={hrow['obj_bytes']:>7d} B | {status}",
                flush=True,
            )

        all_ok = all(r["checksum_ok"] for r in proxy_rows) and all(r["checksum_ok"] for r in holdout_rows)
        total_wall_s = round(time.perf_counter() - t_all, 2)
        result = {
            "label": args.label,
            "compiler": str(args.bend5k),
            "opt_flag": args.opt_flag,
            "cpu": args.cpu,
            "runs": args.runs,
            "all_ok": all_ok,
            "proxy_geomean_vs_gcc10": gm_proxy,
            "total_wall_s": total_wall_s,
            "proxy_7": proxy_rows,
            "holdouts": holdout_rows,
        }
        if args.json_out:
            args.json_out.parent.mkdir(parents=True, exist_ok=True)
            args.json_out.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
            print(f"\nWrote {args.json_out} (all_ok={all_ok}, wall={total_wall_s:.2f}s)", flush=True)
        return 0 if all_ok else 1
    finally:
        if not args.keep_work_dir and args.work_dir.exists():
            shutil.rmtree(args.work_dir, ignore_errors=True)


if __name__ == "__main__":
    raise SystemExit(main())
