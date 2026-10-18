#!/usr/bin/env python3
"""Authenticate and launch the experimental native Bend frontend; no code generation."""
import argparse
import hashlib
import json
import shutil
import subprocess
import time
from pathlib import Path
from process import run as run_process


def pin(file):
    p = Path(file).resolve(strict=True)
    raw = p.read_bytes()
    return dict(file=str(p), bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def verify(record):
    actual = pin(record['file'])
    if actual != record:
        raise ValueError('changed pinned input: ' + record['file'])
    return actual


def authenticate(image_file, base_mode):
    image_pin = pin(image_file)
    image = json.loads(Path(image_file).read_text())
    if (image.get('kind') != 'phase107-native-frontend-image' or
            image.get('version') != 1 or image.get('complete') is not True):
        raise ValueError('incomplete or unsupported native image receipt')
    manifest_pin = verify(image['manifest'])
    manifest = json.loads(Path(manifest_pin['file']).read_text())
    if manifest.get('kind') != 'phase107-native-frontend-source' or manifest.get('version') != 1:
        raise ValueError('unsupported source manifest')
    if manifest['source'] != image['source']:
        raise ValueError('image and manifest refer to different compiler sources')
    source = verify(image['source'])
    binary = verify(image['binary'])
    acquisition = verify(image['acquisition']) if image.get('acquisition') else None
    base = verify(manifest['assets']['base'])
    cache = verify(manifest['assets']['cache']['carrier']) if base_mode == 'cache' else None
    return dict(image=image_pin, acquisition=acquisition, manifest=manifest_pin,
                compilerSource=source, binary=binary, base=base, cache=cache)


def main():
    begin = time.monotonic()
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('input', type=Path)
    p.add_argument('--image', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--entry', default='main')
    p.add_argument('--format', choices=['json', 'qbe', 'units'], default='units')
    p.add_argument('--policy', choices=['raw', 'fast'], default='fast')
    p.add_argument('--base', choices=['cache', 'live'], default='cache')
    p.add_argument('--timeout', type=float, default=30)
    p.add_argument('--verify-only', action='store_true')
    a = p.parse_args()
    if not a.entry or not 0 < a.timeout <= 600:
        raise ValueError('invalid entry or timeout')
    identity = authenticate(a.image, a.base)
    binary, base, cache = (identity[k] for k in ['binary', 'base', 'cache'])
    request = pin(a.input)
    if request['bytes'] > 16777216:
        raise ValueError('input exceeds native reader limit')
    report = dict(kind='phase107-native-frontend-request', version=1,
                  complete=False, executed=False, method=pin(__file__),
                  processMethod=pin(Path(__file__).with_name('process.py')),
                  waitPolicy='pidfd readiness with deadline-preserving polling fallback',
                  **identity, input=request,
                  options=dict(entry=a.entry, format=a.format, policy=a.policy, base=a.base),
                  authenticationSeconds=time.monotonic()-begin)
    out = a.out.resolve()
    out.mkdir(parents=True, exist_ok=False)
    shutil.copyfile(report['processMethod']['file'],out/'process.py')
    report['processSnapshot']=pin(out/'process.py')
    save = lambda: (out/'report.json').write_text(json.dumps(report, indent=2)+'\n')
    save()
    if a.verify_only:
        report['authenticationOnly'] = True
        save()
        print(json.dumps(dict(authenticated=True, executed=False, report=str(out/'report.json'))))
        return
    output = out/('program.ssa' if a.format == 'qbe' else 'program.json')
    command = [binary['file'], request['file'], a.entry, a.format, a.policy, a.base]
    report['command'] = command
    before = time.monotonic()
    with output.open('xb') as stdout, (out/'stderr.txt').open('xb') as stderr:
        try:
            completed = run_process(command, stdout=stdout, stderr=stderr,
                                       timeout=a.timeout, check=False)
            report.update(status=completed.returncode,pid=completed.pid,waitMethod=completed.wait_method,waitFallback=completed.wait_fallback)
        except subprocess.TimeoutExpired as expired:
            report.update(failure='native frontend timeout',status=None,pid=expired.pid,waitMethod=expired.wait_method,killedChildReturncode=expired.returncode)
    report['nativeSeconds'] = time.monotonic()-before
    report['executed'] = True
    report['output'] = pin(output)
    report['totalSeconds'] = time.monotonic()-begin
    save()
    if report['status'] != 0:
        raise SystemExit('native frontend refused or failed; see ' + str(out/'report.json'))
    verify(request)
    verify(report['processMethod'])
    verify(base)
    if cache:
        verify(cache)
    report['complete'] = True
    save()
    print(json.dumps(dict(complete=True, nativeSeconds=report['nativeSeconds'],
                         output=str(output), report=str(out/'report.json'))))


if __name__ == '__main__':
    main()
