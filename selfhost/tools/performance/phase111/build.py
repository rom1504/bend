#!/usr/bin/env python3
"""Build direct QBE plus a cached runtime object; no per-program C/cproc step.

Run under the root process-tree guard. Runtime acquisition is a separate job.
"""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import time

ROOT = Path(__file__).resolve().parents[4]


def pin(path):
    path = Path(path).resolve()
    return dict(file=str(path), bytes=path.stat().st_size, sha256=hashlib.sha256(path.read_bytes()).hexdigest())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source', type=Path, required=True)
    parser.add_argument('--runtime', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--expected', type=Path)
    parser.add_argument('--seconds', type=int, default=60)
    args = parser.parse_args()
    out = args.out.resolve()
    if out.exists() or not out.is_relative_to(ROOT / 'selfhost/build/phase111'):
        raise ValueError('Fresh Phase111 output required')
    out.mkdir(parents=True)
    (out / 'method.py').write_bytes(Path(__file__).read_bytes())
    qbe = ROOT / 'selfhost/build/phase108/toolchain/qbe-1.3/qbe'
    assembler, linker = Path(shutil.which('as')), Path(shutil.which('gcc'))
    inputs = [pin(out / 'method.py'), pin(args.source), pin(args.runtime), pin(qbe), pin(assembler), pin(linker)]
    if args.expected:
        inputs.append(pin(args.expected))
    report = dict(kind='phase111-direct-qbe-build', complete=False, inputs=inputs, jobs=[],
                  perProgramC=False, cproc=False, cachedRuntime=True,
                  scope='QBE emission is an input; this gate builds and optionally executes its exact bytes.')
    save = lambda: (out / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
    def run(label, command):
        row = dict(label=label, command=list(map(str, command)))
        report['jobs'].append(row)
        save()
        start = time.monotonic()
        with (out / (label + '.stdout')).open('xb') as so, (out / (label + '.stderr')).open('xb') as se:
            child = subprocess.run(row['command'], cwd=ROOT, stdout=so, stderr=se, timeout=args.seconds)
        row.update(seconds=time.monotonic()-start, exitCode=child.returncode,
                   stdout=pin(out / (label + '.stdout')), stderr=pin(out / (label + '.stderr')))
        save()
        if child.returncode:
            raise RuntimeError(label + ' failed: ' + str(child.returncode))
    save()
    try:
        run('qbe', [qbe, '-t', 'amd64_sysv', '-o', out / 'program.s', args.source.resolve()])
        run('assemble', [assembler, '-o', out / 'program.o', out / 'program.s'])
        run('link', [linker, '-no-pie', out / 'program.o', args.runtime.resolve(), '-pthread', '-lm', '-o', out / 'program'])
        report['binary'], report['object'] = pin(out / 'program'), pin(out / 'program.o')
        report['buildSeconds'] = sum(row['seconds'] for row in report['jobs'])
        if args.expected:
            run('execute', [out / 'program', '--threads', '1', '--gpu', 'off'])
            if (out / 'execute.stdout').read_bytes() != args.expected.read_bytes():
                raise RuntimeError('Output differs from frozen expected bytes')
            if (out / 'execute.stderr').read_bytes():
                raise RuntimeError('Unexpected execution stderr')
            report['outputExact'] = True
        for row in inputs:
            if pin(row['file']) != row:
                raise RuntimeError('Input changed: ' + row['file'])
        report['complete'] = True
        save()
        print(json.dumps(dict(complete=True, buildSeconds=report['buildSeconds'], binary=report['binary'])))
    except BaseException as error:
        report['error'] = repr(error)
        save()
        raise


if __name__ == '__main__':
    main()
