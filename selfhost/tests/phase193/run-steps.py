#!/usr/bin/env python3
"""Execute explicit frozen argv files serially; targets keep individual guards."""
import argparse, hashlib, json, subprocess, time
from pathlib import Path
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--source',type=Path,required=True)
p.add_argument('--sha256',required=True)
p.add_argument('--out',type=Path,required=True)
p.add_argument('argv',type=Path,nargs='+')
a=p.parse_args()
assert not a.out.exists()
r=dict(complete=False,started=time.time(),source=str(a.source),sha256=a.sha256,steps=[])
def save():
 r['wallSeconds']=time.time()-r['started'];a.out.write_text(json.dumps(r,indent=2)+'\n')
a.out.parent.mkdir(parents=True,exist_ok=True);save()
for path in a.argv:
 assert hashlib.sha256(a.source.read_bytes()).hexdigest()==a.sha256
 data=path.read_bytes();cmd=json.loads(data)
 assert isinstance(cmd,list) and all(isinstance(x,str) for x in cmd)
 row=dict(argv=cmd,method=str(path),sha256=hashlib.sha256(data).hexdigest(),started=time.time())
 r['steps'].append(row);save();print('START',path.name,flush=True)
 result=subprocess.run(cmd)
 row.update(returncode=result.returncode,seconds=time.time()-row['started']);save()
 if result.returncode:raise SystemExit(result.returncode)
r['complete']=True;save()
