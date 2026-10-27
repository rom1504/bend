#!/usr/bin/env python3
"""Offline exact short-request stage-clock summary, no new target execution."""
import hashlib,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5]
def pin(p):
 p=Path(p).resolve();h=hashlib.sha256()
 with p.open('rb') as f:
  for b in iter(lambda:f.read(1048576),b''):h.update(b)
 return dict(file=str(p),bytes=p.stat().st_size,sha256=h.hexdigest())
def verify(x):assert pin(x['file'])==x
src=ROOT/'selfhost/build/phase145/native-stages-observe01/report.json';d=json.loads(src.read_text());assert d['complete'];inputs=[pin(__file__),pin(src),d['stageSpec']];rows=[]
partitions=[('Base',0,1),('Frontend including erasure',1,10),('Admission/static/raw lowering',10,14),('Initial optimizer',14,15),('First verifier',15,16),('Observer/final admission',16,19),('Output opening',19,20),('Registry',20,22),('Render/output/teardown',22,23)]
for x in d['rows']:
 assert x['exactQbe'];verify(x['stageSidecar']);verify(x['sampleFile']);inputs.extend([x['stageSidecar'],x['sampleFile'],x['source'],x['expected']]);intervals=x['intervals'];assert len(intervals)==24 and all(y['available'] for y in intervals[:23])
 groups=[dict(label=name,wallSeconds=sum(y['wallSeconds'] for y in intervals[a:b]),processCpuSeconds=sum(y['processCpuSeconds'] for y in intervals[a:b])) for name,a,b in partitions]
 rows.append(dict(name=x['name'],source=x['source'],expected=x['expected'],diagnosticWallSeconds=x['wallSeconds'],samples=x['sampleHeader']['samples'],quality=x['sampleQuality'],groups=groups,intervals=intervals,optionalFinalVerifier=intervals[23],markerSpanSeconds=sum(g['wallSeconds'] for g in groups),baseFractionOfMarkerSpan=groups[0]['wallSeconds']/sum(g['wallSeconds'] for g in groups)))
for x in inputs:verify(x)
out=ROOT/'research/phase145/native-stages.json';assert not out.exists();summary=dict(kind='phase145-native-short-stage-summary-v1',complete=True,targetsRun=False,inputs=inputs,compilerSource=d['compilerSource'],programObject=d['programObject'],rows=rows,limits=['One short diagnostic request per source; clocks are not a repeated clean benchmark.','156/243/51 samples respectively: all distributions descriptive below500; no full source capture.','Optional nested verifier appears only inMap and is not added to disjoint groups.','Base marker span excludes earlierprocess/IOfileread and laterteardown; no complete startup attribution.']);out.write_text(json.dumps(summary,indent=2)+'\n');print(json.dumps(dict(complete=True,summary=pin(out),rows=[dict(name=x['name'],markerSpanSeconds=x['markerSpanSeconds'],baseFraction=x['baseFractionOfMarkerSpan']) for x in rows])))
