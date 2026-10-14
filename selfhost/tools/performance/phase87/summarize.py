#!/usr/bin/env python3
"""Offline Phase87 output verification and native investigation resource account."""
import argparse,hashlib,json,math,statistics
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4];RAW=ROOT/'selfhost/build/phase87'
ap=argparse.ArgumentParser();ap.add_argument('--out',type=Path,required=True);args=ap.parse_args()
def ident(f):
    b=f.read_bytes();return dict(file=str(f.relative_to(ROOT)),sha256=hashlib.sha256(b).hexdigest(),bytes=len(b))
lanes=[];independent={k:{v} for k,v in json.loads((ROOT/'implementation/phase86/summary.json').read_text())['independentB2'].items()};port_outputs=[]
for f in sorted(RAW.glob('control-*-b2-output.json')):
    p=json.loads(f.read_text());case=f.name.removeprefix('control-').removesuffix('-b2-output.json')
    if p.get('complete'):
        independent.setdefault(case,set()).update(c['sha256'] for c in p['calls'])
for f in sorted(RAW.glob('*/report.json')):
    p=json.loads(f.read_text())
    if 'rows' not in p or 'cases' not in p:continue
    groups={};counts={};mismatches=[]
    for row in p['rows']:
        key=(row['case'],row['role']);g=groups.setdefault(key,dict(requests=[],preparation=[],runtimePreparation=[],processWall=[],rss=[],failures=[]))
        if not row['guard']['complete']:
            g['failures'].append(row['name']);continue
        g['processWall'].append(row['guard']['wallSeconds']*1000);g['rss'].append(row['guard']['peakTreeRssBytes'])
        if 'reference' in row:g['requests'].append([c['requestMs'] for c in row['reference']['calls']])
        else:
            values={}
            for k,v in row['metrics']:values.setdefault(k,[]).append(int(v))
            g['requests'].append(values.get('request_ms',[]));g['preparation']+=values.get('base_prepare_ms',[]);g['runtimePreparation']+=values.get('runtime_prepare_ms',[])
        for output in row['outputs']:
            actual=ident(Path(output['path']));assert actual['sha256']==output['sha256']
            if row['role']=='b2':independent.setdefault(row['case'],set()).add(output['sha256'])
            elif row['role'] in ('native','js'):port_outputs.append(dict(lane=f.parent.name,case=row['case'],role=row['role'],sha256=output['sha256']))
            # Upstream is a different emitter; port hosts must have exact C.
            family='typescript' if row['role']=='typescript' else 'bend'
            counts.setdefault((row['case'],family),[]).append(output['sha256'])
    timing=[]
    for (case,role),g in groups.items():
        calls=g['requests'];medians=[statistics.median(c[i] for c in calls) for i in range(len(calls[0]))] if calls else []
        timing.append(dict(case=case,role=role,samples=len(calls),requestMs=medians,
            preparationMs=statistics.median(g['preparation']) if g['preparation'] else None,
            runtimePreparationMs=statistics.median(g['runtimePreparation']) if g['runtimePreparation'] else None,
            wallMs=statistics.median(g['processWall']) if calls else None,peakRssBytes=max(g['rss'],default=0),failures=g['failures']))
    for (case,family),hashes in counts.items():
        if len(set(hashes))!=1:mismatches.append(dict(case=case,family=family,hashes=sorted(set(hashes))))
    lanes.append(dict(lane=f.parent.name,report=ident(f),complete=p.get('complete',False),allJobsSucceeded=p.get('allJobsSucceeded',False),timing=timing,outputs=sum(map(len,counts.values())),mismatches=mismatches))
guards=[]
for f in RAW.rglob('process.json'):
    p=json.loads(f.read_text());guards.append(dict(file=str(f.relative_to(ROOT)),complete=p['complete'],wallSeconds=p.get('wallSeconds'),peakRssBytes=p['peakTreeRssBytes'],stoppedFor=p.get('stoppedFor'),returncode=p.get('returncode'),started=p['started'],finished=p.get('finished')))
finished=[g for g in guards if g['finished'] is not None]
account=dict(jobs=len(guards),successful=sum(g['complete'] for g in guards),unfinalized=sum(g['finished'] is None for g in guards),occupancySeconds=sum(g['wallSeconds'] for g in finished),peakRssBytes=max((g['peakRssBytes'] for g in guards),default=0),elapsedSeconds=max(g['finished'] for g in finished)-min(g['started'] for g in guards),receipts=guards)
for hashes in independent.values():assert len(hashes)==1,'Independent B2 oracle changed'
for row in port_outputs:
    row['hasIndependentB2']=row['case'] in independent
    row['matchesB2']=row['sha256'] in independent.get(row['case'],set())
assert all(r['matchesB2'] for r in port_outputs),'Positive prototype output lacks an exact independent B2 match'
out=args.out.resolve();out.parent.mkdir(parents=True,exist_ok=True);out.write_text(json.dumps(dict(lanes=lanes,independentB2={k:next(iter(v)) for k,v in independent.items()},portOutputs=port_outputs,account=account),indent=2)+'\n')
print(json.dumps(dict(lanes=[dict(name=l['lane'],outputs=l['outputs'],mismatches=l['mismatches']) for l in lanes],account={k:v for k,v in account.items() if k!='receipts'})))
