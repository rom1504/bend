#!/usr/bin/env python3
"""Bind the closed 03 frontend census to 04 using exact, reviewed unreachable deltas."""
import argparse
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
RAW = ROOT / 'selfhost/build/phase66'
OLD_BASE = 'c742fae9c49b14f0cc9128429a2c6109364c8a933a142f2c90b9f2e5fd976661'
NEW_BASE = '99ac43f2b2bb3e3f39acdcedcecbbd3cb44749ce13969c827d6973fa66f7facf'
OLD_ARRAY = "if(outgoing&&x.array||!outgoing&&Array.isArray(x)){"
NEW_ARRAY = "if(outgoing&&(x.array||desc?.[0]==='Array')||!outgoing&&Array.isArray(x)){"
DELTAS = {
    'tools/typed-driver.mjs': ('21824aaa0fbece123ad87b91fae63608725a72d0fc61e1c064639a209692c168', 'e093483d5103a8e833b6ca710246b1ec3c579b7fac5060c8e42f626c5e25ec85', OLD_BASE, NEW_BASE),
    'src/runtime.mjs': ('6cd3ff8159f489516bf5b3cf120efefaac7bd754d81b768d4c3a5ef80f6e502f', '913b6a850c60377dbb13ef98db2811b6c8383ee9fa6a6fc16fcad9c68f8afc54', OLD_ARRAY, NEW_ARRAY),
    'src/runtime/js/foreign.mjs': ('0cb75519091f17c1739e23fd2693909249585073aa6145602078cfdcdc8543be', 'ad406115010d01b969b18d2446fd8f4073c53118abc95aac4ba6fd9a928be9bb', OLD_ARRAY, NEW_ARRAY),
}
inputs = {}


def pin(value):
    item = value if isinstance(value, dict) else None
    file = Path(item['file'] if item else value).resolve(strict=True)
    data = file.read_bytes()
    actual = dict(file=str(file), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))
    if item:
        assert actual['sha256'] == item['sha256'], file
        if 'canonicalPath' in item:
            assert str(file) == item['canonicalPath'], file
        if 'bytes' in item:
            assert len(data) == item['bytes'], file
    assert str(file) not in inputs or inputs[str(file)] == actual
    inputs[str(file)] = actual
    return actual


def read(value):
    return json.loads(Path(pin(value)['file']).read_text())


def attempt(directory):
    item = pin(directory / 'attempt.json')
    at = read(item)
    assert at['checked'] and at['artifactKind'] == 'derived-b1'
    assert at['config']['strictExact']
    for key in ['api', 'checkedApi', 'base', 'node']:
        pin(at[key])
    bootstrap = read(at['bootstrapReport'])
    assert bootstrap['revision'] == '059266225b77c8ca256ac6b25ee5c21449bab151'
    assert bootstrap['baseSha256'] == at['base']['sha256'] == NEW_BASE
    assert bootstrap['apiSha256'] == at['checkedApi']['sha256']
    source = pin(bootstrap['source'])
    assert source['sha256'] == bootstrap['sourceSha256']
    assert len(bootstrap['exports']) == len(set(bootstrap['exports'])) == 99
    derivation = read(at['derivationReport'])
    assert derivation['complete'] and derivation['transform']['version'] == 7
    assert pin(derivation['original']['api']) == pin(at['checkedApi'])
    assert pin(derivation['original']['bootstrapReport']) == pin(at['bootstrapReport'])
    assert pin(derivation['original']['source']) == source
    assert pin(derivation['output']) == pin(at['api'])
    assert pin(derivation['tool'])['sha256'] == 'fcc80fd4da249e74f2cfd296c7e88f3c5f795a627e498c26bf5deb4ac8397eb5'
    validation = read(directory / 'validation-001/report.json')
    assert validation['complete'] and validation['pass'] and validation['strictExact']
    assert pin(validation['attempt']) == item and pin(validation['api']) == pin(at['api'])
    selected = validation['selected']
    assert selected['selectedComplete'] and selected['exactDifferences'] == selected['discrepancies'] == 0
    assert selected['candidate']['probes'] == selected['reference']['probes'] == 36
    pin(selected['file'])
    rows = {}
    for row in at['snapshot']['sources']:
        frozen = pin(row['frozen'])
        relative = str(Path(frozen['file']).relative_to(at['snapshot']['root']))
        assert relative not in rows
        rows[relative] = frozen
    return item, at, bootstrap, source, rows


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--out', type=Path, required=True)
    args = p.parse_args()
    output = args.out.resolve()
    assert output.is_relative_to(RAW) and not output.exists()
    pin(__file__)
    old_pin, old, ob, os, before = attempt(RAW / 'checked-b1-03')
    new_pin, new, nb, ns, after = attempt(RAW / 'checked-b1-04')
    assert before.keys() == after.keys() and len(before) == 313
    changed = {key for key in before if before[key]['sha256'] != after[key]['sha256']}
    assert changed == DELTAS.keys()
    changes = []
    for key, (old_sha, new_sha, old_text, new_text) in DELTAS.items():
        assert before[key]['sha256'] == old_sha and after[key]['sha256'] == new_sha
        a, b = (Path(rows[key]['file']).read_text() for rows in [before, after])
        assert a.count(old_text) == 1 and a.replace(old_text, new_text) == b
        changes.append(dict(relative=key, before=before[key], after=after[key], old=old_text, new=new_text))
    for key in ['api', 'checkedApi', 'base', 'node']:
        assert old[key]['sha256'] == new[key]['sha256']
    assert os['sha256'] == ns['sha256'] and ob['exports'] == nb['exports']
    assert before['src/runtime/js/direct.mjs']['sha256'] == after['src/runtime/js/direct.mjs']['sha256']

    # These anchors document the source-reviewed reachability proof. The full
    # driver hashes above make this specific to the reviewed implementations.
    driver = Path(after['tools/typed-driver.mjs']['file']).read_text()
    start = driver.index('export async function createPersistentInspector()')
    end = driver.index('\nfunction observation(', start)
    persistent = driver[start:end]
    assert "if(!['parse','check'].includes(options.mode??'check'))" in persistent
    assert 'prepareBase' not in persistent
    start = driver.index('async function inspectWithMemo(')
    end = driver.index("    if(mode==='check') return", start)
    frontend = driver[start:end]
    assert "if(mode==='parse') return" in frontend
    assert 'await prepareBase(api,{backendProducts:false})' in frontend
    assert 'readBaseAnnotations(' not in frontend and 'prepareBaseAnnotations(' not in frontend
    assert 'fs.readFileSync(runtimePath' not in frontend
    assert driver.count('if(backendProducts)prepareBaseAnnotations') == 1
    assert driver.count('if(backendProducts&&baseAnnotationApis(api))') == 1

    comparison = read(RAW / 'conformance-front-paired03.json')
    assert comparison['observationsClosed']
    # Reverify the comparator, every source/fixture/host image it pinned, and
    # the complete result receipts. No current mutable source path exemption.
    for item in comparison['inputs']:
        pin(item)
    pairs = [x for x in comparison['comparisons'] if x['reference'] == 'typescript-new-frontend' and x['candidate'] == 'bend-candidate-new-base-frontend']
    assert len(pairs) == 1
    pair = pairs[0]
    assert pair['commonObservations'] == pair['exactObservationAgreements'] == 3174
    assert not pair['statusDifferences'] and not pair['observationDifferences']
    assert pair['referenceOnly'] == pair['candidateOnly'] == 0
    recipe = read(RAW / 'conformance-new-bend-full01/recipe.json')
    assert len(recipe['images']) == len(recipe['commands']) == 1
    image, command = recipe['images'][0], recipe['commands'][0]
    assert pin(image['attempt']) == old_pin and image['compilerImage']['sha256'] == old['api']['sha256']
    argv = command['command']
    assert argv[argv.index('--lanes')+1] == 'parse,check'
    assert argv[argv.index('--worker-mode')+1] == 'persistent'
    assert command['expectedObservations'] == 3174
    report = read(command['report'])
    assert {r['lane'] for r in report['results']} == {'parse', 'check'}
    assert len(report['results']) == 3174 and report['finished']
    assert not report['changedInputs'] and not report['identity']['changedArtifacts']
    receipt = dict(kind='phase66-frontend-exact-reuse', complete=True, passed=True, dataOnly=True,
        oldAttempt=old_pin, newAttempt=new_pin, comparison=pin(RAW/'conformance-front-paired03.json'),
        originalFrontendReport=pin(command['report']), exactObservations=3174,
        frozenSources=dict(count=313, unchanged=310, changes=changes),
        unchangedCompiler=dict(api=pin(new['api']), checkedApi=pin(new['checkedApi']), source=ns,
            base=pin(new['base']), node=pin(new['node']), roots=nb['exports'], directRuntime=after['src/runtime/js/direct.mjs']),
        freshStrict36=pin(RAW/'checked-b1-04/validation-001/report.json'),
        reachabilityProof='Persistent session only admits parse/check. Creation loads the unchanged API. Parse returns before checking; check prepares mandatory Base with backendProducts:false and returns before optional annotation consumption or runtime emission. The sole host constant delta is read only by optional product preparation/consumption. Both legacy Foreign Array expression copies are emission/runtime-only and are neither imported nor executed by these frontend requests. Exact whole-file before/after edits and 310 unchanged frozen dependencies bind this reviewed proof.',
        scope='Reuses only the closed 3174 parse/check observations under exact unchanged compiler/API/Base/frontend semantics; preserves observed negative parses, type acceptance and proof-trust refusal separately. Does not reuse backend, runtime, generated-program performance, release or arbitrary custom host behavior.', inputs=list(inputs.values()))
    for item in list(inputs.values()):
        pin(item)
    output.parent.mkdir(parents=True, exist_ok=True)
    with output.open('x') as stream:
        stream.write(json.dumps(receipt, indent=2)+'\n')
    print(json.dumps(dict(output=pin(output), passed=True, exactObservations=3174)))


if __name__ == '__main__':
    main()
