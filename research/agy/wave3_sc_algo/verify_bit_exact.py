#!/usr/bin/env python3
"""Verify 100% bit-identical .o output on 9 key native45 programs + measure hosted-B1 compile speedup."""
import hashlib
import json
import subprocess
import sys
import tempfile
import time
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
BUN = ROOT / "selfhost/.assets/bin/bun"
EMIT_OBJ = ROOT / "research/agy/emit_obj.mjs"
BASE_API = ROOT / "selfhost/build/agy/wave2_unified/api.mjs"
CAND_API = Path(sys.argv[1]) if len(sys.argv) > 1 else ROOT / "selfhost/build/agy/wave3_sc_algo/api.mjs"
CATALOG = {c["id"]: c for c in json.loads((ROOT / "selfhost/tools/bench/catalogs/native45/catalog.json").read_text())["cases"]}

TARGETS = [
    "raytrace",
    "mandelbrot",
    "lexer",
    "coverage-bst-64",
    "coverage-map-churn-32",
    "coverage-record-aggregation-256",
    "editdist",
    "symreg",
    "tree-bitonic",
]


def emit(api: Path, src: Path, out: Path) -> tuple[str, int, float]:
    t0 = time.perf_counter()
    r = subprocess.run([str(BUN), str(EMIT_OBJ), str(api), str(src), str(out)],
                       capture_output=True, text=True, timeout=180)
    dt = time.perf_counter() - t0
    if r.returncode != 0:
        raise RuntimeError(f"emit failed ({api.name} on {src.name}): {r.stderr[:400]}")
    data = out.read_bytes()
    return hashlib.sha256(data).hexdigest(), len(data), dt


def main():
    ok = 0
    tot_base = 0.0
    tot_cand = 0.0
    with tempfile.TemporaryDirectory() as td:
        td = Path(td)
        for cid in TARGETS:
            src = ROOT / "selfhost/tools/bench" / CATALOG[cid]["source"]["file"]
            b_sha, b_len, b_dt = emit(BASE_API, src, td / f"{cid}.base.o")
            c_sha, c_len, c_dt = emit(CAND_API, src, td / f"{cid}.cand.o")
            same = (b_sha == c_sha)
            tot_base += b_dt
            tot_cand += c_dt
            status = "BIT-EXACT" if same else f"DIFF! base={b_sha[:12]}({b_len}B) cand={c_sha[:12]}({c_len}B)"
            print(f"  {cid:34s}  base={b_dt:5.2f}s  cand={c_dt:5.2f}s  ({b_dt/c_dt:4.2f}x)  {status}", flush=True)
            if same:
                ok += 1
    print(f"\nSummary: {ok}/{len(TARGETS)} bit-exact | total base={tot_base:.2f}s cand={tot_cand:.2f}s ({tot_base/tot_cand:.2f}x)")
    if ok != len(TARGETS):
        sys.exit(1)


if __name__ == "__main__":
    main()
