#!/usr/bin/env python3
"""Attribute a V8 sample trace by elapsed windows, weighted by actual timeDeltas."""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('profile', type=Path)
p.add_argument('out', type=Path)
p.add_argument('--windows', default='0:15,15:30,30:45,45:60')
a = p.parse_args()
data = a.profile.read_bytes()
profile = json.loads(data)
nodes = {node['id']: node for node in profile['nodes']}
parents = {}
for node in nodes.values():
    for child in node.get('children', []):
        assert child in nodes and child not in parents
        parents[child] = node['id']
assert len(profile['samples']) == len(profile['timeDeltas'])
windows = []
for text in a.windows.split(','):
    start, stop = map(float, text.split(':'))
    assert 0 <= start < stop
    windows.append(dict(window=[start, stop], sampledUs=0, leaves=Counter(), inclusive=Counter()))
names = {key: node['callFrame']['functionName'] for key, node in nodes.items()}
chains = {}
for identifier in set(profile['samples']):
    current, seen, chain = identifier, set(), set()
    while current is not None:
        assert current not in seen
        seen.add(current)
        chain.add(names[current])
        current = parents.get(current)
    chains[identifier] = chain
elapsed = 0
raw_elapsed = 0
negative_deltas = []
for identifier, delta in zip(profile['samples'], profile['timeDeltas']):
    assert identifier in nodes
    if delta < 0:
        negative_deltas.append(delta)
    raw_elapsed += delta
    end = max(elapsed, raw_elapsed)
    for window in windows:
        start, stop = window['window']
        weight = max(0, min(end, stop * 1e6) - max(elapsed, start * 1e6))
        if not weight:
            continue
        window['sampledUs'] += weight
        window['leaves'][names[identifier]] += weight
        for name in chains[identifier]:
            window['inclusive'][name] += weight
    elapsed = end
for window in windows:
    total = window.pop('sampledUs')
    window['sampledSeconds'] = total / 1e6
    for key in ['leaves', 'inclusive']:
        window[key] = [dict(function=name, seconds=value / 1e6, percent=round(100 * value / total, 3))
                       for name, value in window[key].most_common(20)] if total else []
result = dict(kind='phase90-v8-window-attribution', complete=True,
    profile=dict(file=str(a.profile.resolve()), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data)),
    method=dict(file=str(Path(__file__).resolve()), sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest()),
    samples=len(profile['samples']), nodes=len(nodes), sampledSeconds=elapsed / 1e6,
    durationSeconds=(profile['endTime'] - profile['startTime']) / 1e6, windows=windows,
    timestampCorrections=dict(negativeDeltas=len(negative_deltas), negativeMicroseconds=-sum(negative_deltas),
        method='Clamp cumulative sample timestamps monotonically; zero-duration backwards steps, no duplicate attribution of the recovered interval.'),
    scope='Sampling attribution, not pass clocks or compiler completion. Each delta is assigned to its sample; recursive names count once in inclusive totals. Truncated stacks can omit outer callers.')
with a.out.open('x') as stream:
    json.dump(result, stream, indent=2)
    stream.write('\n')
print(json.dumps(dict(complete=True, samples=result['samples'], windows=[dict(window=w['window'], top=w['leaves'][:5]) for w in windows])))
