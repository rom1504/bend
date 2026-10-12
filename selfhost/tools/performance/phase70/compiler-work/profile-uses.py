#!/usr/bin/env python3
"""Attribute already saved V8 samples to occurrence collection and insertion."""
import argparse
import hashlib
import json
import re
from collections import Counter
from pathlib import Path


def pin(path):
    data = path.read_bytes()
    return data, dict(file=str(path.resolve()),
                     sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))


def summarize(path, expected, job):
    data, identity = pin(path)
    assert identity['sha256'] == expected['sha256']
    assert identity['bytes'] == expected['bytes']
    profile = json.loads(data)
    nodes = {row['id']: row for row in profile['nodes']}
    parents = {child: row['id'] for row in nodes.values()
               for child in row.get('children', [])}
    names = {}
    for node, row in nodes.items():
        raw = row['callFrame']['functionName']
        name = (re.sub(r'_(\d+)_', lambda m: chr(int(m[1])), raw[4:])
                if raw.startswith('$jd$') else raw.strip('$'))
        names[node] = name.removesuffix('$scc')
    collector = {'nc_uses', 'nc_uses_term', 'nc_uses_list'}
    total = index_us = 0
    costs, callers = Counter(), Counter()
    assert len(profile['samples']) == len(profile['timeDeltas'])
    for node, delta in zip(profile['samples'], profile['timeDeltas']):
        stack = []
        while node in nodes:
            stack.append(names[node])
            node = parents.get(node)
        positions = [i for i, name in enumerate(stack) if name in collector]
        if not positions:
            continue
        total += delta
        index_names = {name for name in stack[:max(positions)] if name.startswith('index_')}
        if index_names:
            index_us += delta
        for name in index_names:
            costs[name] += delta
        outer = [name for name in stack[max(positions) + 1:]
                 if name.startswith(('nc_', 'nf_', 'nd_', 'nq_'))]
        callers[' > '.join(outer[:4])] += delta
    return dict(job=job, profile=identity, collectorMs=total / 1000,
                indexUnderCollectorMs=index_us / 1000,
                indexFunctionMs={key: val / 1000 for key, val in costs.most_common()},
                nearestCallerPathsMs={key: val / 1000 for key, val in callers.most_common()})


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--summary', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    assert not args.out.exists()
    data, summary_pin = pin(args.summary)
    summary = json.loads(data)
    assert summary['complete'] and summary['dataOnly']
    inputs = {row['file']: row for row in summary['inputs']}
    rows = []
    for row in summary['profiles']:
        path = Path(row['report']['file']).parent / 'request.cpuprofile'
        rows.append(summarize(path, inputs[str(path)], row['job']['name']))
    receipt = dict(kind='phase70-occurrence-insertion-profile', dataOnly=True,
        targetExecuted=False, producer=pin(Path(__file__))[1], summary=summary_pin,
        scope=('Sampled stack unions, not calls or clean clocks. Per-function '
               'index rows overlap. Collector excludes membership-query-only '
               'samples; missing/trampolined frames can hide attribution.'), rows=rows)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    with args.out.open('x') as stream:
        json.dump(receipt, stream, indent=2)
        stream.write('\n')


if __name__ == '__main__':
    main()
