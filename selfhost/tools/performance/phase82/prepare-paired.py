#!/usr/bin/env python3
"""Freeze Phase78 and candidate B1/B2 against the same pinned TypeScript."""
import argparse, hashlib, json, shutil
from pathlib import Path
ROOT=Path('/home/ai/bend2/build/publish/bend'); HERE=Path(__file__).resolve().parent
p=argparse.ArgumentParser();p.add_argument('attempt',type=Path);p.add_argument('images',type=Path);p.add_argument('out',type=Path);p.add_argument('--heldout',action='store_true');p.add_argument('--rounds',type=int,default=3);a=p.parse_args()
def pin(file):
 file=Path(file).resolve();b=file.read_bytes();return dict(file=str(file),sha256=hashlib.sha256(b).hexdigest(),bytes=len(b))
parent=ROOT/('selfhost/build/phase78/heldout21-timing/plan.json' if a.heldout else 'selfhost/build/phase78/paired21-compilation/plan.json')
plan=json.loads(parent.read_text());attempt=json.loads(a.attempt.read_text());images=json.loads(a.images.read_text());assert attempt['checked']
assert images['b1']['sha256']==attempt['api']['sha256'];assert pin(images['b2']['file'])['sha256']==images['b2']['sha256']
out=a.out.resolve();assert out.is_relative_to(ROOT/'selfhost/build/phase82');out.mkdir()
roles={'typescript':plan['roles']['typescript']};inputs=plan['inputs']+[pin(parent),pin(a.attempt),pin(a.images),pin(__file__)]
for label,old,source,api in [
 ('baseline',plan['roles']['b1'],Path(plan['roles']['b1']['project']),plan['roles']['b1']['api']),
 ('ordinary',plan['roles']['b1'],Path(attempt['snapshot']['root']),pin(attempt['api']['file'])),
 ('baseline-b2',plan['roles']['b2'],Path(plan['roles']['b2']['project']),plan['roles']['b2']['api']),
 ('ordinary-b2',plan['roles']['b2'],Path(attempt['snapshot']['root']),pin(images['b2']['file']))]:
 project=out/label/'project';project.mkdir(parents=True)
 for rel in ['tools/typed-driver.mjs','tools/assemble.mjs','tools/native-build.mjs','tools/node-resource-args.mjs','tools/compiler-abi.mjs','tools/base-cache-graph.mjs','src/runtime.mjs','src/compiler.json']:
  target=project/rel;target.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(source/rel,target);inputs += [pin(source/rel),pin(target)]
 shutil.copytree(source/'src/runtime/native',project/'src/runtime/native')
 inputs += [pin(f) for directory in [source,project] for f in (directory/'src/runtime/native').rglob('*') if f.is_file()]
 inputs.append(pin(api['file']));roles[label]={**old,'project':str(project),'api':api,'driver':pin(project/'tools/typed-driver.mjs'),'runtime':pin(project/'src/runtime.mjs'),'nativeProducts':False,'preparation':str(out/'runs'/('prepare-'+label)/'report.json')}
for c in plan['cases'].values():
 expected=c['expected'];c['expected']={r:expected['typescript' if r=='typescript' else 'b1'] for r in roles}
plan['roles']=roles;plan['jobs']=[dict(name='prepare-'+r,role=r,action='prepare',profile=False) for r in roles if r!='typescript']
for round_ in range(a.rounds):
 for i,case in enumerate(plan['cases']):
  order=['baseline','ordinary','typescript','baseline-b2','ordinary-b2'];shift=(round_+i)%len(order);order=order[shift:]+order[:shift]
  for r in order:plan['jobs'].append(dict(name=f'clean-{round_}-{case}-{r}',role=r,case=case,action='request',profile=False,round=round_))
inputs += [pin(HERE/n) for n in ['worker-v2.mjs','run-v2.py']];plan['inputs']=inputs
plan['scope']='Phase82 paired fresh requests: Phase78 and candidate checked B1/genuine B2, pinned TypeScript. Exact previously executed C, ordinary reports enabled. Prepared Bend Base separate, backendProducts false, no process reuse.'
(out/'plan.json').write_text(json.dumps(plan,indent=2)+'\n');print(out/'plan.json')
