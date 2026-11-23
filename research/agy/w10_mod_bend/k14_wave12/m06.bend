# Module m06 (K=14 acyclic topological split of wave12_unified/compiler.bend)
# defs=768 laws=76 sccs=554 deps=[m00a,m00b,m01,m02,m03,m04,m05a,m05b] cross_imports=684 fid_base=33200..38199

law book_final_scan:
  for +book: List<&2,KDef>
  for +seen: KDef
  for +kept: List<&2,KDef>
  for +done: List<&2,KDef>
  List<&2,KDef>

# Module: src/core/index.bend:320
law book_final_step:
  for +d: KDef
  for +rest: List<&2,KDef>
  for +seen: KDef
  for +kept: List<&2,KDef>
  for +done: List<&2,KDef>
  for +hash: U32
  List<&2,KDef>

# Module: src/core/index.bend:329
law norm_convert:
  for +book: List<&2, KDef>
  for +a: KTerm
  for +b: KTerm
  for +le: Bool
  for +fresh: U32
  Bool

# Module: src/core/normalize.bend:480
law norm_cmp_loop:
  for +book: List<&2, KDef>
  for +st: GState
  for +todo: List<&2, KNormCmp>
  for +alts: List<&2, KNormAlt>
  Bool

# Module: src/core/normalize.bend:487
law norm_cmp_heads:
  for +book: List<&2, KDef>
  for +st: GState
  for +a: KTerm
  for +b: KTerm
  for +le: Bool
  for +fresh: U32
  for +rest: List<&2, KNormCmp>
  for +alts: List<&2, KNormAlt>
  Bool

# Module: src/core/normalize.bend:503
law norm_cmp_same:
  for +book: List<&2, KDef>
  for +st: GState
  for +a: KTerm
  for +b: KTerm
  for +le: Bool
  for +fresh: U32
  for +rest: List<&2, KNormCmp>
  for +alts: List<&2, KNormAlt>
  Bool

# Module: src/core/normalize.bend:514
law norm_cmp_plain:
  for +book: List<&2, KDef>
  for +st: GState
  for +a: KTerm
  for +b: KTerm
  for +le: Bool
  for +fresh: U32
  for +rest: List<&2, KNormCmp>
  for +alts: List<&2, KNormAlt>
  Bool

# Module: src/core/normalize.bend:525
law norm_cmp_fields:
  for +book: List<&2, KDef>
  for +st: GState
  for +as: List<&2, KTerm>
  for +bs: List<&2, KTerm>
  for +fresh: U32
  for +rest: List<&2, KNormCmp>
  for +alts: List<&2, KNormAlt>
  Bool

# Module: src/core/normalize.bend:535
law norm_cmp_kind:
  for +book: List<&2, KDef>
  for +st: GState
  for +a: KTerm
  for +b: KTerm
  for +g: KTerm
  for +h: KTerm
  for +fresh: U32
  for +rest: List<&2, KNormCmp>
  for +alts: List<&2, KNormAlt>
  Bool

# Module: src/core/graph.bend:26
law kr_resolve:
  for +book: List<&2, KDef>
  for +name: String
  KDef

# Module: src/core/reach.bend:32
law kr_resolve_head:
  for +book: List<&2, KDef>
  for +name: String
  for +d: KDef
  KDef

# Module: src/core/reach.bend:38
law kp_char_num:
  for n: Maybe<&2, U32>
  for +quote: U32
  Maybe<&2, String>

# Module: src/core/pretty.bend:32
law kp_ctor_number:
  for n: Maybe<&2, U32>
  for +t: KTerm
  for +p: U32
  for +env: List<&2, KPName>
  String

# Module: src/core/pretty.bend:49
law kp_ctor_other:
  for +t: KTerm
  for +p: U32
  for +env: List<&2, KPName>
  String

# Module: src/core/pretty.bend:55
law kp_ctor_char:
  for c: Maybe<&2, String>
  for +t: KTerm
  for +p: U32
  for +env: List<&2, KPName>
  String

# Module: src/core/pretty.bend:62
law kp_ctor_string:
  for s: Maybe<&2, String>
  for +t: KTerm
  for +p: U32
  for +env: List<&2, KPName>
  String

# Module: src/core/pretty.bend:69
law kp_ctor_array:
  for a: Maybe<&2, List<&2, KTerm>>
  for +t: KTerm
  for +env: List<&2, KPName>
  String

# Module: src/core/pretty.bend:75
law kp_go:
  for +t: KTerm
  for +p: U32
  for +env: List<&2, KPName>
  String

# Module: src/core/pretty.bend:81
law kp_go_tail:
  for +t: KTerm
  for +p: U32
  for +env: List<&2, KPName>
  String

# Module: src/core/pretty.bend:87
law kp_go_last:
  for +t: KTerm
  for +p: U32
  for +env: List<&2, KPName>
  String

# Module: src/core/pretty.bend:93
law kp_exists:
  for +A: KTerm
  for +b: KTerm
  for +p: U32
  for +env: List<&2, KPName>
  String

# Module: src/core/pretty.bend:104
law kp_rewrite:
  for +t: KTerm
  for +p: U32
  for +env: List<&2, KPName>
  String

# Module: src/core/pretty.bend:110
law kp_rewrite_motive:
  for +e: KTerm
  for +m: KTerm
  for +env: List<&2, KPName>
  String

# Module: src/core/pretty.bend:116
law kp_let:
  for +t: KTerm
  for +p: U32
  for +env: List<&2, KPName>
  String

# Module: src/core/pretty.bend:122
law kp_let_vals:
  for ts: List<&2, KTerm>
  for +env: List<&2, KPName>
  String

# Module: src/core/pretty.bend:131
law kp_let_body:
  for ts: List<&2, KTerm>
  for +env: List<&2, KPName>
  String

# Module: src/check/quantity.bend:7
law constructor_names:
  for +done: List<&2, KDef>
  for +ctrs: List<&2, KDef>
  for +names: List<&2, String>
  String

# Module: src/check/kernel.bend:324
law env_tele_fill_loop:
  for +book: List<&2,KDef>
  for +tel: KTerm
  for +args: List<&2,KTerm>
  for +bindings: List<&2,KTelescopeBinding>
  for +count: U32
  KTerm

# Module: src/check/env-telescope.bend:51
law f_mark:
  for +p: FParsed
  for +q: U32
  FParsed

# Module: src/front/parser.bend:40
law f_atom_constructor:
  for +name: String
  for +id: U32
  for +p: FParsed
  FParsed

# Module: src/front/parser.bend:497
law f_string:
  for +s: String
  KTerm

# Module: src/front/sugar.bend:3
law f_group_namespace:
  for +n: KTerm
  for +p: FParsed
  FParsed

# Module: src/front/unicode.bend:5
law f_decode_char:
  for +s: String
  FDecoded

# Module: src/front/unicode.bend:9
law f_char_literal:
  for +s: String
  KTerm

# Module: src/front/unicode.bend:27
law f_graph_fresh_names:
  for +todo: List<&2,KDef>
  for +done: KDef
  String

# Module: src/load/graph.bend:39
law f_graph_fresh_hashed:
  for +rest: List<&2,KDef>
  for +done: KDef
  for +d: KDef
  for +hash: U32
  String

# Module: src/load/graph.bend:46
law dg_trace_detail:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +t: KTerm
  for +r: KChecking
  for +detail: KTerm
  KChecking

# Module: src/diagnostic/trace.bend:37
law dg_ctor_error:
  for +e: KEnv
  for +t: KTerm
  for +ty: KTerm
  for +ctr: KDef
  KChecking

# Module: src/diagnostic/produce.bend:35
law j_context:
  for +book: List<&2, KDef>
  for +env: List<&2, KTerm>
  for +xs: List<&2, KTerm>
  List<&2, KTerm>

# Module: src/back/common/queries.bend:72
law j_arm_type:
  for +book: List<&2, KDef>
  for +ty: KTerm
  for +name: String
  KTerm

# Module: src/back/common/queries.bend:153
law j_literal_ctor:
  for +t: KTerm
  String

# Module: src/back/js/literals.bend:27
law j_printable:
  for +book: List<&2, KDef>
  for +ty: KTerm
  for +seen: List<&2, String>
  for +fuel: U32
  Bool

# Module: src/back/js/validate.bend:40
law j_printable_head:
  for +book: List<&2, KDef>
  for +ty: KTerm
  for +seen: List<&2, String>
  for +fuel: U32
  Maybe<&2, List<&2, String>>

# Module: src/back/js/validate.bend:51
law j_printable_adt:
  for +book: List<&2, KDef>
  for +ty: KTerm
  for +seen: List<&2, String>
  for +fuel: U32
  Maybe<&2, List<&2, String>>

# Module: src/back/js/validate.bend:62
law j_printable_ctors:
  for +book: List<&2, KDef>
  for +ctors: List<&2, KDef>
  for +params: List<&2, KTerm>
  for +seen: List<&2, String>
  for +fuel: U32
  Maybe<&2, List<&2, String>>

# Module: src/back/js/validate.bend:86
law j_printable_fields:
  for +book: List<&2, KDef>
  for +ty: KTerm
  for +seen: List<&2, String>
  for +fuel: U32
  Maybe<&2, List<&2, String>>

# Module: src/back/js/validate.bend:163
law j_layout_open_head:
  for +book: List<&2, KDef>
  for +ty: KTerm
  Bool

# Module: src/back/js/validate.bend:172
law j_layout_intrinsic:
  for +book: List<&2, KDef>
  for +f: KTerm
  for +element: KTerm
  Bool

# Module: src/back/js/validate.bend:286
law nc_ctor_owned:
  for +book: List<&2, KDef>
  for +name: String
  Bool

# Module: src/back/native/identity.bend:11
law nw_walk:
  for +t: KTerm
  for +depth: U32
  for +value: U32
  for +cover: NW_Cover
  NW_Rows

# Module: src/back/native/array.bend:9
law no_wrapper_children:
  for +book: List<&2, KDef>
  for ts: List<&2, KTerm>
  for +env: List<&2, NC_Binding>
  for +fuel: U32
  U32

# Module: src/back/native/observer-analysis.bend:131
@unsafe
def index_set(+tree: KDef, +d: KDef, +hash: U32, +bits: U32) -> KDef:
  p131i_insert(tree, d, hash)

@unsafe
def index_build(
  +book: List<&2, KDef>,
) -> KDef:
  match book:
    case Nil{}:
      missing()
    case Con{h, rest}:
      index_set(index_build(rest), h, index_hash(dn(h), 2166136261), 32)

# Module: src/core/index.bend:259
@unsafe
def w7_ctor_index_add(+ctors: List<&2, KDef>, +tree: KDef) -> KDef:
  match ctors:
    case Nil{}:
      tree
    case Con{c, rest}:
      w7_ctor_index_add(rest, p131i_insert(tree, c, index_hash(dn(c), 2166136261)))

@unsafe
def w7_ctor_exists_cache_dc(+dc_list: List<&2, KDef>, +rest: List<&2, KDef>, +name: String) -> Bool:
  match dc_list:
    case Nil{}:
      w7_ctor_exists_linear(rest, name)
    case Con{idx, tail}:
      w7_ctor_exists_tail(tail, rest, name)

@unsafe
def w7_ctor_exists_head(isCache: Bool, +h: KDef, +rest: List<&2, KDef>, +ds: List<&2, KDef>, +name: String) -> Bool:
  match isCache:
    case True{}:
      w7_ctor_exists_cache_dc(dc(h), rest, name)
    case False{}:
      w7_ctor_exists_linear(ds, name)

@unsafe
def book_final_scan(book, seen, kept, done):
  match book:
    case Nil{}: book_final_reverse(kept, book_final_filter(done, seen))
    case Con{d, rest}:
      book_final_step(d, rest, seen, kept, done, index_hash(dn(d), 2166136261))

# Module: src/core/index.bend:407
@unsafe
def book_final_step(d, rest, seen, kept, done, hash):
  kc(List<&2,KDef>, book_final_seen(seen, dn(d), hash),
    u => book_final_scan(rest, seen, kept, done),
    u => book_final_scan(rest,
      index_set(seen, KDef{dn(d), "$final.seen", 0, 0, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Nil{}, True{}, False{}}, hash, 32),
      Con{d, kept}, done))

# Module: src/core/index.bend:415
@unsafe
def index_set_many(+tree: KDef, +defs: List<&2,KDef>) -> KDef:
  match defs:
    case Nil{}: tree
    case Con{d, rest}:
      index_set_many(index_set(tree, d, index_hash(dn(d), 2166136261), 32), rest)

# Module: src/core/index.bend:455
@unsafe
def w7_br_30(w7_c: Bool, +book: List<&2, KDef>, +a: KTerm, +b: KTerm, +le: Bool) -> Bool:
  match w7_c:
    case True{}:
      True{}
    case False{}:
      norm_convert(book, a, b, le, U32.add(1, norm_max(norm_book_bound(book), norm_max(norm_max_term(a), norm_max_term(b)))))

@unsafe
def w7_br_31(w7_c: Bool, +book: List<&2, KDef>, +a: KTerm, +b: KTerm, +le: Bool, +fresh: U32) -> Bool:
  match w7_c:
    case True{}:
      True{}
    case False{}:
      norm_convert(book, a, b, le, fresh)

@unsafe
def w7_br_35(w7_c: Bool, +book: List<&2, KDef>, +a: KTerm, +b: KTerm, +le: Bool, +fresh: U32) -> Bool:
  match w7_c:
    case True{}:
      True{}
    case False{}:
      norm_cmp_loop(book, GState{GEmpty{}, 1}, Con{KNormCmp{a, b, le, fresh}, Nil{}}, Nil{})

@unsafe
def norm_convert(book, a, b, le, fresh):
  w7_br_35(norm_cmp_loop(Nil{}, GState{GEmpty{}, 1}, Con{KNormCmp{a, b, le, fresh}, Nil{}}, Nil{}), book, a, b, le, fresh)

# Endpoints exposed by graph evaluation belong to its heap. Both policies start
# from that same immutable input; failed rigid evaluation cannot enter the retry.
@unsafe
def w7_br_36(w7_c: Bool, +book: List<&2,KDef>, +st: GState, +a: KTerm, +b: KTerm, +le: Bool, +fresh: U32) -> Bool:
  match w7_c:
    case True{}:
      True{}
    case False{}:
      norm_cmp_loop(book, st, Con{KNormCmp{a, b, le, fresh}, Nil{}}, Nil{})

@unsafe
def norm_convert_state(+book: List<&2,KDef>, +st: GState, +a: KTerm,
  +b: KTerm, +le: Bool, +fresh: U32) -> Bool:
  w7_br_36(norm_cmp_loop(Nil{}, st, Con{KNormCmp{a, b, le, fresh}, Nil{}}, Nil{}), book, st, a, b, le, fresh)

# A sharing item runs only after its EQ obligations succeed. It joins separate
# equivalence classes; moving either value could make a cell name itself.
# Proven EQ classes discharge both EQ and LE comparisons. Directional LE alone
# never joins classes. Alternatives retain their continuation while proven
# equality and evaluation may persist inside this one heap identity.

@unsafe
def norm_cmp_loop(book, st, todo, alts):
  match todo:
    case Nil{}:
      True{}
    case Con{KNormShare{left, right}, rest}:
      norm_cmp_loop(book, g_class_join(st,left,right), rest, alts)
    case Con{KNormCmp{a, b, le, fresh}, rest}:
      kc(Bool, norm_cmp_quick(a, b) || norm_cmp_shared(st,a,b), u => norm_cmp_loop(book, st, rest, alts),
        u => norm_cmp_left(book, b, le, fresh,
          kc(List<&2, KNormCmp>, Bool.not(le) && p98_tag_eq(a, "GCell") && p98_tag_eq(b, "GCell"),
            u => Con{KNormShare{ix(a), ix(b)}, rest}, u => rest), alts, g_wnf(book, st, a)))

# Module: src/core/normalize.bend:568
@unsafe
def norm_cmp_fail(
  +book: List<&2, KDef>,
  +st: GState,
  +alts: List<&2, KNormAlt>,
) -> Bool:
  match alts:
    case Nil{}:
      False{}
    case Con{KNormAlt{todo}, rest}:
      norm_cmp_loop(book, st, todo, rest)

# Module: src/core/normalize.bend:584
@unsafe
def w7_br_38(w7_c: Bool, +book: List<&2, KDef>, +st: GState, +rest: List<&2, KNormCmp>, +alts: List<&2, KNormAlt>) -> Bool:
  match w7_c:
    case True{}:
      norm_cmp_loop(book, st, rest, alts)
    case False{}:
      norm_cmp_fail(book, st, alts)

@unsafe
def norm_cmp_test(
  +book: List<&2, KDef>,
  +st: GState,
  +yes: Bool,
  +rest: List<&2, KNormCmp>,
  +alts: List<&2, KNormAlt>,
) -> Bool:
  w7_br_38(yes, book, st, rest, alts)

# Module: src/core/normalize.bend:594
@unsafe
def w7_br_39(w7_c: Bool, +book: List<&2, KDef>, +st: GState, +a: KTerm, +b: KTerm, +le: Bool, +fresh: U32, +rest: List<&2, KNormCmp>, +alts: List<&2, KNormAlt>) -> Bool:
  match w7_c:
    case True{}:
      norm_cmp_same(book, st, a, b, le, fresh, rest, alts)
    case False{}:
      norm_cmp_fail(book, st, alts)

@unsafe
def w7_br_40(w7_c: Bool, +book: List<&2, KDef>, +st: GState, +a: KTerm, +b: KTerm, +le: Bool, +fresh: U32, +rest: List<&2, KNormCmp>, +alts: List<&2, KNormAlt>) -> Bool:
  match w7_c:
    case True{}:
      norm_cmp_heads(book, st, a, core_literal_step(b), le, fresh, rest, alts)
    case False{}:
      w7_br_39(p98_tag_eq(a, tg(b)), book, st, a, b, le, fresh, rest, alts)

@unsafe
def w7_br_41(w7_c: Bool, +book: List<&2, KDef>, +st: GState, +a: KTerm, +b: KTerm, +le: Bool, +fresh: U32, +rest: List<&2, KNormCmp>, +alts: List<&2, KNormAlt>) -> Bool:
  match w7_c:
    case True{}:
      norm_cmp_heads(book, st, core_literal_step(a), b, le, fresh, rest, alts)
    case False{}:
      w7_br_40(core_literal(b) && p98_tag_eq(a, "Ctr"), book, st, a, b, le, fresh, rest, alts)

@unsafe
def w7_br_42(w7_c: Bool, +book: List<&2, KDef>, +st: GState, +a: KTerm, +b: KTerm, +le: Bool, +fresh: U32, +rest: List<&2, KNormCmp>, +alts: List<&2, KNormAlt>) -> Bool:
  match w7_c:
    case True{}:
      norm_cmp_loop(book, st, Con{KNormCmp{app(a, var("_", fresh)), app(b, var("_", fresh)), le, U32.add(fresh, 1)}, rest}, alts)
    case False{}:
      w7_br_41(core_literal(a) && p98_tag_eq(b, "Ctr"), book, st, a, b, le, fresh, rest, alts)

@unsafe
def norm_cmp_heads(book, st, a, b, le, fresh, rest, alts):
  w7_br_42(p98_tag_eq(a, "Lam") || p98_tag_eq(b, "Lam"), book, st, a, b, le, fresh, rest, alts)

# Module: src/core/normalize.bend:602
@unsafe
def w7_br_43(w7_c: Bool, +book: List<&2, KDef>, +st: GState, +a: KTerm, +b: KTerm, +fresh: U32, +rest: List<&2, KNormCmp>, +alts: List<&2, KNormAlt>) -> Bool:
  match w7_c:
    case True{}:
      norm_cmp_kind_left(book, a, b, fresh, rest, alts, g_wnf(book, st, kid(a, 0)))
    case False{}:
      norm_cmp_loop(book, st, Con{KNormCmp{kid(a, 0), kid(b, 0), False{}, fresh}, rest}, alts)

@unsafe
def w7_br_44(w7_c: Bool, +book: List<&2, KDef>, +st: GState, +a: KTerm, +b: KTerm, +le: Bool, +fresh: U32, +rest: List<&2, KNormCmp>, +alts: List<&2, KNormAlt>) -> Bool:
  match w7_c:
    case True{}:
      norm_cmp_loop(book, st, Con{KNormCmp{kid(b, 0), kid(a, 0), le, fresh}, Con{KNormCmp{subst(kid(a, 1), ix(a), var("_", fresh)), subst(kid(b, 1), ix(b), var("_", fresh)), le, U32.add(fresh, 1)}, rest}}, alts)
    case False{}:
      norm_cmp_fail(book, st, alts)

@unsafe
def w7_br_45(w7_c: Bool, +book: List<&2, KDef>, +st: GState, +a: KTerm, +b: KTerm, +fresh: U32, +rest: List<&2, KNormCmp>, +alts: List<&2, KNormAlt>) -> Bool:
  match w7_c:
    case True{}:
      norm_cmp_fields(book, st, ks(a), ks(b), fresh, rest, alts)
    case False{}:
      norm_cmp_fail(book, st, alts)

@unsafe
def w7_br_46(w7_c: Bool, +book: List<&2, KDef>, +st: GState, +a: KTerm, +b: KTerm, +le: Bool, +fresh: U32, +rest: List<&2, KNormCmp>, +alts: List<&2, KNormAlt>) -> Bool:
  match w7_c:
    case True{}:
      norm_cmp_test(book, st, U32.is_eq(qt(a), qt(b)), rest, alts)
    case False{}:
      norm_cmp_plain(book, st, a, b, le, fresh, rest, alts)

@unsafe
def w7_br_47(w7_c: Bool, +book: List<&2, KDef>, +st: GState, +a: KTerm, +b: KTerm, +le: Bool, +fresh: U32, +rest: List<&2, KNormCmp>, +alts: List<&2, KNormAlt>) -> Bool:
  match w7_c:
    case True{}:
      w7_br_45(p88_string_eq(nm(a), nm(b)) && norm_removed(rm(a), rm(b), le), book, st, a, b, fresh, rest, alts)
    case False{}:
      w7_br_46(p98_tag_eq(a, "Qua"), book, st, a, b, le, fresh, rest, alts)

@unsafe
def w7_br_48(w7_c: Bool, +book: List<&2, KDef>, +st: GState, +a: KTerm, +b: KTerm, +le: Bool, +fresh: U32, +rest: List<&2, KNormCmp>, +alts: List<&2, KNormAlt>) -> Bool:
  match w7_c:
    case True{}:
      w7_br_44(U32.is_eq(qt(a), qt(b)), book, st, a, b, le, fresh, rest, alts)
    case False{}:
      w7_br_47(p98_tag_eq(a, "ADT"), book, st, a, b, le, fresh, rest, alts)

@unsafe
def w7_br_49(w7_c: Bool, +book: List<&2, KDef>, +st: GState, +a: KTerm, +b: KTerm, +le: Bool, +fresh: U32, +rest: List<&2, KNormCmp>, +alts: List<&2, KNormAlt>) -> Bool:
  match w7_c:
    case True{}:
      w7_br_43(le, book, st, a, b, fresh, rest, alts)
    case False{}:
      w7_br_48(p98_tag_eq(a, "All"), book, st, a, b, le, fresh, rest, alts)

@unsafe
def w7_br_50(w7_c: Bool, +book: List<&2, KDef>, +st: GState, +a: KTerm, +b: KTerm, +le: Bool, +fresh: U32, +rest: List<&2, KNormCmp>, +alts: List<&2, KNormAlt>) -> Bool:
  match w7_c:
    case True{}:
      norm_cmp_test(book, st, U32.is_eq(ix(a), ix(b)), rest, alts)
    case False{}:
      w7_br_49(p98_tag_eq(a, "Typ"), book, st, a, b, le, fresh, rest, alts)

@unsafe
def norm_cmp_same(book, st, a, b, le, fresh, rest, alts):
  w7_br_50(p98_tag_eq(a, "Var"), book, st, a, b, le, fresh, rest, alts)

# Module: src/core/normalize.bend:614
@unsafe
def w7_br_51(w7_c: Bool, +book: List<&2, KDef>, +st: GState, +a: KTerm, +b: KTerm, +le: Bool, +fresh: U32, +rest: List<&2, KNormCmp>, +alts: List<&2, KNormAlt>) -> Bool:
  match w7_c:
    case True{}:
      norm_cmp_loop(book, st, rest, alts)
    case False{}:
      norm_cmp_ref(book, st, a, b, le, norm_max(da(lookup(book, nm(a))), da(lookup(book, nm(b)))), fresh, rest, alts)

@unsafe
def w7_br_52(w7_c: Bool, +book: List<&2, KDef>, +st: GState, +a: KTerm, +b: KTerm, +fresh: U32, +rest: List<&2, KNormCmp>, +alts: List<&2, KNormAlt>) -> Bool:
  match w7_c:
    case True{}:
      norm_cmp_fields(book, st, ks(a), ks(b), fresh, rest, alts)
    case False{}:
      norm_cmp_fail(book, st, alts)

@unsafe
def w7_br_53(w7_c: Bool, +book: List<&2, KDef>, +st: GState, +a: KTerm, +b: KTerm, +fresh: U32, +rest: List<&2, KNormCmp>, +alts: List<&2, KNormAlt>) -> Bool:
  match w7_c:
    case True{}:
      norm_cmp_loop(book, st, Con{KNormCmp{kid(a, 1), kid(b, 1), False{}, fresh}, rest}, alts)
    case False{}:
      norm_cmp_fail(book, st, alts)

@unsafe
def w7_br_54(w7_c: Bool, +book: List<&2, KDef>, +st: GState, +a: KTerm, +b: KTerm, +fresh: U32, +rest: List<&2, KNormCmp>, +alts: List<&2, KNormAlt>) -> Bool:
  match w7_c:
    case True{}:
      norm_cmp_fields(book, st, ks(a), ks(b), fresh, rest, alts)
    case False{}:
      norm_cmp_test(book, st, p98_tag_eq(a, "Qnt") || p98_tag_eq(a, "Rfl") || p98_tag_eq(a, "Efq"), rest, alts)

@unsafe
def w7_br_55(w7_c: Bool, +book: List<&2, KDef>, +st: GState, +a: KTerm, +b: KTerm, +fresh: U32, +rest: List<&2, KNormCmp>, +alts: List<&2, KNormAlt>) -> Bool:
  match w7_c:
    case True{}:
      w7_br_53(p88_string_eq(nm(kid(a, 0)), nm(kid(b, 0))), book, st, a, b, fresh, rest, alts)
    case False{}:
      w7_br_54(p98_tag_eq(a, "App") || p98_tag_eq(a, "Min") || p98_tag_eq(a, "Eql") || p98_tag_eq(a, "Rwt"), book, st, a, b, fresh, rest, alts)

@unsafe
def w7_br_56(w7_c: Bool, +book: List<&2, KDef>, +st: GState, +a: KTerm, +b: KTerm, +fresh: U32, +rest: List<&2, KNormCmp>, +alts: List<&2, KNormAlt>) -> Bool:
  match w7_c:
    case True{}:
      w7_br_52(p88_string_eq(nm(a), nm(b)), book, st, a, b, fresh, rest, alts)
    case False{}:
      w7_br_55(p98_tag_eq(a, "App") && p98_tag_eq(kid(a, 0), "Ref") && p98_tag_eq(kid(b, 0), "Ref"), book, st, a, b, fresh, rest, alts)

@unsafe
def w7_br_57(w7_c: Bool, +book: List<&2, KDef>, +st: GState, +a: KTerm, +b: KTerm, +fresh: U32, +rest: List<&2, KNormCmp>, +alts: List<&2, KNormAlt>) -> Bool:
  match w7_c:
    case True{}:
      norm_cmp_test(book, st, p88_string_eq(nm(a), nm(b)), rest, alts)
    case False{}:
      w7_br_56(p98_tag_eq(a, "Ctr") || p98_tag_eq(a, "Mat"), book, st, a, b, fresh, rest, alts)

@unsafe
def w7_br_58(w7_c: Bool, +book: List<&2, KDef>, +st: GState, +a: KTerm, +b: KTerm, +le: Bool, +fresh: U32, +rest: List<&2, KNormCmp>, +alts: List<&2, KNormAlt>) -> Bool:
  match w7_c:
    case True{}:
      w7_br_51(p88_string_eq(nm(a), nm(b)), book, st, a, b, le, fresh, rest, alts)
    case False{}:
      w7_br_57(p98_tag_eq(a, "Hol"), book, st, a, b, fresh, rest, alts)

@unsafe
def w7_br_59(w7_c: Bool, +book: List<&2, KDef>, +st: GState, +a: KTerm, +b: KTerm, +le: Bool, +fresh: U32, +rest: List<&2, KNormCmp>, +alts: List<&2, KNormAlt>) -> Bool:
  match w7_c:
    case True{}:
      norm_cmp_test(book, st, core_literal_same(a, b), rest, alts)
    case False{}:
      w7_br_58(p98_tag_eq(a, "Ref"), book, st, a, b, le, fresh, rest, alts)

@unsafe
def norm_cmp_plain(book, st, a, b, le, fresh, rest, alts):
  w7_br_59(core_literal(a) && core_literal(b), book, st, a, b, le, fresh, rest, alts)

# Only bare, under-applied definitions compare extensionally. Stuck App heads
# above stay nominal, avoiding repeated eta expansion of an opaque application.

# Module: src/core/normalize.bend:626
@unsafe
def w7_br_60(w7_c: Bool, +book: List<&2, KDef>, +st: GState, +a: KTerm, +b: KTerm, +le: Bool, +n: U32, +fresh: U32, +rest: List<&2, KNormCmp>, +alts: List<&2, KNormAlt>) -> Bool:
  match w7_c:
    case True{}:
      norm_cmp_loop(book, st, Con{KNormCmp{app(a, var("_", fresh)), app(b, var("_", fresh)), le, U32.add(fresh, 1)}, rest}, alts)
    case False{}:
      norm_cmp_ref(book, st, app(a, var("_", fresh)), app(b, var("_", fresh)), le, U32.sub(n, 1), U32.add(fresh, 1), rest, alts)

@unsafe
def w7_br_61(w7_c: Bool, +book: List<&2, KDef>, +st: GState, +a: KTerm, +b: KTerm, +le: Bool, +n: U32, +fresh: U32, +rest: List<&2, KNormCmp>, +alts: List<&2, KNormAlt>) -> Bool:
  match w7_c:
    case True{}:
      norm_cmp_fail(book, st, alts)
    case False{}:
      w7_br_60(U32.is_eq(n, 1), book, st, a, b, le, n, fresh, rest, alts)

@unsafe
def norm_cmp_ref(
  +book: List<&2, KDef>,
  +st: GState,
  +a: KTerm,
  +b: KTerm,
  +le: Bool,
  +n: U32,
  +fresh: U32,
  +rest: List<&2, KNormCmp>,
  +alts: List<&2, KNormAlt>,
) -> Bool:
  w7_br_61(U32.is_eq(n, 0), book, st, a, b, le, n, fresh, rest, alts)

# Module: src/core/normalize.bend:643
@unsafe
def w7_br_62(w7_c: Bool, +book: List<&2, KDef>, +st: GState, +as: List<&2, KTerm>, +bs: List<&2, KTerm>, +fresh: U32, +rest: List<&2, KNormCmp>, +alts: List<&2, KNormAlt>) -> Bool:
  match w7_c:
    case True{}:
      norm_cmp_loop(book, st, norm_cmp_zip(as, bs, fresh, rest), alts)
    case False{}:
      norm_cmp_fail(book, st, alts)

@unsafe
def norm_cmp_fields(book, st, as, bs, fresh, rest, alts):
  w7_br_62(U32.is_eq(terms_len(as), terms_len(bs)), book, st, as, bs, fresh, rest, alts)

# Module: src/core/normalize.bend:647
@unsafe
def w7_br_63(w7_c: Bool, +book: List<&2, KDef>, +st: GState, +a: KTerm, +g: KTerm, +h: KTerm, +fresh: U32, +rest: List<&2, KNormCmp>, +alts: List<&2, KNormAlt>) -> Bool:
  match w7_c:
    case True{}:
      norm_cmp_loop(book, st, Con{KNormCmp{a, kt("Typ", "", 0, 0, Con{kid(h, 0), Nil{}}), True{}, fresh}, rest}, Con{KNormAlt{Con{KNormCmp{a, kt("Typ", "", 0, 0, Con{kid(h, 1), Nil{}}), True{}, fresh}, rest}}, alts})
    case False{}:
      norm_cmp_loop(book, st, Con{KNormCmp{g, h, True{}, fresh}, rest}, alts)

@unsafe
def w7_br_64(w7_c: Bool, +book: List<&2, KDef>, +st: GState, +a: KTerm, +b: KTerm, +g: KTerm, +h: KTerm, +fresh: U32, +rest: List<&2, KNormCmp>, +alts: List<&2, KNormAlt>) -> Bool:
  match w7_c:
    case True{}:
      norm_cmp_loop(book, st, Con{KNormCmp{kt("Typ", "", 0, 0, Con{kid(g, 0), Nil{}}), b, True{}, fresh}, Con{KNormCmp{kt("Typ", "", 0, 0, Con{kid(g, 1), Nil{}}), b, True{}, fresh}, rest}}, alts)
    case False{}:
      w7_br_63(p98_tag_eq(h, "Min"), book, st, a, g, h, fresh, rest, alts)

@unsafe
def w7_br_65(w7_c: Bool, +book: List<&2, KDef>, +st: GState, +a: KTerm, +b: KTerm, +g: KTerm, +h: KTerm, +fresh: U32, +rest: List<&2, KNormCmp>, +alts: List<&2, KNormAlt>) -> Bool:
  match w7_c:
    case True{}:
      norm_cmp_loop(book, st, rest, alts)
    case False{}:
      w7_br_64(p98_tag_eq(g, "Min"), book, st, a, b, g, h, fresh, rest, alts)

@unsafe
def norm_cmp_kind(book, st, a, b, g, h, fresh, rest, alts):
  w7_br_65((p98_tag_eq(g, "Qua") && U32.is_eq(qt(g), 2)) || (p98_tag_eq(h, "Qua") && Bool.not(U32.is_eq(qt(h), 2))), book, st, a, b, g, h, fresh, rest, alts)

# Module: src/core/normalize.bend:665
@unsafe
def norm_cmp_left(
  +book: List<&2, KDef>,
  +b: KTerm,
  +le: Bool,
  +fresh: U32,
  +rest: List<&2, KNormCmp>,
  +alts: List<&2, KNormAlt>,
  +r: GResult,
) -> Bool:
  match r:
    case GResult{st, a}:
      norm_cmp_right(book, a, le, fresh, rest, alts, g_wnf(book, st, b))

# Module: src/core/normalize.bend:679
@unsafe
def norm_cmp_right(
  +book: List<&2, KDef>,
  +a: KTerm,
  +le: Bool,
  +fresh: U32,
  +rest: List<&2, KNormCmp>,
  +alts: List<&2, KNormAlt>,
  +r: GResult,
) -> Bool:
  match r:
    case GResult{st, b}:
      norm_cmp_heads(book, st, a, b, le, fresh, rest, alts)

# Module: src/core/normalize.bend:693
@unsafe
def norm_cmp_kind_left(
  +book: List<&2, KDef>,
  +a: KTerm,
  +b: KTerm,
  +fresh: U32,
  +rest: List<&2, KNormCmp>,
  +alts: List<&2, KNormAlt>,
  +r: GResult,
) -> Bool:
  match r:
    case GResult{st, g}:
      norm_cmp_kind_right(book, a, b, g, fresh, rest, alts, g_wnf(book, st, kid(b, 0)))

# Module: src/core/normalize.bend:707
@unsafe
def norm_cmp_kind_right(
  +book: List<&2, KDef>,
  +a: KTerm,
  +b: KTerm,
  +g: KTerm,
  +fresh: U32,
  +rest: List<&2, KNormCmp>,
  +alts: List<&2, KNormAlt>,
  +r: GResult,
) -> Bool:
  match r:
    case GResult{st, h}:
      norm_cmp_kind(book, st, a, b, g, h, fresh, rest, alts)

# Module: src/core/graph.bend:209
@unsafe
def kr_resolve(book, name):
  kr_resolve_head(book, name, lookup(book, name))

# Module: src/core/reach.bend:98
@unsafe
def kr_resolve_head(book, name, d):
  w7_br_94(p88_string_eq(dk(d), "Absent"), book, name, d)

# Module: src/core/reach.bend:102
@unsafe
def kp_each(
  ts: List<&2, KTerm>,
  +p: U32,
  +env: List<&2, KPName>,
) -> List<&2, String>:
  match ts:
    case Nil{}: Nil{}
    case Con{h, t}: Con{kp_go(h, p, env), kp_each(t, p, env)}

# Module: src/core/pretty.bend:258
@unsafe
def kp_application(
  s: KPChain,
  +p: U32,
  +env: List<&2, KPName>,
) -> String:
  match s:
    case KPChain{+xs, +h}: kc(String, kp_is(h, "Ref", "Exists") && U32.is_eq(terms_len(xs), 2) && kp_eq(tg(terms_at(xs, 1)), "Lam"), u => kp_exists(terms_at(xs, 0), terms_at(xs, 1), p, env), u => kp_go(h, 3, env) ++ "(" ++ kp_join(kp_each(xs, 1, env), ", ") ++ ")")

# Module: src/core/pretty.bend:285
@unsafe
def kp_adt(
  +t: KTerm,
  +p: U32,
  +env: List<&2, KPName>,
) -> String:
  kp_par(kp_name(env, nm(t)) ++ kc(String, U32.is_eq(terms_len(ks(t)), 0) && Bool.not(kp_has_removed(rm(t))), u => "", u => "<" ++ kp_join(kp_each(ks(t), 1, env), ", ") ++ ">") ++ kp_removed(rm(t), env), kp_has_removed(rm(t)) && U32.is_gt(p, 2))

# Module: src/core/pretty.bend:302
@unsafe
def kp_char(
  +t: KTerm,
  +quote: U32,
) -> Maybe<&2, String>:
  kc(Maybe<&2, String>, kp_is(t, "Ctr", "Chr") && U32.is_eq(terms_len(ks(t)), 1), u => kp_char_num(kp_number(kid(t, 0)), quote), u => None{})

# Module: src/core/pretty.bend:373
@unsafe
def kp_char_num(n, quote):
  match n:
    case None{}: None{}
    case Some{x}: Some{kp_escape(x, quote)}

# Module: src/core/pretty.bend:379
@unsafe
def kp_string(
  +t: KTerm,
) -> Maybe<&2, String>:
  kc(Maybe<&2, String>, core_literal(t) && p88_string_eq(nm(t), "String"), u => kp_string(core_literal_step(t)), u => kc(Maybe<&2, String>, kp_is(t, "Ctr", "SNil"), u => Some{""},
    u => kc(Maybe<&2, String>, kp_is(t, "Ctr", "SCon") && U32.is_eq(terms_len(ks(t)), 2), u => kp_append(kp_char(kid(t, 0), 34), kp_string(kid(t, 1))), u => None{})))

# Module: src/core/pretty.bend:386
@unsafe
def kp_list(
  chain: KPChain,
  +p: U32,
  +env: List<&2, KPName>,
) -> String:
  match chain:
    case KPChain{+xs, +t}:
      kc(String, kp_is(t, "Ctr", "Nil"), u => "[" ++ kp_join(kp_each(xs, 1, env), ", ") ++ "]",
        u => kp_par(kp_join(kp_each(xs, 3, env), " <> ") ++ " <> " ++ kp_go(t, 2, env), U32.is_gt(p, 2)))

# Module: src/core/pretty.bend:403
@unsafe
def kp_tuple(
  chain: KPChain,
  +env: List<&2, KPName>,
) -> String:
  match chain:
    case KPChain{xs, t}: "(" ++ kp_join(kp_each(xs, 1, env), ", ") ++ ", " ++ kp_go(t, 1, env) ++ ")"

# Module: src/core/pretty.bend:411
@unsafe
def w7_br_110(w7_c: Bool, +t: KTerm, +n: Nat, +p: U32, +env: List<&2, KPName>) -> String:
  match w7_c:
    case True{}:
      kp_nat(kid(t, 0), Nat.add(n, 1n), p, env)
    case False{}:
      kp_par(Nat.show(n) ++ "n+" ++ kp_go(t, 2, env), U32.is_gt(p, 2))

@unsafe
def w7_br_111(w7_c: Bool, +t: KTerm, +n: Nat, +p: U32, +env: List<&2, KPName>) -> String:
  match w7_c:
    case True{}:
      Nat.show(n) ++ "n"
    case False{}:
      w7_br_110(kp_is(t, "Ctr", "Succ") && U32.is_eq(terms_len(ks(t)), 1), t, n, p, env)

@unsafe
def w7_br_112(w7_c: Bool, +t: KTerm, +n: Nat, +p: U32, +env: List<&2, KPName>) -> String:
  match w7_c:
    case True{}:
      w7_br_109(Nat.is_le(n, U32.to_nat(U32.sub(4294967295, kl_number(t)))), t, n, p)
    case False{}:
      w7_br_111(kp_is(t, "Ctr", "Zero"), t, n, p, env)

@unsafe
def kp_nat(
  +t: KTerm,
  +n: Nat,
  +p: U32,
  +env: List<&2, KPName>,
) -> String:
  w7_br_112(core_nat(t), t, n, p, env)

# Module: src/core/pretty.bend:423
@unsafe
def kp_ctor(
  +t: KTerm,
  +p: U32,
  +env: List<&2, KPName>,
) -> String:
  kp_ctor_number(kp_number(t), t, p, env)

# Module: src/core/pretty.bend:444
@unsafe
def kp_ctor_number(n, t, p, env):
  match n:
    case Some{+x}: kc(String, kp_eq(nm(t), "F32"), u => kp_float_show(x), u => U32.show(x))
    case None{}: kp_ctor_other(t, p, env)

# Module: src/core/pretty.bend:450
@unsafe
def w7_br_113(w7_c: Bool, +t: KTerm, +p: U32, +env: List<&2, KPName>) -> String:
  match w7_c:
    case True{}:
      kp_nat(t, 0n, p, env)
    case False{}:
      kp_ctor_char(kp_char(t, 39), t, p, env)

@unsafe
def kp_ctor_other(t, p, env):
  w7_br_113(kp_eq(nm(t), "Succ") || kp_eq(nm(t), "Zero"), t, p, env)

# Module: src/core/pretty.bend:455
@unsafe
def kp_ctor_char(c, t, p, env):
  match c:
    case Some{s}: "'" ++ s ++ "'"
    case None{}: kp_ctor_string(kp_string(t), t, p, env)

# Module: src/core/pretty.bend:461
@unsafe
def kp_ctor_string(s, t, p, env):
  match s:
    case Some{x}: "\"" ++ x ++ "\""
    case None{}:
      kc(String, kp_eq(nm(t), "Con") || kp_eq(nm(t), "Nil"), u => kp_list(kp_chain(t, "Con", 2, Nil{}), p, env),
        u => kc(String, kp_eq(nm(t), "Tuple"), u => kp_tuple(kp_chain(t, "Tuple", 2, Nil{}), env), u => kp_ctor_array(kp_array(t), t, env)))

# Module: src/core/pretty.bend:469
@unsafe
def kp_ctor_array(a, t, env):
  match a:
    case Some{xs}: "[" ++ kp_join(kp_each(xs, 1, env), ", ") ++ "]"
    case None{}: kp_name(env, nm(t)) ++ "{" ++ kp_join(kp_each(ks(t), 1, env), ", ") ++ "}"

# Module: src/core/pretty.bend:475
@unsafe
def w7_br_114(w7_c: Bool, +t: KTerm, +env: List<&2, KPName>) -> String:
  match w7_c:
    case True{}:
      kp_name(env, nm(t)) ++ ": " ++ kp_go(kid(t, 0), 2, env) ++ kc(String, kp_eq(tg(kid(t, 1)), "Efq"), u => "", u => "; " ++ kp_matches(kid(t, 1), env))
    case False{}:
      kp_go(t, 2, env)

@unsafe
def kp_matches(
  +t: KTerm,
  +env: List<&2, KPName>,
) -> String:
  w7_br_114(kp_eq(tg(t), "Mat"), t, env)

# Module: src/core/pretty.bend:482
@unsafe
def w7_br_115(w7_c: Bool, +t: KTerm, +env: List<&2, KPName>) -> String:
  match w7_c:
    case True{}:
      "Data"
    case False{}:
      "Kind(" ++ kp_go(kid(t, 0), 1, env) ++ ")"

@unsafe
def w7_br_116(w7_c: Bool, +t: KTerm, +env: List<&2, KPName>) -> String:
  match w7_c:
    case True{}:
      "Type"
    case False{}:
      w7_br_115(kp_eq(tg(kid(t, 0)), "Qua") && U32.is_eq(qt(kid(t, 0)), 2), t, env)

@unsafe
def w7_br_117(w7_c: Bool, +t: KTerm, +p: U32, +env: List<&2, KPName>) -> String:
  match w7_c:
    case True{}:
      kp_par(kp_quant(qt(t)) ++ nm(t) ++ " => " ++ kp_go(kid(t, 0), 0, kp_bind(env, t)), U32.is_gt(p, 1))
    case False{}:
      kp_go_tail(t, p, env)

@unsafe
def w7_br_118(w7_c: Bool, +t: KTerm, +p: U32, +env: List<&2, KPName>) -> String:
  match w7_c:
    case True{}:
      kp_par("@" ++ kp_quant(qt(t)) ++ nm(t) ++ ":" ++ kp_go(kid(t, 0), 3, env) ++ " -> " ++ kp_go(kid(t, 1), 2, kp_bind(env, t)), U32.is_gt(p, 2))
    case False{}:
      w7_br_117(kp_eq(tg(t), "Lam"), t, p, env)

@unsafe
def w7_br_119(w7_c: Bool, +t: KTerm, +p: U32, +env: List<&2, KPName>) -> String:
  match w7_c:
    case True{}:
      kp_par(kp_go(kid(t, 0), 3, env) ++ " <&> " ++ kp_go(kid(t, 1), 3, env), U32.is_gt(p, 2))
    case False{}:
      w7_br_118(kp_eq(tg(t), "All"), t, p, env)

@unsafe
def w7_br_120(w7_c: Bool, +t: KTerm, +p: U32, +env: List<&2, KPName>) -> String:
  match w7_c:
    case True{}:
      "&" ++ U32.show(qt(t))
    case False{}:
      w7_br_119(kp_eq(tg(t), "Min"), t, p, env)

@unsafe
def w7_br_121(w7_c: Bool, +t: KTerm, +p: U32, +env: List<&2, KPName>) -> String:
  match w7_c:
    case True{}:
      "Quant"
    case False{}:
      w7_br_120(kp_eq(tg(t), "Qua"), t, p, env)

@unsafe
def w7_br_122(w7_c: Bool, +t: KTerm, +p: U32, +env: List<&2, KPName>) -> String:
  match w7_c:
    case True{}:
      w7_br_116(kp_eq(tg(kid(t, 0)), "Qua") && U32.is_eq(qt(kid(t, 0)), 1), t, env)
    case False{}:
      w7_br_121(kp_eq(tg(t), "Qnt"), t, p, env)

@unsafe
def w7_br_123(w7_c: Bool, +t: KTerm, +p: U32, +env: List<&2, KPName>) -> String:
  match w7_c:
    case True{}:
      kp_name(env, nm(t)) ++ kc(String, kp_bound(env, kp_name(env, nm(t))), u => "^", u => "") ++ kc(String, U32.is_eq(qt(t), 3), u => "!", u => "")
    case False{}:
      w7_br_122(kp_eq(tg(t), "Typ"), t, p, env)

@unsafe
def w7_br_124(w7_c: Bool, +t: KTerm, +p: U32, +env: List<&2, KPName>) -> String:
  match w7_c:
    case True{}:
      kp_scope(env, ix(t), nm(t))
    case False{}:
      w7_br_123(kp_eq(tg(t), "Ref"), t, p, env)

@unsafe
def kp_go(t, p, env):
  w7_br_124(kp_eq(tg(t), "Var"), t, p, env)

# Module: src/core/pretty.bend:494
@unsafe
def w7_br_125(w7_c: Bool, +t: KTerm, +p: U32, +env: List<&2, KPName>) -> String:
  match w7_c:
    case True{}:
      U32.show(kl_number(t)) ++ "n"
    case False{}:
      kp_ctor(core_literal_step(t), p, env)

@unsafe
def w7_br_126(w7_c: Bool, +t: KTerm, +p: U32, +env: List<&2, KPName>) -> String:
  match w7_c:
    case True{}:
      "{" ++ kp_go(kid(t, 0), 2, env) ++ " : " ++ kp_go(kid(t, 1), 2, env) ++ "}"
    case False{}:
      kp_go_last(t, p, env)

@unsafe
def w7_br_127(w7_c: Bool, +t: KTerm, +p: U32, +env: List<&2, KPName>) -> String:
  match w7_c:
    case True{}:
      "?" ++ nm(t)
    case False{}:
      w7_br_126(kp_eq(tg(t), "Ann"), t, p, env)

@unsafe
def w7_br_128(w7_c: Bool, +t: KTerm, +p: U32, +env: List<&2, KPName>) -> String:
  match w7_c:
    case True{}:
      "{==}"
    case False{}:
      w7_br_127(kp_eq(tg(t), "Hol"), t, p, env)

@unsafe
def w7_br_129(w7_c: Bool, +t: KTerm, +p: U32, +env: List<&2, KPName>) -> String:
  match w7_c:
    case True{}:
      "{" ++ kp_go(kid(t, 0), 2, env) ++ " == " ++ kp_go(kid(t, 1), 2, env) ++ " : " ++ kp_go(kid(t, 2), 2, env) ++ "}"
    case False{}:
      w7_br_128(kp_eq(tg(t), "Rfl"), t, p, env)

@unsafe
def w7_br_130(w7_c: Bool, +t: KTerm, +p: U32, +env: List<&2, KPName>) -> String:
  match w7_c:
    case True{}:
      "\\{}"
    case False{}:
      w7_br_129(kp_eq(tg(t), "Eql"), t, p, env)

@unsafe
def w7_br_131(w7_c: Bool, +t: KTerm, +p: U32, +env: List<&2, KPName>) -> String:
  match w7_c:
    case True{}:
      "\\{" ++ kp_matches(t, env) ++ "}"
    case False{}:
      w7_br_130(kp_eq(tg(t), "Efq"), t, p, env)

@unsafe
def w7_br_132(w7_c: Bool, +t: KTerm, +p: U32, +env: List<&2, KPName>) -> String:
  match w7_c:
    case True{}:
      kp_ctor(t, p, env)
    case False{}:
      w7_br_131(kp_eq(tg(t), "Mat"), t, p, env)

@unsafe
def w7_br_133(w7_c: Bool, +t: KTerm, +p: U32, +env: List<&2, KPName>) -> String:
  match w7_c:
    case True{}:
      kp_adt(t, p, env)
    case False{}:
      w7_br_132(kp_eq(tg(t), "Ctr"), t, p, env)

@unsafe
def w7_br_134(w7_c: Bool, +t: KTerm, +p: U32, +env: List<&2, KPName>) -> String:
  match w7_c:
    case True{}:
      kp_application(kp_spine(t, Nil{}), p, env)
    case False{}:
      w7_br_133(kp_eq(tg(t), "ADT"), t, p, env)

@unsafe
def w7_br_135(w7_c: Bool, +t: KTerm, +p: U32, +env: List<&2, KPName>) -> String:
  match w7_c:
    case True{}:
      w7_br_125(core_nat(t), t, p, env)
    case False{}:
      w7_br_134(kp_eq(tg(t), "App"), t, p, env)

@unsafe
def kp_go_tail(t, p, env):
  w7_br_135(core_literal(t), t, p, env)

# Module: src/core/pretty.bend:508
@unsafe
def w7_br_137(w7_c: Bool, +t: KTerm, +p: U32, +env: List<&2, KPName>) -> String:
  match w7_c:
    case True{}:
      kp_let(t, p, env)
    case False{}:
      w7_br_136(kp_eq(tg(t), "Literal"), t)

@unsafe
def w7_br_138(w7_c: Bool, +t: KTerm, +p: U32, +env: List<&2, KPName>) -> String:
  match w7_c:
    case True{}:
      kp_rewrite(t, p, env)
    case False{}:
      w7_br_137(kp_eq(tg(t), "Let"), t, p, env)

@unsafe
def w7_br_139(w7_c: Bool, +t: KTerm, +p: U32, +env: List<&2, KPName>) -> String:
  match w7_c:
    case True{}:
      kp_go(kid(t, 1), p, env)
    case False{}:
      w7_br_138(kp_eq(tg(t), "Rwt"), t, p, env)

@unsafe
def kp_go_last(t, p, env):
  w7_br_139(kp_eq(tg(t), "Sub"), t, p, env)

# Module: src/core/pretty.bend:516
@unsafe
def kp_exists(A, b, p, env):
  kp_par("&" ++ nm(b) ++ ":" ++ kp_go(A, 3, env) ++ " -> " ++ kp_go(kid(b, 0), 2, kp_bind(env, b)), U32.is_gt(p, 2))

# Module: src/core/pretty.bend:526
@unsafe
def kp_rewrite(t, p, env):
  kp_par("%" ++ kp_rewrite_motive(kid(t, 0), kid(t, 1), env) ++ "; " ++ kp_go(kid(t, 2), 0, env), U32.is_gt(p, 1))

# Module: src/core/pretty.bend:530
@unsafe
def w7_br_140(w7_c: Bool, +e: KTerm, +m: KTerm, +env: List<&2, KPName>) -> String:
  match w7_c:
    case True{}:
      kc(String, kp_eq(nm(kid(m, 0)), ""), u => "", u => nm(kid(m, 0)) ++ "@") ++ kp_go(e, 2, env) ++ " : " ++ kp_go(kid(kid(m, 0), 0), 2, kp_bind(kp_bind(env, m), kid(m, 0)))
    case False{}:
      kp_go(e, 2, env) ++ " : " ++ kp_go(m, 2, env)

@unsafe
def kp_rewrite_motive(e, m, env):
  w7_br_140(kp_eq(tg(m), "Lam") && kp_eq(tg(kid(m, 0)), "Lam"), e, m, env)

# Module: src/core/pretty.bend:534
@unsafe
def kp_let(t, p, env):
  kp_par(kp_let_names(ks(t)) ++ " = " ++ kp_let_vals(ks(t), env) ++ "; " ++ kp_let_body(ks(t), env), U32.is_gt(p, 0))

# Module: src/core/pretty.bend:538
@unsafe
def kp_let_vals(ts, env):
  match ts:
    case Nil{}: ""
    case Con{+h, +rest}: kc(String, U32.is_eq(terms_len(rest), 0), u => "", u => kp_go(kid(h, 0), 2, env) ++ kc(String, U32.is_eq(terms_len(rest), 1), u => "", u => " " ++ kp_let_vals(rest, env)))

# Module: src/core/pretty.bend:550
@unsafe
def kp_let_body(ts, env):
  match ts:
    case Nil{}: "<missing let body>"
    case Con{+h, +rest}: kc(String, U32.is_eq(terms_len(rest), 0), u => kp_go(h, 0, env), u => kp_let_body(rest, kp_bind(env, h)))

# Module: src/check/quantity.bend:52
@unsafe
def constructor_exists(
  +ds: List<&2, KDef>,
  +name: String,
) -> Bool:
  match ds:
    case Nil{}:
      False{}
    case Con{h, rest}:
      w7_ctor_exists_head(p88_string_eq(dk(h), "BookCache"), h, rest, ds, name)

# Module: src/check/kernel.bend:984
@unsafe
def constructor_names(done, ctrs, names):
  match ctrs:
    case Nil{}:
      ""
    case Con{h, rest}:
      kc(String, has_name(names, dn(h)) || constructor_exists(done, dn(h)), u => "duplicate constructor name", u => constructor_names(done, rest, Con{dn(h), names}))

# Module: src/check/kernel.bend:1008
@unsafe
def kw_mint_floor(+world: KWorld, +roots: List<&2,KTerm>) -> U32:
  kw_floor_fresh(world, kw_fresh(world), roots)

# Module: src/check/kernel.bend:1384
@unsafe
def kw_temp_floor(+world: KWorld, +roots: List<&2,KTerm>) -> U32:
  kw_temp_fresh(world, kw_fresh(world), roots)

# Module: src/check/kernel.bend:1388
@unsafe
def w7_br_242(w7_c: Bool, +book: List<&2,KDef>, +tel: KTerm, +args: List<&2,KTerm>) -> KTerm:
  match w7_c:
    case True{}:
      env_tele_fill_loop(book, tel, args, Nil{}, 0)
    case False{}:
      env_tele_fill_eager(book, tel, args)

@unsafe
def w7_br_243(w7_c: Bool, +book: List<&2,KDef>, +tel: KTerm, +args: List<&2,KTerm>) -> KTerm:
  match w7_c:
    case True{}:
      w7_br_242(env_tele_safe(tel), book, tel, args)
    case False{}:
      env_tele_fill_eager(book, tel, args)

@unsafe
def env_tele_fill(+book: List<&2,KDef>, +tel: KTerm, +args: List<&2,KTerm>) -> KTerm:
  w7_br_243(env_tele_many(args), book, tel, args)

# Module: src/check/env-telescope.bend:64
@unsafe
def w7_br_245(w7_c: Bool, +book: List<&2,KDef>, +tel: KTerm, +h: KTerm, +rest: List<&2,KTerm>) -> KTerm:
  match w7_c:
    case True{}:
      env_tele_fill_loop(book, kid(tel, 1), rest, [KTelescopeBinding{ix(tel), h}], 1)
    case False{}:
      env_tele_fill_eager_head(book, tel, h, rest)

@unsafe
def w7_br_246(w7_c: Bool, +book: List<&2,KDef>, +tel: KTerm, +h: KTerm, +rest: List<&2,KTerm>) -> KTerm:
  match w7_c:
    case True{}:
      w7_br_245(env_tele_safe(tel), book, tel, h, rest)
    case False{}:
      {KTerm{"Error", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}

@unsafe
def env_tele_fill_open(+book: List<&2,KDef>, +tel: KTerm, +h: KTerm, +rest: List<&2,KTerm>) -> KTerm:
  w7_br_246(p98_tag_eq(tel, "All"), book, tel, h, rest)

# Module: src/check/env-telescope.bend:82
@unsafe
def env_tele_fill_loop(book, tel, args, bindings, count):
  match args:
    case Nil{}: env_tele_apply(tel, bindings)
    case Con{h, rest}:
      kc(KTerm, env_tele_safe(h),
        u => kc(KTerm, p98_tag_eq(tel, "All") && U32.is_lt(count, 64),
          u => env_tele_fill_loop(book, kid(tel, 1), rest, Con{KTelescopeBinding{ix(tel), h}, bindings}, U32.add(count, 1)),
          u => env_tele_fill_open(book, wnf(book, env_tele_apply(tel, bindings)), h, rest)),
        u => env_tele_fill_eager(book, env_tele_apply(tel, bindings), args))

# Module: src/check/env-telescope.bend:103
@unsafe
def w7b_wnf(+book: List<&2, KDef>, +t: KTerm) -> KTerm:
  match t:
    case KLambda{_, _, _, _, _, _, _, _}: t
    case KLiteral{_, _, _, _, _}: t
    case KTerm{+tag, _, _, _, _, _, _, _}:
      w7b_wnf_go(p88_string_eq(tag, "ADT") || p88_string_eq(tag, "All") || p88_string_eq(tag, "Typ") || p88_string_eq(tag, "Set") || p88_string_eq(tag, "Qnt") || p88_string_eq(tag, "Eql") || p88_string_eq(tag, "Emp") || p88_string_eq(tag, "Uni"), book, t)

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
def f_context_name(+term: KTerm, +input: FInput) -> FParsed:
  match input:
    case FInput{tokens, context}:
      match context:
        case FParseContext{scope, env, next}:
          +bound = f_env(nm(term), env)
          f_choose(FParsed, p98_tag_eq(bound, "Absent"),
            u => f_context_name_resolved(term, input, f_context_resolve(term, scope)),
            u => FParsed{kt_span("Var", nm(bound), ix(bound), 1, Nil{}, kb(term), ke(term)), input})

# Module: src/front/contextual.bend:25
@unsafe
def f_context_atom_name(+input: FInput) -> FParsed:
  f_context_name(kt_span("Ref", f_tx(input), 0, 1, Nil{}, f_begin(input), f_end(input)), f_tl(input))

# Module: src/front/contextual.bend:72
@unsafe
def f_context_type_name(+name: String, +input: FInput) -> String:
  match input:
    case FInput{tokens, context}:
      match context:
        case FParseContext{scope, env, next}: nm(f_context_resolve(ref(name), scope))

# Module: src/front/contextual.bend:505
@unsafe
def f_context_mark(+parsed: FParsed) -> FParsed:
  match parsed:
    case FParsed{term, input}: f_choose(FParsed, f_context_stop(term), u => parsed, u => f_context_mark_input(term, input))

# Module: src/front/contextual.bend:510
@unsafe
def f_context_mark_input(+term: KTerm, +input: FInput) -> FParsed:
  match input:
    case FInput{tokens, context}:
      match context:
        case FParseContext{scope, env, next}:
          match scope:
            case FParseScope{prior, index, ctorIndex, ns, aliases, +p144p_view}:
              +syntax = f_context_syntax(term)
              +resolved = f_choose(KTerm, f_eq(tg(term), "ADT"), u => term, u => f_context_resolve(syntax, scope))
              f_context_mark_known(term, syntax, resolved, p144p_find(nm(resolved), prior, p144p_view), input)

# Module: src/front/contextual.bend:522

@unsafe
def f_atom_constructor(name, id, p):
  match p:
    case FParsed{+args, ts}:
      f_choose(FParsed, f_context_stop(args), u => FParsed{args, ts}, u => f_context_constructor(kt("Ctr", name, id, 1, ks(args)), ts))

# Module: src/front/parser.bend:278
@unsafe
def f_mark(p, q):
  f_context_mark(p)

# Module: src/front/parser.bend:292
@unsafe
def w7_br_336(w7_c: Bool, +s: String) -> U32:
  match w7_c:
    case True{}:
      2
    case False{}:
      w7_br_335(f_eq(s, "||"), s)

@unsafe
def w7_br_337(w7_c: Bool, +s: String) -> U32:
  match w7_c:
    case True{}:
      1
    case False{}:
      w7_br_336(f_eq(s, "&") || f_eq(s, "|"), s)

@unsafe
def f_prec(
  +s: String,
) -> U32:
  w7_br_337(f_eq(s, "=>") || f_eq(s, "->"), s)
@unsafe
def w7_br_353(w7_c: Bool, +s: String) -> String:
  match w7_c:
    case True{}:
      ".div"
    case False{}:
      w7_br_352(f_eq(s, "%"), s)

@unsafe
def w7_br_354(w7_c: Bool, +s: String) -> String:
  match w7_c:
    case True{}:
      ".mul"
    case False{}:
      w7_br_353(f_eq(s, "/"), s)

@unsafe
def w7_br_355(w7_c: Bool, +s: String) -> String:
  match w7_c:
    case True{}:
      ".sub"
    case False{}:
      w7_br_354(f_eq(s, "*"), s)

@unsafe
def w7_br_356(w7_c: Bool, +s: String) -> String:
  match w7_c:
    case True{}:
      ".add"
    case False{}:
      w7_br_355(f_eq(s, "-"), s)

@unsafe
def w7_br_367(w7_c: Bool, +source: String, +error: KTerm) -> String:
  match w7_c:
    case True{}:
      fpe_eof(source, source, 0, error)
    case False{}:
      nm(error)

@unsafe
def w7_br_377(w7_c: Bool, +source: String, +rest: String, +offset: U32, +error: KTerm, +observed: String) -> String:
  match w7_c:
    case True{}:
      fpe_range(source, rest, ix(error), qt(error), offset, offset, error, "")
    case False{}:
      fpe_message(source, offset, offset, error, observed)

@unsafe
def w7_br_378(w7_c: Bool, +source: String, +rest: String, +offset: U32, +error: KTerm, +observed: String) -> String:
  match w7_c:
    case True{}:
      fpe_message(source, offset, offset, error, "'" ++ fpe_line_text(String.lines(source), ix(error)) ++ "'")
    case False{}:
      w7_br_377(f_eq(tg(kid(error, 2)), "ParseRange"), source, rest, offset, error, observed)

@unsafe
def fpe_observe(+source: String, +rest: String, +offset: U32, +error: KTerm, +observed: String) -> String:
  w7_br_378(f_eq(tg(kid(error, 2)), "ParseLine"), source, rest, offset, error, observed)

# Module: src/front/parser.bend:594
@unsafe
def w7_br_379(w7_c: Bool, +source: String, +rest: String, +line: U32, +column: U32, +offset: U32, +start: U32, +error: KTerm, +acc: String) -> String:
  match w7_c:
    case True{}:
      nm(error)
    case False{}:
      fpe_range(source, f_tail(rest), f_choose(U32, Char.is_eq(f_head(rest), '\n'), u => U32.add(line, 1), u => line), f_choose(U32, Char.is_eq(f_head(rest), '\n'), u => 0, u => U32.add(column, 1)), U32.add(offset, dg_units(f_head(rest))), start, error, SCon{f_head(rest), acc})

@unsafe
def w7_br_380(w7_c: Bool, +source: String, +rest: String, +line: U32, +column: U32, +offset: U32, +start: U32, +error: KTerm, +acc: String) -> String:
  match w7_c:
    case True{}:
      fpe_message(source, start, offset, error, f_choose(String, String.is_empty(nm(kid(error, 2))), u => "'" ++ String.reverse(acc) ++ "'", u => nm(kid(error, 2))))
    case False{}:
      w7_br_379(String.is_empty(rest), source, rest, line, column, offset, start, error, acc)

@unsafe
def fpe_range(+source: String, +rest: String, +line: U32, +column: U32, +offset: U32, +start: U32, +error: KTerm, +acc: String) -> String:
  w7_br_380(U32.is_eq(line, ix(kid(error, 2))) && U32.is_eq(column, qt(kid(error, 2))), source, rest, line, column, offset, start, error, acc)

# Module: src/front/parser.bend:600
@unsafe
def w7_br_381(w7_c: Bool, +source: String, +rest: String, +offset: U32, +error: KTerm) -> String:
  match w7_c:
    case True{}:
      fpe_message(source, offset, offset, error, "end of input")
    case False{}:
      fpe_eof(source, f_tail(rest), U32.add(offset, dg_units(f_head(rest))), error)

@unsafe
def fpe_eof(+source: String, +rest: String, +offset: U32, +error: KTerm) -> String:
  w7_br_381(String.is_empty(rest), source, rest, offset, error)

# Module: src/front/parser.bend:610
@unsafe
def w7_br_390(w7_c: Bool, +source: String, +begin: U32, +end: U32, +error: KTerm, +observed: String) -> String:
  match w7_c:
    case True{}:
      nm(error)
    case False{}:
      fpe_message(source, begin, end, error, observed)

@unsafe
def fpe_point_message(+source: String, +begin: U32, +end: U32, +error: KTerm, +observed: String) -> String:
  w7_br_390(f_eq(tg(kid(error, 1)), "ParseObservedPoint") && String.is_empty(observed), source, begin, end, error, observed)


# Match diagnostics need the original spelling, including parentheses and the
# use-site name of a constructor introduced by an earlier pattern substitution.
# Keep this rejection-only payload until the existing source owner is available.

# Module: src/front/parser.bend:743
@unsafe
def w7_br_417(w7_c: Bool, +s: String) -> KTerm:
  match w7_c:
    case True{}:
      f_char_literal(f_tail(s))
    case False{}:
      w7_br_416(f_contains(s, '.'), s)

@unsafe
def f_string(s):
  f_string_at(s, atom("Absent"))

# Module: src/front/elaborate.bend:181
@unsafe
def w7_br_428(w7_c: Bool, +s: String, +origin: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      kl_make("String", 0, "")
    case False{}:
      f_string_decoded_at(f_decode_char(s), origin)

@unsafe
def f_string_at(+s: String, +origin: KTerm) -> KTerm:
  w7_br_428(Char.is_eq(f_head(s), '"'), s, origin)

# Module: src/front/sugar.bend:8
@unsafe
def f_do_header_name(+name: String, +input: FInput) -> KTerm:
  match input:
    case FInput{tokens, context}:
      match context:
        case FParseContext{scope, env, next}: f_context_resolve(kt_span("Ref", name, 0, 1, Nil{}, U32.add(f_begin(input), 1), U32.add(f_begin(input), 1)), scope)

# Module: src/front/sugar.bend:49
@unsafe
def f_do_return(+monad: KTerm, +position: U32, +begin: U32, +p: FParsed) -> FParsed:
  match p:
    case FParsed{n, ts}:
      f_choose(FParsed, f_context_stop(n), u => p, u => f_do_result(kt_span("FDo", nm(monad), position, 1, [monad, n], begin, f_begin(f_space(ts))), ts))

# Module: src/front/sugar.bend:97
@unsafe
def f_do_tail(+monad: KTerm, +binder: KTerm, +ty: KTerm, +pure: Bool, +v: KTerm, +begin: U32, +end: U32, +p: FParsed) -> FParsed:
  match p:
    case FParsed{body, ts}:
      f_choose(FParsed, f_context_stop(body), u => p,
        u => f_choose(FParsed, pure,
          u => FParsed{kt_span("Let", "", 0, 1, [kt_span("Bind", nm(binder), ix(binder), qt(binder), [kt_span("Ann", "", 0, 1, [v, ty], begin, end)], kb(binder), ke(binder)), body], begin, end), ts},
          u => f_do_result(kt_span("FDo", nm(monad), ix(binder), 2, [monad, ty, v, k_lam(nm(binder), ix(binder), qt(binder), [body], begin, end, True{})], begin, end), ts)))

# Module: src/front/sugar.bend:165
@unsafe
def f_do_result(+term: KTerm, +input: FInput) -> FParsed:
  match input:
    case FInput{tokens, context}:
      match context:
        case FParseContext{scope, env, next}:
          +name = nm(term) ++ f_choose(String, U32.is_eq(qt(term), 0), u => "", u => f_choose(String, U32.is_eq(qt(term), 1), u => ".pure", u => ".bind"))
          f_do_resolved(term, input, scope, f_context_resolve(kt_span("Ref", name, 0, 1, Nil{}, f_begin(f_space(input)), f_begin(f_space(input))), scope))

# Module: src/front/sugar.bend:174
@unsafe
def f_group_namespace(n, p):
  match p:
    case FParsed{ty, ts}:
      f_choose(FParsed, f_eq(tg(ty), "Error"),
        u => FParsed{f_choose(KTerm, String.is_empty(f_error_term(n)), u => ty, u => n), ts},
        u => f_expect(FParsed{f_context_namespace_at(n, ty, ts, f_begin(f_space(ts))), ts}, ")"))

# Module: src/front/unicode.bend:32
@unsafe
def f_decode_char(s):
  w7_br_443(String.is_empty(s), s)

# Module: src/front/unicode.bend:36
@unsafe
def f_char_literal(s):
  f_char_decoded(f_decode_char(s))

# Module: src/front/unicode.bend:58
@unsafe
def f_string_decoded_at(+d: FDecoded, +origin: KTerm) -> KTerm:
  match d:
    case FDecoded{code, rest, err}:
      f_choose(KTerm, String.is_empty(err), u => f_string_cons(code, f_string_at(rest, origin)),
        u => f_choose(KTerm, U32.is_gt(kb(origin), 0), u => f_escape_seek(origin, f_tail(nm(origin)), err), u => kt("Error", err, 0, 0, Nil{})))

# Module: src/front/unicode.bend:78
@unsafe
def w7_br_451(w7_c: Bool, +origin: KTerm, +rest: String, +legacy: String) -> KTerm:
  match w7_c:
    case True{}:
      kt("Error", legacy, 0, 0, Nil{})
    case False{}:
      f_escape_decoded(origin, rest, legacy, f_decode_char(rest))

@unsafe
def f_escape_seek(+origin: KTerm, +rest: String, +legacy: String) -> KTerm:
  w7_br_451(String.is_empty(rest) || Char.is_eq(f_head(rest), '"'), origin, rest, legacy)

# Module: src/front/unicode.bend:83
@unsafe
def f_escape_decoded(+origin: KTerm, +rest: String, +legacy: String, +decoded: FDecoded) -> KTerm:
  match decoded:
    case FDecoded{code, tail, error}:
      f_choose(KTerm, String.is_empty(error), u => f_escape_seek(origin, tail, legacy),
        u => fpe_expected_at(k_with_span(origin, U32.add(U32.sub(ke(origin), dg_width(rest)), 2), U32.add(U32.sub(ke(origin), dg_width(rest)), 2)), legacy, "an escape (\\n \\t \\r \\0 \\\\ \\\' \\\" \\u{1F600})", "'" ++ SCon{f_head(f_tail(f_tail(rest))), ""} ++ "'"))

# Invalid scalar escapes keep the reference constructor-chain representation.

# Module: src/front/unicode.bend:91
@unsafe
def w7_br_468(w7_c: Bool, +size: KTerm, +ty: KTerm, +count: Bool, +ts: FInput, +n: KTerm) -> FParsed:
  match w7_c:
    case True{}:
      FParsed{n, ts}
    case False{}:
      f_array_sized(n, ty, ts, f_choose(KTerm, count, u => f_array_depth_at(size, f_array_nat_depth(size, 0)), u => size))

@unsafe
def f_array_namespaced(+size: KTerm, +ty: KTerm, +count: Bool, +ts: FInput, +n: KTerm) -> FParsed:
  w7_br_468(f_context_stop(n), size, ty, count, ts, n)

# Module: src/front/literals_arrays.bend:171
@unsafe
def f_array_sized(+n: KTerm, +ty: KTerm, +ts: FInput, +depth: KTerm) -> FParsed:
  w7_br_469(f_context_stop(depth), n, ty, ts, depth)

# Module: src/front/literals_arrays.bend:175
@unsafe
def f_context_namespace(+term: KTerm, +ty: KTerm, +input: FInput) -> KTerm:
  f_context_namespace_at(term, ty, input, f_previous_end(input))

# Module: src/front/literals_arrays.bend:185
@unsafe
def w7_br_473(w7_c: Bool, +term: KTerm, +ty: KTerm, +input: FInput, +cursor: U32) -> KTerm:
  match w7_c:
    case True{}:
      f_context_namespace_let(term, f_context_namespace_at(f_last(ks(term)), ty, input, cursor))
    case False{}:
      f_context_namespace_head(term, ty, input, cursor, f_namespace_head(term))

@unsafe
def f_context_namespace_at(+term: KTerm, +ty: KTerm, +input: FInput, +cursor: U32) -> KTerm:
  w7_br_473(f_eq(tg(term), "Let"), term, ty, input, cursor)

# Module: src/front/literals_arrays.bend:190
@unsafe
def w7_br_474(w7_c: Bool, +term: KTerm, +ty: KTerm, +input: FInput, +cursor: U32) -> KTerm:
  match w7_c:
    case True{}:
      f_context_namespace_type(term, f_namespace_head(ty), input, cursor)
    case False{}:
      term

@unsafe
def w7_br_475(w7_c: Bool, +term: KTerm, +ty: KTerm, +input: FInput, +cursor: U32, +head: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      f_context_namespace_app(term, f_context_namespace_at(kid(term, 0), ty, input, cursor), f_context_namespace_at(kid(term, 1), ty, input, cursor))
    case False{}:
      w7_br_474(f_implicit_operator(nm(head)), term, ty, input, cursor)

@unsafe
def w7_br_476(w7_c: Bool, +term: KTerm, +ty: KTerm, +input: FInput, +cursor: U32, +head: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      w7_br_475(f_eq(tg(term), "App"), term, ty, input, cursor, head)
    case False{}:
      term

@unsafe
def f_context_namespace_head(+term: KTerm, +ty: KTerm, +input: FInput, +cursor: U32, +head: KTerm) -> KTerm:
  w7_br_476(f_namespace_operator(head, input), term, ty, input, cursor, head)

# Module: src/front/literals_arrays.bend:197
@unsafe
def f_context_namespace_type(+term: KTerm, +ty: KTerm, +input: FInput, +cursor: U32) -> KTerm:
  match input:
    case FInput{tokens, context}:
      match context:
        case FParseContext{scope, env, next}:
          f_choose(KTerm, f_eq(tg(ty), "Var") || f_eq(tg(ty), "FName") || f_eq(tg(ty), "Ref") || f_eq(tg(ty), "ADT"),
            u => f_context_namespace_resolved(term, f_context_resolve(kt_span("Ref", nm(ty) ++ nm(term), 0, 1, Nil{}, cursor, cursor), scope)),
            u => fpe_message_at(ty, "expected an operator type name", "a type name after : (the operators' namespace)"))

# Module: src/front/literals_arrays.bend:211
@unsafe
def f_ctor_index(+book: List<&2,KDef>, +tree: KDef) -> KDef:
  match book:
    case Nil{}: tree
    case Con{d, rest}: f_ctor_index_def(d, f_ctor_index(rest, tree))

# Module: src/front/validate.bend:60
@unsafe
def f_ctor_index_def(+d: KDef, +tree: KDef) -> KDef:
  +children = f_ctor_index(dc(d), tree)
  f_choose(KDef, f_eq(dk(d), "Ctr"), u => index_set(children, d, index_hash(dn(d), 2166136261), 32), u => children)

# Module: src/front/validate.bend:65
@unsafe
def f_graph_fresh_names(todo, done):
  match todo:
    case Nil{}:
      ""
    case Con{+d, rest}:
      f_graph_fresh_hashed(rest, done, d, index_hash(dn(d), 2166136261))

# Module: src/load/graph.bend:268
@unsafe
def w7_br_520(w7_c: Bool, +rest: List<&2,KDef>, +done: KDef, +d: KDef, +hash: U32) -> String:
  match w7_c:
    case True{}:
      f_graph_fresh_names(rest, index_set(done, d, hash, 32))
    case False{}:
      "expected a fresh name (duplicate declaration: " ++ dn(d) ++ ")"

@unsafe
def f_graph_fresh_name(
  +rest: List<&2,KDef>,
  +done: KDef,
  +d: KDef,
  +hash: U32,
  +old: KDef,
) -> String:
  w7_br_520(f_eq(dk(old), "Absent") || (f_eq(dk(old), "Def") && f_eq(dk(d), "Def") && f_eq(tg(dv(old)), "Absent") && Bool.not(f_eq(tg(dv(d)), "Absent")) && (Bool.not(db(old)) || db(d))), rest, done, d, hash)

# Module: src/load/graph.bend:278
@unsafe
def f_graph_fresh_hashed(rest, done, d, hash):
  f_graph_fresh_name(rest, done, d, hash, index_find(done, dn(d), hash, 32))

# Refine only the error already selected by graph validation. Success is O(1).

# Module: src/load/graph.bend:347
@unsafe
def f_prefix_names_extend(+defs: List<&2,KDef>, +names: KDef) -> KDef:
  match defs:
    case Nil{}: names
    case Con{d, rest}: f_prefix_names_extend(rest, index_set(names, d, index_hash(dn(d), 2166136261), 32))

# Module: src/load/prefix.bend:201
@unsafe
def f_prefix_ctors_extend(+defs: List<&2,KDef>, +ctors: KDef) -> KDef:
  match defs:
    case Nil{}: ctors
    case Con{d, rest}:
      +hash = index_hash(dn(d), 2166136261)
      +next = kc(KDef, p88_string_eq(dk(d), "Ctr") && p88_string_eq(dk(index_find(ctors, dn(d), hash, 32)), "Absent"), u => index_set(ctors, d, hash, 32), u => ctors)
      f_prefix_ctors_extend(rest, f_prefix_ctors_extend(dc(d), next))

# Module: src/load/prefix.bend:210
@unsafe
def dg_trace_detail(e, ctx, t, r, detail):
  KChecking{kt("DTrace", cn(e), 0, qt(detail), [kid(detail, 0), kid(detail, 1), kt("DCtx", "", 0, 0, ctx), t, kt("DTrail", "", 0, 0, [t]), dg_text(kc(String, p88_string_eq(ce(r), "constructor requires a datatype goal"), u => dg_datatype_braces(cb(e),nm(t)), u => ""))]), cy(r), cs(r), ce(r), rw(r), rx(r)}

# Module: src/diagnostic/trace.bend:82
@unsafe
def w7_br_547(w7_c: Bool, +e: KEnv, +t: KTerm, +ty: KTerm, +code: String) -> KTerm:
  match w7_c:
    case True{}:
      dg_pair(ty, dg_text("non-inferrable term"))
    case False{}:
      w7_br_546(p88_string_eq(code, "constructor requires a datatype goal"), e, t, ty, code)

@unsafe
def w7_br_548(w7_c: Bool, +e: KEnv, +t: KTerm, +ty: KTerm, +code: String) -> KTerm:
  match w7_c:
    case True{}:
      dg_pair(dg_text(kc(String, (p98_tag_eq(t, "Ctr") || core_literal(t)) && p88_string_eq(dg_family(cb(e), nm(kc(KTerm, core_literal(t), u => core_literal_step(t), u => t))), ""), u => "a declared constructor", u => "an annotated term (cannot infer)")), t)
    case False{}:
      w7_br_547(p88_string_eq(code, "lambda requires a function type") || p88_string_eq(code, "matcher requires a function type") || p88_string_eq(code, "reflexivity requires equality goal"), e, t, ty, code)

@unsafe
def w7_br_549(w7_c: Bool, +e: KEnv, +t: KTerm, +ty: KTerm, +code: String) -> KTerm:
  match w7_c:
    case True{}:
      dg_pair(ty, t)
    case False{}:
      w7_br_548(p88_string_eq(code, "cannot infer: annotation required"), e, t, ty, code)

@unsafe
def w7_br_550(w7_c: Bool, +e: KEnv, +t: KTerm, +ty: KTerm, +code: String) -> KTerm:
  match w7_c:
    case True{}:
      dg_pair(dg_text("a family instance (write " ++ name_key(nm(t)) ++ "<..>)"), t)
    case False{}:
      w7_br_549(p88_string_eq(code, "unresolved hole"), e, t, ty, code)

@unsafe
def w7_br_565(w7_c: Bool, +e: KEnv, +t: KTerm, +ty: KTerm, +ctr: KDef) -> KChecking:
  match w7_c:
    case True{}:
      dg_bad_detail(cw(e), "constructor does not belong to goal or field count differs", dg_text(name_key(nm(t)) ++ " with " ++ U32.show(da(ctr)) ++ kc(String, U32.is_eq(da(ctr), 1), u => " field", u => " fields")), t)
    case False{}:
      w7_br_564(p88_string_eq(dg_family(cb(e), nm(t)), ""), e, t, ty)

@unsafe
def dg_ctor_error(e, t, ty, ctr):
  w7_br_565(Bool.not(p88_string_eq(dk(ctr), "Absent")) && Bool.not(has_name(rm(ty), nm(t))), e, t, ty, ctr)

# The checker verdict stays unchanged; only rejection metadata differs.

# Module: src/diagnostic/produce.bend:197
@unsafe
def j_context(book, env, xs):
  match xs:
    case Nil{}:
      env
    case Con{h, Nil{}}:
      env
    case Con{h, rest}:
      Con{kt("Env", "", ix(h), 0, Con{j_type(book, env, kid(h, 0)), Nil{}}), j_context(book, env, rest)}

# Module: src/back/common/queries.bend:77
@unsafe
def j_arm_type(book, ty, name):
  j_arm_type_domain(book, ty, name, wnf(book, kid(ty, 0)))

# Checked books have unique constructor names. Like the Phase55 arity query,
# use the normalized matcher owner only when both telescope and ADT are known.
# Unknown shapes and absent owner constructors keep the global first-match path.

# Module: src/back/common/queries.bend:148
@unsafe
def j_arm_type_domain(+book: List<&2,KDef>, +ty: KTerm, +name: String, +domain: KTerm) -> KTerm:
  j_arm_tel(book, j_specialize(book,
    dt(kc(KDef, p98_tag_eq(ty, "All") && p98_tag_eq(domain, "ADT"),
      u => j_layout_ctor(book, domain, name), u => j_find_ctor(book, name))), ks(domain)), kid(ty, 1))

# Module: src/back/common/queries.bend:160
@unsafe
def w7_br_575(w7_c: Bool, +book: List<&2,KDef>, +d: KDef) -> U32:
  match w7_c:
    case True{}:
      jd_domains(book, dt(d))
    case False{}:
      U32.add(da(d), U32.min(jd_raise(book, dv(d), da(d)), U32.sub(jd_domains(book, dt(d)), da(d))))

@unsafe
def jd_arity(+book: List<&2,KDef>, +d: KDef) -> U32:
  w7_br_575(p98_tag_eq(j_strip(dv(d)), "Foreign"), book, d)

# Pinned fun_of/def_raise: open common lambda prefixes beyond declared formals,
# including prefixes shared by every matcher arm, capped by the type telescope.

# Module: src/back/common/arity.bend:15
@unsafe
def w7_br_589(w7_c: Bool, +t: KTerm) -> String:
  match w7_c:
    case True{}:
      j_literal_ctor(t)
    case False{}:
      ""

@unsafe
def w7_br_590(w7_c: Bool, +t: KTerm) -> String:
  match w7_c:
    case True{}:
      w7_br_588(core_nat(t), t)
    case False{}:
      w7_br_589(p98_tag_eq(t, "Ctr"), t)

@unsafe
def w7_br_595(w7_c: Bool, +t: KTerm) -> String:
  match w7_c:
    case True{}:
      j_word_text(j_word(j_strip(kid(t, 0)), 0, 0), False{})
    case False{}:
      w7_br_594(p88_string_eq(nm(t), "F32"), t)

@unsafe
def j_literal_ctor(t):
  w7_br_595(p88_string_eq(nm(t), "U32"), t)

# Module: src/back/js/literals.bend:33
@unsafe
def j_printable(book, ty, seen, fuel):
  j_printable_done(j_printable_head(book, wnf(book, ty), seen, fuel))

# Module: src/back/js/validate.bend:35
@unsafe
def j_printable_head(book, ty, seen, fuel):
  kc(Maybe<&2, List<&2, String>>, p98_tag_eq(ty, "Eql"), u => Some{seen}, u => kc(Maybe<&2, List<&2, String>>, p98_tag_eq(ty, "ADT") && Bool.not(p88_string_eq(nm(ty), "IO.OP")) && p88_string_eq(dk(lookup(book, nm(ty))), "ADT"), u => j_printable_adt(book, ty, seen, fuel), u => None{}))

# Module: src/back/js/validate.bend:59
@unsafe
def j_printable_adt(book, ty, seen, fuel):
  kc(Maybe<&2, List<&2, String>>, String.contains("|U32|F32|Nat|Char|String|", "|" ++ nm(ty) ++ "|") || has_name(seen, term_key(ty)), u => Some{seen}, u => kc(Maybe<&2, List<&2, String>>, p88_string_eq(nm(ty), "Array"), u => j_printable_head(book, wnf(book, kid(ty, 0)), seen, fuel), u => j_printable_ctors(book, dc(lookup(book, nm(ty))), ks(ty), Con{term_key(ty), seen}, fuel)))

# Module: src/back/js/validate.bend:71
@unsafe
def j_printable_ctors(book, ctors, params, seen, fuel):
  match ctors:
    case Nil{}:
      Some{seen}
    case Con{d, rest}:
      j_printable_ctors_more(book, rest, params, fuel,
        j_printable_fields(book, j_specialize(book, dt(d), params), seen, fuel))

# Module: src/back/js/validate.bend:80
@unsafe
def j_printable_ctors_more(+book: List<&2,KDef>, +ctors: List<&2,KDef>,
  +params: List<&2,KTerm>, +fuel: U32, +done: Maybe<&2,List<&2,String>>) -> Maybe<&2,List<&2,String>>:
  match done:
    case None{}: None{}
    case Some{seen}: j_printable_ctors(book, ctors, params, seen, fuel)

# Module: src/back/js/validate.bend:94
@unsafe
def j_printable_fields(book, ty, seen, fuel):
  kc(Maybe<&2, List<&2, String>>, p98_tag_eq(ty, "All"), u =>
    kc(Maybe<&2, List<&2, String>>, U32.is_eq(qt(ty), 0), u => None{}, u =>
      j_printable_fields_more(book, kid(ty, 1), fuel,
        j_printable_head(book, wnf(book, kid(ty, 0)), seen, fuel))), u => Some{seen})

# Module: src/back/js/validate.bend:101
@unsafe
def j_printable_fields_more(+book: List<&2,KDef>, +ty: KTerm,
  +fuel: U32, +done: Maybe<&2,List<&2,String>>) -> Maybe<&2,List<&2,String>>:
  match done:
    case None{}: None{}
    case Some{seen}: j_printable_fields(book, ty, seen, fuel)

# Module: src/back/js/validate.bend:150
@unsafe
def j_layout_open(
  +book: List<&2, KDef>,
  +ty: KTerm,
) -> Bool:
  j_layout_open_head(book, w7b_wnf(book, ty))

# Module: src/back/js/validate.bend:169
@unsafe
def w7_br_602(w7_c: Bool, +book: List<&2, KDef>, +ty: KTerm) -> Bool:
  match w7_c:
    case True{}:
      j_layout_element_open(book, kid(ty, 0))
    case False{}:
      False{}

@unsafe
def j_layout_open_head(book, ty):
  w7_br_602(p98_tag_eq(ty, "ADT") && p88_string_eq(nm(ty), "Array"), book, ty)

# Module: src/back/js/validate.bend:181
@unsafe
def w7_br_605(w7_c: Bool, +book: List<&2, KDef>, +element: KTerm) -> Bool:
  match w7_c:
    case True{}:
      j_layout_element_open(book, j_strip(element))
    case False{}:
      False{}

@unsafe
def j_layout_intrinsic(book, f, element):
  w7_br_605(j_layout_array_intrinsic(book, f), book, element)

# An equality has no live layout, even when its two sides remain open.
# Keep normalization inside the original demanded Array branch.

# Module: src/back/js/validate.bend:282
@unsafe
def w7b_jl_fty_if(isAnn: Bool, +book: List<&2, KDef>, +fn: KTerm) -> KTerm:
  match isAnn:
    case True{}: w7b_wnf(book, kid(fn, 1))
    case False{}: w7b_wnf(book, j_type(book, Nil{}, fn))

@unsafe
def j_primitive_type(+book: List<&2,KDef>, +ty: KTerm, +name: String) -> Bool:
  p98_tag_eq(ty, "ADT") && p88_string_eq(nm(ty), name) && U32.is_eq(terms_len(ks(ty)), 0) &&
  List.is_empty(&2, String, rm(ty)) &&
  kc(Bool, p88_string_eq(name, "Nat"), u => j_u32_native_ctor(book, "Nat", "Zero") && j_u32_native_ctor(book, "Nat", "Succ"), u =>
  kc(Bool, p88_string_eq(name, "F32"), u => j_u32_native_ctor(book, "F32", "F32") && j_u32_native_book(book), u =>
  kc(Bool, p88_string_eq(name, "Bool"), u => j_u32_native_ctor(book, "Bool", "False") && j_u32_native_ctor(book, "Bool", "True"), u => j_u32_native_book(book))))

# Module: src/back/js/primitive.bend:33
@unsafe
def j_primitive_telescope(+book: List<&2,KDef>, +ty: KTerm, +name: String, +at: U32, +left: U32) -> Bool:
  +head = wnf(book, ty)
  kc(Bool, U32.is_eq(left, 0), u => j_primitive_type(book, head, j_primitive_result(name)), u =>
    kc(Bool, p98_tag_eq(head, "All") && Bool.not(U32.is_eq(qt(head), 0)) &&
      j_primitive_type(book, wnf(book, kid(head, 0)), j_primitive_input(name, at)),
      u => j_primitive_telescope(book, kid(head, 1), name, U32.inc(at), U32.sub(left, 1)), u => False{}))

# Module: src/back/js/primitive.bend:41
@unsafe
def w7_br_612(w7_c: Bool, +book: List<&2,KDef>, +d: KDef, +arity: U32) -> Bool:
  match w7_c:
    case True{}:
      j_primitive_telescope(book, dt(d), dn(d), 0, arity)
    case False{}:
      False{}

@unsafe
def j_primitive_definition(+book: List<&2,KDef>, +d: KDef, +arity: U32) -> Bool:
  w7_br_612(db(d) && p88_string_eq(dk(d), "Def") && U32.is_eq(dx(d), 0) && Bool.not(p98_tag_eq(j_strip(dv(d)), "Foreign")) && U32.is_eq(da(d), arity) && U32.is_eq(j_primitive_arity(dn(d)), arity), book, d, arity)

# Module: src/back/js/primitive.bend:48
@unsafe
def j_pure_list_head(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  +owner = lookup(book, "List")
  p98_tag_eq(ty, "ADT") && p88_string_eq(nm(ty), "List") && U32.is_eq(terms_len(ks(ty)), 2) &&
    List.is_empty(&2, String, rm(ty)) && p98_tag_eq(kid(ty, 0), "Qua") && U32.is_eq(qt(kid(ty, 0)), 2) &&
    List.is_empty(&2, KTerm, ks(kid(ty, 0))) && p88_string_eq(dk(owner), "ADT") && db(owner) &&
    U32.is_eq(da(owner), 2) && U32.is_eq(dx(owner), 0) && U32.is_eq(j_region_def_count(dc(owner)), 2) &&
    j_list_ground_kind(wnf(book, j_specialize(book, dt(owner), ks(ty)))) &&
    j_pure_native_ctor(lookup(dc(owner), "Nil"), "Nil", 0) && j_pure_native_ctor(lookup(dc(owner), "Con"), "Con", 2)

# Module: src/back/js/jpure.bend:450
@unsafe
def j_pure_sigma_head(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  +owner = lookup(book, "Sigma")
  +family = kid(ty, 3)
  p98_tag_eq(ty, "ADT") && p88_string_eq(nm(ty), "Sigma") && U32.is_eq(terms_len(ks(ty)), 4) &&
    List.is_empty(&2, String, rm(ty)) && p88_string_eq(dk(owner), "ADT") && db(owner) &&
    U32.is_eq(da(owner), 4) && U32.is_eq(dx(owner), 0) && U32.is_eq(j_region_def_count(dc(owner)), 1) &&
    p98_tag_eq(kid(ty, 0), "Qua") && (U32.is_eq(qt(kid(ty, 0)), 1) || U32.is_eq(qt(kid(ty, 0)), 2)) && List.is_empty(&2, KTerm, ks(kid(ty, 0))) &&
    p98_tag_eq(kid(ty, 1), "Qua") && (U32.is_eq(qt(kid(ty, 1)), 1) || U32.is_eq(qt(kid(ty, 1)), 2)) && List.is_empty(&2, KTerm, ks(kid(ty, 1))) &&
    p98_tag_eq(family, "Lam") && U32.is_eq(qt(family), 1) && U32.is_eq(terms_len(ks(family)), 1) &&
    List.is_empty(&2, String, rm(family)) && j_pure_shape_bound([family], 256) &&
    U32.is_eq(j_region_counter_uses([kid(family, 0)], ix(family), 0), 0) &&
    j_map_sigma_kind(wnf(book, j_specialize(book, dt(owner), ks(ty))), qt(kid(ty, 0)), qt(kid(ty, 1))) &&
    j_pure_native_ctor(lookup(dc(owner), "Tuple"), "Tuple", 2)

# Parameterless canonical user/scalar owners need no alpha comparison. List and
# independent Sigma compare their complete normalized specialization recursively.

# Module: src/back/js/jpure.bend:484
@unsafe
def w7_br_617(w7_c: Bool, +book: List<&2,KDef>, +name: String, +count: U32) -> Bool:
  match w7_c:
    case True{}:
      j_string_owner_header(book, name, count)
    case False{}:
      False{}

@unsafe
def j_string_owner(+book: List<&2,KDef>, +ty: KTerm, +name: String, +count: U32) -> Bool:
  w7_br_617(p98_tag_eq(ty, "ADT") && p88_string_eq(nm(ty), name) && List.is_empty(&2, KTerm, ks(ty)) && List.is_empty(&2, String, rm(ty)), book, name, count)

# Module: src/back/js/jpure.bend:578
@unsafe
def w7_br_618(w7_c: Bool, +book: List<&2,KDef>) -> Bool:
  match w7_c:
    case True{}:
      j_string_char_type_fields(book)
    case False{}:
      False{}

@unsafe
def j_string_char_type_fields(+book: List<&2,KDef>) -> Bool:
  +c = lookup(dc(lookup(book, "Char")), "Chr")
  +tel = wnf(book, dt(c))
  j_pure_native_ctor(c, "Chr", 1) &&
    p98_tag_eq(tel, "All") && U32.is_eq(qt(tel), 1) && U32.is_eq(terms_len(ks(tel)), 2) &&
    j_primitive_type(book, wnf(book, kid(tel, 0)), "U32") && j_string_owner(book, wnf(book, kid(tel, 1)), "Char", 1)

# Module: src/back/js/jpure.bend:598
@unsafe
def j_map_cmp_type(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  +owner = lookup(book, "Cmp")
  +kind = wnf(book, dt(owner))
  j_map_cmp_nominal(ty) &&
    p88_string_eq(dk(owner), "ADT") && db(owner) && U32.is_eq(da(owner), 0) && U32.is_eq(dx(owner), 0) &&
    U32.is_eq(j_region_def_count(dc(owner)), 3) && p98_tag_eq(kind, "Typ") && U32.is_eq(terms_len(ks(kind)), 1) &&
    p98_tag_eq(kid(kind, 0), "Qua") && U32.is_eq(qt(kid(kind, 0)), 2) &&
    j_map_cmp_ctor(book, lookup(dc(owner), "LT"), "LT", ty) &&
    j_map_cmp_ctor(book, lookup(dc(owner), "EQ"), "EQ", ty) &&
    j_map_cmp_ctor(book, lookup(dc(owner), "GT"), "GT", ty)

# ADT quant0/1 is source-node metadata, not a Cmp quantity parameter. The
# canonical owner has no parameters; constructors must terminate at this exact
# nominal zeroarity type. No recursive type proof or metadata-erasing rewrite.

# Module: src/back/js/jpure.bend:1366
@unsafe
def j_map_maybe_head(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  +owner = lookup(book, "Maybe")
  p98_tag_eq(ty, "ADT") && p88_string_eq(nm(ty), "Maybe") && U32.is_eq(terms_len(ks(ty)), 2) && List.is_empty(&2,String, rm(ty)) &&
    p98_tag_eq(kid(ty, 0), "Qua") && U32.is_eq(qt(kid(ty, 0)), 2) && List.is_empty(&2,KTerm, ks(kid(ty, 0))) &&
    p88_string_eq(dk(owner), "ADT") && db(owner) && U32.is_eq(da(owner), 2) && U32.is_eq(dx(owner), 0) &&
    U32.is_eq(j_region_def_count(dc(owner)), 2) && j_list_ground_kind(wnf(book, j_specialize(book, dt(owner), ks(ty)))) &&
    j_pure_native_ctor(lookup(dc(owner), "None"), "None", 0) && j_pure_native_ctor(lookup(dc(owner), "Some"), "Some", 1)

# Module: src/back/js/jpure.bend:1385
@unsafe
def w7_br_620(w7_c: Bool, +book: List<&2,KDef>) -> Bool:
  match w7_c:
    case True{}:
      j_pure_unit_constructor(book, lookup(dc(lookup(book, "Unit")), "Unit"))
    case False{}:
      False{}

@unsafe
def j_pure_unit_constructor(+book: List<&2,KDef>, +c: KDef) -> Bool:
  j_pure_native_ctor(c, "Unit", 0) && j_string_owner(book, wnf(book, dt(c)), "Unit", 1)

# Module: src/back/js/region.bend:53
@unsafe
def j_region_scalar(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  +head = wnf(book, ty)
  String.contains("|U32|Bool|Nat|F32|", "|" ++ nm(head) ++ "|") && j_primitive_type(book, head, nm(head))

# Module: src/back/js/region.bend:135
@unsafe
def j_callback_fun_type(+book: List<&2,KDef>, +ty: KTerm, +arg: String) -> Bool:
  +h = wnf(book, ty)
  p98_tag_eq(h, "All") && U32.is_eq(qt(h), 1) &&
    j_primitive_type(book, wnf(book, kid(h, 0)), arg) &&
    j_primitive_type(book, wnf(book, kid(h, 1)), "U32")

# Module: src/back/js/region.bend:1068
@unsafe
def j_callback_factory_type(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  +h = wnf(book, ty)
  p98_tag_eq(h, "All") && Bool.not(U32.is_eq(qt(h), 0)) &&
    j_primitive_type(book, wnf(book, kid(h, 0)), "Nat") &&
    j_callback_fun_type(book, kid(h, 1), "U32")

# Module: src/back/js/region.bend:1075
@unsafe
def j_callback_erased_prefix(+book: List<&2,KDef>, +ty: KTerm, +body: KTerm, +left: U32) -> Bool:
  +h = wnf(book, ty)
  +t = j_strip(body)
  kc(Bool, U32.is_eq(left, 0), u => True{}, u =>
    p98_tag_eq(h, "All") && U32.is_eq(qt(h), 0) && j_callback_type_domain(book, kid(h, 0)) &&
    p98_tag_eq(t, "Lam") && U32.is_eq(qt(t), 1) && U32.is_eq(terms_len(ks(t)), 1) &&
    j_callback_runtime_absent(kid(t, 0), ix(t), 2048) &&
    j_callback_erased_prefix(book, kid(h, 1), kid(t, 0), U32.sub(left, 1)))

# Module: src/back/js/region.bend:1110
@unsafe
def j_callback_live_compose_type(+book: List<&2,KDef>, +ty: KTerm, +body: KTerm, +left: U32) -> Bool:
  +h = wnf(book, ty)
  +t = j_strip(body)
  kc(Bool, U32.is_eq(left, 0), u => j_primitive_type(book, h, "U32"), u =>
    p98_tag_eq(h, "All") && U32.is_eq(qt(h), 1) && p98_tag_eq(t, "Lam") &&
    U32.is_eq(qt(t), 1) && U32.is_eq(terms_len(ks(t)), 1) &&
    kc(Bool, U32.is_eq(left, 1), u => j_primitive_type(book, wnf(book, kid(h, 0)), "U32"),
      u => j_callback_fun_type(book, kid(h, 0), "U32")) &&
    j_callback_live_compose_type(book, kid(h, 1), kid(t, 0), U32.sub(left, 1)))

# Check exact composition lambda binders, including erased prefix positions.

# Module: src/back/js/region.bend:1122
@unsafe
def j_callback_compose_on(+book: List<&2,KDef>, +d: KDef) -> Bool:
  +f = j_fusion_binder(dv(d), 3)
  +g = j_fusion_binder(dv(d), 4)
  +x = j_fusion_binder(dv(d), 5)
  +body = j_fusion_after(dv(d), 6)
  +inner = j_strip(kid(body, 1))
  j_fusion_def(d, 5) && j_u32_bounded([dt(d), dv(d)], 2048) &&
    j_callback_erased_prefix(book, dt(d), dv(d), 3) &&
    j_callback_live_compose_type(book, j_specialize(book, dt(d), [ref("U32"), ref("U32"), ref("U32")]), j_fusion_after(dv(d), 3), 3) &&
    p98_tag_eq(f, "Lam") && p98_tag_eq(g, "Lam") && p98_tag_eq(x, "Lam") &&
    p98_tag_eq(body, "App") && U32.is_eq(terms_len(ks(body)), 2) &&
    j_fusion_var(kid(body, 0), ix(g)) && p98_tag_eq(inner, "App") && U32.is_eq(terms_len(ks(inner)), 2) &&
    j_fusion_var(kid(inner, 0), ix(f)) && j_fusion_var(kid(inner, 1), ix(x))

# Module: src/back/js/region.bend:1137
@unsafe
def j_fold_ctors(+book: List<&2,KDef>, +name: String, +ctors: List<&2,KDef>) -> Bool:
  match ctors:
    case Nil{}: True{}
    case Con{c, rest}:
      p88_string_eq(dk(c), "Ctr") && Bool.not(db(c)) && U32.is_eq(dx(c), 0) && U32.is_le(da(c), 2) &&
        j_fold_fields(book, dt(c), name, da(c)) && j_fold_ctors(book, name, rest)

# Module: src/back/js/fold.bend:21
@unsafe
def j_fold_fields(+book: List<&2,KDef>, +ty: KTerm, +owner: String, +left: U32) -> Bool:
  +head = wnf(book, ty)
  kc(Bool, U32.is_eq(left, 0), u => p98_tag_eq(head, "ADT") && p88_string_eq(nm(head), owner) &&
    U32.is_eq(terms_len(ks(head)), 0) && List.is_empty(&2, String, rm(head)), u =>
    p98_tag_eq(head, "All") && Bool.not(U32.is_eq(qt(head), 0)) &&
      (j_primitive_type(book, wnf(book, kid(head, 0)), "U32") ||
        (p98_tag_eq(wnf(book, kid(head, 0)), "ADT") && p88_string_eq(nm(wnf(book, kid(head, 0))), owner) &&
          U32.is_eq(terms_len(ks(wnf(book, kid(head, 0)))), 0) && List.is_empty(&2, String, rm(wnf(book, kid(head, 0)))))) &&
      j_fold_fields(book, kid(head, 1), owner, U32.sub(left, 1)))

# Module: src/back/js/fold.bend:243
@unsafe
def j_list_ground_head(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  p98_tag_eq(ty, "ADT") && p88_string_eq(nm(ty), "List") && U32.is_eq(terms_len(ks(ty)), 2) &&
    List.is_empty(&2, String, rm(ty)) && p98_tag_eq(kid(ty, 0), "Qua") && U32.is_eq(qt(kid(ty, 0)), 2) &&
    U32.is_eq(terms_len(ks(kid(ty, 0))), 0) && j_primitive_type(book, wnf(book, kid(ty, 1)), "U32")

# Module: src/back/js/fold.bend:290
@unsafe
def w7_br_628(w7_c: Bool, +book: List<&2,KDef>, +c: KDef, +ty: KTerm, +fields: U32) -> Bool:
  match w7_c:
    case True{}:
      j_list_ground_fields(book, j_specialize(book, dt(c), ks(ty)), fields)
    case False{}:
      False{}

@unsafe
def j_list_ground_fields(+book: List<&2,KDef>, +tel: KTerm, +left: U32) -> Bool:
  +head = wnf(book, tel)
  kc(Bool, U32.is_eq(left, 0), u => j_list_ground_head(book, head), u =>
    kc(Bool, p98_tag_eq(head, "All") && U32.is_eq(qt(head), 1) &&
      kc(Bool, U32.is_eq(left, 2), u => j_primitive_type(book, wnf(book, kid(head, 0)), "U32"),
        u => j_list_ground_head(book, wnf(book, kid(head, 0)))),
      u => j_list_ground_fields(book, kid(head, 1), U32.sub(left, 1)), u => False{}))

# Preserve prior type domains; a List comparison always checks the full grounded
# parameter identity instead of relying on owner spelling.

# Module: src/back/js/fold.bend:320
@unsafe
def j_region_same_type(+book: List<&2,KDef>, +a: KTerm, +b: KTerm) -> Bool:
  +x = wnf(book, a)
  +y = wnf(book, b)
  kc(Bool, p88_string_eq(nm(x), "List") || p88_string_eq(nm(y), "List"),
    u => j_list_ground_head(book, x) && j_list_ground_head(book, y), u => p88_string_eq(nm(x), nm(y)))
# A checked residual datatype with one remaining constructor needs projection,
# not another tag test. This also preserves the foreign JS lane's trusted values.
# Deep closures use flat factories with explicit lexical captures.

# Module: src/back/js/emit.bend:563
@unsafe
def nc_ctor_owned(book, name):
  p144o_owned(book,name)

@unsafe
def ni_emit(k: String, xs: List<&2, String>) -> String:
  ni_fill(ni_template(k), xs, 0)

# Module: src/back/native/tables.bend:2
@unsafe
def w7_br_650(w7_c: Bool, +name: String, +ws: List<&2, String>, +n: U32) -> N_Emitted:
  match w7_c:
    case True{}:
      N_Emitted{"Term init[1] = { " ++ nc_head(ws) ++ " };\n", "blk_new(e, !NATIVE_SCALAR_ARRAYS, 0, 0, 1, init)", n}
    case False{}:
      w7_br_649(p88_string_eq(name, "ANode"), name, ws, n)

@unsafe
def w7_br_651(w7_c: Bool, +name: String, +ws: List<&2, String>, +n: U32) -> N_Emitted:
  match w7_c:
    case True{}:
      N_Emitted{"", nc_head(ws), n}
    case False{}:
      w7_br_650(p88_string_eq(name, "ALeaf"), name, ws, n)

@unsafe
def w7_br_652(w7_c: Bool, +name: String, +ws: List<&2, String>, +n: U32) -> N_Emitted:
  match w7_c:
    case True{}:
      N_Emitted{"", "term_word(e, " ++ nc_head(ws) ++ ")", n}
    case False{}:
      w7_br_651(p88_string_eq(name, "Chr"), name, ws, n)

@unsafe
def w7_br_653(w7_c: Bool, +name: String, +ws: List<&2, String>, +n: U32) -> N_Emitted:
  match w7_c:
    case True{}:
      N_Emitted{"", "nat_chk(e, " ++ nc_head(ws) ++ " + 1)", n}
    case False{}:
      w7_br_652(p88_string_eq(name, "U32") || p88_string_eq(name, "F32"), name, ws, n)

@unsafe
def nc_ctor_index(ds: List<&2, KDef>, +tree: KDef) -> KDef:
  match ds:
    case Nil{}: tree
    case Con{+d, rest}:
      +next = nt_choose(KDef, p88_string_eq(dk(d), "Ctr") && p88_string_eq(dk(index_find(tree, dn(d), index_hash(dn(d), 2166136261), 32)), "Absent"),
        u => index_set(tree, d, index_hash(dn(d), 2166136261), 32), u => tree)
      nc_ctor_index(rest, nc_ctor_index(dc(d), next))

# Module: src/back/native/bridge.bend:403
@unsafe
def nc_field_count(+book: List<&2, KDef>, +name: String) -> U32:
  w7_br_658(p88_string_eq(name, "Succ") || p88_string_eq(name, "Chr") || p88_string_eq(name, "U32") || p88_string_eq(name, "F32"), book, name)

# Module: src/back/native/bridge.bend:425
@unsafe
def w7_br_663(w7_c: Bool, +name: String, +word: String) -> String:
  match w7_c:
    case True{}:
      "(" ++ word ++ " == 0)"
    case False{}:
      w7_br_662(p88_string_eq(name, "Succ"), name, word)

@unsafe
def w7_br_664(w7_c: Bool, +name: String, +word: String) -> String:
  match w7_c:
    case True{}:
      "native_bool(" ++ word ++ ")"
    case False{}:
      w7_br_663(p88_string_eq(name, "Zero"), name, word)

@unsafe
def w7_br_665(w7_c: Bool, +name: String, +word: String) -> String:
  match w7_c:
    case True{}:
      "(!native_bool(" ++ word ++ "))"
    case False{}:
      w7_br_664(p88_string_eq(name, "True"), name, word)

@unsafe
def nc_condition(+name: String, +word: String) -> String:
  w7_br_665(p88_string_eq(name, "False"), name, word)

# Module: src/back/native/bridge.bend:450
@unsafe
def w5c2_nc_marked_if(ok: Bool, +name: String) -> Bool:
  match ok:
    case True{}: nc_native_primitive(nc_primitive_name(name))
    case False{}: False{}

@unsafe
def nc_native_marked(+d: KDef) -> Bool:
  +name = dn(d)
  w5c2_nc_marked_if(w5c2_may_be_prim_first(name) && Bool.not(p98_tag_eq(nc_unann(dv(d)), "Foreign")), name)

# Module: src/back/native/bridge.bend:521
@unsafe
def w5c2_prim_u(ok: Bool, +c: U32, +k: String) -> Bool:
  match ok:
    case True{}: w5c2_prim_is_u32(k)
    case False{}: w5c2_prim_f(U32.is_eq(c, 102), c, k)

@unsafe
def nc_native_primitive(+prim: String) -> Bool:
  match prim:
    case SNil{}: False{}
    case SCon{h, _}:
      +c = Char.to_u32(h)
      w5c2_prim_u(U32.is_eq(c, 117), c, prim)

# Module: src/back/native/bridge.bend:525
@unsafe
def nc_primitive_arity(+k: String) -> U32:
  match k:
    case SNil{}: 1
    case SCon{h, _}:
      +c = Char.to_u32(h)
      w5c2_arity_u(U32.is_eq(c, 117), c, k)

# Module: src/back/native/bridge.bend:537
@unsafe
def nc_primitive_body(+k: String) -> KTerm:
  nc_prim_lambdas(k, nc_primitive_arity(k), 0)

# Module: src/back/native/bridge.bend:566
@unsafe
def nd_scalar_known(+name: String) -> Bool:
  Bool.not(p88_string_eq(ni_template(name), "")) && Bool.not(p88_string_eq(name, "f32_show") || p88_string_eq(name, "f32_read"))

# Reject ordinary/non-call heads before building intrinsic names and templates.
# Scalar and allocating call classifiers share the same provenance/arity gate.

@unsafe
def w5c3_nd_head_nat(is_nat: Bool, +t: KTerm, +hname: String) -> String:
  match is_nat:
    case True{}: nd_native_saturated(t, nc_primitive_name(hname))
    case False{}: ""

@unsafe
def nd_native_saturated(+t: KTerm, +name: String) -> String:
  w5c3_str_if(U32.is_eq(w5c3_nd_arg_count(t, 0), nc_primitive_arity(name)), name)

# Module: src/back/native/direct.bend:47
@unsafe
def nd_scalar_word(+name: String, +words: List<&2, String>) -> String:
  +expr = ni_emit(name, words)
  nt_choose(String, p88_string_eq(name, "u32_cmp") || p88_string_eq(name, "nat_cmp"), u => "term_pak((" ++ expr ++ ") == 0 ? CID_LT : (" ++ expr ++ ") == 1 ? CID_EQ : CID_GT, 0)", u => expr)

# Saturated calls to a known leading lambda telescope use one register entry.
# Partial applications keep the closure ABI; eligible named prefixes skip factories.

# Module: src/back/native/direct.bend:62
@unsafe
def nf_scalar_kind(+book: List<&2, KDef>, +ty: KTerm) -> N_WordKind:
  +head = nq_layout_type(book, ty)
  +owner = lookup(book, nm(head))
  nt_choose(N_WordKind, p98_tag_eq(head, "ADT") && p88_string_eq(dk(owner), "ADT") && db(owner) && List.is_empty(&2, String, rm(head)) && List.is_empty(&2, KTerm, ks(head)) && nb_contains(["U32", "F32", "Char", "Bool"], nm(head)), u => N_W32{}, u => N_W64{})

# Module: src/back/native/flat.bend:92
@unsafe
def nf_kind_tele(+book: List<&2, KDef>, +ty: KTerm, +left: U32, +fuel: U32) -> List<&2, N_WordKind>:
  nt_choose(List<&2, N_WordKind>, U32.is_eq(left, 0), u => Nil{}, u =>
    nt_choose(List<&2, N_WordKind>, U32.is_eq(fuel, 0), v => nf_opaque_kinds(left), v => nf_kind_head(book, nq_layout_type(book, ty), left, U32.sub(fuel, 1))))

# Module: src/back/native/flat.bend:101
@unsafe
def nf_kind_head(+book: List<&2, KDef>, +head: KTerm, +left: U32, +fuel: U32) -> List<&2, N_WordKind>:
  nt_choose(List<&2, N_WordKind>, p98_tag_eq(head, "All"),
    u => nt_choose(List<&2, N_WordKind>, U32.is_eq(qt(head), 0), v => nf_kind_tele(book, kid(head, 1), left, fuel), v => Con{p113n_type_kind(book, kid(head, 0)), nf_kind_tele(book, kid(head, 1), U32.sub(left, 1), fuel)}),
    u => nf_opaque_kinds(left))

@unsafe
def nf_worker_kinds(+book: List<&2, KDef>, +name: String, +arity: U32) -> List<&2, N_WordKind>:
  +d = lookup(book, name)
  nt_choose(List<&2, N_WordKind>, U32.is_eq(arity, jd_live_arity(book, dt(d), jd_arity(book, d))), u => nf_kind_tele(book, dt(d), arity, 256), u => nf_opaque_kinds(arity))

# A shell's fields remain opaque. Only nonflattened scalar arguments inherit
# the original argument kind; expanding a product must not shift later slots.

# W4-10 Pass 1: Decode 2-bit-per-field N_WordKind mask stored in NQShape.qt.
@unsafe
def nq_layout_head(+book: List<&2, KDef>, +ty: KTerm) -> KTerm:
  +owner = lookup(book, nm(ty))
  nt_choose(KTerm, p98_tag_eq(ty, "ADT") && p88_string_eq(dk(owner), "ADT") && List.is_empty(&2, String, rm(ty)) && U32.is_eq(terms_len(ks(ty)), da(owner)) && U32.is_eq(dx(owner), 0) && (Bool.not(db(owner)) || p88_string_eq(dn(owner), "Sigma")),
    u => nq_layout_single(book, ty, owner, dc(owner)), u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})

# W4-10 Pass 1: Compute 2-bit-per-field N_WordKind mask for single-ctor product fields.
@unsafe
def w4c_field_bits(+book: List<&2, KDef>, +field: KTerm) -> U32:
  w7_br_693(w4c_field_is_w32(book, field), book, field)

law w4c_layout_kind_mask:
  for +book: List<&2, KDef>
  for +tel: KTerm
  for +left: U32
  for +fidx: U32
  for +acc: U32
  U32

@unsafe
def w7_br_694(w7_c: Bool, +book: List<&2, KDef>, +head: KTerm, +left: U32, +fidx: U32, +acc: U32) -> U32:
  match w7_c:
    case True{}:
      +bits = w4c_field_bits(book, nq_layout_type(book, kid(head, 0))) +acc2 = U32.or(acc, U32.shln(bits, U32.to_nat(U32.mul(fidx, 2)))) w4c_layout_kind_mask(book, kid(head, 1), U32.sub(left, 1), U32.inc(fidx), acc2)
    case False{}:
      acc

@unsafe
def w7_br_695(w7_c: Bool, +book: List<&2, KDef>, +head: KTerm, +left: U32, +fidx: U32, +acc: U32) -> U32:
  match w7_c:
    case True{}:
      acc
    case False{}:
      w7_br_694(p98_tag_eq(head, "All") && Bool.not(U32.is_eq(qt(head), 0)), book, head, left, fidx, acc)

@unsafe
def w4c_layout_kind_head(+book: List<&2, KDef>, +head: KTerm, +left: U32, +fidx: U32, +acc: U32) -> U32:
  w7_br_695(U32.is_eq(left, 0), book, head, left, fidx, acc)

@unsafe
def w4c_layout_kind_mask(book, tel, left, fidx, acc):
  w4c_layout_kind_head(book, nq_layout_type(book, tel), left, fidx, acc)

# Module: src/back/native/product-layout.bend:15
@unsafe
def nq_layout_single(+book: List<&2, KDef>, +ty: KTerm, +owner: KDef, ctors: List<&2, KDef>) -> KTerm:
  match ctors:
    case Con{+ctr, Nil{}}:
      nt_choose(KTerm, p88_string_eq(dk(ctr), "Ctr") && U32.is_gt(da(ctr), 0) && U32.is_le(da(ctr), 8) && U32.is_eq(dx(ctr), 0) && (Bool.not(db(owner)) || (p88_string_eq(dn(ctr), "Tuple") && U32.is_eq(da(ctr), 2))),
        u =>
          +spec = nq_layout_specialize(dt(ctr), ks(ty), 64)
          nt_choose(KTerm, nq_layout_fields(book, spec, ty, da(ctr), Nil{}),
            v => kt("NQShape", nt_choose(String, db(owner), w => dn(ctr), w => nc_ctor_encode(dn(ctr))), da(ctr), w4c_layout_kind_mask(book, spec, da(ctr), 0, 0), Nil{}),
            v => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}),
        u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})
    case _: {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}

# Prior-field dependencies disqualify a shell; direct recursion is checked
# separately. A generic type, Array<T>, function or nested record is opaque;
# no recursive unboxing or field-representation theorem is assumed here.

# Module: src/back/native/product-layout.bend:29
@unsafe
def nq_layout_fields(+book: List<&2, KDef>, +tel: KTerm, +owner: KTerm, +left: U32, +seen: List<&2, U32>) -> Bool:
  nq_layout_field_head(book, nq_layout_type(book, tel), owner, left, seen)

# Module: src/back/native/product-layout.bend:39
@unsafe
def w7_br_696(w7_c: Bool, +book: List<&2, KDef>, +head: KTerm, +owner: KTerm, +left: U32, +seen: List<&2, U32>) -> Bool:
  match w7_c:
    case True{}:
      p98_tag_eq(head, "ADT") && p88_string_eq(nm(head), nm(owner)) && List.is_empty(&2, String, rm(head)) && Bool.not(nq_layout_dep(head, seen)) && norm_exact_lists(ks(head), ks(owner))
    case False{}:
      p98_tag_eq(head, "All") && Bool.not(U32.is_eq(qt(head), 0)) && nq_layout_leaf(nq_layout_type(book, kid(head, 0)), owner, seen) && nq_layout_fields(book, kid(head, 1), owner, U32.sub(left, 1), Con{ix(head), seen})

@unsafe
def nq_layout_field_head(+book: List<&2, KDef>, +head: KTerm, +owner: KTerm, +left: U32, +seen: List<&2, U32>) -> Bool:
  w7_br_696(U32.is_eq(left, 0), book, head, owner, left, seen)

# A directly recursive outer shell remains boxed. Nested records/arrays stay
# opaque fields; this is not a recursive graph-layout analysis.

# Module: src/back/native/product-layout.bend:47
@unsafe
def nw_covered(+body: KTerm, +fields: U32, cover: NW_Cover) -> Bool:
  match cover:
    case NW_None{}: False{}
    case NW_Cover{prior, bits, priorFields}:
      +word = nw_word({KTerm{"NWBitProbe", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, {KTerm{"NWTailProbe", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})
      nw_same(nw_apply(body, word, fields), nw_apply(prior, nw_rebuild(bits, word), priorFields), Nil{})

# Module: src/back/native/word-pattern.bend:81
@unsafe
def w7_br_725(w7_c: Bool, +t: KTerm, +depth: U32, +value: U32, +cover: NW_Cover, +bit: U32) -> NW_Rows:
  match w7_c:
    case True{}:
      nw_walk(t, U32.inc(depth), U32.or(value, U32.shln(bit, U32.to_nat(depth))), nw_descend(cover, bit))
    case False{}:
      NW_Rows{True{}, Nil{}}

@unsafe
def nw_branch(+t: KTerm, +depth: U32, +value: U32, +cover: NW_Cover, +bit: U32, +present: Bool) -> NW_Rows:
  w7_br_725(present, t, depth, value, cover, bit)

# Module: src/back/native/word-pattern.bend:109
@unsafe
def nw_bits(+depth: U32, +value: U32, +cover: NW_Cover, arms: NW_Arms) -> NW_Rows:
  match arms:
    case NW_Arms{zero, one, +end, +hasZero, +hasOne, valid}:
      nt_choose(NW_Rows, valid && (hasZero || hasOne),
        u => nw_bits_ready(zero, one, end, hasZero, hasOne, depth, value, cover, Bool.not(hasZero && hasOne) && Bool.not(nw_covered(end, 2, cover))),
        u => NW_Rows{False{}, Nil{}})

# Module: src/back/native/word-pattern.bend:117
@unsafe
def nw_bits_ready(+zero: KTerm, +one: KTerm, +end: KTerm, +hasZero: Bool, +hasOne: Bool, +depth: U32, +value: U32, +cover: NW_Cover, +own: Bool) -> NW_Rows:
  +next = nt_choose(NW_Cover, own, u => NW_Cover{end, Nil{}, 2}, u => cover)
  nw_join(nw_join(nw_branch(zero, depth, value, next, 0, hasZero), nw_branch(one, depth, value, next, 1, hasOne)),
    NW_Rows{True{}, nt_choose(List<&2, KTerm>, own, u => [nw_row(end, depth, value, 2)], u => Nil{})})

# Module: src/back/native/word-pattern.bend:123
@unsafe
def w7_br_727(w7_c: Bool, +t: KTerm, +depth: U32, +value: U32, +cover: NW_Cover) -> NW_Rows:
  match w7_c:
    case True{}:
      NW_Rows{True{}, nt_choose(List<&2, KTerm>, nw_covered(t, 1, cover), x => Nil{}, x => [nw_row(t, depth, value, 1)])}
    case False{}:
      NW_Rows{False{}, Nil{}}

@unsafe
def w7_br_728(w7_c: Bool, +t: KTerm, +depth: U32, +value: U32, +cover: NW_Cover) -> NW_Rows:
  match w7_c:
    case True{}:
      nw_bits(depth, value, cover, nw_arms(kid(t, 0), {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, False{}, False{}))
    case False{}:
      w7_br_727(p98_tag_eq(t, "Lam"), t, depth, value, cover)

@unsafe
def w7_br_729(w7_c: Bool, +t: KTerm, +depth: U32, +value: U32, +cover: NW_Cover) -> NW_Rows:
  match w7_c:
    case True{}:
      w7_br_726(p98_tag_eq(t, "Mat") && p88_string_eq(nm(t), "WNil") && U32.is_eq(ix(t), 1) && U32.is_eq(terms_len(ks(t)), 2), t, depth, value)
    case False{}:
      w7_br_728(p98_tag_eq(t, "Mat") && p88_string_eq(nm(t), "WCon") && U32.is_eq(ix(t), 3) && U32.is_eq(terms_len(ks(t)), 2), t, depth, value, cover)

@unsafe
def nw_walk(t, depth, value, cover):
  w7_br_729(U32.is_eq(depth, 32), t, depth, value, cover)

# Module: src/back/native/word-pattern.bend:134
@unsafe
def w12_nw_dispatch(+mat: KTerm) -> NW_Rows:
  nt_choose(NW_Rows, p88_string_eq(nm(mat), "#U32"),
    u => w12_nw_walk_lit(mat),
    u => nw_walk(kid(mat, 0), 0, 0, NW_None{}))

@unsafe
def ns_scalar(+book: List<&2, KDef>, +ty: KTerm) -> Bool:
  +head = nq_layout_type(book, ty)
  p98_tag_eq(head, "ADT") && db(lookup(book, nm(head))) && nb_contains(["U32", "F32", "Char", "Bool"], nm(head))

# Module: src/back/native/scalar-array.bend:9
@unsafe
def ns_array_type(+book: List<&2, KDef>, +ty: KTerm) -> Bool:
  +head = nq_layout_type(book, ty)
  nt_choose(Bool, p98_tag_eq(head, "ADT") && p88_string_eq(nm(head), "Array") && db(lookup(book, "Array")),
    u => ns_scalar(book, kid(head, 0)), u => False{})

# Module: src/back/native/scalar-array.bend:15
@unsafe
def w5c2_ns_gen_arr_prim(ok: Bool, +name: String) -> Bool:
  match ok:
    case False{}: False{}
    case True{}:
      +p = nc_primitive_name(name)
      String.eq(p, "array_get") || String.eq(p, "array_set") || String.eq(p, "array_new") ||
      String.eq(p, "array_swap") || String.eq(p, "array_size") || String.eq(p, "array_clone")

@unsafe
def w5c2_ns_ann_ty(is_mat: Bool, +book: List<&2, KDef>, +ty: KTerm) -> KTerm:
  match is_mat:
    case True{}: kid(nq_layout_type(book, ty), 0)
    case False{}: ty

@unsafe
def ns_array_free(+book: List<&2, KDef>, +ty: KTerm) -> Bool:
  +head = nq_layout_type(book, ty)
  nt_choose(Bool, p98_tag_eq(head, "Qua") || p98_tag_eq(head, "Qnt"), u => True{}, u =>
  nt_choose(Bool, p98_tag_eq(head, "Lam"), u => ns_array_free(book, kid(head, 0)), u =>
    nt_choose(Bool, p98_tag_eq(head, "ADT") && db(lookup(book, nm(head))) && nb_contains(["Nat", "U32", "F32", "Char", "Bool", "Unit", "String", "List", "Maybe", "Result", "Sigma", "Word.Nil", "Word.Con"], nm(head)),
      u => ns_types_free(book, ks(head)), u => False{})))

# Module: src/back/native/scalar-array.bend:81
@unsafe
def ns_types_free(+book: List<&2, KDef>, ts: List<&2, KTerm>) -> Bool:
  match ts:
    case Nil{}: True{}
    case Con{h, rest}: nt_choose(Bool, ns_array_free(book, h), u => ns_types_free(book, rest), u => False{})

# Module: src/back/native/scalar-array.bend:87
@unsafe
def ns_unshared_terms(+book: List<&2,KDef>, body: KTerm, terms: List<&2,KTerm>) -> Bool:
  match terms:
    case Nil{}: True{}
    case Con{head,rest}: p131u_unshared(book,p131u_build(body),Con{head,rest})

# Module: src/back/native/sharing.bend:6
@unsafe
def nh_types(+book: List<&2, KDef>, ts: List<&2, KTerm>, hot: List<&2, String>, +fuel: U32) -> List<&2, String>:
  match ts:
    case Nil{}: hot
    case Con{h, rest}: nh_types(book, rest, nh_type(book, h, hot, fuel), fuel)

# Module: src/back/native/sharing.bend:16
@unsafe
def nh_type(+book: List<&2, KDef>, +ty: KTerm, +hot: List<&2, String>, +fuel: U32) -> List<&2, String>:
  nt_choose(List<&2, String>, nb_contains(hot, "*") || U32.is_eq(fuel, 0), u => nh_add("*", hot), u => nh_head(book, nq_layout_type(book, ty), hot, U32.sub(fuel, 1)))

# Module: src/back/native/sharing.bend:20
@unsafe
def nh_head(+book: List<&2, KDef>, +t: KTerm, +hot: List<&2, String>, +fuel: U32) -> List<&2, String>:
  nt_choose(List<&2, String>, nb_contains(["Qua", "Qnt", "Typ", "Eql", "Rfl", "Lit", "Num", "Chr"], tg(t)), u => hot, u =>
    nt_choose(List<&2, String>, p98_tag_eq(t, "Lam"), v => nh_type(book, kid(t, 0), hot, fuel), v =>
      nt_choose(List<&2, String>, p98_tag_eq(t, "ADT") && List.is_empty(&2, String, rm(t)) && U32.is_le(nq_layout_size([t], 4097), 4096), w => nh_adt(book, t, lookup(book, nm(t)), hot, fuel), w => nh_add("*", hot))))

# Module: src/back/native/sharing.bend:26
@unsafe
def nh_adt(+book: List<&2, KDef>, +t: KTerm, +d: KDef, +hot: List<&2, String>, +fuel: U32) -> List<&2, String>:
  nt_choose(List<&2, String>, db(d) && nb_contains(["Nat", "U32", "F32", "Char", "Bool", "Unit"], nm(t)) && List.is_empty(&2, KTerm, ks(t)), u => hot, u =>
    nt_choose(List<&2, String>, p88_string_eq(dk(d), "ADT") && U32.is_eq(da(d), terms_len(ks(t))) && U32.is_eq(dx(d), 0),
      v => nh_adt_fields(book, t, d, nh_types(book, ks(t), hot, fuel), fuel), v => nh_add("*", hot)))

# Module: src/back/native/sharing.bend:32
@unsafe
def nh_adt_fields(+book: List<&2, KDef>, +t: KTerm, +d: KDef, +hot: List<&2, String>, +fuel: U32) -> List<&2, String>:
  +key = "type:" ++ term_key(t)
  nt_choose(List<&2, String>, nb_contains(hot, key), u => hot, u => nh_ctors(book, dc(d), ks(t), db(d), nh_add(key, hot), fuel))

# Module: src/back/native/sharing.bend:37
@unsafe
def nh_ctors(+book: List<&2, KDef>, cs: List<&2, KDef>, +args: List<&2, KTerm>, +base: Bool, hot: List<&2, String>, +fuel: U32) -> List<&2, String>:
  match cs:
    case Nil{}: hot
    case Con{+c, rest}:
      +key = nt_choose(String, base, u => dn(c), u => nc_ctor_encode(dn(c)))
      nh_ctors(book, rest, args, base, nh_fields(book, nq_layout_specialize(dt(c), args, 64), da(c), nh_add("ctor:" ++ key, hot), fuel), fuel)

# Module: src/back/native/sharing.bend:45
@unsafe
def nh_fields(+book: List<&2, KDef>, +tel: KTerm, +left: U32, +hot: List<&2, String>, +fuel: U32) -> List<&2, String>:
  nt_choose(List<&2, String>, U32.is_eq(left, 0), u => hot, u =>
    nt_choose(List<&2, String>, U32.is_eq(fuel, 0), v => nh_add("*", hot), v => nh_field(book, nq_layout_type(book, tel), left, hot, U32.sub(fuel, 1))))

# Module: src/back/native/sharing.bend:50
@unsafe
def nh_field(+book: List<&2, KDef>, +head: KTerm, +left: U32, +hot: List<&2, String>, +fuel: U32) -> List<&2, String>:
  nt_choose(List<&2, String>, p98_tag_eq(head, "All"),
    u => nh_fields(book, kid(head, 1), U32.sub(left, 1), nt_choose(List<&2, String>, U32.is_eq(qt(head), 0), v => hot, v => nh_type(book, kid(head, 0), hot, fuel)), fuel),
    u => nh_add("*", hot))

# Module: src/back/native/sharing.bend:56
@unsafe
def nh_terms(+book: List<&2,KDef>, body: KTerm, terms: List<&2,KTerm>, +hot: List<&2,String>) -> List<&2,String>:
  match terms:
    case Nil{}: hot
    case Con{head,rest}:
      nt_choose(List<&2,String>,nb_contains(hot,"*"),u => hot,
        u => p131u_hot(book,p131u_build(body),Con{head,rest},hot))

@unsafe
def w7_br_735(w7_c: Bool, +book: List<&2, KDef>, +ty: KTerm, +left: U32, +i: U32) -> U32:
  match w7_c:
    case True{}:
      0
    case False{}:
      nh_field_mask_head(book, nq_layout_type(book, ty), left, i)

@unsafe
def nh_field_mask(+book: List<&2, KDef>, +ty: KTerm, +left: U32, +i: U32) -> U32:
  w7_br_735(U32.is_eq(left, 0) || U32.is_gt(left, 8), book, ty, left, i)

# Module: src/back/native/sharing.bend:215
@unsafe
def w7_br_736(w7_c: Bool, +book: List<&2, KDef>, +head: KTerm, +left: U32, +i: U32) -> U32:
  match w7_c:
    case True{}:
      U32.or(nt_choose(U32, Bool.not(U32.is_eq(qt(head), 0)) && ns_scalar(book, kid(head, 0)), v => U32.shln(1, U32.to_nat(i)), v => 0), nh_field_mask(book, kid(head, 1), U32.sub(left, 1), U32.add(i, nt_bool(Bool.not(U32.is_eq(qt(head), 0))))))
    case False{}:
      0

@unsafe
def nh_field_mask_head(+book: List<&2, KDef>, +head: KTerm, +left: U32, +i: U32) -> U32:
  w7_br_736(p98_tag_eq(head, "All"), book, head, left, i)

# Module: src/back/native/validate.bend:3
@unsafe
def ns_ctor_index(cs: List<&2, N_Constructor>, +index: KDef) -> KDef:
  match cs:
    case Nil{}: index
    case Con{N_Constructor{+name, arity, hot}, rest}:
      ns_ctor_index(rest, index_set(index, KDef{name, "NativeStaticCtor", arity, 0, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Nil{}, False{}, False{}}, index_hash(name, 2166136261), 32))

# Module: src/back/native/static.bend:80
@unsafe
def w7_br_752(w7_c: Bool, +book: List<&2, KDef>, +t: KTerm, +env: List<&2, NC_Binding>, +fuel: U32) -> U32:
  match w7_c:
    case True{}:
      U32.min(3, U32.inc(no_wrapper_children(book, ks(t), env, U32.sub(fuel, 1))))
    case False{}:
      3

@unsafe
def w7_br_753(w7_c: Bool, +book: List<&2, KDef>, +t: KTerm, +env: List<&2, NC_Binding>, +fuel: U32) -> U32:
  match w7_c:
    case True{}:
      0
    case False{}:
      w7_br_752(p98_tag_eq(t, "Ctr") && U32.is_gt(fuel, 0) && Bool.not(nb_contains(["Succ", "Chr", "U32", "F32", "ALeaf", "ANode", "Zero", "True", "False"], nm(t))) && U32.is_eq(terms_len(ks(t)), nc_field_count(book, nm(t))), book, t, env, fuel)

@unsafe
def no_wrapper_nodes(+book: List<&2, KDef>, +t: KTerm, +env: List<&2, NC_Binding>, +fuel: U32) -> U32:
  w7_br_753(p98_tag_eq(t, "Var") && Bool.not(p88_string_eq(nc_word(ix(t), env), "NATIVE_UNBOUND_VARIABLE")), book, t, env, fuel)

# Module: src/back/native/observer-adapter.bend:54
@unsafe
def no_wrapper_children(book, ts, env, fuel):
  match ts:
    case Nil{}: 0
    case Con{h, rest}: U32.min(3, U32.add(no_wrapper_nodes(book, h, env, fuel), no_wrapper_children(book, rest, env, fuel)))

# Module: src/back/native/observer-layout.bend:16
@unsafe
def nol_fields(+book: List<&2, KDef>, +ty: KTerm, +tel: KTerm, +left: U32, +seen: List<&2, U32>) -> KTerm:
  +head = nq_layout_type(book, tel)
  nt_choose(KTerm, U32.is_eq(left, 0),
    u => nt_choose(KTerm, p98_tag_eq(head, "ADT") && p88_string_eq(nm(head), nm(ty)) && List.is_empty(&2, String, rm(head)) && Bool.not(nq_layout_dep(head, seen)) && norm_exact_lists(ks(head), ks(ty)), v => kt("NO_Types", "", 0, 0, Nil{}), v => nol_error("indexed constructor result")),
    u => nt_choose(KTerm, p98_tag_eq(head, "All") && Bool.not(U32.is_eq(qt(head), 0)) && U32.is_le(left, 16),
      v => nol_field(book, ty, head, nq_layout_type(book, kid(head, 0)), left, seen), v => nol_error("constructor telescope")))

# Module: src/back/native/observer-layout.bend:41
@unsafe
def w7_br_754(w7_c: Bool, +book: List<&2, KDef>, +ty: KTerm, +head: KTerm, +field: KTerm, +left: U32, +seen: List<&2, U32>) -> KTerm:
  match w7_c:
    case True{}:
      nol_field_cons(field, nol_fields(book, ty, kid(head, 1), U32.sub(left, 1), Con{ix(head), seen}))
    case False{}:
      nol_error("dependent or unsupported constructor field")

@unsafe
def nol_field(+book: List<&2, KDef>, +ty: KTerm, +head: KTerm, +field: KTerm, +left: U32, +seen: List<&2, U32>) -> KTerm:
  w7_br_754(nol_owner(book, field) && Bool.not(nq_layout_dep(field, seen)), book, ty, head, field, left, seen)

# Module: src/back/native/observer-layout.bend:47
@unsafe
def w7_br_756(w7_c: Bool, +book: List<&2, KDef>, +ty: KTerm, +ctr: KDef) -> KTerm:
  match w7_c:
    case True{}:
      nol_fields(book, ty, nq_layout_specialize(dt(ctr), ks(ty), 64), da(ctr), Nil{})
    case False{}:
      nol_error("constructor descriptor")

@unsafe
def nol_ctor_fields(+book: List<&2, KDef>, +ty: KTerm, +ctr: KDef) -> KTerm:
  w7_br_756(nol_owner(book, ty) && p88_string_eq(dk(ctr), "Ctr") && U32.is_eq(dx(ctr), 0) && U32.is_le(da(ctr), 16), book, ty, ctr)

# Module: src/back/native/observer-layout.bend:57
@unsafe
def nol_enum(+book: List<&2, KDef>, +ty: KTerm, ctors: List<&2, KDef>, +left: U32) -> Bool:
  match ctors:
    case Nil{}: True{}
    case Con{+ctr, +rest}:
      nt_choose(Bool, U32.is_gt(left, 0) && U32.is_eq(da(ctr), 0),
        u => p98_tag_eq(nol_ctor_fields(book, ty, ctr), "NO_Types") && nol_enum(book, ty, rest, U32.sub(left, 1)), u => False{})

# Module: src/back/native/observer-layout.bend:65
@unsafe
def dr_mark_safe(names: List<&2, String>, +safe: KDef) -> KDef:
  match names:
    case Nil{}: safe
    case Con{+name, rest}:
      dr_mark_safe(rest, index_set(safe, KDef{name, "ReportSafe", 0, 0, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Nil{}, False{}, False{}}, index_hash(name, 2166136261), 32))

@unsafe
def agy_ctor_parent_add(ctors: List<&2, KDef>, +adt: KDef, +acc: KDef) -> KDef:
  match ctors:
    case Nil{}: acc
    case Con{+c, rest}:
      +cname = dn(c)
      +entry : KDef = KDef{cname, "AgyCtorParent", 0, 0,
        {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},
        {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Con{adt, Nil{}}, False{}, False{}}
      agy_ctor_parent_add(rest, adt, index_set(acc, entry, index_hash(cname, 2166136261), 32))

law agy_dr_walk_def:
  for +book: List<&2, KDef>
  for +cidx: KDef
  for +todo: List<&2, String>
  for +seen: List<&2, String>
  for +seen_set: KDef
  for +safe: KDef
  for +d: KDef
  DR_Closure

@unsafe
def agy_dr_walk(+book: List<&2, KDef>, +cidx: KDef, todo: List<&2, String>, +seen: List<&2, String>, +seen_set: KDef, +safe: KDef) -> DR_Closure:
  match todo:
    case Nil{}: DR_Closure{False{}, seen}
    case Con{+name, +rest}:
      +h = index_hash(name, 2166136261)
      kc(DR_Closure, p88_string_eq(dk(index_find(seen_set, name, h, 32)), "ReportSeen") ||
          p88_string_eq(dk(index_find(safe, name, h, 32)), "ReportSafe"),
        u => agy_dr_walk(book, cidx, rest, seen, seen_set, safe),
        u => agy_dr_walk_def(book, cidx, rest, Con{name, seen},
          index_set(seen_set, KDef{name, "ReportSeen", 0, 0,
            {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},
            {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Nil{}, False{}, False{}}, h, 32),
          safe, agy_kr_resolve_cidx(book, cidx, name, h)))

@unsafe
def w7_br_787(w7_c: Bool, +book: List<&2, KDef>, +cidx: KDef, +todo: List<&2, String>, +seen: List<&2, String>, +seen_set: KDef, +safe: KDef, +d: KDef) -> DR_Closure:
  match w7_c:
    case True{}:
      DR_Closure{True{}, seen}
    case False{}:
      agy_dr_walk(book, cidx, agy_dr_deps(d, todo), seen, seen_set, safe)

@unsafe
def agy_dr_walk_def(book, cidx, todo, seen, seen_set, safe, d):
  w7_br_787(du(d) || (p98_tag_eq(dv(d), "Foreign") && Bool.not(db(d))), book, cidx, todo, seen, seen_set, safe, d)

@unsafe
def p88_fields(state: P88State, +tag: U32, roles: List<&2,U32>, values: List<&2,P88Node>, +left: U32) -> P88Decoded:
  match roles:
    case Nil{}: p88_fields_finish(state,tag,values,left)
    case Con{role, rest}: p88_fields_next(p88_field(state,role),tag,rest,values,left)

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:244
@unsafe
def p88_fields_finish(state: P88State, tag: U32, values: List<&2,P88Node>, left: U32) -> P88Decoded:
  match state:
    case P88State{cursor,nodes,strings,made,sn,+begin,+end}:
      p88_record_put(P88State{cursor,nodes,strings,made,sn,begin,end},p88_build(tag,List.reverse(&2,P88Node,values),begin,end),left)

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:250
@unsafe
def p88_fields_next(step: P88Step, tag: U32, roles: List<&2,U32>, values: List<&2,P88Node>, left: U32) -> P88Decoded:
  match step:
    case P88Step{state, P88Bad{}}: P88DecodeError{"cache field"}
    case P88Step{state, value}: p88_fields(state,tag,roles,Con{value,values},left)

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:256
@unsafe
def p88_record_put(state: P88State, node: P88Node, left: U32) -> P88Decoded:
  match state node:
    case s P88Bad{}: P88DecodeError{"cache record"}
    case P88State{cursor,nodes,strings,+made,sn,begin,end} n:
      p88_records(P88State{cursor,Array.set(P88Node,nodes,made,n),strings,U32.inc(made),sn,begin,end},U32.sub(left,1))

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:263
@unsafe
def p88_records(state: P88State, left: U32) -> P88Decoded:
  match left:
    case 0: p88_roots(state,[7,9,10,11,12],Nil{})
    case n: p88_record_tag(p88_number(state),n)

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:269
@unsafe
def p88_record_tag(step: P88Step, left: U32) -> P88Decoded:
  match step:
    case P88Step{state,P88Word{+tag}}: p88_record_tag_gate(state,tag,left,U32.is_le(tag,11))
    case P88Step{state,other}: P88DecodeError{"cache tag"}

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:275
@unsafe
def p88_record_tag_gate(state: P88State, tag: U32, left: U32, ok: Bool) -> P88Decoded:
  match ok:
    case False{}: P88DecodeError{"cache tag"}
    case True{}: p88_record_width(p88_number(state),tag,left)

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:281
@unsafe
def p88_record_width(step: P88Step, +tag: U32, left: U32) -> P88Decoded:
  match step:
    case P88Step{state,P88Word{width}}:
      p88_record_width_gate(state,tag,left,U32.is_eq(width,U32.from_nat(List.length(&2,U32,p88_roles(tag)))))
    case P88Step{state,other}: P88DecodeError{"cache width"}

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:288
@unsafe
def p88_record_width_gate(state: P88State, +tag: U32, left: U32, ok: Bool) -> P88Decoded:
  match ok:
    case False{}: P88DecodeError{"cache width"}
    case True{}: p88_fields(state,tag,p88_roles(tag),Nil{},left)

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:294
@unsafe
def p88_strings(state: P88State, +index: U32, +total: U32) -> P88Decoded:
  match state:
    case P88State{cursor,nodes,strings,made,+sn,begin,end}:
      p88_strings_gate(cursor,nodes,strings,made,sn,begin,end,index,total,U32.is_lt(index,sn))

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:332
@unsafe
def p88_strings_gate(cursor: P88Cursor, nodes: Array<P88Node>, strings: Array<String>, made: U32, sn: U32, begin: U32, end: U32, index: U32, total: U32, more: Bool) -> P88Decoded:
  match more:
    case False{}: p88_records(P88State{cursor,nodes,strings,made,sn,begin,end},total)
    case True{}: p88_strings_read(nodes,strings,made,sn,begin,end,index,total,p88_text(cursor))

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:338
@unsafe
def p88_strings_read(nodes: Array<P88Node>, strings: Array<String>, made: U32, sn: U32, begin: U32, end: U32, index: U32, total: U32, read: P88TextRead) -> P88Decoded:
  match read:
    case P88TextRead{P88Cursor{text,+mode},value}:
      p130m_strings_read(nodes,strings,made,sn,begin,end,index,total,text,mode,value,p130m_valid(mode))

@unsafe
def p88_header_counts(read: P88Number, +n: U32, +begin: U32, +end: U32) -> P88Decoded:
  match read:
    case P88Number{P88Cursor{text,+mode},+sn}:
      p88_header_allocate(P88Cursor{text,mode},n,sn,begin,end,p130m_valid(mode) && U32.is_ge(n,1) && U32.is_le(n,1048576) && U32.is_le(sn,65536) && U32.is_ge(begin,1) && U32.is_gt(end,begin))

@unsafe
def p88_header_allocate(cursor: P88Cursor, +n: U32, +sn: U32, begin: U32, end: U32, ok: Bool) -> P88Decoded:
  match ok:
    case True{}: p88_strings(P88State{cursor,Array.new(P88Node,p88_array_depth(n,1,0n),P88Bad{}),Array.new(String,p88_array_depth(sn,1,0n),""),0,sn,begin,end},0,n)
    case False{}: P88DecodeError{"cache header bounds"}

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:380
@unsafe
def p205_role(+roles: KDef, +key: String, +name: String) -> Maybe<&2,KDef>:
  +old = dk(p111v_get(roles,key))
  kc(Maybe<&2,KDef>,agy_str_eq(old,"Absent"),u => Some{p111v_put(roles,key,name,0,0)},
    u => kc(Maybe<&2,KDef>,agy_str_eq(old,name),v => Some{roles},v => None{}))

@unsafe
def p205u_literal(+book: List<&2,KDef>, +t: KTerm) -> KTerm:
  w7_br_802(core_literal(t) && agy_str_eq(nm(t),"String"), book, t)
@unsafe
def p205u_any_static(+book: List<&2,KDef>, +xs: List<&2,KTerm>) -> Bool:
  match xs:
    case Nil{}: False{}
    case Con{x,rest}: p205u_literal_good(p205u_literal(book,x)) || p205u_any_static(book,rest)
@unsafe
def p205u_static_arg(+book: List<&2,KDef>, +body: KTerm, +args: List<&2,KTerm>) -> Bool:
  match args:
    case Nil{}: False{}
    case Con{arg,rest}:
      kc(Bool,p98_tag_eq(body,"Lam"),u => p205u_static_arg(book,kid(body,0),rest),u =>
        p205u_literal_good(p205u_literal(book,arg)))
@unsafe
def w7_br_809(w7_c: Bool, +book: List<&2,KDef>, +t: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      p205u_after_args(book,dt(j_find_ctor(book,nm(t))),terms_len(ks(t)))
    case False{}:
      w7_br_808(p98_tag_eq(t,"Ref"), book, t)

@unsafe
def w7_br_810(w7_c: Bool, +book: List<&2,KDef>, +t: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      p205u_call_type(book,j_call_spine(t,[]))
    case False{}:
      w7_br_809(p98_tag_eq(t,"Ctr"), book, t)

@unsafe
def w7_br_811(w7_c: Bool, +book: List<&2,KDef>, +t: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      p205u_let_type(book,ks(t))
    case False{}:
      w7_br_810(p98_tag_eq(t,"App"), book, t)

@unsafe
def w7_br_812(w7_c: Bool, +book: List<&2,KDef>, +t: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      p205u_closed_type(book,ref(nm(t)))
    case False{}:
      w7_br_811(p98_tag_eq(t,"Let"), book, t)

@unsafe
def w7_br_813(w7_c: Bool, +book: List<&2,KDef>, +t: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      p205u_closed_type(book,kid(t,1))
    case False{}:
      w7_br_812(core_literal(t), book, t)

@unsafe
def p205u_bind_type(+book: List<&2,KDef>, +t: KTerm) -> KTerm:
  w7_br_813(p98_tag_eq(t,"Ann"), book, t)
@unsafe
def w7_br_814(w7_c: Bool, +book: List<&2,KDef>, +call: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      p205u_after_args(book,dt(lookup(book,nm(call))),terms_len(ks(call)))
    case False{}:
      atom("Absent")

@unsafe
def p205u_call_type(+book: List<&2,KDef>, +call: KTerm) -> KTerm:
  w7_br_814(p98_tag_eq(call,"Call"), book, call)
@unsafe
def p205u_let_type(+book: List<&2,KDef>, +xs: List<&2,KTerm>) -> KTerm:
  match xs:
    case Con{last,Nil{}}: p205u_bind_type(book,last)
    case Con{binding,rest}: p205u_let_type(book,rest)
    case _: atom("Absent")
@unsafe
def p205u_exists(+book: List<&2,KDef>, +todo: List<&2,KTerm>, +fuel: U32) -> Bool:
  match todo fuel:
    case Nil{} _: False{}
    case _ 0: False{}
    case Con{t,rest} _:
      p205u_literal_good(p205u_literal(book,j_strip(t))) ||
        p205u_exists(book,nt_append(KTerm,p205u_children(t),rest),U32.sub(fuel,1))
@unsafe
def w7_br_839(w7_c: Bool, +op: String, +a: U32, +b: U32) -> CtfeVal:
  match w7_c:
    case True{}:
      CVU32{U32.and(a, b)}
    case False{}:
      w7_br_838(agy_str_eq(op, "u32_or"), op, a, b)

@unsafe
def w7_br_840(w7_c: Bool, +op: String, +a: U32, +b: U32) -> CtfeVal:
  match w7_c:
    case True{}:
      w7_br_829(U32.is_eq(b, 0), a, b)
    case False{}:
      w7_br_839(agy_str_eq(op, "u32_and"), op, a, b)

@unsafe
def w7_br_841(w7_c: Bool, +op: String, +a: U32, +b: U32) -> CtfeVal:
  match w7_c:
    case True{}:
      w7_br_828(U32.is_eq(b, 0), a, b)
    case False{}:
      w7_br_840(agy_str_eq(op, "u32_mod"), op, a, b)

@unsafe
def w7_br_842(w7_c: Bool, +op: String, +a: U32, +b: U32) -> CtfeVal:
  match w7_c:
    case True{}:
      CVU32{U32.mul(a, b)}
    case False{}:
      w7_br_841(agy_str_eq(op, "u32_div"), op, a, b)

@unsafe
def ctfe_run_nat_bin(+op: String, +a: U32, +b: U32) -> CtfeVal:
  w7_br_857(agy_str_eq(op, "nat_add"), op, a, b)

@unsafe
def w7_br_867(w7_c: Bool, +op: String, +a: F32, +b: F32) -> CtfeVal:
  match w7_c:
    case True{}:
      CVF32{F32.add(a, b)}
    case False{}:
      w7_br_866(agy_str_eq(op, "f32_sub"), op, a, b)

@unsafe
def ctfe_run_f32_bin(+op: String, +a: F32, +b: F32) -> CtfeVal:
  w7_br_867(agy_str_eq(op, "f32_add"), op, a, b)

@unsafe
def ctfe_run_nat_opt(+op: String, ma: Maybe<&2, U32>, mb: Maybe<&2, U32>) -> CtfeVal:
  match ma mb:
    case Some{x} Some{y}: ctfe_run_nat_bin(op, x, y)
    case _ _: CVFail{}

law agy_abs_walk:
  for +ctx: List<&2,KDef>
  for +m: KTerm
  for +pat: KTerm
  for +pending: List<&2,U32>
  for +next_h: U32
  for +fname: String
  for +p_lam: KTerm
  for +r_lams: List<&2,KTerm>
  for +st_idx: U32
  AgyAbsWalk

@unsafe
def agy_abs_walk_mat_go(+ctx: List<&2,KDef>, +m: KTerm, +pat: KTerm, +h0: U32, +hrest: List<&2,U32>, +next_h: U32, +fname: String, +p_lam: KTerm, +r_lams: List<&2,KTerm>, +st_idx: U32, +cname: String, +carity: U32) -> AgyAbsWalk:
  +new_hs = agy_abs_make_holes(next_h,carity)
  +cpat = kt("Ctr",cname,0,1,agy_abs_hole_terms(new_hs))
  +pat_arm = agy_abs_fill(pat,h0,cpat)
  +pend_arm = List.append(&2,U32,new_hs,hrest)
  +w_arm = agy_abs_walk(ctx,kid(m,0),pat_arm,pend_arm,U32.add(next_h,carity),fname,p_lam,r_lams,st_idx)
  +w_rest = agy_abs_walk(ctx,kid(m,1),pat,Con{h0,hrest},next_h,fname,p_lam,r_lams,st_idx)
  agy_abs_walk_mat_join(m,w_arm,w_rest)

@unsafe
def agy_abs_walk_mat(+ctx: List<&2,KDef>, +m: KTerm, +pat: KTerm, +h0: U32, +hrest: List<&2,U32>, +next_h: U32, +fname: String, +p_lam: KTerm, +r_lams: List<&2,KTerm>, +st_idx: U32) -> AgyAbsWalk:
  +cname = nm(m)
  +carity = agy_abs_ctor_arity(ctx,cname)
  kc(AgyAbsWalk,U32.is_lt(carity,100) && U32.is_eq(terms_len(ks(m)),2),
    u => agy_abs_walk_mat_go(ctx,m,pat,h0,hrest,next_h,fname,p_lam,r_lams,st_idx,cname,carity),
    u => AgyAbsWalk{m,False{},False{}})

@unsafe
def agy_abs_walk(ctx, m, pat, pending, next_h, fname, p_lam, r_lams, st_idx):
  match pending:
    case Nil{}:
      kc(AgyAbsWalk,agy_abs_eq(m,pat),
        u => AgyAbsWalk{m,True{},True{}},
        u => AgyAbsWalk{agy_abs_wrap_tail(m,fname,p_lam,r_lams,st_idx),False{},True{}})
    case Con{+h0,+hrest}:
      kc(AgyAbsWalk,p98_tag_eq(m,"Mat"),
        u => agy_abs_walk_mat(ctx,m,pat,h0,hrest,next_h,fname,p_lam,r_lams,st_idx),
        u => kc(AgyAbsWalk,p98_tag_eq(m,"Efq"),
          v => AgyAbsWalk{m,False{},True{}},
          v => kc(AgyAbsWalk,p98_tag_eq(m,"Lam"),
            w => agy_abs_walk_lam_join(m,agy_abs_walk(ctx,kid(m,0),agy_abs_fill(pat,h0,var(nm(m),ix(m))),hrest,next_h,fname,p_lam,r_lams,st_idx)),
            w => AgyAbsWalk{m,False{},False{}})))

@unsafe
def w7_br_896(w7_c: Bool, +b1: KTerm, +fname: String, +lams1: List<&2,KTerm>) -> AgyStep:
  match w7_c:
    case True{}:
      agy_bf_check_right(kid(b1,0),fname,lams1)
    case False{}:
      AgyStep{0,False{}}

@unsafe
def agy_bf_check_succ_let(+b0: KTerm, +b1: KTerm, +ret: KTerm, +fname: String, +lams1: List<&2,KTerm>) -> AgyStep:
  w7_br_896(p98_tag_eq(b0,"Bind") && p98_tag_eq(b1,"Bind") && agy_bf_check_add(ret,ix(b0),ix(b1)) && agy_bf_check_left(kid(b0,0),fname,lams1), b1, fname, lams1)

@unsafe
def w7_br_897(w7_c: Bool, +succ_body: KTerm, +fname: String, +lams1: List<&2,KTerm>) -> AgyStep:
  match w7_c:
    case True{}:
      agy_bf_check_succ_let(kid(succ_body,0),kid(succ_body,1),kid(succ_body,2),fname,lams1)
    case False{}:
      AgyStep{0,False{}}

@unsafe
def agy_bf_check_succ(+succ_body: KTerm, +fname: String, +lams1: List<&2,KTerm>) -> AgyStep:
  w7_br_897(p98_tag_eq(succ_body,"Let") && U32.is_eq(terms_len(ks(succ_body)),3), succ_body, fname, lams1)

@unsafe
def w5c3_bin_gt(m: Bool, +op: String, +a: U32, +b: U32) -> KTerm:
  match m:
    case True{}: p205v_bool(U32.is_gt(a,b))
    case False{}: w5c3_bin_ge(String.eq(op,"u32_is_ge"), op, a, b)

@unsafe
def w5c3_bin_le(m: Bool, +op: String, +a: U32, +b: U32) -> KTerm:
  match m:
    case True{}: p205v_bool(U32.is_le(a,b))
    case False{}: w5c3_bin_gt(String.eq(op,"u32_is_gt"), op, a, b)

@unsafe
def w5c3_bin_lt(m: Bool, +op: String, +a: U32, +b: U32) -> KTerm:
  match m:
    case True{}: p205v_bool(U32.is_lt(a,b))
    case False{}: w5c3_bin_le(String.eq(op,"u32_is_le"), op, a, b)

@unsafe
def w5c3_bin_ne(m: Bool, +op: String, +a: U32, +b: U32) -> KTerm:
  match m:
    case True{}: p205v_bool(U32.is_ne(a,b))
    case False{}: w5c3_bin_lt(String.eq(op,"u32_is_lt"), op, a, b)

@unsafe
def p205v_range_cmp(+op: String, +ra: W2Range, +rb: W2Range) -> KTerm:
  match ra rb:
    case W2Range{la,ha,oka} W2Range{lb,hb,okb}:
      w5c2_rcmp_ok(oka && okb, op, la, ha, lb, hb)

@unsafe
def w2d_check_fold_body(+fname: String, +st_ty: KTerm, +body: KTerm) -> W2Fold:
  w7_br_919(p98_tag_eq(body,"Mat") && agy_str_eq(nm(body),"SNil") && U32.is_eq(terms_len(ks(body)),2) && U32.is_eq(p205u_refs(kid(body,0),fname),0) && p98_tag_eq(kid(body,1),"Mat") && agy_str_eq(nm(kid(body,1)),"SCon") && U32.is_eq(terms_len(ks(kid(body,1))),2) && p98_tag_eq(kid(kid(body,1),1),"Efq"), fname, st_ty, body)

@unsafe
def w2d_check_fold(+book: List<&2,KDef>, +d: KDef) -> W2Fold:
  +fname = dn(d)
  +ty0 = j_strip(dt(d))
  kc(W2Fold,agy_str_eq(dk(d),"Def") && Bool.not(db(d) || du(d)) && U32.is_eq(dx(d),0) && U32.is_eq(da(d),2) &&
    p98_tag_eq(ty0,"All") && p198e_owner(kid(ty0,0),"String") && p98_tag_eq(j_strip(kid(ty0,1)),"All") &&
    p205v_closed_ty(book,kid(j_strip(kid(ty0,1)),0),4) && p205u_room([dv(d)],256),
    u => w2d_check_fold_body(fname,kid(j_strip(kid(ty0,1)),0),p205u_clean(dv(d))),
    u => W2Fold{fname,atom("Absent"),atom("Absent"),atom("Absent"),False{}})

@unsafe
def w2d_ann_mat(+book: List<&2,KDef>, +m: KTerm, +st_ty: KTerm, +ret_ty: KTerm) -> KTerm:
  +sm = j_strip(m)
  kc(KTerm,p98_tag_eq(sm,"Mat"),u =>
    w2d_ann_mat_res(sm,w2d_mat_type(book,sm,st_ty,ret_ty)),u => sm)

@unsafe
def w2d_push_rec_in_mat(+book: List<&2,KDef>, +t: KTerm, +hname: String, +rargs: List<&2,KTerm>, +ret_ty: KTerm) -> KTerm:
  +s = j_strip(t)
  kc(KTerm,p98_tag_eq(s,"Efq"),u => s,u =>
  kc(KTerm,p98_tag_eq(s,"Lam"),v => k_with_children(s,[w2d_push_rec_in_mat(book,kid(s,0),hname,rargs,ret_ty)]),v =>
  kc(KTerm,p98_tag_eq(s,"Let") && U32.is_eq(terms_len(ks(s)),2),w => kt("Let","",0,0,[kid(s,0),w2d_push_rec_in_mat(book,kid(s,1),hname,rargs,ret_ty)]),w =>
  kc(KTerm,p98_tag_eq(s,"Mat") && U32.is_eq(terms_len(ks(s)),2),x => k_with_children(s,[w2d_push_rec_in_mat(book,kid(s,0),hname,rargs,ret_ty),w2d_push_rec_in_mat(book,kid(s,1),hname,rargs,ret_ty)]),x =>
  kc(KTerm,p98_tag_eq(s,"App") && p98_tag_eq(j_strip(kid(s,0)),"Mat"),y => app(w2d_ann_mat(book,w2d_push_rec_in_mat(book,kid(s,0),hname,rargs,ret_ty),ret_ty,ret_ty),kid(s,1)),y =>
    agy_bf_apps(ref(hname),nt_append(KTerm,rargs,[s])))))))

@unsafe
def w2d_wrap_rec_in_step_opt(+book: List<&2,KDef>, +t: KTerm, +hname: String, +rargs: List<&2,KTerm>, +bs: List<&2,KTerm>, +ret_ty: KTerm) -> KTerm:
  +s = j_strip(t)
  kc(KTerm,p98_tag_eq(s,"Let") && U32.is_eq(terms_len(ks(s)),2),
    u => w2d_wrap_rec_in_step_opt(book,kid(s,1),hname,rargs,nt_append(KTerm,bs,[kid(s,0)]),ret_ty),u =>
  kc(KTerm,p98_tag_eq(s,"Mat") && agy_str_eq(nm(s),"Tuple") && U32.is_eq(terms_len(ks(s)),2) &&
    p98_tag_eq(kid(s,0),"Lam") && p98_tag_eq(kid(kid(s,0),0),"Lam"),
    u => k_with_children(s,[
           k_with_children(kid(s,0),[
             k_with_children(kid(kid(s,0),0),[
               w2d_wrap_lets(bs,w2d_push_rec_in_mat(book,kid(kid(kid(s,0),0),0),hname,rargs,ret_ty))])]),
           kid(s,1)]),
    u => kc(KTerm,p98_tag_eq(s,"Lam"),
           v => k_with_children(s,[w2d_wrap_lets(bs,w2d_push_rec_in_mat(book,kid(s,0),hname,rargs,ret_ty))]),
           v => atom("Absent"))))

law w2d_hoist_mat:
  for +ctx: List<&2,KDef>
  for +st_ty: KTerm
  for +acc_ty: KTerm
  for +t: KTerm
  W2Hoist

@unsafe
def w2d_hoist_wrap_app(+ctx: List<&2,KDef>, +st_ty: KTerm, +acc_ty: KTerm, +arg: KTerm, +h: W2Hoist) -> W2Hoist:
  match h:
    case W2Hoist{c,t,ok}:
      W2Hoist{c,app(w2d_ann_mat(ctx,t,st_ty,acc_ty),arg),ok}

@unsafe
def w2d_hoist_mat(ctx, st_ty, acc_ty, t):
  +s = j_strip(t)
  kc(W2Hoist,p98_tag_eq(s,"Efq"),u => W2Hoist{"",s,True{}},u =>
  kc(W2Hoist,p98_tag_eq(s,"Ctr") && agy_str_eq(nm(s),"Tuple") && U32.is_eq(terms_len(ks(s)),2) &&
    p98_tag_eq(j_strip(kid(s,0)),"Ctr") && List.is_empty(&2,KTerm,ks(j_strip(kid(s,0)))),
    v => W2Hoist{nm(j_strip(kid(s,0))),kid(s,1),True{}},v =>
  kc(W2Hoist,p98_tag_eq(s,"Lam"),w => w2d_hoist_wrap_lam(s,w2d_hoist_mat(ctx,st_ty,acc_ty,kid(s,0))),w =>
  kc(W2Hoist,p98_tag_eq(s,"Let") && U32.is_eq(terms_len(ks(s)),2),
    x => w2d_hoist_wrap_let(kid(s,0),w2d_hoist_mat(ctx,st_ty,acc_ty,kid(s,1))),x =>
  kc(W2Hoist,p98_tag_eq(s,"Mat") && U32.is_eq(terms_len(ks(s)),2),
    y => w2d_hoist_mat_pair(s,w2d_hoist_mat(ctx,st_ty,acc_ty,kid(s,0)),w2d_hoist_mat(ctx,st_ty,acc_ty,kid(s,1))),y =>
  kc(W2Hoist,p98_tag_eq(s,"App") && w2d_is_mat_head(kid(s,0)),
    z => w2d_hoist_wrap_app(ctx,st_ty,acc_ty,kid(s,1),w2d_hoist_mat(ctx,st_ty,acc_ty,kid(s,0))),z => W2Hoist{"",s,False{}}))))))

@unsafe
def w2d_hoist_fst(+ctx: List<&2,KDef>, +st_ty: KTerm, +acc_ty: KTerm, +t: KTerm) -> KTerm:
  +s = j_strip(t)
  kc(KTerm,p98_tag_eq(s,"Ctr") && agy_str_eq(nm(s),"Tuple"),u => s,u =>
    w2d_hoist_fst_res(s,w2d_hoist_mat(ctx,st_ty,acc_ty,s)))

@unsafe
def p152c_fact(+book: List<&2,KDef>, +name: String, +source: KTerm, +fact: KDef) -> KTerm:
  +prior = index_first(dc(fact))
  nt_choose(KTerm,p98_tag_eq(dt(ns_context(book)),"P112StaticImage") &&
    agy_str_eq(dk(fact),"NativeStaticBody") && agy_str_eq(dn(fact),name) &&
    agy_str_eq(dk(prior),"NativeErasedBody") && agy_str_eq(dn(prior),name) &&
    U32.is_gt(nq_layout_remaining([dv(fact)],33),0),
    u => nt_choose(KTerm,p152c_pair(p112s_context_ctors(book),source,dv(fact)),
      v => dv(fact),v => source),u => source)

# These are the incumbent nbc_select gates, applied to the original compact
# body. The leaf-only substitution changes neither binders nor evaluation order.
@unsafe
def p152c_select(+book: List<&2,KDef>, +name: String, +body: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +n: U32, +count: U32) -> KTerm:
  nt_choose(KTerm,U32.is_gt(nq_layout_remaining([body],33),0),u =>
    nt_choose(KTerm,nbc_closed(body,[]) && nbc_match_list([body]),u =>
      nt_choose(KTerm,nbc_applicable(body,args),u =>
        nt_choose(KTerm,nd_comb_fresh(body,args,env,n,64),
          u => nbc_filled(f_fresh_term(p152c_fact(book,name,body,ns_body(book,name)),[],nc_id(U32.add(n,63))),args,n),
          u => atom("Absent")),u => atom("Absent")),u => atom("Absent")),u => atom("Absent"))

@unsafe
def p152c_source(+book: List<&2,KDef>, +name: String, +body: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +n: U32, +count: U32) -> KTerm:
  nt_choose(KTerm,U32.is_gt(nq_layout_remaining([body],33),0) && nbc_closed(body,[]),
    u => p152c_select(book,name,nc_compact(body),args,env,n,count),u => atom("Absent"))

# Preserve the exact previous classifier on every other case. N_Imm64 retains
# the constructor tag in the full U64 word; N_W32 would truncate that tag.
@unsafe
def p111v_put_h(+tree: KDef, +name: String, +hash: U32, +kind: String, +width: U32, +capacity: U32) -> KDef:
  p131i_insert(tree, KDef{name,kind,width,capacity,atom("Absent"),atom("Absent"),[],False{},False{}}, hash)

@unsafe
def p111v_put(+tree: KDef, +name: String, +kind: String, +width: U32, +capacity: U32) -> KDef:
  p131i_insert(tree, KDef{name,kind,width,capacity,atom("Absent"),atom("Absent"),[],False{},False{}}, index_hash(name,2166136261))

@unsafe
def p111v_counted_call(+symbol: String, +args: List<&2,N111Arg>, +live: KDef, +ids: N111Ids) -> Bool:
  +count = p111v_literal(p111v_arg(args,3))
  +is_ctor = String.eq(symbol,"p111_rt_ctor")
  +target = p111v_target(p111v_arg(args,1),ids,is_ctor)
  p111v_buffer(args,2,count,live) && w5c3_cc_ctor(is_ctor, symbol, target, count)

@unsafe
def w5c3_ctr_stake(m: Bool, +symbol: String, +args: List<&2,N111Arg>, +live: KDef) -> Bool:
  match m:
    case True{}:
      +id = p111v_literal(p111v_arg(args,1))
      +cnt = p111v_literal(p111v_arg(args,4))
      U32.is_eq(cnt,p111v_special_arity(id)) && p111v_buffer(args,3,cnt,live)
    case False{}: w5c3_ctr_stest(String.eq(symbol,"p111_rt_special_test"), symbol, args)

@unsafe
def w5c3_ctr_sctor(m: Bool, +symbol: String, +args: List<&2,N111Arg>, +live: KDef) -> Bool:
  match m:
    case True{}:
      +id = p111v_literal(p111v_arg(args,1))
      +count = p111v_literal(p111v_arg(args,3))
      U32.is_eq(count,p111v_special_arity(id)) && p111v_buffer(args,2,count,live)
    case False{}: w5c3_ctr_stake(String.eq(symbol,"p111_rt_special_take"), symbol, args, live)

@unsafe
def w5c3_ctr_op(m: Bool, +symbol: String, +args: List<&2,N111Arg>, +live: KDef) -> Bool:
  match m:
    case True{}:
      +id = p111v_literal(p111v_arg(args,1))
      +count = p111v_literal(p111v_arg(args,3))
      U32.is_gt(id,0) && U32.is_lt(id,87) && U32.is_eq(count,p111v_at(p111v_primitive_arities(),id)) && p111v_buffer(args,2,count,live)
    case False{}: w5c3_ctr_sctor(String.eq(symbol,"p111_rt_special_ctor"), symbol, args, live)

@unsafe
def w5c3_ctr_spop(m: Bool, +symbol: String, +args: List<&2,N111Arg>, +live: KDef, +arity: U32, +incoming: U32) -> Bool:
  match m:
    case True{}: U32.is_gt(incoming,0) && U32.is_eq(p111v_literal(p111v_arg(args,1)),U32.sub(arity,incoming))
    case False{}: w5c3_ctr_op(String.eq(symbol,"p111_rt_op"), symbol, args, live)

@unsafe
def p111q_insert(+tree: KDef, +name: String, id: U32) -> KDef:
  index_set(tree,KDef{name,"N111Id",id,0,{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},[],False{},False{}},index_hash(name,2166136261),32)

@unsafe
def p111q_constructor_ids(constructors: List<&2,N_Constructor>, +next: U32, tree: KDef) -> KDef:
  match constructors:
    case Nil{}: tree
    case Con{N_Constructor{+name,arity,+hot},rest}:
      p111q_constructor_ids(rest,U32.inc(next),
        index_set(tree,KDef{name,"N111Id",next,arity,kt("P185Constructor","",nt_choose(U32,hot,u => 1,u => 0),11102,[]),{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},[],False{},False{}},
          index_hash(name,2166136261),32))

@unsafe
def p112_intrinsic_fallback(+name: String, +values: List<&2,N111Value>) -> P111ValueCode:
  match values:
    case Con{+value,Nil{}}:
      nt_choose(P111ValueCode,agy_str_eq(name,"u32_to_nat") || agy_str_eq(name,"f32_bits"),
        u => P111ValueCode{[N111Set{"value",N111U64{},value}],N111Local{"value"},""},
        u => p125i_previous_fallback(name,values))
    case _: p125i_previous_fallback(name,values)

@unsafe
def p185_bool_binary(op: String, a: N111Value, b: N111Value) -> P111ValueCode:
  p112_scalar_result(nt_append(N111Stmt,
    [N111Set{"p185_bool_a_local_input", N111U64{}, a},
     N111Set{"p185_bool_b_local_input", N111U64{}, b}],
    nt_append(N111Stmt, p112f_rename(p112_special_bool(N111Local{"input"}, False{}), "p185_bool_a_"),
    nt_append(N111Stmt, p112f_rename(p112_special_bool(N111Local{"input"}, False{}), "p185_bool_b_"),
      [N111Bin{"p185_bool_test", N111U32{}, op,
         N111Local{"p185_bool_a_local_match_condition"}, N111Local{"p185_bool_b_local_match_condition"}},
       N111If{N111Local{"p185_bool_test"},
         [N111Set{"value", N111U64{}, N111Const{1, 0}}],
         [N111Set{"value", N111U64{}, N111Const{0, 0}}]}]))))


@unsafe
def p112s_ctors(constructors: List<&2,N_Constructor>, +next: U32, index: KDef) -> KDef:
  match constructors:
    case Nil{}: index
    case Con{N_Constructor{+name,arity,hot},rest}:
      p112s_ctors(rest,U32.inc(next),index_set(index,KDef{name,"P112StaticCtor",next,arity,{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},[],False{},False{}},index_hash(name,2166136261),32))


@unsafe
def p112s_block_effects(index: KDef, names: List<&2,String>) -> KDef:
  match names:
    case Nil{}: index
    case Con{+name,rest}:
      p112s_block_effects(index_set(index,KDef{name,"P112StaticForeign",0,0,{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},[],False{},False{}},index_hash(name,2166136261),32),rest)


@unsafe
def w8_p112s_intern_fit(fits: Bool, +term: KTerm, +fields: List<&2,P112SWord>, +key: String, +hash: U32, +count: U32, +size: U32, +nodes: List<&2,P112SNode>, +index: KDef, +error: String) -> P112STerm:
  match fits:
    case True{}:
      P112STerm{p112s_marker(P112SBox{nm(term),size}),P112SImage{U32.add(size,count),Con{P112SNode{size,nm(term),fields},nodes},p131i_insert(index,KDef{key,"P112StaticIntern",size,0,{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},[],False{},False{}},hash),error}}
    case False{}:
      P112STerm{term,P112SImage{size,nodes,index,error}}

law p112s_term:
  for +constructors: KDef
  for +term: KTerm
  for +image: P112SImage
  P112STerm


@unsafe
def p112s_terms(+constructors: KDef, terms: List<&2,KTerm>, +image: P112SImage) -> P112STerms:
  match terms:
    case Nil{}: P112STerms{[],image}
    case Con{head,rest}: p112s_terms_step(constructors,rest,p112s_term(constructors,head,image))


@unsafe
def p112s_terms_step(+constructors: KDef, +rest: List<&2,KTerm>, first: P112STerm) -> P112STerms:
  match first:
    case P112STerm{head,image}: p112s_terms_cons(head,p112s_terms(constructors,rest,image))


@unsafe
def w8_p112s_rebuild_ctr(isCtr: Bool, +constructors: KDef, +term: KTerm, +image: P112SImage) -> P112STerm:
  match isCtr:
    case True{}: p112s_constructor(constructors,ns_static_scalar(term),image)
    case False{}: P112STerm{term,image}

@unsafe
def p112s_rebuild(+constructors: KDef, +original: KTerm, children: P112STerms) -> P112STerm:
  match children:
    case P112STerms{kids,+image}:
      +term = k_rebuild(original,nm(original),ix(original),qt(original),kids,rm(original),kb(original),ke(original))
      w8_p112s_rebuild_ctr(agy_str_eq(tg(term),"Ctr"),constructors,term,image)


@unsafe
def w8_p112s_term_leaf(isLeaf: Bool, +constructors: KDef, +term: KTerm, +image: P112SImage) -> P112STerm:
  match isLeaf:
    case True{}: P112STerm{term,image}
    case False{}: p112s_rebuild(constructors,term,p112s_terms(constructors,ks(term),image))

@unsafe
def w8_p112s_term_stale(isStale: Bool, +tag: String, +constructors: KDef, +term: KTerm, +image: P112SImage) -> P112STerm:
  match isStale:
    case True{}: p112s_stale(image)
    case False{}: w8_p112s_term_leaf(agy_str_eq(tag,"NWord") || agy_str_eq(tag,"Var") || agy_str_eq(tag,"Ref"),constructors,term,image)

@unsafe
def p112s_term(constructors,term,image):
  +tag = tg(term)
  w8_p112s_term_stale(agy_str_eq(tag,"NStatic") || agy_str_eq(tag,"NWPattern"),tag,constructors,term,image)


@unsafe
def p112s_node_index(nodes: List<&2,P112SNode>, index: KDef) -> KDef:
  match nodes:
    case Nil{}: index
    case Con{P112SNode{+offset,name,fields},rest}:
      +key = U32.show(offset)
      p112s_node_index(rest,p131i_insert(index,KDef{key,"P112StaticNode",offset,nt_count(P112SWord,fields),atom(name),{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},[],False{},False{}},index_hash(key,2166136261)))


@unsafe
def p112f_value(value: N111Value, +prefix: String) -> N111Value:
  match value:
    case N111Local{+name}: N111Local{p112f_name(prefix,name)}
    case _: value


@unsafe
def p112f_args(args: List<&2,N111Arg>, +prefix: String) -> List<&2,N111Arg>:
  match args:
    case Nil{}: []
    case Con{N111Arg{+typ,+value},+rest}: Con{N111Arg{typ,p112f_value(value,prefix)},p112f_args(rest,prefix)}


@unsafe
def p112f_rename(body: List<&2,N111Stmt>, +prefix: String) -> List<&2,N111Stmt>:
  match body:
    case Nil{}: []
    case Con{+stmt,+rest}: Con{p112f_stmt(stmt,prefix),p112f_rename(rest,prefix)}


@unsafe
def p112f_stmt(stmt: N111Stmt, +prefix: String) -> N111Stmt:
  match stmt:
    case N111Set{+name,+typ,+value}: N111Set{p112f_name(prefix,name),typ,p112f_value(value,prefix)}
    case N111Bin{+name,+typ,+op,+left,+right}: N111Bin{p112f_name(prefix,name),typ,op,p112f_value(left,prefix),p112f_value(right,prefix)}
    case N111Call{+name,+typ,+symbol,+args}: N111Call{p112f_name(prefix,name),typ,symbol,p112f_args(args,prefix)}
    case N111If{+condition,+yes,+no}: N111If{p112f_value(condition,prefix),p112f_rename(yes,prefix),p112f_rename(no,prefix)}
    case N111Return{+value}: N111Return{p112f_value(value,prefix)}
    case N111Load{+name,+typ,+base,+offset}: N111Load{p112f_name(prefix,name),typ,p112f_value(base,prefix),offset}
    case N111Store{+typ,+base,+offset,+value}: N111Store{typ,p112f_value(base,prefix),offset,p112f_value(value,prefix)}
    case N111Offset{+name,+base,+bytes}: N111Offset{p112f_name(prefix,name),p112f_value(base,prefix),p112f_value(bytes,prefix)}
    case N111Alloca{+name,+bytes,+align}: N111Alloca{p112f_name(prefix,name),bytes,align}


@unsafe
def p112f_bind_captures(words: List<&2,String>, +prefix: String, +index: U32) -> List<&2,N111Stmt>:
  match words:
    case Nil{}: []
    case Con{+word,+rest}: Con{N111Set{p112f_name(prefix,word),N111U64{},N111Local{prefix ++ "capture_" ++ U32.show(index)}},p112f_bind_captures(rest,prefix,U32.inc(index))}


@unsafe
def p112f_inline(cont: P112FusionCont, +prefix: String) -> List<&2,N111Stmt>:
  match cont:
    case P112FusionCont{+captures,+result,+pop,+body}:
      Con{N111Alloca{p112f_name(prefix,"scratch"),2048,8},
        nt_append(N111Stmt,nt_choose(List<&2,N111Stmt>,agy_str_eq(pop,""),u => [],u => [N111Set{p112f_name(prefix,pop),N111U64{},N111Const{0,0}}]),
          nt_append(N111Stmt,p112f_bind_captures(captures,prefix,0),
            Con{N111Set{p112f_name(prefix,result),N111U64{},N111Local{prefix ++ "result"}},p112f_rename(body,prefix)}))}


@unsafe
def p112r_failure(body: List<&2,N111Stmt>, +symbols: KDef, +sites: U32) -> Bool:
  match body:
    case Con{N111Call{+dest,N111U64{},+symbol,+args},Con{N111Return{N111Local{+word}},Nil{}}}:
      agy_str_eq(symbol,"p111_rt_fail") && agy_str_eq(dest,word) && p112t_failure_args(args)
    case Con{+stmt,+rest}: (p112r_scalar(stmt,symbols,sites) || p112r_failure_frame(stmt,sites)) && p112r_failure(rest,symbols,sites)
    case _: False{}


@unsafe
def p112r_scan(+body: List<&2,N111Stmt>, +owner: String, +arity: U32, +ready: KDef, +symbols: KDef, +sites: U32) -> P112WorkerBody:
  nt_choose(P112WorkerBody,p112r_failure(body,symbols,sites),u => P112WorkerBody{True{},0,p112w_failure_nodes(body)},
    u => p112r_normal(body,owner,arity,ready,symbols,sites))


@unsafe
def p112r_normal(+body: List<&2,N111Stmt>, +owner: String, +arity: U32, +ready: KDef, +symbols: KDef, +sites: U32) -> P112WorkerBody:
  +buffer = p112r_head_buffer(body)
  nt_choose(P112WorkerBody,p112r_buffer(buffer,sites) && p112r_tail(body,owner,arity,0,buffer),
    u => P112WorkerBody{True{},0,p112r_exit(body,arity,P112WorkerAgain{})},u =>
    nt_choose(P112WorkerBody,p112r_result(body,sites),u => P112WorkerBody{True{},0,p112r_exit(body,1,P112WorkerResult{})},
      u => p112r_scan_target(body,owner,arity,ready,symbols,sites,buffer,p112r_target(body,sites))))


@unsafe
def p112r_scan_target(+body: List<&2,N111Stmt>, +owner: String, +arity: U32, +ready: KDef, +symbols: KDef, +sites: U32, +buffer: String, +target: String) -> P112WorkerBody:
  +count = da(p111v_get(ready,target))
  nt_choose(P112WorkerBody,p112w_ready(ready,target) && Bool.not(agy_str_eq(owner,target)) && p112r_buffer(buffer,sites) && p112r_tail(body,target,count,0,buffer),
    u => P112WorkerBody{True{},1,p112r_exit(body,count,P112WorkerCall{target,count})},
    u => p112r_next(body,owner,arity,ready,symbols,sites))


@unsafe
def p112r_next(body: List<&2,N111Stmt>, +owner: String, +arity: U32, +ready: KDef, +symbols: KDef, +sites: U32) -> P112WorkerBody:
  match body:
    case Nil{}: P112WorkerBody{True{},0,[]}
    case Con{N111If{+condition,+yes,+no},+rest}:
      p112r_yes(condition,no,rest,owner,arity,ready,symbols,sites,p112r_scan(yes,owner,arity,ready,symbols,sites))
    case Con{+stmt,+rest}:
      nt_choose(P112WorkerBody,p112r_scalar(stmt,symbols,sites),
        u => p112e_worker_scalar(stmt,p112r_normal(rest,owner,arity,ready,symbols,sites)),u => P112WorkerBody{False{},0,[]})


@unsafe
def p112r_yes(+condition: N111Value, +no: List<&2,N111Stmt>, +rest: List<&2,N111Stmt>, +owner: String, +arity: U32, +ready: KDef, +symbols: KDef, +sites: U32, +yes: P112WorkerBody) -> P112WorkerBody:
  nt_choose(P112WorkerBody,p112e_worker_valid(yes),
    u => p112r_no(condition,rest,owner,arity,ready,symbols,sites,yes,p112r_scan(no,owner,arity,ready,symbols,sites)),u => P112WorkerBody{False{},0,[]})


@unsafe
def p112r_no(+condition: N111Value, +rest: List<&2,N111Stmt>, +owner: String, +arity: U32, +ready: KDef, +symbols: KDef, +sites: U32, +yes: P112WorkerBody, +no: P112WorkerBody) -> P112WorkerBody:
  nt_choose(P112WorkerBody,p112e_worker_valid(no),
    u => p112r_rest(condition,yes,no,p112r_scan(rest,owner,arity,ready,symbols,sites)),u => P112WorkerBody{False{},0,[]})


@unsafe
def p112r_prelude(+owner: String, +arity: U32, +ready: KDef, +symbols: KDef, +sites: U32, prelude: P112TailPrelude) -> P112WorkerPlan:
  match prelude:
    case P112TailPrelude{+valid,+params,+prefix,+body}:
      nt_choose(P112WorkerPlan,valid,u => p112w_finish(params,p112r_scan(body,owner,arity,ready,symbols,sites)),u => P112WorkerPlan{False{},0,[],[]})


@unsafe
def p112c_plan(segment: N111Segment, +ready: KDef, +symbols: KDef, +sites: U32) -> P112WorkerPlan:
  match segment:
    case N111Segment{+name,+arity,+result,+incoming,+flags,+body}:
      nt_choose(P112WorkerPlan,U32.is_eq(incoming,0) && U32.is_eq(flags,0) && U32.is_eq(result,1) && U32.is_le(arity,64) && U32.is_le(sites,8),
        u => p112r_prelude(name,arity,ready,symbols,sites,p112t_prelude(body,arity)),u => P112WorkerPlan{False{},0,[],[]})


@unsafe
def p113d_pass(candidates: List<&2,P113DCandidate>, +index: KDef, +functions: List<&2,P113DFunction>, +waiting: List<&2,P113DCandidate>, +count: U32) -> P113DPass:
  match candidates:
    case Nil{}: P113DPass{index,functions,nt_reverse(P113DCandidate,waiting,[]),count}
    case Con{+candidate,rest}: p113d_pass_one(candidate,rest,index,functions,waiting,count)


@unsafe
def p113d_pass_one(+candidate: P113DCandidate, +rest: List<&2,P113DCandidate>, +index: KDef, +functions: List<&2,P113DFunction>, +waiting: List<&2,P113DCandidate>, +count: U32) -> P113DPass:
  match candidate:
    case P113DCandidate{+function,+error,+calls}: p113d_pass_function(candidate,function,error,calls,rest,index,functions,waiting,count)


@unsafe
def w7c_p113d_admit_ok(ok: Bool, +function: P113DFunction, +name: String, +params: List<&2,NC_Binding>, +rest: List<&2,P113DCandidate>, +index: KDef, +functions: List<&2,P113DFunction>, +waiting: List<&2,P113DCandidate>, +count: U32) -> P113DPass:
  match ok:
    case True{}: p113d_pass(rest,p111v_put(index,name,"P113Direct",nt_count(NC_Binding,params),0),Con{function,functions},waiting,U32.inc(count))
    case False{}: p113d_pass(rest,index,functions,waiting,count)

@unsafe
def w7c_p113d_deps_ready(depsOk: Bool, +candidate: P113DCandidate, +function: P113DFunction, +name: String, +params: List<&2,NC_Binding>, +body: List<&2,P113DStmt>, +rest: List<&2,P113DCandidate>, +index: KDef, +functions: List<&2,P113DFunction>, +waiting: List<&2,P113DCandidate>, +count: U32) -> P113DPass:
  match depsOk:
    case True{}: w7c_p113d_admit_ok(w7_self_rec_ok(name,body),function,name,params,rest,index,functions,waiting,count)
    case False{}: p113d_pass(rest,index,functions,Con{candidate,waiting},count)

@unsafe
def w7c_p113d_skip(skip: Bool, +candidate: P113DCandidate, +function: P113DFunction, +name: String, +params: List<&2,NC_Binding>, +body: List<&2,P113DStmt>, +calls: List<&2,String>, +rest: List<&2,P113DCandidate>, +index: KDef, +functions: List<&2,P113DFunction>, +waiting: List<&2,P113DCandidate>, +count: U32) -> P113DPass:
  match skip:
    case True{}: p113d_pass(rest,index,functions,waiting,count)
    case False{}: w7c_p113d_deps_ready(w6_p113d_deps_self(calls,index,name),candidate,function,name,params,body,rest,index,functions,waiting,count)

@unsafe
def p113d_pass_function(+candidate: P113DCandidate, +function: P113DFunction, +error: String, +calls: List<&2,String>, +rest: List<&2,P113DCandidate>, +index: KDef, +functions: List<&2,P113DFunction>, +waiting: List<&2,P113DCandidate>, +count: U32) -> P113DPass:
  match function:
    case P113DFunction{+name,+params,result,public,+body}:
      w7c_p113d_skip(Bool.not(String.is_empty(error)) || p113d_ready(index,name),candidate,function,name,params,body,calls,rest,index,functions,waiting,count)


@unsafe
def p113e_insert(+index: KDef, +record: KDef) -> KDef:
  index_set(index,record,index_hash(dn(record),2166136261),32)


@unsafe
def p113_primitive_kind(+name: String, +arity: U32) -> N_WordKind:
  nt_choose(N_WordKind,p113n_primitive(name),
    u => nt_choose(N_WordKind,U32.is_eq(arity,nc_primitive_arity(name)),v => N_Imm64{},v => N_W64{}),
    u => nt_choose(N_WordKind,p113_scalar_result_name(name),
      v => nt_choose(N_WordKind,U32.is_eq(arity,nc_primitive_arity(name)),w => N_W32{},w => N_W64{}),v => N_W64{}))

@unsafe
def p113_result_tele(+book: List<&2,KDef>, +ty: KTerm, +left: U32, +fuel: U32) -> N_WordKind:
  nt_choose(N_WordKind, U32.is_eq(fuel,0), u => N_W64{},
    u => p113_result_head(book,nq_layout_type(book,ty),left,U32.sub(fuel,1)))


@unsafe
def p113_result_head(+book: List<&2,KDef>, +head: KTerm, +left: U32, +fuel: U32) -> N_WordKind:
  nt_choose(N_WordKind, p98_tag_eq(head,"All"),
    u => nt_choose(N_WordKind, U32.is_eq(terms_len(ks(head)),2) && Bool.not(nc_occurs(kid(head,1),ix(head))),
      v => nt_choose(N_WordKind, U32.is_eq(qt(head),0),
        w => p113_result_tele(book,kid(head,1),left,fuel),
        w => nt_choose(N_WordKind, U32.is_gt(left,0),
          z => p113_result_tele(book,kid(head,1),U32.sub(left,1),fuel), z => N_W64{})),
      v => N_W64{}),
    u => nt_choose(N_WordKind, U32.is_eq(left,0), v => p113n_type_kind(book,head), v => N_W64{}))

@unsafe
def p113p_array_pair(+name: String, +count: U32) -> Bool:
  +arity = p113p_array_arity(p111_op_id(name))
  U32.is_gt(arity,0) && U32.is_eq(arity,count)

# Structural signature only. The direct verifier additionally proves that both
# buffers are valid local allocas, with count*8 and16 bytes respectively, and
# prohibits a state pointer masquerading as either buffer.


@unsafe
def w8_bangs_index(bangs: List<&2,String>, acc: KDef) -> KDef:
  match bangs:
    case Nil{}: acc
    case Con{+b,rest}:
      +h = index_hash(b,2166136261)
      w8_bangs_index(rest,p131i_insert(acc,KDef{b,"Bang",0,0,{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},[],False{},False{}},h))

@unsafe
def p113n_canonical(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  +head = nq_layout_type(book,ty)
  +owner = lookup(book,"Nat")
  p98_tag_eq(head,"ADT") && agy_str_eq(nm(head),"Nat") && agy_str_eq(dk(owner),"ADT") && db(owner) && U32.is_eq(da(owner),0) &&
    List.is_empty(&2,String,rm(head)) && List.is_empty(&2,KTerm,ks(head))


@unsafe
def p113n_type_kind(+book: List<&2,KDef>, +ty: KTerm) -> N_WordKind:
  nt_choose(N_WordKind,p113n_canonical(book,ty),u => N_Imm64{},u => nf_scalar_kind(book,ty))


@unsafe
def p113n_constructor(+book: List<&2,KDef>, +name: String, +arity: U32) -> Bool:
  p113n_canonical(book,kt("ADT","Nat",0,0,[])) && j_u32_native_ctor(book,"Nat",name) &&
    ((agy_str_eq(name,"Zero") && U32.is_eq(arity,0)) || (agy_str_eq(name,"Succ") && U32.is_eq(arity,1)))

# Only a closed, unparameterized constructor telescope is used for additional
# field facts. Generic/dependent specialization remains the mature mask's job.


@unsafe
def p113n_ctor_end(+book: List<&2,KDef>, +ty: KTerm, +left: U32) -> KTerm:
  nt_choose(KTerm,U32.is_eq(left,0),u => nq_layout_type(book,ty),
    u => p113n_ctor_end_head(book,nq_layout_type(book,ty),left))


@unsafe
def p113n_ctor_end_head(+book: List<&2,KDef>, +head: KTerm, +left: U32) -> KTerm:
  nt_choose(KTerm,p98_tag_eq(head,"All") && U32.is_eq(terms_len(ks(head)),2),
    u => p113n_ctor_end(book,kid(head,1),U32.sub(left,1)),u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})


@unsafe
def p113i_bind(params: List<&2,NC_Binding>, args: List<&2,N111Value>, +prefix: String) -> List<&2,P113DStmt>:
  match params args:
    case Con{NC_Binding{id,word,kind},rest} Con{value,tail}:
      Con{P113DScalar{N111Set{p112f_name(prefix,word),N111U64{},value}},p113i_bind(rest,tail,prefix)}
    case _ _: []


@unsafe
def p113j_scratch_alloc(+body: List<&2,P113DStmt>, +prefix: String) -> List<&2,P113DStmt>:
  +bytes = p113j_scratch(body)
  nt_choose(List<&2,P113DStmt>,U32.is_eq(bytes,0),u => [],
    u => [P113DScalar{N111Alloca{p112f_name(prefix,"scratch"),U32.mul(U32.div(U32.add(bytes,7),8),8),8}}])


@unsafe
def p113j_names(names: List<&2,String>, +prefix: String) -> List<&2,String>:
  match names:
    case Nil{}: []
    case Con{head,rest}: Con{p112f_name(prefix,head),p113j_names(rest,prefix)}


@unsafe
def p113j_values(values: List<&2,N111Value>, +prefix: String) -> List<&2,N111Value>:
  match values:
    case Nil{}: []
    case Con{head,rest}: Con{p112f_value(head,prefix),p113j_values(rest,prefix)}


@unsafe
def p113j_snapshots(values: List<&2,N111Value>, +prefix: String, +index: U32) -> List<&2,P113DStmt>:
  match values:
    case Nil{}: []
    case Con{value,rest}:
      Con{P113DScalar{N111Set{prefix ++ "result_" ++ U32.show(index),N111U64{},p112f_value(value,prefix)}},
        p113j_snapshots(rest,prefix,U32.inc(index))}


@unsafe
def p113j_expand(body: List<&2,P113DStmt>, +prefix: String, +destinations: List<&2,String>) -> List<&2,P113DStmt>:
  match body:
    case Nil{}: []
    case Con{P113DScalar{stmt},rest}: Con{P113DScalar{p112f_stmt(stmt,prefix)},p113j_expand(rest,prefix,destinations)}
    case Con{P113DIf{condition,yes,no},rest}:
      Con{P113DIf{p112f_value(condition,prefix),p113j_expand(yes,prefix,destinations),p113j_expand(no,prefix,destinations)},
        p113j_expand(rest,prefix,destinations)}
    case Con{P113DCall{names,target,args},rest}:
      Con{P113DCall{p113j_names(names,prefix),target,p113j_values(args,prefix)},p113j_expand(rest,prefix,destinations)}
    case Con{P113DResult{values},rest}:
      nt_append(P113DStmt,p113j_snapshots(values,prefix,0),p113j_assign(destinations,prefix,0))
    case _: []


@unsafe
def w4i_expand(body: List<&2,P113DStmt>, +prefix: String, +destinations: List<&2,String>, +callee: String) -> List<&2,P113DStmt>:
  match body:
    case Nil{}: []
    case Con{P113DScalar{stmt},rest}: Con{P113DScalar{p112f_stmt(stmt,prefix)},w4i_expand(rest,prefix,destinations,callee)}
    case Con{P113DIf{condition,yes,no},rest}:
      Con{P113DIf{p112f_value(condition,prefix),w4i_expand(yes,prefix,destinations,callee),w4i_expand(no,prefix,destinations,callee)},
        w4i_expand(rest,prefix,destinations,callee)}
    case Con{P113DCall{names,target,args},rest}:
      Con{P113DCall{p113j_names(names,prefix),target,p113j_values(args,prefix)},w4i_expand(rest,prefix,destinations,callee)}
    case Con{P113DResult{values},rest}:
      nt_append(P113DStmt,p113j_snapshots(values,prefix,0),p113j_assign(destinations,prefix,0))
    case Con{P113DAgain{values},rest}:
      [P113DCall{destinations,callee,p113j_values(values,prefix)}]


# ---- W5-R1 Pass 4a: 2-Step Peel for Tiny P113DCall-Free Self-Recursive Loops ----
law w5_expand_peel:
  for body: List<&2,P113DStmt>
  for +prefix: String
  for +destinations: List<&2,String>
  for +callee: P113DFunction
  for +fuel: U32
  List<&2,P113DStmt>

@unsafe
def w5_inline_step(callee: P113DFunction, +args: List<&2,N111Value>, +destinations: List<&2,String>,
    +prefix: String, +fuel: U32) -> List<&2,P113DStmt>:
  match callee:
    case P113DFunction{name,params,result,public,+body}:
      nt_append(P113DStmt,p113i_bind(params,args,prefix),
        w5_expand_peel(body,prefix,destinations,P113DFunction{name,params,result,public,body},fuel))

@unsafe
def w5_expand_peel(body,prefix,destinations,callee,fuel):
  match body:
    case Nil{}: []
    case Con{P113DScalar{stmt},rest}:
      Con{P113DScalar{p112f_stmt(stmt,prefix)},w5_expand_peel(rest,prefix,destinations,callee,fuel)}
    case Con{P113DIf{condition,yes,no},rest}:
      Con{P113DIf{p112f_value(condition,prefix),
            w5_expand_peel(yes,prefix,destinations,callee,fuel),
            w5_expand_peel(no,prefix,destinations,callee,fuel)},
        w5_expand_peel(rest,prefix,destinations,callee,fuel)}
    case Con{P113DCall{names,target,args},rest}:
      Con{P113DCall{p113j_names(names,prefix),target,p113j_values(args,prefix)},
        w5_expand_peel(rest,prefix,destinations,callee,fuel)}
    case Con{P113DResult{values},rest}:
      nt_append(P113DStmt,p113j_snapshots(values,prefix,0),p113j_assign(destinations,prefix,0))
    case Con{P113DAgain{values},rest}:
      +nextArgs = p113j_values(values,prefix)
      nt_choose(List<&2,P113DStmt>,U32.is_gt(fuel,0),
        u => w5_inline_step(callee,nextArgs,destinations,prefix ++ "p",U32.sub(fuel,1)),
        u => [P113DCall{destinations,w5_callee_name(callee),nextArgs}])

@unsafe
def p113nm_eligible(+book: List<&2,KDef>, +mat: KTerm, +count: U32) -> Bool:
  p98_tag_eq(mat,"Mat") && agy_str_eq(nm(mat),"Succ") && U32.is_eq(ix(mat),2) &&
    U32.is_eq(qt(mat),0) && U32.is_eq(terms_len(ks(mat)),2) && U32.is_eq(count,1) &&
    p113n_constructor(book,"Succ",1)


@unsafe
def p113nm_take(+book: List<&2,KDef>, +mat: KTerm, +word: N111Value, +count: U32, +n: U32) -> List<&2,N111Stmt>:
  nt_choose(List<&2,N111Stmt>,p113nm_eligible(book,mat,count),
    u => [N111Bin{"v_" ++ U32.show(nc_id(n)),N111U64{},"sub",word,N111Const{1,0}}],
    u => p111_take(nm(mat),word,count,n))


@unsafe
def p113a_function(function: P113DFunction, +heap_min: U32) -> P113DFunction:
  match function:
    case P113DFunction{name,params,result,public,body}: p113a_function_done(name,params,result,public,p113a_scan(body,0,heap_min))


@unsafe
def p113k_put(+facts: KDef, +name: String, fact: P113KFact) -> KDef:
  match fact:
    case P113KFact{bits,exact,lo,hi}:
      +h = index_hash(name,2166136261)
      +ver = ix(dt(index_find(facts,name,h,32)))
      p131i_insert(facts,KDef{name,"P113KFact",bits,Bool.to_u32(exact),kt("Epoch","",U32.inc(ver),0,[]),kt("P113KValue","",lo,hi,[]),[],False{},False{}},h)

@unsafe
def p113k_replace(+value: N111Value, +facts: KDef) -> N111Value:
  p113k_atom(value,p113k_value(value,facts))


@unsafe
def p113k_values(values: List<&2,N111Value>, +facts: KDef) -> List<&2,N111Value>:
  match values:
    case Nil{}: []
    case Con{value,rest}: Con{p113k_replace(value,facts),p113k_values(rest,facts)}


@unsafe
def p113k_args(args: List<&2,N111Arg>, +facts: KDef) -> List<&2,N111Arg>:
  match args:
    case Nil{}: []
    case Con{N111Arg{N111Ptr{},value},rest}: Con{N111Arg{N111Ptr{},value},p113k_args(rest,facts)}
    case Con{N111Arg{typ,value},rest}: Con{N111Arg{typ,p113k_replace(value,facts)},p113k_args(rest,facts)}


@unsafe
def p113k_join_fact(left: P113KFact, right: P113KFact) -> P113KFact:
  match left right:
    case P113KFact{+lb,+le,+ll,+lh} P113KFact{+rb,+re,+rl,+rh}:
      w5c2_join_fact_if(le && re && U32.is_eq(ll,rl) && U32.is_eq(lh,rh), lb, ll, lh, rb, rl, rh)

# AGY-W5-STRUCT + W5B-C2: zero-closure Patricia-trie structural intersection for p113k_join
@unsafe
def p113k_join_insert(+out: KDef, +name: String, +hash: U32, fact: P113KFact) -> KDef:
  match fact:
    case P113KFact{bits,exact,lo,hi}:
      p131i_insert(out,KDef{name,"P113KFact",bits,Bool.to_u32(exact),kt("Epoch","",1,0,[]),kt("P113KValue","",lo,hi,[]),[],False{},False{}},hash)

@unsafe
def w5c2_join_pair_ok(ok: Bool, +name: String, +hash: U32, +la: U32, +lx: U32, +lv: KTerm, +ra: U32, +rx: U32, +rv: KTerm, +out: KDef) -> KDef:
  match ok:
    case False{}: out
    case True{}:
      p113k_join_insert(out, name, hash, p113k_join_fact(
        P113KFact{la, U32.is_eq(lx, 1), ix(lv), qt(lv)},
        P113KFact{ra, U32.is_eq(rx, 1), ix(rv), qt(rv)}))

@unsafe
def p113k_limit(fact: P113KFact, +width: U32) -> P113KFact:
  match fact:
    case P113KFact{+bits,exact,+lo,+hi}:
      +nhi = w5c2_u32_pick(U32.is_eq(width, 32), 0, hi)
      w5c2_p113k_limit_if(exact, bits, lo, nhi, width)

@unsafe
def p113k_compare(+op: String, +left: P113KFact, +right: P113KFact) -> P113KFact:
  nt_choose(P113KFact,p113k_zero(left) && p113l_ones(right),u => p113k_unsigned(op,False{},True{}),u =>
    nt_choose(P113KFact,p113l_ones(left) && p113k_zero(right),u => p113k_unsigned(op,False{},False{}),u => p113l_base_compare(op,left,right)))

@unsafe
def p113k_binary(+op: String, +left: P113KFact, +right: P113KFact, +width: U32) -> P113KFact:
  p113l_enrich(p113l_base_binary(op,left,right,width),op,left,right)

@unsafe
def w4k_cond_subject(+facts: KDef, condition: N111Value) -> KDef:
  match condition:
    case N111Local{name}:
      +rel = p113l_relation(facts,name)
      nt_choose(KDef,agy_str_eq(dk(rel),"P113LRelation") && U32.is_le(p113k_bits_of(p113k_get(facts,nm(dv(rel)))),1),
        u => rel,u => missing())
    case _: missing()


@unsafe
def w4k_mark_val(value: N111Value, used: KDef) -> KDef:
  match value:
    case N111Local{+name}: index_set(used,KDef{name,"W4KUsed",0,0,atom("Absent"),atom("Absent"),[],False{},False{}},index_hash(name,2166136261),32)
    case _: used


@unsafe
def w4g_cval(+env: W4GCopyEnv, value: N111Value) -> N111Value:
  match value:
    case N111Local{n}: N111Local{w4g_resolve(env,n)}
    case _: value


@unsafe
def w4g_cvals(+env: W4GCopyEnv, values: List<&2,N111Value>) -> List<&2,N111Value>:
  match values:
    case Nil{}: []
    case Con{v,rest}: Con{w4g_cval(env,v),w4g_cvals(env,rest)}


@unsafe
def w4g_cargs(+env: W4GCopyEnv, args: List<&2,N111Arg>) -> List<&2,N111Arg>:
  match args:
    case Nil{}: []
    case Con{N111Arg{t,v},rest}: Con{N111Arg{t,w4g_cval(env,v)},w4g_cargs(env,rest)}


@unsafe
def w4g_record_alias_in(env: W4GCopyEnv, +dst: String, +rsrc: String) -> W4GCopyEnv:
  match env:
    case W4GCopyEnv{+vers,+aliases}:
      +sv = w4g_ver(vers,rsrc)
      +ent : KDef = KDef{dst,"W4GAlias",sv,0,atom("Absent"),kt("W4GSrc",rsrc,0,0,[]),[],False{},False{}}
      W4GCopyEnv{vers,index_set(aliases,ent,index_hash(dst,2166136261),32)}


@unsafe
def w4g_cscalar_if(cond: N111Value, +env: W4GCopyEnv, yc: W4GCopySc, nc: W4GCopySc) -> W4GCopySc:
  match yc nc:
    case W4GCopySc{yb,_} W4GCopySc{nb,_}:
      W4GCopySc{[N111If{w4g_cval(env,cond),yb,nb}],w4g_clear_aliases(env)}


@unsafe
def w5b_w4g_ins_if(live: Bool, +hash: U32, h: KDef, out: KDef) -> KDef:
  match live:
    case True{}: p131i_insert(out,KDef{dn(h),"W4GLive",1,0,atom("Absent"),atom("Absent"),[],False{},False{}},hash)
    case False{}: out

@unsafe
def w5b_w4g_union_bkt(+hash: U32, bucket: List<&2,KDef>, out: KDef) -> KDef:
  match bucket:
    case Nil{}: out
    case Con{+h,rest}:
      w5b_w4g_union_bkt(hash,rest,w5b_w4g_ins_if(U32.is_gt(da(h),0) || String.eq(dk(h),"W4KUsed"),hash,h,out))

@unsafe
def w4g_live_union_bucket(bucket: List<&2,KDef>, +out: KDef) -> KDef:
  match bucket:
    case Nil{}: out
    case Con{+h,rest}:
      w4g_live_union_bucket(rest,w5b_w4g_ins_if(U32.is_gt(da(h),0) || String.eq(dk(h),"W4KUsed"),index_hash(dn(h),2166136261),h,out))

@unsafe
def p113l_base_binary(+op: String, +left: P113KFact, +right: P113KFact, +width: U32) -> P113KFact:
  match left right:
    case P113KFact{+lb,+le,+ll,+lh} P113KFact{+rb,+re,+rl,+rh}:
      nt_choose(P113KFact,p111v_comparison(op),u => p113k_compare(op,left,right),u =>
      nt_choose(P113KFact,agy_str_eq(op,"and"),
        u => nt_choose(P113KFact,le && re,v => p113k_exact(U32.and(ll,rl),U32.and(lh,rh)),
          v => nt_choose(P113KFact,p113k_zero(left) || p113k_zero(right),w => p113k_exact(0,0),w => p113k_bound(U32.min(lb,rb)))),u =>
      nt_choose(P113KFact,agy_str_eq(op,"or"),
        u => nt_choose(P113KFact,le && re,v => p113k_exact(U32.or(ll,rl),U32.or(lh,rh)),v => p113k_bound(U32.max(lb,rb))),u =>
      nt_choose(P113KFact,agy_str_eq(op,"xor"),
        u => nt_choose(P113KFact,le && re,v => p113k_exact(U32.xor(ll,rl),U32.xor(lh,rh)),v => p113k_bound(U32.max(lb,rb))),u =>
      nt_choose(P113KFact,(agy_str_eq(op,"shr") || agy_str_eq(op,"shl")) && re && U32.is_eq(rh,0) && U32.is_lt(rl,width),
        u => p113k_shift(left,rl,agy_str_eq(op,"shr")),u =>
      nt_choose(P113KFact,agy_str_eq(op,"add"),
        u => nt_choose(P113KFact,le && re,v => w4k_add_exact(ll,lh,rl,rh,width),v => p113k_bound(U32.min(width,U32.inc(U32.max(lb,rb))))),u =>
      nt_choose(P113KFact,agy_str_eq(op,"sub"),
        u => nt_choose(P113KFact,le && re,v => w4k_sub_exact(ll,lh,rl,rh,width),v => p113k_bound(width)),u =>
      nt_choose(P113KFact,agy_str_eq(op,"mul"),
        u => nt_choose(P113KFact,le && re,v => w4k_mul_exact(ll,lh,rl,rh,width,lb,rb),v => p113k_bound(U32.min(width,U32.add(lb,rb)))),u =>
      nt_choose(P113KFact,agy_str_eq(op,"udiv"),
        u => nt_choose(P113KFact,le && re && U32.is_eq(lh,0) && U32.is_eq(rh,0) && U32.is_ne(rl,0),
          v => p113k_exact(U32.div(ll,rl),0),v => p113k_bound(lb)),u =>
      nt_choose(P113KFact,agy_str_eq(op,"urem"),
        u => nt_choose(P113KFact,le && re && U32.is_eq(lh,0) && U32.is_eq(rh,0) && U32.is_ne(rl,0),
          v => p113k_exact(U32.mod(ll,rl),0),v => p113k_bound(U32.min(lb,rb))),
        u => p113k_bound(width)))))))))))


@unsafe
def p113l_base_compare(+op: String, left: P113KFact, right: P113KFact) -> P113KFact:
  match left right:
    case P113KFact{+lb,+le,+ll,+lh} P113KFact{+rb,+re,+rl,+rh}:
      nt_choose(P113KFact,le && re,
        u => p113k_unsigned(op,U32.is_eq(ll,rl) && U32.is_eq(lh,rh),U32.is_lt(lh,rh) || (U32.is_eq(lh,rh) && U32.is_lt(ll,rl))),u =>
      nt_choose(P113KFact,re && U32.is_lt(lb,rb),u => p113k_unsigned(op,False{},True{}),u =>
      nt_choose(P113KFact,le && U32.is_lt(rb,lb),u => p113k_unsigned(op,False{},False{}),u => p113k_bound(1))))


# The admitted direct IR reserves a non-reassignable 2048-byte scratch pointer.
# Restrict this fact to that buffer and the exact primitive ABI; arbitrary local
# pointers need capacity facts that this scalar pass deliberately does not track.
# These runtime primitives return raw 0/1 even for NaNs or packed Bool inputs.
@unsafe
def p113l_relation(+facts: KDef, +name: String) -> KDef:
  w5c2_p113l_rel_check(p111v_get(facts, "@condition:" ++ name), facts, name)

@unsafe
def p113l_relate(+facts: KDef, +name: String, subject: String, version: U32, truth: U32) -> KDef:
  +key = "@condition:" ++ name
  index_set(facts, KDef{key, "P113LRelation", truth, 0, kt("Epoch", "", version, p113l_version(facts, name), []), kt("Subject", subject, 0, 0, []), [], False{}, False{}}, index_hash(key, 2166136261), 32)

law agy_p124r_known_orig:
  for +ready: KDef
  for +name: String
  Bool

@unsafe
def p114h_rename(body: List<&2,P114RStmt>, +prefix: String) -> List<&2,P114RStmt>:
  match body:
    case Nil{}: []
    case Con{stmt,rest}: Con{p114h_rename_stmt(stmt,prefix),p114h_rename(rest,prefix)}


@unsafe
def p114h_rename_stmt(stmt: P114RStmt, +prefix: String) -> P114RStmt:
  match stmt:
    case P114RScalar{scalar}: P114RScalar{p112f_stmt(scalar,prefix)}
    case P114RIf{condition,yes,no}: P114RIf{p112f_value(condition,prefix),p114h_rename(yes,prefix),p114h_rename(no,prefix)}
    case P114RDescend{frame,arguments}: P114RDescend{p112f_rename(frame,prefix),p112f_rename(arguments,prefix)}
    case P114RAgain{arguments}: P114RAgain{p112f_rename(arguments,prefix)}
    case P114RResult{value}: P114RResult{p112f_value(value,prefix)}
    case P114RFailure{body}: P114RFailure{p112f_rename(body,prefix)}
    case P114RResumeReady{frame,call,result}: P114RResumeReady{p112f_rename(frame,prefix),p112f_rename(call,prefix),p112f_value(result,prefix)}
    case P114RPushFrame{frame}: P114RPushFrame{p112f_rename(frame,prefix)}


@unsafe
def p117h_put(facts: KDef, +name: String, origin: U32) -> KDef:
  index_set(facts,KDef{name,"P117HOrigin",origin,0,{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},[],False{},False{}},index_hash(name,2166136261),32)


@unsafe
def p117v_template(+original: N111Stmt, +n: U32, +origin: U32) -> List<&2,N111Stmt>:
  p117v_template_ex(original,n,origin,missing())

@unsafe
def p117v_template_sunk(+original: N111Stmt, +n: U32, +origin: U32, +v0: N111Value, +v1: N111Value, +v2: N111Value) -> List<&2,N111Stmt>:
  p117v_template_sunk_ex(original,n,origin,v0,v1,v2,missing())

law p117v_rewrite_ex:
  for +body: List<&2,P113DStmt>
  for +n: U32
  for +heap_min: U32
  for +used: U32
  for +sites: KDef
  for +nomask: KDef
  P113ABody

@unsafe
def p117v_rewrite_no_ex(condition: N111Value, yes: List<&2,P113DStmt>, rest: List<&2,P113DStmt>, +heap_min: U32, +used: U32, +sites: KDef, +nomask: KDef, no: P113ABody) -> P113ABody:
  match no:
    case P113ABody{nb,nn}: p113a_prefix([P113DIf{condition,yes,nb}],p117v_rewrite_ex(rest,nn,heap_min,used,sites,nomask))

@unsafe
def p117v_rewrite_yes_ex(condition: N111Value, no: List<&2,P113DStmt>, rest: List<&2,P113DStmt>, +heap_min: U32, +used: U32, +sites: KDef, +nomask: KDef, yes: P113ABody) -> P113ABody:
  match yes:
    case P113ABody{body,next}:
      p117v_rewrite_no_ex(condition,body,rest,heap_min,used,sites,nomask,p117v_rewrite_ex(no,next,heap_min,used,sites,nomask))

@unsafe
def p117v_rewrite_step_ex(body: List<&2,P113DStmt>, +n: U32, +heap_min: U32, +used: U32, +sites: KDef, +nomask: KDef) -> P113ABody:
  match body:
    case Nil{}: P113ABody{[],n}
    case Con{P113DScalar{+stmt},+rest}:
      +origin = p117h_get(sites,U32.show(n))
      nt_choose(P113ABody,U32.is_eq(p113a_stmt_id(stmt),0),
        u => p113a_prefix([P113DScalar{stmt}],p117v_rewrite_ex(rest,n,heap_min,used,sites,nomask)),u =>
        p113a_prefix(p113d_scalars(nt_choose(List<&2,N111Stmt>,U32.is_eq(U32.and(used,p117h_bit(origin)),0),
          v => p113a_template(stmt,n,heap_min),v => p117v_template_ex(stmt,n,origin,nomask))),
          p117v_rewrite_ex(rest,U32.inc(n),heap_min,used,sites,nomask)))
    case Con{P113DIf{condition,yes,no},rest}:
      p117v_rewrite_yes_ex(condition,no,rest,heap_min,used,sites,nomask,p117v_rewrite_ex(yes,n,heap_min,used,sites,nomask))
    case Con{head,rest}: p113a_prefix([head],p117v_rewrite_ex(rest,n,heap_min,used,sites,nomask))

@unsafe
def p117v_rewrite_sunk_ex(sunk: P113ASunk, body: List<&2,P113DStmt>, +n: U32, +heap_min: U32, +used: U32, +sites: KDef, +nomask: KDef) -> P113ABody:
  match sunk:
    case P113ASunkYes{stmt,id,pre,v0,v1,v2,rest}:
      +origin = p117h_get(sites,U32.show(n))
      p113a_prefix(nt_append(P113DStmt,pre,p113d_scalars(
        nt_choose(List<&2,N111Stmt>,U32.is_eq(U32.and(used,p117h_bit(origin)),0),
          v => p113a_template_sunk(stmt,n,heap_min,v0,v1,v2),
          v => p117v_template_sunk_ex(stmt,n,origin,v0,v1,v2,nomask)))),
        p117v_rewrite_ex(rest,U32.inc(n),heap_min,used,sites,nomask))
    case P113ASunkNo{}: p117v_rewrite_step_ex(body,n,heap_min,used,sites,nomask)

@unsafe
def p117v_rewrite_ex(body,n,heap_min,used,sites,nomask):
  p117v_rewrite_sunk_ex(p113a_match_sunk(body),body,n,heap_min,used,sites,nomask)

@unsafe
def p117v_rewrite(+body: List<&2,P113DStmt>, +n: U32, +heap_min: U32, +used: U32, +sites: KDef) -> P113ABody:
  p117v_rewrite_ex(body,n,heap_min,used,sites,missing())

# --- Flow-Sensitive BCE Fact Analysis (Bitmask & Unit-Stride IV) ---
# Fact entry per variable stored in a single KDef map `env`:
#   dk = "BM"  -> da = upper bound M (<= 0x7fffffff), dx = 0
#   dk = "INC" -> da = param_idx, dx = 1 (value == param[da] + 1)
#   dk = "DEC" -> da = param_idx, dx = 2 (value == param[da] - 1)
#   dk = "NZ"  -> da = param_idx, dx = 3 (value == (param[da] != 0))
#   dk = "PRM" -> da = param_idx, dx = 4 (value == param[da])
#   dk = "UNK" -> unknown / killed

@unsafe
def w4c_env_kill(+env: KDef, +name: String) -> KDef:
  p111v_put(env,name,"UNK",0,0)

@unsafe
def w4c_env_seed(params: List<&2,NC_Binding>, +i: U32, +env: KDef) -> KDef:
  match params:
    case Nil{}: env
    case Con{NC_Binding{_,word,_},rest}:
      w4c_env_seed(rest,U32.inc(i),p111v_put(env,word,"PRM",i,4))

@unsafe
def p118t_import_contract(+symbol: String, +args: List<&2,N111Arg>, +live: KDef, +ids: N111Ids) -> Bool:
  nt_choose(Bool,agy_str_eq(symbol,"p118_rt_extend"),u =>
    p118t_extend_contract(args,live,ids,p111v_target(p111v_arg(args,2),ids,True{})),u =>
    agy_str_eq(symbol,"p118_rt_finish") && p111v_args(args,[3,2,2,2],live,ids))


@unsafe
def p118b_project_call(+stmt: N111Stmt, +ids: N111Ids) -> P113DCode:
  match stmt:
    case N111Call{+name,+typ,+symbol,+args}:
      nt_choose(P113DCode,agy_str_eq(symbol,"p118_rt_borrow_fields"),
        u => p118b_project_borrow(name,typ,args,ids),
        u => nt_choose(P113DCode,agy_str_eq(symbol,"p118_rt_borrow_scalar_safe"),
          v => p128bs_project_guard(name,typ,args),
          v => P113DCode{[P113DScalar{stmt}],0,"",[]}))
    case _: P113DCode{[P113DScalar{stmt}],0,"",[]}

@unsafe
def p118b_project(body: List<&2,P113DStmt>, ids: N111Ids) -> P113DCode:
  p118ns_project(body,ids,[],"")


@unsafe
def p118b_project_function(+function: P113DFunction, +ids: N111Ids) -> P118BWorkers:
  match function:
    case P113DFunction{name,params,result,public,body}:
      +projected = p118b_project(body,ids)
      P118BWorkers{[P113DFunction{name,params,result,public,p113d_body(projected)}],p113d_error(projected)}


@unsafe
def p118ns_project_node(stmt: P113DStmt, +ids: N111Ids) -> P113DCode:
  match stmt:
    case P113DScalar{scalar}: p118b_project_call(scalar,ids)
    case P113DIf{condition,yes,no}: p113d_branch(condition,p118b_project(yes,ids),p118b_project(no,ids))
    case _: P113DCode{[stmt],0,"",[]}


@unsafe
def p118ns_project(body: List<&2,P113DStmt>, +ids: N111Ids, reversed: List<&2,P113DStmt>, error: String) -> P113DCode:
  match body:
    case Nil{}: P113DCode{nt_reverse(P113DStmt,reversed,[]),0,error,[]}
    case Con{head,rest}:
      +projected = p118ns_project_node(head,ids)
      p118ns_project(rest,ids,nt_reverse(P113DStmt,p113d_body(projected),reversed),
        p111_first(error,p113d_error(projected)))


@unsafe
def p118ns_project_functions(functions: List<&2,P113DFunction>, +ids: N111Ids, reversed: List<&2,P113DFunction>, error: String) -> P118BWorkers:
  match functions:
    case Nil{}: P118BWorkers{nt_reverse(P113DFunction,reversed,[]),error}
    case Con{head,rest}:
      +projected = p118b_project_function(head,ids)
      p118ns_project_functions(rest,ids,nt_reverse(P113DFunction,p118ns_worker_functions(projected),reversed),
        p111_first(error,p118ns_worker_error(projected)))


@unsafe
def p198e_word(+book: List<&2,KDef>, +ty: KTerm, +name: String) -> Bool:
  j_primitive_type(book,wnf(book,ty),name)

@unsafe
def p121c_source_prefix(+book: List<&2,KDef>, +ty: KTerm, +term: KTerm, +left: U32) -> KTerm:
  +h = wnf(book,ty)
  +t = j_strip(term)
  nt_choose(KTerm,U32.is_eq(left,0),u => t,u =>
    nt_choose(KTerm,agy_str_eq(tg(h),"All") && U32.is_eq(qt(h),0) && j_callback_type_domain(book,kid(h,0)) &&
      agy_str_eq(tg(t),"Lam") && U32.is_eq(qt(t),0) && U32.is_eq(terms_len(ks(t)),1) &&
      j_callback_runtime_absent(kid(t,0),ix(t),2048),v =>
      k_rebuild(t,nm(t),ix(t),1,[p121c_source_prefix(book,kid(h,1),kid(t,0),U32.sub(left,1))],rm(t),0,0),
      v => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}))


@unsafe
def p121c_signature(+book: List<&2,KDef>, +ty: KTerm, +left: U32) -> Bool:
  +head = wnf(book,ty)
  nt_choose(Bool,U32.is_eq(left,0),u => j_primitive_type(book,head,"U32"),u =>
    agy_str_eq(tg(head),"All") && Bool.not(U32.is_eq(qt(head),0)) &&
    j_primitive_type(book,wnf(book,kid(head,0)),"U32") && p121c_signature(book,kid(head,1),U32.sub(left,1)))


@unsafe
def p123p_put(+facts: KDef, +name: String, +root: String, invert: U32) -> KDef:
  +key = "@p123predicate:" ++ name
  index_set(facts,KDef{key,"P123Predicate",invert,0,
    kt("Epoch","",p113l_version(facts,root),p113l_version(facts,name),[]),
    kt("Root",root,0,0,[]),[],False{},False{}},index_hash(key,2166136261),32)


@unsafe
def w5c2_p123p_test_if(ok: Bool, +op: String, +lo: U32, +facts: KDef, +source: String) -> KDef:
  match ok:
    case True{}: p123p_test_origin(op, lo, p123p_get(facts, source))
    case False{}: missing()

@unsafe
def p123p_test(+op: String, value: N111Value, constant: N111Value, +facts: KDef) -> KDef:
  match value constant:
    case N111Local{source} N111Const{+lo,+hi}:
      w5c2_p123p_test_if((String.eq(op,"eq") || String.eq(op,"ne")) && U32.is_eq(hi,0) && U32.is_le(lo,1), op, lo, facts, source)
    case _ _: missing()

@unsafe
def w5c2_p123p_pick_fwd(hit: Bool, +forward: KDef, +op: String, +right: N111Value, +left: N111Value, +facts: KDef) -> KDef:
  match hit:
    case True{}: forward
    case False{}: p123p_test(op, right, left, facts)

@unsafe
def w5c2_p123p_pick_eq(is_eqne: Bool, +op: String, +left: N111Value, +right: N111Value, +facts: KDef) -> KDef:
  match is_eqne:
    case False{}: missing()
    case True{}:
      +forward = p123p_test(op, left, right, facts)
      w5c2_p123p_pick_fwd(String.eq(dk(forward), "P123Test"), forward, op, right, left, facts)

@unsafe
def p124r_complete(+ready: KDef, +name: String, +function: KDef) -> P124Callable:
  +count = da(function)
  nt_choose(P124Callable,agy_str_eq(dk(function),"P113Direct") && U32.is_eq(dx(function),1) &&
    U32.is_eq(ix(dv(function)),1) && U32.is_le(count,8),
    u => P124Callable{True{},count,p113e_symbol(name)},u => p124r_legacy(ready,name))



# ============================================================================
# AGY-W2B-2: Multi-Pass Topological p114r Direct-Worker Promotion
# ============================================================================

@unsafe
def agy_p124r_hready(+ready: KDef, +hready: KDef, +name: String) -> P124Callable:
  +entry = p111v_get(hready,name)
  +count = da(entry)
  nt_choose(P124Callable,agy_str_eq(dk(entry),"AgyHReady") && U32.is_le(count,8),
    u => P124Callable{True{},count,p114r_symbol(name)},
    u => p124r_legacy(ready,name))

@unsafe
def agy_p124r_complete3(+ready: KDef, +hready: KDef, +name: String, +function: KDef) -> P124Callable:
  +count = da(function)
  nt_choose(P124Callable,agy_str_eq(dk(function),"P113Direct") && U32.is_eq(dx(function),1) &&
    U32.is_eq(ix(dv(function)),1) && U32.is_le(count,8),
    u => P124Callable{True{},count,p113e_symbol(name)},
    u => agy_p124r_hready(ready,hready,name))

@unsafe
def agy_p124r_known_orig_children(children: List<&2,KDef>, +name: String) -> Bool:
  match children:
    case Con{ready,Con{direct,rest}}: p124r_valid(p124r_complete(ready,name,p111v_get(direct,name)))
    case _: False{}

@unsafe
def agy_p124r_known_orig(ready,name):
  nt_choose(Bool,p124r_is_view(ready),
    u => agy_p124r_known_orig_children(dc(ready),name),
    u => p112w_ready(ready,name))

@unsafe
def p124r_lookup_children(children: List<&2,KDef>, +name: String) -> P124Callable:
  match children:
    case Con{ready,Con{direct,Nil{}}}: p124r_complete(ready,name,p111v_get(direct,name))
    case Con{ready,Con{direct,Con{hready,Nil{}}}}: agy_p124r_complete3(ready,hready,name,p111v_get(direct,name))
    case _: P124Callable{False{},0,""}


@unsafe
def p124r_lookup(view: KDef, name: String) -> P124Callable:
  p124r_lookup_children(dc(view),name)



@unsafe
def p125i_previous_fallback(+name: String, +values: List<&2,N111Value>) -> P111ValueCode:
  +id = p111_op_id(name)
  nt_choose(P111ValueCode,U32.is_eq(id,0),u => P111ValueCode{Nil{},N111Const{0,0},"unknown native primitive " ++ name},
    u => P111ValueCode{nt_append(N111Stmt,p111_store(values,0),[N111Call{"value",N111U64{},"p111_rt_op",[
      p111_state(),p111_u32(id),p111_scratch(),p111_u32(nt_count(N111Value,values))]}]),N111Local{"value"},""})

@unsafe
def p126s_kind(+book: List<&2,KDef>, +ty: KTerm) -> String:
  +head = wnf(book,ty)
  nt_choose(String,j_primitive_type(book,head,"F32"),u => "F32",u =>
    nt_choose(String,j_primitive_type(book,head,"U32"),u => "U32",u => ""))


@unsafe
def p126dp_selected(+name: String, +values: List<&2,N111Value>, +wanted: KTerm) -> Bool:
  U32.is_eq(p111_op_id(name),70) && U32.is_eq(nt_count(N111Value,values),2) &&
    p113p_known(wanted) && agy_str_eq(nm(wanted),"Tuple") && U32.is_eq(ix(wanted),2)


@unsafe
def p126sc_bind(params: List<&2,NC_Binding>, +prefix: String, +index: U32) -> List<&2,P113DStmt>:
  match params:
    case Nil{}: []
    case Con{NC_Binding{id,word,kind},rest}:
      Con{P113DScalar{N111Set{p112f_name(prefix,word),N111U64{},N111Local{"p126scc_arg_" ++ U32.show(index)}}},p126sc_bind(rest,prefix,U32.inc(index))}


@unsafe
def p126sc_rewrite(body: List<&2,P113DStmt>, +prefix: String, +left: String, +right: String, +self_tag: U32, +width: U32) -> List<&2,P113DStmt>:
  match body:
    case Nil{}: []
    case Con{P113DScalar{stmt},rest}:
      Con{P113DScalar{p112f_stmt(stmt,prefix)},p126sc_rewrite(rest,prefix,left,right,self_tag,width)}
    case Con{P113DIf{condition,yes,no},rest}:
      Con{P113DIf{p112f_value(condition,prefix),p126sc_rewrite(yes,prefix,left,right,self_tag,width),p126sc_rewrite(no,prefix,left,right,self_tag,width)},p126sc_rewrite(rest,prefix,left,right,self_tag,width)}
    case Con{P113DCall{destinations,+target,+args},+rest}:
      nt_choose(List<&2,P113DStmt>,p126sc_internal(target,left,right),
        u => [P113DAgain{p126sc_lanes(nt_choose(U32,agy_str_eq(target,left),v => 0,v => 1),p113j_values(args,prefix),width)}],
        u => Con{P113DCall{p113j_names(destinations,prefix),target,p113j_values(args,prefix)},p126sc_rewrite(rest,prefix,left,right,self_tag,width)})
    case Con{P113DResult{values},rest}: Con{P113DResult{p113j_values(values,prefix)},p126sc_rewrite(rest,prefix,left,right,self_tag,width)}
    case Con{P113DAgain{values},rest}: [P113DAgain{p126sc_lanes(self_tag,p113j_values(values,prefix),width)}]


@unsafe
def p126sc_counts(candidates: List<&2,P113DCandidate>, +counts: KDef, +slot: U32) -> KDef:
  match candidates:
    case Nil{}: counts
    case Con{P113DCandidate{function,error,calls},rest}:
      +name = p126sc_name(function)
      p126sc_counts(rest,index_set(counts,KDef{name,"P126Count",U32.inc(da(p111v_get(counts,name))),slot,{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},kt("Calls","",0,0,p126sc_call_terms(calls)),[],False{},False{}},index_hash(name,2166136261),32),U32.inc(slot))


@unsafe
def p128rf_members(names: List<&2,String>, tree: KDef) -> KDef:
  match names:
    case Nil{}: tree
    case Con{+name,rest}:
      p128rf_members(rest,index_set(tree,
        KDef{name,"P128ReachMember",0,0,{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},[],False{},False{}},
        index_hash(name,2166136261),32))


@unsafe
def p130m_strings_read(nodes: Array<P88Node>, strings: Array<String>, made: U32, sn: U32, begin: U32, end: U32, +index: U32, total: U32, text: String, mode: U32, value: String, valid: Bool) -> P88Decoded:
  match valid:
    case True{}: p88_strings(P88State{P88Cursor{text,mode},nodes,Array.set(String,strings,index,value),made,sn,begin,end},U32.inc(index),total)
    case False{}: P88DecodeError{"cache string"}

@unsafe
def p131u_unshared(+book: List<&2,KDef>, +uses: List<&2,P131UEntry>, terms: List<&2,KTerm>) -> Bool:
  match terms:
    case Nil{}: True{}
    case Con{+term,+rest}:
      nt_choose(Bool,p98_tag_eq(term,"Ann"),
        u => nt_choose(Bool,p98_tag_eq(kid(term,0),"Var"),
          v => nt_choose(Bool,ns_array_free(book,kid(term,1)),w => p131u_unshared(book,uses,rest),w => nt_choose(Bool,U32.is_le(p131u_max(uses,ix(kid(term,0))),1),x => p131u_unshared(book,uses,rest),x => False{})),
          v => p131u_unshared(book,uses,Con{kid(term,0),rest})),
        u => nt_choose(Bool,p98_tag_eq(term,"Var"),
          v => nt_choose(Bool,U32.is_le(p131u_max(uses,ix(term)),1),w => p131u_unshared(book,uses,nt_append(KTerm,ks(term),rest)),w => False{}),
          v => p131u_unshared(book,uses,nt_append(KTerm,ks(term),rest))))


@unsafe
def p131u_hot(+book: List<&2,KDef>, +uses: List<&2,P131UEntry>, terms: List<&2,KTerm>, +hot: List<&2,String>) -> List<&2,String>:
  match terms:
    case Nil{}: hot
    case Con{+term,+rest}:
      nt_choose(List<&2,String>,nb_contains(hot,"*"),u => hot,u =>
        nt_choose(List<&2,String>,p98_tag_eq(term,"Ann"),v =>
          nt_choose(List<&2,String>,p98_tag_eq(kid(term,0),"Var"),w =>
            p131u_hot(book,uses,rest,nt_choose(List<&2,String>,U32.is_gt(p131u_max(uses,ix(kid(term,0))),1),x => nh_type(book,kid(term,1),hot,64),x => hot)),
            w => p131u_hot(book,uses,Con{kid(term,0),rest},hot)),v =>
          nt_choose(List<&2,String>,p98_tag_eq(term,"Var"),w => nt_choose(List<&2,String>,U32.is_gt(p131u_max(uses,ix(term)),1),x => nh_add("*",hot),x => p131u_hot(book,uses,rest,hot)),w => p131u_hot(book,uses,nt_append(KTerm,ks(term),rest),hot))))

@unsafe
def p131i_original_set(+tree: KDef, +d: KDef, +hash: U32, +bits: U32) -> KDef:
  w5c2_orig_set_if(String.eq(dk(tree), "Absent"), tree, d, hash)


law p131i_insert:
  for +tree: KDef
  for +d: KDef
  for +hash: U32
  KDef

@unsafe
def w5c_p131i_br(bit: U32, +stored: U32, +split: U32, +left: KDef, +right: KDef, +d: KDef, +hash: U32) -> KDef:
  match bit:
    case 0: KIndexNode{stored, split, p131i_insert(left, d, hash), right}
    case _: KIndexNode{stored, split, left, p131i_insert(right, d, hash)}

@unsafe
def w5c_p131i_in(outside: U32, +tree: KDef, +stored: U32, +split: U32, +left: KDef, +right: KDef, +d: KDef, +hash: U32, +diff: U32) -> KDef:
  match outside:
    case 0: w5c_p131i_br(U32.and(hash, split), stored, split, left, right, d, hash)
    case _:
      +m = index_split_bit(diff)
      w5c_p131i_join(U32.and(hash, m), stored, tree, d, hash, m)

@unsafe
def p131i_insert(tree, d, hash):
  match tree:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      p131i_original_set(tree, d, hash, 32)
    case KIndexLeaf{stored, bucket}:
      w5c_p131i_leaf(index_split_bit(U32.xor(hash, stored)), tree, d, hash, stored, bucket)
    case KIndexNode{stored, split, left, right}:
      +diff = U32.xor(hash, stored)
      w5c_p131i_in(U32.and(diff, U32.sub(split, 1)), tree, stored, split, left, right, d, hash, diff)

@unsafe
def p142j_mark(seen: KDef, name: String, hash: U32) -> KDef:
  index_set(seen,KDef{name,"P142JSeen",0,0,
    {KTerm{"Absent","",0,0,[],[],0,0}:KTerm},
    {KTerm{"Absent","",0,0,[],[],0,0}:KTerm},[],False{},False{}},hash,32)

# Test/bridge helper: the production checked entry starts from missing().

@unsafe
def p143cs_step(+head: KDef, tail: P143CSchedule) -> P143CSchedule:
  match tail:
    case P143CSchedule{+index,events}:
      +next = index_find(index,dn(head),index_hash(dn(head),2166136261),32)
      P143CSchedule{
        nt_choose(KDef,p88_string_eq(dk(head),"BookCache"),
          u => index_first(dc(head)),
          u => index_set(index,head,index_hash(dn(head),2166136261),32)),
        Con{P143CEvent{head,next},events}}


@unsafe
def p144p_update(+definition: KDef, view: Maybe<&2,KDef>) -> Maybe<&2,KDef>:
  match view:
    case None{}: None{}
    case Some{index}: Some{index_set(index,definition,index_hash(dn(definition),2166136261),32)}


@unsafe
def p144o_identity(+book: List<&2,KDef>, facts: P144OFacts, +name: String) -> String:
  nt_choose(String,p144o_query(book,facts,name),u => name,u => nc_ctor_encode(name))

# Catalogue normalization still uses the ORIGINAL source book. Only ownership
# identity queries consume the shared summary; order/arity/foreign rules stay.

@unsafe
def w7c_p144o_specs_set(+book: List<&2,KDef>, children: List<&2,KDef>, +params: U32, +owned_set: KDef) -> List<&2,N_Constructor>:
  match children:
    case Nil{}: []
    case Con{+child,rest}:
      +cname = dn(child)
      +ident = nt_choose(String,p142j_member(owned_set,cname,index_hash(cname,2166136261)),u => cname,u => nc_ctor_encode(cname))
      Con{N_Constructor{ident,nc_live_count(book,nc_skip_tel(book,dt(child),params),da(child)),True{}},
        w7c_p144o_specs_set(book,rest,params,owned_set)}

@unsafe
def w7c_p144o_constructors_set(+book: List<&2,KDef>, definitions: List<&2,KDef>, +owned_set: KDef) -> List<&2,N_Constructor>:
  match definitions:
    case Nil{}: []
    case Con{+definition,+rest}:
      nt_choose(List<&2,N_Constructor>,p88_string_eq(dk(definition),"ADT"),
        u => List.append(&2,N_Constructor,w7c_p144o_specs_set(book,dc(definition),da(definition),owned_set),w7c_p144o_constructors_set(book,rest,owned_set)),
        u => nt_choose(List<&2,N_Constructor>,p88_string_eq(dk(definition),"Def") && nc_foreign(definition),
          v => Con{N_Constructor{dn(definition),nc_all_args(book,dt(definition)),True{}},w7c_p144o_constructors_set(book,rest,owned_set)},
          v => w7c_p144o_constructors_set(book,rest,owned_set)))

@unsafe
def p144o_specs(+book: List<&2,KDef>, children: List<&2,KDef>, +params: U32, +facts: P144OFacts) -> List<&2,N_Constructor>:
  match children:
    case Nil{}: []
    case Con{+child,rest}:
      Con{N_Constructor{p144o_identity(book,facts,dn(child)),nc_live_count(book,nc_skip_tel(book,dt(child),params),da(child)),True{}},
        p144o_specs(book,rest,params,facts)}


@unsafe
def p144o_constructors_fallback(+book: List<&2,KDef>, definitions: List<&2,KDef>, +facts: P144OFacts) -> List<&2,N_Constructor>:
  match definitions:
    case Nil{}: []
    case Con{+definition,+rest}:
      nt_choose(List<&2,N_Constructor>,p88_string_eq(dk(definition),"ADT"),
        u => List.append(&2,N_Constructor,p144o_specs(book,dc(definition),da(definition),facts),p144o_constructors_fallback(book,rest,facts)),
        u => nt_choose(List<&2,N_Constructor>,p88_string_eq(dk(definition),"Def") && nc_foreign(definition),
          v => Con{N_Constructor{dn(definition),nc_all_args(book,dt(definition)),True{}},p144o_constructors_fallback(book,rest,facts)},
          v => p144o_constructors_fallback(book,rest,facts)))

@unsafe
def p144o_owned(+book: List<&2,KDef>, name: String) -> Bool:
  p144o_owned_context(book,name,nc_ctor_context(book))

# The hot query returns Bool directly via O(1) hash-trie membership when attached.

@unsafe
def w7c_p144o_owned_children(+book: List<&2,KDef>, +query: String, +typ: KTerm, children: List<&2,KDef>) -> Bool:
  match children:
    case Con{_, Con{owned_set, _}}:
      nt_choose(Bool,p98_tag_eq(typ,"P144Ownership"),
        u => p142j_member(owned_set,query,index_hash(query,2166136261)),
        u => p144o_owned_term(book,query,typ))
    case _: p144o_owned_term(book,query,typ)

@unsafe
def p144o_owned_context(+book: List<&2,KDef>, +query: String, context: KDef) -> Bool:
  match context:
    case KDef{name,kind,arity,templates,typ,value,children,native,uns}:
      nt_choose(Bool,p88_string_eq(name,"$native.ctors") && p88_string_eq(kind,"NativeCtorIndex") &&
        U32.is_eq(arity,0) && U32.is_eq(templates,0) && Bool.not(native) && Bool.not(uns),
        u => w7c_p144o_owned_children(book,query,typ,children),u => p144o_original(book,query))
    case _: p144o_original(book,query)


@unsafe
def p144ce_query(+book: List<&2,KDef>, facts: P144CEFacts, +name: String) -> Bool:
  match facts:
    case P144CEFacts{members,valid}:
      nt_choose(Bool,valid && book_final_name_valid(name),
        u => p142j_member(members,name,index_hash(name,2166136261)),
        u => constructor_exists(book,name))


@unsafe
def w7c_p167l_demand_if(absent: Bool, +name: String, +h: U32, +todo: List<&2,String>, +asked: KDef, +count: U32) -> P167Demand:
  match absent:
    case True{}:
      P167Demand{Con{name,todo},p131i_insert(asked,KDef{name,"P167Seen",0,0,atom("Absent"),atom("Absent"),[],False{},False{}},h),U32.inc(count)}
    case False{}: P167Demand{todo,asked,count}

@unsafe
def w7c_p167l_cat_old(absent: Bool, +old: KDef, +name: String, +h: U32, +source: String, +kind: String, +arity: U32, +allowed: Bool, +index: KDef) -> P167Catalogue:
  match absent:
    case True{}:
      P167Catalogue{p131i_insert(index,KDef{name,kind,arity,Bool.to_u32(allowed),ref(source),atom("Absent"),[],False{},False{}},h),""}
    case False{}:
      nt_choose(P167Catalogue,agy_str_eq(dk(old),kind) && agy_str_eq(nm(dt(old)),source) && U32.is_eq(da(old),arity),
        w => P167Catalogue{index,""},w => P167Catalogue{index,"demand: conflicting scheduled identity " ++ name})

@unsafe
def w7c_p167l_cat_err(hasErr: Bool, +name: String, +source: String, +kind: String, +arity: U32, +allowed: Bool, +index: KDef, +error: String) -> P167Catalogue:
  match hasErr:
    case True{}: P167Catalogue{index,error}
    case False{}:
      +h = index_hash(name,2166136261)
      +old = w5c3_find(index,name,h)
      w7c_p167l_cat_old(agy_str_eq(dk(old),"Absent"),old,name,h,source,kind,arity,allowed,index)

@unsafe
def w6_rw_val(+alias: KDef, val: N111Value) -> N111Value:
  match val:
    case N111FuncId{name}: N111FuncId{w6_alias(alias,name)}
    case _: val

@unsafe
def w6_rw_args(+alias: KDef, args: List<&2,N111Arg>) -> List<&2,N111Arg>:
  match args:
    case Nil{}: []
    case Con{N111Arg{typ,val},rest}: Con{N111Arg{typ,w6_rw_val(alias,val)},w6_rw_args(alias,rest)}

law w6_rw_stmts:
  for +alias: KDef
  for body: List<&2,N111Stmt>
  List<&2,N111Stmt>

@unsafe
def w6_rw_stmt(+alias: KDef, stmt: N111Stmt) -> N111Stmt:
  match stmt:
    case N111Set{name,typ,val}: N111Set{name,typ,w6_rw_val(alias,val)}
    case N111Bin{name,typ,op,left,right}: N111Bin{name,typ,op,w6_rw_val(alias,left),w6_rw_val(alias,right)}
    case N111Call{name,typ,symbol,args}: N111Call{name,typ,symbol,w6_rw_args(alias,args)}
    case N111If{cond,yes,no}: N111If{w6_rw_val(alias,cond),w6_rw_stmts(alias,yes),w6_rw_stmts(alias,no)}
    case N111Return{val}: N111Return{w6_rw_val(alias,val)}
    case N111Load{name,typ,base,offset}: N111Load{name,typ,w6_rw_val(alias,base),offset}
    case N111Store{typ,base,offset,val}: N111Store{typ,w6_rw_val(alias,base),offset,w6_rw_val(alias,val)}
    case N111Offset{name,base,bytes}: N111Offset{name,w6_rw_val(alias,base),w6_rw_val(alias,bytes)}
    case N111Alloca{name,bytes,align}: N111Alloca{name,bytes,align}

@unsafe
def w6_rw_stmts(alias, body):
  match body:
    case Nil{}: []
    case Con{head,rest}: Con{w6_rw_stmt(alias,head),w6_rw_stmts(alias,rest)}

@unsafe
def w6_rw_segs(+alias: KDef, segs: List<&2,N111Segment>, acc: List<&2,N111Segment>) -> List<&2,N111Segment>:
  match segs:
    case Nil{}: nt_reverse(N111Segment,acc,[])
    case Con{N111Segment{name,arity,result,incoming,flags,body},rest}:
      w6_rw_segs(alias,rest,Con{N111Segment{name,arity,result,incoming,flags,w6_rw_stmts(alias,body)},acc})

@unsafe
def w4p_prod_index(fns: List<&2,P113DFunction>, +acc: KDef) -> KDef:
  match fns:
    case Nil{}: acc
    case Con{P113DFunction{+name,+params,+result,public,+body},+rest}:
      nt_choose(KDef,String.starts_with(name,"$product.") &&
          Bool.not(nb_contains(p113j_calls(body),"$direct." ++ String.drop(name,9n))),
        u => w4p_prod_index(rest,p111v_put(acc,name,"W4Prod",nt_count(NC_Binding,params),result)),
        u => w4p_prod_index(rest,acc))

@unsafe
def w7_pre_pass(nodes: List<&2,W7PreNode>, +ready: KDef, +admitted: List<&2,String>, +waiting: List<&2,W7PreNode>, +count: U32) -> W7PrePass:
  match nodes:
    case Nil{}: W7PrePass{ready,admitted,nt_reverse(W7PreNode,waiting,[]),count}
    case Con{+node,+rest}:
      match node:
        case W7PreNode{+name,deps}:
          nt_choose(W7PrePass,w7_pre_deps_ok(deps,ready),
            u => w7_pre_pass(rest,p111v_put(ready,name,"W7Ok",1,0),Con{name,admitted},waiting,U32.inc(count)),
            u => w7_pre_pass(rest,ready,admitted,Con{node,waiting},count))

@unsafe
def p168j_insert(segment: N111Segment, registry: P112RegionRegistry) -> P112RegionRegistry:
  match segment registry:
    case N111Segment{+name,+arity,result,incoming,flags,body} P112RegionRegistry{ready,symbols,entries,workers,fusions}:
      P112RegionRegistry{p111v_put(ready,name,"P112Worker",arity,0),
        p111v_put(symbols,p112w_symbol(name),"P112RegionSymbol",arity,0),entries,U32.inc(workers),fusions}



@unsafe
def p185cb_scanned(ids: N111Ids, +expected: U32, scan: P111VScan) -> N111Ids:
  match ids scan:
    case N111Ids{functions,constructors} P111VScan{metadata,error,+count}:
      N111Ids{functions,p185cb_tree(constructors,String.is_empty(error) && U32.is_gt(count,0) && U32.is_eq(count,expected),metadata)}

@unsafe
def w11_p186ch_take_r1(+stmt: N111Stmt, +dest: String, a0: N111Arg, r1: List<&2,N111Arg>) -> P114TExpansion:
  match r1:
    case Con{a1,r2}: w11_p186ch_take_r2(stmt,dest,a0,a1,r2)
    case _: P114TExpansion{[stmt],False{}}

@unsafe
def w11_p186ch_take(+stmt: N111Stmt, +dest: String, args: List<&2,N111Arg>) -> P114TExpansion:
  match args:
    case Con{a0,r1}: w11_p186ch_take_r1(stmt,dest,a0,r1)
    case _: P114TExpansion{[stmt],False{}}

@unsafe
def p186ch_expand(+stmt: N111Stmt) -> P114TExpansion:
  match stmt:
    case N111Call{+dest,typ,+symbol,args}:
      nt_choose(P114TExpansion,w11_n111_is_u64(typ),
        u => nt_choose(P114TExpansion,agy_str_eq(symbol,"p111_rt_special_take"),
          v => w11_p186ch_take(stmt,dest,args),
          v => nt_choose(P114TExpansion,agy_str_eq(symbol,"p111_rt_special_ctor"),
            w => w11_p186ch_ctor(stmt,dest,args),
            w => P114TExpansion{[stmt],False{}})),
        u => P114TExpansion{[stmt],False{}})
    case _: P114TExpansion{[stmt],False{}}
# A pending continuation frame is distinct from a recursive descent. Preserve
# its exact stores/call, then continue scanning the remaining computation. This
# composes two pushes before a self descent or an already admitted ready call.
# The old successful plan is returned unchanged. New plans still pass through
# p114h_finish/close: at most eight known cases, exact captures and incoming
# result, reserved-name hygiene, and the original scalar/call restrictions.
#
# Each executed PushFrame increments the private depth once. Existing unwind
# pops its FID and captures once in LIFO order. Recursive work stays in the
# explicit runtime stack; this does not introduce recursive machine calls.
# The node stores no region-state variable: case renaming only renames the
# original frame operands, leaving the emitter-owned depth unchanged.

@unsafe
def x181_frame_home(+name: String, +frame: X181Frame) -> X181Frame:
  match frame:
    case X181Frame{+slots,+bytes,calls,params,symbol}:
      nt_choose(X181Frame,agy_str_eq(dk(p111v_get(slots,name)),"Absent"),
        u => X181Frame{p111v_put(slots,name,"X181Stack",x181_frame_align(U32.add(bytes,8),8),8),
          x181_frame_align(U32.add(bytes,8),8),calls,params,symbol},
        u => frame)

@unsafe
def x181_frame_buffer(+name: String, +bytes: U32, alignment: U32,
  +frame: X181Frame) -> X181Frame:
  match frame:
    case X181Frame{+slots,used,calls,params,symbol}:
      +old = p111v_get(slots,name)
      +size = nt_choose(U32,U32.is_eq(bytes,0),u => 1,u => bytes)
      +align = x181_frame_alignment(alignment)
      +end = x181_frame_align(U32.add(used,size),align)
      nt_choose(X181Frame,agy_str_eq(dk(old),"X181Buffer") &&
        U32.is_ge(dx(old),size) && U32.is_eq(U32.mod(da(old),align),0),
        u => frame,
        u => X181Frame{p111v_put(slots,name,"X181Buffer",end,size),end,calls,params,symbol})

# Staging every argument and reserving another word per argument covers both
# register arguments and the stack-argument copy. It is deliberately generous.
@unsafe
def agy_mark_bounded_frame(+symbol: String, body: List<&2,P113DStmt>, frame: X181Frame) -> X181Frame:
  match frame:
    case X181Frame{slots,bytes,calls,params,sym}:
      nt_choose(X181Frame,(String.starts_with(symbol,"p113d_") || String.starts_with(symbol,"p114r_")) &&
          U32.is_le(p113i_size(body),512),
        u => X181Frame{p111v_put(slots,"__agy_ctor_ok","X186SavedMask",1,0),bytes,calls,params,sym},
        u => frame)

# W4-4 Pass 4a: Detect whether "state" is ever referenced in a function body.
@unsafe
def x186_u32_float_text(name: String, buffer: String, ids: N111Ids, +frame: X181Frame) -> X188Seq:
  x188_many([x181_load(N111Local{buffer},ids,frame,x188_reg(10,64)),
    x188_i2("movl",X187Mem{10,0},x188_reg(10,32)),
    x188_i2("pxor",x188_xmm(0),x188_xmm(0)),
    x188_i2("cvtsi2ssq",x188_reg(10,64),x188_xmm(0)),
    x186_float_result(name,frame)])

@unsafe
def x186_u32_float_probe_when(enabled: Bool, stmt: N111Stmt, ids: N111Ids, frame: X181Frame) -> X188Seq:
  match stmt:
    case N111Call{name,N111U64{},symbol,
      Con{N111Arg{N111Ptr{},N111Local{state}},
      Con{N111Arg{N111U32{},N111Const{23,0}},
      Con{N111Arg{N111Ptr{},N111Local{+buffer}},
      Con{N111Arg{N111U32{},N111Const{1,0}},Nil{}}}}}}:
        nt_choose(X188Seq,enabled && agy_str_eq(symbol,"p111_rt_op") && agy_str_eq(state,"state") &&
            Bool.not(agy_str_eq(buffer,"state")),
          u => x186_u32_float_text(name,buffer,ids,frame),u => X188Empty{})
    case _: X188Empty{}

# The independent verifier establishes the foreign primitive ABI before this pass.
# A successful probe carries the pointer to exactly the original argument buffer.
@unsafe
def x198w_probe(op: X198WOp,stmt: N111Stmt,+ids: N111Ids,+frame: X181Frame) -> X188Seq:
  match op:
    case X198WOp{name,buf,id}: x188_many([x181_load(N111Local{buf},ids,frame,x188_reg(10,64)),
      x198w_calc(id),x181_store(name,frame,x188_reg(11,64))])
    case _: x186_u32_float_probe_when(x186_u32_float_enabled(),stmt,ids,frame)

@unsafe
def w4_u32_to_f32(+name: String, +value: N111Value, ids: N111Ids, +frame: X181Frame, +homes: KDef) -> X188Seq:
  +dest = x186_x_home(name,homes)
  +target = x186_float_operand(dest,x188_xmm(0))
  x188_many([w4_u32_to_r10(x186_x_source(value,homes),value,ids,frame),
    x188_i2("pxor",target,target),
    x188_i2("cvtsi2ssq",x188_reg(10,64),target),
    nt_choose(X188Seq,x186_float_present(dest),u => X188Empty{},u => x186_float_publish(name,target,frame))])

@unsafe
def x186_float_load_from(source: Maybe<&2,X187Operand>, value: N111Value,
    ids: N111Ids, frame: X181Frame, xmm: X187Operand) -> X188Seq:
  match source:
    case Some{operand}: x188_i2("movd",operand,xmm)
    case None{}: w2_float_const_load(value,ids,frame,xmm)

@unsafe
def x186_float_load(+value: N111Value, ids: N111Ids, +frame: X181Frame, xmm: X187Operand) -> X188Seq:
  x186_float_load_from(x186_float_source(value,frame),value,ids,frame,xmm)

@unsafe
def x186_float_result(name: String, frame: X181Frame) -> X188Seq:
  x186_float_publish(name,x188_xmm(0),frame)

@unsafe
def x186_float_finish(+name: String, +id: U32, +frame: X181Frame) -> X188Seq:
  nt_choose(X188Seq,U32.is_lt(id,30),
    u => x188_cat(x188_i2(x185_float_arithmetic(id),x188_xmm(1),x188_xmm(0)),x186_float_result(name,frame)),
    u => x188_many([x188_i2("ucomiss",x188_xmm(1),x188_xmm(0)),x185_float_compare(id),
      x188_i2("movzbl",x188_reg(10,8),x188_reg(10,32)),x181_store(name,frame,x188_reg(10,64))]))

@unsafe
def x185_float_text(name: String, id: U32, buffer: String, ids: N111Ids, +frame: X181Frame) -> X188Seq:
  x188_many([x181_load(N111Local{buffer},ids,frame,x188_reg(10,64)),
    x188_i2("movd",X187Mem{10,0},x188_xmm(0)),x188_i2("movd",X187Mem{10,8},x188_xmm(1)),
    x186_float_finish(name,id,frame)])

@unsafe
def x200r_sqrt_buffer(name: String, buffer: String, ids: N111Ids, +frame: X181Frame) -> X188Seq:
  x188_many([x181_load(N111Local{buffer},ids,frame,x188_reg(10,64)),
    x188_i2("movd",X187Mem{10,0},x188_xmm(0)),
    x188_i1("call",X187Target{"p200_rt_f32_sqrt_keep"}),
    x188_i2("movd",x188_xmm(0),x188_reg(10,32)),
    x188_i2("movd",x188_reg(10,32),x188_xmm(0)),
    x186_float_result(name,frame)])

@unsafe
def x186_float_operation(operation: X186InlineOp, +ids: N111Ids, +frame: X181Frame) -> X188Seq:
  match operation:
    case X186InlineF32{+name,+id,+buffer}:
      nt_choose(X188Seq,U32.is_eq(id,36),u => x200r_sqrt_buffer(name,buffer,ids,frame),
        u => nt_choose(X188Seq,x192_float_unary(id),
          v => x192_float_conversion_buffer(name,id,buffer,ids,frame),
          v => x185_float_text(name,id,buffer,ids,frame)))
    case X186InlineNone{}: X188Empty{}
# Specialized native ABI11102 sqrt call. It remains an unknown call to every
# effect, scratch, liveness and XMM analysis; do not add opcode36 to FloatValues.
@unsafe
def x195s_text(name: String, buffer: String, ids: N111Ids, +frame: X181Frame, +site: U32) -> X188Seq:
  x188_many([x181_load(N111Local{buffer},ids,frame,x188_reg(10,64)),
    x188_i2("movd",X187Mem{10,0},x188_xmm(0)),
    x188_i2("sqrtss",x188_xmm(0),x188_xmm(0)),
    x186_float_result(name,frame)])
law x186_call_arguments:
  for +args: List<&2,N111Arg>
  for +ids: N111Ids
  for +frame: X181Frame
  X188Seq

law agy_reuse_walk:
  for +ids: N111Ids
  for stmts: List<&2,P113DStmt>
  List<&2,P113DStmt>

@unsafe
def agy_reuse_take_matched(+ids: N111Ids, +tname: String, +state: String,
    +term: N111Value, +buf: String, +n: U32, +orig_head: P113DStmt, +rest: List<&2,P113DStmt>,
    found: AgyReuseMatch) -> List<&2,P113DStmt>:
  match found:
    case AgyReuseMatch{ok,+ctor,rest2}:
      nt_choose(List<&2,P113DStmt>,ok && Bool.not(String.is_empty(ctor)),
        v => Con{P113DScalar{N111Call{tname,N111U64{},"agy_rt_take_reuse" ++ U32.show(n),
          [N111Arg{N111Ptr{},N111Local{state}},N111Arg{N111U64{},term},
           N111Arg{N111Ptr{},N111Local{buf}},N111Arg{N111U32{},N111CtorId{ctor}}]}},
          agy_reuse_walk(ids,rest2)},
        v => Con{orig_head,agy_reuse_walk(ids,rest)})

@unsafe
def agy_reuse_try_take(+ids: N111Ids, +tname: String, +sym: String, +state: String,
    +term: N111Value, +buf: String, +n: U32, +orig_head: P113DStmt, +rest: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  nt_choose(List<&2,P113DStmt>,Bool.not(agy_reuse_stmts_use(tname,rest)),
    u => agy_reuse_take_matched(ids,tname,state,term,buf,n,orig_head,rest,agy_reuse_find(p185cc_class(n),tname,ids,rest)),
    u => Con{orig_head,agy_reuse_walk(ids,rest)})

@unsafe
def agy_reuse_walk(ids,stmts):
  match stmts:
    case Nil{}: []
    case Con{+head,+rest}:
      match head:
        case P113DScalar{N111Call{+tname,N111U64{},+sym,Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111U64{},+term},Con{N111Arg{N111Ptr{},N111Local{+buf}},Nil{}}}}}}:
          +n = agy_rt_take_arity(sym)
          nt_choose(List<&2,P113DStmt>,U32.is_gt(n,0) && agy_str_eq(state,"state"),
            u => agy_reuse_try_take(ids,tname,sym,state,term,buf,n,head,rest),
            u => Con{head,agy_reuse_walk(ids,rest)})
        case P113DIf{cond,yes,no}:
          Con{P113DIf{cond,agy_reuse_walk(ids,yes),agy_reuse_walk(ids,no)},agy_reuse_walk(ids,rest)}
        case _:
          Con{head,agy_reuse_walk(ids,rest)}

@unsafe
def agy_reuse_body(+symbol: String, +ids: N111Ids, +body: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  nt_choose(List<&2,P113DStmt>,agy_reuse_enabled() &&
      (String.starts_with(symbol,"p113d_") || String.starts_with(symbol,"p114r_")) &&
      U32.is_le(p113i_size(body),256),
    u => agy_reuse_walk(ids,body),
    u => body)

law agy_call_schedule:
  for +moves: List<&2,AgyCallMove>
  for +ids: N111Ids
  for +frame: X181Frame
  for +fuel: U32
  X188Seq

@unsafe
def agy_call_step(picked: AgyCallPick, +moves: List<&2,AgyCallMove>, +ids: N111Ids, +frame: X181Frame, +fuel: U32) -> X188Seq:
  match picked:
    case AgyCallPick{chosen,rest}:
      x188_cat(agy_call_emit_move(chosen,ids,frame),agy_call_schedule(rest,ids,frame,fuel))
    case AgyCallPickNone{}:
      match moves:
        case Con{AgyCallMove{dstIdx,+dstReg,srcReg,typ,value},rest}:
          x188_cat(x188_i2("movq",x188_reg(dstReg,64),x188_reg(10,64)),
            agy_call_schedule(agy_call_rewrite_src(moves,dstReg,10),ids,frame,fuel))
        case Nil{}: X188Empty{}

@unsafe
def agy_call_schedule(moves,ids,frame,fuel):
  match moves:
    case Nil{}: X188Empty{}
    case Con{head,rest}:
      nt_choose(X188Seq,U32.is_gt(fuel,0),
        u => agy_call_step(agy_call_pick_ready(moves,moves),moves,ids,frame,U32.sub(fuel,1)),
        u => x188_error("agy: call arg schedule overflow"))

@unsafe
def agy_call_parallel(+args: List<&2,N111Arg>, +ids: N111Ids, +frame: X181Frame) -> X188Seq:
  match frame:
    case X181Frame{slots,bytes,calls,params,symbol}:
      x188_cat(agy_call_stack_args(args,ids,frame,0),
        agy_call_schedule(agy_call_reg_moves(args,slots,0),ids,frame,16))

@unsafe
def x186_call_selected(+enabled: Bool, +args: List<&2,N111Arg>, +ids: N111Ids,
    +frame: X181Frame, plan: X186CallPlan) -> X188Seq:
  match plan:
    case X186CallPlan{+kind,+count}:
      nt_choose(X188Seq,U32.is_eq(kind,0),u => x188_error("x186: invalid call argument frame"),u =>
        nt_choose(X188Seq,enabled && U32.is_eq(kind,1),u => x186_call_direct(args,ids,frame,0),
          u => nt_choose(X188Seq,enabled && U32.is_eq(kind,2),
            v => agy_call_parallel(args,ids,frame),
            v => x188_cat(x186_call_snapshot(args,ids,frame,U32.mul(count,8),0),
              x186_call_place(count,U32.mul(count,8),0)))))

@unsafe
def x186_call_arguments(args,ids,frame):
  x186_call_selected(x186_call_arguments_enabled(),args,ids,frame,x186_call_plan(args,frame))
# Scalar selection reserves r10/r11/rax/rcx as scratch. Frame variables have
# 64-bit homes; each U32 producer clears the upper half before publication.
# Typed instructions are the shared product of selection; text is a renderer.

@unsafe
def x185_load_memory(+name: String, +typ: N111Type, +base: N111Value, +offset: U32,
    +ids: N111Ids, +frame: X181Frame) -> X188Seq:
  x188_cat(nt_choose(X188Seq,x185_machine_enabled() && U32.is_le(offset,2147483647),u =>
    x188_cat(x181_load(base,ids,frame,x188_reg(10,64)),x188_i2(x181_width(typ,"movq","movl"),X187Mem{10,offset},x188_width_reg(typ,10))),u =>
    x188_cat(x181_address(base,offset,ids,frame),x188_i2(x181_width(typ,"movq","movl"),X187Mem{10,0},x188_width_reg(typ,10)))),
    x181_store(name,frame,x188_reg(10,64)))

@unsafe
def x185_store_memory(+typ: N111Type, +base: N111Value, +offset: U32, +value: N111Value,
    +ids: N111Ids, +frame: X181Frame) -> X188Seq:
  nt_choose(X188Seq,x185_machine_enabled() && U32.is_le(offset,2147483647),u =>
    x188_many([x181_load(base,ids,frame,x188_reg(10,64)),x181_load(value,ids,frame,x188_reg(11,64)),
      x188_i2(x181_width(typ,"movq","movl"),x188_width_reg(typ,11),X187Mem{10,offset})]),u =>
    x188_many([x181_address(base,offset,ids,frame),x181_load(value,ids,frame,x188_reg(11,64)),
      x188_i2(x181_width(typ,"movq","movl"),x188_width_reg(typ,11),X187Mem{10,0})]))
@unsafe
def x185_late_borrow(+stmt: N111Stmt, +ids: N111Ids, +site: U32, +mask: U32, read: P128BFRead) -> List<&2,N111Stmt>:
  match read:
    case P128BFRead{dest,term,buffer,ctor,count}:
      nt_append(N111Stmt,p128bf_guard(term,ctor,site),
        [N111If{p114t_local(site,"borrow_guard"),p128bf_fast(dest,buffer,count,site,mask),[stmt]}])
    case _: x185_late_previous(stmt,ids,site,p126nt_expand(stmt,site))

@unsafe
def w5_late_succ(+stmt: N111Stmt, +ids: N111Ids, +site: U32, +bfMask: U32, expansion: P114TExpansion) -> List<&2,N111Stmt>:
  match expansion:
    case P114TExpansion{body,changed}:
      nt_choose(List<&2,N111Stmt>,changed,u => x185_late_accessors(body),u =>
        x186_late_registers(stmt,ids,site,bfMask,nt_choose(P114TExpansion,x186_transport_enabled(),
          v => p186rt_expand(stmt,ids,site),v => P114TExpansion{[stmt],False{}})))

@unsafe
def x186_late_char(+stmt: N111Stmt, +ids: N111Ids, +site: U32, +bfMask: U32, expansion: P114TExpansion) -> List<&2,N111Stmt>:
  match expansion:
    case P114TExpansion{body,changed}:
      nt_choose(List<&2,N111Stmt>,changed,u => x185_late_accessors(body),u =>
        w5_late_succ(stmt,ids,site,bfMask,w5_succ_expand(stmt,site)))

@unsafe
def x186_late_registers(+stmt: N111Stmt, +ids: N111Ids, +site: U32, +bfMask: U32, expansion: P114TExpansion) -> List<&2,N111Stmt>:
  match expansion:
    case P114TExpansion{body,changed}:
      nt_choose(List<&2,N111Stmt>,changed,u => x185_late_accessors(body),
        u => x185_late_borrow(stmt,ids,site,bfMask,p128bf_match(stmt,ids,site)))

# W5B-R3 Pass 4: Sink N111Store into P111_SPECIAL_SUCC overflow slow-path
@unsafe
def w5b_reads_rec_go(fresh: Bool, +name: String, +counts: KDef, +reversedNames: List<&2,String>, +h: U32, +old: KDef) -> X181ReadCounts:
  match fresh:
    case True{}:
      X181ReadCounts{
        index_set(counts,KDef{name,"X181Reads",1,0,atom("Absent"),atom("Absent"),[],False{},False{}},h,32),
        Con{name,reversedNames}}
    case False{}:
      X181ReadCounts{
        index_set(counts,KDef{name,"X181Reads",x181_read_increment(da(old)),0,atom("Absent"),atom("Absent"),[],False{},False{}},h,32),
        reversedNames}

@unsafe
def x181_register_install(+name: String, register: U32, frame: X181Frame) -> X181Frame:
  match frame:
    case X181Frame{+slots,bytes,calls,params,symbol}:
      X181Frame{index_set(slots,x181_register_slot(p111v_get(slots,name),register),
        index_hash(name,2166136261),32),bytes,calls,params,symbol}

@unsafe
def x190_register_scores(names: List<&2,String>, +writes: KDef,
    +params: List<&2,String>, +policy: U32, +counts: KDef) -> KDef:
  match names:
    case Nil{}: counts
    case Con{+name,rest}:
      +h = index_hash(name,2166136261)
      x190_register_scores(rest,writes,params,policy,
        index_set(counts,KDef{name,"X181Reads",x190_register_score(da(index_find(counts,name,h,32)),
          nb_contains(params,name) || U32.is_eq(da(index_find(writes,name,h,32)),0),policy),0,
          atom("Absent"),atom("Absent"),[],False{},False{}},h,32))

@unsafe
def w5b_copy_write_go(sat: Bool, +cur: U32, +name: String, +counts: KDef, +h: U32) -> KDef:
  match sat:
    case True{}: counts
    case False{}:
      index_set(counts,KDef{name,"X185Writes",U32.inc(cur),0,
        atom("Absent"),atom("Absent"),[],False{},False{}},h,32)

@unsafe
def x185_copy_record(+name: String, +typ: N111Type, +source: String, +counts: KDef,
    +params: List<&2,String>, +aliases: KDef) -> KDef:
  nt_choose(KDef,Bool.not(U32.is_eq(p111v_type(typ),1)) && Bool.not(agy_str_eq(name,source)) &&
      Bool.not(nb_contains(params,name)) && U32.is_eq(da(p111v_get(counts,name)),1) &&
      U32.is_eq(da(p111v_get(counts,source)),1),
    u => index_set(aliases,KDef{name,"X185Alias",0,0,atom("Absent"),
      kt("X185Local",x185_copy_name(source,aliases),0,0,[]),[],False{},False{}},index_hash(name,2166136261),32),
    u => aliases)

@unsafe
def x185_copy_values(values: List<&2,N111Value>, +aliases: KDef) -> List<&2,N111Value>:
  match values:
    case Nil{}: []
    case Con{head,rest}: Con{x185_copy_value(head,aliases),x185_copy_values(rest,aliases)}

@unsafe
def x185_copy_args(args: List<&2,N111Arg>, +aliases: KDef) -> List<&2,N111Arg>:
  match args:
    case Nil{}: []
    case Con{N111Arg{typ,value},rest}: Con{N111Arg{typ,x185_copy_value(value,aliases)},x185_copy_args(rest,aliases)}

@unsafe
def x185_copy_scalar(stmt: N111Stmt, +aliases: KDef) -> List<&2,N111Stmt>:
  match stmt:
    case N111Set{+name,typ,value}:
      nt_choose(List<&2,N111Stmt>,agy_str_eq(dk(p111v_get(aliases,name)),"X185Alias"),u => [],
        u => [N111Set{name,typ,x185_copy_value(value,aliases)}])
    case N111Bin{name,typ,op,left,right}: [N111Bin{name,typ,op,x185_copy_value(left,aliases),x185_copy_value(right,aliases)}]
    case N111Call{name,typ,symbol,args}: [N111Call{name,typ,symbol,x185_copy_args(args,aliases)}]
    case N111If{condition,yes,no}: [N111If{x185_copy_value(condition,aliases),x185_copy_scalars(yes,aliases),x185_copy_scalars(no,aliases)}]
    case N111Return{value}: [N111Return{x185_copy_value(value,aliases)}]
    case N111Load{name,typ,base,offset}: [N111Load{name,typ,x185_copy_value(base,aliases),offset}]
    case N111Store{typ,base,offset,value}: [N111Store{typ,x185_copy_value(base,aliases),offset,x185_copy_value(value,aliases)}]
    case N111Offset{name,base,bytes}: [N111Offset{name,x185_copy_value(base,aliases),x185_copy_value(bytes,aliases)}]
    case N111Alloca{name,bytes,align}: [N111Alloca{name,bytes,align}]

@unsafe
def x185_copy_scalars(body: List<&2,N111Stmt>, +aliases: KDef) -> List<&2,N111Stmt>:
  match body:
    case Nil{}: []
    case Con{head,rest}: nt_append(N111Stmt,x185_copy_scalar(head,aliases),x185_copy_scalars(rest,aliases))

@unsafe
def x185_copy_body(body: List<&2,P113DStmt>, +aliases: KDef) -> List<&2,P113DStmt>:
  match body:
    case Nil{}: []
    case Con{P113DScalar{stmt},rest}: nt_append(P113DStmt,x181_scalar_rows(x185_copy_scalar(stmt,aliases)),x185_copy_body(rest,aliases))
    case Con{P113DIf{condition,yes,no},rest}:
      Con{P113DIf{x185_copy_value(condition,aliases),x185_copy_body(yes,aliases),x185_copy_body(no,aliases)},x185_copy_body(rest,aliases)}
    case Con{P113DCall{destinations,target,args},rest}:
      Con{P113DCall{destinations,target,x185_copy_values(args,aliases)},x185_copy_body(rest,aliases)}
    case Con{P113DResult{values},rest}: Con{P113DResult{x185_copy_values(values,aliases)},x185_copy_body(rest,aliases)}
    case Con{P113DAgain{values},rest}: Con{P113DAgain{x185_copy_values(values,aliases)},x185_copy_body(rest,aliases)}

@unsafe
def agy_x185_copy_apply(+body: List<&2,P113DStmt>, +aliases: KDef) -> List<&2,P113DStmt>:
  nt_choose(List<&2,P113DStmt>,p88_string_eq(dk(aliases),"Absent"),u => body,u => x185_copy_body(body,aliases))

@unsafe
def x185_t_range(+name: String, first: U32, last: U32, region: U32, ranges: KDef) -> KDef:
  index_set(ranges,KDef{name,"X185TRange",first,last,kt("X185TRegion","",region,0,[]),
    atom("Absent"),[],False{},False{}},index_hash(name,2166136261),32)

@unsafe
def x185_t_forbid(name: String, scan: X185TScan) -> X185TScan:
  match scan:
    case X185TScan{ranges,names,position,region}:
      X185TScan{p111v_put(ranges,name,"X185TBlocked",0,0),names,position,region}

@unsafe
def x185_t_install(+name: String, register: U32, frame: X181Frame) -> X181Frame:
  match frame:
    case X181Frame{+slots,bytes,calls,params,symbol}:
      X181Frame{index_set(slots,x185_t_slot(p111v_get(slots,name),register),
        index_hash(name,2166136261),32),bytes,calls,params,symbol}

@unsafe
def w5b_d_ins_if(live: Bool, +hash: U32, head: KDef, out: KDef) -> KDef:
  match live:
    case True{}: p131i_insert(out,head,hash)
    case False{}: out

@unsafe
def w5b_d_union_bkt(+hash: U32, bucket: List<&2,KDef>, out: KDef) -> KDef:
  match bucket:
    case Nil{}: out
    case Con{+head,rest}:
      w5b_d_union_bkt(hash,rest,w5b_d_ins_if(U32.is_gt(da(head),0),hash,head,out))

@unsafe
def x194_cr_direct(+typ: N111Type, +op: String, +left: N111Value,
    +ids: N111Ids, +frame: X181Frame, +wide: X187Operand,
    +narrow: X187Operand, +byte: X187Operand, +right: X185Physical) -> X188Seq:
  nt_choose(X188Seq,x194_cr_applicable(typ,op,wide,right),
    u => x194_cr_attempt(typ,op,left,ids,frame,wide,narrow,byte,right),
    u => x194_cr_previous(typ,op,left,ids,frame,wide,narrow,byte,right))

@unsafe
def x194_cr_attempt(+typ: N111Type, +op: String, +left: N111Value,
    +ids: N111Ids, +frame: X181Frame, +wide: X187Operand,
    +narrow: X187Operand, +byte: X187Operand, +right: X185Physical) -> X188Seq:
  +commuted = x194_cr_select(typ,op,wide,narrow,byte,right,x190_value_home(left,frame))
  nt_choose(X188Seq,x188_empty(commuted),
    u => x194_cr_previous(typ,op,left,ids,frame,wide,narrow,byte,right),u => commuted)

# Exact previous direct-operand selection, retained as the refusal path.
@unsafe
def x194_cr_previous(+typ: N111Type, +op: String, +left: N111Value,
    +ids: N111Ids, +frame: X181Frame, +wide: X187Operand,
    narrow: X187Operand, byte: X187Operand, right: X185Physical) -> X188Seq:
  match right:
    case X185Physical{+rw,rn,rb}:
      nt_choose(X188Seq,Bool.not(x181_shift(op)) &&
          (Bool.not(x188_operand_same(rw,wide)) || x185_physical_source(left,frame,wide)),u =>
        x188_cat(x185_physical_load(left,ids,frame,wide),
          x190_operand_instruction(typ,op,wide,narrow,byte,x188_physical_width(typ,rw,rn))),u => X188Empty{})
    case _: X188Empty{}
# Local stack-cell forwarding only. Stores and allocas remain in place. A fact
# dies on source reassignment, overlapping storage, any unknown-address store,
# call, branch or terminal edge. Thus copied/escaped pointers cannot silently
# mutate a remembered cell. No fact is carried around Again or out of setup.
law x185_sf_body:
  for body: List<&2,P113DStmt>
  for +buffers: KDef
  for facts: List<&2,X185ScratchCell>
  List<&2,P113DStmt>

@unsafe
def x185_sf_after(rest: List<&2,P113DStmt>, buffers: KDef, step: X185ScratchStep) -> List<&2,P113DStmt>:
  match step:
    case X185ScratchStep{stmt,facts}: Con{stmt,x185_sf_body(rest,buffers,facts)}

@unsafe
def x185_sf_if(condition: N111Value, yes: List<&2,P113DStmt>, no: List<&2,P113DStmt>,
    rest: List<&2,P113DStmt>, +buffers: KDef) -> List<&2,P113DStmt>:
  Con{P113DIf{condition,x185_sf_body(yes,buffers,[]),x185_sf_body(no,buffers,[])},x185_sf_body(rest,buffers,[])}

@unsafe
def x198w_step(replacement: Maybe<&2,N111Stmt>,stmt: N111Stmt,buffers: KDef,facts: List<&2,X185ScratchCell>) -> X185ScratchStep:
  match replacement:
    case Some{repl}: x185_sf_scalar(repl,buffers,facts)
    case _: x185_sf_scalar(stmt,buffers,facts)

@unsafe
def x198w_fact(+stmt: N111Stmt,+buffers: KDef,+facts: List<&2,X185ScratchCell>) -> X185ScratchStep:
  match stmt:
    case N111Call{name,ty,symbol,args}:
      x198w_step(x198w_known(x198w_op(stmt),facts),stmt,buffers,facts)
    case _: x185_sf_scalar(stmt,buffers,facts)

@unsafe
def x185_sf_body(body,buffers,facts):
  match body:
    case Nil{}: []
    case Con{P113DScalar{N111If{condition,yes,no}},rest}:
      x185_sf_if(condition,x181_scalar_rows(yes),x181_scalar_rows(no),rest,buffers)
    case Con{P113DIf{condition,yes,no},rest}: x185_sf_if(condition,yes,no,rest,buffers)
    case Con{P113DScalar{stmt},rest}: x185_sf_after(rest,buffers,x198w_fact(stmt,buffers,facts))
    case Con{head,rest}: Con{head,x185_sf_body(rest,buffers,[])}


@unsafe
def x186_m_dead_cell(+name: String, +offset: U32, +typ: N111Type, scan: X186Memory) -> Bool:
  match scan:
    case X186Memory{buffers,+reads,used}:
      x186_m_cell(name,offset,typ,buffers) && U32.is_eq(da(p111v_get(reads,x186_m_key(name,offset))),0) &&
        (U32.is_eq(x185_sf_width(typ),4) || U32.is_eq(da(p111v_get(reads,x186_m_key(name,U32.add(offset,4)))),0))

law x186_m_body:
  for body: List<&2,P113DStmt>
  for +scan: X186Memory
  List<&2,P113DStmt>

@unsafe
def x186_m_body(body,scan):
  match body:
    case Nil{}: []
    case Con{P113DScalar{N111Store{+typ,N111Local{+buffer},+offset,+value}},+rest}:
      nt_choose(List<&2,P113DStmt>,x186_m_dead_cell(buffer,offset,typ,scan),
        u => x186_m_body(rest,scan),
        u => Con{P113DScalar{N111Store{typ,N111Local{buffer},offset,value}},x186_m_body(rest,scan)})
    case Con{P113DScalar{N111Alloca{+name,+bytes,+align}},+rest}:
      nt_choose(List<&2,P113DStmt>,x186_m_dead_buffer(name,scan),u => x186_m_body(rest,scan),
        u => Con{P113DScalar{N111Alloca{name,bytes,align}},x186_m_body(rest,scan)})
    case Con{P113DScalar{N111If{condition,yes,no}},rest}:
      Con{P113DIf{condition,x186_m_body(x181_scalar_rows(yes),scan),x186_m_body(x181_scalar_rows(no),scan)},x186_m_body(rest,scan)}
    case Con{P113DIf{condition,yes,no},rest}:
      Con{P113DIf{condition,x186_m_body(yes,scan),x186_m_body(no,scan)},x186_m_body(rest,scan)}
    case Con{head,rest}: Con{head,x186_m_body(rest,scan)}

law x186_p_schedule:
  for +moves: List<&2,X186Move>
  for +ids: N111Ids
  for +frame: X181Frame
  for chunks: List<&2,X188Seq>
  for +fuel: U32
  Maybe<&2,X188Seq>

@unsafe
def x186_p_chosen(picked: X186Pick, +ids: N111Ids, +frame: X181Frame,
    chunks: List<&2,X188Seq>, fuel: U32) -> Maybe<&2,X188Seq>:
  match picked:
    case X186Pick{X186Move{destination,source,home,read},rest}:
      x186_p_schedule(rest,ids,frame,Con{x190_move(destination,source,ids,frame),chunks},fuel)
    case _: None{}

@unsafe
def x186_p_schedule(moves,ids,frame,chunks,fuel):
  match moves:
    case Nil{}: Some{x188_finish(chunks)}
    case Con{head,rest}:
      nt_choose(Maybe<&2,X188Seq>,U32.is_gt(fuel,0),
        u => x186_p_chosen(x186_p_pick(moves,moves),ids,frame,chunks,U32.sub(fuel,1)),u => None{})

@unsafe
def x186_p_ready(plan: Maybe<&2,List<&2,X186Move>>, ids: N111Ids, frame: X181Frame) -> Maybe<&2,X188Seq>:
  match plan:
    case Some{moves}: x186_p_schedule(x186_p_self(moves),ids,frame,[],64)
    case _: None{}

@unsafe
def x186_parallel(+params: List<&2,String>, +values: List<&2,N111Value>, +ids: N111Ids, +frame: X181Frame) -> Maybe<&2,X188Seq>:
  match frame:
    case X181Frame{slots,bytes,calls,words,symbol}:
      nt_choose(Maybe<&2,X188Seq>,x186_parallel_enabled() && U32.is_le(nt_count(String,params),64) &&
          U32.is_le(nt_count(N111Value,values),64),
        u => x186_p_ready(x186_p_zip(params,values,slots,[]),ids,frame),u => None{})
# Select copies and loads directly into an assigned machine home. A memory
# source's address defaults to a reserved r10 snapshot before its destination changes.
# Every U32 publication still clears high bits. Stack destinations retain the
# old sequence; these rules neither remove memory accesses nor alter lifetimes.
@unsafe
def x186_set_selected(+name: String, +typ: N111Type, +value: N111Value,
    +ids: N111Ids, +frame: X181Frame, physical: X185Physical) -> X188Seq:
  match physical:
    case X185Physical{+wide,+narrow,byte}:
      +direct = nt_choose(X188Seq,x190_operands_enabled() && U32.is_eq(p111v_type(typ),1),
        u => x190_narrow_value(value,frame,narrow),u => X188Empty{})
      nt_choose(X188Seq,x188_empty(direct),
        u => x188_cat(x185_physical_load(value,ids,frame,wide),x181_mask(typ,narrow)),u => direct)
    case X185PhysicalNone{}:
      x188_many([x181_load(value,ids,frame,x188_reg(10,64)),x181_mask(typ,x188_reg(10,32)),x181_store(name,frame,x188_reg(10,64))])

@unsafe
def x186_set_text(+name: String, typ: N111Type, value: N111Value, ids: N111Ids, +frame: X181Frame) -> X188Seq:
  x186_set_selected(name,typ,value,ids,frame,x185_physical_home(name,frame))

@unsafe
def x186_load_selected(+name: String, +typ: N111Type, +base: N111Value, +offset: U32,
    +ids: N111Ids, +frame: X181Frame, physical: X185Physical) -> X188Seq:
  match physical:
    case X185Physical{+wide,+narrow,byte}:
      +direct = nt_choose(X188Seq,x190_operands_enabled() && U32.is_le(offset,2147483647),
        u => x190_load_direct(typ,offset,x188_physical_width(typ,wide,narrow),x190_value_home(base,frame)),u => X188Empty{})
      nt_choose(X188Seq,Bool.not(x188_empty(direct)),u => direct,u =>
      nt_choose(X188Seq,U32.is_le(offset,2147483647),u =>
        x188_cat(x181_load(base,ids,frame,x188_reg(10,64)),
          x188_i2(x181_width(typ,"movq","movl"),X187Mem{10,offset},x188_physical_width(typ,wide,narrow))),u =>
        x188_cat(x181_address(base,offset,ids,frame),
          x188_i2(x181_width(typ,"movq","movl"),X187Mem{10,0},x188_physical_width(typ,wide,narrow)))))
    case X185PhysicalNone{}: x185_load_memory(name,typ,base,offset,ids,frame)

@unsafe
def x186_load_text(+name: String, typ: N111Type, base: N111Value, offset: U32,
    ids: N111Ids, +frame: X181Frame) -> X188Seq:
  x186_load_selected(name,typ,base,offset,ids,frame,x185_physical_home(name,frame))

# Address evaluation precedes destination publication even when base=destination.
@unsafe
def x190_store_memory(+typ: N111Type, +base: N111Value, +offset: U32, +value: N111Value,
    +ids: N111Ids, +frame: X181Frame) -> X188Seq:
  +direct = nt_choose(X188Seq,x190_operands_enabled() && U32.is_le(offset,2147483647),
    u => x190_store_direct(typ,offset,x190_value_home(base,frame),x190_value_home(value,frame)),u => X188Empty{})
  nt_choose(X188Seq,x188_empty(direct),u => x185_store_memory(typ,base,offset,value,ids,frame),u => direct)

# The parallel-copy scheduler has already established this move's order. Its
# values are full 64-bit words; cycle snapshots still use the original plan.
@unsafe
def x190_move(+name: String, +value: N111Value, +ids: N111Ids, +frame: X181Frame) -> X188Seq:
  x190_move_selected(name,value,ids,frame,nt_choose(X185Physical,x190_operands_enabled(),
    u => x190_value_home(value,frame),u => X185PhysicalNone{}))

@unsafe
def w5b_m_add_if(has: Bool, +m: KDef, +name: String, +h: U32) -> KDef:
  match has:
    case True{}: m
    case False{}: p131i_insert(m,KDef{name,"X186M",0,0,atom("Absent"),atom("Absent"),[],False{},False{}},h)

@unsafe
def w4c_e_kill_cond(+v: N111Value, +state: X186ExprState) -> X186ExprState:
  match state:
    case X186ExprState{_,_,_,_,_,_,at}:
      w4c_e_kill_val(x186_e_value_t(v,at),w4c_e_kill_val(v,state))

@unsafe
def w4c_dia_nonlast_ok(body: List<&2,P113DStmt>, +dst: String, +forb: KDef) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{_,Nil{}}: True{}
    case Con{P113DScalar{sc},rest}:
      +n = w4c_dia_nonlast_name(sc)
      Bool.not(String.is_empty(n)) && Bool.not(agy_str_eq(n,dst)) &&
        Bool.not(w4c_dia_has(forb,n)) && w4c_dia_nonlast_ok(rest,dst,forb)
    case Con{P113DIf{c,y,n},rest}:
      w5_sel_nonlast_ok(w5_as_sel(c,y,n),dst,forb) && w4c_dia_nonlast_ok(rest,dst,forb)
    case _: False{}

@unsafe
def w5_dia_collapse_pair(+h1: P113DStmt, +h2: P113DStmt, s1: W5SnapSet, +afterLive: KDef) -> List<&2,P113DStmt>:
  match s1:
    case W5Snap{t,_,v}: w5_dia_collapse_pair2(h1,h2,t,v,w5_as_snap(h2),afterLive)
    case W5SnapNone{}: [h1,h2]

@unsafe
def w5_dia_collapse_arm(arm: List<&2,P113DStmt>, +afterLive: KDef) -> List<&2,P113DStmt>:
  match arm:
    case Nil{}: []
    case Con{+h1,Con{+h2,Nil{}}}: w5_dia_collapse_pair(h1,h2,w5_as_snap(h1),afterLive)
    case Con{h,rest}: Con{h,w5_dia_collapse_arm(rest,afterLive)}

@unsafe
def w5b_put_name(+name: String, +m: KDef) -> KDef:
  p111v_put(m,name,"W5B",U32.inc(da(p111v_get(m,name))),0)

@unsafe
def x186_f_scalar(+stmt: N111Stmt, buffers: KDef, +facts: List<&2,X185ScratchCell>) -> X186FloatStep:
  X186FloatStep{x186_f_operation(stmt,facts,x186_inline_op(stmt)),x186_f_facts(x185_sf_scalar(stmt,buffers,facts))}

law x186_f_plan:
  for body: List<&2,P113DStmt>
  for +buffers: KDef
  for facts: List<&2,X185ScratchCell>
  List<&2,X186FloatNode>

@unsafe
def x186_f_after(rest: List<&2,P113DStmt>, buffers: KDef, step: X186FloatStep) -> List<&2,X186FloatNode>:
  match step:
    case X186FloatStep{node,facts}: Con{node,x186_f_plan(rest,buffers,facts)}

@unsafe
def x186_f_branch(condition: N111Value, yes: List<&2,P113DStmt>, no: List<&2,P113DStmt>,
    rest: List<&2,P113DStmt>, +buffers: KDef) -> List<&2,X186FloatNode>:
  Con{X186FloatBranch{condition,x186_f_plan(yes,buffers,[]),x186_f_plan(no,buffers,[])},x186_f_plan(rest,buffers,[])}

@unsafe
def x186_f_plan(body,buffers,facts):
  match body:
    case Nil{}: []
    case Con{P113DScalar{N111If{condition,yes,no}},rest}:
      x186_f_branch(condition,x181_scalar_rows(yes),x181_scalar_rows(no),rest,buffers)
    case Con{P113DIf{condition,yes,no},rest}: x186_f_branch(condition,yes,no,rest,buffers)
    case Con{P113DScalar{stmt},rest}: x186_f_after(rest,buffers,x186_f_scalar(stmt,buffers,facts))
    case Con{head,rest}: Con{X186FloatPlain{head},x186_f_plan(rest,buffers,[])}

# Metadata only: a binary node has exactly the same local reads and single
# destination write, at one inclusive endpoint. Its integer result has NO
# relationship to F32. These rows are consumed only by frame/read-score/range
# collection, or by the address-escape/read-footprint scan below. They must
# never be emitted, value-folded, copied, or fed to an optimizer.
law x186_f_prune:
  for nodes: List<&2,X186FloatNode>
  for +scan: X186Memory
  List<&2,X186FloatNode>

@unsafe
def x186_f_prune(nodes,scan):
  match nodes:
    case Nil{}: []
    case Con{X186FloatPlain{P113DScalar{N111Store{+typ,N111Local{+buffer},+offset,+value}}},+rest}:
      nt_choose(List<&2,X186FloatNode>,x186_m_dead_cell(buffer,offset,typ,scan),u => x186_f_prune(rest,scan),
        u => Con{X186FloatPlain{P113DScalar{N111Store{typ,N111Local{buffer},offset,value}}},x186_f_prune(rest,scan)})
    case Con{X186FloatPlain{P113DScalar{N111Alloca{+name,+bytes,+align}}},+rest}:
      nt_choose(List<&2,X186FloatNode>,x186_m_dead_buffer(name,scan),u => x186_f_prune(rest,scan),
        u => Con{X186FloatPlain{P113DScalar{N111Alloca{name,bytes,align}}},x186_f_prune(rest,scan)})
    case Con{X186FloatBranch{condition,yes,no},rest}:
      Con{X186FloatBranch{condition,x186_f_prune(yes,scan),x186_f_prune(no,scan)},x186_f_prune(rest,scan)}
    case Con{head,rest}: Con{head,x186_f_prune(rest,scan)}

@unsafe
def x186_x_load_from(source: Maybe<&2,X187Operand>, value: N111Value, ids: N111Ids,
    frame: X181Frame, target: X187Operand) -> X188Seq:
  match source:
    case Some{operand}: x186_x_move(operand,target)
    case None{}: x186_float_load(value,ids,frame,target)

@unsafe
def x186_x_load(+value: N111Value, ids: N111Ids, frame: X181Frame, homes: KDef, target: X187Operand) -> X188Seq:
  x186_x_load_from(x186_x_source(value,homes),value,ids,frame,target)

@unsafe
def x186_x_publish_to(destination: Maybe<&2,X187Operand>, name: String, source: X187Operand, frame: X181Frame) -> X188Seq:
  match destination:
    case Some{operand}: x186_x_move(source,operand)
    case None{}: x186_float_publish(name,source,frame)

@unsafe
def x186_x_publish(+name: String, source: X187Operand, frame: X181Frame, homes: KDef) -> X188Seq:
  x186_x_publish_to(x186_x_home(name,homes),name,source,frame)

@unsafe
def w2_int_branch_code(+typ: N111Type, op: String, +left: N111Value, +right: N111Value,
    label: U32, +ids: N111Ids, +frame: X181Frame) -> X188Seq:
  +lh = w2_phys_val(left,frame)
  +dst = w2_phys_dst(lh,typ)
  +load_l = w2_phys_load(lh,left,ids,frame)
  +imm = w12_int_cmp_imm(typ,right,dst,ids)
  x188_many([load_l,
    nt_choose(X188Seq,x188_empty(imm),
      u => x188_cat(x181_load(right,ids,frame,x188_reg(11,64)),
             x188_i2(x181_width(typ,"cmpq","cmpl"),x188_width_reg(typ,11),dst)),
      u => imm),
    x188_i1(w2_int_inv(op),X187Target{x181_label(label,frame)})])

@unsafe
def w12_bool_fast_prefix(+word: N111Value, +invert: Bool, +l_no: U32, +l_yes: U32, +ids: N111Ids, +frame: X181Frame) -> X188Seq:
  +lh = w2_phys_val(word,frame)
  +reg = w2_phys_dst(lh,N111U64{})
  +load_w = w2_phys_load(lh,word,ids,frame)
  +expected = w2b_bool_cid_imm(ids)
  nt_choose(X188Seq,invert,
    u => x188_many([
      load_w,
      x188_i2("testq",reg,reg),
      x188_i1("jz",X187Target{x181_label(l_yes,frame)}),
      x188_i2("cmpq",X187Imm{1,0},reg),
      x188_i1("je",X187Target{x181_label(l_no,frame)}),
      x188_i2("movq",reg,x188_reg(10,64)),
      x188_i2("shrq",X187Imm{40,0},x188_reg(10,64)),
      x188_i2("andl",X187Imm{8388607,0},x188_reg(10,32)),
      x188_i2("cmpl",X187Imm{expected,0},x188_reg(10,32)),
      x188_i1("je",X187Target{x181_label(l_no,frame)}),
      x188_label(x181_label(l_yes,frame))]),
    u => x188_many([
      load_w,
      x188_i2("testq",reg,reg),
      x188_i1("jz",X187Target{x181_label(l_no,frame)}),
      x188_i2("cmpq",X187Imm{1,0},reg),
      x188_i1("je",X187Target{x181_label(l_yes,frame)}),
      x188_i2("movq",reg,x188_reg(10,64)),
      x188_i2("shrq",X187Imm{40,0},x188_reg(10,64)),
      x188_i2("andl",X187Imm{8388607,0},x188_reg(10,32)),
      x188_i2("cmpl",X187Imm{expected,0},x188_reg(10,32)),
      x188_i1("jne",X187Target{x181_label(l_no,frame)}),
      x188_label(x181_label(l_yes,frame))]))

@unsafe
def w2b_bool_fast_prefix(+word: N111Value, +l_no: U32, +l_yes: U32, +ids: N111Ids, +frame: X181Frame) -> X188Seq:
  w12_bool_fast_prefix(word,True{},l_no,l_yes,ids,frame)

@unsafe
def w12_signbit_branch_code(+w: N111Value, label: U32, +ids: N111Ids, +frame: X181Frame) -> X188Seq:
  +lh = w2_phys_val(w,frame)
  +reg = w2_phys_dst(lh,N111U64{})
  +load_w = w2_phys_load(lh,w,ids,frame)
  x188_many([load_w,x188_i2("testq",reg,reg),x188_i1("jge",X187Target{x181_label(label,frame)})])

law x190_l_body:
  for body: List<&2,P113DStmt>
  for +flow: X190LFlow
  for +env: X190LEnv
  X190LFlow

@unsafe
def x190_l_join(condition: N111Value, no: List<&2,P113DStmt>, +after: U32,
    +env: X190LEnv, yes: X190LFlow) -> X190LFlow:
  match env yes:
    case X190LEnv{+ids,parameters,header,collect} X190LFlow{live,graph}:
      x190_l_joined(x190_l_value(condition,ids),live,env,x190_l_body(no,X190LFlow{after,graph},env))

@unsafe
def x190_l_if(condition: N111Value, yes: List<&2,P113DStmt>, no: List<&2,P113DStmt>,
    flow: X190LFlow, +env: X190LEnv) -> X190LFlow:
  match flow:
    case X190LFlow{+live,graph}: x190_l_join(condition,no,live,env,x190_l_body(yes,X190LFlow{live,graph},env))

@unsafe
def x190_l_again(values: List<&2,N111Value>, flow: X190LFlow, +env: X190LEnv) -> X190LFlow:
  match flow env:
    case X190LFlow{live,graph} X190LEnv{ids,+parameters,header,collect}:
      x190_l_event(x190_l_values(values,ids),parameters,X190LFlow{U32.or(header,parameters),graph},env)

@unsafe
def x190_l_scalar_ids(+stmt: N111Stmt, +flow: X190LFlow, +env: X190LEnv, +ids: KDef) -> X190LFlow:
  match stmt:
    case N111Set{name,typ,value}: x190_l_event(x190_l_value(value,ids),x190_l_bit(name,ids),flow,env)
    case N111Bin{name,typ,op,left,right}:
      x190_l_event(U32.or(x190_l_value(left,ids),x190_l_value(right,ids)),x190_l_bit(name,ids),flow,env)
    case N111Load{name,typ,base,offset}: x190_l_event(x190_l_value(base,ids),x190_l_bit(name,ids),flow,env)
    case N111Store{typ,base,offset,value}: x190_l_event(U32.or(x190_l_value(base,ids),x190_l_value(value,ids)),0,flow,env)
    case N111Offset{name,base,bytes}:
      x190_l_event(U32.or(x190_l_value(base,ids),x190_l_value(bytes,ids)),x190_l_bit(name,ids),flow,env)
    case N111Alloca{name,bytes,align}: flow
    case N111Return{value}: x190_l_terminal(x190_l_value(value,ids),flow,env)
    case N111If{condition,yes,no}: x190_l_if(condition,x181_scalar_rows(yes),x181_scalar_rows(no),flow,env)
    case N111Call{name,typ,symbol,args}:
      x190_l_inline(x186_inline_op(stmt),x190_l_args(args,ids),x190_l_bit(name,ids),flow,env)

@unsafe
def x190_l_scalar(stmt: N111Stmt, flow: X190LFlow, +env: X190LEnv) -> X190LFlow:
  match env:
    case X190LEnv{ids,parameters,header,collect}: x190_l_scalar_ids(stmt,flow,env,ids)

@unsafe
def x190_l_stmt(stmt: P113DStmt, +flow: X190LFlow, +env: X190LEnv) -> X190LFlow:
  match stmt env:
    case P113DScalar{scalar} _: x190_l_scalar(scalar,flow,env)
    case P113DIf{condition,yes,no} _: x190_l_if(condition,yes,no,flow,env)
    case P113DResult{values} X190LEnv{ids,parameters,header,collect}: x190_l_terminal(x190_l_values(values,ids),flow,env)
    case P113DAgain{values} _: x190_l_again(values,flow,env)
    case P113DCall{names,target,args} X190LEnv{+ids,parameters,header,collect}:
      x190_l_call(x190_l_values(args,ids),x190_l_names(names,ids),flow,env)

@unsafe
def x190_l_body(body,flow,env):
  match body:
    case Nil{}: flow
    case Con{head,rest}: x190_l_stmt(head,x190_l_body(rest,flow,env),env)

law x190_l_fixed:
  for +body: List<&2,P113DStmt>
  for +ids: KDef
  for +parameters: U32
  for +header: U32
  for +fuel: U32
  X190LFixed

@unsafe
def x190_l_fixed_step(+body: List<&2,P113DStmt>, +ids: KDef, +parameters: U32,
    +header: U32, +fuel: U32, flow: X190LFlow) -> X190LFixed:
  match flow:
    case X190LFlow{+live,graph}:
      nt_choose(X190LFixed,U32.is_eq(live,header),u => X190LFixed{header,True{}},
        u => x190_l_fixed(body,ids,parameters,U32.or(header,live),U32.sub(fuel,1)))

@unsafe
def x190_l_fixed(body,ids,parameters,header,fuel):
  nt_choose(X190LFixed,U32.is_eq(fuel,0),u => X190LFixed{header,False{}},u =>
    x190_l_fixed_step(body,ids,parameters,header,fuel,x190_l_body(body,X190LFlow{0,[]},X190LEnv{ids,parameters,header,False{}})))

@unsafe
def x203_choices(rows: List<&2,X181RegisterChoice>, +bit: U32, ids: KDef,
    reversed: List<&2,String>) -> X190LCandidates:
  match rows:
    case Nil{}: X190LCandidates{nt_reverse(String,reversed,[]),ids}
    case Con{X181RegisterChoice{+name,score},rest}:
      x203_choices(rest,U32.shl(bit),p111v_put(ids,name,"X190LBit",bit,0),Con{name,reversed})

@unsafe
def x190_a_pair(+name: String, value: N111Value, +ids: KDef, +affinities: KDef) -> KDef:
  match value:
    case N111Local{+source}:
      +destinationBit = x190_l_bit(name,ids)
      +sourceBit = x190_l_bit(source,ids)
      nt_choose(KDef,U32.is_gt(destinationBit,0) && U32.is_gt(sourceBit,0),u =>
        p111v_put(p111v_put(affinities,name,"X190Affinity",U32.or(da(p111v_get(affinities,name)),sourceBit),0),
          source,"X190Affinity",U32.or(da(p111v_get(affinities,source)),destinationBit),0),u => affinities)
    case _: affinities

@unsafe
def x190_branch_test(+typ: N111Type, op: String, +left: N111Value, +right: N111Value,
    label: U32, +ids: N111Ids, +frame: X181Frame) -> X188Seq:
  +lh = nt_choose(X185Physical,x190_operands_enabled(),u => x190_value_home(left,frame),u => X185PhysicalNone{})
  +rh = nt_choose(X185Physical,x190_operands_enabled(),u => x190_value_home(right,frame),u => X185PhysicalNone{})
  +destination = x190_branch_operand(typ,lh,x188_width_reg(typ,10))
  +immediate = nt_choose(X188Seq,x185_machine_enabled(),u => x190_branch_immediate_to(typ,right,ids,destination),u => X188Empty{})
  x188_many([x190_branch_load(left,ids,frame,lh,x188_reg(10,64)),
    nt_choose(X188Seq,x188_empty(immediate),u =>
      x188_cat(x190_branch_load(right,ids,frame,rh,x188_reg(11,64)),
        x188_i2(x181_width(typ,"cmpq","cmpl"),x190_branch_operand(typ,rh,x188_width_reg(typ,11)),destination)),u => immediate),
    x188_i1(x190_branch_inverse(op),X187Target{x181_label(label,frame)})])

@unsafe
def x190_branch_arm_when(enabled: Bool, +typ: N111Type, +op: String,
    +left: N111Value, +right: N111Value, +truth: Bool, +arm: List<&2,P113DStmt>, +facts: X190BranchFacts) -> List<&2,P113DStmt>:
  match arm:
    case Con{P113DScalar{N111Bin{name,+innerType,+innerOp,a,b}},Con{P113DIf{condition,yes,no},rest}}:
      +same = agy_str_eq(op,innerOp)
      nt_choose(List<&2,P113DStmt>,enabled && U32.is_eq(p111v_type(typ),p111v_type(innerType)) &&
          x186_e_equal(left,a) && x186_e_equal(right,b) &&
          (same || agy_str_eq(x190_branch_inverse(op),"j" ++ x181_condition(innerOp))) &&
          x190_branch_allowed(name,innerType,innerOp,condition,facts),
        u => x190_branch_append(nt_choose(List<&2,P113DStmt>,Bool.not(Bool.xor(same,truth)),v => yes,v => no),rest),
        u => arm)
    case _: arm

@unsafe
def x190_branch_arm(typ: N111Type, op: String, left: N111Value, right: N111Value,
    truth: Bool, arm: List<&2,P113DStmt>, facts: X190BranchFacts) -> List<&2,P113DStmt>:
  x190_branch_arm_when(x190_branch_complements_enabled(),typ,op,left,right,truth,arm,facts)

@unsafe
def w12_i_st_opt_shr(+body: List<&2,P113DStmt>, +orig: List<&2,P113DStmt>, +wantXor: Bool, +word: N111Value, +oRaw: String, +oBits: String, +oExp: String) -> List<&2,P113DStmt>:
  match body:
    case Con{P113DScalar{N111Bin{+b1,t,op,+w1,N111Const{40,0}}},+rest}:
      nt_choose(List<&2,P113DStmt>,agy_str_eq(op,"shr") && w2_val_eq(w1,word),
        u => w12_i_st_and(rest,orig,wantXor,oRaw,b1,oExp),
        u => w12_i_st_opt_exp(body,orig,wantXor,oRaw,oBits,oExp))
    case _: w12_i_st_opt_exp(body,orig,wantXor,oRaw,oBits,oExp)

@unsafe
def w12_i_strip_opp(+body: List<&2,P113DStmt>, +wantXor: Bool, +word: N111Value, +oRaw: String, +oBits: String, +oExp: String) -> List<&2,P113DStmt>:
  match body:
    case Con{P113DScalar{N111Set{s1,ts1,N111Local{s1b}}},+more}:
      nt_choose(List<&2,P113DStmt>,agy_str_eq(s1,oRaw) && agy_str_eq(s1b,oRaw),
        u => w12_i_st_opt_shr(more,body,wantXor,word,oRaw,oBits,oExp),
        u => w12_i_st_opt_shr(body,body,wantXor,word,oRaw,oBits,oExp))
    case Con{P113DScalar{N111Bin{+raw,t,op,+w0,N111Const{1,0}}},+more}:
      nt_choose(List<&2,P113DStmt>,agy_str_eq(op,"eq") && w2_val_eq(w0,word),
        u => w12_i_st_opt_shr(more,body,wantXor,word,raw,oBits,oExp),
        u => w12_i_st_opt_shr(body,body,wantXor,word,oRaw,oBits,oExp))
    case _: w12_i_st_opt_shr(body,body,wantXor,word,oRaw,oBits,oExp)

@unsafe
def w12_i_bm_fin(+w0: N111Value, +invert: Bool, +raw: String, +b1: String, +b2: String, +ex: String,
    +bx: String, +mc: String, +mc2: String, +yes: List<&2,P113DStmt>, +no: List<&2,P113DStmt>, +rest: List<&2,P113DStmt>) -> W12IBoolMatch:
  +no2 = w12_i_strip_opp(no,Bool.not(invert),w0,raw,b2,ex)
  nt_choose(W12IBoolMatch,
    w12_i_bool_dead(raw,b1,b2,ex,bx,mc2,yes,no2,rest) &&
    w12_i_dead_in(mc,yes,[rest],256) && w12_i_dead_in(mc,no2,[rest],256),
    u => W12IBoolHit{w0,invert,yes,no2,rest},
    u => W12IBoolMiss{})

@unsafe
def w12_i_bm_if(body: List<&2,P113DStmt>, +w0: N111Value, +invert: Bool, +raw: String, +b1: String, +b2: String,
    +ex: String, +bx: String, +mc: String, +mc2: String) -> W12IBoolMatch:
  match body:
    case Con{P113DIf{N111Local{mcb},+yes,+no},+rest}:
      nt_choose(W12IBoolMatch,agy_str_eq(mcb,mc2),
        u => w12_i_bm_fin(w0,invert,raw,b1,b2,ex,bx,mc,mc2,yes,no,rest),
        u => W12IBoolMiss{})
    case _: W12IBoolMiss{}

@unsafe
def x191_indexed(+body: List<&2,P113DStmt>, +facts: X190BranchFacts) -> Maybe<&2,X191Pick>:
  match body:
    case Con{P113DScalar{N111Bin{+scaled,N111U64{},op,index,factor}},
      Con{P113DScalar{N111Offset{+pointer,base,N111Local{source}}},rest}}:
      +scale = x191_scale(op,factor)
      nt_choose(Maybe<&2,X191Pick>,x191_address_enabled() && U32.is_gt(scale,0) &&
          agy_str_eq(scaled,source) && x191_single(scaled,facts) && x191_single(pointer,facts),
        u => x191_access(X191Address{base,index,scale,0},pointer,rest,facts),u => None{})
    case Con{P113DScalar{N111Offset{+pointer,base,index}},rest}:
      nt_choose(Maybe<&2,X191Pick>,x191_address_enabled() && x191_single(pointer,facts),
        u => x191_access(X191Address{base,index,1,0},pointer,rest,facts),u => None{})
    case _: None{}

@unsafe
def x191_pick(+body: List<&2,P113DStmt>, +facts: X190BranchFacts) -> Maybe<&2,X191Pick>:
  match body:
    case Con{P113DScalar{N111Load{name,typ,base,+offset}},rest}:
      nt_choose(Maybe<&2,X191Pick>,U32.is_le(offset,2147483647),
        u => x191_load_alu(name,typ,X191Address{base,N111Const{0,0},0,offset},rest,facts),u => None{})
    case _: x191_indexed(body,facts)

# Placement rows preserve each actual input, output and call barrier. A store
# has no definition. Splitting its three reads into two rows is conservative:
# base and value remain live through the first row, overlapping the index.
# No metadata row escapes to source verification, memory analysis or emission.
law x191_placement:
  for +body: List<&2,P113DStmt>
  for +facts: X190BranchFacts
  List<&2,P113DStmt>

@unsafe
def x191_placement_plain(body: List<&2,P113DStmt>, +facts: X190BranchFacts) -> List<&2,P113DStmt>:
  match body:
    case Nil{}: []
    case Con{P113DIf{condition,yes,no},rest}:
      Con{P113DIf{condition,x191_placement(yes,facts),x191_placement(no,facts)},x191_placement(rest,facts)}
    case Con{P113DScalar{N111If{condition,yes,no}},rest}:
      Con{P113DIf{condition,x191_placement(x181_scalar_rows(yes),facts),
        x191_placement(x181_scalar_rows(no),facts)},x191_placement(rest,facts)}
    case Con{head,rest}: Con{head,x191_placement(rest,facts)}

@unsafe
def x191_placement_pick(pick: Maybe<&2,X191Pick>, body: List<&2,P113DStmt>, +facts: X190BranchFacts) -> List<&2,P113DStmt>:
  match pick:
    case Some{X191Pick{rest,operation}}: nt_append(P113DStmt,x191_rows(operation),x191_placement(rest,facts))
    case None{}: x191_placement_plain(body,facts)

@unsafe
def x191_placement(body,facts):
  x192_shared_placement(x192_shared_pick(body,facts),body,facts)

# Frame homes never use reserved r10/r11/rax. Evaluate both address components
# before writing any destination. A load may alias either address register;
# an ALU must use rax when its destination aliases an address register.
@unsafe
def x191_address_code(address: X191Address, +ids: N111Ids, +frame: X181Frame) -> X191AddressCode:
  match address:
    case X191Address{+base,+index,+scale,disp}:
      +br = x191_reg(base,frame,10)
      +ir = x191_reg(index,frame,11)
      X191AddressCode{x188_cat(x185_physical_load(base,ids,frame,x188_reg(br,64)),
        nt_choose(X188Seq,U32.is_eq(scale,0),u => X188Empty{},
          u => x185_physical_load(index,ids,frame,x188_reg(ir,64)))),
        nt_choose(X187Operand,U32.is_eq(scale,0),u => X187Mem{br,disp},
          u => X187Indexed{br,ir,scale,disp})}

@unsafe
def x191_emit_address(operation: X191Operation, address: X191AddressCode, +ids: N111Ids, +frame: X181Frame) -> X188Seq:
  match operation address:
    case X191Load{+name,+typ,a} X191AddressCode{prefix,operand}:
      +dest = x191_destination(name,frame)
      x188_many([prefix,x188_i2(x181_width(typ,"movq","movl"),operand,x188_width_reg(typ,dest)),
        x191_publish(name,dest,frame)])
    case X191Store{+typ,a,+value} X191AddressCode{prefix,operand}:
      +source = x191_reg(value,frame,0)
      x188_many([prefix,x185_physical_load(value,ids,frame,x188_reg(source,64)),
        x188_i2(x181_width(typ,"movq","movl"),x188_width_reg(typ,source),operand)])
    case X191MemoryAlu{+name,+typ,op,left,a} X191AddressCode{prefix,+operand}:
      +home = x191_destination(name,frame)
      +dest = nt_choose(U32,x191_aliases(home,operand),u => 0,u => home)
      x188_many([prefix,x185_physical_load(left,ids,frame,x188_reg(dest,64)),
        x188_i2(x181_alu(op) ++ x181_width(typ,"q","l"),operand,x188_width_reg(typ,dest)),
        x191_publish(name,dest,frame)])

@unsafe
def x191_emit(+operation: X191Operation, +ids: N111Ids, +frame: X181Frame) -> X188Seq:
  match operation:
    case X191Load{name,typ,address}: x191_emit_address(operation,x191_address_code(address,ids,frame),ids,frame)
    case X191Store{typ,address,value}: x191_emit_address(operation,x191_address_code(address,ids,frame),ids,frame)
    case X191MemoryAlu{name,typ,op,left,address}: x191_emit_address(operation,x191_address_code(address,ids,frame),ids,frame)

@unsafe
def x192_shared_pick(body: List<&2,P113DStmt>, +facts: X190BranchFacts) -> Maybe<&2,X192AddressPick>:
  match body:
    case Con{P113DScalar{N111Bin{+scaled,N111U64{},op,+index,factor}},rest}:
      +scale = x191_scale(op,factor)
      nt_choose(Maybe<&2,X192AddressPick>,x192_shared_address_enabled() && U32.is_gt(scale,0) &&
          Bool.not(x185_sf_source(index,scaled)),
        u => x192_address_scan(rest,scaled,index,scale,[],0,0,15,[],facts),u => None{})
    case _: None{}

# Both allocation paths consume these exact read/write rows. The original body
# still supplies frame slots, whole-function facts, setup and parameter homes.
@unsafe
def x192_shared_placement(pick: Maybe<&2,X192AddressPick>, +body: List<&2,P113DStmt>, +facts: X190BranchFacts) -> List<&2,P113DStmt>:
  match pick:
    case Some{X192AddressPick{rest,rows}}: nt_append(P113DStmt,x192_address_rows(rows),x191_placement(rest,facts))
    case None{}: x191_placement_pick(x191_pick(body,facts),body,facts)

@unsafe
def x191_ff_work(todo: List<&2,X188Seq>, previous: X191FrameStore, output: List<&2,X188Seq>) -> X188Seq:
  match todo:
    case Nil{}: x188_finish(output)
    case Con{X188Empty{},rest}: x191_ff_work(rest,previous,output)
    case Con{X188Join{left,right},rest}: x191_ff_work(Con{left,Con{right,rest}},previous,output)
    case Con{X188One{+item},rest}: x191_ff_work(rest,x191_ff_store(item),x198qm_item(item,previous,output))


@unsafe
def x191_frame_forward_when(enabled: Bool, +code: X188Seq) -> X188Seq:
  nt_choose(X188Seq,enabled,u => x191_ff_work([code],X191FrameStoreNone{},[]),u => code)

# Copy + full-width immediate ADD/SUB -> one LEA. No value/memory motion.
# Refuse until a bounded typed-item scan proves every arithmetic flag dead:
# only CMP/ADD/SUB terminate that proof; carry consumers and all unknown items
# are barriers. Partial flag writers (including shifts by zero) only pass through.
# Signed displacement admission uses both immediate words, never just lo.

@unsafe
def w4c_sub_fold(+b: U32, +t: U32, +a: U32, +i0: X187Parsed, +i1: X187Parsed,
    +rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +out: List<&2,X188Seq>) -> List<&2,X188Seq>:
  match rest:
    case Con{i2,Con{i3,Con{i4,tail}}}:
      w4c_sub_fold2(w4b_as_rr(i2),i3,i4,b,t,a,i0,i1,rest,tail,fnItems,out)
    case _: w4b_copy_peep(Con{i1,rest},fnItems,Con{X188One{i0},out})

@unsafe
def w4b_copy_after_sub(+c: U32, +rest: List<&2,X187Parsed>, +i0: X187Parsed, +i1: X187Parsed,
    +fnItems: List<&2,X187Parsed>, +out: List<&2,X188Seq>) -> List<&2,X188Seq>:
  match rest:
    case Con{+i2,Con{+i3,+tail}}: w4b_copy_check_cmp(w4b_as_imm_reg(i2),c,i0,i1,i2,i3,tail,fnItems,out)
    case _: w4b_copy_peep(Con{i1,rest},fnItems,Con{X188One{i0},out})

@unsafe
def w4b_copy_pair_rr(r0: W4BRR, r1: W4BRR, +i0: X187Parsed, +i1: X187Parsed,
    +rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +out: List<&2,X188Seq>) -> List<&2,X188Seq>:
  match r0 r1:
    case W4BRR{+op0,+s,+ws,+t,+wt} W4BRR{+op1,+t2,+wt2,+d,+wd}:
      +isMov32 = agy_str_eq(op0,"movl") && U32.is_eq(ws,32) && U32.is_eq(wt,32)
      # movl %s32, %t32 ; movq %t64, %d64 -> movl %s32, %d32
      nt_choose(List<&2,X188Seq>,isMov32 && agy_str_eq(op1,"movq") && U32.is_eq(wt2,64) && U32.is_eq(wd,64) &&
          U32.is_eq(t,t2) && Bool.not(U32.is_eq(t,d)) && w4b_reg_dead(t,rest,fnItems,36),
        u => w4b_copy_peep(Con{PInst{X187Instruction{"movl",[X187Reg{s,32,False{}},X187Reg{d,32,False{}}]}},rest},fnItems,out),
        # movl %s32, %t32 ; alu32 %t32, %d32 -> alu32 %s32, %d32
        u => nt_choose(List<&2,X188Seq>,isMov32 && w4b_is_alu32_rr(op1) && U32.is_eq(wt2,32) && U32.is_eq(wd,32) &&
            U32.is_eq(t,t2) && Bool.not(U32.is_eq(t,d)) && w4b_reg_dead(t,rest,fnItems,36),
          v => w4b_copy_peep(Con{PInst{X187Instruction{op1,[X187Reg{s,32,False{}},X187Reg{d,32,False{}}]}},rest},fnItems,out),
          # comm_alu32 %d32, %t32 ; movq %t64, %d64 -> comm_alu32 %t32, %d32 (when %t is dead)
          v => nt_choose(List<&2,X188Seq>,
              (agy_str_eq(op0,"addl") || agy_str_eq(op0,"imull") || agy_str_eq(op0,"andl") || agy_str_eq(op0,"orl") || agy_str_eq(op0,"xorl")) &&
              U32.is_eq(ws,32) && U32.is_eq(wt,32) && agy_str_eq(op1,"movq") && U32.is_eq(wt2,64) && U32.is_eq(wd,64) &&
              U32.is_eq(t,t2) && U32.is_eq(s,d) && Bool.not(U32.is_eq(t,d)) && w4b_reg_dead(t,rest,fnItems,36),
            z => w4b_copy_peep(Con{PInst{X187Instruction{op0,[X187Reg{t,32,False{}},X187Reg{d,32,False{}}]}},rest},fnItems,out),
            # subl %s32, %t32 ; movl %t32, %d32 ; cmpq $0, %d64 ; jz/jnz -> drop cmpq
            z => nt_choose(List<&2,X188Seq>,agy_str_eq(op0,"subl") && agy_str_eq(op1,"movl") &&
                U32.is_eq(wt,32) && U32.is_eq(wt2,32) && U32.is_eq(wd,32) && U32.is_eq(t,t2),
              w => w4b_copy_after_sub(d,rest,i0,i1,fnItems,out),
              # movl/alu32 _, %t32 ; movl %t32, %t32 -> drop redundant zero-extend
              w => nt_choose(List<&2,X188Seq>,(isMov32 || (w4b_is_alu32_rr(op0) && U32.is_eq(wt,32))) &&
                  agy_str_eq(op1,"movl") && U32.is_eq(wt2,32) && U32.is_eq(wd,32) &&
                  U32.is_eq(t,t2) && U32.is_eq(t,d),
                x => w4b_copy_peep(rest,fnItems,Con{X188One{i0},out}),
                x => nt_choose(List<&2,X188Seq>,isMov32 && agy_str_eq(op1,"movq") &&
                    U32.is_eq(wt2,64) && U32.is_eq(wd,64) && U32.is_eq(d,11),
                  y => w4c_sub_fold(s,t,t2,i0,i1,rest,fnItems,out),
                  y => w4b_copy_peep(Con{i1,rest},fnItems,Con{X188One{i0},out})))))))
    case _ _: w4b_copy_peep(Con{i1,rest},fnItems,Con{X188One{i0},out})

law w4c_xmm_opt_nolea:
  for +p1: List<&2,X187Parsed>
  List<&2,X187Parsed>

@unsafe
def w4c_xmm_opt(+items: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  +p1 = w4c_xmm_peep(items,items,w4c_count_reads(items,W4CMEmpty{}),[])
  w4c_xmm_opt_nolea(p1)


# ---- W5-R2: General XMM Register-Copy & Commutative Memory-Operand Folding ----

@unsafe
def w5_xmm_opt_noxmm_go(hasLea: Bool, +items: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match hasLea:
    case True{}: items
    case False{}:
      +p2 = w4c_copy_slot_fwd(items)
      +p4 = w4c_backedge_coalesce(p2)
      w4c_dead_slot_elim(p4)

@unsafe
def w5_xmm_opt_noxmm(+items: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  +p2 = w4c_copy_slot_fwd(items)
  +p4 = w4c_backedge_coalesce(p2)
  w4c_dead_slot_elim(p4)

@unsafe
def w4c_xmm_opt_nolea(p1):
  +p2 = w4c_copy_slot_fwd(p1)
  +p3 = w4c_xmm_peep(p2,p2,w4c_count_reads(p2,W4CMEmpty{}),[])
  +p4 = w4c_backedge_coalesce(p3)
  +p5 = w4c_dead_slot_elim(p4)
  +p6 = w4c_xmm_peep(p5,p5,w4c_count_reads(p5,W4CMEmpty{}),[])
  +p7 = w4c_dead_slot_elim(p6)
  +p8 = w4c_xmm_peep(p7,p7,w4c_count_reads(p7,W4CMEmpty{}),[])
  +p9 = w4c_dead_slot_elim(p8)
  +p10 = w5_xmm_fold(p9,p9,[])
  w5_xmm_fold(p10,p10,[])

@unsafe
def w5b_leaf_slot_promote_go(+items: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  +canRcx = Bool.not(w5b_reg_used(1,items))
  +canR12 = w5b_r12_check(items,False{},False{})
  +p1 = nt_choose(List<&2,X187Parsed>,canRcx,v => w5b_promote_one(1,False{},items),v => items)
  +p2 = nt_choose(List<&2,X187Parsed>,canR12,v => w5b_promote_one(12,True{},p1),v => p1)
  w5b_promote_cleanup(items,p2,canRcx || canR12)

@unsafe
def w5b_leaf_slot_promote(+items: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  nt_choose(List<&2,X187Parsed>,w4c_has_leaq_rbp(items),u => items,u => w5b_leaf_slot_promote_go(items))

@unsafe
def w5b_run_leaf_promote(doProm: Bool, +items: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match doProm:
    case True{}: w5b_leaf_slot_promote(items)
    case False{}: items

@unsafe
def w5_run_xmm_rbp(hasNegRbp: Bool, +items: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match hasNegRbp:
    case True{}: w5_xmm_opt_noxmm(items)
    case False{}: items

@unsafe
def w5_run_xmm(hasXmm: Bool, +hasNegRbp: Bool, +items: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match hasXmm:
    case True{}: w4c_xmm_opt(items)
    case False{}: w5_run_xmm_rbp(hasNegRbp,items)

# ============================================================================
# W5B-R3 Pass 5/6: General Rotate, Spill-Bounce, Cmp+Branch, Square & Select Peepholes
# ============================================================================
@unsafe
def w11_rot16_s5(+rotOp: String, +rX: U32, +rA: U32, +rB: U32, +k: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{i5,r6}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,w11_inst_reg_reg_eq(i5,"orq",rB,64,rA,64),
        u => w11_rot16_s6(rotOp,rX,rA,rB,k,r6,fnItems),
        u => None{})
    case _: None{}

@unsafe
def w11_ror16_m(+rX: U32, +rA: U32, +rB: U32, +k: U32, m_opt: Maybe<&2,U32>, r5: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match m_opt:
    case Some{m}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_eq(U32.add(k,m),16),
        u => w11_rot16_s5("rorw",rX,rA,rB,k,r5,fnItems),
        u => None{})
    case _: None{}

@unsafe
def w11_ror16_s4(+rX: U32, +rA: U32, +rB: U32, +k: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{+i4,r5}:
      w11_ror16_m(rX,rA,rB,k,w11_maybe_u32_or(w11_inst_imm_reg(i4,"shll",rA,0),w11_inst_imm_reg(i4,"shlq",rA,0)),r5,fnItems)
    case _: None{}

@unsafe
def w11_ror16_s3(+rX: U32, +rA: U32, +rB: U32, +k: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{i3,r4}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,w11_inst_reg_reg_eq(i3,"movq",rX,64,rA,64),
        u => w11_ror16_s4(rX,rA,rB,k,r4,fnItems),
        u => None{})
    case _: None{}

@unsafe
def w11_rol16_m(+rX: U32, +rA: U32, +rB: U32, +k: U32, m_opt: Maybe<&2,U32>, r5: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match m_opt:
    case Some{m}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_eq(U32.add(k,m),16),
        u => w11_rot16_s5("rolw",rX,rA,rB,k,r5,fnItems),
        u => None{})
    case _: None{}

@unsafe
def w11_rol16_s4(+rX: U32, +rA: U32, +rB: U32, +k: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{i4,r5}: w11_rol16_m(rX,rA,rB,k,w11_inst_imm_reg(i4,"shrq",rB,64),r5,fnItems)
    case _: None{}

@unsafe
def w11_rol16_rb(+rX: U32, +rA: U32, +k: U32, rb_opt: Maybe<&2,U32>, r4: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rb_opt:
    case Some{+rB}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,Bool.not(U32.is_eq(rB,rA)) && Bool.not(U32.is_eq(rB,rX)),
        u => w11_rol16_s4(rX,rA,rB,k,r4,fnItems),
        u => None{})
    case _: None{}

@unsafe
def w11_cmp_jcc_b2a_rb(+cmpInst: X187Parsed, +cc: String, +rA: U32, rb_opt: Maybe<&2,U32>,
    r4: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rb_opt:
    case Some{rB}: w11_cmp_jcc_tail(cmpInst,cc,rA,rB,True{},r4,fnItems)
    case _: None{}

@unsafe
def w11_cmp_jcc_b2a(+cmpInst: X187Parsed, +cc: String, +rA: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{iM,r4}: w11_cmp_jcc_b2a_rb(cmpInst,cc,rA,w11_inst_reg_dst(iM,"movq",rA,64,64),r4,fnItems)
    case _: None{}

@unsafe
def w11_cmp_jcc_after_mov(+cmpInst: X187Parsed, +cc: String, +rA: U32, +rB: U32,
    rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{+i3,+r4}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,w11_inst_imm_eq_reg(i3,"xorl",1,rB,32),
        v => w11_cmp_jcc_tail(cmpInst,cc,rA,rB,True{},r4,fnItems),
        v => w11_cmp_jcc_tail(cmpInst,cc,rA,rB,False{},Con{i3,r4},fnItems))
    case _: None{}

@unsafe
def w11_cmp_jcc_mov_rb(+cmpInst: X187Parsed, +cc: String, +rA: U32, rb_opt: Maybe<&2,U32>,
    r3: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rb_opt:
    case Some{rB}: w11_cmp_jcc_after_mov(cmpInst,cc,rA,rB,r3,fnItems)
    case _: None{}

@unsafe
def w11_cmp_jcc_after_z(+cmpInst: X187Parsed, +cc: String, +rA: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{+i2,+r3}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,w11_inst_imm_eq_reg(i2,"xorl",1,rA,32),
        u => w11_cmp_jcc_b2a(cmpInst,cc,rA,r3,fnItems),
        u => w11_cmp_jcc_mov_rb(cmpInst,cc,rA,w11_inst_reg_dst(i2,"movq",rA,64,64),r3,fnItems))
    case _: None{}

@unsafe
def w11_cmp_jcc_s1(+cmpInst: X187Parsed, +cc: String, +rA: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{i1,r2}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,w11_inst_reg_reg_eq(i1,"movzbl",rA,8,rA,32),
        u => w11_cmp_jcc_after_z(cmpInst,cc,rA,r2,fnItems),
        u => None{})
    case _: None{}

@unsafe
def w11_cmp_bounce_s3_set(+rA: U32, +rT1: U32, +rB: U32, +rT2: U32,
    s_opt: Maybe<&2,W11SetCC>, r4: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match s_opt:
    case Some{W11SetCC{opS,rs}}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_eq(rs,rT1),
        u => w11_cmp_bounce_s4(rA,rT1,rB,rT2,opS,r4,fnItems),
        u => None{})
    case _: None{}

@unsafe
def w11_cmp_bounce_s3(+rA: U32, +rT1: U32, +rB: U32, +rT2: U32,
    rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{i3,r4}: w11_cmp_bounce_s3_set(rA,rT1,rB,rT2,w11_inst_setcc(i3),r4,fnItems)
    case _: None{}

@unsafe
def w11_cmp_bounce_s2(+rA: U32, +rT1: U32, +rB: U32, +rT2: U32,
    rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{i2,r3}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,w11_inst_reg_reg_eq(i2,"cmpq",rT2,64,rT1,64),
        u => w11_cmp_bounce_s3(rA,rT1,rB,rT2,r3,fnItems),
        u => None{})
    case _: None{}

@unsafe
def w11_cmp_bounce_s1(+rA: U32, +rT1: U32, rr_opt: Maybe<&2,W11PairU32>,
    r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rr_opt:
    case Some{W11PairU32{+rB,+rT2}}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,Bool.not(U32.is_eq(rT1,rT2)) && Bool.not(U32.is_eq(rB,rT1)),
        u => w11_cmp_bounce_s2(rA,rT1,rB,rT2,r2,fnItems),
        u => None{})
    case _: None{}

@unsafe
def w11_sel_bounce_s3(+srcY: X187Operand, +rN: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{i3,r4}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,w11_inst_reg_reg_eq(i3,"testl",0,32,0,32),
        u => w11_sel_bounce_s4(srcY,rN,r4,fnItems),
        u => None{})
    case _: None{}

@unsafe
def w11_sel_bounce_rn(+srcY: X187Operand, rn_opt: Maybe<&2,U32>, r3: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rn_opt:
    case Some{+rN}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        Bool.not(U32.is_eq(rN,10)) && Bool.not(U32.is_eq(rN,11)) && Bool.not(U32.is_eq(rN,0)),
        u => w11_sel_bounce_s3(srcY,rN,r3,fnItems),
        u => None{})
    case _: None{}

@unsafe
def w11_sel_bounce_s2(+srcY: X187Operand, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{i2,r3}: w11_sel_bounce_rn(srcY,w11_inst_src_reg(i2,"movq",11,64,64),r3,fnItems)
    case _: None{}

@unsafe
def w11_sel_bounce_src(src_opt: Maybe<&2,X187Operand>, r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match src_opt:
    case Some{srcY}: w11_sel_bounce_s2(srcY,r2,fnItems)
    case _: None{}

@unsafe
def w7_run_xmm(hasXmm: Bool, +hasNegRbp: Bool, +hasLoop: Bool, +items: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match hasXmm:
    case True{}: w4c_xmm_opt(items)
    case False{}:
      match hasNegRbp:
        case False{}: items
        case True{}:
          +p2 = w4c_copy_slot_fwd(items)
          +p4 = nt_choose(List<&2,X187Parsed>,hasLoop,u => w4c_backedge_coalesce(p2),u => p2)
          w4c_dead_slot_elim(p4)

@unsafe
def x199s_frame(code: X188Seq,+frame: X181Frame) -> X188Seq:
  match frame:
    case X181Frame{slots,bytes,calls,ps,sym}: x199s_apply(code,slots,x181_loop_label(frame))

@unsafe
def x191_select_chosen(plan: Maybe<&2,X191SelectPlan>, condition: N111Value,
    ids: N111Ids, frame: X181Frame) -> Maybe<&2,X188Seq>:
  match plan:
    case Some{selected}: Some{x191_select_emit(condition,selected,ids,frame)}
    case None{}: None{}

# An empty pair has no effects. Its already evaluated Local/Const condition
# need not be loaded or tested; any preceding Boolean producer stays intact.
@unsafe
def x191_select_arms(condition: N111Value, +yes: List<&2,P113DStmt>, +no: List<&2,P113DStmt>,
    ids: N111Ids, frame: X181Frame) -> Maybe<&2,X188Seq>:
  nt_choose(Maybe<&2,X188Seq>,List.is_empty(&2,P113DStmt,yes) && List.is_empty(&2,P113DStmt,no),
    u => Some{X188Empty{}},u => x191_select_chosen(x191_select_plan(yes,no),condition,ids,frame))

@unsafe
def x191_conditional_select(+condition: N111Value, yes: List<&2,P113DStmt>, no: List<&2,P113DStmt>,
    ids: N111Ids, frame: X181Frame) -> Maybe<&2,X188Seq>:
  nt_choose(Maybe<&2,X188Seq>,x191_conditional_select_enabled() && x191_select_value(condition),
    u => x191_select_arms(condition,yes,no,ids,frame),u => None{})
# Experimental compare/copy/select fusion. No new whole-function traversal:
# the existing branch-pair walk collects independent counts in dx, leaving
# its original adjacent-branch count in da. The original allocation stays.
@unsafe
def x197ms_result(+typ: N111Type, +op: String, +names: List<&2,String>, +frame: X181Frame,
    +yw: X187Operand, +yn: X187Operand, +nw: X187Operand, +nn: X187Operand,
    destination: X185Physical) -> X188Seq:
  match destination:
    case X185Physical{dw,dn,db}: x197ms_select(typ,op,names,frame,yw,yn,nw,nn,dw,dn)
    case X185PhysicalNone{}: x197ms_select(typ,op,names,frame,yw,yn,nw,nn,x188_reg(11,64),x188_reg(11,32))

@unsafe
def x197ms_registers(+typ: N111Type, +op: String, +st: N111Type,
    +names: List<&2,String>, +frame: X181Frame,
    left: X185Physical, right: X185Physical, yes: X185Physical, no: X185Physical) -> X188Seq:
  match left right yes no:
    case X185Physical{lw,ln,lb} X185Physical{rw,rn,rb}
         X185Physical{yw,yn,yb} X185Physical{nw,nn,nb}:
      x188_cat(x188_i2(x181_width(typ,"cmpq","cmpl"),x188_physical_width(typ,rw,rn),x188_physical_width(typ,lw,ln)),
        x197ms_result(st,op,names,frame,yw,yn,nw,nn,x197ms_destination(names,frame)))
    case _ _ _ _: X188Empty{}

@unsafe
def x197ms_pick(plan: X194Select, +frame: X181Frame) -> X188Seq:
  match plan:
    case X194Select{rest,typ,+op,left,right,+invert,X191SelectPlan{st,+yes,+no,names},removed}:
      nt_choose(X188Seq,x197ms_enabled() && Bool.not(String.is_empty(x197ms_inverse(op))),u =>
        x197ms_registers(typ,op,st,names,frame,x190_value_home(left,frame),x190_value_home(right,frame),
          x190_value_home(nt_choose(N111Value,invert,v => no,v => yes),frame),
          x190_value_home(nt_choose(N111Value,invert,v => yes,v => no),frame)),u => X188Empty{})

@unsafe
def w2_cmov_cmp(+typ: N111Type, +left: N111Value, +right: N111Value, +ids: N111Ids, +frame: X181Frame) -> X188Seq:
  +lh = w2_phys_val(left,frame)
  +dst = w2_phys_dst(lh,typ)
  +load_l = w2_phys_load(lh,left,ids,frame)
  +imm = w2_int_cmp_imm(typ,right,dst)
  x188_cat(load_l,
    nt_choose(X188Seq,x188_empty(imm),
      u => x188_cat(w2_cmov_load(right,ids,frame,11),x188_i2(x181_width(typ,"cmpq","cmpl"),x188_width_reg(typ,11),dst)),
      u => imm))

@unsafe
def x197ms_previous(plan: X194Select, +ids: N111Ids, +frame: X181Frame) -> X188Seq:
  match plan:
    case X194Select{rest,+typ,+op,left,right,invert,X191SelectPlan{+st,+yes,+no,names},removed}:
      x188_many([w2_cmov_cmp(typ,left,right,ids,frame),
        w2_cmov_load(nt_choose(N111Value,invert,u => no,u => yes),ids,frame,0),x181_mask(st,x188_reg(0,32)),
        w2_cmov_load(nt_choose(N111Value,invert,u => yes,u => no),ids,frame,11),x181_mask(st,x188_reg(11,32)),
        x188_i2("cmov" ++ x181_condition(op) ++ x181_width(st,"q","l"),x188_width_reg(st,0),x188_width_reg(st,11)),
        x191_select_publish(names,frame)])


@unsafe
def x192_p_write(facts: KDef, name: String, known: Bool) -> KDef:
  p111v_put(facts,name,"X192Predicate",nt_choose(U32,known,u => 1,u => 0),0)

@unsafe
def x181_results(values: List<&2,N111Value>, +ids: N111Ids, +frame: X181Frame, +code: X181Code) -> X181Code:
  match values:
    case Con{head,Nil{}}: x181_return(x181_load(head,ids,frame,x188_reg(0,64)),frame,code)
    case _: x181_store_results(values,0,ids,frame,code)

@unsafe
def x181_store_results(values: List<&2,N111Value>, +offset: U32, +ids: N111Ids, +frame: X181Frame, code: X181Code) -> X181Code:
  match values:
    case Nil{}: x181_return(x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),frame,code)
    case Con{head,rest}:
      x181_store_results(rest,U32.add(offset,8),ids,frame,x181_add(
        x188_many([x181_load(head,ids,frame,x188_reg(10,64)),
          x181_load(N111Local{"__x181_result_out"},ids,frame,x188_reg(11,64)),
          x188_i2("movq",x188_reg(10,64),X187Mem{11,offset})]),code))

@unsafe
def x186_again_planned(values: List<&2,N111Value>, +ids: N111Ids, +frame: X181Frame,
    code: X181Code, plan: Maybe<&2,X188Seq>) -> X181Code:
  match plan:
    case Some{text}: x181_tail_moves([],0,ids,frame,x181_add(text,code))
    case None{}: x181_tail_moves(x181_tail_args(frame),0,ids,frame,x181_tail_snapshot(values,0,ids,frame,code))

@unsafe
def x198a_fact(+value: N111Value, +facts: KDef, ids: N111Ids) -> P113KFact:
  match value ids:
    case N111CtorId{name} N111Ids{functions,ctors}: x198a_id(p111v_get(ctors,name))
    case _ _: p113k_value(value,facts)

def x198_sym_bind(+env: KDef, name: String, token: U32) -> KDef:
  p111v_put(env,name,"X198Token",token,0)

@unsafe
def x192h_buffers(cases: List<&2,P114HCase>, +index: U32) -> List<&2,P113DStmt>:
  match cases:
    case Nil{}: []
    case Con{head,rest}:
      Con{P113DScalar{N111Alloca{p112f_name(p114h_prefix(index),"scratch"),2048,8}},x192h_buffers(rest,U32.inc(index))}

@unsafe
def x192h_restore(captures: List<&2,String>, +index: U32, +prefix: String) -> List<&2,P113DStmt>:
  match captures:
    case Nil{}: []
    case Con{name,rest}:
      Con{x192h_stack("p111_rt_stack_get",p112f_name(prefix,name),index),x192h_restore(rest,U32.inc(index),prefix)}

# Runtime pop adjusts SP first; stack_get then reads the popped words. This is
# intentional, matching p114hs_case, not a conventional pop-returning-values API.
@unsafe
def x192h_case_prefix(+captures: List<&2,String>, result: String, +pop: String, +index: U32) -> List<&2,P113DStmt>:
  +count = nt_count(String,captures)
  +prefix = p114h_prefix(index)
  nt_append(P113DStmt,nt_choose(List<&2,P113DStmt>,U32.is_eq(count,0),u => [],
      u => [x192h_stack("p111_rt_stack_pop","p114h_popped",count)]),
    nt_append(P113DStmt,nt_choose(List<&2,P113DStmt>,String.is_empty(pop),u => [],
      u => [P113DScalar{N111Set{p112f_name(prefix,pop),N111U64{},x192h_c(0)}}]),
      nt_append(P113DStmt,x192h_restore(captures,0,prefix),
        [P113DScalar{N111Set{p112f_name(prefix,result),N111U64{},x192h_v("p114r_value")}}])))

def x198pw_put(+map: KDef,+role: String,name: String) -> KDef:
  index_set(map,KDef{role,"X198PWName",0,0,kt("Name",name,0,0,[]),atom("Absent"),[],False{},False{}},
    index_hash(role,2166136261),32)

def x198pw_bind(+slot: String,+id: U32,+s: X198PWState) -> X198PWState:
  match s:
    case X198PWState{roles,+vars}:
      +reverse = "#" ++ U32.show(id)
      nt_choose(X198PWState,p88_string_eq(dk(p111v_get(vars,slot)),"Absent") && p88_string_eq(dk(p111v_get(vars,reverse)),"Absent"),
        u => X198PWState{roles,p111v_put(p111v_put(vars,slot,"X198PWVar",id,0),reverse,"X198PWId",0,0)},u => X198PWBad{})
    case _: X198PWBad{}

@unsafe
def x198pw_mark(plans: List<&2,X198PWPlan>,ids: N111Ids) -> N111Ids:
  match plans ids:
    case Con{X198PWPlan{owner,leaf,node},rest} N111Ids{+fs,cs}:
      +key = x198pw_key("$direct." ++ owner)
      +entry : KDef = KDef{key,"X198PWCertified",0,0,kt("Name",leaf,0,0,[]),kt("Name",node,0,0,[]),[],False{},False{}}
      x198pw_mark(rest,N111Ids{nt_choose(KDef,agy_str_eq(dk(p111v_get(fs,key)),"Absent"),
        u => index_set(fs,entry,index_hash(key,2166136261),32),u => fs),cs})
    case _ N111Ids{fs,cs}: N111Ids{fs,cs}

@unsafe
def w4c_zip_set(plans: List<&2,AgyZipPlan>, +acc: KDef) -> KDef:
  match plans:
    case Nil{}: acc
    case Con{AgyZipPlan{+owner,_,_},rest}:
      +k = "$direct." ++ owner
      +e : KDef = KDef{k,"P113Direct",0,0,kt("Type","",0,0,[]),kt("Type","",0,0,[]),[],False{},False{}}
      w4c_zip_set(rest,index_set(acc,e,index_hash(k,2166136261),32))
    case Con{_,rest}: w4c_zip_set(rest,acc)

@unsafe
def agy_zip_mark(plans: List<&2,AgyZipPlan>, ids: N111Ids) -> N111Ids:
  match plans ids:
    case Con{AgyZipPlan{owner,leaf,node},rest} N111Ids{+fs,cs}:
      +key = agy_zip_key("$direct." ++ owner)
      +entry : KDef = KDef{key,"AgyZipCertified",0,0,kt("Name",leaf,0,0,[]),kt("Name",node,0,0,[]),[],False{},False{}}
      agy_zip_mark(rest,N111Ids{nt_choose(KDef,agy_str_eq(dk(p111v_get(fs,key)),"Absent"),
        u => index_set(fs,entry,index_hash(key,2166136261),32),u => fs),cs})
    case _ N111Ids{fs,cs}: N111Ids{fs,cs}

@unsafe
def agy_ro_mark(entries: List<&2,KDef>, ids: N111Ids) -> N111Ids:
  match entries ids:
    case Con{+entry,rest} N111Ids{+fs,cs}:
      +key = dn(entry)
      agy_ro_mark(rest,N111Ids{nt_choose(KDef,agy_str_eq(dk(p111v_get(fs,key)),"Absent"),
        u => index_set(fs,entry,index_hash(key,2166136261),32),u => fs),cs})
    case _ N111Ids{fs,cs}: N111Ids{fs,cs}

@unsafe
def agy_fl_mark(plans: List<&2,AgyFlowPlan>, ids: N111Ids) -> N111Ids:
  match plans ids:
    case Con{AgyFlowPlan{owner,leaf,node,warp,wn},rest} N111Ids{+fs,cs}:
      +key = agy_fl_key("$direct." ++ owner)
      +c0 : KDef = KDef{"w","Name",0,0,kt("Name",warp,0,0,[]),kt("Name",wn,0,0,[]),[],False{},False{}}
      +entry : KDef = KDef{key,"AgyFlowCertified",0,0,kt("Name",leaf,0,0,[]),kt("Name",node,0,0,[]),[c0],False{},False{}}
      agy_fl_mark(rest,N111Ids{nt_choose(KDef,agy_str_eq(dk(p111v_get(fs,key)),"Absent"),
        u => index_set(fs,entry,index_hash(key,2166136261),32),u => fs),cs})
    case _ N111Ids{fs,cs}: N111Ids{fs,cs}

@unsafe
def x193f_tail(+segment: N111Segment, +ready: KDef, +enabled: Bool) -> X193FBody:
  match segment:
    case N111Segment{+name,arity,+result,incoming,+flags,+body}:
      nt_choose(X193FBody,enabled && U32.is_eq(result,1) && U32.is_eq(flags,0) &&
          Bool.not(p112t_admitted(p112t_plan(segment))) && x193f_clean(body),
        u => x193f_workers(p112w_public(body,name,ready)),u => X193FBody{body,0,""})

@unsafe
def x193f_candidate(+segment: N111Segment, +ready: KDef, +tail: Bool, plan: P112FusionBody) -> X193FBody:
  match segment plan:
    case N111Segment{name,arity,result,incoming,flags,original} P112FusionBody{body,count,site}:
      x193f_tail(N111Segment{name,arity,result,incoming,flags,body},ready,tail)

# Exposed pure selection for finite controls. An unavailable legacy target
# refuses the complete candidate; no prefix or partially rewritten body escapes.
@unsafe
def x193f_checked(+candidate: X193FBody, +available: KDef) -> X193FBody:
  match candidate:
    case X193FBody{+body,calls,error}:
      X193FBody{body,calls,p111_first(error,p111_first(x181_hygiene_scalars(body),x181_program_scalars(body,available)))}

@unsafe
def x193fb_candidate(+segment: N111Segment, +ready: KDef, +tail: Bool, +plan: P112FusionBody) -> X193FBody:
  match segment plan:
    case N111Segment{name,arity,result,incoming,flags,+original} P112FusionBody{+body,+count,site}:
      nt_choose(X193FBody,U32.is_eq(count,0),u => x193f_candidate(segment,ready,tail,plan),u =>
        nt_choose(X193FBody,x193fb_budget(p112f_size(original),p112f_size(body)),
          v => x193f_candidate(segment,ready,tail,plan),v => x193f_tail(segment,ready,tail)))

law x181_program_data:
  for data: P111QData
  for +available: KDef
  X181Output


# Consume the original canonical total-word table certificate, before allocation.
# This is a transport of p126s_cells/p126i_catalogue, not a new evaluator.
@unsafe
def x195t_data_values(name: String, +last: U32, cells: Maybe<&2,List<&2,U32>>, available: KDef) -> X181Output:
  match cells:
    case Some{+values}:
      nt_choose(X181Output,U32.is_ge(last,3) && U32.is_lt(last,64) && U32.is_eq(nt_count(U32,values),U32.inc(last)),
        u => x181_program_data(P111QData{p126i_table_name(name),8,False{},p126s_data(values)},available),
        u => X181Output{[],"x195 table catalogue length mismatch"})
    case None{}: X181Output{[],"x195 table catalogue shape mismatch"}

@unsafe
def x195t_data_found(found: Maybe<&2,U32>, function: P113DFunction, available: KDef) -> X181Output:
  match found function:
    case None{} _: X181Output{[],""}
    case Some{last} P113DFunction{name,[NC_Binding{id,+word,kind}],result,public,body}:
      nt_choose(X181Output,U32.is_eq(result,1),
        u => x195t_data_values(name,last,p126s_cells(word,body,0),available),
        u => X181Output{[],"x195 table catalogue result mismatch"})
    case _ _: X181Output{[],"x195 table catalogue parameters mismatch"}

@unsafe
def x195t_data(+function: P113DFunction, tables: List<&2,P126ITable>, available: KDef) -> X181Output:
  match function:
    case P113DFunction{name,params,result,public,body}:
      x195t_data_found(p126i_lookup(tables,name),function,available)
# Consume the checked semantic bodies retained by P169 preparation. Renderer
# fusion/legacy workers are optional here: public adapters already call p113d.
# No QBE text is parsed. A raw reference to an unavailable legacy worker fails
# the entire output, including references carried as symbol values or data.

@unsafe
def x181_program_values(values: List<&2,N111Value>, +available: KDef) -> String:
  match values:
    case Nil{}: ""
    case Con{head,rest}: p111_first(x181_program_value(head,available),x181_program_values(rest,available))

@unsafe
def x181_program_args(args: List<&2,N111Arg>, +available: KDef) -> String:
  match args:
    case Nil{}: ""
    case Con{N111Arg{typ,value},rest}:
      p111_first(x181_program_value(value,available),x181_program_args(rest,available))

@unsafe
def x181_program_scalar(stmt: N111Stmt, +available: KDef) -> String:
  match stmt:
    case N111Set{name,typ,value}: x181_program_value(value,available)
    case N111Bin{name,typ,op,left,right}:
      p111_first(x181_program_value(left,available),x181_program_value(right,available))
    case N111Call{name,typ,symbol,args}:
      p111_first(x181_program_symbol(symbol,available),x181_program_args(args,available))
    case N111If{condition,yes,no}:
      p111_first(x181_program_value(condition,available),
        p111_first(x181_program_scalars(yes,available),x181_program_scalars(no,available)))
    case N111Return{value}: x181_program_value(value,available)
    case N111Load{name,typ,base,offset}: x181_program_value(base,available)
    case N111Store{typ,base,offset,value}:
      p111_first(x181_program_value(base,available),x181_program_value(value,available))
    case N111Offset{name,base,bytes}:
      p111_first(x181_program_value(base,available),x181_program_value(bytes,available))
    case N111Alloca{name,bytes,align}: ""

@unsafe
def x181_program_scalars(body: List<&2,N111Stmt>, +available: KDef) -> String:
  match body:
    case Nil{}: ""
    case Con{head,rest}: p111_first(x181_program_scalar(head,available),x181_program_scalars(rest,available))

@unsafe
def x181_program_stmt(stmt: P113DStmt, +available: KDef) -> String:
  match stmt:
    case P113DScalar{scalar}: x181_program_scalar(scalar,available)
    case P113DIf{condition,yes,no}:
      p111_first(x181_program_value(condition,available),
        p111_first(x181_program_stmts(yes,available),x181_program_stmts(no,available)))
    case P113DCall{destinations,target,args}: x181_program_values(args,available)
    case P113DResult{values}: x181_program_values(values,available)
    case P113DAgain{values}: x181_program_values(values,available)

@unsafe
def x181_program_stmts(body: List<&2,P113DStmt>, +available: KDef) -> String:
  match body:
    case Nil{}: ""
    case Con{head,rest}: p111_first(x181_program_stmt(head,available),x181_program_stmts(rest,available))

# Same import rule as p168j_forward_if. The extra signature check refuses a
# malformed cursor instead of selecting a different calling convention.
@unsafe
def agy_dp_put(env: KDef, name: String, token: U32) -> KDef:
  p111v_put(env,name,"AgyDpTok",token,0)

@unsafe
def agy_f32_put(env: KDef, +name: String, kind: String, expr: KTerm) -> KDef:
  +entry : KDef = KDef{name,kind,0,0,kt("None","",0,0,[]),expr,[],False{},False{}}
  index_set(env,entry,index_hash(name,2166136261),32)

@unsafe
def agy_da_mark(entries: List<&2,KDef>, ids: N111Ids) -> N111Ids:
  match entries ids:
    case Con{+entry,rest} N111Ids{+fs,cs}:
      +key = dn(entry)
      agy_da_mark(rest,N111Ids{nt_choose(KDef,agy_str_eq(dk(p111v_get(fs,key)),"Absent"),
        u => index_set(fs,entry,index_hash(key,2166136261),32),u => fs),cs})
    case _ N111Ids{fs,cs}: N111Ids{fs,cs}

@unsafe
def agy_bp_map_hash(+book: List<&2,KDef>, +seed: U32) -> U32:
  agy_bp_list(book,["Map.bit.u","Map.bit.chr","Map.bit.go.chr","Map.bit.go.rec","Map.bit.go","Map.bit.at","Map.bit","Map.msb.u.if","Map.msb.u","Map.diff.chr","Map.diff.step","Map.diff.fin","Map.diff","Map.put.go","Map.put","Map.ins.splice.bit","Map.ins.splice","Map.ins.go","Map.ins","Map.lo","Map.hi","Map.seek.go","Map.seek","Map.set.fin.go","Map.set.fin","Map.set.go","Map.set","Map.get.leaf","Map.get.go","Map.get","Map.pop.lo","Map.pop.hi","Map.pop.leaf","Map.pop.go","Map.pop","Map.del.fin","Map.del","String.eq","String.cmp","String.cmp.rec","String.cmp.fin"],seed)

@unsafe
def agy_bp_arr_hash(+book: List<&2,KDef>, +seed: U32) -> U32:
  agy_bp_list(book,["Array.to_list.go","Array.to_list"],seed)

@unsafe
def agy_bp_map_pinned(+book: List<&2,KDef>) -> Bool:
  U32.is_eq(agy_bp_map_hash(book,2166136261),1678702329) &&
  U32.is_eq(agy_bp_map_hash(book,33554467),992788723)

@unsafe
def agy_bp_arr_pinned(+book: List<&2,KDef>) -> Bool:
  U32.is_eq(agy_bp_arr_hash(book,2166136261),707040475) &&
  U32.is_eq(agy_bp_arr_hash(book,33554467),668870049)

@unsafe
def agy_bp_mark_ids(ids: N111Ids, +key: String) -> N111Ids:
  match ids:
    case N111Ids{+fs,cs}:
      +entry : KDef = KDef{key,"AgyBasePinned",0,0,atom("Absent"),atom("Absent"),[],False{},False{}}
      N111Ids{nt_choose(KDef,agy_str_eq(dk(p111v_get(fs,key)),"Absent"),
        u => index_set(fs,entry,index_hash(key,2166136261),32),u => fs),cs}

@unsafe
def agy_map_book_ok(+book: List<&2,KDef>) -> Bool:
  agy_bp_map_pinned(book) &&
  agy_map_has_ctor(book,"Map","MTip",0) &&
  agy_map_has_ctor(book,"Map","MLeaf",2) &&
  agy_map_has_ctor(book,"Map","MNode",3) &&
  agy_map_has_ctor(book,"String","SNil",0) &&
  agy_map_has_ctor(book,"String","SCon",2) &&
  agy_map_has_ctor(book,"Char","Chr",1) &&
  agy_map_has_ctor(book,"Sigma","Tuple",2) &&
  agy_map_has_def(book,"Map.set",5) &&
  agy_map_has_def(book,"Map.set.go",4) &&
  agy_map_has_def(book,"Map.seek",4) &&
  agy_map_has_def(book,"Map.put",5) &&
  agy_map_has_def(book,"Map.ins",6) &&
  agy_map_has_def(book,"Map.diff",2) &&
  agy_map_has_def(book,"Map.bit",2) &&
  agy_map_has_def(book,"Map.del",4) &&
  agy_map_has_def(book,"Map.pop",4) &&
  agy_map_has_def(book,"Map.get",4) &&
  agy_map_has_def(book,"Map.get.go",4)

@unsafe
def agy_map_mark_one(ids: N111Ids, +name: String, +kind: String) -> N111Ids:
  match ids:
    case N111Ids{+fs,cs}:
      +key = agy_map_key(name)
      +entry : KDef = KDef{key,kind,0,0,atom("Absent"),atom("Absent"),[],False{},False{}}
      N111Ids{nt_choose(KDef,agy_str_eq(dk(p111v_get(fs,key)),"Absent"),
        u => index_set(fs,entry,index_hash(key,2166136261),32),u => fs),cs}

@unsafe
def x181_program_data(data,available):
  match data:
    case P111QData{+name,alignment,exported,items}:
      x181_program_join(X181Output{[x188_table_head(name,alignment,exported)],""},
        x181_program_join(x181_program_data_items(items,available,[]),
          X181Output{[X188One{PSize{name}}],""}))

# Tail transfer preserves argc/argv and their normal SysV return address.
# The descriptor supplies all constructor identities, static words and effects.
@unsafe
def x181_stream_slice_checked(item: P111QDatum, rest: List<&2,P111QDatum>, available: KDef,
    remaining: U32, acc: List<&2,X188Seq>, error: String) -> X181StreamSlice:
  match error:
    case SNil{}:
      x181_stream_data_slice(rest,available,U32.sub(remaining,1),Con{x181_program_datum(item),acc})
    case SCon{head,tail}: X181StreamSlice{X188Empty{},[],SCon{head,tail}}

@unsafe
def x181_stream_slice_items(items: List<&2,P111QDatum>, +available: KDef,
    remaining: U32, acc: List<&2,X188Seq>) -> X181StreamSlice:
  match items:
    case Nil{}: X181StreamSlice{x188_finish(acc),[],""}
    case Con{+head,rest}:
      x181_stream_slice_checked(head,rest,available,remaining,acc,x181_stream_datum_error(head,available))

@unsafe
def x181_stream_data_slice(items: List<&2,P111QDatum>, available: KDef,
    remaining: U32, acc: List<&2,X188Seq>) -> X181StreamSlice:
  match remaining:
    case 0: X181StreamSlice{x188_finish(acc),items,""}
    case _: x181_stream_slice_items(items,available,remaining,acc)

@unsafe
def w5b_enc_spec_f(family: U32, width: U32, code: U32, extra: U32, prefix: U32,
    +operands: List<&2,X187Operand>, +offset: U32) -> X187Encoded:
  match family:
    case 17: x192_float_cvtt_operands(operands,offset)
    case _: x187_e_selected(X187Op{family,width,code,extra,prefix},operands,offset)

@unsafe
def x187_encode_spec(spec: X187Op, +operands: List<&2,X187Operand>, +offset: U32) -> X187Encoded:
  match spec:
    case X187Op{family,width,code,extra,prefix}: w5b_enc_spec_f(family,width,code,extra,prefix,operands,offset)
    case X187OpNone{}: x187_e_error()

@unsafe
def w5b_enc_off_ok(ok: Bool, +op: String, +operands: List<&2,X187Operand>, +offset: U32) -> X187Encoded:
  match ok:
    case True{}: x187_encode_spec(x187_e_spec(op),operands,offset)
    case False{}: x187_e_error()

@unsafe
def x187_encode(inst: X187Instruction, +offset: U32) -> X187Encoded:
  match inst:
    case X187Instruction{+op,+operands}:
      w5b_enc_off_ok(U32.is_le(offset,4294967280),op,operands,offset)

# Proposal only: integer CMOVcc, AT&T source first. Memory sources are read
# unconditionally. The32-bit form zeroes destination high32 even when false.
@unsafe
def x187_elf_sections(object: X187Object, symbols: X187ElfSymbols) -> X187ObjectResult:
  match object:
    case X187Object{text,rodata,data,items,relocations}:
      w7_elf_sections_fast(object,X187ElfSizes{nt_count(U32,text),nt_count(U32,rodata),nt_count(U32,data)},symbols)

@unsafe
def x187_build_name(+name: String, +build: X187Build) -> X187Build:
  match build:
    case X187Build{s,t,r,d,ts,rs,ds,+symbols,names,relocs,error}:
      nt_choose(X187Build,agy_str_eq(dk(p111v_get(symbols,name)),"Absent"),
        u => X187Build{s,t,r,d,ts,rs,ds,index_set(symbols,
          KDef{name,"X187Sym",0,0,KTerm{"","",0,0,[],[],0,0},atom("Absent"),[],False{},False{}},
          index_hash(name,2166136261),32),Con{name,names},relocs,error},u => build)

@unsafe
def x187_build_symbol_update(+name: String, +mode: U32, +value: U32, +build: X187Build, +old: KDef) -> X187Build:
  match build old:
    case X187Build{+s,t,r,d,ts,rs,ds,symbols,names,relocs,error}
      KDef{on,ok,+section,+offset,KTerm{tk,tn,+size,+kind,kids,removed,begin,end},ov,oc,+global,+defined}:
      nt_choose(X187Build,(U32.is_eq(mode,1) && defined) ||
          (U32.is_eq(mode,4) && (Bool.not(defined) || Bool.not(U32.is_eq(s,section)) || U32.is_lt(x187_build_offset(build),offset))),
        u => x187_build_error("duplicate symbol or invalid size: " ++ name,build),u =>
        X187Build{s,t,r,d,ts,rs,ds,index_set(symbols,
          KDef{name,"X187Sym",nt_choose(U32,U32.is_eq(mode,1),v => s,v => section),
            nt_choose(U32,U32.is_eq(mode,1),v => x187_build_offset(build),v => offset),
            KTerm{"","",nt_choose(U32,U32.is_eq(mode,4),v => U32.sub(x187_build_offset(build),offset),v => size),
              nt_choose(U32,U32.is_eq(mode,3),v => value,v => kind),[],[],0,0},atom("Absent"),[],
            global || U32.is_eq(mode,2),defined || U32.is_eq(mode,1)},index_hash(name,2166136261),32),names,relocs,error})
    case _ _: x187_build_error("invalid object symbol record",build)

@unsafe
def x201s_update(+hash: U32, +name: String, +mode: U32, +value: U32, +build: X187Build, +old: KDef) -> X187Build:
  match build old:
    case X187Build{+s,t,r,d,ts,rs,ds,symbols,names,relocs,error}
      KDef{on,ok,+section,+offset,KTerm{tk,tn,+size,+kind,kids,removed,begin,end},ov,oc,+global,+defined}:
      nt_choose(X187Build,(U32.is_eq(mode,1) && defined) ||
          (U32.is_eq(mode,4) && (Bool.not(defined) || Bool.not(U32.is_eq(s,section)) || U32.is_lt(x187_build_offset(build),offset))),
        u => x187_build_error("duplicate symbol or invalid size: " ++ name,build),u =>
        X187Build{s,t,r,d,ts,rs,ds,index_set(symbols,
          KDef{name,"X187Sym",nt_choose(U32,U32.is_eq(mode,1),v => s,v => section),
            nt_choose(U32,U32.is_eq(mode,1),v => x187_build_offset(build),v => offset),
            KTerm{"","",nt_choose(U32,U32.is_eq(mode,4),v => U32.sub(x187_build_offset(build),offset),v => size),
              nt_choose(U32,U32.is_eq(mode,3),v => value,v => kind),[],[],0,0},atom("Absent"),[],
            global || U32.is_eq(mode,2),defined || U32.is_eq(mode,1)},hash,32),names,relocs,error})
    case _ _: x187_build_error("invalid object symbol record",build)


law w7c_pub_check_scalars:
  for body: List<&2,N111Stmt>
  for +available: KDef
  String

@unsafe
def w7c_pub_check_scalar(stmt: N111Stmt, +available: KDef) -> String:
  match stmt:
    case N111Set{name,typ,value}: p111_first(x181_program_value(value,available),x181_hygiene_name(name))
    case N111Bin{name,typ,op,left,right}:
      p111_first(x181_program_value(left,available),p111_first(x181_program_value(right,available),x181_hygiene_name(name)))
    case N111Call{name,typ,symbol,args}:
      p111_first(x181_program_symbol(symbol,available),p111_first(x181_program_args(args,available),x181_hygiene_name(name)))
    case N111If{condition,yes,no}:
      p111_first(x181_program_value(condition,available),
        p111_first(w7c_pub_check_scalars(yes,available),w7c_pub_check_scalars(no,available)))
    case N111Return{value}: x181_program_value(value,available)
    case N111Load{name,typ,base,offset}: p111_first(x181_program_value(base,available),x181_hygiene_name(name))
    case N111Store{typ,base,offset,value}:
      p111_first(x181_program_value(base,available),x181_program_value(value,available))
    case N111Offset{name,base,bytes}:
      p111_first(x181_program_value(base,available),p111_first(x181_program_value(bytes,available),x181_hygiene_name(name)))
    case N111Alloca{name,bytes,align}: x181_hygiene_name(name)

@unsafe
def w7c_pub_check_scalars(body,available):
  match body:
    case Nil{}: ""
    case Con{head,rest}: p111_first(w7c_pub_check_scalar(head,available),w7c_pub_check_scalars(rest,available))

@unsafe
def w11_p114h_filter_segs_mod(segs: List<&2,N111Segment>, +direct: KDef, +weak_set: KDef,
    +acc: List<&2,N111Segment>) -> List<&2,N111Segment>:
  match segs:
    case Nil{}: nt_reverse(N111Segment,acc,[])
    case Con{+seg,+rest}:
      w11_p114h_filter_segs_mod(rest,direct,weak_set,
        nt_choose(List<&2,N111Segment>,agy_p114h_seg_eligible(seg,direct,missing()) && w11_seg_not_weak(seg,weak_set),
          u => Con{seg,acc},u => acc))

@unsafe
def w10_if_add_direct(fns: List<&2, P113DFunction>, acc: KDef) -> KDef:
  match fns:
    case Nil{}: acc
    case Con{P113DFunction{+name, params, result, public, body}, rest}:
      w10_if_add_direct(rest, p111v_put(acc, name, "D", 1, 0))

@unsafe
def w10_if_add_public(segs: List<&2, N111Segment>, acc: KDef) -> KDef:
  match segs:
    case Nil{}: acc
    case Con{N111Segment{+name, arity, result, incoming, flags, body}, rest}:
      w10_if_add_public(rest, p111v_put(acc, name, "P", 1, 0))

law w10_if_strip_suffix:
  for ds: List<&2, KDef>
  for +abi: W10IfAbi
  for +laws: KDef
  List<&2, KDef>

@unsafe
def w10_if_strip_one(+d: KDef, +rest: List<&2, KDef>, +abi: W10IfAbi, +laws: KDef) -> List<&2, KDef>:
  match d:
    case KDef{+name, +kind, +arity, +templates, +typ, +value, +ctors, +native, +unsafe}:
      nt_choose(List<&2, KDef>, agy_str_eq(name, "main"),
        u => w10_if_strip_suffix(rest, abi, laws),
        u => nt_choose(List<&2, KDef>, agy_str_eq(kind, "Def") && U32.is_eq(templates, 0) && p98_tag_eq(value, "Absent"),
          v =>
            +laws2 = p131i_insert(laws, d, index_hash(name, 2166136261))
            Con{KDef{name, kind, arity, templates, w10_if_zero_term(typ), w10_if_zero_term(value), Nil{}, True{}, unsafe}, w10_if_strip_suffix(rest, abi, laws2)},
          v => nt_choose(List<&2, KDef>, agy_str_eq(kind, "Def") && U32.is_eq(templates, 0) &&
              Bool.not(agy_str_eq(name, "kc") || agy_str_eq(name, "f_choose") || agy_str_eq(name, "nt_choose") || agy_str_eq(name, "p151_choose")),
            w =>
              +sig = nt_choose(KTerm, p98_tag_eq(typ, "Absent"), z => dt(p111v_get(laws, name)), z => typ)
              Con{KDef{name, kind, arity, templates, w10_if_zero_term(typ), w10_if_build_stub(d, sig, w10_if_force_cps(abi, name)), Nil{}, True{}, True{}}, w10_if_strip_suffix(rest, abi, laws)},
            w => Con{KDef{name, kind, arity, templates, w10_if_zero_term(typ), w10_if_zero_term(value), w10_if_strip_ctors(ctors), True{}, unsafe}, w10_if_strip_suffix(rest, abi, laws)})))
    case _: w10_if_strip_suffix(rest, abi, laws)

@unsafe
def w10_if_strip_suffix(ds, abi, laws):
  match ds:
    case Nil{}: Nil{}
    case Con{d, rest}: w10_if_strip_one(d, rest, abi, laws)

# --- Pure-Bend .p130 word-pair encoder (zero-copy right-cons + O(1) KDef cache) ---

# === AGY-W12E-FAST-IFACE-V2: Pure-Bend Fast x86-iface v2 ===
# Builds on Wave 11 (P5-D) with 3 major pure-Bend optimizations (0 new types, 0 C, 0 JS):
#   1. Zero-rm + Complete Multi-Cache .p130 encoder:
#      (a) Pre-allocates Nil{} at record 0 (O(1) w10_if_enc_nil) and emits all other records in
#          O(1) via w10_if_emit_rec (eliminates 425k-entry rm Patricia trie lookups/insertions).
#      (b) Complete KDef ID caching across all 6 world/ready views:
#          - unique_cache (non-dup s_book defs) seeds final_cache;
#          - final_cache (every def in world.final, incl. merged law+def) serves world.book;
#          - patch_cache (s_state.patches) + final_cache serves world.checked;
#          - last_cache (last-wins s_book defs) serves world.seen and ready.names.
#          Zero KDefs (neither 319 base.bend patches nor 889 law+def pairs) are re-encoded!
#      (c) Right-associated batch concatenation in w10_if_take_batch.
#   2. Incremental O(|suffix|) world & ready extension (w10_if_emit_extended + w10_if_book_put_fast):
#      When fresh_suffix contains only stubbed Defs (zero ADTs, as in m01..m10), extends
#      base_world and base_ready directly via book_put_many_cached without O(N) prefix validation,
#      base_prefix_resume_world, p86_checked_prefix, or base_prefix_world_prepare.
#   3. Upstream-stub fast-path in w10_if_fast_abi:
#      Strips Ann wrappers (w10_if_strip_ann) to classify already-stubbed upstream defs from
#      base_book in O(1) (direct stub -> insert into worker_sigs directly; CPS stub -> skip),
#      running p128br_scan and p113pl_candidates only on new suffix defs + non-stub Base defs.

@unsafe
def w10_if_intern_str(enc: W10IfEnc, +s: String) -> W10IfRes:
  match enc:
    case W10IfEnc{+sm, +sr, +sn, +rm, +rr, +rn}:
      +hit = p111v_get(sm, s)
      nt_choose(W10IfRes, agy_str_eq(dk(hit), "Absent"),
        u => W10IfRes{W10IfEnc{p111v_put(sm, s, "S", sn, 0), Con{w10_if_push_str(s), sr}, U32.inc(sn), rm, rr, rn}, sn},
        u => W10IfRes{W10IfEnc{sm, sr, sn, rm, rr, rn}, da(hit)})

@unsafe
def w10_if_mark_patches(ps: List<&2, KDef>, bad: KDef) -> KDef:
  match ps:
    case Nil{}: bad
    case Con{p, rest}:
      w10_if_mark_patches(rest, p111v_put(bad, dn(p), "B", 1, 0))

@unsafe
def w10_if_mark_dups(ds: List<&2, KDef>, +seen: KDef, +bad: KDef) -> KDef:
  match ds:
    case Nil{}: bad
    case Con{KDef{+name, _, _, _, _, _, _, _, _}, +rest}:
      nt_choose(KDef, w10_if_abi_has(seen, name),
        u => w10_if_mark_dups(rest, seen, p111v_put(bad, name, "B", 1, 0)),
        u => w10_if_mark_dups(rest, p111v_put(seen, name, "S", 1, 0), bad))
    case Con{_, rest}: w10_if_mark_dups(rest, seen, bad)

@unsafe
def w10_if_cache_put(h: KDef, +id: U32, +bad: KDef, +cache: KDef) -> KDef:
  match h:
    case KDef{+name, _, _, _, _, _, _, _, _}:
      nt_choose(KDef, w10_if_abi_has(bad, name),
        u => cache,
        u => p111v_put(cache, name, "C", id, 0))
    case _: cache

@unsafe
def w10_if_cache_put_any(h: KDef, +id: U32, +cache: KDef) -> KDef:
  match h:
    case KDef{+name, _, _, _, _, _, _, _, _}:
      p111v_put(cache, name, "C", id, 0)
    case _: cache

@unsafe
def w10_if_suffix_set(ds: List<&2, KDef>, acc: KDef) -> KDef:
  match ds:
    case Nil{}: acc
    case Con{d, rest}: w10_if_suffix_set(rest, p111v_put(acc, dn(d), "S", 1, 0))

