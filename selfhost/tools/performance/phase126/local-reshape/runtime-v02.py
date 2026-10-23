"""Root-run build of one pinned additive helper on exact selected Phase125 runtime."""
import argparse
import hashlib
import json
import subprocess
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
HERE = Path(__file__).resolve().parent

def pin(p):
    p = Path(p).resolve()
    data = p.read_bytes()
    return dict(file=str(p), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())

def verify(p):
    assert pin(p['file']) == p, 'Changed input: ' + p['file']

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()
authority_file = HERE / 'manifest04.json'
authority = json.loads(authority_file.read_text())
selection_file = ROOT / 'implementation/phase125/candidate.json'
selection = json.loads(selection_file.read_text())
assert selection['complete'] and selection['nativeQualified']
verify(selection['runtimeReport']); verify(selection['runtime'])
base_report_file = Path(selection['runtimeReport']['file'])
base = json.loads(base_report_file.read_text())
assert base['complete'] and base['kind'] == 'phase125-additive-runtime'
assert base['object'] == selection['runtime']
for item in [*base['inputs'], base['source'], base['object'], authority['runtime']]:
    verify(item)
base_dir = Path(base['source']['file']).parent
compiler = Path(base['command'][0])
assert base['command'][1:5] == ['-O2', '-std=gnu11', '-ffp-contract=off', '-c']
assert len(base['command']) == 8
assert pin(compiler) in base['inputs'], 'Unpinned native compiler'
out = a.out.resolve()
assert not out.exists() and out.is_relative_to(ROOT / 'selfhost/build/phase126')
headers = []
for name in ['runtime.h', 'primitives.h']:
    current = pin(base_dir / name)
    original = next(x for x in base['inputs'] if Path(x['file']).name == name)
    assert current['bytes'] == original['bytes'] and current['sha256'] == original['sha256']
    headers.append(current)
inputs = [pin(__file__), pin(authority_file), pin(selection_file), selection['runtimeReport'],
          *base['inputs'], base['source'], base['object'], *headers, authority['runtime']]
inputs = list({x['file']: x for x in inputs}.values())
for item in inputs:
    verify(item)
out.mkdir(parents=True)
(out / 'runtime.c').write_bytes(Path(base['source']['file']).read_bytes() + b'\n' + Path(authority['runtime']['file']).read_bytes())
for header in headers:
    (out / Path(header['file']).name).write_bytes(Path(header['file']).read_bytes())
(out / 'method.py').write_bytes(Path(__file__).read_bytes())
command = [str(compiler), '-O2', '-std=gnu11', '-ffp-contract=off', '-c', str(out / 'runtime.c'), '-o', str(out / 'runtime.o')]
report = dict(complete=False, kind='phase126-local-reshape-additive-runtime', inputs=inputs,
              source=pin(out / 'runtime.c'), command=command, parent=base['object'],
              extension=authority['runtime'], scope='Exact qualified Phase125 runtime bytes plus one reviewed raw-only helper; unchanged flags and compiler. This builds the runtime object only, not a target program or self-hosted compiler.')
save = lambda: (out / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
save(); started = time.monotonic()
try:
    with (out / 'stdout').open('xb') as stdout, (out / 'stderr').open('xb') as stderr:
        child = subprocess.run(command, stdout=stdout, stderr=stderr, timeout=45)
    report.update(status=child.returncode, complete=child.returncode == 0)
    if report['complete']:
        report['object'] = pin(out / 'runtime.o')
    for item in inputs:
        verify(item)
except Exception as error:
    report.update(complete=False, error=str(error))
finally:
    report['seconds'] = time.monotonic() - started
    save(); print(json.dumps(report))
raise SystemExit(0 if report['complete'] else 1)
