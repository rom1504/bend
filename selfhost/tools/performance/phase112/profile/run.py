#!/usr/bin/env python3
"""Root-only serial control + six cached-object diagnostic profiles; no timing claim."""
import argparse
import json
import os
from pathlib import Path
import signal
import subprocess
import sys
import time
from prepare import ROOT, HERE, SOURCE_SHA
from parse import pin


def read(path):
    return json.loads(Path(path).read_text())


def verify(record):
    actual = pin(Path(record['file']))
    if any(actual[k] != record[k] for k in ['bytes', 'sha256']):
        raise ValueError('changed pinned input: ' + record['file'])
    return Path(actual['file'])


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--plan', type=Path, default=HERE / 'batch-plan01.json')
    p.add_argument('--runtime-source', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--budget-seconds', type=float, default=60)
    a = p.parse_args()
    if sorted(os.sched_getaffinity(0)) != [3]:
        raise SystemExit('root must run this supervisor on CPU3 under the outer resource guard')
    out = a.out.resolve()
    if out.exists() or not out.is_relative_to(ROOT / 'selfhost/build/phase112') or a.budget_seconds <= 0:
        raise SystemExit('fresh Phase112 output and positive budget required')
    plan = read(a.plan)
    if plan['kind'] != 'phase112-frozen-diagnostic-batch' or len(plan['cases']) != 6:
        raise SystemExit('frozen six-case diagnostic plan required')
    runtime_dir = a.runtime_source.resolve()
    runtime = read(runtime_dir / 'manifest.json')
    if (runtime.get('kind') != 'phase112-diagnostic-runtime' or not runtime.get('exactInverseVerified') or
            runtime['source']['sha256'] != SOURCE_SHA):
        raise SystemExit('authenticated diagnostic runtime required')
    inputs = [pin(a.plan), pin(Path(__file__)), pin(HERE / 'parse.py'), pin(HERE / 'prepare.py'),
              pin(runtime_dir / 'manifest.json')]
    inputs += [plan['binding'], plan['benchmarkManifest'], plan['compiler']]
    inputs += runtime['output']
    freeze = read(HERE / 'control-freeze.json')
    inputs += [pin(HERE / 'control-freeze.json')]
    for record in freeze['files']:
        inputs.append(dict(record, file=str((ROOT / record['file']).resolve())))
    for case in plan['cases']:
        if case['repetitions'] != 1 or case['warmups'] != 0:
            raise SystemExit('diagnostic plan must use one repetition and zero warmups')
        inputs += [case[k] for k in ['object', 'qbe', 'build', 'emission', 'source', 'oracle']]
    for record in inputs:
        verify(record)
    binding = read(plan['binding']['file'])
    manifest = read(plan['benchmarkManifest']['file'])
    if binding['manifest'] != plan['benchmarkManifest'] or not binding.get('fullFrozenQualified'):
        raise SystemExit('binding does not cover the exact frozen benchmark manifest')
    by_name = {case['name']: case for case in manifest['cases']}
    if set(by_name) != {case['name'] for case in plan['cases']}:
        raise SystemExit('plan case coverage differs from benchmark')
    for case in plan['cases']:
        original = by_name[case['name']]
        product = binding['products'][case['name']]
        built = read(case['build']['file'])
        if (case['runtimeArgs'] != original['runtimeArgs'] or
                case['expected']['stdoutPrefix'] != original['expectedStdout'] + '0\n1\n' or
                case['expected']['stderr'] != '' or case['expected']['status'] != 0 or
                case['qbe'] != product['qbe'] or case['build'] != product['build'] or
                case['object'] != built['object'] or not built['complete'] or
                case['source'] != original['source'] or case['oracle'] != original['expectedStdoutEvidence']):
            raise SystemExit('plan does not bind exact existing product and independent expectations')
    out.mkdir(parents=True)
    (out / 'plan.json').write_bytes(a.plan.read_bytes())
    (out / 'method.py').write_bytes(Path(__file__).read_bytes())
    report = dict(kind='phase112-diagnostic-batch', version=1, complete=False, diagnosticOnly=True,
                  timingsAreNotPerformanceResults=True, inputs=inputs, jobs=[], control=None,
                  cases=[dict(name=case['name'], state='pending') for case in plan['cases']],
                  cpuAffinity=[3], budgetSeconds=a.budget_seconds,
                  scope='One invocation with repetitions=1 and warmups=0; exact unchanged workload inputs. '
                        'Wrapper evaluates the workload once for reference output and once for the repetition. '
                        'Runtime counts include wrapper/setup/readback and are not per-kernel instruction costs.')
    started = time.monotonic()

    def save():
        report['supervisorSeconds'] = time.monotonic() - started
        report['qualifiedNames'] = [row['name'] for row in report['cases'] if row['state'] == 'qualified']
        report['missingNames'] = [row['name'] for row in report['cases'] if row['state'] != 'qualified']
        temporary = out / 'report.tmp'
        temporary.write_text(json.dumps(report, indent=2) + '\n')
        temporary.replace(out / 'report.json')

    def run(label, command, seconds=15):
        row = dict(label=label, command=list(map(str, command)), state='pending')
        report['jobs'].append(row)
        save()
        remaining = a.budget_seconds - (time.monotonic() - started)
        if remaining <= 0:
            raise TimeoutError('diagnostic budget exhausted')
        so, se = out / (label + '.stdout'), out / (label + '.stderr')
        begin = time.monotonic()
        with so.open('xb') as stdout, se.open('xb') as stderr:
            process = subprocess.Popen(row['command'], cwd=ROOT, stdout=stdout, stderr=stderr, start_new_session=True)
            try:
                process.wait(timeout=min(seconds, remaining))
            except BaseException:
                if process.poll() is None:
                    os.killpg(process.pid, signal.SIGKILL)
                process.wait()
                row['state'] = 'interrupted'
                raise
            finally:
                row.update(exitCode=process.returncode, diagnosticWallSeconds=time.monotonic()-begin,
                           stdout=pin(so), stderr=pin(se))
                save()
        row['state'] = 'done' if process.returncode == 0 else 'failed'
        save()
        if process.returncode != 0:
            raise RuntimeError(label + ' failed; see preserved output')
        return row

    def parse(label, observed, expected, qbe=None, control=False):
        command = [sys.executable, str(HERE / 'parse.py'), '--stdout', observed['stdout']['file'],
            '--stderr', observed['stderr']['file'], '--status', str(observed['exitCode']),
            '--expected', str(expected), '--runtime-manifest', str(runtime_dir / 'manifest.json'),
            '--out', str(out / (label + '-profile'))]
        if qbe:
            command += ['--qbe', qbe['file'], '--wall-seconds', str(observed['diagnosticWallSeconds'])]
        if control:
            command += ['--counter-expect', str(HERE / 'control-counts.json')]
        run(label + '-parse', command, 10)
        profile_path = out / (label + '-profile/profile.json')
        return pin(profile_path), read(profile_path)

    save()
    try:
        gcc = plan['compiler']['file']
        runtime_object = out / 'runtime.o'
        run('runtime-build', [gcc, '-O2', '-std=gnu11', '-ffp-contract=off', '-c',
                             runtime_dir / 'runtime.c', '-o', runtime_object], 30)
        report['runtimeObject'] = pin(runtime_object)
        control = out / 'counter-control'
        run('control-link', [gcc, '-O2', '-std=gnu11', '-I' + str(runtime_dir),
                            HERE / 'counter-control.c', runtime_object, '-pthread', '-lm', '-o', control])
        report['controlBinary'] = pin(control)
        observed = run('control-run', [control])
        profile_pin, _ = parse('control', observed, HERE / 'control-output.json', control=True)
        report['control'] = dict(complete=True, profile=profile_pin)
        save()
        for case, row in zip(plan['cases'], report['cases']):
            name = case['name']
            try:
                row['state'] = 'building'
                row.update(object=case['object'], qbe=case['qbe'], runtimeObject=report['runtimeObject'])
                binary = out / (name + '.program')
                run(name + '-link', [gcc, '-no-pie', case['object']['file'], runtime_object,
                                    '-pthread', '-lm', '-o', binary])
                row['binary'] = pin(binary)
                expected = out / (name + '.expected.json')
                expected.write_text(json.dumps(case['expected'], indent=2) + '\n')
                row['expected'] = pin(expected)
                observed = run(name + '-run', [binary, '--threads', '1', '--gpu', 'off', '--',
                                               '1', '0', *map(str, case['runtimeArgs'])])
                profile_pin, profile = parse(name, observed, expected, qbe=case['qbe'])
                row.update(state='qualified', profile=profile_pin, counters=profile['counters'],
                    dominant={name: values[:12] for name, values in profile['histograms'].items()})
                print(json.dumps(dict(case=name, complete=True, profile=profile_pin['file'])), flush=True)
            except Exception as error:
                row.update(state='failed', error=repr(error))
                # Preserve this failed observation; independent remaining cases
                # may still provide information within the fixed total budget.
            save()
        for record in inputs:
            verify(record)
        report['complete'] = bool(report['control']) and all(row['state'] == 'qualified' for row in report['cases'])
    except BaseException as error:
        report['error'] = repr(error)
    finally:
        save()
    print(json.dumps(dict(complete=report['complete'], qualified=report['qualifiedNames'],
                         missing=report['missingNames'], report=str(out / 'report.json'))), flush=True)
    return 0 if report['complete'] else 1


if __name__ == '__main__':
    raise SystemExit(main())
