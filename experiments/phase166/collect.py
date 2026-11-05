#!/usr/bin/env python3
"""Collect completed, immutable investigation receipts; execute no targets."""
import hashlib, json, shutil
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
BUILD=ROOT/'selfhost/build/phase166'
OUT=ROOT/'implementation/phase166'
def read(p): return json.loads(p.read_text())
def pin(p):
    b=p.read_bytes()
    return dict(file=str(p.relative_to(ROOT)),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def copy(p,name):
    dst=OUT/'evidence'/name; dst.parent.mkdir(parents=True,exist_ok=True)
    if dst.exists(): raise ValueError('Fresh evidence required: '+str(dst))
    shutil.copyfile(p,dst)
    return pin(dst)
evidence=[]
names=['lookup-api01','lookup-controls01','lookup-expected-controls01',
       'lookup-products01','lookup-products02','lookup-consumer-products01',
       'lookup-profile01','lookup-clean01']
for name in names:
    p=BUILD/name/'report.json'; r=read(p); assert r['complete']
    evidence.append(copy(p,name+'/report.json'))
census={}
for campaign,name in [('backend-census02','map'),('backend-census02','verifier'),('backend-census03','map')]:
    p=BUILD/campaign/(name+'-replay/report.json');r=read(p)
    assert r['complete'] and r['qbeOracleExact'] and r['cOracleExact']
    assert r['census']['qbe']['qbeStageOrder']['admitted']
    evidence.append(copy(p,campaign+'/'+name+'.json'))
    census[campaign+'/'+name]={k:dict(instrumentedSeconds=r['products'][k]['seconds'],
        taggedObjectEvents=sum(v['objects'].values()),objects=v['objects'],work=v['work'],
        intervals=v['intervals'],producers=v.get('producers')) for k,v in r['census'].items()}
for name in ['lookup-profile-comparison02.json','lookup-profile-summary02.md']:
    evidence.append(copy(BUILD/name,name))
processes=[]
for p in sorted(BUILD.rglob('process.json')):
    r=read(p); life=read(p.parent/'retention.json')
    assert r['complete'] and r['returncode']==0 and life['closed']
    processes.append(dict(guard=str(p.parent.relative_to(ROOT)),wallSeconds=r['wallSeconds'],
        peakTreeRssBytes=r['peakTreeRssBytes'],minimumDiskFreeBytes=r['minimumDiskFreeBytes'],
        peakRunAllocatedBytes=r['peakRunAllocatedBytes'],closure=life['closure']))
    evidence.append(copy(p,'guards/'+p.parent.relative_to(BUILD).as_posix().replace('/','-')+'.json'))
    evidence.append(copy(p.parent/'retention.json','retention/'+p.parent.relative_to(BUILD).as_posix().replace('/','-')+'.json'))
for name in ['closures.json','reclaim01-applied/report.json']:
    p=ROOT/'selfhost/build-retention/phase166'/name
    if p.exists(): evidence.append(copy(p,'retention/'+name.replace('/','-')))
profiles=read(BUILD/'lookup-profile-comparison02.json')['workloads']['lookup10000']
full=read(BUILD/'lookup-products02/report.json'); control=read(BUILD/'lookup-consumer-products01/report.json')
summary={}
for role,row in profiles.items():
    profile=row['profile']; assert profile['adequate'] and profile['wholeChildCpuCoverageAdequate']
    summary[role]=dict(clean=row['clean'],balancedMedian=full['medians'][role],
        expectedRecordsMedian=control['medians'][role],
        acceptedCaptures=len(profile['acceptedCaptures']),rejectedCaptures=len(profile['rejectedCaptures']),
        acceptedSamples=profile['samples'],unknownSamples=profile['unknownSamples'],
        functions=profile['functions'],categories=profile['categories'],
        sampledOverCleanWallRatio=row['sampledOverCleanWallRatio'])
qbe=summary['qbe']['functions']
metrics=dict(phase=166,complete=True,productionChanged=False,qualifiedCompiler='Phase152',
    sourceIdentity=full['source'],lookup=summary,
    qbeCtorTakePhysicalFraction=sum(x['periodWeightedFraction'] for x in qbe if x['decoded'] in
        ['p125_rt_ctor1','p125_rt_ctor2','p125_rt_take1','p125_rt_take2']),
    fullQbeOverBendc=full['medians']['qbe']/full['medians']['bendc'],
    controlQbeOverBendc=control['medians']['qbe']/control['medians']['bendc'],
    controlCOverBendc=control['medians']['c']/control['medians']['bendc'],
    census=census,guardedJobs=processes,guardWallSeconds=sum(x['wallSeconds'] for x in processes),
    evidence=evidence,scope='Investigation only. Kernel timing is not compiler throughput. Hosted constructor events are not native allocations. Counterfactual producer changes sharing/reachability, so times are not additive attribution.')
OUT.mkdir(parents=True,exist_ok=True)
(OUT/'metrics.json').write_text(json.dumps(metrics,indent=2)+'\n')
print(json.dumps(dict(jobs=len(processes),guardSeconds=metrics['guardWallSeconds'],evidence=len(evidence),
    qbeCtorTakeFraction=metrics['qbeCtorTakePhysicalFraction'])))
