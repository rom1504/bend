#!/usr/bin/env python3
"""Wave 5C Track W5C-V1: Untouched Upstream Defaults (3) + native45 (10) on wave5b_unified/api.mjs."""
from __future__ import annotations
import argparse
import hashlib
import json
import math
import statistics
import subprocess
import tempfile
import time
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
LOCKED_NODE = ROOT / "research/agy/locked_node.sh"
CPU2_LOCK = "/tmp/agy_cpu2_bench.lock"
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"
BATCH_EMIT = ROOT / "research/agy/wave3_fuzz/batch_emit.mjs"

W5B_API = ROOT / "selfhost/build/agy/wave5b_unified/api.mjs"
AGY_RT = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
W2_FULL44 = ROOT / "selfhost/build/agy/wave2_unified/full44"

UPSTREAM_DIR = ROOT / "research/agy/wave4_bench/inputs/upstream"
UPSTREAM_SUITE = json.loads((UPSTREAM_DIR / "suite.json").read_text())
UPSTREAM_WORKLOADS = ["histogram", "gameoflife", "nbody"]
UPSTREAM_C_BASELINES = {
    "histogram": 7.5097,
    "gameoflife": 17.4611,
    "nbody": 10.7390,
}
UPSTREAM_W4C_BASELINES = {
    "histogram": 20.25,
    "gameoflife": 38.41,
    "nbody": 14.20,
}
UPSTREAM_BEND_C_BASELINES = {
    "histogram": 11.4522,
    "gameoflife": 24.4644,
    "nbody": 10.4266,
}

CATALOG = json.loads((ROOT / "selfhost/tools/bench/catalogs/native45/catalog.json").read_text())
CASES = {c["id"]: c for c in CATALOG["cases"]}
W2_SUMMARY = {r["id"]: r for r in json.loads((W2_FULL44 / "summary.json").read_text())["rows"]}

NATIVE45_IDS = [
    "raytrace",
    "mandelbrot",
    "lexer",
    "coverage-bst-64",
    "coverage-map-churn-32",
    "coverage-record-aggregation-256",
    "editdist",
    "symreg",
    "coverage-list-pipeline-512",
    "tree-bitonic",
]


def sha256_file(p: Path) -> str:
    return hashlib.sha256(p.read_bytes()).hexdigest()


def run_n45_once(exe: Path, reps: int, warmups: int, args: list, expected_stdout: str) -> int:
    r = subprocess.run(
        ["flock", CPU2_LOCK, "taskset", "-c", "2", str(exe), str(reps), str(warmups), *[str(a) for a in args]],
        capture_output=True, text=True, check=True,
    )
    lines = r.stdout.splitlines()
    exp_lines = expected_stdout.splitlines()
    assert lines[:len(exp_lines)] == exp_lines, (exe.name, lines[:len(exp_lines)], exp_lines)
    assert int(lines[-3]) == warmups and int(lines[-2]) == reps, (exe.name, lines[-3:])
    return int(lines[-1])


def calibrate_n45(exe: Path, args: list, expected_stdout: str, target_ms: int = 140) -> int:
    reps = 4
    while True:
        ms = run_n45_once(exe, reps, 2, args, expected_stdout)
        if ms >= target_ms or reps >= 500000:
            return reps
        scale = max(2, int(math.ceil(target_ms / max(ms, 1))))
        reps = min(500000, reps * min(scale, 16))


def run_upstream_once(exe: Path, expected_checksum: int) -> float:
    t0 = time.perf_counter()
    r = subprocess.run(
        ["flock", CPU2_LOCK, "taskset", "-c", "2", str(exe), "+RTS", "--threads", "1", "--gpu", "off", "-RTS"],
        capture_output=True, text=True, check=True,
    )
    elapsed = time.perf_counter() - t0
    out_val = int(r.stdout.strip().splitlines()[-1])
    assert out_val == expected_checksum, f"{exe.name}: got {out_val}, expected {expected_checksum}"
    return elapsed


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--upstream-runs", type=int, default=3)
    ap.add_argument("--out-json", type=Path, default=ROOT / "experiments/agy/receipts/wave5c-upstream-native45.json")
    args = ap.parse_args()

    with tempfile.TemporaryDirectory(prefix="w5c_v1_") as td:
        tmp = Path(td)

        # 1. Verify upstream source SHA256s match suite.json (100% untouched)
        jobs = []
        up_shas = {}
        for wl in UPSTREAM_WORKLOADS:
            src = UPSTREAM_DIR / wl / "main.bend"
            sha = sha256_file(src)
            exp_sha = UPSTREAM_SUITE[wl]["sourceSha256"]["bend"]
            assert sha == exp_sha, f"Upstream {wl} modified! got {sha}, expected {exp_sha}"
            up_shas[wl] = sha
            jobs.append({"id": f"up:{wl}", "src": str(src), "out": str(tmp / f"up_{wl}.o")})

        for cid in NATIVE45_IDS:
            c = CASES[cid]
            src = ROOT / "selfhost/tools/bench" / c["source"]["file"]
            jobs.append({"id": f"n45:{cid}", "src": str(src), "out": str(tmp / f"n45_{cid}.o")})

        print(f"Batch-emitting {len(jobs)} programs (3 upstream + 10 native45) via wave5b_unified/api.mjs...", flush=True)
        t_emit = time.perf_counter()
        manifest = tmp / "manifest.json"
        manifest.write_text(json.dumps(jobs))
        r_emit = subprocess.run(
            ["taskset", "-c", "0,1,4,5", "bash", str(LOCKED_NODE), "--stack-size=8192", str(BATCH_EMIT), str(W5B_API), str(manifest)],
            capture_output=True, text=True, check=True,
        )
        emitted = {item["id"]: item for item in json.loads(r_emit.stdout)}
        emit_sec = round(time.perf_counter() - t_emit, 2)
        for j in jobs:
            assert emitted[j["id"]]["ok"], f"Emit failed for {j['id']}: {emitted[j['id']]}"
        print(f"Batch emit 13/13 OK in {emit_sec:.2f}s.\n", flush=True)

        # 2. native45 10-benchmark non-regression gate
        print("=== 1. native45 10-Benchmark Non-Regression Gate (wave5b_unified vs wave2_unified, CPU 2, 3 runs) ===", flush=True)
        n45_rows = []
        for cid in NATIVE45_IDS:
            c = CASES[cid]
            exp = c["point"]["expectedStdout"]
            rargs = c["point"]["runtimeArgs"]
            w2_obj = W2_FULL44 / f"{cid}.cand.o"
            w5b_obj = tmp / f"n45_{cid}.o"
            w2_exe = tmp / f"n45_{cid}.w2.exe"
            w5b_exe = tmp / f"n45_{cid}.w5b.exe"
            subprocess.run([CC, "-no-pie", str(w2_obj), str(AGY_RT), "-pthread", "-lm", "-o", str(w2_exe)], check=True)
            subprocess.run([CC, "-no-pie", str(w5b_obj), str(AGY_RT), "-pthread", "-lm", "-o", str(w5b_exe)], check=True)

            reps = calibrate_n45(w5b_exe, rargs, exp, target_ms=140)
            w2_times, w5b_times = [], []
            for rd in range(3):
                if rd % 2 == 0:
                    w2_times.append(run_n45_once(w2_exe, reps, 2, rargs, exp))
                    w5b_times.append(run_n45_once(w5b_exe, reps, 2, rargs, exp))
                else:
                    w5b_times.append(run_n45_once(w5b_exe, reps, 2, rargs, exp))
                    w2_times.append(run_n45_once(w2_exe, reps, 2, rargs, exp))
            w2_med = max(statistics.median(w2_times), 0.5)
            w5b_med = max(statistics.median(w5b_times), 0.5)
            ratio = w5b_med / w2_med
            speedup = w2_med / w5b_med
            w2_over_c = W2_SUMMARY[cid]["est_over_c"]
            w5b_over_c = w2_over_c * ratio
            row = {
                "id": cid,
                "reps": reps,
                "w2_ms": w2_med,
                "w5b_ms": w5b_med,
                "w2_runs": w2_times,
                "w5b_runs": w5b_times,
                "w5b_over_w2": round(ratio, 4),
                "speedup": round(speedup, 4),
                "w2_est_over_c": round(w2_over_c, 4),
                "w5b_est_over_c": round(w5b_over_c, 4),
                "w2_obj_bytes": w2_obj.stat().st_size,
                "w5b_obj_bytes": w5b_obj.stat().st_size,
                "exact_stdout": True,
            }
            n45_rows.append(row)
            print(
                f"  {cid:32s} w2={w2_med:6.1f}ms w5b={w5b_med:6.1f}ms  w5b/w2={ratio:.3f}x ({speedup:.2f}x)  overC: {w2_over_c:.3f}x -> {w5b_over_c:.3f}x  PASS",
                flush=True,
            )
            w5b_obj.unlink(missing_ok=True)
            w2_exe.unlink(missing_ok=True)
            w5b_exe.unlink(missing_ok=True)

        gm_ratio = math.exp(sum(math.log(r["w5b_over_w2"]) for r in n45_rows) / len(n45_rows))
        gm_over_c_w2 = math.exp(sum(math.log(r["w2_est_over_c"]) for r in n45_rows) / len(n45_rows))
        gm_over_c_w5b = math.exp(sum(math.log(r["w5b_est_over_c"]) for r in n45_rows) / len(n45_rows))
        print(
            f"  GEOMEAN (10 cases): w5b/w2 = {gm_ratio:.4f}x ({1/gm_ratio:.3f}x speedup) | overC: {gm_over_c_w2:.3f}x -> {gm_over_c_w5b:.3f}x | gate<=1.02x: {'PASS' if gm_ratio <= 1.02 else 'FAIL'}\n",
            flush=True,
        )

        # 3. Full Untouched Upstream Defaults (0e2f38f, CPU 2)
        print(f"=== 2. Full Untouched Upstream Defaults (wave5b_unified, CPU 2, {args.upstream_runs} runs) ===", flush=True)
        up_rows = []
        for wl in UPSTREAM_WORKLOADS:
            obj = tmp / f"up_{wl}.o"
            exe = tmp / f"up_{wl}.exe"
            obj_bytes = obj.stat().st_size
            subprocess.run([CC, "-no-pie", str(obj), str(AGY_RT), "-pthread", "-lm", "-o", str(exe)], check=True)
            exp_chk = UPSTREAM_SUITE[wl]["expected"]["upstream"]
            runs = []
            for r_idx in range(args.upstream_runs):
                t_sec = run_upstream_once(exe, exp_chk)
                runs.append(round(t_sec, 4))
                print(f"  {wl:12s} run {r_idx+1}/{args.upstream_runs}: {t_sec:.4f}s (checksum={exp_chk} OK)", flush=True)
            med = round(statistics.median(runs), 4)
            c_base = UPSTREAM_C_BASELINES[wl]
            w4c_base = UPSTREAM_W4C_BASELINES[wl]
            up_bc_base = UPSTREAM_BEND_C_BASELINES[wl]
            over_c = med / c_base
            vs_w4c = w4c_base / med
            over_up_bc = med / up_bc_base
            up_rows.append({
                "workload": wl,
                "source_sha256": up_shas[wl],
                "expected_checksum": exp_chk,
                "checksum_ok": True,
                "obj_bytes": obj_bytes,
                "runs_sec": runs,
                "median_sec": med,
                "c16_sec": c_base,
                "upstream_bend_c_sec": up_bc_base,
                "w4c_sec": w4c_base,
                "over_c16": round(over_c, 4),
                "over_upstream_bend_c": round(over_up_bc, 4),
                "speedup_vs_w4c": round(vs_w4c, 4),
            })
            print(
                f"  => {wl:12s} median={med:.4f}s | vs C16({c_base:.4f}s)={over_c:.3f}x | vs W4C({w4c_base:.2f}s)={vs_w4c:.3f}x | vs UpBend->C({up_bc_base:.4f}s)={over_up_bc:.3f}x\n",
                flush=True,
            )
            obj.unlink(missing_ok=True)
            exe.unlink(missing_ok=True)

        total_w5b = round(sum(r["median_sec"] for r in up_rows), 4)
        total_w4c = round(sum(r["w4c_sec"] for r in up_rows), 4)
        total_c16 = round(sum(r["c16_sec"] for r in up_rows), 4)
        gm_over_c16 = math.exp(sum(math.log(r["over_c16"]) for r in up_rows) / len(up_rows))
        gm_w4c_over_c16 = math.exp(sum(math.log(r["w4c_sec"] / r["c16_sec"]) for r in up_rows) / len(up_rows))
        gm_over_up_bc = math.exp(sum(math.log(r["over_upstream_bend_c"]) for r in up_rows) / len(up_rows))
        print(
            f"  UPSTREAM TOTAL: w5b={total_w5b:.2f}s vs w4c={total_w4c:.2f}s ({total_w4c/total_w5b:.3f}x) vs C16={total_c16:.2f}s",
            flush=True,
        )
        print(
            f"  UPSTREAM GEOMEAN over C16: w5b={gm_over_c16:.3f}x (W4C was {gm_w4c_over_c16:.3f}x) | over Upstream Bend->C: {gm_over_up_bc:.3f}x",
            flush=True,
        )

    receipt = {
        "api": str(W5B_API),
        "runtime": str(AGY_RT),
        "emit_sec": emit_sec,
        "native45_10": {
            "rows": n45_rows,
            "geomean_w5b_over_w2": round(gm_ratio, 4),
            "geomean_speedup": round(1.0 / gm_ratio, 4),
            "geomean_w2_est_over_c": round(gm_over_c_w2, 4),
            "geomean_w5b_est_over_c": round(gm_over_c_w5b, 4),
            "gate_le_1_02": gm_ratio <= 1.02,
        },
        "upstream_defaults": {
            "runs_per_workload": args.upstream_runs,
            "rows": up_rows,
            "total_w5b_sec": total_w5b,
            "total_w4c_sec": total_w4c,
            "total_c16_sec": total_c16,
            "total_speedup_vs_w4c": round(total_w4c / total_w5b, 4),
            "geomean_over_c16": round(gm_over_c16, 4),
            "geomean_w4c_over_c16": round(gm_w4c_over_c16, 4),
            "geomean_over_upstream_bend_c": round(gm_over_up_bc, 4),
        },
    }
    args.out_json.parent.mkdir(parents=True, exist_ok=True)
    args.out_json.write_text(json.dumps(receipt, indent=2) + "\n")
    print(f"\nWrote receipt: {args.out_json}", flush=True)


if __name__ == "__main__":
    main()
