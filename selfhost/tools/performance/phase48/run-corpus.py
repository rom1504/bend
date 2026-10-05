#!/usr/bin/env python3
"""Phase47 serial corpus queue with explicit Phase48 bundle arguments."""
import argparse, hashlib, json, subprocess, sys
from pathlib import Path

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[4]
TOOLS = ROOT / 'selfhost/tools/performance'
CATALOG = TOOLS / 'phase37/catalog.json'
PARENT = TOOLS / 'phase47/run-corpus.py'
assert hashlib.sha256(PARENT.read_bytes()).hexdigest() == '9abc7ad1124ab7433835f4077f4d0115ea148b5dd75df6234a5d2c529ff05b94'
NODE = '/home/ai/.nvm/versions/node/v24.18.0/bin/node'
def identity(p):
    return dict(path=str(p.resolve()), sha256=hashlib.sha256(p.read_bytes()).hexdigest())

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('baseline', type=Path); p.add_argument('candidate', type=Path); p.add_argument('out', type=Path)
a = p.parse_args()
a.out = a.out.resolve()
assert a.out.is_relative_to(ROOT / 'selfhost/build/phase48') and not a.out.exists()
ids = [c['id'] for c in json.loads(CATALOG.read_text())['cases']]
assert len(ids) == len(set(ids)) == 45
commands = [[sys.executable, str(TOOLS / 'programs/run.py'), '--catalog', str(CATALOG),
    '--baseline', str(a.baseline.resolve(strict=True)), '--candidate', str(a.candidate.resolve(strict=True)),
    '--cases', ','.join(ids[i*15:(i+1)*15]), '--budget', '600', '--out', str(a.out / f'runtime-{i}'),
    '--node', NODE, '--cpu', '3', '--rss-mib', '2048', '--available-mib', '4096'] for i in range(3)]
a.out.mkdir(parents=True)
(a.out / 'consumed-run-corpus.py').write_bytes(Path(__file__).read_bytes())
(a.out / 'plan.json').write_text(json.dumps(dict(kind='phase48-full-corpus-queue',
    producer=identity(Path(__file__)), parent=identity(PARENT), inputs=[identity(x) for x in [CATALOG, a.baseline, a.candidate]],
    commands=commands, scope='Same Phase47 serial runner, three 15-point 600-second presets; ordinary five rounds/raytrace three. No nested resource supervisor, compilation or profiling.'), indent=2)+'\n')
for i, command in enumerate(commands):
    print('Starting full batch', i, flush=True)
    subprocess.run(command, cwd=ROOT, check=True)
subprocess.run([sys.executable, str(TOOLS / 'phase44/summarize-runtime.py'), str(CATALOG), str(a.baseline.resolve()),
    str(a.candidate.resolve()), str(a.out / 'summary.json'), *[str(a.out / f'runtime-{i}/report.json') for i in range(3)]], cwd=ROOT, check=True)
