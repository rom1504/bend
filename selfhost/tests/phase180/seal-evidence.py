#!/usr/bin/env python3
"""Archive exact Phase180 receipts/source snapshots; never prune build artifacts."""
import hashlib
import io
import json
from pathlib import Path
import tarfile

ROOT = Path(__file__).resolve().parents[3]
BUILD = ROOT / 'selfhost/build/phase180'
DEST = ROOT / 'implementation/phase180'
ARCHIVE = DEST / 'evidence.tar.gz'
INDEX = DEST / 'evidence-index.json'


def sha(data):
    return hashlib.sha256(data).hexdigest()


def main():
    if ARCHIVE.exists() or INDEX.exists():
        raise ValueError('Evidence outputs must be fresh')
    roots = [BUILD, ROOT / 'selfhost/build-retention/phase180']
    suffixes = {'.json', '.jsonl', '.txt', '.log', '.bend', '.mjs', '.py', '.c', '.h', '.inc'}
    names = {'stdout', 'stderr', 'compiler.stderr', 'qbe.stderr', 'qbe.stdout'}
    rows = []
    excluded = []
    DEST.mkdir(parents=True, exist_ok=True)
    with tarfile.open(ARCHIVE, 'w:gz') as archive:
        for root in roots:
            for file in sorted(root.rglob('*')):
                if not file.is_file():
                    continue
                rel = file.relative_to(ROOT).as_posix()
                small_inspection = 'inspection01' in file.parts and file.suffix in {'.ssa', '.s', '.objdump'}
                if file.suffix not in suffixes and file.name not in names and not small_inspection:
                    excluded.append({'path': rel, 'bytes': file.stat().st_size})
                    continue
                data = file.read_bytes()
                member = tarfile.TarInfo(rel)
                member.size = len(data)
                member.mode = 0o644
                member.mtime = 0
                archive.addfile(member, io.BytesIO(data))
                rows.append({'path': rel, 'bytes': len(data), 'sha256': sha(data)})
    with tarfile.open(ARCHIVE, 'r:gz') as archive:
        if archive.getnames() != [r['path'] for r in rows]:
            raise ValueError('Archive member order/set mismatch')
        for row in rows:
            data = archive.extractfile(row['path']).read()
            if len(data) != row['bytes'] or sha(data) != row['sha256']:
                raise ValueError('Archive verification failed: ' + row['path'])
    guards = []
    for file in sorted(BUILD.glob('*-guard/process.json')):
        d = json.loads(file.read_text())
        name = file.parent.name.removesuffix('-guard')
        close = ROOT / 'selfhost/build-retention/phase180' / (name + '-close') / 'report.json'
        # Close receipts use retention.json in current maintenance tooling.
        if not close.exists():
            close = close.with_name('retention.json')
        # Guard complete means successful, not merely finished. Failed trials
        # must be archived too; require their terminal fields, never relabel.
        if 'finished' not in d or 'returncode' not in d or 'wallSeconds' not in d:
            raise ValueError('An outer job is still incomplete: ' + name)
        guards.append({'name': name, 'seconds': d['wallSeconds'],
                       'exit': d['returncode'], 'peakTreeRssBytes': d['peakTreeRssBytes'],
                       'process': file.relative_to(ROOT).as_posix(),
                       'closeDirectory': str(close.parent.relative_to(ROOT)),
                       'closeFiles': sorted(p.name for p in close.parent.glob('*') if p.is_file())})
    if any(not g['closeFiles'] for g in guards):
        raise ValueError('Missing retention closure')
    result = {'kind': 'phase180-exact-evidence-archive', 'complete': True,
              'archive': {'path': str(ARCHIVE.relative_to(ROOT)), 'bytes': ARCHIVE.stat().st_size,
                          'sha256': sha(ARCHIVE.read_bytes())},
              'rows': rows, 'excludedArtifacts': excluded, 'guards': guards,
              'cost': {'outerJobs': len(guards),
                       'targetWallSeconds': sum(g['seconds'] for g in guards),
                       'nonzeroJobs': sum(g['exit'] != 0 for g in guards),
                       'nonzeroWallSeconds': sum(g['seconds'] for g in guards if g['exit'] != 0)},
              'scope': 'Exact receipts, logs and source/method snapshots; no build artifact deletion. '
                       'Excluded machine products remain local and have identities in original receipts. '
                       'Outer wall includes concurrent children; excludes agent/metadata/research effort. '
                       'Restore only into a separate empty directory; never overwrite qualified artifacts.'}
    INDEX.write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps({'archive': result['archive'], 'members': len(rows), 'cost': result['cost']}))


if __name__ == '__main__':
    main()
