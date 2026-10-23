#!/usr/bin/env python3
"""Check diagnostic hooks with a frozen independent ABI program, under a root guard."""
import argparse
import json
import os
from pathlib import Path
import signal
import subprocess
import sys
import time

sys.dont_write_bytecode = True
from run import pin, verify, save

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
CONTROL = HERE / 'controls/runtime-control.c'
EXPECTED = HERE / 'controls/runtime-control.expected.json'
SOURCE_SHA = '41bfdd1aaf6943a0f61a6ada8365e8cd27ca21c9a85e316fbbe988339c369721'
PROFILE_ENV = ('LD_PRELOAD', 'BEND_SAMPLE_OUT', 'BEND_SAMPLE_PERIOD_US',
    'BEND_SAMPLE_CONTEXT_OUT', 'BEND_SAMPLE_CALLERS_OUT', 'BEND_PROFILE_EVENTS_OUT', 'BEND_PROFILE_COUNTERS')


def require(ok, message):
    if not ok:
        raise ValueError(message)


def read(path):
    return json.loads(Path(path).read_text())


def validate_events(document, expected, enabled):
    require(document['schema'] == 'bend-native-dispatch-events-v1', 'Unexpected event schema')
    require(document['complete'] and not document['counter_overflow'] and document['invalid_context_events'] == 0,
            'Incomplete, overflowed or invalid-context counters')
    require(document['segment_count'] == expected['segmentCount'] and
            document['runtime_segment_count'] == expected['runtimeSegmentCount'] and
            document['unknown_fid'] == expected['unknownFid'], 'Control descriptor/FID mismatch')
    require(document['context_kind'] == 'active-dispatch-not-logical-ancestry' and
            document['global_context_scope'] == 'one-active-dispatch-thread-only', 'Wrong context scope')
    require(document['counter_names'] == expected['counterNames'], 'Counter inventory/order changed')
    require(document['counts_enabled'] is enabled, 'Counter mode differs from explicit request')
    if not enabled:
        require(document['counter_bytes'] == 0 and document['rows'] == [], 'Disabled counters allocated or collected events')
        return dict(complete=True, countsEnabled=False, rows=0)
    require(document['counter_bytes'] == (expected['segmentCount'] + 5) * len(expected['counterNames']) * 8,
            'Counter storage dimensions differ')
    observed = {}
    for row in document['rows']:
        fid = str(row['fid'])
        require(fid not in observed, 'Duplicate FID row')
        require(len(row['counts']) == len(expected['counterNames']) and
                all(isinstance(n, int) and not isinstance(n, bool) and n >= 0 for n in row['counts']),
                'Invalid counter vector')
        observed[fid] = dict(zip(expected['counterNames'], row['counts']))
        address = int(row['segment_address'], 16)
        require((address != 0) == (row['fid'] < expected['segmentCount']), 'Wrong program/runtime segment address class')
    require(set(observed) == set(expected['rows']), 'Unexpected/missing active or outside-dispatch FIDs')
    differences = {fid: {name: dict(expected=value, actual=observed[fid][name])
        for name, value in counts.items() if observed[fid][name] != value}
        for fid, counts in expected['rows'].items()}
    differences = {fid: values for fid, values in differences.items() if values}
    require(not differences, 'Source-derived per-FID counter mismatch: ' + json.dumps(differences, sort_keys=True))
    totals = {name: sum(row[name] for row in observed.values()) for name in expected['counterNames']}
    require(totals == expected['totals'], 'Source-derived total counter mismatch')
    return dict(complete=True, countsEnabled=True, rows=len(observed), totals=totals,
                exactPerFid=True, limitations=expected['limitations'])


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--runtime-plan', type=Path, required=True)
    parser.add_argument('--build-report', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--control', type=Path, default=CONTROL)
    parser.add_argument('--expected', type=Path, default=EXPECTED)
    args = parser.parse_args()
    require(not any(key in os.environ for key in PROFILE_ENV), 'Ambient profiling environment must be unset')
    control, expected_path = args.control.resolve(), args.expected.resolve()
    plan, built, expected = read(args.runtime_plan), read(args.build_report), read(expected_path)
    require(plan['schema'] == 'bend-native-profile-runtime-plan-v1' and plan['complete'] and plan['reverseExact'], 'Complete reversible runtime plan required')
    require(built['complete'] and built['plan'] == pin(args.runtime_plan), 'Build receipt belongs to another/incomplete plan')
    require(expected['schema'] == 'bend-native-profile-control-expectations-v1' and expected['frozenBeforeExecution'], 'Frozen independent expectations required')
    require(pin(control)['sha256'] == expected['source']['sha256'], 'Frozen independent control source changed')
    if control == CONTROL:
        require(pin(control)['sha256'] == SOURCE_SHA, 'Original control changed')
    original = ROOT / expected['source']['file']
    require(original.read_bytes() == control.read_bytes(), 'Copied control differs from original independent fixture')
    require(expected['output'] == dict(status=0, stdout='45\n', stderr=''), 'Independent arithmetic/output oracle changed')
    compile_jobs = [job for job in plan['jobs'] if job['label'] == 'compile-runtime']
    require(len(compile_jobs) == 1, 'Unique runtime compilation job required')
    runtime_job = compile_jobs[0]
    runtime_object = Path(runtime_job['command'][runtime_job['command'].index('-o') + 1]).resolve()
    runtime_pin = pin(runtime_object)
    require(runtime_pin in built['products'], 'Retained diagnostic object differs from build receipt')
    compiler = Path(runtime_job['command'][0]).resolve()
    inputs = [pin(__file__), pin(HERE / 'run.py'), pin(control), pin(expected_path), pin(original),
              pin(ROOT / 'selfhost/tools/performance/phase112/profile/control-freeze.json'),
              pin(args.runtime_plan), pin(args.build_report), runtime_pin, pin(compiler),
              *plan['inputs'], *plan['outputs']]
    for item in inputs:
        verify(item)
    out = args.out.resolve()
    require(not out.exists(), 'Control output directory must be fresh')
    out.mkdir(parents=True)
    for source, name in [(control, 'control.c'), (expected_path, 'expected.json'), (Path(__file__), 'method.py')]:
        (out / name).write_bytes(source.read_bytes())
    report = dict(schema='bend-native-profile-runtime-control-v1', complete=False,
        started=time.time(), inputs=inputs, expected=pin(out / 'expected.json'),
        source=pin(out / 'control.c'), methodSnapshot=pin(out / 'method.py'), jobs=[], checks=[],
        cpuAffinity=sorted(os.sched_getaffinity(0)),
        scope='Independent frozen ABI control; no compiler-generated optimization or benchmark. Source-derived expectations precede execution. Per-channel positive/negative coverage is stated by the expectation fixture.')
    report_path = out / 'report.json'
    save(report_path, report)

    def run(label, command, env):
        directory = out / label; directory.mkdir()
        row = dict(label=label, command=list(map(str, command)), started=time.time(), timeoutSeconds=30)
        report['jobs'].append(row); save(report_path, report)
        child = None
        try:
            with (directory / 'stdout').open('xb') as stdout, (directory / 'stderr').open('xb') as stderr:
                child = subprocess.Popen(row['command'], cwd=out, env=env, stdout=stdout, stderr=stderr, start_new_session=True)
                try:
                    child.wait(timeout=30)
                except BaseException:
                    if child.poll() is None:
                        os.killpg(child.pid, signal.SIGKILL)
                    child.wait()
                    raise
                row['returncode'] = child.returncode
        finally:
            row['finished'] = time.time()
            for name in ['stdout', 'stderr']:
                if (directory / name).is_file():
                    row[name] = pin(directory / name)
            save(report_path, report)
        require(row['returncode'] == 0, 'Control stage failed: ' + label)
        return row

    try:
        binary = out / 'control'
        command = [str(compiler), '-O2', '-std=gnu11', '-ffp-contract=off', '-no-pie',
            '-I' + str(args.runtime_plan.resolve().parent), str(out / 'control.c'), str(runtime_object),
            '-pthread', '-lm', '-o', str(binary)]
        run('build-control', command, dict(os.environ))
        report['binary'] = pin(binary); save(report_path, report)
        for label, enabled in [('counters-off', False), ('counters-on', True)]:
            events = out / label / 'events.json'
            env = dict(os.environ, BEND_PROFILE_COUNTERS='1' if enabled else '0', BEND_PROFILE_EVENTS_OUT=str(events))
            row = run(label, [str(binary)], env)
            row['environment'] = {key: env[key] for key in ['BEND_PROFILE_COUNTERS', 'BEND_PROFILE_EVENTS_OUT']}
            require(Path(row['stdout']['file']).read_bytes() == b'45\n' and Path(row['stderr']['file']).read_bytes() == b'',
                    'Independent output oracle failed: ' + label)
            row['events'] = pin(events)
            report['checks'].append(dict(mode=label, **validate_events(read(events), expected, enabled)))
            save(report_path, report)
        for item in inputs:
            verify(item)
        report['complete'] = True
    except BaseException as error:
        report['error'] = type(error).__name__ + ': ' + str(error)
        raise
    finally:
        report['finished'] = time.time()
        report['failurePolicy'] = 'Owned child process groups are killed/reaped on interruption/timeout; all diagnostics and failed artifacts are preserved.'
        save(report_path, report)
    print(json.dumps(dict(complete=True, report=pin(report_path), checks=report['checks'])))


if __name__ == '__main__':
    main()
