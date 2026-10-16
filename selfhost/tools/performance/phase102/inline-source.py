#!/usr/bin/env python3
"""Compose one bounded NF inlining-budget change onto a reversible source recipe."""
import argparse
from pathlib import Path
import sys
sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[4]
sys.path.insert(0, str(ROOT/'selfhost/tools/performance/phase100'))
import run as R

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--parent', type=Path, required=True)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args(); out = a.out.resolve(); out.mkdir(parents=True, exist_ok=False)
parent = R.read(a.parent); assert parent['complete']
for item in [parent['source'], parent['candidate']]: R.verify(item)
source = Path(parent['candidate']['file']).read_text()
old = 'nct_within(nc_text(code), 4096)'
assert source.count(old) == 1
at = source.index(old); new = old.replace('4096', '8192')
result = source[:at]+new+source[at+len(old):]
changes = parent['changes'] + [dict(offset=at, old=old, new=new)]
reverse = result
for c in reversed(changes):
    i = c['offset']; assert reverse[i:i+len(c['new'])] == c['new']
    reverse = reverse[:i]+c['old']+reverse[i+len(c['new']):]
assert reverse == Path(parent['source']['file']).read_text()
dest = out/'compiler.bend'; dest.write_text(result)
R.save(out/'changes.json', dict(complete=True, targetsRun=False, releaseQualified=False,
    method=R.pin(__file__), parentRecipe=R.pin(a.parent), parentCandidate=parent['candidate'],
    source=parent['source'], candidate=R.pin(dest), changes=changes, inverseExact=True,
    physicalLineDelta=len(result.splitlines())-len(reverse.splitlines()),
    scope='NF size hint4096→8192 only. Admission unchanged. No transitive code-growth bound; compiler-image build cost remains a separate gate.'))
print(R.json.dumps(R.pin(dest)))
