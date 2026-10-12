#!/usr/bin/env python3
"""Data-only comparison of actual old69/final03 compiler images on Numeric."""
import argparse
import hashlib
import json
import math
import statistics
from pathlib import Path


def pin(value):
    expected = value if isinstance(value, dict) else None
    path = Path(expected['file'] if expected else value).resolve(strict=True)
    data = path.read_bytes()
    result = dict(file=str(path), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))
    if expected:
        assert result['sha256'] == expected['sha256']
        assert 'bytes' not in expected or result['bytes'] == expected['bytes']
    return result


p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--plan', type=Path, required=True)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()
assert not a.out.exists()
plan = json.loads(a.plan.read_text())
plan_pin = pin(a.plan)
assert plan['legitimateImages'] and len(plan['jobs']) == 20
for item in plan['inputs']:
    pin(item)
rows = []
for job in plan['jobs']:
    path = a.plan.parent/'runs'/job['name']/'report.json'
    report = json.loads(path.read_text())
    guard_path = path.parent.with_name(path.parent.name+'-guard')/'process.json'
    guard = json.loads(guard_path.read_text())
    assert report['complete'] and report['pass'] and report['inputsUnchanged']
    assert report['plan'] == plan_pin and report['job'] == job
    assert guard['complete'] and guard['returncode'] == 0
    if job['action'] == 'request':
        assert report['exactC'] and pin(report['output'])['sha256'] == pin(report['oracle'])['sha256']
        assert report['oracle'] == plan['cases']['numeric']['expected'][job['role']]
    rows.append(dict(job=job, report=pin(path), guard=pin(guard_path), timings=report['timings'],
        guardWallSeconds=guard['wallSeconds'], peakRssBytes=guard['peakTreeRssBytes']))
stages = []
for stage in ['b1', 'b2']:
    arms = {}
    for release in ['old69', 'final03']:
        values = sorted([r for r in rows if r['job'].get('stage') == stage and r['job'].get('release') == release], key=lambda r:r['job']['round'])
        assert len(values) == 4 and sorted(r['job']['position'] for r in values) == list(range(4))
        samples = [r['timings']['requestMs'] for r in values]
        arms[release] = dict(requestMs=samples, medianMs=statistics.median(samples), minimumMs=min(samples), maximumMs=max(samples))
    paired = [new/old for new, old in zip(arms['final03']['requestMs'], arms['old69']['requestMs'])]
    stages.append(dict(stage=stage, arms=arms, finalOverOldMedian=arms['final03']['medianMs']/arms['old69']['medianMs'],
        pairedRoundRatios=paired, geomeanPairedRatio=math.exp(statistics.mean(math.log(r) for r in paired)), finalFasterRounds=sum(r<1 for r in paired)))
result = dict(kind='phase70-legitimate-release-compiler-pair', complete=True, targetsExecutedByAnalyzer=False,
    producer=pin(__file__), plan=plan_pin, evidence=plan['evidence'], preparations=4, exactRequests=16,
    stages=stages, observations=rows,
    preparationGuardSeconds=sum(r['guardWallSeconds'] for r in rows if r['job']['action']=='prepare'),
    cleanGuardSeconds=sum(r['guardWallSeconds'] for r in rows if r['job']['action']=='request'),
    peakRssBytes=max(r['peakRssBytes'] for r in rows), scope=plan['scope'])
with a.out.open('x') as stream:
    stream.write(json.dumps(result, indent=2)+'\n')
print(json.dumps(dict(output=pin(a.out), stages=stages)))
