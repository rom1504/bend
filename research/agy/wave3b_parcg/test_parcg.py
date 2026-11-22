#!/usr/bin/env python3
"""Verify 100% exact stdout equivalence and measure wall-clock & codegen speedup
for N=1 vs N=4 sharded codegen on small proxies (raytrace, mandelbrot, lexer,
coverage-bst-64) + N=1 bit-exactness against Wave 2 baseline api.mjs.
"""
import hashlib
import json
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
sys.path.insert(0, str(ROOT / "research/agy/wave3b_parcg"))
from par_compile import compile_sharded, DEFAULT_RT, BUN

BASE_API = ROOT / "selfhost/build/agy/wave2_unified/api.mjs"
CAND_API = ROOT / "selfhost/build/agy/wave3b_parcg/api.mjs"
EMIT_OBJ = ROOT / "research/agy/emit_obj.mjs"
CATALOG = {c["id"]: c for c in json.loads((ROOT / "selfhost/tools/bench/catalogs/native45/catalog.json").read_text())["cases"]}
TARGETS = ["raytrace", "mandelbrot", "lexer", "coverage-bst-64"]


def sha256(p: Path) -> str:
    return hashlib.sha256(p.read_bytes()).hexdigest()


def run_exe(exe: Path) -> tuple[int, str]:
    r = subprocess.run([str(exe)], capture_output=True, text=True, timeout=60)
    return r.returncode, r.stdout


def main():
    results = []
    with tempfile.TemporaryDirectory(prefix="parcg_test_") as td:
        td = Path(td)
        for cid in TARGETS:
            src = ROOT / "selfhost/tools/bench" / CATALOG[cid]["source"]["file"]
            # 1. N=1 bit-exactness vs Wave 2 baseline api.mjs
            base_o = td / f"{cid}.base.o"
            cand1_o = td / f"{cid}.cand1.o"
            subprocess.run([str(BUN), str(EMIT_OBJ), str(BASE_API), str(src), str(base_o)], check=True, capture_output=True)
            subprocess.run([str(BUN), str(EMIT_OBJ), str(CAND_API), str(src), str(cand1_o)], check=True, capture_output=True)
            bit_exact_n1 = (sha256(base_o) == sha256(cand1_o))

            # 2. N=1 vs N=4 sharded compile + link + run
            exe1 = td / f"{cid}_n1"
            exe4 = td / f"{cid}_n4"
            r1 = compile_sharded(src, exe1, shards=1, rt=DEFAULT_RT, api=CAND_API)
            r4 = compile_sharded(src, exe4, shards=4, rt=DEFAULT_RT, api=CAND_API)

            rc1, out1 = run_exe(exe1)
            rc4, out4 = run_exe(exe4)
            stdout_match = (rc1 == 0 and rc4 == 0 and out1 == out4)

            emit1_ms = r1["workers"][0]["emitMs"]
            emit4_max_ms = max(w["emitMs"] for w in r4["workers"])
            emit_speedup = emit1_ms / emit4_max_ms if emit4_max_ms > 0 else 0.0
            wall_speedup = r1["totalWallSec"] / r4["totalWallSec"] if r4["totalWallSec"] > 0 else 0.0

            row = {
                "id": cid,
                "bitExactN1": bit_exact_n1,
                "stdoutMatch": stdout_match,
                "rc1": rc1,
                "rc4": rc4,
                "n1WallSec": r1["totalWallSec"],
                "n4WallSec": r4["totalWallSec"],
                "wallSpeedup": round(wall_speedup, 2),
                "n1EmitMs": emit1_ms,
                "n4MaxEmitMs": emit4_max_ms,
                "emitSpeedup": round(emit_speedup, 2),
                "n1ObjBytes": r1["totalObjBytes"],
                "n4ObjBytes": r4["totalObjBytes"],
                "n4LinkSec": r4["linkSec"],
            }
            results.append(row)
            status = "PASS" if (bit_exact_n1 and stdout_match) else "FAIL"
            print(
                f"{status:4s} {cid:18s} "
                f"N1_bitexact={bit_exact_n1} stdout_eq={stdout_match} | "
                f"wall: {r1['totalWallSec']:.2f}s -> {r4['totalWallSec']:.2f}s ({wall_speedup:.2f}x) | "
                f"codegen(x181-x188): {emit1_ms:.0f}ms -> {emit4_max_ms:.0f}ms ({emit_speedup:.2f}x) | "
                f"link={r4['linkSec']:.2f}s",
                flush=True,
            )

    all_ok = all(r["bitExactN1"] and r["stdoutMatch"] for r in results)
    print(f"\nOverall: {'ALL PASS' if all_ok else 'FAILED'} ({sum(r['bitExactN1'] and r['stdoutMatch'] for r in results)}/{len(results)})")
    if not all_ok:
        sys.exit(1)


if __name__ == "__main__":
    main()
