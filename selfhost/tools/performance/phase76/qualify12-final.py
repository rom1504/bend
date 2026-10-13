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
run('identity12b-prepare',['python3',M/'prepare-c-identity.py','--attempt',R/'compiler12/attempt.json','--image-pins',R/'compiler12-b2/image-pins.json','--acquired',R/'compiler12-native06/report.json','--acquired',R/'compiler12-coverage06/report.json','--expected-cases','12','--out',R/'compiler12-C-identity12b'])
p=R/'compiler12-C-identity12b/plan.json';j=read(p)
run('identity12b-cache',['python3','selfhost/tools/performance/phase70/methods/compilation/run.py','--plan',p,'--group','prepare','--only','prepare-b2'])
run('identity12b-emit',['python3','selfhost/tools/performance/phase70/methods/compilation/run.py','--plan',p,'--group','clean','--only',','.join(x['name'] for x in j['jobs'] if x['action']=='request' and x['role']=='b2')])
for job in read(R/'compiler12-qualification-method/plan.json')['qualificationCommands']:run('qualification12-'+job['name'],job['command'])
run('js12-closure',['python3',M/'verify-js.py','selfhost/build/phase73/compiler14/equality/api.mjs',R/'compiler12/equality/api.mjs',R/'compiler12-js-closure'])
for label,script,dest in [('report','report-controls.mjs','compiler12-report-controls.json'),('ctor','ctor-controls.mjs','compiler12-ctor-controls'),('uses','uses-controls-v2.mjs','compiler12-uses-controls')]:
 run(label+'12-controls',['python3','selfhost/tools/performance/phase32/bounded-run.py','--seconds','45','--rss-mib','2048','--available-mib','4096',R/('compiler12-'+label+'-guard'),'taskset','-c','3','/home/ai/.nvm/versions/node/v24.18.0/bin/node','--max-old-space-size=1024','--stack-size=4096',M/script,R/'compiler12/equality/api.mjs',R/dest])
print('selected qualification finished; installation awaits review of results',flush=True)
