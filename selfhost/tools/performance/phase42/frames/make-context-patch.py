from pathlib import Path
import difflib
root=Path('.')
tree_path='selfhost/src/back/js/tree.bend'
emit_path='selfhost/src/back/js/emit.bend'
tree=(root/tree_path).read_text();emit=(root/emit_path).read_text()
start=tree.index('@unsafe\ndef j_component_declaration(')
end=tree.index('\n@unsafe\ndef j_component_values(',start)
old=tree[start:end].rstrip()
new=old.replace('    "function "', '    j_component_covered_declaration(book, d, j_covered_term(book, j_pure_remove(j_pure_defs(pure), dn(d)), dv(d))), u => "")\n\n@unsafe\ndef j_component_covered_declaration(+book: List<&2,KDef>, +d: KDef, +body: KTerm) -> String:\n  "function "',1)
assert new.endswith(', u => "")')
new=new[:-len(', u => "")')]
new=new.replace('j_component_emit(book, Nil{}, dv(d),','j_component_emit(book, Nil{}, body,')
# Retain structural planning/ref counts on the original d. Only emission sees body.
newtree=tree[:start]+new+tree[end:]
newtree+='''

# Inherited proof context is used only for the body of an independently admitted
# private worker. Its public and generic call boundaries retain the complete
# graph guard. Exact definitions prevent same-name or stale graph substitution.
@unsafe
def j_covered_defs(+book: List<&2,KDef>, +context: List<&2,KDef>, +needed: List<&2,KDef>) -> Bool:
  match needed:
    case Nil{}: True{}
    case Con{d, rest}:
      +found = lookup(context, dn(d))
      kc(Bool, String.eq(dk(found), "Def") && exact_def(d, found) && exact_def(d, lookup(book, dn(d))),
        u => j_covered_defs(book, context, rest), u => False{})

# Annotation preserves original call-result typing for the ordinary shared
# binder/argument emitter. Lowering plans are never sent back to the checker.
@unsafe
def j_covered_result(+ty: KTerm, +args: List<&2,KTerm>) -> KTerm:
  match args:
    case Nil{}: ty
    case Con{h, rest}: j_covered_result(j_app_type(ty, h), rest)

@unsafe
def j_covered_term(+book: List<&2,KDef>, +context: List<&2,KDef>, +t: KTerm) -> KTerm:
  kc(KTerm, String.eq(tg(t), "Ann"), u =>
    k_with_children(t, [j_covered_term(book, context, kid(t, 0)), kid(t, 1)]), u =>
  kc(KTerm, String.eq(tg(t), "Var") || String.eq(tg(t), "Ref") || String.eq(tg(t), "Lit"), u => t, u =>
  kc(KTerm, String.eq(tg(t), "App"), u =>
    j_covered_app(book, context, t, k_with_children(t, j_covered_terms(book, context, ks(t)))), u =>
    k_with_children(t, j_covered_terms(book, context, ks(t))))))

@unsafe
def j_covered_terms(+book: List<&2,KDef>, +context: List<&2,KDef>, +ts: List<&2,KTerm>) -> List<&2,KTerm>:
  match ts:
    case Nil{}: Nil{}
    case Con{h, rest}: Con{j_covered_term(book, context, h), j_covered_terms(book, context, rest)}

@unsafe
def j_covered_app(+book: List<&2,KDef>, +context: List<&2,KDef>, +original: KTerm, +rebuilt: KTerm) -> KTerm:
  +spine = j_call_spine(original, Nil{})
  +d = lookup(book, nm(spine))
  kc(KTerm, String.eq(tg(spine), "Call") && U32.is_eq(terms_len(ks(spine)), da(d)) &&
    String.eq(dk(lookup(context, dn(d))), "Def") && exact_def(d, lookup(context, dn(d))), u =>
      j_covered_component(book, context, original, rebuilt, d, j_component_plan(book, d)),
    u => j_direct_call_term(book, context, rebuilt))

@unsafe
def j_covered_component(+book: List<&2,KDef>, +context: List<&2,KDef>, +original: KTerm, +rebuilt: KTerm, +d: KDef, +pure: JPure) -> KTerm:
  kc(KTerm, j_pure_valid(pure) && j_covered_defs(book, context, j_pure_defs(pure)), u =>
    j_region_annotate(kt("JCall", dn(d), 0, 1, ks(j_call_spine(rebuilt, Nil{}))),
      j_covered_result(dt(d), ks(j_call_spine(original, Nil{})))),
    u => j_direct_call_term(book, context, rebuilt))
'''
needle='"JCall"), u => j_region_name(nm(t)) ++ "("'
replacement='"JCall"), u => j_region_name(nm(t)) ++ kc(String, U32.is_eq(qt(t), 1), u => "$tree", u => "") ++ "("'
assert emit.count(needle)==1
newemit=emit.replace(needle,replacement)
out=Path('selfhost/tools/performance/phase42/frames/context-source.patch')
patch=''.join(difflib.unified_diff(tree.splitlines(True),newtree.splitlines(True),fromfile='a/'+tree_path,tofile='b/'+tree_path))
patch+=''.join(difflib.unified_diff(emit.splitlines(True),newemit.splitlines(True),fromfile='a/'+emit_path,tofile='b/'+emit_path))
out.write_text(patch)
