#!/usr/bin/env python3
"""Coordinator-only serial native chain, then an explicitly separate gate queue.

--dry-run prints commands and launches nothing. Existing receipts are never
resumed or replaced. Qualification completion is not admission or promotion.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parents[4]
T = ROOT / 'selfhost/tools/performance/phase102'
Q = T.parent / 'phase99/qualification/reuse.py'
PREPARE = Q.parent / 'prepare.py'
INTEGRITY = ROOT / 'selfhost/build/phase98/qualification-methods17/methods/conformance_integrity.py'
RUNTIME = T.parent / 'phase99/runtime/run.py'


def read(path):
    return json.loads(Path(path).read_text())


def pin(path):
    path = Path(path).resolve()
    data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def verify(item):
    assert pin(item['file']) == item, ('Changed input', item['file'])


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('phase', choices=['chain', 'qualification'])
    parser.add_argument('--recipe', type=Path, required=True, help='Exact reversible Phase98-to-final recipe')
    parser.add_argument('--controls', type=Path, nargs='+', default=[], help='Completed final API output reports')
    parser.add_argument('--apps', type=Path, nargs='+', default=[], help='Completed final application reports')
    parser.add_argument('--reason', help='Root-supplied changed-backend policy description; required for chain')
    parser.add_argument('--run-id', default='03', help='Fresh numeric output suffix; default03')
    parser.add_argument('--dry-run', action='store_true')
    args = parser.parse_args()
    assert re.fullmatch(r'[0-9]{2,}', args.run_id), 'Use a numeric run id of at least two digits'
    assert args.reason if args.phase == 'chain' else args.controls and args.apps
    root = ROOT / 'selfhost/build/phase102'
    old = ROOT / 'selfhost/build/phase99'
    b1root, out = root / ('native-b1-' + args.run_id), root / ('native-chain' + args.run_id)
    plan = old / ('phase102-final-plan' + args.run_id)
    policy, b1, b2 = plan / 'policy/policy.json', b1root / 'b1.json', out / 'b2.json'
    recipe_pin = pin(args.recipe)
    recipe = read(args.recipe)
    baseline_path = Q.parent / 'baseline.json'
    baseline = read(baseline_path)
    assert recipe['complete'] and baseline['complete']
    assert recipe['source'] == baseline['source'], 'Recipe must start at the frozen Phase98 source'
    for item in (recipe['source'], recipe['candidate']):
        verify(item)
    source = Path(recipe['candidate']['file'])
    common = ['--b1-build', b1, '--b2-build', b2, '--backend-policy', policy]
    jobs = []

    def job(name, method, *parts):
        jobs.append(dict(name=name, command=[sys.executable, '-B', *map(str, [method, *parts])]))

    if args.phase == 'chain':
        job('acquire-b1', T / 'acquire-native.py', '--recipe', args.recipe.resolve(), '--out', b1root)
        job('prepare', PREPARE, '--source', source, '--recipe', args.recipe.resolve(),
            '--acquisition', b1root / 'checked/report.json', '--reason', args.reason, '--out', plan)
        job('reference', Q, 'request', '--baseline', 'b2', '--source', source,
            '--purpose', 'reference', '--out', out / 'reference')
        job('b1-self', Q, 'request', '--stage', 'b1', '--binary', b1root / 'compiler',
            '--compiler-source', source, '--build-receipt', b1, '--source', source,
            '--purpose', 'changed-backend', '--backend-policy', policy,
            '--oracle-report', out / 'reference/report.json', '--out', out / 'b1-self')
        job('b2-build', Q, 'build', '--emission-receipt', out / 'b1-self/report.json',
            '--binary', out / 'b2/compiler', '--out', out / 'b2-build', '--seconds', '420', '--rss-mib', '6144')
        job('b2-bind', Q, 'bind', '--stage', 'b2', '--binary', out / 'b2/compiler',
            '--source', source, '--emission-receipt', out / 'b1-self/report.json',
            '--build-guard', out / 'b2-build', '--out', b2)
        job('b2-self', Q, 'request', '--stage', 'b2', '--binary', out / 'b2/compiler',
            '--compiler-source', source, '--build-receipt', b2, '--source', source,
            '--purpose', 'compare', '--backend-policy', policy,
            '--oracle-report', out / 'b1-self/report.json', '--out', out / 'b2-self')
        fresh = [b1root, out, plan]
    else:
        for suite in ['controls', 'broad45']:
            job(suite, Q, 'backend-gates', *common, '--suite', suite, '--out', out / suite)
        job('conformance-prepare', Q, 'conformance', *common, '--out', out / 'conformance')
        for role in ['b1', 'b2', 'diagnostics']:
            job('conformance-' + role, INTEGRITY, 'run', '--plan', out / 'conformance/plan.json', '--role', role)
        job('conformance-collect', INTEGRITY, 'collect', '--plan', out / 'conformance/plan.json',
            '--out', out / 'conformance/collected.json')
        job('inheritance', T / 'native-inherit-v2.py', *common,
            '--controls', *[p.resolve() for p in args.controls],
            '--apps', *[p.resolve() for p in args.apps], '--out', out / 'inheritance')
        job('continuity', T / 'qualification-method.py', 'batch-continuity', 'emit',
            '--plan', ROOT / 'selfhost/build/phase98/batch-continuity-plan01/plan.json',
            '--b2-build', b2, '--backend-policy', policy, '--out', out / 'runtime-continuity')
        for stage in ['b1', 'b2']:
            builds = ['--b1-build', b1] if stage == 'b1' else ['--b1-build', b1, '--b2-build', b2]
            job('speed-' + stage, Q, 'compare', '--stage', stage, *builds, '--backend-policy', policy,
                '--out', old / ('phase102-' + stage + '-screen' + args.run_id))
        job('runtime-acquire', RUNTIME, 'acquire', '--changed-plan', out / 'runtime-continuity/changed-plan.json',
            '--b1-build', b1, '--b2-build', b2, '--out', old / ('phase102-runtime-products' + args.run_id))
        fresh = [out / name for name in ['controls', 'broad45', 'conformance', 'inheritance', 'runtime-continuity']]
        fresh += [old / ('phase102-' + name + args.run_id) for name in ['b1-screen', 'b2-screen', 'runtime-products']]

    if args.dry_run:
        print(json.dumps(dict(phase=args.phase, source=recipe['candidate'], jobs=jobs,
                             targetsRun=False, freshOutputs=list(map(str, fresh))), indent=2))
        return
    inputs = [pin(__file__), recipe_pin, pin(baseline_path), recipe['source'], recipe['candidate']]
    if args.phase == 'qualification':
        chain_path = out / 'chain-queue.json'
        chain = read(chain_path)
        assert chain['complete'] and chain['recipe'] == recipe_pin and chain['source'] == recipe['candidate']
        assert chain['method'] == pin(__file__), 'Queue method changed since chain; preserve the frozen method'
        inputs.append(pin(chain_path))
        for path in [*args.controls, *args.apps]:
            value = read(path)
            assert value['complete'] and not value.get('error') and value.get('passed', True)
            inputs.append(pin(path))
    assert all(not path.exists() for path in fresh), ('Output already exists; use a fresh run id', fresh)
    out.mkdir(parents=True, exist_ok=args.phase == 'qualification')
    state = out / (args.phase + '-queue.json')
    report = dict(complete=False, phase=args.phase, started=time.time(), method=pin(__file__),
                  recipe=recipe_pin, source=recipe['candidate'], inputs=inputs, plannedJobs=jobs, jobs=[],
                  releaseQualified=False, scope='Queue completion only; no admission, final authority decision or selection change.')
    with state.open('x') as stream:
        stream.write(json.dumps(report, indent=2) + '\n')

    def save():
        temporary = state.with_suffix('.tmp')
        temporary.write_text(json.dumps(report, indent=2) + '\n')
        temporary.replace(state)

    try:
        for planned in jobs:
            for item in inputs:
                verify(item)
            row = dict(planned, started=time.time())
            report['jobs'].append(row)
            save()
            print('Starting ' + row['name'], flush=True)
            stdout, stderr = out / (row['name'] + '.stdout'), out / (row['name'] + '.stderr')
            started = time.perf_counter()
            try:
                with stdout.open('xb') as output, stderr.open('xb') as error:
                    process = subprocess.run(row['command'], cwd=ROOT, stdout=output, stderr=error)
                row['returncode'] = process.returncode
            except BaseException as error:
                row['error'] = repr(error)
                raise
            finally:
                row.update(finished=time.time(), seconds=time.perf_counter() - started)
                for key, path in [('stdout', stdout), ('stderr', stderr)]:
                    if path.exists(): row[key] = pin(path)
                save()
            print(json.dumps(row), flush=True)
            if process.returncode:
                raise RuntimeError('Failed stage; retained logs: ' + row['name'])
        for item in inputs:
            verify(item)
        report['complete'] = True
    except BaseException as error:
        report['error'] = repr(error)
        raise
    finally:
        report['finished'] = time.time()
        save()


if __name__ == '__main__':
    main()
