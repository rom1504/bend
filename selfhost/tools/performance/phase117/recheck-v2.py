"""Reuse frozen machine products; longer matched observations or leaf profiles."""
import argparse,importlib.util,json,os,subprocess,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4]
def module(name,path):
 s=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
O=module('oracle',ROOT/'selfhost/tools/performance/phase112/benchmark45/run.py')
A=module('sample',ROOT/'selfhost/tools/performance/phase116/survey-v2.py')
p=argparse.ArgumentParser();p.add_argument('--mode',choices=['clean','profile'],required=True);p.add_argument('--out',type=Path,required=True);p.add_argument('--names',nargs='+',required=True);p.add_argument('--candidate-report');a=p.parse_args()
assert sorted(os.sched_getaffinity(0))==[3]
out=a.out.resolve();assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase117');out.mkdir()
receipt=ROOT/'selfhost/build/phase117/broad-screen01/report.json';r=O.read(receipt);assert r['complete'];m=O.read(ROOT/'selfhost/tools/performance/phase112/benchmark45/manifest01.json');counts=O.read(ROOT/'selfhost/tools/performance/phase112/benchmark45/upstream-50ms-profile01.json');sampler=ROOT/'selfhost/build/phase108/profiler01/sampler.so'
alt=O.read(a.candidate_report) if a.candidate_report else None
if alt:assert alt['complete'] and a.mode=='clean'
result=dict(complete=False,mode=a.mode,comparison='alternative vs selected Phase117' if alt else 'selected Phase117 vs Phase114',inputs=[O.pin(__file__),O.pin(O.__file__),O.pin(A.__file__),O.pin(receipt),O.pin(sampler)],rows=[]);
if alt:result['inputs'].append(O.pin(a.candidate_report))
save=lambda:O.save(out/'report.json',result);save();start=time.monotonic()
for name in a.names:
 c=next(c for c in m['cases'] if c['name']==name);c=dict(c,**counts['cases'][name]);c['repetitions']*=16 if a.mode=='profile' else 4
 products={x['role']:x['binary'] for x in r['rows'] if x['name']==name}
 if alt:products.update(baseline=products['candidate'],candidate=next(x['binary'] for x in alt['rows'] if x['name']==name and x['role']=='candidate'))
 for x in products.values():O.verify(x)
 for rnd in ([8000,13000] if a.mode=='profile' else range(5)):
  roles=['candidate'] if a.mode=='profile' else ['candidate','baseline','upstream'];roles=roles[rnd%len(roles):]+roles[:rnd%len(roles)]
  for role in roles:
   stem=f'{name}-{role}-{rnd}';cmd=[products[role]['file'],'--threads','1','--gpu','off','--',str(c['repetitions']),str(c['warmups']),*map(str,c['runtimeArgs'])];env=dict(os.environ);sample=out/(stem+'.samples')
   if a.mode=='profile':env.update(LD_PRELOAD=str(sampler),BEND_SAMPLE_OUT=str(sample),BEND_SAMPLE_PERIOD_US=str(rnd))
   t=time.monotonic();child=subprocess.run(cmd,capture_output=True,timeout=30,env=env);wall=time.monotonic()-t;elapsed=O.observation(child.stdout,child.stderr,child.returncode,c,wall)
   (out/(stem+'.stdout')).write_bytes(child.stdout);(out/(stem+'.stderr')).write_bytes(child.stderr)
   row=dict(name=name,role=role,round=rnd,command=cmd,binary=products[role],elapsedMs=elapsed,wallSeconds=wall,correct=True,stdout=O.pin(out/(stem+'.stdout')),stderr=O.pin(out/(stem+'.stderr')))
   if a.mode=='profile':
    analysis=A.analyze(sample,products[role]['file']);f=out/(stem+'.analysis.json');O.save(f,analysis);row.update(samples=analysis['header']['samples'],usable=analysis['usable'],profile=O.pin(sample),analysis=O.pin(f));assert analysis['usable']
   result['rows'].append(row);save()
result.update(complete=True,seconds=time.monotonic()-start);save()
