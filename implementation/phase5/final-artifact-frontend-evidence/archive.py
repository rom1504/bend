#!/usr/bin/env python3
"""Preserve final artifact observations and actual consumed bytes; no new bootstrap."""
import gzip, hashlib, io, json, pathlib, tarfile

ROOT = pathlib.Path(__file__).resolve().parents[3]
OUT = pathlib.Path(__file__).resolve().parent
RUN = ROOT / 'selfhost/build/phase5/final-artifact-frontend-01'
LAUNCH = ROOT / 'selfhost/build/phase5/final-artifact-frontend-launch'
sha = lambda data: hashlib.sha256(data).hexdigest()
report = json.loads((RUN / 'report.json').read_text())
assert report.get('finished'), 'Cannot archive a running attempt'
files = {p for directory in [RUN, LAUNCH] for p in directory.rglob('*') if p.is_file()}
external, identities = [], []

def retain(item):
    p = pathlib.Path(item['file'])
    assert str(p.resolve()) == item['canonicalPath'], p
    assert sha(p.read_bytes()) == item['sha256'], p
    identities.append(item)
    try:
        p.relative_to(ROOT)
    except ValueError:
        external.append(item)
    else:
        files.add(p)

for item in report['inputs']:
    retain(item)
for row in report['rows']:
    if row.get('observations'):
        retain(row['observations'])
        raw = json.loads(pathlib.Path(row['observations']['file']).read_text())
        for name, digest in raw['inputHashes'].items():
            retain({'file': name, 'canonicalPath': raw['inputPaths'][name], 'sha256': digest})
    for history in row.get('histories', []):
        retain(history['identity'])
    if row['complete']:
        assert row['workerHistoriesVerified'] and not row['differences']
        assert len(raw['results']) == 2756
if report['complete']:
    assert report['inputsVerified'] and len(report['rows']) == 2
    assert all(row['complete'] for row in report['rows'])
files.add(pathlib.Path(__file__).resolve())
archive = OUT / 'raw.tar.gz'
assert not archive.exists()
members = []
with archive.open('xb') as target, gzip.GzipFile(fileobj=target, mode='wb', mtime=0, filename='') as zipped:
    with tarfile.open(fileobj=zipped, mode='w|') as tar:
        for p in sorted(files):
            data = p.read_bytes()
            name = str(p.relative_to(ROOT))
            info = tarfile.TarInfo(name)
            info.size, info.mode = len(data), 0o644
            tar.addfile(info, io.BytesIO(data))
            members.append({'path': name, 'bytes': len(data), 'sha256': sha(data)})
index = {item['path']: item for item in members}
with tarfile.open(archive, 'r:gz') as tar:
    actual = tar.getmembers()
    assert len(actual) == len(index)
    for item in actual:
        assert item.isfile() and not pathlib.PurePosixPath(item.name).is_absolute()
        assert '..' not in pathlib.PurePosixPath(item.name).parts
        data = tar.extractfile(item).read()
        assert index[item.name] == {'path': item.name, 'bytes': len(data), 'sha256': sha(data)}
for item in members:
    assert sha((ROOT / item['path']).read_bytes()) == item['sha256'], item['path']
for item in identities:
    p = pathlib.Path(item['file'])
    assert str(p.resolve()) == item['canonicalPath'] and sha(p.read_bytes()) == item['sha256']
manifest = {
    'kind': 'phase5-final-artifact-frontend-evidence', 'complete': report['complete'],
    'newBootstrap': False, 'archive': archive.name, 'bytes': archive.stat().st_size,
    'sha256': sha(archive.read_bytes()), 'membersVerified': True, 'sourcesRechecked': True,
    'members': members, 'external': external,
    'scope': 'Actual final public H and maintained equality derivative frontend observations, including known strict failures and any retained incomplete attempt. Successful equivalence is distinct from full-language conformance.',
    'prerequisites': 'Historical absolute paths are preserved. Recorded Node/Linux tools and pinned upstream Git metadata remain external; restored bytes do not create a new checked build or relocate the protocol.'
}
(OUT / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
print(json.dumps({k: v for k, v in manifest.items() if k not in ['members', 'external']}))
