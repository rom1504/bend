#!/usr/bin/env python3
"""Fast 7-case benchmark harness for Track B (BST, Map Churn, Tree-Bitonic) vs unified baseline."""
import argparse
import json
import statistics
import subprocess
import sys
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
CATALOG = ROOT / "selfhost/tools/bench/catalogs/native45/catalog.json"
BUN = ROOT / "selfhost/.assets/bin/bun"
EMIT_OBJ = ROOT / "research/agy/emit_obj.mjs"
BASE_DIR = ROOT / "selfhost/build/agy/unified/full44"
RT_OBJ = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"

TARGETS = [
    "coverage-bst-32",
    "coverage-bst-64",
    "coverage-map-churn-32",
    "coverage-map-churn-128",
    "variation-tree-bitonic-6-17",
    "tree-bitonic",
    "variation-tree-bitonic-9-123",
]

def run(cmd, timeout=120):
    p = subprocess.run(list(map(str, cmd)), capture_output=True, text=True, timeout=timeout)
    if p.returncode != 0:
        raise RuntimeError(f"Failed ({p.returncode}): {cmd}\nSTDOUT:\n{p.stdout}\nSTDERR:\n{p.stderr}")
    return p.stdout

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--api", type=Path, required=True)
    ap.add_argument("--rt", type=Path, default=RT_OBJ)
    ap.add_argument("--work", type=Path, default=ROOT / "selfhost/build/agy/wave2_bst/bins")
    ap.add_argument("--rounds", type=int, default=3)
    ap.add_argument("--cases", nargs="*", default=TARGETS)
    a = ap.parse_args()
    a.work.mkdir(parents=True, exist_ok=True)

    cat = json.loads(CATALOG.read_text())
    by_id = {c["id"]: c for c in cat["cases"]}

    # Compile all candidate binaries (delete .o immediately to keep disk low)
    cand_bins = {}
    for cid in a.cases:
        c = by_id[cid]
        src = ROOT / "selfhost/tools/bench" / c["source"]["file"]
        obj = a.work / f"{cid}.o"
        binp = a.work / f"{cid}.cand"
        run([BUN, EMIT_OBJ, a.api, src, obj])
        run([CC, "-O2", "-no-pie", obj, a.rt, "-o", binp, "-lm", "-pthread"])
        obj.unlink(missing_ok=True)
        cand_bins[cid] = binp

    # Alternating rounds on CPU 2
    base_times = {cid: [] for cid in a.cases}
    cand_times = {cid: [] for cid in a.cases}
    for r in range(a.rounds):
        for cid in a.cases:
            pt = by_id[cid]["point"]
            args = [str(pt["repetitions"]), str(pt["warmups"]), str(pt["runtimeArgs"][0]), str(pt["runtimeArgs"][1])]
            expected = pt["expectedStdout"].strip()
            order = [("base", BASE_DIR / f"{cid}.cand"), ("cand", cand_bins[cid])]
            if r % 2 == 1:
                order.reverse()
            for tag, binp in order:
                out = run(["taskset", "-c", "2", binp, *args]).splitlines()
                assert out[0].strip() == expected, f"{cid} ({tag}) oracle mismatch: got {out[0]!r}, expected {expected!r}"
                ms = int(out[-1])
                (base_times if tag == "base" else cand_times)[cid].append(ms)

    tot_b = 0
    tot_c = 0
    print(f"{'Case':30s} {'Base':>7s} {'Cand':>7s} {'Delta':>8s} {'Ratio':>7s}")
    print("-" * 64)
    for cid in a.cases:
        mb = statistics.median(base_times[cid])
        mc = statistics.median(cand_times[cid])
        tot_b += mb
        tot_c += mc
        print(f"{cid:30s} {mb:7.1f} {mc:7.1f} {mc-mb:+8.1f} {mc/mb:7.4f}x")
    print("-" * 64)
    print(f"{'TOTAL':30s} {tot_b:7.1f} {tot_c:7.1f} {tot_c-tot_b:+8.1f} {tot_c/tot_b:7.4f}x")

if __name__ == "__main__":
    main()
