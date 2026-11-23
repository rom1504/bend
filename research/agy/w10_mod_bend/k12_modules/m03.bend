# Module m03 (K=12 acyclic topological split of wave8_unified/compiler.bend)
# defs=676 laws=81 sccs=505 deps=[m00,m01,m02] cross_imports=655 fid_base=15360..20479

law core_subst_stable_terms:
  for +ts: List<&2, KTerm>
  Bool

# Module: src/core/term.bend:421
law core_subst_stable_app:
  for +kids: List<&2, KTerm>
  for +removed: List<&2, String>
  Bool

# Module: src/core/term.bend:450
law index_bucket:
  for +ds: List<&2, KDef>
  for +name: String
  KDef

# Compressed persistent binary trie. Internal nodes carry one discriminating
# hash bit; leaves retain exact-name buckets for complete 32-bit collisions.

# Module: src/core/index.bend:20
law book_final_legacy:
  for +book: List<&2,KDef>
  for +done: List<&2,KDef>
  List<&2,KDef>

# Module: src/core/normalize.bend:23
law norm_stuck:
  for +t: KTerm
  for +x: KTerm
  for +args: List<&2, KTerm>
  for +left: U32
  for +fallback: KTerm
  KTerm

# Module: src/core/normalize.bend:189
law norm_min_right:
  for +a: KTerm
  for +b: KTerm
  KTerm

# Module: src/core/normalize.bend:235
law norm_max_book:
  for +book: List<&2, KDef>
  U32

# Module: src/core/normalize.bend:252
law norm_max_defs:
  for +todo: List<&2, KDef>
  for +bound: U32
  U32

# Module: src/core/normalize.bend:405
law norm_exact:
  for +a: KTerm
  for +b: KTerm
  Bool

# Module: src/core/normalize.bend:410
law kr_dependencies:
  for +d: KDef
  for +stops: List<&2, String>
  for +todo: List<&2, String>
  List<&2, String>

# Module: src/core/reach.bend:49
law kr_ctor_refs:
  for ctors: List<&2, KDef>
  for +todo: List<&2, String>
  List<&2, String>

# Module: src/core/reach.bend:54
law descend_go:
  for +a: KTerm
  for +p: KTerm
  U32

# Module: src/check/quantity.bend:12
law descend_fields:
  for +a: List<&2, KTerm>
  for +p: List<&2, KTerm>
  for +ord: U32
  for +index: U32
  KDescent

# Module: src/check/quantity.bend:19
law descend_field:
  for +a: List<&2, KTerm>
  for +p: List<&2, KTerm>
  for +ord: U32
  for +index: U32
  for +field: U32
  KDescent

# Module: src/check/quantity.bend:27
law descend_ctr:
  for +a: KTerm
  for +p: KTerm
  for +result: KDescent
  U32

# Module: src/check/quantity.bend:37
law descend_sub:
  for +a: KTerm
  for +ps: List<&2, KTerm>
  for +bad: U32
  for +index: U32
  U32

# Module: src/check/quantity.bend:44
law count_open:
  for +book: List<&2, KDef>
  U32

# Module: src/check/kernel.bend:309
law prefix_state_exact_defs:
  for +left: List<&2,KDef>
  for +right: List<&2,KDef>
  Bool

# Module: src/check/prefix-state.bend:15
law fpe_foreign:
  for +ts: FInput
  KTerm

# Module: src/front/flatten.bend:10
law f_var_rows:
  for +rows: List<&2, KTerm>
  for +v: KTerm
  List<&2, KTerm>

# Module: src/front/elaborate.bend:32
law f_hit_row:
  for +r: KTerm
  for +c: KTerm
  for +fields: List<&2, KTerm>
  for +v: KTerm
  KTerm

# Module: src/front/elaborate.bend:46
law f_float:
  for +s: String
  KTerm

# Module: src/front/literals_arrays.bend:12
law ffw_walk:
  for +term: KTerm
  for +env: List<&2,KTerm>
  for +next: U32
  for +stack: List<&2,FFFrame>
  FFresh

# Module: src/front/fresh_work.bend:18
law ffw_done:
  for +term: KTerm
  for +next: U32
  for +stack: List<&2,FFFrame>
  FFresh

# Module: src/front/fresh_work.bend:23
law ffw_frame:
  for +frame: FFFrame
  for +value: KTerm
  for +next: U32
  for +stack: List<&2,FFFrame>
  FFresh

# Module: src/front/fresh_work.bend:29
law ffw_kids:
  for +term: KTerm
  for +env: List<&2,KTerm>
  for +pending: List<&2,KTerm>
  for +built: List<&2,KTerm>
  for +next: U32
  for +stack: List<&2,FFFrame>
  FFresh

# Module: src/front/fresh_work.bend:37
law ffw_let:
  for +env: List<&2,KTerm>
  for +bodyenv: List<&2,KTerm>
  for +items: List<&2,KTerm>
  for +built: List<&2,KTerm>
  for +next: U32
  for +stack: List<&2,FFFrame>
  FFresh

# Module: src/front/fresh_work.bend:45
law ffw_let_tail:
  for +env: List<&2,KTerm>
  for +bodyenv: List<&2,KTerm>
  for +term: KTerm
  for +tail: List<&2,KTerm>
  for +built: List<&2,KTerm>
  for +next: U32
  for +stack: List<&2,FFFrame>
  FFresh

# Module: src/front/fresh_work.bend:120
law f_lambda_valid:
  for +a: KTerm
  for +body: KTerm
  for +cursor: U32
  KTerm

# Module: src/front/validate.bend:82
law f_alias_valid:
  for +s: String
  Bool

# Module: src/front/validate.bend:86
law f_valid_name:
  for +s: String
  Bool

# Module: src/front/validate.bend:140
law f_path_parts:
  for +s: String
  for +part: String
  for +parts: List<&2,String>
  for +abs: Bool
  String

# Module: src/load/graph.bend:14
law fpe_defs:
  for +ds: List<&2,KDef>
  KTerm

# Module: src/load/graph.bend:305
law fpe_defs_next:
  for +error: KTerm
  for +rest: List<&2,KDef>
  KTerm

# Module: src/load/graph.bend:316
law fpe_find:
  for +ds: List<&2,KDef>
  for +index: U32
  KTerm

# Module: src/load/graph.bend:320
law fpe_find_next:
  for +error: KTerm
  for +rest: List<&2,KDef>
  for +index: U32
  KTerm

# Module: src/load/graph.bend:325
law dg_snippet_lines:
  for +lines: List<&2, String>
  for +at: U32
  for +end: U32
  for +line: U32
  for +left: String
  for +length: U32
  String

# Module: src/diagnostic/trace.bend:4
law dg_constructor_names:
  for +ds: List<&2, KDef>
  String

# Module: src/diagnostic/produce.bend:28
law dg_adt_error:
  for +world: KWorld
  for +t: KTerm
  for +d: KDef
  KChecking

# Module: src/diagnostic/produce.bend:116
law j_u32:
  for +t: KTerm
  Maybe<&2, U32>

# Module: src/back/common/literals.bend:22
law j_count_constructors:
  for +ctors: List<&2, KDef>
  for +removed: List<&2, String>
  U32

# Module: src/back/js/shared-text.bend:16
law j_quote:
  for +s: String
  String

# Module: src/back/js/literals.bend:10
law j_string:
  for +t: KTerm
  for +acc: String
  Maybe<&2, String>

# Module: src/back/js/literals.bend:83
law j_string_head:
  for +head: KTerm
  for +tail: KTerm
  for +acc: String
  Maybe<&2, String>

# Module: src/back/js/literals.bend:93
law j_string_char:
  for +value: Maybe<&2, U32>
  for +tail: KTerm
  for +acc: String
  Maybe<&2, String>

# Module: src/back/js/literals.bend:107
law nc_context_pick:
  for +original: KDef
  for +annotated: KDef
  KDef

# Module: src/back/native/book.bend:16
law nc_context_has_cache:
  for annotated: List<&2, KDef>
  Bool

# Module: src/back/native/observer-emitter.bend:67
law driver_count_todos:
  for +book: List<&2,KDef>
  U32

# Module: src/driver/api.bend:45
law driver_owned_names:
  for +book: List<&2,KDef>
  for +names: List<&2,String>
  String

# Module: src/driver/api.bend:70
law driver_owned_name:
  for +book: List<&2,KDef>
  for +name: String
  Bool

# Module: src/core/term.bend:4
law p177s_entry:
  for t: KTerm
  for id: U32
  for value: KTerm
  KTerm

@unsafe
def subst(+t: KTerm, +id: U32, +v: KTerm) -> KTerm:
  p177s_entry(t,id,v)

# Module: src/core/term.bend:379
@unsafe
def core_subst_stable(
  +t: KTerm,
) -> Bool:
  match t:
    case KTerm{tag, name, id, quant, kids, removed, originBegin, originEnd}:
      kc(Bool, p88_string_eq(tag, "Var"), u => False{},
        u => kc(Bool, core_subst_stable_terms(kids),
          u => kc(Bool, p88_string_eq(tag, "App"),
            u => kc(Bool, p88_string_eq(name, "") && U32.is_eq(id, 0) && U32.is_eq(quant, 0), u => core_subst_stable_app(kids, removed), u => False{}),
            u => True{}),
          u => False{}))
    case KLambda{name, id, quant, kids, removed, begin, end, present}:
      core_subst_stable_terms(kids)
    case KLiteral{kind, number, text, literalBegin, literalEnd}:
      True{}

# Module: src/core/term.bend:444
@unsafe
def core_subst_stable_terms(ts):
  match ts:
    case Nil{}: True{}
    case Con{h, rest}:
      kc(Bool, core_subst_stable(h), u => core_subst_stable_terms(rest), u => False{})

# Module: src/core/term.bend:466
@unsafe
def core_subst_stable_app(kids, removed):
  match removed:
    case Con{h, rest}: False{}
    case Nil{}: core_subst_stable_app_kids(kids)

# Module: src/core/term.bend:472
@unsafe
def core_literal_step(+t: KTerm) -> KTerm:
  w7_br_7(p88_string_eq(nm(t), "Nat"), t)

# Module: src/core/term.bend:541
@unsafe
def w5_idx_bucket_if(ok: Bool, bucket: List<&2, KDef>, +name: String) -> KDef:
  match ok:
    case True{}: index_bucket(bucket, name)
    case False{}: missing()

@unsafe
def w5_idx_bkt_hit(hit: Bool, h: KDef, rest: List<&2, KDef>, +name: String) -> KDef:
  match hit:
    case True{}: h
    case False{}: index_bucket(rest, name)

# Module: src/core/index.bend:126
@unsafe
def index_bucket(ds, name):
  match ds:
    case Nil{}:
      missing()
    case Con{+h, rest}:
      w5_idx_bkt_hit(String.eq(dn(h), name), h, rest, name)

# Module: src/core/index.bend:134
@unsafe
def index_remove(
  +ds: List<&2, KDef>,
  +name: String,
) -> List<&2, KDef>:
  match ds:
    case Nil{}:
      Nil{}
    case Con{h, rest}:
      index_remove_step(h, rest, name, agy_str_eq(dn(h), name))

# Module: src/core/index.bend:145
@unsafe
def index_remove_step(
  +h: KDef, +rest: List<&2, KDef>, +name: String, +same: Bool,
) -> List<&2, KDef>:
  match same:
    case True{}: index_remove(rest, name)
    case False{}: Con{h, index_remove(rest, name)}

# Module: src/core/index.bend:153
law index_tip:
  for +tree: KDef
  for +hash: U32
  KDef

@unsafe
def w5_idx_tip_br(goLeft: Bool, left: KDef, right: KDef, +hash: U32) -> KDef:
  match goLeft:
    case True{}: index_tip(left, hash)
    case False{}: index_tip(right, hash)

@unsafe
def w5_idx_tip_node(isLeaf: Bool, +tree: KDef, +mask: U32, left: KDef, right: KDef, +hash: U32) -> KDef:
  match isLeaf:
    case True{}: tree
    case False{}: w5_idx_tip_br(U32.is_eq(U32.and(hash, mask), 0), left, right, hash)

@unsafe
def w5_idx_tip_kdef(isLeaf: Bool, +tree: KDef, +templates: U32, +hash: U32) -> KDef:
  match isLeaf:
    case True{}: tree
    case False{}: index_tip(index_child(tree, Bool.not(U32.is_eq(U32.and(hash, templates), 0))), hash)

@unsafe
def index_tip(tree, hash):
  match tree:
    case KDef{label, kind, arity, templates, typ, value, ctors, native, unsafe}:
      w5_idx_tip_kdef(U32.is_eq(templates, 0), tree, templates, hash)
    case KIndexLeaf{stored, bucket}: tree
    case KIndexNode{stored, mask, left, right}:
      w5_idx_tip_node(U32.is_eq(mask, 0), tree, mask, left, right, hash)

# U32 subtraction wraps: x & (0 - x) isolates its lowest set bit, or 0.

# Module: src/core/index.bend:169
@unsafe
def index_leaf(
  +d: KDef,
  +hash: U32,
  +ds: List<&2, KDef>,
) -> KDef:
  KIndexLeaf{hash, Con{d, index_remove(ds, dn(d))}}

# Module: src/core/index.bend:183
@unsafe
def w7_ctor_tree_of(+cache: KDef) -> KDef:
  w7_ctor_tree_list(dc(cache))

@unsafe
def book_final_large(
  +book: List<&2,KDef>,
  +remaining: U32,
) -> Bool:
  match book:
    case Nil{}: U32.is_eq(remaining, 0)
    case Con{h, rest}:
      kc(Bool, U32.is_eq(remaining, 0), u => True{}, u => book_final_large(rest, U32.sub(remaining, 1)))

# Malformed raw JavaScript names retain the legacy comparison demand order.
# Projection and Char.to_u32 do not throw on surrogate codepoints; only the
# unchanged legacy comparisons decide whether such input must fail.

# Module: src/core/index.bend:353
@unsafe
def book_final_names_valid(
  +book: List<&2,KDef>,
) -> Bool:
  match book:
    case Nil{}: True{}
    case Con{d, rest}:
      kc(Bool, book_final_name_valid(dn(d)),
        u => book_final_names_valid(rest), u => False{})

# Module: src/core/index.bend:373
@unsafe
def book_final_legacy(book, done):
  match book:
    case Nil{}: done
    case Con{d, rest}: book_final_legacy(rest, Con{d, index_remove(done, dn(d))})

# Batch an immutable declaration overlay. Retain the original sequential path
# for cache-valued declarations, malformed names and cache misses that disagree
# with the retained event list. Definition references/order are retained;
# event-list cell identity is not promised.

# Module: src/core/index.bend:434
@unsafe
def book_put_many_regular(+defs: List<&2,KDef>) -> Bool:
  match defs:
    case Nil{}: True{}
    case Con{d, rest}:
      kc(Bool, p88_string_eq(dk(d), "BookCache"),
        u => False{}, u => book_put_many_regular(rest))

# Module: src/core/index.bend:442
@unsafe
def w7_br_11(w7_c: Bool, +rest: List<&2,KDef>, +name: String) -> Bool:
  match w7_c:
    case True{}:
      p88_string_eq(dn(index_bucket(rest, name)), "")
    case False{}:
      True{}

@unsafe
def norm_stuck(t, x, args, left, fallback):
  w7_br_24(U32.is_eq(left, 0), t, x, args, fallback)

# Module: src/core/normalize.bend:196
@unsafe
def norm_min_right(a, b):
  w7_br_29(p98_tag_eq(b, "Qua"), a, b)

# Module: src/core/normalize.bend:224
@unsafe
def w7c_norm_max_defs(ds: List<&2, KDef>, +bound: U32) -> U32:
  match ds:
    case Nil{}: bound
    case Con{+h, rest}:
      +b1 = w7c_norm_max_term(dt(h), bound)
      +b2 = w7c_norm_max_term(dv(h), b1)
      +b3 = w7c_norm_max_defs(dc(h), b2)
      w7c_norm_max_defs(rest, b3)

@unsafe
def norm_max_book(book):
  w7c_norm_max_defs(book, 0)

# Module: src/core/normalize.bend:244
@unsafe
def norm_removed(
  +as: List<&2, String>,
  +bs: List<&2, String>,
  +le: Bool,
) -> Bool:
  w7_br_32(le, as, bs)

# Module: src/core/normalize.bend:287
@unsafe
def norm_max_defs(todo, bound):
  match todo:
    case Nil{}:
      bound
    case Con{h, rest}:
      norm_max_defs(norm_defs_join(dc(h), rest), norm_max(bound, norm_max(norm_max_term(dt(h)), norm_max_term(dv(h)))))

# Syntactic reflexivity precedes evaluation, as pointer reflexivity does in
# upstream. Cell contents are included; different stored values never match.

# Module: src/core/normalize.bend:426
@unsafe
def norm_exact(a, b):
  norm_exact_lists(Con{a, Nil{}}, Con{b, Nil{}})

# Module: src/core/normalize.bend:430
@unsafe
def norm_cmp_shared(+st: GState, +a: KTerm, +b: KTerm) -> Bool:
  p98_tag_eq(a,"GCell") && p98_tag_eq(b,"GCell") && g_class_same(st,ix(a),ix(b))

# Module: src/core/normalize.bend:555
@unsafe
def w7_br_67(w7_c: Bool, +classes: GClasses, +left: U32, +right: U32, +leftRank: U32, +rightRank: U32) -> GClasses:
  match w7_c:
    case True{}:
      g_class_put(classes,left,GClassEntry{right,leftRank})
    case False{}:
      g_class_put(g_class_raise(classes,left,leftRank,U32.is_eq(leftRank,rightRank)), right,GClassEntry{left,rightRank})

@unsafe
def w7_br_68(w7_c: Bool, +classes: GClasses, +left: U32, +right: U32, +leftRank: U32, +rightRank: U32) -> GClasses:
  match w7_c:
    case True{}:
      classes
    case False{}:
      w7_br_67(U32.is_lt(leftRank,rightRank), classes, left, right, leftRank, rightRank)

@unsafe
def w7_br_73(w7_c: Bool, +st: GState, +t: KTerm) -> GResult:
  match w7_c:
    case True{}:
      g_shared_head(t, g_share_terms(st, ks(t), Nil{}))
    case False{}:
      GResult{st, t}

@unsafe
def kr_dependencies(d, stops, todo):
  List.append(&2, String, kr_refs(dt(d), kr_ctor_refs(dc(d), kc(List<&2, String>, has_name(stops, dn(d)), u => Nil{}, u => kr_refs(dv(d), Nil{})))), todo)

# Module: src/core/reach.bend:112
@unsafe
def kr_ctor_refs(ctors, todo):
  match ctors:
    case Nil{}: todo
    case Con{d, rest}: kr_refs(dt(d), kr_ctor_refs(rest, todo))

# Module: src/core/reach.bend:118
@unsafe
def kp_name(+env: List<&2,KPName>, +name: String) -> String:
  match env:
    case Nil{}: name_key(name)
    case Con{KPName{n, id, depth}, rest}: kp_name(rest, name)
    case Con{KPFile{ns, aliases}, rest}: kp_file_name(ns, aliases, name, String.split(name, ':'))

# Module: src/core/pretty.bend:196
@unsafe
def kp_removed(
  xs: List<&2, String>,
  +env: List<&2, KPName>,
) -> String:
  match xs:
    case Nil{}: ""
    case Con{h, t}: " - " ++ kp_name(env, h) ++ "{}" ++ kp_removed(t, env)

# Module: src/core/pretty.bend:294
@unsafe
def kp_number(
  +t: KTerm,
) -> Maybe<&2, U32>:
  kc(Maybe<&2, U32>, core_literal(t) && (p88_string_eq(nm(t), "U32") || p88_string_eq(nm(t), "F32")), u => Some{kl_number(t)}, u => kc(Maybe<&2, U32>, (kp_is(t, "Ctr", "U32") || kp_is(t, "Ctr", "F32")) && U32.is_eq(terms_len(ks(t)), 1), u => kp_word(kid(t, 0), 1, 32, 0), u => None{}))

# Module: src/core/pretty.bend:326
@unsafe
def kp_float_show(
  +n: U32,
) -> String:
  kp_float_text(F32.show(kp_float(n)))

# Module: src/core/pretty.bend:339
@unsafe
def w7_br_103(w7_c: Bool, +n: U32) -> String:
  match w7_c:
    case True{}:
      "\\" ++ Char.show(Char.from_u32(n))
    case False{}:
      w7_br_102(U32.is_lt(n, 32) || U32.is_eq(n, 127) || (U32.is_ge(n, 55296) && U32.is_le(n, 57343)) || U32.is_gt(n, 1114111), n)

@unsafe
def w7_br_104(w7_c: Bool, +n: U32, +quote: U32) -> String:
  match w7_c:
    case True{}:
      "\\\\"
    case False{}:
      w7_br_103(U32.is_eq(n, quote), n)

@unsafe
def w7_br_145(w7_c: Bool, +a: KTerm, +p: KTerm) -> U32:
  match w7_c:
    case True{}:
      1
    case False{}:
      descend_go(strip(a), strip(p))

@unsafe
def descend(
  +q: U32,
  +a: KTerm,
  +p: KTerm,
) -> U32:
  w7_br_145(U32.is_eq(q, 0), a, p)

# Module: src/check/quantity.bend:121
@unsafe
def w7_br_147(w7_c: Bool, +a: KTerm, +p: KTerm) -> U32:
  match w7_c:
    case True{}:
      descend_ctr(a, p, kc(KDescent, p98_tag_eq(a, "Ctr") && p88_string_eq(nm(a), nm(p)) && U32.is_eq(terms_len(ks(a)), terms_len(ks(p))), u => descend_fields(ks(a), ks(p), 1, 0), u => KDescent{2, 4294967295}))
    case False{}:
      2

@unsafe
def w7_br_148(w7_c: Bool, +a: KTerm, +p: KTerm) -> U32:
  match w7_c:
    case True{}:
      w7_br_146(p98_tag_eq(a, "Var") && U32.is_eq(ix(a), ix(p)))
    case False{}:
      w7_br_147(p98_tag_eq(p, "Ctr"), a, p)

@unsafe
def w7_br_149(w7_c: Bool, +a: KTerm, +p: KTerm) -> U32:
  match w7_c:
    case True{}:
      descend_go(core_literal_step(a), p)
    case False{}:
      w7_br_148(p98_tag_eq(p, "Var"), a, p)

@unsafe
def descend_go(a, p):
  w7_br_149(core_literal(a) && p98_tag_eq(p, "Ctr"), a, p)

# Module: src/check/quantity.bend:130
@unsafe
def descend_fields(a, p, ord, index):
  match a:
    case Nil{}:
      KDescent{ord, 4294967295}
    case Con{h, t}:
      descend_field(t, terms_tail(p), ord, index, descend(1, h, terms_at(p, 0)))

# Module: src/check/quantity.bend:138
@unsafe
def w7_br_150(w7_c: Bool, +a: List<&2, KTerm>, +p: List<&2, KTerm>, +ord: U32, +index: U32, +field: U32) -> KDescent:
  match w7_c:
    case True{}:
      KDescent{2, index}
    case False{}:
      descend_fields(a, p, kc(U32, U32.is_eq(field, 1), u => ord, u => field), U32.inc(index))

@unsafe
def descend_field(a, p, ord, index, field):
  w7_br_150(U32.is_eq(field, 2), a, p, ord, index, field)

# Module: src/check/quantity.bend:142
@unsafe
def descend_ctr(a, p, result):
  match result:
    case KDescent{ord, bad}:
      kc(U32, U32.is_eq(ord, 2), u => descend_sub(a, ks(p), bad, 0), u => ord)

# Module: src/check/quantity.bend:156
@unsafe
def descend_sub(a, ps, bad, index):
  match ps:
    case Nil{}:
      2
    case Con{h, t}:
      kc(U32, U32.is_eq(index, bad), u => descend_sub(a, t, bad, U32.inc(index)), u => kc(U32, U32.is_eq(descend(1, a, h), 2), u => descend_sub(a, t, bad, U32.inc(index)), u => 0))

# Module: src/check/quantity.bend:164
@unsafe
def good(
  +r: KChecking,
) -> Bool:
  p88_string_eq(ce(r), "")

# Module: src/check/kernel.bend:567
@unsafe
def w7_br_153(w7_c: Bool, +r: KChecking, +t: KTerm, +ty: KTerm) -> KChecking:
  match w7_c:
    case True{}:
      KChecking{t, ty, cs(r), "", rw(r), rx(r)}
    case False{}:
      r

@unsafe
def checked(
  +r: KChecking,
  +t: KTerm,
  +ty: KTerm,
) -> KChecking:
  w7_br_153(good(r), r, t, ty)

# Module: src/check/kernel.bend:575
@unsafe
def w7_br_154(w7_c: Bool, +a: KChecking, +b: KChecking, +t: KTerm, +ty: KTerm, +join: Bool) -> KChecking:
  match w7_c:
    case True{}:
      KChecking{t, ty, uses_merge(cs(a), cs(b), join), "", rw(b), rx(b)}
    case False{}:
      b

@unsafe
def w7_br_170(w7_c: Bool, +t: KTerm, +ty: KTerm, +q: U32, +r: KChecking) -> KChecking:
  match w7_c:
    case True{}:
      kr_from(r, dg_quant_error(rw(r), "affine variable consumed more than allowed", nm(t), q, uses_get(cs(r), ix(t))))
    case False{}:
      KChecking{k_with_children(t, Con{ct(r), Nil{}}), ty, uses_del(cs(r), ix(t)), "", rw(r), rx(r)}

@unsafe
def remaining(
  +cs: List<&2, KDef>,
  +removed: List<&2, String>,
) -> List<&2, KDef>:
  match cs:
    case Nil{}:
      Nil{}
    case Con{h, t}:
      kc(List<&2, KDef>, has_name(removed, dn(h)), u => remaining(t, removed), u => Con{h, remaining(t, removed)})

# Module: src/check/kernel.bend:800
@unsafe
def declared(
  +d: KDef,
) -> KDef:
  KDef{dn(d), dk(d), da(d), dx(d), dt(d), {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, dc(d), db(d), du(d)}

# Module: src/check/kernel.bend:916
@unsafe
def check_open(
  +book: List<&2, KDef>,
) -> String:
  check_open_message(count_open(book))

# Module: src/check/kernel.bend:922
@unsafe
def count_open(book):
  match book:
    case Nil{}:
      0
    case Con{d, rest}:
      U32.add(kc(U32, p88_string_eq(dk(d), "Def") && p98_tag_eq(dv(d), "Absent") && Bool.not(db(d)), u => 1, u => 0), count_open(rest))

# Module: src/check/kernel.bend:930
@unsafe
def w7_br_191(w7_c: Bool, +d: KDef, +fill: KDef) -> KDef:
  match w7_c:
    case True{}:
      declared(fill)
    case False{}:
      d

@unsafe
def w7_br_200(w7_c: Bool, +t: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      foreign_tip(kid(strip(t), 1))
    case False{}:
      strip(t)

@unsafe
def foreign_tip(
  +t: KTerm,
) -> KTerm:
  w7_br_200(p98_tag_eq(strip(t), "All"), t)

# Module: src/check/kernel.bend:1019
@unsafe
def w7_br_214(w7_c: Bool, +d: KDef) -> U32:
  match w7_c:
    case True{}:
      U32.sub(da(d), dx(d))
    case False{}:
      0

@unsafe
def w7_br_215(w7_c: Bool, +d: KDef, +body: KTerm) -> U32:
  match w7_c:
    case True{}:
      0
    case False{}:
      w7_br_214(contains_self(Con{body, Nil{}}, dn(d)), d)

@unsafe
def kr_from(+origin: KChecking, +derived: KChecking) -> KChecking:
  KChecking{ct(derived), cy(derived), cs(derived), ce(derived), rw(origin), rx(origin)}

# Module: src/check/kernel.bend:1261
@unsafe
def w7_br_235(w7_c: Bool, +r: KChecking) -> KChecking:
  match w7_c:
    case True{}:
      kr_from(r, bad(rw(r), "nondecreasing self-call"))
    case False{}:
      r

@unsafe
def w7_br_239(w7_c: Bool, +t: KTerm) -> Bool:
  match w7_c:
    case True{}:
      p88_string_eq(nm(t), "") && U32.is_eq(ix(t), 0) && U32.is_eq(qt(t), 0) && core_subst_stable_app(ks(t), rm(t)) && Bool.not(p98_tag_eq(kid(t, 0), "Var"))
    case False{}:
      True{}

@unsafe
def sk_quote(+s: String) -> String:
  "\"" ++ String.reverse(sk_escape(s, "")) ++ "\""

# Module: src/check/specialize.bend:108
@unsafe
def sk_escape(+s: String, +acc: String) -> String:
  match s:
    case SNil{}: acc
    case SCon{c, rest}: sk_escape(rest, String.reverse(sk_char(c, Char.to_u32(c))) ++ acc)

# Module: src/check/specialize.bend:114
@unsafe
def prefix_state_exact_def(+a: KDef, +b: KDef) -> Bool:
  p88_string_eq(dn(a), dn(b)) && p88_string_eq(dk(a), dk(b)) && U32.is_eq(da(a), da(b)) && U32.is_eq(dx(a), dx(b)) && prefix_state_exact_bool(db(a), db(b)) && prefix_state_exact_bool(du(a), du(b)) && prefix_state_exact_term(dt(a), dt(b)) && prefix_state_exact_term(dv(a), dv(b)) && prefix_state_exact_defs(dc(a), dc(b))

# Module: src/check/prefix-state.bend:48
@unsafe
def prefix_state_exact_defs(left, right):
  match left right:
    case Nil{} Nil{}: True{}
    case Con{a, ar} Con{b, br}: kc(Bool, prefix_state_exact_def(a, b), u => prefix_state_exact_defs(ar, br), u => False{})
    case other_left other_right: False{}

# Module: src/check/prefix-state.bend:55
@unsafe
def base_prefix_names(+defs: List<&2,KDef>) -> Bool:
  match defs:
    case Nil{}: True{}
    case Con{d, rest}: kc(Bool, Bool.not(p88_string_eq(dn(d), "")) && Bool.not(String.contains(dn(d), "~")) && Bool.not(String.contains(dn(d), "$kernel.")) && (p88_string_eq(dk(d), "Def") || p88_string_eq(dk(d), "ADT") || p88_string_eq(dk(d), "Ctr")) && base_prefix_names(dc(d)), u => base_prefix_names(rest), u => False{})

# Module: src/check/prefix-state.bend:132
@unsafe
def base_prefix_native(+prefix: List<&2,KDef>) -> Bool:
  match prefix:
    case Nil{}: True{}
    case Con{d, rest}: kc(Bool, db(d), u => base_prefix_native(rest), u => False{})

# Module: src/check/prefix-state.bend:144
@unsafe
def base_prefix_world_raw(+book: List<&2,KDef>) -> List<&2,KDef>:
  match book:
    case Nil{}: Nil{}
    case Con{d, rest}: kc(List<&2,KDef>, p88_string_eq(dk(d), "BookCache"), u => rest, u => book)

# Module: src/check/prefix-state.bend:150
@unsafe
def base_prefix_stamp(+book: List<&2,KDef>, +bound: U32) -> U32:
  match book:
    case Nil{}: bound
    case Con{d, rest}: kc(U32, p88_string_eq(dk(d), "BookCache"), u => da(d), u => bound)

# Module: src/check/prefix-state.bend:156
@unsafe
def base_prefix_world_hash_disjoint(+suffix: List<&2,KDef>, +index: KDef) -> Bool:
  match suffix:
    case Nil{}: True{}
    case Con{d, rest}:
      +hash = index_hash(dn(d), 2166136261)
      +tip = index_tip(index, hash)
      kc(Bool, p88_string_eq(dk(tip), "Absent") || Bool.not(U32.is_eq(da(tip), hash)),
        u => base_prefix_world_hash_disjoint(rest, index), u => False{})

# Module: src/check/prefix-state.bend:331
@unsafe
def w7_br_291(w7_c: Bool, +t: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      {KTerm{"Qnt", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}
    case False{}:
      w7_br_290(p98_tag_eq(t, "Typ") || p98_tag_eq(t, "Qnt") || p98_tag_eq(t, "All"))

@unsafe
def f_lex_cursor(+s: String, +l: U32, +c: U32, +d: U32, +acc: List<&2,FToken>, +offset: U32, +previous: U32) -> List<&2,FToken>:
  p150l_cursor(s,l,c,d,acc,offset,previous)


# Compiler-local ASCII classification. Unsigned subtraction tests a bounded
# ASCII range; setting bit 5 folds uppercase ASCII into lowercase. Other Unicode
# codepoints cannot enter either ASCII range, including isolated surrogates.
# Base Char workers and exported runtime primitive semantics remain unchanged.

# Module: src/front/lexer.bend:292
@unsafe
def w7_br_305(w7_c: Bool, +term: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      f_context_syntax(term)
    case False{}:
      w7_br_304(p98_tag_eq(term, "Ref"), term)

@unsafe
def f_context_head(+term: KTerm) -> KTerm:
  w7_br_305(p98_tag_eq(term, "FName"), term)

# Module: src/front/contextual.bend:161
@unsafe
def f_context_constructor_done(+term: KTerm, +input: FInput, +resolved: KTerm) -> FParsed:
  w7_br_306(f_context_stop(resolved), term, input, resolved)

# Module: src/front/contextual.bend:177
@unsafe
def f_context_header(+d: KDef, +ns: String, +aliases: List<&2,KTerm>) -> KDef:
  +alias = f_alias(dn(d), aliases)
  KDef{f_choose(String, f_eq(alias, dn(d)), u => f_qual_name(dn(d), ns), u => alias), dk(d), da(d), dx(d), dt(d), atom("Absent"), f_context_headers(dc(d), ns, aliases), db(d), du(d)}

# Module: src/front/contextual.bend:250
@unsafe
def f_context_headers(+defs: List<&2,KDef>, +ns: String, +aliases: List<&2,KTerm>) -> List<&2,KDef>:
  match defs:
    case Nil{}: Nil{}
    case Con{d, rest}: Con{f_context_header(d, ns, aliases), f_context_headers(rest, ns, aliases)}

# Module: src/front/contextual.bend:256
@unsafe
def f_context_module(+d: KDef, +ns: String) -> KDef:
  KDef{f_choose(String, f_eq(dk(d), "ImportFill"), u => dn(d), u => f_qual_name(dn(d), ns)), f_choose(String, f_eq(dk(d), "ImportFill"), u => "Def", u => dk(d)), da(d), dx(d), dt(d), dv(d), f_context_modules(dc(d), ns), db(d), du(d)}

# Module: src/front/contextual.bend:478
@unsafe
def f_context_modules(+defs: List<&2,KDef>, +ns: String) -> List<&2,KDef>:
  match defs:
    case Nil{}: Nil{}
    case Con{d, rest}: Con{f_context_module(d, ns), f_context_modules(rest, ns)}

# Module: src/front/contextual.bend:484
@unsafe
def f_expect(
  +p: FParsed,
  +s: String,
) -> FParsed:
  match p:
    case FParsed{+n, +ts}:
      f_choose(FParsed, f_context_stop(n), u => FParsed{n, ts}, u => f_choose(FParsed, f_eq(f_tx(ts), s), u => FParsed{n, f_tl(ts)}, u => fpe_error(ts, "expected " ++ s, "'" ++ s ++ "'")))

# Module: src/front/parser.bend:178
@unsafe
def w7_atom_q(ok: Bool, +ts: FInput) -> FParsed:
  match ok:
    case True{}:
      FParsed{kt("Hol", f_tx(f_tl(ts)), 0, 0, Nil{}), f_tl(f_tl(ts))}
    case False{}:
      fpe_error(ts, "expected term", "a term")

@unsafe
def w7_locate_end(spaced: Bool, +ts: FInput) -> U32:
  match spaced:
    case True{}:
      f_begin(f_space(ts))
    case False{}:
      f_previous_end(ts)

@unsafe
def w7_locate_keep(keep: Bool, +n: KTerm, +begin: U32, +end: U32, +created: Bool, +ts: FInput) -> FParsed:
  match keep:
    case True{}:
      FParsed{n, ts}
    case False{}:
      FParsed{f_located_term(n, begin, end, created), ts}

@unsafe
def f_unmark(
  +ts: FInput,
) -> FInput:
  w7_br_323(U32.is_eq(f_quant(ts), 1), ts)

# Module: src/front/parser.bend:308
@unsafe
def w7_br_329(w7_c: Bool, +s: String) -> U32:
  match w7_c:
    case True{}:
      9
    case False{}:
      w7_br_328(f_eq(s, "<<") || f_eq(s, ">>op"), s)

@unsafe
def w7_br_330(w7_c: Bool, +s: String) -> U32:
  match w7_c:
    case True{}:
      8
    case False{}:
      w7_br_329(f_eq(s, ".&."), s)

@unsafe
def w7_br_346(w7_c: Bool, +s: String) -> String:
  match w7_c:
    case True{}:
      ".shrn"
    case False{}:
      w7_br_345(f_eq(s, ".&."), s)

@unsafe
def w7_br_347(w7_c: Bool, +s: String) -> String:
  match w7_c:
    case True{}:
      ".shln"
    case False{}:
      w7_br_346(f_eq(s, ">>op"), s)

@unsafe
def fpe_word(+ts: FInput, +legacy: String, +expected: String) -> FParsed:
  fpe_span(ts, f_prepend(FToken{"", f_line(ts), U32.add(f_col(ts), U32.from_nat(String.length(f_tx(ts)))), 0, f_end(ts), f_end(ts), f_end(ts)}, f_empty(ts)), legacy, expected, "")

# Module: src/front/parser.bend:590
@unsafe
def fpe_match_resolved(+source: String, +start: U32, +error: KTerm) -> KTerm:
  +head = kid(error, 0)
  +text = f_choose(String, U32.is_gt(start, 0) && U32.is_ge(kb(head), start) && U32.is_ge(ke(head), kb(head)) && U32.is_le(U32.sub(ke(head), start), dg_width(source)),
    u => fpe_source_slice(source, U32.sub(kb(head), start), U32.sub(ke(head), start)), u => nm(head))
  k_with_children(error, [kt("ParseMessage", fpe_match_message(text, ix(head)), 0, 0, Nil{})])

# Module: src/front/parser.bend:754
@unsafe
def f_find(
  +name: String,
  +book: List<&2, KDef>,
) -> KDef:
  match book:
    case Nil{}:
      KDef{name, "Missing", 0, 0, atom("Absent"), atom("Absent"), Nil{}, False{}, False{}}
    case Con{+d, ds}:
      f_find_next(name, d, ds, p137q_key_eq(name, d))

# Module: src/front/declarations.bend:253

@unsafe
def f_find_next(
  +name: String, +d: KDef, +ds: List<&2, KDef>, +same: Bool,
) -> KDef:
  match same:
    case True{}: d
    case False{}: f_find(name, ds)

# Module: src/front/declarations.bend:261
@unsafe
def f_law_bind(
  +clauses: List<&2, KTerm>,
  +ty: KTerm,
  +exists: String,
) -> KTerm:
  match clauses:
    case Nil{}:
      ty
    case Con{+c, cs}:
      f_choose(KTerm, f_eq(tg(c), "Exists"), u => f_app_span(kt_span("Ref", exists, 0, 1, Nil{}, kb(c), ke(c)), [kid(c, 0), k_lam(nm(c), ix(c), 1, [f_law_bind(cs, ty, exists)], kb(c), ke(c), False{})], kb(c), ke(c)), u => kt_span("All", nm(c), ix(c), qt(c), [kid(c, 0), f_law_bind(cs, ty, exists)], kb(c), ke(c)))

# Module: src/front/declarations.bend:445
@unsafe
def f_let_ann(
  +ty: KTerm,
  +p: FParsed,
  +begin: U32,
) -> FParsed:
  match p:
    case FParsed{v, ts}:
      FParsed{f_choose(KTerm, f_context_stop(v), u => v, u => kt_span("Ann", "", 0, 1, [v, ty], begin, f_begin(f_space(ts)))), ts}

# Module: src/front/declarations.bend:536
@unsafe
def f_def_fillable(+old: KDef) -> Bool:
  f_eq(dk(old), "Def") && f_eq(tg(dv(old)), "Absent") && Bool.not(db(old))

# Module: src/front/declarations.bend:617
@unsafe
def fpe_foreign(ts):
  w7_br_404(Char.is_eq(f_head(f_tx(ts)), '"'), ts)

# Module: src/front/declarations.bend:662
@unsafe
def f_var_rows(rows, v):
  match rows:
    case Nil{}:
      Nil{}
    case Con{+r, rs}:
      Con{kt("Row", "", 0, qt(r), [kt("Patterns", "", 0, 1, f_tail_terms(ks(kid(r, 0)))), f_choose(KTerm, U32.is_eq(qt(r), 0), u => kid(r, 1), u => f_pattern_sub(kid(r, 1), ix(f_rowpat(r)), v))]), f_var_rows(rs, v)}

# Module: src/front/elaborate.bend:134
@unsafe
def f_hit_row(r, c, fields, v):
  kt("Row", "", 0, qt(r), [kt("Patterns", "", 0, 1, norm_join(f_choose(List<&2, KTerm>, f_eq(tg(f_rowpat(r)), "Var"), u => fields, u => ks(f_rowpat(r))), f_tail_terms(ks(kid(r, 0))))), f_choose(KTerm, U32.is_eq(qt(r), 0), u => kid(r, 1), u => f_pattern_sub(f_choose(KTerm, f_eq(tg(f_rowpat(r)), "Var"), u => f_pattern_sub(kid(r, 1), ix(f_rowpat(r)), v), u => kid(r, 1)), ix(v), kt_span("Ctr", nm(c), 0, 1, fields, kb(c), ke(c))))])

# Module: src/front/elaborate.bend:146
@unsafe
def f_escape_code(
  +c: Char,
) -> U32:
  w7_br_422(Char.is_eq(c, 'n'), c)

# Module: src/front/elaborate.bend:188
@unsafe
def w7_pat_sub_var(hit: Bool, +t: KTerm, +kids: List<&2, KTerm>, +id: U32, +value: KTerm) -> KTerm:
  match hit:
    case True{}:
      f_pattern_value(value, kb(t), ke(t))
    case False{}:
      match kids:
        case Nil{}:
          t
        case Con{_, _}:
          k_with_children(t, f_pattern_subs(kids, id, value))

@unsafe
def w7_br_427(w7_c: Bool, +origin: KTerm, +rest: String, +offset: U32, +legacy: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      f_numeric_error(origin, f_tail(rest), U32.add(offset, 1), legacy)
    case False{}:
      w7_br_426(String.is_empty(rest), origin, rest, offset, legacy)

@unsafe
def f_numeric_error(+origin: KTerm, +rest: String, +offset: U32, +legacy: KTerm) -> KTerm:
  w7_br_427(f_ascii_digit(f_head(rest)), origin, rest, offset, legacy)

# Module: src/front/elaborate.bend:240
@unsafe
def f_error_defs(
  +ds: List<&2,KDef>,
) -> String:
  nm(fpe_defs(ds))

# Module: src/front/sugar.bend:197
@unsafe
def f_rewrite_context_body(+origin: KTerm, +begin: U32, +proof: KTerm, +xi: U32, +binder: KTerm, +motive: KTerm, +p: FParsed) -> FParsed:
  match p:
    case FParsed{body, ts}:
      +end = f_begin(f_space(ts))
      f_choose(FParsed, f_context_stop(body), u => p,
        u => FParsed{kt_span("Rwt", "", 0, 1, [proof, k_lam("_", xi, 1, [k_lam(nm(binder), ix(binder), 1, [motive], kb(origin), ke(origin), False{})], begin, end, False{}), body], begin, end), ts})

# Module: src/front/sugar.bend:272
@unsafe
def w7_br_454(w7_c: Bool, +t: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      k_with_children(t, [kid(t, 0), f_string_expand(kid(t, 1))])
    case False{}:
      t

@unsafe
def w7_br_455(w7_c: Bool, +t: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      f_string_expand(core_literal_step(t))
    case False{}:
      w7_br_454(p98_tag_eq(t, "Ctr") && p88_string_eq(nm(t), "SCon"), t)

@unsafe
def f_string_expand(+t: KTerm) -> KTerm:
  w7_br_455(core_literal(t) && p88_string_eq(nm(t), "String"), t)

# Module: src/front/literals_arrays.bend:61
@unsafe
def f_float(s):
  f_float_read(F32.read(s))

# Module: src/front/literals_arrays.bend:69
@unsafe
def f_nat_extend_value(+a: KTerm, +b: KTerm, +value: KTerm) -> KTerm:
  w7_br_464(core_nat(a) && core_nat(value) && U32.is_le(kl_number(value), U32.sub(4294967295, kl_number(a))), a, b, value)

# Module: src/front/literals_arrays.bend:131
@unsafe
def w7_br_470(w7_c: Bool, +term: KTerm, +offset: U32) -> KTerm:
  match w7_c:
    case True{}:
      f_array_nat_depth(kid(term, 0), U32.add(offset, 1))
    case False{}:
      kt("Error", "array count must be a natural power of two", 0, 0, Nil{})

@unsafe
def w7_br_471(w7_c: Bool, +term: KTerm, +offset: U32) -> KTerm:
  match w7_c:
    case True{}:
      f_power_bits(offset, 0)
    case False{}:
      w7_br_470(f_eq(tg(term), "Ctr") && f_eq(nm(term), "Succ") && U32.is_eq(terms_len(ks(term)), 1) && U32.is_lt(offset, 4294967295), term, offset)

@unsafe
def w7_br_472(w7_c: Bool, +term: KTerm, +offset: U32) -> KTerm:
  match w7_c:
    case True{}:
      f_power_bits(U32.add(kl_number(term), offset), 0)
    case False{}:
      w7_br_471(f_eq(tg(term), "Ctr") && f_eq(nm(term), "Zero") && List.is_empty(&2,KTerm,ks(term)), term, offset)

@unsafe
def f_array_nat_depth(+term: KTerm, +offset: U32) -> KTerm:
  w7_br_472(core_nat(term) && U32.is_le(kl_number(term), U32.sub(4294967295, offset)), term, offset)

# Module: src/front/literals_arrays.bend:181
@unsafe
def f_binding_head(+ts: FInput) -> Bool:
  (f_ascii_alpha(f_head(f_tx(ts))) || Char.is_eq(f_head(f_tx(ts)), '_') || f_eq(f_tx(ts), "+bind")) && Bool.not(f_reserved(f_tx(ts)))

# Module: src/front/fresh_work.bend:56
@unsafe
def f_fresh_stack(
  +term: KTerm,
  +env: List<&2,KTerm>,
  +next: U32,
) -> FFresh:
  ffw_walk(term, env, next, Nil{})

# Module: src/front/fresh_work.bend:63
@unsafe
def w7_br_489(w7_c: Bool, +term: KTerm, +env: List<&2,KTerm>, +next: U32, +stack: List<&2,FFFrame>) -> FFresh:
  match w7_c:
    case True{}:
      ffw_walk(k_with_span(kid(term, 1), kb(term), ke(term)), env, next, stack)
    case False{}:
      ffw_walk_existing(term, env, next, stack)

@unsafe
def ffw_walk(term, env, next, stack):
  w7_br_489(p98_tag_eq(term, "FName"), term, env, next, stack)

# Module: src/front/fresh_work.bend:66
@unsafe
def w7_ffw_var(isVar: Bool, +term: KTerm, +env: List<&2, KTerm>, +next: U32, +stack: List<&2, FFFrame>) -> FFresh:
  match isVar:
    case True{}:
      ffw_done(f_rename_var(term, env), next, stack)
    case False{}:
      ffw_kids(term, env, ks(term), Nil{}, next, stack)

@unsafe
def w7_ffw_all(isAll: Bool, +term: KTerm, +env: List<&2, KTerm>, +next: U32, +stack: List<&2, FFFrame>) -> FFresh:
  match isAll:
    case True{}:
      ffw_walk(kid(term, 0), env, U32.add(next, 1), Con{FFAllA{term, env, next}, stack})
    case False{}:
      ffw_kids(term, env, ks(term), Nil{}, next, stack)

@unsafe
def w7_ffw_lam(isLam: Bool, +term: KTerm, +env: List<&2, KTerm>, +next: U32, +stack: List<&2, FFFrame>) -> FFresh:
  match isLam:
    case True{}:
      ffw_walk(kid(term, 0), Con{kt("Map", "", ix(term), 0, [var(nm(term), next)]), env}, U32.add(next, 1), Con{FFLambda{term, next}, stack})
    case False{}:
      ffw_kids(term, env, ks(term), Nil{}, next, stack)

@unsafe
def w7_ffw_let(isLet: Bool, +tag: String, +term: KTerm, +env: List<&2, KTerm>, +next: U32, +stack: List<&2, FFFrame>) -> FFresh:
  match isLet:
    case True{}:
      ffw_let(env, env, ks(term), Nil{}, next, Con{FFOrigin{kb(term), ke(term)}, stack})
    case False{}:
      w7_ffw_lam(p88_string_eq(tag, "Lam"), term, env, next, stack)

@unsafe
def w7_ffw_funb(isUnb: Bool, +term: KTerm, +env: List<&2, KTerm>, +next: U32, +stack: List<&2, FFFrame>) -> FFresh:
  match isUnb:
    case True{}:
      ffw_done(term, next, stack)
    case False{}:
      ffw_kids(term, env, ks(term), Nil{}, next, stack)

@unsafe
def w7_ffw_fglob(isGlob: Bool, +tag: String, +term: KTerm, +env: List<&2, KTerm>, +next: U32, +stack: List<&2, FFFrame>) -> FFresh:
  match isGlob:
    case True{}:
      ffw_done(kt_span("Ref", nm(term), 0, 1, Nil{}, kb(term), ke(term)), next, stack)
    case False{}:
      w7_ffw_funb(p88_string_eq(tag, "FUnboundVar"), term, env, next, stack)

@unsafe
def w7_ffw_tag(c0: U32, +tag: String, +term: KTerm, +env: List<&2, KTerm>, +next: U32, +stack: List<&2, FFFrame>) -> FFresh:
  match c0:
    case 86:
      w7_ffw_var(p88_string_eq(tag, "Var"), term, env, next, stack)
    case 65:
      w7_ffw_all(p88_string_eq(tag, "All"), term, env, next, stack)
    case 76:
      w7_ffw_let(p88_string_eq(tag, "Let"), tag, term, env, next, stack)
    case 70:
      w7_ffw_fglob(p88_string_eq(tag, "FGlobal"), tag, term, env, next, stack)
    case _:
      ffw_kids(term, env, ks(term), Nil{}, next, stack)

@unsafe
def ffw_walk_existing(+term: KTerm, +env: List<&2,KTerm>, +next: U32, +stack: List<&2,FFFrame>) -> FFresh:
  match term:
    case KLiteral{_, _, _, _, _}:
      ffw_done(term, next, stack)
    case KLambda{name, id, _, _, _, _, _, _}:
      ffw_walk(kid(term, 0), Con{kt("Map", "", id, 0, [var(name, next)]), env}, U32.add(next, 1), Con{FFLambda{term, next}, stack})
    case KTerm{tag, _, _, _, _, _, _, _}:
      w7_ffw_tag(w7_char0(tag), tag, term, env, next, stack)

# Module: src/front/fresh_work.bend:75
@unsafe
def ffw_done(term, next, stack):
  match stack:
    case Nil{}:
      FFresh{term, next}
    case Con{frame, rest}:
      ffw_frame(frame, term, next, rest)

# Module: src/front/fresh_work.bend:82
@unsafe
def ffw_frame(frame, value, next, stack):
  match frame:
    case FFAllA{+term, +env, +id}:
      ffw_walk(kid(term, 1), Con{kt("Map", "", ix(term), 0, [var(nm(term), id)]), env}, next, Con{FFAllB{term, id, value}, stack})
    case FFAllB{+term, id, typ}:
      ffw_done(kt_span("All", nm(term), id, qt(term), [typ, value], kb(term), ke(term)), next, stack)
    case FFLambda{+term, id}:
      ffw_done(k_lam(nm(term), id, qt(term), [value], kb(term), ke(term), k_quantity_present(term)), next, stack)
    case FFKids{term, env, pending, built}:
      ffw_kids(term, env, pending, Con{value, built}, next, stack)
    case FFLetValue{env, bodyenv, +id, +binding, pending, built}:
      ffw_let(env, Con{kt("Map", "", ix(binding), 0, [var(nm(binding), id)]), bodyenv}, pending, Con{kt_span("Bind", nm(binding), id, qt(binding), [value], kb(binding), ke(binding)), built}, next, stack)
    case FFOrigin{begin, end}:
      ffw_done(k_with_span(value, begin, end), next, stack)
    case FFLetBody{built}:
      ffw_done(kt("Let", "", 0, 1, ffw_reverse_onto(built, [value])), next, stack)

# Module: src/front/fresh_work.bend:99
@unsafe
def ffw_kids(term, env, pending, built, next, stack):
  match pending:
    case Nil{}:
      ffw_done(k_with_children(term, List.reverse(&2,KTerm,built)), next, stack)
    case Con{head, rest}:
      ffw_walk(head, env, next, Con{FFKids{term, env, rest, built}, stack})

# Module: src/front/fresh_work.bend:106
@unsafe
def ffw_let(env, bodyenv, items, built, next, stack):
  match items:
    case Nil{}:
      ffw_done(kt("Error", "empty core let", 0, 0, Nil{}), next, stack)
    case Con{term, tail}:
      ffw_let_tail(env, bodyenv, term, tail, built, next, stack)

# Module: src/front/fresh_work.bend:113
@unsafe
def ffw_let_tail(env, bodyenv, term, tail, built, next, stack):
  match tail:
    case Nil{}:
      ffw_walk(term, bodyenv, next, Con{FFLetBody{built}, stack})
    case Con{head, rest}:
      ffw_walk(kid(term, 0), env, U32.add(next, 1), Con{FFLetValue{env, bodyenv, next, term, tail, built}, stack})

# Module: src/front/fresh_work.bend:126
@unsafe
def f_path_defs(
  +ds: List<&2,KDef>,
  +dir: String,
  +native: Bool,
) -> List<&2,KDef>:
  match ds:
    case Nil{}:
      Nil{}
    case Con{+d, rest}:
      Con{KDef{dn(d), dk(d), da(d), dx(d), dt(d), f_choose(KTerm, f_eq(tg(dv(d)), "Foreign"), u => f_path_term(dv(d), dir), u => dv(d)), f_path_defs(dc(d), dir, native), native || db(d), du(d)}, f_path_defs(rest, dir, native)}

# Module: src/front/families.bend:33
@unsafe
def w7_br_496(w7_c: Bool, +t: KTerm, +args: List<&2, KTerm>, +d: KDef) -> KTerm:
  match w7_c:
    case True{}:
      kt("Error", "a quantified datatype after + (+D<..> sets D's leading quantities to &2)", ix(t), 0, Nil{})
    case False{}:
      f_adt_fill(t, args, da(d), f_leading_quants(dt(d)))

@unsafe
def f_scope_app_span(+f: KTerm, +x: KTerm, +begin: U32, +end: U32) -> KTerm:
  w7_br_498(f_eq(tg(f), "Lam"), f, x, begin, end)

# Module: src/front/families.bend:65
@unsafe
def f_valid_ctor_head(+p: KTerm, +ctr: KDef) -> Maybe<&2,KTerm>:
  f_choose(Maybe<&2,KTerm>, f_eq(dk(ctr), "Missing"), u => Some{fpe_message_at(p, "unknown constructor pattern: " ++ nm(p), "a declared constructor (unknown: " ++ name_key(nm(p)) ++ ")")},
    u => f_choose(Maybe<&2,KTerm>, U32.is_eq(da(ctr), terms_len(ks(p))), u => None{}, u => Some{fpe_message_at(p, "constructor pattern field count differs: " ++ nm(p), "a " ++ name_key(nm(p)) ++ " pattern with " ++ U32.show(da(ctr)) ++ f_choose(String, U32.is_eq(da(ctr), 1), u => " field", u => " fields"))}))

# Module: src/front/validate.bend:75
@unsafe
def f_lambda_valid(a, body, cursor):
  w7_br_501(f_eq(tg(a), "Ref") && f_valid_name(nm(a)), a, body, cursor)

# Module: src/front/validate.bend:97
@unsafe
def f_alias_valid(s):
  (Char.is_alpha(f_head(s)) || Char.is_eq(f_head(s), '_')) && f_alias_chars(s) && Bool.not(f_reserved(s))

# Module: src/front/validate.bend:101
@unsafe
def f_valid_name(s):
  (f_ascii_alpha(f_head(s)) || Char.is_eq(f_head(s), '_')) && f_name_chars(s) && Bool.not(f_reserved(s))

# Module: src/front/validate.bend:149
@unsafe
def f_valid_var_pattern(+p: KTerm, +constructor: KDef) -> Maybe<&2,KTerm>:
  f_choose(Maybe<&2,KTerm>, f_valid_name(nm(p)), u => f_choose(Maybe<&2,KTerm>, f_eq(dk(constructor), "Missing"), u => None{}, u => Some{fpe_message_at(p, "a constructor pattern requires braces: " ++ nm(p), "a braced constructor pattern (" ++ name_key(nm(p)) ++ " is a constructor: write " ++ name_key(nm(p)) ++ "{}, or rename the binder)")}),
    u => Some{kt("Error", "reserved pattern binder: " ++ nm(p), 0, 0, Nil{})})

# Module: src/front/validate.bend:231
@unsafe
def f_import_local(+path: String) -> Bool:
  w7_br_510(String.starts_with(path, "/"), path)

# Module: src/load/imports.bend:46
@unsafe
def w7_br_514(w7_c: Bool, +ts: FInput) -> String:
  match w7_c:
    case True{}:
      "+"
    case False{}:
      w7_br_513(f_eq(f_tx(ts), ">op"), ts)

@unsafe
def f_path_normal(
  +s: String,
) -> String:
  f_path_parts(s, "", Nil{}, Char.is_eq(f_head(s), '/'))

# Module: src/load/graph.bend:95
@unsafe
def w7_br_515(w7_c: Bool, +s: String, +part: String, +parts: List<&2,String>, +abs: Bool) -> String:
  match w7_c:
    case True{}:
      f_path_parts(f_tail(s), "", f_path_push(part, parts), abs)
    case False{}:
      f_path_parts(f_tail(s), part ++ SCon{f_head(s), ""}, parts, abs)

@unsafe
def w7_br_516(w7_c: Bool, +s: String, +part: String, +parts: List<&2,String>, +abs: Bool) -> String:
  match w7_c:
    case True{}:
      f_path_join_parts(List.reverse(&2, String, f_path_push(part, parts)), f_choose(String, abs, u => "/", u => ""))
    case False{}:
      w7_br_515(Char.is_eq(f_head(s), '/'), s, part, parts, abs)

@unsafe
def f_path_parts(s, part, parts, abs):
  w7_br_516(String.is_empty(s), s, part, parts, abs)

# Module: src/load/graph.bend:99
@unsafe
def fpe_def(
  +d: KDef,
) -> KTerm:
  fpe_defs_next(fpe_terms([dt(d), dv(d)]), dc(d))

# Module: src/load/graph.bend:378
@unsafe
def fpe_defs(ds):
  match ds:
    case Nil{}: {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}
    case Con{head, tail}: fpe_defs_next(fpe_def(head), tail)

# Module: src/load/graph.bend:383
@unsafe
def w7_br_525(w7_c: Bool, +error: KTerm, +rest: List<&2,KDef>) -> KTerm:
  match w7_c:
    case True{}:
      fpe_defs(rest)
    case False{}:
      error

@unsafe
def fpe_defs_next(error, rest):
  w7_br_525(f_eq(tg(error), "Absent"), error, rest)

# Module: src/load/graph.bend:386
@unsafe
def fpe_find(ds, index):
  match ds:
    case Nil{}: {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}
    case Con{head, tail}: fpe_find_next(fpe_def(head), tail, index)

# Module: src/load/graph.bend:391
@unsafe
def w7_br_526(w7_c: Bool, +error: KTerm, +rest: List<&2,KDef>, +index: U32) -> KTerm:
  match w7_c:
    case True{}:
      fpe_find(rest, U32.add(index, 1))
    case False{}:
      kt("ParseOwner", "", index, 0, [error])

@unsafe
def fpe_find_next(error, rest, index):
  w7_br_526(f_eq(tg(error), "Absent"), error, rest, index)

# Module: src/load/graph.bend:394
@unsafe
def w7_br_532(w7_c: Bool, +d: KDef, +old: KDef) -> KDef:
  match w7_c:
    case True{}:
      KDef{dn(old), "ImportFill", da(d), dx(old), dt(old), dv(d), Nil{}, False{}, du(old) || du(d)}
    case False{}:
      KDef{dn(d), "Def", da(d), dx(d), kt("Error", "an imported definition must uniquely fill a non-native law with plain parameter names", 0, 0, Nil{}), dv(d), dc(d), db(d), du(d)}

@unsafe
def f_graph_fill(+d: KDef, +old: KDef) -> KDef:
  w7_br_532(f_eq(dk(old), "Def") && f_eq(tg(dv(old)), "Absent") && Bool.not(db(old)) && f_bare_params(ks(dt(d))) && U32.is_ge(da(d), dx(old)) && (Bool.not(f_eq(tg(dv(d)), "Foreign")) || U32.is_eq(dx(old), 0)), d, old)

# The first selected frontend Error keeps its existing traversal order. Located
# errors resolve directly through source ownership, including imported aliases.

# Module: src/load/graph.bend:466
@unsafe
def f_declared(
  +name: String,
  +book: List<&2, KDef>,
) -> Bool:
  match book:
    case Nil{}:
      False{}
    case Con{+d, ds}:
      f_choose(Bool, f_eq(name, dn(d)) && Bool.not(f_eq(dk(d), "ImportFill") || f_eq(dk(d), "Ctr")), u => True{}, u => f_declared(name, ds))

# Module: src/load/modules.bend:75
@unsafe
def f_fresh_prefix_exact_head(+a: KDef, +b: KDef) -> Bool:
  p88_string_eq(dn(a), dn(b)) && p88_string_eq(dk(a), dk(b)) && U32.is_eq(da(a), da(b)) && U32.is_eq(dx(a), dx(b)) && Bool.not(Bool.xor(db(a), db(b))) && Bool.not(Bool.xor(du(a), du(b))) && U32.is_eq(f_graph_count_defs(dc(a), 0), f_graph_count_defs(dc(b), 0)) && f_fresh_prefix_exact_terms([dt(a), dv(a)], [dt(b), dv(b)])

# Module: src/load/prefix.bend:37
@unsafe
def f_prefix_complete_seed(+source: FSource, +ns: String, +carrier: FPrefixGraph, +path: String, +text: String, +book: List<&2,KDef>) -> FPrefixCompletion:
  match carrier:
    case FPrefixGraph{graph, prefix, suffix, count, ready}:
      f_prefix_seed_completed(graph, ns, ready, book, f_complete_seed(source, graph, path, text, book))
    case FReadyPrefixGraph{graph, prefix, suffix, count, ready, names, ctors, baseNames}:
      f_prefix_seed_completed(graph, ns, ready, book, f_complete_seed(source, graph, path, text, book))

# Module: src/load/prefix.bend:133
@unsafe
def dg_snippet_lines(lines, at, end, line, left, length):
  match lines:
    case Nil{}: ""
    case Con{h, rest}:
      kc(String, U32.is_gt(line, end), u => "", u => kc(String, U32.is_lt(U32.add(line, 1), at), u => "", u => "\n" ++ dg_lpad(U32.show(line), dg_width(U32.show(end))) ++ kc(String, U32.is_eq(line, at), u => ">| " ++ h ++ "\n" ++ dg_marker(h, dg_width(U32.show(end)), left, length), u => " | " ++ h)) ++ dg_snippet_lines(rest, at, end, U32.add(line, 1), left, length))

# Module: src/diagnostic/render.bend:141
@unsafe
def w7_br_557(w7_c: Bool, +q: U32, +name: String, +site: KTerm, +r: KChecking) -> KChecking:
  match w7_c:
    case True{}:
      KChecking{kt("DTrace", nm(ct(r)), ix(ct(r)), qt(ct(r)), [kid(ct(r), 0), kid(ct(r), 1), kid(ct(r), 2), site, kt("DTrail", "", 0, 0, Con{site, ks(kid(ct(r), 4))}), kc(KTerm, U32.is_eq(q, 2), u => dg_text("Note: +" ++ name ++ " can be used many times, so its type must be Data."), u => kid(ct(r), 5))]), cy(r), cs(r), ce(r), rw(r), rx(r)}
    case False{}:
      r

@unsafe
def dg_report_payload(+term: KTerm, +error: String, +name: String) -> DDiagnostic:
  w7_br_558(p98_tag_eq(term, "DTrace"), term, error, name)

# Module: src/diagnostic/produce.bend:42
@unsafe
def dg_finish(
  +error: String,
  +book: List<&2, KDef>,
  +diagnostic: DDiagnostic,
  +origins: List<&2, DOrigin>,
) -> DResult:
  DResult{error, book, diagnostic_locate(diagnostic, origins)}

# One source-event checker carries semantic state and diagnostic metadata.

# Module: src/diagnostic/produce.bend:103
@unsafe
def w7_br_563(w7_c: Bool, +d: KDef, +body: KTerm) -> KDef:
  match w7_c:
    case True{}:
      KDef{dn(d), dk(d), da(d), dx(d), dt(d), body, dc(d), db(d), du(d)}
    case False{}:
      d

@unsafe
def dg_legacy_finish(+original: List<&2,KDef>, +origins: List<&2,DOrigin>, +book: List<&2,KDef>, +error: String) -> DResult:
  dg_finish(error, kc(List<&2,KDef>, p88_string_eq(error, ""), u => original, u => book), dg_no_report("", error), origins)

# Module: src/diagnostic/produce.bend:175
@unsafe
def dg_constructor_names(ds):
  match ds:
    case Nil{}: ""
    case Con{d, rest}: name_key(dn(d)) ++ kc(String, defs_empty(rest), u => "", u => ", " ++ dg_constructor_names(rest))

# Module: src/diagnostic/produce.bend:185
@unsafe
def w7_br_566(w7_c: Bool, +world: KWorld, +t: KTerm, +d: KDef) -> KChecking:
  match w7_c:
    case True{}:
      dg_bad_detail(world, "unknown family or wrong parameter count", dg_text(name_key(nm(t)) ++ " with " ++ U32.show(da(d)) ++ kc(String, U32.is_eq(da(d), 1), u => " parameter", u => " parameters")), t)
    case False{}:
      dg_bad_message(world, "unknown family or wrong parameter count", dg_text("a declared datatype (unknown: " ++ name_key(nm(t)) ++ ")"))

@unsafe
def dg_adt_error(world, t, d):
  w7_br_566(p88_string_eq(dk(d), "ADT"), world, t, d)

# Compatibility projections and explicit capability for hosts using one verdict.

# Module: src/diagnostic/produce.bend:205
@unsafe
def j_u32(t):
  j_u32_node(j_strip(t))

# Module: src/back/common/literals.bend:27
@unsafe
def j_count_constructors(ctors, removed):
  match ctors:
    case Nil{}:
      0
    case Con{d, rest}:
      U32.add(kc(U32, has_name(removed, dn(d)), u => 0, u => 1), j_count_constructors(rest, removed))

# Module: src/back/common/queries.bend:220
@unsafe
def j_escape(
  +s: String,
) -> String:
  match s:
    case SNil{}:
      ""
    case SCon{c, t}:
      j_escape_char(c) ++ j_escape(t)

# Module: src/back/js/shared-text.bend:21
@unsafe
def j_quote(s):
  "\"" ++ j_escape(s) ++ "\""

# Module: src/back/js/literals.bend:5
@unsafe
def j_string(t, acc):
  kc(Maybe<&2,String>, core_literal(t) && p88_string_eq(nm(t), "String"), u => Some{String.reverse(acc) ++ kl_text(t)}, u => kc(Maybe<&2, String>, p98_tag_eq(t, "Ctr"), u => kc(Maybe<&2, String>, p88_string_eq(nm(t), "SNil"), u => Some{String.reverse(acc)}, u => kc(Maybe<&2, String>, p88_string_eq(nm(t), "SCon"), u => j_string_head(j_strip(kid(t, 0)), j_strip(kid(t, 1)), acc), u => None{})), u => None{}))

# Module: src/back/js/literals.bend:90
@unsafe
def j_string_head(head, tail, acc):
  kc(Maybe<&2, String>, p98_tag_eq(head, "Ctr") && p88_string_eq(nm(head), "Chr"), u => j_string_char(j_u32(kid(head, 0)), tail, acc), u => None{})

# Module: src/back/js/literals.bend:100
@unsafe
def j_string_char(value, tail, acc):
  match value:
    case None{}:
      None{}
    case Some{n}:
      kc(Maybe<&2, String>, U32.is_le(n, 1114111) && (U32.is_lt(n, 55296) || U32.is_gt(n, 57343)), u => j_string(tail, SCon{Char.from_u32(n), acc}), u => None{})

# Module: src/back/js/literals.bend:112
@unsafe
def j_pure_native_ctor(+c: KDef, +name: String, +arity: U32) -> Bool:
  p88_string_eq(dk(c), "Ctr") && db(c) && p88_string_eq(dn(c), name) && U32.is_eq(da(c), arity) && U32.is_eq(dx(c), 0)

# Module: src/back/js/jpure.bend:440
@unsafe
def j_pure_closed_field(+ty: KTerm, +left: U32) -> KTerm:
  w7_br_616(p88_string_eq(nm(ty), "List"), ty, left)

# Module: src/back/js/jpure.bend:543
@unsafe
def j_fusion_empty(+d: KDef) -> KTerm:
  kid(j_strip(dv(d)), 0)

# Module: src/back/js/region.bend:889
@unsafe
def j_fusion_link(+d: KDef) -> KTerm:
  kid(j_strip(kid(j_strip(dv(d)), 1)), 0)

# Module: src/back/js/region.bend:893
@unsafe
def j_fusion_def(+d: KDef, +arity: U32) -> Bool:
  p88_string_eq(dk(d), "Def") && Bool.not(db(d)) && U32.is_eq(dx(d), 0) && U32.is_eq(da(d), arity)

# Module: src/back/js/region.bend:897
@unsafe
def j_fusion_choose(+d: KDef, +link: String) -> Bool:
  +t = j_fusion_after(dv(d), 2)
  +yes = j_strip(kid(t, 0))
  +no = j_strip(kid(t, 1))
  j_fusion_def(d, 3) && p98_tag_eq(j_fusion_binder(dv(d), 1), "Lam") &&
    j_fusion_cases(t, "True", "False") && j_fusion_ctor(yes, link, 2) &&
    j_fusion_var(kid(yes, 0), ix(j_fusion_binder(dv(d), 0))) &&
    j_fusion_var(kid(yes, 1), ix(j_fusion_binder(dv(d), 1))) &&
    j_fusion_var(kid(no, 0), ix(j_fusion_binder(dv(d), 1)))

# Module: src/back/js/region.bend:969
@unsafe
def nt_clean(+s: String) -> String:
  w5c2_clean_if(w5c2_is_clean(s), s)

# Module: src/back/native/text.bend:57
@unsafe
def nc_ctor_display(
  +name: String,
) -> String:
  w7_br_630(String.starts_with(name, "$ctor."), name)

# Module: src/back/native/identity.bend:74
@unsafe
def w5c2_ni_u32(+k: String) -> String:
  w5c2_str_pick(String.eq(k, "u32_add"), "U32_BIN($0, +, $1)",
  w5c2_str_pick(String.eq(k, "u32_sub"), "U32_BIN($0, -, $1)",
  w5c2_str_pick(String.eq(k, "u32_and"), "U32_BIN($0, &, $1)",
  w5c2_str_pick(String.eq(k, "u32_or"), "U32_BIN($0, |, $1)",
  w5c2_str_pick(String.eq(k, "u32_xor"), "U32_BIN($0, ^, $1)",
  w5c2_str_pick(String.eq(k, "u32_mul"), "U32_BIN($0, *, $1)",
  w5c2_str_pick(String.eq(k, "u32_is_eq"), "U32_BIN($0, ==, $1)",
  w5c2_str_pick(String.eq(k, "u32_is_ne"), "U32_BIN($0, !=, $1)",
  w5c2_str_pick(String.eq(k, "u32_is_lt"), "U32_BIN($0, <, $1)",
  w5c2_str_pick(String.eq(k, "u32_is_le"), "U32_BIN($0, <=, $1)",
  w5c2_str_pick(String.eq(k, "u32_is_gt"), "U32_BIN($0, >, $1)",
  w5c2_str_pick(String.eq(k, "u32_is_ge"), "U32_BIN($0, >=, $1)",
    w5c2_ni_u32_2(k)))))))))))))

@unsafe
def w5c2_ni_f32(+k: String) -> String:
  w5c2_str_pick(String.eq(k, "f32_add"), "f32_rewrap(f32_unbox($0) + f32_unbox($1))",
  w5c2_str_pick(String.eq(k, "f32_sub"), "f32_rewrap(f32_unbox($0) - f32_unbox($1))",
  w5c2_str_pick(String.eq(k, "f32_mul"), "f32_rewrap(f32_unbox($0) * f32_unbox($1))",
  w5c2_str_pick(String.eq(k, "f32_div"), "f32_rewrap(f32_unbox($0) / f32_unbox($1))",
  w5c2_str_pick(String.eq(k, "f32_is_eq"), "((u64)(f32_unbox($0) == f32_unbox($1)))",
  w5c2_str_pick(String.eq(k, "f32_is_ne"), "((u64)(f32_unbox($0) != f32_unbox($1)))",
  w5c2_str_pick(String.eq(k, "f32_is_lt"), "((u64)(f32_unbox($0) < f32_unbox($1)))",
  w5c2_str_pick(String.eq(k, "f32_is_le"), "((u64)(f32_unbox($0) <= f32_unbox($1)))",
  w5c2_str_pick(String.eq(k, "f32_is_gt"), "((u64)(f32_unbox($0) > f32_unbox($1)))",
  w5c2_str_pick(String.eq(k, "f32_is_ge"), "((u64)(f32_unbox($0) >= f32_unbox($1)))",
    w5c2_ni_f32_2(k)))))))))))

@unsafe
def w5c2_ni_n(ok: Bool, +c: U32, +k: String) -> String:
  match ok:
    case True{}: w5c2_ni_nat(k)
    case False{}: w5c2_ni_b(U32.is_eq(c, 98), k)

@unsafe
def nu_add(+s: NU_Set, +key: U32) -> NU_Set:
  match s:
    case NU_Empty{}: NU_Leaf{key}
    case _:
      +split = index_split_bit(U32.xor(key, nu_tip(s, key)))
      w5c2_nu_add_if(U32.is_eq(split, 0), s, key, split)

# Module: src/back/native/uses.bend:41
@unsafe
def nc_find_ctor_plain(+book: List<&2, KDef>, +name: String) -> KDef:
  match book:
    case Nil{}: missing()
    case Con{+d, +rest}:
      nt_choose(KDef, p88_string_eq(dn(d), name) && p88_string_eq(dk(d), "Ctr"), u => d,
        u => nc_find_ctor_next(rest, name, nc_find_ctor_plain(dc(d), name)))

# Module: src/back/native/bridge.bend:389
@unsafe
def w7_br_656(w7_c: Bool, +rest: List<&2, KDef>, +name: String, +found: KDef) -> KDef:
  match w7_c:
    case True{}:
      nc_find_ctor_plain(rest, name)
    case False{}:
      found

@unsafe
def nc_find_ctor_next(+rest: List<&2, KDef>, +name: String, +found: KDef) -> KDef:
  w7_br_656(p88_string_eq(dk(found), "Absent"), rest, name, found)

# First constructor in legacy depth-first order wins, including cache children.

# Module: src/back/native/bridge.bend:394
@unsafe
def nc_ctor_payload(children: List<&2, KDef>) -> KDef:
  match children:
    case Con{bodies, Con{+ctors, rest}}:
      nt_choose(KDef, p88_string_eq(dk(ctors), "NativeCtorIndex"), u => ctors, u => missing())
    case _: missing()

# Module: src/back/native/bridge.bend:414
@unsafe
def w5c2_pn_fallback(hit: String, +k: String) -> String:
  match hit:
    case SNil{}: w5c2_clean_lower(k)
    case SCon{a, b}: SCon{a, b}

@unsafe
def w5c2_arity_arr4(is4: Bool, +k: String) -> U32:
  match is4:
    case True{}: 4
    case False{}: w5c2_arity_arr3(U32.is_ne(nc_atomic(k), 0) || String.eq(k, "array_set") || String.eq(k, "array_swap"), k)

@unsafe
def w7_br_675(w7_c: Bool, +t: KTerm) -> NC_Literal:
  match w7_c:
    case True{}:
      NC_Literal{True{}, kl_number(t)}
    case False{}:
      w7_br_674(p88_string_eq(nm(t), "U32") || p88_string_eq(nm(t), "F32"), t)

@unsafe
def nd_comb_fresh(+body: KTerm, +args: List<&2, KTerm>, +env: List<&2, NC_Binding>, +n: U32, +left: U32) -> Bool:
  p143o_range(body,args,env,n,left)

@unsafe
def nf_expand_kinds(shapes: List<&2, KTerm>, kinds: List<&2, N_WordKind>) -> List<&2, N_WordKind>:
  match shapes, kinds:
    case Con{+shape, rest}, Con{kind, more}: nt_append(N_WordKind, nt_choose(List<&2, N_WordKind>, p98_tag_eq(shape, "NQShape"), u => w4c_shape_kinds(ix(shape), qt(shape), 0), u => [kind]), nf_expand_kinds(rest, more))
    case _, _: Nil{}

# Module: src/back/native/flat.bend:137
@unsafe
def nq_layout_specialize(+tel: KTerm, args: List<&2, KTerm>, +fuel: U32) -> KTerm:
  match args:
    case Nil{}: tel
    case Con{+arg, +rest}:
      nt_choose(KTerm, U32.is_eq(fuel, 0), u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, u => nq_layout_specialize_head(nq_layout_reduce(tel, 64), arg, rest, U32.sub(fuel, 1)))

# Module: src/back/native/product-layout.bend:133
@unsafe
def w7_br_705(w7_c: Bool, +head: KTerm, +arg: KTerm, +rest: List<&2, KTerm>, +fuel: U32) -> KTerm:
  match w7_c:
    case True{}:
      nq_layout_specialize(nq_layout_subst(kid(head, 1), ix(head), arg), rest, fuel)
    case False{}:
      {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}

@unsafe
def nq_layout_specialize_head(+head: KTerm, +arg: KTerm, +rest: List<&2, KTerm>, +fuel: U32) -> KTerm:
  w7_br_705(p98_tag_eq(head, "All") && nq_layout_subst_small(kid(head, 1), arg), head, arg, rest, fuel)

# Module: src/back/native/product.bend:4
@unsafe
def nq_pair_primitive(+name: String) -> Bool:
  U32.is_ne(nc_atomic(name), 0) || p88_string_eq(name, "array_size") || p88_string_eq(name, "array_clone") || p88_string_eq(name, "array_get") || p88_string_eq(name, "array_swap")

# Module: src/back/native/product.bend:87
@unsafe
def nq_signature_tele(+name: String, +arity: U32, +tele: KTerm) -> KDef:
  +ok = p98_tag_eq(tele, "NQTele") && nq_has_shape(ks(tele)) && U32.is_le(nq_shape_words(nc_tail_terms(ks(tele))), 64)
  KDef{name, "NQSignature", arity, 0, nt_choose(KTerm, ok, u => kid(tele, 0), u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}), nt_choose(KTerm, ok, u => kt("NQSig", "$product." ++ name, 0, 0, nc_tail_terms(ks(tele))), u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}), Nil{}, False{}, False{}}

# Module: src/back/native/product.bend:326
@unsafe
def nq_signature_cons(+d: KDef, +rest: List<&2, KDef>) -> List<&2, KDef>:
  nt_choose(List<&2, KDef>, p98_tag_eq(dv(d), "NQSig"),
    u => Con{d, Con{KDef{nm(dv(d)), "NQSignature", da(d), 0, dt(d), dv(d), Nil{}, False{}, False{}}, List.append(&2, KDef, nq_constructor_shapes(Con{dt(d), ks(dv(d))}), rest)}}, u => Con{d, rest})

# Module: src/back/native/product.bend:343
@unsafe
def nw_applicable(+mat: KTerm) -> Bool:
  w7_br_731(p98_tag_eq(mat, "Mat"), mat)

# Under a row's bit constraints, reconstructing its original scalar wrapper is
# the original low 32-bit value. Keep the value; materialize an escaping Word
# tail only if it remains used after beta substitution and this local rewrite.

# Module: src/back/native/word-pattern.bend:152
@unsafe
def w7_br_733(w7_c: Bool, +t: KTerm, +word: KTerm, +id: U32) -> KTerm:
  match w7_c:
    case True{}:
      var("", id)
    case False{}:
      nw_restore_children(t, word, id)

@unsafe
def w7_br_734(w7_c: Bool, +t: KTerm, +word: KTerm, +id: U32) -> KTerm:
  match w7_c:
    case True{}:
      w7_br_733(nw_same(kid(t, 0), word, Nil{}), t, word, id)
    case False{}:
      nw_restore_children(t, word, id)

@unsafe
def nw_restore(+t: KTerm, +word: KTerm, +id: U32) -> KTerm:
  w7_br_734(p98_tag_eq(t, "Ctr") && (p88_string_eq(nm(t), "U32") || p88_string_eq(nm(t), "F32")) && U32.is_eq(terms_len(ks(t)), 1), t, word, id)

# Module: src/back/native/word-pattern.bend:173
@unsafe
def nw_restore_children(+t: KTerm, +word: KTerm, +id: U32) -> KTerm:
  k_rebuild(t, nm(t), ix(t), qt(t), nw_restore_list(ks(t), word, id), rm(t), kb(t), ke(t))

# Module: src/back/native/word-pattern.bend:177
@unsafe
def nw_restore_list(ts: List<&2, KTerm>, +word: KTerm, +id: U32) -> List<&2, KTerm>:
  match ts:
    case Nil{}: Nil{}
    case Con{t, rest}: Con{nw_restore(t, word, id), nw_restore_list(rest, word, id)}

# Module: src/back/native/word-pattern.bend:253
@unsafe
def w5c2_nc_arr_known_go(is_a: Bool, +k: String) -> Bool:
  match is_a:
    case False{}: False{}
    case True{}:
      String.eq(k, "array_get") || String.eq(k, "array_set") || String.eq(k, "array_new") ||
      String.eq(k, "array_swap") || String.eq(k, "array_size") || String.eq(k, "array_clone") ||
      U32.is_ne(nc_atomic(k), 0)

@unsafe
def nv_owned(book: List<&2, KDef>) -> String:
  match book:
    case Nil{}: ""
    case Con{+d, +rest}:
      nt_choose(String, Bool.not(db(d)) && nb_contains(["IO", "Sigma", "String", "Word.Con", "IO.OP", "Result", "Poll", "Maybe", "Bool", "Unit", "Nat", "U32", "F32", "Char", "Array"], dn(d)),
        u => name_key(dn(d)) ++ " is a name the compiler encodes itself: name yours apart",
        u => nv_owned(rest))

# Module: src/back/native/book.bend:42
@unsafe
def nc_foreign(+d: KDef) -> Bool:
  p98_tag_eq(nc_unann(dv(d)), "Foreign") || p98_tag_eq(nc_unann(dv(d)), "Absent")

# Module: src/back/native/book.bend:70
@unsafe
def nc_has_ctor(cs: List<&2, N_Constructor>, +key: String) -> Bool:
  match cs:
    case Nil{}: False{}
    case Con{N_Constructor{k, a, h}, rest}: p88_string_eq(k, key) || nc_has_ctor(rest, key)

# Module: src/back/native/book.bend:189
@unsafe
def nc_add_ctors(cs: List<&2, N_Constructor>, +acc: List<&2, N_Constructor>) -> List<&2, N_Constructor>:
  match cs:
    case Nil{}: acc
    case Con{N_Constructor{+k, +a, +h}, rest}: nc_add_ctors(rest, nt_choose(List<&2, N_Constructor>, nc_has_ctor(acc, k), u => acc, u => List.append(&2, N_Constructor, acc, [N_Constructor{k, a, h}])))

# Module: src/back/native/book.bend:199
@unsafe
def nc_context_pick(original, annotated):
  w7_br_738(p88_string_eq(dk(annotated), "Absent"), original, annotated)

# Module: src/back/native/book.bend:356
@unsafe
def nc_context_has_cache(annotated):
  match annotated:
    case Nil{}: False{}
    case Con{head, rest}:
      nt_choose(Bool, p88_string_eq(dk(head), "BookCache"), u => True{}, u => nc_context_has_cache(rest))


# Observers require the pre-compaction source form, including typed literals.
# Retain that exact erased body through static preparation instead of erasing
# every expanded helper again. No fact means the original raw path is used.

# Module: src/back/native/book.bend:374
@unsafe
def ns_context(+book: List<&2, KDef>) -> KDef:
  match book:
    case Con{cache, rest}:
      nt_choose(KDef, p88_string_eq(dk(cache), "BookCache"), u => ns_payload(dc(cache)), u => missing())
    case _: missing()

# Module: src/back/native/static.bend:33
@unsafe
def ns_payload(children: List<&2, KDef>) -> KDef:
  match children:
    case Con{source, Con{+facts, rest}}:
      nt_choose(KDef, p88_string_eq(dk(facts), "NativeStaticContext") && p88_string_eq(dn(facts), "$native.static"), u => facts, u => missing())
    case _: missing()

# Module: src/back/native/static.bend:40
@unsafe
def ns_constant(+t: KTerm) -> Bool:
  w7_br_741(p98_tag_eq(t, "NStatic"), t)

# Module: src/back/native/static.bend:85
@unsafe
def ns_constants(ts: List<&2, KTerm>) -> Bool:
  match ts:
    case Nil{}: True{}
    case Con{h, rest}: nt_choose(Bool, ns_constant(h), u => ns_constants(rest), u => False{})

# An immediate U32 payload is within LOC_MASK. Other one-field constructors
# retain a box; no type annotation or raw width promise licenses packing.

# Module: src/back/native/static.bend:112
@unsafe
def ns_packed_fields(+t: KTerm, fields: List<&2, KTerm>) -> Bool:
  match fields:
    case Nil{}: True{}
    case Con{+h, Nil{}}:
      nt_choose(Bool, String.starts_with(nm(t), "$ctor.") && p98_tag_eq(h, "NWord"), u => ns_constant(h), u => False{})
    case _: False{}

# Native Bool and Char constructors have immediate runtime representations.
# Exact syntax/arity preserves malformed wrappers' original fallback.

# Module: src/back/native/static.bend:188
@unsafe
def w7_br_763(w7_c: Bool, +t: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      core_literal_step(t)
    case False{}:
      {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}

@unsafe
def noa_origins(values: List<&2, KTerm>) -> List<&2, KTerm>:
  match values:
    case Nil{}: Nil{}
    case Con{+h, +rest}: Con{noa_origin(h), noa_origins(rest)}

# Module: src/back/native/observer-analysis.bend:317
@unsafe
def agy_dr_ctor_refs(ctors: List<&2, KDef>, +todo: List<&2, String>) -> List<&2, String>:
  match ctors:
    case Nil{}: todo
    case Con{d, rest}: agy_dr_refs(dt(d), agy_dr_ctor_refs(rest, todo))

@unsafe
def agy_dr_deps(+d: KDef, +todo: List<&2, String>) -> List<&2, String>:
  agy_dr_refs(dt(d), agy_dr_ctor_refs(dc(d), agy_dr_refs(dv(d), todo)))

@unsafe
def driver_count_todos(book):
  match book:
    case Nil{}: 0
    case Con{d, rest}:
      U32.add(kc(U32, p88_string_eq(dk(d), "Def") && p98_tag_eq(dv(d), "Absent") && Bool.not(db(d)), u => 1, u => U32.add(driver_holes(dt(d)), driver_holes(dv(d)))), U32.add(driver_count_todos(dc(d)), driver_count_todos(rest)))

# Module: src/driver/api.bend:50
@unsafe
def driver_owned_candidates(+book: List<&2,KDef>) -> List<&2,KDef>:
  match book:
    case Nil{}: Nil{}
    case Con{d, rest}: kc(List<&2,KDef>, db(d),
      u => driver_owned_candidates(rest), u => Con{d, driver_owned_candidates(rest)})

# Module: src/driver/api.bend:93
@unsafe
def driver_owned_names(book, names):
  match names:
    case Nil{}: ""
    case Con{name, rest}:
      kc(String, driver_owned_name(book, name),
        u => name_key(name) ++ " is a name the compiler encodes itself: name yours apart",
        u => driver_owned_names(book, rest))

# Module: src/driver/api.bend:112
@unsafe
def driver_owned_name(book, name):
  match book:
    case Nil{}: False{}
    case Con{d, rest}:
      (p88_string_eq(dn(d), name) && Bool.not(db(d))) || driver_owned_name(rest, name)

# Module: src/driver/api.bend:125
@unsafe
def driver_program_complete(+book: List<&2,KDef>, +origins: List<&2,DOrigin>, +error: String) -> DResult:
  dg_finish(error, book, dg_no_report("", error), origins)

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:42
@unsafe
def p88_text(cursor: P88Cursor) -> P88TextRead:
  p88_text_size(p88_u32(cursor))

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:67
@unsafe
def p88_head_at(state: P88State, n: U32, string: Bool) -> P88Step:
  match string:
    case True{}: p88_string_at(state, U32.sub(n, 2147483648))
    case False{}: p88_node_at(state, n, 13)

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:168
@unsafe
def p205_signature(+t: KTerm, args: List<&2,String>) -> Bool:
  match args:
    case Con{arg,Nil{}}: p205_ty(t,arg)
    case Con{arg,rest}: p98_tag_eq(t,"All") && U32.is_ne(qt(t),0) && p205_ty(kid(t,0),arg) && p205_signature(kid(t,1),rest)
    case _: False{}

@unsafe
def p205u_binders(+body: KTerm, +owner: String, +arity: U32, +index: U32) -> Bool:
  +tail = kid(body,0)
  +call = p205u_call(kid(tail,0),owner)
  +arg = p205u_at(ks(call),index)
  p98_tag_eq(body,"Lam") && p98_tag_eq(tail,"Lam") &&
    U32.is_eq(p205u_refs(body,owner),1) && U32.is_eq(p205u_vars(kid(tail,0),ix(tail)),1) &&
    p98_tag_eq(call,"Call") && U32.is_eq(terms_len(ks(call)),arity) &&
    p98_tag_eq(arg,"Var") && U32.is_eq(ix(arg),ix(tail))

@unsafe
def p205u_literal_def(+d: KDef) -> KTerm:
  +t = j_strip(dv(d))
  kc(KTerm,agy_str_eq(dk(d),"Def") && U32.is_eq(da(d),0) && U32.is_eq(dx(d),0) && Bool.not(db(d) || du(d)) &&
    core_literal(t) && agy_str_eq(nm(t),"String"),u => t,u => atom("Absent"))
@unsafe
def p205u_field_join( +term: KTerm, +good: Bool, +rest: P205UFields) -> P205UFields:
  match rest:
    case P205UFields{terms,next,steps,ok}: P205UFields{Con{term,terms},next,steps,good && ok}
@unsafe
def p205u_room( +todo: List<&2,KTerm>, +fuel: U32) -> Bool:
  match todo fuel:
    case Nil{} _: True{}
    case _ 0: False{}
    case Con{t,rest} _: p205u_room(nt_append(KTerm,p205u_children(t),rest),U32.sub(fuel,1))
@unsafe
def p205u_record(+change: KDef, +used: Bool) -> P205UPick:
  P205UPick{change,used || Bool.not(agy_str_eq(dk(change),"Absent"))}
@unsafe
def w7_br_833(w7_c: Bool, +op: String, +a: U32, +b: U32) -> CtfeVal:
  match w7_c:
    case True{}:
      ctfe_bool(U32.is_le(a, b))
    case False{}:
      w7_br_832(agy_str_eq(op, "u32_is_gt"), op, a, b)

@unsafe
def w7_br_852(w7_c: Bool, +op: String, +a: U32, +b: U32) -> CtfeVal:
  match w7_c:
    case True{}:
      ctfe_bool(U32.is_eq(a, b))
    case False{}:
      w7_br_851(agy_str_eq(op, "nat_is_lt"), op, a, b)

@unsafe
def w7_br_860(w7_c: Bool, +op: String, +a: F32, +b: F32) -> CtfeVal:
  match w7_c:
    case True{}:
      ctfe_bool(F32.is_le(a, b))
    case False{}:
      w7_br_859(agy_str_eq(op, "f32_is_gt"), op, a, b)

@unsafe
def w7_br_861(w7_c: Bool, +op: String, +a: F32, +b: F32) -> CtfeVal:
  match w7_c:
    case True{}:
      ctfe_bool(F32.is_lt(a, b))
    case False{}:
      w7_br_860(agy_str_eq(op, "f32_is_le"), op, a, b)

@unsafe
def ctfe_pack_ctr(+cname: String, +vs: List<&2, CtfeVal>) -> CtfeVal:
  w7_br_871(agy_str_eq(cname, "U32") || agy_str_eq(cname, "F32"), cname, vs)

@unsafe
def w7_br_875(w7_c: Bool, +owner: String, +v: CtfeVal) -> KTerm:
  match w7_c:
    case True{}:
      ctfe_reify_char(v)
    case False{}:
      w7_br_874(agy_str_eq(owner, "String"), v)

@unsafe
def w7_br_876(w7_c: Bool, +owner: String, +v: CtfeVal) -> KTerm:
  match w7_c:
    case True{}:
      ctfe_reify_bool(v)
    case False{}:
      w7_br_875(agy_str_eq(owner, "Char"), owner, v)

law agy_abs_wrap_let_kids:
  for xs: List<&2,KTerm>
  for +fname: String
  for +p_lam: KTerm
  for +r_lams: List<&2,KTerm>
  for +st_idx: U32
  List<&2,KTerm>

@unsafe
def w7_br_885(w7_c: Bool, +t: KTerm, +fname: String, +p_lam: KTerm, +r_lams: List<&2,KTerm>, +st_idx: U32) -> KTerm:
  match w7_c:
    case True{}:
      k_with_children(t,agy_abs_wrap_let_kids(ks(t),fname,p_lam,r_lams,st_idx))
    case False{}:
      agy_abs_rec_call(fname,p_lam,r_lams,st_idx,t)

@unsafe
def agy_abs_wrap_tail(+t: KTerm, +fname: String, +p_lam: KTerm, +r_lams: List<&2,KTerm>, +st_idx: U32) -> KTerm:
  w7_br_885(p98_tag_eq(t,"Let") && U32.is_gt(terms_len(ks(t)),0), t, fname, p_lam, r_lams, st_idx)

@unsafe
def agy_abs_wrap_let_kids(xs, fname, p_lam, r_lams, st_idx):
  match xs:
    case Nil{}: []
    case Con{x,Nil{}}: [agy_abs_wrap_tail(x,fname,p_lam,r_lams,st_idx)]
    case Con{x,rest}: Con{x,agy_abs_wrap_let_kids(rest,fname,p_lam,r_lams,st_idx)}

@unsafe
def w7_br_886(w7_c: Bool, +cdef: KDef) -> U32:
  match w7_c:
    case True{}:
      999999
    case False{}:
      da(cdef)

@unsafe
def agy_abs_ctor_arity_def(+cdef: KDef) -> U32:
  w7_br_886(agy_str_eq(dk(cdef),"Absent"), cdef)

@unsafe
def w7_br_887(w7_c: Bool, +p_lam: KTerm, +r_lams: List<&2,KTerm>, +st_idx: U32, +m2: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      agy_abs_lam(nm(p_lam),ix(p_lam),qt(p_lam),agy_abs_wrap_lams(agy_abs_drop_last(r_lams),m2))
    case False{}:
      agy_abs_build_sbr_app(p_lam,r_lams,st_idx,m2)

@unsafe
def agy_abs_build_sbr(+arity: U32, +p_lam: KTerm, +r_lams: List<&2,KTerm>, +st_idx: U32, +m2: KTerm) -> KTerm:
  w7_br_887(U32.is_eq(st_idx,U32.sub(arity,2)), p_lam, r_lams, st_idx, m2)

@unsafe
def agy_bf_type_arity(+t: KTerm) -> U32:
  +t0 = j_strip(t)
  kc(U32,p98_tag_eq(t0,"All") && U32.is_eq(qt(t0),2) && p198e_owner(kid(t0,0),"Nat"),
    u => agy_bf_type_second(kid(t0,1)),
    u => 0)

@unsafe
def w7_br_894(w7_c: Bool, +a0: KTerm, +pid: U32) -> AgyStep:
  match w7_c:
    case True{}:
      agy_bf_is_shln(a0,pid)
    case False{}:
      AgyStep{0,False{}}

@unsafe
def agy_bf_strip_cache(book: List<&2,KDef>) -> List<&2,KDef>:
  match book:
    case Nil{}: []
    case Con{+h,+rest}:
      kc(List<&2,KDef>,p88_string_eq(dk(h),"BookCache"),u => rest,u => Con{h,rest})

@unsafe
def w5c3_ar_xor(m: Bool, +op: String, +a: U32, +b: U32) -> KTerm:
  match m:
    case True{}: KLiteral{"U32",U32.xor(a,b),"",0,0}
    case False{}: w5c3_ar_and(String.eq(op,"u32_and"), op, a, b)

@unsafe
def w5c3_ar_mul(m: Bool, +op: String, +a: U32, +b: U32) -> KTerm:
  match m:
    case True{}: KLiteral{"U32",U32.mul(a,b),"",0,0}
    case False{}: w5c3_ar_xor(String.eq(op,"u32_xor"), op, a, b)

@unsafe
def w5c2_rcmp_eq(m: Bool, +op: String, +la: U32, +ha: U32, +lb: U32, +hb: U32) -> KTerm:
  match m:
    case True{}: w5c2_rcmp_b(U32.is_lt(ha,lb) || U32.is_gt(la,hb), False{})
    case False{}: w5c2_rcmp_ne(String.eq(op,"u32_is_ne"), la, ha, lb, hb)

@unsafe
def p205v_pure_nonzero_mod(+op: String, +args: List<&2,KTerm>) -> Bool:
  match args:
    case Con{_,Con{b,Nil{}}}: String.eq(op,"u32_mod") && p205v_range_ok(p205v_range_mod(j_u32(b)))
    case _: False{}

law w2d_extract_step:
  for +t: KTerm
  for +fname: String
  for +tid: U32
  W2StepExtract

@unsafe
def w2d_extract_step_let(+ks_list: List<&2,KTerm>, +fname: String, +tid: U32) -> W2StepExtract:
  match ks_list:
    case Con{b,Con{body,Nil{}}}:
      kc(W2StepExtract,U32.is_eq(p205u_refs(b,fname),0) && U32.is_eq(p205u_vars(b,tid),0),
        u => w2d_extract_wrap_let(b,w2d_extract_step(body,fname,tid)),
        u => W2StepExtract{body,False{}})
    case _: W2StepExtract{atom("Absent"),False{}}

@unsafe
def w2d_extract_step_call(+t: KTerm, +call: KTerm, +fname: String, +tid: U32) -> W2StepExtract:
  w7_br_916(p98_tag_eq(call,"Call") && agy_str_eq(nm(call),fname) && U32.is_eq(terms_len(ks(call)),2) && agy_bf_is_var(p205u_at(ks(call),0),tid) && U32.is_eq(p205u_vars(p205u_at(ks(call),1),tid),0) && U32.is_eq(p205u_refs(p205u_at(ks(call),1),fname),0), t, call)

@unsafe
def w2d_extract_step(t, fname, tid):
  +s = j_strip(t)
  kc(W2StepExtract,p98_tag_eq(s,"App"),u => w2d_extract_step_call(s,j_call_spine(s,[]),fname,tid),u =>
  kc(W2StepExtract,p98_tag_eq(s,"Let"),v => w2d_extract_step_let(ks(s),fname,tid),v =>
  kc(W2StepExtract,p98_tag_eq(s,"Lam"),w => w2d_extract_wrap_lam(s,w2d_extract_step(kid(s,0),fname,tid)),w =>
  kc(W2StepExtract,p98_tag_eq(s,"Mat") && U32.is_eq(terms_len(ks(s)),2) && p98_tag_eq(kid(s,1),"Efq"),
    x => w2d_extract_wrap_mat(s,kid(s,1),w2d_extract_step(kid(s,0),fname,tid)),
    x => W2StepExtract{s,False{}}))))

@unsafe
def w2d_check_rec_succ(+pname: String, +ar: U32, +lams0: List<&2,KTerm>, +lams1: List<&2,KTerm>, +rid: U32, +wl: W2Lets) -> W2Builder:
  match wl:
    case W2Lets{bs,inner}:
      kc(W2Builder,p98_tag_eq(inner,"Ctr") && agy_str_eq(nm(inner),"SCon") && U32.is_eq(terms_len(ks(inner)),2) &&
        U32.is_eq(p205u_vars(kid(inner,0),rid),0) && U32.is_eq(p205u_refs(kid(inner,0),pname),0) &&
        w2d_no_var_list(bs,rid) && w2d_no_ref_list(bs,pname) && p98_tag_eq(j_strip(kid(inner,1)),"App"),
        u => w2d_check_rec_call(pname,ar,lams0,lams1,bs,kid(inner,0),rid,j_call_spine(j_strip(kid(inner,1)),[])),
        u => W2Builder{pname,ar,False{},[],[],[],atom("Absent"),[],False{}})

@unsafe
def w7_br_923(w7_c: Bool, +cname: String, +hid: U32, +rargs: List<&2,KTerm>, +st: KTerm, +acc_id: U32) -> W2UnboxArm:
  match w7_c:
    case True{}:
      w2d_check_self_arm_ctr(cname,hid,rargs,j_strip(kid(st,0)),acc_id)
    case False{}:
      W2UnboxArm{"",0,atom("Absent"),[],False{}}

@unsafe
def w2d_check_self_arm_st(+cname: String, +hid: U32, +rargs: List<&2,KTerm>, +st: KTerm, +acc_id: U32) -> W2UnboxArm:
  w7_br_923(p98_tag_eq(st,"Ctr") && agy_str_eq(nm(st),"Tuple") && U32.is_eq(terms_len(ks(st)),2) && agy_bf_is_var(kid(st,1),acc_id) && w2d_no_var_list(rargs,acc_id) && w2d_no_var_list(rargs,hid), cname, hid, rargs, st, acc_id)

@unsafe
def w2d_rewrite_to_inner_st(+t: KTerm, +rargs: List<&2,KTerm>, +st: KTerm, +cname: String, +iname: String) -> KTerm:
  w7_br_925(p98_tag_eq(st,"Ctr") && agy_str_eq(nm(st),"Tuple") && U32.is_eq(terms_len(ks(st)),2) && p98_tag_eq(j_strip(kid(st,0)),"Ctr") && agy_str_eq(nm(j_strip(kid(st,0))),cname) && U32.is_eq(terms_len(ks(j_strip(kid(st,0)))),1), t, rargs, st, cname, iname)

@unsafe
def w2d_is_small_mat(+t: KTerm) -> Bool:
  +s = j_strip(t)
  p98_tag_eq(s,"App") && w2d_is_mat_head(kid(s,0)) && p205u_room([s],128)

# ==============================================================================
# Core Deforestation Pusher (with linear String continuation env `senv`)
# ==============================================================================
@unsafe
def w7_br_932(w7_c: Bool, +call: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      p205u_at(ks(call),1)
    case False{}:
      w7_br_931(p98_tag_eq(call,"Call") && agy_str_eq(nm(call),"Sigma") && U32.is_eq(terms_len(ks(call)),4) && p98_tag_eq(j_strip(p205u_at(ks(call),3)),"Lam"), call)

@unsafe
def w2d_st_snd_ty_call(+call: KTerm) -> KTerm:
  w7_br_932(p98_tag_eq(call,"Call") && U32.is_eq(terms_len(ks(call)),2), call)

@unsafe
def p86_read_sized(pair: File & Result<&1,&1,U32 & String,U32>) -> IO(String):
  (file, result) = pair
  match result:
    case Done{+size}:
      p86_read_limit(file, size, U32.is_le(size, 16777216))
    case Fail{error}:
      do IO<String>:
        Unit <- File.close(file)
        IO.pass(String, Fail{error})

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:725
@unsafe
def p86_read_file(path: String) -> IO(String):
  do IO<String>:
    file : File <- IO.try(File, File.open(path, "r"))
    pair : File & Result<&1,&1,U32 & String,U32> <- File.size(file)
    p86_read_sized(pair)


# PRIVATE cache mode: the wrapper authenticates the complete carrier receipt,
# producer/Base/path/ABI and native consumer image before invoking this entry.
# A matching stamp alone grants no trust. Cache refusal never falls back silently.

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:762
@unsafe
def nbc_filled(fresh: FFresh, args: List<&2, KTerm>, n: U32) -> KTerm:
  match fresh:
    case FFresh{term, next}: nbc_evaluate(term, args, Nil{}, n)
# Phase152 experimental overlay. Replace only nbc_definition and p113_value_kind.
# Original source admission runs before prepared facts are inspected. The only
# accepted body difference is nullary Ctr -> authenticated packed NStatic.
# No selector/name recognizer, raw marker admission, new IR, or verifier bypass.
@unsafe
def ntr_refs(xs: List<&2, KTerm>, +owner: String) -> Bool:
  match xs:
    case Nil{}: False{}
    case Con{h, rest}: nb_contains(nc_refs(h), owner) || ntr_refs(rest, owner)

@unsafe
def w5c2_opid_f(+k: String) -> U32:
  w5c2_u32_pick(String.eq(k, "f32_add"), 26,
  w5c2_u32_pick(String.eq(k, "f32_sub"), 27,
  w5c2_u32_pick(String.eq(k, "f32_mul"), 28,
  w5c2_u32_pick(String.eq(k, "f32_div"), 29,
  w5c2_u32_pick(String.eq(k, "f32_is_eq"), 30,
  w5c2_u32_pick(String.eq(k, "f32_is_ne"), 31,
  w5c2_u32_pick(String.eq(k, "f32_is_lt"), 32,
  w5c2_u32_pick(String.eq(k, "f32_is_le"), 33,
  w5c2_u32_pick(String.eq(k, "f32_is_gt"), 34,
  w5c2_u32_pick(String.eq(k, "f32_is_ge"), 35, w5c2_opid_f2(k)))))))))))

@unsafe
def w5c2_opid_dn(ok: Bool, +c: U32, +k: String) -> U32:
  match ok:
    case True{}: w5c2_opid_n(k)
    case False{}: w5c2_opid_da(U32.is_eq(c, 97), c, k)

@unsafe
def p111_partition(env: List<&2, NC_Binding>, +uses: NU_Set) -> P111Partition:
  match env:
    case Nil{}: P111Partition{Nil{}, Nil{}}
    case Con{NC_Binding{+id, +word, +kind}, rest}: p111_partition_step(id, word, kind, nu_has(uses, id), p111_partition(rest, uses))

@unsafe
def p111_constructor(name: String, values: List<&2,N111Value>) -> P111ValueCode:
  p114p_constructor(name,values)

@unsafe
def w5c3_bucket_hit(hit: Bool, +h: KDef, rest: List<&2,KDef>, +name: String) -> KDef:
  match hit:
    case True{}: h
    case False{}: w5c3_bucket(rest, name)

@unsafe
def w5c3_bucket(ds: List<&2,KDef>, +name: String) -> KDef:
  match ds:
    case Nil{}: missing()
    case Con{+h, rest}: w5c3_bucket_hit(String.eq(dn(h), name), h, rest, name)

@unsafe
def w5c3_find_leaf(eq: Bool, bucket: List<&2,KDef>, +name: String) -> KDef:
  match eq:
    case True{}: w5c3_bucket(bucket, name)
    case False{}: missing()

law w5c3_inter_buckets:
  for lb: List<&2,KDef>
  for +rb: List<&2,KDef>
  List<&2,KDef>

@unsafe
def w5c3_ib_step(is_abs: Bool, +head: KDef, +found: KDef, rest: List<&2,KDef>, +rb: List<&2,KDef>) -> List<&2,KDef>:
  match is_abs:
    case True{}: w5c3_inter_buckets(rest, rb)
    case False{}:
      +cap = w5c3_u32_if(U32.is_eq(dx(head), dx(found)), dx(head), 0)
      Con{KDef{dn(head), dk(head), da(head), cap, atom("Absent"), atom("Absent"), [], False{}, False{}}, w5c3_inter_buckets(rest, rb)}

@unsafe
def w5c3_inter_buckets(lb, rb):
  match lb:
    case Nil{}: Nil{}
    case Con{+head, rest}:
      +found = w5c3_bucket(rb, dn(head))
      w5c3_ib_step(String.eq(dk(found), "Absent"), head, found, rest, rb)

@unsafe
def w5c3_comb_a(a_abs: Bool, +lh: U32, +lm: U32, +ia: KDef, +ib: KDef) -> KDef:
  match a_abs:
    case True{}: ib
    case False{}: w5c3_comb_b(String.eq(dk(ib), "Absent"), lh, lm, ia, ib)

@unsafe
def w5c3_inter_combine(+lh: U32, +lm: U32, +ia: KDef, +ib: KDef) -> KDef:
  w5c3_comb_a(String.eq(dk(ia), "Absent"), lh, lm, ia, ib)

@unsafe
def w5c3_sig10(m: Bool, +s: String) -> List<&2,U32>:
  match m:
    case True{}: [3,2,2]
    case False{}: w5c3_sig14(String.eq(s,"p111_rt_stack_pop") || String.eq(s,"p111_rt_stack_get") || String.eq(s,"p111_rt_reg_get") || String.eq(s,"p111_rt_fail"), s)

@unsafe
def w5c3_cc_frame(m: Bool, +target: KDef, +count: U32) -> Bool:
  match m:
    case True{}: Bool.not(String.eq(dk(target),"Absent")) && U32.is_gt(dx(target),0) && U32.is_eq(U32.add(count,dx(target)),da(target))
    case False{}: True{}

@unsafe
def w5c3_cc_clo(m: Bool, +symbol: String, +target: KDef, +count: U32) -> Bool:
  match m:
    case True{}: Bool.not(String.eq(dk(target),"Absent")) && U32.is_eq(dx(target),0) && U32.is_eq(U32.inc(count),da(target))
    case False{}: w5c3_cc_frame(String.eq(symbol,"p111_rt_frame"), target, count)

@unsafe
def w5c3_ctr_fail(m: Bool, +args: List<&2,N111Arg>) -> Bool:
  match m:
    case True{}:
      +id = p111v_literal(p111v_arg(args,1))
      U32.is_gt(id,0) && U32.is_le(id,8)
    case False{}: True{}

@unsafe
def p111q_segment_table(segments: List<&2,N111Segment>, +kind: U32, acc: List<&2,P111QDatum>) -> List<&2,P111QDatum>:
  match segments:
    case Nil{}: p111q_nonempty(nt_reverse(P111QDatum,acc,[]))
    case Con{N111Segment{name,arity,result,incoming,flags,body},rest}:
      p111q_segment_table(rest,kind,Con{p111q_segment_datum(name,arity,incoming,flags,kind),acc})

@unsafe
def p111q_strings(+names: List<&2,String>, +prefix: String) -> List<&2,P111QData>:
  Con{P111QData{prefix,8,False{},p111q_string_refs(names,prefix,0,[])},p111q_string_defs(names,prefix,0,[])}

@unsafe
def p112t_failure(body: List<&2,N111Stmt>) -> Bool:
  match body:
    case Con{N111Call{dest,N111U64{},symbol,args},Con{N111Return{N111Local{word}},Nil{}}}:
      agy_str_eq(symbol,"p111_rt_fail") && agy_str_eq(dest,word) && p112t_failure_args(args)
    case Con{+stmt,rest}: (p112t_scalar_safe(stmt) || p112t_failure_frame(stmt)) && p112t_failure(rest)
    case _: False{}

# Failure recognition runs once at block entry. Ordinary scalar tails use this
# path directly, avoiding repeated full-suffix failure scans.


@unsafe
def p112_special_test(+name: String, +word: N111Value) -> List<&2, N111Stmt>:
  +kind = p111_special(name)
  nt_choose(List<&2, N111Stmt>, U32.is_gt(kind, 0) && U32.is_le(kind, 7) && p112_special_safe(word),
    u => p112_special_selected(kind, word), u => p112_special_test_fallback(name, word))


@unsafe
def p112f_index_get(+tree: P112FusionIndex, +name: String) -> Maybe<&2,N111Segment>:
  p112f_index_find(tree,name,index_hash(name,2166136261))


law p112f_index_insert:
  for +tree: P112FusionIndex
  for +segment: N111Segment
  for +hash: U32
  for +split: U32
  P112FusionIndex

@unsafe
def w7c_p112f_ins_lr(bit: U32, +mask: U32, +left: P112FusionIndex, +right: P112FusionIndex, +segment: N111Segment, +hash: U32, +split: U32) -> P112FusionIndex:
  match bit:
    case 0: P112FusionNode{mask,p112f_index_insert(left,segment,hash,split),right}
    case _: P112FusionNode{mask,left,p112f_index_insert(right,segment,hash,split)}

@unsafe
def w7c_p112f_ins_node(above: Bool, +tree: P112FusionIndex, +mask: U32, +left: P112FusionIndex, +right: P112FusionIndex, +segment: N111Segment, +hash: U32, +split: U32) -> P112FusionIndex:
  match above:
    case True{}: p112f_index_join(tree,segment,hash,split)
    case False{}: w7c_p112f_ins_lr(U32.and(hash,mask),mask,left,right,segment,hash,split)

@unsafe
def p112f_index_insert(tree, segment, hash, split):
  match tree:
    case P112FusionEmpty{}: P112FusionLeaf{hash,[segment]}
    case P112FusionLeaf{+stored,+bucket}:
      w7c_p112f_ins_leaf(split,tree,bucket,segment,hash,split)
    case P112FusionNode{+mask,+left,+right}:
      w7c_p112f_ins_node(Bool.not(U32.is_eq(split,0)) && U32.is_lt(split,mask),tree,mask,left,right,segment,hash,split)


@unsafe
def p112f_index_add(+tree: P112FusionIndex, +segment: N111Segment) -> P112FusionIndex:
  match segment:
    case N111Segment{+name,+arity,+result,+incoming,+flags,+body}:
      +hash = index_hash(name,2166136261)
      p112f_index_insert(tree,segment,hash,index_split_bit(U32.xor(hash,p112f_index_tip(tree,hash))))


@unsafe
def p112f_clean(body: List<&2,N111Stmt>) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{+stmt,+rest}: p112f_clean_stmt(stmt) && p112f_clean(rest)


@unsafe
def p112f_clean_stmt(stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Set{+name,+typ,+value}: p112f_clean_name(name) && p112f_clean_value(value)
    case N111Bin{+name,+typ,+op,+left,+right}: p112f_clean_name(name) && p112f_clean_value(left) && p112f_clean_value(right)
    case N111Call{+name,+typ,+symbol,+args}: p112f_clean_name(name) && p112f_clean_args(args)
    case N111If{+condition,+yes,+no}: p112f_clean_value(condition) && p112f_clean(yes) && p112f_clean(no)
    case N111Return{+value}: p112f_clean_value(value)
    case N111Load{+name,+typ,+base,+offset}: p112f_clean_name(name) && p112f_clean_value(base)
    case N111Store{+typ,+base,+offset,+value}: p112f_clean_value(base) && p112f_clean_value(value)
    case N111Offset{+name,+base,+bytes}: p112f_clean_name(name) && p112f_clean_value(base) && p112f_clean_value(bytes)
    case N111Alloca{+name,+bytes,+align}: p112f_clean_name(name)


@unsafe
def p112f_safe(+body: List<&2,N111Stmt>) -> Bool:
  nt_choose(Bool,p112f_transition(body),u => True{},u => p112f_safe_next(body))


@unsafe
def p112f_safe_next(body: List<&2,N111Stmt>) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{N111If{+condition,+yes,+no},+rest}: p112f_safe(yes) && p112f_safe(no) && p112f_safe(rest)
    case Con{+stmt,+rest}: (p112t_scalar_safe(stmt) || p112t_failure_frame(stmt)) && p112f_safe(rest)


@unsafe
def p112r_runtime_args(args: List<&2,N111Arg>, +sites: U32) -> Bool:
  match args:
    case Con{N111Arg{N111Ptr{},N111Local{+name}},+rest}: agy_str_eq(name,"state") && p112r_buffers(rest,sites)
    case _: False{}


@unsafe
def p112r_exit(body: List<&2,N111Stmt>, +count: U32, +last: P112WorkerStmt) -> List<&2,P112WorkerStmt>:
  nt_append(P112WorkerStmt,p112w_failure_nodes(p112f_snapshots(p112f_values(body,count),"p112f_region_","exit_",0)),p112r_exit_stores(count,0,last))


@unsafe
def p112g_value(value: N111Value) -> Bool:
  match value:
    case N111Local{+name}: p112g_name(name)
    case N111Const{+lo,+hi}: True{}
    case _: False{}


@unsafe
def p112h_condition(value: N111Value) -> Bool:
  match value:
    case N111Local{+name}: p112g_name(name)
    case N111Const{+lo,+hi}: U32.is_eq(hi,0)
    case _: False{}


@unsafe
def p113p_array_call(symbol: String, args: List<&2,N111Arg>) -> Bool:
  p113j_array_call(symbol,args)

@unsafe
def p113pl_done(+values: List<&2,N111Value>, +target: P113PTarget, +n: U32) -> P113DCode:
  nt_choose(P113DCode,p118t_target(target),u => p118t_finish(values,n),
    u => p118t_original_done(values,target,n))

@unsafe
def p113pl_emitted(+target: P113PTarget, +n: U32, value: P113PValueCode) -> P113DCode:
  match value:
    case P113PValueCode{body,values,+error}:
      nt_choose(P113DCode,String.is_empty(error),u => p113d_prepend(body,p113pl_done(values,target,n)),u => p113d_fail(error,n))


@unsafe
def p113i_scalar_clean(stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Set{name,typ,value}: p113i_name(name) && p113i_value(value)
    case N111Bin{name,typ,op,left,right}: p113i_name(name) && p113i_value(left) && p113i_value(right)
    case N111Call{name,typ,symbol,args}: p113i_name(name) && p113i_args(args)
    case N111If{condition,yes,no}: p113i_value(condition) && p113i_scalars_clean(yes) && p113i_scalars_clean(no)
    case N111Load{name,typ,base,offset}: p113i_name(name) && p113i_value(base)
    case N111Store{typ,base,offset,value}: p113i_value(base) && p113i_value(value)
    case N111Offset{name,base,bytes}: p113i_name(name) && p113i_value(base) && p113i_value(bytes)
    case N111Alloca{name,bytes,align}: p113i_name(name)
    case _: False{}


@unsafe
def p113i_scalars_clean(body: List<&2,N111Stmt>) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{head,rest}: p113i_scalar_clean(head) && p113i_scalars_clean(rest)


@unsafe
def p113j_scratch_count(+args: List<&2,N111Arg>, +position: U32, +count_at: U32) -> U32:
  nt_choose(U32,U32.is_eq(p113j_scratch_args(args),1) && p113j_is_scratch(p111v_arg(args,position)),
    u => p113j_scratch_literal(p111v_arg(args,count_at)),u => 2048)


@unsafe
def p113a_success(+id: U32, +destination: String, +output: N111Value, +n: U32) -> List<&2,N111Stmt>:
  nt_choose(List<&2,N111Stmt>,U32.is_eq(id,72),
    u => p113a_pair_store(destination,output,p113a_value(n,"old"),n),u =>
    nt_append(N111Stmt,[N111Store{N111U32{},p113a_value(n,"cell"),0,p113a_value(n,"new")}],
      nt_choose(List<&2,N111Stmt>,U32.is_eq(id,73),
        v => [N111Set{destination,N111U64{},p113a_value(n,"array")}],
        v => p113a_pair_store(destination,output,p113a_value(n,"old"),n))))

@unsafe
def p113a_raw(+id: U32, +destination: String, +output: N111Value, +original: N111Stmt, +n: U32) -> List<&2,N111Stmt>:
  nt_choose(List<&2,N111Stmt>,U32.is_eq(id,75),
    u => nt_append(N111Stmt,p113a_class(n),p113a_pair_store(destination,output,p113a_value(n,"size"),n)),
    u => nt_append(N111Stmt,p117p_address(id,n),p113a_success(id,destination,output,n)))

@unsafe
def p113a_input_name(stmt: N111Stmt) -> String:
  match stmt:
    case N111Call{destination,N111U64{},symbol,args}: p113a_val_name(p111v_arg(args,2))
    case _: ""


@unsafe
def p113a_body_names(body: List<&2,P113DStmt>) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{P113DScalar{stmt},rest}: p113a_scalar_names(stmt) && p113a_body_names(rest)
    case Con{P113DIf{condition,yes,no},rest}: p113a_body_names(yes) && p113a_body_names(no) && p113a_body_names(rest)
    case Con{P113DCall{destinations,target,args},rest}: p113a_names(destinations) && p113a_body_names(rest)
    case Con{head,rest}: p113a_body_names(rest)


@unsafe
def w5c2_bits16(ge65536: Bool, +v: U32, +b: U32) -> U32:
  match ge65536:
    case True{}:
      +v1 = U32.shrn(v, 16n)
      w5c2_bits8(U32.is_ge(v1, 256), v1, U32.add(b, 16))
    case False{}: w5c2_bits8(U32.is_ge(v, 256), v, b)

@unsafe
def p113k_result_type(+typ: N111Type, +op: String) -> N111Type:
  w5c2_res_ty_if(p111v_comparison(op), typ)


@unsafe
def w5c2_bs_6(ok: Bool, +name: String, +typ: N111Type, +op: String, +left: N111Value, +right: N111Value, +lf: P113KFact, +rf: P113KFact) -> N111Stmt:
  match ok:
    case True{}: N111Set{name, typ, left}
    case False{}:
      w5c2_bs_7(
        (String.eq(op,"and") && p113k_mask_covers(p113k_bits_of(rf),lf)) ||
        ((String.eq(op,"or") || String.eq(op,"xor") || String.eq(op,"add")) && p113k_zero(lf)) ||
        (String.eq(op,"mul") && p113l_exact_one(lf)),
        name, typ, op, left, right)

@unsafe
def p114r_arguments(+body: List<&2,N111Stmt>, +owner: String, +arity: U32) -> Bool:
  nt_choose(Bool,p112t_tail(body,owner,arity,0),u => True{},
    u => p114r_arguments_next(body,owner,arity))


@unsafe
def p114r_arguments_next(body: List<&2,N111Stmt>, +owner: String, +arity: U32) -> Bool:
  match body:
    case Con{stmt,rest}: p112t_scalar_safe(stmt) && p114r_arguments(rest,owner,arity)
    case _: False{}


@unsafe
def p114g_prepend(+stmt: N111Stmt, tail: P114GBody) -> P114GBody:
  match tail:
    case P114GBody{valid,frames,body}:
      P114GBody{valid && p112t_scalar_safe(stmt),frames,Con{P114RScalar{stmt},body}}


@unsafe
def p114h_clean(body: List<&2,N111Stmt>) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{stmt,rest}: p114h_clean_stmt(stmt) && p114h_clean(rest)


@unsafe
def p114h_clean_stmt(stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Set{name,typ,value}: p114h_clean_name(name) && p114h_clean_value(value)
    case N111Bin{name,typ,op,left,right}: p114h_clean_name(name) && p114h_clean_value(left) && p114h_clean_value(right)
    case N111Call{name,typ,symbol,args}: p114h_clean_name(name) && p114h_clean_args(args)
    case N111If{condition,yes,no}: p114h_clean_value(condition) && p114h_clean(yes) && p114h_clean(no)
    case N111Return{value}: p114h_clean_value(value)
    case N111Load{name,typ,base,offset}: p114h_clean_name(name) && p114h_clean_value(base)
    case N111Store{typ,base,offset,value}: p114h_clean_value(base) && p114h_clean_value(value)
    case N111Offset{name,base,bytes}: p114h_clean_name(name) && p114h_clean_value(base) && p114h_clean_value(bytes)
    case N111Alloca{name,bytes,align}: p114h_clean_name(name)


def p114h_clean_segment(segment: N111Segment) -> Bool:
  match segment:
    case N111Segment{name,arity,result,incoming,flags,body}: p114h_clean(body)


@unsafe
def p114t_frame(+dest: String, fid: String, buffer: String, +count: U32, +site: U32) -> List<&2,N111Stmt>:
  Con{N111Load{p114t_name(site,"sp"),N111Ptr{},N111Local{"state"},16},
    nt_append(N111Stmt,p114t_captures(buffer,count,0,site),[
      N111Store{N111U64{},p114t_local(site,"sp"),U32.mul(count,8),N111FuncId{fid}},
      N111Offset{p114t_name(site,"next_sp"),p114t_local(site,"sp"),N111Const{U32.mul(U32.inc(count),8),0}},
      N111Store{N111Ptr{},N111Local{"state"},16,p114t_local(site,"next_sp")},
      N111Set{dest,N111U64{},N111Const{0,0}}])}


@unsafe
def p114t_body_names(body: List<&2,P113DStmt>) -> Bool:
  p114ts_body(body,True{})

@unsafe
def p114ts_body(body: List<&2,P113DStmt>, valid: Bool) -> Bool:
  match body:
    case Nil{}: valid
    case Con{P113DScalar{stmt},rest}: p114ts_body(rest,valid && p114t_scalar_names(stmt))
    case Con{P113DIf{condition,yes,no},rest}:
      p114ts_body(rest,valid && p114t_body_names(yes) && p114t_body_names(no))
    case Con{P113DCall{destinations,target,args},rest}: p114ts_body(rest,valid && p114t_names(destinations))
    case Con{head,rest}: p114ts_body(rest,valid)


@unsafe
def p114ts_segments(segments: List<&2,N111Segment>, valid: Bool) -> Bool:
  match segments:
    case Nil{}: valid
    case Con{N111Segment{name,arity,result,incoming,flags,body},rest}:
      p114ts_segments(rest,valid && p114t_scalar_list_names(body))


@unsafe
def p117p_address(+id: U32, +n: U32) -> List<&2,N111Stmt>:
  nt_append(N111Stmt,p113a_class(n),nt_append(N111Stmt,[
    N111Bin{p113a_name(n,"mask"),N111U64{},"sub",p113a_value(n,"size"),N111Const{1,0}},
    N111Bin{p113a_name(n,"index"),N111U64{},"and",p113a_value(n,"index"),p113a_value(n,"mask")},
    N111Bin{p113a_name(n,"base_bytes"),N111U64{},"shl",p113a_value(n,"location"),N111Const{3,0}},
    N111Bin{p113a_name(n,"index_bytes"),N111U64{},"shl",p113a_value(n,"index"),N111Const{2,0}},
    N111Bin{p113a_name(n,"bytes"),N111U64{},"add",p113a_value(n,"base_bytes"),p113a_value(n,"index_bytes")},
    N111Offset{p113a_name(n,"cell"),N111Local{"p113a_heap_base"},p113a_value(n,"bytes")}],
    nt_choose(List<&2,N111Stmt>,U32.is_eq(id,73),u => [],
      u => [N111Load{p113a_name(n,"old"),N111U32{},p113a_value(n,"cell"),0}])))


@unsafe
def p117h_params_clean(params: List<&2,NC_Binding>) -> Bool:
  match params:
    case Nil{}: True{}
    case Con{NC_Binding{id,name,kind},rest}: Bool.not(p117h_buffer(name)) && p117h_params_clean(rest)


@unsafe
def p117h_slot(+base: N111Value, +offset: U32) -> String:
  match base:
    case N111Local{+name}:
      nt_choose(String,p117h_buffer(name) && U32.is_eq(U32.and(offset,7),0),
        u => name ++ ":" ++ U32.show(offset),u => "")
    case _: ""


@unsafe
def p117h_metadata(+name: String, +origin: U32, +heap_min: U32) -> List<&2,N111Stmt>:
  [N111Set{p117h_name(origin,"array"),N111U64{},N111Local{name}},
   N111Bin{p117h_name(origin,"tag"),N111U64{},"shr",p117h_ref(origin,"array"),N111Const{56,0}},
   N111Bin{p117h_name(origin,"btag"),N111U64{},"and",p117h_ref(origin,"tag"),N111Const{127,0}},
   N111Bin{p117h_name(origin,"raw"),N111U64{},"eq",p117h_ref(origin,"btag"),N111Const{p117h_raw_tag(),0}},
   N111Bin{p117h_name(origin,"location"),N111U64{},"and",p117h_ref(origin,"array"),N111Const{4294967295,255}},
   N111Bin{p117h_name(origin,"dynamic"),N111U64{},"uge",p117h_ref(origin,"location"),N111Const{heap_min,0}},
   N111Bin{p117h_name(origin,"admitted"),N111U32{},"and",p117h_ref(origin,"raw"),p117h_ref(origin,"dynamic")},
   N111Bin{p117h_name(origin,"rfc"),N111U64{},"shr",p117h_ref(origin,"tag"),N111Const{7,0}},
   N111Bin{p117h_name(origin,"rfc_ok"),N111U32{},"and",p117h_ref(origin,"admitted"),p117h_ref(origin,"rfc")},
   N111If{p117h_ref(origin,"rfc_ok"),[
     N111Bin{p117h_name(origin,"rbytes"),N111U64{},"shl",p117h_ref(origin,"location"),N111Const{3,0}},
     N111Offset{p117h_name(origin,"rptr"),N111Local{"p113a_heap_base"},p117h_ref(origin,"rbytes")},
     N111Load{p117h_name(origin,"rcell"),N111U64{},p117h_ref(origin,"rptr"),0},
     N111Bin{p117h_name(origin,"location"),N111U64{},"shr",p117h_ref(origin,"rcell"),N111Const{24,0}},
     N111Bin{p117h_name(origin,"rdyn"),N111U64{},"uge",p117h_ref(origin,"location"),N111Const{heap_min,0}},
     N111Bin{p117h_name(origin,"admitted"),N111U32{},"and",p117h_ref(origin,"admitted"),p117h_ref(origin,"rdyn")}],[]},
   N111Bin{p117h_name(origin,"class"),N111U64{},"shr",p117h_ref(origin,"array"),N111Const{40,0}},
   N111Bin{p117h_name(origin,"class"),N111U64{},"and",p117h_ref(origin,"class"),N111Const{31,0}},
   N111Bin{p117h_name(origin,"size"),N111U64{},"shl",N111Const{1,0},p117h_ref(origin,"class")},
   N111Bin{p117h_name(origin,"mask"),N111U64{},"sub",p117h_ref(origin,"size"),N111Const{1,0}},
   N111Bin{p117h_name(origin,"bytes"),N111U64{},"shl",p117h_ref(origin,"location"),N111Const{3,0}},
   N111Offset{p117h_name(origin,"base"),N111Local{"p113a_heap_base"},p117h_ref(origin,"bytes")}]


@unsafe
def p117h_prelude(params: List<&2,NC_Binding>, +origin: U32, +used: U32, +heap_min: U32) -> List<&2,N111Stmt>:
  match params:
    case Nil{}: []
    case Con{NC_Binding{id,name,kind},rest}:
      nt_append(N111Stmt,nt_choose(List<&2,N111Stmt>,U32.is_eq(U32.and(used,p117h_bit(origin)),0),
        u => [],u => p117h_metadata(name,origin,heap_min)),p117h_prelude(rest,U32.inc(origin),used,heap_min))


@unsafe
def p117h_address(+id: U32, +n: U32, +origin: U32) -> List<&2,N111Stmt>:
  nt_append(N111Stmt,[
    N111Bin{p113a_name(n,"index"),N111U64{},"and",p113a_value(n,"index"),p117h_ref(origin,"mask")},
    p123a_scale(p113a_name(n,"bytes"),p113a_value(n,"index"),p117h_index_shift()),
    N111Offset{p113a_name(n,"cell"),p117h_ref(origin,"base"),p113a_value(n,"bytes")}],
    nt_choose(List<&2,N111Stmt>,U32.is_eq(id,73),u => [],
      u => [N111Load{p113a_name(n,"old"),p117h_cell_type(),p113a_value(n,"cell"),0}]))

@unsafe
def p117v_guard(params: List<&2,NC_Binding>, +origin: U32, +used: U32) -> List<&2,N111Stmt>:
  match params:
    case Nil{}: []
    case Con{head,rest}:
      nt_append(N111Stmt,nt_choose(List<&2,N111Stmt>,U32.is_eq(U32.and(used,p117h_bit(origin)),0),u => [],u =>
        [N111Bin{"p113a_version_guard",N111U32{},"and",N111Local{"p113a_version_guard"},p117h_ref(origin,"admitted")}]),
        p117v_guard(rest,U32.inc(origin),used))


# W4-10 Pass 4: Hoisted Bitmask & Induction-Variable Array Mask Elimination (w4_bitmask_bounds_sound).
@unsafe
def p117v_address_nomask(+id: U32, +n: U32, +origin: U32) -> List<&2,N111Stmt>:
  nt_append(N111Stmt,[
    p123a_scale(p113a_name(n,"bytes"),p113a_value(n,"index"),p117h_index_shift()),
    N111Offset{p113a_name(n,"cell"),p117h_ref(origin,"base"),p113a_value(n,"bytes")}],
    nt_choose(List<&2,N111Stmt>,U32.is_eq(id,73),u => [],
      u => [N111Load{p113a_name(n,"old"),p117h_cell_type(),p113a_value(n,"cell"),0}]))

@unsafe
def w5_arm_loc_pair(s1: W5SetLoc, h2: P113DStmt) -> W5SetLoc:
  match s1:
    case W5SetLoc{t,src}: w5_arm_loc_pair2(t,src,w5_set_loc_st(h2))
    case W5SetLocNone{}: W5SetLocNone{}

@unsafe
def w5_arm_loc(body: List<&2,P113DStmt>) -> W5SetLoc:
  match body:
    case Con{h1,Nil{}}: w5_set_loc_st(h1)
    case Con{h1,Con{h2,Nil{}}}: w5_arm_loc_pair(w5_set_loc_st(h1),h2)
    case _: W5SetLocNone{}

@unsafe
def p118t_ready(+name: String, +params: List<&2,NC_Binding>, +old: P113DCandidate, code: P113DCode) -> List<&2,P113DCandidate>:
  match code:
    case P113DCode{+body,fresh,+error,+calls}:
      +private = "$p118.trmc." ++ name
      +arity = nt_count(NC_Binding,params)
      +hidden : List<&2,NC_Binding> = [NC_Binding{nc_id(arity),"p118_root",N_W64{}},NC_Binding{nc_id(U32.inc(arity)),"p118_parent",N_W64{}}]
      nt_choose(List<&2,P113DCandidate>,String.is_empty(error) && p118t_has_extend(body),u => [
        P113DCandidate{P113DFunction{private,nt_append(NC_Binding,params,hidden),1,False{},body},"",calls},
        P113DCandidate{P113DFunction{name,params,1,True{},[
          P113DCall{["p118_public_result"],private,nt_append(N111Value,p113pl_locals(nc_words(params)),[N111Const{0,0},N111Const{0,0}])},
          P113DResult{[N111Local{"p118_public_result"}]}]},"",[private]}],u => [old])


@unsafe
def p118b_reads(+layout: NO_Layout, +fields: List<&2,KTerm>, +yesTerm: KTerm, +word: N111Value) -> List<&2,N111Stmt>:
  match layout:
    case NO_Layout{key,+ctor,+storage,+width}:
      nt_choose(List<&2,N111Stmt>,agy_str_eq(storage,"Boxed"),
        u => Con{N111Call{"p118b_read_status",N111U64{},"p118_rt_borrow_fields",
          [p111_state(),p111_word(word),p111_scratch(),N111Arg{N111U32{},N111CtorId{ctor}},p111_u32(width)]},p118b_field_loads(fields,yesTerm,0)},
        u => nt_choose(List<&2,N111Stmt>,agy_str_eq(storage,"Nullary"),v => [],v =>
          nt_choose(List<&2,N111Stmt>,agy_str_eq(storage,"Succ"),
            w => [N111Bin{"v_" ++ U32.show(ix(kid(kt("","",0,0,fields),0))),N111U64{},"sub",word,N111Const{1,0}}],
            w => [N111Set{"v_" ++ U32.show(ix(kid(kt("","",0,0,fields),0))),N111U64{},word}])) )


@unsafe
def p118b_arg_types(args: List<&2,N111Arg>, widths: List<&2,U32>) -> Bool:
  match args widths:
    case Nil{} Nil{}: True{}
    case Con{N111Arg{typ,value},rest} Con{width,more}:
      U32.is_eq(p111v_type(typ),width) && p118b_arg_types(rest,more)
    case _ _: False{}


@unsafe
def p118c_ctor_names(ctors: List<&2,N_Constructor>, hot: List<&2,String>) -> List<&2,String>:
  p118ns_ctor_names(ctors,hot,[])


@unsafe
def w7_patch_prog_tables(+tables: List<&2,P111QData>, +set3: Bool, +or_flags: U32) -> List<&2,P111QData>:
  nt_choose(List<&2,P111QData>,Bool.not(set3) && U32.is_eq(or_flags,0),u => tables,u => w7_patch_prog_tables_go(tables,set3,or_flags))

@unsafe
def p118c_tables(+tables: List<&2,P111QData>) -> List<&2,P111QData>:
  nt_choose(List<&2,P111QData>,p118c_has_cold(tables),u => p118c_cap_tables(tables),u => tables)

# The sole override. Existing p111_emit_plan still performs runtime admission;
# lower_request retains source/bound checking and the original lowering passes.
# The original full verifier runs once before either derived transformation.

@unsafe
def p118z_scalar(stmt: N111Stmt, +direct: Bool) -> Bool:
  match stmt:
    case N111Set{name,typ,value}: p118z_nonpointer(typ)
    case N111Bin{name,typ,op,left,right}: p118z_nonpointer(typ)
    case N111Call{name,N111U64{},+symbol,args}:
      p118z_runtime(symbol) && p113e_runtime_args(args) &&
        Bool.not(direct && (p118z_transition(symbol) || agy_str_eq(symbol,"p111_rt_reg_get")))
    case N111If{condition,yes,no}: p118z_scalars(yes,direct) && p118z_scalars(no,direct)
    case N111Load{name,typ,base,offset}: p118z_nonpointer(typ) && p113e_nonstate_pointer(base)
    case N111Store{typ,base,offset,value}: p118z_nonpointer(typ) && p113e_nonstate_pointer(base)
    case N111Alloca{name,bytes,align}: True{}
    case N111Return{value}: Bool.not(direct)
    # No pointer aliases/offsets/loads; other pointer roots are verified allocas.
    case _: False{}

# A transition must terminate its block immediately. This forbids reading the
# old segment's wider inputs after a narrower outgoing transfer. The original
# verifier checks the transition's count, target and return value definitions.

@unsafe
def p118z_scalars(body: List<&2,N111Stmt>, direct: Bool) -> Bool:
  p118ns_scalars(body,direct,True{})


@unsafe
def p118ns_scalars(body: List<&2,N111Stmt>, +direct: Bool, +valid: Bool) -> Bool:
  match body:
    case Nil{}: valid
    case Con{N111Call{+name,N111U64{},+symbol,+args},Con{N111Return{N111Local{+reply}},Nil{}}}:
      valid && nt_choose(Bool,p118z_transition(symbol),
        u => Bool.not(direct) && agy_str_eq(name,reply) && p118z_scalar(N111Call{name,N111U64{},symbol,args},direct),
        u => p118z_scalar(N111Call{name,N111U64{},symbol,args},direct) && p118z_scalar(N111Return{N111Local{reply}},direct))
    case Con{N111Call{name,typ,+symbol,args},rest}:
      p118ns_scalars(rest,direct,valid && Bool.not(p118z_transition(symbol)) &&
        p118z_scalar(N111Call{name,typ,symbol,args},direct))
    case Con{head,rest}: p118ns_scalars(rest,direct,valid && p118z_scalar(head,direct))


@unsafe
def p118np_foreign(+d: KDef) -> Bool:
  Bool.not(db(d)) && (p98_tag_eq(nc_unann(dv(d)),"Foreign") ||
    (p88_string_eq(dk(d),"Def") && nc_foreign(d)))


@unsafe
def p123p_test_origin(+op: String, +lo: U32, +record: KDef) -> KDef:
  nt_choose(KDef,agy_str_eq(dk(record),"P123Predicate"),
    u => KDef{"","P123Test",U32.xor(da(record),U32.xor(lo,Bool.to_u32(agy_str_eq(op,"eq")))),0,
      {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},dv(record),[],False{},False{}},u => missing())


@unsafe
def p124r_is_view(view: KDef) -> Bool:
  agy_str_eq(dk(view),"P124Callables")


@unsafe
def p124r_call_nodes(body: List<&2,N111Stmt>, +count: U32, +symbol: String) -> List<&2,N111Stmt>:
  nt_append(N111Stmt,p114r_without_transition(body),nt_append(N111Stmt,p114h_call_loads(count,0),[
    N111Call{"p114h_call_result",N111U64{},symbol,Con{p111_state(),agy_p124r_call_args(count,symbol)}}]))


@unsafe
def p124r_target(body: List<&2,N111Stmt>) -> String:
  match body:
    case Nil{}: ""
    case Con{+stmt,+rest}:
      +target = p112w_target(Con{stmt,rest})
      nt_choose(String,String.is_empty(target),u =>
        nt_choose(String,p112t_scalar_safe(stmt),v => p124r_target(rest),v => ""),u => target)


@unsafe
def p125p_equations(+d: KDef, +empty: String, +link: String) -> Bool:
  +z = j_fusion_empty(d)
  +s = j_fusion_link(d)
  +body = j_fusion_after(s,3)
  +call = j_call_spine(kid(body,1),[])
  j_fusion_cases(dv(d),empty,link) &&
    p98_tag_eq(j_fusion_binder(z,0),"Lam") &&
    j_fusion_var(j_fusion_after(z,1),ix(j_fusion_binder(z,0))) &&
    p98_tag_eq(j_fusion_binder(s,2),"Lam") && j_fusion_ctor(body,link,2) &&
    j_fusion_var(kid(body,0),ix(j_fusion_binder(s,0))) &&
    j_fusion_call(call,dn(d),2) &&
    j_fusion_var(kid(call,0),ix(j_fusion_binder(s,1))) &&
    j_fusion_var(kid(call,1),ix(j_fusion_binder(s,2)))


@unsafe
def p125p_candidates(+owner: String, +empty: String, +link: String, candidates: List<&2,P113DCandidate>) -> List<&2,P113DCandidate>:
  match candidates:
    case Nil{}: []
    case Con{head,rest}: Con{p125p_wrap(owner,empty,link,head),p125p_candidates(owner,empty,link,rest)}


@unsafe
def p125v_previous_sized(stmt: N111Stmt) -> N111Stmt:
  match stmt:
    case N111Call{name,typ,+symbol,+args}:
      +count = p111v_literal(p111v_arg(args,3))
      nt_choose(N111Stmt,(agy_str_eq(symbol,"p111_rt_ctor") || agy_str_eq(symbol,"p111_rt_take")) &&
        U32.is_ge(count,1) && U32.is_le(count,4),
        u => N111Call{name,typ,"p118_" ++ symbol ++ U32.show(count),args},u => stmt)
    case _: stmt


@unsafe
def p126r_scalar(stmt: N111Stmt) -> Bool:
  match stmt:
    case N111If{condition,yes,no}: p126r_scalars(yes) && p126r_scalars(no)
    case _: p112t_scalar_safe(stmt)


@unsafe
def p126r_scalars(body: List<&2,N111Stmt>) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{head,rest}: p126r_scalar(head) && p126r_scalars(rest)


@unsafe
def p126i_catalogue(functions: List<&2,P113DFunction>, acc: List<&2,P126ITable>) -> List<&2,P126ITable>:
  match functions:
    case Nil{}: nt_reverse(P126ITable,acc,[])
    case Con{head,rest}: p126i_catalogue(rest,p126i_add(head,acc))


@unsafe
def p126i_calls(body: List<&2,P113DStmt>, tables: List<&2,P126ITable>) -> Bool:
  match tables:
    case Nil{}: False{}
    case Con{head,rest}: p126i_calls_walk(body,[],Con{head,rest})

@unsafe
def p126bp_shape(+info: KDef, +params: List<&2,NC_Binding>, +wrapper: KTerm) -> Bool:
  agy_str_eq(tg(dv(info)),"NQSig") && p113p_known(dt(info)) &&
    Bool.not(nq_has_shape(ks(dv(info)))) && U32.is_eq(terms_len(ks(dv(info))),nt_count(NC_Binding,params)) &&
    (agy_str_eq(tg(wrapper),"Ctr") || agy_str_eq(tg(wrapper),"NCtr")) &&
    agy_str_eq(nm(wrapper),nm(dt(info))) && U32.is_eq(terms_len(ks(wrapper)),ix(dt(info))) &&
    p126bp_fields(ks(wrapper))


@unsafe
def p126bp_flat(+owner: String, +params: List<&2,NC_Binding>, +schema: NO_Schema, +info: KDef) -> List<&2,P113DFunction>:
  +env : List<&2,NC_Binding> = Con{NC_Binding{no_schema_result(schema),"p118b_observation",N_W64{}},params}
  [P113DFunction{nm(dv(info)),params,ix(dt(info)),False{},[
    P113DCall{["p118b_observation"],p118b_read_name(owner),p111_env_words(params)},
    P113DResult{p111_values(ks(no_schema_wrapper(schema)),env)}]}]


@unsafe
def p128bi_patterns(values: List<&2,N111Value>, +params: List<&2,NC_Binding>) -> List<&2,KTerm>:
  match values:
    case Nil{}: []
    case Con{head,rest}: Con{p128bi_pattern(head,params),p128bi_patterns(rest,params)}


@unsafe
def p128bi_pick(rules: List<&2,KDef>, +destinations: List<&2,String>, +args: List<&2,N111Value>, +original: P113DStmt, +candidate: P113DStmt, +count: U32) -> P113DStmt:
  match rules:
    case Nil{}: nt_choose(P113DStmt,U32.is_eq(count,1),u => candidate,u => original)
    case Con{+rule,+rest}:
      nt_choose(P113DStmt,p128bi_matches(ks(dv(rule)),args),
        u => p128bi_pick(rest,destinations,args,original,
          P113DCall{destinations,dn(rule),p128bi_arguments(da(rule),0,ks(dv(rule)),args)},U32.inc(count)),
        u => p128bi_pick(rest,destinations,args,original,candidate,count))


@unsafe
def p128bf_fast(+dest: String, +buffer: String, +count: U32, +site: U32, +mask: U32) -> List<&2,N111Stmt>:
  nt_append(N111Stmt,
    [N111Load{p114t_name(site,"borrow_heap"),N111Ptr{},N111Local{"state"},0},
     N111Bin{p114t_name(site,"borrow_location"),N111U64{},"and",p114t_local(site,"borrow_word"),N111Const{4294967295,255}},
     N111Bin{p114t_name(site,"borrow_rfc_bit"),N111U64{},"shr",p114t_local(site,"borrow_word"),N111Const{63,0}},
     N111If{p114t_local(site,"borrow_rfc_bit"),p128bf_rfc(site),[]},
     N111Bin{p114t_name(site,"borrow_field_bytes"),N111U64{},"shl",p114t_local(site,"borrow_location"),N111Const{3,0}},
     N111Offset{p114t_name(site,"borrow_fields"),p114t_local(site,"borrow_heap"),p114t_local(site,"borrow_field_bytes")}],
    nt_append(N111Stmt,p128bf_fields(buffer,count,site,0,mask),[N111Set{dest,N111U64{},N111Const{count,0}}]))

@unsafe
def p131u_build(+term: KTerm) -> List<&2,P131UEntry>:
  nt_choose(List<&2,P131UEntry>,p98_tag_eq(term,"Var"),
    u => [P131UEntry{ix(term),1,1}],u =>
    nt_choose(List<&2,P131UEntry>,p98_tag_eq(term,"Mat") && U32.is_eq(terms_len(ks(term)),2),
      v => p131u_merge(p131u_build(kid(term,0)),p131u_build(kid(term,1)),1),v =>
      nt_choose(List<&2,P131UEntry>,p98_tag_eq(term,"NWPattern"),
        w => p131u_rows(ks(term)),w => p131u_list(ks(term)))))



@unsafe
def p131u_list(terms: List<&2,KTerm>) -> List<&2,P131UEntry>:
  match terms:
    case Nil{}: []
    case Con{head,rest}: p131u_merge(p131u_build(head),p131u_list(rest),0)



@unsafe
def p131u_rows(rows: List<&2,KTerm>) -> List<&2,P131UEntry>:
  match rows:
    case Nil{}: []
    case Con{row,rest}: p131u_merge(p131u_build(kid(row,0)),p131u_rows(rest),2)



@unsafe
def w5c_p131i_leaf(+mask: U32, +tree: KDef, +d: KDef, +hash: U32, +stored: U32, bucket: List<&2, KDef>) -> KDef:
  match mask:
    case 0: KIndexLeaf{hash, Con{d, index_remove(bucket, dn(d))}}
    case _: w5c_p131i_join(U32.and(hash, mask), stored, tree, d, hash, mask)

@unsafe
def p137qi_plain(body: List<&2,P113DStmt>) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{P113DScalar{stmt},rest}: p137qi_scalar(stmt) && p137qi_plain(rest)
    case Con{P113DCall{destinations,target,args},rest}: p137qi_plain(rest)
    case Con{P113DIf{condition,yes,no},rest}: p137qi_plain(yes) && p137qi_plain(no) && p137qi_plain(rest)
    case _: False{}


@unsafe
def p143cp_childless(+definition: KDef) -> Bool:
  p88_string_eq(dk(definition),"Def") && defs_empty(dc(definition))


@unsafe
def p143cg_enough(definitions: List<&2,KDef>, left: U32) -> Bool:
  match definitions left:
    case _ 0: True{}
    case Nil{} _: False{}
    case Con{definition,rest} +n:
      p143cg_enough(rest,nt_choose(U32,p143cp_childless(definition),
        u => U32.sub(n,1),u => n))

@unsafe
def p164a_segment(+owner: String, +arity: U32) -> N111Segment:
  N111Segment{owner,arity,1,0,0,p164a_body(owner,arity)}



@unsafe
def p164a_shape(segment: N111Segment) -> Bool:
  match segment:
    case N111Segment{+owner,+arity,result,incoming,flags,body}:
      U32.is_le(arity,64) && U32.is_eq(result,1) && U32.is_eq(incoming,0) && U32.is_eq(flags,0) &&
        p134v_list(~N111Stmt,~p134v_scalar,body,p164a_body(owner,arity))



@unsafe
def w7c_w6_alias_hit(absent: Bool, +e: KDef, +name: String) -> String:
  match absent:
    case True{}: name
    case False{}: nm(dt(e))

@unsafe
def w6_canon_args(args: List<&2,N111Arg>, +st: W6CState) -> W6CState:
  match args:
    case Nil{}: st
    case Con{N111Arg{typ,val},rest}:
      match st:
        case W6CState{+locals,next,chunks,fuel}:
          w6_canon_args(rest,W6CState{locals,next,Con{"," ++ w6_type_tag(typ) ++ ":" ++ w6_canon_val(locals,val),chunks},fuel})

@unsafe
def p168v_callable(+name: String, arity: U32, result: U32, +entry: KDef) -> Bool:
  agy_str_eq(dk(entry),"P164Adapter") && agy_str_eq(dn(entry),name) &&
    agy_str_eq(tg(dt(entry)),"Ref") && U32.is_eq(da(entry),arity) &&
    U32.is_eq(dx(entry),0) && U32.is_eq(result,1)



@unsafe
def p171s_constructor_rows(rows: List<&2,KDef>) -> List<&2,KDef>:
  match rows:
    case Nil{}: []
    case Con{+head,+rest}:
      nt_choose(List<&2,KDef>,defs_empty(dc(head)),
        u => p171s_constructor_rows(rest),u => Con{head,p171s_constructor_rows(rest)})

@unsafe
def p177s_entry(t,id,value):
  w7c_subst(t,id,value,0)

@unsafe
def p185cc_fast(+dest: String, +ctor: String, +buffer: String, +count: U32, +site: U32) -> List<&2,N111Stmt>:
  +cls = p185cc_class(count)
  nt_append(N111Stmt,
    [N111Load{p114t_name(site,"cold_heap"),N111Ptr{},N111Local{"state"},0},
     N111Bin{p114t_name(site,"cold_bytes"),N111U64{},"shl",p114t_local(site,"cold_head"),N111Const{3,0}},
     N111Offset{p114t_name(site,"cold_fields"),p114t_local(site,"cold_heap"),p114t_local(site,"cold_bytes")},
     N111Load{p114t_name(site,"cold_next"),N111U64{},p114t_local(site,"cold_fields"),0},
     N111Load{p114t_name(site,"cold_length"),N111U64{},p114t_local(site,"cold_allocator"),U32.mul(U32.add(32,cls),8)}],
    nt_append(N111Stmt,p185cc_reads(buffer,count,site,0),
      nt_append(N111Stmt,
        [N111Store{N111U64{},p114t_local(site,"cold_allocator"),U32.mul(cls,8),p114t_local(site,"cold_next")},
         N111Bin{p114t_name(site,"cold_remaining"),N111U64{},"sub",p114t_local(site,"cold_length"),N111Const{nt_choose(U32,U32.is_le(count,2),u => count,u => 4),0}},
         N111Store{N111U64{},p114t_local(site,"cold_allocator"),U32.mul(U32.add(32,cls),8),p114t_local(site,"cold_remaining")}],
        nt_append(N111Stmt,p185cc_writes(count,site,0),
          [N111Bin{p114t_name(site,"cold_cid"),N111U64{},"shl",N111CtorId{ctor},N111Const{40,0}},
           N111Bin{p114t_name(site,"cold_tag"),N111U64{},"or",p114t_local(site,"cold_cid"),N111Const{0,33554432}},
           N111Bin{dest,N111U64{},"or",p114t_local(site,"cold_tag"),p114t_local(site,"cold_head")}]))))

@unsafe
def p185cc_cached(+stmt: N111Stmt, dest: String, ctor: String, buffer: String, +count: U32, +site: U32) -> List<&2,N111Stmt>:
  [N111Load{p114t_name(site,"cold_allocator"),N111Ptr{},N111Local{"state"},8},
   N111Load{p114t_name(site,"cold_head"),N111U64{},p114t_local(site,"cold_allocator"),U32.mul(p185cc_class(count),8)},
   N111Bin{p114t_name(site,"cold_nonempty"),N111U64{},"ne",p114t_local(site,"cold_head"),N111Const{0,0}},
   N111If{p114t_local(site,"cold_nonempty"),p185cc_fast(dest,ctor,buffer,count,site),[stmt]}]

# This structured expansion is shared by QBE and direct x86. Its original
# call remains the slow branch at both guards. The caller renders each
# generated statement once, so that slow call is never recursively expanded.
@unsafe
def p185pt_take(+name: String, +word: N111Value, +count: U32, +n: U32) -> List<&2,N111Stmt>:
  nt_choose(List<&2,N111Stmt>,p185pt_admitted(name,word,count),
    u => p185pt_single(name,word,n),u => p185pt_previous(name,word,count,n))
# Renderer-only proof at p134e_registered's verified IDs/final-tables pairing.
# No source names are reserved or inserted. Proof occupies otherwise absent
# N111Id.value metadata and is stripped before every new pairing. Raw/manual
# IDs, incomplete tables and unsupported capabilities keep the dynamic guard.

@unsafe
def p186rt_guard(stmt: N111Stmt, buffer: String, +count: U32, +site: U32, finish: List<&2,N111Stmt>) -> P114TExpansion:
  P114TExpansion{[
    N111Load{p114t_name(site,"transfer_caps"),N111U64{},N111Symbol{"p111_program"},88},
    N111Bin{p114t_name(site,"transfer_live"),N111U64{},"and",p114t_local(site,"transfer_caps"),N111Const{4,0}},
    N111If{p114t_local(site,"transfer_live"),
      nt_append(N111Stmt,p186rt_reads(buffer,count,site,0),
        nt_append(N111Stmt,p186rt_writes(count,site,0),finish)),[stmt]}],True{}}

@unsafe
def x188_many(chunks: List<&2,X188Seq>) -> X188Seq:
  x188_finish(nt_reverse(X188Seq,chunks,[]))

def x188_operand_text(operand: X187Operand) -> String:
  match operand:
    case X187Reg{index,width,vector}:
      nt_choose(String,vector,u => "%xmm" ++ U32.show(index),u => x188_gpr_text(index,width))
    case X187Imm{lo,hi}: "$" ++ p111q_u64(lo,hi)
    case X187Mem{base,disp}: x188_signed32(disp) ++ "(" ++ x188_gpr_text(base,64) ++ ")"
    case X187Rip{symbol,+lo,+hi}: symbol ++ nt_choose(String,U32.is_eq(lo,0) && U32.is_eq(hi,0),u => "",u => "+" ++ p111q_u64(lo,hi)) ++ "(%rip)"
    case X187Target{symbol}: symbol
    case X187Indexed{base,index,scale,disp}:
      x188_signed32(disp) ++ "(" ++ x188_gpr_text(base,64) ++ "," ++ x188_gpr_text(index,64) ++ "," ++ U32.show(scale) ++ ")"

@unsafe
def x188_operands_text(operands: List<&2,X187Operand>, separator: String) -> String:
  match operands:
    case Nil{}: ""
    case Con{head,rest}: separator ++ x188_operand_text(head) ++ x188_operands_text(rest,", ")

def x188_datum_text(datum: P111QDatum) -> String:
  match datum:
    case P111QByte{value}: ".byte " ++ U32.show(value) ++ "\n"
    case P111QWord{value}: ".long " ++ U32.show(value) ++ "\n"
    case P111QLong{lo,hi}: ".quad " ++ p111q_u64(lo,hi) ++ "\n"
    case P111QReloc{symbol,offset}: ".quad " ++ symbol ++ "+" ++ U32.show(offset) ++ "\n"
    case P111QZeros{bytes}: ".zero " ++ U32.show(bytes) ++ "\n"

@unsafe
def w4_body_uses_state(body: List<&2,P113DStmt>) -> Bool:
  match body:
    case Nil{}: False{}
    case Con{P113DScalar{s},rest}: w4_scalar_state(s) || w4_body_uses_state(rest)
    case Con{P113DIf{c,yes,no},rest}:
      w4_val_state(c) || w4_body_uses_state(yes) || w4_body_uses_state(no) || w4_body_uses_state(rest)
    case Con{P113DCall{_,_,_},rest}: True{}
    case Con{P113DResult{vs},rest}: w4_vals_state(vs) || w4_body_uses_state(rest)
    case Con{P113DAgain{vs},rest}: w4_vals_state(vs) || w4_body_uses_state(rest)

@unsafe
def x198w_calc(+id: U32) -> X188Seq:
  nt_choose(X188Seq,U32.is_eq(id,24),u => x188_i2("movq",X187Mem{10,0},x188_reg(11,64)),u =>
    nt_choose(X188Seq,U32.is_eq(id,25),v => x188_i2("movl",X187Mem{10,0},x188_reg(11,32)),v =>
      nt_choose(X188Seq,U32.is_eq(id,63),w =>
        x188_many([x188_i2("movq",X187Mem{10,0},x188_reg(11,64)),x188_i2("subq",X187Mem{10,8},x188_reg(11,64)),
          x188_i2("movabsq",X187Imm{0,0},x188_reg(10,64)),x188_i2("cmovbq",x188_reg(10,64),x188_reg(11,64))]),w =>
        x188_many([x188_i2("movq",X187Mem{10,0},x188_reg(11,64)),x188_i2("cmpq",X187Mem{10,8},x188_reg(11,64)),
          x188_i1("setb",x188_reg(11,8)),x188_i2("movzbl",x188_reg(11,8),x188_reg(11,32))]))))

@unsafe
def x192_float_to_u32_core() -> X188Seq:
  x188_many([x188_i2("movd",x188_xmm(0),x188_reg(10,32)),
    x188_i2("xorl",x188_reg(11,32),x188_reg(11,32)),
    x188_i2("cmpl",X187Imm{1333788672,0},x188_reg(10,32)),
    x188_i2("cmovael",x188_reg(11,32),x188_reg(10,32)),
    x188_i2("movd",x188_reg(10,32),x188_xmm(0)),
    x188_i2("cvttss2siq",x188_xmm(0),x188_reg(10,64))])

@unsafe
def x192_u32_to_float_core() -> X188Seq:
  x188_many([x188_i2("movd",x188_xmm(0),x188_reg(10,32)),
    x188_i2("pxor",x188_xmm(0),x188_xmm(0)),
    x188_i2("cvtsi2ssq",x188_reg(10,64),x188_xmm(0)),
    x188_i2("movd",x188_xmm(0),x188_reg(10,32))])

@unsafe
def x185_float_compare(id: U32) -> X188Seq:
  match id:
    case 30: x188_many([x188_i1("sete",x188_reg(10,8)),x188_i1("setnp",x188_reg(11,8)),x188_i2("andb",x188_reg(11,8),x188_reg(10,8))])
    case 31: x188_many([x188_i1("setne",x188_reg(10,8)),x188_i1("setp",x188_reg(11,8)),x188_i2("orb",x188_reg(11,8),x188_reg(10,8))])
    case 32: x188_many([x188_i1("setb",x188_reg(10,8)),x188_i1("setnp",x188_reg(11,8)),x188_i2("andb",x188_reg(11,8),x188_reg(10,8))])
    case 33: x188_many([x188_i1("setbe",x188_reg(10,8)),x188_i1("setnp",x188_reg(11,8)),x188_i2("andb",x188_reg(11,8),x188_reg(10,8))])
    case 34: x188_i1("seta",x188_reg(10,8))
    case _: x188_i1("setae",x188_reg(10,8))

# Direct MOVD reads the low word and clears the rest of its XMM destination.
# A register result also clears its full64 upper half; a stack result must
# retain the old zero-extended64 store rather than writing only four bytes.
@unsafe
def agy_copy_words(+srcReg: U32, +dstReg: U32, +tmpReg: U32, +count: U32, +index: U32) -> X188Seq:
  nt_choose(X188Seq,U32.is_eq(index,count),u => X188Empty{},u =>
    x188_many([
      x188_i2("movq",X187Mem{srcReg,U32.mul(index,8)},x188_reg(tmpReg,64)),
      x188_i2("movq",x188_reg(tmpReg,64),X187Mem{dstReg,U32.mul(index,8)}),
      agy_copy_words(srcReg,dstReg,tmpReg,count,U32.inc(index))]))

@unsafe
def agy_rfc_check_fields(+count: U32, +index: U32, +frame: X181Frame, +lbase: U32, +slow: String) -> X188Seq:
  nt_choose(X188Seq,U32.is_eq(index,count),u => X188Empty{},u =>
    +off = U32.mul(index,8)
    +ltriv = x181_label(U32.add(lbase,U32.mul(index,3)),frame)
    +lok = x181_label(U32.add(lbase,U32.add(U32.mul(index,3),1)),frame)
    x188_many([
      x188_i2("movq",X187Mem{10,off},x188_reg(0,64)),
      x188_i2("movq",x188_reg(0,64),X187Mem{2,off}),
      x188_i2("testq",x188_reg(0,64),x188_reg(0,64)),
      x188_i1("jge",X187Target{ltriv}),
      x188_i2("shlq",X187Imm{24,0},x188_reg(0,64)),
      x188_i2("shrq",X187Imm{24,0},x188_reg(0,64)),
      x188_i2("movq",X187Indexed{9,0,8,0},x188_reg(8,64)),
      x188_i2("andl",X187Imm{16777215,0},x188_reg(8,32)),
      x188_i2("cmpl",X187Imm{16777210,0},x188_reg(8,32)),
      x188_i1("jae",X187Target{slow}),
      x188_i1("jmp",X187Target{lok}),
      x188_label(ltriv),
      x188_i2("shrq",X187Imm{56,0},x188_reg(0,64)),
      x188_i2("cmpq",X187Imm{2,0},x188_reg(0,64)),
      x188_i1("jae",X187Target{slow}),
      x188_label(lok),
      agy_rfc_check_fields(count,U32.inc(index),frame,lbase,slow)]))

@unsafe
def agy_rfc_bump_fields(+count: U32, +index: U32, +frame: X181Frame, +lbase: U32) -> X188Seq:
  nt_choose(X188Seq,U32.is_eq(index,count),u => X188Empty{},u =>
    +off = U32.mul(index,8)
    +lbump = x181_label(U32.add(lbase,U32.add(U32.mul(index,3),2)),frame)
    x188_many([
      x188_i2("movq",X187Mem{2,off},x188_reg(0,64)),
      x188_i2("testq",x188_reg(0,64),x188_reg(0,64)),
      x188_i1("jge",X187Target{lbump}),
      x188_i2("shlq",X187Imm{24,0},x188_reg(0,64)),
      x188_i2("shrq",X187Imm{24,0},x188_reg(0,64)),
      x188_i2("movq",X187Indexed{9,0,8,0},x188_reg(8,64)),
      x188_i2("addq",X187Imm{1,0},x188_reg(8,64)),
      x188_i2("movq",x188_reg(8,64),X187Indexed{9,0,8,0}),
      x188_label(lbump),
      agy_rfc_bump_fields(count,U32.inc(index),frame,lbase)]))

law agy_reuse_stmts_use:
  for +target: String
  for stmts: List<&2,P113DStmt>
  Bool

@unsafe
def agy_reuse_stmt_uses(+target: String, stmt: P113DStmt) -> Bool:
  match stmt:
    case P113DScalar{s}: agy_reuse_nstmt_uses(target,s)
    case P113DIf{c,yes,no}: agy_reuse_val_uses(target,c) || agy_reuse_stmts_use(target,yes) || agy_reuse_stmts_use(target,no)
    case P113DCall{ds,t,args}: agy_reuse_vals_use(target,args)
    case P113DResult{vs}: agy_reuse_vals_use(target,vs)
    case P113DAgain{vs}: agy_reuse_vals_use(target,vs)

@unsafe
def agy_reuse_stmts_use(target,stmts):
  match stmts:
    case Nil{}: False{}
    case Con{s,rest}: agy_reuse_stmt_uses(target,s) || agy_reuse_stmts_use(target,rest)

@unsafe
def x186_call_slot(+slot: KDef, +bytes: U32) -> U32:
  nt_choose(U32,agy_str_eq(dk(slot),"X181Stack") && U32.is_ge(da(slot),48) &&
      U32.is_le(da(slot),bytes) && U32.is_eq(dx(slot),8),u => 1,u =>
  nt_choose(U32,agy_str_eq(dk(slot),"X181Buffer") && U32.is_gt(da(slot),40) &&
      U32.is_le(da(slot),bytes) && U32.is_gt(dx(slot),0) &&
      U32.is_le(dx(slot),U32.sub(da(slot),40)),u => 1,u =>
  nt_choose(U32,agy_str_eq(dk(slot),"X181Register") && U32.is_lt(da(slot),5),u => 1,u =>
  nt_choose(U32,agy_str_eq(dk(slot),"X185Transient") && U32.is_lt(da(slot),5),u => 2,u => 0))))

@unsafe
def agy_call_pick_ready(todo: List<&2,AgyCallMove>, +all: List<&2,AgyCallMove>) -> AgyCallPick:
  match todo:
    case Nil{}: AgyCallPickNone{}
    case Con{+m,+rest}:
      match m:
        case AgyCallMove{dstIdx,dstReg,srcReg,typ,value}:
          nt_choose(AgyCallPick,Bool.not(agy_call_other_reads(dstReg,dstIdx,all)),
            u => AgyCallPick{m,rest},
            u => agy_call_pick_cons(m,agy_call_pick_ready(rest,all)))

@unsafe
def x181_load_slot(+slot: KDef, +reg: X187Operand) -> X188Seq:
  nt_choose(X188Seq,agy_str_eq(dk(slot),"X181Stack"),
    u => x188_i2("movq",X187Mem{5,U32.sub(0,da(slot))},reg),u =>
  nt_choose(X188Seq,agy_str_eq(dk(slot),"X181Buffer"),
    u => x188_i2("leaq",X187Mem{5,U32.sub(0,da(slot))},reg),u =>
  nt_choose(X188Seq,agy_str_eq(dk(slot),"X181Register"),
    u => x188_i2("movq",x181_reg(da(slot)),reg),u =>
  nt_choose(X188Seq,agy_str_eq(dk(slot),"X185Transient"),
    v => x188_i2("movq",x185_transient_reg(da(slot)),reg),
    v => x188_error("x181: missing local slot")))))

@unsafe
def x188_id_found(+found: KDef, reg: X187Operand) -> X188Seq:
  nt_choose(X188Seq,agy_str_eq(dk(found),"N111Id"),
    u => x188_i2("movabsq",X187Imm{da(found),0},reg),u => x188_error("x181: missing native ID"))

@unsafe
def x181_store_slot(+slot: KDef, +reg: X187Operand) -> X188Seq:
  nt_choose(X188Seq,agy_str_eq(dk(slot),"X181UnusedState"),u => X188Empty{},u =>
  nt_choose(X188Seq,agy_str_eq(dk(slot),"X181Stack"),
    u => x188_i2("movq",reg,X187Mem{5,U32.sub(0,da(slot))}),u =>
  nt_choose(X188Seq,agy_str_eq(dk(slot),"X181Register"),
    u => x188_i2("movq",reg,x181_reg(da(slot))),u =>
  nt_choose(X188Seq,agy_str_eq(dk(slot),"X185Transient"),
    v => x188_i2("movq",reg,x185_transient_reg(da(slot))),
    v => x188_error("x181: invalid destination slot")))))

@unsafe
def x181_bin_instruction(+typ: N111Type, +op: String) -> X188Seq:
  +suffix = x181_width(typ,"q","l")
  +left = x188_width_reg(typ,10)
  +right = x188_width_reg(typ,11)
  +condition = x181_condition(op)
  +alu = x181_alu(op)
  nt_choose(X188Seq,Bool.not(String.is_empty(condition)),u =>
    x188_many([x188_i2("cmp" ++ suffix,right,left),x188_i1("set" ++ condition,x188_reg(10,8)),
      x188_i2("movzbl",x188_reg(10,8),x188_reg(10,32))]),u =>
    nt_choose(X188Seq,String.is_empty(alu),u => X188Empty{},u =>
      nt_choose(X188Seq,x181_shift(op),v =>
        x188_many([x188_i2("movl",x188_reg(11,32),x188_reg(1,32)),x188_i2(alu ++ suffix,x188_reg(1,8),left)]),
        v => x188_i2(alu ++ suffix,right,left))))

@unsafe
def w4_mul_imm(+typ: N111Type, +lo: U32, +hi: U32, +left: X187Operand, +narrow: X187Operand) -> X188Seq:
  +suffix = x181_width(typ,"q","l")
  nt_choose(X188Seq,U32.is_eq(hi,0) && U32.is_eq(lo,0),
    u => x188_i2("xorl",narrow,narrow),u =>
  nt_choose(X188Seq,U32.is_eq(hi,0) && U32.is_ge(lo,2) && U32.is_eq(U32.and(lo,U32.sub(lo,1)),0),
    v => x188_i2("shl" ++ suffix,X187Imm{w4_pow2_log(lo,0),0},left),v =>
    X188Empty{}))

@unsafe
def x185_late_transport(expansion: P114TExpansion) -> List<&2,N111Stmt>:
  match expansion:
    case P114TExpansion{body,changed}: x185_late_accessors(body)

@unsafe
def w4_bf_mask_read(+rest: List<&2,P113DStmt>, read: P128BFRead) -> U32:
  match read:
    case P128BFRead{dest,term,buffer,ctor,count}: w4_bf_scan_loads(buffer,count,rest,0)
    case _: 255

@unsafe
def w5_succ_expand(+stmt: N111Stmt, +site: U32) -> P114TExpansion:
  match stmt:
    case N111Call{+dest,N111U64{},+symbol,args}:
      nt_choose(P114TExpansion,agy_str_eq(symbol,"p111_rt_special_ctor"),
        u => w5_succ_args(stmt,dest,site,args),
        u => P114TExpansion{[stmt],False{}})
    case _: P114TExpansion{[stmt],False{}}

@unsafe
def x181_register_consider(name: String, +reads: U32, slot: KDef,
  +best: X181RegisterChoice) -> X181RegisterChoice:
  match best:
    case X181RegisterChoice{oldName,oldReads}:
      nt_choose(X181RegisterChoice,U32.is_gt(reads,oldReads) && agy_str_eq(dk(slot),"X181Stack"),
        u => X181RegisterChoice{name,reads},u => best)

@unsafe
def x185_physical_slot(+slot: KDef) -> X185Physical:
  nt_choose(X185Physical,agy_str_eq(dk(slot),"X181Register"),u => x185_physical_callee(da(slot)),
    u => nt_choose(X185Physical,agy_str_eq(dk(slot),"X185Transient"),u => x185_physical_transient(da(slot)),
      u => X185PhysicalNone{}))

@unsafe
def x190_operand_instruction(+typ: N111Type, +op: String,
    +wide: X187Operand, +narrow: X187Operand, +byte: X187Operand, +right: X187Operand) -> X188Seq:
  +suffix = x181_width(typ,"q","l")
  +left = x188_physical_width(typ,wide,narrow)
  +condition = x181_condition(op)
  +alu = x181_alu(op)
  nt_choose(X188Seq,Bool.not(String.is_empty(condition)),u =>
    x188_many([x188_i2("cmp" ++ suffix,right,left),x188_i1("set" ++ condition,byte),x188_i2("movzbl",byte,narrow)]),u =>
    nt_choose(X188Seq,String.is_empty(alu),v => X188Empty{},v =>
      nt_choose(X188Seq,x181_shift(op),w =>
        x188_many([x188_i2("movl",x188_reg(11,32),x188_reg(1,32)),x188_i2(alu ++ suffix,x188_reg(1,8),left)]),
        w => x188_i2(alu ++ suffix,right,left))))

@unsafe
def x194_cr_applicable(+typ: N111Type, +op: String, +wide: X187Operand, right: X185Physical) -> Bool:
  match right:
    case X185Physical{rw,rn,rb}:
      x194_cr_enabled() && x188_operand_same(rw,wide) && x190_branch_width(typ) && x194_cr_op(op)
    case _: False{}

# Test cheap physical/operation conditions before querying the left frame home.
@unsafe
def x185_sf_overlap(facts: List<&2,X185ScratchCell>, +buffer: String, +offset: U32,
    +typ: N111Type) -> List<&2,X185ScratchCell>:
  match facts:
    case Nil{}: []
    case Con{+cell,+rest}:
      match cell:
        case X185ScratchCell{+other,+start,+width,value}:
          nt_choose(List<&2,X185ScratchCell>,agy_str_eq(buffer,other) &&
              U32.is_lt(offset,U32.add(start,x185_sf_width(width))) &&
              U32.is_lt(start,U32.add(offset,x185_sf_width(typ))),
            u => x185_sf_overlap(rest,buffer,offset,typ),
            u => Con{cell,x185_sf_overlap(rest,buffer,offset,typ)})

@unsafe
def x185_sf_find(facts: List<&2,X185ScratchCell>, +buffer: String, +offset: U32,
    +typ: N111Type) -> Maybe<&2,N111Value>:
  match facts:
    case Nil{}: None{}
    case Con{X185ScratchCell{other,start,width,value},rest}:
      nt_choose(Maybe<&2,N111Value>,agy_str_eq(buffer,other) && U32.is_eq(offset,start) &&
          U32.is_eq(p111v_type(typ),p111v_type(width)),
        u => Some{value},u => x185_sf_find(rest,buffer,offset,typ))

@unsafe
def x186_sf_inline(effect: X186InlineOp, facts: List<&2,X185ScratchCell>) -> List<&2,X185ScratchCell>:
  match effect:
    case X186InlineF32{destination,id,buffer}: x185_sf_written(facts,destination)
    case _: []

@unsafe
def x186_p_same(+a: KDef, +b: KDef) -> Bool:
  Bool.not(agy_str_eq(dk(a),"Absent")) && agy_str_eq(dk(a),dk(b)) && U32.is_eq(da(a),da(b))

@unsafe
def x186_p_word_home(+slot: KDef, +destination: Bool) -> Bool:
  (agy_str_eq(dk(slot),"X181Stack") && U32.is_ge(da(slot),48) && U32.is_eq(U32.mod(da(slot),8),0) && U32.is_eq(dx(slot),8)) ||
  (agy_str_eq(dk(slot),"X181Register") && U32.is_le(da(slot),4) &&
    (Bool.not(destination) || U32.is_gt(da(slot),0))) ||
  (agy_str_eq(dk(slot),"X185Transient") && U32.is_lt(da(slot),5))

@unsafe
def x186_p_dest_used(+home: KDef, moves: List<&2,X186Move>) -> Bool:
  match moves:
    case Nil{}: False{}
    case Con{X186Move{destination,source,other,read},rest}: x186_p_same(home,other) || x186_p_dest_used(home,rest)

@unsafe
def x186_p_self(moves: List<&2,X186Move>) -> List<&2,X186Move>:
  match moves:
    case Nil{}: []
    case Con{+move,+rest}:
      match move:
        case X186Move{destination,source,home,read}:
          nt_choose(List<&2,X186Move>,x186_p_same(home,read),u => x186_p_self(rest),u => Con{move,x186_p_self(rest)})

@unsafe
def x186_p_read(+home: KDef, moves: List<&2,X186Move>) -> Bool:
  match moves:
    case Nil{}: False{}
    case Con{X186Move{destination,source,other,read},rest}: x186_p_same(home,read) || x186_p_read(home,rest)

@unsafe
def x190_load_direct(typ: N111Type, offset: U32, dest: X187Operand, base: X185Physical) -> X188Seq:
  match base:
    case X185Physical{X187Reg{index,width,vector},narrow,byte}:
      x188_i2(x181_width(typ,"movq","movl"),X187Mem{index,offset},dest)
    case _: X188Empty{}

# Only two known physical operands can bypass both snapshots. Their homes are
# outside selector scratch registers, and this instruction preserves base=value.
@unsafe
def x190_store_direct(+typ: N111Type, offset: U32, base: X185Physical, value: X185Physical) -> X188Seq:
  match base:
    case X185Physical{X187Reg{index,width,vector},narrow,byte}:
      match value:
        case X185Physical{wide,narrow,byte}:
          x188_i2(x181_width(typ,"movq","movl"),x188_physical_width(typ,wide,narrow),X187Mem{index,offset})
        case _: X188Empty{}
    case _: X188Empty{}

@unsafe
def x190_narrow_slot(+slot: KDef, +dest: X187Operand) -> X188Seq:
  x190_narrow_physical(slot,dest,x185_physical_slot(slot))

@unsafe
def x190_narrow_physical(+slot: KDef, +dest: X187Operand, physical: X185Physical) -> X188Seq:
  match physical:
    case X185Physical{wide,narrow,byte}: x188_i2("movl",narrow,dest)
    case _: nt_choose(X188Seq,agy_str_eq(dk(slot),"X181Stack"),
      u => x188_i2("movl",X187Mem{5,U32.sub(0,da(slot))},dest),u => X188Empty{})

law x186_ft_insert:
  for +trie: X186FactTrie
  for +item: X186Expr
  for +h: U32
  X186FactTrie

@unsafe
def w5b_ft_ins_side(bit: U32, +stored: U32, +split: U32, l: X186FactTrie, r: X186FactTrie, +item: X186Expr, +h: U32) -> X186FactTrie:
  match bit:
    case 0: X186FTNode{stored,split,x186_ft_insert(l,item,h),r}
    case _: X186FTNode{stored,split,l,x186_ft_insert(r,item,h)}

@unsafe
def w5b_ft_ins_node(below: U32, +trie: X186FactTrie, +stored: U32, +split: U32, l: X186FactTrie, r: X186FactTrie,
    +item: X186Expr, +h: U32, +diff: U32) -> X186FactTrie:
  match below:
    case 0: w5b_ft_ins_side(U32.and(h,split),stored,split,l,r,item,h)
    case _: x186_ft_join(trie,item,h,stored,index_split_bit(diff))

@unsafe
def x186_ft_insert(trie, item, h):
  match trie:
    case X186FTNil{}: X186FTLeaf{h,[item]}
    case X186FTLeaf{stored,items}:
      w5b_ft_ins_leaf(index_split_bit(U32.xor(h,stored)),trie,item,h,stored,items)
    case X186FTNode{stored,split,l,r}:
      +diff = U32.xor(h,stored)
      w5b_ft_ins_node(U32.and(diff,U32.sub(split,1)),trie,stored,split,l,r,item,h,diff)

@unsafe
def x186_ft_rebuild(facts: List<&2,X186Expr>) -> X186FactTrie:
  match facts:
    case Nil{}: X186FTNil{}
    case Con{+f,rest}:
      match f:
        case X186Expr{name,kind,typ,op,left,right}:
          x186_ft_insert(x186_ft_rebuild(rest),f,x186_expr_hash(kind,p111v_type(typ),op,left,right))

law x186_at_insert:
  for +trie: X186AliasTrie
  for +item: X186Alias
  for +h: U32
  X186AliasTrie

@unsafe
def w5b_at_ins_side(bit: U32, +stored: U32, +split: U32, l: X186AliasTrie, r: X186AliasTrie, +item: X186Alias, +h: U32) -> X186AliasTrie:
  match bit:
    case 0: X186ATNode{stored,split,x186_at_insert(l,item,h),r}
    case _: X186ATNode{stored,split,l,x186_at_insert(r,item,h)}

@unsafe
def w5b_at_ins_node(below: U32, +trie: X186AliasTrie, +stored: U32, +split: U32, l: X186AliasTrie, r: X186AliasTrie,
    +item: X186Alias, +h: U32, +diff: U32) -> X186AliasTrie:
  match below:
    case 0: w5b_at_ins_side(U32.and(h,split),stored,split,l,r,item,h)
    case _: x186_at_join(trie,item,h,stored,index_split_bit(diff))

@unsafe
def x186_at_insert(trie, item, h):
  match trie:
    case X186ATNil{}: X186ATLeaf{h,[item]}
    case X186ATLeaf{stored,items}:
      w5b_at_ins_leaf(index_split_bit(U32.xor(h,stored)),trie,item,h,stored,items)
    case X186ATNode{stored,split,l,r}:
      +diff = U32.xor(h,stored)
      w5b_at_ins_node(U32.and(diff,U32.sub(split,1)),trie,stored,split,l,r,item,h,diff)

@unsafe
def x186_at_rebuild(aliases: List<&2,X186Alias>) -> X186AliasTrie:
  match aliases:
    case Nil{}: X186ATNil{}
    case Con{+a,rest}:
      match a:
        case X186Alias{name,val}:
          x186_at_insert(x186_at_rebuild(rest),a,index_hash(name,2166136261))

@unsafe
def x186_e_value_t(value: N111Value, aliasTrie: X186AliasTrie) -> N111Value:
  match value:
    case N111Local{name}: x186_e_alias_t(aliasTrie,name)
    case _: value

@unsafe
def w5b_ft_prune(trie: X186FactTrie, +name: String) -> X186FactTrie:
  match trie:
    case X186FTNil{}: X186FTNil{}
    case X186FTLeaf{stored,items}: w5b_ft_leaf_wrap(stored,x186_e_kill_facts(items,name))
    case X186FTNode{stored,split,l,r}: w5b_ft_node(stored,split,w5b_ft_prune(l,name),w5b_ft_prune(r,name))

@unsafe
def w5b_ft_prune_if(same: Bool, ft: X186FactTrie, +name: String) -> X186FactTrie:
  match same:
    case True{}: ft
    case False{}: w5b_ft_prune(ft,name)

@unsafe
def w5b_at_prune_if(same: Bool, at: X186AliasTrie, +name: String) -> X186AliasTrie:
  match same:
    case True{}: at
    case False{}: w5b_at_prune(at,name)

law x186_e_find:
  for facts: List<&2,X186Expr>
  for +kind: U32
  for +typ: N111Type
  for +op: String
  for +left: N111Value
  for +right: N111Value
  Maybe<&2,String>

@unsafe
def w5_e_find_if(hit: Bool, name: String, rest: List<&2,X186Expr>, +kind: U32, +typ: N111Type, +op: String,
    +left: N111Value, +right: N111Value) -> Maybe<&2,String>:
  match hit:
    case True{}: Some{name}
    case False{}: x186_e_find(rest,kind,typ,op,left,right)

@unsafe
def x186_e_find(facts, kind, typ, op, left, right):
  match facts:
    case Nil{}: None{}
    case Con{X186Expr{name,other,width,operation,+a,+b},rest}:
      w5_e_find_if(U32.is_eq(kind,other) && U32.is_eq(p111v_type(typ),p111v_type(width)) &&
          String.eq(op,operation) &&
          ((x186_e_equal(left,a) && x186_e_equal(right,b)) ||
           (U32.is_eq(kind,0) && w4_cse_comm(op) && x186_e_equal(left,b) && x186_e_equal(right,a))),
        name,rest,kind,typ,op,left,right)

@unsafe
def w5_as_sel_no(+cond: N111Value, +a: String, +ta: N111Type, +va: N111Value, na: W4CSelArm) -> W5Sel:
  match na:
    case W4CSelArm{+b,+tb,+vb}:
      nt_choose(W5Sel,
        w4c_sel_val(cond) && agy_str_eq(a,b) && Bool.not(x181_register_reserved(a)) &&
          w4c_sel_width(ta) && U32.is_eq(p111v_type(ta),p111v_type(tb)) &&
          w4c_sel_val(va) && w4c_sel_val(vb),
        u => W5Sel{cond,a,ta,va,vb},
        u => W5SelNone{})
    case W4CSelArmNone{}: W5SelNone{}

@unsafe
def w5_nc_def_arm(arm: W4CSelArm, +dst: String, +typW: U32, +origX: String, +cName: String,
    +acc: List<&2,W5NatArm>) -> W5NatChain:
  match arm:
    case W4CSelArm{+adst,+atyp,+aval}:
      nt_choose(W5NatChain,
        agy_str_eq(adst,dst) && U32.is_eq(p111v_type(atyp),typW) && w5_nc_val_ok(aval,dst,origX,cName),
        u => W5NatChain{acc,aval},
        u => W5NatChainNone{})
    case W4CSelArmNone{}: W5NatChainNone{}

law w4c_su_body:
  for body: List<&2,P113DStmt>
  for +seq: U32
  List<&2,P113DStmt>

@unsafe
def w4c_su_check_second(+x1: String, +t1: N111Type, +op1: String, +l1: N111Value, +r1: N111Value,
    +s2: P113DStmt, +rest: List<&2,P113DStmt>, +seq: U32) -> List<&2,P113DStmt>:
  match s2:
    case P113DScalar{N111Bin{+x2,+t2,+op2,+l2,+r2}}:
      +dblXor = agy_str_eq(op1,"xor") && agy_str_eq(op2,"xor") &&
        w4c_su_is_const1(r1) && w4c_su_is_const1(r2) && w4c_su_is_local(l2,x1) &&
        Bool.not(w4c_su_is_local(l1,x1)) &&
        Bool.not(x181_register_reserved(x2)) && w4c_sel_width(t1) && w4c_sel_width(t2)
      nt_choose(List<&2,P113DStmt>,dblXor,
        u =>
          +outTyp = nt_choose(N111Type,U32.is_eq(p111v_type(t1),1) || U32.is_eq(p111v_type(t2),1),
            z => N111U32{},z => N111U64{})
          Con{P113DScalar{N111Bin{x1,t1,op1,l1,r1}},
            w4c_su_body(Con{P113DScalar{N111Set{x2,outTyp,l1}},rest},seq)},
        u => nt_choose(List<&2,P113DStmt>,agy_str_eq(x1,x2) && Bool.not(x181_register_reserved(x1)) && w4k_pure_bin(op1),
          v =>
            +fresh = x1 ++ "_w4s" ++ U32.show(seq)
            +st1 : P113DStmt = P113DScalar{N111Bin{fresh,t1,op1,l1,r1}}
            +st2 : P113DStmt = P113DScalar{N111Bin{x2,t2,op2,w4c_su_subst(l2,x1,fresh),w4c_su_subst(r2,x1,fresh)}}
            Con{st1,w4c_su_body(Con{st2,rest},U32.inc(seq))},
          v => Con{P113DScalar{N111Bin{x1,t1,op1,l1,r1}},w4c_su_body(Con{s2,rest},seq)}))
    case _: Con{P113DScalar{N111Bin{x1,t1,op1,l1,r1}},w4c_su_body(Con{s2,rest},seq)}

@unsafe
def w4c_su_pair(s1: P113DStmt, s2: P113DStmt, rest: List<&2,P113DStmt>, +seq: U32) -> List<&2,P113DStmt>:
  match s1:
    case P113DScalar{N111Bin{x1,t1,op1,l1,r1}}: w4c_su_check_second(x1,t1,op1,l1,r1,s2,rest,seq)
    case P113DIf{cond,yes,no}:
      Con{P113DIf{cond,w4c_su_body(yes,seq),w4c_su_body(no,U32.add(seq,1000))},w4c_su_body(Con{s2,rest},U32.add(seq,2000))}
    case _: Con{s1,w4c_su_body(Con{s2,rest},seq)}

@unsafe
def w4c_su_body(body,seq):
  match body:
    case Nil{}: []
    case Con{s1,Con{s2,rest}}: w4c_su_pair(s1,s2,rest,seq)
    case Con{P113DIf{cond,yes,no},Nil{}}: [P113DIf{cond,w4c_su_body(yes,seq),w4c_su_body(no,U32.add(seq,1000))}]
    case Con{h,Nil{}}: [h]

@unsafe
def x190_v_values(values: List<&2,N111Value>, +state: X190Values) -> List<&2,N111Value>:
  match values:
    case Nil{}: []
    case Con{head,rest}: Con{x190_v_value(head,state),x190_v_values(rest,state)}

@unsafe
def x190_v_args(args: List<&2,N111Arg>, +state: X190Values) -> List<&2,N111Arg>:
  match args:
    case Nil{}: []
    case Con{N111Arg{typ,value},rest}: Con{N111Arg{typ,x190_v_value(value,state)},x190_v_args(rest,state)}

@unsafe
def w5b_typ_eq(a: N111Type, b: N111Type) -> Bool:
  U32.is_eq(p111v_type(a),p111v_type(b))

law x186_f_has_scalars:
  for body: List<&2,N111Stmt>
  Bool

@unsafe
def x186_f_has_scalar(+stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Call{name,typ,symbol,args}: x186_f_admitted(x186_inline_op(stmt))
    case N111If{condition,yes,no}:
      nt_choose(Bool,x186_f_has_scalars(yes),u => True{},u => x186_f_has_scalars(no))
    case _: False{}

@unsafe
def x186_f_has_scalars(body):
  match body:
    case Nil{}: False{}
    case Con{head,rest}: nt_choose(Bool,x186_f_has_scalar(head),u => True{},u => x186_f_has_scalars(rest))

law x186_f_has_body:
  for body: List<&2,P113DStmt>
  Bool

@unsafe
def x186_f_has_stmt(stmt: P113DStmt) -> Bool:
  match stmt:
    case P113DScalar{scalar}: x186_f_has_scalar(scalar)
    case P113DIf{condition,yes,no}:
      nt_choose(Bool,x186_f_has_body(yes),u => True{},u => x186_f_has_body(no))
    case _: False{}

@unsafe
def x186_f_has_body(body):
  match body:
    case Nil{}: False{}
    case Con{head,rest}: nt_choose(Bool,x186_f_has_stmt(head),u => True{},u => x186_f_has_body(rest))

law w2_stmts_reads:
  for +name: String
  for body: List<&2,N111Stmt>
  Bool

@unsafe
def w2_scalar_reads(+name: String, stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Set{d,t,v}: w2_val_reads(name,v)
    case N111Bin{d,t,op,l,r}: w2_val_reads(name,l) || w2_val_reads(name,r)
    case N111Load{d,t,b,off}: w2_val_reads(name,b)
    case N111Store{t,b,off,v}: w2_val_reads(name,b) || w2_val_reads(name,v)
    case N111Offset{d,b,by}: w2_val_reads(name,b) || w2_val_reads(name,by)
    case N111Alloca{d,by,al}: False{}
    case N111Call{d,t,sym,args}: w2_args_reads(name,args)
    case N111If{c,yes,no}: w2_val_reads(name,c) || w2_stmts_reads(name,yes) || w2_stmts_reads(name,no)
    case N111Return{v}: w2_val_reads(name,v)

@unsafe
def w2_stmts_reads(name,body):
  match body:
    case Nil{}: False{}
    case Con{head,rest}: w2_scalar_reads(name,head) || w2_stmts_reads(name,rest)

@unsafe
def w2_typ_eq(a: N111Type, b: N111Type) -> Bool:
  U32.is_eq(p111v_type(a),p111v_type(b))

@unsafe
def w2_int_cmp_imm(+typ: N111Type, right: N111Value, +dst: X187Operand) -> X188Seq:
  match right:
    case N111Const{+lo,0}:
      nt_choose(X188Seq,U32.is_eq(p111v_type(typ),1) || U32.is_le(lo,2147483647),
        u => x188_i2(x181_width(typ,"cmpq","cmpl"),X187Imm{lo,0},dst),
        u => X188Empty{})
    case _: X188Empty{}

@unsafe
def w2_phys_dst(lh: X185Physical, +typ: N111Type) -> X187Operand:
  match lh:
    case X185Physical{wide,narrow,byte}: nt_choose(X187Operand,U32.is_eq(p111v_type(typ),1),u => narrow,u => wide)
    case _: x188_width_reg(typ,10)

@unsafe
def w4_carried_idxs(cs: List<&2,W4Carried>) -> List<&2,U32>:
  match cs:
    case Nil{}: []
    case Con{W4Carried{n,idx,xmm},rest}: Con{idx,w4_carried_idxs(rest)}

law x194fv_clean_body:
  for body: List<&2,P113DStmt>
  Bool

@unsafe
def x194fv_clean_scalar(stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Set{name,typ,value}: x194fv_name(name) && x194fv_clean_value(value)
    case N111Bin{name,typ,op,left,right}: x194fv_name(name) && x194fv_clean_value(left) && x194fv_clean_value(right)
    case N111Load{name,typ,base,offset}: x194fv_name(name) && x194fv_clean_value(base)
    case N111Store{typ,base,offset,value}: x194fv_clean_value(base) && x194fv_clean_value(value)
    case N111Offset{name,base,bytes}: x194fv_name(name) && x194fv_clean_value(base) && x194fv_clean_value(bytes)
    case N111Alloca{name,bytes,align}: x194fv_name(name)
    case N111Call{name,typ,symbol,args}: x194fv_name(name) && x194fv_clean_args(args)
    case N111If{condition,yes,no}: x194fv_clean_value(condition) &&
      x194fv_clean_body(x181_scalar_rows(yes)) && x194fv_clean_body(x181_scalar_rows(no))
    case N111Return{value}: x194fv_clean_value(value)

@unsafe
def x194fv_clean_stmt(stmt: P113DStmt) -> Bool:
  match stmt:
    case P113DScalar{scalar}: x194fv_clean_scalar(scalar)
    case P113DIf{condition,yes,no}: x194fv_clean_value(condition) && x194fv_clean_body(yes) && x194fv_clean_body(no)
    case P113DCall{names,target,args}: x194fv_names(names) && x194fv_clean_values(args)
    case P113DResult{values}: x194fv_clean_values(values)
    case P113DAgain{values}: x194fv_clean_values(values)

@unsafe
def x194fv_clean_body(body):
  match body:
    case Nil{}: True{}
    case Con{stmt,rest}: x194fv_clean_stmt(stmt) && x194fv_clean_body(rest)

# All operands in an overwrite row still read the previous definition first.
# An ordinary U64 copy is safe even when its new value is noncanonical: its
# destination retains its original name, and that write kills the alias.
@unsafe
def w5b_l_edges_start(+any: U32, rows: List<&2,U32>, +bit: U32, +before: U32, +after: U32, +writes: U32, +aw: U32) -> List<&2,U32>:
  match any:
    case 0: rows
    case _: w5b_l_edges_go(rows,bit,before,after,writes,aw,any)

@unsafe
def x190_l_edges(rows: List<&2,U32>, +bit: U32, +before: U32, +after: U32, +writes: U32) -> List<&2,U32>:
  +aw = U32.or(after,writes)
  w5b_l_edges_start(U32.or(before,aw),rows,bit,before,after,writes,aw)

@unsafe
def x190_j_choose(+groups: List<&2,U32>, +bit: U32, +edges: U32, +position: U32, enabled: Bool) -> U32:
  +caller = nt_choose(U32,enabled,u => x190_j_pick(x190_j_callers(groups),bit,edges,position,4),u => 9)
  nt_choose(U32,U32.is_lt(caller,9),u => caller,u => x190_j_pick(groups,bit,edges,position,0))

@unsafe
def x190_j_color(names: List<&2,String>, rows: List<&2,U32>, +params: List<&2,String>,
    +bit: U32, +groups: List<&2,U32>) -> List<&2,U32>:
  match names rows:
    case Con{name,rest} Con{edges,more}:
      x190_j_color(rest,more,params,U32.shl(bit),
        x190_l_group(groups,x190_j_choose(groups,bit,edges,x190_l_position(name,params,0),x190_caller_first_enabled()),bit))
    case _ _: groups

# Affinities only choose among already legal colors; they never merge names
# or alter interference. A narrow copy may share a dead source, while the
# unchanged write/live-out edges prevent truncating a source that survives.
@unsafe
def x190_a_choose(+groups: List<&2,U32>, partners: U32, +bit: U32, +edges: U32, +position: U32) -> U32:
  +preferred = x190_a_pick(groups,partners,bit,edges,position,0)
  nt_choose(U32,U32.is_lt(preferred,9),u => preferred,
    u => x190_j_choose(groups,bit,edges,position,x190_caller_first_enabled()))

@unsafe
def x190_j_valid(names: List<&2,String>, rows: List<&2,U32>, +params: List<&2,String>,
    +bit: U32, +groups: List<&2,U32>) -> Bool:
  match names rows:
    case Nil{} Nil{}: U32.is_eq(nt_count(U32,groups),9)
    case Con{name,rest} Con{edges,more}:
      x190_j_valid_groups(groups,bit,edges,x190_l_position(name,params,0),0,False{}) &&
        x190_j_valid(rest,more,params,U32.shl(bit),groups)
    case _ _: False{}

@unsafe
def x190_branch_shape(+name: String, typ: N111Type, op: String, condition: N111Value) -> Bool:
  match condition:
    case N111Local{other}:
      agy_str_eq(name,other) && x190_branch_width(typ) && Bool.not(x181_register_reserved(name)) &&
        Bool.not(String.is_empty(x181_condition(op)))
    case _: False{}

# Count a subset of actual reads: each is a branch immediately preceded by
# the comparison defining its condition. Scan every original node once, also
# descending into both arms; counting a pair never skips the branch's body.
@unsafe
def x190_branch_id_imm(+typ: N111Type, +found: KDef, destination: X187Operand) -> X188Seq:
  nt_choose(X188Seq,agy_str_eq(dk(found),"N111Id") && U32.is_le(da(found),2147483647),
    u => x188_i2(x181_width(typ,"cmpq","cmpl"),X187Imm{da(found),0},destination),
    u => X188Empty{})

def x190_branch_operand(typ: N111Type, physical: X185Physical, fallback: X187Operand) -> X187Operand:
  match physical:
    case X185Physical{wide,narrow,byte}: x188_physical_width(typ,wide,narrow)
    case _: fallback

@unsafe
def x192_address_rows(rows: List<&2,X192AddressRow>) -> List<&2,P113DStmt>:
  match rows:
    case Nil{}: []
    case Con{X192AddressPlain{stmt},rest}: Con{stmt,x192_address_rows(rest)}
    case Con{X192AddressMemory{operation},rest}: nt_append(P113DStmt,x191_rows(operation),x192_address_rows(rest))

@unsafe
def w4_qm_mul_d(+d: U32) -> X188Seq:
  nt_choose(X188Seq,U32.is_eq(d,3),u => x188_i2("leaq",X187Indexed{0,0,2,0},x188_reg(0,64)),u =>
  nt_choose(X188Seq,U32.is_eq(d,5),v => x188_i2("leaq",X187Indexed{0,0,4,0},x188_reg(0,64)),v =>
  nt_choose(X188Seq,U32.is_eq(d,9),w => x188_i2("leaq",X187Indexed{0,0,8,0},x188_reg(0,64)),w =>
    x188_many([x188_i2("movl",X187Imm{d,0},x188_reg(11,32)),x188_i2("imull",x188_reg(11,32),x188_reg(0,32))]))))

law x197d_work:
  for todo: List<&2,X188Seq>
  for output: List<&2,X188Seq>
  X188Seq

@unsafe
def x197d_admit(displacement: Maybe<&2,U32>, +source: U32, +destination: U32,
    +after: List<&2,X188Seq>, original: X187Parsed, rest: List<&2,X188Seq>, +output: List<&2,X188Seq>) -> X188Seq:
  match displacement:
    case Some{disp}:
      nt_choose(X188Seq,x197d_flags_dead(after,16),
        u => x197d_work(after,Con{x188_i2("leaq",X187Mem{source,disp},x188_reg(destination,64)),output}),
        u => x197d_work(rest,Con{X188One{original},output}))
    case None{}: x197d_work(rest,Con{X188One{original},output})

@unsafe
def x197d_second(next: Maybe<&2,X197DHead>, source: U32, +destination: U32,
    original: X187Parsed, rest: List<&2,X188Seq>, output: List<&2,X188Seq>) -> X188Seq:
  match next:
    case Some{X197DHead{PInst{X187Instruction{op,[X187Imm{lo,hi},X187Reg{target,64,False{}}]}},after}}:
      x197d_admit(nt_choose(Maybe<&2,U32>,U32.is_eq(target,destination),
        u => x197d_displacement(op,lo,hi),u => None{}),source,destination,after,original,rest,output)
    case _: x197d_work(rest,Con{X188One{original},output})

@unsafe
def x197d_step(+item: X187Parsed, +rest: List<&2,X188Seq>, +output: List<&2,X188Seq>) -> X188Seq:
  match item:
    case PInst{X187Instruction{op,[X187Reg{+source,64,False{}},X187Reg{+destination,64,False{}}]}}:
      nt_choose(X188Seq,agy_str_eq(op,"movq") && x191_ff_register(source) &&
          x191_ff_register(destination) && Bool.not(U32.is_eq(source,destination)),
        u => x197d_second(x197d_next(rest),source,destination,item,rest,output),
        u => x197d_work(rest,Con{X188One{item},output}))
    case _: x197d_work(rest,Con{X188One{item},output})

@unsafe
def x197d_work(todo,output):
  match todo:
    case Nil{}: x188_finish(output)
    case Con{X188Empty{},rest}: x197d_work(rest,output)
    case Con{X188Join{left,right},rest}: x197d_work(Con{left,Con{right,rest}},output)
    case Con{X188One{item},rest}: x197d_step(item,rest,output)

@unsafe
def x197d_select(code: X188Seq) -> X188Seq:
  x197d_work([code],[])

# W4-4 Pass 3: General x86-64 machine peephole (self-movq, double xor 1, bool01*x, sub 1; cmp 0).
law w4_peep_list:
  for items: List<&2,X187Parsed>
  for +out: List<&2,X188Seq>
  List<&2,X188Seq>

@unsafe
def w4_peep_bool_mul(+r: U32, +rest: List<&2,X187Parsed>, +out: List<&2,X188Seq>) -> List<&2,X188Seq>:
  match rest:
    case Con{PInst{X187Instruction{+mop,[X187Reg{+sr,+sw,False{}},X187Reg{+dr,+dw,False{}}]}},+tail}:
      nt_choose(List<&2,X188Seq>,(agy_str_eq(mop,"imulq") || agy_str_eq(mop,"imull")) &&
          U32.is_eq(sr,r) && U32.is_eq(sw,dw) && Bool.not(U32.is_eq(sr,dr)) &&
          Bool.not(U32.is_eq(sr,11)) && Bool.not(U32.is_eq(dr,11)) &&
          w4_peep_flags_dead_list(tail,16),
        u => nt_choose(List<&2,X188Seq>,U32.is_eq(sw,64),
          v => w4_peep_list(tail,Con{x188_many([
            x188_i2("xorl",x188_reg(11,32),x188_reg(11,32)),
            x188_i2("subq",x188_reg(sr,64),x188_reg(11,64)),
            x188_i2("andq",x188_reg(11,64),x188_reg(dr,64))]),out}),
          v => w4_peep_list(tail,Con{x188_many([
            x188_i2("xorl",x188_reg(11,32),x188_reg(11,32)),
            x188_i2("subl",x188_reg(sr,32),x188_reg(11,32)),
            x188_i2("andl",x188_reg(11,32),x188_reg(dr,32))]),out})),
        u => w4_peep_list(rest,out))
    case _: w4_peep_list(rest,out)

@unsafe
def w4_peep_after_setcc(+r: U32, +rest: List<&2,X187Parsed>, +out: List<&2,X188Seq>) -> List<&2,X188Seq>:
  match rest:
    case Con{PInst{X187Instruction{+x1,[X187Imm{1,0},X187Reg{+r1,+w1,False{}}]}},
         Con{PInst{X187Instruction{+x2,[X187Imm{1,0},X187Reg{+r2,+w2,False{}}]}},+tail}}:
      nt_choose(List<&2,X188Seq>,(agy_str_eq(x1,"xorl") || agy_str_eq(x1,"xorq")) &&
          (agy_str_eq(x2,"xorl") || agy_str_eq(x2,"xorq")) &&
          U32.is_eq(r1,r) && U32.is_eq(r2,r) && w4_peep_flags_dead_list(tail,16),
        u => w4_peep_bool_mul(r,tail,out),
        u => w4_peep_bool_mul(r,rest,out))
    case _: w4_peep_bool_mul(r,rest,out)

@unsafe
def w4_peep_sub_cmp(+rest: List<&2,X187Parsed>, +i0: X187Parsed, +i1: X187Parsed, +out: List<&2,X188Seq>,
    +subop: String, +cmpop: String, +r1: U32, +r2: U32, +w1: U32, +w2: U32) -> List<&2,X188Seq>:
  match rest:
    case Con{PInst{X187Instruction{+jop,[X187Target{tgt}]}},_}:
      nt_choose(List<&2,X188Seq>,((agy_str_eq(subop,"subq") && agy_str_eq(cmpop,"cmpq") && U32.is_eq(w1,64) && U32.is_eq(w2,64)) ||
          (agy_str_eq(subop,"subl") && agy_str_eq(cmpop,"cmpl") && U32.is_eq(w1,32) && U32.is_eq(w2,32))) &&
          U32.is_eq(r1,r2) && w4_peep_is_jz_jnz(jop),
        u => w4_peep_list(rest,Con{X188One{i0},out}),
        u => w4_peep_list(Con{i1,rest},Con{X188One{i0},out}))
    case _: w4_peep_list(Con{i1,rest},Con{X188One{i0},out})

@unsafe
def w4_peep_mem_inc(+c: U32, +r: U32, +b: U32, +idx: U32, +sc: U32, +disp: U32,
    +i0: X187Parsed, +i1: X187Parsed, +rest: List<&2,X187Parsed>, +out: List<&2,X188Seq>) -> List<&2,X188Seq>:
  match rest:
    case Con{PInst{X187Instruction{+mop,[X187Reg{+mr,32,False{}},X187Indexed{+mb,+mi,+ms,+md}]}},+tail}:
      nt_choose(List<&2,X188Seq>,agy_str_eq(mop,"movl") && U32.is_eq(mr,r) &&
          U32.is_eq(mb,b) && U32.is_eq(mi,idx) && U32.is_eq(ms,sc) && U32.is_eq(md,disp) &&
          Bool.not(U32.is_eq(r,b)) && Bool.not(U32.is_eq(r,idx)) &&
          w4_peep_reg_dead(r,tail,16) && w4_peep_flags_dead_list(tail,16),
        u => w4_peep_list(tail,Con{x188_i2("addl",X187Imm{c,0},X187Indexed{b,idx,sc,disp}),out}),
        u => w4_peep_list(Con{i1,rest},Con{X188One{i0},out}))
    case _: w4_peep_list(Con{i1,rest},Con{X188One{i0},out})

@unsafe
def w4_peep_eax_and(+sr: U32, +mask: U32, +i0: X187Parsed, +i1: X187Parsed,
    +rest: List<&2,X187Parsed>, +out: List<&2,X188Seq>) -> List<&2,X188Seq>:
  match rest:
    case Con{PInst{X187Instruction{+mop,[X187Reg{0,64,False{}},X187Reg{+dr,64,False{}}]}},+tail}:
      nt_choose(List<&2,X188Seq>,agy_str_eq(mop,"movq") && U32.is_eq(dr,sr) &&
          Bool.not(U32.is_eq(sr,0)) && w4_peep_reg_dead(0,tail,16) && w4_peep_flags_dead_list(tail,16),
        u => w4_peep_list(tail,Con{x188_i2("andl",X187Imm{mask,0},x188_reg(sr,32)),out}),
        u => w4_peep_list(Con{i1,rest},Con{X188One{i0},out}))
    case _: w4_peep_list(Con{i1,rest},Con{X188One{i0},out})

@unsafe
def w4_peep_shlq_movl(+k: U32, +r1: U32, +i0: X187Parsed, +i1: X187Parsed,
    +rest: List<&2,X187Parsed>, +out: List<&2,X188Seq>) -> List<&2,X188Seq>:
  match i1:
    case PInst{X187Instruction{+mop,[X187Reg{+r2,32,False{}},X187Reg{+r3,32,False{}}]}}:
      nt_choose(List<&2,X188Seq>,agy_str_eq(mop,"movl") &&
          U32.is_eq(r1,r2) && U32.is_eq(r2,r3) && U32.is_ge(k,1) && U32.is_le(k,31) &&
          w4_peep_flags_dead_list(rest,16),
        u => w4_peep_list(rest,Con{x188_i2("shll",X187Imm{k,0},x188_reg(r1,32)),out}),
        u => w4_peep_list(Con{i1,rest},Con{X188One{i0},out}))
    case _: w4_peep_list(Con{i1,rest},Con{X188One{i0},out})

@unsafe
def w4_peep_movabs_add(+c: U32, +r1: U32, +i0: X187Parsed, +i1: X187Parsed,
    +rest: List<&2,X187Parsed>, +out: List<&2,X188Seq>) -> List<&2,X188Seq>:
  match i1:
    case PInst{X187Instruction{+a1,[X187Indexed{+b,+idx,+sc,+disp},X187Reg{+r2,32,False{}}]}}:
      nt_choose(List<&2,X188Seq>,agy_str_eq(a1,"addl") && U32.is_eq(r1,r2) && U32.is_le(c,2147483647),
        u => w4_peep_mem_inc(c,r1,b,idx,sc,disp,i0,i1,rest,out),
        u => w4_peep_list(Con{i1,rest},Con{X188One{i0},out}))
    case _: w4_peep_list(Con{i1,rest},Con{X188One{i0},out})

@unsafe
def w4_peep_movl_and(+sr: U32, +i0: X187Parsed, +i1: X187Parsed,
    +rest: List<&2,X187Parsed>, +out: List<&2,X188Seq>) -> List<&2,X188Seq>:
  match i1:
    case PInst{X187Instruction{+a1,[X187Imm{+mask,0},X187Reg{0,32,False{}}]}}:
      nt_choose(List<&2,X188Seq>,agy_str_eq(a1,"andl") && U32.is_le(mask,2147483647),
        u => w4_peep_eax_and(sr,mask,i0,i1,rest,out),
        u => w4_peep_list(Con{i1,rest},Con{X188One{i0},out}))
    case _: w4_peep_list(Con{i1,rest},Con{X188One{i0},out})

@unsafe
def w4_peep_cmp0_jcc(+r1: U32, +i0: X187Parsed, +i1: X187Parsed,
    +rest: List<&2,X187Parsed>, +out: List<&2,X188Seq>) -> List<&2,X188Seq>:
  match i1:
    case PInst{X187Instruction{+jop,[X187Target{tgt}]}}:
      nt_choose(List<&2,X188Seq>,w4_peep_is_jz_jnz(jop),
        u => w4_peep_list(Con{i1,rest},Con{x188_i2("testq",x188_reg(r1,64),x188_reg(r1,64)),out}),
        u => w4_peep_list(Con{i1,rest},Con{X188One{i0},out}))
    case _: w4_peep_list(Con{i1,rest},Con{X188One{i0},out})

@unsafe
def w4_peep_extra(+i0: X187Parsed, +i1: X187Parsed, +rest: List<&2,X187Parsed>, +out: List<&2,X188Seq>) -> List<&2,X188Seq>:
  match i0:
    case PInst{X187Instruction{+op,[X187Imm{+lo,0},X187Reg{+r1,64,False{}}]}}:
      nt_choose(List<&2,X188Seq>,agy_str_eq(op,"shlq"),
        u => w4_peep_shlq_movl(lo,r1,i0,i1,rest,out),
        u => nt_choose(List<&2,X188Seq>,agy_str_eq(op,"movabsq"),
          v => w4_peep_movabs_add(lo,r1,i0,i1,rest,out),
          v => nt_choose(List<&2,X188Seq>,agy_str_eq(op,"cmpq") && U32.is_eq(lo,0),
            w => w4_peep_cmp0_jcc(r1,i0,i1,rest,out),
            w => w4_peep_list(Con{i1,rest},Con{X188One{i0},out}))))
    case PInst{X187Instruction{+op,[X187Reg{+sr,32,False{}},X187Reg{0,32,False{}}]}}:
      nt_choose(List<&2,X188Seq>,agy_str_eq(op,"movl"),
        u => w4_peep_movl_and(sr,i0,i1,rest,out),
        u => w4_peep_list(Con{i1,rest},Con{X188One{i0},out}))
    case _: w4_peep_list(Con{i1,rest},Con{X188One{i0},out})

@unsafe
def w4_peep_pair(+i0: X187Parsed, +i1: X187Parsed, +rest: List<&2,X187Parsed>, +out: List<&2,X188Seq>) -> List<&2,X188Seq>:
  match i0 i1:
    case PInst{X187Instruction{+sop,[X187Reg{+sr,8,False{}}]}}
         PInst{X187Instruction{+mop,[X187Reg{+mr1,8,False{}},X187Reg{+mr2,32,False{}}]}}:
      nt_choose(List<&2,X188Seq>,w4_peep_is_setcc(sop) && agy_str_eq(mop,"movzbl") &&
          U32.is_eq(sr,mr1) && U32.is_eq(mr1,mr2),
        u => w4_peep_after_setcc(sr,rest,Con{X188One{i1},Con{X188One{i0},out}}),
        u => w4_peep_list(Con{i1,rest},Con{X188One{i0},out}))
    case PInst{X187Instruction{+x1,[X187Imm{1,0},X187Reg{+r1,+w1,False{}}]}}
         PInst{X187Instruction{+x2,[X187Imm{1,0},X187Reg{+r2,+w2,False{}}]}}:
      nt_choose(List<&2,X188Seq>,agy_str_eq(x1,"xorq") && agy_str_eq(x2,"xorq") &&
          U32.is_eq(r1,r2) && U32.is_eq(w1,64) && U32.is_eq(w2,64) && w4_peep_flags_dead_list(rest,16),
        u => w4_peep_list(rest,out),
        u => w4_peep_list(Con{i1,rest},Con{X188One{i0},out}))
    case PInst{X187Instruction{+subop,[X187Imm{1,0},X187Reg{+r1,+w1,False{}}]}}
         PInst{X187Instruction{+cmpop,[X187Imm{0,0},X187Reg{+r2,+w2,False{}}]}}:
      w4_peep_sub_cmp(rest,i0,i1,out,subop,cmpop,r1,r2,w1,w2)
    case _ _: w4_peep_extra(i0,i1,rest,out)

@unsafe
def w5b_peep_selfmov(drop: Bool, +op: String, +a: U32, +b: U32, rest: List<&2,X187Parsed>, +out: List<&2,X188Seq>) -> List<&2,X188Seq>:
  match drop:
    case True{}: w4_peep_list(rest,out)
    case False{}: w4_peep_list(rest,Con{X188One{PInst{X187Instruction{op,[X187Reg{a,64,False{}},X187Reg{b,64,False{}}]}}},out})

@unsafe
def w4_peep_list(items,out):
  match items:
    case Nil{}: out
    case Con{PInst{X187Instruction{+op,[X187Reg{+a,64,False{}},X187Reg{+b,64,False{}}]}},+rest}:
      w5b_peep_selfmov(U32.is_eq(a,b) && String.eq(op,"movq"),op,a,b,rest,out)
    case Con{i0,Con{i1,rest}}: w4_peep_pair(i0,i1,rest,out)
    case Con{h,rest}: w4_peep_list(rest,Con{X188One{h},out})

# W4-4 Pass 4c: Leaf function prologue/epilogue shrink-wrapping.
# If a function makes 0 calls and never references %rbp or %rsp outside its
# standard prologue/epilogue, strip pushq %rbp; movq %rsp, %rbp; subq $N, %rsp
# (and replace callee-save frame slots with pushq/popq, or nothing if 0 saved).
@unsafe
def w4_leaf_finish(res: Maybe<&2,List<&2,X188Seq>>, original: X188Seq) -> X188Seq:
  match res:
    case Some{out}: x188_finish(out)
    case None{}: original

@unsafe
def w4_leaf_body_uses_r12(items: List<&2,X187Parsed>) -> Bool:
  match items:
    case Nil{}: False{}
    case Con{+h,+rest}:
      nt_choose(Bool,w4_leaf_is_r12_init(h) || w4_leaf_is_r12_restore(h),
        u => w4_leaf_body_uses_r12(rest),
        u => w4_leaf_item_uses_r12(h) || w4_leaf_body_uses_r12(rest))

@unsafe
def w4_leaf_shrink_pro(pro: W4LeafPrologue, original: X188Seq) -> X188Seq:
  match pro:
    case W4LeafNone{}: original
    case W4LeafPrologue{prefix,+saved,+body}:
      +dropR12 = w4_leaf_has_r12(saved) && Bool.not(w4_leaf_body_uses_r12(body))
      +effSaved = nt_choose(List<&2,U32>,dropR12,u => w4_leaf_drop_r12_list(saved),u => saved)
      +effBody = nt_choose(List<&2,X187Parsed>,dropR12,u => w4_leaf_strip_r12_init(body),u => body)
      +epilogue = x188_many(nt_append(X188Seq,w4_leaf_pops_rev(effSaved,[]),[x188_i0("ret")]))
      +proSeq = x188_many(nt_append(X188Seq,w4_leaf_wrap_prefix(prefix),w4_leaf_pushes(effSaved)))
      w4_leaf_finish(w4_leaf_rewrite(effBody,saved,epilogue,[proSeq]),original)

law w5c_lbl_insert:
  for +trie: W5BLblTrie
  for +entry: W5BLblEntry
  for +h: U32
  W5BLblTrie

@unsafe
def w5c_lbl_ins_side(bit: U32, +stored: U32, +split: U32, l: W5BLblTrie, r: W5BLblTrie, +entry: W5BLblEntry, +h: U32) -> W5BLblTrie:
  match bit:
    case 0: W5BLNode{stored,split,w5c_lbl_insert(l,entry,h),r}
    case _: W5BLNode{stored,split,l,w5c_lbl_insert(r,entry,h)}

@unsafe
def w5c_lbl_ins_node(below: U32, +trie: W5BLblTrie, +stored: U32, +split: U32, l: W5BLblTrie, r: W5BLblTrie,
    +entry: W5BLblEntry, +h: U32, +diff: U32) -> W5BLblTrie:
  match below:
    case 0: w5c_lbl_ins_side(U32.and(h,split),stored,split,l,r,entry,h)
    case _: w5c_lbl_join(trie,entry,h,stored,index_split_bit(diff))

@unsafe
def w5c_lbl_insert(trie, entry, h):
  match trie:
    case W5BLNil{}: W5BLLeaf{h,[entry]}
    case W5BLLeaf{stored,items}: w5c_lbl_ins_leaf(index_split_bit(U32.xor(h,stored)),trie,entry,h,stored,items)
    case W5BLNode{stored,split,l,r}:
      +diff = U32.xor(h,stored)
      w5c_lbl_ins_node(U32.and(diff,U32.sub(split,1)),trie,stored,split,l,r,entry,h,diff)

@unsafe
def w5c_lbl_build(items: List<&2,X187Parsed>) -> W5BLblTrie:
  match items:
    case Nil{}: W5BLNil{}
    case Con{PLabel{+l},+rest}:
      w5c_lbl_insert(w5c_lbl_build(rest),W5BLblEntry{l,rest},index_hash(l,2166136261))
    case Con{_,rest}: w5c_lbl_build(rest)

law w5c_reg_dead_step_t:
  for +r: U32
  for items: List<&2,X187Parsed>
  for +lbls: W5BLblTrie
  for +budget: U32
  for +hops: U32
  for +seen: List<&2,String>
  Bool

@unsafe
def w5c_reg_dead_at_lbl_t(+r: U32, found: Maybe<&2,List<&2,X187Parsed>>, +lbls: W5BLblTrie,
    +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match found:
    case Some{atTgt}: w5c_reg_dead_step_t(r,atTgt,lbls,budget,hops,seen)
    case None{}: False{}

@unsafe
def w5c_rd_cont_t(stop: Bool, +r: U32, rest: List<&2,X187Parsed>, +lbls: W5BLblTrie, +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match stop:
    case True{}: False{}
    case False{}: w5c_reg_dead_step_t(r,rest,lbls,U32.sub(budget,1),hops,seen)

@unsafe
def w5c_rd_kill_or_cont_t(kill: Bool, +r: U32, rest: List<&2,X187Parsed>, +lbls: W5BLblTrie, +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match kill:
    case True{}: True{}
    case False{}: w5c_reg_dead_step_t(r,rest,lbls,U32.sub(budget,1),hops,seen)

@unsafe
def w5c_rd_wr_if_t(reads: Bool, +dr: U32, +dw: U32, +r: U32, rest: List<&2,X187Parsed>, +lbls: W5BLblTrie, +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match reads:
    case True{}: False{}
    case False{}: w5c_rd_kill_or_cont_t(U32.is_eq(dr,r) && U32.is_ge(dw,32),r,rest,lbls,budget,hops,seen)

@unsafe
def w5c_reg_dead_write_t(+r: U32, args: List<&2,X187Operand>, +rest: List<&2,X187Parsed>,
    +lbls: W5BLblTrie, +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match args:
    case Con{+src,Con{X187Reg{+dr,+dw,False{}},Nil{}}}:
      w5c_rd_wr_if_t(w4b_op_reads_reg(r,src),dr,dw,r,rest,lbls,budget,hops,seen)
    case _: w5c_rd_cont_t(w4b_args_read_reg(r,args),r,rest,lbls,budget,hops,seen)

@unsafe
def w5c_rd_br_seen_hops_t(+hops: U32, +r: U32, rest: List<&2,X187Parsed>, +lbls: W5BLblTrie, +budget: U32, +seen: List<&2,String>) -> Bool:
  match hops:
    case 0: False{}
    case _: w5c_reg_dead_step_t(r,rest,lbls,U32.sub(budget,1),U32.sub(hops,1),seen)

@unsafe
def w5c_rd_br_seen_jmp_t(isJmp: Bool, +r: U32, rest: List<&2,X187Parsed>, +lbls: W5BLblTrie, +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match isJmp:
    case True{}: True{}
    case False{}: w5c_rd_br_seen_hops_t(hops,r,rest,lbls,budget,seen)

@unsafe
def w5c_rd_br_both_t(ok: Bool, +r: U32, +tgt: String, +lbls: W5BLblTrie, +nb: U32, +nh: U32, +seen: List<&2,String>) -> Bool:
  match ok:
    case False{}: False{}
    case True{}: w5c_reg_dead_at_lbl_t(r,w5c_lbl_find(lbls,tgt,index_hash(tgt,2166136261)),lbls,nb,nh,Con{tgt,seen})

@unsafe
def w5c_rd_br_jmp_t(isJmp: Bool, +r: U32, +tgt: String, rest: List<&2,X187Parsed>, +lbls: W5BLblTrie, +nb: U32, +nh: U32, +seen: List<&2,String>) -> Bool:
  match isJmp:
    case True{}: w5c_reg_dead_at_lbl_t(r,w5c_lbl_find(lbls,tgt,index_hash(tgt,2166136261)),lbls,nb,nh,Con{tgt,seen})
    case False{}: w5c_rd_br_both_t(w5c_reg_dead_step_t(r,rest,lbls,nb,nh,seen),r,tgt,lbls,nb,nh,seen)

@unsafe
def w5c_rd_br_hops_t(+hops: U32, +r: U32, +op: String, +tgt: String, rest: List<&2,X187Parsed>, +lbls: W5BLblTrie, +budget: U32, +seen: List<&2,String>) -> Bool:
  match hops:
    case 0: False{}
    case _: w5c_rd_br_jmp_t(String.eq(op,"jmp"),r,tgt,rest,lbls,U32.sub(budget,1),U32.sub(hops,1),seen)

@unsafe
def w5c_rd_br_seen_t(isSeen: Bool, +r: U32, +op: String, +tgt: String, rest: List<&2,X187Parsed>, +lbls: W5BLblTrie, +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match isSeen:
    case True{}: w5c_rd_br_seen_jmp_t(String.eq(op,"jmp"),r,rest,lbls,budget,hops,seen)
    case False{}: w5c_rd_br_hops_t(hops,r,op,tgt,rest,lbls,budget,seen)

@unsafe
def w5c_reg_dead_branch_t(+r: U32, +op: String, args: List<&2,X187Operand>, +rest: List<&2,X187Parsed>,
    +lbls: W5BLblTrie, +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match args:
    case Con{X187Target{+tgt},Nil{}}: w5c_rd_br_seen_t(nb_contains(seen,tgt),r,op,tgt,rest,lbls,budget,hops,seen)
    case _: False{}

@unsafe
def w5c_reg_dead_pop_t(+r: U32, args: List<&2,X187Operand>, +rest: List<&2,X187Parsed>,
    +lbls: W5BLblTrie, +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match args:
    case Con{X187Reg{+dr,+dw,False{}},Nil{}}:
      w5c_rd_kill_or_cont_t(U32.is_eq(dr,r) && U32.is_ge(dw,32),r,rest,lbls,budget,hops,seen)
    case _: False{}

@unsafe
def w5c_rd_alu_if_t(isAlu: Bool, +r: U32, args: List<&2,X187Operand>, rest: List<&2,X187Parsed>,
    +lbls: W5BLblTrie, +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match isAlu:
    case False{}: False{}
    case True{}: w5c_rd_cont_t(w4b_args_read_reg(r,args),r,rest,lbls,budget,hops,seen)

@unsafe
def w5c_rd_setcc_if_t(killed: Bool, +r: U32, +op: String, args: List<&2,X187Operand>, rest: List<&2,X187Parsed>,
    +lbls: W5BLblTrie, +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match killed:
    case True{}: True{}
    case False{}: w5c_rd_alu_if_t(w4b_is_simple_alu(op),r,args,rest,lbls,budget,hops,seen)

@unsafe
def w5c_rd_wo_if_t(isWo: Bool, +r: U32, +op: String, +args: List<&2,X187Operand>, rest: List<&2,X187Parsed>,
    +lbls: W5BLblTrie, +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match isWo:
    case True{}: w5c_reg_dead_write_t(r,args,rest,lbls,budget,hops,seen)
    case False{}: w5c_rd_alu_if_t(w4b_is_simple_alu(op),r,args,rest,lbls,budget,hops,seen)

@unsafe
def w5c_rd_pop_if_t(isPop: Bool, +r: U32, args: List<&2,X187Operand>, rest: List<&2,X187Parsed>,
    +lbls: W5BLblTrie, +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match isPop:
    case True{}: w5c_reg_dead_pop_t(r,args,rest,lbls,budget,hops,seen)
    case False{}: False{}

@unsafe
def w5c_rd_inst_c_t(u: U32, +r: U32, +op: String, +args: List<&2,X187Operand>, +rest: List<&2,X187Parsed>,
    +lbls: W5BLblTrie, +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match u:
    case 114: w5c_rd_ret_if_t(String.eq(op,"ret"),r)
    case 112: w5c_rd_pop_if_t(String.eq(op,"popq"),r,args,rest,lbls,budget,hops,seen)
    case 106: w5c_reg_dead_branch_t(r,op,args,rest,lbls,budget,hops,seen)
    case 115: w5c_rd_setcc_if_t(String.starts_with(op,"set") && w5b_dead_after_setcc(r,args,rest),r,op,args,rest,lbls,budget,hops,seen)
    case _: w5c_rd_wo_if_t(w4b_is_write_only_op(op),r,op,args,rest,lbls,budget,hops,seen)

@unsafe
def w5c_reg_dead_inst_t(+r: U32, +op: String, +args: List<&2,X187Operand>, +rest: List<&2,X187Parsed>,
    +lbls: W5BLblTrie, +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match op:
    case SCon{c,_}: w5c_rd_inst_c_t(Char.to_u32(c),r,op,args,rest,lbls,budget,hops,seen)
    case SNil{}: False{}

@unsafe
def w5c_rd_lbl_seen_t(isSeen: Bool, +r: U32, +lbl: String, rest: List<&2,X187Parsed>,
    +lbls: W5BLblTrie, +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match isSeen:
    case True{}: True{}
    case False{}: w5c_reg_dead_step_t(r,rest,lbls,U32.sub(budget,1),hops,Con{lbl,seen})

@unsafe
def w5c_reg_dead_go_t(+r: U32, items: List<&2,X187Parsed>, +lbls: W5BLblTrie, +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match items:
    case Nil{}: False{}
    case Con{PLabel{+lbl},rest}: w5c_rd_lbl_seen_t(nb_contains(seen,lbl),r,lbl,rest,lbls,budget,hops,seen)
    case Con{PInst{X187Instruction{op,args}},rest}: w5c_reg_dead_inst_t(r,op,args,rest,lbls,budget,hops,seen)
    case _: False{}

@unsafe
def w5c_reg_dead_step_t(r,items,lbls,budget,hops,seen):
  match budget:
    case 0: False{}
    case _: w5c_reg_dead_go_t(r,items,lbls,budget,hops,seen)

@unsafe
def w5c_reg_dead_t(+r: U32, items: List<&2,X187Parsed>, +lbls: W5BLblTrie, +budget: U32) -> Bool:
  w5c_reg_dead_step_t(r,items,lbls,budget,8,[])

@unsafe
def w4b_reg_dead(+r: U32, items: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +budget: U32) -> Bool:
  w4b_reg_dead_step(r,items,fnItems,budget,8,[])

# Shallow instruction extractors (keep bend.ts case trees O(1)).
@unsafe
def w4b_items_reg_mask(items: List<&2,X187Parsed>, +acc: U32) -> U32:
  match items:
    case Nil{}: acc
    case Con{PInst{X187Instruction{_,args}},rest}: w4b_items_reg_mask(rest,w4b_args_reg_mask(args,acc))
    case Con{_,rest}: w4b_items_reg_mask(rest,acc)

@unsafe
def w4b_licm_apply(split: W4BLoopSplit, +orig: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match split:
    case W4BLoopNone{}: orig
    case W4BLoopSplit{before,+lbl,+body}:
      +ms = w4b_collect_magics(body,[])
      +mask = w4b_items_reg_mask(body,0)
      +free = w4b_free_regs([8,9,1,2],mask)
      w4b_licm_finish(w4b_pair_magics(ms,free),before,lbl,body,orig)

@unsafe
def w4b_rotate_finish(exitSplit: W4BExitSplit, before: List<&2,X187Parsed>, +loopLbl: String,
    +bodyLbl: String, +r: U32, +w: U32, orig: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match exitSplit:
    case W4BExitNone{}: orig
    case W4BExitSplit{exitBlk,loopBody}:
      +exitLbl = loopLbl ++ "_exit"
      +rew = w4b_rewrite_backedges(loopBody,loopLbl,bodyLbl,exitLbl,r,w)
      +rew2 = w4b_taildup_check(nt_reverse(X187Parsed,rew,[]),rew,exitLbl)
      nt_append(X187Parsed,before,
        Con{w4b_test_inst(r,w),
          Con{PInst{X187Instruction{"je",[X187Target{exitLbl}]}},
            Con{PLabel{bodyLbl},
              nt_append(X187Parsed,rew2,
                Con{PLabel{exitLbl},exitBlk})}}})

@unsafe
def w4c_rotate_check_test(tr: W4BRR, br: W4BBranch, +before: List<&2,X187Parsed>, +loopLbl: String,
    +afterHdr: List<&2,X187Parsed>, +orig: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match tr br:
    case W4BRR{top,+s,+ws,+d,+wd} W4BBranch{jop,+bodyLbl}:
      nt_choose(List<&2,X187Parsed>,
        U32.is_eq(s,d) && U32.is_eq(ws,wd) &&
        ((agy_str_eq(top,"testq") && U32.is_eq(ws,64)) || (agy_str_eq(top,"testl") && U32.is_eq(ws,32))) &&
        (agy_str_eq(jop,"jne") || agy_str_eq(jop,"jnz")),
        v => w4b_rotate_finish(w5_take_exit_gen(afterHdr,loopLbl,bodyLbl,[],512),before,loopLbl,bodyLbl,s,ws,orig),
        v => orig)
    case _ _: orig

@unsafe
def w4c_rotate_check_cmp(+cmpop: String, +lo: U32, +hi: U32, +r: U32, +w: U32,
    br: W4BBranch, +before: List<&2,X187Parsed>, +loopLbl: String,
    +afterHdr: List<&2,X187Parsed>, +orig: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match br:
    case W4BBranch{jop,+bodyLbl}:
      nt_choose(List<&2,X187Parsed>,
        U32.is_eq(lo,0) && U32.is_eq(hi,0) &&
        ((agy_str_eq(cmpop,"cmpq") && U32.is_eq(w,64)) || (agy_str_eq(cmpop,"cmpl") && U32.is_eq(w,32))) &&
        (agy_str_eq(jop,"jne") || agy_str_eq(jop,"jnz")),
        v => w4b_rotate_finish(w5_take_exit_gen(afterHdr,loopLbl,bodyLbl,[],512),before,loopLbl,bodyLbl,r,w,orig),
        v => orig)
    case W4BBranchNone{}: orig

@unsafe
def w4b_wrap_items(items: List<&2,X187Parsed>, +acc: List<&2,X188Seq>) -> X188Seq:
  match items:
    case Nil{}: x188_finish(acc)
    case Con{h,rest}: w4b_wrap_items(rest,Con{X188One{h},acc})

# W4-10 Pass 3: CFG-aware machine peepholes (addl $c, m32; andl $M, %r32; subq+testq+jne).
law w4c_peep_cfg:
  for items: List<&2,X187Parsed>
  for +fnItems: List<&2,X187Parsed>
  for +out: List<&2,X188Seq>
  List<&2,X188Seq>

@unsafe
def w4c_try_mem_inc_3(+c: U32, +r1: U32, a: W4CMemAdd, m: W4CMemAdd, +i0: X187Parsed, +i1: X187Parsed,
    +i2: X187Parsed, +tail: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +out: List<&2,X188Seq>) -> List<&2,X188Seq>:
  match a:
    case W4CMemAdd{+b,+idx,+sc,+disp,+r2}:
      match m:
        case W4CMemAdd{+mb,+mi,+ms,+md,+mr}:
          nt_choose(List<&2,X188Seq>,
            U32.is_eq(r1,r2) && U32.is_eq(r2,mr) && U32.is_le(c,2147483647) &&
            U32.is_eq(b,mb) && U32.is_eq(idx,mi) && U32.is_eq(sc,ms) && U32.is_eq(disp,md) &&
            Bool.not(U32.is_eq(r1,b)) && Bool.not(U32.is_eq(r1,idx)) &&
            w4b_reg_dead(r1,tail,fnItems,24) && w4_peep_flags_dead_list(tail,16),
            u => w4c_peep_cfg(tail,fnItems,Con{x188_i2("addl",X187Imm{c,0},X187Indexed{b,idx,sc,disp}),out}),
            u => w4c_peep_cfg(Con{i1,Con{i2,tail}},fnItems,Con{X188One{i0},out}))
        case W4CMemAddNone{}: w4c_peep_cfg(Con{i1,Con{i2,tail}},fnItems,Con{X188One{i0},out})
    case W4CMemAddNone{}: w4c_peep_cfg(Con{i1,Con{i2,tail}},fnItems,Con{X188One{i0},out})

@unsafe
def w4c_try_eax_and_3(+sr: U32, im: W4BImmReg, r2: W4BRR, +i0: X187Parsed, +i1: X187Parsed,
    +i2: X187Parsed, +tail: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +out: List<&2,X188Seq>) -> List<&2,X188Seq>:
  match im:
    case W4BImmReg{+aop,+mask,0,0,32}:
      match r2:
        case W4BRR{+mop,0,64,+dr,64}:
          nt_choose(List<&2,X188Seq>,
            agy_str_eq(aop,"andl") && agy_str_eq(mop,"movq") && U32.is_eq(dr,sr) &&
            Bool.not(U32.is_eq(sr,0)) && U32.is_le(mask,2147483647) &&
            w4b_reg_dead(0,tail,fnItems,64) && w4_peep_flags_dead_list(tail,16),
            u => w4c_peep_cfg(tail,fnItems,Con{x188_i2("andl",X187Imm{mask,0},x188_reg(sr,32)),out}),
            u => w4c_peep_cfg(Con{i1,Con{i2,tail}},fnItems,Con{X188One{i0},out}))
        case _: w4c_peep_cfg(Con{i1,Con{i2,tail}},fnItems,Con{X188One{i0},out})
    case _: w4c_peep_cfg(Con{i1,Con{i2,tail}},fnItems,Con{X188One{i0},out})

# ---- W5-R1 Pass 5b: Drop redundant testq %r,%r after subq $1,%r + 0..2 flag-preserving movs ----
@unsafe
def w5_try_sub_mov2(+r1: U32, +i0: X187Parsed, +i1: X187Parsed, +i2: X187Parsed, +i3: X187Parsed,
    tail3: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +out: List<&2,X188Seq>) -> List<&2,X188Seq>:
  match tail3:
    case Con{+i4,+tail4}:
      nt_choose(List<&2,X188Seq>,
        w5_is_mov_not_writing(i1,r1) && w5_is_mov_not_writing(i2,r1) &&
        w5_is_testq_r(i3,r1) && w5_is_jz_jnz_item(i4),
        v => w4c_peep_cfg(Con{i4,tail4},fnItems,Con{X188One{i2},Con{X188One{i1},Con{X188One{i0},out}}}),
        v => w4c_peep_cfg(Con{i1,Con{i2,Con{i3,Con{i4,tail4}}}},fnItems,Con{X188One{i0},out}))
    case Nil{}: w4c_peep_cfg(Con{i1,Con{i2,Con{i3,Nil{}}}},fnItems,Con{X188One{i0},out})

@unsafe
def w5_try_sub_mov_test(+r1: U32, +i0: X187Parsed, +i1: X187Parsed, +i2: X187Parsed,
    tail: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +out: List<&2,X188Seq>) -> List<&2,X188Seq>:
  match tail:
    case Con{+i3,+tail3}:
      nt_choose(List<&2,X188Seq>,
        w5_is_mov_not_writing(i1,r1) && w5_is_testq_r(i2,r1) && w5_is_jz_jnz_item(i3),
        u => w4c_peep_cfg(Con{i3,tail3},fnItems,Con{X188One{i1},Con{X188One{i0},out}}),
        u => w5_try_sub_mov2(r1,i0,i1,i2,i3,tail3,fnItems,out))
    case Nil{}: w4c_peep_cfg(Con{i1,Con{i2,Nil{}}},fnItems,Con{X188One{i0},out})

@unsafe
def w4c_try_sub_test_3(+r1: U32, rr: W4BRR, br: W4BBranch, +i0: X187Parsed, +i1: X187Parsed,
    +i2: X187Parsed, +tail: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +out: List<&2,X188Seq>) -> List<&2,X188Seq>:
  match rr:
    case W4BRR{+top,+ts,64,+td,64}:
      match br:
        case W4BBranch{+jop,_}:
          nt_choose(List<&2,X188Seq>,
            agy_str_eq(top,"testq") && U32.is_eq(ts,td) && U32.is_eq(ts,r1) && w4_peep_is_jz_jnz(jop),
            u => w4c_peep_cfg(Con{i2,tail},fnItems,Con{X188One{i0},out}),
            u => w5_try_sub_mov_test(r1,i0,i1,i2,tail,fnItems,out))
        case W4BBranchNone{}: w5_try_sub_mov_test(r1,i0,i1,i2,tail,fnItems,out)
    case _: w5_try_sub_mov_test(r1,i0,i1,i2,tail,fnItems,out)

@unsafe
def w4c_peep_cfg_rr(rr0: W4BRR, +i0: X187Parsed, +i1: X187Parsed, +i2: X187Parsed,
    +tail: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +out: List<&2,X188Seq>) -> List<&2,X188Seq>:
  match rr0:
    case W4BRR{+op,+sr,32,0,32}:
      nt_choose(List<&2,X188Seq>,agy_str_eq(op,"movl"),
        u => w4c_try_eax_and_3(sr,w4b_as_imm_reg(i1),w4b_as_rr(i2),i0,i1,i2,tail,fnItems,out),
        u => w4c_peep_cfg(Con{i1,Con{i2,tail}},fnItems,Con{X188One{i0},out}))
    case _: w4c_peep_cfg(Con{i1,Con{i2,tail}},fnItems,Con{X188One{i0},out})

@unsafe
def w4c_peep_cfg_imm(im0: W4BImmReg, +i0: X187Parsed, +i1: X187Parsed, +i2: X187Parsed,
    +tail: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +out: List<&2,X188Seq>) -> List<&2,X188Seq>:
  match im0:
    case W4BImmReg{+op,+lo,0,+r1,64}:
      nt_choose(List<&2,X188Seq>,agy_str_eq(op,"movabsq"),
        u => w4c_try_mem_inc_3(lo,r1,w4c_as_addl_mem_reg(i1),w4c_as_movl_reg_mem(i2),i0,i1,i2,tail,fnItems,out),
        u => nt_choose(List<&2,X188Seq>,agy_str_eq(op,"subq") && U32.is_eq(lo,1),
          v => w4c_try_sub_test_3(r1,w4b_as_rr(i1),w4b_as_branch(i2),i0,i1,i2,tail,fnItems,out),
          v => w4c_peep_cfg(Con{i1,Con{i2,tail}},fnItems,Con{X188One{i0},out})))
    case _: w4c_peep_cfg_rr(w4b_as_rr(i0),i0,i1,i2,tail,fnItems,out)

@unsafe
def w4c_peep_cfg(items,fnItems,out):
  match items:
    case Nil{}: out
    case Con{+i0,Con{+i1,Con{+i2,+tail}}}:
      w4c_peep_cfg_imm(w4b_as_imm_reg(i0),i0,i1,i2,tail,fnItems,out)
    case Con{h,rest}: w4c_peep_cfg(rest,fnItems,Con{X188One{h},out})

# ---- W4-11: General x86-64 XMM Spill-Forwarding, Copy-Forwarding,
#             Backedge Coalescing & Dead Stack-Slot Store Elimination ----

@unsafe
def w4c_has_leaq_rbp(items: List<&2,X187Parsed>) -> Bool:
  match items:
    case Nil{}: False{}
    case Con{h,rest}: w4c_inst_is_leaq_rbp(h) || w4c_has_leaq_rbp(rest)

# Count reads and writes of negative-%rbp slots across an instruction list.
@unsafe
def w4c_add_op_read(op: X187Operand, +m: W4CMap) -> W4CMap:
  match op:
    case X187Mem{+b,+d}: nt_choose(W4CMap,w4c_is_neg_rbp(b,d),u => w4c_inc_cnt(m,d),u => m)
    case _: m

@unsafe
def w4c_inst_writes(item: X187Parsed, +m: W4CMap) -> W4CMap:
  match item:
    case PInst{X187Instruction{+op,Con{_,Con{X187Mem{+b,+d},Nil{}}}}}:
      nt_choose(W4CMap,w4c_is_neg_rbp(b,d) && Bool.not(agy_str_eq(op,"cmpq") || agy_str_eq(op,"cmpl") || agy_str_eq(op,"testq") || agy_str_eq(op,"testl") || agy_str_eq(op,"ucomiss")),
        u => w4c_inc_cnt(m,d),u => m)
    case _: m

@unsafe
def w4c_replace_slot(+from: U32, +to: U32, items: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match items:
    case Nil{}: []
    case Con{h,rest}: Con{w4c_replace_inst(from,to,h),w4c_replace_slot(from,to,rest)}

# Direct O(N) early-exit slot checks (ZERO W4CMap trie allocations!)
@unsafe
def w4c_find_def_back(+disp: U32, revPrefix: List<&2,X187Parsed>, +between: List<&2,X187Parsed>) -> W4CDefSplit:
  w4c_find_def_back_f(disp,revPrefix,between,64)

@unsafe
def w4c_drop_dead_stores(items: List<&2,X187Parsed>, +reads: W4CMap, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match items:
    case Nil{}: nt_reverse(X187Parsed,acc,[])
    case Con{+h,+rest}:
      nt_choose(List<&2,X187Parsed>,w4c_is_dead_store(h,reads),
        u => w4c_drop_dead_stores(rest,reads,acc),
        u => w4c_drop_dead_stores(rest,reads,Con{h,acc}))

law w5_xmm_fold:
  for items: List<&2,X187Parsed>
  for +fnItems: List<&2,X187Parsed>
  for +acc: List<&2,X187Parsed>
  List<&2,X187Parsed>

# X2: movaps %xmmA, %xmmB; <fop> src, %xmmB; movaps %xmmB, %xmmA (%xmmB dead) -> <fop> src, %xmmA
@unsafe
def w5_x2_c(+a: U32, +b: U32, +fop: String, +fsrc: X187Operand, m2: W5Movaps,
    +r3: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match m2:
    case W5MAYes{s2,d2}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        U32.is_eq(s2,b) && U32.is_eq(d2,a) &&
        w4c_xmm_dead(b,r3,fnItems,400,2),
        u => Some{w5_xmm_fold(r3,fnItems,Con{PInst{X187Instruction{fop,[fsrc,x188_xmm(a)]}},acc})},
        u => None{})
    case W5MANo{}: None{}

@unsafe
def w5_x2_b(+a: U32, +b: U32, f1: W4CFopAny, +i2: X187Parsed,
    +r3: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match f1:
    case W4CFAYes{fop,fsrc,fdst}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_eq(fdst,b),
        u => w5_x2_c(a,b,fop,fsrc,w5_as_movaps(i2),r3,fnItems,acc),
        u => None{})
    case W4CFANo{}: None{}

# X3: movaps %xmmA, %xmmB; movd disp(%rbp), %xmmA; <addss|mulss> %xmmB, %xmmA (%xmmB dead)
#     -> <addss|mulss> disp(%rbp), %xmmA
@unsafe
def w5_x3_c(+a: U32, +b: U32, +disp: U32, f2: W4CFopAny,
    +r3: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match f2:
    case W4CFAYes{+fop,fsrc,fdst}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        w5_is_comm_fop(fop) && U32.is_eq(fdst,a) && w4c_op_is_xmm(b,fsrc) &&
        w4c_xmm_dead(b,r3,fnItems,400,2),
        u => Some{w5_xmm_fold(r3,fnItems,Con{PInst{X187Instruction{fop,[X187Mem{5,disp},x188_xmm(a)]}},acc})},
        u => None{})
    case W4CFANo{}: None{}

@unsafe
def w5_x3_b(+a: U32, +b: U32, ld1: W5MovdSlot, +i2: X187Parsed,
    +r3: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match ld1:
    case W5MSYes{disp,ldst}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_eq(ldst,a),
        u => w5_x3_c(a,b,disp,w4c_as_fop_any(i2),r3,fnItems,acc),
        u => None{})
    case W5MSNo{}: None{}

# X5: movaps %xmmA, %xmmB; <fop> %xmmB, %xmmC (%xmmB dead) -> <fop> %xmmA, %xmmC
@unsafe
def w5_x5(+a: U32, +b: U32, f1: W4CFopAny, +r2: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match f1:
    case W4CFAYes{+fop,fsrc,+fdst}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        Bool.not(U32.is_eq(b,fdst)) && w4c_op_is_xmm(b,fsrc) && w4c_xmm_dead(b,r2,fnItems,400,2),
        u => Some{w5_xmm_fold(r2,fnItems,Con{PInst{X187Instruction{fop,[x188_xmm(a),x188_xmm(fdst)]}},acc})},
        u => None{})
    case W4CFANo{}: None{}

# X4: movd disp(%rbp), %xmmA; <addss|mulss> %xmmB, %xmmA; movq %xmmA, disp(%rbp) (%xmmA,%xmmB dead)
#     -> <addss|mulss> disp(%rbp), %xmmB; movq %xmmB, disp(%rbp)
@unsafe
def w5_x4_d(+disp: U32, +a: U32, +b: U32, +fop: String, st2: W4CMovqXmmMem,
    +r3: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match st2:
    case W4CMXMYes{sx,sdisp}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        Bool.not(U32.is_eq(a,b)) && U32.is_eq(sx,a) && U32.is_eq(sdisp,disp) &&
        w4c_xmm_dead(a,r3,fnItems,400,2) && w4c_xmm_dead(b,r3,fnItems,400,2),
        u => Some{w5_xmm_fold(r3,fnItems,
          Con{PInst{X187Instruction{"movq",[x188_xmm(b),X187Mem{5,disp}]}},
          Con{PInst{X187Instruction{fop,[X187Mem{5,disp},x188_xmm(b)]}},acc}})},
        u => None{})
    case W4CMXMNo{}: None{}

@unsafe
def w5_x4_c(+disp: U32, +a: U32, +fop: String, fsrc: X187Operand, +st2: W4CMovqXmmMem,
    +r3: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match fsrc:
    case X187Reg{b,_,True{}}: w5_x4_d(disp,a,b,fop,st2,r3,fnItems,acc)
    case _: None{}

@unsafe
def w5_x4_b(+disp: U32, +a: U32, f1: W4CFopAny, +i2: X187Parsed,
    +r3: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match f1:
    case W4CFAYes{+fop,fsrc,fdst}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,w5_is_comm_fop(fop) && U32.is_eq(fdst,a),
        u => w5_x4_c(disp,a,fop,fsrc,w4c_as_movq_xm(i2),r3,fnItems,acc),
        u => None{})
    case W4CFANo{}: None{}

# X6: <movd|movaps|sqrtss> src, %xmmA; movaps %xmmA, %xmmB (%xmmA dead) -> <op> src, %xmmB
@unsafe
def w5_x6_b(+op0: String, +src0: X187Operand, +a: U32, m1: W5Movaps,
    +r2: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match m1:
    case W5MAYes{s1,+b}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        U32.is_eq(s1,a) && Bool.not(U32.is_eq(a,b)) && Bool.not(w4c_op_is_xmm(b,src0)) &&
        w4c_xmm_dead(a,r2,fnItems,400,2),
        u => Some{w5_xmm_fold(r2,fnItems,Con{PInst{X187Instruction{op0,[src0,x188_xmm(b)]}},acc})},
        u => None{})
    case W5MANo{}: None{}

@unsafe
def w5_x6_a(p0: W5XmmProd, +i1: X187Parsed, +r2: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match p0:
    case W5XPYes{op0,src0,a}: w5_x6_b(op0,src0,a,w5_as_movaps(i1),r2,fnItems,acc)
    case W5XPNo{}: None{}

@unsafe
def w5_x6(+i0: X187Parsed, +i1: X187Parsed, +r2: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  w5_x6_a(w5_as_xmm_prod(i0),i1,r2,fnItems,acc)

@unsafe
def w5b_x7_c(+a: U32, +b: U32, +fop: String, +fsrc: X187Operand, st2: W4CMovqXmmMem,
    +r3: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match st2:
    case W4CMXMYes{sx,disp}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        U32.is_eq(sx,b) && Bool.not(w4c_op_is_xmm(a,fsrc)) &&
        w4c_xmm_dead(a,r3,fnItems,400,2) && w4c_xmm_dead(b,r3,fnItems,400,2),
        u => Some{w5_xmm_fold(r3,fnItems,
          Con{PInst{X187Instruction{"movq",[x188_xmm(a),X187Mem{5,disp}]}},
          Con{PInst{X187Instruction{fop,[fsrc,x188_xmm(a)]}},acc}})},
        u => None{})
    case W4CMXMNo{}: None{}

# X9: movaps A,B; <fop1> s1,B; <fop2> s2,B; movq B,disp(%rbp) (A,B dead) -> in-place in A
@unsafe
def w5b_x9_d(+a: U32, +b: U32, +op1: String, +s1: X187Operand, +op2: String, +s2: X187Operand,
    st3: W4CMovqXmmMem, +r4: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>,
    +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match st3:
    case W4CMXMYes{sx,disp}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        U32.is_eq(sx,b) && Bool.not(w4c_op_is_xmm(a,s1)) && Bool.not(w4c_op_is_xmm(a,s2)) &&
        w4c_xmm_dead(a,r4,fnItems,400,2) && w4c_xmm_dead(b,r4,fnItems,400,2),
        u => Some{w5_xmm_fold(r4,fnItems,
          Con{PInst{X187Instruction{"movq",[x188_xmm(a),X187Mem{5,disp}]}},
          Con{PInst{X187Instruction{op2,[s2,x188_xmm(a)]}},
          Con{PInst{X187Instruction{op1,[s1,x188_xmm(a)]}},acc}}})},
        u => None{})
    case W4CMXMNo{}: None{}

@unsafe
def w5b_x9_c(+a: U32, +b: U32, +op1: String, +s1: X187Operand, f2: W4CFopAny, +i3: X187Parsed,
    +r4: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match f2:
    case W4CFAYes{op2,s2,fdst2}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_eq(fdst2,b),
        u => w5b_x9_d(a,b,op1,s1,op2,s2,w4c_as_movq_xm(i3),r4,fnItems,acc),
        u => None{})
    case W4CFANo{}: None{}

@unsafe
def w5b_x9_r3(+a: U32, +b: U32, +op1: String, +s1: X187Operand, +i2: X187Parsed, r3: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match r3:
    case Con{+i3,+r4}: w5b_x9_c(a,b,op1,s1,w4c_as_fop_any(i2),i3,r4,fnItems,acc)
    case Nil{}: None{}

@unsafe
def w5b_x79_b(+a: U32, +b: U32, f1: W4CFopAny, +i2: X187Parsed, +r3: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match f1:
    case W4CFAYes{+op1,+s1,fdst1}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_eq(fdst1,b),
        u => w4c_or_peep_opt(w5b_x7_c(a,b,op1,s1,w4c_as_movq_xm(i2),r3,fnItems,acc),
          v => w5b_x9_r3(a,b,op1,s1,i2,r3,fnItems,acc)),
        u => None{})
    case W4CFANo{}: None{}

# X8: movaps A,B; movaps C,D; <fop> B,D (B dead, A!=D, B!=C, B!=D) -> movaps C,D; <fop> A,D
@unsafe
def w5b_x8_c(+a: U32, +b: U32, +c: U32, +d: U32, f2: W4CFopAny,
    +r3: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match f2:
    case W4CFAYes{+fop,fsrc,fdst}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        U32.is_eq(fdst,d) && w4c_op_is_xmm(b,fsrc) && w4c_xmm_dead(b,r3,fnItems,400,2),
        u => Some{w5_xmm_fold(r3,fnItems,
          Con{PInst{X187Instruction{fop,[x188_xmm(a),x188_xmm(d)]}},
          Con{PInst{X187Instruction{"movaps",[x188_xmm(c),x188_xmm(d)]}},acc}})},
        u => None{})
    case W4CFANo{}: None{}

@unsafe
def w5b_x8_b(+a: U32, +b: U32, m1: W5Movaps, +i2: X187Parsed,
    +r3: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match m1:
    case W5MAYes{c,d}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        Bool.not(U32.is_eq(a,d)) && Bool.not(U32.is_eq(b,c)) && Bool.not(U32.is_eq(b,d)),
        u => w5b_x8_c(a,b,c,d,w4c_as_fop_any(i2),r3,fnItems,acc),
        u => None{})
    case W5MANo{}: None{}

@unsafe
def w5_xmm_fold_ma_r2(+a: U32, +b: U32, +i1: X187Parsed, r2: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match r2:
    case Con{+i2,+r3}:
      w4c_or_peep_opt(w5_x2_b(a,b,w4c_as_fop_any(i1),i2,r3,fnItems,acc),
        v => w4c_or_peep_opt(w5_x3_b(a,b,w5_as_movd_slot(i1),i2,r3,fnItems,acc),
          w => w4c_or_peep_opt(w5b_x79_b(a,b,w4c_as_fop_any(i1),i2,r3,fnItems,acc),
            x => w4c_or_peep_opt(w5b_x8_b(a,b,w5_as_movaps(i1),i2,r3,fnItems,acc),
              y => w5_x5(a,b,w4c_as_fop_any(i1),Con{i2,r3},fnItems,acc)))))
    case Nil{}: w5_x5(a,b,w4c_as_fop_any(i1),[],fnItems,acc)

@unsafe
def w5_xmm_fold_ma(+a: U32, +b: U32, +i0: X187Parsed, +i1: X187Parsed, +r2: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  nt_choose(Maybe<&2,List<&2,X187Parsed>>,U32.is_eq(a,b),
    u => Some{w5_xmm_fold(Con{i1,r2},fnItems,acc)},
    u => w5_xmm_fold_ma_r2(a,b,i1,r2,fnItems,acc))

@unsafe
def w5_xmm_try_ma(ma: W5Movaps, +i0: X187Parsed, +i1: X187Parsed, +r2: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match ma:
    case W5MAYes{a,b}: w5_xmm_fold_ma(a,b,i0,i1,r2,fnItems,acc)
    case W5MANo{}: None{}

@unsafe
def w5_xmm_try_ms(ms: W5MovdSlot, +i1: X187Parsed, +r2: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match ms:
    case W5MSYes{disp,a}:
      match r2:
        case Con{+i2,+r3}: w5_x4_b(disp,a,w4c_as_fop_any(i1),i2,r3,fnItems,acc)
        case Nil{}: None{}
    case W5MSNo{}: None{}

@unsafe
def w5_xmm_fold_step(+i0: X187Parsed, +i1: X187Parsed, +r2: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  w4c_or_peep(w5_xmm_try_ma(w5_as_movaps(i0),i0,i1,r2,fnItems,acc),
    u => w4c_or_peep(w5_xmm_try_ms(w5_as_movd_slot(i0),i1,r2,fnItems,acc),
      v => w4c_or_peep(w5_x6(i0,i1,r2,fnItems,acc),
        w => w5_xmm_fold(Con{i1,r2},fnItems,Con{i0,acc}))))

@unsafe
def w5_xmm_fold(items,fnItems,acc):
  match items:
    case Nil{}: nt_reverse(X187Parsed,acc,[])
    case Con{+i0,Con{+i1,+r2}}: w5_xmm_fold_step(i0,i1,r2,fnItems,acc)
    case Con{+i0,Nil{}}: w5_xmm_fold_last(w5_as_movaps(i0),i0,acc)

# ---- W5-R2: General x86-64 GPR Peepholes (`w5_gpr_peep`) ----

@unsafe
def w5b_g12_found_cmov(+rC: U32, cm: Maybe<&2,X187Parsed>, +mid: List<&2,X187Parsed>,
    +rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match cm:
    case Some{newCmov}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,w4b_reg_dead(rC,rest,fnItems,96),
        w => Some{nt_append(X187Parsed,nt_reverse(X187Parsed,mid,[]),
          Con{PInst{X187Instruction{"testq",[x188_reg(rC,64),x188_reg(rC,64)]}},
          Con{newCmov,rest}})},
        w => None{})
    case None{}: None{}

@unsafe
def w5_scan_flags(items: List<&2,X187Parsed>, +acc: U32) -> U32:
  match items:
    case Nil{}: acc
    case Con{PLabel{_},rest}: w5_scan_flags(rest,U32.or(acc,4))
    case Con{PInst{X187Instruction{+op,args}},rest}:
      +f1 = w5_bit_if(String.eq(op,"imulq"),8,acc)
      +f2 = w5_bit_if(String.eq(op,"call"),16,f1)
      w5_scan_flags(rest,w5_args_flags(args,f2))
    case Con{_,rest}: w5_scan_flags(rest,acc)

@unsafe
def w5b_r12_check(items: List<&2,X187Parsed>, +hasSave: Bool, +hasInit: Bool) -> Bool:
  match items:
    case Nil{}: hasSave && hasInit
    case Con{+h,+rest}:
      nt_choose(Bool,w5b_is_r12_save(h),u => w5b_r12_check(rest,True{},hasInit),
        u => nt_choose(Bool,w5b_is_r12_restore(h),v => w5b_r12_check(rest,hasSave,hasInit),
          v => nt_choose(Bool,w5b_is_r12_ctx_init(h),w => w5b_r12_check(rest,hasSave,True{}),
            w => Bool.not(w5b_item_uses_r12(h)) && w5b_r12_check(rest,hasSave,hasInit))))

@unsafe
def w5b_mark_bad_args(args: List<&2,X187Operand>, +bad: W4CMap) -> W4CMap:
  match args:
    case Nil{}: bad
    case Con{a,rest}: w5b_mark_bad_args(rest,w5b_mark_bad_op(a,bad))

@unsafe
def w5b_rew_one(+disp: U32, +rFree: U32, h: X187Parsed) -> X187Parsed:
  match h:
    case PInst{X187Instruction{op,args}}: PInst{X187Instruction{op,w5b_rew_args(disp,rFree,args)}}
    case other: other

@unsafe
def w5b_rew_items(+disp: U32, +rFree: U32, +dropInit: Bool, items: List<&2,X187Parsed>,
    +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match items:
    case Nil{}: nt_reverse(X187Parsed,acc,[])
    case Con{+h,+rest}:
      nt_choose(List<&2,X187Parsed>,dropInit && w5b_is_r12_ctx_init(h),
        u => w5b_rew_items(disp,rFree,False{},rest,acc),
        u => w5b_rew_items(disp,rFree,dropInit,rest,Con{w5b_rew_one(disp,rFree,h),acc}))

@unsafe
def w5b_reg_dead_fast(+r: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>) -> Bool:
  w4b_reg_dead(r,rest,fnItems,64)

@unsafe
def x199s_bucket(bucket: List<&2,KDef>, +offset: U32) -> Bool:
  match bucket:
    case Nil{}: False{}
    case Con{+h,rest}: (agy_str_eq(dk(h),"X181Stack") && U32.is_eq(da(h),offset) && U32.is_eq(dx(h),8)) || x199s_bucket(rest,offset)

@unsafe
def x199s_owned(slots: KDef, +offset: U32) -> Bool:
  match slots:
    case KIndexLeaf{hash,bucket}: x199s_bucket(bucket,offset)
    case KIndexNode{hash,mask,left,right}: x199s_owned(left,offset) || x199s_owned(right,offset)
    case _: False{}

@unsafe
def x199s_window(items: List<&2,X187Parsed>, +reg: U32, +disp: U32, +label: String, +fuel: U32) -> Bool:
  match items:
    case Con{PInst{X187Instruction{+op,[X187Mem{5,+offset},X187Reg{+dst,+width,False{}}]}},+rest}:
      nt_choose(Bool,U32.is_eq(disp,offset),u =>
        nt_choose(Bool,agy_str_eq(op,"movq") && U32.is_eq(width,64) && x191_ff_register(dst),v => x199s_tail(rest,label,64),v => False{}),
        u => nt_choose(Bool,U32.is_gt(fuel,0) && x199s_plain(op) && Bool.not(U32.is_eq(reg,dst)),v => x199s_window(rest,reg,disp,label,U32.sub(fuel,1)),v => False{}))
    case Con{PInst{X187Instruction{op,[a,b]}},rest}:
      nt_choose(Bool,U32.is_gt(fuel,0) && x199s_plain(op) && Bool.not(x199s_touches(a,reg) || x199s_touches(b,reg)),u =>
        x199s_window(rest,reg,disp,label,U32.sub(fuel,1)),u => False{})
    case _: False{}

@unsafe
def x199s_emit(items: List<&2,X187Parsed>, +found: List<&2,X191FrameStore>, out: List<&2,X188Seq>) -> X188Seq:
  match items:
    case Nil{}: x188_finish(out)
    case Con{item,rest}: x199s_emit(rest,found,Con{x199s_item(item,found),out})

@unsafe
def x199s_finish(found: List<&2,X191FrameStore>, items: List<&2,X187Parsed>, original: X188Seq) -> X188Seq:
  match found:
    case Nil{}: original
    case Con{head,tail}: x199s_emit(items,Con{head,tail},[])

@unsafe
def x191_select_tail(yes: List<&2,P113DStmt>, no: List<&2,P113DStmt>,
    +typ: N111Type, +previous: String, +fuel: U32) -> Maybe<&2,List<&2,String>>:
  match yes no:
    case Nil{} Nil{}: Some{[]}
    case Con{P113DScalar{N111Set{+a,ta,N111Local{sa}}},ar}
         Con{P113DScalar{N111Set{b,tb,N111Local{sb}}},br}:
      nt_choose(Maybe<&2,List<&2,String>>,U32.is_gt(fuel,0) && agy_str_eq(a,b) &&
          Bool.not(x181_register_reserved(a)) && agy_str_eq(sa,previous) && agy_str_eq(sb,previous) &&
          U32.is_eq(p111v_type(ta),p111v_type(typ)) && U32.is_eq(p111v_type(tb),p111v_type(typ)),
        u => x191_select_names(a,x191_select_tail(ar,br,typ,a,U32.sub(fuel,1))),u => None{})
    case _ _: None{}

law w5_mid_safe:
  for stmts: List<&2,P113DStmt>
  for +p: String
  for +n: String
  Bool

@unsafe
def w5_stmt_safe(st: P113DStmt, +p: String, +n: String) -> Bool:
  match st:
    case P113DScalar{sc}: w5_scalar_safe(sc,p,n)
    case P113DIf{cond,yes,no}:
      Bool.not(w5_val_is(cond,p)) && w5_mid_safe(yes,p,n) && w5_mid_safe(no,p,n)
    case P113DCall{dests,_,args}:
      Bool.not(w5_names_has(dests,p)) && Bool.not(w5_names_has(dests,n)) && Bool.not(w5_vals_has(args,p))
    case P113DResult{vs}:
      Bool.not(w5_vals_has(vs,p))
    case P113DAgain{_}: False{}

@unsafe
def w5_mid_safe(stmts,p,n):
  match stmts:
    case Nil{}: True{}
    case Con{st,rest}: w5_stmt_safe(st,p,n) && w5_mid_safe(rest,p,n)

@unsafe
def x198a_copies(body: List<&2,P113DStmt>, +loop: X198ACountdown, +bindings: List<&2,X186Alias>,
    +budget: U32) -> Maybe<&2,List<&2,X186Alias>>:
  match body loop:
    case Nil{} _: Some{bindings}
    case Con{P113DScalar{N111Set{+name,N111U64{},value}},rest} X198ACountdown{+params,+fuel,pred,buffer,ids}:
      +resolved = x186_e_value(value,bindings)
      nt_choose(Maybe<&2,List<&2,X186Alias>>,U32.is_gt(budget,0) && x198a_free(name,loop) &&
        x198a_word(resolved,params) && Bool.not(x185_sf_source(resolved,fuel)),
        u => x198a_copies(rest,loop,Con{X186Alias{name,resolved},bindings},U32.sub(budget,1)),u => None{})
    case _ _: None{}

# Every non-fuel component must be its own incoming word or a constant.
# Parallel rebound inputs can thus be used again without reordering moves.
@unsafe
def x198a_op(+op: String, right: P113KFact, typ: N111Type) -> Bool:
  match right:
    case P113KFact{bits,exact,lo,hi}:
      agy_str_eq(op,"eq") || agy_str_eq(op,"ne") || agy_str_eq(op,"and") || agy_str_eq(op,"or") ||
        agy_str_eq(op,"xor") || ((agy_str_eq(op,"shr") || agy_str_eq(op,"shl")) &&
          U32.is_eq(hi,0) && U32.is_lt(lo,p113k_width(typ)))

def x198_perm_shape(+arg: U32, +id: U32, +slow: String) -> X188Seq:
  x188_many([x188_i2("movq",x198_perm_reg(arg),x198_perm_reg(0)),
    x188_i2("shrq",X187Imm{40,0},x198_perm_reg(0)),
    x188_i2("cmpl",X187Imm{U32.add(131072,id),0},x188_reg(0,32)),x188_i1("jne",X187Target{slow})])

def x198_perm_bound(+arg: U32, +loc: U32, +slow: String) -> X188Seq:
  x188_many([x188_i2("movq",x198_perm_reg(arg),x198_perm_reg(loc)),
    x188_i2("andq",x198_perm_reg(0),x198_perm_reg(loc)),
    x188_i2("cmpq",x198_perm_reg(1),x198_perm_reg(loc)),x188_i1("jb",X187Target{slow})])

@unsafe
def agy_da_stmts_use(body: List<&2,P113DStmt>, +name: String) -> Bool:
  match body:
    case Nil{}: False{}
    case Con{P113DScalar{s},rest}: agy_da_scalar_uses(s,name) || agy_da_stmts_use(rest,name)
    case Con{P113DIf{c,yes,no},rest}:
      agy_da_val_uses(c,name) || agy_da_stmts_use(yes,name) || agy_da_stmts_use(no,name) || agy_da_stmts_use(rest,name)
    case Con{P113DCall{_,_,args},rest}: agy_da_vals_use(args,name) || agy_da_stmts_use(rest,name)
    case Con{P113DResult{vs},rest}: agy_da_vals_use(vs,name) || agy_da_stmts_use(rest,name)
    case Con{P113DAgain{vs},rest}: agy_da_vals_use(vs,name) || agy_da_stmts_use(rest,name)

law x181_hygiene_stmts:
  for body: List<&2,P113DStmt>
  String

@unsafe
def x181_hygiene_stmt(stmt: P113DStmt) -> String:
  match stmt:
    case P113DScalar{scalar}: x181_hygiene_scalar(scalar)
    case P113DIf{condition,yes,no}: p111_first(x181_hygiene_stmts(yes),x181_hygiene_stmts(no))
    case P113DCall{destinations,target,args}: x181_hygiene_names(destinations)
    case _: ""

@unsafe
def x181_hygiene_stmts(body):
  match body:
    case Nil{}: ""
    case Con{head,rest}: p111_first(x181_hygiene_stmt(head),x181_hygiene_stmts(rest))

# Experimental nonzero-mode certificate. This module is not in the live manifest.
# Canonical aliases are admitted only from N_W32 parameter metadata; no arbitrary
# ABI word is silently identified with its low half.
law x198n_clean:
  for body: List<&2,P113DStmt>
  for +params: List<&2,String>
  Bool

@unsafe
def x198n_clean(body,params):
  match body:
    case Nil{}: True{}
    case Con{P113DScalar{N111Set{name,typ,value}},rest}: x198n_name(name,params) && x190_branch_width(typ) && x198n_clean(rest,params)
    case Con{P113DScalar{N111Bin{name,typ,op,left,right}},rest}: x198n_name(name,params) && x190_branch_width(typ) && x198n_op(op) && x198n_clean(rest,params)
    case Con{P113DIf{condition,yes,no},rest}: x198n_clean(yes,params) && x198n_clean(no,params) && x198n_clean(rest,params)
    case Con{P113DScalar{N111If{condition,yes,no}},rest}: x198n_clean(x181_scalar_rows(yes),params) && x198n_clean(x181_scalar_rows(no),params) && x198n_clean(rest,params)
    case _: False{}

@unsafe
def x198n_finished(state: X198NState, params: List<&2,String>, values: List<&2,N111Value>, fuel: String, mode: String) -> Bool:
  match state:
    case X198NState{valid,env}: valid && x198n_back(params,values,env,fuel,mode)

@unsafe
def x198o_bin(+typ: N111Type, +op: String, +left: U32, +right: U32) -> U32:
  nt_choose(U32,U32.is_eq(left,1) && U32.is_eq(right,1),u => 1,u =>
    nt_choose(U32,U32.is_eq(p113k_width(typ),32) &&
      ((agy_str_eq(op,"add") && ((U32.is_eq(left,2) && U32.is_eq(right,1)) || (U32.is_eq(left,1) && U32.is_eq(right,2)))) ||
       (agy_str_eq(op,"sub") && U32.is_eq(left,2) && U32.is_eq(right,1))),v => 2,v => 0))

@unsafe
def x198o_finished(state: X198AState, params: List<&2,String>, values: List<&2,N111Value>, fuel: String, counter: String) -> Bool:
  match state:
    case X198AState{valid,env}: valid && x198o_back(params,values,env,fuel,counter)

@unsafe
def x198o_emit(prefix: List<&2,P113DStmt>, +params: List<&2,String>, +values: List<&2,N111Value>, +fuel: String, +counter: String) -> List<&2,P113DStmt>:
  nt_append(P113DStmt,prefix,w4_x198o_guards_opt(x198o_guards(params,values,fuel,counter),params,values,fuel,counter))

@unsafe
def x198o_progress_copy(value: X198OProgress, +typ: N111Type) -> X198OProgress:
  match value:
    case X198OProgress{fact,different,sp}: X198OProgress{x198n_width(fact,typ),different,sp}

@unsafe
def x198o_progress_diff(+typ: N111Type, +op: String, +left: X198NFact, +right: X198NFact, +lsp: String, +rsp: String, +ld: String, +rd: String) -> String:
  +d0 = nt_choose(String,U32.is_eq(p113k_width(typ),32),u =>
    nt_choose(String,(agy_str_eq(op,"add") || agy_str_eq(op,"sub") || agy_str_eq(op,"xor")) && x198n_low_nonzero(right),v => x198o_progress_alias(left),v =>
      nt_choose(String,(agy_str_eq(op,"add") || agy_str_eq(op,"xor")) && x198n_low_nonzero(left),w => x198o_progress_alias(right),w => "")),u => "")
  nt_choose(String,Bool.not(String.is_empty(d0)),u => d0,u =>
    nt_choose(String,(agy_str_eq(op,"add") || agy_str_eq(op,"sub") || agy_str_eq(op,"xor")) && w4_const_odd(right) && Bool.not(String.is_empty(lsp)),v => lsp,v =>
    nt_choose(String,(agy_str_eq(op,"add") || agy_str_eq(op,"xor")) && w4_const_odd(left) && Bool.not(String.is_empty(rsp)),w => rsp,w =>
    nt_choose(String,(agy_str_eq(op,"add") || agy_str_eq(op,"sub") || agy_str_eq(op,"xor")) && w4_const_even(right) && Bool.not(String.is_empty(ld)),z => ld,z =>
    nt_choose(String,(agy_str_eq(op,"add") || agy_str_eq(op,"xor")) && w4_const_even(left) && Bool.not(String.is_empty(rd)),q => rd,q => "")))))

@unsafe
def x198o_progress_finished(state: X198OProgressState, params: List<&2,String>, values: List<&2,N111Value>, fuel: String, counter: String) -> Bool:
  match state:
    case X198OProgressState{valid,env}: valid && x198o_progress_back(params,values,env,fuel,counter)

@unsafe
def agy_la_match_con_branch(stmts: List<&2,P113DStmt>, +prefix: List<&2,P113DStmt>,
    +aname: String, +bname: String) -> String:
  match stmts:
    case Nil{}: ""
    case Con{P113DIf{N111Local{cond},yes,no},_}:
      +con_name = agy_la_find_tag_cmp(prefix,cond)
      nt_choose(String,Bool.not(String.is_empty(con_name)) &&
          agy_la_scan_con(yes,aname,bname,con_name,False{},False{},False{}),
        u => con_name,u => "")
    case Con{h,rest}: agy_la_match_con_branch(rest,Con{h,prefix},aname,bname)

@unsafe
def agy_la_match_body(stmts: List<&2,P113DStmt>, +prefix: List<&2,P113DStmt>,
    +aname: String, +bname: String) -> String & String:
  match stmts:
    case Nil{}: ("","")
    case Con{P113DIf{N111Local{cond},yes,no},_}:
      +nil_name = agy_la_find_tag_cmp(prefix,cond)
      +con_name = agy_la_match_con_branch(no,Nil{},aname,bname)
      nt_choose(String & String,Bool.not(String.is_empty(nil_name)) &&
          Bool.not(String.is_empty(con_name)) &&
          Bool.not(agy_str_eq(nil_name,con_name)) &&
          agy_la_has_finish_b(yes,bname),
        u => (nil_name,con_name),u => ("",""))
    case Con{h,rest}: agy_la_match_body(rest,Con{h,prefix},aname,bname)

@unsafe
def agy_la_emit_fast(+symbol: String, +slow_sym: String, +nil_cid: U32, +con_cid: U32) -> X181Output:
  +pfx = ".Lla_" ++ symbol
  +l_notnil = pfx ++ "_nn"
  +l_walk   = pfx ++ "_wk"
  +l_lok    = pfx ++ "_lk"
  +l_patch  = pfx ++ "_pt"
  +l_bail   = pfx ++ "_bl"
  X181Output{[x188_many([
    X188One{PSection{1}},X188One{PGlobal{symbol}},X188One{PType{symbol,2}},x188_label(symbol),
    # Fast path only when p118_root == 0 (top-level call)
    x188_i2("testq",x188_reg(1,64),x188_reg(1,64)),
    x188_i1("jne",X187Target{slow_sym}),
    # Live descriptor checks: capabilities & 9 == 9, !cid_hot[con_cid]
    x188_i2("movq",X187Rip{"p111_program",88,0},x188_reg(9,64)),
    x188_i2("andl",X187Imm{9,0},x188_reg(9,32)),
    x188_i2("cmpl",X187Imm{9,0},x188_reg(9,32)),
    x188_i1("jne",X187Target{slow_sym}),
    x188_i2("movq",X187Rip{"p111_program",136,0},x188_reg(9,64)),
    x188_i2("movl",X187Imm{con_cid,0},x188_reg(10,32)),
    x188_i2("movzbl",X187Indexed{9,10,1,0},x188_reg(11,32)),
    x188_i2("testl",x188_reg(11,32),x188_reg(11,32)),
    x188_i1("jnz",X187Target{slow_sym}),
    # Check cid(a) == nil_cid -> return b
    x188_i2("movq",x188_reg(6,64),x188_reg(9,64)),
    x188_i2("shrq",X187Imm{40,0},x188_reg(9,64)),
    x188_i2("andq",X187Imm{65535,0},x188_reg(9,64)),
    x188_i2("cmpq",X187Imm{nil_cid,0},x188_reg(9,64)),
    x188_i1("jne",X187Target{l_notnil}),
    x188_i2("movq",x188_reg(2,64),x188_reg(0,64)),
    x188_i0("ret"),
    x188_label(l_notnil),
    x188_i2("cmpq",X187Imm{con_cid,0},x188_reg(9,64)),
    x188_i1("jne",X187Target{slow_sym}),
    # %r10 = heap, %rax = orig_a, %r8 = cur, %r11 = 0xffffffffff
    x188_i2("movq",X187Mem{7,0},x188_reg(10,64)),
    x188_i2("movq",x188_reg(6,64),x188_reg(0,64)),
    x188_i2("movq",x188_reg(6,64),x188_reg(8,64)),
    x188_i2("movabsq",X187Imm{4294967295,255},x188_reg(11,64)),
    x188_label(l_walk),
    # Check cur (%r8) is strictly unshared owned: tag == 0x02 ONLY (never mutate 0x82 RFC cells in-place!)
    x188_i2("movq",x188_reg(8,64),x188_reg(9,64)),
    x188_i2("andq",x188_reg(11,64),x188_reg(9,64)),
    x188_i2("movq",x188_reg(8,64),x188_reg(1,64)),
    x188_i2("shrq",X187Imm{56,0},x188_reg(1,64)),
    x188_i2("cmpq",X187Imm{2,0},x188_reg(1,64)),
    x188_i1("jne",X187Target{l_bail}),
    x188_label(l_lok),
    # Reject static terms (loc < HEAP_OFF) before any in-place mutation
    x188_i2("movq",X187Rip{"p111_program",64,0},x188_reg(1,64)),
    x188_i2("addq",X187Imm{127,0},x188_reg(1,64)),
    x188_i2("andq",X187Imm{4294967168,4294967295},x188_reg(1,64)),
    x188_i2("addq",X187Imm{51413504,0},x188_reg(1,64)),
    x188_i2("cmpq",x188_reg(1,64),x188_reg(9,64)),
    x188_i1("jb",X187Target{l_bail}),
    # %rcx = next = heap[loc + 1]
    x188_i2("movq",X187Indexed{10,9,8,8},x188_reg(1,64)),
    x188_i2("movq",x188_reg(1,64),x188_reg(6,64)),
    x188_i2("shrq",X187Imm{40,0},x188_reg(6,64)),
    x188_i2("andq",X187Imm{65535,0},x188_reg(6,64)),
    x188_i2("cmpq",X187Imm{nil_cid,0},x188_reg(6,64)),
    x188_i1("je",X187Target{l_patch}),
    x188_i2("cmpq",X187Imm{con_cid,0},x188_reg(6,64)),
    x188_i1("jne",X187Target{l_bail}),
    x188_i2("movq",x188_reg(1,64),x188_reg(8,64)),
    x188_i1("jmp",X187Target{l_walk}),
    x188_label(l_patch),
    x188_i2("movq",x188_reg(2,64),X187Indexed{10,9,8,8}),
    x188_i0("ret"),
    x188_label(l_bail),
    # Restore original (a=%rax, root=0, parent=0) and jump to slow TRMC worker
    x188_i2("movq",x188_reg(0,64),x188_reg(6,64)),
    x188_i2("xorl",x188_reg(1,32),x188_reg(1,32)),
    x188_i2("xorl",x188_reg(8,32),x188_reg(8,32)),
    x188_i1("jmp",X187Target{slow_sym}),
    X188One{PSize{symbol}}
  ])],""}

@unsafe
def agy_sh_chk_hot(+cid: U32, +slow: String) -> X188Seq:
  x188_many([
    x188_i2("movl",X187Imm{cid,0},x188_reg(10,32)),
    x188_i2("movzbl",X187Indexed{0,10,1,0},x188_reg(11,32)),
    x188_i2("testl",x188_reg(11,32),x188_reg(11,32)),
    x188_i1("jnz",X187Target{slow})])

# Guard capabilities & 9 == 9 and cid_hot != NULL; leaves cid_hot base in %rax
@unsafe
def agy_sh_guard_caps(+slow: String) -> X188Seq:
  x188_many([
    x188_i2("movq",X187Rip{"p111_program",88,0},x188_reg(0,64)),
    x188_i2("andl",X187Imm{9,0},x188_reg(0,32)),
    x188_i2("cmpl",X187Imm{9,0},x188_reg(0,32)),
    x188_i1("jne",X187Target{slow}),
    x188_i2("movq",X187Rip{"p111_program",136,0},x188_reg(0,64)),
    x188_i2("testq",x188_reg(0,64),x188_reg(0,64)),
    x188_i1("jz",X187Target{slow})])

# Unpack Char in %rax -> u32 in %eax (zero-extended); %r10 = heap; clobbers %r11; jumps to bail on thunk/bad tag
@unsafe
def agy_sh_unpack_chr(+prefix: String, +bail: String, +chr_cid: U32) -> X188Seq:
  +chr_pak = U32.add(65536,chr_cid)
  +chr_ctr = U32.add(131072,chr_cid)
  +l_pak = prefix ++ "_cp"
  +l_dir = prefix ++ "_cd"
  +l_ok = prefix ++ "_ok"
  x188_many([
    x188_i2("movq",x188_reg(0,64),x188_reg(11,64)),
    x188_i2("shrq",X187Imm{32,0},x188_reg(11,64)),
    x188_i2("testq",x188_reg(11,64),x188_reg(11,64)),
    x188_i1("jz",X187Target{l_ok}),
    x188_i2("shrq",X187Imm{8,0},x188_reg(11,64)),
    x188_i2("cmpq",X187Imm{chr_pak,0},x188_reg(11,64)),
    x188_i1("je",X187Target{l_pak}),
    x188_i2("andl",X187Imm{8388607,0},x188_reg(11,32)),
    x188_i2("cmpl",X187Imm{chr_ctr,0},x188_reg(11,32)),
    x188_i1("jne",X187Target{bail}),
    x188_i2("movq",x188_reg(0,64),x188_reg(11,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(11,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(11,64)),
    x188_i2("testq",x188_reg(0,64),x188_reg(0,64)),
    x188_i1("jge",X187Target{l_dir}),
    x188_i2("movq",X187Indexed{10,11,8,0},x188_reg(11,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(11,64)),
    x188_label(l_dir),
    x188_i2("movq",X187Indexed{10,11,8,0},x188_reg(0,64)),
    x188_i2("movq",x188_reg(0,64),x188_reg(11,64)),
    x188_i2("shrq",X187Imm{32,0},x188_reg(11,64)),
    x188_i2("testq",x188_reg(11,64),x188_reg(11,64)),
    x188_i1("jnz",X187Target{bail}),
    x188_i1("jmp",X187Target{l_ok}),
    x188_label(l_pak),
    x188_i2("movl",x188_reg(0,32),x188_reg(0,32)),
    x188_label(l_ok)])

# Shared SCon equality loop: expects %r8=cur_a, %r9=cur_b, %r10=heap, %r12=snil_word.
# Clobbers %rax, %rbx, %r8, %r9, %r11, %r13. Preserves %rdi, %rsi, %rdx, %rcx, %r10, %r12.
@unsafe
def agy_sh_epilogue_2(+pfx: String, +slow: String, +l_true: String, +l_false: String, +l_bail: String, +owned: Bool) -> X188Seq:
  +l_done = pfx ++ "_dn"
  +l_sk1 = pfx ++ "_s1"
  +l_sk2 = pfx ++ "_s2"
  +sink_seq = nt_choose(X188Seq,owned,
    u => x188_many([
      x188_i2("movl",x188_reg(0,32),x188_reg(13,32)),
      x188_i2("movq",x188_reg(7,64),x188_reg(12,64)),
      x188_i2("movq",x188_reg(2,64),x188_reg(3,64)),
      x188_i2("movq",x188_reg(6,64),x188_reg(0,64)),
      x188_i2("shrq",X187Imm{56,0},x188_reg(0,64)),
      x188_i2("cmpq",X187Imm{2,0},x188_reg(0,64)),
      x188_i1("jb",X187Target{l_sk1}),
      x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
      x188_i1("call",X187Target{"p111_rt_sink"}),
      x188_label(l_sk1),
      x188_i2("movq",x188_reg(3,64),x188_reg(0,64)),
      x188_i2("shrq",X187Imm{56,0},x188_reg(0,64)),
      x188_i2("cmpq",X187Imm{2,0},x188_reg(0,64)),
      x188_i1("jb",X187Target{l_sk2}),
      x188_i2("movq",x188_reg(12,64),x188_reg(7,64)),
      x188_i2("movq",x188_reg(3,64),x188_reg(6,64)),
      x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
      x188_i1("call",X187Target{"p111_rt_sink"}),
      x188_label(l_sk2),
      x188_i2("movl",x188_reg(13,32),x188_reg(0,32))]),
    u => X188Empty{})
  x188_many([
    x188_label(l_false),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("jmp",X187Target{l_done}),
    x188_label(l_true),
    x188_i2("movl",X187Imm{1,0},x188_reg(0,32)),
    x188_label(l_done),
    sink_seq,
    x188_i1("popq",x188_reg(13,64)),
    x188_i1("popq",x188_reg(12,64)),
    x188_i1("popq",x188_reg(3,64)),
    x188_i0("ret"),
    x188_label(l_bail),
    x188_i1("popq",x188_reg(13,64)),
    x188_i1("popq",x188_reg(12,64)),
    x188_i1("popq",x188_reg(3,64)),
    x188_i1("jmp",X187Target{slow})])

@unsafe
def x204_expanded_tail(expanded: List<&2,N111Stmt>, rest: List<&2,N111Stmt>, saved: String) -> Bool:
  match expanded:
    case Con{load,Nil{}}: x202k_tail(Con{load,rest},saved)
    case _: False{}

@unsafe
def x204_source_tail(+rows: List<&2,N111Stmt>, +saved: String) -> Bool:
  match rows:
    case Con{N111Call{name,typ,symbol,args},rest}:
      +call: N111Stmt = N111Call{name,typ,symbol,args}
      x185_late_enabled() && x202k_index(call,"p111_rt_reg_get",0) &&
        x204_expanded_tail(p112a_expand(3,call),rest,saved)
    case _: x202k_tail(rows,saved)

@unsafe
def x202k_template(+symbol: String) -> X181Output:
  X181Output{[x188_many([X188One{PSection{1}},X188One{PGlobal{symbol}},X188One{PType{symbol,2}},x188_label(symbol),
    x188_i1("pushq",x188_reg(5,64)),x188_i2("movq",x188_reg(4,64),x188_reg(5,64)),
    x188_i2("subq",X187Imm{2320,0},x188_reg(4,64)),x188_i2("movq",x188_reg(12,64),X187Mem{5,4294967280}),
    x188_i2("movq",x188_reg(7,64),x188_reg(0,64)),x188_i2("movq",x188_reg(0,64),x188_reg(12,64)),
    x188_label(".L" ++ symbol ++ "_loop"),
    x188_i2("movq",X187Mem{12,16},x188_reg(7,64)),x188_i2("movabsq",X187Imm{4294967288,4294967295},x188_reg(11,64)),
    x188_i2("addq",x188_reg(11,64),x188_reg(7,64)),x188_i2("movq",x188_reg(7,64),X187Mem{12,16}),
    x188_i2("movq",X187Mem{12,16},x188_reg(7,64)),x188_i2("movq",X187Mem{7,0},x188_reg(6,64)),
    x188_i2("movq",X187Mem{12,40},x188_reg(7,64)),x188_i2("movq",x188_reg(12,64),x188_reg(10,64)),
    x188_i2("movq",x188_reg(10,64),X187Mem{4,24}),x188_i2("movq",x188_reg(7,64),x188_reg(10,64)),
    x188_i2("movq",x188_reg(10,64),X187Mem{4,32}),x188_i2("movq",x188_reg(6,64),x188_reg(10,64)),
    x188_i2("movq",x188_reg(10,64),X187Mem{4,40}),x188_i2("movq",X187Mem{4,24},x188_reg(7,64)),
    x188_i2("movq",X187Mem{4,32},x188_reg(6,64)),x188_i2("movq",X187Mem{4,40},x188_reg(2,64)),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),x188_i1("call",X187Target{"p111_rt_apply"}),
    x188_i2("movq",x188_reg(0,64),x188_reg(7,64)),x188_i2("movq",x188_reg(7,64),x188_reg(0,64)),
    x188_i2("movq",X187Mem{5,4294967280},x188_reg(12,64)),x188_i2("movq",x188_reg(5,64),x188_reg(4,64)),
    x188_i1("popq",x188_reg(5,64)),x188_i0("ret"),X188One{PSize{symbol}}])],""}

law x192h_body:
  for body: List<&2,P114RStmt>
  for +params: List<&2,String>
  for +buffer: String
  List<&2,P113DStmt>

# Match all eight current constructors explicitly. A future constructor cannot
# silently gain admission through a permissive default. Frame/call statements
# retain their exact ordering and use the maintained runtime/late expansions.
@unsafe
def x192h_stmt(stmt: P114RStmt, +params: List<&2,String>, +buffer: String) -> List<&2,P113DStmt>:
  match stmt:
    case P114RScalar{scalar}: [P113DScalar{scalar}]
    case P114RIf{condition,yes,no}:
      [P113DIf{condition,x192h_body(yes,params,buffer),x192h_body(no,params,buffer)}]
    case P114RDescend{frame,arguments}:
      nt_append(P113DStmt,x181_scalar_rows(frame),Con{x192h_increment(),x192h_again(arguments,params,buffer)})
    case P114RAgain{arguments}: x192h_again(arguments,params,buffer)
    case P114RResult{value}: [x192h_result(params,value)]
    case P114RFailure{body}: x181_scalar_rows(body)
    case P114RResumeReady{frame,call,result}:
      nt_append(P113DStmt,x181_scalar_rows(frame),Con{x192h_increment(),
        nt_append(P113DStmt,x181_scalar_rows(call),[x192h_result(params,result)])})
    case P114RPushFrame{frame}: nt_append(P113DStmt,x181_scalar_rows(frame),[x192h_increment()])

@unsafe
def x192h_body(body,params,buffer):
  match body:
    case Nil{}: []
    case Con{stmt,rest}: nt_append(P113DStmt,x192h_stmt(stmt,params,buffer),x192h_body(rest,params,buffer))

def x198pw_part0(+slow: String) -> X188Seq:
  x188_many([
    x188_i2("cmpq",X187Imm{0,0},x188_reg(8,64)),
    x188_i1("jne",X187Target{slow}),
    x188_i2("cmpq",X187Imm{0,0},x188_reg(9,64)),
    x188_i1("jne",X187Target{slow}),
    x188_i2("cmpq",X187Imm{0,0},X187Mem{4,8}),
    x188_i1("jne",X187Target{slow}),
    x188_i2("movq",X187Rip{"p111_program",0,0},x188_reg(0,64)),
    x188_i2("cmpq",X187Imm{11102,0},x188_reg(0,64)),
    x188_i1("jne",X187Target{slow}),
    x188_i2("movq",X187Rip{"p111_program",8,0},x188_reg(0,64)),
    x188_i2("cmpq",X187Imm{192,0},x188_reg(0,64)),
    x188_i1("jne",X187Target{slow}),
    x188_i2("movq",X187Rip{"p111_program",88,0},x188_reg(0,64)),
    x188_i2("andq",X187Imm{9,0},x188_reg(0,64))])

def x198pw_part1(+slow: String) -> X188Seq:
  x188_many([
    x188_i2("cmpq",X187Imm{9,0},x188_reg(0,64)),
    x188_i1("jne",X187Target{slow}),
    x188_i1("pushq",x188_reg(5,64)),
    x188_i2("movq",x188_reg(4,64),x188_reg(5,64)),
    x188_i1("pushq",x188_reg(3,64)),
    x188_i1("pushq",x188_reg(12,64)),
    x188_i1("pushq",x188_reg(13,64)),
    x188_i1("pushq",x188_reg(14,64)),
    x188_i1("pushq",x188_reg(15,64)),
    x188_i2("subq",X187Imm{9304,0},x188_reg(4,64)),
    x188_i2("movq",x188_reg(7,64),X187Mem{4,0}),
    x188_i2("movq",x188_reg(6,64),X187Mem{4,8}),
    x188_i2("movq",x188_reg(2,64),X187Mem{4,16}),
    x188_i2("movq",x188_reg(1,64),X187Mem{4,24})])

def x198pw_part2(+prefix: String, +falseHi: U32, +trueHi: U32) -> X188Seq:
  x188_many([
    x188_i2("xorl",x188_reg(3,32),x188_reg(3,32)),
    x188_i2("cmpq",X187Imm{0,0},x188_reg(1,64)),
    x188_i1("je",X187Target{prefix ++ "_setup"}),
    x188_i2("movabsq",X187Imm{0,falseHi},x188_reg(0,64)),
    x188_i2("cmpq",x188_reg(0,64),x188_reg(1,64)),
    x188_i1("je",X187Target{prefix ++ "_setup"}),
    x188_i2("movl",X187Imm{1,0},x188_reg(3,32)),
    x188_i2("cmpq",X187Imm{1,0},x188_reg(1,64)),
    x188_i1("je",X187Target{prefix ++ "_setup"}),
    x188_i2("movabsq",X187Imm{0,trueHi},x188_reg(0,64)),
    x188_i2("cmpq",x188_reg(0,64),x188_reg(1,64)),
    x188_i1("jne",X187Target{prefix ++ "_miss"}),
    x188_label(prefix ++ "_setup"),
    x188_i2("movq",X187Mem{7,0},x188_reg(12,64))])

def x198pw_part3(+prefix: String) -> X188Seq:
  x188_many([
    x188_i2("movq",X187Rip{"p111_program",64,0},x188_reg(0,64)),
    x188_i2("addq",X187Imm{127,0},x188_reg(0,64)),
    x188_i2("andq",X187Imm{4294967168,4294967295},x188_reg(0,64)),
    x188_i2("addq",X187Imm{51413504,0},x188_reg(0,64)),
    x188_i2("movq",x188_reg(0,64),X187Mem{4,32}),
    x188_i2("leaq",X187Mem{4,8},x188_reg(0,64)),
    x188_i2("movq",x188_reg(0,64),X187Mem{4,64}),
    x188_i2("leaq",X187Mem{4,16},x188_reg(0,64)),
    x188_i2("movq",x188_reg(0,64),X187Mem{4,72}),
    x188_i2("movl",X187Imm{16,0},x188_reg(13,32)),
    x188_i2("xorl",x188_reg(14,32),x188_reg(14,32)),
    x188_i2("xorl",x188_reg(15,32),x188_reg(15,32)),
    x188_label(prefix ++ "_scan"),
    x188_i2("cmpq",X187Imm{0,0},x188_reg(13,64))])

def x198pw_part4(+prefix: String, +leafHi: U32) -> X188Seq:
  x188_many([
    x188_i1("je",X187Target{prefix ++ "_commit"}),
    x188_i2("subq",X187Imm{16,0},x188_reg(13,64)),
    x188_i2("movq",X187Indexed{4,13,1,64},x188_reg(7,64)),
    x188_i2("movq",X187Indexed{4,13,1,72},x188_reg(6,64)),
    x188_i2("movq",X187Mem{7,0},x188_reg(2,64)),
    x188_i2("movq",X187Mem{6,0},x188_reg(1,64)),
    x188_i2("movq",x188_reg(2,64),x188_reg(8,64)),
    x188_i2("shrq",X187Imm{32,0},x188_reg(8,64)),
    x188_i2("cmpl",X187Imm{leafHi,0},x188_reg(8,32)),
    x188_i1("jne",X187Target{prefix ++ "_node"}),
    x188_i2("movq",x188_reg(1,64),x188_reg(9,64)),
    x188_i2("shrq",X187Imm{32,0},x188_reg(9,64)),
    x188_i2("cmpl",X187Imm{leafHi,0},x188_reg(9,32)),
    x188_i1("jne",X187Target{prefix ++ "_miss"})])

def x198pw_part5(+prefix: String) -> X188Seq:
  x188_many([
    x188_i2("addl",X187Imm{1,0},x188_reg(15,32)),
    x188_i2("cmpl",X187Imm{1024,0},x188_reg(15,32)),
    x188_i1("ja",X187Target{prefix ++ "_miss"}),
    x188_i2("cmpl",x188_reg(1,32),x188_reg(2,32)),
    x188_i1("je",X187Target{prefix ++ "_scan"}),
    x188_i1("seta",x188_reg(0,8)),
    x188_i2("movzbl",x188_reg(0,8),x188_reg(0,32)),
    x188_i2("xorl",x188_reg(3,32),x188_reg(0,32)),
    x188_i1("je",X187Target{prefix ++ "_scan"}),
    x188_i2("cmpq",X187Imm{8192,0},x188_reg(14,64)),
    x188_i1("je",X187Target{prefix ++ "_miss"}),
    x188_i2("movq",x188_reg(7,64),X187Indexed{4,14,1,1088}),
    x188_i2("movq",x188_reg(6,64),X187Indexed{4,14,1,1096}),
    x188_i2("addq",X187Imm{16,0},x188_reg(14,64))])

def x198pw_part6(+prefix: String, +nodeHead: U32) -> X188Seq:
  x188_many([
    x188_i1("jmp",X187Target{prefix ++ "_scan"}),
    x188_label(prefix ++ "_node"),
    x188_i2("shrq",X187Imm{8,0},x188_reg(8,64)),
    x188_i2("cmpl",X187Imm{nodeHead,0},x188_reg(8,32)),
    x188_i1("jne",X187Target{prefix ++ "_miss"}),
    x188_i2("movq",x188_reg(1,64),x188_reg(9,64)),
    x188_i2("shrq",X187Imm{40,0},x188_reg(9,64)),
    x188_i2("cmpl",X187Imm{nodeHead,0},x188_reg(9,32)),
    x188_i1("jne",X187Target{prefix ++ "_miss"}),
    x188_i2("movabsq",X187Imm{4294967295,255},x188_reg(0,64)),
    x188_i2("andq",x188_reg(0,64),x188_reg(2,64)),
    x188_i2("andq",x188_reg(0,64),x188_reg(1,64)),
    x188_i2("cmpq",X187Mem{4,32},x188_reg(2,64)),
    x188_i1("jb",X187Target{prefix ++ "_miss"})])

def x198pw_part7(+prefix: String) -> X188Seq:
  x188_many([
    x188_i2("cmpq",X187Mem{4,32},x188_reg(1,64)),
    x188_i1("jb",X187Target{prefix ++ "_miss"}),
    x188_i2("cmpq",x188_reg(1,64),x188_reg(2,64)),
    x188_i1("je",X187Target{prefix ++ "_miss"}),
    x188_i2("cmpq",X187Imm{992,0},x188_reg(13,64)),
    x188_i1("ja",X187Target{prefix ++ "_miss"}),
    x188_i2("leaq",X187Indexed{12,2,8,8},x188_reg(7,64)),
    x188_i2("leaq",X187Indexed{12,1,8,8},x188_reg(6,64)),
    x188_i2("movq",x188_reg(7,64),X187Indexed{4,13,1,64}),
    x188_i2("movq",x188_reg(6,64),X187Indexed{4,13,1,72}),
    x188_i2("leaq",X187Indexed{12,2,8,0},x188_reg(7,64)),
    x188_i2("leaq",X187Indexed{12,1,8,0},x188_reg(6,64)),
    x188_i2("movq",x188_reg(7,64),X187Indexed{4,13,1,80}),
    x188_i2("movq",x188_reg(6,64),X187Indexed{4,13,1,88})])

def x198pw_part8(+prefix: String) -> X188Seq:
  x188_many([
    x188_i2("addq",X187Imm{32,0},x188_reg(13,64)),
    x188_i1("jmp",X187Target{prefix ++ "_scan"}),
    x188_label(prefix ++ "_commit"),
    x188_i2("cmpq",x188_reg(14,64),x188_reg(13,64)),
    x188_i1("je",X187Target{prefix ++ "_done"}),
    x188_i2("movq",X187Indexed{4,13,1,1088},x188_reg(7,64)),
    x188_i2("movq",X187Indexed{4,13,1,1096},x188_reg(6,64)),
    x188_i2("movq",X187Mem{7,0},x188_reg(0,64)),
    x188_i2("movq",X187Mem{6,0},x188_reg(2,64)),
    x188_i2("movq",x188_reg(2,64),X187Mem{7,0}),
    x188_i2("movq",x188_reg(0,64),X187Mem{6,0}),
    x188_i2("addq",X187Imm{16,0},x188_reg(13,64)),
    x188_i1("jmp",X187Target{prefix ++ "_commit"}),
    x188_label(prefix ++ "_done")])

def x198pw_part9(+prefix: String, +nodeCid: U32) -> X188Seq:
  x188_many([
    x188_i2("movq",X187Mem{4,0},x188_reg(7,64)),
    x188_i2("movl",X187Imm{nodeCid,0},x188_reg(6,32)),
    x188_i2("leaq",X187Mem{4,8},x188_reg(2,64)),
    x188_i1("call",X187Target{"p125_rt_ctor2"}),
    x188_i2("addq",X187Imm{9304,0},x188_reg(4,64)),
    x188_i1("popq",x188_reg(15,64)),
    x188_i1("popq",x188_reg(14,64)),
    x188_i1("popq",x188_reg(13,64)),
    x188_i1("popq",x188_reg(12,64)),
    x188_i1("popq",x188_reg(3,64)),
    x188_i1("popq",x188_reg(5,64)),
    x188_i0("ret"),
    x188_label(prefix ++ "_miss"),
    x188_i2("movq",X187Mem{4,0},x188_reg(7,64))])

def x198pw_part10(+slow: String) -> X188Seq:
  x188_many([
    x188_i2("movq",X187Mem{4,8},x188_reg(6,64)),
    x188_i2("movq",X187Mem{4,16},x188_reg(2,64)),
    x188_i2("movq",X187Mem{4,24},x188_reg(1,64)),
    x188_i2("xorl",x188_reg(8,32),x188_reg(8,32)),
    x188_i2("xorl",x188_reg(9,32),x188_reg(9,32)),
    x188_i2("addq",X187Imm{9304,0},x188_reg(4,64)),
    x188_i1("popq",x188_reg(15,64)),
    x188_i1("popq",x188_reg(14,64)),
    x188_i1("popq",x188_reg(13,64)),
    x188_i1("popq",x188_reg(12,64)),
    x188_i1("popq",x188_reg(3,64)),
    x188_i1("popq",x188_reg(5,64)),
    x188_i1("jmp",X187Target{slow})])

@unsafe
def x198pw_ctor(+d: KDef,name: String,+fields: List<&2,String>,ty: String) -> Bool:
  agy_str_eq(dk(d),"Ctr") && agy_str_eq(dn(d),name) && U32.is_eq(dx(d),0) &&
    U32.is_eq(da(d),nt_count(String,fields)) && x198pw_tel(dt(d),fields,ty)

@unsafe
def x198pw_layout(cs: List<&2,KDef>,+ty: String,+leaf: String,+node: String) -> Bool:
  match cs:
    case Con{+a,Con{+b,Nil{}}}:
      (x198pw_ctor(a,leaf,["U32"],ty) && x198pw_ctor(b,node,[ty,ty],ty)) ||
      (x198pw_ctor(b,leaf,["U32"],ty) && x198pw_ctor(a,node,[ty,ty],ty))
    case _: False{}

@unsafe
def agy_zip_data_layout(cs: List<&2,KDef>, +ty: String, +leaf: String, +node: String) -> Bool:
  match cs:
    case Con{+a,Con{+b,Nil{}}}:
      (x198pw_ctor(a,leaf,[],ty) && x198pw_ctor(b,node,[ty,"U32",ty],ty)) ||
      (x198pw_ctor(b,leaf,[],ty) && x198pw_ctor(a,node,[ty,"U32",ty],ty))
    case _: False{}

@unsafe
def agy_zip_machine(+prefix: String, +slow: String, +leaf_cid: U32, +node_cid: U32) -> X188Seq:
  +leaf_hi = U32.add(16777216,U32.mul(leaf_cid,256))
  +node_hi = U32.add(33554432,U32.mul(node_cid,256))
  +node_chk = U32.add(131072,node_cid)
  +l_loop = prefix ++ "_lp"
  +l_left = prefix ++ "_lt"
  +l_ins = prefix ++ "_in"
  +l_unch = prefix ++ "_un"
  +l_ret = prefix ++ "_rt"
  +l_bail = prefix ++ "_bl"
  x188_many([
    # Live descriptor checks before push %rbx (zero-cost bail on hot/cap-off)
    x188_i2("movq",X187Rip{"p111_program",88,0},x188_reg(0,64)),
    x188_i2("andl",X187Imm{9,0},x188_reg(0,32)),
    x188_i2("cmpl",X187Imm{9,0},x188_reg(0,32)),
    x188_i1("jne",X187Target{slow}),
    x188_i2("movq",X187Rip{"p111_program",136,0},x188_reg(0,64)),
    x188_i2("movl",X187Imm{node_cid,0},x188_reg(10,32)),
    x188_i2("movzbl",X187Indexed{0,10,1,0},x188_reg(0,32)),
    x188_i2("testl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("jnz",X187Target{slow}),
    # Save %rbx to hold HEAP_OFF in register (0-cycle check inside loop!)
    x188_i1("pushq",x188_reg(3,64)),
    x188_i2("movq",X187Rip{"p111_program",64,0},x188_reg(3,64)),
    x188_i2("addq",X187Imm{127,0},x188_reg(3,64)),
    x188_i2("andq",X187Imm{4294967168,4294967295},x188_reg(3,64)),
    x188_i2("addq",X187Imm{51413504,0},x188_reg(3,64)),
    x188_i2("movq",X187Mem{7,0},x188_reg(9,64)),
    x188_i2("movq",x188_reg(1,64),x188_reg(8,64)),
    x188_i2("xorl",x188_reg(10,32),x188_reg(10,32)),
    x188_i2("movq",x188_reg(6,64),x188_reg(11,64)),
    # Loop: %r8=cur, %r9=e.mem, %r10=slot_ptr (0=root), %r11=rem_fuel, %rbx=HEAP_OFF
    x188_label(l_loop),
    x188_i2("movabsq",X187Imm{0,leaf_hi},x188_reg(0,64)),
    x188_i2("cmpq",x188_reg(0,64),x188_reg(8,64)),
    x188_i1("je",X187Target{l_ins}),
    x188_i2("testq",x188_reg(11,64),x188_reg(11,64)),
    x188_i1("jz",X187Target{l_unch}),
    x188_i2("movq",x188_reg(8,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{40,0},x188_reg(0,64)),
    x188_i2("cmpq",X187Imm{node_chk,0},x188_reg(0,64)),
    x188_i1("jne",X187Target{l_bail}),
    x188_i2("movq",x188_reg(8,64),x188_reg(0,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(0,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(0,64)),
    x188_i2("cmpq",x188_reg(3,64),x188_reg(0,64)),
    x188_i1("jb",X187Target{l_bail}),
    x188_i2("leaq",X187Indexed{9,0,8,0},x188_reg(10,64)),
    x188_i2("movl",X187Mem{10,8},x188_reg(0,32)),
    x188_i2("cmpl",x188_reg(0,32),x188_reg(2,32)),
    x188_i1("jb",X187Target{l_left}),
    x188_i2("addq",X187Imm{16,0},x188_reg(10,64)),
    x188_label(l_left),
    x188_i2("movq",X187Mem{10,0},x188_reg(8,64)),
    x188_i2("subq",X187Imm{1,0},x188_reg(11,64)),
    x188_i1("jmp",X187Target{l_loop}),
    # Return tree unchanged (fuel == 0 before reaching Leaf)
    x188_label(l_unch),
    x188_i2("movq",x188_reg(1,64),x188_reg(0,64)),
    x188_i1("popq",x188_reg(3,64)),
    x188_i0("ret"),
    # Insert new Node{Leaf, x, Leaf} from class-2 freelist
    x188_label(l_ins),
    x188_i2("movq",X187Mem{7,8},x188_reg(0,64)),
    x188_i2("movq",X187Mem{0,16},x188_reg(11,64)),
    x188_i2("testq",x188_reg(11,64),x188_reg(11,64)),
    x188_i1("jz",X187Target{l_bail}),
    x188_i2("leaq",X187Indexed{9,11,8,0},x188_reg(8,64)),
    x188_i2("movq",X187Mem{8,0},x188_reg(9,64)),
    x188_i2("movq",x188_reg(9,64),X187Mem{0,16}),
    x188_i2("subq",X187Imm{4,0},X187Mem{0,272}),
    x188_i2("movabsq",X187Imm{0,leaf_hi},x188_reg(0,64)),
    x188_i2("movq",x188_reg(0,64),X187Mem{8,0}),
    x188_i2("movl",x188_reg(2,32),x188_reg(2,32)),
    x188_i2("movq",x188_reg(2,64),X187Mem{8,8}),
    x188_i2("movq",x188_reg(0,64),X187Mem{8,16}),
    x188_i2("movabsq",X187Imm{0,node_hi},x188_reg(0,64)),
    x188_i2("orq",x188_reg(11,64),x188_reg(0,64)),
    x188_i2("testq",x188_reg(10,64),x188_reg(10,64)),
    x188_i1("jz",X187Target{l_ret}),
    x188_i2("movq",x188_reg(0,64),X187Mem{10,0}),
    x188_i2("movq",x188_reg(1,64),x188_reg(0,64)),
    x188_label(l_ret),
    x188_i1("popq",x188_reg(3,64)),
    x188_i0("ret"),
    # Clean bailout (zero heap mutations occurred; %rdi,%rsi,%rdx,%rcx intact!)
    x188_label(l_bail),
    x188_i1("popq",x188_reg(3,64)),
    x188_i1("jmp",X187Target{slow})])

@unsafe
def agy_ro_find_ctor(cs: List<&2,KDef>, +name: String) -> KDef:
  match cs:
    case Nil{}: missing()
    case Con{+c,rest}:
      nt_choose(KDef,agy_str_eq(dk(c),"Ctr") && agy_str_eq(dn(c),name),u => c,u => agy_ro_find_ctor(rest,name))

@unsafe
def agy_ro_emit_bin_op(+op: String, +left_reg: U32) -> X188Seq:
  # left is in left_reg (32-bit), right is in %eax (reg 0, 32-bit), result in %eax
  nt_choose(X188Seq,agy_str_eq(op,"subl"),
    u => x188_many([
      x188_i2("subl",x188_reg(0,32),x188_reg(left_reg,32)),
      x188_i2("movl",x188_reg(left_reg,32),x188_reg(0,32))]),
    u => x188_i2(op,x188_reg(left_reg,32),x188_reg(0,32)))

def x198pw_has_cid(+id: KDef,+arity: U32) -> Bool:
  p88_string_eq(dk(id),"N111Id") && U32.is_lt(da(id),65536) && U32.is_eq(dx(id),arity)

@unsafe
def agy_fl_machine(+prefix: String, +slow: String, +warp_sym: String, +wn_sym: String,
    +leaf_cid: U32, +node_cid: U32) -> X188Seq:
  +node_chk = U32.add(131072,node_cid)
  +l_rec = prefix ++ "_rc"
  +l_ret_w = prefix ++ "_rw"
  +l_chk_leaf = prefix ++ "_cl"
  +l_slow_rec = prefix ++ "_sr"
  +l_wn = prefix ++ "_wn"
  +l_wn_leaf = prefix ++ "_wl"
  +l_wn_slow = prefix ++ "_ws"
  x188_many([
    # Entry guards (before any callee-saved push): mode==0, depth==0, val==0, d<=64, cap&9==9, !cid_hot[node]
    x188_i2("cmpq",X187Imm{0,0},x188_reg(8,64)),
    x188_i1("jne",X187Target{slow}),
    x188_i2("cmpq",X187Imm{0,0},x188_reg(9,64)),
    x188_i1("jne",X187Target{slow}),
    x188_i2("cmpq",X187Imm{0,0},X187Mem{4,8}),
    x188_i1("jne",X187Target{slow}),
    x188_i2("cmpq",X187Imm{64,0},x188_reg(6,64)),
    x188_i1("ja",X187Target{slow}),
    x188_i2("movq",X187Rip{"p111_program",88,0},x188_reg(0,64)),
    x188_i2("andl",X187Imm{9,0},x188_reg(0,32)),
    x188_i2("cmpl",X187Imm{9,0},x188_reg(0,32)),
    x188_i1("jne",X187Target{slow}),
    x188_i2("movq",X187Rip{"p111_program",136,0},x188_reg(0,64)),
    x188_i2("movl",X187Imm{node_cid,0},x188_reg(10,32)),
    x188_i2("movzbl",X187Indexed{0,10,1,0},x188_reg(0,32)),
    x188_i2("testl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("jnz",X187Target{slow}),
    # Save 5 callee-saved regs (entry %rsp is 8 mod 16 -> 5 pushes = 0 mod 16)
    x188_i1("pushq",x188_reg(3,64)),
    x188_i1("pushq",x188_reg(12,64)),
    x188_i1("pushq",x188_reg(13,64)),
    x188_i1("pushq",x188_reg(14,64)),
    x188_i1("pushq",x188_reg(15,64)),
    x188_i2("movq",x188_reg(7,64),x188_reg(12,64)),
    x188_i2("movq",x188_reg(2,64),x188_reg(13,64)),
    x188_i2("movq",X187Mem{12,0},x188_reg(14,64)),
    x188_i2("movq",X187Rip{"p111_program",64,0},x188_reg(15,64)),
    x188_i2("addq",X187Imm{127,0},x188_reg(15,64)),
    x188_i2("andq",X187Imm{4294967168,4294967295},x188_reg(15,64)),
    x188_i2("addq",X187Imm{51413504,0},x188_reg(15,64)),
    # %rsi=d, %rcx=w -> call .Lrec -> result in %rax
    x188_i1("call",X187Target{l_rec}),
    x188_i1("popq",x188_reg(15,64)),
    x188_i1("popq",x188_reg(14,64)),
    x188_i1("popq",x188_reg(13,64)),
    x188_i1("popq",x188_reg(12,64)),
    x188_i1("popq",x188_reg(3,64)),
    x188_i0("ret"),

    # .Lrec(%rsi=d, %rcx=w) -> %rax; preserves %r12..%r15, %rbx
    x188_label(l_rec),
    x188_i2("testq",x188_reg(6,64),x188_reg(6,64)),
    x188_i1("jz",X187Target{l_ret_w}),
    x188_i2("movq",x188_reg(1,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{40,0},x188_reg(0,64)),
    x188_i2("cmpq",X187Imm{node_chk,0},x188_reg(0,64)),
    x188_i1("jne",X187Target{l_chk_leaf}),
    x188_i2("movq",x188_reg(1,64),x188_reg(0,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(0,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(0,64)),
    x188_i2("cmpq",x188_reg(15,64),x188_reg(0,64)),
    x188_i1("jb",X187Target{l_slow_rec}),
    # Fast in-place Node path: push %rbx, d-1, w (3 pushes -> %rsp 0 mod 16!)
    x188_i1("pushq",x188_reg(3,64)),
    x188_i2("subq",X187Imm{1,0},x188_reg(6,64)),
    x188_i1("pushq",x188_reg(6,64)),
    x188_i1("pushq",x188_reg(1,64)),
    x188_i2("leaq",X187Indexed{14,0,8,0},x188_reg(3,64)),
    # Left child: wa = (%rbx) -> wn -> rec -> (%rbx)
    x188_i2("movq",X187Mem{3,0},x188_reg(1,64)),
    x188_i1("call",X187Target{l_wn}),
    x188_i2("movq",X187Mem{4,8},x188_reg(6,64)),
    x188_i1("call",X187Target{l_rec}),
    x188_i2("movq",x188_reg(0,64),X187Mem{3,0}),
    # Right child: wb = 8(%rbx) -> wn -> rec -> 8(%rbx)
    x188_i2("movq",X187Mem{3,8},x188_reg(1,64)),
    x188_i1("call",X187Target{l_wn}),
    x188_i2("movq",X187Mem{4,8},x188_reg(6,64)),
    x188_i1("call",X187Target{l_rec}),
    x188_i2("movq",x188_reg(0,64),X187Mem{3,8}),
    # Return original w in-place!
    x188_i1("popq",x188_reg(0,64)),
    x188_i1("popq",x188_reg(6,64)),
    x188_i1("popq",x188_reg(3,64)),
    x188_i0("ret"),

    x188_label(l_chk_leaf),
    x188_i2("andl",X187Imm{65535,0},x188_reg(0,32)),
    x188_i2("cmpl",X187Imm{leaf_cid,0},x188_reg(0,32)),
    x188_i1("jne",X187Target{l_slow_rec}),
    x188_label(l_ret_w),
    x188_i2("movq",x188_reg(1,64),x188_reg(0,64)),
    x188_i0("ret"),

    # Slow recursive call: slow(state, d, s, w, 0, 0, 0)
    # Entry %rsp is 8 mod 16 -> sub $24 -> 0 mod 16, 0(%rsp)=0
    x188_label(l_slow_rec),
    x188_i2("subq",X187Imm{24,0},x188_reg(4,64)),
    x188_i2("movq",x188_reg(12,64),x188_reg(7,64)),
    x188_i2("movq",x188_reg(13,64),x188_reg(2,64)),
    x188_i2("xorl",x188_reg(8,32),x188_reg(8,32)),
    x188_i2("xorl",x188_reg(9,32),x188_reg(9,32)),
    x188_i2("movq",x188_reg(8,64),X187Mem{4,0}),
    x188_i1("call",X187Target{slow}),
    x188_i2("addq",X187Imm{24,0},x188_reg(4,64)),
    x188_i0("ret"),

    # .Lwn(%rcx=child) -> %rcx = warp_node(child, s)
    x188_label(l_wn),
    x188_i2("movq",x188_reg(1,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{40,0},x188_reg(0,64)),
    x188_i2("cmpq",X187Imm{node_chk,0},x188_reg(0,64)),
    x188_i1("jne",X187Target{l_wn_leaf}),
    x188_i2("movq",x188_reg(1,64),x188_reg(0,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(0,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(0,64)),
    x188_i2("cmpq",x188_reg(15,64),x188_reg(0,64)),
    x188_i1("jb",X187Target{l_wn_slow}),
    # Check ALC_LEN[1] + 2 < 32768 before freeing class-1 Node slot
    x188_i2("movq",X187Mem{12,8},x188_reg(8,64)),
    x188_i2("movq",X187Mem{8,264},x188_reg(11,64)),
    x188_i2("addq",X187Imm{2,0},x188_reg(11,64)),
    x188_i2("cmpq",X187Imm{32768,0},x188_reg(11,64)),
    x188_i1("jae",X187Target{l_wn_slow}),
    # Unpack a0=%rsi, a1=%rdx, push loc onto ALC_AT[1], update ALC_LEN[1]
    x188_i2("leaq",X187Indexed{14,0,8,0},x188_reg(10,64)),
    x188_i2("movq",X187Mem{10,0},x188_reg(6,64)),
    x188_i2("movq",X187Mem{10,8},x188_reg(2,64)),
    x188_i2("movq",X187Mem{8,8},x188_reg(9,64)),
    x188_i2("movq",x188_reg(9,64),X187Mem{10,0}),
    x188_i2("movq",x188_reg(0,64),X187Mem{8,8}),
    x188_i2("movq",x188_reg(11,64),X187Mem{8,264}),
    # Call p114r_<warp>(%r12, a0=%rsi, a1=%rdx, %r13, 0, 0, 0)
    x188_i2("subq",X187Imm{24,0},x188_reg(4,64)),
    x188_i2("movq",x188_reg(12,64),x188_reg(7,64)),
    x188_i2("movq",x188_reg(13,64),x188_reg(1,64)),
    x188_i2("xorl",x188_reg(8,32),x188_reg(8,32)),
    x188_i2("xorl",x188_reg(9,32),x188_reg(9,32)),
    x188_i2("movq",x188_reg(8,64),X187Mem{4,0}),
    x188_i1("call",X187Target{warp_sym}),
    x188_i2("addq",X187Imm{24,0},x188_reg(4,64)),
    x188_i2("movq",x188_reg(0,64),x188_reg(1,64)),
    x188_i0("ret"),

    x188_label(l_wn_leaf),
    x188_i2("andl",X187Imm{65535,0},x188_reg(0,32)),
    x188_i2("cmpl",X187Imm{leaf_cid,0},x188_reg(0,32)),
    x188_i1("jne",X187Target{l_wn_slow}),
    x188_i0("ret"),

    # Slow wn: call p114r_<wn>(%r12, child, %r13, 0, 0, 0)
    x188_label(l_wn_slow),
    x188_i2("subq",X187Imm{8,0},x188_reg(4,64)),
    x188_i2("movq",x188_reg(12,64),x188_reg(7,64)),
    x188_i2("movq",x188_reg(1,64),x188_reg(6,64)),
    x188_i2("movq",x188_reg(13,64),x188_reg(2,64)),
    x188_i2("xorl",x188_reg(1,32),x188_reg(1,32)),
    x188_i2("xorl",x188_reg(8,32),x188_reg(8,32)),
    x188_i2("xorl",x188_reg(9,32),x188_reg(9,32)),
    x188_i1("call",X187Target{wn_sym}),
    x188_i2("addq",X187Imm{8,0},x188_reg(4,64)),
    x188_i2("movq",x188_reg(0,64),x188_reg(1,64)),
    x188_i0("ret")])

@unsafe
def agy_al_emit_fast(+symbol: String, +slow_sym: String, +con_cid: U32) -> X181Output:
  +pfx = ".Lal_" ++ symbol
  +l_loop = pfx ++ "_lp"
  +l_done = pfx ++ "_dn"
  +l_bail = pfx ++ "_bl"
  X181Output{[x188_many([
    X188One{PSection{1}},X188One{PGlobal{symbol}},X188One{PType{symbol,2}},x188_label(symbol),
    # Fast path only on mode == 0 && tag(a) == 4 (raw Array<U32>) && cls <= 24 && loc >= 1
    x188_i2("testq",x188_reg(1,64),x188_reg(1,64)),
    x188_i1("jne",X187Target{slow_sym}),
    x188_i2("movq",x188_reg(6,64),x188_reg(10,64)),
    x188_i2("shrq",X187Imm{56,0},x188_reg(10,64)),
    x188_i2("cmpq",X187Imm{4,0},x188_reg(10,64)),
    x188_i1("jne",X187Target{slow_sym}),
    x188_i2("movq",x188_reg(6,64),x188_reg(10,64)),
    x188_i2("shrq",X187Imm{40,0},x188_reg(10,64)),
    x188_i2("andq",X187Imm{31,0},x188_reg(10,64)),
    x188_i2("cmpq",X187Imm{24,0},x188_reg(10,64)),
    x188_i1("ja",X187Target{slow_sym}),
    x188_i2("movabsq",X187Imm{4294967295,255},x188_reg(11,64)),
    x188_i2("andq",x188_reg(6,64),x188_reg(11,64)),
    x188_i2("cmpq",X187Imm{1,0},x188_reg(11,64)),
    x188_i1("jb",X187Target{slow_sym}),
    # Prologue (16-byte aligned: push rbp + 5 regs + sub 40 = 80 bytes)
    x188_i1("pushq",x188_reg(5,64)),
    x188_i2("movq",x188_reg(4,64),x188_reg(5,64)),
    x188_i1("pushq",x188_reg(3,64)),
    x188_i1("pushq",x188_reg(12,64)),
    x188_i1("pushq",x188_reg(13,64)),
    x188_i1("pushq",x188_reg(14,64)),
    x188_i1("pushq",x188_reg(15,64)),
    x188_i2("subq",X187Imm{40,0},x188_reg(4,64)),
    # %r12 = st, %rbx = a, %r15 = acc, %r13 = base = heap + (loc << 3), %r14 = size = 1 << cls
    x188_i2("movq",x188_reg(7,64),x188_reg(12,64)),
    x188_i2("movq",x188_reg(6,64),x188_reg(3,64)),
    x188_i2("movq",x188_reg(2,64),x188_reg(15,64)),
    x188_i2("movq",X187Mem{12,0},x188_reg(13,64)),
    x188_i2("shlq",X187Imm{3,0},x188_reg(11,64)),
    x188_i2("addq",x188_reg(11,64),x188_reg(13,64)),
    x188_i2("movq",x188_reg(10,64),x188_reg(1,64)),
    x188_i2("movabsq",X187Imm{1,0},x188_reg(14,64)),
    x188_i2("shlq",x188_reg(1,8),x188_reg(14,64)),
    # Loop i = size down to 1 (accessing base[i - 1])
    x188_label(l_loop),
    x188_i2("subq",X187Imm{1,0},x188_reg(14,64)),
    x188_i2("movl",X187Indexed{13,14,4,0},x188_reg(0,32)),
    x188_i2("movq",x188_reg(0,64),X187Mem{4,0}),
    x188_i2("movq",x188_reg(15,64),X187Mem{4,8}),
    x188_i2("movq",x188_reg(12,64),x188_reg(7,64)),
    x188_i2("movabsq",X187Imm{con_cid,0},x188_reg(6,64)),
    x188_i2("movq",x188_reg(4,64),x188_reg(2,64)),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("call",X187Target{"p125_rt_ctor2"}),
    x188_i2("movq",x188_reg(0,64),x188_reg(15,64)),
    x188_i2("testq",x188_reg(14,64),x188_reg(14,64)),
    x188_i1("jne",X187Target{l_loop}),
    x188_label(l_done),
    # Sink a (%rbx) and return acc (%r15)
    x188_i2("movq",x188_reg(12,64),x188_reg(7,64)),
    x188_i2("movq",x188_reg(3,64),x188_reg(6,64)),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("call",X187Target{"p111_rt_sink"}),
    x188_i2("movq",x188_reg(15,64),x188_reg(0,64)),
    x188_i2("addq",X187Imm{40,0},x188_reg(4,64)),
    x188_i1("popq",x188_reg(15,64)),
    x188_i1("popq",x188_reg(14,64)),
    x188_i1("popq",x188_reg(13,64)),
    x188_i1("popq",x188_reg(12,64)),
    x188_i1("popq",x188_reg(3,64)),
    x188_i1("popq",x188_reg(5,64)),
    x188_i0("ret"),
    X188One{PSize{symbol}}
  ])],""}

@unsafe
def x193f_clean(body: List<&2,N111Stmt>) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{stmt,rest}: x193f_clean_stmt(stmt) && x193f_clean(rest)

@unsafe
def x193f_clean_stmt(stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Set{name,typ,value}: x193f_clean_name(name) && x193f_clean_value(value)
    case N111Bin{name,typ,op,left,right}: x193f_clean_name(name) && x193f_clean_value(left) && x193f_clean_value(right)
    case N111Call{name,typ,symbol,args}: x193f_clean_name(name) && x193f_clean_args(args)
    case N111If{condition,yes,no}: x193f_clean_value(condition) && x193f_clean(yes) && x193f_clean(no)
    case N111Return{value}: x193f_clean_value(value)
    case N111Load{name,typ,base,offset}: x193f_clean_name(name) && x193f_clean_value(base)
    case N111Store{typ,base,offset,value}: x193f_clean_value(base) && x193f_clean_value(value)
    case N111Offset{name,base,bytes}: x193f_clean_name(name) && x193f_clean_value(base) && x193f_clean_value(bytes)
    case N111Alloca{name,bytes,align}: x193f_clean_name(name)

@unsafe
def x193f_worker(stmt: P112WorkerStmt) -> X193FBody:
  match stmt:
    case P112WorkerScalar{scalar}: X193FBody{[scalar],0,""}
    case P112WorkerIf{condition,yes,no}: x193f_branch(condition,x193f_workers(yes),x193f_workers(no))
    case P112WorkerCall{target,count}:
      nt_choose(X193FBody,U32.is_le(count,256),u => X193FBody{x193f_call(target,count),1,""},
        u => X193FBody{[],0,"public helper argument count exceeds scratch"})
    case P112WorkerAgain{}: X193FBody{[],0,"private Again in public helper plan"}
    case P112WorkerResult{}: X193FBody{[],0,"private Result in public helper plan"}

@unsafe
def x193f_workers(body: List<&2,P112WorkerStmt>) -> X193FBody:
  match body:
    case Nil{}: X193FBody{[],0,""}
    case Con{stmt,rest}: x193f_join(x193f_worker(stmt),x193f_workers(rest))

# Mirror p112w_public_segment's own direct-loop precedence and metadata gate.
# A direct tail loop stays with the original x86 segment consumer in this pilot.
law x195t_clean_body:
  for body: List<&2,P113DStmt>
  Bool

@unsafe
def x195t_clean_scalar(stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Set{name,typ,value}: x195t_name(name) && x195t_clean_value(value)
    case N111Bin{name,typ,op,left,right}: x195t_name(name) && x195t_clean_value(left) && x195t_clean_value(right)
    case N111Load{name,typ,base,offset}: x195t_name(name) && x195t_clean_value(base)
    case N111Store{typ,base,offset,value}: x195t_clean_value(base) && x195t_clean_value(value)
    case N111Offset{name,base,bytes}: x195t_name(name) && x195t_clean_value(base) && x195t_clean_value(bytes)
    case N111Alloca{name,bytes,align}: x195t_name(name)
    case N111Call{name,typ,symbol,args}: x195t_name(name) && x195t_clean_args(args)
    case N111If{condition,yes,no}: x195t_clean_value(condition) &&
      x195t_clean_body(x181_scalar_rows(yes)) && x195t_clean_body(x181_scalar_rows(no))
    case N111Return{value}: x195t_clean_value(value)

@unsafe
def x195t_clean_stmt(stmt: P113DStmt) -> Bool:
  match stmt:
    case P113DScalar{scalar}: x195t_clean_scalar(scalar)
    case P113DIf{condition,yes,no}: x195t_clean_value(condition) && x195t_clean_body(yes) && x195t_clean_body(no)
    case P113DCall{names,target,args}: x195t_names(names) && x195t_clean_values(args)
    case P113DResult{values}: x195t_clean_values(values)
    case P113DAgain{values}: x195t_clean_values(values)

@unsafe
def x195t_clean_body(body):
  match body:
    case Nil{}: True{}
    case Con{stmt,rest}: x195t_clean_stmt(stmt) && x195t_clean_body(rest)

# Reuse four private locals for each completed lookup. Prefix admission proves
# none can alias an original parameter, definition or read-only local.
@unsafe
def x195t_found(+stmt: P113DStmt, name: String, target: String, value: N111Value,
    found: Maybe<&2,U32>) -> List<&2,P113DStmt>:
  match found:
    case Some{+last}: nt_choose(List<&2,P113DStmt>,U32.is_ge(last,3) && U32.is_lt(last,64),
      u => x195t_load(name,target,value,last),u => [stmt])
    case None{}: [stmt]

@unsafe
def x185_array_dispatch_ex(+name: String, +params: List<&2,NC_Binding>, +result: U32, +used: U32, +extra: List<&2,N111Stmt>) -> List<&2,N111Stmt>:
  nt_append(N111Stmt,
    nt_append(N111Stmt,Con{N111Set{"p113a_version_guard",N111U32{},N111Const{1,0}},p117v_guard(params,1,used)},extra),
    [N111If{N111Local{"p113a_version_guard"},[],[
      N111Call{"__x181_fallback",N111U64{},"p117v_" ++ nt_fid(name),
        Con{p111_state(),nt_choose(List<&2,N111Arg>,U32.is_eq(result,1),
          u => x185_array_arguments(params),
          u => Con{N111Arg{N111Ptr{},N111Local{"__x181_result_out"}},x185_array_arguments(params)})}},
      N111Return{N111Local{"__x181_fallback"}}]}])

@unsafe
def x199s_call(fuel: String, index: String, array: String, +carry: String) -> List<&2,P113DStmt>:
  [P113DScalar{N111Call{carry,N111U64{},"p199_rt_u32_scan4",[
    N111Arg{N111Ptr{},p117h_ref(3,"base")},N111Arg{N111U64{},p117h_ref(3,"mask")},
    N111Arg{N111U64{},N111Local{fuel}},N111Arg{N111U64{},N111Local{index}},N111Arg{N111U64{},N111Local{carry}}]}},
    P113DResult{[N111Local{array},N111Local{carry}]}]

@unsafe
def agy_dp_check_arr(+slot_off: U32, +dst_reg: U32, +strict_lt: Bool, +heap_min: U32, +miss: String) -> X188Seq:
  # Inputs: %r12 = j_u64 + n, %rdi = state, 40(%rsp) = j_u64 (zero-ext), heap = (%rdi)
  # Clobbers %rax, %rcx, %r10, %r11. Sets dst_reg = heap + (loc << 3) + (j_u64 << 2)
  x188_many([
    x188_i2("movq",X187Mem{4,slot_off},x188_reg(10,64)),
    x188_i2("movq",x188_reg(10,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{56,0},x188_reg(0,64)),
    x188_i2("cmpq",X187Imm{4,0},x188_reg(0,64)),
    x188_i1("jne",X187Target{miss}),
    x188_i2("movabsq",X187Imm{4294967295,255},x188_reg(11,64)),
    x188_i2("andq",x188_reg(10,64),x188_reg(11,64)),
    x188_i2("cmpq",X187Imm{heap_min,0},x188_reg(11,64)),
    x188_i1("jb",X187Target{miss}),
    # size = 1 << ((arr >> 40) & 31)
    x188_i2("movq",x188_reg(10,64),x188_reg(1,64)),
    x188_i2("shrq",X187Imm{40,0},x188_reg(1,64)),
    x188_i2("andl",X187Imm{31,0},x188_reg(1,32)),
    x188_i2("movl",X187Imm{1,0},x188_reg(0,32)),
    x188_i2("shlq",x188_reg(1,8),x188_reg(0,64)),
    x188_i2("cmpq",x188_reg(0,64),x188_reg(12,64)),
    x188_i1(nt_choose(String,strict_lt,u => "jae",u => "ja"),X187Target{miss}),
    # dst_reg = heap + (loc << 3) + (j_u64 << 2)
    x188_i2("movq",X187Mem{7,0},x188_reg(dst_reg,64)),
    x188_i2("leaq",X187Indexed{dst_reg,11,8,0},x188_reg(dst_reg,64)),
    x188_i2("movq",X187Mem{4,0},x188_reg(10,64)),
    x188_i2("leaq",X187Indexed{dst_reg,10,4,0},x188_reg(dst_reg,64))])

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
    case Con{P113DAgain{vals},rest}:
      +aName = w5_lcu_local_opt(w5_lcu_nth_val(vals,idx))
      +acc2 = w5_lcu_merge_scan(acc,w5_lcu_ctor_before_again(revPrefix,aName))
      w5_lcu_scan_agains(rest,[],idx,acc2)
    case Con{P113DIf{_,yes,no},rest}:
      +a1 = w5_lcu_scan_agains(yes,[],idx,acc)
      +a2 = w5_lcu_scan_agains(no,[],idx,a1)
      w5_lcu_scan_agains(rest,[],idx,a2)
    case Con{s,rest}:
      w5_lcu_scan_agains(rest,Con{s,revPrefix},idx,acc)

# Check whether every use of `pName` in `body` is admissible (tag/take/sink/result only, never reassigned).
@unsafe
def w5_lcu_check_body(body: List<&2,P113DStmt>, +pName: String, +arity: U32, +acc: W5LcuUse) -> W5LcuUse:
  match body:
    case Nil{}: acc
    case Con{P113DScalar{s},rest}: w5_lcu_check_body(rest,pName,arity,w5_lcu_check_n111(s,pName,arity,acc))
    case Con{P113DIf{c,yes,no},+rest}:
      nt_choose(W5LcuUse,w5_lcu_val_is(pName,c),u => w5_lcu_use_fail(acc),
        u => w5_lcu_check_body(rest,pName,arity,
          w5_lcu_check_body(no,pName,arity,w5_lcu_check_body(yes,pName,arity,acc))))
    case Con{P113DCall{ds,_,args},+rest}:
      nt_choose(W5LcuUse,w5_lcu_names_has(pName,ds) || w5_lcu_vals_has(pName,args),
        u => w5_lcu_use_fail(acc),u => w5_lcu_check_body(rest,pName,arity,acc))
    case Con{P113DAgain{vals},+rest}:
      nt_choose(W5LcuUse,w5_lcu_vals_has(pName,vals),
        u => w5_lcu_use_fail(acc),u => w5_lcu_check_body(rest,pName,arity,acc))
    case Con{P113DResult{vals},rest}:
      w5_lcu_check_body(rest,pName,arity,acc)

@unsafe
def w5_lcu_check_scan_res(+idx: U32, +pName: String, +nParams: U32, +body: List<&2,P113DStmt>, scan: W5LcuScan) -> W5LcuCand:
  match scan:
    case W5LcuScan{ok,seen,+ctor,+arity}:
      nt_choose(W5LcuCand,ok && seen && U32.is_le(U32.sub(U32.add(nParams,arity),1),16),
        u => w5_lcu_check_use_res(idx,pName,ctor,arity,w5_lcu_check_body(body,pName,arity,W5LcuUse{True{},False{}})),
        u => W5LcuCandNo{})

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
    case W5LcuYes{_,+a,_,+fvs,_}:
      +trimmed = w5_lcu_drop_n(revAcc,U32.inc(a))
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

def agy_f32_find_const(cs: List<&2,U32>, +val: U32, +idx: U32) -> U32:
  match cs:
    case Nil{}: 99
    case Con{c,rest}: nt_choose(U32,U32.is_eq(c,val),u => idx,u => agy_f32_find_const(rest,val,U32.inc(idx)))

@unsafe
def agy_f32_collect_c(+e: KTerm, +cs: List<&2,U32>) -> List<&2,U32>:
  nt_choose(List<&2,U32>,agy_str_eq(tg(e),"FConst"),
    u => nt_choose(List<&2,U32>,U32.is_eq(agy_f32_find_const(cs,ix(e),0),99),v => Con{ix(e),cs},v => cs),
    u => nt_choose(List<&2,U32>,agy_str_eq(tg(e),"FBin") && U32.is_eq(terms_len(ks(e)),2),
      v => agy_f32_collect_c(kid(e,1),agy_f32_collect_c(kid(e,0),cs)),
      v => cs))

@unsafe
def agy_f32_hoist_consts(cs: List<&2,U32>, +reg: U32) -> X188Seq:
  match cs:
    case Nil{}: X188Empty{}
    case Con{bits,rest}:
      x188_many([
        x188_i2("movl",X187Imm{bits,0},x188_reg(0,32)),
        x188_i2("movd",x188_reg(0,32),x188_xmm(reg)),
        agy_f32_hoist_consts(rest,U32.inc(reg))])

# Emit U32 expr into dst_reg (0=eax, 8=r8d, 9=r9d, 10=r10d).
# Incoming: %ecx(1) = h, %edx(2) = obs_u32
law agy_f32_emit_u:
  for +e: KTerm
  for +slot: U32
  X188Seq

@unsafe
def agy_f32_emit_ubin(+op: String, +l: KTerm, +r: KTerm, +slot: U32, +dr: U32) -> X188Seq:
  +sr = agy_f32_u_reg(U32.inc(slot))
  x188_many([
    agy_f32_emit_u(l,slot),
    agy_f32_emit_u(r,U32.inc(slot)),
    x188_i2(op,x188_reg(sr,32),x188_reg(dr,32))])

@unsafe
def agy_f32_emit_u(e,slot):
  +t = tg(e)
  +r = agy_f32_u_reg(slot)
  nt_choose(X188Seq,agy_str_eq(t,"UVarH"),
    u => x188_i2("movl",x188_reg(1,32),x188_reg(r,32)),u =>
    nt_choose(X188Seq,agy_str_eq(t,"UObs"),
      v => x188_i2("movl",x188_reg(2,32),x188_reg(r,32)),v =>
      nt_choose(X188Seq,agy_str_eq(t,"UConst"),
        w => x188_i2("movl",X187Imm{ix(e),0},x188_reg(r,32)),w =>
        nt_choose(X188Seq,agy_str_eq(t,"UBin") && U32.is_eq(terms_len(ks(e)),2),
          z => agy_f32_emit_ubin(nm(e),kid(e,0),kid(e,1),slot,r),
          z => X188Empty{}))))

# Reuse %xmm1 directly when obs shares subexpression ye!
@unsafe
def agy_f32_subst_opt(opt: Maybe<&2,KTerm>, ye: KTerm) -> Maybe<&2,KTerm>:
  match opt:
    case None{}: None{}
    case Some{e}: Some{agy_f32_subst_y(e,ye)}

law agy_f32_emit_f2:
  for +e: KTerm
  for +cs: List<&2,U32>
  for +dst: U32
  X188Seq

@unsafe
def agy_f32_emit_fbin2(+op: String, +l: KTerm, +r: KTerm, +cs: List<&2,U32>, +dst: U32) -> X188Seq:
  nt_choose(X188Seq,agy_str_eq(tg(r),"FVarX"),
    u => x188_cat(agy_f32_emit_f2(l,cs,dst),x188_i2(op,x188_xmm(0),x188_xmm(dst))),u =>
    nt_choose(X188Seq,agy_str_eq(tg(r),"FVarY"),
      k => x188_cat(agy_f32_emit_f2(l,cs,dst),x188_i2(op,x188_xmm(1),x188_xmm(dst))),k =>
      nt_choose(X188Seq,agy_str_eq(tg(r),"FConst"),
        v => x188_cat(agy_f32_emit_f2(l,cs,dst),x188_i2(op,x188_xmm(U32.add(8,agy_f32_find_const(cs,ix(r),0))),x188_xmm(dst))),v =>
        x188_many([
          agy_f32_emit_f2(l,cs,dst),
          agy_f32_emit_f2(r,cs,U32.inc(dst)),
          x188_i2(op,x188_xmm(U32.inc(dst)),x188_xmm(dst))]))))

@unsafe
def agy_f32_emit_f2(e,cs,dst):
  +t = tg(e)
  nt_choose(X188Seq,agy_str_eq(t,"FVarX"),
    u => x188_i2("movaps",x188_xmm(0),x188_xmm(dst)),u =>
    nt_choose(X188Seq,agy_str_eq(t,"FVarY"),
      k => x188_i2("movaps",x188_xmm(1),x188_xmm(dst)),k =>
      nt_choose(X188Seq,agy_str_eq(t,"FConst"),
        v => x188_i2("movaps",x188_xmm(U32.add(8,agy_f32_find_const(cs,ix(e),0))),x188_xmm(dst)),v =>
        nt_choose(X188Seq,agy_str_eq(t,"FBin") && U32.is_eq(terms_len(ks(e)),2),
          w => agy_f32_emit_fbin2(nm(e),kid(e,0),kid(e,1),cs,dst),
          w => X188Empty{}))))

law w5b_f32_scan_body:
  for body: List<&2,P113DStmt>
  for +acc: U32
  U32

@unsafe
def w5b_f32_bd_cont(+a1: U32, rest: List<&2,P113DStmt>) -> U32:
  match a1:
    case 4: 4
    case _: w5b_f32_scan_body(rest,a1)

@unsafe
def w5b_f32_scan_step(st: P113DStmt, rest: List<&2,P113DStmt>, +acc: U32) -> U32:
  match st:
    case P113DAgain{_}: w5b_f32_bd_cont(U32.or(acc,1),rest)
    case P113DCall{_,_,_}: 4
    case P113DScalar{s}: w5b_f32_bd_cont(w5b_f32_scan_scalar(s,acc),rest)
    case P113DIf{_,yes,no}: w5b_f32_bd_cont(w5b_f32_bd_cont(w5b_f32_scan_body(yes,acc),no),rest)
    case _: w5b_f32_scan_body(rest,acc)

@unsafe
def w5b_f32_scan_body(body, acc):
  match body:
    case Nil{}: acc
    case Con{st,rest}: w5b_f32_scan_step(st,rest,acc)

@unsafe
def agy_map_emit_bit(+pfx: String, +snil: U32, +scon: U32, +key_reg: U32,
    +l_bit0: String, +l_bit1: String, +l_bail: String) -> X188Seq:
  +l_walk = pfx ++ "_bw"
  +l_slok = pfx ++ "_bs"
  +l_chr  = pfx ++ "_bc"
  x188_many([
    # Check pos < 2^32
    x188_i2("movq",x188_reg(7,64),x188_reg(8,64)),
    x188_i2("shrq",X187Imm{32,0},x188_reg(8,64)),
    x188_i2("testq",x188_reg(8,64),x188_reg(8,64)),
    x188_i1("jne",X187Target{l_bail}),
    # ci = (pos * 0xF83E0F84) >> 37 into %r8
    x188_i2("movabsq",X187Imm{4164816772,0},x188_reg(8,64)),
    x188_i2("imulq",x188_reg(7,64),x188_reg(8,64)),
    x188_i2("shrq",X187Imm{37,0},x188_reg(8,64)),
    # off = pos - ci * 33 into %rdi
    x188_i2("movq",x188_reg(8,64),x188_reg(9,64)),
    x188_i2("imulq",X187Imm{33,0},x188_reg(9,64)),
    x188_i2("subq",x188_reg(9,64),x188_reg(7,64)),
    # Walk s = key_reg in %r9 for %r8 (ci) hops
    x188_i2("movq",x188_reg(key_reg,64),x188_reg(9,64)),
    x188_label(l_walk),
    x188_i2("movq",x188_reg(9,64),x188_reg(2,64)),
    x188_i2("shrq",X187Imm{40,0},x188_reg(2,64)),
    x188_i2("andq",X187Imm{65535,0},x188_reg(2,64)),
    x188_i2("cmpq",X187Imm{snil,0},x188_reg(2,64)),
    x188_i1("je",X187Target{l_bit0}),
    x188_i2("cmpq",X187Imm{scon,0},x188_reg(2,64)),
    x188_i1("jne",X187Target{l_bail}),
    # Extract s_loc into %rdx (handling tag 0x02 and 0x82)
    x188_i2("movq",x188_reg(9,64),x188_reg(1,64)),
    x188_i2("shrq",X187Imm{56,0},x188_reg(1,64)),
    x188_i2("movabsq",X187Imm{4294967295,255},x188_reg(2,64)),
    x188_i2("andq",x188_reg(9,64),x188_reg(2,64)),
    x188_i2("cmpq",X187Imm{2,0},x188_reg(1,64)),
    x188_i1("je",X187Target{l_slok}),
    x188_i2("cmpq",X187Imm{130,0},x188_reg(1,64)),
    x188_i1("jne",X187Target{l_bail}),
    x188_i2("movq",X187Indexed{13,2,8,0},x188_reg(2,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(2,64)),
    x188_label(l_slok),
    x188_i2("testq",x188_reg(8,64),x188_reg(8,64)),
    x188_i1("je",X187Target{l_chr}),
    x188_i2("movq",X187Indexed{13,2,8,8},x188_reg(9,64)),
    x188_i2("subq",X187Imm{1,0},x188_reg(8,64)),
    x188_i1("jmp",X187Target{l_walk}),
    x188_label(l_chr),
    x188_i2("testq",x188_reg(7,64),x188_reg(7,64)),
    x188_i1("je",X187Target{l_bit1}),
    # ch = heap[s_loc] in %r9d, shift = 32 - off in %ecx
    x188_i2("movl",X187Indexed{13,2,8,0},x188_reg(9,32)),
    x188_i2("movl",X187Imm{32,0},x188_reg(1,32)),
    x188_i2("subl",x188_reg(7,32),x188_reg(1,32)),
    x188_i2("shrl",x188_reg(1,8),x188_reg(9,32)),
    x188_i2("andl",X187Imm{1,0},x188_reg(9,32)),
    x188_i1("jne",X187Target{l_bit1}),
    x188_i1("jmp",X187Target{l_bit0})
  ])

# Shared inline string equality:
# Inputs: %r13 = heap, %r8 = s1, %r9 = s2
# Clobbers: %rax, %rcx, %rdx, %rdi, %r8, %r9
# Preserves: %rsi, %r10, %r11, %rbx, %r12..%r15
# Branches to l_eq (equal), l_ne (not equal), or l_bail (unexpected tag)
@unsafe
def agy_map_emit_streq(+pfx: String, +snil: U32, +scon: U32,
    +l_eq: String, +l_ne: String, +l_bail: String) -> X188Seq:
  +l_loop = pfx ++ "_sc"
  +l_c1n  = pfx ++ "_s1n"
  +l_l1ok = pfx ++ "_s1k"
  +l_l2ok = pfx ++ "_s2k"
  x188_many([
    x188_label(l_loop),
    x188_i2("cmpq",x188_reg(9,64),x188_reg(8,64)),
    x188_i1("je",X187Target{l_eq}),
    # cid1 in %rcx, cid2 in %rdx
    x188_i2("movq",x188_reg(8,64),x188_reg(1,64)),
    x188_i2("shrq",X187Imm{40,0},x188_reg(1,64)),
    x188_i2("andq",X187Imm{65535,0},x188_reg(1,64)),
    x188_i2("movq",x188_reg(9,64),x188_reg(2,64)),
    x188_i2("shrq",X187Imm{40,0},x188_reg(2,64)),
    x188_i2("andq",X187Imm{65535,0},x188_reg(2,64)),
    x188_i2("cmpq",X187Imm{snil,0},x188_reg(1,64)),
    x188_i1("jne",X187Target{l_c1n}),
    x188_i2("cmpq",X187Imm{snil,0},x188_reg(2,64)),
    x188_i1("je",X187Target{l_eq}),
    x188_i1("jmp",X187Target{l_ne}),
    x188_label(l_c1n),
    x188_i2("cmpq",X187Imm{snil,0},x188_reg(2,64)),
    x188_i1("je",X187Target{l_ne}),
    x188_i2("cmpq",X187Imm{scon,0},x188_reg(1,64)),
    x188_i1("jne",X187Target{l_bail}),
    x188_i2("cmpq",X187Imm{scon,0},x188_reg(2,64)),
    x188_i1("jne",X187Target{l_bail}),
    # loc1 -> %rcx
    x188_i2("movq",x188_reg(8,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{56,0},x188_reg(0,64)),
    x188_i2("movabsq",X187Imm{4294967295,255},x188_reg(1,64)),
    x188_i2("andq",x188_reg(8,64),x188_reg(1,64)),
    x188_i2("cmpq",X187Imm{2,0},x188_reg(0,64)),
    x188_i1("je",X187Target{l_l1ok}),
    x188_i2("cmpq",X187Imm{130,0},x188_reg(0,64)),
    x188_i1("jne",X187Target{l_bail}),
    x188_i2("movq",X187Indexed{13,1,8,0},x188_reg(1,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(1,64)),
    x188_label(l_l1ok),
    # loc2 -> %rdx
    x188_i2("movq",x188_reg(9,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{56,0},x188_reg(0,64)),
    x188_i2("movabsq",X187Imm{4294967295,255},x188_reg(2,64)),
    x188_i2("andq",x188_reg(9,64),x188_reg(2,64)),
    x188_i2("cmpq",X187Imm{2,0},x188_reg(0,64)),
    x188_i1("je",X187Target{l_l2ok}),
    x188_i2("cmpq",X187Imm{130,0},x188_reg(0,64)),
    x188_i1("jne",X187Target{l_bail}),
    x188_i2("movq",X187Indexed{13,2,8,0},x188_reg(2,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(2,64)),
    x188_label(l_l2ok),
    # Compare chars (raw u64/u32 words at heap[loc1], heap[loc2])
    x188_i2("movq",X187Indexed{13,1,8,0},x188_reg(7,64)),
    x188_i2("cmpq",X187Indexed{13,2,8,0},x188_reg(7,64)),
    x188_i1("jne",X187Target{l_ne}),
    x188_i2("movq",X187Indexed{13,1,8,8},x188_reg(8,64)),
    x188_i2("movq",X187Indexed{13,2,8,8},x188_reg(9,64)),
    x188_i1("jmp",X187Target{l_loop})
  ])

# Emit native Map.get fast path wrapper for p111 symbol
@unsafe
def agy_map_sink_rsi(+skip_lbl: String) -> X188Seq:
  x188_many([
    x188_i2("movq",x188_reg(6,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{56,0},x188_reg(0,64)),
    x188_i2("cmpq",X187Imm{2,0},x188_reg(0,64)),
    x188_i1("jb",X187Target{skip_lbl}),
    x188_i2("movq",x188_reg(12,64),x188_reg(7,64)),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("call",X187Target{"p111_rt_sink"}),
    x188_label(skip_lbl)])

# Helper: unpack Chr{code} in %rax -> u32 code in %eax (handles unboxed U32 TAG_NUM, TAG_PAK, TAG_CTR, RFC|TAG_CTR); clobbers %rcx
@unsafe
def agy_map_unpack_chr(+prefix: String, +bail: String, +chr_cid: U32) -> X188Seq:
  +chr_pak = U32.add(65536,chr_cid)
  +chr_ctr = U32.add(131072,chr_cid)
  +l_pak = prefix ++ "_cp"
  +l_dir = prefix ++ "_cd"
  x188_many([
    x188_i2("movq",x188_reg(0,64),x188_reg(1,64)),
    x188_i2("shrq",X187Imm{32,0},x188_reg(1,64)),
    x188_i2("testq",x188_reg(1,64),x188_reg(1,64)),
    x188_i1("jz",X187Target{l_pak}),
    x188_i2("shrq",X187Imm{8,0},x188_reg(1,64)),
    x188_i2("cmpq",X187Imm{chr_pak,0},x188_reg(1,64)),
    x188_i1("je",X187Target{l_pak}),
    x188_i2("andl",X187Imm{8388607,0},x188_reg(1,32)),
    x188_i2("cmpl",X187Imm{chr_ctr,0},x188_reg(1,32)),
    x188_i1("jne",X187Target{bail}),
    x188_i2("movq",x188_reg(0,64),x188_reg(1,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(1,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(1,64)),
    x188_i2("shrq",X187Imm{63,0},x188_reg(0,64)),
    x188_i2("testl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("jz",X187Target{l_dir}),
    x188_i2("movq",X187Indexed{13,1,8,0},x188_reg(1,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(1,64)),
    x188_label(l_dir),
    x188_i2("movl",X187Indexed{13,1,8,0},x188_reg(0,32)),
    x188_label(l_pak)])

# Shared key-unpack sequence: unpacks %r8 (String) into kbuf[0..%r15) at 0(%rbp), jumps to bail on >64 or bad tag
@unsafe
def agy_map_bit_at(+prefix: String, +bail: String) -> X188Seq:
  +l_b0 = prefix ++ "_b0"
  +l_b1 = prefix ++ "_b1"
  +l_bd = prefix ++ "_bd"
  x188_many([
    x188_i2("cmpq",X187Imm{2112,0},x188_reg(0,64)),
    x188_i1("jae",X187Target{bail}),
    x188_i2("movq",x188_reg(0,64),x188_reg(2,64)),
    x188_i2("movl",X187Imm{4164816772,0},x188_reg(1,32)),
    x188_i2("imulq",x188_reg(1,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{37,0},x188_reg(0,64)),
    x188_i2("cmpq",x188_reg(15,64),x188_reg(0,64)),
    x188_i1("jae",X187Target{l_b0}),
    x188_i2("movq",x188_reg(0,64),x188_reg(1,64)),
    x188_i2("shlq",X187Imm{5,0},x188_reg(1,64)),
    x188_i2("addq",x188_reg(0,64),x188_reg(1,64)),
    x188_i2("subq",x188_reg(1,64),x188_reg(2,64)),
    x188_i2("testl",x188_reg(2,32),x188_reg(2,32)),
    x188_i1("jz",X187Target{l_b1}),
    x188_i2("movl",X187Indexed{5,0,4,0},x188_reg(0,32)),
    x188_i2("movl",X187Imm{32,0},x188_reg(1,32)),
    x188_i2("subl",x188_reg(2,32),x188_reg(1,32)),
    x188_i2("shrl",x188_reg(1,8),x188_reg(0,32)),
    x188_i2("andl",X187Imm{1,0},x188_reg(0,32)),
    x188_i1("jmp",X187Target{l_bd}),
    x188_label(l_b0),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("jmp",X187Target{l_bd}),
    x188_label(l_b1),
    x188_i2("movl",X187Imm{1,0},x188_reg(0,32)),
    x188_label(l_bd)])

# Shared cmp_and_diff: compares kbuf[0..%r15) against %r9 (leaf_k).
# Jumps to eq_lbl if equal; jumps to diff_lbl with diff in %rax if unequal; jumps to bail on bad tag.
# Clobbers %rax, %rcx, %rdx, %r9, %r10, %r11.
def x188_table_head(+name: String, +alignment: U32, +exported: Bool) -> X188Seq:
  x188_many([X188One{PSection{nt_choose(U32,U32.is_eq(alignment,1) && Bool.not(exported) && Bool.not(agy_str_eq(name,"p111_cid_hot")),u => 2,u => 3)}},X188One{PAlign{alignment}},
    nt_choose(X188Seq,exported,u => X188One{PGlobal{name}},u => X188Empty{}),
    X188One{PType{name,1}},x188_label(name)])

def x181_program_main() -> X188Seq:
  x188_many([X188One{PSection{1}},X188One{PGlobal{"main"}},X188One{PType{"main",2}},
    x188_label("main"),x188_i2("leaq",X187Rip{"p111_program",0,0},x188_reg(2,64)),
    x188_i1("jmp",X187Target{"p111_rt_main"}),X188One{PSize{"main"}}])

@unsafe
def x187_e_address(value: X187Operand, +reg: U32, field: U32, +trailing: U32) -> X187RM:
  match value:
    case X187Reg{index,width,vector}: X187RM{[U32.add(192,U32.add(U32.mul(U32.mod(reg,8),8),U32.mod(index,8)))],[],""}
    case X187Mem{base,disp}: X187RM{x187_e_mem(base,disp,reg),[],""}
    case X187Indexed{+base,+index,+scale,+disp}:
      nt_choose(X187RM,x191_e_indexed_valid(base,index,scale),u =>
        X187RM{x191_e_indexed(base,index,scale,disp,reg),[],""},
        u => X187RM{[],[],"invalid indexed ModRM operand"})
    case X187Rip{symbol,+lo,+hi}:
      +sub = U32.add(4,trailing)
      X187RM{[U32.add(5,U32.mul(U32.mod(reg,8),8)),0,0,0,0],
        [X187Relocation{1,U32.inc(field),2,symbol,U32.sub(lo,sub),
          U32.sub(hi,nt_choose(U32,U32.is_lt(lo,sub),u => 1,u => 0))}],""}
    case _: X187RM{[],[],"invalid ModRM operand"}

@unsafe
def x187_e_reg_immediate(+dst: X187Operand, +lo: U32, +hi: U32, +width: U32) -> X187Encoded:
  match dst:
    case X187Reg{+index,bits,vector}:
      nt_choose(X187Encoded,x187_e_reg(dst,width,False{}) &&
          (U32.is_eq(width,64) || (U32.is_eq(hi,0) && (Bool.not(U32.is_eq(width,8)) || U32.is_le(lo,255)))),u =>
        x187_e_ok(nt_append(U32,x187_e_prefix(0,U32.is_eq(width,64),0,dst,x187_e_byte(dst)),
          Con{U32.add(nt_choose(U32,U32.is_eq(width,8),v => 176,v => 184),U32.mod(index,8)),x187_e_imm(lo,hi,width)})),u => x187_e_error())
    case _: x187_e_error()

@unsafe
def x187_e_movabs(src: X187Operand, dst: X187Operand) -> X187Encoded:
  match src:
    case X187Imm{lo,hi}: x187_e_reg_immediate(dst,lo,hi,64)
    case _: x187_e_error()

@unsafe
def w5c_es_f8(ok: Bool, +operand: X187Operand, +code: U32) -> X187Encoded:
  match ok:
    case True{}: x187_e_ok(nt_append(U32,x187_e_prefix(0,False{},0,operand,False{}),[U32.add(code,U32.mod(x187_e_index(operand),8))]))
    case False{}: x187_e_error()

@unsafe
def x187_elf_symbol_bytes(symbol: X187Symbol, nameOffset: U32) -> List<&2,U32>:
  match symbol:
    case X187Symbol{name,section,value,size,global,kind}:
      x187_elf_cat(x187_elf_u32(nameOffset),
        Con{U32.add(kind,nt_choose(U32,global,u => 16,u => 0)),Con{0,
          x187_elf_cat(x187_elf_u16(section),
            x187_elf_cat(x187_elf_u64(value,0),x187_elf_u64(size,0)))}})

@unsafe
def x187_elf_section_header(section: X187ElfSection, offset: U32, size: U32) -> List<&2,U32>:
  match section:
    case X187ElfSection{name,kind,flags,alignment,entry,link,info,bytes}:
      x187_elf_cat(x187_elf_u32(name),x187_elf_cat(x187_elf_u32(kind),
      x187_elf_cat(x187_elf_u64(flags,0),x187_elf_cat(x187_elf_u64(0,0),
      x187_elf_cat(x187_elf_u64(offset,0),x187_elf_cat(x187_elf_u64(size,0),
      x187_elf_cat(x187_elf_u32(link),x187_elf_cat(x187_elf_u32(info),
      x187_elf_cat(x187_elf_u64(alignment,0),x187_elf_u64(entry,0))))))))))

@unsafe
def x187_elf_header(sectionOffset: U32) -> List<&2,U32>:
  x187_elf_cat([127,69,76,70,2,1,1,0,0,0,0,0,0,0,0,0,1,0,62,0,1,0,0,0],
    x187_elf_cat(x187_elf_zero(16,[]),x187_elf_cat(x187_elf_u64(sectionOffset,0),
      [0,0,0,0,64,0,0,0,0,0,64,0,11,0,9,0])))

@unsafe
def w7_shdr(+name: U32, +kind: U32, +flags: U32, +offset: U32, +size: U32,
    +link: U32, +info: U32, +align: U32, +entry: U32, tail: List<&2,U32>) -> List<&2,U32>:
  x187_elf_cat(x187_elf_u32(name),x187_elf_cat(x187_elf_u32(kind),
  x187_elf_cat(x187_elf_u64(flags,0),x187_elf_cat(x187_elf_u64(0,0),
  x187_elf_cat(x187_elf_u64(offset,0),x187_elf_cat(x187_elf_u64(size,0),
  x187_elf_cat(x187_elf_u32(link),x187_elf_cat(x187_elf_u32(info),
  x187_elf_cat(x187_elf_u64(align,0),x187_elf_cat(x187_elf_u64(entry,0),tail))))))))))

@unsafe
def w7_bb_apply(+section: U32, +cur: U32, rc: W7RevCount, +build: X187Build,
    t: List<&2,U32>, r: List<&2,U32>, d: List<&2,U32>, +ts: U32, +rs: U32, +ds: U32,
    symbols: KDef, names: List<&2,String>, relocs: List<&2,X187Relocation>, error: String) -> X187Build:
  match rc:
    case W7RevCount{out,+count}:
      nt_choose(X187Build,U32.is_gt(count,134217728) || U32.is_gt(cur,U32.sub(134217728,count)),
        u => x187_build_error("x86 object section exceeds 128 MiB bound",build),
        u => w7_bb_sec(section,out,count,build,t,r,d,ts,rs,ds,symbols,names,relocs,error))

@unsafe
def x201f_selected(+raw: List<&2,U32>, patches: List<&2,X187Relocation>, +size: U32,
    +plan: List<&2,X187Relocation>) -> X187Encoded:
  match plan:
    case Nil{}: x188_fixup_bytes(nt_reverse(U32,raw,[]),patches,0,[])
    case Con{head,rest}: x201f_apply(raw,plan,size,[])

@unsafe
def x181_function_fast_done(+symbol: String, code: X181Code) -> X181Output:
  match code:
    case X181Code{chunks,next,+terminal,+error}:
      X181Output{[x188_cat(x188_finish(chunks),X188One{PSize{symbol}})],
        nt_choose(String,String.is_empty(error) && Bool.not(terminal),u => "x86 unterminated function",u => error)}

@unsafe
def agy_lpt_priv_wrap(+fns: List<&2,P113DFunction>, +acc: List<&2,AgyLptPriv>) -> List<&2,AgyLptPriv>:
  match fns:
    case Nil{}: acc
    case Con{+head,rest}: agy_lpt_priv_wrap(rest,Con{AgyLptPriv{agy_lpt_priv_weight(head),head},acc})

@unsafe
def w8_relocate_context(ctx: P134Context, +fid_base: U32) -> P134Context:
  match ctx:
    case P134Context{N111Ids{fns,ctors},index,direct,ready,view,lookups,heap,mode}:
      P134Context{N111Ids{w8_shift_fids_tree(fns,fid_base),ctors},index,direct,ready,view,lookups,heap,mode}

@unsafe
def w8_relocate_tables(tables: List<&2,P111QData>, +fid_base: U32, +mod_name: String) -> List<&2,P111QData>:
  match tables:
    case Nil{}: []
    case Con{head,rest}:
      Con{w8_relocate_table(head,fid_base,mod_name),w8_relocate_tables(rest,fid_base,mod_name)}

