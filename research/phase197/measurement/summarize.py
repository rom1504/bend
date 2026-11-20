#!/usr/bin/env python3
"""Summarize two frozen, balanced six-workload Phase197 runtime sessions."""
from pathlib import Path
import hashlib
import json
import math

ROOT = Path(__file__).resolve().parents[3]
BUILD = ROOT / 'selfhost/build/phase197'
OUT = Path(__file__).parent
ROLES = ['minimum', 'decrement', 'combined']

def pin(p):
    data = p.read_bytes()
    return {'file': str(p), 'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()}

def gm(xs):
    return math.exp(sum(map(math.log, xs)) / len(xs))

plan = json.loads((BUILD / 'measurement-plan01.json').read_text())
machine = json.loads((BUILD / 'machine-product-comparison01.json').read_text())
assert machine['complete']
reports = [json.loads((BUILD / f'runtime0{i}/report.json').read_text()) for i in [1, 2]]
for report in reports:
    assert report['complete'] and not report.get('error') and not report['changedInputs']
    assert report['reference'] == 'baseline' and report['positionBalanced'] and report['rounds'] == 4
    assert report['selectedCaseIds'] == plan['cases']
    assert set(report['roles']) == {'baseline', *ROLES}
rows = []
for name in plan['cases']:
    sessions = []
    for report in reports:
        case = next(c for c in report['cases'] if c['id'] == name)
        summary = case['summary']
        assert summary['admitted'] and summary['ratioEligible']
        assert len(case['samples']) == 16 and all(s['correct'] and not s['lowResolution'] for s in case['samples'])
        sessions.append({'ratios': summary['ratios'], 'stats': summary['stats'],
                         'dispersionRoles': [r for r, st in summary['stats'].items()
                            if (st['maximumMs'] - st['minimumMs']) / st['medianMs'] > 0.05]})
    rows.append({'id': name, 'sessions': sessions,
                 'unchangedObjectRoles': [r['role'] for r in machine['rows'] if r['case'] == name and r['wholeObjectIdentical']],
                 'sessionGeometricRatios': {r: gm([s['ratios'][r] for s in sessions]) for r in ROLES}})
groups = {'allSix': plan['cases'], 'development': plan['targetDevelopment'],
          'heldout': plan['heldout'], 'unrelatedWorkload': [plan['unrelatedWorkload']]}
aggregate = {group: {role: {'sessionGeomeans': [gm([row['sessions'][i]['ratios'][role]
    for row in rows if row['id'] in names]) for i in range(2)],
    'acrossSessionGeomean': gm([row['sessionGeometricRatios'][role] for row in rows if row['id'] in names])}
    for role in ROLES} for group, names in groups.items()}
result = {'kind': 'phase197-six-case-runtime-summary', 'complete': True,
          'method': pin(Path(__file__)), 'plan': pin(BUILD / 'measurement-plan01.json'),
          'machineObjectComparison': pin(BUILD / 'machine-product-comparison01.json'),
          'reports': [pin(BUILD / f'runtime0{i}/report.json') for i in [1, 2]],
          'rows': rows, 'aggregate': aggregate,
          'dispersionThreshold': 'Within-session maximum-minus-minimum exceeds 5% of median',
          'scope': 'Two four-round position-balanced finite six-workload screens versus exact qualified Phase195 products. Ratios use independent per-role calibration. All regressions retained. No confidence interval, full45, compiler-speed, native qualification or installation claim.'}
json_path = OUT / 'runtime-summary01.json'
md_path = OUT / 'runtime-summary01.md'
assert not json_path.exists() and not md_path.exists(), 'Fresh summary outputs required'
json_path.write_text(json.dumps(result, indent=2) + '\n')
lines = ['# Phase197 checked compiler runtime screen', '',
         'Ratios are candidate / qualified Phase195 runtime; lower is faster. Each cell shows the two independent sessions. Four rounds balance all four roles in each session.', '',
         '| Case | Minimum | Decrement | Combined |', '| --- | ---: | ---: | ---: |']
for row in rows:
    lines.append('| ' + row['id'] + ' | ' + ' | '.join('/'.join(f"{s['ratios'][r]:.4f}" for s in row['sessions']) for r in ROLES) + ' |')
lines += ['', 'Geometric ratios across both sessions:', '', '| Partition | Minimum | Decrement | Combined |', '| --- | ---: | ---: | ---: |']
for group, values in aggregate.items():
    lines.append('| ' + group + ' | ' + ' | '.join(f"{values[r]['acrossSessionGeomean']:.4f}" for r in ROLES) + ' |')
flags = [f"{row['id']} session{i + 1}: {', '.join(s['dispersionRoles'])}" for row in rows for i, s in enumerate(row['sessions']) if s['dispersionRoles']]
lines += ['', 'Dispersion flags: ' + ('; '.join(flags) if flags else 'none') + '.', '', result['scope'], '']
lines += ['Unchanged emitted objects: ' + '; '.join(row['id'] + ': ' + ', '.join(row['unchangedObjectRoles']) for row in rows if row['unchangedObjectRoles']) + '. Timing differences on these rows do not establish an optimization effect.', '']
md_path.write_text('\n'.join(lines))
print(json.dumps({'complete': True, 'aggregate': aggregate, 'summary': str(json_path)}))
