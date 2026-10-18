#!/usr/bin/env python3
import copy,hashlib,importlib.util,json,subprocess,sys,time
from pathlib import Path
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];P106=HERE.parent/'phase106'
spec=importlib.util.spec_from_file_location('controls',HERE/'inline/controls.py');C=importlib.util.module_from_spec(spec);spec.loader.exec_module(C)
out=Path(sys.argv[1]).resolve();controls=json.loads((HERE/'inline/leaf-controls.json').read_text());report=dict(complete=False,rows=[],native=[],jobs=[],mutants=[]);models={};programs={}
def save():(out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
def model(p,args):
 key=(hashlib.sha256(json.dumps(p,sort_keys=True).encode()).hexdigest(),tuple(args))
 if key not in models:models[key]=C.reference.Interpreter(p).run(args)
 return models[key]
def run(cmd,want=None,code=0):
 cmd=list(map(str,cmd));start=time.monotonic();r=subprocess.run(cmd,cwd=ROOT,capture_output=True,text=True,timeout=30);report['jobs'].append(dict(command=cmd,seconds=time.monotonic()-start,status=r.returncode,stdout=r.stdout,stderr=r.stderr));save();assert r.returncode==code,(cmd,r.stderr)
 if want is not None:assert r.stdout==str(want)+'\n'
def each_body(body,change):
 change(body)
 for s in body:
  for k in ['then','else','body']:
   if k in s:each_body(s[k],change)
try:
 runner=out/'runner.o';run(['gcc','-O2','-c',P106/'cranelift/runner.c','-o',runner])
 for row in json.loads((out/'rows.json').read_text()):
  name,budget,stem=row['name'],row['budget'],row['stem'];before=json.loads(Path(stem+'.before.json').read_text());after=json.loads(Path(stem+'.json').read_text());assert C.nodes(after)<=C.nodes(before)+budget
  if budget<=1 or name in controls['refusals']:assert before==after,(name,budget,'refusal changed')
  assert [f['name'] for f in before['functions']]==[f['name'] for f in after['functions']]
  for f in after['functions']:
   names=[p['name'] for p in f['params']+f['locals']];assert len(names)==len(set(names))
  observations=[];cases=[c for c in controls['cases'] if c['fixture']==name]
  for case in cases:
   values=[model(p,case['args']) for p in [before,after]]
   assert [v['value'] for v in values]==[case['expected']]*2,(name,budget,case,values)
   assert values[0]['allocations']==values[1]['allocations'] and values[0]['frees']==values[1]['frees']
   observations.append(dict(**case,values=values))
  report['rows'].append(dict(name=name,budget=budget,nodesBefore=C.nodes(before),nodesAfter=C.nodes(after),observations=observations));save()
  if budget!=4096 or not cases:continue
  assert C.calls(after)==0,(name,'leaf call not eliminated');programs[name]=after
  for backend in ['gcc','qbe','cl']:
   obj=out/(name+'-'+backend+'.o');binary=out/(name+'-'+backend)
   if backend=='gcc':run(['gcc','-O2','-c',stem+'.c','-o',obj])
   elif backend=='cl':run([ROOT/'selfhost/build/phase106/cargo-target/release/bend-native-ir-cranelift',stem+'.json',obj,'speed_and_size'])
   else:run([ROOT/'selfhost/build/phase107/toolchain/qbe-1.3/qbe','-t','amd64_sysv','-o',stem+'.s',stem+'.ssa']);run(['as','-o',obj,stem+'.s'])
   run(['gcc',runner,obj,'-o',binary])
   for case in cases:run([binary,'--expect',case['expected'],*case['args']],case['expected']);report['native'].append(dict(backend=backend,**case))
   run([binary,'--expect',cases[0]['expected']^1,*cases[0]['args']],code=1)
 # Typed emitted-IR mutations test the oracle; they do not mutate the producer.
 for name,args,want in [('leaf_alias',[7,11],373),('leaf_reset',[4,3],20)]:
  original=programs[name];assert model(original,args)['value']==want;mutant=copy.deepcopy(original);main=next(f for f in mutant['functions'] if f['name']==mutant['entry']);edits=[0]
  def change(body):
   if name=='leaf_alias':
    targets=[i for i,s in enumerate(body) if s['kind']=='set' and s['name'].endswith('_v_after') and s['value']['kind']=='load']
    stores=[i for i,s in enumerate(body) if s['kind']=='store' and s['ptr'].get('name','').endswith('_v_a')]
    if targets and stores:stmt=body.pop(targets[0]);body.insert(stores[0],stmt);edits[0]+=1
   else:
    kept=[s for s in body if not(s['kind']=='set' and s['name'].endswith('_v_saved') and s['value']==dict(kind='const',type='ptr',value=0))]
    edits[0]+=len(body)-len(kept);body[:]=kept
  each_body(main['body'],change);assert edits[0]==1,(name,edits)
  got=model(mutant,args)['value'];assert got!=want;report['mutants'].append(dict(name=name,args=args,expected=want,mutantValue=got,detected=True))
 report.update(complete=True,distinctModelExecutions=len(models))
except Exception as e:report['error']=repr(e);raise
finally:save()
print(json.dumps(dict(complete=True,pairs=len(report['rows']),native=len(report['native']),mutants=len(report['mutants']),distinctModelExecutions=len(models))))
