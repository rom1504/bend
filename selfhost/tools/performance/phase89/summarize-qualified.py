#!/usr/bin/env python3
"""Offline, equal-source summary of the final native89 engine screen."""
import hashlib
import json
import math
import statistics
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
RAW = ROOT / 'selfhost/build/phase89'


def pin(path):
    data = path.read_bytes()
    return dict(file=str(path.relative_to(ROOT)), bytes=len(data),
                sha256=hashlib.sha256(data).hexdigest())


def read(name):
    path = RAW / name / 'report.json'
    report = json.loads(path.read_text())
    assert report['complete'] and report['passed']
    assert all(row['exact'] and row['job']['pass_'] for row in report['rows'])
    return report, pin(path)


cold, cold_pin = read('qualified-cold01')
warm, warm_pin = read('qualified-warm01')
rows = []
for case in cold['sourcePins']:
    record = dict(case=case, cold={})
    for role in cold['roles']:
        group = [r for r in cold['rows'] if r['case'] == case and r['role'] == role]
        assert len(group) == 2
        record['cold'][role] = dict(
            processMs=1000 * statistics.median(r['processWallSeconds'] for r in group),
            requestMs=statistics.median(r['requestMs'][0] for r in group))
    record['nativeOverTsBunColdProcess'] = (record['cold']['native']['processMs'] /
                                           record['cold']['ts-bun']['processMs'])
    repeated = [r for r in warm['rows'] if r['case'] == case]
    if repeated:
        record['fiveCallsMs'] = {r['role']: r['requestMs'] for r in repeated}
        record['nativeOverTsBunFifthRequest'] = (record['fiveCallsMs']['native'][4] /
                                                record['fiveCallsMs']['ts-bun'][4])
    rows.append(record)
result = dict(complete=True, cold=cold_pin, warm=warm_pin, method=pin(Path(__file__)),
              cleanOutputs=sum(len(r['outputs']) for t in (cold, warm) for r in t['rows']),
              coldNativeOverTsBunGeomean=math.exp(statistics.mean(
                  math.log(r['nativeOverTsBunColdProcess']) for r in rows)), rows=rows,
              scope='Six-case cold process screen, two rounds; three-case five-call screen, one round. '
                    'Prepared native Base and JS source loading have different boundaries. '
                    'Not a backend-only ratio, steady-state claim, broad parity claim or program execution timing.')
(ROOT / 'implementation/phase89/qualified-screen.json').write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps(result, indent=2))
