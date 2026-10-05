#!/usr/bin/env python3
"""Join completed selected semantic gates without executing or repairing any gate."""
import argparse
import hashlib
import json
import traceback
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
RAW = ROOT / 'selfhost/build/phase48'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('plan', type=Path)
    parser.add_argument('out', type=Path, help='Fresh JSON receipt under build/phase48')
    parser.add_argument('--count-report', type=Path, help='Explicit existing SAME selected-image count control')
    parser.add_argument('--count-process', type=Path, help='Its actual guarded process.json; required with --count-report')
    parser.add_argument('--source-reconciliation', type=Path, required=True, help='Completed explicit live-source reconciliation receipt')
    args = parser.parse_args()
    out = args.out.resolve()
    assert out.is_relative_to(RAW) and not out.exists()
    assert bool(args.count_report) == bool(args.count_process)
    pins = {}
    report = dict(kind='phase48-selected-semantic-qualification', complete=False, passed=False,
                  compilerExecuted=False, generatedProgramsExecuted=False, jobs=[], fixtures=[], inputs=[])

    def pin(file, expected=None, refresh=False):
        file = Path(file).resolve(strict=True)
        row = pins.get(str(file))
        if row is None or refresh:
            digest = hashlib.sha256()
            with file.open('rb') as stream:
                for chunk in iter(lambda: stream.read(2**20), b''):
                    digest.update(chunk)
            row = dict(file=str(file), sha256=digest.hexdigest(), bytes=file.stat().st_size)
        if expected:
            assert row['sha256'] == expected['sha256'], file
            assert 'bytes' not in expected or row['bytes'] == expected['bytes'], file
            assert 'canonicalPath' not in expected or str(file) == expected['canonicalPath'], file
        assert pins.get(str(file), row) == row, file
        pins[str(file)] = row
        return row

    def bound(row):
        return pin(row.get('file', row.get('path', row.get('canonicalPath'))), row)

    def read(file):
        pin(file)
        return json.loads(Path(file).read_text())

    def audit(value):
        if isinstance(value, list):
            for child in value:
                audit(child)
        elif isinstance(value, dict):
            file = value.get('file', value.get('path', value.get('canonicalPath')))
            if isinstance(file, str) and 'sha256' in value:
                assert Path(file).is_absolute(), file
                pin(file, value)
            for child in value.values():
                audit(child)

    def expect(value, contract):
        for key, wanted in contract.items():
            if key == 'arrayLengths':
                for field, size in wanted.items():
                    assert isinstance(value[field], list) and len(value[field]) == size, field
            else:
                assert value.get(key) == wanted, (key, value.get(key), wanted)
        assert not value.get('error'), value.get('error')

    def command_equal(actual, expected):
        assert len(actual) == len(expected), (actual, expected)
        for actual_arg, expected_arg in zip(actual, expected):
            if Path(expected_arg).is_absolute():
                assert (ROOT / actual_arg).resolve(strict=True) == Path(expected_arg).resolve(strict=True)
            else:
                assert actual_arg == expected_arg, (actual_arg, expected_arg)

    def process(file, expected=None):
        value = read(file)
        assert value['complete'] and value['returncode'] == 0 and not value.get('stoppedFor')
        assert value['rssLimitBytes'] <= 2048 * 1024**2 and value['availableFloorBytes'] >= 4096 * 1024**2
        assert value['finished'] >= value['started']
        if expected:
            command_equal(value['command'], expected)
        logs = {name: pin(Path(file).parent / (name + '.log')) for name in ['stdout', 'stderr']}
        return dict(receipt=pin(file), started=value['started'], finished=value['finished'], logs=logs)

    try:
        pin(__file__)
        plan = read(args.plan)
        assert plan['kind'] == 'phase48-rnfa-final-semantic-plan-v2' and plan['complete'] and not plan['executed'] and plan['serial']
        assert Path(plan['cwd']) == ROOT and plan['releaseSeparate']
        audit(plan['inputs']); audit(plan['selected'])
        selected = plan['selected']
        report.update(plan=pin(args.plan), selected=selected, expectedJobs=len(plan['jobs']))
        attempt = read(selected['attempt']['file'])
        assert attempt['checked'] and attempt['config']['strictExact']
        bootstrap = read(bound(attempt['bootstrapReport'])['file'])
        report['sourceSha256'] = bootstrap['sourceSha256']
        reconciliation = read(args.source_reconciliation)
        assert reconciliation['kind'] == 'phase48-selected-source-reconciliation' and reconciliation['complete'] and reconciliation['sourceExact']
        assert len(reconciliation['unchangedAncillaryInputs']) == 827
        assert bound(reconciliation['attempt']) == bound(selected['attempt'])
        assert len(reconciliation['replaced']) == 13 and len(reconciliation['removed']) == 3
        bound(reconciliation['plan'])
        archive_id = bound(reconciliation['preimages']); archive = read(archive_id['file'])
        assert archive['complete'] and len(archive['files']) == 16
        assert {r['path'] for r in archive['files']} == {r['path'] for r in reconciliation['replaced'] + reconciliation['removed']}
        for item in archive['files']:
            pin(Path(archive_id['file']).parent / item['archive'], item)
        live_src, frozen_src = ROOT / 'selfhost/src', Path(attempt['snapshot']['root']) / 'src'
        source_names = set(reconciliation['sourceFiles'])
        assert len(source_names) == 188
        assert {str(p.relative_to(live_src)) for p in live_src.rglob('*') if p.is_file()} == source_names
        assert {str(p.relative_to(frozen_src)) for p in frozen_src.rglob('*') if p.is_file()} == source_names
        for name, digest in reconciliation['sourceFiles'].items():
            assert not Path(name).is_absolute() and '..' not in Path(name).parts
            pin(live_src / name, {'sha256': digest}); pin(frozen_src / name, {'sha256': digest})
        report['sourceReconciliation'] = dict(receipt=pin(args.source_reconciliation), exactSourceFiles=188, preservedPreimages=16,
            ancillaryScope='827 ancillary identities were checked during source reconciliation. This join does not freeze mutable installed dist artifacts across the later installer.')
        fixtures = {row['name']: row for row in plan['fixtures']}
        assert len(fixtures) == len(plan['fixtures'])
        assert [row['index'] for row in plan['jobs']] == list(range(len(plan['jobs'])))
        assert len({row['name'] for row in plan['jobs']}) == len(plan['jobs'])
        candidate_rows = {}
        for name, fixture in fixtures.items():
            binding = fixture['bindings']
            module = pin(binding['candidateModule'])
            emission = read(binding['candidateEmission'])
            assert emission['kind'] == 'bend-program-checked-emission' and emission['complete']
            assert emission['observation']['checked'] and emission['observation']['status'] == 'ok'
            audit(emission)
            assert bound(emission['attempt']) == bound(selected['attempt'])
            assert bound(emission['output']) == module
            assert bound(emission['input']) == bound(binding['source'])
            assert bound(emission['catalog']) == bound(binding['catalog'])
            assert emission['compiler']['sourceSha256'] == report['sourceSha256']
            for key in ['api', 'runtime', 'base', 'driver']:
                assert bound(emission['compiler'][key]) == bound(selected[key])
            candidate_rows[name] = dict(module=module, emission=pin(binding['candidateEmission']))
            report['fixtures'].append(dict(name=name, **candidate_rows[name], baseline=bound(fixture['baselineModule']),
                                           baselineEmission=bound(fixture['baselineEmission']), reusedAcquisition=fixture['reusedAcquisition']))
        focused_finished, maintained_started = [], None
        for job in plan['jobs']:
            name = job['name']
            alias = name == 'control-counts' and args.count_report is not None
            result_file = args.count_report.resolve(strict=True) if alias else Path(job['report'])
            child = read(result_file); expect(child, job['expect'])
            row = dict(name=name, report=pin(result_file), disposition='previous-same-selected-image-execution' if alias else 'planned-completion',
                       stage=job['stage'], contract=job['expect'])
            if name.startswith('acquire-'):
                fixture_name = name[len('acquire-'):]
                fixture, candidate = fixtures[fixture_name], candidate_rows[fixture_name]
                assert len(child['cases']) == 1 and child['cases'][0]['sourceSha256'] == fixture['bindings']['source']['sha256']
                module = child['cases'][0]['modules']['candidate']
                assert pin(result_file.parent / module['path'], module) == candidate['module']
                prep = child['preparation']; prep_file = result_file.parent / prep['path']; pin(prep_file, prep)
                preparation = read(prep_file)
                assert preparation['complete'] and preparation['cpu'] == 3 and preparation['heapMiB'] == 1024
                assert len(preparation['sources']) == 1
                proc = preparation['sources'][0]['process']
                expected = ['taskset', '-c', '3', selected['node']['file'], '--stack-size=4096', '--max-old-space-size=1024',
                            preparation['worker']['path'], str(Path(selected['attempt']['file']).parent), fixture['bindings']['source']['file'],
                            candidate['module']['file'], fixture['bindings']['catalog']['file']]
                row['process'] = process(result_file.parent / 'emit-00/process.json', expected)
                assert read(result_file.parent / 'emit-00/process.json') == proc
            elif job['guard'] == 'phase46/job.py only':
                command = job['command']; payload = command[command.index('--') + 1:]
                proc_file = args.count_process.resolve(strict=True) if alias else Path(command[command.index('--out') + 1]) / 'process.json'
                if alias:
                    assert fixtures['counts']['reusedAcquisition'], 'Count alias requires exact prior acquisition binding'
                    payload = payload[:-1] + [str(result_file.parent)]
                row['process'] = process(proc_file, ['taskset', '-c', '3', *payload])
                if name.startswith('control-'):
                    fixture_name = name[len('control-'):]
                    fixture, candidate = fixtures[fixture_name], candidate_rows[fixture_name]
                    consumed = {bound(item)['file']: bound(item) for item in child['inputs']}
                    for required in [fixture['controller'], selected['node'], fixture['baselineModule'], fixture['baselineEmission'], candidate['module'], candidate['emission']]:
                        assert consumed[required['file']] == bound(required)
                    audit(child)
                elif name in ['float-ir', 'native-rejection']:
                    audit(child)
                    consumed = {bound(item)['file']: bound(item) for item in child['inputs']}
                    for required in [selected['attempt'], selected['api'], selected['runtime'], selected['node']]:
                        assert consumed[required['file']] == bound(required)
                    if name == 'native-rejection':
                        current = child['roles'][1]
                        for key in ['attempt', 'api', 'runtime', 'base']:
                            assert bound(current[key]) == bound(selected[key])
                elif name == 'backend81':
                    assert bound(child['attempt']) == bound(selected['attempt'])
                    assert all(r['acceptedCampaignObservation'] for r in child['rows'])
                    assert len(child['steps']) == 7 and all(s['complete'] and s['exitCode'] == 0 for s in child['steps'])
                    backend_plan = read(child['plan']['file']); audit(backend_plan['inputs'])
                    assert bound(backend_plan['attempt']) == bound(selected['attempt'])
            elif name == 'maintained8':
                assert child['inputsUnchanged'] and all(t['pass'] for t in child['tests'])
                audit(child['inputs'])
                for key in ['attempt', 'api', 'runtime', 'base']:
                    assert bound(child[key]) == bound(selected[key])
                rows = []
                for test, command in zip(child['tests'], child['commands']):
                    assert test['name'] == command['name']
                    item = process(result_file.parent / ('process-' + test['name']) / 'process.json', command['command'])
                    assert read(item['receipt']['file']) == test['process']; rows.append(item)
                assert len(rows) == 8
                row['processes'] = rows
                maintained_started = min(x['started'] for x in rows)
            elif name == 'prepare-backend81':
                assert bound(child['selectedAttempt']) == bound(selected['attempt'])
                assert bound(child['selectedApi']) == bound(selected['api']) and bound(child['selectedRuntime']) == bound(selected['runtime'])
                audit(child['inputs']); audit(child['output'])
            else:
                raise AssertionError('Unrecognized planned gate: ' + name)
            if job['stage'] == 'focused-controls':
                focused_finished.append(row['process']['finished'])
            report['jobs'].append(row)
        assert maintained_started is not None and max(focused_finished) <= maintained_started
        assert len(report['jobs']) == len(plan['jobs'])
        report['focusedBeforeMaintained'] = True
        report['countExecutionAlias'] = next((r for r in report['jobs'] if r['disposition'] == 'previous-same-selected-image-execution'), None)
        report['releaseFollowup'] = dict(assessed=False, required=['full runtime and compiler-request decisions',
            'release.mjs install/verify', '42-step CLI smoke', 'installed-release-receipt-v2.py', 'portable publication and smoke', 'protected103'])
        report['selectionSlots'] = {name: dict(status='not-joined', receipt=None, requiredBinding=binding) for name, binding in {
            'runtime': 'Same selected API/runtime; complete45-case/669-sample comparison and exact oracles, with honest drift/regression review.',
            'compilerRequests': 'Same selected attempt/API/runtime; saved request outputs and controlled baseline/TypeScript comparison.',
            'installed': 'Unchanged installed-release receipt: same attempt/API/runtime/live source, install+verify and42CLI checks plus protected103.',
            'portable': 'Same selected attempt/API/runtime and45 exact module bindings, unchanged reference bundle and actual portable smoke.',
            'accounting': 'Closed campaign cutoff and interval union; no claim of CPU or waiting time from unrecorded wall time.'}.items()}
        report['scope'] = 'Actual selected semantic observations only. Existing count execution is explicitly aliased if requested; no fabricated execution or inherited different-image qualification. Backend81 requires exact historical outcome agreement, including shared failures. Installation, portable release and performance remain separate receipts.'
        for value in list(pins.values()):
            pin(value['file'], value, refresh=True)
        report.update(complete=True, passed=True, inputsUnchanged=True)
    except Exception:
        report['error'] = traceback.format_exc()
    report['inputs'] = list(pins.values())
    out.parent.mkdir(parents=True, exist_ok=True)
    with out.open('x') as stream:
        json.dump(report, stream, indent=2); stream.write('\n')
    print(json.dumps(dict(complete=report['complete'], passed=report['passed'], jobs=len(report['jobs']), out=str(out), error=report.get('error'))))
    return 0 if report['passed'] else 1


if __name__ == '__main__':
    raise SystemExit(main())
