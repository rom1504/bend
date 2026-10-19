#!/usr/bin/env python3
"""Root-run checked-API emission and unchanged QBE build for frozen batch subsets."""
import argparse
import importlib.util
import json
import os
from pathlib import Path
import signal
import subprocess
import sys
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
PHASE111 = ROOT / 'selfhost/tools/performance/phase111'
spec = importlib.util.spec_from_file_location('phase112_benchmark', HERE / 'run.py')
method = importlib.util.module_from_spec(spec)
spec.loader.exec_module(method)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--api', type=Path, required=True)
    p.add_argument('--prefix', type=Path, required=True, help='Fresh output prefix below selfhost/build/phase111')
    p.add_argument('--out', type=Path, required=True, help='Fresh acquisition report below selfhost/build/phase112')
    p.add_argument('--names', nargs='+')
    p.add_argument('--runtime', type=Path)
    p.add_argument('--merge-reports', type=Path, help='Optional old product map; replace selected names only')
    p.add_argument('--seconds', type=int, default=60)
    p.add_argument('--build-seconds', type=int, default=30)
    args = p.parse_args()
    if sorted(os.sched_getaffinity(0)) != [3] or min(args.seconds, args.build_seconds) <= 0:
        raise ValueError('Root CPU3 outer guard and positive limits required')
    api = args.api.resolve()
    if api.is_dir():
        api /= 'api.mjs'
    api_report_file = api.parent / 'report.json'
    api_report = method.read(api_report_file)
    if not api_report.get('complete') or not api_report.get('checked') or 'p111_compile_source' not in api_report.get('exports', []):
        raise ValueError('Complete checked source API required')
    if method.verify(api_report['api']) != api:
        raise ValueError('API differs from checked receipt')
    bun = Path(api_report['command'][0]).resolve()
    bun_pin = next(x for x in api_report['inputs'] if Path(x['file']).resolve() == bun)
    method.verify(bun_pin)
    compiler_sources = [str(Path(x).resolve()) for x in api_report['command'] if x.endswith('.bend')]
    if len(compiler_sources) != 1:
        raise ValueError('Checked API must identify one compiler source')
    compiler_source = next(x for x in api_report['inputs'] if str(Path(x['file']).resolve()) == compiler_sources[0])
    method.verify(compiler_source)
    manifest_file = HERE / 'manifest01.json'
    manifest = method.read(manifest_file)
    cases = {x['name']: x for x in manifest['cases']}
    names = args.names or list(cases)
    if len(set(names)) != len(names) or set(names) - set(cases):
        raise ValueError('Unknown or duplicate frozen cases')
    runtime = args.runtime.resolve() if args.runtime else Path(manifest['phase111Runtime']['file'])
    if runtime.is_dir():
        runtime /= 'runtime.o'
    prefix, out = args.prefix.resolve(), args.out.resolve()
    if not prefix.is_relative_to(ROOT / 'selfhost/build/phase111') or out.exists() or not out.is_relative_to(ROOT / 'selfhost/build/phase112'):
        raise ValueError('Fresh phase111 product prefix and phase112 report path required')
    locations = {name: (Path(str(prefix) + '-' + name + '-emit'), Path(str(prefix) + '-' + name + '-build')) for name in names}
    if any(path.exists() for pair in locations.values() for path in pair):
        raise ValueError('Selected product output already exists')
    products = method.read(args.merge_reports) if args.merge_reports else {}
    if not isinstance(products, dict) or set(products) - set(cases):
        raise ValueError('Product map contains unknown cases')
    inputs = [method.pin(__file__), method.pin(HERE / 'run.py'), method.pin(manifest_file),
              method.pin(api_report_file), api_report['api'], method.pin(runtime), bun_pin,
              method.pin(sys.executable), method.pin(PHASE111 / 'emit.mjs'), method.pin(PHASE111 / 'build.py'),
              compiler_source, manifest['base'], manifest['carrier'], *[cases[name]['source'] for name in names]]
    if args.merge_reports:
        inputs.append(method.pin(args.merge_reports))
    for item in inputs:
        method.verify(item)
    out.mkdir(parents=True)
    (out / 'method.py').write_bytes(Path(__file__).read_bytes())
    (out / 'benchmark-method.py').write_bytes((HERE / 'run.py').read_bytes())
    report = dict(kind='phase112-checked-api-batch-acquisition', complete=False, inputs=inputs,
                  api=api_report['api'], apiReport=method.pin(api_report_file), names=names,
                  compilerSource=compiler_source,
                  jobs=[], rows=[], started=time.time(), compilerHost='checked Bend source API',
                  scope='Compiler emission and build only; actual batch output is checked later by the matched runtime harness.')
    save = lambda: method.save(out / 'report.json', report)
    save()

    def run(label, command, limit):
        job = dict(label=label, command=list(map(str, command)), limitSeconds=limit)
        report['jobs'].append(job)
        save()
        print(json.dumps(dict(stage=label, status='running')), flush=True)
        stdout, stderr = out / (label + '.stdout'), out / (label + '.stderr')
        start, child = time.monotonic(), None
        try:
            with stdout.open('xb') as so, stderr.open('xb') as se:
                child = subprocess.Popen(job['command'], cwd=ROOT, stdout=so, stderr=se, start_new_session=True)
                try:
                    child.wait(timeout=limit)
                except BaseException as error:
                    if child.poll() is None:
                        os.killpg(child.pid, signal.SIGKILL)
                    child.wait()
                    job['timedOut'] = isinstance(error, subprocess.TimeoutExpired)
                    raise
            if child.returncode:
                raise RuntimeError(label + ' exited ' + str(child.returncode))
        finally:
            job['seconds'] = time.monotonic() - start
            if child is not None:
                job['exitCode'] = child.returncode
            for key, path in [('stdout', stdout), ('stderr', stderr)]:
                if path.exists():
                    job[key] = method.pin(path)
            save()

    try:
        for index, name in enumerate(names):
            emit, build = locations[name]
            row = dict(name=name, source=cases[name]['source'], status='emitting')
            report['rows'].append(row)
            save()
            run(str(index) + '-emit', [bun, PHASE111 / 'emit.mjs', api, row['source']['file'], emit, 'cache'], args.seconds)
            emitted = method.read(emit / 'report.json')
            if not emitted.get('complete') or not emitted.get('sourceChecked'):
                raise ValueError('Checked source emission did not complete')
            product = method.verify(emitted['product'])
            row.update(status='building', emission=method.pin(emit / 'report.json'),
                       compilerSeconds=emitted.get('compilerSeconds'), qbe=emitted['product'])
            save()
            run(str(index) + '-build', [sys.executable, '-B', PHASE111 / 'build.py', '--source', product,
                                      '--runtime', runtime, '--out', build, '--seconds', args.build_seconds],
                3 * args.build_seconds + 10)
            built = method.read(build / 'report.json')
            if not built.get('complete'):
                raise ValueError('Direct QBE build did not complete')
            method.verify(built['binary'])
            row.update(status='built', build=method.pin(build / 'report.json'), binary=built['binary'],
                       buildSeconds=built.get('buildSeconds'))
            products[name] = dict(emission=str(emit / 'report.json'), build=str(build / 'report.json'))
            method.save(out / 'products-map.json', products)
            save()
        for item in inputs:
            method.verify(item)
        report.update(complete=True, productsMap=method.pin(out / 'products-map.json'))
    except BaseException as error:
        report['error'] = repr(error)
        if report['rows'] and report['rows'][-1]['status'] != 'built':
            report['rows'][-1]['status'] += '-failed'
    finally:
        report['finished'] = time.time()
        save()
    print(json.dumps(dict(complete=report['complete'], cases=len(names), productsMap=report.get('productsMap'))), flush=True)
    return 0 if report['complete'] else 1


if __name__ == '__main__':
    raise SystemExit(main())
