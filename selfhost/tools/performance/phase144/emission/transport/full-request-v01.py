"""Prepare or inspect one exact full-source runtime comparison; never run targets."""
import argparse,hashlib,json,shlex
from pathlib import Path
ROOT=Path(__file__).resolve().parents[6];HERE=Path(__file__).resolve().parent
BASE=ROOT/'selfhost/build/phase130/p144-final03-fixed-cold01/report.json'
BUILD=ROOT/'selfhost/build/phase144/small-transfer02/build.json'
FAST=ROOT/'selfhost/build/phase144/small-transfer-fast02/report.json'
REQUEST=ROOT/'selfhost/tools/performance/phase130/native-request.py'
def pin(p):
 p=Path(p).resolve();h=hashlib.sha256();n=0
 with p.open('rb') as f:
  for b in iter(lambda:f.read(1048576),b''):h.update(b);n+=len(b)
 return dict(file=str(p),bytes=n,sha256=h.hexdigest())
def verify(p):assert pin(p['file'])==p,p['file']
def read(p):return json.loads(Path(p).read_text())
p=argparse.ArgumentParser(description=__doc__);p.add_argument('action',choices=['prepare','inspect']);p.add_argument('--out',type=Path,required=True);p.add_argument('--plan',type=Path);a=p.parse_args();out=a.out.resolve();assert out.is_relative_to(ROOT/'selfhost/build/phase144') and not out.exists()
if a.action=='prepare':
 b=read(BUILD);f=read(FAST);old=read(BASE)
 assert b['complete'] and b['baselineObjectByteIdenticalToParent'] and all(x['exactExpected'] for x in b['jobs']) and f['complete']
 assert old['complete'] and old['byteExact'] and old['exitCode']==0 and not old['changedInputs']
 assert old['image']['sha256']==b['variants']['baseline']['binary']['sha256']=='22380e6ab9a2d565e89aa742d4082ad74493f293c3ccbcfb39b311c15647898e'
 assert old['product']['sha256']=='ac29be094a56cb5e5125b7982a083a15b8e2d5f8c3505b7c1e484c65675abd36'
 assert old['source']['sha256']=='15f5cada2710119cce19a0cfe961c21f61edc5f0b048f90359090a0c1817dac1'
 carrier=ROOT/'selfhost/build/phase130/base-carrier01/receipt.json';candidate=b['variants']['candidate'];requestOut=ROOT/'selfhost/build/phase130/p144-small-transfer-fixed142-01';assert not requestOut.exists()
 inputs=[pin(__file__),pin(BASE),pin(BUILD),pin(FAST),pin(REQUEST),pin(carrier),*old['inputs'],*b['inputs'],old['image'],old['source'],old['product'],*candidate.values()]
 for x in inputs:verify(x)
 command=['python3','-B',str(REQUEST),'--image',candidate['binary']['file'],'--source',old['source']['file'],'--carrier-receipt',str(carrier),'--out',str(requestOut),'--expected-qbe',old['product']['file'],'--seconds','600']
 guard=['python3','-B',str(ROOT/'selfhost/tools/performance/phase111/guard.py'),'--out',str(ROOT/'selfhost/build/phase144/small-transfer-full01-guard'),'--seconds','650','--cpu','3','--rss-mib','3072','--available-mib','16384','--file-mib','256','--',*command]
 result=dict(kind='phase144-small-transfer-full-request-plan',complete=True,targetsRun=False,inputs=inputs,baseline=pin(BASE),baselineSeconds=old['nativeSeconds'],compilerObject=b['compilerObject'],compilerBuild=b['inputs'][next(i for i,x in enumerate(b['inputs']) if x['file'].endswith('/p144-final03-n2/report.json'))],runtimeBuild=pin(BUILD),linkedRuntime=candidate['object'],image=candidate['binary'],source=old['source'],expectedQbe=old['product'],requestReport=str(requestOut/'report.json'),command=command,jobs=[dict(name='full-frozen142-exact-runtime-only',command=guard)],scope='One current final03 N2 object relinked with experimental same-ABI tiny-copy runtime. Exact frozenPhase142 source and final03 ac29QBE. Retained same-image serial baseline251.861s, not paired or a confidence interval. No acquisition/selection; native-request runtime field is future build context, linked runtime is bound here.')
 out.mkdir();(out/'plan.json').write_text(json.dumps(result,indent=2)+'\n');(out/'command.sh').write_text('#!/bin/sh\nset -eu\n'+shlex.join(guard)+'\n');print(json.dumps(dict(plan=pin(out/'plan.json'),command=pin(out/'command.sh'))))
else:
 assert a.plan;plan=read(a.plan);assert plan['complete'];r=read(plan['requestReport']);old=read(plan['baseline']['file'])
 assert r['complete'] and r['byteExact'] and r['exitCode']==0 and not r['changedInputs']
 assert r['image']==plan['image'] and r['source']==plan['source'] and r['expectedQbe']==plan['expectedQbe']
 assert (r['product']['bytes'],r['product']['sha256'])==(plan['expectedQbe']['bytes'],plan['expectedQbe']['sha256'])
 for x in plan['inputs']:verify(x)
 ratio=r['nativeSeconds']/old['nativeSeconds'];out.mkdir();result=dict(kind='phase144-small-transfer-full-request-result',complete=True,targetsRun=False,inputs=[pin(__file__),pin(a.plan),pin(plan['requestReport']),*plan['inputs']],sameCompilerObject=plan['compilerObject'],linkedRuntime=plan['linkedRuntime'],baselineSeconds=old['nativeSeconds'],candidateSeconds=r['nativeSeconds'],ratio=ratio,savedPercent=100*(1-ratio),candidatePeakRssKiB=r['peakRssKiB'],eligibleForFurtherQualification=ratio<=.98,scope='Exact full output passed. One retained baseline versus one later candidate;no statistical confidence or qualification/promotion implied.')
 (out/'report.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps({k:result[k] for k in ['complete','baselineSeconds','candidateSeconds','ratio','savedPercent','eligibleForFurtherQualification']}))
