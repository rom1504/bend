#!/usr/bin/env python3
"""Prepare the existing release gates with an exact audited packaging-only delta."""
import argparse
import ast
import hashlib
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
PROJECT = ROOT/'selfhost'
RAW = PROJECT/'build/phase63'
ADAPTER = Path(__file__).resolve()
PARENT = PROJECT/'tools/performance/phase53/release-qualification-plan-v1.py'
PARENT_SHA = 'befbedf7ffdba8649d50911cb0b0e86712d435895b1dd1edc10f06f20691111a'


def identity(value):
    file = Path(value['file'] if isinstance(value, dict) else value).resolve(strict=True)
    row = dict(file=str(file), sha256=hashlib.sha256(file.read_bytes()).hexdigest(), bytes=file.stat().st_size)
    if isinstance(value, dict):
        assert row['sha256'] == value['sha256'], str(file)
        if 'bytes' in value:
            assert row['bytes'] == value['bytes'], str(file)
    return row


def read(value):
    return json.loads(Path(identity(value)['file']).read_text())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('attempt', type=Path)
    parser.add_argument('new_output', type=Path)
    parser.add_argument('--ledger', type=Path)
    parser.add_argument('--plan', type=Path, required=True)
    parser.add_argument('--packager-patch', type=Path, required=True)
    args = parser.parse_args()
    assert args.new_output.resolve().is_relative_to(RAW.resolve()) and not args.new_output.exists()
    assert args.plan.resolve().is_relative_to(RAW.resolve()) and not args.plan.exists()
    parent = identity(PARENT)
    assert parent['sha256'] == PARENT_SHA
    patch_file = identity(args.packager_patch)
    patch = read(patch_file)
    before, after = identity(patch['before']), identity(patch['after'])
    assert before['sha256'] != after['sha256'], 'A real packaging delta is required'
    assert isinstance(patch['edits'], list) and patch['edits']
    replay = Path(before['file']).read_text()
    for edit in patch['edits']:
        assert isinstance(edit['old'], str) and edit['old'] and isinstance(edit['new'], str)
        assert replay.count(edit['old']) == 1, 'Packager edit must match exactly once'
        replay = replay.replace(edit['old'], edit['new'])
    assert replay == Path(after['file']).read_text(), 'Unrecorded packager change'

    attempt_file = args.attempt.resolve(strict=True)/'attempt.json'
    attempt = read(attempt_file)
    assert attempt['checked'] is True and attempt['artifactKind'] == 'derived-b1'
    for key in ['api', 'checkedApi', 'runtime', 'base', 'bootstrapReport', 'derivationReport']:
        identity(attempt[key])
    snapshot = Path(attempt['snapshot']['root'])
    frozen = {row['frozen']['file']: row['frozen'] for row in attempt['snapshot']['sources']}
    snapshot_release = identity(snapshot/'tools/development/release.mjs')
    current_release = identity(PROJECT/'tools/development/release.mjs')
    assert snapshot_release['sha256'] == before['sha256']
    assert current_release['sha256'] == after['sha256']
    assert identity(frozen[snapshot_release['file']]) == snapshot_release

    graph_snapshot = identity(snapshot/'tools/base-cache-graph.mjs')
    graph_current = identity(PROJECT/'tools/base-cache-graph.mjs')
    assert graph_snapshot['sha256'] == graph_current['sha256']
    assert identity(frozen[graph_snapshot['file']]) == graph_snapshot
    bootstrap = read(attempt['bootstrapReport'])
    assert bootstrap['stage'] == 'upstream-bootstrap' and bootstrap['provenance']['verifiedAfterBuild'] is True
    assert bootstrap['apiSha256'] == attempt['checkedApi']['sha256']
    helper_inputs = [row for row in bootstrap['provenance']['inputs']
        if row.get('role') == 'host-tool' and Path(row['file']).name == 'base-cache-graph.mjs']
    assert len(helper_inputs) == 1 and identity(helper_inputs[0]) == graph_snapshot
    assert bootstrap['sourceSha256'] == identity(bootstrap['source'])['sha256']

    source = PARENT.read_text()
    edits = []

    def change(old, new):
        nonlocal source
        assert source.count(old) == 1, old
        source = source.replace(old, new)
        edits.append(dict(old=old, new=new))

    change("for name in ['tools/typed-driver.mjs','tools/development/release.mjs','src/runtime/js/effs/manifest.json']:",
           "for name in ['tools/typed-driver.mjs','tools/base-cache-graph.mjs','src/runtime/js/effs/manifest.json']:")
    change('tools=[identity(f) for f in [__file__,legacy,legacy_runner,direct,release,job,guard]],steps=steps,',
           'tools=[identity(f) for f in [__file__,legacy,legacy_runner,direct,release,job,guard,*closureTools]],steps=steps,packagerClosure=closure,')
    ast.parse(source, filename=str(PARENT))
    closure = dict(kind='phase63-audited-release-packager-closure', producer=identity(ADAPTER),
        patch=patch_file, before=before, after=after, snapshotRelease=snapshot_release,
        currentRelease=current_release, graphSnapshot=graph_snapshot, graphCurrent=graph_current,
        checkedBootstrap=identity(attempt['bootstrapReport']), parent=parent, methodEdits=edits,
        derivedMethodSha256=hashlib.sha256(source.encode()).hexdigest(), compilerRebuilt=False,
        scope='Only the packager may differ from the checked snapshot, by the exact retained delta. '
        'Driver, graph helper, compiler source, APIs, Base and runtimes retain their checked identities. '
        'The original five release target commands and oracles are unchanged; this plan executes none.')
    closure_tools = [ADAPTER, Path(patch_file['file']), Path(before['file']), Path(after['file']),
                     Path(graph_snapshot['file']), Path(graph_current['file'])]
    stable = [identity(file) for file in closure_tools] + [parent, snapshot_release, current_release]
    argv = [str(PARENT), str(args.attempt), str(args.new_output), '--plan', str(args.plan)]
    if args.ledger:
        argv += ['--ledger', str(args.ledger)]
    old_argv = sys.argv
    try:
        sys.argv = argv
        exec(compile(source, str(PARENT), 'exec'), dict(__file__=str(PARENT), __name__='__main__',
            closureTools=closure_tools, closure=closure))
    finally:
        sys.argv = old_argv
    for row in stable:
        identity(row)
    plan = read(args.plan)
    assert [step['name'] for step in plan['steps']] == ['install', 'verify-before', 'legacy42', 'default24', 'verify-after']
    assert plan['steps'][2]['expected']['steps'] == 42 and plan['steps'][3]['expected']['steps'] == 24
    assert plan['api']['sha256'] == attempt['api']['sha256'] and plan['packagerClosure'] == closure


if __name__ == '__main__':
    main()
