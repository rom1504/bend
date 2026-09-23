#!/usr/bin/env python3
"""Compare retained complete parse/check observations, never compiler execution.

Arguments: FINAL LIVE_REFERENCE CAMPAIGN_BASELINE HISTORICAL_REFERENCE NEW_JSON.
Harness completion flags encode strict expectations and may be false even when
all observations finished. Validate the full inventory and health separately.
"""
import collections
import hashlib
import json
from pathlib import Path
import sys

names = ('final', 'reference', 'baseline', 'historicalReference')
assert len(sys.argv) == 6, __doc__
paths = dict(zip(names, map(Path, sys.argv[1:5])))
out = Path(sys.argv[5])
assert not out.exists(), 'Refuse to overwrite historical comparison'
sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
identity = lambda p: {'file': str(p.absolute()), 'canonicalPath': str(p.resolve()), 'sha256': sha(p)}
inputs = {name: identity(p) for name, p in paths.items()}
inputs['comparisonTool'] = identity(Path(__file__))
reports = {name: json.loads(p.read_text()) for name, p in paths.items()}
key = lambda r: r['id'] + '::' + r['lane']
maps = {}
fixture_sets = {}

def observation(row):
    r = row['result']
    # Physical artifact paths and elapsed time are intentionally excluded.
    return {
        'status': r.get('status'), 'phase': r.get('phase'),
        'checked': r.get('checked'), 'exitCode': r.get('exitCode'),
        'signal': r.get('signal'),
        'text': r.get('diagnostic', r.get('output', r.get('stdout', ''))),
    }

for name, r in reports.items():
    assert r.get('finished') and r['inventory']['total'] == 1378, name
    assert len(r['results']) == 2756 and r['summary']['probes'] == 2756, name
    assert r['changedInputs'] == [] and r['identity']['changedArtifacts'] == [], name
    assert r['identity']['adapterChangedDuringRun'] is False, name
    assert all(not w['errors'] and not w['stats']['failures'] and not w['stats']['timeouts'] for w in r['workers']), name
    assert all(x['result']['status'] in ('ok', 'error') for x in r['results']), name
    assert all(x['status'] in ('pass', 'fail', 'observed') for x in r['results']), name
    maps[name] = {key(x): x for x in r['results']}
    assert len(maps[name]) == 2756, name
    fixtures = {x['id']: x for x in r['inventory']['tests']}
    assert len(fixtures) == 1378, name
    fixture_sets[name] = {i: (x['sha256'], x['negative'], x['expected']) for i, x in fixtures.items()}
    assert set(maps[name]) == {i + '::' + lane for i in fixtures for lane in ('parse', 'check')}, name
    assert all(x['negative'] == fixtures[x['id']]['negative'] for x in r['results']), name
    assert set((x['id'], x['lane']) for x in r['selection']['requested']) == set((x['id'], x['lane']) for x in r['results']), name
for name in names:
    assert fixture_sets[name] == fixture_sets['final'], name + ': changed fixture bytes/oracles'
    assert reports[name]['inventory']['revision'] == reports['final']['inventory']['revision'], name
    sources = lambda r: {x['file']: x['sha256'] for x in r['inventory']['sources']}
    assert sources(reports[name]) == sources(reports['final']), name + ': different upstream sources'

def details(k):
    return {'key': k, **{n: observation(maps[n][k]) for n in names},
            'strictVerdicts': {n: maps[n][k]['status'] for n in names}}

allkeys = sorted(maps['final'])
same = lambda a, b, k: observation(maps[a][k]) == observation(maps[b][k])
old_diffs = {k for k in allkeys if not same('baseline', 'historicalReference', k)}
new_diffs = {k for k in allkeys if not same('final', 'reference', k)}
reference_changes = [k for k in allkeys if not same('reference', 'historicalReference', k)]
groups = {}
for lane in ('parse', 'check', 'all'):
    keys = [k for k in allkeys if lane == 'all' or maps['final'][k]['lane'] == lane]
    groups[lane] = {
        'observations': len(keys),
        'baselineExactDifferences': sum(k in old_diffs for k in keys),
        'finalExactDifferences': sum(k in new_diffs for k in keys),
        'statusDifferences': sum(maps['final'][k]['result'].get('status') != maps['reference'][k]['result'].get('status') for k in keys),
        'statusOrPhaseDifferences': sum(any(maps['final'][k]['result'].get(f) != maps['reference'][k]['result'].get(f) for f in ('status', 'phase')) for k in keys),
        'checkedFlagDifferences': sum(maps['final'][k]['result'].get('checked') != maps['reference'][k]['result'].get('checked') for k in keys),
        'classificationDifferences': sum(any(maps['final'][k]['result'].get(f) != maps['reference'][k]['result'].get(f) for f in ('status', 'phase', 'checked', 'exitCode', 'signal')) for k in keys),
    }
    groups[lane]['textOnlyDifferences'] = groups[lane]['finalExactDifferences'] - groups[lane]['classificationDifferences']

summaries = {}
for name, r in reports.items():
    negatives = [x for x in r['results'] if x['negative']]
    positives = [x for x in r['results'] if not x['negative']]
    check_neg = [x for x in negatives if x['lane'] == 'check']
    summaries[name] = {
        'strictByLane': {lane: dict(collections.Counter(x['status'] for x in r['results'] if x['lane'] == lane)) for lane in ('parse', 'check')},
        'strictCheckFailures': [key(x) for x in r['results'] if x['lane'] == 'check' and x['status'] == 'fail'],
        'positiveFixtures': len(positives) // 2,
        'positiveFixturesBothLanesPass': sum(all(maps[name][i + '::' + l]['status'] == 'pass' and maps[name][i + '::' + l]['result']['status'] == 'ok' for l in ('parse', 'check')) for i, f in fixture_sets[name].items() if not f[1]),
        'negativeParseObserved': sum(x['lane'] == 'parse' and x['status'] == 'observed' for x in negatives),
        'negativeCheckActualPhases': dict(collections.Counter(x['result']['phase'] for x in check_neg)),
        'negativeCheckStatus': dict(collections.Counter(x['result']['status'] for x in check_neg)),
        'negativeCheckCheckedTrue': sum(x['result'].get('checked') is True for x in check_neg),
        'harnessCompleteFlag': r['complete'],
    }

result = {
    'kind': 'phase5-final-live-frontend-comparison', 'complete': True,
    'scope': 'Exact retained parse/check observations only; negative parse observations do not establish checker conformance. No new compiler run or controlled timing.',
    'inputs': inputs, 'fixtureCount': 1378, 'observationCount': 2756,
    'sameFixtureBytesAndOracles': True, 'healthyCompletedInventory': True,
    'groups': groups, 'summaries': summaries,
    'referenceChanges': [details(k) for k in reference_changes],
    'newExactDifferences': [details(k) for k in sorted(new_diffs - old_diffs)],
    'resolvedExactDifferences': sorted(old_diffs - new_diffs),
    'remainingDifferences': [{'key': k, 'differentFields': [f for f in observation(maps['final'][k]) if observation(maps['final'][k])[f] != observation(maps['reference'][k])[f]]} for k in sorted(new_diffs)],
    'changedCandidateObservations': [k for k in allkeys if not same('final', 'baseline', k)],
    'strictCheckRegressions': [details(k) for k in allkeys if maps['final'][k]['lane'] == 'check' and maps['baseline'][k]['status'] == 'pass' and maps['final'][k]['status'] != 'pass'],
    'strictCheckImprovements': [k for k in allkeys if maps['final'][k]['lane'] == 'check' and maps['baseline'][k]['status'] != 'pass' and maps['final'][k]['status'] == 'pass'],
    'referenceStrictFailures': [details(k) for k in allkeys if maps['reference'][k]['status'] == 'fail'],
    'exactDiagnosticLocation': 'Original result.diagnostic/output/stdout fields in the four hash-identified input reports, indexed by id::lane; no trimming or normalization.',
    'fullLanguageConformanceClaim': False,
}
for x in inputs.values():
    assert str(Path(x['file']).resolve()) == x['canonicalPath'] and sha(Path(x['file'])) == x['sha256'], 'Input changed during comparison'
out.parent.mkdir(parents=True, exist_ok=True)
with out.open('x') as f:
    json.dump(result, f, indent=2, ensure_ascii=False)
    f.write('\n')
print(json.dumps({'complete': True, 'groups': groups, 'new': len(result['newExactDifferences']), 'resolved': len(result['resolvedExactDifferences']), 'referenceChanges': len(reference_changes)}))
