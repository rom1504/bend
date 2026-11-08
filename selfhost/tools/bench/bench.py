#!/usr/bin/env python3
"""Freeze, plan and measure explicit compiler/program artifacts; never acquire implicitly."""
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
import threading
import time

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent / 'build'))
import assets as build_assets
PRESETS = {
    20: dict(defaultSet='fast', rounds=3, warmupCalls=3, warmupMs=100, calibrationMs=20, targetMs=50),
    60: dict(defaultSet='core', rounds=3, warmupCalls=3, warmupMs=350, calibrationMs=40, targetMs=150),
    300: dict(defaultSet='broad', rounds=5, warmupCalls=3, warmupMs=600, calibrationMs=50, targetMs=250),
    600: dict(defaultSet='full', rounds=5, warmupCalls=3, warmupMs=1000, calibrationMs=50, targetMs=300),
}
NAME = re.compile(r'[A-Za-z0-9_.-]+\Z')


def native_runtime_arguments(product):
    if build_assets.runtime_argument_convention(product) == 'bend-rts-v1' and 'BENDRTS' in os.environ:
        raise ValueError('Explicit RTS execution requires ambient BENDRTS to be unset')
    return build_assets.runtime_arguments(product, application=True)


def require(ok, message):
    if not ok:
        raise ValueError(message)


def read(path):
    return json.loads(Path(path).read_text())


def pin(path):
    path = Path(path).resolve(strict=True)
    digest = hashlib.sha256()
    with path.open('rb') as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b''):
            digest.update(block)
    return dict(file=str(path), bytes=path.stat().st_size, sha256=digest.hexdigest())


def bind(value, base):
    entry = value if isinstance(value, dict) else dict(file=value)
    actual = pin(base / entry.get('file', entry.get('path', '')))
    if 'sha256' in entry:
        require(all(actual[k] == entry[k] for k in ('sha256', 'bytes')), 'Changed input: ' + actual['file'])
    return actual


def verify(entry):
    require(pin(entry['file']) == entry, 'Changed frozen input: ' + entry['file'])


def unique_inputs(entries):
    result = {}
    for entry in entries:
        require(entry['file'] not in result or result[entry['file']] == entry,
                'Conflicting input identities: ' + entry['file'])
        result[entry['file']] = entry
    return list(result.values())


def save(path, value, fresh=False):
    path = Path(path)
    if fresh:
        with path.open('x') as stream:
            json.dump(value, stream, indent=2)
            stream.write('\n')
    else:
        temporary = path.with_name(path.name + '.tmp')
        temporary.write_text(json.dumps(value, indent=2) + '\n')
        temporary.replace(path)


def catalog(path):
    path = Path(path).resolve()
    value = read(path)
    base = (path.parent / value.get('assetRoot', '.')).resolve()
    result = []
    for case in value['cases']:
        name = case['id']
        require(NAME.fullmatch(name), 'Unsafe case ID')
        row = dict(case, source=bind(case['source'], base))
        if 'expectedFile' in case:
            row['expectedFile'] = bind(case['expectedFile'], base)
            require(Path(row['expectedFile']['file']).read_text() == case['point']['expectedStdout'],
                    'Catalog independent expected file differs')
        result.append(row)
    require(len(result) == len({row['id'] for row in result}), 'Duplicate catalog case')
    return dict(value, cases=result)


def freeze(recipe_path, output):
    recipe_path = Path(recipe_path).resolve()
    recipe, base = read(recipe_path), recipe_path.parent
    kind = recipe['kind']
    require(kind in ('programs', 'compiler'), 'Expected programs or compiler recipe')
    roles = recipe['roles']
    require(roles and all(NAME.fullmatch(name) for name in roles), 'Invalid roles')
    reference = recipe['reference']
    require(reference in roles, 'Reference role missing')
    inputs = [pin(recipe_path), pin(__file__), pin(build_assets.__file__), pin(HERE.parent / 'build/common.py')]
    bound_roles = {}
    for name, role in roles.items():
        for key in ('host', 'stage', 'target', 'preparation', 'policy', 'status'):
            require(isinstance(role.get(key), str) and role[key], 'Missing role dimension: ' + key)
        require(role['target'] in ('js', 'c', 'qbe'), 'Unsupported output target')
        item = dict(role)
        for key in ('compiler', 'runtime', 'engine', 'qualification'):
            if key in item:
                item[key] = bind(item[key], base)
                inputs.append(item[key])
        item['inputs'] = [bind(p, base) for p in role.get('inputs', [])]
        inputs.extend(item['inputs'])
        bound_roles[name] = item
    rows = []
    sets = recipe.get('sets', {})
    if kind == 'programs':
        catalog_path = (base / recipe['catalog']).resolve()
        cat = catalog(catalog_path)
        inputs.append(pin(catalog_path))
        sets = cat['sets']
        known = {row['id']: row for row in cat['cases']}
        for selected in recipe['cases']:
            name = selected['id']
            require(name in known, 'Unknown catalog case: ' + name)
            row = dict(known[name])
            require(set(selected['products']) == set(roles), 'Missing product role')
            row['products'] = {}
            for role, product in selected['products'].items():
                product = dict(product, artifact=bind(product['artifact'], base))
                if roles[role]['target'] != 'js':
                    product['runtimeArgumentConvention'] = build_assets.runtime_argument_convention(product)
                product['inputs'] = [bind(p, base) for p in product.get('inputs', [])]
                inputs.extend([product['artifact'], *product['inputs']])
                if 'generatedSource' in product:
                    product['generatedSource'] = bind(product['generatedSource'], base)
                    inputs.append(product['generatedSource'])
                row['products'][role] = product
                if roles[role]['target'] == 'js':
                    require('engine' in bound_roles[role], 'JS role requires pinned engine')
                    require('expected' in row['point'], 'JS requires scalar-value catalog')
                else:
                    require('expectedStdout' in row['point'], 'Native requires native-batch catalog')
            inputs.append(row['source'])
            if 'expectedFile' in row:
                inputs.append(row['expectedFile'])
            rows.append(row)
        if any(role['target'] == 'js' for role in roles.values()):
            inputs.extend(pin(HERE / 'js' / name) for name in ('execute.mjs', 'profile.mjs', 'analyze.mjs'))
    else:
        for case in recipe['cases']:
            row = dict(case, source=bind(case['source'], base), requests={})
            require(set(case['requests']) == set(roles), 'Missing compiler role')
            inputs.append(row['source'])
            for role, request in case['requests'].items():
                item = dict(request)
                require(item.get('clock', 'process') == 'process', 'Cold compiler clock is complete fresh child process')
                require(item.get('scope') in ('request', 'source-to-executable'), 'Name compiler timing scope')
                require(isinstance(item['command'], list) and item['command'] and
                        all(isinstance(x, str) for x in item['command']), 'Command must be an argv vector')
                executable = bind(item['command'][0], base)
                inputs.append(executable)
                item['command'] = [executable['file'], *item['command'][1:]]
                item['inputs'] = [bind(p, base) for p in item.get('inputs', [])]
                inputs.extend(item['inputs'])
                require('stdout' in item or 'product' in item, 'Independent complete-output oracle required')
                require('stderr' in item or item.get('stderrProtocol') == 'native-c-source-v1',
                        'Explicit independent stderr oracle or strict native-C protocol required')
                if 'stderrProtocol' in item:
                    require(item['stderrProtocol'] == 'native-c-source-v1' and item.get('productSuffix') == '.1.c'
                            and 'product' in item and 'stdout' in item and 'stderr' not in item,
                            'Unknown native C complete-output contract')
                    inputs.extend(pin(HERE.parent / 'build' / name) for name in ('request.py', 'common.py', 'assets.py'))
                else:
                    require(not item.get('productSuffix'), 'Product suffix requires the qualified C protocol')
                for key in ('stdout', 'stderr', 'product'):
                    if key in item:
                        item[key] = bind(item[key], base)
                        inputs.append(item[key])
                row['requests'][role] = item
            require(len({r['scope'] for r in row['requests'].values()}) == 1,
                    'Do not compare request clocks with source-to-executable clocks')
            rows.append(row)
    require(rows and len(rows) == len({row['id'] for row in rows}) and
            all(NAME.fullmatch(row['id']) for row in rows), 'Empty, duplicate or unsafe cases')
    names = {row['id'] for row in rows}
    # Keep catalog sets intact: a partial acquisition must refuse missing cases,
    # not quietly shrink a named broad/full score to its available products.
    sets.setdefault('full', [row['id'] for row in rows])
    for key in ('fast', 'core', 'broad'):
        sets.setdefault(key, list(sets['full']))
    manifest = dict(schema='bend-benchmark-manifest-v1', kind=kind, reference=reference,
                    roles=bound_roles, cases=rows, sets=sets, cwd=str((base / recipe.get('cwd', '.')).resolve()),
                    inputs=unique_inputs(inputs),
                    scope=recipe.get('scope', ''), acquisition='Explicit and excluded; no compiler acquisition by timing runner')
    for entry in manifest['inputs']:
        verify(entry)
    save(output, manifest, fresh=True)
    return manifest


def select(manifest, budget, selected_set=None, names=None):
    preset = PRESETS[budget]
    names = names.split(',') if names else manifest['sets'][selected_set or preset['defaultSet']]
    known = {row['id']: row for row in manifest['cases']}
    require(names and len(names) == len(set(names)) and all(n in known for n in names), 'Unknown, duplicate or empty case selection')
    return [known[name] for name in names]


def observation(stdout, stderr, code, point, wall):
    """Exact native complete-result/count oracle, retained from the qualified runner."""
    expected = (point['expectedStdout'] + str(point['warmups']) + '\n' + str(point['repetitions']) + '\n').encode()
    require(code == 0 and not stderr and stdout.startswith(expected), 'Program failed complete-output or success-count check')
    suffix = stdout[len(expected):]
    require(suffix.endswith(b'\n') and suffix[:-1] and all(x in b'0123456789' for x in suffix[:-1]),
            'Invalid exact elapsed-milliseconds suffix')
    elapsed = int(suffix[:-1])
    require(elapsed <= wall * 1000 + 2, 'In-program interval exceeds process wall clock')
    return elapsed


def child(command, directory, deadline, cwd):
    """Child clocks/cleanup only. Memory, disk, affinity and lane belong to outer guard."""
    directory.mkdir(parents=True, exist_ok=False)
    remaining = deadline - time.monotonic()
    require(remaining > 0, 'Budget exhausted before child launch')
    started = time.monotonic()
    expired = threading.Event()
    process = None
    def stop():
        expired.set()
        if process is not None:
            try:
                os.killpg(process.pid, signal.SIGKILL)
            except ProcessLookupError:
                pass
    with (directory / 'stdout').open('xb') as stdout, (directory / 'stderr').open('xb') as stderr:
        process = subprocess.Popen(command, cwd=cwd, stdout=stdout, stderr=stderr, start_new_session=True)
        timer = threading.Timer(remaining, stop)
        timer.daemon = True
        timer.start()
        try:
            _, status, usage = os.wait4(process.pid, 0)
            process.returncode = os.waitstatus_to_exitcode(status)
        except BaseException:
            stop()
            process.wait()
            raise
        finally:
            timer.cancel()
            # Reap descendants still in the original group even after normal exit.
            try:
                os.killpg(process.pid, signal.SIGKILL)
            except ProcessLookupError:
                pass
    result = dict(command=command, seconds=time.monotonic() - started,
                  cpuSeconds=usage.ru_utime + usage.ru_stime, peakRssBytes=usage.ru_maxrss * 1024,
                  exitCode=process.returncode, timedOut=expired.is_set(),
                  stdout=pin(directory / 'stdout'), stderr=pin(directory / 'stderr'))
    save(directory / 'process.json', result, fresh=True)
    return result


def same_bytes(left, right):
    with Path(left).open('rb') as a, Path(right).open('rb') as b:
        while True:
            x, y = a.read(1024 * 1024), b.read(1024 * 1024)
            if x != y:
                return False
            if not x:
                return True


def summary(samples, roles, reference, rounds, ratio_eligible=True):
    paired = []
    for index in range(rounds):
        rows = [row for row in samples if row['round'] == index]
        if len(rows) == len(roles) and {r['role'] for r in rows} == set(roles) and all(r['correct'] for r in rows):
            paired.append(index)
    complete = len(paired) == rounds and all(row['correct'] for row in samples)
    stats = {}
    for role in roles:
        rows = [row for row in samples if row['role'] == role and row['round'] in paired]
        if rows:
            times = [row['metricMs'] for row in rows]
            stats[role] = dict(medianMs=statistics.median(times), samplesMs=times,
                               minimumMs=min(times), maximumMs=max(times),
                               lowResolution=any(row.get('lowResolution', False) for row in rows))
    ratios = None
    if complete and ratio_eligible and all(stats[r]['medianMs'] > 0 and not stats[r]['lowResolution'] for r in roles):
        ratios = {role: stats[role]['medianMs'] / stats[reference]['medianMs'] for role in roles if role != reference}
    return dict(complete=complete, pairedRounds=paired, stats=stats, ratios=ratios,
                ratioEligible=ratio_eligible)


def aggregate(cases, roles, reference):
    result = {}
    eligible = [case for case in cases if case['summary']['ratioEligible']]
    if not eligible or not all(case['summary']['ratios'] is not None for case in eligible):
        return dict(complete=False, reason='Incomplete, failed, zero-duration or low-resolution timed cases')
    for role in roles:
        if role == reference:
            continue
        values = [case['summary']['ratios'][role] for case in eligible]
        families = {}
        sources = {}
        for case, ratio in zip(eligible, values):
            families.setdefault(case['family'], []).append(ratio)
            sources.setdefault(case.get('sourceGroup', case['id']), []).append(ratio)
        source_means = [statistics.mean(math.log(v) for v in group) for group in sources.values()]
        result[role] = dict(geomean=math.exp(statistics.mean(math.log(v) for v in values)),
                           equalSourceGeomean=math.exp(statistics.mean(source_means)),
                           sourceCount=len(sources),
                           meanPositiveLogSlowdown=statistics.mean(max(0, math.log(v)) for v in values),
                           casesOver105=sum(v > 1.05 for v in values),
                           families={k: math.exp(statistics.mean(math.log(v) for v in vs)) for k, vs in families.items()})
    return dict(complete=True, timedCases=len(eligible), correctnessOnlyCases=len(cases) - len(eligible), roles=result)


def run(args):
    started = time.monotonic()
    manifest = read(args.manifest)
    require(manifest['schema'] == 'bend-benchmark-manifest-v1', 'Unsupported manifest')
    selected = select(manifest, args.budget, args.set, args.cases)
    for entry in manifest['inputs']:
        verify(entry)
    preset, roles = PRESETS[args.budget], list(manifest['roles'])
    rounds = args.rounds or preset['rounds']
    require(1 <= rounds <= 20 and args.scale >= 1, 'Invalid rounds or workload scale')
    plan = dict(manifest=pin(args.manifest), kind=manifest['kind'], budgetSeconds=args.budget,
                preset=preset, roles=manifest['roles'], reference=manifest['reference'],
                cases=[row['id'] for row in selected], rounds=rounds, scale=args.scale,
                qualification='Supplied role labels/receipts are pinned, not independently qualified by this timing runner',
                partialResults='Never replace a complete paired score',
                clock='Fresh child process' if manifest['kind'] == 'compiler' else 'JS timed calls or native in-program batch')
    if args.plan:
        print(json.dumps(plan, indent=2))
        return 0
    require(args.guarded, 'Run inside the documented outer resource guard and pass --guarded')
    require(sorted(os.sched_getaffinity(0)) == [args.cpu], 'Outer guard must pin the complete benchmark lane')
    require(not any(k in os.environ for k in ('LD_PRELOAD', 'BEND_SAMPLE_OUT', 'BEND_SAMPLE_CONTEXT_OUT',
                                             'BEND_PROFILE_EVENTS_OUT', 'BEND_PROFILE_COUNTERS')), 'Ambient instrumentation forbidden')
    out = args.out.resolve()
    out.mkdir(parents=True, exist_ok=False)
    deadline = started + args.budget
    report = dict(schema='bend-benchmark-report-v1', complete=False, status='running', plan=plan, cases=[])
    save(out / 'plan.json', plan, fresh=True)
    save(out / 'report.json', report)
    try:
        for case in selected:
            count = min(rounds, 3) if (manifest['kind'] == 'programs' and case['id'] == 'raytrace'
                                      and all(r['target'] == 'js' for r in manifest['roles'].values())) else rounds
            eligible = case.get('point', {}).get('ratioEligible', True)
            item = dict(id=case['id'], family=case.get('family', case['id']), rounds=count, samples=[],
                        sourceGroup=case.get('sourceGroup', case['source']['sha256']),
                        summary=summary([], roles, manifest['reference'], count, eligible))
            report['cases'].append(item)
        for index in range(rounds):
            for case, item in zip(selected, report['cases']):
                if index >= item['rounds']:
                    continue
                eligible = case.get('point', {}).get('ratioEligible', True)
                order = roles[index % len(roles):] + roles[:index % len(roles)]
                for role in order:
                    require(time.monotonic() < deadline, 'Benchmark wall budget exhausted')
                    directory = out / 'samples' / case['id'] / f'{index}-{role}'
                    directory.mkdir(parents=True)
                    row = dict(role=role, round=index, correct=False)
                    item['samples'].append(row)
                    if manifest['kind'] == 'compiler':
                        request = case['requests'][role]
                        output = directory / 'product'
                        replacements = {'{output}': str(output), '{work}': str(directory), '{source}': case['source']['file']}
                        command = [replacements.get(token, token) for token in request['command']]
                        proc = child(command, directory / 'process', deadline, manifest['cwd'])
                        row.update(process=proc, metricMs=proc['seconds'] * 1000, scope=request['scope'])
                        require(proc['exitCode'] == 0 and not proc['timedOut'], 'Compiler child failed')
                        for key in ('stdout', 'stderr', 'product'):
                            if key in request:
                                actual = Path(str(output) + request.get('productSuffix', '')) if key == 'product' else Path(proc[key]['file'])
                                require(same_bytes(actual, request[key]['file']), 'Compiler complete-output oracle differs: ' + key)
                        if request.get('stderrProtocol') == 'native-c-source-v1':
                            sys.path.insert(0, str(HERE.parent / 'build'))
                            import request as build_request
                            row['telemetry'] = build_request.c_telemetry(Path(proc['stderr']['file']).read_bytes(),
                                Path(str(output) + '.1.c').read_bytes())
                    elif manifest['roles'][role]['target'] == 'js':
                        product = case['products'][role]
                        config = dict(case['point'], **{k: preset[k] for k in ('warmupCalls', 'warmupMs', 'calibrationMs', 'targetMs')})
                        if case['id'] == 'raytrace':
                            config['warmupCalls'] = 1
                        config_path, result_path = directory / 'config.json', directory / 'sample.json'
                        save(config_path, config, fresh=True)
                        command = [manifest['roles'][role]['engine']['file'], '--stack-size=4096', '--max-old-space-size=1024',
                                   str(HERE / 'js/execute.mjs'), product['artifact']['file'], str(config_path), str(result_path)]
                        proc = child(command, directory / 'process', deadline, manifest['cwd'])
                        row['process'] = proc
                        require(proc['exitCode'] == 0 and not proc['timedOut'], 'JS child failed')
                        result = read(result_path)
                        require(result['complete'] and result['pass'] and
                                result['module']['sha256'] == product['artifact']['sha256'] and
                                result['configSha256'] == pin(config_path)['sha256'] and
                                result['toolSha256'] == pin(HERE / 'js/execute.mjs')['sha256'], 'JS result/identity failed')
                        row.update(result=result, metricMs=result['msPerCall'])
                    else:
                        point = dict(case['point'], repetitions=case['point']['repetitions'] * args.scale)
                        command = [case['products'][role]['artifact']['file'], *native_runtime_arguments(case['products'][role]),
                                   str(point['repetitions']), str(point['warmups']), *map(str, point['runtimeArgs'])]
                        proc = child(command, directory / 'process', deadline, manifest['cwd'])
                        row['process'] = proc
                        ms = observation(Path(proc['stdout']['file']).read_bytes(), Path(proc['stderr']['file']).read_bytes(),
                                         proc['exitCode'], point, proc['seconds'])
                        require(not proc['timedOut'], 'Native child timed out')
                        row.update(metricMs=ms / point['repetitions'], elapsedMs=ms, repetitions=point['repetitions'],
                                   warmups=point['warmups'], lowResolution=eligible and ms < 100)
                    row['correct'] = True
                    item['summary'] = summary(item['samples'], roles, manifest['reference'], item['rounds'], eligible)
                save(out / 'report.json', report)
        for entry in manifest['inputs']:
            verify(entry)
        report['complete'] = all(case['summary']['complete'] for case in report['cases'])
        report['status'] = 'measured' if report['complete'] else 'incomplete'
    except BaseException as error:
        report['error'] = repr(error)
        report['status'] = ('interrupted' if isinstance(error, KeyboardInterrupt) else
                            'budget-exhausted' if time.monotonic() >= deadline else 'failed')
        for case in report['cases']:
            case['summary'] = summary(case['samples'], roles, manifest['reference'], case['rounds'], case['summary']['ratioEligible'])
        # A failed global identity/contract gate cannot retain a favorable ratio.
        if report['status'] == 'failed':
            for case in report['cases']:
                case['summary']['ratios'] = None
    finally:
        report['aggregate'] = aggregate(report['cases'], roles, manifest['reference']) if report['complete'] else dict(complete=False)
        report['wallSeconds'] = time.monotonic() - started
        report['budgetOverrunSeconds'] = max(0, report['wallSeconds'] - args.budget)
        save(out / 'report.json', report)
    print(json.dumps({k: report[k] for k in ('complete', 'status', 'wallSeconds', 'aggregate')}))
    return 0 if report['complete'] else 1


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest='command', required=True)
    freeze_parser = commands.add_parser('freeze')
    freeze_parser.add_argument('--recipe', type=Path, required=True)
    freeze_parser.add_argument('--out', type=Path, required=True)
    list_parser = commands.add_parser('list')
    list_parser.add_argument('--catalog', type=Path, required=True)
    runner = commands.add_parser('run')
    runner.add_argument('--manifest', type=Path, required=True)
    runner.add_argument('--out', type=Path)
    runner.add_argument('--budget', type=int, choices=PRESETS, default=20)
    runner.add_argument('--set', choices=('fast', 'core', 'broad', 'full'))
    runner.add_argument('--cases')
    runner.add_argument('--rounds', type=int)
    runner.add_argument('--scale', type=int, default=1)
    runner.add_argument('--cpu', type=int, default=3)
    runner.add_argument('--guarded', action='store_true')
    runner.add_argument('--plan', action='store_true')
    args = parser.parse_args()
    if args.command == 'freeze':
        manifest = freeze(args.recipe, args.out)
        print(json.dumps(dict(cases=len(manifest['cases']), roles=list(manifest['roles']), targetsRun=False)))
        return 0
    if args.command == 'list':
        value = catalog(args.catalog)
        print(json.dumps(dict(sets=value['sets'], cases=[row['id'] for row in value['cases']]), indent=2))
        return 0
    require(args.plan or args.out is not None, 'Fresh --out directory is required')
    return run(args)


if __name__ == '__main__':
    try:
        raise SystemExit(main())
    except Exception as error:
        print(str(error), file=sys.stderr)
        raise SystemExit(1)
