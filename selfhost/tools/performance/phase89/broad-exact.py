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


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('image', type=Path)
    ap.add_argument('out', type=Path)
    ap.add_argument('--live-evidence', type=Path, required=True)
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
            new=new, liveEvidence=live_pin, privateCache=old['cache'], points=points,
            distinctSources=len(groups), targetJobsRun=0, inputsUnchanged=True,
            scope='Offline bindings only; does not establish candidate broad C equality or runtime correctness.')
        save(out/'preflight.json', preflight)
        print(json.dumps(dict(preflight=pin(out/'preflight.json'), points=len(points),
            distinctSources=len(groups), targetJobsRun=0)), flush=True)
        return
    out.mkdir(parents=True)
    report = dict(kind='phase89-native-broad-exact-c', complete=False, passed=False,
        method=pin(__file__), inputs=list(inputs.values()), old=old, new=new,
        liveEvidence=live_pin, privateCache=old['cache'], points=points,
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
