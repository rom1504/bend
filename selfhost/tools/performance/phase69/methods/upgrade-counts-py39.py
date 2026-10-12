#!/usr/bin/env python3
"""Preserve strict equal-length checks without Python3.10 zip(strict=True)."""
import ast
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent


def pin(p):
    b = p.read_bytes()
    return dict(file=str(p), sha256=hashlib.sha256(b).hexdigest(), bytes=len(b))


parent, output = HERE/'count-selected.py', HERE/'count-selected-v2.py'
text = parent.read_text()
edits = [
    ("    sites = [a-b for a,b in zip(high['allocationSites'], low['allocationSites'], strict=True)]",
     "    assert len(high['allocationSites']) == len(low['allocationSites'])\n    sites = [a-b for a,b in zip(high['allocationSites'], low['allocationSites'])]"),
    ("    top = sorted((dict(site=site, addedCalls=count) for site,count in zip(item['sites'],sites,strict=True)",
     "    assert len(item['sites']) == len(sites)\n    top = sorted((dict(site=site, addedCalls=count) for site,count in zip(item['sites'],sites)")]
for old,new in edits:
    assert text.count(old) == 1
    text = text.replace(old,new)
assert 'strict=True' not in text
ast.parse(text, feature_version=9)
with output.open('x') as f:
    f.write(text)
with output.with_suffix('.derivation.json').open('x') as f:
    json.dump(dict(kind='phase69-counter-python39-successor', parent=pin(parent), output=pin(output),
                   producer=pin(Path(__file__).resolve()),
                   edits=[dict(before=x,after=y,count=1) for x,y in edits],
                   dataOnly=True, targetsExecuted=False,
                   scope='Only replace both Python3.10 strict zip calls by preceding equal-length assertions and ordinary zip. Instrumentation, target commands, caching/provenance, operation counts and oracles remain unchanged. The failed first count campaign stays immutable.'), f, indent=2)
    f.write('\n')
print(json.dumps(pin(output)))
