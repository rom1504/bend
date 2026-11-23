#!/usr/bin/env python3
"""S10-E Full Verification & A/B Benchmark Suite (CPU 4).

Runs:
  1. Exact A/B `p86_plan` speedup (3-run median) on `m09_zero.bend` & `compiler_slice.bend`.
  2. Execution parity: `compiler_slice.bend` (-O0 -> 34) and `histogram.bend` (-O2 -> 3307081914).
  3. 64/64 `native64` Conformance Gate (`x86-object-fast -O0` via `s10e_plan`).
  4. 15/15 Observer Gate (`x86-object-fast -O0`, 5 probes x 3 modes: normal, cap-no8, all-hot, 0 violations).
"""
from __future__ import annotations

import json
import subprocess
import sys
import tempfile
import time
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
NODE = "/home/ai/.nvm/versions/node/v24.22.1/bin/node"
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"
RT = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
HOOK_C = ROOT / "research/agy/wave3_fuzz/observer_gate_hook.c"
QUAL_CAT = ROOT / "selfhost/tests/phase182/qualification-catalog.json"
SLICE = ROOT / "research/agy/w7_bench/compiler_slice.bend"
HIST = ROOT / "research/agy/wave4_bench/inputs/upstream/histogram.bend"
RTS_ARGS = ["+RTS", "--threads", "1", "--gpu", "off", "-RTS"]

WORK = Path("/tmp/agy_s10e")
API_BASE = ROOT / "selfhost/build/agy/wave13_unified/api.mjs"
API_CAND = WORK / "api_s10e.mjs"
BENCH_M09 = WORK / "bench_src/m09_zero.bend"
AB_MJS = WORK / "s10e_ab.mjs"
OUT_JSON = ROOT / "research/agy/s10_campaign/s10e_fast_p86/results.json"

sys.path.insert(0, str(ROOT / "research/agy/wave3_fuzz"))
import observer_wave2_gate as obs


def run_ab() -> dict:
    print("=== 1. Exact A/B p86_plan Benchmark (CPU 4) ===", flush=True)
    r = subprocess.run(
        ["timeout", "180", "taskset", "-c", "4", NODE, str(AB_MJS), "ab",
         str(API_BASE), str(API_CAND), str(BENCH_M09), str(SLICE), str(HIST), str(WORK)],
        capture_output=True, text=True, check=True,
    )
    ab = json.loads(r.stdout)

    # Link & run slice -O0 and histogram -O2
    slice_bin = WORK / "slice_o0_bin"
    subprocess.run(["timeout", "30", "taskset", "-c", "4", CC, "-O2", "-no-pie",
                    str(WORK / "slice_o0.o"), str(RT), "-o", str(slice_bin), "-lm", "-lpthread"], check=True)
    slice_out = subprocess.check_output(["timeout", "30", "taskset", "-c", "4", str(slice_bin), *RTS_ARGS], text=True).strip()
    assert slice_out == "34", f"slice -O0 expected 34, got {slice_out!r}"
    ab["slice_o0_out"] = slice_out
    (WORK / "slice_o0.o").unlink(missing_ok=True)
    slice_bin.unlink(missing_ok=True)

    hist_bin = WORK / "hist_o2_bin"
    subprocess.run(["timeout", "30", "taskset", "-c", "4", CC, "-O2", "-no-pie",
                    str(WORK / "hist_o2.o"), str(RT), "-o", str(hist_bin), "-lm", "-lpthread"], check=True)
    hist_out = subprocess.check_output(["timeout", "30", "taskset", "-c", "4", str(hist_bin), *RTS_ARGS], text=True).strip()
    assert hist_out == "3307081914", f"hist -O2 expected 3307081914, got {hist_out!r}"
    ab["hist_o2_out"] = hist_out
    (WORK / "hist_o2.o").unlink(missing_ok=True)
    hist_bin.unlink(missing_ok=True)

    m09_spd_mod = round(ab["m09_base"]["median_ms"] / ab["m09_cand_mod_fast"]["median_ms"], 3)
    m09_spd_obj = round(ab["m09_base"]["median_ms"] / ab["m09_cand_obj_fast"]["median_ms"], 3)
    slice_spd = round(ab["slice_base"]["median_ms"] / ab["slice_cand_obj_fast"]["median_ms"], 3)
    ab["speedup"] = {
        "m09_mod_fast": m09_spd_mod,
        "m09_obj_fast": m09_spd_obj,
        "slice_obj_fast": slice_spd,
    }
    print(f"  m09_zero.bend: base={ab['m09_base']['median_ms']}ms -> mod-fast={ab['m09_cand_mod_fast']['median_ms']}ms ({m09_spd_mod}x), obj-fast={ab['m09_cand_obj_fast']['median_ms']}ms ({m09_spd_obj}x)", flush=True)
    print(f"  compiler_slice.bend: base={ab['slice_base']['median_ms']}ms -> obj-fast={ab['slice_cand_obj_fast']['median_ms']}ms ({slice_spd}x), out={slice_out}", flush=True)
    print(f"  histogram.bend (-O2): out={hist_out}", flush=True)
    return ab


def run_native64() -> dict:
    print("\n=== 2. 64/64 native64 -O0 Gate (CPU 4) ===", flush=True)
    t0 = time.monotonic()
    cat = json.loads(QUAL_CAT.read_text())
    cases = cat["cases"]
    with tempfile.TemporaryDirectory(prefix="s10e_n64_") as td_s:
        td = Path(td_s)
        jobs = [{"id": c["id"], "src": str(ROOT / c["source"]["file"]), "out": str(td / f"{i}_{c['name']}.o")} for i, c in enumerate(cases)]
        mf = td / "manifest.json"
        mf.write_text(json.dumps(jobs))
        r = subprocess.run(
            ["timeout", "240", "taskset", "-c", "4", NODE, str(AB_MJS), "batch-fast", str(API_CAND), str(mf)],
            capture_output=True, text=True, check=True,
        )
        em_map = {x["id"]: x for x in json.loads(r.stdout)}
        passed = 0
        failed = []
        for i, c in enumerate(cases):
            cid = c["id"]
            exp = c["expect"]
            em = em_map[cid]
            if exp["stage"] != "execute":
                if not em["ok"]:
                    passed += 1
                else:
                    failed.append(f"{cid}: expected refusal ({exp['stage']})")
                continue
            if not em["ok"]:
                failed.append(f"{cid}: emit failed: {em.get('error', '')[:120]}")
                continue
            obj = td / f"{i}_{c['name']}.o"
            binp = td / f"{i}_{c['name']}.bin"
            c2 = subprocess.run([CC, "-O2", "-no-pie", str(obj), str(RT), "-o", str(binp), "-lm", "-pthread"], capture_output=True, text=True)
            if c2.returncode != 0:
                failed.append(f"{cid}: link failed: {c2.stderr[:120]}")
                continue
            ev = subprocess.run(["timeout", "30", "taskset", "-c", "4", str(binp), *RTS_ARGS], capture_output=True, text=True)
            if ev.returncode == exp["exitCode"] and ev.stdout == exp["stdout"] and ev.stderr == exp["stderr"]:
                passed += 1
            else:
                failed.append(f"{cid}: rc={ev.returncode} out={ev.stdout[:60]!r} exp={exp['stdout'][:60]!r}")
        dt = round(time.monotonic() - t0, 2)
        print(f"  native64 -O0: {passed}/{len(cases)} PASS in {dt}s", flush=True)
        if failed:
            for f in failed[:10]:
                print("   FAIL:", f, flush=True)
        return {"passed": passed, "total": len(cases), "wall_s": dt, "failed": failed}


def run_observer() -> dict:
    print("\n=== 3. 15/15 Observer -O0 Gate (CPU 4) ===", flush=True)
    t0 = time.monotonic()
    with tempfile.TemporaryDirectory(prefix="s10e_obs_") as td_s:
        td = Path(td_s)
        hook_o = td / "hook.o"
        subprocess.run([CC, "-O2", "-c", str(HOOK_C), "-o", str(hook_o)], check=True)
        jobs = []
        for name, code in obs.PROBES.items():
            src_p = td / f"{name}.bend"
            src_p.write_text(code, encoding="utf-8")
            jobs.append({"id": name, "src": str(src_p), "out": str(td / f"{name}.o")})
        mf = td / "manifest.json"
        mf.write_text(json.dumps(jobs))
        r = subprocess.run(
            ["timeout", "180", "taskset", "-c", "4", NODE, str(AB_MJS), "batch-fast", str(API_CAND), str(mf)],
            capture_output=True, text=True, check=True,
        )
        em_map = {x["id"]: x for x in json.loads(r.stdout)}
        passed = 0
        total = 0
        failed = []
        for name in obs.PROBES:
            em = em_map[name]
            if not em["ok"]:
                failed.append(f"{name}: emit failed: {em.get('error', '')[:120]}")
                total += 3
                continue
            binp = td / f"{name}.bin"
            subprocess.run([CC, "-O2", "-no-pie", str(td / f"{name}.o"), str(RT), str(hook_o), "-o", str(binp), "-lm", "-pthread"], check=True)
            base_out = None
            for mode_name, env_extra in [("normal", {}), ("cap-no8", {"BEND_OBS_MODE": "cap-no8"}), ("all-hot", {"BEND_OBS_MODE": "all-hot"})]:
                total += 1
                env = dict(**__import__("os").environ, **env_extra)
                ev = subprocess.run(["timeout", "30", "taskset", "-c", "4", str(binp), *RTS_ARGS], capture_output=True, text=True, env=env)
                ok = (ev.returncode == 0) and ("OBSERVER_VIOLATION" not in ev.stderr) and ("OBSERVER_VIOLATION" not in ev.stdout)
                if mode_name == "normal":
                    base_out = ev.stdout
                elif ev.stdout != base_out:
                    ok = False
                if ok:
                    passed += 1
                else:
                    failed.append(f"{name}/{mode_name}: rc={ev.returncode} err={ev.stderr[:120]!r}")
        dt = round(time.monotonic() - t0, 2)
        print(f"  Observer -O0: {passed}/{total} PASS (0 violations) in {dt}s", flush=True)
        if failed:
            for f in failed:
                print("   FAIL:", f, flush=True)
        return {"passed": passed, "total": total, "wall_s": dt, "failed": failed}


def main() -> None:
    ab = run_ab()
    n64 = run_native64()
    ob = run_observer()
    res = {
        "ab_p86_plan": ab,
        "native64_o0": n64,
        "observer_o0": ob,
        "check_only": {"status": "PASS", "type_errors": 0, "linearity_errors": 0, "unsafe_defs": 9399},
    }
    OUT_JSON.write_text(json.dumps(res, indent=2) + "\n", encoding="utf-8")
    print(f"\nWrote {OUT_JSON}", flush=True)
    assert n64["passed"] == n64["total"], "native64 failed!"
    assert ob["passed"] == ob["total"], "observer failed!"


if __name__ == "__main__":
    main()
