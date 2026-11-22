#!/usr/bin/env python3
"""Parallel Sharded x86 Codegen Driver (Wave 3B Track B3).

Spawns N parallel workers (pinned to safe CPUs avoiding CPU 3 & 7), emits
shard_0.o .. shard_{N-1}.o, and links them with runtime-agy.o into a single
native x86-64 executable.

Supports both:
  - Hosted JS/Bun API (`--api <api.mjs>`)
  - Native compiler binary (`--native <bin>`)

Usage:
  python3 -B research/agy/wave3b_parcg/par_compile.py \
      --api selfhost/build/agy/wave3b_parcg/api.mjs \
      --shards 4 \
      --src <input.bend> \
      --out <exe> \
      [--rt selfhost/build/agy/unified/runtime-agy.o] \
      [--work-dir <dir>]
"""
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
BUN = ROOT / "selfhost/.assets/bin/bun"
EMIT_SHARD = ROOT / "research/agy/wave3b_parcg/emit_shard.mjs"
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"
DEFAULT_RT = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
BASE = ROOT / "selfhost/dist/base.bend"
SAFE_CPUS = [0, 1, 2, 4, 5, 6]


def run_worker_api(api: Path, src: Path, obj: Path, shard: int, shards: int, cpu: int) -> dict:
    t0 = time.perf_counter()
    r = subprocess.run(
        ["taskset", "-c", str(cpu), str(BUN), str(EMIT_SHARD),
         str(api), str(src), str(obj), str(shard), str(shards)],
        capture_output=True, text=True, timeout=300,
    )
    dt = time.perf_counter() - t0
    if r.returncode != 0:
        raise RuntimeError(f"shard {shard}/{shards} failed (rc={r.returncode}): {r.stderr[:400]}")
    info = json.loads(r.stdout.strip().splitlines()[-1])
    info["wallSec"] = round(dt, 3)
    info["cpu"] = cpu
    return info


def run_worker_native(compiler: Path, src: Path, obj: Path, shard: int, shards: int, cpu: int) -> dict:
    t0 = time.perf_counter()
    cmd = ["taskset", "-c", str(cpu), str(compiler),
           "+RTS", "--threads", "1", "--gpu", "off", "-RTS",
           "--RTS", "x86-object", str(src), str(BASE), "live", "", ""]
    if shards > 1:
        cmd.extend([str(shard), str(shards)])
    with obj.open("wb") as fout:
        r = subprocess.run(cmd, stdout=fout, stderr=subprocess.PIPE, timeout=600)
    dt = time.perf_counter() - t0
    if r.returncode != 0:
        raise RuntimeError(f"native shard {shard}/{shards} failed (rc={r.returncode}): {r.stderr.decode(errors='replace')[:400]}")
    sz = obj.stat().st_size
    if sz < 64:
        raise RuntimeError(f"native shard {shard}/{shards} produced tiny object ({sz}B)")
    return {"out": str(obj), "shard": shard, "shards": shards, "bytes": sz, "wallSec": round(dt, 3), "cpu": cpu}


def compile_sharded(src: Path, out_exe: Path, shards: int, rt: Path,
                    api: Path = None, native: Path = None, work_dir: Path = None) -> dict:
    assert (api is not None) ^ (native is not None), "specify exactly one of --api or --native"
    t0 = time.perf_counter()
    cleanup = None
    if work_dir is None:
        cleanup = tempfile.TemporaryDirectory(prefix="parcg_")
        wd = Path(cleanup.name)
    else:
        wd = work_dir
        wd.mkdir(parents=True, exist_ok=True)
    try:
        objs = [wd / f"shard_{k}.o" for k in range(shards)]
        t_emit0 = time.perf_counter()
        if shards == 1:
            cpu = SAFE_CPUS[2]  # CPU 2
            workers = [run_worker_api(api, src, objs[0], 0, 1, cpu) if api
                       else run_worker_native(native, src, objs[0], 0, 1, cpu)]
        else:
            with ThreadPoolExecutor(max_workers=shards) as ex:
                futs = []
                for k in range(shards):
                    cpu = SAFE_CPUS[k % len(SAFE_CPUS)]
                    if api:
                        futs.append(ex.submit(run_worker_api, api, src, objs[k], k, shards, cpu))
                    else:
                        futs.append(ex.submit(run_worker_native, native, src, objs[k], k, shards, cpu))
                workers = [f.result() for f in futs]
        t_emit1 = time.perf_counter()

        t_link0 = time.perf_counter()
        out_exe.parent.mkdir(parents=True, exist_ok=True)
        link_cmd = [CC, "-no-pie"] + [str(o) for o in objs] + [str(rt), "-pthread", "-lm", "-o", str(out_exe)]
        r_link = subprocess.run(link_cmd, capture_output=True, text=True, timeout=60)
        t_link1 = time.perf_counter()
        if r_link.returncode != 0:
            raise RuntimeError(f"link failed: {r_link.stderr[:500]}")

        return {
            "src": str(src),
            "out": str(out_exe),
            "shards": shards,
            "emitWallSec": round(t_emit1 - t_emit0, 3),
            "linkSec": round(t_link1 - t_link0, 3),
            "totalWallSec": round(t_link1 - t0, 3),
            "totalObjBytes": sum(w["bytes"] for w in workers),
            "workers": workers,
        }
    finally:
        if cleanup is not None:
            cleanup.cleanup()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--api", type=Path, default=None)
    ap.add_argument("--native", type=Path, default=None)
    ap.add_argument("--shards", type=int, default=4)
    ap.add_argument("--src", type=Path, required=True)
    ap.add_argument("--out", type=Path, required=True)
    ap.add_argument("--rt", type=Path, default=DEFAULT_RT)
    ap.add_argument("--work-dir", type=Path, default=None)
    args = ap.parse_args()
    res = compile_sharded(args.src, args.out, args.shards, args.rt, args.api, args.native, args.work_dir)
    print(json.dumps(res, indent=2))


if __name__ == "__main__":
    main()
