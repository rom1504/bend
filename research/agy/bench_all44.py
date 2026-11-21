#!/usr/bin/env python3
"""Full native45 (or subset) benchmark & qualification against Phase 205 baseline and mature Bend C reference."""
import argparse, gzip, json, math, statistics, subprocess, sys, time
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
NODE = "/home/ai/.nvm/versions/node/v24.22.1/bin/node"
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"
EMIT = ROOT / "research/agy/emit_obj.mjs"
CATALOG = json.loads((ROOT / "selfhost/tools/bench/catalogs/native45/catalog.json").read_text())
CASES = {c["id"]: c for c in CATALOG["cases"]}

P205_SUMMARY = json.loads(
    gzip.open(ROOT / "implementation/phase205/evidence/final-broad06.json.gz").read()
)["selfhost/build/phase205/final-broad06/summary.json"]["data"]
P205_BY_ID = {r["id"]: r for r in P205_SUMMARY["cases"]}


def emit_and_link(api_path, rt_path, extra_objs, src_path, obj_path, exe_path, reuse_obj=False):
    if not (reuse_obj and obj_path.exists() and obj_path.stat().st_size > 64):
        r = subprocess.run([NODE, "--stack-size=4096", str(EMIT), str(api_path), str(src_path), str(obj_path)],
                           capture_output=True, text=True)
        if r.returncode != 0:
            raise RuntimeError(f"emit failed for {src_path.name}: {r.stderr.strip()[:400]}")
    cmd = [CC, "-no-pie", str(obj_path), str(rt_path), *[str(x) for x in extra_objs], "-pthread", "-lm", "-o", str(exe_path)]
    r2 = subprocess.run(cmd, capture_output=True, text=True)
    if r2.returncode != 0:
        raise RuntimeError(f"link failed for {src_path.name}: {r2.stderr.strip()[:400]}")
    return obj_path.stat().st_size


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
    ap.add_argument("--base-api", type=Path, default=ROOT / "selfhost/build/agy/api-base/api.mjs")
    ap.add_argument("--cand-api", type=Path, required=True)
    ap.add_argument("--base-rt", type=Path, default=ROOT / "selfhost/build/agy/bootstrap/runtime-live-scan.o")
    ap.add_argument("--cand-rt", type=Path, default=ROOT / "selfhost/build/agy/bootstrap/runtime-live-scan.o")
    ap.add_argument("--cand-extra", action="append", default=[])
    ap.add_argument("--base-cache", type=Path, default=ROOT / "selfhost/build/agy/base-objs")
    ap.add_argument("--out", type=Path, required=True)
    ap.add_argument("--cases", default="all")
    ap.add_argument("--rounds", type=int, default=3)
    ap.add_argument("--target-ms", type=int, default=140)
    ap.add_argument("--cpu", type=int, default=2)
    a = ap.parse_args()
    a.out.mkdir(parents=True, exist_ok=True)
    a.base_cache.mkdir(parents=True, exist_ok=True)
    ids = list(CASES.keys()) if a.cases == "all" else [x.strip() for x in a.cases.split(",") if x.strip()]

    results = []
    for cid in ids:
        c = CASES[cid]
        src = ROOT / "selfhost/tools/bench" / c["source"]["file"]
        exp = c["point"]["expectedStdout"]
        args = c["point"]["runtimeArgs"]
        eligible = c["point"]["ratioEligible"]
        b_obj = a.base_cache / f"{cid}.o"
        b_exe = a.out / f"{cid}.base"
        c_obj = a.out / f"{cid}.cand.o"
        c_exe = a.out / f"{cid}.cand"
        b_sz = emit_and_link(a.base_api, a.base_rt, [], src, b_obj, b_exe, reuse_obj=True)
        c_sz = emit_and_link(a.cand_api, a.cand_rt, [Path(x) for x in a.cand_extra], src, c_obj, c_exe, reuse_obj=False)
        same_obj = b_obj.read_bytes() == c_obj.read_bytes()

        if not eligible:
            run_once(b_exe, 4, 2, args, exp, a.cpu)
            run_once(c_exe, 4, 2, args, exp, a.cpu)
            print(f"{cid:32s} ZERO-WORK ORACLE PASS same_obj={same_obj}", flush=True)
            results.append(dict(id=cid, eligible=False, same_obj=same_obj, ok=True))
            continue

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
        zero_clamped = False
        if c_med <= 0:
            c_med = 0.5  # conservative upper bound (<1ms over reps)
            zero_clamped = True
        if b_med <= 0:
            b_med = 0.5
        ratio = c_med / b_med
        p205 = P205_BY_ID[cid]
        base_over_c = p205["medianMs"]["candidate"] / p205["medianMs"]["c"]
        est_over_c = base_over_c * ratio
        est_fixed_ms = p205["fixedEquivalentMs"]["candidate"] * ratio
        c_fixed_ms = p205["fixedEquivalentMs"]["c"]
        row = dict(id=cid, eligible=True, reps=reps, base_ms=b_med, cand_ms=c_med,
                   zero_clamped=zero_clamped,
                   cand_over_base=ratio, p205_over_c=base_over_c, est_over_c=est_over_c,
                   est_fixed_ms=est_fixed_ms, c_fixed_ms=c_fixed_ms,
                   same_obj=same_obj, base_obj=b_sz, cand_obj=c_sz,
                   base_runs=b_times, cand_runs=c_times)
        results.append(row)
        print(f"{cid:32s} cand/base={ratio:.3f}x  overC: {base_over_c:.3f}x -> {est_over_c:.3f}x  same_obj={same_obj}", flush=True)

    timed = [r for r in results if r["eligible"]]
    gm_cb = math.exp(sum(math.log(r["cand_over_base"]) for r in timed) / len(timed))
    gm_c = math.exp(sum(math.log(r["est_over_c"]) for r in timed) / len(timed))
    fixed_cand = sum(r["est_fixed_ms"] for r in timed) / 1000.0
    fixed_c = sum(r["c_fixed_ms"] for r in timed) / 1000.0
    above2 = sum(1 for r in timed if r["est_over_c"] > 2.0)
    above11 = sum(1 for r in timed if r["est_over_c"] > 1.1)
    summary = dict(
        cases=len(timed),
        geomean_cand_over_base=gm_cb,
        geomean_est_over_c=gm_c,
        fixed_batch_cand_s=fixed_cand,
        fixed_batch_c_s=fixed_c,
        fixed_batch_over_c=fixed_cand / fixed_c if fixed_c > 0 else 0,
        above_2x_c=above2,
        above_1_1x_c=above11,
        rows=results,
    )
    print(f"\n=== SUMMARY ({len(timed)} timed cases) ===")
    print(f"Geomean cand/base : {gm_cb:.4f}x")
    print(f"Geomean vs C (est): {gm_c:.4f}x")
    print(f"Fixed batch vs C  : {fixed_cand:.3f}s / {fixed_c:.3f}s = {fixed_cand/fixed_c:.4f}x")
    print(f"Cases > 1.1x / 2x : {above11} / {above2}")
    (a.out / "summary.json").write_text(json.dumps(summary, indent=2) + "\n")


if __name__ == "__main__":
    main()
