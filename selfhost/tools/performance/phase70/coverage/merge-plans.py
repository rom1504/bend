#!/usr/bin/env python3
"""Make common work from separate calibration observations; no targets run."""
import argparse
import hashlib
import json
import math
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]


def pin(path):
    path = Path(path).resolve()
    data = path.read_bytes()
    return dict(path=str(path), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))


p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--calibration', type=Path, nargs='+', required=True)
p.add_argument('--out', type=Path, required=True)
p.add_argument('--target-ms', type=int, default=300)
p.add_argument('--max-slow-ms', type=int, default=3000)
a = p.parse_args()
assert 100 <= a.target_ms <= a.max_slow_ms
out = a.out.resolve()
assert out.is_relative_to(ROOT/'selfhost/build/phase70') and not out.exists()
rows, inputs = [], [pin(__file__)]
for path in a.calibration:
    path = path/'report.json' if path.is_dir() else path
    report = json.loads(path.read_text())
    assert report['kind'] == 'phase70-native-coverage-calibrate' and report['complete']
    assert all(r['correct'] and r['validClock'] and r['elapsedMs'] >= 10 for r in report['records']), (
        'Calibration below 10 ms is too coarse. Repeat using its generated plan in a fresh directory.')
    rows += report['records']
    inputs.append(pin(path))
plan = {}
for name in sorted({r['case'] for r in rows}):
    samples = [r for r in rows if r['case'] == name]
    assert sorted(r['role'] for r in samples) == ['selfhost', 'selfhost', 'upstream'], (
        name, 'Require one baseline, one candidate and one upstream observation per case')
    rates = [r['elapsedMs']/r['repetitions'] for r in samples]
    repetitions = max(16, math.ceil(a.target_ms/min(rates)/16)*16)
    assert repetitions <= 1000000 and max(rates)*repetitions <= a.max_slow_ms, (
        name, 'Role spread cannot meet both timing bounds. Keep the case and choose explicit new bounds.')
    plan[name] = dict(repetitions=repetitions, warmups=max(16, (repetitions//8//16)*16),
                      targetFastMs=a.target_ms, predictedFastMs=min(rates)*repetitions,
                      predictedSlowMs=max(rates)*repetitions)
out.parent.mkdir(parents=True, exist_ok=True)
for item in inputs:
    assert pin(item['path']) == item
with out.open('x') as stream:
    json.dump(plan, stream, indent=2)
    stream.write('\n')
with out.with_suffix('.derivation.json').open('x') as stream:
    json.dump(dict(kind='phase70-common-native-work', output=pin(out), inputs=inputs,
                   targetsExecuted=False, targetFastMs=a.target_ms,
                   maxPredictedSlowMs=a.max_slow_ms,
                   rule='Round fastest observed role to 16 repetitions; identical work in every final role.'),
              stream, indent=2)
    stream.write('\n')
print(json.dumps(dict(output=pin(out), cases=len(plan), targetsExecuted=False)))
