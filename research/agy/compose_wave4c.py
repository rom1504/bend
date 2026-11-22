#!/usr/bin/env python3
"""Compose Wave 4C general backend passes cleanly on top of Wave 4B unified/compiler.bend:
  1. W4-9:  apply_cmov.py (branchless cmov diamonds for gameoflife + expression LICM/rotate fix) [optional]
  2. W4-10: apply_arrclose.py (product-field scalar kind prop + bitmask/IV BCE + testq loop rotate + CFG peepholes)
  3. W4-11: apply_f32clean.py (XMM store-to-load forwarding + native45 inliner guards + p113i_ prefix compaction)

Usage:
  python3 -B research/agy/compose_wave4c.py <out_compiler.bend> [--no-cmov]
"""
import argparse
import subprocess
import tempfile
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
WAVE4B_COMPILER = ROOT / "selfhost/build/agy/wave4b_unified/compiler.bend"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("out", type=Path)
    ap.add_argument("--src", type=Path, default=WAVE4B_COMPILER)
    ap.add_argument("--no-cmov", action="store_true")
    args = ap.parse_args()

    steps = []
    if not args.no_cmov and (ROOT / "research/agy/wave4c_cmov/apply_cmov.py").exists():
        steps.append((
            "W4-9 (Branchless cmov Diamonds + Expression Closer)",
            lambda i, o: ["python3", "-B", str(ROOT / "research/agy/wave4c_cmov/apply_cmov.py"), "--src", str(i), "--dst", str(o)],
        ))
    steps.extend([
        ("W4-10 (Product-Field Kind Prop + Bitmask/IV BCE + testq Rotate + CFG Peepholes)",
         lambda i, o: ["python3", "-B", str(ROOT / "research/agy/wave4c_arrclose/apply_arrclose.py"), "--src", str(i), "--dst", str(o)]),
        ("W4-11 (XMM Store-to-Load Forwarding + Native45 Guards + p113i Prefix Compaction)",
         lambda i, o: ["python3", "-B", str(ROOT / "research/agy/wave4c_f32clean/apply_f32clean.py"), "--src", str(i), "--dst", str(o)]),
    ])

    args.out.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory() as td:
        cur = args.src
        for idx, (label, mk_cmd) in enumerate(steps):
            nxt = args.out if idx == len(steps) - 1 else Path(td) / f"step_{idx:02d}.bend"
            cmd = mk_cmd(cur, nxt)
            print(f"[{idx+1}/{len(steps)}] {label} ...", flush=True)
            subprocess.run(cmd, check=True)
            cur = nxt
    print(f"\nComposed Wave 4C unified compiler: {args.out} ({args.out.stat().st_size} bytes)", flush=True)


if __name__ == "__main__":
    main()
