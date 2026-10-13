#!/usr/bin/env python3
"""Freeze unchanged Phase78 roles for a five-source diagnostic survey."""
import hashlib,json,shutil
from pathlib import Path
ROOT=Path('/home/ai/bend2/build/publish/bend'); HERE=Path(__file__).resolve().parent
OUT=ROOT/'selfhost/build/phase81/survey01'
def pin(p):
 p=Path(p).resolve(); b=p.read_bytes()
 return dict(file=str(p),sha256=hashlib.sha256(b).hexdigest(),bytes=len(b))
parents=[ROOT/'selfhost/build/phase78'/n/'plan.json' for n in ['paired21-compilation','heldout21-timing']]
plan,held=[json.loads(p.read_text()) for p in parents]
OUT.mkdir(parents=True,exist_ok=False)
inputs=plan['inputs']+held['inputs']+[pin(p) for p in parents]
plan['cases'].update(held['cases'])
roles={'typescript':plan['roles']['typescript']}
for label in ['b1','b2']:
 old=plan['roles'][label]; source=Path(old['project']); project=OUT/label/'project'
 project.mkdir(parents=True)
 for rel in ['tools/typed-driver.mjs','tools/assemble.mjs','tools/native-build.mjs','tools/node-resource-args.mjs','tools/compiler-abi.mjs','tools/base-cache-graph.mjs','src/runtime.mjs','src/compiler.json']:
  target=project/rel;target.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(source/rel,target);inputs += [pin(source/rel),pin(target)]
 shutil.copytree(source/'src/runtime/native',project/'src/runtime/native')
 inputs += [pin(f) for f in (project/'src/runtime/native').rglob('*') if f.is_file()]
 roles[label]={**old,'project':str(project),'driver':pin(project/'tools/typed-driver.mjs'),'runtime':pin(project/'src/runtime.mjs'),'nativeProducts':False,'preparation':str(OUT/'runs'/('prepare-'+label)/'report.json')}
plan['roles']=roles
for c in plan['cases'].values(): c['expected']={r:c['expected'][r] for r in roles}
jobs=[dict(name='prepare-'+r,role=r,action='prepare',profile=False) for r in ['b1','b2']]
for round_ in range(3):
 for i,case in enumerate(plan['cases']):
  order=['b1','b2','typescript']; shift=(round_+i)%3;order=order[shift:]+order[:shift]
  # Alternate ordinary and no-report B2 placement. This is a different API contract.
  for r in order:
   j=dict(name=f'clean-{round_}-{case}-{r}',role=r,case=case,action='request',profile=False,round=round_)
   quiet={**j,'name':j['name']+'-quiet','withReport':False}
   if r=='b2' and case in ['numeric','array','lexer'] and round_%2: jobs.append(quiet)
   jobs.append(j)
   if r=='b2' and case in ['numeric','array','lexer'] and not round_%2: jobs.append(quiet)
for case in plan['cases']:
 for r in ['b1','b2','typescript']:
  jobs.append(dict(name=f'profile-{case}-{r}',role=r,case=case,action='request',profile=True))
for r in ['b1','b2','typescript']:
 jobs.append(dict(name=f'profile-heap-numeric-{r}',role=r,case='numeric',action='request',profile=True,heap=True))
plan['jobs']=jobs
plan['inputs']=list({p['file']:p for p in inputs+[pin(HERE/n) for n in ['worker.mjs','run.py','prepare.py']]}.values())
plan['scope']='Phase81 investigation only. Unchanged Phase78 B1/B2, upstream0592662. Fresh checked C requests; imports and explicit Base excluded; backendProducts false. Quiet API is a separately labelled contract ablation. Profiles are diagnostic, never clean speedups.'
(OUT/'plan.json').write_text(json.dumps(plan,indent=2)+'\n')
print(OUT/'plan.json')
