#!/usr/bin/env python3
"""Freeze Phase143 evidence and bounded native recovery artifacts."""
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
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    out = args.out.resolve()
    assert out.is_relative_to(ROOT / 'implementation/phase143') and not out.exists()
    files = set()
    for directory in [ROOT / 'selfhost/build/phase143',
                      *sorted((ROOT / 'selfhost/build/phase111').glob('*p143*')),
                      *sorted((ROOT / 'selfhost/build/phase130').glob('*p143*'))]:
        for path in directory.rglob('*'):
            if not path.is_file() or path.is_symlink() or '__pycache__' in path.parts:
                continue
            if path.name in {'api.mjs', 'program', 'runtime.o'} or path.suffix in {'.ssa', '.s', '.o'}:
                continue
            if path.stat().st_size > 8 * 1024 * 1024:
                continue
            files.add(path)
    for directory in ['selfhost/tools/performance/phase143', 'research/phase143',
                      'experiments/phase143', 'design/phase143']:
        files.update(p for p in (ROOT / directory).rglob('*')
                     if p.is_file() and not p.is_symlink() and '__pycache__' not in p.parts)

    # Exact symbols/owner bindings support offline reanalysis. Keep clean images
    # and the N2 object as bounded native-first recovery checkpoints as well.
    retained = [
        'selfhost/build/phase143/profile01/owners.json',
        'selfhost/build/phase143/profile01/runtime/program',
        'selfhost/build/phase111/p142-indexed-n1/program',
        'selfhost/build/phase111/p142-indexed-n1/report.json',
        'selfhost/build/phase142/indexed-source02/compiler.bend',
        'selfhost/build/phase142/indexed-source02/manifest.json',
        'selfhost/build/phase111/p143-integrated-n2/program',
        'selfhost/build/phase111/p143-integrated-n2/program.o',
        'selfhost/build/phase128/runtime-borrow01/runtime.o',
        'selfhost/build/phase128/runtime-borrow01/report.json',
        'selfhost/build/phase130/base-carrier01/base.p130',
        'selfhost/build/phase130/base-carrier01/receipt.json',
    ]
    for name in retained:
        path = ROOT / name
        assert path.is_file() and not path.is_symlink(), path
        files.add(path)
    files = sorted(files)
    rows = [pin(p) for p in files]
    out.mkdir(parents=True)
    archive = out / 'evidence.tar.gz'
    with tarfile.open(archive, 'w:gz', compresslevel=6) as tar:
        for path in files:
            tar.add(path, arcname=str(path.relative_to(ROOT)), recursive=False)
    with tarfile.open(archive, 'r:gz') as tar:
        assert len(tar.getmembers()) == len(rows)
        for row in rows:
            data = tar.extractfile(row['file']).read()
            assert len(data) == row['bytes']
            assert hashlib.sha256(data).hexdigest() == row['sha256']
    assert [pin(p) for p in files] == rows, 'Input changed during archival'
    record = dict(
        kind='phase143-evidence', complete=True, files=rows,
        archive=pin(archive), roundtripExact=True, currentInputsExact=True,
        explicitRecoveryArtifacts=retained,
        exclusions='Generated APIs, QBE, assembly, ordinary objects/executables and files above8MiB, except explicit recovery artifacts. '
                   'Receipts retain their identities and reproduction commands. Parent toolchains/artifacts remain dependencies; '
                   'absolute-path receipts require explicit relocation and renewed validation. Not a portable release.')
    (out / 'inventory.json').write_text(json.dumps(record, indent=2) + '\n')
    print(json.dumps(dict(files=len(rows), bytes=sum(r['bytes'] for r in rows),
                          archive=record['archive'], roundtripExact=True)))


if __name__ == '__main__':
    main()
