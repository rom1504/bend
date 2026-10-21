"""Frozen executable rechecks/profile captures; reuse the independent oracle."""
import argparse, importlib.util, math, os, statistics, subprocess, time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4]
def module(name,path):
 s=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
O=module('oracle',ROOT/'selfhost/tools/performance/phase112/benchmark45/run.py')
A=module('sample',ROOT/'selfhost/tools/performance/phase116/survey-v2.py')
p=argparse.ArgumentParser();p.add_argument('--baseline-screen',type=Path);p.add_argument('--mode',choices=['clean','profile'],required=True);p.add_argument('--screen',type=Path,required=True);p.add_argument('--out',type=Path,required=True);p.add_argument('--names',nargs='+',required=True);p.add_argument('--roles',nargs='+',default=['candidate','baseline','upstream']);p.add_argument('--scale',type=int,default=4);p.add_argument('--rounds',type=int,default=5);a=p.parse_args()
assert sorted(os.sched_getaffinity(0))==[3]
out=a.out.resolve();assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase118');out.mkdir()
r=O.read(a.screen);assert r['complete'];other=O.read(a.baseline_screen) if a.baseline_screen else None
if other:assert other['complete']
manifest=ROOT/'selfhost/tools/performance/phase112/benchmark45/manifest01.json';m=O.read(manifest);counts=ROOT/'selfhost/tools/performance/phase112/benchmark45/upstream-50ms-profile01.json';profile=O.read(counts);sampler=ROOT/'selfhost/build/phase108/profiler01/sampler.so'
result=dict(complete=False,mode=a.mode,inputs=[O.pin(__file__),O.pin(O.__file__),O.pin(A.__file__),O.pin(a.screen),O.pin(manifest),O.pin(counts),O.pin(sampler)],rows=[],scope='Unchanged frozen binaries, original complete-output oracle. Profile durations are diagnostic, never clean timings. Physical leaves are not inclusive attribution.')
if other:result['inputs']+=[O.pin(a.baseline_screen)];result['baselineOverride']='Candidate binary from independently pinned baseline-screen, same original45 sources/counts/oracle'
save=lambda:O.save(out/'report.json',result);save();start=time.monotonic()
for x in [*r['inputs'],*(other['inputs'] if other else [])]:O.verify(x)
for name in a.names:
 c=next(c for c in m['cases'] if c['name']==name);O.verify(c['source']);O.verify(c['expectedStdoutEvidence']);c=dict(c,**profile['cases'][name]);products={x['role']:x['binary'] for x in r['rows'] if x['name']==name}
 if other:products['baseline']=next(x['binary'] for x in other['rows'] if x['name']==name and x['role']=='candidate')
 for x in products.values():O.verify(x)
 for rnd in ([8000,13000] if a.mode=='profile' else range(a.rounds)):
  roles=a.roles[rnd%len(a.roles):]+a.roles[:rnd%len(a.roles)]
  for role in roles:
   one=dict(c);one['repetitions']*=a.scale
   if a.mode=='profile':
    timed=other if other and role=='baseline' else r;timed_role='candidate' if other and role=='baseline' else role
    old=statistics.median(x['elapsedMs'] for x in timed['rows'] if x['name']==name and x['role']==timed_role)
    one['repetitions']=max(1,math.ceil(c['repetitions']*4500/old))
   stem=f'{name}-{role}-{rnd}';cmd=[products[role]['file'],'--threads','1','--gpu','off','--',str(one['repetitions']),str(one['warmups']),*map(str,one['runtimeArgs'])];env=dict(os.environ);sample=out/(stem+'.samples')
   if a.mode=='profile':env.update(LD_PRELOAD=str(sampler),BEND_SAMPLE_OUT=str(sample),BEND_SAMPLE_PERIOD_US=str(rnd))
   t=time.monotonic();child=subprocess.run(cmd,capture_output=True,timeout=30,env=env);wall=time.monotonic()-t;elapsed=O.observation(child.stdout,child.stderr,child.returncode,one,wall)
   (out/(stem+'.stdout')).write_bytes(child.stdout);(out/(stem+'.stderr')).write_bytes(child.stderr)
   row=dict(name=name,role=role,round=rnd,command=cmd,binary=products[role],elapsedMs=elapsed,wallSeconds=wall,correct=True,stdout=O.pin(out/(stem+'.stdout')),stderr=O.pin(out/(stem+'.stderr')))
   if a.mode=='profile':
    analysis=A.analyze(sample,products[role]['file']);f=out/(stem+'.analysis.json');O.save(f,analysis);row.update(samples=analysis['header']['samples'],usable=analysis['usable'],profile=O.pin(sample),analysis=O.pin(f))
   result['rows'].append(row);save();print(stem,elapsed,flush=True)
result.update(complete=True,seconds=time.monotonic()-start);save()
