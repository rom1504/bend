#!/usr/bin/env python3
"""Publish completed Phase112 receipt summaries; no compiler/target execution."""
import csv,hashlib,json,statistics
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4]
B=ROOT/'selfhost/build/phase112';I=ROOT/'implementation/phase112';T=Path(__file__).parent
P=ROOT/'selfhost/build/phase111'
def read(p):return json.loads(Path(p).read_text())
def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
old=read(B/'word-broad-runtime01/report.json');new=read(B/'facts-broad-runtime01/report.json')
assert old['complete'] and new['complete'] and old['timingProfile']==new['timingProfile']
assert all(not p.exists() for p in [I/'broad-runtime.csv',I/'results.json',T/'selection.json'])
rows=[]
for name in new['requestedCorpusNames']:
 a=old['perProgram'].get(name);z=new['perProgram'].get(name)
 if a is None or z is None:
  assert name=='scalar-region-0'
  os=[r for r in old['records'] if r['case']==name];ns=[r for r in new['records'] if r['case']==name]
  assert len(os)==len(ns)==6 and all(r['correct'] for r in os+ns)
  rows.append(dict(program=name,word_ms=statistics.median(r['elapsedMs'] for r in os if r['role']=='word-n2'),word_upstream_ms=statistics.median(r['elapsedMs'] for r in os if r['role']=='upstream'),facts_ms=statistics.median(r['elapsedMs'] for r in ns if r['role']=='facts-n2'),facts_upstream_ms=statistics.median(r['elapsedMs'] for r in ns if r['role']=='upstream'),word_upstream_ratio=None,facts_upstream_ratio=None,normalized_facts_word_ratio=None))
  continue
 o=a['ratiosToUpstream']['word-n2'];n=z['ratiosToUpstream']['facts-n2']
 rows.append(dict(program=name,word_ms=a['mediansMs']['word-n2'],word_upstream_ms=a['mediansMs']['upstream'],facts_ms=z['mediansMs']['facts-n2'],facts_upstream_ms=z['mediansMs']['upstream'],word_upstream_ratio=o,facts_upstream_ratio=n,normalized_facts_word_ratio=n/o))
r4=read(B/'transport04/report.json');r5=read(B/'transport05/report.json');assert r4['complete'] and r5['complete']
required=[B/'facts-full-jobs01/report.json',B/'facts-broad-jobs01/report.json',B/'facts-admission01/report.json',B/'facts-gap-if-admission01/manifest.json',B/'facts-api-native-products01/report.json',B/'facts-self-elf-authenticated01/report.json']
for p in required:
 d=read(p)
 assert d.get('complete',d.get('admitted',False)),str(p)
summary=dict(kind='phase112-final-measurement-summary',complete=True,ratioDirection='ours/reference elapsed time; smaller is faster',compilerGenerations=r4['summary']['cache']['threeCaseGeometricRatios'],matchedPhase111Comparison=r5['summary']['cache']['threeCaseGeometricRatios'],programRuntime=dict(points=44,families=23,zeroWorkControls=1,rounds=3,wordUpstream=old['geomeanRatios']['upstream']['word-n2'],factsUpstream=new['geomeanRatios']['upstream']['facts-n2'],outsideInitialSixPoints=38,outsideInitialSixUpstream=new['phase112Heldout']['geomeanRatios']['upstream']['facts-n2'],comparisonScope='Word/facts broad measurements are separate controlled campaigns. Exact matched incremental effects use the six-case experiments; no inferential confidence interval is claimed.'),selfEmissionSeconds=read(P/'p112-facts-self01/report.json')['nativeSeconds'],inputs=[pin(__file__)]+[pin(p) for p in required+[B/'transport04/report.json',B/'transport05/report.json',B/'word-broad-runtime01/report.json',B/'facts-broad-runtime01/report.json',B/'profile-facts-compiler01/report.json',B/'broad-shapes01/report.json']],limitations=['Experimental direct-QBE N1/N2; installed B1/B2 unchanged','Three compilation inputs, not broad compiler timing','Native prepared Base/cached runtime versus upstream source Base/full C build','CPU1/GPUoff; no parallel qualification','Structural verifier and corpus checks are not whole-compiler correctness proof'])
with (I/'broad-runtime.csv').open('x') as f:
 w=csv.DictWriter(f,fieldnames=list(rows[0]),lineterminator="\n");w.writeheader();w.writerows(rows)
(I/'results.json').write_text(json.dumps(summary,indent=2)+'\n')
selection=dict(kind='phase112-qualified-experimental-selection',profile='facts',productionSelectionChanged=False,source=pin(B/'facts-source01/compiler.bend'),sourceManifest=pin(B/'facts-source01/manifest.json'),recipe=pin(B/'facts-source01/profile.json'),api=pin(P/'p112-facts-api02/api.mjs'),n1=pin(P/'p112-facts-full-native01/program'),n2=pin(P/'p112-facts-self01/build/program'),runtime=pin(P/'runtime-source04/runtime.o'),qualification=[pin(p) for p in required],results=pin(I/'results.json'),fallbackProfile='word',rejectedProfiles=['fast'],scope='Qualified sequential x86-64 direct-QBE research integration. Generated artifacts are local; checked Bend recipes and bounded receipts are committed. This does not alter selfhost/tools/native/selection.json.')
(T/'selection.json').write_text(json.dumps(selection,indent=2)+'\n')
print(json.dumps(dict(complete=True,targetsRun=False,programRows=len(rows),profile='facts')))
