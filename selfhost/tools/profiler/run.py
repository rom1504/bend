#!/usr/bin/env python3
"""Reproducible clean timing and diagnostic native sampling for arbitrary programs.

The manifest supplies argv and independent stdout expectations. This module
knows nothing about compiler phases, Bend benchmark names, or optimization.
Run resource-intensive workloads inside the repository's execution guard.
"""
import argparse
import hashlib
import json
import math
import os
from pathlib import Path
import re
import signal
import statistics
import subprocess
import sys
import threading
import time

sys.dont_write_bytecode = True


def pin(path):
    path = Path(path).resolve()
    digest = hashlib.sha256()
    with path.open('rb') as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b''):
            digest.update(block)
    return dict(file=str(path), bytes=path.stat().st_size, sha256=digest.hexdigest())


def verify(item):
    actual = pin(item['file'])
    if any(actual[key] != item[key] for key in ('sha256', 'bytes')):
        raise ValueError('Frozen input changed: ' + item['file'])
    return Path(actual['file'])


def save(path, value):
    # Reports are mutable only while their fresh campaign is active.
    Path(path).write_text(json.dumps(value, indent=2, allow_nan=False) + '\n')


def all_pins(value):
    if isinstance(value, dict):
        if set(('file', 'bytes', 'sha256')) <= value.keys():
            yield value
        for child in value.values():
            yield from all_pins(child)
    elif isinstance(value, list):
        for child in value:
            yield from all_pins(child)


def output_matches(path, expected):
    if expected['kind'] == 'exact':
        actual = pin(path)
        return all(actual[key] == expected[key] for key in ('bytes', 'sha256'))
    if expected['kind'] == 'prefix-integer-line':
        # Explicit benchmark contract: complete fixed output, then one unsigned
        # elapsed-time line. No other normalization or ignored text is allowed.
        content = Path(path).read_bytes()
        prefix = expected['prefix'].encode()
        return content.startswith(prefix) and re.fullmatch(rb'[0-9]+\n', content[len(prefix):]) is not None
    raise ValueError('Unknown output expectation')


def execute(command, directory, cwd, timeout, env):
    directory.mkdir()
    finished = threading.Event()
    expired = []
    with (directory/'stdout').open('xb') as stdout, (directory/'stderr').open('xb') as stderr:
        start = time.monotonic()
        child = subprocess.Popen(command, cwd=cwd, env=env, stdout=stdout, stderr=stderr, start_new_session=True)

        def deadline():
            if not finished.wait(timeout):
                expired.append(True)
                try:
                    os.killpg(child.pid, signal.SIGKILL)
                except ProcessLookupError:
                    pass

        watchdog = threading.Thread(target=deadline, daemon=True)
        watchdog.start()
        try:
            _, status, usage = os.wait4(child.pid, 0)
            seconds = time.monotonic() - start
            child.returncode = os.waitstatus_to_exitcode(status)
        except BaseException:
            # A canceled runner must not leave its isolated workload alive.
            try:
                os.killpg(child.pid, signal.SIGKILL)
            except ProcessLookupError:
                pass
            try:
                os.waitpid(child.pid, 0)
            except ChildProcessError:
                pass
            raise
        finally:
            finished.set()
            watchdog.join()
    return dict(command=command, returncode=child.returncode, timedOut=bool(expired),
                wallSeconds=seconds, userSeconds=usage.ru_utime, systemSeconds=usage.ru_stime,
                cpuSeconds=usage.ru_utime + usage.ru_stime, peakRssKiB=usage.ru_maxrss,
                minorFaults=usage.ru_minflt, majorFaults=usage.ru_majflt,
                voluntarySwitches=usage.ru_nvcsw, involuntarySwitches=usage.ru_nivcsw,
                stdout=pin(directory/'stdout'), stderr=pin(directory/'stderr'))


def summarize(rows):
    summary = {}
    for name, variant in sorted({(r['workload'], r['variant']) for r in rows}):
        selected = [r for r in rows if (r['workload'], r['variant']) == (name, variant)]
        clean = [r for r in selected if r['mode'] == 'clean' and r.get('correct')
                 and not r.get('diagnosticRuntime') and r.get('timingKind', 'clean') == 'clean']
        instrumented = [r for r in selected if r['mode'] == 'clean' and r.get('correct')
                        and r.get('diagnosticRuntime')]
        sampled = [r for r in selected if r['mode'] == 'sample']
        metrics = {}
        for field in ('wallSeconds', 'cpuSeconds', 'peakRssKiB'):
            values = [r[field] for r in clean]
            metrics[field] = dict(samples=values, median=statistics.median(values) if values else None,
                                  minimum=min(values) if values else None, maximum=max(values) if values else None)
        summary.setdefault(name, {})[variant] = dict(cleanRuns=len(clean), clean=metrics,
            instrumentedUnsampledRuns=len(instrumented),
            instrumentedUnsampledWallSeconds=[r['wallSeconds'] for r in instrumented],
            sampledRuns=len(sampled), usableCaptures=sum(bool(r.get('profileUsable')) for r in sampled),
            diagnosticWallSeconds=[r['wallSeconds'] for r in sampled],
            diagnosticOverCleanWallRatio=(statistics.median(r['wallSeconds'] for r in sampled) /
                metrics['wallSeconds']['median']) if sampled and clean else None)
    return summary


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--manifest', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--modes', default='clean,sample')
    parser.add_argument('--rounds', type=int, default=3)
    parser.add_argument('--periods-us', default='8000,13000')
    parser.add_argument('--names', nargs='*')
    parser.add_argument('--check-only', action='store_true')
    args = parser.parse_args()
    manifest = json.loads(args.manifest.read_text())
    if manifest.get('schema') != 'bend-native-profile-workloads-v1':
        raise ValueError('Expected bend-native-profile-workloads-v1 manifest')
    modes = args.modes.split(',')
    periods = [int(x) for x in args.periods_us.split(',')]
    if not set(modes) <= {'clean', 'sample', 'events'} or len(set(modes)) != len(modes):
        raise ValueError('Unique clean/sample/events modes required')
    if not 1 <= args.rounds <= 20 or not periods or any(not 250 <= n <= 100000 for n in periods):
        raise ValueError('Invalid round count or sampling interval')
    if any(key in os.environ for key in ('LD_PRELOAD', 'BEND_SAMPLE_OUT', 'BEND_SAMPLE_PERIOD_US',
            'BEND_SAMPLE_CONTEXT_OUT', 'BEND_SAMPLE_CALLERS_OUT', 'BEND_PROFILE_EVENTS_OUT', 'BEND_PROFILE_COUNTERS')):
        raise ValueError('Ambient profiling instrumentation must be unset')
    workloads = [w for w in manifest['workloads'] if not args.names or w['name'] in args.names]
    if not workloads or (args.names and len(workloads) != len(set(args.names))):
        raise ValueError('Unknown or empty workload selection')
    if modes == ['events'] and not any(v.get('dispatchInstrumentation')
            for w in workloads for v in w['variants']):
        raise ValueError('Event collection requires an instrumented variant')
    inputs = {r['file']: r for r in all_pins(manifest)}
    from analyze import DEPENDENCY
    for method in [args.manifest, Path(__file__), Path(__file__).with_name('analyze.py'),
                   DEPENDENCY, Path(sys.executable)]:
        row = pin(method); inputs[row['file']] = row
    for item in inputs.values():
        verify(item)
    for workload in workloads:
        for variant in workload['variants']:
            if str(Path(variant['command'][0]).resolve()) != variant['binary']['file']:
                raise ValueError('Command must directly execute pinned binary')
            if variant.get('env'):
                raise ValueError('Environment overrides need an explicit future schema')
    out = args.out.resolve()
    if out.exists():
        raise ValueError('Fresh output directory required')
    if args.check_only:
        print(json.dumps(dict(valid=True, workloads=len(workloads), inputs=len(inputs), targetsRun=False)))
        return
    out.mkdir(parents=True)
    (out/'manifest.json').write_bytes(args.manifest.read_bytes())
    methods = out/'methods'; methods.mkdir()
    snapshots = []
    for item in inputs.values():
        path = Path(item['file'])
        if path.suffix in ('.py', '.c', '.h') and 'selfhost/tools/' in str(path):
            destination = methods/(item['sha256']+'-'+path.name)
            destination.write_bytes(path.read_bytes())
            snapshots.append(dict(original=item, snapshot=pin(destination)))
    report = dict(schema='bend-native-profile-run-v1', complete=False, started=time.time(),
        inputs=list(inputs.values()), cpuAffinity=sorted(os.sched_getaffinity(0)), rows=[],
        methodSnapshots=snapshots,
        scope=manifest.get('scope'), modes=modes, cleanRounds=args.rounds, samplePeriodsUs=periods,
        timing='Complete child process; diagnostic sampling times are excluded from clean metrics.')
    save(out/'report.json', report)
    try:
        for mode in modes:
            rounds = periods if mode == 'sample' else list(range(args.rounds))
            for iteration, setting in enumerate(rounds):
                ordered = workloads[iteration % len(workloads):] + workloads[:iteration % len(workloads)]
                for position, workload in enumerate(ordered):
                    variants = workload['variants']
                    shift = (iteration + position) % len(variants)
                    for variant in variants[shift:] + variants[:shift]:
                        diagnostic = variant.get('dispatchInstrumentation', False)
                        if mode == 'events' and not diagnostic:
                            continue
                        index = len(report['rows'])
                        directory = out/f'{index:03d}-{mode}-{workload["name"]}-{variant["name"]}'
                        sample_path = directory/'samples.txt'
                        env = dict(os.environ)
                        if diagnostic:
                            env['BEND_PROFILE_COUNTERS'] = '1' if mode == 'events' else '0'
                            if mode == 'events':
                                env['BEND_PROFILE_EVENTS_OUT'] = str(directory/'events.json')
                        if mode == 'sample':
                            sampler = verify(manifest['sampler'])
                            env.update(LD_PRELOAD=str(sampler), BEND_SAMPLE_OUT=str(sample_path),
                                       BEND_SAMPLE_PERIOD_US=str(setting))
                            if diagnostic:
                                env['BEND_SAMPLE_CONTEXT_OUT'] = str(directory/'contexts.txt')
                            if manifest.get('unwindTable'):
                                env['BEND_SAMPLE_CALLERS_OUT'] = str(directory/'callers.txt')
                        row = dict(workload=workload['name'], variant=variant['name'], mode=mode,
                            round=iteration + 1, periodUs=setting if mode == 'sample' else None,
                            diagnosticRuntime=diagnostic,
                            timingKind='diagnostic' if diagnostic or mode != 'clean' else 'clean')
                        report['rows'].append(row)
                        save(out/'report.json', report)
                        row.update(execute(variant['command'], directory, manifest['cwd'],
                                           workload.get('timeoutSeconds', 30), env))
                        expected = variant['expected']
                        row['correct'] = (not row['timedOut'] and row['returncode'] == expected.get('exitCode', 0)
                            and output_matches(directory/'stdout', expected['stdout'])
                            and output_matches(directory/'stderr', expected['stderr']))
                        if not row['correct']:
                            raise ValueError('Program output/status failed: ' + str(directory))
                        if mode == 'events':
                            events = json.loads((directory/'events.json').read_text())
                            if not events.get('complete') or not events.get('counts_enabled'):
                                raise ValueError('Incomplete diagnostic event report')
                            row['events'] = pin(directory/'events.json')
                        if mode == 'sample':
                            from analyze import analyze_capture
                            clean = [r['cpuSeconds'] for r in report['rows'] if r.get('correct') and
                                r['mode'] == 'clean' and not r.get('diagnosticRuntime') and
                                r.get('timingKind', 'clean') == 'clean' and
                                r['workload'] == workload['name'] and r['variant'] == variant['name']]
                            analysis = analyze_capture(sample_path, variant['binary']['file'],
                                groups=manifest.get('groups'),
                                clean_cpu_seconds=statistics.median(clean) if clean else None)
                            save(directory/'analysis.json', analysis)
                            row.update(profile=pin(sample_path), analysis=pin(directory/'analysis.json'),
                                       profileUsable=analysis['usable'])
                            if diagnostic:
                                row['contexts'] = pin(directory/'contexts.txt')
                            if manifest.get('unwindTable'):
                                row['callers'] = pin(directory/'callers.txt')
                        report['summary'] = summarize(report['rows'])
                        save(out/'report.json', report)
                        print(json.dumps({k:row[k] for k in ('workload','variant','mode','wallSeconds','correct')}
                            | {'profileUsable':row.get('profileUsable')}), flush=True)
        if not report['rows']:
            raise ValueError('Campaign executed no workloads')
        report.update(complete=True, passed=all(r['correct'] for r in report['rows']),
                      profilesUsable=all(r.get('profileUsable', True) for r in report['rows']))
    except BaseException as error:
        report['error'] = str(error)
        raise
    finally:
        report['changedInputs'] = []
        for item in inputs.values():
            try:
                verify(item)
            except (ValueError, OSError):
                report['changedInputs'].append(item['file'])
        if report['changedInputs']:
            report['complete'] = False
        report['finished'] = time.time()
        report['summary'] = summarize([r for r in report['rows'] if 'wallSeconds' in r])
        save(out/'report.json', report)
    if not report['complete']:
        raise ValueError('Inputs changed during profiling')


if __name__ == '__main__':
    main()
