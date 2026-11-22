#!/usr/bin/env python3
"""Evaluate Wave 5C vs candidate api.mjs on the 5 blind holdouts, pinned to CPU 4."""
import argparse
import json
import math
import subprocess
import time
from pathlib import Path
from statistics import median

ROOT = Path("/home/ai/bend2_agy")
RT = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
LOCKED_NODE = str(ROOT / "research/agy/locked_node.sh")
BATCH_EMIT = str(ROOT / "research/agy/wave3_fuzz/batch_emit.mjs")
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"
RTS_ARGS = ["+RTS", "--threads", "1", "--gpu", "off", "-RTS"]

HOLDOUTS = ["queens", "terrain", "tree-matmul", "tree-radix", "hashmap"]
EXPECTED = {
    "queens": "2063750025",
    "terrain": "2572468224",
    "tree-matmul": "3797651056",
    "tree-radix": "1998173798",
    "hashmap": "1307803744",
}


def run_timed(cmd, cpu: int, runs: int, timeout_s: int):
    times = []
    out = ""
    for _ in range(runs):
        t0 = time.monotonic()
        try:
            r = subprocess.run(
                ["taskset", "-c", str(cpu), *cmd],
                capture_output=True,
                text=True,
                timeout=timeout_s,
            )
        except subprocess.TimeoutExpired:
            return {"ok": False, "error": f"TIMEOUT>{timeout_s}s"}
        dt = time.monotonic() - t0
        if r.returncode != 0:
            return {"ok": False, "error": f"rc={r.returncode}: {r.stderr[:120]}"}
        out = r.stdout.strip()
        times.append(dt)
        if dt > 20.0:
            break
    return {"ok": True, "s": median(times), "runs": [round(x, 4) for x in times], "out": out}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--api", type=Path, required=True)
    ap.add_argument("--tag", type=str, default="cand")
    ap.add_argument("--cpu", type=int, default=4)
    ap.add_argument("--runs", type=int, default=3)
    ap.add_argument("--timeout", type=int, default=90)
    ap.add_argument("--only", type=str, default="")
    ap.add_argument("--out-dir", type=Path, default=Path("/tmp/agy_w6_holdouts"))
    args = ap.parse_args()

    names = [x.strip() for x in args.only.split(",") if x.strip()] if args.only else HOLDOUTS
    args.out_dir.mkdir(parents=True, exist_ok=True)

    jobs = [
        {"id": n, "src": str(ROOT / "bench/runtime" / n / "main.bend"), "out": str(args.out_dir / f"{args.tag}_{n}.o")}
        for n in names
    ]
    jf = args.out_dir / f"{args.tag}_jobs.json"
    jf.write_text(json.dumps(jobs))

    t0 = time.monotonic()
    r = subprocess.run(
        ["bash", LOCKED_NODE, BATCH_EMIT, str(args.api), str(jf)],
        capture_output=True,
        text=True,
    )
    emit_s = time.monotonic() - t0
    if r.returncode != 0:
        print(f"[{args.tag}] EMIT FAILED: {r.stderr[-400:]}")
        raise SystemExit(1)
    em_map = {x["id"]: x for x in json.loads(r.stdout)}
    print(f"[{args.tag}] batch emit {len(names)} holdouts: {emit_s:.2f}s", flush=True)

    res_all = {"tag": args.tag, "emit_s": round(emit_s, 3), "cases": {}}
    for n in names:
        em = em_map[n]
        if not em.get("ok"):
            print(f"  {n:12s}: EMIT ERR: {em.get('error', '')[:120]}", flush=True)
            res_all["cases"][n] = {"ok": False, "error": em.get("error", "")[:120]}
            continue
        obj = args.out_dir / f"{args.tag}_{n}.o"
        exe = args.out_dir / f"{args.tag}_{n}.bin"
        lr = subprocess.run([CC, "-no-pie", str(obj), str(RT), "-lm", "-lpthread", "-o", str(exe)], capture_output=True, text=True)
        if lr.returncode != 0:
            print(f"  {n:12s}: LINK ERR: {lr.stderr[:120]}", flush=True)
            res_all["cases"][n] = {"ok": False, "error": lr.stderr[:120]}
            continue
        res = run_timed([str(exe), *RTS_ARGS], args.cpu, args.runs, args.timeout)
        if res["ok"]:
            res["match"] = (res["out"] == EXPECTED[n])
            print(f"  {n:12s}: {res['s']:.4f}s  runs={res['runs']}  match={res['match']}  out={res['out']!r}", flush=True)
        else:
            print(f"  {n:12s}: FAIL {res['error']}", flush=True)
        res_all["cases"][n] = res
    print(json.dumps(res_all, indent=2))


if __name__ == "__main__":
    main()
