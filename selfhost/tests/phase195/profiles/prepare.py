#!/usr/bin/env python3
"""Metadata-only Phase194 product binding and maintained profile preparation."""
import argparse
import importlib.util
import json
import shlex
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
sys.dont_write_bytecode = True
sys.path[:0] = [str(ROOT/'selfhost/tools/profiler'), str(ROOT/'selfhost/tools/build')]
import common as C

spec = importlib.util.spec_from_file_location('profile_plan', ROOT/'selfhost/tools/profiler/plan-runtime.py')
P = importlib.util.module_from_spec(spec)
spec.loader.exec_module(P)
PHASE = ROOT/'selfhost/build/phase194'
OUTPUT = ROOT/'selfhost/build/phase195'
BATCHES = {'priority': ('variation-ray-active-64-2440,editdist', 120),
           'remaining': ('tree-bitonic,test-map-set-ops,lexer', 180)}


def read(path):
    return json.loads(Path(path).read_text())


def prepare(batch):
    cases, ceiling = BATCHES[batch]
    manifest_path = PHASE/'runtime-plan01/manifest.json'
    document = read(manifest_path)
    references_path = PHASE/'references01/manifest.json'
    references = read(references_path)
    acquisition_path = PHASE/'native45-02/report.json'
    acquisition = read(acquisition_path)
    C.require(acquisition['complete'] and not acquisition['changedInputs'], 'Incomplete native acquisition')
    native = read(C.verify(acquisition['programManifest']))
    known = {row['id']: row for row in document['cases']}
    refs = {row['id']: row for row in references['cases']}
    products = {row['id']: row for row in native['cases']}
    rows = {row['id']: row for row in acquisition['rows']}
    for name in cases.split(','):
        case, row = known[name], rows[name]
        C.require(row['complete'] and row['status'] == 'executed-independent-oracle-pass', 'Missing native oracle')
        C.require(case['source'] == row['source'] and case['expectedFile'] == row['expectedFile'], 'Source/oracle mismatch')
        C.require(case['products']['candidate'] == products[name]['products']['candidate']
                  and case['products']['candidate']['artifact'] == row['artifact'], 'Wrong current native product')
        for role in ('c', 'qbe'):
            C.require(case['products'][role] == refs[name]['products'][role], 'Wrong retained reference: '+role)
        for pin in (row['artifact'], row['object'], row['buildReceipt'], row['oracleReceipt']):
            C.verify(pin)
    role = document['roles']['candidate']
    native_role = native['roles']['candidate']
    C.require(native_role == acquisition['roles']['candidate']
              and {k:v for k,v in role.items() if k != 'inputs'} ==
                  {k:v for k,v in native_role.items() if k != 'inputs'}
              and all(pin in role['inputs'] for pin in native_role['inputs'])
              and role['compiler']['file'] == str(PHASE/'native-self01/program')
              and role['stage'] == 'N2', 'Wrong current compiler binding')
    name = 'profile-'+batch
    args = argparse.Namespace(manifest=manifest_path, timing=PHASE/'runtime02/report.json',
        sampler=ROOT/'selfhost/build/phase159/thread-sampler01/sampler.so',
        sampler_receipt=ROOT/'selfhost/build/phase159/thread-sampler01/report.json',
        cases=cases, roles='candidate,c,qbe', seconds_per_run=3.2,
        periods_us='8000,13000', clean_rounds=1, cpu=3,
        out=OUTPUT/(name+'-plan01'), capture_out=OUTPUT/(name+'01'), guard_out=OUTPUT/(name+'01-guard'))
    plan = P.prepare(args)
    command = list(plan['captureCommand'])
    original_ceiling = command[command.index('--seconds')+1]
    command[command.index('--seconds')+1] = str(ceiling)
    close = ['python3', '-B', 'selfhost/tools/build-retention/close.py', '--run', str(args.guard_out),
             '--classification', 'completed', '--keep-root', str(args.capture_out), '--out',
             str(ROOT/'selfhost/build-retention/phase195'/(name+'01-close'))]
    binding = dict(complete=True, targetsRun=False, method=C.pin(__file__),
        plan=C.pin(args.out/'plan.json'), manifest=C.pin(args.out/'manifest.json'),
        authoritativeInputs=[C.pin(references_path), C.pin(acquisition_path), acquisition['programManifest']],
        captureCommand=command, offlineCommands=plan['offlineCommands'], closeOnSuccess=close,
        guardSeconds=ceiling, genericGuardSeconds=int(original_ceiling), diskMiB=128,
        expectedTargetCpuSeconds=plan['estimatedTargetCpuSeconds'],
        executionPolicy='Only outer wall ceiling shortened; original maintained plan and all quality gates preserved. Classify failure as failed, not completed. No nested guards.')
    C.write_json(args.out/'execution.json', binding)
    print(json.dumps(dict(batch=batch, expectedTargetCpuSeconds=plan['estimatedTargetCpuSeconds'],
                          guardSeconds=ceiling, diskMiB=128)))
    for argv in [command, *plan['offlineCommands']]:
        print(shlex.join(argv))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--batch', choices=BATCHES, required=True)
    prepare(parser.parse_args().batch)
