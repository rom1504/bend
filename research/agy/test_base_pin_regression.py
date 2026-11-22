#!/usr/bin/env python3
"""Permanent regression gate for AGY-W2-BASEPIN (Base library body identity).

Tests:
  1. Codex's exact Map.del reproducer (sizes 32 & 31, seed 17):
     - Stock Base -> selects fast path and matches original digest (2930913555 / 3758749986)
     - Modified Base (Map.del passes "absent" ++ key) -> falls back and matches Phase 205 (1962642045 / 2992498260)
  2. Modified Base Map.get (always returns default d) -> Wave 2 matches Phase 205
  3. Modified Base Array.to_list.go (returns Nil{}) -> Wave 2 matches Phase 205
  4. Stock Base zero-regression: coverage-map-churn-32, coverage-record-aggregation-256,
     complete-generic-row32 emit bit-for-bit identical .o to pre-pin wave2_unified/full44/*.cand.o
"""
import hashlib
import json
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
NODE = "/home/ai/.nvm/versions/node/v24.22.1/bin/node"
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"
BASE = ROOT / "selfhost/dist/base.bend"
P205_API = ROOT / "selfhost/build/agy/api-base/api.mjs"
W2_API = ROOT / "selfhost/build/agy/wave2_unified/api.mjs"
P205_RT = ROOT / "selfhost/build/agy/bootstrap/runtime-live-scan.o"
AGY_RT = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
FULL44_DIR = ROOT / "selfhost/build/agy/wave2_unified/full44"

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


def sha256_file(p: Path) -> str:
    return hashlib.sha256(p.read_bytes()).hexdigest()


def build_and_run(emit_js: Path, api: Path, rt: Path, base: Path, src: Path, args: list, tmp: Path, tag: str):
    obj = tmp / f"{tag}.o"
    exe = tmp / f"{tag}.exe"
    r_emit = subprocess.run([NODE, "--stack-size=4096", str(emit_js), str(W2_API), str(api), str(base), str(src), str(obj)],
                            capture_output=True, text=True)
    if r_emit.returncode != 0:
        raise RuntimeError(f"emit failed ({tag}): {r_emit.stderr[:400]}")
    subprocess.run([CC, "-no-pie", str(obj), str(rt), "-pthread", "-lm", "-o", str(exe)],
                   capture_output=True, text=True, check=True)
    r = subprocess.run([str(exe), *args], capture_output=True, text=True, check=True)
    syms = subprocess.run(["objdump", "-t", str(obj)], capture_output=True, text=True, check=True).stdout
    return r.stdout, syms, obj


def main():
    report = {"kind": "agy-wave2-basepin-regression-v1", "checks": {}, "passed": False}
    base_text = BASE.read_text()
    map_churn = ROOT / "selfhost/tools/bench/catalogs/native45/fixtures/coverage-map-churn-32.bend"

    with tempfile.TemporaryDirectory() as td:
        tmp = Path(td)
        emit_js = tmp / "emit_live.mjs"
        emit_js.write_text(EMIT_LIVE_JS)

        # 1a. Stock Base on coverage-map-churn-32 (32/17 and 31/17)
        out_s32, syms_s, obj_s = build_and_run(emit_js, W2_API, AGY_RT, BASE, map_churn, ["1", "0", "32", "17"], tmp, "stock_map")
        r31 = subprocess.run([str(tmp / "stock_map.exe"), "1", "0", "31", "17"], capture_output=True, text=True, check=True)
        d_s32 = out_s32.splitlines()[0]
        d_s31 = r31.stdout.splitlines()[0]
        has_fast = "agy_map_slow_" in syms_s
        same_as_pre = sha256_file(obj_s) == sha256_file(FULL44_DIR / "coverage-map-churn-32.cand.o")
        assert d_s32 == "2930913555" and d_s31 == "3758749986" and has_fast and same_as_pre, (d_s32, d_s31, has_fast, same_as_pre)
        report["checks"]["stock_map_del"] = dict(d32=d_s32, d31=d_s31, fastPathSelected=has_fast, bitIdenticalToPrePin=same_as_pre, passed=True)
        print(f"1a. stock_map_del:       d32={d_s32} d31={d_s31} fastPath={has_fast} bitIdentical={same_as_pre} PASS", flush=True)

        # 1b. Codex's exact modified Base (Map.del passes "absent" ++ key)
        mod_del = tmp / "base_mod_del.bend"
        old_line = "  Map.del.fin(a, V, Map.pop(a, V, m, key))"
        new_line = '  Map.del.fin(a, V, Map.pop(a, V, m, "absent" ++ key))'
        assert base_text.count(old_line) == 1
        mod_del.write_text(base_text.replace(old_line, new_line, 1))
        out_p32, _, _ = build_and_run(emit_js, P205_API, P205_RT, mod_del, map_churn, ["1", "0", "32", "17"], tmp, "p205_mod_del")
        out_w32, syms_w, _ = build_and_run(emit_js, W2_API, AGY_RT, mod_del, map_churn, ["1", "0", "32", "17"], tmp, "w2_mod_del")
        d_p32, d_w32 = out_p32.splitlines()[0], out_w32.splitlines()[0]
        d_p31 = subprocess.run([str(tmp / "p205_mod_del.exe"), "1", "0", "31", "17"], capture_output=True, text=True, check=True).stdout.splitlines()[0]
        d_w31 = subprocess.run([str(tmp / "w2_mod_del.exe"), "1", "0", "31", "17"], capture_output=True, text=True, check=True).stdout.splitlines()[0]
        fell_back = "agy_map_slow_" not in syms_w
        assert d_p32 == d_w32 == "1962642045" and d_p31 == d_w31 == "2992498260" and fell_back, (d_p32, d_w32, d_p31, d_w31, fell_back)
        report["checks"]["modified_map_del"] = dict(p205_32=d_p32, w2_32=d_w32, p205_31=d_p31, w2_31=d_w31, fellBack=fell_back, passed=True)
        print(f"1b. modified_map_del:    d32={d_w32} d31={d_w31} fellBack={fell_back} PASS", flush=True)

        # 1c. Codex's exact modified Base Map.set (prefixes key passed to Map.seek with "extra")
        mod_set = tmp / "base_mod_set.bend"
        old_set = "  Map.set.go(a, V, x, Map.seek(a, V, m, key))"
        new_set = '  Map.set.go(a, V, x, Map.seek(a, V, m, "extra" ++ key))'
        assert base_text.count(old_set) == 1
        mod_set.write_text(base_text.replace(old_set, new_set, 1))
        out_ps, _, _ = build_and_run(emit_js, P205_API, P205_RT, mod_set, map_churn, ["1", "0", "32", "17"], tmp, "p205_mod_set")
        out_ws, syms_ws, _ = build_and_run(emit_js, W2_API, AGY_RT, mod_set, map_churn, ["1", "0", "32", "17"], tmp, "w2_mod_set")
        d_ps, d_ws = out_ps.splitlines()[0], out_ws.splitlines()[0]
        fell_back_set = ("agy_map_slow_" not in syms_ws) and ("__slow" not in syms_ws)
        assert d_ps == d_ws == "3982402709" and fell_back_set, (d_ps, d_ws, fell_back_set)
        report["checks"]["modified_map_set"] = dict(p205_32=d_ps, w2_32=d_ws, fellBack=fell_back_set, passed=True)
        print(f"1c. modified_map_set:    d32={d_ws} fellBack={fell_back_set} PASS", flush=True)

        # 2. Modified Base Map.get (prefixes key with "absent")
        mod_get = tmp / "base_mod_get.bend"
        old_get = "      Map.get.leaf(V, d, v, String.cmp(key, k))"
        new_get = '      Map.get.leaf(V, d, v, String.cmp("absent" ++ key, k))'
        assert base_text.count(old_get) == 1
        mod_get.write_text(base_text.replace(old_get, new_get, 1))
        rec_agg = ROOT / "selfhost/tools/bench/catalogs/native45/fixtures/coverage-record-aggregation-64.bend"
        out_pg, _, _ = build_and_run(emit_js, P205_API, P205_RT, mod_get, rec_agg, ["1", "0", "64", "17"], tmp, "p205_mod_get")
        out_wg, syms_wg, _ = build_and_run(emit_js, W2_API, AGY_RT, mod_get, rec_agg, ["1", "0", "64", "17"], tmp, "w2_mod_get")
        assert out_pg.splitlines()[0] == out_wg.splitlines()[0] and "__slow" not in syms_wg, (out_pg.splitlines()[0], out_wg.splitlines()[0])
        report["checks"]["modified_map_get"] = dict(p205=out_pg.splitlines()[0], w2=out_wg.splitlines()[0], passed=True)
        print(f"2.  modified_map_get:    p205={out_pg.splitlines()[0]} w2={out_wg.splitlines()[0]} PASS", flush=True)

        # 3. Modified Base Array.to_list.go (swaps xs/ys order -> reverses chunk order, linear-safe!)
        mod_arr = tmp / "base_mod_arr.bend"
        old_arr = "      Array.to_list.go(~T, xs, Array.to_list.go(~T, ys, acc))"
        new_arr = "      Array.to_list.go(~T, ys, Array.to_list.go(~T, xs, acc))"
        assert base_text.count(old_arr) == 1
        mod_arr.write_text(base_text.replace(old_arr, new_arr, 1))
        row32 = ROOT / "selfhost/tools/bench/catalogs/native45/fixtures/complete-generic-row32.bend"
        out_pa, _, _ = build_and_run(emit_js, P205_API, P205_RT, mod_arr, row32, ["1", "0"], tmp, "p205_mod_arr")
        out_wa, syms_wa, _ = build_and_run(emit_js, W2_API, AGY_RT, mod_arr, row32, ["1", "0"], tmp, "w2_mod_arr")
        assert out_pa.splitlines()[0] == out_wa.splitlines()[0] and "agy_al_orig_" not in syms_wa, (out_pa.splitlines()[0], out_wa.splitlines()[0])
        report["checks"]["modified_arr_to_list"] = dict(p205=out_pa.splitlines()[0], w2=out_wa.splitlines()[0], fellBack=("agy_al_orig_" not in syms_wa), passed=True)
        print(f"3.  modified_arr_to_list: p205={out_pa.splitlines()[0]} w2={out_wa.splitlines()[0]} fellBack=True PASS", flush=True)

        # 4. Stock Base zero-regression bit-identity on record-aggregation-256 & complete-generic-row32
        for cid in ("coverage-record-aggregation-256", "complete-generic-row32"):
            src = ROOT / "selfhost/tools/bench/catalogs/native45/fixtures" / f"{cid}.bend"
            _, _, obj = build_and_run(emit_js, W2_API, AGY_RT, BASE, src, ["1", "0"] + (["256", "17"] if "256" in cid else []), tmp, f"stock_{cid}")
            same = sha256_file(obj) == sha256_file(FULL44_DIR / f"{cid}.cand.o")
            assert same, f"{cid} object changed on stock Base!"
            report["checks"][f"stock_bit_identical_{cid}"] = dict(passed=True)
            print(f"4.  stock_bit_identical: {cid} bitIdentical={same} PASS", flush=True)

    report["passed"] = True
    if len(sys.argv) > 1:
        Path(sys.argv[1]).write_text(json.dumps(report, indent=2) + "\n")
    print("\nALL BASE-PIN REGRESSION GATES PASSED!")


if __name__ == "__main__":
    main()
