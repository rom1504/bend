#!/usr/bin/env python3
"""Freeze Phase148 evidence. Data only; no compiler execution or pruning."""
import hashlib
import io
import json
from pathlib import Path
import tarfile

ROOT = Path(__file__).resolve().parents[2]
RAW = ROOT / 'selfhost/build/phase148'
OUT = ROOT / 'implementation/phase148/evidence'


def pin(data):
    return dict(bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def main():
    # Exact generated bulk remains in the independently verified local closure
    # archives. Include experimental ELFs, samples and maps together here too.
    roots = [RAW, ROOT/'selfhost/build-retention/phase148',
             ROOT/'experiments/phase148', ROOT/'selfhost/tests/phase148',
             ROOT/'selfhost/build/phase147/verifier-capture01']
    paths = set()
    for root in roots:
        paths.update(p for p in root.rglob('*') if p.is_file())
    paths.update(ROOT/p for p in [
        'AGENTS.md', 'implementation/phase147/candidate.json',
        'selfhost/tools/build-retention/close.py',
        'selfhost/tools/build-retention/guard.py',
        'selfhost/tools/execution.py', 'selfhost/manifests/current.json',
        'selfhost/manifests/assets-native.json'])
    objects, members, omitted, guards = {}, [], [], []
    for path in sorted(paths):
        if path.is_symlink() or '__pycache__' in path.parts:
            continue
        if path.suffix in {'.ssa', '.s', '.o', '.gz', '.zip', '.xz'}:
            omitted.append(dict(file=str(path.relative_to(ROOT)), bytes=path.stat().st_size,
                                reason='Generated bulk or closure archive remains hot and locally archived.'))
            continue
        before = path.stat()
        data = path.read_bytes()
        after = path.stat()
        assert (before.st_size, before.st_mtime_ns, before.st_ctime_ns) == (
            after.st_size, after.st_mtime_ns, after.st_ctime_ns), path
        identity = pin(data)
        objects[identity['sha256']] = data
        members.append(dict(file=str(path.relative_to(ROOT)), mode=before.st_mode & 0o777,
                            object='objects/'+identity['sha256'], **identity))
        if path.name == 'retention.json' and 'method-history' not in path.parts:
            state = json.loads(data)
            if state.get('kind') == 'build-retention-run-v1':
                assert state['closed'] and state['state'] == 'sealed', path
                guards.append(str(path.relative_to(ROOT)))
    assert sum(map(len, objects.values())) < 64*1024**2
    OUT.mkdir(parents=True, exist_ok=False)
    archive = OUT/'capsule.tar.gz'
    with tarfile.open(archive, 'w:gz', compresslevel=6) as stream:
        for digest, data in sorted(objects.items()):
            entry = tarfile.TarInfo('objects/'+digest)
            entry.size = len(data)
            entry.mode = 0o644
            stream.addfile(entry, io.BytesIO(data))
    with tarfile.open(archive, 'r:gz') as stream:
        seen = set()
        for entry in stream:
            assert entry.isfile() and entry.name not in seen
            digest = entry.name.removeprefix('objects/')
            assert digest in objects and pin(stream.extractfile(entry).read()) == pin(objects[digest])
            seen.add(entry.name)
        assert len(seen) == len(objects)
    report = dict(kind='phase148-evidence-capsule', complete=True,
                  archive=dict(file=str(archive.relative_to(ROOT)), **pin(archive.read_bytes())),
                  members=members, uniqueObjects=len(objects), uniqueBytes=sum(map(len, objects.values())),
                  reopenedVerified=True, sealedGuards=guards, omitted=omitted,
                  scope='Exact sources, methods, receipts, failures, experimental ELFs, profiler samples/maps and controls. Generated bulk remains in local verified closure archives. No compiler qualification or speed claim. No pruning.',
                  restore='Each members row maps its file to archive member object; verify sha256/bytes and restore its mode. Historical receipt paths may need relocation; never rewrite their hashes.')
    (OUT/'inventory.json').write_text(json.dumps(report, indent=2)+'\n')
    print(json.dumps({k:report[k] for k in ['archive','uniqueObjects','uniqueBytes','reopenedVerified']}))


if __name__ == '__main__':
    main()
