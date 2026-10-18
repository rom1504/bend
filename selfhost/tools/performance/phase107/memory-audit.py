#!/usr/bin/env python3
"""Byte-memory oracle, load-only structure checks and finite native controls."""
import copy,hashlib,importlib.util,json,subprocess,sys,time
from pathlib import Path
sys.dont_write_bytecode=True;sys.setrecursionlimit(10000)
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];P106=HERE.parent/'phase106'
spec=importlib.util.spec_from_file_location('controls',HERE/'inline/controls.py');C=importlib.util.module_from_spec(spec);spec.loader.exec_module(C)
sys.path.insert(0,str(P106));from campaign import expected
out=Path(sys.argv[1]).resolve();controls=json.loads((out/'controls.json').read_text());report=dict(complete=False,rows=[],native=[],jobs=[],mutants=[],cFlags=['-O2','-fno-strict-aliasing'],intervalObservations=len(json.loads((out/'intervals.json').read_text())));models={};programs={}
def save():(out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
def model(p,args):
 key=(hashlib.sha256(json.dumps(p,sort_keys=True).encode()).hexdigest(),tuple(args))
 if key not in models:models[key]=C.reference.Interpreter(p).run(args)
 return models[key]
def run(cmd,want=None,code=0):
 cmd=list(map(str,cmd));start=time.monotonic();r=subprocess.run(cmd,cwd=ROOT,capture_output=True,text=True,timeout=30);report['jobs'].append(dict(command=cmd,seconds=time.monotonic()-start,status=r.returncode,stdout=r.stdout,stderr=r.stderr));save();assert r.returncode==code,(cmd,r.stderr)
 if want is not None:assert r.stdout==str(want)+'\n' and r.stderr=='',(cmd,r.stdout)
def structure(a,b):
 if a==b:return 0
 if isinstance(a,dict) and a.get('kind')=='load':assert isinstance(b,dict) and b.get('kind') in ['var','const','func'];return 1
 if isinstance(a,list):assert isinstance(b,list) and len(a)==len(b);return sum(structure(x,y)for x,y in zip(a,b))
 assert isinstance(a,dict) and isinstance(b,dict) and a.keys()==b.keys(),(a,b)
 return sum(structure(a[k],b[k])for k in a)
def each_body(body,change):
 for s in body:
  change(s)
  for k in ['then','else','body']:
   if k in s:each_body(s[k],change)
try:
 runner=out/'runner.o';run(['gcc','-O2','-c',P106/'cranelift/runner.c','-o',runner])
 for row in json.loads((out/'rows.json').read_text()):
  name,stem=row['name'],row['stem'];before=json.loads(Path(stem+'.before.json').read_text());after=json.loads(Path(stem+'.json').read_text());assert C.nodes(after)<=C.nodes(before);replacements=structure(before,after);programs[name]=after
  cases=[c for c in controls['cases']if c['fixture']==name]
  if not name.startswith('memory_'):cases=[dict(args=[n,s],expected=expected(name,n,s))for n in [0,1,2,9]for s in [0,23,2**32-1]]
  if name=='memory_second_probe':
   left=[s for s in before['functions'][0]['body']if s['kind']=='while'];right=[s for s in after['functions'][0]['body']if s['kind']=='while'];assert left==right
  observations=[]
  for case in cases:
   values=[model(p,case['args'])for p in [before,after]];assert [v['value']for v in values]==[case['expected']]*2,(name,case,values);assert values[0]['allocations']==values[1]['allocations'] and values[0]['frees']==values[1]['frees'];observations.append(dict(**case,values=values))
  report['rows'].append(dict(name=name,replacements=replacements,seconds=row['seconds'],observations=observations));save()
  if not name.startswith('memory_'):continue # Broad synthetic families are native-tested in the paired backend screen.
  for backend in ['gcc','qbe','cl']:
   obj=out/(name+'-'+backend+'.o');binary=out/(name+'-'+backend)
   if backend=='gcc':run(['gcc',*report['cFlags'],'-c',stem+'.c','-o',obj])
   elif backend=='cl':run([ROOT/'selfhost/build/phase106/cargo-target/release/bend-native-ir-cranelift',stem+'.json',obj,'speed_and_size'])
   else:run([ROOT/'selfhost/build/phase107/toolchain/qbe-1.3/qbe','-t','amd64_sysv','-o',stem+'.s',stem+'.ssa']);run(['as','-o',obj,stem+'.s'])
   run(['gcc',runner,obj,'-o',binary])
   for case in cases:run([binary,'--expect',case['expected'],*case['args']],case['expected']);report['native'].append(dict(backend=backend,**case))
   run([binary,'--expect',cases[0]['expected']^1,*cases[0]['args']],code=1)
 for name,target,value,args in [('memory_alias','after',dict(kind='var',name='before'),[2,3]),('memory_overlap','wide',dict(kind='const',type='u64',value=0),[1,7]),('memory_dependency','value',dict(kind='var',name='seed'),[2,3]),('memory_payload','payload',dict(kind='var',name='seed'),[2,3])]:
  original=programs[name];want=model(original,args)['value'];mutant=copy.deepcopy(original);edits=[0]
  def change(s):
   if s['kind']=='set' and s['name']==target:s['value']=value;edits[0]+=1
  for f in mutant['functions']:each_body(f['body'],change)
  assert edits[0]==1,(name,edits);got=model(mutant,args)['value'];assert got!=want,(name,want,got);report['mutants'].append(dict(name=name,args=args,expected=want,mutantValue=got,detected=True))
 report.update(complete=True,distinctModelExecutions=len(models))
except Exception as e:report['error']=repr(e);raise
finally:save()
print(json.dumps(dict(complete=True,pairs=len(report['rows']),native=len(report['native']),mutants=len(report['mutants']),distinctModelExecutions=len(models))))
