#!/usr/bin/env python3
"""Compare isolated upstream-built native B1 compilers; never qualify a new B2."""
import argparse, hashlib, importlib.util, json, math, re, shutil, statistics, sys, time
from pathlib import Path
sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[4]
P = ROOT/'selfhost/tools/performance'; BUILD = ROOT/'selfhost/build/phase95'
sys.path.insert(0, str(P/'phase92/comparison'))
from support import authenticate, native_args, pin, read, verify, unchanged
spec = importlib.util.spec_from_file_location('program_support', P/'programs/support.py')
S = importlib.util.module_from_spec(spec); spec.loader.exec_module(S)
CANDIDATE = '847898094f72898b11eb3ecb8b58ea9530d9ff00c592aabd716947c5543c8169'
SHA = lambda b: hashlib.sha256(b).hexdigest()

def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--mode', choices=['screen','broad45','self'], required=True)
    p.add_argument('--out', type=Path, required=True); p.add_argument('--rounds', type=int, default=4)
    a = p.parse_args(); out = a.out.resolve()
    assert out.is_relative_to(BUILD) and not out.exists() and 1 <= a.rounds <= 10
    out.mkdir(parents=True)
    report = dict(complete=False, mode=a.mode, started=time.time(), inputs=[], rows=[], cases=[],
                  rounds=a.rounds if a.mode == 'screen' else 1, executionPerformed=False,
                  scope='Upstream-built native B1 only; identical request assets/cache and Clang O2 flags. Self mode compiles baseline D04 input and preserves its expected unsafe proof refusal. No candidate B2 qualification, Clang rerun, or generated-program runtime measurement. Request excludes preparation; process wall includes startup/preparation/write/teardown.')
    pins = {}
    def bind(value):
        item = verify(value) if isinstance(value, dict) else pin(value)
        assert pins.setdefault(item['file'], item) == item
        report['inputs'] = list(pins.values()); return item
    def load(file): bind(file); return read(file)
    def save(): S.save(out/'report.json', report)
    try:
        for file in [Path(__file__), P/'phase92/comparison/support.py', P/'programs/support.py']:
            bind(file)
        ctx = authenticate(ROOT/'selfhost/build/phase92/upstream-b1/build.json')
        report['baseline'] = ctx
        for item in ctx['inputs']: bind(item)
        checked = load(BUILD/'membership-checked01/report.json')
        assert checked['complete'] and checked['holes'] == 0 and checked['upstream']['revision'] == ctx['upstream']
        assert {'load','check','emit-c'} <= {x['name'] for x in checked['phases']}
        for item in [checked['source'], checked['c'], checked['method'], checked['host'],
                     *checked['loadedFiles'], *checked['upstream']['inputs']]: bind(item)
        assert checked['source']['sha256'] == CANDIDATE
        changes = load(BUILD/'membership-candidate01/changes.json')
        assert changes['schema'] == 'phase95-membership-candidate-v1'
        assert changes['candidateSha256'] == CANDIDATE and changes['forwardReplayExact']
        assert len(changes['changes']) == 1 and not changes['targetsRun']
        for item in [changes['source'], changes['method'], changes['extraction'], changes['patchSource'],
                     *changes['outputs'].values()]: bind(item)
        assert changes['source']['sha256'] == ctx['source']['sha256']
        assert changes['outputs']['compiler.bend'] == checked['source']
        source = Path(changes['source']['file']).read_bytes()
        for change in changes['changes']:
            old, new, offset = change['old'].encode(), change['new'].encode(), change['offsetBytes']
            assert SHA(source) == change['beforeSha256'] and source[offset:offset+len(old)] == old
            source = source[:offset]+new+source[offset+len(old):]
            assert SHA(source) == change['afterSha256']
        assert source == Path(checked['source']['file']).read_bytes()
        build = load(BUILD/'membership-build01/process.json')
        assert build['complete'] and build['returncode'] == 0 and not build.get('stoppedFor')
        for file in ['inputs.json','method.json','stdout.log','stderr.log']: bind(BUILD/'membership-build01'/file)
        for item in read(BUILD/'membership-build01/inputs.json'):
            bind(dict(file=item['path'], sha256=item['sha256'], bytes=item['bytes']))
        candidate = bind(BUILD/'membership-checked01/compiler'); clang = ctx['clang']['file']
        tail = build['command'][build['command'].index(clang):]
        assert len(tail) == 9 and tail[5] == '-o'
        assert str((ROOT/tail[4]).resolve()) == checked['c']['file'] and str((ROOT/tail[6]).resolve()) == candidate['file']
        assert tail[:4]+tail[5:6]+tail[7:] == ctx['optimizationFlags']
        report['candidate'] = dict(binary=candidate, source=checked['source'], c=checked['c'], build=build)
        if a.mode == 'screen':
            old = load(ROOT/'selfhost/build/phase90/final-screen01/report.json'); assert old['complete']
            cases = [dict(name=k, source=bind(v['input']), oracle=bind(v['b2Oracle'])) for k,v in old['oracles'].items()]
            assert len(cases) == 6
        elif a.mode == 'self':
            source = bind(ctx['roles']['b2']['admission']['source'])
            oracle = bind(ctx['roles']['b2']['admission']['c'])
            assert (source['sha256'], source['bytes']) == (ctx['source']['sha256'], ctx['source']['bytes'])
            old = load(ROOT/'selfhost/build/phase92/self-b1-01/report.json')
            assert old['complete'] and old['passed'] and old['exactC']
            assert old['source'] == source and old['oracle'] == oracle
            expected_log = bind(ROOT/'selfhost/build/phase92/self-b1-01/guard/stderr.log')
            clock_line = r'^(?:base_prepare_ms=\d+|runtime_prepare_ms=\d+|request=\d+ request_ms=\d+ consumed_chars=\d+)\n'
            expected_diagnostic = re.sub(clock_line, '', Path(expected_log['file']).read_text(), flags=re.M)
            assert expected_diagnostic.startswith('SOME PROOFS FAIL\nError: 3987 defs rely on unsafe or foreign code:\n')
            report['expectedUnsafeDiagnostic'] = dict(source=expected_log, sha256=SHA(expected_diagnostic.encode()))
            cases = [dict(name='self-d04', source=source, oracle=oracle)]
        else:
            cases = []
            for name in ['pilot02','broad01']:
                old = load(ROOT/f'selfhost/build/phase93/{name}/report.json'); assert old['complete']
                for row in old['cases']:
                    assert row['passed'] and row['sameNativeC']
                    cases.append(dict(name=row['id'], source=bind(row['source']), oracle=bind(row['products']['own']['c'])))
            assert len(cases) == len({x['name'] for x in cases}) == 45
        report['cases'] = cases; save()
        with S.ExecutionGuard(rss_mib=2048, available_mib=4096) as guard:
            for rnd in range(report['rounds']):
                for index, case in enumerate(cases):
                    roles = ['candidate'] if a.mode == 'broad45' else (['baseline','candidate'] if (rnd+index)%2 == 0 else ['candidate','baseline'])
                    for role in roles:
                        assert shutil.disk_usage(ROOT).free > (210 if a.mode == 'self' else 160)*1024**2
                        label = f'{rnd+1}-{case["name"]}-{role}'; prefix = out/label; directory = out/(label+'-guard')
                        argv = native_args(ctx, 'b1', case['source']['file'], prefix)
                        if role == 'candidate': argv[0] = candidate['file']
                        row = dict(round=rnd+1, case=case['name'], role=role, argv=argv, passed=False, raw=[])
                        report['rows'].append(row); report['executionPerformed'] = True; save()
                        command = ['bash','-c','ulimit -f 65536; ulimit -c 0; exec "$@"','phase95','taskset','-c','3',*argv]
                        row['deadlineSeconds'] = 300 if a.mode == 'self' else 60
                        row['process'] = guard.run(command, directory, time.monotonic()+row['deadlineSeconds'])
                        for file in ['process.json','stdout.log','stderr.log']:
                            if (directory/file).exists(): row['raw'].append(pin(directory/file))
                        save(); proc = row['process']
                        assert proc['complete'] and proc['returncode'] == 0 and not proc.get('stoppedFor'), row
                        output = pin(str(prefix)+'.1.c'); row['output'] = output
                        row['exactC'] = Path(output['file']).read_bytes() == Path(case['oracle']['file']).read_bytes()
                        save(); assert row['exactC'], ('Complete C differs', row)
                        logs = (directory/'stderr.log').read_text()
                        clocks = re.findall(r'^request=(\d+) request_ms=(\d+) consumed_chars=(\d+)$', logs, re.M)
                        assert len(clocks) == 1 and clocks[0][0] == '1' and int(clocks[0][2]) > 0
                        assert not (directory/'stdout.log').read_text()
                        if a.mode == 'self':
                            diagnostic = re.sub(clock_line, '', logs, flags=re.M)
                            row['expectedUnsafeRefusalExact'] = diagnostic == expected_diagnostic
                            assert row['expectedUnsafeRefusalExact']
                        else:
                            assert 'SOME PROOFS FAIL' not in logs
                            assert len(re.findall(r'^ALL PROOFS CHECK$', logs, re.M)) == 1
                        row.update(requestMs=int(clocks[0][1]), consumedChars=int(clocks[0][2]), processWallMs=proc['wallSeconds']*1000)
                        assert 0 < row['requestMs'] <= row['processWallMs']+2
                        for key in ['base_prepare_ms','runtime_prepare_ms']:
                            values = re.findall(r'^'+key+r'=(\d+)$', logs, re.M); assert len(values) == 1
                            row[key] = int(values[0])
                        row['passed'] = True; save(); print(json.dumps({k:row[k] for k in ['case','role','round','exactC','requestMs','processWallMs']}), flush=True)
        summary = dict(exactCCount=len(report['rows']), cases={})
        if a.mode in ['screen','self']:
            for case in cases:
                rows = [r for r in report['rows'] if r['case'] == case['name']]; result = {}
                for metric in ['requestMs','processWallMs']:
                    values = {role:[r[metric] for r in rows if r['role'] == role] for role in ['baseline','candidate']}
                    med = {role:statistics.median(v) for role,v in values.items()}
                    pairs = [next(r[metric] for r in rows if r['round']==n and r['role']=='candidate')/next(r[metric] for r in rows if r['round']==n and r['role']=='baseline') for n in range(1,report['rounds']+1)]
                    result[metric] = dict(medians=med, ranges={k:[min(v),max(v)] for k,v in values.items()}, ratioOfMedians=med['candidate']/med['baseline'], pairedRatios=pairs, medianPairedRatio=statistics.median(pairs))
                summary['cases'][case['name']] = result
            summary['equalCaseGeometricRatios'] = {m:math.exp(statistics.mean(math.log(c[m]['ratioOfMedians']) for c in summary['cases'].values())) for m in ['requestMs','processWallMs']}
        unchanged(ctx)
        for item in pins.values(): assert pin(item['file']) == item, item
        report.update(complete=True, inputsUnchanged=True, summary=summary)
    except BaseException as exc:
        report['error'] = repr(exc); raise
    finally:
        report['finished'] = time.time(); save()

if __name__ == '__main__': main()
