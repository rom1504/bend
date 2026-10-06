#!/usr/bin/env python3
"""Three serial guarded processes: private cache prime, lexer, Evening counters."""
import argparse, hashlib, json, sys, time
from pathlib import Path
HERE=Path(__file__).resolve().parent; ROOT=HERE.parents[4]; PROGRAMS=HERE.parents[1]/'programs'
sys.path.insert(0,str(PROGRAMS))
from support import ExecutionGuard, save
p=argparse.ArgumentParser(description=__doc__);p.add_argument('out',type=Path);a=p.parse_args()
out=a.out.resolve();assert out.is_relative_to(ROOT/'selfhost/build/phase59') and not out.exists()
NODE=Path('/home/ai/.nvm/versions/node/v24.18.0/bin/node');WORKER=HERE/'worker-v1.mjs'
PREP=ROOT/'selfhost/build/phase59/preparation01/prepare-direct.result.json'
DERIV=ROOT/'selfhost/build/phase59/counter-image01/derivation.json'
def identity(f):
 f=Path(f).resolve(strict=True);b=f.read_bytes();return dict(file=str(f),sha256=hashlib.sha256(b).hexdigest(),bytes=len(b))
inputs=[identity(f) for f in [__file__,WORKER,NODE,PREP,DERIV,PROGRAMS/'support.py',ROOT/'selfhost/build/phase59/latency-method01/setup.mjs']]
assert inputs[1]['sha256']=='90e6fe1f61003e303c04de567a57ddcbedfff1455bea7fcffd3e150a9f63c801'
assert inputs[4]['sha256']=='2227f48453eddbf2bcd711ed33641415098a3f67ff6927ae870054339b59d890'
def verify():
 for i in inputs:assert identity(i['file'])==i,i['file']
steps=[('prepare',[str(PREP),str(DERIV)],out/'preparation'),('sample',[str(out/'preparation/report.json'),'lexer'],out/'lexer'),('sample',[str(out/'preparation/report.json'),'test-evening-program'],out/'evening')]
out.mkdir(parents=True);report=dict(kind='phase59-guarded-counter-requests',complete=False,pass_=False,diagnosticOnly=True,inputs=inputs,
 resources=dict(cpu=3,heapMiB=1024,stackKiB=4096,rssMiB=2048,availableMiB=4096,childSeconds=120,totalSeconds=300),steps=[])
report['pass']=False;started=time.monotonic();save(out/'report.json',report)
try:
 with ExecutionGuard(rss_mib=2048,available_mib=4096) as guard:
  for n,(mode,args,dest) in enumerate(steps):
   verify();assert time.monotonic()<started+300,'Total deadline';command=['taskset','-c','3',str(NODE),'--max-old-space-size=1024','--stack-size=4096',str(WORKER),mode,*args,str(dest)]
   execution=guard.run(command,out/f'process-{n:02d}',min(started+300,time.monotonic()+120))
   file=dest/'report.json';observation=json.loads(file.read_text()) if file.exists() else None
   report['steps'].append(dict(mode=mode,command=command,execution=execution,result=identity(file) if file.exists() else None,observation=observation));save(out/'report.json',report)
   assert execution['complete'] and execution.get('returncode')==0 and observation and observation['complete'] and observation['pass']
   assert observation['requests']==(0 if mode=='prepare' else 1);verify()
 report['complete']=report['pass']=True
except BaseException as error:report['error']=repr(error);raise
finally:report['wallSeconds']=time.monotonic()-started;save(out/'report.json',report)
print(json.dumps(dict(complete=True,pass_=True,requests=2,report=str(out/'report.json'))))
