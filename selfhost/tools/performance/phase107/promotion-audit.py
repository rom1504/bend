#!/usr/bin/env python3
"""Independent finite observations for scalar promotion, including allocation counts."""
import copy,hashlib,importlib.util,json,subprocess,sys,time
from pathlib import Path
sys.dont_write_bytecode=True;sys.setrecursionlimit(10000)
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];P106=HERE.parent/'phase106'
spec=importlib.util.spec_from_file_location('controls',HERE/'inline/controls.py');C=importlib.util.module_from_spec(spec);spec.loader.exec_module(C)
sys.path.insert(0,str(P106));from campaign import expected
out=Path(sys.argv[1]).resolve();controls=[json.loads((out/(n+'-controls.json')).read_text())for n in ['promotion','memory']]
report=dict(complete=False,rows=[],native=[],jobs=[],mutants=[],cFlags=['-O2','-fno-strict-aliasing']);models={};programs={};originals={}
(out/'method.py').write_bytes(Path(__file__).read_bytes())
def save():(out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
def model(p,args):
 key=(hashlib.sha256(json.dumps(p,sort_keys=True).encode()).hexdigest(),tuple(args))
 if key not in models:models[key]=C.reference.Interpreter(p).run(args)
 return models[key]
def run(cmd,want=None,code=0):
 cmd=list(map(str,cmd));start=time.monotonic();r=subprocess.run(cmd,cwd=ROOT,capture_output=True,text=True,timeout=30)
 report['jobs'].append(dict(command=cmd,seconds=time.monotonic()-start,status=r.returncode,stdout=r.stdout,stderr=r.stderr));save();assert r.returncode==code,(cmd,r.stderr)
 if want is not None:assert r.stdout==str(want)+'\n' and r.stderr=='',(cmd,r.stdout)
def walk(v):
 if isinstance(v,dict):
  yield v
  for x in v.values():yield from walk(x)
 elif isinstance(v,list):
  for x in v:yield from walk(x)
def retained(p):
 return [v for v in walk(p)if v.get('kind') in ['alloc','free'] or (v.get('kind')=='store' and v.get('type')=='ptr')]
try:
 runner=out/'runner.o';run(['gcc','-O2','-c',P106/'cranelift/runner.c','-o',runner])
 for row in json.loads((out/'rows.json').read_text()):
  name,stem=row['name'],row['stem'];before=json.loads(Path(stem+'.before.json').read_text());after=json.loads(Path(stem+'.json').read_text());programs[name]=after;originals[name]=before
  assert retained(before)==retained(after),name
  cases=list({(tuple(c['args']),c['expected']):c for ctl in controls for c in ctl['cases']if c['fixture']==name}.values())
  if row['fixture']=='nx_workload':cases=[dict(args=[n,s],expected=expected(name,n,s))for n in [0,1,2,9]for s in [0,23,2**32-1]]
  observations=[]
  for case in cases:
   values=[model(p,case['args'])for p in [before,after]];assert [v['value']for v in values]==[case['expected']]*2,(name,case,values)
   assert values[0]['allocations']==values[1]['allocations'] and values[0]['frees']==values[1]['frees'];observations.append(dict(**case,values=values))
  report['rows'].append(dict(name=name,changed=row['changed'],seconds=row['seconds'],observations=observations));save()
  if row['fixture']=='nx_workload':continue
  for backend in ['gcc','qbe','cl']:
   obj=out/(name+'-'+backend+'.o');binary=out/(name+'-'+backend)
   if backend=='gcc':run(['gcc',*report['cFlags'],'-c',stem+'.c','-o',obj])
   elif backend=='cl':run([ROOT/'selfhost/build/phase106/cargo-target/release/bend-native-ir-cranelift',stem+'.json',obj,'speed_and_size'])
   else:run([ROOT/'selfhost/build/phase107/toolchain/qbe-1.3/qbe','-t','amd64_sysv','-o',stem+'.s',stem+'.ssa']);run(['as','-o',obj,stem+'.s'])
   run(['gcc',runner,obj,'-o',binary])
   for case in cases:run([binary,'--expect',case['expected'],*case['args']],case['expected']);report['native'].append(dict(backend=backend,**case))
   run([binary,'--expect',cases[0]['expected']^1,*cases[0]['args']],code=1)
 # Independently damage promoted field assignments. Require at least two
 # observable, still scalar-typed mutations; never bless an unexercised mutant.
 for name in ['memory_alias','memory_payload','promotion_alias','promotion_zero']:
  if name not in programs:continue
  original=programs[name];args=[2,3];want=model(original,args)['value'];old_names={v['name']for f in originals[name]['functions']for v in f['locals']}
  for ordinal in range(16):
   mutant=copy.deepcopy(original);sets=[s for s in walk(mutant)if s.get('kind')=='set' and s.get('name','').startswith('p107_p') and s['name'] not in old_names]
   if ordinal>=len(sets):break
   s=sets[ordinal];old=s['value'];typ=next(v['type']for f in mutant['functions']for v in f['locals']if v['name']==s['name']);s['value']=dict(kind='const',type=typ,value=999)
   try:got=model(mutant,args)['value']
   except Exception:continue
   if got!=want:
    report['mutants'].append(dict(name=name,args=args,assignment=ordinal,original=old,expected=want,mutantValue=got,detected=True));break
 assert len(report['mutants'])>=2,report['mutants']
 report.update(complete=True,distinctModelExecutions=len(models))
except Exception as e:report['error']=repr(e);raise
finally:save()
print(json.dumps(dict(complete=True,pairs=len(report['rows']),native=len(report['native']),mutants=len(report['mutants']),distinctModelExecutions=len(models))))
