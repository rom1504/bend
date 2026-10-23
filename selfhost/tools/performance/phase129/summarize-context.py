"""Pool authenticated current-compiler dispatch contexts without rerunning targets.

Keep active dispatch separate from physical leaves and source-call ancestry.
The generic profiler's loss/coverage gates decide which captures are included.
"""
import argparse
from collections import Counter
import json
from pathlib import Path
import sys

ROOT=Path(__file__).resolve().parents[4]
sys.path.insert(0,str(ROOT/'selfhost/tools/profiler'))
from run import pin, save, verify
from compare import capture_reasons
from attribute import attribute, attribute_events

p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--capture',type=Path,required=True)
p.add_argument('--out',type=Path,required=True)
a=p.parse_args();out=a.out.resolve();assert not out.exists()
out.mkdir(parents=True)
owners=a.capture/'owners.json'
result=dict(complete=False,targetsRun=False,inputs=[pin(__file__),pin(owners)],workloads=[],
    scope='Period-weighted active lowered-owner contexts. Conditional emitter grouping, exact linked FID binding. Private calls retain outer context; no inclusive call graph or causal speedup claim. Counter instrumentation changes runtime; inline operations may bypass hooks.')
for directory in sorted(a.capture.iterdir()):
    receipt=directory/'report.json'
    if not receipt.is_file() or directory.name=='build':continue
    run=json.loads(receipt.read_text())
    if run.get('schema')!='bend-native-profile-run-v1':continue
    assert run['complete'] and run['passed']
    result['inputs'].append(pin(receipt))
    counts,weights,leaves=Counter(),Counter(),Counter()
    accepted=[];rejected=[];events=[];total=0;weighted=0
    for row in run['rows']:
        if row['mode']=='sample':
            analysis_path=verify(row['analysis']);analysis=json.loads(analysis_path.read_text())
            reasons=capture_reasons(analysis)
            if reasons:
                rejected.append(dict(analysis=row['analysis'],reasons=reasons));continue
            context=verify(row['contexts'])
            report,_=attribute(analysis_path,None,None,context,owners)
            assert report['pairing']['verified'] and report['pairing']['correct']
            period=analysis['header']['period_us'];n=analysis['header']['samples']
            assert sum(c['samples'] for c in report['dispatchContexts'])==n
            total+=n;weighted+=n*period
            for c in report['dispatchContexts']:
                name=c['loweredOwner'] or '[unknown]'
                counts[name]+=c['samples'];weights[name]+=c['samples']*period
            for c in report['contextLeafMatrix']:
                leaves[(c['dispatchLoweredOwner'] or '[unknown]',c['leafSymbol'] or '[unknown]')]+=c['samples']*period
            target=out/f'{directory.name}-{row["round"]:02d}.json';save(target,report)
            accepted.append(dict(report=pin(target),periodUs=period,samples=n))
        elif row['mode']=='events':
            event_path=verify(row['events'])
            report=attribute_events(event_path,Path(row['command'][0]),owners)
            target=out/f'{directory.name}-events.json';save(target,report);events.append(pin(target))
    result['workloads'].append(dict(name=directory.name,acceptedSamples=total,
        adequatePooledSamples=total>=500,accepted=accepted,rejected=rejected,events=events,
        contexts=[dict(owner=k,samples=counts[k],periodWeightedFraction=v/weighted)
                  for k,v in weights.most_common()],
        contextLeafMatrix=[dict(owner=k[0],leaf=k[1],periodWeightedFraction=v/weighted)
                           for k,v in leaves.most_common()]))
result['complete']=True;save(out/'report.json',result)
print(json.dumps(dict(complete=True,workloads=[dict(name=w['name'],samples=w['acceptedSamples'],top=w['contexts'][:12]) for w in result['workloads']])))
