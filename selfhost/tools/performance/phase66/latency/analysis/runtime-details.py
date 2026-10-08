#!/usr/bin/env python3
"""Expose point/source regressions from the completed selected performance join."""
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
        assert 'bytes' not in item or row['bytes'] == item['bytes'], file
    inputs[str(file)] = row
    return row


def read(value):
    return json.loads(Path(pin(value)['file']).read_text())


def gm(values):
    return math.exp(statistics.mean(map(math.log, values)))


def comparison(candidate, reference):
    return dict(ratio=candidate['medianMs'] / reference['medianMs'],
                disjointImprovement=max(candidate['samplesMs']) < min(reference['samplesMs']),
                disjointRegression=min(candidate['samplesMs']) > max(reference['samplesMs']))


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--joined', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    args = p.parse_args()
    assert not args.out.exists()
    joined = read(args.joined)
    assert joined['kind'] == 'phase66-selected-performance-summary'
    assert joined['complete'] and joined['pass'] and joined['dataOnly'] and not joined['targetExecuted']
    for value in joined['inputs']:
        pin(value)
    runtime = read(joined['execution']['summary'])
    assert runtime['complete'] and runtime['pass'] and runtime['points'] == 45 and runtime['samples'] == 669
    pin(runtime['producer'])
    for value in runtime['reports']:
        pin(value)
    points = {row['id']: row for row in read(ROOT / 'selfhost/tools/performance/phase37/catalog.json')['cases']}
    source_rows = read(ROOT / 'selfhost/tools/performance/phase60/catalog.json')['compileInputs']
    sources = {row['source']['sha256']: row['id'] for row in source_rows}
    assert len(points) == 45 and len(sources) == 23
    assert {row['id'] for row in runtime['cases']} == points.keys()
    rows, groups = [], {}
    for case in runtime['cases']:
        original = points[case['id']]
        source = sources[original['source']['sha256']]
        stats = case['stats']
        assert set(stats) == {'baseline', 'candidate', 'typescript'}
        role_rows = {}
        for role, value in stats.items():
            assert len(value['samplesMs']) == case['rounds']
            assert statistics.median(value['samplesMs']) == value['medianMs']
            role_rows[role] = dict(medianMs=value['medianMs'], minimumMs=min(value['samplesMs']),
                maximumMs=max(value['samplesMs']), medianFirstCallMs=statistics.median(value['firstCallMs']),
                medianImportMs=statistics.median(value['importMs']),
                maximumAbsoluteHalfDriftPercent=max(map(abs, value['halfDriftPercent'])))
        row = dict(id=case['id'], source=source, partition=original['partition'], family=original['family'],
            point=original['point'], rounds=case['rounds'], roles=role_rows,
            updatedVersusOld=comparison(stats['candidate'], stats['baseline']),
            updatedVersusHeadTs=comparison(stats['candidate'], stats['typescript']))
        rows.append(row)
        groups.setdefault(source, []).append(row)
    source_results = []
    for source, members in sorted(groups.items()):
        row = dict(source=source, pointIds=[member['id'] for member in members])
        for key in ['updatedVersusOld', 'updatedVersusHeadTs']:
            values = [member[key]['ratio'] for member in members]
            row[key] = dict(geometricMean=gm(values), minimum=min(values), maximum=max(values))
        source_results.append(row)
    assert len(source_results) == 23
    for key in ['updatedVersusOld', 'updatedVersusHeadTs']:
        assert math.isclose(gm([row[key]['ratio'] for row in rows]),
            joined['execution']['equalPoint'][key]['geometricMean'], rel_tol=1e-12)
        assert math.isclose(gm([row[key]['geometricMean'] for row in source_results]),
            joined['execution']['equalSource'][key]['geometricMean'], rel_tol=1e-12)
    result = dict(kind='phase66-runtime-point-and-source-details', complete=True, **{'pass': True},
        dataOnly=True, targetExecuted=False, producer=pin(__file__), joined=pin(args.joined),
        points=rows, sources=source_results, inputs=list(inputs.values()),
        scope='Same-campaign execution medians only; import and first call are separate. Range separation is descriptive, '
              'not a confidence interval. Source summaries geometrically average only that source\'s original points; '
              'zero-work canaries and held-out partitions remain explicit. No threshold removes observations.')
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(dict(output=pin(args.out), points=len(rows), sources=len(source_results))))


if __name__ == '__main__':
    main()
