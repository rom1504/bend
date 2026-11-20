#!/usr/bin/env python3
"""Authenticate the separately frozen regression follow-up; preserve broad score."""
import importlib.util
import json
from pathlib import Path
ROOT = Path(__file__).resolve().parents[3]
spec = importlib.util.spec_from_file_location('analysis', ROOT / 'selfhost/tests/phase186/analyze-runtime.py')
A = importlib.util.module_from_spec(spec)
spec.loader.exec_module(A)
report = ROOT / 'selfhost/build/phase198/regression-runtime01/report.json'
a = A.analyze(report, 1.10)
raw = A.B.read(report)
assert a['positionBalanced'] and a['rounds'] == 6 and a['reference'] == 'baseline'
assert [c['id'] for c in raw['cases']] == ['coverage-list-pipeline-128','variation-lexer-6-17','variation-local-fold-128-0','symreg','local-pair']
rows = []
for c in a['cases']:
    samples = next(x['samples'] for x in raw['cases'] if x['id'] == c['id'])
    assert all(x['elapsedMs'] >= raw['minimumAcceptedMs'] >= 100 for x in samples)
    by_round = {i: {x['role']: x['metricMs'] for x in samples if x['round'] == i} for i in range(6)}
    ratios = [x['candidate']/x['baseline'] for x in by_round.values()]
    rows.append(dict(id=c['id'], ratio=c['stats']['candidate']['medianMs']/c['stats']['baseline']['medianMs'], pairedRatios=ratios, candidateWins=sum(r<1 for r in ratios), flagged=c['flagged'], stats=c['stats']))
out = dict(kind='phase198-authenticated-regression-followup', complete=True, method=A.C.pin(__file__), analyzer=A.C.pin(A.__file__), report=a['report'], oracleRevalidated=a['oracleRevalidated'], inputPinsVerified=a['inputPinsVerified'], cases=rows, scope='Separate five-case six-round position-balanced follow-up selected before measurement; primary all45 result is retained unchanged. Ratios use role medians; paired ratios and every observation retained. No significance or promotion claim.')
path=ROOT/'research/phase198/qualification/regression-summary01.json'
assert not path.exists()
path.write_text(json.dumps(out,indent=2)+'\n')
print(json.dumps(rows,indent=2))
