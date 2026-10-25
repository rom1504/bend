"""Compose explicit Phase140 experimental Bend overlays on qualified Phase137.

Only source packaging; compiler work remains in the checked Bend modules.
"""
import argparse, importlib.util, json
from pathlib import Path
ROOT = Path(__file__).resolve().parents[4]
spec = importlib.util.spec_from_file_location('p131compose', ROOT/'selfhost/tools/performance/phase131/prepare.py')
C = importlib.util.module_from_spec(spec); spec.loader.exec_module(C)
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--out', type=Path, required=True)
p.add_argument('--module', type=Path, action='append', required=True)
p.add_argument('--overrides', nargs='*', default=[])
p.add_argument('--native-entry', action='store_true')
a = p.parse_args()
out = a.out.resolve()
assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase140')
selection = ROOT/'implementation/phase137/candidate.json'
r = json.loads(selection.read_text())
assert r['nativeQualified'] and r['source']['sha256']=='2620d59a3a20fa5d5d27bbf3b12ceb7304439b27093fff1c0f383da03e4ecf38'
assert C.pin(r['source']['file']) == r['source']
modules = [m.resolve() for m in a.module]
assert len(modules)==len(set(modules))
before = Path(r['source']['file']).read_text()
if a.native_entry:
    assert 'p111_native_args' in a.overrides
    C.ENTRY_GATES -= {'p111_native_args'}
text, added, protected = C.compose(before, [m.read_text() for m in modules], set(a.overrides), set())
old, new = C.blocks(before), C.blocks(text)
for name in r['proofScope']['exactDeclarations']:
    assert old[name] == new[name], name
if a.native_entry:
    assert new['p111_native_request'] == old['p111_native_request']
out.mkdir(parents=True)
(out/'compiler.bend').write_text(text)
(out/'prepare.py').write_bytes(Path(__file__).read_bytes())
for i, m in enumerate(modules):
    (out/f'module{i}.bend').write_bytes(m.read_bytes())
report = dict(kind='phase140-experimental-source', complete=True, checked=False,
    nativeQualified=False, selected=False, source=C.pin(out/'compiler.bend'),
    parent=r['source'], parentSelection=C.pin(selection), modules=[C.pin(m) for m in modules],
    overrides=a.overrides, added=added, protectedDeclarations=protected,
    unchangedProofDeclarations=r['proofScope']['exactDeclarations'],
    physicalLines=len(text.splitlines()),
    inputs=[C.pin(__file__), C.pin(C.__file__), C.pin(selection), r['source'], *[C.pin(m) for m in modules]])
(out/'manifest.json').write_text(json.dumps(report, indent=2)+'\n')
print(json.dumps(dict(source=report['source'], added=len(added))))
