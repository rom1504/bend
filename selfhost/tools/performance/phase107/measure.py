#!/usr/bin/env python3
"""One guarded serial batch: exact finite controls, then paired runtime/build screen."""
import argparse,json,math,random,statistics,subprocess,sys,time
from pathlib import Path
sys.dont_write_bytecode=True;sys.setrecursionlimit(10000)
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];P106=HERE.parent/'phase106'
sys.path.insert(0,str(P106));from campaign import expected,pin,save,read,MASK,CASES
from reference import Interpreter
p=argparse.ArgumentParser();p.add_argument('--artifacts',type=Path,required=True);p.add_argument('--out',type=Path,required=True);p.add_argument('--rounds',type=int,default=3);a=p.parse_args()
out=a.out.resolve();assert not out.exists();out.mkdir(parents=True)
clang=Path('/home/ai/.elan/toolchains/leanprover--lean4---v4.32.0/bin/clang');qbe=ROOT/'selfhost/build/phase107/toolchain/qbe-1.3/qbe';cl=ROOT/'selfhost/build/phase106/cargo-target/release/bend-native-ir-cranelift'
report=dict(kind='phase107-paired-backend-screen',complete=False,started=time.time(),inputs=[pin(__file__),pin(a.artifacts/'report.json'),pin(clang),pin(qbe),pin(cl),pin(P106/'cranelift/runner.c'),pin(P106/'reference.py')],jobs=[],models=[],builds=[],runtimes=[])
def checkpoint():save(out/'report.json',report)
def run(label,command,code=0,stdout=None):
 cmd=list(map(str,command));start=time.perf_counter();r=subprocess.run(cmd,cwd=ROOT,capture_output=True,text=True,timeout=30)
 row=dict(label=label,command=cmd,seconds=time.perf_counter()-start,returncode=r.returncode,stdout=r.stdout,stderr=r.stderr);report['jobs'].append(row)
 assert r.returncode==code,(label,r.returncode,r.stderr)
 if stdout is not None:assert r.stdout==stdout,(label,r.stdout,stdout)
 return row['seconds']
def answer(name,n,seed):
 if name.startswith('ir-'):return expected(name[3:],n,seed)
 name=name[7:]
 if name=='arithmetic':
  mix=lambda x,y:(((x*1664525+1013904223)&MASK)^y)
  return mix(mix(n,seed),(seed+7)&MASK)
 if name=='branches':return (n+7)&MASK if n<seed else n^0x80000000
 if name=='erased':return ((n+seed)&MASK)^2654435769
 if name=='compiler_classify':return int(65<=n<=90 or 97<=n<=122 or 48<=n<=57 or n in (95,46))+2*int(seed==32 or 9<=seed<=13)
 if name=='recurrence':
  for x in range(n,0,-1):seed=((seed*33+x)&MASK)^2654435769
  return seed
 raise ValueError(name)
def cases(name):
 if name=='source-recurrence':return [(n,s) for n in [0,1,2,19,127] for s in [0,23,2147483648,MASK]]
 if name.startswith('source-'):return [(n,s) for n,s in [(0,0),(1,7),(7,1),(19,23),(0x80000000,1),(MASK,MASK),(MASK,0),(0,MASK),(65,9),(123,32)]]
 return [(n,s) for n in [0,1,2,9] for s in [0,23,MASK]]
def perf(name):
 if name.startswith('ir-'):
  c=CASES[name[3:]];return c['args'],c['repeat']
 if name=='source-recurrence':return [1000,23],10000
 return [12345,277],5000000
try:
 runner=out/'runner.o';run('runner',['gcc','-O2','-c',P106/'cranelift/runner.c','-o',runner])
 rows=read(a.artifacts/'report.json')['rows'];binaries={}
 for row in rows:
  name,budget,stem=row['name'],row['budget'],Path(row['stem']);key=f'{name}-{budget}'
  program=read(str(stem)+'.json')
  for n,s in cases(name):
   want=answer(name,n,s);got=Interpreter(program).run([n,s])['value'];assert got==want,(key,n,s,got,want)
   report['models'].append(dict(key=key,args=[n,s],expected=want))
  for backend in ['c','cl','qbe']:
   obj=out/(key+'-'+backend+'.o');binary=out/(key+'-'+backend);elapsed=0
   if backend=='c':elapsed+=run(key+'-clang',[clang,'-O2','-isystem',clang.parents[1]/'include/clang','-c',str(stem)+'.c','-o',obj])
   elif backend=='cl':elapsed+=run(key+'-cranelift',[cl,str(stem)+'.json',obj,'speed_and_size'])
   else:
    assembly=out/(key+'.s');elapsed+=run(key+'-qbe',[qbe,'-t','amd64_sysv','-o',assembly,str(stem)+'.ssa']);elapsed+=run(key+'-assemble',['as','-o',obj,assembly])
   linked=run(key+'-link-'+backend,['gcc',runner,obj,'-o',binary])
   report['builds'].append(dict(name=name,budget=budget,backend=backend,objectSeconds=elapsed,linkSeconds=linked,objectBytes=obj.stat().st_size,binaryBytes=binary.stat().st_size))
   binaries[(name,budget,backend)]=binary
   for n,s in cases(name):
    want=answer(name,n,s);run(key+'-'+backend+'-check',[binary,'--expect',want,n,s],stdout=str(want)+'\n')
   checkpoint()
 order=list(binaries);random.Random(107).shuffle(order)
 for round in range(a.rounds):
  for name,budget,backend in order:
   binary=binaries[(name,budget,backend)];args,repeat=perf(name);want=answer(name,*args)
   seconds=run(f'{name}-{budget}-{backend}-runtime-{round}',[binary,'--expect',want,'--repeat',repeat,*args],stdout=str((want*repeat)&MASK)+'\n')
   report['runtimes'].append(dict(name=name,budget=budget,backend=backend,round=round,args=args,repeat=repeat,expected=want,seconds=seconds))
  checkpoint();order.reverse()
 report['summary']=[]
 for name in sorted({r['name'] for r in rows}):
  times={(b,k):statistics.median(r['seconds'] for r in report['runtimes'] if r['name']==name and r['budget']==b and r['backend']==k) for b in [0,4096] for k in ['c','cl','qbe']}
  report['summary'].append(dict(name=name,seconds={str(b)+'-'+k:t for (b,k),t in times.items()},inlineSpeedup={k:times[0,k]/times[4096,k] for k in ['c','cl','qbe']},inlineRatioToRawC={k:times[4096,k]/times[0,'c'] for k in ['c','cl','qbe']}))
 report.update(complete=True,finished=time.time(),wallSeconds=time.time()-report['started'])
except Exception as e:
 report['error']=repr(e);raise
finally:checkpoint()
print(json.dumps(dict(complete=report['complete'],models=len(report['models']),builds=len(report['builds']),summary=report.get('summary'))))
