"""Explicit declaration replacement/deletion; no compiler semantics in this tool."""
import argparse
import importlib.util
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
spec = importlib.util.spec_from_file_location('compose', ROOT/'selfhost/tools/performance/phase131/prepare.py')
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--out', type=Path, required=True)
p.add_argument('--contract', type=Path)
p.add_argument('--module', type=Path, action='append', default=[])
a = p.parse_args()
out = a.out.resolve()
assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase141')
parent = ROOT/'selfhost/build/phase140/native-source18/compiler.bend'
assert C.pin(parent)['sha256'] == 'c9ded5523c4d4c3ca9b700c4aff12cd77e02043684f0472ed2f8ec8c412b6313'
before = parent.read_text()
old = C.blocks(before, True)
contract = json.loads(a.contract.read_text()) if a.contract else {'deleteNames': [], 'overrides': []}
if a.contract:
    assert contract['source'] == C.pin(parent)
    assert C.pin(contract['module']['file']) == contract['module']
deleted, overrides = set(contract['deleteNames']), set(contract['overrides'])
assert not deleted & overrides and deleted <= old.keys()
modules = [m.resolve() for m in a.module]
assert len(modules) == len(set(modules))
patch = {}
for module in modules:
    declarations = C.blocks(module.read_text(), True)
    assert not patch.keys() & declarations.keys()
    patch.update(declarations)
assert patch.keys() & old.keys() == overrides
assert not patch.keys() & deleted
proofs = json.loads((ROOT/'implementation/phase137/candidate.json').read_text())['proofScope']['exactDeclarations']
protected = C.ENTRY_GATES | set(C.blocks(C.DIRECT_VERIFIER.read_text())) | set(proofs) | {n for n in old if n.startswith('p111v_')}
assert not protected & (deleted | overrides)
hits = list(C.PAT.finditer(before))
parts = [before[:hits[0].start()]]
emitted = set()
for i, hit in enumerate(hits):
    name = hit[1]
    if name in deleted:
        continue
    original = before[hit.start():hits[i+1].start() if i+1<len(hits) else len(before)]
    if name in patch:
        if original.lstrip().startswith('law '):
            assert not patch[name].lstrip().startswith('law '), 'Keep original laws in this replacement'
            parts.append(original)
            continue
        if name not in emitted:
            parts.append(patch[name].rstrip()+'\n\n')
            emitted.add(name)
    else:
        parts.append(original)
parts.extend('\n'+body for name, body in patch.items() if name not in old)
text = ''.join(parts)
after = C.blocks(text, True)
assert after.keys() == (old.keys()-deleted) | patch.keys()
for name in old.keys()-deleted-overrides:
    assert C.norm(after[name]) == C.norm(old[name]), name
for name in protected & old.keys():
    assert after[name] == old[name], name
# This lexical screen supplements, never replaces, the independent Bend check.
code = '\n'.join(x for x in text.splitlines() if not x.lstrip().startswith('#'))
remaining = set(re.findall(r'\b([A-Za-z_][A-Za-z0-9_.]*)\s*\(', code)) & deleted
assert not remaining, sorted(remaining)
def counts(s):
    lines = s.splitlines()
    return dict(bytes=len(s.encode()), physical=len(lines), nonblank=sum(bool(x.strip()) for x in lines),
                code=sum(bool(x.strip()) and not x.lstrip().startswith('#') for x in lines),
                definitions=len(re.findall(r'^def ',s,re.M)), laws=len(re.findall(r'^law ',s,re.M)),
                types=len(re.findall(r'^type ',s,re.M)))
out.mkdir(parents=True)
(out/'compiler.bend').write_text(text)
inputs = [C.pin(__file__), C.pin(C.__file__), C.pin(parent), *[C.pin(m) for m in modules]]
if a.contract:
    inputs.append(C.pin(a.contract))
report = dict(kind='phase141-explicit-replacement', complete=True, checked=False, nativeQualified=False,
              installed=False, source=C.pin(out/'compiler.bend'), parent=C.pin(parent), inputs=inputs,
              deleted=sorted(deleted), overrides=sorted(overrides), added=sorted(patch.keys()-old.keys()),
              protectedDeclarations=sorted(protected & old.keys()), unchangedProofDeclarations=proofs,
              before=counts(before), after=counts(text),
              removed=counts(''.join(old[n] for n in sorted(deleted | overrides))),
              replacement=counts(''.join(patch.values())))
(out/'manifest.json').write_text(json.dumps(report,indent=2)+'\n')
(out/'prepare.py').write_bytes(Path(__file__).read_bytes())
print(json.dumps({k:report[k] for k in ['source','before','after','removed','replacement']}))
