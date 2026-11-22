#!/usr/bin/env python3
"""Wave 5 Final Gate — Strictly Untouched 5-Program Holdout Transfer Test.

Benchmarks the 5 strictly untouched runtime benchmarks (NEVER inspected or tuned on
during Wave 5):
  - queens
  - terrain
  - tree-matmul
  - tree-radix
  - hashmap

Compares Handwritten C (gcc-10 -O3 -ffp-contract=off) vs Wave 2 vs Wave 4C vs Wave 5 Final
on CPU 2 with exact stdout verification and per-program compile + run timings.
"""
import argparse
import json
import math
import subprocess
import tempfile
import time
from pathlib import Path
from statistics import median

ROOT = Path("/home/ai/bend2_agy")
RT = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
LOCKED_NODE = str(ROOT / "research/agy/locked_node.sh")
BATCH_EMIT = str(ROOT / "research/agy/wave3_fuzz/batch_emit.mjs")
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"
RTS_ARGS = ["+RTS", "--threads", "1", "--gpu", "off", "-RTS"]

COMPILERS = [
    ("wave2", ROOT / "selfhost/build/agy/wave2_unified/api.mjs"),
    ("wave4c", ROOT / "selfhost/build/agy/wave4c_unified/api.mjs"),
    ("wave5", ROOT / "selfhost/build/agy/wave5c_unified/api.mjs"),
]

HOLDOUTS = ["queens", "terrain", "tree-matmul", "tree-radix", "hashmap"]


def run_timed(cmd, runs: int, timeout_s: int):
    times = []
    out = ""
    for _ in range(runs):
        t0 = time.monotonic()
        try:
            r = subprocess.run(
                ["flock", "/tmp/agy_cpu2_bench.lock", "taskset", "-c", "2", *cmd],
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
        if dt > 25.0:
            break  # 1 run is plenty for >25s runs
    return {"ok": True, "s": median(times), "runs": [round(x, 4) for x in times], "out": out}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--src-dir", type=Path, required=True, help="Directory containing {queens,terrain,tree-matmul,tree-radix,hashmap}/{main.bend,main.c}")
    ap.add_argument("--runs", type=int, default=3)
    ap.add_argument("--timeout", type=int, default=90)
    ap.add_argument("--out-json", type=Path, default=None)
    args = ap.parse_args()

    results = {}
    with tempfile.TemporaryDirectory() as td:
        td = Path(td)
        # 1. Build & time Handwritten C references
        c_refs = {}
        for name in HOLDOUTS:
            c_src = args.src_dir / name / "main.c"
            if not c_src.is_file():
                print(f"[SKIP] {name}: missing {c_src}")
                continue
            c_exe = td / f"{name}.c.bin"
            subprocess.run(
                [CC, "-O3", "-ffp-contract=off", str(c_src), "-lm", "-o", str(c_exe)],
                check=True,
            )
            c_res = run_timed([str(c_exe)], args.runs, args.timeout)
            c_refs[name] = c_res
            print(f"[C ref] {name:12s}: {c_res.get('s', -1):.4f}s  out={c_res.get('out', '')!r}", flush=True)

        # 2. Emit & time each Bend compiler across all 5 holdouts
        for cname, api in COMPILERS:
            jobs = []
            for name in HOLDOUTS:
                b_src = args.src_dir / name / "main.bend"
                if not b_src.is_file():
                    continue
                jobs.append({"id": name, "src": str(b_src), "out": str(td / f"{cname}_{name}.o")})
            jf = td / f"{cname}_jobs.json"
            jf.write_text(json.dumps(jobs))
            t_em = time.monotonic()
            r = subprocess.run(
                ["bash", LOCKED_NODE, BATCH_EMIT, str(api), str(jf)],
                capture_output=True,
                text=True,
            )
            emit_s = time.monotonic() - t_em
            if r.returncode != 0:
                print(f"[{cname}] BATCH EMIT FAILED: {r.stderr[-300:]}", flush=True)
                continue
            em_map = {x["id"]: x for x in json.loads(r.stdout)}
            print(f"\n[{cname}] batch emit 5 holdouts: {emit_s:.2f}s", flush=True)
            results[cname] = {"emit_s": round(emit_s, 3), "cases": {}}
            for name in HOLDOUTS:
                if name not in c_refs:
                    continue
                em = em_map.get(name, {})
                if not em.get("ok"):
                    print(f"  {name:12s}: EMIT ERR ({em.get('stage')}): {em.get('error', '')[:100]}", flush=True)
                    results[cname]["cases"][name] = {"ok": False, "error": f"emit: {em.get('error', '')[:120]}"}
                    continue
                obj = td / f"{cname}_{name}.o"
                exe = td / f"{cname}_{name}.bin"
                lr = subprocess.run([CC, "-no-pie", str(obj), str(RT), "-lm", "-lpthread", "-o", str(exe)], capture_output=True, text=True)
                if lr.returncode != 0:
                    print(f"  {name:12s}: LINK ERR: {lr.stderr[:100]}", flush=True)
                    results[cname]["cases"][name] = {"ok": False, "error": f"link: {lr.stderr[:120]}"}
                    continue
                res = run_timed([str(exe), *RTS_ARGS], args.runs, args.timeout)
                if res["ok"]:
                    match = (res["out"] == c_refs[name]["out"])
                    ratio = res["s"] / c_refs[name]["s"] if c_refs[name]["s"] > 0 else float("nan")
                    res["match"] = match
                    res["ratio_c"] = round(ratio, 3)
                    print(f"  {name:12s}: {res['s']:.4f}s ({ratio:.2f}x C) match={match} out={res['out']!r}", flush=True)
                else:
                    print(f"  {name:12s}: RUN FAIL: {res['error']}", flush=True)
                results[cname]["cases"][name] = res

    print("\n=== STRICTLY UNTOUCHED 5-PROGRAM HOLDOUT TRANSFER SUMMARY ===")
    print(f"{'Benchmark':<14} {'C (s)':>8} {'W2 (s)':>9} {'W4C (s)':>9} {'W5 (s)':>9} {'W5/C':>8} {'W2->W5':>8} {'W4C->W5':>8}")
    print("-" * 82)
    w2_w5, w4_w5, w5_c = [], [], []
    for name in HOLDOUTS:
        if name not in c_refs or not c_refs[name].get("ok"):
            continue
        cs = c_refs[name]["s"]
        w2 = results.get("wave2", {}).get("cases", {}).get(name, {})
        w4 = results.get("wave4c", {}).get("cases", {}).get(name, {})
        w5 = results.get("wave5", {}).get("cases", {}).get(name, {})
        def fmt(d):
            return f"{d['s']:.4f}" if d.get("ok") and d.get("match") else (d.get("error", "ERR")[:9])
        r_c = f"{w5['s']/cs:.2f}x" if (w5.get("ok") and w5.get("match")) else "-"
        r_2 = f"{w2['s']/w5['s']:.2f}x" if (w2.get("ok") and w2.get("match") and w5.get("ok") and w5.get("match")) else "-"
        r_4 = f"{w4['s']/w5['s']:.2f}x" if (w4.get("ok") and w4.get("match") and w5.get("ok") and w5.get("match")) else "-"
        if w5.get("ok") and w5.get("match"):
            w5_c.append(w5["s"] / cs)
            if w2.get("ok") and w2.get("match"):
                w2_w5.append(w2["s"] / w5["s"])
            if w4.get("ok") and w4.get("match"):
                w4_w5.append(w4["s"] / w5["s"])
        print(f"{name:<14} {cs:8.4f} {fmt(w2):>9} {fmt(w4):>9} {fmt(w5):>9} {r_c:>8} {r_2:>8} {r_4:>8}")
    print("-" * 82)
    def gm(xs): return math.exp(sum(math.log(x) for x in xs) / len(xs)) if xs else float("nan")
    print(f"Geomean W5/C: {gm(w5_c):.3f}x  |  Geomean W2->W5 speedup: {gm(w2_w5):.3f}x  |  Geomean W4C->W5 speedup: {gm(w4_w5):.3f}x")
    print(f"Compile 5 holdouts: W2={results.get('wave2',{}).get('emit_s')}s  W4C={results.get('wave4c',{}).get('emit_s')}s  W5={results.get('wave5',{}).get('emit_s')}s")

    if args.out_json:
        args.out_json.parent.mkdir(parents=True, exist_ok=True)
        args.out_json.write_text(json.dumps({"c_refs": c_refs, "compilers": results}, indent=2) + "\n")


if __name__ == "__main__":
    main()
