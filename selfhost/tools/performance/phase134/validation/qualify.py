#!/usr/bin/env python3
"""Bind actual Phase134 native qualification evidence; never run targets.

This narrow contract covers the reviewed stream-source02 composition. It reuses
the frozen Phase131 native-request and ordinary/focused-output authenticators.
Changing the audited source requires an explicit new source-contract review.
"""
import argparse
import filecmp
import hashlib
import importlib.util
from pathlib import Path
import sys

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('p134_validation', HERE / 'plan.py')
P = importlib.util.module_from_spec(spec); spec.loader.exec_module(P)
V = P.load(P.TOOLS / 'phase131/native/qualify.py', 'p134_frozen_qualification')
C = V.C
SOURCE_SHA = 'a7c3522a563bb4eb58d215b0f614ba4df06ef57bcd98a096c5d56e9e8cafd9d4'
SUCCESS = P.TOOLS / 'phase134/emission/success-manifest.json'
METHODS = {
    Path(V.__file__): '28a5d00beb5744d8d41c192f5efca3926a28a0b78952124f7123b43b45626e14',
    Path(V.Q.__file__): '7e3bf643c2941874709cf11aa7890929ef119eeb4fa0a03d8427e8b119406726',
    Path(C.__file__): '33a4a40ab35ef705cbe99cff20b4b6a2c9792eee4ad8c9597a006d22ae22defa',
    P.TOOLS / 'phase134/emission/finite.mjs': 'caad51e8048526a8679912871ac05fc43796c52fd4c68719638b9c272f2b5208',
    P.TOOLS / 'phase134/emission/plan-v02.bend': '9836b49b83959772e8fb73afe57131ae76749c6a002ceb77ff3d5db9c853ae87',
    P.TOOLS / 'phase134/emission/success.bend': '2caa7cd4802de2cd40cf0d5e077e3141b8dba189ac8d3c382e39a32f1bda180a',
    P.TOOLS / 'phase134/native-io.bend': '03c48dbd9a7106814cfb302dff8a2c9d1b6684032785c57e44889cbf7244b163',
    P.TOOLS / 'phase134/emission/controls-v02.bend': '3b514cbec92dd0864dd7c65ffe54f2f49a74484a49bb87ef2b33e7fc752bd08c',
}
CONTROL_NAMES = [
    'stream-raw-chunk-identity', 'stream-static-empty-chunk-identity',
    'stream-direct-empty-chunk-identity', 'stream-direct-chunk-identity',
    'stream-admitted-array-chunk-identity', 'stream-admitted-boxed-chunk-identity',
    'stream-admitted-no-private-chunk-identity', 'stream-data-257-and-empty-boundaries',
    'stream-legacy-prefix-one-chunk', 'stream-error-preserved',
    'stream-static-nonempty-chunk-identity', 'stream-livebank-refusal-selection',
    'stream-data-slice-limit', 'stream-seal-error-preserved', 'stream-zero-public',
]


def sha(text): return hashlib.sha256(text.encode()).hexdigest()


def source_contract(manifest_path, api_path, finite_path, parent):
    sm, api, finite = map(V.read, [manifest_path, api_path, finite_path])
    P.require(sm.get('kind') == 'phase134-exact-source-overlay' and sm.get('complete') and sm['parent'] == parent['source'] and sm['parentSelection'] == P.pin(P.SELECTION), 'Selected parent composition required')
    source = sm['source']; P.require(source['sha256'] == SOURCE_SHA, 'Source is outside this reviewed qualification contract')
    P.require(api.get('kind') == 'phase111-checked-api' and api.get('complete') and api.get('checked') and api.get('status') == 0 and source in api['inputs'], 'Independent source checking failed or used another source')
    P.require(api['command'][2:4] == [source['file'], api['api']['file']] and api['command'][4:] == api['exports'], 'Checked source/API argv differs')
    required = {'p134ec_controls', 'p134e_collect', 'p134e_begin', 'p134e_next', 'p134e_compile_source', 'p111_compile_source', 'p111_emit_admitted', 'p88_cache_prepare', 'p86_prepare', 'p86_plan', 'p111_runtime_admission'}
    P.require(required <= set(api['exports']), 'Checked API omits required request/control exports')
    old_api = V.bound(parent['checkedApi'])
    P.require(api['command'][:2] == old_api['command'][:2], 'Independent source checker command changed')
    for item in old_api['inputs']:
        if item != parent['source']:
            P.require(any((x['bytes'], x['sha256']) == (item['bytes'], item['sha256']) for x in api['inputs']), 'Independent checker/method pin changed')
    before_text = P.verify(parent['source']).read_text(); after_text = P.verify(source).read_text()
    before, after = C.blocks(before_text), C.blocks(after_text)
    snapshots = sorted(Path(source['file']).parent.glob('module*.bend'), key=lambda x: int(x.stem[6:]))
    P.require(len(snapshots) == 4, 'Exact four-module source composition required')
    for path in snapshots:
        item = P.pin(path); V.retain(item)
        P.require(any((x['bytes'], x['sha256']) == (item['bytes'], item['sha256']) for x in sm['inputs']), 'Unbound module snapshot')
    adapters = {'p111_emit_admitted', 'p111_native_request'}
    P.require(set(sm['entryAdapters']) == adapters, 'Entry adapter inventory changed')
    old_gates = C.ENTRY_GATES.copy()
    try:
        C.ENTRY_GATES -= adapters
        replay, added, protected = C.compose(before_text, [x.read_text() for x in snapshots], set(sm['overrides']), set())
    finally: C.ENTRY_GATES = old_gates
    P.require(replay == after_text and added == sm['added'] and protected == sm['protectedDeclarations'], 'Full source replay or protected inventory differs')
    proofs = parent['proofScope']['exactDeclarations']
    P.require(sm['unchangedProofDeclarations'] == proofs and all(before[n] == after[n] for n in protected + proofs), 'Original verifier or proof declaration bytes changed')
    success = V.read(SUCCESS)
    P.require(success['source_sha256'] == parent['source']['sha256'] and len(success['overrides']) == 9, 'Nine success substitutions required')
    for item in success['overrides']:
        name = item['name']; expected = before[name]
        P.require(sha(expected) == item['original_sha256'], 'Success substitution parent differs: ' + name)
        count = 0
        for old, new in success['replacements'].items():
            count += expected.count(old); expected = expected.replace(old, new)
        P.require(count > 0 and C.norm(expected) == C.norm(after[name]), 'Changed admission beyond successful result: ' + name)
    # The IO routing changes only this call name; source/Base/cache/diagnostic flow stays.
    P.require(before['p111_native_request'].count('p111_compile_source(') == 2 and
              C.norm(after['p111_native_request']) == C.norm(before['p111_native_request'].replace('p111_compile_source(', 'p134e_compile_source(')), 'Native request routing changed beyond the selected call')
    expected = before['p111_emit_admitted'].replace('p128raw_emit_admitted(request,error)', 'p134e_collect(p128raw_emit_admitted(request,error))')
    P.require(C.norm(after['p111_emit_admitted']) == C.norm(expected), 'Pure API no longer collects the fresh admitted pipeline')
    for old, new, substitutions in [
        ('p111_compile_source', 'p134e_compile_source', {'p111_compile_source(': 'p134e_compile_source(', 'p111_compile_prepared(': 'p134e_prepared('}),
        ('p111_compile_prepared', 'p134e_prepared', {'p111_compile_prepared(': 'p134e_prepared(', 'p111_emit_plan(': 'p134e_plan('}),
        ('p111_emit_plan', 'p134e_plan', {'p111_emit_plan(': 'p134e_plan(', 'p111_emit_admitted(': 'p128raw_emit_admitted('}),
    ]:
        body = before[old]
        for left, right in substitutions.items(): body = body.replace(left, right)
        if old == 'p111_compile_source':
            body = body.replace('\n  +carrier: String,', '\n    +carrier: String,')
        P.require(C.norm(body) == C.norm(after[new]), 'Fresh streaming path bypasses request checks: ' + new)
    changed = sorted(n for n in before if C.norm(before[n]) != C.norm(after[n]))
    P.require(changed == sm['changedDeclarations'] == sorted(sm['overrides']), 'Unexpected changed original declaration')
    P.require(finite.get('complete') and finite['source'] == source and finite['sourceManifest'] == P.pin(manifest_path) and P.pin(api_path) in finite['inputs'] and api['api'] in finite['inputs'], 'Finite source/API binding differs')
    P.require(finite['groups'] == [dict(name='p134ec_controls', expectedCount=15, rows=['PASS ' + x for x in CONTROL_NAMES], complete=True)], 'Exact fifteen finite checks required')
    P.require(P.pin(P.TOOLS / 'phase134/emission/finite.mjs') in finite['inputs'], 'Finite runner authority missing')
    return dict(source=source, api=api['api'], checkedApi=P.pin(api_path), sourceManifest=P.pin(manifest_path),
        finiteControls=P.pin(finite_path), protectedDeclarations=protected, unchangedProofDeclarations=proofs,
        successResultSubstitutions=[x['name'] for x in success['overrides']], changedDeclarations=changed,
        completeSourceReplay=True, exactNativeRequestCallSubstitution=True, originalVerifierBytesUnchanged=True,
        scope='Reviewed unchanged checking/verification predicates with deferred successful rendering;15 finite controls. Not a proof of the complete compiler or File runtime.')


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    for name in ['reference', 'source-manifest', 'checked-api', 'finite', 'out']:
        ap.add_argument('--' + name, type=Path, required=True)
    for name in ['acquisition', 'n1-build', 'self-emission', 'n2-build', 'first-focused', 'final-focused', 'final-full45', 'reproduction', 'n3-build', 'wrapper-equality']:
        ap.add_argument('--' + name, type=Path)
    ap.add_argument('--policy', choices=['q1-q2', 'q2-q3'], default='q1-q2')
    ap.add_argument('--source-only', action='store_true', help='Audit actual source/control evidence; never claims native qualification')
    a = ap.parse_args()
    for path, expected in METHODS.items():
        P.require(P.pin(path)['sha256'] == expected, 'Reviewed method/module changed: ' + str(path)); V.retain(P.pin(path))
    ref, parent, base, _ = P.reference(a.reference)
    V.retain([P.pin(__file__), P.pin(P.__file__), P.pin(a.reference), *ref['inputs']])
    contract = source_contract(a.source_manifest, a.checked_api, a.finite, parent)
    if a.source_only:
        P.save(a.out, dict(kind='phase134-streaming-source-contract', complete=True, nativeQualified=False, targetsRun=False, sourceContract=contract, inputs=list(V.INPUTS.values()), selected=False, installed=False))
        print('Source/control contract passed; no native qualification'); return
    P.require(all([a.acquisition, a.n1_build, a.self_emission, a.n2_build, a.first_focused, a.final_focused, a.final_full45]), 'Actual reproduction/build and coverage receipts required')
    P.require(bool(a.reproduction) == bool(a.n3_build) == (a.policy == 'q2-q3'), 'Policy requires exactly Q1=Q2 or Q2=Q3; no implicit relaxation')
    producer = ref['qualifiedFallbackN3']; source = contract['source']; runtime = ref['runtime']; carrier = Path(ref['carrierReceipt']['file'])
    q1 = V.emission(a.acquisition, producer, source, runtime, carrier)
    n1 = V.Q.build(V.read(a.n1_build), q1, runtime, base['tools'])
    q2 = V.emission(a.self_emission, n1, source, runtime, carrier)
    n2 = V.Q.build(V.read(a.n2_build), q2, runtime, base['tools'])
    images, products = dict(n1=n1, n2=n2), dict(q1=q1, q2=q2)
    first, first_build, final, final_build, left, right = n1, a.n1_build, n2, a.n2_build, q1, q2
    if a.policy == 'q2-q3':
        q3 = V.emission(a.reproduction, n2, source, runtime, carrier)
        n3 = V.Q.build(V.read(a.n3_build), q3, runtime, base['tools'])
        images['n3'], products['q3'] = n3, q3
        first, first_build, final, final_build, left, right = n2, a.n2_build, n3, a.n3_build, q2, q3
    P.require(V.exact(left, right), 'Required complete native QBE fixed point failed')
    gates = [V.coverage(a.first_focused, first, first_build, runtime, base['tools']),
             V.coverage(a.final_focused, final, final_build, runtime, base['tools']),
             V.coverage(a.final_full45, final, final_build, runtime, base['tools'], broad=True)]
    wrappers = None
    if a.wrapper_equality:
        w = V.read(a.wrapper_equality)
        P.require(w.get('complete') and w.get('all45ByteExact') and w['image'] in images.values() and w['runtime'] == runtime and w['reusedMeasuredScreen'] == ref['measuredProgramScreen'], 'Wrapper equality is not bound to this chain/reference')
        P.require(len(w['cases']) == 45, 'All45 wrapper observations required')
        for row, case in zip(w['cases'], ref['wrappers']):
            P.require(row['name'] == case['name'] and row['expectedQbe'] == case['expectedQbe'] and row['measuredBinary'] == case['measuredBinary'], 'Wrapper corpus/product differs')
            emitted = V.emission(row['receipt']['file'], w['image'], case['source'], runtime, carrier)
            P.require(emitted == row['nativeQbe'] and V.exact(emitted, case['expectedQbe']), 'Wrapper complete QBE differs')
        wrappers = dict(receipt=P.pin(a.wrapper_equality), producingImage=w['image'], exactProducts=45, reusedMeasuredScreen=w['reusedMeasuredScreen'], freshProgramTimingClaimed=False)
    reports = {key: P.pin(value) for key, value in vars(a).items() if isinstance(value, Path) and key != 'out'}
    result = dict(kind='phase134-native-streaming-research-qualification', complete=True, nativeQualified=True, targetsRun=False,
        source=source, api=contract['api'], runtime=runtime, sourceContract=contract, producer=producer,
        producerSelection=P.pin(P.SELECTION), producerQualification=parent['qualificationArchive'], carrierReceipt=ref['carrierReceipt'],
        policy=a.policy, **images, qbe=products, requiredQbeByteExact=True, reproducedQbe=dict(left=left, right=right),
        acquisitionQbeUnchanged=V.exact(q1, q2), finalImage=final, semanticGates=gates, wrapperEquality=wrappers,
        reports=reports, inputs=list(V.INPUTS.values()), selected=False, installed=False, productionSelectionChanged=False,
        scope='Qualified research checkpoint from actual selected native producer, exact-source checked API, protected verifier/proof bytes,15 finite controls, exact requested QBE reproduction, focused19 on both required generations and ordinary45 on final image. No installed selection, ELF fixed point, complete compiler theorem, or performance result is implied.')
    # Recheck retained inputs at publication rather than relying on the helper's
    # per-process hash cache. Large QBE files are streamed, never read as strings.
    for item in result['inputs']: P.verify(item)
    P.save(a.out, result)
    print('Qualified experimental native chain; installed selection unchanged')


if __name__ == '__main__': main()
