#!/usr/bin/env python3
"""Create and dispatch one physical-only profile plan inside a fresh outer guard.

Phase185's planner and dispatcher remain frozen. No compiler or diagnostic
runtime build is requested; this adapter selects retained products explicitly.
"""
import argparse
import importlib.util
import json
from pathlib import Path
import sys
import time

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
PREVIOUS = HERE.parent / 'phase185'


def module(name, filename):
    spec = importlib.util.spec_from_file_location(name, PREVIOUS / filename)
    value = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(value)
    return value


P = module('p186_profile_plan', 'profile-plan.py')
D = module('p186_profile_dispatcher', 'execute-profile-jobs.py')


def separate_emission(case, product):
    """Find an authenticated receipt binding these exact emitted bytes."""
    matches = {}
    for item in product.get('inputs', []):
        if Path(item['file']).suffix != '.json':
            continue
        P.B.verify(item)
        receipt = P.B.read(item['file'])
        if not (receipt.get('complete') and receipt.get('target') == 'x86'
                and not receipt.get('changedInputs') and not receipt.get('error')):
            continue
        if receipt.get('kind') == 'bend-build-request':
            bound = (receipt.get('product') == product['generatedSource']
                     and receipt.get('source') == case['source'])
        elif receipt.get('kind') == 'phase185-checked-native-emission':
            rows = [r for r in receipt.get('rows', []) if r.get('id') == case['id']]
            bound = (len(rows) == 1 and rows[0].get('complete') and rows[0].get('verified')
                     and rows[0].get('product') == product['generatedSource']
                     and rows[0].get('source') == case['source'])
        else:
            bound = False
        if bound:
            matches[item['file']] = item
    P.B.require(len(matches) == 1, 'One authenticated separate emission receipt required')
    return next(iter(matches.values()))


def prepare(a, out):
    document = P.L.load(a.manifest)
    P.B.require(a.role in document['roles'], 'Unknown manifest role: ' + a.role)
    target = document['roles'][a.role]['target']
    sampler = P.ROOT / ('selfhost/build/phase159/thread-sampler01/sampler.so'
                       if target == 'c' else 'selfhost/build/phase183/profile-controls01/sampler/sampler.so')
    P.prepare(argparse.Namespace(manifest=a.manifest, role=a.role, case=a.case,
        instrument=False, modes='clean,sample', sampler=sampler, runtime_report=None,
        periods_us='8000,13000', out=out / 'plan'))
    jobs_file = out / 'plan/jobs.json'
    jobs = P.B.read(jobs_file)
    omissions = []
    for job in jobs['jobs']:
        command = job['command']
        if job['name'].endswith('-owners') and '--build-receipt' in command:
            index = command.index('--build-receipt')
            receipt = Path(command[index + 1])
            built = P.B.read(receipt)
            if built.get('request') is None:
                case = next(c for c in document['cases'] if job['name'] == c['id'] + '-owners')
                product = case['products'][a.role]
                receipt_pins = [p for p in product.get('inputs', [])
                                if p['file'] == str(receipt.resolve())]
                P.B.require(len(receipt_pins) == 1, 'Authenticated machine receipt required')
                P.B.verify(receipt_pins[0])
                source = product['generatedSource']
                P.B.require(command[command.index('--assembly') + 1] == source['file']
                            and built.get('sourceAssembly') == source
                            and built.get('binary') == product['artifact'],
                            'Separate machine receipt does not bind exact source and binary')
                for item in (source, product['artifact']):
                    P.B.verify(item)
                emission = separate_emission(case, product)
                omissions.append(dict(buildReceipt=P.B.pin(receipt),
                    separateEmissionReceipt=emission,
                    generatedSource=source, binary=product['artifact'],
                    reason='Acquisition retains separate emission and machine receipts; the owner tool requires a combined source-emitting build. Keep conditional lexical grouping plus exact ELF/FID authentication, without a fabricated combined receipt.'))
                del command[index:index + 2]
    jobs['ownerReceiptOmissions'] = omissions
    jobs['selectedRole'] = a.role
    jobs['selectedTarget'] = target
    P.B.save(jobs_file, jobs)
    return jobs_file


def execute(a):
    started = time.monotonic()
    P.B.require(a.guarded and a.cpu == 3 and P.L.os.sched_getaffinity(0) == {3},
                'One external guarded CPU3 lane required')
    P.B.require(0 < a.seconds <= 80, 'Inner deadline must be at most80 seconds; use an outer90-second guard')
    P.L.clean_environment()
    P.B.require('BENDRTS' not in P.L.os.environ, 'Ambient BENDRTS must be unset')
    out = P.L.fresh_output(a.out, P.ROOT)
    jobs_file = prepare(a, out)
    P.B.save(out / 'preparation.json', dict(targetsRun=False, method=P.B.pin(__file__),
        manifest=P.B.pin(a.manifest), jobs=P.B.pin(jobs_file),
        seconds=time.monotonic() - started, physicalOnly=True,
        scope='One clean plus two sample captures at8ms/13ms; exact catalog values, fixed explicit repetitions, original binaries. No clean performance-ratio claim from this diagnostic screen.'), fresh=True)
    remaining = a.seconds - (time.monotonic() - started)
    P.B.require(remaining > 0, 'Preparation exhausted whole diagnostic deadline')
    previous = sys.argv
    try:
        sys.argv = [str(PREVIOUS / 'execute-profile-jobs.py'), '--jobs', str(jobs_file),
                    '--out', str(out / 'controller'), '--seconds', str(remaining), '--cpu', '3', '--guarded']
        return D.main()
    finally:
        sys.argv = previous


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--manifest', type=Path,
        default=P.ROOT / 'selfhost/build/phase186/reference45-01/manifest.json')
    parser.add_argument('--role', required=True, help='Exact authenticated role name in --manifest')
    parser.add_argument('--case', nargs=2, action='append', required=True, metavar=('ID', 'REPETITIONS'))
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--seconds', type=float, default=80)
    parser.add_argument('--cpu', type=int, default=3)
    parser.add_argument('--guarded', action='store_true')
    return execute(parser.parse_args())


if __name__ == '__main__':
    sys.exit(main())
