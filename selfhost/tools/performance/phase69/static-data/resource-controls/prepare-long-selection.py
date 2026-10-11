#!/usr/bin/env python3
"""Freeze one actual long-String native control; never executes a target."""
import argparse, hashlib, json
from pathlib import Path
HERE = Path(__file__).resolve().parent

def pin(path):
    path=path.resolve(strict=True)
    data=path.read_bytes()
    return dict(file=str(path),sha256=hashlib.sha256(data).hexdigest(),bytes=len(data))

p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--out', type=Path, required=True)
a=p.parse_args()
source=HERE/'long-string-2000.bend'
name='phase69/static-data/resource-controls/long-string-2000.bend'
golden=[line[2:] for line in source.read_text().splitlines() if line.startswith('#|')]
assert golden==['4000n']
with a.out.open('x') as f:
    json.dump(dict(cases=[dict(id=name,file=str(source),lanes=['native'])]),f,indent=2)
    f.write('\n')
with a.out.with_suffix('.manifest.json').open('x') as f:
    json.dump(dict(kind='phase69-static-long-literal-selection',producer=pin(Path(__file__)),selection=pin(a.out),expectedCases=1,sources=[dict(id=name,source=pin(source),goldenLines=golden)],dataOnly=True,targetsExecuted=False),f,indent=2)
    f.write('\n')
print(json.dumps(dict(selection=pin(a.out),expectedCases=1,targetsExecuted=False)))
