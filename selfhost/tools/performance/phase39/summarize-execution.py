#!/usr/bin/env python3
"""Summarize fresh three-role execution reports without pooling fixed inputs.

No compiler, execution worker or profiler is run. Ratios always come from one
same-run case; differently warmed groups retain their own protocol and ranges.
"""
import argparse
import hashlib
import json
import math
from pathlib import Path
import sys

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent/'programs'))
from run import summarize


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--attempt', type=Path, required=True)
    ap.add_argument('--catalog', type=Path, default=HERE.parent/'phase37/catalog.json')
    ap.add_argument('--report', type=Path, action='append', required=True)
    ap.add_argument('--confirmation-report', type=Path, action='append', default=[], help='Explicit separately reported repetitions; never pooled with primary results')
    ap.add_argument('--out', type=Path, required=True)
    ap.add_argument('--require-full', action='store_true', help='Require exactly one complete result per frozen point')
    a = ap.parse_args()
    inputs = {}

    def identity(file):
        file = Path(file).resolve()
        digest = hashlib.sha256()
        with file.open('rb') as stream:
            for block in iter(lambda: stream.read(2**20), b''):
                digest.update(block)
        return dict(file=str(file), sha256=digest.hexdigest(), bytes=file.stat().st_size)

    def keep(file, ref=None):
        row = identity(file)
        if ref:
            assert row['sha256'] == ref['sha256'], file
            assert 'bytes' not in ref or row['bytes'] == ref['bytes'], file
        if row['file'] in inputs:
            assert inputs[row['file']] == row, file
        inputs[row['file']] = row
        return row

    def pointer(ref):
        name = ref.get('file', ref.get('path'))
        assert Path(name).is_absolute(), name
        return keep(name, ref)

    def read(file):
        keep(file)
        return json.loads(Path(file).read_text())

    keep(__file__)
    keep(HERE.parent/'programs/run.py')
    keep(HERE.parent/'programs/support.py')
    parent = keep(HERE.parent/'phase37/summarize-expanded.py')
    attempt_file = a.attempt/'attempt.json' if a.attempt.is_dir() else a.attempt
    attempt, catalog = read(attempt_file), read(a.catalog)
    assert attempt['checked'] and attempt['artifactKind'] == 'derived-b1'
    assert catalog['kind'] == 'bend-program-catalog' and len(catalog['cases']) == 45
    by_id = {row['id']: row for row in catalog['cases']}
    assert len(by_id) == 45
    groups, rows, seen = [], [], set()
    confirmations, primary_modules = [], {}
    bootstrap = read(pointer(attempt['bootstrapReport'])['file'])
    driver = next(row['frozen'] for row in attempt['snapshot']['sources']
                  if Path(row['frozen']['file']).relative_to(attempt['snapshot']['root']).as_posix() == 'tools/typed-driver.mjs')
    for row in attempt['snapshot']['sources']:
        pointer(row['frozen'])
    selected_node = pointer(attempt['node'])
    compilers = None
    node_path, node_version = None, None
    for file, confirmation in [(p, False) for p in a.report] + [(p, True) for p in a.confirmation_report]:
        if file.is_dir():
            file = file/'report.json'
        data = read(file)
        assert data['kind'] == 'bend-program-execution-report'
        assert data['complete'] and data['pass'] and data['status'] == 'measured', file
        plan = data['plan']
        assert set(plan['roles']) == {'baseline', 'candidate', 'typescript'}
        assert plan['cpu'] == 3 and plan['heapMiB'] <= 1024 and plan['rssMiB'] <= 2048
        assert plan['availableMiB'] >= 2048
        if node_path is None:
            node_path = plan['node']
        assert plan['node'] == node_path, 'Different Node paths across runs'
        assert keep(plan['node']) == selected_node, 'Node binary differs from selected attempt'
        variants = {name: value['compiler'] for name, value in plan['variants'].items()}
        assert set(variants) == {'baseline', 'candidate', 'typescript'}
        if compilers is None:
            compilers = variants
        else:
            assert variants == compilers, 'Different compiler identities across reports'
        assert variants['baseline']['api']['sha256'] == 'ea5db4a2857ffddce8263406041f56acc9b613754660d7a20c6b7c58682c86a1'
        assert variants['typescript']['kind'] == 'checked-pinned-typescript'
        assert variants['candidate']['kind'] == 'checked-development-attempt'
        for name, compiler in variants.items():
            assert compiler['upstreamCommit'] == catalog['upstreamCommit']
            if name == 'typescript':
                assert len(compiler['sources']) == 3
                for entry in compiler['sources']:
                    pointer(entry)
            else:
                for key in ['api', 'runtime', 'base', 'driver']:
                    pointer(compiler[key])
        for key in ['api', 'runtime', 'base']:
            assert variants['candidate'][key]['sha256'] == attempt[key]['sha256']
            assert pointer(variants['candidate'][key])['file'] == pointer(attempt[key])['file']
        assert variants['candidate']['sourceSha256'] == bootstrap['sourceSha256']
        assert pointer(variants['candidate']['driver']) == pointer(driver)
        role_modules = {}
        for entry in data['inputs']:
            actual = pointer(entry)
            if Path(actual['file']).suffix == '.json':
                document = read(actual['file'])
                if not isinstance(document, dict) or document.get('kind') != 'bend-program-bundle':
                    continue
                assert document['complete'] is True and document['schemaVersion'] == 1
                assert document['catalogSha256'] == keep(a.catalog)['sha256']
                assert document['upstreamCommit'] == catalog['upstreamCommit']
                bundle_cases = {row['id']: row for row in document['cases']}
                assert len(bundle_cases) == len(document['cases'])
                for role, metadata in document['roles'].items():
                    assert role in variants and metadata.get('compiler') == variants[role], 'Bundle compiler differs'
                    for name in plan['selectedIds']:
                        point = bundle_cases[name]
                        assert point['sourceSha256'] == by_id[name]['source']['sha256']
                        assert point['point'] == by_id[name]['point']
                        module = point['modules'][role]
                        compact = dict(sha256=module['sha256'], bytes=module['bytes'])
                        key = (name, role)
                        assert key not in role_modules or role_modules[key] == compact, 'Conflicting bundle module'
                        role_modules[key] = compact
        assert set(role_modules) == {(name, role) for name in plan['selectedIds'] for role in plan['roles']}, 'Missing source/point/role bundle binding'
        assert any(entry['sha256'] == keep(a.catalog)['sha256'] for entry in data['inputs'])
        group = dict(confirmation=confirmation, report=keep(file), protocol=plan['protocol'], budgetSeconds=plan['budgetSeconds'],
            wallSeconds=data['wallSeconds'], ids=plan['selectedIds'], points=len(data['cases']),
            samples=sum(len(row['samples']) for row in data['cases']))
        assert group['ids'] == [row['id'] for row in data['cases']]
        assert len(group['ids']) == len(set(group['ids']))
        assert data['selectedCases'] == data['measuredCases'] == len(group['ids'])
        groups.append(group)
        for case in data['cases']:
            name = case['id']
            assert name in by_id, 'Unknown point: '+name
            if confirmation:
                assert name in seen, 'Confirmation has no primary observation: '+name
            else:
                assert name not in seen, 'Repeated primary point; use --confirmation-report: '+name
                seen.add(name)
            expected = by_id[name]
            assert case['point'] == expected['point']
            recomputed = summarize(case['samples'], plan['roles'], case['rounds'])
            assert recomputed == case['summary'] and recomputed['complete'], name
            modules = {}
            assert len(case['samples']) == case['rounds'] * len(plan['roles'])
            for sample in case['samples']:
                result = sample['result']
                assert sample['process']['complete'] and sample['process']['returncode'] == 0
                assert sample['complete'] and result['complete'] and result['pass']
                module = pointer(result['module'])
                role = sample['role']
                compact = dict(sha256=module['sha256'], bytes=module['bytes'])
                assert role not in modules or modules[role] == compact, 'Module changed within point'
                modules[role] = compact
                assert compact == role_modules[(name, role)], 'Sample not tied to checked point bundle'
                for key in ['args', 'expected', 'exportName']:
                    assert result['config'][key] == expected['point'][key]
                if node_version is None:
                    node_version = result['node']
                assert result['node'] == node_version == attempt['node']['version'], 'Different Node versions across samples'
                assert math.isfinite(result['msPerCall']) and result['msPerCall'] > 0
            stats, ratios = recomputed['stats'], recomputed['ratios']
            base, candidate = stats['baseline'], stats['candidate']
            relation = ('candidate-faster-disjoint' if candidate['maximumMs'] < base['minimumMs'] else
                        'candidate-slower-disjoint' if candidate['minimumMs'] > base['maximumMs'] else 'overlap')
            if confirmation:
                assert modules == primary_modules[name], 'Confirmation modules differ: '+name
            else:
                primary_modules[name] = modules
            paired = []
            for index in recomputed['balancedRounds']:
                pair = {sample['role']: sample['result']['msPerCall'] for sample in case['samples'] if sample['round'] == index}
                paired.append(dict(round=index, baselineMs=pair['baseline'], candidateMs=pair['candidate'],
                    typescriptMs=pair['typescript'], baselineOverCandidate=pair['baseline']/pair['candidate'],
                    candidateOverTypescript=pair['candidate']/pair['typescript']))
            wins = sum(row['candidateMs'] < row['baselineMs'] for row in paired)
            ties = sum(row['candidateMs'] == row['baselineMs'] for row in paired)
            drift = {role: dict(values=stats[role]['halfDriftPercent'],
                minimum=min((x for x in stats[role]['halfDriftPercent'] if x is not None), default=None),
                maximum=max((x for x in stats[role]['halfDriftPercent'] if x is not None), default=None)) for role in plan['roles']}
            (confirmations if confirmation else rows).append(dict(id=name, confirmation=confirmation,
                modules=modules, moduleChanged=modules['candidate']['sha256'] != modules['baseline']['sha256'],
                moduleBytesDelta=modules['candidate']['bytes']-modules['baseline']['bytes'],
                paired=paired, pairedCandidateWins=wins, pairedTies=ties, pairedCandidateLosses=len(paired)-wins-ties,
                halfDriftPercent=drift, partition=expected.get('partition', 'historical'),
                source=expected['source'], point=expected['point'], report=keep(file),
                rounds=case['rounds'], stats=stats, ratios=ratios,
                candidateChangePercent=100*(candidate['medianMs']/base['medianMs']-1),
                observedRangeRelation=relation))
    missing = [row['id'] for row in catalog['cases'] if row['id'] not in seen]
    if a.require_full:
        assert not missing, ('Missing frozen points', missing)
    for row in inputs.values():
        assert identity(row['file']) == row, row['file']
    order = {row['id']: n for n, row in enumerate(catalog['cases'])}
    rows.sort(key=lambda row: order[row['id']])
    report = dict(kind='phase39-final-execution-summary', derivationParent=parent, complete=True, full=not missing, nodePath=node_path, nodeVersion=node_version,
        scope='Recomputed per-point same-run ratios only. No average application-speed claim, no cross-protocol sample pooling, no compilation time or profiler overhead in these ratios.',
        attempt=keep(attempt_file), catalog=keep(a.catalog), compilerIdentities=compilers,
        observedPoints=len(rows), confirmationPoints=len(confirmations), confirmations=confirmations, missing=missing, independentRunGroups=groups,
        catalogPoints=45, catalogSourceFiles=len({row['source']['path'] for row in catalog['cases']}),
        samples=sum(group['samples'] for group in groups),
        primarySamples=sum(group['samples'] for group in groups if not group['confirmation']),
        confirmationSamples=sum(group['samples'] for group in groups if group['confirmation']),
        separateRunWallSecondsSum=sum(group['wallSeconds'] for group in groups),
        rows=rows, inputs=list(inputs.values()))
    report['pass'] = True
    out = a.out.resolve()
    out.mkdir(parents=True, exist_ok=False)
    (out/'report.json').write_text(json.dumps(report, indent=2)+'\n')
    lines = ['# Expanded generated-program results', '',
        f"{len(rows)}/45 frozen points; {report['samples']} samples across {len(groups)} separate paired runs.", '',
        'Execution includes exact output/checksum work. Source acquisition, compilation and profiling are separate. '
        'Ratios use the same-run TypeScript and installed Phase37 observations for each point. '
        'Ranges describe observed samples, not confidence intervals. No ratio average is reported.', '',
        '| Point | Phase37 ms [min–max] | Candidate ms [min–max] | TS ms [min–max] | Gain | Candidate / TS | Paired wins | Bytes Δ | Range relation |',
        '|---|---:|---:|---:|---:|---:|---:|---:|---|']
    for row in rows:
        values = ' | '.join(f"{row['stats'][role]['medianMs']:.6g} [{row['stats'][role]['minimumMs']:.6g}–{row['stats'][role]['maximumMs']:.6g}]" for role in ['baseline','candidate','typescript'])
        lines.append(f"| {row['id']} | {values} | {row['ratios']['baseline/candidate']:.3f}× | {row['ratios']['candidate/typescript']:.3f}× | {row['pairedCandidateWins']}/{row['rounds']} | {row['moduleBytesDelta']:+d} | {row['observedRangeRelation']} |")
    if confirmations:
        lines += ['', '## Explicit confirmations (not pooled)', '',
            '| Point | Report | Gain | Candidate / TS | Paired wins | Candidate change | Range relation |',
            '|---|---|---:|---:|---:|---:|---|']
        for row in confirmations:
            lines.append(f"| {row['id']} | `{Path(row['report']['file']).parent.name}` | {row['ratios']['baseline/candidate']:.3f}× | {row['ratios']['candidate/typescript']:.3f}× | {row['pairedCandidateWins']}/{row['rounds']} | {row['candidateChangePercent']:+.2f}% | {row['observedRangeRelation']} |")
    lines += ['', '## Half-run drift (all observed samples)', '',
        '| Point | Role | Drift percentages |', '|---|---|---|']
    for row in rows + confirmations:
        label = row['id'] + (' (confirmation: '+Path(row['report']['file']).parent.name+')' if row['confirmation'] else '')
        for role in ['baseline','candidate','typescript']:
            values = ', '.join('missing' if value is None else f'{value:+.2f}' for value in row['stats'][role]['halfDriftPercent'])
            lines.append(f'| {label} | {role} | {values} |')
    lines += ['', '## Protocols and uncertainty', '']
    for group in groups:
        p = group['protocol']
        lines.append(f"- `{group['report']['file']}`: {group['points']} points / {group['samples']} samples; "
            f"{group['wallSeconds']:.3f}s process wall; {p['rounds']} requested rounds, "
            f"{p['warmupMs']}ms warmup, {p['targetMs']}ms sample target. The historical ray case retains its special maximum-three-round policy.")
    lines += ['', 'Per-role ranges and every half-drift observation are retained in report.json. '
        'Inspect those before describing a gain as stable. The sum of separate run wall times is a workflow cost, '
        'not a runtime denominator or a promise that the entire catalog fits one preset. '
        'Paired wins compare each balanced round; they are descriptive counts, not a significance test. '
        'Byte deltas are per-point module sizes; shared source modules must not be summed as separate code.', '']
    if missing:
        lines += ['Unmeasured here: '+', '.join(missing)+'.', '']
    (out/'report.md').write_text('\n'.join(lines))
    print(json.dumps(dict(complete=True, full=not missing, points=len(rows), samples=report['samples'], out=str(out))))


if __name__ == '__main__':
    main()
