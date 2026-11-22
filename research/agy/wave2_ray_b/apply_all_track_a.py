#!/usr/bin/env python3
"""Composable Track A (Wave 2A + Wave 2B) entry-point patcher.
Applies Wave 2A (Pass 1 + Pass 2a + Pass 2b) + Wave 2B cleanly onto unified/compiler.bend.
Usage: python3 apply_all_track_a.py <input_compiler.bend> <output_compiler.bend>
"""
import subprocess
import sys
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
W2A = HERE.parent / "wave2_ray" / "apply_wave2_ray.py"
W2B = HERE / "apply_wave2b.py"


def main():
    if len(sys.argv) != 3:
        raise SystemExit(f"Usage: {sys.argv[0]} <in.bend> <out.bend>")
    src = Path(sys.argv[1])
    dst = Path(sys.argv[2])
    dst.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory() as td:
        mid = Path(td) / "w2a.bend"
        subprocess.run(["python3", "-B", str(W2A), str(src), str(mid)], check=True)
        subprocess.run(["python3", "-B", str(W2B), str(mid), str(dst)], check=True)
    print(f"Track A (Wave 2A + 2B) composed: {dst} ({dst.stat().st_size} bytes)")


if __name__ == "__main__":
    main()
