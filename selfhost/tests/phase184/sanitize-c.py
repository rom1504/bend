#!/usr/bin/env python3
"""Finite GCC ASan/UBSan memory/UB gate; sandbox leak checking is unavailable."""
import argparse
import json
import math
import os
from pathlib import Path
import sys
import time

sys.dont_write_bytecode = True
OWN = Path(__file__).resolve()
ROOT = OWN.parents[3]
BENCH = ROOT / 'selfhost/tools/bench'
HAND = BENCH / 'handwritten-c'
CATALOG = BENCH / 'catalogs/native45/catalog.json'
sys.path.insert(0, str(BENCH))
import bench
from common import changed_inputs, fresh_output, pin, require, run, verify, write_json

FLAGS = ['-std=c11', '-O1', '-g', '-fno-omit-frame-pointer',
         '-fsanitize=address,undefined', '-ffp-contract=off', '-fno-lto']
GCC = Path('/usr/bin/gcc-10')
PROVIDERS = {
    'asan': Path('/usr/lib/gcc/x86_64-linux-gnu/10/libasan.so'),
    'ubsan': Path('/usr/lib/gcc/x86_64-linux-gnu/10/libubsan.so'),
}
SANITIZER_ENV = {
    'ASAN_OPTIONS': 'detect_leaks=0:halt_on_error=1',
    'UBSAN_OPTIONS': 'halt_on_error=1:print_stacktrace=1',
}
GROUPS = ('algorithms', 'numeric', 'render-symbolic', 'structures', 'text-map')


def environment():
    env = dict(os.environ)
    for key in ('LD_PRELOAD', 'LD_LIBRARY_PATH', 'LD_AUDIT', 'GCC_EXEC_PREFIX',
                'COMPILER_PATH', 'LIBRARY_PATH', 'CPATH', 'C_INCLUDE_PATH',
                'CPLUS_INCLUDE_PATH', 'OBJC_INCLUDE_PATH', 'CFLAGS', 'CPPFLAGS',
                'LDFLAGS', 'ASAN_OPTIONS', 'LSAN_OPTIONS', 'UBSAN_OPTIONS',
                'MSAN_OPTIONS', 'TSAN_OPTIONS', 'ASAN_SYMBOLIZER_PATH',
                'UBSAN_SYMBOLIZER_PATH'):
        env.pop(key, None)
    env.update(SANITIZER_ENV, PATH='/usr/bin:/bin', LC_ALL='C', LANG='C', TZ='UTC')
    return env


def load_cases():
    catalog = json.loads(CATALOG.read_text())
    require(catalog.get('schema') == 'bend-benchmark-native-catalog-v1', 'Wrong catalog schema')
    known = {case['id']: case for case in catalog['cases']}
    names = catalog['sets']['full']
    require(len(known) == len(catalog['cases']) == len(names) == 45
            and len(set(names)) == 45 and set(names) == set(known), 'Exact original45 catalog required')
    mappings, inputs = {}, [pin(CATALOG), pin(HAND / 'driver.c')]
    for group in GROUPS:
        file = HAND / group / 'mapping.json'
        inputs.append(pin(file))
        rows = json.loads(file.read_text())
        require(isinstance(rows, list) and 0 < len(rows) <= 45, 'Bounded mapping list required')
        for row in rows:
            name = row['id']
            require(name in known and name not in mappings and row['result'] in ('u32', 'text'),
                    'Unknown/duplicate case or result type: ' + name)
            source = (ROOT / row['source']).resolve(strict=True)
            require(source.is_relative_to(HAND / group) and source.suffix == '.c',
                    'Mapping source must belong to its handwritten group')
            mappings[name] = dict(row, source=pin(source))
            inputs.append(pin(source))
    require(set(mappings) == set(names), 'Handwritten mappings must cover all original45 exactly')
    headers = sorted(HAND.rglob('*.h'))
    require(len(headers) <= 64, 'Unexpected local header inventory')
    inputs.extend(pin(header) for header in headers)
    cases = []
    source_results = {}
    for name in names:
        case, mapping = known[name], mappings[name]
        fixture = bench.bind(case['source'], BENCH)
        expected = bench.bind(case['expectedFile'], BENCH)
        require(verify(expected).read_bytes() == case['point']['expectedStdout'].encode('utf8'),
                'Catalog expected file/text mismatch: ' + name)
        args = case['point']['runtimeArgs']
        require(isinstance(args, list) and len(args) == 2 and all(
            type(value) is int and 0 <= value <= 0xffffffff for value in args), 'Two U32 arguments required')
        source = mapping['source']['file']
        require(source_results.setdefault(source, mapping['result']) == mapping['result'],
                'One translation unit cannot expose conflicting result ABIs')
        inputs.extend([fixture, expected])
        cases.append(dict(id=name, family=case['family'], source=mapping['source'],
                          result=mapping['result'], fixture=fixture, expected=expected,
                          point=dict(case['point'], repetitions=3, warmups=2)))
    return cases, bench.unique_inputs(inputs), [pin(header) for header in headers]


def execute(args):
    started = time.monotonic()
    require(math.isfinite(args.seconds) and 0 < args.seconds <= 900, 'Explicit deadline must be 0..900 seconds')
    require(args.guarded and sorted(os.sched_getaffinity(0)) == [3], 'One outer guarded CPU3 lane is required')
    out = fresh_output(args.out, ROOT)
    deadline = started + args.seconds
    report = dict(kind='phase184-handwritten-c-sanitizer-gate', version=1,
                  complete=False, pass_=False, fullCorpusPass=False, status='preflight',
                  cpu=3, secondsLimit=args.seconds, childSecondsLimit=60,
                  flags=FLAGS, sanitizerEnvironment=SANITIZER_ENV,
                  role='GCC10 ASan/UBSan correctness only; no runtime speed or compiler-image claim.',
                  sanitizerScope='AddressSanitizer memory errors and UndefinedBehaviorSanitizer only; no leak-checking claim.',
                  leakChecking=dict(available=False, enabled=False,
                      reason='LeakSanitizer reported that it does not work under ptrace in this sandbox; no sandbox bypass attempted.',
                      priorEvidence='selfhost/build/phase184/sanitizer-all01'),
                  observation='Unmodified native45 full value, two warmup successes, three repeated successes, empty stderr.',
                  policy='Separate driver/kernel objects, no LTO; local-fold pilot precedes the remaining builds and cases.',
                  requestedCases=args.cases, selection=[], inputs=[], builds=[], commands=[], cases=[],
                  capability=dict(available=False, pilotPassed=False))
    report['pass'] = report.pop('pass_')
    env = environment()

    def save():
        write_json(out / 'report.json', report)

    def process(command, directory):
        remaining = deadline - time.monotonic()
        require(remaining > 0, 'Sanitizer gate deadline exhausted')
        directory.mkdir(parents=True, exist_ok=False)
        pending = dict(command=list(map(str, command)), complete=False, status='running',
                       sanitizerEnvironment=SANITIZER_ENV, cpu=3)
        write_json(directory / 'process.json', pending)
        report['commands'].append(dict(directory=str(directory), command=pending['command'], status='running'))
        save()
        result = run(command, cwd=ROOT, stdout=directory / 'stdout', stderr=directory / 'stderr',
                     seconds=min(60, remaining), env=env)
        write_json(directory / 'process.json', result)
        report['commands'][-1].update(status='complete' if result['complete'] else 'failed',
                                      receipt=pin(directory / 'process.json'))
        save()
        return result

    def build(label, command, artifact):
        row = dict(label=label, artifactPath=str(artifact), complete=False)
        report['builds'].append(row)
        save()
        row['process'] = process(command, out / 'build' / label)
        if artifact.is_file():
            row['artifact'] = pin(artifact)
        row['complete'] = bool(row['process']['complete'] and row.get('artifact'))
        save()
        require(row['complete'], 'Sanitized build failed: ' + label)
        return row['artifact']

    drivers, binaries, objects, source_failures = {}, {}, {}, {}

    def driver(kind):
        if kind not in drivers:
            artifact = out / 'objects' / ('driver-' + kind + '.o')
            command = [report['compiler']['file'], *FLAGS]
            if kind == 'text':
                command.append('-DP184_TEXT_RESULT')
            command += ['-c', str(HAND / 'driver.c'), '-o', str(artifact)]
            drivers[kind] = build('driver-' + kind, command, artifact)
        return drivers[kind]

    def executable(case):
        key = case['source']['file']
        require(key not in source_failures, 'Earlier build failed for shared source: ' + key)
        if key not in binaries:
            source = Path(key)
            label = source.parent.name + '-' + source.stem
            artifact = out / 'objects' / (label + '.o')
            try:
                objects[key] = build(label + '-compile',
                    [report['compiler']['file'], *FLAGS, '-c', key, '-o', str(artifact)], artifact)
                driver_object = driver(case['result'])
                binary = out / 'bin' / label
                binaries[key] = build(label + '-link',
                    [report['compiler']['file'], *FLAGS, driver_object['file'], objects[key]['file'],
                     '-lm', '-o', str(binary)], binary)
            except (OSError, ValueError, KeyError, TypeError) as error:
                source_failures[key] = str(error)
                raise
        return binaries[key]

    def observe(case, binary, stage):
        row = dict(id=case['id'], stage=stage, complete=False, correct=False,
                   source=case['source'], fixture=case['fixture'], expected=case['expected'],
                   result=case['result'], point=case['point'], executable=binary)
        report['cases'].append(row)
        save()
        try:
            for identity in (case['source'], case['fixture'], case['expected'], binary):
                verify(identity)
            command = [binary['file'], case['expected']['file'], '3', '2',
                       *map(str, case['point']['runtimeArgs'])]
            child = process(command, out / 'runs' / case['id'])
            row['process'] = child
            row['complete'] = child['complete']
            require(child['complete'] and not child.get('timedOut'), 'Sanitized process failed or exceeded deadline')
            stdout, stderr = verify(child['stdout']).read_bytes(), verify(child['stderr']).read_bytes()
            require(len(stdout) <= len(case['point']['expectedStdout'].encode('utf8')) + 128,
                    'Output exceeds native45 complete-result contract')
            bench.observation(stdout, stderr, child['exitCode'], case['point'], child['seconds'])
            row['correct'] = True
            row['sanitizerStderrEmpty'] = True
        except (OSError, ValueError, KeyError, TypeError) as error:
            row['error'] = str(error)
        save()
        return row

    save()
    try:
        cases, inputs, headers = load_cases()
        known = {case['id']: case for case in cases}
        names = args.cases.split(',') if args.cases is not None else list(known)
        require(names and len(names) == len(set(names)) and all(name in known for name in names),
                'Unknown, empty or duplicate native45 case selection')
        selected = [known[name] for name in names]
        report.update(selection=names, selectedCount=len(names), totalAvailable=45,
                      fullCorpusSelected=len(names) == 45, headers=headers,
                      uniqueSelectedTranslationUnits=len({case['source']['file'] for case in selected}))
        inputs += [pin(OWN), pin(sys.executable), pin(BENCH / 'bench.py'),
                   pin(ROOT / 'selfhost/tools/build/common.py'), pin(ROOT / 'selfhost/tools/build/assets.py')]
        report['inputs'] = bench.unique_inputs(inputs)
        save()
        try:
            report['compiler'] = pin(GCC)
            report['providers'] = {name: dict(requested=str(file), resolved=pin(file))
                                   for name, file in PROVIDERS.items()}
        except OSError as error:
            report['status'] = 'capability-unavailable'
            report['capability']['reason'] = str(error)
            raise ValueError('Pinned GCC10 or sanitizer provider unavailable; no installation attempted') from error
        report['inputs'] = bench.unique_inputs([*report['inputs'], report['compiler'],
            *(provider['resolved'] for provider in report['providers'].values())])
        # Record the compiler's own selected sanitizer libraries, not just installed
        # similarly named files. These are compiler metadata queries, with receipts.
        for name in ('asan', 'ubsan'):
            probe = process([report['compiler']['file'], '-print-file-name=lib' + name + '.so'],
                            out / 'provider' / name)
            require(probe['complete'], 'Compiler sanitizer-provider query failed')
            chosen = verify(probe['stdout']).read_text().strip()
            require(chosen and Path(chosen).is_absolute()
                    and pin(chosen) == report['providers'][name]['resolved'],
                    'Compiler selected a different sanitizer provider: ' + name)
        report['capability']['available'] = True
        (out / 'objects').mkdir()
        (out / 'bin').mkdir()
        report['status'] = 'pilot'
        save()
        # Both ABI drivers are always separate instrumented objects. The first
        # linked executable is the existing local-fold kernel with ordinary args.
        driver('u32')
        driver('text')
        pilot_case = known['local-fold']
        pilot = observe(pilot_case, executable(pilot_case), 'pilot')
        report['capability']['pilotPassed'] = pilot['correct']
        report['capability']['pilotIncludedInSelection'] = 'local-fold' in names
        require(pilot['correct'], 'Sanitized local-fold pilot failed; inspect its retained streams')
        report['status'] = 'checking'
        save()
        # One compile/link per genuinely shared translation unit; all input points
        # still receive independent normal-driver invocations and exact oracles.
        for case in selected:
            if case['id'] == 'local-fold':
                continue
            try:
                binary = executable(case)
                observe(case, binary, 'catalog')
            except (OSError, ValueError, KeyError, TypeError) as error:
                report.setdefault('buildFailures', []).append(dict(id=case['id'], error=str(error)))
                save()
                if time.monotonic() >= deadline:
                    break
        report['executionComplete'] = all(any(row['id'] == name and row['complete']
                                              for row in report['cases']) for name in names)
        report['pass'] = all(any(row['id'] == name and row['correct']
                               for row in report['cases']) for name in names)
        report['complete'] = report['executionComplete'] and report['pass'] and not report.get('buildFailures')
    except (OSError, ValueError, KeyError, TypeError, KeyboardInterrupt) as error:
        report['error'] = str(error) or type(error).__name__
    finally:
        report['changedInputs'] = changed_inputs(report['inputs'])
        report['changedProviderSelections'] = []
        for name, provider in report.get('providers', {}).items():
            try:
                require(pin(provider['requested']) == provider['resolved'], 'Provider selection changed')
            except (OSError, ValueError):
                report['changedProviderSelections'].append(name)
        report['deadlineReached'] = time.monotonic() >= deadline
        report['wallSeconds'] = time.monotonic() - started
        report['compiledTranslationUnits'] = len(objects)
        report['driverObjects'] = drivers
        report['kernelObjects'] = list(objects.values())
        report['executables'] = list(binaries.values())
        if report['changedInputs'] or report['changedProviderSelections'] or report.get('error'):
            report['complete'] = report['pass'] = False
        report['fullCorpusPass'] = bool(report['complete'] and report.get('fullCorpusSelected'))
        if report['status'] != 'capability-unavailable':
            report['status'] = 'passed' if report['complete'] else 'failed'
        save()
    return report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--seconds', type=float, required=True)
    parser.add_argument('--guarded', action='store_true')
    parser.add_argument('--cases', help='Comma-separated known IDs; default all45. The local-fold pilot always runs first.')
    report = execute(parser.parse_args())
    print(json.dumps({key: report.get(key) for key in
                     ('complete', 'pass', 'fullCorpusPass', 'status', 'selection', 'compiledTranslationUnits', 'capability')}, indent=2))
    return 0 if report['complete'] else 1


if __name__ == '__main__':
    try:
        raise SystemExit(main())
    except (OSError, ValueError, KeyError, TypeError) as error:
        print('sanitizer gate: ' + str(error), file=sys.stderr)
        raise SystemExit(1)
