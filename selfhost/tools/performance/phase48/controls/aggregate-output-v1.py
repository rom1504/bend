#!/usr/bin/env python3
"""Lightweight source-byte accounting for the isolated values03 screen; no targets."""
import argparse
import hashlib
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[5]


def identity(p):
    b = p.read_bytes()
    return dict(path=str(p.resolve()), bytes=len(b), sha256=hashlib.sha256(b).hexdigest())


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    paths = [Path(__file__), ROOT / 'selfhost/build/phase48/values-screen03/report.json',
             ROOT / 'selfhost/build/phase48/values-rle03/report.json']
    inputs = [identity(p) for p in paths]
    timing = json.loads(paths[1].read_text())
    assert timing['complete'] and timing['pass'] and len(timing['cases']) == 4
    modules = []
    for name in ['test-rle-roundtrip', 'test-map-set-ops', 'record-aggregation']:
        before = ROOT / f'selfhost/build/phase47/array06-full/modules/{name}.mjs'
        after = ROOT / f'selfhost/build/phase48/values-runtime03/modules/{name}.mjs'
        old, new = identity(before), identity(after)
        inputs.extend([old, new])
        # Join these source observations to actual untouched timed module bytes.
        for role, wanted in [('baseline', old), ('candidate', new)]:
            copied = ROOT / f'selfhost/build/phase48/values-screen03/modules/{role}'
            matches = [p for p in copied.rglob('*.mjs') if p.stat().st_size == wanted['bytes']
                       and identity(p)['sha256'] == wanted['sha256']]
            assert len(matches) == 1, (name, role, 'timed-module identity')
            inputs.append(identity(matches[0]))
        left, right = before.read_bytes().splitlines(keepends=True), after.read_bytes().splitlines(keepends=True)
        assert len(left) == len(right)
        changed = []
        for index, (x, y) in enumerate(zip(left, right)):
            if x == y:
                continue
            mx, my = re.match(rb'^G\[("[^"\n]+")\]=', x), re.match(rb'^G\[("[^"\n]+")\]=', y)
            assert mx and my and mx[1] == my[1], 'Change outside one-line G assignment'
            changed.append(dict(line=index+1, name=json.loads(mx[1]), beforeBytes=len(x), afterBytes=len(y),
                beforeSha256=hashlib.sha256(x).hexdigest(), afterSha256=hashlib.sha256(y).hexdigest(),
                scalarTransportMarker=y.count(b'/* private scalar tuple transport */')))
        assert sum(c['afterBytes']-c['beforeBytes'] for c in changed) == new['bytes']-old['bytes']
        modules.append(dict(name=name, before=old, after=new, deltaBytes=new['bytes']-old['bytes'],
            unchangedOutsideListedAssignmentLines=True, changed=changed))
    cases = []
    for c in timing['cases']:
        s = c['summary']; assert s['complete']
        cases.append(dict(id=c['id'], mediansMs={k:v['medianMs'] for k,v in s['stats'].items()},
            ratios=s['ratios'], sampleRangeMs={k:[v['minimumMs'],v['maximumMs']] for k,v in s['stats'].items()},
            halfDriftPercent={k:[min(v['halfDriftPercent']),max(v['halfDriftPercent'])] for k,v in s['stats'].items()}))
    assert all(identity(Path(x['path'])) == x for x in inputs)
    out = dict(kind='phase48-values03-byte-and-screen-inspection', complete=True, targetExecuted=False,
        inputs=inputs, modules=modules, cases=cases,
        scope='Exact timed-byte comparison plus recorded medians/drift. Markers identify emitted convention, not executed activation. RLE executed witness is separate; no physical allocation or speed causation claim.')
    a.out.parent.mkdir(parents=True, exist_ok=True)
    with a.out.open('x') as f:
        json.dump(out,f,indent=2);f.write('\n')
    print(json.dumps(dict(complete=True, modules=len(modules), report=identity(a.out))))


if __name__ == '__main__':
    main()
