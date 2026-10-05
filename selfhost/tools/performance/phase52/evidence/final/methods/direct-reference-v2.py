#!/usr/bin/env python3
"""Relabel exact checked direct06 output as the next experiment's baseline."""
import argparse
import json
from pathlib import Path
import shutil
import sys

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent / 'programs'))
from support import identity, save
from run import load_bundle


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--direct', type=Path, required=True)
    p.add_argument('--reference', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    assert not a.out.exists()
    profile_file = HERE / 'intrinsic-profile-v1.json'
    profile = json.loads(profile_file.read_text())
    assert identity(profile_file)['sha256'] == '11e41bca09263752a3bec9500d0cc8e99731bd614398d3631a8206cdf9f637d9'
    catalog_file = (HERE / profile['catalog']['path']).resolve()
    catalog = json.loads(catalog_file.read_text())
    assert identity(catalog_file)['sha256'] == profile['catalog']['sha256']
    ids = [c['id'] for c in profile['cases']]
    by_id = {c['id']: c for c in catalog['cases']}
    selected = [by_id[name] for name in ids]
    assert all(c['source'] == by_id[c['id']]['source'] and c['point'] == by_id[c['id']]['point'] for c in profile['cases'])
    inputs = [identity(f) for f in [__file__, profile_file, catalog_file, HERE.parent / 'programs/run.py', HERE.parent / 'programs/support.py']]
    previous = identity(HERE / 'direct-reference.py')
    assert previous['sha256'] == 'a12d092773ce8d816513237fe3b453fa3a47284e397026be78931a4d09624e37'
    inputs.append(previous)
    direct = load_bundle(a.direct, catalog, profile['catalog']['sha256'], selected, ['candidate'], inputs)
    reference = load_bundle(a.reference, catalog, profile['catalog']['sha256'], selected, ['baseline', 'typescript'], inputs)
    compiler = direct['roles']['candidate']['compiler']
    assert compiler['backend'] == 'direct' and compiler['callingContract'] == profile['callingContract']
    assert compiler['api']['sha256'] == '472da578ff9066413f0a2b8e5c0053b5bc26eae8c3cb343b5b0cbb2a62c03a3a'
    assert compiler['directRuntime']['sha256'] == '417d2d47f98116d4eae889ff53132d9255c8a0ffaf047dd497b877f2df0c188a'
    a.out.mkdir(parents=True, exist_ok=False)
    (a.out / 'modules').mkdir()
    rows, copied = [], set()
    for case in selected:
        modules = {}
        for role, source_role, bundle, source_manifest in [('baseline','candidate',direct,a.direct), ('typescript','typescript',reference,a.reference)]:
            entry = bundle['points'][case['id']][source_role]
            assert 'archive' not in json.loads(source_manifest.read_text()), 'This small remapper requires verified loose modules'
            source = source_manifest.resolve().parent / entry['path']
            target = a.out / 'modules' / (role + '-' + entry['sha256'] + '.mjs')
            if target not in copied:
                shutil.copyfile(source, target)
                copied.add(target)
            actual = identity(target)
            assert actual['sha256'] == entry['sha256'] and actual['bytes'] == entry['bytes']
            modules[role] = dict(path=str(target.relative_to(a.out)), sha256=actual['sha256'], bytes=actual['bytes'])
        rows.append(dict(id=case['id'], sourceSha256=case['source']['sha256'], point=case['point'], modules=modules))
    roles = dict(baseline=dict(direct['roles']['candidate'], label='Phase52 checked direct06 predecessor; exact saved output relabeled baseline'), typescript=reference['roles']['typescript'])
    for item in inputs:
        assert identity(item['path']) == item
    provenance = dict(kind='phase52-direct06-reference-role-remap', complete=True, inputs=inputs, profile=identity(profile_file),
        directManifest=identity(a.direct), typescriptManifest=identity(a.reference),
        scope='Data-only exact module copies. Direct06 candidate becomes baseline; TS bytes are retained. No execution, changed ABI, historical timing relabel or new performance claim.')
    save(a.out / 'provenance.json', provenance)
    save(a.out / 'manifest.json', dict(kind='bend-program-bundle', schemaVersion=1, complete=True,
        upstreamCommit=catalog['upstreamCommit'], catalogSha256=profile['catalog']['sha256'], comparisonContract=profile['callingContract'],
        roles=roles, cases=rows, roleRemap=identity(a.out / 'provenance.json')))
    checks = []
    load_bundle(a.out / 'manifest.json', catalog, profile['catalog']['sha256'], selected, ['baseline','typescript'], checks)
    print(json.dumps(dict(complete=True, cases=len(rows), modules=len(copied), manifest=identity(a.out / 'manifest.json'))))


if __name__ == '__main__':
    main()
