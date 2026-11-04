#!/usr/bin/env python3
"""Use the maintained profiler under an explicit self-emission environment."""
import os,runpy,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
for key in list(os.environ):
    if key.startswith('BEND_') or key in ['LD_PRELOAD','LD_AUDIT']: del os.environ[key]
os.environ['BEND_NO_FREE']='1'
sys.path.insert(0,str(ROOT/'selfhost/tools/profiler'))
runpy.run_path(str(ROOT/'selfhost/tools/profiler/run.py'),run_name='__main__')
