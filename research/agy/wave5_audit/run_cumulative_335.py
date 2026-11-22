#!/usr/bin/env python3
"""Run all 335 cumulative Wave 3 (245) + Wave 4 (90) differential fuzz tests
against `wave5a_unified/api.mjs` vs upstream `bun bend2/main.ts` (pinned to CPUs 0,1,4,5).
"""
from __future__ import annotations
import hashlib
import importlib.util
import json
import random
import subprocess
import sys
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
LOCKED_BUN = ROOT / "research/agy/locked_bun.sh"
LOCKED_NODE = ROOT / "research/agy/locked_node.sh"
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"
BATCH_EMIT = ROOT / "research/agy/wave3_fuzz/batch_emit.mjs"
W5A_API = ROOT / "selfhost/build/agy/wave5a_unified/api.mjs"
W2_API = ROOT / "selfhost/build/agy/wave2_unified/api.mjs"
AGY_RT = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
WORK_DIR = ROOT / "selfhost/build/agy/wave5_fuzz/cum335_tmp"
RTS_ARGS = ["+RTS", "--threads", "1", "--gpu", "off", "-RTS"]
CPU_PIN = ["taskset", "-c", "0,1,4,5"]


def load_mod(name: str, path: Path):
    spec = importlib.util.spec_from_file_location(name, path)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def run_upstream(src: Path) -> tuple[bool, str]:
    try:
        r = subprocess.run(
            [*CPU_PIN, "bash", str(LOCKED_BUN), str(src)],
            capture_output=True, text=True, timeout=65,
        )
        if r.returncode != 0:
            return False, f"UP_ERR({r.returncode}): {r.stderr.strip()[:240]}"
        return True, r.stdout
    except subprocess.TimeoutExpired:
        return False, "UP_TIMEOUT"


def batch_emit(api: Path, jobs: list, manifest: Path) -> dict:
    manifest.write_text(json.dumps(jobs))
    r = subprocess.run(
        [*CPU_PIN, "bash", str(LOCKED_NODE), "--stack-size=8192", str(BATCH_EMIT), str(api), str(manifest)],
        capture_output=True, text=True, timeout=900,
    )
    if r.returncode != 0:
        raise RuntimeError(f"batch_emit failed rc={r.returncode}: {r.stderr[:400]}")
    return {item["id"]: item for item in json.loads(r.stdout)}


def link_run_cleanup(obj: Path, rt: Path, exe: Path) -> tuple[bool, str]:
    try:
        r_cc = subprocess.run(
            [*CPU_PIN, CC, "-no-pie", str(obj), str(rt), "-pthread", "-lm", "-o", str(exe)],
            capture_output=True, text=True, timeout=30,
        )
        if r_cc.returncode != 0:
            return False, f"LINK_ERR: {r_cc.stderr.strip()[:240]}"
        try:
            r_run = subprocess.run(
                [*CPU_PIN, str(exe), *RTS_ARGS],
                capture_output=True, text=True, timeout=30,
            )
            if r_run.returncode != 0:
                return False, f"RUN_ERR({r_run.returncode}): {r_run.stderr.strip()[:200]}"
            if r_run.stderr:
                return False, f"RUN_STDERR: {r_run.stderr.strip()[:200]}"
            return True, r_run.stdout
        except subprocess.TimeoutExpired:
            return False, "RUN_TIMEOUT"
    finally:
        obj.unlink(missing_ok=True)
        exe.unlink(missing_ok=True)


def main():
    t0 = time.perf_counter()
    w3 = load_mod("w3_fuzz", ROOT / "research/agy/wave3_fuzz/fuzz_diff.py")
    w4 = load_mod("w4_fuzz", ROOT / "research/agy/wave4_fuzz/fuzz_wave4.py")

    WORK_DIR.mkdir(parents=True, exist_ok=True)
    src_dir = WORK_DIR / "src"
    obj_dir = WORK_DIR / "obj"
    exe_dir = WORK_DIR / "exe"
    for d in (src_dir, obj_dir, exe_dir):
        d.mkdir(parents=True, exist_ok=True)

    suites = [
        ("w3", w3.FAMILIES, 20261122, 35),
        ("w4", w4.FAMILIES, 2026112204, 30),
    ]
    cases = []
    seen = set()
    for tag, families, seed, per_fam in suites:
        for f_idx, (fname, gen_fn) in enumerate(families):
            fam_rng = random.Random(seed + f_idx * 100003)
            generated = 0
            attempt = 0
            while generated < per_fam and attempt < per_fam * 5:
                attempt += 1
                code = gen_fn(fam_rng, generated)
                h = hashlib.sha256(code.encode("utf-8")).hexdigest()[:16]
                if h in seen:
                    continue
                seen.add(h)
                cid = f"{fname}__{generated:03d}"
                sp = src_dir / f"{cid}.bend"
                sp.write_text(code)
                cases.append({
                    "id": cid,
                    "family": fname,
                    "src": sp,
                    "obj": obj_dir / f"{cid}.o",
                    "exe": exe_dir / f"{cid}.exe",
                })
                generated += 1

    print(f"Generated {len(cases)} cumulative Wave 3+4 programs (target 335)", flush=True)

    t_emit = time.perf_counter()
    jobs = [{"id": c["id"], "src": str(c["src"]), "out": str(c["obj"])} for c in cases]
    w2_jobs = [{"id": c["id"], "src": str(c["src"]), "out": str(obj_dir / f"{c['id']}.w2.o")} for c in cases]
    emitted = batch_emit(W5A_API, jobs, WORK_DIR / "cum335_w5_manifest.json")
    w2_emitted = batch_emit(W2_API, w2_jobs, WORK_DIR / "cum335_w2_manifest.json")
    emit_sec = round(time.perf_counter() - t_emit, 2)
    print(f"Wave 5A + Wave 2 oracle batch emit (335 cases) finished in {emit_sec:.2f}s", flush=True)

    t_exec = time.perf_counter()
    up_results = {}
    with ThreadPoolExecutor(max_workers=4) as ex:
        futs = {}
        for c in cases:
            cid = c["id"]
            em = w2_emitted[cid]
            o2 = obj_dir / f"{cid}.w2.o"
            if not em["ok"]:
                up_results[cid] = (False, f"W2_{em['stage'].upper()}_ERR: {em['error'][:240]}")
                o2.unlink(missing_ok=True)
            else:
                futs[ex.submit(link_run_cleanup, o2, AGY_RT, exe_dir / f"{cid}.w2.exe")] = cid
        for fut in as_completed(futs):
            up_results[futs[fut]] = fut.result()
    run_results = {}
    with ThreadPoolExecutor(max_workers=4) as ex:
        futs = {}
        for c in cases:
            cid = c["id"]
            em = emitted[cid]
            if not em["ok"]:
                run_results[cid] = (False, f"W5A_{em['stage'].upper()}_ERR: {em['error'][:240]}")
                c["obj"].unlink(missing_ok=True)
            else:
                futs[ex.submit(link_run_cleanup, c["obj"], AGY_RT, c["exe"])] = cid
        for fut in as_completed(futs):
            run_results[futs[fut]] = fut.result()
    exec_sec = round(time.perf_counter() - t_exec, 2)
    print(f"Wave 5A link + exec finished in {exec_sec:.2f}s", flush=True)

    family_stats = {}
    mismatches = []
    for c in cases:
        cid = c["id"]
        fn = c["family"]
        family_stats.setdefault(fn, {"total": 0, "pass": 0, "fail": 0, "up_err": 0})
        family_stats[fn]["total"] += 1
        up_ok, up_out = up_results[cid]
        w5_ok, w5_out = run_results[cid]
        if not up_ok:
            family_stats[fn]["up_err"] += 1
            mismatches.append({"id": cid, "family": fn, "kind": "upstream_error", "up": up_out, "w5a": w5_out, "src": str(c["src"])})
        elif w5_ok and up_out == w5_out:
            family_stats[fn]["pass"] += 1
            c["src"].unlink(missing_ok=True)
        else:
            family_stats[fn]["fail"] += 1
            mismatches.append({"id": cid, "family": fn, "kind": "mismatch", "up": up_out, "w5a": w5_out, "src": str(c["src"])})

    total_sec = round(time.perf_counter() - t0, 2)
    total_pass = sum(s["pass"] for s in family_stats.values())
    total_all = sum(s["total"] for s in family_stats.values())
    total_fail = sum(s["fail"] for s in family_stats.values())
    total_up = sum(s["up_err"] for s in family_stats.values())

    print("\n=== WAVE 5A CUMULATIVE 335 NON-REGRESSION SUMMARY ===")
    for fn, st in family_stats.items():
        print(f"  {fn:24s}: {st['pass']:3d}/{st['total']:3d} PASS (fail={st['fail']}, up_err={st['up_err']})")
    print(f"  TOTAL                   : {total_pass:3d}/{total_all:3d} PASS (fail={total_fail}, up_err={total_up}) in {total_sec:.2f}s")
    for m in mismatches[:10]:
        print(f"  FAIL {m['id']} ({m['kind']}): up={m['up'].strip()[:120]!r} | w5a={m['w5a'].strip()[:120]!r}", flush=True)

    out = ROOT / "experiments/agy/receipts/wave5-cum335-report.json"
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps({
        "total": total_all, "pass": total_pass, "fail": total_fail, "up_err": total_up,
        "emit_sec": emit_sec, "exec_sec": exec_sec, "total_sec": total_sec,
        "families": family_stats, "mismatches": mismatches,
    }, indent=2) + "\n")
    sys.exit(0 if (total_fail == 0 and total_up == 0) else 1)


if __name__ == "__main__":
    main()
