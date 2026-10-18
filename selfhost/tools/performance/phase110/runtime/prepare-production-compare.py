#!/usr/bin/env python3
"""Freeze a direct production-Clang versus candidate-QBE comparison; run nothing."""
import argparse
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
P109 = ROOT / 'selfhost/build/phase109'
BASELINE = P109 / 'suite01/fused-reverse-kernel'
EXPECTED = ROOT / 'selfhost/tools/performance/phase109/controls/expected.jsonl'


def pin(path):
    raw = path.read_bytes()
    return dict(file=str(path.resolve()), bytes=len(raw),
                sha256=hashlib.sha256(raw).hexdigest())


def verify(record):
    if pin(Path(record['file'])) != record:
        raise ValueError('changed frozen input: ' + record['file'])


def original_cases():
    """Data-only replay of frozen Phase109 prepare-harness.py; hash-checked below."""
    cases_path = ROOT / 'selfhost/tools/performance/phase109/controls/cases.json'
    cases = json.loads(cases_path.read_text())['cases']
    lines, records = [], []
    for i, case in enumerate(cases):
        string_kind = case['kind'] == 'string'
        for side in ('input', 'acc'):
            values = [case[side + 'Codepoints']] if string_kind else [list(map(ord, s)) for s in case[side + 'Strings']]
            texts = []
            for j, value in enumerate(values):
                name = f'c{i}_{side}_{j}'
                lines.append(f'static const uint32_t {name}[] = {{{", ".join(map(str, value)) or "0"}}};')
                texts.append(f'{{{name}, {len(value)}}}')
            lines.append(f'static const Text c{i}_{side}[] = {{{", ".join(texts) or "{NULL, 0}"}}};')
        aliases = []
        for alias in case['aliases']:
            aliases.append('{%d, %d, %d}' % ({'root': 0, 'tail': 1, 'head': 2}[alias['from']], alias.get('offset', 0), alias['kind'] == 'string'))
        lines.append(f'static const Alias c{i}_aliases[] = {{{", ".join(aliases) or "{0, 0, 0}"}}};')
        records.append('{%s, %d, %d, %d, c%d_input, c%d_acc, %d, %d, c%d_aliases, %d}' % (
            json.dumps(case['name']), string_kind, case['staticInput'], case['inputPatternRepeats'], i, i,
            1 if string_kind else len(case['inputStrings']), 1 if string_kind else len(case['accStrings']), i, len(case['aliases'])))
    lines.append('static const Case CASES[] = {\n  ' + ',\n  '.join(records) + '\n};')
    return ('\n'.join(lines) + '\n').encode()


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--build', type=Path, required=True)
    p.add_argument('--worker', default='runtime-ir-single-qbe')
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    build, out = a.build.resolve(), a.out.resolve()
    if out.exists() or not out.is_relative_to(ROOT / 'selfhost/build/phase110'):
        raise ValueError('fresh Phase110 output required')
    candidate = json.loads((build / 'report.json').read_text())
    baseline = json.loads((BASELINE / 'report.json').read_text())
    historical = json.loads((P109 / 'paired02/report.json').read_text())
    if not all(d.get('complete') for d in [candidate, baseline, historical]):
        raise ValueError('complete qualification receipts required')
    if candidate.get('variant') != 'reverse':
        raise ValueError('matched reverse worker contract required')
    matches = [w for w in candidate['workers'] if w['name'] == a.worker]
    if len(matches) != 1 or matches[0]['backend'] != 'qbe':
        raise ValueError('one qualified QBE worker required')
    worker = matches[0]
    production = baseline['builds']['production-clang']['binary']
    if baseline['controls']['production-clang'] != dict(exact=True, cases=13):
        raise ValueError('preserved production worker lacks exact 13-case gate')
    if production not in historical['inputs']:
        raise ValueError('baseline differs from the actual Phase109 denominator')
    # Unrelated historical direct-worker .ssa/.c and objects may have been
    # pruned. The integrated denominator binary and its actual source/harness
    # dependencies remain independently pinned by these preserved receipts.
    required_baseline = [item for item in baseline['inputs']
        if '/production-runtime04/' in item['file']
        or item['file'] == str(EXPECTED) or Path(item['file']).name == 'gcc']
    historical_report_pins = [item for item in historical['inputs']
        if item['file'] == str(BASELINE / 'report.json')]
    for item in [*required_baseline, *historical_report_pins,
                 worker['object'], worker['binary'], production]:
        verify(item)
    original_harness = {Path(item['file']).name: item for item in baseline['inputs']
                        if '/harness02/' in item['file']}
    harness_inputs = [ROOT / 'selfhost/tools/performance/phase109/runtime/harness.c',
                      P109 / 'harness02/abi.h',
                      ROOT / 'selfhost/tools/performance/phase109/controls/cases.json',
                      ROOT / 'selfhost/tools/performance/phase109/runtime/prepare-harness.py']
    restored = {'harness.c': harness_inputs[0].read_bytes(),
                'abi.h': harness_inputs[1].read_bytes(),
                'cases.inc.c': original_cases()}
    for name, content in restored.items():
        old = original_harness[name]
        if (len(content), hashlib.sha256(content).hexdigest()) != (old['bytes'], old['sha256']):
            raise ValueError('restored harness differs from historical bytes: ' + name)
    archived_methods = []
    archives = {'run.py': build / 'method.py', 'emit.mjs': build / 'emit-method.mjs'}
    for item in candidate['inputs']:
        try:
            verify(item)
        except ValueError:
            original = Path(item['file'])
            archive = archives.get(original.name)
            if original.parent != HERE.parent or archive is None:
                raise
            frozen = pin(archive)
            if (frozen['sha256'], frozen['bytes']) != (item['sha256'], item['bytes']):
                raise ValueError('changed method has no exact frozen copy: ' + item['file'])
            archived_methods.append(dict(original=item, frozen=frozen))
    paths = [Path(__file__), build / 'report.json', build / 'runtime.o',
             BASELINE / 'report.json', P109 / 'paired02/report.json',
             P109 / 'production-runtime04/runtime.c',
             P109 / 'production-runtime04/manifest.json',
             *harness_inputs, EXPECTED]
    inputs = [*[pin(path) for path in paths], worker['object'], production,
              *[item['frozen'] for item in archived_methods]]
    oracle = [json.loads(line) for line in EXPECTED.read_text().splitlines()]
    deep = next(row for row in oracle if row['name'] == 'list-deep')
    destination = out / 'candidate-qbe'
    commands = [dict(label='harness-compile', kind='compile', command=[
        'gcc', '-O2', '-std=gnu11', '-c', str(out / 'harness/harness.c'),
        '-o', str(out / 'harness.o')]),
        dict(label='candidate-link', kind='link', command=[
        'gcc', '-no-pie', worker['object']['file'], str(build / 'runtime.o'),
        str(out / 'harness.o'), '-pthread', '-lm', '-o', str(destination)])]
    binaries = [('production-clang', production['file']), ('candidate-qbe', str(destination))]
    for name, binary in binaries:
        commands.append(dict(label=name + '-qualification', kind='qualification',
            command=[binary], expectedJsonLines=oracle))
    for name, binary in binaries:
        commands.append(dict(label=name + '-warmup', kind='warmup',
            command=[binary, 'list-deep', '20'], expectedJson=deep))
    for round_index in range(5):
        order = binaries if round_index % 2 == 0 else list(reversed(binaries))
        for name, binary in order:
            commands.append(dict(label=f'round-{round_index}-{name}', kind='timing',
                name=name, round=round_index,
                command=[binary, 'list-deep', '20'], expectedJson=deep))
    record = dict(kind='phase110-matched-production-comparison-plan', version=1,
        complete=True, targetsRun=False, candidate=worker['name'], inputs=inputs,
        exactArchivedMethods=archived_methods,
        restoredHarnessOriginalPins=original_harness,
        baselineIdentity=production, commands=commands, cpu=3,
        supervision='Root-exclusive existing guarded process runner; no concurrent targets. Pin the new linked binary before qualification and timing; verify every input before and after.',
        clock='Harness workerSeconds, CLOCK_MONOTONIC around only nx_list_reverse; graph construction, complete observation, releases and zero-live check outside the worker clock',
        correctness='Both binaries must pass all original 13 independent observations first. Every timed invocation must exactly equal the list-deep oracle and report repetitions=20; empty scratch and zero-live ownership are checked inside the frozen harness.',
        comparison=dict(case='list-deep', cellsPerRepetition=65536, repetitions=20,
            rounds=5, warmupsPerBinary=1,
            statistic='median candidate workerSeconds / median production workerSeconds measured in this same campaign; also report each round ratio and both ranges',
            historicalTimingIsDenominator=False),
        matched='Production Clang keeps its exact preserved binary and integrated runtime/worker TU. Its historical harness.o was pruned; candidate relink rebuilds the exact pinned harness02 source/cases/header with the original GCC command and verifies the same compiler binary. Candidate keeps its qualified direct-QBE object and separately built runtime object. No source rewrite, worker recompilation or replacement allocator.',
        limitations=['finite List<String> reverse kernel, not whole compiler',
                     'original 13-case controls complement but do not replace broader Phase110 gates',
                     'the shared runtime algorithms match, while compiler integration differs intentionally'])
    out.mkdir(parents=True)
    (out / 'harness').mkdir()
    for name, content in restored.items():
        (out / 'harness' / name).write_bytes(content)
    record['outputs'] = [pin(out / 'harness' / name) for name in restored]
    (out / 'plan.json').write_text(json.dumps(record, indent=2) + '\n')
    print(json.dumps(dict(complete=True, targetsRun=False, plan=str(out / 'plan.json'),
                         baseline=production, candidate=worker['object'])))


if __name__ == '__main__':
    main()
