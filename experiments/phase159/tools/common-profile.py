#!/usr/bin/env python3
"""Reuse the general profiler with the Phase157 clean runtime environment."""
import os,runpy,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
for key in list(os.environ):
    if key.startswith('BEND_') or key in ['LD_PRELOAD','LD_AUDIT']: del os.environ[key]
sys.path.insert(0,str(ROOT/'selfhost/tools/profiler'))
runpy.run_path(str(ROOT/'selfhost/tools/profiler/run.py'),run_name='__main__')
