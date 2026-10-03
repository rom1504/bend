#!/usr/bin/env python3
"""Select already audited execution rows by exact emitted-module identity; run no targets."""
import argparse
import json
import math
from pathlib import Path
import sys

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent / 'programs'))
from run import load_bundle, relative_path, verify, summarize
from prepare import observe_row
from support import identity, save

RAYS = {'raytrace', 'variation-ray-active-64-2440', 'variation-ray-active-256-2240'}


def main():
    p = argparse.ArgumentParser(description=__doc__)
    for name in ['old-summary', 'fresh-summary', 'candidate', 'baseline', 'attempt', 'catalog', 'out']:
        p.add_argument('--' + name, type=Path, required=True)
    a = p.parse_args()
    assert not a.out.exists(), 'Output must be new'
    inputs = []

    def keep(file, expected=None):
        row = verify(file, expected) if expected and 'bytes' in expected else identity(file)
        if expected:
            assert row['sha256'] == expected['sha256'], file
        inputs.append(row)
        return row

    def pointer(row):
        file = row.get('canonicalPath', row.get('file', row.get('path')))
        assert file and Path(file).is_absolute(), 'Absolute receipt pointer required'
        return keep(file, row)

    def read(file, expected=None):
        return json.loads(Path(keep(file, expected)['path']).read_text())

    keep(__file__)
    keep(HERE / 'summarize-execution.py')
    for name in ['run.py', 'support.py', 'prepare.py']:
        keep(HERE.parent / 'programs' / name)
    catalog = read(a.catalog)
    assert catalog['kind'] == 'bend-program-catalog' and len(catalog['cases']) == 45
    cases = {r['id']: r for r in catalog['cases']}
    assert len(cases) == 45
    catalog_sha = identity(a.catalog)['sha256']
    old, fresh = read(a.old_summary), read(a.fresh_summary)
    harnesses, protocols = [], []
    for summary in [old, fresh]:
        assert summary['kind'] == 'phase40-final-execution-summary'
        assert summary['complete'] is True and summary['pass'] is True
        assert summary['catalog']['sha256'] == catalog_sha
        for row in summary['inputs']:
            pointer(row)
        # The maintained summarizer must be among its consumed identities.
        assert any(r['sha256'] == identity(HERE / 'summarize-execution.py')['sha256']
                   for r in summary['inputs'])
        summary_rows = {r['id']: r for r in summary['rows']}
        assert len(summary_rows) == len(summary['rows'])
        observed_rows, point_protocols = set(), {}
        groups = []
        for group in summary['independentRunGroups']:
            assert not group['confirmation']
            raw = read(pointer(group['report'])['path'])
            assert raw['complete'] is True and raw['pass'] is True
            assert raw['plan']['protocol'] == group['protocol']
            assert set(raw['plan']['roles']) == {'baseline', 'candidate', 'typescript'}
            assert raw['plan']['selectedIds'] == group['ids'] == [r['id'] for r in raw['cases']]
            for case in raw['cases']:
                id = case['id']
                assert id not in observed_rows and id in summary_rows
                observed_rows.add(id)
                point_protocols[id] = group['protocol']
                row = summary_rows[id]
                assert pointer(row['report']) == pointer(group['report'])
                assert row['rounds'] == case['rounds'] and row['point'] == case['point'] == cases[id]['point']
                recomputed = summarize(case['samples'], raw['plan']['roles'], case['rounds'])
                assert recomputed['complete'] and recomputed == case['summary']
                assert row['stats'] == recomputed['stats'] and row['ratios'] == recomputed['ratios']
                assert len(case['samples']) == case['rounds'] * 3
                for sample in case['samples']:
                    result = sample['result']
                    assert sample['complete'] and sample['process']['complete'] and sample['process']['returncode'] == 0
                    assert result['complete'] and result['pass'] and result['node'] == summary['nodeVersion']
                    assert math.isfinite(result['msPerCall']) and result['msPerCall'] > 0
                    module = pointer(result['module'])
                    assert row['modules'][sample['role']] == {k: module[k] for k in ['sha256', 'bytes']}
                    assert all(result['config'][k] == case['point'][k] for k in ['args', 'expected', 'exportName'])
                paired = []
                for index in recomputed['balancedRounds']:
                    pair = {s['role']: s['result']['msPerCall'] for s in case['samples'] if s['round'] == index}
                    paired.append(dict(round=index, baselineMs=pair['baseline'], candidateMs=pair['candidate'],
                        typescriptMs=pair['typescript'], baselineOverCandidate=pair['baseline']/pair['candidate'],
                        candidateOverTypescript=pair['candidate']/pair['typescript']))
                wins = sum(r['candidateMs'] < r['baselineMs'] for r in paired)
                ties = sum(r['candidateMs'] == r['baselineMs'] for r in paired)
                assert row['paired'] == paired and row['pairedCandidateWins'] == wins
                assert row['pairedTies'] == ties and row['pairedCandidateLosses'] == len(paired)-wins-ties
                stats = recomputed['stats']
                drift = {role: dict(values=stats[role]['halfDriftPercent'],
                    minimum=min((x for x in stats[role]['halfDriftPercent'] if x is not None), default=None),
                    maximum=max((x for x in stats[role]['halfDriftPercent'] if x is not None), default=None))
                    for role in raw['plan']['roles']}
                base, candidate_stats = stats['baseline'], stats['candidate']
                relation = ('candidate-faster-disjoint' if candidate_stats['maximumMs'] < base['minimumMs'] else
                            'candidate-slower-disjoint' if candidate_stats['minimumMs'] > base['maximumMs'] else 'overlap')
                assert row['halfDriftPercent'] == drift and row['observedRangeRelation'] == relation
                assert row['candidateChangePercent'] == 100*(candidate_stats['medianMs']/base['medianMs']-1)
            harness = {}
            for row in raw['inputs']:
                raw_file = row.get('file', row.get('path'))
                name = Path(raw_file).name
                if name in ['run.py', 'support.py', 'execute.mjs'] or raw_file == summary['nodePath']:
                    keep(raw_file, row)
                    harness[name] = (row['sha256'], row['bytes'])
            assert set(harness) == {'run.py', 'support.py', 'execute.mjs', Path(summary['nodePath']).name}
            groups.append((harness, {k: raw['plan'][k]
                           for k in ['cpu', 'heapMiB', 'rssMiB', 'availableMiB', 'expensivePointPolicy']}))
        assert groups and all(g == groups[0] for g in groups)
        assert observed_rows == set(summary_rows), 'Summary rows differ from raw primary points'
        harnesses.append(groups[0])
        protocols.append(point_protocols)
    assert harnesses[0] == harnesses[1], 'Harness, Node binary or limits differ'
    assert all(protocols[0][id] == protocols[1][id] for id in RAYS), 'Replacement protocol differs'
    assert old['full'] is True and not old['confirmationPoints'] and not fresh['confirmationPoints']
    assert old['nodePath'] == fresh['nodePath'] and old['nodeVersion'] == fresh['nodeVersion']
    for role in ['baseline', 'typescript']:
        assert old['compilerIdentities'][role] == fresh['compilerIdentities'][role]
    old_rows = {r['id']: r for r in old['rows']}
    fresh_rows = {r['id']: r for r in fresh['rows']}
    assert len(old_rows) == len(old['rows']) == 45 and set(old_rows) == set(cases)
    assert len(fresh_rows) == len(fresh['rows']) == 3 and set(fresh_rows) == RAYS
    candidate = load_bundle(a.candidate, catalog, catalog_sha, catalog['cases'], ['candidate'], inputs)
    baseline = load_bundle(a.baseline, catalog, catalog_sha, catalog['cases'], ['baseline', 'typescript'], inputs)
    compiler = candidate['roles']['candidate']['compiler']
    assert compiler == fresh['compilerIdentities']['candidate']
    for role in ['baseline', 'typescript']:
        assert baseline['roles'][role]['compiler'] == fresh['compilerIdentities'][role]
    attempt_file = a.attempt / 'attempt.json' if a.attempt.is_dir() else a.attempt
    attempt = read(attempt_file)
    assert attempt['checked'] is True and attempt['artifactKind'] == 'derived-b1'
    assert pointer(fresh['attempt']) == keep(attempt_file)
    for key in ['api', 'runtime', 'base']:
        assert pointer(compiler[key]) == pointer(attempt[key])
    manifest = read(a.candidate)
    assert 'archive' not in manifest and 'prototype' not in manifest
    assert len(manifest['cases']) == 45 and {r['id'] for r in manifest['cases']} == set(cases)
    prep_file = relative_path(a.candidate.resolve().parent, manifest['preparation']['path'])
    prep = read(prep_file, manifest['preparation'])
    assert prep['complete'] is True and prep['kind'] == 'bend-program-preparation'
    assert pointer(prep['catalog']) == keep(a.catalog)
    assert pointer(prep['node']) == pointer(attempt['node'])
    emitted = {}
    for source in prep['sources']:
        assert source['process']['complete'] is True and source['process']['returncode'] == 0
        receipt = read(relative_path(a.candidate.resolve().parent, source['emission']['path']), source['emission'])
        assert receipt['kind'] == 'bend-program-checked-emission' and receipt['complete'] is True
        assert receipt['compiler'] == compiler and receipt['node'] == fresh['nodeVersion']
        assert receipt['observation']['checked'] and receipt['observation']['typeAccepted']
        assert receipt['observation']['status'] == 'ok'
        assert pointer(receipt['attempt']) == keep(attempt_file)
        assert pointer(receipt['catalog']) == keep(a.catalog)
        src, module = pointer(receipt['input']), pointer(receipt['output'])
        assert src == pointer(source['source']) and src['sha256'] not in emitted
        emitted[src['sha256']] = module
    assert set(emitted) == {c['source']['sha256'] for c in cases.values()}
    adapters = {}
    for adapter in prep['adapters']:
        assert adapter['kind'] == 'complete-generic-row-serialization'
        raw = keep(relative_path(a.candidate.resolve().parent, adapter['raw']['path']), adapter['raw'])
        adapted = keep(relative_path(a.candidate.resolve().parent, adapter['adapted']['path']), adapter['adapted'])
        assert observe_row(Path(raw['path']).read_text(), typescript=False).encode() == Path(adapted['path']).read_bytes()
        assert raw['sha256'] not in adapters or adapters[raw['sha256']] == adapted
        adapters[raw['sha256']] = adapted
    selected = []
    for id, case in cases.items():
        row = fresh_rows[id] if id in RAYS else old_rows[id]
        assert not row['confirmation'] and row['source'] == case['source'] and row['point'] == case['point']
        assert len(row['paired']) == row['rounds'] and row['rounds'] > 0
        for role in ['candidate', 'baseline', 'typescript']:
            entry = candidate['points'][id][role] if role == 'candidate' else baseline['points'][id][role]
            assert row['modules'][role] == {k: entry[k] for k in ['sha256', 'bytes']}, (id, role)
        assert row['moduleChanged'] == (row['modules']['candidate']['sha256'] != row['modules']['baseline']['sha256'])
        assert row['moduleBytesDelta'] == row['modules']['candidate']['bytes']-row['modules']['baseline']['bytes']
        assert row['partition'] == case.get('partition', 'historical')
        if id in RAYS:
            assert old_rows[id]['modules']['candidate'] != row['modules']['candidate'], id
        raw = emitted[case['source']['sha256']]
        emitted_variants = [raw] + ([adapters[raw['sha256']]] if raw['sha256'] in adapters else [])
        assert row['modules']['candidate'] in [{k: module[k] for k in ['sha256', 'bytes']}
                                             for module in emitted_variants], id
        selected.append(dict(row, selection='fresh-replacement' if id in RAYS else 'exact-byte-reuse',
                             measurementProtocol=protocols[1 if id in RAYS else 0][id],
                             measurementApi=(fresh if id in RAYS else old)['compilerIdentities']['candidate']['api']['sha256'],
                             selectedApi=compiler['api']['sha256']))
    report = dict(kind='phase40-execution-evidence-selection', complete=True, pass_=True,
                  scope='42 reused checked05 rotations and 3 fresh checked06 rotations; no pooled timing',
                  oldSummary=identity(a.old_summary), freshSummary=identity(a.fresh_summary),
                  selectedAttempt=identity(attempt_file), selectedApi=compiler['api']['sha256'],
                  nodeVersion=fresh['nodeVersion'], harness= harnesses[0], catalog=identity(a.catalog),
                  acceptedReusePoints=42, replacedPoints=sorted(RAYS), selectedPoints=45,
                  rejectedOldRows=[old_rows[id] for id in sorted(RAYS)], rows=selected, inputs=inputs)
    report['pass'] = report.pop('pass_')
    a.out.mkdir(parents=True)
    save(a.out / 'report.json', report)
    lines = ['# Selected execution evidence', '', report['scope'] + '.', '',
             'Measurement APIs remain explicit per row. Original rejected ray measurements remain in report.json.', '',
             '| Point | Evidence | Baseline / candidate | Candidate / TS |', '|---|---|---:|---:|']
    for row in selected:
        lines.append(f"| {row['id']} | {row['selection']} | {row['ratios']['baseline/candidate']:.3f} | {row['ratios']['candidate/typescript']:.3f} |")
    (a.out / 'report.md').write_text('\n'.join(lines) + '\n')


if __name__ == '__main__':
    main()
