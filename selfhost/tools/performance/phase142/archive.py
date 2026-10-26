#!/usr/bin/env python3
"""Freeze Phase142 receipts and small reproducer inputs; omit generated APIs/QBE."""
import argparse
import hashlib
import json
from pathlib import Path
import tarfile

ROOT = Path(__file__).resolve().parents[4]


def pin(path):
    data = path.read_bytes()
    return dict(file=str(path.relative_to(ROOT)), bytes=len(data),
                sha256=hashlib.sha256(data).hexdigest())


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--out', type=Path, required=True)
    args = ap.parse_args()
    out = args.out.resolve()
    assert out.is_relative_to(ROOT / 'implementation/phase142') and not out.exists()
    files = set()
    for directory in [ROOT / 'selfhost/build/phase142',
                      *sorted((ROOT / 'selfhost/build/phase111').glob('p142-*'))]:
        for path in directory.rglob('*'):
            if not path.is_file() or path.is_symlink():
                continue
            if path.name in {'api.mjs', 'program', 'runtime.o'} or path.suffix in {'.ssa', '.s', '.o'}:
                continue
            if path.stat().st_size > 8 * 1024 * 1024:
                continue
            files.add(path)
    for directory in ['selfhost/tools/performance/phase142', 'research/phase142',
                      'experiments/phase142']:
        files.update(p for p in (ROOT / directory).rglob('*')
                     if p.is_file() and not p.is_symlink() and '__pycache__' not in p.parts)
    files = sorted(files)
    rows = [pin(p) for p in files]
    out.mkdir(parents=True)
    archive = out / 'evidence.tar.gz'
    with tarfile.open(archive, 'w:gz', compresslevel=9) as tar:
        for p in files:
            tar.add(p, arcname=str(p.relative_to(ROOT)), recursive=False)
    # Verify archived bytes, independently of the input inventory.
    with tarfile.open(archive, 'r:gz') as tar:
        for row in rows:
            data = tar.extractfile(row['file']).read()
            assert len(data) == row['bytes']
            assert hashlib.sha256(data).hexdigest() == row['sha256']
    record = dict(kind='phase142-evidence', complete=True, files=rows,
                  archive=pin(archive), roundtripExact=True,
                  exclusions='Generated APIs, QBE, assembly, objects, executables and files above8MiB. '
                  'Receipts retain their identities; checked-source/module/command inputs permit reproduction.')
    (out / 'inventory.json').write_text(json.dumps(record, indent=2) + '\n')
    print(json.dumps(dict(files=len(rows), bytes=sum(r['bytes'] for r in rows),
                          archive=record['archive'])))


if __name__ == '__main__':
    main()
