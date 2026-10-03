from pathlib import Path
import difflib
paths=['selfhost/src/back/js/tree.bend','selfhost/src/back/js/emit.bend']
old={p:Path(p).read_text() for p in paths};new=dict(old)
new[paths[0]]+='''

# Only independently admitted private bodies invoke this plan transform. Keep
# original Ctr shape and identity so structural linear reconstruction and shared
# binder typing still see their original source nodes. No public expression is
# marked, and no native representation is changed.
@unsafe
def j_owned_term(+t: KTerm) -> KTerm:
  kc(KTerm, String.eq(tg(t), "Ann"), u =>
    k_with_children(t, [j_owned_term(kid(t, 0)), kid(t, 1)]), u =>
  kc(KTerm, String.eq(tg(t), "Ctr"), u =>
    k_rebuild(t, nm(t), ix(t), qt(t), j_owned_terms(ks(t)), Con{"$private.owned.ctor", rm(t)}, kb(t), ke(t)),
    u => k_with_children(t, j_owned_terms(ks(t)))))

@unsafe
def j_owned_terms(+ts: List<&2,KTerm>) -> List<&2,KTerm>:
  match ts:
    case Nil{}: Nil{}
    case Con{h, rest}: Con{j_owned_term(h), j_owned_terms(rest)}

# The runtime ctor's nonnative branch is exactly {$:name,a:fields}; it has no
# registration or ownership side effect. Preserve its tag, field array, field
# order, fresh root allocation, and shared child references literally.
@unsafe
def j_owned_ctor(+book: List<&2,KDef>, +t: KTerm, +ty: KTerm) -> Bool:
  kc(Bool, has_name(rm(t), "$private.owned.ctor"),
    u => j_owned_ctor_type(book, t, wnf(book, ty)), u => False{})

@unsafe
def j_owned_ctor_type(+book: List<&2,KDef>, +t: KTerm, +head: KTerm) -> Bool:
  +owner = lookup(book, nm(head))
  +c = j_layout_ctor(book, head, nm(t))
  String.eq(tg(head), "ADT") &&
    String.eq(dk(owner), "ADT") && Bool.not(db(owner)) && j_pure_type(book, head) &&
    String.eq(dk(c), "Ctr") && String.eq(dn(c), nm(t)) && Bool.not(db(c)) &&
    U32.is_eq(terms_len(ks(t)), da(c))
'''
needle='u => "ctor(" ++ j_quote(nm(t)) ++ ",[" ++ j_producer_unary_resume(book, env, ks(spine), tel, child, 0) ++ "])"'
replacement='u => kc(String, j_owned_ctor(book, t, ty), u => "({$:" ++ j_quote(nm(t)) ++ ",a:[" ++ j_producer_unary_resume(book, env, ks(spine), tel, child, 0) ++ "]})", u => "ctor(" ++ j_quote(nm(t)) ++ ",[" ++ j_producer_unary_resume(book, env, ks(spine), tel, child, 0) ++ "])" )'
assert new[paths[0]].count(needle)==1
new[paths[0]]=new[paths[0]].replace(needle,replacement)
needle='j_component_covered_declaration(book, d, j_covered_term(book, j_pure_remove(j_pure_defs(pure), dn(d)), dv(d)))'
replacement='j_component_covered_declaration(book, d, j_owned_term(j_covered_term(book, j_pure_remove(j_pure_defs(pure), dn(d)), dv(d))))'
assert new[paths[0]].count(needle)==1
new[paths[0]]=new[paths[0]].replace(needle,replacement)
# Activation requires the inherited worker-call patch already present.
needle='  kc(String, String.eq(literal, ""), u => "ctor(" ++ j_quote(nm(t)) ++ ",[" ++ j_ctor_args(book, env, ks(t), j_specialize(book, dt(j_layout_ctor(book, wnf(book, ty), nm(t))), ks(wnf(book, ty)))) ++ "])", u => literal)'
replacement='''  kc(String, String.eq(literal, ""), u =>
    kc(String, j_owned_ctor(book, t, ty),
      u => "({$:" ++ j_quote(nm(t)) ++ ",a:[" ++ j_ctor_args(book, env, ks(t), j_specialize(book, dt(j_layout_ctor(book, wnf(book, ty), nm(t))), ks(wnf(book, ty)))) ++ "]})",
      u => "ctor(" ++ j_quote(nm(t)) ++ ",[" ++ j_ctor_args(book, env, ks(t), j_specialize(book, dt(j_layout_ctor(book, wnf(book, ty), nm(t))), ks(wnf(book, ty)))) ++ "])"), u => literal)'''
assert new[paths[1]].count(needle)==1
new[paths[1]]=new[paths[1]].replace(needle,replacement)
patch=''.join(''.join(difflib.unified_diff(old[p].splitlines(True),new[p].splitlines(True),fromfile='a/'+p,tofile='b/'+p)) for p in paths)
Path('selfhost/tools/performance/phase42/frames/owned-constructor-source.patch').write_text(patch)
