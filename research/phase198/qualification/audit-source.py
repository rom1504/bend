#!/usr/bin/env python3
"""Authenticate the complete staged source and its measured seven-root API."""
from pathlib import Path
import importlib.util
import json

ROOT = Path(__file__).resolve().parents[3]
LIVE = ROOT / 'selfhost'
OUT = LIVE / 'build/phase198/selected-source01'
STAGE = OUT / 'maintained'
spec = importlib.util.spec_from_file_location('source', LIVE / 'tools/build/source.py')
s = importlib.util.module_from_spec(spec)
spec.loader.exec_module(s)
roots = ['p88_cache_prepare', 'p86_plan', 'p169np_plan', 'x181_prepared', 'x188_many', 'x188_render', 'x188_assemble']
selected = OUT / 'compiler.bend'
assert s.maintained_assemble(STAGE / 'src/compiler.json', STAGE, 'x86') == selected.read_bytes()
acceptance_path = LIVE / 'build/phase197/full-source-check01/report.json'
acceptance = json.loads(acceptance_path.read_text())
assert acceptance['complete'] and acceptance['checked'] and acceptance['unresolvedHoles'] == 0
assert all(s.pin(selected)[k] == acceptance['source'][k] for k in ['bytes', 'sha256'])
assert Path(acceptance['source']['file']).read_bytes() == selected.read_bytes()
api_path = LIVE / 'build/phase197/combined-api-source02/compiler.bend'
audit_manifest = json.loads((STAGE / 'src/compiler.json').read_text())
audit_manifest['profiles']['x86'].update(roots=roots, omitMain=True)
audit_manifest_path = OUT / 'seven-root-manifest.json'
s.dump(audit_manifest_path, audit_manifest)
seven_root_source = s.maintained_assemble(audit_manifest_path, STAGE, 'x86')
(OUT / 'seven-root-closure.bend').write_bytes(seven_root_source)
def closure(data):
    rows = [((0, b['kind'], b['name']), b['data'], None) for b in s.blocks(data)[1]]
    return {(key[1], key[2]): data for key, data, _ in s.declaration_closure(rows, roots)}
actual, expected = closure(seven_root_source), closure(api_path.read_bytes())
assert actual.keys() == expected.keys()
def framing(data):
    block = s.blocks(data)[1][0]
    return data[block['headerOffset']:].rstrip(b'\n')
differences = [key for key in actual if s.normalized([{'data': actual[key]}]) != s.normalized([{'data': expected[key]}])]
assert not differences, differences
body_differences = [key for key in actual if key[0] == 'def' and framing(actual[key]) != framing(expected[key])]
assert not body_differences, body_differences
profiles = {}
for profile in ['qbe', 'native-c', 'js-api', 'qbe-policy', 'qbe-policy-test']:
    before, before_map = s.maintained_assemble(LIVE / 'src/compiler.json', LIVE, profile, with_map=True)
    after, after_map = s.maintained_assemble(STAGE / 'src/compiler.json', STAGE, profile, with_map=True)
    assert before == after and before_map == after_map, profile
    profiles[profile] = {'bytes': len(after), 'sha256': s.digest(after), 'sourceAndMapIdentical': True}
report = {'kind': 'phase198-staged-source-audit', 'complete': True,
    'sevenRoots': roots, 'selectedSource': s.pin(selected), 'checkedApiSource': s.pin(api_path),
    'checkedApiReceipt': s.pin(LIVE / 'build/phase197/combined-api02/report.json'),
    'sourceAcceptanceReceipt': s.pin(acceptance_path), 'sourceAcceptanceInheritedByExactBytes': True,
    'method': s.pin(Path(__file__)), 'normalizedDifferences': differences,
    'exactExecutableBodiesIdentical': True, 'exactExecutableBodyCount': sum(k[0] == 'def' for k in actual),
    'closureDeclarations': len(actual), 'canonicalProfiles': profiles,
    'liveManifest': s.pin(LIVE / 'src/compiler.json'), 'stagedManifest': s.pin(STAGE / 'src/compiler.json'),
    'scope': 'Full-source assembly, exact measured API bodies, inherited independent source acceptance by identical bytes, and non-x86 profile identity. No new target execution or live source change.'}
s.dump(ROOT / 'research/phase198/qualification/source-audit.json', report)
print(json.dumps({'complete': True, 'closureDeclarations': len(actual), 'exactExecutableBodies': report['exactExecutableBodyCount'], 'otherProfilesIdentical': len(profiles)}))
