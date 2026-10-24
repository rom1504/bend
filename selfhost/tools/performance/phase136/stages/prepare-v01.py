#!/usr/bin/env python3
"""Compose diagnostic stages on the qualified uncached Phase134 core, source only."""
import argparse
import importlib.util
import json
import pathlib

ROOT = pathlib.Path(__file__).resolve().parents[5]
HERE = pathlib.Path(__file__).resolve().parent
COMPOSER = ROOT / 'selfhost/tools/performance/phase131/prepare.py'
spec = importlib.util.spec_from_file_location('composer', COMPOSER)
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--out', type=pathlib.Path, required=True)
args = parser.parse_args()
out = args.out.resolve()
assert not out.exists() and out.is_relative_to(ROOT / 'selfhost/build/phase136')
selection = ROOT / 'implementation/phase134/final/candidate.json'
selected = json.loads(selection.read_text())
assert selected['complete'] and selected['nativeQualified']
assert selected['source']['sha256'] == 'a00019246b5181b288ab4d3e09e616bd41415fe6381e89a96185c05efa19fb57'
assert C.pin(selected['source']['file']) == selected['source']
manifest = pathlib.Path(selected['sourceManifest']['file'])
assert C.pin(manifest) == selected['sourceManifest']
parent = json.loads(manifest.read_text())
before = pathlib.Path(selected['source']['file']).read_text()
modules = [HERE / name for name in ['stages-v01.bend', 'parse-v01.bend', 'entry-v01.bend']]
old = C.blocks(before)
C.ENTRY_GATES -= {'p111_native_args'}
text, added, protected = C.compose(before, [p.read_text() for p in modules], {'p111_native_args'}, set())
new = C.blocks(text)
changed = sorted(n for n in old if C.norm(old[n]) != C.norm(new[n]))
assert changed == ['p111_native_args']
original_tail = old['p111_native_args'].split('    case Con{program,Con{+path', 1)[1]
assert new['p111_native_args'].endswith('    case Con{program,Con{+path' + original_tail)
proofs = parent.get('unchangedProofDeclarations', [])
assert all(C.norm(old[n]) == C.norm(new[n]) for n in proofs)
assert not any(n.startswith(('p134u_', 'p134ns_', 'p135ms_')) for n in new)
out.mkdir(parents=True)
(out / 'compiler.bend').write_text(text)
(out / 'prepare.py').write_bytes(pathlib.Path(__file__).read_bytes())
for i, module in enumerate(modules):
    (out / f'module{i}.bend').write_bytes(module.read_bytes())
report = dict(complete=True, checked=False, targetsRun=False,
    source=C.pin(out / 'compiler.bend'), parent=selected['source'],
    sourceManifest=selected['sourceManifest'], selection=C.pin(selection),
    overrides=changed, added=added, protectedDeclarations=protected,
    unchangedProofDeclarations=proofs,
    inputs=[C.pin(__file__), C.pin(COMPOSER), C.pin(selection), C.pin(manifest),
            selected['source'], *[C.pin(p) for p in modules]],
    scope='Diagnostic seven-argument mode only; original six-argument route verbatim. No incremental cache. All existing compiler/checker/proof/verifier helpers unchanged. Pure and IO consumers share the same transition functions; stdout remains ordinary QBE, stage metadata goes to stderr.')
(out / 'manifest.json').write_text(json.dumps(report, indent=2) + '\n')
print(json.dumps(report['source']))
