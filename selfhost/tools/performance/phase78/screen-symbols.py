#!/usr/bin/env python3
"""Fresh paired B1 screen against Phase77's independently executed exact-C oracles."""
import argparse,hashlib,json,shutil
from pathlib import Path
ROOT=Path('/home/ai/bend2/build/publish/bend')
p=argparse.ArgumentParser();p.add_argument('attempt',type=Path);p.add_argument('out',type=Path);p.add_argument('--rounds',type=int,default=2,choices=[1,2,3]);a=p.parse_args()
def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),sha256=hashlib.sha256(b).hexdigest(),bytes=len(b))
parent=ROOT/'selfhost/build/phase77/compiler01-compilation/plan.json'
plan=json.loads(parent.read_text());attempt=json.loads(a.attempt.read_text())
assert attempt['checked'] and attempt['artifactKind']=='derived-b1'
api=pin(attempt['api']['file']);assert api['sha256']==attempt['api']['sha256']
out=a.out.resolve();assert out.is_relative_to(ROOT/'selfhost/build/phase78');out.mkdir()
old=plan['roles']['b1'];roles={'typescript':plan['roles']['typescript']}
inputs=plan['inputs']+[pin(parent),pin(a.attempt),pin(__file__)]
for label,source,artifact in [('baselineB1',Path(old['project']),old['api']),('b1',Path(attempt['snapshot']['root']),api)]:
 project=out/label/'project';project.mkdir(parents=True)
 for rel in ['tools/typed-driver.mjs','tools/assemble.mjs','tools/native-build.mjs','tools/node-resource-args.mjs','tools/compiler-abi.mjs','tools/base-cache-graph.mjs','src/runtime.mjs','src/compiler.json']:
  target=project/rel;target.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(source/rel,target);inputs += [pin(source/rel),pin(target)]
 shutil.copytree(source/'src/runtime/native',project/'src/runtime/native')
 inputs += [pin(f) for f in (source/'src/runtime/native').rglob('*') if f.is_file()]
 inputs += [pin(f) for f in (project/'src/runtime/native').rglob('*') if f.is_file()]
 inputs.append(pin(artifact['file']))
 roles[label]={**old,'project':str(project),'api':artifact,'driver':pin(project/'tools/typed-driver.mjs'),'runtime':pin(project/'src/runtime.mjs'),'preparation':str(out/'runs'/('prepare-'+label)/'report.json')}
import runpy
translator=Path(__file__).with_name('compact-symbols.py');translate=runpy.run_path(str(translator))['translate'];inputs.append(pin(translator))
for name,c in plan['cases'].items():
 c['expected']['baselineB1']=c['expected']['b1']
 text,mapping=translate(Path(c['expected']['b1']['file']).read_text())
 oracle=out/(name+'-symbols.c');oracle.write_text(text)
 derivation=out/(name+'-symbols.json');derivation.write_text(json.dumps(dict(parent=c['expected']['b1'],method=pin(translator),output=pin(oracle),mapping=mapping,scope='Independent lexical identifier substitution of executed Phase77 C. All non-symbol tokens, strings and comments retained.'),indent=2)+'\n')
 inputs.extend([pin(oracle),pin(derivation)]);c['expected']['b1']=pin(oracle)
plan['roles']=roles;plan['jobs']=[dict(name='prepare-'+r,role=r,action='prepare',profile=False) for r in ['baselineB1','b1']]
for round_ in range(a.rounds):
 for i,case in enumerate(plan['cases']):
  order=['baselineB1','b1','typescript'];shift=(round_+i)%3;order=order[shift:]+order[:shift]
  for r in order:plan['jobs'].append(dict(name=f'clean-{round_}-{case}-{r}',role=r,case=case,action='request',profile=False,round=round_))
inputs += [pin(ROOT/'selfhost/tools/performance/phase78/compilation'/n) for n in ['worker.mjs','run.py']]
plan['inputs']=inputs;plan['candidateAttempt']=pin(a.attempt)
plan['scope']='Two-round alpha-renamed C screen: checked candidate B1, Phase77 checked B1, pinned upstream. Same prepared Base contract. No B2 or release qualification implied.'
(out/'plan.json').write_text(json.dumps(plan,indent=2)+'\n')
print(out/'plan.json')
