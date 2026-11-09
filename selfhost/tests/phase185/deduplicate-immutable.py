#!/usr/bin/env python3
"""Journal 13 reviewed immutable generated-file hardlink substitutions.

Default is read-only preflight. --apply requires a fresh retention directory.
No target runs. Installed images, sources, current products and unique outputs
remain untouched; every historical generated-file path and its bytes remain.
"""
import argparse
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
PLAN_SHA256 = '9b8d4510063a77f66478a8ca5c70e2c243c065eefc0a322de578893e72b23a63'
RECIPIENT_BYTES = 1171234816


def bound(row):
    return dict(file=str(ROOT/str(A.safe_relative(row['file']))),
                bytes=row['bytes'], sha256=row['sha256'])


def same_bytes(a, b):
    with a.open('rb') as x, b.open('rb') as y:
        while True:
            left, right = x.read(1024*1024), y.read(1024*1024)
            if left != right: return False
            if not left: return True


def canonical_metadata(path, expected, *, added_links=0, owned_operation=None):
    A.need(path.resolve() == path, 'Canonical symlink refused')
    s = path.lstat()
    actual = dict(device=s.st_dev, inode=s.st_ino, size=s.st_size, mode=stat.S_IMODE(s.st_mode),
                  uid=s.st_uid, gid=s.st_gid, links=s.st_nlink, mtimeNs=s.st_mtime_ns,
                  ctimeNs=s.st_ctime_ns, allocatedBytes=s.st_blocks*512)
    A.need(stat.S_ISREG(s.st_mode) and not os.listxattr(path), 'Canonical metadata unsupported')
    wanted = dict(expected, links=expected['links']+added_links)
    if owned_operation is not None:
        # Our immediately preceding link or rename may advance ctime. A link
        # adds exactly one name; replacement preserves that count. Capture the
        # new value after each operation, then require it exactly until the
        # next owned operation. No blanket ctime/link-count exemption.
        A.need(owned_operation in {'link', 'replace'}
               and added_links == (1 if owned_operation == 'link' else 0)
               and actual['ctimeNs'] >= expected['ctimeNs'], 'Unexpected canonical ctime')
        wanted['ctimeNs'] = actual['ctimeNs']
    A.need(actual == wanted, 'Canonical identity/metadata changed')
    return actual


def preflight():
    plan_pin = A.pin(PLAN)
    A.need(plan_pin['sha256'] == PLAN_SHA256, 'Reviewed exact-pair plan changed')
    plan = json.loads(PLAN.read_text())
    A.need(plan['kind'] == 'phase185-explicit-immutable-pairs' and plan['version'] == 1
           and plan['complete'] is True and len(plan['pairs']) == 13, 'Unexpected plan')
    A.need(len(plan['authorities']) == 22, 'Expected eleven guard/closure pairs')
    authorities = [bound(row) for row in plan['authorities']]
    for row in authorities: A.authenticate(row)
    closure_pins = [bound(row) for row in plan['authorities'] if row['role'] == 'closure']
    closed_roots = set()
    for row in plan['authorities']:
        A.need(row['role'] in {'sealed-guard', 'closure'}, 'Unexpected authority role')
        state = json.loads(Path(bound(row)['file']).read_text())
        A.need(state.get('state') == 'sealed', 'Historical run is not sealed')
        if row['role'] == 'closure':
            A.need(state.get('complete') is True, 'Closure is incomplete')
            continue
        A.need(state.get('closed') is True and state.get('closure') in closure_pins,
               'Guard is not committed to an authenticated closure')
        for named in state['artifactRoots']:
            root = Path(named)
            A.need(root.resolve() == root and root.is_relative_to(ROOT/'selfhost/build'), 'Invalid closed root')
            relative = str(root.relative_to(ROOT/'selfhost/build'))
            A.need(plan['rootClassifications'].get(relative) == state.get('classification')
                   and state['classification'] in {'completed', 'qualified'}, 'Unreviewed closed root')
            closed_roots.add(root)
    A.need(len(closed_roots) == 11, 'Expected eleven reviewed closed roots')

    protected = [bound(row) for row in plan['protectedInstalled']]
    A.need(protected[0]['file'] == str(ROOT/'selfhost/manifests/current.json'), 'Installed selector required')
    current = json.loads(A.authenticate(protected[0]).read_text())
    A.need(set(current['components']) == {'qbe', 'js', 'nativeCli', 'x86'}
           and current.get('gateStatus', {}).get('qualified') is True, 'Four qualified installed components required')
    A.need(protected == [protected[0], *[bound(row) for row in current['files'].values()]],
           'Reviewed installed file bindings changed')
    installed_inodes = set()
    for row in protected:
        s = A.authenticate(row).stat()
        installed_inodes.add((s.st_dev, s.st_ino))

    sources, destinations, recipient_inodes, total = set(), set(), set(), 0
    for row in plan['pairs']:
        c, d = A.authenticate(bound(row['canonical'])), A.authenticate(bound(row['duplicate']))
        for path in (c, d):
            relative = path.relative_to(ROOT/'selfhost/build')
            A.need(relative.parts[0] in {'phase170', 'phase171', 'phase174', 'phase177'}
                   and (path.suffix in {'.ssa', '.s'} or path.name == 'stdout')
                   and any(path.is_relative_to(root) for root in closed_roots), 'Outside reviewed generated-file scope')
        cm, dm = canonical_metadata(c, row['canonicalMetadata']), A.metadata(d)
        A.need(dm == row['duplicateMetadata'], 'Recipient identity/metadata changed')
        A.need(cm['device'] == dm['device'] and cm['inode'] != dm['inode']
               and all(cm[key] == dm[key] for key in ('mode', 'uid', 'gid')), 'Metadata or filesystem differs')
        ci, di = (cm['device'], cm['inode']), (dm['device'], dm['inode'])
        A.need(ci not in installed_inodes and di not in installed_inodes, 'Installed inode must never be shared')
        A.need(d not in destinations and di not in recipient_inodes, 'Repeated recipient or inode')
        A.need(same_bytes(c, d), 'Full file bytes differ')
        canonical_metadata(c, row['canonicalMetadata'])
        A.need(A.metadata(d) == dm, 'Recipient changed during comparison')
        destinations.add(d); recipient_inodes.add(di); sources.add(c)
        total += dm['allocatedBytes']
    A.need(not sources & destinations, 'Canonical file is also a recipient')
    A.need(total == plan['allocatedRecipientBytes'] == RECIPIENT_BYTES, 'Reviewed recovery estimate differs')
    return plan, [plan_pin, *authorities, *protected]


def apply(out, plan, inputs):
    out = out.absolute()
    A.need(out.resolve() == out and out.is_relative_to(ROOT/'selfhost/build-retention') and not out.exists(),
           'Fresh canonical retention output required')
    A.need(shutil.disk_usage(ROOT).free >= 5*1024**3 + 2*1024**2, 'Keep 5GiB reserve plus bounded journal scratch')
    out.mkdir(parents=True)
    before = shutil.disk_usage(ROOT).free
    A.write_new(out/'intent.json', dict(kind='phase185-immutable-deduplication-intent', complete=True,
        method=A.pin(__file__), retentionMethod=A.pin(A.__file__), inputs=inputs, plan=plan,
        scope='Exact byte/mode/owner preservation. Original inodes and timestamps are recorded, not preserved. No installed inode is shared; future builds must use fresh paths.'))
    canonical_states = {row['canonical']['file']: row['canonicalMetadata'] for row in plan['pairs']}
    done, error = 0, None
    with (out/'journal.jsonl').open('x') as journal:
        def record(value):
            journal.write(json.dumps(value)+'\n'); journal.flush(); os.fsync(journal.fileno())
        try:
            for row in inputs: A.authenticate(row)
            for index, row in enumerate(plan['pairs']):
                c, d = A.authenticate(bound(row['canonical'])), A.authenticate(bound(row['duplicate']))
                key = row['canonical']['file']
                cm = canonical_metadata(c, canonical_states[key])
                A.need(A.metadata(d) == row['duplicateMetadata'] and same_bytes(c, d), 'Pair changed after preflight')
                temporary = d.with_name(d.name+'.phase185-link')
                A.need(not os.path.lexists(temporary), 'Temporary link already exists')
                record(dict(index=index, event='intent', canonical=row['canonical'], duplicate=row['duplicate'], canonicalBefore=cm))
                made_link = False
                try:
                    os.link(c, temporary, follow_symlinks=False); made_link = True
                    linked = canonical_metadata(c, cm, added_links=1, owned_operation='link')
                    A.authenticate(bound(row['canonical']))
                    canonical_metadata(c, linked)
                    A.need(A.metadata(d) == row['duplicateMetadata'], 'Recipient changed before replacement')
                    os.replace(temporary, d)
                    replaced = canonical_metadata(c, linked, owned_operation='replace')
                    fd = os.open(d.parent, os.O_RDONLY | os.O_DIRECTORY)
                    try: os.fsync(fd)
                    finally: os.close(fd)
                    canonical_metadata(c, replaced)
                    A.need(c.stat().st_ino == d.stat().st_ino and same_bytes(c, d), 'Post-link equality failed')
                    A.authenticate(bound(row['duplicate']))
                    canonical_states[key] = canonical_metadata(c, replaced)
                    done += 1
                    record(dict(index=index, event='complete', allocatedRecipientBytes=row['duplicateMetadata']['allocatedBytes'], canonicalAfter=replaced))
                finally:
                    if made_link and os.path.lexists(temporary): temporary.unlink()
            for row in inputs: A.authenticate(row)
        except BaseException as caught:
            error = repr(caught)
            record(dict(event='stopped', error=error, completedPairs=done))
    result = dict(kind='phase185-immutable-deduplication', complete=error is None, targetsRun=False,
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
