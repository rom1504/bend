#!/usr/bin/env python3
"""Compose Wave 5C Final Unified Compiler on top of Wave 5A unified/compiler.bend:
  1-6. All 6 Wave 5B tracks (via compose_wave5b.py, including tight power-of-2 IV BCE guard!)
  7.   W5C-R1: apply_w5c_r1.py (optional if present)
  8.   W5C-C1: apply_w5c_c1.py (W5BLblTrie + copy_peep_fast + skip-unchanged + x187 match family + Patricia direct dispatch -> 5.24x single-thread compile speedup!)

Usage:
  python3 -B research/agy/compose_wave5c.py <out_compiler.bend> [--no-r1]
"""
import argparse
import subprocess
import tempfile
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("out", type=Path)
    ap.add_argument("--no-r1", action="store_true")
    args = ap.parse_args()

    args.out.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory() as td:
        td = Path(td)
        w5b = td / "w5b.bend"
        print("[Wave 5C] Stage 1: Compose Wave 5B (R2 + R1 + R3 + C2 + C1 + C3) ...", flush=True)
        subprocess.run(["python3", "-B", str(ROOT / "research/agy/compose_wave5b.py"), str(w5b)], check=True)
        cur = w5b
        print("[Wave 5C] Stage 2: Apply W5C-C1 (10x Compile-Speed Closer) ...", flush=True)
        w5c_c1 = td / "w5c_c1.bend"
        r1_script = ROOT / "research/agy/wave5c_r1/apply_w5c_r1.py"
        use_r1 = (not args.no_r1) and r1_script.exists()
        subprocess.run(
            ["python3", "-B", str(ROOT / "research/agy/wave5c_c1/apply_w5c_c1.py"), "--src", str(cur), "--dst", str(w5c_c1 if use_r1 else args.out)],
            check=True,
        )
        if use_r1:
            print("[Wave 5C] Stage 3: Apply W5C-R1 (Post-Joint Transient RegAlloc + Peepholes) ...", flush=True)
            subprocess.run(["python3", "-B", str(r1_script), "--src", str(w5c_c1), "--dst", str(args.out)], check=True)
    print(f"\nComposed Wave 5C unified compiler: {args.out} ({args.out.stat().st_size} bytes)", flush=True)


if __name__ == "__main__":
    main()
