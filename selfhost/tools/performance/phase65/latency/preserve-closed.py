#!/usr/bin/env python3
"""Data-only rehash of the closed Phase64 raw tree and inherited protected inputs."""
import hashlib
import json
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
RAW = ROOT / 'selfhost/build/phase65'
OUT = RAW / 'final-state10/closed-evidence-preservation.json'
TRACKED = ROOT / 'implementation/phase65/evidence/closed-evidence-preservation.json'
assert not OUT.exists() and not TRACKED.exists()

def digest(path):
    h = hashlib.sha256()
    with path.open('rb') as stream:
        for block in iter(lambda: stream.read(1048576), b''):
            h.update(block)
    return h.hexdigest()

def pin(path):
    return dict(file=str(path.relative_to(ROOT)), bytes=path.stat().st_size, sha256=digest(path))

errors = []
def verify(rows, label):
    matched = total = 0
    for row in rows:
        path = ROOT / row['file']
        if path.is_symlink() or not path.is_file():
            errors.append(dict(scope=label, file=row['file'], error='missing or symbolic link'))
            continue
        actual = pin(path)
        if actual['sha256'] != row['sha256'] or ('bytes' in row and actual['bytes'] != row['bytes']):
            errors.append(dict(scope=label, expected=row, actual=actual))
        else:
            matched += 1
        total += actual['bytes']
    return dict(expected=len(rows), matched=matched, bytesRead=total)

manifest_path = ROOT / 'selfhost/tools/performance/phase64/artifacts/manifest.json'
inherited_path = RAW / 'inherited-before.json'
manifest_pin, inherited_pin = pin(manifest_path), pin(inherited_path)
manifest, inherited = json.loads(manifest_path.read_text()), json.loads(inherited_path.read_text())
assert manifest['complete'] and manifest['pass'] and manifest['reopenedAllMembers']
assert len(manifest['files']) == manifest['fileCount'] == 15922
assert len(inherited['files']) == 110
closed = ROOT / 'selfhost/build/phase64'
actual_paths = sorted(str(p.relative_to(ROOT)) for p in closed.rglob('*') if p.is_file())
expected_paths = sorted(row['file'] for row in manifest['files'])
added, missing = sorted(set(actual_paths)-set(expected_paths)), sorted(set(expected_paths)-set(actual_paths))
links = sorted(str(p.relative_to(ROOT)) for p in closed.rglob('*') if p.is_symlink())
if added or missing or links:
    errors.append(dict(scope='closedPhase64Inventory', added=added, missing=missing, symlinks=links))
closed_result = verify(manifest['files'], 'closedPhase64')
inherited_result = verify(inherited['files'], 'inheritedProtected')
archive_result = verify([manifest['archive']], 'publishedPhase64Archive')
assert pin(manifest_path) == manifest_pin and pin(inherited_path) == inherited_pin
result = dict(kind='phase65-closed-evidence-preservation', complete=True, dataOnly=True,
    targetExecuted=False, created=datetime.now(timezone.utc).isoformat(),
    producer=pin(Path(__file__)), publishedManifest=manifest_pin, inheritedBaseline=inherited_pin,
    closedPhase64=dict(**closed_result, exactInventory=not(added or missing or links),
                      orderedManifestFilesSha256=hashlib.sha256(json.dumps(manifest['files'], separators=(',',':')).encode()).hexdigest()),
    inheritedProtected=inherited_result, publishedArchive=archive_result,
    errors=errors, scope='Every closed Phase64 file is rehashed against its published artifact manifest; '
          'the published archive itself is rehashed, without extraction or modifications. '
          'Inherited protected files are rehashed against Phase65 inherited-before.json. '
          'No writes occur in Phase64 or any protected input.', **{'pass': not errors})
serialized = json.dumps(result, indent=2)+'\n'
for destination in [OUT, TRACKED]:
    destination.parent.mkdir(parents=True, exist_ok=True)
    with destination.open('x') as stream:
        stream.write(serialized)
print(json.dumps(dict(output=pin(OUT), trackedCopy=pin(TRACKED), closedPhase64=closed_result, inheritedProtected=inherited_result,
                      publishedArchive=archive_result, errors=errors, **{'pass': not errors})))
