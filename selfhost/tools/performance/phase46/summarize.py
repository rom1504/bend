#!/usr/bin/env python3
"""Derive Phase46 result tables from complete retained observations."""
import argparse,hashlib,json,statistics,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4];RAW=ROOT/'selfhost/build/phase46'
p=argparse.ArgumentParser();p.add_argument('--out',required=True,type=Path);a=p.parse_args()
def read(name):return json.loads((RAW/name).read_text())
def identity(path):return dict(path=str(path.relative_to(ROOT)),sha256=hashlib.sha256(path.read_bytes()).hexdigest(),bytes=path.stat().st_size)
timing=read('timing01/report.json');cold=read('cold01/report.json');batch=read('batch03/report.json')
pure=read('pilot02/report.json')['records']+read('expansion01/report.json')['records']
assert len(timing['records'])==len(cold['records'])==72
assert all(r['correct'] and r['timingQualified'] for r in timing['records'])
assert all(r['correct'] for r in cold['records']+batch['records']+pure)
roles=[('upstream','js'),('selfhost','js'),('upstream','c'),('selfhost','c')]
rows=[]
for name in ['numeric','closures','tree','array','map','lexer']:
 row=dict(case=name,cells={})
 for role,target in roles:
  select=lambda x:(x['case'],x['role'],x['target'])==(name,role,target)
  t=list(filter(select,timing['records']));c=list(filter(select,cold['records']))
  b=next(filter(select,batch['records']));q=next(filter(select,pure))
  assert len(t)==len(c)==3
  values=[r['elapsedMs'] for r in t];n=t[0]['repetitions']
  cell=dict(repetitions=n,warmups=t[0]['warmups'],batchMs=values,medianBatchMs=statistics.median(values),
    medianMicrosecondsPerInvocation=statistics.median(values)*1000/n,
    spreadPercent=(max(values)-min(values))/statistics.median(values)*100,
    coldMs=[r['child']['processSeconds']*1000 for r in c],
    medianColdMs=statistics.median(r['child']['processSeconds']*1000 for r in c),
    maxExecutionRssKiB=max(r['child']['maxRssKiB'] for r in t),
    batchEmissionSeconds=b['emission']['wallSeconds'],batchClangSeconds=b.get('toolchain',{}).get('wallSeconds',0),
    pureEmissionSeconds=q['emission']['wallSeconds'],pureClangSeconds=q.get('toolchain',{}).get('wallSeconds',0))
  emitted=RAW/'batch03'/(name+'-'+role+'-'+target)/('program.c' if target=='c' else 'program.'+('cjs' if role=='upstream' else 'mjs'))
  cell['emittedBytes']=emitted.stat().st_size;cell['emittedLines']=len(emitted.read_bytes().splitlines())
  row['cells'][role+'-'+target]=cell
 v={k:c['medianBatchMs'] for k,c in row['cells'].items()}
 row['ratios']=dict(selfJsOverUpstreamJs=v['selfhost-js']/v['upstream-js'],selfCOverUpstreamC=v['selfhost-c']/v['upstream-c'],
   selfCOverSelfJs=v['selfhost-c']/v['selfhost-js'],upstreamJsOverUpstreamC=v['upstream-js']/v['upstream-c'])
 rows.append(row)
diagnostics=read('diagnostics01/report.json');counts=[];profiles=[]
for r in diagnostics['records']:
 if r['kind']=='native-counts':
  assert len(r['runs'])==2 and all(x['correct'] for x in r['runs'])
  lo,hi=[x['counts'] for x in r['runs']]
  delta={k:hi[k]-lo[k] for k in ['heapAllocCalls','requestedWords','hostSegmentEntries','genericClosureEntries']}
  delta['allocationClassCounts']=[b-a for a,b in zip(lo['allocationClassCounts'],hi['allocationClassCounts'])]
  counts.append(dict(case=r['case'],role=r['role'],extraBenchCalls=16,delta=delta))
 elif r['kind']=='v8-cpu-profile':
  assert r['correct'];profiles.append({k:r[k] for k in ['case','role','samples','topFrames']})
receipts=[]
for f in sorted(RAW.rglob('process.json')):
 r=json.loads(f.read_text());receipts.append(dict(path=str(f.relative_to(ROOT)),**{k:r.get(k) for k in ['started','finished','wallSeconds','complete','peakTreeRssBytes','minimumAvailableBytes','stoppedFor']}))
for f in sorted((ROOT/'implementation/phase46/evidence').glob('feasibility-*/process.json')):
 r=json.loads(f.read_text());receipts.append(dict(path=str(f.relative_to(ROOT)),**{k:r.get(k) for k in ['started','finished','wallSeconds','complete','peakTreeRssBytes','minimumAvailableBytes','stoppedFor']}))
intervals=sorted((r['started'],r['finished']) for r in receipts);merged=[]
for lo,hi in intervals:
 if merged and lo<=merged[-1][1]:merged[-1][1]=max(merged[-1][1],hi)
 else:merged.append([lo,hi])
accounting=dict(supervisedJobs=len(receipts),summedJobSeconds=sum(r['wallSeconds'] for r in receipts),
 occupiedIntervalSeconds=sum(hi-lo for lo,hi in merged),maxTreeRssBytes=max(r['peakTreeRssBytes'] for r in receipts),
 minimumAvailableBytes=min(r['minimumAvailableBytes'] for r in receipts),receipts=receipts,
 scope='Supervised execution only. Reading, reasoning, agent coordination, source writing, review, publication and most data-only reporting are not individually timed; do not call the remainder idle.')
sources=['timing01/report.json','cold01/report.json','batch03/report.json','pilot02/report.json','expansion01/report.json','diagnostics01/report.json','oracles.json','timing-plan01.json','environment.json']
summary=dict(kind='phase46-backend-comparison-summary',complete=True,generated=time.time(),producer=identity(Path(__file__)),
 inputs=[identity(RAW/f) for f in sources],timingSamples=72,coldSamples=72,pureCorrectness=24,batchFeasibility=24,independentCycleOracles=96,
 rows=rows,nativeCounts=counts,profiles=profiles,accounting=accounting,
 limitations=['Six selected mechanisms; not full corpus or universal speed.','New Bend batch boundary, not Phase45 host library protocol.',
 'Different native runtimes and different optimizers; not single-factor causal ablation.','Fixed warmup counts and three cyclic rotations, not demonstrated JIT stationarity or fully position-balanced ordering.',
 'Whole-process instrumented profiles/counters are separate from unmodified timing; counters can inhibit optimization.',
 'Cold process includes one complete workload/readback; it does not isolate startup.','Compilation costs have one acquisition each and include checking, verification and orchestration.'])
a.out.parent.mkdir(parents=True,exist_ok=True)
with a.out.open('x') as f:json.dump(summary,f,indent=2);f.write('\n')
print(json.dumps({k:summary[k] for k in ['complete','timingSamples','coldSamples','pureCorrectness','batchFeasibility']}))
