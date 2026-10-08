#!/usr/bin/env python3
"""Data-only summary of exact ordinary-driver host-helper counterfactuals."""
import argparse, hashlib, json, math, statistics
from pathlib import Path


def pin(value):
    p = Path(value['file'] if isinstance(value, dict) else value).resolve(strict=True)
    actual = {'file': str(p), 'sha256': hashlib.sha256(p.read_bytes()).hexdigest()}
    if isinstance(value, dict):
        assert actual['sha256'] == value['sha256'], str(p)
    return actual


def read(value):
    return json.loads(Path(pin(value)['file']).read_text())


p = argparse.ArgumentParser(description=__doc__)
p.add_argument('report', type=Path)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()
assert not a.out.exists(), 'Never overwrite consumed summaries'
r = read(a.report)
assert r['kind'] == 'phase65-host-helper-counterfactual-results'
assert r['complete'] and r['pass'] and not r['failures']
assert r['diagnosticOnly'] and not r['productionQualified']
plan = read(r['plan'])
assert plan['complete'] and plan['pass'] and plan['diagnosticOnly'] and not plan['productionQualified']
roles = list(plan['roles'])
assert roles[0] == 'baseline' and len(roles) == 2
variant = roles[1]
for v in plan['inputs'] + plan['copiedOriginals']:
    pin(v)
for name, role in plan['roles'].items():
    for v in role['files']:
        pin(v)
    assert len(role['changes']) == (name != 'baseline')
    if name != 'baseline':
        assert role['changes'][0]['relative'] == 'tools/base-cache-graph.mjs'
    for key, value in role['image'].items():
        assert value['sha256'] == plan['roles']['baseline']['image'][key]['sha256']
metrics = ['firstRequestMs', 'hostImportMs', 'apiLoadMs', 'importApiAndFirstMs']
seen = set()
for row in r['rows']:
    assert row['success'] and row['execution']['complete'] and row['execution']['returncode'] == 0
    ob = read(row['result'])
    assert ob == row['observation'] and ob['complete'] and ob['pass']
    assert ob['plan'] == r['plan'] and ob['image'] == plan['roles'][row['role']]['image']
    key = (row['case'], row['role'], row['sample'])
    assert key not in seen
    seen.add(key)
    assert ob['case'] == row['case'] and ob['role'] == row['role']
    case = next(c for c in plan['cases'] if c['id'] == row['case'])
    pin(ob['emittedModule']); pin(ob['output']['reference'])
    assert ob['output']['reference'] == case['expected']
    assert ob['output']['sha256'] == case['expected']['sha256'] == ob['emittedModule']['sha256']
    assert abs(ob['importApiAndFirstMs'] - sum(ob[m] for m in metrics[:3])) < 1e-6
expected = {(c['id'], role, sample) for c in plan['cases'] for role in roles for sample in range(r['rounds'])}
assert seen == expected
sources = []
for case in plan['cases']:
    by_role = {}
    for role in roles:
        rows = sorted((x for x in r['rows'] if x['case'] == case['id'] and x['role'] == role), key=lambda x: x['sample'])
        by_role[role] = {m: {'samples': [x['observation'][m] for x in rows], 'median': statistics.median(x['observation'][m] for x in rows)} for m in metrics}
    ratios = {m: by_role[variant][m]['median'] / by_role['baseline'][m]['median'] for m in ['firstRequestMs', 'importApiAndFirstMs']}
    sources.append({'case': case['id'], 'roles': by_role, 'ratios': ratios})
aggregate = {}
for metric in ['firstRequestMs', 'importApiAndFirstMs']:
    values = [s['ratios'][metric] for s in sources]
    aggregate[metric] = {'geometricMean': math.exp(sum(map(math.log, values)) / len(values)), 'minimum': min(values), 'maximum': max(values), 'belowOne': sum(v < 1 for v in values), 'sources': len(values)}
result = {'kind': 'phase65-host-helper-summary', 'complete': True, 'pass': True, 'dataOnly': True, 'diagnosticOnly': True, 'productionQualified': False, 'producer': pin(__file__), 'report': pin(a.report), 'plan': r['plan'], 'originalImage': plan['originalImage'], 'helperChanges': plan['roles'][variant]['changes'], 'roles': roles, 'sourceCount': len(sources), 'rounds': r['rounds'], 'successfulWorkers': len(r['rows']), 'exactRawOutputs': len(r['rows']), 'sources': sources, 'aggregate': aggregate, 'wallSeconds': r['wallSeconds'], 'peakProcessRssBytes': max(row['observation']['maxRssKiB'] * 1024 for row in r['rows']), 'scope': 'Same genuine B2 image and ordinary driver with a helper-only diagnostic substitution in separate projects. Fresh processes with prepared cache; not production qualification, compiler rebuild, or OS-cold I/O. Equal-source geometric means of within-source median ratios; no TS role.'}
a.out.parent.mkdir(parents=True, exist_ok=True)
a.out.write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps({'output': pin(a.out), 'workers': len(r['rows']), 'aggregate': aggregate}))
