#!/usr/bin/env python3
"""Account union of recorded process intervals; do not infer waiting time."""
import datetime,hashlib,json,sys
from pathlib import Path
root,out=map(Path,sys.argv[1:]);assert not out.exists()
start=json.loads((root/'start.json').read_text())['startedUtc']
a=datetime.datetime.fromisoformat(start.replace('Z','+00:00')).timestamp();b=datetime.datetime.now(datetime.timezone.utc).timestamp()
rows=[]
for p in sorted(root.rglob('*.json')):
    try:d=json.loads(p.read_text())
    except (ValueError,UnicodeError):continue
    if not isinstance(d,dict) or not isinstance(d.get('command'),list):continue
    s,e=d.get('started'),d.get('finished')
    if isinstance(s,(int,float)) and isinstance(e,(int,float)) and a<=s<=e<=b:
        rows.append({'path':str(p.relative_to(root)),'started':s,'finished':e,'seconds':e-s,'peakTreeRssBytes':d.get('peakTreeRssBytes'),'returncode':d.get('returncode')})
intervals=[]
for r in sorted(rows,key=lambda x:x['started']):
    if intervals and r['started']<=intervals[-1][1]:intervals[-1][1]=max(intervals[-1][1],r['finished'])
    else:intervals.append([r['started'],r['finished']])
recorded=sum(e-s for s,e in intervals)
d={'kind':'phase54-recorded-process-accounting','complete':True,'producer':{'path':str(Path(__file__).resolve()),'sha256':hashlib.sha256(Path(__file__).read_bytes()).hexdigest()},'startedUtc':start,'cutoffUtc':datetime.datetime.fromtimestamp(b,datetime.timezone.utc).isoformat(),'elapsedSeconds':b-a,'recordedProcessUnionSeconds':recorded,'otherElapsedSeconds':b-a-recorded,'records':rows,'scope':'Union of top-level timestamped process receipts within this phase. Nested/overlapping intervals are not summed. Remaining wall time includes analysis, tooling without receipts, review, docs, orchestration and idle time; it is not a waiting estimate. Publication after cutoff is excluded.'}
out.write_text(json.dumps(d,indent=2)+'\n');print(json.dumps({k:d[k]for k in ['elapsedSeconds','recordedProcessUnionSeconds','otherElapsedSeconds']}))
