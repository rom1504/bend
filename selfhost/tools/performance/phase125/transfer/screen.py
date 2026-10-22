"""Independent paired transfer workload; excluded from the historical45 score."""
import argparse,importlib.util,os,subprocess,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5]
spec=importlib.util.spec_from_file_location('oracle',ROOT/'selfhost/tools/performance/phase112/benchmark45/run.py');O=importlib.util.module_from_spec(spec);spec.loader.exec_module(O)
p=argparse.ArgumentParser();p.add_argument('--emission',nargs=2,action='append',required=True,metavar=('ROLE','REPORT'));p.add_argument('--manifest',type=Path,required=True);p.add_argument('--out',type=Path,required=True);p.add_argument('--label',required=True);a=p.parse_args()
assert sorted(os.sched_getaffinity(0))==[3] and not a.out.exists();a.out.mkdir(parents=True)
case=O.read(a.manifest)['cases'][0];O.verify(case['source']);O.verify(case['expectedStdoutEvidence'])
r=dict(complete=False,inputs=[O.pin(__file__),O.pin(O.__file__),O.pin(a.manifest),case['source'],case['expectedStdoutEvidence']],builds=[],rows=[],scope='Independent transfer only; no frozen benchmark metric change. Complete original Phase93 result/count oracle.');save=lambda:O.save(a.out/'report.json',r);save()
products={};start=time.monotonic()
try:
 for role,file in a.emission:
  assert role not in products;e=O.read(file);assert e['complete'];r['inputs'] += [O.pin(file),*e['inputs']]
  for x in e['inputs']:O.verify(x)
  c=next(x for x in e['cases'] if x['name']==case['name']);assert c['source']==case['source'];O.verify(c['qbe'])
  out=ROOT/'selfhost/build/phase111'/('p125-transfer-'+a.label+'-'+role)
  cmd=['python3','-B',str(ROOT/'selfhost/tools/performance/phase123/build-aligned.py'),'--source',c['qbe']['file'],'--runtime',e['runtime']['file'],'--out',str(out)]
  child=subprocess.run(cmd,capture_output=True,timeout=45);(a.out/(role+'.build.stdout')).write_bytes(child.stdout);(a.out/(role+'.build.stderr')).write_bytes(child.stderr);assert child.returncode==0
  b=O.read(out/'report.json');assert b['complete'];products[role]=b['binary'];r['builds'].append(dict(role=role,report=O.pin(out/'report.json')));save()
 for rnd in range(3):
  roles=list(products);roles=roles[rnd%len(roles):]+roles[:rnd%len(roles)]
  for role in roles:
   binary=products[role];O.verify(binary);cmd=[binary['file'],'--threads','1','--gpu','off','--',str(case['repetitions']),str(case['warmups']),*map(str,case['runtimeArgs'])]
   t=time.monotonic();c=subprocess.run(cmd,capture_output=True,timeout=30);wall=time.monotonic()-t;stem=role+'-'+str(rnd)
   (a.out/(stem+'.stdout')).write_bytes(c.stdout);(a.out/(stem+'.stderr')).write_bytes(c.stderr)
   row=dict(role=role,round=rnd,binary=binary,command=cmd,status=c.returncode,wallSeconds=wall,stdout=O.pin(a.out/(stem+'.stdout')),stderr=O.pin(a.out/(stem+'.stderr')));r['rows'].append(row);save()
   row['elapsedMs']=O.observation(c.stdout,c.stderr,c.returncode,case,wall);row['correct']=True;save()
 r['complete']=True
finally:r['seconds']=time.monotonic()-start;save()
