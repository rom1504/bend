"""Root-run build: exact Phase126 runtime plus the unchanged scalar-borrow guard."""
import argparse
import hashlib
import json
import subprocess
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
BASE_REPORT_SHA256 = '5b5f57ea8d35fc2ad5c03f2bb3f854d0513b2f9d8ea12211505805d544860880'
GUARD_SHA256 = '85d7f3a6a99f3864bdb7b6fd822d854061c87b59f1d83d9b0fb4650283f29ce3'


def pin(path):
    path = Path(path).resolve()
    data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def verify(item):
    assert pin(item['file']) == item, 'Changed input: ' + item['file']


parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--out', type=Path, required=True)
args = parser.parse_args()
selection_file = ROOT / 'implementation/phase126/candidate.json'
selection = json.loads(selection_file.read_text())
assert selection['complete'] and selection['nativeQualified']
base_report_file = ROOT / 'selfhost/build/phase126/runtime-divmod01/report.json'
base_report_pin = pin(base_report_file)
assert base_report_pin['sha256'] == BASE_REPORT_SHA256, 'Unexpected parent runtime report'
assert selection['runtimeReport'] == base_report_pin
base = json.loads(base_report_file.read_text())
assert base['complete'] and base['kind'] == 'phase126-nat-divmod-additive-runtime'
assert base['object'] == selection['runtime']
extension = pin(ROOT / 'selfhost/tools/performance/phase118/runtime-scalar-borrow.c')
assert extension['sha256'] == GUARD_SHA256, 'Scalar guard must remain byte-identical'
for item in [*base['inputs'], base['source'], base['object'], extension]:
    verify(item)

base_dir = Path(base['source']['file']).parent
compiler = Path(base['command'][0])
assert len(base['command']) == 8
assert base['command'][1:5] == ['-O2', '-std=gnu11', '-ffp-contract=off', '-c']
assert base['command'][5:] == [base['source']['file'], '-o', base['object']['file']]
assert pin(compiler) in base['inputs'], 'Unpinned native compiler'
out = args.out.resolve()
assert not out.exists() and out.is_relative_to(ROOT / 'selfhost/build/phase128')
headers = []
for name in ['runtime.h', 'primitives.h']:
    current = pin(base_dir / name)
    original = next(item for item in base['inputs'] if Path(item['file']).name == name)
    assert (current['bytes'], current['sha256']) == (original['bytes'], original['sha256'])
    headers.append(current)
inputs = [pin(__file__), pin(selection_file), base_report_pin,
          *base['inputs'], base['source'], base['object'], *headers, extension]
inputs = list({item['file']: item for item in inputs}.values())
for item in inputs:
    verify(item)

out.mkdir(parents=True)
(out / 'runtime.c').write_bytes(Path(base['source']['file']).read_bytes()
                               + b'\n' + Path(extension['file']).read_bytes())
for header in headers:
    (out / Path(header['file']).name).write_bytes(Path(header['file']).read_bytes())
(out / 'method.py').write_bytes(Path(__file__).read_bytes())
command = [str(compiler), '-O2', '-std=gnu11', '-ffp-contract=off', '-c',
           str(out / 'runtime.c'), '-o', str(out / 'runtime.o')]
report = dict(complete=False, kind='phase128-scalar-borrow-additive-runtime',
              inputs=inputs, source=pin(out / 'runtime.c'), command=command,
              parent=base['object'], extension=extension,
              scope='Exact qualified Phase126 runtime plus unchanged Phase118 scalar-borrow guard; '
                    'same headers, compiler and flags. Runtime object only; no production selection change.')


def save():
    (out / 'report.json').write_text(json.dumps(report, indent=2) + '\n')


save()
started = time.monotonic()
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
    save()
    print(json.dumps(report))
raise SystemExit(0 if report['complete'] else 1)
