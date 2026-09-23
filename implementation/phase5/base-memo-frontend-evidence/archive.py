#!/usr/bin/env python3
"""Archive completed P5-021 host comparison observations, histories and consumed inputs."""
import gzip, hashlib, io, json, pathlib, tarfile

ROOT = pathlib.Path(__file__).resolve().parents[3]
OUT = pathlib.Path(__file__).resolve().parent
RUN = ROOT / 'selfhost/build/phase5/base-memo-frontend'
report = json.loads((RUN / 'run-01/report.json').read_text())
assert report['complete'] and report['inputsVerified']
assert len(report['rows']) == 4
sha = lambda data: hashlib.sha256(data).hexdigest()
files = {p for p in RUN.rglob('*') if p.is_file()}
external = []

def retain(item):
    p = pathlib.Path(item['file'])
    assert str(p.resolve()) == item['canonicalPath'], p
    assert sha(p.read_bytes()) == item['sha256'], p
    try:
        p.relative_to(ROOT)
    except ValueError:
        external.append(item)
    else:
        files.add(p)

for item in report['inputs']:
    retain(item)
    if item['file'].endswith('.bootstrap.json'):
        proof = json.loads(pathlib.Path(item['file']).read_text())
        assert proof['provenance']['verifiedAfterBuild']
        for consumed in proof['provenance']['inputs']:
            retain(consumed)
for row in report['rows']:
    assert row['complete'] and row['workerHistoriesVerified']
    assert not row['differences'] and not row['fullConformance']
    retain(row['observations'])
    for history in row['histories']:
        retain(history['identity'])
    observed = json.loads(pathlib.Path(row['observations']['file']).read_text())
    assert len(observed['results']) == 2756
    for name, digest in observed['inputHashes'].items():
        p = pathlib.Path(name)
        assert str(p.resolve()) == observed['inputPaths'][name]
        assert sha(p.read_bytes()) == digest
        retain({'file': name, 'canonicalPath': str(p.resolve()), 'sha256': digest})

for name in ['base-memo-frontend.test.mjs', 'base-memo-frontend-smoke.mjs']:
    files.add(ROOT / 'selfhost/tools/performance/phase5' / name)
archive = OUT / 'raw.tar.gz'
assert not archive.exists()
members = []
with archive.open('xb') as raw, gzip.GzipFile(fileobj=raw, mode='wb', mtime=0) as zipped:
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
manifest = {
    'kind': 'phase5-base-memo-frontend-evidence',
    'archive': archive.name, 'bytes': archive.stat().st_size,
    'sha256': sha(archive.read_bytes()), 'membersVerified': True,
    'members': members, 'external': external,
    'scope': 'Four complete host-only frontend schedules and exact known failures; genuine checked compiler shared by both hosts. Explicit host provenance differs and is separately verified. No full-conformance pass.',
    'prerequisites': 'Recorded Node and Linux tools plus the pinned upstream Git metadata remain external. Restoring source bytes does not fabricate a checked build or clean pinned checkout.'
}
(OUT / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
print(json.dumps({k: v for k, v in manifest.items() if k not in ['members', 'external']}))
