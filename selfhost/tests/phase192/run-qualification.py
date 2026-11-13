#!/usr/bin/env python3
"""Execute an authenticated, frozen serial qualification plan; no compiler logic."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import time
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--plan',type=Path,required=True)
p.add_argument('--out',type=Path,required=True)
a=p.parse_args()
assert not a.out.exists(), 'Fresh receipt required'
plan=json.loads(a.plan.read_text())
assert plan['readyToStart'] and plan['complete'] and not plan['executed']
def verify(item):
    file=Path(item['file']); data=file.read_bytes()
    assert len(data)==item['bytes'] and hashlib.sha256(data).hexdigest()==item['sha256'], str(file)
verify(plan['selectedSource'])
for item in plan['inputs']: verify(item)
result=dict(kind='phase192-serial-qualification-execution',complete=False,plan=str(a.plan.resolve()),
    planSha256=hashlib.sha256(a.plan.read_bytes()).hexdigest(),started=time.time(),steps=[])
def save():
    result['wallSeconds']=time.time()-result['started']
    a.out.write_text(json.dumps(result,indent=2)+'\n')
a.out.parent.mkdir(parents=True,exist_ok=True);save()
for step in plan['steps']:
    verify(plan['selectedSource'])
    start=time.time()
    row=dict(name=step['name'],started=start,complete=False);result['steps'].append(row);save()
    print('START',step['name'],flush=True)
    completed=subprocess.run(step['argv'])
    row.update(returncode=completed.returncode,wallSeconds=time.time()-start,complete=completed.returncode==0);save()
    if completed.returncode: sys.exit(completed.returncode)
result['complete']=True;save();print('QUALIFICATION COMPLETE',flush=True)
