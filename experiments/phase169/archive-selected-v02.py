#!/usr/bin/env python3
"""Archive an explicitly reviewed set of old generated intermediates; never prune.

A separate root invocation of maintained archive-v02.py applies the resulting
exact file plan. Every ELF/source/API/receipt and every unlisted file stays hot.
"""
import argparse
import gzip
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
        A.need(self.count + len(data) <= self.limit, 'Archive scratch budget exceeded; all source files retained')
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
    A.authenticate(proposal['method']); A.authenticate(proposal['archiveVerifier'])
    rows = [r for r in proposal['roots'] if r['name'] == args.name]
    A.need(len(rows) == 1, 'Exactly one explicitly selected root required')
    row = rows[0]
    raw = ROOT / row['root']
    A.need(raw.resolve() == raw and raw.is_relative_to(ROOT/'selfhost/build') and not raw.is_relative_to(ROOT/'selfhost/build/phase152') and not raw.is_relative_to(ROOT/'selfhost/build/phase169'), 'Invalid/protected root')
    report = json.loads(A.authenticate(row['report']).read_text())
    A.need(report.get('complete'), 'Completed original build required')
    A.need(row['guards'], 'Writer closure evidence required')
    for guard in row['guards']:
        d = json.loads(A.authenticate(guard).read_text())
        A.need(d.get('complete') and d.get('returncode') == 0, 'Successful closed writer required')
    expected = {}
    for item in row['selectedFiles']:
        source = ROOT/item['file']
        A.need(source.parent == raw and source.name in ['program.ssa','program.s','program.o'] and source.name not in expected, 'Only exact distinct generated leaves permitted')
        expected[source.name] = {k:item[k] for k in ['bytes','sha256']}
    A.need(expected, 'Empty selection')
    out = args.out.absolute()
    A.need(out.resolve() == out and out.is_relative_to(ROOT/'selfhost/build-retention/phase169') and not out.exists(), 'Fresh scoped output required')
    with A.exclusive():
        before = {name:A.metadata(raw/name) for name in expected}
        for name, identity in expected.items():
            pin = A.pin(raw/name)
            A.need({k:pin[k] for k in identity} == identity, 'Original product identity differs: '+name)
            A.need(A.metadata(raw/name) == before[name], 'Input changed during initial identity check')
        free = shutil.disk_usage(ROOT).free
        limit = proposal['archiveBudgetPerRootBytes']
        A.need(free > limit + 4*1024**3, 'Insufficient separately authorized maintenance scratch space')
        out.mkdir(parents=True)
        archive = out/'files.tar.gz'
        with archive.open('xb') as stream:
            with gzip.GzipFile(filename='',mode='wb',fileobj=LimitedOutput(stream,limit),mtime=0,compresslevel=1) as compressed:
                with tarfile.open(fileobj=compressed,mode='w|') as tar:
                    for name in sorted(expected):
                        meta = before[name]
                        A.need(A.metadata(raw/name) == meta, 'Input changed before archival')
                        info = tarfile.TarInfo(name)
                        info.size,info.mode,info.uid,info.gid = meta['size'],meta['mode'],meta['uid'],meta['gid']
                        info.mtime = meta['mtimeNs']//10**9
                        with (raw/name).open('rb') as data: tar.addfile(info,data)
                        A.need(A.metadata(raw/name) == meta, 'Input changed during archival')
            stream.flush();os.fsync(stream.fileno())
        with tarfile.open(archive,'r:gz') as tar:
            seen=set()
            for member in tar:
                A.need(member.name in expected and member.name not in seen and member.isfile(), 'Unexpected archive member')
                seen.add(member.name)
                A.need(member.mode == before[member.name]['mode'], 'Archive mode differs')
                with tar.extractfile(member) as data: A.need(A.digest(data)==expected[member.name], 'Archive member differs')
            A.need(seen==set(expected), 'Missing archive member')
        with gzip.open(archive,'rb') as stream:
            while stream.read(1024*1024): pass
        for name, identity in expected.items():
            pin=A.pin(raw/name)
            A.need({k:pin[k] for k in identity}==identity and A.metadata(raw/name)==before[name], 'Source changed after archive verification')
        ap=A.pin(archive)
        receipt=dict(kind='build-retention-run-capsule-v1',complete=True,rawRoot=str(raw),archive=dict(path=archive.name,bytes=ap['bytes'],sha256=ap['sha256']),files=expected,members=len(expected),reopenedVerified=True,inputStabilityVerified=True,method=A.pin(__file__),created=time.time(),writersClosed=dict(report=row['report'],guards=row['guards']),scope='Only listed generated intermediates archived. All ELF/source/API/receipts stay hot; no deletion.')
        A.write_new(out/'receipt.json',receipt)
        policy=dict(allowedRoots=[row['root']],archiveRoots={str((out/'receipt.json').relative_to(ROOT)):row['root']},keepPrefixes=['selfhost/build/phase32/execution.lock','selfhost/build/phase152','selfhost/build/phase168','selfhost/build/phase169'],reviewedProposal=A.pin(args.proposal),scope='Exactly the archived SSA/assembly/object leaves; no other member or root.')
        A.write_new(out/'policy.json',policy)
        result=A.verify(argparse.Namespace(policy=out/'policy.json',receipt=out/'receipt.json',out=out/'verified'))
        allocated=sum(m['allocatedBytes'] for m in before.values())
        A.need(result['selectedFiles']==len(expected) and result['allocatedBytes']==allocated,'Unexpected selection')
        A.write_new(out/'capture.json',dict(complete=True,archive=ap,plan=A.pin(out/'verified/plan.json'),sourceAllocatedBytes=allocated,freeBefore=free,freeAfter=shutil.disk_usage(ROOT).free,sourceUnchanged=True,deletedFiles=0))
        print(json.dumps(dict(complete=True,root=str(raw),files=len(expected),archiveBytes=ap['bytes'],allocatedBytes=allocated,plan=str(out/'verified/plan.json'))))

if __name__ == '__main__': main()
