#!/usr/bin/env python3
"""Freeze separate installed baseline and candidate request roles."""
import argparse,hashlib,json,shutil
from pathlib import Path
ROOT=Path('/home/ai/bend2/build/publish/bend');HERE=Path(__file__).resolve().parent
p=argparse.ArgumentParser();p.add_argument('attempt',type=Path);p.add_argument('out',type=Path);p.add_argument('--rounds',type=int,default=2);a=p.parse_args()
def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),sha256=hashlib.sha256(b).hexdigest(),bytes=len(b))
parent=ROOT/'selfhost/build/phase78/paired21-compilation/plan.json';plan=json.loads(parent.read_text());attempt=json.loads(a.attempt.read_text());assert attempt['checked']
out=a.out.resolve();assert out.is_relative_to(ROOT/'selfhost/build/phase80');out.mkdir()
old=plan['roles']['b1'];roles={'typescript':plan['roles']['typescript']};inputs=plan['inputs']+[pin(parent),pin(a.attempt),pin(__file__)]
for label,source,api in [('baseline',Path(old['project']),old['api']),('ordinary',Path(attempt['snapshot']['root']),pin(attempt['api']['file']))]:
 project=out/label/'project';project.mkdir(parents=True)
 for rel in ['tools/typed-driver.mjs','tools/assemble.mjs','tools/native-build.mjs','tools/node-resource-args.mjs','tools/compiler-abi.mjs','tools/base-cache-graph.mjs','src/runtime.mjs','src/compiler.json']:
  target=project/rel;target.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(source/rel,target);inputs += [pin(source/rel),pin(target)]
 shutil.copytree(source/'src/runtime/native',project/'src/runtime/native')
 inputs += [pin(f) for directory in [source,project] for f in (directory/'src/runtime/native').rglob('*') if f.is_file()]
 inputs.append(pin(api['file']));roles[label]={**old,'project':str(project),'api':api,'driver':pin(project/'tools/typed-driver.mjs'),'runtime':pin(project/'src/runtime.mjs'),'nativeProducts':False,'preparation':str(out/'runs'/('prepare-'+label)/'report.json')}
for c in plan['cases'].values():
 expected=c['expected'];c['expected']={r:expected['typescript' if r=='typescript' else 'b1'] for r in roles}
plan['roles']=roles;plan['jobs']=[dict(name='prepare-'+r,role=r,action='prepare',profile=False) for r in ['baseline','ordinary']]
for round_ in range(a.rounds):
 for i,case in enumerate(plan['cases']):
  order=['baseline','ordinary','typescript'];shift=(round_+i)%3;order=order[shift:]+order[:shift]
  for r in order:plan['jobs'].append(dict(name=f'clean-{round_}-{case}-{r}',role=r,case=case,action='request',profile=False,round=round_))
inputs += [pin(HERE/n) for n in ['worker.mjs','run.py']];plan['inputs']=inputs
plan['scope']='Phase80 discriminator: Phase78 B1, candidate B1, pinned TypeScript. Exact previously executed C. Fresh request includes check and emission; prepared Base separate; backendProducts false. No release or parity claim.'
(out/'plan.json').write_text(json.dumps(plan,indent=2)+'\n');print(out/'plan.json')
