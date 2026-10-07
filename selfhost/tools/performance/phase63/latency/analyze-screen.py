#!/usr/bin/env python3
"""Summarize a completed screen and observed target occupancy through its last worker."""
import argparse
import datetime
import hashlib
import json
import math
from pathlib import Path

ROOT=Path(__file__).resolve().parents[5]
RAW=ROOT/'selfhost/build/phase63'


def identity(file):
    file=Path(file).resolve(strict=True)
    return dict(file=str(file),sha256=hashlib.sha256(file.read_bytes()).hexdigest())


def read(file): return json.loads(Path(file).read_text())


def gm(values): return math.exp(sum(math.log(x) for x in values)/len(values))


def utc(seconds):
    return datetime.datetime.fromtimestamp(seconds,datetime.timezone.utc).isoformat()


p=argparse.ArgumentParser(description=__doc__)
p.add_argument('report',type=Path)
p.add_argument('--out',type=Path,required=True)
a=p.parse_args();assert not a.out.exists()
source=read(a.report);assert source['complete'] and source['pass'] and source['mode']=='clean'
assert not source['failures'] and source['successfulWorkers']==source['expectedWorkers']
plan=read(source['config']['file']);assert identity(source['config']['file'])==source['config']
binding=read(plan['imageBindings']['file']);assert identity(plan['imageBindings']['file'])==plan['imageBindings']
assert binding['roles']['baseline']['kind']==binding['roles']['candidate']['kind']=='checked'
assert plan['rounds']==1 and len(source['statistics'])==2
metrics=['firstRequestMs','importApiAndFirstMs']
cases=[]
for case,roles in source['statistics'].items():
    row=dict(id=case,roles={})
    for role,data in roles.items():
        row['roles'][role]={key:data[key]['median'] for key in metrics+['hostImportMs','apiLoadMs','maxRssKiB','peakTreeRssBytes']}
    row['ratios']={}
    for key in metrics:
        row['ratios'][key]=dict(candidateOverBaseline=roles['candidate'][key]['median']/roles['baseline'][key]['median'],
            candidateOverTypescript=roles['candidate'][key]['median']/roles['typescript'][key]['median'],
            baselineOverTypescript=roles['baseline'][key]['median']/roles['typescript'][key]['median'])
    cases.append(row)
summary={key:{ratio:gm([x['ratios'][key][ratio] for x in cases])
    for ratio in ['candidateOverBaseline','candidateOverTypescript','baselineOverTypescript']} for key in metrics}
preparations=[]
for row in source['preparations']:
    assert row['success']
    observation=row['observation'];execution=row['execution'];role=observation['role']
    preparations.append(dict(role=role,processSeconds=execution['wallSeconds'],
        basePrimeMs=observation.get('basePrimeMs'),preflightMs=observation['preflightMs'],
        workerElapsedMs=observation['workerElapsedMs'],peakTreeRssBytes=execution['peakTreeRssBytes'],
        image=observation.get('image'),result=row['result']))
cutoff=max(row['execution']['finished'] for row in source['rows'])
campaign=read(RAW/'campaign.json')
begin=datetime.datetime.fromisoformat(campaign['started'].replace('Z','+00:00')).timestamp()
intervals=[];unfinished=[]
for file in sorted([*RAW.rglob('run.json'),*RAW.rglob('process.json')]):
    try: record=read(file)
    except (json.JSONDecodeError,FileNotFoundError): continue
    if not isinstance(record.get('started'),(int,float)) or not isinstance(record.get('command'),list):continue
    start=record['started']
    if start>=cutoff:continue
    finish=record.get('finished')
    if not isinstance(finish,(int,float)):
        unfinished.append(str(file));continue
    if finish>cutoff or finish<=begin:continue
    assert finish>=start
    intervals.append(dict(receipt=identity(file),start=max(begin,start),finish=finish,
        complete=record.get('complete'),returncode=record.get('returncode'),
        processWallSeconds=record.get('wallSeconds'),command=record['command']))
merged=[]
for row in sorted(intervals,key=lambda x:x['start']):
    if not merged or row['start']>merged[-1][1]:merged.append([row['start'],row['finish']])
    else:merged[-1][1]=max(merged[-1][1],row['finish'])
occupied=sum(end-start for start,end in merged)
accounting=dict(start=utc(begin),cutoff=utc(cutoff),elapsedSeconds=cutoff-begin,
    completedSupervisorReceipts=len(intervals),failedReceipts=sum(x['returncode']!=0 for x in intervals),
    occupiedUnionSeconds=occupied,occupiedFraction=occupied/(cutoff-begin),
    uncoveredSeconds=cutoff-begin-occupied,unfinishedBeforeCutoff=unfinished,intervals=intervals,
    scope='Recorded serial supervisor interval union, including failed targets, through last screen worker. '
          'No double-counting reused preparations or nested intervals. Uncovered wall is not classified '
          'as waiting; includes reasoning, source/tool work, review and unobserved activity. '
          'Subsequent targets excluded; incomplete intervals receive no invented finish.')
report=dict(kind='phase63-screen-analysis',complete=True,**{'pass':True},dataOnly=True,targetExecuted=False,
    producer=identity(__file__),source=identity(a.report),plan=source['config'],binding=plan['imageBindings'],
    imageKinds={role:value['kind'] for role,value in binding['roles'].items()},
    rounds=plan['rounds'],roles=plan['roles'],cases=cases,geometricMeans=summary,
    preparations=preparations,preparationReport=source['preparationsReusedFrom'],
    screenWallSeconds=source['wallSeconds'],measurementStageSeconds=source['measurementStageSeconds'],
    accounting=accounting,
    scope='Preliminary two-source checked-B1 comparison; one sample per cell, fixed role order. '
          'Complete raw bytes match qualified references. No B2, broad-population, per-feature '
          'attribution, statistical-significance or emitted-program speed claim.')
if source['preparationsReusedFrom']:
    preparation=read(source['preparationsReusedFrom']['file'])
    assert identity(source['preparationsReusedFrom']['file'])==source['preparationsReusedFrom']
    report['preparationWallSeconds']=preparation['wallSeconds']
a.out.parent.mkdir(parents=True,exist_ok=True)
with a.out.open('x') as stream:stream.write(json.dumps(report,indent=2)+'\n')
print(json.dumps(dict(output=identity(a.out),geometricMeans=summary,
    accounting={k:v for k,v in accounting.items() if k!='intervals'},screenSeconds=source['wallSeconds'])))
