#!/usr/bin/env python3
"""Held-out timing, JS continuity and diagnostic profiles after selected gates."""
import json, subprocess
from pathlib import Path
R=Path('selfhost/build/phase78');M=Path('selfhost/tools/performance/phase78')
assert json.loads((R/'runtime21-coverage/report.json').read_text())['complete']
def run(name,cmd):
 print('starting '+name,flush=True)
 with (R/(name+'-controller.log')).open('x') as log:
  rc=subprocess.run(list(map(str,cmd)),stdout=log,stderr=subprocess.STDOUT).returncode
 print(name+' exit '+str(rc),flush=True);assert rc==0,name
for group in ['prepare','clean']:
 run('heldout21-'+group,['python3',M/'compilation/run.py','--plan',R/'heldout21-timing/plan.json','--group',group])
run('js-continuity21',['python3','selfhost/tools/performance/phase46/job.py','--out',R/'js-continuity21-guard','--seconds','180','--','/home/ai/.nvm/versions/node/v24.18.0/bin/node','--stack-size=4096','--max-old-space-size=1024',M/'js-continuity.mjs',R/'compiler21-qualification-method/bootstrap/setup.mjs',R/'compiler21-b2/image-pins.json','selfhost/build/phase66/b1-07-full-acquisition/manifest.json',R/'js-continuity21'])
for group in ['prepare','profile']:
 run('profile21-'+group,['python3',M/'compilation/run.py','--plan',R/'compiler21-compilation/plan.json','--group',group])
print('held-out, JS continuity and profiles completed',flush=True)
