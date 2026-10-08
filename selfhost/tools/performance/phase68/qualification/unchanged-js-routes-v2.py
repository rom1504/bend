#!/usr/bin/env python3
"""Require exact actual JS/frontend driver-route closure; native roots qualify separately."""
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
PARENT = ROOT / 'selfhost/tools/performance/phase68/qualification/unchanged-js.py'
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
assert before['exports'] == after['exports']
# This exact unchanged driver has two native-only guarded arms. Their source
# bytes and the whole driver are admitted explicitly, rather than excluding
# functions merely because their source module or public name looks native.
assert hashlib.sha256(driver.encode()).hexdigest() == 'e093483d5103a8e833b6ca710246b1ec3c579b7fac5060c8e42f626c5e25ec85'
regions = [
    ("    if(mode==='native'&&api.nc_annotation_stops", '    } else if(selectedEmission){',
     '692f261d91c6a49a955d87fe1e38b8db61e8752db43c805a976c0f5cc41bbf57'),
    ("    if(mode==='native') {", "    trace('emit '+mode);",
     '4188e8c2020aefdc68ad83c2530d9e6ded1c6c420556ecd45acf2fe8e073b8b5')]
route_source, excluded_arms = driver, []
for begin, end, expected in regions:
    assert driver.count(begin) == driver.count(end) == 1
    first, last = driver.index(begin), driver.index(end, driver.index(begin))
    arm = driver[first:last]
    assert hashlib.sha256(arm.encode()).hexdigest() == expected
    assert route_source.count(arm) == 1
    route_source = route_source.replace(arm, '')
    excluded_arms.append(dict(begin=begin, end=end, sha256=expected,
        sourceBytes=len(arm.encode()), reason="Guard requires mode==='native'; JS/frontend requests cannot enter this arm."))
dynamic = [line for line in route_source.splitlines() if 'api[' in line]
assert len(dynamic) == 5 and all("typeof api[name]==='function'" in line or "typeof api[name]!=='function'" in line for line in dynamic)
refs = set(re.findall(r'\bapi\.([A-Za-z_]\w*)', route_source))
all_refs = set(re.findall(r'\bapi\.([A-Za-z_]\w*)', driver))
assert refs - before['exports'].keys() == {'bend', 'mjs'}
roots = sorted(refs & before['exports'].keys())
assert set(frontend['roots']) <= set(roots)
strong_roots = sorted(set(before['exports']) - {'nc_compile'})
strong_left, strong_right = C.closure(before, strong_roots), C.closure(after, strong_roots)
strong_differences = sorted(name for name in strong_left | strong_right
    if before['functions'].get(name,{}).get('source') != after['functions'].get(name,{}).get('source'))
strong_passed = strong_left == strong_right and not strong_differences
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
result = dict(kind='phase68-js-frontend-driver-closure', complete=True, passed=True,
              targetExecuted=False, predecessorMethod=parent, changedSourceFiles=changed,
              changedInputs=[dict(path=k, baseline=old_sources.get(k), candidate=new_sources.get(k)) for k in changed],
              movedDeclarations=moved, changedUnreachableFunctions=changed_generated,
              moduleInventory=dict(baseline=configs[0]['modules'], candidate=configs[1]['modules']),
              nativeFixtureModules=dict(baseline=native_manifests[0], candidate=native_manifests[1]), baseline=pin(a.baseline/'attempt.json'),
              candidate=pin(a.candidate/'attempt.json'), frontend=frontend,
              driverRoots=roots, unchangedDriverFunctions=len(left),
              excludedPublicRoots=sorted(set(before['exports'])-set(roots)),
              nativeOnlyDriverReferences=sorted((all_refs-refs)&before['exports'].keys()),
              nativeGuardedArms=excluded_arms, dynamicDriverReferences=dynamic,
              stronger98RootGate=dict(passed=strong_passed, changedFunctions=strong_differences,
                  scope='Reported separately; native-only roots may change and are not transferred by this route-specific gate.'),
              inputs=list(inputs.values()),
              scope='Exact B1 runtime/public wrappers and every generated dependency of each actual API reference on the unchanged JS/frontend driver routes; only the two exact native-guarded arms are excluded. Snapshot host, Base, runtime/providers and all non-module source files except the structurally checked native fixture module list are unchanged. Every moved source declaration preserves its exact signature, body and annotation; compiler configuration differs only in module membership. Changed generated functions are excluded by the complete actual reachable closure, without a native-module allowlist. Supports retaining finite frontend/JS driver-route semantic observations only. Does not transfer excluded public-API controls, native-root behavior, compiler timing, actualB2 behavior or changed native code.')
out.parent.mkdir(parents=True, exist_ok=True)
with out.open('x') as stream:
    stream.write(json.dumps(result, indent=2)+'\n')
print(json.dumps(dict(report=pin(out), frontendFunctions=frontend['unchangedFunctionCount'], driverFunctions=len(left), stronger98RootGatePassed=strong_passed)))
