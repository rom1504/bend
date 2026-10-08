#!/usr/bin/env python3
"""Data-only native results. Keeps acquisition and runtime clocks separate."""
import argparse, hashlib, json, math, statistics
from pathlib import Path
def identity(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(path=str(p),sha256=hashlib.sha256(b).hexdigest(),bytes=len(b))
def checked(p):
 d=json.loads(p.read_text());assert d['complete'],p
 for i in d.get('inputs',[]):assert identity(i['path'])==i,i['path']
 return d
p=argparse.ArgumentParser();p.add_argument('--acquired',type=Path,nargs='+',required=True);p.add_argument('--timing',type=Path,nargs='+',required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
acquisitions=[checked(f) for f in a.acquired];timings=[checked(f) for f in a.timing]
recipes={d['recipe']['sha256'] for d in acquisitions+timings};assert len(recipes)==1,'Do not pool different compiler recipes'
products={};runs={}
for d in acquisitions:
 for r in d['records']:
  key=(r['case'],r['role']);assert key not in products and r['correct'];products[key]=r
  for item in [r['executable'],r['nativeSource'],r['emissionReceipt']]:assert identity(item['path'])==item
for d in timings:
 assert d['kind']=='phase67-native-measure','Calibration is not final timing'
 for r in d['records']:
  assert r['correct'] and r['validClock'];key=(r['case'],r['role']);runs.setdefault(key,[]).append(r)
rows=[]
for case in sorted({c for c,role in runs}):
 row=dict(case=case,roles={})
 counts={(r['repetitions'],r['warmups']) for (c,role),items in runs.items() if c==case for r in items};assert len(counts)==1,'Fixed workload differs'
 for (c,role),items in runs.items():
  if c!=case:continue
  product=products[(c,role)];samples=[r['elapsedMs']/r['repetitions']*1000 for r in items]
  row['roles'][role]=dict(runtimeMicrosecondsPerWorkload=statistics.median(samples),samplesMicrosecondsPerWorkload=samples,rounds=len(samples),minimumElapsedMs=min(r['elapsedMs'] for r in items),allTimingQualified=all(r['timingQualified'] for r in items),runtimeRelativeRange=(max(samples)-min(samples))/statistics.median(samples),emissionTimings=product['emissionTimings'],clangWallSeconds=product['toolchain']['wallSeconds'],sourceBytes=product['nativeSource']['bytes'],executableBytes=product['executable']['bytes'],emissionPeakRssBytes=product['emission']['peakTreeRssBytes'],clangPeakRssBytes=product['toolchain']['peakTreeRssBytes'])
 if set(row['roles'])=={'upstream','selfhost'}:
  row['selfhostOverUpstreamRuntime']=row['roles']['selfhost']['runtimeMicrosecondsPerWorkload']/row['roles']['upstream']['runtimeMicrosecondsPerWorkload']
  row['selfhostOverUpstreamClang']=row['roles']['selfhost']['clangWallSeconds']/row['roles']['upstream']['clangWallSeconds']
 rows.append(row)
result=dict(kind='phase67-native-summary-v1',complete=True,producer=identity(__file__),inputs=[identity(f) for f in a.acquired+a.timing],recipeSha256=next(iter(recipes)),rows=rows,allTimingQualified=all(v['allTimingQualified'] for r in rows for v in r['roles'].values()),scope='Equal input wrappers, native CPU3 threads1/GPUoff. Six-family diagnostic maximum; finite conformance, not universal speed. C build is single acquisition, runtime medians exclude it.')
ratios=[r['selfhostOverUpstreamRuntime'] for r in rows if 'selfhostOverUpstreamRuntime' in r]
if ratios:result['geomeanSelfhostOverUpstreamRuntime']=math.exp(sum(map(math.log,ratios))/len(ratios))
a.out.parent.mkdir(parents=True,exist_ok=True)
with a.out.open('x') as f:json.dump(result,f,indent=2);f.write('\n')
print(json.dumps({'output':identity(a.out),'allTimingQualified':result['allTimingQualified'],'rows':[{'case':r['case'],'ratio':r.get('selfhostOverUpstreamRuntime')} for r in rows]}))
