#!/usr/bin/env python3
"""Wave 6 Multi-Core Native Sharded Compiler Driver.

Drives a self-hosted native Bend compiler binary (e.g. Wave 5 `n2`) across K
parallel worker processes pinned to dedicated CPUs (default `0,1,4,5`), emits
`shard_0.o .. shard_{K-1}.o` in parallel, and links them with `runtime-agy.o`
into a single native x86-64 executable.

Works drop-in with unmodified Wave 5 native binaries (`x86-object ... [SHARD SHARDS]`)
and also supports the weight-balanced LPT native shard subcommand (`x86-shard`)
added by `apply_native_shard.py`.

Usage:
  python3 -B research/agy/wave6_native_par/native_par_compile.py \
      --native selfhost/build/agy/wave5-native-self/n2 \
      --shards 4 \
      --mode cache \
      --cpus 0,1,4,5 \
      --src research/agy/wave4_bench/inputs/upstream/gameoflife/main.bend \
      --out /tmp/agy_w6_native_par/gameoflife
"""
from __future__ import annotations
import argparse
import json
import os
import subprocess
import sys
import tempfile
import time
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"
DEFAULT_RT = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
DEFAULT_BASE = ROOT / "selfhost/dist/base.bend"
DEFAULT_CARRIER = ROOT / "selfhost/build/agy/bootstrap/base.p130"
DEFAULT_STAMP = (
    "p130-word-pair-v1:p88-private-base-text-1:"
    "2dd93239749b4f1e3ee2f4e9617e31aeb5df4cc0200a4c14054a6591e2f74212"
)
DEFAULT_CPUS = [0, 1, 4, 5]


def run_native_worker(
    compiler: Path,
    src: Path,
    obj: Path,
    shard: int,
    shards: int,
    cpu: int,
    mode: str,
    base: Path,
    carrier: Path,
    stamp: str,
    strategy: str,
    timeout: int = 900,
) -> dict:
    t0 = time.perf_counter()
    if shards <= 1:
        subcmd = "x86-object"
    elif strategy == "lpt":
        subcmd = "x86-shard"
    else:
        subcmd = "x86-object"

    if mode == "cache":
        req_args = [subcmd, str(src), str(base), "cache", str(carrier), stamp]
    elif mode == "live":
        req_args = [subcmd, str(src), str(base), "live", "", ""]
    else:
        raise ValueError(f"Unsupported mode: {mode}")

    if shards > 1:
        req_args.extend([str(shard), str(shards)])

    cmd = [
        "taskset", "-c", str(cpu),
        str(compiler),
        "+RTS", "--threads", "1", "--gpu", "off", "-RTS",
        "--RTS",
        *req_args,
    ]
    with obj.open("wb") as fout:
        r = subprocess.run(cmd, stdout=fout, stderr=subprocess.PIPE, timeout=timeout)
    dt = time.perf_counter() - t0
    if r.returncode != 0:
        err = r.stderr.decode(errors="replace")[:600]
        raise RuntimeError(
            f"native worker shard {shard}/{shards} ({subcmd}, {mode}, cpu={cpu}) "
            f"failed (rc={r.returncode}): {err}"
        )
    sz = obj.stat().st_size
    if sz < 64:
        raise RuntimeError(
            f"native worker shard {shard}/{shards} produced tiny object ({sz}B)"
        )
    return {
        "shard": shard,
        "shards": shards,
        "subcmd": subcmd,
        "cpu": cpu,
        "bytes": sz,
        "wallSec": round(dt, 4),
    }


def compile_native_sharded(
    compiler: Path,
    src: Path,
    out_exe: Path | None,
    shards: int = 4,
    mode: str = "cache",
    strategy: str = "rr",
    cpus: list[int] | None = None,
    rt: Path = DEFAULT_RT,
    base: Path = DEFAULT_BASE,
    carrier: Path = DEFAULT_CARRIER,
    stamp: str = DEFAULT_STAMP,
    work_dir: Path | None = None,
    no_link: bool = False,
    timeout: int = 900,
    max_concurrent: int | None = None,
) -> dict:
    compiler = compiler.resolve()
    src = src.resolve()
    rt = rt.resolve()
    base = base.resolve()
    carrier = carrier.resolve()
    if out_exe is not None:
        out_exe = out_exe.resolve()

    # RAM-safe concurrency cap: for huge files (>= 500 KB, e.g. compiler.bend),
    # default to at most 2 concurrent native workers so RSS stays bounded.
    if max_concurrent is None:
        max_concurrent = min(shards, 2) if src.stat().st_size >= 500_000 else shards
    max_concurrent = max(1, min(max_concurrent, shards))

    cpu_list = cpus if cpus else DEFAULT_CPUS
    t0 = time.perf_counter()
    cleanup = None
    if work_dir is None:
        cleanup = tempfile.TemporaryDirectory(prefix="agy_w6_par_", dir="/tmp/agy_w6_native_par")
        wd = Path(cleanup.name)
    else:
        wd = work_dir.resolve()
        wd.mkdir(parents=True, exist_ok=True)

    try:
        objs = [wd / f"shard_{k}.o" for k in range(shards)]
        t_emit0 = time.perf_counter()
        if shards == 1:
            workers = [
                run_native_worker(
                    compiler, src, objs[0], 0, 1, cpu_list[0],
                    mode, base, carrier, stamp, strategy, timeout,
                )
            ]
        else:
            with ThreadPoolExecutor(max_workers=max_concurrent) as ex:
                futs = [
                    ex.submit(
                        run_native_worker,
                        compiler, src, objs[k], k, shards,
                        cpu_list[k % len(cpu_list)],
                        mode, base, carrier, stamp, strategy, timeout,
                    )
                    for k in range(shards)
                ]
                workers = [f.result() for f in futs]
        t_emit1 = time.perf_counter()

        link_sec = 0.0
        exe_bytes = 0
        if not no_link and out_exe is not None:
            t_link0 = time.perf_counter()
            out_exe.parent.mkdir(parents=True, exist_ok=True)
            link_cmd = (
                [CC, "-no-pie"]
                + [str(o) for o in objs]
                + [str(rt), "-pthread", "-lm", "-o", str(out_exe)]
            )
            r_link = subprocess.run(link_cmd, capture_output=True, text=True, timeout=120)
            link_sec = time.perf_counter() - t_link0
            if r_link.returncode != 0:
                raise RuntimeError(f"link failed: {r_link.stderr[:600]}")
            exe_bytes = out_exe.stat().st_size

        t_end = time.perf_counter()
        w_times = [w["wallSec"] for w in workers]
        avg_w = sum(w_times) / len(w_times)
        max_w = max(w_times)
        return {
            "compiler": str(compiler),
            "src": str(src),
            "out": str(out_exe) if out_exe else None,
            "mode": mode,
            "strategy": strategy if shards > 1 else "single",
            "shards": shards,
            "cpus": cpu_list[:shards],
            "emitWallSec": round(t_emit1 - t_emit0, 4),
            "linkSec": round(link_sec, 4),
            "totalWallSec": round(t_end - t0, 4),
            "totalObjBytes": sum(w["bytes"] for w in workers),
            "exeBytes": exe_bytes,
            "workerMaxSec": round(max_w, 4),
            "workerAvgSec": round(avg_w, 4),
            "imbalanceRatio": round(max_w / avg_w, 3) if avg_w > 0 else 1.0,
            "workers": workers,
        }
    finally:
        if cleanup is not None:
            cleanup.cleanup()


def main() -> None:
    ap = argparse.ArgumentParser(description="Multi-Core Native Sharded Bend Compiler Driver")
    ap.add_argument("--native", type=Path, required=True, help="Path to native compiler binary (e.g. n2)")
    ap.add_argument("--src", type=Path, required=True, help="Input .bend file")
    ap.add_argument("--out", type=Path, default=None, help="Output native executable path")
    ap.add_argument("--shards", type=int, default=4, help="Number of parallel shards (1..16)")
    ap.add_argument("--mode", choices=["cache", "live"], default="cache", help="Base loading mode")
    ap.add_argument("--strategy", choices=["rr", "lpt"], default="rr", help="Sharding strategy (rr=x86-object, lpt=x86-shard)")
    ap.add_argument("--cpus", type=str, default="0,1,4,5", help="Comma-separated CPU affinity list")
    ap.add_argument("--rt", type=Path, default=DEFAULT_RT, help="Path to runtime-agy.o")
    ap.add_argument("--base", type=Path, default=DEFAULT_BASE, help="Path to base.bend")
    ap.add_argument("--carrier", type=Path, default=DEFAULT_CARRIER, help="Path to base.p130 carrier")
    ap.add_argument("--stamp", type=str, default=DEFAULT_STAMP, help="Carrier stamp")
    ap.add_argument("--work-dir", type=Path, default=None, help="Optional persistent directory for shard .o files")
    ap.add_argument("--no-link", action="store_true", help="Emit shard .o files only, skip gcc link")
    ap.add_argument("--max-concurrent", type=int, default=None, help="Max concurrent workers (auto-capped to 2 for >=500KB inputs)")
    ap.add_argument("--timeout", type=int, default=900, help="Per-worker timeout in seconds")
    args = ap.parse_args()

    if args.shards < 1 or args.shards > 16:
        ap.error("--shards must be between 1 and 16")
    if not args.no_link and args.out is None:
        ap.error("Specify --out or --no-link")

    cpus = [int(x.strip()) for x in args.cpus.split(",") if x.strip()]
    Path("/tmp/agy_w6_native_par").mkdir(parents=True, exist_ok=True)
    res = compile_native_sharded(
        compiler=args.native,
        src=args.src,
        out_exe=args.out,
        shards=args.shards,
        mode=args.mode,
        strategy=args.strategy,
        cpus=cpus,
        rt=args.rt,
        base=args.base,
        carrier=args.carrier,
        stamp=args.stamp,
        work_dir=args.work_dir,
        no_link=args.no_link,
        timeout=args.timeout,
        max_concurrent=args.max_concurrent,
    )
    print(json.dumps(res, indent=2))


if __name__ == "__main__":
    main()
