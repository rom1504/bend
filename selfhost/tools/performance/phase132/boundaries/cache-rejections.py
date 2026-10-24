#!/usr/bin/env python3
"""Exercise frozen object-cache admission with real copied corrupt inputs; no children."""
import argparse
import contextlib
import copy
import importlib.util
import io
import json
from pathlib import Path
import shutil
from types import SimpleNamespace

HERE = Path(__file__).resolve().parent
SPEC = importlib.util.spec_from_file_location('frozen_object_cache', HERE.parent/'incremental/objects.py')
M = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(M)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--build-report', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    original = M.read(a.build_report)
    M.require(original['complete'], 'Need completed original build')
    plan = M.read(M.verify(original['plan']))
    M.require(plan['context']['method'] == M.pin(M.__file__), 'Must test exact frozen builder')
    first = plan['units'][0]
    row = original['units'][0]
    M.require(row['key'] == first['key'], 'First cache unit identity differs')
    receipt = M.read(M.verify(row['receipt']))
    M.verify(receipt['object'])
    out = M.fresh(a.out)
    result = dict(complete=False, targetsRun=False, method=M.pin(__file__),
                  builder=M.pin(M.__file__), originalBuild=M.pin(a.build_report),
                  originalPlan=original['plan'], originalObject=row['object'],
                  controls=[], scope='Calls the actual frozen build/admission function. '
                  'A subprocess.run tripwire forbids every compiler/assembler/linker launch. '
                  'Copied corrupt artifacts test integrity/key admission, not completeness of semantic dependencies.')

    cases = [
        ('corrupt-object', 'Changed input:'),
        ('stale-receipt-key', 'Cache admission differs'),
        ('corrupt-current-unit', 'Changed input:'),
        ('changed-binding-old-digest', 'Cache key differs'),
        ('changed-runtime-old-pin', 'Changed input:'),
    ]
    for label, expected in cases:
        case = out/label
        case.mkdir()
        current = copy.deepcopy(plan)
        cache = case/'cache'
        entry = cache/first['key']
        entry.mkdir(parents=True)
        cached = copy.deepcopy(receipt)
        obj = entry/'unit.o'
        shutil.copyfile(receipt['object']['file'], obj)
        cached['object']['file'] = str(obj)
        if label == 'corrupt-object':
            with obj.open('r+b') as stream:
                stream.seek(-1, 2)
                byte = stream.read(1)
                stream.seek(-1, 2)
                stream.write(bytes([byte[0] ^ 1]))
        elif label == 'stale-receipt-key':
            cached['key'] = '0'*64
        elif label == 'corrupt-current-unit':
            ir = case/'unit.ssa'
            shutil.copyfile(first['ir']['file'], ir)
            with ir.open('ab') as stream:
                stream.write(b'\n# deliberate stale-pin mutation\n')
            current['units'][0]['ir']['file'] = str(ir)
        elif label == 'changed-binding-old-digest':
            M.require(current['units'][0]['bindings'], 'Need actual cross-unit binding')
            binding = current['units'][0]['bindings'][0]
            binding['symbol'] = binding['symbol'] + '_deliberately_changed'
        elif label == 'changed-runtime-old-pin':
            rt = case/'runtime.o'
            shutil.copyfile(current['context']['runtime']['file'], rt)
            with rt.open('ab') as stream:
                stream.write(b'\0')
            current['context']['runtime']['file'] = str(rt)
        M.save(entry/'receipt.json', cached)
        path = case/'plan.json'
        M.save(path, current)
        attempted = []
        def forbid(*args, **kwargs):
            attempted.append(repr(args[0] if args else kwargs))
            raise AssertionError('Target launch attempted by admission control')
        saved = M.subprocess.run
        M.subprocess.run = forbid
        error = None
        try:
            with contextlib.redirect_stdout(io.StringIO()):
                M.build(SimpleNamespace(plan=path, out=case/'rejected-build',
                                        cache=cache, cold=False, seconds=1))
        except ValueError as exc:
            error = str(exc)
        finally:
            M.subprocess.run = saved
        M.require(error is not None and error.startswith(expected) and not attempted,
                  'Actual admission did not reject expected mutation before target launch: ' + label)
        result['controls'].append(dict(name=label, passed=True, rejection=error,
            subprocessLaunchAttempts=len(attempted), plan=M.pin(path),
            mutatedReceipt=M.pin(entry/'receipt.json'), mutatedObject=M.pin(obj),
            admissionReport=M.pin(case/'rejected-build/report.json')
                if (case/'rejected-build/report.json').exists() else None))
        M.save(out/'report.json', result)
    M.verify(original['plan'])
    M.verify(row['receipt'])
    M.verify(row['object'])
    result.update(complete=True, passed=len(cases), subprocessLaunchAttempts=0,
                  originalPlanReceiptObjectUnchanged=True)
    M.save(out/'report.json', result)
    print(json.dumps(dict(complete=True, passed=len(cases), targetsRun=False, report=M.pin(out/'report.json'))))


if __name__ == '__main__':
    main()
