#!/usr/bin/env python3
"""Review exact historical retirement; apply only an explicitly named plan hash.

Planning never changes the Git index or working files. Applying rechecks all
selected bytes and dependencies, removes only exact baseline index entries, and
leaves dirty/protected working files untouched. Never stages replacement content.
"""
import argparse
import bisect
import collections
import hashlib
import json
import os
from pathlib import Path, PurePosixPath
import re
import stat
import subprocess
import sys
import time
from history_data import read_json, write_json

ROOT = Path(__file__).resolve().parents[3]
DEFAULT = 'selfhost/manifests/history-inventory-v2.json.gz'
CODE = {'.py', '.mjs', '.js', '.ts', '.sh'}


def git(root, *args, **kwargs):
    return subprocess.check_output(['git', '-C', str(root), *args], **kwargs)


def safe_path(root, relative):
    p = PurePosixPath(relative)
    if p.is_absolute() or not relative or any(s in ('', '.', '..') for s in relative.split('/')):
        raise ValueError('Unsafe repository path: ' + relative)
    out = root / relative
    for parent in [out, *out.parents]:
        if parent == root:
            break
        if parent.is_symlink():
            raise ValueError('Symlink in selected path: ' + relative)
    return out


def pin(path):
    h = hashlib.sha256()
    with path.open('rb') as stream:
        for block in iter(lambda: stream.read(1024**2), b''):
            h.update(block)
    return dict(file=str(path), bytes=path.stat().st_size, sha256=h.hexdigest())


def working_identity(path):
    before = path.stat()
    if not stat.S_ISREG(before.st_mode):
        raise ValueError('Selected path is not an ordinary file: ' + str(path))
    sha = hashlib.sha256()
    oid = hashlib.sha1(b'blob ' + str(before.st_size).encode() + b'\0')
    with path.open('rb') as stream:
        for block in iter(lambda: stream.read(1024**2), b''):
            sha.update(block); oid.update(block)
    after = path.stat()
    fingerprint = lambda s: (s.st_dev, s.st_ino, s.st_size, s.st_mtime_ns, s.st_ctime_ns)
    if fingerprint(before) != fingerprint(after):
        raise ValueError('File changed while hashing: ' + str(path))
    return dict(bytes=before.st_size, sha256=sha.hexdigest(), gitBlob=oid.hexdigest(),
                gitMode='100755' if before.st_mode & 0o111 else '100644')


def same_working(expected, observed):
    return all(observed.get(key) == value for key, value in expected.items())


def tree(root, baseline):
    rows = {}
    for raw in git(root, 'ls-tree', '-r', '-z', baseline).decode().split('\0'):
        if raw:
            meta, path = raw.split('\t', 1); mode, kind, blob = meta.split()
            if kind == 'blob':
                rows[path] = dict(gitBlob=blob, gitMode=mode)
    return rows


def index(root, **kwargs):
    rows = {}
    for raw in git(root, 'ls-files', '--stage', '-z', **kwargs).decode().split('\0'):
        if raw:
            meta, path = raw.split('\t', 1); mode, blob, stage = meta.split()
            if stage != '0' or path in rows:
                raise ValueError('Unmerged index entry: ' + path)
            rows[path] = dict(gitBlob=blob, gitMode=mode)
    return rows


def canonical_paths(root):
    path = root/'selfhost/src/compiler.json'
    if not path.is_file():
        return set(), []
    data = json.loads(path.read_text())
    protected = {'selfhost/src/compiler.json'}
    for relative in data.get('modules', []):
        protected.add('selfhost/' + relative)
    if data.get('preamble'):
        protected.add('selfhost/' + data['preamble'])
    return protected, [pin(path)]


def dependencies(root, proposed):
    """Conservative literal-reference gate; dynamic dependency review is separate."""
    blockers = collections.defaultdict(list)
    inputs = []
    tools = root/'selfhost/tools'
    if not tools.is_dir():
        return {}, []
    proposed = set(proposed)
    targets = sorted(proposed)
    queue = []
    for path in sorted((root/'selfhost').glob('*')):
        if path.is_file() and path.suffix in CODE and path.relative_to(root).as_posix() not in proposed:
            queue.append(path)
    for directory, children, names in os.walk(tools):
        parent = Path(directory)
        children[:] = [name for name in children
                       if name not in ('__pycache__', '.git', 'node_modules', 'history')
                       and not (parent == tools and name == 'performance')
                       and not (parent == tools/'laws' and re.fullmatch(r'phase\d+', name))]
        for name in names:
            path = parent/name
            if path.suffix not in CODE or path.stat().st_size > 1024**2:
                continue
            relative = path.relative_to(root).as_posix()
            if relative not in proposed:
                queue.append(path)
    visited = set()
    scheduled = {path.relative_to(root).as_posix() for path in queue}
    roots = set(scheduled)
    while queue:
        path = queue.pop()
        relative = path.relative_to(root).as_posix()
        if relative in visited:
            continue
        visited.add(relative)
        inputs.append(pin(path))
        for lineno, line in enumerate(path.read_text().splitlines(), 1):
            if line.lstrip().startswith(('#', '//')):
                continue
            literals = re.findall(r'''["']([^"'\n]+)["']''', line)
            imported = re.match(r'^\s*(?:from\s+(\w+)\s+import|import\s+(\w+))', line)
            if imported:
                literals.append((imported[1] or imported[2])+'.py')
            for text in literals:
                if len(text) > 4096 or any(len(part.encode()) > 255 for part in Path(text).parts):
                    continue
                if all(part in ('.', '..', '/') for part in Path(text).parts):
                    continue  # A base directory expression is not a file dependency.
                choices = []
                if text.startswith('selfhost/'):
                    choices.append(root/text)
                if text.startswith(('src/', 'tools/', 'dist/', 'tests/', 'proofs/', 'runtime/')):
                    choices.append(root/'selfhost'/text)
                if text.startswith(('./', '../')) or '/' in text or Path(text).suffix in CODE | {'.bend','.c','.h','.json','.zip','.gz','.bendtt','.so','.o'}:
                    choices.append(path.parent/text)
                for candidate in choices:
                    try:
                        # Literal-reference analysis is lexical. Resolving every
                        # quoted string probes the filesystem hundreds of thousands
                        # of times; actual selected paths are checked separately.
                        target = Path(os.path.normpath(str(candidate))).relative_to(root).as_posix()
                    except ValueError:
                        continue
                    matched = [target] if target in proposed else []
                    if target not in ('selfhost', 'selfhost/tools', 'selfhost/src', 'selfhost/dist'):
                        prefix = target+'/'
                        at = bisect.bisect_left(targets, prefix)
                        while at < len(targets) and targets[at].startswith(prefix):
                            matched.append(targets[at]); at += 1
                    for match in matched:
                        record = dict(consumer=relative, line=lineno)
                        if record not in blockers[match]:
                            blockers[match].append(record)
                        dependency = root/match
                        if dependency.suffix in CODE and dependency.is_file() and match not in scheduled:
                            scheduled.add(match)
                            queue.append(dependency)
    review = root/'selfhost/manifests/history-dependency-review-v1.json'
    if review.is_file():
        approved = read_json(review)
        if approved.get('schema') != 'bend-history-dependency-review-v1':
            raise ValueError('Unknown dependency review schema')
        inputs.append(pin(review))
        for exception in approved['exceptions']:
            target, consumer = exception['target'], exception['consumer']
            if target not in blockers:
                continue
            if pin(root/consumer)['sha256'] != exception['consumerSha256']:
                raise ValueError('Reviewed dependency consumer changed: '+consumer)
            blockers[target] = [record for record in blockers[target] if record['consumer'] != consumer]
            if not blockers[target]:
                del blockers[target]
    # An exact reviewed edge can disconnect an entire historical subtree.
    # References from that now-unreachable retired code are not active consumers.
    reachable = set(roots)
    while True:
        discovered = {target for target, refs in blockers.items()
                      if any(ref['consumer'] in reachable for ref in refs)}
        if discovered <= reachable:
            break
        reachable.update(discovered)
    blockers = {target: [ref for ref in refs if ref['consumer'] in reachable]
                for target, refs in blockers.items()}
    blockers = {target: refs for target, refs in blockers.items() if refs}
    return dict(blockers), inputs


def save_new(path, value):
    with path.open('x') as stream:
        json.dump(value, stream, indent=2); stream.write('\n')


def make_plan(root, inventory_path, output, prefixes=(), progress=False):
    started = time.monotonic()
    def mark(stage, **fields):
        if progress:
            print(json.dumps(dict(stage=stage, seconds=round(time.monotonic()-started,3), **fields)),file=sys.stderr,flush=True)
    inv_pin = pin(inventory_path)
    inv = read_json(inventory_path)
    mark('inventory-read')
    if inv.get('schema') != 'bend-history-inventory-v1' or not inv.get('proposalOnly'):
        raise ValueError('Expected a proposal inventory')
    baseline = inv['baselineCommit']
    git(root, 'merge-base', '--is-ancestor', baseline, 'HEAD')
    baseline_tree, current = tree(root, baseline), index(root)
    dirty = set(git(root, 'diff', '--name-only', '-z', baseline).decode().split('\0'))
    mark('git-metadata-read')
    canonical, inputs = canonical_paths(root)
    inputs.append(pin(Path(__file__).resolve()))
    inputs.append(pin(Path(__file__).with_name('history_data.py').resolve()))
    proposed = {r['path']: r for r in inv['files'] if r['action'] == 'retire'
                and (not prefixes or any(r['path'].startswith(prefix) for prefix in prefixes))}
    blockers, dependency_inputs = dependencies(root, proposed)
    mark('dependencies-reviewed',blocked=len(blockers))
    inputs += dependency_inputs
    rows, exclusions = [], []
    for relative, entry in proposed.items():
        expected = dict(gitBlob=entry['gitBlob'], gitMode=entry['gitMode'])
        if baseline_tree.get(relative) != expected:
            raise ValueError('Inventory/baseline mismatch: ' + relative)
        reason = ('canonical-source' if relative in canonical else
                  'active-tool-literal-reference' if relative in blockers else
                  'index-does-not-match-baseline' if current.get(relative) != expected else None)
        if reason:
            exclusions.append(dict(path=relative, reason=reason, consumers=blockers.get(relative, [])))
            continue
        path = safe_path(root, relative)
        if not path.exists():
            exclusions.append(dict(path=relative, reason='working-file-missing'))
            continue
        # A review plan need not reread gigabytes of unchanged archived payloads.
        # Apply independently hashes every selected file before touching the index.
        status = path.stat()
        identity = (working_identity(path) if relative in dirty else
                    dict(bytes=status.st_size, gitBlob=entry['gitBlob'],
                         gitMode='100755' if status.st_mode & 0o111 else '100644'))
        clean = all(identity[key] == expected[key] for key in expected)
        if clean and identity['bytes'] != entry['bytes']:
            raise ValueError('Inventory size disagrees with verified blob: ' + relative)
        preserve = not clean or entry.get('workspaceProtected', False)
        rows.append(dict(path=relative, **expected, working=identity,
                         workingIdentityScope='hashed-dirty-bytes' if relative in dirty else 'Git-clean-metadata-full-hash-required-at-apply',
                         operation='index-only' if preserve else 'index-and-worktree',
                         reason=entry['reason']))
        if len(rows)%10000==0:
            mark('working-metadata-reviewed',files=len(rows))
    if pin(inventory_path) != inv_pin:
        raise ValueError('Inventory changed during planning')
    summary = collections.defaultdict(lambda: dict(files=0, bytes=0))
    for row in rows:
        summary[row['operation']]['files'] += 1
        summary[row['operation']]['bytes'] += row['working']['bytes']
    plan = dict(schema='bend-history-retirement-plan-v1', proposalOnly=True,
                baselineCommit=baseline, repository=str(root), inventory=inv_pin,
                inputs=inputs, createdUnix=time.time(), summary=dict(summary),
                exclusions=exclusions, unresolvedInventoryBlockers=[r for r in inv['files'] if r['action']=='blocked'],
                dependencyAuditScope='Conservative literal path references from maintained tool code; migration qualification and dynamic path review remain root approval gates.',
                files=rows)
    save_new(output, plan)
    mark('plan-written',files=len(rows))
    return dict(plan=pin(output), summary=dict(summary), excluded=len(exclusions),
                unresolvedInventoryBlockers=len(plan['unresolvedInventoryBlockers']), applied=False)


def validate_plan(root, plan_path, expected_sha):
    if pin(plan_path)['sha256'] != expected_sha:
        raise ValueError('Plan hash differs from reviewed identity')
    plan = read_json(plan_path)
    if plan.get('schema') != 'bend-history-retirement-plan-v1' or plan['repository'] != str(root):
        raise ValueError('Plan schema/repository mismatch')
    if len({r['path'] for r in plan['files']}) != len(plan['files']):
        raise ValueError('Duplicate planned paths')
    baseline_tree, current = tree(root, plan['baselineCommit']), index(root)
    git(root, 'merge-base', '--is-ancestor', plan['baselineCommit'], 'HEAD')
    canonical, _ = canonical_paths(root)
    for record in [plan['inventory'], *plan['inputs']]:
        if pin(Path(record['file'])) != record:
            raise ValueError('Planning input changed: ' + record['file'])
    inv = read_json(Path(plan['inventory']['file']))
    allowed = {r['path']: r for r in inv['files'] if r['action']=='retire'}
    if inv['baselineCommit'] != plan['baselineCommit']:
        raise ValueError('Inventory baseline changed')
    blockers, _ = dependencies(root, {r['path'] for r in plan['files']})
    if blockers:
        raise ValueError('Active dependency prevents retirement: ' + str(next(iter(blockers))))
    for row in plan['files']:
        relative = row['path']; source = allowed.get(relative)
        expected = dict(gitBlob=row['gitBlob'], gitMode=row['gitMode'])
        if not source or relative in canonical or any(source[k] != expected[k] for k in expected):
            raise ValueError('Path is not an allowed historical entry: ' + relative)
        if baseline_tree.get(relative) != expected or current.get(relative) != expected:
            raise ValueError('Baseline/index changed: ' + relative)
        if not same_working(row['working'], working_identity(safe_path(root, relative))):
            raise ValueError('Working file changed: ' + relative)
        if row['operation'] not in ('index-only', 'index-and-worktree'):
            raise ValueError('Unsupported operation')
        if row['operation'] == 'index-and-worktree' and (source.get('workspaceProtected') or any(row['working'][k] != expected[k] for k in expected)):
            raise ValueError('Dirty/protected file cannot be deleted: ' + relative)
    return plan


def remove_index_entries(root, rows):
    """Replace the index atomically, retaining every unrelated entry verbatim."""
    raw = git(root, 'rev-parse', '--git-path', 'index').decode().strip()
    index_path = (root/raw).resolve() if not Path(raw).is_absolute() else Path(raw)
    lock = index_path.with_name(index_path.name+'.lock')
    fd = os.open(lock, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
    try:
        # Holding the conventional Git lock excludes concurrent Git index writers.
        before = index(root)
        for row in rows:
            if before.get(row['path']) != dict(gitBlob=row['gitBlob'], gitMode=row['gitMode']):
                raise ValueError('Index changed before locked update: ' + row['path'])
        with os.fdopen(fd, 'wb') as stream:
            fd = None
            stream.write(index_path.read_bytes())
        env = dict(os.environ, GIT_INDEX_FILE=str(lock))
        names = ''.join(row['path']+'\0' for row in rows).encode()
        if names:
            git(root, 'update-index', '--force-remove', '-z', '--stdin', input=names, env=env)
        after = index(root, env=env)
        selected = {row['path'] for row in rows}
        if after != {path: value for path, value in before.items() if path not in selected}:
            raise ValueError('Index update changed unrelated entries')
        os.replace(lock, index_path)
    finally:
        if fd is not None:
            os.close(fd)
        if lock.exists():
            lock.unlink()


def apply_plan(root, plan_path, expected_sha, receipt_path):
    if receipt_path.exists():
        raise ValueError('Receipt must be new')
    plan = validate_plan(root, plan_path, expected_sha)
    receipt = dict(schema='bend-history-retirement-receipt-v1', complete=False,
                   planSha256=expected_sha, baselineCommit=plan['baselineCommit'],
                   recoveryIndex=plan['inventory'], plannedSummary=plan['summary'],
                   preservedWorking=[dict(path=row['path'],working=row['working']) for row in plan['files'] if row['operation']=='index-only'],
                   indexUpdated=False, deleted=[], preserved=[], conflicts=[])
    # Journal before mutation; Git updates the index under its own index.lock.
    with receipt_path.open('xb'):
        pass
    write_json(receipt_path, receipt)
    try:
        remove_index_entries(root, plan['files'])
        receipt['indexUpdated'] = True
        write_json(receipt_path, receipt)
        for row in plan['files']:
            path = safe_path(root, row['path'])
            if row['operation'] == 'index-only':
                receipt['preserved'].append(row['path'])
            elif not same_working(row['working'], working_identity(path)):
                # Index entry is recoverable; preserve any unexpectedly edited bytes.
                receipt['conflicts'].append(row['path'])
            else:
                path.unlink()
                receipt['deleted'].append(row['path'])
        receipt['complete'] = not receipt['conflicts']
    finally:
        write_json(receipt_path, receipt)
    return dict(complete=receipt['complete'], deleted=len(receipt['deleted']),
                preserved=len(receipt['preserved']), conflicts=receipt['conflicts'], receipt=pin(receipt_path))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest='command', required=True)
    plan = sub.add_parser('plan', help='Read-only proposal; never deletes or stages')
    plan.add_argument('--inventory', type=Path, default=ROOT/DEFAULT)
    plan.add_argument('--prefix', action='append', default=[])
    plan.add_argument('--out', type=Path, required=True)
    plan.add_argument('--progress', action='store_true')
    apply = sub.add_parser('apply', help='Apply an explicitly reviewed exact plan')
    apply.add_argument('--plan', type=Path, required=True)
    apply.add_argument('--sha256', required=True)
    apply.add_argument('--receipt', type=Path, required=True)
    args = parser.parse_args()
    if args.command == 'plan':
        result = make_plan(ROOT, args.inventory.resolve(), args.out.resolve(), args.prefix, args.progress)
    else:
        result = apply_plan(ROOT, args.plan.resolve(), args.sha256, args.receipt.resolve())
    print(json.dumps(result, indent=2))


if __name__ == '__main__':
    main()
