#!/usr/bin/env python3
"""Root-operated successor: shared retained siblings are hashed, never selected.

The v1 runner and all completed v1 receipts remain immutable.

Capture uses the Phase169 bounded stream method. The unchanged maintained
archive-v02 verifier/application owns all file removal and restoration.
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
import time

ROOT = Path(__file__).resolve().parents[2]
PROPOSAL = ROOT/'experiments/phase171/retention-approved-completed.json'
PROPOSAL_SHA = 'aa91825c9d1698894b4eff9b537866850a6c117c2373f7601af8d03fe26430df'
OUT = ROOT/'selfhost/build-retention/phase171/reclaim-completed'
spec = importlib.util.spec_from_file_location('archive_selected_v02',ROOT/'experiments/phase169/archive-selected-v02.py')
C = importlib.util.module_from_spec(spec);spec.loader.exec_module(C)
A = C.A


def retained_stat(path):
    """Identity of a KEEP-only sibling. This does not admit a deletion target."""
    A.need(path.resolve()==path, 'Symlinked retained artifact')
    s=path.lstat()
    A.need(stat.S_ISREG(s.st_mode), 'Nonregular retained artifact')
    A.need(s.st_nlink>=1, 'Unlinked retained artifact')
    A.need(s.st_uid==os.geteuid() and s.st_gid==os.getegid(), 'Different retained owner/group')
    A.need(not stat.S_IMODE(s.st_mode)&0o7000, 'Special retained permission bits')
    A.need(not os.listxattr(path,follow_symlinks=False), 'Nonempty retained extended attributes')
    return dict(device=s.st_dev,inode=s.st_ino,size=s.st_size,mode=stat.S_IMODE(s.st_mode),
      uid=s.st_uid,gid=s.st_gid,links=s.st_nlink,mtimeNs=s.st_mtime_ns,ctimeNs=s.st_ctime_ns,
      allocatedBytes=s.st_blocks*512)


def retained_identity(path):
    before=retained_stat(path)
    if before['links']==1:
        # Exactly preserve the v1 identity format for its 13 completed roots.
        A.need(A.metadata(path)==before, 'Unshared retained metadata changed')
        return before
    identity=A.pin(path)
    A.need(retained_stat(path)==before, 'Shared retained artifact changed during hashing')
    A.need(identity['bytes']==before['size'], 'Shared retained size changed')
    return dict(**before,sha256=identity['sha256'],sharedRetainedOnly=True)


def preserved(raw):
    return {p.name:retained_identity(p) for p in raw.iterdir()
      if p.is_file() and p.name not in ('program.s','program.o')}


def admit(row):
    raw=ROOT/row['root']
    A.need(raw.resolve()==raw and raw.parent in (ROOT/'selfhost/build/phase111',ROOT/'selfhost/build/phase134'),'Unapproved root')
    report=json.loads(A.authenticate(row['report']).read_text())
    guard=json.loads(A.authenticate(row['guard']).read_text())
    A.need(report.get('complete') and guard.get('complete') and guard.get('returncode')==0 and guard.get('finished'),'Successful terminal writer required')
    A.need({Path(v['file']).name for v in row['files']}=={'program.s','program.o'} and len(row['files'])==2,'Exact two generated leaves required')
    return raw


def check_completed(row,out):
    report=json.loads((out/'applied/report.json').read_text())
    A.need(report.get('complete') and report['removedFiles']==2,'Incomplete previous prune; manual recovery required')
    plan,raw=A.checked_plan(out/'verified/plan.json')
    rows=list(A.plan_files(plan))
    A.need({v['file']['file'] for v in rows}=={v['file'] for v in row['files']},'Previous selection differs')
    A.need(all(not Path(v['file']).exists() for v in row['files']),'Previously pruned file reappeared; do not prune automatically')
    before=json.loads((out/'preserved.json').read_text())
    A.need(preserved(raw)==before,'Unselected artifact metadata changed')
    return report


def capture_and_prune(row,proposal):
    raw=admit(row);out=OUT/row['name']
    if out.exists(): return check_completed(row,out)
    limit,reserve=proposal['archiveBudgetPerRootBytes'],proposal['reserveBytes']
    free=shutil.disk_usage(ROOT).free
    A.need(free>=reserve+limit+2*1024**2,'Insufficient reserve plus bounded scratch; no capture started')
    before={Path(v['file']).name:A.metadata(Path(v['file'])) for v in row['files']}
    expected={}
    for item in row['files']:
        p=Path(item['file']);A.need(p.parent==raw and A.metadata(p)==item['metadata'],'Selected metadata changed')
        pin=A.pin(p)
        A.need(pin['bytes']==item['metadata']['size'],'Selected size changed')
        if item['historicalSha256'] is not None:A.need(pin['sha256']==item['historicalSha256'],'Original report identity mismatch')
        A.need(A.metadata(p)==before[p.name],'Input changed during initial hashing')
        expected[p.name]={k:pin[k] for k in ('bytes','sha256')}
    keep=preserved(raw)
    out.mkdir(parents=True)
    A.write_new(out/'preserved.json',keep)
    archive=out/'files.tar.gz'
    with archive.open('xb') as stream:
        with gzip.GzipFile(filename='',mode='wb',fileobj=C.LimitedOutput(stream,limit),mtime=0,compresslevel=1) as compressed:
            with tarfile.open(fileobj=compressed,mode='w|') as tar:
                for name in sorted(expected):
                    meta=before[name];A.need(A.metadata(raw/name)==meta,'Input changed before capture')
                    info=tarfile.TarInfo(name);info.size=meta['size'];info.mode=meta['mode'];info.uid=meta['uid'];info.gid=meta['gid'];info.mtime=meta['mtimeNs']//10**9
                    with (raw/name).open('rb') as data:tar.addfile(info,data)
                    A.need(A.metadata(raw/name)==meta,'Input changed during capture')
        stream.flush();os.fsync(stream.fileno())
    A.need(shutil.disk_usage(ROOT).free>=reserve,'Outside writes consumed reserve; original artifacts retained')
    with tarfile.open(archive,'r:gz') as tar:
        seen=set()
        for member in tar:
            A.need(member.name in expected and member.name not in seen and member.isfile(),'Unexpected member')
            seen.add(member.name);A.need(member.mode==before[member.name]['mode'],'Archive mode differs')
            with tar.extractfile(member) as data:A.need(A.digest(data)==expected[member.name],'Archive member differs')
        A.need(seen==set(expected),'Archive member missing')
    with gzip.open(archive,'rb') as stream:
        while stream.read(1024*1024):pass
    for name,identity in expected.items():
        pin=A.pin(raw/name)
        A.need({k:pin[k] for k in identity}==identity and A.metadata(raw/name)==before[name],'Source changed after capture')
    A.need(preserved(raw)==keep,'Unselected artifacts changed during capture')
    ap=A.pin(archive)
    A.write_new(out/'receipt.json',dict(kind='build-retention-run-capsule-v1',complete=True,rawRoot=str(raw),archive=dict(path=archive.name,bytes=ap['bytes'],sha256=ap['sha256']),files=expected,members=2,reopenedVerified=True,inputStabilityVerified=True,method=A.pin(__file__),previousRunner=A.pin(ROOT/'experiments/phase171/reclaim-closed.py'),capturePrimitive=proposal['captureMethod'],created=time.time(),writersClosed=dict(report=row['report'],guards=[row['guard']]),scope='Only exact program.s/program.o; all unselected files remain hot.'))
    A.write_new(out/'policy.json',dict(allowedRoots=[row['root']],archiveRoots={str((out/'receipt.json').relative_to(ROOT)):row['root']},keepPrefixes=proposal['protectedPrefixes'],reviewedProposal=A.pin(PROPOSAL),scope='Exactly two archived assembly/object leaves in one explicitly approved old completed build.'))
    result=A.verify(argparse.Namespace(policy=out/'policy.json',receipt=out/'receipt.json',out=out/'verified'))
    rows=list(A.plan_files(result));expected_paths={str(raw/name) for name in expected}
    A.need(result['selectedFiles']==2 and {v['file']['file'] for v in rows}==expected_paths,'Verifier selection differs')
    A.need(result['allocatedBytes']==row['allocatedBytes'],'Selected allocation differs')
    A.write_new(out/'capture.json',dict(complete=True,archive=ap,plan=A.pin(out/'verified/plan.json'),sourceAllocatedBytes=row['allocatedBytes'],freeBefore=free,freeAfter=shutil.disk_usage(ROOT).free,sourceUnchanged=True,deletedFiles=0))
    applied=A.apply(argparse.Namespace(plan=out/'verified/plan.json',out=out/'applied'))
    A.need(applied['complete'] and applied['removedFiles']==2 and preserved(raw)==keep,'Unexpected apply/preservation outcome')
    A.need(shutil.disk_usage(ROOT).free>=reserve,'Reserve violated by concurrent outside writes')
    return applied


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('action',choices=['check','apply'])
    p.add_argument('--limit',type=int,default=17,help='Maximum additional roots to archive and prune this invocation (1..17).')
    args=p.parse_args();A.need(1<=args.limit<=17,'Limit outside exact reviewed set')
    A.need(A.pin(PROPOSAL)['sha256']==PROPOSAL_SHA,'Reviewed proposal changed')
    proposal=json.loads(PROPOSAL.read_text())
    A.authenticate(proposal['captureMethod']);A.authenticate(proposal['archiveVerifier']);A.authenticate(proposal['sourceInventory'])
    A.need(len(proposal['roots'])==17,'Wrong reviewed root count')
    with A.exclusive():
        pending=[];already=[]
        for row in proposal['roots']:
            raw=admit(row);out=OUT/row['name']
            if out.exists():already.append((row,check_completed(row,out)))
            else:
                for item in row['files']:A.need(A.metadata(Path(item['file']))==item['metadata'],'Reviewed metadata changed')
                pending.append(row)
        print(json.dumps(dict(action=args.action,pendingRoots=len(pending),alreadyAppliedRoots=len(already),pendingAllocatedBytes=sum(r['allocatedBytes'] for r in pending),freeBytes=shutil.disk_usage(ROOT).free,reserveBytes=proposal['reserveBytes'])),flush=True)
        if args.action=='apply':
            for row in pending[:args.limit]:
                result=capture_and_prune(row,proposal)
                print(json.dumps(dict(complete=True,name=row['name'],removedFiles=result['removedFiles'],allocatedBytes=result['selectedAllocatedBytes'],freeAfterBytes=result['freeAfterBytes'])),flush=True)
    print(json.dumps(dict(complete=True,action=args.action,newRoots=min(len(pending),args.limit) if args.action=='apply' else 0)),flush=True)

if __name__=='__main__':main()
