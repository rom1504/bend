"""Compose the bounded virtual-result prototype; no target execution."""
import argparse
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--out',type=Path,required=True)
a = p.parse_args()
subprocess.run([sys.executable,'-B',str(HERE.parent/'prepare.py'),
    '--out',str(a.out),'--module',str(HERE/'candidate-v01.bend'),
    '--module',str(HERE/'controls-v01.bend'),'--overrides',
    'P128BRHelper','p128br_lookup','p128br_call','p128br_seed',
    'p128br_summaries','p128br_helper_names'],check=True)
