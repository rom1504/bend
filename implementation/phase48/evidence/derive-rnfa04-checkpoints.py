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

report = read(RAW / 'compiler-cost-rnfa04/report.json')
config = read(report['config']['file'])
assert report['complete'] and report['pass'] and len(report['rows']) == 18
assert [c['id'] for c in config['cases']] == ['test-evening-program', 'lexer']
assert config['samples'] == 3 and config['order'] == ['typescript', 'baseline', 'candidate']
for role, api in [('baseline', BASE_API), ('candidate', CAND_API)]:
    assert config['variants'][role]['api']['sha256'] == api
    assert config['variants'][role]['runtime']['sha256'] == RUNTIME
expected_order = [(c['id'], n, role) for c in config['cases'] for n in range(3)
                  for role in config['order'][n:] + config['order'][:n]]
assert [(r['source'], r['sample'], r['variant']) for r in report['rows']] == expected_order
last = 0
for row in report['rows']:
    execution, observation = row['execution'], row['observation']
    assert execution['complete'] and execution['returncode'] == 0
    assert observation['complete'] and observation['pass'] and observation['node'] == 'v24.18.0'
    assert execution['started'] >= last
    last = execution['finished']
    request_path, result_path = map(Path, execution['command'][-2:])
    request = read(request_path)
    assert read(result_path) == observation
    prefix = str(request_path).removesuffix('.request.json')
    assert read(Path(prefix + '-process/process.json')) == execution
    case = next(c for c in config['cases'] if c['id'] == row['source'])
    assert observation['source'] == case['source']
    assert observation['output']['sha256'] == case['expected'][row['variant']]['sha256']
    assert request['api'] == config['variants'][row['variant']]['api']
calculated, changes = {}, {}
for case in config['cases']:
    calculated[case['id']] = {}
    for role in config['order']:
        rows = [r for r in report['rows'] if r['source'] == case['id'] and r['variant'] == role]
        s = {k: stats([r['observation'][k] for r in rows])
             for k in ['requestMs', 'hostImportMs', 'importAndRequestMs', 'maxRssKiB']}
        s.update(processWallMs=stats([r['execution']['wallSeconds'] * 1000 for r in rows]),
                 peakTreeRssBytes=stats([r['execution']['peakTreeRssBytes'] for r in rows]),
                 outputBytes=stats([r['observation']['output']['bytes'] for r in rows]))
        assert s == report['statistics'][case['id']][role]
        calculated[case['id']][role] = s
    b, c, t = [calculated[case['id']][r]['requestMs']['median'] for r in ('baseline', 'candidate', 'typescript')]
    changes[case['id']] = dict(candidateOverBaseline=c/b, changePercent=100*(c/b-1),
                              baselineOverTypescript=b/t, candidateOverTypescript=c/t)
prep = read(RAW / 'compiler-cost-plan-rnfa04/preparation.json')
for item in prep['bindings']:
    assert read(RAW / ('compiler-cost-plan-rnfa04/verify-' + item['role'] + '/process.json')) == item['process']
cost = dict(kind='phase48-rnfa04-compiler-cost-derivation', complete=True, pass_=True,
            report=identity(RAW / 'compiler-cost-rnfa04/report.json'), statistics=calculated,
            changes=changes, resources=report['resources'], rows=18,
            sourceAccounting=identity(OUT / 'accounting-rnfa04.json'),
            preparation=dict(record=identity(RAW / 'compiler-cost-plan-rnfa04/preparation.json'),
                             bindingProcesses=prep['bindings'],
                             bindingProcessWallSeconds=sum(x['process']['wallSeconds'] for x in prep['bindings']),
                             scope='Binding verification only; not a full preparation wall timer.'),
            campaignWallSeconds=report['wallSeconds'],
            childWallSeconds=sum(r['execution']['wallSeconds'] for r in report['rows']),
            requestSeconds=sum(r['observation']['requestMs']/1000 for r in report['rows']))
cost['pass'] = cost.pop('pass_')
write('compiler-cost-final.json', cost)

seen = {}
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
        assert process['started'] >= last
        last = process['finished']
    s = {r: stats([x['result']['msPerCall'] for x in case['samples'] if x['role'] == r]) for r in config['order']}
    for role in config['order']:
        assert s[role]['median'] == case['summary']['stats'][role]['medianMs']
    b, c, t = [s[r]['median'] for r in ('baseline', 'candidate', 'typescript')]
    points.append(dict(id=case['id'], point=case['point'], statsMs=s,
                       halfDriftPercent={r: [x['result']['halfDriftPercent'] for x in case['samples'] if x['role'] == r] for r in config['order']},
                       baselineOverCandidate=b/c, candidateOverTypescript=c/t,
                       candidateChangePercent=100*(c/b-1)))
write('literal-rnfa04-checkpoint.json', dict(kind='phase48-rnfa04-literal-checkpoint', complete=True,
      passed=True, report=identity(RAW / 'literal-scale-screen-rnfa04/report.json'),
      protocol=screen['plan'], points=points, samples=36, wallSeconds=screen['wallSeconds'],
      controls=dict(report=identity(RAW / 'array-counts-controls04/report.json'), counts=dict(oracles=43,boundaries=13,activation=56),
                    scope=controls['scope'], activation=controls['activation']),
      historicalComparison=identity(OUT / 'rnfa03-checkpoint.json'),
      scope='Fresh RNFA04 screen, separate from RNFA03 and the primary 45-point corpus. No target execution.'))
