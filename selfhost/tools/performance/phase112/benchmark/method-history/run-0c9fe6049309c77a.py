#!/usr/bin/env python3
"""Bind complete product receipts, or measure already-built matched programs.

Only root launches measure, under the serial CPU3 process-tree guard.
"""
import argparse
import hashlib
import json
import math
import os
from pathlib import Path
import re
import signal
import statistics
import subprocess
import sys
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]


def pin(path):
    path = Path(path).resolve()
    digest = hashlib.sha256()
    size = 0
    with path.open('rb') as stream:
        for data in iter(lambda: stream.read(1024 * 1024), b''):
            digest.update(data)
            size += len(data)
    return dict(file=str(path), bytes=size, sha256=digest.hexdigest())


def verify(row):
    actual = pin(ROOT / row['file'])
    if any(actual[k] != row[k] for k in ('bytes', 'sha256')):
        raise ValueError('Changed input: ' + row['file'])
    return Path(actual['file'])


def read(path):
    return json.loads(Path(path).read_text())


def save(path, value):
    path = Path(path)
    temporary = path.with_suffix('.tmp')
    temporary.write_text(json.dumps(value, indent=2) + '\n')
    temporary.replace(path)


def observation(stdout, stderr, code, case, wall):
    expected = (case['expectedStdout'] + str(case['warmups']) + '\n' + str(case['repetitions']) + '\n').encode()
    if code != 0 or stderr or not stdout.startswith(expected):
        raise ValueError('Program failed complete-output or success-count check')
    suffix = stdout[len(expected):]
    if not suffix.endswith(b'\n') or not suffix[:-1] or any(x not in b'0123456789' for x in suffix[:-1]):
        raise ValueError('Invalid exact elapsed-milliseconds suffix')
    elapsed = int(suffix[:-1])
    if elapsed > wall * 1000 + 2:
        raise ValueError('In-program interval exceeds process wall clock')
    return elapsed


def bind(args, manifest):
    if args.label == 'upstream' or not re.fullmatch(r'[a-z][a-z0-9_-]*', args.label):
        raise ValueError('Upstream is fixed by manifest')
    reports = read(args.reports)
    cases = {x['name']: x for x in manifest['cases']}
    if set(reports) != set(cases):
        raise ValueError('Binding must contain exactly the six frozen case names')
    inputs = [pin(__file__), pin(HERE / 'manifest01.json'), pin(args.reports)]
    products = {}
    for name, entry in reports.items():
        report_path = (ROOT / (entry['emission'] if isinstance(entry, dict) else entry)).resolve()
        emission = read(report_path)
        if not emission.get('complete') or emission.get('mode') != 'cache':
            raise ValueError('Complete cached native emission/build required: ' + name)
        if not emission.get('image') and not emission.get('sourceChecked'):
            raise ValueError('Hosted candidate must have an actual checked-source emission receipt')
        expected_source = cases[name]['source']
        by_path = {str((ROOT / row['file']).resolve()): row for row in emission['inputs']}
        for expected in [expected_source, manifest['base'], manifest['carrier']]:
            actual = by_path.get(expected['file'])
            if not actual or any(actual[k] != expected[k] for k in ('bytes', 'sha256')):
                raise ValueError('Unmatched source/Base/carrier: ' + name)
            verify(actual)
        if args.label == 'phase111' and emission.get('image') != manifest['phase111Compiler']:
            raise ValueError('Phase111 binding must use frozen qualified successor')
        qbe = verify(emission['product'])
        if isinstance(entry, dict):
            build_path = (ROOT / entry['build']).resolve()
        else:
            build_path = verify(emission['buildReport'])
        built = read(build_path)
        if not built.get('complete') or built.get('perProgramC') or built.get('cproc'):
            raise ValueError('Complete direct-QBE build required')
        binary = verify(built['binary'])
        jobs = {row['label']: row for row in built['jobs']}
        qcmd, acmd, lcmd = [jobs[x]['command'] for x in ['qbe', 'assemble', 'link']]
        if (len(qcmd) != 6 or qcmd[1:4] != ['-t', 'amd64_sysv', '-o'] or qcmd[-1] != str(qbe) or
                len(acmd) != 4 or acmd[1] != '-o' or acmd[3] != qcmd[4] or
                len(lcmd) != 8 or lcmd[1] != '-no-pie' or lcmd[2] != acmd[2] or
                lcmd[-4:-2] != ['-pthread', '-lm'] or lcmd[-1] != str(binary)):
            raise ValueError('Unexpected QBE/assembler/link flags')
        runtime_path = lcmd[3]
        build_inputs = {str((ROOT / row['file']).resolve()): row for row in built['inputs']}
        for item in build_inputs.values():
            verify(item)
        toolchain = {key: build_inputs[str(Path(command[0]).resolve())]
                     for key, command in [('qbe', qcmd), ('assembler', acmd), ('linker', lcmd)]}
        for key, row in toolchain.items():
            verify(row)
            if row != manifest['directToolchain'][key]:
                raise ValueError('Unmatched direct toolchain ' + key)
        runtime = build_inputs[str(Path(runtime_path).resolve())]
        verify(runtime)
        if args.label == 'phase111' and runtime != manifest['phase111Runtime']:
            raise ValueError('Unmatched Phase111 runtime')
        record = dict(binary=pin(binary), source=expected_source, emission=pin(report_path),
                      build=pin(build_path), qbe=emission['product'], runtime=runtime,
                      compiler=emission.get('image'), toolchain=toolchain,
                      producerKind=emission.get('kind'), compilerHost=emission.get('compilerHost'),
                      buildCommands=[qcmd, acmd, lcmd])
        products[name] = record
        inputs += [record['binary'], record['emission'], record['build'], record['qbe'], runtime]
    for item in inputs:
        verify(item)
    if args.out.exists():
        raise ValueError('Fresh binding path required')
    args.out.parent.mkdir(parents=True, exist_ok=True)
    save(args.out, dict(kind='phase112-matched-product-binding', complete=True, label=args.label,
                       manifest=pin(HERE / 'manifest01.json'), inputs=inputs, products=products,
                       targetsRun=False, scope='Source-only receipt and binary authentication; no execution or timing.'))
    print(json.dumps(dict(complete=True, targetsRun=False, binding=pin(args.out))))


def measure(args, manifest):
    if sorted(os.sched_getaffinity(0)) != [3]:
        raise ValueError('Root must bind this supervisor to CPU3')
    out = args.out.resolve()
    if out.exists() or not out.is_relative_to(ROOT / 'selfhost/build/phase112'):
        raise ValueError('Fresh Phase112 output directory required')
    inputs = [pin(__file__), pin(HERE / 'manifest01.json'), *manifest['inputs']]
    roles = {'upstream': {c['name']: c['upstream'] for c in manifest['cases']}}
    for path in args.bindings:
        binding = read(path)
        if not binding.get('complete') or binding.get('kind') != 'phase112-matched-product-binding':
            raise ValueError('Complete matched product binding required')
        if binding['manifest'] != pin(HERE / 'manifest01.json') or binding['label'] in roles:
            raise ValueError('Wrong manifest or duplicate product role')
        for item in binding['inputs']:
            verify(item)
        inputs += [pin(path), *binding['inputs']]
        roles[binding['label']] = binding['products']
    if 'phase111' not in roles:
        raise ValueError('Frozen Phase111 comparator binding required')
    cases = manifest['cases']
    if args.names:
        names = set(args.names)
        cases = [c for c in cases if c['name'] in names]
        if len(cases) != len(args.names):
            raise ValueError('Unknown or duplicate case names')
    for case in cases:
        for role, products in roles.items():
            verify(products[case['name']]['binary'])
    for item in inputs:
        verify(item)
    out.mkdir(parents=True)
    (out / 'method.py').write_bytes(Path(__file__).read_bytes())
    (out / 'manifest.json').write_bytes((HERE / 'manifest01.json').read_bytes())
    report = dict(kind='phase112-matched-program-runtime', complete=False, inputs=inputs,
                  roles=list(roles), cases=[c['name'] for c in cases], records=[], rounds=args.rounds,
                  started=time.time(), cpuAffinity=[3], qualifiedMinimumMs=manifest['minimumMs'],
                  budgetSeconds=args.budget_seconds, sampleDeadlineSeconds=args.seconds,
                  zeroWorkExclusions=manifest['zeroWorkExclusions'],
                  clock=manifest['clock'], acquisitionIncluded=False,
                  scope='Exact same existing Phase93 batch sources, inputs, counts and one-CPU flags across roles. Upstream retains pinned Clang -O3; direct roles retain QBE/tool/link flags. Six-point screen, not the old 44-point aggregate.')
    start = time.monotonic()
    def persist():
        report['wallSeconds'] = time.monotonic() - start
        save(out / 'report.json', report)
    persist()
    try:
        for index, case in enumerate(cases):
            name = case['name']
            for rnd in range(args.rounds):
                order = list(roles)
                shift = (index + rnd) % len(order)
                order = order[shift:] + order[:shift]
                for role in order:
                    binary = verify(roles[role][name]['binary'])
                    command = [str(binary), '--threads', '1', '--gpu', 'off', '--',
                               str(case['repetitions']), str(case['warmups']), *map(str, case['runtimeArgs'])]
                    stem = out / (name + '-' + str(rnd + 1) + '-' + role)
                    row = dict(case=name, role=role, round=rnd + 1, command=command,
                               binary=pin(binary), repetitions=case['repetitions'], warmups=case['warmups'],
                               correct=False, qualified=False)
                    report['records'].append(row)
                    remaining = args.budget_seconds - (time.monotonic() - start)
                    if remaining <= 0:
                        raise TimeoutError('Campaign budget exhausted; partial records are not an aggregate')
                    row['limitSeconds'] = min(args.seconds, remaining)
                    persist()
                    t0 = time.monotonic()
                    with stem.with_suffix('.stdout').open('xb') as so, stem.with_suffix('.stderr').open('xb') as se:
                        child = subprocess.Popen(command, cwd=ROOT, stdout=so, stderr=se, start_new_session=True)
                        try:
                            child.wait(timeout=row['limitSeconds'])
                        except BaseException as error:
                            if child.poll() is None:
                                os.killpg(child.pid, signal.SIGKILL)
                            child.wait()
                            row['timedOut'] = isinstance(error, subprocess.TimeoutExpired)
                            raise
                        finally:
                            row.update(processSeconds=time.monotonic() - t0, exitCode=child.returncode,
                                       stdout=pin(stem.with_suffix('.stdout')), stderr=pin(stem.with_suffix('.stderr')))
                            persist()
                    elapsed = observation(Path(row['stdout']['file']).read_bytes(), Path(row['stderr']['file']).read_bytes(),
                                          row['exitCode'], case, row['processSeconds'])
                    row.update(elapsedMs=elapsed, correct=True, qualified=elapsed >= manifest['minimumMs'])
                    persist()
                    print(json.dumps(dict(case=name, role=role, round=rnd + 1, elapsedMs=elapsed)), flush=True)
                    if not row['qualified']:
                        raise ValueError('Below frozen minimum interval; preserve attempt, no automatic retuning or zero-work classification')
        summary = {}
        for case in cases:
            samples = {role: [r['elapsedMs'] for r in report['records'] if r['case'] == case['name'] and r['role'] == role]
                       for role in roles}
            medians = {role: statistics.median(values) for role, values in samples.items()}
            summary[case['name']] = dict(samplesMs=samples, mediansMs=medians,
                ratiosToUpstream={role: value / medians['upstream'] for role, value in medians.items()},
                ratiosToPhase111={role: value / medians['phase111'] for role, value in medians.items()})
        report['perProgram'] = summary
        report['geomeanRatios'] = {denominator: {role: math.exp(sum(math.log(row[key][role]) for row in summary.values()) / len(summary))
            for role in roles} for denominator, key in [('upstream', 'ratiosToUpstream'), ('phase111', 'ratiosToPhase111')]}
        report['aggregateCount'] = len(summary)
        report['fullInitialSix'] = len(summary) == 6
        report['ratioDirection'] = 'role milliseconds / comparator milliseconds; below 1 is faster'
        for item in inputs:
            verify(item)
        report['complete'] = True
    except BaseException as error:
        report['error'] = repr(error)
    finally:
        report['finished'] = time.time()
        persist()
    print(json.dumps(dict(complete=report['complete'], geomeanRatios=report.get('geomeanRatios'))), flush=True)
    return 0 if report['complete'] else 1


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest='action', required=True)
    b = commands.add_parser('bind')
    b.add_argument('--label', required=True)
    b.add_argument('--reports', type=Path, required=True)
    b.add_argument('--out', type=Path, required=True)
    m = commands.add_parser('measure')
    m.add_argument('--bindings', type=Path, nargs='+', required=True)
    m.add_argument('--out', type=Path, required=True)
    m.add_argument('--names', nargs='+')
    m.add_argument('--rounds', type=int, default=3)
    m.add_argument('--seconds', type=int, default=30)
    m.add_argument('--budget-seconds', type=int, default=300)
    args = parser.parse_args()
    manifest = read(HERE / 'manifest01.json')
    if args.action == 'bind':
        return bind(args, manifest) or 0
    if args.rounds < 3 or args.seconds <= 0 or args.budget_seconds <= 0:
        raise ValueError('At least three rounds and positive deadline required')
    return measure(args, manifest)


if __name__ == '__main__':
    raise SystemExit(main())
