#!/usr/bin/env python3
"""Capture the same Bend compiler through upstream C; outer guard owns CPU/RSS.

No compiler logic, machine build, semantic qualification or promotion occurs here.
"""
import argparse
import hashlib
import importlib.util
import json
import math
import os
from pathlib import Path
import signal
import subprocess
import sys
import threading
import time

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[4]
METHOD = ROOT/'selfhost/tools/performance/phase125/native/native-emit.py'
spec = importlib.util.spec_from_file_location('p125_native_emit', METHOD)
P125 = importlib.util.module_from_spec(spec); spec.loader.exec_module(P125)
pin, verify, same_bytes = P125.pin, P125.verify, P125.same_bytes
OLD = ROOT/'selfhost/tools/performance/phase88/base/carrier01/receipt.json'
OLD_SHA = 'fdee4f8b2e7304a5c6df67f72d2e039c79d07542235cd3764c2242e3c65339c9'


def require(condition, message):
    if not condition: raise ValueError(message)


def carrier_inputs(path):
    old_pin = pin(OLD)
    require(old_pin['sha256'] == OLD_SHA, 'Original carrier receipt changed')
    old = json.loads(OLD.read_text()); selected_pin = pin(path)
    selected = json.loads(Path(path).read_text())
    require(old['complete'] and old['kind'] == 'phase88-private-base-carrier', 'Invalid original receipt')
    inputs = [old_pin, selected_pin, old['carrier'], *old['inputPins'].values()]
    binding, header, pins = old['stampBinding'], old['cacheHeader'], old['inputPins']
    require(all(binding[k] == pins[k]['sha256'] for k in ('cache','api','base')), 'Original producer/Base identity mismatch')
    require(binding['path'] == pins['base']['file'] == header['sourcePath'] and
            header['compilerSha256'] == pins['api']['sha256'] and header['baseSha256'] == pins['base']['sha256'], 'Original source binding mismatch')
    stamp = 'p88-private-base-text-1:' + hashlib.sha256(json.dumps(binding, separators=(',',':'), ensure_ascii=False).encode()).hexdigest()
    require(old['stamp'] == stamp, 'Original routing stamp mismatch')
    if selected['kind'] == 'phase88-private-base-carrier':
        require(selected_pin['sha256'] == old_pin['sha256'], 'Only authenticated original Phase88 receipt admitted')
    else:
        require(selected['kind'] == 'phase130-private-word-pair-carrier' and selected['complete'] and
                selected['inverseByteIdentity'] is True and selected['format'] == 'p130-word-pair-v1', 'Complete compact inverse receipt required')
        require(selected['parentReceipt'] == old_pin and selected['parentCarrier'] == old['carrier'] and
                selected['originalStamp'] == stamp and selected['stamp'] == 'p130-word-pair-v1:' + stamp and
                selected['sourceIdentity'] == binding and selected['sourceBegin'] == header['sourceBegin'] and
                selected['sourceEnd'] == header['sourceEnd'], 'Compact carrier lineage mismatch')
        required = [old_pin, old['carrier'], *pins.values(), pin(ROOT/'selfhost/tools/performance/phase130/base/carrier.mjs')]
        require(all(row in selected['inputs'] for row in required), 'Compact receipt omits authenticated inputs')
        inputs.extend([selected['carrier'], *selected['inputs']])
    for row in inputs: verify(row)
    require(0 < selected['carrier']['bytes'] <= 16777216, 'Carrier exceeds bounded reader')
    return selected, pins['base'], inputs


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    for name in ('image','source','carrier-receipt','out'): ap.add_argument('--'+name, type=Path, required=True)
    ap.add_argument('--compiler-source', type=Path, required=True)
    ap.add_argument('--seconds', type=float, default=600)
    ap.add_argument('--expected-qbe', type=Path)
    a = ap.parse_args(); out = a.out.resolve()
    require(not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase144'), 'Fresh Phase144 output required')
    require(math.isfinite(a.seconds) and a.seconds > 0, 'Finite positive timeout required')
    require(not any(k in os.environ for k in ('LD_PRELOAD','BEND_SAMPLE_OUT','BEND_SAMPLE_CONTEXT_OUT','BEND_PROFILE_EVENTS_OUT','BEND_PROFILE_COUNTERS')), 'Ambient diagnostic instrumentation must be unset')
    image, source = P125.member(a.image, 'program'), a.source.resolve()
    require(os.access(image, os.X_OK), 'Executable compiler image required')
    selected, base, inputs = carrier_inputs(a.carrier_receipt.resolve())
    source_pin, image_pin = pin(source), pin(image)
    require(source_pin['bytes'] <= 16777216 and base['bytes'] <= 16777216, 'Source/Base exceeds bounded reader')
    candidate_path = ROOT/'implementation/phase128/candidate.json'
    candidate = json.loads(candidate_path.read_text())
    runtime = candidate['runtime']; runtime_report = json.loads(verify(candidate['runtimeReport']).read_text())
    require(candidate['complete'] and runtime_report['complete'] and runtime_report['object'] == runtime, 'Selected Phase128 runtime receipt mismatch')
    inputs += [pin(a.compiler_source), pin(__file__), pin(METHOD), pin(sys.executable), pin(candidate_path), runtime, candidate['runtimeReport'], source_pin, image_pin]
    image_receipt = image.parent/'report.json'
    if image_receipt.is_file():
        receipt = json.loads(image_receipt.read_text()); inputs.append(pin(image_receipt))
        if 'binary' in receipt:
            require(receipt.get('complete') and receipt['binary'] == image_pin, 'Compiler build receipt mismatch')
    require(image_receipt.is_file(), 'C acquisition receipt required')
    require(receipt['kind'] == 'phase144-upstream-c-build' and receipt['source'] == pin(a.compiler_source), 'Same-source upstream-C acquisition required')
    if a.expected_qbe: inputs.append(pin(a.expected_qbe))
    for row in inputs: verify(row)
    command = [str(image),'--threads','1','--gpu','off','--',str(source),base['file'],'cache',selected['carrier']['file'],selected['stamp']]
    out.mkdir(parents=True); (out/'method.py').write_bytes(Path(__file__).read_bytes())
    (out/'carrier-receipt.json').write_bytes(a.carrier_receipt.read_bytes())
    report = dict(kind='phase144-upstream-c-source-qbe-request', complete=False, experimental=True, mode='cache',
        inputs=inputs, image=image_pin, compilerSource=pin(a.compiler_source), source=source_pin, base=base, carrier=selected['carrier'], stamp=selected['stamp'],
        runtime=runtime, runtimeRole='Selected future build context only; no claim this object is linked into supplied image.',
        command=command, limitSeconds=a.seconds, inheritedAffinity=sorted(os.sched_getaffinity(0)),
        expectedQbe=pin(a.expected_qbe) if a.expected_qbe else None,
        scope='Experimental request only; no native consumer qualification, machine build or installed selection change.',
        byteContract='Raw binary stdout including native IO.print LF bytes; no normalization.',
        timingScope='Whole child request including I/O; outer guard owns process-tree CPU/RSS limits.')
    start = time.monotonic(); child = None
    def save():
        report['totalSeconds'] = time.monotonic()-start
        tmp = out/'report.json.tmp'; tmp.write_text(json.dumps(report, indent=2)+'\n'); tmp.replace(out/'report.json')
    save()
    try:
        with (out/'program.ssa').open('xb') as so, (out/'emit.stderr').open('xb') as se:
            before = time.monotonic()
            child = subprocess.Popen(command, cwd=ROOT, stdout=so, stderr=se, start_new_session=True)
            finished, expired = threading.Event(), threading.Event()
            def deadline():
                if not finished.is_set():
                    expired.set()
                    try: os.killpg(child.pid, signal.SIGKILL)
                    except ProcessLookupError: pass
            watchdog = threading.Timer(max(0, a.seconds-(time.monotonic()-before)), deadline)
            watchdog.daemon = True
            try:
                watchdog.start()
                _, status, usage = os.wait4(child.pid, 0)
                report['nativeSeconds'] = time.monotonic()-before
                child.returncode = os.waitstatus_to_exitcode(status)
                finished.set()
                report.update(userSeconds=usage.ru_utime, systemSeconds=usage.ru_stime,
                              cpuSeconds=usage.ru_utime+usage.ru_stime, peakRssKiB=usage.ru_maxrss)
                if expired.is_set(): raise subprocess.TimeoutExpired(command, a.seconds)
            except BaseException:
                if child.returncode is None:
                    try: os.killpg(child.pid, signal.SIGKILL)
                    except ProcessLookupError: pass
                child.wait(); raise
            finally:
                finished.set(); watchdog.cancel()
                if watchdog.ident is not None: watchdog.join()
                report.setdefault('nativeSeconds', time.monotonic()-before)
        require(child.returncode == 0, 'Native request exited '+str(child.returncode))
        report['product'], report['stderr'] = pin(out/'program.ssa'), pin(out/'emit.stderr')
        require(report['product']['bytes'] and not report['stderr']['bytes'], 'Nonempty QBE and empty stderr required')
        if a.expected_qbe:
            report['byteExact'] = same_bytes(out/'program.ssa', a.expected_qbe)
            require(report['byteExact'], 'Complete QBE bytes differ from reference')
        report['complete'] = True
    except BaseException as error:
        report['error'] = repr(error); report['timedOut'] = isinstance(error, subprocess.TimeoutExpired)
    finally:
        report['exitCode'] = child.returncode if child else None
        report['changedInputs'] = []
        for row in inputs:
            try: verify(row)
            except (OSError, ValueError): report['changedInputs'].append(row['file'])
        if report['changedInputs']: report['complete'] = False
        for key, name in [('product','program.ssa'),('stderr','emit.stderr')]:
            if (out/name).is_file(): report[key] = pin(out/name)
        save()
    print(json.dumps({k:report.get(k) for k in ('complete','nativeSeconds','product','error','changedInputs')}))
    return 0 if report['complete'] else 1


if __name__ == '__main__': sys.exit(main())
