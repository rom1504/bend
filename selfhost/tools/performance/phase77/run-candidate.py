#!/usr/bin/env python3
"""One guarded target at a time; selected compile loop before broad gates."""
import json,subprocess,hashlib
from pathlib import Path
R=Path('selfhost/build/phase77');M=Path('selfhost/tools/performance/phase77');A=R/'compiler01'
def read(p):return json.loads(Path(p).read_text())
def run(name,cmd):
 print('starting '+name,flush=True)
 with (R/(name+'-controller.log')).open('x') as log:r=subprocess.run(list(map(str,cmd)),stdout=log,stderr=subprocess.STDOUT)
 print(name+' exit '+str(r.returncode),flush=True)
 assert r.returncode==0,name
run('freeze01-native',['python3','selfhost/tools/performance/phase67/benchmark/freeze.py','--api',A/'equality/api.mjs','--out',R/'compiler01-native-recipe.json'])
run('freeze01-coverage',['python3',M/'coverage/freeze.py','--api',A/'equality/api.mjs','--out',R/'compiler01-coverage-recipe.json'])
run('acquire01-native',['python3','selfhost/tools/performance/phase67/benchmark/run.py','acquire','--recipe',R/'compiler01-native-recipe.json','--out',R/'compiler01-native06','--roles','selfhost','--cases','numeric,array,closures,tree,map,lexer'])
admission=read('selfhost/build/phase76/compiler12-admission.json');driver=A.resolve()/'snapshot/tools/typed-driver.mjs';admission['driver']=dict(file=str(driver),sha256=hashlib.sha256(driver.read_bytes()).hexdigest())
(R/'compiler01-admission.json').write_text(json.dumps(admission,indent=2)+'\n')
run('b2-01-plan',['python3',M/'prepare-bootstrap.py','plan',A,R/'compiler01-b2','--admission',R/'compiler01-admission.json'])
run('b2-01',['bash',R/'compiler01-b2/run.sh'])
run('compilation01-plan',['python3',M/'prepare-compilation-v2.py','--out',R/'compiler01-compilation','--attempt',A/'attempt.json','--image-pins',R/'compiler01-b2/image-pins.json','--acquired',R/'compiler01-native06/report.json','--reference-acquired','selfhost/build/phase67/native-baseline02/report.json','--reference-acquired','selfhost/build/phase67/native-heldout-baseline02/report.json','--rounds','3'])
run('paired01-plan',['python3',M/'pair-compilation-v2.py','--old','selfhost/build/phase76/compiler12-compilation/plan.json','--new',R/'compiler01-compilation/plan.json','--out',R/'paired01-compilation'])
for group in ['prepare','clean']:run('paired01-'+group,['python3',M/'compilation/run.py','--plan',R/'paired01-compilation/plan.json','--group',group])
run('acquire01-coverage',['python3',M/'coverage/run.py','acquire','--recipe',R/'compiler01-coverage-recipe.json','--out',R/'compiler01-coverage06','--roles','selfhost'])
print('measurements acquired; no installation',flush=True)
