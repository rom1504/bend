#!/usr/bin/env python3
"""Join closed frontend03 evidence to final07 with exact generated frontend closure."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent


def module(name, file):
    spec = importlib.util.spec_from_file_location(name, file)
    value = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(value)
    return value


P = module('phase66_frontend_parent', HERE/'reuse-frontend-v1.py')
C = module('phase66_frontend_closure', HERE/'frontend-closure.py')
ROOT, RAW, pin, read = P.ROOT, P.RAW, P.pin, P.read


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    out = args.out.resolve()
    assert out.is_relative_to(RAW) and not out.exists()
    for file in [Path(__file__), HERE/'reuse-frontend-v1.py', HERE/'frontend-closure.py']:
        pin(file)
    original = read(RAW/'conformance-final04-frontend-reuse.json')
    assert original['complete'] and original['passed'] and original['exactObservations'] == 3174
    assert original['kind'] == 'phase66-frontend-exact-reuse'
    for item in original['inputs']:
        pin(item)
    native = read(RAW/'reuse04-to05.json')
    assert native['complete'] and native['eligibleForExactJavaScriptReuse']
    assert native['nativeQualificationTransferred'] is False
    assert pin(native['baseline']) == pin(original['newAttempt'])
    for item in native['inputs']:
        pin(item)
    old_pin, old, old_boot, old_source, before = P.attempt(RAW/'checked-b1-05')
    new_pin, new, new_boot, new_source, after = P.attempt(RAW/'checked-b1-07')
    assert old_pin == pin(native['candidate'])
    assert before.keys() == after.keys() and len(before) == 313
    expected = {'src/back/js/direct/core.bend', 'src/back/js/direct/calls.bend', 'src/back/js/validate.bend'}
    changed = {key for key in before if before[key]['sha256'] != after[key]['sha256']}
    assert changed == expected
    assert old_boot['exports'] == new_boot['exports']
    for key in ['base', 'node']:
        assert old[key]['sha256'] == new[key]['sha256']
    assert old['api']['sha256'] != new['api']['sha256']
    manifest_files = {
        'src/back/js/direct/core.bend': 'backend/min-erasure-v1/candidate.json',
        'src/back/js/direct/calls.bend': 'backend/wide-call-fields-v2/candidate.json',
        'src/back/js/validate.bend': 'shared-layout/printable-v3/candidate.json',
    }
    changes = []
    for relative, name in manifest_files.items():
        file = HERE.parent/name
        manifest = read(file)
        pin(manifest['patch'])
        candidate = pin(manifest.get('after', manifest.get('candidate')))
        assert candidate['sha256'] == after[relative]['sha256']
        if relative != 'src/back/js/validate.bend':
            assert pin(manifest['before'])['sha256'] == before[relative]['sha256']
        else:
            prior = read(manifest['priorCandidate'])
            assert prior['source']['sha256'] == before[relative]['sha256']
            text = Path(before[relative]['file']).read_text()
            for edit in prior['edits']:
                assert text.count(edit['old']) == edit['occurrences']
                text = text.replace(edit['old'], edit['new'])
            assert hashlib.sha256(text.encode()).hexdigest() == pin(prior['candidate'])['sha256']
            assert prior['candidate']['sha256'] == manifest['source']['sha256']
            for edit in manifest['edits']:
                assert text.count(edit['old']) == edit['occurrences']
                text = text.replace(edit['old'], edit['new'])
            assert text == Path(candidate['file']).read_text()
        changes.append(dict(relative=relative, before=before[relative], after=after[relative],
            candidateManifest=pin(file), reviewedCandidate=candidate))
    driver_file = after['tools/typed-driver.mjs']
    driver = Path(driver_file['file']).read_text()
    assert driver_file['sha256'] == before['tools/typed-driver.mjs']['sha256']
    # The inherited host-source proof remains exact: ordinary persistent
    # sessions only parse/check, disable optional product production, and
    # return before compiler backends or generated runtimes are invoked.
    begin = driver.index('export async function createPersistentInspector()')
    end = driver.index('\nfunction observation(', begin)
    persistent = driver[begin:end]
    assert "if(!['parse','check'].includes(options.mode??'check'))" in persistent
    assert 'prepareBase' not in persistent
    begin = driver.index('async function inspectWithMemo(')
    end = driver.index("    if(mode==='check') return", begin)
    frontend = driver[begin:end]
    assert "if(mode==='parse') return" in frontend
    assert 'await prepareBase(api,{backendProducts:false})' in frontend
    assert 'readBaseAnnotations(' not in frontend and 'prepareBaseAnnotations(' not in frontend
    assert 'fs.readFileSync(runtimePath' not in frontend
    closure = C.compare(old['api']['file'], new['api']['file'], driver)
    assert len(closure['roots']) == 51 and closure['unchangedFunctionCount'] == 1403
    assert len(closure['changedUnreachableFunctions']) == 13
    tokenizer = pin(ROOT/'selfhost/tools/development/equality.mjs')
    assert tokenizer['sha256'] == 'fcc80fd4da249e74f2cfd296c7e88f3c5f795a627e498c26bf5deb4ac8397eb5'
    receipt = dict(kind='phase66-final07-frontend-closure-reuse', complete=True, passed=True,
        dataOnly=True, targetExecuted=False, producer=pin(__file__),
        originalFrontendReuse=pin(RAW/'conformance-final04-frontend-reuse.json'),
        originalFrontendReport=original['originalFrontendReport'], exactObservations=3174,
        nativeOnlyIntermediate=pin(RAW/'reuse04-to05.json'),
        previousAttempt=old_pin, selectedAttempt=new_pin,
        compilerImages=dict(previous=pin(old['api']), selected=pin(new['api']),
            previousSource=old_source, selectedSource=new_source),
        frozenSources=dict(count=313, unchanged=310, changes=changes),
        generatedFrontendClosure=closure, tokenizerSource=tokenizer,
        unchangedHost=driver_file, base=pin(new['base']), node=pin(new['node']),
        freshStrict36=pin(RAW/'checked-b1-07/validation-001/report.json'),
        sourceProof='03→04 has the original exact host-delta frontend proof. 04→05 changes only eight native source files; the actual JS API, host and runtime remain identical. 05→07 changes exactly three backend Bend files. The generated runtime,99 identity API wrappers and all1403 functions reachable from51 conservative frontend host roots remain byte-identical. Only13 backend functions differ and none is reachable. Persistent parse/check returns before backend use. No API image identity is falsely asserted.',
        scope='Transfers only closed3174 parse/check observations, including original shared later-stage mismatches and observed negative parses. Backend/runtime/module/performance results require their own fresh final07 evidence. No mathematical proof,Lean,GPU or universal language-conformance claim.',
        inputs=list(P.inputs.values()))
    for item in receipt['inputs']:
        pin(item)
    out.parent.mkdir(parents=True, exist_ok=True)
    with out.open('x') as stream:
        stream.write(json.dumps(receipt, indent=2)+'\n')
    print(json.dumps(dict(output=pin(out), exactObservations=3174,
        unchangedFrontendFunctions=closure['unchangedFunctionCount'])))


if __name__ == '__main__':
    main()
