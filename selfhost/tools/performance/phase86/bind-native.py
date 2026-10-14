#!/usr/bin/env python3
"""Bind a completed guarded native build to checked C and immutable artifacts."""
import argparse,hashlib,json
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('build',type=Path);p.add_argument('guard',type=Path);p.add_argument('binary',type=Path);a=p.parse_args()
def identity(f):
    f=f.resolve();b=f.read_bytes();return dict(path=str(f),sha256=hashlib.sha256(b).hexdigest(),bytes=len(b))
build=a.build.resolve();guard=a.guard.resolve();binary=a.binary.resolve()
source=json.loads((build/'report.json').read_text());g=json.loads((guard/'process.json').read_text());inputs=json.loads((guard/'inputs.json').read_text())
assert source['complete'] and g['complete']
c=identity(Path(source['c']['file']));assert c['sha256']==source['c']['sha256'] and c in inputs
assert str(binary) in g['command'] and c['path'] in g['command']
for item in inputs:assert identity(Path(item['path']))==item
report=dict(complete=True,source=c,binary=identity(binary),guard=identity(guard/'process.json'),checked=identity(build/'report.json'),inputs=inputs,command=g['command'])
with Path(str(binary)+'.build.json').open('x') as f:json.dump(report,f,indent=2)
print(json.dumps({k:v for k,v in report.items() if k not in ('inputs','command')}))
