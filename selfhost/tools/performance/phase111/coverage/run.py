#!/usr/bin/env python3
"""Serial direct-QBE semantic gate. Root must invoke under its process-tree guard."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import signal
import subprocess
import sys
import time

HERE = Path(__file__).resolve().parent
PHASE = HERE.parent
ROOT = HERE.parents[4]


def pin(path):
    path = Path(path).resolve()
    data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def verify(row):
    path = Path(row['file'])
    actual = pin(path if path.is_absolute() else ROOT / path)
    if (actual['bytes'], actual['sha256']) != (row['bytes'], row['sha256']):
        raise ValueError('changed input: ' + str(path))
    return Path(actual['file'])


def emission_stage(diagnostic):
    if diagnostic.startswith(('parse: ', 'load: ', 'check: ', 'compile: ')):
        return 'source-admission'
    if diagnostic.startswith('native lowering: '):
        return 'lowering'
    if diagnostic.startswith('structured IR: '):
        return 'structured-ir'
    if diagnostic.startswith(('base_', 'cache_')):
        return 'preparation'
    return 'emission'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--api', type=Path, required=True)
    parser.add_argument('--runtime', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--names', nargs='+')
    parser.add_argument('--mode', choices=['cache', 'live'], default='cache')
    parser.add_argument('--seconds', type=int, default=60)
    parser.add_argument('--keep-going', action='store_true')
    args = parser.parse_args()
    if args.seconds <= 0:
        raise ValueError('positive timeout required')
    api = args.api.resolve()
    if api.is_dir():
        api = api / 'api.mjs'
    runtime = args.runtime.resolve()
    if runtime.is_dir():
        runtime = runtime / 'runtime.o'
    out = args.out.resolve()
    if out.exists() or not out.is_relative_to(ROOT / 'selfhost/build/phase111'):
        raise ValueError('fresh Phase111 output required')
    manifest_file = HERE / 'manifest.json'
    manifest = json.loads(manifest_file.read_text())
    cases = {row['name']: row for row in manifest['fixtures']}
    for row in manifest['representatives']:
        cases['broad:' + row['name']] = row
        cases.setdefault(row['name'], row)
    names = args.names or manifest['fastOrder']
    selected = [cases[name] for name in names]
    if len({row['source']['file'] for row in selected}) != len(selected):
        raise ValueError('duplicate selected source')
    api_report_file = api.parent / 'report.json'
    api_report = json.loads(api_report_file.read_text())
    if not (api_report.get('complete') and api_report.get('checked') and
            'p111_compile_source' in api_report.get('exports', [])):
        raise ValueError('complete checked source API required')
    if verify(api_report['api']) != api:
        raise ValueError('API differs from its checked receipt')
    bun = Path(api_report['command'][0]).resolve()
    bun_rows = [row for row in api_report['inputs'] if Path(row['file']).resolve() == bun]
    if len(bun_rows) != 1:
        raise ValueError('API receipt must pin its Bun executable')
    verify(bun_rows[0])
    selection_file = ROOT / 'selfhost/tools/native/selection.json'
    selection = json.loads(selection_file.read_text())
    admission = json.loads(verify(selection['admission']).read_text())
    seed_inputs = [pin(selection_file), selection['admission'], admission['assets']['base']]
    if args.mode == 'cache':
        seed_inputs.append(admission['assets']['cache']['carrier'])
    inputs = [pin(Path(__file__)), pin(manifest_file), pin(PHASE / 'emit.mjs'),
              pin(PHASE / 'build.py'), pin(api), pin(api_report_file), pin(runtime),
              pin(bun), pin(sys.executable), *manifest['inputs'], *seed_inputs]
    for case in selected:
        for key in ['source', 'origin', 'stdoutFile', 'expectationFile', 'independentPriorEvidence']:
            if key in case:
                inputs.append(case[key])
        if case['expect']['stage'] == 'execute':
            assert verify(case['stdoutFile']).read_bytes() == case['expect']['stdout'].encode()
    for row in inputs:
        verify(row)
    out.mkdir(parents=True)
    (out / 'method.py').write_bytes(Path(__file__).read_bytes())
    (out / 'manifest.json').write_bytes(manifest_file.read_bytes())
    report = dict(kind='phase111-direct-source-semantic-coverage', complete=False,
                  passed=False, mode=args.mode, inputs=inputs, names=names, jobs=[],
                  rows=[dict(name=name, expected=case['expect'], status='pending',
                             compiled=False, built=False, executed=False, semanticPass=False,
                             expectedRefusal=False) for name, case in zip(names, selected)],
                  cpuAffinity=sorted(os.sched_getaffinity(0)), started=time.time(),
                  guardRequirement='Root outer process-tree guard; serial CPU3 target lane',
                  perProgramC=False, cproc=False, cachedRuntime=True,
                  scope='Checked hosted Bend API to direct QBE and actual execution. No native-compiler or self-host claim.')

    def save():
        report['summary'] = dict(
            positiveCompiled=sum(row['compiled'] and row['expected']['stage'] == 'execute' for row in report['rows']),
            semanticPasses=sum(row['semanticPass'] for row in report['rows']),
            expectedSourceRefusals=sum(row['expectedRefusal'] for row in report['rows']),
            pending=sum(row['status'] == 'pending' for row in report['rows']))
        (out / 'report.json').write_text(json.dumps(report, indent=2) + '\n')

    def progress(row):
        save()
        print(json.dumps(dict(name=row['name'], status=row['status'])), flush=True)

    def run(label, command, timeout):
        job = dict(label=label, command=list(map(str, command)), started=time.time())
        report['jobs'].append(job)
        save()
        start = time.monotonic()
        with (out / (label + '.stdout')).open('xb') as so, (out / (label + '.stderr')).open('xb') as se:
            child = subprocess.Popen(job['command'], cwd=ROOT, stdout=so, stderr=se, start_new_session=True)
            try:
                code = child.wait(timeout=timeout)
            except subprocess.TimeoutExpired:
                os.killpg(child.pid, signal.SIGKILL)
                code = child.wait()
                job['timedOut'] = True
        job.update(exitCode=code, seconds=time.monotonic()-start,
                   stdout=pin(out / (label + '.stdout')), stderr=pin(out / (label + '.stderr')))
        save()
        return job

    save()
    try:
        for index, (case, row) in enumerate(zip(selected, report['rows'])):
            try:
                for item in inputs:
                    verify(item)
                source = verify(case['source'])
                emit = out / (str(index) + '-emit')
                build = out / (str(index) + '-build')
                row['status'] = 'emitting'
                progress(row)
                job = run(str(index) + '-emit', [bun, PHASE / 'emit.mjs', api, source, emit, args.mode], args.seconds)
                emission = {}
                if (emit / 'report.json').exists():
                    row['emission'] = pin(emit / 'report.json')
                    emission = json.loads((emit / 'report.json').read_text())
                diagnostic = emission.get('diagnostic', '')
                row['diagnostic'] = diagnostic
                stage = emission_stage(diagnostic)
                emitted = job['exitCode'] == 0 and emission.get('complete') and emission.get('sourceChecked')
                if case['expect']['stage'] == 'source-admission':
                    products = [p for p in emit.rglob('*') if p.suffix in ['.ssa', '.s', '.o', '.c'] or p.name == 'program']
                    refused = (job['exitCode'] != 0 and not job.get('timedOut') and
                               emission.get('kind') == 'phase111-checked-source-qbe-emission' and
                               stage == 'source-admission' and bool(diagnostic) and not products and
                               not emission.get('complete') and not build.exists())
                    if case['expect'].get('exactDiagnostic'):
                        refused = refused and diagnostic == case['expect']['diagnostic']
                    if not refused:
                        row['status'] = 'unexpected-admission' if emitted else stage + '-failed'
                        raise RuntimeError('expected source-admission refusal with no products')
                    row.update(status='source-refused', expectedRefusal=True)
                    progress(row)
                    continue
                if not emitted:
                    row['status'] = stage + '-failed'
                    raise RuntimeError('positive source emission failed')
                product = verify(emission['product'])
                if product != emit / 'program.ssa':
                    raise RuntimeError('unexpected QBE product path')
                row.update(compiled=True, status='building', product=emission['product'])
                progress(row)
                job = run(str(index) + '-build', [sys.executable, '-B', PHASE / 'build.py',
                          '--source', product, '--runtime', runtime, '--out', build,
                          '--expected', verify(case['stdoutFile']), '--seconds', args.seconds], 4*args.seconds+10)
                built = {}
                if (build / 'report.json').exists():
                    row['build'] = pin(build / 'report.json')
                    built = json.loads((build / 'report.json').read_text())
                row['built'] = any(x['label'] == 'link' and x.get('exitCode') == 0 for x in built.get('jobs', []))
                row['executed'] = any(x['label'] == 'execute' for x in built.get('jobs', []))
                if job['exitCode'] != 0 or not built.get('complete') or not built.get('outputExact'):
                    row['status'] = 'execution-failed' if row['executed'] else 'build-failed'
                    row['buildError'] = built.get('error', '')
                    raise RuntimeError('build or execution gate failed')
                assert (build / 'execute.stdout').read_bytes() == case['expect']['stdout'].encode()
                assert (build / 'execute.stderr').read_bytes() == case['expect']['stderr'].encode()
                row.update(status='passed', semanticPass=True, binary=built['binary'],
                           observation=pin(build / 'execute.stdout'))
                progress(row)
            except Exception as error:
                row['error'] = repr(error)
                if row['status'] in ['pending', 'emitting', 'building']:
                    row['status'] += '-failed'
                progress(row)
                if not args.keep_going:
                    break
        for item in inputs:
            verify(item)
        report['passed'] = all(row['semanticPass'] or row['expectedRefusal'] for row in report['rows'])
        report['complete'] = report['passed']
    except BaseException as error:
        report['error'] = repr(error)
    finally:
        report.update(finished=time.time(), seconds=time.time()-report['started'])
        save()
    print(json.dumps(dict(complete=report['complete'], **report['summary'])), flush=True)
    return 0 if report['passed'] else 1


if __name__ == '__main__':
    raise SystemExit(main())
