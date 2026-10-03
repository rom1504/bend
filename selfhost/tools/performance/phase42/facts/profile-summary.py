#!/usr/bin/env python3
"""Summarize sampled compiler analysis ancestry, without adding overlapping shares."""
import argparse
import collections
import json
from pathlib import Path

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('profile', type=Path)
p.add_argument('out', type=Path)
a = p.parse_args()
profile = json.loads(a.profile.read_text())
nodes = {n['id']: n for n in profile['nodes']}
parents = {child: n['id'] for n in profile['nodes'] for child in n.get('children', [])}
samples = profile.get('samples', [])
deltas = profile.get('timeDeltas', [1] * len(samples))
assert len(samples) == len(deltas)
targets = ['j_component_plan', 'j_component_admit', 'j_component_select',
           'j_component_wrapper_calls', 'j_component_named', 'j_component_declaration',
           'j_component_refs', 'j_component_prefix', 'j_component_backedges',
           'j_pure_graph', 'j_pure_prefix', 'j_pure_expr', 'j_pure_type_check', 'wnf']
self_us = collections.Counter()
inclusive_us = collections.Counter()
total = sum(deltas)
for sample, delta in zip(samples, deltas):
    frame = nodes[sample]['callFrame']['functionName']
    self_us[frame] += delta
    seen = set()
    current = sample
    while current in nodes:
        name = nodes[current]['callFrame']['functionName'].strip('$')
        if name in targets:
            seen.add(name)
        current = parents.get(current)
    for name in seen:
        inclusive_us[name] += delta
result = dict(kind='phase42-facts-sampled-cpu-summary', samples=len(samples),
              sampledMicroseconds=total, scope='Whole worker capture; inclusive ancestry overlaps. Native trampoline attribution can omit parents. No exact call counts or saved-time estimate.',
              analysis=[dict(name=n, inclusiveMicroseconds=inclusive_us[n], inclusivePercent=100 * inclusive_us[n] / total if total else 0) for n in targets],
              largestSelf=[dict(name=n, sampledMicroseconds=t, percent=100 * t / total if total else 0) for n, t in self_us.most_common(30)])
assert not a.out.exists(), 'Preserve every summary'
a.out.write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps(result, indent=2))
