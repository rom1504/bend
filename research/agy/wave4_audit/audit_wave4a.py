#!/usr/bin/env python3
"""Wave 4 Phase 2 Track W4-8: native45 10-benchmark zero-regression + Base-pin 6/6 gate on wave4a_unified/api.mjs."""
import gzip
import json
import math
import statistics
import subprocess
import tempfile
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
LOCKED_NODE = ROOT / "research/agy/locked_node.sh"
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"
BASE_BEND = ROOT / "selfhost/dist/base.bend"
BATCH_EMIT = ROOT / "research/agy/wave3_fuzz/batch_emit.mjs"

W4A_API = ROOT / "selfhost/build/agy/wave4a_unified/api.mjs"
W2_API = ROOT / "selfhost/build/agy/wave2_unified/api.mjs"
P205_API = ROOT / "selfhost/build/agy/api-base/api.mjs"
AGY_RT = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
P205_RT = ROOT / "selfhost/build/agy/bootstrap/runtime-live-scan.o"
W2_FULL44 = ROOT / "selfhost/build/agy/wave2_unified/full44"

CATALOG = json.loads((ROOT / "selfhost/tools/bench/catalogs/native45/catalog.json").read_text())
CASES = {c["id"]: c for c in CATALOG["cases"]}
W2_SUMMARY = {r["id"]: r for r in json.loads((W2_FULL44 / "summary.json").read_text())["rows"]}

BENCH_IDS = [
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

EMIT_LIVE_JS = r"""
import fs from 'node:fs';
import {pathToFileURL} from 'node:url';
const [prepApiPath, apiPath, basePath, inputPath, outObjPath] = process.argv.slice(2);
const prepApi = (await import(pathToFileURL(prepApiPath))).default;
const api = (await import(pathToFileURL(apiPath))).default;
const prep = prepApi.p86_prepare(basePath, fs.readFileSync(basePath, 'utf8'));
if (prep.$ !== 'P86PreparationReady') throw Error('prep failed: ' + prep.$);
const plan = api.p86_plan(prep.seed, inputPath, fs.readFileSync(inputPath, 'utf8'));
if (plan.$ !== 'P86PlanReady') throw Error('plan failed: ' + (plan.error ?? plan.$));
const obj = api.x187_prepared(api.x198pw_plan(plan));
if (obj.error !== '') throw Error('x86 emit failed: ' + obj.error);
const bytes = [];
for (let list = obj.bytes; list?.$ === 'Con'; list = list.tail) bytes.push(list.head);
fs.writeFileSync(outObjPath, Buffer.from(bytes));
"""


def run_bench_once(exe: Path, reps: int, warmups: int, args: list, expected_stdout: str, cpu: int = 2) -> int:
    r = subprocess.run(
        ["taskset", "-c", str(cpu), str(exe), str(reps), str(warmups), *[str(a) for a in args]],
        capture_output=True, text=True, check=True,
    )
    lines = r.stdout.splitlines()
    exp_lines = expected_stdout.splitlines()
    assert lines[:len(exp_lines)] == exp_lines, (exe.name, lines[:len(exp_lines)], exp_lines)
    assert int(lines[-3]) == warmups and int(lines[-2]) == reps, (exe.name, lines[-3:])
    return int(lines[-1])


def calibrate(exe: Path, args: list, expected_stdout: str, cpu: int = 2, target_ms: int = 140) -> int:
    reps = 4
    while True:
        ms = run_bench_once(exe, reps, 2, args, expected_stdout, cpu)
        if ms >= target_ms or reps >= 500000:
            return reps
        scale = max(2, int(math.ceil(target_ms / max(ms, 1))))
        reps = min(500000, reps * min(scale, 16))


def run_native45_10(tmp: Path) -> dict:
    print("=== 1. native45 10-Benchmark Audit (wave4a_unified vs wave2_unified, CPU 2, 3 runs) ===", flush=True)
    jobs = []
    for cid in BENCH_IDS:
        c = CASES[cid]
        src = ROOT / "selfhost/tools/bench" / c["source"]["file"]
        jobs.append({"id": cid, "src": str(src), "out": str(tmp / f"{cid}.w4a.o")})
    manifest = tmp / "n45_manifest.json"
    manifest.write_text(json.dumps(jobs))
    r_emit = subprocess.run(
        ["bash", str(LOCKED_NODE), "--stack-size=8192", str(BATCH_EMIT), str(W4A_API), str(manifest)],
        capture_output=True, text=True, check=True,
    )
    emitted = {item["id"]: item for item in json.loads(r_emit.stdout)}
    for cid in BENCH_IDS:
        assert emitted[cid]["ok"], f"emit failed for {cid}: {emitted[cid]}"

    rows = []
    for cid in BENCH_IDS:
        c = CASES[cid]
        exp = c["point"]["expectedStdout"]
        args = c["point"]["runtimeArgs"]
        w2_obj = W2_FULL44 / f"{cid}.cand.o"
        w4a_obj = tmp / f"{cid}.w4a.o"
        w2_exe = tmp / f"{cid}.w2.exe"
        w4a_exe = tmp / f"{cid}.w4a.exe"
        subprocess.run([CC, "-no-pie", str(w2_obj), str(AGY_RT), "-pthread", "-lm", "-o", str(w2_exe)], check=True)
        subprocess.run([CC, "-no-pie", str(w4a_obj), str(AGY_RT), "-pthread", "-lm", "-o", str(w4a_exe)], check=True)

        reps = calibrate(w4a_exe, args, exp, cpu=2, target_ms=140)
        w2_times, w4a_times = [], []
        for rd in range(3):
            if rd % 2 == 0:
                w2_times.append(run_bench_once(w2_exe, reps, 2, args, exp, cpu=2))
                w4a_times.append(run_bench_once(w4a_exe, reps, 2, args, exp, cpu=2))
            else:
                w4a_times.append(run_bench_once(w4a_exe, reps, 2, args, exp, cpu=2))
                w2_times.append(run_bench_once(w2_exe, reps, 2, args, exp, cpu=2))
        w2_med = max(statistics.median(w2_times), 0.5)
        w4a_med = max(statistics.median(w4a_times), 0.5)
        ratio = w4a_med / w2_med
        speedup = w2_med / w4a_med
        w2_over_c = W2_SUMMARY[cid]["est_over_c"]
        w4a_over_c = w2_over_c * ratio
        row = {
            "id": cid,
            "reps": reps,
            "w2_ms": w2_med,
            "w4a_ms": w4a_med,
            "w2_runs": w2_times,
            "w4a_runs": w4a_times,
            "w4a_over_w2": round(ratio, 4),
            "speedup": round(speedup, 4),
            "w2_est_over_c": round(w2_over_c, 4),
            "w4a_est_over_c": round(w4a_over_c, 4),
            "w2_obj_bytes": w2_obj.stat().st_size,
            "w4a_obj_bytes": w4a_obj.stat().st_size,
            "exact_stdout": True,
        }
        rows.append(row)
        print(
            f"  {cid:32s} w2={w2_med:6.1f}ms w4a={w4a_med:6.1f}ms  w4a/w2={ratio:.3f}x ({speedup:.2f}x)  overC: {w2_over_c:.3f}x -> {w4a_over_c:.3f}x  PASS",
            flush=True,
        )
        # Cleanup per-benchmark binaries immediately
        w4a_obj.unlink(missing_ok=True)
        w2_exe.unlink(missing_ok=True)
        w4a_exe.unlink(missing_ok=True)

    gm_ratio = math.exp(sum(math.log(r["w4a_over_w2"]) for r in rows) / len(rows))
    gm_over_c_w2 = math.exp(sum(math.log(r["w2_est_over_c"]) for r in rows) / len(rows))
    gm_over_c_w4a = math.exp(sum(math.log(r["w4a_est_over_c"]) for r in rows) / len(rows))
    print(f"  GEOMEAN (10 cases): w4a/w2 = {gm_ratio:.4f}x ({1/gm_ratio:.3f}x speedup) | overC: {gm_over_c_w2:.3f}x -> {gm_over_c_w4a:.3f}x\n", flush=True)
    return {
        "rows": rows,
        "geomean_w4a_over_w2": round(gm_ratio, 4),
        "geomean_speedup": round(1.0 / gm_ratio, 4),
        "geomean_w2_est_over_c": round(gm_over_c_w2, 4),
        "geomean_w4a_est_over_c": round(gm_over_c_w4a, 4),
    }


def build_and_run_live(emit_js: Path, api: Path, rt: Path, base: Path, src: Path, args: list, tmp: Path, tag: str):
    obj = tmp / f"{tag}.o"
    exe = tmp / f"{tag}.exe"
    r_emit = subprocess.run(
        ["bash", str(LOCKED_NODE), "--stack-size=4096", str(emit_js), str(W4A_API), str(api), str(base), str(src), str(obj)],
        capture_output=True, text=True,
    )
    if r_emit.returncode != 0:
        raise RuntimeError(f"emit failed ({tag}): {r_emit.stderr[:400]}")
    subprocess.run([CC, "-no-pie", str(obj), str(rt), "-pthread", "-lm", "-o", str(exe)],
                   capture_output=True, text=True, check=True)
    r = subprocess.run([str(exe), *args], capture_output=True, text=True, check=True)
    syms = subprocess.run(["objdump", "-t", str(obj)], capture_output=True, text=True, check=True).stdout
    obj.unlink(missing_ok=True)
    return r.stdout, syms, exe


def run_base_pin_6(tmp: Path) -> dict:
    print("=== 2. Base-Pin 6/6 Regression Gate on wave4a_unified/api.mjs ===", flush=True)
    base_text = BASE_BEND.read_text()
    emit_js = tmp / "emit_live.mjs"
    emit_js.write_text(EMIT_LIVE_JS)
    map_churn = ROOT / "selfhost/tools/bench/catalogs/native45/fixtures/coverage-map-churn-32.bend"
    rec_agg = ROOT / "selfhost/tools/bench/catalogs/native45/fixtures/coverage-record-aggregation-64.bend"
    row32 = ROOT / "selfhost/tools/bench/catalogs/native45/fixtures/complete-generic-row32.bend"
    checks = {}

    # 1. Stock Base Map.del (32/17 and 31/17)
    out_s32, syms_s, exe_s = build_and_run_live(emit_js, W4A_API, AGY_RT, BASE_BEND, map_churn, ["1", "0", "32", "17"], tmp, "stock_map")
    d_s31 = subprocess.run([str(exe_s), "1", "0", "31", "17"], capture_output=True, text=True, check=True).stdout.splitlines()[0]
    exe_s.unlink(missing_ok=True)
    d_s32 = out_s32.splitlines()[0]
    has_fast = "agy_map_slow_" in syms_s
    assert d_s32 == "2930913555" and d_s31 == "3758749986" and has_fast, (d_s32, d_s31, has_fast)
    checks["1_stock_map_del"] = {"d32": d_s32, "d31": d_s31, "fastPath": has_fast, "passed": True}
    print(f"  1/6 stock_map_del:       d32={d_s32} d31={d_s31} fastPath={has_fast} PASS", flush=True)

    # 2. Modified Base Map.del
    mod_del = tmp / "base_mod_del.bend"
    mod_del.write_text(base_text.replace("  Map.del.fin(a, V, Map.pop(a, V, m, key))",
                                         '  Map.del.fin(a, V, Map.pop(a, V, m, "absent" ++ key))', 1))
    out_p32, _, exe_p = build_and_run_live(emit_js, P205_API, P205_RT, mod_del, map_churn, ["1", "0", "32", "17"], tmp, "p205_mod_del")
    out_w32, syms_w, exe_w = build_and_run_live(emit_js, W4A_API, AGY_RT, mod_del, map_churn, ["1", "0", "32", "17"], tmp, "w4a_mod_del")
    d_p31 = subprocess.run([str(exe_p), "1", "0", "31", "17"], capture_output=True, text=True, check=True).stdout.splitlines()[0]
    d_w31 = subprocess.run([str(exe_w), "1", "0", "31", "17"], capture_output=True, text=True, check=True).stdout.splitlines()[0]
    exe_p.unlink(missing_ok=True); exe_w.unlink(missing_ok=True)
    d_p32, d_w32 = out_p32.splitlines()[0], out_w32.splitlines()[0]
    fell_back = "agy_map_slow_" not in syms_w
    assert d_p32 == d_w32 == "1962642045" and d_p31 == d_w31 == "2992498260" and fell_back
    checks["2_modified_map_del"] = {"d32": d_w32, "d31": d_w31, "fellBack": fell_back, "passed": True}
    print(f"  2/6 modified_map_del:    d32={d_w32} d31={d_w31} fellBack={fell_back} PASS", flush=True)

    # 3. Modified Base Map.set
    mod_set = tmp / "base_mod_set.bend"
    mod_set.write_text(base_text.replace("  Map.set.go(a, V, x, Map.seek(a, V, m, key))",
                                         '  Map.set.go(a, V, x, Map.seek(a, V, m, "extra" ++ key))', 1))
    out_ps, _, exe_ps = build_and_run_live(emit_js, P205_API, P205_RT, mod_set, map_churn, ["1", "0", "32", "17"], tmp, "p205_mod_set")
    out_ws, syms_ws, exe_ws = build_and_run_live(emit_js, W4A_API, AGY_RT, mod_set, map_churn, ["1", "0", "32", "17"], tmp, "w4a_mod_set")
    exe_ps.unlink(missing_ok=True); exe_ws.unlink(missing_ok=True)
    d_ps, d_ws = out_ps.splitlines()[0], out_ws.splitlines()[0]
    fell_back_set = ("agy_map_slow_" not in syms_ws) and ("__slow" not in syms_ws)
    assert d_ps == d_ws == "3982402709" and fell_back_set
    checks["3_modified_map_set"] = {"d32": d_ws, "fellBack": fell_back_set, "passed": True}
    print(f"  3/6 modified_map_set:    d32={d_ws} fellBack={fell_back_set} PASS", flush=True)

    # 4. Modified Base Map.get
    mod_get = tmp / "base_mod_get.bend"
    mod_get.write_text(base_text.replace("      Map.get.leaf(V, d, v, String.cmp(key, k))",
                                         '      Map.get.leaf(V, d, v, String.cmp("absent" ++ key, k))', 1))
    out_pg, _, exe_pg = build_and_run_live(emit_js, P205_API, P205_RT, mod_get, rec_agg, ["1", "0", "64", "17"], tmp, "p205_mod_get")
    out_wg, syms_wg, exe_wg = build_and_run_live(emit_js, W4A_API, AGY_RT, mod_get, rec_agg, ["1", "0", "64", "17"], tmp, "w4a_mod_get")
    exe_pg.unlink(missing_ok=True); exe_wg.unlink(missing_ok=True)
    fell_back_get = "__slow" not in syms_wg
    assert out_pg.splitlines()[0] == out_wg.splitlines()[0] and fell_back_get
    checks["4_modified_map_get"] = {"out": out_wg.splitlines()[0], "fellBack": fell_back_get, "passed": True}
    print(f"  4/6 modified_map_get:    out={out_wg.splitlines()[0]} fellBack={fell_back_get} PASS", flush=True)

    # 5. Modified Base Array.to_list.go
    mod_arr = tmp / "base_mod_arr.bend"
    mod_arr.write_text(base_text.replace("      Array.to_list.go(~T, xs, Array.to_list.go(~T, ys, acc))",
                                         "      Array.to_list.go(~T, ys, Array.to_list.go(~T, xs, acc))", 1))
    out_pa, _, exe_pa = build_and_run_live(emit_js, P205_API, P205_RT, mod_arr, row32, ["1", "0"], tmp, "p205_mod_arr")
    out_wa, syms_wa, exe_wa = build_and_run_live(emit_js, W4A_API, AGY_RT, mod_arr, row32, ["1", "0"], tmp, "w4a_mod_arr")
    exe_pa.unlink(missing_ok=True); exe_wa.unlink(missing_ok=True)
    fell_back_arr = "agy_al_orig_" not in syms_wa
    assert out_pa.splitlines()[0] == out_wa.splitlines()[0] and fell_back_arr
    checks["5_modified_arr_to_list"] = {"out": out_wa.splitlines()[0], "fellBack": fell_back_arr, "passed": True}
    print(f"  5/6 modified_arr_to_list: out={out_wa.splitlines()[0]} fellBack={fell_back_arr} PASS", flush=True)

    # 6. Stock Base fast-path + exact stdout on record-aggregation-256 & complete-generic-row32
    rec_agg_256 = ROOT / "selfhost/tools/bench/catalogs/native45/fixtures/coverage-record-aggregation-256.bend"
    r256_args = ["1", "0", *[str(a) for a in CASES["coverage-record-aggregation-256"]["point"]["runtimeArgs"]]]
    row32_args = ["1", "0", *[str(a) for a in CASES["complete-generic-row32"]["point"]["runtimeArgs"]]]
    out_r256, syms_r256, exe_r256 = build_and_run_live(emit_js, W4A_API, AGY_RT, BASE_BEND, rec_agg_256, r256_args, tmp, "stock_r256")
    out_row32, syms_row32, exe_row32 = build_and_run_live(emit_js, W4A_API, AGY_RT, BASE_BEND, row32, row32_args, tmp, "stock_row32")
    exe_r256.unlink(missing_ok=True); exe_row32.unlink(missing_ok=True)
    exp_r256 = CASES["coverage-record-aggregation-256"]["point"]["expectedStdout"].splitlines()[0]
    exp_row32 = CASES["complete-generic-row32"]["point"]["expectedStdout"].splitlines()[0]
    assert out_r256.splitlines()[0] == exp_r256 and out_row32.splitlines()[0] == exp_row32
    checks["6_stock_fastpath_exact"] = {
        "rec_agg_256": out_r256.splitlines()[0],
        "row32": out_row32.splitlines()[0],
        "row32_arrlist_fast": "agy_al_orig_" in syms_row32,
        "passed": True,
    }
    print(f"  6/6 stock_fastpath_exact: r256={out_r256.splitlines()[0]} row32={out_row32.splitlines()[0]} arrlist_fast={'agy_al_orig_' in syms_row32} PASS\n", flush=True)
    return {"passed": True, "count": "6/6", "checks": checks}


def main():
    with tempfile.TemporaryDirectory() as td:
        tmp = Path(td)
        n45 = run_native45_10(tmp)
        bp = run_base_pin_6(tmp)
    out = ROOT / "experiments/agy/receipts/wave4a-audit-native45-basepin.json"
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps({"native45_10": n45, "base_pin_6": bp}, indent=2) + "\n")
    print(f"Wrote receipt: {out}")


if __name__ == "__main__":
    main()
