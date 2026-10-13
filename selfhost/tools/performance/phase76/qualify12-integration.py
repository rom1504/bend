#!/usr/bin/env python3
import json,subprocess
from pathlib import Path
R=Path('selfhost/build/phase76');M=Path('selfhost/tools/performance/phase76')
def read(p):return json.loads(Path(p).read_text())
def run(name,cmd,check=True):
 print('starting '+name,flush=True)
 with (R/(name+'-controller.log')).open('x') as log:r=subprocess.run(list(map(str,cmd)),stdout=log,stderr=subprocess.STDOUT)
 print(name+' exit '+str(r.returncode),flush=True)
 if check:assert r.returncode==0,name
 return r.returncode
assert (R/'compiler12-b2/image-pins.json').exists()
for gate,selection,count in [('new14','selfhost/tools/performance/phase75/selection-new14.json',14),('native100','selfhost/build/phase75/compiler14-native100/selection.json',100)]:
 run('prepare12-'+gate,['taskset','-c','0','python3',M/'prepare-custom.py','--attempt',R/'compiler12','--toolchain-recipe',R/'compiler12-native-recipe.json','--selection',selection,'--expected-cases',str(count),'--out',R/('compiler12-'+gate)])
cases=read('selfhost/build/phase75/compiler14-raw31/cases.json')
cmd=['taskset','-c','0','python3',M/'prepare-custom-raw.py','--baseline','selfhost/build/phase75/compiler14','--candidate',R/'compiler12','--toolchain-recipe',R/'compiler12-native-recipe.json','--expected-added-cases',str(cases['expectedAddedCases']),'--out',R/'compiler12-raw31']
for c in cases['modules']:cmd+=['--case-module',c['file']]
run('prepare12-raw31',cmd)
run('gate12-raw31',read(R/'compiler12-raw31/plan.json')['command'])
run('prepare12-qualification',['python3',M/'prepare-release-qualification.py','--attempt',R/'compiler12','--b2',R/'compiler12-b2','--native-recipe',R/'compiler12-native-recipe.json','--out',R/'compiler12-qualification-method','--qualification-out',R/'compiler12-qualification','--release-out',R/'compiler12-release'])
for gate in ['new14','native100']:
 p=R/('compiler12-'+gate)/'plan.json';rc=run('gate12-'+gate,read(p)['command'],gate!='native100')
 if gate=='native100':
  def outcomes(j):return [(x['id'],x['lane'],x['status']) for x in j['results']]
  for role in ['candidate','reference']:
   current=read(p.parent/f'execution/selected/{role}.json');old=read(Path(f'selfhost/build/phase75/compiler14-native100/execution/selected/{role}.json'))
   assert current['selectedComplete']==old['selectedComplete'] and outcomes(current)==outcomes(old),(gate,role)
  (R/'native100-inventory12.json').write_text(json.dumps(dict(complete=True,**{'pass':True},candidatePass=100,referencePass=93,sameSevenReferenceFailures=True,controllerReturnCode=rc),indent=2)+'\n')
run('threads12',['python3',M/'recheck-controls.py','--gate',R/'compiler12-new14','--out',R/'compiler12-threads'])
run('identity12-prepare',['python3',M/'prepare-c-identity.py','--attempt',R/'compiler12/attempt.json','--image-pins',R/'compiler12-b2/image-pins.json','--acquired',R/'compiler12-native06/report.json','--acquired',R/'compiler12-coverage06/report.json','--expected-cases','12','--out',R/'compiler12-C-identity12'])
p=R/'compiler12-C-identity12/plan.json';j=read(p)
run('identity12-cache',['python3','selfhost/tools/performance/phase70/methods/compilation/run.py','--plan',p,'--group','prepare','--only','prepare-b2'])
run('identity12-emit',['python3','selfhost/tools/performance/phase70/methods/compilation/run.py','--plan',p,'--group','clean','--only',','.join(x['name'] for x in j['jobs'] if x['action']=='request' and x['role']=='b2')])
for job in read(R/'compiler12-qualification-method/plan.json')['qualificationCommands']:run('qualification12-'+job['name'],job['command'])
run('js12-closure',['python3',M/'verify-js.py','selfhost/build/phase73/compiler14/equality/api.mjs',R/'compiler12/equality/api.mjs',R/'compiler12-js-closure'])
for label,script,dest in [('report','report-controls.mjs','compiler12-report-controls.json'),('ctor','ctor-controls.mjs','compiler12-ctor-controls'),('uses','uses-controls-v2.mjs','compiler12-uses-controls')]:
 run(label+'12-controls',['python3','selfhost/tools/performance/phase32/bounded-run.py','--seconds','45','--rss-mib','2048','--available-mib','4096',R/('compiler12-'+label+'-guard'),'taskset','-c','3','/home/ai/.nvm/versions/node/v24.18.0/bin/node','--max-old-space-size=1024','--stack-size=4096',M/script,R/'compiler12/equality/api.mjs',R/dest])
print('selected qualification finished; installation awaits review of results',flush=True)
