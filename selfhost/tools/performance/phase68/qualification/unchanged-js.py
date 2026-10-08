#!/usr/bin/env python3
"""Require exact non-native executable B1 closure before reusing JS/frontend gates."""
import argparse
import hashlib
import importlib.util
import json
import re
import sys

sys.dont_write_bytecode = True
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
RAW = ROOT / 'selfhost/build/phase68'
PARENT = ROOT / 'selfhost/tools/performance/phase67/latency/unchanged-js.py'
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
# Only assembler module membership may change in compiler configuration. All
# host/runtime/provider and non-module source artifacts remain byte-identical.
configs = [read(sources['src/compiler.json']) for sources in (old_sources, new_sources)]
assert {k:v for k,v in configs[0].items() if k != 'modules'} == {k:v for k,v in configs[1].items() if k != 'modules'}
modules = [set(config['modules']) for config in configs]
assert all(len(config['modules']) == len(mods) for config,mods in zip(configs,modules))
module_paths = modules[0] | modules[1]
assert all(p.startswith('src/') and p.endswith('.bend') for p in module_paths)
assert all(mods <= sources.keys() for mods,sources in zip(modules,(old_sources,new_sources)))
changed = sorted(k for k in old_sources.keys() | new_sources.keys()
    if old_sources.get(k,{}).get('sha256') != new_sources.get(k,{}).get('sha256'))
native_manifest = 'src/back/native/manifest.txt'
assert changed and set(changed) <= module_paths | {'src/compiler.json', native_manifest}, changed
native_manifests = []
for sources,mods in zip((old_sources,new_sources),modules):
    rows = Path(sources[native_manifest]['file']).read_text().splitlines()
    assert rows and len(rows) == len(set(rows)) and all(row and row == row.strip() for row in rows)
    snapshot_root = Path(sources['src/compiler.json']['file']).parents[1]
    resolved = [str((snapshot_root/'src/back/native'/row).resolve().relative_to(snapshot_root)) for row in rows]
    assert set(resolved) <= mods, 'Native fixture manifest must reference exact assembler modules'
    native_manifests.append(resolved)


def declarations(sources, config):
    result = {}
    for module in config['modules']:
        lines = Path(sources[module]['file']).read_text().splitlines(keepends=True)
        index = 0
        while index < len(lines):
            line = lines[index]
            if not line.strip() or line.startswith('#'):
                index += 1
                continue
            if line.startswith('import '):
                # The assembled compiler admits only the historical Base import.
                assert line.strip() == 'import Base', (module, line)
                index += 1
                continue
            start = index
            if line.strip() == '@unsafe':
                index += 1
                line = lines[index]
            match = re.match(r'^(def|law|type) ([^\s(<:]+)', line)
            assert match, (module, index + 1, line)
            key = match[1], match[2]
            assert key not in result, (module, key)
            index += 1
            # Column-zero ')' is a multiline signature continuation. Top-level
            # annotations, imports and declarations delimit blocks. Internal comments
            # remain exact; only trailing inter-declaration comments are excluded.
            while index < len(lines) and not re.match(r'^(?:@|(?:def|law|type|import)\s)', lines[index]):
                assert not lines[index].strip() or lines[index][0].isspace() or lines[index].startswith((')', '#')), (module, index + 1)
                index += 1
            end = index
            while end > start and (not lines[end-1].strip() or lines[end-1].startswith('#')):
                end -= 1
            result[key] = dict(module=module, source=''.join(lines[start:end]))
    return result


old_declarations, new_declarations = [declarations(sources,config)
    for sources,config in zip((old_sources,new_sources),configs)]
moved = []
for key in sorted(old_declarations.keys() & new_declarations.keys()):
    before_declaration, after_declaration = old_declarations[key], new_declarations[key]
    if before_declaration['module'] != after_declaration['module']:
        assert before_declaration['source'] == after_declaration['source'], ('Changed moved declaration', key)
        moved.append(dict(kind=key[0], name=key[1], before=before_declaration['module'],
            after=after_declaration['module'], sha256=hashlib.sha256(before_declaration['source'].encode()).hexdigest(),
            exactSignatureBodyAndAnnotation=True))
for key in ['base', 'runtime', 'node']:
    assert pin(old[key])['sha256'] == pin(new[key])['sha256']
scanner = ROOT/'selfhost/tools/performance/phase66/controls/frontend-closure.py'
spec = importlib.util.spec_from_file_location('phase68_js_closure', scanner)
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
changed_generated = sorted(name for name in before['functions'].keys() | after['functions'].keys()
    if before['functions'].get(name,{}).get('source') != after['functions'].get(name,{}).get('source'))
assert not set(changed_generated) & left
pin(scanner)
parent = pin(PARENT)
pin(__file__)
for row in list(inputs.values()):
    pin(row)
result = dict(kind='phase68-nonnative-executable-closure', complete=True, passed=True,
              targetExecuted=False, predecessorMethod=parent, changedSourceFiles=changed,
              changedInputs=[dict(path=k, baseline=old_sources.get(k), candidate=new_sources.get(k)) for k in changed],
              movedDeclarations=moved, changedUnreachableFunctions=changed_generated,
              moduleInventory=dict(baseline=configs[0]['modules'], candidate=configs[1]['modules']),
              nativeFixtureModules=dict(baseline=native_manifests[0], candidate=native_manifests[1]), baseline=pin(a.baseline/'attempt.json'),
              candidate=pin(a.candidate/'attempt.json'), frontend=frontend,
              nonNativeRoots=roots, unchangedNonNativeFunctions=len(left),
              excludedPublicRoot='nc_compile', inputs=list(inputs.values()),
              scope='Exact B1 runtime/public wrappers and every generated dependency of all98 non-nc_compile public roots. Snapshot host, Base, runtime/providers and all non-module source files except the structurally checked native fixture module list are unchanged. Every moved source declaration preserves its exact signature, body and annotation; compiler configuration differs only in module membership. Changed generated functions are excluded by the complete actual reachable closure, without a native-module allowlist. Supports retaining finite frontend/JS semantic observations; does not transfer compiler timing, actualB2 behavior or changed native code.')
out.parent.mkdir(parents=True, exist_ok=True)
with out.open('x') as stream:
    stream.write(json.dumps(result, indent=2)+'\n')
print(json.dumps(dict(report=pin(out), frontendFunctions=frontend['unchangedFunctionCount'], nonNativeFunctions=len(left))))
