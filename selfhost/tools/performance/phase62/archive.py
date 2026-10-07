#!/usr/bin/env python3
"""Archive a closed Phase62 tree, reopen every member, and verify unchanged inputs."""
import hashlib
import json
import tarfile
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
RAW = ROOT / 'selfhost/build/phase62'
OUT = ROOT / 'selfhost/tools/performance/phase62/artifacts'
OUT.mkdir(exist_ok=False)


def digest(file):
    h = hashlib.sha256()
    with file.open('rb') as f:
        for block in iter(lambda: f.read(1048576), b''):
            h.update(block)
    return h.hexdigest()


def inventory():
    result = []
    for file in sorted(RAW.rglob('*')):
        assert not file.is_symlink(), str(file)
        if file.is_file():
            result.append(dict(file=str(file.relative_to(ROOT)), bytes=file.stat().st_size,
                               sha256=digest(file)))
    return result


before = inventory()
assert before
archive = OUT / 'raw-campaign.tar.gz'
with tarfile.open(archive, 'w:gz', compresslevel=6) as tar:
    for item in before:
        tar.add(ROOT / item['file'], arcname=item['file'], recursive=False)
with tarfile.open(archive, 'r:gz') as tar:
    members = tar.getmembers()
    assert [m.name for m in members] == [r['file'] for r in before]
    for member, expected in zip(members, before):
        assert member.isfile() and member.size == expected['bytes']
        h = hashlib.sha256()
        with tar.extractfile(member) as stream:
            for block in iter(lambda: stream.read(1048576), b''):
                h.update(block)
        assert h.hexdigest() == expected['sha256'], member.name
assert inventory() == before, 'Input tree changed during publication'
report = dict(kind='phase62-reopened-evidence-archive', complete=True,
              created=datetime.now(timezone.utc).isoformat(), files=before,
              fileCount=len(before), uncompressedBytes=sum(x['bytes'] for x in before),
              archive=dict(file=str(archive.relative_to(ROOT)), bytes=archive.stat().st_size,
                           sha256=digest(archive)),
              producer=dict(file=str(Path(__file__).relative_to(ROOT)), sha256=digest(Path(__file__))),
              reopenedAllMembers=True, inputInventoryAndHashesUnchanged=True,
              scope='Closed raw evidence including unsuccessful data-only plot attempt. '
                    'Historical Phase61 prerequisites remain in their existing published capsule.')
report['pass'] = True
(OUT / 'manifest.json').write_text(json.dumps(report, indent=2)+'\n')
print(json.dumps({k: report[k] for k in ['fileCount', 'uncompressedBytes', 'archive']}))
