#!/usr/bin/env python3
"""Compare isolated upstream-built native B1 compilers; never qualify a new B2."""
import argparse, hashlib, importlib.util, json, math, re, shutil, statistics, sys, time
from pathlib import Path
sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[4]
P = ROOT/'selfhost/tools/performance'; BUILD = ROOT/'selfhost/build/phase98'
sys.path.insert(0, str(P/'phase92/comparison'))
from support import authenticate, native_args, pin, read, verify, unchanged
spec = importlib.util.spec_from_file_location('program_support', P/'programs/support.py')
S = importlib.util.module_from_spec(spec); spec.loader.exec_module(S)
SHA = lambda b: hashlib.sha256(b).hexdigest()

def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--mode', choices=['screen'], required=True)
    p.add_argument('--out', type=Path, required=True); p.add_argument('--rounds', type=int, default=4)
    p.add_argument('--checked', type=Path, required=True)
    p.add_argument('--build-guard', type=Path, required=True)
    p.add_argument('--binary', type=Path, required=True)
    p.add_argument('--recipe', type=Path, required=True)
    a = p.parse_args(); out = a.out.resolve()
    assert out.is_relative_to(BUILD) and not out.exists() and a.rounds == 4
    out.mkdir(parents=True)
    report = dict(complete=False, mode=a.mode, started=time.time(), inputs=[], rows=[], cases=[],
                  rounds=a.rounds, executionPerformed=False,
                  scope='Upstream-built native B1 only; identical request assets/cache and Clang O2 flags. Six frozen sources, four balanced rounds and complete checked diagnostics are required. No candidate B2 qualification, Clang rerun, or generated-program runtime measurement. Request excludes preparation; process wall includes startup/preparation/write/teardown.')
    pins = {}
    def bind(value):
        item = verify(value) if isinstance(value, dict) else pin(value)
        assert pins.setdefault(item['file'], item) == item
        report['inputs'] = list(pins.values()); return item
    def load(file): bind(file); return read(file)
    def save(): S.save(out/'report.json', report)
    try:
        for file in [Path(__file__), P/'phase92/comparison/support.py', P/'programs/support.py', P/'phase98/compiler-compare-derivation.json']:
            bind(file)
        ctx = authenticate(ROOT/'selfhost/build/phase92/upstream-b1/build.json')
        report['baseline'] = ctx
        for item in ctx['inputs']: bind(item)
        checked = load(a.checked)
        assert checked['complete'] and checked['holes'] == 0 and checked['upstream']['revision'] == ctx['upstream']
        assert {'load','check','emit-c'} <= {x['name'] for x in checked['phases']}
        for item in [checked['source'], checked['c'], checked['method'], checked['host'],
                     *checked['loadedFiles'], *checked['upstream']['inputs']]: bind(item)
        recipe = load(a.recipe)
        assert recipe['complete'] and recipe['candidate'] == checked['source']
        origin = recipe.get('original', recipe.get('source'))
        assert origin['sha256'] == ctx['source']['sha256']
        def bind_recipe(value):
            if isinstance(value, dict):
                if {'file','sha256','bytes'} <= value.keys(): bind(value)
                else:
                    for child in value.values(): bind_recipe(child)
            elif isinstance(value, list):
                for child in value: bind_recipe(child)
        bind_recipe(recipe)
        replay = Path(origin['file']).read_text()
        for change in recipe['changes']:
            old_text, new_text = change.get('before', change.get('old')), change.get('after', change.get('new'))
            if 'offset' in change:
                offset = change['offset']; assert replay[offset:offset+len(old_text)] == old_text
                replay = replay[:offset]+new_text+replay[offset+len(old_text):]
            else:
                assert replay.count(old_text) == 1
                replay = replay.replace(old_text, new_text, 1)
        assert 'insertion' not in recipe, 'Literal helper insertion requires separate replay support'
        assert replay.encode() == Path(checked['source']['file']).read_bytes()
        report['candidateRecipe'] = bind(a.recipe)
        report['patchReplayedFromBaseline'] = True
        build = load(a.build_guard/'process.json')
        assert build['complete'] and build['returncode'] == 0 and not build.get('stoppedFor')
        for file in ['inputs.json','method.json','stdout.log','stderr.log']: bind(a.build_guard/file)
        for item in read(a.build_guard/'inputs.json'):
            bind(dict(file=item['path'], sha256=item['sha256'], bytes=item['bytes']))
        candidate = bind(a.binary); clang = ctx['clang']['file']
        tail = build['command'][build['command'].index(clang):]
        assert len(tail) == 9 and tail[5] == '-o'
        assert str((ROOT/tail[4]).resolve()) == checked['c']['file'] and str((ROOT/tail[6]).resolve()) == candidate['file']
        assert tail[:4]+tail[5:6]+tail[7:] == ctx['optimizationFlags']
        report['candidate'] = dict(binary=candidate, source=checked['source'], c=checked['c'], build=build)
        old = load(ROOT/'selfhost/build/phase90/final-screen01/report.json'); assert old['complete']
        cases = [dict(name=k, source=bind(v['input']), oracle=bind(v['b2Oracle'])) for k,v in old['oracles'].items()]
        assert len(cases) == len({x['name'] for x in cases}) == 6
        clock_line = r'^(?:base_prepare_ms=\d+|runtime_prepare_ms=\d+|request=\d+ request_ms=\d+ consumed_chars=\d+)\n'
        expected_diagnostic = 'ALL PROOFS CHECK\nUse --verdict for mathematical validity.\n\n'
        report['expectedDiagnostic'] = dict(text=expected_diagnostic, sha256=SHA(expected_diagnostic.encode()),
                                             scope='Exact stderr after removing only the three clock lines; stdout must remain empty.')
        report['cases'] = cases; save()
        with S.ExecutionGuard(rss_mib=2048, available_mib=4096) as guard:
            for rnd in range(report['rounds']):
                for index, case in enumerate(cases):
                    roles = ['baseline','candidate'] if (rnd+index)%2 == 0 else ['candidate','baseline']
                    for role in roles:
                        assert shutil.disk_usage(ROOT).free > 160*1024**2
                        label = f'{rnd+1}-{case["name"]}-{role}'; prefix = out/label; directory = out/(label+'-guard')
                        argv = native_args(ctx, 'b1', case['source']['file'], prefix)
                        if role == 'candidate': argv[0] = candidate['file']
                        row = dict(round=rnd+1, case=case['name'], role=role, argv=argv, passed=False, raw=[])
                        report['rows'].append(row); report['executionPerformed'] = True; save()
                        command = ['bash','-c','ulimit -f 65536; ulimit -c 0; exec "$@"','phase98','taskset','-c','3',*argv]
                        row['deadlineSeconds'] = 60
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
                        diagnostic = re.sub(clock_line, '', logs, flags=re.M)
                        row['diagnosticExact'] = diagnostic == expected_diagnostic
                        row['diagnosticSha256'] = SHA(diagnostic.encode())
                        assert row['diagnosticExact'], ('Unexpected checked diagnostic', diagnostic)
                        row.update(requestMs=int(clocks[0][1]), consumedChars=int(clocks[0][2]), processWallMs=proc['wallSeconds']*1000)
                        assert 0 < row['requestMs'] <= row['processWallMs']+2
                        for key in ['base_prepare_ms','runtime_prepare_ms']:
                            values = re.findall(r'^'+key+r'=(\d+)$', logs, re.M); assert len(values) == 1
                            row[key] = int(values[0])
                        row['passed'] = True; save(); print(json.dumps({k:row[k] for k in ['case','role','round','exactC','requestMs','processWallMs']}), flush=True)
        assert len(report['rows']) == 48 and all(r['passed'] and r['exactC'] and r['diagnosticExact'] for r in report['rows'])
        summary = dict(exactCCount=len(report['rows']), exactDiagnosticCount=len(report['rows']), cases={})
        if a.mode == 'screen':
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
