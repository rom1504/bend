#!/usr/bin/env python3
"""Extract the nonempty loader/checker workload. Source transport only."""
import argparse
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--out', type=Path, required=True)
p.add_argument('--api', action='store_true')
p.add_argument('--rounds', type=int, choices=[32, 64], default=32)
a = p.parse_args()
command = [sys.executable, '-B', 'experiments/phase163/tools/prepare.py',
           '--module', 'selfhost/tests/phase163/direct-runtime.bend',
           '--module', 'selfhost/tests/phase169/checker-workload.bend']
if a.api:
    for name in ['p169c_result', 'p169c_run', 'p169c_fixtures']:
        command += ['--export', name]
else:
    command += ['--module', f'selfhost/tests/phase169/checker-main{a.rounds}.bend',
                '--export', 'main']
command += ['--out', str(a.out)]
raise SystemExit(subprocess.call(command, cwd=ROOT))
