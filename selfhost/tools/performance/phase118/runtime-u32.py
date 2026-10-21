"""Isolate upstream's native U32 quotient policy on the frozen bank runtime."""
import argparse, hashlib, json, subprocess, time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]

def pin(path):
    path = Path(path).resolve()
    data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())

parser = argparse.ArgumentParser()
parser.add_argument('--out', type=Path, required=True)
args = parser.parse_args()
parent = ROOT / 'selfhost/build/phase118/runtime-bank01'
old = json.loads((parent / 'report.json').read_text())
assert old['complete']
for record in [*old['inputs'], old['source'], old['object']]:
    assert pin(record['file']) == record
source = (parent / 'runtime.c').read_text()
before = '#define U32_QUO(a, b) ' + chr(92) + chr(10) + '  ((a) / 2 / (b) * 2 + ((a) - (a) / 2 / (b) * 2 * (b) >= (b)))'
after = '#ifdef __METAL_VERSION__\n' + before + '\n#else\n#define U32_QUO(a, b) ((a) / (b))\n#endif'
assert source.count(before) == 1
source = source.replace(before, after)
out = args.out.resolve()
assert not out.exists() and out.is_relative_to(ROOT / 'selfhost/build/phase118')
out.mkdir()
(out / 'runtime.c').write_text(source)
for name in ['runtime.h', 'primitives.h']:
    (out / name).write_bytes((parent / name).read_bytes())
compiler = Path('/usr/bin/gcc').resolve()
command = [str(compiler), '-O2', '-std=gnu11', '-ffp-contract=off', '-c', str(out / 'runtime.c'), '-o', str(out / 'runtime.o')]
report = dict(complete=False, kind='phase118-native-u32-quotient-runtime',
    inputs=[pin(__file__), pin(parent / 'report.json'), old['source'], pin(parent / 'runtime.h'), pin(parent / 'primitives.h'), pin(compiler)],
    source=pin(out / 'runtime.c'), command=command, changes=[dict(before=before, after=after)],
    scope='One U32_QUO macro change, matching upstream CPU/Metal distinction. Existing divisor-zero branches, casts, arity checks, ownership and bank policies are unchanged.')
def save():
    (out / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
save()
start = time.monotonic()
with (out / 'stdout').open('xb') as stdout, (out / 'stderr').open('xb') as stderr:
    child = subprocess.run(command, stdout=stdout, stderr=stderr, timeout=45)
report.update(complete=child.returncode == 0, status=child.returncode, seconds=time.monotonic() - start)
if report['complete']:
    report['object'] = pin(out / 'runtime.o')
save()
print(json.dumps(dict(complete=report['complete'], seconds=report['seconds'])))
raise SystemExit(child.returncode)
