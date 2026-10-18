#!/usr/bin/env python3
"""Independent closure oracle and native function-pointer controls."""
import copy,importlib.util,json,subprocess,sys,time
from pathlib import Path
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];P106=HERE.parent/'phase106'
spec=importlib.util.spec_from_file_location('ref',P106/'reference.py');R=importlib.util.module_from_spec(spec);spec.loader.exec_module(R)
out=Path(sys.argv[1]).resolve();controls=json.loads((HERE/'inline/reachable-controls.json').read_text());report=dict(complete=False,rows=[],jobs=[],native=[],mutants=[])
def save():(out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
def refs(x):
 if isinstance(x,list):return set().union(*(refs(y) for y in x))
 if not isinstance(x,dict):return set()
 own={x['name']} if x.get('kind') in ('call','func') else set()
 return own|set().union(*(refs(y) for y in x.values()))
def check(before,after,unchanged=False):
 if unchanged:assert before==after;return
 fs={f['name']:f for f in before['functions']};seen=set();todo=[before['entry']]
 while todo:
  name=todo.pop()
  if name in seen:continue
  seen.add(name);todo.extend(refs(fs[name])-seen)
 assert after==dict(before,functions=[f for f in before['functions'] if f['name'] in seen])
def run(cmd,want=None):
 cmd=list(map(str,cmd));start=time.monotonic();r=subprocess.run(cmd,cwd=ROOT,capture_output=True,text=True,timeout=30);report['jobs'].append(dict(command=cmd,seconds=time.monotonic()-start,status=r.returncode,stdout=r.stdout,stderr=r.stderr));save();assert r.returncode==0,(cmd,r.stderr)
 if want is not None:assert r.stdout==str(want)+'\n'
try:
 runner=out/'runner.o';run(['gcc','-O2','-c',P106/'cranelift/runner.c','-o',runner]);programs={}
 for row in json.loads((out/'rows.json').read_text()):
  name,stem=row['name'],row['stem'];before=json.loads(Path(stem+'.before.json').read_text());after=json.loads(Path(stem+'.json').read_text());programs[name]=(before,after)
  spec=next((c for c in controls['cases'] if c['fixture']==name),{})
  check(before,after,spec.get('unchanged',False) or name=='tail_dead')
  if 'keep'in spec:assert [f['name'] for f in after['functions']]==spec['keep']
  if name=='many':assert [f['name'] for f in after['functions']]==['main']
  observations=[]
  if spec.get('execute'):
   for case in controls['inputs']:
    got=[R.Interpreter(p).run(case['args'])['value'] for p in [before,after]];assert got==[case['expected']]*2;observations.append(dict(**case,values=got))
   for backend in ['gcc','qbe','cl']:
    obj=out/(name+'-'+backend+'.o');binary=out/(name+'-'+backend)
    if backend=='gcc':run(['gcc','-O2','-c',stem+'.c','-o',obj])
    elif backend=='cl':run([ROOT/'selfhost/build/phase106/cargo-target/release/bend-native-ir-cranelift',stem+'.json',obj,'speed_and_size'])
    else:run([ROOT/'selfhost/build/phase107/toolchain/qbe-1.3/qbe','-t','amd64_sysv','-o',stem+'.s',stem+'.ssa']);run(['as','-o',obj,stem+'.s'])
    run(['gcc',runner,obj,'-o',binary])
    for case in controls['inputs']:run([binary,'--expect',case['expected'],*case['args']],case['expected']);report['native'].append(dict(name=name,backend=backend,**case))
  report['rows'].append(dict(name=name,before=len(before['functions']),after=len(after['functions']),observations=observations));save()
 for name in ['reach_stored','reach_returned']:
  before,after=programs[name];mutant=copy.deepcopy(after);mutant['functions']=[f for f in mutant['functions'] if f['name']!='target']
  try:check(before,mutant)
  except AssertionError:report['mutants'].append(dict(name=name,detected=True));continue
  raise AssertionError('deleted target undetected')
 before,after=programs['reach_direct'];mutant=copy.deepcopy(after);mutant['functions'].reverse()
 try:check(before,mutant)
 except AssertionError:report['mutants'].append(dict(name='reversed-order',detected=True))
 else:raise AssertionError('order mutant undetected')
 report['complete']=True
except Exception as e:report['error']=repr(e);raise
finally:save()
print(json.dumps(dict(complete=True,rows=len(report['rows']),native=len(report['native']),mutants=len(report['mutants']))))
