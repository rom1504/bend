#!/usr/bin/env python3
"""Losslessly archive superseded Phase114 intermediate code; retain executable files."""
from pathlib import Path
import gzip
import hashlib
import json

ROOT = Path(__file__).resolve().parents[5]
OUT = ROOT / 'selfhost/build/phase114/superseded-code-archive01'
KEEP = ['final', 'scalar-operands', 'namespace', 'float-lanes', 'table-buffers']


def pin(path):
    h = hashlib.sha256()
    with path.open('rb') as stream:
        for block in iter(lambda: stream.read(1048576), b''):
            h.update(block)
    return dict(file=str(path.resolve()), bytes=path.stat().st_size, sha256=h.hexdigest())


def main():
    assert not OUT.exists()
    rows = []
    for source in sorted((ROOT / 'selfhost/build/phase111').glob('p114-*/program.*')):
        if source.suffix not in ['.s', '.o', '.ssa'] or any(x in source.parent.name for x in KEEP):
            continue
        receipt = source.parent / 'report.json'
        if source.is_symlink() or not receipt.is_file():
            continue
        record = json.loads(receipt.read_text())
        if not record.get('complete'):
            continue
        original = pin(source)
        key = 'object' if source.suffix == '.o' else 'product' if source.suffix == '.ssa' else None
        if key:
            assert record[key] == original, str(source)
        rows.append(dict(original=original, producer=pin(receipt)))
    assert rows and sum(r['original']['bytes'] for r in rows) < 100 * 1048576
    OUT.mkdir()
    plan = dict(method=pin(Path(__file__)), files=rows,
                scope='Superseded Phase114 QBE/assembly/object intermediates only; all executables, selected final/native, scalar/float prototypes, sources, APIs and runtimes retained.')
    (OUT / 'plan.json').write_text(json.dumps(plan, indent=2) + '\n')
    for row in rows:
        source = Path(row['original']['file'])
        archive = OUT / (source.parent.name + '-' + source.name + '.gz')
        with source.open('rb') as raw, archive.open('xb') as output:
            with gzip.GzipFile(filename='', mode='wb', fileobj=output, compresslevel=6, mtime=0) as z:
                for block in iter(lambda: raw.read(1048576), b''):
                    z.write(block)
        h = hashlib.sha256()
        count = 0
        with gzip.open(archive, 'rb') as restored:
            for block in iter(lambda: restored.read(1048576), b''):
                h.update(block)
                count += len(block)
        assert h.hexdigest() == row['original']['sha256'] and count == row['original']['bytes']
        assert pin(source) == row['original']
        row.update(archive=pin(archive), roundTripVerified=True)
    result = dict(plan, complete=True, files=rows,
                  restore='Decompress each archive into original.file and verify byte count/SHA256 before use. Actual gzip bytes remain local; hash-only evidence capsules are not replacements.')
    (OUT / 'report.json').write_text(json.dumps(result, indent=2) + '\n')
    for row in rows:
        Path(row['original']['file']).unlink()
    print(json.dumps(dict(files=len(rows), bytesReclaimed=sum(r['original']['bytes'] - r['archive']['bytes'] for r in rows))))


if __name__ == '__main__':
    main()
