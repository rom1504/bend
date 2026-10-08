#!/usr/bin/env python3
"""Data-only State09/future-image CPU census using the reviewed Phase62 reader."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[6]
METHOD = ROOT / 'selfhost/tools/performance/phase62/analysis/profiles-v2.py'
EXPECTED = '4fb715bddc5262f6c7b53d869840f46d225cd3eed2b9ae3b53cdb0ee00bb3679'


def identity(file):
    file = Path(file).resolve(strict=True)
    return dict(file=str(file), sha256=hashlib.sha256(file.read_bytes()).hexdigest())


def verify(pin):
    assert identity(pin['file']) == {k: pin[k] for k in ['file', 'sha256']}, pin


p = argparse.ArgumentParser(description=__doc__)
p.add_argument('report', type=Path)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()
assert not a.out.exists()
assert identity(METHOD)['sha256'] == EXPECTED
spec = importlib.util.spec_from_file_location('phase62_profile_analysis', METHOD)
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)
# Only extend exact named boundaries. Shared SCCs remain unassigned to a member.
m.GENERATED_BOUNDARIES.update({
    'f_prefix_complete_ready_seed': 'source-completion',
    'f_prefix_complete_ready_source': 'source-completion',
    'jd_plan_selected': 'plan-selection',
    'jd_plan_library': 'final-library',
    'jd_plan_program': 'final-program',
})
report = json.loads(a.report.read_text())
assert report['complete'] and report['pass'] and report['mode'] == 'cpu'
assert report['successfulWorkers'] == report['expectedWorkers']
verify(report['config'])
config = json.loads(Path(report['config']['file']).read_text())
assert config['rounds'] == 1 and config['warmRequests'] == 0
rows = []
for row in report['rows']:
    w = row['observation']
    verify(row['result'])
    assert json.loads(Path(row['result']['file']).read_text()) == w
    assert row['success'] and w['complete'] and w['pass'] and not w['cleanTiming']
    for key in ['source', 'output', 'expected']:
        verify(w[key])
    assert Path(w['output']['file']).read_bytes() == Path(w['expected']['file']).read_bytes()
    q = w['profile']
    verify(q['receipt'])
    assert json.loads(Path(q['receipt']['file']).read_text()) == {k: v for k, v in q.items() if k != 'receipt'}
    assert q['mode'] == 'cpu' and q['calls'] == 1 and q['diagnosticOnly']
    verify(q['raw'])
    raw = json.loads(Path(q['raw']['file']).read_text())
    image = w.get('image')
    api = Path(image['api']['file']).as_uri() if image else None
    driver = Path(image['driver']['file']).as_uri() if image else None
    views = {'counts': m.partition(raw, 'cpu', [1] * len(raw['samples']), api, driver, Path(config['upstream']))}
    if q['weightedStatus'] == 'admitted':
        weights = [max(0, x) for x in raw['timeDeltas']]
        assert sum(weights) == q['weightedAccounting']['admittedWeightedUs']
        views['microseconds'] = m.partition(raw, 'cpu', weights, api, driver, Path(config['upstream']))
    # Keep the compact partition/top leaves, not dozens of repeated unresolved stacks.
    for view in views.values():
        view.pop('unresolvedSelf', None)
    rows.append(dict(case=row['case'], role=row['role'], worker=row['result'], raw=q['raw'],
        image=image, weightedStatus=q['weightedStatus'], weightedAccounting=q['weightedAccounting'],
        views=views, warnings=q['warnings']))
result = dict(kind='phase65-cpu-ancestry-analysis', complete=True, **{'pass': True},
    dataOnly=True, targetExecuted=False, producer=identity(__file__), method=identity(METHOD),
    source=identity(a.report), rows=rows,
    scope='One instrumented first window per source/role, including host/API imports. '
          'Nearest exact named boundaries produce disjoint semantic stages; compiler-specific '
          'boundaries are not asserted equivalent across Bend and TypeScript. SCC dispatcher '
          'names never identify an individual member. Family ancestor unions overlap. '
          'CPU weights are admitted diagnostics, not clean times or directly removable excess.')
a.out.parent.mkdir(parents=True, exist_ok=True)
a.out.write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps(dict(output=identity(a.out), rows=[dict(case=r['case'], role=r['role'],
    totalUs=r['views'].get('microseconds', {}).get('total'),
    stages=r['views'].get('microseconds', r['views']['counts'])['exclusiveStages'],
    unions=r['views'].get('microseconds', r['views']['counts'])['inclusiveAncestorUnions']) for r in rows])))
