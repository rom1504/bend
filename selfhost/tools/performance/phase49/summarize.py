#!/usr/bin/env python3
"""Recompute Phase49 measurements from retained, hash-bound probe receipts."""
import argparse
import hashlib
import json
import statistics
from collections import defaultdict
from pathlib import Path

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--raw', type=Path, required=True)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()
assert not a.out.exists()
inputs = {}
def identity(path):
    path = Path(path).resolve()
    data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())
def check(row):
    file = row.get('file', row.get('path'))
    if file not in inputs:
        inputs[file] = identity(file)
    assert all(inputs[file][k] == row[k] for k in ['bytes', 'sha256'] if k in row), file
def read(path):
    row = identity(path)
    check(row)
    return json.loads(Path(path).read_text())
guard_names = {'stringHostGuard', 'stringHostDescriptor', 'regionHostGuard', 'scalarGuard', 'localGuard'}
clean = {}
profiles = []
processes = []
for name in ['clean01', 'cpu01', 'allocation01', 'trace01', 'graphs01', 'graphs-ts02', 'guard-clean01', 'allocation02']:
    queue = read(a.raw / name / 'report.json')
    assert queue['complete'] and queue['inputStabilityVerified'], name
    for row in queue['inputs']:
        check(row)
    values = defaultdict(list)
    for job in queue['jobs']:
        assert job['process']['complete'] and job['process']['returncode'] == 0
        check(job['report'])
        d = read(job['report']['file'])
        assert d['complete'] and d['passed'] and d['inputRehashPassed']
        for row in d['inputs']:
            check(row)
        processes.append(dict(campaign=name, label=job['label'], process=job['process']))
        role = Path(d['module']['file']).stem
        if d['mode'] == 'clean':
            values[role].append(d['microsecondsPerCall'])
        if d['mode'] in ['cpu', 'allocation']:
            s = d['summary']
            profiles.append(dict(campaign=name, role=role, mode=d['mode'], calls=d['input']['calls'],
                samples=s['sampleCount'], estimatedBytesPerCall=d.get('estimatedBytesPerCall'),
                namedGuardSelfPercent=sum(f['selfPercent'] or 0 for f in s['frames'] if f['functionName'] in guard_names),
                native10BytesPerCall=sum(f.get('selfBytes', 0) for f in s['frames'] if f['functionName'] == '$native10') / d['input']['calls'] if d['mode'] == 'allocation' else None,
                topSelf=s['topSelf'][:12], warnings=s.get('warnings', []),
                accounting=s.get('accounting'), report=job['report']))
    if values:
        clean[name] = {role: dict(samples=len(v), microseconds=v, medianUs=statistics.median(v),
                                  minUs=min(v), maxUs=max(v)) for role, v in values.items()}
traces = []
for home in sorted((a.raw / 'trace01').glob('*/process')):
    path = home / 'stdout.log'
    check(identity(path))
    text = path.read_text()
    assert text.count('P49_V8 measure-start') == text.count('P49_V8 measure-end') == 1
    before, measured = text.split('P49_V8 measure-start')
    measured, after = measured.split('P49_V8 measure-end')
    assert 'P49_V8 warmup-end' in before
    traces.append(dict(role=home.parent.name.split('-', 2)[-1],
        measuredBailouts=[x for x in measured.splitlines() if 'bailout' in x],
        measuredGcEvents=sum('gc=' in x for x in measured.splitlines()),
        measuredCompletedOptimizations=[x for x in measured.splitlines() if 'completed optimizing' in x],
        relevantLines=[x for x in text.splitlines() if any(t in x for t in ['P49_V8', '$native10', '_46_55$tree', '$rle$'])],
        input=identity(path)))
ordered = sorted(processes, key=lambda x: x['process']['started'])
for left, right in zip(ordered, ordered[1:]):
    assert left['process']['finished'] <= right['process']['started'], 'Target overlap'
time_seconds = sum(x['process']['wallSeconds'] for x in ordered)
endpoints = [x['process']['finished'] for x in ordered]
start = read(a.raw / 'start.json')
check(identity(__file__))
for row in inputs.values():
    assert identity(row['file']) == row, 'Changed input during summarization'
result = dict(kind='phase49-v8-diagnostic-summary', complete=True, inputs=list(inputs.values()),
    clean=clean, profiles=profiles, traces=traces, targetJobs=len(ordered),
    observedTargetSeconds=time_seconds, lastTargetFinished=max(endpoints),
    maxObservedTreeRssBytes=max(x['process']['peakTreeRssBytes'] for x in ordered),
    noTargetOverlap=True, start=start,
    scope='One fixed RLE source. Changed-guard roles are unsafe diagnostics; no compiler promotion. '
          'Profile estimates and static graph nodes are not exact allocations/call. '
          'First TS clean window is short; use guard-clean01 for the longer fresh comparison. '
          'Successful probe completion does not establish graph-dump completeness: graphs01 TS is invalid; use graphs-ts02.')
a.out.parent.mkdir(parents=True, exist_ok=True)
with a.out.open('x') as stream:
    json.dump(result, stream, indent=2)
    stream.write('\n')
print(json.dumps(dict(complete=True, targetJobs=len(ordered), observedTargetSeconds=time_seconds,
                     inputs=len(inputs), maxObservedTreeRssBytes=result['maxObservedTreeRssBytes'])))
