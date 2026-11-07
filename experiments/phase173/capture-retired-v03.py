#!/usr/bin/env python3
"""Capture one reviewed Phase173 retired root; never prune or reopen a lifecycle.

Host metadata transport only. Root separately applies the maintained verifier's
exact plan. --check-only repeats live dependency/identity admission without IO
mutation and should run immediately before that separate apply.
"""
import argparse
import collections
import hashlib
import importlib.util
import json
from pathlib import Path
import shutil
import sys
import time

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[2]
BUILD = ROOT / 'selfhost/build/phase173'
PROPOSAL = ROOT / 'experiments/phase173/storage-proposal03.json'
PROPOSAL_SHA = '9cbdb29e0d4c491a74cb40e014e5c8f44b9849022e61d0d69b236eb37ca4bad1'
RESERVE, LIMIT = 5 * 1024**3, 32 * 1024**2
ACTIVE_PREFIXES = ('dispatch-', 'plan-', 'borrow-', 'consuming-', 'pattern-',
                   'layout-', 'store-wide8-', 'erased-', 'owned-decomposition',
                   'automatic-')
LEAVES = {
    'source-snapshot': {'compiler.bend', 'manifest.json'},
    'retired-hosted-api': {'api.mjs'},
    'optional-completed-verifier-values': {
        'complete-input-values.json', 'baseline-complete-values.json',
        'candidate-complete-values.json'},
}


def need(condition, message):
    if not condition:
        raise ValueError(message)


def load(name, identity):
    path = Path(identity['file'])
    data = path.read_bytes()
    need(len(data) == identity['bytes'] and hashlib.sha256(data).hexdigest() ==
         identity['sha256'], 'Changed maintained method: ' + str(path))
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def strings(value):
    if isinstance(value, dict):
        for child in value.values():
            yield from strings(child)
    elif isinstance(value, list):
        for child in value:
            yield from strings(child)
    elif isinstance(value, str):
        yield value


def protected_now(proposal):
    """Rebuild the reviewed closure; additionally seed every new binding/active run."""
    roots = set()
    for root in BUILD.iterdir():
        if not root.is_dir() or root.name.endswith('-guard'):
            continue
        n = root.name
        if (n.startswith(ACTIVE_PREFIXES) or
                n.startswith('abi-') and n.endswith('03') or
                n in {'vertical-base-api02', 'vertical-base-source02',
                      'store-native-candidate-source02'} or
                (root / 'binding.json').is_file()):
            roots.add(root)
    protected = {ROOT / p for p in proposal['dependencyAudit']['protectedFiles']}
    queue = collections.deque()
    for root in roots:
        for p in root.iterdir():
            if p.is_file():
                protected.add(p)
                if p.suffix == '.json':
                    queue.append(p)
    # The exclusive execution lock normally excludes live guarded work. Retain
    # its declared inputs as well, including a finished run not yet sealed.
    for guard in BUILD.glob('*-guard'):
        retention = guard / 'retention.json'
        if retention.is_file():
            state = json.loads(retention.read_text())
            if state.get('state') != 'sealed':
                queue.extend([retention, guard / 'process.json'])
    seen = set()
    while queue:
        p = queue.popleft()
        if p in seen or not p.is_file():
            continue
        seen.add(p)
        protected.add(p)
        if p.suffix != '.json':
            continue
        need(p.stat().st_size <= 16 * 1024**2,
             'Oversized live dependency JSON needs explicit review: ' + str(p))
        for value in strings(json.loads(p.read_text())):
            if not (value.startswith(str(BUILD) + '/') or
                    value.startswith('selfhost/build/phase173/')):
                continue
            child = Path(value) if value.startswith('/') else ROOT / value
            if child.is_file():
                protected.add(child)
                queue.append(child)
            elif child.is_dir():
                # Declared active artifact roots are protected as prefixes.
                protected.add(child)
    return protected, dict(seedRoots=len(roots), traversedFiles=len(seen),
                           protectedPaths=len(protected))


def admission(A, proposal, row):
    raw = ROOT / row['root']
    need(raw.parent == BUILD and raw.resolve() == raw, 'Wrong scoped root')
    need(row['kind'] in LEAVES, 'Unreviewed artifact kind')
    evidence = row['terminalReaderOrWriter']
    docs = {key: json.loads(A.authenticate(value).read_text())
            for key, value in evidence.items()}
    guard, lifecycle, closure = docs['guard'], docs['lifecycle'], docs['closure']
    need('finished' in guard and isinstance(guard.get('returncode'), int),
         'Reader/writer has not terminated')
    need(lifecycle.get('state') == 'sealed' and
         lifecycle.get('classification') in {'completed', 'failed'} and
         lifecycle['closure'] == evidence['closure'] and closure.get('complete'),
         'Original lifecycle must remain sealed and authenticated')
    if row['kind'] == 'source-snapshot':
        need(Path(row['sourceWriter']['file']) == raw / 'manifest.json',
             'Snapshot authority must be its exact reviewed manifest')
        writer = json.loads(A.authenticate(row['sourceWriter']).read_text())
        need(writer.get('complete') and writer.get('targetsRun') is False,
             'Metadata source writer is incomplete')
        need(writer['source']['file'] == str(raw / 'compiler.bend') and
             docs['report']['source'] == writer['source'],
             'Terminal API reader does not authenticate this snapshot source')
        A.authenticate(writer['source'])
    else:
        need(docs['report'].get('complete') and guard.get('complete') and
             guard['returncode'] == 0 and lifecycle['classification'] == 'completed',
             'Successful completed writer required')
    protected, audit = protected_now(proposal)
    selected = []
    for item in row['selectedFiles']:
        p = ROOT / item['file']
        need(p.parent == raw and p.name in LEAVES[row['kind']],
             'Only exact reviewed leaf names are admitted')
        need(not any(p == q or p.is_relative_to(q) for q in protected),
             'Selected file is a live/protected dependency: ' + str(p))
        need(A.metadata(p) == item['metadata'], 'Changed reviewed inode: ' + str(p))
        actual = A.pin(p)
        need({k: actual[k] for k in ('bytes', 'sha256')} ==
             {k: item[k] for k in ('bytes', 'sha256')}, 'Changed reviewed bytes')
        selected.append(p)
    need(selected and len(selected) == len(set(selected)), 'Empty/duplicate selection')
    need(sum(A.metadata(p)['allocatedBytes'] for p in selected) == row['allocatedBytes'],
         'Reviewed allocation differs')
    return raw, selected, audit


class Budget:
    """Retain the current reserve; bound each fresh receipt/capsule root."""
    def __init__(self, out):
        self.out, self.minimum, self.next_check = out, shutil.disk_usage(ROOT).free, 0

    def check(self, *, additional=0, force=False):
        need(additional <= LIMIT, 'Capsule exceeds the reviewed scratch bound')
        if force or time.monotonic() >= self.next_check:
            free = shutil.disk_usage(ROOT).free
            self.minimum = min(self.minimum, free)
            need(free >= RESERVE + additional, 'Insufficient 5 GiB reserve/scratch')
            allocated = sum(p.stat().st_blocks * 512 for p in self.out.rglob('*')
                            if p.is_file()) if self.out.exists() else 0
            need(allocated <= LIMIT, 'Fresh archive/receipt root exceeds 32 MiB')
            self.next_check = time.monotonic() + .1


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--name', required=True)
    parser.add_argument('--out', type=Path)
    parser.add_argument('--check-only', action='store_true')
    args = parser.parse_args()
    data = PROPOSAL.read_bytes()
    need(hashlib.sha256(data).hexdigest() == PROPOSAL_SHA, 'Reviewed proposal changed')
    proposal = json.loads(data)
    A = load('phase173_capture_archive', proposal['archiveVerifier'])
    C = load('phase173_capture_capsule', proposal['genericCapsuleImplementation'])
    rows = [r for r in proposal['roots'] if r['name'] == args.name]
    need(len(rows) == 1, 'Exactly one reviewed root required')
    need(proposal['requiredReserveBytes'] == RESERVE and
         proposal['archiveBudgetPerRootBytes'] == LIMIT, 'Unexpected reviewed budgets')
    with A.exclusive():
        raw, selected, audit = admission(A, proposal, rows[0])
        if args.check_only:
            need(args.out is None, '--check-only does not create an output')
            print(json.dumps(dict(complete=True, checkOnly=True, targetsRun=False,
                                  files=len(selected), dependencies=audit)))
            return
        need(args.out is not None, '--out required for capture')
        out = args.out.absolute()
        need(out.resolve() == out and
             out.is_relative_to(ROOT / 'selfhost/build-retention/phase173') and
             not out.exists() and not any(out.is_relative_to(p) for p in selected),
             'Fresh Phase173 retention output required')
        budget = Budget(out)
        budget.check(additional=LIMIT, force=True)
        out.mkdir(parents=True)
        A.write_new(out / 'intent.json', dict(complete=True, proposal=A.pin(PROPOSAL),
                    method=A.pin(__file__), row=args.name, dependencies=audit,
                    writers=rows[0]['terminalReaderOrWriter'], files=rows[0]['selectedFiles'],
                    scope='Exact-leaf capture only; no deletion or lifecycle update.'))
        try:
            members = [dict(path=p, name=p.name, signature=C.signature(p),
                            identity={k: A.pin(p)[k] for k in ('bytes', 'sha256')})
                       for p in selected]
            receipt = C.capsule(raw, sorted(members, key=lambda r: r['name']),
                                out / 'capsule', budget)
            _, selected_after, after = admission(A, proposal, rows[0])
            need(selected_after == selected, 'Live admission changed')
            protected, _ = protected_now(proposal)
            policy = dict(allowedRoots=[rows[0]['root']],
                archiveRoots={str(receipt.relative_to(ROOT)): rows[0]['root']},
                keepPrefixes=sorted(str(p.relative_to(ROOT)) for p in protected),
                reviewedProposal=A.pin(PROPOSAL),
                scope='Only approved archive members; original closures remain sealed.')
            A.write_new(out / 'policy.json', policy)
            plan = A.verify(argparse.Namespace(policy=out / 'policy.json', receipt=receipt,
                                               out=out / 'verified'))
            need(plan['selectedFiles'] == len(selected) and
                 plan['allocatedBytes'] == rows[0]['allocatedBytes'],
                 'Verifier selected a different set; do not suppress protected refusals')
            expected = {str(ROOT / item['file']): (item['bytes'], item['sha256'])
                        for item in rows[0]['selectedFiles']}
            verified = {item['file']['file']: (item['file']['bytes'], item['file']['sha256'])
                        for item in A.plan_files(plan)}
            need(verified == expected, 'Verified path/byte allowlist differs')
            budget.check(force=True)
            A.write_new(out / 'capture.json', dict(complete=True, targetsRun=False,
                deletedFiles=0, lifecycleChanged=False, proposal=A.pin(PROPOSAL),
                archiveReceipt=A.pin(receipt), plan=A.pin(out / 'verified/plan.json'),
                sourceUnchanged=True, dependencies=after, minimumFreeBytes=budget.minimum,
                applyPreflight=['python3', '-B', str(Path(__file__).relative_to(ROOT)),
                                '--name', args.name, '--check-only']))
            budget.check(force=True)
            print(json.dumps(dict(complete=True, files=len(selected), deletedFiles=0,
                                  plan=str(out / 'verified/plan.json'))))
        except Exception as error:
            A.write_new(out / 'capture-error.json', dict(complete=False, error=repr(error),
                        deletedFiles=0, scope='Incomplete capture retained; source files untouched.'))
            raise


if __name__ == '__main__':
    main()
