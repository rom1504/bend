#!/usr/bin/env python3
"""Retain P5-020 attempts and final causal/semantic/cost evidence."""
import gzip, hashlib, io, json, pathlib, tarfile
ROOT = pathlib.Path(__file__).resolve().parents[3]
OUT = pathlib.Path(__file__).resolve().parent
RUN = ROOT / 'selfhost/build/phase5/imported-freshness'
sha = lambda data: hashlib.sha256(data).hexdigest()
audit = json.loads((RUN / 'audit.json').read_text())
cost = json.loads((RUN / 'cost-01/report.json').read_text())
assert audit['complete'] and cost['complete'] and cost['inputsVerified']
files = {p for p in RUN.rglob('*') if p.is_file()}
external = []
def retain(item):
    p = pathlib.Path(item['file'])
    if 'canonicalPath' in item:
        assert str(p.resolve()) == item['canonicalPath'], p
    assert sha(p.read_bytes()) == item['sha256'], p
    try:
        p.relative_to(ROOT)
    except ValueError:
        external.append(item)
    else:
        files.add(p)
for item in cost['inputs'] + audit['inputs']:
    retain(item)
for file in [RUN / 'baseline-final/paired.json', RUN / 'candidate-final/selected/paired.json']:
    paired = json.loads(file.read_text())
    for side in ['candidate', 'reference']:
        rawfile = pathlib.Path(paired['attempts'][side]['file'])
        raw = json.loads(rawfile.read_text())
        for name, digest in raw['inputHashes'].items():
            retain({'file': name, 'canonicalPath': raw['inputPaths'][name], 'sha256': digest})
for reportfile in RUN.rglob('api.mjs.bootstrap.json'):
    report = json.loads(reportfile.read_text())
    for item in report['provenance']['inputs']:
        retain(item)
files.add(ROOT / 'selfhost/tests/frontend/phase5-imported-freshness-audit.py')
files.update(p for p in (ROOT / 'selfhost/tests/frontend/phase5-imported-freshness').rglob('*') if p.is_file())
archive = OUT / 'raw.tar.gz'
assert not archive.exists()
members = []
with archive.open('xb') as raw, gzip.GzipFile(fileobj=raw, mode='wb', mtime=0) as zipped:
    with tarfile.open(fileobj=zipped, mode='w|') as tar:
        for p in sorted(files):
            data = p.read_bytes(); name = str(p.relative_to(ROOT))
            info = tarfile.TarInfo(name); info.size = len(data); info.mode = 0o644
            tar.addfile(info, io.BytesIO(data))
            members.append({'path': name, 'bytes': len(data), 'sha256': sha(data)})
index = {m['path']: m for m in members}
with tarfile.open(archive, 'r:gz') as tar:
    actual = tar.getmembers(); assert len(actual) == len(index)
    for item in actual:
        assert item.isfile() and not pathlib.PurePosixPath(item.name).is_absolute()
        assert '..' not in pathlib.PurePosixPath(item.name).parts
        data = tar.extractfile(item).read()
        assert index[item.name] == {'path': item.name, 'bytes': len(data), 'sha256': sha(data)}
manifest = {'kind': 'phase5-imported-freshness-evidence', 'archive': archive.name,
            'bytes': archive.stat().st_size, 'sha256': sha(archive.read_bytes()),
            'membersVerified': True, 'members': members, 'external': external,
            'prerequisites': 'Recorded Node/Linux tools and original pinned Git metadata remain external. Historical fixtures require restoring their retained version; no new provenance is fabricated.'}
(OUT / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
print(json.dumps({k: v for k, v in manifest.items() if k not in ['members', 'external']}))
