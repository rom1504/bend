"""Package explicit Bend overlays on the exact qualified Phase143 source; no lowering."""
import argparse
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
spec = importlib.util.spec_from_file_location('compose', ROOT/'selfhost/tools/performance/phase131/prepare.py')
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--out', type=Path, required=True)
p.add_argument('--module', type=Path, action='append', required=True)
p.add_argument('--overrides', nargs='*', default=[])
a = p.parse_args()
out = a.out.resolve()
assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase144')
selection = ROOT/'implementation/phase143/candidate.json'
parent = json.loads(selection.read_text())['source']
assert parent['sha256'] == 'a51a4a6d0a32e118ca75eac96fb4e64bae0fcf951b09ee859c2632f65550bd4e'
assert C.pin(parent['file']) == parent
before = Path(parent['file']).read_text()
modules = [m.resolve() for m in a.module]
assert len(modules) == len(set(modules))
text, added, protected = C.compose(before, [m.read_text() for m in modules], set(a.overrides), set())
old, new = C.blocks(before), C.blocks(text)
proofs = json.loads((ROOT/'implementation/phase137/candidate.json').read_text())['proofScope']['exactDeclarations']
additional = {'p126bp_complete', 'p140v_array', 'p140v_direct_walk', 'p140v_direct_step',
              'p140v_direct_result', 'p140v_context', 'p140v_check', 'p140v_open',
              'p140v_raw_walk', 'p140v_segment'}
for name in set(proofs) | additional:
    assert old[name] == new[name], name
out.mkdir(parents=True)
(out/'compiler.bend').write_text(text)
(out/'prepare.py').write_bytes(Path(__file__).read_bytes())
for i, m in enumerate(modules):
    (out/f'module{i}.bend').write_bytes(m.read_bytes())
report = dict(kind='phase144-explicit-overlay', complete=True, checked=False,
              nativeQualified=False, selected=False, source=C.pin(out/'compiler.bend'),
              parent=parent, added=added, overrides=a.overrides,
              protectedDeclarations=sorted(set(protected) | additional),
              unchangedProofDeclarations=proofs,
              physicalLines=len(text.splitlines()), parentLines=len(before.splitlines()),
              inputs=[C.pin(__file__), C.pin(C.__file__), C.pin(selection), parent,
                      *[C.pin(m) for m in modules]])
(out/'manifest.json').write_text(json.dumps(report, indent=2)+'\n')
print(json.dumps({'source':report['source'],'added':len(added),'overrides':a.overrides}))
