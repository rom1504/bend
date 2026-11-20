#!/usr/bin/env python3
"""Stage selected table/branch/call/sqrt sources and audit exact body transport."""
from pathlib import Path
import importlib.util
import json
import shutil

ROOT = Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location('source', ROOT / 'selfhost/tools/build/source.py')
s = importlib.util.module_from_spec(spec)
spec.loader.exec_module(s)
live = ROOT / 'selfhost'
out = live / 'build/phase195/selected-source02'
stage = out / 'maintained'
manifest = live / 'src/compiler.json'
original_pin = s.pin(manifest)
profiles = ['qbe', 'native-c', 'js-api', 'qbe-policy', 'qbe-policy-test']
before = {p: s.maintained_assemble(manifest, live, p) for p in profiles}
assert not out.exists(), 'Fresh output required'
stage.mkdir(parents=True)
shutil.copytree(live / 'src', stage / 'src')
original_manifest = json.loads(manifest.read_text())
dependencies = set(original_manifest['modules'])
for config in original_manifest['profiles'].values():
    dependencies.update(config.get('modules', []))
    if config.get('entryModule'):
        dependencies.add(config['entryModule'])
for module in dependencies:
    if not (stage / module).exists():
        (stage / module).parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(live / module, stage / module)
tests = live / 'tests/phase195'

def declarations(path):
    return s.blocks(path.read_bytes())[1]

def replace(path, name, payload):
    data = path.read_bytes()
    blocks = declarations(path)
    matches = [b for b in blocks if b['kind'] == 'def' and b['name'] == name]
    assert len(matches) == 1, (path, name)
    b = matches[0]
    path.write_bytes(data[:b['offset']] + b'\n' + payload.strip() + b'\n' + data[b['offset']+len(b['data']):])

expression = stage / 'src/back/x86/expression-reuse.bend'
replace(expression, 'x190_v_plain', b'\n\n'.join((tests / p).read_bytes() for p in [
    'branch-facts/branch-facts-v2.bend', 'call-facts/call-facts-v1.bend', 'call-facts/hook-v1.bend']))
table = stage / 'src/back/x86/constant-tables.bend'
table.write_bytes(b'law x181_program_data:\n  for data: P111QData\n  for +available: KDef\n  X181Output\n\n' +
    b''.join(b['data'] for b in declarations(tests / 'float/table-calls-v3.bend') if b['name'].startswith('x195t_')))
replace(stage / 'src/back/x86/program.bend', 'x181_program_private', (tests / 'float/table-hook.bend').read_bytes())
replace(stage / 'src/back/x86/floating.bend', 'x185_float_call',
    (tests / 'float/sqrt-call.bend').read_bytes() + b'\n' + (tests / 'float/sqrt-hook-v2.bend').read_bytes())
model = stage / 'src/back/x86/model.bend'
model.write_bytes(model.read_bytes() + b'\nlaw x181_label:\n  for n: U32\n  for frame: X181Frame\n  String\n')
replace(stage / 'src/back/x86/object-encode.bend', 'x187_encode', (tests / 'float/sqrt-encoding-hook.bend').read_bytes())
interface_headers = {
    'x181_label': ('src/back/x86/function.bend', b'def x181_label(n: U32, frame: X181Frame) -> String:', b'def x181_label(n,frame):'),
    'x181_program_data': ('src/back/x86/program.bend', b'def x181_program_data(data: P111QData, +available: KDef) -> X181Output:', b'def x181_program_data(data,available):')}
for name, (filename, old, new) in interface_headers.items():
    path = stage / filename
    assert path.read_bytes().count(old) == 1
    path.write_bytes(path.read_bytes().replace(old, new))
selected_manifest = stage / 'src/compiler.json'
m = json.loads(selected_manifest.read_text())
modules = m['profiles']['x86']['modules']
modules.insert(modules.index('src/back/x86/program.bend'), 'src/back/x86/constant-tables.bend')
s.dump(selected_manifest, m)
profile_checks = {}
for p in profiles:
    after = s.maintained_assemble(selected_manifest, stage, p)
    assert before[p] == after, p
    profile_checks[p] = {'bytes': len(after), 'sha256': s.digest(after), 'byteIdentity': True}
data, source_map = s.maintained_assemble(selected_manifest, stage, 'x86', with_map=True)
(out / 'compiler.bend').write_bytes(data)
s.dump(out / 'compiler.bend.map.json', source_map)
roots = ['p88_cache_prepare', 'p86_plan', 'p169np_plan', 'x181_prepared', 'x188_many', 'x188_render', 'x188_assemble']
m['profiles']['x86'].update(roots=roots, omitMain=True)
audit_manifest = out / 'seven-root-manifest.json'
s.dump(audit_manifest, m)
closure = s.maintained_assemble(audit_manifest, stage, 'x86')
(out / 'seven-root-closure.bend').write_bytes(closure)
checked = live / 'build/phase195/combined-api-source01/compiler.bend'
rows = [((0, b['kind'], b['name']), b['data'], None) for b in declarations(checked)]
selected = s.declaration_closure(rows, roots)
a = {(key[1], key[2]): s.normalized([{'data': data}]) for key, data, _ in selected}
b = {(x['kind'], x['name']): s.normalized([x]) for x in s.blocks(closure)[1]}
added = b.keys() - a.keys()
assert added == {('law', 'x181_program_data'), ('law', 'x181_label')}, added
assert not a.keys() - b.keys(), a.keys() - b.keys()
differences = [key for key in a if a[key] != b[key]]
assert set(differences) == {('def', n) for n in interface_headers}, differences
for kind, name in differences:
    _, old, new = interface_headers[name]
    assert a[(kind, name)].replace(old, new) == b[(kind, name)], name
def executable(data):
    # Ignore only framing blank lines/comments before the declaration and final
    # blank lines. Preserve all executable-body bytes and internal whitespace.
    block = s.blocks(data)[1][0]
    raw = block['data'][block['headerOffset']-block['offset']:]
    for _, old, new in interface_headers.values():
        raw = raw.replace(old, new, 1)
    return raw.rstrip(b'\n')
api_defs = {key[2]: executable(data) for key, data, _ in selected if key[1] == 'def'}
staged_defs = {x['name']: executable(x['data']) for x in s.blocks(closure)[1] if x['kind'] == 'def'}
assert api_defs.keys() == staged_defs.keys()
body_differences = [n for n in api_defs if api_defs[n] != staged_defs[n]]
assert not body_differences, body_differences
canonical = {}
for p in ['src/back/qbe/product-composition.bend', 'src/back/qbe/typed-regions.bend']:
    canonical.update({(x['kind'], x['name']): s.normalized([x]) for x in declarations(live / p)})
helpers = ['p126i_lookup', 'p126i_present', 'p126i_recognized', 'p126i_calls_walk', 'p126i_calls', 'p126i_table_name', 'p126s_data']
assert all(a[('def', n)] == canonical[('def', n)] for n in helpers)
assert s.pin(manifest) == original_pin
report = {'kind': 'phase195-maintained-integration-audit', 'complete': True,
    'targetsRun': False, 'liveManifestUnchanged': True, 'liveManifest': original_pin,
    'stagedManifest': s.pin(selected_manifest), 'selectedSource': s.pin(out / 'compiler.bend'),
    'checkedApiSource': s.pin(checked), 'checkedApiReceipt': s.pin(live / 'build/phase195/combined-api01/report.json'),
    'sevenRoots': roots, 'closureDeclarations': len(b), 'normalizedDifferences': [],
    'interfaceDefinitionHeaders': differences, 'exactExecutableBodiesIdentical': True,
    'exactExecutableBodyCount': len(api_defs), 'exactExecutableBodyDifferences': body_differences,
    'method': s.pin(Path(__file__)),
    'addedInterfaceLaws': sorted(added), 'canonicalTableHelpersIdentical': helpers,
    'canonicalProfiles': profile_checks, 'included': ['table-v3', 'branch-v2', 'call-v1', 'sqrt-v2'],
    'excluded': ['cycles', 'pool', 'physical-select', 'memory-recurrence']}
s.dump(ROOT / 'research/phase195/maintained-integration-audit.json', report)
print(json.dumps(report, indent=2))
