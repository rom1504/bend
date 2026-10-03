#!/usr/bin/env python3
"""Freeze a complete actual checked candidate; run no compiler or target program.

Archive members are streamed, capped, then independently reopened and hashed.
Runtime bundle paths are relative; original absolute receipt paths remain history.
"""
import argparse
import gzip
import hashlib
import json
from pathlib import Path
import shutil
import sys
import tarfile

HERE = Path(__file__).resolve().parent
PROGRAMS = HERE.parent / 'programs'
sys.path.insert(0, str(PROGRAMS))
from run import load_bundle, relative_path
from prepare import checked_source, observe_row
from support import save

MAX_FILE = 64 * 1024**2
MAX_TOTAL = 512 * 1024**2
MAX_MEMBERS = 4096


def identity(file):
    file = Path(file).resolve()
    h = hashlib.sha256()
    with file.open('rb') as stream:
        for block in iter(lambda: stream.read(2**20), b''):
            h.update(block)
    return dict(path=str(file), sha256=h.hexdigest(), bytes=file.stat().st_size)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--from', dest='origin', type=Path, required=True, help='Full maintained preparation manifest')
    p.add_argument('--attempt', type=Path, required=True, help='Selected checked compiler attempt')
    p.add_argument('--catalog', type=Path, default=HERE.parent / 'phase37/catalog.json')
    p.add_argument('--out', type=Path, required=True, help='New directory, normally phase41/current')
    a = p.parse_args()
    origin = a.origin.resolve(); catalog_file = a.catalog.resolve(); out = a.out.resolve()
    assert not out.exists(), 'Output must be new'
    assert not out.is_relative_to(origin.parent), 'Output cannot be inside acquisition'
    inputs, observed = [], {}

    def keep(file, expected=None):
        item = identity(file)
        if expected:
            assert item['sha256'] == expected['sha256'], file
            assert 'bytes' not in expected or item['bytes'] == expected['bytes'], file
        assert item['path'] not in observed or observed[item['path']] == item, file
        observed[item['path']] = item
        return item

    def pointer(row):
        file = row.get('canonicalPath', row.get('file', row.get('path')))
        assert file and Path(file).is_absolute()
        return keep(file, row)

    def read(file, expected=None):
        item = keep(file, expected)
        return json.loads(Path(item['path']).read_text())

    for file in [__file__, PROGRAMS/'run.py', PROGRAMS/'support.py', PROGRAMS/'prepare.py']:
        keep(file)
    catalog, manifest = read(catalog_file), read(origin)
    catalog_sha = keep(catalog_file)['sha256']
    assert catalog['kind'] == 'bend-program-catalog' and len(catalog['cases']) == 45
    expected_ids = {case['id'] for case in catalog['cases']}
    assert len(expected_ids) == 45
    assert len(manifest['cases']) == 45 and {row['id'] for row in manifest['cases']} == expected_ids
    assert 'archive' not in manifest and 'prototype' not in manifest, 'Actual unmodified preparation required'
    bundle = load_bundle(origin, catalog, catalog_sha, catalog['cases'], ['candidate'], inputs)
    for item in inputs:
        keep(item['path'], item)
    compiler = bundle['roles']['candidate']['compiler']
    assert compiler['kind'] == 'checked-development-attempt'
    assert compiler['upstreamCommit'] == catalog['upstreamCommit']
    attempt_file = a.attempt/'attempt.json' if a.attempt.is_dir() else a.attempt
    attempt = read(attempt_file)
    assert attempt['checked'] is True and attempt['artifactKind'] == 'derived-b1'
    for key in ['api', 'runtime', 'base']:
        assert pointer(compiler[key]) == pointer(attempt[key]), key
    for row in attempt['snapshot']['sources']:
        pointer(row['frozen'])
    driver = next(row['frozen'] for row in attempt['snapshot']['sources']
                  if Path(row['frozen']['file']).relative_to(attempt['snapshot']['root']).as_posix() == 'tools/typed-driver.mjs')
    assert pointer(compiler['driver']) == pointer(driver)
    bootstrap = read(pointer(attempt['bootstrapReport'])['path'])
    assert compiler['sourceSha256'] == bootstrap['sourceSha256']
    assert bootstrap['revision'] == catalog['upstreamCommit']
    node = pointer(attempt['node'])
    preparation_file = relative_path(origin.parent, manifest['preparation']['path'])
    preparation = read(preparation_file, manifest['preparation'])
    assert preparation['kind'] == 'bend-program-preparation' and preparation['complete'] is True
    assert pointer(preparation['catalog']) == keep(catalog_file)
    for row in [preparation['producer'], preparation['worker'], preparation['supervisor'], preparation['node'], *preparation['verifiers']]:
        pointer(row)
    assert pointer(preparation['node']) == node
    expected_sources = {}
    for case in catalog['cases']:
        source = checked_source(case, catalog_file)
        keep(source, case['source'])
        expected_sources[case['source']['sha256']] = source
    assert len(preparation['sources']) == len(expected_sources), 'Full source acquisition required'
    emitted = {}
    for row in preparation['sources']:
        assert row['process']['complete'] is True and row['process']['returncode'] == 0
        receipt_file = relative_path(origin.parent, row['emission']['path'])
        receipt = read(receipt_file, row['emission'])
        assert receipt['kind'] == 'bend-program-checked-emission' and receipt['complete'] is True
        assert receipt['observation']['checked'] is True and receipt['observation']['typeAccepted'] is True
        assert receipt['observation']['status'] == 'ok' and receipt['compiler'] == compiler
        assert pointer(receipt['attempt']) == keep(attempt_file)
        assert pointer(receipt['catalog']) == keep(catalog_file)
        assert receipt['node'] == attempt['node']['version']
        for entry in [receipt['producer'], *receipt['verifiers']]:
            pointer(entry)
        source = pointer(receipt['input']); module = pointer(receipt['output'])
        assert source == pointer(row['source'])
        assert source['sha256'] in expected_sources and source['sha256'] not in emitted
        assert source == keep(expected_sources[source['sha256']])
        assert Path(module['path']).is_relative_to(origin.parent)
        emitted[source['sha256']] = dict(module=module, receipt=keep(receipt_file))
    assert set(emitted) == set(expected_sources)
    adapters = {}
    for row in preparation['adapters']:
        assert row['kind'] == 'complete-generic-row-serialization'
        raw = keep(relative_path(origin.parent, row['raw']['path']), row['raw'])
        adapted = keep(relative_path(origin.parent, row['adapted']['path']), row['adapted'])
        assert pointer(row['producer']) == pointer(preparation['producer'])
        assert observe_row(Path(raw['path']).read_text(), typescript=False).encode() == Path(adapted['path']).read_bytes()
        assert raw['sha256'] not in adapters or adapters[raw['sha256']] == adapted
        adapters[raw['sha256']] = adapted
    files, entries = {}, {}
    total = 0

    def add(name, file):
        nonlocal total
        name = Path(name).as_posix()
        assert not Path(name).is_absolute() and '..' not in Path(name).parts
        file = Path(file)
        assert not file.is_symlink() and file.is_file()
        item = keep(file)
        assert 0 <= item['bytes'] <= MAX_FILE
        if name in files:
            assert entries[name]['sha256'] == item['sha256']
            return entries[name]
        total += item['bytes']
        assert total <= MAX_TOTAL and len(files) < MAX_MEMBERS
        files[name] = file
        entries[name] = dict(path=name, bytes=item['bytes'], sha256=item['sha256'])
        return entries[name]

    # Keep complete acquisition receipts, consumed tools, checked output and logs.
    for file in sorted(origin.parent.rglob('*')):
        assert not file.is_symlink(), 'Acquisition symlink'
        if file.is_file():
            add('acquisition/'+file.relative_to(origin.parent).as_posix(), file)
    add('consumed/freeze-candidate.py', Path(__file__))
    add('provenance/attempt.json', attempt_file)
    add('provenance/bootstrap.json', pointer(attempt['bootstrapReport'])['path'])
    add('provenance/catalog.json', catalog_file)
    for sha, source in sorted(expected_sources.items()):
        add('sources/'+sha+'.bend', source)
    cases = []
    for case in catalog['cases']:
        ready = bundle['points'][case['id']]['candidate']
        module = keep(relative_path(origin.parent, ready['path']), ready)
        raw = emitted[case['source']['sha256']]['module']
        expected = adapters[raw['sha256']] if case.get('adapter') == 'generic-row' else raw
        assert case.get('adapter') in (None, 'generic-row')
        assert module == expected, 'Module not linked to checked emission: '+case['id']
        entry = add('candidate/modules/'+module['sha256']+'.mjs', module['path'])
        cases.append(dict(id=case['id'], sourceSha256=case['source']['sha256'], point=case['point'], modules={'candidate':entry}))
    out.mkdir(parents=True, exist_ok=False)
    provenance = dict(kind='phase41-frozen-checked-candidate', complete=True,
        producer=keep(__file__), catalog=keep(catalog_file), preparation=keep(preparation_file),
        manifest=keep(origin), attempt=keep(attempt_file), compiler=compiler,
        scope='Byte-exact actual checked candidate modules; no JavaScript substitution, compilation or execution. Complete acquisition receipts and logs retained. Absolute historical receipt paths are not runtime dependencies.',
        bounds=dict(maxFileBytes=MAX_FILE, maxTotalBytes=MAX_TOTAL, maxMembers=MAX_MEMBERS),
        inputs=list(observed.values()))
    save(out/'provenance.json', provenance)
    add('provenance.json', out/'provenance.json')
    archive = out/'programs.tar.gz'
    with archive.open('xb') as stream, gzip.GzipFile(fileobj=stream, mode='wb', filename='', mtime=0) as gz:
        with tarfile.open(fileobj=gz, mode='w|') as tar:
            for name, file in sorted(files.items()):
                info = tarfile.TarInfo(name); info.size=entries[name]['bytes']; info.mode=0o644
                info.mtime=0; info.uid=info.gid=0; info.uname=info.gname=''
                with file.open('rb') as source:
                    tar.addfile(info, source)
    seen, reopened_total = set(), 0
    with tarfile.open(archive, 'r|gz') as tar:
        for member in tar:
            assert member.isfile() and member.name in entries and member.name not in seen
            assert member.size == entries[member.name]['bytes'] and member.size <= MAX_FILE
            seen.add(member.name); reopened_total += member.size
            assert reopened_total <= MAX_TOTAL and len(seen) <= MAX_MEMBERS
            h = hashlib.sha256()
            with tar.extractfile(member) as stream:
                for block in iter(lambda: stream.read(2**20), b''):
                    h.update(block)
            assert h.hexdigest() == entries[member.name]['sha256'], member.name
    assert seen == set(entries) and reopened_total == total
    for file, expected in observed.items():
        assert identity(file) == expected, 'Input changed during freeze: '+file
    archive_id = identity(archive); archive_id['path'] = archive.name
    provenance_id = identity(out/'provenance.json'); provenance_id['path'] = 'provenance.json'
    roles = {'candidate':dict(bundle['roles']['candidate'], label='Phase41 checked candidate (frozen actual acquisition)')}
    save(out/'manifest.json', dict(kind='bend-program-bundle', schemaVersion=1, complete=True,
        upstreamCommit=catalog['upstreamCommit'], catalogSha256=catalog_sha, roles=roles, cases=cases,
        archive=archive_id, provenance=provenance_id,
        preservation=dict(members=len(entries), uncompressedBytes=total, reopenedVerified=True, byteExact=True)))
    # The maintained reader must accept every frozen point from the portable archive.
    final_inputs = []
    load_bundle(out/'manifest.json', catalog, catalog_sha, catalog['cases'], ['candidate'], final_inputs)
    print(json.dumps(dict(complete=True, checked=True, cases=len(cases), members=len(entries),
        api=compiler['api']['sha256'], archiveBytes=archive.stat().st_size, manifest=str(out/'manifest.json'))))


if __name__ == '__main__':
    main()
