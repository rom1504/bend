#!/usr/bin/env python3
"""Share storage for closed, archived, identical large stdout captures only."""
import collections
import hashlib
import json
import os
from pathlib import Path
import shutil
import stat
import sys

ROOT = Path(__file__).resolve().parents[5]
EVIDENCE = ROOT / 'implementation/phase102/evidence'

def digest(path):
    value = hashlib.sha256()
    with path.open('rb') as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b''): value.update(block)
    return value.hexdigest()

def verify(row):
    path = ROOT / row['path']
    assert not path.is_symlink() and path.resolve(strict=True) == path
    status = path.stat()
    assert stat.S_ISREG(status.st_mode)
    assert status.st_size == row['bytes'] and stat.S_IMODE(status.st_mode) == row['mode']
    assert digest(path) == row['sha256']
    return path, status

out = Path(sys.argv[1]).resolve()
assert out.is_relative_to(ROOT / 'selfhost/build/phase102') and not out.exists()
receipt = json.loads((EVIDENCE / 'receipt.json').read_text())
archive = ROOT / receipt['archive']['path']
assert receipt['complete'] and receipt['everyMemberVerified']
assert archive.stat().st_size == receipt['archive']['bytes'] and digest(archive) == receipt['archive']['sha256']
groups = collections.defaultdict(list)
for row in json.loads((EVIDENCE / 'manifest.json').read_text()):
    if row['path'].startswith('selfhost/build/phase102/') and Path(row['path']).name == 'stdout.log' and row['bytes'] >= 1024 * 1024:
        groups[(row['sha256'], row['bytes'], row['mode'])].append(row)
report = dict(complete=False, method=dict(file=str(Path(__file__)),sha256=digest(Path(__file__))),
              archiveReceipt=dict(file=str(EVIDENCE/'receipt.json'),sha256=digest(EVIDENCE/'receipt.json')),
              freeBytesBefore=shutil.disk_usage(ROOT).free, replaced=[],
              scope='Only exact archived closed stdout captures share hard links. Every path, byte and mode is preserved. No executable, source or JSON receipt is changed; immutable captures must remain immutable.')
out.parent.mkdir(parents=True, exist_ok=True)
with out.open('x') as stream: json.dump(report, stream, indent=2)
try:
    for rows in groups.values():
        if len(rows) < 2: continue
        source, source_stat = verify(rows[0])
        for row in rows[1:]:
            target, status = verify(row)
            if (status.st_dev, status.st_ino) == (source_stat.st_dev, source_stat.st_ino): continue
            assert status.st_dev == source_stat.st_dev
            temporary = target.with_name(target.name + '.phase102-link')
            assert not temporary.exists()
            os.link(source, temporary)
            try:
                assert target.stat() == status, 'Concurrent change to frozen capture'
                os.replace(temporary, target)
            finally:
                if temporary.exists(): temporary.unlink()
            verify(row)
            report['replaced'].append(dict(path=row['path'], source=str(source.relative_to(ROOT)),
                bytes=row['bytes'],sha256=row['sha256'],mode=row['mode']))
    report['complete'] = True
finally:
    report['freeBytesAfter'] = shutil.disk_usage(ROOT).free
    report['logicalDuplicateBytes'] = sum(row['bytes'] for row in report['replaced'])
    temporary = out.with_suffix('.tmp'); temporary.write_text(json.dumps(report,indent=2)+'\n'); temporary.replace(out)
print(json.dumps({key:report[key] for key in ['complete','logicalDuplicateBytes','freeBytesBefore','freeBytesAfter']}))
