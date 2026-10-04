#!/usr/bin/env python3
"""Serial, checked four-way executable acquisition and correctness pilot."""
import argparse, importlib.util, json, os, time, hashlib
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4]
spec=importlib.util.spec_from_file_location('support',ROOT/'selfhost/tools/performance/programs/support.py')
s=importlib.util.module_from_spec(spec);spec.loader.exec_module(s)
p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True)
p.add_argument('--cases',default='numeric,closures');p.add_argument('--batch',action='store_true')
a=p.parse_args();a.out=a.out.resolve();a.out.mkdir(parents=True,exist_ok=False)
node='/home/ai/.nvm/versions/node/v24.18.0/bin/node'
clang='/home/ai/.elan/toolchains/leanprover--lean4---v4.32.0/bin/clang'
cases=json.loads((ROOT/'selfhost/tools/performance/phase46/cases.json').read_text())
assert set(a.cases.split(',')) <= {c['name'] for c in cases}, 'Unknown case'
for c in cases:assert hashlib.sha256((ROOT/c['source']).read_bytes()).hexdigest()==c['sha256']
records=[];begin=time.time()
with s.ExecutionGuard(rss_mib=2048,available_mib=4096) as guard:
 for case in cases:
  if case['name'] not in a.cases.split(','):continue
  for role,target in [('upstream','js'),('selfhost','js'),('upstream','c'),('selfhost','c')]:
   name=case['name']+'-'+role+'-'+target;out=a.out/name;out.mkdir()
   source=ROOT/case['wrapper'];source=source.with_name(source.stem+'-batch.bend') if a.batch else source
   emitted=out/('program.'+(('cjs' if role=='upstream' else 'mjs') if target=='js' else 'c'))
   cmd=[node,'--max-old-space-size=1024',str(ROOT/'selfhost/tools/performance/phase46/emit.mjs'),role,target,str(source),str(emitted)]
   r={'case':case['name'],'role':role,'target':target,'source':s.identity(source),'expected':case['expected']}
   r['emission']=guard.run(['taskset','-c','3',*cmd],out/'emission',time.monotonic()+120)
   if r['emission']['complete']:
    if target=='c':
     r['toolchain']=guard.run(['taskset','-c','3',clang,'-isystem','/home/ai/.elan/toolchains/leanprover--lean4---v4.32.0/include/clang','-std=c11','-O3',str(emitted),'-lpthread','-lm','-o',str(out/'program')],out/'toolchain',time.monotonic()+90)
    if target=='js' or r['toolchain']['complete']:
     cmd=([node,'--max-old-space-size=1024',str(emitted)] if target=='js' else [str(out/'program')])+['--threads','1','--gpu','off']
     if a.batch:cmd+=['--','1','0']
     r['execution']=guard.run(['taskset','-c','3',*cmd],out/'execution',time.monotonic()+20)
     r['stdout']=(out/'execution/stdout.log').read_text().strip()
     r['stderr']=(out/'execution/stderr.log').read_text().strip()
     if a.batch:
      words=r['stdout'].splitlines()
      expected=[case['expected'],2166136261,((2166136261*16777619)^case['expected'])&0xffffffff]
      r['expectedBatch']=expected
      r['correct']=r['execution']['complete'] and len(words)==4 and all(x.isdecimal() for x in words) and list(map(int,words[:3]))==expected
     else:r['correct']=r['execution']['complete'] and r['stdout']==str(case['expected'])
   records.append(r)
   s.save(a.out/'report.json',{'started':begin,'finished':time.time(),'node':s.identity(node),'clang':s.identity(clang),'producer':s.identity(__file__),'records':records})
   print(json.dumps({'name':name,'correct':r.get('correct',False),'emission':r['emission']['wallSeconds'],'compile':r.get('toolchain',{}).get('wallSeconds'),'stdout':r.get('stdout',''),'stderr':r.get('stderr','')[:300]}),flush=True)
   if guard.interrupted:raise SystemExit(1)
assert len(records)==len(a.cases.split(','))*4
for c in cases:assert hashlib.sha256((ROOT/c['source']).read_bytes()).hexdigest()==c['sha256']
raise SystemExit(0 if all(r.get('correct',False) for r in records) else 1)
