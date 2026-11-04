#!/usr/bin/env python3
"""Classify completed Phase161 jobs; keep current investigation bytes for sealing."""
import json,subprocess,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
rows=[]
for p in sorted((ROOT/'selfhost/build/phase161').glob('*-guard/process.json')):
 d=json.loads(p.read_text());state=json.loads((p.parent/'retention.json').read_text())
 assert 'finished' in d and state['state'] in ['finished','sealed']
 if not state['closed']:
  cmd=[sys.executable,'-B',str(ROOT/'selfhost/tools/build-retention/close.py'),
   '--run',str(p.parent),'--out',str(ROOT/'selfhost/build-retention/phase161'/(p.parent.name+'-close')),
   '--classification','completed' if d['complete'] else 'failed']
  for root in d['artifactRoots']:cmd+=['--keep-root',root]
  child=subprocess.run(cmd,cwd=ROOT,capture_output=True,text=True)
  if child.returncode:raise RuntimeError(child.stdout+child.stderr)
 state=json.loads((p.parent/'retention.json').read_text());assert state['closed']
 rows.append(dict(run=p.parent.name,complete=d['complete'],seconds=d['wallSeconds'],peakTreeRssBytes=d['peakTreeRssBytes'],classification=state['classification'],closure=state['closure']))
out=ROOT/'implementation/phase161';out.mkdir(exist_ok=True)
cost=dict(kind='phase161-resource-cost',complete=True,jobs=len(rows),guardWallSeconds=sum(x['seconds'] for x in rows),
 peakTreeRssBytes=max(x['peakTreeRssBytes'] for x in rows),runs=rows,
 scope='Serial guarded job elapsed time includes compiler execution, machine acquisition, validation and failed attempts. It excludes preparation, agent/source analysis, documentation and archiving. No token/quota telemetry available; these are not billing estimates.',
 retention='Each run explicitly classified; fresh investigation artifacts kept hot and sealed together into a content-deduplicated exact capsule. Earlier Phase156 raw-file pruning and Phase153 diagnostic alias restoration are separately authenticated; no age-based deletion.')
(out/'cost.json').write_text(json.dumps(cost,indent=2)+'\n')
print(json.dumps({k:cost[k] for k in ['jobs','guardWallSeconds','peakTreeRssBytes']}))
