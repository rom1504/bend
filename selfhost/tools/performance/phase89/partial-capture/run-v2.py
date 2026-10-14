#!/usr/bin/env python3
"""Serial normal/stopped sampler controls; optional prefix of a failed self run."""
import argparse
import json
import subprocess
import sys
from pathlib import Path

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
PERF = ROOT / 'selfhost/tools/performance'
sys.path.insert(0, str(PERF / 'phase88'))
from native_support import authenticate, native_args, DEFAULT_CACHE, pin, verify, require
GUARD = PERF / 'phase86/guard.py'
OWNERSHIP = PERF / 'phase88/ownership'
SOURCE = '4584cf083d9eddad6f1290c9472c3aac2708099caa716a27f5b53fbcbaee1618'


def read(path):
    return json.loads(Path(path).read_bytes())


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('out', type=Path)
    p.add_argument('--sampler', type=Path, required=True)
    p.add_argument('--watchdog', type=Path, required=True)
    p.add_argument('--gate', type=Path, default=ROOT / 'selfhost/build/phase89/native-b1-nine-gates01/gates.json')
    p.add_argument('--table', type=Path, default=ROOT / 'selfhost/build/phase89/ownership-self01-table/table.json')
    p.add_argument('--self-after', type=Path, help='Completed failed full-self report; enables one60s self capture')
    p.add_argument('--check-only', action='store_true')
    a = p.parse_args()
    gate, table = read(a.gate), read(a.table)
    require(gate.get('complete') is True and gate.get('passed') is True
            and gate.get('executionPerformed') is True and not gate.get('checkOnly')
            and gate.get('liveQualified') and gate.get('cacheQualifiedForThisExperiment')
            and len(gate['rows']) == 8 and all(r['passed'] and r['exactC'] for r in gate['rows']),
            'Expected eight completed nine-effect B1 live/cache gates')
    auth = authenticate(gate['nativeB1']['image']['file'], None)
    old = authenticate(ROOT / 'selfhost/build/phase88/compiler-native02', DEFAULT_CACHE)
    require(auth == gate['nativeB1'] and auth['source']['sha256'] == SOURCE == gate['source']['sha256'], 'Wrong native image/source')
    require(gate['cacheOrigin'] == old['cache'] and len(gate['nineEffects']) == 9, 'Wrong prepared cache/effect gate')
    require(gate['assets']['sha256'] == '1894cef9f71d674507aa671cd5c24730ce221b23df7ca0f9675949336671ba2b', 'Wrong nine-effect manifest')
    require(table['binary_sha256'] == auth['image']['sha256'] and table['generator_sha256'] == pin(OWNERSHIP / 'make-table.py')['sha256'], 'Wrong image/unwind table')
    require(table['header_sha256'] == pin(a.table.with_name('unwind-table.h'))['sha256'], 'Changed unwind header')
    inputs = [verify(v) for v in gate['inputs']] + [verify(v) for v in gate['nineEffects']]
    inputs += [verify(gate[k]) for k in ['method', 'assets', 'derivation', 'source']]
    inputs += [pin(v) for v in [a.gate, a.table, a.table.with_name('unwind-table.h'), a.sampler, a.watchdog,
        __file__, HERE / 'watchdog.c', HERE / 'analyze.py', OWNERSHIP / 'sample-ownership.c',
        OWNERSHIP / 'analyze.py', PERF / 'phase68/parity-survey/sample-analysis-v2.py', GUARD,
        PERF / 'programs/support.py', PERF / 'phase88/native_support.py', sys.executable]]
    cases = {c['name']: c for c in gate['oracleCases']}
    jobs = [('normal-map', cases['map_closed']['source'], 5, 60, cases['map_closed']['oracle']),
            ('stopped-map', cases['map_closed']['source'], 5, 3, None)]
    if a.self_after:
        failed = read(a.self_after)
        rows = [r for r in failed['rows'] if r['name'] == 'self-source']
        require(failed.get('retainedRefusalOrFailure') and not failed.get('complete')
                and failed['nativeB1'] == auth and failed['source'] == gate['source']
                and len(rows) == 1 and rows[0]['passed'] is False, 'No actual failed matching self attempt')
        process_path = Path(rows[0]['guard']) / 'process.json'
        process = read(process_path)
        require(process == rows[0]['process'] and 'finished' in process and process.get('returncode') not in (None, 0)
                and gate['source']['file'] in process['command'] and auth['image']['file'] in process['command'],
                'Prior self run is still active, succeeded or has different bindings')
        inputs += [pin(a.self_after), pin(process_path)]
        jobs.append(('stopped-self', gate['source'], 1, 60, None))
    cached = dict(auth, cache=old['cache'])
    for value in inputs:
        verify(value)
    if a.check_only:
        print(json.dumps(dict(complete=True, targetExecuted=False, inputs=len(inputs), jobs=[j[0] for j in jobs])))
        return
    out = a.out.resolve()
    out.mkdir(parents=True, exist_ok=False)
    report = dict(complete=False, diagnosticUsable=False, kind='phase89-bounded-partial-capture',
                  inputs=inputs, source=gate['source'], image=auth['image'], rows=[], compilationPassed=False)
    def save():
        (out / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
    save()
    try:
        for name, source, calls, seconds, oracle in jobs:
            for value in inputs:
                verify(value)
            prefix, directory, samples = out / name, out / (name + '-guard'), out / (name + '.samples')
            command = ['env', 'LD_PRELOAD=' + str(a.watchdog.resolve()) + ':' + str(a.sampler.resolve()),
                'BEND_SAMPLE_OUT=' + str(samples), 'BEND_SAMPLE_PERIOD_US=4000', 'BEND_CAPTURE_SECONDS=' + str(seconds),
                *native_args(cached, source['file'], prefix, calls)]
            row = dict(name=name, source=source, command=command, expectedReturncode=0 if oracle else 77,
                       compilationPassed=False, diagnosticUsable=False)
            report['rows'].append(row); save()
            job = subprocess.run([sys.executable, '-B', str(GUARD), '--out', str(directory), '--seconds',
                str(seconds + 30), '--cpu', '3', '--', *command], capture_output=True, text=True)
            process = read(directory / 'process.json')
            row.update(process=process, guardReturncode=job.returncode, guardStdout=job.stdout, guardStderr=job.stderr,
                outputs=[pin(Path(str(prefix) + f'.{i}.c')) for i in range(1, calls + 1) if Path(str(prefix) + f'.{i}.c').exists()])
            save()
            require(process['command'][-len(command):] == command and 'stoppedFor' not in process
                    and process.get('returncode') == row['expectedReturncode'], 'Unexpected target exit; retain failed capture')
            analyzer = OWNERSHIP / 'analyze.py' if oracle else HERE / 'analyze.py'
            if oracle:
                require(process.get('complete') and len(row['outputs']) == calls
                    and all(output[k] == oracle[k] for output in row['outputs']
                            for k in ['sha256', 'bytes']), 'Normal Map output mismatch')
                row.update(compilationPassed=True, exactC=True)
            analysis = out / (name + '.analysis.json')
            cmd = [sys.executable, '-B', str(analyzer), '--samples', str(samples), '--binary', auth['image']['file'],
                   '--table', str(a.table), '--stderr', str(directory / 'stderr.log'), '--out', str(analysis)]
            if not oracle:
                cmd += ['--process', str(directory / 'process.json')]
            subprocess.run(cmd, check=True)
            row.update(diagnosticUsable=True, samples=pin(samples), analysis=pin(analysis)); save()
        report.update(complete=True, diagnosticUsable=True)
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
