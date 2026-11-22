#!/usr/bin/env python3
"""Compose Wave 5B Dual-Engine passes cleanly on top of Wave 5A unified/compiler.bend:
  Engine B (Compiled-Program Speed):
    1. W5B-R1: apply_w5b_r1.py (Array/Loop Closer: histogram, editdist, bst)
    2. W5B-R2: apply_w5b_r2.py (Direct sqrtss, leaf slot promotion %rcx/%r12, XMM/GPR peepholes)
    3. W5B-R3: apply_w5b_r3.py (Holdout Transfer Closer: kmeans, bfs, merkle)
  Engine A (Compile Speed):
    4. W5B-C2: apply_w5b_c2.py (Frontend/IR/Lowering & Closure Killer — 2.08x plan+pw)
    5. W5B-C1: apply_w5b_c1.py (Backend & RegAlloc Compile-Speed Killer — -3.81s emit)
    6. W5B-C3: apply_w5b_c3.py (Multi-Core Parallel Sharded Codegen + Native STRHASH)

Usage:
  python3 -B research/agy/compose_wave5b.py <out_compiler.bend> [--skip r1,r3]
"""
import argparse
import subprocess
import tempfile
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
WAVE5A_COMPILER = ROOT / "selfhost/build/agy/wave5a_unified/compiler.bend"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("out", type=Path)
    ap.add_argument("--src", type=Path, default=WAVE5A_COMPILER)
    ap.add_argument("--skip", default="", help="Comma-separated keys to skip: r1,r2,r3,c2,c1,c3")
    args = ap.parse_args()
    skip = {s.strip().lower() for s in args.skip.split(",") if s.strip()}

    all_steps = [
        ("r2", "W5B-R2 (Direct sqrtss + Leaf Slot Promotion + XMM/GPR Peepholes)",
         lambda i, o: ["python3", "-B", str(ROOT / "research/agy/wave5b_r2/apply_w5b_r2.py"), "--src", str(i), "--dst", str(o)]),
        ("r1", "W5B-R1 (Array/Loop Closer: Hist/Editdist/BST)",
         lambda i, o: ["python3", "-B", str(ROOT / "research/agy/wave5b_r1/apply_w5b_r1.py"), "--src", str(i), "--dst", str(o)]),
        ("r3", "W5B-R3 (Holdout Transfer Closer: Kmeans/BFS/Merkle)",
         lambda i, o: ["python3", "-B", str(ROOT / "research/agy/wave5b_r3/apply_w5b_r3.py"), "--src", str(i), "--dst", str(o)]),
        ("c2", "W5B-C2 (Frontend/IR/Lowering & Closure Killer)",
         lambda i, o: ["python3", "-B", str(ROOT / "research/agy/wave5b_c2/apply_w5b_c2.py"), "--src", str(i), "--dst", str(o)]),
        ("c1", "W5B-C1 (Backend & RegAlloc Compile-Speed Killer)",
         lambda i, o: ["python3", "-B", str(ROOT / "research/agy/wave5b_c1/apply_w5b_c1.py"), "--src", str(i), "--dst", str(o)]),
        ("c3", "W5B-C3 (Parallel Sharded Codegen + Native STRHASH)",
         lambda i, o: ["python3", "-B", str(ROOT / "research/agy/wave5b_c3/apply_w5b_c3.py"), "--src", str(i), "--dst", str(o)]),
    ]
    steps = [(k, lbl, fn) for (k, lbl, fn) in all_steps if k not in skip]

    args.out.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory() as td:
        cur = args.src
        for idx, (key, label, mk_cmd) in enumerate(steps):
            nxt = args.out if idx == len(steps) - 1 else Path(td) / f"step_{idx:02d}_{key}.bend"
            cmd = mk_cmd(cur, nxt)
            print(f"[{idx+1}/{len(steps)}] {label} ...", flush=True)
            subprocess.run(cmd, check=True)
            cur = nxt
    print(f"\nComposed Wave 5B unified compiler: {args.out} ({args.out.stat().st_size} bytes)", flush=True)


if __name__ == "__main__":
    main()
