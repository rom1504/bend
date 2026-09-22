#!/usr/bin/env python3
"""Preserve the completed P5-002 focused gates; never rerun a compiler."""
import gzip, hashlib, io, json, pathlib, tarfile

ROOT = pathlib.Path(__file__).resolve().parents[3]
OUT = pathlib.Path(__file__).resolve().parent
sha = lambda data: hashlib.sha256(data).hexdigest()
tree = ROOT / 'selfhost/build/phase5/development'
files = sorted(p for p in tree.rglob('*') if p.is_file())
files += sorted((ROOT / 'selfhost/tools/development').glob('*.mjs'))
files += [ROOT / 'selfhost/tests/conformance/development.test.mjs']
archive = OUT / 'raw.tar.gz'
if archive.exists() or (OUT / 'manifest.json').exists():
    raise SystemExit('Refusing to replace a preserved archive')
members = []
with archive.open('xb') as raw, gzip.GzipFile(fileobj=raw, mode='wb', mtime=0) as zipped:
    with tarfile.open(fileobj=zipped, mode='w|') as tar:
        for file in files:
            data = file.read_bytes()
            relative = str(file.relative_to(ROOT))
            entry = tarfile.TarInfo(relative)
            entry.size, entry.mode, entry.mtime = len(data), 0o644, 0
            tar.addfile(entry, io.BytesIO(data))
            members.append({'path': relative, 'bytes': len(data), 'sha256': sha(data)})
expected = {r['path']: r for r in members}
with tarfile.open(archive, 'r:gz') as tar:
    actual = tar.getmembers()
    assert len(actual) == len(expected)
    for item in actual:
        assert item.isfile() and not pathlib.PurePosixPath(item.name).is_absolute()
        assert '..' not in pathlib.PurePosixPath(item.name).parts
        data = tar.extractfile(item).read()
        assert {'path': item.name, 'bytes': len(data), 'sha256': sha(data)} == expected[item.name]
manifest = {'kind': 'phase5-development-focused-evidence', 'archive': archive.name,
            'archiveBytes': archive.stat().st_size, 'archiveSha256': sha(archive.read_bytes()),
            'membersVerified': True, 'members': members,
            'externalRequirements': ['Recorded Node 24 binary and platform tools',
                                     'Pinned upstream checkout at recorded canonical path'],
            'scope': 'Preserved historical focused gates, not a new bootstrap or broad conformance proof.'}
(OUT / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
print(json.dumps({k: v for k, v in manifest.items() if k != 'members'}))
