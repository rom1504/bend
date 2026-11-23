# Module m05 (K=13 acyclic topological split of wave11_unified/compiler.bend)
# defs=744 laws=72 sccs=546 deps=[m00a,m00b,m01,m02,m03,m04] cross_imports=594 fid_base=27600..32799

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
law dead_type:
  for +book: List<&2, KDef>
  for +ty: KTerm
  Bool

# Module: src/check/kernel.bend:216
law mat_goal:
  for +book: List<&2, KDef>
  for +goal: KTerm
  for +tel: KTerm
  for +n: U32
  for +name: String
  for +xs: List<&2, KTerm>
  KTerm

# Module: src/check/kernel.bend:252
law mat_goal_head:
  for +book: List<&2, KDef>
  for +goal: KTerm
  for +tel: KTerm
  for +n: U32
  for +name: String
  for +xs: List<&2, KTerm>
  KTerm

# Module: src/check/kernel.bend:269
law tele_quantities_head:
  for +book: List<&2, KDef>
  for +ty: KTerm
  for +n: U32
  List<&2, KTerm>

# Module: src/check/kernel.bend:305
law tele_tip_head:
  for +book: List<&2, KDef>
  for +t: KTerm
  KTerm

# Module: src/check/kernel.bend:342
law env_tele_fill_eager:
  for +book: List<&2,KDef>
  for +tel: KTerm
  for +args: List<&2,KTerm>
  KTerm

# Module: src/check/env-telescope.bend:92
law sp_keys:
  for +ts: List<&2, KTerm>
  String

# Module: src/check/specialize.bend:18
law sp_apply_template:
  for +body: KTerm
  for +xs: List<&2, KTerm>
  KTerm

# Module: src/check/prefix-state.bend:10
law base_prefix_patch:
  for +defs: List<&2,KDef>
  for +patches: List<&2,KDef>
  List<&2,KDef>

# Module: src/check/prefix-state.bend:80
law base_prefix_deltas:
  for +defs: List<&2,KDef>
  for +raw: List<&2,KDef>
  List<&2,KDef>

# Module: src/check/annotate.bend:5
law ka_type_app:
  for +e: KEnv
  for +t: KTerm
  for +fty: KTerm
  KTerm

# Module: src/check/annotate.bend:59
law f_all_body:
  for +name: String
  for +id: U32
  for +q: U32
  for +exi: Bool
  for +a: KTerm
  for +p: FParsed
  FParsed

# Module: src/front/parser.bend:66
law f_tuple:
  for +n: KTerm
  for +p: FParsed
  FParsed

# Module: src/front/parser.bend:75
law f_equation_type:
  for +a: KTerm
  for +b: KTerm
  for +neg: Bool
  for +opBegin: U32
  for +opEnd: U32
  for +p: FParsed
  FParsed

# Module: src/front/parser.bend:104
law fpe_message:
  for +source: String
  for +offset: U32
  for +end: U32
  for +error: KTerm
  for +observed: String
  String

# Module: src/front/parser.bend:554
law f_namespace_operator:
  for +head: KTerm
  for +input: FInput
  Bool

# Module: src/front/parallel.bend:3
law f_graph_aliases:
  for +imports: List<&2, KTerm>
  for +source: FSource
  for +sources: List<&2,FSource>
  for +root: String
  List<&2, KTerm>

# Module: src/load/graph.bend:66
law j_type:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +t: KTerm
  KTerm

# Module: src/back/common/queries.bend:27
law j_type_on:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +t: KTerm
  for +key: String
  KTerm

# Module: src/back/common/queries.bend:38
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
law j_specialize:
  for +book: List<&2, KDef>
  for +tel: KTerm
  for +args: List<&2, KTerm>
  KTerm

# Module: src/back/common/queries.bend:134
law j_constructor_count:
  for +book: List<&2, KDef>
  for +ty: KTerm
  U32

# Module: src/back/common/queries.bend:206
law j_literal_provenance:
  for +book: List<&2, KDef>
  for +ty: KTerm
  for +literal: String
  String

# Module: src/back/js/validate.bend:11
law j_layout_array_intrinsic:
  for +book: List<&2, KDef>
  for +f: KTerm
  Bool

# Module: src/back/js/validate.bend:269
law nc_live_count_head:
  for +book: List<&2, KDef>
  for +head: KTerm
  for +left: U32
  U32

# Erasure consumes annotate_book output. Type annotations determine erased
# arguments, constructor fields, lambda binders, and match-field arities.

# Module: src/back/native/erase.bend:10
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
def core_literal_type(+book: List<&2,KDef>, +t: KTerm, +ty: KTerm) -> Bool:
  p98_tag_eq(ty, "ADT") && p88_string_eq(nm(ty), nm(t)) && List.is_empty(&2, String, rm(ty)) && db(lookup(book, nm(t)))

# Module: src/core/term.bend:529
law index_insert:
  for +tree: KDef
  for +d: KDef
  for +hash: U32
  for +mask: U32
  KDef

law index_insert_legacy:
  for +tree: KDef
  for +d: KDef
  for +hash: U32
  for +mask: U32
  KDef

@unsafe
def w5_idx_ins_leaf(isZero: Bool, +tree: KDef, +d: KDef, +hash: U32, +mask: U32, bucket: List<&2, KDef>) -> KDef:
  match isZero:
    case True{}: index_leaf(d, hash, bucket)
    case False{}: index_join(tree, d, hash, mask)

@unsafe
def w5_idx_ins_br(goLeft: Bool, +stored: U32, +split: U32, +left: KDef, +right: KDef, +d: KDef, +hash: U32, +mask: U32) -> KDef:
  match goLeft:
    case True{}: index_node(stored, split, index_insert(left, d, hash, mask), right)
    case False{}: index_node(stored, split, left, index_insert(right, d, hash, mask))

@unsafe
def w5_idx_ins_split(doJoin: Bool, +tree: KDef, +stored: U32, +split: U32, +left: KDef, +right: KDef, +d: KDef, +hash: U32, +mask: U32) -> KDef:
  match doJoin:
    case True{}: index_join(tree, d, hash, mask)
    case False{}: w5_idx_ins_br(U32.is_eq(U32.and(hash, split), 0), stored, split, left, right, d, hash, mask)

@unsafe
def w5_idx_ins_node(isZero: Bool, +tree: KDef, +stored: U32, +split: U32, +left: KDef, +right: KDef, +d: KDef, +hash: U32, +mask: U32) -> KDef:
  match isZero:
    case True{}: index_insert_legacy(tree, d, hash, mask)
    case False{}: w5_idx_ins_split(Bool.not(U32.is_eq(mask, 0)) && U32.is_lt(mask, split), tree, stored, split, left, right, d, hash, mask)

# Module: src/core/index.bend:203
@unsafe
def index_insert(tree, d, hash, mask):
  match tree:
    case KDef{label, kind, arity, templates, typ, value, ctors, native, unsafe}:
      index_insert_legacy(tree, d, hash, mask)
    case KIndexLeaf{stored, bucket}:
      w5_idx_ins_leaf(U32.is_eq(mask, 0), tree, d, hash, mask, bucket)
    case KIndexNode{stored, split, left, right}:
      w5_idx_ins_node(U32.is_eq(split, 0), tree, stored, split, left, right, d, hash, mask)

# Module: src/core/index.bend:224
@unsafe
def w7_br_8(w7_c: Bool, +tree: KDef, +d: KDef, +hash: U32, +mask: U32) -> KDef:
  match w7_c:
    case True{}:
      index_node(da(tree), dx(tree), index_insert(index_child(tree, False{}), d, hash, mask), index_child(tree, True{}))
    case False{}:
      index_node(da(tree), dx(tree), index_child(tree, False{}), index_insert(index_child(tree, True{}), d, hash, mask))

@unsafe
def w7_br_9(w7_c: Bool, +tree: KDef, +d: KDef, +hash: U32, +mask: U32) -> KDef:
  match w7_c:
    case True{}:
      index_leaf(d, hash, dc(tree))
    case False{}:
      w7_br_8(U32.is_eq(U32.and(hash, dx(tree)), 0), tree, d, hash, mask)

@unsafe
def w7_br_10(w7_c: Bool, +tree: KDef, +d: KDef, +hash: U32, +mask: U32) -> KDef:
  match w7_c:
    case True{}:
      index_join(tree, d, hash, mask)
    case False{}:
      w7_br_9(U32.is_eq(dx(tree), 0), tree, d, hash, mask)

@unsafe
def index_insert_legacy(tree, d, hash, mask):
  w7_br_10(Bool.not(U32.is_eq(mask, 0)) && (U32.is_eq(dx(tree), 0) || U32.is_lt(mask, dx(tree))), tree, d, hash, mask)

# Module: src/core/index.bend:239
@unsafe
def w7_ctor_exists_hit(isAbs: Bool, +rest: List<&2, KDef>, +name: String) -> Bool:
  match isAbs:
    case True{}:
      w7_ctor_exists_linear(rest, name)
    case False{}:
      True{}

@unsafe
def w7_ctor_exists_adt(isAdt: Bool, +h: KDef, +rest: List<&2, KDef>, +name: String) -> Bool:
  match isAdt:
    case True{}:
      w7_ctor_exists_hit(p88_string_eq(dk(lookup(dc(h), name)), "Absent"), rest, name)
    case False{}:
      w7_ctor_exists_linear(rest, name)

@unsafe
def w7_ctor_exists_linear(+ds: List<&2, KDef>, +name: String) -> Bool:
  match ds:
    case Nil{}:
      False{}
    case Con{h, rest}:
      w7_ctor_exists_adt(p88_string_eq(dk(h), "ADT"), h, rest, name)

@unsafe
def w7_ctor_exists_tail(+tail: List<&2, KDef>, +rest: List<&2, KDef>, +name: String) -> Bool:
  match tail:
    case Nil{}:
      w7_ctor_exists_linear(rest, name)
    case Con{ctors, _}:
      Bool.not(p88_string_eq(dk(index_find(ctors, name, index_hash(name, 2166136261), 32)), "Absent"))

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
def book_put_many_cache_name(+cache: KDef, +rest: List<&2,KDef>, +name: String) -> Bool:
  w7_br_12(p88_string_eq(name, ""), cache, rest, name)

# Module: src/core/index.bend:461
@unsafe
def book_put_many_cache_valid(+cache: KDef, +rest: List<&2,KDef>, +defs: List<&2,KDef>) -> Bool:
  match defs:
    case Nil{}: True{}
    case Con{d, more}:
      kc(Bool, book_put_many_cache_name(cache, rest, dn(d)),
        u => book_put_many_cache_valid(cache, rest, more), u => False{})

# Module: src/core/index.bend:469
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
def w7_br_23(w7_c: Bool, +book: List<&2, KDef>, +arm: KTerm, +original: KTerm, +raw: KTerm, +x: KTerm, +args: List<&2, KTerm>, +left: U32, +fallback: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      norm_match(book, arm, original, raw, core_literal_step(x), args, left, fallback)
    case False{}:
      w7_br_22(p98_tag_eq(x, "Ctr"), book, arm, original, raw, x, args, left, fallback)

@unsafe
def norm_match(book, arm, original, raw, x, args, left, fallback):
  w7_br_23(core_literal(x), book, arm, original, raw, x, args, left, fallback)

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
def g_wnf(
  +book: List<&2, KDef>,
  +st: GState,
  +t: KTerm,
) -> GResult:
  g_eval(book, st, t, Nil{}, 0, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Nil{})

# Module: src/core/graph.bend:335
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
def w7_br_93(w7_c: Bool, +book: List<&2, KDef>, +st: GState, +arm: KTerm, +original: KTerm, +raw: KTerm, +x: KTerm, +args: List<&2, KTerm>, +pending: U32, +fallback: KTerm, +stack: List<&2, GFrame>) -> GResult:
  match w7_c:
    case True{}:
      g_match(book, st, arm, original, raw, core_literal_step(x), args, pending, fallback, stack)
    case False{}:
      w7_br_92(Bool.not(p98_tag_eq(x, "Ctr")), book, st, arm, original, raw, x, args, pending, fallback, stack)

@unsafe
def g_match(book, st, arm, original, raw, x, args, pending, fallback, stack):
  w7_br_93(core_literal(x), book, st, arm, original, raw, x, args, pending, fallback, stack)

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
def w7_br_94(w7_c: Bool, +book: List<&2, KDef>, +name: String, +d: KDef) -> KDef:
  match w7_c:
    case True{}:
      kr_parent(book, name)
    case False{}:
      d

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
def kp_escape(
  +n: U32,
  +quote: U32,
) -> String:
  w7_br_108(U32.is_eq(n, 10), n, quote)

# Module: src/core/pretty.bend:366
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
def ctx_dead(
  +book: List<&2, KDef>,
  +ctx: List<&2, KTerm>,
) -> Bool:
  match ctx:
    case Nil{}:
      False{}
    case Con{h, t}:
      kc(Bool, U32.is_eq(qt(h), 0), u => ctx_dead(book, t), u => dead_type(book, wnf(book, kid(h, 0))) || ctx_dead(book, t))

# Module: src/check/kernel.bend:821
@unsafe
def dead_type(book, ty):
  p98_tag_eq(ty, "ADT") && p88_string_eq(dk(lookup(book, nm(ty))), "ADT") && defs_empty(remaining(dc(lookup(book, nm(ty))), rm(ty)))

# Module: src/check/kernel.bend:825
@unsafe
def w7_br_180(w7_c: Bool, +e: KEnv, +t: KTerm, +ty: KTerm, +a: KTerm) -> KChecking:
  match w7_c:
    case True{}:
      ok(cw(e), t, ty, Nil{})
    case False{}:
      dg_bad_detail(cw(e), "nonexhaustive match", dg_text("cases for " ++ dg_constructor_names(remaining(dc(lookup(cb(e), nm(a))), rm(a)))), t)

@unsafe
def mat_rest(
  +book: List<&2, KDef>,
  +t: KTerm,
  +a: KTerm,
) -> KTerm:
  w7_br_184(Bool.not(p98_tag_eq(kid(t, 1), "Mat")) && defs_empty(remaining(dc(lookup(book, nm(a))), Con{nm(t), rm(a)})), t)

# Module: src/check/kernel.bend:855
@unsafe
def w7_br_185(w7_c: Bool, +book: List<&2, KDef>, +goal: KTerm, +tel: KTerm, +n: U32, +name: String, +xs: List<&2, KTerm>) -> KTerm:
  match w7_c:
    case True{}:
      subst(kid(goal, 1), ix(goal), kt("Ctr", name, 0, 0, norm_join(xs, Nil{})))
    case False{}:
      mat_goal_head(book, goal, wnf(book, tel), n, name, xs)

@unsafe
def mat_goal(book, goal, tel, n, name, xs):
  w7_br_185(U32.is_eq(n, 0), book, goal, tel, n, name, xs)

# Module: src/check/kernel.bend:859
@unsafe
def mat_goal_head(book, goal, tel, n, name, xs):
  all(kc(U32, U32.is_eq(qt(tel), 0), u => 0, u => kc(U32, U32.is_eq(qt(tel), 1), u => qt(goal), u => qadd(qt(goal), qt(goal)))), nm(tel), ix(tel), kid(tel, 0), mat_goal(book, goal, kid(tel, 1), U32.sub(n, 1), name, norm_join(xs, Con{var(nm(tel), ix(tel)), Nil{}})))

# Module: src/check/kernel.bend:863
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
def tele_quantities(
  +book: List<&2, KDef>,
  +ty: KTerm,
  +n: U32,
) -> List<&2, KTerm>:
  kc(List<&2, KTerm>, U32.is_eq(n, 0), u => Nil{}, u => tele_quantities_head(book, wnf(book, ty), n))

# Module: src/check/kernel.bend:900
@unsafe
def tele_quantities_head(book, ty, n):
  Con{qua(kc(U32, p98_tag_eq(ty, "All"), u => qt(ty), u => 1)), tele_quantities(book, kid(ty, 1), U32.sub(n, 1))}

# Module: src/check/kernel.bend:904
@unsafe
def w7_br_190(w7_c: Bool, +d: KDef, +later: List<&2, KDef>) -> KDef:
  match w7_c:
    case True{}:
      signature_fill_mode(d, lookup(later, dn(d)))
    case False{}:
      d

@unsafe
def signature_mode(
  +d: KDef,
  +later: List<&2, KDef>,
) -> KDef:
  w7_br_190(p88_string_eq(dk(d), "Def") && p98_tag_eq(dv(d), "Absent"), d, later)

# Module: src/check/kernel.bend:941
@unsafe
def tele_tip(
  +book: List<&2, KDef>,
  +t: KTerm,
) -> KTerm:
  tele_tip_head(book, wnf(book, t))

# Module: src/check/kernel.bend:1037
@unsafe
def w7_br_202(w7_c: Bool, +book: List<&2, KDef>, +t: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      tele_tip(book, kid(t, 1))
    case False{}:
      t

@unsafe
def tele_tip_head(book, t):
  w7_br_202(p98_tag_eq(t, "All"), book, t)

# Module: src/check/kernel.bend:1041
@unsafe
def w7_br_220(w7_c: Bool, +world: KWorld, +r: KChecking) -> KChecking:
  match w7_c:
    case True{}:
      KChecking{ct(r), cy(r), cs(r), ce(r), kw_with_book(rw(r), kw_book(world)), rx(r)}
    case False{}:
      r

@unsafe
def kw_restore_definition(+world: KWorld, +d: KDef, +r: KChecking) -> KChecking:
  w7_br_220(good(r) && U32.is_gt(dx(d), 0), world, r)

# Module: src/check/kernel.bend:1252
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
def kw_floor_fresh(+world: KWorld, +fresh: KWorldFresh, +roots: List<&2,KTerm>) -> U32:
  match fresh:
    case KFreshKnown{next}: norm_max_walk(roots, U32.sub(next, 1))
    case KFreshDeferred{saved}: norm_max_walk(roots, norm_max_walk(saved, norm_book_bound(kw_book(world))))

# Module: src/check/kernel.bend:1380
@unsafe
def kw_temp_fresh(+world: KWorld, +fresh: KWorldFresh, +roots: List<&2,KTerm>) -> U32:
  match fresh:
    case KFreshKnown{next}: norm_max_walk(roots, U32.sub(next, 1))
    case KFreshDeferred{saved}: norm_max_walk(roots, norm_book_bound(kw_book(world)))

# Module: src/check/kernel.bend:1394
@unsafe
def env_tele_apply(+t: KTerm, +bindings: List<&2,KTelescopeBinding>) -> KTerm:
  env_subst_apply(t, bindings)

# Module: src/check/env-telescope.bend:38
@unsafe
def w7_br_244(w7_c: Bool, +book: List<&2,KDef>, +tel: KTerm, +h: KTerm, +rest: List<&2,KTerm>) -> KTerm:
  match w7_c:
    case True{}:
      env_tele_fill_eager(book, subst(kid(tel, 1), ix(tel), h), rest)
    case False{}:
      {KTerm{"Error", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}

@unsafe
def env_tele_fill_eager_head(+book: List<&2,KDef>, +tel: KTerm, +h: KTerm, +rest: List<&2,KTerm>) -> KTerm:
  w7_br_244(p98_tag_eq(tel, "All"), book, tel, h, rest)

# Module: src/check/env-telescope.bend:68
@unsafe
def env_tele_fill_eager(book, tel, args):
  match args:
    case Nil{}: tel
    case Con{h, rest}: env_tele_fill_eager_head(book, wnf(book, tel), h, rest)

# Module: src/check/env-telescope.bend:74
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
def sp_keys(ts):
  match ts:
    case Nil{}: ""
    case Con{head, rest}: term_key(head) ++ kc(String, List.is_empty(&2, KTerm, rest), u => "", u => "\n" ++ sp_keys(rest))

# Module: src/check/specialize.bend:142
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
def sp_live_ref(+world: KWorld, +head: KTerm, +name: String, +consumed: U32) -> KChecking:
  KChecking{KTerm{"Ref", name, ix(head), qt(head), ks(head), rm(head), kb(head), ke(head)}, dt(lookup(kw_book(world), name)), Nil{}, "", world, consumed}

# Module: src/check/specialize.bend:367
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
def base_prefix_deltas(defs, raw):
  match defs:
    case Nil{}: Nil{}
    case Con{d, rest}: kc(List<&2,KDef>, prefix_state_exact_def(d, lookup(raw, dn(d))),
      u => base_prefix_deltas(rest, raw), u => Con{d, base_prefix_deltas(rest, raw)})

# Module: src/check/prefix-state.bend:97
@unsafe
def base_prefix_patch(defs, patches):
  match defs:
    case Nil{}: Nil{}
    case Con{d, rest}: Con{kc(KDef, p88_string_eq(dk(lookup(patches, dn(d))), "Absent"), u => d, u => lookup(patches, dn(d))), base_prefix_patch(rest, patches)}

# Module: src/check/prefix-state.bend:103
@unsafe
def base_prefix_closed_terms(+terms: List<&2,KTerm>, +context: List<&2,KDef>) -> Bool:
  match terms:
    case Nil{}: True{}
    case Con{t, rest}: kc(Bool, (Bool.not(p98_tag_eq(t, "Ref") || p98_tag_eq(t, "ADT")) || Bool.not(p88_string_eq(dk(lookup(context, nm(t))), "Absent"))),
      u => base_prefix_closed_terms(norm_join(ks(t), rest), context), u => False{})

# Module: src/check/prefix-state.bend:120
@unsafe
def base_prefix_closed(+defs: List<&2,KDef>, +context: List<&2,KDef>) -> Bool:
  match defs:
    case Nil{}: True{}
    case Con{d, rest}: kc(Bool, base_prefix_closed_terms(Con{dt(d), Con{dv(d), Nil{}}}, context) && base_prefix_closed(dc(d), context), u => base_prefix_closed(rest, context), u => False{})

# Module: src/check/prefix-state.bend:126
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
def w7b_wnf_go(fast: Bool, +book: List<&2, KDef>, +t: KTerm) -> KTerm:
  match fast:
    case True{}: t
    case False{}: wnf(book, t)

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
def f_context_resolve_table(+term: KTerm, +scope: FParseScope, +constructor: Bool) -> KTerm:
  match scope:
    case FParseScope{prior, index, ctorIndex, ns, aliases, view}:
      +name = nm(term)
      +alias = f_alias(name, aliases)
      +near = f_choose(String, p88_string_eq(alias, name), u => f_qual_name(name, ns), u => alias)
      f_choose(KTerm, p88_string_eq(near, name),
        u => kt_span("Ref", name, 0, 1, Nil{}, kb(term), ke(term)),
        u => f_choose(KTerm, f_choose(Bool, p88_string_eq(alias, name), u => False{}, u => f_context_known(alias, scope, constructor) && f_context_known(name, scope, constructor)),
          u => fpe_point_at(k_with_span(term, ke(term), ke(term)), "expected an unambiguous name (an import alias shadows " ++ name ++ ")", "an unambiguous name (the alias " ++ f_import_alias_head(name) ++ " shadows " ++ name ++ ")"),
          u => kt_span("Ref", f_choose(String, f_context_known(near, scope, constructor) || Bool.not(f_context_known(name, scope, constructor)), u => near, u => name), 0, 1, Nil{}, kb(term), ke(term))))

# Sugar uses its file's own spelling, without applying import aliases.
@unsafe
def f_context_own(+name: String, +input: FInput, +constructor: Bool) -> String:
  match input:
    case FInput{tokens,FParseContext{+scope,env,next}}:
      match scope:
        case FParseScope{prior,index,ctorIndex,+ns,aliases,view}:
          +near = f_qual_name(name,ns)
          f_choose(String,p88_string_eq(near,name),u => name,
            u => f_choose(String,f_context_known(near,scope,constructor) || Bool.not(f_context_known(name,scope,constructor)),u => near,u => name))

# Module: src/front/contextual.bend:4
@unsafe
def f_context_resolve(+term: KTerm, +scope: FParseScope) -> KTerm:
  f_context_resolve_table(term, scope, False{})

# Module: src/front/contextual.bend:14

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
def f_context_constructor(+term: KTerm, +input: FInput) -> FParsed:
  match input:
    case FInput{tokens, context}:
      match context:
        case FParseContext{scope, env, next}: f_context_constructor_done(term, input, f_context_resolve_table(k_with_span(term, f_previous_end(input), f_previous_end(input)), scope, True{}))

# Module: src/front/contextual.bend:173
@unsafe
def f_context_flat(+parsed: FParsed, +vars: List<&2,KTerm>) -> FParsed:
  match parsed:
    case FParsed{term, rest}:
      f_choose(FParsed, f_context_stop(term), u => parsed, u => f_context_flat_input(term, f_space(rest), vars))

# Module: src/front/contextual.bend:217
@unsafe
def w7_br_313(w7_c: Bool, +term: KTerm, +syntax: KTerm, +resolved: KTerm, +definition: KDef, +input: FInput) -> FParsed:
  match w7_c:
    case True{}:
      FParsed{resolved, input}
    case False{}:
      w7_br_312(f_eq(tg(syntax), "Var") && Bool.not(f_eq(dk(definition), "ADT")), term, syntax, resolved, definition, input)

@unsafe
def f_context_mark_known(+term: KTerm, +syntax: KTerm, +resolved: KTerm, +definition: KDef, +input: FInput) -> FParsed:
  w7_br_313(f_context_stop(resolved), term, syntax, resolved, definition, input)

# Module: src/front/contextual.bend:531
@unsafe
def f_all_body(name, id, q, exi, a, p):
  match p:
    case FParsed{b, ts}:
      FParsed{f_choose(KTerm, f_context_stop(b), u => b, u => f_choose(KTerm, exi, u => f_app(kt("Ref", f_context_own("Exists", ts, False{}), 0, 1, Nil{}), [a, k_lam(name, id, q, [b], 0, 0, False{})]), u => kt("All", name, id, q, [a, b]))), ts}

# Module: src/front/parser.bend:324
@unsafe
def f_tuple(n, p):
  match p:
    case FParsed{m, ts}:
      FParsed{f_choose(KTerm, f_context_stop(m), u => m, u => kt("Ctr", f_context_own("Tuple", ts, True{}), 0, 1, [n, m])), ts}

# Module: src/front/parser.bend:351
@unsafe
def f_list(
  +p: FParsed,
) -> FParsed:
  match p:
    case FParsed{+n, ts}:
      FParsed{f_choose(KTerm, f_eq(tg(n), "Error"), u => n, u => f_list_nodes(ks(n), f_context_own("Con", ts, True{}), f_context_own("Nil", ts, True{}))), ts}

# Module: src/front/parser.bend:359
@unsafe
def f_equation_type(a, b, neg, opBegin, opEnd, p):
  match p:
    case FParsed{ty, ts}:
      FParsed{f_choose(KTerm, neg, u => kt("All", "_", 0, 1, [kt("Eql", "", 0, 1, [a, b, ty]), kt_span("FGlobal", f_context_own("Empty", ts, False{}), 0, 1, Nil{}, opBegin, opEnd)]), u => kt("Eql", "", 0, 1, [a, b, ty])), ts}

# Module: src/front/parser.bend:389
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
def w7_br_335(w7_c: Bool, +s: String) -> U32:
  match w7_c:
    case True{}:
      3
    case False{}:
      w7_br_334(f_eq(s, "&&"), s)

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
def w7_br_352(w7_c: Bool, +s: String) -> String:
  match w7_c:
    case True{}:
      ".mod"
    case False{}:
      w7_br_351(f_eq(s, "<"), s)

@unsafe
def fpe_message(source, offset, end, error, observed):
  "Error:\n- expected : " ++ nm(kid(error, 0)) ++ "\n- observed : " ++ observed ++ "\nLocation:" ++ fpe_snippet(source, offset, end, error)

# A range is explicit producer data; point diagnostics retain their old path.

# Module: src/front/parser.bend:582
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
def w7_br_443(w7_c: Bool, +s: String) -> FDecoded:
  match w7_c:
    case True{}:
      FDecoded{0, "", "expected character"}
    case False{}:
      w7_br_442(Char.is_eq(f_head(s), '\\'), s)

@unsafe
def f_namespace_operator(head, input):
  f_eq(tg(head), "Ref") && (f_implicit_operator(nm(head)) || f_eq(nm(head), f_context_own("Bool.and", input, False{})) || f_eq(nm(head), f_context_own("Bool.or", input, False{})) || f_eq(nm(head), f_context_own("String.append", input, False{})))

# Module: src/front/literals_arrays.bend:155
@unsafe
def w7_br_469(w7_c: Bool, +n: KTerm, +ty: KTerm, +ts: FInput, +depth: KTerm) -> FParsed:
  match w7_c:
    case True{}:
      FParsed{depth, ts}
    case False{}:
      FParsed{f_scope_apply_span(ref(f_context_own("Array.new", ts, False{})), [ty, depth, n], 0, 0), ts}

@unsafe
def f_context_write(+term: KTerm, +begin: U32, +input: FInput) -> KTerm:
  w7_br_480(f_eq(tg(term), "App") && f_eq(tg(kid(term, 0)), "App") && f_eq(tg(kid(kid(term, 0), 0)), "App") && f_eq(tg(kid(kid(kid(term, 0), 0), 0)), "App") && f_eq(tg(kid(kid(kid(kid(term, 0), 0), 0), 0)), "Ref") && f_eq(nm(kid(kid(kid(kid(term, 0), 0), 0), 0)), f_context_own("Array.set", input, False{})), term, begin)

# Module: src/front/literals_arrays.bend:221
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
def f_fresh_result(
  +r: FResult,
) -> FResult:
  match r:
    case FResult{book, err, imports}:
      f_fresh_result_end(f_fresh_defs(book, 1), err, imports)

# Module: src/front/freshen.bend:53
@unsafe
def f_graph_aliases(imports, source, sources, root):
  match imports:
    case Nil{}:
      Nil{}
    case Con{+im, rest}:
      Con{kt("Import", f_import_namespace_at(im, source, sources, root), 0, 0, ks(im)), f_graph_aliases(rest, source, sources, root)}

# Module: src/load/graph.bend:193
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
def f_fresh_prefix_prepare(+prefix: List<&2,KDef>) -> FFreshPrefixState:
  f_fresh_prefix_prepared(prefix, f_fresh_defs(prefix, 1))

# Module: src/load/prefix.bend:52
@unsafe
def dg_family(
  +book: List<&2, KDef>,
  +name: String,
) -> String:
  match book:
    case Nil{}: ""
    case Con{d, rest}: kc(String, p88_string_eq(dk(d), "ADT") && Bool.not(p88_string_eq(dk(lookup(dc(d), name)), "Absent")), u => dn(d), u => dg_family(rest, name))

# Module: src/diagnostic/trace.bend:74
@unsafe
def dg_datatype_braces(+book: List<&2,KDef>, +name: String) -> String:
  +bare = dg_unqualified_name(name,name)
  +found = kc(String,p88_string_eq(dk(lookup(book,name)),"ADT"),u => name,
    u => kc(String,p88_string_eq(dk(lookup(book,bare)),"ADT"),v => bare,v => ""))
  kc(String,Bool.not(String.is_empty(found)) && String.is_empty(dg_family(book,name)),
    u => "Note: " ++ found ++ " is a datatype: write its arguments as <>",u => "")

@unsafe
def w7_br_546(w7_c: Bool, +e: KEnv, +t: KTerm, +ty: KTerm, +code: String) -> KTerm:
  match w7_c:
    case True{}:
      dg_pair(ty, kc(KTerm, p88_string_eq(dg_family(cb(e), nm(t)), ""), u => dg_text("non-inferrable term"), u => ref(dg_family(cb(e), nm(t)))))
    case False{}:
      kt("DDetail", "", 0, 0, [dg_text(code), {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}])

@unsafe
def w7_br_564(w7_c: Bool, +e: KEnv, +t: KTerm, +ty: KTerm) -> KChecking:
  match w7_c:
    case True{}:
      dg_bad_detail(cw(e), "constructor does not belong to goal or field count differs", dg_text("a declared constructor (" ++ name_key(nm(ty)) ++ " declares " ++ dg_constructor_names(dc(lookup(cb(e), nm(ty)))) ++ ")"), t)
    case False{}:
      dg_bad_detail(cw(e), "constructor does not belong to goal or field count differs", ty, ref(dg_family(cb(e), nm(t))))

@unsafe
def j_type(book, env, t):
  j_type_on(book, env, t, tg(t))

# Module: src/back/common/queries.bend:35
@unsafe
def w7_br_567(w7_c: Bool, +book: List<&2, KDef>, +env: List<&2, KTerm>, +t: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      j_app_type(wnf(book, j_type(book, env, kid(t, 0))), kid(t, 1))
    case False{}:
      {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}

@unsafe
def w7_br_568(w7_c: Bool, +book: List<&2, KDef>, +env: List<&2, KTerm>, +t: KTerm, +key: String) -> KTerm:
  match w7_c:
    case True{}:
      dt(lookup(book, nm(t)))
    case False{}:
      w7_br_567(p88_string_eq(key, "App"), book, env, t)

@unsafe
def w7_br_569(w7_c: Bool, +book: List<&2, KDef>, +env: List<&2, KTerm>, +t: KTerm, +key: String) -> KTerm:
  match w7_c:
    case True{}:
      j_env(env, ix(t))
    case False{}:
      w7_br_568(p88_string_eq(key, "Ref"), book, env, t, key)

@unsafe
def w7_br_570(w7_c: Bool, +book: List<&2, KDef>, +env: List<&2, KTerm>, +t: KTerm, +key: String) -> KTerm:
  match w7_c:
    case True{}:
      kid(t, 1)
    case False{}:
      w7_br_569(p88_string_eq(key, "Var"), book, env, t, key)

@unsafe
def j_type_on(book, env, t, key):
  w7_br_570(p88_string_eq(key, "Ann"), book, env, t, key)

# Module: src/back/common/queries.bend:44
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
def j_specialize(book, tel, args):
  match args:
    case Nil{}:
      tel
    case Con{h, rest}:
      j_specialize(book, j_app_type(wnf(book, tel), h), rest)

# Module: src/back/common/queries.bend:141
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
def jd_domains(+book: List<&2,KDef>, +ty: KTerm) -> U32:
  jd_domains_head(book, wnf(book, ty))

# Module: src/back/common/arity.bend:19
@unsafe
def w7_br_576(w7_c: Bool, +book: List<&2,KDef>, +ty: KTerm) -> U32:
  match w7_c:
    case True{}:
      U32.inc(jd_domains(book, kid(ty, 1)))
    case False{}:
      0

@unsafe
def jd_domains_head(+book: List<&2,KDef>, +ty: KTerm) -> U32:
  w7_br_576(p98_tag_eq(ty, "All"), book, ty)

# Module: src/back/common/arity.bend:23
@unsafe
def w7_br_577(w7_c: Bool, +book: List<&2,KDef>, +t: KTerm, +left: U32) -> U32:
  match w7_c:
    case True{}:
      jd_raise_typed(book, j_strip(t), left, wnf(book, kid(t, 1)))
    case False{}:
      jd_raise_head(book, j_strip(t), left)

@unsafe
def w7_br_578(w7_c: Bool, +book: List<&2,KDef>, +t: KTerm, +left: U32) -> U32:
  match w7_c:
    case True{}:
      w7_br_577(p98_tag_eq(j_strip(t), "Mat"), book, t, left)
    case False{}:
      jd_raise_head(book, j_strip(t), left)

@unsafe
def jd_raise(+book: List<&2,KDef>, +t: KTerm, +left: U32) -> U32:
  w7_br_578(p98_tag_eq(t, "Ann"), book, t, left)

# Checked annotation supplies the matcher owner. Constructor names are unique
# in checked books; unknown/unannotated inputs retain the original global search.

# Module: src/back/common/arity.bend:33
@unsafe
def w7_br_579(w7_c: Bool, +book: List<&2,KDef>, +t: KTerm, +left: U32, +ty: KTerm) -> U32:
  match w7_c:
    case True{}:
      jd_raise_domain(book, t, left, wnf(book, kid(ty, 0)))
    case False{}:
      jd_raise_head(book, t, left)

@unsafe
def jd_raise_typed(+book: List<&2,KDef>, +t: KTerm, +left: U32, +ty: KTerm) -> U32:
  w7_br_579(p98_tag_eq(ty, "All"), book, t, left, ty)

# Module: src/back/common/arity.bend:38
@unsafe
def w7_br_580(w7_c: Bool, +book: List<&2,KDef>, +t: KTerm, +left: U32, +domain: KTerm) -> U32:
  match w7_c:
    case True{}:
      jd_raise_match(book, t, left, j_layout_ctor(book, domain, nm(t)))
    case False{}:
      jd_raise_head(book, t, left)

@unsafe
def jd_raise_domain(+book: List<&2,KDef>, +t: KTerm, +left: U32, +domain: KTerm) -> U32:
  w7_br_580(p98_tag_eq(domain, "ADT"), book, t, left, domain)

# Module: src/back/common/arity.bend:43
@unsafe
def jd_raise_match(+book: List<&2,KDef>, +t: KTerm, +left: U32, +ctor: KDef) -> U32:
  U32.min(jd_raise(book, kid(t, 0), jd_raise_arm(left, da(ctor))),
    jd_raise(book, kid(t, 1), left))

# Module: src/back/common/arity.bend:48
@unsafe
def w7_br_581(w7_c: Bool, +book: List<&2,KDef>, +t: KTerm, +left: U32) -> U32:
  match w7_c:
    case True{}:
      jd_raise(book, kid(t, 0), U32.sub(left, 1))
    case False{}:
      U32.inc(jd_raise(book, kid(t, 0), 0))

@unsafe
def w7_br_583(w7_c: Bool, +book: List<&2,KDef>, +t: KTerm, +left: U32) -> U32:
  match w7_c:
    case True{}:
      jd_raise_match(book, t, left, j_find_ctor(book, nm(t)))
    case False{}:
      w7_br_582(p98_tag_eq(t, "Efq"))

@unsafe
def w7_br_584(w7_c: Bool, +book: List<&2,KDef>, +t: KTerm, +left: U32) -> U32:
  match w7_c:
    case True{}:
      w7_br_581(U32.is_gt(left, 0) && U32.is_lt(left, 2147483648), book, t, left)
    case False{}:
      w7_br_583(p98_tag_eq(t, "Mat"), book, t, left)

@unsafe
def jd_raise_head(+book: List<&2,KDef>, +t: KTerm, +left: U32) -> U32:
  w7_br_584(p98_tag_eq(t, "Lam"), book, t, left)

# Module: src/back/common/arity.bend:57
@unsafe
def w7_br_585(w7_c: Bool, +book: List<&2,KDef>, +ty: KTerm, +left: U32) -> U32:
  match w7_c:
    case True{}:
      0
    case False{}:
      jd_live_arity_head(book, wnf(book, ty), left)

@unsafe
def jd_live_arity(+book: List<&2,KDef>, +ty: KTerm, +left: U32) -> U32:
  w7_br_585(U32.is_eq(left, 0), book, ty, left)

# Module: src/back/common/arity.bend:67
@unsafe
def w7_br_586(w7_c: Bool, +book: List<&2,KDef>, +ty: KTerm, +left: U32) -> U32:
  match w7_c:
    case True{}:
      U32.add(kc(U32, U32.is_eq(qt(ty), 0), u => 0, u => 1), jd_live_arity(book, kid(ty, 1), U32.sub(left, 1)))
    case False{}:
      0

@unsafe
def jd_live_arity_head(+book: List<&2,KDef>, +ty: KTerm, +left: U32) -> U32:
  w7_br_586(p98_tag_eq(ty, "All"), book, ty, left)

# Module: src/back/common/native-facts.bend:6
@unsafe
def j_u32_native_ctor(+book: List<&2,KDef>, +owner: String, +name: String) -> Bool:
  +d = lookup(book, owner)
  +c = lookup(dc(d), name)
  p88_string_eq(dk(d), "ADT") && db(d) && p88_string_eq(dk(c), "Ctr") && db(c)

# Module: src/back/common/native-facts.bend:12
@unsafe
def j_u32_native_book(+book: List<&2,KDef>) -> Bool:
  j_u32_native_ctor(book, "U32", "U32") &&
  j_u32_native_ctor(book, "Word.Nil", "WNil") &&
  j_u32_native_ctor(book, "Word.Con", "WCon") &&
  j_u32_native_ctor(book, "Bool", "False") &&
  j_u32_native_ctor(book, "Bool", "True") &&
  p88_string_eq(dk(lookup(book, "Word")), "Def") && db(lookup(book, "Word"))

# Module: src/back/js/shared-text.bend:7
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
def w7_br_594(w7_c: Bool, +t: KTerm) -> String:
  match w7_c:
    case True{}:
      j_word_text(j_word(j_strip(kid(t, 0)), 0, 0), True{})
    case False{}:
      w7_br_593(p88_string_eq(nm(t), "Chr"), t)

@unsafe
def j_literal_owner(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  +d = lookup(book, nm(ty))
  Bool.not(p98_tag_eq(ty, "ADT") && p88_string_eq(dk(d), "ADT") && Bool.not(db(d)))

# Module: src/back/js/literals.bend:143
@unsafe
def j_literal_provenance(book, ty, literal):
  w7_br_596(j_literal_owner(book, ty), literal)

# Module: src/back/js/validate.bend:6
@unsafe
def w7b_arr_intr_if(isRef: Bool, +book: List<&2, KDef>, +f: KTerm) -> Bool:
  match isRef:
    case True{}:
      +name = nm(f)
      w7b_starts_A(name) && j_layout_array_name(name) && db(lookup(book, name))
    case False{}: False{}

@unsafe
def j_layout_array_intrinsic(book, f):
  w7b_arr_intr_if(p98_tag_eq(f, "Ref"), book, f)

# Module: src/back/js/validate.bend:276
@unsafe
def j_layout_element_open(+book: List<&2,KDef>, +element: KTerm) -> Bool:
  +tag = tg(wnf(book, element))
  Bool.not(p88_string_eq(tag, "ADT") || p88_string_eq(tag, "Eql"))

# Module: src/back/js/validate.bend:295
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
def j_string_owner_header(+book: List<&2,KDef>, +name: String, +count: U32) -> Bool:
  +owner = lookup(book, name)
  +kind = wnf(book, dt(owner))
  p88_string_eq(dk(owner), "ADT") && db(owner) && U32.is_eq(da(owner), 0) && U32.is_eq(dx(owner), 0) &&
    U32.is_eq(j_region_def_count(dc(owner)), count) && p98_tag_eq(kind, "Typ") && U32.is_eq(terms_len(ks(kind)), 1) &&
    p98_tag_eq(kid(kind, 0), "Qua") && U32.is_eq(qt(kid(kind, 0)), 2) && List.is_empty(&2, KTerm, ks(kid(kind, 0)))

# Module: src/back/js/jpure.bend:586
@unsafe
def j_map_cmp_ctor(+book: List<&2,KDef>, +c: KDef, +name: String, +ty: KTerm) -> Bool:
  j_pure_native_ctor(c, name, 0) && j_map_cmp_nominal(ty) && j_map_cmp_nominal(wnf(book, dt(c)))

# Module: src/back/js/jpure.bend:1376
@unsafe
def j_callback_type_domain(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  +h = wnf(book, ty)
  p98_tag_eq(h, "Typ") && p88_string_eq(nm(h), "") && U32.is_eq(ix(h), 0) && U32.is_eq(qt(h), 0) &&
    List.is_empty(&2, String, rm(h)) && U32.is_eq(terms_len(ks(h)), 1) &&
    p98_tag_eq(kid(h, 0), "Qua") && p88_string_eq(nm(kid(h, 0)), "") && U32.is_eq(ix(kid(h, 0)), 0) &&
    U32.is_eq(qt(kid(h, 0)), 1) && List.is_empty(&2, String, rm(kid(h, 0))) && U32.is_eq(terms_len(ks(kid(h, 0))), 0)

# Module: src/back/js/region.bend:1100
@unsafe
def j_fold_root_result(+book: List<&2,KDef>, +ty: KTerm, +left: U32) -> KTerm:
  +head = wnf(book, ty)
  kc(KTerm, U32.is_eq(left, 0), u => head, u => j_fold_root_result(book, kid(head, 1), U32.sub(left, 1)))

# Grounded first-order List; every other instantiation retains generic emission.

# Module: src/back/js/fold.bend:284
@unsafe
def w5c2_ni_from_nat(ok: Bool, +k: String) -> String:
  match ok:
    case True{}: "f32_rewrap((f32)($0))"
    case False{}: ni_template_prior(k)

@unsafe
def ni_template(+k: String) -> String:
  w5c2_ni_from_nat(String.eq(k, "f32_from_nat"), k)

# Module: src/back/native/intrinsic.bend:78
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
def nc_tele_fill(+book: List<&2, KDef>, +tel: KTerm, args: List<&2, KTerm>) -> KTerm:
  match args:
    case Nil{}: tel
    case Con{h, rest}:
      +head = wnf(book, tel)
      nc_tele_fill(book, subst(kid(head, 1), ix(head), h), rest)

# Module: src/back/native/erase.bend:29
@unsafe
def w7_br_637(w7_c: Bool, +book: List<&2, KDef>, +tel: KTerm, +left: U32) -> U32:
  match w7_c:
    case True{}:
      0
    case False{}:
      nc_live_count_head(book, wnf(book, tel), left)

@unsafe
def nc_live_count(+book: List<&2, KDef>, +tel: KTerm, +left: U32) -> U32:
  w7_br_637(U32.is_eq(left, 0), book, tel, left)

# Module: src/back/native/erase.bend:33
@unsafe
def nc_live_count_head(book, head, left):
  U32.add(nt_bool(Bool.not(U32.is_eq(qt(head), 0))), nc_live_count(book, kid(head, 1), U32.sub(left, 1)))

# Module: src/back/native/erase.bend:37
@unsafe
def w7_br_649(w7_c: Bool, +name: String, +ws: List<&2, String>, +n: U32) -> N_Emitted:
  match w7_c:
    case True{}:
      N_Emitted{"", "blk_node(e, " ++ nc_head(ws) ++ ", " ++ nc_head(nc_tail(ws)) ++ ")", n}
    case False{}:
      ne_constructor(name, ws, False{}, n, True{})

@unsafe
def w7_br_657(w7_c: Bool, +book: List<&2, KDef>, +name: String) -> U32:
  match w7_c:
    case True{}:
      0
    case False{}:
      da(nc_find_ctor(book, nc_ctor_display(name)))

@unsafe
def w7_br_658(w7_c: Bool, +book: List<&2, KDef>, +name: String) -> U32:
  match w7_c:
    case True{}:
      1
    case False{}:
      w7_br_657(p88_string_eq(name, "Zero") || p88_string_eq(name, "True") || p88_string_eq(name, "False"), book, name)

@unsafe
def w7_br_661(w7_c: Bool, +name: String, +word: String) -> String:
  match w7_c:
    case True{}:
      "1"
    case False{}:
      w7_br_660(p88_string_eq(name, "ALeaf"), name, word)

@unsafe
def w7_br_662(w7_c: Bool, +name: String, +word: String) -> String:
  match w7_c:
    case True{}:
      "(" ++ word ++ " != 0)"
    case False{}:
      w7_br_661(p88_string_eq(name, "Chr") || p88_string_eq(name, "U32") || p88_string_eq(name, "F32"), name, word)

@unsafe
def w5c2_pn_disp_u(ok: Bool, +c: U32, +k: String) -> String:
  match ok:
    case True{}: w5c2_pn_u_res(w5c2_pn_u1(k), k)
    case False{}: w5c2_pn_disp_f(U32.is_eq(c, 70), c, k)

@unsafe
def nc_primitive_name(+k: String) -> String:
  match k:
    case SNil{}: ""
    case SCon{h, _}:
      +c = Char.to_u32(h)
      w5c2_pn_disp_u(U32.is_eq(c, 85), c, k)

# Module: src/back/native/bridge.bend:510
@unsafe
def w5c2_prim_n(ok: Bool, +c: U32, +k: String) -> Bool:
  match ok:
    case True{}: w5c2_prim_is_nat(k)
    case False{}: w5c2_prim_b(U32.is_eq(c, 98), c, k)

@unsafe
def w5c2_prim_f(ok: Bool, +c: U32, +k: String) -> Bool:
  match ok:
    case True{}: w5c2_prim_is_f32(k)
    case False{}: w5c2_prim_n(U32.is_eq(c, 110), c, k)

@unsafe
def w5c2_arity_f(ok: Bool, +c: U32, +k: String) -> U32:
  match ok:
    case True{}: w5c2_arity_f32(k)
    case False{}: w5c2_arity_n(U32.is_eq(c, 110), c, k)

@unsafe
def w5c2_arity_u(ok: Bool, +c: U32, +k: String) -> U32:
  match ok:
    case True{}: w5c2_arity_u32(k)
    case False{}: w5c2_arity_f(U32.is_eq(c, 102), c, k)

@unsafe
def nd_foreign_arity(+book: List<&2, KDef>, +ty: KTerm, +n: U32) -> U32:
  +tel = wnf(book, ty)
  nt_choose(U32, p98_tag_eq(tel, "All"), u => nd_foreign_arity(book, kid(tel, 1), U32.add(n, nt_bool(Bool.not(U32.is_eq(qt(tel), 0))))), u => n)

# Module: src/back/native/direct.bend:84
@unsafe
def w4c_field_is_nat(+book: List<&2, KDef>, +head: KTerm) -> Bool:
  +owner = lookup(book, "Nat")
  p98_tag_eq(head, "ADT") && p88_string_eq(nm(head), "Nat") && p88_string_eq(dk(owner), "ADT") && db(owner) && U32.is_eq(da(owner), 0) &&
    List.is_empty(&2, String, rm(head)) && List.is_empty(&2, KTerm, ks(head))

@unsafe
def w4c_field_is_w32(+book: List<&2, KDef>, +head: KTerm) -> Bool:
  +owner = lookup(book, nm(head))
  p98_tag_eq(head, "ADT") && p88_string_eq(dk(owner), "ADT") && db(owner) &&
    List.is_empty(&2, String, rm(head)) && List.is_empty(&2, KTerm, ks(head)) &&
    nb_contains(["U32", "F32", "Char", "Bool"], nm(head))

@unsafe
def w7_br_693(w7_c: Bool, +book: List<&2, KDef>, +field: KTerm) -> U32:
  match w7_c:
    case True{}:
      1
    case False{}:
      w7_br_692(w4c_field_is_nat(book, field))

@unsafe
def nq_layout_type(+book: List<&2, KDef>, +ty: KTerm) -> KTerm:
  nq_layout_eval(book, ty, Nil{}, Nil{}, 64)

# Module: src/back/native/product-layout.bend:71
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
def nq_info(+target: NC_Target, +name: String) -> KDef:
  match target:
    case NC_Scheduler{}: missing()
    case NC_Destination{dests, shape, join, owner, params, tail, +signatures}: lookup(signatures, name)

# A virtual bundle has already evaluated fields, each represented by a Var.
# A single-use substitution keeps the existing scalar ownership environment.

# Module: src/back/native/product.bend:101
@unsafe
def nq_ctor_shape(+value: KTerm, +target: NC_Target) -> KTerm:
  +d = nq_info(target, "$constructor." ++ nm(value))
  nt_choose(KTerm, p88_string_eq(dk(d), "NQConstructor") && U32.is_eq(ix(dt(d)), terms_len(ks(value))), u => dt(d), u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})

# Module: src/back/native/product.bend:137
@unsafe
def w7_br_724(w7_c: Bool, +body: KTerm, +word: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      core_apply(core_apply(body, kid(word, 0)), kid(word, 1))
    case False{}:
      core_apply(body, word)

@unsafe
def nw_apply(+body: KTerm, +word: KTerm, +fields: U32) -> KTerm:
  w7_br_724(U32.is_eq(fields, 2), body, word)

# Module: src/back/native/word-pattern.bend:73
@unsafe
def nc_foreign_tel(+book: List<&2, KDef>, +ty: KTerm, +name: String, +args: List<&2, KTerm>, +n: U32) -> KTerm:
  +tel = wnf(book, ty)
  nt_choose(KTerm, p98_tag_eq(tel, "All"),
    u => nt_choose(KTerm, U32.is_eq(qt(tel), 0),
      u => nc_foreign_tel(book, subst(kid(tel, 1), ix(tel), {KTerm{"Typ", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}), name, args, U32.inc(n)),
      u => k_lam("", nc_id(n), 1, [nc_foreign_tel(book, subst(kid(tel, 1), ix(tel), var("", nc_id(n))), name, List.append(&2, KTerm, args, [var("", nc_id(n))]), U32.inc(n))], 0, 0, False{})),
    u => kt("NCtr", name, 0, 0, args))

# Module: src/back/native/book.bend:62
@unsafe
def w7_br_737(w7_c: Bool, +book: List<&2, KDef>, +tel: KTerm, +n: U32) -> KTerm:
  match w7_c:
    case True{}:
      tel
    case False{}:
      nc_skip_tel(book, kid(wnf(book, tel), 1), U32.sub(n, 1))

@unsafe
def nc_skip_tel(+book: List<&2, KDef>, +tel: KTerm, +n: U32) -> KTerm:
  w7_br_737(U32.is_eq(n, 0), book, tel, n)

# Module: src/back/native/book.bend:157
@unsafe
def nc_all_args(+book: List<&2, KDef>, +ty: KTerm) -> U32:
  +tel = wnf(book, ty)
  nt_choose(U32, p98_tag_eq(tel, "All"), u => U32.add(nt_bool(Bool.not(U32.is_eq(qt(tel), 0))), nc_all_args(book, kid(tel, 1))), u => 0)

# Module: src/back/native/book.bend:179
@unsafe
def nc_paths_of(+book: List<&2, KDef>, names: List<&2, String>) -> List<&2, String>:
  match names:
    case Nil{}: Nil{}
    case Con{name, rest}: List.append(&2, String, nc_c_paths(ks(nc_unann(dv(lookup(book, name))))), nc_paths_of(book, rest))

# Selective annotation keeps all original type-level definitions in scope.
# The host asks reach_book for main's closure, annotates it in the original
# context, and replaces only those entries before native emission.

# Module: src/back/native/book.bend:316
@unsafe
def nc_context_defs(book: List<&2, KDef>, +annotated: List<&2, KDef>) -> List<&2, KDef>:
  match book:
    case Nil{}: Nil{}
    case Con{+d, +rest}:
      nt_choose(List<&2, KDef>, p88_string_eq(dk(d), "BookCache"),
        u => nc_context_defs(rest, annotated),
        u => Con{nc_context_pick(d, lookup(annotated, dn(d))), nc_context_defs(rest, annotated)})

# Build an immutable first-match index once for plain annotation lists.
# A cache sentinel anywhere changes lookup semantics, so retain that input.

# Module: src/back/native/book.bend:341
@unsafe
def w7_br_739(w7_c: Bool, +cs: KDef, +name: String, +arity: U32) -> Bool:
  match w7_c:
    case True{}:
      False{}
    case False{}:
      ns_ctor_known(cs, name, arity)

@unsafe
def ns_ctor(+cs: KDef, +name: String, +arity: U32) -> Bool:
  w7_br_739(nb_contains(["Zero", "Succ", "True", "False", "Chr", "U32", "F32", "ALeaf", "ANode", "Emit", "Halt", "Done", "Fail"], name), cs, name, arity)

# Module: src/back/native/static.bend:68
@unsafe
def nol_owner(+book: List<&2, KDef>, +ty: KTerm) -> Bool:
  +d = lookup(book, nm(ty))
  p98_tag_eq(ty, "ADT") && List.is_empty(&2, String, rm(ty)) && p88_string_eq(dk(d), "ADT") && U32.is_eq(dx(d), 0) && U32.is_eq(terms_len(ks(ty)), da(d))

# Read exactly the declared live fields after specializing type parameters.
# All aliases/substitutions retain the existing 64-step/4096-node limits.
# Prior field dependencies and indexed constructor results decline. Unlike
# nq_layout_leaf, a nested Sigma is not rejected for sharing its owner's name.

# Module: src/back/native/observer-layout.bend:33
@unsafe
def no_literal_native(+book: List<&2, KDef>, +kind: String) -> Bool:
  +d = lookup(book, kind)
  p88_string_eq(dk(d), "ADT") && db(d) && U32.is_eq(da(d), 0) && U32.is_eq(dx(d), 0)

# The child is the emitter atom; name is the exact scalar kind and id the U32
# payload. F32 retains its raw bits. Nat literals fit below native NAT_IMM.

# Module: src/back/native/observer-literals.bend:13
@unsafe
def no_literal_typed(+book: List<&2, KDef>, +t: KTerm) -> KTerm:
  w7_br_762(core_literal(t) && nb_contains(["Nat", "U32", "F32"], nm(t)) && no_literal_native(book, nm(t)), t)

# Optional: one structural step only. The caller must re-enter its ordinary
# budgeted evaluator and spend fuel again; never recursively expand here.

# Module: src/back/native/observer-literals.bend:21
@unsafe
def no_literal_string_step(+book: List<&2, KDef>, +t: KTerm) -> KTerm:
  w7_br_763(core_literal(t) && p88_string_eq(nm(t), "String") && no_literal_native(book, "String"), t)

# A virtual constructor would erase nat_chk/term_word demand. Refuse even if
# the value will be discarded later. Source KLiteral is handled above instead.
# Chr is separate: admit only one argument whose exact proven type is U32.

# Module: src/back/native/observer-literals.bend:29
@unsafe
def agy_kr_resolve_cidx(+book: List<&2, KDef>, +cidx: KDef, +name: String, +hash: U32) -> KDef:
  +d = lookup(book, name)
  kc(KDef, p88_string_eq(dk(d), "Absent"),
    u => index_first(dc(index_find(cidx, name, hash, 32))), u => d)

@unsafe
def driver_emit_owned(
  +book: List<&2,KDef>,
) -> String:
  +error = driver_owned_names(driver_owned_candidates(book), ["IO", "Sigma", "String", "Word.Con", "IO.OP", "Result", "Poll", "Maybe", "Bool", "Unit", "Nat", "U32", "F32", "Char", "Array"])
  kc(String, p88_string_eq(error, ""), u => driver_foreign_names(book, book), u => error)

# Native definitions cannot violate the owned-name rule. Filter once instead
# of revisiting the same native prefix for each reserved name. Retain duplicates
# and source order; foreign/constructor policy still receives the original book.

# Module: src/driver/api.bend:86
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
def p88_roots(state: P88State, roles: List<&2,U32>, values: List<&2,P88Node>) -> P88Decoded:
  match roles:
    case Nil{}: p88_roots_done(state,List.reverse(&2,P88Node,values))
    case Con{role,rest}: p88_roots_next(p88_field(state,role),rest,values)

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:300
@unsafe
def p88_roots_next(step: P88Step, roles: List<&2,U32>, values: List<&2,P88Node>) -> P88Decoded:
  match step:
    case P88Step{state,P88Bad{}}: P88DecodeError{"cache root"}
    case P88Step{state,value}: p88_roots(state,roles,Con{value,values})

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:306
@unsafe
def p88_roots_done(state: P88State, values: List<&2,P88Node>) -> P88Decoded:
  match state values:
    case P88State{P88Cursor{SNil{},mode},nodes,strings,made,sn,begin,end} Con{P88Defs{book},Con{P88Checked{checked},Con{P88Fresh{+fresh},Con{P88World{+world},Con{P88Frontend{+ready},Nil{}}}}}}:
      p130m_roots_ready(P88Products{book,fresh,ready,world},fresh,ready,world,p130m_valid(mode))
    case s other: P88DecodeError{"cache roots or trailing data"}

@unsafe
def p205z_guard(+book: List<&2,KDef>, +rep: KTerm, +join: KTerm, +split: KTerm) -> KTerm:
  +base = norm_book_bound(book)
  kc(KTerm,U32.is_lt(base,4294900000),u => p205z_build(base,rep,join,split),u => atom("Absent"))

@unsafe
def w7_br_798(w7_c: Bool, +body: KTerm, +owner: String, +arity: U32, +index: U32) -> Bool:
  match w7_c:
    case True{}:
      p205u_cons(kid(body,1),owner,arity,index) && U32.is_eq(p205u_refs(kid(body,0),owner),0)
    case False{}:
      False{}

@unsafe
def w7_br_799(w7_c: Bool, +body: KTerm, +owner: String, +arity: U32, +index: U32) -> Bool:
  match w7_c:
    case True{}:
      p205u_shape(kid(body,0),owner,arity,U32.inc(index))
    case False{}:
      w7_br_798(p98_tag_eq(body,"Mat") && agy_str_eq(nm(body),"SNil") && U32.is_eq(terms_len(ks(body)),2), body, owner, arity, index)

@unsafe
def p205u_shape(+body: KTerm, +owner: String, +arity: U32, +index: U32) -> Bool:
  w7_br_799(p98_tag_eq(body,"Lam") && U32.is_lt(index,4), body, owner, arity, index)
@unsafe
def w7_br_801(w7_c: Bool, +book: List<&2,KDef>, +t: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      p205u_literal_def(lookup(book,nm(t)))
    case False{}:
      atom("Absent")

@unsafe
def w7_br_802(w7_c: Bool, +book: List<&2,KDef>, +t: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      t
    case False{}:
      w7_br_801(p98_tag_eq(t,"Ref"), book, t)

@unsafe
def p205u_closed_type(+book: List<&2,KDef>, +t: KTerm) -> KTerm:
  +ty = j_strip(t)
  kc(KTerm,(p98_tag_eq(ty,"Ref") || p98_tag_eq(ty,"ADT")) && List.is_empty(&2,KTerm,ks(ty)) &&
    agy_str_eq(dk(lookup(book,nm(ty))),"ADT"),u => ty,u => atom("Absent"))
@unsafe
def p205u_after_args(+book: List<&2,KDef>, +t: KTerm, +count: U32) -> KTerm:
  +ty = j_strip(t)
  kc(KTerm,U32.is_eq(count,0),u => p205u_closed_type(book,ty),u =>
    kc(KTerm,p98_tag_eq(ty,"All"),v => p205u_after_args(book,kid(ty,1),U32.sub(count,1)),v => atom("Absent")))
@unsafe
def w7_br_808(w7_c: Bool, +book: List<&2,KDef>, +t: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      p205u_closed_type(book,dt(lookup(book,nm(t))))
    case False{}:
      atom("Absent")

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
def w7_br_838(w7_c: Bool, +op: String, +a: U32, +b: U32) -> CtfeVal:
  match w7_c:
    case True{}:
      CVU32{U32.or(a, b)}
    case False{}:
      w7_br_837(agy_str_eq(op, "u32_xor"), op, a, b)

@unsafe
def w7_br_856(w7_c: Bool, +op: String, +a: U32, +b: U32) -> CtfeVal:
  match w7_c:
    case True{}:
      CVNat{kc(U32, U32.is_lt(a, b), v => 0, v => U32.sub(a, b))}
    case False{}:
      w7_br_855(agy_str_eq(op, "nat_mul"), op, a, b)

@unsafe
def w7_br_857(w7_c: Bool, +op: String, +a: U32, +b: U32) -> CtfeVal:
  match w7_c:
    case True{}:
      w7_br_845(U32.is_le(a, U32.sub(4294967295, b)), a, b)
    case False{}:
      w7_br_856(agy_str_eq(op, "nat_sub"), op, a, b)

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
def w7_br_866(w7_c: Bool, +op: String, +a: F32, +b: F32) -> CtfeVal:
  match w7_c:
    case True{}:
      CVF32{F32.sub(a, b)}
    case False{}:
      w7_br_865(agy_str_eq(op, "f32_mul"), op, a, b)

@unsafe
def w7_br_879(w7_c: Bool, +owner: String, +v: CtfeVal) -> KTerm:
  match w7_c:
    case True{}:
      ctfe_reify_u32(v)
    case False{}:
      w7_br_878(agy_str_eq(owner, "Nat"), owner, v)

@unsafe
def ctfe_reify(+owner: String, +v: CtfeVal) -> KTerm:
  w7_br_879(agy_str_eq(owner, "U32"), owner, v)

@unsafe
def agy_abs_ctor_arity(+ctx: List<&2,KDef>, +cname: String) -> U32:
  +parent = kr_parent(ctx,cname)
  kc(U32,agy_str_eq(dk(parent),"Absent"),u => 999999,u => agy_abs_ctor_arity_def(lookup(dc(parent),cname)))

@unsafe
def agy_bf_check_right_args(args: List<&2,KTerm>, lams1: List<&2,KTerm>) -> AgyStep:
  match args lams1:
    case Con{ap,Con{ax,arest}} Con{+lp,Con{lx,lrest}}:
      kc(AgyStep,agy_bf_is_var(ap,ix(lp)) && agy_bf_vars_match(arest,lrest),
        u => agy_bf_step_expr(ax,ix(lx),ix(lp)),
        u => AgyStep{0,False{}})
    case _ _: AgyStep{0,False{}}

@unsafe
def agy_bf_check_right(+call: KTerm, +fname: String, +lams1: List<&2,KTerm>) -> AgyStep:
  +c = j_call_spine(call,[])
  kc(AgyStep,p98_tag_eq(c,"Call") && agy_str_eq(nm(c),fname),
    u => agy_bf_check_right_args(ks(c),lams1),
    u => AgyStep{0,False{}})

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
def p205v_result_type(+book: List<&2,KDef>, +t: KTerm) -> Bool:
  +ty = j_strip(t)
  kc(Bool,p98_tag_eq(ty,"All"),u => p205v_result_type(book,kid(ty,1)),u =>
    p205v_closed_ty(book,ty,4))

@unsafe
def p205v_arithmetic(+op: String, +a: U32, +b: U32) -> KTerm:
  w5c3_ar_add(String.eq(op,"u32_add"), op, a, b)

@unsafe
def w5c3_bin_ge(m: Bool, +op: String, +a: U32, +b: U32) -> KTerm:
  match m:
    case True{}: p205v_bool(U32.is_ge(a,b))
    case False{}: p205v_arithmetic(op,a,b)

@unsafe
def w5c3_bin_gt(m: Bool, +op: String, +a: U32, +b: U32) -> KTerm:
  match m:
    case True{}: p205v_bool(U32.is_gt(a,b))
    case False{}: w5c3_bin_ge(String.eq(op,"u32_is_ge"), op, a, b)

@unsafe
def w5c2_rcmp_le(m: Bool, +op: String, +la: U32, +ha: U32, +lb: U32, +hb: U32) -> KTerm:
  match m:
    case True{}: w5c2_rcmp_tf(U32.is_le(ha,lb), U32.is_gt(la,hb))
    case False{}: w5c2_rcmp_lt(String.eq(op,"u32_is_lt"), op, la, ha, lb, hb)

@unsafe
def w5c2_rcmp_ok(ok: Bool, +op: String, +la: U32, +ha: U32, +lb: U32, +hb: U32) -> KTerm:
  match ok:
    case False{}: atom("Absent")
    case True{}: w5c2_rcmp_le(String.eq(op,"u32_is_le"), op, la, ha, lb, hb)

@unsafe
def p205v_after_args(+book: List<&2,KDef>, +t: KTerm, +count: U32) -> KTerm:
  +ty = j_strip(t)
  kc(KTerm,U32.is_eq(count,0),
    u => kc(KTerm,p205v_closed_ty(book,ty,4),v => ty,v => atom("Absent")),
    u => kc(KTerm,p98_tag_eq(ty,"All"),v => p205v_after_args(book,kid(ty,1),U32.sub(count,1)),v => atom("Absent")))

@unsafe
def w2d_fold_scon(+fname: String, +st_ty: KTerm, +nil_br: KTerm, +scon_br: KTerm) -> W2Fold:
  w7_br_918(p98_tag_eq(scon_br,"Mat") && agy_str_eq(nm(scon_br),"Chr") && U32.is_eq(terms_len(ks(scon_br)),2) && p98_tag_eq(kid(scon_br,1),"Efq") && p98_tag_eq(kid(scon_br,0),"Lam") && p98_tag_eq(kid(kid(scon_br,0),0),"Lam"), fname, st_ty, nil_br, scon_br)

@unsafe
def w7_br_919(w7_c: Bool, +fname: String, +st_ty: KTerm, +body: KTerm) -> W2Fold:
  match w7_c:
    case True{}:
      w2d_fold_scon(fname,st_ty,kid(body,0),kid(kid(body,1),0))
    case False{}:
      W2Fold{fname,st_ty,atom("Absent"),atom("Absent"),False{}}

@unsafe
def w2d_check_fold_body(+fname: String, +st_ty: KTerm, +body: KTerm) -> W2Fold:
  w7_br_919(p98_tag_eq(body,"Mat") && agy_str_eq(nm(body),"SNil") && U32.is_eq(terms_len(ks(body)),2) && U32.is_eq(p205u_refs(kid(body,0),fname),0) && p98_tag_eq(kid(body,1),"Mat") && agy_str_eq(nm(kid(body,1)),"SCon") && U32.is_eq(terms_len(ks(kid(body,1))),2) && p98_tag_eq(kid(kid(body,1),1),"Efq"), fname, st_ty, body)

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
def w2d_mat_type(+book: List<&2,KDef>, +m: KTerm, +st_ty: KTerm, +ret_ty: KTerm) -> KTerm:
  +sm = j_strip(m)
  kc(KTerm,p98_tag_eq(sm,"Mat") && U32.is_eq(terms_len(ks(sm)),2),u =>
    w2d_mat_type_go(book,sm,st_ty,ret_ty,
      kc(KTerm,agy_str_eq(nm(sm),"Tuple"),v => st_ty,v => w2d_ctor_owner_ty(book,nm(sm)))),
    u => ret_ty)

@unsafe
def w7_br_928(w7_c: Bool, +book: List<&2,KDef>, +sm: KTerm, +st_ty: KTerm, +ret_ty: KTerm, +dom: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      atom("Absent")
    case False{}:
      all(1,"$w2m",0,dom,w2d_mat_type_cod(book,j_strip(kid(sm,0)),st_ty,ret_ty))

@unsafe
def w2d_mat_type_go(+book: List<&2,KDef>, +sm: KTerm, +st_ty: KTerm, +ret_ty: KTerm, +dom: KTerm) -> KTerm:
  w7_br_928(p98_tag_eq(dom,"Absent"), book, sm, st_ty, ret_ty, dom)

@unsafe
def w7_br_929(w7_c: Bool, +book: List<&2,KDef>, +br: KTerm, +st_ty: KTerm, +ret_ty: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      w2d_mat_type(book,br,st_ty,ret_ty)
    case False{}:
      ret_ty

@unsafe
def w2d_mat_type_cod(+book: List<&2,KDef>, +br: KTerm, +st_ty: KTerm, +ret_ty: KTerm) -> KTerm:
  w7_br_929(p98_tag_eq(br,"Mat"), book, br, st_ty, ret_ty)

@unsafe
def p152c_nullary(+constructors: KDef, +term: KTerm) -> Bool:
  p98_tag_eq(term,"NStatic") && U32.is_eq(qt(term),1) && U32.is_eq(ix(term),0) &&
    List.is_empty(&2,KTerm,ks(term)) && p112s_constructor_ok(constructors,nm(term),0)

@unsafe
def p152c_immediate(+book: List<&2,KDef>, +term: KTerm) -> Bool:
  p98_tag_eq(dt(ns_context(book)),"P112StaticImage") && p152c_nullary(p112s_context_ctors(book),term)

@unsafe
def p152c_pair(+constructors: KDef, +source: KTerm, +prepared: KTerm) -> Bool:
  nt_choose(Bool,p98_tag_eq(prepared,"NStatic"),
    u => p98_tag_eq(source,"Ctr") && agy_str_eq(nm(source),nm(prepared)) &&
      List.is_empty(&2,KTerm,ks(source)) && p152c_nullary(constructors,prepared),
    u => p152c_variant(source,prepared) && agy_str_eq(tg(source),tg(prepared)) &&
      agy_str_eq(nm(source),nm(prepared)) && U32.is_eq(ix(source),ix(prepared)) &&
      U32.is_eq(qt(source),qt(prepared)) && U32.is_eq(kb(source),kb(prepared)) &&
      U32.is_eq(ke(source),ke(prepared)) && p152c_strings(rm(source),rm(prepared)) &&
      p152c_pairs(constructors,ks(source),ks(prepared)))

@unsafe
def p152c_pairs(+constructors: KDef, a: List<&2,KTerm>, b: List<&2,KTerm>) -> Bool:
  match a b:
    case Nil{} Nil{}: True{}
    case Con{x,xs} Con{y,ys}: p152c_pair(constructors,x,y) && p152c_pairs(constructors,xs,ys)
    case _ _: False{}

# Same-name freshly prepared fact with its retained erased source. A bounded
# correspondence check rejects stale substitutions, fields, boxes and scalars.
# Actual factory preparation already blocked effects before producing markers.
@unsafe
def w5c2_opid_fn(ok: Bool, +name: String) -> U32:
  match ok:
    case True{}: 86
    case False{}: p111_op_id_prior(name)

@unsafe
def p111_op_id(+name: String) -> U32:
  w5c2_opid_fn(String.eq(name, "f32_from_nat"), name)

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
def p111v_signature(+symbol: String) -> List<&2,U32>:
  w5c3_sig1(String.eq(symbol,"p111_rt_keep") || String.eq(symbol,"p111_rt_sink") || String.eq(symbol,"p111_rt_tag"), symbol)

@unsafe
def p111v_args(+args: List<&2,N111Arg>, +sig: List<&2,U32>, +live: KDef, +ids: N111Ids) -> Bool:
  match args sig:
    case Nil{} Nil{}: True{}
    case Con{N111Arg{typ,value},rest} Con{width,more}:
      U32.is_eq(p111v_type(typ),width) && p111v_value(value,width,live,ids) && p111v_args(rest,more,live,ids)
    case _ _: False{}

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
def p111v_buffer(+args: List<&2,N111Arg>, +position: U32, +count: U32, +live: KDef) -> Bool:
  U32.is_le(count,255) && U32.is_ge(p111v_capacity(p111v_arg(args,position),live),U32.mul(count,8))

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
def p111q_tables(+program: P111Program, +ids: N111Ids) -> List<&2,P111QData>:
  match program:
    case P111Program{segments,constructors,show,show_names,effects,pure}:
      nt_append(P111QData,[
        P111QData{"p111_segments",8,False{},p111q_segment_table(segments,0,[])},
        P111QData{"p111_fid_arity",1,False{},p111q_segment_table(segments,1,[])},
        P111QData{"p111_fid_flags",1,False{},p111q_segment_table(segments,2,[])},
        P111QData{"p111_fid_results",1,False{},p111q_segment_table(segments,3,[])},
        P111QData{"p111_cid_arity",1,False{},p111q_ctor_table(constructors,False{},[])},
        P111QData{"p111_cid_hot",1,False{},p111q_ctor_table(constructors,True{},[])},
        P111QData{"p111_show_desc",4,False{},p111q_nonempty(p111q_words(show))},
        p111q_descriptor(program,ids)],
        nt_append(P111QData,p111q_strings(p111q_ctor_names(constructors),"p111_cid_names"),
          nt_append(P111QData,p111q_strings(show_names,"p111_show_names"),p111q_strings(effects,"p111_effects"))))


@unsafe
def p112w_ready(+ready: KDef, +name: String) -> Bool:
  agy_str_eq(dk(p111v_get(ready,name)),"P112Worker")


@unsafe
def p112w_public(+body: List<&2,N111Stmt>, +owner: String, +ready: KDef) -> List<&2,P112WorkerStmt>:
  p112w_public_target(body,owner,ready,p112w_target(body))


@unsafe
def p112w_public_target(+body: List<&2,N111Stmt>, +owner: String, +ready: KDef, +target: String) -> List<&2,P112WorkerStmt>:
  +count = da(p111v_get(ready,target))
  nt_choose(List<&2,P112WorkerStmt>,p112w_ready(ready,target) && Bool.not(agy_str_eq(owner,target)) && p112t_tail(body,target,count,0),
    u => p112w_nodes(body,count,P112WorkerCall{target,count}),u => p112w_public_next(body,owner,ready))


@unsafe
def p112w_public_next(body: List<&2,N111Stmt>, +owner: String, +ready: KDef) -> List<&2,P112WorkerStmt>:
  match body:
    case Nil{}: []
    case Con{N111If{condition,yes,no},rest}:
      Con{P112WorkerIf{condition,p112w_public(yes,owner,ready),p112w_public(no,owner,ready)},p112w_public(rest,owner,ready)}
    case Con{stmt,rest}: Con{P112WorkerScalar{stmt},p112w_public(rest,owner,ready)}


@unsafe
def p112s_word(word: P112SWord, +constructors: KDef) -> N111Value:
  match word:
    case P112SRaw{value}: N111Const{value,0}
    case P112SPacked{name,payload}: N111Const{payload,U32.or(16777216,U32.shln(da(p112s_find(constructors,name)),8n))}
    case P112SBox{name,offset}: N111Const{U32.add(51413504,offset),U32.or(33554432,U32.shln(da(p112s_find(constructors,name)),8n))}


@unsafe
def p112s_constructor(+constructors: KDef, +term: KTerm, +image: P112SImage) -> P112STerm:
  nt_choose(P112STerm,agy_str_eq(tg(term),"NWord"),u => P112STerm{term,image},u =>
    nt_choose(P112STerm,ns_ctor(constructors,nm(term),terms_len(ks(term))) && ns_constants(ks(term)),u =>
      nt_choose(P112STerm,ns_packed(term),v => p112s_packed(term,ks(term),image),v => P112STerm{term,image}),
      u => P112STerm{term,image}))


@unsafe
def p112s_constructor_ok(+constructors: KDef, +name: String, +arity: U32) -> Bool:
  +found = p112s_find(constructors,name)
  agy_str_eq(dk(found),"P112StaticCtor") && U32.is_lt(da(found),65536) && U32.is_eq(dx(found),arity) && p112s_immutable_name(name)


@unsafe
def p112s_word_valid(word: P112SWord, +constructors: KDef, +nodes: KDef) -> Bool:
  match word:
    case P112SRaw{value}: True{}
    case P112SPacked{+name,+payload}:
      +found = p112s_find(constructors,name)
      p112s_constructor_ok(constructors,name,dx(found)) &&
        ((U32.is_eq(dx(found),0) && U32.is_eq(payload,0)) || (U32.is_eq(dx(found),1) && String.starts_with(name,"$ctor.")))
    case P112SBox{+name,+offset}:
      +found = p112s_find(nodes,U32.show(offset))
      agy_str_eq(dk(found),"P112StaticNode") && agy_str_eq(tg(dt(found)),name) &&
        U32.is_gt(dx(found),0) && p112s_constructor_ok(constructors,name,dx(found))


@unsafe
def p112s_fields_valid(fields: List<&2,P112SWord>, +constructors: KDef, +nodes: KDef) -> Bool:
  match fields:
    case Nil{}: True{}
    case Con{head,rest}: p112s_word_valid(head,constructors,nodes) && p112s_fields_valid(rest,constructors,nodes)


@unsafe
def p112s_value(+book: List<&2,KDef>, +term: KTerm) -> P111ValueCode:
  +word = p112s_term_word(term)
  +constructors = p112s_context_ctors(book)
  +valid = agy_str_eq(tg(dt(ns_context(book))),"P112StaticImage") && agy_str_eq(tg(term),"NStatic") &&
    List.is_empty(&2,KTerm,ks(term)) && U32.is_le(qt(term),1) && p112s_word_valid(word,constructors,p112s_context_nodes(book))
  nt_choose(P111ValueCode,valid,u => P111ValueCode{[],p112s_word(word,constructors),""},
    u => P111ValueCode{[],N111Const{0,0},"static word outside its fresh validated image"})


@unsafe
def p112s_image_fields(fields: List<&2,P112SWord>, +constructors: KDef, acc: List<&2,P111QDatum>) -> List<&2,P111QDatum>:
  match fields:
    case Nil{}: acc
    case Con{head,rest}: p112s_image_fields(rest,constructors,Con{p112s_datum(p112s_word(head,constructors)),acc})


@unsafe
def p112s_image_items(nodes: List<&2,P112SNode>, +constructors: KDef, acc: List<&2,P111QDatum>) -> List<&2,P111QDatum>:
  match nodes:
    case Nil{}: nt_reverse(P111QDatum,acc,[])
    case Con{P112SNode{offset,name,fields},rest}:
      p112s_image_items(rest,constructors,p112s_image_fields(fields,constructors,acc))

# ABI11101 has 24 eight-byte descriptor slots. Only static_words (slot8,
# byte64) and static_image (slot19,byte152) differ from the selected descriptor.


@unsafe
def w5c2_p112f_state(is_st: Bool, +prefix: String, +name: String) -> String:
  match is_st:
    case True{}: name
    case False{}: w5c2_p112f_p113i(String.starts_with(prefix, "p113i_") && String.starts_with(name, "p113i_"), prefix, name)

@unsafe
def p112f_name(+prefix: String, +name: String) -> String:
  w5c2_p112f_state(String.eq(name, "state"), prefix, name)


@unsafe
def p112f_cont_body(body: List<&2,N111Stmt>, +count: U32) -> Maybe<&2,P112FusionCont>:
  match body:
    case Con{N111Alloca{+name,2048,8},+rest}:
      nt_choose(Maybe<&2,P112FusionCont>,agy_str_eq(name,"scratch"),u =>
        nt_choose(Maybe<&2,P112FusionCont>,U32.is_eq(count,0),v => p112f_cont_gets(rest,0,0,[],""),v => p112f_cont_pop(rest,count)),u => None{})
    case _: None{}


@unsafe
def p112f_cont(segment: N111Segment, +count: U32) -> Maybe<&2,P112FusionCont>:
  match segment:
    case N111Segment{+name,+arity,+result,+incoming,+flags,+body}:
      nt_choose(Maybe<&2,P112FusionCont>,U32.is_eq(arity,U32.inc(count)) && U32.is_eq(result,1) && U32.is_eq(incoming,1) && U32.is_eq(flags,0) && p112f_clean(body),
        u => p112f_cont_body(body,count),u => None{})


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
def p112r_scalar(+stmt: N111Stmt, +symbols: KDef, +sites: U32) -> Bool:
  match stmt:
    case N111Call{+name,N111U64{},+symbol,+args}:
      (p112t_runtime_call(symbol) && p112r_runtime_args(args,sites)) || p112r_private_call(stmt,symbols)
    case N111Load{+name,N111U64{},N111Local{+base},+offset}: p112r_buffer(base,sites)
    case N111Store{N111U64{},N111Local{+base},+offset,+value}: p112r_buffer(base,sites)
    case N111Alloca{+name,2048,8}: Bool.not(agy_str_eq(name,"scratch")) && p112r_buffer(name,sites)
    case _: p112t_scalar_safe(stmt)


@unsafe
def p113d_ready(+index: KDef, +name: String) -> Bool:
  agy_str_eq(dk(p111v_get(index,name)),"P113Direct")


@unsafe
def p113d_deps(calls: List<&2,String>, +index: KDef) -> Bool:
  match calls:
    case Nil{}: True{}
    case Con{head,rest}: p113d_ready(index,head) && p113d_deps(rest,index)

@unsafe
def w6_p113d_deps_self(calls: List<&2,String>, +index: KDef, +owner: String) -> Bool:
  match calls:
    case Nil{}: True{}
    case Con{+head,rest}: (agy_str_eq(head,owner) || p113d_ready(index,head)) && w6_p113d_deps_self(rest,index,owner)


@unsafe
def p113e_values(values: List<&2,N111Value>, +live: KDef, +ids: N111Ids) -> Bool:
  match values:
    case Nil{}: True{}
    case Con{head,rest}: p111v_value(head,2,live,ids) && p113e_values(rest,live,ids)


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
def p113a_scan_step(body: List<&2,P113DStmt>, +n: U32, +heap_min: U32) -> P113ABody:
  match body:
    case Nil{}: P113ABody{[],n}
    case Con{P113DScalar{+stmt},+rest}:
      nt_choose(P113ABody,U32.is_gt(p113a_stmt_id(stmt),0),
        u => p113a_prefix(p113d_scalars(p113a_template(stmt,n,heap_min)),p113a_scan(rest,U32.inc(n),heap_min)),
        u => p113a_prefix([P113DScalar{stmt}],p113a_scan(rest,n,heap_min)))
    case Con{P113DIf{condition,yes,no},rest}:
      p113a_scan_yes(condition,no,rest,heap_min,p113a_scan(yes,n,heap_min))
    case Con{head,rest}: p113a_prefix([head],p113a_scan(rest,n,heap_min))


@unsafe
def p113a_scan_sunk(sunk: P113ASunk, body: List<&2,P113DStmt>, +n: U32, +heap_min: U32) -> P113ABody:
  match sunk:
    case P113ASunkYes{stmt,id,pre,v0,v1,v2,rest}:
      p113a_prefix(nt_append(P113DStmt,pre,p113d_scalars(p113a_template_sunk(stmt,n,heap_min,v0,v1,v2))),
        p113a_scan(rest,U32.inc(n),heap_min))
    case P113ASunkNo{}: p113a_scan_step(body,n,heap_min)


@unsafe
def p113a_scan(+body: List<&2,P113DStmt>, +n: U32, +heap_min: U32) -> P113ABody:
  p113a_scan_sunk(p113a_match_sunk(body),body,n,heap_min)


@unsafe
def p113a_scan_yes(condition: N111Value, no: List<&2,P113DStmt>, rest: List<&2,P113DStmt>, +heap_min: U32, yes: P113ABody) -> P113ABody:
  match yes:
    case P113ABody{body,next}: p113a_scan_no(condition,body,rest,heap_min,p113a_scan(no,next,heap_min))


@unsafe
def p113a_scan_no(condition: N111Value, yes: List<&2,P113DStmt>, rest: List<&2,P113DStmt>, +heap_min: U32, no: P113ABody) -> P113ABody:
  match no:
    case P113ABody{body,next}: p113a_prefix([P113DIf{condition,yes,body}],p113a_scan(rest,next,heap_min))


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
def p113k_value(value: N111Value, +facts: KDef) -> P113KFact:
  match value:
    case N111Const{lo,hi}: p113k_exact(lo,hi)
    case N111Local{name}: p113k_get(facts,name)
    case _: p113k_bound(64)


@unsafe
def w5c2_join_fact_if(same: Bool, +lb: U32, +ll: U32, +lh: U32, +rb: U32, +rl: U32, +rh: U32) -> P113KFact:
  match same:
    case True{}: p113k_exact(ll, lh)
    case False{}: P113KFact{U32.max(lb, rb), False{}, U32.and(ll, rl), U32.and(lh, rh)}

@unsafe
def w5c2_p113k_limit_if(exact: Bool, +bits: U32, +lo: U32, +nhi: U32, +width: U32) -> P113KFact:
  match exact:
    case True{}: p113k_exact(lo, nhi)
    case False{}: P113KFact{U32.min(bits, width), False{}, lo, nhi}

@unsafe
def p113k_shift(+left: P113KFact, +amount: U32, +right: Bool) -> P113KFact:
  match left:
    case P113KFact{+bits,+exact,+lo,+hi}:
      nt_choose(P113KFact,U32.is_eq(amount,0),u => left,u =>
      nt_choose(P113KFact,exact,
        u =>
      nt_choose(P113KFact,U32.is_lt(amount,32),
        u => nt_choose(P113KFact,right,
          v => p113k_exact(U32.or(U32.shrn(lo,U32.to_nat(amount)),U32.shln(hi,U32.to_nat(U32.sub(32,amount)))),U32.shrn(hi,U32.to_nat(amount))),
          v => p113k_exact(U32.shln(lo,U32.to_nat(amount)),U32.or(U32.shln(hi,U32.to_nat(amount)),U32.shrn(lo,U32.to_nat(U32.sub(32,amount)))))),
        u => nt_choose(P113KFact,right,
          v => p113k_exact(U32.shrn(hi,U32.to_nat(U32.sub(amount,32))),0),
          v => p113k_exact(0,U32.shln(lo,U32.to_nat(U32.sub(amount,32)))))),u => p113k_bound(nt_choose(U32,right,v => nt_choose(U32,U32.is_ge(amount,bits),w => 0,w => U32.sub(bits,amount)),v => U32.min(64,U32.add(bits,amount))))))


@unsafe
def p113k_unsigned(+op: String, +equal: Bool, +less: Bool) -> P113KFact:
  nt_choose(P113KFact,agy_str_eq(op,"eq"),u => p113k_exact(Bool.to_u32(equal),0),u =>
  nt_choose(P113KFact,agy_str_eq(op,"ne"),u => p113k_exact(Bool.to_u32(Bool.not(equal)),0),u =>
  nt_choose(P113KFact,agy_str_eq(op,"ult"),u => p113k_exact(Bool.to_u32(less),0),u =>
  nt_choose(P113KFact,agy_str_eq(op,"ule"),u => p113k_exact(Bool.to_u32(less || equal),0),u =>
  nt_choose(P113KFact,agy_str_eq(op,"ugt"),u => p113k_exact(Bool.to_u32(Bool.not(less || equal)),0),u =>
  nt_choose(P113KFact,agy_str_eq(op,"uge"),u => p113k_exact(Bool.to_u32(Bool.not(less)),0),u => p113k_bound(1)))))))


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
def p113k_bin_stmt(+name: String, +typ: N111Type, +op: String, +left: N111Value, +right: N111Value, +lf: P113KFact, +rf: P113KFact, answer: P113KFact) -> N111Stmt:
  match answer:
    case P113KFact{_, exact, +lo, +hi}:
      w5c2_bs_1(exact, lo, hi, name, typ, op, left, right, lf, rf)


@unsafe
def w4g_ic_has(+m: KDef, +n: String) -> Bool:
  U32.is_gt(da(p111v_get(m,n)),0)


@unsafe
def w4g_ic_nonlast_ok(body: List<&2,P113DStmt>, +dst: String, +subj: String, +facts: KDef, +otherR: KDef, +otherW: KDef) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{_,Nil{}}: True{}
    case Con{P113DScalar{N111Set{+n,_,_}},rest}:
      Bool.not(agy_str_eq(n,dst)) && Bool.not(agy_str_eq(n,subj)) &&
        agy_str_eq(dk(p111v_get(facts,n)),"Absent") &&
        Bool.not(w4g_ic_has(otherR,n)) && Bool.not(w4g_ic_has(otherW,n)) &&
        w4g_ic_nonlast_ok(rest,dst,subj,facts,otherR,otherW)
    case Con{P113DScalar{N111Bin{+n,_,_,_,_}},rest}:
      Bool.not(agy_str_eq(n,dst)) && Bool.not(agy_str_eq(n,subj)) &&
        agy_str_eq(dk(p111v_get(facts,n)),"Absent") &&
        Bool.not(w4g_ic_has(otherR,n)) && Bool.not(w4g_ic_has(otherW,n)) &&
        w4g_ic_nonlast_ok(rest,dst,subj,facts,otherR,otherW)
    case _: False{}


@unsafe
def w4k_is_used(+used: KDef, +name: String) -> Bool:
  agy_str_eq(dk(p111v_get(used,name)),"W4KUsed")


@unsafe
def w4k_dce_scalars(body: List<&2,N111Stmt>, +used: KDef) -> List<&2,N111Stmt>:
  match body:
    case Nil{}: []
    case Con{N111Set{+name,typ,v},+rest}:
      nt_choose(List<&2,N111Stmt>,w4k_is_used(used,name),
        u => Con{N111Set{name,typ,v},w4k_dce_scalars(rest,used)},
        u => w4k_dce_scalars(rest,used))
    case Con{N111Bin{+name,typ,+op,l,r},+rest}:
      nt_choose(List<&2,N111Stmt>,w4k_is_used(used,name) || Bool.not(w4k_pure_bin(op)),
        u => Con{N111Bin{name,typ,op,l,r},w4k_dce_scalars(rest,used)},
        u => w4k_dce_scalars(rest,used))
    case Con{N111If{cond,yes,no},rest}:
      Con{N111If{cond,w4k_dce_scalars(yes,used),w4k_dce_scalars(no,used)},w4k_dce_scalars(rest,used)}
    case Con{s,rest}: Con{s,w4k_dce_scalars(rest,used)}


@unsafe
def w4k_dce_body(body: List<&2,P113DStmt>, +used: KDef) -> List<&2,P113DStmt>:
  match body:
    case Nil{}: []
    case Con{P113DScalar{N111Set{+name,typ,v}},+rest}:
      nt_choose(List<&2,P113DStmt>,w4k_is_used(used,name),
        u => Con{P113DScalar{N111Set{name,typ,v}},w4k_dce_body(rest,used)},
        u => w4k_dce_body(rest,used))
    case Con{P113DScalar{N111Bin{+name,typ,+op,l,r}},+rest}:
      nt_choose(List<&2,P113DStmt>,w4k_is_used(used,name) || Bool.not(w4k_pure_bin(op)),
        u => Con{P113DScalar{N111Bin{name,typ,op,l,r}},w4k_dce_body(rest,used)},
        u => w4k_dce_body(rest,used))
    case Con{P113DScalar{N111If{cond,yes,no}},rest}:
      Con{P113DScalar{N111If{cond,w4k_dce_scalars(yes,used),w4k_dce_scalars(no,used)}},w4k_dce_body(rest,used)}
    case Con{P113DIf{cond,yes,no},rest}:
      Con{P113DIf{cond,w4k_dce_body(yes,used),w4k_dce_body(no,used)},w4k_dce_body(rest,used)}
    case Con{s,rest}: Con{s,w4k_dce_body(rest,used)}


@unsafe
def w4g_ver(+vers: KDef, +name: String) -> U32:
  da(p111v_get(vers,name))


@unsafe
def w4g_resolve(+env: W4GCopyEnv, +name: String) -> String:
  match env:
    case W4GCopyEnv{+vers,+aliases}:
      +entry = p111v_get(aliases,name)
      nt_choose(String,agy_str_eq(dk(entry),"W4GAlias"),
        u =>
          +src = nm(dv(entry))
          nt_choose(String,U32.is_eq(da(entry),w4g_ver(vers,src)),v => src,v => name),
        u => name)


@unsafe
def w4g_live_has(+live: KDef, +name: String) -> Bool:
  U32.is_gt(da(p111v_get(live,name)),0)


@unsafe
def w4g_arm_nonlast_ok(body: List<&2,P113DStmt>, +dst: String, +forbidden: KDef) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{_,Nil{}}: True{}
    case Con{P113DScalar{N111Set{+n,_,_}},rest}:
      Bool.not(agy_str_eq(n,dst)) && Bool.not(w4g_live_has(forbidden,n)) && w4g_arm_nonlast_ok(rest,dst,forbidden)
    case Con{P113DScalar{N111Bin{+n,_,_,_,_}},rest}:
      Bool.not(agy_str_eq(n,dst)) && Bool.not(w4g_live_has(forbidden,n)) && w4g_arm_nonlast_ok(rest,dst,forbidden)
    case _: False{}


@unsafe
def w4g_cond_not_written(cond: N111Value, +writes: KDef) -> Bool:
  match cond:
    case N111Local{n}: Bool.not(w4g_live_has(writes,n))
    case _: True{}


@unsafe
def w4k_add_exact(+ll: U32, +lh: U32, +rl: U32, +rh: U32, +width: U32) -> P113KFact:
  +s_lo = U32.add(ll,rl)
  nt_choose(P113KFact,U32.is_eq(width,32),
    u => p113k_exact(s_lo,0),
    u => p113k_exact(s_lo,U32.add(U32.add(lh,rh),Bool.to_u32(U32.is_lt(s_lo,ll)))))


@unsafe
def w4k_sub_exact(+ll: U32, +lh: U32, +rl: U32, +rh: U32, +width: U32) -> P113KFact:
  +d_lo = U32.sub(ll,rl)
  nt_choose(P113KFact,U32.is_eq(width,32),
    u => p113k_exact(d_lo,0),
    u => p113k_exact(d_lo,U32.sub(U32.sub(lh,rh),Bool.to_u32(U32.is_lt(ll,rl)))))


@unsafe
def w4k_mul_exact(+ll: U32, +lh: U32, +rl: U32, +rh: U32, +width: U32, +lb: U32, +rb: U32) -> P113KFact:
  nt_choose(P113KFact,U32.is_eq(width,32),
    u => p113k_exact(U32.mul(ll,rl),0),
    u => nt_choose(P113KFact,U32.is_eq(lh,0) && U32.is_eq(rh,0) && U32.is_le(ll,65535) && U32.is_le(rl,65535),
      v => p113k_exact(U32.mul(ll,rl),0),
      v => p113k_bound(U32.min(width,U32.add(lb,rb)))))


@unsafe
def p113l_version(+facts: KDef, +name: String) -> U32:
  ix(dt(p111v_get(facts, name)))

@unsafe
def w5c2_p113l_rel_check(found: KDef, +facts: KDef, +name: String) -> KDef:
  match found:
    case KDef{_, kind, _, _, ftyp, fval, _, _, _}:
      w5c2_p113l_rel_ok(
        String.eq(kind, "P113LRelation") &&
        U32.is_eq(ix(ftyp), p113l_version(facts, nm(fval))) &&
        U32.is_eq(qt(ftyp), p113l_version(facts, name)), found)
    case _: missing()

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
def p117h_value(value: N111Value, +facts: KDef) -> U32:
  match value:
    case N111Local{name}: p117h_get(facts,name)
    case _: 0


@unsafe
def p117h_load(+base: N111Value, +offset: U32, +slots: KDef) -> U32:
  +key = p117h_slot(base,offset)
  nt_choose(U32,agy_str_eq(key,""),u => 0,u => p117h_get(slots,key))


@unsafe
def p117h_backedge(values: List<&2,N111Value>, +facts: KDef, +origin: U32, +count: U32) -> U32:
  match values:
    case Nil{}: nt_choose(U32,U32.is_eq(origin,U32.inc(count)),u => 65535,u => 0)
    case Con{value,rest}:
      U32.and(p117h_backedge(rest,facts,U32.inc(origin),count),
        nt_choose(U32,U32.is_eq(p117h_value(value,facts),origin),u => 65535,
          u => U32.xor(65535,p117h_bit(origin))))


@unsafe
def p117h_rewrite_step(body: List<&2,P113DStmt>, +n: U32, +heap_min: U32, +used: U32, +sites: KDef) -> P113ABody:
  match body:
    case Nil{}: P113ABody{[],n}
    case Con{P113DScalar{+stmt},+rest}:
      +origin = p117h_get(sites,U32.show(n))
      nt_choose(P113ABody,U32.is_eq(p113a_stmt_id(stmt),0),
        u => p113a_prefix([P113DScalar{stmt}],p117h_rewrite(rest,n,heap_min,used,sites)),u =>
        p113a_prefix(p113d_scalars(nt_choose(List<&2,N111Stmt>,U32.is_eq(U32.and(used,p117h_bit(origin)),0),
          v => p113a_template(stmt,n,heap_min),v => p117h_template(stmt,n,origin))),
          p117h_rewrite(rest,U32.inc(n),heap_min,used,sites)))
    case Con{P113DIf{condition,yes,no},rest}:
      p117h_rewrite_yes(condition,no,rest,heap_min,used,sites,p117h_rewrite(yes,n,heap_min,used,sites))
    case Con{head,rest}: p113a_prefix([head],p117h_rewrite(rest,n,heap_min,used,sites))


@unsafe
def p117h_rewrite_sunk(sunk: P113ASunk, body: List<&2,P113DStmt>, +n: U32, +heap_min: U32, +used: U32, +sites: KDef) -> P113ABody:
  match sunk:
    case P113ASunkYes{stmt,id,pre,v0,v1,v2,rest}:
      +origin = p117h_get(sites,U32.show(n))
      p113a_prefix(nt_append(P113DStmt,pre,p113d_scalars(
        nt_choose(List<&2,N111Stmt>,U32.is_eq(U32.and(used,p117h_bit(origin)),0),
          v => p113a_template_sunk(stmt,n,heap_min,v0,v1,v2),
          v => p117h_template_sunk(stmt,n,origin,v0,v1,v2)))),
        p117h_rewrite(rest,U32.inc(n),heap_min,used,sites))
    case P113ASunkNo{}: p117h_rewrite_step(body,n,heap_min,used,sites)


@unsafe
def p117h_rewrite(+body: List<&2,P113DStmt>, +n: U32, +heap_min: U32, +used: U32, +sites: KDef) -> P113ABody:
  p117h_rewrite_sunk(p113a_match_sunk(body),body,n,heap_min,used,sites)


@unsafe
def p117h_rewrite_yes(condition: N111Value, no: List<&2,P113DStmt>, rest: List<&2,P113DStmt>, +heap_min: U32, +used: U32, +sites: KDef, yes: P113ABody) -> P113ABody:
  match yes:
    case P113ABody{body,next}: p117h_rewrite_no(condition,body,rest,heap_min,used,sites,p117h_rewrite(no,next,heap_min,used,sites))


@unsafe
def p117h_rewrite_no(condition: N111Value, yes: List<&2,P113DStmt>, rest: List<&2,P113DStmt>, +heap_min: U32, +used: U32, +sites: KDef, no: P113ABody) -> P113ABody:
  match no:
    case P113ABody{body,next}: p113a_prefix([P113DIf{condition,yes,body}],p117h_rewrite(rest,next,heap_min,used,sites))

@unsafe
def p117v_all(+sites: KDef, +count: U32, +used: U32, +index: U32) -> Bool:
  nt_choose(Bool,U32.is_eq(index,count),u => True{},u =>
    U32.is_gt(U32.and(used,p117h_bit(p117h_get(sites,U32.show(index)))),0) && p117v_all(sites,count,used,U32.inc(index)))


@unsafe
def p117v_address_pick(+id: U32, +n: U32, +origin: U32, +nomask: KDef) -> List<&2,N111Stmt>:
  nt_choose(List<&2,N111Stmt>,U32.is_eq(p117h_get(nomask,U32.show(n)),1),
    u => p117v_address_nomask(id,n,origin),
    u => p117h_address(id,n,origin))

@unsafe
def p117v_template_ex(+original: N111Stmt, +n: U32, +origin: U32, +nomask: KDef) -> List<&2,N111Stmt>:
  match original:
    case N111Call{destination,N111U64{},symbol,+args}:
      +id = p113a_call_id(symbol,args)
      nt_append(N111Stmt,p113a_inputs(id,p111v_arg(args,2),n),
        nt_choose(List<&2,N111Stmt>,U32.is_eq(id,75),
          u => p113a_pair_store(destination,p111v_arg(args,4),p117h_ref(origin,"size"),n),
          u => nt_append(N111Stmt,p117v_address_pick(id,n,origin,nomask),p113a_success(id,destination,p111v_arg(args,4),n))))
    case _: [original]

@unsafe
def p117v_template_sunk_ex(+original: N111Stmt, +n: U32, +origin: U32, +v0: N111Value, +v1: N111Value, +v2: N111Value, +nomask: KDef) -> List<&2,N111Stmt>:
  match original:
    case N111Call{destination,N111U64{},symbol,+args}:
      +id = p113a_call_id(symbol,args)
      nt_append(N111Stmt,p113a_sunk_sets(id,n,v0,v1,v2),
        nt_choose(List<&2,N111Stmt>,U32.is_eq(id,75),
          u => p113a_pair_store(destination,p111v_arg(args,4),p117h_ref(origin,"size"),n),
          u => nt_append(N111Stmt,p117v_address_pick(id,n,origin,nomask),p113a_success(id,destination,p111v_arg(args,4),n))))
    case _: [original]

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
def w4c_val_bm_opt(mv: Maybe<&2,N111Value>, +env: KDef) -> Maybe<&2,U32>:
  match mv:
    case Some{v}: w4c_val_bm_env(v,env)
    case None{}: None{}

# Flow-sensitive check for countdown param `pidx`: every P113DAgain is under `pidx != 0` and passes `DEC(pidx)`.
@unsafe
def p118b_project_borrow(+name: String, +typ: N111Type, +args: List<&2,N111Arg>, +ids: N111Ids) -> P113DCode:
  +ctor = p111v_target(p111v_arg(args,3),ids,True{})
  +count = p111v_literal(p111v_arg(args,4))
  +ok = p118b_arg_types(args,[3,2,3,1,1]) && U32.is_eq(p111v_type(typ),2) &&
    Bool.not(agy_str_eq(dk(ctor),"Absent")) && U32.is_eq(da(ctor),count) &&
    U32.is_ge(count,2) && U32.is_le(count,16)
  +projected : N111Stmt = N111Call{name,typ,"p111_rt_take",[
    p111_state(),p111_word(p111v_arg(args,1)),N111Arg{N111Ptr{},p111v_arg(args,2)},p111_u32(count)]}
  nt_choose(P113DCode,ok && p111v_state_argument(args),
    u => P113DCode{[P113DScalar{projected}],0,"",[]},
    u => p113d_fail("borrowed import: constructor/count contract",0))


@unsafe
def p118b_without(functions: List<&2,P113DFunction>, replaced: KDef) -> List<&2,P113DFunction>:
  p118ns_without(functions,replaced,[])

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
def p123p_get(+facts: KDef, +name: String) -> KDef:
  +found = p111v_get(facts,"@p123predicate:" ++ name)
  nt_choose(KDef,agy_str_eq(dk(found),"P123Predicate"),u =>
    nt_choose(KDef,U32.is_eq(ix(dt(found)),p113l_version(facts,nm(dv(found)))) &&
      U32.is_eq(qt(dt(found)),p113l_version(facts,name)),v => found,v => missing()),u => missing())


@unsafe
def p124r_legacy(+ready: KDef, +name: String) -> P124Callable:
  +count = da(p111v_get(ready,name))
  nt_choose(P124Callable,p112w_ready(ready,name) && U32.is_le(count,8),
    u => P124Callable{True{},count,p112w_symbol(name)},u => P124Callable{False{},0,""})


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


law p126sc_partner:
  for +calls: List<&2,String>
  for +left: P113DFunction
  for +index: P113ITable
  for +counts: KDef
  for +slot: U32
  for +done: KDef
  Maybe<&2,P113DFunction>

@unsafe
def p126sc_partner(calls,left,index,counts,slot,done):
  match calls:
    case Nil{}: None{}
    case Con{+name,rest}: p126sc_partner_next(rest,left,index,counts,slot,done,p126sc_partner_try(left,counts,slot,done,p113i_get(index,name,index_hash(name,2166136261),0)))


@unsafe
def p126sc_partner_next(+calls: List<&2,String>, +left: P113DFunction, +index: P113ITable, +counts: KDef, +slot: U32, +done: KDef, found: Maybe<&2,P113DFunction>) -> Maybe<&2,P113DFunction>:
  match found:
    case None{}: p126sc_partner(calls,left,index,counts,slot,done)
    case Some{right}: Some{right}


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
def p128bi_function(function: P113DFunction, index: KDef) -> P113DFunction:
  match function:
    case P113DFunction{name,params,result,public,body}: P113DFunction{name,params,result,public,p128bi_body(body,index)}


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
def w5c2_orig_set_if(is_abs: Bool, +tree: KDef, +d: KDef, +hash: U32) -> KDef:
  match is_abs:
    case True{}: index_leaf(d, hash, Nil{})
    case False{}: index_insert(tree, d, hash, index_split_bit(U32.xor(hash, da(index_tip(tree, hash)))))

@unsafe
def p131rg_symbol_available(book: List<&2,KDef>) -> Bool:
  agy_str_eq(dk(lookup(book,p131rg_opaque())),"Absent")


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
def p144o_query(+book: List<&2,KDef>, facts: P144OFacts, +name: String) -> Bool:
  match facts:
    case P144OFacts{+names,valid}:
      nt_choose(Bool,valid,u => nb_contains(names,name),u => p144o_original(book,name))


@unsafe
def p144o_owned_term(+book: List<&2,KDef>, +query: String, term: KTerm) -> Bool:
  match term:
    case KTerm{tag,name,id,version,kids,names,begin,end}:
      nt_choose(Bool,p88_string_eq(tag,"P144Ownership") && p88_string_eq(name,"") &&
        U32.is_eq(id,0) && U32.is_eq(version,1) && List.is_empty(&2,KTerm,kids) &&
        U32.is_eq(begin,0) && U32.is_eq(end,0),
        u => nb_contains(names,query),u => p144o_original(book,query))
    case _: p144o_original(book,query)

@unsafe
def w7c_w6_alias_k(isK: Bool, +alias: KDef, +name: String) -> String:
  match isK:
    case False{}: name
    case True{}:
      +e = p111v_get(alias,name)
      w7c_w6_alias_hit(agy_str_eq(dk(e),"Absent"),e,name)

@unsafe
def w6_alias(+alias: KDef, +name: String) -> String:
  w7c_w6_alias_k(String.starts_with(name,"$p111.k."),alias,name)

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

@unsafe
def w4p_to_candidates(fns: List<&2,P113DFunction>, +ready: KDef, +signatures: List<&2,KDef>, +prodIdx: KDef) -> List<&2,P113DCandidate>:
  match fns:
    case Nil{}: []
    case Con{+fn,+rest}:
      match fn:
        case P113DFunction{+name,params,result,public,body}:
          nt_choose(List<&2,P113DCandidate>,p113d_ready(ready,name),
            u => w4p_to_candidates(rest,ready,signatures,prodIdx),
            u => Con{w4p_cand_of(w4p_try_wrap(fn,signatures,prodIdx)),w4p_to_candidates(rest,ready,signatures,prodIdx)})

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
def w7_pre_nodes(+book: List<&2,KDef>, xs: List<&2,String>, +remSet: KDef, +acc: List<&2,W7PreNode>) -> List<&2,W7PreNode>:
  match xs:
    case Nil{}: nt_reverse(W7PreNode,acc,[])
    case Con{+name,+rest}:
      nt_choose(List<&2,W7PreNode>,U32.is_gt(da(p111v_get(remSet,name)),0),
        u => w7_pre_nodes(book,rest,remSet,Con{W7PreNode{name,w7_pre_term(dv(lookup(book,name)),name,remSet,[])},acc}),
        u => w7_pre_nodes(book,rest,remSet,acc))

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
def p168j_eligible(segment: N111Segment, +direct: KDef) -> Bool:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,body}:
      nt_choose(Bool,p169q_metadata(arity,result,incoming,flags),
        u => p169q_import(name,arity,direct),u => False{})



@unsafe
def p168j_candidates(segments: List<&2,N111Segment>, +imports: KDef,
    +acc: List<&2,P112MultiCandidate>) -> List<&2,P112MultiCandidate>:
  match segments:
    case Nil{}: nt_reverse(P112MultiCandidate,acc,[])
    case Con{+segment,+rest}:
      match segment:
        case N111Segment{+name,arity,result,incoming,flags,body}:
          nt_choose(List<&2,P112MultiCandidate>,p169q_metadata(arity,result,incoming,flags),
            u => nt_choose(List<&2,P112MultiCandidate>,p112w_ready(imports,name),
              v => p168j_candidates(rest,imports,acc),
              v => nt_choose(List<&2,P112MultiCandidate>,p112c_candidate(segment),
                w => p168j_candidates(rest,imports,Con{P112MultiCandidate{segment},acc}),
                w => p168j_candidates(rest,imports,acc))),
            u => p168j_candidates(rest,imports,acc))



@unsafe
def p168j_forward_if(function: P113DFunction, ready: KDef) -> String:
  match function:
    case P113DFunction{+name,+params,result,public,body}:
      +entry = p111v_get(ready,name)
      nt_choose(String,agy_str_eq(dk(entry),"P112Worker") && U32.is_eq(dx(entry),0),
        u => p168j_forward(name,nt_count(NC_Binding,params)),u => "")



@unsafe
def p168j_forwards(functions: List<&2,P113DFunction>, +ready: KDef,
    acc: List<&2,String>) -> List<&2,String>:
  match functions:
    case Nil{}: nt_reverse(String,acc,[])
    case Con{head,rest}: p168j_forwards(rest,ready,Con{p168j_forward_if(head,ready),acc})


# Exact Phase168 import-seeded emission preparation, with text left in the
# maintained cursor until IO consumes it. This record is not a certificate:
# normal entry constructs it only after both unchanged actual-program gates.
@unsafe
def p169q_import(+name: String, +arity: U32, direct: KDef) -> Bool:
  +function = p111v_get(direct,name)
  agy_str_eq(dk(function),"P113Direct") && U32.is_eq(da(function),arity) &&
    U32.is_eq(dx(function),1) && U32.is_eq(ix(dv(function)),1)



@unsafe
def p169a_namespace(+original: P111Program, +nodes: List<&2,P112SNode>,
    +view: List<&2,P113DFunction>, +certificate: P113ACertificate) -> String:
  +direct : P113DProgram = P113DProgram{P112StaticProgram{original,nodes},view}
  p114t_verify_done(P113AProgram{direct,certificate},p113a_verify_after(direct,certificate,""))



# The certificate is constructed by unchanged p169a_view from this exact
# request. scalar=False implies p118c_plan's ns_definitions permission=False;
# skip only that redundant failed derivation. unshared is not cold authority.
@unsafe
def p185cc_expand(+stmt: N111Stmt, +ids: N111Ids, +site: U32) -> P114TExpansion:
  match stmt:
    case N111Call{+dest,N111U64{},+symbol,
      Con{N111Arg{N111Ptr{},N111Local{+state}},
      Con{N111Arg{N111U32{},N111CtorId{+ctor}},
      Con{N111Arg{N111Ptr{},N111Local{+buffer}},
      Con{N111Arg{N111U32{},N111Const{+count,+high}},Nil{}}}}}}:
        nt_choose(P114TExpansion,agy_str_eq(symbol,"p111_rt_ctor") && agy_str_eq(state,"state") &&
          U32.is_eq(high,0) && U32.is_ge(count,1) && U32.is_le(count,4) &&
          p114t_buffer(buffer) && p185cc_known(ctor,count,ids) && U32.is_le(site,4294967200),
          u => P114TExpansion{p185cb_construct(stmt,dest,ctor,buffer,count,ids,site),True{}},
          u => P114TExpansion{[stmt],False{}})
    case _: P114TExpansion{[stmt],False{}}
# Ordinary match lowering already supplies the checked constructor identity
# and its field count. Unlike a late runtime-call recognizer, this factory has
# the expected CID; the unchanged verifier resolves its N111CtorId. Neither
# a source constructor spelling nor a tag alone is sufficient to take a word.
# The same structured IR reaches both QBE and direct x86.

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
def p185cb_bucket(bucket: List<&2,KDef>, +ready: Bool, +metadata: KDef) -> List<&2,KDef>:
  match bucket:
    case Nil{}: []
    case Con{head,rest}: Con{p185cb_tree(head,ready,metadata),p185cb_bucket(rest,ready,metadata)}

@unsafe
def p185cb_tree(+tree: KDef, +ready: Bool, +metadata: KDef) -> KDef:
  match tree:
    case KIndexLeaf{hash,bucket}: KIndexLeaf{hash,p185cb_bucket(bucket,ready,metadata)}
    case KIndexNode{hash,mask,left,right}: KIndexNode{hash,mask,p185cb_tree(left,ready,metadata),p185cb_tree(right,ready,metadata)}
    case KDef{name,+kind,cid,arity,typ,value,children,native,unsafe}:
      nt_choose(KDef,agy_str_eq(kind,"N111Id"),u => p185cb_entry(tree,ready,metadata),
        u => KDef{name,kind,cid,arity,typ,value,p185cb_bucket(children,ready,metadata),native,unsafe})

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
def w11_p186ch_take_r2(+stmt: N111Stmt, +dest: String, a0: N111Arg, a1: N111Arg, r2: List<&2,N111Arg>) -> P114TExpansion:
  match r2:
    case Con{a2,r3}: w11_p186ch_take_r3(stmt,dest,a0,a1,a2,r3)
    case _: P114TExpansion{[stmt],False{}}

@unsafe
def w11_p186ch_ctor_r1(+stmt: N111Stmt, +dest: String, a0: N111Arg, r1: List<&2,N111Arg>) -> P114TExpansion:
  match r1:
    case Con{a1,r2}: w11_p186ch_ctor_r2(stmt,dest,a0,a1,r2)
    case _: P114TExpansion{[stmt],False{}}

@unsafe
def w11_p186ch_ctor(+stmt: N111Stmt, +dest: String, args: List<&2,N111Arg>) -> P114TExpansion:
  match args:
    case Con{a0,r1}: w11_p186ch_ctor_r1(stmt,dest,a0,r1)
    case _: P114TExpansion{[stmt],False{}}

@unsafe
def x188_render(code: X188Seq) -> String:
  x188_render_go([code],[])

law x181_load:
  for +value: N111Value
  for +ids: N111Ids
  for +frame: X181Frame
  for +reg: X187Operand
  X188Seq
law x181_epilogue:
  for +frame: X181Frame
  X188Seq

@unsafe
def w4_u32_to_r10(source: Maybe<&2,X187Operand>, value: N111Value, ids: N111Ids, frame: X181Frame) -> X188Seq:
  match source:
    case Some{operand}: x188_i2("movd",operand,x188_reg(10,32))
    case None{}: x188_cat(x181_load(value,ids,frame,x188_reg(10,64)),x188_i2("movl",x188_reg(10,32),x188_reg(10,32)))

@unsafe
def x192_float_conversion_buffer(name: String, id: U32, buffer: String,
    ids: N111Ids, +frame: X181Frame) -> X188Seq:
  x188_many([x181_load(N111Local{buffer},ids,frame,x188_reg(10,64)),
    x188_i2("movd",X187Mem{10,0},x188_xmm(0)),
    x192_float_conversion_core(id),x181_store(name,frame,x188_reg(10,64))])

# CVTTSS2SI r64,xmm/m32: F3 REX.W 0F 2C /r. Reject every wrong width/class;
# ordinary/indexed/RIP memory forms share the existing checked ModRM encoder.
@unsafe
def x186_float_home(name: String, frame: X181Frame, stack: Bool) -> Maybe<&2,X187Operand>:
  match frame:
    case X181Frame{slots,bytes,calls,params,symbol}:
      +slot = p111v_get(slots,name)
      nt_choose(Maybe<&2,X187Operand>,(agy_str_eq(dk(slot),"X181Register") || agy_str_eq(dk(slot),"X185Transient")) && U32.is_lt(da(slot),5),
        u => x186_float_narrow(x185_physical_slot(slot)),u =>
        nt_choose(Maybe<&2,X187Operand>,stack && agy_str_eq(dk(slot),"X181Stack") && U32.is_eq(dx(slot),8) &&
            U32.is_ge(da(slot),48) && U32.is_le(da(slot),bytes) && U32.is_eq(U32.mod(da(slot),8),0),
          v => Some{X187Mem{5,U32.sub(0,da(slot))}},v => None{}))

@unsafe
def x186_float_source(value: N111Value, frame: X181Frame) -> Maybe<&2,X187Operand>:
  match value:
    case N111Local{name}: x186_float_home(name,frame,True{})
    case _: None{}

@unsafe
def w2_float_const_load(value: N111Value, ids: N111Ids, frame: X181Frame, +xmm: X187Operand) -> X188Seq:
  match value:
    case N111Const{+lo,0}:
      nt_choose(X188Seq,U32.is_eq(lo,0),u => x188_i2("pxor",xmm,xmm),
        u => x188_cat(x188_i2("movl",X187Imm{lo,0},x188_reg(10,32)),x188_i2("movd",x188_reg(10,32),xmm)))
    case _: x188_cat(x181_load(value,ids,frame,x188_reg(10,64)),x188_i2("movd",x188_reg(10,32),xmm))

@unsafe
def x186_float_publish_to(home: Maybe<&2,X187Operand>, name: String,
    source: X187Operand, frame: X181Frame) -> X188Seq:
  match home:
    case Some{X187Mem{base,disp}}: x188_i2("movq",source,X187Mem{base,disp})
    case Some{operand}: x188_i2("movd",source,operand)
    case None{}: x188_cat(x188_i2("movd",source,x188_reg(10,32)),x181_store(name,frame,x188_reg(10,64)))

@unsafe
def x186_float_publish(+name: String, source: X187Operand, +frame: X181Frame) -> X188Seq:
  x186_float_publish_to(x186_float_home(name,frame,True{}),name,source,frame)

def agy_ctor_cid(ctor: String, ids: N111Ids) -> U32:
  match ids:
    case N111Ids{functions,ctors}: da(p111v_get(ctors,ctor))

@unsafe
def agy_frame_ctor_ok(frame: X181Frame) -> Bool:
  match frame:
    case X181Frame{slots,bytes,calls,params,symbol}:
      U32.is_eq(da(p111v_get(slots,"__agy_ctor_ok")),1)

law agy_reuse_find:
  for +cls: U32
  for +rname: String
  for +ids: N111Ids
  for stmts: List<&2,P113DStmt>
  AgyReuseMatch

@unsafe
def agy_reuse_find_if(+cls: U32, +rname: String, +ids: N111Ids, +cond: N111Value,
    +yes: List<&2,P113DStmt>, +no: List<&2,P113DStmt>, +rest: List<&2,P113DStmt>,
    m1: AgyReuseMatch, m2: AgyReuseMatch) -> AgyReuseMatch:
  match m1 m2:
    case AgyReuseMatch{ok1,+c1,yes2} AgyReuseMatch{ok2,+c2,no2}:
      +chosen = agy_reuse_ctor_pick(c1,c2)
      nt_choose(AgyReuseMatch,ok1 && ok2 && agy_reuse_ctor_compat(c1,c2),
        u => AgyReuseMatch{True{},chosen,Con{P113DIf{cond,yes2,no2},rest}},
        u => nt_choose(AgyReuseMatch,agy_reuse_pure_stmts(yes) && agy_reuse_pure_stmts(no),
          v => agy_reuse_prepend(P113DIf{cond,yes,no},agy_reuse_find(cls,rname,ids,rest)),
          v => AgyReuseMatch{False{},"",Con{P113DIf{cond,yes,no},rest}}))

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
def agy_reuse_find_call(+cls: U32, +rname: String, +ids: N111Ids, +cname: String,
    +typ: N111Type, +sym: String, +args: List<&2,N111Arg>, +rest: List<&2,P113DStmt>) -> AgyReuseMatch:
  nt_choose(AgyReuseMatch,agy_str_eq(sym,"p111_rt_fail") || (agy_str_eq(sym,"p111_rt_sink") && agy_reuse_is_abort(rest)),
    u => AgyReuseMatch{True{},"",Con{P113DScalar{N111Call{cname,typ,sym,args}},rest}},
    u => agy_reuse_find_ctor(cls,rname,ids,cname,typ,sym,args,rest))

@unsafe
def agy_reuse_find(cls,rname,ids,stmts):
  match stmts:
    case Nil{}: AgyReuseMatch{False{},"",[]}
    case Con{+head,+rest}:
      match head:
        case P113DScalar{N111Call{cname,typ,sym,args}}:
          agy_reuse_find_call(cls,rname,ids,cname,typ,sym,args,rest)
        case P113DScalar{other}:
          nt_choose(AgyReuseMatch,agy_reuse_pure_nstmt(other),
            u => agy_reuse_prepend(head,agy_reuse_find(cls,rname,ids,rest)),
            u => AgyReuseMatch{False{},"",stmts})
        case P113DIf{cond,yes,no}:
          agy_reuse_find_if(cls,rname,ids,cond,yes,no,rest,
            agy_reuse_find(cls,rname,ids,yes),agy_reuse_find(cls,rname,ids,no))
        case _: AgyReuseMatch{False{},"",stmts}

@unsafe
def x186_call_value(value: N111Value, +slots: KDef, +bytes: U32) -> U32:
  match value:
    case N111Local{name}: x186_call_slot(p111v_get(slots,name),bytes)
    case _: 1

@unsafe
def x186_call_scan(args: List<&2,N111Arg>, +slots: KDef, +bytes: U32,
    +count: U32, +kind: U32) -> X186CallPlan:
  match args:
    case Nil{}: X186CallPlan{kind,count}
    case Con{N111Arg{typ,value},rest}:
      +value_kind = x186_call_value(value,slots,bytes)
      nt_choose(X186CallPlan,U32.is_ge(count,512),u => X186CallPlan{0,513},u =>
        nt_choose(X186CallPlan,U32.is_eq(value_kind,0),v => X186CallPlan{0,0},v =>
          x186_call_scan(rest,slots,bytes,U32.inc(count),U32.max(kind,value_kind))))

@unsafe
def x186_call_direct(args: List<&2,N111Arg>, +ids: N111Ids, +frame: X181Frame, +index: U32) -> X188Seq:
  match args:
    case Nil{}: X188Empty{}
    case Con{N111Arg{+typ,+value},rest}:
      x188_cat(nt_choose(X188Seq,U32.is_lt(index,6),
        u => x188_cat(x181_load(value,ids,frame,x181_argreg(index)),x186_call_mask(typ,x186_call_reg32(index))),
        u => x188_many([x181_load(value,ids,frame,x188_reg(10,64)),x186_call_mask(typ,x188_reg(10,32)),
          x188_i2("movq",x188_reg(10,64),X187Mem{4,U32.mul(U32.sub(index,6),8)})])),
        x186_call_direct(rest,ids,frame,U32.inc(index)))

@unsafe
def x186_call_snapshot(args: List<&2,N111Arg>, +ids: N111Ids, +frame: X181Frame,
    +base: U32, +index: U32) -> X188Seq:
  match args:
    case Nil{}: X188Empty{}
    case Con{N111Arg{typ,value},rest}:
      x188_many([x181_load(value,ids,frame,x188_reg(10,64)),x186_call_mask(typ,x188_reg(10,32)),
        x188_i2("movq",x188_reg(10,64),X187Mem{4,U32.add(base,U32.mul(index,8))}),
        x186_call_snapshot(rest,ids,frame,base,U32.inc(index))])

@unsafe
def agy_call_src_reg(value: N111Value, slots: KDef) -> U32:
  match value:
    case N111Local{name}:
      +slot = p111v_get(slots,name)
      nt_choose(U32,agy_str_eq(dk(slot),"X185Transient") && U32.is_lt(da(slot),5),
        u => agy_call_treg(da(slot)),u => 0)
    case _: 0

@unsafe
def agy_call_stack_args(args: List<&2,N111Arg>, +ids: N111Ids, +frame: X181Frame, +index: U32) -> X188Seq:
  match args:
    case Nil{}: X188Empty{}
    case Con{N111Arg{typ,value},rest}:
      x188_cat(nt_choose(X188Seq,U32.is_ge(index,6),
        u => x188_many([x181_load(value,ids,frame,x188_reg(10,64)),x186_call_mask(typ,x188_reg(10,32)),
          x188_i2("movq",x188_reg(10,64),X187Mem{4,U32.mul(U32.sub(index,6),8)})]),
        u => X188Empty{}),
        agy_call_stack_args(rest,ids,frame,U32.inc(index)))

law agy_call_reg_moves:
  for args: List<&2,N111Arg>
  for +slots: KDef
  for +index: U32
  List<&2,AgyCallMove>

@unsafe
def agy_call_reg_move_one(+index: U32, +typ: N111Type, +value: N111Value,
    +rest: List<&2,N111Arg>, +slots: KDef) -> List<&2,AgyCallMove>:
  +dst = agy_call_phys_reg(index)
  +src = agy_call_src_reg(value,slots)
  nt_choose(List<&2,AgyCallMove>,U32.is_eq(src,dst) && Bool.not(U32.is_eq(p111v_type(typ),1)),
    v => agy_call_reg_moves(rest,slots,U32.inc(index)),
    v => Con{AgyCallMove{index,dst,src,typ,value},agy_call_reg_moves(rest,slots,U32.inc(index))})

@unsafe
def agy_call_reg_moves(args,slots,index):
  match args:
    case Nil{}: []
    case Con{N111Arg{typ,value},rest}:
      nt_choose(List<&2,AgyCallMove>,U32.is_ge(index,6),u => [],
        u => agy_call_reg_move_one(index,typ,value,rest,slots))

@unsafe
def agy_call_emit_move(m: AgyCallMove, +ids: N111Ids, +frame: X181Frame) -> X188Seq:
  match m:
    case AgyCallMove{+dstIdx,+dstReg,+srcReg,+typ,value}:
      nt_choose(X188Seq,U32.is_eq(srcReg,10),
        u => x188_cat(x188_i2("movq",x188_reg(10,64),x181_argreg(dstIdx)),x186_call_mask(typ,x186_call_reg32(dstIdx))),
        u => nt_choose(X188Seq,U32.is_eq(srcReg,dstReg),
          v => x186_call_mask(typ,x186_call_reg32(dstIdx)),
          v => x188_cat(x181_load(value,ids,frame,x181_argreg(dstIdx)),x186_call_mask(typ,x186_call_reg32(dstIdx)))))

@unsafe
def x181_function_id(ids: N111Ids, name: String, reg: X187Operand) -> X188Seq:
  match ids:
    case N111Ids{functions,constructors}: x188_id_load(functions,name,reg)

@unsafe
def x181_constructor_id(ids: N111Ids, name: String, reg: X187Operand) -> X188Seq:
  match ids:
    case N111Ids{functions,constructors}: x188_id_load(constructors,name,reg)

@unsafe
def x181_load(value,ids,frame,reg):
  match value:
    case N111Local{name}: x181_local_load(name,frame,reg)
    case N111Const{lo,hi}: x188_i2("movabsq",X187Imm{lo,hi},reg)
    case N111Symbol{name}: x188_i2("leaq",X187Rip{name,0,0},reg)
    case N111FuncId{name}: x181_function_id(ids,name,reg)
    case N111CtorId{name}: x181_constructor_id(ids,name,reg)

@unsafe
def x181_address(base: N111Value, +offset: U32, ids: N111Ids, frame: X181Frame) -> X188Seq:
  x188_cat(x181_load(base,ids,frame,x188_reg(10,64)),nt_choose(X188Seq,U32.is_eq(offset,0),u => X188Empty{},u =>
    x188_many([x188_i2("movabsq",X187Imm{offset,0},x188_reg(11,64)),x188_i2("addq",x188_reg(11,64),x188_reg(10,64))])))

@unsafe
def x185_late_previous(+stmt: N111Stmt, +ids: N111Ids, +site: U32, expansion: P114TExpansion) -> List<&2,N111Stmt>:
  match expansion:
    case P114TExpansion{body,+changed}:
      nt_choose(List<&2,N111Stmt>,changed,u => x185_late_accessors(body),
        u => x185_late_constructor(stmt,ids,site,
          nt_choose(P114TExpansion,x185_ctor_enabled(),
            v => p185cc_expand(stmt,ids,site),v => P114TExpansion{[stmt],False{}})))

@unsafe
def x185_late_constructor(+stmt: N111Stmt, ids: N111Ids, site: U32, expansion: P114TExpansion) -> List<&2,N111Stmt>:
  match expansion:
    case P114TExpansion{body,+changed}:
      nt_choose(List<&2,N111Stmt>,changed,u => x185_late_accessors(body),
        u => x185_late_transport(p114t_expand(p118q_sized(stmt),ids,site)))

@unsafe
def w4_bf_mask_for(+stmt: N111Stmt, +rest: List<&2,P113DStmt>, +ids: N111Ids, +site: U32) -> U32:
  w4_bf_mask_read(rest,p128bf_match(stmt,ids,site))

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
def x185_copy_value(value: N111Value, aliases: KDef) -> N111Value:
  match value:
    case N111Local{name}: N111Local{x185_copy_name(name,aliases)}
    case _: value

@unsafe
def x185_physical_home(name: String, frame: X181Frame) -> X185Physical:
  match frame:
    case X181Frame{slots,bytes,calls,params,symbol}: x185_physical_slot(p111v_get(slots,name))

@unsafe
def x185_physical_source(value: N111Value, frame: X181Frame, reg: X187Operand) -> Bool:
  match value:
    case N111Local{name}: x185_physical_same(x185_physical_home(name,frame),reg)
    case _: False{}

@unsafe
def x190_value_home(value: N111Value, frame: X181Frame) -> X185Physical:
  match value:
    case N111Local{name}: x185_physical_home(name,frame)
    case _: X185PhysicalNone{}

# A direct right operand survives the left move only when its home differs
# from the destination, or when that move is itself absent. Shifts keep r11/rcx.
@unsafe
def x185_sf_cell(+buffer: String, +offset: U32, +typ: N111Type, buffers: KDef) -> Bool:
  +entry = p111v_get(buffers,buffer)
  agy_str_eq(dk(entry),"X185ScratchBuffer") && U32.is_le(x185_sf_width(typ),da(entry)) &&
    U32.is_le(offset,U32.sub(da(entry),x185_sf_width(typ)))

@unsafe
def x185_sf_scalar(+stmt: N111Stmt, +buffers: KDef, +facts: List<&2,X185ScratchCell>) -> X185ScratchStep:
  match stmt:
    case N111Store{+typ,N111Local{+buffer},+offset,value}:
      X185ScratchStep{P113DScalar{stmt},nt_choose(List<&2,X185ScratchCell>,x185_sf_cell(buffer,offset,typ,buffers),
        u => x185_sf_insert(X185ScratchCell{buffer,offset,typ,value},x185_sf_overlap(facts,buffer,offset,typ)),u => [])}
    case N111Store{typ,base,offset,value}: X185ScratchStep{P113DScalar{stmt},[]}
    case N111Load{+name,+typ,N111Local{+buffer},+offset}:
      nt_choose(X185ScratchStep,List.is_empty(&2,X185ScratchCell,facts),
        u => X185ScratchStep{P113DScalar{stmt},[]},
        u => X185ScratchStep{x185_sf_loaded(stmt,name,typ,nt_choose(Maybe<&2,N111Value>,x185_sf_cell(buffer,offset,typ,buffers),
          v => x185_sf_find(facts,buffer,offset,typ),v => None{})),x185_sf_written(facts,name)})
    case N111Load{name,typ,base,offset}: X185ScratchStep{P113DScalar{stmt},x185_sf_written(facts,name)}
    case N111Set{name,typ,value}: X185ScratchStep{P113DScalar{stmt},x185_sf_written(facts,name)}
    case N111Bin{name,typ,op,left,right}: X185ScratchStep{P113DScalar{stmt},x185_sf_written(facts,name)}
    case N111Offset{name,base,bytes}: X185ScratchStep{P113DScalar{stmt},x185_sf_written(facts,name)}
    case N111Alloca{name,bytes,align}: X185ScratchStep{P113DScalar{stmt},x186_sf_allocated(facts,name)}
    case N111Call{name,typ,symbol,args}: X185ScratchStep{P113DScalar{stmt},x186_sf_inline(x186_inline_op(stmt),facts)}
    case _: X185ScratchStep{P113DScalar{stmt},[]}

@unsafe
def x186_saves_mask(frame: X181Frame) -> U32:
  match frame:
    case X181Frame{slots,bytes,calls,params,symbol}:
      +entry = p111v_get(slots,"__x181_saved_mask")
      nt_choose(U32,agy_str_eq(dk(entry),"X186SavedMask") && U32.is_le(da(entry),31),
        u => da(entry),u => 31)

@unsafe
def x186_m_cell(+name: String, +offset: U32, +typ: N111Type, +buffers: KDef) -> Bool:
  x185_sf_cell(name,offset,typ,buffers) && U32.is_eq(U32.mod(offset,4),0)

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
def x186_p_zip(params: List<&2,String>, values: List<&2,N111Value>, +slots: KDef,
    +moves: List<&2,X186Move>) -> Maybe<&2,List<&2,X186Move>>:
  match params values:
    case Nil{} Nil{}: Some{nt_reverse(X186Move,moves,[])}
    case Con{+name,rest} Con{+value,more}:
      +home = p111v_get(slots,name)
      nt_choose(Maybe<&2,List<&2,X186Move>>,x186_p_word_home(home,True{}) &&
          x186_p_source_valid(value,slots) && Bool.not(x186_p_dest_used(home,moves)),
        u => x186_p_zip(rest,more,slots,Con{X186Move{name,value,home,x186_p_source(value,slots)},moves}),
        u => None{})
    case _ _: None{}

@unsafe
def x190_move_selected(name: String, value: N111Value, ids: N111Ids, +frame: X181Frame, physical: X185Physical) -> X188Seq:
  match physical:
    case X185Physical{wide,narrow,byte}: x181_store(name,frame,wide)
    case _: x188_cat(x181_load(value,ids,frame,x188_reg(10,64)),x181_store(name,frame,x188_reg(10,64)))

# A 32-bit destination write both truncates and clears the upper half, including
# source=destination. Stack locals are complete allocated 64-bit frame words.
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
def w4c_e_kill_val(v: N111Value, state: X186ExprState) -> X186ExprState:
  match v:
    case N111Local{n}: x186_e_written(state,n)
    case _: state

@unsafe
def w4c_dia_has(+m: KDef, +n: String) -> Bool:
  U32.is_gt(da(p111v_get(m,n)),0)

@unsafe
def w5_sel_nonlast_ok(s: W5Sel, +dst: String, +forb: KDef) -> Bool:
  match s:
    case W5Sel{_,+n,_,_,_}:
      Bool.not(String.is_empty(n)) && Bool.not(agy_str_eq(n,dst)) && Bool.not(w4c_dia_has(forb,n))
    case W5SelNone{}: False{}

@unsafe
def w4c_dia_cond_ok(cond: N111Value, +writes: KDef) -> Bool:
  match cond:
    case N111Local{n}: Bool.not(w4c_dia_has(writes,n))
    case N111Const{_,_}: True{}
    case _: False{}

@unsafe
def w5_dia_collapse_pair2(+h1: P113DStmt, +h2: P113DStmt, +t: String, +v: N111Value,
    s2: W5SnapSet, +afterLive: KDef) -> List<&2,P113DStmt>:
  match s2:
    case W5Snap{dst,dt,v2}:
      nt_choose(List<&2,P113DStmt>,w5_snap_local_eq(v2,t) && Bool.not(w4c_dia_has(afterLive,t)),
        u => [P113DScalar{N111Set{dst,dt,v}}],
        u => [h1,h2])
    case W5SnapNone{}: [h1,h2]

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
def w5b_val_unmodified(v: N111Value, +x: String, +allW: KDef) -> Bool:
  match v:
    case N111Const{_,_}: True{}
    case N111Local{+vn}: Bool.not(agy_str_eq(vn,x)) && Bool.not(w5b_has_name(vn,allW))
    case _: False{}

@unsafe
def w5b_filter_sets(sets: List<&2,P113DStmt>, +hoistNames: KDef, +keepHoisted: Bool) -> List<&2,P113DStmt>:
  match sets:
    case Nil{}: []
    case Con{+h,+t}:
      match h:
        case P113DScalar{N111Set{+x,_,_}}:
          +isH = w5b_has_name(x,hoistNames)
          nt_choose(List<&2,P113DStmt>,nt_choose(Bool,keepHoisted,u => isH,u => Bool.not(isH)),
            u => Con{h,w5b_filter_sets(t,hoistNames,keepHoisted)},
            u => w5b_filter_sets(t,hoistNames,keepHoisted))
        case _:
          nt_choose(List<&2,P113DStmt>,keepHoisted,
            u => w5b_filter_sets(t,hoistNames,keepHoisted),
            u => Con{h,w5b_filter_sets(t,hoistNames,keepHoisted)})

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
def x186_x_source(value: N111Value, homes: KDef) -> Maybe<&2,X187Operand>:
  match value:
    case N111Local{name}: x186_x_home(name,homes)
    case N111Const{lo,0}: x186_x_home("$w2c_" ++ U32.show(lo),homes)
    case _: None{}

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
def w2_phys_load(lh: X185Physical, left: N111Value, ids: N111Ids, frame: X181Frame) -> X188Seq:
  match lh:
    case X185Physical{wide,narrow,byte}: X188Empty{}
    case _: x181_load(left,ids,frame,x188_reg(10,64))

@unsafe
def w2_phys_val(value: N111Value, frame: X181Frame) -> X185Physical:
  match value:
    case N111Local{name}: x185_physical_home(name,frame)
    case _: X185PhysicalNone{}

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
def w2_tbl_store(+dest: String, sym: String, +frame: X181Frame, homes: KDef) -> X188Seq:
  w2_tbl_store_to(x186_x_home(dest,homes),dest,sym,frame)

@unsafe
def w2_tbl_clamp(val: N111Value, +last: U32, ids: N111Ids, frame: X181Frame) -> X188Seq:
  x188_many([
    x181_load(val,ids,frame,x188_reg(10,64)),
    x188_i2("cmpq",X187Imm{last,0},x188_reg(10,64)),
    x188_i2("movl",X187Imm{last,0},x188_reg(11,32)),
    x188_i2("cmovaeq",x188_reg(11,64),x188_reg(10,64))])

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
def w4b_xl_start_reg(+tparams: List<&2,String>, +nodes: List<&2,X186FloatNode>, +hotConsts: List<&2,U32>) -> U32:
  +need = U32.add(w4b_xl_count_params(tparams,0,tparams,nodes,0),w4b_u32_len(hotConsts,0))
  nt_choose(U32,U32.is_le(need,6),u => 10,u =>
    nt_choose(U32,U32.is_ge(need,8),u => 8,u => U32.sub(16,need)))

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
def x190_l_value(value: N111Value, ids: KDef) -> U32:
  match value:
    case N111Local{name}: x190_l_bit(name,ids)
    case _: 0

@unsafe
def x190_l_values(values: List<&2,N111Value>, +ids: KDef) -> U32:
  match values:
    case Nil{}: 0
    case Con{value,rest}: U32.or(x190_l_value(value,ids),x190_l_values(rest,ids))

@unsafe
def x190_l_names(names: List<&2,String>, +ids: KDef) -> U32:
  match names:
    case Nil{}: 0
    case Con{name,rest}: U32.or(x190_l_bit(name,ids),x190_l_names(rest,ids))

# Greedy priority is total body/setup read count, with body encounter ties. Saved homes are
# already installed and never enter this candidate pool. At most 32 names are
# considered; zero-read writes still matter whenever their name is a candidate.
@unsafe
def x190_l_args(args: List<&2,N111Arg>, +ids: KDef) -> U32:
  match args:
    case Nil{}: 0
    case Con{N111Arg{typ,value},rest}: U32.or(x190_l_value(value,ids),x190_l_args(rest,ids))

@unsafe
def x190_l_inline(operation: X186InlineOp, reads: U32, writes: U32, flow: X190LFlow, +env: X190LEnv) -> X190LFlow:
  match operation env:
    case X186InlineF32{name,id,buffer} X190LEnv{+ids,parameters,header,collect}:
      x190_l_event(x190_l_bit(buffer,ids),x190_l_bit(name,ids),flow,env)
    case _ _: x190_l_call(reads,writes,flow,env)

@unsafe
def x190_l_incoming(params: List<&2,String>, flow: X190LFlow, +env: X190LEnv) -> X190LFlow:
  match params env:
    case Nil{} _: flow
    case Con{name,rest} X190LEnv{+ids,parameters,header,collect}:
      x190_l_event(0,x190_l_bit(name,ids),x190_l_incoming(rest,flow,env),env)

# Prologue copies read ABI arguments in order. A candidate parameter may use
# only a source register already consumed at that point. Nonparameters begin
# after the prologue and have no such restriction.
@unsafe
def x190_a_color(names: List<&2,String>, rows: List<&2,U32>, +params: List<&2,String>,
    +bit: U32, +groups: List<&2,U32>, +affinities: KDef) -> List<&2,U32>:
  match names rows:
    case Con{+name,rest} Con{edges,more}:
      x190_a_color(rest,more,params,U32.shl(bit),
        x190_l_group(groups,x190_a_choose(groups,da(p111v_get(affinities,name)),bit,edges,x190_l_position(name,params,0)),bit),affinities)
    case _ _: groups

@unsafe
def w5c_pj_collect_one(+name: String, +color: U32, +bit: U32, +header: U32, +ranges: KDef, +st: W5CPJState) -> W5CPJState:
  match st:
    case W5CPJState{+ends,+occ}:
      nt_choose(W5CPJState,U32.is_ge(color,4) && U32.is_lt(color,9),
        u =>
          +k = U32.sub(color,4)
          +r = p111v_get(ranges,name)
          nt_choose(W5CPJState,U32.is_eq(U32.and(header,bit),0) && agy_str_eq(dk(r),"X185TRange"),
            v => W5CPJState{ends,w5c_occ_add(occ,k,W5CIntv{da(r),dx(r)})},
            v => W5CPJState{x185_t_end(ends,k,4294967295),occ}),
        u => st)

@unsafe
def w5c_pj_collect(names: List<&2,String>, +groups: List<&2,U32>, +header: U32,
    +ranges: KDef, +bit: U32, st: W5CPJState) -> W5CPJState:
  match names:
    case Nil{}: st
    case Con{+name,rest}:
      w5c_pj_collect(rest,groups,header,ranges,U32.shl(bit),
        w5c_pj_collect_one(name,x190_j_home(groups,bit,0),bit,header,ranges,st))

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
def x190_branch_allowed(name: String, typ: N111Type, op: String,
    condition: N111Value, facts: X190BranchFacts) -> Bool:
  x190_branch_allowed_when(x190_branch_reuse_enabled(),name,typ,op,condition,facts)

# The existing layout falls through to yes and jumps to no. Invert the exact
# signed/unsigned predicate; no complementary-condition or dominance inference.
@unsafe
def x190_branch_load(value: N111Value, ids: N111Ids, frame: X181Frame, physical: X185Physical, scratch: X187Operand) -> X188Seq:
  match physical:
    case X185Physical{wide,narrow,byte}: X188Empty{}
    case _: x181_load(value,ids,frame,scratch)

# Comparisons preserve both physical operands, including equal homes. Unknown
# operands use distinct reserved scratch registers outside the allocated pool.
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
def x198h_tail(fid: String, +ids: N111Ids, +frame: X181Frame, code: X181Code) -> X181Code:
  match code:
    case X181Code{chunks,next,terminal,error}:
      X181Code{Con{x188_many([
        x181_load(N111Local{"state"},ids,frame,x188_reg(7,64)),
        x188_i2("movl",X187Imm{4294967295,0},X187Mem{7,32}),
        x186_saves_text(x186_saves_mask(frame),0,True{}),
        x188_i2("movq",x188_reg(5,64),x188_reg(4,64)),x188_i1("popq",x188_reg(5,64)),
        x188_i1("jmp",X187Target{p111q_symbol(fid)})]),chunks},next,True{},error}

@unsafe
def x191_single(+name: String, facts: X190BranchFacts) -> Bool:
  match facts:
    case X190BranchFacts{reads,writes,pairs,protected}:
      Bool.not(x181_register_reserved(name)) && U32.is_eq(da(p111v_get(reads,name)),1) &&
        U32.is_eq(da(p111v_get(writes,name)),1) && U32.is_eq(da(p111v_get(protected,name)),0)

# Only full-width multiplication/left shift matches 64-bit effective-address
# arithmetic. A U32 intermediate must retain its wrap and zero extension.
@unsafe
def x191_load_alu(+loaded: String, +typ: N111Type, address: X191Address,
    body: List<&2,P113DStmt>, +facts: X190BranchFacts) -> Maybe<&2,X191Pick>:
  match body:
    case Con{P113DScalar{N111Bin{name,+other,+op,left,right}},rest}:
      nt_choose(Maybe<&2,X191Pick>,x191_memory_alu_enabled() && x191_single(loaded,facts) &&
          U32.is_eq(p111v_type(typ),p111v_type(other)) && x191_alu(op),
        u => x191_alu_found(x191_alu_left(loaded,op,left,right),rest,name,other,op,address),u => None{})
    case _: None{}

@unsafe
def x191_destination(name: String, frame: X181Frame) -> U32:
  x191_reg_home(x185_physical_home(name,frame),0)

@unsafe
def x192_address_name(+name: String, +count: U32, facts: X190BranchFacts) -> Bool:
  match facts:
    case X190BranchFacts{reads,writes,pairs,protected}:
      Bool.not(x181_register_reserved(name)) && U32.is_eq(da(p111v_get(reads,name)),count) &&
        U32.is_eq(da(p111v_get(writes,name)),1) && U32.is_eq(da(p111v_get(protected,name)),0)

@unsafe
def x192_address_aliases_done(aliases: List<&2,X192AddressAlias>, +facts: X190BranchFacts) -> Bool:
  match aliases:
    case Nil{}: True{}
    case Con{X192AddressAlias{name,address,+reads},rest}:
      U32.is_gt(reads,0) && x192_address_name(name,reads,facts) && x192_address_aliases_done(rest,facts)

@unsafe
def x192_address_fuse_pair(+load: X191Operation, +stmt: P113DStmt,
    +rest: List<&2,X192AddressRow>, +facts: X190BranchFacts) -> List<&2,X192AddressRow>:
  match load stmt:
    case X191Load{+loaded,+typ,address} P113DScalar{N111Bin{name,+other,+op,left,right}}:
      nt_choose(List<&2,X192AddressRow>,x191_memory_alu_enabled() && x191_single(loaded,facts) &&
          U32.is_eq(p111v_type(typ),p111v_type(other)) && x191_alu(op),
        u => x192_address_fuse_left(x191_alu_left(loaded,op,left,right),load,stmt,name,other,op,address,
          x192_address_fuse(rest,facts)),
        u => Con{X192AddressMemory{load},x192_address_fuse(Con{X192AddressPlain{stmt},rest},facts)})
    case _ _: Con{X192AddressMemory{load},x192_address_fuse(Con{X192AddressPlain{stmt},rest},facts)}

@unsafe
def x192_address_fuse(rows: List<&2,X192AddressRow>, +facts: X190BranchFacts) -> List<&2,X192AddressRow>:
  match rows:
    case Con{X192AddressMemory{load},Con{X192AddressPlain{stmt},rest}}:
      x192_address_fuse_pair(load,stmt,rest,facts)
    case Con{head,rest}: Con{head,x192_address_fuse(rest,facts)}
    case Nil{}: []

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
def x198qm_item(+item: X187Parsed, +previous: X191FrameStore, +output: List<&2,X188Seq>) -> List<&2,X188Seq>:
  match item:
    case PInst{X187Instruction{op,[X187Target{name}]}}:
      nt_choose(List<&2,X188Seq>,agy_str_eq(op,"call") && agy_str_eq(name,"p111_rt_op"),
        u => x198qm_window(output,X188One{item}),u => Con{x191_ff_item(item,previous),output})
    case PInst{X187Instruction{op,[X187Reg{r,32,False{}},X187Reg{x,128,True{}}]}}:
      nt_choose(List<&2,X188Seq>,agy_str_eq(op,"movd") && w2c_drop_movd_roundtrip(output,r,x),
        u => output,u => Con{x191_ff_item(item,previous),output})
    case _: Con{x191_ff_item(item,previous),output}

@unsafe
def w4b_copy_check_jcc(br: W4BBranch, +i0: X187Parsed, +i1: X187Parsed, +i2: X187Parsed,
    +i3: X187Parsed, +tail: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +out: List<&2,X188Seq>) -> List<&2,X188Seq>:
  match br:
    case W4BBranch{jop,_}:
      nt_choose(List<&2,X188Seq>,w4_peep_is_jz_jnz(jop),
        u => w4b_copy_peep(Con{i3,tail},fnItems,Con{X188One{i1},Con{X188One{i0},out}}),
        u => w4b_copy_peep(Con{i1,Con{i2,Con{i3,tail}}},fnItems,Con{X188One{i0},out}))
    case W4BBranchNone{}: w4b_copy_peep(Con{i1,Con{i2,Con{i3,tail}}},fnItems,Con{X188One{i0},out})

@unsafe
def w4c_sub_fold4(r4: W4BRR, +b: U32, +t: U32, +a: U32,
    +i0: X187Parsed, +i1: X187Parsed, +rest: List<&2,X187Parsed>, +tail: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +out: List<&2,X188Seq>) -> List<&2,X188Seq>:
  match r4:
    case W4BRR{op4,s4,ws4,d4,wd4}:
      nt_choose(List<&2,X188Seq>,
        agy_str_eq(op4,"movq") && U32.is_eq(s4,a) && U32.is_eq(ws4,64) && U32.is_eq(d4,b) && U32.is_eq(wd4,64) &&
        Bool.not(U32.is_eq(a,b) || U32.is_eq(t,a) || U32.is_eq(t,b) || U32.is_eq(t,11) || U32.is_eq(a,11) || U32.is_eq(b,11)) &&
        w4b_reg_dead(t,tail,fnItems,36) && w4b_reg_dead(a,tail,fnItems,36) && w4b_reg_dead(11,tail,fnItems,36),
        u => w4b_copy_peep(Con{PInst{X187Instruction{"subl",[X187Reg{a,32,False{}},X187Reg{b,32,False{}}]}},tail},fnItems,out),
        u => w4b_copy_peep(Con{i1,rest},fnItems,Con{X188One{i0},out}))
    case W4BRRNone{}: w4b_copy_peep(Con{i1,rest},fnItems,Con{X188One{i0},out})

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
def w4c_sub_fold2(r2: W4BRR, +i3: X187Parsed, +i4: X187Parsed, +b: U32, +t: U32, +a: U32,
    +i0: X187Parsed, +i1: X187Parsed, +rest: List<&2,X187Parsed>, +tail: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +out: List<&2,X188Seq>) -> List<&2,X188Seq>:
  match r2:
    case W4BRR{op2,s2,ws2,d2,wd2}:
      nt_choose(List<&2,X188Seq>,
        agy_str_eq(op2,"movq") && U32.is_eq(s2,t) && U32.is_eq(ws2,64) && U32.is_eq(d2,a) && U32.is_eq(wd2,64),
        u => w4c_sub_fold3(w4b_as_rr(i3),i4,b,t,a,i0,i1,rest,tail,fnItems,out),
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
def w4b_copy_check_cmp(cm: W4BImmReg, +c: U32, +i0: X187Parsed, +i1: X187Parsed,
    +i2: X187Parsed, +i3: X187Parsed, +tail: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +out: List<&2,X188Seq>) -> List<&2,X188Seq>:
  match cm:
    case W4BImmReg{cop,lo,hi,cr,cw}:
      nt_choose(List<&2,X188Seq>,agy_str_eq(cop,"cmpq") && U32.is_eq(lo,0) && U32.is_eq(hi,0) &&
          U32.is_eq(cr,c) && U32.is_eq(cw,64),
        u => w4b_copy_check_jcc(w4b_as_branch(i3),i0,i1,i2,i3,tail,fnItems,out),
        u => w4b_copy_peep(Con{i1,Con{i2,Con{i3,tail}}},fnItems,Con{X188One{i0},out}))
    case W4BImmRegNone{}: w4b_copy_check_test(w4b_as_rr(i2),c,i0,i1,i2,i3,tail,fnItems,out)

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
def w4c_backedge_coalesce(+items: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  +totR = w4c_count_reads(items,W4CMEmpty{})
  +totW = w4c_count_writes(items,W4CMEmpty{})
  w4c_join_bbs(w4c_coal_bbs(w4c_split_bb(items,[],[]),totR,totW))

# Sub-pass C4: Dead negative-%rbp stack-slot store elimination
@unsafe
def w4c_dead_slot_elim(+items: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  w4c_drop_dead_stores(items,w4c_count_reads(items,W4CMEmpty{}),[])

@unsafe
def w5_g1_d(+d1: U32, +d2: U32, +op1: String, +rA: U32, +rB: U32, rr3: W4BRR,
    +r4: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rr3:
    case W4BRR{op3,s3,64,d3,64}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        agy_str_eq(op3,op1) && U32.is_eq(s3,rB) && U32.is_eq(d3,rA) &&
        w4b_reg_dead(rB,r4,fnItems,96),
        u => Some{w5_gpr_peep(r4,fnItems,
          Con{PInst{X187Instruction{op1,[X187Mem{5,d2},x188_reg(rA,64)]}},
          Con{PInst{X187Instruction{op1,[X187Mem{5,d1},x188_reg(rA,64)]}},acc}})},
        u => None{})
    case _: None{}

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
def w5_g1_b(+d1: U32, +rB: U32, rr1: W4BRR, +i2: X187Parsed, +i3: X187Parsed,
    +r4: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rr1:
    case W4BRR{+op1,+rA,64,dr1,64}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        w5_is_comm64(op1) && U32.is_eq(dr1,rB) && Bool.not(U32.is_eq(rA,rB)) &&
        Bool.not(U32.is_eq(rA,5)) && Bool.not(U32.is_eq(rB,5)),
        u => w5_g1_c(d1,op1,rA,rB,w5_as_load_rbp(i2),i3,r4,fnItems,acc),
        u => None{})
    case _: None{}

# G2: movq %rC, %rax; movq srcY, %r10; movq %rN, %r11; testl %eax, %eax; cmovneq %r10, %r11; movq %r11, dst
@unsafe
def w5_gpr_try_rr(rr0: W4BRR, +i0: X187Parsed, +i1: X187Parsed, +r2: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rr0:
    case W4BRR{+op0,+rA,64,+rB,64}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,agy_str_eq(op0,"movq") && Bool.not(U32.is_eq(rA,rB)),
        u => w5_gpr_rr64_r2(rA,rB,i1,r2,fnItems,acc),
        u => None{})
    case W4BRR{+op0,+rA,32,+rB,32}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,agy_str_eq(op0,"movl") && Bool.not(U32.is_eq(rA,rB)),
        u => w5_gpr_rr32_r2(rA,rB,i1,r2,fnItems,acc),
        u => None{})
    case _: None{}

# G12: cmpq $0, %rC; sete %rC8; movzbl %rC8, %rC32; ... testl %rC32, %rC32; cmov(n)eq src, dst
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
def w5b_promote_one(+rFree: U32, +isR12: Bool, +items: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  w5b_promote_pick(rFree,isR12,items,w5b_scan_slots(items,isR12,False{},W5BSlotScan{W4CMEmpty{},W4CMEmpty{}}))

@unsafe
def w5b_promote_cleanup(+orig: List<&2,X187Parsed>, +prom: List<&2,X187Parsed>, changed: Bool) -> List<&2,X187Parsed>:
  match changed:
    case False{}: orig
    case True{}:
      +p1 = w5_flat_rev_seq(w4b_copy_peep(prom,prom,[]),[])
      w5_flat_rev_seq(w4c_peep_cfg(p1,p1,[]),[])

@unsafe
def w11_inst_imm_eq_reg(item: X187Parsed, +want_op: String, +want_imm: U32, +want_r: U32, +rw: U32) -> Bool:
  w11_some_u32_eq(w11_inst_imm_reg(item,want_op,want_r,rw),want_imm)

@unsafe
def w11_inst_reg_reg_eq(item: X187Parsed, +want_op: String, +r1: U32, +w1: U32, +r2: U32, +w2: U32) -> Bool:
  w11_some_u32_eq(w11_inst_reg_dst(item,want_op,r1,w1,w2),r2)

@unsafe
def w11_rot16_s6(+rotOp: String, +rX: U32, +rA: U32, +rB: U32, +k: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{i6,+tail}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,w11_inst_imm_eq_reg(i6,"andq",65535,rA,64) && w5b_reg_dead_fast(rB,tail,fnItems),
        u => Some{Con{PInst{X187Instruction{"movzwl",[x188_reg(rX,32),x188_reg(rA,32)]}},
                  Con{PInst{X187Instruction{rotOp,[X187Imm{k,0},x188_reg(rA,32)]}},tail}}},
        u => None{})
    case _: None{}

@unsafe
def w11_cmp_jcc_tail(+cmpInst: X187Parsed, +cc: String, +rA: U32, +rB: U32, +inv: Bool,
    rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{iT,rJ}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,w11_inst_reg_reg_eq(iT,"testl",rB,32,rB,32),
        u => w11_cmp_jcc_j(cmpInst,cc,rA,rB,inv,rJ,fnItems),
        u => None{})
    case _: None{}

@unsafe
def w11_cmp_bounce_s4(+rA: U32, +rT1: U32, +rB: U32, +rT2: U32, +opS: String,
    rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{i4,+tail}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,w11_inst_reg_reg_eq(i4,"movzbl",rT1,8,rT1,32) && w5b_reg_dead_fast(rT2,tail,fnItems),
        u => Some{Con{PInst{X187Instruction{"cmpq",[x188_reg(rB,64),x188_reg(rA,64)]}},
                  Con{PInst{X187Instruction{opS,[X187Reg{rT1,8,False{}}]}},
                  Con{PInst{X187Instruction{"movzbl",[X187Reg{rT1,8,False{}},x188_reg(rT1,32)]}},tail}}}},
        u => None{})
    case _: None{}

@unsafe
def w11_sel_bounce_s5(+srcY: X187Operand, +rN: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{i5,tail}: w11_sel_bounce_dst(srcY,rN,w11_inst_reg_any(i5,"movq",11,64),tail,fnItems)
    case _: None{}

@unsafe
def w11_sel_bounce_s4(+srcY: X187Operand, +rN: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{i4,r5}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,w11_inst_reg_reg_eq(i4,"cmovneq",10,64,11,64),
        u => w11_sel_bounce_s5(srcY,rN,r5,fnItems),
        u => None{})
    case _: None{}

law w5c_gpr_peep_c:
  for items: List<&2,X187Parsed>
  for +fnItems: List<&2,X187Parsed>
  for +acc: List<&2,X187Parsed>
  W5BGprOut

@unsafe
def w5c_gpr_or_c(res: Maybe<&2,List<&2,X187Parsed>>, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> W5BGprOut:
  match res:
    case Some{out}: W5BGprChanged{out}
    case None{}: w5c_gpr_peep_c(Con{i1,r2},fnItems,Con{i0,acc})

@unsafe
def w5c_gpr_ld_c(neg: Bool, +disp: U32, +rB: U32, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> W5BGprOut:
  match neg:
    case False{}: w5c_gpr_peep_c(Con{i1,r2},fnItems,Con{i0,acc})
    case True{}: w5c_gpr_or_c(w5_gpr_try_ld(W5LRYes{disp,rB},i1,r2,fnItems,acc),i0,i1,r2,fnItems,acc)

@unsafe
def w5c_gpr_rr64_c(same: Bool, +rA: U32, +rB: U32, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> W5BGprOut:
  match same:
    case True{}: w5c_gpr_peep_c(Con{i1,r2},fnItems,Con{i0,acc})
    case False{}: w5c_gpr_or_c(w5_gpr_rr64_r2(rA,rB,i1,r2,fnItems,acc),i0,i1,r2,fnItems,acc)

@unsafe
def w5c_gpr_movq_c(src: X187Operand, +rB: U32, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> W5BGprOut:
  match src:
    case X187Mem{5,disp}: w5c_gpr_ld_c(w4c_is_neg_rbp(5,disp),disp,rB,i0,i1,r2,fnItems,acc)
    case X187Reg{+rA,64,False{}}: w5c_gpr_rr64_c(U32.is_eq(rA,rB),rA,rB,i0,i1,r2,fnItems,acc)
    case _: w5c_gpr_peep_c(Con{i1,r2},fnItems,Con{i0,acc})

@unsafe
def w5c_gpr_cmpq_c(src: X187Operand, +rB: U32, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> W5BGprOut:
  match src:
    case X187Imm{0,0}: w5c_gpr_or_c(w5b_g12_b(rB,w5_as_setcc(i1),r2,fnItems,acc),i0,i1,r2,fnItems,acc)
    case _: w5c_gpr_peep_c(Con{i1,r2},fnItems,Con{i0,acc})

@unsafe
def w5c_gpr_rr32_c(same: Bool, +rA: U32, +rB: U32, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> W5BGprOut:
  match same:
    case True{}: w5c_gpr_peep_c(Con{i1,r2},fnItems,Con{i0,acc})
    case False{}: w5c_gpr_or_c(w5_gpr_rr32_r2(rA,rB,i1,r2,fnItems,acc),i0,i1,r2,fnItems,acc)

@unsafe
def w5c_gpr_movl_c(src: X187Operand, +rB: U32, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> W5BGprOut:
  match src:
    case X187Reg{+rA,32,False{}}: w5c_gpr_rr32_c(U32.is_eq(rA,rB),rA,rB,i0,i1,r2,fnItems,acc)
    case _: w5c_gpr_peep_c(Con{i1,r2},fnItems,Con{i0,acc})

@unsafe
def w5c_gpr_xorl_c(src: X187Operand, +rB: U32, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> W5BGprOut:
  match src:
    case X187Imm{1,0}: w5c_gpr_or_c(w5_g8_b(rB,w4b_as_imm_reg(i1),r2,fnItems,acc),i0,i1,r2,fnItems,acc)
    case _: w5c_gpr_peep_c(Con{i1,r2},fnItems,Con{i0,acc})

@unsafe
def w5c_gpr_op64_cmp_c(isCmpq: Bool, src: X187Operand, +d: U32, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> W5BGprOut:
  match isCmpq:
    case True{}: w5c_gpr_cmpq_c(src,d,i0,i1,r2,fnItems,acc)
    case False{}: w5c_gpr_peep_c(Con{i1,r2},fnItems,Con{i0,acc})

@unsafe
def w5c_gpr_op64_c(isMovq: Bool, +op: String, src: X187Operand, +d: U32, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> W5BGprOut:
  match isMovq:
    case True{}: w5c_gpr_movq_c(src,d,i0,i1,r2,fnItems,acc)
    case False{}: w5c_gpr_op64_cmp_c(String.eq(op,"cmpq"),src,d,i0,i1,r2,fnItems,acc)

@unsafe
def w5c_gpr_op32_xor_c(isXor: Bool, src: X187Operand, +d: U32, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> W5BGprOut:
  match isXor:
    case True{}: w5c_gpr_xorl_c(src,d,i0,i1,r2,fnItems,acc)
    case False{}: w5c_gpr_peep_c(Con{i1,r2},fnItems,Con{i0,acc})

@unsafe
def w5c_gpr_op32_c(isMovl: Bool, +op: String, src: X187Operand, +d: U32, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> W5BGprOut:
  match isMovl:
    case True{}: w5c_gpr_movl_c(src,d,i0,i1,r2,fnItems,acc)
    case False{}: w5c_gpr_op32_xor_c(String.eq(op,"xorl"),src,d,i0,i1,r2,fnItems,acc)

@unsafe
def w5c_gpr_wd_c(wd: U32, +op: String, src: X187Operand, +d: U32, +i0: X187Parsed, +i1: X187Parsed,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> W5BGprOut:
  match wd:
    case 64: w5c_gpr_op64_c(String.eq(op,"movq"),op,src,d,i0,i1,r2,fnItems,acc)
    case 32: w5c_gpr_op32_c(String.eq(op,"movl"),op,src,d,i0,i1,r2,fnItems,acc)
    case _: w5c_gpr_peep_c(Con{i1,r2},fnItems,Con{i0,acc})

@unsafe
def w5c_gpr_step_c(+i0: X187Parsed, +i1: X187Parsed, +r2: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> W5BGprOut:
  match i0:
    case PInst{X187Instruction{+op,Con{src,Con{X187Reg{+d,+wd,False{}},Nil{}}}}}:
      w5c_gpr_wd_c(wd,op,src,d,i0,i1,r2,fnItems,acc)
    case PInst{X187Instruction{+op,Con{X187Target{+lbl},Nil{}}}}:
      w5c_gpr_or_c(w5_gpr_try_jcc(W4BBranch{op,lbl},i1,r2,fnItems,acc),i0,i1,r2,fnItems,acc)
    case _: w5c_gpr_peep_c(Con{i1,r2},fnItems,Con{i0,acc})

@unsafe
def w5c_gpr_peep_c(items,fnItems,acc):
  match items:
    case Nil{}: W5BGprUnchanged{}
    case Con{+i0,Con{+i1,+r2}}: w5c_gpr_step_c(i0,i1,r2,fnItems,acc)
    case Con{_,Nil{}}: W5BGprUnchanged{}

@unsafe
def w5c_gpr_pass3(r2: W5BGprOut, g1: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match r2:
    case W5BGprUnchanged{}: g1
    case W5BGprChanged{+g2}: w5_gpr_peep(g2,g2,[])

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
def x199s_apply(+code: X188Seq,slots: KDef,label: String) -> X188Seq:
  x199s_check(x199s_flat([code],640,[]),code,slots,label)

@unsafe
def x191_select_publish(names: List<&2,String>, +frame: X181Frame) -> X188Seq:
  match names:
    case Nil{}: X188Empty{}
    case Con{name,rest}:
      x188_cat(x181_store(name,frame,x188_reg(11,64)),x191_select_publish(rest,frame))

@unsafe
def x191_select_emit(condition: N111Value, plan: X191SelectPlan,
    +ids: N111Ids, +frame: X181Frame) -> X188Seq:
  match plan:
    case X191SelectPlan{+typ,yes,no,names}:
      x188_many([x181_load(condition,ids,frame,x188_reg(0,64)),
        x181_load(yes,ids,frame,x188_reg(10,64)),x181_mask(typ,x188_reg(10,32)),
        x181_load(no,ids,frame,x188_reg(11,64)),x181_mask(typ,x188_reg(11,32)),
        x188_i2("testl",x188_reg(0,32),x188_reg(0,32)),
        x188_i2(x181_width(typ,"cmovneq","cmovnel"),x188_width_reg(typ,10),x188_width_reg(typ,11)),
        x191_select_publish(names,frame)])

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
def x197ms_destination(names: List<&2,String>, frame: X181Frame) -> X185Physical:
  match names:
    case Con{name,rest}: x185_physical_home(name,frame)
    case Nil{}: X185PhysicalNone{}

# A store never changes its source register. Skipping a same-home publication
# preserves the actual assigned value; stack publications are always emitted.
@unsafe
def x197ms_publish(names: List<&2,String>, +frame: X181Frame, +result: X187Operand) -> X188Seq:
  match names:
    case Nil{}: X188Empty{}
    case Con{+name,rest}:
      x188_cat(nt_choose(X188Seq,x185_physical_same(x185_physical_home(name,frame),result),
        u => X188Empty{},u => x181_store(name,frame,result)),x197ms_publish(rest,frame,result))

# CMP has already read both original operands. If result aliases yes, preserve
# that value and select no under the complementary predicate. Otherwise result
# either already holds no, or receives a width-correct MOV before CMOV yes.
# Explicit MOVL normalization covers a not-taken CMOV and noncanonical high bits.
@unsafe
def w2_cmov_load(value: N111Value, ids: N111Ids, frame: X181Frame, +regIdx: U32) -> X188Seq:
  match value:
    case N111Const{+lo,0}: x188_i2("movl",X187Imm{lo,0},x188_reg(regIdx,32))
    case _: x181_load(value,ids,frame,x188_reg(regIdx,64))

@unsafe
def x192_p_boolean(value: N111Value, facts: KDef) -> Bool:
  match value:
    case N111Const{lo,hi}: U32.is_eq(hi,0) && U32.is_le(lo,1)
    case N111Local{name}: U32.is_eq(da(p111v_get(facts,name)),1)
    case _: False{}

@unsafe
def x192_p_binary(+stmt: N111Stmt, +facts: KDef) -> N111Stmt:
  match stmt:
    case N111Bin{+name,typ,+op,+left,+right}:
      nt_choose(N111Stmt,x190_branch_width(typ) && (agy_str_eq(op,"eq") || agy_str_eq(op,"ne")) &&
          x192_p_boolean(left,facts) && (x192_p_constant(right,0) || x192_p_constant(right,1)),
        u => nt_choose(N111Stmt,Bool.xor(agy_str_eq(op,"eq"),x192_p_constant(right,0)),
          v => N111Set{name,N111U32{},left},v => N111Bin{name,N111U32{},"xor",left,N111Const{1,0}}),
        u => stmt)
    case _: stmt

@unsafe
def x192_p_plan(+condition: N111Value, facts: KDef, plan: Maybe<&2,X191SelectPlan>) -> Maybe<&2,List<&2,P113DStmt>>:
  match plan:
    case Some{X191SelectPlan{+typ,+yes,+no,+names}}:
      nt_choose(Maybe<&2,List<&2,P113DStmt>>,x186_e_equal(yes,no),
        u => Some{x192_p_chain(names,typ,yes,False{})},u =>
          nt_choose(Maybe<&2,List<&2,P113DStmt>>,x192_p_boolean(condition,facts) &&
              ((x192_p_constant(yes,1) && x192_p_constant(no,0)) ||
               (x192_p_constant(yes,0) && x192_p_constant(no,1))),
            v => Some{x192_p_chain(names,typ,condition,x192_p_constant(yes,0))},v => None{}))
    case None{}: None{}

def x181_epilogue(frame):
  x188_many([x186_saves_text(x186_saves_mask(frame),0,True{}),
    x188_i2("movq",x188_reg(5,64),x188_reg(4,64)),x188_i1("popq",x188_reg(5,64)),x188_i0("ret")])

@unsafe
def x181_load_results(names: List<&2,String>, +offset: U32, +ids: N111Ids, +frame: X181Frame, code: X181Code) -> X181Code:
  match names:
    case Nil{}: code
    case Con{name,rest}:
      x181_load_results(rest,U32.add(offset,8),ids,frame,x181_add(
        x188_many([x181_load(N111Local{"__x181_results"},ids,frame,x188_reg(11,64)),
          x188_i2("movq",X187Mem{11,offset},x188_reg(0,64)),
          x181_store(name,frame,x188_reg(0,64))]),code))

@unsafe
def x181_tail_snapshot(values: List<&2,N111Value>, +offset: U32, +ids: N111Ids, +frame: X181Frame, code: X181Code) -> X181Code:
  match values:
    case Nil{}: code
    case Con{head,rest}:
      x181_tail_snapshot(rest,U32.add(offset,8),ids,frame,x181_add(
        x188_many([x181_load(head,ids,frame,x188_reg(10,64)),
          x181_load(N111Local{"__x181_tail"},ids,frame,x188_reg(11,64)),
          x188_i2("movq",x188_reg(10,64),X187Mem{11,offset})]),code))

@unsafe
def x181_tail_moves(params: List<&2,String>, +offset: U32, +ids: N111Ids, +frame: X181Frame, code: X181Code) -> X181Code:
  match params code:
    case Nil{} X181Code{chunks,next,terminal,error}:
      X181Code{Con{x188_i1("jmp",X187Target{x181_loop_label(frame)}),chunks},next,True{},error}
    case Con{name,rest} _:
      x181_tail_moves(rest,U32.add(offset,8),ids,frame,x181_add(
        x188_many([x181_load(N111Local{"__x181_tail"},ids,frame,x188_reg(11,64)),
          x188_i2("movq",X187Mem{11,offset},x188_reg(0,64)),
          x181_store(name,frame,x188_reg(0,64))]),code))

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

@unsafe
def x181_prologue(+frame: X181Frame) -> X188Seq:
  match frame:
    case X181Frame{slots,+bytes,+calls,+params,+symbol}:
      x188_many([X188One{PSection{1}},X188One{PGlobal{symbol}},X188One{PType{symbol,2}},X188One{PLabel{symbol}},
        x188_i1("pushq",x188_reg(5,64)),x188_i2("movq",x188_reg(4,64),x188_reg(5,64)),
        x188_i2("subq",X187Imm{U32.add(U32.mul(U32.div(U32.add(U32.add(bytes,calls),15),16),16),48),0},x188_reg(4,64)),
        x186_saves_text(x186_saves_mask(frame),0,False{}),x181_incoming(params,0,frame,[])])

law w2_asr_body:
  for body: List<&2,P113DStmt>
  List<&2,P113DStmt>

law w2_asr_replace_or:
  for +stmts: List<&2,P113DStmt>
  for +s1: String
  for +m: String
  for +v: N111Value
  for +k: U32
  for +fuel: U32
  List<&2,P113DStmt>

@unsafe
def w2_asr_replace_head(+h: P113DStmt, +rest: List<&2,P113DStmt>, +s1: String, +m: String, +v: N111Value, +k: U32, +fuel: U32) -> List<&2,P113DStmt>:
  match h:
    case P113DScalar{N111Bin{dest,typ,op,+l,+r}}:
      nt_choose(List<&2,P113DStmt>,agy_str_eq(op,"or") &&
          ((agy_str_eq(w2_asr_val_local(l),s1) && agy_str_eq(w2_asr_val_local(r),m)) ||
           (agy_str_eq(w2_asr_val_local(l),m) && agy_str_eq(w2_asr_val_local(r),s1))),
        u => Con{P113DScalar{N111Bin{dest,N111U32{},"sar",v,N111Const{k,0}}},w2_asr_body(rest)},
        u => nt_choose(List<&2,P113DStmt>,w2_asr_v_written(v,h),
          z => Con{h,w2_asr_body(rest)},
          z => Con{h,w2_asr_replace_or(rest,s1,m,v,k,U32.sub(fuel,1))}))
    case _: nt_choose(List<&2,P113DStmt>,w2_asr_v_written(v,h),
      z => Con{h,w2_asr_body(rest)},
      z => Con{h,w2_asr_replace_or(rest,s1,m,v,k,U32.sub(fuel,1))})

@unsafe
def w2_asr_replace_or_go(stmts: List<&2,P113DStmt>, +s1: String, +m: String, +v: N111Value, +k: U32, +fuel: U32) -> List<&2,P113DStmt>:
  match stmts:
    case Nil{}: []
    case Con{h,rest}: w2_asr_replace_head(h,rest,s1,m,v,k,fuel)

@unsafe
def w2_asr_replace_or(stmts,s1,m,v,k,fuel):
  nt_choose(List<&2,P113DStmt>,U32.is_eq(fuel,0),u => stmts,u => w2_asr_replace_or_go(stmts,s1,m,v,k,fuel))

@unsafe
def w2_asr_try(found: Maybe<&2,String>, +s1: String, +v: N111Value, +k: U32,
    +sel_rest: List<&2,P113DStmt>, +orig_head: P113DStmt, +orig_tail: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  match found:
    case Some{m}:
      nt_choose(List<&2,P113DStmt>,w2_asr_v_written(v,orig_head),
        u => Con{orig_head,w2_asr_body(orig_tail)},
        u => Con{orig_head,w2_asr_replace_or(orig_tail,s1,m,v,k,24)})
    case None{}: Con{orig_head,w2_asr_body(orig_tail)}

@unsafe
def w2_asr_after(+s1: String, +s2: String, +v1: N111Value, +k: U32, +after: List<&2,P113DStmt>,
    +h1: P113DStmt, +orig_tail: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  +sel = x194_ps_pick(after)
  w2_asr_try(w2_asr_match_sel(sel,s2,w2_asr_mask(k)),s1,v1,k,w2_asr_sel_rest(sel),h1,orig_tail)

@unsafe
def w2_asr_triple(+h1: P113DStmt, +h2: P113DStmt, +h3: P113DStmt, +after: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  match h1 h2 h3:
    case P113DScalar{N111Bin{+s1,t1,op1,+v1,N111Const{+k,0}}}
         P113DScalar{N111Set{+s1c,t1c,N111Local{+s1ref}}}
         P113DScalar{N111Bin{+s2,t2,op2,+v2,N111Const{31,0}}}:
      nt_choose(List<&2,P113DStmt>,agy_str_eq(op1,"shr") && agy_str_eq(op2,"shr") &&
          agy_str_eq(s1,s1ref) && U32.is_ge(k,1) && U32.is_le(k,31) && w2_val_eq(v1,v2),
        u => w2_asr_after(s1c,s2,v1,k,after,h1,Con{h2,Con{h3,after}}),
        u => Con{h1,w2_asr_body(Con{h2,Con{h3,after}})})
    case P113DScalar{N111Bin{+s1,t1,op1,+v1,N111Const{+k,0}}}
         P113DScalar{N111Bin{+s2,t2,op2,+v2,N111Const{31,0}}}
         _:
      nt_choose(List<&2,P113DStmt>,agy_str_eq(op1,"shr") && agy_str_eq(op2,"shr") &&
          U32.is_ge(k,1) && U32.is_le(k,31) && w2_val_eq(v1,v2),
        u => w2_asr_after(s1,s2,v1,k,Con{h3,after},h1,Con{h2,Con{h3,after}}),
        u => Con{h1,w2_asr_body(Con{h2,Con{h3,after}})})
    case _ _ _: Con{h1,w2_asr_body(Con{h2,Con{h3,after}})}

@unsafe
def w2_asr_body(body):
  match body:
    case Nil{}: []
    case Con{P113DIf{c,yes,no},rest}:
      Con{P113DIf{c,w2_asr_body(yes),w2_asr_body(no)},w2_asr_body(rest)}
    case Con{h1,Con{h2,Con{h3,after}}}: w2_asr_triple(h1,h2,h3,after)
    case Con{head,rest}: Con{head,w2_asr_body(rest)}

@unsafe
def x198a_id(+record: KDef) -> P113KFact:
  nt_choose(P113KFact,agy_str_eq(dk(record),"N111Id"),u => p113k_exact(da(record),0),u => p113k_bound(64))

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

law agy_da_try_window:
  for +s0: N111Stmt
  for +s1: N111Stmt
  for +s2: N111Stmt
  for +dsts: List<&2,String>
  for +target: String
  for +dargs: List<&2,N111Value>
  for +s4: N111Stmt
  for +rest: List<&2,P113DStmt>
  for +ids: N111Ids
  for +seq: U32
  List<&2,P113DStmt>

@unsafe
def agy_da_rewrite_body(body: List<&2,P113DStmt>, +ids: N111Ids, +seq: U32) -> List<&2,P113DStmt>:
  match body:
    case Nil{}: []
    case Con{P113DScalar{+s0},
         Con{P113DScalar{+s1},
         Con{P113DScalar{+s2},
         Con{P113DCall{+dsts,+target,+dargs},
         Con{P113DScalar{+s4},+rest}}}}}:
      agy_da_try_window(s0,s1,s2,dsts,target,dargs,s4,rest,ids,seq)
    case Con{P113DIf{c,yes,no},rest}:
      Con{P113DIf{c,agy_da_rewrite_body(yes,ids,U32.add(seq,1)),agy_da_rewrite_body(no,ids,U32.add(seq,17))},
          agy_da_rewrite_body(rest,ids,U32.add(seq,33))}
    case Con{head,rest}:
      Con{head,agy_da_rewrite_body(rest,ids,seq)}

@unsafe
def agy_da_emit_if(+cls: U32, +n_val: N111Value, +seed_val: N111Value, +acc0_val: N111Value, +accout: String,
    +s0: N111Stmt, +s1: N111Stmt, +s2: N111Stmt, +dsts: List<&2,String>, +target: String,
    +dargs: List<&2,N111Value>, +s4: N111Stmt, +rest: List<&2,P113DStmt>, +ids: N111Ids, +seq: U32) -> List<&2,P113DStmt>:
  +k = U32.shln(1,U32.to_nat(cls))
  +pfx = "agy_da_" ++ U32.show(seq) ++ "_"
  +cond = pfx ++ "c"
  +n32 = pfx ++ "n"
  +s32 = pfx ++ "s"
  +prod = pfx ++ "p"
  +a32 = pfx ++ "a"
  +fast : List<&2,P113DStmt> = [
    P113DScalar{N111Set{n32,N111U32{},n_val}},
    P113DScalar{N111Set{s32,N111U32{},seed_val}},
    P113DScalar{N111Bin{prod,N111U32{},"mul",N111Local{n32},N111Local{s32}}},
    P113DScalar{N111Set{a32,N111U32{},acc0_val}},
    P113DScalar{N111Bin{accout,N111U32{},"add",N111Local{a32},N111Local{prod}}}]
  +slow : List<&2,P113DStmt> = [
    P113DScalar{s0},P113DScalar{s1},P113DScalar{s2},P113DCall{dsts,target,dargs},P113DScalar{s4}]
  Con{P113DScalar{N111Bin{cond,N111U64{},"ule",n_val,N111Const{k,0}}},
    Con{P113DIf{N111Local{cond},fast,slow},
      agy_da_rewrite_body(rest,ids,U32.add(seq,1))}}


@unsafe
def agy_da_try_window(s0,s1,s2,dsts,target,dargs,s4,rest,ids,seq):
  match s0 s1 s2 dsts dargs s4:
    case N111Store{N111U64{},N111Local{b0},0,N111Const{+cls,0}}
         N111Store{N111U64{},N111Local{b1},8,+seed_val}
         N111Call{+arr,N111U64{},op_sym,Con{N111Arg{_,N111Local{st0}},Con{N111Arg{_,N111Const{71,0}},Con{N111Arg{_,N111Local{b2}},Con{N111Arg{_,N111Const{2,0}},Nil{}}}}}}
         Con{+aout,Con{+accout,Nil{}}}
         Con{+n_val,Con{i0_val,Con{N111Local{arrarg},Con{+acc0_val,Nil{}}}}}
         N111Call{_,N111U64{},sink_sym,Con{N111Arg{_,N111Local{st1}},Con{N111Arg{_,N111Local{sinkarg}},Nil{}}}}:
      +ok = agy_str_eq(b0,b1) && agy_str_eq(b0,b2) &&
            agy_str_eq(st0,"state") && agy_str_eq(st1,"state") &&
            agy_str_eq(op_sym,"p111_rt_op") && agy_str_eq(sink_sym,"p111_rt_sink") &&
            U32.is_le(cls,16) && agy_str_eq(arrarg,arr) && agy_str_eq(sinkarg,aout) &&
            Bool.not(agy_str_eq(aout,accout)) && agy_da_is_marked(target,ids) &&
            Bool.not(agy_da_stmts_use(rest,arr)) && Bool.not(agy_da_stmts_use(rest,aout))
      nt_choose(List<&2,P113DStmt>,ok,
        u => agy_da_emit_if(cls,n_val,seed_val,acc0_val,accout,s0,s1,s2,dsts,target,dargs,s4,rest,ids,seq),
        u => Con{P113DScalar{s0},agy_da_rewrite_body(Con{P113DScalar{s1},Con{P113DScalar{s2},Con{P113DCall{dsts,target,dargs},Con{P113DScalar{s4},rest}}}},ids,seq)})
    case _ _ _ _ _ _:
      Con{P113DScalar{s0},agy_da_rewrite_body(Con{P113DScalar{s1},Con{P113DScalar{s2},Con{P113DCall{dsts,target,dargs},Con{P113DScalar{s4},rest}}}},ids,seq)}



law agy_zip_target_sym:
  for +name: String
  for +symbol: String
  for +ids: N111Ids
  String

law agy_zip_wrap_direct:
  for +name: String
  for +symbol: String
  for +ids: N111Ids
  for +orig: X181Output
  for +entry: KDef
  X181Output

law agy_zip_get_mark:
  for name: String
  for ids: N111Ids
  KDef


# === AGY-W2C-LISTAPP ===

@unsafe
def agy_sh_has_mark(+ids: N111Ids, +key: String) -> Bool:
  match ids:
    case N111Ids{fs,_}: agy_str_eq(dk(p111v_get(fs,key)),"AgyBasePinned")

# Check !cid_hot[cid]; expects %rax = cid_hot base, clobbers %r10, %r11
@unsafe
def agy_sh_cid2(+ids: N111Ids, +a: String, +b: String) -> U32:
  +c1 = agy_sh_cid(ids,a)
  nt_choose(U32,U32.is_lt(c1,65536),u => c1,u => agy_sh_cid(ids,b))

def x198pw_name(+map: KDef,+role: String) -> String:
  nm(dt(p111v_get(map,role)))

@unsafe
def x198pw_data(+book: List<&2,KDef>,+ty: String,+leaf: String,+node: String) -> Bool:
  +d = lookup(book,ty)
  agy_str_eq(dk(d),"ADT") && U32.is_eq(da(d),0) && U32.is_eq(dx(d),0) && Bool.not(db(d)) &&
    x198pw_layout(dc(d),ty,leaf,node)

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
def agy_zip_wrap_direct(name,symbol,ids,orig,entry):
  +leaf_id = x198pw_cid(nm(dt(entry)),ids)
  +node_id = x198pw_cid(nm(dv(entry)),ids)
  +slow = "agy_zip_slow_" ++ symbol
  nt_choose(X181Output,agy_str_eq(dk(entry),"AgyZipCertified") &&
      x198pw_has_cid(leaf_id,0) && x198pw_has_cid(node_id,3) && U32.is_ne(da(leaf_id),da(node_id)),
    u => x181_program_join(agy_zip_emit_wrapper(symbol,slow,da(leaf_id),da(node_id)),orig),
    u => orig)

@unsafe
def agy_zip_target_sym(name,symbol,ids):
  +entry = agy_zip_get_mark(name,ids)
  +leaf_id = x198pw_cid(nm(dt(entry)),ids)
  +node_id = x198pw_cid(nm(dv(entry)),ids)
  nt_choose(String,agy_str_eq(dk(entry),"AgyZipCertified") &&
      x198pw_has_cid(leaf_id,0) && x198pw_has_cid(node_id,3) && U32.is_ne(da(leaf_id),da(node_id)),
    u => "agy_zip_slow_" ++ symbol,
    u => symbol)



# ============================================================================
# AGY-W2-ROREC: Borrowed Native-Recursion Fast Path for Read-Only ADT->U32
# ============================================================================

# Compact expression encoding in KTerm:
#   kt("RoConst", "", val, 0, [])
#   kt("RoParamX", "", 0, 0, [])
#   kt("RoField", "", field_idx, 0, [])
#   kt("RoRec", "", field_idx, 0, [])
#   kt("RoBin", op, 0, 0, [left, right])
# Case encoding in KTerm:
#   kt("RoCase", ctor_identity, ctor_arity, 0, [expr])
# Plan stored in N111Ids fs under "$agy.rorec/" ++ "$direct." ++ owner:
#   KDef{key, "AgyRoRecCertified", arity, 0, kt("RoCases", "", 0, 0, cases), kt("None", "", 0, 0, []), [], False{}, False{}}

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

@unsafe
def agy_ro_check_cids(cases: List<&2,KTerm>, +ids: N111Ids) -> Bool:
  match cases:
    case Nil{}: True{}
    case Con{+c,rest}:
      +cid = x198pw_cid(nm(c),ids)
      x198pw_has_cid(cid,ix(c)) && agy_ro_check_cids(rest,ids)

@unsafe
def agy_ro_emit_nullary_dispatch(cases: List<&2,KTerm>, +ids: N111Ids, +prefix: String, +idx: U32) -> X188Seq:
  match cases:
    case Nil{}: x188_i1("jmp",X187Target{prefix ++ "_bail"})
    case Con{+c,+rest}:
      nt_choose(X188Seq,U32.is_eq(ix(c),0),
        u => x188_many([
          x188_i2("cmpl",X187Imm{da(x198pw_cid(nm(c),ids)),0},x188_reg(0,32)),
          x188_i1("je",X187Target{prefix ++ "_c" ++ U32.show(idx)}),
          agy_ro_emit_nullary_dispatch(rest,ids,prefix,U32.inc(idx))]),
        u => nt_choose(X188Seq,U32.is_eq(qt(c),1),
          v => x188_many([
            x188_i2("cmpl",X187Imm{da(x198pw_cid(nm(c),ids)),0},x188_reg(0,32)),
            x188_i1("je",X187Target{prefix ++ "_in" ++ U32.show(idx)}),
            agy_ro_emit_nullary_dispatch(rest,ids,prefix,U32.inc(idx))]),
          v => agy_ro_emit_nullary_dispatch(rest,ids,prefix,U32.inc(idx))))

@unsafe
def agy_ro_emit_boxed_dispatch(cases: List<&2,KTerm>, +ids: N111Ids, +prefix: String, +idx: U32) -> X188Seq:
  match cases:
    case Nil{}: x188_i1("jmp",X187Target{prefix ++ "_bail"})
    case Con{+c,+rest}:
      nt_choose(X188Seq,U32.is_gt(ix(c),0),
        u => x188_many([
          x188_i2("cmpl",X187Imm{da(x198pw_cid(nm(c),ids)),0},x188_reg(0,32)),
          x188_i1("je",X187Target{prefix ++ "_c" ++ U32.show(idx)}),
          agy_ro_emit_boxed_dispatch(rest,ids,prefix,U32.inc(idx))]),
        u => agy_ro_emit_boxed_dispatch(rest,ids,prefix,U32.inc(idx)))

@unsafe
def agy_ro_emit_wrapper(+symbol: String, +slow: String, +arity: U32, +cases: List<&2,KTerm>, +ids: N111Ids) -> X181Output:
  +prefix = ".Lagyro_" ++ symbol
  +rec_lbl = prefix ++ "_rec"
  +has_x = U32.is_eq(arity,2)
  # Check mode == 0 and depth == 0:
  # arity 1: rdi=state, rsi=e, rdx=mode, rcx=depth, r8=value
  # arity 2: rdi=state, rsi=e, rdx=x, rcx=mode, r8=depth, r9=value
  +mode_reg = nt_choose(U32,has_x,u => 1,u => 2)
  +depth_reg = nt_choose(U32,has_x,u => 8,u => 1)
  +entry = x188_many([
    x188_i2("cmpq",X187Imm{0,0},x188_reg(mode_reg,64)),
    x188_i1("jne",X187Target{slow}),
    x188_i2("cmpq",X187Imm{0,0},x188_reg(depth_reg,64)),
    x188_i1("jne",X187Target{slow}),
    # Check tag of e (%rsi)
    x188_i2("movq",x188_reg(6,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{56,0},x188_reg(0,64)),
    x188_i2("cmpq",X187Imm{1,0},x188_reg(0,64)),
    x188_i1("je",X187Target{prefix ++ "_null_entry"}),
    x188_i2("cmpq",X187Imm{130,0},x188_reg(0,64)),
    x188_i1("jne",X187Target{slow}),
    # tag == 0x82 (130): check rc >= 2
    x188_i2("movq",X187Mem{7,0},x188_reg(10,64)),
    x188_i2("movabsq",X187Imm{4294967295,255},x188_reg(11,64)),
    x188_i2("andq",x188_reg(6,64),x188_reg(11,64)),
    x188_i2("movq",X187Indexed{10,11,8,0},x188_reg(0,64)),
    x188_i2("andl",X187Imm{16777215,0},x188_reg(0,32)),
    x188_i2("cmpl",X187Imm{2,0},x188_reg(0,32)),
    x188_i1("jb",X187Target{slow}),
    # Save callee-saved regs + state/e/x for possible bailout
    x188_i1("pushq",x188_reg(3,64)),
    x188_i1("pushq",x188_reg(12,64)),
    x188_i1("pushq",x188_reg(13,64)),
    x188_i1("pushq",x188_reg(14,64)),
    x188_i1("pushq",x188_reg(15,64)),
    x188_i1("pushq",x188_reg(7,64)),
    x188_i1("pushq",x188_reg(6,64)),
    x188_i2("movq",x188_reg(10,64),x188_reg(12,64)),
    x188_i2("movq",x188_reg(11,64),x188_reg(15,64)),
    nt_choose(X188Seq,has_x,u => x188_i2("movl",x188_reg(2,32),x188_reg(13,32)),u => X188Empty{}),
    x188_i2("xorl",x188_reg(11,32),x188_reg(11,32)),
    x188_i2("movl",X187Imm{256,0},x188_reg(1,32)),
    x188_i1("call",X187Target{rec_lbl}),
    x188_i2("testl",x188_reg(11,32),x188_reg(11,32)),
    x188_i1("jne",X187Target{prefix ++ "_miss"}),
    # Success! Decrement root refcount by 1
    x188_i2("movq",X187Indexed{12,15,8,0},x188_reg(10,64)),
    x188_i2("subq",X187Imm{1,0},x188_reg(10,64)),
    x188_i2("movq",x188_reg(10,64),X187Indexed{12,15,8,0}),
    x188_i2("movl",x188_reg(0,32),x188_reg(0,32)),
    x188_i2("addq",X187Imm{16,0},x188_reg(4,64)),
    x188_i1("popq",x188_reg(15,64)),
    x188_i1("popq",x188_reg(14,64)),
    x188_i1("popq",x188_reg(13,64)),
    x188_i1("popq",x188_reg(12,64)),
    x188_i1("popq",x188_reg(3,64)),
    x188_i0("ret"),
    # Nullary entry (tag == 1): no refcount to decrement
    x188_label(prefix ++ "_null_entry"),
    x188_i1("pushq",x188_reg(3,64)),
    x188_i1("pushq",x188_reg(12,64)),
    x188_i1("pushq",x188_reg(13,64)),
    x188_i1("pushq",x188_reg(14,64)),
    x188_i1("pushq",x188_reg(15,64)),
    x188_i1("pushq",x188_reg(7,64)),
    x188_i1("pushq",x188_reg(6,64)),
    x188_i2("movq",X187Mem{7,0},x188_reg(12,64)),
    nt_choose(X188Seq,has_x,u => x188_i2("movl",x188_reg(2,32),x188_reg(13,32)),u => X188Empty{}),
    x188_i2("xorl",x188_reg(11,32),x188_reg(11,32)),
    x188_i2("movl",X187Imm{256,0},x188_reg(1,32)),
    x188_i1("call",X187Target{rec_lbl}),
    x188_i2("testl",x188_reg(11,32),x188_reg(11,32)),
    x188_i1("jne",X187Target{prefix ++ "_miss"}),
    x188_i2("movl",x188_reg(0,32),x188_reg(0,32)),
    x188_i2("addq",X187Imm{16,0},x188_reg(4,64)),
    x188_i1("popq",x188_reg(15,64)),
    x188_i1("popq",x188_reg(14,64)),
    x188_i1("popq",x188_reg(13,64)),
    x188_i1("popq",x188_reg(12,64)),
    x188_i1("popq",x188_reg(3,64)),
    x188_i0("ret"),
    # Miss / bailout: restore all incoming registers and jump to slow
    x188_label(prefix ++ "_miss"),
    x188_i1("popq",x188_reg(6,64)),
    x188_i1("popq",x188_reg(7,64)),
    nt_choose(X188Seq,has_x,
      u => x188_many([
        x188_i2("movl",x188_reg(13,32),x188_reg(2,32)),
        x188_i2("xorl",x188_reg(1,32),x188_reg(1,32)),
        x188_i2("xorl",x188_reg(8,32),x188_reg(8,32)),
        x188_i2("xorl",x188_reg(9,32),x188_reg(9,32))]),
      u => x188_many([
        x188_i2("xorl",x188_reg(2,32),x188_reg(2,32)),
        x188_i2("xorl",x188_reg(1,32),x188_reg(1,32)),
        x188_i2("xorl",x188_reg(8,32),x188_reg(8,32))])),
    x188_i1("popq",x188_reg(15,64)),
    x188_i1("popq",x188_reg(14,64)),
    x188_i1("popq",x188_reg(13,64)),
    x188_i1("popq",x188_reg(12,64)),
    x188_i1("popq",x188_reg(3,64)),
    x188_i1("jmp",X187Target{slow}),
    # Internal recursive helper
    x188_label(rec_lbl),
    x188_i2("testl",x188_reg(1,32),x188_reg(1,32)),
    x188_i1("je",X187Target{prefix ++ "_bail"}),
    x188_i2("movq",x188_reg(6,64),x188_reg(9,64)),
    x188_i2("shrq",X187Imm{56,0},x188_reg(9,64)),
    x188_i2("movq",x188_reg(6,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{40,0},x188_reg(0,64)),
    x188_i2("andl",X187Imm{65535,0},x188_reg(0,32)),
    x188_i2("cmpq",X187Imm{1,0},x188_reg(9,64)),
    x188_i1("je",X187Target{prefix ++ "_null"}),
    x188_i2("movabsq",X187Imm{4294967295,255},x188_reg(8,64)),
    x188_i2("andq",x188_reg(6,64),x188_reg(8,64)),
    x188_i2("cmpq",X187Imm{2,0},x188_reg(9,64)),
    x188_i1("je",X187Target{prefix ++ "_boxed"}),
    x188_i2("cmpq",X187Imm{130,0},x188_reg(9,64)),
    x188_i1("jne",X187Target{prefix ++ "_bail"}),
    x188_i2("movq",X187Indexed{12,8,8,0},x188_reg(8,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(8,64)),
    x188_label(prefix ++ "_boxed"),
    agy_ro_emit_boxed_dispatch(cases,ids,prefix,0),
    x188_label(prefix ++ "_null"),
    agy_ro_emit_nullary_dispatch(cases,ids,prefix,0),
    agy_ro_emit_arms(cases,prefix,0),
    x188_label(prefix ++ "_bail"),
    x188_i2("movl",X187Imm{1,0},x188_reg(11,32)),
    x188_i0("ret")])
  X181Output{[x188_many([
    X188One{PSection{1}},X188One{PGlobal{symbol}},X188One{PType{symbol,2}},X188One{PLabel{symbol}},
    entry,X188One{PSize{symbol}}])],""}

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
def agy_al_is_match(+name: String, +params: List<&2,String>, +ids: N111Ids) -> Bool:
  agy_bp_has_mark(ids,"$agy.bp/arr") &&
  (agy_str_eq(name,"$direct.Array.to_list.go~0") || agy_str_eq(name,"Array.to_list.go~0")) &&
  U32.is_eq(nt_count(String,params),6) &&
  U32.is_lt(agy_al_ctor_id(ids,"Con"),65536)

# Fast path for p114r_$direct.Array.to_list.go~0(st=%rdi, a=%rsi, acc=%rdx, mode=%rcx, depth=%r8, val=%r9)
@unsafe
def x181_program_symbol(+symbol: String, +available: KDef) -> String:
  nt_choose(String,String.starts_with(symbol,"p112w_"),
    u => nt_choose(String,agy_str_eq(dk(p111v_get(available,symbol)),"X181Forward"),
      v => "",v => "x86 unavailable legacy worker: " ++ symbol),u => "")

@unsafe
def x181_program_value(value: N111Value, +available: KDef) -> String:
  match value:
    case N111Symbol{symbol}: x181_program_symbol(symbol,available)
    case _: ""

@unsafe
def x181_forward_selected(+name: String, +ready: KDef) -> Bool:
  +entry = p111v_get(ready,name)
  agy_str_eq(dk(entry),"P112Worker") && U32.is_eq(dx(entry),0)

@unsafe
def x181_forward(+function: P113DFunction, +ready: KDef) -> X181Output:
  match function:
    case P113DFunction{+name,+params,+result,public,body}:
      nt_choose(X181Output,x181_forward_selected(name,ready),
        u => nt_choose(X181Output,U32.is_eq(result,1) &&
            U32.is_eq(da(p111v_get(ready,name)),nt_count(NC_Binding,params)),
          v => X181Output{[x188_many([X188One{PSection{1}},X188One{PType{p112w_symbol(name),2}},
            x188_label(p112w_symbol(name)),x188_i1("jmp",X187Target{p113e_symbol(name)}),
            X188One{PSize{p112w_symbol(name)}}])],""},
          v => X181Output{[],"x86 imported worker signature mismatch: " ++ name}),
        u => X181Output{[],""})

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
def x199s_again(values: List<&2,N111Value>, state: X199ScanState) -> Bool:
  match values state:
    case Con{a,Con{b,Con{c,Con{d,Nil{}}}}} X199ScanState{+env,+loads,+stores}:
      U32.is_eq(loads,1) && U32.is_eq(stores,1) && U32.is_eq(x199s_token(a,env),10) &&
        U32.is_eq(x199s_token(b,env),12) && U32.is_eq(x199s_token(c,env),3) && U32.is_eq(x199s_token(d,env),18)
    case _ _: False{}

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

@unsafe
def agy_dp_again(values: List<&2,N111Value>, a: String, b: String, p: String, c: String, state: AgyDpState) -> Bool:
  match values state:
    case Con{v0,Con{v1,Con{v2,Con{v3,Con{v4,Con{v5,Con{v6,Nil{}}}}}}}} AgyDpState{+env,+stores}:
      U32.is_eq(stores,1) &&
      U32.is_eq(agy_dp_tok(v0,env),10) &&
      U32.is_eq(agy_dp_tok(v1,env),13) &&
      agy_dp_is_ai(agy_dp_tok(v2,env)) &&
      x185_sf_source(v3,a) && x185_sf_source(v4,b) &&
      x185_sf_source(v5,p) && x185_sf_source(v6,c)
    case _ _: False{}

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
def agy_f32_again(values: List<&2,N111Value>, st: AgyF32State) -> AgyF32Plan:
  match values st:
    case Con{v0,Con{v1,Con{v2,Nil{}}}} AgyF32State{+env,s0,s8,obs,has_obs}:
      nt_choose(AgyF32Plan,agy_f32_val_fuel(v0,env,"FuelSub"),
        u => agy_f32_finish_again(agy_f32_val_f(v1,env),agy_f32_val_u(v2,env),obs),
        u => AgyF32No{})
    case _ _: AgyF32No{}

@unsafe
def agy_map_has_ctors(+ids: N111Ids) -> Bool:
  U32.is_lt(agy_map_ctor_id(ids,"MTip"),65536) &&
  U32.is_lt(agy_map_ctor_id(ids,"MLeaf"),65536) &&
  U32.is_lt(agy_map_ctor_id(ids,"MNode"),65536) &&
  U32.is_lt(agy_map_ctor_id(ids,"SNil"),65536) &&
  U32.is_lt(agy_map_ctor_id(ids,"SCon"),65536) &&
  U32.is_lt(agy_map_ctor_id(ids,"Tuple"),65536)

@unsafe
def agy_map_kind(segment: N111Segment, +ids: N111Ids) -> U32:
  match segment:
    case N111Segment{+name,+arity,+result,incoming,flags,+body}:
      nt_choose(U32,agy_bp_has_mark(ids,"$agy.bp/map") && U32.is_eq(arity,3) && U32.is_eq(result,1) && agy_map_has_ctors(ids),u =>
        nt_choose(U32,(agy_str_eq(name,"$direct.Map.get") || agy_str_eq(name,"Map.get")) &&
          agy_map_stmts_has_ctor(body,"MTip") && agy_map_stmts_has_ctor(body,"MLeaf") &&
          agy_map_stmts_has_ctor(body,"MNode"),
          v => 1,v =>
        nt_choose(U32,(agy_str_eq(name,"$direct.Map.set") || agy_str_eq(name,"Map.set")) &&
          agy_map_stmts_has_func(body,"Map.seek"),
          w => 2,w => 0)),
        u => 0)

# Shared inline map_bit sequence:
# Inputs: %r13 = heap, %rdi = pos (u64 Nat), key_reg = key (String), %rsi = preserved (MNode loc)
# Clobbers: %rax (temp), %rcx, %rdx, %r8, %r9, %rdi
# Branches to l_bit0 (bit=0), l_bit1 (bit=1), or l_bail (unexpected tag / pos >= 2^32)
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
def agy_bp_list(+book: List<&2,KDef>, names: List<&2,String>, +h: U32) -> U32:
  match names:
    case Nil{}: h
    case Con{n,rest}:
      +h1 = agy_bp_def(book,n,h)
      nt_choose(U32,U32.is_eq(h1,0),u => 0,u => agy_bp_list(book,rest,h1))

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
def agy_sh_def_pin(+book: List<&2,KDef>, +name: String, +h1: U32, +h2: U32) -> Bool:
  U32.is_eq(agy_sh_def_hash(book,name,2166136261),h1) &&
  U32.is_eq(agy_sh_def_hash(book,name,33554467),h2)

@unsafe
def agy_sh_str_adts_ok(+book: List<&2,KDef>) -> Bool:
  agy_map_has_ctor(book,"String","SNil",0) &&
  agy_map_has_ctor(book,"String","SCon",2) &&
  agy_map_has_ctor(book,"Char","Chr",1) &&
  agy_map_has_ctor(book,"Bool","False",0) &&
  agy_map_has_ctor(book,"Bool","True",0)

@unsafe
def agy_sh_kterm_adt_ok(+book: List<&2,KDef>) -> Bool:
  agy_map_has_ctor(book,"KTerm","KTerm",8) &&
  agy_map_has_ctor(book,"KTerm","KLambda",8) &&
  agy_map_has_ctor(book,"KTerm","KLiteral",5)

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
def x181_program_data_items(items: List<&2,P111QDatum>, +available: KDef, acc: List<&2,X188Seq>) -> X181Output:
  match items:
    case Nil{}: X181Output{nt_reverse(X188Seq,acc,[]),""}
    case Con{+head,rest}:
      x181_program_data_item(head,rest,available,acc)

@unsafe
def x181_program_data_item(+item: P111QDatum, rest: List<&2,P111QDatum>, +available: KDef, acc: List<&2,X188Seq>) -> X181Output:
  match item:
    case P111QReloc{+symbol,offset}:
      nt_choose(X181Output,String.is_empty(x181_program_symbol(symbol,available)),
        u => x181_program_data_items(rest,available,Con{x181_program_datum(item),acc}),
        u => X181Output{[],x181_program_symbol(symbol,available)})
    case _: x181_program_data_items(rest,available,Con{x181_program_datum(item),acc})

@unsafe
def x181_stream_datum_error(item: P111QDatum, +available: KDef) -> String:
  match item:
    case P111QReloc{symbol,offset}: x181_program_symbol(symbol,available)
    case _: ""

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

@unsafe
def x187_e_selected(spec: X187Op, operands: List<&2,X187Operand>, offset: U32) -> X187Encoded:
  match spec operands:
    case X187Op{14,width,code,extra,prefix} Nil{}: x187_e_ok([195])
    case X187Op{family,width,code,extra,prefix} Con{operand,Nil{}}: x187_e_single(operand,family,width,code,extra,offset)
    case X187Op{family,width,code,extra,prefix} Con{src,Con{dst,Nil{}}}: x187_e_pair(src,dst,family,width,code,extra,prefix,offset)
    case _ _: x187_e_error()

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
def x187_elf_relocs_valid(items: List<&2,X187Relocation>, +sizes: X187ElfSizes, +index: KDef, +count: U32) -> Bool:
  match items:
    case Nil{}: True{}
    case Con{head,rest}:
      nt_choose(Bool,U32.is_lt(count,1048576) && x187_elf_reloc_valid(head,sizes,index),
        u => x187_elf_relocs_valid(rest,sizes,index,U32.inc(count)),u => False{})

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

@unsafe
def w7_elf_sections_fast(object: X187Object, sizes: X187ElfSizes, symbols: X187ElfSymbols) -> X187ObjectResult:
  match object sizes symbols:
    case X187Object{text,rodata,data,items,relocations}
         X187ElfSizes{+ts,+rs,+ds}
         X187ElfSymbols{+index,+count,+firstGlobal,table,strings,+stringSize,error}:
      w7_elf_sections_emit(text,rodata,data,ts,rs,ds,count,firstGlobal,table,strings,stringSize,
        w7_relocs_part(relocations,index,[],0,[],0,[],0))

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
def x187_elf_checked(+object: X187Object, +sizes: X187ElfSizes, +symbols: X187ElfSymbols) -> X187ObjectResult:
  match object sizes symbols:
    case X187Object{text,rodata,data,items,relocations}
         X187ElfSizes{+ts,+rs,+ds}
         X187ElfSymbols{+index,+count,+firstGlobal,table,strings,+stringSize,+error}:
      nt_choose(X187ObjectResult,String.is_empty(error),
        u => w7c_elf_checked_go(text,rodata,data,ts,rs,ds,count,firstGlobal,table,strings,stringSize,
          w7c_relocs_fused(relocations,sizes,index,0,[],0,[],0,[],0)),
        u => X187ObjectResult{[],error})

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
def agy_p114h_filter_segs(segs: List<&2,N111Segment>, +direct: KDef, +acc: List<&2,N111Segment>) -> List<&2,N111Segment>:
  match segs:
    case Nil{}: nt_reverse(N111Segment,acc,[])
    case Con{+seg,+rest}:
      agy_p114h_filter_segs(rest,direct,nt_choose(List<&2,N111Segment>,agy_p114h_seg_eligible(seg,direct,missing()),
        u => Con{seg,acc},u => acc))

@unsafe
def x202p_x187_elf_sections(object: X187Object, symbols: X187ElfSymbols, rawSizes: X187ElfSizes) -> IO(U32):
  match object symbols:
    case X187Object{text,rodata,data,items,+relocations}
      X187ElfSymbols{+index,count,firstGlobal,table,strings,stringSize,error}:
      +sectionNames = nt_reverse(U32,x187_elf_ascii(
          "\0.text\0.rodata\0.data\0.rela.text\0.rela.rodata\0.rela.data\0.symtab\0.strtab\0.shstrtab\0.note.GNU-stack\0",[]),[])
      x202t_plan([
        X187ElfSection{1,1,6,16,0,0,0,text},
        X187ElfSection{7,1,2,8,0,0,0,rodata},
        X187ElfSection{15,1,3,8,0,0,0,data},
        X187ElfSection{21,4,0,8,24,7,1,x187_elf_relocs(relocations,1,index,[])},
        X187ElfSection{32,4,0,8,24,7,2,x187_elf_relocs(relocations,2,index,[])},
        X187ElfSection{45,4,0,8,24,7,3,x187_elf_relocs(relocations,3,index,[])},
        X187ElfSection{56,2,0,8,24,8,firstGlobal,nt_reverse(U32,table,[])},
        X187ElfSection{64,3,0,1,0,0,0,nt_reverse(U32,strings,[])},
        X187ElfSection{72,3,0,1,0,0,0,sectionNames},
        X187ElfSection{82,1,0,1,0,0,0,[]}],x202t_sizes(rawSizes,x202t_rela_counts(relocations,0,0,0),count,stringSize,nt_count(U32,sectionNames)),64,[],x187_elf_zero(64,[]))

@unsafe
def x202p_x187_elf_checked(+object: X187Object, +sizes: X187ElfSizes, +symbols: X187ElfSymbols) -> IO(U32):
  match object sizes symbols:
    case X187Object{text,rodata,data,items,relocations}
      X187ElfSizes{+ts,+rs,+ds}
      X187ElfSymbols{+index,+count,+firstGlobal,table,strings,+stringSize,+error}:
      nt_choose(IO(U32),String.is_empty(error),
        u => w10f_x202p_elf_emit(text,rodata,data,ts,rs,ds,count,firstGlobal,table,strings,stringSize,
          w7c_relocs_fused(relocations,sizes,index,0,[],0,[],0,[],0)),
        u => IO.die(U32,1,error))

@unsafe
def w10_merge_main(+entry_mod: String, +first_mod: String, +mods: List<&1,String>) -> X188Seq:
  +entry_sym = "p111_mod_" ++ entry_mod ++ "_program"
  x188_many([
    X188One{PSection{1}},
    X188One{PAlign{16}},
    X188One{PGlobal{"main"}},
    X188One{PType{"main",2}},
    x188_label("main"),
    w10_merge_copy_root(first_mod),
    x188_i2("xorl",x188_reg(11,32),x188_reg(11,32)),
    w10_merge_totals(mods,0),
    w10_merge_fill_sentinel(),
    w10_merge_copies(mods,0),
    x188_i2("leaq",X187Rip{"p111_program",0,0},x188_reg(2,64)),
    x188_i2("movq",x188_reg(11,64),X187Mem{2,16}),
    x188_i2("leaq",X187Rip{entry_sym,0,0},x188_reg(8,64)),
    x188_i2("movq",X187Mem{8,32},x188_reg(0,64)),
    x188_i2("movq",x188_reg(0,64),X187Mem{2,32}),
    x188_i2("leaq",X187Rip{"w8_merged_segments",0,0},x188_reg(0,64)),
    x188_i2("movq",x188_reg(0,64),X187Mem{2,96}),
    x188_i2("leaq",X187Rip{"w8_merged_fid_arity",0,0},x188_reg(0,64)),
    x188_i2("movq",x188_reg(0,64),X187Mem{2,104}),
    x188_i2("leaq",X187Rip{"w8_merged_fid_flags",0,0},x188_reg(0,64)),
    x188_i2("movq",x188_reg(0,64),X187Mem{2,112}),
    x188_i2("leaq",X187Rip{"w8_merged_fid_results",0,0},x188_reg(0,64)),
    x188_i2("movq",x188_reg(0,64),X187Mem{2,120}),
    x188_i1("jmp",X187Target{"p111_rt_main"}),
    x188_label(".Lm_overflow"),
    x188_i2("movl",X187Imm{2,0},x188_reg(0,32)),
    x188_i0("ret"),
    X188One{PSize{"main"}}])

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
def w11_seg_not_weak(+segment: N111Segment, +weak_set: KDef) -> Bool:
  match segment:
    case N111Segment{+name,arity,result,incoming,flags,body}:
      Bool.not(w10_is_weak_sym(weak_set,p111q_symbol(name)))

@unsafe
def w10f_elf_checked_go(text_rev: List<&2,U32>, rodata_rev: List<&2,U32>, data_rev: List<&2,U32>,
    plan: List<&2,X187Relocation>, +ts: U32, +rs: U32, +ds: U32, +count: U32, +firstGlobal: U32,
    table: List<&2,U32>, strings: List<&2,U32>, +stringSize: U32, rr: W7cRelocResult) -> X187ObjectResult:
  match rr:
    case W7cRelocOk{rp}: w10f_elf_sections_emit_rev(text_rev,rodata_rev,data_rev,plan,ts,rs,ds,count,firstGlobal,table,strings,stringSize,rp)
    case W7cRelocBad{}: X187ObjectResult{[],"invalid ELF relocation"}

@unsafe
def w10f_elf_checked_rev(text_rev: List<&2,U32>, rodata_rev: List<&2,U32>, data_rev: List<&2,U32>,
    plan: List<&2,X187Relocation>, relocations: List<&2,X187Relocation>,
    +sizes: X187ElfSizes, +symbols: X187ElfSymbols) -> X187ObjectResult:
  match sizes symbols:
    case X187ElfSizes{+ts,+rs,+ds}
         X187ElfSymbols{+index,+count,+firstGlobal,table,strings,+stringSize,+error}:
      nt_choose(X187ObjectResult,String.is_empty(error),
        u => w10f_elf_checked_go(text_rev,rodata_rev,data_rev,plan,ts,rs,ds,count,firstGlobal,table,strings,stringSize,
          w7c_relocs_fused(relocations,sizes,index,0,[],0,[],0,[],0)),
        u => X187ObjectResult{[],error})

@unsafe
def w10_if_abi_has(+idx: KDef, +key: String) -> Bool:
  Bool.not(agy_str_eq(dk(p111v_get(idx, key)), "Absent"))

@unsafe
def w10_if_force_cps(+abi: W10IfAbi, +name: String) -> Bool:
  match abi:
    case W10IfAbi{+direct, +public}:
      +key = "$direct." ++ name
      w10_if_abi_has(public, key) && Bool.not(w10_if_abi_has(direct, key))

