#!/usr/bin/env python3
"""Account retained guard intervals without summing overlapping parent jobs."""
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4];RAW=ROOT/'selfhost/build/phase76'
rows=[]
for p in RAW.rglob('*.json'):
 if p.name not in ['process.json','run.json']:continue
 try:j=json.loads(p.read_text())
 except (ValueError,OSError):continue
 start,wall=j.get('started'),j.get('wallSeconds')
 if not isinstance(start,(int,float)) or not isinstance(wall,(int,float)):continue
 if not isinstance(j.get('command'),list):continue
 rows.append(dict(path=str(p.relative_to(ROOT)),started=start,finished=start+wall,wallSeconds=wall,returncode=j.get('returncode'),complete=j.get('complete'),peakTreeRssBytes=j.get('peakTreeRssBytes')))
assert rows
intervals=[]
for row in sorted(rows,key=lambda x:x['started']):
 a,b=row['started'],row['finished']
 if intervals and a<=intervals[-1][1]:intervals[-1][1]=max(b,intervals[-1][1])
 else:intervals.append([a,b])
report=dict(complete=True,guardReceipts=len(rows),guardedWallUnionSeconds=sum(b-a for a,b in intervals),firstToLastGuardSpanSeconds=intervals[-1][1]-intervals[0][0],maximumRecordedTreeRssBytes=max(x['peakTreeRssBytes'] or 0 for x in rows),guardsWithNonzeroExit=sum(x['returncode'] not in [0,None] for x in rows),scope='Union of retained numeric guard wall intervals avoids double-counting nested controllers. Includes failures, preparation and resource-guarded validation. Span is first-to-last guard, not active human/agent time. Neither CPU time nor account quota/task billing. Unguarded reads, edits, reporting, pushes and sealing excluded.',rows=rows)
(ROOT/'implementation/phase76/time-accounting.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps({k:v for k,v in report.items() if k!='rows'}))
