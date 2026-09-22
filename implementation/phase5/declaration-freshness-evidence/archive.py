#!/usr/bin/env python3
"""Archive completed P5-010 evidence without compiler execution."""
import gzip, hashlib, io, json, pathlib, tarfile
ROOT = pathlib.Path(__file__).resolve().parents[3]
OUT = pathlib.Path(__file__).resolve().parent
sha = lambda b: hashlib.sha256(b).hexdigest()
run = ROOT / 'selfhost/build/phase5/declaration-freshness'
baseline = ROOT / 'selfhost/build/phase5/integration/attempt-01'
files = [p for p in run.rglob('*') if p.is_file()]
files += [p for p in (baseline / 'snapshot').rglob('*') if p.is_file()]
files += [baseline / n for n in ['attempt.json', 'api.mjs', 'api.mjs.bootstrap.json', 'build.json']]
files += [p for p in (ROOT / 'selfhost/tests/frontend/phase5-freshness').rglob('*') if p.is_file()]
files += [ROOT / 'selfhost/tests/frontend/phase5-freshness-audit.py']
archive = OUT / 'raw.tar.gz'
if archive.exists() or (OUT / 'manifest.json').exists():
    raise SystemExit('Refusing to overwrite preserved evidence')
members = []
with archive.open('xb') as raw, gzip.GzipFile(fileobj=raw, mode='wb', mtime=0) as stream:
    with tarfile.open(fileobj=stream, mode='w|') as tar:
        for file in sorted(set(files)):
            data = file.read_bytes(); relative = str(file.relative_to(ROOT))
            info = tarfile.TarInfo(relative); info.size = len(data); info.mode = 0o644
            tar.addfile(info, io.BytesIO(data))
            members.append({'path': relative, 'bytes': len(data), 'sha256': sha(data)})
expected = {row['path']: row for row in members}
with tarfile.open(archive, 'r:gz') as tar:
    actual = tar.getmembers(); assert len(actual) == len(expected)
    for item in actual:
        assert item.isfile() and not pathlib.PurePosixPath(item.name).is_absolute()
        assert '..' not in pathlib.PurePosixPath(item.name).parts
        data = tar.extractfile(item).read()
        assert {'path': item.name, 'bytes': len(data), 'sha256': sha(data)} == expected[item.name]
manifest = {'kind': 'phase5-declaration-freshness-evidence', 'archive': archive.name,
            'bytes': archive.stat().st_size, 'sha256': sha(archive.read_bytes()),
            'membersVerified': True, 'members': members,
            'externalRequirements': ['Recorded Node binary and platform tools',
                                     'Pinned upstream checkout at recorded canonical path'],
            'omission': 'No run-directory files omitted. Pinned checkout and Node are external requirements.'}
(OUT / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
print(json.dumps({k: v for k, v in manifest.items() if k != 'members'}))
