#!/usr/bin/env python3
"""Run an explicit serial target plan inside the root process-tree guard."""
import argparse, hashlib, json, os, subprocess, time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4]
def pin(p):
    p=Path(p).resolve();return dict(file=str(p),sha256=hashlib.sha256(p.read_bytes()).hexdigest(),bytes=p.stat().st_size)
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--plan',type=Path,required=True);p.add_argument('--out',type=Path,required=True)
a=p.parse_args();out=a.out.resolve()
assert sorted(os.sched_getaffinity(0))==[3]
assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase112')
out.mkdir(parents=True)
plan=json.loads(a.plan.read_text());(out/'plan.json').write_bytes(a.plan.read_bytes());(out/'method.py').write_bytes(Path(__file__).read_bytes())
r=dict(kind='phase112-serial-jobs',complete=False,inputs=[pin(a.plan),pin(__file__)],jobs=[])
def save():(out/'report.json').write_text(json.dumps(r,indent=2)+'\n')
save()
try:
    for i,j in enumerate(plan['jobs']):
        row=dict(name=j['name'],command=j['command']);r['jobs'].append(row);save()
        start=time.monotonic()
        with (out/f'{i}.stdout').open('xb') as so,(out/f'{i}.stderr').open('xb') as se:
            child=subprocess.run(j['command'],cwd=ROOT,stdout=so,stderr=se,timeout=j.get('seconds',120))
        row.update(seconds=time.monotonic()-start,status=child.returncode,stdout=pin(out/f'{i}.stdout'),stderr=pin(out/f'{i}.stderr'));save()
        print(json.dumps(row),flush=True)
        if child.returncode:raise RuntimeError('Failed '+j['name'])
    r['complete']=True
except BaseException as e:r['error']=repr(e);raise
finally:save()
