#!/usr/bin/env python3
"""One serial integration campaign; no installation or benchmark repetition."""
import json, subprocess
from pathlib import Path
R=Path('selfhost/build/phase82');M=Path('selfhost/tools/performance/phase82')
def read(p):return json.loads(Path(p).read_text())
def run(name,cmd,check=True):
 print('starting '+name,flush=True)
 with (R/(name+'-controller.log')).open('x') as log:
  rc=subprocess.run(list(map(str,cmd)),stdout=log,stderr=subprocess.STDOUT).returncode
 print(name+' exit '+str(rc),flush=True)
 if check:assert rc==0,name
 return rc
for gate in ['raw31','new14','word10','heldout2','native100']:
 p=R/('compiler04-'+gate)/'plan.json';rc=run('gate04-'+gate,read(p)['command'],gate!='native100')
 if gate=='native100':
  def outcomes(j):return [(x['id'],x['lane'],x['status']) for x in j['results']]
  for role in ['candidate','reference']:
   current=read(p.parent/f'execution/selected/{role}.json');old=read(f'selfhost/build/phase78/compiler21-native100/execution/selected/{role}.json')
   assert current['selectedComplete']==old['selectedComplete'] and outcomes(current)==outcomes(old),(gate,role)
  (R/'native100-inventory04.json').write_text(json.dumps(dict(complete=True,passed=True,candidatePass=100,referencePass=93,sameSevenReferenceFailures=True,controllerReturnCode=rc),indent=2)+'\n')
run('threads04',['python3',M/'recheck-controls.py','--gate',R/'compiler04-new14','--out',R/'compiler04-threads'])
p=R/'compiler04-C-identity12/plan.json'
for group in ['prepare','clean']:
 run('identity04-'+group,['python3','selfhost/tools/performance/phase70/methods/compilation/run.py','--plan',p,'--group',group])
for job in read(R/'compiler04-qualification-method/plan.json')['qualificationCommands']:
 run('qualification04-'+job['name'],job['command'])
run('js-continuity04',['python3','selfhost/tools/performance/phase46/job.py','--out',R/'js-continuity04-guard','--seconds','180','--','/home/ai/.nvm/versions/node/v24.18.0/bin/node','--stack-size=4096','--max-old-space-size=1024',M/'js-continuity.mjs',R/'compiler04-qualification-method/bootstrap/setup.mjs',R/'compiler04-b2/image-pins.json','selfhost/build/phase66/b1-07-full-acquisition/manifest.json',R/'js-continuity04'])
print('Qualification finished; promotion is a separate recorded decision.',flush=True)
