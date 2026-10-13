#!/usr/bin/env python3
import json,hashlib,shutil
from pathlib import Path
R=Path('selfhost/build/phase78');M=Path('selfhost/tools/performance/phase77');out=R/'generalization01-timing';out.mkdir()
def pin(p):
 p=Path(p).resolve();return dict(file=str(p),sha256=hashlib.sha256(p.read_bytes()).hexdigest(),bytes=p.stat().st_size)
parent=R/'compiler01-compilation/plan.json';j=json.loads(parent.read_text());j['inputs'] += [pin(parent),pin(__file__)]
for role,r in j['roles'].items():
 if role=='typescript':continue
 project=out/role/'project';shutil.copytree(r['project'],project,ignore=shutil.ignore_patterns('build'))
 r.update(project=str(project.resolve()),driver=pin(project/'tools/typed-driver.mjs'),runtime=pin(project/'src/runtime.mjs'),preparation=str((out/'runs'/('prepare-'+role)/'report.json').resolve()))
 j['inputs'] += [pin(f) for f in project.rglob('*') if f.is_file()]
j['cases']={}
for n in ['small','functions65']:
 source=pin(M/'fixtures'/(n+'.bend'));j['inputs'].append(source);expected={}
 for role in ['candidate','reference']:
  report=R/'generalization01/execution/selected'/(role+'.json');g=json.loads(report.read_text());row=next(x for x in g['results'] if x['id']=='phase77/'+n+'.bend');assert row['status']=='pass'
  cs=list(Path(row['artifacts']).glob('*.c'));assert len(cs)==1;code=pin(cs[0]);j['inputs'] += [pin(report),code]
  for r in (['b1','b2'] if role=='candidate' else ['typescript']):expected[r]=code
 j['cases'][n]=dict(input=source,expected=expected)
j['jobs']=[dict(name='prepare-'+r,role=r,action='prepare',profile=False) for r in ['b1','b2']]
for i in range(3):
 for k,c in enumerate(j['cases']):
  order=['b1','b2','typescript'];shift=(i+k)%3;order=order[shift:]+order[:shift]
  for role in order:j['jobs'].append(dict(name=f'clean-{i}-{c}-{role}',role=role,case=c,round=i,action='request',profile=False))
j['scope']='Held-out small source and 65-function user workload without benchmark IO argument readers. Three rotated fresh requests per role/source; exact independent conformance C oracle.'
(out/'plan.json').write_text(json.dumps(j,indent=2)+'\n')
