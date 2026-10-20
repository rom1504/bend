#!/usr/bin/env python3
"""Root-run serial width control gate; all program lowering stays in Bend."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess
import time

ROOT = Path(__file__).resolve().parents[5]
HERE = Path(__file__).resolve().parent
parser = argparse.ArgumentParser()
parser.add_argument('--api', required=True, type=Path)
parser.add_argument('--prepared', required=True, type=Path)
parser.add_argument('--out', required=True, type=Path)
args = parser.parse_args()
assert sorted(os.sched_getaffinity(0)) == [3], 'root CPU3 lane required'
out = args.out.resolve()
assert out.is_relative_to(ROOT / 'selfhost/build/phase113') and not out.exists()
out.mkdir(parents=True)


def pin(file):
    file = Path(file).resolve()
    raw = file.read_bytes()
    return dict(file=str(file), bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


bun = ROOT / 'selfhost/.bootstrap/bun-1.4.3/bun'
qbe = ROOT / 'selfhost/build/phase108/toolchain/qbe-1.3/qbe'
gcc = Path('/usr/bin/x86_64-linux-gnu-gcc-10')
assembler = Path('/usr/bin/x86_64-linux-gnu-as')
assert pin(qbe)['sha256'] == '1eca24288f9574ad57032ac88f11c3f74ced605838749226d77a9acd4443e5f4'
assert pin(gcc)['sha256'] == '693abcb42e67fb871673f258a3644257ca69a209691ec4d8137a42442834bd19'
assert pin(assembler)['sha256'] == 'fac4e966afe9223dbab23aa15d27d144af81de4a44c8cad97c1dde290adb9493'
prepared = args.prepared.resolve()
manifest = json.loads((prepared / 'manifest.json').read_text())
assert manifest['complete'] and manifest['observations'] == 128
for item in manifest['inputs'] + manifest['outputs']:
    assert pin(item['file']) == item, 'prepared pin changed'
report = dict(kind='phase113-width-native-controls', complete=False,
              inputs=[pin(p) for p in [__file__, HERE / 'emit-controls.mjs', args.api,
                  args.api.parent / 'report.json', prepared / 'manifest.json',
                  prepared / 'harness.c', prepared / 'expected.stdout',
                  bun, qbe, gcc, assembler]], jobs=[])


def save():
    (out / 'report.json').write_text(json.dumps(report, indent=2) + '\n')


def run(name, command, seconds):
    command = [str(x) for x in command]
    row = dict(name=name, command=command)
    report['jobs'].append(row)
    save()
    start = time.monotonic()
    with (out / (name + '.stdout')).open('xb') as stdout, (out / (name + '.stderr')).open('xb') as stderr:
        result = subprocess.run(command, cwd=ROOT, stdout=stdout, stderr=stderr, timeout=seconds)
    row.update(seconds=time.monotonic() - start, status=result.returncode,
               stdout=pin(out / (name + '.stdout')), stderr=pin(out / (name + '.stderr')))
    save()
    if result.returncode:
        raise RuntimeError('failed ' + name)


save()
try:
    run('emit', [bun, HERE / 'emit-controls.mjs', args.api.resolve(), prepared, out / 'emit'], 45)
    emitted = json.loads((out / 'emit/report.json').read_text())
    assert emitted['complete'] and emitted['observations'] == 128
    run('qbe', [qbe, '-t', 'amd64_sysv', '-o', out / 'program.s', out / 'emit/program.ssa'], 30)
    run('assemble', [assembler, '-o', out / 'program.o', out / 'program.s'], 20)
    run('link', [gcc, '-O2', '-no-pie', prepared / 'harness.c', out / 'program.o', '-o', out / 'program'], 30)
    run('native', [out / 'program'], 10)
    actual = (out / 'native.stdout').read_bytes()
    expected = (prepared / 'expected.stdout').read_bytes()
    assert actual == expected, 'complete raw64 outputs differ'
    assert len(actual.splitlines()) == 128
    assert not (out / 'native.stderr').read_bytes()
    report.update(complete=True, structuralControls=22, observations=128,
                  outputs=[pin(out / p) for p in ['emit/report.json', 'emit/program.ssa',
                      'program.s', 'program.o', 'program', 'native.stdout', 'native.stderr']])
except BaseException as error:
    report['error'] = repr(error)
    raise
finally:
    save()
