# Module m08 (K=12 acyclic topological split of wave8_unified/compiler.bend)
# defs=635 laws=70 sccs=441 deps=[m00,m01,m02,m03,m04,m05,m06,m07] cross_imports=853 fid_base=40960..46079

law kr_visit:
  for +book: List<&2, KDef>
  for todo: List<&2, String>
  for +seen: List<&2, String>
  for +stops: List<&2, String>
  List<&2, String>

# Module: src/core/reach.bend:27
law check_fits:
  for +e: KEnv
  for +r: KChecking
  for +ty: KTerm
  KChecking

# Module: src/check/kernel.bend:106
law check_rfl:
  for +e: KEnv
  for +t: KTerm
  for +ty: KTerm
  KChecking

law check_rfl_graph:
  for +e: KEnv
  for +t: KTerm
  for +ty: KTerm
  KChecking

# Module: src/check/kernel.bend:153
law annotate:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +ty: KTerm
  KTerm

# Module: src/check/annotate.bend:34
law ka_node:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +ty: KTerm
  KTerm

# Module: src/check/annotate.bend:41
law ka_type:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  KTerm

# Module: src/check/annotate.bend:47
law ka_type_node:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  KTerm

# Module: src/check/annotate.bend:53
law ka_lam:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +ty: KTerm
  KTerm

# Module: src/check/annotate.bend:66
law ka_app:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +fty: KTerm
  KTerm

# Module: src/check/annotate.bend:73
law ka_args_head:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +tel: KTerm
  for +h: KTerm
  for +rest: List<&2, KTerm>
  List<&2, KTerm>

# Module: src/check/annotate.bend:81
law ka_mat:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +ty: KTerm
  for +a: KTerm
  KTerm

# Module: src/check/annotate.bend:89
law ka_mat_ctr:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +ty: KTerm
  for +a: KTerm
  for +c: KDef
  KTerm

# Module: src/check/annotate.bend:98
law ka_let:
  for +e: KEnv
  for +outer: List<&2, KTerm>
  for +ctx: List<&2, KTerm>
  for +xs: List<&2, KTerm>
  for +ty: KTerm
  List<&2, KTerm>

# Module: src/check/annotate.bend:106
law ka_let_head:
  for +e: KEnv
  for +outer: List<&2, KTerm>
  for +ctx: List<&2, KTerm>
  for +h: KTerm
  for +rest: List<&2, KTerm>
  for +ty: KTerm
  for +vty: KTerm
  List<&2, KTerm>

# Module: src/check/annotate.bend:116
law ka_rwt:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +eq: KTerm
  KTerm

# Module: src/check/annotate.bend:264
law ka_spine_finish:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +arg: KTerm
  for +r: KAnnotatedSpine
  KAnnotatedSpine

# Module: src/check/annotate.bend:275
law ka_spine_step:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +arg: KTerm
  for +node: KTerm
  for +fty: KTerm
  KAnnotatedSpine

# Module: src/check/annotate.bend:283
law ka_app_spine:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  KTerm

# Module: src/check/annotate.bend:289
law ka_app_spine_root:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +arg: KTerm
  for +node: KTerm
  for +fty: KTerm
  KTerm

# Module: src/check/annotate.bend:322
law ka_app_spine_finish:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +arg: KTerm
  for +r: KAnnotatedSpine
  KTerm

# Module: src/check/annotate.bend:340
law ka_args_cached:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +tel: KTerm
  for +xs: List<&2, KTerm>
  List<&2, KTerm>

# Module: src/check/annotate.bend:347
law ka_args_cached_head:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +tel: KTerm
  for +h: KTerm
  for +rest: List<&2, KTerm>
  List<&2, KTerm>

# Module: src/check/annotate.bend:382
law ka_args_after_head:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +tel: KTerm
  for +h: KTerm
  for +rest: List<&2, KTerm>
  for +annotated: KTerm
  List<&2, KTerm>

# Module: src/front/lexer.bend:22
law f_operator:
  for +s: String
  String

# Module: src/front/parser.bend:120
law f_atom_nat_plus:
  for +lit: KTerm
  for +p: FParsed
  FParsed

# Module: src/front/parser.bend:265
law fpe_seek:
  for +source: String
  for +rest: String
  for +line: U32
  for +column: U32
  for +offset: U32
  for +error: KTerm
  String

# Module: src/front/parser.bend:536
law fpe_here:
  for +source: String
  for +rest: String
  for +offset: U32
  for +error: KTerm
  String

# Module: src/front/parser.bend:542
law f_nat_extend:
  for +a: KTerm
  for +b: KTerm
  KTerm

# Module: src/front/literals_arrays.bend:134
law dg_reason:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +ty: KTerm
  for +code: String
  KTerm

# Module: src/diagnostic/produce.bend:4
law j_io_shadow:
  for +book: List<&2, KDef>
  List<&2, KDef>

# Module: src/back/common/queries.bend:179
law j_io_shadow_def:
  for +book: List<&2, KDef>
  for +d: KDef
  List<&2, KDef>

# Module: src/back/common/queries.bend:188
law j_layout_term:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +t: KTerm
  for +ty: KTerm
  for +todo: List<&2, String>
  List<&2, String>

# Module: src/back/js/validate.bend:184
law j_layout_kind:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +t: KTerm
  for +ty: KTerm
  for +todo: List<&2, String>
  for +key: String
  List<&2, String>

# Module: src/back/js/validate.bend:204
law j_layout_lam:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +t: KTerm
  for +ty: KTerm
  for +todo: List<&2, String>
  List<&2, String>

# Module: src/back/js/validate.bend:216
law j_layout_match:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +t: KTerm
  for +ty: KTerm
  for +todo: List<&2, String>
  List<&2, String>

# Module: src/back/js/validate.bend:228
law j_layout_app:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +t: KTerm
  for +fty: KTerm
  for +todo: List<&2, String>
  List<&2, String>

# Module: src/back/js/validate.bend:240
law j_layout_function:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +t: KTerm
  for +ty: KTerm
  for +todo: List<&2, String>
  List<&2, String>

# Module: src/back/js/validate.bend:260
law j_layout_fields:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +args: List<&2, KTerm>
  for +tel: KTerm
  for +todo: List<&2, String>
  List<&2, String>

# Module: src/back/js/validate.bend:301
law j_layout_let:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +xs: List<&2, KTerm>
  for +ty: KTerm
  for +todo: List<&2, String>
  List<&2, String>

# Module: src/back/js/validate.bend:313
law j_layout_bindings:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +xs: List<&2, KTerm>
  for +todo: List<&2, String>
  List<&2, String>

# Module: src/back/js/validate.bend:360
law jl_term:
  for +book: List<&2, KDef>
  for +t: KTerm
  for +todo: List<&2, String>
  List<&2, String>

# Module: src/back/js/emit.bend:3
law noa_finish_value:
  for +ctx: NO_Context
  for +value: KTerm
  for +template: KTerm
  for +facts: List<&2, KTerm>
  KTerm

# Module: src/back/native/observer-analysis.bend:430
@unsafe
def book_put(
  +book: List<&2, KDef>,
  +d: KDef,
) -> List<&2, KDef>:
  match book:
    case Nil{}:
      Con{d, Nil{}}
    case Con{h, rest}:
      w7_book_put_step(p88_string_eq(dk(h), "BookCache"), h, rest, book, d)


# An immutable context may be reused by several backend phases. Never nest the
# sentinel or recompute its maximum binder ID from the index's implementation.

# Module: src/core/index.bend:296
@unsafe
def book_put_many_legacy(+book: List<&2,KDef>, +defs: List<&2,KDef>) -> List<&2,KDef>:
  match defs:
    case Nil{}: book
    case Con{d, rest}: book_put_many_legacy(book_put(book, d), rest)

# Module: src/core/index.bend:448
@unsafe
def book_put_many_fast(+book: List<&2,KDef>, +defs: List<&2,KDef>) -> List<&2,KDef>:
  match book:
    case Nil{}: book_final_fast(defs, Nil{})
    case Con{cache, rest}:
      kc(List<&2,KDef>, p88_string_eq(dk(cache), "BookCache"),
        u => kc(List<&2,KDef>, book_put_many_cache_valid(cache, rest, defs),
          u => book_put_many_cached(cache, rest, defs),
          u => book_put_many_legacy(book, defs)),
        u => book_final_fast(defs, book))

# Module: src/core/index.bend:486
@unsafe
def reach_book(
  +book: List<&2, KDef>,
  +roots: List<&2, String>,
  +stops: List<&2, String>,
) -> List<&2, KDef>:
  kr_filter(book, kr_visit(book, roots, Nil{}, stops))

# Module: src/core/reach.bend:78
@unsafe
def kr_visit(book, todo, seen, stops):
  p142r_kr_visit(book,todo,seen,stops)

# Module: src/core/reach.bend:94
@unsafe
def check_fits(e, r, ty):
  w7_br_168(good(r), r, ty)

# Module: src/check/kernel.bend:734
@unsafe
def check_rfl(e, t, ty):
  w7_br_175(p98_tag_eq(ty, "Eql"), e, t, ty)

# Expose the goal and compare its endpoints in one private graph. Ordinary wnf
# substitutes raw let values and can expand a shared goal before comparison.
# The result retains the original goal; no heap-local cell enters KChecking.
@unsafe
def check_rfl_graph_head(+e: KEnv, +t: KTerm, +ty: KTerm,
  +fresh: U32, +r: GResult) -> KChecking:
  match r:
    case GResult{st, head}:
      kc(KChecking, p98_tag_eq(head, "Eql"),
        u => kc(KChecking, norm_convert_state(cb(e), st, kid(head, 0), kid(head, 1), False{}, fresh),
          u => ok(cw(e), t, ty, Nil{}),
          u => check_rfl(e, t, wnf(cb(e), ty))),
        u => bad(cw(e), "reflexivity requires equality goal"))

@unsafe
def check_rfl_graph(e, t, ty):
  +fresh = U32.add(1, norm_max(norm_book_bound(cb(e)), norm_max_term(ty)))
  check_rfl_graph_head(e, t, ty, fresh, g_wnf(cb(e), GState{GEmpty{}, 1}, ty))

# Module: src/check/kernel.bend:758
@unsafe
def check_declarations(
  +todo: List<&2,KDef>,
  +done: List<&2,KDef>,
) -> List<&2,KDef>:
  match todo:
    case Nil{}: done
    case Con{d, rest}:
      check_declarations(rest, book_put(done, kc(KDef, p98_tag_eq(dv(d), "Foreign"), u => d, u => declared(d))))

# Module: src/check/kernel.bend:965
@unsafe
def w7_br_195(w7_c: Bool, +done: List<&2, KDef>, +d: KDef, +old: KDef) -> String:
  match w7_c:
    case True{}:
      w7_br_192(p88_string_eq(dk(d), "ADT"), done, d)
    case False{}:
      w7_br_194(p88_string_eq(dk(old), "Def") && p88_string_eq(dk(d), "Def") && p98_tag_eq(dv(old), "Absent") && Bool.not(p98_tag_eq(dv(d), "Absent")), done, d, old)

@unsafe
def event_error(
  +done: List<&2, KDef>,
  +d: KDef,
  +old: KDef,
) -> String:
  w7_br_195(p88_string_eq(dk(old), "Absent"), done, d, old)

# Module: src/check/kernel.bend:973
@unsafe
def kw_temporary(+world: KWorld, +root: KTerm, +bound: U32) -> KWorld:
  kw_temporary_fresh(world, root, bound, kw_fresh(world))

# Module: src/check/kernel.bend:1405
@unsafe
def kw_temporary_fresh(+world: KWorld, +root: KTerm, +bound: U32, +fresh: KWorldFresh) -> KWorld:
  match fresh:
    case KFreshKnown{next}: KWorld{kw_bound_book(kw_book(world), bound), kw_memo(world), KFreshKnown{norm_max(next, U32.add(bound, 1))}, kw_checked(world)}
    case KFreshDeferred{roots}: KWorld{kw_book(world), kw_memo(world), KFreshDeferred{Con{root, roots}}, kw_checked(world)}

# Module: src/check/kernel.bend:1411
@unsafe
def ki_lhs(+e: KEnv, +name: String, +tel: KTerm, +n: U32, +fresh: U32) -> KEnv:
  +lhs = lhs_ext(cl(e), name, tel, n, Nil{}, fresh)
  KEnv{kc(KWorld, U32.is_eq(n, 0), u => cw(e), u => kw_temporary(cw(e), lhs, U32.sub(U32.add(fresh, n), 1))), cn(e), lhs, U32.add(U32.sub(cp(e), 1), n), cq(e), cu(e), cd(e)}

# Module: src/check/kernel.bend:1420
@unsafe
def w7_br_278(w7_c: Bool, +head: KTerm, +inst: KDef, +consumed: U32, +r: KChecking) -> KChecking:
  match w7_c:
    case True{}:
      sp_live_ref(KWorld{book_put(kw_book(rw(r)), inst), sp_done_memo(kw_memo(rw(r)), dn(inst)), kw_fresh(rw(r)), Con{KDef{dn(inst), dk(inst), da(inst), dx(inst), dt(inst), ct(r), dc(inst), db(inst), du(inst)}, kw_checked(rw(r))}}, head, dn(inst), consumed)
    case False{}:
      r

@unsafe
def sp_live_done(+head: KTerm, +inst: KDef, +consumed: U32, +r: KChecking) -> KChecking:
  w7_br_278(good(r), head, inst, consumed, r)

# Module: src/check/specialize.bend:382
@unsafe
def base_prefix_ctor_disjoint(+defs: List<&2,KDef>, +context: List<&2,KDef>) -> Bool:
  p144ce_disjoint(defs,context)

@unsafe
def base_prefix_admitted_bound(+state: KBasePrefixState, +prefix: List<&2,KDef>, +suffix: List<&2,KDef>, +bound: U32, +final: List<&2,KDef>, +prefix_bound: U32) -> Bool:
  match state:
    case KBasePrefixState{base_bound, delta, stamp, patches, ready}:
      ready && U32.is_eq(base_bound, prefix_bound) && U32.is_ge(bound, base_bound) && U32.is_le(delta, 1048576) && U32.is_le(stamp, delta) && U32.is_le(bound, 1048576) && base_prefix_names(suffix) && prefix_state_disjoint(prefix, book_context(suffix)) && base_prefix_ctor_disjoint(suffix, final)

# Module: src/check/prefix-state.bend:194
@unsafe
def base_prefix_world_order(+declared: List<&2,KDef>, +prefix: List<&2,KDef>, +suffix: List<&2,KDef>) -> List<&2,KDef>:
  match suffix:
    case Nil{}: declared
    case Con{d, rest}: base_prefix_world_order_tail(declared, prefix, suffix)

# Module: src/check/prefix-state.bend:297
@unsafe
def base_prefix_world_admitted(+state: KBasePrefixState, +suffix: List<&2,KDef>, +bound: U32, +final: List<&2,KDef>, +saved: List<&2,KDef>) -> Bool:
  match state:
    case KBasePrefixState{base_bound, delta, stamp, patches, ready}:
      ready && U32.is_ge(bound, base_bound) && U32.is_le(delta, 1048576) && U32.is_le(stamp, delta) && U32.is_le(bound, 1048576) && base_prefix_names(suffix) && base_prefix_world_names_disjoint(suffix, saved) && base_prefix_ctor_disjoint(suffix, final)

# Module: src/check/prefix-state.bend:367
@unsafe
def base_prefix_context_world(+book: List<&2,KDef>, +error: String, +suffix: List<&2,KDef>, +ready: Bool, +prepared: KBasePreparedWorld) -> List<&2,KDef>:
  match prepared:
    case KBasePreparedWorld{state, original, final, saved, checked, seen, todos, checkedBound}:
      +bound = norm_max(base_prefix_world_bound(state), norm_max_book(suffix))
      kc(List<&2,KDef>, ready && String.is_empty(error) && Bool.not(p88_string_eq(dk(index_first(book)), "BookCache")) &&
        base_prefix_world_admitted(state, suffix, bound, final, saved) &&
        base_prefix_world_hash_disjoint(suffix, index_first(dc(index_first(saved)))),
        u => base_prefix_context_tail(book, checkedBound, base_prefix_context_drop(book, checked)),
        u => book_context(book))

# Checking only prepends output to the saved reverse checked list. Reversing the
# result therefore preserves its entire original checked prefix, in forward
# order. Count the known prefix cells; do not rescan their immutable term trees.

# Module: src/check/prefix-state.bend:438
@unsafe
def base_prefix_context_tail(+book: List<&2,KDef>, +checkedBound: U32, +tail: KBasePrefixTail) -> List<&2,KDef>:
  match tail:
    case KBasePrefixTail{suffix, matched}:
      kc(List<&2,KDef>, matched,
        u => book_cached(book, norm_max(checkedBound, norm_max_book(suffix))),
        u => book_context(book))

# Module: src/check/annotate.bend:124
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
  w7b_annotate_wty(e, ctx, t, w7b_wnf(cb(e), ty))

# Keep the type head already demanded by ka_node. Backend consumers otherwise
# normalize the original annotation again while determining the same layout.

# Module: src/check/annotate.bend:174
@unsafe
def ka_annotated(+e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +ty: KTerm) -> KTerm:
  ka_wrap(ka_node(e, ctx, t, ty), ty)

# Module: src/check/annotate.bend:178
@unsafe
def w7_br_280(w7_c: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +ty: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      t
    case False{}:
      ka_node(e, ctx, core_literal_step(t), ty)

@unsafe
def w7_br_281(w7_c: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      ka_app_spine(e, ctx, t)
    case False{}:
      ka_app(e, ctx, t, wnf(cb(e), ka_type(e, ctx, kid(t, 0))))

@unsafe
def w7_br_282(w7_c: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      ka_rwt(e, ctx, t, wnf(cb(e), ka_type(e, ctx, kid(t, 0))))
    case False{}:
      t

@unsafe
def w7_br_283(w7_c: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +ty: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      kt("Let", nm(t), ix(t), qt(t), ka_let(e, ctx, ctx, ks(t), ty))
    case False{}:
      w7_br_282(p98_tag_eq(t, "Rwt"), e, ctx, t)

@unsafe
def w7_br_284(w7_c: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +ty: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      ka_mat(e, ctx, t, ty, wnf(cb(e), kid(ty, 0)))
    case False{}:
      w7_br_283(p98_tag_eq(t, "Let"), e, ctx, t, ty)

@unsafe
def w7_br_285(w7_c: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +ty: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      kt("Ctr", nm(t), ix(t), qt(t), ka_args_cached(e, ctx, tele_fill(cb(e), dt(lookup(dc(lookup(cb(e), nm(ty))), nm(t))), ks(ty)), ks(t)))
    case False{}:
      w7_br_284(p98_tag_eq(t, "Mat"), e, ctx, t, ty)

@unsafe
def w7_br_286(w7_c: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +ty: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      w7_br_281(ka_spine_eligible(t), e, ctx, t)
    case False{}:
      w7_br_285(p98_tag_eq(t, "Ctr"), e, ctx, t, ty)

@unsafe
def w7_br_287(w7_c: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +ty: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      ka_lam(e, ctx, t, ty)
    case False{}:
      w7_br_286(p98_tag_eq(t, "App"), e, ctx, t, ty)

@unsafe
def w7_br_288(w7_c: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +ty: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      ka_node(e, ctx, kid(t, 0), wnf(cb(e), kid(t, 1)))
    case False{}:
      w7_br_287(p98_tag_eq(t, "Lam"), e, ctx, t, ty)

@unsafe
def w7_br_289(w7_c: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +ty: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      w7_br_280(core_literal_type(cb(e), t, ty), e, ctx, t, ty)
    case False{}:
      w7_br_288(p98_tag_eq(t, "Ann"), e, ctx, t, ty)

@unsafe
def ka_node(e, ctx, t, ty):
  w7_br_289(core_literal(t), e, ctx, t, ty)

# Module: src/check/annotate.bend:190
@unsafe
def ka_type(e, ctx, t):
  ka_type_node(e, ctx, core_beta(t))

# Module: src/check/annotate.bend:194
@unsafe
def w7_br_294(w7_c: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      ka_type_app(e, t, wnf(cb(e), ka_type(e, ctx, kid(t, 0))))
    case False{}:
      w7_br_293(p98_tag_eq(t, "ADT"), e, t)

@unsafe
def w7_br_295(w7_c: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      kid(t, 1)
    case False{}:
      w7_br_294(p98_tag_eq(t, "App"), e, ctx, t)

@unsafe
def w7_br_296(w7_c: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      dt(lookup(cb(e), nm(t)))
    case False{}:
      w7_br_295(p98_tag_eq(t, "Ann"), e, ctx, t)

@unsafe
def w7_br_297(w7_c: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      kid(ctx_get(ctx, ix(t)), 0)
    case False{}:
      w7_br_296(p98_tag_eq(t, "Ref"), e, ctx, t)

@unsafe
def ka_type_node(e, ctx, t):
  w7_br_297(p98_tag_eq(t, "Var"), e, ctx, t)

# Module: src/check/annotate.bend:206
@unsafe
def ka_lam(e, ctx, t, ty):
  +q = w7b_lam_q_if(k_quantity_present(t) && U32.is_eq(qt(t), 2) && U32.is_eq(qt(ty), 1), qt(ty))
  +name = nm(t)
  +id = ix(t)
  k_lam(name, id, q, Con{annotate(e, ctx_bind(ctx, id, qt(ty), name, kid(ty, 0)), kid(t, 0), w7b_subst_fast(kid(ty, 1), ix(ty), var(name, id))), Nil{}}, 0, 0, False{})

# Module: src/check/annotate.bend:214
@unsafe
def ka_app(e, ctx, t, fty):
  app(annotate(e, ctx, kid(t, 0), fty), annotate(e, ctx, kid(t, 1), kid(fty, 0)))

# Module: src/check/annotate.bend:218
@unsafe
def ka_args(
  +e: KEnv,
  +ctx: List<&2, KTerm>,
  +tel: KTerm,
  +xs: List<&2, KTerm>,
) -> List<&2, KTerm>:
  match xs:
    case Nil{}:
      Nil{}
    case Con{h, rest}:
      ka_args_head(e, ctx, wnf(cb(e), tel), h, rest)

# Module: src/check/annotate.bend:231
@unsafe
def ka_args_head(e, ctx, tel, h, rest):
  Con{ka_field(annotate(e, ctx, h, kid(tel, 0)), qt(tel)), ka_args(e, ctx, w7b_subst_fast(kid(tel, 1), ix(tel), h), rest)}

# Module: src/check/annotate.bend:235
@unsafe
def ka_mat(e, ctx, t, ty, a):
  ka_mat_ctr(e, ctx, t, ty, a, lookup(dc(lookup(cb(e), nm(a))), nm(t)))

# Module: src/check/annotate.bend:239
@unsafe
def ka_mat_ctr(e, ctx, t, ty, a, c):
  kt("Mat", nm(t), ix(t), qt(t), Con{annotate(e, ctx, kid(t, 0), mat_goal(cb(e), ty, tele_fill(cb(e), dt(c), ks(a)), da(c), nm(t), Nil{})), Con{annotate(e, ctx, mat_rest(cb(e), t, a), all(qt(ty), nm(ty), ix(ty), KTerm{tg(a), nm(a), ix(a), qt(a), ks(a), Con{nm(t), rm(a)}, kb(a), ke(a)}, kid(ty, 1))), Nil{}}})

# Module: src/check/annotate.bend:243
@unsafe
def ka_let(e, outer, ctx, xs, ty):
  match xs:
    case Nil{}:
      Nil{}
    case Con{h, rest}:
      kc(List<&2, KTerm>, p98_tag_eq(h, "Bind"), u => ka_let_head(e, outer, ctx, h, rest, ty, ka_type(e, outer, kid(h, 0))), u => Con{annotate(e, ctx, h, ty), Nil{}})

# Module: src/check/annotate.bend:251
@unsafe
def ka_let_head(e, outer, ctx, h, rest, ty, vty):
  Con{kt("Bind", nm(h), ix(h), qt(h), Con{annotate(e, outer, kid(h, 0), vty), Nil{}}), ka_let(e, outer, ctx_bind(ctx, ix(h), qt(h), nm(h), vty), subst_terms(rest, ix(h), kt("Var", nm(h), ix(h), 0, Con{kid(h, 0), Nil{}})), ty)}

# Module: src/check/annotate.bend:255
@unsafe
def ka_rwt(e, ctx, t, eq):
  kt("Rwt", nm(t), ix(t), qt(t), Con{annotate(e, ctx, kid(t, 0), eq), Con{kid(t, 1), Con{annotate(e, ctx, kid(t, 2), kapply(kapply(kid(t, 1), kid(eq, 0)), {KTerm{"Rfl", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})), Nil{}}}})


# A Ref/Var-headed application spine has no beta-redex in its function prefix.
# Infer each intermediate function type once, preserving the old Ann structure.

# Module: src/check/annotate.bend:298
@unsafe
def w7_br_299(w7_c: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm) -> KAnnotatedSpine:
  match w7_c:
    case True{}:
      ka_spine_finish(e, ctx, kid(t, 1), ka_spine(e, ctx, kid(t, 0)))
    case False{}:
      KAnnotatedSpine{t, ka_type(e, ctx, t)}

@unsafe
def ka_spine(
  +e: KEnv,
  +ctx: List<&2, KTerm>,
  +t: KTerm,
) -> KAnnotatedSpine:
  w7_br_299(p98_tag_eq(t, "App"), e, ctx, t)

# Module: src/check/annotate.bend:310
@unsafe
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
    case KAnnotatedSpine{node, ty}: ka_app_spine_root(e, ctx, arg, node, w7b_wnf(cb(e), ty))

# Module: src/check/annotate.bend:335
@unsafe
def ka_app_spine_root(e, ctx, arg, node, fty):
  app(ka_wrap(node, fty), annotate(e, ctx, arg, kid(fty, 0)))

# Reuse a closed tail with only inert canonical Apps along its literal All spine.
# Ref/Ann/other heads restart analysis after ordinary weak-head normalization.

# Module: src/check/annotate.bend:356
@unsafe
def ka_args_cached(e, ctx, tel, xs):
  match xs:
    case Nil{}: Nil{}
    case Con{h, rest}:
      ka_args_cached_head(e, ctx, w7b_wnf(cb(e), tel), h, rest)

# Module: src/check/annotate.bend:363
@unsafe
def ka_args_cached_head(e, ctx, tel, h, rest):
  kc(List<&2, KTerm>, p98_tag_eq(tel, "All"),
    u => ka_args_after_head(e, ctx, tel, h, rest, annotate(e, ctx, h, kid(tel, 0))),
    u => ka_args_head(e, ctx, tel, h, rest))

# Module: src/check/annotate.bend:369
@unsafe
def ka_args_static(
  +e: KEnv,
  +ctx: List<&2, KTerm>,
  +tel: KTerm,
  +xs: List<&2, KTerm>,
) -> List<&2, KTerm>:
  match xs:
    case Nil{}: Nil{}
    case Con{h, rest}:
      kc(List<&2, KTerm>, p98_tag_eq(tel, "All"),
        u => Con{ka_field(annotate(e, ctx, h, kid(tel, 0)), qt(tel)), ka_args_static(e, ctx, kid(tel, 1), rest)},
        u => ka_args_cached(e, ctx, tel, xs))

# Module: src/check/annotate.bend:392
@unsafe
def ka_args_after_head(e, ctx, tel, h, rest, annotated):
  kc(List<&2, KTerm>, core_subst_stable(kid(tel, 1)),
    u => Con{ka_field(annotated, qt(tel)), ka_args_static(e, ctx, kid(tel, 1), rest)},
    u => Con{ka_field(annotated, qt(tel)), ka_args(e, ctx, subst(kid(tel, 1), ix(tel), h), rest)})

# Checked layout validation consumes the field quantity already reconstructed
# here. Ann's first two children keep the existing backend representation.

# Module: src/check/annotate.bend:400
@unsafe
def w7_br_303(w7_c: Bool, +pattern: KTerm, +input: FInput, +cursor: U32, +observed: KTerm) -> FParsed:
  match w7_c:
    case True{}:
      FParsed{observed, input}
    case False{}:
      f_context_pattern_observed(pattern, input, cursor, f_fresh_term(observed, f_context_free_env(f_context_outer(input)), 0))

@unsafe
def f_context_pattern_computed(+pattern: KTerm, +input: FInput, +cursor: U32, +observed: KTerm) -> FParsed:
  w7_br_303(f_context_stop(observed), pattern, input, cursor, observed)

# Module: src/front/contextual.bend:123
@unsafe
def f_context_pattern_observed(+pattern: KTerm, +input: FInput, +cursor: U32, +fresh: FFresh) -> FParsed:
  match fresh:
    case FFresh{term, next}: f_context_error_at(f_computed_pattern_error(pattern, term), input, cursor)

# Module: src/front/contextual.bend:128
@unsafe
def f_context_atom_done(+p: FParsed) -> FParsed:
  match p:
    case FParsed{term, rest}: FParsed{f_choose(KTerm, p98_tag_eq(term, "Literal"), u => f_literal_at(term), u => term), rest}

# Module: src/front/contextual.bend:166
@unsafe
def f_atom_nat_plus(lit, p):
  match p:
    case FParsed{+rhs, rest}:
      f_choose(FParsed, f_eq(tg(rhs), "Error"), u => FParsed{rhs, rest}, u => FParsed{f_nat_extend(lit, rhs), rest})

# Module: src/front/parser.bend:272
@unsafe
def w7_br_359(w7_c: Bool, +s: String) -> String:
  match w7_c:
    case True{}:
      "String.append"
    case False{}:
      w7_br_358(f_eq(s, "||"), s)

@unsafe
def w7_br_360(w7_c: Bool, +s: String) -> String:
  match w7_c:
    case True{}:
      "Or"
    case False{}:
      w7_br_359(f_eq(s, "++"), s)

@unsafe
def w7_br_361(w7_c: Bool, +s: String) -> String:
  match w7_c:
    case True{}:
      "Pair"
    case False{}:
      w7_br_360(f_eq(s, "|"), s)

@unsafe
def f_operator(s):
  w7_br_361(f_eq(s, "&"), s)

# Module: src/front/parser.bend:453
@unsafe
def w7_br_368(w7_c: Bool, +source: String, +error: KTerm) -> String:
  match w7_c:
    case True{}:
      fpe_seek(source, source, 1, 0, 0, error)
    case False{}:
      w7_br_367(f_eq(nm(kid(error, 1)), "<eof>"), source, error)

@unsafe
def w7_br_369(w7_c: Bool, +source: String, +error: KTerm) -> String:
  match w7_c:
    case True{}:
      w7_br_368(U32.is_gt(ix(error), 0), source, error)
    case False{}:
      nm(error)

@unsafe
def w7_br_371(w7_c: Bool, +source: String, +rest: String, +line: U32, +column: U32, +offset: U32, +error: KTerm) -> String:
  match w7_c:
    case True{}:
      fpe_seek(source, f_tail(rest), U32.add(line, 1), 0, U32.add(offset, 1), error)
    case False{}:
      fpe_seek(source, f_tail(rest), line, U32.add(column, 1), U32.add(offset, dg_units(f_head(rest))), error)

@unsafe
def w7_br_372(w7_c: Bool, +source: String, +rest: String, +line: U32, +column: U32, +offset: U32, +error: KTerm) -> String:
  match w7_c:
    case True{}:
      nm(error)
    case False{}:
      w7_br_371(U32.is_eq(Char.to_u32(f_head(rest)), 10), source, rest, line, column, offset, error)

@unsafe
def w7_br_373(w7_c: Bool, +source: String, +rest: String, +line: U32, +column: U32, +offset: U32, +error: KTerm) -> String:
  match w7_c:
    case True{}:
      fpe_here(source, rest, offset, error)
    case False{}:
      w7_br_372(String.is_empty(rest), source, rest, line, column, offset, error)

@unsafe
def fpe_seek(source, rest, line, column, offset, error):
  w7_br_373(U32.is_eq(line, ix(error)) && U32.is_eq(column, qt(error)), source, rest, line, column, offset, error)

# Module: src/front/parser.bend:573
@unsafe
def fpe_here(source, rest, offset, error):
  w7_br_376(String.is_empty(rest), source, rest, offset, error)

# Module: src/front/parser.bend:577
@unsafe
def w7_br_423(w7_c: Bool, +origin: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      k_with_span(f_string_at(f_tail(nm(origin)), origin), kb(origin), ke(origin))
    case False{}:
      f_literal_value(origin, f_literal(nm(origin)))

@unsafe
def f_literal_at(+origin: KTerm) -> KTerm:
  w7_br_423(Char.is_eq(f_head(nm(origin)), '"'), origin)

# Module: src/front/elaborate.bend:226
@unsafe
def f_nat_extend(a, b):
  f_nat_extend_value(a, b, f_choose(KTerm, f_eq(tg(b), "Literal") && String.ends_with(nm(b), "n"), u => f_literal(nm(b)), u => b))

# Module: src/front/literals_arrays.bend:126
@unsafe
def w7_br_544(w7_c: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +ty: KTerm, +r: KChecking) -> KChecking:
  match w7_c:
    case True{}:
      KChecking{kt("DTrace", nm(ct(r)), ix(ct(r)), qt(ct(r)), [kid(ct(r), 0), kid(ct(r), 1), kid(ct(r), 2), kid(ct(r), 3), kt("DTrail", "", 0, 0, norm_join(ks(kid(ct(r), 4)), [t])), kid(ct(r), 5)]), cy(r), cs(r), ce(r), rw(r), rx(r)}
    case False{}:
      dg_trace_detail(ke_world(e, rw(r)), ctx, t, r, kc(KTerm, p98_tag_eq(ct(r), "DDetail"), u => ct(r), u => dg_reason(ke_world(e, rw(r)), ctx, t, ty, ce(r))))

@unsafe
def w7_br_553(w7_c: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +ty: KTerm, +code: String) -> KTerm:
  match w7_c:
    case True{}:
      dg_pair(dg_text("a bound variable"), kc(KTerm, p98_tag_eq(t, "FUnboundVar"), u => dg_text(nm(t) ++ kc(String, kp_bound(dg_scope(ctx, Nil{}), nm(t)), u => "^-1", u => "")), u => t))
    case False{}:
      w7_br_552(p88_string_eq(code, "nondecreasing self-call"), e, t, ty, code)

@unsafe
def w7_br_554(w7_c: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +ty: KTerm, +code: String) -> KTerm:
  match w7_c:
    case True{}:
      dg_pair(dg_text("a defined name"), t)
    case False{}:
      w7_br_553(p88_string_eq(code, "unbound variable"), e, ctx, t, ty, code)

@unsafe
def dg_reason(e, ctx, t, ty, code):
  w7_br_554(p88_string_eq(code, "undefined name"), e, ctx, t, ty, code)

# Module: src/diagnostic/trace.bend:95
@unsafe
def w7_br_562(w7_c: Bool, +d: KDef, +r: KChecking) -> KWorld:
  match w7_c:
    case True{}:
      kw_put_checked(kw_with_book(rw(r), book_put(kw_book(rw(r)), d)), dg_event_output(d, ct(r)))
    case False{}:
      rw(r)

@unsafe
def dg_event_publish(+rest: List<&2,KDef>, +d: KDef, +r: KChecking) -> KWorld:
  w7_br_562(p88_string_eq(dk(lookup(rest, dn(d))), "Absent"), d, r)

# Module: src/diagnostic/produce.bend:153
@unsafe
def j_io_shadow(book):
  j_io_shadow_def(book, lookup(book, "IO"))

# Module: src/back/common/queries.bend:185
@unsafe
def j_io_shadow_def(book, d):
  book_put(book, KDef{dn(d), dk(d), da(d), dx(d), dt(d), {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, dc(d), db(d), du(d)})

# Module: src/back/common/queries.bend:194
@unsafe
def j_literal_typed(
  +book: List<&2, KDef>,
  +t: KTerm,
  +ty: KTerm,
) -> String:
  +literal = j_literal(t)
  kc(String, p88_string_eq(literal, ""), u => "", u => j_literal_provenance(book, wnf(book, ty), literal))

# Module: src/back/js/literals.bend:138
@unsafe
def j_layout_term(book, env, t, ty, todo):
  j_layout_kind(book, env, t, ty, todo, tg(t))

# Module: src/back/js/validate.bend:194
@unsafe
def j_layout_kind(book, env, t, ty, todo, key):
  kc(List<&2, String>, p88_string_eq(key, "Ann"), u => j_layout_term(book, env, kid(t, 0), kid(t, 1), todo), u =>
  kc(List<&2, String>, p88_string_eq(key, "Ref"), u => j_layout_mark(j_layout_array_intrinsic(book, t), Con{nm(t), todo}), u =>
  kc(List<&2, String>, p88_string_eq(key, "App"), u => j_layout_app(book, env, t, wnf(book, j_type(book, env, kid(t, 0))), todo), u =>
  kc(List<&2, String>, p88_string_eq(key, "Lam"), u => j_layout_lam(book, env, t, wnf(book, ty), todo), u =>
  kc(List<&2, String>, p88_string_eq(key, "Mat"), u => j_layout_match(book, env, t, wnf(book, ty), todo), u =>
  kc(List<&2, String>, p88_string_eq(key, "Ctr"), u => kc(List<&2, String>, Bool.not(p88_string_eq(kc(String, j_layout_native_nat(book, t, wnf(book, ty)), u => "", u => j_literal_typed(book, t, ty)), "")), u => todo, u => j_layout_mark(j_layout_open(book, ty), j_layout_fields(book, env, ks(t), j_specialize(book, dt(j_layout_ctor(book, wnf(book, ty), nm(t))), ks(wnf(book, ty))), todo))), u =>
  kc(List<&2, String>, p88_string_eq(key, "Let"), u => j_layout_let(book, env, ks(t), ty, todo), u =>
  kc(List<&2, String>, p88_string_eq(key, "Rwt"), u => j_layout_term(book, env, kid(t, 2), ty, todo), u => todo))))))))

# Module: src/back/js/validate.bend:213
@unsafe
def j_layout_lam(book, env, t, ty, todo):
  j_layout_term(book, Con{kt("Env", "", ix(t), 0, Con{kid(ty, 0), Nil{}}), env}, kid(t, 0), subst(kid(ty, 1), ix(ty), var(nm(t), ix(t))), todo)

# Module: src/back/js/validate.bend:225
@unsafe
def j_layout_match(book, env, t, ty, todo):
  j_layout_mark(j_layout_open(book, kid(ty, 0)), j_layout_term(book, env, kid(t, 0), j_arm_tel(book, j_specialize(book, dt(j_layout_ctor(book, wnf(book, kid(ty, 0)), nm(t))), ks(wnf(book, kid(ty, 0)))), kid(ty, 1)), kc(List<&2, String>, U32.is_eq(j_constructor_count(book, wnf(book, kid(ty, 0))), 1), u => todo, u => j_layout_term(book, env, kid(t, 1), ty, todo))))

# Module: src/back/js/validate.bend:237
@unsafe
def j_layout_app(book, env, t, fty, todo):
  j_layout_mark(j_layout_intrinsic(book, j_strip(kid(t, 0)), kid(t, 1)), j_layout_function(book, env, kid(t, 0), fty, kc(List<&2, String>, p98_tag_eq(fty, "All") && U32.is_eq(qt(fty), 0), u => todo, u => j_layout_term(book, env, kid(t, 1), kid(fty, 0), todo))))

# Module: src/back/js/validate.bend:249
@unsafe
def j_layout_function(book, env, t, ty, todo):
  kc(List<&2, String>, p98_tag_eq(j_strip(t), "Ref"), u => Con{nm(j_strip(t)), todo}, u => j_layout_term(book, env, t, ty, todo))

# Module: src/back/js/validate.bend:253
@unsafe
def j_layout_fields(book, env, args, tel, todo):
  match args:
    case Nil{}: todo
    case Con{h, rest}:
      j_layout_fields(book, env, rest, j_app_type(tel, h), kc(List<&2, String>, p98_tag_eq(tel, "All") && U32.is_eq(qt(tel), 0), u => todo, u => j_layout_term(book, env, h, kid(tel, 0), todo)))

# Module: src/back/js/validate.bend:310
@unsafe
def j_layout_let(book, env, xs, ty, todo):
  j_layout_bindings(book, env, xs, j_layout_term(book, j_context(book, env, xs), j_body(xs), ty, todo))

# Module: src/back/js/validate.bend:321
@unsafe
def j_layout_bindings(book, env, xs, todo):
  match xs:
    case Nil{}: todo
    case Con{h, Nil{}}: todo
    case Con{h, rest}:
      j_layout_bindings(book, env, rest, kc(List<&2, String>, U32.is_eq(qt(h), 0), u => todo, u => j_layout_term(book, env, kid(h, 0), j_type(book, env, kid(h, 0)), todo)))

# Checked constructor terms identify their ADT; its local telescope lookup avoids
# repeatedly scanning every unrelated definition. Unknown shapes retain fallback.
# A checked native Nat layer has no layout-sensitive fields. Visit its field
# normally, preserving dynamic-tail references, instead of rescanning its suffix.

# Module: src/back/js/validate.bend:333
@unsafe
def w7b_jl_term_if(isAnn: Bool, +book: List<&2, KDef>, +t: KTerm, +todo: List<&2, String>) -> List<&2, String>:
  match isAnn:
    case True{}: jl_node(book, kid(t, 0), kid(t, 1), todo)
    case False{}: j_layout_term(book, Nil{}, t, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, todo)

@unsafe
def jl_term(book, t, todo):
  w7b_jl_term_if(p98_tag_eq(t, "Ann"), book, t, todo)

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
      w7b_jl_bnd_if(U32.is_eq(qt(h), 0), book, h, jl_bindings(book, rest, todo))

# Module: src/back/js/u32.bend:14
@unsafe
def j_pure_type(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  j_region_local_ok(j_pure_type_check(book, ty, Nil{}, 512))

# Module: src/back/js/jpure.bend:37
@unsafe
def j_pure_type_check(+book: List<&2,KDef>, +ty: KTerm, +active: List<&2,String>, +fuel: U32) -> Maybe<&2,U32>:
  kc(Maybe<&2,U32>, U32.is_gt(fuel, 0), u =>
    j_pure_type_head(book, wnf(book, ty), active, U32.sub(fuel, 1)), u => None{})

# Module: src/back/js/jpure.bend:42
@unsafe
def j_pure_type_head(+book: List<&2,KDef>, +ty: KTerm, +active: List<&2,String>, +fuel: U32) -> Maybe<&2,U32>:
  +owner = lookup(book, nm(ty))
  +kind = wnf(book, dt(owner))
  kc(Maybe<&2,U32>, j_region_scalar(book, ty) || j_map_cmp_type(book, ty) || j_list_ground_type(book, ty) || j_string_char_type(book, ty) || j_string_string(book, ty) || j_pure_unit_type(book, ty), u => Some{fuel}, u =>
    kc(Maybe<&2,U32>, j_map_maybe_head(book, ty), u => j_map_maybe_check(book, ty, active, fuel), u =>
    kc(Maybe<&2,U32>, j_pure_map_head(book, ty), u => j_pure_map_check(book, ty, active, fuel), u =>
    kc(Maybe<&2,U32>, j_pure_list_head(book, ty), u => j_pure_list_check(book, ty, active, fuel), u =>
    kc(Maybe<&2,U32>, j_pure_sigma_head(book, ty), u => j_pure_sigma_check(book, ty, active, fuel), u =>
    kc(Maybe<&2,U32>, p98_tag_eq(ty, "ADT") && U32.is_eq(terms_len(ks(ty)), 0) && List.is_empty(&2, String, rm(ty)) &&
      p88_string_eq(dk(owner), "ADT") && Bool.not(db(owner)) && U32.is_eq(da(owner), 0) && U32.is_eq(dx(owner), 0) &&
      p98_tag_eq(kind, "Typ") && U32.is_eq(terms_len(ks(kind)), 1) && p98_tag_eq(kid(kind, 0), "Qua") && U32.is_eq(qt(kid(kind, 0)), 2), u =>
      kc(Maybe<&2,U32>, has_name(active, nm(ty)), u => Some{fuel}, u =>
        kc(Maybe<&2,U32>, Bool.not(List.is_empty(&2, KDef, dc(owner))) && U32.is_le(j_region_def_count(dc(owner)), 32), u =>
          j_pure_type_ctors(book, dc(owner), nm(ty), Con{nm(ty), active}, fuel), u => None{})), u => None{}))))))

# Module: src/back/js/jpure.bend:58
@unsafe
def j_pure_type_ctors(+book: List<&2,KDef>, +cs: List<&2,KDef>, +owner: String, +active: List<&2,String>, +fuel: U32) -> Maybe<&2,U32>:
  match cs:
    case Nil{}: Some{fuel}
    case Con{c, rest}:
      kc(Maybe<&2,U32>, U32.is_gt(fuel, 0) && p88_string_eq(dk(c), "Ctr") && Bool.not(db(c)) && U32.is_eq(dx(c), 0) && U32.is_le(da(c), 32), u =>
        j_pure_type_ctor_next(book, rest, owner, active, j_pure_type_fields(book, dt(c), owner, da(c), active, U32.sub(fuel, 1))), u => None{})

# Module: src/back/js/jpure.bend:66
@unsafe
def j_pure_type_ctor_next(+book: List<&2,KDef>, +rest: List<&2,KDef>, +owner: String, +active: List<&2,String>, +r: Maybe<&2,U32>) -> Maybe<&2,U32>:
  match r:
    case Some{fuel}: j_pure_type_ctors(book, rest, owner, active, fuel)
    case None{}: None{}

# Module: src/back/js/jpure.bend:72
@unsafe
def j_pure_type_fields(+book: List<&2,KDef>, +ty: KTerm, +owner: String, +left: U32, +active: List<&2,String>, +fuel: U32) -> Maybe<&2,U32>:
  +head = wnf(book, ty)
  kc(Maybe<&2,U32>, U32.is_eq(left, 0), u =>
    kc(Maybe<&2,U32>, p98_tag_eq(head, "ADT") && p88_string_eq(nm(head), owner) && U32.is_eq(terms_len(ks(head)), 0) && List.is_empty(&2, String, rm(head)),
      u => Some{fuel}, u => None{}), u =>
    kc(Maybe<&2,U32>, U32.is_gt(fuel, 0) && p98_tag_eq(head, "All") && Bool.not(U32.is_eq(qt(head), 0)), u =>
      j_pure_type_field_next(book, kid(head, 1), owner, U32.sub(left, 1), active,
        j_pure_type_check(book, kid(head, 0), active, U32.sub(fuel, 1))), u => None{}))

# Module: src/back/js/jpure.bend:82
@unsafe
def j_pure_type_field_next(+book: List<&2,KDef>, +ty: KTerm, +owner: String, +left: U32, +active: List<&2,String>, +r: Maybe<&2,U32>) -> Maybe<&2,U32>:
  match r:
    case Some{fuel}: j_pure_type_fields(book, ty, owner, left, active, fuel)
    case None{}: None{}

# Exact closed native containers. The root graph proves ownership separately;
# these predicates never grant public entry and do not change U32 List selectors.

# Module: src/back/js/jpure.bend:436
@unsafe
def j_pure_same_closed(+book: List<&2,KDef>, +a: KTerm, +b: KTerm, +fuel: U32) -> Bool:
  j_region_local_ok(j_pure_same_check(book, a, b, fuel))

# Module: src/back/js/jpure.bend:488
@unsafe
def j_pure_same_check(+book: List<&2,KDef>, +a: KTerm, +b: KTerm, +fuel: U32) -> Maybe<&2,U32>:
  kc(Maybe<&2,U32>, U32.is_gt(fuel, 0), u => j_pure_same_heads(book, wnf(book, a), wnf(book, b), U32.sub(fuel, 1)), u => None{})

# Module: src/back/js/jpure.bend:492
@unsafe
def j_pure_same_heads(+book: List<&2,KDef>, +a: KTerm, +b: KTerm, +fuel: U32) -> Maybe<&2,U32>:
  kc(Maybe<&2,U32>, p88_string_eq(nm(a), "Maybe") || p88_string_eq(nm(b), "Maybe"), u =>
    kc(Maybe<&2,U32>, j_map_maybe_head(book, a) && j_map_maybe_head(book, b), u =>
      j_pure_same_check(book, kid(a, 1), kid(b, 1), fuel), u => None{}), u =>
  kc(Maybe<&2,U32>, p88_string_eq(nm(a), "Map") || p88_string_eq(nm(b), "Map"), u =>
    kc(Maybe<&2,U32>, j_pure_map_head(book, a) && j_pure_map_head(book, b), u =>
      j_pure_same_check(book, kid(a, 1), kid(b, 1), fuel), u => None{}), u =>
  kc(Maybe<&2,U32>, p88_string_eq(nm(a), "List") || p88_string_eq(nm(b), "List"), u =>
    kc(Maybe<&2,U32>, j_pure_list_head(book, a) && j_pure_list_head(book, b), u =>
      j_pure_same_check(book, kid(a, 1), kid(b, 1), fuel), u => None{}), u =>
  kc(Maybe<&2,U32>, p88_string_eq(nm(a), "Sigma") || p88_string_eq(nm(b), "Sigma"), u =>
    kc(Maybe<&2,U32>, j_pure_sigma_head(book, a) && j_pure_sigma_head(book, b) &&
      U32.is_eq(qt(kid(a, 0)), qt(kid(b, 0))) && U32.is_eq(qt(kid(a, 1)), qt(kid(b, 1))), u =>
      j_pure_same_next(book, kid(kid(a, 3), 0), kid(kid(b, 3), 0),
        j_pure_same_check(book, kid(a, 2), kid(b, 2), fuel)), u => None{}), u =>
    kc(Maybe<&2,U32>, p98_tag_eq(a, "ADT") && p98_tag_eq(b, "ADT") && p88_string_eq(nm(a), nm(b)) &&
      List.is_empty(&2, KTerm, ks(a)) && List.is_empty(&2, KTerm, ks(b)) &&
      List.is_empty(&2, String, rm(a)) && List.is_empty(&2, String, rm(b)), u => Some{fuel}, u => None{})))))

# Module: src/back/js/jpure.bend:512
@unsafe
def j_pure_same_next(+book: List<&2,KDef>, +a: KTerm, +b: KTerm, +result: Maybe<&2,U32>) -> Maybe<&2,U32>:
  match result:
    case Some{fuel}: j_pure_same_check(book, a, b, fuel)
    case None{}: None{}

# Native constructors retain exact field quantities and complete terminal type.
# A List tail is checked against its current specialization, not recursively
# re-expanded. Its element already consumes the shared type-proof budget.

# Module: src/back/js/jpure.bend:521
@unsafe
def j_pure_closed_fields(+book: List<&2,KDef>, +tel: KTerm, +expected: KTerm, +left: U32, +active: List<&2,String>, +fuel: U32) -> Maybe<&2,U32>:
  kc(Maybe<&2,U32>, U32.is_gt(fuel, 0), u =>
    j_pure_closed_fields_head(book, wnf(book, tel), expected, left, active, U32.sub(fuel, 1)), u => None{})

# Module: src/back/js/jpure.bend:526
@unsafe
def j_pure_closed_fields_head(+book: List<&2,KDef>, +tel: KTerm, +expected: KTerm, +left: U32, +active: List<&2,String>, +fuel: U32) -> Maybe<&2,U32>:
  kc(Maybe<&2,U32>, U32.is_eq(left, 0), u =>
    kc(Maybe<&2,U32>, j_pure_same_closed(book, tel, expected, 64), u => Some{fuel}, u => None{}), u =>
  kc(Maybe<&2,U32>, p98_tag_eq(tel, "All") && U32.is_eq(qt(tel), 1) &&
    j_pure_same_closed(book, kid(tel, 0), j_pure_closed_field(expected, left), 64), u =>
    kc(Maybe<&2,U32>, p88_string_eq(nm(expected), "List") && U32.is_eq(left, 1), u =>
      kc(Maybe<&2,U32>, j_pure_same_closed(book, kid(tel, 0), expected, 64), u =>
        j_pure_closed_fields(book, kid(tel, 1), expected, 0, active, fuel), u => None{}), u =>
      j_pure_closed_fields_next(book, kid(tel, 1), expected, U32.sub(left, 1), active,
        j_pure_type_check(book, kid(tel, 0), active, fuel))), u => None{}))

# Module: src/back/js/jpure.bend:538
@unsafe
def j_pure_closed_fields_next(+book: List<&2,KDef>, +tel: KTerm, +expected: KTerm, +left: U32, +active: List<&2,String>, +r: Maybe<&2,U32>) -> Maybe<&2,U32>:
  match r:
    case Some{fuel}: j_pure_closed_fields(book, tel, expected, left, active, fuel)
    case None{}: None{}

# Module: src/back/js/jpure.bend:549
@unsafe
def j_pure_list_check(+book: List<&2,KDef>, +ty: KTerm, +active: List<&2,String>, +fuel: U32) -> Maybe<&2,U32>:
  +owner = lookup(book, "List")
  j_pure_closed_fields_next(book, j_specialize(book, dt(lookup(dc(owner), "Con")), ks(ty)), ty, 2, active,
    j_pure_closed_fields(book, j_specialize(book, dt(lookup(dc(owner), "Nil")), ks(ty)), ty, 0, active, fuel))

# Module: src/back/js/jpure.bend:555
@unsafe
def j_pure_sigma_check(+book: List<&2,KDef>, +ty: KTerm, +active: List<&2,String>, +fuel: U32) -> Maybe<&2,U32>:
  +owner = lookup(book, "Sigma")
  j_pure_closed_fields(book, j_specialize(book, dt(lookup(dc(owner), "Tuple")), ks(ty)), ty, 2, active, fuel)

# Proposed exact proofs; integrate only with all runtime/capture consumers.

# Module: src/back/js/jpure.bend:573
@unsafe
def w7_br_619(w7_c: Bool, +book: List<&2,KDef>) -> Bool:
  match w7_c:
    case True{}:
      j_string_string_fields(book)
    case False{}:
      False{}

@unsafe
def j_string_string(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  w7_br_619(j_string_owner(book, ty, "String", 2), book)

# Module: src/back/js/jpure.bend:602
@unsafe
def j_pure_map_fields(+book: List<&2,KDef>, +tel: KTerm, +expected: KTerm, +fields: List<&2,KTerm>, +active: List<&2,String>, +fuel: U32) -> Maybe<&2,U32>:
  kc(Maybe<&2,U32>, U32.is_gt(fuel, 0), u =>
    j_pure_map_fields_head(book, wnf(book, tel), expected, fields, active, U32.sub(fuel, 1)), u => None{})

# Module: src/back/js/jpure.bend:689
@unsafe
def j_pure_map_fields_head(+book: List<&2,KDef>, +tel: KTerm, +expected: KTerm, +fields: List<&2,KTerm>, +active: List<&2,String>, +fuel: U32) -> Maybe<&2,U32>:
  match fields:
    case Nil{}:
      kc(Maybe<&2,U32>, j_pure_same_closed(book, tel, expected, 64), u => Some{fuel}, u => None{})
    case Con{h, rest}:
      kc(Maybe<&2,U32>, p98_tag_eq(tel, "All") && U32.is_eq(qt(tel), 1) &&
        j_pure_same_closed(book, kid(tel, 0), h, 64), u =>
        kc(Maybe<&2,U32>, j_pure_same_closed(book, h, expected, 64), u =>
          j_pure_map_fields(book, kid(tel, 1), expected, rest, active, fuel), u =>
          j_pure_map_fields_next(book, kid(tel, 1), expected, rest, active,
            j_pure_type_check(book, h, active, fuel))), u => None{})

# Module: src/back/js/jpure.bend:702
@unsafe
def j_pure_map_fields_next(+book: List<&2,KDef>, +tel: KTerm, +expected: KTerm, +fields: List<&2,KTerm>, +active: List<&2,String>, +r: Maybe<&2,U32>) -> Maybe<&2,U32>:
  match r:
    case None{}: None{}
    case Some{fuel}: j_pure_map_fields(book, tel, expected, fields, active, fuel)

# Module: src/back/js/jpure.bend:708
@unsafe
def j_pure_map_check(+book: List<&2,KDef>, +ty: KTerm, +active: List<&2,String>, +fuel: U32) -> Maybe<&2,U32>:
  +cs = dc(lookup(book, "Map"))
  j_pure_map_leaf(book, ty, active,
    j_pure_map_fields(book, j_specialize(book, dt(lookup(cs, "MTip")), ks(ty)), ty, Nil{}, active, fuel))

# Module: src/back/js/jpure.bend:714
@unsafe
def j_pure_map_leaf(+book: List<&2,KDef>, +ty: KTerm, +active: List<&2,String>, +r: Maybe<&2,U32>) -> Maybe<&2,U32>:
  match r:
    case None{}: None{}
    case Some{fuel}:
      +c = lookup(dc(lookup(book, "Map")), "MLeaf")
      j_pure_map_node(book, ty, active,
        j_pure_map_fields(book, j_specialize(book, dt(c), ks(ty)), ty,
          [kt("ADT", "String", 0, 0, Nil{}), kid(ty, 1)], active, fuel))

# Module: src/back/js/jpure.bend:724
@unsafe
def j_pure_map_node(+book: List<&2,KDef>, +ty: KTerm, +active: List<&2,String>, +r: Maybe<&2,U32>) -> Maybe<&2,U32>:
  match r:
    case None{}: None{}
    case Some{fuel}:
      +c = lookup(dc(lookup(book, "Map")), "MNode")
      j_pure_map_fields(book, j_specialize(book, dt(c), ks(ty)), ty,
        [kt("ADT", "Nat", 0, 0, Nil{}), ty, ty], active, fuel)

# Exact native scalar-key components needed by closed Map graphs. These proof
# rows do not create public argument admission or change residual native code.

# Module: src/back/js/jpure.bend:1351
@unsafe
def j_map_maybe_check(+book: List<&2,KDef>, +ty: KTerm, +active: List<&2,String>, +fuel: U32) -> Maybe<&2,U32>:
  +cs = dc(lookup(book, "Maybe"))
  j_map_maybe_some(book, ty, active,
    j_pure_map_fields(book, j_specialize(book, dt(lookup(cs, "None")), ks(ty)), ty, Nil{}, active, fuel))

# Module: src/back/js/jpure.bend:1391
@unsafe
def j_map_maybe_some(+book: List<&2,KDef>, +ty: KTerm, +active: List<&2,String>, +r: Maybe<&2,U32>) -> Maybe<&2,U32>:
  match r:
    case None{}: None{}
    case Some{fuel}:
      +c = lookup(dc(lookup(book, "Maybe")), "Some")
      j_pure_map_fields(book, j_specialize(book, dt(c), ks(ty)), ty, [kid(ty, 1)], active, fuel)

# Module: src/back/js/jpure.bend:1404
@unsafe
def j_fusion_scalar(+book: List<&2,KDef>, +t: KTerm, +vars: List<&2,KTerm>) -> Bool:
  +h = j_strip(t)
  +s = j_call_spine(h, Nil{})
  kc(Bool, p98_tag_eq(h, "Var"), u => j_fusion_has_var(vars, ix(h)), u =>
    kc(Bool, p98_tag_eq(h, "Lit"), u => p88_string_eq(nm(h), "U32"), u =>
      p98_tag_eq(s, "Call") && j_primitive_call(book, s) && U32.is_eq(terms_len(ks(s)), 2) &&
      (p88_string_eq(nm(s), "U32.add") || p88_string_eq(nm(s), "U32.sub") || p88_string_eq(nm(s), "U32.mul") ||
       p88_string_eq(nm(s), "U32.mod") || p88_string_eq(nm(s), "U32.is_eq") ||
       p88_string_eq(nm(s), "U32.is_gt") || p88_string_eq(nm(s), "U32.is_lt")) &&
      j_fusion_scalars(book, ks(s), vars)))

# Module: src/back/js/region.bend:849
@unsafe
def j_fusion_scalars(+book: List<&2,KDef>, +xs: List<&2,KTerm>, +vars: List<&2,KTerm>) -> Bool:
  match xs:
    case Nil{}: True{}
    case Con{h, rest}: j_fusion_scalar(book, h, vars) && j_fusion_scalars(book, rest, vars)

# Module: src/back/js/region.bend:855
@unsafe
def j_fusion_producer(+book: List<&2,KDef>, +d: KDef, +empty: String, +link: String) -> Bool:
  +z = j_fusion_empty(d)
  +s = j_fusion_link(d)
  +body = j_fusion_after(s, 2)
  +call = j_call_spine(kid(body, 1), Nil{})
  j_fusion_def(d, 2) && j_fusion_cases(dv(d), "Zero", "Succ") &&
    p98_tag_eq(j_fusion_binder(z, 0), "Lam") && j_fusion_ctor(j_fusion_after(z, 1), empty, 0) &&
    p98_tag_eq(j_fusion_binder(s, 1), "Lam") && j_fusion_ctor(body, link, 2) &&
    j_fusion_call(call, dn(d), 2) && j_fusion_var(kid(call, 0), ix(j_fusion_binder(s, 0))) &&
    j_fusion_scalar(book, kid(body, 0), [j_fusion_binder(s, 1)]) &&
    j_fusion_scalar(book, kid(call, 1), [j_fusion_binder(s, 1)])

# Module: src/back/js/region.bend:935
@unsafe
def j_fusion_map(+book: List<&2,KDef>, +d: KDef, +empty: String, +link: String) -> Bool:
  +s = j_fusion_link(d)
  +body = j_fusion_after(s, 2)
  +call = j_call_spine(kid(body, 1), Nil{})
  j_fusion_def(d, 1) && j_fusion_cases(dv(d), empty, link) && j_fusion_ctor(j_fusion_empty(d), empty, 0) &&
    p98_tag_eq(j_fusion_binder(s, 1), "Lam") && j_fusion_ctor(body, link, 2) &&
    j_fusion_call(call, dn(d), 1) && j_fusion_var(kid(call, 0), ix(j_fusion_binder(s, 1))) &&
    j_fusion_scalar(book, kid(body, 0), [j_fusion_binder(s, 0)])

# Module: src/back/js/region.bend:945
@unsafe
def j_fusion_fold(+book: List<&2,KDef>, +d: KDef, +empty: String, +link: String) -> Bool:
  +z = j_fusion_empty(d)
  +s = j_fusion_link(d)
  +call = j_call_spine(j_fusion_after(s, 3), Nil{})
  j_fusion_def(d, 2) && j_fusion_cases(dv(d), empty, link) &&
    p98_tag_eq(j_fusion_binder(z, 0), "Lam") && j_fusion_var(j_fusion_after(z, 1), ix(j_fusion_binder(z, 0))) &&
    p98_tag_eq(j_fusion_binder(s, 2), "Lam") && j_fusion_call(call, dn(d), 2) &&
    j_fusion_var(kid(call, 0), ix(j_fusion_binder(s, 1))) &&
    j_fusion_scalar(book, kid(call, 1), [j_fusion_binder(s, 0), j_fusion_binder(s, 2)])

# The selector consumes head, child and Bool; True reconstructs exactly one
# original node and False returns exactly the child. Arbitrary callbacks refuse.

# Module: src/back/js/region.bend:958
@unsafe
def j_fusion_filter(+book: List<&2,KDef>, +d: KDef, +empty: String, +link: String) -> Bool:
  +s = j_fusion_link(d)
  +call = j_call_spine(j_fusion_unlet(j_fusion_after(s, 2), 8), Nil{})
  +child = j_call_spine(kid(call, 1), Nil{})
  j_fusion_def(d, 1) && j_fusion_cases(dv(d), empty, link) && j_fusion_ctor(j_fusion_empty(d), empty, 0) &&
    p98_tag_eq(j_fusion_binder(s, 1), "Lam") && p98_tag_eq(call, "Call") && U32.is_eq(terms_len(ks(call)), 3) &&
    j_fusion_choose(lookup(book, nm(call)), link) && j_fusion_var(kid(call, 0), ix(j_fusion_binder(s, 0))) &&
    j_fusion_call(child, dn(d), 1) && j_fusion_var(kid(child, 0), ix(j_fusion_binder(s, 1))) &&
    j_fusion_scalar(book, kid(call, 2), [j_fusion_binder(s, 0)])

# Candidate source fragment for region.bend. No source-name specialization.
# Not checked: root owns acquisition and qualified integration.

# Module: src/back/js/region.bend:1061
@unsafe
def j_callback_scalar(+book: List<&2,KDef>, +t: KTerm, +vars: List<&2,KTerm>, +pred: U32, +fuel: U32) -> Bool:
  +h = j_strip(t)
  +s = j_call_spine(h, Nil{})
  kc(Bool, U32.is_gt(fuel, 0), u =>
    kc(Bool, p98_tag_eq(h, "Var"), u => j_fusion_has_var(vars, ix(h)), u =>
      kc(Bool, p98_tag_eq(h, "Lit"), u => p88_string_eq(nm(h), "U32"), u =>
        kc(Bool, j_fusion_call(s, "U32.from_nat", 1) && j_primitive_call(book, s),
          u => j_fusion_var(kid(s, 0), pred), u =>
          kc(Bool, p98_tag_eq(s, "Call") && U32.is_eq(terms_len(ks(s)), 2) &&
            (p88_string_eq(nm(s), "U32.add") || p88_string_eq(nm(s), "U32.sub") || p88_string_eq(nm(s), "U32.mul") || p88_string_eq(nm(s), "U32.mod")) &&
            j_primitive_call(book, s), u =>
            kc(Bool, j_callback_scalar(book, kid(s, 0), vars, pred, U32.sub(fuel, 1)),
              u => j_callback_scalar(book, kid(s, 1), vars, pred, U32.sub(fuel, 1)), u => False{}), u => False{})))), u => False{})

# The exact generic composition domain is Type&1, with three erased q0
# binders. Type&2 native U32 is specialized only after that formal proof.

# Module: src/back/js/region.bend:1092
@unsafe
def j_callback_factory_on(+book: List<&2,KDef>, +d: KDef) -> Bool:
  +z = j_strip(j_fusion_empty(d))
  +s = j_fusion_link(d)
  +p = j_fusion_binder(s, 0)
  +body = j_fusion_after(s, 1)
  +binding = kid(body, 0)
  +call = j_call_spine(kid(body, 1), Nil{})
  +leaf = j_strip(kid(call, 3))
  +recur = j_call_spine(kid(call, 4), Nil{})
  j_fusion_def(d, 1) && j_callback_factory_type(book, dt(d)) && j_u32_bounded([dt(d), dv(d)], 4096) &&
    j_fusion_cases(dv(d), "Zero", "Succ") && p98_tag_eq(z, "Lam") &&
    U32.is_eq(terms_len(ks(z)), 1) && j_fusion_var(kid(z, 0), ix(z)) &&
    p98_tag_eq(p, "Lam") && p98_tag_eq(body, "Let") && U32.is_eq(terms_len(ks(body)), 2) &&
    p98_tag_eq(binding, "Bind") && Bool.not(U32.is_eq(qt(binding), 0)) && U32.is_eq(terms_len(ks(binding)), 1) &&
    j_callback_scalar(book, kid(binding, 0), Nil{}, ix(p), 256) &&
    p98_tag_eq(call, "Call") && U32.is_eq(terms_len(ks(call)), 5) &&
    j_callback_compose(book, lookup(book, nm(call))) &&
    j_primitive_type(book, wnf(book, kid(call, 0)), "U32") &&
    j_primitive_type(book, wnf(book, kid(call, 1)), "U32") &&
    j_primitive_type(book, wnf(book, kid(call, 2)), "U32") &&
    p98_tag_eq(leaf, "Lam") && U32.is_eq(terms_len(ks(leaf)), 1) &&
    j_fusion_scalar(book, kid(leaf, 0), [leaf, binding]) &&
    j_fusion_call(recur, dn(d), 1) && j_fusion_var(kid(recur, 0), ix(p))

# The source proof admits from_nat only on the predecessor. Inside a bounded
# U32 countdown its exact U32 image is the already numeric predecessor.

# Module: src/back/js/region.bend:1164
@unsafe
def j_callback_compose(+book: List<&2,KDef>, +d: KDef) -> Bool:
  w7_br_622(j_fusion_def(d, 5) && p98_tag_eq(j_strip(dv(d)), "Lam"), book, d)

# Module: src/back/js/region.bend:1244
@unsafe
def w7_br_623(w7_c: Bool, +book: List<&2,KDef>, +d: KDef) -> Bool:
  match w7_c:
    case True{}:
      j_callback_factory_on(book, d)
    case False{}:
      False{}

@unsafe
def w7_br_624(w7_c: Bool, +book: List<&2,KDef>, +d: KDef) -> Bool:
  match w7_c:
    case True{}:
      w7_br_623(j_u32_bounded([dt(d), dv(d)], 4096), book, d)
    case False{}:
      False{}

@unsafe
def nc_constructor_value(+name: String, +ws: List<&2, String>, +n: U32) -> N_Emitted:
  w7_br_655(p88_string_eq(name, "Zero") || p88_string_eq(name, "False"), name, ws, n)

# Module: src/back/native/bridge.bend:374
@unsafe
def nc_ref_name(+book: List<&2, KDef>, +name: String) -> String:
  w5c2_nc_ref_if(nc_native_def(lookup(book, name)), name)

# Module: src/back/native/bridge.bend:529
@unsafe
def w5c3_nd_call_if(is_app: Bool, +book: List<&2, KDef>, +t: KTerm) -> String:
  match is_app:
    case True{}: nd_native_head(book, t, nd_head(t))
    case False{}: ""

# Module: src/back/native/direct.bend:11
@unsafe
def nd_native_call(+book: List<&2, KDef>, +t: KTerm) -> String:
  w5c3_nd_call_if(p98_tag_eq(t, "App"), book, t)

@unsafe
def w5c3_nd_head_if(is_ref: Bool, +book: List<&2, KDef>, +t: KTerm, +head: KTerm) -> String:
  match is_ref:
    case True{}:
      +hname = nm(head)
      w5c3_nd_head_nat(nc_native_def(lookup(book, hname)), t, hname)
    case False{}: ""

# Module: src/back/native/direct.bend:16
@unsafe
def nd_native_head(+book: List<&2, KDef>, +t: KTerm, +head: KTerm) -> String:
  w5c3_nd_head_if(p98_tag_eq(head, "Ref") && Bool.not(U32.is_eq(qt(head), 3)), book, t, head)

# Module: src/back/native/direct.bend:22
@unsafe
def nd_arity(+book: List<&2, KDef>, +name: String) -> U32:
  +fact = ns_body(book, name)
  nt_choose(U32, U32.is_eq(dx(fact), 1) && (p88_string_eq(dk(fact), "NativeStaticBody") || p88_string_eq(dk(fact), "NativeErasedBody")),
    u => da(fact), u => nd_arity_plain(book, name))

# Module: src/back/native/direct.bend:90
@unsafe
def nd_arity_plain(+book: List<&2, KDef>, +name: String) -> U32:
  +d = lookup(book, name)
  nt_choose(U32, nc_native_def(d), u => nc_primitive_arity(nc_primitive_name(name)), u =>
    nt_choose(U32, p98_tag_eq(nc_unann(dv(d)), "Foreign"), u => nd_foreign_arity(book, dt(d), 0), u => U32.max(nd_leading(dv(d), 0), jd_live_arity(book, dt(d), jd_arity(book, d)))))

# Module: src/back/native/direct.bend:96
@unsafe
def nq_value_shape(+book: List<&2, KDef>, +value: KTerm, +target: NC_Target) -> KTerm:
  +head = nd_head(value)
  nt_choose(KTerm, p98_tag_eq(value, "NQBundle"), u => kt("NQShape", nm(value), terms_len(ks(value)), 0, Nil{}), u =>
    nt_choose(KTerm, p98_tag_eq(value, "Ctr") || p98_tag_eq(value, "NCtr") || p98_tag_eq(value, "NStatic"), u => nq_ctor_shape(value, target), u =>
    nt_choose(KTerm, p98_tag_eq(head, "Ref") && Bool.not(U32.is_eq(qt(head), 3)) && U32.is_eq(nd_arity(book, nm(head)), terms_len(nd_args(value, Nil{}))), u => nq_call_shape(book, nm(head), nd_args(value, Nil{}), target), u =>
      nt_choose(KTerm, p98_tag_eq(value, "NFCall"), u => nq_call_shape(book, nm(value), ks(value), target), u =>
        nt_choose(KTerm, p98_tag_eq(value, "NOp") && nq_pair_primitive(nm(value)), u => kt("NQShape", "Tuple", 2, 0, Nil{}), u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})))))

# Module: src/back/native/product.bend:132
@unsafe
def nq_call_shape(+book: List<&2, KDef>, +name: String, +args: List<&2, KTerm>, +target: NC_Target) -> KTerm:
  +d = lookup(book, name)
  +info = nq_info(target, name)
  nt_choose(KTerm, nc_native_def(d) && nq_pair_primitive(nc_primitive_name(name)), u => kt("NQShape", "Tuple", 2, 0, Nil{}), u =>
    nt_choose(KTerm, p98_tag_eq(dv(info), "NQSig") && nq_args_known(ks(dv(info)), args), u => dt(info), u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}))

# Module: src/back/native/product.bend:271
@unsafe
def nq_signature_def(+book: List<&2, KDef>, +name: String) -> KDef:
  +d = lookup(book, name)
  nt_choose(KDef, p88_string_eq(dk(d), "Def") && Bool.not(nc_foreign(d) || nc_native_def(d)),
    u => nq_signature_user(book, name, d), u => nq_signature_opaque(name))

# Module: src/back/native/product.bend:311
@unsafe
def nq_signature_user(+book: List<&2, KDef>, +name: String, +d: KDef) -> KDef:
  +arity = nd_arity(book, name)
  nt_choose(KDef, U32.is_eq(arity, jd_live_arity(book, dt(d), jd_arity(book, d))),
    u => nq_signature_tele(name, arity, nq_tele(book, dt(d), arity, 256, Nil{})), u => nq_signature_opaque(name))

# Module: src/back/native/product.bend:321
@unsafe
def w5c2_ns_gen_arr_ref(is_ref: Bool, +book: List<&2, KDef>, +name: String) -> Bool:
  match is_ref:
    case False{}: False{}
    case True{}: w5c2_ns_gen_arr_prim(nc_native_def(lookup(book, name)), name)

@unsafe
def ns_generic_array(+book: List<&2, KDef>, +t: KTerm) -> Bool:
  match t:
    case KTerm{tag, name, _, _, _, _, _, _}:
      w5c2_ns_gen_arr_ref(String.eq(tag, "Ref"), book, name)
    case _: False{}

# Module: src/back/native/scalar-array.bend:21
law ns_term:
  for +book: List<&2, KDef>
  for +t: KTerm
  Bool

@unsafe
def ns_terms(+book: List<&2, KDef>, ts: List<&2, KTerm>) -> Bool:
  match ts:
    case Nil{}: True{}
    case Con{h, rest}: ns_term(book, h) && ns_terms(book, rest)

# Module: src/back/native/scalar-array.bend:31
@unsafe
def w5c2_ns_ann_if(is_pat: Bool, +book: List<&2, KDef>, +value: KTerm, +ty: KTerm) -> Bool:
  match is_pat:
    case True{}: ns_array_type(book, w5c2_ns_ann_ty(p98_tag_eq(value, "Mat"), book, ty)) && ns_terms(book, ks(value))
    case False{}: ns_term(book, value)

@unsafe
def ns_annotated(+book: List<&2, KDef>, +value: KTerm, +ty: KTerm) -> Bool:
  w5c2_ns_ann_if(ns_array_pattern(value), book, value, ty)

# Module: src/back/native/scalar-array.bend:37
@unsafe
def w5c2_ns_term_gen(is_gen: Bool, +book: List<&2, KDef>, +kids: List<&2, KTerm>) -> Bool:
  match is_gen:
    case True{}: False{}
    case False{}: ns_terms(book, kids)

@unsafe
def w5c2_ns_term_app2(is_ga: Bool, +book: List<&2, KDef>, +t: KTerm, +k1: KTerm, +kids: List<&2, KTerm>) -> Bool:
  match is_ga:
    case True{}: ns_scalar(book, k1)
    case False{}: w5c2_ns_term_gen(ns_generic_array(book, t), book, kids)

@unsafe
def w5c2_ns_term_app(is_app: Bool, +book: List<&2, KDef>, +t: KTerm, +kids: List<&2, KTerm>) -> Bool:
  match is_app:
    case True{}: w5c2_ns_term_app2(ns_generic_array(book, nc_unann(terms_at(kids, 0))), book, t, terms_at(kids, 1), kids)
    case False{}: w5c2_ns_term_gen(ns_generic_array(book, t), book, kids)

@unsafe
def w5c2_ns_term_rwt(bad: Bool, +tag: String, +book: List<&2, KDef>, +t: KTerm, +kids: List<&2, KTerm>) -> Bool:
  match bad:
    case True{}: False{}
    case False{}: w5c2_ns_term_app(String.eq(tag, "App"), book, t, kids)

@unsafe
def w5c2_ns_term_ann(is_ann: Bool, +tag: String, +name: String, +book: List<&2, KDef>, +t: KTerm, +kids: List<&2, KTerm>) -> Bool:
  match is_ann:
    case True{}: ns_annotated(book, terms_at(kids, 0), terms_at(kids, 1))
    case False{}:
      w5c2_ns_term_rwt(
        String.eq(tag, "Rwt") || ((String.eq(tag, "Ctr") || String.eq(tag, "Mat")) && (String.eq(name, "ALeaf") || String.eq(name, "ANode"))),
        tag, book, t, kids)

@unsafe
def ns_term(book, t):
  match t:
    case KTerm{tag, name, _, _, kids, _, _, _}:
      w5c2_ns_term_ann(String.eq(tag, "Ann"), tag, name, book, t, kids)
    case KLambda{_, _, _, kids, _, _, _, _}:
      ns_terms(book, kids)
    case KLiteral{_, _, _, _, _}: True{}

# Module: src/back/native/scalar-array.bend:44
@unsafe
def ns_definitions(+book: List<&2, KDef>, names: List<&2, String>) -> Bool:
  match names:
    case Nil{}: True{}
    case Con{name, rest}:
      +d = lookup(book, name)
      nt_choose(Bool, nt_choose(Bool, nc_native_def(d), u => True{}, u => nt_choose(Bool, nc_foreign(d),
        v => db(d) && nb_contains(["IO.args", "IO.print", "IO.now"], dn(d)),
        v => ns_term(book, dv(d)))), u => ns_definitions(book, rest), u => False{})

# The same certificate permits root-preserving observers: the current native
# catalog and audited IO.args/print/now handlers expose no immutable-root
# identity or mutation. Any foreign whitelist extension must preserve that
# stronger property or split observer permission from scalar-array permission.
# Preconditions: checked/specialized/annotated book, validated layouts, trusted
# runtime and effect ABI. The host proves the narrow effect-source permission.

# Module: src/back/native/scalar-array.bend:60
# Safe predicate used by the actual scoped observer-permission classifier.
# Host authentication and unannotation supply the two explicit flags.
@unsafe
def nh_definitions(+book: List<&2, KDef>, names: List<&2, String>, +hot: List<&2, String>) -> List<&2, String>:
  match names:
    case Nil{}: hot
    case Con{+name, +rest}:
      +d = lookup(book, name)
      nt_choose(List<&2, String>, nb_contains(hot, "*"), u => hot, u => nh_definitions(book, rest, nt_choose(List<&2, String>, nc_native_def(d) || nc_foreign(d), v => hot, v => nh_terms(book, nc_compact_definition(book, d, 0), [dv(d)], hot))))

# Erased Mat.qty carries per-use scalar-field facts, not a source quantity.
# Specialize before erasure, so List<U32> and List<String> stay distinct.
# Every live field keeps its index; unknown/dependent fields remain opaque.

# Module: src/back/native/sharing.bend:211
@unsafe
def nc_definition(+book: List<&2, KDef>, +d: KDef, +n: U32) -> KTerm:
  +fact = ns_body(book, dn(d))
  nt_choose(KTerm, (p88_string_eq(dk(fact), "NativeStaticBody") || p88_string_eq(dk(fact), "NativeErasedBody")), u => dv(fact), u => nc_definition_plain(book, d, n))

# Prepared static bodies already passed literal compaction in this request.

# Module: src/back/native/book.bend:76
@unsafe
def nc_compact_definition(+book: List<&2, KDef>, +d: KDef, +n: U32) -> KTerm:
  +fact = ns_body(book, dn(d))
  nt_choose(KTerm, p88_string_eq(dk(fact), "NativeStaticBody"), u => dv(fact), u => nc_compact(nc_definition(book, d, n)))

# Module: src/back/native/book.bend:81
@unsafe
def nc_definition_plain(+book: List<&2, KDef>, +d: KDef, +n: U32) -> KTerm:
  +prim = nc_primitive_name(dn(d))
  nt_choose(KTerm, nc_native_def(d),
    u => nc_primitive_body(prim),
    u => nt_choose(KTerm, nc_foreign(d),
      u => nc_foreign_tel(book, dt(d), dn(d), Nil{}, n),
      u => nc_erase(book, dv(d))))

# Module: src/back/native/book.bend:153
@unsafe
def nc_is_io(+book: List<&2, KDef>, +ty: KTerm) -> Bool:
  +io = lookup(book, "IO")
  +shadow = book_put(book, KDef{dn(io), dk(io), da(io), dx(io), dt(io), {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, dc(io), db(io), du(io)})
  +head = wnf(shadow, ty)
  p88_string_eq(dk(io), "Def") && db(io) && p98_tag_eq(head, "App") && p98_tag_eq(kid(head, 0), "Ref") && p88_string_eq(nm(kid(head, 0)), "IO")

# Include index/constructor children: raw cached books may carry definitions there.
# A foreign program retains its previous ordinary-constructor representation.

# Module: src/back/native/book.bend:217
@unsafe
def nc_bangs_names(+book: List<&2, KDef>, names: List<&2, String>) -> List<&2, String>:
  match names:
    case Nil{}: Nil{}
    case Con{name, rest}: List.append(&2, String, nc_bangs_term(nc_definition(book, lookup(book, name), 0)), nc_bangs_names(book, rest))

# Module: src/back/native/book.bend:270
@unsafe
def nc_annotation_stops(book: List<&2, KDef>) -> List<&2, String>:
  match book:
    case Nil{}: Nil{}
    case Con{+d, +rest}:
      nt_choose(List<&2, String>, nc_native_def(d),
        u => Con{dn(d), nc_annotation_stops(rest)},
        u => nc_annotation_stops(rest))

# Module: src/back/native/book.bend:325
@unsafe
def nc_source_body(+book: List<&2, KDef>, +d: KDef, +n: U32) -> KTerm:
  +fact = ns_body(book, dn(d))
  +original = nt_choose(KDef, p88_string_eq(dk(fact), "NativeStaticBody"), u => index_first(dc(fact)), u => fact)
  nt_choose(KTerm, p88_string_eq(dk(original), "NativeErasedBody") && p88_string_eq(dn(original), dn(d)), u => dv(original), u => nc_definition_plain(book, d, n))

# Module: src/back/native/static.bend:26
@unsafe
def nr_walk(+book: List<&2,KDef>, todo: List<&2,String>, +done: List<&2,String>, +facts: List<&2,KDef>) -> NR_Closure:
  p143nr_begin(book,todo,done,facts)

# Module: src/back/native/request.bend:36
@unsafe
def nr_unshared(+book: List<&2, KDef>, names: List<&2, String>) -> Bool:
  match names:
    case Nil{}: True{}
    case Con{name, rest}:
      +d = lookup(book, name)
      nt_choose(Bool, nt_choose(Bool, nc_native_def(d) || nc_foreign(d), u => True{}, u => ns_unshared_terms(book, nc_definition(book, d, 0), [dv(d)])),
        u => nr_unshared(book, rest), u => False{})

# Owned annotation creates a plain merged book and a fresh mirror index. Its
# exact bound also bounds that index; erased/generated facts are not source.
# Raw nr_prepare retains the independent source-bound scan at compile time.

# Module: src/back/native/request.bend:63
@unsafe
def w7_br_742(w7_c: Bool, +t: KTerm) -> String:
  match w7_c:
    case True{}:
      no_immediate_ctor(nc_constructor_value(nm(t), Nil{}, 0))
    case False{}:
      "NATIVE_UNBOUND_VARIABLE"

@unsafe
def w7_br_743(w7_c: Bool, +t: KTerm) -> String:
  match w7_c:
    case True{}:
      nm(t) ++ "ull"
    case False{}:
      w7_br_742((p98_tag_eq(t, "Ctr") || p98_tag_eq(t, "NCtr")) && List.is_empty(&2, KTerm, ks(t)) && Bool.not(nb_contains(["Succ", "Chr", "U32", "F32", "ALeaf", "ANode"], nm(t))), t)

@unsafe
def w7_br_744(w7_c: Bool, +t: KTerm, +env: List<&2, NC_Binding>) -> String:
  match w7_c:
    case True{}:
      nc_word(ix(t), env)
    case False{}:
      w7_br_743(p98_tag_eq(t, "NWord"), t)

@unsafe
def nol_root_pair(+book: List<&2, KDef>, +ty: KTerm, +nil: KDef, +cons: KDef) -> List<&2, NO_Spec>:
  +empty = nol_ctor_fields(book, ty, nil)
  +fields = nol_ctor_fields(book, ty, cons)
  nt_choose(List<&2, NO_Spec>, U32.is_eq(da(nil), 0) && U32.is_ge(da(cons), 2) && p98_tag_eq(empty, "NO_Types") && p98_tag_eq(fields, "NO_Types") && nol_root_fields(book, nm(ty), ks(fields), 0),
    u => [nol_spec(book, nm(ty), nil, "Nullary", Nil{}), nol_spec(book, nm(ty), cons, "Boxed", ks(fields))], u => Nil{})

# Module: src/back/native/observer-layout.bend:99
@unsafe
def nol_root_ctors(+book: List<&2, KDef>, +ty: KTerm, ctors: List<&2, KDef>) -> List<&2, NO_Spec>:
  match ctors:
    case Con{+a, Con{+b, Nil{}}}:
      nt_choose(List<&2, NO_Spec>, U32.is_eq(da(a), 0), u => nol_root_pair(book, ty, a, b), u => nol_root_pair(book, ty, b, a))
    case _: Nil{}

# Module: src/back/native/observer-layout.bend:106
@unsafe
def nol_root_specs(+book: List<&2, KDef>, +ty: KTerm) -> List<&2, NO_Spec>:
  +d = lookup(book, nm(ty))
  nt_choose(List<&2, NO_Spec>, nol_plain(ty) && nol_owner(book, ty) && (Bool.not(db(d)) || p88_string_eq(dn(d), "String")),
    u => nol_root_ctors(book, ty, dc(d)), u => Nil{})

# Scalar readers are available to inlined helpers even if no entry parameter
# has the corresponding type. Word/Array and boxed primitive destructuring are
# intentionally absent. A native Nat remains conditional on runtime admission.

# Module: src/back/native/observer-layout.bend:115
@unsafe
def nol_scalar_ctors(+book: List<&2, KDef>, +ty: KTerm, ctors: List<&2, KDef>) -> List<&2, NO_Spec>:
  match ctors:
    case Nil{}: Nil{}
    case Con{+ctr, +rest}:
      +fields = nol_ctor_fields(book, ty, ctr)
      +storage = nt_choose(String, U32.is_eq(da(ctr), 0), u => "Nullary", u => nt_choose(String, p88_string_eq(nm(ty), "Nat") && p88_string_eq(dn(ctr), "Succ"), v => "Succ", v => nt_choose(String, p88_string_eq(nm(ty), "Char") && p88_string_eq(dn(ctr), "Chr"), w => "Char", w => "")))
      +tail = nol_scalar_ctors(book, ty, rest)
      nt_choose(List<&2, NO_Spec>, p98_tag_eq(fields, "NO_Types") && Bool.not(p88_string_eq(storage, "")), u => Con{nol_spec(book, nm(ty), ctr, storage, ks(fields)), tail}, u => tail)

# Module: src/back/native/observer-layout.bend:125
@unsafe
def nol_scalar_specs(+book: List<&2, KDef>, defs: List<&2, KDef>) -> List<&2, NO_Spec>:
  match defs:
    case Nil{}: Nil{}
    case Con{+d, +rest}:
      +ty = kt("ADT", dn(d), 0, 0, Nil{})
      nt_choose(List<&2, NO_Spec>, nt_choose(Bool, p88_string_eq(dk(d), "ADT"), v => nol_scalar(book, ty), v => False{}),
        u => List.append(&2, NO_Spec, nol_scalar_ctors(book, ty, dc(d)), nol_scalar_specs(book, rest)), u => nol_scalar_specs(book, rest))

# Module: src/back/native/observer-layout.bend:134
@unsafe
def nol_wrap(+book: List<&2, KDef>, +sourceType: KTerm, +params: List<&2, KTerm>, +roots: List<&2, U32>, +shells: U32, +observation: String, +result: U32) -> NOL_Wrap:
  +ty = nq_layout_type(book, sourceType)
  nt_choose(NOL_Wrap, List.is_empty(&2, NO_Spec, nol_root_specs(book, ty)),
    u => nt_choose(NOL_Wrap, nol_scalar(book, ty),
      v => nt_choose(NOL_Wrap, p88_string_eq(observation, ""), w => NOL_Wrap{var(nm(ty), result), roots, shells, nm(ty), ""}, w => nol_wrap_fail("multiple observations", roots, shells, observation)),
      v => nol_wrap_shell(book, ty, params, roots, shells, observation, result, dc(lookup(book, nm(ty))))),
    u => nol_wrap_root(ty, params, roots, shells, observation))

# Module: src/back/native/observer-layout.bend:183
@unsafe
def nol_wrap_shell(+book: List<&2, KDef>, +ty: KTerm, +params: List<&2, KTerm>, +roots: List<&2, U32>, +shells: U32, +observation: String, +result: U32, ctors: List<&2, KDef>) -> NOL_Wrap:
  match ctors:
    case Con{+ctr, Nil{}}:
      +owner = lookup(book, nm(ty))
      +fields = nol_ctor_fields(book, ty, ctr)
      nt_choose(NOL_Wrap, U32.is_lt(shells, 2) && nol_owner(book, ty) && U32.is_ge(da(ctr), 1) && p98_tag_eq(fields, "NO_Types") && (Bool.not(db(owner)) || (p88_string_eq(dn(owner), "Sigma") && p88_string_eq(dn(ctr), "Tuple") && U32.is_eq(da(ctr), 2))),
        u => nol_wrap_constructor(nc_ctor_identity(book, dn(ctr)), nol_wrap_fields(book, ks(fields), params, roots, U32.inc(shells), observation, result)),
        u => nol_wrap_fail("unsupported or excess result shell", roots, shells, observation))
    case _: nol_wrap_fail("result is not a fixed constructor", roots, shells, observation)

# Module: src/back/native/observer-layout.bend:202
@unsafe
def nol_wrap_fields(+book: List<&2, KDef>, fields: List<&2, KTerm>, +params: List<&2, KTerm>, +roots: List<&2, U32>, +shells: U32, +observation: String, +result: U32) -> NOL_Wrap:
  match fields:
    case Nil{}: NOL_Wrap{kt("NO_WrapFields", "", 0, 0, Nil{}), roots, shells, observation, ""}
    case Con{+head, +rest}: nol_wrap_tail(book, rest, params, result, nol_wrap(book, head, params, roots, shells, observation, result))

# Module: src/back/native/observer-layout.bend:208
@unsafe
def nol_wrap_tail(+book: List<&2, KDef>, +rest: List<&2, KTerm>, +params: List<&2, KTerm>, +result: U32, +head: NOL_Wrap) -> NOL_Wrap:
  match head:
    case NOL_Wrap{+term, +roots, +shells, +observation, +error}:
      nt_choose(NOL_Wrap, p88_string_eq(error, ""), u => nol_wrap_cons(term, nol_wrap_fields(book, rest, params, roots, shells, observation, result)), u => head)

# Module: src/back/native/observer-layout.bend:214
@unsafe
def nol_finish(+book: List<&2, KDef>, +params: List<&2, KTerm>, +roots: List<&2, U32>, +specs: List<&2, NO_Spec>, +fresh: U32, result: NOL_Wrap) -> NO_Schema:
  match result:
    case NOL_Wrap{+wrapper, +remaining, +shells, +observation, +error}:
      +reason = nt_choose(String, p88_string_eq(error, ""), u => nt_choose(String, ((List.is_empty(&2, U32, remaining) && U32.is_gt(shells, 0)) || (p98_tag_eq(wrapper, "Var") && U32.is_eq(ix(wrapper), nc_id(fresh)) && U32.is_eq(shells, 0))) && Bool.not(p88_string_eq(observation, "")), v => "", v => "result must contain every root once and one scalar"), u => error)
      +ready = nt_choose(List<&2, NO_Spec>, p88_string_eq(reason, ""), u => List.append(&2, NO_Spec, specs, nol_scalar_specs(book, book)), u => Nil{})
      NO_Schema{params, roots, wrapper, nc_id(fresh), observation, ready, U32.inc(fresh), reason}

# Module: src/back/native/observer-layout.bend:232
@unsafe
def noa_scalars(+ctx: NO_Context, values: List<&2, KTerm>) -> List<&2, KTerm>:
  match values:
    case Nil{}: Nil{}
    case Con{+h, +rest}: Con{noa_scalar(ctx, h), noa_scalars(ctx, rest)}

# Module: src/back/native/observer-analysis.bend:247
@unsafe
def noa_finish_fields(+ctx: NO_Context, values: List<&2, KTerm>, templates: List<&2, KTerm>, +facts: List<&2, KTerm>) -> KTerm:
  match values, templates:
    case Nil{}, Nil{}: kt("OResult", "", 0, 0, Nil{})
    case Con{+v, +vs}, Con{+t, +ts}: noa_finish_merge(noa_finish_value(ctx, v, t, facts), noa_finish_fields(ctx, vs, ts, facts))
    case _, _: {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}

# Module: src/back/native/observer-analysis.bend:384
@unsafe
def w7_br_775(w7_c: Bool, +ctx: NO_Context, +value: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      kt("OResult", "", 0, 0, [noa_scalar(ctx, value)])
    case False{}:
      {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}

@unsafe
def w7_br_777(w7_c: Bool, +ctx: NO_Context, +value: KTerm, +template: KTerm, +facts: List<&2, KTerm>) -> KTerm:
  match w7_c:
    case True{}:
      w7_br_775(p88_string_eq(noa_value_type(ctx, value), no_schema_observation(noa_schema(ctx))) && Bool.not(p98_tag_eq(noa_scalar(ctx, value), "Absent")), ctx, value)
    case False{}:
      w7_br_776(noa_equal(value, noa_param_origin(ix(template), no_schema_params(noa_schema(ctx)), 0), facts))

@unsafe
def w7_br_778(w7_c: Bool, +ctx: NO_Context, +value: KTerm, +template: KTerm, +facts: List<&2, KTerm>) -> KTerm:
  match w7_c:
    case True{}:
      noa_finish_fields(ctx, ks(value), ks(template), facts)
    case False{}:
      {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}

@unsafe
def w7_br_779(w7_c: Bool, +ctx: NO_Context, +value: KTerm, +template: KTerm, +facts: List<&2, KTerm>) -> KTerm:
  match w7_c:
    case True{}:
      w7_br_777(U32.is_eq(ix(template), no_schema_result(noa_schema(ctx))), ctx, value, template, facts)
    case False{}:
      w7_br_778(p98_tag_eq(template, "Ctr") && p98_tag_eq(value, "OC") && p88_string_eq(nm(template), nm(value)), ctx, value, template, facts)

@unsafe
def noa_finish_value(ctx, value, template, facts):
  w7_br_779(p98_tag_eq(template, "Var"), ctx, value, template, facts)

# Module: src/back/native/observer-analysis.bend:396
@unsafe
def noa_finish(+ctx: NO_Context, +input: NO_Input) -> NO_Analysis:
  +result = noa_finish_value(ctx, noa_iv(input), no_schema_wrapper(noa_schema(ctx)), noa_if(input))
  nt_choose(NO_Analysis, p98_tag_eq(result, "OResult") && U32.is_eq(terms_len(ks(result)), 1), u => NO_Analysis{kt("NO_Return", "", 0, 0, ks(result)), noa_in(input), noa_iu(input), ""}, u => noa_fail("observer: returned root or observation unproved", noa_in(input), noa_iu(input)))

# Module: src/back/native/observer-analysis.bend:401
@unsafe
def noa_loop_valid(+ctx: NO_Context, params: List<&2, KTerm>, args: List<&2, KTerm>, +i: U32, +strict: Bool) -> Bool:
  match params, args:
    case Nil{}, Nil{}: strict
    case Con{+p, +ps}, Con{+a, +rest}:
      nt_choose(Bool, noa_root_param(ctx, p),
        u => p98_tag_eq(a, "OA") && p88_string_eq(nm(a), nm(p)) && noa_below(noa_origin(a), kt("OArg", "", i, 0, Nil{})) && noa_loop_valid(ctx, ps, rest, U32.inc(i), strict || p98_tag_eq(noa_origin(a), "OField")),
        u => p88_string_eq(noa_value_type(ctx, a), nm(p)) && Bool.not(p98_tag_eq(noa_scalar(ctx, a), "Absent")) && noa_loop_valid(ctx, ps, rest, U32.inc(i), strict))
    case _, _: False{}

# Module: src/back/native/observer-analysis.bend:419
@unsafe
def noa_loop_words(+ctx: NO_Context, params: List<&2, KTerm>, args: List<&2, KTerm>) -> List<&2, KTerm>:
  match params, args:
    case Con{+p, +ps}, Con{+a, +rest}: Con{nt_choose(KTerm, noa_root_param(ctx, p), u => kid(a, 1), u => noa_scalar(ctx, a)), noa_loop_words(ctx, ps, rest)}
    case _, _: Nil{}

# Module: src/back/native/observer-analysis.bend:425
@unsafe
def noa_recur_done(+ctx: NO_Context, +args: List<&2, KTerm>, +marker: KTerm, rest: NO_Analysis) -> NO_Analysis:
  match rest:
    case NO_Analysis{+body, +n, +fuel, +error}:
      nt_choose(NO_Analysis, p88_string_eq(error, "") && p98_tag_eq(body, "NO_Return") && U32.is_eq(terms_len(ks(body)), 1) && norm_exact(kid(body, 0), marker),
        u => NO_Analysis{kt("NO_Loop", "", 0, 0, noa_loop_words(ctx, no_schema_params(noa_schema(ctx)), args)), n, fuel, ""},
        u => noa_fail(nt_choose(String, p88_string_eq(error, ""), v => "observer: non-tail or discarded recursive result", v => error), n, fuel))

# Public query entry: permission must be supplied by the checked host path.
# It is deliberately not read from any user-controlled book definition.

# Module: src/back/native/observer-analysis.bend:467
@unsafe
def no_candidate_names(+book: List<&2, KDef>, names: List<&2, String>, +bangs: List<&2, String>) -> List<&2, String>:
  match names:
    case Nil{}: Nil{}
    case Con{+name, +rest}:
      +d = lookup(book, name)
      nt_choose(List<&2, String>, p88_string_eq(dk(d), "Def") && Bool.not(nc_native_def(d) || nc_foreign(d) || nb_contains(bangs, name)),
        u => Con{name, no_candidate_names(book, rest, bangs)}, u => no_candidate_names(book, rest, bangs))

# Module: src/driver/report.bend:64
@unsafe
def driver_report_data(+book: List<&2, KDef>) -> DR_Report:
  +names = dr_cached_names(book_cached(book_final_fast(book, Nil{}), 0), dr_own_names(book, Nil{}), missing())
  DR_Report{dr_verdict(names), names}

# A completed safe traversal proves every visited name safe in this immutable
# book. A traversal stopped by unsafe code proves only its original root unsafe:
# never mark the other visited branches unsafe or safe from that partial result.

# Module: src/driver/report.bend:119
@unsafe
def driver_todos(
  +book: List<&2,KDef>,
) -> U32:
  driver_count_todos(driver_final(book, Nil{}))

# Module: src/driver/api.bend:39
@unsafe
def driver_program_checked(+original: List<&2,KDef>, +origins: List<&2,DOrigin>, +checked: DChecking) -> DResult:
  match checked:
    case DChecking{result, diagnostic}:
      kc(DResult, good(result),
        u => driver_program_complete(sp_assembled(rw(result)), origins, check_open_message(driver_todos(original))),
        u => dg_finish(ce(result), kw_book(rw(result)), diagnostic, origins))

# Private disjoint-prefix completion. The original prefix TODO count was
# produced with the immutable checked world. Suffix counting stays after a
# successful check, preserving the first checker error and diagnostic world.

# Module: src/driver/api.bend:136
@unsafe
def driver_program_checked_prefix(+suffix: List<&2,KDef>, +todos: U32, +origins: List<&2,DOrigin>, +checked: DChecking) -> DResult:
  match checked:
    case DChecking{result, diagnostic}:
      kc(DResult, good(result),
        u => driver_program_complete(sp_assembled(rw(result)), origins, check_open_message(U32.add(todos, driver_todos(suffix)))),
        u => dg_finish(ce(result), kw_book(rw(result)), diagnostic, origins))

# Module: src/driver/api.bend:144
@unsafe
def p88_decode_admitted(+text: String, +expected_stamp: String, +begin: U32, +end: U32) -> P88Decoded:
  p88_header_stamp(p88_text(P88Cursor{text,p130m_initial(text,expected_stamp)}),expected_stamp,begin,end)

@unsafe
def p88_header_stamp(read: P88TextRead, expected: String, begin: U32, end: U32) -> P88Decoded:
  match read:
    case P88TextRead{P88Cursor{text,+mode},stamp}:
      p88_header_gate(P88Cursor{text,mode},begin,end,p130m_valid(mode) && agy_str_eq(stamp,expected))

@unsafe
def p205_verify(+book: List<&2,KDef>, state: Maybe<&2,KDef>, +role: String, eqn: P205Equation) -> Maybe<&2,KDef>:
  match state eqn:
    case Some{+roles} P205Equation{args,pattern}:
      +d = lookup(book,dk(p111v_get(roles,role)))
      kc(Maybe<&2,KDef>,agy_str_eq(dk(d),"Def") && U32.is_eq(dx(d),0) && (Bool.not(db(d)) || agy_str_eq(dn(d),"String.append")) && p205_signature(dt(d),args),
        u => p205_match(pattern,j_strip(dv(d)),[],roles),u => None{})
    case _ _: None{}

@unsafe
def p205_law(+book: List<&2,KDef>, +rep: String, +join: String, +split: String) -> Bool:
  +r0 = p111v_put(p111v_put(p111v_put(missing(),"repeat",rep,0,0),"join",join,0,0),"split",split,0,0)
  +r1 = p205_verify(book,Some{r0},"repeat",p205_repeat_equation())
  +r2 = p205_verify(book,r1,"join",p205_join_equation())
  +r3 = p205_verify(book,r2,"split",p205_split_equation())
  +r4 = p205_verify(book,r3,"join_rest",p205_join_rest_equation())
  +r5 = p205_verify(book,r4,"pick",p205_pick_equation())
  +r6 = p205_verify(book,r5,"push",p205_push_equation())
  p205_ok(p205_verify(book,r6,"append",p205_append_equation())) && j_primitive_definition(book,lookup(book,"U32.is_eq"),2)

# The only reordered arguments are already-evaluated variables and literals.
# If a temporary is eliminated, neither delimiter may depend on that binding.
@unsafe
def p205z_advance(+context: List<&2,KDef>, +change: KDef) -> List<&2,KDef>:
  kc(List<&2,KDef>,agy_str_eq(dk(change),"Absent"),u => context,
    u => kw_bound_book(context,norm_max_defs([change],norm_book_bound(context))))

@unsafe
def p205_attempt(+book: List<&2,KDef>, +out: KTerm, +bound: KTerm) -> KTerm:
  +join = j_call_spine(out,[])
  kc(KTerm,U32.is_eq(terms_len(ks(join)),2),u => p205_inner(book,join,j_call_spine(kid(join,1),[]),bound),u => atom("Absent"))

@unsafe
def p205_inner(+book: List<&2,KDef>, +join: KTerm, +split: KTerm, +bound: KTerm) -> KTerm:
  +input = j_strip(kid(split,1))
  +target = kc(KTerm,p98_tag_eq(bound,"Bind"),u => kid(bound,0),u => input)
  +rep = j_call_spine(target,[])
  kc(KTerm,U32.is_eq(terms_len(ks(split)),2) && U32.is_eq(terms_len(ks(rep)),2) &&
    (Bool.not(p98_tag_eq(bound,"Bind")) || (p98_tag_eq(input,"Var") && U32.is_eq(ix(input),ix(bound)))) &&
    p205_atom(j_strip(kid(join,0)),bound) && p205_atom(j_strip(kid(split,0)),bound),
    u => kc(KTerm,p205_law(book,nm(rep),nm(join),nm(split)),
      v => p205z_guard(book,rep,join,split),
      v => atom("Absent")),
    u => atom("Absent"))

@unsafe
def w7_br_817(w7_c: Bool, +book: List<&2,KDef>, +input: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      p205u_bounded(book,p205u_clean(input),norm_book_bound(book))
    case False{}:
      atom("Absent")

@unsafe
def p205u_attempt(+book: List<&2,KDef>, +input: KTerm) -> KTerm:
  w7_br_817(p205u_room([input],2048) && p205u_exists(book,[input],2048), book, input)
@unsafe
def w7_br_818(w7_c: Bool, +book: List<&2,KDef>, +clean: KTerm, +bound: U32) -> KTerm:
  match w7_c:
    case True{}:
      p205u_finished(p205u_eval(book,clean,U32.inc(bound),0,256))
    case False{}:
      atom("Absent")

@unsafe
def p205u_bounded(+book: List<&2,KDef>, +clean: KTerm, +bound: U32) -> KTerm:
  w7_br_818(db(lookup(book,"String")) && db(lookup(book,"Char")) && db(lookup(book,"U32")) && U32.is_lt(bound,4294900000), book, clean, bound)

@unsafe
def ctfe_run_u32_bin(+op: String, +a: U32, +b: U32) -> CtfeVal:
  w7_br_844(agy_str_eq(op, "u32_add"), op, a, b)

@unsafe
def ctfe_run_prim2_vals(+op: String, +a: CtfeVal, +b: CtfeVal) -> CtfeVal:
  match a b:
    case CVU32{x} CVU32{y}: ctfe_run_u32_bin(op, x, y)
    case CVF32{x} CVF32{y}: ctfe_run_f32_bin(op, x, y)
    case _ _: ctfe_run_nat_opt(op, ctfe_as_nat(a, 0), ctfe_as_nat(b, 0))

@unsafe
def w7_br_868(w7_c: Bool, +op: String, +a: CtfeVal, +b: CtfeVal) -> CtfeVal:
  match w7_c:
    case True{}:
      ctfe_run_shift(op, a, ctfe_as_nat(b, 0))
    case False{}:
      ctfe_run_prim2_vals(op, a, b)

@unsafe
def ctfe_run_prim2(+op: String, +a: CtfeVal, +b: CtfeVal) -> CtfeVal:
  w7_br_868(agy_str_eq(op, "u32_shln") || agy_str_eq(op, "u32_shrn"), op, a, b)

@unsafe
def agy_abs_commit_ok(+ctx_chk: List<&2,KDef>, +chk: KDef, +rest: List<&2,KDef>) -> AgyAbsResult:
  AgyAbsResult{p205z_advance(ctx_chk,chk),Con{chk,rest},True{}}

@unsafe
def w2d_after_fused_res(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +next: U32, +chk: KDef, +hname: String, +unb: W2State) -> W2State:
  match unb:
    case W2State{ctx2,added2,next2,_,True{}}: W2State{ctx2,added2,next2,ref(hname),True{}}
    case _: W2State{agy_bf_add_def(ctx,chk),Con{chk,added},next,ref(hname),True{}}

@unsafe
def p88_cache_prepare(+path: String, +text: String, carrier: String, stamp: String) -> P86Preparation:
  +end = U32.add(p86_width(text,0),2)
  p88_cache_result(f_source_located(FSource{"Base",path,text},1,end),p88_decode_admitted(carrier,stamp,1,end))

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:767
@unsafe
def nbc_definition(+book: List<&2,KDef>, +d: KDef, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +n: U32, +count: U32) -> KTerm:
  nt_choose(KTerm,p88_string_eq(dk(d),"Def") && Bool.not(nc_native_def(d) || nc_foreign(d)),
    u => p152c_source(book,dn(d),nc_source_body(book,d,n),args,env,n,count),u => atom("Absent"))

# Private host-only tail recursion modulo a final boxed constructor field.
# The ordinary scheduler/device path and public one-Term result ABI remain.
law p111_show_field:
  for +book: List<&2, KDef>
  for +tel: KTerm
  for +left: U32
  for +i: U32
  for +d: P111ShowDesc
  P111ShowDesc

law p111_show_arm:
  for +book: List<&2, KDef>
  for +c: KDef
  for +rest: List<&2, KDef>
  for +args: List<&2, KTerm>
  for +d: P111ShowDesc
  P111ShowDesc

@unsafe
def p111_show_ref(+book: List<&2, KDef>, +ty: KTerm, +types: List<&2, KTerm>) -> P111ShowDesc:
  +id = nc_show_find(book, ty, types, 0)
  nt_choose(P111ShowDesc, U32.is_eq(id, 4294967295),
    u => P111ShowDesc{[P111ShowRef{terms_len(types)}], List.append(&2, KTerm, types, [ty]), ""},
    u => P111ShowDesc{[P111ShowRef{id}], types, ""})

@unsafe
def p111_show_fields(+book: List<&2, KDef>, +tel: KTerm, +left: U32, +i: U32, +types: List<&2, KTerm>) -> P111ShowDesc:
  nt_choose(P111ShowDesc, U32.is_eq(left, 0), u => P111ShowDesc{Nil{}, types, ""}, u =>
    nt_choose(P111ShowDesc, U32.is_eq(qt(wnf(book, tel)), 0), u => P111ShowDesc{Nil{}, types, "native readback cannot print an erased field"}, u =>
      p111_show_field(book, wnf(book, tel), left, i, p111_show_ref(book, kid(wnf(book, tel), 0), types))))

@unsafe
def p111_show_field(book, tel, left, i, d):
  p111_show_join(P111ShowDesc{Con{P111ShowWord{i}, p111_show_cells(d)}, p111_show_types(d), p111_show_error(d)},
    p111_show_fields(book, kid(tel, 1), U32.sub(left, 1), U32.inc(i), p111_show_types(d)))

@unsafe
def p111_show_arms(+book: List<&2, KDef>, +cs: List<&2, KDef>, +args: List<&2, KTerm>, +types: List<&2, KTerm>) -> P111ShowDesc:
  match cs:
    case Nil{}: P111ShowDesc{Nil{}, types, ""}
    case Con{+c, rest}: p111_show_arm(book, c, rest, args, p111_show_fields(book, nc_tele_fill(book, dt(c), args), da(c), 0, types))

@unsafe
def p111_show_arm(book, c, rest, args, d):
  p111_show_join(P111ShowDesc{Con{P111ShowCtor{nc_ctor_identity(book, dn(c))},
    Con{P111ShowCtor{nc_ctor_identity(book, dn(c))}, Con{P111ShowWord{da(c)}, p111_show_cells(d)}}},
    p111_show_types(d), p111_show_error(d)}, p111_show_arms(book, rest, args, p111_show_types(d)))

@unsafe
def p111_show_data(+book: List<&2, KDef>, +ty: KTerm, +types: List<&2, KTerm>) -> P111ShowDesc:
  +cs = dc(lookup(book, nm(ty)))
  +d = p111_show_arms(book, cs, ks(ty), types)
  P111ShowDesc{Con{P111ShowWord{7}, Con{P111ShowWord{1}, Con{P111ShowWord{nt_count(KDef, cs)}, p111_show_cells(d)}}}, p111_show_types(d), p111_show_error(d)}

@unsafe
def p111_value(+t: KTerm, +env: List<&2, NC_Binding>) -> P111ValueCode:
  nt_choose(P111ValueCode, agy_str_eq(tg(t), "Var"), u => P111ValueCode{Nil{}, N111Local{nc_word(ix(t), env)}, ""}, u =>
  nt_choose(P111ValueCode, agy_str_eq(tg(t), "NWord"), u => p111_uint(U32.read(nm(t))), u =>
  nt_choose(P111ValueCode, agy_str_eq(tg(t), "NCtr"), u => p111_constructor(nm(t), p111_values(ks(t), env)), u =>
  nt_choose(P111ValueCode, agy_str_eq(tg(t), "NOp"), u => p111_intrinsic(nm(t), p111_values(ks(t), env)), u =>
    P111ValueCode{Nil{}, N111Const{0, 0}, "not a native evaluated value"}))))

@unsafe
def p111_nat_sum_finish(+values: List<&2, N111Value>, +n: U32, offset: Maybe<&2, U32>) -> P111Code:
  match offset:
    case None{}: p111_fail("invalid native Nat offset", n)
    case Some{+value}:
      +first = p111_constructor("Succ", values)
      p111_nat_sum_join(first, value, n)

@unsafe
def p111_nat_sum_join(first: P111ValueCode, +offset: U32, +n: U32) -> P111Code:
  match first:
    case P111ValueCode{+body, +word, +error}:
      p111_prepend(body, p111_value_return(p111_intrinsic("nat_add", [word, N111Const{offset, 0}]), n))

@unsafe
def p111_is_foreign(+definition: KDef) -> Bool:
  nt_choose(Bool, nc_native_def(definition), u => False{}, u => nc_foreign(definition))

@unsafe
def p111_effects(+source: List<&2, KDef>, names: List<&2, String>) -> List<&2, String>:
  match names:
    case Nil{}: Nil{}
    case Con{+name, +rest}:
      nt_choose(List<&2, String>, p111_is_foreign(lookup(source, name)), u => Con{name, p111_effects(source, rest)}, u => p111_effects(source, rest))

@unsafe
def p111_runtime_admission(request: NR_Request) -> String:
  match request:
    case NR_Request{source, book, names, paths, scope, bound}:
      p111_runtime_effects(p111_effects(source, names), p111_runtime_names())


# Phase111 module: selfhost/tools/performance/phase111/segment/verify.bend
# Structural/type boundary for the sequential runtime ABI. Persistent exact-name
# tries avoid scanning all functions/constructors for every reference. This is
# not an ownership proof or a proof that foreign/runtime implementations are safe.
@unsafe
def p111v_decl(+name: String, +width: U32, +capacity: U32, +alloca: Bool, +scan: P111VScan) -> P111VScan:
  match scan:
    case P111VScan{+index,+error,+count}:
      w5c3_decl_err(Bool.not(String.is_empty(error)), scan, index, name, width, capacity, alloca, count)

@unsafe
def p111v_schema_stmt(+stmt: N111Stmt, +scan: P111VScan) -> P111VScan:
  match stmt:
    case N111Set{name,typ,value}: p111v_decl(name,p111v_type(typ),0,False{},scan)
    case N111Bin{name,typ,op,left,right}: p111v_decl(name,w5c3_u32_if(p111v_comparison(op),1,p111v_type(typ)),0,False{},scan)
    case N111Call{name,typ,symbol,args}: p111v_decl(name,p111v_type(typ),0,False{},scan)
    case N111Load{name,typ,base,offset}: p111v_decl(name,p111v_type(typ),0,False{},scan)
    case N111Offset{name,base,bytes}: p111v_decl(name,3,0,False{},scan)
    case N111Alloca{name,bytes,align}: p111v_decl(name,3,bytes,True{},scan)
    case N111If{condition,yes,no}: p111v_schema(no,p111v_schema(yes,scan))
    case _: scan

@unsafe
def w5c3_schema_step(ok: Bool, +head: N111Stmt, rest: List<&2,N111Stmt>, +scan: P111VScan, +index: KDef, +error: String, +count: U32) -> P111VScan:
  match ok:
    case True{}: p111v_schema(rest,p111v_schema_stmt(head,scan))
    case False{}: P111VScan{index,w5c3_str2_if(String.is_empty(error),"too many segment locals",error),count}

@unsafe
def p111v_schema(+body: List<&2,N111Stmt>, +scan: P111VScan) -> P111VScan:
  match body:
    case Nil{}: scan
    case Con{head,rest}:
      match scan:
        case P111VScan{index,+error,+count}:
          w5c3_schema_step(String.is_empty(error) && U32.is_le(count,65535), head, rest, scan, index, error, count)

@unsafe
def w5c3_inter_dispatch(is_abs: Bool, +left: KDef, +right: KDef, +out: KDef) -> KDef:
  match is_abs:
    case True{}: w5c3_inter_tree(left, right)
    case False{}: w5c3_inter_slow(left, right, out)

@unsafe
def p111v_intersection(+left: KDef, +right: KDef, +out: KDef) -> KDef:
  w5c3_inter_dispatch(String.eq(dk(out), "Absent"), left, right, out)

@unsafe
def w5c3_join_terms(yt: Bool, nt: Bool, +yes: P111VFlow, +no: P111VFlow, +yl: KDef, +nl: KDef) -> P111VFlow:
  match yt:
    case True{}:
      match nt:
        case True{}: P111VFlow{yl,True{},""}
        case False{}: no
    case False{}:
      match nt:
        case True{}: yes
        case False{}: P111VFlow{w5c3_inter_tree(yl,nl),False{},""}

@unsafe
def w5c3_join_no_err(has_ne: Bool, +yes: P111VFlow, +no: P111VFlow, +yl: KDef, yt: Bool, +nl: KDef, nt: Bool) -> P111VFlow:
  match has_ne:
    case True{}: no
    case False{}: w5c3_join_terms(yt, nt, yes, no, yl, nl)

@unsafe
def w5c3_join_yes_err(has_ye: Bool, +yes: P111VFlow, +no: P111VFlow, +yl: KDef, yt: Bool) -> P111VFlow:
  match has_ye:
    case True{}: yes
    case False{}:
      match no:
        case P111VFlow{nl,+nt,+ne}: w5c3_join_no_err(Bool.not(String.is_empty(ne)), yes, no, yl, yt, nl, nt)

@unsafe
def p111v_join(+yes: P111VFlow, +no: P111VFlow) -> P111VFlow:
  match yes:
    case P111VFlow{+yl,yt,+ye}: w5c3_join_yes_err(Bool.not(String.is_empty(ye)), yes, no, yl, yt)

# Exact signatures from runtime/runtime.h and runtime/primitives.h. All results
# in this segment API are U64; process entry p111_rt_main is not callable here.
@unsafe
def w5c3_ctr_ret(m: Bool, +symbol: String, +args: List<&2,N111Arg>, +live: KDef, +arity: U32, +incoming: U32, +result: U32) -> Bool:
  match m:
    case True{}: U32.is_eq(p111v_literal(p111v_arg(args,2)),result) && p111v_buffer(args,1,result,live)
    case False{}: w5c3_ctr_rget(String.eq(symbol,"p111_rt_reg_get"), symbol, args, live, arity, incoming)

@unsafe
def w5c3_ctr_counted(m: Bool, +symbol: String, +args: List<&2,N111Arg>, +live: KDef, +ids: N111Ids, +arity: U32, +incoming: U32, +result: U32) -> Bool:
  match m:
    case True{}: p111v_counted_call(symbol,args,live,ids)
    case False{}: w5c3_ctr_ret(String.eq(symbol,"p111_rt_return"), symbol, args, live, arity, incoming, result)

@unsafe
def p111v_contract(+symbol: String, +args: List<&2,N111Arg>, +live: KDef, +ids: N111Ids, +arity: U32, +incoming: U32, +result: U32) -> Bool:
  w5c3_ctr_counted(String.eq(symbol,"p111_rt_ctor") || String.eq(symbol,"p111_rt_take") || String.eq(symbol,"p111_rt_closure") || String.eq(symbol,"p111_rt_frame") || String.eq(symbol,"p111_rt_jump"),
    symbol, args, live, ids, arity, incoming, result)

@unsafe
def p111v_call(+symbol: String, +typ: N111Type, +args: List<&2,N111Arg>, +live: KDef, +ids: N111Ids, +arity: U32, +incoming: U32, +result: U32) -> Bool:
  +sig = p111v_signature(symbol)
  Bool.not(List.is_empty(&2,U32,sig)) && U32.is_eq(p111v_type(typ),2) &&
    p111v_state_argument(args) && p111v_args(args,sig,live,ids) && p111v_contract(symbol,args,live,ids,arity,incoming,result)

@unsafe
def w8_p112s_def_ok(ok: Bool, +book: List<&2,KDef>, +constructors: KDef, +name: String, +definition: KDef, +rest: List<&2,String>, +facts: List<&2,KDef>, +image: P112SImage) -> P112SDefs:
  match ok:
    case True{}: p112s_def_step(book,constructors,rest,name,facts,p112s_term(constructors,nc_compact(nc_definition(book,definition,0)),image))
    case False{}: p112s_defs(book,constructors,rest,facts,image)

@unsafe
def p112s_defs(+book: List<&2,KDef>, +constructors: KDef, names: List<&2,String>, +facts: List<&2,KDef>, +image: P112SImage) -> P112SDefs:
  match names:
    case Nil{}: P112SDefs{facts,image}
    case Con{+name,+rest}:
      +definition = lookup(book,name)
      w8_p112s_def_ok(agy_str_eq(dk(definition),"Def") && Bool.not(nc_native_def(definition) || nc_foreign(definition)),book,constructors,name,definition,rest,facts,image)


@unsafe
def p112s_def_step(+book: List<&2,KDef>, +constructors: KDef, +rest: List<&2,String>, +name: String, +facts: List<&2,KDef>, transformed: P112STerm) -> P112SDefs:
  match transformed:
    case P112STerm{body,image}:
      +prior = ns_body(book,name)
      p112s_defs(book,constructors,rest,Con{KDef{name,"NativeStaticBody",da(prior),dx(prior),{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},body,[prior],False{},False{}},facts},image)


@unsafe
def p112s_attach(+book: List<&2,KDef>, +constructors: List<&2,N_Constructor>, built: P112SDefs) -> P112SPrepared:
  match built:
    case P112SDefs{+facts,P112SImage{+size,+nodes,index,+error}}:
      p112s_attach_book(book,facts,size,nt_reverse(P112SNode,nodes,[]),p112s_ctors(constructors,0,missing()),error)


@unsafe
def p112s_prepare(+book: List<&2,KDef>, +names: List<&2,String>, +constructors: List<&2,N_Constructor>) -> P112SPrepared:
  nt_choose(P112SPrepared,nc_pack_foreign(book),u => P112SPrepared{book,[],""},u =>
    nt_choose(P112SPrepared,agy_str_eq(dk(index_first(book)),"BookCache"),
      u => p112s_attach(book,constructors,p112s_defs(book,p112s_block_effects(ns_ctor_index(constructors,missing()),p111_effects(book,names)),names,[],P112SImage{0,[],missing(),""})),
      u => P112SPrepared{book,[],"static preparation requires a fresh cached request"}))


@unsafe
def p112f_found(+frame: P112FusionFrame, +target: String, +arity: U32, +site: U32, found: Maybe<&2,N111Segment>) -> Maybe<&2,List<&2,N111Stmt>>:
  match frame found:
    case _ None{}: None{}
    case P112FusionFrame{+captures,+name,+dest,+tail} Some{+segment}:
      p112f_cont_found(frame,target,arity,site,p112f_cont(segment,nt_count(N111Value,captures)))


@unsafe
def p112c_target(+frame: P112FusionFrame, +index: P112FusionIndex, +ready: KDef, +site: U32, +buffer: String, +target: String) -> Maybe<&2,List<&2,N111Stmt>>:
  match frame:
    case P112FusionFrame{+captures,+name,+dest,+tail}:
      +arity = da(p111v_get(ready,target))
      nt_choose(Maybe<&2,List<&2,N111Stmt>>,p112w_ready(ready,target) && U32.is_le(arity,64) && p112r_tail(tail,target,arity,0,buffer),
        u => p112f_found(frame,target,arity,site,p112f_index_get(index,name)),u => None{})

@unsafe
def p112c_try_frame(frame: Maybe<&2,P112FusionFrame>, +index: P112FusionIndex, +ready: KDef, +site: U32, +buffer: String) -> Maybe<&2,List<&2,N111Stmt>>:
  match frame:
    case None{}: None{}
    case Some{+value}:
      match value:
        case P112FusionFrame{+captures,+name,+dest,+tail}: p112g_finish(value,index,ready,site,buffer,p112g_split(tail,0,[]))

@unsafe
def p112c_fused(segment: N111Segment, +old: KDef, +symbols: KDef, +rank: U32, +next: P112RegionRegistry, fused: P112FusionBody) -> P112RegionRegistry:
  match segment fused:
    case N111Segment{+name,+arity,+result,+incoming,+flags,+original} P112FusionBody{+body,+count,+site}:
      +transformed: N111Segment = N111Segment{name,arity,result,incoming,flags,body}
      p112c_freeze(transformed,rank,count,next,p112c_plan(transformed,old,symbols,count))

# This helper receives only a qualified typed candidate from p112c_candidates.


@unsafe
def p112g_finish(frame: P112FusionFrame, +index: P112FusionIndex, +ready: KDef, +site: U32, +buffer: String, split: Maybe<&2,P112PureGap>) -> Maybe<&2,List<&2,N111Stmt>>:
  match frame split:
    case _ None{}: None{}
    case P112FusionFrame{+captures,+name,+dest,+original} Some{P112PureGap{+gap,+tail}}:
      +stripped: P112FusionFrame = P112FusionFrame{captures,name,dest,tail}
      p112g_found(gap,nt_count(N111Value,captures),p112c_target(stripped,index,ready,site,buffer,p112r_target(tail,site)))


@unsafe
def p113d_public(+book: List<&2,KDef>, +name: String) -> String:
  nt_choose(String,U32.is_eq(nd_arity(book,name),0),u => nc_ref_name(book,name),u => nd_name(nc_ref_name(book,name)))


@unsafe
def p113d_value(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>) -> P111ValueCode:
  nt_choose(P111ValueCode,agy_str_eq(tg(t),"NStatic"),
    u => p112s_value(book,t),u => p111_value(t,env))


@unsafe
def p113d_ref(+book: List<&2,KDef>, +t: KTerm, +owner: String, +target: P113DTarget, +n: U32) -> P113DCode:
  nt_choose(P113DCode,U32.is_eq(qt(t),3) || Bool.not(U32.is_eq(nd_arity(book,nm(t)),0)),
    u => p113d_fail("direct: escaping or bang reference",n),
    u => p113d_call(p113d_public(book,nm(t)),[],owner,target,n))


@unsafe
def p113d_nat(+values: List<&2,N111Value>, +target: P113DTarget, +n: U32, offset: Maybe<&2,U32>) -> P113DCode:
  match offset:
    case None{}: p113d_fail("direct: invalid Nat offset",n)
    case Some{value}: p113d_nat_join(p111_constructor("Succ",values),value,target,n)


@unsafe
def p113d_nat_join(first: P111ValueCode, offset: U32, target: P113DTarget, n: U32) -> P113DCode:
  match first:
    case P111ValueCode{body,word,error}: p113d_prepend(body,p113d_emitted(target,n,p111_intrinsic("nat_add",[word,N111Const{offset,0}])))


@unsafe
def p113e_seed_params(params: List<&2,NC_Binding>, +scan: P111VScan) -> P111VScan:
  match params scan:
    case Nil{} _: scan
    case Con{NC_Binding{id,+word,kind},rest} P111VScan{+index,error,count}:
      nt_choose(P111VScan,Bool.not(agy_str_eq(dk(p111v_get(index,word)),"Absent")),
        u => P111VScan{index,"duplicate/reserved direct parameter: " ++ word,count},
        u => p113e_seed_params(rest,p111v_decl(word,2,0,False{},scan)))


@unsafe
def p113e_seed(params: List<&2,NC_Binding>) -> P111VScan:
  +state = p111v_put(missing(),"state","parameter",3,2088)
  +scratch = p111v_put(state,"scratch","alloca",3,2048)
  p113e_seed_params(params,P111VScan{scratch,"",2})


@unsafe
def p113e_declare_names(names: List<&2,String>, +scan: P111VScan) -> P111VScan:
  match names:
    case Nil{}: scan
    case Con{head,rest}: p113e_declare_names(rest,p111v_decl(head,2,0,False{},scan))


@unsafe
def p113e_schema(body: List<&2,P113DStmt>, +scan: P111VScan) -> P111VScan:
  match body:
    case Nil{}: scan
    case Con{head,rest}: p113e_schema(rest,p113e_schema_stmt(head,scan))


@unsafe
def p113e_schema_stmt(stmt: P113DStmt, +scan: P111VScan) -> P111VScan:
  match stmt:
    case P113DScalar{scalar}: p111v_schema_stmt(scalar,scan)
    case P113DIf{condition,yes,no}: p113e_schema(no,p113e_schema(yes,scan))
    case P113DCall{destinations,target,args}: p113e_declare_names(destinations,scan)
    case _: scan


@unsafe
def p113_callee_def(+book: List<&2,KDef>, +d: KDef, +arity: U32) -> N_WordKind:
  nt_choose(N_WordKind, agy_str_eq(dk(d),"Def") && Bool.not(nc_native_def(d)) && Bool.not(nc_foreign(d)),
    u => nt_choose(N_WordKind, U32.is_eq(arity,nd_arity(book,dn(d))),
      v => p113_result_tele(book,dt(d),arity,256), v => N_W64{}),
    u => N_W64{})


@unsafe
def p113_callee_kind(+book: List<&2,KDef>, +head: KTerm, +arity: U32) -> N_WordKind:
  nt_choose(N_WordKind, p98_tag_eq(head,"Ref") && Bool.not(U32.is_eq(qt(head),3)),
    u => p113_callee_def(book,lookup(book,nm(head)),arity), u => N_W64{})


@unsafe
def p113p_primitive(+name: String, +values: List<&2,N111Value>, +wanted: KTerm, +n: U32) -> P113PValueCode:
  nt_choose(P113PValueCode,p126dp_selected(name,values,wanted),
    u => p126dp_code(p111_head(values),p111_head(p111_tail(values)),n),
    u => p126dp_original_primitive(name,values,wanted,n))


@unsafe
def p113pl_nat(+values: List<&2,N111Value>, +target: P113PTarget, +n: U32, offset: Maybe<&2,U32>) -> P113DCode:
  match offset:
    case None{}: p113d_fail("product invalid Nat offset",n)
    case Some{value}: p113pl_nat_join(p111_constructor("Succ",values),value,target,n)


@unsafe
def p113pl_nat_join(first: P111ValueCode, offset: U32, target: P113PTarget, n: U32) -> P113DCode:
  match first:
    case P111ValueCode{body,word,error}: p113d_prepend(body,p113pl_boxed(p111_intrinsic("nat_add",[word,N111Const{offset,0}]),target,n))


@unsafe
def p113df_field_env(+book: List<&2,KDef>, +mat: KTerm, +count: U32, +i: U32, +n: U32) -> List<&2,NC_Binding>:
  nt_choose(List<&2,NC_Binding>,U32.is_eq(i,count),u => [],
    u => Con{p113n_field_binding(book,mat,count,i,n),p113df_field_env(book,mat,count,U32.inc(i),n)})

@unsafe
def p113n_field_kind(+book: List<&2,KDef>, +mat: KTerm, +count: U32, +index: U32) -> N_WordKind:
  nt_choose(N_WordKind,p98_tag_eq(mat,"Mat") && U32.is_eq(ix(mat),U32.inc(count)) && U32.is_le(count,8) && U32.is_lt(index,count) && U32.is_lt(qt(mat),U32.shln(1,U32.to_nat(count))),
    u => p113n_at(p113n_field_kinds(book,nm(mat),count),index),u => N_W64{})

# Preserve the mature scalar mask for every field not proved Imm64. This
# helper does not promote an unknown ordinary Term to a nonowning value.


@unsafe
def p113n_field_binding(+book: List<&2,KDef>, +mat: KTerm, +count: U32, +index: U32, +n: U32) -> NC_Binding:
  nt_choose(NC_Binding,p113n_is_imm(p113n_field_kind(book,mat,count,index)),
    u => NC_Binding{nc_id(U32.add(n,index)),"v_" ++ U32.show(nc_id(U32.add(n,index))),N_Imm64{}},
    u => nk_field_binding(nc_id(U32.add(n,index)),p113df_mask(mat,count),index))

# Exact incumbent classifier, used after the two Nat constructor cases.


@unsafe
def p113dc_definition(+book: List<&2,KDef>, +d: KDef, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +n: U32, +arity: U32) -> KTerm:
  nt_choose(KTerm,agy_str_eq(dk(d),"Def") && Bool.not(nc_native_def(d) || nc_foreign(d)),
    u => nt_choose(KTerm,U32.is_eq(nd_leading(dv(d),0),arity) && U32.is_le(n,U32.sub(4294967295,arity)),
      v => nd_comb_try(nc_erase(book,dv(d)),args,env,n,arity),
      v => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}),
    u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})


@unsafe
def p113dc_arity(+book: List<&2,KDef>, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +n: U32, +arity: U32) -> KTerm:
  +count = terms_len(args)
  nt_choose(KTerm,U32.is_gt(arity,0) && U32.is_le(arity,8) && U32.is_gt(count,0) && U32.is_le(count,arity) && nd_comb_literal(args),
    u => p113dc_definition(book,lookup(book,nm(head)),args,env,n,arity),
    u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})


@unsafe
def p113dc_plan(+book: List<&2,KDef>, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +n: U32) -> KTerm:
  nt_choose(KTerm,agy_str_eq(tg(head),"Ref") && Bool.not(U32.is_eq(qt(head),3)),
    u => p113dc_arity(book,head,args,env,n,nd_arity(book,nm(head))),
    u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})


@unsafe
def p113dc_next(+book: List<&2,KDef>, +head: KTerm, +n: U32) -> U32:
  U32.add(n,nd_arity(book,nm(head)))


@unsafe
def p113k_join_record_h(+record: KDef, +hash: U32, +right: KDef, +out: KDef) -> KDef:
  match record:
    case KDef{name, lkind, la, lx, _, lv, _, _, _}:
      w5c2_join_rec_h_ok(String.eq(lkind, "P113KFact"), name, hash, la, lx, lv, right, out)
    case _: out

@unsafe
def p113k_join_bucket_h(bucket: List<&2,KDef>, +hash: U32, +right: KDef, out: KDef) -> KDef:
  match bucket:
    case Nil{}: out
    case Con{+head,rest}: p113k_join_bucket_h(rest,hash,right,p113k_join_record_h(head,hash,right,out))

@unsafe
def p113k_join_record_b(+record: KDef, +hash: U32, +rbucket: List<&2,KDef>, +out: KDef) -> KDef:
  match record:
    case KDef{name, lkind, la, lx, _, lv, _, _, _}:
      w5c2_join_rec_b_ok(String.eq(lkind, "P113KFact"), name, hash, la, lx, lv, rbucket, out)
    case _: out

@unsafe
def p113k_join_buckets(lbucket: List<&2,KDef>, +hash: U32, +rbucket: List<&2,KDef>, out: KDef) -> KDef:
  match lbucket:
    case Nil{}: out
    case Con{+head,rest}: p113k_join_buckets(rest,hash,rbucket,p113k_join_record_b(head,hash,rbucket,out))

@unsafe
def p113k_join_bucket(bucket: List<&2,KDef>, +right: KDef, out: KDef) -> KDef:
  match bucket:
    case Nil{}: out
    case Con{+head,rest}: p113k_join_bucket(rest,right,p113k_join_record_h(head,index_hash(dn(head),2166136261),right,out))

@unsafe
def p113k_join_record(+record: KDef, +right: KDef, +out: KDef) -> KDef:
  p113k_join_record_h(record,index_hash(dn(record),2166136261),right,out)

law p113k_join_leaf:
  for +lh: U32
  for +lbucket: List<&2,KDef>
  for +right: KDef
  for +out: KDef
  KDef

@unsafe
def w5c2_jl_eq(eq: Bool, +lh: U32, +lbucket: List<&2,KDef>, +rbucket: List<&2,KDef>, +out: KDef) -> KDef:
  match eq:
    case True{}: p113k_join_buckets(lbucket, lh, rbucket, out)
    case False{}: out

@unsafe
def w5c2_jl_lr(go_l: Bool, +lh: U32, +lbucket: List<&2,KDef>, +ra: KDef, +rb: KDef, +out: KDef) -> KDef:
  match go_l:
    case True{}: p113k_join_leaf(lh, lbucket, ra, out)
    case False{}: p113k_join_leaf(lh, lbucket, rb, out)

@unsafe
def w5c2_jl_sub(in_sub: Bool, +lh: U32, +lbucket: List<&2,KDef>, +rm: U32, +ra: KDef, +rb: KDef, +out: KDef) -> KDef:
  match in_sub:
    case True{}: w5c2_jl_lr(U32.is_eq(U32.and(lh, rm), 0), lh, lbucket, ra, rb, out)
    case False{}: out

@unsafe
def w5c2_jl_rm0(rm0: Bool, +lh: U32, +lbucket: List<&2,KDef>, +rh: U32, +rm: U32, +ra: KDef, +rb: KDef, +right: KDef, +out: KDef) -> KDef:
  match rm0:
    case True{}: p113k_join_bucket_h(lbucket, lh, right, out)
    case False{}: w5c2_jl_sub(U32.is_eq(U32.and(U32.xor(lh, rh), U32.sub(rm, 1)), 0), lh, lbucket, rm, ra, rb, out)

@unsafe
def w5c2_jl_abs(is_abs: Bool, +lh: U32, +lbucket: List<&2,KDef>, +right: KDef, +out: KDef) -> KDef:
  match is_abs:
    case True{}: out
    case False{}: p113k_join_bucket_h(lbucket, lh, right, out)

@unsafe
def p113k_join_leaf(lh, lbucket, right, out):
  match right:
    case KIndexLeaf{rh, rbucket}:
      w5c2_jl_eq(U32.is_eq(lh, rh), lh, lbucket, rbucket, out)
    case KIndexNode{rh, rm, ra, rb}:
      w5c2_jl_rm0(U32.is_eq(rm, 0), lh, lbucket, rh, rm, ra, rb, right, out)
    case KDef{_, kind, _, _, _, _, _, _, _}:
      w5c2_jl_abs(String.eq(kind, "Absent"), lh, lbucket, right, out)

@unsafe
def p113k_scalar_bin(+name: String, +typ: N111Type, +op: String, +left: N111Value, +right: N111Value, +facts: KDef, +lf: P113KFact, +rf: P113KFact) -> P113KScalar:
  p123p_bin(name,typ,op,left,right,facts,lf,rf,p123p_pick(op,left,right,facts))

@unsafe
def w4g_ic_reads(body: List<&2,P113DStmt>, acc: KDef) -> KDef:
  match body:
    case Nil{}: acc
    case Con{P113DScalar{N111Set{_,_,v}},rest}: w4g_ic_reads(rest,w4g_ic_mark_val(v,acc))
    case Con{P113DScalar{N111Bin{_,_,_,l,r}},rest}: w4g_ic_reads(rest,w4g_ic_mark_val(r,w4g_ic_mark_val(l,acc)))
    case Con{_,rest}: w4g_ic_reads(rest,acc)


@unsafe
def w4k_mark_body(body: List<&2,P113DStmt>, used: KDef) -> KDef:
  match body:
    case Nil{}: used
    case Con{P113DScalar{s},rest}: w4k_mark_body(rest,w4k_mark_scalar(s,used))
    case Con{P113DIf{cond,yes,no},rest}: w4k_mark_body(rest,w4k_mark_body(no,w4k_mark_body(yes,w4k_mark_val(cond,used))))
    case Con{P113DCall{dsts,tgt,args},rest}: w4k_mark_body(rest,w4k_mark_vals(args,used))
    case Con{P113DResult{vals},rest}: w4k_mark_body(rest,w4k_mark_vals(vals,used))
    case Con{P113DAgain{vals},rest}: w4k_mark_body(rest,w4k_mark_vals(vals,used))


@unsafe
def w4k_dce(+body: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  +b1 = w4k_dce_body(body,w4k_mark_body(body,missing()))
  w4k_dce_body(b1,w4k_mark_body(b1,missing()))


# W4-5: General O(N) versioned forward copy propagation, backward liveness DCE,
# and pure-diamond branchless if-conversion in p113k_function.

law w4g_cscalars:
  for stmts: List<&2,N111Stmt>
  for +env: W4GCopyEnv
  W4GCopySc


@unsafe
def w4g_cscalar(stmt: N111Stmt, +env: W4GCopyEnv) -> W4GCopySc:
  match stmt:
    case N111Set{+dst,+typ,N111Local{+src}}:
      +rsrc = w4g_resolve(env,src)
      +is64 = U32.is_eq(p111v_type(typ),2)
      nt_choose(W4GCopySc,is64 && agy_str_eq(dst,rsrc) && Bool.not(w4g_reserved(dst)),
        u => W4GCopySc{[],env},
        u => nt_choose(W4GCopySc,is64 && Bool.not(w4g_reserved(dst)) && Bool.not(w4g_reserved(rsrc)),
          v => W4GCopySc{[N111Set{dst,typ,N111Local{rsrc}}],w4g_record_alias(env,dst,rsrc)},
          v => W4GCopySc{[N111Set{dst,typ,N111Local{rsrc}}],w4g_bump(env,dst)}))
    case N111Set{+dst,+typ,val}:
      W4GCopySc{[N111Set{dst,typ,w4g_cval(env,val)}],w4g_bump(env,dst)}
    case N111Bin{+dst,+typ,+op,l,r}:
      W4GCopySc{[N111Bin{dst,typ,op,w4g_cval(env,l),w4g_cval(env,r)}],w4g_bump(env,dst)}
    case N111Offset{+dst,b,by}:
      W4GCopySc{[N111Offset{dst,w4g_cval(env,b),w4g_cval(env,by)}],w4g_bump(env,dst)}
    case N111Load{+dst,+typ,b,off}:
      W4GCopySc{[N111Load{dst,typ,w4g_cval(env,b),off}],w4g_bump(env,dst)}
    case N111Store{typ,b,off,v}:
      W4GCopySc{[N111Store{typ,w4g_cval(env,b),off,w4g_cval(env,v)}],env}
    case N111Call{+dst,+typ,+sym,args}:
      W4GCopySc{[N111Call{dst,typ,sym,w4g_cargs(env,args)}],w4g_bump(env,dst)}
    case N111Alloca{+dst,bytes,align}:
      W4GCopySc{[N111Alloca{dst,bytes,align}],w4g_bump(env,dst)}
    case N111Return{v}:
      W4GCopySc{[N111Return{w4g_cval(env,v)}],env}
    case N111If{cond,yes,no}:
      w4g_cscalar_if(cond,env,w4g_cscalars(yes,env),w4g_cscalars(no,env))


@unsafe
def w4g_cscalars_next(res: W4GCopySc, rest: List<&2,N111Stmt>) -> W4GCopySc:
  match res:
    case W4GCopySc{pre,env}: w4g_cscalars_join(pre,w4g_cscalars(rest,env))


@unsafe
def w4g_cscalars(stmts, env):
  match stmts:
    case Nil{}: W4GCopySc{[],env}
    case Con{s,rest}: w4g_cscalars_next(w4g_cscalar(s,env),rest)


law w4g_cbody:
  for body: List<&2,P113DStmt>
  for +env: W4GCopyEnv
  W4GCopyBd


@unsafe
def w4g_cbody_next(pre: List<&2,P113DStmt>, env: W4GCopyEnv, rest: List<&2,P113DStmt>) -> W4GCopyBd:
  w4g_cbody_join(pre,w4g_cbody(rest,env))


@unsafe
def w4g_cbody_scalar(res: W4GCopySc, rest: List<&2,P113DStmt>) -> W4GCopyBd:
  match res:
    case W4GCopySc{ss,env1}: w4g_cbody_next(w4g_wrap_scalars(ss),env1,rest)


@unsafe
def w4g_cbody_if(cond: N111Value, +env: W4GCopyEnv, yc: W4GCopyBd, nc: W4GCopyBd, rest: List<&2,P113DStmt>) -> W4GCopyBd:
  match yc nc:
    case W4GCopyBd{yb,_} W4GCopyBd{nb,_}:
      w4g_cbody_next([P113DIf{w4g_cval(env,cond),yb,nb}],w4g_clear_aliases(env),rest)


@unsafe
def w4g_cbody(body, env):
  match body:
    case Nil{}: W4GCopyBd{[],env}
    case Con{P113DScalar{s},rest}: w4g_cbody_scalar(w4g_cscalar(s,env),rest)
    case Con{P113DIf{cond,yes,no},rest}:
      w4g_cbody_if(cond,env,w4g_cbody(yes,env),w4g_cbody(no,env),rest)
    case Con{P113DCall{+dsts,tgt,args},rest}:
      w4g_cbody_next([P113DCall{dsts,tgt,w4g_cvals(env,args)}],w4g_bump_names(dsts,env),rest)
    case Con{P113DResult{vals},rest}:
      w4g_cbody_next([P113DResult{w4g_cvals(env,vals)}],env,rest)
    case Con{P113DAgain{vals},rest}:
      w4g_cbody_next([P113DAgain{w4g_cvals(env,vals)}],w4g_clear_aliases(env),rest)


@unsafe
def w4g_copy_pass(body: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  w4g_copy_out(w4g_cbody(body,W4GCopyEnv{missing(),missing()}))


# Backward liveness DCE + pure-diamond branchless if-conversion.
@unsafe
def w4g_live_vals(vs: List<&2,N111Value>, live: KDef) -> KDef:
  match vs:
    case Nil{}: live
    case Con{v,rest}: w4g_live_vals(rest,w4g_live_val(v,live))


@unsafe
def w4g_live_args(args: List<&2,N111Arg>, live: KDef) -> KDef:
  match args:
    case Nil{}: live
    case Con{N111Arg{_,v},rest}: w4g_live_args(rest,w4g_live_val(v,live))


@unsafe
def w4g_arm_reads(body: List<&2,P113DStmt>, acc: KDef) -> KDef:
  match body:
    case Nil{}: acc
    case Con{P113DScalar{N111Set{_,_,v}},rest}: w4g_arm_reads(rest,w4g_live_val(v,acc))
    case Con{P113DScalar{N111Bin{_,_,_,l,r}},rest}: w4g_arm_reads(rest,w4g_live_val(r,w4g_live_val(l,acc)))
    case Con{_,rest}: w4g_arm_reads(rest,acc)


@unsafe
def w4g_try_ifconv(+cond: N111Value, +yb: List<&2,P113DStmt>, +nb: List<&2,P113DStmt>,
    +rest: List<&2,P113DStmt>, +afterLive: KDef, +yl: KDef, +nl: KDef) -> W4GBwd:
  +ydst = w4g_arm_last_dst(yb)
  +ndst = w4g_arm_last_dst(nb)
  +basic = Bool.not(String.is_empty(ydst)) && agy_str_eq(ydst,ndst) &&
    w4g_arm_pure(yb,12) && w4g_arm_pure(nb,12)
  nt_choose(W4GBwd,basic,
    u =>
      +yw = w4g_arm_writes(yb,missing())
      +nw = w4g_arm_writes(nb,missing())
      +yr = w4g_arm_reads(yb,missing())
      +nr = w4g_arm_reads(nb,missing())
      +forbY = w4g_live_union(afterLive,w4g_live_union(nr,nw))
      +forbN = w4g_live_union(afterLive,w4g_live_union(yr,yw))
      +ok = Bool.not(w4g_live_has(yr,ydst)) && Bool.not(w4g_live_has(nr,ydst)) &&
        w4g_cond_not_written(cond,yw) && w4g_cond_not_written(cond,nw) &&
        w4g_arm_nonlast_ok(yb,ydst,forbY) && w4g_arm_nonlast_ok(nb,ydst,forbN)
      nt_choose(W4GBwd,ok,
        v =>
          +ynm = ydst ++ "_w4y"
          +nnm = ydst ++ "_w4n"
          +cnm = ydst ++ "_w4c"
          +mnm = ydst ++ "_w4m"
          +dnm = ydst ++ "_w4d"
          +snm = ydst ++ "_w4s"
          +sel : List<&2,P113DStmt> = [
            P113DScalar{N111Bin{cnm,N111U64{},"ne",cond,N111Const{0,0}}},
            P113DScalar{N111Bin{mnm,N111U64{},"sub",N111Const{0,0},N111Local{cnm}}},
            P113DScalar{N111Bin{dnm,N111U64{},"xor",N111Local{ynm},N111Local{nnm}}},
            P113DScalar{N111Bin{snm,N111U64{},"and",N111Local{dnm},N111Local{mnm}}},
            P113DScalar{N111Bin{ydst,N111U64{},"xor",N111Local{nnm},N111Local{snm}}}
          ]
          +merged = nt_append(P113DStmt,w4g_arm_rename_last(yb,ynm),
            nt_append(P113DStmt,w4g_arm_rename_last(nb,nnm),nt_append(P113DStmt,sel,rest)))
          W4GBwd{merged,w4g_live_val(cond,w4g_live_union(yl,nl))},
        v => W4GBwd{Con{P113DIf{cond,yb,nb},rest},w4g_live_val(cond,w4g_live_union(yl,nl))}),
    u => W4GBwd{Con{P113DIf{cond,yb,nb},rest},w4g_live_val(cond,w4g_live_union(yl,nl))})


law w4g_bwd_body:
  for body: List<&2,P113DStmt>
  for live: KDef
  for +again: KDef
  for +term: KDef
  W4GBwd


@unsafe
def w4g_bwd_pure(stmt: N111Stmt, +name: String, reads: List<&2,N111Value>, +after: W4GBwd) -> W4GBwd:
  match after:
    case W4GBwd{body,+live}:
      nt_choose(W4GBwd,w4g_live_has(live,name) || w4g_reserved(name),
        u => W4GBwd{Con{P113DScalar{stmt},body},w4g_live_vals(reads,w4g_live_kill(live,name))},
        u => after)


@unsafe
def w4g_bwd_if_done(+cond: N111Value, rest: List<&2,P113DStmt>, +afterLive: KDef, yes: W4GBwd, no: W4GBwd) -> W4GBwd:
  match yes no:
    case W4GBwd{Nil{},yl} W4GBwd{Nil{},nl}:
      W4GBwd{rest,w4g_live_union(yl,nl)}
    case W4GBwd{yb,yl} W4GBwd{nb,nl}:
      W4GBwd{Con{P113DIf{cond,yb,nb},rest},w4g_live_val(cond,w4g_live_union(yl,nl))}


@unsafe
def w4g_bwd_if(cond: N111Value, yes: List<&2,P113DStmt>, no: List<&2,P113DStmt>,
    after: W4GBwd, +again: KDef, +term: KDef) -> W4GBwd:
  match after:
    case W4GBwd{body,+live}:
      w4g_bwd_if_done(cond,body,live,w4g_bwd_body(yes,live,again,term),w4g_bwd_body(no,live,again,term))


@unsafe
def w4g_bwd_scalar(+stmt: N111Stmt, +after: W4GBwd, +again: KDef, +term: KDef) -> W4GBwd:
  match stmt after:
    case N111Set{+name,_,v} _: w4g_bwd_pure(stmt,name,[v],after)
    case N111Bin{+name,_,+op,l,r} W4GBwd{body,live}:
      nt_choose(W4GBwd,w4k_pure_bin(op),
        u => w4g_bwd_pure(stmt,name,[l,r],after),
        u => W4GBwd{Con{P113DScalar{stmt},body},w4g_live_vals([l,r],w4g_live_kill(live,name))})
    case N111Offset{+name,b,by} _: w4g_bwd_pure(stmt,name,[b,by],after)
    case N111Call{+name,_,_,args} W4GBwd{body,live}:
      W4GBwd{Con{P113DScalar{stmt},body},w4g_live_args(args,w4g_live_kill(live,name))}
    case N111Load{+name,_,b,_} W4GBwd{body,live}:
      W4GBwd{Con{P113DScalar{stmt},body},w4g_live_val(b,w4g_live_kill(live,name))}
    case N111Store{_,b,_,v} W4GBwd{body,live}:
      W4GBwd{Con{P113DScalar{stmt},body},w4g_live_val(v,w4g_live_val(b,live))}
    case N111Alloca{name,_,_} W4GBwd{body,live}:
      W4GBwd{Con{P113DScalar{stmt},body},w4g_live_kill(live,name)}
    case N111If{cond,yes,no} _:
      w4g_bwd_if(cond,w4g_wrap_scalars(yes),w4g_wrap_scalars(no),after,again,term)
    case N111Return{v} W4GBwd{body,live}:
      W4GBwd{Con{P113DScalar{stmt},body},w4g_live_val(v,term)}


@unsafe
def w4g_bwd_stmt(+stmt: P113DStmt, after: W4GBwd, +again: KDef, +term: KDef) -> W4GBwd:
  match stmt after:
    case P113DScalar{sc} _: w4g_bwd_scalar(sc,after,again,term)
    case P113DIf{cond,yes,no} _: w4g_bwd_if(cond,yes,no,after,again,term)
    case P113DCall{names,_,args} W4GBwd{body,live}:
      W4GBwd{Con{stmt,body},w4g_live_vals(args,w4g_live_kills(names,live))}
    case P113DResult{vals} W4GBwd{body,live}:
      W4GBwd{Con{stmt,body},w4g_live_vals(vals,term)}
    case P113DAgain{vals} W4GBwd{body,live}:
      W4GBwd{Con{stmt,body},w4g_live_vals(vals,again)}


@unsafe
def w4g_bwd_body(body, live, again, term):
  match body:
    case Nil{}: W4GBwd{[],live}
    case Con{h,rest}: w4g_bwd_stmt(h,w4g_bwd_body(rest,live,again,term),again,term)


@unsafe
def w4g_bwd_dce(+body: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  +base = w4g_live_base()
  +again = nt_choose(KDef,w4c_body_has_again(body),u => w4g_live_union(w4k_mark_body(body,missing()),base),u => base)
  w4g_bwd_out(w4g_bwd_body(body,base,again,base))


@unsafe
def p113ai_intrinsic(+name: String, +values: List<&2,N111Value>, +n: U32) -> P111ValueCode:
  nt_choose(P111ValueCode,agy_str_eq(name,"array_set") && U32.is_eq(nt_count(N111Value,values),3),
    u => p113ai_set_done(values,n,p111_intrinsic(name,values)),
    u => p111_intrinsic(name,values))


@unsafe
def p113e_product_call(+name: String, +typ: N111Type, +symbol: String, +args: List<&2,N111Arg>, +schema: KDef, +live: KDef, +ids: N111Ids) -> P111VFlow:
  p111v_step(U32.is_eq(p111v_type(typ),2) && p113p_array_call(symbol,args) && p113e_runtime_args(args) &&
    p111v_args(args,[3,1,3,1,3,1],live,ids) && p111v_buffer(args,2,p111v_literal(p111v_arg(args,3)),live) &&
    p111v_memory(p111v_arg(args,4),8,2,live,ids),name,schema,live,"product array import signature/count/capacity mismatch")


@unsafe
def p113l_copy_relation(+before: KDef, +after: KDef, +name: String, value: N111Value, +invert: Bool) -> KDef:
  match value:
    case N111Local{source}: w5c2_p113l_copy_rec(p113l_relation(before, source), after, name, invert)
    case _: after

@unsafe
def w5c2_p113l_br_eqne(is_eqne: Bool, +before: KDef, +after: KDef, +name: String, +op: String, +left: N111Value, +right: N111Value) -> KDef:
  match is_eqne:
    case True{}: p113l_comparison(before, after, name, op, p113k_replace(left, before), p113k_replace(right, before))
    case False{}: after

@unsafe
def w5c2_p113l_br_xor1(ok: Bool, +before: KDef, +after: KDef, +name: String, +left: N111Value) -> KDef:
  match ok:
    case True{}: p113l_copy_relation(before, after, name, left, True{})
    case False{}: after

@unsafe
def w5c2_p113l_br_lz(ok: Bool, +before: KDef, +after: KDef, +name: String, +op: String, +left: N111Value, +right: N111Value, +rf: P113KFact) -> KDef:
  match ok:
    case True{}: p113l_copy_relation(before, after, name, right, False{})
    case False{}: w5c2_p113l_br_xor1(String.eq(op, "xor") && p113l_exact_one(rf), before, after, name, left)

@unsafe
def w5c2_p113l_br_rz(ok: Bool, +before: KDef, +after: KDef, +name: String, +op: String, +left: N111Value, +right: N111Value, +rf: P113KFact) -> KDef:
  match ok:
    case True{}: p113l_copy_relation(before, after, name, left, False{})
    case False{}: w5c2_p113l_br_lz(p113k_zero(p113k_value(left, before)), before, after, name, op, left, right, rf)

@unsafe
def p114h_scan(+body: List<&2,N111Stmt>, +owner: String, +arity: U32, +ready: KDef) -> P114GBody:
  nt_choose(P114GBody,p112t_failure(body),u => P114GBody{True{},[],[P114RFailure{body}]},
    u => p114h_scan_normal(body,owner,arity,ready))


@unsafe
def p114h_scan_normal(+body: List<&2,N111Stmt>, +owner: String, +arity: U32, +ready: KDef) -> P114GBody:
  nt_choose(P114GBody,p112w_result(body),
    u => P114GBody{True{},[],[P114RResult{p114r_result_word(body)}]},u =>
  nt_choose(P114GBody,p112t_tail(body,owner,arity,0),
    u => P114GBody{True{},[],[P114RAgain{p114r_without_transition(body)}]},
    u => p114h_scan_target(body,owner,arity,ready,p112w_target(body))))


@unsafe
def p114h_scan_target(+body: List<&2,N111Stmt>, +owner: String, +arity: U32, +ready: KDef, +target: String) -> P114GBody:
  nt_choose(P114GBody,p124r_is_view(ready),
    u => p124r_terminal(body,owner,arity,ready,target,p124r_lookup(ready,target)),
    u => p124r_original_target(body,owner,arity,ready,target))

@unsafe
def p114h_scan_frame(+body: List<&2,N111Stmt>, +owner: String, +arity: U32, +ready: KDef, frame: Maybe<&2,P112FusionFrame>) -> P114GBody:
  p186sf_frame(body,owner,arity,ready,frame)

@unsafe
def p186sf_previous_frame(+body: List<&2,N111Stmt>, +owner: String, +arity: U32, +ready: KDef, frame: Maybe<&2,P112FusionFrame>) -> P114GBody:
  match frame:
    case Some{P112FusionFrame{captures,+name,dest,+tail}}:
      +count = nt_count(N111Value,captures)
      nt_choose(P114GBody,U32.is_le(count,8) && p126r_arguments(tail,owner,arity),
        u => P114GBody{True{},[P114GFrame{name,count}],[P114RDescend{p114r_prefix(body,U32.inc(count)),p114r_without_transition(tail)}]},
        u => p124r_resume(body,tail,owner,name,count,ready))
    case None{}: p114h_scan_next(body,owner,arity,ready)

@unsafe
def p114h_scan_next(body: List<&2,N111Stmt>, +owner: String, +arity: U32, +ready: KDef) -> P114GBody:
  match body:
    case Nil{}: P114GBody{True{},[],[]}
    case Con{N111If{condition,yes,no},rest}:
      p114g_branch(condition,p114h_scan(yes,owner,arity,ready),p114h_scan(no,owner,arity,ready),p114h_scan(rest,owner,arity,ready))
    case Con{+stmt,+rest}:
      nt_choose(P114GBody,p112t_scalar_safe(stmt),
        u => p114g_prepend(stmt,p114h_scan_normal(rest,owner,arity,ready)),
        u => p114g_prepend(stmt,p114h_scan(rest,owner,arity,ready)))

# A missing case has an impossible capture count; real layouts are 0..8.


@unsafe
def p114h_close(pending: List<&2,P114GFrame>, +owner: String, +arity: U32, +index: P112FusionIndex,
    +ready: KDef, +cases: List<&2,P114HCase>, +left: U32) -> P114HClosed:
  match pending:
    case Nil{}: P114HClosed{True{},nt_reverse(P114HCase,cases,[])}
    case Con{P114GFrame{+name,count},rest}:
      p114h_close_seen(name,count,rest,owner,arity,index,ready,cases,left,p114h_count(cases,name))


@unsafe
def p114h_close_seen(+name: String, +count: U32, +rest: List<&2,P114GFrame>, +owner: String, +arity: U32,
    +index: P112FusionIndex, +ready: KDef, +cases: List<&2,P114HCase>, +left: U32, +seen: U32) -> P114HClosed:
  nt_choose(P114HClosed,U32.is_eq(seen,4294967295),u =>
    nt_choose(P114HClosed,U32.is_gt(left,0),
      v => p114h_close_found(name,count,rest,owner,arity,index,ready,cases,U32.sub(left,1),p112f_index_get(index,name)),
      v => P114HClosed{False{},[]}),u =>
    nt_choose(P114HClosed,U32.is_eq(seen,count),
      v => p114h_close(rest,owner,arity,index,ready,cases,left),v => P114HClosed{False{},[]}))


@unsafe
def p114h_close_found(+name: String, +count: U32, +rest: List<&2,P114GFrame>, +owner: String, +arity: U32,
    +index: P112FusionIndex, +ready: KDef, +cases: List<&2,P114HCase>, +left: U32, found: Maybe<&2,N111Segment>) -> P114HClosed:
  match found:
    case Some{+segment}:
      nt_choose(P114HClosed,p114h_clean_segment(segment),
        u => p114h_close_cont(name,rest,owner,arity,index,ready,cases,left,p112f_cont(segment,count)),
        u => P114HClosed{False{},[]})
    case None{}: P114HClosed{False{},[]}


@unsafe
def p114h_close_cont(+name: String, +rest: List<&2,P114GFrame>, +owner: String, +arity: U32,
    +index: P112FusionIndex, +ready: KDef, +cases: List<&2,P114HCase>, +left: U32, cont: Maybe<&2,P112FusionCont>) -> P114HClosed:
  match cont:
    case Some{P112FusionCont{captures,result,pop,body}}:
      p114h_close_scanned(name,captures,result,pop,rest,owner,arity,index,ready,cases,left,p114h_scan(body,owner,arity,ready))
    case None{}: P114HClosed{False{},[]}


@unsafe
def p114h_close_scanned(+name: String, +captures: List<&2,String>, +result: String, +pop: String,
    +rest: List<&2,P114GFrame>, +owner: String, +arity: U32, +index: P112FusionIndex, +ready: KDef,
    +cases: List<&2,P114HCase>, +left: U32, scanned: P114GBody) -> P114HClosed:
  match scanned:
    case P114GBody{valid,frames,body}:
      nt_choose(P114HClosed,valid,u => p114h_close(nt_append(P114GFrame,frames,rest),owner,arity,index,ready,
        Con{P114HCase{name,captures,result,pop,body},cases},left),u => P114HClosed{False{},[]})


@unsafe
def p114h_finish(+params: List<&2,String>, +owner: String, +arity: U32, +index: P112FusionIndex,
    +ready: KDef, scanned: P114GBody) -> P114HPlan:
  match scanned:
    case P114GBody{valid,+frames,+body}:
      nt_choose(P114HPlan,valid && (U32.is_gt(nt_count(P114GFrame,frames),0) || agy_p114r_body_calls_h(body)),
        u => p114h_closed(params,body,p114h_close(frames,owner,arity,index,ready,[],8)),u => p114h_refused())


@unsafe
def p114h_prelude(+owner: String, +arity: U32, +index: P112FusionIndex, +ready: KDef, prelude: P112TailPrelude) -> P114HPlan:
  match prelude:
    case P112TailPrelude{valid,params,prefix,body}:
      nt_choose(P114HPlan,valid,u => p114h_finish(params,owner,arity,index,ready,p114h_scan(body,owner,arity,ready)),u => p114h_refused())

@unsafe
def p117h_scalar(+stmt: N111Stmt, +scan: P117HScan) -> P117HScan:
  match stmt scan:
    case N111Set{name,N111Ptr{},value} _: p117h_abort(scan)
    case N111Set{name,N111U64{},value} P117HScan{+facts,slots,mask,used,again,left,next,sites}:
      p117h_set(name,p117h_value(value,facts),scan)
    case N111Set{name,typ,value} _: p117h_set(name,0,scan)
    case N111Load{name,N111U64{},base,offset} P117HScan{facts,+slots,mask,used,again,left,next,sites}:
      p117h_set(name,p117h_load(base,offset,slots),scan)
    case N111Load{name,typ,base,offset} _: p117h_set(name,0,scan)
    case N111Bin{name,typ,op,left,right} _: p117h_set(name,0,scan)
    case N111Offset{name,base,bytes} _: p117h_abort(scan)
    case N111Alloca{name,bytes,align} P117HScan{facts,slots,mask,used,again,left,next,sites}:
      P117HScan{p117h_put(facts,name,0),slots,mask,used,again,left,next,sites}
    case N111Store{N111U64{},base,offset,value} P117HScan{+facts,slots,mask,used,again,left,next,sites}:
      P117HScan{facts,p117h_write(base,offset,p117h_value(value,facts),slots),mask,used,again,left,next,sites}
    case N111Store{typ,base,offset,value} P117HScan{facts,slots,mask,used,again,left,next,sites}:
      P117HScan{facts,missing(),mask,used,again,left,next,sites}
    case N111Call{name,N111U64{},symbol,args} _: p117h_call(name,p113a_call_id(symbol,args),args,scan)
    case N111Call{name,typ,symbol,args} _: p117h_call(name,0,args,scan)
    case N111If{condition,yes,no} _: p117h_diamond(p113bq_scalar(yes,no),scan)
    case _ _: scan


@unsafe
def p117h_walk(body: List<&2,P113DStmt>, +count: U32, +scan: P117HScan) -> P117HScan:
  match body scan:
    case Nil{} _: scan
    case _ P117HScan{facts,slots,mask,used,again,0,next,sites}:
      P117HScan{facts,slots,0,used,again,0,next,sites}
    case Con{head,rest} P117HScan{facts,slots,mask,used,again,left,next,sites}:
      p117h_walk(rest,count,p117h_head(head,count,P117HScan{facts,slots,mask,used,again,U32.sub(left,1),next,sites}))


@unsafe
def p117h_head(+stmt: P113DStmt, +count: U32, +scan: P117HScan) -> P117HScan:
  match stmt scan:
    case P113DScalar{scalar} _: p117h_scalar(scalar,scan)
    case P113DCall{names,target,args} P117HScan{facts,slots,mask,used,again,left,next,sites}:
      P117HScan{p117h_kill(names,facts),missing(),mask,used,again,left,next,sites}
    case P113DAgain{values} P117HScan{+facts,slots,mask,used,again,left,next,sites}:
      P117HScan{missing(),missing(),U32.and(mask,p117h_backedge(values,facts,1,count)),used,True{},left,next,sites}
    case P113DIf{condition,yes,no} P117HScan{+facts,+slots,mask,used,again,left,next,sites}:
      p117h_branches(no,count,facts,slots,p117h_walk(yes,count,scan))
    case _ _: scan

# Only the existing exact literal1/0 diamond is admitted. Both arms are one
# U64 assignment, so only that destination loses its origin. No sites/effects.

@unsafe
def p117h_branches(no: List<&2,P113DStmt>, +count: U32, facts: KDef, slots: KDef, yes: P117HScan) -> P117HScan:
  match yes:
    case P117HScan{yf,ys,mask,used,again,left,next,sites}:
      p117h_join(yf,ys,p117h_walk(no,count,P117HScan{facts,slots,mask,used,again,left,next,sites}))


@unsafe
def p117h_join(yf: KDef, ys: KDef, scan: P117HScan) -> P117HScan:
  match scan:
    case P117HScan{facts,slots,mask,used,again,left,next,sites}:
      P117HScan{p117h_common(yf,facts,missing()),p117h_common(ys,slots,missing()),mask,used,again,left,next,sites}

# Layout projection hooks. Packed32 composition overrides these three helpers;
# bytebase always shifts location by3 because locations use heap-word units.

law w5_fs_check_inv:
  for +pidx: U32
  for body: List<&2,P113DStmt>
  for +env: KDef
  Bool

@unsafe
def w5_fs_check_inv(pidx,body,env):
  match body:
    case Nil{}: True{}
    case Con{P113DScalar{stmt},rest}: w5_fs_check_inv(pidx,rest,w4c_step_scalar(stmt,env))
    case Con{P113DCall{dests,_,_},rest}: w5_fs_check_inv(pidx,rest,w4c_kill_names(dests,env))
    case Con{P113DIf{_,yes,no},rest}:
      w5_fs_check_inv(pidx,yes,env) && w5_fs_check_inv(pidx,no,env) && w5_fs_check_inv(pidx,rest,env)
    case Con{P113DAgain{vals},_}: w5_fs_check_inv_val(w4c_nth_val(vals,pidx),pidx,env)
    case Con{_,rest}: w5_fs_check_inv(pidx,rest,env)

@unsafe
def w5_step_scalar_ext(+stmt: N111Stmt, +env: KDef) -> KDef:
  match stmt:
    case N111If{cond,yes,no}: w5_step_min_if(cond,x181_scalar_rows(yes),x181_scalar_rows(no),env)
    case _: w4c_step_scalar(stmt,env)

@unsafe
def w5_step_store(base: N111Value, +off: U32, +val: N111Value, +env: KDef) -> KDef:
  match base:
    case N111Local{+buf}:
      nt_choose(KDef,U32.is_eq(off,8),
        u => w5_step_store_val(val,buf,env),
        u => env)
    case _: env

@unsafe
def w4c_step_scalar(stmt: N111Stmt, +env: KDef) -> KDef:
  match stmt:
    case N111Bin{dest,_,op,left,right}:
      w4c_step_bin_r(w4c_const_u32_any(right),dest,op,w4c_local_name(left),w4c_const_u32_any(left),w4c_local_name(right),env)
    case N111Set{dest,_,val}: w4c_step_set(val,dest,env)
    case N111Store{_,base,off,val}: w5_step_store(base,off,val,env)
    case N111Call{dest,_,sym,args}: w5_step_rt_call(dest,sym,args,env)
    case N111Load{dest,_,_,_}: w4c_env_kill(env,dest)
    case N111Offset{dest,_,_}: w4c_env_kill(env,dest)
    case N111Alloca{dest,_,_}: w4c_env_kill(env,dest)
    case _: env

@unsafe
def w4c_fs_check_dec(+pidx: U32, body: List<&2,P113DStmt>, +guarded: Bool, +env: KDef) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{P113DScalar{stmt},rest}: w4c_fs_check_dec(pidx,rest,guarded,w4c_step_scalar(stmt,env))
    case Con{P113DCall{dests,_,_},rest}: w4c_fs_check_dec(pidx,rest,guarded,w4c_kill_names(dests,env))
    case Con{P113DAgain{vals},rest}:
      guarded && w4c_val_is_dec(w4c_nth_val(vals,pidx),pidx,env) && w4c_fs_check_dec(pidx,rest,guarded,env)
    case Con{P113DIf{cond,yes,no},rest}:
      +isNz = w4c_opt_eq(w4c_cond_nz_param(cond,env),pidx)
      w4c_fs_check_dec(pidx,yes,guarded || isNz,env) &&
      w4c_fs_check_dec(pidx,no,guarded,env) &&
      w4c_fs_check_dec(pidx,rest,guarded,env)
    case Con{_,rest}: w4c_fs_check_dec(pidx,rest,guarded,env)

@unsafe
def w4c_fs_check_inc(+pidx: U32, body: List<&2,P113DStmt>, +env: KDef) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{P113DScalar{stmt},rest}: w4c_fs_check_inc(pidx,rest,w4c_step_scalar(stmt,env))
    case Con{P113DCall{dests,_,_},rest}: w4c_fs_check_inc(pidx,rest,w4c_kill_names(dests,env))
    case Con{P113DAgain{vals},rest}:
      w4c_val_is_inc(w4c_nth_val(vals,pidx),pidx,env) && w4c_fs_check_inc(pidx,rest,env)
    case Con{P113DIf{_,yes,no},rest}:
      w4c_fs_check_inc(pidx,yes,env) && w4c_fs_check_inc(pidx,no,env) && w4c_fs_check_inc(pidx,rest,env)
    case Con{_,rest}: w4c_fs_check_inc(pidx,rest,env)

law w4c_fs_max_bm:
  for +pidx: U32
  for body: List<&2,P113DStmt>
  for +env: KDef
  for +acc: U32
  Maybe<&2,U32>

@unsafe
def w4c_fs_max_bm_b(mb: Maybe<&2,U32>, +pidx: U32, rest: List<&2,P113DStmt>, +env: KDef, +acc: U32) -> Maybe<&2,U32>:
  match mb:
    case Some{+b}:
      +m2 = nt_choose(U32,U32.is_gt(b,acc),u => b,u => acc)
      w4c_fs_max_bm(pidx,rest,env,m2)
    case None{}: None{}

@unsafe
def w4c_fs_max_bm_no(m2: Maybe<&2,U32>, +pidx: U32, rest: List<&2,P113DStmt>, +env: KDef) -> Maybe<&2,U32>:
  match m2:
    case Some{+a2}: w4c_fs_max_bm(pidx,rest,env,a2)
    case None{}: None{}

@unsafe
def w4c_fs_max_bm_yes(m1: Maybe<&2,U32>, +pidx: U32, no: List<&2,P113DStmt>, rest: List<&2,P113DStmt>, +env: KDef) -> Maybe<&2,U32>:
  match m1:
    case Some{+a1}: w4c_fs_max_bm_no(w4c_fs_max_bm(pidx,no,env,a1),pidx,rest,env)
    case None{}: None{}

@unsafe
def w4c_fs_max_bm(pidx,body,env,acc):
  match body:
    case Nil{}: Some{acc}
    case Con{P113DScalar{stmt},rest}: w4c_fs_max_bm(pidx,rest,w4c_step_scalar(stmt,env),acc)
    case Con{P113DCall{dests,_,_},rest}: w4c_fs_max_bm(pidx,rest,w4c_kill_names(dests,env),acc)
    case Con{P113DAgain{vals},rest}:
      w4c_fs_max_bm_b(w4c_val_bm_opt(w4c_nth_val(vals,pidx),env),pidx,rest,env,acc)
    case Con{P113DIf{_,yes,no},rest}:
      w4c_fs_max_bm_yes(w4c_fs_max_bm(pidx,yes,env,acc),pidx,no,rest,env)
    case Con{_,rest}: w4c_fs_max_bm(pidx,rest,env,acc)

@unsafe
def w4c_bce_site(+n: U32, +origin: U32, +idxVal: N111Value, +guarded: Bool, +cntName: String,
    +params: List<&2,NC_Binding>, +ivMask: U32, +pbmMap: KDef, +env: KDef,
    +nomask: KDef, +guards: List<&2,N111Stmt>) -> W4CBCEPlan:
  w4c_bce_site_bm(w4c_val_bm_env(idxVal,env),n,origin,idxVal,guarded,cntName,params,ivMask,pbmMap,env,nomask,guards)

@unsafe
def p118t_import_call(+name: String, +typ: N111Type, +symbol: String, +args: List<&2,N111Arg>, +schema: KDef, +live: KDef, +ids: N111Ids) -> P111VFlow:
  p111v_step(U32.is_eq(p111v_type(typ),2) && p113e_runtime_args(args) && p118t_import_contract(symbol,args,live,ids),
    name,schema,live,"TRMC import signature/constructor/capacity mismatch")


law p118b_eval:
  for +t: KTerm
  for +env: List<&2,NC_Binding>
  for +n: U32
  P113DCode

@unsafe
def p118b_eval(t,env,n):
  nt_choose(P113DCode,agy_str_eq(tg(t),"Var") || agy_str_eq(tg(t),"NWord"),
    u => p113d_emitted(P113DLocal{p118b_value_name(n)},U32.inc(n),p111_value(t,env)),
    u => nt_choose(P113DCode,agy_str_eq(tg(t),"NO_ReadCall"),
      v => p128br_eval_call(nm(t),n,p118b_args(ks(t),env,U32.inc(n))),
      v => nt_choose(P113DCode,agy_str_eq(tg(t),"Ctr") || agy_str_eq(tg(t),"NCtr") || agy_str_eq(tg(t),"NOp"),
        w => p118b_eval_call(t,n,p118b_args(ks(t),env,U32.inc(n))),
        w => p113d_fail("borrowed value: unsupported node",n))))

@unsafe
def p118b_args(terms: List<&2,KTerm>, +env: List<&2,NC_Binding>, +n: U32) -> P118BValues:
  match terms:
    case Nil{}: P118BValues{[],[],n,""}
    case Con{head,rest}: p118b_args_head(rest,env,n,p118b_eval(head,env,n))


@unsafe
def p118b_args_head(rest: List<&2,KTerm>, +env: List<&2,NC_Binding>, +n: U32, +first: P113DCode) -> P118BValues:
  p118b_args_tail(n,first,p118b_args(rest,env,p113d_fresh(first)))


@unsafe
def p118b_eval_call(+t: KTerm, +n: U32, args: P118BValues) -> P113DCode:
  match args:
    case P118BValues{body,+values,next,error}:
      +value = nt_choose(P111ValueCode,agy_str_eq(tg(t),"NOp"),
        u => p111_intrinsic(nm(t),values),u => p111_constructor(nm(t),values))
      p113d_join(P113DCode{body,next,error,[]},
        p113d_emitted(P113DLocal{p118b_value_name(n)},next,value))


law p118b_lower:
  for +t: KTerm
  for +env: List<&2,NC_Binding>
  for +params: List<&2,NC_Binding>
  for +layouts: List<&2,NO_Layout>
  for +n: U32
  P113DCode

@unsafe
def p118b_lower(t,env,params,layouts,n):
  nt_choose(P113DCode,agy_str_eq(tg(t),"NO_Return"),u => p118b_terminal(False{},p118b_args(ks(t),env,n)),u =>
  nt_choose(P113DCode,agy_str_eq(tg(t),"NO_Loop"),u => p118b_terminal(True{},p118b_args(ks(t),env,n)),u =>
  nt_choose(P113DCode,agy_str_eq(tg(t),"NO_Let"),u => p118b_let(t,env,params,layouts,n),u =>
  nt_choose(P113DCode,agy_str_eq(tg(t),"NO_Match"),u => p118b_match(t,env,params,layouts,n,no_layout(nm(t),layouts)),u =>
  nt_choose(P113DCode,agy_str_eq(tg(t),"NO_Error") && agy_str_eq(nm(t),"ERR_FIDS"),
    u => p113d_prepend([N111Call{"ignored",N111U64{},"p111_rt_fail",[p111_state(),p111_u32(4)]}],p113d_result(N111Const{0,0},P113DReturn{},n)),
    u => p113d_fail("borrowed residual: unsupported node",n))))))


@unsafe
def p118b_let(+t: KTerm, +env: List<&2,NC_Binding>, +params: List<&2,NC_Binding>, +layouts: List<&2,NO_Layout>, +n: U32) -> P113DCode:
  +first = p118b_eval(kid(t,0),env,n)
  +assigned : N111Stmt = N111Set{"v_" ++ U32.show(ix(t)),N111U64{},N111Local{p118b_value_name(n)}}
  p113d_join(first,p113d_prepend([assigned],p118b_lower(kid(t,1),Con{nc_binding(ix(t)),env},params,layouts,p113d_fresh(first))))


@unsafe
def p118b_match(+t: KTerm, +env: List<&2,NC_Binding>, +params: List<&2,NC_Binding>, +layouts: List<&2,NO_Layout>, +n: U32, found: Maybe<&2,NO_Layout>) -> P113DCode:
  match found:
    case None{}: p113d_fail("borrowed residual: absent layout",n)
    case Some{+layout}:
      match layout:
        case NO_Layout{key,+ctor,storage,width}:
          +word : N111Value = N111Local{nc_word(ix(kid(t,0)),env)}
          +fields = ks(kid(t,1))
          +yesTerm = kid(t,2)
          +yes = p118b_lower(yesTerm,no_bind_fields(fields,env),params,layouts,n)
          +no = p118b_lower(kid(t,3),env,params,layouts,p113d_fresh(yes))
          p113d_prepend(p111_test(ctor,word),p113d_branch(N111Local{"match_condition"},
            p113d_prepend(p118b_reads(layout,fields,yesTerm,word),yes),no))


@unsafe
def p118c_candidates(book: List<&2,KDef>, defs: List<&2,KDef>, hot: List<&2,String>) -> List<&2,String>:
  p118ns_candidates(book,defs,hot,[])


@unsafe
def p118c_plan_hot(+request: NR_Request, +source: List<&2,KDef>, +book: List<&2,KDef>, +permission: Bool, +error: String, +hot: List<&2,String>) -> P118CPlan:
  +valid = permission && String.is_empty(error) && Bool.not(nb_contains(hot,"*"))
  P118CPlan{request,hot,nt_choose(List<&2,String>,valid,u => p118c_candidates(book,source,hot),u => []),valid,error}


@unsafe
def p118c_apply_verified(original: P113AProgram, +cold: List<&2,String>) -> P113AProgram:
  match original:
    case P113AProgram{P113DProgram{P112StaticProgram{P111Program{segments,ctors,show,names,effects,pure},nodes},functions},certificate}:
      P113AProgram{P113DProgram{P112StaticProgram{P111Program{segments,p118c_ctors(ctors,cold),show,names,effects,pure},nodes},functions},certificate}


@unsafe
def p118c_apply_plan(+original: P113AProgram, plan: P118CPlan) -> P113AProgram:
  match plan:
    case P118CPlan{request,hot,cold,valid,error}:
      nt_choose(P113AProgram,valid && String.is_empty(error),u => p118c_apply_verified(original,cold),u => original)

@unsafe
def p118i_permission(request: NR_Request) -> Bool:
  match request:
    case NR_Request{source,book,names,paths,scope,bound}:
      p118ns_effect_definitions(True{},book,names)

# Internal continuation only: runtime admission, source checking and original
# IR verification have already succeeded in the request-bound integrated entry.
# Scalar false never reaches p118e_permitted or p118e_cold; neither cold facts
# nor the existing scalar/unshared certificate is changed by this overlay.

@unsafe
def p118ns_candidates(+book: List<&2,KDef>, defs: List<&2,KDef>, +hot: List<&2,String>, reversed: List<&2,String>) -> List<&2,String>:
  match defs:
    case Nil{}: nt_reverse(String,reversed,[])
    case Con{+d,rest}:
      prefix = nt_choose(List<&2,String>,agy_str_eq(dk(d),"ADT") &&
        Bool.not(nb_contains(["Nat","U32","F32","Char","Bool","Array","Word.Nil","Word.Con","IO","IO.OP"],dn(d))),
        u => p118c_ctor_names(nc_ctor_specs(book,dc(d),da(d)),hot),u => [])
      p118ns_candidates(book,rest,hot,nt_reverse(String,prefix,reversed))


@unsafe
def p118ns_effect_definition(+d: KDef) -> Bool:
  nt_choose(Bool,nc_native_def(d),u => True{},u => nt_choose(Bool,nc_foreign(d),
    v => no_effect_foreign_allowed(db(d),agy_str_eq(tg(nc_unann(dv(d))),"Foreign"),dn(d)),
    v => agy_str_eq(dk(d),"Def") && no_effect_terms([dv(d)])))


@unsafe
def p118ns_effect_definitions(+valid: Bool, +book: List<&2,KDef>, names: List<&2,String>) -> Bool:
  match valid:
    case False{}: False{}
    case True{}:
      match names:
        case Nil{}: True{}
        case Con{name,rest}:
          p118ns_effect_definitions(p118ns_effect_definition(lookup(book,name)),book,rest)

@unsafe
def p198e_op(+book: List<&2,KDef>, +arm: KTerm, +name: String) -> String:
  +first = j_fusion_binder(arm,0)
  +second = j_fusion_binder(arm,1)
  +call = j_call_spine(j_fusion_after(arm,2),[])
  +l = j_call_spine(kid(call,0),[])
  +r = j_call_spine(kid(call,1),[])
  nt_choose(String,p98_tag_eq(first,"Lam") && j_fusion_var(j_fusion_after(arm,1),ix(first)),
    u => "leaf",u => nt_choose(String,p98_tag_eq(first,"Lam") && p98_tag_eq(second,"Lam") &&
      (agy_str_eq(nm(call),"U32.add") || agy_str_eq(nm(call),"U32.sub") || agy_str_eq(nm(call),"U32.mul")) &&
      j_primitive_call(book,call) && j_fusion_call(l,name,1) && j_fusion_var(kid(l,0),ix(first)) &&
      j_fusion_call(r,name,1) && j_fusion_var(kid(r,0),ix(second)), v => nm(call),v => ""))

@unsafe
def p198e_scalar(+book: List<&2,KDef>, +fold: KDef, +tree: KTerm, +seed: KTerm, +fuel: U32) -> KTerm:
  +h = j_strip(tree)
  nt_choose(KTerm,p98_tag_eq(h,"Ctr") && U32.is_gt(fuel,0),u =>
    p198e_field(book,fold,h,seed,U32.sub(fuel,1),p198e_op(book,p198e_arm(dv(fold),nm(h),12),dn(fold))),
    u => kt("Absent","",0,0,[]))

@unsafe
def p198e_field(+book: List<&2,KDef>, +fold: KDef, +h: KTerm, +seed: KTerm, +fuel: U32, +op: String) -> KTerm:
  nt_choose(KTerm,agy_str_eq(op,"leaf") && U32.is_eq(terms_len(ks(h)),1) && j_fusion_scalar(book,kid(h,0),[seed]),
    u => kid(h,0),u =>
    nt_choose(KTerm,Bool.not(String.is_empty(op)) && Bool.not(agy_str_eq(op,"leaf")) && U32.is_eq(terms_len(ks(h)),2),
      v => p198e_apply(op,p198e_scalar(book,fold,kid(h,0),seed,fuel),p198e_scalar(book,fold,kid(h,1),seed,fuel)),
      v => kt("Absent","",0,0,[])))

@unsafe
def p198e_choice(+book: List<&2,KDef>, +fold: KDef, +branch: KTerm, +skip: U32) -> P198EArm:
  +slot = j_fusion_binder(branch,skip)
  +seed = j_fusion_binder(branch,U32.inc(skip))
  +tree = j_fusion_after(branch,U32.add(skip,2))
  +left = j_fusion_var(kid(tree,0),ix(slot))
  +op = p198e_op(book,p198e_arm(dv(fold),nm(tree),12),dn(fold))
  nt_choose(P198EArm,p98_tag_eq(slot,"Lam") && p98_tag_eq(seed,"Lam") && p98_tag_eq(tree,"Ctr") &&
    U32.is_eq(terms_len(ks(tree)),2) && (agy_str_eq(op,"U32.add") || agy_str_eq(op,"U32.sub") || agy_str_eq(op,"U32.mul")) &&
    (left || j_fusion_var(kid(tree,1),ix(slot))),u =>
    p198e_finish_arm(book,op,left,seed,p198e_scalar(book,fold,nt_choose(KTerm,left,v => kid(tree,1),v => kid(tree,0)),seed,8)),
    u => P198ENoArm{})

@unsafe
def p198e_finish_arm(+book: List<&2,KDef>, +op: String, +left: Bool, +seed: KTerm, +value: KTerm) -> P198EArm:
  nt_choose(P198EArm,j_fusion_scalar(book,value,[seed]),u => P198EArm{op,left,value,seed},u => P198ENoArm{})

@unsafe
def p198e_arms(+book: List<&2,KDef>, +fold: KDef, +prod: KDef, +pick: KDef, +call: KTerm,
    +owner: String, +n: KTerm, +initial: KTerm, +params: List<&2,NC_Binding>) -> P198EPlan:
  +loop = j_fusion_link(prod)
  +pred = j_fusion_binder(loop,0)
  +seed = j_fusion_binder(loop,1)
  +base = j_fusion_empty(prod)
  +leaf = j_fusion_binder(base,0)
  +end = p198e_scalar(book,fold,j_fusion_after(base,1),leaf,8)
  +disc = j_call_spine(kid(call,0),[])
  +rec = j_call_spine(kid(call,1),[])
  +node = j_fusion_link(pick)
  +a = p198e_choice(book,fold,j_fusion_empty(pick),0)
  +b = p198e_choice(book,fold,kid(j_strip(node),0),0)
  +c = p198e_choice(book,fold,kid(j_strip(kid(j_strip(node),1)),0),1)
  nt_choose(P198EPlan,j_fusion_cases(node,"Zero","Succ") && p198e_word(book,p198e_domain(dt(pick),0),"Nat") &&
    p198e_owner(p198e_domain(dt(pick),1),owner) && p198e_word(book,p198e_domain(dt(pick),2),"U32") &&
    p198e_owner(kid(kid(kid(dt(pick),1),1),1),owner) && p98_tag_eq(pred,"Lam") && p98_tag_eq(seed,"Lam") &&
    p98_tag_eq(leaf,"Lam") && j_fusion_scalar(book,end,[leaf]) &&
    j_fusion_call(rec,dn(prod),2) && j_fusion_var(kid(rec,0),ix(pred)) &&
    j_fusion_scalar(book,kid(rec,1),[seed]) && j_fusion_scalar(book,kid(call,2),[seed]) &&
    j_fusion_call(disc,"U32.to_nat",1) && j_primitive_call(book,disc) && j_fusion_scalar(book,kid(disc,0),[seed]) &&
    p198e_triple(a,b,c),
    u => P198EReady{params,n,initial,seed,end,leaf,kid(rec,1),kid(disc,0),kid(call,2),a,b,c},u => P198ERefused{})

@unsafe
def w5c2_p123p_bin_if(hit: Bool, +name: String, +typ: N111Type, +op: String, +left: N111Value, +right: N111Value, +facts: KDef, +lf: P113KFact, +rf: P113KFact, +record: KDef) -> P113KScalar:
  match hit:
    case True{}:
      P113KScalar{[w5c2_p123p_bin_stmt(U32.is_eq(da(record), 0), name, nm(dv(record)))],
        p113k_put(facts, name, p113k_bin_fact(typ, op, lf, rf))}
    case False{}: p123p_old_bin(name, typ, op, left, right, facts, lf, rf)

@unsafe
def p123p_bin(+name: String, +typ: N111Type, +op: String, +left: N111Value, +right: N111Value, +facts: KDef, +lf: P113KFact, +rf: P113KFact, +record: KDef) -> P113KScalar:
  w5c2_p123p_bin_if(String.eq(dk(record), "P123Test"), name, typ, op, left, right, facts, lf, rf, record)


@unsafe
def p124r_terminal(+body: List<&2,N111Stmt>, +owner: String, +arity: U32, +ready: KDef,
    +target: String, callable: P124Callable) -> P114GBody:
  match callable:
    case P124Callable{valid,+count,+symbol}:
      nt_choose(P114GBody,valid && Bool.not(agy_str_eq(owner,target)) && p112t_tail(body,target,count,0),
        u => P114GBody{True{},[],p114h_scalars(p124r_call_nodes(body,count,symbol),[P114RResult{N111Local{"p114h_call_result"}}])},
        u => p114h_scan_frame(body,owner,arity,ready,p112f_frame(body,0,[])))

# Discovery does not prove admission: p114r_arguments checks the complete exact
# argument stores and terminal jump independently before a node is constructed.

@unsafe
def p124r_original_target(+body: List<&2,N111Stmt>, +owner: String, +arity: U32, +ready: KDef, +target: String) -> P114GBody:
  +count = da(p111v_get(ready,target))
  nt_choose(P114GBody,p112w_ready(ready,target) && Bool.not(agy_str_eq(owner,target)) && U32.is_le(count,8) && p112t_tail(body,target,count,0),
    u => p114h_call(body,target,count),u => p114h_scan_frame(body,owner,arity,ready,p112f_frame(body,0,[])))


@unsafe
def p125p_owner(+book: List<&2,KDef>, +ty: KTerm, +empty: String, +link: String) -> Bool:
  +h = wnf(book,ty)
  +owner = lookup(book,nm(h))
  +z = lookup(dc(owner),empty)
  +c = lookup(dc(owner),link)
  +tel = wnf(book,j_specialize(book,dt(c),ks(h)))
  +tail = wnf(book,kid(tel,1))
  p98_tag_eq(h,"ADT") && agy_str_eq(dk(owner),"ADT") &&
    j_pure_same_closed(book,h,h,64) && U32.is_eq(j_region_def_count(dc(owner)),2) &&
    Bool.not(agy_str_eq(empty,link)) && agy_str_eq(dk(z),"Ctr") && U32.is_eq(da(z),0) &&
    agy_str_eq(dk(c),"Ctr") && U32.is_eq(da(c),2) &&
    j_pure_same_closed(book,j_specialize(book,dt(z),ks(h)),h,64) &&
    p98_tag_eq(tel,"All") && U32.is_eq(qt(tel),1) &&
    p98_tag_eq(tail,"All") && U32.is_eq(qt(tail),1) &&
    j_pure_same_closed(book,kid(tail,0),h,64) &&
    j_pure_same_closed(book,kid(tail,1),h,64)


@unsafe
def p125p_types(+book: List<&2,KDef>, +d: KDef, +empty: String, +link: String) -> Bool:
  +ty = wnf(book,dt(d))
  +rest = wnf(book,kid(ty,1))
  +owner = wnf(book,kid(ty,0))
  p98_tag_eq(ty,"All") && U32.is_eq(qt(ty),1) &&
    p98_tag_eq(rest,"All") && U32.is_eq(qt(rest),1) &&
    j_pure_same_closed(book,kid(rest,0),owner,64) &&
    j_pure_same_closed(book,kid(rest,1),owner,64) && p125p_owner(book,owner,empty,link)


@unsafe
def p125p_import(+name: String, +typ: N111Type, +args: List<&2,N111Arg>, +schema: KDef, +live: KDef, +ids: N111Ids) -> P111VFlow:
  +empty = p111v_target(p111v_arg(args,3),ids,True{})
  +link = p111v_target(p111v_arg(args,4),ids,True{})
  p111v_step(U32.is_eq(p111v_type(typ),2) && p113e_runtime_args(args) &&
    p111v_args(args,[3,2,2,1,1],live,ids) &&
    Bool.not(agy_str_eq(dk(empty),"Absent")) && U32.is_eq(da(empty),0) &&
    Bool.not(agy_str_eq(dk(link),"Absent")) && U32.is_eq(da(link),2) &&
    Bool.not(agy_str_eq(dn(empty),dn(link))),name,schema,live,"concat value import signature/constructor mismatch")


law p126s_eval:
  for +book: List<&2,KDef>
  for +term: KTerm
  for +kind: String
  for +fuel: U32
  KTerm

@unsafe
def p126s_eval(book,term,kind,fuel):
  nt_choose(KTerm,U32.is_gt(fuel,0),u =>
    p126s_eval_next(book,j_strip(term),kind,U32.sub(fuel,1),p126s_atom(j_strip(term),kind)),u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})


@unsafe
def p126s_primitive_first(+book: List<&2,KDef>, +call: KTerm, +fuel: U32, +first: KTerm) -> KTerm:
  nt_choose(KTerm,core_literal(first),u =>
    nt_choose(KTerm,agy_str_eq(nm(call),"U32.to_f32"),u => p126s_result(nm(call),kl_number(first),0),u =>
      p126s_primitive_second(nm(call),first,p126s_eval(book,kid(call,1),"F32",fuel))),u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})


law p126s_helper_arg:
  for +book: List<&2,KDef>
  for +body: KTerm
  for +ty: KTerm
  for +arg: KTerm
  for +rest: List<&2,KTerm>
  for +kind: String
  for +fuel: U32
  KTerm

@unsafe
def p126s_helper_arg(book,body,ty,arg,rest,kind,fuel):
  +input = p126s_kind(book,kid(ty,0))
  nt_choose(KTerm,agy_str_eq(tg(body),"Lam") && U32.is_eq(terms_len(ks(body)),1) && agy_str_eq(j_l_name(body),"") &&
    agy_str_eq(tg(ty),"All") && Bool.not(U32.is_eq(qt(ty),0)) && Bool.not(String.is_empty(input)),u =>
      p126s_helper_value(book,body,ty,rest,kind,fuel,p126s_eval(book,arg,input,fuel)),u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})


@unsafe
def p126s_helper(+book: List<&2,KDef>, +body: KTerm, +ty: KTerm, +args: List<&2,KTerm>, +kind: String, +fuel: U32) -> KTerm:
  match args:
    case Nil{}:
      nt_choose(KTerm,agy_str_eq(p126s_kind(book,ty),kind),u => p126s_eval(book,body,kind,fuel),u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})
    case Con{arg,rest}: p126s_helper_arg(book,j_strip(body),wnf(book,ty),arg,rest,kind,fuel)


@unsafe
def p126s_helper_value(+book: List<&2,KDef>, +body: KTerm, +ty: KTerm, +rest: List<&2,KTerm>, +kind: String, +fuel: U32, +value: KTerm) -> KTerm:
  nt_choose(KTerm,core_literal(value),u =>
    p126s_helper(book,subst(kid(body,0),ix(body),value),subst(kid(ty,1),ix(ty),value),rest,kind,fuel),u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})


@unsafe
def p126s_call(+book: List<&2,KDef>, +call: KTerm, +kind: String, +fuel: U32) -> KTerm:
  +name = nm(call)
  +d = lookup(book,name)
  nt_choose(KTerm,agy_str_eq(kind,"F32") && String.contains("|U32.to_f32|F32.add|F32.sub|F32.mul|F32.div|","|" ++ name ++ "|") && j_primitive_call(book,call),
    u => p126s_primitive_first(book,call,fuel,p126s_eval(book,kid(call,0),j_primitive_input(name,0),fuel)),u =>
    nt_choose(KTerm,agy_str_eq(dk(d),"Def") && Bool.not(db(d) || nc_foreign(d)) && U32.is_eq(dx(d),0) &&
      U32.is_gt(da(d),0) && U32.is_le(da(d),2) && U32.is_eq(da(d),terms_len(ks(call))) && j_u32_bounded([dv(d)],64),
      u => p126s_helper(book,dv(d),dt(d),ks(call),kind,fuel),u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}))


@unsafe
def p126s_eval_spine(+book: List<&2,KDef>, +kind: String, +fuel: U32, +spine: KTerm) -> KTerm:
  nt_choose(KTerm,agy_str_eq(tg(spine),"Call"),u => p126s_call(book,spine,kind,fuel),u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})


@unsafe
def p126s_eval_next(+book: List<&2,KDef>, +term: KTerm, +kind: String, +fuel: U32, +value: KTerm) -> KTerm:
  nt_choose(KTerm,core_literal(value),u => value,u => p126s_eval_spine(book,kind,fuel,j_call_spine(term,[])))


law p126s_rows:
  for +book: List<&2,KDef>
  for +term: KTerm
  for +ty: KTerm
  for +kind: String
  for +left: U32
  Maybe<&2,List<&2,U32>>

@unsafe
def p126s_rows(book,term,ty,kind,left):
  +head = wnf(book,ty)
  nt_choose(Maybe<&2,List<&2,U32>>,U32.is_gt(left,0) && agy_str_eq(tg(head),"All") && Bool.not(U32.is_eq(qt(head),0)) &&
    j_primitive_type(book,wnf(book,kid(head,0)),"Nat"),u => p126s_rows_on(book,j_strip(term),head,kind,left),u => None{})


@unsafe
def p126s_row_first(+book: List<&2,KDef>, +term: KTerm, +ty: KTerm, +kind: String, +left: U32, +first: KTerm) -> Maybe<&2,List<&2,U32>>:
  nt_choose(Maybe<&2,List<&2,U32>>,core_literal(first),u =>
    p126s_cons(first,p126s_rows(book,kid(j_strip(kid(term,1)),0),j_arm_type(book,ty,"Succ"),kind,U32.sub(left,1))),u => None{})


@unsafe
def p126s_rows_on(+book: List<&2,KDef>, +term: KTerm, +ty: KTerm, +kind: String, +left: U32) -> Maybe<&2,List<&2,U32>>:
  +rest = j_strip(kid(term,1))
  nt_choose(Maybe<&2,List<&2,U32>>,agy_str_eq(tg(term),"Lam") && U32.is_eq(terms_len(ks(term)),1) && agy_str_eq(j_l_name(term),""),
    u => p126s_last(p126s_eval(book,kid(term,0),kind,8)),u =>
    nt_choose(Maybe<&2,List<&2,U32>>,agy_str_eq(tg(term),"Mat") && agy_str_eq(nm(term),"Zero") && U32.is_eq(terms_len(ks(term)),2) &&
      agy_str_eq(tg(rest),"Mat") && agy_str_eq(nm(rest),"Succ") && U32.is_eq(terms_len(ks(rest)),2) &&
      agy_str_eq(tg(j_strip(kid(rest,1))),"Efq") && U32.is_eq(terms_len(ks(j_strip(kid(rest,1)))),0),
      u => p126s_row_first(book,term,ty,kind,left,p126s_eval(book,kid(term,0),kind,8)),u => None{}))


@unsafe
def p126s_plan_result(+book: List<&2,KDef>, +d: KDef, +ty: KTerm, +kind: String) -> Maybe<&2,List<&2,U32>>:
  nt_choose(Maybe<&2,List<&2,U32>>,Bool.not(String.is_empty(kind)) && j_u32_bounded([dv(d)],4096),
    u => p126s_rows(book,dv(d),ty,kind,64),u => None{})


@unsafe
def p126s_plan_type(+book: List<&2,KDef>, +d: KDef, +ty: KTerm) -> Maybe<&2,List<&2,U32>>:
  nt_choose(Maybe<&2,List<&2,U32>>,agy_str_eq(tg(ty),"All") && Bool.not(U32.is_eq(qt(ty),0)) &&
    j_primitive_type(book,wnf(book,kid(ty,0)),"Nat"),
    u => p126s_plan_result(book,d,ty,p126s_kind(book,kid(ty,1))),u => None{})


@unsafe
def p126bp_original_functions(+book: List<&2,KDef>, +owner: String, +plan: NO_Plan) -> P118BWorkers:
  +schema = no_plan_schema(plan)
  +params = no_plan_params(no_schema_params(schema))
  +reader = p118b_lower(noa_body(no_plan_analysis(plan)),params,params,no_schema_specs_layouts(no_schema_specs(schema)),0)
  +result = no_schema_result(schema)
  +env : List<&2,NC_Binding> = Con{NC_Binding{result,"p118b_observation",N_W64{}},params}
  +wrapper = p118b_eval(no_schema_wrapper(schema),env,0)
  +adapter : List<&2,P113DStmt> = Con{P113DCall{["p118b_observation"],p118b_read_name(owner),p111_env_words(params)},
    nt_append(P113DStmt,p113d_body(wrapper),[P113DResult{[N111Local{p118b_value_name(0)}]}])}
  P118BWorkers{[
    P113DFunction{p118b_read_name(owner),params,1,False{},p113d_body(reader)},
    P113DFunction{p113d_public(book,owner),params,1,True{},adapter}],
    p111_first(p113d_error(reader),p113d_error(wrapper))}


@unsafe
def p126dp_original_primitive(+name: String, +values: List<&2,N111Value>, +wanted: KTerm, +n: U32) -> P113PValueCode:
  nt_choose(P113PValueCode,p113p_array_pair(name,nt_count(N111Value,values)) && p113p_known(wanted) && agy_str_eq(nm(wanted),"Tuple") && U32.is_eq(ix(wanted),2),
    u => p113p_pair_code(p111_op_id(name),values,n),
    u => nt_choose(P113PValueCode,p113p_known(wanted),
      v => P113PValueCode{[],[],"primitive product shape unsupported"},
      v => p113p_boxed(p113ai_intrinsic(name,values,n))))


@unsafe
def w5c2_p126dp_tup(ok: Bool, +book: List<&2,KDef>, +value: KTerm, +target: NC_Target) -> KTerm:
  match ok:
    case True{}: kt("NQShape", "Tuple", 2, 0, [])
    case False{}: nq_value_shape(book, value, target)

@unsafe
def p126dp_import(+name: String, +typ: N111Type, +args: List<&2,N111Arg>, +schema: KDef, +live: KDef, +ids: N111Ids) -> P111VFlow:
  p111v_step(U32.is_eq(p111v_type(typ),2) && p113e_runtime_args(args) &&
    p111v_args(args,[3,2,2,3],live,ids) && p111v_memory(p111v_arg(args,3),8,2,live,ids),
    name,schema,live,"Nat.divmod product import signature/output capacity mismatch")

@unsafe
def p126sc_candidates_counted(+candidates: List<&2,P113DCandidate>, +counts: KDef) -> List<&2,P113DCandidate>:
  p126sc_walk(candidates,p126sc_index(candidates,counts,P113IEmpty{}),counts,missing(),0,[])


@unsafe
def p126sc_candidates(+candidates: List<&2,P113DCandidate>) -> List<&2,P113DCandidate>:
  p126sc_candidates_counted(candidates,p126sc_counts(candidates,missing(),0))

@unsafe
def p128bs_functions(+book: List<&2,KDef>, +owner: String, +plan: NO_Plan, fallback: P113DFunction) -> P118BWorkers:
  match fallback:
    case P113DFunction{name,old_params,result,public,body}:
      +schema = no_plan_schema(plan)
      +params = no_plan_params(no_schema_params(schema))
      +roots = p128bs_roots(params,no_schema_roots(schema),0)
      +reader = p118b_lower(noa_body(no_plan_analysis(plan)),params,params,no_schema_specs_layouts(no_schema_specs(schema)),0)
      +yes : List<&2,P113DStmt> = Con{P113DCall{["p128bs_observation"],p118b_read_name(owner),p111_env_words(params)},
        nt_append(P113DStmt,p128bs_drops(roots,0),[P113DResult{[N111Local{"p128bs_observation"}]}])}
      +no : List<&2,P113DStmt> = [P113DCall{["p128bs_fallback"],p128bs_owned(owner),p111_env_words(params)},P113DResult{[N111Local{"p128bs_fallback"}]}]
      +adapter : List<&2,P113DStmt> = [P113DScalar{N111Call{"p128bs_borrow",N111U64{},"p118_rt_borrow_scalar_safe",p128bs_guard_args(roots)}},P113DScalar{N111Bin{"p128bs_condition",N111U64{},"ne",N111Local{"p128bs_borrow"},N111Const{0,0}}},P113DIf{N111Local{"p128bs_condition"},yes,no}]
      P118BWorkers{[
        P113DFunction{p128bs_owned(owner),old_params,result,False{},body},
        P113DFunction{p118b_read_name(owner),params,1,False{},p113d_body(reader)},
        P113DFunction{p113d_public(book,owner),params,1,True{},adapter}],p113d_error(reader)}


@unsafe
def p128br_arguments(+ctx: NO_Context, params: List<&2,KTerm>, +roots: List<&2,U32>, args: List<&2,KTerm>, +i: U32) -> Bool:
  match params args:
    case Nil{} Nil{}: True{}
    case Con{+param,rest} Con{+arg,more}:
      agy_str_eq(noa_value_type(ctx,arg),nm(param)) &&
        nt_choose(Bool,no_root_index(roots,i),
          u => agy_str_eq(tg(arg),"OA") && p128br_held(noa_origin(arg),
            no_schema_params(noa_schema(ctx)),no_schema_roots(noa_schema(ctx)),0),
          u => Bool.not(agy_str_eq(tg(noa_scalar(ctx,arg)),"Absent"))) &&
        p128br_arguments(ctx,rest,roots,more,U32.inc(i))
    case _ _: False{}


@unsafe
def p128br_words(+ctx: NO_Context, args: List<&2,KTerm>, +roots: List<&2,U32>, +i: U32) -> List<&2,KTerm>:
  match args:
    case Nil{}: []
    case Con{+arg,rest}:
      Con{nt_choose(KTerm,no_root_index(roots,i),u => kid(arg,1),u => noa_scalar(ctx,arg)),
        p128br_words(ctx,rest,roots,U32.inc(i))}


@unsafe
def p128br_apply(functions: List<&2,P113DFunction>, patches: List<&2,P128BRPatch>) -> List<&2,P113DFunction>:
  p128bi_walk(functions,patches,missing(),[])

@unsafe
def p128bl_pair(+book: List<&2,KDef>, +ty: KTerm, +nil: KDef, +cons: KDef) -> P128BLNode:
  +empty = nol_ctor_fields(book,ty,nil)
  +fields = nol_ctor_fields(book,ty,cons)
  nt_choose(P128BLNode,U32.is_eq(da(nil),0) && U32.is_ge(da(cons),2) &&
    agy_str_eq(tg(empty),"NO_Types") && agy_str_eq(tg(fields),"NO_Types") &&
    p128bl_recursive(ty,ks(fields),0),
    u => P128BLNode{[nol_spec(book,nm(ty),nil,"Nullary",[]),
      nol_spec(book,nm(ty),cons,"Boxed",ks(fields))],ks(fields),""},
    u => P128BLNode{[],[],"nested observer: constructor specialization or one recursive child"})


@unsafe
def p128bl_ctors(+book: List<&2,KDef>, +ty: KTerm, ctors: List<&2,KDef>) -> P128BLNode:
  match ctors:
    case Con{+a,Con{+b,Nil{}}}:
      nt_choose(P128BLNode,U32.is_eq(da(a),0),u => p128bl_pair(book,ty,a,b),u => p128bl_pair(book,ty,b,a))
    case _: P128BLNode{[],[],"nested observer: requires finite two-constructor spine"}


@unsafe
def p128bl_finish(+book: List<&2,KDef>, +params: List<&2,KTerm>, +roots: List<&2,U32>, +fresh: U32, +result: KTerm, graph: P128BLGraph) -> NO_Schema:
  match graph:
    case P128BLGraph{types,specs,+error}:
      nt_choose(NO_Schema,String.is_empty(error),
        u => NO_Schema{params,roots,var(nm(result),nc_id(fresh)),nc_id(fresh),nm(result),
          nt_append(NO_Spec,specs,nol_scalar_specs(book,book)),U32.inc(fresh),""},
        u => nol_failure(error,fresh))


@unsafe
def p131rg_visible(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  nol_scalar(book,ty) || Bool.not(List.is_empty(&2,NO_Spec,nol_root_specs(book,ty)))


law p131rv_value:
  for +ctx: NO_Context
  for +value: KTerm
  for +wanted: String
  for +fuel: U32
  Bool

@unsafe
def p131rv_value(ctx,value,wanted,fuel):
  nt_choose(Bool,U32.is_eq(fuel,0),u => False{},u =>
    nt_choose(Bool,agy_str_eq(tg(value),"OC"),
      v => p131rv_constructor(ctx,value,wanted,U32.sub(fuel,1),noa_spec(nm(value),no_schema_specs(noa_schema(ctx)))),
      v => agy_str_eq(tg(value),"OA") && agy_str_eq(nm(value),wanted) &&
        (Bool.not(agy_str_eq(tg(noa_scalar(ctx,value)),"Absent")) ||
          p128br_held(noa_origin(value),no_schema_params(noa_schema(ctx)),no_schema_roots(noa_schema(ctx)),0))))


@unsafe
def p131rv_fields(+ctx: NO_Context, values: List<&2,KTerm>, types: List<&2,String>, +fuel: U32) -> Bool:
  match values types:
    case Nil{} Nil{}: True{}
    case Con{value,rest} Con{ty,more}:
      p131rv_value(ctx,value,ty,fuel) && p131rv_fields(ctx,rest,more,fuel)
    case _ _: False{}


@unsafe
def p131rv_constructor(+ctx: NO_Context, +value: KTerm, +wanted: String, +fuel: U32, spec: Maybe<&2,NO_Spec>) -> Bool:
  match spec:
    case None{}: False{}
    case Some{NO_Spec{NO_Layout{key,ctor,storage,+width},owner,+fields}}:
      agy_str_eq(owner,wanted) && U32.is_eq(width,terms_len(ks(value))) &&
        U32.is_eq(width,nt_count(String,fields)) && p131rv_fields(ctx,ks(value),fields,fuel)


@unsafe
def p131rv_arguments(+ctx: NO_Context, params: List<&2,KTerm>, +roots: List<&2,U32>, args: List<&2,KTerm>, +i: U32, +virtual: Bool) -> Bool:
  match params args:
    case Nil{} Nil{}: virtual
    case Con{+param,rest} Con{+arg,more}:
      agy_str_eq(noa_value_type(ctx,arg),nm(param)) &&
        nt_choose(Bool,no_root_index(roots,i),
          u => p131rv_value(ctx,arg,nm(param),16),
          u => Bool.not(agy_str_eq(tg(noa_scalar(ctx,arg)),"Absent"))) &&
        p131rv_arguments(ctx,rest,roots,more,U32.inc(i),virtual || (no_root_index(roots,i) && agy_str_eq(tg(arg),"OC")))
    case _ _: False{}


@unsafe
def p134e_registered(+segments: List<&2,N111Segment>, +functions: List<&2,P113DFunction>, +ids: N111Ids, +index: P112FusionIndex,
    +heap: U32, +mode: U32, +tables: List<&2,P111QData>, registry: P112RegionRegistry) -> P134Cursor:
  match registry:
    case P112RegionRegistry{+ready,symbols,+entries,workers,fusions}:
      +direct = p113e_signatures(functions,missing())
      +lookups = nt_choose(List<&2,P126ITable>,U32.is_eq(mode,2),u => p126i_catalogue(functions,[]),u => [])
      +ids = p185cb_bind(ids,tables)
      +context : P134Context = P134Context{ids,index,direct,ready,p124r_view(ready,direct),lookups,heap,mode}
      +public : P134Cursor = P134Public{segments,context,P134Tables{tables}}
      +legacy = nt_choose(P134Cursor,List.is_empty(&2,N111Segment,segments),u => public,
        u => P134Legacy{nt_reverse(P112RegionEntry,entries,[]),context,public})
      P134Private{functions,context,legacy}

@unsafe
def w7b_p142j_def_if(live: Bool, +book: List<&2,KDef>, +d: KDef, +todo: List<&2,String>) -> List<&2,String>:
  match live:
    case True{}: jl_term(book,dv(d),todo)
    case False{}: todo

@unsafe
def p143cp_put(+book: List<&2,KDef>, +definition: KDef, +logging: Bool) -> List<&2,KDef>:
  nt_choose(List<&2,KDef>,logging,
    u => p143cp_put_log(book,definition),u => book_put(book,definition))


@unsafe
def p143cp_put_log(+book: List<&2,KDef>, +definition: KDef) -> List<&2,KDef>:
  match book:
    case Nil{}: book_put(book,definition)
    case Con{+cache,+rest}:
      nt_choose(List<&2,KDef>,p88_string_eq(dk(cache),"BookCache") &&
        p143cp_childless(definition) && p143cp_childless(index_lookup(cache,dn(definition))),
        u => p143cp_logged(cache,rest,definition),
        u => book_put(p143cp_canon(book),definition))


@unsafe
def p143cp_world(world: KWorld) -> KWorld:
  match world:
    case KWorld{book,memo,fresh,checked}: KWorld{p143cp_canon(book),memo,fresh,checked}


@unsafe
def p143cp_result(checked: DChecking, logging: Bool) -> DChecking:
  match checked logging:
    case DChecking{KChecking{term,typ,uses,error,world,consumed},diagnostic} True{}:
      DChecking{KChecking{term,typ,uses,error,p143cp_world(world),consumed},diagnostic}
    case result False{}: result


@unsafe
def w7c_declare_head(isCache: Bool, +todo: List<&2,KDef>, +cache: KDef, +rows: List<&2,KDef>, +done: List<&2,KDef>) -> List<&2,KDef>:
  match isCache:
    case True{}:
      Con{KDef{dn(cache), dk(cache), da(cache), 0,
        {KTerm{"Absent","",0,0,Nil{},Nil{},0,0} : KTerm}, {KTerm{"Absent","",0,0,Nil{},Nil{},0,0} : KTerm},
        w7c_declare_loop(todo, index_first(dc(cache)), w7c_init_ctors(dc(cache), rows)),
        True{}, False{}}, rows}
    case False{}:
      check_declarations(todo, done)

@unsafe
def p143nr_begin(+book: List<&2,KDef>, +todo: List<&2,String>, +done: List<&2,String>, +facts: List<&2,KDef>) -> NR_Closure:
  p143nr_walk(book,todo,done,facts,p142j_members(done,missing()))


@unsafe
def p143nr_walk(+book: List<&2,KDef>, todo: List<&2,String>, +done: List<&2,String>, +facts: List<&2,KDef>, +seen: KDef) -> NR_Closure:
  match todo:
    case Nil{}: NR_Closure{done,facts}
    case Con{+name,+rest}:
      p143nr_name(book,name,rest,done,facts,seen,index_hash(name,2166136261))


@unsafe
def p143nr_name(+book: List<&2,KDef>, +name: String, +todo: List<&2,String>, +done: List<&2,String>, +facts: List<&2,KDef>, +seen: KDef, +hash: U32) -> NR_Closure:
  nt_choose(NR_Closure,p142j_member(seen,name,hash),
    u => p143nr_walk(book,todo,done,facts,seen),
    u => p143nr_visit(book,name,todo,done,facts,p142j_mark(seen,name,hash),lookup(book,name)))


@unsafe
def p143nr_visit(+book: List<&2,KDef>, +name: String, +todo: List<&2,String>, +done: List<&2,String>, +facts: List<&2,KDef>, +seen: KDef, +d: KDef) -> NR_Closure:
  +body = nc_definition_plain(book,d,0)
  +more = nt_choose(List<&2,KDef>,p88_string_eq(dk(d),"Def") && Bool.not(nc_native_def(d) || nc_foreign(d)),
    u => Con{KDef{name,"NativeErasedBody",U32.max(nd_leading(dv(d), 0), jd_live_arity(book, dt(d), jd_arity(book, d))),1,{KTerm{"Absent","",0,0,[],[],0,0}:KTerm},body,[],False{},False{}},facts},u => facts)
  p143nr_walk(book,nt_reverse(String,w7c_refs_term(body,Nil{}),todo),Con{name,done},more,seen)

@unsafe
def p144o_view(+book: List<&2,KDef>, +facts: P144OFacts) -> List<&2,KDef>:
  match book:
    case Con{+cache,+rest}:
      nt_choose(List<&2,KDef>,p88_string_eq(dk(cache),"BookCache"),
        u => Con{KDef{dn(cache),dk(cache),da(cache),dx(cache),dt(cache),dv(cache),
          [index_first(dc(cache)),KDef{"$native.static","NativeStaticContext",0,0,
            KTerm{"NativeImage","",0,0,[],[],0,0},KTerm{"Absent","",0,0,[],[],0,0},
            [missing(),p144o_ctor_carrier(nc_ctor_prepare(book),facts)],False{},False{}}],db(cache),du(cache)},rest},
        u => book)
    case Nil{}: []


@unsafe
def p144o_request(+source: List<&2,KDef>, view: List<&2,KDef>, closure: NR_Closure, bound: Maybe<&2,U32>) -> NR_Request:
  match closure:
    case NR_Closure{+names,facts}:
      NR_Request{source,ns_attach_book(view,facts,0,[]),names,nc_paths_of(source,names),kr_filter(source,names),bound}


@unsafe
def p144ce_disjoint(+defs: List<&2,KDef>, +context: List<&2,KDef>) -> Bool:
  match defs:
    case Nil{}: True{}
    case _: p144ce_disjoint_go(defs,context,p144ce_build(context))


@unsafe
def p164a_allowed(+book: List<&2,KDef>, +source: String, +bangs: List<&2,String>, +ready: KDef) -> Bool:
  +definition = lookup(book,source)
  +arity = nd_arity(book,source)
  +signature = p111v_get(ready,p113d_public(book,source))
  agy_str_eq(dk(definition),"Def") && Bool.not(nc_native_def(definition) || nc_foreign(definition) || nb_contains(bangs,source)) &&
    U32.is_le(arity,64) && agy_str_eq(dk(signature),"P113Direct") &&
    U32.is_eq(da(signature),arity) && U32.is_eq(dx(signature),1) && U32.is_eq(ix(dv(signature)),1)



# Exact fixed-shape recognizer for later emission ONLY. Admission uses the
# explicit source-bound map plus independent source/header/direct checks.
@unsafe
def p167l_stmts(body: List<&2,N111Stmt>, demand: P167Demand) -> P167Demand:
  match body:
    case Nil{}: demand
    case Con{head,rest}: p167l_stmts(rest,p167l_stmt(head,demand))



@unsafe
def p167l_stmt(stmt: N111Stmt, demand: P167Demand) -> P167Demand:
  match stmt:
    case N111Set{name,typ,value}: p167l_value(value,demand)
    case N111Bin{name,typ,op,left,right}: p167l_value(right,p167l_value(left,demand))
    case N111Call{name,typ,symbol,args}: p167l_args(args,demand)
    case N111If{condition,yes,no}: p167l_stmts(no,p167l_stmts(yes,p167l_value(condition,demand)))
    case N111Return{value}: p167l_value(value,demand)
    case N111Load{name,typ,base,offset}: p167l_value(base,demand)
    case N111Store{typ,base,offset,value}: p167l_value(value,p167l_value(base,demand))
    case N111Offset{name,base,bytes}: p167l_value(bytes,p167l_value(base,demand))
    case N111Alloca{name,bytes,align}: demand



@unsafe
def p167l_direct(body: List<&2,P113DStmt>, demand: P167Demand) -> P167Demand:
  match body:
    case Nil{}: demand
    case Con{head,rest}: p167l_direct(rest,p167l_direct_stmt(head,demand))



@unsafe
def p167l_direct_stmt(stmt: P113DStmt, demand: P167Demand) -> P167Demand:
  match stmt:
    case P113DScalar{scalar}: p167l_stmt(scalar,demand)
    case P113DIf{condition,yes,no}: p167l_direct(no,p167l_direct(yes,p167l_value(condition,demand)))
    case P113DCall{destinations,target,args}: p167l_values(args,demand)
    case P113DResult{values}: p167l_values(values,demand)
    case P113DAgain{values}: p167l_values(values,demand)



@unsafe
def p167l_function_demands(functions: List<&2,P113DFunction>, demand: P167Demand) -> P167Demand:
  match functions:
    case Nil{}: demand
    case Con{P113DFunction{name,params,result,public,body},rest}:
      p167l_function_demands(rest,p167l_direct(body,demand))



# Static P112SWord is Raw/Packed/Box, and contains no function-ID variant.
# Every node is retained and independently checked against the actual schema.
@unsafe
def p167l_segment_demands(segments: List<&2,N111Segment>, demand: P167Demand) -> P167Demand:
  match segments:
    case Nil{}: demand
    case Con{N111Segment{name,arity,result,incoming,flags,body},rest}:
      p167l_segment_demands(rest,p167l_stmts(body,demand))



law w6_dedup_round:
  for +segs: List<&2,N111Segment>
  for +rounds: U32
  List<&2,N111Segment>

@unsafe
def w6_dedup_finish(acc: W6DedupAcc, +next_rounds: U32) -> List<&2,N111Segment>:
  match acc:
    case W6DedupAcc{seen,+alias,+kept,+merged}:
      +ordered = nt_reverse(N111Segment,kept,[])
      nt_choose(List<&2,N111Segment>,U32.is_eq(merged,0),
        u => ordered,
        u => w6_dedup_round(w6_rw_segs(alias,ordered,[]),next_rounds))

@unsafe
def w6_dedup_round(segs, rounds):
  nt_choose(List<&2,N111Segment>,U32.is_eq(rounds,0),u => segs,u =>
    w6_dedup_finish(w6_dedup_scan(segs,W6DedupAcc{missing(),missing(),[],0}),U32.sub(rounds,1)))

@unsafe
def w6_dedup_segments(segs: List<&2,N111Segment>) -> List<&2,N111Segment>:
  w6_dedup_round(segs,1)

# === END AGY-W6 ===


@unsafe
def p167v_allowed(+book: List<&2,KDef>, +source: String, +bangs: List<&2,String>, +ready: KDef) -> Bool:
  +definition = lookup(book,source)
  +arity = nd_arity(book,source)
  +signature = p111v_get(ready,p113d_public(book,source))
  agy_str_eq(dk(definition),"Def") && Bool.not(nc_native_def(definition) || nc_foreign(definition) || nb_contains(bangs,source)) &&
    U32.is_le(arity,64) && agy_str_eq(dk(signature),"P113Direct") &&
    U32.is_eq(da(signature),arity) && U32.is_eq(dx(signature),1) && U32.is_eq(ix(dv(signature)),0)



# Independent mixed original boundary. Generic bodies still use the unchanged
# verifier. Exact adapters are checked against source, headers AND final workers.
@unsafe
def w7_pre_build_set(+book: List<&2,KDef>, xs: List<&2,String>, +bangs: List<&2,String>, +acc: KDef) -> KDef:
  match xs:
    case Nil{}: acc
    case Con{+name,+rest}:
      +d = lookup(book,name)
      nt_choose(KDef,agy_str_eq(dk(d),"Def") && Bool.not(nc_native_def(d) || nc_foreign(d) || nb_contains(bangs,name)) && U32.is_le(nd_arity(book,name),64),
        u => w7_pre_build_set(book,rest,bangs,p111v_put(acc,name,"W7Rem",1,0)),
        u => w7_pre_build_set(book,rest,bangs,acc))

@unsafe
def w7_filter_remaining(+book: List<&2,KDef>, +remaining: List<&2,String>, +bangs: List<&2,String>) -> List<&2,String>:
  +remSet = w7_pre_build_set(book,remaining,bangs,missing())
  w7_pre_peel(w7_pre_nodes(book,remaining,remSet,[]),missing(),[],32)

@unsafe
def w7c_p112c_fused(+cand: P112MultiCandidate, segment: N111Segment, +old: KDef, +symbols: KDef, +rank: U32,
    +next: P112RegionRegistry, +waiting: List<&2,P112MultiCandidate>, +added: U32, fused: P112FusionBody) -> W7C112CPass:
  match segment fused:
    case N111Segment{+name,+arity,+result,+incoming,+flags,+original} P112FusionBody{+body,+count,+site}:
      +transformed : N111Segment = N111Segment{name,arity,result,incoming,flags,body}
      +plan = p112c_plan(transformed,old,symbols,count)
      w7c_p112c_try_admit(p112w_admitted(plan),cand,transformed,rank,count,next,plan,waiting,added)

@unsafe
def p169s_registered(+segments: List<&2,N111Segment>, +functions: List<&2,P113DFunction>,
    ids: N111Ids, index: P112FusionIndex, heap: U32, mode: U32,
    tables: List<&2,P111QData>, +registry: P112RegionRegistry) -> P169Prepared:
  match registry:
    case P112RegionRegistry{ready,symbols,entries,workers,fusions}:
      P169Prepared{p168j_forwards(functions,ready,[]),
        p134e_registered(segments,functions,ids,index,heap,mode,tables,registry),""}



# Same ids, full fusion index, seeded discovery and capabilities as p168j_seeded.
# Only p134e_collect_cursor has moved out of the preparation boundary.
@unsafe
def p169q_selection(+book: List<&2,KDef>, plans: List<&2,P169ScalarPlan>,
    blocked: KDef, +targets: KDef) -> P168TSelection:
  match plans:
    case Nil{}: P168TSelection{blocked,targets}
    case Con{P169ScalarPlan{plan,eligible},rest}:
      +owner = p113d_public(book,no_plan_owner(plan))
      p169q_selection(book,rest,p167l_mark(blocked,owner),
        nt_choose(KDef,eligible,u => p167l_mark(targets,owner),u => targets))



law p171s_put:
  for +seen: List<&2,KDef>
  for +definition: KDef
  List<&2,KDef>

# These are the only two maintained declarations overridden in the experiment.
@unsafe
def w7c_p171s_put_step(isCache: Bool, +cache: KDef, +rows: List<&2,KDef>, +seen: List<&2,KDef>, +definition: KDef) -> List<&2,KDef>:
  match isCache:
    case True{}: p171s_cached(cache, rows, definition)
    case False{}: book_put(seen, definition)

@unsafe
def p171s_put(seen,definition):
  match seen:
    case Nil{}: book_put(seen,definition)
    case Con{+cache,+rows}:
      w7c_p171s_put_step(p88_string_eq(dk(cache),"BookCache"), cache, rows, seen, definition)
# Private nested schemas omit only the request-global scalar suffix.
# The retry loop attaches the genuine immutable catalogue lazily, once.

@unsafe
def p186sf_retry(+body: List<&2,N111Stmt>, +owner: String, +arity: U32, +ready: KDef, frame: Maybe<&2,P112FusionFrame>) -> P114GBody:
  match frame:
    case Some{P112FusionFrame{captures,name,dest,tail}}:
      +count = nt_count(N111Value,captures)
      nt_choose(P114GBody,U32.is_le(count,8),
        u => p186sf_push(p114r_prefix(body,U32.inc(count)),name,count,p114h_scan(tail,owner,arity,ready)),
        u => P114GBody{False{},[],[]})
    case None{}: P114GBody{False{},[],[]}

@unsafe
def p186sf_selected(+body: List<&2,N111Stmt>, +owner: String, +arity: U32, +ready: KDef, +frame: Maybe<&2,P112FusionFrame>, +previous: P114GBody) -> P114GBody:
  match previous:
    case P114GBody{+valid,frames,lowered}:
      nt_choose(P114GBody,valid,u => P114GBody{valid,frames,lowered},
        u => p186sf_retried(previous,p186sf_retry(body,owner,arity,ready,frame)))

@unsafe
def p186sf_frame(+body: List<&2,N111Stmt>, +owner: String, +arity: U32, +ready: KDef, +frame: Maybe<&2,P112FusionFrame>) -> P114GBody:
  p186sf_selected(body,owner,arity,ready,frame,p186sf_previous_frame(body,owner,arity,ready,frame))
# Machine object boundary. Bytes are U32 values restricted to0..255. Registers
# use architectural encoding numbers; byte registers4..7 mean spl/bpl/sil/dil,
# never ah/ch/dh/bh. Displacements/addends carry exact two's-complement bits.
law x181_frame:
  for +symbol: String
  for +params: List<&2,String>
  for +body: List<&2,P113DStmt>
  X181Frame
law x185_dead_body:
  for +setup: List<&2,P113DStmt>
  for +body: List<&2,P113DStmt>
  List<&2,P113DStmt>

law x185_physical_binary:
  for name: String
  for +typ: N111Type
  for +op: String
  for +left: N111Value
  for +right: N111Value
  for +ids: N111Ids
  for +frame: X181Frame
  X188Seq

# Typed late address-selection plans, declared before emission modules.
@unsafe
def x181_frame(symbol,params,body):
  +stateKind = nt_choose(String,w4_body_uses_state(body),u => "X181Register",u => "X181UnusedState")
  +initial: X181Frame = X181Frame{p111v_put(missing(),"state",stateKind,0,8),40,0,params,symbol}
  +homes = x181_frame_names(params,initial)
  +scratch = x181_frame_buffer("scratch",2048,16,homes)
  +results = x181_frame_buffer("__x181_results",64,16,scratch)
  +framed = x181_frame_stmts(body,x181_frame_buffer("__x181_tail",
    nt_choose(U32,List.is_empty(&2,String,params),u => 8,u => U32.mul(nt_count(String,params),8)),8,results))
  agy_mark_bounded_frame(symbol,body,framed)
# Exact shared admission for the F32 machine expansion. An admitted operation
# reads two U64 cells at buffer+0 and buffer+8, then writes one U64 local. It
# never writes/escapes memory or calls a helper. Its only machine clobbers are
# reserved r10/r11, xmm0/xmm1 and flags; transient/callee-saved homes survive.
# All consumers use this constructor rather than rediscovering the call shape.
# These effects describe already verified IR; they do not bypass its verifier.
@unsafe
def x195s_original(stmt: N111Stmt, ids: N111Ids, frame: X181Frame, code: X181Code) -> X181Code:
  match stmt:
    case N111Call{name,typ,symbol,args}: x195s_previous(name,typ,symbol,args,ids,frame,code)
    case _: x181_error("sqrt specialization expected scalar call",code)

# Match the retained runtime exactly: zero > input uses ordered JA, so negative
# finite/infinite inputs call sqrtf; +/-0 and NaNs remain on the SQRTSS path.
@unsafe
def x195s_expand(name: String, buffer: String, stmt: N111Stmt,
    +ids: N111Ids, +frame: X181Frame, +code: X181Code) -> X181Code:
  match code:
    case X181Code{chunks,+next,terminal,error}:
      nt_choose(X181Code,U32.is_le(next,4294967293),u =>
        X181Code{Con{x195s_text(name,buffer,ids,frame,next),chunks},U32.add(next,2),terminal,error},
        u => x195s_original(stmt,ids,frame,code))

@unsafe
def x195s_selected(pick: Maybe<&2,X195Sqrt>, stmt: N111Stmt,
    ids: N111Ids, frame: X181Frame, code: X181Code) -> X181Code:
  match pick:
    case Some{X195Sqrt{name,buffer}}: x195s_expand(name,buffer,stmt,ids,frame,code)
    case None{}: x195s_original(stmt,ids,frame,code)

@unsafe
def agy_rt_inline_fallback(name: String, typ: N111Type, symbol: String, args: List<&2,N111Arg>,
    ids: N111Ids, frame: X181Frame, code: X181Code) -> X181Code:
  +stmt: N111Stmt = N111Call{name,typ,symbol,args}
  x195s_selected(x195s_pick(x195s_enabled(),stmt),stmt,ids,frame,code)


# ============================================================================
# AGY-W2B-1: Perceus Static In-Place Reuse (takeN -> ctorM same-class fusion)
# ============================================================================

@unsafe
def x181_binary(+name: String, +typ: N111Type, +op: String,
    +left: N111Value, +right: N111Value, +ids: N111Ids,
    +frame: X181Frame, +code: X181Code) -> X181Code:
  +instruction = x181_bin_instruction(typ,op)
  +immediate = nt_choose(X188Seq,x185_machine_enabled(),u => x185_immediate(typ,op,x185_id_to_const(right,ids)),u => X188Empty{})
  +physical = x185_physical_binary(name,typ,op,left,right,ids,frame)
  nt_choose(X181Code,x188_empty(instruction),u => x181_error("unsupported x181 binary operation: " ++ op,code),u =>
    nt_choose(X181Code,Bool.not(x188_empty(physical)),v => x181_add(physical,code),v =>
      x181_add(x188_many([x181_load(left,ids,frame,x188_reg(10,64)),
        nt_choose(X188Seq,x188_empty(immediate),w => x188_cat(x181_load(right,ids,frame,x188_reg(11,64)),instruction),w => immediate),
        x181_store(name,frame,x188_reg(10,64))]),code)))

law x181_reads_scalars:
  for body: List<&2,N111Stmt>
  for counts: X181ReadCounts
  X181ReadCounts

@unsafe
def x181_reads_name(+name: String, +counts: X181ReadCounts) -> X181ReadCounts:
  w5b_reads_name_go(x181_register_reserved(name),name,counts)

@unsafe
def x181_reads_value(value: N111Value, counts: X181ReadCounts) -> X181ReadCounts:
  match value:
    case N111Local{name}: x181_reads_name(name,counts)
    case _: counts

@unsafe
def x181_reads_values(values: List<&2,N111Value>, counts: X181ReadCounts) -> X181ReadCounts:
  match values:
    case Nil{}: counts
    case Con{head,rest}: x181_reads_values(rest,x181_reads_value(head,counts))

@unsafe
def x181_reads_args(args: List<&2,N111Arg>, counts: X181ReadCounts) -> X181ReadCounts:
  match args:
    case Nil{}: counts
    case Con{N111Arg{typ,value},rest}: x181_reads_args(rest,x181_reads_value(value,counts))

# Encounter order is source order, operands left-to-right, then condition,
# yes branch and no branch. Each syntactic read counts once, even in a loop.
@unsafe
def x181_reads_scalar(stmt: N111Stmt, counts: X181ReadCounts) -> X181ReadCounts:
  match stmt:
    case N111Set{name,typ,value}: x181_reads_value(value,counts)
    case N111Bin{name,typ,op,left,right}:
      x181_reads_value(right,x181_reads_value(left,counts))
    case N111Call{name,typ,symbol,args}: x181_reads_args(args,counts)
    case N111If{condition,yes,no}:
      x181_reads_scalars(no,x181_reads_scalars(yes,x181_reads_value(condition,counts)))
    case N111Return{value}: x181_reads_value(value,counts)
    case N111Load{name,typ,base,offset}: x181_reads_value(base,counts)
    case N111Store{typ,base,offset,value}:
      x181_reads_value(value,x181_reads_value(base,counts))
    case N111Offset{name,base,bytes}:
      x181_reads_value(bytes,x181_reads_value(base,counts))
    case N111Alloca{name,bytes,align}: counts

@unsafe
def x181_reads_scalars(body,counts):
  match body:
    case Nil{}: counts
    case Con{head,rest}: x181_reads_scalars(rest,x181_reads_scalar(head,counts))

@unsafe
def x190_register_counted(+frame: X181Frame, reads: X181ReadCounts,
    writes: KDef, policy: U32) -> X181Frame:
  match frame reads:
    case X181Frame{slots,bytes,calls,+params,symbol} X181ReadCounts{counts,+reversedNames}:
      x181_register_counted(frame,X181ReadCounts{
        x190_register_scores(reversedNames,writes,params,policy,counts),reversedNames})

@unsafe
def x185_copy_writes(body: List<&2,P113DStmt>, counts: KDef) -> KDef:
  match body:
    case Nil{}: counts
    case Con{P113DScalar{stmt},rest}: x185_copy_writes(rest,x185_copy_writes_scalar(stmt,counts))
    case Con{P113DIf{condition,yes,no},rest}: x185_copy_writes(rest,x185_copy_writes(no,x185_copy_writes(yes,counts)))
    case Con{P113DCall{destinations,target,args},rest}: x185_copy_writes(rest,x185_copy_writes_names(destinations,counts))
    case Con{head,rest}: x185_copy_writes(rest,counts)

@unsafe
def x185_copy_function(+params: List<&2,String>, +setup: List<&2,P113DStmt>, +body: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  nt_choose(List<&2,P113DStmt>,x185_copy_enabled() && U32.is_lt(p113i_add(p113i_size(setup),p113i_size(body)),4096),
    u => agy_x185_copy_apply(body,x185_copy_aliases(body,
      x185_copy_writes(body,x185_copy_writes(setup,x185_copy_writes_names(params,missing()))),params,missing())),
    u => body)

# Reuse the established word-width/constant facts after aliases have gone.
# Facts start empty at the loop body: entry-only setup facts must not assert
# properties of parameters changed by Again. The second copy pass removes
# identities introduced by the existing simplifier, under the same restrictions.
@unsafe
def w5b_te_absent(isAbs: Bool, +name: String, +write: Bool, +old: KDef, +ranges: KDef, +names: List<&2,String>, +position: U32, +region: U32, +scan: X185TScan) -> X185TScan:
  match isAbs:
    case True{}: w5b_te_wr(write,name,ranges,names,position,region,scan)
    case False{}: w5b_te_is_rng(String.eq(dk(old),"X185TRange"),name,old,ranges,names,position,region,scan)

@unsafe
def w5b_te_res(res: Bool, +name: String, +write: Bool, +ranges: KDef, +names: List<&2,String>, +position: U32, +region: U32, +scan: X185TScan) -> X185TScan:
  match res:
    case True{}: scan
    case False{}:
      +old = p111v_get(ranges,name)
      w5b_te_absent(String.eq(dk(old),"Absent"),name,write,old,ranges,names,position,region,scan)

@unsafe
def x185_t_event(+name: String, +write: Bool, +scan: X185TScan) -> X185TScan:
  match scan:
    case X185TScan{+ranges,+names,+position,+region}:
      w5b_te_res(x181_register_reserved(name),name,write,ranges,names,position,region,scan)

@unsafe
def x185_t_chosen(name: String, +rest: List<&2,String>, +ranges: KDef, +frame: X181Frame,
    +ends: List<&2,U32>, +index: U32, +last: U32) -> X181Frame:
  nt_choose(X181Frame,U32.is_lt(index,5),
    u => x185_t_place(rest,ranges,x185_t_install(name,index,frame),x185_t_end(ends,index,last)),
    u => x185_t_place(rest,ranges,frame,ends))

@unsafe
def x185_d_values(values: List<&2,N111Value>, live: KDef) -> KDef:
  match values:
    case Nil{}: live
    case Con{head,rest}: x185_d_values(rest,x185_d_value(head,live))

@unsafe
def x185_d_args(args: List<&2,N111Arg>, live: KDef) -> KDef:
  match args:
    case Nil{}: live
    case Con{N111Arg{typ,value},rest}: x185_d_args(rest,x185_d_value(value,live))

@unsafe
def x185_d_union_bucket(bucket: List<&2,KDef>, out: KDef) -> KDef:
  match bucket:
    case Nil{}: out
    case Con{+head,rest}:
      x185_d_union_bucket(rest,w5b_d_mark_if(U32.is_gt(da(head),0),head,out))

@unsafe
def x185_d_base() -> KDef:
  x185_d_names(["state","scratch","__x181_result_out","__x181_results","__x181_tail"],missing())

@unsafe
def x185_d_pure(stmt: N111Stmt, +name: String, reads: List<&2,N111Value>, +after: X185Dead) -> X185Dead:
  match after:
    case X185Dead{body,+live}:
      nt_choose(X185Dead,U32.is_gt(da(p111v_get(live,name)),0) || x181_register_reserved(name),
        u => X185Dead{Con{P113DScalar{stmt},body},x185_d_values(reads,x185_d_kill(live,name))},
        u => after)

law x185_d_body:
  for body: List<&2,P113DStmt>
  for live: KDef
  for +again: KDef
  for +terminal: KDef
  X185Dead

@unsafe
def x185_d_if(condition: N111Value, yes: List<&2,P113DStmt>, no: List<&2,P113DStmt>,
    after: X185Dead, +again: KDef, +terminal: KDef) -> X185Dead:
  match after:
    case X185Dead{body,+live}:
      x185_d_if_done(condition,body,x185_d_body(yes,live,again,terminal),x185_d_body(no,live,again,terminal))

@unsafe
def x185_d_if_done(+condition: N111Value, rest: List<&2,P113DStmt>, yes: X185Dead, no: X185Dead) -> X185Dead:
  match yes no:
    case X185Dead{Nil{},yl} X185Dead{Nil{},nl}:
      X185Dead{rest,x185_d_union(yl,nl)}
    case X185Dead{yb,yl} X185Dead{nb,nl}:
      X185Dead{Con{P113DIf{condition,yb,nb},rest},x185_d_value(condition,x185_d_union(yl,nl))}

@unsafe
def x185_d_scalar(+stmt: N111Stmt, after: X185Dead, +again: KDef, +terminal: KDef) -> X185Dead:
  match stmt after:
    case N111Set{+name,typ,value} _: x185_d_pure(stmt,name,[value],after)
    case N111Bin{+name,typ,op,left,right} _: x185_d_pure(stmt,name,[left,right],after)
    case N111Offset{+name,base,bytes} _: x185_d_pure(stmt,name,[base,bytes],after)
    case N111Call{+name,typ,symbol,args} X185Dead{body,live}:
      X185Dead{Con{P113DScalar{stmt},body},x185_d_args(args,x185_d_kill(live,name))}
    case N111Load{+name,typ,base,offset} X185Dead{+body,+live}:
      nt_choose(X185Dead,
        U32.is_eq(da(p111v_get(live,name)),0) && String.starts_with(name,"p113a_") && String.ends_with(name,"_old"),
        u => X185Dead{body,live},
        u => X185Dead{Con{P113DScalar{stmt},body},x185_d_value(base,x185_d_kill(live,name))})
    case N111Store{typ,base,offset,value} X185Dead{body,live}:
      X185Dead{Con{P113DScalar{stmt},body},x185_d_value(value,x185_d_value(base,live))}
    case N111Alloca{name,bytes,align} X185Dead{body,live}:
      X185Dead{Con{P113DScalar{stmt},body},x185_d_kill(live,name)}
    case N111If{condition,yes,no} _:
      x185_d_if(condition,x181_scalar_rows(yes),x181_scalar_rows(no),after,again,terminal)
    case N111Return{value} X185Dead{body,live}:
      X185Dead{Con{P113DScalar{stmt},body},x185_d_value(value,terminal)}

@unsafe
def x185_d_stmt(+stmt: P113DStmt, after: X185Dead, +again: KDef, +terminal: KDef) -> X185Dead:
  match stmt after:
    case P113DScalar{scalar} _: x185_d_scalar(scalar,after,again,terminal)
    case P113DIf{condition,yes,no} _: x185_d_if(condition,yes,no,after,again,terminal)
    case P113DCall{names,target,args} X185Dead{body,live}:
      X185Dead{Con{stmt,body},x185_d_values(args,x185_d_kills(names,live))}
    case P113DResult{values} X185Dead{body,live}:
      X185Dead{Con{stmt,body},x185_d_values(values,terminal)}
    case P113DAgain{values} X185Dead{body,live}:
      X185Dead{Con{stmt,body},x185_d_values(values,again)}

@unsafe
def x185_d_body(body,live,again,terminal):
  match body:
    case Nil{}: X185Dead{[],live}
    case Con{head,rest}: x185_d_stmt(head,x185_d_body(rest,live,again,terminal),again,terminal)

@unsafe
def x185_dead_body(setup,body):
  nt_choose(List<&2,P113DStmt>,x185_dead_enabled() &&
      U32.is_lt(p113i_add(p113i_size(setup),p113i_size(body)),8192),
    u => x185_d_result(x185_d_body(body,x185_d_base(),
      x185_d_union(x185_copy_writes(setup,missing()),x185_d_base()),x185_d_base())),u => body)
# Direct register destinations for scalar binary operations. The default path
# snapshots right into r11 before overwriting any aliased destination.

@unsafe
def x185_physical_binary(name,typ,op,left,right,ids,frame):
  nt_choose(X188Seq,x185_register_binary_enabled(),
    u => x185_physical_selected(typ,op,left,right,ids,frame,x185_physical_home(name,frame)),u => X188Empty{})

# Experimental physical right-home selection for integer commutative ALU.
# No expression/value motion, allocation change, or additional analysis walk.
law x185_sf_buffers:
  for body: List<&2,P113DStmt>
  for buffers: KDef
  KDef

@unsafe
def x185_sf_scalar_buffer(stmt: N111Stmt, buffers: KDef) -> KDef:
  match stmt:
    case N111Alloca{name,bytes,align}: x185_sf_alloca(name,bytes,buffers)
    case N111Set{name,typ,value}: x185_sf_block(name,buffers)
    case N111Bin{name,typ,op,left,right}: x185_sf_block(name,buffers)
    case N111Load{name,typ,base,offset}: x185_sf_block(name,buffers)
    case N111Offset{name,base,bytes}: x185_sf_block(name,buffers)
    case N111Call{name,typ,symbol,args}: x185_sf_block(name,buffers)
    case N111If{condition,yes,no}:
      x185_sf_buffers(x181_scalar_rows(no),x185_sf_buffers(x181_scalar_rows(yes),buffers))
    case _: buffers

@unsafe
def x185_sf_buffers(body,buffers):
  match body:
    case Nil{}: buffers
    case Con{P113DScalar{stmt},rest}: x185_sf_buffers(rest,x185_sf_scalar_buffer(stmt,buffers))
    case Con{P113DIf{condition,yes,no},rest}:
      x185_sf_buffers(rest,x185_sf_buffers(no,x185_sf_buffers(yes,buffers)))
    case Con{P113DCall{names,target,args},rest}: x185_sf_buffers(rest,x185_sf_blocks(names,buffers))
    case Con{head,rest}: x185_sf_buffers(rest,buffers)

@unsafe
def x185_scratch_body(params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  nt_choose(List<&2,P113DStmt>,x185_scratch_enabled() && agy_has_mem_body(body) &&
      U32.is_lt(p113i_add(p113i_size(setup),p113i_size(body)),4096),
    u => x185_sf_body(body,x185_sf_buffers(body,x185_sf_buffers(setup,
      x185_sf_blocks(params,p111v_put(missing(),"scratch","X185ScratchBuffer",2048,0)))),[]),u => body)
# Keep the existing frame offsets and outgoing alignment, but preserve only
# callee-saved registers actually assigned a home. Unknown/unprepared frames
# retain the complete save set. The reserved key cannot originate in a public
# local: the existing __x181 hygiene gate rejects it.
@unsafe
def x186_m_value(value: N111Value, scan: X186Memory) -> X186Memory:
  match value:
    case N111Local{name}: x186_m_escape(name,scan)
    case _: scan

@unsafe
def x186_m_values(values: List<&2,N111Value>, scan: X186Memory) -> X186Memory:
  match values:
    case Nil{}: scan
    case Con{head,rest}: x186_m_values(rest,x186_m_value(head,scan))

@unsafe
def x186_m_args(args: List<&2,N111Arg>, scan: X186Memory) -> X186Memory:
  match args:
    case Nil{}: scan
    case Con{N111Arg{typ,value},rest}: x186_m_args(rest,x186_m_value(value,scan))

@unsafe
def x186_m_read(+name: String, +offset: U32, +typ: N111Type, +scan: X186Memory) -> X186Memory:
  match scan:
    case X186Memory{+buffers,reads,used}:
      nt_choose(X186Memory,x186_m_cell(name,offset,typ,buffers),
        u => x186_m_read_second(name,offset,typ,buffers,
          p111v_put(reads,x186_m_key(name,offset),"X186Read",1,0),p111v_put(used,name,"X186Used",1,0)),
        u => x186_m_escape(name,scan))

@unsafe
def x186_m_store(+name: String, offset: U32, typ: N111Type, +scan: X186Memory) -> X186Memory:
  match scan:
    case X186Memory{buffers,reads,used}:
      nt_choose(X186Memory,x186_m_cell(name,offset,typ,buffers),u => scan,u => x186_m_escape(name,scan))

@unsafe
def x186_m_unknown_call(stmt: N111Stmt, scan: X186Memory) -> X186Memory:
  match stmt:
    case N111Call{name,typ,symbol,args}: x186_m_args(args,scan)
    case _: scan

@unsafe
def x186_m_call(stmt: N111Stmt, +scan: X186Memory, effect: X186InlineOp) -> X186Memory:
  match effect:
    case X186InlineF32{destination,+id,+buffer}:
      nt_choose(X186Memory,x200r_float_unary(id),
        u => x186_m_read(buffer,0,N111U64{},scan),
        u => x186_m_read(buffer,8,N111U64{},x186_m_read(buffer,0,N111U64{},scan)))
    case _: x186_m_unknown_call(stmt,scan)
@unsafe
def x186_e_set_state(+state: X186ExprState, stmt: N111Stmt, +name: String, typ: N111Type, value: N111Value) -> X186ExprStep:
  match state:
    case X186ExprState{facts,aliases,fc,ac,mentioned,ft,at}:
      X186ExprStep{P113DScalar{stmt},x186_e_remember_alias(x186_e_written(state,name),name,typ,x186_e_value_t(value,at))}

@unsafe
def x186_e_found(found: Maybe<&2,String>, stmt: N111Stmt, +name: String, kind: U32, +typ: N111Type,
    state: X186ExprState) -> X186ExprStep:
  match found:
    case None{}: X186ExprStep{P113DScalar{stmt},state}
    case Some{+source}: X186ExprStep{P113DScalar{nt_choose(N111Stmt,U32.is_eq(kind,1),
        u => stmt,u => N111Set{name,N111U64{},N111Local{source}})},
      x186_e_result_alias(state,name,N111U64{},source)}

# Offset declarations retain their exact capacity-propagating verifier row.
# Their value equivalence may canonicalize later keys, but never replaces that row.
@unsafe
def x186_e_result_alias(+state: X186ExprState, name: String, typ: N111Type, source: String) -> X186ExprState:
  match state:
    case X186ExprState{facts,aliases,fc,ac,mentioned,ft,at}:
      x186_e_remember_alias(state,name,typ,x186_e_alias_t(at,source))

@unsafe
def x186_e_expression(+state: X186ExprState, stmt: N111Stmt, +name: String, +kind: U32,
    +typ: N111Type, +op: String, left: N111Value, right: N111Value) -> X186ExprStep:
  match state:
    case X186ExprState{facts,aliases,fc,ac,mentioned,ft,at}:
      x186_e_key(stmt,name,kind,typ,op,x186_e_value_t(left,at),x186_e_value_t(right,at),ft,x186_e_written(state,name))

@unsafe
def x186_e_key(stmt: N111Stmt, +name: String, +kind: U32, +typ: N111Type, +op: String,
    +left: N111Value, +right: N111Value, ft: X186FactTrie, state: X186ExprState) -> X186ExprStep:
  +eh = x186_expr_hash(kind,p111v_type(typ),op,left,right)
  x186_e_found(x186_e_find(x186_ft_find(ft,eh),kind,typ,op,left,right),stmt,name,kind,x186_e_result_type(kind,typ,op),
    x186_e_insert(state,name,kind,typ,op,left,right,eh))

@unsafe
def w5_sel_read(s: W5Sel, acc: KDef) -> KDef:
  match s:
    case W5Sel{c,_,_,va,vb}: x185_d_value(vb,x185_d_value(va,x185_d_value(c,acc)))
    case W5SelNone{}: acc

@unsafe
def w4c_dia_writes(body: List<&2,P113DStmt>, acc: KDef) -> KDef:
  match body:
    case Nil{}: acc
    case Con{P113DScalar{sc},rest}: w4c_dia_writes(rest,w4c_dia_write_scalar(sc,acc))
    case Con{P113DIf{c,y,n},rest}: w4c_dia_writes(rest,w5_sel_write(w5_as_sel(c,y,n),acc))
    case Con{_,rest}: w4c_dia_writes(rest,acc)

@unsafe
def w4c_dia_read_scalar(stmt: N111Stmt, acc: KDef) -> KDef:
  match stmt:
    case N111Set{_,_,v}: x185_d_value(v,acc)
    case N111Bin{_,_,_,l,r}: x185_d_value(r,x185_d_value(l,acc))
    case _: acc

@unsafe
def w4c_dia_reads(body: List<&2,P113DStmt>, acc: KDef) -> KDef:
  match body:
    case Nil{}: acc
    case Con{P113DScalar{sc},rest}: w4c_dia_reads(rest,w4c_dia_read_scalar(sc,acc))
    case Con{P113DIf{c,y,n},rest}: w4c_dia_reads(rest,w5_sel_read(w5_as_sel(c,y,n),acc))
    case Con{_,rest}: w4c_dia_reads(rest,acc)

@unsafe
def w4c_dia_try_no(+cond: N111Value, +yb: List<&2,P113DStmt>, +nb: List<&2,P113DStmt>,
    +rest: List<&2,P113DStmt>, +afterLive: KDef, +yl: KDef, +nl: KDef, +seq: U32,
    +ydst: String, +yt: N111Type, nd: W4CLastDst) -> W4CDiaRes:
  match nd:
    case W4CLast{+ndst,+nt}:
      +basic = Bool.not(String.is_empty(ydst)) && agy_str_eq(ydst,ndst) &&
        Bool.not(x181_register_reserved(ydst)) &&
        w4c_sel_width(yt) && w4c_sel_width(nt) &&
        w4c_sel_val(cond) &&
        Bool.not(w4c_dia_is_sel(w4c_sel_arm(yb)) && w4c_dia_is_sel(w4c_sel_arm(nb))) &&
        w4c_dia_arm_pure(yb,16) && w4c_dia_arm_pure(nb,16)
      nt_choose(W4CDiaRes,basic,
        u =>
          +yw = w4c_dia_writes(yb,missing())
          +nw = w4c_dia_writes(nb,missing())
          +yr = w4c_dia_reads(yb,missing())
          +nr = w4c_dia_reads(nb,missing())
          +forbY = x185_d_union(afterLive,x185_d_union(nr,nw))
          +forbN = x185_d_union(afterLive,x185_d_union(yr,yw))
          +ok = w4c_dia_cond_ok(cond,yw) && w4c_dia_cond_ok(cond,nw) &&
            w4c_dia_nonlast_ok(yb,ydst,forbY) && w4c_dia_nonlast_ok(nb,ydst,forbN)
          nt_choose(W4CDiaRes,ok,
            v =>
              +resTyp = nt_choose(N111Type,U32.is_eq(p111v_type(yt),2) || U32.is_eq(p111v_type(nt),2),
                z => N111U64{},z => N111U32{})
              +ynm = ydst ++ "_w4cy" ++ U32.show(seq)
              +nnm = ydst ++ "_w4cn" ++ U32.show(seq)
              +sel : P113DStmt = P113DIf{cond,
                [P113DScalar{N111Set{ydst,resTyp,N111Local{ynm}}}],
                [P113DScalar{N111Set{ydst,resTyp,N111Local{nnm}}}]}
              +merged = nt_append(P113DStmt,w4c_dia_rename_last(yb,ynm),
                nt_append(P113DStmt,w4c_dia_rename_last(nb,nnm),Con{sel,rest}))
              W4CDiaRes{merged,x185_d_value(cond,x185_d_union(yl,nl)),U32.inc(seq)},
            v => W4CDiaRes{Con{P113DIf{cond,yb,nb},rest},x185_d_value(cond,x185_d_union(yl,nl)),seq}),
        u => W4CDiaRes{Con{P113DIf{cond,yb,nb},rest},x185_d_value(cond,x185_d_union(yl,nl)),seq})
    case W4CLastNone{}:
      W4CDiaRes{Con{P113DIf{cond,yb,nb},rest},x185_d_value(cond,x185_d_union(yl,nl)),seq}

@unsafe
def w4c_dia_try(+cond: N111Value, +yb: List<&2,P113DStmt>, +nb: List<&2,P113DStmt>,
    +rest: List<&2,P113DStmt>, +afterLive: KDef, +yl: KDef, +nl: KDef, +seq: U32,
    yd: W4CLastDst) -> W4CDiaRes:
  match yd:
    case W4CLast{ydst,yt}: w4c_dia_try_no(cond,yb,nb,rest,afterLive,yl,nl,seq,ydst,yt,w4c_dia_last_dst(nb))
    case W4CLastNone{}:
      W4CDiaRes{Con{P113DIf{cond,yb,nb},rest},x185_d_value(cond,x185_d_union(yl,nl)),seq}

@unsafe
def x190_v_binary(+name: String, +typ: N111Type, +op: String, +left: N111Value, +right: N111Value, +state: X190Values) -> X190ValueStep:
  w5b_v_binary_go(name,typ,op,left,right,state,w5b_try_const_bin(op,left,right))

@unsafe
def x190_v_scalar(stmt: N111Stmt, +state: X190Values) -> X190ValueStep:
  match stmt:
    case N111Set{name,typ,value}: x190_v_set(name,typ,x190_v_value(value,state),state)
    case N111Bin{name,typ,op,left,right}: x190_v_binary(name,typ,op,x190_v_value(left,state),x190_v_value(right,state),state)
    case N111Offset{+name,base,bytes}:
      X190ValueStep{P113DScalar{N111Offset{name,x190_v_value(base,state),x190_v_value(bytes,state)}},x190_v_written(name,False{},state)}
    case N111Load{+name,+typ,base,offset}:
      X190ValueStep{P113DScalar{N111Load{name,typ,x190_v_value(base,state),offset}},x190_v_written(name,U32.is_eq(p111v_type(typ),1),state)}
    case N111Store{typ,base,offset,value}:
      X190ValueStep{P113DScalar{N111Store{typ,x190_v_value(base,state),offset,x190_v_value(value,state)}},state}
    case N111Call{name,typ,symbol,args}:
      X190ValueStep{P113DScalar{N111Call{name,typ,symbol,x190_v_args(args,state)}},x190_v_empty()}
    case N111Alloca{+name,bytes,align}:
      X190ValueStep{P113DScalar{N111Alloca{name,bytes,align}},x190_v_written(name,False{},state)}
    case N111Return{value}: X190ValueStep{P113DScalar{N111Return{x190_v_value(value,state)}},x190_v_empty()}
    case _: X190ValueStep{P113DScalar{stmt},x190_v_empty()}

# Modulo-2^32 arithmetic commutes with truncation for these operations only.
# In particular, shifts keep the original 64-bit count and intermediate bits.
@unsafe
def x195cf_scalar(stmt: N111Stmt, +state: X190Values) -> X190ValueStep:
  match stmt:
    case N111Call{+name,typ,symbol,args}:
      X190ValueStep{P113DScalar{N111Call{name,typ,symbol,x190_v_args(args,state)}},
        x195cf_after_call([name],state)}
    case _: x190_v_scalar(stmt,state)


# Sole replacement; the original matcher, Set/width logic and per-write kills
# remain authoritative. Only call transfer differs from the branch-only hook.
@unsafe
def x186_f_buffers(params: List<&2,String>, setup: List<&2,P113DStmt>, body: List<&2,P113DStmt>) -> KDef:
  x185_sf_buffers(body,x185_sf_buffers(setup,x185_sf_blocks(params,
    p111v_put(missing(),"scratch","X185ScratchBuffer",2048,0))))

@unsafe
def x186_x_noncanonical(stmt: P113DStmt, scan: X185TScan) -> X185TScan:
  match scan:
    case X185TScan{ranges,names,position,region}:
      X185TScan{x185_copy_writes([stmt],ranges),names,position,region}

@unsafe
def x186_x_float(+name: String, +id: U32, +left: N111Value, +right: N111Value,
    +ids: N111Ids, +frame: X181Frame, +homes: KDef) -> X188Seq:
  nt_choose(X188Seq,U32.is_eq(id,36),u => x200r_sqrt_values(name,left,ids,frame,homes),
    u => nt_choose(X188Seq,x192_float_unary(id),u => x192_float_conversion(name,id,left,ids,frame,homes),
    u => nt_choose(X188Seq,U32.is_lt(id,30),v => x186_x_arithmetic(name,id,left,right,ids,frame,homes),
      v => x186_x_compare(name,id,left,right,ids,frame,homes))))
@unsafe
def x190_a_body(body: List<&2,P113DStmt>, +ids: KDef, +params: List<&2,String>, affinities: KDef) -> KDef:
  match body:
    case Nil{}: affinities
    case Con{P113DScalar{N111Set{name,typ,value}},rest}:
      x190_a_body(rest,ids,params,x190_a_pair(name,value,ids,affinities))
    case Con{P113DScalar{N111If{condition,yes,no}},rest}:
      x190_a_body(rest,ids,params,x190_a_body(x181_scalar_rows(no),ids,params,
        x190_a_body(x181_scalar_rows(yes),ids,params,affinities)))
    case Con{P113DIf{condition,yes,no},rest}:
      x190_a_body(rest,ids,params,x190_a_body(no,ids,params,x190_a_body(yes,ids,params,affinities)))
    case Con{P113DAgain{values},rest}: x190_a_body(rest,ids,params,x190_a_tail(params,values,ids,affinities))
    case Con{head,rest}: x190_a_body(rest,ids,params,affinities)

@unsafe
def w5c_pj_apply(frame: X181Frame, +names: List<&2,String>, +groups: List<&2,U32>,
    +header: U32, scan: X185TScan) -> X181Frame:
  match scan:
    case X185TScan{+ranges,allNames,+position,region}:
      w5c_pj_run(frame,ranges,allNames,position,
        w5c_pj_collect(names,groups,header,ranges,1,W5CPJState{[0,0,0,0,0],[[],[],[],[],[]]}))

@unsafe
def x191_again_reads(params: List<&2,String>, values: List<&2,N111Value>, +counts: X181ReadCounts) -> X181ReadCounts:
  match params values:
    case Con{parameter,rest} Con{+value,more}:
      x191_again_reads(rest,more,nt_choose(X181ReadCounts,x191_again_identity(parameter,value),
        u => counts,u => x181_reads_value(value,counts)))
    case _ _: counts

@unsafe
def w5b_reads_8(+condition: N111Value, +counts: X181ReadCounts) -> X181ReadCounts:
  x181_reads_value(condition,x181_reads_value(condition,x181_reads_value(condition,
    x181_reads_value(condition,x181_reads_value(condition,x181_reads_value(condition,
      x181_reads_value(condition,x181_reads_value(condition,counts))))))))

@unsafe
def w5b_reads_loop_cond(+condition: N111Value, +counts: X181ReadCounts) -> X181ReadCounts:
  w5b_reads_8(condition,w5b_reads_8(condition,w5b_reads_8(condition,w5b_reads_8(condition,counts))))

@unsafe
def x191_loop_cons(head: X191LoopReads, rest: X191LoopReads) -> X191LoopReads:
  match head rest:
    case X191LoopReads{+a,hot,+falls} X191LoopReads{b,restHot,restFalls}:
      X191LoopReads{nt_choose(X181ReadCounts,falls,u => x191_reads_merge(a,b),u => a),hot,falls && restFalls}

law x190_branch_pairs:
  for +body: List<&2,P113DStmt>
  for pairs: KDef
  KDef

@unsafe
def x190_branch_pairs_stmt(stmt: P113DStmt, pairs: KDef) -> KDef:
  match stmt:
    case P113DIf{condition,yes,no}: x190_branch_pairs(no,x190_branch_pairs(yes,pairs))
    case P113DScalar{N111If{condition,yes,no}}:
      x190_branch_pairs(x181_scalar_rows(no),x190_branch_pairs(x181_scalar_rows(yes),pairs))
    case _: pairs

@unsafe
def x190_branch_pairs(body,pairs):
  match body:
    case Nil{}: pairs
    case Con{head,rest}: x190_branch_pairs(rest,x190_branch_pairs_stmt(head,
      x194_ps_count_pick(x194_ps_pick(body),x190_branch_pair(body,pairs))))

@unsafe
def w5_run_licm(doLicm: Bool, +items: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match doLicm:
    case True{}: w4b_licm_magic(items)
    case False{}: items

# ---- W5B-R2: General Leaf-Function Free-GPR Stack-Slot Promotion ----

@unsafe
def w5_run_rot(hasLbl: Bool, +items: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match hasLbl:
    case False{}: items
    case True{}:
      +rot = w4b_rotate_loop(items)
      +rot2 = w5_flat_rev_seq(w4b_copy_peep(rot,rot,[]),[])
      w5_flat_rev_seq(w4c_peep_cfg(rot2,rot2,[]),[])

@unsafe
def w7_post_select_full(+flat0: List<&2,X187Parsed>, +hasXmm: Bool, +hasNegRbp: Bool,
    +hasLbl: Bool, +hasImulq: Bool, +hasCall: Bool, +hasLoop: Bool) -> X188Seq:
  +f1 = w5_flat_rev_seq(w4_peep_list(flat0,[]),[])
  +f3 = w5c_copy_peep2(w5c_copy_peep_t(f1,w5c_lbl_build_if(hasLbl,f1),[],False{}),hasLbl,f1)
  +f4s = w7_leaf_shrink_if(Bool.not(hasCall),f3)
  +licm = w5_run_licm(Bool.not(hasCall) && hasLoop && hasImulq,f4s)
  +prom = w5b_run_leaf_promote(Bool.not(hasCall) && hasNegRbp,licm)
  +f5 = w5_run_rot(hasLoop,prom)
  +rg = w5c_gpr_peep_c(f5,f5,[])
  +g3 = w5c_gpr_pass2(rg,f5)
  +rb = w5c_bp_c(g3,g3,[])
  +b1b = w5c_bp_pass2(rb,g3)
  +b2 = w7_peep_cfg2(w7_gpr_changed(rg) || w7_gpr_changed(rb),b1b)
  +xmm = w7_run_xmm(hasXmm,hasNegRbp,hasLoop,b2)
  w4b_wrap_items(xmm,[])

@unsafe
def w4_post_select(code: X188Seq) -> X188Seq:
  +flat0 = w4_peep_flat([code],[])
  +flags = w5_scan_flags(flat0,0)
  +hasXmm = Bool.not(U32.is_eq(U32.and(flags,1),0))
  +hasNegRbp = Bool.not(U32.is_eq(U32.and(flags,2),0))
  +hasLbl = Bool.not(U32.is_eq(U32.and(flags,4),0))
  +hasImulq = Bool.not(U32.is_eq(U32.and(flags,8),0))
  +hasCall = Bool.not(U32.is_eq(U32.and(flags,16),0))
  +hasLoop = hasLbl && w7_is_loop(w4b_find_loop(flat0,[]))
  nt_choose(X188Seq,hasCall && Bool.not(hasXmm) && Bool.not(hasLoop) && w7_len_gt(flat0,96),
    u => x188_finish(w4_peep_list(flat0,[])),
    u => w7_post_select_full(flat0,hasXmm,hasNegRbp,hasLbl,hasImulq,hasCall,hasLoop))

law x192_p_body:
  for body: List<&2,P113DStmt>
  for facts: KDef
  List<&2,P113DStmt>

@unsafe
def x192_p_if_chosen(chosen: Maybe<&2,List<&2,P113DStmt>>, condition: N111Value,
    yes: List<&2,P113DStmt>, no: List<&2,P113DStmt>, rest: List<&2,P113DStmt>, +facts: KDef) -> List<&2,P113DStmt>:
  match chosen:
    case Some{rows}: x192_p_body(nt_append(P113DStmt,rows,rest),facts)
    case None{}: Con{P113DIf{condition,x192_p_body(yes,facts),x192_p_body(no,facts)},x192_p_body(rest,missing())}

@unsafe
def x192_p_if(+condition: N111Value, +yes: List<&2,P113DStmt>, +no: List<&2,P113DStmt>,
    rest: List<&2,P113DStmt>, +facts: KDef) -> List<&2,P113DStmt>:
  x192_p_if_chosen(x192_p_plan(condition,facts,x191_select_plan(yes,no)),condition,yes,no,rest,facts)

@unsafe
def x192_p_scalar(stmt: N111Stmt, rest: List<&2,P113DStmt>, +facts: KDef) -> List<&2,P113DStmt>:
  +ready = x192_p_binary(stmt,facts)
  Con{P113DScalar{ready},x192_p_body(rest,x192_p_scalar_facts(ready,facts))}

@unsafe
def x192_p_body(body,facts):
  match body:
    case Nil{}: []
    case Con{P113DIf{condition,yes,no},rest}: x192_p_if(condition,yes,no,rest,facts)
    case Con{P113DScalar{N111If{condition,yes,no}},rest}:
      x192_p_if(condition,x181_scalar_rows(yes),x181_scalar_rows(no),rest,facts)
    case Con{P113DScalar{stmt},rest}: x192_p_scalar(stmt,rest,facts)
    case Con{head,rest}: Con{head,x192_p_body(rest,missing())}

@unsafe
def x192_predicate_body(+body: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  nt_choose(List<&2,P113DStmt>,x192_predicate_enabled() && U32.is_le(p113i_size(body),4096),
    u => x192_p_body(body,missing()),u => body)
@unsafe
def x198a_cert(facts: Maybe<&2,KDef>, prefix: List<&2,P113DStmt>, condition: N111Value,
    truth: Bool, loop: X198ACountdown) -> Bool:
  match facts:
    case Some{table}: x198a_eval(prefix,condition,truth,loop,table)
    case None{}: False{}

@unsafe
def x198a_arm_allowed(copies: Maybe<&2,List<&2,X186Alias>>, +loop: X198ACountdown,
    prefix: List<&2,P113DStmt>, condition: N111Value, truth: Bool, args: List<&2,N111Value>) -> Bool:
  match copies loop:
    case Some{bindings} X198ACountdown{params,fuel,pred,buffer,ids}:
      x198a_cert(x198a_back(params,args,fuel,pred,bindings,missing()),prefix,condition,truth,loop)
    case _ _: False{}

@unsafe
def x198a_arm(+arm: List<&2,P113DStmt>, +loop: X198ACountdown, prefix: List<&2,P113DStmt>,
    condition: N111Value, truth: Bool, args: List<&2,N111Value>) -> List<&2,P113DStmt>:
  match loop:
    case X198ACountdown{params,fuel,pred,buffer,ids}:
      nt_choose(List<&2,P113DStmt>,x198a_arm_allowed(x198a_copies(arm,loop,[],16),loop,prefix,condition,truth,args),
        u => nt_append(P113DStmt,arm,[P113DScalar{N111Set{pred,N111U64{},N111Const{0,0}}}]),u => arm)

# The only continuation after the branch must be the shared, arity-checked
# backedge. No skipped statement can observe the new predecessor value.
@unsafe
def x198a_scan(+body: List<&2,P113DStmt>, +loop: X198ACountdown, +reverse: List<&2,P113DStmt>,
    +budget: U32) -> List<&2,P113DStmt>:
  match body:
    case Con{P113DIf{+condition,yes,no},Con{P113DAgain{+args},Nil{}}}:
      +prefix = nt_reverse(P113DStmt,reverse,[])
      [P113DIf{condition,x198a_arm(yes,loop,prefix,condition,True{},args),
        x198a_arm(no,loop,prefix,condition,False{},args)},P113DAgain{args}]
    case Con{P113DScalar{N111Bin{+name,+typ,+op,+l,+r}},rest}:
      +row = {P113DScalar{N111Bin{name,typ,op,l,r}} : P113DStmt}
      nt_choose(List<&2,P113DStmt>,U32.is_gt(budget,0),u =>
        Con{row,x198a_scan(rest,loop,Con{row,reverse},U32.sub(budget,1))},u => body)
    case _: body

def x198_sym_step(stmt: N111Stmt, +s: X198Sym) -> X198Sym:
  match stmt s:
    case N111Bin{name,N111U64{},op,x,y} X198Sym{env,ctor,taken,made,s0,s1}:
      x198_sym_bin(name,op,x198_sym_get(x,env),y,s)
    case N111Set{name,N111U64{},v} X198Sym{env,ctor,taken,made,s0,s1}:
      x198_sym_assign(name,x198_sym_get(v,env),s)
    case N111Load{name,N111U64{},base,+off} X198Sym{env,ctor,taken,made,s0,s1}:
      nt_choose(X198Sym,U32.is_eq(x198_sym_get(base,env),8) && (U32.is_eq(off,0) || U32.is_eq(off,8)),
        u => x198_sym_assign(name,nt_choose(U32,U32.is_eq(off,0),v => s0,v => s1),s),u => X198Refuse{})
    case N111Store{N111U64{},base,+off,v} X198Sym{+env,ctor,taken,made,s0,s1}:
      +value = x198_sym_get(v,env)
      nt_choose(X198Sym,U32.is_eq(x198_sym_get(base,env),8) && U32.is_gt(value,0) && (U32.is_eq(off,0) || U32.is_eq(off,8)),
        u => X198Sym{env,ctor,taken,made,nt_choose(U32,U32.is_eq(off,0),v => value,v => s0),
          nt_choose(U32,U32.is_eq(off,8),v => value,v => s1)},u => X198Refuse{})
    case N111Call{name,N111U64{},fun,args} _: x198_sym_call(name,fun,args,s)
    case N111Alloca{+name,bytes,align} X198Sym{env,ctor,taken,made,s0,s1}:
      # A fixed x86 frame declaration emits no target instruction. Refuse a
      # redeclaration of a parameter / known symbolic scalar.
      nt_choose(X198Sym,U32.is_eq(da(p111v_get(env,name)),0) || p88_string_eq(name,"scratch"),u => s,u => X198Refuse{})
    case _ _: X198Refuse{}

@unsafe
def x198_sym_walk(rows: List<&2,P113DStmt>, +s: X198Sym, +steps: U32) -> X198Perm:
  match rows s:
    case Con{P113DResult{Con{v,Nil{}}},Nil{}} X198Sym{env,ctor,3,3,s0,s1}:
      x198_perm_spec(ctor,x198_sym_get(v,env))
    case Con{P113DScalar{stmt},rest} X198Sym{env,ctor,taken,made,s0,s1}:
      nt_choose(X198Perm,U32.is_lt(steps,64),u => x198_sym_walk(rest,x198_sym_step(stmt,s),U32.inc(steps)),u => X198NoPerm{})
    case Con{P113DIf{test,yes,no},Nil{}} X198Sym{env,ctor,taken,made,s0,s1}:
      nt_choose(X198Perm,U32.is_lt(steps,64) && x198_sym_range(x198_sym_get(test,env),31,32),
        u => x198_sym_walk(yes,s,U32.inc(steps)),u => X198NoPerm{})
    case _ _: X198NoPerm{}

@unsafe
def x198_perm_pick(+params: List<&2,String>, setup: List<&2,P113DStmt>, body: List<&2,P113DStmt>) -> X198Perm:
  match params setup:
    case Con{+state,Con{+a,Con{+b,Nil{}}}} Nil{}:
      nt_choose(X198Perm,agy_str_eq(state,"state") && Bool.not(agy_str_eq(a,b) || agy_str_eq(a,state) || agy_str_eq(b,state) ||
          agy_str_eq(a,"scratch") || agy_str_eq(b,"scratch") || String.starts_with(a,"__x181") || String.starts_with(b,"__x181")),
        u => x198_sym_walk(body,X198Sym{x198_sym_bind(x198_sym_bind(x198_sym_bind(x198_sym_bind(missing(),state,7),a,1),b,2),"scratch",8),"",0,0,0,0},0),
        u => X198NoPerm{})
    case _ _: X198NoPerm{}

# Typed SysV entry wrapper. The old worker is called with the original three
# physical arguments on every refusal. The two owned input words remain live
# through the guard and are published under the fresh parent on success.
@unsafe
def x198n_bin(+typ: N111Type, +op: String, +left: X198NFact, +right: X198NFact) -> X198NFact:
  nt_choose(X198NFact,agy_str_eq(op,"or") && (x198n_nonzero(left) || x198n_nonzero(right)),u =>
    nt_choose(X198NFact,x198n_equal(left,right),v => x198n_width(left,typ),v => X198NNonzero{x198n_low_nonzero(left) || x198n_low_nonzero(right)}),u =>
  nt_choose(X198NFact,(agy_str_eq(op,"eq") || agy_str_eq(op,"ne")) &&
    ((x198n_zero(left) && x198n_nonzero(right)) || (x198n_zero(right) && x198n_nonzero(left))),u =>
      X198NConst{nt_choose(U32,agy_str_eq(op,"ne"),v => 1,v => 0),0},u =>
  nt_choose(X198NFact,x198n_zero(right) && (agy_str_eq(op,"add") || agy_str_eq(op,"sub") || agy_str_eq(op,"or") || agy_str_eq(op,"xor") || agy_str_eq(op,"shl") || agy_str_eq(op,"shr") || agy_str_eq(op,"sar")),u => x198n_width(left,typ),u =>
  nt_choose(X198NFact,x198n_zero(left) && (agy_str_eq(op,"add") || agy_str_eq(op,"or") || agy_str_eq(op,"xor")),u => x198n_width(right,typ),u =>
  nt_choose(X198NFact,agy_str_eq(op,"mul") && (x198n_zero(left) || x198n_zero(right)),u => X198NConst{0,0},u =>
  nt_choose(X198NFact,agy_str_eq(op,"mul") && x198n_one(right),u => x198n_width(left,typ),u =>
  nt_choose(X198NFact,agy_str_eq(op,"mul") && x198n_one(left),u => x198n_width(right,typ),u =>
    x198n_exact_bin(typ,op,left,right))))))))

law x198n_eval:
  for body: List<&2,P113DStmt>
  for +env: List<&2,X198NBinding>
  for +fuel: String
  X198NState

@unsafe
def x198n_continue(body: List<&2,P113DStmt>, fuel: String, +state: X198NState) -> X198NState:
  match state:
    case X198NState{+valid,+env}: nt_choose(X198NState,valid,u => x198n_eval(body,env,fuel),u => state)

@unsafe
def x198n_choose(+condition: X198NFact, +yes: List<&2,P113DStmt>, +no: List<&2,P113DStmt>, +env: List<&2,X198NBinding>, +fuel: String) -> X198NState:
  nt_choose(X198NState,x198n_zero(condition),u => x198n_eval(no,env,fuel),u =>
    nt_choose(X198NState,x198n_nonzero(condition),v => x198n_eval(yes,env,fuel),v =>
      x198n_join(x198n_eval(yes,env,fuel),x198n_eval(no,env,fuel))))

@unsafe
def x198n_eval(body,env,fuel):
  match body:
    case Nil{}: X198NState{True{},env}
    case Con{P113DScalar{N111Set{+name,+typ,+value}},rest}:
      nt_choose(X198NState,x190_branch_width(typ),u =>
        x198n_eval(rest,Con{X198NBinding{name,x198n_width(x198n_value(value,env),typ)},env},fuel),u => X198NState{False{},[]})
    case Con{P113DScalar{N111Bin{+name,+typ,+op,+left,+right}},rest}:
      nt_choose(X198NState,x190_branch_width(typ) && x198n_op(op),u =>
        x198n_eval(rest,Con{X198NBinding{name,nt_choose(X198NFact,agy_str_eq(op,"sub") && x185_sf_source(left,fuel) && x192_p_constant(right,1) && U32.is_eq(p113k_width(typ),64),v => X198NPredecessor{},v => x198n_bin(typ,op,x198n_width(x198n_value(left,env),typ),x198n_width(x198n_value(right,env),typ)))},env},fuel),u => X198NState{False{},[]})
    case Con{P113DIf{condition,yes,no},rest}:
      x198n_continue(rest,fuel,x198n_choose(x198n_value(condition,env),yes,no,env,fuel))
    case Con{P113DScalar{N111If{condition,yes,no}},rest}:
      x198n_continue(rest,fuel,x198n_choose(x198n_value(condition,env),x181_scalar_rows(yes),x181_scalar_rows(no),env,fuel))
    case _: X198NState{False{},[]}

@unsafe
def x198n_modes(choices: List<&2,String>, +params: List<&2,NC_Binding>, +fuel: String, +returned: List<&2,N111Value>, +prefix: List<&2,P113DStmt>, +values: List<&2,N111Value>) -> Maybe<&2,String>:
  match choices:
    case Nil{}: None{}
    case Con{+mode,rest}:
      +names = x181_param_names(params)
      nt_choose(Maybe<&2,String>,Bool.not(agy_str_eq(mode,fuel)) && x198n_return(returned,names,fuel,mode) &&
        x198n_finished(x198n_eval(prefix,x198n_initial(params,fuel,mode),fuel),names,values,fuel,mode),u => Some{mode},u => x198n_modes(rest,params,fuel,returned,prefix,values))

@unsafe
def x198n_loop(split: Maybe<&2,X198NLoop>, +params: List<&2,NC_Binding>, +fuel: String, returned: List<&2,N111Value>) -> Maybe<&2,String>:
  match split:
    case Some{X198NLoop{+prefix,values}}:
      nt_choose(Maybe<&2,String>,x198n_clean(prefix,x181_param_names(params)),u =>
        x198n_modes(x181_param_names(params),params,fuel,returned,prefix,values),u => None{})
    case None{}: None{}

# The original positive-fuel branch may contain a redundant verified Nat guard.
# Its failure arm is unreachable under the outer U64 positive-fuel condition.
@unsafe
def x198o_progress_bin(+typ: N111Type, +op: String, left: X198OProgress, right: X198OProgress) -> X198OProgress:
  match left right:
    case X198OProgress{+a,+ad,+asp} X198OProgress{+b,+bd,+bsp}:
      +x = x198n_width(a,typ)
      +y = x198n_width(b,typ)
      X198OProgress{x198n_bin(typ,op,x,y),x198o_progress_diff(typ,op,x,y,asp,bsp,ad,bd),w4_progress_parity(op,x,y,asp,bsp)}

@unsafe
def x198o_progress_eval(body: List<&2,P113DStmt>, +env: List<&2,X198OProgressBinding>) -> X198OProgressState:
  match body:
    case Nil{}: X198OProgressState{True{},env}
    case Con{P113DScalar{N111Set{+name,+typ,+value}},rest}:
      nt_choose(X198OProgressState,x190_branch_width(typ),u => x198o_progress_eval(rest,Con{X198OProgressBinding{name,x198o_progress_copy(x198o_progress_value(value,env),typ)},env}),u => X198OProgressState{False{},[]})
    case Con{P113DScalar{N111Bin{+name,+typ,+op,+left,+right}},rest}:
      nt_choose(X198OProgressState,x190_branch_width(typ) && x198n_op(op),u => x198o_progress_eval(rest,Con{X198OProgressBinding{name,x198o_progress_bin(typ,op,x198o_progress_value(left,env),x198o_progress_value(right,env))},env}),u => X198OProgressState{False{},[]})
    case _: X198OProgressState{False{},[]}

@unsafe
def x198o_no_fixed(+prefix: List<&2,P113DStmt>, +params: List<&2,NC_Binding>, values: List<&2,N111Value>, +fuel: String, counter: String) -> Bool:
  x198o_progress_finished(x198o_progress_eval(prefix,x198o_progress_initial(params,fuel)),x181_param_names(params),values,fuel,counter)

# Preserve the direct-worker parameter kinds until after the existing scalar
# normalization. Fallback retains the old pipeline; no operation is selected here.
@unsafe
def x192h_unwind(cases: List<&2,P114HCase>, params: List<&2,String>) -> List<&2,P113DStmt>:
  [P113DScalar{N111Bin{"p114r_pending",N111U64{},"ne",x192h_v("p114r_depth"),x192h_c(0)}},
   P113DIf{x192h_v("p114r_pending"),
     Con{P113DScalar{N111Bin{"p114r_depth",N111U64{},"sub",x192h_v("p114r_depth"),x192h_c(1)}},
     Con{x192h_stack("p111_rt_stack_pop","p114h_popped",1),
     Con{x192h_stack("p111_rt_stack_get","p114h_fid",0),x192h_dispatch(cases,0,params)}}},
     [P113DResult{[x192h_v("p114r_value")]}]}]

@unsafe
def x192h_worker_body(+params: List<&2,String>, body: List<&2,P114RStmt>, cases: List<&2,P114HCase>) -> List<&2,P113DStmt>:
  [P113DIf{x192h_v("p114h_mode"),x192h_unwind(cases,params),x192h_body(body,params,"scratch")}]

@unsafe
def x198pw_def(+book: List<&2,KDef>, role: String, +arity: U32, pattern: X198PWPattern, state: X198PWState) -> X198PWState:
  match state:
    case X198PWState{+roles,vars}:
      +d = lookup(book,x198pw_name(roles,role))
      nt_choose(X198PWState,agy_str_eq(dk(d),"Def") && U32.is_eq(da(d),arity) && Bool.not(nc_native_def(d) || nc_foreign(d) || du(d)),
        u => x198pw_match(pattern,dv(d),X198PWState{roles,missing()}),u => X198PWBad{})
    case _: X198PWBad{}

@unsafe
def x198pw_intrinsic(+book: List<&2,KDef>,+roles: KDef, role: String, code: String) -> Bool:
  +d = lookup(book,x198pw_name(roles,role))
  nc_native_def(d) && U32.is_eq(da(d),2) && agy_str_eq(nc_primitive_name(dn(d)),code)

@unsafe
def x198pw_finish(+book: List<&2,KDef>,+owner: String,s: X198PWState) -> X198PWPlan:
  match s:
    case X198PWState{+roles,vars}:
      nt_choose(X198PWPlan,x198pw_intrinsic(book,roles,"xor","bool_xor") && x198pw_intrinsic(book,roles,"gt","u32_is_gt"),
        u => X198PWPlan{owner,nc_ctor_identity(book,x198pw_name(roles,"leaf")),nc_ctor_identity(book,x198pw_name(roles,"node"))},
        u => X198PWNone{})
    case _: X198PWNone{}

@unsafe
def x198pw_family(+book: List<&2,KDef>,+owner: String,+leaf: String,+node: String) -> X198PWPlan:
  +roles = x198pw_put(x198pw_put(x198pw_put(x198pw_put(x198pw_put(missing(),"self",owner),"leaf",leaf),"node",node),"false","False"),"true","True")
  +leafPath = x198pw_def(book,"self",3,x198pw_root_leaf(),X198PWState{roles,missing()})
  +nodePath = x198pw_def(book,"self",3,x198pw_root_node(),leafPath)
  +zipPath = x198pw_def(book,"join",2,x198pw_join(),nodePath)
  +leafFunc = x198pw_def(book,"leafFunction",3,x198pw_leaf_function(),zipPath)
  +noSwap = x198pw_def(book,"order",3,x198pw_order("false","a","b"),leafFunc)
  x198pw_finish(book,owner,x198pw_def(book,"order",3,x198pw_order("true","b","a"),noSwap))

@unsafe
def x198pw_alternative(book: List<&2,KDef>,owner: String,one: String,two: String,plan: X198PWPlan) -> X198PWPlan:
  match plan:
    case X198PWNone{}: x198pw_family(book,owner,two,one)
    case X198PWPlan{name,leaf,node}: X198PWPlan{name,leaf,node}

@unsafe
def x198pw_ready(+plans: List<&2,X198PWPlan>,p: P169Prepared) -> P169Prepared:
  match p:
    case P169Prepared{forwards,+cursor,+error}:
      P169Prepared{forwards,nt_choose(P134Cursor,String.is_empty(error) && Bool.not(List.is_empty(&2,X198PWPlan,plans)),
        u => x198pw_cursor(plans,cursor),u => cursor),error}


# ============================================================================
# AGY-W2B-3: Certified In-Place Binary-Tree Zipper-Insert Fast Path
# ============================================================================

@unsafe
def agy_zip_def(+book: List<&2,KDef>, role: String, +arity: U32, pat: AgyZipPat, state: X198PWState) -> X198PWState:
  match state:
    case X198PWState{+roles,vars}:
      +d = lookup(book,x198pw_name(roles,role))
      nt_choose(X198PWState,agy_str_eq(dk(d),"Def") && U32.is_eq(da(d),arity) && Bool.not(nc_native_def(d) || nc_foreign(d) || du(d)),
        u => agy_zip_match(pat,dv(d),X198PWState{roles,missing()}),u => X198PWBad{})
    case _: X198PWBad{}

@unsafe
def agy_zip_finish(+book: List<&2,KDef>, +owner: String, +ty: String, s: X198PWState) -> AgyZipPlan:
  match s:
    case X198PWState{+roles,vars}:
      +leaf = x198pw_name(roles,"leaf")
      +node = x198pw_name(roles,"node")
      nt_choose(AgyZipPlan,x198pw_intrinsic(book,roles,"lt","u32_is_lt") && agy_zip_data_ok(book,ty,leaf,node),
        u => AgyZipPlan{owner,nc_ctor_identity(book,leaf),nc_ctor_identity(book,node)},
        u => AgyZipNone{})
    case _: AgyZipNone{}

@unsafe
def agy_zip_check_family(+book: List<&2,KDef>, +owner: String, +ty: String, +leaf: String, +node: String) -> AgyZipPlan:
  +r0 = x198pw_put(x198pw_put(x198pw_put(x198pw_put(x198pw_put(x198pw_put(x198pw_put(x198pw_put(x198pw_put(x198pw_put(
    missing(),"self",owner),"leaf",leaf),"node",node),"pair","Tuple"),"nil","Nil"),"con","Con"),"true","True"),"false","False"),"zero","Zero"),"succ","Succ")
  +s1 = agy_zip_def(book,"self",3,agy_zip_pat_insert(),X198PWState{r0,missing()})
  +s2 = agy_zip_def(book,"fin",2,agy_zip_pat_fin_leaf(),s1)
  +s3 = agy_zip_def(book,"fin",2,agy_zip_pat_fin_node(),s2)
  +s4 = agy_zip_def(book,"up",2,agy_zip_pat_up_nil(),s3)
  +s5 = agy_zip_def(book,"up",2,agy_zip_pat_up_con("true","acc","other"),s4)
  +s6 = agy_zip_def(book,"up",2,agy_zip_pat_up_con("false","other","acc"),s5)
  +s7 = agy_zip_def(book,"down",3,agy_zip_pat_down_zero(),s6)
  +s8 = agy_zip_def(book,"down",3,agy_zip_pat_down_succ_leaf(),s7)
  +s9 = agy_zip_or(
    agy_zip_def(book,"down",3,agy_zip_pat_down_succ_node_let(),s8),
    agy_zip_def(book,"down",3,agy_zip_pat_down_succ_node_dir(),s8))
  +s10 = agy_zip_def(book,"pick",5,agy_zip_pat_pick("true","l","r"),s9)
  +s11 = agy_zip_def(book,"pick",5,agy_zip_pat_pick("false","r","l"),s10)
  agy_zip_finish(book,owner,ty,s11)

@unsafe
def agy_zip_try_ctors(+book: List<&2,KDef>, +owner: String, +ty: String, cs: List<&2,KDef>) -> AgyZipPlan:
  match cs:
    case Con{+a,Con{+b,Nil{}}}:
      nt_choose(AgyZipPlan,x198pw_ctor(a,dn(a),[],ty) && x198pw_ctor(b,dn(b),[ty,"U32",ty],ty),
        u => agy_zip_check_family(book,owner,ty,dn(a),dn(b)),
        u => nt_choose(AgyZipPlan,x198pw_ctor(b,dn(b),[],ty) && x198pw_ctor(a,dn(a),[ty,"U32",ty],ty),
          v => agy_zip_check_family(book,owner,ty,dn(b),dn(a)),
          v => AgyZipNone{}))
    case _: AgyZipNone{}

@unsafe
def agy_zip_ready(+plans: List<&2,AgyZipPlan>, p: P169Prepared) -> P169Prepared:
  match p:
    case P169Prepared{forwards,+cursor,+error}:
      P169Prepared{forwards,nt_choose(P134Cursor,String.is_empty(error) && Bool.not(List.is_empty(&2,AgyZipPlan,plans)),
        u => agy_zip_cursor(plans,cursor),u => cursor),error}

law agy_ro_parse_expr:
  for +book: List<&2,KDef>
  for +owner: String
  for +t: KTerm
  for +f0_id: U32
  for +f0_k: U32
  for +f1_id: U32
  for +f1_k: U32
  for +x_id: U32
  for +has_x: Bool
  for +fuel: U32
  Maybe<&2,KTerm>

@unsafe
def agy_ro_parse_bin_l(+book: List<&2,KDef>, +owner: String, +op: String, +b: KTerm,
    +f0_id: U32, +f0_k: U32, +f1_id: U32, +f1_k: U32, +x_id: U32, +has_x: Bool, +fuel: U32,
    ra: Maybe<&2,KTerm>) -> Maybe<&2,KTerm>:
  match ra:
    case None{}: None{}
    case Some{ea}:
      agy_ro_parse_bin_r(op,ea,agy_ro_parse_expr(book,owner,b,f0_id,f0_k,f1_id,f1_k,x_id,has_x,fuel))

@unsafe
def agy_ro_parse_bin(+book: List<&2,KDef>, +owner: String, +op: String, +a: KTerm, +b: KTerm,
    +f0_id: U32, +f0_k: U32, +f1_id: U32, +f1_k: U32, +x_id: U32, +has_x: Bool, +fuel: U32) -> Maybe<&2,KTerm>:
  agy_ro_parse_bin_l(book,owner,op,b,f0_id,f0_k,f1_id,f1_k,x_id,has_x,fuel,
    agy_ro_parse_expr(book,owner,a,f0_id,f0_k,f1_id,f1_k,x_id,has_x,fuel))

@unsafe
def agy_ro_parse_prim(+book: List<&2,KDef>, +owner: String, +fn_name: String, +a: KTerm, +b: KTerm,
    +f0_id: U32, +f0_k: U32, +f1_id: U32, +f1_k: U32, +x_id: U32, +has_x: Bool, +fuel: U32) -> Maybe<&2,KTerm>:
  +d = lookup(book,fn_name)
  +op = agy_ro_prim_op(nc_primitive_name(dn(d)))
  nt_choose(Maybe<&2,KTerm>,nc_native_def(d) && U32.is_eq(da(d),2) && Bool.not(String.is_empty(op)),
    u => agy_ro_parse_bin(book,owner,op,a,b,f0_id,f0_k,f1_id,f1_k,x_id,has_x,fuel),
    u => None{})

@unsafe
def agy_ro_parse_app(+book: List<&2,KDef>, +owner: String, spine: KPChain,
    +f0_id: U32, +f0_k: U32, +f1_id: U32, +f1_k: U32, +x_id: U32, +has_x: Bool, +fuel: U32) -> Maybe<&2,KTerm>:
  match spine:
    case KPChain{Con{+a,Nil{}},+hd}:
      +hu = nc_unann(hd)
      nt_choose(Maybe<&2,KTerm>,Bool.not(has_x) && agy_str_eq(tg(hu),"Ref") && agy_str_eq(nm(hu),owner),
        u => nt_choose(Maybe<&2,KTerm>,U32.is_gt(agy_ro_rec_field(a,f0_id,f0_k,f1_id,f1_k),0),
          v => Some{kt("RoRec","",U32.sub(agy_ro_rec_field(a,f0_id,f0_k,f1_id,f1_k),1),0,[])},
          v => None{}),
        u => None{})
    case KPChain{Con{+a,Con{+b,Nil{}}},+hd}:
      +hu = nc_unann(hd)
      nt_choose(Maybe<&2,KTerm>,agy_str_eq(tg(hu),"Ref"),
        u => nt_choose(Maybe<&2,KTerm>,has_x && agy_str_eq(nm(hu),owner) && agy_ro_is_x(b,x_id,has_x),
          v => nt_choose(Maybe<&2,KTerm>,U32.is_gt(agy_ro_rec_field(a,f0_id,f0_k,f1_id,f1_k),0),
            w => Some{kt("RoRec","",U32.sub(agy_ro_rec_field(a,f0_id,f0_k,f1_id,f1_k),1),0,[])},
            w => None{}),
          v => agy_ro_parse_prim(book,owner,nm(hu),a,b,f0_id,f0_k,f1_id,f1_k,x_id,has_x,fuel)),
        u => None{})
    case _: None{}

@unsafe
def agy_ro_parse_expr(book,owner,t,f0_id,f0_k,f1_id,f1_k,x_id,has_x,fuel):
  +u = nc_unann(t)
  nt_choose(Maybe<&2,KTerm>,U32.is_eq(fuel,0),u0 => None{},u0 =>
    nt_choose(Maybe<&2,KTerm>,agy_str_eq(tg(u),"Lit") && agy_str_eq(nm(u),"U32"),
      u1 => Some{kt("RoConst","",kl_number(u),0,[])},u1 =>
      nt_choose(Maybe<&2,KTerm>,agy_str_eq(tg(u),"Var"),
        u2 => agy_ro_lookup_var(ix(u),f0_id,f0_k,f1_id,f1_k,x_id,has_x),u2 =>
        nt_choose(Maybe<&2,KTerm>,agy_str_eq(tg(u),"App"),
          u3 => agy_ro_parse_app(book,owner,x198pw_spine(u,[],4),f0_id,f0_k,f1_id,f1_k,x_id,has_x,U32.sub(fuel,1)),
          u3 => None{}))))

@unsafe
def agy_ro_peel_x(+book: List<&2,KDef>, +owner: String, +body: KTerm,
    +f0_id: U32, +f0_k: U32, +f1_id: U32, +f1_k: U32, +has_x: Bool) -> Maybe<&2,KTerm>:
  +u = nc_unann(body)
  nt_choose(Maybe<&2,KTerm>,has_x,
    v => nt_choose(Maybe<&2,KTerm>,agy_str_eq(tg(u),"Lam") && U32.is_eq(terms_len(ks(u)),1),
      w => agy_ro_parse_expr(book,owner,kid(u,0),f0_id,f0_k,f1_id,f1_k,ix(u),True{},32),
      w => None{}),
    v => agy_ro_parse_expr(book,owner,u,f0_id,f0_k,f1_id,f1_k,0,False{},32))

@unsafe
def agy_ro_peel_arm2(+book: List<&2,KDef>, +owner: String, +body: KTerm, +f0_id: U32, +k0: U32, +k1: U32, +has_x: Bool) -> Maybe<&2,KTerm>:
  +u1 = nc_unann(body)
  nt_choose(Maybe<&2,KTerm>,agy_str_eq(tg(u1),"Lam") && U32.is_eq(terms_len(ks(u1)),1),
    v => agy_ro_peel_x(book,owner,kid(u1,0),f0_id,k0,ix(u1),k1,has_x),
    v => None{})

@unsafe
def agy_ro_peel_arm(+book: List<&2,KDef>, +owner: String, +arm: KTerm, +fields: List<&2,U32>, +has_x: Bool) -> Maybe<&2,KTerm>:
  match fields:
    case Nil{}:
      agy_ro_peel_x(book,owner,arm,0,0,0,0,has_x)
    case Con{+k0,Nil{}}:
      +u0 = nc_unann(arm)
      nt_choose(Maybe<&2,KTerm>,agy_str_eq(tg(u0),"Lam") && U32.is_eq(terms_len(ks(u0)),1),
        v => agy_ro_peel_x(book,owner,kid(u0,0),ix(u0),k0,0,0,has_x),
        v => None{})
    case Con{+k0,Con{+k1,Nil{}}}:
      +u0 = nc_unann(arm)
      nt_choose(Maybe<&2,KTerm>,agy_str_eq(tg(u0),"Lam") && U32.is_eq(terms_len(ks(u0)),1),
        v => agy_ro_peel_arm2(book,owner,kid(u0,0),ix(u0),k0,k1,has_x),
        v => None{})
    case _: None{}

@unsafe
def agy_fl_ready(+plans: List<&2,AgyFlowPlan>, p: P169Prepared) -> P169Prepared:
  match p:
    case P169Prepared{forwards,+cursor,+error}:
      P169Prepared{forwards,nt_choose(P134Cursor,String.is_empty(error) && Bool.not(List.is_empty(&2,AgyFlowPlan,plans)),
        u => agy_fl_cursor(plans,cursor),u => cursor),error}

@unsafe
def x199s_scalar(stmt: N111Stmt, params: List<&2,String>, +state: X199ScanState) -> Maybe<&2,X199ScanState>:
  match stmt state:
    case N111Set{name,N111U64{},value} X199ScanState{+env,+loads,+stores}:
      x199s_bound(name,x199s_token(value,env),params,state)
    case N111Set{name,N111U32{},value} X199ScanState{+env,+loads,+stores}:
      x199s_bound(name,x199s_narrow(x199s_token(value,env)),params,state)
    case N111Bin{name,typ,op,left,right} X199ScanState{+env,+loads,+stores}:
      x199s_bound(name,x199s_bin(typ,op,x199s_token(left,env),x199s_token(right,env)),params,state)
    case N111Offset{name,base,bytes} X199ScanState{+env,+loads,+stores}:
      nt_choose(Maybe<&2,X199ScanState>,U32.is_eq(x199s_token(base,env),5) && U32.is_eq(x199s_token(bytes,env),14),
        u => x199s_bound(name,15,params,state),u => None{})
    case N111Load{name,N111U32{},base,offset} X199ScanState{+env,+loads,+stores}:
      nt_choose(Maybe<&2,X199ScanState>,U32.is_eq(x199s_token(base,env),15) && U32.is_eq(offset,0) &&
          U32.is_eq(loads,0) && U32.is_eq(stores,0),
        u => x199s_bound(name,16,params,X199ScanState{env,1,0}),u => None{})
    case N111Store{N111U32{},base,offset,value} X199ScanState{+env,+loads,+stores}:
      nt_choose(Maybe<&2,X199ScanState>,U32.is_eq(x199s_token(base,env),15) && U32.is_eq(offset,0) &&
          U32.is_eq(x199s_token(value,env),19) && U32.is_eq(loads,1) && U32.is_eq(stores,0),
        u => Some{X199ScanState{env,1,1}},u => None{})
    case _ _: None{}

@unsafe
def x199s_walk(body: List<&2,P113DStmt>, +params: List<&2,String>, state: Maybe<&2,X199ScanState>, +budget: U32) -> Bool:
  match body state:
    case Con{P113DAgain{values},Nil{}} Some{current}: x199s_again(values,current)
    case Con{P113DScalar{stmt},rest} Some{current}:
      U32.is_gt(budget,0) && x199s_walk(rest,params,x199s_scalar(stmt,params,current),U32.sub(budget,1))
    case _ _: False{}

@unsafe
def x199s_positive(+body: List<&2,P113DStmt>, +params: List<&2,String>, +fuel: String,
    +index: String, +array: String, +carry: String) -> List<&2,P113DStmt>:
  match body:
    case Con{P113DScalar{N111Bin{+test,N111U64{},+op,+left,+right}},Con{P113DIf{+condition,+yes,+no},Nil{}}}:
      nt_choose(List<&2,P113DStmt>,agy_str_eq(op,"ne") && x185_sf_source(left,fuel) && x192_p_constant(right,0) &&
          x185_sf_source(condition,test) && x199s_free(test,params) &&
          x199s_walk(yes,params,Some{X199ScanState{x199s_seed(fuel,index,array,carry),0,0}},64),
        u => [P113DScalar{N111Bin{test,N111U64{},op,left,right}},
          P113DIf{condition,x199s_call(fuel,index,array,carry),no}],u => body)
    case _: body

@unsafe
def x199s_select(+params: List<&2,String>, +body: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  match params body:
    case Con{state,Con{out,Con{+fuel,Con{+index,Con{+array,Con{+carry,Nil{}}}}}}}
        Con{P113DScalar{N111Bin{+test,N111U64{},+op,+left,+right}},Con{P113DIf{+condition,+yes,no},Nil{}}}:
      nt_choose(List<&2,P113DStmt>,agy_str_eq(state,"state") && agy_str_eq(out,"__x181_result_out") &&
          p113e_distinct(params) && agy_str_eq(op,"eq") && x185_sf_source(left,fuel) && x192_p_constant(right,0) &&
          x185_sf_source(condition,test) && x199s_free(test,params) && x199s_result(yes,array,carry),
        u => [P113DScalar{N111Bin{test,N111U64{},op,left,right}},
          P113DIf{condition,yes,x199s_positive(no,params,fuel,index,array,carry)}],u => body)
    case _ _: body

# These stages are the existing x185/x186 normalization pipeline with one
# selector before allocation. Non-admitted versions use the original entry.
@unsafe
def agy_dp_scalar(stmt: N111Stmt, params: List<&2,String>, +state: AgyDpState) -> Maybe<&2,AgyDpState>:
  match stmt state:
    case N111Set{name,N111U64{},value} AgyDpState{+env,+stores}:
      agy_dp_bound(name,agy_dp_tok(value,env),params,state)
    case N111Set{name,N111U32{},value} AgyDpState{+env,+stores}:
      agy_dp_bound(name,agy_dp_narrow(agy_dp_tok(value,env)),params,state)
    case N111Bin{name,typ,op,left,right} AgyDpState{+env,+stores}:
      agy_dp_bound(name,agy_dp_bin(typ,op,agy_dp_tok(left,env),agy_dp_tok(right,env)),params,state)
    case N111Offset{name,base,bytes} AgyDpState{+env,+stores}:
      +bt = agy_dp_tok(base,env)
      +yt = agy_dp_tok(bytes,env)
      +tok = nt_choose(U32,U32.is_eq(bt,4) && U32.is_eq(yt,15),u => 16,u =>
        nt_choose(U32,U32.is_eq(bt,6) && U32.is_eq(yt,22),v => 23,v =>
          nt_choose(U32,U32.is_eq(bt,6) && U32.is_eq(yt,26),w => 27,w =>
            nt_choose(U32,U32.is_eq(bt,8) && U32.is_eq(yt,30),z => 31,z =>
              nt_choose(U32,U32.is_eq(bt,8) && U32.is_eq(yt,41),q => 42,q => 0)))))
      agy_dp_bound(name,tok,params,state)
    case N111Load{name,N111U32{},base,offset} AgyDpState{+env,+stores}:
      +bt = agy_dp_tok(base,env)
      +tok = nt_choose(U32,U32.is_eq(offset,0) && U32.is_eq(stores,0),u =>
        nt_choose(U32,U32.is_eq(bt,16),v => 17,v =>
          nt_choose(U32,U32.is_eq(bt,23),w => 24,w =>
            nt_choose(U32,U32.is_eq(bt,27),z => 28,z =>
              nt_choose(U32,U32.is_eq(bt,31),q => 32,q => 0)))),u => 0)
      agy_dp_bound(name,tok,params,state)
    case N111Store{N111U32{},base,offset,value} AgyDpState{+env,+stores}:
      nt_choose(Maybe<&2,AgyDpState>,U32.is_eq(agy_dp_tok(base,env),42) && U32.is_eq(offset,0) &&
          U32.is_eq(agy_dp_tok(value,env),39) && U32.is_eq(stores,0),
        u => Some{AgyDpState{env,1}},u => None{})
    case _ _: None{}

@unsafe
def agy_dp_if(cond: N111Value, yes: List<&2,P113DStmt>, no: List<&2,P113DStmt>,
    params: List<&2,String>, +state: AgyDpState) -> Maybe<&2,AgyDpState>:
  match yes no state:
    # Skip empty no-op diamonds left by predicate pass
    case Nil{} Nil{} _: Some{state}
    # Select diamond: if cond: dst = yv else: dst = nv
    case Con{P113DScalar{N111Set{+yn,N111U64{},yv}},Nil{}}
         Con{P113DScalar{N111Set{+nn,N111U64{},nv}},Nil{}}
         AgyDpState{+env,+stores}:
      +ct = agy_dp_tok(cond,env)
      +yt = agy_dp_tok(yv,env)
      +nt = agy_dp_tok(nv,env)
      +tok = nt_choose(U32,agy_str_eq(yn,nn),u =>
        nt_choose(U32,(U32.is_eq(ct,19) && U32.is_eq(yt,50) && U32.is_eq(nt,51)) ||
            (U32.is_eq(ct,18) && U32.is_eq(yt,51) && U32.is_eq(nt,50)),v => 20,v =>
          nt_choose(U32,U32.is_eq(ct,35) && U32.is_eq(yt,33) && U32.is_eq(nt,34),w => 36,w =>
            nt_choose(U32,U32.is_eq(ct,38) && U32.is_eq(yt,36) && U32.is_eq(nt,37),z => 39,z => 0))),u => 0)
      agy_dp_bound(yn,tok,params,state)
    case _ _ _: None{}

@unsafe
def agy_dp_walk(body: List<&2,P113DStmt>, +params: List<&2,String>, +a: String, +b: String, +p: String, +c: String,
    state: Maybe<&2,AgyDpState>, +budget: U32) -> Bool:
  match body state:
    case Con{P113DAgain{values},Nil{}} Some{cur}: agy_dp_again(values,a,b,p,c,cur)
    case Con{P113DScalar{stmt},rest} Some{cur}:
      U32.is_gt(budget,0) && agy_dp_walk(rest,params,a,b,p,c,agy_dp_scalar(stmt,params,cur),U32.sub(budget,1))
    case Con{P113DIf{cond,yes,no},rest} Some{cur}:
      U32.is_gt(budget,0) && agy_dp_walk(rest,params,a,b,p,c,agy_dp_if(cond,yes,no,params,cur),U32.sub(budget,1))
    case _ _: False{}

@unsafe
def agy_dp_positive(body: List<&2,P113DStmt>, +params: List<&2,String>, +fuel: String, +idx: String, +ai: String,
    +a: String, +b: String, +p: String, +c: String) -> Bool:
  match body:
    case Con{P113DScalar{N111Bin{+test,N111U64{},+op,+left,+right}},Con{P113DIf{+cond,+yes,no},Nil{}}}:
      (agy_str_eq(op,"ne") && x185_sf_source(left,fuel) && x192_p_constant(right,0) &&
      x185_sf_source(cond,test) && agy_dp_free(test,params) &&
      agy_dp_walk(yes,params,a,b,p,c,Some{AgyDpState{agy_dp_seed(fuel,idx,ai),0}},128)) ||
      agy_dp_walk(body,params,a,b,p,c,Some{AgyDpState{agy_dp_seed(fuel,idx,ai),0}},128)
    case _: agy_dp_walk(body,params,a,b,p,c,Some{AgyDpState{agy_dp_seed(fuel,idx,ai),0}},128)

@unsafe
def agy_dp_certify(+params: List<&2,String>, body: List<&2,P113DStmt>) -> Bool:
  match params body:
    case Con{state,Con{out,Con{+fuel,Con{+idx,Con{+ai,Con{+a,Con{+b,Con{+p,Con{+c,Nil{}}}}}}}}}}
         Con{P113DScalar{N111Bin{+test,N111U64{},+op,+left,+right}},Con{P113DIf{+cond,+yes,no},Nil{}}}:
      agy_str_eq(state,"state") && agy_str_eq(out,"__x181_result_out") &&
      p113e_distinct(params) && agy_str_eq(op,"eq") && x185_sf_source(left,fuel) &&
      x192_p_constant(right,0) && x185_sf_source(cond,test) && agy_dp_free(test,params) &&
      agy_dp_result(yes,a,b,p,c) && agy_dp_positive(no,params,fuel,idx,ai,a,b,p,c)
    case _ _: False{}

# ---- x86 emitter for certified 1D DP stencil loop ----
# Incoming SysV ABI:
#   %rdi(7)=state, %rsi(6)=out, %rdx(2)=n, %rcx(1)=j, %r8(8)=ai, %r9(9)=a,
#   8(%rsp)=b, 16(%rsp)=prev, 24(%rsp)=cur
@unsafe
def agy_f32_call_op(+dst: String, args: List<&2,N111Arg>, +params: List<&2,String>, +st: AgyF32State) -> Maybe<&2,AgyF32State>:
  match args st:
    case Con{N111Arg{_,N111Local{st_name}},Con{N111Arg{_,N111Const{+op_id,0}},Con{N111Arg{_,N111Local{buf}},Con{N111Arg{_,N111Const{+cnt,0}},Nil{}}}}}
         AgyF32State{+env,+s0,+s8,+obs,+has_obs}:
      +sse = agy_f32_sse_op(op_id)
      nt_choose(Maybe<&2,AgyF32State>,agy_str_eq(st_name,"state") && agy_str_eq(buf,"scratch"),
        u => nt_choose(Maybe<&2,AgyF32State>,U32.is_eq(cnt,2) && Bool.not(String.is_empty(sse)),
          v => agy_f32_call_fbin(dst,sse,s0,s8,params,env,obs,has_obs),
          v => nt_choose(Maybe<&2,AgyF32State>,U32.is_eq(op_id,58) && U32.is_eq(cnt,1),
            w => agy_f32_call_tou32(dst,s0,params,env,has_obs),
            w => None{})),
        u => None{})
    case _ _: None{}

@unsafe
def agy_f32_scalar(stmt: N111Stmt, +params: List<&2,String>, +st: AgyF32State) -> Maybe<&2,AgyF32State>:
  match stmt st:
    case N111Store{N111U64{},N111Local{buf},+off,+val} AgyF32State{+env,+s0,+s8,+obs,+has_obs}:
      nt_choose(Maybe<&2,AgyF32State>,agy_str_eq(buf,"scratch"),
        u => nt_choose(Maybe<&2,AgyF32State>,U32.is_eq(off,0),
          v => Some{AgyF32State{env,Some{val},s8,obs,has_obs}},
          v => nt_choose(Maybe<&2,AgyF32State>,U32.is_eq(off,8),
            w => Some{AgyF32State{env,s0,Some{val},obs,has_obs}},
            w => None{})),
        u => None{})
    case N111Call{dst,N111U64{},sym,args} _:
      nt_choose(Maybe<&2,AgyF32State>,agy_str_eq(sym,"p111_rt_op"),
        u => agy_f32_call_op(dst,args,params,st),
        u => None{})
    case N111Set{dst,_,val} AgyF32State{+env,+s0,+s8,+obs,+has_obs}:
      agy_f32_set_copy(dst,val,params,env,s0,s8,obs,has_obs)
    case N111Bin{+dst,typ,+op,+left,+right} AgyF32State{+env,+s0,+s8,+obs,+has_obs}:
      +alu = agy_f32_u32_op(op)
      nt_choose(Maybe<&2,AgyF32State>,agy_str_eq(op,"sub") && agy_f32_val_fuel(left,env,"Fuel") && x192_p_constant(right,1) && agy_f32_free(dst,params),
        u => Some{AgyF32State{agy_f32_put(env,dst,"FuelSub",kt("None","",0,0,[])),s0,s8,obs,has_obs}},
        u => nt_choose(Maybe<&2,AgyF32State>,Bool.not(String.is_empty(alu)),
          v => agy_f32_bin_u(dst,alu,agy_f32_val_u(left,env),agy_f32_val_u(right,env),params,env,s0,s8,obs,has_obs),
          v => None{}))
    case _ _: None{}

@unsafe
def agy_f32_walk(body: List<&2,P113DStmt>, +params: List<&2,String>, st: Maybe<&2,AgyF32State>, +budget: U32) -> AgyF32Plan:
  match body st:
    case Con{P113DAgain{values},Nil{}} Some{cur}: agy_f32_again(values,cur)
    case Con{P113DScalar{stmt},rest} Some{cur}:
      nt_choose(AgyF32Plan,U32.is_gt(budget,0),
        u => agy_f32_walk(rest,params,agy_f32_scalar(stmt,params,cur),U32.sub(budget,1)),
        u => AgyF32No{})
    case _ _: AgyF32No{}

@unsafe
def agy_f32_positive(body: List<&2,P113DStmt>, +params: List<&2,String>, +fuel: String, +x: String, +h: String) -> AgyF32Plan:
  match body:
    case Con{P113DScalar{N111Bin{+test,N111U64{},+op,+left,+right}},Con{P113DIf{+cond,+yes,no},Nil{}}}:
      nt_choose(AgyF32Plan,agy_str_eq(op,"ne") && x185_sf_source(left,fuel) && x192_p_constant(right,0) &&
          x185_sf_source(cond,test) && agy_f32_free(test,params),
        u => agy_f32_walk(yes,params,Some{AgyF32State{agy_f32_seed(fuel,x,h),None{},None{},None{},False{}}},64),
        u => AgyF32No{})
    case _: AgyF32No{}

@unsafe
def agy_bp_apply(prepared: P169Prepared, +map_ok: Bool, +arr_ok: Bool) -> P169Prepared:
  match prepared:
    case P169Prepared{forwards,+cursor,+error}:
      P169Prepared{forwards,nt_choose(P134Cursor,(map_ok || arr_ok) && String.is_empty(error),
        u => agy_bp_cursor(cursor,map_ok,arr_ok),u => cursor),error}

@unsafe
def agy_bp_annotate(r: NR_Request, +prepared: P169Prepared) -> P169Prepared:
  match r:
    case NR_Request{source,+book,names,paths,scope,bound}:
      agy_bp_apply(prepared,agy_bp_map_pinned(book),agy_bp_arr_pinned(book))



# ============================================================================
# AGY-W5B-STRHASH: Certified Native x86-64 String/Hash/Tag Fast Paths (Wave 5B)
# ============================================================================

@unsafe
def agy_sh_apply(prepared: P169Prepared, +eq_go_ok: Bool, +eq_ok: Bool, +agy_eq_ok: Bool,
    +base_eq_ok: Bool, +hash_ok: Bool, +tageq_ok: Bool, +tageq_read_ok: Bool) -> P169Prepared:
  match prepared:
    case P169Prepared{forwards,+cursor,+error}:
      +any_ok = eq_go_ok || eq_ok || agy_eq_ok || base_eq_ok || hash_ok || tageq_ok || tageq_read_ok
      P169Prepared{forwards,nt_choose(P134Cursor,any_ok && String.is_empty(error),
        u => agy_sh_cursor(cursor,eq_go_ok,eq_ok,agy_eq_ok,base_eq_ok,hash_ok,tageq_ok,tageq_read_ok),u => cursor),error}

@unsafe
def agy_sh_annotate(r: NR_Request, +prepared: P169Prepared) -> P169Prepared:
  match r:
    case NR_Request{source,+book,names,paths,scope,bound}:
      +adts = agy_sh_str_adts_ok(book)
      +chr_eq_ok = agy_sh_def_pin(book,"Char.is_eq",3302228733,42192839)
      +chr_u32_ok = agy_sh_def_pin(book,"Char.to_u32",1968267531,1583642761)
      +base_eq_ok = adts && chr_u32_ok &&
        agy_sh_def_pin(book,"String.eq",225128774,712577888) &&
        agy_sh_def_pin(book,"String.order",565631753,2204196711) &&
        agy_sh_def_pin(book,"String.order.go",3716281844,3937681030)
      +eq_go_ok = adts && (
        (chr_eq_ok && agy_sh_def_pin(book,"p88_string_eq_go",3024631756,2674381182)) ||
        (chr_u32_ok && agy_sh_def_pin(book,"p88_string_eq_go",1723204692,4196828370)))
      +eq_ok =
        (eq_go_ok && agy_sh_def_pin(book,"p98_eq_finish",165389557,2460805607) &&
          agy_sh_def_pin(book,"p88_string_eq",3716379759,1182868109)) ||
        (base_eq_ok && agy_sh_def_pin(book,"p88_string_eq",1506689157,1260695159))
      +agy_eq_ok = base_eq_ok && agy_sh_def_pin(book,"agy_str_eq",339807906,3620894948)
      +hash_ok = adts && chr_u32_ok && agy_sh_def_pin(book,"index_hash",1696180074,3131242088)
      +kt_adts = agy_sh_kterm_adt_ok(book)
      +tageq_read_ok = kt_adts && (
        (eq_ok && agy_sh_def_pin(book,"p98_tag_eq_read",572502218,3139754552)) ||
        (base_eq_ok && agy_sh_def_pin(book,"p98_tag_eq_read",2686625593,3004633447)))
      +tageq_ok = kt_adts && (
        (tageq_read_ok && agy_sh_def_pin(book,"p98_tag_eq_finish",133393152,3410656966) &&
          agy_sh_def_pin(book,"p98_tag_eq",2318141704,1837477542)) ||
        (base_eq_ok && agy_sh_def_pin(book,"p98_tag_eq",2108109257,3206482399)))
      agy_sh_apply(prepared,eq_go_ok,eq_ok,agy_eq_ok,base_eq_ok,hash_ok,tageq_ok,tageq_read_ok)


@unsafe
def agy_map_ready(ok: Bool, p: P169Prepared) -> P169Prepared:
  match p:
    case P169Prepared{forwards,+cursor,+error}:
      P169Prepared{forwards,nt_choose(P134Cursor,ok && String.is_empty(error),
        u => agy_map_cursor(cursor),u => cursor),error}

@unsafe
def agy_map_annotate(r: NR_Request, +prepared: P169Prepared) -> P169Prepared:
  match r:
    case NR_Request{source,+book,names,paths,scope,bound}:
      agy_map_ready(agy_map_book_ok(book),prepared)

@unsafe
def x187_elf_globals(items: List<&2,X187Symbol>, sizes: X187ElfSizes, state: X187ElfSymbols) -> X187ElfSymbols:
  match state:
    case X187ElfSymbols{index,+count,firstGlobal,table,strings,stringSize,error}:
      x187_elf_symbols(items,True{},sizes,X187ElfSymbols{index,count,count,table,strings,stringSize,error})

@unsafe
def x187_elf_sized(+object: X187Object, +sizes: X187ElfSizes) -> X187ObjectResult:
  match object:
    case X187Object{text,rodata,data,+symbols,relocations}:
      x187_elf_checked(object,sizes,x187_elf_globals(symbols,sizes,
        x187_elf_symbols(symbols,False{},sizes,X187ElfSymbols{missing(),1,1,x187_elf_zero(24,[]),[0],1,""})))

@unsafe
def x201e_size_data(object: X187Object, text: U32, rodata: U32, +data: U32) -> X187ObjectResult:
  nt_choose(X187ObjectResult,U32.is_le(data,67108864),
    u => x187_elf_sized(object,X187ElfSizes{text,rodata,data}),
    u => X187ObjectResult{[],"invalid or oversized ELF section bytes"})

@unsafe
def x201e_size_rodata(object: X187Object, data: List<&2,U32>, text: U32, +rodata: U32) -> X187ObjectResult:
  nt_choose(X187ObjectResult,U32.is_le(rodata,67108864),
    u => x201e_size_data(object,text,rodata,x201e_checked_size(data,0)),
    u => X187ObjectResult{[],"invalid or oversized ELF section bytes"})

@unsafe
def x187_build_symbol(+name: String, +mode: U32, +value: U32, +build: X187Build) -> X187Build:
  x201s_symbol(name,mode,value,index_hash(name,2166136261),build)

@unsafe
def x201s_symbol(+name: String, mode: U32, value: U32, +hash: U32, +build: X187Build) -> X187Build:
  match build:
    case X187Build{s,t,r,d,ts,rs,ds,symbols,names,relocs,error}:
      x201s_found(name,mode,value,hash,build,index_find(symbols,name,hash,32))

@unsafe
def w5b_be_if(ok: Bool, bytes: List<&2,U32>, relocs: List<&2,X187Relocation>, error: String, +build: X187Build) -> X187Build:
  match ok:
    case True{}: x187_build_relocations(relocs,x187_build_bytes(bytes,build))
    case False{}: x187_build_error(error,build)

@unsafe
def x187_build_encoded(+encoded: X187Encoded, +build: X187Build) -> X187Build:
  match encoded:
    case X187Encoded{bytes,relocs,+error}:
      w5b_be_if(String.is_empty(error),bytes,relocs,error,build)

# Tag only an encoder-authenticated local branch. RIP address loads and calls
# retain their ordinary relocation kinds and therefore retain symbol identity.
# Kind 130 is private to this builder and must never reach the ELF validator.
@unsafe
def w7_build_inst_enc(enc: X187Encoded, +inst: X187Instruction, +build: X187Build) -> X187Build:
  match enc:
    case X187Encoded{bytes,Nil{},SNil{}}: x187_build_bytes(bytes,build)
    case other: x187_build_encoded(x188_branch_encoded(inst,other),build)

@unsafe
def x188_build_instruction(+inst: X187Instruction, +build: X187Build) -> X187Build:
  w7_build_inst_enc(x187_encode(inst,x187_build_offset(build)),inst,build)

@unsafe
def x188_fixup_item(+reloc: X187Relocation, +index: KDef, +size: U32, +state: X188Fixups) -> X188Fixups:
  match reloc:
    case X187Relocation{section,offset,+kind,name,lo,hi}:
      nt_choose(X188Fixups,U32.is_eq(kind,130),
        u => x188_fixup_symbol(reloc,size,state,p111v_get(index,name)),
        u => x188_fixup_keep(reloc,state))

@unsafe
def x188_fixup_scan(items: List<&2,X187Relocation>, +index: KDef, +size: U32,
    +count: U32, +state: X188Fixups) -> X188Fixups:
  match items:
    case Nil{}: state
    case Con{head,rest}:
      nt_choose(X188Fixups,U32.is_lt(count,1048576),
        u => x188_fixup_scan(rest,index,size,U32.inc(count),x188_fixup_item(head,index,size,state)),
        u => x188_fixup_error("invalid ELF relocation",state))

@unsafe
def x187_build_symbols(+names: List<&2,String>, +index: KDef, +escaped: KDef, +sizes: X187ElfSizes,
    +acc: List<&2,X187Symbol>, +object: X187Object) -> X187ObjectResult:
  match names:
    case Nil{}:
      match object:
        case X187Object{text,rodata,data,symbols,relocations}:
          x187_elf_sized(X187Object{text,rodata,data,acc,relocations},sizes)
    case Con{+name,rest}: x187_build_symbol_final(name,rest,index,escaped,sizes,acc,object,p111v_get(index,name))

@unsafe
def x187_build_symbol_final(+name: String, +rest: List<&2,String>, +index: KDef, +escaped: KDef, +sizes: X187ElfSizes,
    +acc: List<&2,X187Symbol>, +object: X187Object, +symbol: KDef) -> X187ObjectResult:
  match symbol:
    case KDef{n,k,section,value,KTerm{tk,tn,size,kind,kids,removed,begin,end},v,c,+global,+defined}:
      nt_choose(X187ObjectResult,Bool.not(defined) && String.starts_with(name,".L"),
        u => X187ObjectResult{[],"undefined local label: " ++ name},u =>
        x188_build_symbol_checked(X187Symbol{name,section,value,size,global || Bool.not(defined),kind},
          rest,index,escaped,sizes,acc,object))
    case _: X187ObjectResult{[],"invalid final object symbol"}

@unsafe
def x188_build_symbol_checked(+symbol: X187Symbol, rest: List<&2,String>, index: KDef, +escaped: KDef,
    +sizes: X187ElfSizes, +acc: List<&2,X187Symbol>, object: X187Object) -> X187ObjectResult:
  match symbol:
    case X187Symbol{+name,section,value,size,+global,kind}:
      nt_choose(X187ObjectResult,x187_elf_symbol_valid(symbol,sizes),u =>
        x187_build_symbols(rest,index,escaped,sizes,
          nt_choose(List<&2,X187Symbol>,Bool.not(global) && String.starts_with(name,".L") &&
              agy_str_eq(dk(p111v_get(escaped,name)),"Absent"),v => acc,v => Con{symbol,acc}),object),
        u => X187ObjectResult{[],"invalid or duplicate ELF symbol"})

@unsafe
def x188_build_patched(names: List<&2,String>, index: KDef, escaped: KDef, sizes: X187ElfSizes,
    rodata: List<&2,U32>, data: List<&2,U32>, relocations: List<&2,X187Relocation>, patched: X187Encoded) -> X187ObjectResult:
  match patched:
    case X187Encoded{bytes,unused,+error}:
      nt_choose(X187ObjectResult,String.is_empty(error),
        u => x187_build_symbols(names,index,escaped,sizes,[],X187Object{bytes,rodata,data,[],relocations}),
        u => X187ObjectResult{[],error})

@unsafe
def agy_p114h_plan_hygiene_ok(+name: String, +params: List<&2,String>, +body: List<&2,P114RStmt>,
    +cases: List<&2,P114HCase>, +available: KDef) -> Bool:
  +fparams = x192h_formals(params)
  +setup : List<&2,P113DStmt> = Con{P113DScalar{N111Alloca{"scratch",2048,8}},x192h_buffers(cases,0)}
  +wbody = x192h_worker_body(params,body,cases)
  +adapter = x192h_adapter(name,params)
  String.is_empty(p111_first(x181_program_stmts(setup,available),p111_first(x181_program_stmts(wbody,available),
    p111_first(x181_program_stmts(adapter,available),p111_first(x181_hygiene_names(fparams),
      p111_first(x181_hygiene_stmts(setup),p111_first(x181_hygiene_stmts(wbody),x181_hygiene_stmts(adapter))))))))

@unsafe
def agy_p114h_plan_hygiene(+name: String, +available: KDef, plan: P114HPlan) -> Bool:
  match plan:
    case P114HPlan{valid,params,body,cases}:
      nt_choose(Bool,valid,u => agy_p114h_plan_hygiene_ok(name,params,body,cases,available),u => False{})

@unsafe
def x202p_x187_elf_sized(+object: X187Object, +sizes: X187ElfSizes) -> IO(U32):
  match object:
    case X187Object{text,rodata,data,+symbols,relocations}:
      x202p_x187_elf_checked(object,sizes,x187_elf_globals(symbols,sizes,
        x187_elf_symbols(symbols,False{},sizes,X187ElfSymbols{missing(),1,1,x187_elf_zero(24,[]),[0],1,""})))

@unsafe
def x202p_x201e_size_data(object: X187Object, text: U32, rodata: U32, +data: U32) -> IO(U32):
  nt_choose(IO(U32),U32.is_le(data,67108864),
    u => x202p_x187_elf_sized(object,X187ElfSizes{text,rodata,data}),
    u => IO.die(U32,1,"invalid or oversized ELF section bytes"))

@unsafe
def x202p_x201e_size_rodata(object: X187Object, data: List<&2,U32>, text: U32, +rodata: U32) -> IO(U32):
  nt_choose(IO(U32),U32.is_le(rodata,67108864),
    u => x202p_x201e_size_data(object,text,rodata,x201e_checked_size(data,0)),
    u => IO.die(U32,1,"invalid or oversized ELF section bytes"))

