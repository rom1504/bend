#!/usr/bin/env python3
"""Root-only guarded execution of the fixed loop-recurrence machine diagnostic."""
import argparse,json,os,sys,time
from pathlib import Path
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[4];sys.path.insert(0,str(ROOT/'selfhost/tools/build'))
from common import pin,verify,run
p=argparse.ArgumentParser();p.add_argument('--plan',type=Path,required=True);p.add_argument('--out',type=Path,required=True);p.add_argument('--seconds',type=float,default=60);a=p.parse_args()
assert os.sched_getaffinity(0)=={3},'Outer CPU3 guard required'
assert 0<a.seconds<=120 and not a.out.exists()
plan=json.loads(a.plan.read_text());assert plan['kind']=='phase195-exact-machine-loop-carry' and plan['complete']
inputs=[pin(a.plan),*plan['inputs']];[verify(x) for x in inputs]
a.out.mkdir(parents=True);began=time.monotonic();report={'kind':'phase195-loop-carry-machine-diagnostic','complete':False,'inputs':inputs,'jobs':[],'products':[],'scope':plan['scope']}
def save():
 report['wallSeconds']=time.monotonic()-began;(a.out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
def job(name,cmd,expected=None):
 assert time.monotonic()-began<a.seconds;[verify(x) for x in inputs]
 env=dict(os.environ);[env.pop(k,None) for k in ['LD_PRELOAD','LD_AUDIT','BENDRTS','NODE_OPTIONS','NODE_PATH']];env['LC_ALL']='C'
 row=run(cmd,cwd=ROOT,stdout=a.out/(name+'.stdout'),stderr=a.out/(name+'.stderr'),seconds=min(30,a.seconds-(time.monotonic()-began)),env=env)
 report['jobs'].append(dict(label=name,**row));save()
 assert row['complete'] and Path(row['stderr']['file']).read_bytes()==b'',name+' failed or wrote stderr'
 if expected is not None:assert Path(row['stdout']['file']).read_bytes()==expected,name+' independent output differs'
assets=json.loads(Path(plan['assets']).read_text());policy=assets['toolchains']['x86']
def tool(k):return str((ROOT/assets['assets'][k]['file']).resolve())
assembler,linker,runtime=tool('assembler'),tool('linker'),tool('qbe-runtime')
recipe={'kind':'programs','reference':'baseline','catalog':str(ROOT/'selfhost/tools/bench/catalogs/native45/catalog.json'),'roles':{},'cases':[],'scope':plan['scope']}
for role in ['baseline','carry']:
 recipe['roles'][role]={'host':'native','stage':'diagnostic','target':'x86','preparation':'retained-rendered-assembly','policy':'exact-machine-recurrence-diagnostic','status':'unqualified-machine-diagnostic','runtime':pin(runtime),'inputs':inputs}
save()
try:
 for case in plan['rows']:
  products={}
  for role in ['baseline','carry']:
   stem=case['id']+'-'+role;obj=a.out/(stem+'.o');binary=a.out/stem;source=case['variants'][role]
   job(stem+'-assemble',[assembler,*policy['assemblerFlags'],'-o',str(obj),source['file']])
   job(stem+'-link',[linker,*policy['linkerFlags'],str(obj),runtime,*policy['libraries'],'-o',str(binary)])
   args=[str(x) for x in case['point']['runtimeArgs']]
   job(stem+'-oracle',[str(binary.resolve()),'+RTS','--threads','1','--gpu','off','-RTS','--RTS','1','0',*args],Path(case['expectedFile']['file']).read_bytes())
   products[role]={'artifact':pin(binary),'generatedSource':source,'runtimeArgumentConvention':'bend-rts-v1','inputs':inputs}
   report['products'].append({'case':case['id'],'role':role,'object':pin(obj),'binary':pin(binary)})
  recipe['cases'].append({'id':case['id'],'products':products})
 observer=Path(__file__).with_name('observer.c');observer_object=a.out/'observer.o'
 job('observer-compile',[linker,'-std=c11','-O2','-fno-pie','-c',str(observer),'-o',str(observer_object)])
 for role in ['baseline','carry']:
  obj=a.out/(role+'-observer.o');binary=a.out/(role+'-observer')
  job(role+'-observer-assemble',[assembler,*policy['assemblerFlags'],'-o',str(obj),plan['rows'][0]['variants'][role+'Observer']['file']])
  job(role+'-observer-link',[linker,*policy['linkerFlags'],str(observer_object),str(obj),runtime,*policy['libraries'],'-o',str(binary)])
  job(role+'-observer-execute',[str(binary.resolve())],b'phase195 loop carry observer: checks=577 failures=0\n')
  report['products'].append({'role':role,'observer':pin(binary)})
 [verify(x) for x in inputs];report['complete']=True;save()
 recipe['inputs']=[*inputs,pin(a.out/'report.json')]
 (a.out/'programs.recipe.json').write_text(json.dumps(recipe,indent=2)+'\n')
except BaseException as error:
 report['error']=str(error);save();raise
print(json.dumps({'complete':report['complete'],'seconds':report['wallSeconds'],'jobs':len(report['jobs'])}))
