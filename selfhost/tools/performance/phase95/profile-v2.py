#!/usr/bin/env python3
"""Phase95 v2: explicit sampling period; all v1 quality gates are preserved."""
import argparse, importlib.util, json, pathlib, shutil, subprocess, sys, time
sys.dont_write_bytecode = True
ROOT = pathlib.Path(__file__).resolve().parents[4]
PERF = ROOT / 'selfhost/tools/performance'
sys.path.insert(0, str(PERF / 'phase92/comparison'))
from support import authenticate, native_args, pin
spec = importlib.util.spec_from_file_location('program_support', PERF / 'programs/support.py')
S = importlib.util.module_from_spec(spec); spec.loader.exec_module(S)
OWN = PERF / 'phase88/ownership'


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--case', choices=['map_closed', 'self'], required=True)
    p.add_argument('--out', type=pathlib.Path, required=True)
    p.add_argument('--sampler', type=pathlib.Path, required=True)
    p.add_argument('--sampler-build', type=pathlib.Path, required=True)
    p.add_argument('--table', type=pathlib.Path,
                   default=ROOT / 'selfhost/build/phase95/ownership-b1-table01/table.json')
    p.add_argument('--period-us', type=int, choices=[4000, 8000, 16000])
    p.add_argument('--check-only', action='store_true')
    a = p.parse_args()
    out, sampler, table_path = a.out.resolve(), a.sampler.resolve(), a.table.resolve()
    assert not out.exists(), 'Preserve earlier capture and failures'
    ctx = authenticate(ROOT / 'selfhost/build/phase92/upstream-b1/build.json')
    image = ctx['roles']['b1']['admission']['binary']
    table = json.loads(table_path.read_bytes())
    assert table['binary_sha256'] == image['sha256'] and table['binary'] == image['file']
    assert table['generator_sha256'] == pin(OWN / 'make-table.py')['sha256']
    assert table['header_sha256'] == pin(table_path.with_name('unwind-table.h'))['sha256']
    build = json.loads(a.sampler_build.read_bytes()); cmd = build['command']
    assert build['complete'] and build['returncode'] == 0 and not build.get('stoppedFor')
    assert not build.get('error') and not build.get('interrupted') and build.get('finished')
    assert any((ROOT / x).resolve() == OWN / 'sample-ownership.c' for x in cmd)
    assert cmd[cmd.index('-o') + 1] == str(sampler)
    assert ('-I' + str(table_path.parent) in cmd or
            any(x == '-I' and y == str(table_path.parent) for x, y in zip(cmd, cmd[1:])))
    screen_path = ROOT / 'selfhost/build/phase90/final-screen01/report.json'
    screen = json.loads(screen_path.read_bytes())
    if a.case == 'self':
        source, oracle, calls, period = ctx['source'], ctx['roles']['b2']['admission']['c'], 1, 8000
    else:
        row = screen['oracles'][a.case]
        source, oracle, calls, period = row['input'], row['b2Oracle'], 5, 4000
    if a.period_us is not None: period = a.period_us
    derived = pin(pathlib.Path(__file__).with_name('profile.py'))
    assert derived['sha256'] == '3771e8e319daef36e38e1c1b7dd57dddae632e04de4e2e37d629e738573c54df'
    for item in [source, oracle]: assert pin(item['file']) == item
    files = [__file__, derived['file'], table_path, table_path.with_name('unwind-table.h'), sampler,
             a.sampler_build, OWN / 'sample-ownership.c', OWN / 'make-table.py', OWN / 'analyze.py',
             PERF / 'phase68/parity-survey/sample-analysis-v2.py', PERF / 'programs/support.py',
             screen_path, sys.executable, *[shutil.which(x) for x in ['readelf', 'addr2line', 'nm']]]
    inputs = list({v['file']: v for v in [*ctx['inputs'], source, oracle, *map(pin, files)]}.values())
    command = ['taskset', '-c', '3', 'env', 'LD_PRELOAD=' + str(sampler),
               'BEND_SAMPLE_OUT=' + str(out / 'samples.txt'), 'BEND_SAMPLE_PERIOD_US=' + str(period),
               *native_args(ctx, 'b1', source['file'], out / 'program', calls)]
    if a.check_only:
        print(json.dumps(dict(complete=True, targetExecuted=False, inputs=len(inputs), command=command)))
        return
    parent = out.parent
    while not parent.exists(): parent = parent.parent
    assert shutil.disk_usage(parent).free >= 512 * 1024**2, 'Reserve disk for complete self C and raw evidence'
    out.mkdir(parents=True)
    report = dict(schema='phase95-physical-ownership-capture-v2', derivedFrom=derived, complete=False,
        compilationPassed=False, diagnosticUsable=False, case=a.case, role='b1', context=ctx,
        source=source, oracle=oracle, inputs=inputs, command=command, calls=calls, periodUs=period,
        limitations=['Physical cleanup callers only; no reconstruction of musttail-erased ancestors.',
            'Sample fractions include observer overhead and are not optimization speed estimates.',
            'No allocation counts or general allocation-caller attribution from this sampler.'])
    def save(): S.save(out / 'report.json', report)
    save()
    try:
        for item in inputs: assert pin(item['file']) == item
        with S.ExecutionGuard(rss_mib=2048, available_mib=4096) as guard:
            report['process'] = guard.run(['bash', '-c',
                'ulimit -f 65536; ulimit -c 0; exec "$@"', 'phase95', *command],
                out / 'guard', time.monotonic() + 240)
        report['outputs'] = []
        for i in range(1, calls + 1):
            product = out / f'program.{i}.c'
            if product.exists():
                value = pin(product)
                report['outputs'].append(dict(output=value,
                    exact=all(value[k] == oracle[k] for k in ['sha256', 'bytes'])))
        report['compilationPassed'] = bool(report['process']['complete'] and
            len(report['outputs']) == calls and all(v['exact'] for v in report['outputs']))
        if (out / 'samples.txt').exists(): report['samples'] = pin(out / 'samples.txt')
        save()
        assert report['compilationPassed'], 'Compiler/output failure; retain complete raw attempt'
        lines = (out / 'samples.txt').read_text().splitlines()
        header = dict(line.split('\t', 1) for line in lines[1:lines.index('MAPS')])
        report['samplerHeader'] = header
        report['samplingLossFree'] = all(int(header[k]) == 0 for k in
            ['overruns', 'dropped', 'thread_overflow', 'thread_clock_failures', 'timer_disarm_failures'])
        analysis_cmd = [sys.executable, '-B', str(OWN / 'analyze.py'), '--samples', str(out / 'samples.txt'),
            '--binary', image['file'], '--table', str(table_path), '--stderr', str(out / 'guard/stderr.log'),
            '--out', str(out / 'analysis.json')]
        report['analysisCommand'] = analysis_cmd; save()
        with (out / 'analysis.stdout.log').open('w') as stdout, (out / 'analysis.stderr.log').open('w') as stderr:
            result = subprocess.run(analysis_cmd, stdout=stdout, stderr=stderr, timeout=120)
        report['analysisReturncode'] = result.returncode
        report['analyzerAccepted'] = result.returncode == 0 and (out / 'analysis.json').exists()
        report['diagnosticUsable'] = report['analyzerAccepted'] and report['samplingLossFree']
        if (out / 'analysis.json').exists(): report['analysis'] = pin(out / 'analysis.json')
        report['complete'] = report['compilationPassed'] and report['diagnosticUsable']
        save()
        assert report['diagnosticUsable'], 'Analyzer or zero-loss gate rejected capture; raw evidence retained'
    except Exception as error:
        report['error'] = repr(error)
        raise
    finally:
        report['changedInputs'] = [v for v in inputs if not pathlib.Path(v['file']).exists() or pin(v['file']) != v]
        report['inputsUnchanged'] = not report['changedInputs']
        if report['changedInputs']: report.update(complete=False, diagnosticUsable=False)
        save()
    assert report['inputsUnchanged'], 'Inputs changed during acquisition'
    print(json.dumps(dict(complete=report['complete'], case=a.case,
        wallSeconds=report['process']['wallSeconds'], samples=report.get('samples'))))


if __name__ == '__main__': main()
