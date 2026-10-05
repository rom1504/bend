#!/usr/bin/env python3
"""Run the unchanged checked Phase52 direct acquisition with Phase53 lineage."""
import argparse, hashlib, json, runpy, sys
from pathlib import Path
sys.dont_write_bytecode = True
HERE=Path(__file__).resolve().parent
PARENT=HERE.parent/'phase52/prepare-v2.py'
WORKER=HERE.parent/'phase52/emit-worker-v2.mjs'
def pin(p):
 p=Path(p).resolve(strict=True);return dict(file=str(p),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
p=argparse.ArgumentParser(add_help=False)
p.add_argument('--attempt',type=Path,required=True);p.add_argument('--out',type=Path,required=True)
p.add_argument('--backend',choices=['direct'],default='direct');p.add_argument('--role',choices=['candidate'],default='candidate')
for n in ['cpu','heap-mib','rss-mib','available-mib']:p.add_argument('--'+n,type=int,required=True)
a,_=p.parse_known_args()
assert (a.cpu,a.heap_mib,a.rss_mib,a.available_mib)==(3,1024,2048,4096)
assert not a.out.exists()
inputs=[pin(__file__),pin(PARENT),pin(WORKER),pin(a.attempt/'attempt.json')]
assert inputs[1]['sha256']=='7a08af571e14ed0f508d49eb1a8560b76d05cd6cf6438b5f4d119fadc818b017'
assert inputs[2]['sha256']=='f730abcde7203c61339f4eafefa144bc5c01031d5a1936c88d493afd5fe2d4a1'
try:runpy.run_path(str(PARENT),run_name='__main__')
finally:
 if a.out.exists():
  changed=[r['file'] for r in inputs if pin(r['file'])!=r]
  report=dict(kind='phase53-inherited-checked-acquisition',inputs=inputs,inputsUnchanged=not changed,changedInputs=changed,
    scope='Unchanged Phase52 checked emitter/observer and single serial guard; inherited phase labels identify the method, not a historical compiler selection.')
  for key,name in [('manifest','manifest.json'),('preparation','preparation.json')]:
   if (a.out/name).exists():report[key]=pin(a.out/name)
  report['complete']=not changed and bool(report.get('manifest')) and json.loads((a.out/'manifest.json').read_text()).get('complete',False)
  with (a.out/'phase53-acquisition.json').open('x') as f:json.dump(report,f,indent=2);f.write('\n')
  assert not changed,changed
