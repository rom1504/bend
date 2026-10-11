#!/usr/bin/env python3
"""P68-016 saved-binary follow-up: three balanced rotations, no compilation."""
import importlib.util
import json
import os
from pathlib import Path
import statistics
import time

ROOT = Path(__file__).resolve().parents[5]
spec = importlib.util.spec_from_file_location('support', ROOT/'selfhost/tools/performance/programs/support.py')
S = importlib.util.module_from_spec(spec)
spec.loader.exec_module(S)
raw = ROOT/'selfhost/build/phase68'
read = lambda p: json.loads(Path(p).read_text())
first = raw/'scalar-array-diagnostic01'
plan = read(first/'plan.json')
result = read(first/'execution.json')
assert result['complete'] and result['allTimingQualified']
up_path = ROOT/'selfhost/build/phase67/native-baseline02/report.json'
up = read(up_path)
assert up['complete']
parent = next(r for r in up['records'] if r['case'] == 'array' and r['role'] == 'upstream')
assert parent['correct'] and parent['source'] == plan['parent']['source']
recipe = read(plan['recipe']['path'])
up_recipe = read(up['recipe']['path'])
for key in ('clang', 'clangArgs', 'linkArgs', 'cpu', 'compilerEnvironment', 'upstreamCommit'):
    assert recipe[key] == up_recipe[key], key
assert {k: os.environ.get(k) for k in plan['compilerEnvironment']} == plan['compilerEnvironment']
arms = {'baseline': plan['parent']['executable'],
        'combined': next(r['executable'] for r in result['builds'] if r['role'] == 'combined'),
        'upstream': parent['executable']}
pins = [S.identity(__file__), S.identity(first/'plan.json'), S.identity(first/'execution.json'),
        S.identity(up_path), up['recipe'], plan['recipe'], *plan['actualInputs'],
        *arms.values(), parent['nativeSource'], parent['emissionReceipt'], parent['source']]
for pin in pins:
    assert S.identity(pin['path']) == pin
out = raw/'scalar-array-upstream01'
out.mkdir(exist_ok=False)
n, warm = 61440, 7680
expected = plan['measurements'][0]['expected']
schedule = [dict(role=role, round=round) for round in range(3)
            for role in (list(arms)[round:]+list(arms)[:round])]
S.save(out/'plan.json', dict(pins=pins, repetitions=n, warmups=warm, expected=expected,
    schedule=schedule, scope='Saved C binaries, identical source/Clang flags; three position-balanced rotations. No new emission or general conformance.'))
report = dict(complete=False, started=time.time(), plan=S.identity(out/'plan.json'), records=[])
try:
    with S.ExecutionGuard(rss_mib=2048, available_mib=4096) as guard:
        for item in schedule:
            dest = out/(item['role']+'-r'+str(item['round']))
            command = ['taskset', '-c', '3', 'python3', str(ROOT/'selfhost/tools/performance/phase46/execute.py'),
                str(dest/'child.json'), arms[item['role']]['path'], '--threads', '1', '--gpu', 'off', '--', str(n), str(warm)]
            row = dict(item)
            report['records'].append(row)
            row['process'] = guard.run(command, dest, time.monotonic()+45)
            row['child'] = read(dest/'child.json')
            words = row['child']['stdout'].strip().splitlines()
            row['correct'] = (row['process']['complete'] and row['child']['returncode'] == 0
                and not row['child']['stderr'] and len(words) == 4
                and all(w.isdecimal() for w in words) and list(map(int, words[:3])) == expected)
            assert row['correct'], row
            row['elapsedMs'] = int(words[3])
            row['qualified'] = 100 <= row['elapsedMs'] <= row['child']['processSeconds']*1000+2
            assert row['qualified'], row
            S.save(out/'report.json', report)
    for pin in pins:
        assert S.identity(pin['path']) == pin
    report['mediansMs'] = {role: statistics.median(r['elapsedMs'] for r in report['records'] if r['role'] == role) for role in arms}
    report['complete'] = True
finally:
    report['finished'] = time.time()
    S.save(out/'report.json', report)
print(json.dumps({k: report[k] for k in ('complete', 'mediansMs')}))
