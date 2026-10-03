#!/usr/bin/env python3
"""Prepare a bounded grounded-list source proposal in fresh files, never edit source."""
from pathlib import Path
import argparse,difflib,json,hashlib
ap=argparse.ArgumentParser();ap.add_argument('root',type=Path);ap.add_argument('out',type=Path);a=ap.parse_args();root=a.root.resolve();out=a.out.resolve();out.mkdir(parents=True,exist_ok=False)
files={n:(root/'selfhost/src/back/js'/n).read_text() for n in ['fold.bend','jpure.bend','local.bend','region.bend','producer.bend','tree.bend','finite.bend']};old=dict(files)
def once(name,src,dst):
 assert files[name].count(src)==1,(name,src);files[name]=files[name].replace(src,dst)
# Grounded type identity is restricted to exactly List<&2,U32>. Its constructor
# telescopes and specialized owner kind must establish the tagged scalar layout.
files['fold.bend']+='''
# Grounded first-order List; every other instantiation retains generic emission.
@unsafe
def j_list_ground_head(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  String.eq(tg(ty), "ADT") && String.eq(nm(ty), "List") && U32.is_eq(terms_len(ks(ty)), 2) &&
    List.is_empty(&2, String, rm(ty)) && String.eq(tg(kid(ty, 0)), "Qua") && U32.is_eq(qt(kid(ty, 0)), 2) &&
    U32.is_eq(terms_len(ks(kid(ty, 0))), 0) && j_primitive_type(book, wnf(book, kid(ty, 1)), "U32")

@unsafe
def j_list_ground_type(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  +head = wnf(book, ty)
  +d = lookup(book, "List")
  kc(Bool, j_list_ground_head(book, head) && String.eq(dk(d), "ADT") && Bool.not(db(d)) &&
    U32.is_eq(dx(d), 0) && U32.is_eq(da(d), 2) && U32.is_eq(j_region_def_count(dc(d)), 2), u =>
    j_list_ground_kind(wnf(book, j_specialize(book, dt(d), ks(head)))) &&
      j_list_ground_ctor(book, lookup(dc(d), "Nil"), head, 0) && j_list_ground_ctor(book, lookup(dc(d), "Con"), head, 2), u => False{})

@unsafe
def j_list_ground_kind(+ty: KTerm) -> Bool:
  String.eq(tg(ty), "Typ") && U32.is_eq(terms_len(ks(ty)), 1) &&
    String.eq(tg(kid(ty, 0)), "Qua") && U32.is_eq(qt(kid(ty, 0)), 2)

@unsafe
def j_list_ground_ctor(+book: List<&2,KDef>, +c: KDef, +ty: KTerm, +fields: U32) -> Bool:
  kc(Bool, String.eq(dk(c), "Ctr") && Bool.not(db(c)) && U32.is_eq(dx(c), 0) && U32.is_eq(da(c), fields), u =>
    j_list_ground_fields(book, j_specialize(book, dt(c), ks(ty)), fields), u => False{})

@unsafe
def j_list_ground_fields(+book: List<&2,KDef>, +tel: KTerm, +left: U32) -> Bool:
  +head = wnf(book, tel)
  kc(Bool, U32.is_eq(left, 0), u => j_list_ground_head(book, head), u =>
    kc(Bool, String.eq(tg(head), "All") && U32.is_eq(qt(head), 2) &&
      kc(Bool, U32.is_eq(left, 2), u => j_primitive_type(book, wnf(book, kid(head, 0)), "U32"),
        u => j_list_ground_head(book, wnf(book, kid(head, 0)))),
      u => j_list_ground_fields(book, kid(head, 1), U32.sub(left, 1)), u => False{}))

# Preserve prior type domains; a List comparison always checks the full grounded
# parameter identity instead of relying on owner spelling.
@unsafe
def j_region_same_type(+book: List<&2,KDef>, +a: KTerm, +b: KTerm) -> Bool:
  +x = wnf(book, a)
  +y = wnf(book, b)
  kc(Bool, String.eq(nm(x), "List") || String.eq(nm(y), "List"),
    u => j_list_ground_head(book, x) && j_list_ground_head(book, y), u => String.eq(nm(x), nm(y)))
'''
once('jpure.bend','kc(Maybe<&2,U32>, j_region_scalar(book, ty), u => Some{fuel}, u =>','kc(Maybe<&2,U32>, j_region_scalar(book, ty) || j_list_ground_type(book, ty), u => Some{fuel}, u =>')
once('local.bend','kc(Maybe<&2,U32>, j_fold_type(book, ty), u => Some{fuel}, u =>','kc(Maybe<&2,U32>, j_fold_type(book, ty) || j_list_ground_type(book, ty), u => Some{fuel}, u =>')
once('jpure.bend','String.eq(nm(wnf(book, kid(t, 1))), nm(ty))','j_region_same_type(book, kid(t, 1), ty)')
once('jpure.bend','String.eq(nm(wnf(book, j_env(env, ix(t)))), nm(ty))','j_region_same_type(book, j_env(env, ix(t)), ty)')
once('jpure.bend','String.eq(nm(head), nm(result))','j_region_same_type(book, head, result)')
once('jpure.bend','j_pure_args(book, env, ks(t), dt(c), ty, level, s)','j_pure_args(book, env, ks(t), j_specialize(book, dt(c), ks(ty)), ty, level, s)')
once('region.bend','String.eq(nm(wnf(book, kid(t, 1))), nm(ty))','j_region_same_type(book, kid(t, 1), ty)')
once('region.bend','String.eq(nm(wnf(book, j_env(env, ix(t)))), nm(ty))','j_region_same_type(book, j_env(env, ix(t)), ty)')
# A whole pure root may retain grounded List values through residual components.
once('producer.bend','has_name(active, "@producer") && j_fold_type(book, ty)','(has_name(active, "@producer") && j_fold_type(book, ty)) || j_list_ground_type(book, ty)')
once('finite.bend','j_finite_values(book, env, ks(t), dt(c), U32.inc(depth))','j_finite_values(book, env, ks(t), j_specialize(book, dt(c), ks(ty)), U32.inc(depth))')
# Residual structural workers provide a real recursive opportunity for scalar roots.
once('region.bend','def j_region_has_loop(+helpers: List<&2,KDef>)','def j_region_has_loop(+book: List<&2,KDef>, +helpers: List<&2,KDef>)')
once('region.bend','u => j_region_has_loop(rest))','u => kc(Bool, String.eq(tg(dv(d)), "JResidual") && j_pure_valid(j_component_plan(book, lookup(book, dn(d)))), u => True{}, u => j_region_has_loop(book, rest)))')
once('region.bend','j_region_has_loop(j_region_helpers(s))','j_region_has_loop(book, j_region_helpers(s))')
# Existing two-child branches remain unchanged; new one-child branches are closed
# by the independent JPure whole-graph check and proper descendant test.
once('tree.bend','u => False{}))\n\n# Calls keep the existing generic fallback', 'u => j_linear_leaf(book, env, t, d)))\n\n# Calls keep the existing generic fallback')
once('tree.bend','"if($frame.phase===0){$frame.left=$value;$frame.phase=1;" ++\n    j_component_emit', '"if($frame.phase===2){" ++ j_component_emit(book, Nil{}, dv(d), dt(d), j_component_values(0, da(d)), d, 3) ++ "--$top;}else if($frame.phase===0){$frame.left=$value;$frame.phase=1;" ++\n    j_component_emit')
once('tree.bend','kc(String, U32.is_eq(phase, 2), u =>\n      "const " ++ j_local(ix(kid(t, 0)))', 'kc(String, U32.is_eq(j_component_refs([t], dn(d), 1024, 0), 1), u => j_linear_finish(book, env, t, ty, d, phase), u =>\n    kc(String, U32.is_eq(phase, 2), u =>\n      "const " ++ j_local(ix(kid(t, 0)))')
once('tree.bend','j_component_enter(book, env, j_call_spine(kid(kid(t, phase), 0), Nil{}), d, phase)))','j_component_enter(book, env, j_call_spine(kid(kid(t, phase), 0), Nil{}), d, phase))))')
files['tree.bend']+=''''
# One structural child: direct tail transfer, or reconstruction through a tagged
# constructor / saturated known combiner. An inert sequential alias may precede
# the call; effectful or allocating lets remain generic.
@unsafe
def j_linear_alias(+t: KTerm, +name: String) -> Bool:
  String.eq(tg(t), "Let") && U32.is_eq(terms_len(ks(t)), 2) &&
    Bool.not(U32.is_eq(qt(kid(t, 0)), 0)) && j_region_field_atom(j_strip(kid(kid(t, 0), 0))) &&
    U32.is_eq(j_component_refs([kid(t, 0)], name, 1024, 0), 0)

@unsafe
def j_linear_spine(+t: KTerm) -> KTerm:
  kc(KTerm, String.eq(tg(t), "Ctr"), u => kt("Call", nm(t), 0, 0, ks(t)), u => j_call_spine(t, Nil{}))

@unsafe
def j_linear_tel(+book: List<&2,KDef>, +t: KTerm, +ty: KTerm) -> KTerm:
  kc(KTerm, String.eq(tg(t), "Ctr"),
    u => j_specialize(book, dt(j_layout_ctor(book, wnf(book, ty), nm(t))), ks(wnf(book, ty))),
    u => dt(lookup(book, nm(j_linear_spine(t)))))

@unsafe
def j_linear_child(+env: List<&2,KTerm>, +args: List<&2,KTerm>, +d: KDef, +at: U32) -> U32:
  match args:
    case Nil{}: 32
    case Con{h, rest}: kc(U32, j_component_self(env, h, d), u => at, u => j_linear_child(env, rest, d, U32.inc(at)))

@unsafe
def j_linear_leaf(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +d: KDef) -> Bool:
  kc(Bool, U32.is_eq(j_component_refs([t], dn(d), 1024, 0), 1), u =>
    kc(Bool, j_linear_alias(t, dn(d)), u => j_linear_leaf(book, j_context(book, env, ks(t)), j_strip(kid(t, 1)), d), u =>
    kc(Bool, j_component_self(env, t, d), u => True{}, u =>
      j_linear_combine(book, env, t, d, j_linear_spine(t)))), u => False{})

@unsafe
def j_linear_combine(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +d: KDef, +spine: KTerm) -> Bool:
  +target = lookup(book, nm(spine))
  (String.eq(tg(t), "Ctr") || (String.eq(tg(spine), "Call") && Bool.not(String.eq(nm(spine), dn(d))) &&
    U32.is_eq(terms_len(ks(spine)), da(target)))) &&
    U32.is_lt(j_linear_child(env, ks(spine), d, 0), terms_len(ks(spine)))

@unsafe
def j_linear_finish(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +d: KDef, +phase: U32) -> String:
  kc(String, j_linear_alias(t, dn(d)), u =>
    "{" ++ j_nat_loop_values(book, env, ks(t), 0) ++ "{" ++ j_nat_loop_names(ks(t), 0) ++
    j_linear_finish(book, j_context(book, env, ks(t)), j_strip(kid(t, 1)), ty, d, phase) ++ "}}", u =>
    kc(String, j_component_self(env, t, d), u =>
      "const $next=[" ++ j_apply_args(book, env, ks(j_call_spine(t, Nil{})), dt(d)) ++ "];" ++
      j_component_assign(0, da(d)) ++ "continue $visit;", u =>
      j_linear_split(book, env, t, ty, d, phase, j_linear_spine(t))))

@unsafe
def j_linear_split(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +d: KDef, +phase: U32, +spine: KTerm) -> String:
  +child = j_linear_child(env, ks(spine), d, 0)
  +tel = j_linear_tel(book, t, ty)
  kc(String, U32.is_eq(phase, 3), u =>
    "$value=" ++ kc(String, String.eq(tg(t), "Ctr"),
      u => "ctor(" ++ j_quote(nm(t)) ++ ",[" ++ j_producer_unary_resume(book, env, ks(spine), tel, child, 0) ++ "])",
      u => j_linear_combiner_emit(book, nm(spine), j_producer_unary_resume(book, env, ks(spine), tel, child, 0))) ++ ";", u =>
    j_producer_unary_before(book, env, ks(spine), tel, child, 0) ++
    "const $next=[" ++ j_apply_args(book, env, ks(j_call_spine(j_strip(terms_at(ks(spine), child)), Nil{})), dt(d)) ++ "];" ++
    "let $saved=$top<$frames.length?$frames[$top]:null;if(!$saved)$saved=$frames[$top]={args:null,left:null,phase:0,before:null};" ++
    "$saved.args=[" ++ j_component_save(0, da(d)) ++ "];$saved.before=[" ++ j_region_vector_names("$u", 0, child) ++
    "];$saved.phase=2;++$top;" ++ j_component_assign(0, da(d)) ++ "continue $visit;")
'''

files['tree.bend']+='''
@unsafe
def j_linear_combiner_emit(+book: List<&2,KDef>, +name: String, +args: String) -> String:
  +d = lookup(book, name)
  kc(String, j_finite_ready(book, d), u =>
    "((" ++ j_region_parameters(0, da(d)) ++ ")=>{" ++
      j_finite_emit(book, Nil{}, dv(d), dt(d), j_finite_slots(0, da(d))) ++ "})(" ++ args ++ ")",
    u => "callOwned(get(G," ++ j_quote(name) ++ "),[" ++ args ++ "])")
'''
files['tree.bend']=files['tree.bend'].replace("\n'\n# One structural child","\n# One structural child")
for name,text in files.items():
 (out/name).write_text(text)
patch=''.join(''.join(difflib.unified_diff(old[n].splitlines(True),files[n].splitlines(True),fromfile='a/selfhost/src/back/js/'+n,tofile='b/selfhost/src/back/js/'+n)) for n in files if files[n]!=old[n]);(out/'source.patch').write_text(patch)
(out/'proposal.json').write_text(json.dumps(dict(kind='phase40-ground-list-source-proposal',complete=False,files=[n for n in files if files[n]!=old[n]],sha256=hashlib.sha256(patch.encode()).hexdigest()),indent=2)+'\n')
