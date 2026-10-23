"""Compose the late-worker capability experiment/control; no target execution."""
import argparse
from pathlib import Path
import subprocess
import sys
HERE=Path(__file__).resolve().parent
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--out',type=Path,required=True);p.add_argument('--closure-only',action='store_true')
a=p.parse_args()
cmd=[sys.executable,'-B',str(HERE.parent/'prepare.py'),'--out',str(a.out)]
for name in ['candidate-v02.bend','controls-v02.bend','late-workers-v03.bend']:
    cmd += ['--module',str(HERE/name)]
if a.closure_only:cmd += ['--module',str(HERE/'closure-only-v01.bend'),'--module-overrides','p131p_retry']
cmd += ['--overrides','P128BRHelper','p128br_lookup','p128br_call','p128br_seed',
    'p128br_summaries','p128br_helper_names','p128br_scan_ready','p128raw_br_scanned']
subprocess.run(cmd,check=True)
