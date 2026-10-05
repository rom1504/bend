#!/usr/bin/env python3
"""Data-only top-level supervisor interval accounting; run after timing, never targets."""
import argparse, collections, hashlib, importlib.util, json, sys, time
from pathlib import Path

sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent
PREVIOUS=HERE.parent/'phase48/time-use.py'
assert hashlib.sha256(PREVIOUS.read_bytes()).hexdigest()=='d3f1d6d6948903f3af09ae3bf4e739d13687710b46e3cbacd464415c19295bc8'
PARENT=HERE.parent/'phase47/time-use.py'
assert hashlib.sha256(PARENT.read_bytes()).hexdigest()=='a516193ef66473e792c575d8e206d5f2451465607fa9356a21e095ae91d45e1a'
spec=importlib.util.spec_from_file_location('phase47_time_helpers',PARENT)
old=importlib.util.module_from_spec(spec);spec.loader.exec_module(old)
CATEGORIES=['build','acquisition','control','timing','cost','qualification','profiles','preparation','release','other']
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--root',type=Path,default=HERE.parents[2]/'build/phase52')
p.add_argument('--end',help='UTC cutoff; omission is an explicitly provisional current-time snapshot')
p.add_argument('--categories',type=Path,help='Optional JSON mapping exact relative receipt-path prefixes to categories')
p.add_argument('--out',type=Path,required=True);a=p.parse_args()
root=a.root.resolve(strict=True);assert not a.out.exists()
inputs=[]
def identity(file,raw=None):
 file=Path(file).resolve();raw=file.read_bytes() if raw is None else raw
 return dict(file=str(file),sha256=hashlib.sha256(raw).hexdigest(),bytes=len(raw))
def read(file):
 raw=Path(file).read_bytes();inputs.append(identity(file,raw));return json.loads(raw)
inputs.extend([identity(__file__),identity(PARENT),identity(PREVIOUS)])
start=old.stamp(read(root/'start.json')['startedUtc']);end=old.stamp(a.end) if a.end else time.time();assert end>start
overrides=read(a.categories) if a.categories else {};assert all(v in CATEGORIES for v in overrides.values())
def category(file,command):
 matching=[k for k in overrides if file==k or file.startswith(k.rstrip('/')+'/')]
 if matching:return overrides[max(matching,key=len)]
 text=(file+' '+' '.join(map(str,command))).lower()
 if file.startswith('smoke-direct'):return 'control'
 if 'acquisition' in file or 'acquire-semantics' in text:return 'acquisition'
 if any(str(x).endswith('/workflow.mjs') for x in command) and 'run' in command:return 'build'
 if 'compiler-cost' in text or 'library-cost-worker' in text:return 'cost'
 if any(x in text for x in ['--cpu-prof','--heap-prof','--trace-opt','--trace-deopt','diagnose.py']):return 'profiles'
 if any(str(x).endswith(('/emit-worker.mjs','/emit-worker-v2.mjs')) for x in command):return 'acquisition'
 if any(str(x).endswith(('/execute.mjs','/consumed-execute.mjs')) for x in command):return 'timing'
 if any(x in text for x in ['qualify','backend-run.py','backend-census.py','conformance/target.mjs','frontend-gate']):return 'qualification'
 if any(x in text for x in ['release.mjs','release-smoke','portable-smoke','--install-attempt']):return 'release'
 if any(x in text for x in ['/controls/','controls.mjs','-controls','/test.mjs','/test-','entry-probe','native-corpus-probe']):return 'control'
 if any(x in text for x in ['derive','audit','snapshot','freeze','bind-','prepare-final']):return 'preparation'
 return 'other'
records=[];seen={};skipped=[]
# Only process/run supervisor receipts. Copies embedded in report/preparation JSON are not summed.
for file in sorted(set(root.rglob('process.json')) | set(root.rglob('run.json'))):
 relative=str(file.relative_to(root))
 try:data=read(file)
 except (OSError,ValueError) as error:skipped.append(dict(file=relative,reason=str(error)));continue
 for location,row in old.process_rows(data):
  if not all(k in row for k in ['started','finished','wallSeconds']):
   skipped.append(dict(file=relative,location=location,reason='unfinished or no measured wall interval'));continue
  try:begin=old.stamp(row['started']);finish=old.stamp(row['finished'])
  except ValueError as error:skipped.append(dict(file=relative,location=location,reason=str(error)));continue
  if finish<=begin:skipped.append(dict(file=relative,location=location,reason='nonpositive interval'));continue
  if finish<=start or begin>=end:continue
  key=(begin,finish,tuple(map(str,row['command'])))
  if key in seen:records[seen[key]]['duplicates'].append(relative+':'+location);continue
  seen[key]=len(records)
  records.append(dict(id=len(records),file=relative,location=location,duplicates=[],command=row['command'],
   start=begin,finish=finish,wallSeconds=row['wallSeconds'],category=category(relative,row['command']),
   complete=row.get('complete'),returncode=row.get('returncode'),peakTreeRssBytes=row.get('peakTreeRssBytes'),
   rssLimitBytes=row.get('rssLimitBytes'),availableFloorBytes=row.get('availableFloorBytes')))
# Shared-guard campaigns are serial; enclosed child supervisors do not add wall time.
# This is temporal containment, not an inferred PID/process-tree relationship.
for row in records:
 parents=[x for x in records if x['id']!=row['id'] and x['start']<=row['start'] and x['finish']>=row['finish']
          and (x['start']<row['start'] or x['finish']>row['finish'])]
 row['enclosedBy']=max(parents,key=lambda x:x['finish']-x['start'])['id'] if parents else None
top=[r for r in records if r['enclosedBy'] is None]
events=collections.defaultdict(lambda:dict(start=[],end=[]))
for r in top:
 events[max(start,r['start'])]['start'].append(r['id']);events[min(end,r['finish'])]['end'].append(r['id'])
active=set();totals=collections.Counter();segments=[];points=sorted(events);union=0
for at,next_at in zip(points,points[1:]):
 active.difference_update(events[at]['end']);active.update(events[at]['start'])
 if not active:continue
 kinds={records[i]['category'] for i in active};kind=next(iter(kinds)) if len(kinds)==1 else 'overlap-mixed'
 seconds=next_at-at;union+=seconds;totals[kind]+=seconds
 segments.append(dict(start=at,finish=next_at,seconds=seconds,category=kind,records=sorted(active)))
changed=[r['file'] for r in inputs if not Path(r['file']).is_file() or identity(r['file'])!=r]
failed=[r['id'] for r in records if r['returncode'] not in [None,0] or r['complete'] is False]
report=dict(kind='phase52-top-level-supervisor-time',dataOnly=True,complete=not changed,
 provisional=a.end is None,inputs=inputs,changedInputs=changed,start=old.iso(start),cutoff=old.iso(end),
 elapsedSeconds=end-start,observedUnionSeconds=union,uncoveredSeconds=end-start-union,
 categories={c:dict(unionSeconds=totals[c],topLevelRecords=sum(r['category']==c for r in top)) for c in CATEGORIES+['overlap-mixed']},
 uniqueProcessRecords=len(records),topLevelRecords=len(top),nestedRecordsExcluded=len(records)-len(top),
 duplicateRecordLocations=sum(len(r['duplicates']) for r in records),failedRecordIds=failed,
 failedTopLevelIds=[r['id'] for r in top if r['id'] in failed],
 observedPeakTreeRssBytes=max((r['peakTreeRssBytes'] or 0 for r in records),default=0),
 naiveClippedSumSeconds=sum(min(end,r['finish'])-max(start,r['start']) for r in records),
 topLevelClippedSumSeconds=sum(min(end,r['finish'])-max(start,r['start']) for r in top),
 otherRecords=[r['id'] for r in top if r['category']=='other'],records=records,segments=segments,skipped=skipped,
 method='Reuse Phase47 timestamp/record reader. Collapse identical command/start/finish copies; retain temporal enclosure roots; union half-open intervals, assigning partial mixed-category overlap its own bucket. Child resource peaks and failures remain diagnostic, never added durations. Categories express outer-job intent.',
 limits='Wall occupancy is not CPU usage or agent work time. Uncovered time mixes analysis, code, review, docs, orchestration, unrecorded operations and possible idle time; never label it waiting. Only finished process.json and run.json intervals are covered. Explicit cutoff does not prove writer closure; final publication separately needs closure evidence.')
a.out.parent.mkdir(parents=True,exist_ok=True)
with a.out.open('x') as stream:json.dump(report,stream,indent=2);stream.write('\n')
print(json.dumps({k:report[k] for k in ['complete','provisional','elapsedSeconds','observedUnionSeconds','topLevelRecords','nestedRecordsExcluded','categories','otherRecords']}))
raise SystemExit(0 if not changed else 1)
