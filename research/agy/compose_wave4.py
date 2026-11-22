#!/usr/bin/env python3
"""Compose Wave 4A general backend passes cleanly on top of Wave 3B unified/compiler.bend:
  1. W4-2: apply_array_fast.py (per-function runtime-guarded p113a + p117v LICM + cold scratch sinking)
  2. W4-1: apply_inliner.py (general multi-pass p113i + tail-loop peel + U32/F32 const-fold + scalar Bool)
  3. W4-3: apply_regunbox.py (general F32 XMM regalloc + direct movss spills + tail-rec $product unbox + dead-field elim) [optional]
  4. W4-4: apply_scalar_x86.py (spill-free U32.mod + lea + shl + leaf shrink-wrap + bool01 cmov + odd-parity guard + CSE/regalloc)

Usage:
  python3 -B research/agy/compose_wave4.py <out_compiler.bend> [--no-regunbox]
"""
import argparse
import subprocess
import tempfile
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
WAVE3B_COMPILER = ROOT / "selfhost/build/agy/wave3b_unified/compiler.bend"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("out", type=Path)
    ap.add_argument("--src", type=Path, default=WAVE3B_COMPILER)
    ap.add_argument("--no-regunbox", action="store_true")
    args = ap.parse_args()

    steps = [
        ("W4-2 (Per-Function Array Fast-Path + p117v LICM + Cold Scratch Sink)",
         lambda i, o: ["python3", "-B", str(ROOT / "research/agy/wave4_array/apply_array_fast.py"), "--src", str(i), "--dst", str(o)]),
        ("W4-1 (Multi-Pass Inliner + U32/F32 Const-Fold + Scalar Bool)",
         lambda i, o: ["python3", "-B", str(ROOT / "research/agy/wave4_inliner/apply_inliner.py"), "--src", str(i), "--dst", str(o)]),
    ]
    if not args.no_regunbox and (ROOT / "research/agy/wave4_regunbox/apply_regunbox.py").exists():
        steps.append((
            "W4-3 (General F32 XMM Regalloc + Tail-Rec $product Unbox + Dead-Field Elim)",
            lambda i, o: ["python3", "-B", str(ROOT / "research/agy/wave4_regunbox/apply_regunbox.py"), "--src", str(i), "--dst", str(o)],
        ))
    steps.append((
        "W4-4 (General x86 Scalar Codegen, U32.mod Spill Fix, Shl/Lea, Shrink-Wrap, CSE)",
        lambda i, o: ["python3", "-B", str(ROOT / "research/agy/wave4_scalar/apply_scalar_x86.py"), "--src", str(i), "--dst", str(o)],
    ))

    args.out.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory() as td:
        cur = args.src
        for idx, (label, mk_cmd) in enumerate(steps):
            nxt = args.out if idx == len(steps) - 1 else Path(td) / f"step_{idx:02d}.bend"
            cmd = mk_cmd(cur, nxt)
            print(f"[{idx+1}/{len(steps)}] {label} ...", flush=True)
            subprocess.run(cmd, check=True)
            cur = nxt
    print(f"\nComposed Wave 4A unified compiler: {args.out} ({args.out.stat().st_size} bytes)", flush=True)


if __name__ == "__main__":
    main()
