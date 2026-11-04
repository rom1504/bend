#!/usr/bin/env python3
"""Classify completed Phase160 jobs; keep current investigation bytes for sealing."""
import json,subprocess,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
rows=[]
for p in sorted((ROOT/'selfhost/build/phase160').glob('*-guard/process.json')):
 d=json.loads(p.read_text());state=json.loads((p.parent/'retention.json').read_text())
 assert 'finished' in d and state['state'] in ['finished','sealed']
 if not state['closed']:
  cmd=[sys.executable,'-B',str(ROOT/'selfhost/tools/build-retention/close.py'),
   '--run',str(p.parent),'--out',str(ROOT/'selfhost/build-retention/phase160'/(p.parent.name+'-close')),
   '--classification','rejected' if p.parent.name=='full-profile01-guard' else ('completed' if d['complete'] else 'failed')]
  for root in d['artifactRoots']:cmd+=['--keep-root',root]
  child=subprocess.run(cmd,cwd=ROOT,capture_output=True,text=True)
  if child.returncode:raise RuntimeError(child.stdout+child.stderr)
 state=json.loads((p.parent/'retention.json').read_text());assert state['closed']
 rows.append(dict(run=p.parent.name,complete=d['complete'],seconds=d['wallSeconds'],peakTreeRssBytes=d['peakTreeRssBytes'],classification=state['classification'],closure=state['closure']))
out=ROOT/'implementation/phase160';out.mkdir(exist_ok=True)
cost=dict(kind='phase160-resource-cost',complete=True,jobs=len(rows),guardWallSeconds=sum(x['seconds'] for x in rows),
 peakTreeRssBytes=max(x['peakTreeRssBytes'] for x in rows),runs=rows,
 scope='Serial guarded job elapsed time includes compiler execution, machine acquisition, validation and failed attempts. It excludes preparation, agent/source analysis, documentation and archiving. No token/quota telemetry available; these are not billing estimates.',
 retention='Each run explicitly classified; fresh investigation artifacts kept hot and sealed together into a content-deduplicated exact capsule. Earlier Phase153 raw-file pruning is separately authenticated; no age-based deletion.')
(out/'cost.json').write_text(json.dumps(cost,indent=2)+'\n')
print(json.dumps({k:cost[k] for k in ['jobs','guardWallSeconds','peakTreeRssBytes']}))
