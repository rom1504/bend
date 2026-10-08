#!/usr/bin/env python3
"""Compare separate native recipes only after matching methods and exact workloads."""
import argparse, hashlib, json, math, statistics
from pathlib import Path
def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(path=str(p),sha256=hashlib.sha256(b).hexdigest(),bytes=len(b))
def read(p):return json.loads(Path(p).read_text())
def load(acq,timing):
 a,t=read(acq),read(timing);assert a['complete'] and t['complete'];assert a['recipe']==t['recipe'];assert pin(a['recipe']['path'])==a['recipe'];r=read(a['recipe']['path'])
 assert t['kind']=='phase67-native-measure';assert pin(t['plan']['path'])==t['plan']
 products={}
 for item in a['records']:
  key=(item['case'],item['role']);assert key not in products and item['correct'];products[key]=item
  for field in ['source','nativeSource','executable','emissionReceipt']:assert pin(item[field]['path'])==item[field]
 samples={}
 for item in t['records']:
  assert item['correct'] and item['validClock'] and item['timingQualified'];samples.setdefault((item['case'],item['role']),[]).append(item)
 return a,t,r,products,samples
def gm(xs):return math.exp(sum(map(math.log,xs))/len(xs))
p=argparse.ArgumentParser();p.add_argument('--baseline-acquired',required=True,type=Path);p.add_argument('--baseline-timing',required=True,type=Path);p.add_argument('--candidate-acquired',required=True,type=Path);p.add_argument('--candidate-timing',required=True,type=Path);p.add_argument('--out',required=True,type=Path);args=p.parse_args()
a,b,ra,pa,sa=load(args.baseline_acquired,args.baseline_timing);c,d,rc,pc,sc=load(args.candidate_acquired,args.candidate_timing)
for field in ['node','clang','nodeArgs','clangArgs','linkArgs','cpu','treeRssMiB','availableMiB','compilerEnvironment','upstreamCommit']:assert ra[field]==rc[field],field
sharedA={i['path']:i for i in ra['inputs']};sharedC={i['path']:i for i in rc['inputs']};changed=[path for path in sharedA.keys()&sharedC.keys() if sharedA[path]!=sharedC[path]];assert not changed,changed
assert b['plan']==d['plan'],'Use the same fixed plan for this ablation'
cases=sorted(case for case,role in sc if role=='selfhost');assert set(cases)<={case for case,role in sa if role=='selfhost'}
rows=[]
for case in cases:
 key=(case,'selfhost');old,new=pa[key],pc[key];assert old['source']==new['source'];left,right=sa[key],sc[key]
 protocol=lambda rows:{(r['repetitions'],r['warmups'],tuple(r['expected']))for r in rows}
 assert protocol(left)==protocol(right) and len(protocol(left))==1
 med=lambda rows:statistics.median(r['elapsedMs']/r['repetitions']*1000 for r in rows)
 oldTime,newTime=med(left),med(right);ratio=newTime/oldTime
 row=dict(case=case,baselineMicroseconds=oldTime,candidateMicroseconds=newTime,candidateOverBaselineRuntime=ratio,runtimeReductionPercent=(1-ratio)*100,speedup=1/ratio,baselineRounds=len(left),candidateRounds=len(right),baselineClangSeconds=old['toolchain']['wallSeconds'],candidateClangSeconds=new['toolchain']['wallSeconds'],candidateOverBaselineClang=new['toolchain']['wallSeconds']/old['toolchain']['wallSeconds'],baselineCBytes=old['nativeSource']['bytes'],candidateCBytes=new['nativeSource']['bytes'],candidateOverBaselineCBytes=new['nativeSource']['bytes']/old['nativeSource']['bytes'])
 if(case,'upstream')in sa:row['candidateOverEarlierUpstreamRuntime']=newTime/med(sa[(case,'upstream')])
 rows.append(row)
result=dict(kind='phase67-native-ablation-comparison-v1',complete=True,producer=pin(__file__),inputs=[pin(f)for f in [args.baseline_acquired,args.baseline_timing,args.candidate_acquired,args.candidate_timing]],baselineRecipe=a['recipe'],candidateRecipe=c['recipe'],plan=b['plan'],sharedMethodInputs=len(sharedA.keys()&sharedC.keys()),changedSharedInputs=changed,rows=rows,geomeanCandidateOverBaselineRuntime=gm([r['candidateOverBaselineRuntime']for r in rows]),geomeanCandidateOverBaselineClang=gm([r['candidateOverBaselineClang']for r in rows]),geomeanCandidateOverBaselineCBytes=gm([r['candidateOverBaselineCBytes']for r in rows]),scope='Separate sequential campaigns with exact same wrapper/plan/method/toolchain, not temporally interleaved baseline/candidate samples. Earlier TS projection is contextual; reacquire/reexecute TS for final paired confirmation. Runtime intervals all>=100ms; C builds single acquisition per product.')
args.out.parent.mkdir(parents=True,exist_ok=True)
with args.out.open('x')as f:json.dump(result,f,indent=2);f.write('\n')
print(json.dumps({'output':pin(args.out),'runtimeRatio':result['geomeanCandidateOverBaselineRuntime'],'buildRatio':result['geomeanCandidateOverBaselineClang'],'sizeRatio':result['geomeanCandidateOverBaselineCBytes'],'rows':rows}))
