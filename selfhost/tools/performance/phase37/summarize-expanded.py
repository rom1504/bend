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
    ap.add_argument('--catalog', type=Path, default=HERE/'catalog.json')
    ap.add_argument('--report', type=Path, action='append', required=True)
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
    attempt_file = a.attempt/'attempt.json' if a.attempt.is_dir() else a.attempt
    attempt, catalog = read(attempt_file), read(a.catalog)
    assert attempt['checked'] and attempt['artifactKind'] == 'derived-b1'
    assert catalog['kind'] == 'bend-program-catalog' and len(catalog['cases']) == 45
    by_id = {row['id']: row for row in catalog['cases']}
    assert len(by_id) == 45
    groups, rows, seen = [], [], set()
    compilers = None
    for file in a.report:
        if file.is_dir():
            file = file/'report.json'
        data = read(file)
        assert data['kind'] == 'bend-program-execution-report'
        assert data['complete'] and data['pass'] and data['status'] == 'measured', file
        plan = data['plan']
        assert set(plan['roles']) == {'baseline', 'candidate', 'typescript'}
        assert plan['cpu'] == 3 and plan['heapMiB'] <= 1024 and plan['rssMiB'] <= 2048
        assert plan['availableMiB'] >= 2048
        variants = {name: value['compiler'] for name, value in plan['variants'].items()}
        assert set(variants) == {'baseline', 'candidate', 'typescript'}
        if compilers is None:
            compilers = variants
        else:
            assert variants == compilers, 'Different compiler identities across reports'
        assert variants['baseline']['api']['sha256'] == '93e55ad7ee456eebb5fa3dd9606c2cf262ea386c6f66bfd891ffe187d8f50a75'
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
        for entry in data['inputs']:
            pointer(entry)
        assert any(entry['sha256'] == keep(a.catalog)['sha256'] for entry in data['inputs'])
        group = dict(report=keep(file), protocol=plan['protocol'], budgetSeconds=plan['budgetSeconds'],
            wallSeconds=data['wallSeconds'], ids=plan['selectedIds'], points=len(data['cases']),
            samples=sum(len(row['samples']) for row in data['cases']))
        assert group['ids'] == [row['id'] for row in data['cases']]
        groups.append(group)
        for case in data['cases']:
            name = case['id']
            assert name in by_id and name not in seen, 'Unknown or repeated point: '+name
            seen.add(name)
            expected = by_id[name]
            assert case['point'] == expected['point']
            recomputed = summarize(case['samples'], plan['roles'], case['rounds'])
            assert recomputed == case['summary'] and recomputed['complete'], name
            for sample in case['samples']:
                result = sample['result']
                assert sample['process']['complete'] and sample['process']['returncode'] == 0
                assert sample['complete'] and result['complete'] and result['pass']
                pointer(result['module'])
                assert math.isfinite(result['msPerCall']) and result['msPerCall'] > 0
            stats, ratios = recomputed['stats'], recomputed['ratios']
            base, candidate = stats['baseline'], stats['candidate']
            relation = ('candidate-faster-disjoint' if candidate['maximumMs'] < base['minimumMs'] else
                        'candidate-slower-disjoint' if candidate['minimumMs'] > base['maximumMs'] else 'overlap')
            rows.append(dict(id=name, partition=expected.get('partition', 'historical'),
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
    report = dict(kind='phase37-expanded-execution-summary', complete=True, full=not missing,
        scope='Recomputed per-point same-run ratios only. No average application-speed claim, no cross-protocol sample pooling, no compilation time or profiler overhead in these ratios.',
        attempt=keep(attempt_file), catalog=keep(a.catalog), compilerIdentities=compilers,
        observedPoints=len(rows), missing=missing, independentRunGroups=groups,
        catalogPoints=45, catalogSourceFiles=len({row['source']['path'] for row in catalog['cases']}),
        samples=sum(group['samples'] for group in groups),
        separateRunWallSecondsSum=sum(group['wallSeconds'] for group in groups),
        rows=rows, inputs=list(inputs.values()))
    out = a.out.resolve()
    out.mkdir(parents=True, exist_ok=False)
    (out/'report.json').write_text(json.dumps(report, indent=2)+'\n')
    lines = ['# Expanded generated-program results', '',
        f"{len(rows)}/45 frozen points; {report['samples']} samples across {len(groups)} separate paired runs.", '',
        'Execution includes exact output/checksum work. Source acquisition, compilation and profiling are separate. '
        'Ratios use the same-run TypeScript and Phase36 observations for each point. '
        'Ranges describe observed samples, not confidence intervals. No ratio average is reported.', '',
        '| Point | Phase36 ms | Candidate ms | TS ms | Phase36 / candidate | Candidate / TS | Range relation |',
        '|---|---:|---:|---:|---:|---:|---|']
    for row in rows:
        medians = [row['stats'][role]['medianMs'] for role in ['baseline', 'candidate', 'typescript']]
        values = ' | '.join(f'{value:.6g}' for value in medians)
        lines.append(f"| {row['id']} | {values} | {row['ratios']['baseline/candidate']:.3f}× | {row['ratios']['candidate/typescript']:.3f}× | {row['observedRangeRelation']} |")
    lines += ['', '## Protocols and uncertainty', '']
    for group in groups:
        p = group['protocol']
        lines.append(f"- `{group['report']['file']}`: {group['points']} points / {group['samples']} samples; "
            f"{group['wallSeconds']:.3f}s process wall; {p['rounds']} requested rounds, "
            f"{p['warmupMs']}ms warmup, {p['targetMs']}ms sample target. The historical ray case retains its special maximum-three-round policy.")
    lines += ['', 'Per-role ranges and every half-drift observation are retained in report.json. '
        'Inspect those before describing a gain as stable. The sum of separate run wall times is a workflow cost, '
        'not a runtime denominator or a promise that the entire catalog fits one preset.', '']
    if missing:
        lines += ['Unmeasured here: '+', '.join(missing)+'.', '']
    (out/'report.md').write_text('\n'.join(lines))
    print(json.dumps(dict(complete=True, full=not missing, points=len(rows), samples=report['samples'], out=str(out))))


if __name__ == '__main__':
    main()
