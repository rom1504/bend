#!/usr/bin/env python3
"""Root-run tiny C controls and two balanced micro rounds; no compiler image."""
import argparse
import hashlib
import json
from pathlib import Path
import statistics
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[5]
CC = Path('/home/ai/.elan/toolchains/leanprover--lean4---v4.32.0/bin/clang')
GUARD = ROOT / 'selfhost/tools/performance/phase86/guard.py'


def pin(path):
    path = Path(path).resolve(); data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--emission', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args(); out = args.out.resolve()
    assert out.is_relative_to(ROOT / 'selfhost/build/phase99'); out.mkdir(exist_ok=False)
    emission = json.loads(args.emission.read_text()); assert emission['complete']

    def verify(value):
        if isinstance(value, dict):
            if {'file', 'bytes', 'sha256'} <= value.keys(): assert pin(value['file']) == value
            else:
                for item in value.values(): verify(item)
        elif isinstance(value, list):
            for item in value: verify(item)

    verify(emission)
    report = dict(complete=False, method=pin(__file__), emission=pin(args.emission),
                  compiler=pin(CC), guard=pin(GUARD), rows=[], products={}, controls=[], samples=[])

    def save(): (out / 'report.json').write_text(json.dumps(report, indent=2) + '\n')

    def run(name, argv, seconds, allow_error=False):
        folder = out / name
        command = [sys.executable, '-B', str(GUARD), '--out', str(folder), '--seconds', str(seconds),
                   '--rss-mib', '2048', '--available-mib', '4096', '--cpu', '3', '--', *map(str, argv)]
        result = subprocess.run(command, capture_output=True, text=True)
        (out / (name + '.launcher.log')).write_text(result.stdout + result.stderr)
        process = json.loads((folder / 'process.json').read_text())
        row = dict(name=name, argv=argv, process=process, receipt=pin(folder / 'process.json'))
        report['rows'].append(row); save()
        assert process.get('finished') and isinstance(process.get('returncode'), int) and not process.get('stoppedFor'), name
        if not allow_error: assert process['complete'] and result.returncode == 0 and process['returncode'] == 0, name
        return dict(returncode=process['returncode'], stdout=(folder / 'stdout.log').read_text(),
                    stderr=(folder / 'stderr.log').read_text(), wallSeconds=process['wallSeconds'])

    def sample(name, row, allow_error=False):
        product = report['products'][row['id']]
        observed = run(name, [product['binary']['file'], '--threads', '1', '--gpu', 'off', '--', *row['args']], 30, allow_error)
        if not allow_error:
            assert observed['stdout'] == row['stdout'] and observed['stderr'] == row['stderr'], row['id']
        return observed

    try:
        for row in emission['programs']:
            assert pin(row['c']['file']) == row['c']
            binary = out / (row['id'] + '.program')
            run(row['id'] + '-build', [str(CC), '-isystem', str(CC.parent.parent / 'include/clang'), '-O2', row['c']['file'], '-o', str(binary), '-lm', '-pthread'], 60)
            report['products'][row['id']] = dict(c=row['c'], binary=pin(binary)); save()
        strict = {}
        for row in emission['programs']:
            expected_error = row['id'].startswith('strict-unused-')
            observed = sample(row['id'] + '-control', row, expected_error)
            if expected_error:
                assert observed['returncode'] != 0, ('strict argument lost its overflow', row['id'], observed)
                assert 'a Nat past the largest immediate 2^48-1' in observed['stderr'], (row['id'], observed)
                strict[row['role']] = {k: observed[k] for k in ['returncode', 'stdout', 'stderr']}
            report['controls'].append(dict(id=row['id'], **observed)); save()
        assert strict['candidate'] == strict['baseline']
        for rnd in range(2):
            for role in (['baseline', 'candidate'] if rnd == 0 else ['candidate', 'baseline']):
                row = next(x for x in emission['programs'] if x['id'] == 'name-key-micro-' + role)
                observed = sample('micro-round' + str(rnd) + '-' + role, row)
                report['samples'].append(dict(round=rnd, role=role, **observed)); save()
        medians = {role: statistics.median(x['wallSeconds'] for x in report['samples'] if x['role'] == role)
                   for role in ['baseline', 'candidate']}
        verify(emission)
        report.update(complete=True, medians=medians, candidateOverBaseline=medians['candidate'] / medians['baseline'],
                      timingAbove100ms=all(x['wallSeconds'] >= .1 for x in report['samples']),
                      strictFailureExact=True, behaviorExecutions=8, timedExecutions=4,
                      scope='Four finite source controls, including matching native overflow; two balanced whole-process rounds on a synthetic name_key mechanism. No compiler-latency or broad conformance claim.')
    except BaseException as error:
        report['error'] = repr(error); raise
    finally: save()
    print(json.dumps({k: report[k] for k in ['complete', 'medians', 'candidateOverBaseline', 'strictFailureExact', 'timingAbove100ms']}))


if __name__ == '__main__': main()
