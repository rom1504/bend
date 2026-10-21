"""Build new checked producer; reuse original frozen full-output evaluator."""
import argparse,importlib.util,json,os,statistics,subprocess,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4]
spec=importlib.util.spec_from_file_location('old',ROOT/'selfhost/tools/performance/phase112/benchmark45/run.py');O=importlib.util.module_from_spec(spec);spec.loader.exec_module(O)
read,pin,verify,save=O.read,O.pin,O.verify,O.save
p=argparse.ArgumentParser();p.add_argument('--emission',type=Path,required=True);p.add_argument('--out',type=Path,required=True);p.add_argument('--label',required=True);p.add_argument('--rounds',type=int,default=3);p.add_argument('--scale',type=int,default=1);a=p.parse_args()
assert sorted(os.sched_getaffinity(0))==[3]
out=a.out.resolve();assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase118');out.mkdir()
e=read(a.emission);assert e['complete']
for r in e['inputs']:verify(r)
m=read(ROOT/'selfhost/tools/performance/phase112/benchmark45/manifest01.json');profiles=read(ROOT/'selfhost/tools/performance/phase112/benchmark45/upstream-50ms-profile01.json');parent=read(ROOT/'implementation/phase117/selection.json');verify(parent['broad']);broad=read(parent['broad']['file']);base={'products':{r['name']:{'binary':r['binary']} for r in broad['rows'] if r['role']=='candidate'}}
report=dict(complete=False,inputs=[pin(__file__),pin(O.__file__),pin(a.emission),*e['inputs']],builds=[],rows=[],label=a.label);save(out/'report.json',report);start=time.monotonic()
try:
 for x in e['cases']:
  name=x['name'];case=next(c for c in m['cases'] if c['name']==name);verify(x['qbe']);dest=ROOT/'selfhost/build/phase111'/('p118-'+a.label+'-'+name+'-build')
  cmd=['python3','-B',str(ROOT/'selfhost/tools/performance/phase111/build.py'),'--source',x['qbe']['file'],'--runtime',e['runtime']['file'],'--out',str(dest),'--seconds','30']
  t=time.monotonic();r=subprocess.run(cmd,capture_output=True,timeout=55);(out/(name+'.build.stdout')).write_bytes(r.stdout);(out/(name+'.build.stderr')).write_bytes(r.stderr)
  br=read(dest/'report.json');report['builds'].append(dict(name=name,command=cmd,seconds=time.monotonic()-t,status=r.returncode,report=pin(dest/'report.json')));save(out/'report.json',report);assert r.returncode==0 and br['complete'];verify(br['binary'])
  for role,prod in [('candidate',br['binary']),('baseline',base['products'][name]['binary']),('upstream',case['upstream']['binary'])]:verify(prod)
  counts=profiles['cases'][name];c=dict(case,repetitions=counts['repetitions']*a.scale,warmups=counts['warmups'])
  products={'candidate':br['binary'],'baseline':base['products'][name]['binary'],'upstream':case['upstream']['binary']}
  for rnd in range(a.rounds):
   roles=list(products);roles=roles[rnd%3:]+roles[:rnd%3]
   for role in roles:
    binary=products[role];cmd=[binary['file'],'--threads','1','--gpu','off','--',str(c['repetitions']),str(c['warmups']),*map(str,c['runtimeArgs'])]
    t=time.monotonic();child=subprocess.run(cmd,capture_output=True,timeout=30);wall=time.monotonic()-t
    obs=O.observation(child.stdout,child.stderr,child.returncode,c,wall)
    stem=f'{name}-{role}-{rnd}';(out/(stem+'.stdout')).write_bytes(child.stdout);(out/(stem+'.stderr')).write_bytes(child.stderr)
    row=dict(name=name,role=role,round=rnd,command=cmd,binary=binary,elapsedMs=obs,correct=True,wallSeconds=wall,stdout=pin(out/(stem+'.stdout')),stderr=pin(out/(stem+'.stderr')));report['rows'].append(row);save(out/'report.json',report)
  print(name,'finished',flush=True)
 report['complete']=True
finally:report['seconds']=time.monotonic()-start;save(out/'report.json',report)
