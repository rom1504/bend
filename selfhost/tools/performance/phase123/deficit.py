"""Complement frozen geometric scores with positive log-slowdown; no benchmark changes."""
import argparse,hashlib,json,math,statistics
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4]
def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
p=argparse.ArgumentParser();p.add_argument('--summary',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args();assert not a.out.exists()
s=json.loads(a.summary.read_text());assert s['complete'] and len(s['screens'])==1
manifest=ROOT/'selfhost/tools/performance/phase112/benchmark45/manifest01.json';m=json.loads(manifest.read_text());family={x['name']:x['family'] for x in m['cases']}
rows=[x for x in s['screens'][0]['cases'] if x['ratioEligible']];assert len(rows)==44
result=dict(complete=True,inputs=[pin(__file__),pin(a.summary),pin(manifest)],cases=[],roles={})
for x in rows:
 ms=x['mediansMs'];result['cases'].append(dict(name=x['name'],family=family[x['name']],mediansMs=ms,**{role:dict(ratio=ms[role]/ms['upstream'],positiveLogSlowdown=max(0,math.log(ms[role]/ms['upstream'])),positiveExcessMs=max(0,ms[role]-ms['upstream'])) for role in ['baseline','candidate']}))
for role in ['baseline','candidate']:
 rs=result['cases'];groups={}
 for x in rs:groups.setdefault(x['family'],[]).append(x[role]['positiveLogSlowdown'])
 L=statistics.mean(x[role]['positiveLogSlowdown'] for x in rs);fl=statistics.mean(statistics.mean(xs) for xs in groups.values())
 result['roles'][role]=dict(meanPositiveLogSlowdown=L,expMeanPositiveLogSlowdown=math.exp(L),familyWeightedPositiveLogSlowdown=fl,expFamilyWeightedPositiveLogSlowdown=math.exp(fl),over1_1=sum(x[role]['ratio']>1.1 for x in rs),over2=sum(x[role]['ratio']>2 for x in rs),summedMedianMs=sum(x['mediansMs'][role] for x in rs),summedPositiveExcessMs=sum(x[role]['positiveExcessMs'] for x in rs),families=len(groups))
result['relativePositiveLogReduction']=1-result['roles']['candidate']['meanPositiveLogSlowdown']/result['roles']['baseline']['meanPositiveLogSlowdown']
result['largestRegressions']=sorted([dict(name=x['name'],candidateOverBaseline=x['candidateOverBaseline'],mediansMs=x['mediansMs']) for x in rows],key=lambda x:x['candidateOverBaseline'],reverse=True)[:10]
result['scope']='Same44 timed points and frozen family labels; unchanged zero-work sentinel retained by source summary but excluded from ratios. Natural logarithms. exp(L) is a deficit diagnostic, not a new measured geometric runtime ratio. Fast cases contribute zero rather than offsetting slow cases. Family labels need not imply independent algorithms. Fixed-batch sums are not prevalence estimates or compiler throughput.'
a.out.parent.mkdir(parents=True,exist_ok=True);a.out.write_text(json.dumps(result,indent=2)+'\n');print(json.dumps({k:result[k] for k in ['roles','relativePositiveLogReduction']},indent=2))
