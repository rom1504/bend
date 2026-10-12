#!/usr/bin/env python3
"""Data-only inclusive family unions over retained CPU samples; groups overlap."""
import argparse
import hashlib
import json
import re
from collections import defaultdict
from pathlib import Path


def pin(path, expected=None):
    path = Path(path).resolve(strict=True)
    data = path.read_bytes()
    value = dict(file=str(path), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))
    if expected:
        assert value['sha256'] == expected['sha256']
        assert 'bytes' not in expected or value['bytes'] == expected['bytes']
    return value


def semantic(name):
    if name.startswith('$jd$'):
        name = re.sub(r'_(\d+)_', lambda m: chr(int(m[1])), name[4:])
    else:
        name = name.strip('$')
    return name.removesuffix('$scc')


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--plan', type=Path, required=True)
    ap.add_argument('--out', type=Path, required=True)
    args = ap.parse_args()
    assert not args.out.exists()
    plan_pin = pin(args.plan)
    plan = json.loads(args.plan.read_text())
    groups = {'occurrenceMembership':['nc_uses'], 'productUseCounts':['nq_uses','nq_min_uses'],
        'template':['ne_template'], 'erasure':['nc_erase'], 'normalization':['norm_','wnf'], 'index':['index_']}
    rows = []
    for job in plan['jobs']:
        if not job['profile']:
            continue
        report_path = args.plan.parent/'runs'/job['name']/'report.json'
        report_pin = pin(report_path)
        report = json.loads(report_path.read_text())
        assert report['complete'] and report['pass'] and report['exactC'] and report['plan'] == plan_pin
        profile_pin = pin(report['profile']['file'], report['profile'])
        profile = json.loads(Path(profile_pin['file']).read_text())
        nodes = {n['id']:n for n in profile['nodes']}
        parent = {child:n['id'] for n in nodes.values() for child in n.get('children', [])}
        sums = defaultdict(int)
        assert len(profile['samples']) == len(profile['timeDeltas'])
        for id_, delta in zip(profile['samples'], profile['timeDeltas']):
            seen = set()
            while id_ in nodes:
                name = semantic(nodes[id_]['callFrame']['functionName'])
                for group, prefixes in groups.items():
                    if any(name.startswith(prefix) for prefix in prefixes):
                        seen.add(group)
                id_ = parent.get(id_)
            for group in seen:
                sums[group] += delta
        rows.append(dict(job=job, report=report_pin, profile=profile_pin,
            sampledMs=sum(profile['timeDeltas'])/1000,
            inclusiveFamilyUnionMs={group:sums[group]/1000 for group in groups}))
    result = dict(kind='phase70-profile-family-unions', plan=plan_pin, method=pin(__file__),
        targetExecuted=False, groups=groups, rows=rows,
        scope='Each sample counted at most once per family when any ancestor matches. Different families overlap and must not be added. Names decode descriptor escapes and trailing $scc. Samples are instrumented diagnostics, not clean timing or exact invocation counts.')
    with args.out.open('x') as stream:
        stream.write(json.dumps(result, indent=2)+'\n')
    print(json.dumps(dict(output=pin(args.out), rows=len(rows))))


if __name__ == '__main__':
    main()
