#!/usr/bin/env python3
"""Capture proposal04's three exact retired QBE payloads; never apply or delete."""
import argparse
import gzip
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import shutil
import sys
import tarfile
import time

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[2]
RAW = ROOT / 'selfhost/build/phase140/full-batch01'
PROPOSAL = ROOT / 'experiments/phase173/storage-proposal04.json'
PROPOSAL_SHA = '29467e6e90936948723f519f5e4c71f605ae01b8766dbb42b0c63c6a149df8e4'
MEMBERS = tuple(f'{n:03}-transport/payload.bin' for n in (1, 2, 3))
MIB, RESERVE, CAP = 1024**2, 5 * 1024**3, 64 * 1024**2
ARCHIVE_CAP = CAP - 4 * MIB  # Receipt/header/allocation headroom, inside total cap.


def need(ok, message):
    if not ok:
        raise ValueError(message)


def authority():
    data = PROPOSAL.read_bytes()
    need(hashlib.sha256(data).hexdigest() == PROPOSAL_SHA, 'Reviewed proposal changed')
    p = json.loads(data)
    identity = p['captureDesign']['archiveVerifier']
    method = Path(identity['file'])
    need(method == ROOT / 'selfhost/tools/build-retention/archive-v02.py',
         'Wrong maintained verifier')
    data = method.read_bytes()
    need(len(data) == identity['bytes'] and hashlib.sha256(data).hexdigest() ==
         identity['sha256'], 'Maintained verifier changed')
    spec = importlib.util.spec_from_file_location('transport_archive_v04', method)
    a = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(a)
    need(p['root'] == str(RAW.relative_to(ROOT)) and
         p['requiredReserveBytes'] == RESERVE and p['archiveAndReceiptBudgetBytes'] == CAP,
         'Wrong reviewed root/budget')
    need(tuple(x['member'] for x in p['selectedFiles']) == MEMBERS,
         'Exactly three reviewed members required')
    return a, p


def current_references():
    """One bounded streaming path audit; no recursive compiler-object parsing."""
    scopes = ['selfhost/manifests', 'selfhost/tools', 'selfhost/tests/phase173',
              'selfhost/build/phase173']
    suffixes = {'.json', '.py', '.mjs', '.ts', '.sh', '.bend', '.txt'}
    root_marker = b'selfhost/build/phase140/full-batch01'
    files, size = 0, 0
    for scope in scopes:
        for p in (ROOT / scope).rglob('*'):
            if p.is_symlink():
                need(not p.resolve().is_relative_to(RAW),
                     'Current alias references retired batch: ' + str(p))
                continue
            if not p.is_file() or p.suffix not in suffixes:
                continue
            need(p.stat().st_size <= 128 * MIB,
                 'Oversized current text input needs explicit review: ' + str(p))
            marker = b'full-batch01' if scope == 'selfhost/tools' else root_marker
            files += 1
            tail = b''
            with p.open('rb') as stream:
                while block := stream.read(MIB):
                    size += len(block)
                    merged = tail + block
                    need(marker not in merged, 'Current reference requires retention: ' + str(p))
                    tail = merged[-len(marker):]
    return dict(filesRead=files, bytesRead=size, selectedRootHits=0,
                scope='Current manifest/tool/Phase173 textual paths; historical replay requires restore.')


def admission(a, p):
    need(RAW.resolve() == RAW and RAW.is_dir(), 'Wrong/symlinked original root')
    report = json.loads(a.authenticate(p['writerReport']).read_text())
    guard = json.loads(a.authenticate(p['writerGuard']).read_text())
    need(report['complete'] and report['experimental'] and not report['selected'] and
         report['exitCode'] == 0 and not report['changedInputs'] and
         guard['complete'] and guard['returncode'] == 0 and 'finished' in guard,
         'Original unselected writer has not completed successfully')
    transports = [json.loads(a.authenticate(v).read_text()) for v in p['transportReports']]
    a.authenticate(p['retainedReference'])
    for item in p['selectedFiles']:
        path = ROOT / item['file']
        need(path == RAW / item['member'], 'Selected path/member differs')
        need(a.metadata(path) == item['metadata'], 'Reviewed inode changed: ' + str(path))
        actual = a.pin(path)
        need(all(actual[k] == item[k] for k in ('bytes', 'sha256')), 'Reviewed bytes changed')
        need(any(j['product'] == actual for j in report['jobs']), 'Missing original product pin')
        need(any(t.get('complete') and t['payload'] == actual for t in transports),
             'Missing original complete transport pin')
    need(sum(a.metadata(RAW / m)['allocatedBytes'] for m in MEMBERS) == p['allocatedBytes'],
         'Reviewed allocation changed')
    return current_references()


class Budget:
    def __init__(self, out):
        self.out, self.minimum, self.next_check = out, shutil.disk_usage(ROOT).free, 0

    def check(self, *, admission=False, force=False):
        if force or time.monotonic() >= self.next_check:
            free = shutil.disk_usage(ROOT).free
            self.minimum = min(self.minimum, free)
            need(free >= RESERVE + (CAP if admission else 0), '5 GiB reserve/scratch refusal')
            allocated = self.out.stat().st_blocks * 512 if self.out.exists() else 0
            if self.out.exists():
                allocated += sum(f.stat().st_blocks * 512 for f in self.out.rglob('*'))
            need(allocated <= CAP, 'Total fresh capture allocation exceeds 64 MiB')
            self.next_check = time.monotonic() + .1


class CappedWriter:
    def __init__(self, stream, budget):
        self.stream, self.budget, self.count = stream, budget, 0

    def write(self, data):
        need(self.count + len(data) <= ARCHIVE_CAP, 'Compressed archive exceeds 60 MiB cap')
        self.budget.check()
        count = self.stream.write(data)
        self.count += count
        return count

    def flush(self):
        self.stream.flush()


def capture(a, p, out, audit):
    budget = Budget(out)
    budget.check(admission=True, force=True)
    out.mkdir(parents=True)
    own_method = a.pin(__file__)
    a.write_new(out / 'intent.json', dict(complete=True, proposal=a.pin(PROPOSAL),
        method=own_method, selectedFiles=p['selectedFiles'], dependencies=audit,
        archiveAndReceiptCapBytes=CAP, reserveBytes=RESERVE, deletedFiles=0))
    try:
        originals = {v['member']: v for v in p['selectedFiles']}
        archive = out / 'files.tar.gz'
        with archive.open('xb') as raw:
            with gzip.GzipFile(filename='', mode='wb', fileobj=CappedWriter(raw, budget),
                               mtime=0, compresslevel=1) as encoded:
                with tarfile.open(fileobj=encoded, mode='w|') as tar:
                    for name in MEMBERS:
                        item, path = originals[name], RAW / name
                        meta = a.metadata(path)
                        need(meta == item['metadata'], 'Source changed before capture')
                        header = tarfile.TarInfo(name)
                        header.size, header.mode = item['bytes'], meta['mode']
                        header.uid, header.gid = meta['uid'], meta['gid']
                        header.mtime = meta['mtimeNs'] // 10**9
                        with path.open('rb') as stream:
                            tar.addfile(header, stream)
                        need(a.metadata(path) == meta, 'Source changed during capture')
            raw.flush()
            os.fsync(raw.fileno())
        budget.check(force=True)
        seen = set()
        with gzip.open(archive, 'rb') as decoded:
            with tarfile.open(fileobj=decoded, mode='r|') as tar:
                for member in tar:
                    need(member.isfile() and member.name in originals and
                         member.name not in seen, 'Unexpected or duplicate archive member')
                    seen.add(member.name)
                    item = originals[member.name]
                    need(member.size == item['bytes'] and
                         member.mtime == item['metadata']['mtimeNs'] // 10**9,
                         'Archived size/timestamp differs')
                    need((member.mode, member.uid, member.gid) ==
                         tuple(item['metadata'][k] for k in ('mode', 'uid', 'gid')),
                         'Archived member metadata differs')
                    with tar.extractfile(member) as stream:
                        need(a.digest(stream) == {k: item[k] for k in ('bytes', 'sha256')},
                             'Reopened archive member differs')
                    budget.check()
            while decoded.read(MIB):
                budget.check()
        need(seen == set(MEMBERS), 'Archive omitted a member')
        after = admission(a, p)
        a.authenticate(own_method)
        archived = a.pin(archive)
        receipt = dict(kind='build-retention-run-capsule-v1', complete=True,
            rawRoot=str(RAW), archive=dict(path=archive.name, bytes=archived['bytes'],
            sha256=archived['sha256']), files={n: {k: originals[n][k]
            for k in ('bytes', 'sha256')} for n in MEMBERS}, members=3,
            reopenedVerified=True, inputStabilityVerified=True, memberModesVerified=True,
            method=own_method, writersClosed=dict(report=p['writerReport'], guard=p['writerGuard'],
            transports=p['transportReports']), protectedStart=p['retainedReference'],
            scope='Only three reviewed nested payloads; no deletion or lifecycle mutation.')
        a.write_new(out / 'receipt.json', receipt)
        policy = dict(allowedRoots=[p['root']],
            archiveRoots={str((out / 'receipt.json').relative_to(ROOT)): p['root']},
            keepPrefixes=['selfhost/build/phase32/execution.lock', 'selfhost/build/phase170',
                          'selfhost/build/phase171', 'selfhost/build/phase173',
                          str((RAW / '000-transport').relative_to(ROOT))],
            reviewedProposal=a.pin(PROPOSAL), scope='Exactly three authenticated archive members.')
        a.write_new(out / 'policy.json', policy)
        plan = a.verify(argparse.Namespace(policy=out / 'policy.json',
                         receipt=out / 'receipt.json', out=out / 'verified'))
        expected = {str(ROOT / v['file']): (v['bytes'], v['sha256']) for v in p['selectedFiles']}
        actual = {v['file']['file']: (v['file']['bytes'], v['file']['sha256'])
                  for v in a.plan_files(plan)}
        need(actual == expected and plan['selectedFiles'] == 3 and
             plan['allocatedBytes'] == p['allocatedBytes'], 'Verified exact selection differs')
        budget.check(force=True)
        a.write_new(out / 'capture.json', dict(complete=True, targetsRun=False, deletedFiles=0,
            archive=archived, plan=a.pin(out / 'verified/plan.json'), sourceUnchanged=True,
            lifecycleChanged=False, dependencies=after, minimumFreeBytes=budget.minimum,
            conditionalNetLowerBoundBytes=p['allocatedBytes'] - CAP,
            applyPreflight=['python3', '-B', str(Path(__file__).relative_to(ROOT)), '--check-only']))
        budget.check(force=True)
        print(json.dumps(dict(complete=True, files=3, archiveBytes=archived['bytes'],
                              deletedFiles=0, plan=str(out / 'verified/plan.json'))))
    except Exception as error:
        a.write_new(out / 'capture-error.json', dict(complete=False, error=repr(error),
                    deletedFiles=0, scope='Original files untouched; partial capture retained.'))
        raise


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path)
    parser.add_argument('--check-only', action='store_true')
    args = parser.parse_args()
    a, proposal = authority()
    with a.exclusive():
        audit = admission(a, proposal)
        if args.check_only:
            need(args.out is None, 'Read-only preflight does not take --out')
            print(json.dumps(dict(complete=True, targetsRun=False, checkOnly=True,
                                  selectedFiles=3, dependencies=audit)))
            return
        need(args.out is not None, 'Capture requires --out')
        out = args.out.absolute()
        need(out.resolve() == out and out.parent == ROOT / 'selfhost/build-retention/phase173'
             and out.name.startswith('capture04-') and not out.exists(),
             'Fresh capture04-* Phase173 retention directory required')
        capture(a, proposal, out, audit)


if __name__ == '__main__':
    main()
