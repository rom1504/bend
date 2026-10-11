"""Join 27 qualified clean requests and separately observed checked-entry profiles."""
import argparse, hashlib, importlib.util, json, math, statistics
from pathlib import Path
p = argparse.ArgumentParser()
for name in ['plan', 'profiles', 'out']:
    p.add_argument('--'+name, type=Path, required=True)
a = p.parse_args()
assert not a.out.exists()
inputs = []
def pin(p):
    p = Path(p).resolve()
    r = dict(file=str(p), sha256=hashlib.sha256(p.read_bytes()).hexdigest(), bytes=p.stat().st_size)
    inputs.append(r)
    return r
def read(p):
    return json.loads(Path(pin(p)['file']).read_text())
plan_pin, plan = pin(a.plan), read(a.plan)
for identity in plan['inputs']:
    assert pin(identity['file']) == identity
clean = []
for job in [j for j in plan['jobs'] if j['action']=='request' and not j['profile']]:
    f = a.plan.parent/'runs'/job['name']/'report.json'
    r = read(f)
    assert r['complete'] and r['pass'] and r['exactC'] and r['inputsUnchanged'] and r['plan']==plan_pin
    assert pin(r['output']['file'])==r['output'] and pin(r['oracle']['file'])==r['oracle']
    guard = read(f.parent.with_name(f.parent.name+'-guard')/'process.json')
    assert guard['complete'] and guard['returncode']==0
    clean.append(dict(job=job, report=pin(f), timings=r['timings'], guardWallSeconds=guard['wallSeconds']))
assert len(clean)==27
rows = []
for case in plan['cases']:
    times = {role:statistics.median(r['timings']['requestMs'] for r in clean if r['job']['case']==case and r['job']['role']==role) for role in plan['roles']}
    rows.append(dict(case=case, requestMediansMs=times, ratios={role:times[role]/times['typescript'] for role in ['b1','b2']}))
root = Path(__file__).resolve().parents[5]
method = root/'selfhost/tools/performance/phase68/compilation/analyze.py'
spec = importlib.util.spec_from_file_location('A', method)
A = importlib.util.module_from_spec(spec);spec.loader.exec_module(A)
profiles = []
pr = read(a.profiles/'report.json');assert pr['complete']
for row in pr['jobs']:
    r = read(row['report']['path'])
    assert r['complete'] and r['pass'] and r['exactC'] and r['inputsUnchanged']
    assert r['stages']['nc_compile_checked']['calls']>0
    profiles.append(dict(job=r['job'], report=pin(row['report']['path']), stages=r['stages'], cpu=A.profile_summary(read(r['profile']['file']), {})))
assert len(profiles)==4
result = dict(complete=True, clean=clean, rows=rows, profiles=profiles,
    requestGeomeans={role:math.prod(r['ratios'][role] for r in rows)**(1/len(rows)) for role in ['b1','b2']},
    method=pin(__file__), profileAnalysis=pin(method), inputs=inputs,
    scope='27 balanced exact-C requests with prepared Base, excluding imports and Clang; four diagnostic profiles use the checked-entry successor instead of the original profile jobs. These are not program runtime or full-corpus compilation measurements.')
a.out.write_text(json.dumps(result, indent=2)+'\n')
print(json.dumps(dict(rows=rows, requestGeomeans=result['requestGeomeans'])))
