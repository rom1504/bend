#!/usr/bin/env python3
"""Summarize diagnostic exclusive clocks and actual admitted compiler paths."""
import argparse
import hashlib
import json
from pathlib import Path


def identity(file):
    file=Path(file).resolve(strict=True)
    return dict(file=str(file),sha256=hashlib.sha256(file.read_bytes()).hexdigest())


def read(file):return json.loads(Path(file).read_text())


p=argparse.ArgumentParser(description=__doc__)
p.add_argument('report',type=Path);p.add_argument('--out',type=Path,required=True)
a=p.parse_args();assert not a.out.exists()
report=read(a.report)
assert report['complete'] and report['pass'] and report['mode']=='stages' and not report['failures']
assert report['successfulWorkers']==report['expectedWorkers']
rows=[]
for worker in report['rows']:
    assert worker['success']
    observation=worker['observation'];stages=observation['stages']
    assert observation['cleanTiming'] is False and stages['incomplete']==0
    assert abs(stages['rootMs']-stages['exclusiveMs'])<1e-5
    events={x['id']:x for x in stages['events']}
    compile_event=next(x for x in events.values() if x['name']=='worker.compile')
    def within(event,parent):
        while event['id']!=parent['id'] and event['parent'] is not None:event=events[event['parent']]
        return event['id']==parent['id']
    relevant=[x for x in events.values() if within(x,compile_event)]
    names={}
    for event in relevant:
        row=names.setdefault(event['name'],dict(name=event['name'],calls=0,exclusiveMs=0,inclusiveMs=0))
        row['calls']+=1;row['exclusiveMs']+=event['exclusiveMs'];row['inclusiveMs']+=event['inclusiveMs']
    assert abs(sum(x['exclusiveMs'] for x in names.values())-compile_event['inclusiveMs'])<1e-5
    probes=['api.f-prefix-complete-ready-seed','api.f-prefix-complete-seed','api.f-prefix-complete-source',
        'api.f-prefix-graph-trace','api.check-program-diagnostic-world','api.check-program-diagnostic-prefix',
        'api.jd-plan-selected','api.jd-plan-library','api.jd-reach-selected','api.jd-library-selected',
        'api.book-context-world','api.book-context']
    active={name:names.get(name,dict(calls=0))['calls'] for name in probes}
    abi={phase:sum(row['exclusiveMs'] for name,row in names.items() if name.startswith('abi.') and name.endswith('.'+phase))
        for phase in ['encode','invoke','decode']}
    rows.append(dict(case=worker['case'],role=worker['role'],sample=worker['sample'],
        result=worker['result'],image=observation.get('image'),output=observation['output'],
        firstRequestMs=observation['firstRequestMs'],combinedMs=observation['importApiAndFirstMs'],
        instrumentedCompileWindowMs=compile_event['inclusiveMs'],
        exclusiveSumMs=sum(row['exclusiveMs'] for row in names.values()),
        cacheInclusiveMs=names.get('driver.base-cache',{}).get('inclusiveMs',0),
        activePaths=active,abiExclusiveMs=abi,
        compileStages=sorted(names.values(),key=lambda x:x['exclusiveMs'],reverse=True),
        fullStageClock=stages))
result=dict(kind='phase63-exclusive-stage-analysis',complete=True,**{'pass':True},
    dataOnly=True,targetExecuted=False,producer=identity(__file__),source=identity(a.report),
    method=report['methodDerivation'],rows=rows,wallSeconds=report['wallSeconds'],
    scope='Single diagnostic first requests; nested exclusive clocks partition each compilation. '
          'API wrappers and host clocks perturb execution. These are not clean timing samples. '
          'Actual owned world/ready/plan calls are observed, not inferred from function availability. '
          'ABI encode/invoke/decode is zero when the image needs no positional adapter. '
          'TS load/check/emission boundaries retain their own semantic scope.')
a.out.parent.mkdir(parents=True,exist_ok=True)
with a.out.open('x') as stream:stream.write(json.dumps(result,indent=2)+'\n')
print(json.dumps(dict(output=identity(a.out),wallSeconds=result['wallSeconds'],rows=[dict(case=r['case'],role=r['role'],
    compilationMs=r['firstRequestMs'],cacheMs=r['cacheInclusiveMs'],activePaths=r['activePaths'],
    abi=r['abiExclusiveMs'],largest=r['compileStages'][:10]) for r in rows])))
