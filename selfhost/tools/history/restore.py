#!/usr/bin/env python3
"""Recover selected pinned historical files without a worktree or compiler run."""
import argparse
import hashlib
import json
import os
from pathlib import Path, PurePosixPath
import re
import subprocess
from history_data import read_json

ROOT = Path(__file__).resolve().parents[3]
DEFAULT = ROOT / 'selfhost/manifests/history-inventory-v2.json.gz'


def git(*args):
    return subprocess.check_output(['git', '-C', str(ROOT), *args])


def safe_relative(value):
    p = PurePosixPath(value)
    if p.is_absolute() or not value or any(part in ('', '.', '..') for part in value.split('/')):
        raise ValueError('Expected a normalized repository-relative path')
    return p


def select_paths(manifest, requested, archive_group=None):
    if archive_group:
        if requested:
            raise ValueError('Choose explicit paths or one archive group, not both')
        groups = [g for g in manifest.get('archiveGroups', []) if g['archivePath'] == archive_group]
        if len(groups) != 1 or not groups[0]['consecutiveTrackedParts']:
            raise ValueError('Unknown or nonconsecutive split archive group')
        group = groups[0]
        entries = {entry['path']:entry for entry in manifest['files']}
        numbers = [part['partNumber'] for part in group['parts']]
        if not numbers or numbers[0] not in (0,1) or numbers != list(range(numbers[0],numbers[-1]+1)):
            raise ValueError('Archive parts are not in complete numeric order')
        pattern = re.compile(re.escape(archive_group)+r'\.part-?(\d+)$')
        indexed = {path for path in entries if pattern.fullmatch(path)}
        if indexed != {part['path'] for part in group['parts']} or group['partCount'] != len(indexed):
            raise ValueError('Archive group omits or duplicates indexed parts')
        for part in group['parts']:
            entry = entries.get(part['path'])
            match = pattern.fullmatch(part['path'])
            if not entry or not match or int(match[1]) != part['partNumber'] or any(entry[key] != part[key] for key in ('gitBlob','bytes')):
                raise ValueError('Archive group and file index disagree')
        if group['bytes'] != sum(part['bytes'] for part in group['parts']):
            raise ValueError('Archive group size disagrees with file index')
        return [part['path'] for part in group['parts']]
    return requested


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--manifest', type=Path, default=DEFAULT)
    parser.add_argument('--path', action='append', default=[])
    parser.add_argument('--archive-group', help='Restore all pinned parts in numeric order; does not concatenate them')
    parser.add_argument('--list-prefix')
    parser.add_argument('--list-groups', action='store_true')
    parser.add_argument('--out', type=Path)
    parser.add_argument('--max-mib', type=int, default=64)
    args = parser.parse_args()
    manifest = read_json(args.manifest)
    if manifest['schema'] != 'bend-history-inventory-v1':
        raise ValueError('Unsupported history manifest')
    commit = manifest['baselineCommit']
    if git('rev-parse', commit + '^{commit}').decode().strip() != commit:
        raise ValueError('Baseline commit is unavailable')
    entries = {entry['path']: entry for entry in manifest['files']}
    if args.list_groups:
        print(json.dumps(manifest.get('archiveGroups', []), indent=2))
        return
    if args.list_prefix is not None:
        rows = [dict(path=p, action=e['action'], bytes=e['bytes']) for p, e in entries.items()
                if p.startswith(args.list_prefix)]
        print(json.dumps(dict(count=len(rows), files=rows), indent=2))
        return
    requested = select_paths(manifest, args.path, args.archive_group)
    if not requested or len(set(requested)) != len(requested) or len(requested) > 32 or not args.out:
        parser.error('Use 1–32 distinct --path arguments and a fresh --out directory')
    if args.max_mib <= 0:
        parser.error('--max-mib must be positive')
    selected = [entries[str(safe_relative(p))] for p in requested]
    if sum(entry['bytes'] for entry in selected) > args.max_mib * 1024**2:
        raise ValueError('Selected files exceed retrieval budget')
    out = args.out.absolute()
    if out.exists() or out.is_symlink() or not out.parent.is_dir():
        raise ValueError('Output must be a fresh child of an existing directory')
    # Establish membership from the pinned commit, rather than trusting the manifest.
    for entry in selected:
        got = git('ls-tree', '-z', commit, '--', entry['path']).decode().rstrip('\0')
        meta, path = got.split('\t', 1)
        mode, kind, oid = meta.split()
        if path != entry['path'] or kind != 'blob' or oid != entry['gitBlob'] or mode != entry['gitMode']:
            raise ValueError('Manifest/tree identity mismatch: ' + entry['path'])
        if mode not in ('100644', '100755'):
            raise ValueError('Only ordinary files may be restored')
    out.mkdir(mode=0o700)
    receipt = dict(schema='bend-history-restore-v1', baselineCommit=commit,
                   complete=False, targetsRun=False, archiveGroup=args.archive_group, files=[])
    try:
        for entry in selected:
            dest = out / entry['path']
            dest.parent.mkdir(parents=True, exist_ok=True)
            sha = hashlib.sha256()
            git_sha = hashlib.sha1(b'blob ' + str(entry['bytes']).encode() + b'\0')
            count = 0
            with dest.open('xb') as stream:
                child = subprocess.Popen(['git', '-C', str(ROOT), 'cat-file', 'blob', entry['gitBlob']], stdout=subprocess.PIPE)
                try:
                    for block in iter(lambda: child.stdout.read(1024**2), b''):
                        count += len(block)
                        if count > entry['bytes']:
                            raise ValueError('Restored blob exceeds declared size')
                        sha.update(block); git_sha.update(block); stream.write(block)
                except BaseException:
                    child.kill(); child.wait(); raise
                finally:
                    child.stdout.close()
                if child.wait() != 0:
                    raise ValueError('git cat-file failed')
            if count != entry['bytes'] or git_sha.hexdigest() != entry['gitBlob']:
                raise ValueError('Restored blob size/hash mismatch')
            os.chmod(dest, int(entry['gitMode'][-3:], 8))
            receipt['files'].append(dict(path=entry['path'], gitBlob=entry['gitBlob'], bytes=count, sha256=sha.hexdigest()))
        receipt['complete'] = True
    finally:
        (out / 'restore.json').write_text(json.dumps(receipt, indent=2) + '\n')
    print(json.dumps(dict(complete=True, files=len(selected), bytes=sum(r['bytes'] for r in receipt['files']), receipt=str(out/'restore.json'))))


if __name__ == '__main__':
    main()
