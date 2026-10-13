#!/usr/bin/env python3
import subprocess
from pathlib import Path
R=Path('selfhost/build/phase77');M=Path('selfhost/tools/performance/phase77')
for name,plan,groups in [('profile01',R/'compiler01-compilation/plan.json',['prepare','profile']),('diagnostic01',R/'diagnostic01/plan.json',['prepare','clean'])]:
 for group in groups:
  print('starting '+name+'-'+group,flush=True)
  with (R/(name+'-'+group+'-controller.log')).open('x') as f:r=subprocess.run(['python3',str(M/'compilation/run.py'),'--plan',str(plan),'--group',group],stdout=f,stderr=subprocess.STDOUT)
  assert r.returncode==0,(name,group)
