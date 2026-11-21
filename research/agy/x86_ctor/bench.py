#!/usr/bin/env python3
"""Emit, verify, and run alternating CPU-0 timings comparing baseline vs candidate."""
import argparse, json, math, statistics, subprocess, time
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
NODE = "/home/ai/.nvm/versions/node/v24.22.1/bin/node"
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"
EMIT = ROOT / "research/agy/emit_obj.mjs"
CATALOG = json.loads((ROOT / "selfhost/tools/bench/catalogs/native45/catalog.json").read_text())
CASES = {c["id"]: c for c in CATALOG["cases"]}

def emit_and_link(api_path, rt_path, src_path, obj_path, exe_path):
    t0 = time.perf_counter()
    subprocess.run([NODE, "--stack-size=4096", str(EMIT), str(api_path), str(src_path), str(obj_path)],
                   capture_output=True, text=True, check=True)
    t1 = time.perf_counter()
    subprocess.run([CC, "-no-pie", str(obj_path), str(rt_path), "-pthread", "-lm", "-o", str(exe_path)],
                   capture_output=True, text=True, check=True)
    return t1 - t0, obj_path.stat().st_size

def run_once(exe, reps, warmups, args, expected_stdout, cpu):
    r = subprocess.run(["taskset", "-c", str(cpu), str(exe), str(reps), str(warmups), *[str(a) for a in args]],
                       capture_output=True, text=True, check=True)
    lines = r.stdout.splitlines()
    exp_lines = expected_stdout.splitlines()
    assert lines[:len(exp_lines)] == exp_lines, (exe, lines[:len(exp_lines)], exp_lines)
    assert int(lines[-3]) == warmups and int(lines[-2]) == reps, (exe, lines[-3:])
    return int(lines[-1])

def calibrate(exe, args, expected_stdout, cpu, target_ms=140):
    reps = 4
    while True:
        ms = run_once(exe, reps, 2, args, expected_stdout, cpu)
        if ms >= target_ms or reps >= 500000:
            return reps
        scale = max(2, int(math.ceil(target_ms / max(ms, 1))))
        reps = min(500000, reps * min(scale, 16))

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--base-api", type=Path, required=True)
    ap.add_argument("--cand-api", type=Path, required=True)
    ap.add_argument("--base-rt", type=Path, default=ROOT / "selfhost/build/agy/bootstrap/runtime-live-scan.o")
    ap.add_argument("--cand-rt", type=Path, default=ROOT / "selfhost/build/agy/bootstrap/runtime-live-scan.o")
    ap.add_argument("--out", type=Path, required=True)
    ap.add_argument("--cases", required=True)
    ap.add_argument("--rounds", type=int, default=5)
    ap.add_argument("--target-ms", type=int, default=140)
    ap.add_argument("--cpu", type=int, default=0)
    a = ap.parse_args()
    a.out.mkdir(parents=True, exist_ok=True)
    ids = [x.strip() for x in a.cases.split(",") if x.strip()]
    results = []
    for cid in ids:
        c = CASES[cid]
        src = ROOT / "selfhost/tools/bench" / c["source"]["file"]
        exp = c["point"]["expectedStdout"]
        args = c["point"]["runtimeArgs"]
        b_obj, b_exe = a.out / f"{cid}.base.o", a.out / f"{cid}.base"
        c_obj, c_exe = a.out / f"{cid}.cand.o", a.out / f"{cid}.cand"
        _, b_sz = emit_and_link(a.base_api, a.base_rt, src, b_obj, b_exe)
        _, c_sz = emit_and_link(a.cand_api, a.cand_rt, src, c_obj, c_exe)
        same_obj = b_obj.read_bytes() == c_obj.read_bytes()
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
                   same_obj=same_obj, base_obj=b_sz, cand_obj=c_sz,
                   base_runs=b_times, cand_runs=c_times)
        results.append(row)
        print(f"{cid:26s} reps={reps:6d} base={b_med:6.1f}ms cand={c_med:6.1f}ms ratio={ratio:.3f}x obj={b_sz}->{c_sz}", flush=True)
    gm = math.exp(sum(math.log(r["ratio"]) for r in results) / len(results))
    print(f"\nGEOMEAN cand/base ({len(results)} cases): {gm:.4f}x")
    (a.out / "results.json").write_text(json.dumps(dict(geomean=gm, cases=results), indent=2) + "\n")

if __name__ == "__main__":
    main()
