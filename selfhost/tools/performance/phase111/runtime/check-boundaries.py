#!/usr/bin/env python3
"""Run frozen runtime boundary observations, under the root process-tree guard."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]


def pin(path):
    path = Path(path).resolve()
    return dict(file=str(path), bytes=path.stat().st_size, sha256=hashlib.sha256(path.read_bytes()).hexdigest())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--runtime', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    out = args.out.resolve()
    if out.exists() or not out.is_relative_to(ROOT / 'selfhost/build/phase111'):
        raise ValueError('Fresh Phase111 output required')
    out.mkdir(parents=True)
    frozen = HERE / 'boundary-expected.json'
    expected = json.loads(frozen.read_text())
    for row in [expected['source'], *expected['inputs']]:
        found = pin(ROOT / row['file'])
        if found['sha256'] != row['sha256'] or found['bytes'] != row['bytes']:
            raise ValueError('Frozen boundary input changed: ' + row['file'])
    (out / 'method.py').write_bytes(Path(__file__).read_bytes())
    for file in ['boundary-controls.c', 'boundary-expected.json']:
        shutil.copyfile(HERE / file, out / file)
    report = dict(kind='phase111-runtime-boundaries', complete=False,
                  inputs=[pin(out / 'method.py'), pin(out / 'boundary-controls.c'), pin(frozen),
                          pin(args.runtime), pin(shutil.which('gcc'))], jobs=[], cases=[])
    save = lambda: (out / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
    def run(label, command):
        row = dict(label=label, command=list(map(str, command)))
        report['jobs'].append(row)
        save()
        start = time.monotonic()
        with (out / (label + '.stdout')).open('xb') as so, (out / (label + '.stderr')).open('xb') as se:
            child = subprocess.run(row['command'], cwd=ROOT, stdout=so, stderr=se, timeout=15)
        row.update(seconds=time.monotonic()-start, exitCode=child.returncode,
                   stdout=pin(out / (label + '.stdout')), stderr=pin(out / (label + '.stderr')))
        save()
        return child.returncode, (out / (label + '.stdout')).read_text(), (out / (label + '.stderr')).read_text()
    save()
    status, _, _ = run('build', ['gcc', '-O2', '-std=gnu11', '-I' + str(HERE), out / 'boundary-controls.c',
                                args.runtime.resolve(), '-pthread', '-lm', '-o', out / 'program'])
    if status:
        raise RuntimeError('Boundary harness build failed')
    for case in expected['cases']:
        status, stdout, stderr = run(case['name'], [out / 'program', case['name']])
        match = status == case['exitCode'] and stdout == case['stdout'] and stderr == case['stderr']
        report['cases'].append(dict(name=case['name'], passed=match, actualExitCode=status,
                                    expectedExitCode=case['exitCode'], stdout=stdout, stderr=stderr))
        save()
    report['complete'] = all(row['passed'] for row in report['cases'])
    save()
    print(json.dumps(dict(complete=report['complete'], passed=sum(row['passed'] for row in report['cases']),
                         total=len(report['cases']), out=str(out))))
    raise SystemExit(0 if report['complete'] else 1)


if __name__ == '__main__':
    main()
