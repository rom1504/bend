#!/usr/bin/env python3
"""Freeze the affine callback fixture and independent integer expectations."""
import argparse
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
SOURCE = HERE / 'callback-fixture.bend'
PIN = '018751270e800bc222a93dad7f257083ee53a5f7'


def values(size, seed):
    state = seed
    result = []
    for position in range(size):
        offset = (seed + size - position - 1) & 0xffffffff
        result.append(((state & 65535) + offset) & 0xffffffff)
        state = (state * 1664525 + 1013904223) & 0xffffffff
    return result


parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--out', type=Path, required=True)
args = parser.parse_args()
assert args.out.resolve().parent == HERE.resolve(), 'Catalog sources resolve against this directory'
assert not args.out.exists()
data = SOURCE.read_bytes()
source = dict(path=SOURCE.name, bytes=len(data), sha256=hashlib.sha256(data).hexdigest(),
              provenance=dict(kind='phase39-authored-affine-callback-control',
                              design='design/phase39/callbacks.md'))
points = [(64, 17), (256, 1234567)]
cases = [dict(id=f'callback-affine-{n}-{seed}', category='diagnostic',
              description='Affine scalar captures over materialized callback/input/result lists',
              source=source, point=dict(exportName='bench', args=[n, seed], expected=sum(values(n, seed)) & 0xffffffff),
              sets=['fast', 'core', 'broad', 'full'], partition='development', family='affine-callback',
              oracle='Independent Python U32 recurrence; full small lists also retained') for n, seed in points]
controls = [dict(args=[n, seed], result=values(n, seed), expected=sum(values(n, seed)) & 0xffffffff)
            for n, seed in [(0, 0), (1, 17), (3, 123), (15, 0xffffffff), (17, 19), (31, 2147483647)]]
catalog = dict(schemaVersion=1, upstreamCommit=PIN,
               scope='New mechanism fixture, not an extension of frozen Phase37 coverage or evidence of real-world prevalence.',
               cases=cases, sets={name:[c['id'] for c in cases] for name in ['fast','core','broad','full']},
               validationPoints=controls,
               oracleProducer=dict(path=Path(__file__).name, sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest()))
args.out.write_text(json.dumps(catalog, indent=2)+'\n')
print(json.dumps(dict(complete=True, out=str(args.out), points=len(cases), completeListControls=len(controls))))
