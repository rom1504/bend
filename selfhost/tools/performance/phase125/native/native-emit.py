#!/usr/bin/env python3
"""Capture a native Phase111 compiler request under the root process-tree guard.

No compiler transformation is implemented here. Native stdout is saved unchanged.
"""
import argparse
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import signal
import subprocess
import sys
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
PHASE = ROOT / "selfhost/tools/performance/phase111"
BUILDER = ROOT / "selfhost/tools/performance/phase123/build-aligned.py"
REFERENCE_KINDS = {
    'phase111-checked-source-qbe-emission',
    'phase111-staged-checked-source-qbe-emission',
    'phase111-native-source-qbe-emission',
    'phase125-aligned-native-source-qbe-emission',
}


def utc():
    return datetime.now(timezone.utc).isoformat()


def pin(path):
    path = Path(path).resolve()
    digest, size = hashlib.sha256(), 0
    with path.open('rb') as stream:
        for data in iter(lambda: stream.read(1024 * 1024), b''):
            digest.update(data)
            size += len(data)
    return dict(file=str(path), bytes=size, sha256=digest.hexdigest())


def verify(row):
    actual = pin(row['file'])
    if any(actual[key] != row[key] for key in ('bytes', 'sha256')):
        raise ValueError('Changed input: ' + row['file'])
    return Path(actual['file'])


def same_bytes(left, right):
    with Path(left).open('rb') as a, Path(right).open('rb') as b:
        while True:
            x, y = a.read(1024 * 1024), b.read(1024 * 1024)
            if x != y:
                return False
            if not x:
                return True


def member(path, name):
    path = path.resolve()
    return path / name if path.is_dir() else path


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--image', type=Path, required=True)
    parser.add_argument('--source', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--mode', choices=['cache', 'live'], default='cache')
    parser.add_argument('--reference', type=Path, help='Complete emission directory or report.json')
    parser.add_argument('--runtime', type=Path, help='Cached object, or directory containing runtime.o')
    parser.add_argument('--expected', type=Path, help='Exact generated-program stdout; requires --runtime')
    parser.add_argument('--seconds', type=float, default=300, help='Native request wall limit')
    parser.add_argument('--build-seconds', type=int, default=180, help='Existing builder per-command limit')
    args = parser.parse_args()
    if args.seconds <= 0 or args.build_seconds <= 0:
        raise ValueError('Positive time limits required')
    if args.expected and not args.runtime:
        raise ValueError('--expected requires --runtime')
    out = args.out.resolve()
    if out.exists() or not out.is_relative_to(ROOT / 'selfhost/build/phase111'):
        raise ValueError('Fresh Phase111 output required')
    image = member(args.image, 'program')
    source = args.source.resolve()
    if not os.access(image, os.X_OK):
        raise ValueError('Executable native image required')

    assets_file = PHASE / 'native-assets01.json'
    assets = json.loads(assets_file.read_text())
    if assets.get('kind') != 'phase111-native-request-assets' or not assets.get('complete'):
        raise ValueError('Complete frozen native assets required')
    selection_file = verify(assets['selection'])
    selection = json.loads(selection_file.read_text())
    if selection['admission'] != assets['admission']:
        raise ValueError('Frozen admission differs from selection')
    admission = json.loads(verify(assets['admission']).read_text())
    if not (admission.get('complete') and admission.get('qualified')):
        raise ValueError('Selected seed admission incomplete')
    if admission['assets']['base'] != assets['base'] or admission['assets']['cache'] != assets['cache']:
        raise ValueError('Frozen Base/cache differs from admitted assets')
    base = verify(assets['base'])
    carrier = Path(assets['cache']['carrier']['file'])
    shared = [pin(source), assets['selection'], assets['admission'], assets['base']]
    if args.mode == 'cache':
        verify(assets['cache']['carrier'])
        shared.append(assets['cache']['carrier'])
    image_pin = pin(image)
    inputs = [pin(__file__), pin(PHASE / 'native-emit.py'), pin(HERE / 'derivation01.json'), pin(assets_file), pin(sys.executable), image_pin, *shared]
    runtime = member(args.runtime, 'runtime.o') if args.runtime else None
    expected = args.expected.resolve() if args.expected else None
    if runtime:
        inputs.extend([pin(BUILDER), pin(runtime)])
    if expected:
        inputs.append(pin(expected))

    reference = None
    if args.reference:
        reference_file = member(args.reference, 'report.json')
        reference = json.loads(reference_file.read_text())
        if (reference.get('kind') not in REFERENCE_KINDS or not reference.get('complete') or
                reference.get('mode') != args.mode):
            raise ValueError('Complete same-mode emission reference required')
        reference_inputs = {str(Path(row['file']).resolve()): row for row in reference['inputs']}
        for row in shared:
            other = reference_inputs.get(row['file'])
            if not other or any(other[key] != row[key] for key in ('bytes', 'sha256')):
                raise ValueError('Reference does not bind identical request input: ' + row['file'])
        verify(reference['product'])
        inputs.extend([pin(reference_file), reference['product']])

    # This binds an existing build receipt when available; it does not manufacture
    # source acquisition provenance for an arbitrary executable supplied by caller.
    image_receipt = None
    image_report = image.parent / 'report.json'
    if image_report.is_file():
        candidate = json.loads(image_report.read_text())
        binary = candidate.get('binary')
        if candidate.get('complete') and isinstance(binary, dict) and Path(binary['file']).resolve() == image:
            if any(image_pin[key] != binary[key] for key in ('bytes', 'sha256')):
                raise ValueError('Image differs from adjacent complete build receipt')
            image_receipt = pin(image_report)
            inputs.append(image_receipt)

    command = [str(image), '--threads', '1', '--gpu', 'off', '--', 'phase111',
               str(source), str(base), args.mode, str(carrier), assets['cache']['stamp']]
    out.mkdir(parents=True)
    (out / 'native-emit-method.py').write_bytes(Path(__file__).read_bytes())
    (out / 'native-assets.json').write_bytes(assets_file.read_bytes())
    report = dict(kind='phase125-aligned-native-source-qbe-emission', version=1, complete=False,
                  assemblerOption='-mbranches-within-32B-boundaries',
                  mode=args.mode, startedUtc=utc(), inputs=inputs, image=image_pin,
                  imageReceipt=image_receipt, jobs=[], gates=dict(emission='pending',
                  comparison='pending' if reference else 'not-requested',
                  build='pending' if runtime else 'not-requested',
                  semantics='pending' if expected else 'not-requested'),
                  inheritedAffinity=sorted(os.sched_getaffinity(0)) if hasattr(os, 'sched_getaffinity') else None,
                  timingScope='nativeSeconds is whole child request wall time, including reads, compilation and stdout writes; no internal-stage attribution. totalSeconds starts after preflight. Root guard owns process-tree RSS/CPU limits.',
                  byteContract='Each native IO.print(chunk) appends LF. program.ssa is raw stdout; no added final newline, filtering or whitespace normalization.',
                  scope='A native request receipt. Successful emission alone is not assembly, semantic qualification, provenance of the compiler image, or a completed self-host chain.')
    total_start = time.monotonic()
    report_file = out / 'report.json'

    def save():
        report['totalSeconds'] = time.monotonic() - total_start
        temporary = out / 'report.json.tmp'
        temporary.write_text(json.dumps(report, indent=2) + '\n')
        temporary.replace(report_file)

    def run(label, argv, stdout, stderr, limit):
        row = dict(label=label, command=list(map(str, argv)), status='running', startedUtc=utc(), limitSeconds=limit)
        report['jobs'].append(row)
        save()
        print(json.dumps(dict(stage=label, status='running')), flush=True)
        start, child = time.monotonic(), None
        try:
            with stdout.open('xb') as so, stderr.open('xb') as se:
                child = subprocess.Popen(row['command'], cwd=ROOT, stdout=so, stderr=se, start_new_session=True)
                try:
                    child.wait(timeout=limit)
                except BaseException:
                    if child.poll() is None:
                        os.killpg(child.pid, signal.SIGKILL)
                    child.wait()
                    raise
            row['exitCode'] = child.returncode
            if child.returncode:
                raise RuntimeError(label + ' exited ' + str(child.returncode))
            row['status'] = 'complete'
        except BaseException as error:
            row['status'] = 'failed'
            row['error'] = repr(error)
            row['timedOut'] = isinstance(error, subprocess.TimeoutExpired)
            if child is not None:
                row['exitCode'] = child.returncode
            raise
        finally:
            row['seconds'] = time.monotonic() - start
            if label == 'native-request':
                report['nativeSeconds'] = row['seconds']
            for name, path in [('stdout', stdout), ('stderr', stderr)]:
                if path.is_file():
                    row[name] = pin(path)
            save()
            print(json.dumps(dict(stage=label, status=row['status'], seconds=row['seconds'])), flush=True)
        return row

    stage = 'emission'
    save()
    try:
        report['gates'][stage] = 'running'
        job = run('native-request', command, out / 'program.ssa', out / 'emit.stderr', args.seconds)
        report['nativeSeconds'] = job['seconds']
        report['product'] = job['stdout']
        report['stderr'] = job['stderr']
        if not report['product']['bytes'] or report['stderr']['bytes']:
            raise RuntimeError('Native request requires nonempty stdout and empty stderr')
        report['gates'][stage] = 'passed'
        if reference:
            stage = 'comparison'
            report['gates'][stage] = 'running'
            save()
            start = time.monotonic()
            exact = same_bytes(out / 'program.ssa', reference['product']['file'])
            report['comparison'] = dict(reference=pin(reference_file), product=reference['product'],
                                        byteExact=exact, seconds=time.monotonic() - start)
            if not exact:
                raise RuntimeError('Native stdout differs from exact reference QBE bytes')
            report['gates'][stage] = 'passed'
        if runtime:
            stage = 'build'
            report['gates'][stage] = 'running'
            argv = [sys.executable, BUILDER, '--source', out / 'program.ssa',
                    '--runtime', runtime, '--out', out / 'build', '--seconds', args.build_seconds]
            if expected:
                argv.extend(['--expected', expected])
            try:
                run('build', argv, out / 'build.stdout', out / 'build.stderr',
                    (4 if expected else 3) * args.build_seconds + 30)
            finally:
                build_report_file = out / 'build/report.json'
                if build_report_file.is_file():
                    report['buildReport'] = pin(build_report_file)
                    build_report = json.loads(build_report_file.read_text())
                    execution = [row for row in build_report.get('jobs', []) if row['label'] == 'execute']
                    if execution:
                        report['gates']['build'] = 'passed'
                        stage = 'semantics'
                        report['gates'][stage] = 'running'
            build_report = json.loads((out / 'build/report.json').read_text())
            if not build_report.get('complete') or (expected and not build_report.get('outputExact')):
                raise RuntimeError('Existing builder did not complete requested gates')
            report['gates']['build'] = 'passed'
            if expected:
                report['gates']['semantics'] = 'passed'
        stage = 'input-authentication'
        for row in inputs:
            verify(row)
        report['complete'] = True
        report['finishedUtc'] = utc()
        save()
        print(json.dumps(dict(complete=True, gates=report['gates'], product=report['product'],
                              nativeSeconds=report['nativeSeconds'])), flush=True)
        return 0
    except BaseException as error:
        report['failedStage'] = stage
        if stage in report['gates']:
            report['gates'][stage] = 'failed'
        report['error'] = repr(error)
        for name, path in [('product', out / 'program.ssa'), ('stderr', out / 'emit.stderr')]:
            if path.is_file():
                report[name] = pin(path)
        report['finishedUtc'] = utc()
        save()
        print(json.dumps(dict(complete=False, failedStage=stage, error=repr(error))), file=sys.stderr, flush=True)
        return 1


if __name__ == '__main__':
    sys.exit(main())
