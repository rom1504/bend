#!/usr/bin/env python3
"""Compact verified source-median summary of any Phase66 clean campaign."""
import argparse
import hashlib
import json
import math
import statistics
from pathlib import Path


def pin(value):
    file = Path(value['file'] if isinstance(value, dict) else value).resolve(strict=True)
    item = dict(file=str(file), sha256=hashlib.sha256(file.read_bytes()).hexdigest())
    if isinstance(value, dict):
        assert item['sha256'] == value['sha256'], str(file)
    return item


p = argparse.ArgumentParser(description=__doc__)
p.add_argument('report', type=Path)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()
assert not a.out.exists()
r = json.loads(a.report.read_text())
assert r['complete'] and r['pass'] and not r['failures'] and r['mode'] == 'clean'
config = json.loads(Path(pin(r['config'])['file']).read_text())
assert not config['prepareOnly'] and config['warmRequests'] == 0
expected = {(case['id'], role, sample) for case in config['cases'] for role in config['roles'] for sample in range(config['rounds'])}
seen = set()
groups = {}
images = {}
for row in r['rows']:
    key = row['case'], row['role'], row['sample']
    assert key in expected and key not in seen
    seen.add(key)
    w = row['observation']
    assert json.loads(Path(pin(row['result'])['file']).read_text()) == w
    assert row['success'] and row['execution']['returncode'] == 0
    assert w['complete'] and w['pass'] and w['cleanTiming'] and not w['warmRequests']
    for field in ['source', 'output', 'expected']:
        pin(w[field])
    assert Path(w['output']['file']).read_bytes() == Path(w['expected']['file']).read_bytes()
    groups.setdefault(row['case'], {}).setdefault(row['role'], []).append(w)
    image = w.get('image')
    assert row['role'] not in images or images[row['role']] == image
    images[row['role']] = image
assert seen == expected and len(seen) == r['successfulWorkers'] == r['expectedWorkers']
metrics = ['firstRequestMs', 'hostImportMs', 'apiLoadMs', 'importApiAndFirstMs']
sources = []
ratios = {}
for case, roles in groups.items():
    values = {role: {m: dict(median=statistics.median(w[m] for w in workers),
        samples=[w[m] for w in workers]) for m in metrics} for role, workers in roles.items()}
    relative = {}
    for numerator, denominator in [(left, right) for left in config['roles'] for right in config['roles'] if left != right]:
        if numerator not in values or denominator not in values:
            continue
        label = numerator + '/' + denominator
        relative[label] = {m: values[numerator][m]['median'] / values[denominator][m]['median']
            for m in ['firstRequestMs', 'importApiAndFirstMs']}
        for m, value in relative[label].items():
            ratios.setdefault(label, {}).setdefault(m, []).append(value)
    sources.append(dict(case=case, roles=values, ratios=relative))
aggregate = {pair: {metric: dict(geometricMean=math.exp(statistics.mean(map(math.log, values))),
    minimum=min(values), maximum=max(values), belowOne=sum(v < 1 for v in values), sources=len(values))
    for metric, values in metric_values.items()} for pair, metric_values in ratios.items()}
result = dict(kind='phase66-clean-latency-summary', complete=True, **{'pass': True},
    dataOnly=True, targetExecuted=False, producer=pin(__file__), report=pin(a.report),
    config=pin(r['config']), method=r['methodDerivation'], successfulWorkers=len(seen),
    exactRawOutputs=len(seen), sourceCount=len(sources), rounds=config['rounds'], roles=config['roles'],
    images=images, aggregate=aggregate, sources=sources, wallSeconds=r['wallSeconds'],
    peakTreeRssBytes=max(row['execution']['peakTreeRssBytes'] for row in r['rows']),
    scope='Equal-source geometric mean of within-source median ratios; every sample uses a fresh process '
          'with prepared persistent cache. Compilation excludes imports; combined adds actual host/API imports. '
          'Full raw emitted modules match each role-qualified oracle, not necessarily the other role. '
          'This verifies compilation outputs, not fresh generated-program runtime or complete conformance.')
a.out.parent.mkdir(parents=True, exist_ok=True)
a.out.write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps(dict(output=pin(a.out), workers=len(seen), aggregate=aggregate)))
