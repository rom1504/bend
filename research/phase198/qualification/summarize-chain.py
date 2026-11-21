#!/usr/bin/env python3
"""Authenticate a frozen composed source's completed native qualification."""
import argparse
import hashlib
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
BUILD=ROOT/'selfhost/build/phase198'
def pin(path):
 p=Path(path).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def read(path):return json.loads(Path(path).read_text())
def closed(stem):
 gp=BUILD/(stem+'-guard')/'process.json';g=read(gp)
 assert g['complete'] and g['returncode']==0 and g['minimumDiskFreeBytes']>=g['diskReserveBytes'],stem
 cp=ROOT/'selfhost/build-retention/phase198'/(stem+'-close')/'report.json';assert read(cp)['complete'],stem
 return dict(guard=pin(gp),retentionClose=pin(cp))
def verify(p):
 q=pin(p['file']);assert all(q[k]==p[k] for k in ['bytes','sha256']),p['file'];return q
p=argparse.ArgumentParser();p.add_argument('--prefix',required=True);p.add_argument('--out',required=True);p.add_argument('--require-native-heldout',action='store_true');p.add_argument('--require-live-equivalence',action='store_true');a=p.parse_args()
assert a.prefix.replace('-','').isalnum()
out=Path(a.out);assert not out.exists()
planpath=BUILD/(a.prefix+'-argv01')/'plan.json';plan=read(planpath)
assert plan['complete'] and plan['prefix']==a.prefix
for k in ['method','templates','selectedSource','manifest','audit','sourceCheck']:verify(plan[k])
source=plan['selectedSource'];check=read(plan['sourceCheck']['file'])
assert check['complete'] and check['checked'] and check['typeAccepted'] and check['unresolvedHoles']==0
assert not check.get('changedInputs')
for row in check.get('inputs',[]):verify(row)
assert any(row.get('sha256')==source['sha256'] and row.get('bytes')==source['bytes'] for row in check['loadedSources'])
for row in plan['argv']:verify(row)
evidence=plan['sourceEvidence']
for k in ['checkedAPIs','inputs']:
 for row in evidence.get(k,[]):verify(row)
names=['native-image01','native-self01','native-reproduction01','native45-01','native45-02','native-generations-compare01','native64-01','runtime10-01']
docs={};gates=[]
for name in names:
 stem=a.prefix+'-'+name;path=BUILD/stem/'report.json';d=read(path);docs[name]=d
 assert d['complete'] and not d.get('error') and not d.get('changedInputs'),stem
 assert d.get('passed',True),stem
 for row in d.get('inputs',[]):verify(row)
 gp=BUILD/(stem+'-guard')/'process.json';g=read(gp)
 assert g['complete'] and g['returncode']==0 and g['minimumDiskFreeBytes']>=g['diskReserveBytes'],stem
 close=ROOT/'selfhost/build-retention/phase198'/(stem+'-close')/'report.json';assert read(close)['complete'],stem
 gates.append(dict(name=stem,report=pin(path),guard=pin(gp),retentionClose=pin(close),seconds=d.get('wallSeconds',d.get('seconds'))))
for name in ['native-image01','native-self01','native-reproduction01']:
 assert docs[name]['imageBinding']['sourceIdentity']==source,name
obj2=pin(BUILD/(a.prefix+'-native-self01')/'program.o');obj3=pin(BUILD/(a.prefix+'-native-reproduction01')/'program.o')
assert obj2['bytes']==obj3['bytes'] and obj2['sha256']==obj3['sha256']
assert docs['native-reproduction01']['expectedObject']==obj2
for name in ['native45-01','native45-02']:
 assert len(docs[name]['rows'])==45 and all(r['complete'] for r in docs[name]['rows'])
c=docs['native-generations-compare01'];assert c['objectsIdentical']==45 and c['linkedSectionsIdentical']==135
assert docs['native64-01']['counts']=={'pass':64,'fail':0,'unsupported':0}
assert len(docs['runtime10-01']['rows'])==10 and all(r['complete'] for r in docs['runtime10-01']['rows'])
r=dict(kind='phase198-composed-native-qualification-summary',complete=True,method=pin(__file__),plan=pin(planpath),selectedSource=source,sourceCheck=plan['sourceCheck'],sourceEvidence=evidence,gates=gates,compilerObjectN2EqualsN3=True,compilerObject=obj2,native45GenerationCounts=[45,45],native45ExactObjects=45,native45ExactLinkedSections=135,native64Counts=docs['native64-01']['counts'],runtimeControlsPassed=10,scope='Finite sequential AMD64 SysV correctness, exact N2/N3 compiler reproduction and cross-generation program objects/sections. Performance and promotion are separate evidence.')
livepath=BUILD/(a.prefix+'-live-gates01')/'report.json'
if livepath.exists():
 live=read(livepath);assert live['complete'] and len(live['rows'])==71 and len(live['refusals'])==3
 for k in ['image','conformance','runtimeControl','live','approvedRuntime','method']:verify(live[k])
 for row in live['rows']:
  for k in ['source','object','reference','exe']:verify(row[k])
 guard=BUILD/(a.prefix+'-live-gates01-guard')/'process.json';g=read(guard);assert g['complete'] and g['returncode']==0
 r['liveRuntimeBoundary']=dict(report=pin(livepath),guard=pin(guard),executedObjects=71,originalAdmissionRefusals=3)
if a.require_native_heldout:
 hp=BUILD/(a.prefix+'-native-heldout01')/'report.json';h=read(hp)
 assert h['complete'] and h['nativeObjectsExact']==2 and h['independentCPoints']==12 and h['countChecks']==2
 for k in ['method','image','imageReceipt','trial','plan']:verify(h[k])
 assert h['image']==pin(BUILD/(a.prefix+'-native-self01')/'program')
 for row in h['rows']:
  assert row['complete'] and row['objectBytesExact']
  for k in ['source','expectedObject','object','binary','buildReceipt','buildStdout','buildStderr','cOracle','cSource']:verify(row[k])
 r['authoredNativeHeldout']=dict(**closed(a.prefix+'-native-heldout01'),report=pin(hp),exactCheckedApiObjects=2,independentCPoints=12,countChecks=2)
if a.require_live_equivalence:
 ep=BUILD/(a.prefix+'-compare-live01')/'report.json';e=read(ep)
 assert e['complete'] and not e.get('changedInputs') and e['objectsIdentical']==45 and e['liveAllocatedLayoutsIdentical']==45
 assert e['compilerSources'][1]==source
 for role in ['candidate','live']:
  assert e['mappedImageDiagnostics'][role]['programHeadersIdentical']==45 and e['mappedImageDiagnostics'][role]['normalizedLoadFileBytesIdentical']==45,role
 for row in e['inputs']:verify(row)
 r['measuredMachineEquivalence']=dict(**closed(a.prefix+'-compare-live01'),report=pin(ep),measuredSummary=e['measuredSummary'],measuredReport=e['measuredReport'],ordinaryComparison=e['ordinaryComparison'],scope='Timing observations belong to the measured orbit source. The corrected source has separately proven byte-identical45 objects and equivalent allocated executable images under both runtimes; no new45 performance samples were taken.')
out.write_text(json.dumps(r,indent=2)+'\n');print(json.dumps(pin(out)))
