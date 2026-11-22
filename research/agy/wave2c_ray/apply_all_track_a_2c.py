#!/usr/bin/env python3
"""Composable Track A full patcher (Wave 2A + Wave 2B + Wave 2C) on unified/compiler.bend."""
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
TRACK_A_2B = ROOT / "research/agy/wave2_ray_b/apply_all_track_a.py"
WAVE_2C = ROOT / "research/agy/wave2c_ray/apply_wave2c.py"


def main():
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} <in_compiler.bend> <out_compiler.bend>", file=sys.stderr)
        sys.exit(2)
    in_path, out_path = sys.argv[1], sys.argv[2]
    with tempfile.TemporaryDirectory(prefix="track_a_2c_") as td:
        mid = str(Path(td) / "compiler_w2b.bend")
        subprocess.run([sys.executable, str(TRACK_A_2B), in_path, mid], check=True)
        subprocess.run([sys.executable, str(WAVE_2C), mid, out_path], check=True)


if __name__ == "__main__":
    main()
