#!/usr/bin/env python3
"""Stable entry for the explicitly selected native Bend compiler release."""
import runpy
from pathlib import Path
runpy.run_path(str(Path(__file__).resolve().parent/'tools/native/launch.py'),run_name='__main__')
