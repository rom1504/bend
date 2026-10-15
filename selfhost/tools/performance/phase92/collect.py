#!/usr/bin/env python3
"""Offline final native-chain scoreboard; no compiler or benchmark execution."""
import hashlib,json,pathlib,sys,zipfile
ROOT=pathlib.Path(__file__).resolve().parents[4];RAW=ROOT/'selfhost/build/phase92';OUT=ROOT/'implementation/phase92'
def read(p):return json.loads(pathlib.Path(p).read_text())
def pin(p):
 p=pathlib.Path(p).resolve();b=p.read_bytes();return dict(file=str(p),sha256=hashlib.sha256(b).hexdigest(),bytes=len(b))
def verify(r):assert pin(r['file'])==r
inputs=[]
def get(p):
 p=pathlib.Path(p);inputs.append(pin(p));return read(p)
build=get(RAW/'upstream-b1/build.json');screen=get(RAW/'screen01/report.json');broad=get(RAW/'broad02/report.json');parent=get(RAW/'broad01/report.json')
selfs={r:get(RAW/f'self-{r}-01/report.json') for r in ['b1','b2']};ts=get(RAW/'full-ts-bun01/report.json')
live=get(RAW/'live01/report.json');assert live['complete'] and live['passed'] and len(live['rows'])==3
conf=get(OUT/'native-conformance-results01.json');census=get(ROOT/'implementation/phase91/census01.json')
for r in [build,screen,broad,*selfs.values(),ts,conf]:assert r['complete'] and r.get('passed',True)
assert len(screen['rows'])==36 and all(r['passed'] for r in screen['rows'])
assert len(broad['rows'])==90 and len(broad['programExecutions'])==45
assert all(r['passed'] for r in broad['rows']+broad['programExecutions'])
assert parent['provenance']['originalSources']==23 and broad['parentActuallyCompletedCompilerJobs']==89 and broad['newTargetJobsStarted']==91
assert not parent['complete'] and parent['error']=='AssertionError: Need 160 MiB reserve plus per-job output headroom'
assert conf['counts']==dict(originalNative100=100,eligiblePerRole=69,excludedPerRole=31,executionObservations=138,rejectionObservations=6)
cap=ROOT/'selfhost/tools/performance/phase92/evidence01'
receipt=get(cap/'receipt.json');assert receipt['complete']
for field in ['archive','manifest']:
 r=receipt[field];p=ROOT/r['file'];actual=pin(p);assert (actual['bytes'],actual['sha256'])==(r['bytes'],r['sha256'])
with zipfile.ZipFile(cap/'raw.zip') as z:
 for r in selfs.values():
  assert r['exactC'] and r['source']['sha256']==build['source']['sha256']
  b=z.read(str(pathlib.Path(r['output']['file']).relative_to(ROOT)))
  assert (len(b),hashlib.sha256(b).hexdigest())==(r['output']['bytes'],r['output']['sha256'])
  assert b==pathlib.Path(r['oracle']['file']).read_bytes()
for r in census['modules'].values():verify(r['identity'])
assert len(census['modules'])==132
jobs=[]
for p in sorted(RAW.rglob('process.json')):
 r=read(p);assert r['complete'] and r['returncode']==0 and not r.get('stoppedFor')
 assert r['finished']>r['started'] and r['wallSeconds']>0
 jobs.append(dict(receipt=pin(p),**{k:r[k] for k in ['started','finished','wallSeconds','peakTreeRssBytes','returncode']}))
ordered=sorted(jobs,key=lambda r:r['started']);overlap=[(a['receipt']['file'],b['receipt']['file']) for a,b in zip(ordered,ordered[1:]) if b['started']<a['finished']];assert not overlap
execution=dict(guardedJobs=len(jobs),targetWallSeconds=sum(r['wallSeconds'] for r in jobs),campaignSpanSeconds=ordered[-1]['finished']-ordered[0]['started'],peakRssBytes=max(r['peakTreeRssBytes'] for r in jobs),overlapCount=len(overlap),preLaunchDiskStops=1,jobs=jobs,scope='Root-guarded serial jobs, including suite controllers and their descendants. Does not count agents, documentation, archival IO or quota usage.')
(OUT/'execution-ledger.json').write_text(json.dumps(execution,indent=2)+'\n')
tms=ts['workerResult']['calls'][0]['requestMs'];full={}
for role,r in selfs.items():full[role]=dict(requestSeconds=r['requestMs'][0]/1000,processSeconds=r['process']['wallSeconds'],peakRssBytes=r['process']['peakTreeRssBytes'],overTsBunRequest=r['requestMs'][0]/tms,overTsBunProcess=r['process']['wallSeconds']/ts['process']['wallSeconds'])
full['ts-bun']=dict(requestSeconds=tms/1000,processSeconds=ts['process']['wallSeconds'],peakRssBytes=ts['process']['peakTreeRssBytes'])
full['b2OverB1Request']=selfs['b2']['requestMs'][0]/selfs['b1']['requestMs'][0]
summary=dict(kind='phase92-native-chain-scoreboard',complete=True,compilerChanged=False,source=build['source'],images=dict(b1=build['image'],b2=screen['authentication']['roles']['b2']['admission']['binary']),upstream=build['upstream'],ratioDefinition='numerator elapsed / denominator elapsed; smaller is faster',compilation=dict(sixSource=screen['summary']['equalCaseGeometricRatios'],uncachedSmallControl=live['summary'],fullSelf=full,broad45= broad['summary']['equalCaseGeometricRatios']),generatedPrograms=dict(points=45,originalSources=23,exactCompleteCObservations=90,executionPasses=45,freshRuntimeSpeedRatio=None,scope='Both native stages equal each frozen current C oracle and shared programs pass. This is output continuity and correctness, not fresh runtime timing; original C12 imports exceed entry scope.'),conformance=dict(nativePerRole=69,rejectionsPerRole=3,excludedPerRole=31,reference=pin(OUT/'native-conformance-results01.json'),fullFrontendQualified=False,jsTargetQualified=False),simplicity=dict(moduleCount=132,**census['bendTotals'],sourceDeltaThisPhase=0,nativeFrozenAssemblyLines=38711,nativeProfileReplacements=14),execution={k:v for k,v in execution.items() if k!='jobs'},inputs=inputs,limits=['Six-source screen has two observations per role/source; full self has one per role. Broad45 spans an explicit disk-reclamation pause and is secondary timing evidence.','Native prepared Base is outside request time but inside process time; TS performs ordinary Base preparation.','Native B2 is reused from byte-identical C, not a newly rebuilt ELF.','Native entry supports checked C only, one Base-importing source and nine providers.','Existing JS B2 rich diagnostic gap, unsupported APIs and GPU/parallel scope remain.'])
for r in inputs:verify(r)
(OUT/'summary.json').write_text(json.dumps(summary,indent=2)+'\n')
print(json.dumps(dict(complete=True,execution=summary['execution'],compilation=summary['compilation']['fullSelf'])))
