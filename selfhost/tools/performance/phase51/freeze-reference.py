#!/usr/bin/env python3
"""Copy unchanged RNFA04 and TS programs into a fresh paired reference bundle."""
import hashlib
import json
import sys
import tarfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
out = Path(sys.argv[1]).resolve()
out.mkdir(parents=True, exist_ok=False)
inputs = []


def identity(path):
    path = Path(path).resolve()
    row = dict(file=str(path), bytes=path.stat().st_size,
               sha256=hashlib.sha256(path.read_bytes()).hexdigest())
    inputs.append(row)
    return row


identity(__file__)
roles, cases = {}, {}
catalog = ROOT / 'selfhost/tools/performance/phase37/catalog.json'
catalog_id = identity(catalog)
catalog_rows = {c['id']: c for c in json.loads(catalog.read_text())['cases']}
for file, old_role, role in [
        ('selfhost/tools/performance/phase48/current/manifest.json', 'candidate', 'baseline'),
        ('selfhost/tools/performance/phase48/baseline/manifest.json', 'typescript', 'typescript')]:
    file = ROOT / file
    identity(file)
    manifest = json.loads(file.read_text())
    assert manifest['complete'] and manifest['catalogSha256'] == catalog_id['sha256']
    archive = file.parent / manifest['archive']['path']
    archive_id = identity(archive)
    assert all(archive_id[k] == manifest['archive'][k] for k in ['bytes', 'sha256'])
    rows = {c['id']: c for c in manifest['cases']}
    assert set(rows) == set(catalog_rows)
    roles[role] = manifest['roles'][old_role]
    if role == 'baseline':
        assert roles[role]['compiler']['api']['sha256'] == '6f9d111aa68c19f3ce45b80785621d57c4d10efb12d50164f5cb0597bc952100'
    modules = {c['modules'][old_role]['path']: c['modules'][old_role] for c in rows.values()}
    found = set()
    with tarfile.open(archive, 'r:gz') as tar:
        for member in tar:
            if member.name not in modules:
                continue
            row = modules[member.name]
            assert member.isfile() and member.name not in found and member.size == row['bytes'] <= 64 * 2**20
            found.add(member.name)
            data = tar.extractfile(member).read()
            assert hashlib.sha256(data).hexdigest() == row['sha256']
            target = out / 'modules' / (row['sha256'] + '.mjs')
            target.parent.mkdir(exist_ok=True)
            if target.exists():
                assert target.read_bytes() == data
            else:
                target.write_bytes(data)
    assert found == set(modules)
    for name, row in rows.items():
        assert row['point'] == catalog_rows[name]['point'] and row['sourceSha256'] == catalog_rows[name]['source']['sha256']
        case = cases.setdefault(name, dict(id=name, point=row['point'], sourceSha256=row['sourceSha256'], modules={}))
        m = row['modules'][old_role]
        case['modules'][role] = dict(path='modules/' + m['sha256'] + '.mjs', bytes=m['bytes'], sha256=m['sha256'])
manifest = dict(kind='bend-program-bundle', schemaVersion=1, complete=True,
    upstreamCommit=manifest['upstreamCommit'], catalogSha256=catalog_id['sha256'], roles=roles, cases=list(cases.values()))
(out / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
(out / 'provenance.json').write_text(json.dumps(dict(complete=True, executed=False, inputs=inputs,
    scope='Exact unchanged installed RNFA04 baseline and pinned TS programs; metadata role mapping only.'), indent=2) + '\n')
print(json.dumps(dict(complete=True, cases=len(cases), out=str(out))))
