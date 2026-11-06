#!/usr/bin/env python3
"""Capture one explicitly reviewed old generated file; never remove source data.

The maintained archive-v02 verifier supplies the prune/restore plan. The caller
must separately review and invoke its apply command. No compiler is executed.
"""
import argparse
import gzip
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import shutil
import tarfile
import time

ROOT = Path(__file__).resolve().parents[2]
METHOD = ROOT / 'selfhost/tools/build-retention/archive-v02.py'
spec = importlib.util.spec_from_file_location('archive_v02', METHOD)
A = importlib.util.module_from_spec(spec)
spec.loader.exec_module(A)

class LimitedOutput:
    def __init__(self, stream, limit): self.stream, self.limit, self.count = stream, limit, 0
    def write(self, data):
        A.need(self.count + len(data) <= self.limit, 'Archive exceeded explicit scratch budget; source untouched')
        self.count += len(data)
        return self.stream.write(data)
    def flush(self): return self.stream.flush()

def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--proposal', type=Path, required=True)
    p.add_argument('--name', required=True)
    p.add_argument('--out', type=Path, required=True)
    args = p.parse_args()
    proposal = json.loads(args.proposal.read_text())
    rows = [r for r in proposal['roots'] if r['name'] == args.name]
    A.need(len(rows) == 1, 'Exactly one reviewed root required')
    row = rows[0]
    for identity in [proposal['method'], row['report'], *row['guards']]: A.authenticate(identity)
    raw = ROOT / row['root']
    source = ROOT / row['selected']['file']
    expected = {k: row['selected'][k] for k in ['bytes', 'sha256']}
    A.need(source.parent == raw and source.name == 'program.ssa', 'Only exact generated SSA leaf permitted')
    out = args.out.absolute()
    A.need(out.resolve() == out and out.is_relative_to(ROOT / 'selfhost/build-retention/phase169') and not out.exists(), 'Fresh scoped destination required')
    A.need(json.loads(A.authenticate(row['report']).read_text())['complete'], 'Completed request required')
    for guard in row['guards']:
        d = json.loads(A.authenticate(guard).read_text())
        A.need(d['complete'] and d['returncode'] == 0, 'Successful closed process required')
    with A.exclusive():
        before = A.metadata(source)
        A.need({k:A.pin(source)[k] for k in expected} == expected, 'Original report identity differs')
        free = shutil.disk_usage(ROOT).free
        limit = proposal['archiveBudgetPerFileBytes']
        A.need(free > limit + 4 * 1024**3, 'Insufficient emergency archive headroom')
        out.mkdir(parents=True)
        archive = out / 'files.tar.gz'
        with archive.open('xb') as stream:
            with gzip.GzipFile(filename='',mode='wb',fileobj=LimitedOutput(stream,limit),mtime=0,compresslevel=1) as compressed:
                with tarfile.open(fileobj=compressed,mode='w|') as tar:
                    info = tarfile.TarInfo(source.name)
                    info.size,info.mode,info.uid,info.gid = before['size'],before['mode'],before['uid'],before['gid']
                    info.mtime = before['mtimeNs']//10**9
                    with source.open('rb') as data: tar.addfile(info,data)
            stream.flush();os.fsync(stream.fileno())
        with tarfile.open(archive,'r:gz') as tar:
            members=tar.getmembers()
            A.need(len(members)==1 and members[0].name==source.name and members[0].isfile(), 'Unexpected archived members')
            with tar.extractfile(members[0]) as data: A.need(A.digest(data)==expected,'Archive roundtrip differs')
        with gzip.open(archive,'rb') as stream:
            while stream.read(1024*1024): pass
        A.need(A.metadata(source)==before and {k:A.pin(source)[k] for k in expected}==expected,'Source changed during archival')
        ap = A.pin(archive)
        receipt=dict(kind='build-retention-run-capsule-v1',complete=True,rawRoot=str(raw),archive=dict(path=archive.name,bytes=ap['bytes'],sha256=ap['sha256']),files={source.name:expected},members=1,reopenedVerified=True,inputStabilityVerified=True,method=A.pin(__file__),created=time.time(),scope='One reviewed legacy generated SSA file; all other files remain hot. No deletion.',writersClosed=dict(report=row['report'],guards=row['guards']))
        A.write_new(out/'receipt.json',receipt)
        policy=dict(allowedRoots=[row['root']],archiveRoots={str((out/'receipt.json').relative_to(ROOT)):row['root']},keepPrefixes=['selfhost/build/phase32/execution.lock','selfhost/build/phase152','selfhost/build/phase168','selfhost/build/phase169'],reviewedProposal=A.pin(args.proposal),selectedFile=A.pin(source),scope='Exactly one archived SSA member, no ELF/source/API/receipt.')
        A.write_new(out/'policy.json',policy)
        result=A.verify(argparse.Namespace(policy=out/'policy.json',receipt=out/'receipt.json',out=out/'verified'))
        A.need(result['selectedFiles']==1 and result['allocatedBytes']==before['allocatedBytes'],'Unexpected prune selection')
        A.write_new(out/'capture.json',dict(complete=True,source=A.pin(source),archive=ap,plan=A.pin(out/'verified/plan.json'),freeBefore=free,freeAfter=shutil.disk_usage(ROOT).free,sourceUnchanged=True,deletedFiles=0))
        print(json.dumps(dict(complete=True,source=str(source),archiveBytes=ap['bytes'],allocatedBytes=before['allocatedBytes'],plan=str(out/'verified/plan.json'))))

if __name__ == '__main__': main()
