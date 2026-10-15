#!/usr/bin/env python3
"""Account for actual guarded execution, separate from calibration decisions."""
import collections, json
from run import ROOT, pin, read, save
rows=[];groups=collections.defaultdict(lambda:dict(jobs=0,wallSeconds=0))
for p in sorted((ROOT/'selfhost/build/phase93').rglob('process.json')):
    r=read(p);assert r.get('complete') and r.get('returncode')==0 and not r.get('stoppedFor')
    group=p.relative_to(ROOT/'selfhost/build/phase93').parts[0]
    rows.append(dict(receipt=pin(p),**r));groups[group]['jobs']+=1;groups[group]['wallSeconds']+=r['wallSeconds']
rows.sort(key=lambda r:r['started'])
assert all(a['finished']<=b['started'] for a,b in zip(rows,rows[1:]))
result=dict(complete=True,method=pin(__file__),jobs=len(rows),wallSeconds=sum(r['wallSeconds'] for r in rows),
    campaignSpanSeconds=rows[-1]['finished']-rows[0]['started'],peakTreeRssBytes=max(r['peakTreeRssBytes'] for r in rows),
    overlaps=0,targetFailures=0,groups=dict(groups),records=rows,
    scope='Actual serial guarded jobs only; calibration rejection for zero-work is retained separately. Includes compiler emission, Clang, generated-program calibration/timing/scaling and eight objdump jobs. Excludes planning, offline analysis, archive and publication time. Quota consumption unavailable.')
save(ROOT/'implementation/phase93/execution-ledger.json',result)
print(json.dumps({k:v for k,v in result.items() if k not in ['records','scope','method']}))
