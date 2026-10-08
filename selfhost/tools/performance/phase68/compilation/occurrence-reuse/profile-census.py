#!/usr/bin/env python3
"""Data-only stack unions; samples are not function invocation counts."""
import argparse
import hashlib
import json
import re
from collections import Counter
from pathlib import Path

ap = argparse.ArgumentParser(description=__doc__)
ap.add_argument('--plan', type=Path, required=True)
ap.add_argument('--out', type=Path, required=True)
args = ap.parse_args()
assert not args.out.exists()
inputs = {}


def pin(value):
    expected = value if isinstance(value, dict) else None
    file = Path(expected['file'] if expected else value).resolve(strict=True)
    data = file.read_bytes()
    p = dict(file=str(file), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))
    if expected:
        assert p['sha256'] == expected['sha256']
        assert 'bytes' not in expected or p['bytes'] == expected['bytes']
    inputs[str(file)] = p
    return p


def read(value):
    return json.loads(Path(pin(value)['file']).read_text())


def semantic(name):
    return (re.sub(r'_(\d+)_', lambda m: chr(int(m[1])), name[4:])
            if name.startswith('$jd$') else name.strip('$'))


method = pin(__file__)
plan_pin = pin(args.plan)
plan = read(args.plan)
attempt = read(plan['attempt'])
source = {}
for row in attempt['snapshot']['sources']:
    p = Path(row['frozen']['file'])
    if p.name in ('bridge.bend', 'flat.bend', 'text.bend') and '/back/native/' in str(p):
        source[p.name] = pin(row['frozen'])
groups = {'uses': {'nc_uses', 'nc_uses_term', 'nc_uses_list'},
          'lines': {'nt_lines', 'nt_lines_go'},
          'replace': {'nt_replace', 'nt_replace_go', 'nt_replace_step$scc'}}
observations = []
for job in plan['jobs']:
    if not job['profile']:
        continue
    report_file = args.plan.parent/'runs'/job['name']/'report.json'
    report = read(report_file)
    assert report['complete'] and report['pass'] and report['exactC']
    assert report['inputsUnchanged'] and report['plan'] == plan_pin
    guard = read(report_file.parent.with_name(report_file.parent.name+'-guard')/'process.json')
    assert guard['complete'] and guard['returncode'] == 0
    profile = read(report['profile'])
    nodes = {n['id']: n for n in profile['nodes']}
    parent = {c:n['id'] for n in profile['nodes'] for c in n.get('children', [])}
    totals, samples, callers = Counter(), Counter(), Counter()
    assert len(profile['samples']) == len(profile['timeDeltas'])
    for leaf, delta in zip(profile['samples'], profile['timeDeltas']):
        stack, current = [], leaf
        while current in nodes:
            stack.append(semantic(nodes[current]['callFrame']['functionName']))
            current = parent.get(current)
        for group, names in groups.items():
            positions = [i for i, n in enumerate(stack) if n in names]
            if positions:
                totals[group] += delta
                samples[group] += 1
                if group == 'uses':
                    caller = next((n for n in stack[max(positions)+1:]
                                   if n.startswith(('nc_', 'nf_', 'nd_', 'nq_'))), 'unresolved')
                    callers[caller] += delta
    observations.append(dict(job=job, report=pin(report_file), profile=pin(report['profile']),
        sampledMs={k:v/1000 for k,v in totals.items()}, sampleCounts=dict(samples),
        usesNearestOuterNativeCallerMs={k:v/1000 for k,v in callers.most_common()}))
assert len(observations) == 4
result = dict(kind='phase68-native-occurrence-and-text-stack-census', complete=True,
    dataOnly=True, targetExecuted=False, method=method, plan=plan_pin,
    source=source, groups={k:sorted(v) for k,v in groups.items()}, observations=observations,
    scope='Per-group inclusive sample union includes descendants and counts each sample once. Groups/callers are sampled attribution, not invocation counts or clean wall time. Missing/inlined frames can hide ownership. Actual helper controls separately observe invocation counts on finite constructed inputs.',
    inputs=list(inputs.values()))
result['pass'] = True
args.out.parent.mkdir(parents=True, exist_ok=True)
args.out.write_text(json.dumps(result, indent=2)+'\n')
print(json.dumps(pin(args.out)))
