#!/usr/bin/env python3
"""Offline declaration identity audit; never executes a compiler or target."""
import importlib.util,json,pathlib,re
root=pathlib.Path(__file__).resolve().parents[2]
spec=importlib.util.spec_from_file_location('source',root/'selfhost/tools/build/source.py')
source=importlib.util.module_from_spec(spec);spec.loader.exec_module(source)
def load(path):return source.grouped(source.blocks((root/path).read_bytes())[1])
frozen='selfhost/tests/phase194/predicate-select-v3.bend'
maintained='selfhost/src/back/x86/predicate-select.bend'
hook='selfhost/tests/phase194/predicate-hook.bend'
branch='selfhost/src/back/x86/branch-selection.bend'
api='selfhost/build/phase194/predicate-api-source03/compiler.bend'
f,m,h,b,a=map(load,[frozen,maintained,hook,branch,api])
assert (root/frozen).read_bytes()==(root/maintained).read_bytes()
rows=[]
for name,defs in (f|h).items():
    target=m if name in f else b
    kinds={d["kind"]for d in defs}
    assert source.normalized(defs)==source.normalized([d for d in target[name]if d["kind"]in kinds])==source.normalized([d for d in a[name]if d["kind"]in kinds]),name
    rows.append({'name':name,'normalizedSha256':source.digest(source.normalized(defs)),
      'exactFrozenDeclarationExceptCommentsWhitespace':True,'matchesCheckedApiDeclaration':True})
manifest=json.loads((root/'selfhost/src/compiler.json').read_text())
modules=manifest['profiles']['x86']['modules']
report={'kind':'phase194-predicate-maintained-source-closure','targetExecuted':False,
        'frozenModule':source.pin(root/frozen),'maintainedModule':source.pin(root/maintained),
        'exactFrozenModule':True,'hook':source.pin(root/hook),'checkedApiSource':source.pin(root/api),
        'declarations':rows,'x86ProfileContainsModule':maintained.removeprefix('selfhost/')in modules,
        'scope':'Exact module identity and normalized declaration equality against checked predicate-api03 source; whole-profile assembly/closure belongs to combined integration audit. No source checker or target was executed.'}
(root/'research/phase194/predicate-integration-audit.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps({'declarations':len(rows),'moduleIdentity':True,'checkedApiDeclarationIdentity':True,'x86ProfileContainsModule':report['x86ProfileContainsModule']}))
