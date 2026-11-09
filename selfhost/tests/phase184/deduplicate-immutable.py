#!/usr/bin/env python3
"""Journal 307 reviewed immutable hardlink substitutions; never run a target.

Default is read-only preflight. --apply requires a fresh retention directory.
All canonical paths are qualified build artifacts or retained historical copies;
no current installed file, source, tool, manifest, symlink or unique output moves.
"""
import argparse
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import shutil
import stat
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
spec = importlib.util.spec_from_file_location('retention_archive', ROOT/'selfhost/tools/build-retention/archive-v02.py')
A = importlib.util.module_from_spec(spec); spec.loader.exec_module(A)
PLAN = Path(__file__).with_name('immutable-pairs.json')
PLAN_SHA256 = '188dd77b1344cfc4ea77ae948430f6fe980463c2a232106f03eb4b1613b641ad'


def bound(row):
    return dict(row, file=str(ROOT/str(A.safe_relative(row['file']))))


def same_bytes(a, b):
    with a.open('rb') as x, b.open('rb') as y:
        while True:
            left, right = x.read(1024*1024), y.read(1024*1024)
            if left != right: return False
            if not left: return True


def canonical_metadata(path, expected):
    A.need(path.resolve() == path, 'Canonical symlink refused')
    value = path.stat()
    actual = dict(device=value.st_dev, inode=value.st_ino, mode=stat.S_IMODE(value.st_mode),
                  uid=value.st_uid, gid=value.st_gid, size=value.st_size, mtimeNs=value.st_mtime_ns)
    A.need(stat.S_ISREG(value.st_mode) and not os.listxattr(path), 'Canonical metadata unsupported')
    A.need(all(actual[key] == expected[key] for key in actual), 'Canonical identity/metadata changed')
    return actual


def preflight():
    plan_pin = A.pin(PLAN)
    A.need(plan_pin['sha256'] == PLAN_SHA256, 'Reviewed exact-pair plan changed')
    plan = json.loads(PLAN.read_text())
    A.need(plan['kind'] == 'phase184-explicit-immutable-pairs' and plan['version'] == 1
           and plan['complete'] is True and len(plan['pairs']) == 307, 'Unexpected plan')
    authorities = [bound(row) for row in plan['authorities']]
    for row in authorities: A.authenticate(row)
    for row in authorities[-2:]:
        state = json.loads(Path(row['file']).read_text())
        A.need(state.get('state') == 'sealed' and state.get('closed') is True, 'Historical worktree is not closed')
    selector = A.pin(ROOT/'selfhost/manifests/current.json')
    current = json.loads(Path(selector['file']).read_text())
    A.need(set(current['components']) == {'qbe', 'js', 'nativeCli', 'x86'}
           and current.get('gateStatus', {}).get('qualified') is True, 'Four qualified installed components required')
    protected = [selector, *[bound(row) for row in current['files'].values()]]
    installed_inodes = set()
    for row in protected:
        path = A.authenticate(row); value = path.stat()
        installed_inodes.add((value.st_dev, value.st_ino))
    sources, destinations, total = set(), set(), 0
    for row in plan['pairs']:
        c, d = A.authenticate(bound(row['canonical'])), A.authenticate(bound(row['duplicate']))
        A.need(c.is_relative_to(ROOT/'selfhost/build') and d.is_relative_to(ROOT/'selfhost/build'),
               'Installed/source/tool path is outside the reviewed build-only scope')
        cm, dm = canonical_metadata(c, row['canonicalMetadata']), A.metadata(d)
        A.need(dm == row['duplicateMetadata'], 'Recipient identity/metadata changed')
        A.need(cm['device'] == dm['device'] and cm['inode'] != dm['inode']
               and all(cm[key] == dm[key] for key in ('mode', 'uid', 'gid')), 'Metadata or filesystem differs')
        A.need((cm['device'], cm['inode']) not in installed_inodes
               and (dm['device'], dm['inode']) not in installed_inodes, 'Installed inode must never be shared')
        A.need(same_bytes(c, d), 'Full file bytes differ')
        A.need(d not in destinations, 'Repeated recipient'); destinations.add(d); sources.add(c)
        total += dm['allocatedBytes']
    A.need(not sources & destinations, 'Canonical file is also a recipient')
    A.need(total == plan['allocatedRecipientBytes'] and total >= 300*1024**2, 'Reviewed recovery estimate differs')
    return plan, [plan_pin, *authorities, *protected]


def apply(out, plan, inputs):
    out = out.absolute()
    A.need(out.resolve() == out and out.is_relative_to(ROOT/'selfhost/build-retention') and not out.exists(),
           'Fresh canonical retention output required')
    A.need(shutil.disk_usage(ROOT).free >= 5*1024**3 + 2*1024**2, 'Keep 5GiB reserve plus bounded journal scratch')
    out.mkdir(parents=True)
    before = shutil.disk_usage(ROOT).free
    A.write_new(out/'intent.json', dict(kind='phase184-immutable-deduplication-intent', complete=True,
        method=A.pin(__file__), retentionMethod=A.pin(A.__file__), inputs=inputs, plan=plan,
        scope='Exact byte/mode/owner preservation. Original inodes and timestamps are recorded, not preserved. No installed inode is shared; future builds must use fresh paths.'))
    done, error = 0, None
    with (out/'journal.jsonl').open('x') as journal:
        def record(value):
            journal.write(json.dumps(value)+'\n'); journal.flush(); os.fsync(journal.fileno())
        try:
            for row in inputs: A.authenticate(row)
            for index, row in enumerate(plan['pairs']):
                c, d = A.authenticate(bound(row['canonical'])), A.authenticate(bound(row['duplicate']))
                canonical_metadata(c, row['canonicalMetadata'])
                A.need(A.metadata(d) == row['duplicateMetadata'] and same_bytes(c, d), 'Pair changed after preflight')
                temporary = d.with_name(d.name+'.phase184-link')
                A.need(not os.path.lexists(temporary), 'Temporary link already exists')
                record(dict(index=index, event='intent', canonical=row['canonical'], duplicate=row['duplicate']))
                made_link = False
                try:
                    os.link(c, temporary, follow_symlinks=False); made_link = True
                    A.authenticate(bound(row['canonical']))
                    os.replace(temporary, d)
                    fd = os.open(d.parent, os.O_RDONLY | os.O_DIRECTORY)
                    try: os.fsync(fd)
                    finally: os.close(fd)
                    A.need(c.stat().st_ino == d.stat().st_ino and same_bytes(c, d), 'Post-link equality failed')
                    A.authenticate(bound(row['duplicate']))
                    done += 1
                    record(dict(index=index, event='complete', allocatedRecipientBytes=row['duplicateMetadata']['allocatedBytes']))
                finally:
                    if made_link and os.path.lexists(temporary): temporary.unlink()
            for row in inputs: A.authenticate(row)
        except BaseException as caught:
            error = repr(caught)
            record(dict(event='stopped', error=error, completedPairs=done))
    result = dict(kind='phase184-immutable-deduplication', complete=error is None, targetsRun=False,
                  intent=A.pin(out/'intent.json'), journal=A.pin(out/'journal.jsonl'), completedPairs=done,
                  expectedReleasedBytes=sum(row['duplicateMetadata']['allocatedBytes'] for row in plan['pairs'][:done]),
                  freeBefore=before, freeAfter=shutil.disk_usage(ROOT).free,
                  recovery='Canonical bytes and every original path remain present; partial execution is journaled and must be reviewed before another plan.')
    result['observedFreeIncrease'] = result['freeAfter']-before
    if error: result['error'] = error
    A.write_new(out/'report.json', result)
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--apply', action='store_true')
    parser.add_argument('--out', type=Path)
    args = parser.parse_args()
    if args.apply and args.out is None: parser.error('--apply requires --out')
    with A.exclusive():
        plan, inputs = preflight()
        result = apply(args.out, plan, inputs) if args.apply else dict(complete=True, planOnly=True,
            pairs=len(plan['pairs']), allocatedRecipientBytes=plan['allocatedRecipientBytes'])
    print(json.dumps(result, indent=2))
    raise SystemExit(0 if result['complete'] else 1)
