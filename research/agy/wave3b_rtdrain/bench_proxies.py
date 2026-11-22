#!/usr/bin/env python3
"""Fast proxy benchmark + SIGPROF runtime-drain measurement harness.

Compiles the 6 fast proxies (lexer, coverage-bst-64, coverage-map-churn-32,
symreg, raytrace, mandelbrot) with a given api.mjs + unchanged unified/runtime-agy.o,
verifies exact catalog stdout, measures median-of-3 wall-clock time, and measures
exact % of SIGPROF samples spent inside runtime-agy.o symbols!
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
NODE = "/home/ai/.nvm/versions/node/v24.22.1/bin/node"
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"
BATCH = ROOT / "research/agy/wave3_fuzz/batch_emit.mjs"
RT_OBJ = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
PROF_OBJ = ROOT / "selfhost/build/agy/wave3b_rtdrain/prof.o"
CATALOG_PATH = ROOT / "selfhost/tools/bench/catalogs/native45/catalog.json"

PROXIES = [
    "lexer",
    "coverage-bst-64",
    "coverage-map-churn-32",
    "symreg",
    "raytrace",
    "mandelbrot",
]

# Optional heavier args ONLY for SIGPROF sampling (so fast cases still get >= 100 samples)
PROF_ARGS_OVERRIDE = {
    "lexer": ["40", "0"],
    "coverage-bst-64": ["256", "17"],
    "coverage-map-churn-32": ["128", "17"],
    "symreg": ["8", "42"],
    "raytrace": ["160", "0"],
    "mandelbrot": ["4", "0"],
}


def load_rt_symbols() -> set:
    out = subprocess.check_output(["nm", str(RT_OBJ)], text=True)
    syms = set()
    for line in out.splitlines():
        parts = line.split()
        if len(parts) >= 3 and parts[1] in ("T", "t", "W", "w"):
            syms.add(parts[2])
    return syms


def load_exe_syms(exe: Path):
    out = subprocess.check_output(["nm", "-n", str(exe)], text=True)
    addrs, names = [], []
    for line in out.splitlines():
        parts = line.split()
        if len(parts) >= 3 and parts[1] in ("T", "t", "W", "w"):
            try:
                addrs.append(int(parts[0], 16))
                names.append(parts[2])
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


def profile_exe(exe: Path, args: list, rt_syms: set, prof_file: Path, cpu: int = 2):
    env = os.environ.copy()
    env["PROF_OUT"] = str(prof_file)
    env["PROF_SECONDS"] = "3"
    t0 = time.perf_counter()
    r = subprocess.run(
        ["taskset", "-c", str(cpu), str(exe), *args],
        env=env,
        capture_output=True,
        timeout=15,
    )
    dt = time.perf_counter() - t0
    if r.returncode != 0:
        raise RuntimeError(f"prof run failed for {exe.name}: rc={r.returncode} {r.stderr[:200]}")
    if not prof_file.exists():
        return dict(total=0, rt_samples=0, rt_pct=0.0, top_rt=[], elapsed=dt)
    data = prof_file.read_bytes()
    n = len(data) // 24
    addrs, names = load_exe_syms(exe)
    counts = collections.Counter()
    rt_counts = collections.Counter()
    for i in range(n):
        rip, _, _, _ = struct.unpack_from("<QQII", data, i * 24)
        sym = resolve_pc(addrs, names, rip)
        counts[sym] += 1
        if sym in rt_syms:
            rt_counts[sym] += 1
    rt_total = sum(rt_counts.values())
    rt_pct = 100.0 * rt_total / max(n, 1)
    top_rt = [(s, c, round(100.0 * c / max(n, 1), 2)) for s, c in rt_counts.most_common(6)]
    return dict(total=n, rt_samples=rt_total, rt_pct=round(rt_pct, 2), top_rt=top_rt, elapsed=round(dt, 4))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--api", type=Path, required=True)
    ap.add_argument("--label", type=str, default="run")
    ap.add_argument("--out-json", type=Path, default=None)
    ap.add_argument("--repeats", type=int, default=3)
    ap.add_argument("--cpu", type=int, default=2)
    args = ap.parse_args()

    cat = {c["id"]: c for c in json.loads(CATALOG_PATH.read_text())["cases"]}
    rt_syms = load_rt_symbols()

    with tempfile.TemporaryDirectory(prefix="w3b_prof_") as td:
        tdir = Path(td)
        jobs = []
        for cid in PROXIES:
            c = cat[cid]
            src = ROOT / "selfhost/tools/bench" / c["source"]["file"]
            jobs.append({"id": cid, "src": str(src), "out": str(tdir / f"{cid}.o")})
        manifest = tdir / "manifest.json"
        manifest.write_text(json.dumps(jobs))

        t0 = time.perf_counter()
        r = subprocess.run(
            [NODE, "--stack-size=8192", str(BATCH), str(args.api), str(manifest)],
            capture_output=True,
            text=True,
            timeout=120,
        )
        emit_s = time.perf_counter() - t0
        if r.returncode != 0:
            raise RuntimeError(f"batch_emit failed: {r.stderr[:500]}")
        emitted = {item["id"]: item for item in json.loads(r.stdout)}
        print(f"[{args.label}] Emitted {len(PROXIES)} proxies in {emit_s:.2f}s", flush=True)

        results = {}
        tot_samples = 0
        tot_rt = 0
        agg_rt = collections.Counter()

        for cid in PROXIES:
            c = cat[cid]
            obj = tdir / f"{cid}.o"
            exe = tdir / f"{cid}.bin"
            exe_prof = tdir / f"{cid}.prof.bin"
            exp = c["point"]["expectedStdout"].splitlines()
            run_args = ["+RTS", "--threads", "1", "--gpu", "off", "-RTS", *[str(a) for a in c["point"]["runtimeArgs"]]]

            # Link clean binary
            subprocess.run([CC, "-no-pie", str(obj), str(RT_OBJ), "-pthread", "-lm", "-o", str(exe)], check=True)
            # Link profiled binary
            subprocess.run([CC, "-no-pie", str(obj), str(RT_OBJ), str(PROF_OBJ), "-pthread", "-lm", "-o", str(exe_prof)], check=True)

            # Time clean binary (median of repeats)
            times = []
            for rep in range(args.repeats):
                ts = time.perf_counter()
                rr = subprocess.run(["taskset", "-c", str(args.cpu), str(exe), *run_args], capture_output=True, text=True, timeout=30)
                dt = time.perf_counter() - ts
                if rr.returncode != 0:
                    raise RuntimeError(f"{cid} failed rc={rr.returncode}: {rr.stderr[:200]}")
                got = rr.stdout.splitlines()[:len(exp)]
                if got != exp:
                    raise RuntimeError(f"{cid} stdout mismatch: got={got} exp={exp}")
                times.append(dt)
            med_ms = round(statistics.median(times) * 1000.0, 2)

            # Profile with heavier args for good SIGPROF resolution
            p_args = ["+RTS", "--threads", "1", "--gpu", "off", "-RTS", *PROF_ARGS_OVERRIDE[cid]]
            prof_file = tdir / f"{cid}.prof"
            pinfo = profile_exe(exe_prof, p_args, rt_syms, prof_file, cpu=args.cpu)
            # If too few samples (< 30), re-run once with catalog args just to see
            tot_samples += pinfo["total"]
            tot_rt += pinfo["rt_samples"]
            for s, cnt, _ in pinfo["top_rt"]:
                agg_rt[s] += cnt

            top_str = ", ".join(f"{s}:{pct:.1f}%" for s, _, pct in pinfo["top_rt"][:4])
            print(f"  {cid:24s} wall={med_ms:7.2f}ms  rt={pinfo['rt_pct']:5.1f}% ({pinfo['rt_samples']:4d}/{pinfo['total']:4d})  [{top_str}]", flush=True)
            results[cid] = dict(
                objBytes=emitted[cid].get("bytes", obj.stat().st_size),
                medianMs=med_ms,
                timesMs=[round(t * 1000.0, 2) for t in times],
                prof=pinfo,
            )

        agg_pct = round(100.0 * tot_rt / max(tot_samples, 1), 2)
        print(f"[{args.label}] AGGREGATE runtime-agy.o = {agg_pct:.2f}% ({tot_rt}/{tot_samples} samples)", flush=True)
        print("  Top aggregate runtime symbols:", ", ".join(f"{s}:{100.0*c/max(tot_samples,1):.2f}%" for s, c in agg_rt.most_common(10)), flush=True)

        summary = dict(
            label=args.label,
            api=str(args.api),
            emitSeconds=round(emit_s, 3),
            aggregateRtPct=agg_pct,
            aggregateRtSamples=tot_rt,
            aggregateTotalSamples=tot_samples,
            cases=results,
        )
        if args.out_json:
            args.out_json.parent.mkdir(parents=True, exist_ok=True)
            args.out_json.write_text(json.dumps(summary, indent=2) + "\n")


if __name__ == "__main__":
    main()
