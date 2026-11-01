#!/usr/bin/env python3
"""Inventory exact historical Git blobs; never remove files or change the index."""
import argparse
import collections
import copy
import hashlib
import json
from pathlib import Path
import re
import subprocess
from history_data import read_json, write_json

ROOT = Path(__file__).resolve().parents[3]
DEFAULT_POLICY = ROOT / 'selfhost/manifests/history-policy-v1.json'
CODE = {'.py', '.mjs', '.js', '.ts', '.c', '.h', '.bend', '.lean', '.sh'}
ARCHIVE = ('.tar.gz', '.tar.xz', '.tar.zst', '.zip', '.gz', '.xz', '.zst')
SPLIT_ARCHIVE = re.compile(r'^(?P<archive>.+\.(?:tar\.(?:gz|xz|bz2|zst|zstd)|tgz|tbz2|txz|tzst|zip|gz|xz|bz2|zst|zstd))\.part-?(?P<number>\d+)$', re.I)
TEST_SEGMENT = re.compile(r'^(?:fixtures?|controls?|cases?|tests?|oracles?|proofs?|laws|challenges?)(?:[-_0-9].*)?$')


def git(*args, **kwargs):
    return subprocess.check_output(['git', '-C', str(ROOT), *args], **kwargs)


def hash_file(path):
    h = hashlib.sha256()
    with path.open('rb') as stream:
        for block in iter(lambda: stream.read(1024**2), b''):
            h.update(block)
    return h.hexdigest()


def classify(path, policy):
    p = Path(path)
    if path in policy['keepPaths']:
        return 'keep', 'active-stable-dependency'
    if path in policy['pendingMigrationPaths']:
        return 'blocked', 'stable-dependency-awaiting-migration'
    if any(path.startswith(prefix) for prefix in policy.get('pendingMigrationPrefixes', [])):
        return 'blocked', 'installed-assets-awaiting-migration'
    if path in policy.get('retirePaths', []):
        return 'retire', 'explicitly-reviewed-retired-file'
    if any(path.startswith(prefix) for prefix in policy.get('retirePrefixes', [])):
        return 'retire', 'explicitly-reviewed-retired-surface'
    if path.startswith('selfhost/tests/conformance/'):
        return 'keep', 'independent-conformance-harness-or-scientific-report'
    if path.startswith(('selfhost/dist/release-history/', 'selfhost/dist/phase1/', 'selfhost/dist/selfhost/')):
        if p.suffix in CODE or p.suffix in {'.hvm', '.bendtt'}:
            return 'retire', 'historical-distribution-compiler-copy'
    if re.fullmatch(r'[0-9a-f]{64}\.gz', p.name) and 'objects' in p.parts:
        return 'retire', 'content-addressed-historical-capsule-object'
    if SPLIT_ARCHIVE.fullmatch(path):
        return 'retire', 'historical-split-archive-part-recoverable-from-git'
    if path.endswith(ARCHIVE):
        return 'retire', 'historical-archive-recoverable-from-git'
    test_asset = any(TEST_SEGMENT.match(s) for s in p.parts)
    compiler_copy = p.name.startswith('compiler') and p.suffix in CODE
    compiler_copy |= '/host/' in path or '/selfhost/src/' in path
    if test_asset and not compiler_copy and (p.suffix in {'.bend', '.bendtt', '.lean', '.c', '.h', '.expected', '.json', '.txt'} or re.search(r'oracle|expected', p.name)):
        return 'keep', 'independent-test-proof-oracle-asset-review'
    if p.suffix in CODE:
        return 'retire', 'historical-method-or-source-copy'
    if p.suffix in {'.ssa', '.asm', '.ll', '.o', '.so', '.a'}:
        return 'retire', 'historical-generated-code'
    return 'keep', 'report-metadata-or-other-evidence'


def archive_groups(files):
    grouped = collections.defaultdict(list)
    for entry in files:
        match = SPLIT_ARCHIVE.fullmatch(entry['path'])
        if match:
            grouped[match['archive']].append(dict(path=entry['path'], partNumber=int(match['number']),
                gitBlob=entry['gitBlob'], bytes=entry['bytes']))
    result = []
    for archive, parts in sorted(grouped.items()):
        parts.sort(key=lambda part: (part['partNumber'], part['path']))
        numbers = [part['partNumber'] for part in parts]
        consecutive = numbers[0] in (0, 1) and numbers == list(range(numbers[0], numbers[-1]+1))
        result.append(dict(archivePath=archive, partCount=len(parts), bytes=sum(part['bytes'] for part in parts),
            firstPart=numbers[0], lastPart=numbers[-1], consecutiveTrackedParts=consecutive,
            completenessScope='All matching parts tracked at the pinned baseline; consecutive numbering is checked, archive payload integrity is not inferred.',
            recovery='Restore each exact Git blob in listed numeric order; parts are never decompressed or repacked by this metadata tool.', parts=parts))
    return result


def refresh_policy(previous, policy):
    """Reclassify the complete recovery catalog without re-surveying the checkout."""
    if previous.get('schema') != 'bend-history-inventory-v1' or not previous.get('proposalOnly'):
        raise ValueError('Expected a proposal recovery inventory')
    if previous['baselineCommit'] != policy['baselineCommit']:
        raise ValueError('Policy refresh cannot change the recovery baseline')
    result = copy.deepcopy(previous)
    summary = collections.defaultdict(lambda: dict(files=0, bytes=0))
    for entry in result['files']:
        action, reason = classify(entry['path'], policy)
        entry.update(action=action, reason=reason)
        entry.pop('application', None)
        if action == 'retire':
            entry['application'] = ('index-only-preserve-working-bytes' if entry.get('workspaceProtected')
                                    else 'review-before-removal')
        summary[action]['files'] += 1
        summary[action]['bytes'] += entry['bytes']
    result['summary'] = dict(summary)
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--policy', type=Path, default=DEFAULT_POLICY)
    parser.add_argument('--out', type=Path, default=ROOT/'selfhost/manifests/history-inventory-v2.json.gz')
    parser.add_argument('--refresh-policy-only', action='store_true',
                        help='Keep every recovery identity and original workspace pin; only refresh policy classifications')
    args = parser.parse_args()
    policy = json.loads(args.policy.read_text())
    assert policy['schema'] == 'bend-history-policy-v1'
    commit = policy['baselineCommit']
    assert git('rev-parse', commit+'^{commit}').decode().strip() == commit
    if args.refresh_policy_only:
        previous_sha = hash_file(args.out)
        result = refresh_policy(read_json(args.out), policy)
        result['method'] = dict(path=str(Path(__file__).relative_to(ROOT)), sha256=hash_file(Path(__file__)))
        result['policy'] = dict(path=str(args.policy.relative_to(ROOT)), sha256=hash_file(args.policy))
        result['policyRefresh'] = dict(previousIndexSha256=previous_sha,
            recoveryIdentitiesPreserved=True, originalWorkspacePinsPreserved=True,
            currentWorkingTreeResurveyed=False)
        write_json(args.out, result)
        print(json.dumps(dict(output=str(args.out), summary=result['summary'],
                              recoveryRows=len(result['files']), policyOnly=True), indent=2))
        return
    files = []
    for record in git('ls-tree', '-r', '-z', commit).decode().split('\0'):
        if not record:
            continue
        meta, path = record.split('\t', 1)
        mode, kind, blob = meta.split()
        if kind == 'blob' and any(path.startswith(p) for p in policy['scopePrefixes']):
            files.append(dict(path=path, gitBlob=blob, gitMode=mode))
    # Clean tracked working files already have the baseline byte length. Avoid
    # resolving tens of thousands of deep Git deltas merely to count their size.
    # Retrieval independently checks every declared size against the Git blob.
    dirty = set(git('diff', '--name-only', '-z', commit).decode().split('\0')) - {''}
    sizes = {}
    if args.out.is_file():
        previous = read_json(args.out)
        if previous.get('schema') == 'bend-history-inventory-v1' and previous.get('baselineCommit') == commit:
            sizes.update({entry['gitBlob']: entry['bytes'] for entry in previous['files']})
    missing = set()
    for entry in files:
        path = ROOT/entry['path']
        if entry['path'] not in dirty and path.is_file() and not path.is_symlink():
            size = path.stat().st_size
            if entry['gitBlob'] in sizes:
                assert sizes[entry['gitBlob']] == size
            sizes[entry['gitBlob']] = size
        else:
            missing.add(entry['gitBlob'])
    ids = sorted(missing - sizes.keys())
    rows = git('cat-file', '--batch-check=%(objectname) %(objecttype) %(objectsize)', input=('\n'.join(ids)+'\n').encode()).decode().splitlines() if ids else []
    for row in rows:
        blob, kind, size = row.split()
        assert kind == 'blob'
        sizes[blob] = int(size)
    dirty_pins = []
    summary = collections.defaultdict(lambda: dict(files=0, bytes=0))
    for entry in files:
        path = entry['path']; action, reason = classify(path, policy)
        entry.update(bytes=sizes[entry['gitBlob']], action=action, reason=reason)
        protected = path in dirty or any(path.startswith(prefix) for prefix in policy['preserveWorkspacePrefixes'])
        if protected:
            entry['workspaceProtected'] = True
            if action == 'retire':
                entry['application'] = 'index-only-preserve-working-bytes'
        elif action == 'retire':
            entry['application'] = 'review-before-removal'
        if path in dirty:
            current = ROOT/path
            dirty_pins.append(dict(path=path, baselineGitBlob=entry['gitBlob'], exists=current.exists(),
                **(dict(bytes=current.stat().st_size, sha256=hash_file(current)) if current.is_file() else {})))
        summary[action]['files'] += 1; summary[action]['bytes'] += entry['bytes']
    result = dict(schema='bend-history-inventory-v1', baselineCommit=commit,
        proposalOnly=True, targetsRun=False, indexModified=False,
        method=dict(path=str(Path(__file__).relative_to(ROOT)), sha256=hash_file(Path(__file__))),
        policy=dict(path=str(args.policy.relative_to(ROOT)), sha256=hash_file(args.policy)),
        scope='Exact Git recovery inventory; automatic classification is a review proposal, not permission to delete.',
        summary=dict(summary), dirtyTrackedFiles=dirty_pins, archiveGroups=archive_groups(files), files=files)
    write_json(args.out, result)
    print(json.dumps(dict(output=str(args.out), summary=dict(summary), dirtyTrackedFiles=len(dirty_pins)), indent=2))


if __name__ == '__main__':
    main()
