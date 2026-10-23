#!/usr/bin/env python3
"""Propose exact hardlinks for closed generated artifacts; never mutate them.

Output is accepted by phase112/apply-dedup.py after independent review.
Only explicitly closed Phase1..110 build trees are considered, excluding the
Phase130 scan's principal scope. Installed images, runtimes, toolchains, caches,
source snapshots, current campaigns and symlinks are outside this proposal.
"""
import argparse
import collections
import hashlib
import json
import os
from pathlib import Path
import stat
import time

ROOT = Path(__file__).resolve().parents[4]
PHASES = [*range(1, 63), *range(67, 76), *range(77, 94), *range(95, 111)]
SUFFIXES = {'.ssa', '.s', '.o', '.c', '.js', '.mjs'}
EXCLUDED = {'runtime.c', 'runtime.o', 'harness.o'}


def identity(path):
    s = path.lstat()
    return dict(file=str(path.relative_to(ROOT)), bytes=s.st_size,
                mode=stat.S_IMODE(s.st_mode), device=s.st_dev, inode=s.st_ino,
                hardlinks=s.st_nlink, allocatedBytes=s.st_blocks * 512,
                mtimeNs=s.st_mtime_ns, uid=s.st_uid, gid=s.st_gid)


def digest(path):
    h = hashlib.sha256()
    with path.open('rb') as stream:
        while block := stream.read(1048576):
            h.update(block)
    return h.hexdigest()


def equal(left, right):
    with left.open('rb') as a, right.open('rb') as b:
        while True:
            x, y = a.read(1048576), b.read(1048576)
            if x != y:
                return False
            if not x:
                return True


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--out', type=Path, required=True)
    ap.add_argument('--recovery-mib', type=int, default=800)
    a = ap.parse_args()
    if not 1 <= a.recovery_mib <= 1024:
        raise ValueError('Recovery target must be 1..1024MiB')
    out = a.out.absolute()
    if out.exists() or not out.is_relative_to(ROOT / 'selfhost/build/phase131'):
        raise ValueError('Fresh Phase131 proposal required')
    if out != out.resolve():
        raise ValueError('Output must not traverse symlinks')
    start = time.monotonic()
    bins, seen = collections.defaultdict(list), set()
    for phase in PHASES:
        base = ROOT / 'selfhost/build' / f'phase{phase}'
        if base.is_symlink():
            continue
        for directory, dirs, files in os.walk(base, followlinks=False):
            dirs[:] = [d for d in dirs if d != 'toolchain'
                       and not (Path(directory) / d).is_symlink()]
            for name in files:
                path = Path(directory) / name
                if path.suffix not in SUFFIXES or name in EXCLUDED:
                    continue
                s = path.lstat()
                inode = (s.st_dev, s.st_ino)
                if not stat.S_ISREG(s.st_mode) or s.st_size < 65536 or inode in seen:
                    continue
                seen.add(inode)
                before = identity(path)
                attrs = {n: os.getxattr(path, n, follow_symlinks=False).hex()
                         for n in sorted(os.listxattr(path, follow_symlinks=False))}
                if before != identity(path):
                    raise ValueError('Artifact changed during metadata scan')
                row = dict(before, xattrs=attrs)
                key = (s.st_size, s.st_dev, row['mode'], s.st_uid, s.st_gid,
                       tuple(attrs.items()))
                bins[key].append((path, row))
    bins = [rows for rows in bins.values() if len(rows) > 1]
    bins.sort(key=lambda rows: sum(r['allocatedBytes'] for _, r in rows
                                  if r['hardlinks'] == 1), reverse=True)
    groups, total, hashed = [], 0, 0
    for rows in bins:
        hashes = collections.defaultdict(list)
        for path, row in rows:
            if any(identity(path)[k] != row[k] for k in identity(path)):
                raise ValueError('Artifact changed before hashing')
            sha = digest(path)
            hashed += row['bytes']
            if any(identity(path)[k] != row[k] for k in identity(path)):
                raise ValueError('Artifact changed while hashing')
            hashes[sha].append((path, dict(row, sha256=sha)))
        for sha, items in hashes.items():
            if len(items) < 2:
                continue
            items.sort(key=lambda item: (item[1]['hardlinks'] == 1, item[1]['file']))
            keeper, keep = items[0]
            duplicates = []
            for path, row in items[1:]:
                if row['hardlinks'] != 1:
                    continue
                if not equal(keeper, path):
                    raise ValueError('SHA256 collision or concurrent mutation')
                if any(identity(path)[k] != row[k] for k in identity(path)):
                    raise ValueError('Artifact changed during byte comparison')
                duplicates.append(row)
                total += row['allocatedBytes']
                if total >= a.recovery_mib * 1048576:
                    break
            if duplicates:
                groups.append(dict(sha256=sha, keep=keep, duplicates=duplicates))
            if total >= a.recovery_mib * 1048576:
                break
        if total >= a.recovery_mib * 1048576:
            break
    report = dict(kind='phase131-readonly-exact-generated-artifact-dedup-proposal',
                  complete=True, mutationsPerformed=False, groups=groups,
                  expectedRecoveredAllocatedBytes=total,
                  duplicatePaths=sum(len(g['duplicates']) for g in groups),
                  hashedBytes=hashed, seconds=time.monotonic() - start,
                  method=dict(file=str(Path(__file__).relative_to(ROOT)),
                              sha256=digest(Path(__file__))),
                  scope=dict(phases=PHASES, suffixes=sorted(SUFFIXES), minimumBytes=65536,
                             excludes=sorted(EXCLUDED | {'toolchain', 'symlinks'})),
                  policy='Proposal only. SHA256 and streamed byte equality; matching mode, '
                  'owner, device and xattrs; destinations have one link. Root must '
                  'reverify identities before atomic hardlinks. Every path and byte '
                  'must survive. Shared inodes must remain immutable.')
    out.parent.mkdir(parents=True, exist_ok=True)
    with out.open('x') as stream:
        json.dump(report, stream, indent=2)
        stream.write('\n')
    print(json.dumps({k: report[k] for k in ['expectedRecoveredAllocatedBytes',
                                          'duplicatePaths', 'hashedBytes', 'seconds']}))


if __name__ == '__main__':
    main()
