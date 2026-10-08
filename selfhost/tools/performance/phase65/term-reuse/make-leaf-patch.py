#!/usr/bin/env python3
"""Create the isolated leaf-only successor without changing live source."""
from pathlib import Path
import hashlib,json,difflib
directory=Path(__file__).resolve().parent
manifest=json.loads((directory/'shallow-v1/manifest.json').read_text())
before=(directory/'shallow-v1/before.bend').read_text()
sha=lambda s:hashlib.sha256(s.encode()).hexdigest()
assert sha(before)==manifest['beforeSha256']
old='  kc(KTerm, String.eq(tg(t), "Var"), u => kc(KTerm, U32.is_eq(ix(t), id), u => v, u => t), u => subst_node(t, id, v))'
new='''  kc(KTerm, String.eq(tg(t), "Var"), u => kc(KTerm, U32.is_eq(ix(t), id), u => v, u => t),
    u => kc(KTerm, core_literal(t), u => t,
      u => kc(KTerm, List.is_empty(&2, KTerm, ks(t)) && Bool.not(String.eq(tg(t), "App")), u => t,
        u => core_rebuild(k_with_children(t, subst_terms(ks(t), id, v))))))'''
assert before.count(old)==1
after=before.replace(old,new)
out=directory/'leaf-only-v1';out.mkdir(exist_ok=False)
for name,text in [('before.bend',before),('after.bend',after)]: (out/name).write_text(text)
patch=''.join(difflib.unified_diff(before.splitlines(keepends=True),after.splitlines(keepends=True),fromfile='a/'+manifest['source'],tofile='b/'+manifest['source']))
(out/'candidate.patch').write_text(patch)
(out/'manifest.json').write_text(json.dumps({'kind':'phase65-leaf-only-substitution-v1','productionApplied':False,'targetExecuted':False,'source':manifest['source'],'beforeSha256':sha(before),'afterSha256':sha(after),'patchSha256':sha(patch),'physicalLineDelta':len(after.splitlines())-len(before.splitlines()),'addedDefinitions':0,'addedTypes':0,'contract':'Existing Var branch, then literal/childless-nonApp return outside match. Nonleaf uses existing k_with_children plus original child substitution/rebuild. Public subst_node unchanged; no second leaf guard or literal ks allocation.'},indent=2)+'\n')
print(out)
