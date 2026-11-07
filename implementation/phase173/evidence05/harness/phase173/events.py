#!/usr/bin/env python3
"""Observe a frozen diagnostic native product under Phase173 job.py.

This is host receipt/byte transport, not a compiler or a clean timing harness.
The caller supplies independently established, complete expected stdout bytes.
No compilation, relinking, runtime patching, or source transformation occurs.
"""
import argparse
import json
import os
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[3]
sys.dont_write_bytecode = True
sys.path.insert(0, str(ROOT / 'selfhost/tools/build'))
from common import pin, verify, require, fresh_output, write_json, run, same_bytes

COUNTERS = (
    'dispatches', 'heap_alloc_calls', 'heap_alloc_miss_calls', 'heap_free_calls',
    'heap_alloc_requested_words', 'heap_free_words', 'term_keep_calls',
    'term_sink_calls', 'term_drop_calls', 'ctr_take_calls', 'frame_push_calls',
    'frame_capture_words', 'return_calls', 'primitive_calls',
    'register_words_copy_requested', 'register_words_clear_requested')


def pins(value):
    if isinstance(value, dict):
        if {'file', 'bytes', 'sha256'} <= value.keys():
            yield value
        else:
            for item in value.values():
                yield from pins(item)
    elif isinstance(value, list):
        for item in value:
            yield from pins(item)


def read(path):
    require(path.stat().st_size <= 8 * 1024 * 1024, 'Receipt exceeds 8 MiB')
    return json.loads(path.read_text())


def authenticated_inputs(build_path, runtime_path, expected):
    build, runtime = read(build_path), read(runtime_path)
    require(build.get('kind') == 'bend-native-build' and build.get('complete') is True,
            'Complete native build required')
    require(not build.get('error') and not build.get('changedInputs'), 'Native build failed or changed inputs')
    ir = build.get('sourceIR') or build.get('retainedIR')
    require(ir is not None, 'Retained authenticated QBE required')
    if build.get('irDigest'):
        require({k: ir[k] for k in ('bytes', 'sha256')} == build['irDigest'],
                'Retained QBE differs from build relay digest')
    require(runtime.get('complete') is True and not runtime.get('error'),
            'Complete diagnostic runtime build required')
    verify(runtime['plan'])
    plan = read(Path(runtime['plan']['file']))
    require(plan.get('schema') == 'bend-native-profile-runtime-plan-v1'
            and plan.get('complete') is True and plan.get('reverseExact') is True
            and plan.get('compiled') is False and plan.get('executed') is False,
            'Reversible diagnostic runtime plan required')
    require(plan.get('extension') is None, 'This runner admits the base 16-counter schema only')
    require(len(runtime['jobs']) == len(plan['jobs']) == 1,
            'One independently built diagnostic runtime object required')
    job, planned = runtime['jobs'][0], plan['jobs'][0]
    require(job['label'] == planned['label'] == 'compile-runtime'
            and job['command'] == planned['command']
            and job.get('returncode') == 0 and not job.get('timedOut'),
            'Runtime compilation does not match authenticated plan')
    command = job['command']
    require(command.count('-DP144_SINGLE_MUTATOR_RFC=1') == 1,
            'Pinned single-mutator runtime policy required')
    require(command.count('-c') == command.count('-o') == 1, 'Ambiguous runtime compiler command')
    require(command[command.index('-o') + 1] == job['product']['file'], 'Runtime product mismatch')
    runtime_source = command[command.index('-c') + 1]
    require(any(x['file'] == runtime_source for x in plan['outputs']), 'Unpinned diagnostic runtime source')
    require(runtime['products'] == [job['product']] and build['runtime'] == job['product'],
            'Native executable was not linked with the authenticated diagnostic runtime')
    links = [x for x in build['jobs'] if x.get('label') == 'link']
    require(len(links) == 1, 'Exactly one native link job required')
    link = links[0]
    require(link.get('complete') is True and link.get('exitCode') == 0
            and not link.get('timedOut'), 'Native link job failed')
    require(link['command'].count(build['runtime']['file']) == 1
            and link['command'].count(build['object']['file']) == 1
            and link['command'][-2:] == ['-o', build['binary']['file']],
            'Native link command does not bind program, runtime and executable')
    inputs = [pin(__file__), pin(ROOT / 'selfhost/tools/build/common.py'), pin(sys.executable),
              pin(build_path), pin(runtime_path), pin(expected),
              *pins(build), *pins(runtime), *pins(plan)]
    unique = {}
    for item in inputs:
        old = unique.get(item['file'])
        require(old is None or old == item, 'Conflicting input identity: ' + item['file'])
        verify(item)
        unique[item['file']] = item
    return build, list(unique.values())


def event_totals(events):
    require(events.get('schema') == 'bend-native-dispatch-events-v1'
            and events.get('complete') is True and events.get('counts_enabled') is True
            and events.get('counter_overflow') is False
            and events.get('invalid_context_events') == 0, 'Invalid or incomplete event capture')
    require(events.get('counter_names') == list(COUNTERS), 'Unexpected counter schema')
    require(events.get('context_kind') == 'active-dispatch-not-logical-ancestry'
            and events.get('global_context_scope') == 'one-active-dispatch-thread-only'
            and events.get('runtime_segment_count') == 4
            and events.get('unknown_fid') == 4294967295, 'Unexpected attribution contract')
    segments = events['segment_count']
    require(type(segments) is int and 1 <= segments <= 65532, 'Invalid segment count')
    require(events.get('counter_bytes') == (segments + 5) * len(COUNTERS) * 8,
            'Counter allocation size differs from schema')
    total, seen = [0] * len(COUNTERS), set()
    require(isinstance(events.get('rows'), list), 'Event rows required')
    for row in events['rows']:
        fid, values = row['fid'], row['counts']
        require(type(fid) is int and (0 <= fid < segments + 4 or fid == 4294967295)
                and fid not in seen, 'Invalid or repeated event context')
        seen.add(fid)
        require(isinstance(values, list) and len(values) == len(COUNTERS)
                and all(type(n) is int and 0 <= n < 2**64 for n in values),
                'Invalid event counter value')
        total = [a + b for a, b in zip(total, values)]
    return dict(zip(COUNTERS, total))


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--build', type=Path, required=True)
    p.add_argument('--runtime-build', type=Path, required=True)
    p.add_argument('--expected', type=Path, required=True)
    p.add_argument('--seconds', type=int, default=15, choices=range(1, 61))
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--check-only', action='store_true', help='Authenticate receipts without executing a target')
    a = p.parse_args()
    require(not any(k.startswith('BEND_') or k in ('BANGS', 'LD_PRELOAD', 'LD_AUDIT')
                    for k in os.environ), 'Ambient Bend/profiler/loader overrides must be unset')
    build, inputs = authenticated_inputs(a.build, a.runtime_build, a.expected)
    affinity = sorted(os.sched_getaffinity(0))
    require(affinity == [3], 'Run this observation inside Phase173 job.py CPU3 guard')
    if a.check_only:
        print(json.dumps(dict(valid=True, inputs=len(inputs), targetsRun=False)))
        return
    out = fresh_output(a.out, ROOT)
    event_path = out / 'events.json'
    env = dict(os.environ, BEND_PROFILE_COUNTERS='1', BEND_PROFILE_EVENTS_OUT=str(event_path))
    command = [build['binary']['file'], '--threads', '1', '--gpu', 'off']
    report = dict(kind='phase173-native-events', complete=False, inputs=inputs,
        command=command, environment={k: env[k] for k in ('BEND_PROFILE_COUNTERS', 'BEND_PROFILE_EVENTS_OUT')},
        cpuAffinity=affinity, runtimePolicy=dict(threads=1, gpu='off', bendHeapMutators=1),
        expectedStdout=pin(a.expected),
        timingKind='diagnostic: counter overhead; not usable for performance claims',
        scope='Complete fixed-output run of authenticated diagnostic executable. Runtime events '
              'may omit generated inline work; event differences are not a direct fast-arm counter.')
    write_json(out / 'report.json', report)
    try:
        report['run'] = run(command, cwd=ROOT, stdout=out / 'stdout', stderr=out / 'stderr',
                            seconds=a.seconds, env=env)
        row = report['run']
        report['outputExact'] = (row.get('complete') is True and row['exitCode'] == 0
            and row['stderr']['bytes'] == 0 and same_bytes(out / 'stdout', a.expected))
        require(report['outputExact'], 'Target status or complete stdout/stderr oracle mismatch')
        require(event_path.is_file() and not event_path.is_symlink(), 'Fresh regular event output required')
        events = read(event_path)
        report['totals'] = event_totals(events)
        report['events'] = pin(event_path)
        for item in inputs:
            verify(item)
        report['complete'] = True
    except Exception as error:
        report['error'] = repr(error)
    finally:
        if event_path.is_file():
            report['events'] = pin(event_path)
        write_json(out / 'report.json', report)
        print(json.dumps({k: report[k] for k in ('complete', 'outputExact', 'totals', 'error') if k in report}))
    if not report['complete']:
        raise SystemExit(1)


if __name__ == '__main__':
    main()
