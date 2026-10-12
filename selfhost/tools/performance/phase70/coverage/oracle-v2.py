#!/usr/bin/env python3
"""Independent integer/string specifications; never load a compiler or target."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import sys

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
MASK = 0xffffffff
INITIAL = 2166136261
P37 = ROOT / 'selfhost/tools/performance/phase37/fixtures-new/oracles.py'
spec = importlib.util.spec_from_file_location('phase70_previous_oracles', P37)
previous = importlib.util.module_from_spec(spec)
spec.loader.exec_module(previous)


def hash_words(words):
    value = INITIAL
    for word in words:
        value = ((value * 16777619) ^ word) & MASK
    return value


def array_map(size, seed):
    if not 0 <= size <= 1024:
        raise ValueError('Array-map selection must fit its 1024 cells')
    # Specification of the full 1024-element result, independent of Array.map.
    cells = [((seed + 3 * i) & MASK) if i < size else seed for i in range(1024)]
    return sum(value > 1000 for value in cells)


def tape_observer(size, seed):
    words = []
    for _ in range(size):
        words.append(seed % 257)
        seed = (seed * 1664525 + 1013904223) & MASK
    return (sum(words) & MASK) ^ ((hash_words(words) * 2) & MASK)


def observe_strings(left, right):
    # Python compares Unicode code points, matching the Bend Char ordering.
    order = 1 if left < right else 3 if left > right else 2
    a, b = hash_words(map(ord, left)), hash_words(map(ord, right))
    return ((a ^ ((b * 33) & MASK)) + order) & MASK


def string_order(size, seed):
    pre = ('λ🙂中' + chr(97 + seed % 26)) * size
    pairs = [(pre, pre), (pre, pre + 'a'), (pre + 'a', pre),
             (pre + 'λ', pre + '中'), (pre + '🙂', pre + 'λ'),
             (pre + 'same', pre + 'same'), (pre, '!' + pre), ('!' + pre, pre)]
    return observe_strings(*pairs[seed & 7]) ^ observe_strings('λ🙂', 'λ中')


FUNCTIONS = {'list-pipeline': previous.list_pipeline, 'bst': previous.bst,
             'expression': previous.expression, 'array-map': array_map,
             'tape-observer': tape_observer, 'string-order': string_order}


def points(case):
    return [FUNCTIONS[case['name']]((case['size'] + (i & 1)) & MASK,
                                   (case['seed'] + (i & 15)) & MASK)
            for i in range(16)]


def digest(values, count):
    if len(values) != 16 or any(type(v) is not int or not 0 <= v <= MASK for v in values):
        raise ValueError('Expected sixteen U32 values')
    if type(count) is not int or count < 0:
        raise ValueError('Expected nonnegative integer repetitions')
    h = INITIAL
    for i in range(count):
        h = ((h * 16777619) ^ ((values[i & 15] + i) & MASK)) & MASK
    return h


def identity(path):
    path = Path(path).resolve()
    data = path.read_bytes()
    return dict(path=str(path), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', required=True, type=Path)
    args = parser.parse_args()
    if args.out.exists():
        raise FileExistsError(args.out)
    inputs = [identity(__file__), identity(P37), identity(HERE / 'cases-v2.json')]
    rows = []
    for case in json.loads((HERE / 'cases-v2.json').read_text()):
        source = identity(ROOT / case['source'])
        assert source['sha256'] == case['sha256'], case['name']
        values = points(case)
        assert values[0] == case['expected'], case['name']
        inputs += [source, identity(ROOT / case['wrapper'])]
        for dependency in case.get('dependencies', []):
            actual = identity(ROOT / dependency['path'])
            assert actual['sha256'] == dependency['sha256']
            inputs.append(actual)
        rows.append(dict(name=case['name'], values=values, base=case['expected'],
                         defaultWarmDigest=digest(values, 2), defaultMeasuredDigest=digest(values, 8),
                         smallControls=[dict(size=n, seed=s, expected=FUNCTIONS[case['name']](n, s))
                                        for n, s in [(0, 0), (1, 0), (2, 17), (7, 123)]]))
    for pin in inputs:
        assert identity(pin['path']) == pin
    report = dict(kind='phase70-independent-native-coverage-oracles', complete=True,
                  targetsExecuted=False, cycle=16, inputs=inputs, cases=rows,
                  limits='U32 digests may collide. These are finite specifications, not proof of language coverage.')
    args.out.parent.mkdir(parents=True, exist_ok=True)
    with args.out.open('x') as out:
        json.dump(report, out, indent=2, ensure_ascii=False)
        out.write('\n')
    print(json.dumps(dict(output=identity(args.out), cases=len(rows), targetsExecuted=False)))


if __name__ == '__main__':
    main()
