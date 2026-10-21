"""Longer original-source timing using authenticated, already-built products."""
import argparse, importlib.util, os, subprocess, time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
spec = importlib.util.spec_from_file_location('oracle', ROOT/'selfhost/tools/performance/phase112/benchmark45/run.py')
O = importlib.util.module_from_spec(spec); spec.loader.exec_module(O)
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--screen', type=Path, required=True)
p.add_argument('--out', type=Path, required=True)
p.add_argument('--names', nargs='+', required=True)
p.add_argument('--factor', type=int, default=20)
a = p.parse_args()
assert sorted(os.sched_getaffinity(0)) == [3] and 1 <= a.factor <= 20
out = a.out.resolve()
assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase121')
screen = O.read(a.screen); assert screen['complete']
manifest = ROOT/'selfhost/tools/performance/phase112/benchmark45/manifest01.json'
cases = O.read(manifest)['cases']
out.mkdir()
r = dict(complete=False, inputs=[O.pin(__file__), O.pin(O.__file__), O.pin(a.screen), O.pin(manifest)], rows=[],
         scope='Same built original-source products and independent output/count oracle; repetitions multiplied equally for all roles. No build or compiler timing.')
save = lambda: O.save(out/'report.json', r)
start = time.monotonic(); save()
for name in a.names:
    case = next(c for c in cases if c['name'] == name)
    sources = {role: next(x for x in screen['rows'] if x['name']==name and x['role']==role) for role in ['candidate','baseline','upstream']}
    for role, row in sources.items():
        assert row['correct']; O.verify(row['binary']); r['inputs'].append(row['binary'])
    for rnd in range(3):
        roles = list(sources); roles = roles[rnd:] + roles[:rnd]
        for role in roles:
            source = sources[role]; cmd = source['command'].copy(); pos = cmd.index('--')+1
            cmd[pos] = str(int(cmd[pos])*a.factor)
            c = dict(case, repetitions=int(cmd[pos]), warmups=int(cmd[pos+1]))
            t = time.monotonic(); child = subprocess.run(cmd, capture_output=True, timeout=30); wall = time.monotonic()-t
            stem = f'{name}-{role}-{rnd}'
            (out/(stem+'.stdout')).write_bytes(child.stdout); (out/(stem+'.stderr')).write_bytes(child.stderr)
            row = dict(name=name, role=role, round=rnd, command=cmd, binary=source['binary'], wallSeconds=wall,
                       status=child.returncode, stdout=O.pin(out/(stem+'.stdout')), stderr=O.pin(out/(stem+'.stderr')))
            r['rows'].append(row); save()
            row.update(elapsedMs=O.observation(child.stdout,child.stderr,child.returncode,c,wall), correct=True); save()
for item in r['inputs']: O.verify(item)
r.update(complete=True, seconds=time.monotonic()-start); save()
