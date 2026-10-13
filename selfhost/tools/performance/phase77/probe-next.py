#!/usr/bin/env python3
import subprocess,json
from pathlib import Path
R=Path('selfhost/build/phase77');M=Path('selfhost/tools/performance/phase77');N='/home/ai/.nvm/versions/node/v24.18.0/bin/node'
def run(name,cmd):
 print('starting '+name,flush=True)
 with (R/(name+'-controller.log')).open('x') as f:r=subprocess.run(list(map(str,cmd)),stdout=f,stderr=subprocess.STDOUT)
 assert r.returncode==0,name
 print('passed '+name,flush=True)
run('string-controls',['python3','selfhost/tools/performance/phase46/job.py','--out',R/'string-controls-guard','--seconds','60','--',N,'--stack-size=4096','--max-old-space-size=1024',M/'string-controls.mjs',R/'compiler01-b2/full/compiler.mjs',R/'strings01/api.mjs',R/'string-controls'])
for group in ['prepare','clean']:run('strings01-'+group,['python3',M/'compilation/run.py','--plan',R/'strings01/plan.json','--group',group])
run('warm01-prepare',['python3',M/'compilation/run.py','--plan',R/'warm01/plan.json','--group','prepare'])
run('warm01-requests',['python3',M/'run-warm.py','--plan',R/'warm01/plan.json','--out',R/'warm01/requests'])
