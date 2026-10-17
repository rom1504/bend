#!/usr/bin/env python3
"""Current native B1/B2 and pinned TS/Bun; serial, authenticated process clocks."""
import argparse
import importlib.util
import json
import math
import os
from pathlib import Path
import random
import re
import shutil
import statistics
import subprocess
import sys
import time

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
P = HERE.parent
spec = importlib.util.spec_from_file_location('native_launch', ROOT/'selfhost/tools/native/launch.py')
N = importlib.util.module_from_spec(spec)
spec.loader.exec_module(N)
pin, verify = N.pin, N.verify
ROLES = ['b1', 'b2', 'upstream']


def read(path):
    return json.loads(Path(path).read_text())


def save(path, data):
    temporary = Path(str(path) + '.tmp')
    temporary.write_text(json.dumps(data, indent=2) + '\n')
    temporary.replace(path)


def same(a, b):
    return all(a[k] == b[k] for k in ('sha256', 'bytes'))


def native_clocks(text):
    calls = re.findall(r'^request=(\d+) request_ms=(\d+) consumed_chars=(\d+)$', text, re.M)
    assert len(calls) == 1 and calls[0][0] == '1' and int(calls[0][2]) > 0, 'Missing/full request clock'
    result = dict(requestMs=int(calls[0][1]), consumedChars=int(calls[0][2]))
    for key in ('base_prepare_ms', 'runtime_prepare_ms'):
        values = re.findall(r'^' + key + r'=(\d+)$', text, re.M)
        assert len(values) == 1, ('Missing/duplicate preparation clock', key)
        result[key] = int(values[0])
    result['diagnostic'] = re.sub(
        r'^(?:base_prepare_ms=\d+|runtime_prepare_ms=\d+|request=\d+ request_ms=\d+ consumed_chars=\d+)\n', '', text, flags=re.M)
    return result


def prepare(corpus):
    release, selection = N.load(stage='b2')
    inputs = {}
    def bind(item):
        value = verify(item) if isinstance(item, dict) else pin(item)
        assert inputs.setdefault(value['file'], value) == value
        return value
    def document(path):
        return read(bind(path)['file'])
    bind(__file__); bind(HERE/'upstream.mjs'); bind(N.__file__)
    for path in [P/'phase46/execute.py', P/'phase86/guard.py', P/'programs/support.py', sys.executable]:
        bind(path)
    bind(selection['selection']); bind(selection['admission']); bind(release['source'])
    for stage in ('b1', 'b2'):
        producer = release['stages'][stage]
        build = document(producer['build'])
        assert build['complete'] and not build['cPatched'] and build['source'] == release['source']
        assert build['binary'] == producer['binary']
        bind(producer['binary']); bind(producer['c']); bind(build['clang']); bind(build['buildInputs'])
    assets = release['assets']
    for key in ['base', 'runtime', 'template']: bind(assets[key])
    for item in assets['parts'] + assets['effects']: bind(item)
    bind(assets['cache']['carrier'])
    upstream = document(ROOT/'selfhost/build/phase86/upstream.json')
    assert upstream['revision'] == '059266225b77c8ca256ac6b25ee5c21449bab151'
    for item in upstream['inputs']: bind(item)
    old_screen = document(ROOT/'selfhost/build/phase90/final-screen01/report.json')
    assert old_screen['complete'] and old_screen['passed']
    bun = bind(old_screen['bun'])
    ts = {key: next(item for item in upstream['inputs'] if item['file'].endswith('/'+name))
          for key, name in [('bend','bend.ts'), ('compiler','comp.ts'), ('base','base.bend')]}
    assert ts['base'] == assets['base']
    cases = []
    if corpus == 'screen':
        current = document(ROOT/'selfhost/build/phase99/phase102-b2-screen04/report.json')
        assert current['complete'] and current['passed']
        assert current['producers']['candidate']['binary'] == release['stages']['b2']['binary']
        for c in current['cases']:
            old = old_screen['oracles'][c['name']]
            assert c['source'] == old['input']
            cases.append(dict(name=c['name'], source=bind(c['source']),
                nativeOracle=bind(c['candidateOracle']), expectedDiagnostic=c['expectedDiagnostic'],
                upstreamOracle=old['tsOracle']))
        assert len(cases) == 6
    elif corpus == 'broad45':
        current = document(ROOT/'selfhost/build/phase102/native-chain04/broad45/report.json')
        assert current['complete'] and current['passed'] and current['inputsUnchanged']
        for stage in ('b1','b2'):
            assert current['producers'][stage]['binary'] == release['stages'][stage]['binary']
        rows = {(r['name'],r['stage']): r for r in current['rows']}
        for c in current['cases']:
            b1, b2 = [rows[c['name'], stage] for stage in ('b1', 'b2')]
            assert b1['passed'] and b2['passed'] and same(b1['output'], b2['output'])
            assert b1['source'] == b2['source'] == c['source']
            assert same(b1['diagnosticFile'], b2['diagnosticFile'])
            diagnostic = Path(bind(b2['diagnosticFile'])['file']).read_text()
            cases.append(dict(name=c['name'], source=bind(c['source']), original=bind(c['original']),
                nativeOracle=bind(b2['output']), expectedDiagnostic=diagnostic,
                expectedStdout=c['expectedStdout'], expectedStderr=c['expectedStderr'],
                expectedStdoutEvidence=bind(c['expectedStdoutEvidence']), runtimeArgs=c['runtimeArgs']))
        assert len(cases) == 45 and len({c['original']['sha256'] for c in cases}) == 23
    else:
        records = [document(ROOT/f'selfhost/build/phase102/native-chain04/{stage}-self/report.json')
                   for stage in ('b1', 'b2')]
        for stage, r in zip(('b1','b2'), records):
            assert r['complete'] and r['passed'] and r['source'] == release['source']
            assert r['producer']['binary'] == release['stages'][stage]['binary']
            bind(r['row']['output']); bind(r['row']['diagnosticFile'])
        assert same(records[0]['row']['output'], records[1]['row']['output'])
        assert same(records[0]['row']['diagnosticFile'], records[1]['row']['diagnosticFile'])
        cases.append(dict(name='compiler', source=release['source'],
            nativeOracle=records[1]['row']['output'], upstreamOracle=bind(release['stages']['b1']['c']),
            expectedDiagnostic=Path(records[1]['row']['diagnosticFile']['file']).read_text()))
    return release, selection, inputs, upstream['revision'], bun, ts, cases


def summarize(rows, cases):
    result = {}
    for mode in sorted({r['mode'] for r in rows if not r.get('acquisition')}):
        per_case = {}
        for case in cases:
            groups = {}
            for role in ROLES:
                sample = [r for r in rows if not r.get('acquisition') and r['mode']==mode
                          and r['case']==case['name'] and r['role']==role]
                assert sample and all(r['passed'] for r in sample)
                metrics = {}
                for key in ['processMs','requestMs','peakRssKiB','userSeconds','systemSeconds']:
                    values = [r[key] for r in sample]
                    metrics[key] = dict(median=statistics.median(values), min=min(values), max=max(values),
                                        samples=len(values))
                groups[role] = metrics
            ratios = {a+'/'+b: groups[a]['processMs']['median']/groups[b]['processMs']['median']
                      for a,b in [('b1','upstream'),('b2','upstream'),('b2','b1')]}
            per_case[case['name']] = dict(roles=groups, processRatios=ratios)
        geometric = {pair: math.exp(statistics.mean(math.log(c['processRatios'][pair]) for c in per_case.values()))
                     for pair in ['b1/upstream','b2/upstream','b2/b1']}
        entry = dict(cases=per_case, equalPointGeometricRatios=geometric)
        if all('original' in c for c in cases):
            originals = {c['original']['sha256'] for c in cases}
            entry['equalOriginalGeometricRatios'] = {
                pair: math.exp(statistics.mean(statistics.mean(
                    math.log(per_case[c['name']]['processRatios'][pair])
                    for c in cases if c['original']['sha256']==original) for original in originals))
                for pair in geometric}
        result[mode] = entry
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--corpus', choices=['screen','broad45','self'], required=True)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--rounds', type=int, default=4)
    parser.add_argument('--modes', default='prepared,live')
    parser.add_argument('--seed', type=int, default=10520261017)
    parser.add_argument('--check-only', action='store_true')
    args = parser.parse_args()
    assert 1 <= args.rounds <= 8
    modes = args.modes.split(',')
    assert len(set(modes))==len(modes) and set(modes) <= {'prepared','live'}
    out = args.out.resolve()
    assert out.is_relative_to(ROOT/'selfhost/build/phase105') and not out.exists()
    release, selection, inputs, revision, bun, ts, cases = prepare(args.corpus)
    out.mkdir(parents=True)
    save(out/'upstream.json', ts)
    inputs[str(out/'upstream.json')] = pin(out/'upstream.json')
    rng = random.Random(args.seed)
    schedule = []
    orders = {}
    for case in cases:
        order = ROLES.copy(); rng.shuffle(order); orders[case['name']] = order
    for rnd in range(args.rounds):
        shuffled = cases.copy(); rng.shuffle(shuffled)
        for case in shuffled:
            order = orders[case['name']]
            shift = rnd % len(order); order = order[shift:] + order[:shift]
            if (rnd//3)%2: order = list(reversed(order))
            mode_order = modes.copy(); rng.shuffle(mode_order)
            for mode in mode_order:
                for role in order:
                    schedule.append(dict(round=rnd+1,case=case['name'],mode=mode,role=role))
    report = dict(kind='phase105-current-native-upstream-compilation', complete=False, passed=False,
        started=time.time(), corpus=args.corpus, rounds=args.rounds, modes=modes, seed=args.seed,
        selection=selection, source=release['source'], stages=release['stages'], upstreamRevision=revision,
        bun=bun, upstream=ts, inputs=list(inputs.values()), cases=cases, schedule=schedule, rows=[],
        checkOnly=args.check_only, cpu='3', compilerThreads=1,
        scope='Fresh compiler child process including startup, preparation, C write and exit. Same high-resolution wrapper for all roles. Guard wall separately retains 20ms polling. No Clang or generated-program runtime in compiler clocks. Native prepared mode reuses Base; upstream always source Base. Live mode includes source Base for all. requestMs clocks have different boundaries and are diagnostic only.',
        machine=dict(uname=list(os.uname()), cpuinfo=Path('/proc/cpuinfo').read_text().split('\n\n')[0],
                     diskFreeBytes=shutil.disk_usage(ROOT).free))
    def checkpoint(): save(out/'report.json', report)
    checkpoint()
    def unchanged():
        for item in inputs.values(): verify(item)
        assert N.load(stage='b2') == (release, selection)
    if args.check_only:
        unchanged(); report.update(complete=True, passed=True, inputsUnchanged=True, targetJobs=0)
        checkpoint(); print(json.dumps(dict(complete=True, targetJobs=0, report=str(out/'report.json')))); return
    canonical = {}
    for c in cases:
        for key in ['nativeOracle', 'upstreamOracle']:
            item = c.get(key)
            if item and 'file' in item: canonical[item['sha256']] = item
    by_name = {c['name']:c for c in cases}
    def sample(planned, acquisition=False):
        assert shutil.disk_usage(ROOT).free > (256 if args.corpus=='self' else 192)*1024**2, 'Disk reserve'
        case = by_name[planned['case']]; role = planned['role']; mode = planned['mode']
        label = f"{len(report['rows']):04d}-{case['name']}-{mode}-{role}"
        prefix = out/label
        argv = (N.native_args(release, case['source']['file'], prefix, 1, mode=='live', role)
                if role != 'upstream' else [bun['file'],str(HERE/'upstream.mjs'),str(out/'upstream.json'),case['source']['file'],str(prefix)])
        seconds = 300 if args.corpus=='self' else 60
        rss = 6144 if args.corpus=='self' else 2048
        available = 16384 if rss>3072 else 4096
        command = [sys.executable,'-B',str(P/'phase86/guard.py'),'--out',str(prefix)+'-guard',
            '--seconds',str(seconds),'--rss-mib',str(rss),'--available-mib',str(available),'--cpu','3','--',
            sys.executable,'-B',str(P/'phase46/execute.py'),str(prefix)+'.child.json',*argv]
        row = dict(planned, acquisition=acquisition, passed=False, command=command)
        report['rows'].append(row); checkpoint()
        print(json.dumps(dict(starting=label, acquisition=acquisition)), flush=True)
        started = time.perf_counter()
        result = subprocess.run(command,cwd=ROOT,capture_output=True,text=True)
        row.update(supervisorMs=1000*(time.perf_counter()-started), guardExit=result.returncode)
        Path(str(prefix)+'.guard.stdout').write_text(result.stdout)
        Path(str(prefix)+'.guard.stderr').write_text(result.stderr)
        process_path = Path(str(prefix)+'-guard/process.json')
        row['guard'] = pin(process_path)
        process = read(process_path)
        assert result.returncode==0 and process['complete'] and process['returncode']==0 and not process.get('stoppedFor'), ('Guard failed', label)
        child_path = Path(str(prefix)+'.child.json'); child = read(child_path)
        row['child'] = pin(child_path)
        assert child['returncode']==0 and child['command']==argv
        row.update(processMs=1000*child['processSeconds'], guardWallMs=1000*process['wallSeconds'],
                   peakRssKiB=child['maxRssKiB'], peakTreeRssBytes=process['peakTreeRssBytes'],
                   userSeconds=child['userSeconds'], systemSeconds=child['systemSeconds'])
        output = pin(str(prefix)+'.1.c'); row['output']=output
        if role=='upstream':
            worker = read(str(prefix)+'.json'); row['worker'] = pin(str(prefix)+'.json')
            assert worker['complete'] and worker['checked'] and worker['holes']==0 and not worker.get('error')
            assert set(worker['loadedFiles']) <= {case['source']['file'], ts['base']['file']}, 'Unexpected import'
            row.update(requestMs=worker['requestMs'], importsMs=worker['importsMs'], checked=True)
            if acquisition:
                assert 'upstreamOracle' not in case
                case['upstreamOracle'] = output
                row['oracleAcquired'] = True
            oracle = case['upstreamOracle']
        else:
            decoded = native_clocks(child['stderr'])
            assert decoded.pop('diagnostic') == case['expectedDiagnostic'], 'Native verdict/diagnostic differs'
            row.update(decoded, exactDiagnostic=True)
            oracle = case['nativeOracle']
        assert same(output,oracle), ('Complete C differs', label)
        row.update(exactC=True, passed=True)
        # Only deduplicate a just-produced, validated output. Historical evidence
        # is never deleted. Every original request path remains a hard link.
        if output['sha256'] in canonical:
            prior = canonical[output['sha256']]
            verify(prior)
            assert Path(output['file']).read_bytes() == Path(prior['file']).read_bytes()
            Path(output['file']).unlink(); os.link(prior['file'],output['file'])
            row['sameBytesStoredAt'] = prior['file']
        else: canonical[output['sha256']] = output
        checkpoint()
        print(json.dumps({k:row[k] for k in ['case','mode','role','processMs','requestMs','passed']}), flush=True)
    try:
        # Closed45 differs from the runtime batch corpus. Acquire upstream's exact
        # current-source products first, then freeze them before timed repetitions.
        for c in cases:
            if 'upstreamOracle' not in c:
                sample(dict(round=0,case=c['name'],mode='prepared',role='upstream'),True)
        save(out/'oracles.json', cases)
        inputs[str(out/'oracles.json')] = pin(out/'oracles.json')
        report['inputs'] = list(inputs.values()); checkpoint()
        for planned in schedule: sample(planned)
        report['summary'] = summarize(report['rows'], cases)
        unchanged()
        report.update(complete=True, passed=True, inputsUnchanged=True)
    except BaseException as error:
        report['error'] = repr(error)
        raise
    finally:
        report.update(finished=time.time(), targetJobs=len(report['rows']))
        checkpoint()


if __name__ == '__main__': main()
