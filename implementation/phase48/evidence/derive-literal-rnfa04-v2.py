#!/usr/bin/env python3
"""Data-only, fixed RNFA04 receipts; no compiler imports or target execution."""
import hashlib
import json
import math
from pathlib import Path
from statistics import median

ROOT = Path(__file__).resolve().parents[3]
RAW = ROOT / 'selfhost/build/phase48'
OUT = Path(__file__).resolve().parent
BASE_API = '28f9eb983b2ba3603a9af703d832d4a301efe32182b468e090db6b728a47d12f'
CAND_API = '6f9d111aa68c19f3ce45b80785621d57c4d10efb12d50164f5cb0597bc952100'
RUNTIME = '880bce50e3194b9ee9d99bd57c18ef88bcb8925d9d1668dec6765040a4d3219b'
seen = {}

def identity(path):
    path = Path(path).resolve()
    h = hashlib.sha256()
    with path.open('rb') as f:
        for chunk in iter(lambda: f.read(1048576), b''):
            h.update(chunk)
    value = dict(path=str(path), bytes=path.stat().st_size, sha256=h.hexdigest())
    if str(path) in seen:
        assert seen[str(path)] == value, path
    seen[str(path)] = value
    return value

def walk(value):
    if isinstance(value, dict):
        path = value.get('canonicalPath', value.get('file', value.get('path')))
        if path and value.get('sha256'):
            actual = identity(path)
            assert actual['sha256'] == value['sha256'], path
            if 'bytes' in value:
                assert actual['bytes'] == value['bytes'], path
        for child in value.values():
            walk(child)
    elif isinstance(value, list):
        for child in value:
            walk(child)

def read(path):
    identity(path)
    value = json.loads(Path(path).read_text())
    walk(value)
    return value

def stats(xs):
    return dict(median=median(xs), min=min(xs), max=max(xs), samples=xs)

def write(name, value):
    value['method'] = identity(__file__)
    for p, original in list(seen.items()):
        assert identity(p) == original
    value['inputs'] = list(seen.values())
    with (OUT / name).open('x') as f:
        json.dump(value, f, indent=2)
        f.write('\n')
    print(name, identity(OUT / name)['sha256'], len(value['inputs']))

seen = {}
config = dict(order=['typescript', 'baseline', 'candidate'])
intervals = []
screen = read(RAW / 'literal-scale-screen-rnfa04/report.json')
controls = read(RAW / 'array-counts-controls04/report.json')
assert screen['complete'] and screen['pass'] and len(screen['cases']) == 4
assert controls['complete'] and controls['pass']
assert [len(controls[k]) for k in ('oracles', 'boundaries', 'activation')] == [43, 13, 56]
for role, api in [('baseline', BASE_API), ('candidate', CAND_API)]:
    assert screen['plan']['variants'][role]['compiler']['api']['sha256'] == api
points, last = [], 0
for case in screen['cases']:
    assert [(s['round'], s['role']) for s in case['samples']] == [
        (n, role) for n in range(3) for role in config['order'][n:] + config['order'][:n]]
    for s in case['samples']:
        result, process = s['result'], s['process']
        assert result['complete'] and result['pass'] and process['returncode'] == 0
        sample_path = Path(process['command'][-1])
        assert read(sample_path) == result
        assert read(sample_path.parent / 'process/process.json') == process
        intervals.append((process['started'], process['finished']))
    s = {r: stats([x['result']['msPerCall'] for x in case['samples'] if x['role'] == r]) for r in config['order']}
    for role in config['order']:
        assert s[role]['median'] == case['summary']['stats'][role]['medianMs']
    b, c, t = [s[r]['median'] for r in ('baseline', 'candidate', 'typescript')]
    points.append(dict(id=case['id'], point=case['point'], statsMs=s,
                       halfDriftPercent={r: [x['result']['halfDriftPercent'] for x in case['samples'] if x['role'] == r] for r in config['order']},
                       baselineOverCandidate=b/c, candidateOverTypescript=c/t,
                       candidateChangePercent=100*(c/b-1)))
ordered = sorted(intervals)
assert all(a[1] <= b[0] for a,b in zip(ordered,ordered[1:]))
write('literal-rnfa04-checkpoint.json', dict(kind='phase48-rnfa04-literal-checkpoint', complete=True,
      passed=True, report=identity(RAW / 'literal-scale-screen-rnfa04/report.json'),
      protocol=screen['plan'], points=points, samples=36, wallSeconds=screen['wallSeconds'],
      controls=dict(report=identity(RAW / 'array-counts-controls04/report.json'), counts=dict(oracles=43,boundaries=13,activation=56),
                    scope=controls['scope'], activation=controls['activation']),
      historicalComparison=identity(OUT / 'rnfa03-checkpoint.json'),
      scope='Fresh RNFA04 screen, separate from RNFA03 and the primary 45-point corpus. No target execution.'))
