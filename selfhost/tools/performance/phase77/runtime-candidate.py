#!/usr/bin/env python3
import subprocess,json
from pathlib import Path
R=Path('selfhost/build/phase77');M=Path('selfhost/tools/performance/phase77')
def run(name,cmd):
 print('starting '+name,flush=True)
 with (R/(name+'-controller.log')).open('x') as f:r=subprocess.run(list(map(str,cmd)),stdout=f,stderr=subprocess.STDOUT)
 assert r.returncode==0,name
 print('passed '+name,flush=True)
run('runtime01-six',['python3',M/'compare-native.py','--candidate',R/'compiler01-native06','--out',R/'runtime01-six','--rounds','3'])
run('runtime01-coverage',['python3',M/'coverage/compare.py','--baseline','selfhost/build/phase73/compiler14-coverage06','--upstream','selfhost/build/phase70/coverage-baseline01','selfhost/build/phase70/compiler02-coverage-baseline-holdouts01','--plan','selfhost/build/phase77/coverage-counts.json','--candidate',R/'compiler01-coverage06','--out',R/'runtime01-coverage','--rounds','3'])
