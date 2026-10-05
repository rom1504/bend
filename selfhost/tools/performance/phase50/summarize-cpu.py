#!/usr/bin/env python3
"""Read a completed profile queue; summarize weighted raw CPU samples, without execution."""
import argparse
from collections import Counter
import hashlib
import json
import math
from pathlib import Path

GUARDS = set('regionHostGuard arrayViewHostGuard stringHostGuard stringHostDescriptor scalarGuard localGuard'.split())
PROOF = set('regionProofCovers regionProofOpen regionProofClose'.split())
DISPATCH = set('invokeExact enterExact apply force call callOwned'.split())
inputs = {}

def identity(path):
    path = Path(path).resolve(strict=True)
    hasher = hashlib.sha256()
    with path.open('rb') as stream:
        for block in iter(lambda: stream.read(1048576), b''): hasher.update(block)
    return dict(file=str(path), bytes=path.stat().st_size, sha256=hasher.hexdigest())

def pin(path, expected=None):
    item = identity(path)
    if expected:
        assert item['sha256'] == expected['sha256'], 'Changed input: ' + str(path)
        assert expected.get('bytes', item['bytes']) == item['bytes']
    if item['file'] in inputs:
        assert inputs[item['file']] == item
    inputs[item['file']] = item
    return item

def read(path, expected=None):
    item = pin(path, expected)
    return json.loads(Path(item['file']).read_text()), item

ap = argparse.ArgumentParser(description=__doc__)
ap.add_argument('queue', type=Path)
ap.add_argument('output', type=Path)
args = ap.parse_args()
assert not args.output.exists(), 'New output only'
pin(__file__)
queue, queue_id = read(args.queue)
assert queue['complete'] and queue['inputStabilityVerified'] and queue['jobs']
for item in queue['inputs']:
    pin(item['file'], item)
bindings, _ = read(args.queue.resolve().parent.parent / 'inputs.json')
manifest, _ = read(bindings['manifest']['file'], bindings['manifest'])
assert bindings['manifest']['sha256'] == '7c11d34a7bc5982c8b3d7ff6b73c09d33db20701f81a80942e14d184389c7f73'
assert manifest['complete'] and manifest['roles'] == bindings['roles']
compiler = manifest['roles']['candidate']['compiler']
assert compiler['api']['sha256'] == '6f9d111aa68c19f3ce45b80785621d57c4d10efb12d50164f5cb0597bc952100'
for key in ('api', 'runtime', 'base', 'driver'): pin(compiler[key]['file'], compiler[key])
bound = {c['id']: c for c in bindings['cases']}
assert len(bound) == len(bindings['cases']) == len(manifest['cases']) == 45
assert set(bound) == {c['id'] for c in manifest['cases']} == {j['label'] for j in queue['jobs']}
for case in manifest['cases']:
    b = bound[case['id']]; expected = case['modules']['candidate']
    assert b['point'] == case['point'] and b['sourceSha256'] == case['sourceSha256']
    origin = pin(Path(bindings['manifest']['file']).parent / expected['path'], expected)
    assert origin == b['origin'] and b['module']['sha256'] == origin['sha256']
cases = []
for job in queue['jobs']:
    assert job['passed'] and job['process']['complete'] and job['process']['returncode'] == 0
    report, report_id = read(job['report']['file'], job['report'])
    assert report['complete'] and report['pass'] and report['profileKind'] == 'cpu'
    command = job['process']['command']
    assert len(command) >= 5 and Path(command[-2]).resolve() == Path(report_id['file'])
    pin(command[-5], {'sha256': report['toolSha256']})
    module = pin(report['module']['file'], report['module'])
    assert module == bound[job['label']]['module']
    assert Path(command[-4]).resolve() == Path(module['file'])
    config, _ = read(command[-3], {'sha256': report['configSha256']})
    assert config == report['config']
    assert {k: config[k] for k in ('exportName', 'args', 'expected')} == bound[job['label']]['point']
    assert Path(command[-1]).resolve() == Path(report['profile']['file']).resolve()
    raw, raw_id = read(report['profile']['file'], report['profile'])
    url = Path(module['file']).as_uri()
    nodes = {n['id']: n for n in raw['nodes']}
    assert nodes and len(nodes) == len(raw['nodes'])
    parents = {}
    for node in nodes.values():
        for child in node.get('children', []):
            assert child in nodes and child not in parents
            parents[child] = node['id']
    roots = set(nodes) - set(parents)
    assert len(roots) == 1
    context, pending = {}, [(next(iter(roots)), False)]
    while pending:
        nid, inherited = pending.pop()
        assert nid not in context, 'CPU profile must be a tree'
        frame = nodes[nid]['callFrame']
        context[nid] = inherited or (frame['url'] == url and frame['functionName'] in GUARDS)
        pending.extend((child, context[nid]) for child in nodes[nid].get('children', []))
    assert len(context) == len(nodes), 'Disconnected or cyclic CPU profile'
    samples, deltas = raw['samples'], raw['timeDeltas']
    assert len(samples) == len(deltas) and samples
    weights, counts, frames, frame_counts = Counter(), Counter(), Counter(), Counter()
    guard_weight = guard_count = 0
    for nid, delta in zip(samples, deltas):
        assert nid in nodes and isinstance(delta, (int, float)) and math.isfinite(delta) and delta >= 0
        f = nodes[nid]['callFrame']; name = f['functionName']; local = f['url'] == url
        category = 'gc' if name == '(garbage collector)' else 'guard' if local and name in GUARDS else 'proof' if local and name in PROOF else 'dispatch' if local and name in DISPATCH else 'generated-other' if local else 'external-or-harness'
        weights[category] += delta; counts[category] += 1
        key = (name, f['url'], f['lineNumber'], f['columnNumber'])
        frames[key] += delta; frame_counts[key] += 1
        if context[nid]:
            guard_weight += delta; guard_count += 1
    total = sum(deltas)
    assert total > 0 and total == report['summary']['totalWeight'] and len(samples) == report['summary']['sampleCount']
    def metric(weight, count):
        return dict(microseconds=weight, samples=count, percent=100 * weight / total)
    top = [dict(functionName=k[0], url=k[1], line=k[2] + 1 if k[2] >= 0 else None, column=k[3] + 1 if k[3] >= 0 else None, **metric(v, frame_counts[k])) for k, v in frames.most_common(10)]
    warnings = list(report['summary'].get('warnings', []))
    if len(samples) < 100: warnings.append('Fewer than 100 samples; hotspot proportions are coarse.')
    if not report.get('targetReached'): warnings.append('Requested profile window was not reached.')
    if report.get('maxRepetitionsReached'): warnings.append('Repetition cap was reached.')
    cases.append(dict(id=job['label'], module=module, report=report_id, rawProfile=raw_id, point={k: config[k] for k in ('exportName', 'args', 'expected')}, calls=report['repetitions'], profiledLoopMs=report['profiledLoopMs'], sampleCount=len(samples), totalWeightUs=total, self={k: metric(weights[k], counts[k]) for k in ['guard', 'proof', 'dispatch', 'gc', 'generated-other', 'external-or-harness']}, guardAncestor=metric(guard_weight, guard_count), topSelf=top, warnings=warnings))
assert len({c['id'] for c in cases}) == len(cases)
assert all(identity(item['file']) == item for item in inputs.values()), 'Consumed inputs changed'
result = dict(kind='phase50-cpu-ancestry-summary', complete=True, diagnosticOnly=True, queue=queue_id, inputs=list(inputs.values()), guardNames=sorted(GUARDS), proofNames=sorted(PROOF), dispatchNames=sorted(DISPATCH), cases=cases, warnings=['Each sample is weighted by its preceding time delta; sampled percentages are not clean execution-time ratios.', 'Self categories partition all sample weight. guardAncestor counts each raw-tree sample once if its leaf or any ancestor is a named guard in the exact module URL; it overlaps self categories and must not be added to them.', 'Native reflection and anonymous descendants are included only through actual guard ancestry. Missing/inlined guard frames can undercount; inline input checks are not identified by this census.', 'GC is reported by sampled leaf identity; a root-level GC sample cannot be assigned to the allocation that caused it.', 'These fixed warmed windows include validation, harness and profiler boundary work; one window is not a stationarity or significance test.'])
args.output.parent.mkdir(parents=True, exist_ok=True)
with args.output.open('x') as stream:
    json.dump(result, stream, indent=2); stream.write('\n')
print(json.dumps(dict(complete=True, cases=len(cases), output=identity(args.output))))
