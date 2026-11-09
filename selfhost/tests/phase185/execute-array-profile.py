#!/usr/bin/env python3
"""Prepare and execute the fixed local-fold x86 screen in one fresh guarded root."""
import argparse
import importlib.util
import json
from pathlib import Path
import sys
import time

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent


def module(name, filename):
    spec = importlib.util.spec_from_file_location(name, HERE / filename)
    result = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(result)
    return result


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--seconds', type=float, default=150)
    p.add_argument('--cpu', type=int, default=3)
    p.add_argument('--guarded', action='store_true')
    a = p.parse_args()
    started = time.monotonic()
    P = module('array_profile_plan', 'profile-plan.py')
    P.B.require(a.guarded and P.L.os.sched_getaffinity(0) == {a.cpu}, 'One external guarded CPU lane required')
    P.B.require(0 < a.seconds <= 180, 'Whole diagnostic deadline must be at most180 seconds')
    out = P.L.fresh_output(a.out, P.ROOT)
    plan = out / 'plan'
    P.prepare(argparse.Namespace(
        manifest=P.ROOT / 'selfhost/build/phase185/array-programs01/programs.manifest.json',
        role='array-x86', case=[('local-fold', '16000')], instrument=False, modes='sample',
        sampler=P.ROOT / 'selfhost/build/phase183/profile-controls01/sampler/sampler.so',
        runtime_report=None, periods_us='8000,13000', out=plan))
    jobs_file = plan / 'jobs.json'
    jobs = json.loads(jobs_file.read_text())
    for job in jobs['jobs']:
        command = job['command']
        if job['name'].endswith('-owners') and '--build-receipt' in command:
            index = command.index('--build-receipt')
            receipt = command[index + 1]
            built = json.loads(Path(receipt).read_text())
            if built.get('request') is None:
                del command[index:index + 2]
                jobs['ownerReceiptPolicy'] = dict(omitted=receipt,
                    reason='Machine-only native --ir receipt has no compiler request; use conditional lexical owner mapping and linked ELF checks.')
    P.B.save(jobs_file, jobs)
    P.B.save(out / 'preparation.json', dict(targetsRun=False, method=P.B.pin(__file__),
        jobs=P.B.pin(jobs_file), seconds=time.monotonic() - started), fresh=True)
    remaining = a.seconds - (time.monotonic() - started)
    P.B.require(remaining > 0, 'Preparation exhausted whole profile deadline')
    dispatcher = module('array_profile_dispatcher', 'execute-profile-jobs.py')
    sys.argv = [str(HERE / 'execute-profile-jobs.py'), '--jobs', str(jobs_file),
        '--out', str(out / 'controller'), '--seconds', str(remaining), '--cpu', str(a.cpu), '--guarded']
    return dispatcher.main()


if __name__ == '__main__':
    sys.exit(main())
