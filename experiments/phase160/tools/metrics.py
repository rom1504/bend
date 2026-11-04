#!/usr/bin/env python3
"""Summarize completed whole-request evidence without mixing failed timings."""
import json,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
sys.path.insert(0,str(ROOT/'selfhost/tools/build'))
from common import pin,verify,same_bytes,require,write_json
OUT=ROOT/'implementation/phase160';OUT.mkdir(exist_ok=True)
B=ROOT/'selfhost/build/phase160'
inputs=[]
def read(name):
 p=B/name/'report.json';inputs.append(pin(p));return json.loads(p.read_text())
own=[]
for name in ['current-self01','current-self-checked01','capped-self01','capped-self-checked01']:
 d=read(name);require(d['complete'] and d['exactOutput'],'Unqualified self output')
 verify(d['expectedProduct']);require(same_bytes(B/name/'stdout',Path(d['expectedProduct']['file'])),'Self bytes changed')
 own.append(dict(run=name,mode=d['mode'],seconds=d['process']['seconds'],peakRssKiB=d['process']['peakRssKiB'],output=d['expectedProduct']))
requests={}
for name in ['map02','checker01','full-c01','full-qbe01']:
 d=read(name);require(d['complete'],'Incomplete comparison')
 for row in d['rows']:
  require(row['passed'] and row['byteExact'],'Failed oracle')
  require(same_bytes(verify(row['product']),verify(row['deduplicatedAgainst'])),'Changed output')
  p=row['process'];requests.setdefault(d['case'],{})[row['role']]=dict(run=name,seconds=p['wallSeconds'],cpuSeconds=p['cpuSeconds'],peakRssKiB=p['peakRssKiB'],product=row['product'])
for case,row in requests.items():
 row['speedup']=row['qbe']['seconds']/row['c']['seconds']
 row['timeReduction']=1-row['c']['seconds']/row['qbe']['seconds']
 row['rssRatio']=row['c']['peakRssKiB']/row['qbe']['peakRssKiB']
d=read('full-factor01');require(d['complete'] and d['environment']=={'BEND_GC_FACTOR':'1'},'Wrong cadence experiment')
row=d['rows'][0];require(row['passed'] and row['byteExact'] and row['role']=='c','Bad policy output')
require(same_bytes(verify(row['product']),verify(row['deduplicatedAgainst'])),'Changed policy output')
p=row['process'];baseline=requests['full-compiler']
factor=dict(run='full-factor01',seconds=p['wallSeconds'],cpuSeconds=p['cpuSeconds'],peakRssKiB=p['peakRssKiB'],
 product=row['product'],environment=d['environment'],timeReductionVersusDefaultC=1-p['wallSeconds']/baseline['c']['seconds'],
 speedupVersusQbe=baseline['qbe']['seconds']/p['wallSeconds'],timeReductionVersusQbe=1-p['wallSeconds']/baseline['qbe']['seconds'],
 rssRatioVersusDefaultC=p['peakRssKiB']/baseline['c']['peakRssKiB'])
failures=[]
for name in ['emit01','unchecked01','map01']:
 d=read(name);failures.append(dict(run=name,complete=d['complete'],process=d.get('process'),rows=d.get('rows'),scope='Rejected/timeout; never a successful timing'))
write_json(OUT/'metrics.json',dict(kind='phase160-complete-request-measurements',complete=True,
 method=pin(__file__),ownSelfEmission=own,requests=requests,collectionBudgetAblation=factor,failures=failures,inputs=inputs,
 limitations=['One fresh observation per role/case; no repeated-median confidence claim.',
 'Image acquisition is separate. Requests include live Base, checking, complete optimization/verification, output and teardown; machine construction excluded.',
 'Same source semantics via checked original and exact spanless parse bridge; C and QBE source bytes differ only at audited whitespace sites.',
 'Cross-backend result bundles generated code, representation, runtime and Clang/QBE policies; not attribution to one mechanism.',
 'Private bounded-search GC, BEND_NO_FREE=1 and BEND_UNBOX=0 acquisition are not default bendc or production qualification.',
 'Own bendc self emission is a different implementation/input/output and cannot serve as an apples-to-apples speed ratio.']))
print(json.dumps({k:{x:r[x] for x in ['speedup','timeReduction','rssRatio']} for k,r in requests.items()}))
