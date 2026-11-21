#!/usr/bin/env python3
"""Read-only arithmetic on retained acquisitions; no target execution."""
from collections import defaultdict
import hashlib
import json
import math
from pathlib import Path
import statistics

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
def pin(p):
 p=Path(p);return dict(file=str(p),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
def read(p): return json.loads(Path(p).read_text())
def same(pin_):
 p=pin_.get('file',pin_.get('path'));assert pin(ROOT/p)['sha256']==pin_['sha256'],p

history=ROOT/'research/phase198/runtime-broad/orbit-summary.json'
identity=ROOT/'research/phase198/runtime-broad/evidence/progress-live-equivalence.json'
timing=ROOT/'selfhost/build/phase199/focused-runtime01/report.json'
manifest=ROOT/'selfhost/build/phase198/progress-native45-02/programs.manifest.json'
s=read(history);identity_report=read(identity);f=read(timing);m=read(manifest)
assert identity_report['complete'] and identity_report['objectsIdentical']==45 and identity_report['liveAllocatedLayoutsIdentical']==45
same(identity_report['measuredSummary']);same(identity_report['measuredReport'])
assert f['complete'] and f['positionBalanced'] and len(f['samples'])==225
same(f['products']);same(f['method']);same(f['study'])
products=read(f['products']['file'])
groups=[]
for g in f['groups']:
 samples=[r for r in f['samples'] if r['case']==g['case'] and r['arm']==g['arm']]
 pairs=[]
 for round_ in range(f['rounds']):
  rows={r['role']:r for r in samples if r['round']==round_}
  assert set(rows)==set(f['roles'])
  for role,row in rows.items():
   stdout=row['observation']['stdout'].splitlines()
   assert stdout[0]+'\n'==products['cases'][g['case']]['point']['expectedStdout']
   assert int(stdout[1])==4 and int(stdout[2])==row['repetitions']
   assert math.isclose(row['nsPerWork'],float(stdout[3])*1e6/row['repetitions'])
  pairs.append({role:rows['simd']['nsPerWork']/rows[role]['nsPerWork'] for role in ['baseline','delegate','c']})
 medians={role:statistics.median(p[role] for p in pairs) for role in pairs[0]}
 assert math.isclose(medians['baseline'],g['againstMatchedBaseline']['simd']['median'])
 assert math.isclose(medians['c'],g['simdOverC']) and math.isclose(medians['delegate'],g['simdOverDelegate'])
 groups.append(dict(case=g['case'],arm=g['arm'],pairs=pairs,medianRatios=medians))

cases=[c for c in s['cases'] if c['ratioEligible']]
assert len(cases)==44
family={c['id']:c['family'] for c in m['cases']}
base=sum(c['fixedEquivalentMs']['live'] for c in cases)
base_geo=math.exp(sum(math.log(c['ratios']['live']['overC']) for c in cases)/len(cases))
assert math.isclose(base_geo,s['subsets']['all']['roles']['live']['overC']['geomean'])
projections=[]
for arm in ['live/program-helper-runtime','live/program-runtime-helper']:
 ratios={g['case']:g['medianRatios']['baseline'] for g in groups if g['arm']==arm}
 changed=[];families=defaultdict(lambda:dict(milliseconds=0,cMilliseconds=0,positiveExcessMilliseconds=0,cases=[]))
 ranked=[]
 for c in cases:
  ms=c['fixedEquivalentMs']['live'];cms=c['fixedEquivalentMs']['c'];ratio=ratios.get(c['id'],1)
  projected=ms*ratio
  if c['id'] in ratios:changed.append(dict(case=c['id'],ratio=ratio,baselineMilliseconds=ms,projectedMilliseconds=projected,savedMilliseconds=ms-projected))
  fam=families[family[c['id']]];fam['milliseconds']+=projected;fam['cMilliseconds']+=cms
  fam['positiveExcessMilliseconds']+=max(0,projected-cms);fam['cases'].append(c['id'])
  ranked.append(dict(case=c['id'],projectedMilliseconds=projected,cMilliseconds=cms,positiveExcessMilliseconds=max(0,projected-cms),historicalDispersionFlag=c['flagged']))
 saved=sum(c['savedMilliseconds'] for c in changed)
 factor=math.exp(sum(math.log(r) for r in ratios.values())/len(cases))
 projections.append(dict(arm=arm,ratioEligibleDenominator=len(cases),unchangedCases=len(cases)-len(changed),geometricFactor=factor,geometricReductionPercent=100*(1-factor),baselineGeomeanOverC=base_geo,projectedGeomeanOverC=base_geo*factor,baselineMilliseconds=base,projectedMilliseconds=base-saved,savedMilliseconds=saved,timeReductionPercent=100*saved/base,changedCases=changed,remainingFamilies=sorted([dict(family=k,**v) for k,v in families.items()],key=lambda r:-r['positiveExcessMilliseconds']),remainingCases=sorted(ranked,key=lambda r:-r['positiveExcessMilliseconds'])))

out=dict(kind='offline-scan-only-contribution-projection',complete=True,programsExecuted=False,inputs=[pin(x) for x in [history,identity,timing,manifest,Path(__file__)]],measuredGroups=groups,sampleCount=len(f['samples']),minimumSampleMilliseconds=min(r['observation']['elapsedMs'] for r in f['samples']),projections=projections,formula='For each of3 measured fold cases, projected fixed time=historical Phase198 live fixed time × median within-round SIMD/matched-baseline ratio. All41 other eligible cases unchanged. Geometric factor=exp(sum(log(three ratios))/44).',scope='This combines measured focused Phase199 ratios with authenticated Phase198 fixed-work medians. It is a projection, not a new whole-catalog timing. Historical dispersion flags and current single-session limitations remain. Family positive C excess is diagnostic headroom, not promised attainable gain.')
(HERE/'evidence/contribution.json').write_text(json.dumps(out,indent=2)+'\n')
print(json.dumps([{k:v for k,v in p.items() if k not in ['remainingFamilies','remainingCases','changedCases']} for p in projections],indent=2))
