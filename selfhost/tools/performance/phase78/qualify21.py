#!/usr/bin/env python3
"""Serial qualification of selected compiler21; installation remains separate."""
import json, subprocess
from pathlib import Path
R=Path('selfhost/build/phase78');M=Path('selfhost/tools/performance/phase78');A=R/'compiler21'
def read(p):return json.loads(Path(p).read_text())
def run(name,cmd,check=True):
 print('starting '+name,flush=True)
 with (R/(name+'-controller.log')).open('x') as log:
  rc=subprocess.run(list(map(str,cmd)),stdout=log,stderr=subprocess.STDOUT).returncode
 print(name+' exit '+str(rc),flush=True)
 if check:assert rc==0,name
 return rc
assert read(R/'compiler21-b2/image-pins.json')['b1']['sha256']==read(A/'attempt.json')['api']['sha256']
run('acquire21-native',['python3','selfhost/tools/performance/phase67/benchmark/run.py','acquire','--recipe',R/'compiler21-native-recipe.json','--out',R/'compiler21-native06','--roles','selfhost','--cases','numeric,array,closures,tree,map,lexer'])
run('acquire21-coverage',['python3',M/'coverage/run.py','acquire','--recipe',R/'compiler21-coverage-recipe.json','--out',R/'compiler21-coverage06','--roles','selfhost'])
run('compilation21-plan',['python3',M/'prepare-compilation-v2.py','--out',R/'compiler21-compilation','--attempt',A/'attempt.json','--image-pins',R/'compiler21-b2/image-pins.json','--acquired',R/'compiler21-native06/report.json','--reference-acquired','selfhost/build/phase67/native-baseline02/report.json','--reference-acquired','selfhost/build/phase67/native-heldout-baseline02/report.json','--rounds','3'])
run('paired21-plan',['python3',M/'pair-compilation-v2.py','--old','selfhost/build/phase77/compiler01-compilation/plan.json','--new',R/'compiler21-compilation/plan.json','--out',R/'paired21-compilation'])
for group in ['prepare','clean']:
 run('paired21-'+group,['python3',M/'compilation/run.py','--plan',R/'paired21-compilation/plan.json','--group',group])
run('prepare21-qualification',['python3',M/'prepare-release-qualification.py','--attempt',A,'--b2',R/'compiler21-b2','--native-recipe',R/'compiler21-native-recipe.json','--out',R/'compiler21-qualification-method','--qualification-out',R/'compiler21-qualification','--release-out',R/'compiler21-release'])
for gate in ['raw31','new14','word10','heldout2','native100']:
 p=R/('compiler21-'+gate)/'plan.json';rc=run('gate21-'+gate,read(p)['command'],gate!='native100')
 if gate=='native100':
  def outcomes(j):return [(x['id'],x['lane'],x['status']) for x in j['results']]
  for role in ['candidate','reference']:
   current=read(p.parent/f'execution/selected/{role}.json');old=read(f'selfhost/build/phase77/compiler01-native100/execution/selected/{role}.json')
   assert current['selectedComplete']==old['selectedComplete'] and outcomes(current)==outcomes(old),(gate,role)
  (R/'native100-inventory21.json').write_text(json.dumps(dict(complete=True,**{'pass':True},candidatePass=100,referencePass=93,sameSevenReferenceFailures=True,controllerReturnCode=rc),indent=2)+'\n')
run('gate21-js9',['python3','selfhost/tools/performance/phase46/job.py','--out',R/'compiler21-js9-guard','--seconds','180','--','/home/ai/.nvm/versions/node/v24.18.0/bin/node','--stack-size=4096','--max-old-space-size=1024','selfhost/tools/development/workflow.mjs','validate',A,M/'selection-js9.json',R/'compiler21-js9'])
run('threads21',['python3',M/'recheck-controls.py','--gate',R/'compiler21-new14','--out',R/'compiler21-threads'])
run('identity21-prepare',['python3',M/'prepare-c-identity.py','--attempt',A/'attempt.json','--image-pins',R/'compiler21-b2/image-pins.json','--acquired',R/'compiler21-native06/report.json','--acquired',R/'compiler21-coverage06/report.json','--expected-cases','12','--out',R/'compiler21-C-identity12'])
p=R/'compiler21-C-identity12/plan.json';j=read(p)
run('identity21-cache',['python3',M/'compilation/run.py','--plan',p,'--group','prepare','--only','prepare-b2'])
run('identity21-emit',['python3',M/'compilation/run.py','--plan',p,'--group','clean','--only',','.join(x['name'] for x in j['jobs'] if x['action']=='request' and x['role']=='b2')])
for job in read(R/'compiler21-qualification-method/plan.json')['qualificationCommands']:
 run('qualification21-'+job['name'],job['command'])
run('runtime21-six',['python3',M/'compare-native.py','--candidate',R/'compiler21-native06','--out',R/'runtime21-six','--rounds','3'])
run('runtime21-coverage',['python3',M/'coverage/compare.py','--baseline','selfhost/build/phase77/compiler01-coverage06','--upstream','selfhost/build/phase70/coverage-baseline01','selfhost/build/phase70/compiler02-coverage-baseline-holdouts01','--plan','selfhost/build/phase77/coverage-counts.json','--candidate',R/'compiler21-coverage06','--out',R/'runtime21-coverage','--rounds','3'])
print('selected compiler qualification completed; installation and held-out timing are separate',flush=True)
