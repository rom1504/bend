#!/usr/bin/env python3
"""Collect complete receipts and arithmetic; runs no compiler or benchmark."""
import json, shutil, statistics, sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
sys.path.insert(0,str(ROOT/'selfhost/tools/build'))
from common import pin, verify, require, write_json
area=ROOT/'selfhost/build/phase165'
out=ROOT/'implementation/phase165'; evidence=out/'evidence'
evidence.mkdir(parents=True,exist_ok=True)
report=dict(kind='phase165-causal-bisection-results',complete=True,
            scope='Private diagnostic ablations. No production compiler changes, speedup, broad qualification or new full cold-build result.',
            source='027e15041035522ed7e40ef971eff75f24a09ef6a00e3f8fe335839f94bcb8a8',
            comparisons={}, backends=[], guards=[], evidence=[])
def preserve(path):
    relative=path.relative_to(area)
    target=evidence/relative
    target.parent.mkdir(parents=True,exist_ok=True)
    shutil.copyfile(path,target)
    row=dict(original=pin(path),copy=pin(target))
    report['evidence'].append(row)
    return pin(path)
for treatment in ['memo','lookup','map','ours-eq']:
    for suite in ['controls','checker','full']:
        path=area/f'{treatment}-{suite}01/report.json'
        data=json.loads(path.read_text()); require(data['complete'],'Incomplete comparison '+str(path))
        require(all(row['exactOracle'] for row in data['rows']),'Changed outcome')
        points={}
        for case in dict.fromkeys(row['case'] for row in data['rows']):
            rows=[x for x in data['rows'] if x['case']==case]
            values={role:[x['process']['seconds'] for x in rows if x['role']==role]
                    for role in dict.fromkeys(x['role'] for x in rows)}
            medians={role:statistics.median(v) for role,v in values.items()}
            candidate=next(role for role in medians if role!='original02')
            points[case]=dict(seconds=values,medians=medians,
                              candidateOverOriginal=medians[candidate]/medians['original02'])
        report['comparisons'][f'{treatment}-{suite}']=dict(receipt=preserve(path),points=points)
for name in ['backend-plan02','backend-plan04','backend-plan05','backend-plan06']:
    path=area/name/'replay/report.json'
    if not path.exists(): continue
    data=json.loads(path.read_text()); require(data['complete'],'Incomplete backend replay')
    values={role:p['seconds'] for role,p in data['products'].items()}
    report['backends'].append(dict(name=name,receipt=preserve(path),case=data['name'],
        seconds=values,qbeOverC=values['qbe']/values['c'],
        bytes={role:p['file']['bytes'] for role,p in data['products'].items()}))
for path in sorted(area.rglob('process.json')):
    data=json.loads(path.read_text())
    if data.get('kind')!='build-retention-disk-guard-v1':continue
    require('finished' in data,'Active target remains')
    report['guards'].append(dict(receipt=preserve(path),complete=data['complete'],
        seconds=data['wallSeconds'],peakRssBytes=data['peakTreeRssBytes'],
        minimumDiskFreeBytes=data['minimumDiskFreeBytes'],stoppedFor=data.get('stoppedFor')))
# Preserve small provenance/failed outcomes, not generated C/ELFs or IR graphs.
seen={x['original']['file'] for x in report['evidence']}
for pattern in ['**/report.json','**/manifest.json','**/plan.json','**/jobs.json','**/emission.stderr']:
    for path in sorted(area.glob(pattern)):
        if str(path) not in seen and path.stat().st_size<250_000:
            preserve(path);seen.add(str(path))
report['cost']=dict(guardedRuns=len(report['guards']),
    guardedSeconds=sum(r['seconds'] for r in report['guards']),
    peakRssBytes=max(r['peakRssBytes'] for r in report['guards']),
    minimumDiskFreeBytes=min(r['minimumDiskFreeBytes'] for r in report['guards']))
write_json(out/'metrics.json',report)
print(json.dumps(report['cost']))
