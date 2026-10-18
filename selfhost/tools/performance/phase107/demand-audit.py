#!/usr/bin/env python3
"""Independent semantic and capacity checks for closed-program demand inlining."""
import importlib.util,json,sys,time
from pathlib import Path
sys.dont_write_bytecode=True;sys.setrecursionlimit(10000)
HERE=Path(__file__).resolve().parent;P106=HERE.parent/'phase106'
sys.path.insert(0,str(P106));from reference import Interpreter
spec=importlib.util.spec_from_file_location('controls',HERE/'inline/controls.py');C=importlib.util.module_from_spec(spec);spec.loader.exec_module(C)
out=Path(sys.argv[1]);report=dict(complete=False,rows=[],mutants=[]);start=time.monotonic();memo={};programs={}
def value(p,args):
 key=(json.dumps(p,separators=(',',':')),tuple(args))
 if key not in memo:memo[key]=Interpreter(p).run(args)['value']
 return memo[key]
try:
 for r in json.loads((out/'rows.json').read_text()):
  name,budget=r['name'],r['budget'];before=json.loads(Path(r['stem']+'.before.json').read_text());after=json.loads(Path(r['stem']+'.json').read_text());assert before['entry']==after['entry'];assert C.nodes(after)<=C.nodes(before)+budget
  names=[f['name'] for f in after['functions']];assert names==[f['name'] for f in before['functions'] if f['name'] in names]
  for f in after['functions']:
   loc=[v['name'] for v in f['params']+f['locals']];assert len(loc)==len(set(loc))
  if budget==0 or name in ['tail_dead','reach_cap']:assert before==after
  observations=[];finite=C.controls(name)
  if name.startswith('reach_') and name not in ['reach_cap','reach_cycle']:finite=[dict(args=[n,s]) for n,s in [(0,0),(1,7),(19,23),(2**32-1,2**32-1)]]
  if name in ['many','text','list','tree','closure','tail']:finite=[dict(args=[n,s]) for n in [0,1,2,9] for s in [0,23,2**32-1]]
  if r['valid']:
   for case in finite:
    values=[value(p,case['args']) for p in [before,after]];assert values[0]==values[1],(name,budget,case,values)
    if 'expected'in case:assert values==[case['expected']]*2
    observations.append(dict(args=case['args'],values=values))
  if budget==4096:
   programs[name]=after
   if name in ['many','snapshot','collision','branch','merge','reset','nested']:assert len(after['functions'])==1 and C.calls(after)==0
  report['rows'].append(dict(name=name,budget=budget,before=C.nodes(before),after=C.nodes(after),seconds=r['seconds'],observations=observations))
 report['mutants']=C.negative_controls(programs);report.update(complete=True,distinctModelRuns=len(memo),seconds=time.monotonic()-start)
finally:(out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(dict(complete=report['complete'],rows=len(report['rows']),observations=sum(len(r['observations'])for r in report['rows']),mutants=len(report['mutants']))))
