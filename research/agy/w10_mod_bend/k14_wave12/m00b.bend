# Module m00b (K=14 acyclic topological split of wave12_unified/compiler.bend)
# defs=615 laws=35 sccs=582 deps=[m00a] cross_imports=14 fid_base=3400..6799

law core_subst_stable_app_last:
  for +f: KTerm
  for +x: KTerm
  for +rest: List<&2, KTerm>
  Bool

# Module: src/core/term.bend:501
law index_first:
  for +ds: List<&2, KDef>
  KDef

# Module: src/core/index.bend:13
law norm_exact_names:
  for +as: List<&2, String>
  for +bs: List<&2, String>
  Bool

# Module: src/core/normalize.bend:458
law kp_index:
  for env: List<&2, KPName>
  for +id: U32
  U32

# Module: src/core/pretty.bend:15
law kp_digit:
  for +n: U32
  String

# Module: src/core/pretty.bend:27
law kp_float_point:
  for s: String
  String

# Module: src/core/pretty.bend:97
law sp_take_next:
  for +ts: List<&2, KTerm>
  for +n: U32
  List<&2, KTerm>

# Module: src/check/specialize.bend:23
law sp_drop_next:
  for +ts: List<&2, KTerm>
  for +n: U32
  List<&2, KTerm>

# Module: src/check/specialize.bend:28
law f_kind_wrap:
  for +p: FParsed
  FParsed

# Module: src/front/parser.bend:35
law f_list_nodes:
  for +xs: List<&2, KTerm>
  for +con: String
  for +nil: String
  KTerm

# Module: src/front/parser.bend:79
law f_has_id:
  for +vars: List<&2, KTerm>
  for +id: U32
  Bool

# Module: src/front/elaborate.bend:27
law f_seed_text_equal:
  for +a: String
  for +b: String
  Bool

# Module: src/load/modules.bend:12
law dg_text:
  for +s: String
  KTerm

# Module: src/diagnostic/trace.bend:8
law dg_bad_detail:
  for +world: KWorld
  for +message: String
  for +expected: KTerm
  for +observed: KTerm
  KChecking

# Module: src/diagnostic/trace.bend:15
law dg_bad_message:
  for +world: KWorld
  for +message: String
  for +expected: KTerm
  KChecking

# Module: src/diagnostic/trace.bend:21
law j_word_text:
  for +value: Maybe<&2, U32>
  for +float: Bool
  String

# Module: src/back/js/literals.bend:40
law j_l_names:
  for +names: List<&2, String>
  String

# Module: src/back/native/text.bend:74
law nc_occurs:
  for +t: KTerm
  for +id: U32
  Bool

# Module: src/back/native/bridge.bend:505
law driver_holes:
  for +t: KTerm
  U32

# Module: src/driver/api.bend:53
law driver_holes_terms:
  for +ts: List<&2,KTerm>
  U32

# Module: src/driver/api.bend:65
@unsafe
def name_key(+name: String) -> String:
  match name:
    case SNil{}: ""
    case SCon{c, rest}: kc(String, Char.is_eq(c, ':'), u => "." ++ rest, u => SCon{c, name_key(rest)})

# First-order trusted core. Binder identifiers are globally unique.
# Quantities: 0 erased, 1 affine, 2 unrestricted. No function-valued fields.

# Module: src/core/term.bend:36
@unsafe
def atom(
  +tag: String,
) -> KTerm:
  kt(tag, "", 0, 0, Nil{})

# Module: src/core/term.bend:52
@unsafe
def kid(
  +t: KTerm,
  +n: U32,
) -> KTerm:
  terms_at(ks(t), n)

# Module: src/core/term.bend:142
@unsafe
def var(
  +name: String,
  +id: U32,
) -> KTerm:
  kt("Var", name, id, 0, Nil{})

# Module: src/core/term.bend:149
@unsafe
def ref(
  +name: String,
) -> KTerm:
  kt("Ref", name, 0, 0, Nil{})

# Module: src/core/term.bend:155
@unsafe
def qua(
  +q: U32,
) -> KTerm:
  kt("Qua", "", 0, q, Nil{})

# Module: src/core/term.bend:161
@unsafe
def app(
  +f: KTerm,
  +x: KTerm,
) -> KTerm:
  kt("App", "", 0, 0, Con{f, Con{x, Nil{}}})

# Module: src/core/term.bend:174
@unsafe
def all(
  +q: U32,
  +name: String,
  +id: U32,
  +a: KTerm,
  +b: KTerm,
) -> KTerm:
  kt("All", name, id, q, Con{a, Con{b, Nil{}}})

# Module: src/core/term.bend:184
@unsafe
def has_name(
  +ns: List<&2, String>,
  +name: String,
) -> Bool:
  match ns:
    case Nil{}:
      False{}
    case Con{h, t}:
      has_name_next(t, name, p88_string_eq(h, name))

# Module: src/core/term.bend:332
@unsafe
def has_name_next(+rest: List<&2,String>, +name: String, +same: Bool) -> Bool:
  match same:
    case True{}: True{}
    case False{}: has_name(rest, name)
@unsafe
def core_subst_stable_app_last(f, x, rest):
  match rest:
    case Con{h, tail}: False{}
    case Nil{}:
      Bool.not(p98_tag_eq(f, "Lam"))

# Module: src/core/term.bend:491
@unsafe
def w7_br_4(w7_c: Bool, +n: U32, +bits: U32, +begin: U32, +end: U32) -> KTerm:
  match w7_c:
    case True{}:
      kt_span("Ctr", "WNil", 0, 1, Nil{}, begin, end)
    case False{}:
      kt_span("Ctr", "WCon", 0, 1, [kt_span("Ctr", kc(String, U32.is_eq(U32.and(n, 1), 0), u => "False", u => "True"), 0, 1, Nil{}, begin, end), core_literal_word(U32.shrn(n, 1n), U32.sub(bits, 1), begin, end)], begin, end)

@unsafe
def core_literal_word(+n: U32, +bits: U32, +begin: U32, +end: U32) -> KTerm:
  w7_br_4(U32.is_eq(bits, 0), n, bits, begin, end)

# Module: src/core/term.bend:534
@unsafe
def core_literal_string(+s: String, +begin: U32, +end: U32) -> KTerm:
  match s:
    case SNil{}: kt_span("Ctr", "SNil", 0, 1, Nil{}, begin, end)
    case SCon{c, rest}: kt_span("Ctr", "SCon", 0, 1, [kt_span("Ctr", "Chr", 0, 1, [KLiteral{"U32", Char.to_u32(c), "", begin, end}], begin, end), KLiteral{"String", 0, rest, begin, end}], begin, end)

# Module: src/core/term.bend:547
@unsafe
def k_quantity_present(+t: KTerm) -> Bool:
  match t:
    case KTerm{tag, name, id, quant, kids, removed, begin, end}: p88_string_eq(tag, "Lam")
    case KLambda{name, id, quant, kids, removed, begin, end, present}: present
    case KLiteral{kind, number, text, begin, end}: False{}

# Field-changing structural rebuilds retain the input variant and syntax fact.

# Module: src/core/term.bend:652
@unsafe
def index_first(ds):
  match ds:
    case Nil{}:
      missing()
    case Con{h, rest}:
      h

# The public callers supply complete 32-bit hashes. `bits` remains in this
# internal ABI for the native identifier validator; paths use stored masks.

# Module: src/core/index.bend:71
@unsafe
def w7_ctor_tree_tail(+tail: List<&2, KDef>) -> KDef:
  match tail:
    case Nil{}:
      missing()
    case Con{ctors, _}:
      ctors

@unsafe
def book_final_name_valid(
  +name: String,
) -> Bool:
  match name:
    case SNil{}: True{}
    case SCon{h, rest}:
      kc(Bool, U32.is_le(U32.sub(Char.to_u32(h), 55296), 2047),
        u => False{}, u => book_final_name_valid(rest))

# Module: src/core/index.bend:363
@unsafe
def w7_br_27(w7_c: Bool, +a: KTerm, +b: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      kt("Min", "", 0, 0, Con{a, Con{b, Nil{}}})
    case False{}:
      b

@unsafe
def norm_exact_names(as, bs):
  match as bs:
    case Nil{} Nil{}:
      True{}
    case Con{a, ar} Con{b, br}:
      kc(Bool, p88_string_eq(a, b), u => norm_exact_names(ar, br), u => False{})
    case other_a other_b:
      False{}

# Comparison is a worklist of conjunctions with explicit alternatives for
# the right-hand kind meet. Deep constructor equality does not grow the host stack.
# The empty-book pass proves symbolic copies before unfolding definitions.
# Each policy owns its heap. A failed rigid comparison cannot cache an opaque
# head in the full-book pass, or share cells across independent conversions.

# Module: src/core/normalize.bend:467
@unsafe
def g_class_get(+classes: GClasses, +id: U32) -> Maybe<&2,GClassEntry>:
  match classes:
    case GClassesEmpty{}: None{}
    case GClassesNode{entry,left,right}:
      kc(Maybe<&2,GClassEntry>,U32.is_eq(id,0),u => entry,
        u => kc(Maybe<&2,GClassEntry>,U32.is_eq(U32.and(id,1),0),
          u => g_class_get(left,U32.shr(id)),u => g_class_get(right,U32.shr(id))))

@unsafe
def g_class_put(+classes: GClasses, +id: U32, +entry: GClassEntry) -> GClasses:
  match classes:
    case GClassesEmpty{}:
      g_class_put(GClassesNode{None{},GClassesEmpty{},GClassesEmpty{}},id,entry)
    case GClassesNode{old,left,right}:
      kc(GClasses,U32.is_eq(id,0),u => GClassesNode{Some{entry},left,right},
        u => kc(GClasses,U32.is_eq(U32.and(id,1),0),
          u => GClassesNode{old,g_class_put(left,U32.shr(id),entry),right},
          u => GClassesNode{old,left,g_class_put(right,U32.shr(id),entry)}))

@unsafe
def g_get(
  +heap: GHeap,
  +id: U32,
) -> KTerm:
  match heap:
    case GEmpty{}:
      {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}
    case GNode{value, left, right}:
      kc(KTerm, U32.is_eq(id, 0), u => value, u => kc(KTerm, U32.is_eq(U32.and(id, 1), 0), u => g_get(left, U32.shr(id)), u => g_get(right, U32.shr(id))))

# Module: src/core/graph.bend:268
@unsafe
def kp_eq(
  +a: String,
  +b: String,
) -> Bool:
  p88_string_eq(a, b)

# Module: src/core/pretty.bend:144
@unsafe
def kp_index(env, id):
  match env:
    case Nil{}: id
    case Con{KPFile{ns, aliases}, tail}: kp_index(tail, id)
    case Con{KPName{n, +i, +depth}, +tail}:
      kc(U32, U32.is_eq(i, id), u => depth, u => kp_index(tail, id))

# Module: src/core/pretty.bend:222
@unsafe
def kp_digit(n):
  Char.show(Char.from_u32(kc(U32, U32.is_lt(n, 10), u => U32.add(n, 48), u => U32.add(n, 87))))

# Module: src/core/pretty.bend:353
@unsafe
def kp_float_point(s):
  match s:
    case SNil{}: ".0"
    case SCon{+h, +t}: kc(String, U32.is_eq(Char.to_u32(h), 101), u => ".0e" ++ t, u => Char.show(h) ++ kp_float_point(t))

# Module: src/core/pretty.bend:522
@unsafe
def uses_del(
  +xs: List<&2, KTerm>,
  +id: U32,
) -> List<&2, KTerm>:
  match xs:
    case Nil{}:
      Nil{}
    case Con{h, t}:
      kc(List<&2, KTerm>, U32.is_eq(ix(h), id), u => uses_del(t, id), u => Con{h, uses_del(t, id)})

# Module: src/check/quantity.bend:95
@unsafe
def w7_ctx_get_hit(hit: Bool, +h: KTerm, +t: List<&2, KTerm>, +id: U32) -> KTerm:
  match hit:
    case True{}:
      h
    case False{}:
      ctx_get(t, id)

@unsafe
def ctx_get(
  +ctx: List<&2, KTerm>,
  +id: U32,
) -> KTerm:
  match ctx:
    case Nil{}:
      {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}
    case Con{h, t}:
      w7_ctx_get_hit(U32.is_eq(ix(h), id), h, t, id)

# Module: src/check/kernel.bend:596
@unsafe
def ctx_bind(
  +ctx: List<&2, KTerm>,
  +id: U32,
  +q: U32,
  +name: String,
  +ty: KTerm,
) -> List<&2, KTerm>:
  Con{kt("Bind", name, id, q, Con{ty, Nil{}}), ctx}

# Module: src/check/kernel.bend:606
@unsafe
def w7_br_189(w7_c: Bool, +n: U32) -> String:
  match w7_c:
    case True{}:
      ""
    case False{}:
      U32.show(n) ++ " TODO" ++ kc(String, U32.is_eq(n, 1), u => "", u => "s") ++ " found.\nThe code is incomplete, and not a valid proof yet."

@unsafe
def kw_seed(+book: List<&2,KDef>, +bound: U32) -> KWorld:
  KWorld{book, Nil{}, kc(KWorldFresh, U32.is_eq(bound, 4294967295), u => KFreshDeferred{Nil{}}, u => KFreshKnown{U32.add(bound, 1)}), Nil{}}

# Module: src/check/kernel.bend:1270
@unsafe
def sk_quant(+q: U32) -> String:
  "{\"$\":\"" ++ kc(String, U32.is_eq(q, 0), u => "None", u => kc(String, U32.is_eq(q, 2), u => "Many", u => "Lone")) ++ "\"}"

# Module: src/check/specialize.bend:132
@unsafe
def sp_take(
  +ts: List<&2, KTerm>,
  +n: U32,
) -> List<&2, KTerm>:
  kc(List<&2, KTerm>, U32.is_eq(n, 0), u => Nil{}, u => sp_take_next(ts, n))

# Module: src/check/specialize.bend:270
@unsafe
def sp_take_next(ts, n):
  match ts:
    case Nil{}:
      Nil{}
    case Con{h, rest}:
      Con{h, sp_take(rest, U32.sub(n, 1))}

# Module: src/check/specialize.bend:278
@unsafe
def sp_drop(
  +ts: List<&2, KTerm>,
  +n: U32,
) -> List<&2, KTerm>:
  kc(List<&2, KTerm>, U32.is_eq(n, 0), u => ts, u => sp_drop_next(ts, n))

# Module: src/check/specialize.bend:285
@unsafe
def sp_drop_next(ts, n):
  match ts:
    case Nil{}:
      Nil{}
    case Con{h, rest}:
      sp_drop(rest, U32.sub(n, 1))

# Module: src/check/specialize.bend:293
@unsafe
def ka_wrap(
  +t: KTerm,
  +ty: KTerm,
) -> KTerm:
  kt("Ann", "", 0, 0, Con{t, Con{ty, Nil{}}})

# Module: src/check/annotate.bend:144
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
def ka_field(+annotated: KTerm, +quantity: U32) -> KTerm:
  kt("Ann", "", 1, quantity, ks(annotated))

# Module: src/front/lexer.bend:48
@unsafe
def f_eq(
  +a: String,
  +b: String,
) -> Bool:
  agy_str_eq(a, b)

# Module: src/front/lexer.bend:68
@unsafe
def f_context_stop(+term: KTerm) -> Bool:
  p98_tag_eq(term, "Error")

# Module: src/front/contextual.bend:68
@unsafe
def w7_br_304(w7_c: Bool, +term: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      kt_span("FComputedHead", "", 0, 1, [term], kb(term), ke(term))
    case False{}:
      term

@unsafe
def f_app(
  +f: KTerm,
  +xs: List<&2, KTerm>,
) -> KTerm:
  match xs:
    case Nil{}:
      f
    case Con{x, xt}:
      f_app(kt("App", "", 0, 1, [f, x]), xt)

# Module: src/front/parser.bend:189
@unsafe
def f_kind_wrap(p):
  match p:
    case FParsed{n, ts}:
      FParsed{kt("Typ", "", 0, 0, [n]), ts}

# Module: src/front/parser.bend:288
@unsafe
def f_list_nodes(xs, con, nil):
  match xs:
    case Nil{}:
      kt("Ctr", nil, 0, 1, Nil{})
    case Con{x, xt}:
      kt("Ctr", con, 0, 1, [x, f_list_nodes(xt, con, nil)])

# Module: src/front/parser.bend:367
@unsafe
def f_app_span(+f: KTerm, +xs: List<&2,KTerm>, +begin: U32, +end: U32) -> KTerm:
  match xs:
    case Nil{}: f
    case Con{x, rest}: f_app_span(kt_span("App", "", 0, 1, [f, x], begin, end), rest, begin, end)

# Semantic parser errors carry explicit producer data and an actual term range.
# Their historical fallback remains available to deliberately unlocated callers.

# Module: src/front/parser.bend:668
@unsafe
def fpe_message_at(+term: KTerm, +legacy: String, +message: String) -> KTerm:
  kt_span("Error", legacy, 0, 0, [kt("ParseMessage", message, 0, 0, Nil{})], kb(term), ke(term))

# Module: src/front/parser.bend:672
@unsafe
def fpe_expected_at(+term: KTerm, +legacy: String, +expected: String, +observed: String) -> KTerm:
  kt_span("Error", legacy, 0, 0, [kt("ParseExpected", expected, 0, 0, Nil{}), kt("ParseObserved", observed, 0, 0, Nil{})], kb(term), ke(term))

# Module: src/front/parser.bend:676
@unsafe
def fpe_message_note_at(+term: KTerm, +legacy: String, +message: String, +note: String) -> KTerm:
  kt_span("Error", legacy, 0, 0, [kt("ParseMessage", message, 0, 0, Nil{}), kt("ParseNote", note, 0, 0, Nil{})], kb(term), ke(term))


# Failure payloads request an original line or exact UTF16 cursor observation.

# Module: src/front/parser.bend:703
@unsafe
def f_parse_scope_empty() -> FParseScope:
  FParseScope{Nil{}, missing(), missing(), "", Nil{}, None{}}

# Module: src/front/declarations.bend:681

@unsafe
def ff_failed(+term: KTerm) -> Bool:
  p98_tag_eq(term, "Error")

# Module: src/front/flatten.bend:188
@unsafe
def ff_variable(+term: KTerm) -> Bool:
  p98_tag_eq(term, "Var")

# Module: src/front/elaborate.bend:60
@unsafe
def f_has_id(vars, id):
  match vars:
    case Nil{}:
      False{}
    case Con{v, vs}:
      U32.is_eq(ix(v), id) || f_has_id(vs, id)

# Module: src/front/elaborate.bend:126
@unsafe
def w7_br_465(w7_c: Bool, +n: U32, +b: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      b
    case False{}:
      kt("Ctr", "Succ", 0, 1, [f_nat_prefix(U32.sub(n, 1), b)])

@unsafe
def f_nat_prefix(+n: U32, +b: KTerm) -> KTerm:
  w7_br_465(U32.is_eq(n, 0), n, b)

# Module: src/front/literals_arrays.bend:143
@unsafe
def w7_br_477(w7_c: Bool, +term: KTerm, +head: KTerm, +arg: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      arg
    case False{}:
      k_with_children(term, [head, arg])

@unsafe
def f_seed_text_equal(a, b):
  p88_string_eq(a, b)

# Module: src/load/seed.bend:154
@unsafe
def f_prefix_ready_seed_completed(+state: FReadyPrefixState, +completed: FPrefixCompletion) -> FPrefixCompletion:
  match state completed:
    case FReadyPrefixState{names, ctors, count, ready} FPrefixCompletion{carrier, parsed}:
      match carrier:
        case FPrefixGraph{graph, prefix, suffix, actual, eligible}:
          kc(FPrefixCompletion, eligible && ready && U32.is_eq(count, actual),
            u => FPrefixCompletion{FReadyPrefixGraph{graph, prefix, suffix, count, True{}, names, ctors, names}, parsed},
            u => completed)
        case FReadyPrefixGraph{graph, prefix, suffix, actual, eligible, oldNames, oldCtors, baseNames}: completed

# Module: src/load/prefix.bend:148
@unsafe
def dg_text(s):
  kt("DText", s, 0, 0, Nil{})

# Module: src/diagnostic/trace.bend:50
@unsafe
def dg_bad_detail(world, message, expected, observed):
  KChecking{kt("DDetail", "", 0, 1, [expected, observed]), {KTerm{"Error", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Nil{}, message, world, 0}

# Module: src/diagnostic/trace.bend:54
@unsafe
def dg_bad_message(world, message, expected):
  KChecking{kt("DDetail", "", 0, 0, [expected, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}]), {KTerm{"Error", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Nil{}, message, world, 0}

# Module: src/diagnostic/trace.bend:58
@unsafe
def dg_pair(
  +expected: KTerm,
  +observed: KTerm,
) -> KTerm:
  kt("DDetail", "", 0, 1, [expected, observed])

# Module: src/diagnostic/trace.bend:65
@unsafe
def dg_unqualified_name(+rest: String, +name: String) -> String:
  match rest:
    case SNil{}: name
    case SCon{head,tail}: dg_unqualified_name(tail,kc(String,Char.is_eq(head,':'),u => tail,u => name))

@unsafe
def dg_origin_span(+origins: List<&2,DOrigin>, +begin: U32, +end: U32) -> DSpan:
  match origins:
    case Nil{}: DNoSpan{}
    case Con{DSourceOrigin{source, first, limit}, rest}:
      kc(DSpan, U32.is_gt(first, 0) && U32.is_gt(limit, first) && U32.is_ge(begin, first) && U32.is_ge(end, begin) && U32.is_lt(end, limit),
        u => DSpan{source, U32.sub(begin, first), U32.sub(end, first)},
        u => dg_origin_span(rest, begin, end))

# Module: src/diagnostic/produce.bend:59
@unsafe
def w5c2_j_spine_ref(is_ref: Bool, +name: String, +args: List<&2, KTerm>) -> KTerm:
  match is_ref:
    case True{}: kt("Call", name, 0, 0, args)
    case False{}: {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}

@unsafe
def j_escape_unit(+n: U32) -> String:
  "\\u{" ++ kc(String, U32.is_eq(n, 0), u => "0", u => U32.hex(n)) ++ "}"

# Module: src/back/js/shared-text.bend:52
@unsafe
def j_word_text(value, float):
  match value:
    case None{}:
      ""
    case Some{n}:
      kc(String, float, u => "bitsFloat(" ++ U32.show(n) ++ ")", u => U32.show(n))

# Module: src/back/js/literals.bend:45
@unsafe
def j_pure_shape_bound(+todo: List<&2,KTerm>, +fuel: U32) -> Bool:
  match todo:
    case Nil{}: True{}
    case Con{t, rest}: kc(Bool, U32.is_gt(fuel, 0), u =>
      j_pure_shape_bound(List.append(&2, KTerm, ks(t), rest), U32.sub(fuel, 1)), u => False{})

# Module: src/back/js/jpure.bend:457
@unsafe
def j_region_counter_uses(+todo: List<&2,KTerm>, +id: U32, +count: U32) -> U32:
  match todo:
    case Nil{}: count
    case Con{t, rest}:
      kc(U32, U32.is_ge(count, 2), u => count, u =>
        j_region_counter_uses(List.append(&2, KTerm, ks(t), rest), id,
          U32.add(count, kc(U32, p98_tag_eq(t, "Var") && U32.is_eq(ix(t), id), u => 1, u => 0))))

# A scalar-only use of a closed total producer/filter/map/fold pipeline may erase
# its private lists. This is selected only after the existing whole-root proof.

# Module: src/back/js/region.bend:823
@unsafe
def j_fusion_has_var(+xs: List<&2,KTerm>, +id: U32) -> Bool:
  match xs:
    case Nil{}: False{}
    case Con{h, rest}: U32.is_eq(ix(h), id) || j_fusion_has_var(rest, id)

# No arbitrary JPure calls: these native U32 operations are total under the
# unchanged numeric host guard. Existing emission owns per-operation wrapping
# and mod's zero-divisor behavior; this pass does not reassociate arithmetic.

# Module: src/back/js/region.bend:837
@unsafe
def j_l_names(names):
  match names:
    case Nil{}: ""
    case Con{h, rest}: kc(String, String.starts_with(h, "$js."), u => h, u => "")

# Module: src/back/native/text.bend:2
@unsafe
def nk_kind(+id: U32, env: List<&2, NC_Binding>) -> N_WordKind:
  match env:
    case Nil{}: N_W64{}
    case Con{NC_Binding{at, word, +kind}, rest}: nt_choose(N_WordKind, U32.is_eq(id, at), u => kind, u => nk_kind(id, rest))

# Module: src/back/native/layout.bend:18
@unsafe
def nk_field_binding(+id: U32, +mask: U32, +i: U32) -> NC_Binding:
  NC_Binding{id, "v_" ++ U32.show(id), nt_choose(N_WordKind, U32.is_ne(U32.and(mask, U32.shln(1, U32.to_nat(i))), 0), u => N_W32{}, u => N_W64{})}

# Module: src/back/native/intrinsic.bend:4
@unsafe
def ni_replace_all(+s: String, +key: String, +value: String) -> String:
  match s:
    case SNil{}: ""
    case SCon{+h, +t}:
      nt_choose(String, String.starts_with(s, key), u => value ++ ni_replace_all(String.drop(s, String.length(key)), key, value), u => SCon{h, ni_replace_all(t, key, value)})

# Module: src/back/native/intrinsic.bend:85
@unsafe
def nb_contains(+xs: List<&2, String>, +k: String) -> Bool:
  match xs:
    case Nil{}: False{}
    case Con{+h, +t}: p88_string_eq(h, k) || nb_contains(t, k)

# Module: src/back/native/emit.bend:2
@unsafe
def ne_stores(+base: String, +ws: List<&2, String>, +i: U32, +seal: Bool) -> String:
  match ws:
    case Nil{}: ""
    case Con{+h, +t}: "e.mem[" ++ base ++ " + " ++ U32.show(i) ++ "] = " ++ nt_choose(String, seal, u => "rfc_seal(e, " ++ h ++ ")", u => h) ++ ";\n" ++ ne_stores(base, t, U32.inc(i), seal)

# A checked no-sharing certificate permits cold non-Base parents. Raw emission
# lacks the macro and keeps the ordinary sealed stores. Other node kinds remain
# on ne_node; constructor identity comes from nc_ctor_identity provenance.

# Module: src/back/native/emit.bend:16
@unsafe
def nc_occurs_list(
  +ts: List<&2, KTerm>,
  +id: U32,
) -> Bool:
  match ts:
    case Nil{}: False{}
    case Con{h, t}: nc_occurs(h, id) || nc_occurs_list(t, id)

# Module: src/back/native/bridge.bend:120
@unsafe
def w5c2_nc_occurs_if(is_var: Bool, +t: KTerm, +id: U32) -> Bool:
  match is_var:
    case True{}: U32.is_eq(ix(t), id)
    case False{}: nc_occurs_list(ks(t), id)

@unsafe
def nc_occurs(t, id):
  w5c2_nc_occurs_if(p98_tag_eq(t, "Var"), t, id)

# Var remains a leaf even in malformed raw terms with Var children.

# Module: src/back/native/bridge.bend:125
@unsafe
def nc_remove_env(env: List<&2, NC_Binding>, +id: U32) -> List<&2, NC_Binding>:
  match env:
    case Nil{}: Nil{}
    case Con{NC_Binding{+at, +word, +kind}, +rest}:
      nt_choose(List<&2, NC_Binding>, U32.is_eq(at, id), u => rest, u => Con{NC_Binding{at, word, kind}, nc_remove_env(rest, id)})

# Module: src/back/native/bridge.bend:211
@unsafe
def nc_mklet(+id: U32, +val: KTerm, +body: KTerm) -> KTerm:
  kt("Let", "", 0, 0, [kt("Bind", "", id, 1, [val]), body])

# Module: src/back/native/bridge.bend:329
@unsafe
def nd_match_vars(args: List<&2, KTerm>) -> Bool:
  match args:
    case Nil{}: True{}
    case Con{h, rest}: p98_tag_eq(h, "Var") && nd_match_vars(rest)

# Module: src/back/native/direct.bend:128
@unsafe
def nd_comb_literal(args: List<&2, KTerm>) -> Bool:
  match args:
    case Nil{}: False{}
    case Con{+h, rest}: nt_choose(Bool, p98_tag_eq(h, "Lam"), u => True{}, u => nd_comb_literal(rest))

# Module: src/back/native/direct.bend:164
@unsafe
def nf_opaque_kinds(+left: U32) -> List<&2, N_WordKind>:
  nt_choose(List<&2, N_WordKind>, U32.is_eq(left, 0), u => Nil{}, u => Con{N_W64{}, nf_opaque_kinds(U32.sub(left, 1))})

# Module: src/back/native/flat.bend:96
law nq_layout_remaining:
  for ts: List<&2, KTerm>
  for +left: U32
  U32

@unsafe
def w5c2_nq_rem_if(z: Bool, +h: KTerm, +rest: List<&2, KTerm>, +left: U32) -> U32:
  match z:
    case True{}: 0
    case False{}: nq_layout_remaining(List.append(&2, KTerm, ks(h), rest), U32.sub(left, 1))

@unsafe
def nq_layout_remaining(ts, left):
  match ts:
    case Nil{}: left
    case Con{+h, +rest}:
      w5c2_nq_rem_if(U32.is_eq(left, 0), h, rest, left)

# Module: src/back/native/product-layout.bend:114
@unsafe
def w7_br_706(w7_c: Bool, +shape: KTerm) -> U32:
  match w7_c:
    case True{}:
      ix(shape)
    case False{}:
      1

@unsafe
def nq_match_args(args: List<&2, KTerm>) -> Bool:
  match args:
    case Nil{}: True{}
    case Con{+h, rest}: (p98_tag_eq(h, "Var") || p98_tag_eq(h, "NQBundle")) && nq_match_args(rest)

# Module: src/back/native/product.bend:211
@unsafe
def nq_has_bundle(args: List<&2, KTerm>) -> Bool:
  match args:
    case Nil{}: False{}
    case Con{h, rest}: p98_tag_eq(h, "NQBundle") || nq_has_bundle(rest)

# Module: src/back/native/product.bend:247
@unsafe
def nq_has_shape(shapes: List<&2, KTerm>) -> Bool:
  match shapes:
    case Nil{}: False{}
    case Con{h, rest}: p98_tag_eq(h, "NQShape") || nq_has_shape(rest)

# Module: src/back/native/product.bend:299
@unsafe
def nw_word(+bit: KTerm, +tail: KTerm) -> KTerm:
  kt("Ctr", "WCon", 0, 1, [bit, tail])

# Module: src/back/native/word-pattern.bend:61
@unsafe
def nw_descend(cover: NW_Cover, +bit: U32) -> NW_Cover:
  match cover:
    case NW_None{}: NW_None{}
    case NW_Cover{body, bits, fields}: NW_Cover{body, Con{kt("NWord", U32.show(bit), 0, 0, Nil{}), bits}, fields}

# Module: src/back/native/word-pattern.bend:87
@unsafe
def nw_row(+body: KTerm, +depth: U32, +value: U32, +fields: U32) -> KTerm:
  kt("NWRow", U32.show(value), depth, fields, [body])

# Module: src/back/native/word-pattern.bend:103
def no_effect_provider_member(names: List<&2, String>, +name: String) -> Bool:
  match names:
    case Nil{}: False{}
    case Con{head, rest}: p88_string_eq(head, name) || no_effect_provider_member(rest, name)

@unsafe
def ns_canonical(+text: String, parsed: Maybe<&2, U32>) -> Bool:
  match parsed:
    case None{}: False{}
    case Some{value}: p88_string_eq(text, U32.show(value))

# Module: src/back/native/static.bend:91
@unsafe
def no_immediate_ctor(emitted: N_Emitted) -> String:
  match emitted:
    case N_Emitted{code, word, next}: nt_choose(String, p88_string_eq(code, ""), u => word, u => "NATIVE_UNBOUND_VARIABLE")

# Module: src/back/native/observer-emitter.bend:20
@unsafe
def no_layout(+key: String, layouts: List<&2, NO_Layout>) -> Maybe<&2, NO_Layout>:
  match layouts:
    case Nil{}: None{}
    case Con{+layout, rest}:
      match layout:
        case NO_Layout{name, ctor, storage, width}: nt_choose(Maybe<&2, NO_Layout>, p88_string_eq(key, name), u => Some{layout}, u => no_layout(key, rest))

# Module: src/back/native/observer-emitter.bend:40
@unsafe
def no_field_decls(fields: List<&2, KTerm>, +storage: String, +word: String, +loc: String, +i: U32) -> String:
  match fields:
    case Nil{}: ""
    case Con{field, rest}:
      "Term v_" ++ U32.show(ix(field)) ++ " = " ++ nt_choose(String, p88_string_eq(storage, "Boxed"), u => "e.mem[" ++ loc ++ " + " ++ U32.show(i) ++ "]", u => nt_choose(String, p88_string_eq(storage, "Succ"), v => "(" ++ word ++ " - 1)", v => word)) ++ ";\n" ++ no_field_decls(rest, storage, word, loc, U32.inc(i))

# Module: src/back/native/observer-emitter.bend:76
@unsafe
def nol_error(+reason: String) -> KTerm:
  kt("NO_Refusal", reason, 0, 0, Nil{})

# Module: src/back/native/observer-layout.bend:20
@unsafe
def w7_br_755(w7_c: Bool, +field: KTerm, +tail: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      k_with_children(tail, Con{field, ks(tail)})
    case False{}:
      tail

@unsafe
def nol_wrap_cons(+head: KTerm, tail: NOL_Wrap) -> NOL_Wrap:
  match tail:
    case NOL_Wrap{+term, +roots, +shells, +observation, +error}: NOL_Wrap{k_with_children(term, Con{head, ks(term)}), roots, shells, observation, error}

# Module: src/back/native/observer-layout.bend:219
@unsafe
def nol_wrap_constructor(+ctor: String, fields: NOL_Wrap) -> NOL_Wrap:
  match fields:
    case NOL_Wrap{+term, +roots, +shells, +observation, +error}: NOL_Wrap{kt("Ctr", ctor, 0, 0, ks(term)), roots, shells, observation, error}

# Module: src/back/native/observer-layout.bend:224
@unsafe
def noa_atom(+ty: String, +origin: KTerm, +value: KTerm) -> KTerm:
  kt("OA", ty, 0, 0, [origin, value])

# Module: src/back/native/observer-analysis.bend:103
@unsafe
def noa_bind(id: U32, value: KTerm, env: List<&2, KTerm>) -> List<&2, KTerm>:
  Con{kt("OBind", "", id, 0, [value]), env}

# Module: src/back/native/observer-analysis.bend:117
@unsafe
def noa_spec(+name: String, specs: List<&2, NO_Spec>) -> Maybe<&2, NO_Spec>:
  match specs:
    case Nil{}: None{}
    case Con{+spec, +rest}:
      match spec:
        case NO_Spec{NO_Layout{+key, +ctor, +storage, +width}, +owner, +fields}:
          nt_choose(Maybe<&2, NO_Spec>, p88_string_eq(name, ctor), u => Some{spec}, u => noa_spec(name, rest))

# Module: src/back/native/observer-analysis.bend:126
@unsafe
def noa_no_absent(values: List<&2, KTerm>) -> Bool:
  match values:
    case Nil{}: True{}
    case Con{+h, +rest}: Bool.not(p98_tag_eq(h, "Absent")) && noa_no_absent(rest)

# Module: src/back/native/observer-analysis.bend:253
@unsafe
def noa_param_origin(+id: U32, params: List<&2, KTerm>, +i: U32) -> KTerm:
  match params:
    case Nil{}: {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}
    case Con{+p, +rest}: nt_choose(KTerm, U32.is_eq(ix(p), id), u => kt("OArg", "", i, 0, Nil{}), u => noa_param_origin(id, rest, U32.inc(i)))

# Module: src/back/native/observer-analysis.bend:377
@unsafe
def w7_br_776(w7_c: Bool) -> KTerm:
  match w7_c:
    case True{}:
      kt("OResult", "", 0, 0, Nil{})
    case False{}:
      {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}

@unsafe
def driver_holes(t):
  U32.add(kc(U32, p98_tag_eq(t, "Hol"), u => 1, u => 0), driver_holes_terms(ks(t)))

# Module: src/driver/api.bend:58
@unsafe
def driver_holes_terms(ts):
  match ts:
    case Nil{}: 0
    case Con{t, rest}: U32.add(driver_holes(t), driver_holes_terms(rest))

# Exact pinned compiler OWNED datatype set. User definitions remain valid for
# pure checking/normalization but cannot use the runtime's intrinsic layouts.

# Module: src/driver/api.bend:76
@unsafe
def p205_var_at(+id: U32, ids: List<&2,U32>, +depth: U32) -> Bool:
  match ids:
    case Nil{}: False{}
    case Con{x,xs}: kc(Bool,U32.is_eq(depth,0),u => U32.is_eq(id,x),u => p205_var_at(id,xs,U32.sub(depth,1)))

@unsafe
def w7_br_793(w7_c: Bool, +original: KTerm, +child: KTerm, +prefix: List<&2,KTerm>) -> KTerm:
  match w7_c:
    case True{}:
      child
    case False{}:
      k_with_children(original,List.append(&2,KTerm,prefix,[child]))

law w5c3_has_var:
  for +t: KTerm
  for +id: U32
  Bool

@unsafe
def w5c3_hv_step(hit: Bool, rest: List<&2,KTerm>, +id: U32) -> Bool:
  match hit:
    case True{}: True{}
    case False{}: w5c3_has_var_fields(rest,id)

@unsafe
def w5c3_has_var_fields(xs: List<&2,KTerm>, +id: U32) -> Bool:
  match xs:
    case Nil{}: False{}
    case Con{x,rest}: w5c3_hv_step(w5c3_has_var(x,id), rest, id)

@unsafe
def w5c3_hv_if(is_var: Bool, +t: KTerm, +id: U32) -> Bool:
  match is_var:
    case True{}: U32.is_eq(ix(t),id)
    case False{}: w5c3_has_var_fields(ks(t),id)

@unsafe
def w5c3_has_var(t, id):
  w5c3_hv_if(p98_tag_eq(t,"Var"), t, id)
@unsafe
def w7_br_815(w7_c: Bool, +arg: KTerm, +ty: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      arg
    case False{}:
      kt("Ann","",0,0,[arg,ty])

@unsafe
def w5c3_p205u_ch_leaf(is_leaf: Bool, +t: KTerm) -> List<&2,KTerm>:
  match is_leaf:
    case True{}: []
    case False{}: ks(t)

@unsafe
def ctfe_bool(+b: Bool) -> CtfeVal:
  CVCtr{kc(String, b, u => "True", u => "False"), []}

@unsafe
def ctfe_env_get(+env: List<&2, Sigma<&2, &2, U32, _ => CtfeVal>>, +id: U32) -> CtfeVal:
  match env:
    case Nil{}: CVFail{}
    case Con{(bid, val), rest}:
      kc(CtfeVal, U32.is_eq(bid, id), u => val, u => ctfe_env_get(rest, id))

@unsafe
def ctfe_run_shift(+op: String, a: CtfeVal, mb: Maybe<&2, U32>) -> CtfeVal:
  match a mb:
    case CVU32{+x} Some{+n}:
      kc(CtfeVal, agy_str_eq(op, "u32_shln"),
        v => CVU32{U32.shln(x, U32.to_nat(n))},
        v => CVU32{U32.shrn(x, U32.to_nat(n))})
    case _ _: CVFail{}

law ctfe_bits_to_u32:
  for v: CtfeVal
  for +at: U32
  for +acc: U32
  Maybe<&2, U32>

@unsafe
def ctfe_bits_wcon(fields: List<&2, CtfeVal>, +at: U32, +acc: U32) -> Maybe<&2, U32>:
  match fields:
    case Con{CVCtr{+bn, Nil{}}, Con{+rest, Nil{}}}:
      kc(Maybe<&2, U32>, agy_str_eq(bn, "True"),
        z => ctfe_bits_to_u32(rest, U32.inc(at), U32.or(acc, U32.shln(1, U32.to_nat(at)))),
        z => kc(Maybe<&2, U32>, agy_str_eq(bn, "False"),
          q => ctfe_bits_to_u32(rest, U32.inc(at), acc),
          q => None{}))
    case _: None{}

@unsafe
def ctfe_bits_to_u32(v, at, acc):
  match v:
    case CVCtr{+cname, fields}:
      kc(Maybe<&2, U32>, agy_str_eq(cname, "WNil"),
        u => kc(Maybe<&2, U32>, U32.is_eq(at, 32), w => Some{acc}, w => None{}),
        u => kc(Maybe<&2, U32>, agy_str_eq(cname, "WCon") && U32.is_lt(at, 32),
          w => ctfe_bits_wcon(fields, at, acc),
          w => None{}))
    case _: None{}

@unsafe
def agy_abs_is_var(+t: KTerm, +id: U32) -> Bool:
  p98_tag_eq(t,"Var") && U32.is_eq(ix(t),id)

@unsafe
def agy_abs_find_var(lams: List<&2,KTerm>, +id: U32, +idx: U32) -> U32:
  match lams:
    case Nil{}: 999999
    case Con{+l,rest}:
      kc(U32,U32.is_eq(ix(l),id),u => idx,u => agy_abs_find_var(rest,id,U32.inc(idx)))

@unsafe
def agy_abs_in_inv(lams: List<&2,KTerm>, +st_idx: U32, +cur: U32, +id: U32) -> Bool:
  match lams:
    case Nil{}: False{}
    case Con{+l,rest}:
      kc(Bool,Bool.not(U32.is_eq(cur,st_idx)) && U32.is_eq(ix(l),id),
        u => True{},
        u => agy_abs_in_inv(rest,st_idx,U32.inc(cur),id))

@unsafe
def agy_abs_hole(+hid: U32) -> KTerm:
  kt("AgyHole","",hid,0,[])

@unsafe
def agy_abs_make_holes(+start: U32, +n: U32) -> List<&2,U32>:
  kc(List<&2,U32>,U32.is_eq(n,0),u => [],
    u => Con{start,agy_abs_make_holes(U32.inc(start),U32.sub(n,1))})

law agy_abs_fill_list:
  for xs: List<&2,KTerm>
  for +hid: U32
  for +val: KTerm
  List<&2,KTerm>

@unsafe
def w7_br_882(w7_c: Bool, +pat: KTerm, +hid: U32, +val: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      val
    case False{}:
      k_with_children(pat,agy_abs_fill_list(ks(pat),hid,val))

@unsafe
def agy_abs_fill(+pat: KTerm, +hid: U32, +val: KTerm) -> KTerm:
  w7_br_882(p98_tag_eq(pat,"AgyHole") && U32.is_eq(ix(pat),hid), pat, hid, val)

@unsafe
def agy_abs_fill_list(xs, hid, val):
  match xs:
    case Nil{}: []
    case Con{x,rest}: Con{agy_abs_fill(x,hid,val),agy_abs_fill_list(rest,hid,val)}

@unsafe
def agy_abs_walk_mat_join(+m: KTerm, +w_arm: AgyAbsWalk, +w_rest: AgyAbsWalk) -> AgyAbsWalk:
  match w_arm w_rest:
    case AgyAbsWalk{arm2,h1,ok1} AgyAbsWalk{rest2,h2,ok2}:
      AgyAbsWalk{k_with_children(m,[arm2,rest2]),h1 || h2,ok1 && ok2}

@unsafe
def agy_bf_is_var(+t: KTerm, +id: U32) -> Bool:
  p98_tag_eq(t,"Var") && U32.is_eq(ix(t),id)

@unsafe
def p205v_bool(+b: Bool) -> KTerm:
  match b:
    case True{}: kt("Ctr","True",0,1,[])
    case False{}: kt("Ctr","False",0,1,[])

@unsafe
def p205v_range_add(+a: W2Range, +b: W2Range) -> W2Range:
  match a b:
    case W2Range{la,ha,oka} W2Range{lb,hb,okb}:
      +s_hi = U32.add(ha,hb)
      +s_lo = U32.add(la,lb)
      kc(W2Range,oka && okb && U32.is_ge(s_hi,ha) && U32.is_ge(s_lo,la),
        u => W2Range{s_lo,s_hi,True{}},u => W2Range{0,0,False{}})

@unsafe
def p205v_range_mod(+rhs: Maybe<&2,U32>) -> W2Range:
  match rhs:
    case Some{k}: kc(W2Range,U32.is_gt(k,0),u => W2Range{0,U32.sub(k,1),True{}},u => W2Range{0,0,False{}})
    case None{}: W2Range{0,0,False{}}

@unsafe
def w2d_extract_wrap_let(+b: KTerm, +r: W2StepExtract) -> W2StepExtract:
  match r:
    case W2StepExtract{term,found}: W2StepExtract{kt("Let","",0,0,[b,term]),found}

@unsafe
def w2d_extract_wrap_lam(+lam: KTerm, +r: W2StepExtract) -> W2StepExtract:
  match r:
    case W2StepExtract{term,found}: W2StepExtract{k_with_children(lam,[term]),found}

@unsafe
def w2d_extract_wrap_mat(+mat: KTerm, +alt: KTerm, +r: W2StepExtract) -> W2StepExtract:
  match r:
    case W2StepExtract{term,found}: W2StepExtract{k_with_children(mat,[term,alt]),found}

@unsafe
def w2d_wrap_lets(bs: List<&2,KTerm>, +body: KTerm) -> KTerm:
  match bs:
    case Nil{}: body
    case Con{b,rest}: kt("Let","",0,0,[b,w2d_wrap_lets(rest,body)])

@unsafe
def w7_br_930(w7_c: Bool, +sm: KTerm, +ty: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      sm
    case False{}:
      kt("Ann","",0,0,[sm,ty])

@unsafe
def w2d_hoist_mat_pair(+m: KTerm, +h0: W2Hoist, +h1: W2Hoist) -> W2Hoist:
  match h0 h1:
    case W2Hoist{c0,t0,True{}} W2Hoist{c1,t1,True{}}:
      kc(W2Hoist,agy_str_eq(c0,c1) || String.is_empty(c1),
        u => W2Hoist{c0,k_with_children(m,[t0,t1]),True{}},
        u => kc(W2Hoist,String.is_empty(c0),v => W2Hoist{c1,k_with_children(m,[t0,t1]),True{}},v => W2Hoist{"",m,False{}}))
    case _ _: W2Hoist{"",m,False{}}

@unsafe
def w2d_hoist_fst_res(+orig: KTerm, +h: W2Hoist) -> KTerm:
  match h:
    case W2Hoist{cname,inner,True{}}:
      kc(KTerm,Bool.not(String.is_empty(cname)),
        u => kt("Ctr","Tuple",0,1,[kt("Ctr",cname,0,1,[]),inner]),
        u => orig)
    case _: orig

@unsafe
def w2d_pim_lam(+lam: KTerm, +r: FFresh) -> FFresh:
  match r:
    case FFresh{b,n1}: FFresh{k_with_children(lam,[b]),n1}

@unsafe
def w2d_pim_let(+bind: KTerm, +r: FFresh) -> FFresh:
  match r:
    case FFresh{b,n1}: FFresh{kt("Let","",0,0,[bind,b]),n1}

@unsafe
def w2d_pim_pair2(+m: KTerm, +t0: KTerm, +r1: FFresh) -> FFresh:
  match r1:
    case FFresh{t1,n2}: FFresh{k_with_children(m,[t0,t1]),n2}

@unsafe
def w2d_senv_del(+senv: List<&2,W2Bind>, +id: U32) -> List<&2,W2Bind>:
  match senv:
    case Nil{}: []
    case Con{W2Bind{bid,rhs},rest}:
      kc(List<&2,W2Bind>,U32.is_eq(bid,id),u => rest,u => Con{W2Bind{bid,rhs},w2d_senv_del(rest,id)})

@unsafe
def w2d_push_let_keep(+b: KTerm, +res: W2State) -> W2State:
  match res:
    case W2State{ctx2,added2,next2,t2,ch2}: W2State{ctx2,added2,next2,kt("Let","",0,0,[b,t2]),ch2}

@unsafe
def w2d_let_rest(+xs: List<&2,KTerm>) -> KTerm:
  match xs:
    case Con{last,Nil{}}: last
    case _: kt("Let","",0,0,xs)

@unsafe
def p86_read_eof(pair: File & Result<&1,&1,U32 & String,String>, text: String) -> IO(String):
  (file, result) = pair
  do IO<String>:
    Unit <- File.close(file)
    tail : String <- IO.pass(String, result)
    kc(IO(String), String.is_empty(tail), u => IO.pure(String, text),
      u => IO.die(String, 1, "input was not completely read"))

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:701
@unsafe
def nbc_match_list(ts: List<&2, KTerm>) -> Bool:
  match ts:
    case Nil{}: False{}
    case Con{+h, rest}: nt_choose(Bool, p98_tag_eq(h, "Mat"), u => True{}, u => nbc_match_list(List.append(&2, KTerm, ks(h), rest)))

@unsafe
def nbc_uses_list(ts: List<&2, KTerm>, +id: U32) -> U32:
  match ts:
    case Nil{}: 0
    case Con{+h, rest}: U32.add(nt_choose(U32, p98_tag_eq(h, "Var"), u => Bool.to_u32(U32.is_eq(ix(h), id)), u => nbc_uses_list(ks(h), id)), nbc_uses_list(rest, id))

# Only exclusive nullary matcher arms may discard a literal branch. Nonliteral
# actuals are evaluated into outer ordered lets before the match is inspected.
@unsafe
def p152c_strings(a: List<&2,String>, b: List<&2,String>) -> Bool:
  match a b:
    case Nil{} Nil{}: True{}
    case Con{x,xs} Con{y,ys}: agy_str_eq(x,y) && p152c_strings(xs,ys)
    case _ _: False{}

@unsafe
def ntr_target(+target: NC_Target) -> Bool:
  match target:
    case NC_Scheduler{}: False{}
    case NC_Destination{words, +shape, join, owner, params, +tail, signatures}: tail && p98_tag_eq(shape, "NTRMC")

@unsafe
def p111_show_ctor_id(+name: String, constructors: List<&2, N_Constructor>, +i: U32) -> U32:
  match constructors:
    case Nil{}: 4294967295
    case Con{N_Constructor{key, arity, hot}, +rest}:
      nt_choose(U32, agy_str_eq(name, key), u => i, u => p111_show_ctor_id(name, rest, U32.inc(i)))

@unsafe
def p111_show_offset(offsets: List<&2, U32>, +i: U32) -> U32:
  match offsets:
    case Nil{}: 4294967295
    case Con{+head, +rest}: nt_choose(U32, U32.is_eq(i, 0), u => head, u => p111_show_offset(rest, U32.sub(i, 1)))

@unsafe
def p111_show_resolved(+value: U32, +error: String) -> P111ShowWords:
  nt_choose(P111ShowWords, U32.is_eq(value, 4294967295), u => P111ShowWords{Nil{}, error}, u => P111ShowWords{[value], ""})

@unsafe
def p111_show_words_join(a: P111ShowWords, b: P111ShowWords) -> P111ShowWords:
  match a b:
    case P111ShowWords{first, +error_a} P111ShowWords{second, +error_b}:
      P111ShowWords{List.append(&2, U32, first, second), nt_choose(String, agy_str_eq(error_a, ""), u => error_b, u => error_a)}

@unsafe
def p111_special(+name: String) -> U32:
  nt_choose(U32, agy_str_eq(name, "False"), u => 1, u =>
  nt_choose(U32, agy_str_eq(name, "True"), u => 2, u =>
  nt_choose(U32, agy_str_eq(name, "Zero"), u => 3, u =>
  nt_choose(U32, agy_str_eq(name, "Succ"), u => 4, u =>
  nt_choose(U32, agy_str_eq(name, "Chr"), u => 5, u =>
  nt_choose(U32, agy_str_eq(name, "U32"), u => 6, u =>
  nt_choose(U32, agy_str_eq(name, "F32"), u => 7, u =>
  nt_choose(U32, agy_str_eq(name, "ALeaf"), u => 8, u =>
  nt_choose(U32, agy_str_eq(name, "ANode"), u => 9, u =>
    0)))))))))


# Phase111 module: selfhost/tools/performance/phase111/segment/lower-helpers.bend
# Structured counterparts of the mature generic bridge utilities.
@unsafe
def p111_first(+a: String, +b: String) -> String:
  nt_choose(String, agy_str_eq(a, ""), u => b, u => a)

@unsafe
def w5c3_leaf_from(+h: U32, res: List<&2,KDef>) -> KDef:
  match res:
    case Nil{}: missing()
    case Con{_, _}: KIndexLeaf{h, res}

@unsafe
def p111q_utf8_char(+code: U32, +acc: List<&2,P111QDatum>) -> List<&2,P111QDatum>:
  nt_choose(List<&2,P111QDatum>,U32.is_lt(code,128),u => Con{P111QByte{code},acc},u =>
    nt_choose(List<&2,P111QDatum>,U32.is_lt(code,2048),u =>
      Con{P111QByte{U32.add(128,U32.and(code,63))},Con{P111QByte{U32.add(192,U32.shrn(code,6n))},acc}},u =>
      nt_choose(List<&2,P111QDatum>,U32.is_lt(code,65536),u =>
        Con{P111QByte{U32.add(128,U32.and(code,63))},Con{P111QByte{U32.add(128,U32.and(U32.shrn(code,6n),63))},Con{P111QByte{U32.add(224,U32.shrn(code,12n))},acc}}},u =>
        Con{P111QByte{U32.add(128,U32.and(code,63))},Con{P111QByte{U32.add(128,U32.and(U32.shrn(code,6n),63))},Con{P111QByte{U32.add(128,U32.and(U32.shrn(code,12n),63))},Con{P111QByte{U32.add(240,U32.shrn(code,18n))},acc}}}})))

@unsafe
def p112_scalar_safe_value(value: N111Value) -> Bool:
  match value:
    case N111Local{+name}: Bool.not(agy_str_eq(name, "p112_s_a") || agy_str_eq(name, "p112_s_b") || agy_str_eq(name, "p112_s_test"))
    case _: True{}


@unsafe
def p112_scalar_arity(+id: U32) -> U32:
  nt_choose(U32, (U32.is_ge(id, 1) && U32.is_le(id, 12)) || U32.is_eq(id, 16) || U32.is_eq(id, 17), u => 2, u =>
  nt_choose(U32, (U32.is_ge(id, 13) && U32.is_le(id, 15)) || U32.is_eq(id, 20) || U32.is_eq(id, 21), u => 1, u => 0))


@unsafe
def p112_scalar_op(+id: U32) -> String:
  nt_choose(String, U32.is_eq(id, 1), u => "add", u =>
  nt_choose(String, U32.is_eq(id, 2), u => "sub", u =>
  nt_choose(String, U32.is_eq(id, 3), u => "and", u =>
  nt_choose(String, U32.is_eq(id, 4), u => "or", u =>
  nt_choose(String, U32.is_eq(id, 5), u => "xor", u =>
  nt_choose(String, U32.is_eq(id, 6), u => "mul", u =>
  nt_choose(String, U32.is_eq(id, 7), u => "eq", u =>
  nt_choose(String, U32.is_eq(id, 8), u => "ne", u =>
  nt_choose(String, U32.is_eq(id, 9), u => "ult", u =>
  nt_choose(String, U32.is_eq(id, 10), u => "ule", u =>
  nt_choose(String, U32.is_eq(id, 11), u => "ugt", u => "uge")))))))))))


@unsafe
def p112t_jump_args(args: List<&2,N111Arg>, +owner: String, +arity: U32) -> Bool:
  match args:
    case Con{N111Arg{N111Ptr{},N111Local{state}},
      Con{N111Arg{N111U32{},N111FuncId{name}},
      Con{N111Arg{N111Ptr{},N111Local{scratch}},
      Con{N111Arg{N111U32{},N111Const{count,hi}},Nil{}}}}}:
      agy_str_eq(state,"state") && agy_str_eq(name,owner) && agy_str_eq(scratch,"scratch") &&
        U32.is_eq(count,arity) && U32.is_eq(hi,0)
    case _: False{}


@unsafe
def p112t_runtime_call(+symbol: String) -> Bool:
  agy_str_eq(symbol,"p111_rt_keep") || agy_str_eq(symbol,"p111_rt_sink") ||
  agy_str_eq(symbol,"p111_rt_ctor") || agy_str_eq(symbol,"p111_rt_take") ||
  agy_str_eq(symbol,"p111_rt_closure") || agy_str_eq(symbol,"p111_rt_tag") ||
  agy_str_eq(symbol,"p111_rt_op") || agy_str_eq(symbol,"p111_rt_special_ctor") ||
  agy_str_eq(symbol,"p111_rt_special_test") || agy_str_eq(symbol,"p111_rt_special_take")


@unsafe
def p112t_transition(body: List<&2,N111Stmt>) -> Bool:
  match body:
    case Con{N111Call{dest,N111U64{},symbol,args},Con{N111Return{N111Local{word}},Nil{}}}:
      (agy_str_eq(symbol,"p111_rt_jump") || agy_str_eq(symbol,"p111_rt_return")) && agy_str_eq(dest,word)
    case _: False{}


@unsafe
def p112t_failure_args(args: List<&2,N111Arg>) -> Bool:
  match args:
    case Con{N111Arg{N111Ptr{},N111Local{state}},Con{N111Arg{N111U32{},N111Const{code,0}},Nil{}}}:
      agy_str_eq(state,"state") && U32.is_gt(code,0) && U32.is_le(code,8)
    case _: False{}


@unsafe
def p112t_failure_frame(stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Call{name,N111U64{},symbol,Con{N111Arg{N111Ptr{},N111Local{state}},Con{N111Arg{N111U32{},N111FuncId{target}},Con{N111Arg{N111Ptr{},N111Local{scratch}},Con{N111Arg{N111U32{},N111Const{count,0}},Nil{}}}}}}:
      agy_str_eq(symbol,"p111_rt_frame") && agy_str_eq(state,"state") && agy_str_eq(scratch,"scratch") && U32.is_le(count,255)
    case _: False{}


@unsafe
def p112t_buffer_args(args: List<&2,N111Arg>) -> Bool:
  match args:
    case Nil{}: True{}
    case Con{N111Arg{N111Ptr{},N111Local{name}},rest}: agy_str_eq(name,"scratch") && p112t_buffer_args(rest)
    case Con{N111Arg{N111Ptr{},value},rest}: False{}
    case Con{arg,rest}: p112t_buffer_args(rest)


@unsafe
def p112_special_safe(word: N111Value) -> Bool:
  match word:
    case N111Local{+name}:
      Bool.not(agy_str_eq(name, "p112_b_raw") || agy_str_eq(name, "p112_b_bits") || agy_str_eq(name, "p112_b_expected") || agy_str_eq(name, "p112_b_boxed"))
    case _: True{}

# Bits40..55 are aux, bits56..62 are the7-bit tag; bit63 is RFC.
# A packed True may have arbitrary location bits and either RFC bit.


@unsafe
def p112w_result_args(args: List<&2,N111Arg>) -> Bool:
  match args:
    case Con{N111Arg{N111Ptr{},N111Local{state}},Con{N111Arg{N111Ptr{},N111Local{scratch}},Con{N111Arg{N111U32{},N111Const{1,0}},Nil{}}}}:
      agy_str_eq(state,"state") && agy_str_eq(scratch,"scratch")
    case _: False{}


@unsafe
def p112w_target(body: List<&2,N111Stmt>) -> String:
  match body:
    case Con{N111Store{N111U64{},N111Local{scratch},offset,value},rest}:
      nt_choose(String,agy_str_eq(scratch,"scratch"),u => p112w_target(rest),u => "")
    case Con{N111Call{dest,N111U64{},symbol,Con{state,Con{N111Arg{N111U32{},N111FuncId{name}},rest}}},Con{N111Return{value},Nil{}}}:
      nt_choose(String,agy_str_eq(symbol,"p111_rt_jump"),u => name,u => "")
    case _: ""


@unsafe
def p112w_call_args(+count: U32, +index: U32, +acc: String) -> String:
  nt_choose(String,U32.is_eq(count,index),u => acc,u =>
    p112w_call_args(count,U32.inc(index),acc ++ ", l %p112_arg_" ++ U32.show(index)))


@unsafe
def p112s_marker(word: P112SWord) -> KTerm:
  match word:
    case P112SRaw{value}: kt("NWord",U32.show(value),0,0,[])
    case P112SPacked{name,payload}: kt("NStatic",name,payload,1,[])
    case P112SBox{name,offset}: kt("NStatic",name,offset,0,[])


def p112s_context_ctors_list(children: List<&2,KDef>) -> KDef:
  match children:
    case Con{facts,Con{original,Con{constructors,Con{nodes,Nil{}}}}}: constructors
    case _: missing()


def p112s_context_nodes_list(children: List<&2,KDef>) -> KDef:
  match children:
    case Con{facts,Con{original,Con{constructors,Con{nodes,Nil{}}}}}: nodes
    case _: missing()


@unsafe
def p112e_tail_scalar(+stmt: N111Stmt, tail: P112TailBody) -> P112TailBody:
  match tail:
    case P112TailBody{+valid,+loops,+body}:
      nt_choose(P112TailBody,valid,u => P112TailBody{True{},loops,Con{P112TailScalar{stmt},body}},
        u => P112TailBody{False{},0,[]})


@unsafe
def p112e_worker_scalar(+stmt: N111Stmt, tail: P112WorkerBody) -> P112WorkerBody:
  match tail:
    case P112WorkerBody{+valid,+calls,+body}:
      nt_choose(P112WorkerBody,valid,u => P112WorkerBody{True{},calls,Con{P112WorkerScalar{stmt},body}},
        u => P112WorkerBody{False{},0,[]})


law p112f_index_bucket:
  for bucket: List<&2,N111Segment>
  for +name: String
  Maybe<&2,N111Segment>

@unsafe
def w7c_p112f_bucket_eq(eq: Bool, +segment: N111Segment, rest: List<&2,N111Segment>, +name: String) -> Maybe<&2,N111Segment>:
  match eq:
    case True{}: Some{segment}
    case False{}: p112f_index_bucket(rest,name)

@unsafe
def p112f_index_bucket(bucket, name):
  match bucket:
    case Nil{}: None{}
    case Con{+segment,+rest}:
      match segment:
        case N111Segment{+key,+arity,+result,+incoming,+flags,+body}:
          w7c_p112f_bucket_eq(agy_str_eq(key,name),segment,rest,name)


@unsafe
def p112f_callargs(+count: U32, +index: U32, +prefix: String) -> List<&2,N111Arg>:
  nt_choose(List<&2,N111Arg>,U32.is_eq(count,index),u => [],u =>
    Con{N111Arg{N111U64{},N111Local{prefix ++ "arg_" ++ U32.show(index)}},p112f_callargs(count,U32.inc(index),prefix)})


@unsafe
def p112m_mask(+depth: U32) -> U32:
  nt_choose(U32,U32.is_eq(depth,32),u => 4294967295,u => U32.sub(U32.shln(1,U32.to_nat(depth)),1))


@unsafe
def p112r_buffer_sites(+name: String, +sites: U32, +index: U32) -> Bool:
  nt_choose(Bool,U32.is_eq(index,sites),u => False{},u =>
    agy_str_eq(name,"p112f_" ++ U32.show(index) ++ "_local_scratch") || p112r_buffer_sites(name,sites,U32.inc(index)))


@unsafe
def p112r_jump(body: List<&2,N111Stmt>, +owner: String, +arity: U32, +buffer: String) -> Bool:
  match body:
    case Con{N111Call{+dest,N111U64{},+symbol,Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111U32{},N111FuncId{+name}},Con{N111Arg{N111Ptr{},N111Local{+scratch}},Con{N111Arg{N111U32{},N111Const{+count,0}},Nil{}}}}}},Con{N111Return{N111Local{+word}},Nil{}}}:
      agy_str_eq(symbol,"p111_rt_jump") && agy_str_eq(dest,word) && agy_str_eq(state,"state") && agy_str_eq(name,owner) && agy_str_eq(scratch,buffer) && U32.is_eq(count,arity)
    case _: False{}


@unsafe
def p112r_exit_stores(+count: U32, +index: U32, +last: P112WorkerStmt) -> List<&2,P112WorkerStmt>:
  nt_choose(List<&2,P112WorkerStmt>,U32.is_eq(count,index),u => [last],u =>
    Con{P112WorkerScalar{N111Store{N111U64{},N111Local{"scratch"},U32.mul(index,8),N111Local{"p112f_region_exit_" ++ U32.show(index)}}},p112r_exit_stores(count,U32.inc(index),last)})

# All operands are copied before any canonical slot is overwritten. The exact
# suffix has only pure value stores followed by its transfer, so secondary
# terminal stores can be replaced by this transport without moving owner calls.


law w6_body_calls_self:
  for +owner: String
  for body: List<&2,P113DStmt>
  Bool

@unsafe
def p113e_nonstate_pointer(value: N111Value) -> Bool:
  match value:
    case N111Local{name}: Bool.not(agy_str_eq(name,"state"))
    case _: False{}


@unsafe
def p113pl_names(+base: String, +count: U32, +i: U32) -> List<&2,String>:
  nt_choose(List<&2,String>,U32.is_eq(i,count),u => [],u => Con{base ++ "_" ++ U32.show(i),p113pl_names(base,count,U32.inc(i))})


@unsafe
def p113pl_zeroes(+count: U32) -> List<&2,N111Value>:
  nt_choose(List<&2,N111Value>,U32.is_eq(count,0),u => [],u => Con{N111Const{0,0},p113pl_zeroes(U32.sub(count,1))})


@unsafe
def p113px_terms(plan: P112Liveness) -> List<&2,KTerm>:
  match plan:
    case P112LivenessEmpty{}: []
    case P112LivenessLeaf{term,uses}: [term]
    case P112LivenessLet{value,id,uses,rest}: Con{kt("Bind","",id,1,[value]),p113px_terms(rest)}


@unsafe
def p113df_kind(+mask: U32, +i: U32, +prior: N_WordKind) -> N_WordKind:
  nt_choose(N_WordKind,U32.is_ne(U32.and(mask,U32.shln(1,U32.to_nat(i))),0),
    u => N_W32{},u => prior)


def p113n_at(kinds: List<&2,N_WordKind>, +index: U32) -> N_WordKind:
  match kinds:
    case Nil{}: N_W64{}
    case Con{head,rest}: nt_choose(N_WordKind,U32.is_eq(index,0),u => head,u => p113n_at(rest,U32.sub(index,1)))


law p113i_bucket:
  for name: String
  for values: List<&2,P113DFunction>
  Maybe<&2,P113DFunction>

@unsafe
def w7c_p113i_bhead_eq(eq: Bool, +head: P113DFunction, +name: String, rest: List<&2,P113DFunction>) -> Maybe<&2,P113DFunction>:
  match eq:
    case True{}: Some{head}
    case False{}: p113i_bucket(name,rest)

@unsafe
def p113i_bucket_head(+name: String, +head: P113DFunction, rest: List<&2,P113DFunction>) -> Maybe<&2,P113DFunction>:
  match head:
    case P113DFunction{key,params,result,public,body}:
      w7c_p113i_bhead_eq(agy_str_eq(name,key),head,name,rest)

@unsafe
def p113i_bucket(name, values):
  match values:
    case Nil{}: None{}
    case Con{+head,rest}: p113i_bucket_head(name,head,rest)


@unsafe
def w6_body_calls_self(owner, body):
  match body:
    case Nil{}: False{}
    case Con{P113DCall{_,target,_},rest}: agy_str_eq(target,owner) || w6_body_calls_self(owner,rest)
    case Con{P113DIf{_,yes,no},rest}: w6_body_calls_self(owner,yes) || w6_body_calls_self(owner,no) || w6_body_calls_self(owner,rest)
    case Con{_,rest}: w6_body_calls_self(owner,rest)

@unsafe
def w9_is_sh_intrinsic(+name: String) -> Bool:
  agy_str_eq(name,"$direct.String.eq") ||
  agy_str_eq(name,"$p118borrow.read.String.eq") ||
  agy_str_eq(name,"$p128borrow.owned.String.eq") ||
  agy_str_eq(name,"$direct.agy_str_eq") ||
  agy_str_eq(name,"$p118borrow.read.agy_str_eq") ||
  agy_str_eq(name,"$p128borrow.owned.agy_str_eq") ||
  agy_str_eq(name,"$direct.p88_string_eq") ||
  agy_str_eq(name,"$p118borrow.read.p88_string_eq") ||
  agy_str_eq(name,"$p128borrow.owned.p88_string_eq") ||
  agy_str_eq(name,"$direct.p98_tag_eq") ||
  agy_str_eq(name,"$p118borrow.read.p98_tag_eq") ||
  agy_str_eq(name,"$p128borrow.owned.p98_tag_eq") ||
  agy_str_eq(name,"$direct.p98_tag_eq_read") ||
  agy_str_eq(name,"$p118borrow.read.p98_tag_eq_read") ||
  agy_str_eq(name,"$p128borrow.owned.p98_tag_eq_read")

law w4c_scalars_has_arr_pair:
  for xs: List<&2,N111Stmt>
  Bool

@unsafe
def w4c_stmt_has_arr_pair(stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Call{_,_,sym,_}: agy_str_eq(sym,"p113_rt_array_pair")
    case N111If{_,y,n}: w4c_scalars_has_arr_pair(y) || w4c_scalars_has_arr_pair(n)
    case _: False{}

@unsafe
def w4c_scalars_has_arr_pair(xs):
  match xs:
    case Nil{}: False{}
    case Con{h,rest}: w4c_stmt_has_arr_pair(h) || w4c_scalars_has_arr_pair(rest)

@unsafe
def p113j_is_scratch(value: N111Value) -> Bool:
  match value:
    case N111Local{name}: agy_str_eq(name,"scratch")
    case _: False{}


@unsafe
def p113j_scratch_literal(value: N111Value) -> U32:
  match value:
    case N111Const{+count,0}: nt_choose(U32,U32.is_le(count,256),u => U32.max(8,U32.mul(count,8)),u => 2048)
    case _: 2048


law w5_body_no_dcalls:
  for body: List<&2,P113DStmt>
  Bool

@unsafe
def w5_body_no_dcalls(body):
  match body:
    case Nil{}: True{}
    case Con{P113DIf{_,yes,no},rest}: w5_body_no_dcalls(yes) && w5_body_no_dcalls(no) && w5_body_no_dcalls(rest)
    case Con{P113DCall{_,_,_},_}: False{}
    case Con{P113DScalar{N111Call{_,_,sym,_}},rest}:
      Bool.not(agy_str_eq(sym,"p113_rt_array_pair")) && w5_body_no_dcalls(rest)
    case Con{P113DScalar{N111Alloca{_,_,_}},_}: False{}
    case Con{_,rest}: w5_body_no_dcalls(rest)

@unsafe
def w4c_skip_digits(s: String, +seen: Bool) -> Maybe<&2,String>:
  match s:
    case SNil{}: None{}
    case SCon{h,+rest}:
      +c = Char.to_u32(h)
      nt_choose(Maybe<&2,String>,U32.is_ge(c,48) && U32.is_le(c,57),
        u => w4c_skip_digits(rest,True{}),
        u => nt_choose(Maybe<&2,String>,seen && U32.is_eq(c,95),v => Some{rest},v => None{}))

@unsafe
def w4g_ic_res(+name: String) -> Bool:
  agy_str_eq(name,"state") || agy_str_eq(name,"scratch") ||
    agy_str_eq(name,"__x181_result_out") || agy_str_eq(name,"__x181_results") ||
    agy_str_eq(name,"__x181_tail")


@unsafe
def w4k_pure_bin(+op: String) -> Bool:
  Bool.not(agy_str_eq(op,"udiv") || agy_str_eq(op,"urem"))


@unsafe
def w4g_reserved(+name: String) -> Bool:
  agy_str_eq(name,"state") || agy_str_eq(name,"scratch") ||
    agy_str_eq(name,"__x181_result_out") || agy_str_eq(name,"__x181_results") ||
    agy_str_eq(name,"__x181_tail")


@unsafe
def w4g_clear_aliases(env: W4GCopyEnv) -> W4GCopyEnv:
  match env:
    case W4GCopyEnv{vers,_}: W4GCopyEnv{vers,missing()}


@unsafe
def w4k_f32_scale_up(+x: F32, +k: U32) -> F32:
  nt_choose(F32,U32.is_ge(k,4),u => w4k_f32_scale_up(F32.mul(x,16.0),U32.sub(k,4)),u =>
  nt_choose(F32,U32.is_eq(k,0),u => x,u => w4k_f32_scale_up(F32.mul(x,2.0),U32.sub(k,1))))


@unsafe
def w4k_f32_scale_down(+x: F32, +k: U32) -> F32:
  nt_choose(F32,U32.is_ge(k,4),u => w4k_f32_scale_down(F32.mul(x,0.0625),U32.sub(k,4)),u =>
  nt_choose(F32,U32.is_eq(k,0),u => x,u => w4k_f32_scale_down(F32.mul(x,0.5),U32.sub(k,1))))


@unsafe
def w4k_f32_bin_eval(+id: U32, ma: Maybe<&2,F32>, mb: Maybe<&2,F32>) -> Maybe<&2,U32>:
  match ma mb:
    case Some{+a} Some{+b}:
      nt_choose(Maybe<&2,U32>,U32.is_eq(id,26),u => Some{F32.bits(F32.add(a,b))},u =>
      nt_choose(Maybe<&2,U32>,U32.is_eq(id,27),u => Some{F32.bits(F32.sub(a,b))},u =>
      nt_choose(Maybe<&2,U32>,U32.is_eq(id,28),u => Some{F32.bits(F32.mul(a,b))},u =>
      nt_choose(Maybe<&2,U32>,U32.is_eq(id,29),u => Some{F32.bits(F32.div(a,b))},u => None{}))))
    case _ _: None{}


@unsafe
def p113bq_scalar(yes: List<&2,N111Stmt>, no: List<&2,N111Stmt>) -> P113BQDiamond:
  match yes no:
    case Con{N111Set{+a,N111U64{},N111Const{1,0}},Nil{}} Con{N111Set{b,N111U64{},N111Const{0,0}},Nil{}}:
      nt_choose(P113BQDiamond,agy_str_eq(a,b),u => P113BQYes{a,False{}},u => P113BQNo{})
    case Con{N111Set{+a,N111U64{},N111Const{0,0}},Nil{}} Con{N111Set{b,N111U64{},N111Const{1,0}},Nil{}}:
      nt_choose(P113BQDiamond,agy_str_eq(a,b),u => P113BQYes{a,True{}},u => P113BQNo{})
    case _ _: P113BQNo{}


@unsafe
def p114t_fusion_buffer(+name: String, +site: U32) -> Bool:
  nt_choose(Bool,U32.is_eq(site,8),u => False{},u =>
    nt_choose(Bool,agy_str_eq(name,"p112f_" ++ U32.show(site) ++ "_local_scratch"),
      v => True{},v => p114t_fusion_buffer(name,U32.inc(site))))


@unsafe
def p114t_negative_bytes(+count: U32) -> N111Value:
  nt_choose(N111Value,U32.is_eq(count,0),u => N111Const{0,0},
    u => N111Const{U32.sub(0,U32.mul(count,8)),4294967295})

# Preserve the runtime's ordered source-load/destination-store pairs. We do not
# replace this loop with memmove or reorder all loads ahead of all stores.


@unsafe
def p117h_bit(+origin: U32) -> U32:
  nt_choose(U32,U32.is_eq(origin,0),u => 0,u => U32.shln(1,U32.to_nat(U32.sub(origin,1))))


def p117h_abort(scan: P117HScan) -> P117HScan:
  match scan:
    case P117HScan{facts,slots,mask,used,again,left,next,sites}:
      P117HScan{missing(),missing(),0,used,again,0,next,sites}


@unsafe
def w5_arm_loc_pair2(+t: String, +src: String, s2: W5SetLoc) -> W5SetLoc:
  match s2:
    case W5SetLoc{dst,s}: nt_choose(W5SetLoc,agy_str_eq(t,s),u => W5SetLoc{dst,src},u => W5SetLocNone{})
    case W5SetLocNone{}: W5SetLocNone{}

@unsafe
def w4c_nth_val(vals: List<&2,N111Value>, +i: U32) -> Maybe<&2,N111Value>:
  match vals:
    case Nil{}: None{}
    case Con{v,rest}: nt_choose(Maybe<&2,N111Value>,U32.is_eq(i,0),u => Some{v},u => w4c_nth_val(rest,U32.sub(i,1)))

@unsafe
def w4c_nth_param_name(params: List<&2,NC_Binding>, +i: U32) -> String:
  match params:
    case Nil{}: ""
    case Con{NC_Binding{_,word,_},rest}: nt_choose(String,U32.is_eq(i,0),u => word,u => w4c_nth_param_name(rest,U32.sub(i,1)))

@unsafe
def p118t_import(+symbol: String) -> Bool:
  agy_str_eq(symbol,"p118_rt_extend") || agy_str_eq(symbol,"p118_rt_finish")


@unsafe
def w7_patch_prog_item(+item: P111QDatum, +set3: Bool, +or_flags: U32) -> P111QDatum:
  match item:
    case P111QLong{+lo,+hi}:
      nt_choose(P111QDatum,set3,u => P111QLong{U32.or(3,or_flags),0},u => P111QLong{U32.or(lo,or_flags),hi})
    case _: item

@unsafe
def p118z_transition(+symbol: String) -> Bool:
  agy_str_eq(symbol,"p111_rt_jump") || agy_str_eq(symbol,"p111_rt_return") || agy_str_eq(symbol,"p111_rt_apply")


# Exact closed runtime-name membership: the 18 nonempty p111v_signature
# names plus seven extensions. Complete String patterns preserve suffix and
# unknown-name rejection without allocating an unused signature list.
# Persistent independent controls: tests/phase147/runtime-classifier-cases.json.
# Exact closed-name Boolean recognizer. No prefix-only acceptance or hashing.

@unsafe
def p121f_children(xs: List<&2,KTerm>, +depth: U32) -> List<&2,KTerm>:
  match xs:
    case Nil{}: []
    case Con{head,rest}: Con{kt("P121Depth","",depth,0,[head]),p121f_children(rest,depth)}

# Finite syntax budget before recursive shape/scalar checks. Worklist depth is
# explicit and covers every child, including annotations. Exhaustion refuses.

@unsafe
def p121f_env(binder: KTerm, word: String) -> NC_Binding:
  NC_Binding{ix(binder),word,N_W32{}}


@unsafe
def p123a_scale(+name: String, +value: N111Value, +shift: U32) -> N111Stmt:
  nt_choose(N111Stmt,U32.is_le(shift,3),
    u => N111Bin{name,N111U64{},"mul",value,N111Const{nt_choose(U32,U32.is_eq(shift,0),u => 1,u => nt_choose(U32,U32.is_eq(shift,1),u => 2,u => nt_choose(U32,U32.is_eq(shift,2),u => 4,u => 8))),0}},
    u => N111Bin{name,N111U64{},"shl",value,N111Const{shift,0}})


@unsafe
def p125p_forward(body: List<&2,P113DStmt>) -> Bool:
  match body:
    case Con{P113DCall{Con{+dest,Nil{}},target,args},Con{P113DResult{Con{N111Local{returned},Nil{}}},Nil{}}}:
      agy_str_eq(dest,returned) && Bool.not(String.starts_with(dest,"p125_concat_"))
    case _: False{}

# V2 returns the owning List Term directly. Zero is exclusively refusal:
# exact admitted ADT results have nonzero PAK/CTR tags, with or without RFC.

@unsafe
def p125v_shape(+state: String, +buffer: String, +count: U32) -> Bool:
  agy_str_eq(state,"state") && Bool.not(agy_str_eq(buffer,"state")) && U32.is_ge(count,1) && U32.is_le(count,4)


@unsafe
def p126i_lookup(tables: List<&2,P126ITable>, +name: String) -> Maybe<&2,U32>:
  match tables:
    case Nil{}: None{}
    case Con{P126ITable{key,last},rest}:
      nt_choose(Maybe<&2,U32>,agy_str_eq(key,name),u => Some{last},u => p126i_lookup(rest,name))


@unsafe
def p126sc_has(names: List<&2,String>, +name: String) -> Bool:
  match names:
    case Nil{}: False{}
    case Con{head,rest}: nt_choose(Bool,agy_str_eq(head,name),u => True{},u => p126sc_has(rest,name))


@unsafe
def p126sc_internal(+name: String, +left: String, +right: String) -> Bool:
  agy_str_eq(name,left) || agy_str_eq(name,right)

# The whole residual block must be exactly Result([the call destination]).

@unsafe
def p126sc_tail(destinations: List<&2,String>, rest: List<&2,P113DStmt>) -> Bool:
  match destinations rest:
    case Con{name,Nil{}} Con{P113DResult{Con{N111Local{word},Nil{}}},Nil{}}: agy_str_eq(name,word)
    case _ _: False{}


@unsafe
def p126sc_lane_params(+count: U32, +index: U32) -> List<&2,NC_Binding>:
  nt_choose(List<&2,NC_Binding>,U32.is_eq(count,index),u => [],u =>
    Con{NC_Binding{index,"p126scc_arg_" ++ U32.show(index),N_W64{}},p126sc_lane_params(count,U32.inc(index))})


@unsafe
def p126sc_call_terms(calls: List<&2,String>) -> List<&2,KTerm>:
  match calls:
    case Nil{}: []
    case Con{name,rest}: Con{kt("Ref",name,0,0,[]),p126sc_call_terms(rest)}


@unsafe
def p128br_lookup(+name: String, helpers: List<&2,P128BRHelper>) -> Maybe<&2,P128BRHelper>:
  match helpers:
    case Nil{}: None{}
    case Con{+head,rest}:
      match head:
        case P128BRHelper{owner,params,roots,result,reader,wrapper,resultId}:
          nt_choose(Maybe<&2,P128BRHelper>,agy_str_eq(name,owner),u => Some{head},u => p128br_lookup(name,rest))


@unsafe
def p128br_patch(target: String, workers: P118BWorkers) -> P128BRPatches:
  match workers:
    case P118BWorkers{+functions,error}:
      P128BRPatches{nt_choose(List<&2,P128BRPatch>,List.is_empty(&2,P113DFunction,functions),
        u => [],u => [P128BRPatch{target,functions}]),error}


@unsafe
def p128br_replacement(+name: String, patches: List<&2,P128BRPatch>) -> Maybe<&2,List<&2,P113DFunction>>:
  match patches:
    case Nil{}: None{}
    case Con{P128BRPatch{target,functions},rest}:
      nt_choose(Maybe<&2,List<&2,P113DFunction>>,agy_str_eq(name,target),u => Some{functions},u => p128br_replacement(name,rest))


@unsafe
def p131p_parameter(+id: U32, params: List<&2,KTerm>) -> Bool:
  match params:
    case Nil{}: False{}
    case Con{p,rest}: U32.is_eq(ix(p),id) || p131p_parameter(id,rest)


def p134v_value(a: N111Value, b: N111Value) -> Bool:
  match a b:
    case N111Local{x} N111Local{y}: p88_string_eq(x,y)
    case N111Const{xl,xh} N111Const{yl,yh}: U32.is_eq(xl,yl) && U32.is_eq(xh,yh)
    case N111Symbol{x} N111Symbol{y}: p88_string_eq(x,y)
    case N111FuncId{x} N111FuncId{y}: p88_string_eq(x,y)
    case N111CtorId{x} N111CtorId{y}: p88_string_eq(x,y)
    case _ _: False{}


@unsafe
def p144o_term(term: KTerm) -> P144OFacts:
  match term:
    case KTerm{tag,name,id,version,kids,names,begin,end}:
      nt_choose(P144OFacts,p88_string_eq(tag,"P144Ownership") && p88_string_eq(name,"") &&
        U32.is_eq(id,0) && U32.is_eq(version,1) && List.is_empty(&2,KTerm,kids) &&
        U32.is_eq(begin,0) && U32.is_eq(end,0),
        u => P144OFacts{names,True{}},u => P144OFacts{[],False{}})
    case _: P144OFacts{[],False{}}


@unsafe
def w6_local_find(locals: List<&2,W6Local>, +name: String) -> U32:
  match locals:
    case Nil{}: 4294967295
    case Con{W6Local{+orig,+cid},rest}:
      nt_choose(U32,agy_str_eq(orig,name),u => cid,u => w6_local_find(rest,name))

@unsafe
def w6_use_local_id(+cid: U32, +name: String) -> String:
  nt_choose(String,U32.is_eq(cid,4294967295),u => "v:?" ++ name,u => "v:L" ++ U32.show(cid))

@unsafe
def w6_def_local_id(+locals: List<&2,W6Local>, +next: U32, +chunks: List<&2,String>, +fuel: U32, +name: String, +cid: U32) -> W6CState:
  nt_choose(W6CState,U32.is_eq(cid,4294967295),
    u => W6CState{Con{W6Local{name,next},locals},U32.inc(next),Con{"L" ++ U32.show(next),chunks},fuel},
    u => W6CState{locals,next,Con{"L" ++ U32.show(cid),chunks},fuel})

@unsafe
def p169o_certified(+mode: U32, certificate: P113ACertificate) -> U32:
  nt_choose(U32,U32.is_eq(mode,1),u => 2,u => mode)


# Optional same-request cold metadata restoration after the existing full
# verifier and array/transport namespace gates. No emitted body or ID changes.
@unsafe
def p185cc_class(+count: U32) -> U32:
  nt_choose(U32,U32.is_eq(count,1),u => 0,u => nt_choose(U32,U32.is_eq(count,2),v => 1,v => 2))

# p111_program is the immutable descriptor passed by the emitted main to
# p111_rt_main. Its fixed offsets are checked independently of the state
# layout. Capability 8 authorizes unsealed cold publication; bit 1 requires
# the selected sequential host ABI (LANE_STEP=1).
@unsafe
def p185cb_items(tables: List<&2,P111QData>, +name: String) -> List<&2,P111QDatum>:
  match tables:
    case Nil{}: []
    case Con{P111QData{+key,alignment,exported,items},rest}:
      nt_choose(List<&2,P111QDatum>,agy_str_eq(key,name),u => items,u => p185cb_items(rest,name))

@unsafe
def p185cb_unique(tables: List<&2,P111QData>, +name: String, +found: Bool) -> Bool:
  match tables:
    case Nil{}: found
    case Con{P111QData{key,alignment,exported,items},+rest}:
      nt_choose(Bool,agy_str_eq(key,name),u => nt_choose(Bool,found,v => False{},v => p185cb_unique(rest,name,True{})),
        u => p185cb_unique(rest,name,found))

@unsafe
def p185cb_at(items: List<&2,P111QDatum>, +index: U32) -> P111QDatum:
  match items:
    case Nil{}: P111QZeros{0}
    case Con{head,rest}: nt_choose(P111QDatum,U32.is_eq(index,0),u => head,u => p185cb_at(rest,U32.sub(index,1)))

@unsafe
def p185cb_ref(item: P111QDatum, +name: String) -> Bool:
  match item:
    case P111QReloc{symbol,0}: agy_str_eq(symbol,name)
    case _: False{}

@unsafe
def w11_val_const32(v: N111Value) -> Maybe<&2,U32>:
  match v:
    case N111Const{lo,hi}: nt_choose(Maybe<&2,U32>,U32.is_eq(hi,0),u => Some{lo},u => None{})
    case _: None{}

@unsafe
def w11_p186ch_take_a4(+stmt: N111Stmt, +dest: String, +word: N111Value, +buffer: String, m4: Maybe<&2,U32>) -> P114TExpansion:
  match m4:
    case Some{n}:
      nt_choose(P114TExpansion,U32.is_eq(n,1),
        u => P114TExpansion{[N111Store{N111U64{},N111Local{buffer},0,word},N111Set{dest,N111U64{},N111Const{1,0}}],True{}},
        u => P114TExpansion{[stmt],False{}})
    case _: P114TExpansion{[stmt],False{}}

@unsafe
def w11_p186ch_ctor_a3(+stmt: N111Stmt, +dest: String, +kind: U32, +buffer: String, m3: Maybe<&2,U32>) -> P114TExpansion:
  match m3:
    case Some{+n}:
      nt_choose(P114TExpansion,U32.is_eq(kind,5) && U32.is_eq(n,1),
        w => P114TExpansion{[N111Load{dest,N111U64{},N111Local{buffer},0}],True{}},
        w => nt_choose(P114TExpansion,U32.is_eq(n,0) && U32.is_ge(kind,1) && U32.is_le(kind,3),
          z => P114TExpansion{[N111Set{dest,N111U64{},N111Const{Bool.to_u32(U32.is_eq(kind,2)),0}}],True{}},
          z => P114TExpansion{[stmt],False{}}))
    case _: P114TExpansion{[stmt],False{}}

@unsafe
def p186sf_push(+frame: List<&2,N111Stmt>, +name: String, +count: U32, scanned: P114GBody) -> P114GBody:
  match scanned:
    case P114GBody{valid,frames,body}:
      nt_choose(P114GBody,valid,
        u => P114GBody{True{},Con{P114GFrame{name,count},frames},Con{P114RPushFrame{frame},body}},
        u => P114GBody{False{},[],[]})

@unsafe
def p186sf_retried(previous: P114GBody, proposed: P114GBody) -> P114GBody:
  match proposed:
    case P114GBody{+valid,frames,body}:
      nt_choose(P114GBody,valid,u => P114GBody{valid,frames,body},u => previous)

def x188_gpr_text(index: U32, +width: U32) -> String:
  match index:
    case 0: nt_choose(String,U32.is_eq(width,64),u => "%rax",u => nt_choose(String,U32.is_eq(width,32),v => "%eax",v => "%al"))
    case 1: nt_choose(String,U32.is_eq(width,64),u => "%rcx",u => nt_choose(String,U32.is_eq(width,32),v => "%ecx",v => "%cl"))
    case 2: nt_choose(String,U32.is_eq(width,64),u => "%rdx",u => nt_choose(String,U32.is_eq(width,32),v => "%edx",v => "%dl"))
    case 3: nt_choose(String,U32.is_eq(width,64),u => "%rbx",u => nt_choose(String,U32.is_eq(width,32),v => "%ebx",v => "%bl"))
    case 4: nt_choose(String,U32.is_eq(width,64),u => "%rsp",u => nt_choose(String,U32.is_eq(width,32),v => "%esp",v => "%spl"))
    case 5: nt_choose(String,U32.is_eq(width,64),u => "%rbp",u => nt_choose(String,U32.is_eq(width,32),v => "%ebp",v => "%bpl"))
    case 6: nt_choose(String,U32.is_eq(width,64),u => "%rsi",u => nt_choose(String,U32.is_eq(width,32),v => "%esi",v => "%sil"))
    case 7: nt_choose(String,U32.is_eq(width,64),u => "%rdi",u => nt_choose(String,U32.is_eq(width,32),v => "%edi",v => "%dil"))
    case n: "%r" ++ U32.show(n) ++ nt_choose(String,U32.is_eq(width,64),u => "",u => nt_choose(String,U32.is_eq(width,32),v => "d",v => "b"))

def x188_signed32(+value: U32) -> String:
  nt_choose(String,U32.is_gt(value,2147483647),u => "-" ++ U32.show(U32.sub(0,value)),u => U32.show(value))

def x181_frame_alignment(+alignment: U32) -> U32:
  nt_choose(U32,U32.is_eq(alignment,4),u => 4,
    u => nt_choose(U32,U32.is_eq(alignment,8),v => 8,v => 16))

@unsafe
def x181_frame_outgoing(count: U32, +frame: X181Frame) -> X181Frame:
  match frame:
    case X181Frame{slots,bytes,+calls,params,symbol}:
      +needed = U32.mul(count,16)
      nt_choose(X181Frame,U32.is_gt(needed,calls),
        u => X181Frame{slots,bytes,needed,params,symbol},u => frame)

@unsafe
def w4_val_state(v: N111Value) -> Bool:
  match v:
    case N111Local{n}: agy_str_eq(n,"state")
    case _: False{}

def x200r_sqrt_admitted(+id: U32, count: U32, buffer: String) -> Bool:
  U32.is_eq(id,36) && U32.is_eq(count,1) && Bool.not(p88_string_eq(buffer,"state"))

@unsafe
def x195s_pick(enabled: Bool, stmt: N111Stmt) -> Maybe<&2,X195Sqrt>:
  match stmt:
    case N111Call{name,N111U64{},symbol,[
      N111Arg{N111Ptr{},N111Local{state}},N111Arg{N111U32{},N111Const{36,0}},
      N111Arg{N111Ptr{},N111Local{+buffer}},N111Arg{N111U32{},N111Const{1,0}}]}:
      nt_choose(Maybe<&2,X195Sqrt>,enabled && agy_str_eq(symbol,"p111_rt_op") &&
        agy_str_eq(state,"state") && Bool.not(agy_str_eq(buffer,"state")),
        u => Some{X195Sqrt{name,buffer}},u => None{})
    case _: None{}

def agy_rt_ctor_arity(+symbol: String) -> U32:
  nt_choose(U32,p88_string_eq(symbol,"p125_rt_ctor1"),u => 1,u =>
  nt_choose(U32,p88_string_eq(symbol,"p125_rt_ctor2"),u => 2,u =>
  nt_choose(U32,p88_string_eq(symbol,"p125_rt_ctor3"),u => 3,u =>
  nt_choose(U32,p88_string_eq(symbol,"p125_rt_ctor4"),u => 4,u => 0))))

def agy_rt_take_arity(+symbol: String) -> U32:
  nt_choose(U32,p88_string_eq(symbol,"p125_rt_take1"),u => 1,u =>
  nt_choose(U32,p88_string_eq(symbol,"p125_rt_take2"),u => 2,u =>
  nt_choose(U32,p88_string_eq(symbol,"p125_rt_take3"),u => 3,u =>
  nt_choose(U32,p88_string_eq(symbol,"p125_rt_take4"),u => 4,u => 0))))

def agy_cls_words(+cls: U32) -> U32:
  nt_choose(U32,U32.is_eq(cls,0),u => 1,u => nt_choose(U32,U32.is_eq(cls,1),v => 2,v => 4))

def agy_reuse_enabled() -> Bool: True{}
def agy_sink_skip_enabled() -> Bool: False{}

def agy_reuse_val_uses(+target: String, val: N111Value) -> Bool:
  match val:
    case N111Local{name}: p88_string_eq(name,target)
    case _: False{}

@unsafe
def agy_reuse_pure_nstmt(stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Call{n,t,sym,args}: False{}
    case N111If{c,yes,no}: False{}
    case N111Return{v}: False{}
    case _: True{}

def agy_reuse_ctor_compat(+c1: String, +c2: String) -> Bool:
  String.is_empty(c1) || String.is_empty(c2) || p88_string_eq(c1,c2)

def agy_reuse_ctor_pick(+c1: String, +c2: String) -> String:
  nt_choose(String,String.is_empty(c1),u => c2,u => c1)

def agy_rt_take_reuse_arity(+symbol: String) -> U32:
  nt_choose(U32,p88_string_eq(symbol,"agy_rt_take_reuse1"),u => 1,u =>
  nt_choose(U32,p88_string_eq(symbol,"agy_rt_take_reuse2"),u => 2,u =>
  nt_choose(U32,p88_string_eq(symbol,"agy_rt_take_reuse3"),u => 3,u =>
  nt_choose(U32,p88_string_eq(symbol,"agy_rt_take_reuse4"),u => 4,u => 0))))

def agy_rt_ctor_reuse_arity(+symbol: String) -> U32:
  nt_choose(U32,p88_string_eq(symbol,"agy_rt_ctor_reuse1"),u => 1,u =>
  nt_choose(U32,p88_string_eq(symbol,"agy_rt_ctor_reuse2"),u => 2,u =>
  nt_choose(U32,p88_string_eq(symbol,"agy_rt_ctor_reuse3"),u => 3,u =>
  nt_choose(U32,p88_string_eq(symbol,"agy_rt_ctor_reuse4"),u => 4,u => 0))))

@unsafe
def x186_call_capacity(plan: X186CallPlan, +bytes: U32, +calls: U32) -> X186CallPlan:
  match plan:
    case X186CallPlan{kind,+count}:
      nt_choose(X186CallPlan,U32.is_ge(bytes,40) && U32.is_le(calls,2147483000) &&
          U32.is_le(bytes,U32.sub(2147483583,calls)) && U32.is_ge(calls,U32.mul(count,16)),
        u => X186CallPlan{kind,count},u => X186CallPlan{0,count})

@unsafe
def x181_condition(+op: String) -> String:
  nt_choose(String,agy_str_eq(op,"eq"),u => "e",u =>
  nt_choose(String,agy_str_eq(op,"ne"),u => "ne",u =>
  nt_choose(String,agy_str_eq(op,"ult"),u => "b",u =>
  nt_choose(String,agy_str_eq(op,"ule"),u => "be",u =>
  nt_choose(String,agy_str_eq(op,"ugt"),u => "a",u =>
  nt_choose(String,agy_str_eq(op,"uge"),u => "ae",u =>
  nt_choose(String,agy_str_eq(op,"slt"),u => "l",u =>
  nt_choose(String,agy_str_eq(op,"sle"),u => "le",u =>
  nt_choose(String,agy_str_eq(op,"sgt"),u => "g",u =>
  nt_choose(String,agy_str_eq(op,"sge"),u => "ge",u => ""))))))))))

@unsafe
def x181_shift(+op: String) -> Bool:
  agy_str_eq(op,"shl") || agy_str_eq(op,"shr") || agy_str_eq(op,"sar")

@unsafe
def w4_pow2_log(+d: U32, +shift: U32) -> U32:
  nt_choose(U32,U32.is_le(d,1),u => shift,u => w4_pow2_log(U32.shrn(d,1n),U32.inc(shift)))

law w4_bf_no_buf_load_scalars:
  for +buf: String
  for body: List<&2,N111Stmt>
  Bool

@unsafe
def w4_bf_no_buf_load_scalar(+buf: String, stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Load{d,t,N111Local{b},off}: Bool.not(agy_str_eq(b,buf))
    case N111If{c,yes,no}: w4_bf_no_buf_load_scalars(buf,yes) && w4_bf_no_buf_load_scalars(buf,no)
    case _: True{}

@unsafe
def w4_bf_no_buf_load_scalars(buf,body):
  match body:
    case Nil{}: True{}
    case Con{h,rest}: w4_bf_no_buf_load_scalar(buf,h) && w4_bf_no_buf_load_scalars(buf,rest)

@unsafe
def x181_register_reserved(+name: String) -> Bool:
  agy_str_eq(name,"state") || agy_str_eq(name,"scratch") || String.starts_with(name,"__x181")

def x190_register_score(+reads: U32, loopState: Bool, policy: U32) -> U32:
  +weight = nt_choose(U32,U32.is_eq(policy,2) && loopState,u => 32,u => 8)
  nt_choose(U32,U32.is_gt(reads,U32.div(4294967295,weight)),
    u => 4294967295,u => U32.mul(reads,weight))

@unsafe
def x185_t_pick(ends: List<&2,U32>, +first: U32, +index: U32) -> U32:
  match ends:
    case Nil{}: 5
    case Con{last,rest}: nt_choose(U32,U32.is_lt(last,first),
      u => index,u => x185_t_pick(rest,first,U32.inc(index)))

@unsafe
def x185_t_end(ends: List<&2,U32>, +index: U32, +last: U32) -> List<&2,U32>:
  match ends:
    case Nil{}: []
    case Con{head,+rest}: nt_choose(List<&2,U32>,U32.is_eq(index,0),
      u => Con{last,rest},u => Con{head,x185_t_end(rest,U32.sub(index,1),last)})

def x194_cr_op(+op: String) -> Bool:
  p88_string_eq(op,"add") || p88_string_eq(op,"mul") || p88_string_eq(op,"and") ||
    p88_string_eq(op,"or") || p88_string_eq(op,"xor")

@unsafe
def x185_sf_source(value: N111Value, name: String) -> Bool:
  match value:
    case N111Local{source}: agy_str_eq(source,name)
    case _: False{}

# A stored local denotes its value at the store, not at the later load. Killing
# every dependent fact on a definition preserves that snapshot without adding
# hidden locals, even for repeated/mutable definitions and load destinations.
@unsafe
def x198w_op(stmt: N111Stmt) -> X198WOp:
  match stmt:
    case N111Call{name,N111U64{},symbol,
      Con{N111Arg{N111Ptr{},N111Local{state}},Con{N111Arg{N111U32{},N111Const{+id,0}},
      Con{N111Arg{N111Ptr{},N111Local{+buf}},Con{N111Arg{N111U32{},N111Const{+n,0}},Nil{}}}}}}:
      nt_choose(X198WOp,agy_str_eq(symbol,"p111_rt_op") && agy_str_eq(state,"state") && Bool.not(agy_str_eq(buf,"state")) &&
        ((U32.is_eq(n,1) && (U32.is_eq(id,24) || U32.is_eq(id,25))) ||
         (U32.is_eq(n,2) && (U32.is_eq(id,63) || U32.is_eq(id,67)))),
        u => X198WOp{name,buf,id},u => X198WNone{})
    case _: X198WNone{}

def x186_expression_enabled() -> Bool: True{}
def x186_e_empty() -> X186ExprState:
  X186ExprState{[],[],0,0,missing(),X186FTNil{},X186ATNil{}}

@unsafe
def w4_cse_comm(+op: String) -> Bool:
  match op:
    case SCon{h,t}:
      +c = Char.to_u32(h)
      nt_choose(Bool,U32.is_eq(c,97),u => agy_str_eq(t,"dd") || agy_str_eq(t,"nd"),u =>
      nt_choose(Bool,U32.is_eq(c,109),u => agy_str_eq(t,"ul"),u =>
      nt_choose(Bool,U32.is_eq(c,111),u => agy_str_eq(t,"r"),u =>
      nt_choose(Bool,U32.is_eq(c,120),u => agy_str_eq(t,"or"),u => False{}))))
    case SNil{}: False{}

@unsafe
def w5b_expr_hash_mix(comm: Bool, +ho: U32, +hl: U32, +hr: U32) -> U32:
  match comm:
    case True{}: U32.xor(U32.mul(ho,16777619),U32.xor(U32.add(hl,hr),U32.mul(U32.xor(hl,hr),33554467)))
    case False{}: U32.mul(U32.xor(U32.mul(U32.xor(ho,hl),16777619),hr),16777619)

@unsafe
def w5b_ft_find_leaf(eq: Bool, items: List<&2,X186Expr>) -> List<&2,X186Expr>:
  match eq:
    case True{}: items
    case False{}: []

@unsafe
def w5b_ft_join_br(bit: U32, +trie: X186FactTrie, +item: X186Expr, +h: U32, +stored: U32, +mask: U32) -> X186FactTrie:
  match bit:
    case 0: X186FTNode{stored,mask,X186FTLeaf{h,[item]},trie}
    case _: X186FTNode{stored,mask,trie,X186FTLeaf{h,[item]}}

@unsafe
def w5b_at_find_leaf(eq: Bool, items: List<&2,X186Alias>) -> List<&2,X186Alias>:
  match eq:
    case True{}: items
    case False{}: []

@unsafe
def w5b_at_join_br(bit: U32, +trie: X186AliasTrie, +item: X186Alias, +h: U32, +stored: U32, +mask: U32) -> X186AliasTrie:
  match bit:
    case 0: X186ATNode{stored,mask,X186ATLeaf{h,[item]},trie}
    case _: X186ATNode{stored,mask,trie,X186ATLeaf{h,[item]}}

@unsafe
def x186_e_equal(left: N111Value, right: N111Value) -> Bool:
  match left right:
    case N111Local{a} N111Local{b}: agy_str_eq(a,b)
    case N111Const{al,ah} N111Const{bl,bh}: U32.is_eq(al,bl) && U32.is_eq(ah,bh)
    case N111Symbol{a} N111Symbol{b}: agy_str_eq(a,b)
    case N111FuncId{a} N111FuncId{b}: agy_str_eq(a,b)
    case N111CtorId{a} N111CtorId{b}: agy_str_eq(a,b)
    case _ _: False{}

law x186_e_alias:
  for aliases: List<&2,X186Alias>
  for +name: String
  N111Value

@unsafe
def w5b_e_alias_if(eq: Bool, value: N111Value, rest: List<&2,X186Alias>, +name: String) -> N111Value:
  match eq:
    case True{}: value
    case False{}: x186_e_alias(rest,name)

@unsafe
def x186_e_alias(aliases, name):
  match aliases:
    case Nil{}: N111Local{name}
    case Con{X186Alias{other,value},rest}: w5b_e_alias_if(String.eq(name,other),value,rest,name)

@unsafe
def w5b_ft_node(stored: U32, split: U32, l: X186FactTrie, r: X186FactTrie) -> X186FactTrie:
  match l:
    case X186FTNil{}: r
    case _:
      match r:
        case X186FTNil{}: l
        case _: X186FTNode{stored,split,l,r}

@unsafe
def w5b_ft_leaf_wrap(stored: U32, ni: List<&2,X186Expr>) -> X186FactTrie:
  match ni:
    case Nil{}: X186FTNil{}
    case _: X186FTLeaf{stored,ni}

@unsafe
def w5b_at_node(stored: U32, split: U32, l: X186AliasTrie, r: X186AliasTrie) -> X186AliasTrie:
  match l:
    case X186ATNil{}: r
    case _:
      match r:
        case X186ATNil{}: l
        case _: X186ATNode{stored,split,l,r}

@unsafe
def w5b_at_leaf_wrap(stored: U32, ni: List<&2,X186Alias>) -> X186AliasTrie:
  match ni:
    case Nil{}: X186ATNil{}
    case _: X186ATLeaf{stored,ni}

@unsafe
def w4c_dia_is_sel(arm: W4CSelArm) -> Bool:
  match arm:
    case W4CSelArm{_,_,_}: True{}
    case W4CSelArmNone{}: False{}

@unsafe
def w5_sel_is(s: W5Sel) -> Bool:
  match s:
    case W5Sel{_,_,_,_,_}: True{}
    case W5SelNone{}: False{}

@unsafe
def w4c_dia_nonlast_name(stmt: N111Stmt) -> String:
  match stmt:
    case N111Set{n,_,_}: n
    case N111Bin{n,_,_,_,_}: n
    case _: ""

@unsafe
def w4c_dia_rename_scalar(stmt: N111Stmt, +newDst: String) -> N111Stmt:
  match stmt:
    case N111Set{_,t,v}: N111Set{newDst,t,v}
    case N111Bin{_,t,op,l,r}: N111Bin{newDst,t,op,l,r}
    case _: stmt

@unsafe
def w5_as_snap_sc(sc: N111Stmt) -> W5SnapSet:
  match sc:
    case N111Set{d,t,v}: W5Snap{d,t,v}
    case _: W5SnapNone{}

@unsafe
def w5_snap_local_eq(v: N111Value, +target: String) -> Bool:
  match v:
    case N111Local{s}: agy_str_eq(s,target)
    case _: False{}

@unsafe
def w4c_dia_out(res: W4CDiaRes) -> List<&2,P113DStmt>:
  match res:
    case W4CDiaRes{out,_,_}: out

# ---- W5B-R1 Pass 3: Unreachable Nat-Fail Elimination + Zero-Temp Nat-Match cmov Chain ----
@unsafe
def w5_is_cmp0_local(op: String, wantOp: String, l: N111Value, r: N111Value) -> String:
  match l:
    case N111Local{x}:
      match r:
        case N111Const{0,0}: nt_choose(String,agy_str_eq(op,wantOp),u => x,u => "")
        case _: ""
    case _: ""

@unsafe
def w5_is_sub1_local(op: String, l: N111Value, r: N111Value) -> String:
  match l:
    case N111Local{x}:
      match r:
        case N111Const{1,0}: nt_choose(String,agy_str_eq(op,"sub"),u => x,u => "")
        case _: ""
    case _: ""

@unsafe
def w5_val_eq_name(v: N111Value, +target: String) -> Bool:
  match v:
    case N111Local{n}: agy_str_eq(n,target)
    case _: False{}

@unsafe
def w5_nc_emit_arms(arms: List<&2,W5NatArm>, +origX: String, +cName: String, +cTyp: N111Type,
    +dst: String, +dstTyp: N111Type, +tail: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  match arms:
    case Nil{}: tail
    case Con{W5NatArm{k,val},rest}:
      +cmpSt : P113DStmt = P113DScalar{N111Bin{cName,cTyp,"eq",N111Local{origX},N111Const{k,0}}}
      +selSt : P113DStmt = P113DIf{N111Local{cName},
        [P113DScalar{N111Set{dst,dstTyp,val}}],
        [P113DScalar{N111Set{dst,dstTyp,N111Local{dst}}}]}
      Con{cmpSt,Con{selSt,w5_nc_emit_arms(rest,origX,cName,cTyp,dst,dstTyp,tail)}}

@unsafe
def w4c_su_subst(v: N111Value, +old: String, +fresh: String) -> N111Value:
  match v:
    case N111Local{+n}: nt_choose(N111Value,agy_str_eq(n,old),u => N111Local{fresh},u => N111Local{n})
    case _: v

@unsafe
def w4c_su_is_const1(v: N111Value) -> Bool:
  match v:
    case N111Const{1,0}: True{}
    case _: False{}

@unsafe
def w4c_su_is_local(v: N111Value, +target: String) -> Bool:
  match v:
    case N111Local{n}: agy_str_eq(n,target)
    case _: False{}

def x190_local_values_enabled() -> Bool: True{}
def x190_v_empty() -> X190Values: X190Values{[],missing()}

def x190_v_mask(value: N111Value) -> Bool:
  match value:
    case N111Const{lo,hi}: U32.is_eq(lo,4294967295) && U32.is_eq(hi,0)
    case _: False{}

# For any word, x & 0xffffffff equals its zero-extended U32 copy. If x is
# already canonical the copy is full-width and requires no extra truncation.
@unsafe
def w5b_const_cmp(+op: String, +al: U32, +ah: U32, +bl: U32, +bh: U32) -> Maybe<&2,U32>:
  nt_choose(Maybe<&2,U32>,agy_str_eq(op,"eq"),
    u => Some{nt_choose(U32,U32.is_eq(al,bl) && U32.is_eq(ah,bh),v => 1,v => 0)},
    u => nt_choose(Maybe<&2,U32>,agy_str_eq(op,"ne"),
      v => Some{nt_choose(U32,U32.is_eq(al,bl) && U32.is_eq(ah,bh),w => 0,w => 1)},
      v => nt_choose(Maybe<&2,U32>,agy_str_eq(op,"ult"),
        w => Some{nt_choose(U32,U32.is_lt(ah,bh) || (U32.is_eq(ah,bh) && U32.is_lt(al,bl)),z => 1,z => 0)},
        w => nt_choose(Maybe<&2,U32>,agy_str_eq(op,"ule"),
          z => Some{nt_choose(U32,U32.is_lt(ah,bh) || (U32.is_eq(ah,bh) && U32.is_le(al,bl)),q => 1,q => 0)},
          z => None{}))))

@unsafe
def x190_v_narrow_op(+op: String) -> Bool:
  agy_str_eq(op,"add") || agy_str_eq(op,"sub") || agy_str_eq(op,"mul") ||
    agy_str_eq(op,"and") || agy_str_eq(op,"or") || agy_str_eq(op,"xor")

def x195bf_enabled() -> Bool: True{}

@unsafe
def w5b_is_set(stmt: P113DStmt) -> Bool:
  match stmt:
    case P113DScalar{N111Set{_,_,_}}: True{}
    case _: False{}

@unsafe
def w5b_val_eq(a: N111Value, b: N111Value) -> Bool:
  match a:
    case N111Local{na}:
      match b:
        case N111Local{nb}: agy_str_eq(na,nb)
        case _: False{}
    case N111Const{al,ah}:
      match b:
        case N111Const{bl,bh}: U32.is_eq(al,bl) && U32.is_eq(ah,bh)
        case _: False{}
    case _: False{}

@unsafe
def w5b_emit_if_go(+yes2: List<&2,P113DStmt>, +no2: List<&2,P113DStmt>,
    +condition: N111Value, +tail: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  match yes2:
    case Nil{}:
      match no2:
        case Nil{}: tail
        case _: Con{P113DIf{condition,yes2,no2},tail}
    case _: Con{P113DIf{condition,yes2,no2},tail}

def x195cf_enabled() -> Bool: True{}

@unsafe
def x186_x_pick(ends: List<&2,U32>, +first: U32, +index: U32) -> U32:
  match ends:
    case Nil{}: 14
    case Con{last,rest}: nt_choose(U32,U32.is_lt(last,first),u => index,
      u => x186_x_pick(rest,first,U32.inc(index)))

@unsafe
def w4b_zeros(+n: U32) -> List<&2,U32>:
  nt_choose(List<&2,U32>,U32.is_eq(n,0),u => [],u => Con{0,w4b_zeros(U32.sub(n,1))})

@unsafe
def w2c_x_clear_canon(scan: X186XScan) -> X186XScan:
  match scan:
    case X186XScan{ranges,canonical}: X186XScan{ranges,missing()}

@unsafe
def w2c_scan_val_eq(a: N111Value, b: N111Value) -> Bool:
  match a b:
    case N111Local{x} N111Local{y}: agy_str_eq(x,y)
    case N111Const{la,ha} N111Const{lb,hb}: U32.is_eq(la,lb) && U32.is_eq(ha,hb)
    case _ _: False{}

@unsafe
def w2b_replace_nth(vals: List<&2,N111Value>, +idx: U32, +repl: N111Value) -> List<&2,N111Value>:
  match vals:
    case Nil{}: []
    case Con{v,+rest}:
      nt_choose(List<&2,N111Value>,U32.is_eq(idx,0),u => Con{repl,rest},u => Con{v,w2b_replace_nth(rest,U32.sub(idx,1),repl)})

@unsafe
def w2_xl_nth(vals: List<&2,N111Value>, +idx: U32) -> Maybe<&2,N111Value>:
  match vals:
    case Nil{}: None{}
    case Con{v,rest}: nt_choose(Maybe<&2,N111Value>,U32.is_eq(idx,0),u => Some{v},u => w2_xl_nth(rest,U32.sub(idx,1)))

@unsafe
def w2_val_reads(+name: String, value: N111Value) -> Bool:
  match value:
    case N111Local{local}: agy_str_eq(local,name)
    case _: False{}

@unsafe
def w2_scalar_writes(+name: String, stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Set{d,t,v}: agy_str_eq(d,name)
    case N111Bin{d,t,op,l,r}: agy_str_eq(d,name)
    case N111Load{d,t,b,off}: agy_str_eq(d,name)
    case N111Offset{d,b,by}: agy_str_eq(d,name)
    case N111Alloca{d,by,al}: agy_str_eq(d,name)
    case N111Call{d,t,sym,args}: agy_str_eq(d,name)
    case _: False{}

@unsafe
def w2_names_has(+name: String, names: List<&2,String>) -> Bool:
  match names:
    case Nil{}: False{}
    case Con{n,rest}: agy_str_eq(n,name) || w2_names_has(name,rest)

@unsafe
def w2_val_eq(a: N111Value, b: N111Value) -> Bool:
  match a b:
    case N111Local{x} N111Local{y}: agy_str_eq(x,y)
    case N111Const{la,ha} N111Const{lb,hb}: U32.is_eq(la,lb) && U32.is_eq(ha,hb)
    case _ _: False{}

@unsafe
def w2_int_inv(+op: String) -> String:
  nt_choose(String,agy_str_eq(op,"eq"),u => "jne",u =>
  nt_choose(String,agy_str_eq(op,"ne"),u => "je",u =>
  nt_choose(String,agy_str_eq(op,"ult"),u => "jae",u =>
  nt_choose(String,agy_str_eq(op,"ule"),u => "ja",u =>
  nt_choose(String,agy_str_eq(op,"ugt"),u => "jbe",u =>
  nt_choose(String,agy_str_eq(op,"uge"),u => "jb",u =>
  nt_choose(String,agy_str_eq(op,"slt"),u => "jge",u =>
  nt_choose(String,agy_str_eq(op,"sle"),u => "jg",u =>
  nt_choose(String,agy_str_eq(op,"sgt"),u => "jle",u =>
  nt_choose(String,agy_str_eq(op,"sge"),u => "jl",u => ""))))))))))

@unsafe
def w2_xl_safe_scalar(stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Call{d,t,sym,args}: agy_str_eq(sym,"p111_rt_fail")
    case N111If{c,yes,no}: False{}
    case _: True{}

@unsafe
def w2_xl_same_local(found: Maybe<&2,N111Value>, name: String) -> Bool:
  match found:
    case Some{N111Local{x}}: agy_str_eq(x,name)
    case _: False{}

@unsafe
def w2_xl_tail_skip(params: List<&2,String>) -> List<&2,String>:
  match params:
    case Nil{}: []
    case Con{+head,+rest}:
      nt_choose(List<&2,String>,agy_str_eq(head,"__x181_result_out"),u => rest,u => params)

@unsafe
def x194fv_closed(body: List<&2,X186FloatNode>, +name: String, +fuel: U32) -> Bool:
  match body:
    case Con{X186FloatValues{+destination,id,left,right},rest}:
      nt_choose(Bool,U32.is_eq(fuel,0),u => False{},u =>
        nt_choose(Bool,agy_str_eq(destination,name),v => True{},v => x194fv_closed(rest,name,U32.sub(fuel,1))))
    case Con{X186FloatPlain{P113DScalar{N111Set{+destination,N111U64{},value}}},rest}:
      nt_choose(Bool,U32.is_eq(fuel,0),u => False{},u =>
        nt_choose(Bool,agy_str_eq(destination,name),v => True{},v => x194fv_closed(rest,name,U32.sub(fuel,1))))
    case _: False{}

@unsafe
def x190_l_position(+name: String, params: List<&2,String>, +index: U32) -> U32:
  match params:
    case Nil{}: 4294967295
    case Con{head,rest}: nt_choose(U32,agy_str_eq(name,head),u => index,u => x190_l_position(name,rest,U32.inc(index)))

@unsafe
def x190_l_group(groups: List<&2,U32>, +register: U32, +bit: U32) -> List<&2,U32>:
  match groups:
    case Nil{}: []
    case Con{+mask,+rest}: nt_choose(List<&2,U32>,U32.is_eq(register,0),
      u => Con{U32.or(mask,bit),rest},u => Con{mask,x190_l_group(rest,U32.sub(register,1),bit)})

@unsafe
def x190_l_home(groups: List<&2,U32>, +bit: U32, +register: U32) -> U32:
  match groups:
    case Nil{}: 5
    case Con{mask,rest}: nt_choose(U32,U32.is_eq(U32.and(mask,bit),0),
      u => x190_l_home(rest,bit,U32.inc(register)),u => register)

@unsafe
def x203_prefix(rows: List<&2,X181RegisterChoice>, +limit: U32) -> List<&2,X181RegisterChoice>:
  match rows:
    case Nil{}: []
    case Con{head,rest}: nt_choose(List<&2,X181RegisterChoice>,U32.is_eq(limit,0),
      u => [],u => Con{head,x203_prefix(rest,U32.sub(limit,1))})

def x190_j_edges(+bit: U32, +edges: U32, color: U32) -> U32:
  nt_choose(U32,U32.is_lt(color,4),u => U32.and(edges,U32.not(bit)),u => edges)

@unsafe
def x190_j_home(groups: List<&2,U32>, +bit: U32, +color: U32) -> U32:
  match groups:
    case Nil{}: 9
    case Con{mask,rest}: nt_choose(U32,U32.is_eq(U32.and(mask,bit),0),
      u => x190_j_home(rest,bit,U32.inc(color)),u => color)

@unsafe
def w5c_occ_add(occ: List<&2,List<&2,W5CIntv>>, +idx: U32, +intv: W5CIntv) -> List<&2,List<&2,W5CIntv>>:
  match occ:
    case Nil{}: []
    case Con{+head,+rest}:
      nt_choose(List<&2,List<&2,W5CIntv>>,U32.is_eq(idx,0),
        u => Con{Con{intv,head},rest},
        u => Con{head,w5c_occ_add(rest,U32.sub(idx,1),intv)})

@unsafe
def x191_again_identity(parameter: String, value: N111Value) -> Bool:
  match value:
    case N111Local{name}: agy_str_eq(parameter,name)
    case _: False{}

@unsafe
def x190_branch_inverse(+op: String) -> String:
  nt_choose(String,agy_str_eq(op,"eq"),u => "jne",u =>
  nt_choose(String,agy_str_eq(op,"ne"),u => "je",u =>
  nt_choose(String,agy_str_eq(op,"ult"),u => "jae",u =>
  nt_choose(String,agy_str_eq(op,"ule"),u => "ja",u =>
  nt_choose(String,agy_str_eq(op,"ugt"),u => "jbe",u =>
  nt_choose(String,agy_str_eq(op,"uge"),u => "jb",u =>
  nt_choose(String,agy_str_eq(op,"slt"),u => "jge",u =>
  nt_choose(String,agy_str_eq(op,"sle"),u => "jg",u =>
  nt_choose(String,agy_str_eq(op,"sgt"),u => "jle",u =>
  nt_choose(String,agy_str_eq(op,"sge"),u => "jl",u => ""))))))))))

@unsafe
def x198h_public(frame: X181Frame) -> Bool:
  match frame:
    case X181Frame{slots,bytes,calls,[+state],+symbol}:
      agy_str_eq(state,"state") && String.starts_with(symbol,"p111_FID_")
    case _: False{}

@unsafe
def x191_alu(+op: String) -> Bool:
  agy_str_eq(op,"add") || agy_str_eq(op,"sub") || agy_str_eq(op,"and") ||
    agy_str_eq(op,"or") || agy_str_eq(op,"xor") || agy_str_eq(op,"mul")

@unsafe
def x192_address_lookup(aliases: List<&2,X192AddressAlias>, +name: String) -> Maybe<&2,X191Address>:
  match aliases:
    case Nil{}: None{}
    case Con{X192AddressAlias{other,address,reads},rest}:
      nt_choose(Maybe<&2,X191Address>,agy_str_eq(name,other),u => Some{address},u => x192_address_lookup(rest,name))

@unsafe
def x192_address_used(aliases: List<&2,X192AddressAlias>, +name: String) -> List<&2,X192AddressAlias>:
  match aliases:
    case Nil{}: []
    case Con{X192AddressAlias{+other,address,+reads},rest}:
      Con{X192AddressAlias{other,address,nt_choose(U32,agy_str_eq(name,other),u => U32.inc(reads),u => reads)},
        x192_address_used(rest,name)}

@unsafe
def p198q_search(+d: U32, +q: U32, +r: U32, +s: U32, +scale: U32) -> P198Quot:
  nt_choose(P198Quot,U32.is_le(U32.sub(d,r),scale) && U32.is_lt(q,4294967295),
    u => P198Magic{U32.inc(q),U32.add(32,s)},u =>
    nt_choose(P198Quot,U32.is_lt(q,2147483648) && U32.is_lt(s,16),v =>
      p198q_search(d,U32.add(U32.mul(q,2),U32.div(U32.mul(r,2),d)),U32.mod(U32.mul(r,2),d),U32.inc(s),U32.mul(scale,2)),
      v => P198NoQuot{}))

@unsafe
def p198q_log(+d: U32, +shift: U32) -> U32:
  nt_choose(U32,U32.is_le(d,1),u => shift,u => p198q_log(U32.shrn(d,1n),U32.inc(shift)))

@unsafe
def x198qm_rr(item: X188Seq, want: String, src: U32, dst: U32, +width: U32) -> Bool:
  match item:
    case X188One{PInst{X187Instruction{op,[X187Reg{a,b,False{}},X187Reg{c,d,False{}}]}}}:
      agy_str_eq(op,want) && U32.is_eq(a,src) && U32.is_eq(c,dst) && U32.is_eq(b,width) && U32.is_eq(d,width)
    case _: False{}

@unsafe
def x198qm_state(item: X188Seq) -> Bool:
  match item:
    case X188One{PInst{X187Instruction{op,[X187Reg{src,64,False{}},X187Reg{7,64,False{}}]}}}:
      agy_str_eq(op,"movq") && U32.is_lt(src,16)
    case _: False{}

@unsafe
def x198qm_imm(item: X188Seq, target: U32) -> U32:
  match item:
    case X188One{PInst{X187Instruction{op,[X187Imm{value,0},X187Reg{dst,64,False{}}]}}}:
      nt_choose(U32,agy_str_eq(op,"movabsq") && U32.is_eq(dst,target),u => value,u => 0)
    case _: 0

@unsafe
def x198qm_lea(item: X188Seq, target: U32) -> U32:
  match item:
    case X188One{PInst{X187Instruction{op,[X187Mem{5,offset},X187Reg{dst,64,False{}}]}}}:
      nt_choose(U32,agy_str_eq(op,"leaq") && U32.is_eq(dst,target),u => offset,u => 0)
    case _: 0

@unsafe
def x198qm_store(item: X188Seq) -> Bool:
  match item:
    case X188One{PInst{X187Instruction{op,[X187Reg{11,64,False{}},X187Mem{10,8}]}}}: agy_str_eq(op,"movq")
    case _: False{}

# W4-4 Pass 1: Spill-free U32.div/mod operand recovery + lea for d in {3, 5, 9}.
@unsafe
def w4_qm_store0_r11(item: X188Seq) -> Bool:
  match item:
    case X188One{PInst{X187Instruction{op,[X187Reg{11,64,False{}},X187Mem{10,0}]}}}: agy_str_eq(op,"movq")
    case _: False{}

@unsafe
def w2c_movd_inverse(prev: X188Seq, +r: U32, +x: U32) -> Bool:
  match prev:
    case X188One{PInst{X187Instruction{op,[X187Reg{px,128,True{}},X187Reg{pr,32,False{}}]}}}:
      agy_str_eq(op,"movd") && U32.is_eq(pr,r) && U32.is_eq(px,x)
    case _: False{}

@unsafe
def x197d_flag_kill(+op: String) -> Bool:
  agy_str_eq(op,"cmpq") || agy_str_eq(op,"cmpl") || agy_str_eq(op,"addq") ||
    agy_str_eq(op,"addl") || agy_str_eq(op,"subq") || agy_str_eq(op,"subl")

@unsafe
def x197d_flag_pass(+op: String) -> Bool:
  agy_str_eq(op,"movq") || agy_str_eq(op,"movl") || agy_str_eq(op,"movabsq") ||
    agy_str_eq(op,"movzbl") || agy_str_eq(op,"leaq") || agy_str_eq(op,"shrq") ||
    agy_str_eq(op,"shrl") || agy_str_eq(op,"shlq") || agy_str_eq(op,"shll") ||
    agy_str_eq(op,"sarq") || agy_str_eq(op,"sarl") || agy_str_eq(op,"andq") ||
    agy_str_eq(op,"andl") || agy_str_eq(op,"orq") || agy_str_eq(op,"orl") ||
    agy_str_eq(op,"xorq") || agy_str_eq(op,"xorl")

@unsafe
def w4_peep_is_jz_jnz(+op: String) -> Bool:
  agy_str_eq(op,"je") || agy_str_eq(op,"jne") || agy_str_eq(op,"jz") || agy_str_eq(op,"jnz")

@unsafe
def w4_peep_flags_pass_op(+op: String) -> Bool:
  agy_str_eq(op,"movq") || agy_str_eq(op,"movl") || agy_str_eq(op,"movabsq") ||
  agy_str_eq(op,"movzbl") || agy_str_eq(op,"leaq") || agy_str_eq(op,"pushq") || agy_str_eq(op,"popq")

@unsafe
def w4_leaf_match_end(items: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match items:
    case Con{PInst{X187Instruction{e1,[X187Reg{5,64,False{}},X187Reg{4,64,False{}}]}},
         Con{PInst{X187Instruction{e2,[X187Reg{5,64,False{}}]}},
         Con{PInst{X187Instruction{e3,Nil{}}},rest}}}:
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,agy_str_eq(e1,"movq") && agy_str_eq(e2,"popq") && agy_str_eq(e3,"ret"),
        u => Some{rest},u => None{})
    case _: None{}

@unsafe
def w4_leaf_is_r12_init(item: X187Parsed) -> Bool:
  match item:
    case PInst{X187Instruction{op,[X187Reg{7,64,False{}},X187Reg{12,64,False{}}]}}: agy_str_eq(op,"movq")
    case _: False{}

@unsafe
def w4_leaf_is_r12_restore(item: X187Parsed) -> Bool:
  match item:
    case PInst{X187Instruction{op,[X187Mem{5,4294967280},X187Reg{12,64,False{}}]}}: agy_str_eq(op,"movq")
    case _: False{}

@unsafe
def w4_leaf_drop_r12_list(saved: List<&2,U32>) -> List<&2,U32>:
  match saved:
    case Nil{}: []
    case Con{+r,+rest}: nt_choose(List<&2,U32>,U32.is_eq(r,12),u => w4_leaf_drop_r12_list(rest),u => Con{r,w4_leaf_drop_r12_list(rest)})

@unsafe
def w4b_is_ret(item: X187Parsed) -> Bool:
  match item:
    case PInst{X187Instruction{op,Nil{}}}: agy_str_eq(op,"ret")
    case _: False{}

@unsafe
def w12_mem5_disp(op: X187Operand) -> U32:
  match op:
    case X187Mem{b,d}: nt_choose(U32,U32.is_eq(b,5),u => d,u => 0)
    case _: 0

@unsafe
def w12_reg64_id(op: X187Operand) -> U32:
  match op:
    case X187Reg{r,w,f}: nt_choose(U32,U32.is_eq(w,64) && Bool.not(f),u => U32.inc(r),u => 0)
    case _: 0

@unsafe
def w12_reg_any_id(op: X187Operand) -> U32:
  match op:
    case X187Reg{r,_,f}: nt_choose(U32,Bool.not(f),u => U32.inc(r),u => 0)
    case _: 0

@unsafe
def w4b_has_call(items: List<&2,X187Parsed>) -> Bool:
  match items:
    case Nil{}: False{}
    case Con{PInst{X187Instruction{op,_}},rest}: agy_str_eq(op,"call") || w4b_has_call(rest)
    case Con{_,rest}: w4b_has_call(rest)

@unsafe
def w4b_branch_is_jmp(+lbl: String, br: W4BBranch) -> Bool:
  match br:
    case W4BBranch{op,t}: agy_str_eq(op,"jmp") && agy_str_eq(t,lbl)
    case W4BBranchNone{}: False{}

@unsafe
def w4b_branch_is_any(+lbl: String, br: W4BBranch) -> Bool:
  match br:
    case W4BBranch{op,t}: String.starts_with(op,"j") && agy_str_eq(t,lbl)
    case W4BBranchNone{}: False{}

@unsafe
def w4b_branch_is_cond(+lbl: String, br: W4BBranch) -> Bool:
  match br:
    case W4BBranch{op,t}: String.starts_with(op,"j") && Bool.not(agy_str_eq(op,"jmp")) && agy_str_eq(t,lbl)
    case W4BBranchNone{}: False{}

@unsafe
def w4b_is_magic_pair(a: W4BImmReg, b: W4BRR) -> Maybe<&2,U32>:
  match a b:
    case W4BImmReg{op0,m,hi,r0,w0} W4BRR{op1,s,ws,d,wd}:
      nt_choose(Maybe<&2,U32>,agy_str_eq(op0,"movl") && U32.is_eq(hi,0) && U32.is_eq(r0,11) && U32.is_eq(w0,32) &&
          agy_str_eq(op1,"imulq") && U32.is_eq(s,11) && U32.is_eq(ws,64) && U32.is_eq(d,0) && U32.is_eq(wd,64) &&
          U32.is_ge(m,256),
        u => Some{m},u => None{})
    case _ _: None{}

@unsafe
def w4b_lookup_magic(+m: U32, mp: List<&2,W4BMagicMap>) -> Maybe<&2,U32>:
  match mp:
    case Nil{}: None{}
    case Con{W4BMagicEntry{imm,reg},rest}:
      nt_choose(Maybe<&2,U32>,U32.is_eq(imm,m),u => Some{reg},u => w4b_lookup_magic(m,rest))

@unsafe
def w5_args_jump_to(args: List<&2,X187Operand>, +lbl1: String, +lbl2: String) -> Bool:
  match args:
    case Nil{}: False{}
    case Con{X187Target{+t},rest}:
      agy_str_eq(t,lbl1) || agy_str_eq(t,lbl2) || w5_args_jump_to(rest,lbl1,lbl2)
    case Con{_,rest}: w5_args_jump_to(rest,lbl1,lbl2)

@unsafe
def w4b_test_inst(+r: U32, +w: U32) -> X187Parsed:
  nt_choose(X187Parsed,U32.is_eq(w,64),
    u => PInst{X187Instruction{"testq",[X187Reg{r,64,False{}},X187Reg{r,64,False{}}]}},
    u => PInst{X187Instruction{"testl",[X187Reg{r,32,False{}},X187Reg{r,32,False{}}]}})

@unsafe
def w4c_as_addl_mem_reg(item: X187Parsed) -> W4CMemAdd:
  match item:
    case PInst{X187Instruction{op,args}}:
      match args:
        case Con{X187Indexed{b,idx,sc,disp},Con{X187Reg{r,32,False{}},Nil{}}}:
          nt_choose(W4CMemAdd,agy_str_eq(op,"addl"),u => W4CMemAdd{b,idx,sc,disp,r},u => W4CMemAddNone{})
        case _: W4CMemAddNone{}
    case _: W4CMemAddNone{}

@unsafe
def w4c_as_movl_reg_mem(item: X187Parsed) -> W4CMemAdd:
  match item:
    case PInst{X187Instruction{op,args}}:
      match args:
        case Con{X187Reg{r,32,False{}},Con{X187Indexed{b,idx,sc,disp},Nil{}}}:
          nt_choose(W4CMemAdd,agy_str_eq(op,"movl"),u => W4CMemAdd{b,idx,sc,disp,r},u => W4CMemAddNone{})
        case _: W4CMemAddNone{}
    case _: W4CMemAddNone{}

@unsafe
def w5_check_testq_r(rr: W4BRR, +r: U32) -> Bool:
  match rr:
    case W4BRR{+top,+ts,64,+td,64}:
      agy_str_eq(top,"testq") && U32.is_eq(ts,td) && U32.is_eq(ts,r)
    case _: False{}

@unsafe
def w4c_map_get(m: W4CMap, +k: U32, +sh: U32) -> U32:
  match m:
    case W4CMEmpty{}: 0
    case W4CMLeaf{lk,lv}: nt_choose(U32,U32.is_eq(lk,k),u => lv,u => 0)
    case W4CMNode{z,o}:
      nt_choose(U32,U32.is_eq(U32.and(sh,1),0),
        u => w4c_map_get(z,k,U32.shr(sh)),
        u => w4c_map_get(o,k,U32.shr(sh)))

@unsafe
def w4c_shift_by(+x: U32, +n: U32) -> U32:
  nt_choose(U32,U32.is_eq(n,0),u => x,u => w4c_shift_by(U32.shr(x),U32.sub(n,1)))

@unsafe
def w4c_is_fop(+op: String) -> Bool:
  agy_str_eq(op,"addss") || agy_str_eq(op,"subss") || agy_str_eq(op,"mulss") || agy_str_eq(op,"divss")

@unsafe
def w4c_is_write_only_mem(+op: String) -> Bool:
  agy_str_eq(op,"movq") || agy_str_eq(op,"movl") || agy_str_eq(op,"movss") || agy_str_eq(op,"movd")

@unsafe
def w4c_is_xmm_write_only(+op: String) -> Bool:
  agy_str_eq(op,"movaps") || agy_str_eq(op,"movd") || agy_str_eq(op,"movss") || agy_str_eq(op,"pxor")

@unsafe
def w4c_is_ctrl(+op: String) -> Bool:
  agy_str_eq(op,"jmp") || agy_str_eq(op,"je") || agy_str_eq(op,"jne") || agy_str_eq(op,"ja") ||
  agy_str_eq(op,"jae") || agy_str_eq(op,"jb") || agy_str_eq(op,"jbe") || agy_str_eq(op,"jg") ||
  agy_str_eq(op,"jge") || agy_str_eq(op,"jl") || agy_str_eq(op,"jle") || agy_str_eq(op,"call") ||
  agy_str_eq(op,"ret")

@unsafe
def w4c_as_load_xmm(item: X187Parsed) -> W4CLoadXmm:
  match item:
    case PInst{X187Instruction{op,Con{src,Con{X187Reg{dr,_,True{}},Nil{}}}}}:
      nt_choose(W4CLoadXmm,agy_str_eq(op,"movd") || agy_str_eq(op,"movaps"),u => W4CLXYes{op,src,dr},u => W4CLXNo{})
    case _: W4CLXNo{}

@unsafe
def w4c_replace_op(+from: U32, +to: U32, op: X187Operand) -> X187Operand:
  match op:
    case X187Mem{+b,+d}: nt_choose(X187Operand,U32.is_eq(b,5) && U32.is_eq(d,from),u => X187Mem{5,to},u => X187Mem{b,d})
    case _: op

@unsafe
def w5_is_comm_fop(+op: String) -> Bool:
  agy_str_eq(op,"addss") || agy_str_eq(op,"mulss")

@unsafe
def w5_as_movaps(item: X187Parsed) -> W5Movaps:
  match item:
    case PInst{X187Instruction{op,Con{X187Reg{sr,_,True{}},Con{X187Reg{dr,_,True{}},Nil{}}}}}:
      nt_choose(W5Movaps,agy_str_eq(op,"movaps"),u => W5MAYes{sr,dr},u => W5MANo{})
    case _: W5MANo{}

@unsafe
def w5_as_movd_slot(item: X187Parsed) -> W5MovdSlot:
  match item:
    case PInst{X187Instruction{op,Con{X187Mem{b,d},Con{X187Reg{dr,_,True{}},Nil{}}}}}:
      nt_choose(W5MovdSlot,agy_str_eq(op,"movd") && U32.is_eq(b,5),u => W5MSYes{d,dr},u => W5MSNo{})
    case _: W5MSNo{}

@unsafe
def w5_as_xmm_prod(item: X187Parsed) -> W5XmmProd:
  match item:
    case PInst{X187Instruction{op,Con{src,Con{X187Reg{dr,_,True{}},Nil{}}}}}:
      nt_choose(W5XmmProd,agy_str_eq(op,"movd") || agy_str_eq(op,"movaps") || agy_str_eq(op,"sqrtss"),
        u => W5XPYes{op,src,dr},u => W5XPNo{})
    case _: W5XPNo{}

@unsafe
def w5_is_comm64(+op: String) -> Bool:
  agy_str_eq(op,"addq") || agy_str_eq(op,"orq") || agy_str_eq(op,"andq") || agy_str_eq(op,"xorq")

@unsafe
def w5_is_comm32(+op: String) -> Bool:
  agy_str_eq(op,"addl") || agy_str_eq(op,"orl") || agy_str_eq(op,"andl") || agy_str_eq(op,"xorl")

@unsafe
def w5_as_load_rbp(item: X187Parsed) -> W5LoadRbp:
  match item:
    case PInst{X187Instruction{op,Con{X187Mem{b,d},Con{X187Reg{dr,64,False{}},Nil{}}}}}:
      nt_choose(W5LoadRbp,agy_str_eq(op,"movq") && U32.is_eq(b,5),u => W5LRYes{d,dr},u => W5LRNo{})
    case _: W5LRNo{}

@unsafe
def w5_as_store_rbp(item: X187Parsed) -> W5StoreRbp:
  match item:
    case PInst{X187Instruction{op,Con{X187Reg{sr,64,False{}},Con{X187Mem{b,d},Nil{}}}}}:
      nt_choose(W5StoreRbp,agy_str_eq(op,"movq") && U32.is_eq(b,5),u => W5SRYes{sr,d},u => W5SRNo{})
    case _: W5SRNo{}

@unsafe
def w5_as_movq_to_reg(item: X187Parsed) -> W5MovqToReg:
  match item:
    case PInst{X187Instruction{op,Con{src,Con{X187Reg{dr,64,False{}},Nil{}}}}}:
      nt_choose(W5MovqToReg,agy_str_eq(op,"movq"),u => W5MTRYes{src,dr},u => W5MTRNo{})
    case _: W5MTRNo{}

@unsafe
def w5_as_movq_from_reg(item: X187Parsed) -> W5MovqFromReg:
  match item:
    case PInst{X187Instruction{op,Con{X187Reg{sr,64,False{}},Con{dst,Nil{}}}}}:
      nt_choose(W5MovqFromReg,agy_str_eq(op,"movq"),u => W5MFRYes{sr,dst},u => W5MFRNo{})
    case _: W5MFRNo{}

@unsafe
def w5_as_movzbl(item: X187Parsed) -> W5Movzbl:
  match item:
    case PInst{X187Instruction{op,Con{X187Reg{sr,8,False{}},Con{X187Reg{dr,32,False{}},Nil{}}}}}:
      nt_choose(W5Movzbl,agy_str_eq(op,"movzbl"),u => W5MZYes{sr,dr},u => W5MZNo{})
    case _: W5MZNo{}

@unsafe
def w5_g11_inv_jcc(+op: String) -> String:
  nt_choose(String,agy_str_eq(op,"jne") || agy_str_eq(op,"jnz"),u => "cmoveq",
    u => nt_choose(String,agy_str_eq(op,"je") || agy_str_eq(op,"jz"),v => "cmovneq",v => ""))

@unsafe
def w12g_g11_l4_eq(+t2: String, r4: List<&2,X187Parsed>) -> Bool:
  match r4:
    case Con{PLabel{l4},_}: agy_str_eq(l4,t2)
    case _: False{}

@unsafe
def w5b_g12_flip_cmov(+op: String) -> String:
  nt_choose(String,agy_str_eq(op,"cmovneq"),u => "cmoveq",
    u => nt_choose(String,agy_str_eq(op,"cmoveq"),v => "cmovneq",v => ""))

@unsafe
def w5b_g12_is_testl_self(+rC: U32, item: X187Parsed) -> Bool:
  match item:
    case PInst{X187Instruction{op,Con{X187Reg{s,32,False{}},Con{X187Reg{d,32,False{}},Nil{}}}}}:
      agy_str_eq(op,"testl") && U32.is_eq(s,rC) && U32.is_eq(d,rC)
    case _: False{}

@unsafe
def w5b_is_r12_save(item: X187Parsed) -> Bool:
  match item:
    case PInst{X187Instruction{op,Con{X187Reg{12,64,False{}},Con{X187Mem{5,4294967280},Nil{}}}}}:
      agy_str_eq(op,"movq")
    case _: False{}

@unsafe
def w5b_is_r12_restore(item: X187Parsed) -> Bool:
  match item:
    case PInst{X187Instruction{op,Con{X187Mem{5,4294967280},Con{X187Reg{12,64,False{}},Nil{}}}}}:
      agy_str_eq(op,"movq")
    case _: False{}

@unsafe
def w5b_is_r12_ctx_init(item: X187Parsed) -> Bool:
  match item:
    case PInst{X187Instruction{op,Con{X187Reg{7,64,False{}},Con{X187Reg{12,64,False{}},Nil{}}}}}:
      agy_str_eq(op,"movq")
    case _: False{}

@unsafe
def w5b_is_gpr64_slot_op(+op: String) -> Bool:
  agy_str_eq(op,"movq") || agy_str_eq(op,"addq") || agy_str_eq(op,"subq") ||
  agy_str_eq(op,"andq") || agy_str_eq(op,"orq") || agy_str_eq(op,"xorq") ||
  agy_str_eq(op,"cmpq") || agy_str_eq(op,"cmoveq") || agy_str_eq(op,"cmovneq")

@unsafe
def w5b_inv_cc(+cc: String) -> String:
  nt_choose(String,agy_str_eq(cc,"e"),u => "ne",u =>
  nt_choose(String,agy_str_eq(cc,"ne"),u => "e",u =>
  nt_choose(String,agy_str_eq(cc,"z"),u => "nz",u =>
  nt_choose(String,agy_str_eq(cc,"nz"),u => "z",u =>
  nt_choose(String,agy_str_eq(cc,"a"),u => "be",u =>
  nt_choose(String,agy_str_eq(cc,"be"),u => "a",u =>
  nt_choose(String,agy_str_eq(cc,"ae"),u => "b",u =>
  nt_choose(String,agy_str_eq(cc,"b"),u => "ae",u =>
  nt_choose(String,agy_str_eq(cc,"g"),u => "le",u =>
  nt_choose(String,agy_str_eq(cc,"le"),u => "g",u =>
  nt_choose(String,agy_str_eq(cc,"ge"),u => "l",u =>
  nt_choose(String,agy_str_eq(cc,"l"),u => "ge",u => ""))))))))))))

@unsafe
def w5b_set_cc(+op: String) -> String:
  nt_choose(String,agy_str_eq(op,"sete"),u => "e",u =>
  nt_choose(String,agy_str_eq(op,"setne"),u => "ne",u =>
  nt_choose(String,agy_str_eq(op,"seta"),u => "a",u =>
  nt_choose(String,agy_str_eq(op,"setae"),u => "ae",u =>
  nt_choose(String,agy_str_eq(op,"setb"),u => "b",u =>
  nt_choose(String,agy_str_eq(op,"setbe"),u => "be",u =>
  nt_choose(String,agy_str_eq(op,"setg"),u => "g",u =>
  nt_choose(String,agy_str_eq(op,"setge"),u => "ge",u =>
  nt_choose(String,agy_str_eq(op,"setl"),u => "l",u =>
  nt_choose(String,agy_str_eq(op,"setle"),u => "le",u => ""))))))))))

@unsafe
def w5b_is_cmp(+op: String) -> Bool:
  agy_str_eq(op,"cmpq") || agy_str_eq(op,"cmpl")

@unsafe
def w5b_is_je_jne(item: X187Parsed) -> Maybe<&2,String>:
  match item:
    case PInst{X187Instruction{+op,Con{X187Target{+lbl},Nil{}}}}:
      nt_choose(Maybe<&2,String>,agy_str_eq(op,"je") || agy_str_eq(op,"jz"),
        u => Some{"E:" ++ lbl},
        u => nt_choose(Maybe<&2,String>,agy_str_eq(op,"jne") || agy_str_eq(op,"jnz"),
          v => Some{"N:" ++ lbl},v => None{}))
    case _: None{}

@unsafe
def w5b_jcc_name(+op: String) -> String:
  nt_choose(String,agy_str_eq(op,"je"),u => "e",u =>
  nt_choose(String,agy_str_eq(op,"jne"),u => "ne",u =>
  nt_choose(String,agy_str_eq(op,"jz"),u => "z",u =>
  nt_choose(String,agy_str_eq(op,"jnz"),u => "nz",u =>
  nt_choose(String,agy_str_eq(op,"ja"),u => "a",u =>
  nt_choose(String,agy_str_eq(op,"jae"),u => "ae",u =>
  nt_choose(String,agy_str_eq(op,"jb"),u => "b",u =>
  nt_choose(String,agy_str_eq(op,"jbe"),u => "be",u =>
  nt_choose(String,agy_str_eq(op,"jg"),u => "g",u =>
  nt_choose(String,agy_str_eq(op,"jge"),u => "ge",u =>
  nt_choose(String,agy_str_eq(op,"jl"),u => "l",u =>
  nt_choose(String,agy_str_eq(op,"jle"),u => "le",u => ""))))))))))))

@unsafe
def w11_op_imm32(op: X187Operand) -> Maybe<&2,U32>:
  match op:
    case X187Imm{lo,hi}: nt_choose(Maybe<&2,U32>,U32.is_eq(hi,0),u => Some{lo},u => None{})
    case _: None{}

@unsafe
def w5c_is_self_movl(inst: X187Parsed, +rD: U32) -> Bool:
  match inst:
    case PInst{X187Instruction{op1,Con{X187Reg{r1,32,False{}},Con{X187Reg{r2,32,False{}},Nil{}}}}}:
      agy_str_eq(op1,"movl") && U32.is_eq(r1,rD) && U32.is_eq(r2,rD)
    case _: False{}

@unsafe
def w5c_movq_dst(inst: X187Parsed, +rD: U32) -> U32:
  match inst:
    case PInst{X187Instruction{op1,Con{X187Reg{r1,64,False{}},Con{X187Reg{r2,64,False{}},Nil{}}}}}:
      nt_choose(U32,agy_str_eq(op1,"movq") && U32.is_eq(r1,rD),u => r2,u => 99)
    case _: 99

@unsafe
def w7_len_gt(items: List<&2,X187Parsed>, +limit: U32) -> Bool:
  match items:
    case Nil{}: False{}
    case Con{_,rest}:
      nt_choose(Bool,U32.is_eq(limit,0),u => True{},u => w7_len_gt(rest,U32.sub(limit,1)))

@unsafe
def x199s_count_arg(arg: X187Operand, +disp: U32, +wide: Bool) -> U32:
  match arg:
    case X187Mem{5,+offset}: Bool.to_u32(U32.is_lt(U32.sub(offset,disp),8) ||
      U32.is_lt(U32.sub(disp,offset),nt_choose(U32,wide,u => 32,u => 8)))
    case X187Reg{5,width,False{}}: 3
    case X187Indexed{5,index,scale,offset}: 3
    case X187Indexed{base,5,scale,offset}: 3
    case _: 0

@unsafe
def x199s_lookup(found: List<&2,X191FrameStore>, +offset: U32) -> U32:
  match found:
    case Nil{}: 16
    case Con{X191FrameStore{r,d},rest}: nt_choose(U32,U32.is_eq(d,offset),u => r,u => x199s_lookup(rest,offset))
    case Con{X191FrameStoreNone{},rest}: x199s_lookup(rest,offset)

@unsafe
def x194_ps_member(names: List<&2,String>, +name: String) -> Bool:
  match names:
    case Nil{}: False{}
    case Con{head,rest}: agy_str_eq(head,name) || x194_ps_member(rest,name)

@unsafe
def x197ms_inverse(+op: String) -> String:
  nt_choose(String,agy_str_eq(op,"eq"),u => "ne",u =>
  nt_choose(String,agy_str_eq(op,"ne"),u => "e",u =>
  nt_choose(String,agy_str_eq(op,"ult"),u => "ae",u =>
  nt_choose(String,agy_str_eq(op,"ule"),u => "a",u =>
  nt_choose(String,agy_str_eq(op,"ugt"),u => "be",u =>
  nt_choose(String,agy_str_eq(op,"uge"),u => "b",u =>
  nt_choose(String,agy_str_eq(op,"slt"),u => "ge",u =>
  nt_choose(String,agy_str_eq(op,"sle"),u => "g",u =>
  nt_choose(String,agy_str_eq(op,"sgt"),u => "le",u =>
  nt_choose(String,agy_str_eq(op,"sge"),u => "l",u => ""))))))))))

def x192_predicate_enabled() -> Bool: True{}

@unsafe
def x192_p_constant(value: N111Value, wanted: U32) -> Bool:
  match value:
    case N111Const{lo,hi}: U32.is_eq(hi,0) && U32.is_eq(lo,wanted)
    case _: False{}

# A boolean comparison with 0/1 is a copy or complement. Both original
# operands have already been evaluated; no floating predicate is admitted.
@unsafe
def x181_tail_skip(params: List<&2,String>) -> List<&2,String>:
  match params:
    case Nil{}: []
    case Con{+head,+rest}:
      nt_choose(List<&2,String>,agy_str_eq(head,"__x181_result_out"),u => rest,u => params)

law w12_has_borrow_fields:
  for body: List<&2,P113DStmt>
  Bool

@unsafe
def w12_has_borrow_fields(body):
  match body:
    case Nil{}: False{}
    case Con{P113DScalar{N111Call{d,t,sym,args}},rest}:
      agy_str_eq(sym,"p118_rt_borrow_fields") || w12_has_borrow_fields(rest)
    case Con{P113DIf{c,yes,no},rest}:
      w12_has_borrow_fields(yes) || w12_has_borrow_fields(no) || w12_has_borrow_fields(rest)
    case Con{h,rest}: w12_has_borrow_fields(rest)

@unsafe
def w2_asr_mask(+k: U32) -> U32:
  U32.sub(0,U32.shln(1,U32.to_nat(U32.sub(32,k))))

@unsafe
def w2_asr_val_local(v: N111Value) -> String:
  match v:
    case N111Local{name}: name
    case _: ""

@unsafe
def w2_asr_is_const(v: N111Value, +want: U32) -> Bool:
  match v:
    case N111Const{lo,0}: U32.is_eq(lo,want)
    case _: False{}

@unsafe
def w2_asr_head(names: List<&2,String>) -> Maybe<&2,String>:
  match names:
    case Con{m,rest2}: Some{m}
    case Nil{}: None{}

@unsafe
def w2_asr_changed(rewritten: List<&2,P113DStmt>, sel_rest: List<&2,P113DStmt>) -> Bool:
  match rewritten sel_rest:
    case Con{P113DScalar{N111Bin{d1,t1,op1,a1,b1}},_} Con{P113DScalar{N111Bin{d2,t2,op2,a2,b2}},_}:
      agy_str_eq(op1,"sar") && agy_str_eq(op2,"or")
    case _ _: False{}

@unsafe
def w11_val_is_const2(v: N111Value) -> Bool:
  match v:
    case N111Const{lo,hi}: U32.is_eq(lo,2) && U32.is_eq(hi,0)
    case _: False{}

@unsafe
def w11_val_local_eq(v: N111Value, +a: String) -> Bool:
  match v:
    case N111Local{b}: agy_str_eq(a,b)
    case _: False{}

@unsafe
def w5_insert_before_again(stmts: List<&2,P113DStmt>, +subStmt: P113DStmt) -> List<&2,P113DStmt>:
  match stmts:
    case Nil{}: [subStmt]
    case Con{P113DAgain{vs},Nil{}}: Con{subStmt,[P113DAgain{vs}]}
    case Con{h,rest}: Con{h,w5_insert_before_again(rest,subStmt)}

def x198a_enabled() -> Bool: True{}

def x198a_exact(fact: P113KFact) -> Bool:
  match fact:
    case P113KFact{bits,exact,lo,hi}: exact

def x198a_truth(fact: P113KFact, truth: Bool) -> Bool:
  match fact:
    case P113KFact{bits,exact,lo,hi}: exact && U32.is_eq(hi,0) && U32.is_eq(lo,Bool.to_u32(truth))

# Interpret just the guard prefix on the next state's constants. Unknown
# inputs (including fuel) refuse even when an unrelated fact could bound them.
def x198_sym_range(+x: U32, low: U32, high: U32) -> Bool:
  U32.is_ge(x,low) && U32.is_le(x,high)

def x198_perm_spec(+ctor: String, value: U32) -> X198Perm:
  # Base-4 digits encode the original index occupying each destination.
  # Admit precisely one pair exchange; duplicated, lost or reordered extra
  # fields cannot match these six bijections.
  match value:
    case 587: X198Perm{ctor,0,1}
    case 659: X198Perm{ctor,0,2}
    case 728: X198Perm{ctor,0,3}
    case 551: X198Perm{ctor,1,2}
    case 569: X198Perm{ctor,1,3}
    case 542: X198Perm{ctor,2,3}
    case _: X198NoPerm{}

def x198_perm_slot(+slot: U32) -> X187Operand:
  X187Indexed{10,nt_choose(U32,U32.is_lt(slot,2),u => 8,u => 9),8,U32.mul(U32.and(slot,1),8)}

def agy_da_key(name: String) -> String:
  "$agy.scan4/" ++ name

def agy_da_val_uses(v: N111Value, +name: String) -> Bool:
  match v:
    case N111Local{n}: p88_string_eq(n,name)
    case _: False{}

@unsafe
def x181_param_names(params: List<&2,NC_Binding>) -> List<&2,String>:
  match params:
    case Nil{}: []
    case Con{NC_Binding{id,word,kind},rest}: Con{word,x181_param_names(rest)}

# The native verifier permits these local spellings. Refuse collisions before
# introducing backend-owned result pointers and buffers; never shadow an input
# variable with an implicit frame slot. Global function names are FID encoded.
@unsafe
def x181_hygiene_name(+name: String) -> String:
  nt_choose(String,String.starts_with(name,"__x181"),
    u => "x86 reserved local name: " ++ name,u => "")

@unsafe
def x198n_equal(left: X198NFact, right: X198NFact) -> Bool:
  match left right:
    case X198NUnknown{} X198NUnknown{}: True{}
    case X198NConst{a,b} X198NConst{c,d}: U32.is_eq(a,c) && U32.is_eq(b,d)
    case X198NAlias{a,b} X198NAlias{c,d}: agy_str_eq(a,c) && Bool.not(Bool.xor(b,d))
    case X198NNonzero{a} X198NNonzero{b}: Bool.not(Bool.xor(a,b))
    case X198NPredecessor{} X198NPredecessor{}: True{}
    case _ _: False{}

@unsafe
def x198n_get(+name: String, env: List<&2,X198NBinding>) -> X198NFact:
  match env:
    case Nil{}: X198NUnknown{}
    case Con{X198NBinding{key,+fact},rest}: nt_choose(X198NFact,agy_str_eq(name,key),u => fact,u => x198n_get(name,rest))

@unsafe
def x198n_zero(value: X198NFact) -> Bool:
  match value:
    case X198NConst{lo,hi}: U32.is_eq(lo,0) && U32.is_eq(hi,0)
    case _: False{}

@unsafe
def x198n_one(value: X198NFact) -> Bool:
  match value:
    case X198NConst{lo,hi}: U32.is_eq(lo,1) && U32.is_eq(hi,0)
    case _: False{}

@unsafe
def x198n_nonzero(value: X198NFact) -> Bool:
  match value:
    case X198NConst{lo,hi}: Bool.not(U32.is_eq(lo,0) && U32.is_eq(hi,0))
    case X198NNonzero{narrow}: True{}
    case _: False{}

@unsafe
def x198n_low_nonzero(value: X198NFact) -> Bool:
  match value:
    case X198NConst{lo,hi}: Bool.not(U32.is_eq(lo,0))
    case X198NNonzero{narrow}: narrow
    case _: False{}

@unsafe
def x198n_constant(answer: P113KFact) -> X198NFact:
  match answer:
    case P113KFact{bits,exact,lo,hi}: nt_choose(X198NFact,exact,u => X198NConst{lo,hi},u => X198NUnknown{})

def x198n_op(+op: String) -> Bool:
  p88_string_eq(op,"add") || p88_string_eq(op,"sub") || p88_string_eq(op,"mul") || p88_string_eq(op,"and") || p88_string_eq(op,"or") || p88_string_eq(op,"xor") || p88_string_eq(op,"shl") || p88_string_eq(op,"shr") || p88_string_eq(op,"sar") || p88_string_eq(op,"eq") || p88_string_eq(op,"ne") || p88_string_eq(op,"ult") || p88_string_eq(op,"ule") || p88_string_eq(op,"ugt") || p88_string_eq(op,"uge")

def x198n_enabled() -> Bool: True{}

@unsafe
def x198n_split_add(stmt: P113DStmt, suffix: Maybe<&2,X198NLoop>) -> Maybe<&2,X198NLoop>:
  match suffix:
    case Some{X198NLoop{prefix,values}}: Some{X198NLoop{Con{stmt,prefix},values}}
    case None{}: None{}

def x198n_fuel_kind(kind: N_WordKind) -> Bool:
  match kind:
    case N_Imm64{}: True{}
    case N_W64{}: True{}
    case _: False{}

def x198n_word_kind(kind: N_WordKind) -> Bool:
  match kind:
    case N_W32{}: True{}
    case _: False{}

@unsafe
def x198n_initial(params: List<&2,NC_Binding>, +fuel: String, +mode: String) -> List<&2,X198NBinding>:
  match params:
    case Nil{}: []
    case Con{NC_Binding{id,+name,kind},rest}:
      Con{X198NBinding{name,nt_choose(X198NFact,agy_str_eq(name,fuel),u => X198NNonzero{False{}},u =>
        nt_choose(X198NFact,agy_str_eq(name,mode),v => X198NNonzero{True{}},v => X198NAlias{name,True{}}))},x198n_initial(rest,fuel,mode)}

@unsafe
def x198n_identity(fact: X198NFact, name: String) -> Bool:
  match fact:
    case X198NAlias{other,narrow}: narrow && agy_str_eq(other,name)
    case _: False{}

@unsafe
def x198n_pred(fact: X198NFact) -> Bool:
  match fact:
    case X198NPredecessor{}: True{}
    case _: False{}

@unsafe
def x198n_selected(choice: Maybe<&2,String>, +original: List<&2,P113DStmt>, +test: P113DStmt, condition: N111Value, +returned: List<&2,N111Value>, positive: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  match choice:
    case Some{mode}: [test,P113DIf{condition,[P113DResult{returned}],[P113DScalar{N111Bin{"p198n_nonzero_exit",N111U32{},"ne",N111Local{mode},N111Const{0,0}}},P113DIf{N111Local{"p198n_nonzero_exit"},[P113DResult{returned}],positive}]}]
    case None{}: original

@unsafe
def x198o_get(+name: String, env: List<&2,X198ABinding>) -> U32:
  match env:
    case Nil{}: 0
    case Con{X198ABinding{key,fact},rest}: nt_choose(U32,agy_str_eq(name,key),u => fact,u => x198o_get(name,rest))

@unsafe
def x198o_initial(params: List<&2,NC_Binding>, +fuel: String, +counter: String) -> List<&2,X198ABinding>:
  match params:
    case Nil{}: []
    case Con{NC_Binding{id,+name,kind},rest}:
      Con{X198ABinding{name,nt_choose(U32,agy_str_eq(name,fuel),u => 0,u => nt_choose(U32,agy_str_eq(name,counter),v => 2,v => 1))},x198o_initial(rest,fuel,counter)}

@unsafe
def x198o_argument(params: List<&2,String>, values: List<&2,N111Value>, +wanted: String) -> N111Value:
  match params values:
    case Con{name,ps} Con{+value,vs}: nt_choose(N111Value,agy_str_eq(name,wanted),u => value,u => x198o_argument(ps,vs,wanted))
    case _ _: N111Const{0,0}

@unsafe
def x198o_names(names: List<&2,String>) -> Bool:
  match names:
    case Nil{}: True{}
    case Con{name,rest}: Bool.not(String.starts_with(name,"p198a_")) && x198o_names(rest)

# A conservative straight-line certificate that some state field cannot be fixed.
# Unknown control flow returns no proof. A proven refusal adds no runtime checks.
# W4-4 Pass 5b: General parity-flipping progress certificate in x198o.
# Tracks `sameParity`: a U32 value with the exact same LSB as `param`.
# Multiplying by any odd constant preserves `sameParity`; adding/subbing/xoring
# any odd constant flips LSB -> `different = param` (mathematically zero fixed points in Z/2^32Z).
@unsafe
def w4_const_odd(f: X198NFact) -> Bool:
  match f:
    case X198NConst{lo,_}: U32.is_eq(U32.and(lo,1),1)
    case _: False{}

@unsafe
def w4_const_even(f: X198NFact) -> Bool:
  match f:
    case X198NConst{lo,_}: U32.is_eq(U32.and(lo,1),0)
    case _: False{}

@unsafe
def x198o_progress_get(+name: String, env: List<&2,X198OProgressBinding>) -> X198OProgress:
  match env:
    case Nil{}: X198OProgress{X198NUnknown{},"",""}
    case Con{X198OProgressBinding{key,+value},rest}: nt_choose(X198OProgress,agy_str_eq(name,key),u => value,u => x198o_progress_get(name,rest))

@unsafe
def x198o_progress_initial(params: List<&2,NC_Binding>, +fuel: String) -> List<&2,X198OProgressBinding>:
  match params:
    case Nil{}: []
    case Con{NC_Binding{id,+name,kind},rest}:
      +isFuel = agy_str_eq(name,fuel)
      Con{X198OProgressBinding{name,X198OProgress{
        nt_choose(X198NFact,isFuel,u => X198NUnknown{},u => X198NAlias{name,True{}}),
        "",
        nt_choose(String,isFuel,u => "",u => name)}},x198o_progress_initial(rest,fuel)}

@unsafe
def x198o_progress_alias(value: X198NFact) -> String:
  match value:
    case X198NAlias{+name,narrow}: nt_choose(String,narrow,u => name,u => "")
    case _: ""

@unsafe
def x198o_progress_is(value: X198OProgress, name: String) -> Bool:
  match value:
    case X198OProgress{fact,+different,_}: Bool.not(String.is_empty(different)) && agy_str_eq(different,name)

@unsafe
def agy_la_is_local(v: N111Value, +want: String) -> Bool:
  match v:
    case N111Local{n}: agy_str_eq(n,want)
    case _: False{}

@unsafe
def agy_la_extract_ctor(v: N111Value) -> String:
  match v:
    case N111CtorId{n}: n
    case _: ""

@unsafe
def x202k_index(call: N111Stmt, op: String, +index: U32) -> Bool:
  match call:
    case N111Call{dest,N111U64{},symbol,Con{N111Arg{N111Ptr{},N111Local{state}},Con{N111Arg{N111U32{},N111Const{lo,0}},Nil{}}}}:
      agy_str_eq(symbol,op) && agy_str_eq(state,"state") && U32.is_eq(lo,index)
    case _: False{}

@unsafe
def x202k_digits(text: String) -> Bool:
  match text:
    case SNil{}: True{}
    case SCon{ch,rest}: U32.is_le(U32.sub(Char.to_u32(ch),48),9) && x202k_digits(rest)

def x192h_regions_enabled() -> Bool: True{}

def x192h_v(name: String) -> N111Value: N111Local{name}
def x192h_c(value: U32) -> N111Value: N111Const{value,0}

@unsafe
def x192h_edge_name(index: U32) -> String:
  "p114h_edge_" ++ U32.show(index)

# Every scratch argument is read before any parameter is overwritten, including
# cross-parameter swaps and same-name results. Case buffers use QBE's rename.
def x198pw_v(name: String) -> X198PWPattern: X198PWVar{name}

def x198pw_node(l: X198PWPattern,r: X198PWPattern) -> X198PWPattern: X198PWCtr{"node",[l,r]}

def x198pw_two(role: String,x: String,y: String,body: X198PWPattern) -> X198PWPattern:
  X198PWCase{role,X198PWLam{x,X198PWLam{y,body}}}

def x198pw_three(x: String,y: String,z: String,body: X198PWPattern) -> X198PWPattern:
  X198PWLam{x,X198PWLam{y,X198PWLam{z,body}}}

def x198pw_add(plan: X198PWPlan,acc: List<&2,X198PWPlan>) -> List<&2,X198PWPlan>:
  match plan:
    case X198PWNone{}: acc
    case X198PWPlan{name,leaf,node}: Con{X198PWPlan{name,leaf,node},acc}

# This private map entry is consumed only within this x86 experiment. All
# dispatched function IDs and original data tables were established already.
def x198pw_key(owner: String) -> String: "$p198.pairwise/" ++ owner

def agy_zip_key(owner: String) -> String: "$agy.zipper/" ++ owner

def agy_ro_key(owner: String) -> String:
  "$agy.rorec/" ++ owner

def agy_ro_rev_u32(xs: List<&2,U32>, acc: List<&2,U32>) -> List<&2,U32>:
  match xs:
    case Nil{}: acc
    case Con{h,t}: agy_ro_rev_u32(t,Con{h,acc})

def agy_ro_prim_op(+name: String) -> String:
  nt_choose(String,p88_string_eq(name,"u32_add"),u => "addl",u =>
    nt_choose(String,p88_string_eq(name,"u32_sub"),u => "subl",u =>
      nt_choose(String,p88_string_eq(name,"u32_mul"),u => "imull",u =>
        nt_choose(String,p88_string_eq(name,"u32_xor"),u => "xorl",u =>
          nt_choose(String,p88_string_eq(name,"u32_and"),u => "andl",u =>
            nt_choose(String,p88_string_eq(name,"u32_or"),u => "orl",u => ""))))))

@unsafe
def agy_ro_lookup_var(+vid: U32, +f0_id: U32, +f0_k: U32, +f1_id: U32, +f1_k: U32, +x_id: U32, +has_x: Bool) -> Maybe<&2,KTerm>:
  nt_choose(Maybe<&2,KTerm>,has_x && U32.is_eq(vid,x_id),
    u => Some{kt("RoParamX","",0,0,[])},u =>
    nt_choose(Maybe<&2,KTerm>,U32.is_eq(f0_k,1) && U32.is_eq(vid,f0_id),
      v => Some{kt("RoField","",0,0,[])},v =>
      nt_choose(Maybe<&2,KTerm>,U32.is_eq(f1_k,1) && U32.is_eq(vid,f1_id),
        w => Some{kt("RoField","",1,0,[])},w => None{})))

@unsafe
def agy_ro_parse_bin_r(+op: String, ea: KTerm, rb: Maybe<&2,KTerm>) -> Maybe<&2,KTerm>:
  match rb:
    case None{}: None{}
    case Some{eb}: Some{kt("RoBin",op,0,0,[ea,eb])}

def agy_ro_is_inline_u32(fs: List<&2,U32>) -> U32:
  match fs:
    case Con{k0,Nil{}}: nt_choose(U32,U32.is_eq(k0,1),u => 1,u => 0)
    case _: 0

@unsafe
def agy_ro_add_entry(entry: Maybe<&2,KDef>, acc: List<&2,KDef>) -> List<&2,KDef>:
  match entry:
    case None{}: acc
    case Some{e}: Con{e,acc}

@unsafe
def agy_ro_h_args(ps: List<&2,String>, +arity: U32) -> Bool:
  match ps:
    case Con{state,Con{a,Con{mode,Con{depth,Con{value,Nil{}}}}}}:
      U32.is_eq(arity,1) && agy_str_eq(state,"state") && agy_str_eq(mode,"p114h_mode") && agy_str_eq(depth,"p114r_depth") && agy_str_eq(value,"p114r_value")
    case Con{state,Con{a,Con{b,Con{mode,Con{depth,Con{value,Nil{}}}}}}}:
      U32.is_eq(arity,2) && agy_str_eq(state,"state") && agy_str_eq(mode,"p114h_mode") && agy_str_eq(depth,"p114r_depth") && agy_str_eq(value,"p114r_value")
    case _: False{}

def x198pw_h_args(ps: List<&2,String>) -> Bool:
  match ps:
    case Con{state,Con{a,Con{b,Con{d,Con{mode,Con{depth,Con{value,Nil{}}}}}}}}:
      p88_string_eq(state,"state") && p88_string_eq(mode,"p114h_mode") && p88_string_eq(depth,"p114r_depth") && p88_string_eq(value,"p114r_value")
    case _: False{}

@unsafe
def agy_fl_check_warp(+book: List<&2,KDef>, +owner: String, +wn: String, +leaf_id: String, +node_id: String,
    +warp_name: String, wp: X198PWPlan) -> AgyFlowPlan:
  match wp:
    case X198PWPlan{w_owner,w_leaf,w_node}:
      nt_choose(AgyFlowPlan,agy_str_eq(w_leaf,leaf_id) && agy_str_eq(w_node,node_id),
        u => AgyFlowPlan{owner,leaf_id,node_id,warp_name,wn},
        u => AgyFlowNone{})
    case _: AgyFlowNone{}

def agy_fl_add(p: AgyFlowPlan, acc: List<&2,AgyFlowPlan>) -> List<&2,AgyFlowPlan>:
  match p:
    case AgyFlowNone{}: acc
    case AgyFlowPlan{o,l,n,w,wn}: Con{AgyFlowPlan{o,l,n,w,wn},acc}

def agy_fl_key(owner: String) -> String: "$agy.flow/" ++ owner

def x193f_fusion_enabled() -> Bool: True{}
def x193f_tail_enabled() -> Bool: True{}

@unsafe
def x193f_clean_name(name: String) -> Bool:
  Bool.not(String.starts_with(name,"p193f_"))

@unsafe
def x193f_arg_name(index: U32) -> String: "p193f_arg_" ++ U32.show(index)

# Snapshot every argument before the helper can overwrite any runtime storage.
# The same bounded scratch contract was checked by p112t_tail in the planner.
def x193fb_ratio() -> U32: 2
def x193fb_slack() -> U32: 16

def x195t_enabled() -> Bool: True{}

def x195t_name(name: String) -> Bool:
  Bool.not(String.starts_with(name,"p195t_"))

@unsafe
def x185_array_arguments(params: List<&2,NC_Binding>) -> List<&2,N111Arg>:
  match params:
    case Nil{}: []
    case Con{NC_Binding{id,word,kind},rest}:
      Con{N111Arg{N111U64{},N111Local{word}},x185_array_arguments(rest)}

# This call is only on the entry guard's false edge, before parameter mutation.
# Multiple results retain their incoming hidden output pointer and status.
def x199s_pair(+a: U32, +b: U32, +x: U32, +y: U32) -> Bool:
  (U32.is_eq(a,x) && U32.is_eq(b,y)) || (U32.is_eq(a,y) && U32.is_eq(b,x))

def x199s_narrow(+token: U32) -> U32:
  nt_choose(U32,U32.is_eq(token,2),u => 11,u =>
    nt_choose(U32,U32.is_eq(token,4),v => 17,v =>
      nt_choose(U32,U32.is_eq(token,7) || U32.is_eq(token,8) || U32.is_eq(token,9) ||
        U32.is_eq(token,11) || U32.is_eq(token,12) || U32.is_eq(token,13) ||
        U32.is_eq(token,16) || U32.is_eq(token,17) || U32.is_eq(token,18) || U32.is_eq(token,19),w => token,w => 0)))

def x199s_enabled() -> Bool: True{}

def agy_dp_pair(+a: U32, +b: U32, +x: U32, +y: U32) -> Bool:
  (U32.is_eq(a,x) && U32.is_eq(b,y)) || (U32.is_eq(a,y) && U32.is_eq(b,x))

def agy_dp_is_j(+t: U32) -> Bool:
  U32.is_eq(t,2) || U32.is_eq(t,11)

def agy_dp_is_ai(+t: U32) -> Bool:
  U32.is_eq(t,3) || U32.is_eq(t,12)

def agy_dp_narrow(+t: U32) -> U32:
  nt_choose(U32,U32.is_eq(t,2),u => 11,u =>
    nt_choose(U32,U32.is_eq(t,3),v => 12,v =>
      nt_choose(U32,U32.is_eq(t,11) || U32.is_eq(t,12) || U32.is_eq(t,13) ||
        U32.is_eq(t,17) || U32.is_eq(t,20) || U32.is_eq(t,24) || U32.is_eq(t,28) ||
        U32.is_eq(t,32) || U32.is_eq(t,33) || U32.is_eq(t,34) || U32.is_eq(t,36) ||
        U32.is_eq(t,37) || U32.is_eq(t,39) || U32.is_eq(t,50) || U32.is_eq(t,51),w => t,w => 0)))

@unsafe
def w5_lcu_val_is(+name: String, v: N111Value) -> Bool:
  match v:
    case N111Local{n}: agy_str_eq(n,name)
    case _: False{}

@unsafe
def w5_lcu_names_has(+name: String, ns: List<&2,String>) -> Bool:
  match ns:
    case Nil{}: False{}
    case Con{h,rest}: agy_str_eq(h,name) || w5_lcu_names_has(name,rest)

@unsafe
def w5_lcu_nth_val(vs: List<&2,N111Value>, +idx: U32) -> Maybe<&2,N111Value>:
  match vs:
    case Nil{}: None{}
    case Con{h,rest}:
      nt_choose(Maybe<&2,N111Value>,U32.is_eq(idx,0),u => Some{h},u => w5_lcu_nth_val(rest,U32.sub(idx,1)))

@unsafe
def w5_lcu_local_opt(mv: Maybe<&2,N111Value>) -> String:
  match mv:
    case Some{N111Local{n}}: n
    case _: ""

# Match `N111Call{dest, N111U64{}, "p111_rt_ctor", [state, N111CtorId{C}, N111Local{buf}, N111Const{A, 0}]}`
@unsafe
def w5_lcu_match_ctor_args(+aName: String, args: List<&2,N111Arg>) -> W5LcuCtor:
  match args:
    case Con{N111Arg{N111Ptr{},N111Local{+st}},
         Con{N111Arg{N111U32{},N111CtorId{+c}},
         Con{N111Arg{N111Ptr{},N111Local{+buf}},
         Con{N111Arg{N111U32{},N111Const{+a,0}},Nil{}}}}}:
      nt_choose(W5LcuCtor,agy_str_eq(st,"state") && Bool.not(agy_str_eq(buf,"state")) && U32.is_ge(a,1) && U32.is_le(a,8),
        u => W5LcuYes{c,a,buf,[],aName},
        u => W5LcuNo{})
    case _: W5LcuNo{}

@unsafe
def w5_lcu_collect_stores(revPrefix: List<&2,P113DStmt>, +buf: String, +wantOff: U32, +acc: List<&2,N111Value>) -> Maybe<&2,List<&2,N111Value>>:
  match revPrefix:
    case Con{P113DScalar{N111Store{N111U64{},N111Local{+b},+off,+v}},rest}:
      nt_choose(Maybe<&2,List<&2,N111Value>>,agy_str_eq(b,buf) && U32.is_eq(off,wantOff),
        u => nt_choose(Maybe<&2,List<&2,N111Value>>,U32.is_eq(wantOff,0),
          w => Some{Con{v,acc}},
          w => w5_lcu_collect_stores(rest,buf,U32.sub(wantOff,8),Con{v,acc})),
        u => None{})
    case _: None{}

@unsafe
def w5_lcu_drop_n(xs: List<&2,P113DStmt>, +n: U32) -> List<&2,P113DStmt>:
  match xs:
    case Nil{}: []
    case Con{h,+rest}:
      nt_choose(List<&2,P113DStmt>,U32.is_eq(n,0),u => Con{h,rest},u => w5_lcu_drop_n(rest,U32.sub(n,1)))

@unsafe
def w5_lcu_finish_ctor_vals(+c: String, +a: U32, +buf: String, +aName: String, mv: Maybe<&2,List<&2,N111Value>>) -> W5LcuCtor:
  match mv:
    case Some{vs}: W5LcuYes{c,a,buf,vs,aName}
    case None{}: W5LcuNo{}

@unsafe
def w5_lcu_n111_def(s: N111Stmt) -> String:
  match s:
    case N111Set{d,_,_}: d
    case N111Bin{d,_,_,_,_}: d
    case N111Load{d,_,_,_}: d
    case N111Offset{d,_,_}: d
    case N111Alloca{d,_,_}: d
    case N111Call{d,_,_,_}: d
    case _: ""

@unsafe
def w5_lcu_n111_is_if(s: N111Stmt) -> Bool:
  match s:
    case N111If{_,_,_}: True{}
    case _: False{}

@unsafe
def w5_lcu_merge_scan_mc(+cur: W5LcuScan, +seen: Bool, +c0: String, +a0: U32, mc: W5LcuCtor) -> W5LcuScan:
  match mc:
    case W5LcuNo{}: W5LcuScan{False{},seen,c0,a0}
    case W5LcuYes{+c,+a,_,_,_}:
      nt_choose(W5LcuScan,Bool.not(seen),
        w => W5LcuScan{True{},True{},c,a},
        w => nt_choose(W5LcuScan,agy_str_eq(c0,c) && U32.is_eq(a0,a),
          z => cur,
          z => W5LcuScan{False{},True{},c0,a0}))

@unsafe
def w5_lcu_is_tag_args(+pName: String, args: List<&2,N111Arg>) -> Bool:
  match args:
    case Con{N111Arg{N111Ptr{},N111Local{st}},Con{N111Arg{N111U64{},N111Local{w}},Nil{}}}:
      agy_str_eq(st,"state") && agy_str_eq(w,pName)
    case _: False{}

@unsafe
def w5_lcu_is_take_args(+pName: String, +arity: U32, args: List<&2,N111Arg>) -> Bool:
  match args:
    case Con{N111Arg{N111Ptr{},N111Local{st}},
         Con{N111Arg{N111U64{},N111Local{w}},
         Con{N111Arg{N111Ptr{},N111Local{buf}},
         Con{N111Arg{N111U32{},N111Const{a,0}},Nil{}}}}}:
      agy_str_eq(st,"state") && agy_str_eq(w,pName) && Bool.not(agy_str_eq(buf,"state")) && U32.is_eq(a,arity)
    case _: False{}

@unsafe
def w5_lcu_use_fail(u: W5LcuUse) -> W5LcuUse:
  match u:
    case W5LcuUse{_,st}: W5LcuUse{False{},st}

@unsafe
def w5_lcu_check_use_res(+idx: U32, +pName: String, +ctor: String, +arity: U32, ures: W5LcuUse) -> W5LcuCand:
  match ures:
    case W5LcuUse{uok,seenTake}:
      nt_choose(W5LcuCand,uok && seenTake,w => W5LcuCandYes{idx,pName,ctor,arity},w => W5LcuCandNo{})

@unsafe
def w5_lcu_field_name(+depth: U32, +i: U32) -> String:
  "w5_lcu_" ++ U32.show(depth) ++ "_" ++ U32.show(i)

@unsafe
def w5_lcu_count_loads(rest: List<&2,P113DStmt>, +tbuf: String, +arity: U32, +acc: U32) -> U32:
  match rest:
    case Con{P113DScalar{N111Load{_,N111U64{},N111Local{+b},+off}},more}:
      +fidx = U32.div(off,8)
      nt_choose(U32,agy_str_eq(b,tbuf) && U32.is_eq(U32.mod(off,8),0) && U32.is_lt(fidx,arity),
        u => w5_lcu_count_loads(more,tbuf,arity,U32.inc(acc)),
        u => acc)
    case _: acc

@unsafe
def w5_lcu_take_buf(args: List<&2,N111Arg>) -> String:
  match args:
    case Con{_,Con{_,Con{N111Arg{_,N111Local{buf}},_}}}: buf
    case _: ""

@unsafe
def w5_lcu_prepend_rev(xs: List<&2,P113DStmt>, revAcc: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  match xs:
    case Nil{}: revAcc
    case Con{h,rest}: w5_lcu_prepend_rev(rest,Con{h,revAcc})

@unsafe
def w5_lcu_is_set_to(+aName: String, s0: P113DStmt) -> Bool:
  match s0:
    case P113DScalar{N111Set{dst,N111U64{},N111Local{_}}}: agy_str_eq(dst,aName)
    case _: False{}

def agy_f32_sse_op(+op_id: U32) -> String:
  nt_choose(String,U32.is_eq(op_id,26),u => "addss",u =>
    nt_choose(String,U32.is_eq(op_id,27),v => "subss",v =>
      nt_choose(String,U32.is_eq(op_id,28),w => "mulss",w =>
        nt_choose(String,U32.is_eq(op_id,29),z => "divss",z => ""))))

def agy_f32_u32_op(+op: String) -> String:
  nt_choose(String,p88_string_eq(op,"add"),u => "addl",u =>
    nt_choose(String,p88_string_eq(op,"sub"),v => "subl",v =>
      nt_choose(String,p88_string_eq(op,"mul"),w => "imull",w =>
        nt_choose(String,p88_string_eq(op,"xor"),z => "xorl",z =>
          nt_choose(String,p88_string_eq(op,"and"),q => "andl",q =>
            nt_choose(String,p88_string_eq(op,"or"),r => "orl",r => ""))))))

@unsafe
def agy_f32_finish_again(ry: Maybe<&2,KTerm>, rh: Maybe<&2,KTerm>, obs: Maybe<&2,KTerm>) -> AgyF32Plan:
  match ry rh:
    case Some{ye} Some{he}: AgyF32Yes{ye,obs,he}
    case _ _: AgyF32No{}

def agy_f32_max(+a: U32, +b: U32) -> U32:
  nt_choose(U32,U32.is_gt(a,b),u => a,u => b)

def agy_f32_u_reg(+idx: U32) -> U32:
  nt_choose(U32,U32.is_eq(idx,0),u => 0,u =>
    nt_choose(U32,U32.is_eq(idx,1),v => 8,v =>
      nt_choose(U32,U32.is_eq(idx,2),w => 9,w => 10)))

@unsafe
def w5b_or_if(b: Bool, +bit: U32, +acc: U32) -> U32:
  match b:
    case True{}: U32.or(acc,bit)
    case False{}: acc

@unsafe
def agy_da_has_scan4(body: List<&2,P113DStmt>) -> Bool:
  match body:
    case Nil{}: False{}
    case Con{P113DScalar{N111Call{_,_,sym,_}},rest}:
      agy_str_eq(sym,"p199_rt_u32_scan4") || agy_da_has_scan4(rest)
    case Con{P113DIf{_,yes,no},rest}:
      agy_da_has_scan4(yes) || agy_da_has_scan4(no) || agy_da_has_scan4(rest)
    case Con{_,rest}: agy_da_has_scan4(rest)

@unsafe
def agy_map_val_is_ctor(v: N111Value, +cname: String) -> Bool:
  match v:
    case N111CtorId{n}: agy_str_eq(n,cname)
    case _: False{}

@unsafe
def agy_map_val_has_func(v: N111Value, +fname: String) -> Bool:
  match v:
    case N111FuncId{n}: agy_str_eq(n,fname) || agy_str_eq(n,"$direct." ++ fname)
    case _: False{}

@unsafe
def agy_bp_mix(+h: U32, +v: U32) -> U32:
  U32.mul(U32.xor(h,v),16777619)

def agy_map_key(name: String) -> String: "$agy.map/" ++ name

def x181_program_datum(datum: P111QDatum) -> X188Seq:
  X188One{PDatum{datum}}

# Both output consumers share the complete typed table interface.
def x181_program_note() -> X188Seq:
  X188One{PSection{4}}
# One File owns stdout throughout emission. Only one function and at most 128
# data directives are rendered at a time; no whole-program text is collected.
# A later emission/write failure may leave partial bytes in the fresh output.
# The host must accept that artifact only after successful process completion.

@unsafe
def x181_stream_fail(file: File, error: String) -> IO(U32):
  do IO<U32>:
    Unit <- File.close(file)
    IO.die(U32,1,error)

def x187_e_error() -> X187Encoded: X187Encoded{[],[],"unsupported x86 instruction or operand form"}
def x187_e_ok(bytes: List<&2,U32>) -> X187Encoded: X187Encoded{bytes,[],""}

@unsafe
def x187_e_le(+word: U32, +count: U32) -> List<&2,U32>:
  nt_choose(List<&2,U32>,U32.is_eq(count,0),u => [],
    u => Con{U32.mod(word,256),x187_e_le(U32.div(word,256),U32.sub(count,1))})

@unsafe
def x187_e_reg(value: X187Operand, +width: U32, +vector: Bool) -> Bool:
  match value:
    case X187Reg{index,bits,simd}: U32.is_lt(index,16) && U32.is_eq(width,bits) && Bool.not(Bool.xor(vector,simd))
    case _: False{}

@unsafe
def x187_e_index(value: X187Operand) -> U32:
  match value:
    case X187Reg{index,width,vector}: index
    case X187Mem{base,disp}: base
    case X187Indexed{base,index,scale,disp}: base
    case _: 0

# RSP cannot be an index: SIB index4 without REX.X denotes no index.
# R12 is a real index: SIB index4 with REX.X denotes R12.
def x191_e_indexed_valid(base: U32, +index: U32, +scale: U32) -> Bool:
  U32.is_lt(base,16) && U32.is_lt(index,16) && Bool.not(U32.is_eq(index,4)) &&
    (U32.is_eq(scale,1) || U32.is_eq(scale,2) || U32.is_eq(scale,4) || U32.is_eq(scale,8))

def x191_e_rex_x(value: X187Operand) -> U32:
  match value:
    case X187Indexed{base,index,scale,disp}: nt_choose(U32,U32.is_ge(index,8),u => 2,u => 0)
    case _: 0

@unsafe
def x187_e_byte(value: X187Operand) -> Bool:
  match value:
    case X187Reg{index,8,False{}}: U32.is_ge(index,4)
    case _: False{}



@unsafe
def w5b_b2u(b: Bool, v: U32) -> U32:
  match b:
    case True{}: v
    case False{}: 0

@unsafe
def w5b_e_prefix_tail(+legacy: U32, tail: List<&2,U32>) -> List<&2,U32>:
  match legacy:
    case 0: tail
    case _: Con{legacy,tail}

@unsafe
def w5b_e_mem_mode2(short: Bool) -> U32:
  match short:
    case True{}: 1
    case False{}: 2

@unsafe
def w5b_e_mem_sib(low: U32, dtail: List<&2,U32>) -> List<&2,U32>:
  match low:
    case 4: Con{36,dtail}
    case _: dtail

def x191_e_scale(scale: U32) -> U32:
  match scale:
    case 1: 0
    case 2: 1
    case 4: 2
    case _: 3

def x187_elf_u16(+value: U32) -> List<&2,U32>:
  [U32.and(value,255),U32.and(U32.shrn(value,8n),255)]

def x187_elf_u32(+value: U32) -> List<&2,U32>:
  [U32.and(value,255),U32.and(U32.shrn(value,8n),255),
   U32.and(U32.shrn(value,16n),255),U32.shrn(value,24n)]

@unsafe
def x187_elf_ascii(text: String, acc: List<&2,U32>) -> List<&2,U32>:
  match text:
    case SNil{}: acc
    case SCon{head,rest}: x187_elf_ascii(rest,Con{Char.to_u32(head),acc})

@unsafe
def w7c_u32_rev(+v: U32, tail: List<&2,U32>) -> List<&2,U32>:
  Con{U32.shrn(v,24n),Con{U32.and(U32.shrn(v,16n),255),
    Con{U32.and(U32.shrn(v,8n),255),Con{U32.and(v,255),tail}}}}

def x201e_u32_reverse(+value: U32, tail: List<&2,U32>) -> List<&2,U32>:
  Con{U32.shrn(value,24n),Con{U32.and(U32.shrn(value,16n),255),
    Con{U32.and(U32.shrn(value,8n),255),Con{U32.and(value,255),tail}}}}

def x187_elf_align(+offset: U32, +alignment: U32) -> U32:
  U32.and(U32.add(offset,U32.sub(alignment,1)),U32.xor(U32.sub(alignment,1),4294967295))

def x187_build_empty() -> X187Build:
  X187Build{1,[],[],[],0,0,0,missing(),[],[],""}

def x187_build_offset(+build: X187Build) -> U32:
  match build:
    case X187Build{section,t,r,d,ts,rs,ds,symbols,names,relocs,error}:
      match section:
        case 1: ts
        case 2: rs
        case _: ds

@unsafe
def w7_rev_count(bytes: List<&2,U32>, acc: List<&2,U32>, +n: U32) -> W7RevCount:
  match bytes:
    case Nil{}: W7RevCount{acc,n}
    case Con{a,Con{b,Con{c,Con{d,rest}}}}: w7_rev_count(rest,Con{d,Con{c,Con{b,Con{a,acc}}}},U32.add(n,4))
    case Con{a,rest}: w7_rev_count(rest,Con{a,acc},U32.inc(n))

def x187_build_relocation_known(+reloc: X187Relocation, +build: X187Build) -> X187Build:
  match build:
    case X187Build{s,t,r,d,ts,rs,ds,symbols,names,relocs,error}:
      X187Build{s,t,r,d,ts,rs,ds,symbols,names,Con{reloc,relocs},error}

@unsafe
def x187_build_fill(+count: U32, +byte: U32, +acc: List<&2,U32>) -> List<&2,U32>:
  match count:
    case 0: acc
    case _: x187_build_fill(U32.sub(count,1),byte,Con{byte,acc})

def x187_build_section(+build: X187Build) -> U32:
  match build:
    case X187Build{s,t,r,d,ts,rs,ds,symbols,names,relocs,error}: s

def x187_build_switch(+section: U32, +build: X187Build) -> X187Build:
  match build:
    case X187Build{s,t,r,d,ts,rs,ds,symbols,names,relocs,error}:
      X187Build{section,t,r,d,ts,rs,ds,symbols,names,relocs,error}

def x187_build_message(build: X187Build) -> String:
  match build:
    case X187Build{s,t,r,d,ts,rs,ds,symbols,names,relocs,error}: error

# An explicit pending-fragment stack bounds host call depth even for a deeply
# left- or right-associated selector sequence. Left is consumed before right.
def x188_fixup_add(patch: X187Relocation, state: X188Fixups) -> X188Fixups:
  match state:
    case X188Fixups{patches,relocations,escaped,error}:
      X188Fixups{Con{patch,patches},relocations,escaped,error}

@unsafe
def x202e_write(parts: List<&2,List<&2,U32>>, file: File) -> IO(U32):
  match parts:
    case Nil{}: do IO<U32>:
      Unit <- File.close(file)
      IO.pure(U32,0)
    case Con{Nil{},rest}: x202e_write(rest,file)
    case Con{bytes,rest}: do IO<U32>:
      pair : File & Result<&1,&1,U32 & String,Unit> <- File.write_bytes(file,bytes)
      x202e_after(rest,pair)

@unsafe
def x202e_after(rest: List<&2,List<&2,U32>>, pair: File & Result<&1,&1,U32 & String,Unit>) -> IO(U32):
  (file,result) = pair
  x202e_status(result,file,rest)

@unsafe
def x202e_status(result: Result<&1,&1,U32 & String,Unit>, file: File, rest: List<&2,List<&2,U32>>) -> IO(U32):
  match result:
    case Done{unit}: x202e_write(rest,file)
    case Fail{error}: do IO<U32>:
      Unit <- File.close(file)
      IO.pass(U32,Fail{error})

@unsafe
def x202t_rela_counts(items: List<&2,X187Relocation>, t: U32, r: U32, d: U32) -> X187ElfSizes:
  match items:
    case Nil{}: X187ElfSizes{t,r,d}
    case Con{X187Relocation{sec,off,kind,symbol,lo,hi},rest}:
      match sec:
        case 1: x202t_rela_counts(rest,U32.add(t,24),r,d)
        case 2: x202t_rela_counts(rest,t,U32.add(r,24),d)
        case _: x202t_rela_counts(rest,t,r,U32.add(d,24))

def x202t_sizes(raw: X187ElfSizes, rela: X187ElfSizes, symbols: U32, stringBytes: U32, names: U32) -> List<&2,U32>:
  match raw rela:
    case X187ElfSizes{text,rodata,data} X187ElfSizes{relText,relRo,relData}:
      [text,rodata,data,relText,relRo,relData,U32.mul(symbols,24),stringBytes,names,0]

@unsafe
def x187_print_status(result: Result<&1,&1,U32 & String,Unit>) -> IO(U32):
  match result:
    case Done{unit}: IO.pure(U32,0)
    case Fail{error}: IO.pass(U32,Fail{error})

# Preferred integration confines source certification to the x86 request path.
# The common checked planner runs once; its original rejection is returned.
law agy_lpt_n111_list:
  for +stmts: List<&2,N111Stmt>
  for +acc: U32
  U32

@unsafe
def agy_lpt_n111_stmt(+stmt: N111Stmt, +acc: U32) -> U32:
  match stmt:
    case N111If{c,yes,no}: agy_lpt_n111_list(no,agy_lpt_n111_list(yes,U32.add(acc,2)))
    case _: U32.add(acc,1)

@unsafe
def agy_lpt_n111_list(stmts, acc):
  match stmts:
    case Nil{}: acc
    case Con{head,rest}: agy_lpt_n111_list(rest,agy_lpt_n111_stmt(head,acc))

@unsafe
def agy_lpt_priv_split(+xs: List<&2,AgyLptPriv>, +a: List<&2,AgyLptPriv>, +b: List<&2,AgyLptPriv>) -> AgyLptPrivSplit:
  match xs:
    case Nil{}: AgyLptPrivSplit{a,b}
    case Con{x,Nil{}}: AgyLptPrivSplit{Con{x,a},b}
    case Con{x,Con{y,rest}}: agy_lpt_priv_split(rest,Con{x,a},Con{y,b})

@unsafe
def agy_lpt_pub_split(+xs: List<&2,AgyLptPub>, +a: List<&2,AgyLptPub>, +b: List<&2,AgyLptPub>) -> AgyLptPubSplit:
  match xs:
    case Nil{}: AgyLptPubSplit{a,b}
    case Con{x,Nil{}}: AgyLptPubSplit{Con{x,a},b}
    case Con{x,Con{y,rest}}: agy_lpt_pub_split(rest,Con{x,a},Con{y,b})

@unsafe
def w10_merge_names_ok(mods: List<&1,String>) -> Bool:
  match mods:
    case Nil{}: True{}
    case Con{+head,rest}: Bool.not(String.is_empty(head)) && w10_merge_names_ok(rest)

@unsafe
def w10_is_mod_local_sym(+name: String) -> Bool:
  String.starts_with(name,"p111_FID_36_112_49_49_49_46_107_46_") ||
    String.starts_with(name,"p113d_FID_36_112_49_49_49_46_107_46_") ||
    String.starts_with(name,"p114r_FID_36_112_49_49_49_46_107_46_") ||
    agy_str_eq(name,"p111_FID_109_97_105_110_") ||
    agy_str_eq(name,"p113d_FID_109_97_105_110_") ||
    agy_str_eq(name,"p114r_FID_109_97_105_110_") ||
    String.contains(name,"_126_")

@unsafe
def w10_if_h_init() -> W10IfHash:
  W10IfHash{2166136261, 3759247821}

@unsafe
def w10_if_h_byte(h: W10IfHash, +b: U32) -> W10IfHash:
  match h:
    case W10IfHash{h1, h2}:
      W10IfHash{
        U32.mul(U32.xor(h1, b), 16777619),
        U32.mul(U32.xor(h2, U32.xor(b, 165)), 16777619)
      }

law w10_if_zero_term:
  for +t: KTerm
  KTerm

@unsafe
def w10_if_zero_terms(ts: List<&2, KTerm>) -> List<&2, KTerm>:
  match ts:
    case Nil{}: Nil{}
    case Con{x, rest}: Con{w10_if_zero_term(x), w10_if_zero_terms(rest)}

@unsafe
def w10_if_zero_term(t):
  match t:
    case KTerm{tag, name, id, quant, kids, removed, ob, oe}:
      KTerm{tag, name, id, quant, w10_if_zero_terms(kids), removed, 0, 0}
    case KLambda{name, id, quant, kids, removed, ob, oe, qp}:
      KLambda{name, id, quant, w10_if_zero_terms(kids), removed, 0, 0, qp}
    case KLiteral{kind, number, text, ob, oe}:
      KLiteral{kind, number, text, 0, 0}

@unsafe
def w10_if_bind_len(bs: List<&2, W10IfBind>, acc: U32) -> U32:
  match bs:
    case Nil{}: acc
    case Con{_, rest}: w10_if_bind_len(rest, U32.inc(acc))

@unsafe
def w10_if_build_call(acc: KTerm, bs: List<&2, W10IfBind>) -> KTerm:
  match bs:
    case Nil{}: acc
    case Con{W10IfBind{name, id, quant}, rest}:
      +v : KTerm = KTerm{"Var", name, id, 0, Nil{}, Nil{}, 0, 0}
      w10_if_build_call(KTerm{"App", "", 0, 0, Con{acc, Con{v, Nil{}}}, Nil{}, 0, 0}, rest)

@unsafe
def w10_if_wrap_lams(rev_bs: List<&2, W10IfBind>, body: KTerm) -> KTerm:
  match rev_bs:
    case Nil{}: body
    case Con{W10IfBind{name, id, quant}, rest}:
      w10_if_wrap_lams(rest, KLambda{name, id, quant, Con{body, Nil{}}, Nil{}, 0, 0, False{}})

@unsafe
def w10_if_w(+n: U32, tail: String) -> String:
  SCon{Chr{U32.add(65536, U32.and(n, 65535))}, SCon{Chr{U32.add(65536, U32.shrn(n, 16n))}, tail}}

@unsafe
def w10_if_str_len(s: String, acc: U32) -> U32:
  match s:
    case SNil{}: acc
    case SCon{_, rest}: w10_if_str_len(rest, U32.inc(acc))

@unsafe
def w10_if_enc_nil(enc: W10IfEnc) -> W10IfRes:
  W10IfRes{enc, 0}

@unsafe
def w10_if_res_enc(r: W10IfRes) -> W10IfEnc:
  match r:
    case W10IfRes{enc, _}: enc

@unsafe
def w10_if_res_id(r: W10IfRes) -> U32:
  match r:
    case W10IfRes{_, id}: id

@unsafe
def w10_if_take_batch_join(+h: String, pair: String & List<&2, String>) -> String & List<&2, String>:
  (rest_str, rest_xs) = pair
  (h ++ rest_str, rest_xs)

@unsafe
def w10_if_stream_done(res3: Result<&1, &1, U32 & String, Unit>, +stamp: String) -> IO(U32):
  match res3:
    case Fail{e3}: IO.pass(U32, Fail{e3})
    case Done{_}:
      do IO<U32>:
        _ : Unit <- IO.print_err(stamp ++ "\n")
        IO.pure(U32, 0)

@unsafe
def w10_if_mark_ready(st: KBasePrefixState) -> KBasePrefixState:
  match st:
    case KBasePrefixState{bound, delta, stamp, patches, _}:
      KBasePrefixState{bound, delta, stamp, patches, True{}}

# --- Incremental O(|suffix|) world & ready extension for stub-only suffixes ---

@unsafe
def w8_tr_ms(t0: Nat, t1: Nat) -> String:
  Nat.show(Nat.sub(t1,t0)) ++ "ms"

@unsafe
def ts_priv_name(f: P113DFunction) -> String:
  match f:
    case P113DFunction{+name, params, result, public, body}: name

@unsafe
def ts_pub_name(s: N111Segment) -> String:
  match s:
    case N111Segment{+name, arity, result, incoming, flags, body}: name

