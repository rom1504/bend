#!/usr/bin/env python3
"""Execute frozen matched profiles serially; caller supplies process-tree guard.
Tiny fixture process times are diagnostic only, not generated-program benchmarks.
"""
import argparse
import hashlib
import importlib.util
import json
import shutil
import sys
import time
from pathlib import Path
sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
SPEC = importlib.util.spec_from_file_location('p109_process', ROOT / 'selfhost/tools/performance/phase107/frontend/native/process.py')
PROCESS = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(PROCESS)


def pin(path):
    path = Path(path).resolve()
    return {'file': str(path), 'sha256': hashlib.sha256(path.read_bytes()).hexdigest(), 'bytes': path.stat().st_size}


def verify(row):
    path = Path(row['file'])
    if not path.is_absolute():
        path = ROOT / path
    actual = pin(path)
    if actual['sha256'] != row['sha256'] or actual['bytes'] != row['bytes']:
        raise ValueError('changed pinned input: ' + str(path))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--rounds', type=int, default=1, choices=range(1, 6))
    parser.add_argument('--only', nargs='+', choices=['nt-reverse', 'string-reverse-heldout', 'non-tail-list'])
    parser.add_argument('--profiles', nargs='+', choices=['original-clang', 'portable-clang', 'portable-clang-shim', 'portable-qbe'])
    parser.add_argument('--seconds', type=float, default=60)
    args = parser.parse_args()
    out = args.out.resolve()
    if not out.is_relative_to(ROOT / 'selfhost/build/phase109') or out.exists():
        raise ValueError('fresh output under selfhost/build/phase109 required')
    if shutil.disk_usage(ROOT).free < 64 * 1024**2:
        raise ValueError('need at least 64MiB disk headroom')
    plan_path = HERE / 'baseline-plan.json'
    plan = json.loads(plan_path.read_text())
    out.mkdir(parents=True)
    report = {'kind': 'phase109-matched-baselines', 'version': 1, 'complete': False,
              'plan': pin(plan_path), 'method': pin(__file__), 'rounds': args.rounds,
              'executionTimingScope': 'tiny whole processes; startup-dominated diagnostic, not a speed benchmark',
              'profileComparisons': plan['comparisons'],
              'inputs': plan['inputs'] + [pin(shutil.which(tool)) for tool in ('gcc', 'cpp', 'as', 'ld', 'size')]
                        + [pin(ROOT / 'selfhost/build/phase108/toolchain/cproc-src/config.h')], 'rows': []}
    def save():
        (out / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
    def command(row, label, argv, folder):
        for item in report['inputs'] + [row['generatedSource'], row['emissionReceipt']]:
            verify(item)
        stdout_path, stderr_path = folder / (label + '.stdout'), folder / (label + '.stderr')
        job = {'label': label, 'command': argv}
        row['jobs'].append(job)
        save()
        begin = time.monotonic()
        with stdout_path.open('xb') as stdout, stderr_path.open('xb') as stderr:
            result = PROCESS.run(argv, stdout=stdout, stderr=stderr, timeout=args.seconds, cwd=ROOT)
        job.update(status=result.returncode, seconds=time.monotonic() - begin,
                   waitMethod=result.wait_method, stdout=pin(stdout_path), stderr=pin(stderr_path))
        save()
        if result.returncode:
            raise RuntimeError(label + ' failed; see ' + str(stderr_path))
        return job
    start = time.monotonic()
    save()
    try:
        for item in report['inputs']:
            verify(item)
        cases = args.only or ['nt-reverse', 'string-reverse-heldout', 'non-tail-list']
        for case in cases:
            selected = [x for x in plan['rows'] if x['case'] == case and (not args.profiles or x['profile'] in args.profiles)]
            for round_index in range(args.rounds):
                order = selected if round_index % 2 == 0 else list(reversed(selected))
                for entry in order:
                    folder = out / case / str(round_index) / entry['profile']
                    folder.mkdir(parents=True)
                    rewrite = lambda arg: str(folder / Path(arg).relative_to(entry['out'])) if arg.startswith(entry['out'] + '/') else arg
                    commands = [[rewrite(arg) for arg in command] for command in entry['commands']]
                    row = {'case': case, 'round': round_index, 'profile': entry['profile'], 'complete': False,
                           'generatedSource': entry['generatedSource'], 'emissionReceipt': entry['emissionReceipt'],
                           'sourceUnchanged': True, 'jobs': []}
                    report['rows'].append(row)
                    save()
                    builds = [command(row, 'build-' + str(i), argv, folder) for i, argv in enumerate(commands)]
                    binary = folder / 'program'
                    row.update(binary=pin(binary), buildSeconds=sum(x['seconds'] for x in builds))
                    size = command(row, 'sections', ['size', '-A', str(binary)], folder)
                    text_rows = [line.split() for line in (folder / 'sections.stdout').read_text().splitlines() if line.split() and line.split()[0] == '.text']
                    if len(text_rows) != 1:
                        raise ValueError('expected one .text section')
                    row['textBytes'] = int(text_rows[0][1])
                    run = command(row, 'execute', [rewrite(arg) for arg in entry['run']], folder)
                    actual = (folder / 'execute.stdout').read_bytes()
                    if actual != entry['expectedStdout'].encode() or (folder / 'execute.stderr').read_bytes():
                        raise ValueError('output differs from frozen oracle: ' + case)
                    row.update(exactStdout=True, exactStderr=True, processSecondsDiagnostic=run['seconds'], complete=True)
                    verify(entry['generatedSource'])
                    save()
        report.update(complete=True, seconds=time.monotonic() - start)
        save()
        print(json.dumps({'complete': True, 'rows': len(report['rows']), 'receipt': str(out / 'report.json')}))
    except BaseException as error:
        report.update(error=repr(error), seconds=time.monotonic() - start)
        save()
        raise


if __name__ == '__main__':
    main()
