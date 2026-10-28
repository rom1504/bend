#!/usr/bin/env python3
"""Close an explicitly classified guarded run into verified, restorable capsules.

Qualified roots always stay hot. Other roots are archived unless explicitly
kept; pruning requires --prune and the same authenticated archive verifier/applier
used for historical cleanup. No age-based deletion or compiler work occurs.
"""
import argparse
import gzip
import importlib.util
import json
import os
from pathlib import Path
import shutil
import stat
import tarfile
import tempfile
import time

ROOT = Path(__file__).resolve().parents[3]
ARCHIVE = Path(__file__).with_name('archive-v02.py')
spec = importlib.util.spec_from_file_location('close_archive', ARCHIVE)
A = importlib.util.module_from_spec(spec)
spec.loader.exec_module(A)
MIB = 1024**2
MAX_RAW = 1024*MIB
MAX_FILES = 100000
RESERVE = 512*MIB


def free_space():
    return shutil.disk_usage(ROOT).free


class Budget:
    def __init__(self):
        self.next_check = 0
        self.minimum = free_space()

    def check(self, *, additional=0, force=False):
        if force or time.monotonic() >= self.next_check:
            free = free_space()
            self.minimum = min(self.minimum, free)
            A.need(free >= RESERVE+additional, 'Insufficient archive scratch space/reserve')
            self.next_check = time.monotonic()+.1


class CheckedIO:
    def __init__(self, stream, budget):
        self.stream, self.budget = stream, budget

    def read(self, size=-1):
        self.budget.check()
        return self.stream.read(size)

    def write(self, data):
        self.budget.check()
        return self.stream.write(data)

    def __getattr__(self, name):
        return getattr(self.stream, name)


def signature(path):
    A.need(path.resolve() == path, 'Symlinked artifact')
    value = path.lstat()
    A.need(stat.S_ISREG(value.st_mode), 'Archive only regular files')
    return tuple(getattr(value,key) for key in ['st_dev','st_ino','st_mode','st_uid','st_gid','st_nlink','st_size','st_mtime_ns','st_ctime_ns'])


def inventory(root, budget):
    if not root.exists():
        return []
    A.need(root.is_dir() and root.resolve() == root, 'Artifact root must be an unsymlinked directory')
    rows, raw = [], 0
    for current, dirs, files in os.walk(root, followlinks=False):
        budget.check()
        for name in dirs:
            A.need(not (Path(current)/name).is_symlink(), 'Symlinked artifact directory')
        for name in sorted(files):
            path = Path(current)/name
            before = signature(path)
            raw += path.stat().st_size
            A.need(raw <= MAX_RAW and len(rows) < MAX_FILES, 'Root exceeds1GiB/100000-file closure limit; subdivide the run')
            with path.open('rb') as source:
                identity = A.digest(CheckedIO(source,budget))
            A.need(signature(path) == before, 'Artifact changed during inventory')
            rows.append(dict(path=path, name=str(path.relative_to(root)), signature=before, identity=identity))
    return sorted(rows,key=lambda row:row['name'])


def unchanged(rows):
    for row in rows:
        A.need(signature(row['path']) == row['signature'], 'Artifact changed while closing')
        current = A.pin(row['path'])
        A.need({k:current[k] for k in ['bytes','sha256']} == row['identity'], 'Artifact content changed while closing')


def capsule(root, rows, out, budget):
    # Includes tar/PAX headers, JSON verification plans and compression overhead.
    scratch = sum(r['identity']['bytes']+max(8192,len(r['name'].encode())+4096) for r in rows)+16*MIB
    budget.check(additional=scratch,force=True)
    out.mkdir()
    archive = out/'files.tar.gz'
    with archive.open('xb') as raw, gzip.GzipFile(filename='',mode='wb',fileobj=CheckedIO(raw,budget),mtime=0,compresslevel=1) as encoded, tarfile.open(fileobj=encoded,mode='w|') as tar:
        for row in rows:
            A.need(signature(row['path']) == row['signature'], 'Artifact changed before archiving')
            # Explicit regular headers preserve every hardlink alias as bytes;
            # archive.verify retains shared current inodes instead of pruning.
            info = tarfile.TarInfo(row['name'])
            current = row['path'].stat()
            info.size = row['identity']['bytes']
            info.mode = stat.S_IMODE(current.st_mode)
            info.uid,info.gid,info.mtime = current.st_uid,current.st_gid,int(current.st_mtime)
            with row['path'].open('rb') as source:
                tar.addfile(info,CheckedIO(source,budget))
            A.need(signature(row['path']) == row['signature'], 'Artifact changed during archiving')
    with archive.open('rb') as stream:
        os.fsync(stream.fileno())
    expected = {r['name']:r['identity'] for r in rows}
    seen = set()
    with archive.open('rb') as raw, gzip.GzipFile(fileobj=CheckedIO(raw,budget)) as decoded, tarfile.open(fileobj=decoded,mode='r|') as tar:
        for member in tar:
            A.need(member.isfile() and member.name in expected and member.name not in seen, 'Unexpected archive member')
            seen.add(member.name)
            with tar.extractfile(member) as stream:
                A.need(A.digest(stream) == expected[member.name], 'Archive roundtrip differs')
        while decoded.read(MIB):
            budget.check()
    A.need(seen == set(expected), 'Archive omitted a member')
    unchanged(rows)
    budget.check(force=True)
    identity = A.pin(archive)
    receipt = dict(kind='build-retention-run-capsule-v1',complete=True,rawRoot=str(root),
                   archive=dict(path=archive.name,bytes=identity['bytes'],sha256=identity['sha256']),
                   files=expected,members=len(rows),reopenedVerified=True,inputStabilityVerified=True,
                   method=A.pin(__file__),created=time.time(),
                   scope='Exact regular-file bytes, modes and full member verification. Directories remain hot; no symlinks admitted. Shared/special files may be archived but remain unpruned.')
    A.write_new(out/'receipt.json',receipt)
    return out/'receipt.json'


def close(args):
    A.need(args.classification in ['qualified','completed','rejected','failed'], 'Explicit closure classification required')
    run,out = args.run.absolute(),args.out.absolute()
    A.need(run.resolve() == run and run.is_relative_to(ROOT/'selfhost/build'), 'Guard directory must be inside selfhost/build')
    A.need(out.resolve() == out and out.is_relative_to(ROOT/'selfhost/build-retention') and not out.exists(), 'Fresh retention output required')
    retention_path,process_path = run/'retention.json',run/'process.json'
    initial,process_pin = A.pin(retention_path),A.pin(process_path)
    state,process = json.loads(retention_path.read_text()),json.loads(process_path.read_text())
    A.need(state['kind'] == 'build-retention-run-v1' and state['state'] == 'finished' and not state['closed'], 'Only an unfinished close of a finished guarded run is admitted')
    A.need(process['kind'] == 'build-retention-disk-guard-v1' and 'finished' in process and
           state['guardDirectory'] == str(run) and state['artifactRoots'] == process['artifactRoots'], 'Guard/lifecycle identity mismatch')
    roots = [Path(path) for path in state['artifactRoots']]
    A.need(roots and len(roots) == len(set(roots)), 'Distinct artifact roots required')
    for root in roots:
        A.need(root.is_absolute() and root.resolve() == root and root.is_relative_to(ROOT/'selfhost/build'), 'Invalid artifact root')
        A.need(not (root == run or root in run.parents or run in root.parents), 'Guard logs must remain separate and hot')
        A.need(not (root == A.LOCK or root in A.LOCK.parents or A.LOCK in root.parents), 'Never archive execution lock state')
    A.need(not any(a in b.parents or b in a.parents for i,a in enumerate(roots) for b in roots[i+1:]), 'Overlapping artifact roots')
    kept = {path.absolute() for path in args.keep_root}
    A.need(kept <= set(roots), '--keep-root must name an exact declared artifact root')
    qualification = None
    if args.classification == 'qualified':
        A.need(not args.prune and args.qualification is not None and process['complete'], 'Qualified closure requires a successful run, explicit qualification receipt and no pruning')
        qualification = A.pin(args.qualification)
        A.need(json.loads(A.authenticate(qualification).read_text()).get('complete') is True, 'Completed qualification receipt required')
        kept = set(roots)
    elif args.classification == 'completed':
        A.need(process['complete'], 'Completed classification requires a successful guarded command')
    A.need(args.qualification is None or qualification is not None, 'Qualification receipt only applies to qualified closure')
    out.mkdir(parents=True)
    budget = Budget()
    result = dict(kind='build-retention-run-close-v1',complete=False,state='closing',classification=args.classification,
                  initialRetention=initial,process=process_pin,method=A.pin(__file__),archiveMethod=A.pin(ARCHIVE),
                  qualification=qualification,pruneRequested=args.prune,roots=[],started=time.time(),
                  guardCommitRequired='Close is committed only when guard retention.json names this report; process.json remains immutable.')
    A.write_new(out/'intent.json',result)
    try:
        inventories = {root:inventory(root,budget) for root in roots if root not in kept}
        plans = []
        for index,root in enumerate(roots):
            row = dict(root=str(root),keptHot=root in kept)
            result['roots'].append(row)
            if root in kept:
                continue
            rows = inventories[root]
            if not rows:
                row.update(emptyOrAbsent=True, archivedFiles=0)
                continue
            receipt = capsule(root,rows,out/f'root-{index:02d}',budget)
            row.update(archiveReceipt=A.pin(receipt),archivedFiles=len(rows))
            policy = dict(allowedRoots=[str(root.relative_to(ROOT))],
                          archiveRoots={str(receipt.relative_to(ROOT)):str(root.relative_to(ROOT))},
                          keepPrefixes=[str(path.relative_to(ROOT)) for path in sorted(kept)])
            policy_path = out/f'root-{index:02d}'/'policy.json'
            A.write_new(policy_path,policy)
            check_out = out/f'root-{index:02d}'/'verified'
            verified = A.verify(argparse.Namespace(policy=policy_path,receipt=receipt,out=check_out))
            row.update(plan=A.pin(check_out/'plan.json'),prunableFiles=verified['selectedFiles'],kept=verified['kept'])
            plans.append((row,check_out/'plan.json',out/f'root-{index:02d}'/'pruned'))
            budget.check(force=True)
        # Authenticate all sources and close inputs before the first unlink.
        for rows in inventories.values():
            unchanged(rows)
        A.authenticate(initial)
        A.authenticate(process_pin)
        if args.prune:
            for row,plan,prune_out in plans:
                budget.check(force=True)
                applied = A.apply(argparse.Namespace(plan=plan,out=prune_out))
                A.need(applied['complete'], 'Incomplete archive prune')
                row.update(pruneReceipt=A.pin(prune_out/'report.json'),removedFiles=applied['removedFiles'])
        A.authenticate(initial)
        A.authenticate(process_pin)
        result.update(complete=True,state='sealed',finished=time.time(),minimumDiskFreeBytes=budget.minimum)
        A.write_new(out/'report.json',result)
        # The report remains immutable. This one atomic lifecycle update is the
        # commit point; a crash before it leaves the run explicitly unclosed.
        revised = dict(state,state='sealed',closed=True,classification=args.classification,
                       closure=A.pin(out/'report.json'),closedAt=time.time(),
                       retained=[str(path) for path in sorted(kept)],
                       archived=[row['archiveReceipt'] for row in result['roots'] if 'archiveReceipt' in row])
        fd,temporary_name = tempfile.mkstemp(prefix='.retention-close-',dir=run)
        temporary = Path(temporary_name)
        try:
            with os.fdopen(fd,'w') as stream:
                json.dump(revised,stream,indent=2)
                stream.write('\n')
                stream.flush()
                os.fsync(stream.fileno())
            A.authenticate(initial)
            os.replace(temporary,retention_path)
        finally:
            if temporary.exists():
                temporary.unlink()
        fd = os.open(run,os.O_RDONLY|os.O_DIRECTORY)
        try:
            os.fsync(fd)
        finally:
            os.close(fd)
        return result
    except BaseException as error:
        failure = dict(result,complete=False,error=repr(error),finished=time.time(),minimumDiskFreeBytes=budget.minimum)
        destination = out/'failure.json' if (out/'report.json').exists() else out/'report.json'
        A.write_new(destination,failure)
        raise


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--run',type=Path,required=True,help='Finished guard output directory')
    parser.add_argument('--out',type=Path,required=True)
    parser.add_argument('--classification',choices=['qualified','completed','rejected','failed'],required=True)
    parser.add_argument('--qualification',type=Path)
    parser.add_argument('--keep-root',type=Path,action='append',default=[])
    parser.add_argument('--prune',action='store_true')
    args = parser.parse_args()
    with A.exclusive():
        result = close(args)
    print(json.dumps(dict(complete=result['complete'],state=result['state'],classification=result['classification'],
                         archivedFiles=sum(r.get('archivedFiles',0) for r in result['roots']),
                         removedFiles=sum(r.get('removedFiles',0) for r in result['roots']))))


if __name__ == '__main__':
    main()
