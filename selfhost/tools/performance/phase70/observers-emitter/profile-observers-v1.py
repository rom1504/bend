#!/usr/bin/env python3
"""Reduce already completed profiles; no compiler or target is executed."""
import argparse
import hashlib
import json
import os
import re
from collections import defaultdict
from pathlib import Path


def pin(path):
    path = Path(path).resolve(strict=True)
    data = path.read_bytes()
    return data, dict(file=str(path), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))


def semantic(raw):
    if raw.startswith('$jd$'):
        raw = re.sub(r'_(\d+)_', lambda match: chr(int(match[1])), raw[4:])
    else:
        raw = raw.strip('$')
    return raw.removesuffix('$scc')


GROUPS = {
    'allObserver': ['no_', 'nol_', 'noa_'],
    'layout': ['nol_', 'no_schema'],
    'analysis': ['noa_'],
    'plan': ['no_observer_plan', 'no_plan_checked'],
    'route': ['no_route'],
    'candidateNames': ['no_candidate_names'],
    'entryIndex': ['no_entry_defs'],
    'collision': ['no_private_free', 'no_worker_taken'],
    'emitWorker': ['no_worker'],
    'emitAdapter': ['no_adapter'],
    'wrap': ['no_wrap'],
}


def summarize(profile, expected, job):
    data, identity = pin(profile)
    assert identity == expected
    raw = json.loads(data)
    nodes = {row['id']: row for row in raw['nodes']}
    parent = {child: row['id'] for row in nodes.values() for child in row.get('children', [])}
    names = {id_: semantic(row['callFrame']['functionName']) for id_, row in nodes.items()}
    sums = defaultdict(int)
    unions = defaultdict(int)
    counts = defaultdict(int)
    leaves = defaultdict(int)
    caches = {}
    assert len(raw['samples']) == len(raw['timeDeltas'])
    for leaf, delta in zip(raw['samples'], raw['timeDeltas']):
        if leaf not in caches:
            seen = set()
            node = leaf
            while node in nodes:
                name = names[node]
                if name.startswith(('no_', 'nol_', 'noa_')):
                    seen.add(name)
                node = parent.get(node)
            caches[leaf] = seen
        seen = caches[leaf]
        for name in seen:
            sums[name] += delta
        if names[leaf].startswith(('no_', 'nol_', 'noa_')):
            leaves[names[leaf]] += delta
        for group, prefixes in GROUPS.items():
            if any(name.startswith(tuple(prefixes)) for name in seen):
                unions[group] += delta
                counts[group] += 1
    return dict(job=job, profile=identity, sampledMs=sum(raw['timeDeltas'])/1000,
        samples=len(raw['samples']),
        inclusiveFamilyUnionMs={group: unions[group]/1000 for group in GROUPS},
        inclusiveFamilySamples={group: counts[group] for group in GROUPS},
        inclusiveFunctionUnionMs={name: value/1000 for name, value in sorted(sums.items(), key=lambda x:-x[1])},
        exclusiveLeafMs={name:value/1000 for name,value in sorted(leaves.items(),key=lambda x:-x[1])})


def main():
    assert os.sched_getaffinity(0) == {0}, 'Data reduction must use CPU0'
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--summary', type=Path, required=True)
    ap.add_argument('--out', type=Path, required=True)
    args = ap.parse_args()
    assert not args.out.exists()
    data, summary_pin = pin(args.summary)
    summary = json.loads(data)
    assert summary['complete'] and summary['dataOnly'] and not summary['targetExecuted']
    inputs = {row['file']: row for row in summary['inputs']}
    rows=[]
    for row in summary['profiles']:
        path = Path(row['report']['file']).parent/'request.cpuprofile'
        rows.append(summarize(path, inputs[str(path)], row['job']['name']))
    result = dict(kind='phase70-observer-profile-unions', dataOnly=True, targetExecuted=False,
        summary=summary_pin, producer=pin(__file__)[1], groups=GROUPS, rows=rows,
        scope='Named-frame inclusive sampled unions. A sample counts once per family; families and functions overlap and must not be added. Profiles are instrumented diagnostics, not clean timing, invocation counts, or a counterfactual estimate. Inlined or anonymous/trampoline frames can undercount attribution.')
    with args.out.open('x') as stream:
        json.dump(result,stream,indent=2)
        stream.write('\n')
    for row in rows:
        print(json.dumps(dict(job=row['job'], sampledMs=row['sampledMs'], families=row['inclusiveFamilyUnionMs'], top=list(row['inclusiveFunctionUnionMs'].items())[:15])))


if __name__=='__main__':
    main()
