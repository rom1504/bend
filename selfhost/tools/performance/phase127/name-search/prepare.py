#!/usr/bin/env python3
"""Freeze the unchanged compiler-search kernel and an independent host set oracle."""
import hashlib
import json
from pathlib import Path
import re

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
SOURCE = ROOT / 'selfhost/build/phase126/observer-divmod-source32/compiler.bend'
SOURCE_SHA = '40c469114c4d1c75dceab456e1979bb5c0278744a02e6dbe4a37e63667740abb'
FUNCTIONS = ['p88_string_eq_go', 'p98_eq_finish', 'p88_string_eq', 'has_name', 'has_name_next']
MASK = (1 << 32) - 1


def pin(path):
    path = Path(path).resolve(); data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def freeze(path, data):
    if isinstance(data, str):
        data = data.encode('utf-8')
    if path.exists():
        if path.read_bytes() != data:
            raise ValueError('Refusing to change frozen output: ' + str(path))
    else:
        path.write_bytes(data)
    return pin(path)


def save(path, data):
    return freeze(path, json.dumps(data, indent=2, ensure_ascii=False) + '\n')


def extract(lines, name):
    starts = [i for i, line in enumerate(lines) if re.match(r'^def ' + re.escape(name) + r'\(', line)]
    if len(starts) != 1:
        raise ValueError('Unique definition required: ' + name)
    start = starts[0]
    first = start - 1 if start and lines[start - 1].strip() == '@unsafe' else start
    end = start + 1
    while end < len(lines) and (not lines[end].strip() or lines[end][0].isspace() or lines[end].startswith(') -> ')):
        end += 1
    while not lines[end - 1].strip():
        end -= 1
    text = ''.join(lines[first:end])
    return text, dict(name=name, firstLine=first + 1, lastLine=end,
                     bytes=len(text.encode()), sha256=hashlib.sha256(text.encode()).hexdigest(), renamed=False)


def digest(corpus, size):
    name = lambda i: corpus[i % 16] + '.' + str(i)
    names = [name(i) for i in range(size)] + ['λ.compiler.α', '路径.查找']
    queries = [names[0], name(0), names[size // 2], name((size - 1) & MASK), name(size), 'p113pl',
               name(size) + '.absent', 'λ.compiler.α', 'λ.compiler.β', '路径.查找', names[0], '_absent', name(7), name(63)]
    members = set(names)
    hits = [query in members for query in queries]
    result = 2166136261
    for hit in hits:
        result = (result * 16777619 + int(hit)) & MASK
    return dict(size=size, names=len(names), queries=queries, hits=hits, digest=result)


def main():
    source = pin(SOURCE)
    if source['sha256'] != SOURCE_SHA:
        raise ValueError('Pinned compiler source changed')
    text = SOURCE.read_text(); lines = text.splitlines(keepends=True)
    extracted = [extract(lines, name) for name in FUNCTIONS]
    corpus = list(dict.fromkeys(re.findall(r'^def (p113pl_[A-Za-z0-9_]+)\(', text, re.M)))[:16]
    if len(corpus) != 16:
        raise ValueError('Expected sixteen distinct real compiler names')
    corpus_text = 'def p127ns_corpus() -> List<&2,String>:\n  [' + ','.join(json.dumps(x) for x in corpus) + ']\n'
    workload = (HERE / 'workload.bend').read_text()
    benchmark = 'import Base\n\n# Exact Phase126 function extraction; no candidate optimization.\n\n' + '\n'.join(x[0] for x in extracted) + '\n' + corpus_text + '\n' + workload
    benchmark_pin = freeze(HERE / 'benchmark.bend', benchmark)
    controls = [digest(corpus, n) for n in [0, 1, 17, 128]]
    output = ''.join(str(row['digest']) + '\n' for row in controls)
    expected = save(HERE / 'expected.json', dict(status=0, stdout=output, stderr=''))
    stdout = freeze(HERE / 'expected.stdout', output)
    cases = save(HERE / 'cases.json', dict(complete=True, cases=[dict(name='compiler-name-search',
        source=benchmark_pin, expected=expected, expectedStdoutEvidence=expected)]))
    timed = []
    for repetitions, warmups, size in [(32, 2, 64), (64, 2, 256), (128, 2, 1024)]:
        row = digest(corpus, size)
        prefix = ''.join(str(n) + '\n' for n in [row['digest'], (row['digest'] * warmups) & MASK,
                                                (row['digest'] * repetitions) & MASK])
        timed.append(dict(argv=list(map(str, [repetitions, warmups, size, 0])),
            expected=dict(exitCode=0, stdout=dict(kind='prefix-integer-line', prefix=prefix),
                          stderr=dict(kind='exact', bytes=0, sha256=hashlib.sha256(b'').hexdigest())),
            workload=row, calibrated=False))
    save(HERE / 'oracle.json', dict(kind='phase127-independent-name-search-oracle', frozenBeforeExecution=True,
        inputs=[source, pin(__file__), pin(HERE / 'workload.bend')], extracted=[x[1] for x in extracted],
        corpus=corpus, ordinary=controls, expected=expected, stdout=stdout, cases=cases, source=benchmark_pin,
        timed=timed, referenceMethod='Python set membership and independent integer modular arithmetic; never executes or translates the Bend kernel.',
        scope='Baseline fixture and independent output only. No checking, builds, target execution, optimization selection or timing calibration. Timed arguments retain four-word convention but third output is a digest sum, not a count of valid repetitions.'))
    print(json.dumps(dict(source=benchmark_pin, exactExtractedFunctions=FUNCTIONS, expectedStdout=output,
                          targetRuns=False, checked=False, timingsCalibrated=False)))


if __name__ == '__main__':
    main()
