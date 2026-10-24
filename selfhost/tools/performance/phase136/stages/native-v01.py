#!/usr/bin/env python3
"""Freeze/run one exact-output uncached native stage request; outer guard required."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import signal
import subprocess
import sys
import threading
import time

ROOT = Path(__file__).resolve().parents[5]
PHASE = ROOT / 'selfhost/build/phase136'
LABELS = ['base_prepare', 'parse_import', 'check', 'driver_report', 'ownership',
          'compile_eligibility', 'context', 'annotation', 'annotation_check',
          'erasure', 'runtime_admission', 'raw_lowering', 'open_verify',
          'inline_commit', 'ranges_commit', 'final_verify_borrow', 'render']


def pin(path):
    path = Path(path).resolve()
    h = hashlib.sha256()
    with path.open('rb') as f:
        while chunk := f.read(65536):
            h.update(chunk)
    return dict(file=str(path), bytes=path.stat().st_size, sha256=h.hexdigest())


def verify(value):
    assert pin(value['file']) == value, 'Changed input: ' + value['file']
    return Path(value['file'])


def read(path):
    return json.loads(Path(path).read_text())


def save(path, value):
    path.write_text(json.dumps(value, indent=2) + '\n')


def prepare(a):
    acquisition = read(a.image_report)
    manifest = read(a.source_manifest)
    assert acquisition['complete'] and acquisition['source'] == manifest['source']
    image = acquisition['binary']
    oracle_path = ROOT / 'selfhost/build/phase130/p131-final-self01/report.json'
    oracle = read(oracle_path)
    assert oracle['complete'] and oracle['exitCode'] == 0 and oracle['stderr']['bytes'] == 0
    source, expected = oracle['source'], oracle['product']
    inputs = [pin(__file__), pin(sys.executable), pin(a.image_report),
              pin(a.source_manifest), pin(oracle_path), manifest['source'], image,
              acquisition['runtime'], oracle['base'], oracle['carrier']]
    if a.case:
        reference_path = ROOT / 'selfhost/build/phase134/reference03.json'
        reference = read(reference_path)
        assert reference['complete']
        rows = [c for c in reference['cases'] if c['name'] == a.case]
        assert len(rows) == 1
        source, expected = rows[0]['source'], rows[0]['expectedQbe']
        inputs.append(pin(reference_path))
    inputs.extend([source, expected])
    for value in inputs:
        verify(value)
    folder, out = a.plan.resolve().parent, a.out.resolve()
    assert not folder.exists() and folder.is_relative_to(PHASE)
    assert not out.exists() and out.is_relative_to(PHASE) and out != folder
    assert 1 <= a.seconds <= 1200
    folder.mkdir(parents=True)
    plan = dict(kind='phase136-native-stage-request-plan', complete=True,
        inputs=inputs, image=image, compilerSource=manifest['source'],
        source=source, expectedQbe=expected, runtime=acquisition['runtime'],
        base=oracle['base'], carrier=oracle['carrier'], stamp=oracle['stamp'],
        mode=a.mode, case=a.case or 'compiler-A', limitSeconds=a.seconds,
        out=str(out), labels=LABELS, targetsRun=False,
        scope='Same diagnostic executable, ordinary uncached or explicit staged mode. Complete stdout must match an independent frozen QBE oracle. No program-speed or qualified-selection claim. Base carrier is retained, request frontend/backend are not cached.',
        timingScope='Native process wall/CPU/RSS excludes input pinning and post-run hashing. Staged internal monotonic milliseconds exclude input file reads and final diagnostic printing; stage intervals include reference management and output backpressure.')
    save(a.plan, plan)
    print(json.dumps(dict(complete=True, plan=pin(a.plan), targetsRun=False)))


def parse_stages(data):
    lines = data.decode('utf8').splitlines()
    assert len(lines) == len(LABELS), 'Unexpected timing/diagnostic line count'
    result = {}
    for expected, line in zip(LABELS, lines):
        match = re.fullmatch(r'phase136 stage ([a-z_]+) ms=([0-9]{1,10})', line)
        assert match and match[1] == expected, 'Unexpected timing line: ' + line
        result[expected] = int(match[2])
    return result


def run(a):
    plan = read(a.plan)
    assert plan['complete'] and plan['kind'] == 'phase136-native-stage-request-plan'
    assert pin(__file__) in plan['inputs']
    assert not any(k in os.environ for k in ['LD_PRELOAD', 'BEND_SAMPLE_OUT',
        'BEND_SAMPLE_CONTEXT_OUT', 'BEND_PROFILE_COUNTERS', 'BEND_PROFILE_EVENTS_OUT'])
    for value in plan['inputs']:
        verify(value)
    out = Path(plan['out'])
    assert out == out.resolve() and out.is_relative_to(PHASE) and not out.exists()
    out.mkdir(parents=True)
    command = [plan['image']['file'], '--threads', '1', '--gpu', 'off', '--',
        'phase136-stages' if plan['mode'] == 'stages' else 'phase111',
        plan['source']['file'], plan['base']['file'], 'cache',
        plan['carrier']['file'], plan['stamp']]
    if plan['mode'] == 'stages':
        command.append('stderr')
    report = dict(kind='phase136-native-stage-request', complete=False, plan=pin(a.plan),
        inputs=plan['inputs'], command=command, mode=plan['mode'], case=plan['case'],
        image=plan['image'], source=plan['source'], scope=plan['scope'],
        timingScope=plan['timingScope'], inheritedAffinity=sorted(os.sched_getaffinity(0)))
    expired = threading.Event()
    save(out / 'report.json', report)
    try:
        with (out / 'program.ssa').open('xb') as so, (out / 'stderr').open('xb') as se:
            started = time.monotonic()
            child = subprocess.Popen(command, cwd=out, stdout=so, stderr=se, start_new_session=True)
            def stop():
                expired.set()
                try:
                    os.killpg(child.pid, signal.SIGKILL)
                except ProcessLookupError:
                    pass
            timer = threading.Timer(plan['limitSeconds'], stop)
            timer.daemon = True
            timer.start()
            try:
                _, status, usage = os.wait4(child.pid, 0)
                child.returncode = os.waitstatus_to_exitcode(status)
            except BaseException:
                stop()
                child.wait()
                raise
            finally:
                timer.cancel()
                timer.join()
            report.update(nativeSeconds=time.monotonic() - started, exitCode=child.returncode,
                userSeconds=usage.ru_utime, systemSeconds=usage.ru_stime,
                cpuSeconds=usage.ru_utime + usage.ru_stime, peakRssKiB=usage.ru_maxrss,
                timedOut=expired.is_set())
        assert not expired.is_set() and child.returncode == 0, 'Native request failed/timed out'
        product = pin(out / 'program.ssa')
        report['product'] = product
        report['byteExact'] = all(product[k] == plan['expectedQbe'][k] for k in ['bytes', 'sha256'])
        assert report['byteExact'], 'Complete QBE differs from independent oracle'
        diagnostic = (out / 'stderr').read_bytes()
        if plan['mode'] == 'stages':
            report['stageMilliseconds'] = parse_stages(diagnostic)
            report['stageTotalSeconds'] = sum(report['stageMilliseconds'].values()) / 1000
        else:
            assert not diagnostic, 'Unexpected ordinary diagnostics'
        report['complete'] = True
    except BaseException as error:
        report['error'] = repr(error)
    finally:
        for name in ['program.ssa', 'stderr']:
            if (out / name).exists():
                report[name] = pin(out / name)
        report['changedInputs'] = []
        for value in plan['inputs']:
            try:
                verify(value)
            except (AssertionError, OSError):
                report['changedInputs'].append(value['file'])
        if report['changedInputs']:
            report['complete'] = False
        save(out / 'report.json', report)
    print(json.dumps({k: report.get(k) for k in ['complete', 'mode', 'case', 'nativeSeconds',
        'stageMilliseconds', 'stageTotalSeconds', 'peakRssKiB', 'byteExact', 'error']}))
    return 0 if report['complete'] else 1


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    action = parser.add_mutually_exclusive_group(required=True)
    action.add_argument('--prepare', action='store_true')
    action.add_argument('--run', action='store_true')
    parser.add_argument('--plan', type=Path, required=True)
    parser.add_argument('--out', type=Path)
    parser.add_argument('--image-report', type=Path)
    parser.add_argument('--source-manifest', type=Path, default=PHASE / 'stages-source01/manifest.json')
    parser.add_argument('--mode', choices=['ordinary', 'stages'], default='stages')
    parser.add_argument('--case', choices=['lexer', 'coverage-closures-256', 'coverage-map-churn-128'])
    parser.add_argument('--seconds', type=int, default=600)
    args = parser.parse_args()
    if args.prepare:
        assert args.out and args.image_report
        prepare(args)
    else:
        sys.exit(run(args))
