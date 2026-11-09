#!/usr/bin/env python3
"""Current ten finite runtime fixtures through the maintained x86 build path.

Only committed fixture bytes/oracles come from Phase182. Compiler selection,
Base preparation, runtime object, argument convention and machine policy are
explicit current maintained assets; no historical phase adapter is imported.
Run under one outer process-tree/disk guard; this adapter does not nest guards.
"""
import argparse
import json
from pathlib import Path
import sys
import time

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'selfhost/tools/build'))
import assets
from common import fresh_output, pin, require, run, verify, write_json

CASES = ('numeric', 'array-unchecked', 'array-unchecked-boxed', 'char-output',
         'argv', 'files', 'open-errors', 'exit', 'exit-upper-valid', 'halt-valid')
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--assets', type=Path, required=True)
images = p.add_mutually_exclusive_group(required=True)
images.add_argument('--image-key')
images.add_argument('--image', type=Path)
p.add_argument('--image-receipt', type=Path)
p.add_argument('--host', choices=('native', 'js'), required=True)
p.add_argument('--stage', required=True)
p.add_argument('--runtime-key', default='qbe-runtime')
p.add_argument('--mode', choices=('cache', 'live'), default='cache')
p.add_argument('--cases', default=','.join(CASES))
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()
require((a.image is None) == (a.image_receipt is None), '--image requires --image-receipt; asset-key selection does not')
selected = a.cases.split(',')
require(selected and len(selected) == len(set(selected)) and all(name in CASES for name in selected), 'Select distinct known finite cases')
document = assets.load_assets(a.assets, ROOT)
provider = assets.runtime_provider(document, a.runtime_key)
require(assets.runtime_abi(provider) == 11102, 'Current ABI11102 runtime binding required')
runtime_args = assets.runtime_arguments(provider)
out = fresh_output(a.out, ROOT)
inputs = [pin(__file__), document['_manifest'], pin(assets.__file__),
          pin(ROOT / 'selfhost/tools/build/common.py'), pin(ROOT / 'selfhost/tools/build/native.py'),
          pin(sys.executable), assets.asset(document, a.runtime_key)]
if a.image:
    inputs += [pin(a.image), pin(a.image_receipt)]
started = time.monotonic()
report = dict(kind='phase183-x86-runtime-controls', version=1, complete=False, passed=False,
              target='x86', runtimeABI=11102, runtime=assets.asset(document, a.runtime_key), image=pin(a.image) if a.image else assets.asset(document,a.image_key),
              host=a.host, stage=a.stage, inputs=inputs, rows=[],
              selection=dict(names=selected, count=len(selected), total=10, all=selected == list(CASES)),
              runtimeArguments=runtime_args,
              scope='Exact source-output/status controls through maintained x86 request/build/runtime bindings. Includes ordinary requested exit23/255/7, never invalid runtime probes. Not native64, bootstrap, parallel, GPU, or full language qualification.')


def save():
    report['seconds'] = time.monotonic() - started
    write_json(out / 'report.json', report)


save()
try:
    for name in selected:
        source = ROOT / 'selfhost/tests/phase182/native' / (name + '.bend')
        source_pin = pin(source)
        inputs.append(source_pin)
        lines, exit_code = [], 0
        for line in source.read_text().splitlines():
            if line.startswith('#|exit '):
                exit_code = int(line[7:])
            elif line.startswith('#|'):
                lines.append(line[2:])
        stdout, stderr = '\n'.join(lines) + ('\n' if lines else ''), ''
        if name == 'halt-valid':
            stdout, stderr = 'before\n', 'reported\n'
        folder = out / name
        folder.mkdir()
        command = [sys.executable, '-B', 'selfhost/tools/build/native.py', '--assets', str(a.assets),
                   '--host', a.host, '--stage', a.stage, '--target', 'x86', '--mode', a.mode,
                   '--runtime-key', a.runtime_key, '--source', str(source), '--out', str(folder / 'build'),
                   '--seconds', '55', '--retain-ir']
        if a.image_key:
            command += ['--image-key', a.image_key]
        else:
            command += ['--image', str(a.image), '--image-receipt', str(a.image_receipt)]
        row = dict(name=name, source=source_pin, expected=dict(stdout=stdout, stderr=stderr, exitCode=exit_code), complete=False)
        report['rows'].append(row)
        row['build'] = run(command, cwd=ROOT, stdout=folder / 'build.stdout', stderr=folder / 'build.stderr', seconds=65)
        save()
        receipt = folder / 'build/report.json'
        require(row['build']['complete'] and receipt.exists(), 'Build failed: ' + name)
        built = json.loads(receipt.read_text())
        row['receipt'] = pin(receipt)
        require(built.get('complete') and built.get('target') == 'x86' and built.get('runtimeABI') == 11102, 'Incomplete or mismatched x86 build: ' + name)
        work = folder / 'run'
        work.mkdir()
        row['execution'] = run([str(folder / 'build/program'), *runtime_args], cwd=work,
                               stdout=folder / 'stdout', stderr=folder / 'stderr', seconds=15)
        execution = row['execution']
        row['complete'] = (not execution.get('timedOut') and not execution.get('error') and
                           execution['exitCode'] == exit_code and
                           (folder / 'stdout').read_bytes() == stdout.encode() and
                           (folder / 'stderr').read_bytes() == stderr.encode())
        save()
        require(row['complete'], 'Runtime observation differs: ' + name)
    for item in inputs:
        verify(item)
    report['complete'] = True
    report['passed'] = len(report['rows']) == len(selected) and all(row['complete'] for row in report['rows'])
except Exception as error:
    report['error'] = repr(error)
finally:
    save()
    print(json.dumps(dict(complete=report['complete'], passed=report['passed'],
                         cases=[(row['name'], row['complete']) for row in report['rows']], error=report.get('error'))))
sys.exit(0 if report['passed'] else 1)
