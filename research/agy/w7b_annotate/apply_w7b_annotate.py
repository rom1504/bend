#!/usr/bin/env python3
"""Wave 7B: Slash annotate_selected + jl_checked_error + fix gameoflife -O2 regression.

Usage:
  python3 -B research/agy/w7b_annotate/apply_w7b_annotate.py --src <in.bend> --dst <out.bend>

Changes (100% semantically identical):
  1. Hoist kw_initial(book) once in agy_ka_defs_indexed (ka_def_with_kw).
  2. Fast O(1) WHNF short-circuit (w7b_wnf) for already-WHNF tags (ADT, All, Typ, Set, Qnt, Eql, Emp, Uni, KLambda, KLiteral).
  3. Zero-allocation w7b_subst_fast (w7b_needs_subst check before p177s_entry/subst) in ka_lam, ka_spine_step, ka_type_app, ka_args_head.
  4. Direct parameter-match dispatch (no kc closure allocs, frequency-ordered Var/Ref/App/Ctr/Mat/Let/Lam/Ann/Rwt) in annotate/ka_node/ka_lam/ka_args_cached.
  5. Flip j_layout_array_intrinsic to check 'A' prefix + j_layout_array_name BEFORE lookup(book, nm(f)), eliminate kc closures in jl_node/jl_term/jl_app/jl_match/jl_fields/jl_bindings/p142j_*, and fast-path non-special Ctr types in jl_node.
  6. Fix gameoflife -O2 regression: guard giant-non-loop size gates in x185_function_place, x198n_place, x190_joint_frame with w7b_stmts_has_call(body) so pure scalar leaf functions (like gameoflife's step) keep 100% full -O2 optimization and register allocation.
"""

import argparse
from pathlib import Path


def replace_once(src: str, old: str, new: str, label: str) -> str:
    n = src.count(old)
    if n != 1:
        raise RuntimeError(f"[{label}] expected 1 occurrence, found {n}")
    return src.replace(old, new, 1)


def apply_patch(src: str) -> str:
    # ------------------------------------------------------------------
    # 1. annotate_selected / agy_ka_defs_indexed / ka_def / annotate / ka_node
    #    + w7b_wnf + w7b_subst_fast
    # ------------------------------------------------------------------
    old_ann = """@unsafe
def agy_ka_defs_indexed(+book: List<&2, KDef>, ds: List<&2, KDef>, +stops_set: KDef) -> List<&2, KDef>:
  match ds:
    case Nil{}:
      Nil{}
    case Con{+d, rest}:
      +name = dn(d)
      +h = index_hash(name, 2166136261)
      Con{kc(KDef, p88_string_eq(dk(index_find(stops_set, name, h, 32)), "P142JSeen"), u => d, u => ka_def(book, d)), agy_ka_defs_indexed(book, rest, stops_set)}

@unsafe
def agy_stops_set(names: List<&2, String>, acc: KDef) -> KDef:
  match names:
    case Nil{}: acc
    case Con{+name, rest}:
      agy_stops_set(rest, index_set(acc, KDef{name, "P142JSeen", 0, 0,
        {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},
        {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Nil{}, False{}, False{}},
        index_hash(name, 2166136261), 32))

@unsafe
def annotate_selected(book, selected, stops):
  agy_ka_defs_indexed(book_context(book), selected, agy_stops_set(stops, missing()))

# Module: src/check/annotate.bend:148
@unsafe
def ka_defs_except(book, ds, stops):
  agy_ka_defs_indexed(book, ds, agy_stops_set(stops, missing()))

# Module: src/check/annotate.bend:164
@unsafe
def ka_def(book, d):
  KDef{dn(d), dk(d), da(d), dx(d), dt(d), kc(KTerm, p98_tag_eq(dv(d), "Absent") || p98_tag_eq(dv(d), "Foreign") || U32.is_gt(dx(d), 0), u => dv(d), u => annotate(KEnv{kw_initial(book), dn(d), ref(dn(d)), 0, Nil{}, du(d), 0}, Nil{}, dv(d), dt(d))), dc(d), db(d), du(d)}

# Module: src/check/annotate.bend:168
@unsafe
def annotate(e, ctx, t, ty):
  ka_annotated(e, ctx, core_beta(t), wnf(cb(e), ty))"""

    new_ann = """@unsafe
def w7b_wnf_go(fast: Bool, +book: List<&2, KDef>, +t: KTerm) -> KTerm:
  match fast:
    case True{}: t
    case False{}: wnf(book, t)

@unsafe
def w7b_wnf(+book: List<&2, KDef>, +t: KTerm) -> KTerm:
  match t:
    case KLambda{_, _, _, _, _, _, _, _}: t
    case KLiteral{_, _, _, _, _}: t
    case KTerm{+tag, _, _, _, _, _, _, _}:
      w7b_wnf_go(p88_string_eq(tag, "ADT") || p88_string_eq(tag, "All") || p88_string_eq(tag, "Typ") || p88_string_eq(tag, "Set") || p88_string_eq(tag, "Qnt") || p88_string_eq(tag, "Eql") || p88_string_eq(tag, "Emp") || p88_string_eq(tag, "Uni"), book, t)

law w7b_needs_subst:
  for +t: KTerm
  for +id: U32
  Bool

@unsafe
def w7b_needs_subst_list(ts: List<&2, KTerm>, +id: U32) -> Bool:
  match ts:
    case Nil{}: False{}
    case Con{h, rest}:
      w7b_needs_subst(h, id) || w7b_needs_subst_list(rest, id)

@unsafe
def w7b_needs_subst_all(shadowed: Bool, +kids: List<&2, KTerm>, +id: U32) -> Bool:
  match shadowed:
    case True{}:
      match kids:
        case Con{dom, _}: w7b_needs_subst(dom, id)
        case Nil{}: False{}
    case False{}: w7b_needs_subst_list(kids, id)

@unsafe
def w7b_ns_lam(c: Bool, +bid: U32, +kids: List<&2, KTerm>, +id: U32) -> Bool:
  match c:
    case True{}: U32.is_ne(bid, id) && w7b_needs_subst_list(kids, id)
    case False{}: w7b_needs_subst_list(kids, id)

@unsafe
def w7b_ns_app(c: Bool, +tag: String, +bid: U32, +kids: List<&2, KTerm>, +id: U32) -> Bool:
  match c:
    case True{}: True{}
    case False{}: w7b_ns_lam(p88_string_eq(tag, "Lam"), bid, kids, id)

@unsafe
def w7b_ns_var(c: Bool, +tag: String, +bid: U32, +kids: List<&2, KTerm>, +id: U32) -> Bool:
  match c:
    case True{}: U32.is_eq(bid, id) || w7b_needs_subst_list(kids, id)
    case False{}: w7b_ns_app(p88_string_eq(tag, "App"), tag, bid, kids, id)

@unsafe
def w7b_ns_all(c: Bool, +tag: String, +bid: U32, +kids: List<&2, KTerm>, +id: U32) -> Bool:
  match c:
    case True{}: w7b_needs_subst_all(U32.is_eq(bid, id), kids, id)
    case False{}: w7b_ns_var(p88_string_eq(tag, "Var"), tag, bid, kids, id)

@unsafe
def w7b_ns_adt(c: Bool, +tag: String, +bid: U32, +kids: List<&2, KTerm>, +id: U32) -> Bool:
  match c:
    case True{}: w7b_needs_subst_list(kids, id)
    case False{}: w7b_ns_all(p88_string_eq(tag, "All"), tag, bid, kids, id)

@unsafe
def w7b_needs_subst(t, id):
  match t:
    case KLiteral{_, _, _, _, _}: False{}
    case KLambda{_, bid, _, kids, _, _, _, _}:
      U32.is_ne(bid, id) && w7b_needs_subst_list(kids, id)
    case KTerm{+tag, _, bid, _, kids, _, _, _}:
      w7b_ns_adt(p88_string_eq(tag, "ADT"), tag, bid, kids, id)

@unsafe
def w7b_subst_if(need: Bool, +t: KTerm, +id: U32, +v: KTerm) -> KTerm:
  match need:
    case True{}: subst(t, id, v)
    case False{}: t

@unsafe
def w7b_subst_fast(+t: KTerm, +id: U32, +v: KTerm) -> KTerm:
  w7b_subst_if(w7b_needs_subst(t, id), t, id, v)

@unsafe
def w7b_ka_def_if(skip: Bool, +kw: KWorld, +d: KDef, +val: KTerm) -> KDef:
  match skip:
    case True{}: d
    case False{}:
      +name = dn(d)
      KDef{name, dk(d), da(d), dx(d), dt(d), annotate(KEnv{kw, name, ref(name), 0, Nil{}, du(d), 0}, Nil{}, val, dt(d)), dc(d), db(d), du(d)}

@unsafe
def ka_def_with_kw(+kw: KWorld, +d: KDef) -> KDef:
  +val = dv(d)
  w7b_ka_def_if(p98_tag_eq(val, "Absent") || p98_tag_eq(val, "Foreign") || U32.is_gt(dx(d), 0), kw, d, val)

@unsafe
def w7b_ka_stop_if(stop: Bool, +kw: KWorld, +d: KDef) -> KDef:
  match stop:
    case True{}: d
    case False{}: ka_def_with_kw(kw, d)

@unsafe
def agy_ka_defs_kw(+kw: KWorld, ds: List<&2, KDef>, +stops_set: KDef) -> List<&2, KDef>:
  match ds:
    case Nil{}:
      Nil{}
    case Con{+d, rest}:
      +name = dn(d)
      +h = index_hash(name, 2166136261)
      Con{w7b_ka_stop_if(p88_string_eq(dk(index_find(stops_set, name, h, 32)), "P142JSeen"), kw, d), agy_ka_defs_kw(kw, rest, stops_set)}

@unsafe
def agy_ka_defs_indexed(+book: List<&2, KDef>, ds: List<&2, KDef>, +stops_set: KDef) -> List<&2, KDef>:
  agy_ka_defs_kw(kw_initial(book), ds, stops_set)

@unsafe
def agy_stops_set(names: List<&2, String>, acc: KDef) -> KDef:
  match names:
    case Nil{}: acc
    case Con{+name, rest}:
      agy_stops_set(rest, index_set(acc, KDef{name, "P142JSeen", 0, 0,
        {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},
        {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Nil{}, False{}, False{}},
        index_hash(name, 2166136261), 32))

@unsafe
def annotate_selected(book, selected, stops):
  agy_ka_defs_indexed(book_context(book), selected, agy_stops_set(stops, missing()))

# Module: src/check/annotate.bend:148
@unsafe
def ka_defs_except(book, ds, stops):
  agy_ka_defs_indexed(book, ds, agy_stops_set(stops, missing()))

# Module: src/check/annotate.bend:164
@unsafe
def ka_def(book, d):
  ka_def_with_kw(kw_initial(book), d)

# Module: src/check/annotate.bend:168
@unsafe
def w7b_ka_rwt(c: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm) -> KTerm:
  match c:
    case True{}: ka_rwt(e, ctx, t, w7b_wnf(cb(e), ka_type(e, ctx, kid(t, 0))))
    case False{}: t

@unsafe
def w7b_ka_ann(c: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +tag: String) -> KTerm:
  match c:
    case True{}: ka_node(e, ctx, kid(t, 0), w7b_wnf(cb(e), kid(t, 1)))
    case False{}: w7b_ka_rwt(p88_string_eq(tag, "Rwt"), e, ctx, t)

@unsafe
def w7b_ka_lam_b(c: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +tag: String, +ty: KTerm) -> KTerm:
  match c:
    case True{}: ka_lam(e, ctx, t, ty)
    case False{}: w7b_ka_ann(p88_string_eq(tag, "Ann"), e, ctx, t, tag)

@unsafe
def w7b_ka_let_b(c: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +tag: String, +ty: KTerm) -> KTerm:
  match c:
    case True{}: kt("Let", nm(t), ix(t), qt(t), ka_let(e, ctx, ctx, ks(t), ty))
    case False{}: w7b_ka_lam_b(p88_string_eq(tag, "Lam"), e, ctx, t, tag, ty)

@unsafe
def w7b_ka_mat_b(c: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +tag: String, +ty: KTerm) -> KTerm:
  match c:
    case True{}: ka_mat(e, ctx, t, ty, w7b_wnf(cb(e), kid(ty, 0)))
    case False{}: w7b_ka_let_b(p88_string_eq(tag, "Let"), e, ctx, t, tag, ty)

@unsafe
def w7b_ka_ctr_b(c: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +tag: String, +ty: KTerm) -> KTerm:
  match c:
    case True{}: kt("Ctr", nm(t), ix(t), qt(t), ka_args_cached(e, ctx, tele_fill(cb(e), dt(lookup(dc(lookup(cb(e), nm(ty))), nm(t))), ks(ty)), ks(t)))
    case False{}: w7b_ka_mat_b(p88_string_eq(tag, "Mat"), e, ctx, t, tag, ty)

@unsafe
def w7b_ka_spine_b(c: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm) -> KTerm:
  match c:
    case True{}: ka_app_spine(e, ctx, t)
    case False{}: ka_app(e, ctx, t, w7b_wnf(cb(e), ka_type(e, ctx, kid(t, 0))))

@unsafe
def w7b_ka_app_b(c: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +tag: String, +ty: KTerm) -> KTerm:
  match c:
    case True{}: w7b_ka_spine_b(ka_spine_eligible(t), e, ctx, t)
    case False{}: w7b_ka_ctr_b(p88_string_eq(tag, "Ctr"), e, ctx, t, tag, ty)

@unsafe
def w7b_ka_leaf_b(c: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +tag: String, +ty: KTerm) -> KTerm:
  match c:
    case True{}: t
    case False{}: w7b_ka_app_b(p88_string_eq(tag, "App"), e, ctx, t, tag, ty)

@unsafe
def w7b_ann_lit_if(ok: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +wty: KTerm) -> KTerm:
  match ok:
    case True{}: ka_wrap(t, wty)
    case False{}: ka_wrap(ka_node(e, ctx, core_literal_step(t), wty), wty)

@unsafe
def w7b_ann_app_if(isApp: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +tag: String, +wty: KTerm) -> KTerm:
  match isApp:
    case True{}: ka_annotated(e, ctx, core_beta(t), wty)
    case False{}: ka_wrap(w7b_ka_leaf_b(p88_string_eq(tag, "Var") || p88_string_eq(tag, "Ref"), e, ctx, t, tag, wty), wty)

@unsafe
def w7b_annotate_wty(+e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +wty: KTerm) -> KTerm:
  match t:
    case KLiteral{_, _, _, _, _}:
      w7b_ann_lit_if(core_literal_type(cb(e), t, wty), e, ctx, t, wty)
    case KLambda{_, _, _, _, _, _, _, _}:
      ka_wrap(ka_lam(e, ctx, t, wty), wty)
    case KTerm{+tag, _, _, _, _, _, _, _}:
      w7b_ann_app_if(p88_string_eq(tag, "App"), e, ctx, t, tag, wty)

@unsafe
def annotate(e, ctx, t, ty):
  w7b_annotate_wty(e, ctx, t, w7b_wnf(cb(e), ty))"""

    src = replace_once(src, old_ann, new_ann, "annotate_core")

    # ------------------------------------------------------------------
    # 2. ka_type_app, ka_lam, ka_args_head, ka_spine_finish, ka_spine_step,
    #    ka_app_spine_finish, ka_args_cached -> use w7b_subst_fast + w7b_wnf
    # ------------------------------------------------------------------
    old_ka_sub = """@unsafe
def ka_type_app(e, t, fty):
  subst(kid(fty, 1), ix(fty), kid(t, 1))

# Module: src/check/annotate.bend:210
@unsafe
def ka_lam(e, ctx, t, ty):
  k_lam(nm(t), ix(t), kc(U32, k_quantity_present(t) && U32.is_eq(qt(t), 2) && U32.is_eq(qt(ty), 1), u => 2, u => qt(ty)), Con{annotate(e, ctx_bind(ctx, ix(t), qt(ty), nm(t), kid(ty, 0)), kid(t, 0), subst(kid(ty, 1), ix(ty), var(nm(t), ix(t)))), Nil{}}, 0, 0, False{})"""

    new_ka_sub = """@unsafe
def ka_type_app(e, t, fty):
  w7b_subst_fast(kid(fty, 1), ix(fty), kid(t, 1))

@unsafe
def w7b_lam_q_if(c: Bool, +q: U32) -> U32:
  match c:
    case True{}: 2
    case False{}: q

# Module: src/check/annotate.bend:210
@unsafe
def ka_lam(e, ctx, t, ty):
  +q = w7b_lam_q_if(k_quantity_present(t) && U32.is_eq(qt(t), 2) && U32.is_eq(qt(ty), 1), qt(ty))
  +name = nm(t)
  +id = ix(t)
  k_lam(name, id, q, Con{annotate(e, ctx_bind(ctx, id, qt(ty), name, kid(ty, 0)), kid(t, 0), w7b_subst_fast(kid(ty, 1), ix(ty), var(name, id))), Nil{}}, 0, 0, False{})"""

    src = replace_once(src, old_ka_sub, new_ka_sub, "ka_lam_subst")

    old_ka_spine = """@unsafe
def ka_spine_finish(e, ctx, arg, r):
  match r:
    case KAnnotatedSpine{node, ty}: ka_spine_step(e, ctx, arg, node, wnf(cb(e), ty))

# Module: src/check/annotate.bend:315
@unsafe
def ka_spine_step(e, ctx, arg, node, fty):
  KAnnotatedSpine{ka_app_spine_root(e, ctx, arg, node, fty), subst(kid(fty, 1), ix(fty), arg)}

# Module: src/check/annotate.bend:319
@unsafe
def ka_app_spine(e, ctx, t):
  ka_app_spine_finish(e, ctx, kid(t, 1), ka_spine(e, ctx, kid(t, 0)))

# Module: src/check/annotate.bend:330
@unsafe
def ka_app_spine_finish(e, ctx, arg, r):
  match r:
    case KAnnotatedSpine{node, ty}: ka_app_spine_root(e, ctx, arg, node, wnf(cb(e), ty))"""

    new_ka_spine = """@unsafe
def ka_spine_finish(e, ctx, arg, r):
  match r:
    case KAnnotatedSpine{node, ty}: ka_spine_step(e, ctx, arg, node, w7b_wnf(cb(e), ty))

# Module: src/check/annotate.bend:315
@unsafe
def ka_spine_step(e, ctx, arg, node, fty):
  KAnnotatedSpine{ka_app_spine_root(e, ctx, arg, node, fty), w7b_subst_fast(kid(fty, 1), ix(fty), arg)}

# Module: src/check/annotate.bend:319
@unsafe
def ka_app_spine(e, ctx, t):
  ka_app_spine_finish(e, ctx, kid(t, 1), ka_spine(e, ctx, kid(t, 0)))

# Module: src/check/annotate.bend:330
@unsafe
def ka_app_spine_finish(e, ctx, arg, r):
  match r:
    case KAnnotatedSpine{node, ty}: ka_app_spine_root(e, ctx, arg, node, w7b_wnf(cb(e), ty))"""

    src = replace_once(src, old_ka_spine, new_ka_spine, "ka_spine_fast")

    old_ka_args = """@unsafe
def ka_args_head(e, ctx, tel, h, rest):
  Con{ka_field(annotate(e, ctx, h, kid(tel, 0)), qt(tel)), ka_args(e, ctx, subst(kid(tel, 1), ix(tel), h), rest)}"""

    new_ka_args = """@unsafe
def ka_args_head(e, ctx, tel, h, rest):
  Con{ka_field(annotate(e, ctx, h, kid(tel, 0)), qt(tel)), ka_args(e, ctx, w7b_subst_fast(kid(tel, 1), ix(tel), h), rest)}"""

    src = replace_once(src, old_ka_args, new_ka_args, "ka_args_head_fast")

    old_ka_cached = """@unsafe
def ka_args_cached(e, ctx, tel, xs):
  match xs:
    case Nil{}: Nil{}
    case Con{h, rest}:
      ka_args_cached_head(e, ctx, wnf(cb(e), tel), h, rest)"""

    new_ka_cached = """@unsafe
def ka_args_cached(e, ctx, tel, xs):
  match xs:
    case Nil{}: Nil{}
    case Con{h, rest}:
      ka_args_cached_head(e, ctx, w7b_wnf(cb(e), tel), h, rest)"""

    src = replace_once(src, old_ka_cached, new_ka_cached, "ka_args_cached_wnf")

    # ------------------------------------------------------------------
    # 3. jl_checked_error / j_layout_array_intrinsic / jl_node / jl_match /
    #    jl_app / jl_fields / jl_bindings / p142j_*
    # ------------------------------------------------------------------
    old_arr_intr = """@unsafe
def j_layout_array_intrinsic(book, f):
  p98_tag_eq(f, "Ref") && db(lookup(book, nm(f))) && j_layout_array_name(nm(f))"""

    new_arr_intr = """@unsafe
def w7b_starts_A(+name: String) -> Bool:
  match name:
    case SCon{h, _}: U32.is_eq(Char.to_u32(h), 65)
    case SNil{}: False{}

@unsafe
def w7b_arr_intr_if(isRef: Bool, +book: List<&2, KDef>, +f: KTerm) -> Bool:
  match isRef:
    case True{}:
      +name = nm(f)
      w7b_starts_A(name) && j_layout_array_name(name) && db(lookup(book, name))
    case False{}: False{}

@unsafe
def j_layout_array_intrinsic(book, f):
  w7b_arr_intr_if(p98_tag_eq(f, "Ref"), book, f)"""

    src = replace_once(src, old_arr_intr, new_arr_intr, "j_layout_array_intrinsic")

    old_jlo = """@unsafe
def j_layout_open(
  +book: List<&2, KDef>,
  +ty: KTerm,
) -> Bool:
  j_layout_open_head(book, wnf(book, ty))"""

    new_jlo = """@unsafe
def j_layout_open(
  +book: List<&2, KDef>,
  +ty: KTerm,
) -> Bool:
  j_layout_open_head(book, w7b_wnf(book, ty))"""

    src = replace_once(src, old_jlo, new_jlo, "j_layout_open_wnf")

    old_jl = """@unsafe
def jl_term(book, t, todo):
  kc(List<&2, String>, p98_tag_eq(t, "Ann"), u => jl_node(book, kid(t, 0), kid(t, 1), todo),
    u => j_layout_term(book, Nil{}, t, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, todo))

# Module: src/back/js/validate.bend:372
@unsafe
def jl_node(+book: List<&2, KDef>, +t: KTerm, +ty: KTerm, +todo: List<&2, String>) -> List<&2, String>:
  +key = tg(t)
  kc(List<&2, String>, p88_string_eq(key, "Ann"), u => jl_term(book, t, todo), u =>
  kc(List<&2, String>, p88_string_eq(key, "Ref"), u => j_layout_mark(j_layout_array_intrinsic(book, t), Con{nm(t), todo}), u =>
  kc(List<&2, String>, p88_string_eq(key, "App"), u => jl_app(book, t, wnf(book, j_type(book, Nil{}, kid(t, 0))), todo), u =>
  kc(List<&2, String>, p88_string_eq(key, "Lam"), u => jl_term(book, kid(t, 0), todo), u =>
  kc(List<&2, String>, p88_string_eq(key, "Mat"), u => jl_match(book, t, wnf(book, ty), todo), u =>
  kc(List<&2, String>, p88_string_eq(key, "Ctr"), u => kc(List<&2, String>, p88_string_eq(kc(String, j_layout_native_nat(book, t, wnf(book, ty)), u => "", u => j_literal_typed(book, t, ty)), ""), u => j_layout_mark(j_layout_open(book, ty), jl_fields(book, ks(t), todo)), u => todo), u =>
  kc(List<&2, String>, p88_string_eq(key, "Let"), u => jl_bindings(book, ks(t), todo), u =>
  kc(List<&2, String>, p88_string_eq(key, "Rwt"), u => jl_term(book, kid(t, 2), todo), u => todo))))))))

# Module: src/back/js/validate.bend:384
@unsafe
def jl_match(+book: List<&2, KDef>, +t: KTerm, +ty: KTerm, +todo: List<&2, String>) -> List<&2, String>:
  j_layout_mark(j_layout_open(book, kid(ty, 0)), jl_term(book, kid(t, 0), kc(List<&2, String>, U32.is_eq(j_constructor_count(book, wnf(book, kid(ty, 0))), 1), u => todo, u => jl_term(book, kid(t, 1), todo))))

# Module: src/back/js/validate.bend:388
@unsafe
def jl_app(+book: List<&2, KDef>, +t: KTerm, +fty: KTerm, +todo: List<&2, String>) -> List<&2, String>:
  j_layout_mark(j_layout_intrinsic(book, j_strip(kid(t, 0)), kid(t, 1)), jl_function(book, kid(t, 0), kc(List<&2, String>, p98_tag_eq(fty, "All") && U32.is_eq(qt(fty), 0), u => todo, u => jl_term(book, kid(t, 1), todo))))

# Module: src/back/js/validate.bend:392
@unsafe
def jl_function(+book: List<&2, KDef>, +t: KTerm, +todo: List<&2, String>) -> List<&2, String>:
  kc(List<&2, String>, p98_tag_eq(j_strip(t), "Ref"), u => Con{nm(j_strip(t)), todo}, u => jl_term(book, t, todo))

# Module: src/back/js/validate.bend:396
@unsafe
def jl_fields(+book: List<&2, KDef>, args: List<&2, KTerm>, +todo: List<&2, String>) -> List<&2, String>:
  match args:
    case Nil{}: todo
    case Con{+h, +rest}:
      jl_fields(book, rest, kc(List<&2, String>, U32.is_eq(qt(h), 0), u => todo, u => jl_term(book, h, todo)))

# Module: src/back/js/validate.bend:403
@unsafe
def jl_bindings(+book: List<&2, KDef>, xs: List<&2, KTerm>, +todo: List<&2, String>) -> List<&2, String>:
  match xs:
    case Nil{}: todo
    case Con{h, Nil{}}: jl_term(book, h, todo)
    case Con{+h, +rest}:
      kc(List<&2, String>, U32.is_eq(qt(h), 0), u => jl_bindings(book, rest, todo), u => jl_term(book, kid(h, 0), jl_bindings(book, rest, todo)))"""

    new_jl = """@unsafe
def w7b_jl_term_if(isAnn: Bool, +book: List<&2, KDef>, +t: KTerm, +todo: List<&2, String>) -> List<&2, String>:
  match isAnn:
    case True{}: jl_node(book, kid(t, 0), kid(t, 1), todo)
    case False{}: j_layout_term(book, Nil{}, t, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, todo)

@unsafe
def jl_term(book, t, todo):
  w7b_jl_term_if(p98_tag_eq(t, "Ann"), book, t, todo)

@unsafe
def w7b_jl_fty_if(isAnn: Bool, +book: List<&2, KDef>, +fn: KTerm) -> KTerm:
  match isAnn:
    case True{}: w7b_wnf(book, kid(fn, 1))
    case False{}: w7b_wnf(book, j_type(book, Nil{}, fn))

@unsafe
def w7b_jl_ctr_sp_if(isAdt: Bool, +ty: KTerm) -> Bool:
  match isAdt:
    case True{}:
      +n = nm(ty)
      p88_string_eq(n, "Nat") || p88_string_eq(n, "Array") || p88_string_eq(n, "U32") || p88_string_eq(n, "F32") || p88_string_eq(n, "Char") || p88_string_eq(n, "String")
    case False{}: True{}

@unsafe
def w7b_jl_ctr_lit_if(isNat: Bool, +book: List<&2, KDef>, +t: KTerm, +wty: KTerm) -> String:
  match isNat:
    case True{}: ""
    case False{}: j_literal_typed(book, t, wty)

@unsafe
def w7b_jl_ctr_empty_if(isEmpty: Bool, +book: List<&2, KDef>, +t: KTerm, +wty: KTerm, +todo: List<&2, String>) -> List<&2, String>:
  match isEmpty:
    case True{}: j_layout_mark(j_layout_open_head(book, wty), jl_fields(book, ks(t), todo))
    case False{}: todo

@unsafe
def w7b_jl_ctr_if(spec: Bool, +book: List<&2, KDef>, +t: KTerm, +wty: KTerm, +todo: List<&2, String>) -> List<&2, String>:
  match spec:
    case False{}: jl_fields(book, ks(t), todo)
    case True{}:
      +lit = w7b_jl_ctr_lit_if(j_layout_native_nat(book, t, wty), book, t, wty)
      w7b_jl_ctr_empty_if(p88_string_eq(lit, ""), book, t, wty, todo)

@unsafe
def w7b_jl_ctr(+book: List<&2, KDef>, +t: KTerm, +ty: KTerm, +todo: List<&2, String>) -> List<&2, String>:
  +wty = w7b_wnf(book, ty)
  w7b_jl_ctr_if(w7b_jl_ctr_sp_if(p98_tag_eq(wty, "ADT"), wty), book, t, wty, todo)

@unsafe
def w7b_jl_n8(c: Bool, +book: List<&2, KDef>, +t: KTerm, +todo: List<&2, String>) -> List<&2, String>:
  match c:
    case True{}: jl_term(book, kid(t, 2), todo)
    case False{}: todo

@unsafe
def w7b_jl_n7(c: Bool, +book: List<&2, KDef>, +t: KTerm, +key: String, +todo: List<&2, String>) -> List<&2, String>:
  match c:
    case True{}: jl_term(book, t, todo)
    case False{}: w7b_jl_n8(p88_string_eq(key, "Rwt"), book, t, todo)

@unsafe
def w7b_jl_n6(c: Bool, +book: List<&2, KDef>, +t: KTerm, +key: String, +todo: List<&2, String>) -> List<&2, String>:
  match c:
    case True{}: jl_term(book, kid(t, 0), todo)
    case False{}: w7b_jl_n7(p88_string_eq(key, "Ann"), book, t, key, todo)

@unsafe
def w7b_jl_n5(c: Bool, +book: List<&2, KDef>, +t: KTerm, +key: String, +todo: List<&2, String>) -> List<&2, String>:
  match c:
    case True{}: jl_bindings(book, ks(t), todo)
    case False{}: w7b_jl_n6(p88_string_eq(key, "Lam"), book, t, key, todo)

@unsafe
def w7b_jl_n4(c: Bool, +book: List<&2, KDef>, +t: KTerm, +key: String, +ty: KTerm, +todo: List<&2, String>) -> List<&2, String>:
  match c:
    case True{}: jl_match(book, t, w7b_wnf(book, ty), todo)
    case False{}: w7b_jl_n5(p88_string_eq(key, "Let"), book, t, key, todo)

@unsafe
def w7b_jl_n3(c: Bool, +book: List<&2, KDef>, +t: KTerm, +key: String, +ty: KTerm, +todo: List<&2, String>) -> List<&2, String>:
  match c:
    case True{}: w7b_jl_ctr(book, t, ty, todo)
    case False{}: w7b_jl_n4(p88_string_eq(key, "Mat"), book, t, key, ty, todo)

@unsafe
def w7b_jl_n2(c: Bool, +book: List<&2, KDef>, +t: KTerm, +key: String, +ty: KTerm, +todo: List<&2, String>) -> List<&2, String>:
  match c:
    case True{}:
      +fn = kid(t, 0)
      jl_app(book, t, w7b_jl_fty_if(p98_tag_eq(fn, "Ann"), book, fn), todo)
    case False{}: w7b_jl_n3(p88_string_eq(key, "Ctr"), book, t, key, ty, todo)

@unsafe
def w7b_jl_n1(c: Bool, +book: List<&2, KDef>, +t: KTerm, +key: String, +ty: KTerm, +todo: List<&2, String>) -> List<&2, String>:
  match c:
    case True{}: j_layout_mark(j_layout_array_intrinsic(book, t), Con{nm(t), todo})
    case False{}: w7b_jl_n2(p88_string_eq(key, "App"), book, t, key, ty, todo)

@unsafe
def w7b_jl_n0(c: Bool, +book: List<&2, KDef>, +t: KTerm, +key: String, +ty: KTerm, +todo: List<&2, String>) -> List<&2, String>:
  match c:
    case True{}: todo
    case False{}: w7b_jl_n1(p88_string_eq(key, "Ref"), book, t, key, ty, todo)

# Module: src/back/js/validate.bend:372
@unsafe
def jl_node(+book: List<&2, KDef>, +t: KTerm, +ty: KTerm, +todo: List<&2, String>) -> List<&2, String>:
  match t:
    case KLiteral{_, _, _, _, _}: todo
    case KLambda{_, _, _, kids, _, _, _, _}:
      match kids:
        case Con{body, _}: jl_term(book, body, todo)
        case Nil{}: todo
    case KTerm{+key, _, _, _, _, _, _, _}:
      w7b_jl_n0(p88_string_eq(key, "Var"), book, t, key, ty, todo)

@unsafe
def w7b_jl_mat_if(isOne: Bool, +book: List<&2, KDef>, +t: KTerm, +todo: List<&2, String>) -> List<&2, String>:
  match isOne:
    case True{}: todo
    case False{}: jl_term(book, kid(t, 1), todo)

# Module: src/back/js/validate.bend:384
@unsafe
def jl_match(+book: List<&2, KDef>, +t: KTerm, +ty: KTerm, +todo: List<&2, String>) -> List<&2, String>:
  +scr = w7b_wnf(book, kid(ty, 0))
  j_layout_mark(j_layout_open_head(book, scr), jl_term(book, kid(t, 0), w7b_jl_mat_if(U32.is_eq(j_constructor_count(book, scr), 1), book, t, todo)))

@unsafe
def w7b_jl_app_if(erased: Bool, +book: List<&2, KDef>, +arg: KTerm, +todo: List<&2, String>) -> List<&2, String>:
  match erased:
    case True{}: todo
    case False{}: jl_term(book, arg, todo)

# Module: src/back/js/validate.bend:388
@unsafe
def jl_app(+book: List<&2, KDef>, +t: KTerm, +fty: KTerm, +todo: List<&2, String>) -> List<&2, String>:
  +fn = kid(t, 0)
  +arg = kid(t, 1)
  j_layout_mark(j_layout_intrinsic(book, j_strip(fn), arg), jl_function(book, fn, w7b_jl_app_if(p98_tag_eq(fty, "All") && U32.is_eq(qt(fty), 0), book, arg, todo)))

@unsafe
def w7b_jl_fn_if(isRef: Bool, +book: List<&2, KDef>, +t: KTerm, +s: KTerm, +todo: List<&2, String>) -> List<&2, String>:
  match isRef:
    case True{}: Con{nm(s), todo}
    case False{}: jl_term(book, t, todo)

# Module: src/back/js/validate.bend:392
@unsafe
def jl_function(+book: List<&2, KDef>, +t: KTerm, +todo: List<&2, String>) -> List<&2, String>:
  +s = j_strip(t)
  w7b_jl_fn_if(p98_tag_eq(s, "Ref"), book, t, s, todo)

@unsafe
def w7b_jl_fld_if(erased: Bool, +book: List<&2, KDef>, +h: KTerm, +todo: List<&2, String>) -> List<&2, String>:
  match erased:
    case True{}: todo
    case False{}: jl_term(book, h, todo)

# Module: src/back/js/validate.bend:396
@unsafe
def jl_fields(+book: List<&2, KDef>, args: List<&2, KTerm>, +todo: List<&2, String>) -> List<&2, String>:
  match args:
    case Nil{}: todo
    case Con{+h, +rest}:
      jl_fields(book, rest, w7b_jl_fld_if(U32.is_eq(qt(h), 0), book, h, todo))

@unsafe
def w7b_jl_bnd_if(erased: Bool, +book: List<&2, KDef>, +h: KTerm, +tail: List<&2, String>) -> List<&2, String>:
  match erased:
    case True{}: tail
    case False{}: jl_term(book, kid(h, 0), tail)

# Module: src/back/js/validate.bend:403
@unsafe
def jl_bindings(+book: List<&2, KDef>, xs: List<&2, KTerm>, +todo: List<&2, String>) -> List<&2, String>:
  match xs:
    case Nil{}: todo
    case Con{h, Nil{}}: jl_term(book, h, todo)
    case Con{+h, +rest}:
      w7b_jl_bnd_if(U32.is_eq(qt(h), 0), book, h, jl_bindings(book, rest, todo))"""

    src = replace_once(src, old_jl, new_jl, "jl_fast")

    old_p142j = """@unsafe
def p142j_def_set(+book: List<&2,KDef>, +defs: List<&2,KDef>, +d: KDef, +todo: List<&2,String>, +seen: KDef, +stops: KDef) -> Bool:
  p142j_visit_set(book,defs,kc(List<&2,String>,p88_string_eq(dk(d),"Def") && U32.is_eq(dx(d),0),
    u => jl_term(book,dv(d),todo),u => todo),seen,stops)


@unsafe
def p142j_name_set(+book: List<&2,KDef>, +defs: List<&2,KDef>, +name: String, +rest: List<&2,String>, +seen: KDef, +stops: KDef, +hash: U32) -> Bool:
  kc(Bool,p142j_member(seen,name,hash) || p142j_member(stops,name,hash),
    u => p142j_visit_set(book,defs,rest,seen,stops),
    u => p142j_def_set(book,defs,lookup(defs,name),rest,p142j_mark(seen,name,hash),stops))


@unsafe
def p142j_visit_set(book, defs, todo, seen, stops):
  match todo:
    case Nil{}: False{}
    case Con{+name,+rest}:
      kc(Bool,p88_string_eq(name,"$layout.open-array"),u => True{},
        u => p142j_name_set(book,defs,name,rest,seen,stops,index_hash(name,2166136261)))"""

    new_p142j = """@unsafe
def w7b_p142j_def_if(live: Bool, +book: List<&2,KDef>, +d: KDef, +todo: List<&2,String>) -> List<&2,String>:
  match live:
    case True{}: jl_term(book,dv(d),todo)
    case False{}: todo

@unsafe
def p142j_def_set(+book: List<&2,KDef>, +defs: List<&2,KDef>, +d: KDef, +todo: List<&2,String>, +seen: KDef, +stops: KDef) -> Bool:
  p142j_visit_set(book,defs,w7b_p142j_def_if(p88_string_eq(dk(d),"Def") && U32.is_eq(dx(d),0),book,d,todo),seen,stops)

@unsafe
def w7b_p142j_name_if(skip: Bool, +book: List<&2,KDef>, +defs: List<&2,KDef>, +name: String, +rest: List<&2,String>, +seen: KDef, +stops: KDef, +hash: U32) -> Bool:
  match skip:
    case True{}: p142j_visit_set(book,defs,rest,seen,stops)
    case False{}: p142j_def_set(book,defs,lookup(defs,name),rest,p142j_mark(seen,name,hash),stops)

@unsafe
def p142j_name_set(+book: List<&2,KDef>, +defs: List<&2,KDef>, +name: String, +rest: List<&2,String>, +seen: KDef, +stops: KDef, +hash: U32) -> Bool:
  w7b_p142j_name_if(p142j_member(seen,name,hash) || p142j_member(stops,name,hash),book,defs,name,rest,seen,stops,hash)

@unsafe
def w7b_p142j_visit_if(isOpen: Bool, +book: List<&2,KDef>, +defs: List<&2,KDef>, +name: String, +rest: List<&2,String>, +seen: KDef, +stops: KDef) -> Bool:
  match isOpen:
    case True{}: True{}
    case False{}: p142j_name_set(book,defs,name,rest,seen,stops,index_hash(name,2166136261))

@unsafe
def p142j_visit_set(book, defs, todo, seen, stops):
  match todo:
    case Nil{}: False{}
    case Con{+name,+rest}:
      w7b_p142j_visit_if(p88_string_eq(name,"$layout.open-array"),book,defs,name,rest,seen,stops)"""

    src = replace_once(src, old_p142j, new_p142j, "p142j_fast")

    # ------------------------------------------------------------------
    # 4. Fix gameoflife -O2 regression: guard giant-non-loop size gates
    #    in x190_joint_frame, x185_function_place, x198n_place with
    #    w7b_stmts_has_call(body) so pure scalar leaf functions keep full -O2.
    # ------------------------------------------------------------------
    old_joint = """@unsafe
def x190_joint_frame(+frame: X181Frame, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +registerBody: List<&2,P113DStmt>) -> X181Frame:
  +sz = p113i_add(p113i_size(setup),p113i_size(body))
  nt_choose(X181Frame,U32.is_gt(sz,128) && Bool.not(x190_register_loop(body)),
    u => frame,"""

    new_joint = """@unsafe
def w7b_stmts_has_call(xs: List<&2,P113DStmt>) -> Bool:
  match xs:
    case Nil{}: False{}
    case Con{P113DCall{_, _, _}, _}: True{}
    case Con{P113DIf{_, yes, no}, rest}:
      w7b_stmts_has_call(yes) || w7b_stmts_has_call(no) || w7b_stmts_has_call(rest)
    case Con{_, rest}:
      w7b_stmts_has_call(rest)

@unsafe
def x190_joint_frame(+frame: X181Frame, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +registerBody: List<&2,P113DStmt>) -> X181Frame:
  +sz = p113i_add(p113i_size(setup),p113i_size(body))
  nt_choose(X181Frame,U32.is_gt(sz,128) && Bool.not(x190_register_loop(body)) && w7b_stmts_has_call(body),
    u => frame,"""

    src = replace_once(src, old_joint, new_joint, "x190_joint_frame_leaf_guard")

    old_place = """@unsafe
def x185_function_place(+symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +ids: N111Ids) -> X181Output:
  nt_choose(X181Output,Bool.not(x190_register_loop(body)) && U32.is_gt(p113i_size(body),96),"""

    new_place = """@unsafe
def x185_function_place(+symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +ids: N111Ids) -> X181Output:
  nt_choose(X181Output,Bool.not(x190_register_loop(body)) && U32.is_gt(p113i_size(body),96) && w7b_stmts_has_call(body),"""

    src = replace_once(src, old_place, new_place, "x185_function_place_leaf_guard")

    old_x198n = """@unsafe
def x198n_place(+symbol: String, +names: List<&2,String>, +params: List<&2,NC_Binding>, +body: List<&2,P113DStmt>, +ids: N111Ids) -> X181Output:
  nt_choose(X181Output,Bool.not(x190_register_loop(body)) && U32.is_gt(p113i_size(body),96),"""

    new_x198n = """@unsafe
def x198n_place(+symbol: String, +names: List<&2,String>, +params: List<&2,NC_Binding>, +body: List<&2,P113DStmt>, +ids: N111Ids) -> X181Output:
  nt_choose(X181Output,Bool.not(x190_register_loop(body)) && U32.is_gt(p113i_size(body),96) && w7b_stmts_has_call(body),"""

    src = replace_once(src, old_x198n, new_x198n, "x198n_place_leaf_guard")

    return src


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--src", required=True)
    ap.add_argument("--dst", required=True)
    args = ap.parse_args()
    src = Path(args.src).read_text(encoding="utf-8")
    dst = apply_patch(src)
    Path(args.dst).parent.mkdir(parents=True, exist_ok=True)
    Path(args.dst).write_text(dst, encoding="utf-8")
    print(f"apply_w7b_annotate: OK ({len(src)} -> {len(dst)} bytes)")


if __name__ == "__main__":
    main()
