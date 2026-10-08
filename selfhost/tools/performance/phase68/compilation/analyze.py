#!/usr/bin/env python3
"""Data-only native-request timing and V8 owner summary. Keep unknown samples."""
import argparse
import hashlib
import json
import re
import statistics
from collections import defaultdict
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
inputs = {}


def pin(value):
    expected = value if isinstance(value, dict) else None
    p = Path(expected['file'] if expected else value).resolve(strict=True)
    data = p.read_bytes()
    result = dict(file=str(p), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))
    if expected:
        assert result['sha256'] == expected['sha256']
        assert 'bytes' not in expected or result['bytes'] == expected['bytes']
    inputs[str(p)] = result
    return result


def read(p):
    return json.loads(Path(pin(p)['file']).read_text())


def semantic_name(name):
    if name.startswith('$jd$'):
        name = re.sub(r'_(\d+)_', lambda m:chr(int(m[1])), name[4:])
    else:
        name = name.strip('$')
    return name


def profile_summary(profile, owners):
    nodes = {n['id']: n for n in profile['nodes']}
    parent = {child:n['id'] for n in nodes.values() for child in n.get('children',[])}
    self_us, inclusive_us, owner_us = defaultdict(int), defaultdict(int), defaultdict(int)
    assert len(profile['samples']) == len(profile['timeDeltas'])
    for id_, delta in zip(profile['samples'], profile['timeDeltas']):
        raw = nodes[id_]['callFrame']['functionName']
        self_us[raw] += delta
        seen, owner = set(), None
        while id_ in nodes:
            name = semantic_name(nodes[id_]['callFrame']['functionName'])
            if name not in seen:
                inclusive_us[name] += delta;seen.add(name)
            if owner is None and name in owners:
                owner = owners[name]
            id_ = parent.get(id_)
        owner_us[owner or 'unattributed/host/runtime/GC'] += delta
    def ranked(data):
        return [dict(name=k, sampledMs=v/1000) for k,v in sorted(data.items(), key=lambda kv:-kv[1])[:40]]
    return dict(samples=len(profile['samples']), sampledMs=sum(profile['timeDeltas'])/1000,
        exclusiveLeafFunctions=ranked(self_us), inclusiveFunctionUnion=ranked(inclusive_us),
        nearestSourceOwner=ranked(owner_us),
        scope='V8 sampled time, not clean wall timing. Source owner uses nearest recognized named frame; inlining/missing names/GC may remain unattributed. Inclusive rows overlap and must not be added.')


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--plan', type=Path, required=True)
    ap.add_argument('--out', type=Path, required=True)
    args = ap.parse_args()
    assert not args.out.exists()
    plan_pin, plan = pin(args.plan), read(args.plan)
    pin(__file__)
    for item in plan['inputs']:
        pin(item)
    attempt = read(plan['attempt'])
    owners = {}
    snapshot = Path(attempt['snapshot']['root'])
    for record in attempt['snapshot']['sources']:
        p = Path(record['frozen']['file'])
        if p.suffix == '.bend':
            pin(record['frozen'])
            for name in re.findall(r'^def\s+([\w.]+)',p.read_text(),re.M):
                owners[name] = str(p.relative_to(snapshot))
    rows, profiles = [], []
    for job in plan['jobs']:
        report_file = args.plan.resolve().parent/'runs'/job['name']/'report.json'
        if not report_file.exists():
            continue
        report = read(report_file)
        assert report['complete'] and report['pass'] and report['inputsUnchanged']
        assert report['plan'] == plan_pin and report['job'] == job
        supervisor = read(report_file.parent.with_name(report_file.parent.name+'-guard')/'process.json')
        assert supervisor['complete'] and supervisor['returncode'] == 0
        if job['action']=='request':
            pin(report['output']);pin(report['oracle']);assert report['exactC']
        row = dict(job=job, report=pin(report_file), timings=report['timings'],
            guardWallSeconds=supervisor['wallSeconds'], peakRssBytes=supervisor['peakTreeRssBytes'])
        rows.append(row)
        if job['profile']:
            profiles.append(dict(job=job, report=pin(report_file), stages=report['stages'],
                cpu=profile_summary(read(report['profile']),owners)))
    summaries=[]
    for case in plan['cases']:
        per_role={}
        for role in plan['roles']:
            samples=[r for r in rows if r['job']['action']=='request' and not r['job']['profile'] and r['job']['case']==case and r['job']['role']==role]
            if samples:
                per_role[role]=dict(samples=len(samples), requestMedianMs=statistics.median(r['timings']['requestMs'] for r in samples),
                    importsMedianMs=statistics.median(r['timings']['importsMs'] for r in samples))
        if len(per_role)==3:
            ts=per_role['typescript']['requestMedianMs']
            summaries.append(dict(case=case, roles=per_role,
                requestRatios={r:per_role[r]['requestMedianMs']/ts for r in ['b1','b2']},
                positionBalanced=all(x['samples']==3 for x in per_role.values())))
    observed={r['job']['name'] for r in rows}
    missing=[j['name'] for j in plan['jobs'] if j['name'] not in observed]
    result=dict(kind='phase68-native-request-analysis',complete=not missing,dataOnly=True,targetExecuted=False,
        plannedJobs=len(plan['jobs']),closedJobs=len(rows),missingJobs=missing,
        plan=plan_pin, observations=rows, clean=summaries, profiles=profiles,
        scope=plan['scope'], inputs=list(inputs.values()))
    args.out.parent.mkdir(parents=True,exist_ok=True)
    args.out.write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(dict(output=pin(args.out),cleanCases=len(summaries),profiles=len(profiles))))


if __name__=='__main__':
    main()
