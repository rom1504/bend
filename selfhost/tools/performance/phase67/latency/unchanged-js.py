#!/usr/bin/env python3
"""Require exact non-native executable B1 closure before reusing JS/frontend gates."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
RAW = ROOT / 'selfhost/build/phase67'
inputs = {}


def pin(file):
    expected = file if isinstance(file, dict) else None
    file = Path(expected['file'] if expected else file).resolve(strict=True)
    row = dict(file=str(file), sha256=hashlib.sha256(file.read_bytes()).hexdigest())
    if expected:
        assert row['sha256'] == expected['sha256']
    inputs[str(file)] = row
    return row


def read(file):
    return json.loads(Path(pin(file)['file']).read_text())


def attempt(directory):
    record = read(directory/'attempt.json')
    assert record['checked'] and record['config']['strictExact']
    validation = read(directory/'validation-001/report.json')
    assert validation['complete'] and validation['pass'] and validation['strictExact']
    assert pin(validation['attempt']) == pin(directory/'attempt.json')
    assert pin(validation['api']) == pin(record['api'])
    snapshot = Path(record['snapshot']['root'])
    sources = {str(Path(row['frozen']['file']).relative_to(snapshot)): pin(row['frozen'])
               for row in record['snapshot']['sources']}
    bootstrap = read(record['bootstrapReport'])
    assert bootstrap['revision'] == '059266225b77c8ca256ac6b25ee5c21449bab151'
    pin(dict(file=bootstrap['source'], sha256=bootstrap['sourceSha256']))
    return record, sources


p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--baseline', type=Path, required=True)
p.add_argument('--candidate', type=Path, required=True)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()
out = a.out.resolve()
assert out.is_relative_to(RAW) and not out.exists()
old, old_sources = attempt(a.baseline.resolve())
new, new_sources = attempt(a.candidate.resolve())
assert old_sources.keys() == new_sources.keys()
changed = [key for key in old_sources if old_sources[key]['sha256'] != new_sources[key]['sha256']]
assert changed and set(changed) <= {'src/back/native/bridge.bend', 'src/back/native/direct.bend'}, changed
for key in ['base', 'runtime', 'node']:
    assert pin(old[key])['sha256'] == pin(new[key])['sha256']
scanner = ROOT/'selfhost/tools/performance/phase66/controls/frontend-closure.py'
spec = importlib.util.spec_from_file_location('phase67_js_closure', scanner)
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)
driver = Path(old_sources['tools/typed-driver.mjs']['file']).read_text()
frontend = C.compare(old['api']['file'], new['api']['file'], driver)
before, after = C.program(old['api']['file']), C.program(new['api']['file'])
roots = sorted(set(before['exports']) - {'nc_compile'})
assert len(roots) == 98 and before['exports'] == after['exports']
left, right = C.closure(before, roots), C.closure(after, roots)
assert left == right
assert all(before['functions'][key]['source'] == after['functions'][key]['source'] for key in left)
pin(scanner)
pin(__file__)
for row in list(inputs.values()):
    pin(row)
result = dict(kind='phase67-nonnative-executable-closure', complete=True, passed=True,
              targetExecuted=False, changedSourceFiles=changed, baseline=pin(a.baseline/'attempt.json'),
              candidate=pin(a.candidate/'attempt.json'), frontend=frontend,
              nonNativeRoots=roots, unchangedNonNativeFunctions=len(left),
              excludedPublicRoot='nc_compile', inputs=list(inputs.values()),
              scope='Exact B1 runtime/public wrappers and every generated dependency of all98 non-nc_compile public roots. Snapshot host, Base, runtime/providers and all non-native source files are unchanged. Supports retaining finite frontend/JS semantic observations; does not transfer compiler timing, actualB2 behavior or changed native code.')
out.parent.mkdir(parents=True, exist_ok=True)
with out.open('x') as stream:
    stream.write(json.dumps(result, indent=2)+'\n')
print(json.dumps(dict(report=pin(out), frontendFunctions=frontend['unchangedFunctionCount'], nonNativeFunctions=len(left))))
