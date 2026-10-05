#!/usr/bin/env python3
"""Derive an unchecked forced-generic Evening module; never execute a target.

Usage: array-literal-generic-probe.py BASELINE.mjs ARRAYS02.mjs NEW_DIRECTORY
Only the exact new literal adapter's private-entry condition is disabled. Its
existing generic fallback and every other compiler-emitted byte remain intact.
"""
import argparse
import hashlib
import json
from pathlib import Path

BASELINE_SHA = 'b21b0bbd4e40873907038838d89c559ef73d6c7e599f87e63e94b9f5be77f8b7'
CANDIDATE_SHA = 'b67afedbacb274617512fab203affa39ba44a6dd4128ee992e49d18f51e490b6'
BASELINE_API = '28f9eb983b2ba3603a9af703d832d4a301efe32182b468e090db6b728a47d12f'
CANDIDATE_API = '9bdeb7bb69e0291ad46c320f30b71fd65feb503a9fefe05ddc2987b03c1331f3'
RUNTIME_SHA = '880bce50e3194b9ee9d99bd57c18ef88bcb8925d9d1668dec6765040a4d3219b'
ASSIGNMENT = 'G["fpart"]='
ENTRY = 'if($entered&&arrayViewHostGuard()&&true&&localGuard($guards)){/* private literal array handles */'


def identity(file):
    path = Path(file).resolve(strict=True)
    data = path.read_bytes()
    return dict(path=str(path), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))


def verify(record):
    path = record.get('path', record.get('file', record.get('canonicalPath')))
    actual = identity(path)
    assert actual['sha256'] == record['sha256'], 'Changed input: ' + str(path)
    if 'bytes' in record:
        assert actual['bytes'] == record['bytes']
    return actual


def checked(module, expected_sha, expected_api, inputs):
    item = identity(module)
    assert item['sha256'] == expected_sha
    receipt_path = Path(str(module) + '.json')
    receipt = json.loads(receipt_path.read_text())
    assert receipt['kind'] == 'bend-program-checked-emission' and receipt['complete']
    assert receipt['observation']['checked'] and receipt['observation']['status'] == 'ok'
    assert receipt['output']['sha256'] == expected_sha
    compiler = receipt['compiler']
    assert compiler['kind'] == 'checked-development-attempt'
    assert compiler['api']['sha256'] == expected_api
    assert compiler['runtime']['sha256'] == RUNTIME_SHA
    inputs.extend([item, identity(receipt_path)])
    for record in [receipt['attempt'], receipt['input'], compiler['api'], compiler['runtime'],
                   compiler['base'], compiler['driver']]:
        inputs.append(verify(record))
    return receipt


def definition(text):
    lines = text.splitlines(keepends=True)
    matching = [line for line in lines if line.startswith(ASSIGNMENT)]
    assert len(matching) == 1, 'Missing/ambiguous complete assignment'
    return matching[0]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('baseline', type=Path)
    parser.add_argument('candidate', type=Path)
    parser.add_argument('output', type=Path)
    args = parser.parse_args()
    inputs = [identity(__file__)]
    baseline = checked(args.baseline, BASELINE_SHA, BASELINE_API, inputs)
    candidate = checked(args.candidate, CANDIDATE_SHA, CANDIDATE_API, inputs)
    assert baseline['input']['sha256'] == candidate['input']['sha256']
    assert baseline['compiler']['base']['sha256'] == candidate['compiler']['base']['sha256']
    old, new = args.baseline.read_text(), args.candidate.read_text()
    old_def, new_def = definition(old), definition(new)
    assert new.replace(new_def, old_def, 1) == old, 'Unrelated emitted differences'
    assert new.count(ENTRY) == new_def.count(ENTRY) == 1
    assert new.count('/* private literal array handles */') == 1
    # The ordinary source body must be identical, including argument order and
    # delayed jump. The wrapper/declarations are deliberately left in place.
    generic = old_def.split('fn(0,function(){', 1)[1].rsplit('}),false);', 1)[0]
    assert new_def.endswith(generic + '},false,true));})(),false);\n')
    forced = new.replace(ENTRY, 'if(false&&' + ENTRY[len('if('):], 1)
    assert len(forced) == len(new) + len('false&&')
    for item in inputs:
        assert identity(item['path']) == item
    out = args.output.resolve()
    out.mkdir(parents=True, exist_ok=False)
    manifest = dict(kind='phase48-literal-forced-generic-ablation', schemaVersion=1,
        complete=True, diagnosticOnly=True, checkedDerivative=False, executed=False,
        correctness='not-run', timing='not-run', inputs=inputs,
        parentCompiler=candidate['compiler'], source=candidate['input'],
        scope='Only the sole literal-adapter condition is prefixed false&&. The original generic fallback is used without evaluating private permission checks. No private path runs without its guards, and all other guards remain unchanged.',
        limitations='Saved-JavaScript diagnostic only; changed function source/introspection and JIT/code-size effects are not production qualification. Retained exactCode/declarations distinguish this from deleting the adapter.',
        structuralComparison=dict(onlyChangedDefinition='fpart', baselineBytes=len(old_def.encode()),
            candidateBytes=len(new_def.encode()), restoredDefinitionIsExactBaseline=True,
            dependencyCount=5, literalPrivateEntries=1), variants={})
    for name, text in [('original', new), ('forced-generic', forced)]:
        path = out / (name + '.mjs')
        with path.open('x') as stream:
            stream.write(text)
        manifest['variants'][name] = dict(module=identity(path), timingEligible=True,
            transformation='unchanged checked bytes' if name == 'original' else 'disable only literal private entry')
    for item in inputs:
        assert identity(item['path']) == item
    with (out / 'manifest.json').open('x') as stream:
        json.dump(manifest, stream, indent=2)
        stream.write('\n')
    print(json.dumps(dict(complete=True, executed=False, manifest=str(out / 'manifest.json'))))


if __name__ == '__main__':
    main()
