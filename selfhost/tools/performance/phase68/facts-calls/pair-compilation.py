"""Prepare fresh, alternating compiler20/compiler23 request jobs; data only."""
import argparse, hashlib, json, shutil
from pathlib import Path
p=argparse.ArgumentParser()
for n in ['baseline','candidate','out']:p.add_argument('--'+n,type=Path,required=True)
a=p.parse_args();a.out=a.out.resolve();a.out.mkdir(exist_ok=False)
inputs={}
def pin(f):
 f=Path(f).resolve();r=dict(file=str(f),sha256=hashlib.sha256(f.read_bytes()).hexdigest(),bytes=f.stat().st_size);inputs[str(f)]=r;return r
parents={r:json.loads(Path(pin(f)['file']).read_text()) for r,f in [('old',a.baseline),('new',a.candidate)]}
roles={};cases={};jobs=[]
for version,plan in parents.items():
 for x in plan['inputs']:assert pin(x['file'])==x
 for stage in ['b1','b2']:
  role=version+'-'+stage;old=plan['roles'][stage];project=a.out/role/'project'
  shutil.copytree(old['project'],project,ignore=shutil.ignore_patterns('build','__pycache__'))
  roles[role]={**old,'project':str(project),'driver':pin(project/'tools/typed-driver.mjs'),'runtime':pin(project/'src/runtime.mjs'),'preparation':str(a.out/'runs'/('prepare-'+role)/'report.json')}
  for f in project.rglob('*'):
   if f.is_file():pin(f)
  jobs.append(dict(name='prepare-'+role,role=role,action='prepare',profile=False))
 for case,c in plan['cases'].items():
  if case not in cases:cases[case]={**c,'expected':{}}
  assert cases[case]['input']==c['input']
  for stage in ['b1','b2']:cases[case]['expected'][version+'-'+stage]=c['expected'][stage]
for round_ in range(4):
 for case in cases:
  for stage in ['b1','b2']:
   versions=['old','new'] if round_%2==0 else ['new','old']
   for version in versions:
    role=version+'-'+stage
    jobs.append(dict(name=f'clean-{round_}-{case}-{role}',action='request',role=role,case=case,profile=False,round=round_))
result={**parents['new'],'kind':'phase68-native-compilation-plan','comparisonKind':'paired-old-new','parents':{r:pin(f) for r,f in [('old',a.baseline),('new',a.candidate)]},'roles':roles,'cases':cases,'jobs':jobs,'producer':pin(__file__),'inputs':list(inputs.values()),'scope':'Four alternating old/new rounds for each image stage and source; preparation and output paths are fresh. Each role reproduces its own qualified C. No TypeScript timing or profiles in this paired screen.'}
(a.out/'plan.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(dict(jobs=len(jobs),plan=str(a.out/'plan.json'))))
