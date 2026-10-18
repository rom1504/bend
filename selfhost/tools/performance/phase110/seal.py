#!/usr/bin/env python3
"""Seal bounded Phase110 evidence, merging retired captures and verifying every byte."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import tarfile

ROOT = Path(__file__).resolve().parents[4]
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args(); out = a.out.resolve()
if out.exists() or not out.is_relative_to(ROOT / 'implementation/phase110/evidence'):
    raise ValueError('fresh Phase110 evidence archive required')
roots = [ROOT / 'selfhost/build/phase110', ROOT / 'selfhost/build/phase109/p110-native-reverse13']
roots += sorted((ROOT / 'selfhost/build/phase108').glob('p110-*'))
roots += sorted((ROOT / 'selfhost/build/phase98').glob('*phase110*'))
roots += [ROOT / 'selfhost/tools/performance/phase110']
roots += [ROOT / 'selfhost/.bootstrap/upstream-phase66/bend2/base.bend',
          ROOT / 'selfhost/tools/performance/phase88/base/carrier01/base.p88',
          ROOT / 'implementation/phase110/selection.json',
          ROOT / 'implementation/phase110/accounting.json']
roots += sorted((ROOT / 'implementation/phase110/evidence').glob('machine*'))
if not all(root.exists() for root in roots): raise ValueError('missing evidence root')
def inventory():
    return sorted({f for root in roots for f in ([root] if root.is_file() else root.rglob('*'))
                   if f.is_file() and '__pycache__' not in f.parts})
files = inventory()
if any(f.is_symlink() for f in files): raise ValueError('unexpected evidence symlink')
def pin(f):
    h = hashlib.sha256()
    with f.open('rb') as stream:
        for part in iter(lambda: stream.read(1024*1024), b''): h.update(part)
    return dict(file=str(f.relative_to(ROOT)), bytes=f.stat().st_size, sha256=h.hexdigest())
entries = {str(f.relative_to(ROOT)): pin(f) for f in files}
retired = ROOT / 'implementation/phase110/evidence/retired-captures.tar.gz'
retirement_file = ROOT / 'selfhost/build/phase110/cleanup06.json'
retirement = json.loads(retirement_file.read_text())
if not retirement.get('complete') or pin(retired) != retirement['archive']:
    raise ValueError('retired archive differs from authenticated cleanup receipt')
retired_expected = {row['file']: row for row in retirement['files']}
retired_seen = set()
retired_entries = {}
with tarfile.open(retired, 'r:gz') as archive:
    for member in archive:
        name = member.name
        if not member.isfile() or not name.startswith('selfhost/build/phase110/') or '..' in Path(name).parts:
            raise ValueError('unexpected retired member ' + name)
        data = archive.extractfile(member).read()
        row = dict(file=name, bytes=len(data), sha256=hashlib.sha256(data).hexdigest())
        if name in retired_seen or retired_expected.get(name) != row:
            raise ValueError('retired member differs from cleanup receipt ' + name)
        retired_seen.add(name)
        if name in entries and row != entries[name]: raise ValueError('restored capture differs ' + name)
        if name not in entries: retired_entries[name] = row
if retired_seen != set(retired_expected): raise ValueError('missing retired capture')
raw = sum(row['bytes'] for row in list(entries.values()) + list(retired_entries.values()))
if raw > 600*1024**2 or shutil.disk_usage(ROOT).free < 60*1024**2:
    raise ValueError('evidence bound/free-space guard failed')
out.parent.mkdir(parents=True, exist_ok=True)
partial = out.with_suffix(out.suffix + '.partial')
if partial.exists(): raise ValueError('partial archive already exists')
with tarfile.open(partial, 'w:gz', compresslevel=6) as archive:
    for f in files: archive.add(f, arcname=str(f.relative_to(ROOT)), recursive=False)
    with tarfile.open(retired, 'r:gz') as old:
        for member in old:
            if member.name in retired_entries:
                archive.addfile(member, old.extractfile(member))
expected = {**entries, **retired_entries}; seen = set()
with tarfile.open(partial, 'r:gz') as archive:
    for member in archive:
        if not member.isfile() or member.name not in expected or member.name in seen:
            raise ValueError('unexpected/duplicate archived member')
        seen.add(member.name); h = hashlib.sha256(); length = 0
        stream = archive.extractfile(member)
        for part in iter(lambda: stream.read(1024*1024), b''): length += len(part); h.update(part)
        e = expected[member.name]
        if (length, h.hexdigest()) != (e['bytes'], e['sha256']): raise ValueError('changed archived bytes')
if (seen != set(expected) or files != inventory() or
        entries != {str(f.relative_to(ROOT)): pin(f) for f in files}):
    raise ValueError('missing member or live input changed while sealing')
partial.rename(out)
report = dict(kind='phase110-evidence-capsule', complete=True, method=pin(Path(__file__)),
              archive=pin(out), retiredArchive=pin(retired), retirementReceipt=pin(retirement_file), retiredMembersMerged=len(retired_entries),
              uncompressedBytes=raw, members=len(expected), allMembersVerified=True,
              entries=[expected[name] for name in sorted(expected)],
              restore='Inspect the manifest and evidence README first. Restore only absent repository-relative build destinations or the two documented exact Base assets; never overwrite live source/tools. External tools, previous-phase dependencies and selected mature seed retain their original pinned acquisition recipes/capsules.')
(out.parent / 'manifest.json').write_text(json.dumps(report, indent=2) + '\n')
print(json.dumps({k: v for k,v in report.items() if k not in ['entries', 'restore']}))
