#!/usr/bin/env python3
"""Relink an authenticated complete QBE object with a new cached runtime.

Root runs this under the shared process guard. No compiler acquisition or QBE
translation is repeated for a runtime-only experiment.
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
    digest = hashlib.sha256()
    with path.open('rb') as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b''):
            digest.update(chunk)
    return dict(file=str(path), bytes=path.stat().st_size, sha256=digest.hexdigest())


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--build', required=True, type=Path)
    p.add_argument('--runtime', required=True, type=Path)
    p.add_argument('--out', required=True, type=Path)
    a = p.parse_args()
    receipt = a.build / 'report.json' if a.build.is_dir() else a.build
    parent = json.loads(receipt.read_text())
    if not parent.get('complete') or parent.get('kind') != 'phase111-direct-qbe-build':
        raise ValueError('Complete original direct QBE build required')
    for row in [*parent['inputs'], parent['object'], parent['binary']]:
        if pin(row['file']) != row:
            raise ValueError('Changed original build dependency: ' + row['file'])
    out = a.out.resolve()
    if out.exists() or not out.is_relative_to(ROOT / 'selfhost/build/phase111'):
        raise ValueError('Fresh Phase111 output required')
    inputs = [pin(__file__), pin(receipt), parent['object'], pin(a.runtime), pin(shutil.which('gcc'))]
    out.mkdir(parents=True)
    (out / 'method.py').write_bytes(Path(__file__).read_bytes())
    command = [shutil.which('gcc'), '-no-pie', parent['object']['file'], str(a.runtime.resolve()),
               '-pthread', '-lm', '-o', str(out / 'program')]
    report = dict(kind='phase111-direct-qbe-runtime-relink', complete=False, inputs=inputs,
                  object=parent['object'], originalBuild=pin(receipt), command=command,
                  perProgramC=False, cproc=False, cachedRuntime=True,
                  scope='Link only; semantic equivalence and speed require separate gates.')
    def save():
        (out / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
    save()
    try:
        start = time.monotonic()
        with (out / 'link.stdout').open('xb') as so, (out / 'link.stderr').open('xb') as se:
            result = subprocess.run(command, cwd=ROOT, stdout=so, stderr=se, timeout=30)
        report.update(buildSeconds=time.monotonic()-start, exitCode=result.returncode,
                      stdout=pin(out / 'link.stdout'), stderr=pin(out / 'link.stderr'))
        if result.returncode:
            raise RuntimeError('Link failed: ' + str(result.returncode))
        for row in inputs:
            if pin(row['file']) != row:
                raise ValueError('Changed relink input: ' + row['file'])
        report.update(binary=pin(out / 'program'), complete=True)
        save()
        print(json.dumps(dict(complete=True, buildSeconds=report['buildSeconds'], binary=report['binary'])))
    except BaseException as error:
        report['error'] = repr(error)
        save()
        raise


if __name__ == '__main__':
    main()
