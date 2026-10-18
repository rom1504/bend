#!/usr/bin/env python3
"""Paired worker-only timing of the already qualified, frozen ownership binaries."""
import argparse,importlib.util,json,statistics,sys,time
from pathlib import Path
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[4];HERE=ROOT/'selfhost/tools/performance/phase109'
s=importlib.util.spec_from_file_location('r',HERE.parent/'phase108/run.py');R=importlib.util.module_from_spec(s);s.loader.exec_module(R)
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--suite',type=Path,required=True);p.add_argument('--out',type=Path,required=True);p.add_argument('--rounds',type=int,default=7);p.add_argument('--repetitions',type=int,default=20);a=p.parse_args()
suite=a.suite.resolve();out=a.out.resolve();assert out.is_relative_to(ROOT/'selfhost/build/phase109') and not out.exists();out.mkdir(parents=True)
assert json.loads((suite/'report.json').read_text())['complete'];assert 3<=a.rounds<=15 and 1<=a.repetitions<=100
variants=[('raw','direct-qbe'),('raw','direct-clang'),('trusted','direct-qbe'),('fused','direct-qbe'),('fused','direct-clang'),('fused','production-gcc'),('fused','production-clang'),('fused','production-qbe')]
inputs=[R.pin(Path(__file__)),R.pin(suite/'report.json'),R.pin(HERE/'controls/expected.jsonl')];binaries=[]
for policy,backend in variants:
 folder=suite/(policy+'-reverse-kernel');r=json.loads((folder/'report.json').read_text());assert r['complete'] and r['controls'][backend]['cases']==13
 identity=r['builds'][backend]['binary'];R.N.verify(identity);inputs += [identity,R.pin(folder/'report.json')];binaries.append((policy+'-'+backend,Path(identity['file'])))
oracle=next(json.loads(x) for x in (HERE/'controls/expected.jsonl').read_text().splitlines() if json.loads(x)['name']=='list-deep')
report=dict(kind='phase109-paired-owned-workers',complete=False,inputs=inputs,rounds=a.rounds,repetitions=a.repetitions,case='list-deep',nodesPerRepetition=65536,rows=[],scope='Repeated 65536-cell List<String> reverse kernel. Graph setup/observation/release excluded from worker clock, included in process clock. Not whole-compiler or broad-program performance.')
save=lambda:R.save(out/'report.json',report);save()
try:
 for round in range(a.rounds):
  order=binaries if round%2==0 else list(reversed(binaries))
  for name,binary in order:
   R.N.verify(next(x for x in inputs if x['file']==str(binary)));stem=name+'-'+str(round);command=[str(binary),'list-deep',str(a.repetitions)];start=time.monotonic()
   with (out/(stem+'.stdout')).open('xb') as so,(out/(stem+'.stderr')).open('xb') as se:r=R.P.run(command,cwd=ROOT,stdout=so,stderr=se,timeout=30)
   row=dict(name=name,round=round,command=command,status=r.returncode,processSeconds=time.monotonic()-start);report['rows'].append(row);save()
   assert r.returncode==0 and json.loads((out/(stem+'.stdout')).read_text())==oracle
   timing=json.loads((out/(stem+'.stderr')).read_text());row['measurement']=timing;row['workerSeconds']=timing['workerSeconds'];save()
 report['medians']={name:statistics.median(x['workerSeconds'] for x in report['rows'] if x['name']==name) for name,_ in binaries}
 baseline=report['medians']['fused-production-clang'];report['ratiosToProductionClang']={k:v/baseline for k,v in report['medians'].items()}
 for item in inputs:R.N.verify(item)
 report['complete']=True;save();print(json.dumps(dict(complete=True,medians=report['medians'],ratios=report['ratiosToProductionClang'])))
except BaseException as e:report['error']=repr(e);save();raise
