#!/usr/bin/env python3
"""Root-only matched compiler transport/build screen; run inside the CPU3 guard.

One blocking wait4 timer for every native, Bun, QBE, assembler, linker and Clang
child. A watchdog limits execution without polling latency. No candidate source
or benchmark changes. Every freshly built product must match independent output.
"""
import argparse
import hashlib
import json
import math
import os
from pathlib import Path
import shutil
import signal
import statistics
import subprocess
import sys
import threading
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
ROLES = ('phase111', 'phase112', 'upstream')


def pin(path):
    path = Path(path).resolve()
    sha = hashlib.sha256()
    with path.open('rb') as stream:
        while chunk := stream.read(1024 * 1024):
            sha.update(chunk)
    return dict(file=str(path), bytes=path.stat().st_size, sha256=sha.hexdigest())


def verify(row):
    actual = pin(row['file'])
    if any(actual[key] != row[key] for key in ('bytes', 'sha256')):
        raise ValueError('Changed frozen input: ' + row['file'])
    return Path(actual['file'])


def pins(value):
    if isinstance(value, dict):
        if isinstance(value.get('file'), str) and isinstance(value.get('sha256'), str) and isinstance(value.get('bytes'), int):
            yield value
        for child in value.values():
            yield from pins(child)
    elif isinstance(value, list):
        for child in value:
            yield from pins(child)


def summarize(rows, cases, rounds):
    answer = {}
    for mode in sorted({row['mode'] for row in rows}):
        case_rows = {}
        for case in cases:
            metrics = {}
            for role in ROLES:
                sample = [r for r in rows if r['mode'] == mode and r['name'] == case['name'] and r['role'] == role]
                if len(sample) != rounds or not all(r.get('passed') for r in sample):
                    continue
                metrics[role] = {}
                for key in ('requestSeconds', 'machineBuildSeconds', 'readyExecutableStageSumSeconds', 'readyExecutableHarnessSeconds'):
                    values = [r[key] for r in sample]
                    metrics[role][key] = dict(median=statistics.median(values), minimum=min(values), maximum=max(values), samples=values)
            ratios = {}
            if len(metrics) == 3:
                for key in ('requestSeconds', 'readyExecutableStageSumSeconds'):
                    ratios[key] = {a + '/' + b: metrics[a][key]['median'] / metrics[b][key]['median']
                                   for a, b in (('phase112', 'phase111'), ('phase112', 'upstream'), ('phase111', 'upstream'))}
            case_rows[case['name']] = dict(roles=metrics, ratios=ratios)
        complete = all(len(row['roles']) == 3 for row in case_rows.values())
        geometric = {}
        if complete:
            for key in ('requestSeconds', 'readyExecutableStageSumSeconds'):
                geometric[key] = {pair: math.exp(statistics.mean(math.log(row['ratios'][key][pair]) for row in case_rows.values()))
                                  for pair in ('phase112/phase111', 'phase112/upstream', 'phase111/upstream')}
        answer[mode] = dict(complete=complete, cases=case_rows, threeCaseGeometricRatios=geometric)
    return answer


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--manifest', type=Path, default=HERE / 'manifest01.json')
    parser.add_argument('--rounds', type=int, default=3)
    parser.add_argument('--modes', default='cache', help='cache, live, or cache,live; upstream source Base in either')
    parser.add_argument('--check-only', action='store_true')
    args = parser.parse_args()
    modes = args.modes.split(',')
    if not 1 <= args.rounds <= 6 or len(set(modes)) != len(modes) or not set(modes) <= {'cache', 'live'}:
        raise ValueError('One to six rounds and unique cache/live modes required')
    out = args.out.resolve()
    if out.exists() or not out.is_relative_to(ROOT / 'selfhost/build/phase112'):
        raise ValueError('Fresh Phase112 output directory required')
    manifest = json.loads(args.manifest.read_text())
    if manifest.get('kind') != 'phase112-frozen-native-transport-comparison':
        raise ValueError('Frozen transport manifest required')
    inputs = {row['file']: row for row in pins(manifest)}
    for path in (Path(__file__), args.manifest, Path(sys.executable)):
        row = pin(path); inputs[row['file']] = row
    for row in inputs.values():
        verify(row)
    cases = manifest['cases']
    for case in cases:
        if verify(case['stdout']).read_bytes() != case['expect']['stdout'].encode():
            raise ValueError('Expected bytes differ from frozen case')
        if case['expect']['stderr'] or case['expect']['exitCode'] != 0:
            raise ValueError('This screen requires exact successful programs')
    assets = manifest['nativeAssets']
    selection = json.loads(verify(assets['selection']).read_text())
    admission = json.loads(verify(assets['admission']).read_text())
    if selection['admission'] != assets['admission'] or not (admission['complete'] and admission['qualified']):
        raise ValueError('Native Base admission changed')
    if admission['assets']['base'] != assets['base'] or admission['assets']['cache'] != assets['cache']:
        raise ValueError('Native Base/cache binding changed')
    out.mkdir(parents=True)
    (out / 'method.py').write_bytes(Path(__file__).read_bytes())
    (out / 'manifest.json').write_bytes(args.manifest.read_bytes())
    schedule = []
    for mode in modes:
        for rnd in range(args.rounds):
            for position in range(len(cases)):
                case = cases[(position + rnd) % len(cases)]
                shift = (position + 2 * rnd) % len(ROLES)
                for role in ROLES[shift:] + ROLES[:shift]:
                    schedule.append(dict(mode=mode, round=rnd + 1, name=case['name'], role=role))
    report = dict(kind='phase112-matched-native-transport-build', complete=False, passed=False,
                  started=time.time(), inputs=list(inputs.values()), manifest=pin(args.manifest),
                  roles=manifest['roles'], cases=cases, modes=modes, rounds=args.rounds,
                  schedule=schedule, rows=[], cpuAffinity=sorted(os.sched_getaffinity(0)),
                  scope=manifest['scope'], timingScope=manifest['timer'], buildPolicy=manifest['buildPolicy'],
                  clocks=dict(requestSeconds='Whole compiler child through complete output and exit, native QBE versus upstream C explicitly distinct formats.',
                              machineBuildSeconds='Sum of fresh QBE/as/link children or fresh upstream Clang child.',
                              readyExecutableStageSumSeconds='Request plus machine-build child sums; excludes Python authentication/reporting and generated-program execution.',
                              readyExecutableHarnessSeconds='Elapsed through binary construction including between-stage Python bookkeeping, starting after preflight.',
                              executionSeconds='Single full-output correctness observation only, not program-speed benchmark.'),
                  modeNotes=dict(cache='Native authenticated prepared Base; upstream loads/checks source Base. Persistent-cache advantage disclosed.',
                                 live='Native and upstream source Base, fresh processes; OS caches are not flushed.'),
                  lineage=manifest.get('lineage', 'Experimental route N2 baseline versus new route N1 candidate, not a same-source B1/B2 generation comparison.'),
                  checkOnly=args.check_only)
    def save():
        temporary = out / 'report.json.tmp'
        temporary.write_text(json.dumps(report, indent=2) + '\n')
        temporary.replace(out / 'report.json')
    save()
    if args.check_only:
        report.update(complete=True, passed=True, targetJobs=0, finished=time.time())
        save(); print(json.dumps(dict(complete=True, targetJobs=0))); return
    by_name = {case['name']: case for case in cases}
    products = {}
    def run(row, label, command, stdout, stderr, timeout):
        job = dict(stage=label, command=list(map(str, command)), status='running', timeoutSeconds=timeout)
        row['jobs'].append(job); save()
        timed_out = threading.Event()
        finished = threading.Event()
        child = None
        timer = None
        try:
            with stdout.open('xb') as so, stderr.open('xb') as se:
                start = time.perf_counter()
                child = subprocess.Popen(job['command'], cwd=ROOT, stdout=so, stderr=se, start_new_session=True)
                def expire():
                    if not finished.is_set():
                        timed_out.set()
                        try: os.killpg(child.pid, signal.SIGKILL)
                        except ProcessLookupError: pass
                timer = threading.Timer(timeout, expire)
                timer.daemon = True
                timer.start()
                while True:
                    try:
                        _, status, usage = os.wait4(child.pid, 0)
                        break
                    except InterruptedError:
                        continue
                elapsed = time.perf_counter() - start
                finished.set(); timer.cancel()
                child.returncode = os.waitstatus_to_exitcode(status)
            job.update(seconds=elapsed, returncode=child.returncode, timedOut=timed_out.is_set(),
                       peakRssKiB=usage.ru_maxrss, userSeconds=usage.ru_utime, systemSeconds=usage.ru_stime,
                       stdout=pin(stdout), stderr=pin(stderr), status='complete' if child.returncode == 0 and not timed_out.is_set() else 'failed')
            if job['status'] != 'complete':
                raise RuntimeError(f'{label} failed: {child.returncode}, timeout={timed_out.is_set()}')
            return elapsed
        except BaseException as error:
            job.update(status='failed', error=repr(error))
            raise
        finally:
            finished.set()
            if timer: timer.cancel()
            save()
    try:
        for planned in schedule:
            if shutil.disk_usage(ROOT).free < 256 * 1024**2:
                raise RuntimeError('Less than256MiB free disk')
            case = by_name[planned['name']]
            role = planned['role']; mode = planned['mode']
            folder = out / f"{len(report['rows']):03d}-{case['name']}-{mode}-{role}"
            folder.mkdir()
            row = dict(**planned, jobs=[], passed=False)
            report['rows'].append(row); save()
            stage_start = time.perf_counter()
            if role == 'upstream':
                upstream = manifest['roles']['upstream']
                prefix = folder / 'emission'
                command = [upstream['bun']['file'], upstream['worker']['file'], upstream['manifest']['file'], case['source']['file'], prefix]
                emitted = Path(str(prefix) + '.1.c')
                compiler_stdout = folder / 'compile.stdout'
            else:
                command = [manifest['roles'][role]['binary']['file'], '--threads', '1', '--gpu', 'off', '--', 'phase111',
                           case['source']['file'], assets['base']['file'], mode,
                           assets['cache']['carrier']['file'], assets['cache']['stamp']]
                emitted = folder / 'program.ssa'; compiler_stdout = emitted
            row['requestSeconds'] = run(row, 'compile-' + ('c' if role == 'upstream' else 'qbe'), command,
                compiler_stdout, folder / 'compile.stderr', manifest['limits']['requestSeconds'])
            if (folder / 'compile.stderr').stat().st_size or not emitted.is_file() or not emitted.stat().st_size:
                raise RuntimeError('Compiler diagnostics or empty/missing representation')
            if role == 'upstream':
                upstream_report = json.loads(Path(str(prefix) + '.json').read_text())
                if not (upstream_report.get('complete') and upstream_report.get('checked') and upstream_report.get('holes') == 0):
                    raise RuntimeError('Upstream request did not pass its checked gate')
                row['upstreamDiagnosticClocks'] = {k: upstream_report[k] for k in ('importsMs', 'requestMs') if k in upstream_report}
            row['representation'] = pin(emitted)
            key = (role, case['name'])
            old = products.setdefault(key, row['representation']['sha256'])
            if old != row['representation']['sha256']:
                raise RuntimeError('Role output changed across samples/modes')
            tools = manifest['tools']; binary = folder / 'program'
            if role == 'upstream':
                clang = Path(tools['clang']['file'])
                commands = [('clang', [clang, '-isystem', clang.parents[1] / 'include/clang', '-O2', emitted, '-o', binary, '-lm', '-pthread'])]
            else:
                commands = [('qbe', [tools['qbe']['file'], '-t', 'amd64_sysv', '-o', folder / 'program.s', emitted]),
                            ('assemble', [tools['assembler']['file'], '-o', folder / 'program.o', folder / 'program.s']),
                            ('link', [tools['linker']['file'], '-no-pie', folder / 'program.o', manifest['runtime']['file'], '-pthread', '-lm', '-o', binary])]
            row['machineBuildSeconds'] = 0
            for label, command in commands:
                row['machineBuildSeconds'] += run(row, label, command, folder / (label + '.stdout'), folder / (label + '.stderr'), manifest['limits']['buildStageSeconds'])
            row['readyExecutableHarnessSeconds'] = time.perf_counter() - stage_start
            row['readyExecutableStageSumSeconds'] = row['requestSeconds'] + row['machineBuildSeconds']
            row['binary'] = pin(binary)
            row['executionSeconds'] = run(row, 'execute', [binary, '--threads', '1', '--gpu', 'off'],
                folder / 'execute.stdout', folder / 'execute.stderr', manifest['limits']['executionSeconds'])
            if (folder / 'execute.stdout').read_bytes() != Path(case['stdout']['file']).read_bytes() or (folder / 'execute.stderr').stat().st_size:
                raise RuntimeError('Generated program differs from independent complete output')
            row.update(passed=True, outputExact=True, stderrExact=True)
            save()
            print(json.dumps(dict(**planned, passed=True, requestSeconds=row['requestSeconds'], readySeconds=row['readyExecutableStageSumSeconds'])), flush=True)
        for item in inputs.values(): verify(item)
        report.update(complete=True, passed=True, inputsUnchanged=True,
                      summary=summarize(report['rows'], cases, args.rounds), finished=time.time())
        save()
        print(json.dumps(dict(complete=True, rows=len(report['rows']), summary=report['summary'])))
    except BaseException as error:
        report.update(error=repr(error), finished=time.time(), summary=summarize(report['rows'], cases, args.rounds))
        save()
        raise


if __name__ == '__main__':
    main()
