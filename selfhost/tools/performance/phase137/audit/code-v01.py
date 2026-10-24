#!/usr/bin/env python3
"""Pinned static call-path audit of actual integrated query products; no targets."""
import argparse
import collections
import hashlib
import json
from pathlib import Path
import re
import sys
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[5]
sys.path.insert(0,str(ROOT/'selfhost/tools/profiler'))
from owners import decoded_symbol
from run import pin,verify

WANTED={'f_find','f_find_next','lookup','nc_ctor_owned','dn','dk','p137q_repeat',
 'p137q_once','p137q_queries','p137q_record_query','p137q_name_eq','p137q_key_eq','p137q_kind_eq'}

def functions(path):
 result={};active=None;body=[];start=None
 with path.open() as f:
  for n,line in enumerate(f,1):
   if active is None:
    m=re.match(r'(?:export )?function [^$]*\$(\w+)\(',line)
    if m:active=m[1];body=[line];start=n
   else:
    body.append(line)
    if line=='}\n':
     assert active not in result
     result[active]=dict(line=start,body=body,decoded=decoded_symbol(active) or active)
     active=None
 assert active is None
 return result

def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('--emission',action='append',required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
 out=a.out.resolve();assert not out.exists() and out.is_relative_to(ROOT/'implementation/phase137/audit')
 inputs=[pin(__file__),pin(ROOT/'selfhost/tools/profiler/owners.py')];cases=[]
 for spec in a.emission:
  role,filename=spec.split('=',1);ep=Path(filename);e=json.loads(ep.read_text());assert e['complete'];inputs.append(pin(ep))
  for c in e['cases']:
   assert c['verified'];qbe=verify(c['qbe']);inputs.extend([c['qbe'],c['source']]);fs=functions(qbe);rows=[];graph={}
   for sym,f in fs.items():
    graph[sym]=[(m[1],f['line']+i) for i,l in enumerate(f['body']) if (m:=re.search(r'call \$(\w+)\(',l))]
    owner=f['decoded'].split('.')[-1]
    if not sym.startswith('p113d_') or owner not in WANTED:continue
    body=''.join(f['body']);calls=collections.Counter(t for t,_ in graph[sym])
    rows.append(dict(symbol=sym,decoded=f['decoded'],qbeLine=f['line'],lines=len(f['body']),bodySha256=hashlib.sha256(body.encode()).hexdigest(),
      calls=[dict(symbol=t,decoded=fs[t]['decoded'] if t in fs else decoded_symbol(t) or t,sites=n)for t,n in calls.items()],
      staticTake9Sites=sum('call $p111_rt_take(' in l and l.rstrip().endswith('w 9)') for l in f['body']),
      staticSinkSites=sum('call $p111_rt_sink(' in l for l in f['body']),
      runtimeBorrowReadSites=sum('call $p118_rt_borrow_fields(' in l for l in f['body'])))
   roots=[s for s,f in fs.items() if s.startswith('p113d_') and f['decoded']=='$direct.p137q_repeat']
   assert len(roots)==1,roots
   queue=collections.deque([(roots[0],[])]);seen=set();paths=[]
   while queue:
    sym,path=queue.popleft()
    if sym in seen:continue
    seen.add(sym)
    name=fs[sym]['decoded']
    if '$p118borrow.read.' in name and name.split('.')[-1] in WANTED:
     paths.append(dict(reader=sym,decoded=name,edges=path))
    for target,line in graph[sym]:
     if target in fs:queue.append((target,path+[dict(caller=sym,callerDecoded=name,line=line,target=target,targetDecoded=fs[target]['decoded'])]))
   cases.append(dict(producer=role,name=c['name'],qbe=c['qbe'],source=c['source'],sourceProducer=e.get('producerSource'),
       privateFunctions=rows,timedRoot=roots[0],directReachableFunctions=len(seen),borrowedReaderDirectPaths=paths,
       pathCaveat='Named direct paths only: existence does not establish branch frequency. No inference from missing indirect edges.'))
 for item in inputs:verify(item)
 result=dict(kind='phase137-query-qbe-call-audit',complete=True,targetsRun=False,inputs=inputs,cases=cases,
  scope='Actual integrated emitted products. Static path/site inventory is not dynamic execution, event counts, machine-code speed or semantic qualification. Follow adapter guard/fallback branches independently.')
 out.parent.mkdir(parents=True,exist_ok=True);out.write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(dict(complete=True,cases=len(cases),report=pin(out))))

if __name__=='__main__':main()
