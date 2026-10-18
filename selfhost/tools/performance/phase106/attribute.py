#!/usr/bin/env python3
"""Bounded current native full-self sampling or a separate Clang build."""
import argparse
import importlib.util
import json
from pathlib import Path
import shutil
import sys
import time

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
PERF = HERE.parent


def module(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    value = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(value)
    return value


C = module('phase106_comparison', PERF / 'phase105/compare.py')
S = module('phase106_guard', PERF / 'programs/support.py')
N = C.N


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest='kind', required=True)
    profile = sub.add_parser('profile', help='Unchanged B2 ELF, one complete self request')
    profile.add_argument('--out', type=Path, required=True)
    clang = sub.add_parser('clang', help='Current self C with its pinned O2 recipe')
    clang.add_argument('--out', type=Path, required=True)
    clang.add_argument('--time-report', action='store_true',
                       help='Separate diagnostic build; its time is not a clean build measurement')
    args = parser.parse_args()
    out = args.out.resolve()
    assert out.is_relative_to(ROOT / 'selfhost/build/phase106') and not out.exists()
    assert shutil.disk_usage(ROOT).free >= 192 * 1024**2, 'Need 192 MiB disk headroom'

    release, selection, inputs, revision, bun, ts, cases = C.prepare('self')
    assert len(cases) == 1
    case = cases[0]

    def bind(item):
        value = N.verify(item) if isinstance(item, dict) else N.pin(item)
        assert inputs.setdefault(value['file'], value) == value
        return value

    bind(__file__)
    bind(S.__file__)
    bind(sys.executable)
    out.mkdir(parents=True, exist_ok=False)
    report = dict(kind='phase106-current-native-attribution', mode=args.kind,
        complete=False, passed=False, targetsRun=False, started=time.time(),
        selection=selection, source=release['source'], producer=release['stages']['b2'],
        cpu='3', availableFloorMiB=16384, initialDiskFreeBytes=shutil.disk_usage(ROOT).free,
        diskFloorMiB=192, inputs=[], outputDirectory=str(out), defaultSelectionChanged=False)

    def save():
        report['inputs'] = list(inputs.values())
        C.save(out / 'report.json', report)

    def unchanged():
        for item in inputs.values():
            N.verify(item)
        assert N.load(stage='b2') == (release, selection), 'Selected release changed'

    def execute(argv, seconds, rss_mib):
        assert shutil.disk_usage(ROOT).free >= 192 * 1024**2, 'Need 192 MiB disk headroom'
        # The preloader belongs only to the target argv, never to the supervisor.
        command = ['bash', '-c', 'ulimit -f 65536; ulimit -c 0; exec "$@"',
            'phase106', 'taskset', '-c', '3', sys.executable, '-B',
            str(PERF / 'phase46/execute.py'), str(out / 'child.json'), *argv]
        report.update(command=command, secondsLimit=seconds, rssLimitMiB=rss_mib,
                      targetsRun=True)
        save()
        with S.ExecutionGuard(rss_mib=rss_mib, available_mib=16384) as guard:
            process = guard.run(command, out / 'guard', time.monotonic() + seconds)
        report['process'] = process
        report['raw'] = [N.pin(out / 'guard' / name)
                         for name in ['process.json', 'stdout.log', 'stderr.log']]
        assert process['complete'] and process['returncode'] == 0, process
        child = C.read(out / 'child.json')
        report['child'] = N.pin(out / 'child.json')
        assert child['returncode'] == 0 and child['command'] == argv
        report['processSeconds'] = child['processSeconds']
        report['peakRssKiB'] = child['maxRssKiB']
        return child

    save()
    try:
        if args.kind == 'profile':
            P = module('phase106_sample_analysis', PERF / 'phase101/profile.py')
            previous_pin = bind(ROOT / 'selfhost/build/phase102/observer-profile01/report.json')
            previous = C.read(previous_pin['file'])
            assert previous['complete'] and previous['samplerBuild']['guardExit'] == 0
            sampler = bind(previous['sampler'])
            sampler_source = next(v for v in previous['inputs'] if v['file'] == str(P.SAMPLER))
            bind(sampler_source)
            sampler_guard_pin = bind(previous['samplerBuild']['guard'])
            sampler_guard = C.read(sampler_guard_pin['file'])
            assert sampler_guard['complete'] and sampler_guard['returncode'] == 0
            assert str(P.SAMPLER) in sampler_guard['command'] and sampler['file'] in sampler_guard['command']
            for path in [P.__file__, P.ANALYSIS, P.R.__file__,
                         shutil.which('readelf'), shutil.which('addr2line')]:
                bind(path)
            prefix, samples = out / 'output', out / 'samples.txt'
            argv = ['env', 'LD_PRELOAD=' + sampler['file'],
                'BEND_SAMPLE_OUT=' + str(samples), 'BEND_SAMPLE_PERIOD_US=16000',
                *N.native_args(release, case['source']['file'], prefix, stage='b2')]
            report.update(sampler=sampler, samplerAcquisition=previous_pin,
                periodUs=16000, perThreadCapacity=25000, maximumSamplesAtDeadline=18750,
                oracle=case['nativeOracle'], diagnostic=case['expectedDiagnostic'],
                scope='One unchanged ELF full prepared self request. Physical leaf CPU samples, '
                      'including startup/preparation/output/teardown. No dynamic stacks, exact '
                      'parse/check/lower phase clocks, allocation census or clean timing claim.')
            child = execute(argv, seconds=300, rss_mib=6144)
            output = Path(str(prefix) + '.1.c')
            report['output'] = N.pin(output)
            report['exactC'] = output.read_bytes() == Path(case['nativeOracle']['file']).read_bytes()
            clocks = C.native_clocks(child['stderr'])
            report['nativeClocks'] = clocks
            report['exactDiagnostic'] = clocks['diagnostic'] == case['expectedDiagnostic']
            assert report['exactC'] and report['exactDiagnostic'] and not child['stdout']
            data, counts = P.analyze(samples, release['stages']['b2']['binary'])
            assert data['header']['samples'] >= 500
            report['samples'] = N.pin(samples)
            C.save(out / 'analysis.json', data)
            report.update(analysis=N.pin(out / 'analysis.json'), sampleCount=data['header']['samples'],
                          coverage=data['coverage'], leaves=P.ranked(counts, sum(counts.values())))
        else:
            build = C.read(bind(release['stages']['b2']['build'])['file'])
            source = bind(build['c'])
            compiler = bind(build['clang'])
            assert C.same(source, case['nativeOracle'])
            old_command = build['command']
            tail = old_command[old_command.index(compiler['file']):]
            expected = [compiler['file'], '-isystem',
                str(Path(compiler['file']).parents[1] / 'include/clang'), '-O2',
                source['file'], '-o', build['binary']['file'], '-lm', '-pthread']
            assert tail == expected, 'Current image recipe changed; review before attributing it'
            binary = out / 'compiler'
            argv = tail.copy()
            argv[argv.index('-o') + 1] = str(binary)
            if args.time_report:
                argv.insert(argv.index('-O2') + 1, '-ftime-report')
            report.update(c=source, clang=compiler, originalBuild=build['guard'],
                instrumented=bool(args.time_report), sameO2Recipe=True,
                scope='Fresh Clang build of frozen current self C. CPU3, same pinned compiler '
                      'and O2/link flags; diagnostic time-report is explicitly separate. '
                      'No execution, new bootstrap qualification or selection change.')
            child = execute(argv, seconds=600, rss_mib=4096)
            assert not child['stdout']
            report['binary'] = N.pin(binary)
            report['byteIdenticalToSelectedImage'] = C.same(report['binary'], build['binary'])
            report['cleanBuildTiming'] = not args.time_report
        unchanged()
        report.update(inputsUnchanged=True, complete=True, passed=True)
    except BaseException as error:
        report['error'] = repr(error)
        raise
    finally:
        report['finished'] = time.time()
        report['finalDiskFreeBytes'] = shutil.disk_usage(ROOT).free
        save()
    print(json.dumps({key: report[key] for key in
        ['complete', 'mode', 'processSeconds', 'peakRssKiB']}))


if __name__ == '__main__':
    main()
