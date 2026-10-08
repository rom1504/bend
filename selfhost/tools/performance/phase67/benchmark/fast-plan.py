#!/usr/bin/env python3
"""Derive a Bend-only runtime plan from qualified immutable candidate timings."""
import argparse,hashlib,json,math,statistics
from pathlib import Path
def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(path=str(p),sha256=hashlib.sha256(b).hexdigest(),bytes=len(b))
p=argparse.ArgumentParser();p.add_argument('--timing',type=Path,nargs='+',required=True);p.add_argument('--out',type=Path,required=True);p.add_argument('--target-ms',type=int,default=200);a=p.parse_args();assert a.target_ms>=150
rows={};recipes={};inputs=[]
for file in a.timing:
 d=json.loads(file.read_text());assert d['complete'] and d['kind']=='phase67-native-measure';inputs.append(pin(file));r=d['recipe'];assert pin(r['path'])==r;recipes[r['sha256']]=r
 for item in d['records']:
  if item['role']!='selfhost':continue
  assert item['correct'] and item['timingQualified'];rows.setdefault(item['case'],[]).append(item)
assert len(recipes)==1,'One immutable candidate image required';recipe=next(iter(recipes.values()));config=json.loads(Path(recipe['path']).read_text());assert not config['verifyInstalled'],'Use explicit immutable checked API, not live installed release';api=pin(config['api']);assert any(i==api for i in config['inputs'])
plan={}
for case,items in rows.items():
 costs=[i['elapsedMs']/i['repetitions'] for i in items];cost=statistics.median(costs);count=max(16,math.ceil(a.target_ms/cost/16)*16);warm=count//8
 plan[case]=dict(repetitions=count,warmups=warm,targetBendMs=a.target_ms,predictedBendMs=cost*count,predictedBendWithWarmMs=cost*(count+warm),baselineMillisecondsPerWorkload=cost,baselineSamples=len(items),scope='Bend-only relative runtime loop. TS can fall below valid clock resolution; use separate TS-resolved plan for cross-compiler qualification.')
assert rows and max(x['predictedBendWithWarmMs']for x in plan.values())<1000
with a.out.open('x')as f:json.dump(plan,f,indent=2);f.write('\n')
derivation=dict(kind='phase67-bend-only-fast-plan-v1',complete=True,producer=pin(__file__),inputs=inputs,recipe=recipe,baselineApi=api,output=pin(a.out),cases=len(plan),targetMilliseconds=a.target_ms,predictedTwoRoundMeasuredAndWarmMilliseconds=2*sum(x['predictedBendWithWarmMs']for x in plan.values()),timingQualification='All observed final intervals still must be>=100ms. Faster future candidates may require larger counts and old/new remeasurement. Predictions exclude process start, method hashing and independent oracle calculation.',comparison='Same exact plan and observer for baseline/future candidate; two serial campaigns are not temporally paired. No compilation in runtime loop.')
side=a.out.with_name(a.out.stem+'-derivation.json')
with side.open('x')as f:json.dump(derivation,f,indent=2);f.write('\n')
print(json.dumps({'plan':pin(a.out),'derivation':pin(side),'cases':len(plan),'predictedRuntimeSeconds':derivation['predictedTwoRoundMeasuredAndWarmMilliseconds']/1000}))
