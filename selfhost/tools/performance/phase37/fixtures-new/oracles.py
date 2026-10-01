#!/usr/bin/env python3
"""Independent output references and frozen Phase37 application point proposal.

This reads fixture bytes but never imports a Bend compiler or generated module.
Root runs it before acquisition. It refuses to replace an existing proposal.
"""
import argparse
import hashlib
import json
from pathlib import Path
import struct

HERE = Path(__file__).resolve().parent
MASK = 2**32 - 1


def u32(value):
    return value & MASK


def f32(value):
    return struct.unpack('<f', struct.pack('<f', value))[0]


def closures(size, seed):
    return u32(seed + size * (size + 1) // 2)


def list_pipeline(size, seed):
    values = []
    for _ in range(size):
        values.append(seed % 16)
        seed = u32(seed * 1664525 + 1013904223)
    return u32(sum(2 * value for value in values if value > 1))


def bst(size, seed):
    # Sorting is an independent specification for insertion + inorder traversal.
    values = sorted(u32(u32(i * u32(seed * 2 + 1)) + seed) % 257
                    for i in range(size))
    acc = 0
    for value in values:
        acc = u32(acc * 10 + value)
    return acc


def unicode_text(size, seed):
    # Native code-point strings; no port of the recursive split/join machinery.
    return (('α,β,🍎,中,' + str(seed) + ',') * size).replace(',', '|')


def expression(size, seed):
    # Evaluate the generating algebra bottom-up without constructing an AST.
    value = u32(seed + size)
    for index in reversed(range(size)):
        word = u32(seed + index)
        if word % 3 == 0:
            value = u32(value + u32(word * 3))
        elif word % 3 == 1:
            value = u32(value * (word % 5 + 1))
        else:
            value = u32(value - u32(word + 7))
    return value


def map_churn(size, seed):
    content = {'key' + str(i): u32(seed + i * 17) for i in range(size)}
    for i in range(0, size, 3):
        content['key' + str(i)] = seed ^ u32(i * 31)
    for i in range(0, size, 4):
        del content['key' + str(i)]
    acc = 2166136261
    for key in sorted(content):
        for char in key:
            acc = u32(acc * 31 + ord(char))
        acc = u32(acc * 16777619) ^ content[key]
    return acc


def numeric_recurrence(size, seed):
    x = f32(f32(seed % 97 + 1) / f32(100.0))
    result = seed
    for _ in range(size):
        x = f32(f32(f32(3.75) * x) * f32(f32(1.0) - x))
        result = u32(result * 16777619) ^ int(f32(x * f32(1000000.0)))
    return result


def record_aggregation(size, seed):
    totals = {}
    for i in range(size):
        key = '部門' + str(u32(i + seed) % 16)
        amount_text = str(u32(u32(i * 37) + seed) % 1000)
        totals[key] = u32(totals.get(key, 0) + int(amount_text))
    return ''.join(key + '=' + str(totals[key]) + ';' for key in sorted(totals))


FAMILIES = [
    dict(family='closures', function=closures, points=[(64, 17), (256, 123)],
         partition='development', description='Build and apply captured closure composition chains',
         scope='size captured affine closures; generated chain and invocation both timed',
         oracle='Closed-form seed + n(n+1)/2 modulo 2^32; no generated code or recursive closure interpreter.',
         coverage=['higher-order', 'captured-values', 'function-construction', 'Nat-recursion']),
    dict(family='list-pipeline', function=list_pipeline, points=[(128, 17), (512, 123)],
         partition='development', description='Generate, filter, map and fold a word list',
         scope='size LCG words; remove 0/1, double remaining words, sum all retained elements',
         oracle='Python list comprehension over an integer LCG and mathematical sum modulo 2^32.',
         coverage=['linear-list', 'constructor-churn', 'filter', 'composed-traversals', 'U32-wrapping']),
    dict(family='bst', function=bst, points=[(32, 0), (64, 17)],
         partition='holdout', description='Zipper insertion and traversal of skewed or irregular BSTs',
         scope='size insertion values modulo257; seed0 is ascending/skewed, seed17 is irregular; fuel=size+1',
         oracle='Independently sort generated values, then fold decimal positional digest modulo 2^32.',
         coverage=['irregular-tree', 'skewed-tree', 'zipper', 'tuple-state', 'insertion', 'ordered-fold']),
    dict(family='unicode-text', function=unicode_text, points=[(16, 17), (64, 123)],
         partition='development', description='Build, split and join mixed-script Unicode text',
         scope='size blocks containing Greek, supplementary-plane emoji, CJK, decimal seed and separators; complete string observed',
         oracle='Python code-point string repetition and delimiter replacement; complete output equality.',
         coverage=['Unicode', 'supplementary-plane', 'String', 'list-of-strings', 'split-join']),
    dict(family='expression', function=expression, points=[(32, 17), (128, 123)],
         partition='holdout', description='Construct and interpret an unbalanced arithmetic expression AST',
         scope='size nested expression layers; variable Add/Mul/Sub dispatch and small side trees; U32 wrapping',
         oracle='Independent bottom-up scalar recurrence; no AST allocation or recursive evaluator.',
         coverage=['AST', 'unbalanced-tree', 'sum-types', 'producer-consumer', 'U32-wrapping']),
    dict(family='map-churn', function=map_churn, points=[(32, 17), (128, 123)],
         partition='development', description='Build, replace, delete and traverse a larger string-key map',
         scope='size distinct keys; replace every third key; delete every fourth; digest every remaining ordered key and value',
         oracle='Python dictionary, lexical ordering and independent wrapping content digest.',
         coverage=['Map', 'many-keys', 'replacement', 'deletion', 'ordered-traversal', 'String-formatting']),
    dict(family='numeric-recurrence', function=numeric_recurrence, points=[(256, 17), (1024, 123)],
         partition='development', description='F32 nonlinear recurrence with wrapping word observation',
         scope='size logistic recurrence steps; round each operation to binary32; incorporate every intermediate value into U32 digest',
         oracle='Python struct binary32 rounding after each primitive, Python integer U32 wrapping; exact scalar equality.',
         coverage=['F32-rounding', 'F32-U32-conversion', 'numeric-loop', 'Nat-counter', 'U32-wrapping']),
    dict(family='record-aggregation', function=record_aggregation, points=[(64, 17), (256, 123)],
         partition='holdout', description='Generate textual records, parse amounts, aggregate and render a report',
         scope='size records;16 Unicode department keys; decimal parsing; whole ordered report observed; in-memory, not CSV or IO throughput',
         oracle='Independent Python integer/dictionary aggregation and full ordered report string.',
         coverage=['composed-application', 'text-number-parsing', 'Map', 'Unicode', 'list-of-records', 'report-formatting']),
]


def identity(path):
    data = path.read_bytes()
    return dict(sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    if args.out.exists():
        raise SystemExit('Refusing to overwrite proposal: ' + str(args.out))
    original = {row['family']: row for row in json.loads((HERE / 'upstream-provenance.json').read_text())}
    cases, validation = [], []
    for row in FAMILIES:
        family = row['family']
        path = HERE / (family + '.bend')
        actual = identity(path)
        if family in original:
            source = original[family]
            if any(source[key] != actual[key] for key in ['sha256', 'bytes']):
                raise ValueError('Fixture changed after upstream copy: ' + family)
            provenance = source['provenance']
            original_bytes = provenance['original']['bytes']
            if hashlib.sha256(path.read_bytes()[:original_bytes]).hexdigest() != provenance['original']['sha256']:
                raise ValueError('Pinned original prefix changed: ' + family)
        else:
            provenance = dict(kind='phase37-authored-application',
                              description='Independent program authored before candidate optimization; pinned Base imported unchanged.',
                              record='design/phase37/applications.md')
        for size, seed in row['points']:
            cases.append(dict(id='coverage-' + family + '-' + str(size), family=family,
                              category='coverage', partition=row['partition'],
                              description=row['description'], scope=row['scope'],
                              source=dict(path='fixtures-new/' + path.name, **actual, provenance=provenance),
                              point=dict(exportName='bench', args=[size, seed], expected=row['function'](size, seed)),
                              oracle=row['oracle'], coverage=row['coverage'],
                              sets=['coverage', 'coverage-' + row['partition']]))
        for size, seed in [(0, 0), (1, 0), (2, 17), (7, 123)]:
            validation.append(dict(family=family, exportName='bench', args=[size, seed], expected=row['function'](size, seed)))
    output = dict(kind='phase37-application-point-proposal', schemaVersion=1,
                  upstreamCommit='018751270e800bc222a93dad7f257083ee53a5f7',
                  oracle=identity(Path(__file__)), cases=cases, validationPoints=validation,
                  observationLimits='Digest outputs can collide. Only Unicode and aggregation observe complete returned strings. These references are independent executable specifications, not proofs of compiler correctness or representativeness.')
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(json.dumps(output, indent=2, ensure_ascii=False) + '\n')
    print(json.dumps(dict(complete=True, points=len(cases), validationPoints=len(validation), out=str(args.out))))


if __name__ == '__main__':
    main()
