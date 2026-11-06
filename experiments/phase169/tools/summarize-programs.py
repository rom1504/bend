#!/usr/bin/env python3
"""Combine only predeclared resolution repairs; keep the original aggregate."""
import copy
import json
import math
import statistics
import sys
from pathlib import Path
sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0,str(ROOT/'selfhost/tools/bench'))
import bench
paths = [ROOT/'selfhost/build/phase169'/name/'report.json' for name in
         ['quality-broad-timing01','quality-resolution01']]
original,repair = [bench.read(path) for path in paths]
assert original['complete'] and repair['complete'] and repair['aggregate']['complete']
for key in ['manifest','roles','reference','rounds']: assert original['plan'][key] == repair['plan'][key]
assert original['plan']['scale'] == 1 and repair['plan']['scale'] == 40
assert original['plan']['rounds'] == 4
bench.verify(original['plan']['manifest'])
missing = {c['id'] for c in original['cases'] if c['summary']['ratioEligible'] and c['summary']['ratios'] is None}
assert missing == {'coverage-closures-64','coverage-closures-256',
    'coverage-list-pipeline-128','coverage-list-pipeline-512'}
fixed = {c['id']:c for c in repair['cases']}
assert set(fixed) == missing
cases = [copy.deepcopy(fixed.get(c['id'],c)) for c in original['cases']]
roles = list(original['plan']['roles'])
aggregate = bench.aggregate(cases,roles,original['plan']['reference'])
assert aggregate['complete']
ratios = [(c['id'],c['summary']['ratios']['candidate']) for c in cases if c['summary']['ratioEligible']]
family_ratios = list(aggregate['roles']['candidate']['families'].values())
fixed_batch = {role:sum(statistics.median(s['elapsedMs'] for s in c['samples'] if s['role']==role)
                       for c in original['cases']) for role in roles}
result = dict(complete=True, inputs=[bench.pin(__file__),*[bench.pin(p) for p in paths],
    bench.pin(ROOT/'experiments/phase169/broad-resolution.md'),original['plan']['manifest']],
    originalAggregate=original['aggregate'], aggregate=aggregate,
    repairedCases=sorted(missing), originalScale=1, repairScale=40,
    interpretation='Normalized per-call ratios; four predeclared low-resolution points rerun at equal40x repetitions for both images.',
    casesOver110=sum(v>1.1 for _,v in ratios),casesOver200=sum(v>2 for _,v in ratios),
    familyWeightedGeomean=math.exp(statistics.mean(math.log(v) for v in family_ratios)),
    originalFixedBatchMedianSumMs=fixed_batch,
    fixedBatchScope='Sum of per-case median timed intervals in original scale1 observations; no harness/process-start overhead, no mixed-scale clock.',
    worstRatios=sorted(ratios,key=lambda row:row[1],reverse=True),
    correctObservations=sum(len(c['samples']) for r in [original,repair] for c in r['cases']),
    scope='Actual native candidate versus Phase152; frozen45 corpus, not new upstream ratio or full-language guarantee.')
out = ROOT/'implementation/phase169/program-runtime.json'
assert not out.exists()
bench.save(out,result,fresh=True)
print(json.dumps({k:result[k] for k in ['aggregate','casesOver110','familyWeightedGeomean','correctObservations']}))
