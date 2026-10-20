#!/usr/bin/env python3
"""Retain exact gzip bytes for the superseded catalogue-only QBE acquisition."""
from pathlib import Path
import gzip
import hashlib
import json

ROOT = Path(__file__).resolve().parents[5]
SOURCE = ROOT / 'selfhost/build/phase114/catalogue-full01/program.ssa'
OUT = ROOT / 'selfhost/build/phase114/catalogue-qbe-archive01'
EXPECTED = '9947ecb09cefc520615729ead1590205d37025b5b50ca31b71303e949e2f1dd0'


def pin(path):
    digest = hashlib.sha256()
    with path.open('rb') as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b''):
            digest.update(block)
    return dict(file=str(path.resolve()), bytes=path.stat().st_size,
                sha256=digest.hexdigest())


def main():
    receipt = json.loads((SOURCE.parent / 'report.json').read_text())
    original = pin(SOURCE)
    assert receipt['complete'] and receipt['product'] == original
    assert original['sha256'] == EXPECTED and original['bytes'] == 60356569
    assert not OUT.exists()
    OUT.mkdir()
    archive = OUT / 'program.ssa.gz'
    with SOURCE.open('rb') as source, archive.open('xb') as raw:
        with gzip.GzipFile(filename='', mode='wb', fileobj=raw,
                           compresslevel=6, mtime=0) as compressed:
            for block in iter(lambda: source.read(1024 * 1024), b''):
                compressed.write(block)
    digest = hashlib.sha256()
    count = 0
    with gzip.open(archive, 'rb') as restored:
        for block in iter(lambda: restored.read(1024 * 1024), b''):
            digest.update(block)
            count += len(block)
    assert digest.hexdigest() == EXPECTED and count == original['bytes']
    assert pin(SOURCE) == original
    result = dict(complete=True, original=original, archive=pin(archive),
                  method=pin(Path(__file__)), roundTripVerified=True,
                  scope='Only superseded catalogue QBE; final candidates and runtime remain intact.',
                  restore='Decompress the retained gzip into original.file; verify original SHA256 and byte count before use.')
    (OUT / 'report.json').write_text(json.dumps(result, indent=2) + '\n')
    SOURCE.unlink()
    print(json.dumps(dict(bytesReclaimed=original['bytes'] - result['archive']['bytes'],
                          receipt=str(OUT / 'report.json'))))


if __name__ == '__main__':
    main()
