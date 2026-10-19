#!/usr/bin/env python3
"""Apply a reviewed exact-byte hardlink proposal, preserving every artifact path.

No target execution. Only immutable artifacts under selfhost/build are admitted.
Record metadata changes: hardlinks share an inode/mtime and must never be edited
in place later; future compiler campaigns must keep using fresh output paths.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import stat
import time
import uuid

ROOT = Path(__file__).resolve().parents[4]
BUILD = ROOT / 'selfhost/build'
EXTENSIONS = {'.mjs', '.js', '.c', '.s', '.ssa', '.o', '.json', '.jsonl', '.log', '.program'}
FORBIDDEN = {'runtime.c', 'runtime.o', 'harness.o'}


def digest(path):
    value = hashlib.sha256()
    with path.open('rb') as stream:
        while block := stream.read(1024 * 1024):
            value.update(block)
    return value.hexdigest()


def identity(path):
    value = path.lstat()
    return dict(file=str(path.relative_to(ROOT)), bytes=value.st_size,
                mode=stat.S_IMODE(value.st_mode), device=value.st_dev,
                inode=value.st_ino, hardlinks=value.st_nlink,
                allocatedBytes=value.st_blocks * 512, mtimeNs=value.st_mtime_ns,
                uid=value.st_uid, gid=value.st_gid)


def checked_path(row):
    supplied = Path(row['file'])
    path = supplied if supplied.is_absolute() else ROOT / supplied
    if '..' in path.parts or not path.is_relative_to(BUILD):
        raise ValueError('Path outside selfhost/build: ' + str(path))
    if path.name in FORBIDDEN or (path.suffix not in EXTENSIONS and path.name != 'program'):
        raise ValueError('Not an admitted generated artifact: ' + str(path))
    if 'toolchain' in path.relative_to(BUILD).parts:
        raise ValueError('Toolchain excluded: ' + str(path))
    # Reject links in every directory as well as the leaf.
    current = ROOT
    for component in path.relative_to(ROOT).parts:
        current = current / component
        if current.is_symlink():
            raise ValueError('Symlink excluded: ' + str(current))
    if not stat.S_ISREG(path.lstat().st_mode):
        raise ValueError('Regular file required: ' + str(path))
    return path


def verify(row, *, expected_inode=True):
    path = checked_path(row)
    before = identity(path)
    keys = ['bytes', 'mode', 'device', 'mtimeNs']
    if expected_inode:
        keys.append('inode')
    for key in keys:
        if before[key] != row[key]:
            raise ValueError(f'Changed {key}: {path}')
    actual = digest(path)
    after = identity(path)
    if before != after or actual != row['sha256']:
        raise ValueError('Changed contents or metadata: ' + str(path))
    return path, after


def attributes(path):
    return {name: os.getxattr(path, name, follow_symlinks=False)
            for name in os.listxattr(path, follow_symlinks=False)}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--proposal', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    proposal_path = args.proposal.resolve()
    proposal = json.loads(proposal_path.read_text())
    if not proposal.get('complete') or proposal.get('mutationsPerformed'):
        raise ValueError('A complete read-only proposal is required')
    out = args.out.resolve()
    if out.exists() or not out.is_relative_to(ROOT):
        raise ValueError('Fresh repository output directory required')
    groups = proposal['groups']
    paths = [row['file'] for group in groups for row in [group['keep'], *group['duplicates']]]
    if len(paths) != len(set(paths)):
        raise ValueError('Each artifact path must occur once')
    out.mkdir(parents=True)
    (out / 'method.py').write_bytes(Path(__file__).read_bytes())
    (out / 'proposal.json').write_bytes(proposal_path.read_bytes())
    record = dict(kind='phase112-exact-generated-artifact-hardlink-dedup', complete=False,
                  proposal=dict(file=str(proposal_path), sha256=digest(proposal_path)),
                  methodSha256=digest(out / 'method.py'), started=time.time(),
                  policy='No artifact path or byte removed; exact content/mode/owner/xattrs preserved. Original inode/mtime recorded. Shared inodes must remain immutable.',
                  preflightComplete=False, replacements=[], recoveredAllocatedBytes=0)
    def save():
        target = out / 'report.json'
        temporary = out / 'report.json.tmp'
        temporary.write_text(json.dumps(record, indent=2) + '\n')
        temporary.replace(target)
    save()
    try:
        # Entire proposal is checked before the first mutation. Recheck each
        # source/destination immediately around its actual replacement too.
        for group in groups:
            keep, ks = verify(group['keep'])
            if group['sha256'] != group['keep']['sha256']:
                raise ValueError('Group/source hash mismatch')
            attrs = attributes(keep)
            for row in group['duplicates']:
                path, ds = verify(row)
                if row['sha256'] != group['sha256'] or ds['bytes'] != ks['bytes']:
                    raise ValueError('Group/destination identity mismatch')
                if (ds['device'], ds['mode'], ds['uid'], ds['gid']) != (ks['device'], ks['mode'], ks['uid'], ks['gid']):
                    raise ValueError('Hardlink metadata mismatch: ' + str(path))
                if ds['hardlinks'] != 1 or ds['inode'] == ks['inode']:
                    raise ValueError('Proposal destination is not an independent inode: ' + str(path))
                if attributes(path) != attrs:
                    raise ValueError('Different extended attributes: ' + str(path))
        record['preflightComplete'] = True
        save()
        for group in groups:
            keep, unused = verify(group['keep'])
            for expected in group['duplicates']:
                path, before = verify(expected)
                source_before = identity(keep)
                if source_before['inode'] != group['keep']['inode'] or digest(keep) != group['sha256']:
                    raise ValueError('Source changed before linking: ' + str(keep))
                temporary = path.with_name(path.name + '.p112-link-' + uuid.uuid4().hex)
                entry = dict(source=identity(keep), original=before,
                             sha256=group['sha256'], temporary=str(temporary.relative_to(ROOT)),
                             status='pending')
                record['replacements'].append(entry)
                save()
                try:
                    os.link(keep, temporary, follow_symlinks=False)
                    linked = identity(temporary)
                    if linked['inode'] != source_before['inode'] or digest(temporary) != group['sha256']:
                        raise ValueError('Temporary hardlink identity mismatch')
                    if identity(path) != before:
                        raise ValueError('Destination changed before atomic replacement')
                    os.replace(temporary, path)
                    after = identity(path)
                    if after['inode'] != source_before['inode'] or digest(path) != group['sha256']:
                        raise ValueError('Replacement verification failed')
                    entry.update(status='complete', after=after, afterSha256=group['sha256'])
                    record['recoveredAllocatedBytes'] += before['allocatedBytes']
                    save()
                finally:
                    if temporary.exists():
                        temporary.unlink()
        record.update(complete=True, finished=time.time())
        save()
        print(json.dumps(dict(complete=True, paths=len(record['replacements']),
                              recoveredAllocatedBytes=record['recoveredAllocatedBytes'])))
    except BaseException as error:
        record.update(error=repr(error), finished=time.time())
        save()
        raise


if __name__ == '__main__':
    main()
