"""Authenticated ceiling sources and independent finite output controls.

Version one is retained unchanged: helper definitions followed bench and the
first emission rejected that forward use. Version two defines helpers first.
This generator runs no compiler, executable or timing measurement.
"""
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
OLD = HERE.parent / 'diagnostic'
MANIFEST = ROOT / 'selfhost/tools/performance/phase112/benchmark45/manifest01.json'


def pin(path):
    raw = path.read_bytes()
    return {'file': str(path), 'bytes': len(raw), 'sha256': hashlib.sha256(raw).hexdigest()}


def save(path, text):
    if path.exists():
        assert path.read_text() == text, f'refuse to overwrite {path}'
    else:
        path.write_text(text)
    return pin(path)


def json_save(path, value):
    return save(path, json.dumps(value, indent=2) + '\n')


cases = json.loads(MANIFEST.read_text())['cases']
rows = []
prefixes = {}
for case in cases:
    name = case['name']
    if name not in ['coverage-list-pipeline-128', 'coverage-list-pipeline-512',
                    'coverage-map-churn-32', 'coverage-map-churn-128']:
        continue
    source = Path(case['source']['file'])
    assert pin(source) == case['source']
    text = source.read_text()
    prefix, suffix = text.split('# Phase93:', 1)
    prefixes['list' if 'list-pipeline' in name else 'map'] = prefix
    if 'list-pipeline' in name:
        old = '  suma(dbl(keep_gt1(p37.list(U32.to_nat(size), seed))), 0)'
        variants = [
            ('mapfold', 'list-mapfold-helper.bend',
             '  p121.mapfold(keep_gt1(p37.list(U32.to_nat(size), seed)), 0)'),
            ('full', 'list-full-helper.bend', '  p121.pipeline(U32.to_nat(size), seed, 0)'),
        ]
    else:
        old = '  p37.map.digest(Map.to_list(&2, U32, m), 2166136261)'
        variants = [('treefold', 'map-digest-helper.bend', '  p121.map_digest(m, 2166136261)')]
    assert text.count(old) == 1
    before_bench, bench = prefix.split('def bench(', 1)
    for variant, helper_name, replacement in variants:
        helper = OLD / helper_name
        target = HERE / (name + '-' + variant + '.bend')
        result = before_bench + helper.read_text() + '\ndef bench(' + bench.replace(old, replacement) + '# Phase93:' + suffix
        assert result.split('# Phase93:', 1)[1] == suffix
        rows.append({'name': name, 'variant': variant, 'source': save(target, result),
                     'original': case['source'], 'helper': pin(helper),
                     'rejectedV1': pin(OLD / target.name),
                     'runtimeArgs': case['runtimeArgs'], 'expectedStdout': case['expectedStdout'],
                     'expectedStdoutEvidence': case['expectedStdoutEvidence'],
                     'manifestRepetitions': case['repetitions'], 'manifestWarmups': case['warmups'],
                     'wrapperSuffixSha256': hashlib.sha256(suffix.encode()).hexdigest()})


MASK = (1 << 32) - 1


def list_model(size, seed):
    # Independent imperative arithmetic model, no Bend/compiler calls.
    answer = 0
    for _ in range(size):
        head = seed % 16
        seed = ((seed * 1664525 & MASK) + 1013904223) & MASK
        if head > 1:
            answer = (answer + (head * 2 & MASK)) & MASK
    return answer


def map_model(size, seed):
    # Independent dictionary model. Map.bit's presence bit then MSB-first
    # character bits means lo-before-hi yields ordinary lexicographic key order.
    values = {'key' + str(i): (seed + i * 17) & MASK for i in range(size)}
    for i in range(0, size, 3):
        values['key' + str(i)] = seed ^ (i * 31 & MASK)
    for i in range(0, size, 4):
        values.pop('key' + str(i), None)
    answer = 2166136261
    for key in sorted(values):
        for char in key:
            answer = (answer * 31 + ord(char)) & MASK
        answer = ((answer * 16777619) & MASK) ^ values[key]
    return answer


# Cross-check the independent arithmetic/dictionary models against existing
# frozen outputs before writing any new expectation.
for case in cases:
    if case['name'] in [row['name'] for row in rows]:
        model = list_model if 'list-pipeline' in case['name'] else map_model
        assert str(model(*case['runtimeArgs'])) + '\n' == case['expectedStdout']


controls = []
for kind, sizes in [('list', [0, 1, 2, 17, 257]), ('map', [0, 1, 2, 17, 129])]:
    prefix = '\n'.join(line for line in prefixes[kind].splitlines() if not line.startswith('#|')) + '\n'
    if kind == 'list':
        helpers = ['list-mapfold-helper.bend', 'list-full-helper.bend']
        prefix += '\n' + '\n'.join((OLD / name).read_text() for name in helpers)
        prefix += '''
def p121.mapfold_bench(size: U32, seed: U32) -> U32:
  p121.mapfold(keep_gt1(p37.list(U32.to_nat(size), seed)), 0)

def p121.full_bench(size: U32, seed: U32) -> U32:
  p121.pipeline(U32.to_nat(size), seed, 0)
'''
        variants = ['bench', 'p121.mapfold_bench', 'p121.full_bench']
        model = list_model
    else:
        helpers = ['map-digest-helper.bend']
        prefix += '\n' + (OLD / helpers[0]).read_text() + '\n'
        body = prefixes[kind].split('def bench(', 1)[1]
        body = body.replace('p37.map.digest(Map.to_list(&2, U32, m), 2166136261)', 'p121.map_digest(m, 2166136261)')
        prefix += 'def p121.treefold_bench(' + body
        variants = ['bench', 'p121.treefold_bench']
        model = map_model
    calls = []
    expected = []
    samples = []
    for size in sizes:
        for seed in [0, 1, MASK]:
            answer = model(size, seed)
            values = [str(size), str(seed), *[str(answer)] * len(variants)]
            expected.extend(values)
            samples.append({'size': size, 'seed': seed, 'expectedValue': answer,
                            'valueCopies': len(variants)})
            calls.extend([f'    Unit <- IO.print(U32.show({size}))',
                          f'    Unit <- IO.print(U32.show({seed}))'])
            calls.extend(f'    Unit <- IO.print(U32.show({name}({size}, {seed})))' for name in variants)
    calls[-1] = calls[-1].replace('Unit <- ', '', 1)
    source = prefix + '\ndef main() -> IO(Unit):\n  do IO<Unit>:\n' + '\n'.join(calls) + '\n'
    controls.append({'kind': kind, 'source': save(HERE / (kind + '-controls.bend'), source),
                     'expected': save(HERE / (kind + '-controls.expected.stdout'), '\n'.join(expected) + '\n'),
                     'rows': samples, 'columns': ['size', 'seed', *variants],
                     'helpers': [pin(OLD / name) for name in helpers],
                     'oracle': 'Independent Python arithmetic/dictionary model; exact frozen parent outputs cross-checked.'})

out = {'kind': 'phase121-source-specialized-ceiling-diagnostics-v2', 'targetRuns': False,
       'compilerTransformation': False, 'manifest': pin(MANIFEST), 'generator': pin(Path(__file__)),
       'rejectedV1Manifest': pin(OLD / 'manifest.json'), 'cases': rows, 'controls': controls}
json_save(HERE / 'manifest.json', out)
print(json.dumps({'sources': len(rows), 'controls': len(controls), 'targetRuns': False}))
