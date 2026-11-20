#!/usr/bin/env python3
"""Run the remaining already-frozen guarded native gates sequentially."""
import hashlib
import json
import subprocess
import time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
BUILD=ROOT/'selfhost/build/phase198'
def pin(path):
    p=Path(path).resolve(); data=p.read_bytes()
    return dict(file=str(p),bytes=len(data),sha256=hashlib.sha256(data).hexdigest())
journal=BUILD/'native-gates-journal01.json'
assert not journal.exists()
plan=['native45-02','native64-01','runtime10-01','native-generations-compare01']
result=dict(kind='phase198-sequential-native-gates',complete=False,method=pin(__file__),jobs=[])
def save():journal.write_text(json.dumps(result,indent=2)+'\n')
save()
for name in plan:
    argvfile=BUILD/(name+'-argv.json');argv=json.loads(argvfile.read_text())
    row=dict(name=name,argv=pin(argvfile),started=time.time());result['jobs'].append(row);save()
    print('START '+name,flush=True)
    rc=subprocess.run(argv,cwd=ROOT).returncode
    row.update(returncode=rc,finished=time.time());save()
    print('END '+name+' '+str(rc),flush=True)
    if rc:raise SystemExit(rc)
result['complete']=True;save()
