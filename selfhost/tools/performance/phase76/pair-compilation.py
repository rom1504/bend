#!/usr/bin/env python3
"""Interleave old/new B1/B2 plus upstream using the unchanged request worker."""
import argparse, copy, hashlib, json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4]
p=argparse.ArgumentParser();p.add_argument('--old',required=True,type=Path);p.add_argument('--new',required=True,type=Path);p.add_argument('--out',required=True,type=Path);a=p.parse_args()
def read(p): return json.loads(p.read_text())
def pin(p):return dict(file=str(p.resolve()),sha256=hashlib.sha256(p.read_bytes()).hexdigest(),bytes=p.stat().st_size)
old,new=read(a.old),read(a.new);out=a.out.resolve();assert out.is_relative_to(ROOT/'selfhost/build/phase76');out.mkdir(exist_ok=False)
plan=copy.deepcopy(new);inputs={x['file']:x for x in old['inputs']}
for x in new['inputs']:
 if x['file'] in inputs: assert inputs[x['file']]==x
 inputs[x['file']]=x
for f in [a.old,a.new,Path(__file__)]:inputs[str(f.resolve())]=pin(f)
for stage in ['b1','b2']:
 role='old_'+stage;plan['roles'][role]=copy.deepcopy(old['roles'][stage])
 for case in plan['cases']:
  assert plan['cases'][case]['input']==old['cases'][case]['input']
  plan['cases'][case]['expected'][role]=old['cases'][case]['expected'][stage]
for role,r in plan['roles'].items():
 if role!='typescript':r['preparation']=str(out/'runs'/('prepare-'+role)/'report.json')
jobs=[dict(name='prepare-'+r,role=r,action='prepare',profile=False) for r in plan['roles'] if r!='typescript']
order=['old_b1','b1','old_b2','b2','typescript']
for round in range(3):
 for offset,case in enumerate(plan['cases']):
  shift=(round+offset)%len(order);roles=order[shift:]+order[:shift]
  if round%2:roles=list(reversed(roles))
  for role in roles:jobs.append(dict(name=f'clean-{round}-{case}-{role}',action='request',role=role,case=case,profile=False,round=round))
plan.update(producer=pin(Path(__file__)),inputs=list(inputs.values()),jobs=jobs,scope='Three rotated/reversed fresh-process rounds over numeric/array/lexer; old/new genuine B1/B2 and pinned upstream. Exact per-role C oracles, owned prepared Base, imports outside request. Serial CPU3; finite screening precision, no profile clocks.')
(out/'plan.json').write_text(json.dumps(plan,indent=2)+'\n');print(json.dumps(dict(jobs=len(jobs),plan=str(out/'plan.json'))))
