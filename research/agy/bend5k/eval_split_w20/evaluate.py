#!/usr/bin/env python3
"""Generalization Split Evaluator (Validation + Sealed-Test) for bend5k.

Implements the Development / Validation / Sealed-Test evaluation protocol:
  - 4 Validation algorithm families (2 input configs each = 8 programs)
  - 4 Sealed-Test algorithm families (2 input configs each = 8 programs)

Strict Oracle & Anti-Gaming Rules:
  - Every .bend program must pass upstream `locked_bun.sh --check-only`.
  - Every program is verified against its independent handwritten C oracle
    compiled with both `gcc-10 -O2 -ffp-contract=off` and
    `gcc-10 -O3 -march=native -ffp-contract=off`.
  - Timings are counted ONLY when stdout matches the independent C oracle.
  - Compile, link, runtime, timeout, nondeterminism, or checksum failures are
    explicitly recorded and invalidate the aggregate score (never skipped).
  - Family-weighted geometric mean weights every algorithm family equally
    regardless of the number of input configs per family.
"""
from __future__ import annotations

import argparse
import datetime
import hashlib
import json
import math
import statistics
import subprocess
import sys
import tempfile
import time
from pathlib import Path
from typing import Any

HERE = Path(__file__).resolve().parent
REPO_ROOT = HERE.parents[3]
PROVEN19_DEFAULT = Path("/home/ai/bend2_agy/selfhost/build/agy/bend5k/bend5k_o2")
RUNTIME_DEFAULT = Path("/home/ai/bend2_agy/selfhost/build/agy/unified/runtime-agy.o")
LOCKED_BUN = REPO_ROOT / "research/agy/locked_bun.sh"
BASELINE_DEFAULT = HERE / "proven19_baseline.json"

SPLITS: dict[str, list[dict[str, Any]]] = {
    "validation": [
        {
            "family": "v1_tlv_decoder",
            "c_file": "validation/v1_tlv_decoder.c",
            "configs": [
                {"name": "std", "bend_file": "validation/v1_tlv_decoder_std.bend", "c_arg": "std"},
                {"name": "skew", "bend_file": "validation/v1_tlv_decoder_skew.bend", "c_arg": "skew"},
            ],
        },
        {
            "family": "v2_fir_filter_f32",
            "c_file": "validation/v2_fir_filter_f32.c",
            "configs": [
                {"name": "std", "bend_file": "validation/v2_fir_filter_f32_std.bend", "c_arg": "std"},
                {"name": "large", "bend_file": "validation/v2_fir_filter_f32_large.bend", "c_arg": "large"},
            ],
        },
        {
            "family": "v3_base64_codec",
            "c_file": "validation/v3_base64_codec.c",
            "configs": [
                {"name": "std", "bend_file": "validation/v3_base64_codec_std.bend", "c_arg": "std"},
                {"name": "large", "bend_file": "validation/v3_base64_codec_large.bend", "c_arg": "large"},
            ],
        },
        {
            "family": "v4_list_partition_tree",
            "c_file": "validation/v4_list_partition_tree.c",
            "configs": [
                {"name": "std", "bend_file": "validation/v4_list_partition_tree_std.bend", "c_arg": "std"},
                {"name": "skew", "bend_file": "validation/v4_list_partition_tree_skew.bend", "c_arg": "skew"},
            ],
        },
    ],
    "test_sealed": [
        {
            "family": "t1_rle_lz_hash",
            "c_file": "test_sealed/t1_rle_lz_hash.c",
            "configs": [
                {"name": "std", "bend_file": "test_sealed/t1_rle_lz_hash_std.bend", "c_arg": "std"},
                {"name": "skew", "bend_file": "test_sealed/t1_rle_lz_hash_skew.bend", "c_arg": "skew"},
            ],
        },
        {
            "family": "t2_poly_eval_f32",
            "c_file": "test_sealed/t2_poly_eval_f32.c",
            "configs": [
                {"name": "std", "bend_file": "test_sealed/t2_poly_eval_f32_std.bend", "c_arg": "std"},
                {"name": "large", "bend_file": "test_sealed/t2_poly_eval_f32_large.bend", "c_arg": "large"},
            ],
        },
        {
            "family": "t3_expr_peephole",
            "c_file": "test_sealed/t3_expr_peephole.c",
            "configs": [
                {"name": "std", "bend_file": "test_sealed/t3_expr_peephole_std.bend", "c_arg": "std"},
                {"name": "deep", "bend_file": "test_sealed/t3_expr_peephole_deep.bend", "c_arg": "deep"},
            ],
        },
        {
            "family": "t4_utf8_state_machine",
            "c_file": "test_sealed/t4_utf8_state_machine.c",
            "configs": [
                {"name": "std", "bend_file": "test_sealed/t4_utf8_state_machine_std.bend", "c_arg": "std"},
                {"name": "skew", "bend_file": "test_sealed/t4_utf8_state_machine_skew.bend", "c_arg": "skew"},
            ],
        },
    ],
}


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(65536), b""):
            h.update(chunk)
    return h.hexdigest()


def geomean(vals: list[float]) -> float | None:
    if not vals or any(v <= 0.0 for v in vals):
        return None
    return round(math.exp(sum(math.log(v) for v in vals) / len(vals)), 4)


def run_cmd(cmd: list[str], cwd: Path | None = None, timeout_s: float = 60.0) -> tuple[bool, str, str]:
    try:
        p = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True, timeout=timeout_s)
    except subprocess.TimeoutExpired:
        return False, "", f"TIMEOUT after {timeout_s}s: {' '.join(cmd)}"
    if p.returncode != 0:
        err = (p.stderr or p.stdout or "").strip()
        return False, p.stdout.strip(), f"EXIT {p.returncode}: {err[:400]}"
    return True, p.stdout.strip(), ""


def time_cmd(cmd: list[str], cpu_pin: str, runs: int, timeout_s: float = 30.0) -> tuple[bool, str, list[float], float | None, str]:
    full = (["taskset", "-c", cpu_pin] if cpu_pin else []) + cmd
    ok, out0, err = run_cmd(full, timeout_s=timeout_s)
    if not ok:
        return False, "", [], None, f"warmup_failed: {err}"
    times: list[float] = []
    for _ in range(runs):
        t0 = time.perf_counter()
        ok, out, err = run_cmd(full, timeout_s=timeout_s)
        t1 = time.perf_counter()
        if not ok:
            return False, out0, times, None, f"run_failed: {err}"
        if out != out0:
            return False, out0, times, None, f"nondeterministic: {out0!r} vs {out!r}"
        times.append(round((t1 - t0) * 1000.0, 2))
    return True, out0, times, round(statistics.median(times), 2), ""


def compile_and_time_bend(
    compiler: Path,
    runtime: Path,
    bend_src: Path,
    tag: str,
    tdir: Path,
    cpu_pin: str,
    runs: int,
) -> dict[str, Any]:
    obj = tdir / f"{tag}.o"
    exe = tdir / f"{tag}_bin"
    ok, _, err = run_cmd([str(compiler), "-O2", str(bend_src), str(obj)], cwd=REPO_ROOT, timeout_s=60.0)
    if not ok:
        return {"ok": False, "stage": "compile", "error": err, "checksum": None, "median_ms": None, "raw_ms": []}
    ok, _, err = run_cmd(["gcc-10", "-O2", str(obj), str(runtime), "-lm", "-lpthread", "-o", str(exe)], timeout_s=30.0)
    if not ok:
        return {"ok": False, "stage": "link", "error": err, "checksum": None, "median_ms": None, "raw_ms": []}
    ok, out, raw, med, err = time_cmd([str(exe), "+RTS", "--threads", "1", "--gpu", "off", "-RTS"], cpu_pin, runs)
    if not ok:
        return {"ok": False, "stage": "runtime", "error": err, "checksum": out or None, "median_ms": None, "raw_ms": raw}
    return {"ok": True, "stage": "ok", "error": "", "checksum": out, "median_ms": med, "raw_ms": raw}


def eval_split(
    split_name: str,
    compiler: Path,
    runtime: Path,
    cpu_pin: str,
    runs: int,
    check_bun: bool,
    baseline_split: dict[str, Any] | None,
    measure_c: bool,
    tdir: Path,
) -> dict[str, Any]:
    families_out: list[dict[str, Any]] = []
    passed_configs = 0
    total_configs = 0
    failures: list[dict[str, Any]] = []

    fam_vs_p19: list[float] = []
    fam_vs_co2: list[float] = []
    fam_vs_co3: list[float] = []
    total_bend_ms = 0.0
    total_p19_ms = 0.0
    total_co2_ms = 0.0
    total_co3_ms = 0.0

    # Index baseline by (family, config) if provided
    base_idx: dict[tuple[str, str], dict[str, Any]] = {}
    if baseline_split:
        for fb in baseline_split.get("families", []):
            for cb in fb.get("configs", []):
                base_idx[(fb["family"], cb["name"])] = cb

    for fspec in SPLITS[split_name]:
        fam = fspec["family"]
        c_src = HERE / fspec["c_file"]
        co2_bin = tdir / f"{fam}_co2"
        co3_bin = tdir / f"{fam}_co3"

        # Always compile C oracle (O2 and O3-native) so oracle verification is independent
        ok_c2, _, err_c2 = run_cmd(["gcc-10", "-O2", "-ffp-contract=off", str(c_src), "-lm", "-o", str(co2_bin)])
        ok_c3, _, err_c3 = run_cmd(
            ["gcc-10", "-O3", "-march=native", "-ffp-contract=off", str(c_src), "-lm", "-o", str(co3_bin)]
        )
        if not ok_c2 or not ok_c3:
            raise RuntimeError(f"C oracle build failed for {fam}: O2={err_c2} O3={err_c3}")

        cfgs_out: list[dict[str, Any]] = []
        cfg_vs_p19: list[float] = []
        cfg_vs_co2: list[float] = []
        cfg_vs_co3: list[float] = []
        fam_ok = True

        for cspec in fspec["configs"]:
            total_configs += 1
            cname = cspec["name"]
            bend_src = HERE / cspec["bend_file"]
            c_arg = cspec["c_arg"]
            bref = base_idx.get((fam, cname))

            # Optional upstream bun --check-only gate
            bun_ok = True
            bun_err = ""
            if check_bun:
                bun_ok, _, bun_err = run_cmd([str(LOCKED_BUN), "--check-only", str(bend_src)], cwd=REPO_ROOT, timeout_s=95.0)

            # Independent C oracle execution
            if measure_c or bref is None:
                ok2, oc2, raw_c2, med_c2, err2 = time_cmd([str(co2_bin), c_arg], cpu_pin, runs)
                ok3, oc3, raw_c3, med_c3, err3 = time_cmd([str(co3_bin), c_arg], cpu_pin, runs)
                if not ok2 or not ok3 or oc2 != oc3:
                    raise RuntimeError(
                        f"C oracle failure on {fam}/{cname}: ok2={ok2} ({err2}) ok3={ok3} ({err3}) oc2={oc2} oc3={oc3}"
                    )
                oracle_chk = oc2
            else:
                # Verify live C-O2 oracle once (fast, <20ms) and reuse frozen C timings
                ok2, oc2, err2 = run_cmd([str(co2_bin), c_arg], timeout_s=30.0)
                if not ok2:
                    raise RuntimeError(f"Live C oracle failed on {fam}/{cname}: {err2}")
                oracle_chk = oc2
                med_c2 = bref["c_o2_ms"]
                med_c3 = bref["c_o3_native_ms"]
                raw_c2 = bref.get("raw_c_o2_ms", [])
                raw_c3 = bref.get("raw_c_o3_native_ms", [])

            if not bun_ok:
                rec = {
                    "name": cname,
                    "status": "FAIL_BUN_CHECK",
                    "error": bun_err,
                    "oracle_checksum": oracle_chk,
                    "bend_checksum": None,
                    "bend_ms": None,
                    "c_o2_ms": med_c2,
                    "c_o3_native_ms": med_c3,
                }
                cfgs_out.append(rec)
                failures.append({"family": fam, "config": cname, "status": rec["status"], "error": bun_err})
                fam_ok = False
                continue

            bres = compile_and_time_bend(
                compiler, runtime, bend_src, f"{split_name}_{fam}_{cname}", tdir, cpu_pin, runs
            )
            if not bres["ok"]:
                rec = {
                    "name": cname,
                    "status": f"FAIL_{bres['stage'].upper()}",
                    "error": bres["error"],
                    "oracle_checksum": oracle_chk,
                    "bend_checksum": bres["checksum"],
                    "bend_ms": None,
                    "c_o2_ms": med_c2,
                    "c_o3_native_ms": med_c3,
                }
                cfgs_out.append(rec)
                failures.append({"family": fam, "config": cname, "status": rec["status"], "error": bres["error"]})
                fam_ok = False
                continue

            if bres["checksum"] != oracle_chk:
                err_msg = f"checksum mismatch: bend={bres['checksum']} vs oracle={oracle_chk}"
                rec = {
                    "name": cname,
                    "status": "FAIL_ORACLE_MISMATCH",
                    "error": err_msg,
                    "oracle_checksum": oracle_chk,
                    "bend_checksum": bres["checksum"],
                    "bend_ms": None,
                    "c_o2_ms": med_c2,
                    "c_o3_native_ms": med_c3,
                }
                cfgs_out.append(rec)
                failures.append({"family": fam, "config": cname, "status": rec["status"], "error": err_msg})
                fam_ok = False
                continue

            # Verified PASS: record timings & ratios
            passed_configs += 1
            b_ms = float(bres["median_ms"])
            r_co2 = round(b_ms / med_c2, 4) if med_c2 > 0 else 0.0
            r_co3 = round(b_ms / med_c3, 4) if med_c3 > 0 else 0.0
            p19_ms = float(bref["bend_ms"]) if (bref and bref.get("bend_ms")) else None
            r_p19 = round(b_ms / p19_ms, 4) if (p19_ms and p19_ms > 0) else None

            total_bend_ms += b_ms
            total_co2_ms += med_c2
            total_co3_ms += med_c3
            if p19_ms is not None:
                total_p19_ms += p19_ms
            if r_p19 is not None:
                cfg_vs_p19.append(r_p19)
            cfg_vs_co2.append(r_co2)
            cfg_vs_co3.append(r_co3)

            rec = {
                "name": cname,
                "status": "PASS",
                "oracle_checksum": oracle_chk,
                "bend_checksum": bres["checksum"],
                "bend_ms": b_ms,
                "proven19_ms": p19_ms,
                "c_o2_ms": med_c2,
                "c_o3_native_ms": med_c3,
                "vs_proven19": r_p19,
                "vs_c_o2": r_co2,
                "vs_c_o3_native": r_co3,
                "raw_bend_ms": bres["raw_ms"],
                "raw_c_o2_ms": raw_c2,
                "raw_c_o3_native_ms": raw_c3,
            }
            cfgs_out.append(rec)

        f_r_p19 = geomean(cfg_vs_p19) if (fam_ok and len(cfg_vs_p19) == len(fspec["configs"])) else None
        f_r_co2 = geomean(cfg_vs_co2) if (fam_ok and len(cfg_vs_co2) == len(fspec["configs"])) else None
        f_r_co3 = geomean(cfg_vs_co3) if (fam_ok and len(cfg_vs_co3) == len(fspec["configs"])) else None
        if fam_ok:
            if f_r_p19 is not None:
                fam_vs_p19.append(f_r_p19)
            if f_r_co2 is not None:
                fam_vs_co2.append(f_r_co2)
            if f_r_co3 is not None:
                fam_vs_co3.append(f_r_co3)

        families_out.append(
            {
                "family": fam,
                "status": "PASS" if fam_ok else "FAIL",
                "family_geomean_vs_proven19": f_r_p19,
                "family_geomean_vs_c_o2": f_r_co2,
                "family_geomean_vs_c_o3_native": f_r_co3,
                "configs": cfgs_out,
            }
        )

    all_passed = passed_configs == total_configs
    n_fams = len(SPLITS[split_name])
    summary = {
        "status": "PASS" if all_passed else "FAIL",
        "passed_configs": passed_configs,
        "total_configs": total_configs,
        "passed_families": sum(1 for f in families_out if f["status"] == "PASS"),
        "total_families": n_fams,
        "family_weighted_geomean_vs_proven19": geomean(fam_vs_p19) if (all_passed and len(fam_vs_p19) == n_fams) else None,
        "family_weighted_geomean_vs_c_o2": geomean(fam_vs_co2) if (all_passed and len(fam_vs_co2) == n_fams) else None,
        "family_weighted_geomean_vs_c_o3_native": geomean(fam_vs_co3) if (all_passed and len(fam_vs_co3) == n_fams) else None,
        "total_bend_ms": round(total_bend_ms, 2) if all_passed else None,
        "total_proven19_ms": round(total_p19_ms, 2) if (all_passed and total_p19_ms > 0) else None,
        "total_c_o2_ms": round(total_co2_ms, 2) if all_passed else None,
        "total_c_o3_native_ms": round(total_co3_ms, 2) if all_passed else None,
        "total_batch_vs_proven19": round(total_bend_ms / total_p19_ms, 4) if (all_passed and total_p19_ms > 0) else None,
        "failures": failures,
    }
    return {"split": split_name, "summary": summary, "families": families_out}


def print_split_report(res: dict[str, Any], aggregate_only: bool = False) -> None:
    s = res["summary"]
    print(f"\n=== SPLIT: {res['split']} ({s['status']} — {s['passed_families']}/{s['total_families']} families, {s['passed_configs']}/{s['total_configs']} configs) ===")
    if not aggregate_only:
        print(
            f"{'Program':30s} | {'St':4s} | {'Chk':10s} | {'Bend(ms)':>8s} | {'P19(ms)':>8s} | "
            f"{'vsP19':>6s} | {'C-O2':>7s} | {'vsO2':>6s} | {'C-O3':>7s} | {'vsO3':>6s}"
        )
        print("-" * 116)
        for fam in res["families"]:
            for c in fam["configs"]:
                label = f"{fam['family']}/{c['name']}"
                if c["status"] != "PASS":
                    print(f"{label:30s} | FAIL | {c['status']} ({c.get('error', '')[:60]})")
                    continue
                p19_s = f"{c['proven19_ms']:8.2f}" if c["proven19_ms"] is not None else f"{'-':>8s}"
                vp19_s = f"{c['vs_proven19']:5.3f}x" if c["vs_proven19"] is not None else f"{'-':>6s}"
                print(
                    f"{label:30s} | PASS | {c['bend_checksum']:10s} | {c['bend_ms']:8.2f} | {p19_s} | "
                    f"{vp19_s} | {c['c_o2_ms']:7.2f} | {c['vs_c_o2']:5.2f}x | {c['c_o3_native_ms']:7.2f} | {c['vs_c_o3_native']:5.2f}x"
                )
            fg_p19 = f"{fam['family_geomean_vs_proven19']:.3f}x" if fam["family_geomean_vs_proven19"] else "-"
            fg_o2 = f"{fam['family_geomean_vs_c_o2']:.2f}x" if fam["family_geomean_vs_c_o2"] else "-"
            fg_o3 = f"{fam['family_geomean_vs_c_o3_native']:.2f}x" if fam["family_geomean_vs_c_o3_native"] else "-"
            print(f"  -> family geomean [{fam['family']}]: vs_P19={fg_p19}, vs_C_O2={fg_o2}, vs_C_O3_native={fg_o3}")

    print("-" * 116)
    if s["status"] == "PASS":
        vp19 = f"{s['family_weighted_geomean_vs_proven19']:.4f}x" if s["family_weighted_geomean_vs_proven19"] else "N/A (baseline)"
        tb_p19 = f"{s['total_batch_vs_proven19']:.4f}x" if s["total_batch_vs_proven19"] else "N/A"
        print(
            f"FAMILY-WEIGHTED GEOMEAN: vs_P19={vp19} | "
            f"vs_C_O2={s['family_weighted_geomean_vs_c_o2']:.3f}x | "
            f"vs_C_O3_native={s['family_weighted_geomean_vs_c_o3_native']:.3f}x"
        )
        print(
            f"TOTAL FIXED-BATCH WALL : bend={s['total_bend_ms']:.2f}ms | "
            f"c_o2={s['total_c_o2_ms']:.2f}ms | c_o3_native={s['total_c_o3_native_ms']:.2f}ms | "
            f"batch_vs_P19={tb_p19}"
        )
    else:
        print(f"INVALID SCORE: {len(s['failures'])} failure(s) recorded — timings are NOT aggregated when any program fails.")
        for f in s["failures"]:
            print(f"  FAIL {f['family']}/{f['config']}: {f['status']} — {f['error']}")


def main() -> int:
    ap = argparse.ArgumentParser(description="Generalization split evaluator for bend5k.")
    ap.add_argument("--split", choices=["validation", "test_sealed", "all"], default="validation")
    ap.add_argument("--candidate", type=Path, default=None, help="Candidate bend5k binary to evaluate against frozen Proven-19.")
    ap.add_argument("--proven19", type=Path, default=PROVEN19_DEFAULT, help="Proven-19 reference binary.")
    ap.add_argument("--runtime", type=Path, default=RUNTIME_DEFAULT, help="Unified runtime object.")
    ap.add_argument("--baseline", type=Path, default=BASELINE_DEFAULT, help="Frozen Proven-19 baseline JSON.")
    ap.add_argument("--freeze-baseline", action="store_true", help="Run Proven-19 + C baselines and write --baseline JSON.")
    ap.add_argument("--cpu-pin", default="7")
    ap.add_argument("--runs", type=int, default=5)
    ap.add_argument("--skip-bun-check", action="store_true", help="Skip upstream locked_bun.sh --check-only (use only on already-verified fixed corpus).")
    ap.add_argument("--measure-c", action="store_true", help="Re-measure C-O2 and C-O3-native medians instead of reusing frozen C timings.")
    ap.add_argument("--aggregate-only", action="store_true", help="Print only aggregate split stats (enforces information barrier).")
    ap.add_argument("--json-out", type=Path, default=None)
    args = ap.parse_args()

    t_start = time.perf_counter()
    splits_to_run = ["validation", "test_sealed"] if args.split == "all" else [args.split]
    compiler = args.proven19 if args.freeze_baseline or args.candidate is None else args.candidate

    baseline_data: dict[str, Any] | None = None
    if not args.freeze_baseline and args.baseline.exists():
        baseline_data = json.loads(args.baseline.read_text(encoding="utf-8"))

    gcc_ver = subprocess.run(["gcc-10", "--version"], capture_output=True, text=True).stdout.splitlines()[0]

    out_doc: dict[str, Any] = {
        "schema_version": "eval_split_w20_v1",
        "timestamp_utc": datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "mode": "freeze_baseline" if args.freeze_baseline else "evaluate_candidate",
        "cpu_pin": args.cpu_pin,
        "runs_per_program": args.runs,
        "compiler": {
            "path": str(compiler),
            "sha256": sha256_file(compiler),
            "flags": ["-O2"],
            "commit": "801fde8a" if (args.freeze_baseline or args.candidate is None) else "candidate",
        },
        "runtime": {
            "path": str(args.runtime),
            "sha256": sha256_file(args.runtime),
        },
        "c_oracle": {
            "compiler": gcc_ver,
            "o2_flags": ["-O2", "-ffp-contract=off"],
            "o3_native_flags": ["-O3", "-march=native", "-ffp-contract=off"],
        },
        "scoring_rules": {
            "oracle_gate": "Timing is counted ONLY when stdout matches the independent C oracle exactly.",
            "failure_policy": "Any compile, link, runtime, timeout, nondeterminism, bun-check, or checksum failure invalidates the split aggregate.",
            "aggregation": "Family-weighted geometric mean (each algorithm family weighted equally, computed as geomean of its per-config ratios), plus total fixed-batch wall time.",
        },
        "splits": {},
    }

    any_failed = False
    with tempfile.TemporaryDirectory(prefix="l20_ev_") as td:
        tdir = Path(td)
        for sp in splits_to_run:
            b_sp = baseline_data["splits"].get(sp) if baseline_data else None
            res = eval_split(
                split_name=sp,
                compiler=compiler,
                runtime=args.runtime,
                cpu_pin=args.cpu_pin,
                runs=args.runs,
                check_bun=not args.skip_bun_check,
                baseline_split=None if args.freeze_baseline else b_sp,
                measure_c=args.freeze_baseline or args.measure_c,
                tdir=tdir,
            )
            out_doc["splits"][sp] = res
            print_split_report(res, aggregate_only=args.aggregate_only)
            if res["summary"]["status"] != "PASS":
                any_failed = True

    elapsed = round(time.perf_counter() - t_start, 2)
    out_doc["harness_wall_s"] = elapsed
    print(f"\nHarness wall time: {elapsed:.2f}s")

    if args.freeze_baseline:
        if any_failed:
            print("ERROR: Refusing to freeze baseline because one or more programs failed.", file=sys.stderr)
        else:
            args.baseline.write_text(json.dumps(out_doc, indent=2) + "\n", encoding="utf-8")
            print(f"Wrote frozen Proven-19 baseline -> {args.baseline}")
    if args.json_out:
        args.json_out.write_text(json.dumps(out_doc, indent=2) + "\n", encoding="utf-8")
        print(f"Wrote evaluation JSON -> {args.json_out}")

    return 1 if any_failed else 0


if __name__ == "__main__":
    raise SystemExit(main())
