#!/usr/bin/env python3
"""Link already-emitted probe01 objects against baseline vs candidate runtime,
verify exact stdout on all 6 cases, and run alternating CPU-1 timings."""
import argparse
import json
import math
import statistics
import subprocess
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"
PROBE_DIR = ROOT / "selfhost/build/agy/probe01"
CATALOG = json.loads((ROOT / "selfhost/tools/bench/catalogs/native45/catalog.json").read_text())
CASES = {c["id"]: c for c in CATALOG["cases"]}

DEFAULT_CASES = [
    "coverage-bst-64",
    "coverage-map-churn-128",
    "test-evening-program",
    "test-rle-roundtrip",
    "coverage-record-aggregation-256",
    "tree-bitonic",
]

def link_exe(obj_path, rt_path, exe_path):
    p = subprocess.run([CC, "-no-pie", str(obj_path), str(rt_path), "-pthread", "-lm", "-o", str(exe_path)],
                       capture_output=True, text=True)
    if p.returncode != 0:
        raise RuntimeError(f"Link failed: {p.stderr}")

def run_once(exe, reps, warmups, args, expected_stdout, cpu):
    p = subprocess.run(["taskset", "-c", str(cpu), str(exe), str(reps), str(warmups), *[str(a) for a in args]],
                       capture_output=True, text=True, timeout=60)
    if p.returncode != 0:
        raise RuntimeError(f"Run failed ({p.returncode}) {exe}: {p.stderr}")
    lines = p.stdout.splitlines()
    exp_lines = expected_stdout.splitlines()
    assert lines[:len(exp_lines)] == exp_lines, (exe, lines[:len(exp_lines)], exp_lines)
    assert int(lines[-3]) == warmups and int(lines[-2]) == reps, (exe, lines[-3:])
    return int(lines[-1])

def calibrate(exe, args, expected_stdout, cpu, target_ms=160):
    reps = 4
    while True:
        ms = run_once(exe, reps, 2, args, expected_stdout, cpu)
        if ms >= target_ms or reps >= 500000:
            return reps
        scale = max(2, int(math.ceil(target_ms / max(ms, 1))))
        reps = min(500000, reps * min(scale, 16))

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--base-rt", type=Path, default=ROOT / "selfhost/build/agy/bootstrap/runtime-live-scan.o")
    ap.add_argument("--cand-rt", type=Path, default=ROOT / "selfhost/build/agy/rt/runtime-opt.o")
    ap.add_argument("--out", type=Path, default=ROOT / "selfhost/build/agy/rt/bench")
    ap.add_argument("--cpu", type=int, default=1)
    ap.add_argument("--rounds", type=int, default=6)
    ap.add_argument("--target-ms", type=int, default=160)
    ap.add_argument("--cases", default=",".join(DEFAULT_CASES))
    a = ap.parse_args()
    a.out.mkdir(parents=True, exist_ok=True)
    ids = [x.strip() for x in a.cases.split(",") if x.strip()]

    results = []
    for cid in ids:
        c = CASES[cid]
        obj = PROBE_DIR / f"{cid}.o"
        assert obj.exists(), f"Missing object: {obj}"
        exp = c["point"]["expectedStdout"]
        args = c["point"]["runtimeArgs"]
        b_exe = a.out / f"{cid}.base"
        c_exe = a.out / f"{cid}.cand"
        link_exe(obj, a.base_rt, b_exe)
        link_exe(obj, a.cand_rt, c_exe)
        reps = calibrate(c_exe, args, exp, a.cpu, a.target_ms)
        b_times, c_times = [], []
        for r in range(a.rounds):
            if r % 2 == 0:
                b_times.append(run_once(b_exe, reps, 2, args, exp, a.cpu))
                c_times.append(run_once(c_exe, reps, 2, args, exp, a.cpu))
            else:
                c_times.append(run_once(c_exe, reps, 2, args, exp, a.cpu))
                b_times.append(run_once(b_exe, reps, 2, args, exp, a.cpu))
        b_med = statistics.median(b_times)
        c_med = statistics.median(c_times)
        ratio = c_med / b_med if b_med > 0 else 1.0
        row = dict(id=cid, reps=reps, base_ms=b_med, cand_ms=c_med, ratio=ratio,
                   base_runs=b_times, cand_runs=c_times)
        results.append(row)
        print(f"{cid:32s} reps={reps:6d} base={b_med:6.1f}ms cand={c_med:6.1f}ms ratio={ratio:.4f}x  base={b_times} cand={c_times}", flush=True)
    gm = math.exp(sum(math.log(r["ratio"]) for r in results) / len(results))
    print(f"\nGEOMEAN cand/base ({len(results)} cases): {gm:.4f}x")
    (a.out / "results.json").write_text(json.dumps(dict(
        base_rt=str(a.base_rt), cand_rt=str(a.cand_rt), cpu=a.cpu, rounds=a.rounds,
        geomean=gm, cases=results
    ), indent=2) + "\n")

if __name__ == "__main__":
    main()
