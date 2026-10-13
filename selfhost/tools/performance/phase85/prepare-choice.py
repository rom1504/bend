#!/usr/bin/env python3
"""Own and genuinely prepare Base for an unchecked saved-image diagnostic."""
import argparse, hashlib, json, shutil
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4]
def pin(p):
    p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),sha256=hashlib.sha256(b).hexdigest(),bytes=len(b))
ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('--api',required=True,type=Path);ap.add_argument('--out',required=True,type=Path)
a=ap.parse_args();out=a.out.resolve();out.mkdir(parents=True,exist_ok=False)
parent=ROOT/'selfhost/build/phase83/survey01/plan.json';p=json.loads(parent.read_text());old=p['roles']['b2'];project=out/'project'
for directory in ['src','tools']:shutil.copytree(Path(old['project'])/directory,project/directory)
p['roles']={'b2':{**old,'api':pin(a.api),'project':str(project),'driver':pin(project/'tools/typed-driver.mjs'),'runtime':pin(project/'src/runtime.mjs'),'preparation':str(out/'runs/prepare-b2/report.json')}}
p['jobs']=[dict(name='prepare-b2',role='b2',action='prepare',profile=False)]
p['inputs'] += [pin(parent),pin(__file__),pin(a.api),pin(ROOT/'selfhost/tools/performance/phase84/worker.mjs'),pin(ROOT/'selfhost/tools/performance/phase84/run.py')]+[pin(f) for f in project.rglob('*') if f.is_file()]
p['scope']='Unchecked generated-image diagnosis only. New API hash, new copied driver project, genuinely fresh prepared Base. Original production unchanged.'
(out/'plan.json').write_text(json.dumps(p,indent=2)+'\n');print(out/'plan.json')
