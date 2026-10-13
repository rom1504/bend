#!/usr/bin/env python3
"""Derive a profile or held-out plan from completed isolated preparation."""
import argparse,hashlib,json
from pathlib import Path
ROOT=Path('/home/ai/bend2/build/publish/bend');HERE=Path(__file__).resolve().parent
p=argparse.ArgumentParser();p.add_argument('parent',type=Path);p.add_argument('out',type=Path);p.add_argument('--heldout',type=Path);a=p.parse_args()
def pin(f):
 f=f.resolve();b=f.read_bytes();return dict(file=str(f),sha256=hashlib.sha256(b).hexdigest(),bytes=len(b))
j=json.loads(a.parent.read_text());j['preparedPlan']=pin(a.parent)
j['inputs'] += [pin(HERE/'profile/worker.mjs'),pin(HERE/'profile/run.py'),pin(Path(__file__)),pin(a.parent)]
if a.heldout:
 h=json.loads(a.heldout.read_text());j['inputs']+=h['inputs']+[pin(a.heldout)];j['cases']=h['cases']
 for c in j['cases'].values():
  e=c['expected'];c['expected']={r:e['typescript' if r=='typescript' else 'b1'] for r in j['roles']}
 j['jobs']=[]
 for n in range(2):
  for i,c in enumerate(j['cases']):
   order=['baseline','ordinary','library','typescript'];shift=(n+i)%4;order=order[shift:]+order[:shift]
   j['jobs'] += [dict(name=f'clean-{n}-{c}-{r}',role=r,case=c,action='request',profile=False,round=n) for r in order]
else:j['jobs']=[dict(name='profile-'+r+'-numeric',role=r,case='numeric',action='request',profile=True) for r in ['ordinary','library']]
out=a.out.resolve();assert out.is_relative_to(ROOT/'selfhost/build/phase79');out.mkdir();(out/'plan.json').write_text(json.dumps(j,indent=2)+'\n')
