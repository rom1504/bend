#!/usr/bin/env python3
"""Data-only independent oracles for the unchanged reviewed aggregate fixture."""
import argparse
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
SOURCE = HERE / 'aggregate-transport-v4.bend'
SOURCE_SHA = '51febd83c9f780dfd99252b73621a8c032a022c445f579fbd2000ce41789ec66'
PIN = '018751270e800bc222a93dad7f257083ee53a5f7'
MASK = (1 << 32) - 1


def identity(file):
    data = file.read_bytes()
    return dict(path=str(file.resolve()), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))


def state_oracle(n, seed):
    # Model runs directly; no tuple-transport implementation or generated code.
    previous, runs, total = seed % 5, 1, 0
    for i in range(n):
        value = ((seed + i) & MASK) % 5
        runs += value != previous
        previous = value
        total = (total + value) & MASK
    return (1009 * runs + total) & MASK


def deep_oracle(n, seed):
    # Closed finite sum of all n+1 leaves in the non-tail source recursion.
    return sum((((2 * ((seed + i) & MASK)) & MASK)
                ^ (((seed + i) & MASK) + 1) & MASK)
               for i in range(n + 1)) & MASK


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--receipt', type=Path, required=True)
    a = p.parse_args()
    assert a.out.resolve().parent == HERE, 'Catalog must resolve the unchanged local source'
    before = [identity(Path(__file__)), identity(SOURCE),
              identity(HERE / 'aggregate-transport-catalog-v4.json')]
    assert before[1]['sha256'] == SOURCE_SHA and before[1]['bytes'] == 3506
    original = json.loads((HERE / 'aggregate-transport-catalog-v4.json').read_text())
    assert original['upstreamCommit'] == PIN
    assert state_oracle(0, 3) == 1009 and state_oracle(8, 3) == 8089
    assert deep_oracle(0, 9) == ((18 ^ 10) & MASK)
    cases = []
    for export, seed, oracle in [('bench', 3, state_oracle), ('deep', 9, deep_oracle)]:
        for size in [32, 256, 1024]:
            expected = oracle(size, seed)
            if export == 'bench':
                # These points do not wrap their input seed; every successor differs.
                q, r = divmod(size, 5)
                closed = (1009 * size + q * 10 + sum((seed + i) % 5 for i in range(r))) & MASK
                assert expected == closed
            name = f'aggregate-{export}-{size}'
            cases.append(dict(id=name, family='private-tuple-transport-scale',
                category='diagnostic', partition='development', source=original['cases'][0]['source'],
                point=dict(exportName=export, args=[size, seed], expected=expected),
                sets=['fast', 'core', 'broad', 'full'],
                oracle=('Direct run-count and weighted-value model, cross-checked against periodic sum'
                        if export == 'bench' else 'Independent finite U32 sum of n+1 XOR leaves')))
    names = [c['id'] for c in cases]
    catalog = dict(schemaVersion=1, upstreamCommit=PIN,
        scope='Six diagnostic scale points from the exact reviewed v4 source. Never appended to, reweighted into, or substituted for the unchanged primary 45-point corpus.',
        producer=before[0], semanticCatalog=before[2], cases=cases,
        sets={name:names for name in ['fast', 'core', 'broad', 'full']})
    with a.out.open('x') as stream:
        json.dump(catalog, stream, indent=2); stream.write('\n')
    assert all(identity(Path(x['path'])) == x for x in before)
    receipt = dict(kind='phase48-aggregate-scale-oracles', complete=True, targetExecuted=False,
        inputs=before, catalog=identity(a.out), points=[dict(id=c['id'], **c['point']) for c in cases])
    a.receipt.parent.mkdir(parents=True, exist_ok=True)
    with a.receipt.open('x') as stream:
        json.dump(receipt, stream, indent=2); stream.write('\n')
    print(json.dumps(receipt['points']))


if __name__ == '__main__':
    main()
