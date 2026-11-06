#!/usr/bin/env python3
"""Root-run prepared projection ceiling; use one outer maintained resource guard."""
import argparse,json,statistics,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
sys.dont_write_bytecode=True
sys.path.insert(0,str(ROOT/'selfhost/tools/build'))
from common import fresh_output,pin,verify,require,run,write_json
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--plan',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
plan=json.loads(a.plan.read_text());require(plan['inverseExact'] and not plan['targetsRun'],'frozen preparation required')
inputs=[pin(__file__),pin(a.plan),*plan['inputs']]
for item in inputs:verify(item)
out=fresh_output(a.out,ROOT);report=dict(complete=False,inputs=inputs,branches=plan['branches'],jobs=[],scope='saved-IR opportunity experiment; no compiler implementation or promotion')
save=lambda:write_json(out/'report.json',report)
try:
 for spec in plan['jobs']:
  label=spec['label'];command=[value.replace('{out}',str(out)) for value in spec['command']]
  result=run(command,cwd=ROOT,stdout=out/(label+'.stdout'),stderr=out/(label+'.stderr'),seconds=spec['seconds'])
  row=dict(label=label,**result);report['jobs'].append(row);save()
  require(result['complete'],label+' failed')
  if spec['expectedStdout'] is not None:
   require((out/(label+'.stdout')).read_bytes()==spec['expectedStdout'].encode(),label+' complete stdout differs')
   require((out/(label+'.stderr')).stat().st_size==0,label+' stderr differs')
   row['completeOutputExact']=True;save()
 for item in inputs:verify(item)
 atomic=[pin(out/f'controls-0-{flag}') for flag in (0,1)]
 require(atomic[0]['sha256']==atomic[1]['sha256'],'atomic fast-flag binary must be exact')
 report['atomicFlagBinaryExact']=atomic
 measurements={}
 for variant in ('baseline','abi-only','fast'):
  values=[row['seconds'] for row in report['jobs'] if row['label'].endswith('-'+variant) and row['label'].startswith('run-')]
  require(len(values)==4,'four balanced observations required')
  measurements[variant]=dict(seconds=values,medianSeconds=statistics.median(values))
 report['measurements']=measurements
 report['fastOverOriginal']=measurements['fast']['medianSeconds']/measurements['baseline']['medianSeconds']
 report['fastOverAbiOnly']=measurements['fast']['medianSeconds']/measurements['abi-only']['medianSeconds']
 report['complete']=True
finally:
 save();print(json.dumps(dict(complete=report['complete'],report=str(out/'report.json'),measurements=report.get('measurements'))))
