#!/usr/bin/env python3
"""Archive Phase127 profiles/receipts without compiler executables or large QBE outputs."""
import argparse
import gzip
import hashlib
import io
import json
from pathlib import Path
import tarfile

ROOT = Path(__file__).resolve().parents[4]
BUILD = ROOT / 'selfhost/build/phase127'


def digest(path):
    h = hashlib.sha256()
    with path.open('rb') as f:
        for block in iter(lambda: f.read(1024*1024), b''):
            h.update(block)
    return h.hexdigest()


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    a.out.mkdir(parents=True, exist_ok=False)
    files = []
    extensions = {'.json', '.txt', '.log', '.py', '.mjs', '.c', '.h', '.md', '.bend'}
    for path in sorted(BUILD.rglob('*')):
        if not path.is_file() or path.is_symlink():
            continue
        # Raw ordered vectors, event counters, complete receipts, source/method
        # snapshots and derived reports remain. Exclude redundant event JSONL,
        # binaries/objects, bulk stdout, and generated assembly/QBE.
        if path.suffix in extensions or (path.name in {'stdout', 'stderr'} and path.stat().st_size < 64*1024):
            files.append(path)
    files += [ROOT/'selfhost/build/phase126/observer-divmod-source32/compiler.bend']
    # The three exact-QBE expectations are independent of the repaired image.
    manifest = json.loads((BUILD/'followup01/n1-manifest.json').read_text())
    for workload in manifest['workloads']:
        for variant in workload['variants']:
            for expectation in variant['expected'].values():
                if isinstance(expectation, dict) and expectation.get('kind') == 'exact':
                    files.append(Path(expectation['file']))
    files = sorted(set(files))
    entries = []
    for path in files:
        assert path.is_relative_to(ROOT) and not path.is_symlink()
        entries.append({'path': str(path.relative_to(ROOT)), 'bytes': path.stat().st_size,
                        'sha256': digest(path)})
    inventory = {'schema': 'phase127-evidence-capsule-v1', 'files': entries,
                 'scope': 'Raw profiling vectors, event counts, derived attribution, run/guard receipts, frozen methods, source overlay and short exact oracles. Executables, runtime objects and full 99.5MB QBE products remain in retained build paths with hashes; rebuilding them uses the documented checked workflow. Absolute original paths in receipts are provenance, not portable commands.',
                 'methodSha256': digest(Path(__file__))}
    archive = a.out/'profiles.tar.gz'
    inventory_bytes = (json.dumps(inventory, indent=2)+'\n').encode()
    with archive.open('xb') as raw, gzip.GzipFile(fileobj=raw, mode='wb', filename='', mtime=0, compresslevel=6) as compressed:
        with tarfile.open(fileobj=compressed, mode='w|') as tar:
            info = tarfile.TarInfo('INVENTORY.json')
            info.size = len(inventory_bytes); info.mode = 0o644
            tar.addfile(info, io.BytesIO(inventory_bytes))
            for path, entry in zip(files, entries):
                info = tarfile.TarInfo(entry['path'])
                info.size = entry['bytes']; info.mode = 0o644
                with path.open('rb') as data:
                    tar.addfile(info, data)
                assert digest(path) == entry['sha256'], f'Input changed: {path}'
    # Read every archived payload back. An archive checksum alone cannot establish
    # that the requested source artifacts were actually included without changes.
    with tarfile.open(archive, 'r:gz') as tar:
        actual = {}
        for member in tar:
            stream = tar.extractfile(member)
            h = hashlib.sha256()
            for block in iter(lambda: stream.read(1024*1024), b''):
                h.update(block)
            actual[member.name] = (member.size, h.hexdigest())
    assert actual.pop('INVENTORY.json') == (len(inventory_bytes), hashlib.sha256(inventory_bytes).hexdigest())
    assert actual == {e['path']: (e['bytes'], e['sha256']) for e in entries}
    result = {'complete': True, 'archive': {'file': archive.name, 'bytes': archive.stat().st_size,
                                          'sha256': digest(archive)},
              'files': len(entries), 'uncompressedBytes': sum(e['bytes'] for e in entries),
              'everyArchivedFileHashVerified': True, 'scope': inventory['scope']}
    (a.out/'README.md').write_text('# Phase127 evidence capsule\n\n'
        'The compressed archive contains its full SHA256 inventory and the retained '
        'raw profiles, counters, reports, method snapshots and bounded source/oracle inputs. '
        'Every member was read back and checked. See `receipt.json` for the archive identity.\n\n'
        +inventory['scope']+'\n\n'
        'Extract into a separate evidence directory. Do not overwrite the working checkout. '
        'The final report links the original paths; the archive preserves those paths relative to the repository.\n')
    (a.out/'receipt.json').write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps(result))


if __name__ == '__main__':
    main()
