#!/usr/bin/env python3
"""Join independently verified full B1, B2 and generated-program measurements."""
import argparse
import hashlib
import json
import math
import statistics
from pathlib import Path

ROOT = Path(__file__).resolve().parents[6]
inputs = {}


def pin(value):
    item = value if isinstance(value, dict) else None
    file = Path(item.get('file', item.get('path')) if item else value).resolve(strict=True)
    data = file.read_bytes()
    row = dict(file=str(file), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))
    if item:
        assert row['sha256'] == item['sha256'], file
        if 'bytes' in item:
            assert row['bytes'] == item['bytes'], file
    inputs[str(file)] = row
    return row


def read(value):
    return json.loads(Path(pin(value)['file']).read_text())


def gm(values):
    return math.exp(statistics.mean(math.log(x) for x in values))


def ratios(values):
    return dict(geometricMean=gm(values), minimum=min(values), maximum=max(values),
                belowOne=sum(x < 1 for x in values), aboveOne=sum(x > 1 for x in values), count=len(values))


def main():
    p = argparse.ArgumentParser(description=__doc__)
    for name in ['b1', 'b2', 'runtime', 'out']:
        p.add_argument('--' + name, type=Path, required=True)
    args = p.parse_args()
    assert not args.out.exists()
    catalog = read(ROOT / 'selfhost/tools/performance/phase60/catalog.json')
    expected_sources = {row['id'] for row in catalog['compileInputs']}
    original = read(ROOT / 'selfhost/tools/performance/phase37/catalog.json')
    expected_points = {row['id']: row for row in original['cases']}
    assert len(expected_sources) == 23 and len(expected_points) == 45
    compilation = {}
    compile_images = {}
    for generation, file in [('b1', args.b1), ('b2', args.b2)]:
        d = read(file)
        assert d['complete'] and d['pass'] and d['successfulWorkers'] == d['exactRawOutputs'] == 207
        assert d['sourceCount'] == 23 and d['rounds'] == 3
        assert set(d['roles']) == {'baseline', 'candidate', 'typescript_head'}
        assert {row['case'] for row in d['sources']} == expected_sources
        for key in ['report', 'config', 'method', 'producer']:
            pin(d[key])
        expected_kind = 'checked' if generation == 'b1' else 'direct'
        for role in ['baseline', 'candidate']:
            image = d['images'][role]
            assert image['kind'] == expected_kind and image['strictExact'] and not image['diagnosticDerivation']
            for key in ['api', 'source', 'checkedGenerator', 'runtime', 'base', 'directRuntime', 'driver']:
                pin(image[key])
            if generation == 'b2':
                emission = read(image['emission'])
                assert emission['complete'] and emission['pass']
                assert pin(emission['module'])['sha256'] == image['api']['sha256']
        clocks = {}
        for clock in ['firstRequestMs', 'importApiAndFirstMs']:
            changes, parity, disjoint_better, disjoint_worse = [], [], [], []
            for row in d['sources']:
                values = {role: row['roles'][role][clock] for role in d['roles']}
                for role, value in values.items():
                    assert len(value['samples']) == 3 and statistics.median(value['samples']) == value['median']
                changes.append(values['candidate']['median'] / values['baseline']['median'])
                parity.append(values['candidate']['median'] / values['typescript_head']['median'])
                if max(values['candidate']['samples']) < min(values['baseline']['samples']):
                    disjoint_better.append(row['case'])
                if min(values['candidate']['samples']) > max(values['baseline']['samples']):
                    disjoint_worse.append(row['case'])
            for name, values in [('candidate/baseline', changes), ('candidate/typescript_head', parity)]:
                assert math.isclose(gm(values), d['aggregate'][name][clock]['geometricMean'], rel_tol=1e-12)
            clocks[clock] = dict(updatedVersusOld=ratios(changes), updatedVersusHeadTs=ratios(parity),
                disjointSampleImprovement=disjoint_better, disjointSampleRegression=disjoint_worse,
                scope='Observed sample-range separation, not a confidence interval or significance test.')
        compilation[generation] = dict(summary=pin(file), workers=207, sources=23, clocks=clocks,
            wallSeconds=d['wallSeconds'], peakTreeRssBytes=d['peakTreeRssBytes'])
        compile_images[generation] = d['images']
    for role in ['baseline', 'candidate']:
        first, second = compile_images['b1'][role], compile_images['b2'][role]
        for key in ['source', 'checkedGenerator', 'runtime', 'base', 'directRuntime', 'driver']:
            assert first[key]['sha256'] == second[key]['sha256']
        assert read(second['emission'])['generator']['api']['sha256'] == first['api']['sha256']
    runtime = read(args.runtime)
    assert runtime['complete'] and runtime['pass'] and runtime['points'] == 45 and runtime['samples'] == 669
    pin(runtime['producer'])
    assert {row['id'] for row in runtime['cases']} == expected_points.keys()
    plan_identity = None
    for row in runtime['reports']:
        report = read(row)
        assert report['complete'] and report['pass'] and report['status'] == 'measured'
        plan = report['plan']
        assert plan['budgetSeconds'] == 600
        assert plan['protocol'] == dict(defaultSet='full', rounds=5, warmupCalls=3, warmupMs=1000, calibrationMs=50, targetMs=300)
        current = {key: plan[key] for key in ['roles', 'protocol', 'cpu', 'node', 'variants', 'expensivePointPolicy']}
        assert plan_identity is None or current == plan_identity
        plan_identity = current
        for item in report['inputs']:
            pin(item)
    variants = plan_identity['variants']
    assert variants['baseline']['compiler']['api']['sha256'] == read(args.b1)['images']['baseline']['api']['sha256']
    assert variants['candidate']['compiler']['api']['sha256'] == read(args.b1)['images']['candidate']['api']['sha256']
    assert variants['typescript']['compiler']['upstreamCommit'] == '059266225b77c8ca256ac6b25ee5c21449bab151'
    point_values, source_values = {}, {}
    for row in runtime['cases']:
        assert row['rounds'] == (3 if row['id'] == 'raytrace' else 5)
        values = {role: stats['medianMs'] for role, stats in row['stats'].items()}
        for name, denominator in [('updatedVersusOld', 'baseline'), ('updatedVersusHeadTs', 'typescript')]:
            value = values['candidate'] / values[denominator]
            point_values.setdefault(name, []).append(value)
            source = expected_points[row['id']]['source']['sha256']
            source_values.setdefault(name, {}).setdefault(source, []).append(value)
    execution = dict(summary=pin(args.runtime), points=45, samples=669, sources=23,
        equalPoint={key: ratios(values) for key, values in point_values.items()},
        equalSource={key: ratios([gm(v) for v in values.values()]) for key, values in source_values.items()},
        wallSeconds=runtime['wallSeconds'], peakTreeRssBytes=runtime['peakTreeRssBytes'],
        scope='Runtime medians exclude compilation, import, first call and warmup. Equal-source first geometrically averages each source\'s points, then weights all23 sources equally. Neither weighting claims typical production performance; source/argument coverage remains finite.')
    assert all(len(values) == 23 for values in source_values.values())
    result = dict(kind='phase66-selected-performance-summary', complete=True, **{'pass': True},
        dataOnly=True, targetExecuted=False, producer=pin(__file__), compilation=compilation, execution=execution,
        scope='Three independently measured requested performance metrics. Conformance and source complexity are separate evidence. Old/new ratio always uses the same campaign; B1 and B2 campaigns are never pooled.', inputs=list(inputs.values()))
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(dict(output=pin(args.out), compilation=compilation, execution=execution)))


if __name__ == '__main__':
    main()
