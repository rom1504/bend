"""Matched ablation using already authenticated products and the frozen oracle."""
import argparse, importlib.util, os, subprocess, time
from pathlib import Path
ROOT = Path(__file__).resolve().parents[4]
spec = importlib.util.spec_from_file_location('oracle', ROOT/'selfhost/tools/performance/phase112/benchmark45/run.py')
O = importlib.util.module_from_spec(spec); spec.loader.exec_module(O)
p = argparse.ArgumentParser()
p.add_argument('--screen', nargs=2, action='append', required=True)
p.add_argument('--name', required=True); p.add_argument('--out', type=Path, required=True)
p.add_argument('--scale', type=int, default=8); p.add_argument('--rounds', type=int, default=4)
a = p.parse_args(); assert sorted(os.sched_getaffinity(0)) == [3]
out = a.out.resolve(); assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase125')
manifest = ROOT/'selfhost/tools/performance/phase112/benchmark45/manifest01.json'
counts = ROOT/'selfhost/tools/performance/phase112/benchmark45/upstream-50ms-profile01.json'
case = next(x for x in O.read(manifest)['cases'] if x['name'] == a.name)
c = dict(case, repetitions=O.read(counts)['cases'][a.name]['repetitions']*a.scale,
         warmups=O.read(counts)['cases'][a.name]['warmups'])
products = {}; inputs = [O.pin(__file__), O.pin(O.__file__), O.pin(manifest), O.pin(counts)]
for role, file in a.screen:
    s = O.read(file); assert s['complete']; inputs += [O.pin(file), *s['inputs']]
    products[role] = next(x['binary'] for x in s['rows'] if x['name']==a.name and x['role']=='candidate')
    for r in ['baseline', 'upstream']:
        b = next(x['binary'] for x in s['rows'] if x['name']==a.name and x['role']==r)
        assert r not in products or products[r] == b
        products[r] = b
for x in [*inputs, *products.values()]: O.verify(x)
out.mkdir(); report = dict(complete=False, inputs=inputs, products=products, case=c, rows=[])
save = lambda: O.save(out/'report.json', report)
save(); start = time.monotonic()
try:
    for rnd in range(a.rounds):
        roles = list(products); roles = roles[rnd%len(roles):]+roles[:rnd%len(roles)]
        for role in roles:
            cmd = [products[role]['file'], '--threads', '1', '--gpu', 'off', '--', str(c['repetitions']), str(c['warmups']), *map(str,c['runtimeArgs'])]
            t = time.monotonic(); child = subprocess.run(cmd, capture_output=True, timeout=30); wall = time.monotonic()-t
            stdout=out/f'{role}-{rnd}.stdout'; stderr=out/f'{role}-{rnd}.stderr'
            stdout.write_bytes(child.stdout); stderr.write_bytes(child.stderr)
            row = dict(role=role, round=rnd, command=cmd, binary=products[role], status=child.returncode, wallSeconds=wall, stdout=O.pin(stdout), stderr=O.pin(stderr))
            report['rows'].append(row); save()
            row['elapsedMs']=O.observation(child.stdout,child.stderr,child.returncode,c,wall); row['correct']=True; save()
    report['complete']=True
finally:
    report['seconds']=time.monotonic()-start; save()
