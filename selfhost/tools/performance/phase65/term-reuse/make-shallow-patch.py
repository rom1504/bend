#!/usr/bin/env python3
"""Data-only isolated patch generator. Never changes production source."""
from pathlib import Path
import hashlib, json, difflib

root = Path(__file__).resolve().parents[5]
rel = Path('selfhost/src/core/term.bend')
source = root / rel
before = source.read_text()
old = '  kc(KTerm, String.eq(tg(t), "Var"), u => kc(KTerm, U32.is_eq(ix(t), id), u => v, u => t), u => subst_node(t, id, v))'
new = '  kc(KTerm, String.eq(tg(t), "Var"), u => kc(KTerm, U32.is_eq(ix(t), id), u => v, u => t),\n    u => kc(KTerm, core_subst_shallow(t, id), u => t, u => subst_node(t, id, v)))'
assert before.count(old) == 1
anchor = '@unsafe\ndef subst(\n'
declaration = 'law core_subst_shallow:\n  for +t: KTerm\n  for +id: U32\n  Bool\n\n'
assert before.count(anchor) == 1
helpers = '''# Constant-work substitution admission. This predicate visits at most the
# parent and two leaf children; false falls back to ordinary substitution.
# Return the original term in subst, outside all constructor match scopes.
@unsafe
def core_subst_leaf(+t: KTerm, +id: U32) -> Bool:
  kc(Bool, String.eq(tg(t), "Var"), u => Bool.not(U32.is_eq(ix(t), id)),
    u => core_literal(t) || (Bool.not(String.eq(tg(t), "App")) && List.is_empty(&2, KTerm, ks(t))))

@unsafe
def core_subst_shallow_app(+t: KTerm) -> Bool:
  kc(Bool, String.eq(tg(t), "App"),
    u => String.eq(nm(t), "") && U32.is_eq(ix(t), 0) && U32.is_eq(qt(t), 0) && core_subst_stable_app(ks(t), rm(t)),
    u => True{})

@unsafe
def core_subst_shallow_tail(+t: KTerm, +id: U32, +rest: List<&2,KTerm>) -> Bool:
  match rest:
    case Nil{}: Bool.not(String.eq(tg(t), "App"))
    case Con{x, tail}:
      kc(Bool, List.is_empty(&2, KTerm, tail),
        u => kc(Bool, core_subst_leaf(x, id), u => core_subst_shallow_app(t), u => False{}),
        u => False{})

@unsafe
def core_subst_shallow_kids(+t: KTerm, +id: U32, +kids: List<&2,KTerm>) -> Bool:
  match kids:
    case Nil{}: Bool.not(String.eq(tg(t), "App"))
    case Con{h, rest}:
      kc(Bool, core_subst_leaf(h, id), u => core_subst_shallow_tail(t, id, rest), u => False{})

@unsafe
def core_subst_shallow(t, id):
  kc(Bool, String.eq(tg(t), "Var"), u => Bool.not(U32.is_eq(ix(t), id)),
    u => core_subst_shallow_kids(t, id, ks(t)))

'''
end_anchor = '@unsafe\ndef norm_join(\n'
assert before.count(end_anchor) == 1
after = before.replace(old, new).replace(anchor, declaration+anchor).replace(end_anchor, helpers+end_anchor)
assert source.read_text() == before
out = Path(__file__).with_name('shallow-v1')
out.mkdir(exist_ok=False)
for name,text in [('before.bend',before),('after.bend',after)]:
    (out/name).write_text(text)
patch = ''.join(difflib.unified_diff(before.splitlines(keepends=True),after.splitlines(keepends=True),fromfile='a/'+str(rel),tofile='b/'+str(rel)))
(out/'candidate.patch').write_text(patch)
sha = lambda s: hashlib.sha256(s.encode()).hexdigest()
(out/'manifest.json').write_text(json.dumps({'kind':'phase65-shallow-substitution-v1','productionApplied':False,'targetExecuted':False,'source':str(rel),'beforeSha256':sha(before),'afterSha256':sha(after),'patchSha256':sha(patch),'physicalLineDelta':len(after.splitlines())-len(before.splitlines()),'addedDefinitions':5,'addedTypes':0,'contract':'At most two immediate unchanged leaf children; exact canonical App check; original caller term returned outside constructor matches; old substitution fallback and beta semantics retained.'},indent=2)+'\n')
print(out)
