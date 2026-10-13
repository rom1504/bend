#!/usr/bin/env python3
"""Freeze a fresh investigation lane, reusing unmodified Phase83 owned inputs."""
import argparse, hashlib, json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4]
HERE=Path(__file__).resolve().parent
def pin(p):
    p=Path(p).resolve();b=p.read_bytes()
    return dict(file=str(p),sha256=hashlib.sha256(b).hexdigest(),bytes=len(b))
ap=argparse.ArgumentParser(description=__doc__)
ap.add_argument('--out',type=Path,required=True)
ap.add_argument('--mode',choices=['clean','trace','cpu','bytecode','tier'],required=True)
ap.add_argument('--cases',default='numeric,map,functions65,lexer')
ap.add_argument('--roles',default='b2,typescript')
ap.add_argument('--rounds',type=int,default=1)
ap.add_argument('--calls',type=int,default=5)
ap.add_argument('--flags',default='',help='Space-separated fixed V8 flags, no shell evaluation')
args=ap.parse_args();out=args.out.resolve();out.mkdir(parents=True,exist_ok=False)
parent=ROOT/'selfhost/build/phase83/survey01/plan.json';old=json.loads(parent.read_text())
roles={r:old['roles'][r] for r in args.roles.split(',')}
if 'b2' in roles:roles['b2']['preparationPlan']=pin(parent)
cases={c:old['cases'][c] for c in args.cases.split(',')}
flags=args.flags.split()
if args.mode=='trace':flags+=['--trace-opt','--trace-deopt','--trace-turbo-inlining','--trace-gc']
jobs=[]
for rnd in range(args.rounds):
    for ix,c in enumerate(cases):
        names=list(roles)
        if (rnd+ix)%2:names.reverse()
        for r in names:
            jobs.append(dict(name=f'{args.mode}-{rnd+1}-{c}-{r}',mode=args.mode,role=r,case=c,calls=args.calls,
                profileCalls=([1,args.calls] if args.mode=='cpu' else [])))
p=dict(kind='phase85-v8-compiler-plan',parent=pin(parent),roles=roles,cases=cases,jobs=jobs,
    cpu=3,rssMiB=2048,availableMiB=4096,seconds=90,nodeArgs=['--max-old-space-size=1024','--stack-size=4096',*flags],
    inputs=old['inputs']+[pin(parent),pin(HERE/'worker.mjs'),pin(HERE/'run.py'),pin(__file__)])
(out/'plan.json').write_text(json.dumps(p,indent=2)+'\n');print(out/'plan.json')
