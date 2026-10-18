#!/usr/bin/env python3
"""Build and replay frozen bank controls; root runs this under its outer guard."""
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
    data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--runtime', required=True, type=Path)
    p.add_argument('--out', required=True, type=Path)
    args = p.parse_args()
    out = args.out.resolve()
    if out.exists() or not out.is_relative_to(ROOT / 'selfhost/build/phase111'):
        raise ValueError('Fresh Phase111 output required')
    frozen = HERE / 'bank-expected.json'
    expected = json.loads(frozen.read_text())
    for record in [expected['source'], *expected['inputs']]:
        actual = pin(ROOT / record['file'])
        if actual['sha256'] != record['sha256'] or actual['bytes'] != record['bytes']:
            raise ValueError('Frozen bank input changed: ' + record['file'])
    out.mkdir(parents=True)
    for name in ['bank-controls.c', 'bank-expected.json', 'check-banks.py']:
        shutil.copyfile(HERE / name, out / name)
    report = dict(kind='phase111-bank-boundary-observations', complete=False,
                  inputs=[pin(out / 'check-banks.py'), pin(out / 'bank-controls.c'),
                    pin(frozen), pin(HERE / 'runtime.h'), pin(args.runtime), pin(shutil.which('gcc'))],
                  jobs=[], cases=[])
    def save():
        (out / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
    def run(label, command):
        item = dict(label=label, command=list(map(str, command)))
        report['jobs'].append(item)
        save()
        begin = time.monotonic()
        with (out / (label + '.stdout')).open('xb') as so, (out / (label + '.stderr')).open('xb') as se:
            child = subprocess.run(item['command'], cwd=ROOT, stdout=so, stderr=se, timeout=20)
        item.update(seconds=time.monotonic() - begin, exitCode=child.returncode,
                    stdout=pin(out / (label + '.stdout')), stderr=pin(out / (label + '.stderr')))
        save()
        return child.returncode, (out / (label + '.stdout')).read_text(), (out / (label + '.stderr')).read_text()
    save()
    status, _, _ = run('build', ['gcc', '-O2', '-std=gnu11', '-I' + str(HERE),
        out / 'bank-controls.c', args.runtime.resolve(), '-pthread', '-lm', '-o', out / 'program'])
    if status:
        raise RuntimeError('Bank harness compilation failed')
    report['binary'] = pin(out / 'program')
    for case in expected['cases']:
        status, stdout, stderr = run(case['name'], [out / 'program', case['name']])
        passed = status == case['exitCode'] and stdout == case['stdout'] and stderr == case['stderr']
        report['cases'].append(dict(name=case['name'], passed=passed, actualExitCode=status,
                                   stdout=stdout, stderr=stderr))
        save()
    for record in report['inputs']:
        if pin(record['file']) != record:
            raise RuntimeError('Input changed during bank controls')
    report['complete'] = all(case['passed'] for case in report['cases'])
    save()
    print(json.dumps(dict(complete=report['complete'], passed=sum(c['passed'] for c in report['cases']),
                         total=len(report['cases']), out=str(out))))
    raise SystemExit(0 if report['complete'] else 1)


if __name__ == '__main__':
    main()
