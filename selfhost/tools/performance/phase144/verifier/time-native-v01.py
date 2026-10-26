"""Measure already built verifier slices; root must apply the process guard."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess
import statistics
import time

ROOT = Path(__file__).resolve().parents[5]


def pin(p):
    p = Path(p).resolve()
    b = p.read_bytes()
    return dict(file=str(p), bytes=len(b), sha256=hashlib.sha256(b).hexdigest())


p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--plan', type=Path, required=True)
p.add_argument('--out', type=Path, required=True)
p.add_argument('--rounds', type=int, default=3)
a = p.parse_args()
assert 1 <= a.rounds <= 9
out = a.out.resolve()
assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase144')
assert sorted(os.sched_getaffinity(0)) == [3], 'Use the root CPU3 guard'
assert not any(k in os.environ for k in ('LD_PRELOAD','BEND_SAMPLE_OUT','BEND_SAMPLE_CONTEXT_OUT','BEND_PROFILE_EVENTS_OUT','BEND_PROFILE_COUNTERS'))
plan = json.loads(a.plan.read_text())
assert plan['complete'] and plan['kind'] == 'phase144-extracted-native-verifier-plan'
inputs = [pin(__file__), pin(a.plan), *plan['inputs']]
variants = plan['variants']
for mode in ['old', 'new']:
    v = variants[mode]
    build = json.loads(Path(v['build']).read_text())
    emission = json.loads(Path(v['emission']).read_text())
    assert build['complete'] and build['outputExact'] and emission['complete']
    assert build['binary'] == pin(v['binary'])
    assert emission['source'] == v['source'] == pin(v['source']['file'])
    assert emission['product'] == pin(v['qbe'])
    assert emission['product'] in build['inputs']
    assert v['expected'] == pin(v['expected']['file'])
    inputs.extend([pin(v['build']), pin(v['emission']), build['binary'], emission['product'], v['source'], v['expected']])
for x in inputs:
    assert pin(x['file']) == x
out.mkdir(parents=True)
report = dict(kind='phase144-native-complete-verifier-slice-timing', complete=False, inputs=inputs,
    family=plan['datum']['family'], repeats=plan['datum']['repeats'], rows=[],
    scope='Fresh-process alternating complete native slice execution, including static input setup, all metadata table construction, local schemas, statements, branch joins, reclamation and process shutdown. Does not isolate lookup latency or establish full compiler request gain.')
save = lambda: (out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
save()
try:
    for round in range(a.rounds):
        order = ['old', 'new'] if round % 2 == 0 else ['new', 'old']
        row = dict(round=round, order=order, calls=[])
        report['rows'].append(row)
        for mode in order:
            v = variants[mode]
            command = [v['binary'], '--threads', '1', '--gpu', 'off']
            stdout, stderr = out/f'{round}-{mode}.stdout', out/f'{round}-{mode}.stderr'
            start = time.monotonic()
            with stdout.open('xb') as so, stderr.open('xb') as se:
                child = subprocess.run(command, stdout=so, stderr=se, cwd=ROOT, timeout=30)
            seconds = time.monotonic()-start
            call = dict(mode=mode, command=command, seconds=seconds, exitCode=child.returncode,
                stdout=pin(stdout), stderr=pin(stderr))
            row['calls'].append(call)
            save()
            assert child.returncode == 0 and stderr.stat().st_size == 0
            assert stdout.read_bytes() == Path(v['expected']['file']).read_bytes()
            call['outputExact'] = True
            save()
        times = {c['mode']: c['seconds'] for c in row['calls']}
        row['ratio'] = times['new']/times['old']
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
    print(json.dumps({k:report[k] for k in ['complete','family','medians','ratioOfMedians','error'] if k in report}))
