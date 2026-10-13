#!/usr/bin/env python3
"""Fresh paired held-outs, using independently executed native C oracles."""
import argparse, hashlib, json, shutil
from pathlib import Path
p=argparse.ArgumentParser()
for n in ['parent','acquired','old','out']:p.add_argument('--'+n,type=Path,required=True)
a=p.parse_args()
def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),sha256=hashlib.sha256(b).hexdigest(),bytes=len(b))
out=a.out.resolve();assert 'selfhost/build/phase78/' in str(out);out.mkdir()
plan=json.loads(a.parent.read_text());old=json.loads(a.old.read_text())
plan['inputs'] += [pin(a.parent),pin(a.old),pin(__file__)]
cases={}
for name in ['small','functions65']:
 previous=old['cases'][name];expected={}
 for stage in ['b1','b2']:expected['old_'+stage]=previous['expected'][stage]
 for role,keys in [('candidate',['b1','b2']),('reference',['typescript'])]:
  f=a.acquired/'execution/selected'/(role+'.json');j=json.loads(f.read_text());assert j['selectedComplete']
  row=next(x for x in j['results'] if x['id']=='phase77/'+name+'.bend');assert row['status']=='pass'
  files=list(Path(row['artifacts']).glob('*.c'));assert len(files)==1;code=pin(files[0]);plan['inputs'] += [pin(f),code]
  for key in keys:expected[key]=code
 assert previous['input']==pin(previous['input']['file'])
 cases[name]=dict(input=previous['input'],expected=expected)
for role,r in plan['roles'].items():
 if role=='typescript':continue
 project=out/(role+'-project');shutil.copytree(r['project'],project,ignore=shutil.ignore_patterns('build'))
 r.update(project=str(project),driver=pin(project/'tools/typed-driver.mjs'),runtime=pin(project/'src/runtime.mjs'),preparation=str(out/'runs'/('prepare-'+role)/'report.json'))
 plan['inputs'] += [pin(f) for f in project.rglob('*') if f.is_file()]
plan['inputs'] += [pin(v['input']['file']) for v in cases.values()]
plan['inputs'] += [pin(v['expected'][k]['file']) for v in cases.values() for k in ['old_b1','old_b2']]
plan['cases']=cases;plan['jobs']=[dict(name='prepare-'+r,role=r,action='prepare',profile=False) for r in plan['roles'] if r!='typescript']
for i in range(3):
 for k,c in enumerate(cases):
  order=['old_b1','b1','old_b2','b2','typescript'];shift=(i+k)%5;order=order[shift:]+order[:shift]
  if i%2:order=list(reversed(order))
  for role in order:plan['jobs'].append(dict(name=f'clean-{i}-{c}-{role}',role=role,case=c,round=i,action='request',profile=False))
plan['scope']='Paired old/new B1/B2 and upstream on two non-IO held-outs. 30 fresh requests with exact independently executed C. Same prepared-frontend-only clock and no profiles.'
(out/'plan.json').write_text(json.dumps(plan,indent=2)+'\n');print(out/'plan.json')
