# Module m05a (K=14 acyclic topological split of wave12_unified/compiler.bend)
# defs=383 laws=40 sccs=261 deps=[m00a,m00b,m01,m02,m03,m04] cross_imports=419 fid_base=26800..29999

law core_apply:
  for +f: KTerm
  for +x: KTerm
  KTerm

# Module: src/core/term.bend:417
law book_final_filter:
  for +done: List<&2,KDef>
  for +seen: KDef
  List<&2,KDef>

# Module: src/core/index.bend:334
law norm_eval:
  for +book: List<&2, KDef>
  for +t: KTerm
  for +args: List<&2, KTerm>
  for +left: U32
  for +fallback: KTerm
  KTerm

# Module: src/core/normalize.bend:131
law norm_ref:
  for +book: List<&2, KDef>
  for +t: KTerm
  for +args: List<&2, KTerm>
  for +d: KDef
  KTerm

# Module: src/core/normalize.bend:141
law norm_args:
  for +book: List<&2, KDef>
  for +t: KTerm
  for +args: List<&2, KTerm>
  for +left: U32
  for +fallback: KTerm
  KTerm

# Module: src/core/normalize.bend:156
law norm_match:
  for +book: List<&2, KDef>
  for +arm: KTerm
  for +original: KTerm
  for +raw: KTerm
  for +x: KTerm
  for +args: List<&2, KTerm>
  for +left: U32
  for +fallback: KTerm
  KTerm

# Module: src/core/normalize.bend:178
law norm_min:
  for +book: List<&2, KDef>
  for +a: KTerm
  for +b: KTerm
  KTerm

# Module: src/core/normalize.bend:199
law norm_min_left:
  for +book: List<&2, KDef>
  for +a: KTerm
  for +b: KTerm
  KTerm

# Module: src/core/normalize.bend:208
law norm_var:
  for +book: List<&2, KDef>
  for +t: KTerm
  for +values: List<&2, KTerm>
  for +args: List<&2, KTerm>
  for +left: U32
  for +fallback: KTerm
  KTerm

# Module: src/core/normalize.bend:329
law norm_book_bound:
  for +book: List<&2, KDef>
  U32

# Module: src/core/normalize.bend:347
law g_eval:
  for +book: List<&2, KDef>
  for +st: GState
  for +t: KTerm
  for +args: List<&2, KTerm>
  for +pending: U32
  for +fallback: KTerm
  for +stack: List<&2, GFrame>
  GResult

# Module: src/core/graph.bend:55
law g_cell:
  for +book: List<&2, KDef>
  for +st: GState
  for +t: KTerm
  for +args: List<&2, KTerm>
  for +pending: U32
  for +fallback: KTerm
  for +stack: List<&2, GFrame>
  for +cell: KTerm
  GResult

# Module: src/core/graph.bend:66
law g_app:
  for +book: List<&2, KDef>
  for +fn: KTerm
  for +args: List<&2, KTerm>
  for +pending: U32
  for +fallback: KTerm
  for +stack: List<&2, GFrame>
  for +r: GResult
  GResult

# Module: src/core/graph.bend:76
law g_ref:
  for +book: List<&2, KDef>
  for +st: GState
  for +t: KTerm
  for +args: List<&2, KTerm>
  for +stack: List<&2, GFrame>
  for +d: KDef
  GResult

# Module: src/core/graph.bend:85
law g_args:
  for +book: List<&2, KDef>
  for +st: GState
  for +t: KTerm
  for +args: List<&2, KTerm>
  for +pending: U32
  for +fallback: KTerm
  for +stack: List<&2, GFrame>
  GResult

# Module: src/core/graph.bend:95
law g_return:
  for +book: List<&2, KDef>
  for +st: GState
  for +t: KTerm
  for +stack: List<&2, GFrame>
  GResult

# Module: src/core/graph.bend:102
law g_resume:
  for +book: List<&2, KDef>
  for +st: GState
  for +t: KTerm
  for +frame: GFrame
  for +stack: List<&2, GFrame>
  GResult

# Module: src/core/graph.bend:110
law g_filled:
  for +book: List<&2, KDef>
  for +id: U32
  for +args: List<&2, KTerm>
  for +pending: U32
  for +fallback: KTerm
  for +stack: List<&2, GFrame>
  for +r: GResult
  GResult

# Module: src/core/graph.bend:120
law g_min_left:
  for +book: List<&2, KDef>
  for +st: GState
  for +a: KTerm
  for +b: KTerm
  for +args: List<&2, KTerm>
  for +stack: List<&2, GFrame>
  GResult

# Module: src/core/graph.bend:129
law g_match:
  for +book: List<&2, KDef>
  for +st: GState
  for +arm: KTerm
  for +original: KTerm
  for +raw: KTerm
  for +x: KTerm
  for +args: List<&2, KTerm>
  for +pending: U32
  for +fallback: KTerm
  for +stack: List<&2, GFrame>
  GResult

# Module: src/core/graph.bend:142
law g_let:
  for +book: List<&2, KDef>
  for +st: GState
  for +ts: List<&2, KTerm>
  for +bindings: List<&2, KTerm>
  for +args: List<&2, KTerm>
  for +pending: U32
  for +fallback: KTerm
  for +stack: List<&2, GFrame>
  GResult

# Module: src/core/graph.bend:153
law g_let_shared:
  for +book: List<&2, KDef>
  for +h: KTerm
  for +rest: List<&2, KTerm>
  for +bindings: List<&2, KTerm>
  for +args: List<&2, KTerm>
  for +pending: U32
  for +fallback: KTerm
  for +stack: List<&2, GFrame>
  for +r: GResult
  GResult

# Module: src/core/graph.bend:165
law kr_parent:
  for book: List<&2, KDef>
  for +name: String
  KDef

# Module: src/core/reach.bend:43
law infer_adt_done:
  for +t: KTerm
  for +r: KChecking
  KChecking

# Module: src/check/kernel.bend:64
law sp_apply_template:
  for +body: KTerm
  for +xs: List<&2, KTerm>
  KTerm

# Module: src/check/prefix-state.bend:10
law ka_type_app:
  for +e: KEnv
  for +t: KTerm
  for +fty: KTerm
  KTerm

# Module: src/check/annotate.bend:59
law j_find_ctor:
  for +book: List<&2, KDef>
  for +name: String
  KDef

# Module: src/back/common/queries.bend:110
law j_found_ctor:
  for +found: KDef
  for +rest: List<&2, KDef>
  for +name: String
  KDef

# Module: src/back/common/queries.bend:120
law j_constructor_count:
  for +book: List<&2, KDef>
  for +ty: KTerm
  U32

# Module: src/back/common/queries.bend:206
law lookup:
  for +book: List<&2,KDef>
  for +name: String
  KDef

@unsafe
def w5c2_lookup_eq(hit: Bool, +d: KDef, +rest: List<&2,KDef>, +name: String) -> KDef:
  match hit:
    case True{}: d
    case False{}: lookup(rest, name)

@unsafe
def w5c2_lookup_cache(is_c: Bool, +d: KDef, +dname: String, +rest: List<&2,KDef>, +name: String) -> KDef:
  match is_c:
    case True{}: index_lookup(d, name)
    case False{}: w5c2_lookup_eq(String.eq(dname, name), d, rest, name)

@unsafe
def w5c2_lookup_head(+d: KDef, +rest: List<&2,KDef>, +name: String) -> KDef:
  match d:
    case KDef{dname, kind, _, _, _, _, _, _, _}:
      w5c2_lookup_cache(String.eq(kind, "BookCache"), d, dname, rest, name)
    case KIndexLeaf{_, _}:
      w5c2_lookup_eq(String.eq("", name), d, rest, name)
    case KIndexNode{_, _, _, _}:
      w5c2_lookup_eq(String.eq("", name), d, rest, name)

@unsafe
def lookup(book, name):
  match book:
    case Nil{}: missing()
    case Con{+d, +rest}: w5c2_lookup_head(d, rest, name)

# Module: src/core/term.bend:311
@unsafe
def core_apply(f, x):
  core_apply_span(f, x, 0, 0)

# Module: src/core/term.bend:403
@unsafe
def w7_br_3(w7_c: Bool, +t: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      core_apply_span(core_beta(kid(t, 0)), kid(t, 1), kb(t), ke(t))
    case False{}:
      t

@unsafe
def core_beta(
  +t: KTerm,
) -> KTerm:
  w7_br_3(p98_tag_eq(t, "App"), t)

# Scan in substitution order: Var test, children, then App rebuilding.
# A false fact returns to ordinary substitution, preserving its work and errors.
# A canonical App also survives substitution unchanged if both children do and
# its unchanged function is not Lam. Every metadata/arity check is necessary
# because core_rebuild canonicalizes App nodes even without beta reduction.

# Module: src/core/term.bend:427
@unsafe
def w5_idx_ins_leaf(isZero: Bool, +tree: KDef, +d: KDef, +hash: U32, +mask: U32, bucket: List<&2, KDef>) -> KDef:
  match isZero:
    case True{}: index_leaf(d, hash, bucket)
    case False{}: index_join(tree, d, hash, mask)

@unsafe
def index_put_rest(
  +cache: KDef,
  +rest: List<&2, KDef>,
  +name: String,
) -> List<&2, KDef>:
  kc(List<&2, KDef>, Bool.not(p88_string_eq(name, "")) && p88_string_eq(dn(index_lookup(cache, name)), ""),
    u => rest, u => index_remove(rest, name))

# Module: src/core/index.bend:282
@unsafe
def book_final_filter(done, seen):
  match done:
    case Nil{}: Nil{}
    case Con{d, rest}:
      kc(List<&2,KDef>, book_final_seen(seen, dn(d), index_hash(dn(d), 2166136261)),
        u => book_final_filter(rest, seen),
        u => Con{d, book_final_filter(rest, seen)})

# Module: src/core/index.bend:424
@unsafe
def w7_br_12(w7_c: Bool, +cache: KDef, +rest: List<&2,KDef>, +name: String) -> Bool:
  match w7_c:
    case True{}:
      True{}
    case False{}:
      w7_br_11(p88_string_eq(dn(index_lookup(cache, name)), ""), rest, name)

@unsafe
def wnf(
  +book: List<&2, KDef>,
  +t: KTerm,
) -> KTerm:
  norm_eval(book, t, Nil{}, 0, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})

# Module: src/core/normalize.bend:32
@unsafe
def norm_eval_node(
  +book: List<&2, KDef>,
  +t: KTerm,
  +args: List<&2, KTerm>,
  +left: U32,
  +fallback: KTerm,
) -> KTerm:
  norm_node_app(book, t, args, left, fallback, p98_tag_eq(t, "App"))

# Module: src/core/normalize.bend:42
@unsafe
def norm_node_app(
  +book: List<&2, KDef>,
  +t: KTerm,
  +args: List<&2, KTerm>,
  +left: U32,
  +fallback: KTerm,
  +selected: Bool,
) -> KTerm:
  match selected:
    case True{}:
      norm_eval(book, kid(t, 0), Con{kid(t, 1), args}, left, fallback)
    case False{}:
      norm_node_ann(book, t, args, left, fallback, p98_tag_eq(t, "Ann"))

# Module: src/core/normalize.bend:57
@unsafe
def norm_node_ann(
  +book: List<&2, KDef>,
  +t: KTerm,
  +args: List<&2, KTerm>,
  +left: U32,
  +fallback: KTerm,
  +selected: Bool,
) -> KTerm:
  match selected:
    case True{}:
      norm_eval(book, kid(t, 0), args, left, fallback)
    case False{}:
      norm_node_let(book, t, args, left, fallback, p98_tag_eq(t, "Let"))

# Module: src/core/normalize.bend:72
@unsafe
def norm_node_let(
  +book: List<&2, KDef>,
  +t: KTerm,
  +args: List<&2, KTerm>,
  +left: U32,
  +fallback: KTerm,
  +selected: Bool,
) -> KTerm:
  match selected:
    case True{}:
      norm_eval(book, norm_let(ks(t)), args, left, fallback)
    case False{}:
      norm_node_ref(book, t, args, left, fallback, p98_tag_eq(t, "Ref"))

# Module: src/core/normalize.bend:87
@unsafe
def norm_node_ref(
  +book: List<&2, KDef>,
  +t: KTerm,
  +args: List<&2, KTerm>,
  +left: U32,
  +fallback: KTerm,
  +selected: Bool,
) -> KTerm:
  match selected:
    case True{}:
      norm_ref(book, t, args, lookup(book, nm(t)))
    case False{}:
      norm_node_min(book, t, args, left, fallback, p98_tag_eq(t, "Min"))

# Module: src/core/normalize.bend:102
@unsafe
def norm_node_min(
  +book: List<&2, KDef>,
  +t: KTerm,
  +args: List<&2, KTerm>,
  +left: U32,
  +fallback: KTerm,
  +selected: Bool,
) -> KTerm:
  match selected:
    case True{}:
      norm_apply(norm_min(book, kid(t, 0), kid(t, 1)), args)
    case False{}:
      norm_node_rwt(book, t, args, left, fallback, p98_tag_eq(t, "Rwt"))

# Module: src/core/normalize.bend:117
@unsafe
def norm_node_rwt(
  +book: List<&2, KDef>,
  +t: KTerm,
  +args: List<&2, KTerm>,
  +left: U32,
  +fallback: KTerm,
  +selected: Bool,
) -> KTerm:
  match selected:
    case True{}:
      kc(KTerm, p98_tag_eq(wnf(book, kid(t, 0)), "Rfl"), u => norm_eval(book, kid(t, 2), args, left, fallback), u => norm_apply(t, args))
    case False{}:
      norm_args(book, t, args, left, fallback)

# Module: src/core/normalize.bend:139
@unsafe
def w7_br_14(w7_c: Bool, +book: List<&2, KDef>, +t: KTerm, +args: List<&2, KTerm>, +d: KDef) -> KTerm:
  match w7_c:
    case True{}:
      norm_eval(book, dv(d), args, da(d), norm_apply(t, args))
    case False{}:
      norm_apply(t, args)

@unsafe
def w7_br_15(w7_c: Bool, +book: List<&2, KDef>, +t: KTerm, +args: List<&2, KTerm>, +d: KDef) -> KTerm:
  match w7_c:
    case True{}:
      w7_br_13(U32.is_eq(da(d), 0), t, args)
    case False{}:
      w7_br_14(Bool.and(Bool.not(p98_tag_eq(dv(d), "Absent") || p98_tag_eq(dv(d), "Foreign")), U32.is_le(da(d), terms_len(args))), book, t, args, d)

@unsafe
def norm_ref(book, t, args, d):
  w7_br_15(p88_string_eq(dk(d), "ADT"), book, t, args, d)

# Module: src/core/normalize.bend:150
@unsafe
def norm_args(book, t, args, left, fallback):
  match args:
    case Nil{}:
      t
    case Con{x, rest}:
      kc(KTerm, p98_tag_eq(t, "Lam"), u => norm_eval(book, subst(kid(t, 0), ix(t), x), rest, norm_dec(left), fallback), u => kc(KTerm, p98_tag_eq(t, "Mat"), u => norm_match(book, t, t, x, wnf(book, x), rest, left, fallback), u => kc(KTerm, Bool.and(p98_tag_eq(t, "Efq"), Bool.not(U32.is_eq(left, 0))), u => fallback, u => norm_apply(t, args))))

# Module: src/core/normalize.bend:161
@unsafe
def w7_br_17(w7_c: Bool, +book: List<&2, KDef>, +arm: KTerm, +x: KTerm, +args: List<&2, KTerm>, +left: U32, +fallback: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      norm_eval(book, kid(arm, 0), norm_join(ks(x), args), 0, fallback)
    case False{}:
      norm_eval(book, kid(arm, 0), norm_join(ks(x), args), U32.add(norm_dec(left), terms_len(ks(x))), fallback)

@unsafe
def w7_br_18(w7_c: Bool, +book: List<&2, KDef>, +arm: KTerm, +original: KTerm, +raw: KTerm, +x: KTerm, +args: List<&2, KTerm>, +left: U32, +fallback: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      w7_br_17(U32.is_eq(left, 0), book, arm, x, args, left, fallback)
    case False{}:
      norm_match(book, kid(arm, 1), original, raw, x, args, left, fallback)

@unsafe
def w7_br_19(w7_c: Bool, +book: List<&2, KDef>, +arm: KTerm, +original: KTerm, +raw: KTerm, +x: KTerm, +args: List<&2, KTerm>, +left: U32, +fallback: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      norm_stuck(original, raw, args, left, fallback)
    case False{}:
      norm_eval(book, arm, Con{x, args}, left, fallback)

@unsafe
def w7_br_20(w7_c: Bool, +book: List<&2, KDef>, +arm: KTerm, +original: KTerm, +raw: KTerm, +x: KTerm, +args: List<&2, KTerm>, +left: U32, +fallback: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      w7_br_18(p88_string_eq(nm(arm), nm(x)), book, arm, original, raw, x, args, left, fallback)
    case False{}:
      w7_br_19(p98_tag_eq(arm, "Efq"), book, arm, original, raw, x, args, left, fallback)

@unsafe
def w7_br_21(w7_c: Bool, +book: List<&2, KDef>, +arm: KTerm, +original: KTerm, +raw: KTerm, +x: KTerm, +args: List<&2, KTerm>, +left: U32, +fallback: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      norm_match(book, kid(arm, 0), original, raw, x, args, left, fallback)
    case False{}:
      w7_br_20(p98_tag_eq(arm, "Mat"), book, arm, original, raw, x, args, left, fallback)

@unsafe
def w7_br_22(w7_c: Bool, +book: List<&2, KDef>, +arm: KTerm, +original: KTerm, +raw: KTerm, +x: KTerm, +args: List<&2, KTerm>, +left: U32, +fallback: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      w7_br_21(p98_tag_eq(arm, "Ann"), book, arm, original, raw, x, args, left, fallback)
    case False{}:
      norm_stuck(original, raw, args, left, fallback)

@unsafe
def w12_norm_u32_cmp(hit: Bool, +book: List<&2, KDef>, +arm: KTerm, +original: KTerm, +raw: KTerm, +x: KTerm, +args: List<&2, KTerm>, +left: U32, +fallback: KTerm) -> KTerm:
  match hit:
    case True{}:
      norm_eval(book, kid(arm, 0), args, norm_dec(left), fallback)
    case False{}:
      norm_match(book, kid(arm, 1), original, raw, x, args, left, fallback)

@unsafe
def w12_norm_u32_val(v: Maybe<&2, U32>, +book: List<&2, KDef>, +arm: KTerm, +original: KTerm, +raw: KTerm, +x: KTerm, +args: List<&2, KTerm>, +left: U32, +fallback: KTerm) -> KTerm:
  match v:
    case Some{n}:
      w12_norm_u32_cmp(U32.is_eq(n, ix(arm)), book, arm, original, raw, x, args, left, fallback)
    case None{}:
      norm_stuck(original, raw, args, left, fallback)

@unsafe
def w7_br_23(w7_c: Bool, +book: List<&2, KDef>, +arm: KTerm, +original: KTerm, +raw: KTerm, +x: KTerm, +args: List<&2, KTerm>, +left: U32, +fallback: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      norm_match(book, arm, original, raw, core_literal_step(x), args, left, fallback)
    case False{}:
      w7_br_22(p98_tag_eq(x, "Ctr"), book, arm, original, raw, x, args, left, fallback)

@unsafe
def w12_norm_mat_u32(isLitMat: Bool, +book: List<&2, KDef>, +arm: KTerm, +original: KTerm, +raw: KTerm, +x: KTerm, +args: List<&2, KTerm>, +left: U32, +fallback: KTerm) -> KTerm:
  match isLitMat:
    case True{}:
      w12_norm_u32_val(w12_u32_lit_val(x), book, arm, original, raw, x, args, left, fallback)
    case False{}:
      w7_br_23(core_literal(x), book, arm, original, raw, x, args, left, fallback)

@unsafe
def norm_match(book, arm, original, raw, x, args, left, fallback):
  w12_norm_mat_u32(p98_tag_eq(arm, "Mat") && p88_string_eq(nm(arm), "#U32"), book, arm, original, raw, x, args, left, fallback)

# Module: src/core/normalize.bend:187
@unsafe
def norm_min(book, a, b):
  norm_min_left(book, wnf(book, a), b)

# Module: src/core/normalize.bend:206
@unsafe
def w7_br_25(w7_c: Bool, +book: List<&2, KDef>, +a: KTerm, +b: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      a
    case False{}:
      norm_min_right(a, wnf(book, b))

@unsafe
def w7_br_26(w7_c: Bool, +book: List<&2, KDef>, +a: KTerm, +b: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      wnf(book, b)
    case False{}:
      w7_br_25(Bool.and(p98_tag_eq(a, "Qua"), U32.is_eq(qt(a), 0)), book, a, b)

@unsafe
def norm_min_left(book, a, b):
  w7_br_26(Bool.and(p98_tag_eq(a, "Qua"), U32.is_eq(qt(a), 2)), book, a, b)

# Module: src/core/normalize.bend:214
@unsafe
def w7_br_33(w7_c: Bool, +book: List<&2, KDef>, +t: KTerm, +args: List<&2, KTerm>, +left: U32, +fallback: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      norm_var(book, t, ks(t), args, left, fallback)
    case False{}:
      norm_eval_node(book, t, args, left, fallback)

@unsafe
def norm_eval(book, t, args, left, fallback):
  w7_br_33(p98_tag_eq(t, "Var"), book, t, args, left, fallback)

# Module: src/core/normalize.bend:322
@unsafe
def norm_var(book, t, values, args, left, fallback):
  match values:
    case Nil{}:
      norm_apply(t, args)
    case Con{h, rest}:
      norm_eval(book, h, args, left, fallback)

# Module: src/core/normalize.bend:334
@unsafe
def norm_book_bound(book):
  match book:
    case Nil{}:
      0
    case Con{h, rest}:
      kc(U32, p88_string_eq(dk(h), "BookCache"), u => da(h), u => norm_bound_found(book, lookup(book, "$kernel.max-id")))

# Module: src/core/normalize.bend:361
@unsafe
def g_class_join_roots(+st: GState, +classes: GClasses, +left: U32, +right: U32) -> GState:
  w7_br_69(U32.is_eq(left,right), st, classes, left, right)

@unsafe
def g_class_join(+st: GState, +left: U32, +right: U32) -> GState:
  +classes = g_classes(st)
  g_class_join_roots(st,classes,g_class_root(classes,left),g_class_root(classes,right))

@unsafe
def w7_br_75(w7_c: Bool, +book: List<&2, KDef>, +st: GState, +t: KTerm, +args: List<&2, KTerm>, +pending: U32, +fallback: KTerm, +stack: List<&2, GFrame>) -> GResult:
  match w7_c:
    case True{}:
      g_eval(book, st, kid(t, 0), Nil{}, 0, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Con{GRewrite{t, args, pending, fallback}, stack})
    case False{}:
      g_args(book, st, t, args, pending, fallback, stack)

@unsafe
def w7_br_76(w7_c: Bool, +book: List<&2, KDef>, +st: GState, +t: KTerm, +args: List<&2, KTerm>, +pending: U32, +fallback: KTerm, +stack: List<&2, GFrame>) -> GResult:
  match w7_c:
    case True{}:
      g_eval(book, st, kid(t, 0), Nil{}, 0, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Con{GMinA{kid(t, 1), args}, stack})
    case False{}:
      w7_br_75(p98_tag_eq(t, "Rwt"), book, st, t, args, pending, fallback, stack)

@unsafe
def w7_br_77(w7_c: Bool, +book: List<&2, KDef>, +st: GState, +t: KTerm, +args: List<&2, KTerm>, +pending: U32, +fallback: KTerm, +stack: List<&2, GFrame>) -> GResult:
  match w7_c:
    case True{}:
      g_ref(book, st, t, args, stack, lookup(book, nm(t)))
    case False{}:
      w7_br_76(p98_tag_eq(t, "Min"), book, st, t, args, pending, fallback, stack)

@unsafe
def w7_br_78(w7_c: Bool, +book: List<&2, KDef>, +st: GState, +t: KTerm, +args: List<&2, KTerm>, +pending: U32, +fallback: KTerm, +stack: List<&2, GFrame>) -> GResult:
  match w7_c:
    case True{}:
      g_let(book, st, ks(t), Nil{}, args, pending, fallback, stack)
    case False{}:
      w7_br_77(p98_tag_eq(t, "Ref"), book, st, t, args, pending, fallback, stack)

@unsafe
def w7_br_79(w7_c: Bool, +book: List<&2, KDef>, +st: GState, +t: KTerm, +args: List<&2, KTerm>, +pending: U32, +fallback: KTerm, +stack: List<&2, GFrame>) -> GResult:
  match w7_c:
    case True{}:
      g_eval(book, st, kid(t, 0), args, pending, fallback, stack)
    case False{}:
      w7_br_78(p98_tag_eq(t, "Let"), book, st, t, args, pending, fallback, stack)

@unsafe
def w7_br_80(w7_c: Bool, +book: List<&2, KDef>, +st: GState, +t: KTerm, +args: List<&2, KTerm>, +pending: U32, +fallback: KTerm, +stack: List<&2, GFrame>) -> GResult:
  match w7_c:
    case True{}:
      g_eval(book, st, kid(t, 0), args, pending, fallback, stack)
    case False{}:
      w7_br_79(p98_tag_eq(t, "Var") && U32.is_gt(terms_len(ks(t)), 0), book, st, t, args, pending, fallback, stack)

@unsafe
def w7_br_81(w7_c: Bool, +book: List<&2, KDef>, +st: GState, +t: KTerm, +args: List<&2, KTerm>, +pending: U32, +fallback: KTerm, +stack: List<&2, GFrame>) -> GResult:
  match w7_c:
    case True{}:
      g_app(book, kid(t, 0), args, pending, fallback, stack, g_share(st, kid(t, 1)))
    case False{}:
      w7_br_80(p98_tag_eq(t, "Ann"), book, st, t, args, pending, fallback, stack)

@unsafe
def w7_br_82(w7_c: Bool, +book: List<&2, KDef>, +st: GState, +t: KTerm, +args: List<&2, KTerm>, +pending: U32, +fallback: KTerm, +stack: List<&2, GFrame>) -> GResult:
  match w7_c:
    case True{}:
      g_cell(book, st, t, args, pending, fallback, stack, g_get(g_heap(st), ix(t)))
    case False{}:
      w7_br_81(p98_tag_eq(t, "App"), book, st, t, args, pending, fallback, stack)

@unsafe
def g_eval(book, st, t, args, pending, fallback, stack):
  w7_br_82(p98_tag_eq(t, "GCell"), book, st, t, args, pending, fallback, stack)

# Module: src/core/graph.bend:347
@unsafe
def w7_br_83(w7_c: Bool, +book: List<&2, KDef>, +st: GState, +t: KTerm, +args: List<&2, KTerm>, +pending: U32, +fallback: KTerm, +stack: List<&2, GFrame>, +cell: KTerm) -> GResult:
  match w7_c:
    case True{}:
      g_eval(book, st, kid(cell, 0), args, pending, fallback, stack)
    case False{}:
      g_eval(book, st, kid(cell, 0), Nil{}, 0, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Con{GFill{ix(t), args, pending, fallback}, stack})

@unsafe
def g_cell(book, st, t, args, pending, fallback, stack, cell):
  w7_br_83(p98_tag_eq(cell, "GValue"), book, st, t, args, pending, fallback, stack, cell)

# Module: src/core/graph.bend:351
@unsafe
def g_app(book, fn, args, pending, fallback, stack, r):
  g_eval(book, g_state(r), fn, Con{g_term(r), args}, pending, fallback, stack)

# Module: src/core/graph.bend:355
@unsafe
def w7_br_84(w7_c: Bool, +book: List<&2, KDef>, +st: GState, +t: KTerm, +args: List<&2, KTerm>, +stack: List<&2, GFrame>, +d: KDef) -> GResult:
  match w7_c:
    case True{}:
      g_eval(book, st, dv(d), args, da(d), norm_apply(t, args), stack)
    case False{}:
      g_return(book, st, norm_apply(t, args), stack)

@unsafe
def w7_br_85(w7_c: Bool, +book: List<&2, KDef>, +st: GState, +t: KTerm, +args: List<&2, KTerm>, +stack: List<&2, GFrame>, +d: KDef) -> GResult:
  match w7_c:
    case True{}:
      g_return(book, st, norm_apply(kc(KTerm, U32.is_eq(da(d), 0), u => kt("ADT", nm(t), 0, 0, Nil{}), u => t), args), stack)
    case False{}:
      w7_br_84(Bool.not(p98_tag_eq(dv(d), "Absent") || p98_tag_eq(dv(d), "Foreign")) && U32.is_le(da(d), terms_len(args)), book, st, t, args, stack, d)

@unsafe
def g_ref(book, st, t, args, stack, d):
  w7_br_85(p88_string_eq(dk(d), "ADT"), book, st, t, args, stack, d)

# Module: src/core/graph.bend:360
@unsafe
def g_args(book, st, t, args, pending, fallback, stack):
  match args:
    case Nil{}:
      g_return(book, st, t, stack)
    case Con{x, rest}:
      kc(GResult, p98_tag_eq(t, "Lam"), u => g_eval(book, st, subst(kid(t, 0), ix(t), x), rest, norm_dec(pending), fallback, stack),
       u => kc(GResult, p98_tag_eq(t, "Mat"), u => g_eval(book, st, x, Nil{}, 0, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Con{GMatch{t, x, rest, pending, fallback}, stack}),
       u => g_return(book, st, kc(KTerm, p98_tag_eq(t, "Efq") && U32.is_gt(pending, 0), u => fallback, u => norm_apply(t, args)), stack)))

# Module: src/core/graph.bend:370
@unsafe
def g_return(book, st, t, stack):
  match stack:
    case Nil{}:
      GResult{st, t}
    case Con{frame, rest}:
      g_resume(book, st, t, frame, rest)

# Module: src/core/graph.bend:378
@unsafe
def g_resume(book, st, t, frame, stack):
  match frame:
    case GFill{id, args, pending, fallback}:
      g_filled(book, id, args, pending, fallback, stack, g_share_head(st, t))
    case GMatch{arm, raw, args, pending, fallback}:
      g_match(book, st, arm, arm, raw, t, args, pending, fallback, stack)
    case GMinA{other, args}:
      g_min_left(book, st, t, other, args, stack)
    case GMinB{other, args}:
      g_return(book, st, norm_apply(norm_min_right(other, t), args), stack)
    case GRewrite{original, args, pending, fallback}:
      kc(GResult, p98_tag_eq(t, "Rfl"), u => g_eval(book, st, kid(original, 2), args, pending, fallback, stack), u => g_return(book, st, norm_apply(original, args), stack))

# Module: src/core/graph.bend:392
@unsafe
def g_filled(book, id, args, pending, fallback, stack, r):
  g_eval(book, g_cache(g_state(r), id, g_term(r)), g_term(r), args, pending, fallback, stack)

# Module: src/core/graph.bend:396
@unsafe
def w7_br_86(w7_c: Bool, +book: List<&2, KDef>, +st: GState, +a: KTerm, +b: KTerm, +args: List<&2, KTerm>, +stack: List<&2, GFrame>) -> GResult:
  match w7_c:
    case True{}:
      g_return(book, st, norm_apply(a, args), stack)
    case False{}:
      g_eval(book, st, b, Nil{}, 0, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Con{GMinB{a, args}, stack})

@unsafe
def w7_br_87(w7_c: Bool, +book: List<&2, KDef>, +st: GState, +a: KTerm, +b: KTerm, +args: List<&2, KTerm>, +stack: List<&2, GFrame>) -> GResult:
  match w7_c:
    case True{}:
      g_eval(book, st, b, args, 0, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, stack)
    case False{}:
      w7_br_86(p98_tag_eq(a, "Qua") && U32.is_eq(qt(a), 0), book, st, a, b, args, stack)

@unsafe
def g_min_left(book, st, a, b, args, stack):
  w7_br_87(p98_tag_eq(a, "Qua") && U32.is_eq(qt(a), 2), book, st, a, b, args, stack)

# Module: src/core/graph.bend:401
@unsafe
def w7_br_88(w7_c: Bool, +book: List<&2, KDef>, +st: GState, +arm: KTerm, +original: KTerm, +raw: KTerm, +x: KTerm, +args: List<&2, KTerm>, +pending: U32, +fallback: KTerm, +stack: List<&2, GFrame>) -> GResult:
  match w7_c:
    case True{}:
      g_eval(book, st, kid(arm, 0), norm_join(ks(x), args), kc(U32, U32.is_eq(pending, 0), u => 0, u => U32.add(norm_dec(pending), terms_len(ks(x)))), fallback, stack)
    case False{}:
      g_match(book, st, kid(arm, 1), original, raw, x, args, pending, fallback, stack)

@unsafe
def w7_br_89(w7_c: Bool, +book: List<&2, KDef>, +st: GState, +arm: KTerm, +original: KTerm, +raw: KTerm, +x: KTerm, +args: List<&2, KTerm>, +pending: U32, +fallback: KTerm, +stack: List<&2, GFrame>) -> GResult:
  match w7_c:
    case True{}:
      g_return(book, st, norm_stuck(original, raw, args, pending, fallback), stack)
    case False{}:
      g_eval(book, st, arm, Con{x, args}, pending, fallback, stack)

@unsafe
def w7_br_90(w7_c: Bool, +book: List<&2, KDef>, +st: GState, +arm: KTerm, +original: KTerm, +raw: KTerm, +x: KTerm, +args: List<&2, KTerm>, +pending: U32, +fallback: KTerm, +stack: List<&2, GFrame>) -> GResult:
  match w7_c:
    case True{}:
      w7_br_88(p88_string_eq(nm(arm), nm(x)), book, st, arm, original, raw, x, args, pending, fallback, stack)
    case False{}:
      w7_br_89(p98_tag_eq(arm, "Efq"), book, st, arm, original, raw, x, args, pending, fallback, stack)

@unsafe
def w7_br_91(w7_c: Bool, +book: List<&2, KDef>, +st: GState, +arm: KTerm, +original: KTerm, +raw: KTerm, +x: KTerm, +args: List<&2, KTerm>, +pending: U32, +fallback: KTerm, +stack: List<&2, GFrame>) -> GResult:
  match w7_c:
    case True{}:
      g_match(book, st, kid(arm, 0), original, raw, x, args, pending, fallback, stack)
    case False{}:
      w7_br_90(p98_tag_eq(arm, "Mat"), book, st, arm, original, raw, x, args, pending, fallback, stack)

@unsafe
def w7_br_92(w7_c: Bool, +book: List<&2, KDef>, +st: GState, +arm: KTerm, +original: KTerm, +raw: KTerm, +x: KTerm, +args: List<&2, KTerm>, +pending: U32, +fallback: KTerm, +stack: List<&2, GFrame>) -> GResult:
  match w7_c:
    case True{}:
      g_return(book, st, norm_stuck(original, raw, args, pending, fallback), stack)
    case False{}:
      w7_br_91(p98_tag_eq(arm, "Ann"), book, st, arm, original, raw, x, args, pending, fallback, stack)

@unsafe
def w12_g_u32_cmp(hit: Bool, +book: List<&2, KDef>, +st: GState, +arm: KTerm, +original: KTerm, +raw: KTerm, +x: KTerm, +args: List<&2, KTerm>, +pending: U32, +fallback: KTerm, +stack: List<&2, GFrame>) -> GResult:
  match hit:
    case True{}:
      g_eval(book, st, kid(arm, 0), args, norm_dec(pending), fallback, stack)
    case False{}:
      g_match(book, st, kid(arm, 1), original, raw, x, args, pending, fallback, stack)

@unsafe
def w12_g_u32_val(v: Maybe<&2, U32>, +book: List<&2, KDef>, +st: GState, +arm: KTerm, +original: KTerm, +raw: KTerm, +x: KTerm, +args: List<&2, KTerm>, +pending: U32, +fallback: KTerm, +stack: List<&2, GFrame>) -> GResult:
  match v:
    case Some{n}:
      w12_g_u32_cmp(U32.is_eq(n, ix(arm)), book, st, arm, original, raw, x, args, pending, fallback, stack)
    case None{}:
      g_return(book, st, norm_stuck(original, raw, args, pending, fallback), stack)

@unsafe
def w7_br_93(w7_c: Bool, +book: List<&2, KDef>, +st: GState, +arm: KTerm, +original: KTerm, +raw: KTerm, +x: KTerm, +args: List<&2, KTerm>, +pending: U32, +fallback: KTerm, +stack: List<&2, GFrame>) -> GResult:
  match w7_c:
    case True{}:
      g_match(book, st, arm, original, raw, core_literal_step(x), args, pending, fallback, stack)
    case False{}:
      w7_br_92(Bool.not(p98_tag_eq(x, "Ctr")), book, st, arm, original, raw, x, args, pending, fallback, stack)

@unsafe
def w12_g_mat_u32(isLitMat: Bool, +book: List<&2, KDef>, +st: GState, +arm: KTerm, +original: KTerm, +raw: KTerm, +x: KTerm, +args: List<&2, KTerm>, +pending: U32, +fallback: KTerm, +stack: List<&2, GFrame>) -> GResult:
  match isLitMat:
    case True{}:
      w12_g_u32_val(w12_u32_lit_val(x), book, st, arm, original, raw, x, args, pending, fallback, stack)
    case False{}:
      w7_br_93(core_literal(x), book, st, arm, original, raw, x, args, pending, fallback, stack)

@unsafe
def g_match(book, st, arm, original, raw, x, args, pending, fallback, stack):
  w12_g_mat_u32(p98_tag_eq(arm, "Mat") && p88_string_eq(nm(arm), "#U32"), book, st, arm, original, raw, x, args, pending, fallback, stack)

# Module: src/core/graph.bend:411
@unsafe
def g_let(book, st, ts, bindings, args, pending, fallback, stack):
  match ts:
    case Nil{}:
      g_return(book, st, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, stack)
    case Con{h, rest}:
      kc(GResult, p98_tag_eq(h, "Bind"), u => g_let_shared(book, h, rest, bindings, args, pending, fallback, stack, g_share(st, kid(h, 0))), u => g_eval(book, st, g_let_sub(h, bindings), args, pending, fallback, stack))

# Module: src/core/graph.bend:419
@unsafe
def g_let_shared(book, h, rest, bindings, args, pending, fallback, stack, r):
  g_let(book, g_state(r), rest, Con{kt("Bind", nm(h), ix(h), qt(h), Con{g_term(r), Nil{}}), bindings}, args, pending, fallback, stack)

# Module: src/core/graph.bend:423
@unsafe
def kr_parent(book, name):
  match book:
    case Nil{}: missing()
    case Con{+d, +rest}: kc(KDef, p88_string_eq(dk(d), "ADT") && Bool.not(p88_string_eq(dk(lookup(dc(d), name)), "Absent")), u => d, u => kr_parent(rest, name))

# Module: src/core/reach.bend:108
@unsafe
def w7_br_107(w7_c: Bool, +n: U32, +quote: U32) -> String:
  match w7_c:
    case True{}:
      "\\t"
    case False{}:
      w7_br_106(U32.is_eq(n, 13), n, quote)

@unsafe
def w7_br_108(w7_c: Bool, +n: U32, +quote: U32) -> String:
  match w7_c:
    case True{}:
      "\\n"
    case False{}:
      w7_br_107(U32.is_eq(n, 9), n, quote)

@unsafe
def w7_br_158(w7_c: Bool, +e: KEnv, +x: KTerm) -> KEnv:
  match w7_c:
    case True{}:
      e
    case False{}:
      KEnv{cw(e), cn(e), kapply(cl(e), x), U32.sub(cp(e), 1), cq(e), cu(e), cd(e)}

@unsafe
def lhs_step(
  +e: KEnv,
  +x: KTerm,
) -> KEnv:
  w7_br_158(U32.is_eq(cp(e), 0), e, x)

# Module: src/check/kernel.bend:627
@unsafe
def infer_adt_done(t, r):
  ki_args(t, cy(r), r)

# Module: src/check/kernel.bend:688
@unsafe
def w7_br_186(w7_c: Bool, +lhs: KTerm, +name: String, +tel: KTerm, +n: U32, +xs: List<&2, KTerm>, +fresh: U32) -> KTerm:
  match w7_c:
    case True{}:
      kapply(lhs, kt("Ctr", name, 0, 0, xs))
    case False{}:
      k_lam(nm(tel), fresh, qt(tel), Con{lhs_ext(lhs, name, kid(tel, 1), U32.sub(n, 1), norm_join(xs, Con{var(nm(tel), fresh), Nil{}}), U32.add(fresh, 1)), Nil{}}, 0, 0, False{})

@unsafe
def lhs_ext(
  +lhs: KTerm,
  +name: String,
  +tel: KTerm,
  +n: U32,
  +xs: List<&2, KTerm>,
  +fresh: U32,
) -> KTerm:
  w7_br_186(U32.is_eq(n, 0), lhs, name, tel, n, xs, fresh)

# Module: src/check/kernel.bend:878
@unsafe
def w7_br_190(w7_c: Bool, +d: KDef, +later: List<&2, KDef>) -> KDef:
  match w7_c:
    case True{}:
      signature_fill_mode(d, lookup(later, dn(d)))
    case False{}:
      d

@unsafe
def w7_br_220(w7_c: Bool, +world: KWorld, +r: KChecking) -> KChecking:
  match w7_c:
    case True{}:
      KChecking{ct(r), cy(r), cs(r), ce(r), kw_with_book(rw(r), kw_book(world)), rx(r)}
    case False{}:
      r

@unsafe
def kw_put_checked(+world: KWorld, +d: KDef) -> KWorld:
  kw_with_checked(world, Con{d, kw_checked(world)})

# Module: src/check/kernel.bend:1278
@unsafe
def kw_owner(+world: KWorld, +ty: KTerm, +body: KTerm) -> KWorld:
  kw_owner_fresh(world, ty, body, kw_fresh(world))

# Module: src/check/kernel.bend:1286
@unsafe
def ki_ref_result(+e: KEnv, +t: KTerm, +sp: List<&2,KTerm>, +r: KChecking) -> KChecking:
  w7_br_236(good(r), e, sp, r)

# Module: src/check/kernel.bend:1374
@unsafe
def env_tele_apply(+t: KTerm, +bindings: List<&2,KTelescopeBinding>) -> KTerm:
  env_subst_apply(t, bindings)

# Module: src/check/env-telescope.bend:38
@unsafe
def env_subst_apply(+t: KTerm, +bindings: List<&2,KTelescopeBinding>) -> KTerm:
  match bindings:
    case Nil{}: t
    case Con{first, rest}: env_subst_start(t, bindings, first, rest)

# Module: src/check/env-substitution.bend:41
@unsafe
def term_key(+t: KTerm) -> String:
  sk_term(t, Nil{}, 0)

# Module: src/check/specialize.bend:136
@unsafe
def sk_terms(+ts: List<&2,KTerm>, +env: List<&2,KPName>, +depth: U32) -> String:
  match ts:
    case Nil{}: ""
    case Con{head, rest}: sk_term(head, env, depth) ++ kc(String, List.is_empty(&2, KTerm, rest), u => "", u => "," ++ sk_terms(rest, env, depth))

# Module: src/check/specialize.bend:154
@unsafe
def w7_br_252(w7_c: Bool, +t: KTerm, +env: List<&2,KPName>, +depth: U32) -> String:
  match w7_c:
    case True{}:
      sk_var(t, env)
    case False{}:
      sk_term(kid(t, 0), env, depth)

@unsafe
def w7_br_253(w7_c: Bool, +t: KTerm, +env: List<&2,KPName>, +depth: U32) -> String:
  match w7_c:
    case True{}:
      sk_term(subst(kid(t, 1), ix(t), kid(t, 0)), env, depth)
    case False{}:
      sk_node(t, env, depth)

@unsafe
def w7_br_254(w7_c: Bool, +t: KTerm, +env: List<&2,KPName>, +depth: U32) -> String:
  match w7_c:
    case True{}:
      w7_br_252(List.is_empty(&2, KTerm, ks(t)), t, env, depth)
    case False{}:
      w7_br_253(p98_tag_eq(t, "Sub"), t, env, depth)

@unsafe
def sk_term(+t: KTerm, +env: List<&2,KPName>, +depth: U32) -> String:
  w7_br_254(p98_tag_eq(t, "Var"), t, env, depth)

# Module: src/check/specialize.bend:172
@unsafe
def w7_br_255(w7_c: Bool, +t: KTerm, +env: List<&2,KPName>, +depth: U32) -> String:
  match w7_c:
    case True{}:
      "{\"$\":" ++ sk_quote(tg(t)) ++ ",\"k\":" ++ sk_quote(nm(t)) ++ ",\"x\":[" ++ sk_terms(ks(t), env, depth) ++ "]" ++ kc(String, p98_tag_eq(t, "ADT"), u => ",\"r\":[" ++ sk_names(rm(t)) ++ "]", u => "") ++ "}"
    case False{}:
      sk_other(t, env, depth)

@unsafe
def w7_br_256(w7_c: Bool, +t: KTerm, +env: List<&2,KPName>, +depth: U32) -> String:
  match w7_c:
    case True{}:
      sk_let(ks(t), env, depth)
    case False{}:
      w7_br_255(p98_tag_eq(t, "ADT") || p98_tag_eq(t, "Ctr"), t, env, depth)

@unsafe
def w7_br_257(w7_c: Bool, +t: KTerm, +env: List<&2,KPName>, +depth: U32) -> String:
  match w7_c:
    case True{}:
      "{\"$\":\"All\",\"q\":" ++ sk_quant(qt(t)) ++ ",\"k\":" ++ sk_quote(nm(t)) ++ ",\"i\":" ++ U32.show(depth) ++ ",\"A\":" ++ sk_term(kid(t, 0), env, depth) ++ ",\"B\":" ++ sk_term(kid(t, 1), Con{KPName{nm(t), ix(t), depth}, env}, U32.inc(depth)) ++ "}"
    case False{}:
      w7_br_256(p98_tag_eq(t, "Let"), t, env, depth)

@unsafe
def w7_br_258(w7_c: Bool, +t: KTerm, +env: List<&2,KPName>, +depth: U32) -> String:
  match w7_c:
    case True{}:
      "{\"$\":\"Lam\",\"k\":" ++ sk_quote(nm(t)) ++ ",\"i\":" ++ U32.show(depth) ++ ",\"f\":" ++ sk_term(kid(t, 0), Con{KPName{nm(t), ix(t), depth}, env}, U32.inc(depth)) ++ kc(String, k_quantity_present(t), u => ",\"q\":" ++ sk_quant(qt(t)), u => "") ++ "}"
    case False{}:
      w7_br_257(p98_tag_eq(t, "All"), t, env, depth)

@unsafe
def w7_br_259(w7_c: Bool, +t: KTerm, +env: List<&2,KPName>, +depth: U32) -> String:
  match w7_c:
    case True{}:
      "{\"$\":\"Lit\",\"k\":" ++ sk_quote(nm(t)) ++ ",\"v\":" ++ kc(String, p88_string_eq(nm(t), "String"), u => sk_quote(kl_text(t)), u => U32.show(kl_number(t))) ++ "}"
    case False{}:
      w7_br_258(p98_tag_eq(t, "Lam"), t, env, depth)

@unsafe
def w7_br_260(w7_c: Bool, +t: KTerm, +env: List<&2,KPName>, +depth: U32) -> String:
  match w7_c:
    case True{}:
      "{\"$\":\"Ref\",\"k\":" ++ sk_quote(nm(t)) ++ kc(String, U32.is_eq(qt(t), 3), u => ",\"b\":true", u => "") ++ "}"
    case False{}:
      w7_br_259(core_literal(t), t, env, depth)

@unsafe
def sk_node(+t: KTerm, +env: List<&2,KPName>, +depth: U32) -> String:
  w7_br_260(p98_tag_eq(t, "Ref"), t, env, depth)

# Module: src/check/specialize.bend:182
@unsafe
def w7_br_261(w7_c: Bool, +t: KTerm, +env: List<&2,KPName>, +depth: U32) -> String:
  match w7_c:
    case True{}:
      "{\"$\":" ++ sk_quote(tg(t)) ++ "}"
    case False{}:
      sk_internal(t, env, depth)

@unsafe
def w7_br_262(w7_c: Bool, +t: KTerm, +env: List<&2,KPName>, +depth: U32) -> String:
  match w7_c:
    case True{}:
      "{\"$\":\"Hol\",\"k\":" ++ sk_quote(nm(t)) ++ "}"
    case False{}:
      w7_br_261(p98_tag_eq(t, "Qnt") || p98_tag_eq(t, "Efq") || p98_tag_eq(t, "Rfl"), t, env, depth)

@unsafe
def w7_br_263(w7_c: Bool, +t: KTerm, +env: List<&2,KPName>, +depth: U32) -> String:
  match w7_c:
    case True{}:
      sk_triple("Rwt", "e", "p", "f", t, env, depth)
    case False{}:
      w7_br_262(p98_tag_eq(t, "Hol"), t, env, depth)

@unsafe
def w7_br_264(w7_c: Bool, +t: KTerm, +env: List<&2,KPName>, +depth: U32) -> String:
  match w7_c:
    case True{}:
      sk_triple("Eql", "a", "b", "T", t, env, depth)
    case False{}:
      w7_br_263(p98_tag_eq(t, "Rwt"), t, env, depth)

@unsafe
def w7_br_265(w7_c: Bool, +t: KTerm, +env: List<&2,KPName>, +depth: U32) -> String:
  match w7_c:
    case True{}:
      "{\"$\":\"Mat\",\"k\":" ++ sk_quote(nm(t)) ++ ",\"h\":" ++ sk_term(kid(t, 0), env, depth) ++ ",\"m\":" ++ sk_term(kid(t, 1), env, depth) ++ "}"
    case False{}:
      w7_br_264(p98_tag_eq(t, "Eql"), t, env, depth)

@unsafe
def w7_br_266(w7_c: Bool, +t: KTerm, +env: List<&2,KPName>, +depth: U32) -> String:
  match w7_c:
    case True{}:
      "{\"$\":\"Qua\",\"q\":" ++ sk_quant(qt(t)) ++ "}"
    case False{}:
      w7_br_265(p98_tag_eq(t, "Mat"), t, env, depth)

@unsafe
def w7_br_267(w7_c: Bool, +t: KTerm, +env: List<&2,KPName>, +depth: U32) -> String:
  match w7_c:
    case True{}:
      "{\"$\":\"Typ\",\"g\":" ++ sk_term(kid(t, 0), env, depth) ++ "}"
    case False{}:
      w7_br_266(p98_tag_eq(t, "Qua"), t, env, depth)

@unsafe
def w7_br_268(w7_c: Bool, +t: KTerm, +env: List<&2,KPName>, +depth: U32) -> String:
  match w7_c:
    case True{}:
      sk_pair("Ann", "x", "T", t, env, depth)
    case False{}:
      w7_br_267(p98_tag_eq(t, "Typ"), t, env, depth)

@unsafe
def w7_br_269(w7_c: Bool, +t: KTerm, +env: List<&2,KPName>, +depth: U32) -> String:
  match w7_c:
    case True{}:
      sk_pair("Min", "a", "b", t, env, depth)
    case False{}:
      w7_br_268(p98_tag_eq(t, "Ann"), t, env, depth)

@unsafe
def w7_br_270(w7_c: Bool, +t: KTerm, +env: List<&2,KPName>, +depth: U32) -> String:
  match w7_c:
    case True{}:
      sk_pair("App", "f", "x", t, env, depth)
    case False{}:
      w7_br_269(p98_tag_eq(t, "Min"), t, env, depth)

@unsafe
def sk_other(+t: KTerm, +env: List<&2,KPName>, +depth: U32) -> String:
  w7_br_270(p98_tag_eq(t, "App"), t, env, depth)

# Module: src/check/specialize.bend:196
@unsafe
def sk_internal(+t: KTerm, +env: List<&2,KPName>, +depth: U32) -> String:
  "{\"$\":\"Internal\",\"tag\":" ++ sk_quote(tg(t)) ++ ",\"name\":" ++ sk_quote(nm(t)) ++ ",\"id\":" ++ U32.show(ix(t)) ++ ",\"quant\":" ++ U32.show(qt(t)) ++ ",\"kids\":[" ++ sk_terms(ks(t), env, depth) ++ "],\"removed\":[" ++ sk_names(rm(t)) ++ "]}"

# Module: src/check/specialize.bend:200
@unsafe
def sk_pair(+tag: String, +a: String, +b: String, +t: KTerm, +env: List<&2,KPName>, +depth: U32) -> String:
  "{\"$\":" ++ sk_quote(tag) ++ "," ++ sk_quote(a) ++ ":" ++ sk_term(kid(t, 0), env, depth) ++ "," ++ sk_quote(b) ++ ":" ++ sk_term(kid(t, 1), env, depth) ++ "}"

# Module: src/check/specialize.bend:204
@unsafe
def sk_triple(+tag: String, +a: String, +b: String, +c: String, +t: KTerm, +env: List<&2,KPName>, +depth: U32) -> String:
  "{\"$\":" ++ sk_quote(tag) ++ "," ++ sk_quote(a) ++ ":" ++ sk_term(kid(t, 0), env, depth) ++ "," ++ sk_quote(b) ++ ":" ++ sk_term(kid(t, 1), env, depth) ++ "," ++ sk_quote(c) ++ ":" ++ sk_term(kid(t, 2), env, depth) ++ "}"

# Module: src/check/specialize.bend:208
@unsafe
def sk_let(+xs: List<&2,KTerm>, +env: List<&2,KPName>, +depth: U32) -> String:
  "{\"$\":\"Let\",\"k\":[" ++ sk_let_field(xs, 0, env, depth, depth) ++ "],\"i\":[" ++ sk_let_field(xs, 1, env, depth, depth) ++ "],\"q\":[" ++ sk_let_field(xs, 2, env, depth, depth) ++ "],\"v\":[" ++ sk_let_field(xs, 3, env, depth, depth) ++ "],\"f\":" ++ sk_let_body(xs, env, depth) ++ "}"

# Module: src/check/specialize.bend:212
@unsafe
def sk_let_field(+xs: List<&2,KTerm>, +field: U32, +env: List<&2,KPName>, +depth: U32, +id: U32) -> String:
  match xs:
    case Nil{}: ""
    case Con{head, rest}:
      kc(String, p98_tag_eq(head, "Bind"),
        u => kc(String, U32.is_eq(field, 0), u => sk_quote(nm(head)),
          u => kc(String, U32.is_eq(field, 1), u => U32.show(id),
          u => kc(String, U32.is_eq(field, 2), u => sk_quant(qt(head)), u => sk_term(kid(head, 0), env, depth))))
          ++ kc(String, p98_tag_eq(terms_at(rest, 0), "Bind"), u => "," ++ sk_let_field(rest, field, env, depth, U32.inc(id)), u => ""),
        u => "")

# Module: src/check/specialize.bend:224
@unsafe
def sk_let_body(+xs: List<&2,KTerm>, +env: List<&2,KPName>, +depth: U32) -> String:
  match xs:
    case Nil{}: "null"
    case Con{head, rest}:
      kc(String, p98_tag_eq(head, "Bind"), u => sk_let_body(rest, Con{KPName{nm(head), ix(head), depth}, env}, U32.inc(depth)), u => sk_term(head, env, depth))

# Module: src/check/specialize.bend:231
@unsafe
def sp_apply_template(body, xs):
  match xs:
    case Nil{}:
      body
    case Con{h, rest}:
      sp_apply_template(kapply(body, h), rest)

# Module: src/check/specialize.bend:327
@unsafe
def prefix_state_disjoint(+prefix: List<&2,KDef>, +suffix: List<&2,KDef>) -> Bool:
  match prefix:
    case Nil{}: True{}
    case Con{d, rest}: kc(Bool, p88_string_eq(dk(lookup(suffix, dn(d))), "Absent"), u => prefix_state_disjoint(rest, suffix), u => False{})

# Cold-prefix experiment. PRIVATE prepared capability only; not yet selected.
# No carrier is inferred from a source-only validation marker. The driver must
# bind it to the exact checked API, Base bytes and source interval before use.
# Fresh-offset equivariance remains a separate source-review/control obligation.

# Module: src/check/prefix-state.bend:86
@unsafe
def base_prefix_closed_terms(+terms: List<&2,KTerm>, +context: List<&2,KDef>) -> Bool:
  match terms:
    case Nil{}: True{}
    case Con{t, rest}: kc(Bool, (Bool.not(p98_tag_eq(t, "Ref") || p98_tag_eq(t, "ADT")) || Bool.not(p88_string_eq(dk(lookup(context, nm(t))), "Absent"))),
      u => base_prefix_closed_terms(norm_join(ks(t), rest), context), u => False{})

# Module: src/check/prefix-state.bend:120
@unsafe
def base_prefix_world_names_disjoint(+suffix: List<&2,KDef>, +saved: List<&2,KDef>) -> Bool:
  match suffix:
    case Nil{}: True{}
    case Con{d, rest}: kc(Bool, p88_string_eq(dk(lookup(saved, dn(d))), "Absent"),
      u => base_prefix_world_names_disjoint(rest, saved), u => False{})

# The saved index contains every prefix name. Reverse the old intersection
# query so admission does not rebuild a suffix index or walk the Base prefix.

# Module: src/check/prefix-state.bend:340
@unsafe
def ka_type_app(e, t, fty):
  w7b_subst_fast(kid(fty, 1), ix(fty), kid(t, 1))

@unsafe
def f_context_known(+name: String, +scope: FParseScope, +constructor: Bool) -> Bool:
  match scope:
    case FParseScope{prior, index, ctorIndex, ns, aliases, view}:
      f_choose(Bool, constructor,
        u => Bool.not(f_eq(dk(f_ctor_index_find(name, ctorIndex)), "Missing")),
        u => f_declared(name, prior))

@unsafe
def f_context_pattern_named(+pattern: KTerm, +input: FInput, +cursor: U32, +resolved: KTerm) -> FParsed:
  match input:
    case FInput{tokens, context}:
      match context:
        case FParseContext{scope, env, next}:
          match scope:
            case FParseScope{prior, index, ctorIndex, ns, aliases, +p144p_view}:
              f_choose(FParsed, p98_tag_eq(resolved, "Error"), u => f_context_error_at(resolved, input, cursor),
                u => f_context_pattern_checked(pattern, input, cursor, f_valid_var_pattern(pattern, f_ctor_index_find(nm(resolved), ctorIndex))))

# Module: src/front/contextual.bend:112

@unsafe
def f_context_flat(+parsed: FParsed, +vars: List<&2,KTerm>) -> FParsed:
  match parsed:
    case FParsed{term, rest}:
      f_choose(FParsed, f_context_stop(term), u => parsed, u => f_context_flat_input(term, f_space(rest), vars))

# Module: src/front/contextual.bend:217
@unsafe
def f_context_flat_input(+term: KTerm, +input: FInput, +vars: List<&2,KTerm>) -> FParsed:
  match input:
    case FInput{tokens, context}:
      match context:
        case FParseContext{scope, env, next}:
          f_context_flat_done(input, ff_flat(term, vars, next))

# Module: src/front/contextual.bend:225
@unsafe
def w7_br_313(w7_c: Bool, +term: KTerm, +syntax: KTerm, +resolved: KTerm, +definition: KDef, +input: FInput) -> FParsed:
  match w7_c:
    case True{}:
      FParsed{resolved, input}
    case False{}:
      w7_br_312(f_eq(tg(syntax), "Var") && Bool.not(f_eq(dk(definition), "ADT")), term, syntax, resolved, definition, input)

@unsafe
def w7_br_333(w7_c: Bool, +s: String) -> U32:
  match w7_c:
    case True{}:
      5
    case False{}:
      w7_br_332(f_eq(s, "<>") || f_eq(s, "++") || f_eq(s, "<&>"), s)

@unsafe
def w7_br_334(w7_c: Bool, +s: String) -> U32:
  match w7_c:
    case True{}:
      4
    case False{}:
      w7_br_333(f_eq(s, "<") || f_eq(s, ">op") || f_eq(s, "<=") || f_eq(s, ">="), s)

@unsafe
def w7_br_350(w7_c: Bool, +s: String) -> String:
  match w7_c:
    case True{}:
      ".is_gt"
    case False{}:
      w7_br_349(f_eq(s, "<="), s)

@unsafe
def w7_br_351(w7_c: Bool, +s: String) -> String:
  match w7_c:
    case True{}:
      ".is_lt"
    case False{}:
      w7_br_350(f_eq(s, ">op"), s)

@unsafe
def fpe_snippet(+source: String, +begin: U32, +end: U32, +error: KTerm) -> String:
  w7_br_389(f_eq(tg(kid(error, 2)), "ParseLine") || f_eq(tg(kid(error, 3)), "ParseRaw"), source, begin, end)

# UTF16 surrogate halves cannot be manufactured as Bend Unicode scalar chars.
# Keep the producer's legacy diagnostic on that boundary instead of crashing.

# Module: src/front/parser.bend:734
@unsafe
def f_decl_taken(+name: String, +book: List<&2,KDef>, +scope: FParseScope) -> Bool:
  match scope:
    case FParseScope{prior, index, ctorIndex, ns, aliases, +p144p_view}:
      Bool.not(f_eq(dk(f_decl_local(name, book, scope)), "Missing")) || Bool.not(f_eq(dk(index_find(index, name, index_hash(name, 2166136261), 32)), "Absent")) || Bool.not(f_eq(dk(index_find(index, f_qual_name(name, ns), index_hash(f_qual_name(name, ns), 2166136261), 32)), "Absent"))

# Module: src/front/declarations.bend:704

@unsafe
def f_decl_ctor_taken(+name: String, +book: List<&2,KDef>, +scope: FParseScope) -> Bool:
  match scope:
    case FParseScope{prior, index, ctorIndex, ns, aliases, +p144p_view}:
      Bool.not(f_eq(dk(f_ctor_index_find(name, ctorIndex)), "Missing")) || Bool.not(f_eq(dk(f_ctor_index_find(f_qual_name(name, ns), ctorIndex)), "Missing")) || Bool.not(f_eq(dk(f_ctor_index_find(f_alias(name, aliases), ctorIndex)), "Missing"))

# Every local declaration also publishes its mapped header in scope.index.
# A miss proves local absence; hits retain the original first-event scan.

# Module: src/front/declarations.bend:736

@unsafe
def f_do_resolved(+term: KTerm, +input: FInput, +scope: FParseScope, +resolved: KTerm) -> FParsed:
  match scope:
    case FParseScope{prior, index, ctorIndex, ns, aliases, +p144p_view}:
      +head = k_with_span(resolved, kb(term), ke(term))
      +types = ks(kid(term, 0))
      f_choose(FParsed, f_context_stop(resolved), u => FParsed{resolved, input},
        u => FParsed{f_choose(KTerm, U32.is_eq(qt(term), 0),
          u => kt_span("Ann", "", 0, 1, [kid(term, 1), f_choose(KTerm, f_eq(dk(p144p_find(nm(resolved), prior, p144p_view)), "ADT"), u => kt_span("ADT", nm(resolved), 0, 1, types, kb(term), ke(term)), u => f_scope_apply_span(head, types, kb(term), ke(term)))], kb(term), ke(term)),
          u => f_scope_apply_span(head, f_choose(List<&2,KTerm>, U32.is_eq(qt(term), 1), u => norm_join(types, [kid(term, 1)]), u => norm_join(f_do_bind_types(types, kid(term, 1)), [kid(term, 2), kid(term, 3)])), kb(term), ke(term))), input})

# Module: src/front/sugar.bend:185

@unsafe
def w7_br_442(w7_c: Bool, +s: String) -> FDecoded:
  match w7_c:
    case True{}:
      f_decode_escape(f_tail(s))
    case False{}:
      FDecoded{Char.to_u32(f_head(s)), f_tail(s), ""}

@unsafe
def f_fresh_book_stack(
  +book: List<&2,KDef>,
  +next: U32,
) -> FFreshDefs:
  ffd_walk(book, next, Nil{}, Nil{})

# Module: src/front/fresh_work.bend:181
@unsafe
def f_fresh_defs(
  +ds: List<&2,KDef>,
  +next: U32,
) -> FFreshDefs:
  f_fresh_book_stack(ds, next)

# Module: src/front/freshen.bend:45
@unsafe
def w7_br_530(w7_c: Bool, +im: KTerm, +source: FSource, +sources: List<&2,FSource>, +root: String) -> String:
  match w7_c:
    case True{}:
      ""
    case False{}:
      f_strip_bend(f_relative_parts(f_path_segments(f_path_normal(root)), f_path_segments(f_source_path(f_graph_source(f_import_pathname(im, source, sources), sources)))))

@unsafe
def f_import_namespace_at(+im: KTerm, +source: FSource, +sources: List<&2,FSource>, +root: String) -> String:
  w7_br_530(f_eq(nm(im), "Base"), im, source, sources, root)

# Module: src/load/graph.bend:433
@unsafe
def f_graph_fill_defs(+defs: List<&2,KDef>, +imports: List<&2,KTerm>, +scope: List<&2,KDef>) -> List<&2,KDef>:
  match defs:
    case Nil{}: Nil{}
    case Con{d, rest}:
      Con{f_graph_fill_alias(KDef{dn(d), dk(d), da(d), dx(d), dt(d), dv(d), f_graph_fill_defs(dc(d), imports, scope), db(d), du(d)}, imports, scope), f_graph_fill_defs(rest, imports, scope)}

# Module: src/load/graph.bend:454
@unsafe
def j_find_ctor(book, name):
  match book:
    case Nil{}:
      missing()
    case Con{d, rest}:
      j_find_ctor_children(dc(d), rest, name)

# A failed child scan continues with the next owner without constructing Absent.
# A cached child list retains lookup's cache-stop semantics, including a miss.

# Module: src/back/common/queries.bend:101
@unsafe
def j_find_ctor_children(+children: List<&2,KDef>, +rest: List<&2,KDef>, +name: String) -> KDef:
  match children:
    case Nil{}: j_find_ctor(rest, name)
    case Con{d, more}:
      kc(KDef, p88_string_eq(dk(d), "BookCache"),
        u => j_found_ctor(index_lookup(d, name), rest, name),
        u => kc(KDef, p88_string_eq(dn(d), name),
          v => j_found_ctor(d, rest, name), v => j_find_ctor_children(more, rest, name)))

# Module: src/back/common/queries.bend:117
@unsafe
def w7_br_571(w7_c: Bool, +found: KDef, +rest: List<&2, KDef>, +name: String) -> KDef:
  match w7_c:
    case True{}:
      j_find_ctor(rest, name)
    case False{}:
      found

@unsafe
def j_found_ctor(found, rest, name):
  w7_br_571(p88_string_eq(dk(found), "Absent"), found, rest, name)

# Module: src/back/common/queries.bend:127
@unsafe
def j_constructor_count(book, ty):
  j_count_constructors(dc(lookup(book, nm(ty))), rm(ty))

# Module: src/back/common/queries.bend:212
@unsafe
def j_layout_ctor(
  +book: List<&2, KDef>,
  +ty: KTerm,
  +name: String,
) -> KDef:
  +d = lookup(dc(lookup(book, nm(ty))), name)
  kc(KDef, p98_tag_eq(ty, "ADT") && p88_string_eq(dk(d), "Ctr"), u => d, u => j_find_ctor(book, name))

# Module: src/back/common/arity.bend:8
@unsafe
def j_u32_native_ctor(+book: List<&2,KDef>, +owner: String, +name: String) -> Bool:
  +d = lookup(book, owner)
  +c = lookup(dc(d), name)
  p88_string_eq(dk(d), "ADT") && db(d) && p88_string_eq(dk(c), "Ctr") && db(c)

# Module: src/back/common/native-facts.bend:12
@unsafe
def w7_br_592(w7_c: Bool, +t: KTerm) -> String:
  match w7_c:
    case True{}:
      j_nat_text(j_nat(t, 0n))
    case False{}:
      w7_br_591(p88_string_eq(nm(t), "SNil") || p88_string_eq(nm(t), "SCon"), t)

@unsafe
def w7_br_593(w7_c: Bool, +t: KTerm) -> String:
  match w7_c:
    case True{}:
      j_char_text(j_u32(kid(t, 0)))
    case False{}:
      w7_br_592(p88_string_eq(nm(t), "Zero") || p88_string_eq(nm(t), "Succ"), t)

@unsafe
def j_literal_owner(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  +d = lookup(book, nm(ty))
  Bool.not(p98_tag_eq(ty, "ADT") && p88_string_eq(dk(d), "ADT") && Bool.not(db(d)))

# Module: src/back/js/literals.bend:143
@unsafe
def w7b_arr_intr_if(isRef: Bool, +book: List<&2, KDef>, +f: KTerm) -> Bool:
  match isRef:
    case True{}:
      +name = nm(f)
      w7b_starts_A(name) && j_layout_array_name(name) && db(lookup(book, name))
    case False{}: False{}

@unsafe
def j_layout_native_nat(
  +book: List<&2, KDef>,
  +t: KTerm,
  +ty: KTerm,
) -> Bool:
  p98_tag_eq(ty, "ADT") && p88_string_eq(nm(ty), "Nat") && db(lookup(book, "Nat")) && ((p88_string_eq(nm(t), "Zero") && U32.is_eq(terms_len(ks(t)), 0)) || (p88_string_eq(nm(t), "Succ") && U32.is_eq(terms_len(ks(t)), 1)))

# Private checked path. Its definitions have just passed annotate_selected;
# field quantities and every child goal come from that same book/context.
# Raw layout callers retain j_layout_error and its original reconstruction.

# Module: src/back/js/validate.bend:344
@unsafe
def w5c2_ni_from_nat(ok: Bool, +k: String) -> String:
  match ok:
    case True{}: "f32_rewrap((f32)($0))"
    case False{}: ni_template_prior(k)

@unsafe
def ne_constructor(+k: String, +ws: List<&2, String>, +packed: Bool, +n: U32, +hot: Bool) -> N_Emitted:
  match ws:
    case Nil{}: N_Emitted{"", "term_pak(" ++ nt_cid(k) ++ ", 0)", n}
    case Con{+h, +t}:
      nt_choose(N_Emitted, packed,
        u => N_Emitted{"", "term_pak(" ++ nt_cid(k) ++ ", " ++ h ++ ")", n},
        u => nt_choose(N_Emitted, String.starts_with(k, "$ctor.") && U32.is_eq(nt_count(String, t), 0),
          u => ne_single(k, h, n, hot),
          u => ne_wrap_ctor(k, ne_ctor_node(k, "heap_alloc(e, cls_fit(" ++ U32.show(nt_count(String, ws)) ++ "))", ws, n, hot))))

# Module: src/back/native/erase.bend:21
@unsafe
def w7_br_657(w7_c: Bool, +book: List<&2, KDef>, +name: String) -> U32:
  match w7_c:
    case True{}:
      0
    case False{}:
      da(nc_find_ctor(book, nc_ctor_display(name)))

@unsafe
def w7_br_661(w7_c: Bool, +name: String, +word: String) -> String:
  match w7_c:
    case True{}:
      "1"
    case False{}:
      w7_br_660(p88_string_eq(name, "ALeaf"), name, word)

@unsafe
def w5c2_pn_disp_u(ok: Bool, +c: U32, +k: String) -> String:
  match ok:
    case True{}: w5c2_pn_u_res(w5c2_pn_u1(k), k)
    case False{}: w5c2_pn_disp_f(U32.is_eq(c, 70), c, k)

@unsafe
def w5c2_prim_n(ok: Bool, +c: U32, +k: String) -> Bool:
  match ok:
    case True{}: w5c2_prim_is_nat(k)
    case False{}: w5c2_prim_b(U32.is_eq(c, 98), c, k)

@unsafe
def w5c2_arity_f(ok: Bool, +c: U32, +k: String) -> U32:
  match ok:
    case True{}: w5c2_arity_f32(k)
    case False{}: w5c2_arity_n(U32.is_eq(c, 110), c, k)

@unsafe
def w7_br_701(w7_c: Bool, +book: List<&2, KDef>, +t: KTerm, +args: List<&2, KTerm>, +seen: List<&2, String>, +fuel: U32) -> KTerm:
  match w7_c:
    case True{}:
      nq_layout_ref(book, t, args, seen, U32.sub(fuel, 1))
    case False{}:
      nq_layout_apply(book, t, args, seen, U32.sub(fuel, 1))

@unsafe
def w7_br_702(w7_c: Bool, +book: List<&2, KDef>, +t: KTerm, +args: List<&2, KTerm>, +seen: List<&2, String>, +fuel: U32) -> KTerm:
  match w7_c:
    case True{}:
      nq_layout_eval(book, kid(t, 0), Con{kid(t, 1), args}, seen, U32.sub(fuel, 1))
    case False{}:
      w7_br_701(p98_tag_eq(t, "Ref"), book, t, args, seen, fuel)

@unsafe
def w7_br_703(w7_c: Bool, +book: List<&2, KDef>, +t: KTerm, +args: List<&2, KTerm>, +seen: List<&2, String>, +fuel: U32) -> KTerm:
  match w7_c:
    case True{}:
      nq_layout_eval(book, kid(t, 0), args, seen, U32.sub(fuel, 1))
    case False{}:
      w7_br_702(p98_tag_eq(t, "App"), book, t, args, seen, fuel)

@unsafe
def w7_br_704(w7_c: Bool, +book: List<&2, KDef>, +t: KTerm, +args: List<&2, KTerm>, +seen: List<&2, String>, +fuel: U32) -> KTerm:
  match w7_c:
    case True{}:
      {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}
    case False{}:
      w7_br_703(p98_tag_eq(t, "Ann"), book, t, args, seen, fuel)

@unsafe
def nq_layout_eval(+book: List<&2, KDef>, +t: KTerm, +args: List<&2, KTerm>, +seen: List<&2, String>, +fuel: U32) -> KTerm:
  w7_br_704(U32.is_eq(fuel, 0), book, t, args, seen, fuel)

# Module: src/back/native/product-layout.bend:78
@unsafe
def nq_layout_ref(+book: List<&2, KDef>, +t: KTerm, +args: List<&2, KTerm>, +seen: List<&2, String>, +fuel: U32) -> KTerm:
  +d = lookup(book, nm(t))
  nt_choose(KTerm, p88_string_eq(dk(d), "ADT") && U32.is_eq(da(d), terms_len(args)),
    u => kt("ADT", nm(t), 0, 0, args), u =>
    nt_choose(KTerm, p88_string_eq(dk(d), "Def") && Bool.not(nb_contains(seen, nm(t))),
      v => nq_layout_eval(book, dv(d), args, Con{nm(t), seen}, fuel), v => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}))

# Module: src/back/native/product-layout.bend:86
@unsafe
def nq_layout_apply(+book: List<&2, KDef>, +head: KTerm, args: List<&2, KTerm>, +seen: List<&2, String>, +fuel: U32) -> KTerm:
  match args:
    case Nil{}: head
    case Con{+arg, +rest}:
      nt_choose(KTerm, p98_tag_eq(head, "Lam") && nq_layout_subst_small(kid(head, 0), arg),
        u => nq_layout_eval(book, nq_layout_subst(kid(head, 0), ix(head), arg), rest, seen, fuel), u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})

# For positive syntax sizes B and A, substituting a subtree of size A into a
# body of size B yields at most B*A nodes. The limit bounds expansion before it
# happens; an unsafe alias cycle therefore cannot grow until memory exhaustion.

# Module: src/back/native/product-layout.bend:97
@unsafe
def w7_br_724(w7_c: Bool, +body: KTerm, +word: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      core_apply(core_apply(body, kid(word, 0)), kid(word, 1))
    case False{}:
      core_apply(body, word)

@unsafe
def w7_br_739(w7_c: Bool, +cs: KDef, +name: String, +arity: U32) -> Bool:
  match w7_c:
    case True{}:
      False{}
    case False{}:
      ns_ctor_known(cs, name, arity)

@unsafe
def agy_kr_resolve_cidx(+book: List<&2, KDef>, +cidx: KDef, +name: String, +hash: U32) -> KDef:
  +d = lookup(book, name)
  kc(KDef, p88_string_eq(dk(d), "Absent"),
    u => index_first(dc(index_find(cidx, name, hash, 32))), u => d)

@unsafe
def driver_foreign_names(+book: List<&2,KDef>, +defs: List<&2,KDef>) -> String:
  match defs:
    case Nil{}: ""
    case Con{d, rest}:
      kc(String, kc(Bool, p88_string_eq(dk(d), "Def") && p98_tag_eq(j_strip(dv(d)), "Foreign"),
        u => Bool.not(p88_string_eq(dk(j_find_ctor(book, dn(d))), "Absent")), u => False{}),
        u => name_key(dn(d)) ++ " names both a constructor and a foreign def: name one apart",
        u => driver_foreign_names(book, rest))

# Module: src/driver/api.bend:103
@unsafe
def p88_roots_done(state: P88State, values: List<&2,P88Node>) -> P88Decoded:
  match state values:
    case P88State{P88Cursor{SNil{},mode},nodes,strings,made,sn,begin,end} Con{P88Defs{book},Con{P88Checked{checked},Con{P88Fresh{+fresh},Con{P88World{+world},Con{P88Frontend{+ready},Nil{}}}}}}:
      p130m_roots_ready(P88Products{book,fresh,ready,world},fresh,ready,world,p130m_valid(mode))
    case s other: P88DecodeError{"cache roots or trailing data"}

@unsafe
def w7_br_798(w7_c: Bool, +body: KTerm, +owner: String, +arity: U32, +index: U32) -> Bool:
  match w7_c:
    case True{}:
      p205u_cons(kid(body,1),owner,arity,index) && U32.is_eq(p205u_refs(kid(body,0),owner),0)
    case False{}:
      False{}

@unsafe
def w7_br_801(w7_c: Bool, +book: List<&2,KDef>, +t: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      p205u_literal_def(lookup(book,nm(t)))
    case False{}:
      atom("Absent")

@unsafe
def p205u_closed_type(+book: List<&2,KDef>, +t: KTerm) -> KTerm:
  +ty = j_strip(t)
  kc(KTerm,(p98_tag_eq(ty,"Ref") || p98_tag_eq(ty,"ADT")) && List.is_empty(&2,KTerm,ks(ty)) &&
    agy_str_eq(dk(lookup(book,nm(ty))),"ADT"),u => ty,u => atom("Absent"))
@unsafe
def p205_overlay(defs: List<&2,KDef>, +edits: KDef) -> List<&2,KDef>:
  match defs:
    case Nil{}: []
    case Con{+d,rest}:
      Con{nc_context_pick(d,p111v_get(edits,dn(d))),p205_overlay(rest,edits)}

@unsafe
def w7_br_837(w7_c: Bool, +op: String, +a: U32, +b: U32) -> CtfeVal:
  match w7_c:
    case True{}:
      CVU32{U32.xor(a, b)}
    case False{}:
      w7_br_836(agy_str_eq(op, "u32_is_eq"), op, a, b)

@unsafe
def w7_br_856(w7_c: Bool, +op: String, +a: U32, +b: U32) -> CtfeVal:
  match w7_c:
    case True{}:
      CVNat{kc(U32, U32.is_lt(a, b), v => 0, v => U32.sub(a, b))}
    case False{}:
      w7_br_855(agy_str_eq(op, "nat_mul"), op, a, b)

@unsafe
def w7_br_864(w7_c: Bool, +op: String, +a: F32, +b: F32) -> CtfeVal:
  match w7_c:
    case True{}:
      CVF32{F32.div(a, b)}
    case False{}:
      w7_br_863(agy_str_eq(op, "f32_is_eq"), op, a, b)

@unsafe
def w7_br_865(w7_c: Bool, +op: String, +a: F32, +b: F32) -> CtfeVal:
  match w7_c:
    case True{}:
      CVF32{F32.mul(a, b)}
    case False{}:
      w7_br_864(agy_str_eq(op, "f32_div"), op, a, b)

@unsafe
def w7_br_879(w7_c: Bool, +owner: String, +v: CtfeVal) -> KTerm:
  match w7_c:
    case True{}:
      ctfe_reify_u32(v)
    case False{}:
      w7_br_878(agy_str_eq(owner, "Nat"), owner, v)

@unsafe
def agy_bf_check_right_args(args: List<&2,KTerm>, lams1: List<&2,KTerm>) -> AgyStep:
  match args lams1:
    case Con{ap,Con{ax,arest}} Con{+lp,Con{lx,lrest}}:
      kc(AgyStep,agy_bf_is_var(ap,ix(lp)) && agy_bf_vars_match(arest,lrest),
        u => agy_bf_step_expr(ax,ix(lx),ix(lp)),
        u => AgyStep{0,False{}})
    case _ _: AgyStep{0,False{}}

law p205v_closed_ty:
  for +book: List<&2,KDef>
  for +t: KTerm
  for +fuel: U32
  Bool

@unsafe
def w7_br_901(w7_c: Bool, +book: List<&2,KDef>, +call: KTerm, +fuel: U32) -> Bool:
  match w7_c:
    case True{}:
      p205v_closed_ty(book,p205u_at(ks(call),2),fuel) && p98_tag_eq(j_strip(p205u_at(ks(call),3)),"Lam") && p205v_closed_ty(book,kid(j_strip(p205u_at(ks(call),3)),0),fuel)
    case False{}:
      False{}

@unsafe
def w7_br_902(w7_c: Bool, +book: List<&2,KDef>, +call: KTerm, +fuel: U32) -> Bool:
  match w7_c:
    case True{}:
      p205v_closed_ty(book,p205u_at(ks(call),0),fuel) && p205v_closed_ty(book,p205u_at(ks(call),1),fuel)
    case False{}:
      w7_br_901(p98_tag_eq(call,"Call") && agy_str_eq(nm(call),"Sigma") && U32.is_eq(terms_len(ks(call)),4), book, call, fuel)

@unsafe
def p205v_closed_sigma(+book: List<&2,KDef>, +call: KTerm, +fuel: U32) -> Bool:
  w7_br_902(p98_tag_eq(call,"Call") && U32.is_eq(terms_len(ks(call)),2), book, call, fuel)

@unsafe
def w7_br_903(w7_c: Bool, +book: List<&2,KDef>, +ty: KTerm, +fuel: U32) -> Bool:
  match w7_c:
    case True{}:
      p205v_closed_sigma(book,j_call_spine(ty,[]),fuel)
    case False{}:
      False{}

@unsafe
def w7_br_904(w7_c: Bool, +book: List<&2,KDef>, +ty: KTerm, +fuel: U32) -> Bool:
  match w7_c:
    case True{}:
      True{}
    case False{}:
      w7_br_903(p98_tag_eq(ty,"App"), book, ty, fuel)

@unsafe
def p205v_closed_ty_go(+book: List<&2,KDef>, +ty: KTerm, +fuel: U32) -> Bool:
  w7_br_904((p98_tag_eq(ty,"Ref") || p98_tag_eq(ty,"ADT")) && List.is_empty(&2,KTerm,ks(ty)) && agy_str_eq(dk(lookup(book,nm(ty))),"ADT"), book, ty, fuel)

@unsafe
def w7_br_905(w7_c: Bool, +book: List<&2,KDef>, +t: KTerm, +fuel: U32) -> Bool:
  match w7_c:
    case True{}:
      False{}
    case False{}:
      p205v_closed_ty_go(book,j_strip(t),U32.sub(fuel,1))

@unsafe
def p205v_closed_ty(book, t, fuel):
  w7_br_905(U32.is_eq(fuel,0), book, t, fuel)

@unsafe
def p205v_arithmetic(+op: String, +a: U32, +b: U32) -> KTerm:
  w5c3_ar_add(String.eq(op,"u32_add"), op, a, b)

@unsafe
def w5c2_rcmp_le(m: Bool, +op: String, +la: U32, +ha: U32, +lb: U32, +hb: U32) -> KTerm:
  match m:
    case True{}: w5c2_rcmp_tf(U32.is_le(ha,lb), U32.is_gt(la,hb))
    case False{}: w5c2_rcmp_lt(String.eq(op,"u32_is_lt"), op, la, ha, lb, hb)

@unsafe
def w2d_fold_scon(+fname: String, +st_ty: KTerm, +nil_br: KTerm, +scon_br: KTerm) -> W2Fold:
  w7_br_918(p98_tag_eq(scon_br,"Mat") && agy_str_eq(nm(scon_br),"Chr") && U32.is_eq(terms_len(ks(scon_br)),2) && p98_tag_eq(kid(scon_br,1),"Efq") && p98_tag_eq(kid(scon_br,0),"Lam") && p98_tag_eq(kid(kid(scon_br,0),0),"Lam"), fname, st_ty, nil_br, scon_br)

@unsafe
def w2d_check_rec_builder(+d: KDef) -> W2Builder:
  +pname = dn(d)
  +ar = da(d)
  +ty0 = j_strip(dt(d))
  kc(W2Builder,agy_str_eq(dk(d),"Def") && Bool.not(db(d) || du(d)) && U32.is_eq(dx(d),0) &&
    U32.is_ge(ar,2) && U32.is_le(ar,5) &&
    p98_tag_eq(ty0,"All") && p198e_owner(kid(ty0,0),"Nat") &&
    w2d_check_builder_ty(kid(ty0,1),U32.sub(ar,1)) && p205u_room([dv(d)],256),
    u => w2d_check_rec_body(pname,ar,p205u_clean(dv(d))),
    u => W2Builder{pname,ar,False{},[],[],[],atom("Absent"),[],False{}})

law w2d_find_self_arm:
  for +t: KTerm
  for +hname: String
  for +ar: U32
  for +acc_id: U32
  W2UnboxArm

@unsafe
def w2d_pick_arm(+cur: W2UnboxArm, +alt: KTerm, +hname: String, +ar: U32, +acc_id: U32) -> W2UnboxArm:
  match cur:
    case W2UnboxArm{_,_,_,_,True{}}: cur
    case _: w2d_find_self_arm(alt,hname,ar,acc_id)

@unsafe
def w2d_find_self_arm_branch(+cname: String, +br: KTerm, +alt: KTerm, +hname: String, +ar: U32, +acc_id: U32) -> W2UnboxArm:
  +sb = j_strip(br)
  w2d_pick_arm(
    kc(W2UnboxArm,p98_tag_eq(sb,"Lam") && p98_tag_eq(j_strip(kid(sb,0)),"App"),
      u => w2d_check_self_arm_call(cname,ix(sb),j_call_spine(j_strip(kid(sb,0)),[]),hname,ar,acc_id),
      u => W2UnboxArm{"",0,atom("Absent"),[],False{}}),
    alt,hname,ar,acc_id)

@unsafe
def w2d_find_self_arm(t, hname, ar, acc_id):
  +s = j_strip(t)
  kc(W2UnboxArm,p98_tag_eq(s,"Mat") && U32.is_eq(terms_len(ks(s)),2),
    u => w2d_find_self_arm_branch(nm(s),kid(s,0),kid(s,1),hname,ar,acc_id),
    u => W2UnboxArm{"",0,atom("Absent"),[],False{}})

@unsafe
def w2d_ctor_field_ty(+book: List<&2,KDef>, +cname: String) -> KTerm:
  +cd = j_find_ctor(book,cname)
  +cty = j_strip(dt(cd))
  kc(KTerm,p98_tag_eq(cty,"All"),u => kid(cty,0),u => atom("Absent"))

@unsafe
def w2d_ctor_owner_ty(+book: List<&2,KDef>, +cname: String) -> KTerm:
  +cd = j_find_ctor(book,cname)
  +cty = j_strip(dt(cd))
  w2d_strip_alls(cty)

@unsafe
def w5c2_opid_fn(ok: Bool, +name: String) -> U32:
  match ok:
    case True{}: 86
    case False{}: p111_op_id_prior(name)

@unsafe
def p111v_value(+value: N111Value, +width: U32, +live: KDef, +ids: N111Ids) -> Bool:
  match value:
    case N111Local{name}:
      +found = p111v_get(live,name)
      Bool.not(String.eq(dk(found),"Absent")) && U32.is_eq(da(found),width)
    case N111Const{lo,hi}:
      w5c3_val_const(U32.is_eq(width,1), U32.is_eq(width,3), width, lo, hi)
    case N111FuncId{name}:
      match ids:
        case N111Ids{functions,_}: U32.is_le(width,2) && Bool.not(String.eq(dk(p111v_get(functions,name)),"Absent"))
    case N111CtorId{name}:
      match ids:
        case N111Ids{_,constructors}: U32.is_le(width,2) && Bool.not(String.eq(dk(p111v_get(constructors,name)),"Absent"))
    case N111Symbol{name}: False{}

@unsafe
def p111v_capacity(+value: N111Value, +live: KDef) -> U32:
  match value:
    case N111Local{name}: dx(p111v_get(live,name))
    case _: 0

@unsafe
def p111v_memory(+base: N111Value, +offset: U32, +width: U32, +live: KDef, +ids: N111Ids) -> Bool:
  match base:
    case N111Local{name}:
      +bytes = w5c3_u32_if(U32.is_eq(width,1),4,8)
      +found = p111v_get(live, name)
      +capacity = dx(found)
      Bool.not(String.eq(dk(found),"Absent")) && U32.is_eq(da(found),3) &&
        U32.is_ge(capacity,bytes) && U32.is_le(offset,U32.sub(capacity,bytes)) && U32.is_eq(U32.mod(offset,bytes),0)
    case _: False{}

# Direct O(min(|L|,|R|)) Patricia-tree intersection for p111v_intersection (zero re-hashing)
@unsafe
def w5c3_sig1(m: Bool, +s: String) -> List<&2,U32>:
  match m:
    case True{}: [3,2]
    case False{}: w5c3_sig3(String.eq(s,"p111_rt_ctor") || String.eq(s,"p111_rt_closure") || String.eq(s,"p111_rt_frame") || String.eq(s,"p111_rt_jump"), s)

@unsafe
def p111v_target(+value: N111Value, +ids: N111Ids, +constructor: Bool) -> KDef:
  match value:
    case N111CtorId{name}:
      match ids:
        case N111Ids{_,constructors}:
          match constructor:
            case True{}: p111v_get(constructors,name)
            case False{}: missing()
    case N111FuncId{name}:
      match ids:
        case N111Ids{functions,_}:
          match constructor:
            case True{}: missing()
            case False{}: p111v_get(functions,name)
    case _: missing()

@unsafe
def p111q_descriptor(+program: P111Program, ids: N111Ids) -> P111QData:
  match program:
    case P111Program{segments,constructors,show,show_names,effects,pure}:
      P111QData{"p111_program",8,True{},[
        P111QLong{11102,0},P111QLong{192,0},
        P111QLong{nt_count(N111Segment,segments),0},P111QLong{nt_count(N_Constructor,constructors),0},
        P111QLong{p111q_main_id(ids),0},P111QLong{nt_bool(pure),0},
        P111QLong{p111q_width(segments,False{},2),0},P111QLong{p111q_width(segments,True{},1),0},
        P111QLong{0,0},P111QLong{nt_count(U32,show),0},P111QLong{nt_count(String,show_names),0},P111QLong{1,0},
        P111QReloc{"p111_segments",0},P111QReloc{"p111_fid_arity",0},P111QReloc{"p111_fid_flags",0},P111QReloc{"p111_fid_results",0},
        P111QReloc{"p111_cid_arity",0},P111QReloc{"p111_cid_hot",0},P111QReloc{"p111_cid_names",0},P111QLong{0,0},
        P111QReloc{"p111_show_desc",0},P111QReloc{"p111_show_names",0},P111QLong{nt_count(String,effects),0},P111QReloc{"p111_effects",0}]}

@unsafe
def p112w_ready(+ready: KDef, +name: String) -> Bool:
  agy_str_eq(dk(p111v_get(ready,name)),"P112Worker")


@unsafe
def p112s_word(word: P112SWord, +constructors: KDef) -> N111Value:
  match word:
    case P112SRaw{value}: N111Const{value,0}
    case P112SPacked{name,payload}: N111Const{payload,U32.or(16777216,U32.shln(da(p112s_find(constructors,name)),8n))}
    case P112SBox{name,offset}: N111Const{U32.add(51413504,offset),U32.or(33554432,U32.shln(da(p112s_find(constructors,name)),8n))}


@unsafe
def p112s_constructor_ok(+constructors: KDef, +name: String, +arity: U32) -> Bool:
  +found = p112s_find(constructors,name)
  agy_str_eq(dk(found),"P112StaticCtor") && U32.is_lt(da(found),65536) && U32.is_eq(dx(found),arity) && p112s_immutable_name(name)


@unsafe
def w5c2_p112f_state(is_st: Bool, +prefix: String, +name: String) -> String:
  match is_st:
    case True{}: name
    case False{}: w5c2_p112f_p113i(String.starts_with(prefix, "p113i_") && String.starts_with(name, "p113i_"), prefix, name)

@unsafe
def p112f_cont_body(body: List<&2,N111Stmt>, +count: U32) -> Maybe<&2,P112FusionCont>:
  match body:
    case Con{N111Alloca{+name,2048,8},+rest}:
      nt_choose(Maybe<&2,P112FusionCont>,agy_str_eq(name,"scratch"),u =>
        nt_choose(Maybe<&2,P112FusionCont>,U32.is_eq(count,0),v => p112f_cont_gets(rest,0,0,[],""),v => p112f_cont_pop(rest,count)),u => None{})
    case _: None{}


@unsafe
def p112m_plan_rows(rows: List<&2,KTerm>, +rest: List<&2,KTerm>, +n: U32) -> NW_Rows:
  match rows:
    case Nil{}: NW_Rows{True{},[]}
    case Con{+row,more}: nw_join(p112m_planned_row(row,p112m_body(row,rest,n),n),p112m_plan_rows(more,rest,n))


@unsafe
def p112r_private_call(stmt: N111Stmt, +symbols: KDef) -> Bool:
  match stmt:
    case N111Call{+name,N111U64{},+symbol,Con{N111Arg{N111Ptr{},N111Local{+state}},+rest}}:
      +record = p111v_get(symbols,symbol)
      agy_str_eq(state,"state") && agy_str_eq(dk(record),"P112RegionSymbol") && p112r_words(rest,da(record))
    case _: False{}


@unsafe
def p113d_ready(+index: KDef, +name: String) -> Bool:
  agy_str_eq(dk(p111v_get(index,name)),"P113Direct")


@unsafe
def p113pl_call_result(+name: String, +args: List<&2,N111Value>, +shape: KTerm, +target: P113PTarget, +n: U32) -> P113DCode:
  nt_choose(P113DCode,p118t_target(target) && agy_str_eq(name,p113pl_owner(target)),
    u => nt_choose(P113DCode,agy_str_eq(tg(shape),"Absent"),
      v => P113DCode{[P113DAgain{p118t_tail_args(args)}],n,"",[]},
      v => p113d_fail("TRMC self call must retain boxed ABI",n)),
    u => p118t_original_call_result(name,args,shape,target,n))

@unsafe
def p113n_closed_owner(+book: List<&2,KDef>, +end: KTerm) -> Bool:
  +owner = lookup(book,nm(end))
  p98_tag_eq(end,"ADT") && agy_str_eq(dk(owner),"ADT") && U32.is_eq(da(owner),0) &&
    List.is_empty(&2,String,rm(end)) && List.is_empty(&2,KTerm,ks(end))


@unsafe
def p113j_cost(function: P113DFunction) -> U32:
  match function:
    case P113DFunction{name,params,result,public,+body}:
      U32.sub(U32.add(U32.add(p113j_expanded_size(body),nt_count(NC_Binding,params)),
        nt_choose(U32,U32.is_eq(p113j_scratch(body),0),u => 0,u => 1)),1)


@unsafe
def p113a_template(+original: N111Stmt, +n: U32, +heap_min: U32) -> List<&2,N111Stmt>:
  match original:
    case N111Call{destination,N111U64{},symbol,+args}:
      +id = p113a_call_id(symbol,args)
      p113a_template_core(original,n,heap_min,p113a_inputs(id,p111v_arg(args,2),n),[original])
    case _: [original]


@unsafe
def p113a_template_sunk(+original: N111Stmt, +n: U32, +heap_min: U32, +v0: N111Value, +v1: N111Value, +v2: N111Value) -> List<&2,N111Stmt>:
  match original:
    case N111Call{destination,N111U64{},symbol,+args}:
      +id = p113a_call_id(symbol,args)
      p113a_template_core(original,n,heap_min,p113a_sunk_sets(id,n,v0,v1,v2),
        nt_append(N111Stmt,p113a_sunk_stores(id,p111v_arg(args,2),n),[original]))
    case _: [original]


@unsafe
def p113a_match_sunk(body: List<&2,P113DStmt>) -> P113ASunk:
  match body:
    case Con{P113DScalar{N111Store{N111U64{},N111Local{+b0},0,+v0}},
         Con{P113DScalar{N111Store{N111U64{},N111Local{+b1},8,+v1}},
         Con{P113DScalar{N111Store{N111U64{},N111Local{+b2},16,+v2}},
         Con{P113DScalar{N111Alloca{+out,16,8}},
         Con{P113DScalar{+stmt},+rest}}}}}:
      +id = p113a_stmt_id(stmt)
      nt_choose(P113ASunk,U32.is_eq(id,74) && agy_str_eq(b0,"scratch") && agy_str_eq(b1,"scratch") &&
          agy_str_eq(b2,"scratch") && agy_str_eq(p113a_input_name(stmt),"scratch") && Bool.not(agy_str_eq(out,"scratch")),
        u => P113ASunkYes{stmt,74,[P113DScalar{N111Alloca{out,16,8}}],v0,v1,v2,rest},
        u => P113ASunkNo{})
    case Con{P113DScalar{N111Store{N111U64{},N111Local{+b0},0,+v0}},
         Con{P113DScalar{N111Store{N111U64{},N111Local{+b1},8,+v1}},
         Con{P113DScalar{N111Store{N111U64{},N111Local{+b2},16,+v2}},
         Con{P113DScalar{+stmt},+rest}}}}:
      +id = p113a_stmt_id(stmt)
      nt_choose(P113ASunk,U32.is_eq(id,73) && agy_str_eq(b0,"scratch") && agy_str_eq(b1,"scratch") &&
          agy_str_eq(b2,"scratch") && agy_str_eq(p113a_input_name(stmt),"scratch"),
        u => P113ASunkYes{stmt,73,[],v0,v1,v2,rest},
        u => P113ASunkNo{})
    case Con{P113DScalar{N111Store{N111U64{},N111Local{+b0},0,+v0}},
         Con{P113DScalar{N111Store{N111U64{},N111Local{+b1},8,+v1}},
         Con{P113DScalar{N111Alloca{+out,16,8}},
         Con{P113DScalar{+stmt},+rest}}}}:
      +id = p113a_stmt_id(stmt)
      nt_choose(P113ASunk,U32.is_eq(id,72) && agy_str_eq(b0,"scratch") && agy_str_eq(b1,"scratch") &&
          agy_str_eq(p113a_input_name(stmt),"scratch") && Bool.not(agy_str_eq(out,"scratch")),
        u => P113ASunkYes{stmt,72,[P113DScalar{N111Alloca{out,16,8}}],v0,v1,N111Const{0,0},rest},
        u => P113ASunkNo{})
    case Con{P113DScalar{N111Store{N111U64{},N111Local{+b0},0,+v0}},
         Con{P113DScalar{N111Alloca{+out,16,8}},
         Con{P113DScalar{+stmt},+rest}}}:
      +id = p113a_stmt_id(stmt)
      nt_choose(P113ASunk,U32.is_eq(id,75) && agy_str_eq(b0,"scratch") &&
          agy_str_eq(p113a_input_name(stmt),"scratch") && Bool.not(agy_str_eq(out,"scratch")),
        u => P113ASunkYes{stmt,75,[P113DScalar{N111Alloca{out,16,8}}],v0,N111Const{0,0},N111Const{0,0},rest},
        u => P113ASunkNo{})
    case _: P113ASunkNo{}

# Explicit unsigned loads establish the full Term value before64-bit use.
# QBE permits a long temporary in word contexts; high bits are now defined0.

@unsafe
def p113a_count_body(body: List<&2,P113DStmt>, count: U32) -> U32:
  match body:
    case Nil{}: count
    case Con{P113DScalar{stmt},rest}:
      p113a_count_body(rest,U32.add(count,nt_choose(U32,U32.is_gt(p113a_stmt_id(stmt),0),u => 1,u => 0)))
    case Con{P113DIf{condition,yes,no},rest}: p113a_count_body(rest,p113a_count_body(no,p113a_count_body(yes,count)))
    case Con{head,rest}: p113a_count_body(rest,count)


@unsafe
def p113k_exact(+lo: U32, +hi: U32) -> P113KFact:
  P113KFact{w5c2_p113k_exact_bits(U32.is_eq(hi, 0), lo, hi), True{}, lo, hi}

@unsafe
def p113k_get(+facts: KDef, +name: String) -> P113KFact:
  w5c2_p113k_get_rec(p111v_get(facts, name))


# AGY-W5-STRUCT: single-hash p113k_put
@unsafe
def w5c2_bs_1(exact: Bool, +lo: U32, +hi: U32, +name: String, +typ: N111Type, +op: String, +left: N111Value, +right: N111Value, +lf: P113KFact, +rf: P113KFact) -> N111Stmt:
  match exact:
    case True{}: N111Set{name, p113k_result_type(typ, op), N111Const{lo, hi}}
    case False{}:
      w5c2_bs_2(
        ((String.eq(op,"mul") || String.eq(op,"and")) && (p113k_zero(lf) || p113k_zero(rf))) ||
        ((String.eq(op,"shl") || String.eq(op,"shr")) && p113k_zero(lf)),
        name, typ, op, left, right, lf, rf)

@unsafe
def w4g_ic_has(+m: KDef, +n: String) -> Bool:
  U32.is_gt(da(p111v_get(m,n)),0)


@unsafe
def w4k_is_used(+used: KDef, +name: String) -> Bool:
  agy_str_eq(dk(p111v_get(used,name)),"W4KUsed")


@unsafe
def w4g_ver(+vers: KDef, +name: String) -> U32:
  da(p111v_get(vers,name))


@unsafe
def w4g_live_has(+live: KDef, +name: String) -> Bool:
  U32.is_gt(da(p111v_get(live,name)),0)


@unsafe
def p113l_version(+facts: KDef, +name: String) -> U32:
  ix(dt(p111v_get(facts, name)))

@unsafe
def p114t_expand(+stmt: N111Stmt, +ids: N111Ids, +site: U32) -> P114TExpansion:
  match stmt:
    case N111Call{+dest,N111U64{},+symbol,
      Con{N111Arg{N111Ptr{},N111Local{+state}},
      Con{N111Arg{N111U32{},N111FuncId{+fid}},
      Con{N111Arg{N111Ptr{},N111Local{+buffer}},
      Con{N111Arg{N111U32{},N111Const{+count,+high}},Nil{}}}}}}:
        nt_choose(P114TExpansion,agy_str_eq(symbol,"p111_rt_frame") && agy_str_eq(state,"state") &&
          U32.is_eq(high,0) && U32.is_lt(count,256) && p114t_buffer(buffer) && p114t_known_fid(fid,ids),
          u => P114TExpansion{p114t_frame(dest,fid,buffer,count,site),True{}},
          u => P114TExpansion{[stmt],False{}})
    case N111Call{+dest,N111U64{},+symbol,
      Con{N111Arg{N111Ptr{},N111Local{+state}},
      Con{N111Arg{N111U32{},N111Const{+count,+high}},Nil{}}}}:
        nt_choose(P114TExpansion,agy_str_eq(state,"state") && U32.is_eq(high,0) && U32.is_lt(count,256),
          u => nt_choose(P114TExpansion,agy_str_eq(symbol,"p111_rt_stack_pop"),
            v => P114TExpansion{p114t_pop(dest,count,site),True{}},
            v => nt_choose(P114TExpansion,agy_str_eq(symbol,"p111_rt_stack_get"),
              w => P114TExpansion{p114t_get(dest,count,site),True{}},
              w => P114TExpansion{[stmt],False{}})),
          u => P114TExpansion{[stmt],False{}})
    case _: P114TExpansion{[stmt],False{}}


@unsafe
def p114t_verify_done(+program: P113AProgram, +error: String) -> String:
  nt_choose(String,String.is_empty(error),u =>
    nt_choose(String,p114t_namespace(program),v => "",v => "reserved transport-template local"),u => error)


@unsafe
def p117h_get(+facts: KDef, +name: String) -> U32:
  +found = p111v_get(facts,name)
  nt_choose(U32,agy_str_eq(dk(found),"P117HOrigin"),u => da(found),u => 0)


@unsafe
def w4c_env_param_idx(+env: KDef, +name: String) -> Maybe<&2,U32>:
  +d = p111v_get(env,name)
  nt_choose(Maybe<&2,U32>,agy_str_eq(dk(d),"PRM"),u => Some{da(d)},u => None{})

@unsafe
def w5_fs_check_inv_val(v: Maybe<&2,N111Value>, +pidx: U32, +env: KDef) -> Bool:
  match v:
    case Some{N111Local{nm}}:
      +d = p111v_get(env,nm)
      agy_str_eq(dk(d),"PRM") && U32.is_eq(da(d),pidx)
    case _: False{}

@unsafe
def w4c_cond_nz_param(cond: N111Value, +env: KDef) -> Maybe<&2,U32>:
  match cond:
    case N111Local{cn}:
      +d = p111v_get(env,cn)
      nt_choose(Maybe<&2,U32>,agy_str_eq(dk(d),"NZ") || agy_str_eq(dk(d),"PRM"),u => Some{da(d)},u => None{})
    case _: None{}

@unsafe
def w4c_val_is_dec(mv: Maybe<&2,N111Value>, +pidx: U32, +env: KDef) -> Bool:
  match mv:
    case Some{N111Local{nm}}:
      +d = p111v_get(env,nm)
      agy_str_eq(dk(d),"DEC") && U32.is_eq(da(d),pidx)
    case _: False{}

@unsafe
def w4c_val_is_inc(mv: Maybe<&2,N111Value>, +pidx: U32, +env: KDef) -> Bool:
  match mv:
    case Some{N111Local{nm}}:
      +d = p111v_get(env,nm)
      agy_str_eq(dk(d),"INC") && U32.is_eq(da(d),pidx)
    case _: False{}

@unsafe
def w4c_val_bm_env(v: N111Value, +env: KDef) -> Maybe<&2,U32>:
  match v:
    case N111Const{+lo,0}:
      nt_choose(Maybe<&2,U32>,U32.is_le(lo,2147483647),u => Some{lo},u => None{})
    case N111Local{nm}:
      +d = p111v_get(env,nm)
      nt_choose(Maybe<&2,U32>,agy_str_eq(dk(d),"BM"),u => Some{da(d)},u => None{})
    case _: None{}

@unsafe
def p118ns_without(functions: List<&2,P113DFunction>, +replaced: KDef, +reversed: List<&2,P113DFunction>) -> List<&2,P113DFunction>:
  match functions:
    case Nil{}: nt_reverse(P113DFunction,reversed,[])
    case Con{+head,rest}:
      match head:
        case P113DFunction{name,params,result,public,body}:
          next = nt_choose(List<&2,P113DFunction>,agy_str_eq(dk(p111v_get(replaced,name)),"Absent"),
            u => Con{head,reversed},u => reversed)
          p118ns_without(rest,replaced,next)


@unsafe
def w7_p118ns_ctors_set(ctors: List<&2,N_Constructor>, +coldSet: KDef, reversed: List<&2,N_Constructor>) -> List<&2,N_Constructor>:
  match ctors:
    case Nil{}: nt_reverse(N_Constructor,reversed,[])
    case Con{N_Constructor{+name,arity,hot},rest}:
      w7_p118ns_ctors_set(rest,coldSet,Con{N_Constructor{name,arity,U32.is_eq(da(p111v_get(coldSet,name)),0)},reversed})

@unsafe
def p126sc_index(candidates: List<&2,P113DCandidate>, +counts: KDef, +index: P113ITable) -> P113ITable:
  match candidates:
    case Nil{}: index
    case Con{P113DCandidate{+function,+error,calls},+rest}:
      +name = p126sc_name(function)
      nt_choose(P113ITable,String.is_empty(error) && p126sc_shape(function) && U32.is_eq(da(p111v_get(counts,name)),1),
        u => p126sc_index(rest,counts,p113i_put(index,function,index_hash(name,2166136261),0)),
        u => p126sc_index(rest,counts,index))


@unsafe
def p126sc_partner_try(+left: P113DFunction, +counts: KDef, +slot: U32, +done: KDef, found: Maybe<&2,P113DFunction>) -> Maybe<&2,P113DFunction>:
  match found:
    case None{}: None{}
    case Some{+right}:
      nt_choose(Maybe<&2,P113DFunction>,agy_str_eq(dk(p111v_get(done,p126sc_name(right))),"Absent") && U32.is_gt(dx(p111v_get(counts,p126sc_name(right))),slot) && p126sc_call_has(ks(dv(p111v_get(counts,p126sc_name(right)))),p126sc_name(left)),
        u => nt_choose(Maybe<&2,P113DFunction>,p126sc_pair_safe(left,right),v => Some{right},v => None{}),u => None{})


@unsafe
def p128rf_filter(book: List<&2,KDef>, +members: KDef) -> List<&2,KDef>:
  match book:
    case Nil{}: []
    case Con{+d,+rest}:
      kc(List<&2,KDef>,p128rf_member(members,dn(d)),
        u => Con{d,p128rf_filter(rest,members)},u => p128rf_filter(rest,members))

@unsafe
def p128bi_body(body: List<&2,P113DStmt>, +index: KDef) -> List<&2,P113DStmt>:
  match body:
    case Nil{}: []
    case Con{P113DIf{condition,yes,no},rest}:
      Con{P113DIf{condition,p128bi_body(yes,index),p128bi_body(no,index)},p128bi_body(rest,index)}
    case Con{head,rest}: Con{p128bi_call(head,index),p128bi_body(rest,index)}


@unsafe
def p128bf_match(+stmt: N111Stmt, +ids: N111Ids, +site: U32) -> P128BFRead:
  match stmt:
    case N111Call{+dest,N111U64{},+symbol,
      Con{N111Arg{N111Ptr{},N111Local{+state}},
      Con{N111Arg{N111U64{},term},
      Con{N111Arg{N111Ptr{},N111Local{+buffer}},
      Con{N111Arg{N111U32{},N111CtorId{+ctor}},
      Con{N111Arg{N111U32{},N111Const{+count,+high}},Nil{}}}}}}}:
        nt_choose(P128BFRead,agy_str_eq(symbol,"p118_rt_borrow_fields") && agy_str_eq(state,"state") &&
          U32.is_eq(high,0) && U32.is_ge(count,2) && U32.is_le(count,8) &&
          p114t_buffer(buffer) && p128bf_known(ctor,count,ids) && U32.is_le(site,4294967200),
          u => P128BFRead{dest,term,buffer,ctor,count},u => P128BFSkip{})
    case _: P128BFSkip{}


@unsafe
def p143cs_mode(+definition: KDef, next: KDef) -> KDef:
  w7_br_975(p88_string_eq(dk(definition),"Def") && p98_tag_eq(dv(definition),"Absent"), definition, next)

@unsafe
def p144o_original(book: List<&2,KDef>, +name: String) -> Bool:
  match book:
    case Nil{}: False{}
    case Con{+d,+rest}:
      kc(Bool,p137q_is_adt(d),
        u => kc(Bool,p137q_is_ctr(lookup(dc(d),name)),u => db(d),u => p144o_original(rest,name)),
        u => p144o_original(rest,name))


@unsafe
def w7c_w6_alias_k(isK: Bool, +alias: KDef, +name: String) -> String:
  match isK:
    case False{}: name
    case True{}:
      +e = p111v_get(alias,name)
      w7c_w6_alias_hit(agy_str_eq(dk(e),"Absent"),e,name)

@unsafe
def p167live_eligible(program: P113DProgram) -> Bool:
  match program:
    case P113DProgram{P112StaticProgram{P111Program{segments,ctors,show,names,effects,pure},nodes},+functions}:
      Bool.not(List.is_empty(&2,P113DFunction,functions)) &&
        p118z_segments(p164a_generic(segments,[])) && p118z_functions(functions)


# General observer-first experiment. Source permission and the unchanged
# source-derived observer/root-retention analysis precede any seeded admission.
# No source name is special-cased, and no fictitious scheduler header is made.

@unsafe
def w4p_try_wrap(+fn: P113DFunction, +signatures: List<&2,KDef>, +prodIdx: KDef) -> P113DFunction:
  match fn:
    case P113DFunction{+name,+params,+result,+public,body}:
      nt_choose(P113DFunction,public && U32.is_eq(result,1) && String.starts_with(name,"$direct.") &&
          Bool.not(p126s_is_table(fn)),
        u =>
          +origName = String.drop(name,8n)
          +info = lookup(signatures,origName)
          nt_choose(P113DFunction,agy_str_eq(tg(dv(info)),"NQSig"),
            v =>
              +prodName = nm(dv(info))
              +psig = p111v_get(prodIdx,prodName)
              +pshapes = ks(dv(info))
              +rshape = dt(info)
              +rw = nq_width(rshape)
              nt_choose(P113DFunction,agy_str_eq(dk(psig),"W4Prod") &&
                  U32.is_eq(da(psig),nq_shape_words(pshapes)) &&
                  U32.is_eq(dx(psig),rw) && U32.is_ge(rw,1) && U32.is_le(rw,8),
                w => w4p_try_wrap_unpacked(fn,name,params,prodName,rshape,rw,w4p_unpack_params(params,pshapes,64)),
                w => fn),
            v => fn),
        u => fn)

law w7_pre_term:
  for +t: KTerm
  for +owner: String
  for +remSet: KDef
  for +acc: List<&2,String>
  List<&2,String>

@unsafe
def w7_pre_list(ts: List<&2,KTerm>, +owner: String, +remSet: KDef, +acc: List<&2,String>) -> List<&2,String>:
  match ts:
    case Nil{}: acc
    case Con{h,rest}: w7_pre_list(rest,owner,remSet,w7_pre_term(h,owner,remSet,acc))

@unsafe
def w7_pre_term(t, owner, remSet, acc):
  +tag = tg(t)
  nt_choose(List<&2,String>,agy_str_eq(tag,"Ref"),
    u =>
      +rn = nm(t)
      nt_choose(List<&2,String>,Bool.not(agy_str_eq(rn,owner)) && U32.is_gt(da(p111v_get(remSet,rn)),0),
        v => Con{rn,acc},v => acc),
    u => nt_choose(List<&2,String>,agy_str_eq(tag,"All") || agy_str_eq(tag,"Set") || agy_str_eq(tag,"Emp") ||
        agy_str_eq(tag,"Uni") || agy_str_eq(tag,"Eql") || agy_str_eq(tag,"Rfl") || agy_str_eq(tag,"Rwt") ||
        agy_str_eq(tag,"Era") || agy_str_eq(tag,"Typ") || agy_str_eq(tag,"Var") || agy_str_eq(tag,"Num"),
      v => acc,
      v => nt_choose(List<&2,String>,agy_str_eq(tag,"Ann") || agy_str_eq(tag,"Chk"),
        w => w7_pre_term(kid(t,0),owner,remSet,acc),
        w => nt_choose(List<&2,String>,agy_str_eq(tag,"App") && U32.is_eq(qt(t),0),
          x => w7_pre_term(kid(t,0),owner,remSet,acc),
          x => w7_pre_list(ks(t),owner,remSet,acc)))))

@unsafe
def w7_pre_deps_ok(deps: List<&2,String>, +ready: KDef) -> Bool:
  match deps:
    case Nil{}: True{}
    case Con{d,rest}: U32.is_gt(da(p111v_get(ready,d)),0) && w7_pre_deps_ok(rest,ready)

@unsafe
def p168t_has(index: KDef, name: String) -> Bool:
  Bool.not(agy_str_eq(dk(p111v_get(index,name)),"Absent"))



@unsafe
def p168v_functions(functions: List<&2,P113DFunction>, +adapters: KDef) -> List<&2,P113DFunction>:
  match functions:
    case Nil{}: []
    case Con{P113DFunction{+name,+params,+result,public,body},rest}:
      Con{P113DFunction{name,params,result,
        p168v_callable(name,nt_count(NC_Binding,params),result,p111v_get(adapters,name)),body},
        p168v_functions(rest,adapters)}



# Metadata failure cannot be repaired by any direct-map entry. Avoid its name
# hash and lookup entirely, instead of relying on eager Bool conjunction.
@unsafe
def p168j_forward_if(function: P113DFunction, ready: KDef) -> String:
  match function:
    case P113DFunction{+name,+params,result,public,body}:
      +entry = p111v_get(ready,name)
      nt_choose(String,agy_str_eq(dk(entry),"P112Worker") && U32.is_eq(dx(entry),0),
        u => p168j_forward(name,nt_count(NC_Binding,params)),u => "")



@unsafe
def p169q_import(+name: String, +arity: U32, direct: KDef) -> Bool:
  +function = p111v_get(direct,name)
  agy_str_eq(dk(function),"P113Direct") && U32.is_eq(da(function),arity) &&
    U32.is_eq(dx(function),1) && U32.is_eq(ix(dv(function)),1)



@unsafe
def p185cb_entry(+entry: KDef, +ready: Bool, +metadata: KDef) -> KDef:
  match entry:
    case KDef{name,+kind,+cid,+arity,+typ,+value,children,native,unsafe}:
      +clean = nt_choose(KTerm,p185cb_marker(value),u => atom("Absent"),u => value)
      +actual = p111v_get(metadata,U32.show(cid))
      +ok = ready && agy_str_eq(kind,"N111Id") && agy_str_eq(tg(clean),"Absent") &&
        agy_str_eq(tg(typ),"P185Constructor") && U32.is_eq(ix(typ),0) && U32.is_eq(qt(typ),11102) &&
        agy_str_eq(dk(actual),"P185CtorTable") && U32.is_eq(da(actual),arity) && U32.is_eq(dx(actual),0)
      KDef{name,kind,cid,arity,typ,nt_choose(KTerm,ok,u => kt("P185BoundDescriptor","",11102,192,[]),u => clean),children,native,unsafe}
    case _: entry

@unsafe
def p185cb_construct(+stmt: N111Stmt, +dest: String, +ctor: String, +buffer: String, +count: U32, +ids: N111Ids, +site: U32) -> List<&2,N111Stmt>:
  nt_choose(List<&2,N111Stmt>,p185cb_known(ctor,ids),
    u => p185cc_cached(stmt,dest,ctor,buffer,count,site),
    u => nt_append(N111Stmt,p185cc_guard(site),
      [N111If{p114t_local(site,"cold_guard"),p185cc_cached(stmt,dest,ctor,buffer,count,site),[stmt]}]))
# Post-verification ABI11102 register transport. p111v_counted_call proves
# jump FID/arity/incoming and p111v_contract proves return width/capacity.
# The existing scratch-origin and reserved p114t_ namespace rules apply.
# Capability 4 is still checked dynamically: without it the exact original
# helper performs its required trailing-register clear.

@unsafe
def p186rt_expand(+stmt: N111Stmt, +ids: N111Ids, +site: U32) -> P114TExpansion:
  match stmt:
    case N111Call{+dest,N111U64{},+symbol,
      Con{N111Arg{N111Ptr{},N111Local{+state}},
      Con{N111Arg{N111U32{},N111FuncId{+fid}},
      Con{N111Arg{N111Ptr{},N111Local{+buffer}},
      Con{N111Arg{N111U32{},N111Const{+count,+high}},Nil{}}}}}}:
        nt_choose(P114TExpansion,agy_str_eq(symbol,"p111_rt_jump") && agy_str_eq(state,"state") &&
          U32.is_eq(high,0) && U32.is_le(count,8) && p114t_buffer(buffer) &&
          p186rt_fid(fid,ids) && U32.is_le(site,4294967200),
          u => p186rt_guard(stmt,buffer,count,site,p186rt_jump(dest,fid)),
          u => P114TExpansion{[stmt],False{}})
    case N111Call{+dest,N111U64{},+symbol,
      Con{N111Arg{N111Ptr{},N111Local{+state}},
      Con{N111Arg{N111Ptr{},N111Local{+buffer}},
      Con{N111Arg{N111U32{},N111Const{+count,+high}},Nil{}}}}}:
        nt_choose(P114TExpansion,agy_str_eq(symbol,"p111_rt_return") && agy_str_eq(state,"state") &&
          U32.is_eq(high,0) && U32.is_le(count,8) && p114t_buffer(buffer) && U32.is_le(site,4294967200),
          u => p186rt_guard(stmt,buffer,count,site,p186rt_return(dest,count,site)),
          u => P114TExpansion{[stmt],False{}})
    case _: P114TExpansion{[stmt],False{}}
# ABI11102 Char is a full-word identity, not a Unicode-range conversion.
# The unchanged native verifier establishes the import signature and accessible
# buffer. Exact kind/count operands retain all other special constructors and
# malformed calls on the original route. No ownership operation is removed.
#
# A take writes its input before assigning the status destination; a constructor
# loads before assigning its destination. Consequently destination/input/buffer
# aliases preserve the original call's read-before-return ordering without a
# fresh temporary. The buffer's eight bytes retain every input bit.

@unsafe
def w11_p186ch_take_r3(+stmt: N111Stmt, +dest: String, a0: N111Arg, a1: N111Arg, a2: N111Arg, r3: List<&2,N111Arg>) -> P114TExpansion:
  match r3:
    case Con{a3,r4}: w11_p186ch_take_r4(stmt,dest,a0,a1,a2,a3,r4)
    case _: P114TExpansion{[stmt],False{}}

@unsafe
def w11_p186ch_ctor_r1(+stmt: N111Stmt, +dest: String, a0: N111Arg, r1: List<&2,N111Arg>) -> P114TExpansion:
  match r1:
    case Con{a1,r2}: w11_p186ch_ctor_r2(stmt,dest,a0,a1,r2)
    case _: P114TExpansion{[stmt],False{}}

@unsafe
def x188_render(code: X188Seq) -> String:
  x188_render_go([code],[])

@unsafe
def x186_float_home(name: String, frame: X181Frame, stack: Bool) -> Maybe<&2,X187Operand>:
  match frame:
    case X181Frame{slots,bytes,calls,params,symbol}:
      +slot = p111v_get(slots,name)
      nt_choose(Maybe<&2,X187Operand>,(agy_str_eq(dk(slot),"X181Register") && U32.is_lt(da(slot),5)) || (agy_str_eq(dk(slot),"X185Transient") && U32.is_lt(da(slot),6)),
        u => x186_float_narrow(x185_physical_slot(slot)),u =>
        nt_choose(Maybe<&2,X187Operand>,stack && agy_str_eq(dk(slot),"X181Stack") && U32.is_eq(dx(slot),8) &&
            U32.is_ge(da(slot),48) && U32.is_le(da(slot),bytes) && U32.is_eq(U32.mod(da(slot),8),0),
          v => Some{X187Mem{5,U32.sub(0,da(slot))}},v => None{}))

@unsafe
def x186_float_publish_to(home: Maybe<&2,X187Operand>, name: String,
    source: X187Operand, frame: X181Frame) -> X188Seq:
  match home:
    case Some{X187Mem{base,disp}}: x188_i2("movq",source,X187Mem{base,disp})
    case Some{operand}: x188_i2("movd",source,operand)
    case None{}: x188_cat(x188_i2("movd",source,x188_reg(10,32)),x181_store(name,frame,x188_reg(10,64)))

def agy_ctor_cid(ctor: String, ids: N111Ids) -> U32:
  match ids:
    case N111Ids{functions,ctors}: da(p111v_get(ctors,ctor))

@unsafe
def agy_frame_ctor_ok(frame: X181Frame) -> Bool:
  match frame:
    case X181Frame{slots,bytes,calls,params,symbol}:
      U32.is_eq(da(p111v_get(slots,"__agy_ctor_ok")),1)

@unsafe
def agy_reuse_find_ctor(+cls: U32, +rname: String, +ids: N111Ids, +cname: String,
    +typ: N111Type, +sym: String, +args: List<&2,N111Arg>, +rest: List<&2,P113DStmt>) -> AgyReuseMatch:
  match typ args:
    case N111U64{} Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111U32{},N111CtorId{+ctor}},Con{N111Arg{N111Ptr{},N111Local{+buf}},Nil{}}}}:
      +m = agy_rt_ctor_arity(sym)
      nt_choose(AgyReuseMatch,U32.is_gt(m,0) && U32.is_eq(p185cc_class(m),cls) &&
          agy_str_eq(state,"state") && p185cb_known(ctor,ids) && p185cc_known(ctor,m,ids),
        v => AgyReuseMatch{True{},ctor,Con{P113DScalar{N111Call{cname,N111U64{},
          "agy_rt_ctor_reuse" ++ U32.show(m),
          [N111Arg{N111Ptr{},N111Local{state}},N111Arg{N111U32{},N111CtorId{ctor}},
           N111Arg{N111Ptr{},N111Local{buf}},N111Arg{N111U64{},N111Local{rname}}]}},rest}},
        v => AgyReuseMatch{False{},"",Con{P113DScalar{N111Call{cname,typ,sym,args}},rest}})
    case _ _: AgyReuseMatch{False{},"",Con{P113DScalar{N111Call{cname,typ,sym,args}},rest}}

@unsafe
def x186_call_value(value: N111Value, +slots: KDef, +bytes: U32) -> U32:
  match value:
    case N111Local{name}: x186_call_slot(p111v_get(slots,name),bytes)
    case _: 1

@unsafe
def agy_call_src_reg(value: N111Value, slots: KDef) -> U32:
  match value:
    case N111Local{name}:
      +slot = p111v_get(slots,name)
      nt_choose(U32,agy_str_eq(dk(slot),"X185Transient") && U32.is_lt(da(slot),6),
        u => agy_call_treg(da(slot)),u => 0)
    case _: 0

@unsafe
def x181_function_id(ids: N111Ids, name: String, reg: X187Operand) -> X188Seq:
  match ids:
    case N111Ids{functions,constructors}: x188_id_load(functions,name,reg)

@unsafe
def x181_constructor_id(ids: N111Ids, name: String, reg: X187Operand) -> X188Seq:
  match ids:
    case N111Ids{functions,constructors}: x188_id_load(constructors,name,reg)

@unsafe
def w4_bf_mask_for(+stmt: N111Stmt, +rest: List<&2,P113DStmt>, +ids: N111Ids, +site: U32) -> U32:
  w4_bf_mask_read(rest,p128bf_match(stmt,ids,site))

@unsafe
def w12_bf_guard(+term: N111Value, +ctor: String, +ids: N111Ids, +site: U32) -> List<&2,N111Stmt>:
  +want = U32.or(131072,w12_ctor_id(ctor,ids))
  [N111Set{p114t_name(site,"borrow_word"),N111U64{},term},
   N111Bin{p114t_name(site,"borrow_aux_bits"),N111U64{},"shr",p114t_local(site,"borrow_word"),N111Const{40,0}},
   N111Bin{p114t_name(site,"borrow_tag_aux"),N111U64{},"and",p114t_local(site,"borrow_aux_bits"),N111Const{8388607,0}},
   N111Bin{p114t_name(site,"borrow_guard"),N111U32{},"eq",p114t_local(site,"borrow_tag_aux"),N111Const{want,0}}]

@unsafe
def x181_register_best(names: List<&2,String>, +counts: KDef, +slots: KDef,
  best: X181RegisterChoice) -> X181RegisterChoice:
  match names:
    case Nil{}: best
    case Con{+name,rest}:
      x181_register_best(rest,counts,slots,
        x181_register_consider(name,da(p111v_get(counts,name)),p111v_get(slots,name),best))

# Preserve the slot payload exactly apart from kind and physical location.
@unsafe
def x185_copy_name(+name: String, +aliases: KDef) -> String:
  +entry = p111v_get(aliases,name)
  nt_choose(String,agy_str_eq(dk(entry),"X185Alias"),u => nm(dv(entry)),u => name)

# The unchanged verifier requires each local definition before its reads.
# Unique definitions therefore dominate their copies; prior aliases already
# point to their canonical source. A single lookup suffices, with no recursive
# traversal or aliases to mutable homes. U32 copies retain their truncation.
@unsafe
def x185_physical_home(name: String, frame: X181Frame) -> X185Physical:
  match frame:
    case X181Frame{slots,bytes,calls,params,symbol}: x185_physical_slot(p111v_get(slots,name))

@unsafe
def x185_sf_cell(+buffer: String, +offset: U32, +typ: N111Type, buffers: KDef) -> Bool:
  +entry = p111v_get(buffers,buffer)
  agy_str_eq(dk(entry),"X185ScratchBuffer") && U32.is_le(x185_sf_width(typ),da(entry)) &&
    U32.is_le(offset,U32.sub(da(entry),x185_sf_width(typ)))

@unsafe
def x186_saves_mask(frame: X181Frame) -> U32:
  match frame:
    case X181Frame{slots,bytes,calls,params,symbol}:
      +entry = p111v_get(slots,"__x181_saved_mask")
      nt_choose(U32,agy_str_eq(dk(entry),"X186SavedMask") && U32.is_le(da(entry),31),
        u => da(entry),u => 31)

@unsafe
def x186_m_dead_buffer(+name: String, scan: X186Memory) -> Bool:
  match scan:
    case X186Memory{buffers,reads,used}:
      agy_str_eq(dk(p111v_get(buffers,name)),"X185ScratchBuffer") && U32.is_eq(da(p111v_get(used,name)),0)

@unsafe
def x186_p_source(value: N111Value, slots: KDef) -> KDef:
  match value:
    case N111Local{name}: p111v_get(slots,name)
    case _: missing()

@unsafe
def x186_p_source_valid(value: N111Value, slots: KDef) -> Bool:
  match value:
    case N111Local{name}: x186_p_word_home(p111v_get(slots,name),False{})
    case _: True{}

@unsafe
def x190_narrow_value(value: N111Value, frame: X181Frame, dest: X187Operand) -> X188Seq:
  match value:
    case N111Const{lo,hi}: x188_i2("movl",X187Imm{lo,0},dest)
    case N111Local{name}:
      match frame:
        case X181Frame{slots,bytes,calls,params,symbol}: x190_narrow_slot(p111v_get(slots,name),dest)
    case _: X188Empty{}
# Bounded straight-line value numbering for pure Bin/Offset expressions. Copy
# aliases are analysis metadata only: every original Set retains its snapshot.
# Every local write kills dependent keys/results/aliases. Unknown effects and
# control edges forget all facts; no memory load or statement is moved.
@unsafe
def x186_e_written(+state: X186ExprState, +name: String) -> X186ExprState:
  match state:
    case X186ExprState{facts,aliases,+fc,+ac,mentioned,ft,at}:
      w5b_e_written_nonempty(U32.is_eq(fc,0) && U32.is_eq(ac,0),state,facts,aliases,fc,ac,mentioned,ft,at,name)

@unsafe
def w4c_dia_has(+m: KDef, +n: String) -> Bool:
  U32.is_gt(da(p111v_get(m,n)),0)

@unsafe
def x190_v_zero(value: N111Value, state: X190Values) -> Bool:
  match value state:
    case N111Const{lo,hi} _: U32.is_eq(hi,0)
    case N111Local{name} X190Values{aliases,widths}: U32.is_gt(da(p111v_get(widths,name)),0)
    case _ _: False{}

@unsafe
def w5b_has_name(+name: String, m: KDef) -> Bool:
  U32.is_gt(da(p111v_get(m,name)),0)

@unsafe
def w5b_cnt_name(+name: String, m: KDef) -> U32:
  da(p111v_get(m,name))

@unsafe
def x186_x_canonical(value: N111Value, canonical: KDef) -> Bool:
  match value:
    case N111Local{name}: U32.is_gt(da(p111v_get(canonical,name)),0)
    case _: False{}

@unsafe
def x186_x_home(name: String, homes: KDef) -> Maybe<&2,X187Operand>:
  +slot = p111v_get(homes,name)
  nt_choose(Maybe<&2,X187Operand>,agy_str_eq(dk(slot),"X186Xmm") && U32.is_lt(da(slot),14),
    u => Some{x188_xmm(U32.add(da(slot),2))},u => None{})

@unsafe
def x186_x_compare_result(destination: Maybe<&2,X187Operand>, name: String, frame: X181Frame) -> X188Seq:
  match destination:
    case Some{operand}: x188_i2("movd",x188_reg(10,32),operand)
    case None{}: x181_store(name,frame,x188_reg(10,64))

law w4_xl_again_rewrite:
  for +i: U32
  for +cnt: U32
  for +vals: List<&2,N111Value>
  for +homes: KDef
  List<&2,N111Value>

@unsafe
def w4_xl_again_rewrite_step(+i: U32, +cnt: U32, +vals: List<&2,N111Value>, +homes: KDef,
    +ce: KDef, +cn: KDef) -> List<&2,N111Value>:
  w4_xl_again_rewrite(U32.inc(i),cnt,w2b_replace_nth(vals,da(ce),N111Local{dk(cn)}),homes)

@unsafe
def w4_xl_again_rewrite(i,cnt,vals,homes):
  nt_choose(List<&2,N111Value>,U32.is_ge(i,cnt),u => vals,
    u => w4_xl_again_rewrite_step(i,cnt,vals,homes,
      p111v_get(homes,"$w4_cx_" ++ U32.show(i)),p111v_get(homes,"$w4_cn_" ++ U32.show(i))))

@unsafe
def w12_int_cmp_imm(+typ: N111Type, right: N111Value, +dst: X187Operand, +ids: N111Ids) -> X188Seq:
  match right:
    case N111Const{+lo,0}:
      nt_choose(X188Seq,U32.is_eq(p111v_type(typ),1) || U32.is_le(lo,2147483647),
        u => x188_i2(x181_width(typ,"cmpq","cmpl"),X187Imm{lo,0},dst),
        u => X188Empty{})
    case N111CtorId{ctor}:
      x188_i2(x181_width(typ,"cmpq","cmpl"),X187Imm{w12_ctor_id(ctor,ids),0},dst)
    case _: X188Empty{}

@unsafe
def w2_tbl_store_to(home: Maybe<&2,X187Operand>, dest: String, sym: String, +frame: X181Frame) -> X188Seq:
  match home:
    case Some{xmm}:
      x188_many([
        x188_i2("leaq",X187Rip{sym,0,0},x188_reg(11,64)),
        x188_i2("movd",X187Indexed{11,10,8,0},xmm)])
    case None{}:
      x188_many([
        x188_i2("leaq",X187Rip{sym,0,0},x188_reg(11,64)),
        x188_i2("movq",X187Indexed{11,10,8,0},x188_reg(11,64)),
        x181_store(dest,frame,x188_reg(11,64))])

@unsafe
def w4b_xl_count_params(params: List<&2,String>, +idx: U32, +tparams: List<&2,String>,
    +nodes: List<&2,X186FloatNode>, +acc: U32) -> U32:
  match params:
    case Nil{}: acc
    case Con{+p,rest}:
      +isInv = w2_xl_param_inv(p,idx,nodes) && w2_xl_float_used(p,nodes)
      +isCar = w4_xl_carried_ok(p,idx,False{},tparams,nodes)
      w4b_xl_count_params(rest,U32.inc(idx),tparams,nodes,
        nt_choose(U32,isInv || isCar,u => U32.inc(acc),u => acc))

@unsafe
def x194fv_value(+value: N111Value, aliases: KDef) -> N111Value:
  match value:
    case N111Local{name}:
      +entry = p111v_get(aliases,name)
      nt_choose(N111Value,agy_str_eq(dk(entry),"Absent"),u => value,u => N111Local{dk(entry)})
    case _: value

@unsafe
def w2_fc_resolve(+value: N111Value, env: KDef) -> N111Value:
  match value:
    case N111Local{name}:
      +entry = p111v_get(env,name)
      nt_choose(N111Value,agy_str_eq(dk(entry),"W2Const"),u => N111Const{da(entry),0},u => value)
    case _: value

@unsafe
def x190_l_bit(name: String, ids: KDef) -> U32: da(p111v_get(ids,name))

@unsafe
def x190_a_color(names: List<&2,String>, rows: List<&2,U32>, +params: List<&2,String>,
    +bit: U32, +groups: List<&2,U32>, +affinities: KDef) -> List<&2,U32>:
  match names rows:
    case Con{+name,rest} Con{edges,more}:
      +nParams = nt_count(String,params)
      x190_a_color(rest,more,params,U32.shl(bit),
        x190_l_group(groups,x190_a_choose(groups,da(p111v_get(affinities,name)),bit,edges,x190_l_position(name,params,0),nParams),bit),affinities)
    case _ _: groups

@unsafe
def w5c_pj_collect_one(+name: String, +color: U32, +bit: U32, +header: U32, +ranges: KDef,
    +bReads: KDef, +bWrites: KDef, +st: W5CPJState) -> W5CPJState:
  match st:
    case W5CPJState{+ends,+occ}:
      nt_choose(W5CPJState,U32.is_lt(color,9),
        u =>
          +k = nt_choose(U32,U32.is_ge(color,4),w => U32.sub(color,4),w => U32.add(color,6))
          +r = p111v_get(ranges,name)
          +deadInBody = U32.is_eq(U32.and(header,bit),0) &&
            U32.is_eq(da(p111v_get(bReads,name)),0) && U32.is_eq(da(p111v_get(bWrites,name)),0)
          nt_choose(W5CPJState,deadInBody,
            v => st,
            v => nt_choose(W5CPJState,U32.is_eq(U32.and(header,bit),0) && agy_str_eq(dk(r),"X185TRange"),
              w => W5CPJState{ends,w5c_occ_add(occ,k,W5CIntv{da(r),dx(r)})},
              w => W5CPJState{x185_t_end(ends,k,4294967295),occ})),
        u => st)

@unsafe
def x190_branch_allowed_when(reuse: Bool, +name: String, typ: N111Type, op: String,
    condition: N111Value, facts: X190BranchFacts) -> Bool:
  match facts:
    case X190BranchFacts{reads,writes,pairs,protected}:
      +count = da(p111v_get(reads,name))
      +paired = da(p111v_get(pairs,name))
      x190_branch_enabled() && x190_branch_shape(name,typ,op,condition) &&
        ((U32.is_eq(count,1) && U32.is_eq(da(p111v_get(writes,name)),1)) ||
          (reuse && U32.is_gt(paired,0) && U32.is_eq(count,paired) &&
            U32.is_eq(da(p111v_get(protected,name)),0)))

@unsafe
def x198h_target(body: List<&2,P113DStmt>, +ids: N111Ids, +frame: X181Frame) -> Maybe<&2,String>:
  match body:
    case [P113DIf{condition,+yes,[P113DScalar{N111Call{+dest,N111U64{},+symbol,
        [N111Arg{N111Ptr{},N111Local{+state}},N111Arg{N111U32{},N111FuncId{+fid}},
         N111Arg{N111Ptr{},N111Local{+buffer}},N111Arg{N111U32{},N111Const{+count,0}}]}}]},
        P113DScalar{N111Return{N111Local{+result}}}]:
      nt_choose(Maybe<&2,String>,x198h_public(frame) && agy_str_eq(symbol,"p111_rt_jump") &&
        agy_str_eq(state,"state") && agy_str_eq(dest,result) && U32.is_le(count,8) &&
        p114t_buffer(buffer) && p186rt_fid(fid,ids) && x198h_finish(yes,dest,fid),
        u => Some{fid},u => None{})
    case _: None{}

@unsafe
def w12_i_st_opt_exp(+body: List<&2,P113DStmt>, +orig: List<&2,P113DStmt>, +wantXor: Bool, +oRaw: String, +oBits: String, +oExp: String) -> List<&2,P113DStmt>:
  match body:
    case Con{P113DScalar{N111Bin{+ex,t,op,N111CtorId{cname},N111Const{65536,0}}},+rest}:
      nt_choose(List<&2,P113DStmt>,agy_str_eq(op,"or") && agy_str_eq(cname,"True"),
        u => w12_i_st_eq(rest,orig,wantXor,oRaw,oBits,ex),
        u => w12_i_st_eq(body,orig,wantXor,oRaw,oBits,oExp))
    case _: w12_i_st_eq(body,orig,wantXor,oRaw,oBits,oExp)

@unsafe
def x191_single(+name: String, facts: X190BranchFacts) -> Bool:
  match facts:
    case X190BranchFacts{reads,writes,pairs,protected}:
      Bool.not(x181_register_reserved(name)) && U32.is_eq(da(p111v_get(reads,name)),1) &&
        U32.is_eq(da(p111v_get(writes,name)),1) && U32.is_eq(da(p111v_get(protected,name)),0)

# Only full-width multiplication/left shift matches 64-bit effective-address
# arithmetic. A U32 intermediate must retain its wrap and zero extension.
@unsafe
def x192_address_name(+name: String, +count: U32, facts: X190BranchFacts) -> Bool:
  match facts:
    case X190BranchFacts{reads,writes,pairs,protected}:
      Bool.not(x181_register_reserved(name)) && U32.is_eq(da(p111v_get(reads,name)),count) &&
        U32.is_eq(da(p111v_get(writes,name)),1) && U32.is_eq(da(p111v_get(protected,name)),0)

@unsafe
def x198qm_window(+output: List<&2,X188Seq>, +call: X188Seq) -> List<&2,X188Seq>:
  match output:
    case Con{a,Con{b,Con{c,Con{ptr,Con{e,Con{opid,Con{state,+stores}}}}}}}:
      match stores:
        case Con{write,Con{literal,Con{address,rest}}}:
          +arg = x198qm_lea(ptr,2)
          +id = x198qm_imm(opid,6)
          +d = x198qm_imm(literal,11)
          nt_choose(List<&2,X188Seq>,x198qm_rr(a,"xorl",0,0,32) && x198qm_rr(b,"movl",1,1,32) &&
            U32.is_eq(x198qm_imm(c,1),2) && x191_ff_private(arg) && U32.is_eq(arg,x198qm_lea(address,10)) &&
            x198qm_rr(e,"movl",6,6,32) && (U32.is_eq(id,18) || U32.is_eq(id,19)) &&
            x198qm_state(state) && x198qm_store(write),
            u => x198qm_accept(arg,d,id,p198q_plan(d),call,output,rest),
            u => Con{call,output})
        case _: Con{call,output}
    case _: Con{call,output}

@unsafe
def w4c_sub_fold3(r3: W4BRR, +i4: X187Parsed, +b: U32, +t: U32, +a: U32,
    +i0: X187Parsed, +i1: X187Parsed, +rest: List<&2,X187Parsed>, +tail: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +out: List<&2,X188Seq>) -> List<&2,X188Seq>:
  match r3:
    case W4BRR{op3,s3,ws3,d3,wd3}:
      nt_choose(List<&2,X188Seq>,
        agy_str_eq(op3,"subl") && U32.is_eq(s3,11) && U32.is_eq(ws3,32) && U32.is_eq(d3,a) && U32.is_eq(wd3,32),
        u => w4c_sub_fold4(w4b_as_rr(i4),b,t,a,i0,i1,rest,tail,fnItems,out),
        u => w4b_copy_peep(Con{i1,rest},fnItems,Con{X188One{i0},out}))
    case W4BRRNone{}: w4b_copy_peep(Con{i1,rest},fnItems,Con{X188One{i0},out})

@unsafe
def w4b_copy_check_test(tr: W4BRR, +c: U32, +i0: X187Parsed, +i1: X187Parsed,
    +i2: X187Parsed, +i3: X187Parsed, +tail: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +out: List<&2,X188Seq>) -> List<&2,X188Seq>:
  match tr:
    case W4BRR{top,s,ws,d,wd}:
      nt_choose(List<&2,X188Seq>,agy_str_eq(top,"testq") && U32.is_eq(s,c) && U32.is_eq(d,c) &&
          U32.is_eq(ws,64) && U32.is_eq(wd,64),
        u => w4b_copy_check_jcc(w4b_as_branch(i3),i0,i1,i2,i3,tail,fnItems,out),
        u => w4b_copy_peep(Con{i1,Con{i2,Con{i3,tail}}},fnItems,Con{X188One{i0},out}))
    case W4BRRNone{}: w4b_copy_peep(Con{i1,Con{i2,Con{i3,tail}}},fnItems,Con{X188One{i0},out})

@unsafe
def w7_find_loop_go(items: List<&2,X187Parsed>, +before: List<&2,X187Parsed>, +jmps: KDef) -> W4BLoopSplit:
  match items:
    case Nil{}: W4BLoopNone{}
    case Con{PLabel{+lbl},+rest}:
      nt_choose(W4BLoopSplit,
        U32.is_gt(da(p111v_get(jmps,lbl)),0) && w4b_has_jmp_to(lbl,rest) && Bool.not(w4b_has_any_branch_to(lbl,before)),
        u => W4BLoopSplit{nt_reverse(X187Parsed,before,[]),lbl,rest},
        u => w7_find_loop_go(rest,Con{PLabel{lbl},before},jmps))
    case Con{h,rest}: w7_find_loop_go(rest,Con{h,before},jmps)

@unsafe
def w4b_rotate_apply(split: W4BLoopSplit, +orig: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match split:
    case W4BLoopNone{}: orig
    case W4BLoopSplit{+before,+loopLbl,+body}:
      nt_choose(List<&2,X187Parsed>,w4b_has_non_jmp_to(loopLbl,body),u => orig,
        u => w4b_rotate_body(before,loopLbl,body,orig))

@unsafe
def w4c_copy_slot_fwd(+items: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  +totR = w4c_count_reads(items,W4CMEmpty{})
  +totW = w4c_count_writes(items,W4CMEmpty{})
  w4c_join_bbs(w4c_fwd_bbs(w4c_split_bb(items,[],[]),totR,totW))

# Sub-pass C3: Backedge dead-slot & GPR coalescing inside each basic block
@unsafe
def w4c_coal_bbs(bbs: List<&2,List<&2,X187Parsed>>, +totR: W4CMap, +totW: W4CMap) -> List<&2,List<&2,X187Parsed>>:
  match bbs:
    case Nil{}: []
    case Con{+b,rest}:
      +bbR = w4c_count_reads(b,W4CMEmpty{})
      +bbW = w4c_count_writes(b,W4CMEmpty{})
      Con{w4c_coal_bb(b,totR,totW,bbR,bbW,[]),w4c_coal_bbs(rest,totR,totW)}

@unsafe
def w4c_dead_slot_elim(+items: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  w4c_drop_dead_stores(items,w4c_count_reads(items,W4CMEmpty{}),[])

@unsafe
def w5_g1_c(+d1: U32, +op1: String, +rA: U32, +rB: U32, ld2: W5LoadRbp, +i3: X187Parsed,
    +r4: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match ld2:
    case W5LRYes{d2,dr2}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_eq(dr2,rA),
        u => w5_g1_d(d1,d2,op1,rA,rB,w4b_as_rr(i3),r4,fnItems,acc),
        u => None{})
    case W5LRNo{}: None{}

@unsafe
def w5_gpr_try_imm(im0: W4BImmReg, +i1: X187Parsed, +r2: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match im0:
    case W4BImmReg{op0,1,0,r,32}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,agy_str_eq(op0,"xorl"),
        u => w5_g8_b(r,w4b_as_imm_reg(i1),r2,fnItems,acc),
        u => None{})
    case W4BImmReg{op0,0,0,r,64}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,agy_str_eq(op0,"cmpq"),
        u => w5b_g12_b(r,w5_as_setcc(i1),r2,fnItems,acc),
        u => None{})
    case _: None{}

# G15: movq d1(%rbp), %rA; movq d2(%rbp), %rB; <comm64> %rA, %rB (%rA dead) -> movq d2(%rbp), %rB; <comm64> d1(%rbp), %rB
@unsafe
def w5b_scan_slots(items: List<&2,X187Parsed>, +waitInit: Bool, +afterLbl: Bool, +st: W5BSlotScan) -> W5BSlotScan:
  match items:
    case Nil{}: st
    case Con{+h,rest}:
      w5b_scan_slots(rest,waitInit && Bool.not(w5b_is_r12_ctx_init(h)),w5b_is_plabel(h),
        w5b_scan_slot_item(h,waitInit,afterLbl,st))

@unsafe
def w11_inst_imm_eq_reg(item: X187Parsed, +want_op: String, +want_imm: U32, +want_r: U32, +rw: U32) -> Bool:
  w11_some_u32_eq(w11_inst_imm_reg(item,want_op,want_r,rw),want_imm)

@unsafe
def w11_inst_reg_reg_eq(item: X187Parsed, +want_op: String, +r1: U32, +w1: U32, +r2: U32, +w2: U32) -> Bool:
  w11_some_u32_eq(w11_inst_reg_dst(item,want_op,r1,w1,w2),r2)

@unsafe
def w11_sel_bounce_s5(+srcY: X187Operand, +rN: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{i5,tail}: w11_sel_bounce_dst(srcY,rN,w11_inst_reg_any(i5,"movq",11,64),tail,fnItems)
    case _: None{}

@unsafe
def w5c_gpr_pass2(r1: W5BGprOut, f5: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match r1:
    case W5BGprUnchanged{}: f5
    case W5BGprChanged{+g1}: w5c_gpr_pass3(w5c_gpr_peep_c(g1,g1,[]),g1)

@unsafe
def x199s_check(flat: Maybe<&2,List<&2,X187Parsed>>, original: X188Seq, slots: KDef, label: String) -> X188Seq:
  match flat:
    case Some{+items}: x199s_finish(x199s_scan(items,items,slots,label,[]),items,original)
    case _: original

@unsafe
def x191_select_publish(names: List<&2,String>, +frame: X181Frame) -> X188Seq:
  match names:
    case Nil{}: X188Empty{}
    case Con{name,rest}:
      x188_cat(x181_store(name,frame,x188_reg(11,64)),x191_select_publish(rest,frame))

@unsafe
def x194_ps_pick(body: List<&2,P113DStmt>) -> Maybe<&2,X194Select>:
  nt_choose(Maybe<&2,X194Select>,x194_ps_enabled(),u => x194_ps_shape(body),u => None{})

@unsafe
def x194_ps_allowed(names: List<&2,String>, +facts: X190BranchFacts) -> Bool:
  match names facts:
    case Nil{} _: True{}
    case Con{+name,rest} X190BranchFacts{reads,writes,pairs,protected}:
      U32.is_gt(dx(p111v_get(pairs,name)),0) &&
        U32.is_eq(da(p111v_get(reads,name)),dx(p111v_get(pairs,name))) &&
        U32.is_eq(da(p111v_get(protected,name)),0) && x194_ps_allowed(rest,facts)

# Register-aware selection only after the existing X194Select proof has
# accounted for all removed Boolean reads and every effect-free copy arm.
# No new liveness assumptions, names, frame homes, IR motion or clobbers.
@unsafe
def x192_p_boolean(value: N111Value, facts: KDef) -> Bool:
  match value:
    case N111Const{lo,hi}: U32.is_eq(hi,0) && U32.is_le(lo,1)
    case N111Local{name}: U32.is_eq(da(p111v_get(facts,name)),1)
    case _: False{}

@unsafe
def x181_incoming(params: List<&2,String>, +n: U32, +frame: X181Frame, acc: List<&2,X188Seq>) -> X188Seq:
  match params:
    case Nil{}: x188_finish(acc)
    case Con{+name,rest}:
      x181_incoming(rest,U32.inc(n),frame,Con{
        nt_choose(X188Seq,U32.is_lt(n,6),
          u => x181_store(name,frame,x181_argreg(n)),
          u => x188_cat(x188_i2("movq",X187Mem{5,U32.add(16,U32.mul(U32.sub(n,6),8))},x188_reg(0,64)),
            x181_store(name,frame,x188_reg(0,64)))),acc})

def x198_sym_get(value: N111Value, env: KDef) -> U32:
  match value:
    case N111Local{name}: da(p111v_get(env,name))
    case _: 0

def x198_perm_cid(ctor: String, ids: N111Ids) -> U32:
  match ids:
    case N111Ids{functions,ctors}: da(p111v_get(ctors,ctor))

@unsafe
def agy_da_is_marked(target: String, ids: N111Ids) -> Bool:
  match ids:
    case N111Ids{fs,cs}: agy_str_eq(dk(p111v_get(fs,agy_da_key(target))),"AgyScan4")

law agy_zip_get_mark:
  for name: String
  for ids: N111Ids
  KDef


# === AGY-W2C-LISTAPP ===

@unsafe
def agy_sh_has_mark(+ids: N111Ids, +key: String) -> Bool:
  match ids:
    case N111Ids{fs,_}: agy_str_eq(dk(p111v_get(fs,key)),"AgyBasePinned")

# W13-A Win #1: All agy_sh_* paths are read-only and RFC-aware; cid_hot check is unnecessary.
@unsafe
def agy_sh_cid2(+ids: N111Ids, +a: String, +b: String) -> U32:
  +c1 = agy_sh_cid(ids,a)
  nt_choose(U32,U32.is_lt(c1,65536),u => c1,u => agy_sh_cid(ids,b))

def x198pw_name(+map: KDef,+role: String) -> String:
  nm(dt(p111v_get(map,role)))

@unsafe
def agy_zip_data_ok(+book: List<&2,KDef>, +ty: String, +leaf: String, +node: String) -> Bool:
  +d = lookup(book,ty)
  agy_str_eq(dk(d),"ADT") && U32.is_eq(da(d),0) && U32.is_eq(dx(d),0) && Bool.not(db(d)) &&
    agy_zip_data_layout(dc(d),ty,leaf,node)

@unsafe
def agy_zip_get_mark(name,ids):
  match ids:
    case N111Ids{fs,cs}: p111v_get(fs,agy_zip_key(name))

@unsafe
def agy_ro_get_mark(name: String, ids: N111Ids) -> KDef:
  match ids:
    case N111Ids{fs,cs}: p111v_get(fs,agy_ro_key(name))

# ---- x86 code emission for certified read-only native recursion ----
# Register convention inside <rec_lbl>:
#   %r12 (12): heap base pointer (u64*)
#   %r13 (13): x (u32, if arity == 2)
#   %r14 (14): current node payload heap-word index (callee-saved inside boxed arms)
#   %ecx (1) : recursion depth budget (starts at 256)
#   %rsi (6) : incoming node word
#   %eax (0) : U32 result
#   %r11d(11): bail flag (0 = ok, 1 = bail to slow path)
#   %rbx (3) : callee-saved scratch for Bin(left, right)

def x198pw_cid(c: String,ids: N111Ids) -> KDef:
  match ids:
    case N111Ids{functions,ctors}: p111v_get(ctors,c)

@unsafe
def x198pw_get_mark(name: String,ids: N111Ids) -> KDef:
  match ids:
    case N111Ids{fs,cs}: p111v_get(fs,x198pw_key(name))

@unsafe
def agy_fl_get_mark(name: String, ids: N111Ids) -> KDef:
  match ids:
    case N111Ids{fs,cs}: p111v_get(fs,agy_fl_key(name))

@unsafe
def x181_program_symbol(+symbol: String, +available: KDef) -> String:
  nt_choose(String,String.starts_with(symbol,"p112w_"),
    u => nt_choose(String,agy_str_eq(dk(p111v_get(available,symbol)),"X181Forward"),
      v => "",v => "x86 unavailable legacy worker: " ++ symbol),u => "")

@unsafe
def x181_forward_selected(+name: String, +ready: KDef) -> Bool:
  +entry = p111v_get(ready,name)
  agy_str_eq(dk(entry),"P112Worker") && U32.is_eq(dx(entry),0)

@unsafe
def x199s_token(value: N111Value, env: KDef) -> U32:
  match value:
    case N111Local{name}: da(p111v_get(env,name))
    case N111Const{+lo,hi}:
      nt_choose(U32,U32.is_eq(hi,0),u =>
        nt_choose(U32,U32.is_eq(lo,0),v => 7,v =>
          nt_choose(U32,U32.is_eq(lo,1),w => 8,w =>
            nt_choose(U32,U32.is_eq(lo,4),z => 9,z => 0))),u => 0)
    case _: 0

@unsafe
def agy_dp_tok(value: N111Value, env: KDef) -> U32:
  match value:
    case N111Local{name}: da(p111v_get(env,name))
    case N111Const{+lo,hi}:
      nt_choose(U32,U32.is_eq(hi,0),u =>
        nt_choose(U32,U32.is_eq(lo,0),v => 50,v =>
          nt_choose(U32,U32.is_eq(lo,1),w => 51,w =>
            nt_choose(U32,U32.is_eq(lo,4),z => 52,z => 0))),u => 0)
    case _: 0

law w5_lcu_scan_agains:
  for body: List<&2,P113DStmt>
  for +revPrefix: List<&2,P113DStmt>
  for +idx: U32
  for +acc: W5LcuScan
  W5LcuScan

@unsafe
def w5_lcu_scan_agains(body,revPrefix,idx,acc):
  match body:
    case Nil{}: acc
    case Con{P113DAgain{+vals},rest}:
      +aName = w5_lcu_local_opt(w5_lcu_nth_val(vals,idx))
      +mc = nt_choose(W5LcuCtor,U32.is_eq(w5_lcu_vals_count(aName,vals,0),1),
        u => w5_lcu_ctor_before_again(revPrefix,aName),
        u => W5LcuNo{})
      +acc2 = w5_lcu_merge_scan(acc,mc)
      w5_lcu_scan_agains(rest,[],idx,acc2)
    case Con{P113DIf{_,yes,no},rest}:
      +a1 = w5_lcu_scan_agains(yes,[],idx,acc)
      +a2 = w5_lcu_scan_agains(no,[],idx,a1)
      w5_lcu_scan_agains(rest,[],idx,a2)
    case Con{s,rest}:
      w5_lcu_scan_agains(rest,Con{s,revPrefix},idx,acc)

# Check whether every use of `pName` in `body` is admissible (tag/take/sink/result only, never reassigned).
@unsafe
def w5_lcu_check_param(+idx: U32, +pName: String, +nParams: U32, +body: List<&2,P113DStmt>) -> W5LcuCand:
  w5_lcu_check_scan_res(idx,pName,nParams,body,w5_lcu_scan_agains(body,[],idx,W5LcuScan{True{},False{},"",0}))

law w5_lcu_rewrite:
  for body: List<&2,P113DStmt>
  for +revAcc: List<&2,P113DStmt>
  for +idx: U32
  for +pName: String
  for +ctor: String
  for +arity: U32
  for +depth: U32
  List<&2,P113DStmt>

@unsafe
def w5_lcu_rewrite_again_mc(mc: W5LcuCtor, +vals: List<&2,N111Value>, +rest: List<&2,P113DStmt>, +revAcc: List<&2,P113DStmt>,
    +idx: U32, +pName: String, +ctor: String, +arity: U32, +depth: U32) -> List<&2,P113DStmt>:
  match mc:
    case W5LcuYes{_,+a,_,+fvs,+an}:
      +trimmed = w5_lcu_remove_ctor_go(revAcc,an,a,[])
      w5_lcu_rewrite(rest,Con{P113DAgain{w5_lcu_splice_vals(vals,idx,fvs)},trimmed},idx,pName,ctor,arity,depth)
    case W5LcuNo{}:
      w5_lcu_rewrite(rest,Con{P113DAgain{vals},revAcc},idx,pName,ctor,arity,depth)

@unsafe
def w5_lcu_rewrite_again(+vals: List<&2,N111Value>, +rest: List<&2,P113DStmt>, +revAcc: List<&2,P113DStmt>,
    +idx: U32, +pName: String, +ctor: String, +arity: U32, +depth: U32) -> List<&2,P113DStmt>:
  +aName = w5_lcu_local_opt(w5_lcu_nth_val(vals,idx))
  w5_lcu_rewrite_again_mc(w5_lcu_ctor_before_again(revAcc,aName),vals,rest,revAcc,idx,pName,ctor,arity,depth)

@unsafe
def w5_lcu_rewrite_scalar(+s: N111Stmt, +rest: List<&2,P113DStmt>, +revAcc: List<&2,P113DStmt>,
    +idx: U32, +pName: String, +ctor: String, +arity: U32, +depth: U32) -> List<&2,P113DStmt>:
  match s:
    case N111Call{+dest,N111U64{},+sym,+args}:
      nt_choose(List<&2,P113DStmt>,w5_lcu_is_tag_call(pName,sym,args),
        u => w5_lcu_rewrite(rest,Con{P113DScalar{N111Set{dest,N111U64{},N111CtorId{ctor}}},revAcc},idx,pName,ctor,arity,depth),
        u => nt_choose(List<&2,P113DStmt>,w5_lcu_is_take_call(pName,arity,sym,args),
          w =>
            +tbuf = w5_lcu_take_buf(args)
            +nld = w5_lcu_count_loads(rest,tbuf,arity,0)
            +pre : List<&2,P113DStmt> = nt_choose(List<&2,P113DStmt>,U32.is_ge(nld,arity),
              q => revAcc,
              q => w5_lcu_prepend_rev(w5_lcu_field_stores(tbuf,depth,0,arity),revAcc))
            +rev1 : List<&2,P113DStmt> = Con{P113DScalar{N111Set{dest,N111U64{},N111Const{1,0}}},pre}
            w5_lcu_rewrite(w5_lcu_fold_loads(rest,tbuf,arity,depth,[]),rev1,idx,pName,ctor,arity,depth),
          w => nt_choose(List<&2,P113DStmt>,w5_lcu_is_sink_call(pName,sym,args),
            z =>
              +mat = w5_lcu_materialize("w5_lcu_sink_" ++ U32.show(depth),ctor,arity,depth)
              +sinkCall : P113DStmt = P113DScalar{N111Call{dest,N111U64{},"p111_rt_sink",[p111_state(),N111Arg{N111U64{},N111Local{"w5_lcu_sink_" ++ U32.show(depth)}}]}}
              w5_lcu_rewrite(rest,Con{sinkCall,w5_lcu_prepend_rev(mat,revAcc)},idx,pName,ctor,arity,depth),
            z => w5_lcu_rewrite(rest,Con{P113DScalar{s},revAcc},idx,pName,ctor,arity,depth))))
    case _: w5_lcu_rewrite(rest,Con{P113DScalar{s},revAcc},idx,pName,ctor,arity,depth)

@unsafe
def w5_lcu_rewrite(body,revAcc,idx,pName,ctor,arity,depth):
  match body:
    case Nil{}: nt_reverse(P113DStmt,revAcc,[])
    case Con{P113DScalar{s},rest}: w5_lcu_rewrite_scalar(s,rest,revAcc,idx,pName,ctor,arity,depth)
    case Con{P113DIf{c,yes,no},rest}:
      +ny = w5_lcu_rewrite(yes,[],idx,pName,ctor,arity,depth)
      +nn = w5_lcu_rewrite(no,[],idx,pName,ctor,arity,depth)
      w5_lcu_rewrite(rest,Con{P113DIf{c,ny,nn},revAcc},idx,pName,ctor,arity,depth)
    case Con{P113DAgain{vals},rest}:
      w5_lcu_rewrite_again(vals,rest,revAcc,idx,pName,ctor,arity,depth)
    case Con{P113DResult{+vals},+rest}:
      nt_choose(List<&2,P113DStmt>,w5_lcu_vals_has(pName,vals),
        u =>
          +rName = "w5_lcu_res_" ++ U32.show(depth)
          +mat = w5_lcu_materialize(rName,ctor,arity,depth)
          w5_lcu_rewrite(rest,Con{P113DResult{[N111Local{rName}]},w5_lcu_prepend_rev(mat,revAcc)},idx,pName,ctor,arity,depth),
        u => w5_lcu_rewrite(rest,Con{P113DResult{vals},revAcc},idx,pName,ctor,arity,depth))
    case Con{h,rest}:
      w5_lcu_rewrite(rest,Con{h,revAcc},idx,pName,ctor,arity,depth)

@unsafe
def agy_f32_val_f(v: N111Value, env: KDef) -> Maybe<&2,KTerm>:
  match v:
    case N111Const{+lo,hi}:
      nt_choose(Maybe<&2,KTerm>,U32.is_eq(hi,0),u => Some{kt("FConst","",lo,0,[])},u => None{})
    case N111Local{name}:
      +d = agy_f32_get(env,name)
      nt_choose(Maybe<&2,KTerm>,agy_str_eq(dk(d),"F32Expr"),u => Some{dv(d)},u => None{})
    case _: None{}

@unsafe
def agy_f32_val_u(v: N111Value, env: KDef) -> Maybe<&2,KTerm>:
  match v:
    case N111Const{+lo,hi}:
      nt_choose(Maybe<&2,KTerm>,U32.is_eq(hi,0),u => Some{kt("UConst","",lo,0,[])},u => None{})
    case N111Local{name}:
      +d = agy_f32_get(env,name)
      nt_choose(Maybe<&2,KTerm>,agy_str_eq(dk(d),"U32Expr"),u => Some{dv(d)},u => None{})
    case _: None{}

@unsafe
def agy_f32_val_fuel(v: N111Value, env: KDef, +kind: String) -> Bool:
  match v:
    case N111Local{name}: agy_str_eq(dk(agy_f32_get(env,name)),kind)
    case _: False{}

@unsafe
def agy_map_has_ctors(+ids: N111Ids) -> Bool:
  U32.is_lt(agy_map_ctor_id(ids,"MTip"),65536) &&
  U32.is_lt(agy_map_ctor_id(ids,"MLeaf"),65536) &&
  U32.is_lt(agy_map_ctor_id(ids,"MNode"),65536) &&
  U32.is_lt(agy_map_ctor_id(ids,"SNil"),65536) &&
  U32.is_lt(agy_map_ctor_id(ids,"SCon"),65536) &&
  U32.is_lt(agy_map_ctor_id(ids,"Tuple"),65536)

@unsafe
def agy_map_get_fast(+symbol: String, +slow_sym: String, +ids: N111Ids) -> X181Output:
  +mtip  = agy_map_ctor_id(ids,"MTip")
  +mleaf = agy_map_ctor_id(ids,"MLeaf")
  +mnode = agy_map_ctor_id(ids,"MNode")
  +snil  = agy_map_ctor_id(ids,"SNil")
  +scon  = agy_map_ctor_id(ids,"SCon")
  +tup   = agy_map_ctor_id(ids,"Tuple")
  +pfx   = ".Lmg_" ++ symbol
  +l_loop = pfx ++ "_lp"
  +l_lok  = pfx ++ "_lk"
  +l_leaf = pfx ++ "_lf"
  +l_bit0 = pfx ++ "_b0"
  +l_bit1 = pfx ++ "_b1"
  +l_hit  = pfx ++ "_ht"
  +l_ksh  = pfx ++ "_ks"
  +l_hv   = pfx ++ "_hv"
  +l_sdok = pfx ++ "_sd"
  +l_miss = pfx ++ "_ms"
  +l_skok = pfx ++ "_sk"
  +l_ret  = pfx ++ "_rt"
  +l_bail = pfx ++ "_bl"
  X181Output{[x188_many([
    X188One{PSection{1}},X188One{PGlobal{symbol}},X188One{PType{symbol,2}},x188_label(symbol),
    x188_i1("pushq",x188_reg(5,64)),
    x188_i2("movq",x188_reg(4,64),x188_reg(5,64)),
    x188_i1("pushq",x188_reg(3,64)),
    x188_i1("pushq",x188_reg(12,64)),
    x188_i1("pushq",x188_reg(13,64)),
    x188_i1("pushq",x188_reg(14,64)),
    x188_i1("pushq",x188_reg(15,64)),
    x188_i2("subq",X187Imm{40,0},x188_reg(4,64)),
    # %r12 = st, %r13 = heap, %r14 = d, %rbx = orig_m, %r15 = key, %rax = cur
    x188_i2("movq",x188_reg(7,64),x188_reg(12,64)),
    x188_i2("movq",X187Mem{12,0},x188_reg(13,64)),
    x188_i2("movq",X187Mem{12,40},x188_reg(14,64)),
    x188_i2("movq",X187Mem{12,48},x188_reg(3,64)),
    x188_i2("movq",X187Mem{12,56},x188_reg(15,64)),
    x188_i2("movq",x188_reg(3,64),x188_reg(0,64)),
    x188_label(l_loop),
    # %rcx = tag, %rdx = cid
    x188_i2("movq",x188_reg(0,64),x188_reg(1,64)),
    x188_i2("shrq",X187Imm{56,0},x188_reg(1,64)),
    x188_i2("movq",x188_reg(0,64),x188_reg(2,64)),
    x188_i2("shrq",X187Imm{40,0},x188_reg(2,64)),
    x188_i2("andq",X187Imm{65535,0},x188_reg(2,64)),
    x188_i2("cmpq",X187Imm{mtip,0},x188_reg(2,64)),
    x188_i1("je",X187Target{l_miss}),
    # Extract loc into %rsi (handle 0x02 and 0x82)
    x188_i2("movabsq",X187Imm{4294967295,255},x188_reg(6,64)),
    x188_i2("andq",x188_reg(0,64),x188_reg(6,64)),
    x188_i2("cmpq",X187Imm{2,0},x188_reg(1,64)),
    x188_i1("je",X187Target{l_lok}),
    x188_i2("cmpq",X187Imm{130,0},x188_reg(1,64)),
    x188_i1("jne",X187Target{l_bail}),
    x188_i2("movq",X187Indexed{13,6,8,0},x188_reg(6,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(6,64)),
    x188_label(l_lok),
    x188_i2("cmpq",X187Imm{mleaf,0},x188_reg(2,64)),
    x188_i1("je",X187Target{l_leaf}),
    x188_i2("cmpq",X187Imm{mnode,0},x188_reg(2,64)),
    x188_i1("jne",X187Target{l_bail}),
    # MNode: pos = heap[loc] into %rdi
    x188_i2("movq",X187Indexed{13,6,8,0},x188_reg(7,64)),
    agy_map_emit_bit(pfx,snil,scon,15,l_bit0,l_bit1,l_bail),
    x188_label(l_bit0),
    x188_i2("movq",X187Indexed{13,6,8,8},x188_reg(0,64)),
    x188_i1("jmp",X187Target{l_loop}),
    x188_label(l_bit1),
    x188_i2("movq",X187Indexed{13,6,8,16},x188_reg(0,64)),
    x188_i1("jmp",X187Target{l_loop}),
    # MLeaf: %rsi = loc, %rcx = leaf tag; save to %r11 (loc), %r10 (tag)
    x188_label(l_leaf),
    x188_i2("movq",x188_reg(1,64),x188_reg(10,64)),
    x188_i2("movq",x188_reg(6,64),x188_reg(11,64)),
    x188_i2("movq",X187Indexed{13,6,8,0},x188_reg(8,64)),
    x188_i2("movq",x188_reg(15,64),x188_reg(9,64)),
    agy_map_emit_streq(pfx,snil,scon,l_hit,l_miss,l_bail),
    # Hit: v = heap[leaf_loc + 1]
    x188_label(l_hit),
    x188_i2("movq",X187Indexed{13,11,8,8},x188_reg(0,64)),
    x188_i2("movq",x188_reg(0,64),x188_reg(1,64)),
    x188_i2("shrq",X187Imm{56,0},x188_reg(1,64)),
    x188_i2("cmpq",X187Imm{2,0},x188_reg(1,64)),
    x188_i1("jb",X187Target{l_hv}),
    x188_i2("cmpq",X187Imm{130,0},x188_reg(1,64)),
    x188_i1("je",X187Target{l_ksh}),
    # Owned 0x02 value inside owned 0x02 heap leaf: check leaf_loc >= HEAP_OFF, keep, update leaf slot
    x188_i2("cmpq",X187Imm{2,0},x188_reg(1,64)),
    x188_i1("jne",X187Target{l_bail}),
    x188_i2("cmpq",X187Imm{2,0},x188_reg(10,64)),
    x188_i1("jne",X187Target{l_bail}),
    x188_i2("movq",X187Rip{"p111_program",64,0},x188_reg(1,64)),
    x188_i2("addq",X187Imm{127,0},x188_reg(1,64)),
    x188_i2("andq",X187Imm{4294967168,4294967295},x188_reg(1,64)),
    x188_i2("addq",X187Imm{51413504,0},x188_reg(1,64)),
    x188_i2("cmpq",x188_reg(1,64),x188_reg(11,64)),
    x188_i1("jb",X187Target{l_bail}),
    x188_i2("movq",x188_reg(11,64),X187Mem{4,24}),
    x188_i2("movq",x188_reg(12,64),x188_reg(7,64)),
    x188_i2("movq",x188_reg(0,64),x188_reg(6,64)),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("call",X187Target{"p111_rt_keep"}),
    x188_i2("movq",X187Mem{4,24},x188_reg(11,64)),
    x188_i2("movq",x188_reg(0,64),X187Indexed{13,11,8,8}),
    x188_i1("jmp",X187Target{l_hv}),
    x188_label(l_ksh),
    x188_i2("movq",x188_reg(12,64),x188_reg(7,64)),
    x188_i2("movq",x188_reg(0,64),x188_reg(6,64)),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("call",X187Target{"p111_rt_keep"}),
    x188_label(l_hv),
    # %rax = v_out; save to 16(%rsp), sink d (%r14) if boxed, then move v_out to %r14
    x188_i2("movq",x188_reg(0,64),X187Mem{4,16}),
    x188_i2("movq",x188_reg(14,64),x188_reg(1,64)),
    x188_i2("shrq",X187Imm{56,0},x188_reg(1,64)),
    x188_i2("cmpq",X187Imm{2,0},x188_reg(1,64)),
    x188_i1("jb",X187Target{l_sdok}),
    x188_i2("movq",x188_reg(12,64),x188_reg(7,64)),
    x188_i2("movq",x188_reg(14,64),x188_reg(6,64)),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("call",X187Target{"p111_rt_sink"}),
    x188_label(l_sdok),
    x188_i2("movq",X187Mem{4,16},x188_reg(14,64)),
    # Fall into miss/return path: %r14 = result value, %rbx = orig_m, %r15 = key
    x188_label(l_miss),
    x188_i2("movq",x188_reg(15,64),x188_reg(1,64)),
    x188_i2("shrq",X187Imm{56,0},x188_reg(1,64)),
    x188_i2("cmpq",X187Imm{2,0},x188_reg(1,64)),
    x188_i1("jb",X187Target{l_skok}),
    x188_i2("movq",x188_reg(12,64),x188_reg(7,64)),
    x188_i2("movq",x188_reg(15,64),x188_reg(6,64)),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("call",X187Target{"p111_rt_sink"}),
    x188_label(l_skok),
    # ctor2(st, Tuple, [orig_m, val])
    x188_i2("movq",x188_reg(3,64),X187Mem{4,0}),
    x188_i2("movq",x188_reg(14,64),X187Mem{4,8}),
    x188_i2("movq",x188_reg(12,64),x188_reg(7,64)),
    x188_i2("movabsq",X187Imm{tup,0},x188_reg(6,64)),
    x188_i2("movq",x188_reg(4,64),x188_reg(2,64)),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("call",X187Target{"p125_rt_ctor2"}),
    # p111_rt_return(st, &res, 1)
    x188_i2("movq",x188_reg(0,64),X187Mem{4,0}),
    x188_i2("movq",x188_reg(12,64),x188_reg(7,64)),
    x188_i2("movq",x188_reg(4,64),x188_reg(6,64)),
    x188_i2("movl",X187Imm{1,0},x188_reg(2,32)),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("call",X187Target{"p111_rt_return"}),
    x188_label(l_ret),
    x188_i2("addq",X187Imm{40,0},x188_reg(4,64)),
    x188_i1("popq",x188_reg(15,64)),
    x188_i1("popq",x188_reg(14,64)),
    x188_i1("popq",x188_reg(13,64)),
    x188_i1("popq",x188_reg(12,64)),
    x188_i1("popq",x188_reg(3,64)),
    x188_i1("popq",x188_reg(5,64)),
    x188_i0("ret"),
    x188_label(l_bail),
    x188_i2("movq",x188_reg(12,64),x188_reg(7,64)),
    x188_i2("addq",X187Imm{40,0},x188_reg(4,64)),
    x188_i1("popq",x188_reg(15,64)),
    x188_i1("popq",x188_reg(14,64)),
    x188_i1("popq",x188_reg(13,64)),
    x188_i1("popq",x188_reg(12,64)),
    x188_i1("popq",x188_reg(3,64)),
    x188_i1("popq",x188_reg(5,64)),
    x188_i1("jmp",X187Target{slow_sym}),
    X188One{PSize{symbol}}
  ])],""}

# Emit native Map.set in-place update fast path for p111 symbol
@unsafe
def agy_map_set_fast(+symbol: String, +slow_sym: String, +ids: N111Ids) -> X181Output:
  +mleaf = agy_map_ctor_id(ids,"MLeaf")
  +mnode = agy_map_ctor_id(ids,"MNode")
  +snil  = agy_map_ctor_id(ids,"SNil")
  +scon  = agy_map_ctor_id(ids,"SCon")
  +pfx   = ".Lms_" ++ symbol
  +l_loop = pfx ++ "_lp"
  +l_lok  = pfx ++ "_lk"
  +l_leaf = pfx ++ "_lf"
  +l_bit0 = pfx ++ "_b0"
  +l_bit1 = pfx ++ "_b1"
  +l_hit  = pfx ++ "_ht"
  +l_xok  = pfx ++ "_xo"
  +l_svok = pfx ++ "_sv"
  +l_skok = pfx ++ "_sk"
  +l_bail = pfx ++ "_bl"
  X181Output{[x188_many([
    X188One{PSection{1}},X188One{PGlobal{symbol}},X188One{PType{symbol,2}},x188_label(symbol),
    x188_i1("pushq",x188_reg(5,64)),
    x188_i2("movq",x188_reg(4,64),x188_reg(5,64)),
    x188_i1("pushq",x188_reg(3,64)),
    x188_i1("pushq",x188_reg(12,64)),
    x188_i1("pushq",x188_reg(13,64)),
    x188_i1("pushq",x188_reg(14,64)),
    x188_i1("pushq",x188_reg(15,64)),
    x188_i2("subq",X187Imm{40,0},x188_reg(4,64)),
    # %r12 = st, %r13 = heap, %rbx = orig_m, %r14 = key, %r15 = x, %rax = cur
    x188_i2("movq",x188_reg(7,64),x188_reg(12,64)),
    x188_i2("movq",X187Mem{12,0},x188_reg(13,64)),
    x188_i2("movq",X187Mem{12,40},x188_reg(3,64)),
    x188_i2("movq",X187Mem{12,48},x188_reg(14,64)),
    x188_i2("movq",X187Mem{12,56},x188_reg(15,64)),
    x188_i2("movq",x188_reg(3,64),x188_reg(0,64)),
    x188_label(l_loop),
    # Strictly require uniquely owned node: tag == 0x02 OR (tag == 0x82 && (heap[rfc_loc] & 0xffffff) == 1)!
    x188_i2("movq",x188_reg(0,64),x188_reg(1,64)),
    x188_i2("shrq",X187Imm{56,0},x188_reg(1,64)),
    x188_i2("movq",x188_reg(0,64),x188_reg(2,64)),
    x188_i2("shrq",X187Imm{40,0},x188_reg(2,64)),
    x188_i2("andq",X187Imm{65535,0},x188_reg(2,64)),
    x188_i2("movabsq",X187Imm{4294967295,255},x188_reg(6,64)),
    x188_i2("andq",x188_reg(0,64),x188_reg(6,64)),
    x188_i2("cmpq",X187Imm{2,0},x188_reg(1,64)),
    x188_i1("je",X187Target{l_lok}),
    x188_i2("cmpq",X187Imm{130,0},x188_reg(1,64)),
    x188_i1("jne",X187Target{l_bail}),
    x188_i2("movq",X187Indexed{13,6,8,0},x188_reg(6,64)),
    x188_i2("movq",x188_reg(6,64),x188_reg(1,64)),
    x188_i2("andq",X187Imm{16777215,0},x188_reg(1,64)),
    x188_i2("cmpq",X187Imm{1,0},x188_reg(1,64)),
    x188_i1("jne",X187Target{l_bail}),
    x188_i2("shrq",X187Imm{24,0},x188_reg(6,64)),
    x188_label(l_lok),
    # Reject static terms (loc < HEAP_OFF) before any in-place mutation
    x188_i2("movq",X187Rip{"p111_program",64,0},x188_reg(1,64)),
    x188_i2("addq",X187Imm{127,0},x188_reg(1,64)),
    x188_i2("andq",X187Imm{4294967168,4294967295},x188_reg(1,64)),
    x188_i2("addq",X187Imm{51413504,0},x188_reg(1,64)),
    x188_i2("cmpq",x188_reg(1,64),x188_reg(6,64)),
    x188_i1("jb",X187Target{l_bail}),
    x188_i2("cmpq",X187Imm{mleaf,0},x188_reg(2,64)),
    x188_i1("je",X187Target{l_leaf}),
    x188_i2("cmpq",X187Imm{mnode,0},x188_reg(2,64)),
    x188_i1("jne",X187Target{l_bail}),
    # MNode: pos = heap[loc] into %rdi
    x188_i2("movq",X187Indexed{13,6,8,0},x188_reg(7,64)),
    agy_map_emit_bit(pfx,snil,scon,14,l_bit0,l_bit1,l_bail),
    x188_label(l_bit0),
    x188_i2("movq",X187Indexed{13,6,8,8},x188_reg(0,64)),
    x188_i1("jmp",X187Target{l_loop}),
    x188_label(l_bit1),
    x188_i2("movq",X187Indexed{13,6,8,16},x188_reg(0,64)),
    x188_i1("jmp",X187Target{l_loop}),
    # MLeaf: %rsi = owned leaf loc
    x188_label(l_leaf),
    x188_i2("movq",X187Indexed{13,6,8,0},x188_reg(8,64)),
    x188_i2("movq",x188_reg(14,64),x188_reg(9,64)),
    agy_map_emit_streq(pfx,snil,scon,l_hit,l_bail,l_bail),
    # Hit on strictly owned heap path: bail if x (%r15) is unsealed boxed (must rfc_seal in slow)
    x188_label(l_hit),
    x188_i2("movq",x188_reg(15,64),x188_reg(1,64)),
    x188_i2("shrq",X187Imm{56,0},x188_reg(1,64)),
    x188_i2("cmpq",X187Imm{2,0},x188_reg(1,64)),
    x188_i1("jb",X187Target{l_xok}),
    x188_i2("cmpq",X187Imm{130,0},x188_reg(1,64)),
    x188_i1("jne",X187Target{l_bail}),
    x188_label(l_xok),
    x188_i2("movq",X187Indexed{13,6,8,8},x188_reg(8,64)),
    x188_i2("movq",x188_reg(15,64),X187Indexed{13,6,8,8}),
    # Sink old_v (%r8) if boxed
    x188_i2("movq",x188_reg(8,64),x188_reg(1,64)),
    x188_i2("shrq",X187Imm{56,0},x188_reg(1,64)),
    x188_i2("cmpq",X187Imm{2,0},x188_reg(1,64)),
    x188_i1("jb",X187Target{l_svok}),
    x188_i2("movq",x188_reg(12,64),x188_reg(7,64)),
    x188_i2("movq",x188_reg(8,64),x188_reg(6,64)),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("call",X187Target{"p111_rt_sink"}),
    x188_label(l_svok),
    # Sink key (%r14) if boxed
    x188_i2("movq",x188_reg(14,64),x188_reg(1,64)),
    x188_i2("shrq",X187Imm{56,0},x188_reg(1,64)),
    x188_i2("cmpq",X187Imm{2,0},x188_reg(1,64)),
    x188_i1("jb",X187Target{l_skok}),
    x188_i2("movq",x188_reg(12,64),x188_reg(7,64)),
    x188_i2("movq",x188_reg(14,64),x188_reg(6,64)),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("call",X187Target{"p111_rt_sink"}),
    x188_label(l_skok),
    # Return orig_m (%rbx)
    x188_i2("movq",x188_reg(3,64),X187Mem{4,0}),
    x188_i2("movq",x188_reg(12,64),x188_reg(7,64)),
    x188_i2("movq",x188_reg(4,64),x188_reg(6,64)),
    x188_i2("movl",X187Imm{1,0},x188_reg(2,32)),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("call",X187Target{"p111_rt_return"}),
    x188_i2("addq",X187Imm{40,0},x188_reg(4,64)),
    x188_i1("popq",x188_reg(15,64)),
    x188_i1("popq",x188_reg(14,64)),
    x188_i1("popq",x188_reg(13,64)),
    x188_i1("popq",x188_reg(12,64)),
    x188_i1("popq",x188_reg(3,64)),
    x188_i1("popq",x188_reg(5,64)),
    x188_i0("ret"),
    x188_label(l_bail),
    x188_i2("movq",x188_reg(12,64),x188_reg(7,64)),
    x188_i2("addq",X187Imm{40,0},x188_reg(4,64)),
    x188_i1("popq",x188_reg(15,64)),
    x188_i1("popq",x188_reg(14,64)),
    x188_i1("popq",x188_reg(13,64)),
    x188_i1("popq",x188_reg(12,64)),
    x188_i1("popq",x188_reg(3,64)),
    x188_i1("popq",x188_reg(5,64)),
    x188_i1("jmp",X187Target{slow_sym}),
    X188One{PSize{symbol}}
  ])],""}

@unsafe
def agy_bp_def(+book: List<&2,KDef>, +name: String, +h: U32) -> U32:
  +d = lookup(book,name)
  nt_choose(U32,agy_str_eq(dk(d),"Def") && db(d),
    u =>
      +h1 = agy_bp_str(name,h)
      +h2 = agy_bp_mix(agy_bp_mix(h1,da(d)),dx(d))
      agy_bp_term(dv(d),h2),
    u => 0)

@unsafe
def agy_bp_has_mark(+ids: N111Ids, +key: String) -> Bool:
  match ids:
    case N111Ids{fs,_}: agy_str_eq(dk(p111v_get(fs,key)),"AgyBasePinned")

@unsafe
def agy_sh_def_hash(+book: List<&2,KDef>, +name: String, +seed: U32) -> U32:
  +d = lookup(book,name)
  nt_choose(U32,agy_str_eq(dk(d),"Def"),
    u =>
      +h1 = agy_bp_str(name,seed)
      +h2 = agy_bp_mix(agy_bp_mix(h1,da(d)),dx(d))
      agy_bp_term(dv(d),h2),
    u => 0)

@unsafe
def agy_map_has_ctor(+book: List<&2,KDef>, +adt_name: String, +ctor_name: String, +arity: U32) -> Bool:
  +adt = lookup(book,adt_name)
  +c = lookup(dc(adt),ctor_name)
  agy_str_eq(dk(adt),"ADT") && agy_str_eq(dk(c),"Ctr") && (U32.is_eq(da(c),arity) || U32.is_eq(U32.sub(da(c),dx(c)),arity))

@unsafe
def agy_map_has_def(+book: List<&2,KDef>, +name: String, +arity: U32) -> Bool:
  +d = lookup(book,name)
  agy_str_eq(dk(d),"Def") && U32.is_eq(da(d),arity) && Bool.not(du(d))

@unsafe
def agy_map_get_mark(name: String, ids: N111Ids) -> KDef:
  match ids:
    case N111Ids{fs,cs}: p111v_get(fs,agy_map_key(name))

# Helper: emit sink-if-nontrivial for value in reg %rsi (clobbers %rax, %rcx, %rdx, %rdi, %rsi, %r8..%r11)
@unsafe
def x187_e_pair(+src: X187Operand, +dst: X187Operand, +family: U32, +width: U32,
    +code: U32, +extra: U32, +prefix: U32, +offset: U32) -> X187Encoded:
  match family:
    case 1: x187_e_alu(src,dst,width,extra,offset)
    case 2: x187_e_mov(src,dst,width,offset)
    case 15: x187_e_movabs(src,dst)
    case 3: x187_e_shift(src,dst,width,extra,prefix,offset)
    case 4: x187_e_imul(src,dst,width,offset)
    case 6: w5c_ep_f6(x187_e_reg(dst,32,False{}) && x187_e_rm(src,8,False{}),src,dst,offset)
    case 7: x187_e_sse(src,dst,prefix,code,offset)
    case 10: x187_e_movd(src,dst,offset)
    case 11: w5c_ep_f11(x187_e_reg(dst,128,True{}) && x187_e_rm(src,64,False{}),src,dst,offset)
    case 12: w5c_ep_f12(x187_e_reg(dst,64,False{}) && x187_e_rm(src,64,False{}) && Bool.not(x187_e_reg(src,64,False{})),src,dst,offset)
    case 13: x187_e_test(src,dst,width,offset)
    case 16: x191cm_pair(src,dst,width,code,offset)
    case 18: w5c_ep_f18(x187_e_reg(dst,32,False{}) && x187_e_rm(src,32,False{}),src,dst,offset)
    case _: x187_e_error()

law x187_elf_reloc_step:
  for +head: X187Relocation
  for +rest: List<&2,X187Relocation>
  for +section: U32
  for +index: KDef
  for +acc: List<&2,U32>
  List<&2,U32>
@unsafe
def x187_elf_reloc_valid(relocation: X187Relocation, +sizes: X187ElfSizes, +index: KDef) -> Bool:
  match relocation:
    case X187Relocation{+section,+offset,+kind,symbol,addendLo,addendHi}:
      +limit = x187_elf_section_size(section,sizes)
      +width = nt_choose(U32,U32.is_eq(kind,1),u => 8,u => 4)
      U32.is_ge(section,1) && U32.is_le(section,3) &&
        (U32.is_eq(kind,1) || U32.is_eq(kind,2) || U32.is_eq(kind,4)) &&
        U32.is_le(offset,limit) && U32.is_le(width,U32.sub(limit,offset)) &&
        agy_str_eq(dk(p111v_get(index,symbol)),"X187Symbol")

@unsafe
def x187_elf_reloc_bytes(relocation: X187Relocation, index: KDef) -> List<&2,U32>:
  match relocation:
    case X187Relocation{section,offset,kind,symbol,lo,hi}:
      x187_elf_cat(x187_elf_u64(offset,0),
        x187_elf_cat(x187_elf_u64(kind,da(p111v_get(index,symbol))),x187_elf_u64(lo,hi)))

@unsafe
def x187_elf_relocs(items: List<&2,X187Relocation>, +section: U32, +index: KDef, acc: List<&2,U32>) -> List<&2,U32>:
  match items:
    case Nil{}: nt_reverse(U32,acc,[])
    case Con{+head,rest}: x187_elf_reloc_step(head,rest,section,index,acc)

@unsafe
def x187_elf_reloc_step(head, rest, section, index, acc):
  match head:
    case X187Relocation{current,offset,kind,symbol,lo,hi}:
      x187_elf_relocs(rest,section,index,nt_choose(List<&2,U32>,U32.is_eq(current,section),
        u => x201e_u32_reverse(hi,x201e_u32_reverse(lo,x201e_u32_reverse(da(p111v_get(index,symbol)),
          x201e_u32_reverse(kind,Con{0,Con{0,Con{0,Con{0,x201e_u32_reverse(offset,acc)}}}})))),u => acc))

law w7_relocs_part:
  for items: List<&2,X187Relocation>
  for +index: KDef
  for +r1: List<&2,U32>
  for +n1: U32
  for +r2: List<&2,U32>
  for +n2: U32
  for +r3: List<&2,U32>
  for +n3: U32
  W7RelocParts

@unsafe
def w7_relocs_step(sec: U32, offset: U32, kind: U32, symbol: String, lo: U32, hi: U32,
    rest: List<&2,X187Relocation>, +index: KDef,
    +r1: List<&2,U32>, +n1: U32, +r2: List<&2,U32>, +n2: U32, +r3: List<&2,U32>, +n3: U32) -> W7RelocParts:
  match sec:
    case 1: w7_relocs_part(rest,index,w7_reloc_enc(offset,kind,da(p111v_get(index,symbol)),lo,hi,r1),U32.add(n1,24),r2,n2,r3,n3)
    case 2: w7_relocs_part(rest,index,r1,n1,w7_reloc_enc(offset,kind,da(p111v_get(index,symbol)),lo,hi,r2),U32.add(n2,24),r3,n3)
    case 3: w7_relocs_part(rest,index,r1,n1,r2,n2,w7_reloc_enc(offset,kind,da(p111v_get(index,symbol)),lo,hi,r3),U32.add(n3,24))
    case _: w7_relocs_part(rest,index,r1,n1,r2,n2,r3,n3)

@unsafe
def w7_relocs_part(items,index,r1,n1,r2,n2,r3,n3):
  match items:
    case Nil{}: W7RelocParts{r1,n1,r2,n2,r3,n3}
    case Con{X187Relocation{sec,offset,kind,symbol,lo,hi},rest}:
      w7_relocs_step(sec,offset,kind,symbol,lo,hi,rest,index,r1,n1,r2,n2,r3,n3)

law w7c_relocs_fused:
  for items: List<&2,X187Relocation>
  for +sizes: X187ElfSizes
  for +index: KDef
  for +count: U32
  for +r1: List<&2,U32>
  for +n1: U32
  for +r2: List<&2,U32>
  for +n2: U32
  for +r3: List<&2,U32>
  for +n3: U32
  W7cRelocResult

@unsafe
def w7c_reloc_fused_add(sec: U32, offset: U32, kind: U32, symIdx: U32, lo: U32, hi: U32,
    rest: List<&2,X187Relocation>, +sizes: X187ElfSizes, +index: KDef, +count: U32,
    +r1: List<&2,U32>, +n1: U32, +r2: List<&2,U32>, +n2: U32, +r3: List<&2,U32>, +n3: U32) -> W7cRelocResult:
  match sec:
    case 1: w7c_relocs_fused(rest,sizes,index,U32.inc(count),w7_reloc_enc(offset,kind,symIdx,lo,hi,r1),U32.add(n1,24),r2,n2,r3,n3)
    case 2: w7c_relocs_fused(rest,sizes,index,U32.inc(count),r1,n1,w7_reloc_enc(offset,kind,symIdx,lo,hi,r2),U32.add(n2,24),r3,n3)
    case _: w7c_relocs_fused(rest,sizes,index,U32.inc(count),r1,n1,r2,n2,w7_reloc_enc(offset,kind,symIdx,lo,hi,r3),U32.add(n3,24))

@unsafe
def w7c_reloc_fused_sym(+sec: U32, +offset: U32, +kind: U32, +lo: U32, +hi: U32,
    +sym: KDef, +rest: List<&2,X187Relocation>, +sizes: X187ElfSizes, +index: KDef, +count: U32,
    +r1: List<&2,U32>, +n1: U32, +r2: List<&2,U32>, +n2: U32, +r3: List<&2,U32>, +n3: U32) -> W7cRelocResult:
  +limit = x187_elf_section_size(sec,sizes)
  +width = nt_choose(U32,U32.is_eq(kind,1),u => 8,u => 4)
  nt_choose(W7cRelocResult,U32.is_lt(count,1048576) && U32.is_ge(sec,1) && U32.is_le(sec,3) &&
      (U32.is_eq(kind,1) || U32.is_eq(kind,2) || U32.is_eq(kind,4)) &&
      U32.is_le(offset,limit) && U32.is_le(width,U32.sub(limit,offset)) &&
      agy_str_eq(dk(sym),"X187Symbol"),
    u => w7c_reloc_fused_add(sec,offset,kind,da(sym),lo,hi,rest,sizes,index,count,r1,n1,r2,n2,r3,n3),
    u => W7cRelocBad{})

@unsafe
def w7c_relocs_fused(items,sizes,index,count,r1,n1,r2,n2,r3,n3):
  match items:
    case Nil{}: W7cRelocOk{W7RelocParts{r1,n1,r2,n2,r3,n3}}
    case Con{X187Relocation{sec,offset,kind,symbol,lo,hi},rest}:
      w7c_reloc_fused_sym(sec,offset,kind,lo,hi,p111v_get(index,symbol),rest,sizes,index,count,r1,n1,r2,n2,r3,n3)

@unsafe
def agy_p114h_seg_eligible(+segment: N111Segment, +direct: KDef, +hready: KDef) -> Bool:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,body}:
      w7c_p114h_hdr_ok(
        U32.is_eq(result,1) && U32.is_eq(incoming,0) && U32.is_eq(flags,0) &&
        U32.is_gt(arity,0) && U32.is_le(arity,8) &&
        Bool.not(String.starts_with(name,"$p111.k.")) && Bool.not(String.starts_with(name,"p111.k.")),
        name,direct,hready)

@unsafe
def w10_merge_seq(+entry_mod: String, +first_mod: String, +mods: List<&1,String>) -> X188Seq:
  x188_many([
    w10_merge_data(),
    w10_merge_unused_seg(),
    w10_merge_main(entry_mod,first_mod,mods)])

@unsafe
def w10_is_weak_sym(+weak_set: KDef, +name: String) -> Bool:
  agy_str_eq(dk(p111v_get(weak_set,name)),"W10Weak")

# Single-pass Elf64_Sym emitter reconciling w9_elf_fast (`w7c_elf_ascii_valid` +
# `w7c_elf_sym_nums_valid` + `w7c_elf_sym_push`) with M2 `STB_LOCAL`/`STB_GLOBAL`/`STB_WEAK`:
#   STB_LOCAL  = 0 -> 0
#   STB_GLOBAL = 1 -> 16
#   STB_WEAK   = 2 -> 32  (only for defined symbols in weak_set)
@unsafe
def w10f_elf_checked_go(text_rev: List<&2,U32>, rodata_rev: List<&2,U32>, data_rev: List<&2,U32>,
    plan: List<&2,X187Relocation>, +ts: U32, +rs: U32, +ds: U32, +count: U32, +firstGlobal: U32,
    table: List<&2,U32>, strings: List<&2,U32>, +stringSize: U32, rr: W7cRelocResult) -> X187ObjectResult:
  match rr:
    case W7cRelocOk{rp}: w10f_elf_sections_emit_rev(text_rev,rodata_rev,data_rev,plan,ts,rs,ds,count,firstGlobal,table,strings,stringSize,rp)
    case W7cRelocBad{}: X187ObjectResult{[],"invalid ELF relocation"}

@unsafe
def w10_if_abi_has(+idx: KDef, +key: String) -> Bool:
  Bool.not(agy_str_eq(dk(p111v_get(idx, key)), "Absent"))

@unsafe
def w10_if_stub_kind(+book: List<&2, KDef>, +name: String) -> U32:
  +d = lookup(book, name)
  nt_choose(U32, db(d) && du(d) && agy_str_eq(dk(d), "Def") && U32.is_eq(dx(d), 0),
    u => w10_if_peel_stub(name, dv(d), 0),
    u => 0)

