#!/usr/bin/env python3
import json,subprocess
from pathlib import Path
R=Path('selfhost/build/phase77');M=Path('selfhost/tools/performance/phase77')
def read(p):return json.loads(Path(p).read_text())
def run(name,cmd,check=True):
 print('starting '+name,flush=True)
 with (R/(name+'-controller.log')).open('x') as log:r=subprocess.run(list(map(str,cmd)),stdout=log,stderr=subprocess.STDOUT)
 print(name+' exit '+str(r.returncode),flush=True)
 if check:assert r.returncode==0,name
 return r.returncode
assert (R/'compiler01-b2/image-pins.json').exists()
for gate,selection,count in [('new14','selfhost/tools/performance/phase75/selection-new14.json',14),('native100','selfhost/build/phase75/compiler14-native100/selection.json',100),('word10',M/'selection-word10.json',10)]:
 run('prepare01-'+gate,['taskset','-c','0','python3',M/'prepare-custom.py','--attempt',R/'compiler01','--toolchain-recipe',R/'compiler01-native-recipe.json','--selection',selection,'--expected-cases',str(count),'--out',R/('compiler01-'+gate)])
cases=read('selfhost/build/phase75/compiler14-raw31/cases.json')
cmd=['taskset','-c','0','python3',M/'prepare-custom-raw.py','--baseline','selfhost/build/phase75/compiler14','--candidate',R/'compiler01','--toolchain-recipe',R/'compiler01-native-recipe.json','--expected-added-cases',str(cases['expectedAddedCases']),'--out',R/'compiler01-raw31']
for c in cases['modules']:cmd+=['--case-module',c['file']]
run('prepare01-raw31',cmd)
run('gate01-raw31',read(R/'compiler01-raw31/plan.json')['command'])
run('prepare01-qualification',['python3',M/'prepare-release-qualification.py','--attempt',R/'compiler01','--b2',R/'compiler01-b2','--native-recipe',R/'compiler01-native-recipe.json','--out',R/'compiler01-qualification-method','--qualification-out',R/'compiler01-qualification','--release-out',R/'compiler01-release'])
for gate in ['new14','word10','native100']:
 p=R/('compiler01-'+gate)/'plan.json';rc=run('gate01-'+gate,read(p)['command'],gate!='native100')
 if gate=='native100':
  def outcomes(j):return [(x['id'],x['lane'],x['status']) for x in j['results']]
  for role in ['candidate','reference']:
   current=read(p.parent/f'execution/selected/{role}.json');old=read(Path(f'selfhost/build/phase75/compiler14-native100/execution/selected/{role}.json'))
   assert current['selectedComplete']==old['selectedComplete'] and outcomes(current)==outcomes(old),(gate,role)
  (R/'native100-inventory01.json').write_text(json.dumps(dict(complete=True,**{'pass':True},candidatePass=100,referencePass=93,sameSevenReferenceFailures=True,controllerReturnCode=rc),indent=2)+'\n')
run('threads12',['python3',M/'recheck-controls.py','--gate',R/'compiler01-new14','--out',R/'compiler01-threads'])
run('identity01-prepare',['python3',M/'prepare-c-identity.py','--attempt',R/'compiler01/attempt.json','--image-pins',R/'compiler01-b2/image-pins.json','--acquired',R/'compiler01-native06/report.json','--acquired',R/'compiler01-coverage06/report.json','--expected-cases','12','--out',R/'compiler01-C-identity12'])
p=R/'compiler01-C-identity12/plan.json';j=read(p)
run('identity01-cache',['python3','selfhost/tools/performance/phase70/methods/compilation/run.py','--plan',p,'--group','prepare','--only','prepare-b2'])
run('identity01-emit',['python3','selfhost/tools/performance/phase70/methods/compilation/run.py','--plan',p,'--group','clean','--only',','.join(x['name'] for x in j['jobs'] if x['action']=='request' and x['role']=='b2')])
for job in read(R/'compiler01-qualification-method/plan.json')['qualificationCommands']:run('qualification01-'+job['name'],job['command'])
run('js01-closure',['python3',M/'verify-js.py','selfhost/build/phase73/compiler14/equality/api.mjs',R/'compiler01/equality/api.mjs',R/'compiler01-js-closure'])
run('word01-controls',['python3','selfhost/tools/performance/phase32/bounded-run.py','--seconds','45','--rss-mib','2048','--available-mib','4096',R/'word01-guard','taskset','-c','3','/home/ai/.nvm/versions/node/v24.18.0/bin/node','--max-old-space-size=1024','--stack-size=4096',M/'word-controls-v4.mjs',R/'compiler01/equality/api.mjs','selfhost/build/phase76/diagnostic02/trim-body.json',R/'word01-controls'])
print('selected source qualification finished; installation remains separate',flush=True)
