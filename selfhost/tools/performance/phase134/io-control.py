#!/usr/bin/env python3
"""Check inherited raw File.write effects against independent bytes; guard externally."""
import hashlib
import json
from pathlib import Path
import subprocess
import sys

def pin(p):
    p=Path(p).resolve(); b=p.read_bytes()
    return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())

binary=Path(sys.argv[1]).resolve(); out=Path(sys.argv[2]).resolve()
assert not out.exists(); out.mkdir(parents=True)
cmd=[str(binary),'--threads','1','--gpu','off']
report=dict(complete=False,inputs=[pin(__file__),pin(binary)],command=cmd,rows=[])
try:
    p=subprocess.run(cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=15)
    assert (p.returncode,p.stdout,p.stderr)==(0,b'one:two\n',b''),(p.returncode,p.stdout,p.stderr)
    report['rows'].append(dict(name='pipe-no-extra-lf',pass_=True))
    dest=out/'redirected.stdout'; dest.write_bytes(b'preserve:')
    with dest.open('ab') as stream:
        p=subprocess.run(cmd,stdout=stream,stderr=subprocess.PIPE,timeout=15)
    assert p.returncode==0 and not p.stderr and dest.read_bytes()==b'preserve:one:two\n'
    report['rows'].append(dict(name='append-preserves-prefix',pass_=True,product=pin(dest)))
    report['complete']=True
finally:
    (out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(report))
