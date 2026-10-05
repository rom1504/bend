#!/usr/bin/env python3
"""Data-only factory for a fresh Phase47 normal-library cost planner.

Does not import an API, verify an attempt, prime a cache, or execute a target.
The generated planner is executed separately by the root after source freeze.
"""
import argparse
import ast
import copy
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
PARENT = HERE.parent / 'phase39/compiler-cost-plan.py'
PARENT_SHA = '43ebb0a6bab827f7ddc872a1db90fb9591c51d40e7409b9910f00248f9c29cde'
WORKER = HERE.parent / 'phase30/library-cost-worker.mjs'
WORKER_SHA = 'f0dea569bdb02df60ed1156b0cead389e197291f1c3a3c6775102c7a03790f42'
RUNNER = HERE / 'compiler-cost-run.py'
RUNNER_SHA = '557a6600f25d1bf63f5c1ee973458f3bfc345bdd9afae0fa57ce735d283f2ca4'
ROOT = HERE.parents[3]
BASELINE = ROOT / 'selfhost/build/phase45/full-preparation-worker23/manifest.json'
BASELINE_SHA = '904cfdadc27b3238e1f8debd06085f9d0bb1533047c6263f269b26e85ee473ba'
CASES = ['local-fold', 'editdist', 'lexer']


def identity(file):
    data = file.read_bytes()
    return dict(file=str(file.resolve()), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def derive(source):
    replacements = [
        ("HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];PROGRAMS=HERE.parent/'programs'",
         f"HERE=Path({str(PARENT.parent)!r});ROOT=HERE.parents[3];PROGRAMS=HERE.parent/'programs'"),
        ('with ExecutionGuard(rss_mib=2048,available_mib=2048) as guard:',
         'with ExecutionGuard(rss_mib=2048,available_mib=4096) as guard:'),
        ('heapMiB=1024,rssMiB=2048,availableMiB=2048,node=',
         'heapMiB=1024,rssMiB=2048,availableMiB=4096,node='),
        ("--cases',default='local-pair,tree-bitonic,coverage-numeric-recurrence-1024'",
         "--cases',default='local-fold,editdist,lexer'"),
    ]
    for before, after in replacements:
        assert source.count(before) == 1, 'Parent substitution is no longer exact'
        source = source.replace(before, after, 1)
    # Historical provenance text and kind remain unchanged. This separate
    # derivation receipt records the current parent and the four exact changes.
    ast.parse(source)
    return source.encode()


def baseline_subset(out):
    original = identity(BASELINE)
    assert original['sha256'] == BASELINE_SHA
    manifest = json.loads(BASELINE.read_text())
    assert manifest['complete'] and set(manifest['roles']) == {'candidate'}
    compiler = manifest['roles']['candidate']['compiler']
    assert compiler['api']['sha256'] == 'e77c504a9c91d9ae9d43e52f4f4899711eb7a8ebe707ee565348df2708488b4c'
    catalog_file = HERE.parent / 'phase37/catalog.json'
    assert identity(catalog_file)['sha256'] == manifest['catalogSha256']
    catalog = json.loads(catalog_file.read_text())
    rows, retained = [], []
    for name in CASES:
        selected = [r for r in manifest['cases'] if r['id'] == name]
        assert len(selected) == 1
        row = copy.deepcopy(selected[0])
        case = next(c for c in catalog['cases'] if c['id'] == name)
        assert row['sourceSha256'] == case['source']['sha256'] and row['point'] == case['point']
        module = row['modules']['candidate']
        relative = Path(module['path'])
        assert not relative.is_absolute() and '..' not in relative.parts
        source = BASELINE.parent / relative
        assert source.resolve().is_relative_to(BASELINE.parent.resolve())
        data = source.read_bytes()
        assert len(data) == module['bytes'] and hashlib.sha256(data).hexdigest() == module['sha256']
        receipt_file = Path(str(source) + '.json')
        receipt_data = receipt_file.read_bytes()
        receipt = json.loads(receipt_data)
        assert receipt['kind'] == 'bend-program-checked-emission' and receipt['complete']
        assert receipt['observation']['checked'] and receipt['compiler'] == compiler
        assert receipt['input']['sha256'] == row['sourceSha256']
        assert receipt['output']['sha256'] == module['sha256']
        assert receipt['catalog']['sha256'] == manifest['catalogSha256']
        assert receipt['attempt']['sha256'] == 'd58b4fe1499803ec0df9bc6b79c76493d90d1a6d8f55e246ecaec31e24f9b5d4'
        target = out / 'baseline' / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        with target.open('xb') as stream:
            stream.write(data)
        with Path(str(target) + '.json').open('xb') as stream:
            stream.write(receipt_data)
        retained.append(dict(case=name, originalModule=identity(source), copiedModule=identity(target),
                             originalReceipt=identity(receipt_file), copiedReceipt=identity(Path(str(target)+'.json'))))
        row['modules'] = {'baseline': module}
        rows.append(row)
    subset = {k: manifest[k] for k in ['kind', 'schemaVersion', 'complete', 'upstreamCommit', 'catalogSha256']}
    subset.update(roles={'baseline': manifest['roles']['candidate']}, cases=rows)
    assert identity(BASELINE) == original
    return subset, dict(originalManifest=original, originalRole='candidate', selectedRole='baseline',
                        retained=retained, receiptBytesUnchanged=True, compilerBytesUnchanged=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('out', type=Path, help='Fresh directory for planner and derivation receipt')
    args = parser.parse_args()
    parents = [identity(PARENT), identity(WORKER), identity(RUNNER)]
    assert [x['sha256'] for x in parents] == [PARENT_SHA, WORKER_SHA, RUNNER_SHA]
    data = derive(PARENT.read_text())
    out = args.out.resolve()
    assert not out.exists(), 'Preserve every consumed prior plan'
    out.mkdir(parents=True)
    (out / 'planner.py').write_bytes(data)
    subset, baseline = baseline_subset(out)
    receipt = dict(kind='phase47-compiler-cost-planner-derivation', complete=True,
                   targetExecuted=False, configCreated=False, producer=identity(Path(__file__)),
                   parent=parents[0], worker=parents[1], runner=parents[2],
                   derived=identity(out / 'planner.py'),
                   baseline=baseline,
                   changes=['Anchor HERE to the original Phase39 tool directory',
                            'Raise planner verification available-memory floor to 4096 MiB',
                            'Raise recorded available-memory floor to 4096 MiB',
                            'Default cases to local-fold,editdist,lexer'],
                   unchanged=['Phase30 worker bytes', 'Compiler/cache/receipt verification',
                              'Rotated three samples and public request timing boundary',
                              'Independent expected-output matching', 'Phase47 runner bytes'],
                   historicalMetadata='Generated planner preserves parent metadata verbatim; this receipt supplies current derivation attribution.')
    with (out / 'derivation.json').open('x') as stream:
        json.dump(receipt, stream, indent=2)
        stream.write('\n')
    derivation = identity(out / 'derivation.json')
    with (out / 'baseline/derivation.json').open('xb') as stream:
        stream.write((out / 'derivation.json').read_bytes())
    subset['provenance'] = dict(path='derivation.json', sha256=derivation['sha256'], bytes=derivation['bytes'])
    with (out / 'baseline/manifest.json').open('x') as stream:
        json.dump(subset, stream, indent=2)
        stream.write('\n')
    assert [identity(x)['sha256'] for x in [PARENT, WORKER, RUNNER]] == [PARENT_SHA, WORKER_SHA, RUNNER_SHA]
    print(json.dumps(dict(complete=True, targetExecuted=False,
                         planner=str(out / 'planner.py'), receipt=str(out / 'derivation.json'),
                         baseline=str(out / 'baseline/manifest.json'))))


if __name__ == '__main__':
    main()
