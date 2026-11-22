#!/usr/bin/env python3
"""Correctness Verification & Multi-Core Benchmark Suite for Wave 6 Native Sharded Compiler.

Verifies exact runtime output match (1-core vs 2-core vs 4-core, RR and LPT) on:
  - histogram, gameoflife, nbody, lexer, raytrace
  - native64 spot checks (coverage-bst-64, coverage-closures-64, coverage-record-aggregation-64)

Benchmarks wall-clock compile times (1-core vs 2-core vs 4-core on CPUs 0,1,4,5)
in both `cache` and `live` modes, and optionally full `compiler.bend` self-compile.
"""
from __future__ import annotations
import argparse
import json
import subprocess
import sys
import tempfile
import time
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from native_par_compile import compile_native_sharded, ROOT

CPUS = [0, 1, 4, 5]

BENCH_CASES = [
    ("histogram", ROOT / "research/agy/wave4_bench/inputs/upstream/histogram/main.bend", []),
    ("gameoflife", ROOT / "research/agy/wave4_bench/inputs/upstream/gameoflife/main.bend", []),
    ("nbody", ROOT / "research/agy/wave4_bench/inputs/upstream/nbody/main.bend", []),
    ("lexer", ROOT / "selfhost/tests/consolidation/native-broad/lexer.bend", []),
    ("raytrace", ROOT / "selfhost/tests/consolidation/native-broad/raytrace.bend", []),
]

NATIVE64_CASES = [
    ("coverage-bst-64", ROOT / "selfhost/tests/consolidation/native-broad/coverage-bst-64.bend",
     ROOT / "selfhost/tests/consolidation/native-broad/coverage-bst-64.stdout"),
    ("coverage-closures-64", ROOT / "selfhost/tests/consolidation/native-broad/coverage-closures-64.bend",
     ROOT / "selfhost/tests/consolidation/native-broad/coverage-closures-64.stdout"),
    ("coverage-record-aggregation-64", ROOT / "selfhost/tests/consolidation/native-broad/coverage-record-aggregation-64.bend",
     ROOT / "selfhost/tests/consolidation/native-broad/coverage-record-aggregation-64.stdout"),
]


def run_exe(exe: Path, extra_args: list[str] | None = None, cpu: int = 0) -> str:
    cmd = ["taskset", "-c", str(cpu), str(exe), "+RTS", "--threads", "1", "--gpu", "off", "-RTS"]
    if extra_args:
        cmd.extend(["--RTS", *extra_args])
    r = subprocess.run(cmd, capture_output=True, text=True, timeout=120)
    if r.returncode != 0:
        raise RuntimeError(f"exe {exe.name} failed (rc={r.returncode}): {r.stderr[:400]}")
    return r.stdout


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--native", type=Path, required=True, help="Native compiler binary")
    ap.add_argument("--strategy", choices=["rr", "lpt"], default="rr")
    ap.add_argument("--modes", type=str, default="cache,live", help="Comma-separated modes to benchmark")
    ap.add_argument("--shard-counts", type=str, default="1,2,4")
    ap.add_argument("--skip-native64", action="store_true")
    ap.add_argument("--skip-exec", type=str, default="", help="Comma-separated benchmark names to skip running (still compiles+links)")
    ap.add_argument("--self-compile", type=Path, default=None, help="Optional compiler.bend to benchmark 1/2/4-core self-compile")
    ap.add_argument("--self-modes", type=str, default="cache", help="Modes for self-compile benchmark")
    ap.add_argument("--out-json", type=Path, required=True)
    args = ap.parse_args()

    compiler = args.native.resolve()
    modes = [m.strip() for m in args.modes.split(",") if m.strip()]
    shard_counts = [int(x.strip()) for x in args.shard_counts.split(",") if x.strip()]
    skip_exec = {x.strip() for x in args.skip_exec.split(",") if x.strip()}

    results = {
        "compiler": str(compiler),
        "strategy": args.strategy,
        "cpus": CPUS,
        "benchmarks": {},
        "native64": {},
        "self_compile": {},
    }

    with tempfile.TemporaryDirectory(prefix="agy_w6_verify_", dir="/tmp/agy_w6_native_par") as td:
        td_path = Path(td)

        # 1. Main benchmark & correctness suite
        for mode in modes:
            print(f"\n=== Benchmark & Verify ({args.strategy}, mode={mode}) ===", flush=True)
            mode_rows = {}
            for name, src, run_args in BENCH_CASES:
                row = {"src": str(src), "runs": {}, "exact_match": True}
                ref_out = None
                for k in shard_counts:
                    exe = td_path / f"{name}_{mode}_s{k}"
                    res = compile_native_sharded(
                        compiler=compiler, src=src, out_exe=exe,
                        shards=k, mode=mode, strategy=args.strategy, cpus=CPUS,
                    )
                    if name in skip_exec:
                        out = "(compile+link verified)"
                    else:
                        out = run_exe(exe, run_args, cpu=CPUS[0])
                    exe.unlink(missing_ok=True)
                    if ref_out is None:
                        ref_out = out
                    else:
                        if out != ref_out:
                            row["exact_match"] = False
                            raise RuntimeError(
                                f"OUTPUT MISMATCH on {name} (mode={mode}, shards={k}): "
                                f"got {out[:120]!r} vs ref {ref_out[:120]!r}"
                            )
                    row["runs"][str(k)] = {
                        "emitWallSec": res["emitWallSec"],
                        "linkSec": res["linkSec"],
                        "totalWallSec": res["totalWallSec"],
                        "totalObjBytes": res["totalObjBytes"],
                        "workerMaxSec": res["workerMaxSec"],
                        "workerAvgSec": res["workerAvgSec"],
                        "imbalanceRatio": res["imbalanceRatio"],
                        "workerWallSecs": [w["wallSec"] for w in res["workers"]],
                    }
                row["stdout_preview"] = ref_out.strip().splitlines()[0][:80] if ref_out.strip() else ""
                t1 = row["runs"]["1"]["totalWallSec"]
                t2 = row["runs"].get("2", {}).get("totalWallSec", 0)
                t4 = row["runs"].get("4", {}).get("totalWallSec", 0)
                sp2 = f"{t1/t2:.2f}x" if t2 else "-"
                sp4 = f"{t1/t4:.2f}x" if t4 else "-"
                print(
                    f"  {name:12s}: 1c={t1:6.3f}s  2c={t2:6.3f}s ({sp2})  "
                    f"4c={t4:6.3f}s ({sp4})  imbal4={row['runs'].get('4',{}).get('imbalanceRatio','-')}  "
                    f"match={row['exact_match']}",
                    flush=True,
                )
                mode_rows[name] = row
            results["benchmarks"][mode] = mode_rows

        # 2. native64 spot checks (4-core cache mode vs golden .stdout)
        if not args.skip_native64:
            print(f"\n=== native64 Spot Checks (4-core {args.strategy}, mode=cache) ===", flush=True)
            for name, src, golden_path in NATIVE64_CASES:
                exe = td_path / f"{name}_s4"
                res = compile_native_sharded(
                    compiler=compiler, src=src, out_exe=exe,
                    shards=4, mode="cache", strategy=args.strategy, cpus=CPUS,
                )
                out = run_exe(exe, cpu=CPUS[0])
                exe.unlink(missing_ok=True)
                golden = golden_path.read_text()
                ok = (out.strip() == golden.strip())
                results["native64"][name] = {
                    "totalWallSec": res["totalWallSec"],
                    "emitWallSec": res["emitWallSec"],
                    "exact_match_golden": ok,
                }
                print(f"  {name:32s}: 4c={res['totalWallSec']:6.3f}s  golden_match={ok}", flush=True)
                if not ok:
                    raise RuntimeError(f"native64 mismatch on {name}: got {out[:120]!r} vs {golden[:120]!r}")

        # 3. Optional full compiler.bend self-compile benchmark (1-core vs 2-core vs 4-core)
        if args.self_compile is not None:
            sc_src = args.self_compile.resolve()
            sc_modes = [m.strip() for m in args.self_modes.split(",") if m.strip()]
            for mode in sc_modes:
                print(f"\n=== Self-Compile Benchmark: {sc_src.name} ({args.strategy}, mode={mode}) ===", flush=True)
                sc_runs = {}
                for k in shard_counts:
                    exe = td_path / f"self_{mode}_s{k}"
                    res = compile_native_sharded(
                        compiler=compiler, src=sc_src, out_exe=exe,
                        shards=k, mode=mode, strategy=args.strategy, cpus=CPUS,
                        timeout=1200,
                    )
                    # Smoke test the self-compiled binary by compiling gameoflife with it!
                    smoke_exe = td_path / f"smoke_gol_s{k}"
                    compile_native_sharded(
                        compiler=exe,
                        src=ROOT / "research/agy/wave4_bench/inputs/upstream/gameoflife/main.bend",
                        out_exe=smoke_exe, shards=1, mode="cache", strategy="rr", cpus=[CPUS[0]],
                    )
                    smoke_out = run_exe(smoke_exe, cpu=CPUS[0]).strip()
                    smoke_exe.unlink(missing_ok=True)
                    exe.unlink(missing_ok=True)
                    sc_runs[str(k)] = {
                        "emitWallSec": res["emitWallSec"],
                        "linkSec": res["linkSec"],
                        "totalWallSec": res["totalWallSec"],
                        "totalObjBytes": res["totalObjBytes"],
                        "exeBytes": res["exeBytes"],
                        "workerMaxSec": res["workerMaxSec"],
                        "workerAvgSec": res["workerAvgSec"],
                        "imbalanceRatio": res["imbalanceRatio"],
                        "workerWallSecs": [w["wallSec"] for w in res["workers"]],
                        "smokeGameOfLifeStdout": smoke_out,
                    }
                    print(
                        f"  shards={k}: emit={res['emitWallSec']:6.2f}s  link={res['linkSec']:5.2f}s  "
                        f"total={res['totalWallSec']:6.2f}s  workers={[round(w['wallSec'],2) for w in res['workers']]}  "
                        f"imbal={res['imbalanceRatio']}  smoke_gol={smoke_out}",
                        flush=True,
                    )
                results["self_compile"][mode] = sc_runs

    args.out_json.parent.mkdir(parents=True, exist_ok=True)
    args.out_json.write_text(json.dumps(results, indent=2) + "\n")
    print(f"\nSaved results -> {args.out_json}", flush=True)


if __name__ == "__main__":
    main()
