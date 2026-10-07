#!/usr/bin/env python3
"""Data-only clean-image ratios and later-request trajectories; no target launch."""
import argparse
import hashlib
import json
import math
import statistics
from pathlib import Path


def identity(value):
    file = Path(value['file'] if isinstance(value, dict) else value).resolve(strict=True)
    result = dict(file=str(file), sha256=hashlib.sha256(file.read_bytes()).hexdigest())
    if isinstance(value, dict):
        assert result['sha256'] == value['sha256'], str(file)
    return result


def read(value):
    return json.loads(Path(identity(value)['file']).read_text())


def stats(values):
    return dict(median=statistics.median(values), min=min(values), max=max(values), samples=values)


def geometric(values):
    return math.exp(sum(map(math.log, values)) / len(values))


p = argparse.ArgumentParser(description=__doc__)
p.add_argument('report', type=Path)
p.add_argument('out', type=Path)
a = p.parse_args()
assert not a.out.exists()
d = read(a.report)
assert d['complete'] is True and d['pass'] is True and not d['failures']
assert d['mode'] == 'clean'
c = read(d['config'])
roles, cases, rounds = c['roles'], c['cases'], c['rounds']
assert d['successfulWorkers'] == d['expectedWorkers'] == len(roles) * len(cases) * rounds
assert all(row['success'] for row in d['rows'])
metrics = ['firstRequestMs', 'importApiAndFirstMs', 'hostImportMs', 'apiLoadMs', 'maxRssKiB']
later = [f'laterRequest{i + 1}Ms' for i in range(c['warmRequests'])]
observations, images = {}, {}
for row in d['rows']:
    obs = read(row['result'])
    assert obs == row['observation'] and obs['complete'] and obs['pass'] and obs['cleanTiming']
    assert obs['role'] == row['role'] and obs['sample'] == row['sample']
    assert len(obs['warmRequests']) == c['warmRequests']
    assert obs['output']['sha256'] == obs['expected']['sha256']
    assert all(x['output']['sha256'] == obs['output']['sha256'] for x in obs['warmRequests'])
    if row['role'] != 'typescript':
        images.setdefault(row['role'], obs['image'])
        assert images[row['role']] == obs['image']
    values = {key: obs[key] for key in metrics}
    values.update({key: sample['requestMs'] for key, sample in zip(later, obs['warmRequests'])})
    observations[(row['case'], row['role'], row['sample'])] = values
if set(images) == {'b1', 'b2'}:
    for key in ['source', 'base', 'runtime', 'directRuntime', 'driver']:
        assert images['b1'][key]['sha256'] == images['b2'][key]['sha256'], key
    assert images['b1']['kind'] == 'checked' and images['b2']['kind'] == 'direct'
comparisons = [(x, y) for x, y in [('b2', 'b1'), ('b2', 'typescript'), ('b1', 'typescript')] if x in roles and y in roles]
rows = []
for case in cases:
    by_role = {role: {key: stats([observations[(case['id'], role, sample)][key]
        for sample in range(rounds)]) for key in metrics + later} for role in roles}
    ratios = {x + '/' + y: {key: by_role[x][key]['median'] / by_role[y][key]['median']
        for key in ['firstRequestMs', 'importApiAndFirstMs', *later]} for x, y in comparisons}
    trajectory = {role: {key + '/firstRequestMs': by_role[role][key]['median'] /
        by_role[role]['firstRequestMs']['median'] for key in later} for role in roles}
    rows.append(dict(case=case['id'], source=case['source'], roles=by_role,
        ratios=ratios, laterVersusFirst=trajectory))
result = dict(kind='phase62-generation-clean-summary', complete=True, **{'pass': True},
    producer=identity(__file__), report=identity(a.report), config=d['config'],
    roles=roles, rounds=rounds, warmRequests=c['warmRequests'], successfulWorkers=len(d['rows']),
    wallSeconds=d['wallSeconds'], images=images, cases=rows,
    geometricMeans={x + '/' + y: {key: geometric([row['ratios'][x + '/' + y][key] for row in rows])
        for key in ['firstRequestMs', 'importApiAndFirstMs', *later]} for x, y in comparisons},
    scope='Equal-source geometric mean of per-source medians. Each first request has its own process; '
          'later request indexes remain separate. Position balance depends on role count/rounds. '
          'Only selected sources; no significance, steady-state plateau or new program-runtime claim. '
          'B1 is equality-derived TS bootstrap; images include ABI/runtime differences.')
a.out.parent.mkdir(parents=True, exist_ok=True)
a.out.write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps(dict(summary=identity(a.out), geometricMeans=result['geometricMeans'])))
