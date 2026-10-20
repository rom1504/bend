#!/usr/bin/env python3
"""Root-only guarded build of an authenticated additive profile11301 runtime."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import time

ROOT = Path(__file__).resolve().parents[5]


def pin(path):
    path = Path(path).resolve()
    raw = path.read_bytes()
    return dict(file=str(path), bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--runtime', type=Path, required=True)
    ap.add_argument('--out', type=Path, required=True)
    ap.add_argument('--seconds', type=int, default=90)
    args = ap.parse_args()
    runtime, out = args.runtime.resolve(), args.out.resolve()
    if out.exists() or not out.is_relative_to(ROOT / 'selfhost/build/phase113'):
        raise ValueError('Fresh Phase113 build output required')
    manifest_path = runtime / 'manifest.json'
    manifest = json.loads(manifest_path.read_text())
    if (manifest.get('kind'), manifest.get('profile'), manifest.get('stateAbi'),
        manifest.get('complete'), manifest.get('exactRuntime04Prefix')) != (
            'phase113-array-pair-runtime-source', 11301, 11101, True, True):
        raise ValueError('Unqualified runtime source capsule')
    for row in manifest['inputs'] + manifest['outputs']:
        if pin(row['file']) != row:
            raise ValueError('Runtime capsule input changed: ' + row['file'])
    for name in ['runtime.c', 'runtime.h', 'primitives.h']:
        if pin(runtime / name) not in manifest['outputs']:
            raise ValueError('Runtime output not authenticated: ' + name)
    compiler_name = shutil.which('gcc')
    if compiler_name is None:
        raise ValueError('GCC unavailable')
    compiler = Path(compiler_name).resolve()
    object_path = out / 'runtime.o'
    if object_path.exists():
        raise ValueError('Object already exists')
    inputs = [pin(Path(__file__)), pin(manifest_path), pin(compiler)] + manifest['outputs']
    command = [str(compiler), '-O2', '-std=gnu11', '-ffp-contract=off', '-c',
               str(runtime / 'runtime.c'), '-o', str(object_path)]
    out.mkdir(parents=True)
    record = dict(kind='phase113-array-pair-runtime-build', profile=11301,
                  complete=False, inputs=inputs, command=command,
                  rootGuardRequired=True, stateAbi=11101)
    save = lambda: (out / 'report.json').write_text(json.dumps(record, indent=2)+'\n')
    save()
    started = time.monotonic()
    try:
        with (out / 'build.stdout').open('xb') as stdout, (out / 'build.stderr').open('xb') as stderr:
            child = subprocess.run(command, cwd=ROOT, stdout=stdout, stderr=stderr, timeout=args.seconds)
        record.update(seconds=time.monotonic()-started, exitCode=child.returncode,
                      stdout=pin(out / 'build.stdout'), stderr=pin(out / 'build.stderr'))
        if child.returncode:
            raise RuntimeError('GCC runtime build failed')
        record['object'] = pin(object_path)
        for row in inputs + manifest['inputs']:
            if pin(row['file']) != row:
                raise ValueError('Input changed during build: ' + row['file'])
        record['complete'] = True
        save()
        print(json.dumps(dict(complete=True, object=record['object'], seconds=record['seconds'])))
    except BaseException as error:
        record.update(error=repr(error), seconds=time.monotonic()-started)
        save()
        raise


if __name__ == '__main__':
    main()
