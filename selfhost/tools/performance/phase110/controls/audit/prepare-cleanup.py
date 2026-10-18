#!/usr/bin/env python3
"""Read-only capsule/local authentication; writes a proposal, never deletes files."""
import argparse
import datetime
import hashlib
import json
from pathlib import Path
import stat
import tarfile

ROOT = Path(__file__).resolve().parents[6]
SOURCE_SUFFIXES = {'.bend', '.lean', '.ts', '.js', '.mjs', '.py', '.h', '.sh'}
GENERATED_SUFFIXES = {'.c', '.o', '.s', '.ssa', '.qbe', '.ll', '.asm', '.out'}


def digest(stream):
    h = hashlib.sha256()
    for data in iter(lambda: stream.read(1024 * 1024), b''):
        h.update(data)
    return h.hexdigest()


def file_digest(path):
    with path.open('rb') as stream:
        return digest(stream)


def preservation_reason(path):
    parts = path.parts
    if len(parts) < 4 or parts[:2] != ('selfhost', 'build'):
        return 'outside historical generated build outputs'
    if parts[2] not in ('phase107', 'phase108', 'phase109'):
        return 'outside requested historical phases'
    if any(p.startswith('p110-') or p == 'phase110' for p in parts):
        return 'current Phase110 output'
    if path.suffix in SOURCE_SUFFIXES:
        return 'source snapshot or tool source'
    if any('source' in p or 'capture' in p or p in ('toolchain', 'sources', 'snapshots') for p in parts[3:-1]):
        return 'source acquisition, capture, or toolchain preserved as a unit'
    if any(p.startswith('production-runtime') for p in parts):
        return 'runtime snapshot preserved as a unit'
    return None


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    candidates, archives, excluded = [], [], []
    seen = set()
    for phase in (107, 108, 109):
        manifest_path = ROOT / f'implementation/phase{phase}/evidence/manifest.json'
        manifest = json.loads(manifest_path.read_text())
        archive_path = manifest_path.parent / 'observations.tar.gz'
        declared_archive = manifest['archive']
        archive_sha = file_digest(archive_path)
        assert archive_sha == declared_archive['sha256'], archive_path
        assert archive_path.stat().st_size == declared_archive['bytes'], archive_path
        archives.append({
            'phase': phase, 'archive': str(archive_path.relative_to(ROOT)),
            'archiveSha256': archive_sha, 'archiveBytes': archive_path.stat().st_size,
            'manifest': str(manifest_path.relative_to(ROOT)),
            'manifestSha256': file_digest(manifest_path),
        })
        proposed = {}
        for row in manifest.get('entries', manifest.get('files', [])):
            name = row.get('file', row.get('path'))
            relative = Path(name)
            if relative.is_absolute() or '..' in relative.parts or name in seen:
                continue
            path = ROOT / relative
            reason = preservation_reason(relative)
            if reason or not path.is_file() or path.is_symlink():
                continue
            s = path.stat()
            if not stat.S_ISREG(s.st_mode) or s.st_mode & 0o111 or not s.st_blocks:
                continue
            if s.st_size != row['bytes'] or file_digest(path) != row['sha256']:
                excluded.append({'path': name, 'reason': 'local bytes differ from sealed manifest'})
                continue
            generated = relative.suffix in GENERATED_SUFFIXES or (
                relative.suffix == '.json' and s.st_size >= 100_000 and
                relative.name not in ('report.json', 'process.json', 'inputs.json', 'method.json')
            )
            proposed[name] = {
                'path': name, 'bytes': s.st_size, 'allocatedBytes': s.st_blocks * 512,
                'localSha256': row['sha256'], 'manifestSha256': row['sha256'],
                'archive': str(archive_path.relative_to(ROOT)), 'member': name,
                'phase': phase, 'tier': 'generated-data' if generated else 'archived-receipt-or-text',
                'localDevice': s.st_dev, 'localInode': s.st_ino, 'localLinks': s.st_nlink,
                'localMtimeNs': s.st_mtime_ns,
            }
        with tarfile.open(archive_path, 'r|gz') as archive:
            for member in archive:
                row = proposed.get(member.name)
                if row is None:
                    continue
                assert 'memberSha256' not in row, ('duplicate archive member', member.name)
                assert member.isfile() and member.size == row['bytes'], member.name
                with archive.extractfile(member) as stream:
                    member_sha = digest(stream)
                assert member_sha == row['localSha256'], member.name
                row['memberSha256'] = member_sha
        for name, row in proposed.items():
            assert row.get('memberSha256') == row['localSha256'], ('missing member', name)
            # A local writer changing bytes during the archive pass invalidates this proposal.
            path = ROOT / name
            s = path.stat()
            assert (s.st_dev, s.st_ino, s.st_size, s.st_mtime_ns) == (
                row['localDevice'], row['localInode'], row['bytes'], row['localMtimeNs']
            ), ('local file changed', name)
            if s.st_nlink != 1:
                excluded.append({'path': name, 'reason': 'multiple local hard links; reclaim not assured'})
                continue
            seen.add(name)
            candidates.append(row)
    candidates.sort(key=lambda r: (r['tier'] != 'generated-data', -r['allocatedBytes'], r['path']))
    totals = {}
    for tier in ('generated-data', 'archived-receipt-or-text'):
        rows = [r for r in candidates if r['tier'] == tier]
        totals[tier] = {'files': len(rows), 'bytes': sum(r['bytes'] for r in rows),
                        'allocatedBytes': sum(r['allocatedBytes'] for r in rows)}
    result = {
        'kind': 'phase110-historical-cleanup-proposal-v1', 'complete': True,
        'createdUtc': datetime.datetime.now(datetime.timezone.utc).isoformat(),
        'executed': False, 'deletionAuthorizedByThisFile': False,
        'scope': 'Only sealed duplicate regular non-executable historical build outputs; no deletion performed.',
        'preserved': ['All Phase110 outputs, including p110-* inside phase108',
                      'All executable files and selected native images',
                      'Source snapshots, source acquisitions, capture directories and toolchains',
                      'Phase109 production runtime snapshots',
                      'All evidence archives and manifests, repository source and tools'],
        'limitations': ['Allocated bytes are st_blocks*512, not a post-deletion measurement.',
                       'Removing local receipts makes historical direct paths unavailable until archive restoration.',
                       'Root must recheck exact path, non-symlink status, bytes and SHA immediately before deletion.',
                       'Existing selected compiler C omitted from capsules is never proposed.'],
        'archives': archives, 'tiers': totals, 'files': len(candidates),
        'bytes': sum(r['bytes'] for r in candidates),
        'allocatedBytes': sum(r['allocatedBytes'] for r in candidates),
        'excluded': excluded, 'candidates': candidates,
    }
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps({k: v for k, v in result.items() if k not in ('candidates', 'excluded')}, indent=2))


if __name__ == '__main__':
    main()
