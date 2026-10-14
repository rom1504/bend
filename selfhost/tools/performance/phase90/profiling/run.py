#!/usr/bin/env python3
"""One authenticated late native-self prefix; never a compilation qualification."""
import argparse
import json
import subprocess
import sys
from pathlib import Path

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
PERF = ROOT / 'selfhost/tools/performance'
OLD = PERF / 'phase89/partial-capture'
sys.path.insert(0, str(PERF / 'phase88'))
from native_support import native_args, pin, verify, require


def read(path):
    return json.loads(Path(path).read_bytes())


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('out', type=Path)
    p.add_argument('--seconds', type=int, choices=[180, 240], default=240)
    p.add_argument('--watchdog', type=Path, required=True)
    p.add_argument('--watchdog-build', type=Path, required=True)
    p.add_argument('--sampler', type=Path, default=ROOT / 'selfhost/build/phase89/partial-libs01/sampler.so')
    p.add_argument('--check-only', action='store_true')
    a = p.parse_args()
    gate_path = ROOT / 'selfhost/build/phase89/native-b1-nine-gates01/gates.json'
    failed_path = gate_path.with_name('report.json')
    controls_path = ROOT / 'selfhost/build/phase89/partial-self02/report.json'
    table = ROOT / 'selfhost/build/phase89/ownership-self01-table/table.json'
    gate, controls, build = read(gate_path), read(controls_path), read(a.watchdog_build)
    require(controls['inputsUnchanged'], 'Prior controls changed inputs')
    by_name = {r['name']: r for r in controls['rows']}
    require(by_name['normal-map']['compilationPassed'] and by_name['normal-map']['exactC']
            and by_name['normal-map']['diagnosticUsable']
            and by_name['stopped-map']['diagnosticUsable'], 'Missing successful sampler controls')
    prior_sampler = [v for v in controls['inputs'] if v['file'].endswith('/sampler.so')]
    require(len(prior_sampler) == 1 and pin(a.sampler)['sha256'] == prior_sampler[0]['sha256'],
            'Sampler differs from the controlled exact-image library')
    derivation = read(HERE / 'watchdog.derivation.json')
    require(derivation['exactReverse'] and verify(derivation['baseline'])
            and verify(derivation['candidate']), 'Watchdog source derivation changed')
    old_text = Path(derivation['baseline']['file']).read_text()
    require((HERE / 'watchdog.c').read_text().replace('value > 240', 'value > 120') == old_text,
            'Unexpected watchdog implementation change')
    command = build['command']
    require(build.get('complete') and build.get('returncode') == 0
            and str((HERE / 'watchdog.c').resolve()) in command
            and '-o' in command and Path(command[command.index('-o') + 1]).resolve() == a.watchdog.resolve()
            and '-shared' in command and '-fPIC' in command, 'Wrong watchdog build receipt')
    build_inputs = read(a.watchdog_build.with_name('inputs.json'))
    source_build_pins = [v for v in build_inputs if v['path'] == str((HERE / 'watchdog.c').resolve())]
    require(len(source_build_pins) == 1 and source_build_pins[0]['sha256'] == pin(HERE / 'watchdog.c')['sha256'],
            'Watchdog source was not pinned by the build guard')

    # Reuse the old complete authentication, including the actual failed self
    # receipt, without running any compiler target or weakening its admission.
    authentication = subprocess.run([sys.executable, '-B', str(OLD / 'run-v2.py'), str(a.out),
        '--sampler', str(a.sampler), '--watchdog', str(a.watchdog),
        '--self-after', str(failed_path), '--check-only'], capture_output=True, text=True)
    require(authentication.returncode == 0, 'Previous admission refused: ' + authentication.stderr)
    inputs = [verify(v) for v in controls['inputs']]
    inputs += [verify(by_name[name][key]) for name in ['normal-map', 'stopped-map']
               for key in ['samples', 'analysis']]
    inputs += [pin(path) for path in [controls_path, gate_path, failed_path, a.sampler, a.watchdog,
        a.watchdog_build, a.watchdog_build.with_name('inputs.json'), __file__,
        HERE / 'windows.py', HERE / 'watchdog.c', HERE / 'watchdog.derivation.json']]
    require(gate['nativeB1']['image']['sha256'] ==
            '8bacae268296d6fe16d02ce50a7a2189bd587506c074532c6e5d74e622716e45', 'Wrong Phase89 native image')
    if a.check_only:
        print(json.dumps(dict(complete=True, targetExecuted=False, inputs=len(inputs),
            seconds=a.seconds, periodUs=16000, expectedSamples=a.seconds * 1000000 // 16000)))
        return

    out = a.out.resolve()
    out.mkdir(parents=True, exist_ok=False)
    report = dict(kind='phase90-late-self-capture', complete=False, diagnosticUsable=False,
        compilationPassed=False, inputs=inputs, image=gate['nativeB1']['image'],
        source=gate['source'], periodUs=16000, captureSeconds=a.seconds,
        authentication=json.loads(authentication.stdout), rows=[])

    def save():
        (out / 'report.json').write_text(json.dumps(report, indent=2) + '\n')

    save()
    try:
        cached = dict(gate['nativeB1'], cache=gate['cacheOrigin'])
        guard, samples, prefix = out / 'guard', out / 'self.samples', out / 'self'
        command = ['env', 'LD_PRELOAD=' + str(a.watchdog.resolve()) + ':' + str(a.sampler.resolve()),
            'BEND_SAMPLE_OUT=' + str(samples), 'BEND_SAMPLE_PERIOD_US=16000',
            'BEND_CAPTURE_SECONDS=' + str(a.seconds), *native_args(cached, gate['source']['file'], prefix, 1)]
        report['command'] = command
        save()
        job = subprocess.run([sys.executable, '-B', str(PERF / 'phase86/guard.py'),
            '--out', str(guard), '--seconds', str(a.seconds + 30), '--cpu', '3', '--', *command],
            capture_output=True, text=True)
        process = read(guard / 'process.json')
        report.update(process=process, guardReturncode=job.returncode,
            guardStdout=job.stdout, guardStderr=job.stderr,
            outputs=[pin(path) for path in [Path(str(prefix) + '.1.c')] if path.exists()])
        save()
        require(process['command'][-len(command):] == command and 'stoppedFor' not in process
                and process.get('returncode') in [0, 77], 'Unexpected exit; retain failed capture')
        stopped = process['returncode'] == 77
        report['targetReturnedNormally'] = not stopped
        report['diagnosticStopped'] = stopped
        analyzer = OLD / 'analyze.py' if stopped else PERF / 'phase88/ownership/analyze.py'
        analysis = out / 'strict-analysis.json'
        command = [sys.executable, '-B', str(analyzer), '--samples', str(samples),
            '--binary', gate['nativeB1']['image']['file'], '--table', str(table),
            '--stderr', str(guard / 'stderr.log'), '--out', str(analysis)]
        if stopped:
            command += ['--process', str(guard / 'process.json')]
        analyzed = subprocess.run(command, capture_output=True, text=True)
        report.update(analyzerReturncode=analyzed.returncode, analyzerStdout=analyzed.stdout,
            analyzerStderr=analyzed.stderr, samples=pin(samples))
        save()
        require(analyzed.returncode == 0, 'Strict analyzer rejected capture; preserve raw failure')
        report.update(strictAnalysis=pin(analysis), diagnosticUsable=True)
        if stopped:
            subprocess.run([sys.executable, '-B', str(HERE / 'windows.py'), '--analysis', str(analysis),
                '--out', str(out / 'windows.json')], check=True)
            report['windows'] = pin(out / 'windows.json')
        report['complete'] = True
    except Exception as error:
        report['error'] = str(error)
        raise
    finally:
        changed = []
        for value in inputs:
            try:
                verify(value)
            except Exception as error:
                changed.append(dict(input=value, error=str(error)))
        report['inputsUnchanged'] = not changed
        if changed:
            report.update(complete=False, diagnosticUsable=False, changedInputs=changed)
        save()
        require(not changed, 'Inputs changed; diagnostic rejected')


if __name__ == '__main__':
    main()
