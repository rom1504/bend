#!/usr/bin/env python3
"""Restore exact intermediate source/data revisions; never run compiler targets."""
import argparse
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
HISTORY = ROOT / 'experiments/phase171/descendant-history/manifest.json'
SOURCES = ROOT / 'selfhost/tests/phase171'

def identity(data):
    return {'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()}

def read_pin(row):
    path = ROOT / row['file']
    assert path.resolve().is_relative_to(ROOT) and not path.is_symlink()
    data = path.read_bytes()
    assert identity(data) == {k: row[k] for k in ('bytes', 'sha256')}, row['file']
    return data

def leaf(name):
    assert name and Path(name).name == name and name not in ('.', '..')

def apply(snapshot, delta, revision):
    assert delta['kind'] == 'phase171-exact-text-delta' and delta['version'] == 1
    assert (delta['fromRevision'], delta['toRevision']) == (revision-1, revision)
    snapshot = dict(snapshot)
    names = [row['name'] for row in delta['changes']]
    assert len(names) == len(set(names))
    for row in delta['changes']:
        name = row['name']; leaf(name)
        if row['before'] is None:
            assert name not in snapshot
            data = b''
        else:
            data = snapshot[name]
            assert identity(data) == row['before'], name
        edits = row['edits']
        previous_end = 0
        for edit in edits:
            start = edit['offset']; old = edit['before'].encode()
            assert isinstance(start, int) and previous_end <= start <= len(data)
            assert data[start:start+len(old)] == old, name
            previous_end = start+len(old)
        for edit in reversed(edits):
            start = edit['offset']; old = edit['before'].encode()
            data = data[:start]+edit['after'].encode()+data[start+len(old):]
        assert identity(data) == row['after'], name
        snapshot[name] = data
    assert {n: identity(d) for n, d in snapshot.items()} == delta['inventory']
    return snapshot

def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--revision', type=int, choices=(12,13,14), required=True)
    p.add_argument('--out', type=Path, help='Fresh directory only; omitted means in-memory verification')
    p.add_argument('--check-existing', action='store_true', help='Compare every intermediate against existing original directories without writes')
    a = p.parse_args()
    manifest = json.loads(HISTORY.read_text())
    assert manifest['kind'] == 'phase171-descendant-history' and manifest['version'] == 1
    assert manifest['baseline']['revision'] == 11
    state = {Path(row['file']).name: read_pin(row) for row in manifest['baseline']['files']}
    for row in manifest['retainedLatest']['files']: read_pin(row)
    checked = []
    for revision in range(12, a.revision+1):
        rows = [r for r in manifest['patches'] if r['revision'] == revision]
        assert len(rows) == 1
        state = apply(state, json.loads(read_pin(rows[0])), revision)
        if a.check_existing:
            old = SOURCES / ('descendant-v'+str(revision))
            assert all(p.is_file() and not p.is_symlink() for p in old.iterdir())
            assert {p.name: p.read_bytes() for p in old.iterdir()} == state
        checked.append({'revision': revision, 'files': len(state), 'bytes': sum(map(len,state.values()))})
    if a.out:
        out = a.out.resolve()
        assert out.is_relative_to(ROOT) and not out.exists(), 'Fresh repository-local output required'
        out.mkdir(parents=True)
        for name, data in state.items():
            leaf(name)
            with (out/name).open('xb') as f: f.write(data)
        assert {p.name: p.read_bytes() for p in out.iterdir()} == state
    print(json.dumps({'kind': 'phase171-descendant-history-verification', 'complete': True,
        'targetsRun': False, 'manifest': identity(HISTORY.read_bytes()), 'checked': checked,
        'existingCopiesExact': a.check_existing, 'output': str(a.out.resolve()) if a.out else None,
        'inventory': {n: identity(d) for n,d in sorted(state.items())}}, indent=2))

if __name__ == '__main__': main()
