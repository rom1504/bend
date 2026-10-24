#!/usr/bin/env python3
"""Prepare experimental final-codegen timing without claiming native qualification.

Metadata only: authenticate actual N0->N1->N2 builds and both focused19 gates.
Q1 may differ from Q2. Q2=Q3/full45 belong to the separate final binder. The
frozen Phase130 timing runner, cases, tools, clocks and 27-row schedule remain.
"""
import argparse
import copy
import filecmp
import hashlib
import importlib.util
import json
from pathlib import Path
import re
import sys

HERE = Path(__file__).resolve().parent
FROZEN = HERE / 'timing-plan.py'
FROZEN_SHA = 'de623e0e5366a0bc5df27de16a2ea8bed590cbef191a8380326e8cd104e2086a'
if hashlib.sha256(FROZEN.read_bytes()).hexdigest() != FROZEN_SHA:
    raise ValueError('Frozen FAST timing planner changed')
sys.dont_write_bytecode = True
spec = importlib.util.spec_from_file_location('p131_frozen_timing', FROZEN)
T = importlib.util.module_from_spec(spec)
spec.loader.exec_module(T)
ROOT, pin, verify, pins, read, require = T.ROOT, T.pin, T.verify, T.pins, T.read, T.require
FINAL_SHA = '1bc5930edcf80cda6c3572645df3c846fa631a83c2b936f20c83b05e0a6728f9'
FINAL_METHOD = HERE / 'qualify-final.py'
FINAL_METHOD_SHA = '124aba0fe7c8cb0599a01088b97b3fd38a50441a6730a6dd4c9dece7be87f236'


def codegen_contract(admission, method):
    require(admission.get('kind') == 'phase131-native-acquisition-admission'
            and admission.get('complete') and admission.get('sourceChecked'), 'Checked final admission required')
    require(admission.get('changeKind') == 'declared-codegen-change'
            and admission.get('requiredReproduction') == 'N0->N1->N2->N3;Q2=Q3', 'Final codegen reproduction policy differs')
    require(admission.get('source', {}).get('sha256') == FINAL_SHA, 'Wrong final compiler source')
    require(method.get('sha256') == FINAL_METHOD_SHA
            and admission.get('qualificationMethod') == method, 'Wrong final qualification method')


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--comparison', choices=['parent-n2', 'n1-n2'], default='parent-n2')
    for name in ['admission', 'acquisition', 'n1-build', 'n1-focused', 'self-emission', 'n2-build', 'n2-focused', 'out']:
        ap.add_argument('--' + name, type=Path, required=True)
    ap.add_argument('--tag', required=True)
    a = ap.parse_args()
    out = a.out.resolve()
    require(not out.exists() and out.is_relative_to(ROOT / 'selfhost/build/phase131'), 'Fresh Phase131 manifest required')
    require(re.fullmatch(r'p131-[a-z0-9_-]+', a.tag), 'Use a p131- result tag')
    require(pin(T.BASE)['sha256'] == T.BASE_SHA and pin(T.RUNNER)['sha256'] == T.RUNNER_SHA, 'Frozen timing policy changed')
    base, ad = read(T.BASE), read(a.admission)
    codegen_contract(ad, pin(FINAL_METHOD))
    parent_file = ROOT / 'implementation/phase130/candidate.json'
    parent = read(parent_file)
    require(parent['complete'] and parent['nativeQualified'], 'Qualified Phase130 parent required')
    require(ad['runtime'] == parent['runtime'] == base['runtime']
            and ad['permittedProducer'] == parent['n1']
            and ad['producerSelection'] == pin(parent_file), 'Admission/producer/runtime mismatch')
    for row in [*pins(ad), *pins(parent)]:
        verify(row)
    carrier = parent['preferredCarrierReceipt']
    require(base['roles']['phase111']['carrierReceipt'] == carrier == base['roles']['phase112']['carrierReceipt'], 'Both native roles must use identical compact Base')
    acquisition = T.emission(a.acquisition, ad, parent['n1'], carrier)
    n1 = T.Q.build(read(a.n1_build), acquisition['product'], ad['runtime'], base['tools'])
    T.focused(a.n1_focused, n1, ad['runtime'])
    own = T.emission(a.self_emission, ad, n1, carrier)
    n2 = T.Q.build(read(a.n2_build), own['product'], ad['runtime'], base['tools'])
    T.focused(a.n2_focused, n2, ad['runtime'])
    # This is an observation, not an admission condition for new codegen policy.
    first_equal = (acquisition['product']['bytes'] == own['product']['bytes'] and
                   filecmp.cmp(acquisition['product']['file'], own['product']['file'], shallow=False))
    left = dict(binary=parent['n1'], source=parent['source'], generation='Qualified Phase130 N1; compact Base', nativeQualified=True, carrierReceipt=carrier)
    if a.comparison == 'n1-n2':
        left = dict(binary=n1, source=ad['source'], generation='Experimental final Phase131 N1; focused19 passed; compact Base', nativeQualified=False, carrierReceipt=carrier)
    right = dict(binary=n2, source=ad['source'], generation='Experimental final Phase131 N2; focused19 passed; compact Base', nativeQualified=False, carrierReceipt=carrier)
    evidence = [a.admission, a.acquisition, a.n1_build, a.n1_focused, a.self_emission, a.n2_build, a.n2_focused]
    manifest = copy.deepcopy(base)
    manifest.update(preparedOnly=True, targetsRun=False, researchOnly=True, nativeQualified=False, unqualified=True)
    manifest['roles'].update(phase111=left, phase112=right)
    manifest['inputs'] = [pin(__file__), pin(FROZEN), pin(T.Q.__file__), pin(FINAL_METHOD), pin(T.BASE), pin(T.RUNNER), pin(parent_file), *map(pin, evidence)]
    manifest['lineage'] = dict(comparison=a.comparison,
        roleKeys=dict(phase111=left['generation'], phase112=right['generation'], upstream='Unchanged pinned TypeScript/Bun C compiler'),
        qualificationScope='Actual admitted N0->N1->N2 lineage and focused19 on N1/N2 only. Final Q2=Q3, N3 focused19/full45 and installed selection remain separate.',
        sameCompilerSource=a.comparison == 'n1-n2', compactCarrierBothNative=True,
        requiredReproduction=ad['requiredReproduction'], selfReproductionEstablished=False,
        firstQbe=acquisition['product'], secondQbe=own['product'], firstSecondQbeByteEqual=first_equal,
        unchanged='Phase130 cases, independent full outputs, upstream, tools, machine flags, limits, wait4 clocks and rotated three-round schedule.',
        costScope='Request and machine-build child sums separate. Native prepared Base/cached runtime; upstream source Base/full C-Clang runtime build. Program execution is correctness-only.',
        installed=False)
    manifest['derivation'] = dict(kind='phase131-final-codegen-experimental-native-request-comparison', original=pin(T.BASE), runner=pin(T.RUNNER), targetsRun=False)
    for row in pins(manifest):
        verify(row)
    target = ROOT / 'selfhost/build/phase112' / a.tag
    jobs_path = out.with_name(out.stem + '-jobs.json')
    require(not target.exists() and not jobs_path.exists(), 'Fresh target/job paths required')
    command = [sys.executable, '-B', str(T.RUNNER), '--manifest', str(out), '--out', str(target), '--rounds', '3', '--modes', 'cache']
    out.parent.mkdir(parents=True, exist_ok=True)
    with out.open('x') as f:
        json.dump(manifest, f, indent=2); f.write('\n')
    jobs = dict(kind='phase131-final-codegen-native-timing-jobs', complete=True, targetsRun=False,
                inputs=[pin(out), pin(__file__), pin(FROZEN), pin(T.RUNNER)],
                jobs=[dict(name='phase131-final-' + a.comparison + '-upstream-three-source', seconds=240, command=command)])
    with jobs_path.open('x') as f:
        json.dump(jobs, f, indent=2); f.write('\n')
    print(json.dumps(dict(complete=True, targetsRun=False, manifest=pin(out), jobs=pin(jobs_path), command=command)))


if __name__ == '__main__':
    main()
