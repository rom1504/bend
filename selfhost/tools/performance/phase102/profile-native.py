#!/usr/bin/env python3
"""Root-only bounded leaf profiling of an unchanged authenticated native image."""
import argparse
import collections
from pathlib import Path
import shutil
import sys
import time
sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[4]
PERF = ROOT / 'selfhost/tools/performance'
sys.path.insert(0, str(PERF / 'phase100'))
import run as R
Q = R.module('phase102_profile_native_auth', PERF / 'phase99/qualification/reuse.py')
N = Q.support
P = R.module('phase102_profile_native_analysis', PERF / 'phase101/profile.py')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--build', type=Path, required=True)
    parser.add_argument('--request-row', type=Path, required=True)
    parser.add_argument('--sampler-report', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--rounds', type=int, default=3)
    parser.add_argument('--periods', default='8000,13000')
    parser.add_argument('--seconds', type=int, default=60)
    a = parser.parse_args()
    assert 1 <= a.rounds <= 6 and 10 <= a.seconds <= 60
    periods = list(map(int, a.periods.split(',')))
    assert len(periods) == len(set(periods)) and periods and all(8000 <= x <= 32000 for x in periods)
    out = a.out.resolve(); assert out.is_relative_to(ROOT / 'selfhost/build/phase102')
    out.mkdir(parents=True, exist_ok=False)
    bindings = N.Bindings(); ctx = Q.baseline(bindings)
    build = N.read(bindings.bind(a.build)['file'])
    producer = N.authenticate(build['binary'], build['stage'], build['source'], a.build, bindings, ctx)
    row = N.read(bindings.bind(a.request_row)['file'])
    assert row['passed'] and N.bounded_exit(row['process'], 0) and len(row['clocks']) == 1
    bindings.tree(row['raw']); source = bindings.bind(row['source'])
    oracle = bindings.bind(row['output']); diagnostic = bindings.bind(row['diagnosticFile'])
    assert Path(diagnostic['file']).read_text() == row['diagnostic']
    assert oracle['file'].endswith('.1.c')
    old_prefix = oracle['file'][:-len('.1.c')]
    old_args = N.native_args(ctx, producer, source['file'], old_prefix, live=row['live'])
    assert row['command'] == ['bash', '-c', 'ulimit -f 65536; ulimit -c 0; exec "$@"',
                              'phase98', 'taskset', '-c', '3', *old_args]
    assert row['process']['command'] == row['command']
    raw = {Path(v['file']).name:Path(v['file']) for v in row['raw']}
    assert N.read(raw['process.json']) == row['process']
    assert not raw['stdout.log'].read_bytes()
    assert N.strip_clocks(raw['stderr.log'].read_text()) == row['diagnostic']
    # Reuse the already built generic sampler. It has no image-specific table.
    previous = N.read(bindings.bind(a.sampler_report)['file'])
    assert previous['complete'] and previous['samplerBuild']['guardExit'] == 0
    sampler = bindings.bind(previous['sampler'])
    sampler_source = next(v for v in previous['inputs'] if v['file'] == str(P.SAMPLER))
    bindings.bind(sampler_source)
    sampler_guard = N.read(bindings.bind(previous['samplerBuild']['guard'])['file'])
    assert N.bounded_exit(sampler_guard, 0)
    assert str(P.SAMPLER) in sampler_guard['command'] and sampler['file'] in sampler_guard['command']
    for file in [__file__, P.__file__, P.ANALYSIS, Q.__file__, N.__file__, N.S.__file__,
                 shutil.which('readelf'), shutil.which('addr2line')]: bindings.bind(file)
    report = dict(kind='phase102-unchanged-native-compiler-profile', complete=False,
        targetsRun=False, source=source, producer=producer, oracle=oracle, diagnostic=diagnostic,
        sampler=sampler, periodsUs=periods, rounds=a.rounds, globalTargetSeconds=a.seconds,
        rows=[], inputs=list(bindings.rows.values()),
        scope='Unchanged ELF physical leaf attribution, one worker, full repeated isolated '
              'requests including startup and IO. Full C and clock-stripped diagnostics '
              'must equal the same-image qualification request. No compiler rebuild, '
              'source instrumentation, dynamic stack attribution or clean speed claim.')
    def save(): R.save(out / 'report.json', report)
    save(); buckets = collections.defaultdict(collections.Counter)
    try:
        assert shutil.disk_usage(ROOT).free >= 512 * 1024**2
        deadline = time.monotonic() + a.seconds
        with N.S.ExecutionGuard(rss_mib=2048, available_mib=16384) as guard:
            for period in periods:
                for rnd in range(a.rounds):
                    assert time.monotonic() < deadline, 'Global capture budget exhausted'
                    dest = out / f'p{period}-r{rnd}'; dest.mkdir()
                    prefix = dest / 'output'; samples = dest / 'samples.txt'
                    args = N.native_args(ctx, producer, source['file'], prefix, live=row['live'])
                    command = ['bash', '-c', 'ulimit -f 65536; ulimit -c 0; exec "$@"',
                        'phase102-profile', 'taskset', '-c', '3', 'env', 'LD_PRELOAD=' + sampler['file'],
                        'BEND_SAMPLE_OUT=' + str(samples), 'BEND_SAMPLE_PERIOD_US=' + str(period), *args]
                    record = dict(periodUs=period, round=rnd, command=command, complete=False)
                    report['rows'].append(record); report['targetsRun'] = True; save()
                    record['process'] = guard.run(command, dest / 'guard', min(deadline, time.monotonic() + 30))
                    record['raw'] = [R.pin(dest / 'guard' / f) for f in ['process.json', 'stdout.log', 'stderr.log']]
                    assert N.bounded_exit(record['process'], 0), record['process']
                    output = Path(str(prefix) + '.1.c')
                    record['output'] = R.pin(output)
                    record['exactC'] = output.read_bytes() == Path(oracle['file']).read_bytes()
                    stderr = (dest / 'guard/stderr.log').read_text()
                    record['exactDiagnostic'] = N.strip_clocks(stderr) == row['diagnostic']
                    assert record['exactC'] and record['exactDiagnostic'] and not (dest / 'guard/stdout.log').read_bytes()
                    data, counts = P.analyze(samples, producer['binary'])
                    record['samples'] = R.pin(samples)
                    R.save(dest / 'analysis.json', data)
                    record.update(analysis=R.pin(dest / 'analysis.json'), sampleCount=data['header']['samples'],
                                  coverage=data['coverage'], complete=True)
                    buckets[period].update(counts); buckets['all'].update(counts); save()
        report['summaries'] = [dict(periodUs=k, samples=sum(v.values()), leaves=P.ranked(v, sum(v.values())))
                               for k, v in buckets.items()]
        assert sum(buckets['all'].values()) >= 500, 'Insufficient pooled samples; retain exploratory only'
        bindings.unchanged(); report['inputsUnchanged'] = True; report['complete'] = True
    except BaseException as error:
        report['error'] = repr(error); raise
    finally: save()
    print(R.json.dumps(dict(complete=report['complete'], samples=sum(buckets['all'].values()),
                           leaves=P.ranked(buckets['all'], sum(buckets['all'].values()))[:15])))


if __name__ == '__main__': main()
