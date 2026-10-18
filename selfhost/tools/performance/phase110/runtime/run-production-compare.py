#!/usr/bin/env python3
"""Execute one frozen direct production comparison; root must guard serially."""
import argparse,hashlib,json,statistics,subprocess,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5]
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--plan',type=Path,required=True);a=p.parse_args()
plan=a.plan.resolve();out=plan.parent;spec=json.loads(plan.read_text());assert spec['complete'] and not spec['targetsRun']
pin=lambda p:dict(file=str(p.resolve()),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
def verify(row):assert pin(Path(row['file']))==row, 'changed input '+row['file']
for row in spec['inputs']+spec['outputs']:verify(row)
report=dict(kind='phase110-direct-production-comparison',complete=False,inputs=[pin(Path(__file__)),pin(plan),*spec['inputs'],*spec['outputs']],started=time.time(),rows=[],scope=spec['limitations'])
report_path=out/'report.json';assert not report_path.exists()
def save():report_path.write_text(json.dumps(report,indent=2)+'\n')
save()
try:
 for item in spec['commands']:
  label=item['label'];row={**item};report['rows'].append(row);save();t=time.monotonic()
  with (out/(label+'.stdout')).open('xb') as so,(out/(label+'.stderr')).open('xb') as se:
   result=subprocess.run(item['command'],cwd=ROOT,stdout=so,stderr=se,timeout=60)
  row.update(status=result.returncode,processSeconds=time.monotonic()-t,stdout=pin(out/(label+'.stdout')),stderr=pin(out/(label+'.stderr')));save();assert result.returncode==0,label
  if item['kind']=='link':report['candidateBinary']=pin(out/'candidate-qbe')
  if 'expectedJsonLines' in item:assert [json.loads(s) for s in (out/(label+'.stdout')).read_text().splitlines()]==item['expectedJsonLines'],label
  if 'expectedJson' in item:
   assert json.loads((out/(label+'.stdout')).read_text())==item['expectedJson'],label
   timing=json.loads((out/(label+'.stderr')).read_text());assert timing['repetitions']==spec['comparison']['repetitions'];row['measurement']=timing;row['workerSeconds']=timing['workerSeconds']
  save()
 timings=[r for r in report['rows'] if r['kind']=='timing'];med={n:statistics.median(r['workerSeconds'] for r in timings if r['name']==n) for n in ['production-clang','candidate-qbe']}
 ratios=[next(r['workerSeconds'] for r in timings if r['round']==i and r['name']=='candidate-qbe')/next(r['workerSeconds'] for r in timings if r['round']==i and r['name']=='production-clang') for i in range(spec['comparison']['rounds'])]
 report.update(medians=med,ratio=med['candidate-qbe']/med['production-clang'],roundRatios=ratios,ranges={n:[min(r['workerSeconds'] for r in timings if r['name']==n),max(r['workerSeconds'] for r in timings if r['name']==n)] for n in med},finished=time.time())
 for row in report['inputs']:verify(row)
 report['complete']=True;save();print(json.dumps({k:report[k] for k in ['complete','medians','ratio','roundRatios']}))
except BaseException as e:report['error']=repr(e);save();raise
