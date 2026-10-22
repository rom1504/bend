#!/usr/bin/env python3
"""Run frozen coverage through a native image; root owns the outer serial guard."""
import argparse
import importlib.util
import json
import os
from pathlib import Path
import signal
import subprocess
import sys
import time

ADAPTER = Path(__file__).resolve().parent
ROOT = ADAPTER.parents[4]
PHASE = ROOT / "selfhost/tools/performance/phase111"
HERE = PHASE / "coverage"
BUILDER = ROOT / "selfhost/tools/performance/phase123/build-aligned.py"
spec = importlib.util.spec_from_file_location('phase111_native_transport', ADAPTER / 'native-emit.py')
transport = importlib.util.module_from_spec(spec)
spec.loader.exec_module(transport)
pin, verify = transport.pin, transport.verify

# These constrain the already-frozen stage oracle; diagnostic wording remains
# non-exact. A load error, crashed image or verifier refusal cannot substitute.
REFUSALS = {
    'negative-type': ('source-admission', 'check: main:'),
    'negative-affine': ('source-admission', 'check: twice:'),
    'negative-foreign': ('backend-admission', 'compile: foreign provider unavailable in fixed runtime: p108_missing'),
}


def absolute(row):
    return dict(row, file=str((ROOT / row['file']).resolve()))


def stop_tree(child):
    # native-emit and build jobs create sessions. Snapshot descendants before
    # killing the transport so its active native child cannot outlive this gate.
    parents = {}
    for item in Path('/proc').iterdir():
        if item.name.isdecimal():
            try:
                fields = (item / 'stat').read_text().rsplit(')', 1)[1].split()
                parents[int(item.name)] = int(fields[1])
            except (OSError, ValueError, IndexError):
                pass
    victims, frontier = {child.pid}, {child.pid}
    while frontier:
        frontier = {pid for pid, parent in parents.items() if parent in frontier and pid not in victims}
        victims.update(frontier)
    for pid in sorted(victims, reverse=True):
        try:
            os.kill(pid, signal.SIGKILL)
        except ProcessLookupError:
            pass
    child.wait()


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--image', type=Path, required=True)
    p.add_argument('--runtime', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    choice = p.add_mutually_exclusive_group()
    choice.add_argument('--names', nargs='+')
    choice.add_argument('--suite', choices=['focused', 'fast', 'broad'], default='focused')
    p.add_argument('--mode', choices=['cache', 'live'], default='cache')
    p.add_argument('--references', type=Path, help='Optional JSON mapping case names to emission directories/reports')
    p.add_argument('--seconds', type=int, default=300)
    p.add_argument('--build-seconds', type=int, default=180)
    p.add_argument('--keep-going', action='store_true')
    args = p.parse_args()
    if args.seconds <= 0 or args.build_seconds <= 0:
        raise ValueError('Positive time limits required')
    out = args.out.resolve()
    if out.exists() or not out.is_relative_to(ROOT / 'selfhost/build/phase111'):
        raise ValueError('Fresh Phase111 output required')
    image = transport.member(args.image, 'program')
    runtime = transport.member(args.runtime, 'runtime.o')
    manifest_file = HERE / 'manifest.json'
    manifest = json.loads(manifest_file.read_text())
    cases = {case['name']: case for case in manifest['fixtures']}
    for case in manifest['representatives']:
        cases['broad:' + case['name']] = case
        cases.setdefault(case['name'], case)
    names = args.names or (manifest['fastOrder'] if args.suite == 'fast' else
                          ['broad:' + x['name'] for x in manifest['representatives']] if args.suite == 'broad' else
                          [x['name'] for x in manifest['fixtures']])
    selected = [cases[name] for name in names]
    if len({x['source']['file'] for x in selected}) != len(selected):
        raise ValueError('Duplicate selected source')
    references = json.loads(args.references.read_text()) if args.references else {}
    if not isinstance(references, dict) or any(not isinstance(x, str) for x in references.values()):
        raise ValueError('References must map names to paths')
    inputs = [pin(__file__), pin(ADAPTER / 'native-emit.py'), pin(PHASE / 'native-assets01.json'),
              pin(BUILDER), pin(ADAPTER / 'derivation01.json'), pin(PHASE / 'coverage/native-run.py'), pin(manifest_file), pin(image), pin(runtime), pin(sys.executable),
              *map(absolute, manifest['inputs'])]
    if args.references:
        inputs.append(pin(args.references))
    for case in selected:
        for key in ['source', 'origin', 'stdoutFile', 'expectationFile', 'independentPriorEvidence']:
            if key in case:
                inputs.append(absolute(case[key]))
        if case['expect']['stage'] == 'execute':
            if verify(absolute(case['stdoutFile'])).read_bytes() != case['expect']['stdout'].encode():
                raise ValueError('Frozen stdout file differs from manifest')
        elif case['name'] not in REFUSALS:
            raise ValueError('No native refusal policy for ' + case['name'])
    for item in inputs:
        verify(item)
    out.mkdir(parents=True)
    (out / 'method.py').write_bytes(Path(__file__).read_bytes())
    (out / 'manifest.json').write_bytes(manifest_file.read_bytes())
    report = dict(kind='phase125-aligned-native-source-semantic-coverage', complete=False, passed=False,
                  mode=args.mode, names=names, inputs=inputs, jobs=[], started=time.time(),
                  rows=[dict(name=name, expected=case['expect'], status='pending', compiled=False,
                             built=False, executed=False, semanticPass=False, expectedRefusal=False)
                        for name, case in zip(names, selected)],
                  refusalPolicy=REFUSALS, cpuAffinity=sorted(os.sched_getaffinity(0)),
                  guardRequirement='Root outer process-tree guard; serial CPU3 target lane',
                  scope='Frozen regression sources through supplied native compiler, direct QBE, cached runtime, and exact program output. Does not alone establish a self-host chain.',
                  timingScope='nativeSeconds includes native reads/compiler/stdout; buildSeconds excludes execute; executionSeconds is generated program wall. Supervisor wall includes transport/preflight/hashing.')
    start = time.monotonic()

    def save():
        rows = report['rows']
        report['seconds'] = time.monotonic() - start
        report['summary'] = dict(positiveCompiled=sum(r['compiled'] for r in rows),
            positiveBuilt=sum(r['built'] for r in rows), positiveExecuted=sum(r['executed'] for r in rows),
            semanticPasses=sum(r['semanticPass'] for r in rows), expectedRefusals=sum(r['expectedRefusal'] for r in rows),
            expectedSourceRefusals=sum(r.get('refusalStage') == 'source-admission' and r['expectedRefusal'] for r in rows),
            expectedBackendRefusals=sum(r.get('refusalStage') == 'backend-admission' and r['expectedRefusal'] for r in rows),
            pending=sum(r['status'] == 'pending' for r in rows))
        (out / 'report.json').write_text(json.dumps(report, indent=2) + '\n')

    def progress(row):
        save()
        print(json.dumps(dict(name=row['name'], status=row['status'])), flush=True)

    save()
    try:
        for index, (case, row) in enumerate(zip(selected, report['rows'])):
            request = out / (str(index) + '-native')
            try:
                source = verify(absolute(case['source']))
                positive = case['expect']['stage'] == 'execute'
                command = [sys.executable, '-B', ADAPTER / 'native-emit.py', '--image', image,
                           '--source', source, '--out', request, '--mode', args.mode, '--seconds', args.seconds]
                if positive:
                    command += ['--runtime', runtime, '--expected', verify(absolute(case['stdoutFile'])),
                                '--build-seconds', args.build_seconds]
                    reference = references.get(row['name'], references.get(case['name']))
                    if reference:
                        command += ['--reference', reference]
                row['status'] = 'running'
                progress(row)
                job = dict(name=row['name'], command=list(map(str, command)))
                report['jobs'].append(job)
                save()
                t0 = time.monotonic()
                stdout, stderr = out / (str(index) + '.stdout'), out / (str(index) + '.stderr')
                with stdout.open('xb') as so, stderr.open('xb') as se:
                    child = subprocess.Popen(job['command'], cwd=ROOT, stdout=so, stderr=se, start_new_session=True)
                    try:
                        job['exitCode'] = child.wait(timeout=args.seconds + (4 * args.build_seconds if positive else 0) + 90)
                    except BaseException as error:
                        stop_tree(child)
                        job['exitCode'] = child.returncode
                        job['timedOut'] = isinstance(error, subprocess.TimeoutExpired)
                        raise
                    finally:
                        job.update(seconds=time.monotonic() - t0, stdout=pin(stdout), stderr=pin(stderr))
                        save()
                emission_file = request / 'report.json'
                row['emission'] = pin(emission_file)
                emission = json.loads(emission_file.read_text())
                row['nativeSeconds'] = emission.get('nativeSeconds')
                native_jobs = [j for j in emission.get('jobs', []) if j.get('label') == 'native-request']
                native = native_jobs[0] if len(native_jobs) == 1 else {}
                if not positive:
                    raw = verify(emission['stderr']).read_bytes()
                    diagnostic = raw.decode('utf8')
                    diagnostic = diagnostic[:-1] if diagnostic.endswith('\n') else diagnostic
                    row['diagnostic'] = diagnostic
                    row['refusalStage'], prefix = REFUSALS[case['name']]
                    product = verify(emission['product'])
                    products = [x for x in request.rglob('*') if x.suffix in ['.s', '.o', '.c'] or x.name == 'program' or
                                (x.suffix == '.ssa' and x.stat().st_size)]
                    refused = (job['exitCode'] == 1 and not job.get('timedOut') and native.get('exitCode') == 1 and
                               not native.get('timedOut') and emission.get('kind') == 'phase125-aligned-native-source-qbe-emission' and
                               emission.get('failedStage') == 'emission' and not emission.get('complete') and
                               emission.get('gates', {}).get('emission') == 'failed' and product.stat().st_size == 0 and
                               diagnostic.startswith(prefix) and
                               (len(diagnostic) > len(prefix) or row['refusalStage'] == 'backend-admission') and
                               '\x00' not in diagnostic and not products and not (request / 'build').exists())
                    if case['expect'].get('exactDiagnostic'):
                        refused = refused and diagnostic == case['expect']['diagnostic']
                    if not refused:
                        raise RuntimeError('Expected checked source/backend refusal; crash, timeout or another stage is not a pass')
                    row.update(status='source-refused', expectedRefusal=True)
                else:
                    row['compiled'] = emission.get('gates', {}).get('emission') == 'passed'
                    row['product'] = emission.get('product')
                    build_file = request / 'build/report.json'
                    built = {}
                    if build_file.is_file():
                        row['build'] = pin(build_file)
                        built = json.loads(build_file.read_text())
                        if built.get('kind') != 'phase123-branch-aligned-qbe-build':
                            raise RuntimeError('Phase123 aligned build receipt required')
                        assemblies = [j for j in built.get('jobs', []) if j.get('label') == 'assemble']
                        if len(assemblies) != 1 or assemblies[0]['command'][1:2] != ['-mbranches-within-32B-boundaries']:
                            raise RuntimeError('Selected assembler alignment option missing')
                        row['buildSeconds'] = built.get('buildSeconds')
                        row['built'] = any(j['label'] == 'link' and j.get('exitCode') == 0 for j in built.get('jobs', []))
                        executions = [j for j in built.get('jobs', []) if j['label'] == 'execute']
                        row['executed'] = bool(executions)
                        if executions:
                            row['executionSeconds'] = executions[0].get('seconds')
                    if (job['exitCode'] or not emission.get('complete') or not built.get('complete') or
                            not built.get('outputExact') or not row['built'] or not row['executed']):
                        row['status'] = str(emission.get('failedStage', 'transport')) + '-failed'
                        row['childError'] = emission.get('error', '')
                        raise RuntimeError('Native emission, comparison, build or semantic gate failed')
                    execution = executions[0]
                    if (execution['exitCode'] != case['expect']['exitCode'] or
                            verify(execution['stdout']).read_bytes() != case['expect']['stdout'].encode() or
                            verify(execution['stderr']).read_bytes() != case['expect']['stderr'].encode()):
                        raise RuntimeError('Generated program differs from frozen complete observation')
                    row.update(status='passed', semanticPass=True, binary=built['binary'], observation=execution['stdout'])
                progress(row)
            except Exception as error:
                row['error'] = repr(error)
                if row['status'] in ['pending', 'running']:
                    row['status'] = 'failed'
                progress(row)
                if not args.keep_going:
                    break
        for item in inputs:
            verify(item)
        report['passed'] = all(r['semanticPass'] or r['expectedRefusal'] for r in report['rows'])
        report['complete'] = report['passed']
    except BaseException as error:
        report['error'] = repr(error)
    finally:
        report['finished'] = time.time()
        save()
    print(json.dumps(dict(complete=report['complete'], **report['summary'])), flush=True)
    return 0 if report['passed'] else 1


if __name__ == '__main__':
    raise SystemExit(main())
