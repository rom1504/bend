"""Separate observed fixed-work gains on changed and identical loaded programs."""
import argparse, json, math, statistics
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('summary',type=Path);a=p.parse_args()
r=json.loads(a.summary.read_bytes());assert r['complete']
rows=[c for c in r['cases'] if c['ratioEligible']]
def measures(group):
    total={k:sum(c['fixedEquivalentMs'][k] for c in group)/1000 for k in ['baseline','candidate','c']}
    return dict(cases=len(group),seconds=total,saved=total['baseline']-total['candidate'],
        ratio=total['candidate']/total['baseline'] if total['baseline'] else None,
        geometric=statistics.geometric_mean(c['ratios']['candidate']['overBaseline'] for c in group) if group else None)
groups={k:[c for c in rows if r['identityControls'][c['id']]['loadedLayoutsIdentical']==flag] for k,flag in [('changed',False),('identical',True)]}
all_=measures(rows);by={k:measures(v) for k,v in groups.items()}
by['fixedAtBaselineOnIdentical']=(by['identical']['seconds']['baseline']+by['changed']['seconds']['candidate'])/all_['seconds']['c']
print(json.dumps(dict(total=all_,groups=by,observedOverC=all_['seconds']['candidate']/all_['seconds']['c'],baselineOverC=all_['seconds']['baseline']/all_['seconds']['c'],
    changed=[dict(id=c['id'],ratio=c['ratios']['candidate']['overBaseline'],overC=c['ratios']['candidate']['overC'],saved=(c['fixedEquivalentMs']['baseline']-c['fixedEquivalentMs']['candidate'])/1000) for c in groups['changed']],compilerCostSeconds=r['compilerCostSeconds']),indent=2))
