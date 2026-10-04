#!/usr/bin/env python3
"""Independent Phase46 batch oracles; no compiler or generated program imports.

Usage: python3 oracle.py --out FRESH_MANIFEST.json
points(case) returns the sixteen workload results in input-cycle order.
digest(values, count) reproduces the wrapping observer, not the benchmark.
"""
import argparse
import functools
import hashlib
import importlib.util
import json
from pathlib import Path
import sys

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
MASK = 0xffffffff
INITIAL = 2166136261
ORACLE_FILES = [
    HERE.parent / 'phase37/fixtures-new/oracles.py',
    HERE.parent / 'phase37/algorithm-oracles.py',
    HERE.parent / 'phase37/coverage-catalog.py',
]


def identity(file):
    file = Path(file).resolve()
    data = file.read_bytes()
    return {'path': str(file), 'canonicalPath': str(file),
            'sha256': hashlib.sha256(data).hexdigest(), 'bytes': len(data)}


@functools.lru_cache(maxsize=1)
def functions():
    modules = []
    for index, file in enumerate(ORACLE_FILES):
        spec = importlib.util.spec_from_file_location('phase46_oracle_' + str(index), file)
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        modules.append(module)
    app, algorithms, coverage = modules
    return {'numeric': app.numeric_recurrence, 'closures': app.closures,
            'tree': algorithms.bitonic, 'array': coverage.fold,
            'map': app.map_churn, 'lexer': algorithms.lexer}


def points(case):
    oracle = functions()[case['name']]
    return [oracle((case['size'] + (i & 1)) & MASK,
                   (case['seed'] + (i & 15)) & MASK) for i in range(16)]


def digest(values, count):
    if len(values) != 16 or any(type(v) is not int or not 0 <= v <= MASK for v in values):
        raise ValueError('Expected sixteen U32 oracle results')
    if type(count) is not int or count < 0:
        raise ValueError('Expected a nonnegative iteration count')
    h = INITIAL
    for i in range(count):
        h = ((h * 16777619) ^ ((values[i & 15] + i) & MASK)) & MASK
    return h


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', required=True, type=Path)
    args = parser.parse_args()
    output = args.out.resolve()
    if output.exists():
        raise FileExistsError('Refusing to replace oracle manifest: ' + str(output))
    inputs = [identity(Path(__file__)), identity(HERE / 'cases.json'),
              identity(HERE / 'make-batch.py'), *map(identity, ORACLE_FILES)]
    cases = json.loads((HERE / 'cases.json').read_text())
    rows = []
    for case in cases:
        source = identity(ROOT / case['source'])
        if source['sha256'] != case['sha256']:
            raise ValueError('Changed fixture: ' + case['name'])
        values = points(case)
        if values[0] != case['expected']:
            raise ValueError('Independent base oracle differs: ' + case['name'])
        wrapper = identity(HERE / (case['name'] + '-batch.bend'))
        inputs.extend([source, wrapper])
        rows.append({'name': case['name'], 'source': source, 'wrapper': wrapper,
                     'size': case['size'], 'seed': case['seed'],
                     'base': case['expected'], 'values': values,
                     'defaultWarmDigest': digest(values, 2),
                     'defaultMeasuredDigest': digest(values, 8)})
    for before in inputs:
        if identity(before['path']) != before:
            raise ValueError('Oracle input changed during calculation: ' + before['path'])
    report = {'kind': 'phase46-independent-batch-oracles', 'version': 1,
              'complete': True, 'producer': inputs[0], 'inputs': inputs,
              'cycle': 16, 'initial': INITIAL, 'multiplier': 16777619,
              'schedule': 'size+(i&1), seed+(i&15), both wrapping U32',
              'digest': 'h=((h*16777619)^((values[i&15]+i)&0xffffffff))&0xffffffff',
              'cases': rows}
    with output.open('x') as stream:
        stream.write(json.dumps(report, indent=2) + '\n')
    print(json.dumps({'complete': True, 'cases': len(rows), 'oraclePoints': len(rows) * 16,
                      'output': identity(output)}))


if __name__ == '__main__':
    main()
