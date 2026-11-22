#!/usr/bin/env python3
"""Compose Wave 5A Dual-Engine passes cleanly on top of Wave 4C unified/compiler.bend:
  Engine B (Compiled-Program Speed):
    1. W5-R1: apply_r1.py (joint regalloc cap 256, loop-counter sink, multi-level cmov, 2-step peel, inv+min BCE)
    2. W5-R2: apply_r2.py (high-param loop dispatch, w5_xmm_fold, w5_gpr_peep)
    3. W5-R3: apply_r3.py (arity 32->64 direct-style, cmov diamond select, disjoint-buffer slot fwd)
    4. W5-R4: apply_r4.py (inline P111_SPECIAL_SUCC 1n+j, general Loop-Carried Product Unboxing)
  Engine A (Compile Speed):
    5. W5-C2: apply_struct_fast.py (Patricia-trie p113k_join, O(log N) x186_e_* CSE, x187_encode dispatch)
    6. W5-C1: apply_compile_fast.py (zero-closure hash trie, w5_scan_flags pre-guards, O(N) w4c_xmm_opt)
    7. W5-C3: apply_frontend_fast.py (Frontend/Lowering O(N^2) killer) [optional]

Usage:
  python3 -B research/agy/compose_wave5a.py <out_compiler.bend> [--no-c3]
"""
import argparse
import subprocess
import tempfile
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
WAVE4C_COMPILER = ROOT / "selfhost/build/agy/wave4c_unified/compiler.bend"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("out", type=Path)
    ap.add_argument("--src", type=Path, default=WAVE4C_COMPILER)
    ap.add_argument("--no-c3", action="store_true")
    args = ap.parse_args()

    steps = [
        ("W5-R1 (Joint RegAlloc 256 + Loop-Counter Sink + 2-Step Peel + BCE)",
         lambda i, o: ["python3", "-B", str(ROOT / "research/agy/wave5_r1/apply_r1.py"), "--src", str(i), "--dst", str(o)]),
        ("W5-R2 (High-Param Loop Dispatch + w5_xmm_fold + w5_gpr_peep)",
         lambda i, o: ["python3", "-B", str(ROOT / "research/agy/wave5_r2/apply_r2.py"), "--src", str(i), "--dst", str(o)]),
        ("W5-R3 (Arity 32->64 Direct-Style + cmov Select + Disjoint-Buf Slot Fwd)",
         lambda i, o: ["python3", "-B", str(ROOT / "research/agy/wave5_r3/apply_r3.py"), "--src", str(i), "--dst", str(o)]),
        ("W5-R4 (Inline P111_SPECIAL_SUCC + Loop-Carried Product Unboxing)",
         lambda i, o: ["python3", "-B", str(ROOT / "research/agy/wave5_r4/apply_r4.py"), "--src", str(i), "--dst", str(o)]),
        ("W5-C2 (Patricia-Trie p113k_join + O(log N) x186_e_* CSE + x187 Dispatch)",
         lambda i, o: ["python3", "-B", str(ROOT / "research/agy/wave5_struct/apply_struct_fast.py"), "--src", str(i), "--dst", str(o)]),
        ("W5-C1 (Zero-Closure Hash Trie + w5_scan_flags Pre-Guards + O(N) xmm_opt)",
         lambda i, o: ["python3", "-B", str(ROOT / "research/agy/wave5_compile/apply_compile_fast.py"), "--src", str(i), "--dst", str(o)]),
    ]
    if not args.no_c3 and (ROOT / "research/agy/wave5_c3/apply_frontend_fast.py").exists():
        steps.append((
            "W5-C3 (Frontend & Lowering O(N^2) Compile-Speed Killer)",
            lambda i, o: ["python3", "-B", str(ROOT / "research/agy/wave5_c3/apply_frontend_fast.py"), "--src", str(i), "--dst", str(o)],
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
    print(f"\nComposed Wave 5A unified compiler: {args.out} ({args.out.stat().st_size} bytes)", flush=True)


if __name__ == "__main__":
    main()
