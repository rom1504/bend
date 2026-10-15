#!/usr/bin/env python3
"""Prepare/run/collect two fresh TS/Bun full-source context requests; root runs targets."""
import argparse
import hashlib
import json
import math
import os
from pathlib import Path
import re
import shutil
import statistics
import subprocess
import sys

sys.dont_write_bytecode = True
ROOT = next(parent for parent in Path(__file__).resolve().parents
            if (parent / 'selfhost/tools/performance/phase86/reference.mjs').is_file())
PERF = ROOT / 'selfhost/tools/performance'


def pin(file):
    file = Path(file).resolve(strict=True); h = hashlib.sha256()
    with file.open('rb') as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b''): h.update(block)
    return dict(file=str(file), sha256=h.hexdigest(), bytes=file.stat().st_size)


def read(file): return json.loads(Path(file).read_text())


def verify(row):
    assert pin(row['file']) == row, row['file']
    return row


def save(file, value, exclusive=False):
    with Path(file).open('x' if exclusive else 'w') as stream:
        json.dump(value, stream, indent=2); stream.write('\n')


def same(a, b): return all(a[k] == b[k] for k in ['sha256', 'bytes'])


def prepare(a):
    out = a.out.resolve(); assert out.is_relative_to(ROOT / 'selfhost/build/phase98') and not out.exists()
    inputs = {}
    def bind(value):
        item = verify(value) if isinstance(value, dict) else pin(value)
        assert inputs.setdefault(item['file'], item) == item
        return item
    screen_pin = bind(ROOT / 'selfhost/build/phase92/screen01/report.json'); screen = read(screen_pin['file'])
    assert screen['complete'] and screen['passed'] and screen['inputsUnchanged']
    provenance = screen['provenance']; bun = bind(provenance['bun']); worker = bind(provenance['referenceWorker'])
    assert worker['file'] == str(PERF / 'phase86/reference.mjs')
    survey_pin = bind(provenance['survey']); survey = read(survey_pin['file'])
    assert survey_pin['file'] == str(ROOT / 'selfhost/build/phase83/survey01/plan.json')
    ts = survey['roles']['typescript']; upstream_dir = Path(ts['bend']['file']).parent
    survey_upstream = [bind(row) for row in survey['inputs'] if row.get('file', '').startswith(str(upstream_dir) + '/')]
    assert len(survey_upstream) == 32
    for key in ['bend', 'compiler', 'base']: bind(ts[key])
    acquisition_pin = bind(a.acquisition); acquisition = read(acquisition_pin['file'])
    assert acquisition['complete'] and acquisition['holes'] == 0
    assert {'load', 'check', 'emit-c'} <= {row['name'] for row in acquisition['phases']}
    assert acquisition['upstream']['revision'] == '059266225b77c8ca256ac6b25ee5c21449bab151'
    assert acquisition['upstream']['status'] == ''
    source = bind(acquisition['source']); oracle = bind(acquisition['c'])
    assert source['sha256'] == '2a72bbdc3d757982d7dd4804d8a1312f9427e3b2822ed9d187424c2d9f4de051'
    assert oracle['file'] == str(ROOT / 'selfhost/build/phase98/origin-checked01/program.c')
    for row in [acquisition['method'], acquisition['host'], *acquisition['loadedFiles'], *acquisition['upstream']['inputs']]: bind(row)
    acquired = {row['file']:row for row in acquisition['upstream']['inputs']}
    assert all(acquired[row['file']] == row for row in survey_upstream)
    assert all(acquired[ts[key]['file']] == ts[key] for key in ['bend', 'compiler', 'base'])
    assert acquisition['loadedFiles'] == [source, ts['base']]
    old_pin = bind(PERF / 'phase92/full-reference.py')
    old_report_pin = bind(ROOT / 'selfhost/build/phase92/full-ts-bun01/report.json')
    old_report = read(old_report_pin['file']); assert old_report['complete'] and old_report['passed']
    assert old_report['bun'] == bun and old_report['worker'] == worker
    assert old_report['process']['rssLimitBytes'] == 3072 * 1024**2
    assert old_report['process']['availableFloorBytes'] == 4096 * 1024**2
    guard = bind(PERF / 'phase86/guard.py'); bind(PERF / 'programs/support.py'); python = bind(sys.executable)
    original = bind(__file__); out.mkdir(parents=True)
    frozen = out / 'method.py'; frozen.write_bytes(Path(__file__).read_bytes()); method = bind(frozen)
    assert same(original, method)
    jobs = []
    for index in [1, 2]:
        directory = out / ('run' + str(index).zfill(2)); prefix = directory / 'compiler'
        argv = [bun['file'], worker['file'], 'typescript', source['file'], str(prefix), '1']
        command = [python['file'], '-B', guard['file'], '--out', str(directory / 'guard'),
                   '--seconds', '180', '--rss-mib', '4096', '--available-mib', '16384', '--cpu', '3', '--', *argv]
        jobs.append(dict(index=index, out=str(directory), prefix=str(prefix), argv=argv, guardCommand=command))
    plan = dict(kind='phase98-full-source-typescript-context-plan', version=1, complete=True, targetsRun=False,
        source=source, oracle=oracle, acquisition=acquisition_pin, bun=bun, worker=worker,
        survey=survey_pin, upstream=acquisition['upstream']['revision'], method=method,
        previousMethod=old_pin, historicalFullSelf=old_report_pin,
        previousResources=dict(rssMiB=3072, availableMiB=4096, seconds=150),
        resources=dict(rssMiB=4096, availableMiB=16384, seconds=180, cpu='3', fileCapKiB=65536),
        jobs=jobs, inputs=list(inputs.values()),
        scope='Two fresh processes, one request each. Unchanged TypeScript reference loads/checks ordinary Base inside requestMs; native cached self-request excludes prepared-Base decoding and runtime preparation. Process wall includes startup, import, preparation, C write and teardown; Python authentication is outside clocks. Contextual ratio only, not a paired statistical speed claim or generated-program benchmark.')
    for row in plan['inputs']: verify(row)
    save(out / 'plan.json', plan, True)
    commands = [dict(name='ts-bun-full-self-' + str(job['index']), command=[python['file'], '-B', str(frozen), 'run', '--plan', str(out / 'plan.json'), '--index', str(job['index'])]) for job in jobs]
    commands.append(dict(name='collect', dataOnly=True, command=[python['file'], '-B', str(frozen), 'collect', '--plan', str(out / 'plan.json'), '--out', str(out / 'report.json')],
        optionalNativeContext='Append --native-self followed by completed same-source B1/B2 self-request reports to record contextual native/TS ratios.'))
    save(out / 'commands.json', commands, True)
    print(json.dumps(dict(complete=True, targetsRun=False, plan=str(out / 'plan.json'), commands=str(out / 'commands.json'))))


def authenticate_plan(path):
    plan_pin = pin(path); plan = read(path)
    assert plan['kind'] == 'phase98-full-source-typescript-context-plan' and plan['complete']
    assert plan['method'] == pin(__file__)
    for row in plan['inputs']: verify(row)
    assert [job['index'] for job in plan['jobs']] == [1, 2]
    return plan_pin, plan


def run(a):
    plan_pin, plan = authenticate_plan(a.plan); job = plan['jobs'][a.index - 1]
    out = Path(job['out']); assert not out.exists(); out.mkdir()
    assert shutil.disk_usage(ROOT).free >= 210 * 1024**2
    report = dict(kind='phase98-full-source-typescript-context-run', complete=False, passed=False,
                  plan=plan_pin, index=a.index, source=plan['source'], command=job['guardCommand'], method=pin(__file__))
    save(out / 'report.json', report)
    try:
        env = {k:v for k,v in os.environ.items() if not k.startswith('BEND_') and k not in ['NODE_OPTIONS', 'NODE_PATH']}
        done = subprocess.run(job['guardCommand'], cwd=ROOT, env=env, capture_output=True, text=True)
        (out / 'launcher.stdout').write_text(done.stdout); (out / 'launcher.stderr').write_text(done.stderr)
        report['launcherExit'] = done.returncode
        process = read(out / 'guard/process.json'); report['process'] = process
        assert done.returncode == 0 and process['complete'] and process['returncode'] == 0
        assert not process.get('stoppedFor') and not process.get('interrupted')
        assert process['command'][-len(job['argv']):] == job['argv']
        report['worker'] = pin(job['prefix'] + '.json'); value = read(report['worker']['file'])
        report['output'] = pin(job['prefix'] + '.1.c')
        assert value['role'] == 'typescript' and value['complete'] and not value.get('error')
        assert len(value['calls']) == 1 and value['calls'][0]['index'] == 1
        call = value['calls'][0]; assert call['observation'] == dict(status='ok', checked=True)
        assert same(report['output'], plan['oracle']) and same(call, plan['oracle'])
        assert Path(report['output']['file']).read_bytes() == Path(plan['oracle']['file']).read_bytes()
        assert json.loads((out / 'guard/stdout.log').read_text()) == value
        assert not (out / 'guard/stderr.log').read_bytes()
        assert math.isfinite(call['requestMs']) and call['requestMs'] > 0
        report.update(requestMs=call['requestMs'], importsMs=value['importsMs'], processWallMs=1000 * process['wallSeconds'],
                      maxRssKiB=value['maxRssKiB'], exactC=True)
        for row in plan['inputs']: verify(row)
        report.update(complete=True, passed=True, inputsUnchanged=True)
    except BaseException as error:
        report['error'] = repr(error); raise
    finally:
        report['captures'] = [pin(path) for path in [out / 'launcher.stdout', out / 'launcher.stderr', out / 'guard/process.json', out / 'guard/stdout.log', out / 'guard/stderr.log'] if path.exists()]
        save(out / 'report.json', report)
    print(json.dumps({key:report[key] for key in ['complete', 'passed', 'index', 'requestMs', 'processWallMs', 'exactC']}))


def collect(a):
    plan_pin, plan = authenticate_plan(a.plan); assert not a.out.exists(); rows = []; inputs = [plan_pin, pin(__file__)]
    for job in plan['jobs']:
        rp = pin(Path(job['out']) / 'report.json'); inputs.append(rp); row = read(rp['file'])
        assert row['kind'] == 'phase98-full-source-typescript-context-run' and row['complete'] and row['passed'] and row['inputsUnchanged']
        assert row['plan'] == plan_pin and row['index'] == job['index'] and row['source'] == plan['source']
        assert row['command'] == job['guardCommand'] and row['method'] == plan['method'] and row['launcherExit'] == 0
        for capture in row['captures']: inputs.append(verify(capture))
        process = read(Path(job['out']) / 'guard/process.json'); assert process == row['process']
        assert process['complete'] and process['returncode'] == 0 and not process.get('stoppedFor') and not process.get('interrupted')
        assert process['command'][-len(job['argv']):] == job['argv']
        assert process['rssLimitBytes'] == 4096 * 1024**2 and process['availableFloorBytes'] == 16384 * 1024**2
        output = verify(row['output']); inputs.append(output); inputs.append(verify(row['worker']))
        value = read(row['worker']['file']); assert value['role'] == 'typescript' and value['complete'] and len(value['calls']) == 1
        call = value['calls'][0]; assert call['index'] == 1 and call['observation'] == dict(status='ok', checked=True)
        assert json.loads((Path(job['out']) / 'guard/stdout.log').read_text()) == value
        assert not (Path(job['out']) / 'guard/stderr.log').read_bytes()
        assert same(output, plan['oracle']) and same(call, plan['oracle']) and row['exactC']
        assert Path(output['file']).read_bytes() == Path(plan['oracle']['file']).read_bytes()
        assert row['requestMs'] == call['requestMs'] and row['importsMs'] == value['importsMs']
        assert row['processWallMs'] == 1000 * process['wallSeconds']
        rows.append(dict(receipt=rp, index=job['index'], requestMs=row['requestMs'], importsMs=row['importsMs'], processWallMs=row['processWallMs'], exactC=True))
    medians = {key:statistics.median(row[key] for row in rows) for key in ['requestMs', 'importsMs', 'processWallMs']}
    native = []
    for file in a.native_self or []:
        rp = pin(file); inputs.append(rp); value = read(file)
        assert value['kind'] == 'phase98-native-qualification-request' and value['complete'] and value['passed'] and value['inputsUnchanged']
        assert value['source'] == value['producer']['source'] == plan['source'] and not value['row']['live']
        row = value['row']; assert row['passed']
        raw = {Path(item['file']).name:verify(item) for item in row['raw']}; inputs.extend(raw.values())
        assert read(raw['process.json']['file']) == row['process']
        process = row['process']; assert process['complete'] and process['returncode'] == 0 and not process.get('stoppedFor') and not process.get('interrupted')
        for key in ['source', 'binary', 'build']: inputs.append(verify(value['producer'][key]))
        assert process['command'] == row['command'] and value['producer']['binary']['file'] in process['command']
        assert plan['source']['file'] in process['command'] and not Path(raw['stdout.log']['file']).read_bytes()
        clocks = re.findall(r'^request=1 request_ms=(\d+) consumed_chars=(\d+)$', Path(raw['stderr.log']['file']).read_text(), re.M)
        assert len(clocks) == 1 and int(clocks[0][0]) == row['requestMs'] and int(clocks[0][1]) > 0
        inputs.append(verify(row['output']))
        metrics = dict(requestMs=row['requestMs'], processWallMs=1000 * process['wallSeconds'])
        native.append(dict(stage=value['producer']['stage'], receipt=rp, metricsMs=metrics,
                           ratiosNativeOverTs={key:metrics[key] / medians[key] for key in metrics}))
    for item in [*plan['inputs'], *inputs]: verify(item)
    report = dict(kind='phase98-full-source-typescript-context', complete=True, passed=True, inputsUnchanged=True,
        dataOnly=True, targetsRunByCollector=False, plan=plan_pin, source=plan['source'], oracle=plan['oracle'],
        rows=rows, mediansMs=medians, nativeContext=native, method=pin(__file__), inputs=inputs, scope=plan['scope'])
    a.out.parent.mkdir(parents=True, exist_ok=True); save(a.out, report, True)
    print(json.dumps(dict(complete=True, passed=True, mediansMs=medians, nativeContext=native, report=str(a.out))))


def main():
    assert __debug__
    p = argparse.ArgumentParser(description=__doc__); sub = p.add_subparsers(dest='mode', required=True)
    q = sub.add_parser('prepare'); q.add_argument('--acquisition', type=Path, required=True); q.add_argument('--out', type=Path, required=True)
    q = sub.add_parser('run'); q.add_argument('--plan', type=Path, required=True); q.add_argument('--index', type=int, choices=[1, 2], required=True)
    q = sub.add_parser('collect'); q.add_argument('--plan', type=Path, required=True); q.add_argument('--out', type=Path, required=True); q.add_argument('--native-self', type=Path, nargs='+')
    a = p.parse_args(); {'prepare':prepare, 'run':run, 'collect':collect}[a.mode](a)


if __name__ == '__main__': main()
