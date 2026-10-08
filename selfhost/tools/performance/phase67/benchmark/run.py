#!/usr/bin/env python3
"""Small native acquisition and fixed-work loop. Root-only target executor."""
import argparse, importlib.util, json, math, statistics, time, sys, os
from pathlib import Path
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[4];OLD=HERE.parents[1]/'phase46'
def module(name,file):
 s=importlib.util.spec_from_file_location(name,file);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
S=module('support',HERE.parents[1]/'programs/support.py');O=module('oracle',OLD/'oracle.py')
def check(inputs):
 for i in inputs:
  assert S.identity(i['path'])==i,i['path']
def write(p,x):S.save(p,x)
p=argparse.ArgumentParser();p.add_argument('action',choices=['acquire','calibrate','measure']);p.add_argument('--recipe',required=True,type=Path);p.add_argument('--out',required=True,type=Path);p.add_argument('--cases',default='numeric,array,closures');p.add_argument('--roles',default='upstream,selfhost');p.add_argument('--acquired',type=Path,nargs='+');p.add_argument('--plan',type=Path);p.add_argument('--rounds',type=int,default=3);p.add_argument('--target-ms',type=int,default=120);p.add_argument('--max-slow-ms',type=int,default=16000);a=p.parse_args()
recipe=json.loads(a.recipe.read_text());check(recipe['inputs']);
assert {k:os.environ.get(k) for k in recipe['compilerEnvironment']}==recipe['compilerEnvironment'],'Changed compiler environment'
a.out=a.out.resolve();a.out.mkdir(parents=True,exist_ok=False)
catalog={c['name']:c for c in json.loads((OLD/'cases.json').read_text())};names=a.cases.split(',');roles=a.roles.split(',');assert set(names)<=catalog.keys() and set(roles)<={'selfhost','upstream'}
records=[];report=dict(kind='phase67-native-'+a.action,recipe=S.identity(a.recipe),started=time.time(),complete=False,records=records,inputs=recipe['inputs']);write(a.out/'report.json',report)
def save():
 report['finished']=time.time();write(a.out/'report.json',report)
def run(guard,cmd,d,seconds):return guard.run(['taskset','-c','3',*cmd],d,time.monotonic()+seconds)
def observe(r,out,expected):
 r['stdout']=(out/'stdout.log').read_text() if (out/'stdout.log').exists() else '';r['stderr']=(out/'stderr.log').read_text() if (out/'stderr.log').exists() else ''
 words=r['stdout'].strip().splitlines();r['correct']=r['process']['complete'] and len(words)==4 and all(x.isdecimal() for x in words) and list(map(int,words[:3]))==expected
 if r['correct']:r['elapsedMs']=int(words[3])
 return r['correct']
try:
 with S.ExecutionGuard(rss_mib=2048,available_mib=4096) as guard:
  if a.action=='acquire':
   for i,name in enumerate(names):
    c=catalog[name]; values=O.points(c);assert values[0]==c['expected']
    for role in (roles[i%len(roles):]+roles[:i%len(roles)]):
     d=a.out/(name+'-'+role);d.mkdir();src=OLD/(name+'-batch.bend');emitted=d/'program.c';exe=d/'program'
     r=dict(case=name,role=role,source=S.identity(src),expected=[c['expected'],O.digest(values,0),O.digest(values,1)],correct=False);records.append(r)
     r['emission']=run(guard,[recipe['node'],*recipe['nodeArgs'],str(HERE/'emit.mjs'),str(a.recipe.resolve()),role,str(src),str(emitted)],d/'emission',120);save()
     if not r['emission']['complete']:raise RuntimeError('Emission failed: '+name+' '+role)
     er=json.loads((d/'program.c.json').read_text());assert er['complete'];r['emissionReceipt']=S.identity(d/'program.c.json');r['nativeSource']=S.identity(emitted);r['emissionTimings']=er['timings']
     r['toolchain']=run(guard,[recipe['clang'],*recipe['clangArgs'],str(emitted),*recipe['linkArgs'],'-o',str(exe)],d/'toolchain',90);save()
     if not r['toolchain']['complete']:raise RuntimeError('Clang failed: '+name+' '+role)
     r['executable']=S.identity(exe)
     r['process']=run(guard,[str(exe),'--threads','1','--gpu','off','--','1','0'],d/'smoke',20)
     observe(r,d/'smoke',r['expected']);save();print(json.dumps({k:r.get(k) for k in ['case','role','correct','emissionTimings']}),flush=True)
     if not r['correct']:raise RuntimeError('Wrong result: '+name+' '+role)
  else:
   assert a.acquired;artifacts={}
   for acquired in a.acquired:
    ar=json.loads((acquired/'report.json').read_text());assert ar['complete'];check(ar['inputs'])
    assert ar['recipe']==S.identity(a.recipe),'Use the recipe bound to these exact artifacts'
    for r in ar['records']:
     key=(r['case'],r['role']);assert key not in artifacts;assert r['correct'];check([r['executable'],r['nativeSource'],r['emissionReceipt']]);artifacts[key]=r
   report['acquisitions']=[S.identity(x/'report.json') for x in a.acquired];report['artifacts']=[r['executable'] for r in artifacts.values()]
   plan=json.loads(a.plan.read_text()) if a.plan else None
   if a.action=='measure':assert plan;report['plan']=S.identity(a.plan)
   for name in names:
    c=catalog[name];values=O.points(c);n=plan[name]['repetitions'] if plan else {'numeric':4096,'array':512,'closures':8192,'tree':128,'map':64,'lexer':64}[name];warm=plan[name]['warmups'] if plan else n
    expected=[c['expected'],O.digest(values,warm),O.digest(values,n)]
    for round_index in range(a.rounds if a.action=='measure' else 1):
     for role in roles[round_index%len(roles):]+roles[:round_index%len(roles)]:
      artifact=artifacts[(name,role)]['executable'];check([artifact]);dest=a.out/(name+'-'+role+'-r'+str(round_index));child=dest/'child.json'
      cmd=['python3',str(OLD/'execute.py'),str(child),artifact['path'],'--threads','1','--gpu','off','--',str(n),str(warm)]
      r=dict(case=name,role=role,round=round_index,repetitions=n,warmups=warm,expected=expected)
      r['process']=run(guard,cmd,dest,45);observe(r,dest,expected)
      if child.exists():r['child']=json.loads(child.read_text())
      r['validClock']=r.get('correct',False) and 0<r.get('elapsedMs',0)<=r.get('child',{}).get('processSeconds',0)*1000+2
      r['timingQualified']=r['validClock'] and r['elapsedMs']>=100
      records.append(r);save();print(json.dumps({k:r.get(k) for k in ['case','role','round','correct','elapsedMs','timingQualified']}),flush=True)
      if not r.get('correct'):raise RuntimeError('Runtime correctness failure')
   if a.action=='calibrate':
    plan={}
    for name in names:
     rows=[r for r in records if r['case']==name];low=min(max(1,r['elapsedMs']) for r in rows);high=max(max(1,r['elapsedMs']) for r in rows);old=rows[0]['repetitions'];count=max(16,min(1000000,math.ceil(a.target_ms/low*old/16)*16,math.floor(a.max_slow_ms/high*old/16)*16))
     plan[name]=dict(repetitions=count,warmups=count,targetFastMs=a.target_ms,maxPredictedSlowMs=a.max_slow_ms,calibrationMinMs=low,calibrationMaxMs=high,calibrationRepetitions=old,predictedFastMs=low*count/old,predictedSlowMs=high*count/old,clockResolutionMs=1)
    write(a.out/'plan.json',plan)
 if a.action!='acquire':check(report['artifacts'])
 check(recipe['inputs']);report['complete']=all(r['correct'] for r in records);save()
except BaseException as e:
 report['error']=repr(e);save();raise
