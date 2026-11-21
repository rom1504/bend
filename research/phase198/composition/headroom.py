"""Per-family parity ceilings using measured times. Budgets are not performance predictions."""
import argparse
import itertools
import json
import math
from pathlib import Path
from statistics import geometric_mean

def calculate(path, role):
    r=json.loads(path.read_bytes());assert r['complete'] and {'c',role}<=r['roles'].keys()
    cases=[c for c in r['cases'] if c['summary']['ratioEligible']]
    assert len(cases)==44
    rows={}
    for c in cases:
        a=c['summary']['stats'][role]['medianMs'];b=c['summary']['stats']['c']['medianMs']
        g=rows.setdefault(c['family'],{'programs':[],'positiveLog':0,'positiveExcessMs':0,'fixedCostMs':0,'referenceMs':0})
        reps=c['point']['repetitions']
        g['programs'].append({'id':c['id'],'ratio':a/b})
        g['positiveLog']+=max(0,math.log(a/b));g['positiveExcessMs']+=reps*max(0,a-b)
        g['fixedCostMs']+=reps*a;g['referenceMs']+=reps*b
    ratio=geometric_mean(p['ratio'] for g in rows.values() for p in g['programs'])
    total_positive=sum(g['positiveLog'] for g in rows.values())
    total_excess=sum(g['positiveExcessMs'] for g in rows.values())
    batch=sum(g['fixedCostMs'] for g in rows.values());ref=sum(g['referenceMs'] for g in rows.values())
    for g in rows.values():
        g['ifEverySlowMemberReachedC']=ratio*math.exp(-g['positiveLog']/len(cases))
        g['shareOfRemainingPositiveLog']=g['positiveLog']/total_positive
        g['shareOfPositiveBatchExcess']=g['positiveExcessMs']/total_excess
    ranked=sorted(rows,key=lambda f:-rows[f]['positiveLog'])
    fixed=sorted(rows,key=lambda f:-rows[f]['positiveExcessMs'])
    def curve(rank):
        all_rows=[]
        for i in range(len(rank)+1):
            names=rank[:i]
            new=ratio*math.exp(-sum(rows[n]['positiveLog'] for n in names)/len(cases))
            wall=(batch-sum(rows[n]['positiveExcessMs'] for n in names))/ref
            all_rows.append({'families':names,'geomean':new,'fixedBatchRatio':wall})
        return all_rows
    return {'role':role,'baseline':ratio,'fixedBatchRatio':batch/ref,'source':str(path),
            'assumption':'Counterfactual upper bound. Bring only the above-C members of each chosen family down to the C reference and preserve every other measured runtime and already-fast result. Assumes independent costs; provides no implementation forecast.',
            'families':rows,'logDeficitOrder':curve(ranked),'fixedExcessOrder':curve(fixed)}
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('receipt',type=Path);p.add_argument('out',type=Path);p.add_argument('--role',default='live')
    a=p.parse_args();a.out.write_text(json.dumps(calculate(a.receipt,a.role),indent=2)+'\n')
