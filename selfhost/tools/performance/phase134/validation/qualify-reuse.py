#!/usr/bin/env python3
"""Exact selected no-copy + verified-function reuse contract; no range memo pass.

Prior qualifiers remain immutable. Only two existing optimizer callers change;
all actual p113e/final verifier bodies and the checked no-copy route are retained.
"""
import importlib.util
from pathlib import Path
import re
import sys

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('p134_nocopy_contract', HERE / 'qualify-no-copy.py')
N = importlib.util.module_from_spec(spec); spec.loader.exec_module(N)
Q, P, C, V = N.Q, N.P, N.C, N.V
P.require(P.pin(N.__file__)['sha256'] == '4ea15bc20cb141bae6b6a969c5644f9fdb082922ec1d1cb4dc7580d818ae7e07', 'Frozen no-copy qualifier changed')
SOURCE_SHA = 'a00019246b5181b288ab4d3e09e616bd41415fe6381e89a96185c05efa19fb57'
CORE = P.TOOLS / 'phase134/reuse/verify-core-v01.bend'
CONTROLS = P.TOOLS / 'phase134/reuse/verify-controls-v01.bend'
FINITE = P.TOOLS / 'phase134/reuse/finite-v03.mjs'
NEW_METHODS = {
    CORE: '7129be0eb9ba0003586548b7067384f8c75c0224c7cf9cae677d0ae0fdbb02e2',
    CONTROLS: '7592b21b4a30826563fcb66b3db4c472945c06690d991572961b109fb3bac507',
    FINITE: '9b690507fe903e0eeadcc0ea38149dae334bd2031cf79ce77baf0e1f38d5a207',
}


def source_contract(manifest_path, api_path, finite_path, parent):
    # Authenticate prior no-copy semantics and actual native writer controls;
    # these completed experiments are reused, never re-executed here.
    prior = N.source_contract(P.BUILD/'phase134/no-copy-source01/manifest.json',
        P.BUILD/'phase111/p134-no-copy-api01/report.json',
        P.BUILD/'phase128/p134-no-copy-finite01/report.json', parent)
    sm, api, finite = map(V.read,[manifest_path,api_path,finite_path])
    source = sm['source']
    P.require(sm.get('kind') == 'phase134-exact-source-overlay' and sm.get('complete') and source['sha256'] == SOURCE_SHA and sm['parent'] == parent['source'] and sm['parentSelection'] == P.pin(P.SELECTION), 'Exact selected reuse source/parent required')
    P.require(api.get('kind') == 'phase111-checked-api' and api.get('complete') and api.get('checked') and api.get('status') == 0 and source in api['inputs'], 'Actual combined source independently checked')
    P.require(api['command'][2:4] == [source['file'],api['api']['file']] and api['command'][4:] == api['exports'], 'Checked combined API command differs')
    old_api = V.bound(prior['checkedApi'])
    required = {'p88_cache_prepare','p86_plan','p111_runtime_admission','p111_emit_admitted',
                'p134e_compile_source','p134e_begin','p134e_next','p134v_controls','p114s_control_report','p134ec_controls'}
    P.require(api['command'][:2] == old_api['command'][:2] and required <= set(api['exports']), 'Combined API omits actual differential/control exports or changes checker')
    for item in old_api['inputs']:
        if item != prior['source']:
            P.require(any((x['bytes'],x['sha256']) == (item['bytes'],item['sha256']) for x in api['inputs']), 'Independent checker/method differs')
    before_text = P.verify(parent['source']).read_text(); after_text = P.verify(source).read_text()
    before, after = C.blocks(before_text), C.blocks(after_text)
    snapshots = sorted(Path(source['file']).parent.glob('module*.bend'),key=lambda x:int(x.stem[6:]))
    P.require(len(snapshots) == 6, 'Exact six-module composition required')
    for path in snapshots:
        item=P.pin(path); V.retain(item)
        P.require(any((x['bytes'],x['sha256']) == (item['bytes'],item['sha256']) for x in sm['inputs']), 'Unbound combined module snapshot')
    P.require(set(sm['entryAdapters']) == {'p111_emit_admitted','p111_native_request'}, 'Request entry adapter inventory changed')
    gates = C.ENTRY_GATES.copy()
    try:
        C.ENTRY_GATES -= set(sm['entryAdapters'])
        replay,added,protected = C.compose(before_text,[x.read_text() for x in snapshots],set(sm['overrides']),set())
    finally: C.ENTRY_GATES = gates
    P.require(replay == after_text and added == sm['added'] and protected == sm['protectedDeclarations'] == prior['protectedDeclarations'], 'Combined source replay/protected inventory differs')
    proofs = prior['unchangedProofDeclarations']
    P.require(sm['unchangedProofDeclarations'] == proofs and all(before[n] == after[n] for n in protected+proofs), 'Original verifier/proof declaration bytes changed')
    previous = C.blocks(P.verify(prior['source']).read_text())
    new = C.blocks(CORE.read_text()); new.update(C.blocks(CONTROLS.read_text()))
    P.require(not (set(previous)-set(after)) and set(after)-set(previous) == set(new)-set(previous), 'Unexpected combined additions/removals')
    changes = sorted(n for n in previous if C.norm(previous[n]) != C.norm(after[n]))
    P.require(changes == ['p114s_inline','p114s_ranges'], 'Reuse changes more than the two optimizer callers')
    for name in changes:
        P.require(C.norm(previous[name].replace('p114s_commit(', 'p134v_commit(')) == C.norm(after[name]), 'Original optimizer operation/order changed: '+name)
    verifiers = sorted(n for n in previous if n.startswith(('p113e_','p111v_','p113a_verify')) or n in ['p114s_open','p114s_open_functions','p114s_commit'])
    P.require(all(previous[n] == after[n] for n in verifiers), 'Actual verification implementation/provenance changed')
    P.require(not any(n.startswith('p134rk_') for n in after), 'Rejected duplicate-range experiment leaked into final source')
    changed = sorted(n for n in before if C.norm(before[n]) != C.norm(after[n]))
    P.require(changed == sm['changedDeclarations'] == sorted(sm['overrides']), 'Changed original declaration inventory differs')
    P.require(finite.get('complete') and finite['source'] == source and finite['sourceManifest'] == P.pin(manifest_path) and P.pin(api_path) in finite['inputs'] and api['api'] in finite['inputs'] and P.pin(FINITE) in finite['inputs'], 'Actual combined finite source/API/method differs')
    names = re.findall(r'p114st_row\("([^"]+)"',CONTROLS.read_text())
    P.require(len(names) == len(set(names)) == 26, 'Expected26 fixed reuse controls')
    expected = {
        'p134v_controls': ['PASS '+x for x in names],
        'p114s_control_report': ['PASS scaling-'+case+'-'+kind for case in ['empty','identity','product-calls','branch','tail-loop','public-main'] for kind in ['original','opened','exact-output']],
        'p134ec_controls': ['PASS '+x for x in Q.CONTROL_NAMES],
    }
    P.require(len(finite['groups']) == 3 and {g['name'] for g in finite['groups']} == set(expected), 'Exact three finite groups required')
    for group in finite['groups']:
        rows=expected[group['name']]
        P.require(group == dict(name=group['name'],expectedCount=len(rows),rows=rows,complete=True), 'Exact59 finite predicate observations required')
    return dict(source=source,api=api['api'],checkedApi=P.pin(api_path),sourceManifest=P.pin(manifest_path),finiteControls=P.pin(finite_path),
        priorSourceContract=prior,protectedDeclarations=protected,unchangedProofDeclarations=proofs,
        successResultSubstitutions=prior['successResultSubstitutions'],changedDeclarations=changed,completeSourceReplay=True,
        originalVerifierBytesUnchanged=True,unchangedVerificationImplementations=verifiers,changedOptimizerCallers=changes,
        nativeWriterControls=prior['nativeWriterControls'],nativeWriterBuild=prior['nativeWriterBuild'],
        reuseCore=P.pin(CORE),reuseControls=P.pin(CONTROLS),finiteCount=59,duplicateRangeIncluded=False,
        variant='no-copy-verification-reuse',
        scope='Same ordered full headers and immutable IDs preserve verifier context. Unchanged successful bodies reuse their prior judgment; changed/unknown bodies use p113e_function, header changes use original p114s_commit. Internally produced boundaries only; no external/persistent certificate claim. Original final verifier and no-copy renderer remain unchanged;26 reuse+18 existing optimizer+15 emission predicates pass.')


def main():
    Q.SOURCE_SHA = N.SOURCE_SHA  # Used only to authenticate the prior no-copy contract.
    Q.METHODS.update(N.NEW_METHODS); Q.METHODS.update(NEW_METHODS)
    Q.source_contract = source_contract
    V.retain([P.pin(__file__),P.pin(N.__file__)])
    save=P.save
    def save_reuse(path,value):
        value['variant']='no-copy-verification-reuse'
        if 'scope' in value: value['scope'] += ' Selected extension additionally requires26 reuse and18 existing optimizer predicates; duplicate-range memo experiment is excluded.'
        save(path,value)
    P.save=save_reuse
    Q.main()


if __name__ == '__main__': main()
