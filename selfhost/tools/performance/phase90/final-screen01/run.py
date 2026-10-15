#!/usr/bin/env python3
"""Six cases, two balanced cold rounds, three compiler hosts; root executes only."""
import argparse
import hashlib
import importlib.util
import json
import math
import os
from pathlib import Path
import re
import statistics
import subprocess
import sys
import time

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
P = ROOT / 'selfhost/tools/performance'
NODE = '/home/ai/.nvm/versions/node/v24.18.0/bin/node'
NATIVE = P / 'phase90/runtime-migration01/native.py'
CASES = ['small', 'numeric_closed', 'lexer_original', 'map_closed', 'functions65', 'unicode']
ROLES = ['ts-bun', 'js-b2', 'native']


def pin(file):
    file = Path(file).resolve(strict=True)
    h = hashlib.sha256()
    with file.open('rb') as stream:
        for part in iter(lambda: stream.read(1024*1024), b''):
            h.update(part)
    return dict(file=str(file), sha256=h.hexdigest(), bytes=file.stat().st_size)


def read(file):
    return json.loads(Path(file).read_text())


def save(file, value):
    Path(file).write_text(json.dumps(value, indent=2)+'\n')


def summary(rows):
    result = dict(cases={}, equalCaseGeometricRatios={}, samplesPerRoleCase=2)
    for name in CASES:
        group = {}
        for role in ROLES:
            selected = [x for x in rows if x['case'] == name and x['role'] == role]
            assert len(selected) == 2 and all(x['passed'] for x in selected)
            group[role] = {}
            for metric in ['requestMs', 'processWallMs', 'importsMs', 'basePreparationMs', 'runtimePreparationMs']:
                values = [x[metric] for x in selected if x.get(metric) is not None]
                group[role][metric] = dict(samples=values, median=statistics.median(values) if values else None)
            group[role]['requestRound2OverRound1'] = (selected[1]['requestMs']/selected[0]['requestMs']
                                                    if selected[0]['requestMs'] > 0 else None)
        for role in ['js-b2', 'native']:
            group[role]['ratiosToTsBun'] = {metric: group[role][metric]['median']/group['ts-bun'][metric]['median']
                                          for metric in ['requestMs', 'processWallMs']
                                          if group['ts-bun'][metric]['median'] > 0}
        result['cases'][name] = group
    for role in ['js-b2', 'native']:
        result['equalCaseGeometricRatios'][role] = {}
        for metric in ['requestMs', 'processWallMs']:
            ratios = [result['cases'][name][role]['ratiosToTsBun'].get(metric) for name in CASES]
            result['equalCaseGeometricRatios'][role][metric] = (
                math.exp(sum(math.log(x) for x in ratios)/len(ratios)) if all(x and x > 0 for x in ratios) else None)
    return result


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--b2-pins', type=Path, required=True)
    ap.add_argument('--native-admission', type=Path, required=True, help='Final native.py selection pointer')
    ap.add_argument('--out', type=Path, required=True)
    ap.add_argument('--check-only', action='store_true')
    ap.add_argument('--job-seconds', type=int, default=30)
    a = ap.parse_args()
    assert 1 <= a.job_seconds <= 90
    out = a.out.resolve()
    assert out.is_relative_to(ROOT/'selfhost/build/phase90') and not out.exists()
    inputs = {}

    def bind(record):
        file = record.get('file', record.get('path'))
        actual = pin(file)
        assert actual['sha256'] == record['sha256'], file
        if 'bytes' in record:
            assert actual['bytes'] == record['bytes'], file
        previous = inputs.setdefault(actual['file'], actual)
        assert previous == actual, file
        return actual

    def file(path):
        return bind(pin(path))

    for method in [__file__, HERE/'worker.mjs', NATIVE, P/'phase86/reference.mjs',
                   P/'phase86/guard.py', P/'programs/support.py', sys.executable]:
        file(method)
    screen_pin = file(ROOT/'selfhost/build/phase88/screen01/report.json')
    screen = read(screen_pin['file'])
    assert screen['complete'] and screen['allJobsSucceeded']
    survey_pin = file(ROOT/'selfhost/build/phase83/survey01/plan.json')
    survey = read(survey_pin['file'])
    historical_survey = next(x for x in screen['inputs'] if x.get('file', x.get('path')) == survey_pin['file'])
    assert bind(historical_survey) == survey_pin
    ts = survey['roles']['typescript']
    for record in ts.values():
        if isinstance(record, dict) and 'sha256' in record:
            bind(record)
    upstream_root = str(Path(ts['bend']['file']).parent) + '/'
    for record in survey['inputs']:
        path = record.get('file', record.get('path', ''))
        if path.startswith(upstream_root):
            bind(record)
    bun_receipt = file(ROOT/'selfhost/build/phase89/bun-install.json')
    bun = bind(read(bun_receipt['file'])['binary'])
    node = file(NODE)
    image_pins = file(a.b2_pins)
    pins = read(image_pins['file'])
    assert pins['kind'] == 'phase56-direct-image-pins'
    for key in ['producer', 'plan', 'attempt', 'emission', 'comparison', 'source', 'b1', 'b2', 'runtime', 'rootsReference', 'admission']:
        bind(pins[key])
    attempt = read(pins['attempt']['file'])
    assert attempt['kind'] == 'bend-development-attempt' and attempt['checked'] and attempt['artifactKind'] == 'derived-b1'
    assert attempt['api']['sha256'] == pins['b1']['sha256']
    assert bind(attempt['node']) == node
    for item in attempt['snapshot']['sources']:
        bind(item['frozen'])
    for item in attempt['artifacts']:
        bind(item)
    bootstrap = read(bind(attempt['bootstrapReport'])['file'])
    assert bootstrap['stage'] == 'upstream-bootstrap' and bootstrap['provenance']['verifiedAfterBuild']
    assert bootstrap['sourceSha256'] == pins['source']['sha256'] and bootstrap['exports'] == pins['roots']
    validation = read(file(Path(pins['attempt']['file']).parent/'validation-001/report.json')['file'])
    assert validation['complete'] and validation['pass'] and validation['strictExact']
    emission, comparison = read(pins['emission']['file']), read(pins['comparison']['file'])
    assert emission['kind'] == 'phase55-split-compiler-emission' and emission['complete'] and emission['pass']
    assert bind(emission['module']) == bind(pins['b2'])
    assert emission['subject']['attempt']['sha256'] == pins['attempt']['sha256']
    assert comparison['kind'] == 'phase55-direct-compiler-driver-comparison'
    assert comparison['complete'] and comparison['pass'] and comparison['observations'] == 8
    for role in ['source', 'direct']:
        probe = read(bind(comparison[role])['file'])
        assert probe['complete'] and probe['pass'] and probe['emission']['sha256'] == pins['emission']['sha256']
    snapshot = Path(attempt['snapshot']['root'])
    b2 = dict(imagePins=image_pins, attempt=bind(pins['attempt']), api=bind(pins['b2']), generator=bind(pins['b1']),
              project=str(snapshot), driver=file(snapshot/'tools/typed-driver.mjs'), base=bind(attempt['base']),
              runtime=bind(attempt['runtime']), nativeRuntime=file(snapshot/'src/runtime/native/runtime.c'),
              nativeTemplate=file(snapshot/'src/runtime/native/runtime-template.json'))
    selected = [b2[k] for k in ['imagePins', 'attempt', 'api', 'driver', 'base', 'runtime', 'nativeRuntime', 'nativeTemplate']]
    selected += [file(snapshot/'tools'/name) for name in ['assemble.mjs', 'native-build.mjs', 'node-resource-args.mjs',
                                                       'compiler-abi.mjs', 'base-cache-graph.mjs']]
    b2['selectedInputs'] = selected
    spec = importlib.util.spec_from_file_location('phase90_final_native_launcher', NATIVE)
    native = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(native)
    admission, binding = native.load(a.native_admission)
    for record in binding.values():
        bind(record)
    for key in ['binary', 'base', 'runtime', 'template']:
        bind(admission[key])
    for record in admission['parts'] + admission['effects'] + [admission['cache']['carrier']]:
        bind(record)
    assert b2['base']['sha256'] == admission['base']['sha256'] == ts['base']['sha256']
    assert b2['nativeRuntime']['sha256'] == admission['runtime']['sha256']
    assert b2['nativeTemplate']['sha256'] == admission['template']['sha256']
    cases = {}
    for name in CASES:
        source = file(screen['cases'][name])
        expected_source = next(x for x in screen['inputs'] if x.get('file', x.get('path')) == source['file'])
        assert bind(expected_source) == source
        reference = next(x for x in screen['rows'] if x['case'] == name and x['role'] == 'typescript')
        assert reference['guard']['complete'] and reference['guard']['returncode'] == 0 and len(reference['outputs']) == 1
        cases[name] = dict(input=source, tsOracle={k: reference['outputs'][0][k] for k in ['sha256', 'bytes']})
    report = dict(kind='phase90-final-compiler-six-case-screen', complete=False, passed=False,
        checkOnly=a.check_only, executionPerformed=False, method=pin(__file__), nativeBinding=binding,
        nativeAdmission=admission, b2ImagePins=image_pins, tsBaseline=screen_pin, tsSurvey=survey_pin,
        bun=bun, node=node, rounds=2, roles=ROLES, cases=CASES, rows=[], inputs=list(inputs.values()),
        scope='Six selected compilation workloads, two balanced fresh-process rounds; performance/output screen only. '
              'B2/native use separately prepared API/Base products; TS does ordinary load/check/emit including Base. '
              'Native Base decode is outside native request_ms and inside process time. B2 cache decode is inside inspect time. '
              'Process clocks include each measurement worker and output validation; B2 validation is also itemized, '
              'and this is not a production CLI startup comparison. No full-conformance, compiled-program-speed or general-parity claim.')
    out.mkdir(parents=True)
    save(out/'preflight.json', report)

    def unchanged():
        for p in inputs.values():
            assert pin(p['file']) == p, p['file']
        assert native.load(a.native_admission) == (admission, binding)

    if a.check_only:
        unchanged()
        report.update(complete=True, passed=True, inputsUnchanged=True, targetJobsRun=0)
        save(out/'preflight.json', report)
        print(json.dumps(dict(complete=True, targetJobsRun=0, preflight=pin(out/'preflight.json'))))
        return

    def guarded(name, argv):
        directory = out/(name+'-guard')
        command = [sys.executable, '-B', str(P/'phase86/guard.py'), '--out', str(directory),
                   '--seconds', str(a.job_seconds), '--rss-mib', '2048', '--available-mib', '4096', '--cpu', '3', '--', *argv]
        env = {k:v for k,v in os.environ.items() if not k.startswith('BEND_') and k not in ['NODE_OPTIONS', 'NODE_PATH']}
        result = subprocess.run(command, cwd=ROOT, env=env, capture_output=True, text=True)
        process = read(directory/'process.json') if (directory/'process.json').exists() else {}
        row = dict(command=command, guard=str(directory), guardReturncode=result.returncode, process=process,
                   guardStdout=result.stdout, guardStderr=result.stderr)
        assert result.returncode == 0 and process.get('complete') and process.get('returncode') == 0 and not process.get('stoppedFor'), row
        return row

    error = None
    started = time.monotonic()
    try:
        plan = dict(kind='phase90-final-compiler-six-case-plan', node=node, b2=b2, cases=cases,
                    requestInputs=list(inputs.values()))
        save(out/'prepare-plan.json', plan)
        report['executionPerformed'] = True
        setup = guarded('prepare', [NODE, '--stack-size=4096', '--max-old-space-size=1024', str(HERE/'worker.mjs'),
                                  str(out/'prepare-plan.json'), 'prepare', '-', str(out/'prepare')])
        preparation = file(out/'prepare/report.json')
        prepared = read(preparation['file'])
        assert prepared['complete'] and prepared['pass'] and prepared['inputsUnchanged']
        assert [x['case'] for x in prepared['calls']] == CASES
        b2['cache'] = [bind(p) for p in prepared['cache']]
        for row in prepared['calls']:
            cases[row['case']]['b2Oracle'] = bind(row['output'])
        plan.update(preparation=preparation, requestInputs=list(inputs.values()))
        save(out/'plan.json', plan)
        file(out/'plan.json')
        report['preparation'] = dict(job=setup, report=preparation, importsMs=prepared['importsMs'],
            basePreparationMs=prepared['basePreparationMs'], oracleRequestsMs=[x['requestMs'] for x in prepared['calls']],
            scope='Separate shared-process Base preparation and six correctness oracles; excluded from measured request medians.')
        report['oracles'] = cases
        campaign = time.monotonic()
        for rnd in range(2):
            for ix, name in enumerate(CASES):
                order = ROLES[ix % 3:] + ROLES[:ix % 3]
                if rnd:
                    order = list(reversed(order))
                for position, role in enumerate(order):
                    source = cases[name]['input']
                    assert pin(source['file']) == source
                    label = f'{rnd+1}-{name}-{role}'
                    prefix = out/label
                    if role == 'native':
                        argv = native.native_args(admission, source['file'], prefix, 1)
                    elif role == 'ts-bun':
                        argv = [bun['file'], str(P/'phase86/reference.mjs'), 'typescript', source['file'], str(prefix), '1']
                    else:
                        argv = [NODE, '--stack-size=4096', '--max-old-space-size=1024', str(HERE/'worker.mjs'),
                                str(out/'plan.json'), 'request', name, str(prefix)]
                    job = guarded(label, argv)
                    row = dict(round=rnd+1, case=name, role=role, position=position+1, job=job,
                               processWallMs=1000*job['process']['wallSeconds'], peakRssBytes=job['process'].get('peakTreeRssBytes'),
                               importsMs=None, basePreparationMs=None, runtimePreparationMs=None, passed=False)
                    report['rows'].append(row)
                    if role == 'native':
                        logs = (Path(job['guard'])/'stderr.log').read_text()
                        requests = list(map(int, re.findall(r'request=\d+ request_ms=(\d+)', logs)))
                        assert len(requests) == 1
                        row['requestMs'] = requests[0]
                        for key, field in [('base_prepare_ms', 'basePreparationMs'), ('runtime_prepare_ms', 'runtimePreparationMs')]:
                            values = re.findall(key+r'=(\d+)', logs)
                            assert len(values) == 1, (key, values)
                            row[field] = int(values[0])
                        row['output'] = pin(str(prefix)+'.1.c')
                    else:
                        result_file = prefix/'report.json' if role == 'js-b2' else Path(str(prefix)+'.json')
                        result = read(result_file)
                        assert result['complete'] and len(result['calls']) == 1 and not result.get('error')
                        if role == 'js-b2':
                            assert result['pass'] and result['inputsUnchanged']
                            row['workerValidationMs'] = dict(inputs=result['inputValidationMs'],
                                output=result['calls'][0]['outputValidationMs'], final=result['finalVerificationMs'])
                        observation = result['calls'][0]
                        assert observation['observation']['status'] == 'ok' and observation['observation']['checked']
                        row.update(importsMs=result['importsMs'], requestMs=observation['requestMs'], workerReport=pin(result_file))
                        row['output'] = (bind(observation['output']) if role == 'js-b2' else pin(str(prefix)+'.1.c'))
                    oracle = cases[name]['tsOracle' if role == 'ts-bun' else 'b2Oracle']
                    row['exactC'] = all(row['output'][k] == oracle[k] for k in ['sha256', 'bytes'])
                    if role != 'ts-bun':
                        row['exactC'] = row['exactC'] and Path(row['output']['file']).read_bytes() == Path(oracle['file']).read_bytes()
                    row['passed'] = bool(row['exactC'])
                    save(out/'report.json', report)
                    print(json.dumps({k: row[k] for k in ['round', 'case', 'role', 'requestMs', 'processWallMs', 'exactC']}), flush=True)
                    assert row['passed'], 'Complete C output changed'
        report['timedCampaignSeconds'] = time.monotonic()-campaign
        report['summary'] = summary(report['rows'])
    except BaseException as exc:
        error = exc
        report['error'] = f'{type(exc).__name__}: {exc}'
    try:
        unchanged()
        report['inputsUnchanged'] = True
    except BaseException as exc:
        error = error or exc
        report['inputVerificationError'] = f'{type(exc).__name__}: {exc}'
    report.update(complete=error is None and len(report['rows']) == 36,
                  passed=error is None and len(report['rows']) == 36,
                  executionAndFinalVerificationSeconds=time.monotonic()-started, inputs=list(inputs.values()))
    save(out/'report.json', report)
    if error:
        raise error


if __name__ == '__main__':
    main()
