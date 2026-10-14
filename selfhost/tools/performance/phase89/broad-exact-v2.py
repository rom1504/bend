#!/usr/bin/env python3
"""Root-only serial exact-C gate against all 45 executed Phase88 catalog points.

An explicitly private experiment: reuse the authenticated Phase88 Base carrier
only after the exact candidate has passed compare-owned/chunks live qualification.
No Clang, program execution, public cache admission, or timing comparison.
"""
import argparse
import hashlib
import json
import re
import sys
from pathlib import Path

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[4]
P = ROOT/'selfhost/tools/performance'
sys.path.insert(0, str(P/'phase88'))
from broad import guard, save
from native_support import authenticate, native_args, pin, DEFAULT_CACHE, RUNTIME


def read(path):
    return json.loads(Path(path).read_text())


def walk_pins(value):
    if isinstance(value, dict):
        if all(k in value for k in ('file', 'sha256', 'bytes')):
            yield value
        else:
            for child in value.values():
                yield from walk_pins(child)
    elif isinstance(value, list):
        for child in value:
            yield from walk_pins(child)


def nine_assets(remember):
    directory = P/'phase89/native-b2'
    assets_pin = remember(directory/'nine-effects.json')
    assert assets_pin['sha256'] == '1894cef9f71d674507aa671cd5c24730ce221b23df7ca0f9675949336671ba2b'
    assets = read(assets_pin['file'])
    assert assets['kind'] == 'phase89-private-native-entry-effect-assets' and assets['version'] == 1
    names = ['args.c', 'print.c', 'now.c', 'print_err.c', 'file_open.c',
             'file_read.c', 'file_size.c', 'file_write.c', 'file_close.c']
    assert [p['name'] for p in assets['admittedEffects']] == names
    effects = []
    for name, item in zip(names, assets['admittedEffects']):
        assert Path(item['file']) == ROOT/'selfhost/src/runtime/native/effs'/name
        effects.append(remember(item['file'], item))
    for key in ('base', 'runtime', 'runtimeTemplate', 'oldEntry', 'oldDefinition', 'newDefinition'):
        remember(assets[key]['file'], assets[key])
    derivation_pin = remember(ROOT/'selfhost/build/phase89/native-self-source01.bend.derivation.json')
    derivative = read(derivation_pin['file'])
    assert derivative['kind'] == 'phase89-native-nine-effect-entry-derivative'
    assert derivative['complete'] and derivative['remainingBytesExact']
    assert derivative['replacementCount'] == 1 and derivative['definition'] == 'p86_effect_file'
    assert derivative['admittedEffects'] == assets['admittedEffects']
    for item in derivative['inputs']:
        remember(item['file'], item)
    output = remember(derivative['output']['file'], derivative['output'])
    assert output['sha256'] == '4584cf083d9eddad6f1290c9472c3aac2708099caa716a27f5b53fbcbaee1618'
    before_source = Path(derivative['inputs'][0]['file']).read_bytes()
    old_block = Path(assets['oldDefinition']['file']).read_bytes()
    new_block = Path(assets['newDefinition']['file']).read_bytes()
    assert before_source.count(old_block) == 1
    offset = before_source.index(old_block)
    prefix, suffix = before_source[:offset], before_source[offset+len(old_block):]
    assert derivative['offset'] == offset
    assert derivative['oldDefinitionBytes'] == len(old_block) and derivative['newDefinitionBytes'] == len(new_block)
    assert hashlib.sha256(prefix).hexdigest() == derivative['unchangedPrefixSha256']
    assert hashlib.sha256(suffix).hexdigest() == derivative['unchangedSuffixSha256']
    assert Path(output['file']).read_bytes() == prefix+new_block+suffix
    assert Path(assets['oldEntry']['file']).read_bytes().count(old_block) == 1
    return assets_pin, assets, effects, derivation_pin, output


def admit_nine_gates(path, old, new, remember):
    gate_pin = remember(path)
    gate = read(gate_pin['file'])
    assert gate['kind'] == 'phase89-nine-effect-native-b1-gates'
    assert gate['complete'] and gate['passed'] and gate['executionPerformed'] and not gate['checkOnly']
    assert gate['liveQualified'] and gate['cacheQualifiedForThisExperiment']
    assert gate['nativeB1'] == new and new['cache'] is None
    assert gate['cacheOrigin'] == old['cache']
    method = P/'phase89/native-b2/run-b1.py'
    remember(method, gate['method'])
    assert Path(gate['method']['file']).resolve() == method
    for item in gate['inputs']:
        remember(item.get('file', item.get('path')), item)
    assets_pin, assets, effects, derivative_pin, source = nine_assets(remember)
    assert gate['assets'] == assets_pin and gate['derivation'] == derivative_pin
    assert gate['source'] == source and gate['nineEffects'] == effects
    assert new['source']['sha256'] == source['sha256']
    assert new['base'] == remember(assets['base']['file'], assets['base'])
    assert new['runtime']['sha256'] == assets['runtime']['sha256']
    assert new['template'] == remember(assets['runtimeTemplate']['file'], assets['runtimeTemplate'])
    checked = read(new['checked']['file'])
    assert checked['kind'] == 'phase89-checked-native-source-derivative'
    assert remember(checked['derivation']['file'], checked['derivation']) == derivative_pin
    for item in checked['inputs']:
        remember(item.get('file', item.get('path')), item)
    remember(checked['parent']['file'], checked['parent'])
    build = read(new['build']['file'])
    for item in build['inputs']:
        remember(item.get('file', item.get('path')), item)

    screen_pin = remember(ROOT/'selfhost/build/phase88/screen01/report.json')
    screen = read(screen_pin['file'])
    assert screen['complete'] and screen['allJobsSucceeded']
    cases = []
    for name in ('small', 'map_closed', 'unicode'):
        item = next(p for p in screen['inputs'] if p.get('file', p.get('path')) == screen['cases'][name])
        source = remember(screen['cases'][name], item)
        row = next(r for r in screen['rows'] if r['role'] == 'b2' and r['case'] == name)
        assert row['guard']['complete'] and row['guard']['returncode'] == 0 and len(row['outputs']) == 1
        cases.append(dict(name=name, source=source, oracle=row['outputs'][0], oracleReceipt=screen_pin))
    file_pin = remember(assets['testedFileControl']['file'], assets['testedFileControl'])
    file_gate = read(file_pin['file'])
    assert file_gate['kind'] == 'phase89-b2-control-emission' and file_gate['complete']
    assert file_gate['case'] == 'file-io' and file_gate['observation']['status'] == 'ok'
    assert file_gate['policy'] and all(v == 0 for v in file_gate['policy'].values())
    item = next(p for p in file_gate['inputs'] if p['file'].endswith('/file-io.bend'))
    cases.append(dict(name='file-io', source=remember(item['file'], item),
        oracle=remember(file_gate['output']['file'], file_gate['output']), oracleReceipt=file_pin))
    assert gate['oracleCases'] == cases
    expected_rows = [(mode, case) for mode in ('live', 'cached') for case in cases]
    assert len(gate['rows']) == len(expected_rows) == 8
    guard_method = P/'phase86/guard.py'
    support = P/'programs/support.py'
    for row, (mode, case) in zip(gate['rows'], expected_rows):
        name = mode+'-'+case['name']
        assert row['name'] == name and row['mode'] == mode
        assert row['passed'] and row['exactC'] and row['inputBindingsUnchanged']
        assert row['guardReturncode'] == 0 and row['source'] == case['source'] and row['oracle'] == case['oracle']
        directory = Path(row['guard']).resolve()
        assert directory.name == name+'-guard'
        prefix = directory.parent/name
        producer = new if mode == 'live' else dict(new, cache=old['cache'])
        argv = native_args(producer, case['source']['file'], prefix, 1)
        command = row['command']
        assert Path(command[0]).resolve() == Path(sys.executable).resolve()
        assert command[1:] == ['-B', str(guard_method), '--out', str(directory),
            '--seconds', '90', '--rss-mib', '2048', '--available-mib', '4096', '--cpu', '3', '--', *argv]
        process_path = directory/'process.json'
        process = read(process_path)
        assert row['process'] == process
        assert process['complete'] and process['returncode'] == 0 and not process.get('stoppedFor')
        assert process['command'] == ['bash', '-c', 'ulimit -f 65536; ulimit -c 0; exec "$@"',
            'phase86', 'taskset', '-c', '3', *argv]
        assert process['rssLimitBytes'] == 2048*1024**2 and process['availableFloorBytes'] == 4096*1024**2
        output = remember(str(prefix)+'.1.c', row['output'])
        assert all(output[k] == case['oracle'][k] for k in ('sha256', 'bytes'))
        method_receipt = read(directory/'method.json')
        remember(guard_method, method_receipt['method'])
        remember(support, method_receipt['support'])
        assert method_receipt['cpu'] == '3'
        for item in read(directory/'inputs.json'):
            remember(item.get('file', item.get('path')), item)
        stderr = (directory/'stderr.log').read_text()
        clocks = list(map(int, re.findall(r'request=\d+ request_ms=(\d+)', stderr)))
        assert len(clocks) == 1 and row['requestMs'] == clocks
        for asset in directory.iterdir():
            if asset.is_file():
                remember(asset)
    return gate_pin


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('image', type=Path)
    ap.add_argument('out', type=Path)
    gate_args = ap.add_mutually_exclusive_group(required=True)
    gate_args.add_argument('--live-evidence', type=Path)
    gate_args.add_argument('--nine-effects-gates', type=Path)
    ap.add_argument('--seconds', type=int, default=90)
    ap.add_argument('--check-only', action='store_true', help='Validate every binding and write preflight.json; launch no target')
    a = ap.parse_args()
    assert 1 <= a.seconds <= 180
    out = a.out.resolve()
    assert out.is_relative_to(ROOT/'selfhost/build/phase89') and not out.exists()
    baseline_image = ROOT/'selfhost/build/phase88/compiler-native02'
    old, new = authenticate(baseline_image, DEFAULT_CACHE), authenticate(a.image, None)
    assert new['cache'] is None
    for key in ('base', 'runtime', 'runtimeParts', 'template', 'effectsDir', 'effects'):
        assert old[key] == new[key], key

    inputs = {}

    def remember(path, expected=None):
        actual = pin(path)
        if expected is not None:
            expected_path = expected.get('file', expected.get('path'))
            assert actual['file'] == str(Path(expected_path).resolve()), str(path)
            assert all(actual[k] == expected[k] for k in ('sha256', 'bytes')), str(path)
        previous = inputs.setdefault(actual['file'], actual)
        assert previous == actual
        return actual

    for method in [Path(__file__), P/'phase88/broad.py', P/'phase88/native_support.py',
                   P/'phase86/guard.py', P/'programs/support.py']:
        remember(method)
    for auth in (old, new):
        for item in walk_pins(auth):
            remember(item['file'], item)
        build = read(auth['build']['file'])
        build_guard = build['guard']
        remember(build_guard.get('file', build_guard.get('path')), build_guard)
    remember(RUNTIME.parent/'receipt.json')  # authenticate reads this transport receipt.

    if a.nine_effects_gates:
        live_pin = admit_nine_gates(a.nine_effects_gates, old, new, remember)
        admission_kind = 'phase89-nine-effect-native-b1-gates'
    else:
        live_pin = remember(a.live_evidence)
        live = read(live_pin['file'])
        assert live['complete'] and live['passed'] and live['new'] == new and live['old'] == old
        allowed_methods = [P/'phase89/compare-owned.py', P/'phase89/compare-chunks.py']
        assert live['method']['file'] in list(map(str, allowed_methods))
        remember(live['method']['file'], live['method'])
        assert len(live['live']) == 3 and {r['case'] for r in live['live']} == {'small', 'map_closed', 'unicode'}
        for row in live['live']:
            assert row['exact'] and row['job']['pass_'] and row['role'] == 'candidate-live'
            assert len(row['outputs']) == 1
            source = live['sourcePins'][row['case']]
            remember(source['file'], source)
            remember(row['outputs'][0]['file'], row['outputs'][0])
            process_path = Path(row['job']['guard'])/'process.json'
            process = read(process_path)
            assert process['complete'] and process['returncode'] == 0 and not process.get('stoppedFor')
            command = process['command']
            start = command.index(new['image']['file'])
            prefix = row['outputs'][0]['file'].removesuffix('.1.c')
            assert command[start:] == native_args(new, source['file'], prefix, 1)
            remember(process_path)

        admission_kind = 'compare-owned-or-chunks-live'

    evidence_path = ROOT/'implementation/phase88/evidence.json'
    evidence = read(evidence_path)
    remember(evidence_path)
    sealed_path = ROOT/evidence['manifest']['file']
    sealed_pin = remember(sealed_path)
    assert sealed_pin['sha256'] == evidence['manifest']['sha256']
    assert sealed_pin['bytes'] == evidence['manifest']['bytes']
    sealed = {p['file']: p for p in read(sealed_path)}

    def retained(path):
        actual = remember(path)
        archived = sealed[str(Path(path).relative_to(ROOT))]
        assert (actual['sha256'], actual['bytes']) == (archived['sha256'], archived['bytes'])
        return read(path)

    manifest_path = ROOT/'selfhost/build/phase88/broad-fixtures03/manifest.json'
    qualified_path = ROOT/'selfhost/build/phase88/broad-qualified.json'
    manifest, qualified = retained(manifest_path), retained(qualified_path)
    assert qualified['complete'] and qualified['passed'] and qualified['points'] == 45
    assert len(manifest['cases']) == len(qualified['rows']) == 45
    oracles = {r['id']: r for r in qualified['rows']}
    assert len(oracles) == 45 and {r['id'] for r in manifest['cases']} == set(oracles)
    original_runs, groups, points = {}, {}, []
    for case in manifest['cases']:
        oracle = oracles[case['id']]
        source = remember(case['source']['file'], case['source'])
        assert oracle['sourceSha256'] == source['sha256'] and oracle['exactC'] and oracle['exactStdout']
        assert oracle['family'] == case['family']
        run_name = oracle['run']
        assert run_name in ('broad01', 'broad02', 'broad03')
        if run_name not in original_runs:
            run_path = ROOT/f'selfhost/build/phase88/{run_name}/report.json'
            original_runs[run_name] = retained(run_path)
        previous = next(r for r in original_runs[run_name]['cases'] if r['id'] == case['id'])
        assert previous['pass_'] and previous['exact'] and previous['executionExact']
        assert previous['source']['sha256'] == source['sha256']
        assert previous['b2']['sha256'] == previous['native']['sha256'] == oracle['cSha256']
        assert previous['expected'] == case['expected']
        assert all(job['pass_'] for job in previous['jobs'].values())
        text = Path(source['file']).read_bytes()
        assert re.findall(rb'^import .*$', text, re.M) == [b'import Base']
        key = source['sha256']
        group = groups.setdefault(key, dict(source=source, text=text, ids=[],
            expectedC=dict(sha256=oracle['cSha256'], bytes=previous['native']['bytes'])))
        assert group['text'] == text and group['expectedC'] == dict(sha256=oracle['cSha256'], bytes=previous['native']['bytes'])
        group['ids'].append(case['id'])
        points.append(dict(id=case['id'], family=case['family'], source=source,
            sourceGroup=key, expectedC=group['expectedC'], expectedStdout=case['expected'],
            priorRun=run_name, priorExecutionExact=True))

    # Scoped experimental permission only. native_support's public admission stays unchanged.
    cached = dict(new, cache=old['cache'])
    if a.check_only:
        assert all(pin(p['file']) == p for p in inputs.values()), 'Frozen input changed'
        assert authenticate(a.image, None) == new
        assert authenticate(baseline_image, DEFAULT_CACHE) == old
        out.mkdir(parents=True)
        preflight = dict(kind='phase89-native-broad-exact-c-preflight', complete=True,
            passed=True, method=pin(__file__), inputs=list(inputs.values()), old=old,
            new=new, liveEvidence=live_pin, admissionKind=admission_kind, privateCache=old['cache'], points=points,
            distinctSources=len(groups), targetJobsRun=0, inputsUnchanged=True,
            scope='Offline bindings only; does not establish candidate broad C equality or runtime correctness.')
        save(out/'preflight.json', preflight)
        print(json.dumps(dict(preflight=pin(out/'preflight.json'), points=len(points),
            distinctSources=len(groups), targetJobsRun=0)), flush=True)
        return
    out.mkdir(parents=True)
    report = dict(kind='phase89-native-broad-exact-c', complete=False, passed=False,
        method=pin(__file__), inputs=list(inputs.values()), old=old, new=new,
        liveEvidence=live_pin, admissionKind=admission_kind, privateCache=old['cache'], points=points,
        distinctSources=len(groups), rows=[], inputsUnchanged=False,
        scope='Full C equality transfers prior executed-output evidence for these exact 45 points. No new runtime performance measurement, Clang build, native B2, full-language conformance, or public cache-consumer admission.')
    save(out/'report.json', report)
    error = None
    try:
        for index, group in enumerate(groups.values(), 1):
            source = group['source']
            assert pin(source['file']) == source
            directory = out/f'{index:02d}-{group["ids"][0]}'
            directory.mkdir()
            prefix = directory/'candidate'
            job = guard(directory/'guard', native_args(cached, source['file'], prefix, 1), a.seconds)
            process_path = directory/'guard/process.json'
            process = read(process_path) if process_path.exists() else None
            output_path = Path(str(prefix)+'.1.c')
            output = pin(output_path) if output_path.exists() else None
            exact = bool(output and all(output[k] == group['expectedC'][k] for k in ('sha256', 'bytes')))
            receipts = [pin(p) for p in sorted((directory/'guard').glob('*')) if p.is_file()]
            row = dict(ids=group['ids'], source=source, expectedC=group['expectedC'], output=output,
                job=job, process=process, receipts=receipts, exact=exact)
            row['passed'] = bool(exact and job['pass_'] and process and process['complete']
                and process['returncode'] == 0 and not process.get('stoppedFor'))
            report['rows'].append(row)
            save(out/'report.json', report)
            print(json.dumps(dict(ids=group['ids'], exact=exact, passed=row['passed'])), flush=True)
            assert row['passed'], 'Stop at first failed process or C mismatch; preserve all evidence'
            assert pin(source['file']) == source
    except BaseException as exc:
        error = exc
        report['error'] = f'{type(exc).__name__}: {exc}'
    try:
        assert all(pin(p['file']) == p for p in inputs.values()), 'Frozen input changed'
        assert authenticate(a.image, None) == new
        assert authenticate(baseline_image, DEFAULT_CACHE) == old
        report['inputsUnchanged'] = True
    except BaseException as exc:
        report['inputVerificationError'] = f'{type(exc).__name__}: {exc}'
        error = error or exc
    report['complete'] = error is None and len(report['rows']) == len(groups)
    report['passed'] = report['complete'] and report['inputsUnchanged'] and all(r['passed'] for r in report['rows'])
    report['exactPoints'] = sum(len(r['ids']) for r in report['rows'] if r['passed'])
    save(out/'report.json', report)
    if error:
        raise error


if __name__ == '__main__':
    main()
