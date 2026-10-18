#!/usr/bin/env python3
"""Freeze this completed campaign's local observations, products and failed attempts."""
import argparse
import gzip
import hashlib
import json
import tarfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()
out = a.out.resolve()
assert out.is_relative_to(ROOT / 'implementation/phase106') and not out.exists()
out.mkdir(parents=True)
base = ROOT / 'selfhost/build/phase106'
excluded_dirs = {'cargo-home', 'cargo-target'}
excluded_files = {'fullself-profile01/output.1.c', 'self-clang-clean01/compiler'}
files = [f for f in base.rglob('*') if f.is_file() and not f.is_symlink()
         and f.relative_to(base).parts[0] not in excluded_dirs
         and str(f.relative_to(base)) not in excluded_files]
for folder in (ROOT / 'selfhost/build/phase98').glob('phase106-*'):
    files.extend(f for f in folder.rglob('*') if f.is_file() and not f.is_symlink())
files.append(base / 'cargo-target/release/bend-native-ir-cranelift')
files.extend(f for f in (ROOT / 'selfhost/tools/performance/phase106').rglob('*')
             if f.is_file() and not f.is_symlink() and '__pycache__' not in f.parts)
files = sorted(set(files))
entries = []
for f in files:
    entries.append(dict(file=str(f.relative_to(ROOT)), bytes=f.stat().st_size,
                        sha256=hashlib.sha256(f.read_bytes()).hexdigest()))
archive = out / 'observations.tar.gz'
with archive.open('wb') as raw, gzip.GzipFile(fileobj=raw, mode='wb', filename='', mtime=0) as zipped:
    with tarfile.open(fileobj=zipped, mode='w') as tar:
        for f in files:
            info = tar.gettarinfo(str(f), arcname=str(f.relative_to(ROOT)))
            info.uid = info.gid = 0; info.uname = info.gname = ''; info.mtime = 0
            with f.open('rb') as content: tar.addfile(info, content)
(out / 'FILES.sha256').write_text(''.join(f"{e['sha256']}  {e['file']}\n" for e in entries))
receipt = dict(complete=True, files=entries,
    archive=dict(file=archive.name, bytes=archive.stat().st_size,
                 sha256=hashlib.sha256(archive.read_bytes()).hexdigest()),
    exclusions=dict(directories=sorted(excluded_dirs), files=sorted(excluded_files)),
    scope='Phase106 raw receipts, logs, generated artifacts/products, source snapshots, methods, '
          'proof/mutation attempts and runnable adapter. Excludes dependency/build caches and '
          'duplicate full compiler C/image; their authenticated pins remain in attribution reports. '
          'Previously authenticated tools, installed compiler assets and Phase105 baselines are '
          'external prerequisites, not silently recopied into this capsule.')
(out / 'manifest.json').write_text(json.dumps(receipt, indent=2) + '\n')
for source, name in [(base / 'measure01/report.json', 'measurements.json'),
                     (base / 'analysis01.json', 'analysis.json'),
                     (base / 'confirm01/report.json', 'confirmation.json'),
                     (ROOT / 'selfhost/build/phase98/phase106-law-check02/report.json', 'laws.json'),
                     (ROOT / 'selfhost/build/phase98/phase106-law-mutants02/report.json', 'mutations.json')]:
    (out / name).write_bytes(source.read_bytes())
# Verify the complete compressed archive against every recorded content digest.
with tarfile.open(archive, 'r:gz') as tar:
    assert tar.getnames() == [e['file'] for e in entries]
    for entry in entries:
        data = tar.extractfile(entry['file']).read()
        assert len(data) == entry['bytes']
        assert hashlib.sha256(data).hexdigest() == entry['sha256']
print(json.dumps(dict(complete=True, entries=len(entries), bytes=archive.stat().st_size)))
