#!/usr/bin/env python3
"""Count the two checked source snapshots; do not execute either compiler."""
import hashlib
import json
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[2]


def identity(path):
    return dict(path=str(path), bytes=path.stat().st_size,
                sha256=hashlib.sha256(path.read_bytes()).hexdigest())


def count(name):
    attempt = ROOT/'selfhost/build'/name
    manifest = json.loads((attempt/'attempt.json').read_text())
    snapshot = attempt/'snapshot'
    config = json.loads((snapshot/'src/compiler.json').read_text())
    sources = [snapshot/p for p in config['modules']]
    lines = [line for p in sources for line in p.read_text().splitlines()]
    runtime = snapshot/'src/runtime.mjs'
    return dict(attempt=identity(attempt/'attempt.json'),
        modules=len(sources), physicalBendLines=len(lines),
        nonblankBendLines=sum(bool(s.strip()) for s in lines),
        definitions=sum(bool(re.match(r'^def\s', s)) for s in lines),
        types=sum(bool(re.match(r'^type\s', s)) for s in lines),
        laws=sum(bool(re.match(r'^law\s', s)) for s in lines),
        runtime={**identity(runtime), 'physicalLines':len(runtime.read_text().splitlines())},
        api=identity(Path(manifest['api']['file'])),
        inputs=[identity(p) for p in sources])


out = Path(sys.argv[1])
assert not out.exists()
data = dict(kind='phase37-checked-source-size', complete=True,
    scope='Physical and nonblank lines in ordered compiler.json Bend modules; column-zero def/type/law counts. Generated assembled runtime counted separately; API is generated code, not authored complexity. No conceptual-complexity score is inferred from these counts.',
    baseline=count('phase36/checked03'), candidate=count('phase37/checked03'))
out.write_text(json.dumps(data, indent=2)+'\n')
print(json.dumps({role:{k:v for k,v in data[role].items() if k not in ['inputs','attempt']}
                  for role in ['baseline','candidate']}))
