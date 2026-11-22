#!/usr/bin/env python3
"""Composable Wave 2 Track A (Ray, Mandelbrot & Numeric Loops) patcher.
Applies Pass 1 + Pass 2a + Pass 2b cleanly onto unified/compiler.bend (or any compatible compiler.bend).
Usage: python3 apply_wave2_ray.py <input_compiler.bend> <output_compiler.bend>
"""
import subprocess
import sys
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent


def main():
    if len(sys.argv) != 3:
        raise SystemExit(f"Usage: {sys.argv[0]} <in.bend> <out.bend>")
    src = Path(sys.argv[1])
    dst = Path(sys.argv[2])
    dst.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory() as td:
        td = Path(td)
        s1 = td / "p1.bend"
        s2a = td / "p2a.bend"
        subprocess.run(["python3", "-B", str(HERE / "apply_pass1.py"), str(src), str(s1)], check=True)
        subprocess.run(["python3", "-B", str(HERE / "apply_pass2a.py"), str(s1), str(s2a)], check=True)
        subprocess.run(["python3", "-B", str(HERE / "apply_pass2b.py"), str(s2a), str(dst)], check=True)
    print(f"Wave 2 Track A composed: {dst} ({dst.stat().st_size} bytes)")


if __name__ == "__main__":
    main()
