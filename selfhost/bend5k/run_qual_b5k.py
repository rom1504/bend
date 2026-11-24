#!/usr/bin/env python3
"""Run the 64-case Phase182 qualification catalog (-O0) through bend5k."""
import argparse
import collections
import json
import os
import subprocess
import sys
import time
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
CATALOG = ROOT / "selfhost/tests/phase182/qualification-catalog.json"
RT_OBJ = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"


def classify_compile_err(stderr: str) -> str:
    s = stderr.strip()
    if "memory fault" in s.lower() or "stack overflow" in s.lower():
        return "compile_stack_overflow"
    if "lex" in s.lower() or "unterminated" in s.lower():
        return "lex"
    if s.startswith("check:") or s.startswith("compile:"):
        return "check"
    if "lower" in s.lower():
        return "lower"
    return "parse"


def run_case(b5k: Path, work_dir: Path, case: dict, timeout: int) -> dict:
    cid = case["id"]
    src = ROOT / case["source"]["file"]
    expect = case["expect"]
    stage = expect["stage"]
    safe = cid.replace("/", "__")
    obj = work_dir / f"{safe}.o"
    exe = work_dir / f"{safe}.exe"

    def cleanup():
        for p in (obj, exe):
            if p.exists():
                p.unlink()

    cleanup()
    t0 = time.perf_counter()
    try:
        rcmp = subprocess.run(
            [str(b5k), str(src), str(obj)],
            capture_output=True,
            text=True,
            timeout=timeout,
        )
    except subprocess.TimeoutExpired:
        cleanup()
        return {"id": cid, "status": "FAIL", "cat": "compile_timeout", "detail": f"timeout>{timeout}s", "ms": int((time.perf_counter() - t0) * 1000)}

    if stage in ("source-admission", "backend-admission"):
        ok = (rcmp.returncode != 0) and (not obj.exists())
        cleanup()
        if ok:
            return {"id": cid, "status": "PASS", "cat": "pass_reject", "detail": rcmp.stderr.strip()[:120], "ms": int((time.perf_counter() - t0) * 1000)}
        return {"id": cid, "status": "FAIL", "cat": "check_accept_bad", "detail": f"expected reject, rc={rcmp.returncode}", "ms": int((time.perf_counter() - t0) * 1000)}

    if rcmp.returncode != 0 or not obj.exists():
        cat = classify_compile_err(rcmp.stderr)
        detail = (rcmp.stderr.strip() or rcmp.stdout.strip() or f"rc={rcmp.returncode}")[:140]
        cleanup()
        return {"id": cid, "status": "FAIL", "cat": cat, "detail": detail, "ms": int((time.perf_counter() - t0) * 1000)}

    try:
        rlnk = subprocess.run(
            [CC, "-no-pie", str(obj), str(RT_OBJ), "-pthread", "-lm", "-o", str(exe)],
            capture_output=True,
            text=True,
            timeout=timeout,
        )
    except subprocess.TimeoutExpired:
        cleanup()
        return {"id": cid, "status": "FAIL", "cat": "link_timeout", "detail": "gcc timeout", "ms": int((time.perf_counter() - t0) * 1000)}

    if rlnk.returncode != 0:
        detail = rlnk.stderr.strip().splitlines()[0][:140] if rlnk.stderr.strip() else f"rc={rlnk.returncode}"
        cleanup()
        return {"id": cid, "status": "FAIL", "cat": "x64_elf_link", "detail": detail, "ms": int((time.perf_counter() - t0) * 1000)}

    try:
        rrun = subprocess.run(
            [str(exe)],
            capture_output=True,
            text=True,
            timeout=timeout,
        )
    except subprocess.TimeoutExpired:
        cleanup()
        return {"id": cid, "status": "FAIL", "cat": "runtime_timeout", "detail": f"exec timeout>{timeout}s", "ms": int((time.perf_counter() - t0) * 1000)}

    cleanup()
    exp_rc = expect.get("exitCode", 0)
    exp_out = expect.get("stdout", "")
    if rrun.returncode == exp_rc and rrun.stdout == exp_out:
        return {"id": cid, "status": "PASS", "cat": "pass_exec", "detail": "", "ms": int((time.perf_counter() - t0) * 1000)}
    if rrun.returncode != exp_rc:
        cat = "runtime_crash" if rrun.returncode < 0 else "runtime_err"
        detail = f"rc={rrun.returncode} stderr={rrun.stderr.strip()[:100]!r} stdout={rrun.stdout[:60]!r}"
    else:
        cat = "runtime_wrong_out"
        detail = f"got={rrun.stdout[:80]!r} exp={exp_out[:80]!r}"
    return {"id": cid, "status": "FAIL", "cat": cat, "detail": detail, "ms": int((time.perf_counter() - t0) * 1000)}


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--bend5k", type=Path, default=Path("/tmp/agy_b5k_m1/bend5k"))
    ap.add_argument("--work-dir", type=Path, default=Path("/tmp/agy_b5k_m1/qual"))
    ap.add_argument("--timeout", type=int, default=15)
    ap.add_argument("--json-out", type=Path, default=None)
    args = ap.parse_args()

    args.work_dir.mkdir(parents=True, exist_ok=True)
    data = json.loads(CATALOG.read_text(encoding="utf-8"))
    cases = data["cases"]
    results = []
    cats = collections.Counter()
    passed = 0

    t_all = time.perf_counter()
    for c in cases:
        res = run_case(args.bend5k, args.work_dir, c, args.timeout)
        results.append(res)
        cats[res["cat"]] += 1
        if res["status"] == "PASS":
            passed += 1
        mark = "PASS" if res["status"] == "PASS" else f"FAIL[{res['cat']}]"
        print(f"{mark:24s} {res['id']:38s} {res['ms']:4d}ms  {res['detail']}", flush=True)

    dt = time.perf_counter() - t_all
    print(f"\n=== SUMMARY: PASS {passed} / {len(cases)} ({dt:.2f}s) ===", flush=True)
    for k, v in cats.most_common():
        print(f"  {k:22s}: {v}", flush=True)

    if args.json_out:
        args.json_out.write_text(json.dumps({"passed": passed, "total": len(cases), "cats": dict(cats), "results": results}, indent=2))
    return 0


if __name__ == "__main__":
    sys.exit(main())
