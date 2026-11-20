"""Acquire two independently frozen checked experiment APIs; no time overlap."""
import argparse
import json
from pathlib import Path
import subprocess
import sys

p=argparse.ArgumentParser();p.add_argument('--out',required=True,type=Path)
p.add_argument('pairs',nargs='+',metavar='FRESH_JOB:SOURCE_FOLDER')
a=p.parse_args()
a.out.mkdir(parents=True,exist_ok=False)
runs=[]
for item in a.pairs:
    name,source=item.split(':');assert all(x.replace('-','').isalnum() for x in [name,source])
    build=Path('selfhost/build/phase198')
    cmd=[sys.executable,'-B','research/phase198/qualification/job.py','--rss-mib','3072',name,'60','96',
        'selfhost/.assets/bin/bun','selfhost/tools/build/hosted.mjs','acquire','--source',str(build/source/'compiler.bend'),
        '--exports',str(build/source/'exports.json'),'--out',str(build/name),'--engine','selfhost/.assets/bin/bun',
        '--upstream','selfhost/.bootstrap/upstream-phase182']
    rc=subprocess.run(cmd).returncode
    runs.append({'name':name,'sourceFolder':source,'rc':rc,'argv':cmd})
    (a.out/'report.json').write_text(json.dumps({'complete':len(runs)==len(a.pairs),'results':runs},indent=2)+'\n')
print(runs)
if any(r['rc'] for r in runs):sys.exit(1)
