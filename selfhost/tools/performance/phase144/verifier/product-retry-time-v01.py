"""Root-only adaptive paired runtime, including the entire verifier slice."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import statistics
import subprocess
import time

ROOT = Path(__file__).resolve().parents[5]


def pin(path):
    path = Path(path).resolve()
    body = path.read_bytes()
    return dict(file=str(path), bytes=len(body), sha256=hashlib.sha256(body).hexdigest())


p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--plan', type=Path, required=True)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()
out = a.out.resolve()
assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase144')
assert sorted(os.sched_getaffinity(0)) == [3]
assert not any(k in os.environ for k in ('LD_PRELOAD', 'BEND_SAMPLE_OUT', 'BEND_SAMPLE_CONTEXT_OUT', 'BEND_PROFILE_EVENTS_OUT', 'BEND_PROFILE_COUNTERS'))
plan = json.loads(a.plan.read_text())
assert plan['complete'] and plan['kind'] == 'phase144-product-retry-native-plan'
emission = json.loads(Path(plan['emission']).read_text())
assert emission['complete'] and emission['source'] == plan['source']
inputs = [pin(__file__), pin(a.plan), *plan['inputs'], pin(plan['emission'])]
for mode in ['old', 'new']:
    variant = plan['variants'][mode]
    build = json.loads(Path(variant['build']).read_text())
    assert build['complete'] and build['outputExact']
    qbe = emission['variants'][mode]['qbe']
    assert qbe == pin(variant['qbe']) and qbe in build['inputs']
    assert plan['runtime'] in build['inputs'] and plan['expected'] in build['inputs']
    assert build['binary'] == pin(variant['binary'])
    inputs += [pin(variant['build']), build['binary'], qbe]
for x in inputs:
    assert pin(x['file']) == x
expected = Path(plan['expected']['file']).read_bytes()
assert expected == b'2048\n'
out.mkdir(parents=True)
report = dict(kind='phase144-product-retry-complete-native-verifier-timing', complete=False,
              inputs=inputs, rows=[], policy='Run one alternating pair; extend to three total pairs only if both first executions take less than3s.',
              scope='Same compact verifier Bend source and input data, baseline vs additive product retry. Full metadata construction, schema/flow/joins, reclamation and process shutdown included. No original-compiler speed claim.')
save = lambda: (out/'report.json').write_text(json.dumps(report, indent=2)+'\n')
save()
try:
    for round in range(3):
        if round and not report['extendToThree']:
            break
        order = ['old', 'new'] if round % 2 == 0 else ['new', 'old']
        row = dict(round=round, order=order, calls=[])
        report['rows'].append(row)
        for mode in order:
            command = [plan['variants'][mode]['binary'], '--threads', '1', '--gpu', 'off']
            stdout, stderr = out/f'{round}-{mode}.stdout', out/f'{round}-{mode}.stderr'
            t = time.monotonic()
            with stdout.open('xb') as so, stderr.open('xb') as se:
                child = subprocess.run(command, cwd=ROOT, stdout=so, stderr=se, timeout=30)
            call = dict(mode=mode, seconds=time.monotonic()-t, command=command,
                        exitCode=child.returncode, stdout=pin(stdout), stderr=pin(stderr))
            row['calls'].append(call)
            save()
            assert child.returncode == 0 and stderr.stat().st_size == 0 and stdout.read_bytes() == expected
            call['outputExact'] = True
            save()
        times = {x['mode']: x['seconds'] for x in row['calls']}
        row['ratio'] = times['new']/times['old']
        if round == 0:
            report['extendToThree'] = max(times.values()) < 3
        save()
    report['medians'] = {mode: statistics.median(c['seconds'] for r in report['rows'] for c in r['calls'] if c['mode'] == mode) for mode in ['old', 'new']}
    report['ratioOfMedians'] = report['medians']['new']/report['medians']['old']
    report['medianPairedRatio'] = statistics.median(r['ratio'] for r in report['rows'])
    for x in inputs:
        assert pin(x['file']) == x
    report['complete'] = True
except BaseException as error:
    report['error'] = repr(error)
    save()
    raise
finally:
    save()
    print(json.dumps({k: report[k] for k in ['complete', 'extendToThree', 'medians', 'ratioOfMedians', 'error'] if k in report}))
