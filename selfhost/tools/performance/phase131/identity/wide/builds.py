"""Build four already verified tiny QBE products; exact ordinary outputs."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess

ROOT=Path(__file__).resolve().parents[6];HERE=Path(__file__).resolve().parent
def pin(p):
    p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
assert sorted(os.sched_getaffinity(0))==[5]
out=a.out.resolve();assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase131')
out.mkdir();r=dict(complete=False,inputs=[pin(__file__),pin(HERE/'oracle.json'),pin(HERE/'expected.stdout')],rows=[])
def save():(out/'report.json').write_text(json.dumps(r,indent=2)+'\n')
save()
try:
    for role in ['baseline','candidate']:
        emission=ROOT/f'selfhost/build/phase118/p131-wide-{role}-emit01/report.json'
        e=json.loads(emission.read_text());assert e['complete'];r['inputs'].append(pin(emission))
        for case in e['cases']:
            assert case['verified'] and case['parentVerified']
            build=ROOT/f'selfhost/build/phase111/p131-wide-{role}-{case["name"]}01'
            cmd=['python3',str(ROOT/'selfhost/tools/performance/phase123/build-aligned.py'),
                 '--source',case['qbe']['file'],'--runtime',e['runtime']['file'],'--out',str(build),
                 '--expected',str(HERE/'expected.stdout'),'--seconds','20']
            row=dict(role=role,case=case['name'],command=cmd);r['rows'].append(row);save()
            child=subprocess.run(cmd,capture_output=True,timeout=30)
            row.update(exitCode=child.returncode,stdout=child.stdout.decode(),stderr=child.stderr.decode());save()
            assert child.returncode==0
            receipt=json.loads((build/'report.json').read_text());assert receipt['complete'] and receipt['outputExact']
            row['build']=pin(build/'report.json');row['binary']=receipt['binary'];save()
    r['complete']=True;save()
except BaseException as e:r['error']=repr(e);save();raise
print(json.dumps(dict(complete=True,builds=len(r['rows']))))
