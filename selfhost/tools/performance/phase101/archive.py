#!/usr/bin/env python3
"""Preserve the complete local experiment tree; verify every tar member."""
import hashlib
import json
from pathlib import Path
import tarfile

ROOT = Path(__file__).resolve().parents[4]
BUILD = ROOT / 'selfhost/build/phase101'
OUT = ROOT / 'implementation/phase101/evidence'


def digest(stream):
    result = hashlib.sha256()
    while True:
        block = stream.read(1024*1024)
        if not block: return result.hexdigest()
        result.update(block)


def main():
    OUT.mkdir(exist_ok=False)
    files = sorted(p for p in BUILD.rglob('*') if p.is_file())
    assert files and not any(p.is_symlink() for p in files)
    manifest = []
    for p in files:
        with p.open('rb') as f: sha = digest(f)
        manifest.append(dict(path=str(p.relative_to(ROOT)), bytes=p.stat().st_size,
                             mode=p.stat().st_mode & 0o777, sha256=sha))
    archive = OUT/'phase101.tar.xz'
    with tarfile.open(archive, 'w:xz', preset=3) as tar:
        for p in files: tar.add(p, arcname=str(p.relative_to(ROOT)), recursive=False)
    with tarfile.open(archive, 'r:xz') as tar:
        for expected, member in zip(manifest, tar):
            assert member.name == expected['path'] and member.isfile()
            assert member.size == expected['bytes'] and member.mode == expected['mode']
            with tar.extractfile(member) as f: assert digest(f) == expected['sha256']
        assert len(tar.getmembers()) == len(manifest)
    with archive.open('rb') as f: sha = digest(f)
    receipt = dict(complete=True, files=len(manifest), uncompressedBytes=sum(r['bytes'] for r in manifest),
                   archive=dict(path=str(archive.relative_to(ROOT)), bytes=archive.stat().st_size, sha256=sha),
                   everyMemberVerified=True)
    (OUT/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
    (OUT/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
    print(json.dumps(receipt))


if __name__=='__main__': main()
