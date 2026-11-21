"""Copy sealed or partial hot-placement receipts without changing the guarded run."""
import gzip
import json
from pathlib import Path
from project import BUILD, HERE, sha

stage='allocation-hot01'
root=BUILD/'phase198'/stage
guard=BUILD/'phase198'/(stage+'-guard')
closed=BUILD/'../build-retention/phase198'/(stage+'-close')
# Closure artifacts live alongside the build tree at selfhost/build-retention.
closed=closed.resolve()
assert closed.is_dir()
inputs=[guard/'process.json',guard/'retention.json',*sorted(closed.glob('*.json'))]
report=root/'report.json'
if report.exists():inputs.insert(0,report)
if (guard/'stderr.log').stat().st_size:inputs.append(guard/'stderr.log')
evidence={}
for p in inputs:
    if p.suffix=='.json':data=json.loads(p.read_text())
    else:data=p.read_text()
    evidence[str(p)]=dict(sha256=sha(p),data=data)
(HERE/'hot-session.json.gz').write_bytes(gzip.compress(json.dumps(evidence,indent=2).encode(),mtime=0))
if not report.exists():
    print('no target report')
else:
    j=json.loads(report.read_text())
    for case,row in j['cases'].items():
        print(case, len(row['checks']), {k:(round(v['median'],5),v['wins']) for k,v in row['ratios'].items()})
