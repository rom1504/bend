#!/usr/bin/env python3
"""Sequential bounded release qualification; never installs automatically."""
import json,subprocess,hashlib
from pathlib import Path
R=Path('selfhost/build/phase76');M=Path('selfhost/tools/performance/phase76');A=R/'compiler12'
def read(p):return json.loads(Path(p).read_text())
def run(name,cmd,check=True):
 print('starting '+name,flush=True)
 with (R/(name+'-controller.log')).open('x') as log:r=subprocess.run(list(map(str,cmd)),stdout=log,stderr=subprocess.STDOUT)
 print(name+' exit '+str(r.returncode),flush=True)
 if check:assert r.returncode==0,name
 return r.returncode
run('freeze12-native',['python3','selfhost/tools/performance/phase67/benchmark/freeze.py','--api',A/'equality/api.mjs','--out',R/'compiler12-native-recipe.json'])
run('freeze12-coverage',['python3',M/'coverage/freeze.py','--api',A/'equality/api.mjs','--out',R/'compiler12-coverage-recipe.json'])
admission=read(R/'compiler08-admission.json');driver=A.resolve()/'snapshot/tools/typed-driver.mjs';admission['driver']=dict(file=str(driver),sha256=hashlib.sha256(driver.read_bytes()).hexdigest())
(R/'compiler12-admission.json').write_text(json.dumps(admission,indent=2)+'\n')
run('b2-12-plan',['python3',M/'prepare-bootstrap.py','plan',A,R/'compiler12-b2','--admission',R/'compiler12-admission.json'])
run('acquire12-native',['python3','selfhost/tools/performance/phase67/benchmark/run.py','acquire','--recipe',R/'compiler12-native-recipe.json','--out',R/'compiler12-native06','--roles','selfhost','--cases','numeric,array,closures,tree,map,lexer'])
run('acquire12-coverage',['python3',M/'coverage/run.py','acquire','--recipe',R/'compiler12-coverage-recipe.json','--out',R/'compiler12-coverage06','--roles','selfhost'])
run('b2-12',['bash',R/'compiler12-b2/run.sh'])
run('compilation12-plan',['python3',M/'prepare-compilation-v2.py','--out',R/'compiler12-compilation','--attempt',A/'attempt.json','--image-pins',R/'compiler12-b2/image-pins.json','--acquired',R/'compiler12-native06/report.json','--reference-acquired','selfhost/build/phase67/native-baseline02/report.json','--reference-acquired','selfhost/build/phase67/native-heldout-baseline02/report.json','--rounds','3'])
run('paired12-plan',['python3',M/'pair-compilation-v2.py','--old','selfhost/build/phase75/compiler14-compilation/plan.json','--new',R/'compiler12-compilation/plan.json','--out',R/'paired12-compilation'])
for group in ['prepare','clean']:run('paired12-'+group,['python3',M/'compilation/run.py','--plan',R/'paired12-compilation/plan.json','--group',group])
print('measurement complete; no installation',flush=True)
