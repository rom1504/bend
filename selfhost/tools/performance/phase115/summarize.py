"""Read exact receipts, recompute policy decisions, preserve scoped measurements."""
import hashlib,json,math,statistics,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4];HERE=Path(__file__).resolve().parent
pin=lambda p:dict(file=str(Path(p).resolve()),bytes=Path(p).stat().st_size,sha256=hashlib.sha256(Path(p).read_bytes()).hexdigest())
def read(p):return json.loads(Path(p).read_text())
def verify(r):assert pin(r['file'])==r,r['file']
def gm(xs):return math.exp(statistics.mean(math.log(x) for x in xs))
manifest=HERE/'manifest03.json';m=read(manifest);runtimePath=ROOT/'selfhost/build/phase112/p115-runtime01/report.json';runtime=read(runtimePath)
assert runtime['complete'] and runtime['executionComplete'] and runtime['fullCorpusOutputQualified'] and len(runtime['records'])==90
assert all(r['correct'] and r['qualified'] for r in runtime['records'])
for obs in runtime['records']:
 for key in ['stdout','stderr','binary']:verify(obs[key])
rows=[];receipts=[pin(manifest),pin(runtimePath),pin(__file__)]
for c in m['cases']:
 p=ROOT/'selfhost/build/phase115/matrix03'/c['name']/'report.json';r=read(p);assert r['complete'] and r['warmupExact'] and len(r['rows'])==27
 for item in r['inputs']:verify(item)
 for item in r['products'].values():verify(item)
 assert r['reference']['sha256']==r['products']['0']['sha256']
 receipts.append(pin(p));cost={e:[sum(x['seconds'] for x in r['rows'] if x['round']==i and x['engine']==e) for i in range(3)] for e in ['legacy','cached']}
 med={e:statistics.median(v) for e,v in cost.items()}
 policyCost={str(p):{e:statistics.median(x['seconds'] for x in r['rows'] if x.get('policy')==p and x['engine']==e) for e in ['legacy','cached']} for p in range(4)}
 runtimeMs={}
 for role in ['upstream','policy0','policy1','policy2','policy3']:
  samples=[x['elapsedMs'] for x in runtime['records'] if x['case']==c['name'] and x['role']==role];assert len(samples)==3
  runtimeMs[role]=dict(samples=samples,median=statistics.median(samples))
 rows.append(dict(name=c['name'],partition=c['partition'],fourPolicySeconds=cost,medianFourPolicySeconds=med,cachedOverLegacy=med['cached']/med['legacy'],policyEmissionSeconds=policyCost,planPreparationSeconds=[x['seconds'] for x in r['rows'] if x['kind']=='preparation'],sharedSetupStages=[v for v in r['stages'] if v['label'] in ['base-preparation','source-frontend','runtime-admission','lowering','independent-original-final-verifier','common-emission-context']],referenceEmissionStage=next(v for v in r['stages'] if v['label']=='original-emission'),routes=r['counts'],products=r['products'],runtimeMs=runtimeMs))
training=[r for r in rows if r['partition']=='training'];evaluation=[r for r in rows if r['partition']=='evaluation']
eligible=[p for p in range(4) if all(r['products'][str(p)]['sha256']==r['products']['0']['sha256'] for r in training)]
compileCosts={str(p):sum(r['policyEmissionSeconds'][str(p)]['legacy'] for r in training) for p in range(4)}
best=min(eligible,key=lambda p:compileCosts[str(p)]);selected=best if compileCosts[str(best)]<=.9*compileCosts['0'] else 0
runtimeRatios={str(p):gm([r['runtimeMs']['policy'+str(p)]['median']/r['runtimeMs']['policy0']['median'] for r in training]) for p in range(4)}
fast=min(range(4),key=lambda p:runtimeRatios[str(p)])
programSelected=fast if runtimeRatios[str(fast)]<=.97 and all(r['runtimeMs']['policy'+str(fast)]['median']<=1.03*r['runtimeMs']['policy0']['median'] for r in training) else 0
summary=dict(kind='phase115-results',complete=True,source=m['parent'],experimentalApi=m['api'],receipts=receipts,cases=rows,
 scope='Six historical cases, not broad/native compiler throughput. Four-policy timing includes fresh alternative preparation per sweep; output checks, setup, builds and runtime evaluation are separate costs.',
 capacity={part:dict(geomeanCachedOverLegacy=gm([r['cachedOverLegacy'] for r in subset]),sumLegacyMedianSeconds=sum(r['medianFourPolicySeconds']['legacy'] for r in subset),sumCachedMedianSeconds=sum(r['medianFourPolicySeconds']['cached'] for r in subset)) for part,subset in [('training',training),('evaluation',evaluation),('all',rows)]},
 compilationPolicy=dict(eligible=eligible,trainingCosts=compileCosts,selected=selected,trainingRatio=compileCosts[str(selected)]/compileCosts['0'],evaluationByteExact=all(r['products'][str(selected)]['sha256']==r['products']['0']['sha256'] for r in evaluation),evaluationRatio=sum(r['policyEmissionSeconds'][str(selected)]['legacy'] for r in evaluation)/sum(r['policyEmissionSeconds']['0']['legacy'] for r in evaluation)),
 programPolicy=dict(trainingRatios=runtimeRatios,selected=programSelected),recursiveFeedbackDemonstrated=False,installedSelectionChanged=False)
negativePath=ROOT/'selfhost/build/phase115/negative-replay01/report.json'
if negativePath.exists():
 neg=read(negativePath);assert neg['complete']
 for item in neg['inputs']:verify(item)
 summary['receipts'].append(pin(negativePath));out=[]
 for r in neg['cases']:
  assert r['complete'] and len(r['samples'])==10 and all(s['outputExact'] for s in r['samples'])
  med={e:statistics.median(s['seconds'] for s in r['samples'] if s['engine']==e) for e in ['original','candidate']}
  out.append(dict(name=r['name'],medians=med,ratio=med['candidate']/med['original'],samples=r['samples'],setupSeconds=r['frontendLoweringVerifySeconds']))
 summary['negativeDecision']=dict(cases=out,geomeanRatio=gm([r['ratio'] for r in out]),sumOriginalMedianSeconds=sum(r['medians']['original'] for r in out),sumCandidateMedianSeconds=sum(r['medians']['candidate'] for r in out),composition=read(ROOT/'selfhost/build/phase115/negative-source01/manifest.json'),scope='Full warm emission only; no whole-request or native throughput claim.')
# Recorded guards only; wall outside them is unattributed, not agent quota.
guards=[]
for p in sorted((ROOT/'selfhost/build/phase115').glob('*-guard/process.json')):
 r=read(p);guards.append(dict(receipt=pin(p),seconds=r['wallSeconds'],complete=r['complete'],peakTreeRssBytes=r['peakTreeRssBytes']))
summary['runtimeReuse']='matrix03 requires exact equality of every complete policy product to matrix02; reuse the independently built/executed identical products, without repeating machine builds.'
summary['guards']=guards;summary['recordedGuardSeconds']=sum(g['seconds'] for g in guards)
out=ROOT/'implementation/phase115/results.json';assert not out.exists();out.parent.mkdir(exist_ok=True);out.write_text(json.dumps(summary,indent=2)+'\n')
print(json.dumps({k:summary[k] for k in ['capacity','compilationPolicy','programPolicy','recordedGuardSeconds']},indent=2))
if 'negativeDecision' in summary:print('negative full emission ratio',summary['negativeDecision']['geomeanRatio'])
