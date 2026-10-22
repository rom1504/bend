"""Byte-checked hardlink deduplication of frozen Phase125 artifacts; paths survive."""
import argparse
from collections import defaultdict
import hashlib
import json
import os
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
EXT = {'.ssa', '.s', '.o', '.mjs', '.bend', '.c', '.stdout', '.stderr', '.json'}


def digest(path):
    value = hashlib.sha256()
    with path.open('rb') as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b''):
            value.update(chunk)
    return value.hexdigest()


def equal(a, b):
    with a.open('rb') as left, b.open('rb') as right:
        while True:
            x, y = left.read(1024 * 1024), right.read(1024 * 1024)
            if x != y:
                return False
            if not x:
                return True


def stat(path):
    s = path.stat()
    return dict(device=s.st_dev, inode=s.st_ino, links=s.st_nlink, bytes=s.st_size,
                allocated=s.st_blocks * 512, mode=s.st_mode, uid=s.st_uid,
                gid=s.st_gid, mtimeNs=s.st_mtime_ns)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--apply', action='store_true')
    args = parser.parse_args()
    out = args.out.resolve()
    assert not out.exists() and out.is_relative_to(ROOT / 'selfhost/build/phase126')
    roots = [ROOT / 'selfhost/build/phase125']
    for phase in ('phase118', 'phase111'):
        roots.extend(sorted((ROOT / 'selfhost/build' / phase).glob('p125-*')))
    groups = defaultdict(list)
    for root in roots:
        if not root.is_dir():
            continue
        for path in root.rglob('*'):
            if path.is_symlink() or not path.is_file() or (path.suffix not in EXT and path.name != 'program'):
                continue
            s = stat(path)
            if s['bytes'] >= 65536:
                groups[tuple(s[key] for key in ('device', 'bytes', 'mode', 'uid', 'gid'))].append((path, s))
    plan, seen = [], {}
    for rows in groups.values():
        if len({row[1]['inode'] for row in rows}) < 2:
            continue
        hashes = defaultdict(list)
        for path, s in rows:
            identity = (s['device'], s['inode'])
            if identity not in seen:
                seen[identity] = digest(path)
            hashes[seen[identity]].append((path, s))
        for sha, members in hashes.items():
            members.sort(key=lambda item: (-item[1]['links'], str(item[0])))
            keep, ks = members[0]
            for path, s in members[1:]:
                if s['inode'] != ks['inode']:
                    assert equal(keep, path), 'Equal hashes but unequal bytes'
                    plan.append(dict(keep=str(keep), file=str(path), sha256=sha,
                                     keeperBefore=ks, before=s))
    out.mkdir(parents=True)
    report = dict(complete=False, applied=args.apply, method=str(Path(__file__).resolve()),
                  methodSha256=digest(Path(__file__)), roots=list(map(str, roots)),
                  minimumBytes=65536, hashAndByteEquality=True, plan=plan, results=[],
                  scope='Only frozen Phase125 paths; no bytes deleted or modified. Each replacement is a hardlink after independent SHA256 and byte comparison. Inode/mtime may change; every original path remains.')
    save = lambda: (out / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
    save()
    reclaimed = 0
    if args.apply:
        for row in plan:
            keep, path = Path(row['keep']), Path(row['file'])
            before = stat(path)
            assert all(before[k] == row['before'][k] for k in ('device', 'inode', 'bytes', 'mode', 'uid', 'gid', 'mtimeNs'))
            assert digest(keep) == row['sha256'] == digest(path) and equal(keep, path)
            temp = path.with_name(path.name + '.p126-hardlink-tmp')
            assert not temp.exists()
            os.link(keep, temp)
            os.replace(temp, path)
            after = stat(path)
            assert after['inode'] == stat(keep)['inode'] and digest(path) == row['sha256']
            freed = before['allocated'] if before['links'] == 1 else 0
            reclaimed += freed
            report['results'].append(dict(file=str(path), after=after, unlinkedDuplicateAllocatedBytes=freed))
            save()
    report.update(complete=True, duplicatePaths=len(plan), reclaimedAllocatedBytes=reclaimed)
    save()
    print(json.dumps({key: report[key] for key in ('complete', 'applied', 'duplicatePaths', 'reclaimedAllocatedBytes')}))


if __name__ == '__main__':
    main()
