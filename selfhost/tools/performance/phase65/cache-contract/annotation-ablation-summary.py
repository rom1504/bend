#!/usr/bin/env python3
"""Read-only incremental H2 timing summary; never executes a compiler."""
import hashlib
import json
import math
import statistics
import sys
from pathlib import Path

report_file, out = map(Path, sys.argv[1:])
assert not out.exists()
pin = lambda p: dict(file=str(p.resolve()), sha256=hashlib.sha256(p.read_bytes()).hexdigest())
report = json.loads(report_file.read_text())
assert report['kind'] == 'phase65-base-annotation-presence-ablation-results'
assert report['complete'] and report['pass'] and not report['failures']
assert pin(Path(report['plan']['file'])) == report['plan']
plan = json.loads(Path(report['plan']['file']).read_text())
rows = []
for case in plan['cases']:
    groups = {role: [r for r in report['rows'] if r['case'] == case['id'] and r['role'] == role]
              for role in ['without_products', 'with_products']}
    assert all(len(xs) == report['rounds'] for xs in groups.values())
    for group in groups.values():
        for r in group:
            assert r['success'] and r['observation']['pass']
            assert pin(Path(r['result']['file'])) == r['result']
            assert json.loads(Path(r['result']['file']).read_text()) == r['observation']
            assert r['observation']['output']['sha256'] == case['expected']['sha256']
    clocks = {}
    for clock in ['firstRequestMs', 'importApiAndFirstMs']:
        samples = {role: [r['observation'][clock] for r in group] for role, group in groups.items()}
        medians = {role: statistics.median(xs) for role, xs in samples.items()}
        clocks[clock] = dict(samples=samples, medians=medians,
                             withOverWithout=medians['with_products']/medians['without_products'])
    rows.append(dict(case=case['id'], clocks=clocks))
result = dict(kind='phase65-h2-incremental-ablation-summary', complete=True, dataOnly=True,
              targetExecuted=False, producer=pin(Path(__file__)), report=pin(report_file), plan=report['plan'],
              workers=len(report['rows']), rows=rows,
              geometricMean={clock: math.exp(statistics.mean(math.log(r['clocks'][clock]['withOverWithout']) for r in rows))
                             for clock in ['firstRequestMs', 'importApiAndFirstMs']},
              scope='Same actual combined B2/H6/API/driver/frame in both roles, optional sidecar presence alone differs. '
                    'Equal-case geometric mean of role medians, fresh prepared requests with complete raw output equality. '
                    'This measures incremental artifact value, retaining H2 code in both roles; not full H2-removal or TS parity.')
out.parent.mkdir(parents=True, exist_ok=True)
out.write_text(json.dumps(result, indent=2)+'\n')
print(json.dumps(dict(output=pin(out), geometricMean=result['geometricMean'], rows=rows)))
