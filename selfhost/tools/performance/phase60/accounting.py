#!/usr/bin/env python3
"""Data-only cutoff accounting of compiler campaign reports; never launch targets."""
import argparse,datetime,hashlib,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4];RAW=ROOT/'selfhost/build/phase60'
def ident(p):
 p=Path(p).resolve();b=p.read_bytes()
 return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def utc(value):return datetime.datetime.fromisoformat(value.replace('Z','+00:00')).timestamp()
def union(intervals):
 merged=[]
 for a,b in sorted(intervals):
  if merged and a<=merged[-1][1]:merged[-1][1]=max(b,merged[-1][1])
  else:merged.append([a,b])
 return sum(b-a for a,b in merged)
def summary(rows):
 charged=[r for r in rows if r['charged']]
 return dict(processes=len(charged),processWallSeconds=sum(r['processWallSeconds'] for r in charged),
  intervalUnionSeconds=union([r['interval'] for r in charged]),
  maxObservedTreeRssBytes=max([r['peakTreeRssBytes'] or 0 for r in charged],default=0),
  firstRequestsObserved=sum(r['firstRequestsObserved'] for r in charged),
  laterRequestsObserved=sum(r['laterRequestsObserved'] for r in charged),
  failedRows=sum(r['status']=='failed' for r in rows),unaccountedRows=sum(not r['charged'] and r['duplicateOf'] is None for r in rows))
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--report',type=Path,action='append',required=True)
p.add_argument('--cutoff-utc',required=True);p.add_argument('--out',type=Path,required=True)
a=p.parse_args();out=a.out.resolve();assert out.is_relative_to(RAW) and not out.exists()
startPath=RAW/'start.json';resumePath=RAW/'resume01.json'
start=json.loads(startPath.read_text());resume=json.loads(resumePath.read_text())
begin=utc(resume['resumedUtc']);cutoff=utc(a.cutoff_utc);assert cutoff>=begin
inputs=[ident(startPath),ident(resumePath)];seen={};rows=[];campaigns=[]
for path in a.report:
 path=path.resolve();assert path.is_relative_to(RAW);pin=ident(path);d=json.loads(path.read_text());inputs.append(pin)
 assert 'preparations' in d and 'rows' in d,'Not a compiler campaign report: '+str(path)
 local=[]
 for section in ['preparations','rows']:
  for ordinal,row in enumerate(d[section]):
   e=row.get('execution') or {};o=row.get('observation') or {};request=o.get('request')
   if not request:
    command=e.get('command',[])
    candidates=[Path(x) for x in command if isinstance(x,str) and x.endswith('.request.json')]
    if len(candidates)==1 and candidates[0].exists():request=ident(candidates[0])
   if request:
    actual=ident(request['file']);assert actual['sha256']==request['sha256'];inputs.append(actual)
    key=(actual['file'],actual['sha256'])
   else:key=None
   previous=seen.get(key) if key else None
   if previous is not None:
    assert rows[previous]['execution']==e,'Same request identity names a different execution; refuse deduplication'
   finished=e.get('finished');started=e.get('started');wall=e.get('wallSeconds')
   ended=isinstance(finished,(int,float)) and isinstance(started,(int,float)) and isinstance(wall,(int,float))
   inWindow=ended and begin<=started<=finished<=cutoff
   success=row.get('success',o.get('pass'))
   status='passed' if success is True else 'failed' if success is False else 'unknown'
   if not ended:status='unfinished-or-skipped'
   elif not inWindow:status='outside-cutoff'
   charged=bool(inWindow and previous is None)
   if charged and key:seen[key]=len(rows)
   r=dict(campaign=str(path),section=section,ordinal=ordinal,request=request,
    role=row.get('role',o.get('role')),case=row.get('case'),mode=d.get('mode'),status=status,
    charged=charged,duplicateOf=previous,execution=e,observationError=row.get('observationError'),
    processWallSeconds=wall if charged else 0,interval=[started,finished] if charged else None,
    peakTreeRssBytes=e.get('peakTreeRssBytes'),maxRssKiB=o.get('maxRssKiB'),
    firstRequestsObserved=int(isinstance(o.get('firstRequestMs'),(int,float))),
    laterRequestsObserved=len(o.get('warmRequests',[])))
   local.append(r);rows.append(r)
 campaigns.append(dict(report=pin,complete=d.get('complete'),pass_=d.get('pass'),
  runnerWallSeconds=d.get('wallSeconds'),preparationSeconds=d.get('preparationSeconds'),
  measurementStageSeconds=d.get('measurementStageSeconds'),expectedWorkers=d.get('expectedWorkers'),
  successfulWorkers=d.get('successfulWorkers'),failures=d.get('failures',[]),
  reusedPreparations=d.get('preparationsReusedFrom'),accounting=summary(local)))
for c in campaigns:c['pass']=c.pop('pass_')
# Retain one identity per input, checking reports/requests are unchanged before publication.
inputs=list({r['file']:r for r in inputs}.values())
for r in inputs:assert ident(r['file'])==r,'Accounting input changed while reading'
result=dict(kind='phase60-target-process-accounting',complete=True,dataOnly=True,targetExecuted=False,
 producer=ident(__file__),phaseStartUtc=start['startedUtc'],resumeUtc=resume['resumedUtc'],cutoffUtc=a.cutoff_utc,
 windowSeconds=cutoff-begin,excludedPreResumeSeconds=begin-utc(start['startedUtc']),
 pauseScope='Pre-resume window excluded, including overnight usage-limit interruption; no target preceded resume per resume receipt. Not an estimate of active project work.',
 campaigns=campaigns,totals=summary(rows),rows=rows,inputs=inputs,
 scope='Explicit supplied compiler reports through cutoff only. Reused preparations deduplicated by exact request path/hash. Process sums include host/setup inside each child; runner walls overlap process sums and must not be added. No total project wall, CPU utilization, agent effort, fresh preservation audit or clean benchmark claim. Failed completed children charged; unfinished/skipped/out-of-window rows retained without invented duration. Request counts are observed first/later compiler calls, excluding unreported preparation/preflight internals. Fast20/60 use this same report schema; their fresh reports must be explicitly supplied.')
out.parent.mkdir(parents=True,exist_ok=True)
with out.open('x') as f:json.dump(result,f,indent=2);f.write('\n')
print(json.dumps(result['totals']))
