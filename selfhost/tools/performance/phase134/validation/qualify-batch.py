#!/usr/bin/env python3
"""Versioned batch-source05 qualification; reuse the frozen native-chain gates.

The original stream qualifier stays byte-identical. Its checked source contract
anchors the unchanged renderer; this adapter audits only the bounded writer,
five-module replay and the additional packet predicates. No targets execute.
"""
import importlib.util
from pathlib import Path
import sys

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('p134_stream_qualification', HERE / 'qualify.py')
Q = importlib.util.module_from_spec(spec); spec.loader.exec_module(Q)
P, C, V = Q.P, Q.C, Q.V
P.require(P.pin(Q.__file__)['sha256'] == '5ccbddb23b681525bce776b5036b3bab7ebbe54e6cbea04180c663474e739b0c', 'Frozen first-stream qualifier changed')
SOURCE_SHA = '95c4ac4f0d529a0c63cc2e8a7e010c4e95ef4a4db2d697817560a46518f68c99'
NEW_METHODS = {
    P.TOOLS / 'phase134/native-io-v05.bend': '6fb7254d4c4a5b29d63c83a68223e720f065540619fc8cfa0d134508bd85ed72',
    P.TOOLS / 'phase134/emission/batch-controls-v04.bend': 'cf001bbb4d396cf03041a0e4c3490fb33622b5143df9a438384e7395ec64d6a6',
    P.TOOLS / 'phase134/emission/finite-v02.mjs': '556ff5a5fabc623499f7b5fc990a55c359cda3e41ca9fc7c8f50e3c0de5bb093',
}
PACKET_CONTROLS = [
    'batch-empty-stream', 'batch-empty-fragment', 'batch-empty-chunk-newline',
    'batch-existing-final-newline', 'batch-no-newline-boundary',
    'batch-exact-character-limit', 'batch-oversized-alone',
    'batch-pending-lookahead', 'batch-piece-count-and-data', 'batch-large-data-fragments',
]
ORIGINAL_SOURCE_CONTRACT = Q.source_contract


def source_contract(manifest_path, api_path, finite_path, parent):
    # Authenticate the already executed unchanged-body controls; do not rerun them.
    prior_manifest = P.BUILD / 'phase134/stream-source02/manifest.json'
    prior_api = P.BUILD / 'phase111/p134-stream-api02/report.json'
    prior_finite = P.BUILD / 'phase128/p134-stream-finite03/report.json'
    prior = ORIGINAL_SOURCE_CONTRACT(prior_manifest, prior_api, prior_finite, parent)
    sm, api, finite = map(V.read, [manifest_path, api_path, finite_path])
    source = sm['source']
    P.require(sm.get('kind') == 'phase134-exact-source-overlay' and sm.get('complete') and source['sha256'] == SOURCE_SHA and sm['parent'] == parent['source'] and sm['parentSelection'] == P.pin(P.SELECTION), 'Reviewed batch source/parent required')
    P.require(api.get('kind') == 'phase111-checked-api' and api.get('complete') and api.get('checked') and api.get('status') == 0 and source in api['inputs'], 'Independent batch source checking failed')
    P.require(api['command'][2:4] == [source['file'], api['api']['file']] and api['command'][4:] == api['exports'], 'Checked batch API command differs')
    old_api = V.read(prior_api)
    P.require(set(old_api['exports']) | {'p134wbc_controls', 'p134wb_packet'} <= set(api['exports']) and api['command'][:2] == old_api['command'][:2], 'Batch API omits prior/new controls or changes checker')
    for item in old_api['inputs']:
        if item != prior['source']:
            P.require(any((x['bytes'], x['sha256']) == (item['bytes'], item['sha256']) for x in api['inputs']), 'Independent checker/method changed')
    before_text = P.verify(parent['source']).read_text(); after_text = P.verify(source).read_text()
    before, after = C.blocks(before_text), C.blocks(after_text)
    snapshots = sorted(Path(source['file']).parent.glob('module*.bend'), key=lambda x: int(x.stem[6:]))
    P.require(len(snapshots) == 5, 'Exact five-module composition required')
    for path in snapshots:
        item = P.pin(path); V.retain(item)
        P.require(any((x['bytes'], x['sha256']) == (item['bytes'], item['sha256']) for x in sm['inputs']), 'Unbound batch module snapshot')
    P.require(set(sm['entryAdapters']) == {'p111_emit_admitted', 'p111_native_request'}, 'Batch changed entry adapter inventory')
    old_gates = C.ENTRY_GATES.copy()
    try:
        C.ENTRY_GATES -= set(sm['entryAdapters'])
        replay, added, protected = C.compose(before_text, [x.read_text() for x in snapshots], set(sm['overrides']), set())
    finally: C.ENTRY_GATES = old_gates
    P.require(replay == after_text and added == sm['added'] and protected == sm['protectedDeclarations'] == prior['protectedDeclarations'], 'Batch source replay or verifier inventory differs')
    proofs = prior['unchangedProofDeclarations']
    P.require(sm['unchangedProofDeclarations'] == proofs and all(before[n] == after[n] for n in protected + proofs), 'Protected verifier/proof bytes changed')
    previous = C.blocks(P.verify(prior['source']).read_text())
    P.require(set(previous) - set(after) == {'p134w_written', 'p134w_step', 'p134w_drain'}, 'Removed more than replaced writer helpers')
    changed_prior = sorted(n for n in previous if n in after and C.norm(previous[n]) != C.norm(after[n]))
    P.require(changed_prior == ['p134w_plan'], 'Batch changes renderer/admission rather than just writer dispatch')
    changed = sorted(n for n in before if C.norm(before[n]) != C.norm(after[n]))
    P.require(changed == sm['changedDeclarations'] == prior['changedDeclarations'] == sorted(sm['overrides']), 'Changed original declaration inventory differs')
    P.require(finite.get('complete') and finite['source'] == source and finite['sourceManifest'] == P.pin(manifest_path) and P.pin(api_path) in finite['inputs'] and api['api'] in finite['inputs'], 'Batch finite source/API identity differs')
    groups = [dict(name='p134ec_controls', expectedCount=15, rows=['PASS ' + x for x in Q.CONTROL_NAMES], complete=True),
              dict(name='p134wbc_controls', expectedCount=10, rows=['PASS ' + x for x in PACKET_CONTROLS], complete=True)]
    P.require(finite['groups'] == groups and P.pin(P.TOOLS / 'phase134/emission/finite-v02.mjs') in finite['inputs'], 'Exact15 original plus10 packet checks required')
    return dict(source=source, api=api['api'], checkedApi=P.pin(api_path), sourceManifest=P.pin(manifest_path),
        finiteControls=P.pin(finite_path), priorSourceContract=prior, protectedDeclarations=protected,
        unchangedProofDeclarations=proofs, successResultSubstitutions=prior['successResultSubstitutions'],
        changedDeclarations=changed, completeSourceReplay=True, originalVerifierBytesUnchanged=True,
        unchangedStreamDeclarations=True, addedPacketControls=10, variant='bounded-packet-writer',
        scope='Same verified plan, renderer, source routing and15 stream predicates; bounded writer adds10 packet controls. At most64 pieces/65536 characters except one oversized piece, with one possible rendered lookahead. This is not a complete compiler/File-runtime proof or a fixed UTF-8 byte limit.')


def main():
    Q.METHODS.update(NEW_METHODS)
    Q.source_contract = source_contract
    V.retain(P.pin(__file__))
    save = P.save
    def save_batch(path, value):
        value['variant'] = 'bounded-packet-writer'
        if 'scope' in value:
            value['scope'] += ' This writer version additionally requires10 exact packet predicates; no first-version qualification receipt is changed.'
        save(path, value)
    P.save = save_batch
    Q.main()


if __name__ == '__main__': main()
