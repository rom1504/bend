#!/usr/bin/env python3
"""Root-only two-case stage diagnostic; at most60s each and180s total."""
import argparse
import hashlib
import json
import sys
import time
from pathlib import Path

ROOT=Path(__file__).resolve().parents[6]
sys.dont_write_bytecode=True
sys.path.insert(0,str(ROOT/'selfhost/tools/performance/programs'))
from support import ExecutionGuard

p=argparse.ArgumentParser(description=__doc__)
p.add_argument('manifest',type=Path);p.add_argument('out',type=Path)
a=p.parse_args();assert not a.out.exists();m=json.loads(a.manifest.read_text())
assert m['kind']=='phase66-shared-layout-diagnostic-plan' and m['complete']
assert 1<=len(m['cases'])<=2 and 1<=m['resources']['perCaseSeconds']<=60 and 1<=m['resources']['totalSeconds']<=180
def verify():
    for row in m['inputs']:assert hashlib.sha256(Path(row['file']).read_bytes()).hexdigest()==row['sha256'],row['file']
verify();a.out.mkdir(parents=True);started=time.monotonic();rows=[]
with ExecutionGuard(rss_mib=2048,available_mib=4096) as guard:
    for i,case in enumerate(m['cases']):
        target=a.out/str(i)
        command=['taskset','-c','3',m['node']['file'],'--stack-size=4096','--max-old-space-size=1024',
                 m['worker']['file'],str(a.manifest.resolve()),str(i),str(target)]
        process=guard.run(command,a.out/(str(i)+'-process'),min(started+m['resources']['totalSeconds'],time.monotonic()+m['resources']['perCaseSeconds']))
        row=dict(case=case['id'],process=process,result=None,apiEvents=[])
        if (target/'report.json').exists():row['result']=json.loads((target/'report.json').read_text())
        if (target/'api.jsonl').exists():row['apiEvents']=[json.loads(x) for x in (target/'api.jsonl').read_text().splitlines()]
        rows.append(row)
        if guard.interrupted:break
verify();result=dict(kind='phase66-shared-layout-diagnostic',complete=len(rows)==len(m['cases']),diagnosticOnly=True,
    productionQualified=False,rows=rows,inputsUnchanged=True,inputs=m['inputs'],wallSeconds=time.monotonic()-started,
    scope='Diagnostic tracing changes timings. A deadline is retained as timeout evidence, never a successful conformance observation. No source/API/cache bytes changed; only private driver public-call tracing was added.')
(a.out/'report.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(dict(report=str(a.out/'report.json'),complete=result['complete'],cases=[dict(id=r['case'],stoppedFor=r['process'].get('stoppedFor'),lastApi=r['apiEvents'][-1] if r['apiEvents'] else None) for r in rows])))
