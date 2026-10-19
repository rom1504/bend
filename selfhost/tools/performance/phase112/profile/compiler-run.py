#!/usr/bin/env python3
"""Root-only cached compiler relink and exact lexer-scan request call profile."""
import argparse
import json
import os
from pathlib import Path
import signal
import subprocess
import sys
import time
from prepare import ROOT, HERE, SOURCE_SHA
from parse import pin
from run import read, verify


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--plan', type=Path, default=HERE / 'compiler-plan01.json')
    p.add_argument('--runtime-run', type=Path, required=True,
                   help='Batch report with passed independent counter control and cached runtime object')
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--budget-seconds', type=float, default=60)
    a = p.parse_args()
    if sorted(os.sched_getaffinity(0)) != [3]:
        raise SystemExit('root must run on CPU3 under the outer resource guard')
    out = a.out.resolve()
    if out.exists() or not out.is_relative_to(ROOT / 'selfhost/build/phase112') or a.budget_seconds <= 0:
        raise SystemExit('fresh Phase112 output and positive budget required')
    plan = read(a.plan)
    if plan['kind'] != 'phase112-frozen-compiler-diagnostic' or plan['name'] != 'lexer-scan':
        raise SystemExit('frozen compiler diagnostic plan required')
    previous = read(a.runtime_run)
    if (previous.get('kind') != 'phase112-diagnostic-batch' or
            not (previous.get('control') or {}).get('complete')):
        raise SystemExit('independent runtime counter control must qualify before compiler profiling')
    control_path = verify(previous['control']['profile'])
    control = read(control_path)
    if (not control.get('complete') or not control.get('independentCounterControl') or
            control['meta']['sourceSha256'] != SOURCE_SHA):
        raise SystemExit('cached runtime control is not qualified for this diagnostic source')
    runtime_object = verify(previous['runtimeObject'])
    runtime_jobs = [j for j in previous['jobs'] if j['label'] == 'runtime-build']
    if len(runtime_jobs) != 1 or runtime_jobs[0]['exitCode'] != 0:
        raise SystemExit('missing successful diagnostic runtime build receipt')
    runtime_source = Path(runtime_jobs[0]['command'][-3])
    if runtime_jobs[0]['command'][-2:] != ['-o', str(runtime_object)] or runtime_source.name != 'runtime.c':
        raise SystemExit('unexpected diagnostic runtime build command')
    runtime_manifest = runtime_source.with_name('manifest.json')
    runtime = read(runtime_manifest)
    if runtime.get('kind') != 'phase112-diagnostic-runtime' or runtime['source']['sha256'] != SOURCE_SHA:
        raise SystemExit('wrong cached diagnostic runtime source')
    bound_paths = {record['file']: record for record in previous['inputs']}
    if str(runtime_manifest) not in bound_paths or pin(runtime_manifest) != bound_paths[str(runtime_manifest)]:
        raise SystemExit('runtime source manifest is not bound by qualified control receipt')
    for frozen in runtime['output']:
        verify(frozen)
        if frozen['file'] not in bound_paths or frozen != bound_paths[frozen['file']]:
            raise SystemExit('runtime source output is not bound by qualified control receipt')
    inputs = [pin(a.plan), pin(Path(__file__)), pin(HERE / 'parse.py'), pin(HERE / 'prepare.py'),
              pin(HERE / 'run.py'), pin(a.runtime_run), previous['control']['profile'],
              previous['runtimeObject'], pin(runtime_manifest), *runtime['output'], *plan['inputs']]
    for record in inputs:
        verify(record)
    built = read(plan['compilerBuild']['file'])
    request = read(plan['requestReceipt']['file'])
    jobs = [j for j in request['jobs'] if j['label'] == 'native-request']
    if (not built.get('complete') or built['object'] != plan['compilerObject'] or
            not request.get('complete') or len(jobs) != 1 or jobs[0]['exitCode'] != 0 or
            jobs[0]['command'] != plan['requestCommand'] or request['product'] != plan['expectedSSA'] or
            request['image'] != built['binary'] or plan['compilerQBE'] not in built['inputs']):
        raise SystemExit('compiler plan does not match exact original build/request receipts')
    out.mkdir(parents=True)
    (out / 'plan.json').write_bytes(a.plan.read_bytes())
    (out / 'method.py').write_bytes(Path(__file__).read_bytes())
    expected = out / 'expected-output.json'
    expected.write_text(json.dumps(dict(status=0, stdout=Path(plan['expectedSSA']['file']).read_bytes().decode('utf8'),
                                        stderr=''), indent=2) + '\n')
    inputs.append(pin(expected))
    report = dict(kind='phase112-compiler-runtime-count-profile', version=1, complete=False,
                  diagnosticOnly=True, timingsAreNotPerformanceResults=True,
                  inputs=inputs, jobs=[], expectedSSA=plan['expectedSSA'],
                  compilerObject=plan['compilerObject'], compilerQBE=plan['compilerQBE'],
                  runtimeObject=previous['runtimeObject'], control=previous['control'],
                  budgetSeconds=a.budget_seconds, cpuAffinity=[3],
                  scope='Exact lexer-scan request, cached full compiler object, cached qualified diagnostic runtime. '
                        'Whole-process source-level helper counts including request IO, frontend, backend and readback; '
                        'not CPU samples, benchmark timings, or a new self-host qualification.')
    start = time.monotonic()

    def save():
        report['supervisorSeconds'] = time.monotonic() - start
        temporary = out / 'report.tmp'
        temporary.write_text(json.dumps(report, indent=2) + '\n')
        temporary.replace(out / 'report.json')

    def run(label, command, seconds):
        row = dict(label=label, command=list(map(str, command)), state='pending')
        report['jobs'].append(row)
        save()
        remaining = a.budget_seconds - (time.monotonic() - start)
        if remaining <= 0:
            raise TimeoutError('compiler diagnostic budget exhausted')
        so, se = out / (label + '.stdout'), out / (label + '.stderr')
        begin = time.monotonic()
        with so.open('xb') as stdout, se.open('xb') as stderr:
            child = subprocess.Popen(row['command'], cwd=ROOT, stdout=stdout, stderr=stderr, start_new_session=True)
            try:
                child.wait(timeout=min(seconds, remaining))
            except BaseException:
                if child.poll() is None:
                    os.killpg(child.pid, signal.SIGKILL)
                child.wait()
                row['state'] = 'interrupted'
                raise
            finally:
                row.update(exitCode=child.returncode, diagnosticWallSeconds=time.monotonic()-begin,
                           stdout=pin(so), stderr=pin(se))
                save()
        row['state'] = 'done' if child.returncode == 0 else 'failed'
        save()
        if child.returncode != 0:
            raise RuntimeError(label + ' failed; raw observations preserved')
        return row

    save()
    try:
        binary = out / 'compiler.program'
        run('relink', [plan['linker']['file'], '-no-pie', plan['compilerObject']['file'],
                       runtime_object, '-pthread', '-lm', '-o', binary], 15)
        report['binary'] = pin(binary)
        observed = run('compiler-request', [binary, *plan['requestCommand'][1:]], 45)
        if (observed['stdout']['bytes'] != plan['expectedSSA']['bytes'] or
                observed['stdout']['sha256'] != plan['expectedSSA']['sha256']):
            raise ValueError('diagnostic compiler raw SSA differs from exact uninstrumented request')
        report['exactSSA'] = True
        run('parse', [sys.executable, HERE / 'parse.py', '--stdout', observed['stdout']['file'],
            '--stderr', observed['stderr']['file'], '--status', '0', '--expected', expected,
            '--runtime-manifest', runtime_manifest, '--qbe', plan['compilerQBE']['file'],
            '--out', out / 'profile'], 15)
        profile_path = out / 'profile/profile.json'
        profile = read(profile_path)
        report.update(profile=pin(profile_path), counters=profile['counters'],
                      dominant={name: rows[:25] for name, rows in profile['histograms'].items()})
        for record in inputs:
            verify(record)
        report['complete'] = True
    except BaseException as error:
        report['error'] = repr(error)
    finally:
        save()
    print(json.dumps(dict(complete=report['complete'], exactSSA=report.get('exactSSA', False),
                         report=str(out / 'report.json'))), flush=True)
    return 0 if report['complete'] else 1


if __name__ == '__main__':
    raise SystemExit(main())
