#!/usr/bin/env python3
"""Build one shared leaf object and validate it against the actual old worker."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess
import time

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
def pin(p):
 p=Path(p);return dict(file=str(p),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
def checked(v):
 assert pin(v['file'])['sha256']==v['sha256'],v
 return v['file']
def main(out):
 assert os.sched_getaffinity(0)=={3}
 out.mkdir(parents=True,exist_ok=False);start=time.monotonic()
 f=json.loads((HERE/'frozen.json').read_text())
 r=dict(complete=False,freeze=pin(HERE/'frozen.json'),commands=[],scope=f['scope'])
 def save(): (out/'report.json').write_text(json.dumps(r,indent=2)+'\n')
 def run(argv,timeout=12):
  t=time.monotonic();p=subprocess.run(list(map(str,argv)),capture_output=True,text=True,timeout=timeout)
  r['commands'].append(dict(argv=list(map(str,argv)),status=p.returncode,stdout=p.stdout,stderr=p.stderr,wallSeconds=time.monotonic()-t));save()
  assert p.returncode==0,(argv,p.stdout,p.stderr)
  return p.stdout
 save()
 try:
  for v in f['inputs']:checked(v)
  cc=checked(f['compiler']);runtime=checked(f['runtime']);original=checked(f['originalObject'])
  helper=out/'scan.o';old=out/'original.o';controls=out/'controls'
  run([cc,*f['flags'],'-c',HERE/'scan.c','-o',helper])
  r['helperObject']=pin(helper);save()
  run([checked(f['objcopy']),'--redefine-sym','main=p199_retained_main',original,old])
  run([cc,*f['flags'],'-no-pie',HERE/'controls.c',helper,old,runtime,'-pthread','-lm','-o',controls])
  r['controlsExecutable']=pin(controls)
  text=run([controls]);(out/'controls.jsonl').write_text(text)
  rows=[json.loads(x) for x in text.splitlines()];independent=0
  for row in rows:
   if row['kind']!='vector':continue
   a=row['initial'].copy();carry=row['carry'];i=row['index']
   for _ in range(row['n']):
    i&=0xffffffff;carry=(carry+a[i&row['mask']])&0xffffffff;a[i&row['mask']]=carry^i;i=(i+1)&0xffffffff
   assert a==row['final'] and carry==row['result'],row
   independent+=1
  r['independentPythonFullStateChecks']=independent;r['checks']=rows
  assembly=run([checked(f['objdump']),'-dr','-Mintel',helper]);(out/'scan.asm').write_text(assembly)
  r['helperDisassembly']=pin(out/'scan.asm');r['complete']=True
 except Exception as e:
  r['error']=repr(e);raise
 finally:
  r['wallSeconds']=time.monotonic()-start;save()
 print(json.dumps({k:v for k,v in r.items() if k not in ['commands','checks']}))
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);main(p.parse_args().out)
