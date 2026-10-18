#!/usr/bin/env python3
"""Frozen finite worker policy experiment. Python supervises; it does not optimize Bend."""
import argparse,importlib.util,json,math,statistics,sys,time
from pathlib import Path
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[4];HERE=ROOT/'selfhost/tools/performance/phase110'
s=importlib.util.spec_from_file_location('p108',HERE.parent/'phase108/run.py');R=importlib.util.module_from_spec(s);s.loader.exec_module(R)
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--build',type=Path,required=True);p.add_argument('--out',type=Path,required=True);p.add_argument('--rounds',type=int,default=3);p.add_argument('--repetitions',type=int,default=10);p.add_argument('--profiles',nargs='+');p.add_argument('--cases',nargs='+');p.add_argument('--reference',default='fused-qbe');p.add_argument('--selection',type=Path);p.add_argument('--calibration',type=Path);a=p.parse_args()
out=a.out.resolve();assert out.is_relative_to(ROOT/'selfhost/build/phase110') and not out.exists();assert 3<=a.rounds<=5 and 1<=a.repetitions<=100
build=a.build.resolve();manifest=json.loads((build/'report.json').read_text());assert manifest['complete'];out.mkdir(parents=True)
plan=HERE/'controls/policy-search.json';spec=json.loads(plan.read_text());names=a.cases or spec['trainingWorkloads'];workers=[w for w in manifest['workers'] if not a.profiles or w['name'] in a.profiles];assert a.reference in [w['name'] for w in workers]
expected=next(x for x in manifest['inputs'] if x['file'].endswith('/expected.jsonl'));oracle={v['name']:v for v in map(json.loads,Path(expected['file']).read_text().splitlines())};assert all(n in oracle for n in names)
calibration=json.loads(a.calibration.read_text()) if a.calibration else None
counts={n:a.repetitions for n in names}
if calibration:
 counts={r['case']:r['repetitions'] for r in calibration['calibration']};assert set(names)==set(counts)
inputs=[R.pin(Path(__file__)),R.pin(build/'report.json'),R.pin(plan),expected,*[w['binary'] for w in workers]]
if a.calibration:inputs.append(R.pin(a.calibration))
report=dict(kind='phase110-bounded-worker-policy-search',complete=False,inputs=inputs,rounds=a.rounds,repetitions=a.repetitions,repetitionsPerCase=counts,cases=names,reference=a.reference,training=not bool(a.cases),selectionFrozen=False,rows=[],started=time.time(),scope='Worker clock excludes graph construction/observation/release. Process and campaign clocks include them. Same immutable source/library/runtime; no agent edits inside this finite evaluation.')
(out/'method.py').write_bytes(Path(__file__).read_bytes())
selection=json.loads(a.selection.read_text()) if a.selection else None
if selection:
 assert selection['complete'] and selection['selectionFrozen'];inputs.append(R.pin(a.selection))
 assert set(w['name'] for w in workers)=={selection['reference'],selection['qbeWinner'],selection['globalWinner']}
 assert names==spec['heldoutWorkloads']
 report.update(kind='phase110-frozen-winner-evaluation',training=False,selection=R.pin(a.selection))
save=lambda:R.save(out/'report.json',report);save()
def gm(v):return math.exp(statistics.mean(math.log(x) for x in v))
try:
 for row in inputs:R.N.verify(row)
 for r in range(a.rounds):
  order=workers if r%2==0 else list(reversed(workers))
  for case in names:
   for w in order:
    name=w['name'];label=f'{r}-{case}-{name}';command=[w['binary']['file'],case,str(counts[case])];start=time.monotonic()
    with (out/(label+'.stdout')).open('xb') as so,(out/(label+'.stderr')).open('xb') as se:c=R.P.run(command,cwd=ROOT,stdout=so,stderr=se,timeout=60)
    row=dict(name=name,case=case,round=r,command=command,status=c.returncode,processSeconds=time.monotonic()-start);report['rows'].append(row);save()
    if c.returncode or json.loads((out/(label+'.stdout')).read_text())!=oracle[case]:raise ValueError(label+' semantics failed')
    timing=json.loads((out/(label+'.stderr')).read_text());assert timing['name']==case and timing['repetitions']==counts[case]
    row.update(measurement=timing,workerSeconds=timing['workerSeconds']);save()
 med={w['name']:{case:statistics.median(x['workerSeconds'] for x in report['rows'] if x['name']==w['name'] and x['case']==case) for case in names} for w in workers}
 ratios={n:{case:v[case]/med[a.reference][case] for case in names} for n,v in med.items()}
 ranking=sorted([dict(name=n,ratio=gm(v.values()),cases=v) for n,v in ratios.items()],key=lambda r:r['ratio'])
 def eligible(row):
  if row['ratio']>=.97:return False
  return all(gm([next(x['workerSeconds'] for x in report['rows'] if x['round']==r and x['case']==case and x['name']==row['name'])/next(x['workerSeconds'] for x in report['rows'] if x['round']==r and x['case']==case and x['name']==a.reference) for case in names])<1 for r in range(a.rounds))
 win=next((row['name'] for row in ranking if eligible(row)),a.reference);qwin=next((row['name'] for row in ranking if row['name'].endswith('-qbe') and eligible(row)),a.reference)
 report.update(medians=med,ranking=ranking,globalWinner=win,qbeWinner=qwin,selectionFrozen=True,finished=time.time())
 if selection:
  report.update(globalWinner=selection['globalWinner'],qbeWinner=selection['qbeWinner'],selectionFrozen=False,evaluationOnly=True,accepted={n:gm(ratios[n].values())<=1.03 for n in [selection['globalWinner'],selection['qbeWinner']]})
 for row in inputs:R.N.verify(row)
 report['complete']=True;save();print(json.dumps(dict(complete=True,ranking=[dict(name=r['name'],ratio=r['ratio']) for r in ranking],globalWinner=win,qbeWinner=qwin,wallSeconds=report['finished']-report['started'])))
except BaseException as e:report['error']=repr(e);save();raise
