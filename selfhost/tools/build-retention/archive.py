#!/usr/bin/env python3
"""Verify, prune and restore explicit files already preserved in a closed archive.

Never deletes a directory. Uses the unchanged compiler execution lock. All
archive bytes and members are authenticated before a deletion plan is issued.
"""
import argparse
import collections
import contextlib
import fcntl
import gzip
import hashlib
import io
import json
import os
from pathlib import Path, PurePosixPath
import shutil
import stat
import tarfile
import tempfile
import time

ROOT = Path(__file__).resolve().parents[3]
LOCK = ROOT/'selfhost/build/phase32/execution.lock'


def need(value, message):
    if not value:
        raise ValueError(message)


def digest(stream):
    h, size = hashlib.sha256(), 0
    while block := stream.read(1024*1024):
        h.update(block)
        size += len(block)
    return dict(bytes=size, sha256=h.hexdigest())


def pin(path):
    path = Path(path).absolute()
    need(path.resolve() == path and path.is_file(), 'Not a regular unsymlinked input: '+str(path))
    with path.open('rb') as stream:
        return dict(file=str(path), **digest(stream))


def authenticate(item):
    need(pin(item['file']) == item, 'Changed pinned input: '+item['file'])
    return Path(item['file'])


def safe_relative(value):
    p = PurePosixPath(value)
    need(value and not p.is_absolute() and '..' not in p.parts and str(p) == value, 'Unsafe relative path: '+value)
    return p


def target(root, member):
    p = root/str(safe_relative(member))
    need(p.resolve() == p and p.is_relative_to(root), 'Symlinked/outside artifact path')
    return p


def metadata(path):
    need(path.resolve() == path, 'Symlinked artifact path')
    s = path.lstat()
    need(stat.S_ISREG(s.st_mode), 'Not regular')
    need(s.st_nlink == 1, 'Shared inode')
    need(s.st_uid == os.geteuid() and s.st_gid == os.getegid(), 'Different owner/group')
    need(not stat.S_IMODE(s.st_mode) & 0o7000, 'Special permission bits')
    need(not os.listxattr(path, follow_symlinks=False), 'Nonempty extended attributes')
    return dict(device=s.st_dev, inode=s.st_ino, size=s.st_size, mode=stat.S_IMODE(s.st_mode),
                uid=s.st_uid, gid=s.st_gid, links=s.st_nlink, mtimeNs=s.st_mtime_ns,
                ctimeNs=s.st_ctime_ns, allocatedBytes=s.st_blocks*512)


def write_new(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open('x') as stream:
        json.dump(data, stream, indent=2)
        stream.write('\n')
        stream.flush()
        os.fsync(stream.fileno())


@contextlib.contextmanager
def exclusive():
    need(LOCK.is_file() and LOCK.resolve() == LOCK, 'Existing shared lock required')
    with LOCK.open('a') as lock:
        fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        inode = LOCK.stat().st_ino
        try:
            yield
            need(LOCK.stat().st_ino == inode, 'Shared lock replaced')
        finally:
            fcntl.flock(lock, fcntl.LOCK_UN)


class Parts(io.RawIOBase):
    """Bounded concatenation of existing authenticated archive transport parts."""
    def __init__(self, paths):
        self.paths = iter(paths)
        self.current = None

    def readable(self):
        return True

    def readinto(self, view):
        while True:
            if self.current is None:
                p = next(self.paths, None)
                if p is None:
                    return 0
                self.current = p.open('rb')
            count = self.current.readinto(view)
            if count:
                return count
            self.current.close()
            self.current = None

    def close(self):
        if self.current:
            self.current.close()
        super().close()


def archive_parts(receipt_path, receipt):
    authority = receipt['archive']
    if authority.get('parts'):
        paths = [ROOT/str(safe_relative(p['file'])) for p in authority['parts']]
        for p,item in zip(paths, authority['parts']):
            need({k:pin(p)[k] for k in ['bytes','sha256']} == {k:item[k] for k in ['bytes','sha256']}, 'Transport part mismatch')
    else:
        full = ROOT/str(safe_relative(authority['file'])) if authority.get('file') else receipt_path.parent/str(safe_relative(authority['path']))
        if full.exists():
            paths = [full]
        else:
            paths = sorted(full.parent.glob(full.name+'.part-*'))
            need(paths and [p.name for p in paths] == [full.name+f'.part-{i:03d}' for i in range(len(paths))], 'Missing/noncontiguous archive parts')
    pins = [pin(p) for p in paths]
    with Parts(paths) as stream:
        need(digest(stream) == {k:receipt['archive'][k] for k in ['bytes','sha256']}, 'Archive stream digest mismatch')
    return paths, pins


def context(receipt_path, receipt, policy):
    named = str(receipt_path.relative_to(ROOT))
    root = ROOT/str(safe_relative(policy['archiveRoots'][named]))
    need(str(root.relative_to(ROOT)) in policy['allowedRoots'], 'Archive root not authorized')
    need(root.resolve() == root and root.is_relative_to(ROOT/'selfhost/build'), 'Invalid archive root')
    need(receipt.get('complete'), 'Completed archive required')
    relative = isinstance(receipt['files'],dict)
    if relative:
        need(Path(receipt['rawRoot']) == root and receipt.get('reopenedVerified') and receipt.get('inputStabilityVerified'), 'Unverified root-relative archive')
        files = receipt['files']
        need(len(files) == receipt['members'], 'Wrong member count')
    else:
        need(receipt.get('reopenedAllMembers') and receipt.get('inputInventoryAndHashesUnchanged'), 'Unverified repository archive')
        files = {r['file']:{k:r[k] for k in ['bytes','sha256']} for r in receipt['files']}
        need(len(files) == len(receipt['files']) == receipt['fileCount'], 'Duplicate/wrong member count')
    for name in files:
        safe_relative(name)
    excluded = [ROOT/str(safe_relative(p)) for p in policy['keepPrefixes']]
    def references(value):
        if isinstance(value,dict):
            if isinstance(value.get('file'),str):
                p = Path(value['file'])
                excluded.append(p if p.is_absolute() else ROOT/p)
            for child in value.values(): references(child)
        elif isinstance(value,list):
            for child in value: references(child)
    for key in ['writersClosed','protectedFinal','protectedStart','attempt','api','writerClosure','protectedPredecessors']:
        references(receipt.get(key))
    return root,files,relative,excluded


def member_relative(root,name,relative):
    safe_relative(name)
    if relative:
        return name
    p = ROOT/name
    return str(p.relative_to(root)) if p.is_relative_to(root) else None


def plan_files(plan):
    data = authenticate(plan['files'])
    with data.open() as source:
        for line in source:
            yield json.loads(line)


def verify(args):
    policy_pin = pin(args.policy)
    method_pin = pin(__file__)
    policy = json.loads(authenticate(policy_pin).read_text())
    receipt_path = args.receipt.absolute()
    receipt_pin = pin(receipt_path)
    receipt = json.loads(receipt_path.read_text())
    root,files,relative,excluded = context(receipt_path,receipt,policy)
    paths, pins = archive_parts(receipt_path, receipt)
    args.out.mkdir(parents=True, exist_ok=False)
    selected = args.out/'files.jsonl'
    reasons, seen, accepted, allocated, logical = collections.Counter(), set(), 0, 0, 0
    begin = time.monotonic()
    with selected.open('x') as listing, Parts(paths) as compressed, gzip.GzipFile(fileobj=compressed) as decoded, tarfile.open(fileobj=decoded, mode='r|') as tar:
        for member in tar:
            need(member.name not in seen and member.name in files and member.isfile(), 'Unexpected/duplicate/nonregular archive member')
            seen.add(member.name)
            expected = files[member.name]
            with tar.extractfile(member) as stream:
                need(digest(stream) == expected, 'Archive member differs: '+member.name)
            rel = member_relative(root,member.name,relative)
            if rel is None:
                reasons['outside-approved-root'] += 1
                continue
            p = target(root,rel)
            if any(p == keep or p.is_relative_to(keep) for keep in excluded):
                reasons['protected'] += 1
                continue
            if not p.exists():
                reasons['already-absent'] += 1
                continue
            try:
                info = metadata(p)
            except ValueError as error:
                reasons[str(error)] += 1
                continue
            current = pin(p)
            need(metadata(p) == info, 'Artifact changed during verification')
            if {k:current[k] for k in ['bytes','sha256']} != expected:
                reasons['changed-since-archive'] += 1
                continue
            row = dict(member=member.name, relative=rel, file=current, metadata=info, archiveMode=member.mode)
            listing.write(json.dumps(row,separators=(',',':'))+'\n')
            accepted += 1
            allocated += info['allocatedBytes']
            logical += current['bytes']
        listing.flush()
        os.fsync(listing.fileno())
        while decoded.read(1024*1024):
            pass  # Validate complete gzip footer/CRC, including transport parts.
    need(seen == set(files), 'Missing archive members')
    authenticate(receipt_pin)
    authenticate(policy_pin)
    authenticate(method_pin)
    for item in pins:
        authenticate(item)
    report = dict(kind='build-retention-verified-prune-plan-v1', complete=True, root=str(root),
                  method=method_pin, policy=policy_pin, archiveReceipt=receipt_pin, archiveParts=pins,
                  files=pin(selected), selectedFiles=accepted, allocatedBytes=allocated, logicalBytes=logical,
                  kept=dict(reasons), archiveMembers=len(seen), seconds=time.monotonic()-begin,
                  scope='All archive members verified; selected current exclusive regular files match exact archived bytes. Original current modes/owner/time are preserved in this plan. No deletion.')
    write_new(args.out/'plan.json', report)
    return report


def checked_plan(path):
    plan = json.loads(path.read_text())
    need(plan['complete'] and plan['kind'] == 'build-retention-verified-prune-plan-v1', 'Verified plan required')
    authenticate(plan['method'])
    authenticate(plan['policy'])
    receipt_path = authenticate(plan['archiveReceipt'])
    for item in plan['archiveParts']:
        authenticate(item)
    policy = json.loads(Path(plan['policy']['file']).read_text())
    receipt = json.loads(receipt_path.read_text())
    root,files,relative,excluded = context(receipt_path,receipt,policy)
    need(str(root) == plan['root'], 'Plan changes archive root')
    _,parts = archive_parts(receipt_path,receipt)
    need(parts == plan['archiveParts'], 'Plan changes archive parts')
    seen = set()
    for row in plan_files(plan):
        name = row['member']
        need(name not in seen and name in files, 'Duplicate/unarchived plan member')
        seen.add(name)
        rel = member_relative(root,name,relative)
        need(rel is not None and rel == row['relative'], 'Plan changes archive-relative identity')
        p = target(root,rel)
        need(str(p) == row['file']['file'] and {k:row['file'][k] for k in ['bytes','sha256']} == files[name], 'Plan changes archive bytes/path')
        need(not any(p == keep or p.is_relative_to(keep) for keep in excluded), 'Plan selects protected path')
    need(len(seen) == plan['selectedFiles'], 'Plan selected count differs')
    return plan, root


def apply(args):
    plan, root = checked_plan(args.plan)
    rows = list(plan_files(plan))
    # Revalidate every row before issuing durable, complete intent. No partial
    # deletion due to a stale plan discovered late in preflight.
    for row in rows:
        p = target(root, row['relative'])
        need(str(p) == row['file']['file'] and metadata(p) == row['metadata'], 'Stale plan metadata')
        authenticate(row['file'])
    args.out.mkdir(parents=True, exist_ok=False)
    before = shutil.disk_usage(ROOT).free
    intent = dict(kind='build-retention-prune-intent-v1', complete=True, plan=pin(args.plan),
                  files=plan['files'], selectedFiles=len(rows), authorizedPolicy=plan['policy'], freeBeforeBytes=before)
    write_new(args.out/'intent.json', intent)
    removed = 0
    begin = time.monotonic()
    report = dict(kind='build-retention-prune-result-v1', complete=False, plan=pin(args.plan), intent=pin(args.out/'intent.json'))
    try:
        with (args.out/'journal.jsonl').open('x') as journal:
            for row in rows:
                p = target(root, row['relative'])
                need(metadata(p) == row['metadata'], 'Artifact changed before unlink')
                p.unlink()
                removed += 1
                journal.write(json.dumps(dict(member=row['member'],removed=True),separators=(',',':'))+'\n')
                if removed % 256 == 0:
                    journal.flush()
                    os.fsync(journal.fileno())
            journal.flush()
            os.fsync(journal.fileno())
        report['complete'] = True
    finally:
        report.update(removedFiles=removed, freeBeforeBytes=before, freeAfterBytes=shutil.disk_usage(ROOT).free,
                      selectedAllocatedBytes=plan['allocatedBytes'], seconds=time.monotonic()-begin,
                      scope='Files only; empty directories retained. Exact recovery uses pinned archive members and plan metadata. Interrupted intents retain the entire removal allowlist.')
        write_new(args.out/'report.json', report)
    return report


def restore(args):
    plan, root = checked_plan(args.plan)
    rows = {r['member']:r for r in plan_files(plan)}
    if args.member:
        need(all(n in rows for n in args.member), 'Member outside plan')
        rows = {n:rows[n] for n in args.member}
    destination = args.destination.absolute() if args.destination else root
    need(destination.resolve() == destination and destination.is_relative_to(ROOT), 'Invalid restoration destination')
    args.out.mkdir(parents=True, exist_ok=False)
    paths = [Path(p['file']) for p in plan['archiveParts']]
    seen, restored, already = set(), 0, 0
    with Parts(paths) as compressed, gzip.GzipFile(fileobj=compressed) as decoded, tarfile.open(fileobj=decoded, mode='r|') as tar:
        for member in tar:
            if member.name not in rows:
                continue
            need(member.isfile() and member.name not in seen, 'Duplicate/nonregular restore member')
            seen.add(member.name)
            row = rows[member.name]
            p = target(destination,row['relative'])
            if p.exists():
                need({k:pin(p)[k] for k in ['bytes','sha256']} == {k:row['file'][k] for k in ['bytes','sha256']}, 'Restore refuses changed existing content')
                need(stat.S_IMODE(p.stat().st_mode) == row['metadata']['mode'], 'Restore refuses different existing mode')
                already += 1
                continue
            p.parent.mkdir(parents=True, exist_ok=True)
            need(p.parent.resolve() == p.parent, 'Symlinked restore parent')
            fd, temporary = tempfile.mkstemp(prefix='.retention-',dir=p.parent)
            try:
                h, size = hashlib.sha256(), 0
                with os.fdopen(fd,'wb') as output, tar.extractfile(member) as stream:
                    while block := stream.read(1024*1024):
                        output.write(block)
                        h.update(block)
                        size += len(block)
                    output.flush()
                    os.fsync(output.fileno())
                need((size,h.hexdigest()) == (row['file']['bytes'],row['file']['sha256']), 'Restore byte mismatch')
                need((os.geteuid(),os.getegid()) == (row['metadata']['uid'],row['metadata']['gid']), 'Restore owner/group unavailable')
                os.chmod(temporary,row['metadata']['mode'])
                os.utime(temporary,ns=(row['metadata']['mtimeNs'],row['metadata']['mtimeNs']))
                os.link(temporary,p)  # Publish without overwrite.
                restored += 1
            finally:
                os.unlink(temporary)
        while decoded.read(1024*1024):
            pass
    need(seen == set(rows), 'Restore member missing')
    result = dict(kind='build-retention-restore-v1', complete=True, plan=pin(args.plan), destination=str(destination),
                  restored=restored,alreadyExact=already, restoredMembers=sorted(rows))
    write_new(args.out/'report.json',result)
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest='command',required=True)
    check = sub.add_parser('verify')
    check.add_argument('--policy',type=Path,required=True)
    check.add_argument('--receipt',type=Path,required=True)
    for name in ['apply','restore']:
        p = sub.add_parser(name)
        p.add_argument('--plan',type=Path,required=True)
        if name == 'restore':
            p.add_argument('--member',action='append')
            p.add_argument('--destination',type=Path)
    for p in sub.choices.values():
        p.add_argument('--out',type=Path,required=True)
    args = parser.parse_args()
    args.out = args.out.absolute()
    need(args.out.resolve() == args.out and args.out.is_relative_to(ROOT/'selfhost/build-retention') and not args.out.exists(), 'Fresh retention receipt directory required')
    with exclusive():
        result = {'verify':verify,'apply':apply,'restore':restore}[args.command](args)
    print(json.dumps({k:result[k] for k in ['kind','complete','selectedFiles','allocatedBytes','kept','removedFiles','restored','seconds'] if k in result}))


if __name__ == '__main__':
    main()
