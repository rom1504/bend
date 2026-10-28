#!/usr/bin/env python3
"""Seal the completed retention receipts; no historical product archives copied."""
import gzip
import hashlib
import json
from pathlib import Path
import shutil
import tarfile
import time

ROOT = Path(__file__).resolve().parents[2]
SOURCES = [ROOT / 'selfhost/build-retention/2026-10-28',
           ROOT / 'selfhost/build/retention-smoke/native-guard']
OUT = ROOT / 'implementation/build-retention/evidence'


def digest(stream):
    h = hashlib.sha256()
    for chunk in iter(lambda: stream.read(1 << 20), b''):
        h.update(chunk)
    return h.hexdigest()


def pin(path):
    with path.open('rb') as stream:
        return dict(file=str(path.relative_to(ROOT)), bytes=path.stat().st_size,
                    sha256=digest(stream))


def main():
    started = time.time()
    assert shutil.disk_usage(ROOT).free > 1024**3
    paths = []
    for source in SOURCES:
        for path in sorted(source.rglob('*')):
            assert not path.is_symlink(), path
            if path.is_file():
                paths.append(path)
    assert sum(p.stat().st_size for p in paths) < 300 * 1024**2
    entries = [pin(p) for p in paths]
    OUT.mkdir(parents=True, exist_ok=False)
    archive = OUT / 'receipts.tar.gz'
    with archive.open('xb') as raw, gzip.GzipFile(fileobj=raw, mode='wb',
                                                 compresslevel=5, mtime=0) as zipped:
        with tarfile.open(fileobj=zipped, mode='w|') as tar:
            for path, entry in zip(paths, entries):
                info = tar.gettarinfo(str(path), arcname=entry['file'])
                assert info.isfile()
                with path.open('rb') as stream:
                    tar.addfile(info, stream)
    assert entries == [pin(p) for p in paths], 'Evidence changed during sealing'
    expected = {e['file']: e for e in entries}
    seen = set()
    with gzip.open(archive, 'rb') as zipped:
        with tarfile.open(fileobj=zipped, mode='r|') as tar:
            for member in tar:
                assert member.isfile() and member.name not in seen
                entry = expected[member.name]
                assert member.size == entry['bytes']
                with tar.extractfile(member) as stream:
                    assert digest(stream) == entry['sha256']
                seen.add(member.name)
        while zipped.read(1 << 20):
            pass
    assert seen == set(expected)
    # Bound Git transport objects; multipart transport is unnecessary below this.
    assert archive.stat().st_size < 48 * 1024**2
    report = dict(complete=True, kind='build-retention-recovery-evidence-v1',
                  method=pin(Path(__file__).resolve()), started=started,
                  finished=time.time(), archive=pin(archive), files=entries,
                  verifiedMembers=len(seen),
                  scope='Exact cleanup plans, journals, tests and native smoke. '
                        'Historical product bytes remain in their existing pinned archives; '
                        'this capsule does not duplicate them.')
    with (OUT / 'archive.json').open('x') as stream:
        json.dump(report, stream, indent=2)
        stream.write('\n')
    print(json.dumps({k: report[k] for k in ['complete', 'verifiedMembers', 'archive']}))


if __name__ == '__main__':
    main()
