#!/usr/bin/env python3
"""Hoist immutable inline eligibility out of the three dependency rounds."""
import argparse
from pathlib import Path
import sys
sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[4]
sys.path.insert(0, str(ROOT / 'selfhost/tools/performance/phase100'))
import run as R

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--parent', type=Path, required=True)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args(); parent = R.read(a.parent)
assert parent['complete'] and parent['inverseExact']
for item in [parent['source'], parent['candidate']]: R.verify(item)
source = Path(parent['candidate']['file']).read_text()
original = source; changes = list(parent['changes']); added = []

def replace(old, new, count=1):
    global source
    assert source.count(old) == count, (old, source.count(old), count)
    start = 0
    for _ in range(count):
        at = source.index(old, start)
        row = dict(offset=at, old=old, new=new); changes.append(row); added.append(row)
        source = source[:at] + new + source[at + len(old):]; start = at + len(new)

replace('@unsafe\ndef nfi_pass(workers: List<&2, NF_Worker>, +ready: List<&2, String>, +previous: List<&2, String>)',
        '@unsafe\ndef nfi_eligible(+ready: List<&2, String>, worker: NF_Worker) -> Bool:\n'
        '  match worker:\n'
        '    case NF_Worker{name, params, code, deps, shape}: nb_contains(ready, name) && nct_within(nc_text(code), 8192)\n\n'
        '@unsafe\ndef nfi_pass(workers: List<&2, NF_Worker>, +previous: List<&2, String>)')
replace('nb_contains(ready, name) && nct_within(nc_text(code), 8192) && nfi_deps(deps, previous)',
        'nfi_deps(deps, previous)')
replace('nfi_pass(rest, ready, previous)', 'nfi_pass(rest, previous)', 2)
replace('  +inline = nfi_pass(no_route_workers(route), no_route_ready(route), nfi_pass(no_route_workers(route), no_route_ready(route), nfi_pass(no_route_workers(route), no_route_ready(route), Nil{})))',
        '  +eligible = List.filter(NF_Worker, nfi_eligible(no_route_ready(route)), no_route_workers(route))\n'
        '  +inline = nfi_pass(eligible, nfi_pass(eligible, nfi_pass(eligible, Nil{})))')
inverse = source
for row in reversed(changes):
    at = row['offset']; assert inverse[at:at + len(row['new'])] == row['new']
    inverse = inverse[:at] + row['old'] + inverse[at + len(row['new']):]
assert inverse == Path(parent['source']['file']).read_text()
out = a.out.resolve(); out.mkdir(parents=True, exist_ok=False)
dest = out / 'compiler.bend'; dest.write_text(source)
R.save(out / 'changes.json', dict(complete=True, targetsRun=False, releaseQualified=False,
    method=R.pin(__file__), parentRecipe=R.pin(a.parent), parentCandidate=parent['candidate'],
    source=parent['source'], candidate=R.pin(dest), changes=changes, addedChanges=added,
    inverseExact=True, physicalLineDelta=len(source.splitlines()) - len(original.splitlines()),
    scope='Stable filter hoists unchanged admission-membership/8192-codepoint predicates '
          'once. Three immutable dependency rounds traverse the same eligible workers '
          'in original order. Hint sets, admission and emitted bodies are intended identical; '
          'actual checked emission and focused controls remain required.'))
print(R.json.dumps(R.pin(dest)))
