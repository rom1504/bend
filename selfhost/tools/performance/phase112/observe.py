#!/usr/bin/env python3
"""Observe one bounded native control against a frozen status/stdout/stderr."""
import argparse,hashlib,json,os,subprocess,time
from pathlib import Path
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--binary',type=Path,required=True);p.add_argument('--expected',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
assert sorted(os.sched_getaffinity(0))==[3] and not a.out.exists()
def pin(f):
 f=f.resolve();b=f.read_bytes();return dict(file=str(f),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
expected=json.loads(a.expected.read_text());inputs=[pin(a.binary),pin(a.expected),pin(Path(__file__))];a.out.mkdir()
start=time.monotonic();c=subprocess.run([str(a.binary.resolve()),'--threads','1','--gpu','off'],stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=10)
actual=dict(status=c.returncode,stdout=c.stdout.decode(),stderr=c.stderr.decode());good=actual==expected
(a.out/'stdout').write_bytes(c.stdout);(a.out/'stderr').write_bytes(c.stderr)
(a.out/'report.json').write_text(json.dumps(dict(complete=good,inputs=inputs,expected=expected,actual=actual,seconds=time.monotonic()-start),indent=2)+'\n')
assert good,(actual,expected)
print(json.dumps(dict(complete=True,status=c.returncode)))
