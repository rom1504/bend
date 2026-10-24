#!/usr/bin/env python3
"""Bind exact Phase137 source and existing native gates; never execute targets."""
import argparse
import importlib.util
import json
from pathlib import Path
import re
import sys

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
TOOLS = ROOT / 'selfhost/tools/performance'
spec = importlib.util.spec_from_file_location('p137_native_contract', TOOLS / 'phase131/native/qualify.py')
V = importlib.util.module_from_spec(spec); spec.loader.exec_module(V)
Q, C = V.Q, V.C
SELECTION = ROOT / 'implementation/phase134/final/candidate.json'
SOURCE_SHA = '2620d59a3a20fa5d5d27bbf3b12ceb7304439b27093fff1c0f383da03e4ecf38'
CHANGED = sorted(['lookup', 'f_find', 'nc_ctor_owned', 'nol_fields', 'nol_ctor_fields',
                  'p131rg_width', 'p118b_project_borrow', 'p113i_eligible', 'p131rg_controls'])
GROUPS = {'p137w_controls': 17, 'p137qi_controls': 20, 'p131rg_controls': 13}
MODULES = ['wide/wide-v01.bend', 'wide/controls-v01.bend',
           'queries/retain-wide-v01.bend', 'queries/retain-controls-v02.bend',
           '../../../build/phase137/integrated-source03/module0.bend',
           'wide/controls-policy-v01.bend']


def require(ok, why):
    if not ok: raise ValueError(why)


def json_read(path): return json.loads(Path(path).read_text())


def save(path, value):
    path = Path(path).resolve()
    require(path.is_relative_to(ROOT / 'selfhost/build/phase137') and not path.exists(),
            'Fresh Phase137 metadata path required')
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open('x') as f: json.dump(value, f, indent=2); f.write('\n')


def authorities():
    frozen = json_read(HERE / 'authority.json')
    V.retain([Q.pin(__file__), Q.pin(HERE / 'authority.json'), *frozen['inputs']])
    parent = json_read(SELECTION)
    require(parent.get('complete') and parent.get('nativeQualified') and
            parent['source']['sha256'] == 'a00019246b5181b288ab4d3e09e616bd41415fe6381e89a96185c05efa19fb57',
            'Exact qualified Phase134 source required')
    for k in ['source', 'sourceManifest', 'checkedApi', 'runtime', 'runtimeReport',
              'n2', 'qualification', 'preferredCarrierReceipt']:
        V.retain(parent[k])
    prior = json_read(parent['qualification']['file'])
    require(prior.get('complete') and prior.get('nativeQualified') and
            prior['finalImage'] == parent['n2'] and prior['source'] == parent['source'] and
            prior['runtime'] == parent['runtime'], 'Parent qualification binding differs')
    base = V.read(ROOT / 'selfhost/build/phase130/n1-n2-timing01.json')
    require(parent['runtime'] == base['runtime'], 'Frozen machine runtime differs')
    return parent, prior, base


def source_contract(manifest_path, api_path, finite_path, parent, prior):
    sm, api, finite = map(V.read, [manifest_path, api_path, finite_path])
    source = sm['source']
    require(sm.get('complete') and sm.get('kind') == 'phase137-integrated-query-observer-source' and
            source['sha256'] == SOURCE_SHA and sm['qualified'] == parent['source'] and
            sm['qualifiedSelection'] == Q.pin(SELECTION) and sm['runtime'] == parent['runtime'],
            'Source outside this reviewed composition')
    require(api.get('kind') == 'phase111-checked-api' and api.get('complete') and api.get('checked') and
            api.get('status') == 0 and source in api['inputs'] and
            api['command'][2:4] == [source['file'], api['api']['file']] and
            api['command'][4:] == api['exports'], 'Independent checked source/API binding failed')
    old_api = V.bound(parent['checkedApi'])
    require(api['command'][:2] == old_api['command'][:2], 'Independent checker changed')
    for item in old_api['inputs']:
        if item != parent['source']:
            require(any((x['bytes'], x['sha256']) == (item['bytes'], item['sha256']) for x in api['inputs']),
                    'Checker/method authority differs: ' + item['file'])
    require(set(GROUPS) | {'p88_cache_prepare', 'p86_plan', 'p111_runtime_admission', 'p111_emit_admitted'}
            <= set(api['exports']), 'Required request/control exports absent')
    before_text, after_text = [Q.verify(row).read_text() for row in [parent['source'], source]]
    before, after = C.blocks(before_text), C.blocks(after_text)
    module_paths = [(TOOLS / 'phase137' / name).resolve() for name in MODULES]
    replay, added, protected = C.compose(before_text, [p.read_text() for p in module_paths], set(CHANGED), set())
    replay_blocks = C.blocks(replay)
    require(set(replay_blocks) == set(after) and all(C.norm(replay_blocks[n]) == C.norm(after[n]) for n in after),
            'Complete declaration replay differs')
    require(sorted(n for n in before if C.norm(before[n]) != C.norm(after[n])) == CHANGED and
            sorted(x['declaration'] for x in sm['allChangesFromQualified']) == CHANGED,
            'Changed declaration inventory differs')
    proofs = prior['sourceContract']['unchangedProofDeclarations']
    require(sm['protectedDeclarations'] == protected and sm['unchangedProofDeclarations'] == proofs and
            len(proofs) == 11 and all(before[n] == after[n] for n in protected + proofs),
            'Protected verifier/proof bytes changed')
    # The only other definitions are the exact replayed modules, and their
    # source hash above also covers comments, declarations and ordering.
    for n in set(before) - set(CHANGED):
        require(before[n].rstrip('\n') == after[n].rstrip('\n'), 'Unlisted body changed: ' + n)
    require(finite.get('complete') and finite.get('kind') == 'phase137-integrated-finite-controls' and
            source in finite['inputs'] and Q.pin(api_path) in finite['inputs'] and
            api['api'] in finite['inputs'] and Q.pin(TOOLS / 'phase137/loop/finite-integrated-v01.mjs') in finite['inputs'],
            'Finite controls use another source/API/method')
    expected_rows = []
    for name in ['p137qi_controls', 'p137w_controls', 'p131rg_controls']:
        labels = re.findall(r'(p128bs_control_row|p113ft_row)\("([^"]+)"', after[name])
        expected = [('PASS ' + label if fn == 'p113ft_row' else label + ':pass') for fn, label in labels]
        require(len(expected) == len(set(expected)) == GROUPS[name], 'Exact finite label count differs: ' + name)
        expected_rows.extend(expected)
    require(finite['expectedCount'] == 50 and finite['rows'] == expected_rows, 'Exact fifty finite rows differ')
    return dict(source=source, sourceManifest=Q.pin(manifest_path), checkedApi=Q.pin(api_path), api=api['api'],
                finiteControls=Q.pin(finite_path), finiteCount=50, changedDeclarations=CHANGED,
                addedDeclarations=added, protectedDeclarations=protected, unchangedProofDeclarations=proofs,
                completeDeclarationReplay=True, exactSourcePinned=True, originalVerifierBytesUnchanged=True,
                runtimeUnchanged=True, ordinaryEntryUnchanged=True)


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    for name in ['source-manifest', 'checked-api', 'finite', 'out']:
        ap.add_argument('--' + name, required=True, type=Path)
    for name in ['acquisition', 'n1-build', 'self-emission', 'n2-build', 'reproduction', 'n3-build',
                 'first-focused', 'final-focused', 'final-full45']:
        ap.add_argument('--' + name, type=Path)
    ap.add_argument('--policy', choices=['q1-q2', 'q2-q3'], default='q2-q3')
    ap.add_argument('--source-only', action='store_true')
    a = ap.parse_args(); parent, prior, base = authorities()
    contract = source_contract(a.source_manifest, a.checked_api, a.finite, parent, prior)
    if a.source_only:
        save(a.out, dict(kind='phase137-checked-source-contract', complete=True, nativeQualified=False,
             targetsRun=False, sourceContract=contract, producer=parent['n2'], runtime=parent['runtime'],
             carrierReceipt=parent['preferredCarrierReceipt'], inputs=list(V.INPUTS.values()), installed=False))
        print('Source and50 exact controls bound; native qualification remains pending'); return
    require(all([a.acquisition, a.n1_build, a.self_emission, a.n2_build, a.first_focused,
                 a.final_focused, a.final_full45]), 'Actual native chain and coverage receipts required')
    require(bool(a.reproduction) == bool(a.n3_build) == (a.policy == 'q2-q3'), 'Explicit reproduction policy mismatch')
    source, runtime, carrier = contract['source'], parent['runtime'], Path(parent['preferredCarrierReceipt']['file'])
    q1 = V.emission(a.acquisition, parent['n2'], source, runtime, carrier)
    n1 = Q.build(V.read(a.n1_build), q1, runtime, base['tools'])
    q2 = V.emission(a.self_emission, n1, source, runtime, carrier)
    n2 = Q.build(V.read(a.n2_build), q2, runtime, base['tools'])
    images, products = dict(n1=n1, n2=n2), dict(q1=q1, q2=q2)
    first, first_build, final, final_build, left, right = n1, a.n1_build, n2, a.n2_build, q1, q2
    if a.policy == 'q2-q3':
        q3 = V.emission(a.reproduction, n2, source, runtime, carrier)
        n3 = Q.build(V.read(a.n3_build), q3, runtime, base['tools'])
        images['n3'], products['q3'] = n3, q3
        first, first_build, final, final_build, left, right = n2, a.n2_build, n3, a.n3_build, q2, q3
    require(V.exact(left, right), 'Required complete QBE reproduction differs')
    gates = [V.coverage(a.first_focused, first, first_build, runtime, base['tools']),
             V.coverage(a.final_focused, final, final_build, runtime, base['tools']),
             V.coverage(a.final_full45, final, final_build, runtime, base['tools'], broad=True)]
    result = dict(kind='phase137-native-research-qualification', complete=True, nativeQualified=True,
        targetsRun=False, source=source, api=contract['api'], sourceContract=contract, runtime=runtime,
        producer=parent['n2'], producerSelection=Q.pin(SELECTION), producerQualification=parent['qualification'],
        carrierReceipt=parent['preferredCarrierReceipt'], policy=a.policy, **images, qbe=products,
        finalImage=final, requiredQbeByteExact=True, reproducedQbe=dict(left=left, right=right),
        acquisitionQbeUnchanged=V.exact(q1, q2), semanticGates=gates,
        reports={k: Q.pin(v) for k, v in vars(a).items() if isinstance(v, Path) and k != 'out'},
        inputs=list(V.INPUTS.values()), selected=False, installed=False, productionSelectionChanged=False,
        scope='Exact-source checked candidate,50 finite predicates, actual native producer/build chain, complete requested QBE fixed point, focused19 on both required generations and ordinary45 on final image. No ELF fixed point, full compiler proof, program-speed or compiler-speed claim.')
    for item in result['inputs']: require(Q.pin(item['file']) == item, 'Input changed during qualification')
    save(a.out, result); print('Native qualification passed; installed selection unchanged')


if __name__ == '__main__': main()
