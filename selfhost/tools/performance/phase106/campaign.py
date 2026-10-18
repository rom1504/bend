#!/usr/bin/env python3
"""Serial experiment harness; independent references stay outside policy search."""
import argparse
import hashlib
import importlib.util
import json
import math
import random
import shutil
import statistics
import subprocess
import sys
import time
from pathlib import Path

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
P = HERE.parent
MASK = (1 << 32) - 1
WORKLOADS = ['text', 'list', 'tree', 'closure', 'tail', 'many', 'shared', 'shared_borrow']
# Frozen before candidate measurements. Held-outs are held out from policy
# selection, not unknown to the implementation or representative of all Bend.
CASES = {
    'text': dict(group='train', args=[200000, 7], repeat=100),
    'list': dict(group='train', args=[2048, 17], repeat=200),
    'tree': dict(group='heldout', args=[11, 23], repeat=100),
    'closure': dict(group='heldout', args=[100000, 31], repeat=100),
    'tail': dict(group='control', args=[1000000, 127], repeat=20),
    'many': dict(group='control', args=[2000, 29], repeat=50),
    'shared': dict(group='mechanism', args=[200000, 37], repeat=50),
    'shared_borrow': dict(group='mechanism', args=[200000, 37], repeat=50),
}
CONFIGS = [('c-o0', 'c', '-O0'), ('c-o2', 'c', '-O2'),
           ('cl-none', 'cl', 'none'), ('cl-speed', 'cl', 'speed'),
           ('cl-size', 'cl', 'speed_and_size')]


def pin(file):
    p = Path(file).resolve()
    return dict(file=str(p), bytes=p.stat().st_size,
                sha256=hashlib.sha256(p.read_bytes()).hexdigest())


def read(file):
    return json.loads(Path(file).read_text())


def save(file, data):
    p = Path(file)
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(json.dumps(data, indent=2) + '\n')


def expected(name, n, seed):
    """Mathematical workload answers; no generated C or optimizer is consulted."""
    if name == 'text':
        value = 2166136261 ^ seed
        for i in range(n & 1048575):
            c = (17 * i + seed) & 127
            ident = 65 <= c <= 90 or 97 <= c <= 122 or 48 <= c <= 57 or c in (95, 46)
            space = c == 32 or 9 <= c <= 13
            value = ((value ^ (c + 131 * ident + 17 * space)) * 16777619) & MASK
        return value
    if name == 'list':
        value = seed
        for i in reversed(range(n & 65535)):
            value = (value * 33 + (i ^ seed)) & MASK
        return value
    if name == 'tree':
        def tree(depth, value):
            if not depth:
                return value
            left = tree(depth - 1, (value * 1664525 + 1013904223) & MASK)
            right = tree(depth - 1, (value + 2654435769) & MASK)
            return (value + (left ^ right)) & MASK
        return tree(n & 15, seed)
    if name == 'closure':
        value = 0
        coefficient = 3 if seed & 1 else 7
        for i in range(n & 1048575):
            value = ((value * 33) ^ ((coefficient * i + seed) & MASK)) & MASK
        return value
    if name == 'tail':
        value = seed
        for _ in range(n & 16777215):
            value ^= (value << 13) & MASK
            value ^= value >> 17
            value ^= (value << 5) & MASK
        return value
    if name == 'many':
        value = seed
        for _ in range(n & 65535):
            value = ((value + 127 * 128 // 2) & MASK) ^ 2654435769
            for i in range(1, 128):
                value = ((value * 1664525) ^ (i + 1013904223)) & MASK
        return value
    if name in ('shared', 'shared_borrow'):
        value = 0
        for i in range(n & 1048575):
            value = (33 * value + (seed ^ i)) & MASK
        return value
    raise ValueError(name)


class Jobs:
    def __init__(self, out):
        self.out = out
        self.rows = []

    def run(self, label, argv, seconds=60, expected_code=0):
        assert shutil.disk_usage(ROOT).free > 192 * 1024**2, 'disk floor'
        folder = self.out / 'jobs' / label
        folder.parent.mkdir(parents=True, exist_ok=True)
        receipt = self.out / 'jobs' / (label + '.child.json')
        assert not folder.exists() and not receipt.exists()
        command = [sys.executable, '-B', str(P / 'phase86/guard.py'),
                   '--out', str(folder), '--seconds', str(seconds),
                   '--rss-mib', '2048', '--available-mib', '4096', '--cpu', '3', '--',
                   sys.executable, '-B', str(P / 'phase46/execute.py'), str(receipt),
                   *map(str, argv)]
        start = time.monotonic()
        done = subprocess.run(command, cwd=ROOT, capture_output=True, text=True)
        guard = read(folder / 'process.json')
        row = dict(label=label, command=command, runnerSeconds=time.monotonic() - start,
                   guard=pin(folder / 'process.json'), wrapperExit=done.returncode)
        self.rows.append(row)
        save(self.out / 'jobs.json', self.rows)
        assert not guard.get('stoppedFor') and receipt.exists(), (label, guard, done.stderr)
        if expected_code == 0:
            assert done.returncode == 0 and guard['complete'] and guard['returncode'] == 0, (label, guard)
        child = read(receipt)
        row.update(child=pin(receipt), processSeconds=child['processSeconds'],
                   peakRssKiB=child['maxRssKiB'], returncode=child['returncode'])
        save(self.out / 'jobs.json', self.rows)
        assert child['returncode'] == expected_code, (label, child['stdout'], child['stderr'])
        return child


def generate(producer, out):
    jobs = Jobs(out)
    report = dict(complete=False, producer=pin(producer), method=pin(__file__),
                  cases=CASES, products={}, started=time.time())
    save(out / 'report.json', report)
    for name in [*WORKLOADS, 'law_bridge', 'classify', 'shift']:
        report['products'][name] = {}
        for policy in ['raw', 'fold']:
            report['products'][name][policy] = {}
            for kind in ['c', 'json']:
                child = jobs.run(f'{name}-{policy}-{kind}', [producer, kind, name, policy])
                assert not child['stderr']
                target = out / f'{name}-{policy}.{kind}'
                target.write_text(child['stdout'])
                if kind == 'json':
                    assert read(target)['version'] == 1
                report['products'][name][policy][kind] = dict(
                    artifact=pin(target), emissionSeconds=child['processSeconds'])
            save(out / 'report.json', report)
    assert pin(producer) == report['producer'] and pin(__file__) == report['method']
    report.update(complete=True, finished=time.time(), jobs=len(jobs.rows))
    save(out / 'report.json', report)


def measure(artifacts, adapter, out, rounds):
    source = read(artifacts)
    assert source['complete'] and source['cases'] == CASES
    for product in source['products'].values():
        for policy in product.values():
            for mode in policy.values():
                assert pin(mode['artifact']['file']) == mode['artifact']
    selected = read(ROOT / 'selfhost/build/phase105/self-prepared01/report.json')
    recipe = read(selected['stages']['b2']['build']['file'])
    clang = recipe['clang']['file']
    assert pin(clang) == recipe['clang']
    include = str(Path(clang).parents[1] / 'include/clang')
    cc = [clang, '-isystem', include, '-std=c11', '-march=native', '-fPIC']
    jobs = Jobs(out)
    report = dict(complete=False, passed=False, started=time.time(), cases=CASES,
                  configs=CONFIGS, rounds=rounds, seed=10620261018, rows=[],
                  artifacts=pin(artifacts), adapter=pin(adapter), clang=pin(clang),
                  harness=pin(HERE / 'cranelift/runner.c'), method=pin(__file__),
                  scope='Direct constructed IR, fresh AOT backend/object/link and process runtime. '
                  'Both backends host ISA/PIC. Shared runner object acquired once. Emission is a '
                  'single observation per artifact, reused in cost models. Not a new full compiler '
                  'backend or self-hosted image.')
    save(out / 'report.json', report)
    runner = out / 'runner.o'
    receipt = jobs.run('runner-build', [*cc, '-O2', '-c', HERE / 'cranelift/runner.c', '-o', runner])
    report['runnerAcquisitionSeconds'] = receipt['processSeconds']
    answers = {name: expected(name, *case['args']) for name, case in CASES.items()}
    report['answers'] = answers
    schedule = [(round_, name, config) for round_ in range(rounds)
                for name in WORKLOADS for config in CONFIGS]
    random.Random(report['seed']).shuffle(schedule)
    report['schedule'] = schedule
    save(out / 'report.json', report)
    for round_, name, (label, backend, option) in schedule:
        prefix = f'r{round_}-{name}-{label}'
        obj, binary = out / (prefix + '.o'), out / prefix
        mode = 'c' if backend == 'c' else 'json'
        product = source['products'][name]['fold'][mode]
        if backend == 'c':
            command = [*cc, option, '-c', product['artifact']['file'], '-o', obj]
        else:
            command = [adapter, product['artifact']['file'], obj, option]
        compiled = jobs.run(prefix + '-compile', command)
        linked = jobs.run(prefix + '-link', [*cc, '-no-pie', runner, obj, '-o', binary])
        case = CASES[name]
        run = jobs.run(prefix + '-execute', [binary, '--repeat', str(case['repeat']),
                                           '--expect', str(answers[name]),
                                           *map(str, case['args'])])
        answer = (answers[name] * case['repeat']) & MASK
        assert run['stdout'] == str(answer) + '\n' and not run['stderr'], (prefix, run)
        row = dict(round=round_, workload=name, config=label,
                   emissionSeconds=product['emissionSeconds'],
                   compileSeconds=compiled['processSeconds'], linkSeconds=linked['processSeconds'],
                   executeSeconds=run['processSeconds'], peakCompileRssKiB=compiled['maxRssKiB'],
                   peakExecuteRssKiB=run['maxRssKiB'], object=pin(obj), binary=pin(binary),
                   checksum=answer)
        report['rows'].append(row)
        save(out / 'report.json', report)
        print(json.dumps({k: row[k] for k in ['round', 'workload', 'config', 'compileSeconds', 'executeSeconds']}), flush=True)
    for key in ['artifacts', 'adapter', 'clang', 'harness', 'method']:
        assert pin(report[key]['file']) == report[key], ('input changed', key)
    for product in source['products'].values():
        for policy in product.values():
            for mode in policy.values():
                assert pin(mode['artifact']['file']) == mode['artifact']
    report.update(complete=True, passed=True, inputsUnchanged=True, finished=time.time(), jobs=len(jobs.rows))
    save(out / 'report.json', report)


def analyze(file, out):
    source = read(file)
    assert source['complete'] and source['passed']
    table = {}
    for name in WORKLOADS:
        table[name] = {}
        for label, _, _ in CONFIGS:
            rows = [r for r in source['rows'] if r['workload'] == name and r['config'] == label]
            assert len(rows) == source['rounds']
            keys = ['emissionSeconds', 'compileSeconds', 'linkSeconds', 'executeSeconds']
            table[name][label] = {k: dict(median=statistics.median(r[k] for r in rows),
                                        min=min(r[k] for r in rows), max=max(r[k] for r in rows)) for k in keys}
    def cost(name, label, k):
        row = table[name][label]
        return sum(row[x]['median'] for x in ['emissionSeconds', 'compileSeconds', 'linkSeconds']) + k * row['executeSeconds']['median']
    searches = []
    for k in [1, 10, 100]:
        scores = {label: sum(cost(name, label, k) for name in WORKLOADS if CASES[name]['group'] == 'train')
                  for label, _, _ in CONFIGS}
        winner = min(scores, key=scores.get)
        validations = {}
        for group in ['train', 'heldout', 'control', 'mechanism']:
            names = [name for name in WORKLOADS if CASES[name]['group'] == group]
            baseline = sum(cost(name, 'c-o2', k) for name in names)
            selected = sum(cost(name, winner, k) for name in names)
            validations[group] = dict(baselineSeconds=baseline, selectedSeconds=selected,
                                      selectedOverBaseline=selected / baseline)
        searches.append(dict(executionBatchesPerBuild=k, trainingScores=scores, selected=winner,
                             validation=validations))
    training_rows = [r for r in source['rows'] if CASES[r['workload']]['group'] == 'train']
    search_cpu_wall = sum(r['compileSeconds'] + r['linkSeconds'] + r['executeSeconds'] for r in training_rows)
    artifacts = read(source['artifacts']['file'])
    search_cpu_wall += sum(artifacts['products'][name]['fold'][kind]['emissionSeconds']
                           for name in WORKLOADS if CASES[name]['group'] == 'train'
                           for kind in ['c', 'json'])
    result = dict(complete=True, source=pin(file), table=table, searches=searches,
                  measuredTrainingTargetSeconds=search_cpu_wall,
                  accounting='Training target cost includes compile/link/execute and required training '
                  'emissions once; excludes one-time adapter/producer/common-runner acquisition and '
                  'harness/reference/supervision costs. Full campaign receipts account for these separately.',
                  scope='Training chooses among five fixed backend profiles. Held-out results never choose '
                  'the winner. k scenarios reuse measured runtime; they are cost-model projections, not '
                  'fresh k-repeat research campaigns. Each runtime batch includes process startup '
                  'and the workload-specific repeated calls. No recursive acceleration claim.')
    for search in searches:
        saving = search['validation']['train']['baselineSeconds'] - search['validation']['train']['selectedSeconds']
        search['trainingTargetOnlyPaybackCycles'] = math.ceil(search_cpu_wall / saving) if saving > 0 else None
    save(out, result)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    subs = parser.add_subparsers(dest='mode', required=True)
    g = subs.add_parser('generate'); g.add_argument('--producer', type=Path, required=True)
    m = subs.add_parser('measure'); m.add_argument('--artifacts', type=Path, required=True)
    m.add_argument('--adapter', type=Path, required=True); m.add_argument('--rounds', type=int, default=3)
    a = subs.add_parser('analyze'); a.add_argument('--report', type=Path, required=True)
    for p in [g, m, a]: p.add_argument('--out', type=Path, required=True)
    args = parser.parse_args(); out = args.out.resolve()
    assert out.is_relative_to(ROOT / 'selfhost/build/phase106') and not out.exists()
    if args.mode == 'analyze':
        analyze(args.report, out)
    else:
        out.mkdir(parents=True)
        if args.mode == 'generate': generate(args.producer.resolve(), out)
        else:
            assert 2 <= args.rounds <= 5
            measure(args.artifacts.resolve(), args.adapter.resolve(), out, args.rounds)


if __name__ == '__main__':
    main()
