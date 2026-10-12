#!/usr/bin/env python3
"""Data-only exact-C factorial medians, paired-round ratios and interaction."""
import argparse,hashlib,json,math,statistics
from pathlib import Path

def pin(p):
 p=Path(p).resolve(strict=True);b=p.read_bytes();return dict(file=str(p),sha256=hashlib.sha256(b).hexdigest(),bytes=len(b))
def gm(values):return math.exp(statistics.mean(math.log(v) for v in values))
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--plan',required=True,type=Path);p.add_argument('--out',required=True,type=Path);a=p.parse_args();assert not a.out.exists()
planpin=pin(a.plan);plan=json.loads(a.plan.read_text());assert plan['diagnosticOnly'] and not plan['shippingCandidate']
for item in plan['inputs']:assert pin(item['file'])==item,item['file']
rows=[]
for job in plan['jobs']:
 path=a.plan.parent/'runs'/job['name']/'report.json';r=json.loads(path.read_text());g=path.parent.with_name(path.parent.name+'-guard')/'process.json';guard=json.loads(g.read_text())
 assert r['complete'] and r['pass'] and r['inputsUnchanged'] and r['plan']==planpin and r['job']==job
 assert guard['complete'] and guard['returncode']==0
 if job['action']=='request':
  assert r['exactC'] and pin(r['output']['file'])['sha256']==pin(r['oracle']['file'])['sha256']
 rows.append(dict(job=job,report=pin(path),guard=pin(g),timings=r['timings'],guardWallSeconds=guard['wallSeconds'],peakRssBytes=guard['peakTreeRssBytes']))
assert len(rows)==40
stages=[]
for stage in ['b1','b2']:
 arms={}
 for arm in ['current','occurrence-off','ordinary-skip','both']:
  rs=sorted([r for r in rows if r['job'].get('stage')==stage and r['job'].get('arm')==arm],key=lambda r:r['job']['round'])
  assert len(rs)==4 and sorted(r['job']['position'] for r in rs)==list(range(4))
  values=[r['timings']['requestMs'] for r in rs];arms[arm]=dict(requestMs=values,medianMs=statistics.median(values),positions=[r['job']['position'] for r in rs],minimumMs=min(values),maximumMs=max(values))
 def contrast(numerator,denominator):
  left,right=arms[numerator],arms[denominator];paired=[x/y for x,y in zip(left['requestMs'],right['requestMs'])]
  return dict(numerator=numerator,denominator=denominator,medianRatio=left['medianMs']/right['medianMs'],pairedRoundRatios=paired,geomeanPairedRatio=gm(paired),numeratorFasterRounds=sum(x<1 for x in paired))
 contrasts=dict(occurrenceOnWithObserver=contrast('current','occurrence-off'),occurrenceOnWithSkip=contrast('ordinary-skip','both'),
  skipWithOccurrence=contrast('ordinary-skip','current'),skipWithoutOccurrence=contrast('both','occurrence-off'))
 interaction=[(arms['ordinary-skip']['requestMs'][i]/arms['current']['requestMs'][i])/(arms['both']['requestMs'][i]/arms['occurrence-off']['requestMs'][i]) for i in range(4)]
 stages.append(dict(stage=stage,arms=arms,contrasts=contrasts,skipRatioInteractionByRound=interaction,geomeanSkipInteraction=gm(interaction)))
result=dict(kind='phase70-native-compiler-factorial-analysis',complete=True,dataOnly=True,targetsExecuted=False,diagnosticOnly=True,shippingCandidate=False,
 plan=planpin,producer=pin(__file__),preparations=8,cleanRequests=32,allExactC=True,stages=stages,
 preparationGuardSeconds=sum(r['guardWallSeconds'] for r in rows if r['job']['action']=='prepare'),cleanGuardSeconds=sum(r['guardWallSeconds'] for r in rows if r['job']['action']=='request'),
 peakRssBytes=max(r['peakRssBytes'] for r in rows),observations=rows,
 scope='All32 requests retained; complete four-position rotation perstage. Pure generated-image diagnostic, not checked-source release or a corpus-wide result. Ratios below1 favor numerator. Paired rounds expose noise and factorial interaction; source implementation/qualification is separate.')
with a.out.open('x') as f:f.write(json.dumps(result,indent=2)+'\n')
print(json.dumps(dict(output=pin(a.out),stages=stages)))
