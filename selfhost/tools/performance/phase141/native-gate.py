"""Select exact prior qualification cases; do not confuse six broad cases with45."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import sys

ROOT=Path(__file__).resolve().parents[4]
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--image',type=Path,required=True);p.add_argument('--out',type=Path,required=True)
p.add_argument('--set',choices=['focused19','full45'],required=True)
a=p.parse_args();out=a.out.resolve();assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase111')
prior=ROOT/f'selfhost/build/phase111/p137-n3-{a.set}/report.json'
r=json.loads(prior.read_text());assert r['complete'] and r['passed']
count=19 if a.set=='focused19' else 45
assert len(r['names'])==len(r['rows'])==count
refs=out.with_name(out.name+'-references.json');assert not refs.exists()
refs.write_text(json.dumps({x['name']:str(Path(x['emission']['file']).parent)for x in r['rows']},indent=2)+'\n')
runner = 'full45.py' if a.set == 'full45' else 'coverage.py'
cmd=[sys.executable,'-B',str(ROOT/'selfhost/tools/performance/phase125/native'/runner),
 '--image',str(a.image.resolve()),'--runtime',str(ROOT/'selfhost/build/phase128/runtime-borrow01/runtime.o'),
 '--out',str(out),'--references',str(refs),'--seconds','240','--build-seconds','30','--names',*r['names']]
result=subprocess.run(cmd,cwd=ROOT)
if result.returncode:raise SystemExit(result.returncode)
now=json.loads((out/'report.json').read_text())
assert now['complete'] and now['passed'] and now['names']==r['names'] and len(now['rows'])==count
def pin(f):
 f=Path(f).resolve();b=f.read_bytes();return dict(file=str(f),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
(out/'selection.json').write_text(json.dumps(dict(complete=True,expectedCount=count,
 inputs=[pin(__file__),pin(prior),pin(refs),pin(out/'report.json')],command=cmd),indent=2)+'\n')
print(json.dumps(dict(complete=True,count=count,summary=now['summary'])))
