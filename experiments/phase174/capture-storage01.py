#!/usr/bin/env python3
"""Capture four reviewed historical bulk roots; never apply or run targets."""
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
PROPOSAL = ROOT / 'experiments/phase174/storage-proposal01.json'
PROPOSAL_SHA = '64f9860c8a1f8fc8d15a3054d870366f03a66aaeeccd55b6f4b7bfc0564a93e1'
HELPER = ROOT / 'experiments/phase169/archive-selected-v02.py'
HELPER_SHA = 'f1b5463bbdfa2e1d650da65d896da8268d89de1b8e58f7d7a0a34a68b36a79b9'
RESERVE, LIMIT, RECEIPTS = 5 * 1024**3, 20 * 1024**2, 2 * 1024**2
EXACT = {
    'p174-retired-p147-profile-full02-stdout': (
        'selfhost/build/phase147/profile-full02/capture/000-sample-full-current-selected-n2-diagnostic', ['stdout']),
    'p174-retired-p147-profile-final-full01-stdout': (
        'selfhost/build/phase147/profile-final-full01/capture/000-sample-full-current-candidate-n1-diagnostic', ['stdout']),
    'p174-retired-p147-profile-candidate-full01-stdout': (
        'selfhost/build/phase147/profile-candidate-full01/capture/000-sample-full-current-candidate-n1-diagnostic', ['stdout']),
    'p174-retired-p144-product-graphs': (
        'selfhost/build/phase144/product-retry-census02',
        ['verifier-original-trace.graph.json', 'verifier-product-trace.graph.json', 'verifier-sum-trace.graph.json']),
}


def load_helper():
    import hashlib
    if hashlib.sha256(HELPER.read_bytes()).hexdigest() != HELPER_SHA:
        raise ValueError('Frozen archive helper changed')
    spec = importlib.util.spec_from_file_location('p174_archive_helper', HELPER)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--name', required=True, choices=EXACT)
    parser.add_argument('--out', type=Path)
    parser.add_argument('--check-only', action='store_true')
    args = parser.parse_args()
    H = load_helper()
    A = H.A
    proposal_pin = A.pin(PROPOSAL)
    A.need(proposal_pin['sha256'] == PROPOSAL_SHA, 'Frozen proposal changed')
    proposal = json.loads(PROPOSAL.read_text())
    A.authenticate(proposal['method'])
    A.authenticate(proposal['archiveVerifier'])
    A.need(proposal['archiveBudgetPerRootBytes'] == LIMIT and proposal['requiredReserveBytes'] == RESERVE, 'Unexpected limits')
    rows = [r for r in proposal['roots'] if r['name'] == args.name]
    A.need(len(rows) == 1, 'Exactly one approved root required')
    row = rows[0]
    approved_root, approved_members = EXACT[args.name]
    A.need(row['root'] == approved_root and row['captureAdapter'] == 'exact-generic-capsule-required', 'Unexpected root')
    raw = ROOT / approved_root
    A.need(raw.resolve() == raw, 'Symlinked root')
    selected = {Path(x['file']).name: x for x in row['selectedFiles']}
    A.need(len(selected) == len(row['selectedFiles']) and set(selected) == set(approved_members), 'Unexpected members')
    for name, item in selected.items():
        A.need(ROOT / item['file'] == raw / name and item['bytes'] < 128 * 1024**2, 'Invalid leaf or member cap')
    out = ROOT / 'selfhost/build-retention/phase174' / ('capture01-' + args.name)
    A.need(args.check_only or (args.out is not None and args.out.absolute() == out), 'Use exact fresh output path')
    A.need(out.resolve() == out and not out.exists(), 'Output exists or is symlinked')

    with A.exclusive():
        report = json.loads(A.authenticate(row['report']).read_text())
        A.need(report.get('complete') and row['guards'], 'Completed report and closed consumers required')
        for guard in row['guards']:
            value = json.loads(A.authenticate(guard).read_text())
            A.need(value.get('complete') and value.get('returncode') == 0, 'Unclosed/failed writer')
        before = {}
        expected = {}
        for name, item in selected.items():
            before[name] = A.metadata(raw / name)
            A.need(before[name] == item['metadata'], 'Reviewed inode/metadata changed')
            expected[name] = {k: item[k] for k in ['bytes', 'sha256']}
            current = A.pin(raw / name)
            A.need({k: current[k] for k in expected[name]} == expected[name], 'Reviewed identity changed')
            A.need(A.metadata(raw / name) == before[name], 'Source changed during preflight')
        if args.check_only:
            print(json.dumps(dict(complete=True, targetsRun=False, archivesCreated=0, root=str(raw), files=len(selected))))
            return
        free = shutil.disk_usage(ROOT).free
        A.need(free >= RESERVE + LIMIT + RECEIPTS, 'Insufficient reserve plus bounded capture/receipt space')
        out.mkdir(parents=True)
        archive = out / 'files.tar.gz'

        class ReservedOutput(H.LimitedOutput):
            def write(self, data):
                A.need(shutil.disk_usage(ROOT).free >= RESERVE + RECEIPTS + len(data), 'Reserve reached; retain all source files')
                return super().write(data)

        with archive.open('xb') as stream:
            with gzip.GzipFile(filename='', mode='wb', fileobj=ReservedOutput(stream, LIMIT), mtime=0, compresslevel=1) as compressed:
                with tarfile.open(fileobj=compressed, mode='w|') as tar:
                    for name in sorted(selected):
                        meta = before[name]
                        A.need(A.metadata(raw / name) == meta, 'Source changed before archive')
                        info = tarfile.TarInfo(name)
                        info.size, info.mode, info.uid, info.gid = meta['size'], meta['mode'], meta['uid'], meta['gid']
                        info.mtime = meta['mtimeNs'] // 10**9
                        with (raw / name).open('rb') as data:
                            tar.addfile(info, data)
                        A.need(A.metadata(raw / name) == meta, 'Source changed during archive')
            stream.flush()
            os.fsync(stream.fileno())
        with tarfile.open(archive, 'r:gz') as tar:
            seen = set()
            for member in tar:
                A.need(member.name in selected and member.name not in seen and member.isfile(), 'Unexpected archive member')
                seen.add(member.name)
                meta = before[member.name]
                A.need((member.size, member.mode, member.uid, member.gid, member.mtime) ==
                       (meta['size'], meta['mode'], meta['uid'], meta['gid'], meta['mtimeNs'] // 10**9), 'Archive metadata differs')
                with tar.extractfile(member) as data:
                    A.need(A.digest(data) == expected[member.name], 'Archive member differs')
            A.need(seen == set(selected), 'Missing archive member')
        with gzip.open(archive, 'rb') as stream:
            while stream.read(1024**2):
                pass
        for name in selected:
            A.need(A.metadata(raw / name) == before[name], 'Source changed after capture')
        A.authenticate(proposal_pin)
        archive_pin = A.pin(archive)
        receipt = dict(kind='build-retention-run-capsule-v1', complete=True, rawRoot=str(raw),
                       archive=dict(path=archive.name, bytes=archive_pin['bytes'], sha256=archive_pin['sha256']),
                       files=expected, members=len(expected), reopenedVerified=True, inputStabilityVerified=True,
                       method=A.pin(__file__), reviewedProposal=proposal_pin, created=time.time(),
                       writersClosed=dict(report=row['report'], guards=row['guards']),
                       scope='Exact retired generated bulk only; no source/runtime/ELF/sample deletion or target execution.')
        A.write_new(out / 'receipt.json', receipt)
        policy = dict(allowedRoots=[approved_root], archiveRoots={str((out / 'receipt.json').relative_to(ROOT)): approved_root},
                      keepPrefixes=['selfhost/build/phase32/execution.lock', 'selfhost/build/phase170', 'selfhost/build/phase171'],
                      reviewedProposal=proposal_pin, scope='Only explicitly archived exact leaves. All unlisted files remain hot.')
        A.write_new(out / 'policy.json', policy)
        result = A.verify(argparse.Namespace(policy=out / 'policy.json', receipt=out / 'receipt.json', out=out / 'verified'))
        allocated = sum(m['allocatedBytes'] for m in before.values())
        A.need(result['selectedFiles'] == len(selected) and result['allocatedBytes'] == allocated, 'Unexpected verifier selection')
        A.need(shutil.disk_usage(ROOT).free >= RESERVE, 'Reserve reached; do not apply')
        A.write_new(out / 'capture.json', dict(complete=True, archive=archive_pin, plan=A.pin(out / 'verified/plan.json'),
                                             sourceAllocatedBytes=allocated, freeBefore=free, freeAfter=shutil.disk_usage(ROOT).free,
                                             sourceUnchanged=True, targetsRun=False, deletedFiles=0))
        print(json.dumps(dict(complete=True, root=str(raw), files=len(selected), archiveBytes=archive_pin['bytes'],
                              allocatedBytes=allocated, plan=str(out / 'verified/plan.json'))))


if __name__ == '__main__':
    main()
