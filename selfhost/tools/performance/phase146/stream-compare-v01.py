#!/usr/bin/env python3
"""Fresh native requests with literal bounded streaming QBE comparison.

Transport/oracle only; no compiler transformation, machine build or cache.
Root owns one outer CPU/RSS guard. Each producer sees identical handling.
"""
import argparse
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import resource
import selectors
import signal
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parents[4]
METHOD = ROOT/'selfhost/tools/performance/phase130/native-request.py'
spec = importlib.util.spec_from_file_location('native', METHOD)
N = importlib.util.module_from_spec(spec)
spec.loader.exec_module(N)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ['baseline', 'candidate', 'source', 'carrier-receipt', 'expected-qbe', 'out']:
        parser.add_argument('--'+name, type=Path, required=True)
    parser.add_argument('--seconds', type=int, default=600)
    a = parser.parse_args()
    out = a.out.resolve()
    N.require(not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase146'), 'Fresh Phase146 output')
    N.require(0 < a.seconds <= 900, 'Bounded per-request deadline')
    N.require(not any(k in os.environ for k in ['LD_PRELOAD', 'BEND_SAMPLE_OUT', 'BEND_SAMPLE_CONTEXT_OUT', 'BEND_PROFILE_EVENTS_OUT', 'BEND_PROFILE_COUNTERS']), 'No diagnostic instrumentation')
    carrier, base, inputs = N.carrier_inputs(a.carrier_receipt.resolve())
    images = {role: N.pin(getattr(a, role)) for role in ['baseline', 'candidate']}
    source, oracle = N.pin(a.source), N.pin(a.expected_qbe)
    inputs += [N.pin(__file__), N.pin(METHOD), N.pin(sys.executable), source, oracle, *images.values()]
    for image in images.values():
        receipt = Path(image['file']).parent/'report.json'
        build = json.loads(receipt.read_text())
        N.require(build['complete'] and build['binary'] == image, 'Completed producer receipt')
        inputs.append(N.pin(receipt))
    for item in inputs:
        N.verify(item)
    out.mkdir(parents=True)
    report = dict(kind='phase146-literal-stream-native-comparison', complete=False, inputs=inputs,
                  rows=[], source=source, expectedQbe=oracle, inheritedAffinity=sorted(os.sched_getaffinity(0)),
                  scope='One fresh baseline-first pair; same source, prepared Base, serial runtime mode and bounded byte-for-byte output consumer. No source-result reuse, QBE machine build or IR copy. OS caches not flushed. Candidate request is observed Q3.')
    start = time.monotonic()

    def save():
        report['seconds'] = time.monotonic()-start
        temp = out/'report.tmp'
        temp.write_text(json.dumps(report, indent=2)+'\n')
        temp.replace(out/'report.json')

    try:
        for role, image in images.items():
            command = [image['file'], '--threads', '1', '--gpu', 'off', '--', 'phase111',
                       source['file'], base['file'], 'cache', carrier['carrier']['file'], carrier['stamp']]
            row = dict(role=role, image=image, command=command, complete=False)
            report['rows'].append(row)
            save()
            child = None
            with (out/(role+'.stderr')).open('xb') as error, Path(oracle['file']).open('rb') as expected, selectors.DefaultSelector() as selector:
                before = resource.getrusage(resource.RUSAGE_CHILDREN)
                tick = time.monotonic()
                try:
                    child = subprocess.Popen(command, cwd=ROOT, stdout=subprocess.PIPE, stderr=error, bufsize=0, start_new_session=True)
                    os.set_blocking(child.stdout.fileno(), False)
                    selector.register(child.stdout, selectors.EVENT_READ)
                    size, digest, maximum = 0, hashlib.sha256(), 0
                    while selector.get_map():
                        N.require(time.monotonic()-tick < a.seconds, 'Request deadline exceeded')
                        for key, _ in selector.select(.25):
                            block = os.read(key.fd, 65536)
                            if not block:
                                selector.unregister(key.fileobj)
                                child.stdout.close()
                                break
                            N.require(block == expected.read(len(block)), 'Literal QBE mismatch at byte '+str(size))
                            size += len(block)
                            maximum = max(maximum, len(block))
                            digest.update(block)
                    N.require(expected.read(1) == b'', 'Truncated QBE')
                    code = child.wait(timeout=max(.001, a.seconds-(time.monotonic()-tick)))
                    elapsed = time.monotonic()-tick
                    after = resource.getrusage(resource.RUSAGE_CHILDREN)
                    error.flush()
                    row.update(exitCode=code, nativeSeconds=elapsed, userSeconds=after.ru_utime-before.ru_utime,
                               systemSeconds=after.ru_stime-before.ru_stime, stderr=N.pin(out/(role+'.stderr')),
                               digest=dict(bytes=size, sha256=digest.hexdigest()), maximumBlockBytes=maximum)
                    N.require(code == 0 and row['stderr']['bytes'] == 0, 'Compiler exit or diagnostics')
                    N.require(row['digest'] == {k: oracle[k] for k in ['bytes', 'sha256']}, 'Full output digest mismatch')
                    row.update(complete=True, literalByteExact=True)
                finally:
                    if child is not None and child.poll() is None:
                        os.killpg(child.pid, signal.SIGKILL)
                        child.wait()
                    save()
        for item in inputs:
            N.verify(item)
        report['candidateOverBaseline'] = report['rows'][1]['nativeSeconds']/report['rows'][0]['nativeSeconds']
        report['complete'] = True
    except BaseException as error:
        report['error'] = repr(error)
    finally:
        save()
    print(json.dumps({k: report.get(k) for k in ['complete', 'candidateOverBaseline', 'seconds', 'error']}))
    return 0 if report['complete'] else 1


if __name__ == '__main__':
    raise SystemExit(main())
