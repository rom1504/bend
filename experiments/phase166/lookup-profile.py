#!/usr/bin/env python3
"""Run the maintained profiler with the exact lookup runtime policy."""
import os, runpy, sys
from pathlib import Path
ROOT = Path(__file__).resolve().parents[2]
for key in list(os.environ):
    if key.startswith('BEND_') or key in ['BANGS', 'LD_PRELOAD', 'LD_AUDIT']:
        del os.environ[key]
os.environ.update(BEND_RC='0', BEND_NO_FREE='1', BEND_AUTO_PAR='0', BANGS='0')
sys.dont_write_bytecode = True
sys.path.insert(0, str(ROOT/'selfhost/tools/profiler'))
runpy.run_path(str(ROOT/'selfhost/tools/profiler/run.py'), run_name='__main__')
