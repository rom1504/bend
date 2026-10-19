#!/usr/bin/env python3
"""Root-only native acquisition of unchanged Phase93 batch programs."""
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
spec = importlib.util.spec_from_file_location('phase112_broad_method', HERE / 'run.py')
method = importlib.util.module_from_spec(spec)
spec.loader.exec_module(method)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--image', type=Path, required=True)
    p.add_argument('--runtime', type=Path, required=True)
    p.add_argument('--producer-receipt', type=Path, required=True,
                   help='Completed image qualification/build receipt binding the selected compiler image')
    p.add_argument('--prefix', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--names', nargs='+')
    p.add_argument('--names-file', type=Path)
    p.add_argument('--seconds', type=int, default=30)
    p.add_argument('--build-seconds', type=int, default=30)
    p.add_argument('--budget-seconds', type=int, default=480)
    args = p.parse_args()
    if sorted(os.sched_getaffinity(0)) != [3] or min(args.seconds, args.build_seconds, args.budget_seconds) <= 0:
        raise ValueError('Root serial CPU3 guard and positive limits required')
    if args.names and args.names_file:
        raise ValueError('Use names or names-file, not both')
    manifest = method.read(HERE / 'manifest01.json')
    cases = {x['name']: x for x in manifest['cases']}
    names = args.names or (args.names_file.read_text().split() if args.names_file else list(cases))
    if not names or len(set(names)) != len(names) or set(names) - set(cases):
        raise ValueError('Unknown, empty or duplicate corpus names')
    image, runtime = args.image.resolve(), args.runtime.resolve()
    if runtime.is_dir():
        runtime /= 'runtime.o'
    image_pin = method.pin(image)
    receipt = method.read(args.producer_receipt)
    if not (receipt.get('complete') or receipt.get('qualified')):
        raise ValueError('Completed compiler producer receipt required')
    def contains_pin(value):
        if isinstance(value, dict):
            return (value.get('file') == image_pin['file'] and value.get('sha256') == image_pin['sha256'] and
                    value.get('bytes') == image_pin['bytes']) or any(contains_pin(x) for x in value.values())
        return isinstance(value, list) and any(contains_pin(x) for x in value)
    if not contains_pin(receipt):
        raise ValueError('Producer receipt must bind the exact compiler image')
    prefix, out = args.prefix.resolve(), args.out.resolve()
    if not prefix.is_relative_to(ROOT / 'selfhost/build/phase111') or out.exists() or not out.is_relative_to(ROOT / 'selfhost/build/phase112'):
        raise ValueError('Fresh Phase111 product prefix and Phase112 report directory required')
    locations = {name: Path(str(prefix) + '-' + name) for name in names}
    if any(x.exists() for x in locations.values()):
        raise ValueError('Selected output already exists')
    inputs = [method.pin(__file__), method.pin(HERE/'run.py'), method.pin(HERE/'manifest01.json'),
              method.pin(HERE/'upstream-50ms-profile01.json'), image_pin, method.pin(runtime),
              method.pin(args.producer_receipt), method.pin(PHASE111/'native-emit.py'),
              method.pin(PHASE111/'build.py'), method.pin(sys.executable),
              manifest['base'], manifest['carrier'], *[cases[n]['source'] for n in names]]
    if args.names_file:
        inputs.append(method.pin(args.names_file))
    for x in inputs:
        method.verify(x)
    out.mkdir(parents=True)
    (out/'method.py').write_bytes(Path(__file__).read_bytes())
    (out/'benchmark-method.py').write_bytes((HERE/'run.py').read_bytes())
    report = dict(kind='phase112-broad-native-batch-acquisition', complete=False, inputs=inputs,
        image=image_pin, runtime=method.pin(runtime), producerReceipt=method.pin(args.producer_receipt),
        names=names, jobs=[], productsMap=None, started=time.time(),
        scope='Native compiler request and unchanged direct build only; product complete outputs and batch timing are qualified separately.')
    products = {}
    start = time.monotonic()
    save = lambda: method.save(out/'report.json', report)
    save()
    try:
        for index, name in enumerate(names):
            remaining = args.budget_seconds - (time.monotonic() - start)
            if remaining <= 0:
                raise TimeoutError('Acquisition campaign budget exhausted')
            command = [sys.executable, '-B', str(PHASE111/'native-emit.py'), '--image', str(image),
                       '--source', cases[name]['source']['file'], '--out', str(locations[name]),
                       '--mode', 'cache', '--runtime', str(runtime), '--seconds', str(args.seconds),
                       '--build-seconds', str(args.build_seconds)]
            job = dict(name=name, command=command, status='running', limitSeconds=min(remaining, args.seconds+3*args.build_seconds+15))
            report['jobs'].append(job)
            save()
            print(json.dumps(dict(case=name, index=index+1, total=len(names), status='compiling')), flush=True)
            so, se = out/(name+'.stdout'), out/(name+'.stderr')
            t0 = time.monotonic()
            with so.open('xb') as sout, se.open('xb') as serr:
                child = subprocess.Popen(command, cwd=ROOT, stdout=sout, stderr=serr, start_new_session=True)
                try:
                    child.wait(timeout=job['limitSeconds'])
                except BaseException:
                    if child.poll() is None:
                        os.killpg(child.pid, signal.SIGKILL)
                    child.wait()
                    raise
                finally:
                    job.update(exitCode=child.returncode, seconds=time.monotonic()-t0,
                               stdout=method.pin(so), stderr=method.pin(se))
                    save()
            if child.returncode:
                raise RuntimeError(name+' native emission/build failed')
            emitted_path = locations[name]/'report.json'
            emitted = method.read(emitted_path)
            if not emitted.get('complete') or emitted.get('image') != image_pin:
                raise ValueError('Complete exact-image native receipt required')
            built = method.read(method.verify(emitted['buildReport']))
            if not built.get('complete'):
                raise ValueError('Complete direct build receipt required')
            method.verify(built['binary'])
            job.update(status='built', emission=method.pin(emitted_path), build=emitted['buildReport'], binary=built['binary'])
            products[name] = str(emitted_path)
            method.save(out/'products-map.json', products)
            report['productsMap'] = method.pin(out/'products-map.json')
            save()
        for x in inputs:
            method.verify(x)
        report['complete'] = True
    except BaseException as error:
        report['error'] = repr(error)
    finally:
        report['finished'] = time.time()
        save()
    print(json.dumps(dict(complete=report['complete'], built=len(products), requested=len(names))), flush=True)
    return 0 if report['complete'] else 1


if __name__ == '__main__':
    raise SystemExit(main())
