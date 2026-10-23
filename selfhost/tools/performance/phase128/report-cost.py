"""Summarize completed guard intervals; never infer token/quota expenditure."""
import argparse
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()
assert not a.out.exists()
pin = lambda f: dict(file=str(f.resolve()), bytes=f.stat().st_size,
    sha256=hashlib.sha256(f.read_bytes()).hexdigest())
rows, pending = [], []
for f in sorted((ROOT/'selfhost/build/phase128').glob('*/process.json')):
    r = json.loads(f.read_text())
    if 'finished' not in r:
        pending.append(str(f)); continue
    rows.append(dict(name=f.parent.name, report=pin(f), started=r['started'],
        finished=r['finished'], seconds=r['wallSeconds'], status=r.get('returncode'),
        peakRssBytes=r.get('peakTreeRssBytes', 0), command=r['command']))
intervals=[]
for r in sorted(rows, key=lambda x:x['started']):
    if intervals and r['started'] <= intervals[-1][1]:
        intervals[-1][1]=max(intervals[-1][1],r['finished'])
    else: intervals.append([r['started'],r['finished']])
now=datetime.now(timezone.utc)
started=datetime.fromisoformat('2026-10-23T14:49:07+00:00')
report=dict(complete=not pending, asOf=now.isoformat(), phaseStarted=started.isoformat(),
    wallSeconds=(now-started).total_seconds(), guardedActiveSeconds=sum(b-a for a,b in intervals),
    guardedJobSumSeconds=sum(r['seconds'] for r in rows), jobs=len(rows),
    failedJobs=sum(r['status']!=0 for r in rows),
    peakTreeRssBytes=max((r['peakRssBytes'] for r in rows),default=0),
    pending=pending, rows=rows, inputs=[pin(Path(__file__))],
    scope='Completed Phase128 guard receipts, including failures. Interval union avoids double-counting concurrent jobs. Outside-guard wall includes investigation, edits, documentation, source/receipt hashing, commits and orchestration; it is not all idle time. Subagent work overlaps this wall clock. No token/quota accounting endpoint is available, so no token-cost claim is made.')
a.out.write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps({k:v for k,v in report.items() if k not in ['rows','inputs']}))
