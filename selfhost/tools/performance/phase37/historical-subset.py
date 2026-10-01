#!/usr/bin/env python3
"""Bind the unchanged historical15 catalog to already checked Phase37 output.

No compiler, test, measurement or module transformation is executed. Original
checked receipts are copied byte-for-byte; their output paths still identify
the original acquisition. Only the bundle's catalog membership changes.
"""
import argparse
import copy
import hashlib
import json
from pathlib import Path
import shutil
import sys

HERE = Path(__file__).resolve().parent
PROGRAMS = HERE.parent/'programs'
sys.path.insert(0, str(PROGRAMS))
from run import load_bundle, relative_path

HISTORICAL = '32833e4c2372983361b2c9f34a0967cfe38ce0e1052ac9abaab41def3179cfde'


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('candidate', type=Path)
    ap.add_argument('out', type=Path)
    ap.add_argument('--catalog', type=Path, default=HERE/'catalog.json')
    a = ap.parse_args()
    file, out = a.candidate.resolve(), a.out.resolve()
    if file.is_dir():
        file = file/'manifest.json'
    observed = {}

    def identity(path):
        path = Path(path).resolve()
        digest = hashlib.sha256()
        with path.open('rb') as stream:
            for block in iter(lambda: stream.read(2**20), b''):
                digest.update(block)
        return dict(file=str(path), sha256=digest.hexdigest(), bytes=path.stat().st_size)

    def keep(path, ref=None):
        row = identity(path)
        if ref:
            assert row['sha256'] == ref['sha256'], row['file']
            assert 'bytes' not in ref or row['bytes'] == ref['bytes'], row['file']
        observed[row['file']] = row
        return row

    def read(path):
        keep(path)
        return json.loads(Path(path).read_text())

    def verify(ref, base=file.parent):
        name = Path(ref.get('file', ref.get('path')))
        path = name if name.is_absolute() else relative_path(base, str(name))
        keep(path, ref)
        return path

    def save(path, data):
        path.write_text(json.dumps(data, indent=2)+'\n')

    keep(__file__)
    for name in ['run.py', 'support.py']:
        keep(PROGRAMS/name)
    old_file, new_file = PROGRAMS/'catalog.json', a.catalog.resolve()
    old, new, bundle = read(old_file), read(new_file), read(file)
    assert keep(old_file)['sha256'] == HISTORICAL
    assert old['upstreamCommit'] == new['upstreamCommit'] == bundle['upstreamCommit']
    assert len(old['cases']) == 15 and len(new['cases']) == 45
    assert 'archive' not in bundle, 'Use the direct checked acquisition, not a repacked reference'
    assert set(bundle['roles']) == {'candidate'}
    compiler = bundle['roles']['candidate']['compiler']
    assert compiler['kind'] == 'checked-development-attempt' and compiler['artifact'] == 'derived-b1'
    for key in ['api', 'runtime', 'base', 'driver']:
        verify(compiler[key])
    by_id = {c['id']: c for c in new['cases']}
    assert len(by_id) == len(new['cases'])
    selected = []
    source_hashes = set()
    mapping = []
    for historical in old['cases']:
        current = by_id[historical['id']]
        assert current['source']['sha256'] == historical['source']['sha256']
        assert current['source']['bytes'] == historical['source']['bytes']
        assert current['point'] == historical['point'], historical['id']
        before = verify(historical['source'], old_file.parent)
        after = verify(current['source'], new_file.parent)
        mapping.append(dict(id=historical['id'], historical=keep(before), acquired=keep(after),
                            point=historical['point']))
        selected.append(current)
        source_hashes.add(current['source']['sha256'])
    checked_inputs = []
    load_bundle(file, new, keep(new_file)['sha256'], selected, ['candidate'], checked_inputs)
    for row in checked_inputs:
        keep(row['path'], row)
    preparation_file = verify(bundle['preparation'])
    preparation = read(preparation_file)
    assert preparation['kind'] == 'bend-program-preparation' and preparation['complete']
    sources = [row for row in preparation['sources'] if row['source']['sha256'] in source_hashes]
    assert len(sources) == len(source_hashes) == 13
    assert {row['source']['sha256'] for row in sources} == source_hashes
    copies = {}

    def retain(name, ref):
        source = relative_path(file.parent, name)
        keep(source, ref)
        assert name not in copies or copies[name]['sha256'] == ref['sha256']
        copies[name] = dict(ref)

    for row in sources:
        verify(row['source'])
        receipt_file = verify(row['emission'])
        receipt = read(receipt_file)
        assert receipt['kind'] == 'bend-program-checked-emission' and receipt['complete']
        observation = receipt['observation']
        assert observation['checked'] and observation['typeAccepted'] and observation['exitCode'] == 0
        assert receipt['compiler'] == compiler
        assert receipt['input']['sha256'] == row['source']['sha256']
        for key in ['attempt', 'input', 'output', 'producer']:
            verify(receipt[key])
        attempt = read(verify(receipt['attempt']))
        assert attempt['checked'] and attempt['artifactKind'] == 'derived-b1'
        for key in ['api', 'runtime', 'base']:
            assert attempt[key]['sha256'] == compiler[key]['sha256']
        raw_name = Path(row['emission']['path']).with_suffix('').as_posix()
        retain(raw_name, receipt['output'])
        retain(row['emission']['path'], row['emission'])
    cases = {row['id']: row for row in bundle['cases']}
    selected_cases = [copy.deepcopy(cases[row['id']]) for row in old['cases']]
    selected_hashes = set()
    for row in selected_cases:
        entry = row['modules']['candidate']
        retain(entry['path'], entry)
        selected_hashes.add(entry['sha256'])
    adapters = [copy.deepcopy(row) for row in preparation.get('adapters', [])
                if row['adapted']['sha256'] in selected_hashes]
    assert len(adapters) == 1 and adapters[0]['kind'] == 'complete-generic-row-serialization'
    for row in adapters:
        for key in ['raw', 'adapted']:
            retain(row[key]['path'], row[key])
        verify(row['producer'])
    out.mkdir(parents=True, exist_ok=False)
    for name, ref in copies.items():
        target = relative_path(out, name)
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(relative_path(file.parent, name), target)
        keep(target, ref)
    derived_preparation = dict(kind='phase37-historical-catalog-subset-preparation', complete=True,
        executed=False, producer=keep(__file__), parentBundle=keep(file),
        parentPreparation=keep(preparation_file), acquisitionCatalog=keep(new_file),
        targetCatalog=keep(old_file), mapping=mapping, sources=copy.deepcopy(sources), adapters=adapters,
        scope='Metadata-only subset: same checked API, source bytes, points, raw/observed module bytes and checked emission receipts. Process observations in sources are retained original acquisitions, not new executions.')
    for row in observed.values():
        assert identity(row['file']) == row, row['file']
    derived_preparation['inputs'] = list(observed.values())
    save(out/'preparation.json', derived_preparation)
    prep = identity(out/'preparation.json')
    manifest = dict(kind='bend-program-bundle', schemaVersion=1, complete=True,
        upstreamCommit=bundle['upstreamCommit'], catalogSha256=HISTORICAL,
        roles=copy.deepcopy(bundle['roles']), cases=selected_cases,
        preparation=dict(path='preparation.json', sha256=prep['sha256'], bytes=prep['bytes']))
    save(out/'manifest.json', manifest)
    print(json.dumps(dict(complete=True, executed=False, cases=15, sources=13,
                         copiedFiles=len(copies), out=str(out), api=compiler['api']['sha256'])))


if __name__ == '__main__':
    main()
