#!/usr/bin/env python3
"""Live qualification, then three-way baseline/owned/chunks native comparison."""
import argparse
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
P = ROOT / 'selfhost/tools/performance'
sys.path.insert(0, str(P / 'phase88'))
from broad import guard, pin, save
from native_support import authenticate, native_args, DEFAULT_CACHE

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('image', type=Path)
p.add_argument('out', type=Path)
p.add_argument('--calls', choices=[1, 5], type=int, default=1)
p.add_argument('--rounds', type=int, default=2)
p.add_argument('--cases', default='small,numeric_closed,lexer_original,map_closed,functions65,unicode')
p.add_argument('--live-evidence', type=Path, help='Reuse a prior exact live gate for this same image')
a = p.parse_args()
out = a.out.resolve()
out.mkdir(parents=True, exist_ok=False)
old = authenticate(ROOT / 'selfhost/build/phase88/compiler-native02', DEFAULT_CACHE)
new = authenticate(a.image, None)
owned = authenticate(ROOT / 'selfhost/build/phase89/compiler-owned01', None)
owned_gate = json.loads((ROOT / 'selfhost/build/phase89/owned-cold01/report.json').read_text())
assert owned_gate['complete'] and owned_gate['passed'] and owned_gate['new'] == owned
assert new['source']['sha256'] == '670204c4898753c29b648ca77cc19c2b3ad33764bfdf2f55598e8957a2310751'
for k in ['base', 'runtime', 'runtimeParts', 'template', 'effectsDir', 'effects']:
    assert old[k] == new[k], k
baseline = json.loads((ROOT / 'selfhost/build/phase88/screen01/report.json').read_text())
cases = a.cases.split(',')
sources = {n: pin(baseline['cases'][n]) for n in set(cases + ['small', 'map_closed', 'unicode'])}
report = dict(complete=False, passed=False, method=pin(__file__), old=old, owned=owned, new=new,
              sourcePins=sources, calls=a.calls, rounds=a.rounds, cases=cases, live=[], rows=[],
              scope='Experimental prepared-cache comparison after exact live checks; this does not alter the public Phase88 cache-consumer admission.')
save(out / 'report.json', report)

def run(name, role, auth, calls, round_number):
    source = sources[name]
    assert pin(source['file']) == source
    prefix = out / f'{round_number}-{name}-{role}'
    job = guard(Path(str(prefix) + '-guard'), native_args(auth, source['file'], prefix, calls), 90)
    logs = (Path(job['guard']) / 'stderr.log').read_text()
    outputs = [pin(Path(str(prefix) + f'.{i}.c')) for i in range(1, calls + 1) if Path(str(prefix) + f'.{i}.c').exists()]
    oracle = next(r['outputs'][0]['sha256'] for r in baseline['rows'] if r['case'] == name and r['role'] == 'b2')
    exact = len(outputs) == calls and all(x['sha256'] == oracle for x in outputs)
    process = json.loads((Path(job['guard']) / 'process.json').read_text())
    return dict(case=name, role=role, round=round_number, job=job, outputs=outputs, exact=exact,
                requestMs=list(map(int, re.findall(r'request=\d+ request_ms=(\d+)', logs))),
                preparation=dict(re.findall(r'(base_prepare_ms|runtime_prepare_ms)=(\d+)', logs)),
                processWallSeconds=process['wallSeconds'], peakRssBytes=process['peakTreeRssBytes'])

if a.live_evidence:
    previous = json.loads(a.live_evidence.read_text())
    assert previous['new'] == new and previous['complete'] and previous['passed']
    assert {r['case'] for r in previous['live']} == {'small', 'map_closed', 'unicode'}
    assert all(r['exact'] and r['job']['pass_'] for r in previous['live'])
    report['live'] = previous['live']
    report['liveEvidence'] = pin(a.live_evidence)
else:
    for name in ['small', 'map_closed', 'unicode']:
        row = run(name, 'candidate-live', new, 1, 0)
        report['live'].append(row)
        save(out / 'report.json', report)
        assert row['exact'] and row['job']['pass_'], 'Live qualification failed'

# Only the benchmark harness opts this explicitly bound derivative into the
# already authenticated carrier; the public launcher still refuses it.
cached = dict(new, cache=old['cache'])
for rnd in range(a.rounds):
    for i, name in enumerate(cases):
        roles = [('baseline', old), ('owned', dict(owned, cache=old['cache'])), ('chunks', cached)]
        order = roles[i % 3:] + roles[:i % 3]
        if rnd % 2:
            order.reverse()
        for role, auth in order:
            row = run(name, role, auth, a.calls, rnd + 1)
            report['rows'].append(row)
            save(out / 'report.json', report)
            print(json.dumps({k: row[k] for k in ['round', 'case', 'role', 'exact', 'requestMs', 'processWallSeconds']}), flush=True)
            assert row['exact'] and row['job']['pass_'], 'Cached comparison failed'
assert authenticate(a.image, None) == new
assert authenticate(ROOT / 'selfhost/build/phase89/compiler-owned01', None) == owned
assert authenticate(ROOT / 'selfhost/build/phase88/compiler-native02', DEFAULT_CACHE) == old
report.update(complete=True, passed=True)
save(out / 'report.json', report)
