#!/usr/bin/env python3
"""Interleave two already-frozen plans, retaining every per-job guard/receipt."""
import argparse,json,subprocess,sys
from pathlib import Path
ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('left',type=Path);ap.add_argument('right',type=Path)
a=ap.parse_args();plans=[a.left.resolve(),a.right.resolve()];ps=[json.loads(f.read_text()) for f in plans]
assert [j['name'] for j in ps[0]['jobs']]==[j['name'] for j in ps[1]['jobs']]
for ix,j in enumerate(ps[0]['jobs']):
    for p in plans[::(-1 if ix%2 else 1)]:
        subprocess.run([sys.executable,'-B',str(Path(__file__).with_name('run.py')),'--plan',str(p),'--only',j['name']],check=True)
