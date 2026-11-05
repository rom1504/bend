#!/usr/bin/env python3
"""Bounded three-path transport; run only inside the declared outer guard."""
import argparse, json, os, statistics, subprocess, sys, time
from pathlib import Path
sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT/'selfhost/tools/build'))
from common import pin, verify, require, write_json, fresh_output

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--plan', type=Path, required=True)
p.add_argument('--controls', type=Path, required=True)
a = p.parse_args()
plan = json.loads(a.plan.read_text())
controls = json.loads(a.controls.read_text())
require(controls['complete'] and controls['rawValuesComplete'], 'Complete raw controls required')
for v in plan['inputs'] + controls['inputs']: verify(v)
out = fresh_output(Path(plan['runRoot']), ROOT)
(out/'tmp').mkdir()
env = {k:v for k,v in os.environ.items() if not k.startswith('BEND_') and k not in ['BANGS','LD_PRELOAD','LD_AUDIT']}
env.update(plan['runtimeEnvironment']); env['TMPDIR'] = str(out/'tmp')
report = dict(kind='phase166-lookup-build-and-run', complete=False,
    inputs=[pin(__file__), pin(a.plan), pin(a.controls), *plan['inputs']],
    source=plan['source'], environment=plan['runtimeEnvironment'], jobs=[], runs=[],
    scope='Same source; distinct recorded runtimes/toolchain optimization policies. Whole-process elapsed includes startup/teardown. Finite oracle, not proof or full-compiler prediction.')
def save(): write_json(out/'report.json', report)
save()
try:
    for job in plan['jobs']:
        stdout = Path(job.get('stdout', out/(job['name']+'.stdout')))
        stderr = out/(job['name']+'.stderr')
        start = time.perf_counter()
        with stdout.open('xb') as so, stderr.open('xb') as se:
            got = subprocess.run(job['command'], cwd=ROOT, env=env, stdout=so, stderr=se, timeout=job['seconds'])
        report['jobs'].append(dict(name=job['name'], command=job['command'], seconds=time.perf_counter()-start,
            returncode=got.returncode, stdout=pin(stdout), stderr=pin(stderr)))
        save(); require(got.returncode == 0, 'Failed job '+job['name'])
    report['binaries'] = {k:pin(v) for k,v in plan['binaries'].items()}
    def execute(role, cycle):
        binary = report['binaries'][role]; verify(binary)
        command = [binary['file'], *plan['executionArgs']]
        start = time.perf_counter()
        got = subprocess.run(command, cwd=ROOT, env=env, capture_output=True, timeout=20)
        row = dict(role=role, cycle=cycle, command=command, seconds=time.perf_counter()-start,
            returncode=got.returncode, stdout=got.stdout.decode(errors='replace'), stderr=got.stderr.decode(errors='replace'))
        row['complete'] = got.returncode == 0 and got.stdout == plan['expectedStdout'].encode() and got.stderr == b''
        report['runs'].append(row); save(); require(row['complete'], 'Independent native output failed '+role)
    for role in ['qbe','c','bendc']: execute(role, 0)
    # These are resolved complete workloads only when each first sample exceeds
    # 30ms. Otherwise preserve controls and request a fresh larger source point.
    report['resolvedForTiming'] = all(r['seconds'] >= .030 for r in report['runs'])
    if report['resolvedForTiming']:
        for cycle, order in enumerate([['bendc','c','qbe'],['c','qbe','bendc'],['bendc','qbe','c']], 1):
            for role in order: execute(role, cycle)
        report['medians'] = {k:statistics.median(r['seconds'] for r in report['runs'] if r['role']==k) for k in report['binaries']}
    for v in report['inputs']: verify(v)
    report['complete'] = True
except Exception as e:
    report['error'] = repr(e); sys.exitcode = 1
finally:
    save(); print(json.dumps({k:report[k] for k in ['complete','resolvedForTiming','medians','error'] if k in report}))
if not report['complete']: raise SystemExit(1)
