#!/usr/bin/env python3
"""Summarize completed same-producer packaging receipts; never launch jobs."""
import argparse,hashlib,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5]
def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--plan',type=Path,required=True);ap.add_argument('--out',type=Path,required=True);a=ap.parse_args()
 out=a.out.resolve();assert not out.exists()and out.is_relative_to(ROOT/'selfhost/build/phase144')
 plan=json.loads(a.plan.read_text());assert plan['complete'];inputs=[pin(__file__),pin(a.plan)]
 def read(p):
  p=Path(p);r=json.loads(p.read_text());assert r['complete'];inputs.append(pin(p));return r
 for row in plan['inputs']:assert pin(row['file'])==row
 baseline=read(plan['baselineRequest']['file']);candidate=read(plan['profileRequestFuture']);build=read(plan['profileMachineFuture']);api=read(plan['profileApiFuture'])
 assert api['checked']and plan['profile']in api['inputs']
 assert baseline['source']==plan['parent']and candidate['source']==plan['profile']
 assert baseline['image']==candidate['image']==plan['producer']
 assert baseline['inheritedAffinity']==candidate['inheritedAffinity']==[3]
 for field in ['base','carrier','stamp']:assert baseline[field]==candidate[field]
 assert candidate['exitCode']==baseline['exitCode']==0
 assert candidate['product']in build['inputs']and plan['runtime']in build['inputs']
 assert pin(candidate['product']['file'])==candidate['product']and pin(build['binary']['file'])==build['binary']
 smokes=[]
 for case in plan['cases']:
  hosted=read(ROOT/'selfhost/build/phase144'/('native-profile03-hosted-'+case['name'])/'report.json')
  native=read(ROOT/'selfhost/build/phase130'/('p144-native-profile03-'+case['name'])/'report.json')
  assert hosted['compilerSource']==plan['profile']and native['image']==build['binary']
  assert native['source']==case['source']and native['byteExact']
  assert (hosted['product']['bytes'],hosted['product']['sha256'])==(case['qbe']['bytes'],case['qbe']['sha256'])==(native['product']['bytes'],native['product']['sha256'])
  smokes.append(dict(name=case['name'],currentApiProductExact=True,nativeProductExact=True))
 nativeRatio=candidate['nativeSeconds']/baseline['nativeSeconds']
 r=dict(kind='phase144-same-producer-source-packaging-result',complete=True,selected=False,inputs=inputs,
  profile=plan['profile'],parent=plan['parent'],producer=plan['producer'],runtime=plan['runtime'],
  nativeSeconds=dict(full=baseline['nativeSeconds'],profile=candidate['nativeSeconds'],ratio=nativeRatio,reduction=1-nativeRatio),
  sourceBytesRatio=plan['profile']['bytes']/plan['parent']['bytes'],
  qbeBytes=dict(full=baseline['product']['bytes'],profile=candidate['product']['bytes']),
  profileMachineSeconds=build['buildSeconds'],smokes=smokes,
  measurementScope='One retained full-source request and one later reduced-source request, same exact compiler executable/Base/carrier/CPU affinity. Different compiler-source input measures packaging/workflow cost, not same-source algorithm speed. OS caches unflushed; not randomized pairs.',
  qualificationScope='Independent source check and3complete ordinary hosted/native products. All native CLI source entries retained; no profile bootstrap fixed point, incremental/provider rerun, full conformance or default promotion.')
 p=Path(plan['baselineMachineFuture'])
 if p.exists():
  b=read(p);assert baseline['product']in b['inputs']and plan['runtime']in b['inputs']
  full=baseline['nativeSeconds']+b['buildSeconds'];profile=candidate['nativeSeconds']+build['buildSeconds']
  r['sequentialWorkflowEstimate']=dict(full=full,profile=profile,ratio=profile/full,baselineMachineSeconds=b['buildSeconds'],scope='Sum of separately supervised complete compiler child request and QBE/as/link jobs; excludes outer orchestration and validation, not overlapped build wall time.')
 else:r['sequentialWorkflowEstimate']=None
 out.mkdir();(out/'report.json').write_text(json.dumps(r,indent=2)+'\n');print(json.dumps(r['nativeSeconds']))
if __name__=='__main__':main()
