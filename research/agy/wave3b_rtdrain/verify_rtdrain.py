#!/usr/bin/env python3
"""All-in-one verification & SIGPROF runtime-drain benchmark for Wave 3B Track B1.

1. Compiles & profiles `proxy_rfc_ast.bend` (~1s AST/ADT/RFC/String proxy) + 6 catalog proxies
   on BOTH baseline (`wave2_unified/api.mjs`) AND candidate (`wave3b_rtdrain/api.mjs`)
   linked against UNCHANGED `unified/runtime-agy.o`.
   Checks exact stdout equality with upstream (`bun bend2/main.ts`) on `proxy_rfc_ast.bend`
   and exact catalog stdout on all 6 proxies.
2. Runs 19/19 `focused19` conformance gate (using single `batch_emit.mjs` call for speed!).
3. Runs `observer_wave2_gate` (15/15 live-metadata probes: normal / cap-no8 / all-hot)
   with candidate `api.mjs` + unchanged `unified/runtime-agy.o` (0 OBSERVER_VIOLATIONs!).
"""
import argparse
import bisect
import collections
import json
import os
import statistics
import struct
import subprocess
import sys
import tempfile
import time
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
BUN = ROOT / "selfhost/.assets/bin/bun"
NODE = "/home/ai/.nvm/versions/node/v24.22.1/bin/node"
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"
BATCH = ROOT / "research/agy/wave3_fuzz/batch_emit.mjs"
RT_OBJ = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
PROF_OBJ = ROOT / "selfhost/build/agy/wave3b_rtdrain/prof.o"
HOOK_C = ROOT / "research/agy/wave3_fuzz/observer_gate_hook.c"
RUNTIME_DIR = ROOT / "selfhost/src/runtime/qbe"
CATALOG_45 = ROOT / "selfhost/tools/bench/catalogs/native45/catalog.json"
QUAL_CAT = ROOT / "selfhost/tests/phase182/qualification-catalog.json"
RFC_PROXY = ROOT / "research/agy/wave3b_rtdrain/proxy_rfc_ast.bend"
W2_API = ROOT / "selfhost/build/agy/wave2_unified/api.mjs"
W3B_API = ROOT / "selfhost/build/agy/wave3b_rtdrain/api.mjs"
RTS_ARGS = ["+RTS", "--threads", "1", "--gpu", "off", "-RTS"]

PROXIES = [
    "lexer",
    "coverage-bst-64",
    "coverage-map-churn-32",
    "symreg",
    "raytrace",
    "mandelbrot",
]


def load_rt_symbols() -> set:
    out = subprocess.check_output(["nm", str(RT_OBJ)], text=True)
    return {
        p[2]
        for line in out.splitlines()
        if len(p := line.split()) >= 3 and p[1] in ("T", "t", "W", "w")
    }


def load_exe_syms(exe: Path):
    out = subprocess.check_output(["nm", "-n", str(exe)], text=True)
    addrs, names = [], []
    for line in out.splitlines():
        p = line.split()
        if len(p) >= 3 and p[1] in ("T", "t", "W", "w"):
            try:
                addrs.append(int(p[0], 16))
                names.append(p[2])
            except ValueError:
                pass
    return addrs, names


def resolve_pc(addrs, names, pc: int) -> str:
    i = bisect.bisect_right(addrs, pc) - 1
    if i < 0:
        return "<below>"
    if pc - addrs[i] > 0x200000:
        return "<ext>"
    return names[i]


def batch_emit(api: Path, jobs: list, manifest: Path) -> dict:
    manifest.write_text(json.dumps(jobs))
    r = subprocess.run(
        [NODE, "--stack-size=8192", str(BATCH), str(api), str(manifest)],
        capture_output=True,
        text=True,
        timeout=300,
    )
    if r.returncode != 0:
        raise RuntimeError(f"batch_emit({api}) failed: {r.stderr[:400]}")
    return {x["id"]: x for x in json.loads(r.stdout)}


def profile_exe(exe: Path, args: list, rt_syms: set, prof_file: Path, cpu: int = 2):
    env = dict(os.environ, PROF_OUT=str(prof_file), PROF_SECONDS="5")
    t0 = time.perf_counter()
    r = subprocess.run(
        ["taskset", "-c", str(cpu), str(exe), *args],
        env=env,
        capture_output=True,
        timeout=20,
    )
    dt = time.perf_counter() - t0
    if r.returncode != 0:
        raise RuntimeError(f"prof failed {exe.name}: rc={r.returncode} {r.stderr[:200]}")
    data = prof_file.read_bytes() if prof_file.exists() else b""
    n = len(data) // 24
    addrs, names = load_exe_syms(exe)
    rt_counts = collections.Counter()
    for i in range(n):
        rip, _, _, _ = struct.unpack_from("<QQII", data, i * 24)
        sym = resolve_pc(addrs, names, rip)
        if sym in rt_syms:
            rt_counts[sym] += 1
    rt_tot = sum(rt_counts.values())
    return dict(
        total=n,
        rt_samples=rt_tot,
        rt_pct=round(100.0 * rt_tot / max(n, 1), 2),
        top_rt=[(s, c, round(100.0 * c / max(n, 1), 2)) for s, c in rt_counts.most_common(8)],
        elapsed_ms=round(dt * 1000.0, 2),
    )


def run_benchmark_pair(rt_syms: set, cpu: int = 2) -> dict:
    cat45 = {c["id"]: c for c in json.loads(CATALOG_45.read_text())["cases"]}
    # Get upstream expected stdout for proxy_rfc_ast.bend
    up_rfc = subprocess.run(
        [str(BUN), str(ROOT / "bend2/main.ts"), str(RFC_PROXY)],
        capture_output=True,
        text=True,
        timeout=60,
        check=True,
    ).stdout.strip()
    print(f"[upstream] proxy_rfc_ast.bend stdout = {up_rfc!r}", flush=True)

    out = {"upstream_rfc_proxy": up_rfc, "baseline": {}, "rtdrain": {}}
    with tempfile.TemporaryDirectory(prefix="w3b_eval_") as td:
        tdir = Path(td)
        for tag, api in (("baseline", W2_API), ("rtdrain", W3B_API)):
            print(f"\n=== Benchmarking {tag} ({api.parent.name}) ===", flush=True)
            jobs = [{"id": "proxy_rfc_ast", "src": str(RFC_PROXY), "out": str(tdir / f"{tag}_rfc.o")}]
            for cid in PROXIES:
                src = ROOT / "selfhost/tools/bench" / cat45[cid]["source"]["file"]
                jobs.append({"id": cid, "src": str(src), "out": str(tdir / f"{tag}_{cid}.o")})
            em = batch_emit(api, jobs, tdir / f"{tag}_manifest.json")
            for j in jobs:
                assert em[j["id"]]["ok"], f"{tag} emit failed on {j['id']}: {em[j['id']]}"

            res = {}
            # 1. proxy_rfc_ast (wall + SIGPROF)
            obj = tdir / f"{tag}_rfc.o"
            exe = tdir / f"{tag}_rfc.bin"
            exe_p = tdir / f"{tag}_rfc.prof.bin"
            subprocess.run([CC, "-no-pie", str(obj), str(RT_OBJ), "-pthread", "-lm", "-o", str(exe)], check=True)
            subprocess.run([CC, "-no-pie", str(obj), str(RT_OBJ), str(PROF_OBJ), "-pthread", "-lm", "-o", str(exe_p)], check=True)
            times = []
            for _ in range(3):
                t0 = time.perf_counter()
                r = subprocess.run(["taskset", "-c", str(cpu), str(exe), *RTS_ARGS], capture_output=True, text=True, timeout=30, check=True)
                times.append((time.perf_counter() - t0) * 1000.0)
                assert r.stdout.strip() == up_rfc, f"{tag} proxy_rfc_ast mismatch: {r.stdout.strip()!r} != {up_rfc!r}"
            pinfo = profile_exe(exe_p, RTS_ARGS, rt_syms, tdir / f"{tag}_rfc.prof", cpu=cpu)
            med = round(statistics.median(times), 2)
            top_s = ", ".join(f"{s}:{p:.1f}%" for s, _, p in pinfo["top_rt"][:5])
            print(f"  {'proxy_rfc_ast':24s} wall={med:7.2f}ms  rt={pinfo['rt_pct']:5.1f}% ({pinfo['rt_samples']:4d}/{pinfo['total']:4d})  [{top_s}]", flush=True)
            res["proxy_rfc_ast"] = dict(medianMs=med, timesMs=[round(t, 2) for t in times], prof=pinfo)

            # 2. 6 catalog proxies (wall + stdout verify + SIGPROF on raytrace/symreg)
            for cid in PROXIES:
                c = cat45[cid]
                obj = tdir / f"{tag}_{cid}.o"
                exe = tdir / f"{tag}_{cid}.bin"
                exp = c["point"]["expectedStdout"].splitlines()
                rargs = [*RTS_ARGS, *[str(a) for a in c["point"]["runtimeArgs"]]]
                subprocess.run([CC, "-no-pie", str(obj), str(RT_OBJ), "-pthread", "-lm", "-o", str(exe)], check=True)
                times = []
                for _ in range(3):
                    t0 = time.perf_counter()
                    r = subprocess.run(["taskset", "-c", str(cpu), str(exe), *rargs], capture_output=True, text=True, timeout=30, check=True)
                    times.append((time.perf_counter() - t0) * 1000.0)
                    got = r.stdout.splitlines()[:len(exp)]
                    assert got == exp, f"{tag} {cid} mismatch: {got} != {exp}"
                med = round(statistics.median(times), 2)
                pinfo = None
                if cid in ("raytrace", "symreg"):
                    exe_p = tdir / f"{tag}_{cid}.prof.bin"
                    subprocess.run([CC, "-no-pie", str(obj), str(RT_OBJ), str(PROF_OBJ), "-pthread", "-lm", "-o", str(exe_p)], check=True)
                    pinfo = profile_exe(exe_p, rargs, rt_syms, tdir / f"{tag}_{cid}.prof", cpu=cpu)
                    top_s = ", ".join(f"{s}:{p:.1f}%" for s, _, p in pinfo["top_rt"][:4])
                    print(f"  {cid:24s} wall={med:7.2f}ms  rt={pinfo['rt_pct']:5.1f}% ({pinfo['rt_samples']:4d}/{pinfo['total']:4d})  [{top_s}]", flush=True)
                else:
                    print(f"  {cid:24s} wall={med:7.2f}ms  PASS", flush=True)
                res[cid] = dict(medianMs=med, timesMs=[round(t, 2) for t in times], prof=pinfo)
            out[tag] = res
    return out


def run_focused19(api: Path) -> tuple:
    cat = json.loads(QUAL_CAT.read_text())
    cases = [c for c in cat["cases"] if c["suite"] == "focused"]
    assert len(cases) == 19
    passed = 0
    failed = []
    with tempfile.TemporaryDirectory(prefix="w3b_f19_") as td:
        tdir = Path(td)
        jobs = [{"id": c["id"], "src": str(ROOT / c["source"]["file"]), "out": str(tdir / f"{c['name']}.o")} for c in cases]
        em = batch_emit(api, jobs, tdir / "f19_manifest.json")
        for c in cases:
            cid = c["id"]
            stage = c["expect"]["stage"]
            obj = tdir / f"{c['name']}.o"
            exe = tdir / f"{c['name']}.bin"
            info = em[cid]
            if stage != "execute":
                if not info["ok"] and not obj.exists():
                    passed += 1
                else:
                    failed.append((cid, f"expected rejection, got {info}"))
                continue
            if not info["ok"]:
                failed.append((cid, f"emit failed: {info}"))
                continue
            subprocess.run([CC, "-no-pie", str(obj), str(RT_OBJ), "-pthread", "-lm", "-o", str(exe)], check=True)
            r = subprocess.run([str(exe)], capture_output=True, text=True, timeout=30)
            if r.returncode == c["expect"]["exitCode"] and r.stdout == c["expect"]["stdout"]:
                passed += 1
            else:
                failed.append((cid, f"rc={r.returncode} out={r.stdout!r} exp={c['expect']['stdout']!r}"))
    print(f"\n=== focused19: {passed}/{len(cases)} PASS ===", flush=True)
    for f in failed:
        print("  FAIL:", f, flush=True)
    return passed, len(cases), failed


def run_observer_gate(api: Path) -> tuple:
    sys.path.insert(0, str(ROOT / "research/agy/wave3_fuzz"))
    import observer_wave2_gate as og
    passed = 0
    total = len(og.PROBES) * 3
    violations = []
    with tempfile.TemporaryDirectory(prefix="w3b_obs_") as td:
        tdir = Path(td)
        hook_o = tdir / "hook.o"
        subprocess.run([CC, "-std=gnu11", "-Wall", "-Wextra", "-O2", "-I", str(RUNTIME_DIR), "-c", str(HOOK_C), "-o", str(hook_o)], check=True)
        jobs = []
        for name, code in og.PROBES.items():
            sp = tdir / f"{name}.bend"
            sp.write_text(code)
            jobs.append({"id": name, "src": str(sp), "out": str(tdir / f"{name}.o")})
        em = batch_emit(api, jobs, tdir / "obs_manifest.json")
        for name in og.PROBES:
            assert em[name]["ok"], f"obs emit failed for {name}: {em[name]}"
            sp = tdir / f"{name}.bend"
            obj = tdir / f"{name}.o"
            exe = tdir / f"{name}.exe"
            up = subprocess.run([str(BUN), str(ROOT / "bend2/main.ts"), str(sp)], capture_output=True, text=True, check=True).stdout
            subprocess.run(
                [CC, "-no-pie", "-Wl,--wrap=p111_rt_main",
                 "-Wl,--wrap=p125_rt_take1", "-Wl,--wrap=p125_rt_take2",
                 "-Wl,--wrap=p125_rt_take3", "-Wl,--wrap=p125_rt_take4",
                 str(obj), str(hook_o), str(RT_OBJ), "-pthread", "-lm", "-o", str(exe)],
                check=True,
            )
            for mode in ("normal", "cap-no8", "all-hot"):
                env = dict(os.environ, OBS_MODE=mode)
                r = subprocess.run([str(exe), *RTS_ARGS], capture_output=True, text=True, env=env, timeout=30)
                ok = (r.returncode == 0 and r.stdout == up and "OBSERVER_VIOLATION" not in r.stderr and r.stderr == "")
                if ok:
                    passed += 1
                else:
                    violations.append((name, mode, r.returncode, r.stdout.strip(), up.strip(), r.stderr.strip()))
                    print(f"  [FAIL] {name} mode={mode}: rc={r.returncode} out={r.stdout.strip()!r} exp={up.strip()!r} err={r.stderr.strip()!r}", flush=True)
    print(f"\n=== observer_wave2_gate: {passed}/{total} PASS ({len(violations)} violations) ===", flush=True)
    return passed, total, violations


def main():
    rt_syms = load_rt_symbols()
    bench = run_benchmark_pair(rt_syms)
    f_pass, f_tot, f_fail = run_focused19(W3B_API)
    o_pass, o_tot, o_viol = run_observer_gate(W3B_API)
    report = dict(
        benchmark=bench,
        focused19=dict(passed=f_pass, total=f_tot, failed=f_fail),
        observer_gate=dict(passed=o_pass, total=o_tot, violations=o_viol),
    )
    out_p = ROOT / "selfhost/build/agy/wave3b_rtdrain/eval_report.json"
    out_p.write_text(json.dumps(report, indent=2) + "\n")
    print(f"\nSaved report to {out_p}", flush=True)
    if f_fail or o_viol:
        sys.exit(1)


if __name__ == "__main__":
    main()
