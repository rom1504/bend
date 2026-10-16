#!/usr/bin/env python3
"""Build useful Bend apps and measure complete native executions under the guard."""
import argparse
import importlib.util
import json
import os
from pathlib import Path
import re
import shutil
import statistics
import subprocess
import sys
import time

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[4]
PERF = ROOT / 'selfhost/tools/performance'
APPS = ('source-index', 'image-render', 'dependency-plan')


def module(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    value = importlib.util.module_from_spec(spec)
    sys.modules[name] = value
    spec.loader.exec_module(value)
    return value


NATIVE = module('phase100_native', ROOT / 'selfhost/tools/native/launch.py')
pin = NATIVE.pin
verify = NATIVE.verify


def read(path):
    return json.loads(Path(path).read_text())


def save(path, value):
    path = Path(path)
    temporary = path.with_suffix('.tmp')
    temporary.write_text(json.dumps(value, indent=2) + '\n')
    temporary.replace(path)


def guarded(directory, argv, seconds=60, cpu='3'):
    assert shutil.disk_usage(ROOT).free > 512 * 1024**2, 'Need 512 MiB disk reserve'
    command = [sys.executable, '-B', str(PERF / 'phase86/guard.py'),
               '--out', str(directory), '--seconds', str(seconds), '--cpu', cpu,
               '--rss-mib', '2048', '--available-mib', '4096', '--',
               sys.executable, '-B', str(PERF / 'phase46/execute.py'),
               str(directory / 'child.json'), *map(str, argv)]
    child = subprocess.run(command, cwd=ROOT, capture_output=True, text=True)
    process = read(directory / 'process.json') if (directory / 'process.json').exists() else {}
    record = dict(guard=pin(directory / 'process.json') if process else None,
                  guardExit=child.returncode, process=process)
    if (directory / 'child.json').exists():
        inner = read(directory / 'child.json')
        record.update(receipt=pin(directory / 'child.json'),
                      seconds=inner['processSeconds'], rssKiB=inner['maxRssKiB'],
                      userSeconds=inner['userSeconds'], systemSeconds=inner['systemSeconds'])
    save(directory.parent / (directory.name + '-job.json'), record)
    assert child.returncode == 0 and process.get('complete') and not process.get('stoppedFor'), (
        'Target failed; inspect retained logs', str(directory), child.stderr)
    return record, inner


def authenticate():
    release, binding = NATIVE.load()
    # Load both authenticated stage identities; requests are still serial.
    other, _ = NATIVE.load(stage='b1')
    assert other == release
    survey_path = ROOT / 'selfhost/build/phase83/survey01/plan.json'
    survey = read(survey_path)
    reference = survey['roles']['typescript']
    base = Path(reference['bend']['file']).parent
    inputs = [binding['selection'], binding['admission'], release['source'],
              *[release['stages'][r]['binary'] for r in ('b1', 'b2')]]
    for key in ('base', 'runtime', 'template'):
        inputs.append(release['assets'][key])
    inputs += release['assets']['parts'] + release['assets']['effects']
    inputs.append(release['assets']['cache']['carrier'])
    inputs += [p for p in survey['inputs'] if p.get('file', '').startswith(str(base) + '/')]
    inputs += [pin(survey_path), pin(PERF / 'phase86/reference.mjs'),
               pin(PERF / 'phase86/guard.py'), pin(PERF / 'programs/support.py'),
               pin(PERF / 'phase46/execute.py'), pin(ROOT / 'selfhost/tools/native/launch.py')]
    clang = read(ROOT / 'selfhost/build/phase98/origin-b2.json')['clang']
    bun = pin(ROOT / 'selfhost/.bootstrap/bun-1.4.3/bun')
    inputs += [clang, bun]
    for item in inputs:
        verify(item)
    return release, dict(binding=binding, inputs=inputs, clang=clang, bun=bun,
                         upstream='059266225b77c8ca256ac6b25ee5c21449bab151')


def acquire(args, out, report):
    release, context = authenticate()
    report.update(context=context, apps=[])
    for index, name in enumerate(args.apps.split(',')):
        directory = out / name
        directory.mkdir()
        folder = ROOT / 'selfhost/apps' / name
        row = dict(id=name, source=pin(folder / 'main.bend'),
                   oracle=pin(folder / 'oracle.py'), emissions={}, products={}, complete=False)
        report['apps'].append(row)
        save(out / 'report.json', report)
        try:
            # Reference first diagnoses app typing cheaply before native requests.
            for role in ('upstream', 'b1', 'b2'):
                prefix = directory / role
                argv = ([context['bun']['file'], str(PERF / 'phase86/reference.mjs'),
                         'typescript', row['source']['file'], str(prefix), '1'] if role == 'upstream'
                        else NATIVE.native_args(release, row['source']['file'], prefix, stage=role))
                job, result = guarded(directory / (role + '-emit'), argv)
                c = pin(str(prefix) + '.1.c')
                if role == 'upstream':
                    receipt = read(str(prefix) + '.json')
                    assert receipt['complete'] and receipt['calls'][0]['observation'] == dict(status='ok', checked=True)
                    request_ms = receipt['calls'][0]['requestMs']
                else:
                    clocks = re.findall(r'^request=1 request_ms=(\d+) consumed_chars=\d+$', result['stderr'], re.M)
                    assert len(clocks) == 1, result['stderr']
                    request_ms = int(clocks[0])
                row['emissions'][role] = dict(c=c, requestMs=request_ms, job=job)
                print(json.dumps(dict(app=name, emitted=role, requestMs=request_ms)), flush=True)
                save(out / 'report.json', report)
            row['sameNativeC'] = row['emissions']['b1']['c']['sha256'] == row['emissions']['b2']['c']['sha256']
            assert row['sameNativeC'], 'Native stage products differ; investigate before sharing a program image'
            for role in ('b2', 'upstream'):
                c = row['emissions'][role]['c']
                binary = directory / (role + '.program')
                clang = context['clang']['file']
                argv = [clang, '-isystem', str(Path(clang).parents[1] / 'include/clang'),
                        '-std=c11', '-O3', c['file'], '-o', str(binary), '-lpthread', '-lm']
                job, _ = guarded(directory / (role + '-build'), argv)
                row['products'][role] = dict(binary=pin(binary), c=c, build=job)
            verify(row['source'])
            verify(row['oracle'])
            row['complete'] = True
        except Exception as error:
            row['error'] = repr(error)
            print(json.dumps(dict(app=name, error=repr(error))), flush=True)
        save(out / 'report.json', report)
    for item in context['inputs']:
        verify(item)
    report['complete'] = all(row['complete'] for row in report['apps'])


def measure(args, out, report):
    reports = [read(path) for path in args.acquired]
    selected = {}
    for acquired in reports:
        assert acquired['complete']
        for item in acquired['context']['inputs']:
            verify(item)
        for row in acquired['apps']:
            if row['id'] in args.apps.split(','):
                assert row['id'] not in selected, 'Duplicate application acquisition'
                selected[row['id']] = row
    report.update(acquired=[pin(path) for path in args.acquired], cases=[], records=[], summary=[], oracles=[])
    fixtures = read(args.fixtures) if args.fixtures else None
    if fixtures:
        assert fixtures['complete'] and fixtures['kind'] == 'phase100-applications-measure'
        assert all(row['passed'] for row in fixtures['records'])
        report['fixtureSource'] = pin(args.fixtures)
        report['fixtureOracles'] = fixtures['oracles']
        for snapshot in fixtures.get('oracleSnapshots', []):
            verify(snapshot)
    assert set(selected) == set(args.apps.split(','))
    for name, app in selected.items():
        verify(app['source'])
        for product in app['products'].values():
            verify(product['binary'])
        directory = out / name
        directory.mkdir()
        if fixtures:
            generated = []
            for case in fixtures['cases']:
                if case['app'] != name:
                    continue
                for item in [case['expected'], *case['inputs']]:
                    verify(item)
                generated.append(dict(case, expected=Path(case['expected']['file']).read_text(),
                                      input_files=[item['file'] for item in case['inputs']]))
        else:
            # Oracle changes do not require recompiling unchanged Bend source.
            current_oracle = pin(app['oracle']['file'])
            report['oracles'].append(current_oracle)
            shutil.copyfile(current_oracle['file'], directory / 'oracle-snapshot.py')
            report.setdefault('oracleSnapshots', []).append(pin(directory / 'oracle-snapshot.py'))
            oracle = module('oracle_' + name.replace('-', '_'), Path(app['oracle']['file']))
            generated = oracle.cases(directory, depth=args.depth,
                                     selected=set(args.cases.split(',')) if args.cases else None)
        for case in generated:
            if args.cases and case['id'] not in args.cases.split(','):
                continue
            expected = directory / (case['id'] + '.expected.txt')
            expected.write_text(case['expected'])
            row = {k: v for k, v in case.items() if k not in ('expected', 'input_files')}
            row.update(app=name, expected=pin(expected),
                       inputs=[pin(p) for p in case.get('input_files', [])])
            report['cases'].append(row)
            threads = args.threads.split(',') if case.get('parallel', False) else ['1']
            for workers in threads:
                count = int(workers)
                cpu = {1: '3', 2: '2,3', 4: '0,1,2,3'}[count]
                trials = []
                for rnd in range(args.rounds):
                    roles = ('b2', 'upstream') if rnd % 2 == 0 else ('upstream', 'b2')
                    for role in roles:
                        binary = app['products'][role]['binary']
                        argv = [binary['file'], '--threads', workers, '--gpu', 'off', '--', *case['argv']]
                        location = directory / f'{case["id"]}-t{workers}-r{rnd}-{role}'
                        job, child = guarded(location, argv, seconds=args.seconds, cpu=cpu)
                        passed = child['stdout'] == case['expected'] and not child['stderr']
                        trial = dict(app=name, case=case['id'], role=role, workers=count,
                                     round=rnd, cpu=cpu, passed=passed, job=job,
                                     stdoutBytes=len(child['stdout'].encode()))
                        report['records'].append(trial)
                        trials.append(trial)
                        save(out / 'report.json', report)
                        assert passed, ('Complete output mismatch', str(location))
                values = {}
                for role in ('b2', 'upstream'):
                    jobs = [t['job'] for t in trials if t['role'] == role]
                    times = [j['seconds'] for j in jobs]
                    values[role] = dict(seconds=statistics.median(times), rangeSeconds=[min(times), max(times)],
                                        rssKiB=max(j['rssKiB'] for j in jobs),
                                        cpuSeconds=statistics.median(j['userSeconds'] + j['systemSeconds'] for j in jobs))
                result = dict(app=name, case=case['id'], workers=count, roles=values,
                              ratio=values['b2']['seconds'] / values['upstream']['seconds'],
                              substantial=min(v['seconds'] for v in values.values()) >= .1)
                report['summary'].append(result)
                print(json.dumps(result), flush=True)
            verify(row['expected'])
            for item in row['inputs']:
                verify(item)
    assert report['cases'], 'No cases selected'
    if args.cases:
        assert {c['id'] for c in report['cases']} == set(args.cases.split(','))
    for app in selected.values():
        verify(app['source'])
    for oracle_pin in report['oracles']:
        verify(oracle_pin)
    report['complete'] = True


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('action', choices=('acquire', 'measure'))
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--apps', default=','.join(APPS))
    parser.add_argument('--acquired', type=Path, nargs='+')
    parser.add_argument('--fixtures', type=Path, help='Reuse pinned inputs/oracles from a successful measurement')
    parser.add_argument('--depth', choices=('smoke', 'survey'), default='smoke')
    parser.add_argument('--cases')
    parser.add_argument('--rounds', type=int, default=1)
    parser.add_argument('--threads', default='1')
    parser.add_argument('--seconds', type=int, default=30)
    args = parser.parse_args()
    assert set(args.apps.split(',')) <= set(APPS)
    assert 1 <= args.rounds <= 9 and 1 <= args.seconds <= 120
    assert set(args.threads.split(',')) <= {'1', '2', '4'}
    out = args.out.resolve()
    assert out.is_relative_to(ROOT / 'selfhost/build/phase100') and not out.exists()
    out.mkdir(parents=True)
    # Snapshot this method so later harness fixes do not destroy old run provenance.
    shutil.copyfile(__file__, out / 'method.py')
    report = dict(kind='phase100-applications-' + args.action, complete=False,
                  method=pin(out / 'method.py'), started=time.time(),
                  configuration=vars(args).copy(), host=dict(machine=os.uname().machine,
                  cpu=next(line.split(':', 1)[1].strip() for line in Path('/proc/cpuinfo').read_text().splitlines()
                           if line.startswith('model name')), affinity=sorted(os.sched_getaffinity(0))))
    report['configuration'] = {k: [str(x) for x in v] if isinstance(v, list) else
                              str(v) if isinstance(v, Path) else v for k, v in report['configuration'].items()}
    save(out / 'report.json', report)
    try:
        (acquire if args.action == 'acquire' else measure)(args, out, report)
    except Exception as error:
        report['error'] = repr(error)
        raise
    finally:
        report['finished'] = time.time()
        save(out / 'report.json', report)
    return 0 if report['complete'] else 1


if __name__ == '__main__':
    sys.exit(main())
