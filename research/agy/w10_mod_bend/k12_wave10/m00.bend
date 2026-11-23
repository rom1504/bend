# Module m00 (K=12 acyclic topological split of wave8_unified/compiler.bend)
# defs=1327 laws=81 sccs=1270 deps=[none] cross_imports=0 fid_base=0..5119

def p88_string_eq_go(a: String, b: String, same: Bool) -> Bool:
  match a b same:
    case SNil{} SNil{} result: result
    case SNil{} SCon{h, t} result: False{}
    case SCon{h, t} SNil{} result: False{}
    case SCon{h1, t1} SCon{h2, t2} False{}: False{}
    case SCon{h1, t1} SCon{h2, t2} True{}:
      p88_string_eq_go(t1, t2, U32.is_eq(Char.to_u32(h1), Char.to_u32(h2)))

def p98_eq_finish(same: Bool, left: String, right: String) -> Bool:
  same

def p88_string_eq(+a: String, +b: String) -> Bool:
  String.eq(a, b)

@unsafe
def agy_str_eq(+a: String, +b: String) -> Bool:
  String.eq(a, b)

# Core syntax, declarations, and structural term operations.

# Module: src/core/term.bend:25
law core_subst_stable_app_last:
  for +f: KTerm
  for +x: KTerm
  for +rest: List<&2, KTerm>
  Bool

# Module: src/core/term.bend:501
law norm_defs_join:
  for +a: List<&2, KDef>
  for +b: List<&2, KDef>
  List<&2, KDef>

# Module: src/core/index.bend:4
law index_first:
  for +ds: List<&2, KDef>
  KDef

# Module: src/core/index.bend:13
law book_final_reverse:
  for +book: List<&2,KDef>
  for +done: List<&2,KDef>
  List<&2,KDef>

# Module: src/core/index.bend:313
law norm_names_len:
  for +names: List<&2, String>
  U32

# Module: src/core/normalize.bend:343
law norm_exact_names:
  for +as: List<&2, String>
  for +bs: List<&2, String>
  Bool

# Module: src/core/normalize.bend:458
law norm_cmp_zip:
  for +as: List<&2, KTerm>
  for +bs: List<&2, KTerm>
  for +fresh: U32
  for +rest: List<&2, KNormCmp>
  List<&2, KNormCmp>

# Module: src/core/normalize.bend:542
law g_put_node:
  for +old: KTerm
  for +left: GHeap
  for +right: GHeap
  for +id: U32
  for +value: KTerm
  GHeap

# Module: src/core/graph.bend:34
law kp_index:
  for env: List<&2, KPName>
  for +id: U32
  U32

# Module: src/core/pretty.bend:15
law kp_has_removed:
  for xs: List<&2, String>
  Bool

# Module: src/core/pretty.bend:19
law kp_digit:
  for +n: U32
  String

# Module: src/core/pretty.bend:27
law kp_append:
  for a: Maybe<&2, String>
  for b: Maybe<&2, String>
  Maybe<&2, String>

# Module: src/core/pretty.bend:37
law kp_array_join:
  for a: Maybe<&2, List<&2, KTerm>>
  for b: Maybe<&2, List<&2, KTerm>>
  Maybe<&2, List<&2, KTerm>>

# Module: src/core/pretty.bend:42
law kp_float_point:
  for s: String
  String

# Module: src/core/pretty.bend:97
law terms_tail:
  for +ts: List<&2, KTerm>
  List<&2, KTerm>

# Module: src/check/quantity.bend:31
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
law f_ascii_char_eq:
  for +a: Char
  for +b: Char
  Bool

# Module: src/front/lexer.bend:27
law f_ascii_alpha:
  for +c: Char
  Bool

# Module: src/front/lexer.bend:31
law f_ascii_digit:
  for +c: Char
  Bool

# Module: src/front/lexer.bend:35
law f_ascii_ident_code:
  for +code: U32
  Bool

# Module: src/front/lexer.bend:43
law f_ascii_space_code:
  for +code: U32
  Bool

# Module: src/front/parser.bend:6
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
law ff_field_cons:
  for +p: KTerm
  for +r: FFields
  FFields

# Module: src/front/flatten.bend:72
law f_tail_terms:
  for +xs: List<&2, KTerm>
  List<&2, KTerm>

# Module: src/front/elaborate.bend:12
law f_has_id:
  for +vars: List<&2, KTerm>
  for +id: U32
  Bool

# Module: src/front/elaborate.bend:27
law f_escape_valid:
  for +c: Char
  Bool

# Module: src/front/unicode.bend:17
law ffw_reverse_onto:
  for +items: List<&2,KTerm>
  for +onto: List<&2,KTerm>
  List<&2,KTerm>

# Module: src/front/fresh_work.bend:141
law f_fresh_result_end:
  for +r: FFreshDefs
  for +err: String
  for +imports: List<&2, KTerm>
  FResult

# Module: src/load/paths.bend:3
law f_graph_error:
  for +g: FGraph
  for +err: String
  FGraph

# Module: src/load/graph.bend:59
law f_graph_count_defs:
  for +book: List<&2,KDef>
  for +count: U32
  U32

# Module: src/load/graph.bend:282
law f_seed_text_equal:
  for +a: String
  for +b: String
  Bool

# Module: src/load/modules.bend:12
law f_source_name:
  for +source: FSource
  String

# Module: src/load/modules.bend:26
law f_source_text:
  for +source: FSource
  String

# Module: src/load/modules.bend:30
law f_source_path:
  for +source: FSource
  String

# Module: src/load/prefix.bend:9
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
law dg_result_error:
  for +result: DResult
  String

# Module: src/back/common/literals.bend:6
law j_strip:
  for +t: KTerm
  KTerm

# Module: src/back/common/literals.bend:14
law j_body:
  for +xs: List<&2, KTerm>
  KTerm

# Module: src/back/common/queries.bend:85
law j_word_text:
  for +value: Maybe<&2, U32>
  for +float: Bool
  String

# Module: src/back/js/literals.bend:40
law j_char_text:
  for +value: Maybe<&2, U32>
  String

# Module: src/back/js/literals.bend:52
law j_nat_text:
  for +value: Maybe<&2, Nat>
  String

# Module: src/back/js/literals.bend:74
law j_l_names:
  for +names: List<&2, String>
  String

# Module: src/back/native/text.bend:74
law nc_ctor_codes:
  for +name: String
  String

# Module: src/back/native/identity.bend:19
law nc_occurs:
  for +t: KTerm
  for +id: U32
  Bool

# Module: src/back/native/bridge.bend:505
law nc_unann:
  for +t: KTerm
  KTerm

# Module: src/back/native/book.bend:25
law dr_count:
  for names: List<&2,String>
  U32

# Module: src/driver/report.bend:29
law driver_holes:
  for +t: KTerm
  U32

# Module: src/driver/api.bend:53
law driver_holes_terms:
  for +ts: List<&2,KTerm>
  U32

# Module: src/driver/api.bend:65
@unsafe
def kc(
  -A: Type,
  +b: Bool,
  yes: Unit -> A,
  no: Unit -> A,
) -> A:
  match b:
    case True{}:
      yes(Unit{})
    case False{}:
      no(Unit{})

# Module identity uses ns:name; only external output replaces its first colon.

# Module: src/core/term.bend:18
@unsafe
def name_key(+name: String) -> String:
  match name:
    case SNil{}: ""
    case SCon{c, rest}: kc(String, Char.is_eq(c, ':'), u => "." ++ rest, u => SCon{c, name_key(rest)})

# First-order trusted core. Binder identifiers are globally unique.
# Quantities: 0 erased, 1 affine, 2 unrestricted. No function-valued fields.

# Module: src/core/term.bend:36
@unsafe
def kt(
  +tag: String,
  +name: String,
  +id: U32,
  +quant: U32,
  +kids: List<&2, KTerm>,
) -> KTerm:
  KTerm{tag, name, id, quant, kids, Nil{}, 0, 0}

# Module: src/core/term.bend:46
@unsafe
def atom(
  +tag: String,
) -> KTerm:
  kt(tag, "", 0, 0, Nil{})

# Module: src/core/term.bend:52
@unsafe
def tg(
  +t: KTerm,
) -> String:
  match t:
    case KTerm{tag, name, id, quant, kids, removed, originBegin, originEnd}:
      tag
    case KLambda{name, id, quant, kids, removed, begin, end, present}:
      "Lam"
    case KLiteral{kind, number, text, literalBegin, literalEnd}:
      "Lit"

# Module: src/core/term.bend:64
@unsafe
def nm(
  +t: KTerm,
) -> String:
  match t:
    case KTerm{tag, name, id, quant, kids, removed, originBegin, originEnd}:
      name
    case KLambda{name, id, quant, kids, removed, begin, end, present}:
      name
    case KLiteral{kind, number, text, literalBegin, literalEnd}:
      kind

# Module: src/core/term.bend:76
@unsafe
def ix(
  +t: KTerm,
) -> U32:
  match t:
    case KTerm{tag, name, id, quant, kids, removed, originBegin, originEnd}:
      id
    case KLambda{name, id, quant, kids, removed, begin, end, present}:
      id
    case KLiteral{kind, number, text, literalBegin, literalEnd}:
      0

# Module: src/core/term.bend:88
@unsafe
def qt(
  +t: KTerm,
) -> U32:
  match t:
    case KTerm{tag, name, id, quant, kids, removed, originBegin, originEnd}:
      quant
    case KLambda{name, id, quant, kids, removed, begin, end, present}:
      quant
    case KLiteral{kind, number, text, literalBegin, literalEnd}:
      0

# Module: src/core/term.bend:100
@unsafe
def ks(
  +t: KTerm,
) -> List<&2, KTerm>:
  match t:
    case KTerm{tag, name, id, quant, kids, removed, originBegin, originEnd}:
      kids
    case KLambda{name, id, quant, kids, removed, begin, end, present}:
      kids
    case KLiteral{kind, number, text, literalBegin, literalEnd}:
      Nil{}

# Module: src/core/term.bend:112
@unsafe
def rm(
  +t: KTerm,
) -> List<&2, String>:
  match t:
    case KTerm{tag, name, id, quant, kids, removed, originBegin, originEnd}:
      removed
    case KLambda{name, id, quant, kids, removed, begin, end, present}:
      removed
    case KLiteral{kind, number, text, literalBegin, literalEnd}:
      Nil{}

# AGY-W5B-C2-IR
# Module: src/core/term.bend:124
law terms_at:
  for +ts: List<&2, KTerm>
  for +n: U32
  KTerm

@unsafe
def w5c2_terms_at_if(z: Bool, +h: KTerm, +t: List<&2, KTerm>, +n: U32) -> KTerm:
  match z:
    case True{}: h
    case False{}: terms_at(t, U32.sub(n, 1))

@unsafe
def terms_at(ts, n):
  match ts:
    case Nil{}:
      {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}
    case Con{h, t}:
      w5c2_terms_at_if(U32.is_eq(n, 0), h, t, n)

# Module: src/core/term.bend:135
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
def missing() -> KDef:
  KDef{"", "Absent", 0, 0,
    KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0},
    KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0},
    Nil{}, False{}, False{}}

@unsafe
def terms_len(
  +ts: List<&2, KTerm>,
) -> U32:
  match ts:
    case Nil{}:
      0
    case Con{h, t}:
      U32.add(1, terms_len(t))

# Module: src/core/term.bend:321
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
def norm_join(
  +a: List<&2, KTerm>,
  +b: List<&2, KTerm>,
) -> List<&2, KTerm>:
  match a:
    case Nil{}:
      b
    case Con{h, t}:
      Con{h, norm_join(t, b)}

# Module: src/core/term.bend:507
@unsafe
def norm_defs_join(a, b):
  match a:
    case Nil{}:
      b
    case Con{h, rest}:
      Con{h, norm_defs_join(rest, b)}


# Numeric and string values retain source literal identity until demanded.

# Module: src/core/term.bend:517
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
def kb(+t: KTerm) -> U32:
  match t:
    case KTerm{tag, name, id, quant, kids, removed, originBegin, originEnd}:
      originBegin
    case KLambda{name, id, quant, kids, removed, begin, end, present}:
      begin
    case KLiteral{kind, number, text, literalBegin, literalEnd}:
      literalBegin

# Module: src/core/term.bend:567
@unsafe
def ke(+t: KTerm) -> U32:
  match t:
    case KTerm{tag, name, id, quant, kids, removed, originBegin, originEnd}:
      originEnd
    case KLambda{name, id, quant, kids, removed, begin, end, present}:
      end
    case KLiteral{kind, number, text, literalBegin, literalEnd}:
      literalEnd

# Replace only semantic children; every other immutable field is preserved.

# Module: src/core/term.bend:582
@unsafe
def k_with_children(+t: KTerm, +newKids: List<&2,KTerm>) -> KTerm:
  match t:
    case KTerm{tag, name, id, quant, oldKids, removed, originBegin, originEnd}:
      KTerm{tag, name, id, quant, newKids, removed, originBegin, originEnd}

# Explicit replacement does not guess or inherit an occurrence.
    case KLambda{name, id, quant, kids, removed, begin, end, present}:
      KLambda{name, id, quant, newKids, removed, begin, end, present}
    case KLiteral{kind, number, text, literalBegin, literalEnd}:
      t

# Module: src/core/term.bend:594
@unsafe
def k_with_span(+t: KTerm, +newBegin: U32, +newEnd: U32) -> KTerm:
  match t:
    case KTerm{tag, name, id, quant, kids, removed, oldBegin, oldEnd}:
      KTerm{tag, name, id, quant, kids, removed, newBegin, newEnd}
    case KLambda{name, id, quant, kids, removed, begin, end, present}:
      KLambda{name, id, quant, kids, removed, newBegin, newEnd, present}
    case KLiteral{kind, number, text, literalBegin, literalEnd}:
      KLiteral{kind, number, text, newBegin, newEnd}

# Module: src/core/term.bend:604
@unsafe
def kt_span(+tag: String, +name: String, +id: U32, +quant: U32,
  +kids: List<&2,KTerm>, +begin: U32, +end: U32) -> KTerm:
  KTerm{tag, name, id, quant, kids, Nil{}, begin, end}

# Interpreted literal leaves are closed; payload is never a binder or quantity.

# Module: src/core/term.bend:610
@unsafe
def core_literal(+t: KTerm) -> Bool:
  match t:
    case KTerm{tag, name, id, quant, kids, removed, begin, end}: False{}
    case KLambda{name, id, quant, kids, removed, begin, end, present}:
      False{}
    case KLiteral{kind, number, text, begin, end}: True{}

# Module: src/core/term.bend:618
@unsafe
def kl_number(+t: KTerm) -> U32:
  match t:
    case KTerm{tag, name, id, quant, kids, removed, begin, end}: 0
    case KLambda{name, id, quant, kids, removed, begin, end, present}:
      0
    case KLiteral{kind, number, text, begin, end}: number

# Module: src/core/term.bend:626
@unsafe
def kl_text(+t: KTerm) -> String:
  match t:
    case KTerm{tag, name, id, quant, kids, removed, begin, end}: ""
    case KLambda{name, id, quant, kids, removed, begin, end, present}:
      ""
    case KLiteral{kind, number, text, begin, end}: text

# Module: src/core/term.bend:634
@unsafe
def kl_make(+kind: String, +number: U32, +text: String) -> KTerm:
  KLiteral{kind, number, text, 0, 0}

# Quantity presence is explicit syntax metadata on Lambda only. Ordinary term
# allocation remains unchanged; legacy KTerm/Lam inputs supplied a quantity.

# Module: src/core/term.bend:640
@unsafe
def k_lam(+name: String, +id: U32, +quant: U32, +kids: List<&2,KTerm>, +begin: U32, +end: U32, +present: Bool) -> KTerm:
  KLambda{name, id, quant, kids, Nil{}, begin, end, present}

# Module: src/core/term.bend:644
@unsafe
def k_quantity_present(+t: KTerm) -> Bool:
  match t:
    case KTerm{tag, name, id, quant, kids, removed, begin, end}: p88_string_eq(tag, "Lam")
    case KLambda{name, id, quant, kids, removed, begin, end, present}: present
    case KLiteral{kind, number, text, begin, end}: False{}

# Field-changing structural rebuilds retain the input variant and syntax fact.

# Module: src/core/term.bend:652
@unsafe
def k_rebuild(+t: KTerm, +name: String, +id: U32, +quant: U32, +kids: List<&2,KTerm>, +removed: List<&2,String>, +begin: U32, +end: U32) -> KTerm:
  match t:
    case KTerm{tag, oldName, oldId, oldQuant, oldKids, oldRemoved, oldBegin, oldEnd}:
      KTerm{tag, name, id, quant, kids, removed, begin, end}
    case KLambda{oldName, oldId, oldQuant, oldKids, oldRemoved, oldBegin, oldEnd, present}:
      KLambda{name, id, quant, kids, removed, begin, end, present}
    case KLiteral{kind, number, text, oldBegin, oldEnd}: t

# Module: src/core/index.bend:26
@unsafe
def index_hash(
  +name: String,
  +acc: U32,
) -> U32:
  match name:
    case SNil{}:
      acc
    case SCon{h, rest}:
      index_hash(rest, U32.mul(U32.xor(acc, Char.to_u32(h)), 16777619))

# Module: src/core/index.bend:37
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
def w9_pick_kdef(bit: U32, left: KDef, right: KDef) -> KDef:
  match bit:
    case 0: left
    case _: right

@unsafe
def w9_pick_kdef_b(goLeft: Bool, left: KDef, right: KDef) -> KDef:
  match goLeft:
    case True{}: left
    case False{}: right

# Module: src/core/index.bend:126
@unsafe
def index_split_bit(
  +diff: U32,
) -> U32:
  U32.and(diff, U32.sub(0, diff))

# Module: src/core/index.bend:175
@unsafe
def index_node(
  +hash: U32,
  +mask: U32,
  +left: KDef,
  +right: KDef,
) -> KDef:
  KIndexNode{hash, mask, left, right}

# Module: src/core/index.bend:192
@unsafe
def w7_char0(+s: String) -> U32:
  match s:
    case SNil{}:
      0
    case SCon{c, _}:
      Char.to_u32(c)

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
def book_final_reverse(book, done):
  match book:
    case Nil{}: done
    case Con{d, rest}: book_final_reverse(rest, Con{d, done})

# Module: src/core/index.bend:392
@unsafe
def w7_br_16(w7_c: Bool, +n: U32) -> U32:
  match w7_c:
    case True{}:
      0
    case False{}:
      U32.sub(n, 1)

@unsafe
def w7_br_27(w7_c: Bool, +a: KTerm, +b: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      kt("Min", "", 0, 0, Con{a, Con{b, Nil{}}})
    case False{}:
      b

@unsafe
def norm_max(
  +a: U32,
  +b: U32,
) -> U32:
  U32.max(a, b)

# Module: src/core/normalize.bend:230
@unsafe
def w7c_norm_max_terms(ts: List<&2, KTerm>, +bound: U32) -> U32:
  match ts:
    case Nil{}: bound
    case Con{h, rest}:
      w7c_norm_max_terms(rest, w7c_norm_max_term(h, bound))

@unsafe
def w7c_norm_max_term(+t: KTerm, +bound: U32) -> U32:
  w7c_norm_max_terms(ks(t), U32.max(bound, ix(t)))

@unsafe
def norm_names_len(names):
  match names:
    case Nil{}:
      0
    case Con{h, rest}:
      U32.add(1, norm_names_len(rest))

# The book checker computes this immutable bound once per source book. Public
# callers without a stamp retain the complete scan, so fresh IDs stay sound.

# Module: src/core/normalize.bend:353
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
def norm_cmp_zip(as, bs, fresh, rest):
  match as bs:
    case Con{a, ar} Con{b, br}:
      Con{KNormCmp{a, b, False{}, fresh}, norm_cmp_zip(ar, br, fresh, rest)}
    case other_a other_b:
      rest

# Module: src/core/normalize.bend:655
@unsafe
def g_heap(
  +st: GState,
) -> GHeap:
  match st:
    case GState{heap, next}:
      heap
    case GCompared{heap, next, classes}:
      heap

# Module: src/core/graph.bend:217
@unsafe
def g_next(
  +st: GState,
) -> U32:
  match st:
    case GState{heap, next}:
      next
    case GCompared{heap, next, classes}:
      next

# Every evaluation update preserves the comparison facts of this heap identity.
# Fresh GState constructors still start an independent, empty class relation.
@unsafe
def g_with_heap(+st: GState, +heap: GHeap, +next: U32) -> GState:
  match st:
    case GState{oldHeap,oldNext}: GState{heap,next}
    case GCompared{oldHeap,oldNext,classes}: GCompared{heap,next,classes}

@unsafe
def g_classes(+st: GState) -> GClasses:
  match st:
    case GState{heap,next}: GClassesEmpty{}
    case GCompared{heap,next,classes}: classes

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
def g_class_rank_entry(+entry: Maybe<&2,GClassEntry>) -> U32:
  match entry:
    case None{}: 0
    case Some{GClassEntry{parent,rank}}: rank

@unsafe
def g_state(
  +r: GResult,
) -> GState:
  match r:
    case GResult{state, term}:
      state

# Module: src/core/graph.bend:233
@unsafe
def g_term(
  +r: GResult,
) -> KTerm:
  match r:
    case GResult{state, term}:
      term

# Module: src/core/graph.bend:241
@unsafe
def g_states(
  +r: GTerms,
) -> GState:
  match r:
    case GTerms{state, terms}:
      state

# Module: src/core/graph.bend:249
@unsafe
def g_terms(
  +r: GTerms,
) -> List<&2, KTerm>:
  match r:
    case GTerms{state, terms}:
      terms

# Module: src/core/graph.bend:257
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
def g_put(
  +heap: GHeap,
  +id: U32,
  +value: KTerm,
) -> GHeap:
  match heap:
    case GEmpty{}:
      g_put_node({KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, GEmpty{}, GEmpty{}, id, value)
    case GNode{old, left, right}:
      g_put_node(old, left, right, id, value)

# Module: src/core/graph.bend:280
@unsafe
def w7_br_70(w7_c: Bool, +old: KTerm, +left: GHeap, +right: GHeap, +id: U32, +value: KTerm) -> GHeap:
  match w7_c:
    case True{}:
      GNode{old, g_put(left, U32.shr(id), value), right}
    case False{}:
      GNode{old, left, g_put(right, U32.shr(id), value)}

@unsafe
def w7_br_71(w7_c: Bool, +old: KTerm, +left: GHeap, +right: GHeap, +id: U32, +value: KTerm) -> GHeap:
  match w7_c:
    case True{}:
      GNode{value, left, right}
    case False{}:
      w7_br_70(U32.is_eq(U32.and(id, 1), 0), old, left, right, id, value)

@unsafe
def g_put_node(old, left, right, id, value):
  w7_br_71(U32.is_eq(id, 0), old, left, right, id, value)

# Module: src/core/graph.bend:284
@unsafe
def kp_eq(
  +a: String,
  +b: String,
) -> Bool:
  p88_string_eq(a, b)

# Module: src/core/pretty.bend:144
@unsafe
def w7_br_95(w7_c: Bool) -> String:
  match w7_c:
    case True{}:
      "+"
    case False{}:
      ""

@unsafe
def kp_join(
  xs: List<&2, String>,
  +sep: String,
) -> String:
  match xs:
    case Nil{}: ""
    case Con{h, Nil{}}: h
    case Con{h, t}: h ++ sep ++ kp_join(t, sep)

# Module: src/core/pretty.bend:168
@unsafe
def w7_br_97(w7_c: Bool, +s: String) -> String:
  match w7_c:
    case True{}:
      "(" ++ s ++ ")"
    case False{}:
      s

@unsafe
def kp_index(env, id):
  match env:
    case Nil{}: id
    case Con{KPFile{ns, aliases}, tail}: kp_index(tail, id)
    case Con{KPName{n, +i, +depth}, +tail}:
      kc(U32, U32.is_eq(i, id), u => depth, u => kp_index(tail, id))

# Module: src/core/pretty.bend:222
@unsafe
def kp_depth(
  env: List<&2, KPName>,
) -> U32:
  match env:
    case Nil{}: 0
    case Con{KPFile{ns, aliases}, t}: kp_depth(t)
    case Con{KPName{n, i, depth}, t}: U32.add(1, kp_depth(t))

# Module: src/core/pretty.bend:231
@unsafe
def kp_has_removed(xs):
  match xs:
    case Nil{}: False{}
    case Con{h,t}: True{}

# Module: src/core/pretty.bend:308
@unsafe
def kp_float(
  n: U32,
) -> F32:
  match n:
    case U32{w}: F32{w}

# Module: src/core/pretty.bend:333
@unsafe
def kp_digit(n):
  Char.show(Char.from_u32(kc(U32, U32.is_lt(n, 10), u => U32.add(n, 48), u => U32.add(n, 87))))

# Module: src/core/pretty.bend:353
@unsafe
def kp_append(a, b):
  match a b:
    case Some{x} Some{y}: Some{x ++ y}
    case _ _: None{}

# Module: src/core/pretty.bend:392
@unsafe
def kp_array_join(a, b):
  match a b:
    case Some{x} Some{y}: Some{List.append(&2, KTerm, x, y)}
    case _ _: None{}

# Module: src/core/pretty.bend:436
@unsafe
def kp_float_point(s):
  match s:
    case SNil{}: ".0"
    case SCon{+h, +t}: kc(String, U32.is_eq(Char.to_u32(h), 101), u => ".0e" ++ t, u => Char.show(h) ++ kp_float_point(t))

# Module: src/core/pretty.bend:522
@unsafe
def w7_br_141(w7_c: Bool, +a: U32) -> U32:
  match w7_c:
    case True{}:
      a
    case False{}:
      2

@unsafe
def w7_br_143(w7_c: Bool, +a: U32, +b: U32) -> U32:
  match w7_c:
    case True{}:
      a
    case False{}:
      b

@unsafe
def w7_br_144(w7_c: Bool, +d: U32) -> U32:
  match w7_c:
    case True{}:
      0
    case False{}:
      d

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
def w7_br_146(w7_c: Bool) -> U32:
  match w7_c:
    case True{}:
      1
    case False{}:
      2

@unsafe
def terms_tail(ts):
  match ts:
    case Nil{}:
      Nil{}
    case Con{h, t}:
      t

# Module: src/check/quantity.bend:150
@unsafe
def cn(
  +e: KEnv,
) -> String:
  match e:
    case KEnv{world, name, lhs, pending, quantities, unsafe, depth}:
      name

# Module: src/check/kernel.bend:481
@unsafe
def cl(
  +e: KEnv,
) -> KTerm:
  match e:
    case KEnv{world, name, lhs, pending, quantities, unsafe, depth}:
      lhs

# Module: src/check/kernel.bend:489
@unsafe
def cp(
  +e: KEnv,
) -> U32:
  match e:
    case KEnv{world, name, lhs, pending, quantities, unsafe, depth}:
      pending

# Module: src/check/kernel.bend:497
@unsafe
def cq(
  +e: KEnv,
) -> List<&2, KTerm>:
  match e:
    case KEnv{world, name, lhs, pending, quantities, unsafe, depth}:
      quantities

# Module: src/check/kernel.bend:505
@unsafe
def cu(
  +e: KEnv,
) -> Bool:
  match e:
    case KEnv{world, name, lhs, pending, quantities, unsafe, depth}:
      unsafe

# Module: src/check/kernel.bend:513
@unsafe
def ok(
  +world: KWorld,
  +t: KTerm,
  +ty: KTerm,
  +us: List<&2, KTerm>,
) -> KChecking:
  KChecking{t, ty, us, "", world, 0}

# Module: src/check/kernel.bend:554
@unsafe
def bad(
  +world: KWorld,
  +msg: String,
) -> KChecking:
  KChecking{{KTerm{"Error", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, {KTerm{"Error", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Nil{}, msg, world, 0}

# Module: src/check/kernel.bend:561
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
def w7_br_156(w7_c: Bool, +q: U32) -> U32:
  match w7_c:
    case True{}:
      1
    case False{}:
      q

@unsafe
def defs_empty(
  +ds: List<&2, KDef>,
) -> Bool:
  match ds:
    case Nil{}:
      True{}
    case Con{h, t}:
      False{}

# Module: src/check/kernel.bend:810
@unsafe
def w7_br_189(w7_c: Bool, +n: U32) -> String:
  match w7_c:
    case True{}:
      ""
    case False{}:
      U32.show(n) ++ " TODO" ++ kc(String, U32.is_eq(n, 1), u => "", u => "s") ++ " found.\nThe code is incomplete, and not a valid proof yet."

@unsafe
def w7_br_193(w7_c: Bool) -> String:
  match w7_c:
    case True{}:
      ""
    case False{}:
      "definition does not match prior law signature"

@unsafe
def kw_initial(+book: List<&2,KDef>) -> KWorld:
  KWorld{book, Nil{}, KFreshDeferred{Nil{}}, Nil{}}

# Module: src/check/kernel.bend:1209
@unsafe
def cw(+e: KEnv) -> KWorld:
  match e:
    case KEnv{world, name, lhs, pending, quantities, unsafe, depth}: world

# Module: src/check/kernel.bend:1233
@unsafe
def cd(+e: KEnv) -> U32:
  match e:
    case KEnv{world, name, lhs, pending, quantities, unsafe, depth}: depth

# Module: src/check/kernel.bend:1238
@unsafe
def kw_seed(+book: List<&2,KDef>, +bound: U32) -> KWorld:
  KWorld{book, Nil{}, kc(KWorldFresh, U32.is_eq(bound, 4294967295), u => KFreshDeferred{Nil{}}, u => KFreshKnown{U32.add(bound, 1)}), Nil{}}

# Module: src/check/kernel.bend:1270
@unsafe
def ki_reverse_terms(+xs: List<&2,KTerm>, +out: List<&2,KTerm>) -> List<&2,KTerm>:
  match xs:
    case Nil{}: out
    case Con{h, rest}: ki_reverse_terms(rest, Con{h, out})

# Module: src/check/kernel.bend:1345
@unsafe
def env_tele_many(+args: List<&2,KTerm>) -> Bool:
  match args:
    case Nil{}: False{}
    case Con{h, rest}: Bool.not(List.is_empty(&2, KTerm, rest))

# Module: src/check/env-telescope.bend:58
@unsafe
def env_subst_reverse(+bindings: List<&2,KTelescopeBinding>, +out: List<&2,KTelescopeBinding>) -> List<&2,KTelescopeBinding>:
  match bindings:
    case Nil{}: out
    case Con{binding, rest}: env_subst_reverse(rest, Con{binding, out})

# Module: src/check/env-substitution.bend:29
@unsafe
def sp_mtemplate(
  +m: KSpecMemo,
) -> String:
  match m:
    case KSpecMemo{template, key, name, active}:
      template

# Module: src/check/specialize.bend:70
@unsafe
def sp_mkey(
  +m: KSpecMemo,
) -> String:
  match m:
    case KSpecMemo{template, key, name, active}:
      key

# Module: src/check/specialize.bend:78
@unsafe
def sp_mname(
  +m: KSpecMemo,
) -> String:
  match m:
    case KSpecMemo{template, key, name, active}:
      name

# Module: src/check/specialize.bend:86
@unsafe
def sp_active(
  +m: KSpecMemo,
) -> Bool:
  match m:
    case KSpecMemo{template, key, name, active}:
      active

# Module: src/check/specialize.bend:94
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
def prefix_state_join(+left: List<&2,KDef>, +right: List<&2,KDef>) -> List<&2,KDef>:
  match left:
    case Nil{}: right
    case Con{h, rest}: Con{h, prefix_state_join(rest, right)}

# Module: src/check/prefix-state.bend:21
@unsafe
def prefix_state_variant(+t: KTerm) -> U32:
  match t:
    case KTerm{tag, name, id, quant, kids, removed, begin, end}: 0
    case KLambda{name, id, quant, kids, removed, begin, end, present}: 1
    case KLiteral{kind, number, text, begin, end}: 2

# Unlike conversion/reflexivity, the snapshot key retains source intervals too.

# Module: src/check/prefix-state.bend:29
@unsafe
def w7_br_279(w7_c: Bool, +b: Bool) -> Bool:
  match w7_c:
    case True{}:
      b
    case False{}:
      Bool.not(b)

@unsafe
def base_prefix_world_bound(+state: KBasePrefixState) -> U32:
  match state:
    case KBasePrefixState{bound, delta, stamp, patches, ready}: bound

# Module: src/check/prefix-state.bend:381
@unsafe
def base_prefix_context_drop(+book: List<&2,KDef>, +prefix: List<&2,KDef>) -> KBasePrefixTail:
  match prefix:
    case Nil{}: KBasePrefixTail{book, True{}}
    case Con{d, rest}: base_prefix_context_drop_head(book, rest)

# Module: src/check/prefix-state.bend:444
@unsafe
def base_prefix_context_drop_head(+book: List<&2,KDef>, +prefix: List<&2,KDef>) -> KBasePrefixTail:
  match book:
    case Nil{}: KBasePrefixTail{Nil{}, False{}}
    case Con{d, rest}: base_prefix_context_drop(rest, prefix)

# Module: src/check/prefix-state.bend:450
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
def w7b_lam_q_if(c: Bool, +q: U32) -> U32:
  match c:
    case True{}: 2
    case False{}: q

# Module: src/check/annotate.bend:210
@unsafe
def ka_field(+annotated: KTerm, +quantity: U32) -> KTerm:
  kt("Ann", "", 1, quantity, ks(annotated))

# Module: src/front/lexer.bend:48
@unsafe
def f_choose(
  -A: Type,
  +b: Bool,
  yes: Unit -> A,
  no: Unit -> A,
) -> A:
  match b:
    case True{}:
      yes(Unit{})
    case False{}:
      no(Unit{})

# Module: src/front/lexer.bend:61
@unsafe
def f_eq(
  +a: String,
  +b: String,
) -> Bool:
  agy_str_eq(a, b)

# Module: src/front/lexer.bend:68
@unsafe
def f_raw_tx(
  +ts: List<&2, FToken>,
) -> String:
  match ts:
    case Nil{}:
      "<eof>"
    case Con{FToken{t, l, c, k, begin, end, previousEnd}, rest}:
      t

# Module: src/front/lexer.bend:78
@unsafe
def f_raw_tl(
  +ts: List<&2, FToken>,
) -> List<&2, FToken>:
  match ts:
    case Nil{}:
      Nil{}
    case Con{t, rest}:
      rest

# Module: src/front/lexer.bend:88
@unsafe
def f_raw_line(
  +ts: List<&2, FToken>,
) -> U32:
  match ts:
    case Nil{}:
      0
    case Con{FToken{t, l, c, k, begin, end, previousEnd}, rest}:
      l

# Module: src/front/lexer.bend:98
@unsafe
def f_raw_col(
  +ts: List<&2, FToken>,
) -> U32:
  match ts:
    case Nil{}:
      0
    case Con{FToken{t, l, c, k, begin, end, previousEnd}, rest}:
      c

# Module: src/front/lexer.bend:108
@unsafe
def f_raw_kind(
  +ts: List<&2, FToken>,
) -> U32:
  match ts:
    case Nil{}:
      0
    case Con{FToken{t, l, c, k, begin, end, previousEnd}, rest}:
      k

# Module: src/front/lexer.bend:118
@unsafe
def f_head(
  +s: String,
) -> Char:
  match s:
    case SNil{}:
      '\0'
    case SCon{h, t}:
      h

# Module: src/front/lexer.bend:135
@unsafe
def f_tail(
  +s: String,
) -> String:
  match s:
    case SNil{}:
      ""
    case SCon{h, t}:
      t

# Module: src/front/lexer.bend:145
@unsafe
def w7_br_300(w7_c: Bool, +offset: U32, +size: U32) -> U32:
  match w7_c:
    case True{}:
      0
    case False{}:
      U32.add(offset, size)

@unsafe
def f_raw_begin(+ts: List<&2,FToken>) -> U32:
  match ts:
    case Nil{}: 0
    case Con{FToken{text, line, column, kind, begin, end, previousEnd}, rest}: begin

# Module: src/front/lexer.bend:199
@unsafe
def f_raw_end(+ts: List<&2,FToken>) -> U32:
  match ts:
    case Nil{}: 0
    case Con{FToken{text, line, column, kind, begin, end, previousEnd}, rest}: end

# Module: src/front/lexer.bend:205
@unsafe
def f_raw_previous_end(+ts: List<&2,FToken>) -> U32:
  match ts:
    case Nil{}: 0
    case Con{FToken{text, line, column, kind, begin, end, previousEnd}, rest}: previousEnd
# Private lexer producer: exact FToken output, unchanged parser consumers.
# SNil alone ends input; an actual NUL remains a one-character symbol.
@unsafe
def w7_lex_eof(isZero: Bool, +acc: List<&2, FToken>, +offset: U32, +previous: U32) -> List<&2, FToken>:
  match isZero:
    case True{}:
      List.reverse(&2, FToken, acc)
    case False{}:
      List.reverse(&2, FToken, Con{FToken{"<eof>", 0, 0, 0, offset, offset, previous}, acc})

@unsafe
def p150l_unterminated(l: U32, c: U32, acc: List<&2,FToken>, +offset: U32, previous: U32) -> List<&2,FToken>:
  List.reverse(&2,FToken,Con{FToken{"unterminated string",l,c,3,offset,offset,previous},acc})

# Exact three-character dispatch precedes dot-word scanning. Only accepted
# operators construct token text; lookahead compares scalar character values.
@unsafe
def p150l_edge_text(text: String, +column: U32, last: Char) -> P150LEdge:
  match text:
    case SNil{}: P150LEdge{column,Char.is_eq(last,'n')}
    case SCon{head,rest}: p150l_edge_text(rest,U32.add(column,1),head)

@unsafe
def f_ascii_char_eq(a, b):
  U32.is_eq(Char.to_u32(a), Char.to_u32(b))

# Module: src/front/lexer.bend:296
@unsafe
def f_ascii_alpha(c):
  U32.is_le(U32.sub(U32.or(Char.to_u32(c), 32), 97), 25)

# Module: src/front/lexer.bend:300
@unsafe
def f_ascii_digit(c):
  U32.is_le(U32.sub(Char.to_u32(c), 48), 9)

# Module: src/front/lexer.bend:304
@unsafe
def f_ascii_ident_code(code):
  U32.is_le(U32.sub(U32.or(code, 32), 97), 25) || U32.is_le(U32.sub(code, 48), 9) || U32.is_eq(code, 95) || U32.is_eq(code, 46)

# Module: src/front/lexer.bend:312
@unsafe
def f_ascii_space_code(code):
  U32.is_eq(code, 32) || U32.is_le(U32.sub(code, 9), 4)

# Header and argument whitespace preserves statement semicolons.

# Module: src/front/lexer.bend:317
@unsafe
def f_empty(+input: FInput) -> FInput:
  match input:
    case FInput{tokens, context}: FInput{Nil{}, context}

# Module: src/front/lexer.bend:338
@unsafe
def f_prepend(+token: FToken, +input: FInput) -> FInput:
  match input:
    case FInput{tokens, context}: FInput{Con{token, tokens}, context}

# Module: src/front/lexer.bend:343
@unsafe
def f_tl(+input: FInput) -> FInput:
  match input:
    case FInput{tokens, context}:
      match tokens:
        case Nil{}: input
        case Con{token, rest}: FInput{rest, context}

# Module: src/front/lexer.bend:386
@unsafe
def f_context_close(+input: FInput, +outer: List<&2,KTerm>) -> FInput:
  match input:
    case FInput{tokens, context}:
      match context:
        case FParseContext{scope, env, next}: FInput{tokens, FParseContext{scope, outer, next}}

# Module: src/front/contextual.bend:50
@unsafe
def f_context_rewind(+old: FInput, +input: FInput) -> FInput:
  match old:
    case FInput{tokens, ignored}:
      match input:
        case FInput{discarded, context}: FInput{tokens, context}

# Module: src/front/contextual.bend:57
@unsafe
def f_context_stop(+term: KTerm) -> Bool:
  p98_tag_eq(term, "Error")

# Module: src/front/contextual.bend:68
@unsafe
def f_context_failure_rest(+start: FInput, +end: FInput) -> FInput:
  end

# Module: src/front/contextual.bend:86
@unsafe
def w7_br_304(w7_c: Bool, +term: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      kt_span("FComputedHead", "", 0, 1, [term], kb(term), ke(term))
    case False{}:
      term

@unsafe
def f_context_flat_done(+input: FInput, +flat: FFlatten) -> FParsed:
  match input:
    case FInput{tokens, context}:
      match context:
        case FParseContext{scope, env, next}:
          match flat:
            case FFlatten{body, after}: FParsed{body, FInput{tokens, FParseContext{scope, env, after}}}

# Module: src/front/contextual.bend:245
@unsafe
def f_context_enter(+input: FInput, +scope: FParseScope) -> FInput:
  match input:
    case FInput{tokens, context}:
      match scope:
        case FParseScope{prior, index, ctorIndex, ns, aliases, +p144p_view}: FInput{tokens, FParseContext{scope, Nil{}, 0}}

# Module: src/front/contextual.bend:311

@unsafe
def f_context_outer(+input: FInput) -> List<&2,KTerm>:
  match input:
    case FInput{tokens, context}:
      match context:
        case FParseContext{scope, env, next}: env

# Module: src/front/contextual.bend:324
@unsafe
def f_context_scope(+input: FInput, +scope: FParseScope) -> FInput:
  match input:
    case FInput{tokens, context}:
      match context:
        case FParseContext{old, env, next}: FInput{tokens, FParseContext{scope, env, next}}

# Module: src/front/contextual.bend:498
@unsafe
def f_pn(
  +p: FParsed,
) -> KTerm:
  match p:
    case FParsed{n, ts}:
      n

# Module: src/front/parser.bend:148
@unsafe
def f_pr(
  +p: FParsed,
) -> FInput:
  match p:
    case FParsed{n, ts}:
      ts

# Module: src/front/parser.bend:156
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
def w7_br_321(w7_c: Bool) -> U32:
  match w7_c:
    case True{}:
      2
    case False{}:
      1

@unsafe
def f_list_nodes(xs, con, nil):
  match xs:
    case Nil{}:
      kt("Ctr", nil, 0, 1, Nil{})
    case Con{x, xt}:
      kt("Ctr", con, 0, 1, [x, f_list_nodes(xt, con, nil)])

# Module: src/front/parser.bend:367
@unsafe
def w7_br_326(w7_c: Bool) -> U32:
  match w7_c:
    case True{}:
      12
    case False{}:
      0

@unsafe
def w7_br_343(w7_c: Bool, +s: String) -> String:
  match w7_c:
    case True{}:
      ".xor"
    case False{}:
      s

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
def f_result(
  +book: List<&2, KDef>,
  +err: KTerm,
  +imports: List<&2, KTerm>,
) -> FRawResult:
  FRawResult{List.reverse(&2, KDef, book), err, List.reverse(&2, KTerm, imports)}

# Module: src/front/declarations.bend:242
@unsafe
def f_parse_scope_empty() -> FParseScope:
  FParseScope{Nil{}, missing(), missing(), "", Nil{}, None{}}

# Module: src/front/declarations.bend:681

@unsafe
def ff_field_cons(p, r):
  match r:
    case FFields{fields, next}:
      FFields{Con{p, fields}, next}

# Module: src/front/flatten.bend:166
@unsafe
def ff_failed(+term: KTerm) -> Bool:
  p98_tag_eq(term, "Error")

# Module: src/front/flatten.bend:188
@unsafe
def ff_variable(+term: KTerm) -> Bool:
  p98_tag_eq(term, "Var")

# Module: src/front/elaborate.bend:60
@unsafe
def f_tail_terms(xs):
  match xs:
    case Nil{}:
      Nil{}
    case Con{x, xt}:
      xt

# Module: src/front/elaborate.bend:76
@unsafe
def f_has_id(vars, id):
  match vars:
    case Nil{}:
      False{}
    case Con{v, vs}:
      U32.is_eq(ix(v), id) || f_has_id(vs, id)

# Module: src/front/elaborate.bend:126
@unsafe
def w7_br_419(w7_c: Bool, +c: Char) -> U32:
  match w7_c:
    case True{}:
      0
    case False{}:
      Char.to_u32(c)

@unsafe
def w7c_pat_val_pos(+t: KTerm, +begin: U32, +end: U32) -> KTerm:
  match t:
    case KTerm{tag, name, id, quant, kids, removed, oldBegin, oldEnd}:
      match kids:
        case Nil{}: KTerm{tag, name, id, quant, Nil{}, removed, begin, end}
        case Con{_, _}: KTerm{tag, name, id, quant, w7c_pat_vals_pos(kids, begin, end), removed, begin, end}
    case KLambda{name, id, quant, kids, removed, oldBegin, oldEnd, present}:
      match kids:
        case Nil{}: KLambda{name, id, quant, Nil{}, removed, begin, end, present}
        case Con{_, _}: KLambda{name, id, quant, w7c_pat_vals_pos(kids, begin, end), removed, begin, end, present}
    case KLiteral{kind, number, text, literalBegin, literalEnd}:
      KLiteral{kind, number, text, begin, end}

@unsafe
def w7c_pat_vals_pos(+terms: List<&2,KTerm>, +begin: U32, +end: U32) -> List<&2,KTerm>:
  match terms:
    case Nil{}: Nil{}
    case Con{head, rest}: Con{w7c_pat_val_pos(head, begin, end), w7c_pat_vals_pos(rest, begin, end)}

@unsafe
def f_escape_valid(c):
  Char.is_eq(c, 'n') || Char.is_eq(c, 't') || Char.is_eq(c, 'r') || Char.is_eq(c, '0') || Char.is_eq(c, '\\') || Char.is_eq(c, '\'') || Char.is_eq(c, '"')

# Module: src/front/unicode.bend:44
@unsafe
def w7_br_446(w7_c: Bool, +c: Char) -> U32:
  match w7_c:
    case True{}:
      U32.sub(Char.to_u32(Char.to_lower(c)), 87)
    case False{}:
      16

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
def w7_br_481(w7_c: Bool, +term: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      term
    case False{}:
      {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}

@unsafe
def w7c_lower_1_lam(stop: Bool, +name: String, +id: U32, +quant: U32, +r0: KTerm, +rem: List<&2,String>, +b: U32, +e: U32, +pres: Bool) -> KTerm:
  match stop:
    case True{}: r0
    case False{}: KLambda{name, id, quant, Con{r0, Nil{}}, rem, b, e, pres}

@unsafe
def w7c_lower_1_term(stop: Bool, +tag: String, +name: String, +id: U32, +quant: U32, +r0: KTerm, +rem: List<&2,String>, +b: U32, +e: U32) -> KTerm:
  match stop:
    case True{}: r0
    case False{}: KTerm{tag, name, id, quant, Con{r0, Nil{}}, rem, b, e}

@unsafe
def w7c_lower_2_b(stop: Bool, +tag: String, +name: String, +id: U32, +quant: U32, +r0: KTerm, +r1: KTerm, +rem: List<&2,String>, +b: U32, +e: U32) -> KTerm:
  match stop:
    case True{}: r1
    case False{}: KTerm{tag, name, id, quant, Con{r0, Con{r1, Nil{}}}, rem, b, e}

@unsafe
def ffw_reverse_onto(items, onto):
  match items:
    case Nil{}:
      onto
    case Con{head, tail}:
      ffw_reverse_onto(tail, Con{head, onto})

# Definition lists require the same explicit continuation discipline: computing
# the freshened tail before constructing its enclosing list consumes host stack
# even when each individual term is shallow. Constructor-definition lists share
# this worklist, so both declaration breadth and nested list depth are bounded
# by heap storage rather than JavaScript's call stack.

# Module: src/front/fresh_work.bend:175
@unsafe
def f_fresh_result_end(r, err, imports):
  match r:
    case FFreshDefs{book, next}:
      FResult{book, err, imports}

# Module: src/load/paths.bend:23
@unsafe
def w7_br_493(w7_c: Bool, +dir: String, +path: String) -> String:
  match w7_c:
    case True{}:
      path
    case False{}:
      dir ++ path

@unsafe
def f_graph_error(g, err):
  match g:
    case FGraph{book, old, done}:
      FGraph{book, err, done}

# Module: src/load/graph.bend:169
@unsafe
def f_graph_count_defs(book, count):
  match book:
    case Nil{}: count
    case Con{head, tail}: f_graph_count_defs(tail, U32.add(count, 1))

# Module: src/load/graph.bend:254
@unsafe
def w7_br_521(w7_c: Bool, +t: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}
    case False{}:
      t

@unsafe
def f_relative_parents(+root: List<&2,String>) -> String:
  match root:
    case Nil{}: ""
    case Con{part, rest}: "../" ++ f_relative_parents(rest)

# Module: src/load/graph.bend:429
@unsafe
def fs_path(
  +seed: FSeed,
) -> String:
  match seed:
    case FSeed{path, book, root}:
      path

# Module: src/load/seed.bend:92
@unsafe
def fs_book(
  +seed: FSeed,
) -> List<&2, KDef>:
  match seed:
    case FSeed{path, book, root}:
      book

# Module: src/load/seed.bend:100
@unsafe
def f_seed_text_equal(a, b):
  p88_string_eq(a, b)

# Module: src/load/seed.bend:154
@unsafe
def fs_root(+seed: FSeed) -> String:
  match seed:
    case FSeed{path, book, root}: root

# Module: src/load/modules.bend:35
@unsafe
def w7_br_535(w7_c: Bool, +name: String, +ns: String) -> String:
  match w7_c:
    case True{}:
      name
    case False{}:
      ns ++ ":" ++ name

@unsafe
def f_source_name(source):
  match source:
    case FSource{name, path, text}:
      name
    case FCompletedSource{name, path, text, parsed}:
      name
    case FLocatedSource{source, begin, end}:
      f_source_name(source)

# Module: src/load/modules.bend:93
@unsafe
def f_source_text(source):
  match source:
    case FSource{name, path, text}:
      text
    case FCompletedSource{name, path, text, parsed}:
      text
    case FLocatedSource{source, begin, end}:
      f_source_text(source)

# Module: src/load/modules.bend:103
@unsafe
def f_source_path(source):
  match source:
    case FSource{name, path, text}:
      path
    case FCompletedSource{name, path, text, parsed}:
      path
    case FLocatedSource{source, begin, end}:
      f_source_path(source)

# Location ownership is separate from text/completed source delivery.

# Module: src/load/modules.bend:125
@unsafe
def f_source_located(+source: FSource, +begin: U32, +end: U32) -> FSource:
  FLocatedSource{source, begin, end}

# Module: src/load/modules.bend:129
@unsafe
def f_source_begin(+source: FSource) -> U32:
  match source:
    case FSource{name, path, text}: 0
    case FCompletedSource{name, path, text, parsed}: 0
    case FLocatedSource{source, begin, end}: begin

# Module: src/load/modules.bend:136
@unsafe
def f_source_end(+source: FSource) -> U32:
  match source:
    case FSource{name, path, text}: 0
    case FCompletedSource{name, path, text, parsed}: 0
    case FLocatedSource{source, begin, end}: end

# Module: src/load/modules.bend:158
@unsafe
def f_header_result(+parsed: FResult, +body: String, +line: U32, +offset: U32) -> FHeader:
  match parsed:
    case FResult{book, error, imports}: FHeader{imports, error, body, line, offset}

# Module: src/load/modules.bend:191
@unsafe
def f_header_supplied(+parsed: FResult) -> FHeader:
  match parsed:
    case FResult{book, error, imports}: FHeader{imports, "", "", 1, 0}

# Module: src/load/modules.bend:210
@unsafe
def f_header_imports(+header: FHeader) -> List<&2,KTerm>:
  match header:
    case FHeader{imports, error, body, line, offset}: imports

# Module: src/load/modules.bend:215
@unsafe
def f_completion_graph(+completion: FCompletion) -> FGraph:
  match completion:
    case FCompletion{graph, parsed}: graph

# The host has already checked the immutable cache identity. Bind the supplied
# source again here; a seed cannot inject definitions for a different file.

# Module: src/load/modules.bend:276
@unsafe
def f_fresh_prefix_variant(+t: KTerm) -> U32:
  match t:
    case KTerm{tag, name, id, quant, kids, removed, begin, end}: 0
    case KLambda{name, id, quant, kids, removed, begin, end, present}: 1
    case KLiteral{kind, number, text, begin, end}: 2

# Unlike conversion equality, a loader snapshot retains variant, source spans
# and explicit Lambda quantity presence. Worklists avoid nested tree recursion.

# Module: src/load/prefix.bend:24
@unsafe
def f_prefix_graph_empty() -> FPrefixGraph:
  FPrefixGraph{FGraph{Nil{}, "", Nil{}}, Nil{}, Nil{}, 0, False{}}

# Module: src/load/prefix.bend:125
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
def w7_br_540(w7_c: Bool, +book: List<&2,KDef>, +count: U32) -> FFreshPrefixTail:
  match w7_c:
    case True{}:
      FFreshPrefixTail{book, True{}}
    case False{}:
      f_prefix_drop_next(book, count)

@unsafe
def f_prefix_drop(+book: List<&2,KDef>, +count: U32) -> FFreshPrefixTail:
  w7_br_540(U32.is_eq(count, 0), book, count)

# Module: src/load/prefix.bend:167
@unsafe
def f_prefix_drop_next(+book: List<&2,KDef>, +count: U32) -> FFreshPrefixTail:
  match book:
    case Nil{}: FFreshPrefixTail{Nil{}, False{}}
    case Con{d, rest}: f_prefix_drop(rest, U32.sub(count, 1))

# Module: src/load/prefix.bend:173
@unsafe
def f_prefix_source_tail(+graph: FGraph, +parsed: FResult, +prefix: List<&2,KDef>, +count: U32, +tail: FFreshPrefixTail) -> FPrefixCompletion:
  match tail:
    case FFreshPrefixTail{suffix, matched}: FPrefixCompletion{FPrefixGraph{graph, prefix, suffix, count, matched}, parsed}

# Module: src/load/prefix.bend:225
@unsafe
def w7_br_541(w7_c: Bool) -> U32:
  match w7_c:
    case True{}:
      2
    case False{}:
      1

@unsafe
def w7_br_542(w7_c: Bool, +n: U32) -> String:
  match w7_c:
    case True{}:
      ""
    case False{}:
      " " ++ dg_padding(U32.sub(n, 1))

@unsafe
def dg_padding(
  +n: U32,
) -> String:
  w7_br_542(U32.is_eq(n, 0), n)

# Module: src/diagnostic/render.bend:74
@unsafe
def dg_lines_count(
  +lines: List<&2, String>,
) -> U32:
  match lines:
    case Nil{}: 0
    case Con{h, rest}: U32.add(1, dg_lines_count(rest))

# Module: src/diagnostic/render.bend:96
@unsafe
def w7_br_543(w7_c: Bool, +count: U32) -> String:
  match w7_c:
    case True{}:
      ""
    case False{}:
      "^" ++ dg_carets(U32.sub(count, 1))

@unsafe
def dg_carets(
  +count: U32,
) -> String:
  w7_br_543(U32.is_eq(count, 0), count)

# Module: src/diagnostic/render.bend:121
@unsafe
def dg_import_tail(+text: String) -> Bool:
  match text:
    case SNil{}: True{}
    case SCon{head, rest}: Char.is_space(head)

# Module: src/diagnostic/trace.bend:46
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
def dg_no_report(
  +name: String,
  +message: String,
) -> DDiagnostic:
  DDiagnostic{DText{message}, DText{""}, False{}, Nil{}, name, DNoSpan{}, "", Nil{}}

# Module: src/diagnostic/trace.bend:108
@unsafe
def dg_has_span(+s: DSpan) -> Bool:
  match s:
    case DNoSpan{}: False{}
    case DSpan{source, begin, end}: True{}

# Positive ranges resolve by their owning immutable source interval, not by
# definition names or structural term equality. EOF is the reserved last point.

# Module: src/diagnostic/produce.bend:50
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
def dg_checking_result(+r: DChecking) -> KChecking:
  match r:
    case DChecking{result, diagnostic}: result

# Module: src/diagnostic/produce.bend:108
@unsafe
def dg_result_error(result):
  match result:
    case DResult{error, book, diagnostic}: error

# Module: src/back/common/literals.bend:11
@unsafe
def w5c2_j_strip_if(is_ann: Bool, +t: KTerm, +kids: List<&2, KTerm>) -> KTerm:
  match is_ann:
    case False{}: t
    case True{}:
      match kids:
        case Nil{}: {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}
        case Con{h, _}: j_strip(h)

@unsafe
def j_strip(t):
  match t:
    case KTerm{tag, _, _, _, kids, _, _, _}:
      w5c2_j_strip_if(String.eq(tag, "Ann"), t, kids)
    case _: t

# Module: src/back/common/literals.bend:19
@unsafe
def j_private_float_finite(+bits: U32) -> Bool:
  Bool.not(U32.is_eq(U32.and(U32.shrn(bits, 23n), 255), 255))

# Module: src/back/common/queries.bend:7
@unsafe
def w5c2_j_spine_ref(is_ref: Bool, +name: String, +args: List<&2, KTerm>) -> KTerm:
  match is_ref:
    case True{}: kt("Call", name, 0, 0, args)
    case False{}: {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}

@unsafe
def j_body(xs):
  match xs:
    case Nil{}:
      {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}
    case Con{h, Nil{}}:
      h
    case Con{h, rest}:
      j_body(rest)

# Module: src/back/common/queries.bend:91
@unsafe
def w7_br_582(w7_c: Bool) -> U32:
  match w7_c:
    case True{}:
      99
    case False{}:
      0

@unsafe
def jd_raise_arm(+left: U32, +fields: U32) -> U32:
  # Signed residual in two's-complement U32: Mat may consume past zero before
  # later arms add fields. Clamping here would lose nested-matcher information.
  U32.add(U32.sub(left, 1), fields)

# Module: src/back/common/arity.bend:63
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
def j_char_text(value):
  match value:
    case None{}:
      ""
    case Some{n}:
      "checkedChar(" ++ U32.show(n) ++ ")"

# Module: src/back/js/literals.bend:58
@unsafe
def j_nat_text(value):
  match value:
    case None{}:
      ""
    case Some{n}:
      Nat.show(n) ++ "n"

# Module: src/back/js/literals.bend:80
@unsafe
def w7_br_596(w7_c: Bool, +literal: String) -> String:
  match w7_c:
    case True{}:
      literal
    case False{}:
      ""

@unsafe
def w7_br_598(w7_c: Bool) -> String:
  match w7_c:
    case True{}:
      "main must be a filled def: a foreign main cannot anchor IO"
    case False{}:
      ""

@unsafe
def j_printable_done(+done: Maybe<&2,List<&2,String>>) -> Bool:
  match done:
    case None{}: False{}
    case Some{visited}: True{}

# Module: src/back/js/validate.bend:48
@unsafe
def w7_br_603(w7_c: Bool, +name: String) -> Bool:
  match w7_c:
    case True{}:
      String.contains("|Array.new|Array.set|Array.get|Array.get_unchecked|Array.swap|Array.size|", "|" ++ name ++ "|")
    case False{}:
      False{}

@unsafe
def w7b_starts_A(+name: String) -> Bool:
  match name:
    case SCon{h, _}: U32.is_eq(Char.to_u32(h), 65)
    case SNil{}: False{}

@unsafe
def j_primitive_known(+name: String) -> Bool:
  String.contains("|U32.add|U32.sub|U32.mul|U32.div|U32.mod|U32.and|U32.or|U32.xor|U32.inc|U32.not|U32.shl|U32.shr|U32.shln|U32.shrn|U32.is_zero|U32.is_eq|U32.is_ne|U32.is_lt|U32.is_le|U32.is_gt|U32.is_ge|U32.to_nat|U32.from_nat|U32.to_f32|F32.add|F32.sub|F32.mul|F32.div|F32.mod|F32.neg|F32.is_eq|F32.is_ne|F32.is_lt|F32.is_le|F32.is_gt|F32.is_ge|F32.sqrt|F32.exp|F32.log|F32.log2|F32.log10|F32.sin|F32.cos|F32.tan|F32.asin|F32.acos|F32.atan|F32.sinh|F32.cosh|F32.tanh|F32.floor|F32.ceil|F32.trunc|F32.abs|", "|" ++ name ++ "|")

# Module: src/back/js/primitive.bend:11
@unsafe
def w7_br_606(w7_c: Bool) -> U32:
  match w7_c:
    case True{}:
      1
    case False{}:
      2

@unsafe
def w7_br_607(w7_c: Bool) -> String:
  match w7_c:
    case True{}:
      "F32"
    case False{}:
      "U32"

@unsafe
def w7_br_609(w7_c: Bool) -> String:
  match w7_c:
    case True{}:
      "F32"
    case False{}:
      "U32"

@unsafe
def j_region_local_ok(+result: Maybe<&2,U32>) -> Bool:
  match result:
    case Some{fuel}: True{}
    case None{}: False{}

# Closed recursive tagged ADTs: no parameters, native arrays, functions, foreign
# representations or dependent fields. An active owner still has every one of
# its constructors checked by the pending outer visit.

# Module: src/back/js/jpure.bend:33
@unsafe
def j_pure_shape_bound(+todo: List<&2,KTerm>, +fuel: U32) -> Bool:
  match todo:
    case Nil{}: True{}
    case Con{t, rest}: kc(Bool, U32.is_gt(fuel, 0), u =>
      j_pure_shape_bound(List.append(&2, KTerm, ks(t), rest), U32.sub(fuel, 1)), u => False{})

# Module: src/back/js/jpure.bend:457
@unsafe
def j_region_def_count(+ds: List<&2,KDef>) -> U32:
  match ds:
    case Nil{}: 0
    case Con{h, rest}: U32.inc(j_region_def_count(rest))

# Stop after two uses. Inspect every child, including closures and annotations;
# globally fresh frontend IDs make copied helper binders unambiguous here.

# Module: src/back/js/region.bend:812
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
def nt_choose(-A: Type, +b: Bool, yes: Unit -> A, no: Unit -> A) -> A:
  match b:
    case True{}: yes(Unit{})
    case False{}: no(Unit{})

# Chunks arrive in reverse output order. Only each new chunk is traversed by
# append; the growing suffix stays on its right.

# Module: src/back/native/text.bend:10
@unsafe
def nt_text_finish(xs: List<&2, String>, acc: String) -> String:
  match xs:
    case Nil{}: acc
    case Con{h, t}: nt_text_finish(t, h ++ acc)

# Module: src/back/native/text.bend:30
@unsafe
def nt_count_go(-A: Data, xs: List<&2, A>, +n: U32) -> U32:
  match xs:
    case Nil{}: n
    case Con{h, t}: nt_count_go(A, t, U32.inc(n))

# Module: src/back/native/text.bend:36
@unsafe
def nt_reverse(-A: Data, xs: List<&2, A>, acc: List<&2, A>) -> List<&2, A>:
  match xs:
    case Nil{}: acc
    case Con{h, t}: nt_reverse(A, t, Con{h, acc})

# Module: src/back/native/text.bend:46
@unsafe
def w5c2_clean_char_ok(+c: U32) -> Bool:
  (U32.is_ge(c, 97) && U32.is_le(c, 122)) ||
  (U32.is_ge(c, 65) && U32.is_le(c, 90)) ||
  (U32.is_ge(c, 48) && U32.is_le(c, 57)) ||
  U32.is_eq(c, 95)

@unsafe
def nt_bool(b: Bool) -> U32:
  match b:
    case True{}: 1
    case False{}: 0

# Module: src/back/native/text.bend:82
law w5c2_rep_scan:
  for +s: String
  for +key: String
  for +k0: U32
  for +klen: Nat
  for +value: String
  String

@unsafe
def w5c2_rep_hit(hit: Bool, +s: String, +h: Char, +t: String, +key: String, +k0: U32, +klen: Nat, +value: String) -> String:
  match hit:
    case True{}: value ++ String.drop(s, klen)
    case False{}: SCon{h, w5c2_rep_scan(t, key, k0, klen, value)}

@unsafe
def w5c2_rep_scan(s, key, k0, klen, value):
  match s:
    case SNil{}: ""
    case SCon{+h, +t}:
      w5c2_rep_hit(U32.is_eq(Char.to_u32(h), k0) && String.starts_with(s, key), s, h, t, key, k0, klen, value)

@unsafe
def nc_ctor_codes(name):
  match name:
    case SNil{}:
      ""
    case SCon{h, rest}:
      U32.show(Char.to_u32(h)) ++ "_" ++ nc_ctor_codes(rest)

# Module: src/back/native/identity.bend:66
@unsafe
def nk_kind(+id: U32, env: List<&2, NC_Binding>) -> N_WordKind:
  match env:
    case Nil{}: N_W64{}
    case Con{NC_Binding{at, word, +kind}, rest}: nt_choose(N_WordKind, U32.is_eq(id, at), u => kind, u => nk_kind(id, rest))

# Module: src/back/native/layout.bend:18
@unsafe
def w7_br_634(w7_c: Bool) -> N_WordKind:
  match w7_c:
    case True{}:
      N_W32{}
    case False{}:
      N_W64{}

@unsafe
def nk_typed_bindings(params: List<&2, NC_Binding>, kinds: List<&2, N_WordKind>) -> List<&2, NC_Binding>:
  match params, kinds:
    case Con{NC_Binding{id, word, old}, rest}, Con{kind, more}: Con{NC_Binding{id, word, kind}, nk_typed_bindings(rest, more)}
    case _, _: params

# Module: src/back/native/layout.bend:32
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
def w7_br_636(w7_c: Bool, +a: U32, +b: U32) -> U32:
  match w7_c:
    case True{}:
      a
    case False{}:
      b

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
def ne_single_result(+prefix: String, +value: String, +boxed: N_Emitted) -> N_Emitted:
  match boxed:
    case N_Emitted{+code, +box, +next}:
      N_Emitted{prefix ++ code ++ value ++ " = " ++ box ++ ";\n}\n", value, next}

# A fitting payload is a trivial tag-zero word; every other value keeps its box.

# Module: src/back/native/emit.bend:36
law nu_tip:
  for s: NU_Set
  for +key: U32
  U32

@unsafe
def w5c2_nu_tip_lr(go_l: Bool, left: NU_Set, right: NU_Set, +key: U32) -> U32:
  match go_l:
    case True{}: nu_tip(left, key)
    case False{}: nu_tip(right, key)

@unsafe
def nu_tip(s, key):
  match s:
    case NU_Empty{}: key
    case NU_Leaf{stored}: stored
    case NU_Node{+mask, left, right}:
      w5c2_nu_tip_lr(U32.is_eq(U32.and(key, mask), 0), left, right, key)

# Module: src/back/native/uses.bend:17
@unsafe
def w5c2_nu_join_lr(go_l: Bool, +s: NU_Set, +key: U32, +mask: U32) -> NU_Set:
  match go_l:
    case True{}: NU_Node{mask, NU_Leaf{key}, s}
    case False{}: NU_Node{mask, s, NU_Leaf{key}}

law nu_has:
  for s: NU_Set
  for +key: U32
  Bool

@unsafe
def w5c2_nu_has_lr(go_l: Bool, left: NU_Set, right: NU_Set, +key: U32) -> Bool:
  match go_l:
    case True{}: nu_has(left, key)
    case False{}: nu_has(right, key)

@unsafe
def nu_has(s, key):
  match s:
    case NU_Empty{}: False{}
    case NU_Leaf{stored}: U32.is_eq(stored, key)
    case NU_Node{+mask, left, right}:
      w5c2_nu_has_lr(U32.is_eq(U32.and(key, mask), 0), left, right, key)

# Module: src/back/native/bridge.bend:19
law nc_word:
  for +id: U32
  for +env: List<&2, NC_Binding>
  String

@unsafe
def w5c2_nc_word_if(eq: Bool, +word: String, +id: U32, +rest: List<&2, NC_Binding>) -> String:
  match eq:
    case True{}: word
    case False{}: nc_word(id, rest)

@unsafe
def nc_word(id, env):
  match env:
    case Nil{}: "NATIVE_UNBOUND_VARIABLE"
    case Con{NC_Binding{+at, +word, _}, +rest}:
      w5c2_nc_word_if(U32.is_eq(id, at), word, id, rest)

# Module: src/back/native/bridge.bend:26
@unsafe
def nc_words(+env: List<&2, NC_Binding>) -> List<&2, String>:
  match env:
    case Nil{}: Nil{}
    case Con{NC_Binding{+id, +word, +kind}, +rest}: Con{word, nc_words(rest)}

# Module: src/back/native/bridge.bend:44
@unsafe
def nct_leaf(text: String) -> NC_Text:
  match text:
    case SNil{}: NC_Empty{}
    case SCon{head, tail}: NC_Leaf{SCon{head, tail}}

@unsafe
def nct_empty(text: NC_Text) -> Bool:
  match text:
    case NC_Empty{}: True{}
    case NC_Leaf{code}: False{}
    case NC_Join{left, right}: False{}

@unsafe
def nct_cat_right(left: NC_Text, right: NC_Text, empty: Bool) -> NC_Text:
  match empty:
    case True{}: left
    case False{}: NC_Join{left, right}

@unsafe
def nc_text(x: NC_Code) -> NC_Text:
  match x:
    case NC_Code{body, segs, n, err, edges}: body

# Module: src/back/native/bridge.bend:54
@unsafe
def nc_fresh(+x: NC_Code) -> U32:
  match x:
    case NC_Code{+body, +segs, +n, +err, edges}: n

# Module: src/back/native/bridge.bend:59
@unsafe
def nc_error(+x: NC_Code) -> String:
  match x:
    case NC_Code{+body, +segs, +n, +err, edges}: err

# Module: src/back/native/bridge.bend:64
@unsafe
def nc_id(+n: U32) -> U32:
  U32.sub(4294967295, n)

# Module: src/back/native/bridge.bend:84
@unsafe
def nc_binding(+id: U32) -> NC_Binding:
  NC_Binding{id, "v_" ++ U32.show(id), N_W64{}}

# Module: src/back/native/bridge.bend:111
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
def nc_head(+xs: List<&2, String>) -> String:
  match xs:
    case Nil{}: "0"
    case Con{+h, +t}: h

# Module: src/back/native/bridge.bend:341
@unsafe
def nc_tail(+xs: List<&2, String>) -> List<&2, String>:
  match xs:
    case Nil{}: Nil{}
    case Con{+h, +t}: t

# Module: src/back/native/bridge.bend:356
@unsafe
def w5c2_may_be_prim_first(+name: String) -> Bool:
  match name:
    case SNil{}: False{}
    case SCon{h, _}:
      +c = Char.to_u32(h)
      U32.is_eq(c, 85) || U32.is_eq(c, 70) || U32.is_eq(c, 78) || U32.is_eq(c, 66) || U32.is_eq(c, 65) ||
      U32.is_eq(c, 117) || U32.is_eq(c, 102) || U32.is_eq(c, 110) || U32.is_eq(c, 98) || U32.is_eq(c, 97)

@unsafe
def w5c2_prim_is_u32(+k: String) -> Bool:
  String.eq(k, "u32_add") || String.eq(k, "u32_sub") || String.eq(k, "u32_and") ||
  String.eq(k, "u32_or") || String.eq(k, "u32_xor") || String.eq(k, "u32_mul") ||
  String.eq(k, "u32_is_eq") || String.eq(k, "u32_is_ne") || String.eq(k, "u32_is_lt") ||
  String.eq(k, "u32_is_le") || String.eq(k, "u32_is_gt") || String.eq(k, "u32_is_ge") ||
  String.eq(k, "u32_inc") || String.eq(k, "u32_shl") || String.eq(k, "u32_shr") ||
  String.eq(k, "u32_shln") || String.eq(k, "u32_shrn") || String.eq(k, "u32_div") ||
  String.eq(k, "u32_mod") || String.eq(k, "u32_not") || String.eq(k, "u32_is_zero") ||
  String.eq(k, "u32_cmp") || String.eq(k, "u32_to_f32") || String.eq(k, "u32_to_nat") ||
  String.eq(k, "u32_from_nat")

@unsafe
def w5c2_prim_is_f32(+k: String) -> Bool:
  String.eq(k, "f32_add") || String.eq(k, "f32_sub") || String.eq(k, "f32_mul") ||
  String.eq(k, "f32_div") || String.eq(k, "f32_is_eq") || String.eq(k, "f32_is_ne") ||
  String.eq(k, "f32_is_lt") || String.eq(k, "f32_is_le") || String.eq(k, "f32_is_gt") ||
  String.eq(k, "f32_is_ge") || String.eq(k, "f32_sqrt") || String.eq(k, "f32_exp") ||
  String.eq(k, "f32_log") || String.eq(k, "f32_log2") || String.eq(k, "f32_log10") ||
  String.eq(k, "f32_sin") || String.eq(k, "f32_cos") || String.eq(k, "f32_tan") ||
  String.eq(k, "f32_asin") || String.eq(k, "f32_acos") || String.eq(k, "f32_atan") ||
  String.eq(k, "f32_sinh") || String.eq(k, "f32_cosh") || String.eq(k, "f32_tanh") ||
  String.eq(k, "f32_floor") || String.eq(k, "f32_ceil") || String.eq(k, "f32_trunc") ||
  String.eq(k, "f32_abs") || String.eq(k, "f32_pow") || String.eq(k, "f32_atan2") ||
  String.eq(k, "f32_mod") || String.eq(k, "f32_neg") || String.eq(k, "f32_to_u32") ||
  String.eq(k, "f32_bits") || String.eq(k, "f32_show") || String.eq(k, "f32_read") ||
  String.eq(k, "f32_from_nat")

@unsafe
def w5c2_prim_is_nat(+k: String) -> Bool:
  String.eq(k, "nat_add") || String.eq(k, "nat_sub") || String.eq(k, "nat_mul") ||
  String.eq(k, "nat_double") || String.eq(k, "nat_cmp") || String.eq(k, "nat_is_lt") ||
  String.eq(k, "nat_divmod")

@unsafe
def w5c2_prim_is_bool(+k: String) -> Bool:
  String.eq(k, "bool_or") || String.eq(k, "bool_xor")

@unsafe
def w5c2_nc_ref_if(is_nat: Bool, +name: String) -> String:
  match is_nat:
    case True{}: "$native." ++ name
    case False{}: name

@unsafe
def w5c2_arity_2_if(is2: Bool) -> U32:
  match is2:
    case True{}: 2
    case False{}: 1

@unsafe
def w5c3_str_if(cond: Bool, +yes: String) -> String:
  match cond:
    case True{}: yes
    case False{}: ""

@unsafe
def nd_name(name: String) -> String:
  "$direct." ++ name

@unsafe
def nd_match_vars(args: List<&2, KTerm>) -> Bool:
  match args:
    case Nil{}: True{}
    case Con{h, rest}: p98_tag_eq(h, "Var") && nd_match_vars(rest)

# Module: src/back/native/direct.bend:128
@unsafe
def nd_match_rest_list(ts: List<&2, KTerm>) -> List<&2, KTerm>:
  match ts:
    case Con{head, Con{arg, rest}}: rest
    case _: Nil{}

# A small linear combinator exposes literal captures to the existing beta rule.
# Only its closed App/Var body is copied: <=8 parameters imply <=15 body nodes.

# Module: src/back/native/direct.bend:158
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
@unsafe
def w7_br_690(w7_c: Bool) -> N_WordKind:
  match w7_c:
    case True{}:
      N_Imm64{}
    case False{}:
      N_W64{}

@unsafe
def nf_self_moves(params: List<&2, NC_Binding>, words: List<&2, String>, +i: U32) -> String:
  match params, words:
    case Con{NC_Binding{id, word, kind}, rest}, Con{value, more}: word ++ " = nf_arg_" ++ U32.show(i) ++ ";\n" ++ nf_self_moves(rest, more, U32.inc(i))
    case _, _: ""

# Module: src/back/native/flat.bend:143
@unsafe
def nf_self_temps(words: List<&2, String>, +i: U32) -> String:
  match words:
    case Nil{}: ""
    case Con{word, rest}: "Term nf_arg_" ++ U32.show(i) ++ " = " ++ word ++ ";\n" ++ nf_self_temps(rest, U32.inc(i))

# Module: src/back/native/product-layout.bend:5
@unsafe
def w7_br_692(w7_c: Bool) -> U32:
  match w7_c:
    case True{}:
      2
    case False{}:
      0

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
def w5c2_nq_sub_var(eq: Bool, +t: KTerm, +value: KTerm) -> KTerm:
  match eq:
    case True{}: value
    case False{}: t

@unsafe
def nc_calls(+code: NC_Code) -> List<&2, String>:
  match code:
    case NC_Code{body, segs, fresh, error, edges}: edges

# Module: src/back/native/product.bend:14
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
def nq_signature_opaque(name: String) -> KDef:
  KDef{name, "NQSignature", 0, 0, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Nil{}, False{}, False{}}

# Module: src/back/native/product.bend:315
@unsafe
def nc_tail_terms(ts: List<&2, KTerm>) -> List<&2, KTerm>:
  match ts:
    case Nil{}: Nil{}
    case Con{h, rest}: rest

# Module: src/back/native/product.bend:332
@unsafe
def nq_entry_cons(params: List<&2, NC_Binding>, arg: KTerm, tail: NQ_Entry) -> NQ_Entry:
  match tail:
    case NQ_Entry{more, args, fresh}: NQ_Entry{List.append(&2, NC_Binding, params, more), Con{arg, args}, fresh}

# Module: src/back/native/word-pattern.bend:15
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
def nw_join(a: NW_Rows, b: NW_Rows) -> NW_Rows:
  match a, b:
    case NW_Rows{av, ar}, NW_Rows{bv, br}: NW_Rows{av && bv, List.append(&2, KTerm, ar, br)}

# Module: src/back/native/word-pattern.bend:92
@unsafe
def nw_row(+body: KTerm, +depth: U32, +value: U32, +fields: U32) -> KTerm:
  kt("NWRow", U32.show(value), depth, fields, [body])

# Module: src/back/native/word-pattern.bend:103
@unsafe
def nw_value_result(parsed: Maybe<&2, U32>) -> U32:
  match parsed:
    case None{}: 0
    case Some{value}: value

# Module: src/back/native/word-pattern.bend:167
@unsafe
def ns_array_pattern(+t: KTerm) -> Bool:
  match t:
    case KTerm{tag, name, _, _, _, _, _, _}:
      (String.eq(tag, "Ctr") || String.eq(tag, "Mat")) && (String.eq(name, "ALeaf") || String.eq(name, "ANode"))
    case _: False{}

# Module: src/back/native/scalar-array.bend:25
def no_effect_provider_member(names: List<&2, String>, +name: String) -> Bool:
  match names:
    case Nil{}: False{}
    case Con{head, rest}: p88_string_eq(head, name) || no_effect_provider_member(rest, name)

@unsafe
def w5c2_nc_unann_if(is_ann: Bool, +t: KTerm, +kids: List<&2, KTerm>) -> KTerm:
  match is_ann:
    case False{}: t
    case True{}:
      match kids:
        case Nil{}: {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}
        case Con{h, _}: nc_unann(h)

@unsafe
def nc_unann(t):
  match t:
    case KTerm{tag, _, _, _, kids, _, _, _}:
      w5c2_nc_unann_if(String.eq(tag, "Ann"), t, kids)
    case _: t

# Module: src/back/native/book.bend:66
@unsafe
def nc_default_ctors() -> List<&2, N_Constructor>:
  [N_Constructor{"Tuple", 2, True{}}, N_Constructor{"SNil", 0, True{}}, N_Constructor{"SCon", 2, True{}}, N_Constructor{"WCon", 2, True{}}, N_Constructor{"WNil", 0, True{}}, N_Constructor{"Emit", 1, True{}}, N_Constructor{"Halt", 2, True{}}, N_Constructor{"Done", 1, True{}}, N_Constructor{"Fail", 1, True{}}, N_Constructor{"Some", 1, True{}}, N_Constructor{"None", 0, True{}}, N_Constructor{"True", 0, True{}}, N_Constructor{"False", 0, True{}}, N_Constructor{"Unit", 0, True{}}, N_Constructor{"LT", 0, True{}}, N_Constructor{"EQ", 0, True{}}, N_Constructor{"GT", 0, True{}}]

# Module: src/back/native/book.bend:183
@unsafe
def w7_br_738(w7_c: Bool, +original: KDef, +annotated: KDef) -> KDef:
  match w7_c:
    case True{}:
      original
    case False{}:
      annotated

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
def no_root_index(roots: List<&2, U32>, +i: U32) -> Bool:
  match roots:
    case Nil{}: False{}
    case Con{root, rest}: U32.is_eq(root, i) || no_root_index(rest, i)

# Module: src/back/native/observer-adapter.bend:35
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
def nol_failure(+reason: String, +fresh: U32) -> NO_Schema:
  NO_Schema{Nil{}, Nil{}, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, 0, "", Nil{}, fresh, reason}

# Module: src/back/native/observer-layout.bend:138
@unsafe
def nol_wrap_fail(+reason: String, +roots: List<&2, U32>, +shells: U32, +observation: String) -> NOL_Wrap:
  NOL_Wrap{{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, roots, shells, observation, reason}

# Module: src/back/native/observer-layout.bend:174
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
def no_schema_specs_layouts(specs: List<&2, NO_Spec>) -> List<&2, NO_Layout>:
  match specs:
    case Nil{}: Nil{}
    case Con{+spec, +rest}:
      match spec:
        case NO_Spec{+layout, +owner, +fields}: Con{layout, no_schema_specs_layouts(rest)}

# Module: src/back/native/observer-layout.bend:250
@unsafe
def no_schema_params(schema: NO_Schema) -> List<&2, KTerm>:
  match schema:
    case NO_Schema{+params, +roots, +wrapper, +result, +observation, +specs, +fresh, +error}: params

# Module: src/back/native/observer-layout.bend:255
@unsafe
def no_schema_roots(schema: NO_Schema) -> List<&2, U32>:
  match schema:
    case NO_Schema{+params, +roots, +wrapper, +result, +observation, +specs, +fresh, +error}: roots

# Module: src/back/native/observer-layout.bend:260
@unsafe
def no_schema_wrapper(schema: NO_Schema) -> KTerm:
  match schema:
    case NO_Schema{+params, +roots, +wrapper, +result, +observation, +specs, +fresh, +error}: wrapper

# Module: src/back/native/observer-layout.bend:265
@unsafe
def no_schema_result(schema: NO_Schema) -> U32:
  match schema:
    case NO_Schema{+params, +roots, +wrapper, +result, +observation, +specs, +fresh, +error}: result

# Module: src/back/native/observer-layout.bend:270
@unsafe
def no_schema_observation(schema: NO_Schema) -> String:
  match schema:
    case NO_Schema{+params, +roots, +wrapper, +result, +observation, +specs, +fresh, +error}: observation

# Module: src/back/native/observer-layout.bend:275
@unsafe
def no_schema_specs(schema: NO_Schema) -> List<&2, NO_Spec>:
  match schema:
    case NO_Schema{+params, +roots, +wrapper, +result, +observation, +specs, +fresh, +error}: specs

# Module: src/back/native/observer-layout.bend:280
@unsafe
def no_schema_fresh(schema: NO_Schema) -> U32:
  match schema:
    case NO_Schema{+params, +roots, +wrapper, +result, +observation, +specs, +fresh, +error}: fresh

# Module: src/back/native/observer-layout.bend:285
@unsafe
def no_schema_error(schema: NO_Schema) -> String:
  match schema:
    case NO_Schema{+params, +roots, +wrapper, +result, +observation, +specs, +fresh, +error}: error

# Module: src/back/native/observer-literals.bend:6
@unsafe
def noa_book(c: NO_Context) -> List<&2,KDef>:
  match c:
    case NO_Context{book,owner,schema,helpers}: book

@unsafe
def noa_owner(c: NO_Context) -> String:
  match c:
    case NO_Context{book,owner,schema,helpers}: owner

@unsafe
def noa_schema(c: NO_Context) -> NO_Schema:
  match c:
    case NO_Context{book,owner,schema,helpers}: schema

@unsafe
def noa_iv(i: NO_Input) -> KTerm:
  match i:
    case NO_Input{+v, +f, +n, +fuel}: v

# Module: src/back/native/observer-analysis.bend:60
@unsafe
def noa_if(i: NO_Input) -> List<&2, KTerm>:
  match i:
    case NO_Input{+v, +f, +n, +fuel}: f

# Module: src/back/native/observer-analysis.bend:65
@unsafe
def noa_in(i: NO_Input) -> U32:
  match i:
    case NO_Input{+v, +f, +n, +fuel}: n

# Module: src/back/native/observer-analysis.bend:70
@unsafe
def noa_iu(i: NO_Input) -> U32:
  match i:
    case NO_Input{+v, +f, +n, +fuel}: fuel

# Module: src/back/native/observer-analysis.bend:75
@unsafe
def noa_body(a: NO_Analysis) -> KTerm:
  match a:
    case NO_Analysis{+b, +n, +f, +e}: b

# Module: src/back/native/observer-analysis.bend:80
@unsafe
def noa_fresh(a: NO_Analysis) -> U32:
  match a:
    case NO_Analysis{+b, +n, +f, +e}: n

# Module: src/back/native/observer-analysis.bend:85
@unsafe
def noa_fuel(a: NO_Analysis) -> U32:
  match a:
    case NO_Analysis{+b, +n, +f, +e}: f

# Module: src/back/native/observer-analysis.bend:90
@unsafe
def noa_error(a: NO_Analysis) -> String:
  match a:
    case NO_Analysis{+b, +n, +f, +e}: e

# Module: src/back/native/observer-analysis.bend:95
@unsafe
def noa_fail(msg: String, n: U32, fuel: U32) -> NO_Analysis:
  NO_Analysis{{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, n, fuel, msg}

# Module: src/back/native/observer-analysis.bend:99
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
def noa_ctor_type(spec: Maybe<&2, NO_Spec>) -> String:
  match spec:
    case None{}: ""
    case Some{NO_Spec{+layout, +owner, +fields}}: owner

# Module: src/back/native/observer-analysis.bend:228
@unsafe
def noa_no_absent(values: List<&2, KTerm>) -> Bool:
  match values:
    case Nil{}: True{}
    case Con{+h, +rest}: Bool.not(p98_tag_eq(h, "Absent")) && noa_no_absent(rest)

# Module: src/back/native/observer-analysis.bend:253
@unsafe
def noa_tail(xs: List<&2, KTerm>) -> List<&2, KTerm>:
  match xs:
    case Nil{}: Nil{}
    case Con{+x, +rest}: rest

# Module: src/back/native/observer-analysis.bend:358
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
def no_plan_owner(plan: NO_Plan) -> String:
  match plan:
    case NO_Plan{+owner, +schema, +analysis, +error}: owner

# Module: src/back/native/observer-plan.bend:12
@unsafe
def no_plan_schema(plan: NO_Plan) -> NO_Schema:
  match plan:
    case NO_Plan{+owner, +schema, +analysis, +error}: schema

# Module: src/back/native/observer-plan.bend:17
@unsafe
def no_plan_analysis(plan: NO_Plan) -> NO_Analysis:
  match plan:
    case NO_Plan{+owner, +schema, +analysis, +error}: analysis

# Module: src/back/native/observer-plan.bend:22
@unsafe
def no_plan_error(plan: NO_Plan) -> String:
  match plan:
    case NO_Plan{+owner, +schema, +analysis, +error}: error

# Module: src/back/native/observer-plan.bend:27
@unsafe
def dr_count(names):
  match names:
    case Nil{}: 0
    case Con{+name, +rest}: U32.add(1, dr_count(rest))

# Module: src/driver/report.bend:79
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
def p88_state_bad(state: P88State) -> P88State:
  match state:
    case P88State{cursor,nodes,strings,made,sn,begin,end}:
      P88State{P88Cursor{"",0},nodes,strings,made,sn,begin,end}

def p151_choose(-A: Type, +b: Bool, yes: Unit -> A, no: Unit -> A) -> A:
  match b:
    case True{}: yes(Unit{})
    case False{}: no(Unit{})

@unsafe
def p88_role_empty(role: U32, node: P88Node) -> P88Node:
  match role node:
    case 6 P88Empty{}: P88Terms{Nil{}}
    case 7 P88Empty{}: P88Defs{Nil{}}
    case 8 P88Empty{}: P88Strings{Nil{}}
    case r n: n

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:139
@unsafe
def p88_string_got(cursor: P88Cursor, nodes: Array<P88Node>, made: U32, sn: U32, begin: U32, end: U32, pair: Array<String> & String) -> P88Step:
  (strings, text) = pair
  P88Step{P88State{cursor, nodes, strings, made, sn, begin, end}, P88String{text}}

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:202
@unsafe
def p88_span(+a: U32, +b: U32, begin: U32, end: U32) -> Bool:
  (U32.is_eq(a, 0) && U32.is_eq(b, 0)) || (U32.is_ge(a, begin) && U32.is_ge(b, a) && U32.is_lt(b, end))

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:206
@unsafe
def p88_valid_node(node: P88Node, valid: Bool) -> P88Node:
  match valid:
    case True{}: node
    case False{}: P88Bad{}

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:212
@unsafe
def p88_array_depth(+needed: U32, +capacity: U32, depth: Nat) -> Nat:
  p88_array_depth_step(needed,capacity,depth,U32.is_le(needed,capacity))

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:384
@unsafe
def p88_array_depth_step(needed: U32, capacity: U32, depth: Nat, done: Bool) -> Nat:
  match done:
    case True{}: depth
    case False{}: p88_array_depth(needed,U32.mul(capacity,2),1n+depth)

# Phase88 native-host entry. Reuses one checked Base world; algorithms stay Bend.
# Root freezes/audits Base, runtime and EFFECTDIR; only the three audited scalar
# Base effects are admitted. This is a prepared-session experiment, not a CLI.
# RUNTIME names the authenticated runtime whose five prepared sibling files
# RUNTIME.part0 .. RUNTIME.part4 are supplied by the root harness.

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:414
@unsafe
def p205_var_at(+id: U32, ids: List<&2,U32>, +depth: U32) -> Bool:
  match ids:
    case Nil{}: False{}
    case Con{x,xs}: kc(Bool,U32.is_eq(depth,0),u => U32.is_eq(id,x),u => p205_var_at(id,xs,U32.sub(depth,1)))

@unsafe
def p205_ok(state: Maybe<&2,KDef>) -> Bool:
  match state:
    case Some{x}: True{}
    case None{}: False{}

@unsafe
def w7_br_793(w7_c: Bool, +original: KTerm, +child: KTerm, +prefix: List<&2,KTerm>) -> KTerm:
  match w7_c:
    case True{}:
      child
    case False{}:
      k_with_children(original,List.append(&2,KTerm,prefix,[child]))

@unsafe
def w5c3_b2u(b: Bool) -> U32:
  match b:
    case True{}: 1
    case False{}: 0

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
def p205u_length( +text: String, +fuel: U32) -> Bool:
  match text fuel:
    case SNil{} _: True{}
    case SCon{c,rest} 0: False{}
    case SCon{c,rest} _: p205u_length(rest,U32.sub(fuel,1))

# All failure results are propagated to the outer absent sentinel.
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
def p205_repeat_equation() -> P205Equation:
  P205Equation{["Nat", "String", "String"],
    N205{"Mat","Zero",[L205{N205{"Ctr","SNil",[]}},N205{"Mat","Succ",[L205{L205{N205{"App","",[N205{"App","",[R205{"append"},V205{0}]},N205{"App","",[N205{"App","",[R205{"repeat"},V205{1}]},V205{0}]}]}}},N205{"Efq","",[]}]}]}}

@unsafe
def p205_split_equation() -> P205Equation:
  P205Equation{["U32", "String", "Strings"],
    L205{N205{"Mat","SNil",[N205{"Ctr","Con",[N205{"Ctr","SNil",[]},N205{"Ctr","Nil",[]}]},N205{"Mat","SCon",[N205{"Mat","Chr",[L205{L205{B205{V205{1},N205{"App","",[N205{"App","",[N205{"App","",[R205{"pick"},V205{0}]},N205{"App","",[N205{"App","",[R205{"split"},V205{3}]},V205{1}]}]},N205{"App","",[N205{"App","",[N205{"Ref","U32.is_eq",[]},V205{0}]},V205{3}]}]}}}},N205{"Efq","",[]}]},N205{"Efq","",[]}]}]}}}

@unsafe
def p205_pick_equation() -> P205Equation:
  P205Equation{["U32", "Strings", "Bool", "Strings"],
    L205{L205{N205{"Mat","True",[N205{"Ctr","Con",[N205{"Ctr","SNil",[]},V205{0}]},N205{"Mat","False",[N205{"App","",[N205{"App","",[R205{"push"},N205{"Ctr","Chr",[V205{1}]}]},V205{0}]},N205{"Efq","",[]}]}]}}}}

@unsafe
def p205_push_equation() -> P205Equation:
  P205Equation{["Char", "Strings", "Strings"],
    L205{N205{"Mat","Nil",[N205{"Ctr","Con",[N205{"Ctr","SCon",[V205{0},N205{"Ctr","SNil",[]}]},N205{"Ctr","Nil",[]}]},N205{"Mat","Con",[L205{L205{N205{"Ctr","Con",[N205{"Ctr","SCon",[V205{2},V205{1}]},V205{0}]}}},N205{"Efq","",[]}]}]}}}

@unsafe
def p205_join_equation() -> P205Equation:
  P205Equation{["String", "Strings", "String"],
    L205{N205{"Mat","Nil",[N205{"Ctr","SNil",[]},N205{"Mat","Con",[L205{L205{N205{"App","",[N205{"App","",[N205{"App","",[R205{"join_rest"},V205{2}]},V205{0}]},V205{1}]}}},N205{"Efq","",[]}]}]}}}

@unsafe
def p205_join_rest_equation() -> P205Equation:
  P205Equation{["String", "Strings", "String", "String"],
    L205{N205{"Mat","Nil",[L205{V205{0}},N205{"Mat","Con",[L205{L205{L205{N205{"App","",[N205{"App","",[R205{"append"},V205{0}]},N205{"App","",[N205{"App","",[R205{"append"},V205{3}]},N205{"App","",[N205{"App","",[N205{"App","",[R205{"join_rest"},V205{3}]},V205{1}]},V205{2}]}]}]}}}},N205{"Efq","",[]}]}]}}}

@unsafe
def p205_append_equation() -> P205Equation:
  P205Equation{["String", "String", "String"],
    N205{"Mat","SNil",[L205{V205{0}},N205{"Mat","SCon",[L205{L205{L205{N205{"Ctr","SCon",[V205{2},N205{"App","",[N205{"App","",[R205{"append"},V205{1}]},V205{0}]}]}}}},N205{"Efq","",[]}]}]}}


# AGY-005a: General Bounded Pure Closed-Term Evaluator (CTFE)
# Evaluates pure, safe, 0-arg definitions returning ground Data values
# (U32, Nat, Bool, Char, String, F32) under strict step fuel, rechecking every
# rewritten body with check_definition_body + ka_def.

def ctfe_bits_to_f32(u: U32) -> F32:
  match u:
    case U32{w}: F32{w}

@unsafe
def ctfe_fail(+fuel: U32) -> CtfeRes:
  CtfeRes{CVFail{}, fuel}

@unsafe
def ctfe_is_fail(+v: CtfeVal) -> Bool:
  match v:
    case CVFail{}: True{}
    case _: False{}

@unsafe
def ctfe_bool(+b: Bool) -> CtfeVal:
  CVCtr{kc(String, b, u => "True", u => "False"), []}

@unsafe
def ctfe_cmp(+c: Cmp) -> CtfeVal:
  match c:
    case LT{}: CVCtr{"LT", []}
    case EQ{}: CVCtr{"EQ", []}
    case GT{}: CVCtr{"GT", []}

@unsafe
def ctfe_env_get(+env: List<&2, Sigma<&2, &2, U32, _ => CtfeVal>>, +id: U32) -> CtfeVal:
  match env:
    case Nil{}: CVFail{}
    case Con{(bid, val), rest}:
      kc(CtfeVal, U32.is_eq(bid, id), u => val, u => ctfe_env_get(rest, id))

@unsafe
def ctfe_rev_append(xs: List<&2, CtfeVal>, acc: List<&2, CtfeVal>) -> List<&2, CtfeVal>:
  match xs:
    case Nil{}: acc
    case Con{h, t}: ctfe_rev_append(t, Con{h, acc})

@unsafe
def w7_br_826(w7_c: Bool) -> U32:
  match w7_c:
    case True{}:
      1
    case False{}:
      0

@unsafe
def ctfe_as_nat_zero(fields: List<&2, CtfeVal>, +acc: U32) -> Maybe<&2, U32>:
  match fields:
    case Nil{}: Some{acc}
    case _: None{}

@unsafe
def w7_br_828(w7_c: Bool, +a: U32, +b: U32) -> CtfeVal:
  match w7_c:
    case True{}:
      CVFail{}
    case False{}:
      CVU32{U32.div(a, b)}

@unsafe
def w7_br_829(w7_c: Bool, +a: U32, +b: U32) -> CtfeVal:
  match w7_c:
    case True{}:
      CVFail{}
    case False{}:
      CVU32{U32.mod(a, b)}

@unsafe
def w7_br_845(w7_c: Bool, +a: U32, +b: U32) -> CtfeVal:
  match w7_c:
    case True{}:
      CVNat{U32.add(a, b)}
    case False{}:
      CVFail{}

@unsafe
def w7_br_846(w7_c: Bool, +a: U32, +b: U32) -> CtfeVal:
  match w7_c:
    case True{}:
      CVNat{U32.mul(a, b)}
    case False{}:
      CVFail{}

@unsafe
def w7_br_847(w7_c: Bool, +a: U32, +b: U32) -> CtfeVal:
  match w7_c:
    case True{}:
      CVFail{}
    case False{}:
      CVNat{U32.div(a, b)}

@unsafe
def w7_br_848(w7_c: Bool, +a: U32, +b: U32) -> CtfeVal:
  match w7_c:
    case True{}:
      CVFail{}
    case False{}:
      CVNat{U32.mod(a, b)}

@unsafe
def ctfe_nat_to_u32(m: Maybe<&2, U32>) -> CtfeVal:
  match m:
    case Some{n}: CVU32{n}
    case None{}: CVFail{}

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
def ctfe_str_cons(+code: U32, tail: Maybe<&2, String>) -> Maybe<&2, String>:
  match tail:
    case Some{s}: Some{SCon{Chr{code}, s}}
    case None{}: None{}

@unsafe
def agy_abs_lam(+name: String, +id: U32, +q: U32, +body: KTerm) -> KTerm:
  KLambda{name,id,q,[body],[],0,0,True{}}

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
def agy_abs_drop_last(lams: List<&2,KTerm>) -> List<&2,KTerm>:
  match lams:
    case Nil{}: []
    case Con{_,Nil{}}: []
    case Con{l,rest}: Con{l,agy_abs_drop_last(rest)}

@unsafe
def agy_abs_join(+ch1: Bool, +step_res: AgyAbsResult) -> AgyAbsResult:
  match step_res:
    case AgyAbsResult{ctx2,out2,ch2}: AgyAbsResult{ctx2,out2,ch1 || ch2}

@unsafe
def agy_bf_lam(+name: String, +id: U32, +q: U32, +body: KTerm) -> KTerm:
  KLambda{name,id,q,[body],[],0,0,True{}}

@unsafe
def agy_bf_u32(+n: U32) -> KTerm:
  KLiteral{"U32",n,"",0,0}

@unsafe
def agy_bf_nat(+n: U32) -> KTerm:
  KLiteral{"Nat",n,"",0,0}

@unsafe
def agy_bf_is_var(+t: KTerm, +id: U32) -> Bool:
  p98_tag_eq(t,"Var") && U32.is_eq(ix(t),id)

@unsafe
def agy_bf_join(+ch1: Bool, +step_res: AgyBFResult) -> AgyBFResult:
  match step_res:
    case AgyBFResult{ctx2,out2,ch2}: AgyBFResult{ctx2,out2,ch1 || ch2}

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
def p205v_range_and(+rhs: Maybe<&2,U32>) -> W2Range:
  match rhs:
    case Some{k}: W2Range{0,k,True{}}
    case None{}: W2Range{0,0,False{}}

@unsafe
def p205v_pure_op(+op: String) -> Bool:
  String.eq(op,"u32_add") || String.eq(op,"u32_sub") || String.eq(op,"u32_mul") ||
  String.eq(op,"u32_xor") || String.eq(op,"u32_and") || String.eq(op,"u32_or") ||
  String.eq(op,"u32_shln") || String.eq(op,"u32_shrn") ||
  String.eq(op,"u32_is_eq") || String.eq(op,"u32_is_ne") || String.eq(op,"u32_is_lt") ||
  String.eq(op,"u32_is_le") || String.eq(op,"u32_is_gt") || String.eq(op,"u32_is_ge") ||
  String.eq(op,"u32_inc") || String.eq(op,"u32_dec")

@unsafe
def w5c3_bval_false(m: Bool) -> U32:
  match m:
    case True{}: 1
    case False{}: 0

@unsafe
def w5c3_is_range_cmp_op(+op: String) -> Bool:
  String.eq(op,"u32_is_le") || String.eq(op,"u32_is_lt") || String.eq(op,"u32_is_ge") ||
  String.eq(op,"u32_is_gt") || String.eq(op,"u32_is_eq") || String.eq(op,"u32_is_ne")

@unsafe
def w2d_init(xs: List<&2,KTerm>) -> List<&2,KTerm>:
  match xs:
    case Nil{}: []
    case Con{x,Nil{}}: []
    case Con{x,rest}: Con{x,w2d_init(rest)}

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
def w2d_peel_lets_cons(+b: KTerm, +r: W2Lets) -> W2Lets:
  match r:
    case W2Lets{bs,body}: W2Lets{Con{b,bs},body}

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
def w2d_inline_char_res(+orig: KTerm, +ev: P205UResult) -> FFresh:
  match ev:
    case P205UResult{term,n2,_,True{}}: FFresh{term,n2}
    case P205UResult{_,n2,_,False{}}: FFresh{orig,n2}

@unsafe
def w2d_u32_or0(+m: Maybe<&2,U32>) -> U32:
  match m:
    case Some{v}: v
    case None{}: 0

# Lift a closed 1-arg Mat (e.g. step on Space over dynamic state) to a top-level Def so p113d compiles the caller directly!
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
def p98_tag_eq_read(term: KTerm, key: String) -> Bool:
  match term:
    case KTerm{tag, name, id, quant, kids, removed, begin, end}:
      String.eq(tag, key)
    case KLambda{name, id, quant, kids, removed, begin, end, present}:
      String.eq("Lam", key)
    case KLiteral{kind, number, text, begin, end}:
      String.eq("Lit", key)

def p98_tag_eq_finish(same: Bool, term: KTerm, key: String) -> Bool:
  same

# AGY-W5-C3-FRONTEND
def p98_tag_eq(+term: KTerm, +key: String) -> Bool:
  match term:
    case KTerm{tag, _, _, _, _, _, _, _}: String.eq(tag, key)
    case KLambda{_, _, _, _, _, _, _, _}: String.eq("Lam", key)
    case KLiteral{_, _, _, _, _}: String.eq("Lit", key)

# Bounded saturated selector expansion. The syntax gate admits no references,
# primitive calls, data fields, or free variables from the callee body.
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

def p152c_variant(a: KTerm, b: KTerm) -> Bool:
  match a b:
    case KTerm{a0,a1,a2,a3,a4,a5,a6,a7} KTerm{b0,b1,b2,b3,b4,b5,b6,b7}: True{}
    case KLambda{a0,a1,a2,a3,a4,a5,a6,a7} KLambda{b0,b1,b2,b3,b4,b5,b6,b7}: Bool.not(Bool.xor(a7,b7))
    case _ _: False{}

@unsafe
def ntr_target(+target: NC_Target) -> Bool:
  match target:
    case NC_Scheduler{}: False{}
    case NC_Destination{words, +shape, join, owner, params, +tail, signatures}: tail && p98_tag_eq(shape, "NTRMC")

@unsafe
def ntr_owner(+target: NC_Target) -> String:
  match target:
    case NC_Scheduler{}: ""
    case NC_Destination{words, shape, join, +owner, params, tail, signatures}: owner

@unsafe
def ntr_last(xs: List<&2, KTerm>) -> KTerm:
  match xs:
    case Nil{}: {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}
    case Con{h, Nil{}}: h
    case Con{h, rest}: ntr_last(rest)

@unsafe
def ntr_prefix(xs: List<&2, KTerm>) -> List<&2, KTerm>:
  match xs:
    case Nil{}: Nil{}
    case Con{h, Nil{}}: Nil{}
    case Con{h, rest}: Con{h, ntr_prefix(rest)}

@unsafe
def p111_show_cells(d: P111ShowDesc) -> List<&2, P111ShowCell>:
  match d:
    case P111ShowDesc{cells, types, error}: cells

@unsafe
def p111_show_types(d: P111ShowDesc) -> List<&2, KTerm>:
  match d:
    case P111ShowDesc{cells, types, error}: types

@unsafe
def p111_show_error(d: P111ShowDesc) -> String:
  match d:
    case P111ShowDesc{cells, types, error}: error

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
def p111_show_finish_words(names: List<&2, String>, words: P111ShowWords) -> P111Show:
  match words:
    case P111ShowWords{values, error}: P111Show{values, names, error}

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
def p111_body(+code: P111Code) -> List<&2, N111Stmt>:
  match code:
    case P111Code{+body, +segments, +fresh, +error}: body

@unsafe
def p111_segments(+code: P111Code) -> List<&2, N111Segment>:
  match code:
    case P111Code{+body, +segments, +fresh, +error}: segments

@unsafe
def p111_fresh(+code: P111Code) -> U32:
  match code:
    case P111Code{+body, +segments, +fresh, +error}: fresh

@unsafe
def p111_error(+code: P111Code) -> String:
  match code:
    case P111Code{+body, +segments, +fresh, +error}: error

@unsafe
def p111_first(+a: String, +b: String) -> String:
  nt_choose(String, agy_str_eq(a, ""), u => b, u => a)

@unsafe
def p111_fail(+error: String, +n: U32) -> P111Code:
  P111Code{Nil{}, Nil{}, n, error}

@unsafe
def p111_state() -> N111Arg:
  N111Arg{N111Ptr{}, N111Local{"state"}}

@unsafe
def p111_u32(+value: U32) -> N111Arg:
  N111Arg{N111U32{}, N111Const{value, 0}}

@unsafe
def p111_word(+value: N111Value) -> N111Arg:
  N111Arg{N111U64{}, value}

@unsafe
def p111_scratch() -> N111Arg:
  N111Arg{N111Ptr{}, N111Local{"scratch"}}

@unsafe
def p111_env_words(env: List<&2, NC_Binding>) -> List<&2, N111Value>:
  match env:
    case Nil{}: Nil{}
    case Con{NC_Binding{+id, +word, +kind}, +rest}: Con{N111Local{word}, p111_env_words(rest)}

@unsafe
def p111_head(values: List<&2, N111Value>) -> N111Value:
  match values:
    case Nil{}: N111Const{0, 0}
    case Con{+head, +rest}: head

@unsafe
def p111_tail(values: List<&2, N111Value>) -> List<&2, N111Value>:
  match values:
    case Nil{}: Nil{}
    case Con{+head, +rest}: rest

@unsafe
def p111_store(values: List<&2, N111Value>, +index: U32) -> List<&2, N111Stmt>:
  match values:
    case Nil{}: Nil{}
    case Con{+head, +rest}: Con{N111Store{N111U64{}, N111Local{"scratch"}, U32.mul(index, 8), head}, p111_store(rest, U32.inc(index))}

@unsafe
def p111_name(+n: U32) -> String:
  "$p111.k." ++ U32.show(n)

@unsafe
def p111_uint(parsed: Maybe<&2, U32>) -> P111ValueCode:
  match parsed:
    case None{}: P111ValueCode{Nil{}, N111Const{0, 0}, "invalid native U32 literal"}
    case Some{+value}: P111ValueCode{Nil{}, N111Const{value, 0}, ""}

@unsafe
def p111_empty() -> P111Program:
  P111Program{Nil{}, Nil{}, Nil{}, Nil{}, Nil{}, False{}}

@unsafe
def p111_finish_show(+segments: List<&2, N111Segment>, +ctors: List<&2, N_Constructor>, +effects: List<&2, String>, +pure: Bool, show: P111Show) -> P111Result:
  match show:
    case P111Show{+words, +names, +error}: P111Result{P111Program{segments, ctors, words, names, effects, pure}, error}

# ABI11102 capability set; original providers plus byte argv/path effects.
# Adding a foreign provider requires a new runtime capsule and this admission
# catalogue together. This is an internal checked-request backend boundary.
@unsafe
def p111_runtime_names() -> List<&2, String>:
  ["IO.args", "IO.args_bytes", "IO.print", "IO.now", "IO.print_err", "File.open", "File.open_bytes", "File.read", "File.read_line", "File.read_bytes", "File.read_at", "File.size", "File.write", "File.write_at", "File.write_bytes", "File.close", "NativeHost.read", "NativeHost.path", "NativeHost.publish"]

@unsafe
def w5c3_u32_if(cond: Bool, +yes: U32, +no: U32) -> U32:
  match cond:
    case True{}: yes
    case False{}: no

@unsafe
def w5c3_str2_if(cond: Bool, +yes: String, +no: String) -> String:
  match cond:
    case True{}: yes
    case False{}: no

@unsafe
def p111v_name_chars(+name: String, +n: U32) -> Bool:
  match name:
    case SNil{}: U32.is_gt(n,0)
    case SCon{h,t}:
      +c = Char.to_u32(h)
      U32.is_lt(n,128) && ((U32.is_ge(c,65) && U32.is_le(c,90)) ||
        (U32.is_ge(c,97) && U32.is_le(c,122)) || U32.is_eq(c,95) ||
        (U32.is_gt(n,0) && U32.is_ge(c,48) && U32.is_le(c,57))) && p111v_name_chars(t,U32.inc(n))

@unsafe
def p111v_raw_name_chars(+name: String, +count: U32) -> Bool:
  match name:
    case SNil{}: U32.is_gt(count,0)
    case SCon{head,rest}: U32.is_lt(count,4096) && Bool.not(U32.is_eq(Char.to_u32(head),0)) && p111v_raw_name_chars(rest,U32.inc(count))

@unsafe
def p111v_comparison(+op: String) -> Bool:
  String.eq(op,"eq") || String.eq(op,"ne") || String.eq(op,"ult") || String.eq(op,"ule") ||
  String.eq(op,"ugt") || String.eq(op,"uge") || String.eq(op,"slt") || String.eq(op,"sle") ||
  String.eq(op,"sgt") || String.eq(op,"sge")

@unsafe
def w5c3_val_const(w1: Bool, w3: Bool, +width: U32, +lo: U32, +hi: U32) -> Bool:
  match w1:
    case True{}: U32.is_eq(hi,0)
    case False{}:
      match w3:
        case True{}: U32.is_eq(lo,0) && U32.is_eq(hi,0)
        case False{}: U32.is_eq(width,2)

@unsafe
def w5c3_fb_leaf(eq: Bool, rb: List<&2,KDef>) -> List<&2,KDef>:
  match eq:
    case True{}: rb
    case False{}: Nil{}

@unsafe
def w5c3_leaf_from(+h: U32, res: List<&2,KDef>) -> KDef:
  match res:
    case Nil{}: missing()
    case Con{_, _}: KIndexLeaf{h, res}

@unsafe
def w5c3_comb_b(b_abs: Bool, +lh: U32, +lm: U32, +ia: KDef, +ib: KDef) -> KDef:
  match b_abs:
    case True{}: ia
    case False{}: KIndexNode{lh, lm, ia, ib}

@unsafe
def w5c3_sig17(m: Bool) -> List<&2,U32>:
  match m:
    case True{}: [3,1,2,3,1]
    case False{}: []

def p111v_primitive_arities() -> List<&2,U32>:
  [0,2,2,2,2,2,2,2,2,2,2,2,2,1,1,1,2,2,2,2,1,1,2,1,1,1,2,2,2,2,2,2,2,2,2,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,1,1,1,1,1,2,2,2,1,2,2,2,2,2,2,2,3,3,1,1,3,3,3,3,3,3,3,4,3,1]

@unsafe
def w5c3_at_step(z: Bool, +head: U32, rest: List<&2,U32>, +index: U32) -> U32:
  match z:
    case True{}: head
    case False{}: p111v_at(rest,U32.sub(index,1))

@unsafe
def p111v_at(+values: List<&2,U32>, +index: U32) -> U32:
  match values:
    case Nil{}: 4294967295
    case Con{head,rest}: w5c3_at_step(U32.is_eq(index,0), head, rest, index)

def w5c3_lit_ok(z: Bool, lo: U32) -> U32:
  match z:
    case True{}: lo
    case False{}: 4294967295

def p111v_state_argument(args: List<&2,N111Arg>) -> Bool:
  match args:
    case Con{N111Arg{N111Ptr{},N111Local{name}},rest}: String.eq(name,"state")
    case _: False{}

@unsafe
def w5c3_finish_if(has_err: Bool, +error: String, terminal: Bool) -> String:
  match has_err:
    case True{}: error
    case False{}:
      match terminal:
        case True{}: ""
        case False{}: "segment has a nonterminal path"

@unsafe
def p111q_div10(+lo: U32, +hi: U32) -> P111QDecimal:
  +a = U32.shrn(hi,16n)
  +b = U32.add(U32.mul(U32.mod(a,10),65536),U32.and(hi,65535))
  +c = U32.add(U32.mul(U32.mod(b,10),65536),U32.shrn(lo,16n))
  +d = U32.add(U32.mul(U32.mod(c,10),65536),U32.and(lo,65535))
  P111QDecimal{U32.add(U32.mul(U32.div(c,10),65536),U32.div(d,10)),
    U32.add(U32.mul(U32.div(a,10),65536),U32.div(b,10)),U32.mod(d,10)}

def p111q_nonempty(items: List<&2,P111QDatum>) -> List<&2,P111QDatum>:
  match items:
    case Nil{}: [P111QByte{0}]
    case Con{head,rest}: Con{head,rest}

@unsafe
def p111q_utf8_char(+code: U32, +acc: List<&2,P111QDatum>) -> List<&2,P111QDatum>:
  nt_choose(List<&2,P111QDatum>,U32.is_lt(code,128),u => Con{P111QByte{code},acc},u =>
    nt_choose(List<&2,P111QDatum>,U32.is_lt(code,2048),u =>
      Con{P111QByte{U32.add(128,U32.and(code,63))},Con{P111QByte{U32.add(192,U32.shrn(code,6n))},acc}},u =>
      nt_choose(List<&2,P111QDatum>,U32.is_lt(code,65536),u =>
        Con{P111QByte{U32.add(128,U32.and(code,63))},Con{P111QByte{U32.add(128,U32.and(U32.shrn(code,6n),63))},Con{P111QByte{U32.add(224,U32.shrn(code,12n))},acc}}},u =>
        Con{P111QByte{U32.add(128,U32.and(code,63))},Con{P111QByte{U32.add(128,U32.and(U32.shrn(code,6n),63))},Con{P111QByte{U32.add(128,U32.and(U32.shrn(code,12n),63))},Con{P111QByte{U32.add(240,U32.shrn(code,18n))},acc}}}})))

def p112_liveness_uses(plan: P112Liveness) -> NU_Set:
  match plan:
    case P112LivenessEmpty{}: NU_Empty{}
    case P112LivenessLeaf{term, uses}: uses
    case P112LivenessLet{value, id, uses, rest}: uses

# Scan each original binding once, backwards. Using the complete original head
# retains nc_uses' behavior even for extra children in a raw Bind-shaped node.


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


def p112_scalar_result(body: List<&2, N111Stmt>) -> P111ValueCode:
  P111ValueCode{body, N111Local{"value"}, ""}


def p112_scalar_mask() -> N111Value:
  N111Const{4294967295, 0}


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
def p112t_tail_nodes(body: List<&2,N111Stmt>, left: U32) -> List<&2,P112TailStmt>:
  match body left:
    case _ 0: [P112TailAgain{}]
    case Con{stmt,rest} _: Con{P112TailScalar{stmt},p112t_tail_nodes(rest,U32.sub(left,1))}
    case _ _: []


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


def p112t_scalars(body: List<&2,N111Stmt>) -> List<&2,P112TailStmt>:
  match body:
    case Nil{}: []
    case Con{stmt,rest}: Con{P112TailScalar{stmt},p112t_scalars(rest)}


@unsafe
def p112t_branch(+condition: N111Value, yes: P112TailBody, no: P112TailBody, tail: P112TailBody) -> P112TailBody:
  match yes no tail:
    case P112TailBody{yv,yl,yb} P112TailBody{nv,nl,nb} P112TailBody{tv,tl,tb}:
      P112TailBody{yv && nv && tv,U32.add(yl,U32.add(nl,tl)),Con{P112TailIf{condition,yb,nb},tb}}


@unsafe
def p112t_finish(+params: List<&2,String>, +prefix: List<&2,N111Stmt>, body: P112TailBody) -> P112TailPlan:
  match body:
    case P112TailBody{valid,loops,nodes}: P112TailPlan{valid && U32.is_gt(loops,0),loops,params,prefix,nodes}


def p112t_admitted(plan: P112TailPlan) -> Bool:
  match plan:
    case P112TailPlan{valid,loops,params,prefix,body}: valid


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
def p112a_tag(+name: String, word: N111Value) -> List<&2, N111Stmt>:
  [N111Bin{name, N111U64{}, "shr", word, N111Const{40, 0}},
   N111Bin{name, N111U64{}, "and", N111Local{name}, N111Const{65535, 0}}]


@unsafe
def p112_special_safe(word: N111Value) -> Bool:
  match word:
    case N111Local{+name}:
      Bool.not(agy_str_eq(name, "p112_b_raw") || agy_str_eq(name, "p112_b_bits") || agy_str_eq(name, "p112_b_expected") || agy_str_eq(name, "p112_b_boxed"))
    case _: True{}

# Bits40..55 are aux, bits56..62 are the7-bit tag; bit63 is RFC.
# A packed True may have arbitrary location bits and either RFC bit.


@unsafe
def p185_bool_safe_value(value: N111Value) -> Bool:
  match value:
    case N111Local{name}: Bool.not(String.starts_with(name, "p185_bool_"))
    case _: True{}


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
def p112w_nodes(body: List<&2,N111Stmt>, left: U32, +last: P112WorkerStmt) -> List<&2,P112WorkerStmt>:
  match body left:
    case _ 0: [last]
    case Con{stmt,rest} _: Con{P112WorkerScalar{stmt},p112w_nodes(rest,U32.sub(left,1),last)}
    case _ _: []


@unsafe
def p112w_branch(+condition: N111Value, yes: P112WorkerBody, no: P112WorkerBody, tail: P112WorkerBody) -> P112WorkerBody:
  match yes no tail:
    case P112WorkerBody{yv,yc,yb} P112WorkerBody{nv,nc,nb} P112WorkerBody{tv,tc,tb}:
      P112WorkerBody{yv && nv && tv,U32.add(yc,U32.add(nc,tc)),Con{P112WorkerIf{condition,yb,nb},tb}}

# A worker already admitted in an earlier immutable pass keeps its exact rank;
# no subsequent pass needs to reconstruct its plan merely to discard it.

def p112w_finish(+params: List<&2,String>, body: P112WorkerBody) -> P112WorkerPlan:
  match body:
    case P112WorkerBody{valid,calls,nodes}: P112WorkerPlan{valid,calls,params,nodes}

def p112w_admitted(plan: P112WorkerPlan) -> Bool:
  match plan:
    case P112WorkerPlan{valid,calls,params,body}: valid

# Public terminal calls can use a private target even when their caller is a
# continuation. The retained rt_return performs its original pending-frame work.


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


def p112s_uint(value: Maybe<&2,U32>) -> U32:
  match value:
    case None{}: 0
    case Some{word}: word


def p112s_terms_cons(head: KTerm, tail: P112STerms) -> P112STerms:
  match tail:
    case P112STerms{rest,image}: P112STerms{Con{head,rest},image}


def p112s_context_ctors_list(children: List<&2,KDef>) -> KDef:
  match children:
    case Con{facts,Con{original,Con{constructors,Con{nodes,Nil{}}}}}: constructors
    case _: missing()


def p112s_context_nodes_list(children: List<&2,KDef>) -> KDef:
  match children:
    case Con{facts,Con{original,Con{constructors,Con{nodes,Nil{}}}}}: nodes
    case _: missing()


def p112s_datum(value: N111Value) -> P111QDatum:
  match value:
    case N111Const{lo,hi}: P111QLong{lo,hi}
    case _: P111QReloc{"INVALID_P112_STATIC_WORD",0}


def p112s_descriptor_item(item: P111QDatum, index: U32, size: U32) -> P111QDatum:
  match index:
    case 8: P111QLong{size,0}
    case 19: P111QReloc{"p111_static_image",0}
    case _: item


def p112w_failure_nodes(body: List<&2,N111Stmt>) -> List<&2,P112WorkerStmt>:
  match body:
    case Nil{}: []
    case Con{stmt,rest}: Con{P112WorkerScalar{stmt},p112w_failure_nodes(rest)}


def p112e_tail_valid(body: P112TailBody) -> Bool:
  match body:
    case P112TailBody{valid,loops,nodes}: valid


def p112e_worker_valid(body: P112WorkerBody) -> Bool:
  match body:
    case P112WorkerBody{valid,calls,nodes}: valid


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


@unsafe
def p112fp_supported(+id: U32, +count: U32) -> Bool:
  (U32.is_eq(id,23) && U32.is_eq(count,1)) ||
    (U32.is_ge(id,26) && U32.is_le(id,35) && U32.is_eq(count,2))


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


def p112f_index_present(found: Maybe<&2,N111Segment>) -> Bool:
  match found:
    case None{}: False{}
    case Some{+segment}: True{}


@unsafe
def w7c_p112f_badd(pres: Bool, +bucket: List<&2,N111Segment>, +segment: N111Segment) -> List<&2,N111Segment>:
  match pres:
    case True{}: bucket
    case False{}: Con{segment,bucket}

law p112f_index_tip:
  for tree: P112FusionIndex
  for +hash: U32
  U32

@unsafe
def w7c_p112f_tip_lr(bit: U32, left: P112FusionIndex, right: P112FusionIndex, +hash: U32) -> U32:
  match bit:
    case 0: p112f_index_tip(left,hash)
    case _: p112f_index_tip(right,hash)

@unsafe
def p112f_index_tip(tree, hash):
  match tree:
    case P112FusionEmpty{}: hash
    case P112FusionLeaf{+stored,+bucket}: stored
    case P112FusionNode{+mask,+left,+right}:
      w7c_p112f_tip_lr(U32.and(hash,mask),left,right,hash)


@unsafe
def w7c_p112f_join_lr(bit: U32, +tree: P112FusionIndex, +segment: N111Segment, +hash: U32, +mask: U32) -> P112FusionIndex:
  match bit:
    case 0: P112FusionNode{mask,P112FusionLeaf{hash,[segment]},tree}
    case _: P112FusionNode{mask,tree,P112FusionLeaf{hash,[segment]}}

@unsafe
def p112f_clean_name(+name: String) -> Bool:
  Bool.not(String.starts_with(name,"p112f_"))


@unsafe
def p112f_size(body: List<&2,N111Stmt>) -> U32:
  match body:
    case Nil{}: 0
    case Con{N111If{+condition,+yes,+no},+rest}: U32.add(1,U32.add(p112f_size(yes),U32.add(p112f_size(no),p112f_size(rest))))
    case Con{+stmt,+rest}: U32.inc(p112f_size(rest))


@unsafe
def p112f_snapshots(values: List<&2,N111Value>, +prefix: String, +kind: String, +index: U32) -> List<&2,N111Stmt>:
  match values:
    case Nil{}: []
    case Con{+value,+rest}: Con{N111Set{prefix ++ kind ++ U32.show(index),N111U64{},value},p112f_snapshots(rest,prefix,kind,U32.inc(index))}


@unsafe
def p112f_callargs(+count: U32, +index: U32, +prefix: String) -> List<&2,N111Arg>:
  nt_choose(List<&2,N111Arg>,U32.is_eq(count,index),u => [],u =>
    Con{N111Arg{N111U64{},N111Local{prefix ++ "arg_" ++ U32.show(index)}},p112f_callargs(count,U32.inc(index),prefix)})


@unsafe
def p112f_prepend(+stmt: N111Stmt, tail: P112FusionBody) -> P112FusionBody:
  match tail:
    case P112FusionBody{+body,+count,+next}: P112FusionBody{Con{stmt,body},count,next}


@unsafe
def p112f_scan_rest(+condition: N111Value, +yes: List<&2,N111Stmt>, +no: List<&2,N111Stmt>, +bc: U32, rest: P112FusionBody) -> P112FusionBody:
  match rest:
    case P112FusionBody{+body,+count,+next}: P112FusionBody{Con{N111If{condition,yes,no},body},U32.add(bc,count),next}


@unsafe
def p112m_mask(+depth: U32) -> U32:
  nt_choose(U32,U32.is_eq(depth,32),u => 4294967295,u => U32.sub(U32.shln(1,U32.to_nat(depth)),1))


@unsafe
def p112r_buffer_sites(+name: String, +sites: U32, +index: U32) -> Bool:
  nt_choose(Bool,U32.is_eq(index,sites),u => False{},u =>
    agy_str_eq(name,"p112f_" ++ U32.show(index) ++ "_local_scratch") || p112r_buffer_sites(name,sites,U32.inc(index)))


@unsafe
def p112r_words(args: List<&2,N111Arg>, +count: U32) -> Bool:
  match args:
    case Nil{}: U32.is_eq(count,0)
    case Con{N111Arg{N111U64{},+value},+rest}: U32.is_gt(count,0) && p112r_words(rest,U32.sub(count,1))
    case _: False{}


@unsafe
def p112r_head_buffer(body: List<&2,N111Stmt>) -> String:
  match body:
    case Con{N111Store{N111U64{},N111Local{+base},+offset,+value},+rest}: base
    case Con{N111Call{+dest,N111U64{},+symbol,Con{+state,Con{+target,Con{N111Arg{N111Ptr{},N111Local{+base}},+rest}}}},+tail}: base
    case _: ""


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


def p112c_more(plan: P112FusionBody) -> P112FusionBody:
  match plan:
    case P112FusionBody{+body,+count,+next}: P112FusionBody{body,U32.inc(count),next}


def p112g_prepend(+stmt: N111Stmt, found: Maybe<&2,List<&2,N111Stmt>>) -> Maybe<&2,List<&2,N111Stmt>>:
  match found:
    case None{}: None{}
    case Some{+body}: Some{Con{stmt,body}}

# The pinned p112f_fused scaffold begins with capture-count snapshots and one
# zero frame-result assignment. The gap must follow these, and precede every
# argument snapshot. An unexpectedly short scaffold refuses the whole attempt.


def p112to_nonowning(kind: N_WordKind) -> Bool:
  match kind:
    case N_W32{}: True{}
    case N_Imm64{}: True{}
    case _: False{}


@unsafe
def p113d_body(+code: P113DCode) -> List<&2,P113DStmt>:
  match code:
    case P113DCode{body,fresh,error,calls}: body


@unsafe
def p113d_fresh(+code: P113DCode) -> U32:
  match code:
    case P113DCode{body,fresh,error,calls}: fresh


@unsafe
def p113d_error(+code: P113DCode) -> String:
  match code:
    case P113DCode{body,fresh,error,calls}: error


@unsafe
def p113d_calls(+code: P113DCode) -> List<&2,String>:
  match code:
    case P113DCode{body,fresh,error,calls}: calls


def p113d_scalars(body: List<&2,N111Stmt>) -> List<&2,P113DStmt>:
  match body:
    case Nil{}: []
    case Con{stmt,rest}: Con{P113DScalar{stmt},p113d_scalars(rest)}


def p113d_fail(error: String, n: U32) -> P113DCode:
  P113DCode{[],n,error,[]}


@unsafe
def p113d_result(word: N111Value, target: P113DTarget, n: U32) -> P113DCode:
  match target:
    case P113DReturn{}: P113DCode{[P113DResult{[word]}],n,"",[]}
    case P113DLocal{name}: P113DCode{[P113DScalar{N111Set{name,N111U64{},word}}],n,"",[]}


@unsafe
def p113d_tail(target: P113DTarget) -> Bool:
  match target:
    case P113DReturn{}: True{}
    case _: False{}


@unsafe
def w6_p113d_self_nontail(+name: String, args: List<&2,N111Value>, target: P113DTarget, n: U32) -> P113DCode:
  match target:
    case P113DReturn{}: P113DCode{[P113DAgain{args}],n,"",[]}
    case P113DLocal{dest}: P113DCode{[P113DCall{[dest],name,args}],n,"",[]}

@unsafe
def p113d_call_target(+name: String, args: List<&2,N111Value>, target: P113DTarget, n: U32) -> P113DCode:
  match target:
    case P113DReturn{}: P113DCode{[P113DCall{["p113_result"],name,args},P113DResult{[N111Local{"p113_result"}]}],n,"",[name]}
    case P113DLocal{dest}: P113DCode{[P113DCall{[dest],name,args}],n,"",[name]}

# Scalar snippets are reused whole, including their own checked shifts and
# branches. The direct path never interprets generated backend text.


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
def p113p_boxed(code: P111ValueCode) -> P113PValueCode:
  match code:
    case P111ValueCode{+body,+value,+error}: P113PValueCode{body,[value],error}


@unsafe
def p113p_array_arity(id: U32) -> U32:
  match id:
    case 72: 2
    case 74: 3
    case 75: 1
    case 76: 1
    case _: 0


@unsafe
def p113pl_shape(+target: P113PTarget) -> KTerm:
  match target:
    case P113PTarget{destinations,shape,tail,owner,signatures}: shape


@unsafe
def p113pl_owner(+target: P113PTarget) -> String:
  match target:
    case P113PTarget{destinations,shape,tail,owner,signatures}: owner


@unsafe
def p113pl_signatures(+target: P113PTarget) -> List<&2,KDef>:
  match target:
    case P113PTarget{destinations,shape,tail,owner,signatures}: signatures


@unsafe
def p113pl_tail(+target: P113PTarget) -> Bool:
  match target:
    case P113PTarget{destinations,shape,tail,owner,signatures}: tail


@unsafe
def p113pl_local(+target: P113PTarget, destinations: List<&2,String>, shape: KTerm) -> P113PTarget:
  match target:
    case P113PTarget{old,prior,tail,owner,signatures}: P113PTarget{destinations,shape,False{},owner,signatures}

# Only the mature semantic shape query consumes this view. No NC_Code or C
# expression is generated, read or interpreted by the structured product path.


@unsafe
def p113pl_view(+target: P113PTarget) -> NC_Target:
  match target:
    case P113PTarget{destinations,shape,tail,owner,signatures}: NC_Destination{destinations,shape,"",owner,[],tail,signatures}


@unsafe
def p113pl_names(+base: String, +count: U32, +i: U32) -> List<&2,String>:
  nt_choose(List<&2,String>,U32.is_eq(i,count),u => [],u => Con{base ++ "_" ++ U32.show(i),p113pl_names(base,count,U32.inc(i))})


def p113pl_locals(names: List<&2,String>) -> List<&2,N111Value>:
  match names:
    case Nil{}: []
    case Con{name,rest}: Con{N111Local{name},p113pl_locals(rest)}


def p113pl_sets(names: List<&2,String>, values: List<&2,N111Value>) -> List<&2,N111Stmt>:
  match names values:
    case Con{name,rest} Con{value,more}: Con{N111Set{name,N111U64{},value},p113pl_sets(rest,more)}
    case _ _: []


@unsafe
def p113pl_zeroes(+count: U32) -> List<&2,N111Value>:
  nt_choose(List<&2,N111Value>,U32.is_eq(count,0),u => [],u => Con{N111Const{0,0},p113pl_zeroes(U32.sub(count,1))})


@unsafe
def w8_push_rev(xs: List<&2,P113DCandidate>, acc: List<&2,P113DCandidate>) -> List<&2,P113DCandidate>:
  match xs:
    case Nil{}: acc
    case Con{h,t}: w8_push_rev(t,Con{h,acc})

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


def p113n_is_imm(kind: N_WordKind) -> Bool:
  match kind:
    case N_Imm64{}: True{}
    case _: False{}


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
def p113i_put_leaf(table: P113ITable, function: P113DFunction) -> P113ITable:
  match table:
    case P113IBucket{values}: P113IBucket{Con{function,values}}
    case _: P113IBucket{[function]}

@unsafe
def p113i_name(+name: String) -> Bool:
  Bool.not(String.starts_with(name,"p113i_"))


@unsafe
def p113i_add(left: U32, right: U32) -> U32:
  U32.min(32768,U32.add(left,right))


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

@unsafe
def p113i_stack_add(left: U32, right: U32) -> U32:
  U32.min(65536,U32.add(left,right))


@unsafe
def p113i_prepend(stmt: P113DStmt, scan: P113IScan) -> P113IScan:
  match scan:
    case P113IScan{body,next,budget}: P113IScan{Con{stmt,body},next,budget}


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
def w4c_body_has_again(body: List<&2,P113DStmt>) -> Bool:
  match body:
    case Nil{}: False{}
    case Con{P113DAgain{_},_}: True{}
    case Con{P113DIf{_,y,n},rest}: w4c_body_has_again(y) || w4c_body_has_again(n) || w4c_body_has_again(rest)
    case Con{_,rest}: w4c_body_has_again(rest)

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


@unsafe
def p113j_assign(destinations: List<&2,String>, +prefix: String, +index: U32) -> List<&2,P113DStmt>:
  match destinations:
    case Nil{}: []
    case Con{dest,rest}:
      Con{P113DScalar{N111Set{dest,N111U64{},N111Local{prefix ++ "result_" ++ U32.show(index)}}},
        p113j_assign(rest,prefix,U32.inc(index))}


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
def w5_callee_name(callee: P113DFunction) -> String:
  match callee:
    case P113DFunction{name,_,_,_,_}: name

@unsafe
def w4g_has_const_arg(args: List<&2,N111Value>) -> Bool:
  match args:
    case Nil{}: False{}
    case Con{N111Const{_,_},_}: True{}
    case Con{_,rest}: w4g_has_const_arg(rest)


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
def w7c_p113j_calls_acc(body: List<&2,P113DStmt>, acc: List<&2,String>) -> List<&2,String>:
  match body:
    case Nil{}: acc
    case Con{P113DCall{destinations,target,args},rest}:
      Con{target,w7c_p113j_calls_acc(rest,acc)}
    case Con{P113DIf{condition,yes,no},rest}:
      w7c_p113j_calls_acc(yes,w7c_p113j_calls_acc(no,w7c_p113j_calls_acc(rest,acc)))
    case Con{stmt,rest}: w7c_p113j_calls_acc(rest,acc)

@unsafe
def p113a_enabled(certificate: P113ACertificate) -> Bool:
  match certificate:
    case P113ACertificate{scalar,unshared}: scalar


@unsafe
def p113a_name(n: U32, role: String) -> String:
  "p113a_" ++ U32.show(n) ++ "_" ++ role


@unsafe
def p113a_val_name(v: N111Value) -> String:
  match v:
    case N111Local{name}: name
    case _: ""


@unsafe
def p113a_local_name(name: String) -> Bool:
  Bool.not(String.starts_with(name,"p113a_"))


@unsafe
def p113a_function_done(name: String, params: List<&2,NC_Binding>, result: U32, public: Bool, scan: P113ABody) -> P113DFunction:
  match scan:
    case P113ABody{body,next}: P113DFunction{name,params,result,public,body}


@unsafe
def w5c2_bits1(ge2: Bool, +b: U32) -> U32:
  match ge2:
    case True{}: U32.add(b, 2)
    case False{}: U32.inc(b)

@unsafe
def w5c2_p113k_bound_if(z: Bool, +bits: U32) -> P113KFact:
  match z:
    case True{}: P113KFact{0, True{}, 0, 0}
    case False{}: P113KFact{U32.min(bits, 64), False{}, 0, 0}

@unsafe
def w5c2_p113k_atom_if(exact: Bool, +lo: U32, +hi: U32, +value: N111Value) -> N111Value:
  match exact:
    case True{}: N111Const{lo,hi}
    case False{}: value

@unsafe
def w5c2_ones_if(is32: Bool, +bits: U32) -> U32:
  match is32:
    case True{}: 4294967295
    case False{}: U32.sub(U32.shln(1, U32.to_nat(bits)), 1)

@unsafe
def p113k_bits_of(fact: P113KFact) -> U32:
  match fact:
    case P113KFact{bits,exact,lo,hi}: bits

@unsafe
def p113k_zero(fact: P113KFact) -> Bool:
  match fact:
    case P113KFact{bits,exact,lo,hi}: U32.is_eq(bits,0)

@unsafe
def w4g_ic_res(+name: String) -> Bool:
  agy_str_eq(name,"state") || agy_str_eq(name,"scratch") ||
    agy_str_eq(name,"__x181_result_out") || agy_str_eq(name,"__x181_results") ||
    agy_str_eq(name,"__x181_tail")


@unsafe
def w4g_ic_rename_last(body: List<&2,P113DStmt>, +newDst: String) -> List<&2,P113DStmt>:
  match body:
    case Con{P113DScalar{N111Set{_,t,v}},Nil{}}: [P113DScalar{N111Set{newDst,t,v}}]
    case Con{P113DScalar{N111Bin{_,t,op,l,r}},Nil{}}: [P113DScalar{N111Bin{newDst,t,op,l,r}}]
    case Con{h,rest}: Con{h,w4g_ic_rename_last(rest,newDst)}
    case Nil{}: []


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
def w4g_wrap_scalars(stmts: List<&2,N111Stmt>) -> List<&2,P113DStmt>:
  match stmts:
    case Nil{}: []
    case Con{s,rest}: Con{P113DScalar{s},w4g_wrap_scalars(rest)}


@unsafe
def w4g_copy_out(res: W4GCopyBd) -> List<&2,P113DStmt>:
  match res:
    case W4GCopyBd{out,_}: out


@unsafe
def w4g_arm_last_dst(body: List<&2,P113DStmt>) -> String:
  match body:
    case Con{P113DScalar{N111Set{n,_,_}},Nil{}}: n
    case Con{P113DScalar{N111Bin{n,_,_,_,_}},Nil{}}: n
    case Con{_,rest}: w4g_arm_last_dst(rest)
    case Nil{}: ""


@unsafe
def w4g_arm_rename_last(body: List<&2,P113DStmt>, +newDst: String) -> List<&2,P113DStmt>:
  match body:
    case Con{P113DScalar{N111Set{_,t,v}},Nil{}}: [P113DScalar{N111Set{newDst,t,v}}]
    case Con{P113DScalar{N111Bin{_,t,op,l,r}},Nil{}}: [P113DScalar{N111Bin{newDst,t,op,l,r}}]
    case Con{h,rest}: Con{h,w4g_arm_rename_last(rest,newDst)}
    case Nil{}: []


@unsafe
def w4g_bwd_out(res: W4GBwd) -> List<&2,P113DStmt>:
  match res:
    case W4GBwd{out,_}: out


@unsafe
def w4g_p113k_body_only(scan: P113KBody) -> List<&2,P113DStmt>:
  match scan:
    case P113KBody{body,_,_}: body


@unsafe
def p113ai_first(values: List<&2,N111Value>) -> N111Value:
  match values:
    case Con{value,rest}: value
    case Nil{}: N111Symbol{"invalid_array_identity"}


@unsafe
def p185k_bool_primitive(+id: U32, +count: U32) -> Bool:
  (U32.is_eq(count,1) && U32.is_eq(id,21)) ||
    (U32.is_eq(count,2) && ((U32.is_ge(id,7) && U32.is_le(id,12)) ||
      (U32.is_ge(id,30) && U32.is_le(id,35)) || (U32.is_ge(id,67) && U32.is_le(id,69))))


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
def w4k_slot_key(+buf: String, +offset: U32) -> String:
  "@w4slot:" ++ buf ++ ":" ++ U32.show(offset)


@unsafe
def p113bq_scalar(yes: List<&2,N111Stmt>, no: List<&2,N111Stmt>) -> P113BQDiamond:
  match yes no:
    case Con{N111Set{+a,N111U64{},N111Const{1,0}},Nil{}} Con{N111Set{b,N111U64{},N111Const{0,0}},Nil{}}:
      nt_choose(P113BQDiamond,agy_str_eq(a,b),u => P113BQYes{a,False{}},u => P113BQNo{})
    case Con{N111Set{+a,N111U64{},N111Const{0,0}},Nil{}} Con{N111Set{b,N111U64{},N111Const{1,0}},Nil{}}:
      nt_choose(P113BQDiamond,agy_str_eq(a,b),u => P113BQYes{a,True{}},u => P113BQNo{})
    case _ _: P113BQNo{}


@unsafe
def p113l_ones(fact: P113KFact) -> Bool:
  match fact:
    case P113KFact{bits,exact,lo,hi}: U32.is_ne(lo,0) || U32.is_ne(hi,0)


@unsafe
def p113l_exact_one(fact: P113KFact) -> Bool:
  match fact:
    case P113KFact{bits,exact,lo,hi}: exact && U32.is_eq(lo,1) && U32.is_eq(hi,0)


def p114r_prefix(body: List<&2,N111Stmt>, count: U32) -> List<&2,N111Stmt>:
  match body count:
    case _ 0: []
    case Con{stmt,rest} _: Con{stmt,p114r_prefix(rest,U32.sub(count,1))}
    case _ _: []

# Retain every argument store and preceding scalar operation; exclude only the
# exact final jump+machine return. No branch/frame/unknown call can intervene.


def p114r_without_transition(body: List<&2,N111Stmt>) -> List<&2,N111Stmt>:
  match body:
    case Con{first,Con{second,Nil{}}}: []
    case Con{first,rest}: Con{first,p114r_without_transition(rest)}
    case _: []


@unsafe
def p114h_clean_name(+name: String) -> Bool:
  Bool.not(String.starts_with(name,"p114h_") || String.starts_with(name,"p114r_"))


def p114h_refused() -> P114HPlan:
  P114HPlan{False{},[],[],[]}


def p114h_scalars(body: List<&2,N111Stmt>, tail: List<&2,P114RStmt>) -> List<&2,P114RStmt>:
  match body:
    case Nil{}: tail
    case Con{stmt,rest}: Con{P114RScalar{stmt},p114h_scalars(rest,tail)}


@unsafe
def p114h_call_name(index: U32) -> String:
  "p114h_arg_" ++ U32.show(index)


def p114h_closed(params: List<&2,String>, body: List<&2,P114RStmt>, closed: P114HClosed) -> P114HPlan:
  match closed:
    case P114HClosed{valid,cases}: P114HPlan{valid,params,body,cases}


def p114h_valid(plan: P114HPlan) -> Bool:
  match plan:
    case P114HPlan{valid,params,body,cases}: valid


@unsafe
def p114h_prefix(index: U32) -> String:
  "p114h_case_" ++ U32.show(index) ++ "_"


@unsafe
def p114t_name(site: U32, role: String) -> String:
  "p114t_" ++ U32.show(site) ++ "_" ++ role


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
def p114t_local_name(+name: String) -> Bool:
  Bool.not(String.starts_with(name,"p114t_"))


@unsafe
def p117h_bit(+origin: U32) -> U32:
  nt_choose(U32,U32.is_eq(origin,0),u => 0,u => U32.shln(1,U32.to_nat(U32.sub(origin,1))))


def p117h_abort(scan: P117HScan) -> P117HScan:
  match scan:
    case P117HScan{facts,slots,mask,used,again,left,next,sites}:
      P117HScan{missing(),missing(),0,used,again,0,next,sites}


def p117h_raw_tag() -> U32: 4

def p117h_index_shift() -> U32: 2

def p117h_cell_type() -> N111Type: N111U32{}


@unsafe
def w4c_local_name(v: N111Value) -> String:
  match v:
    case N111Local{src}: src
    case _: ""

@unsafe
def w4c_const_u32_any(v: N111Value) -> Maybe<&2,U32>:
  match v:
    case N111Const{lo,0}: Some{lo}
    case _: None{}

@unsafe
def w5_set_loc_val(+dst: String, v: N111Value) -> W5SetLoc:
  match v:
    case N111Local{s}: W5SetLoc{dst,s}
    case _: W5SetLocNone{}

@unsafe
def w5_arm_loc_pair2(+t: String, +src: String, s2: W5SetLoc) -> W5SetLoc:
  match s2:
    case W5SetLoc{dst,s}: nt_choose(W5SetLoc,agy_str_eq(t,s),u => W5SetLoc{dst,src},u => W5SetLocNone{})
    case W5SetLocNone{}: W5SetLocNone{}

@unsafe
def w5_loc_dst(x: W5SetLoc) -> String:
  match x:
    case W5SetLoc{dst,_}: dst
    case W5SetLocNone{}: ""

@unsafe
def w5_loc_src(x: W5SetLoc) -> String:
  match x:
    case W5SetLoc{_,src}: src
    case W5SetLocNone{}: ""

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
def w4c_opt_eq(m: Maybe<&2,U32>, +x: U32) -> Bool:
  match m:
    case Some{v}: U32.is_eq(v,x)
    case None{}: False{}

@unsafe
def w4c_guard_ule(+gn: String, +lhs: N111Value, +rhs: N111Value) -> List<&2,N111Stmt>:
  [N111Bin{gn,N111U64{},"ule",lhs,rhs},
   N111Bin{"p113a_version_guard",N111U32{},"and",N111Local{"p113a_version_guard"},N111Local{gn}}]

@unsafe
def w4c_has_bit(+mask: U32, +i: U32) -> Bool:
  U32.is_lt(i,31) && U32.is_ne(U32.and(mask,U32.shln(1,U32.to_nat(i))),0)

def p118t_state() -> List<&2,N111Value>:
  [N111Local{"p118_root"},N111Local{"p118_parent"}]


@unsafe
def p118t_prefix(values: List<&2,N111Value>, +count: U32) -> List<&2,N111Value>:
  match values count:
    case _ 0: []
    case Con{head,rest} _: Con{head,p118t_prefix(rest,U32.sub(count,1))}
    case _ _: []


@unsafe
def p118t_rest(+values: List<&2,N111Value>, +count: U32) -> List<&2,N111Value>:
  match values count:
    case _ 0: values
    case Con{head,rest} _: p118t_rest(rest,U32.sub(count,1))
    case _ _: []


@unsafe
def p118t_import(+symbol: String) -> Bool:
  agy_str_eq(symbol,"p118_rt_extend") || agy_str_eq(symbol,"p118_rt_finish")


@unsafe
def p118b_read_name(owner: String) -> String:
  "$p118borrow.read." ++ owner


@unsafe
def p118b_value_name(n: U32) -> String:
  "p118b_value_" ++ U32.show(n)


@unsafe
def p118c_cap_item(item: P111QDatum) -> P111QDatum:
  match item:
    case P111QLong{lo,hi}: P111QLong{U32.or(lo,8),hi}
    case _: item


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

def p147z_runtime_111(symbol: String) -> Bool:
  match symbol:
    case "keep": True{}
    case "sink": True{}
    case "ctor": True{}
    case "take": True{}
    case "closure": True{}
    case "tag": True{}
    case "frame": True{}
    case "jump": True{}
    case "return": True{}
    case "apply": True{}
    case "stack_pop": True{}
    case "stack_get": True{}
    case "reg_get": True{}
    case "fail": True{}
    case "op": True{}
    case "special_ctor": True{}
    case "special_test": True{}
    case "special_take": True{}
    case _: False{}
def p147z_runtime_118(symbol: String) -> Bool:
  match symbol:
    case "extend": True{}
    case "finish": True{}
    case "borrow_fields": True{}
    case "borrow_scalar_safe": True{}
    case _: False{}

@unsafe
def p118z_cap_item(item: P111QDatum) -> P111QDatum:
  match item:
    case P111QLong{lo,hi}: P111QLong{U32.or(lo,4),hi}
    case _: item


@unsafe
def p118xs_prefix(args: List<&2,N111Arg>) -> List<&2,N111Arg>:
  match args:
    case Con{a,Con{b,Con{c,Con{d,Con{count,Nil{}}}}}}: [a,b,c,d]
    case _: []


@unsafe
def p118ns_worker_functions(workers: P118BWorkers) -> List<&2,P113DFunction>:
  match workers:
    case P118BWorkers{functions,error}: functions


@unsafe
def p118ns_worker_error(workers: P118BWorkers) -> String:
  match workers:
    case P118BWorkers{functions,error}: error


@unsafe
def p118ns_zero_byte(items: List<&2,P111QDatum>, +found: Bool) -> Bool:
  match items:
    case Nil{}: found
    case Con{P111QByte{value},rest}: p118ns_zero_byte(rest,found || U32.is_eq(value,0))
    case Con{item,rest}: p118ns_zero_byte(rest,found)


@unsafe
def p121f_children(xs: List<&2,KTerm>, +depth: U32) -> List<&2,KTerm>:
  match xs:
    case Nil{}: []
    case Con{head,rest}: Con{kt("P121Depth","",depth,0,[head]),p121f_children(rest,depth)}

# Finite syntax budget before recursive shape/scalar checks. Worklist depth is
# explicit and covers every child, including annotations. Exhaustion refuses.

def p121f_ref(name: String) -> N111Value:
  N111Local{name}


@unsafe
def p121f_env(binder: KTerm, word: String) -> NC_Binding:
  NC_Binding{ix(binder),word,N_W32{}}


@unsafe
def p198e_triple(+a: P198EArm, +b: P198EArm, +c: P198EArm) -> Bool:
  match a b c:
    case P198EArm{oa,la,va,sa} P198EArm{ob,lb,vb,sb} P198EArm{oc,lc,vc,sc}: True{}
    case _ _ _: False{}

# Probe short syntactic spines before paying the full bounded body/type checks.
@unsafe
def p198e_bin(name: String, op: String, a: N111Value, b: N111Value) -> N111Stmt:
  N111Bin{name,N111U64{},op,a,b}

@unsafe
def w5c2_p123p_bin_stmt(is0: Bool, +name: String, +vname: String) -> N111Stmt:
  match is0:
    case True{}: N111Set{name, N111U32{}, N111Local{vname}}
    case False{}: N111Bin{name, N111U32{}, "xor", N111Local{vname}, N111Const{1, 0}}

@unsafe
def p123a_scale(+name: String, +value: N111Value, +shift: U32) -> N111Stmt:
  nt_choose(N111Stmt,U32.is_le(shift,3),
    u => N111Bin{name,N111U64{},"mul",value,N111Const{nt_choose(U32,U32.is_eq(shift,0),u => 1,u => nt_choose(U32,U32.is_eq(shift,1),u => 2,u => nt_choose(U32,U32.is_eq(shift,2),u => 4,u => 8))),0}},
    u => N111Bin{name,N111U64{},"shl",value,N111Const{shift,0}})


@unsafe
def p124r_view(ready: KDef, direct: KDef) -> KDef:
  KDef{"","P124Callables",0,0,{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},[ready,direct],False{},False{}}


@unsafe
def agy_p124r_hview(ready: KDef, direct: KDef, hready: KDef) -> KDef:
  KDef{"","P124Callables",0,0,{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},[ready,direct,hready],False{},False{}}

@unsafe
def agy_p114r_nstmts_calls_h(stmts: List<&2,N111Stmt>) -> Bool:
  match stmts:
    case Nil{}: False{}
    case Con{N111Call{n,t,sym,args},rest}:
      String.starts_with(sym,"p114r_") || agy_p114r_nstmts_calls_h(rest)
    case Con{N111If{c,yes,no},rest}:
      agy_p114r_nstmts_calls_h(yes) || agy_p114r_nstmts_calls_h(no) || agy_p114r_nstmts_calls_h(rest)
    case Con{_,rest}: agy_p114r_nstmts_calls_h(rest)

def p124r_valid(callable: P124Callable) -> Bool:
  match callable:
    case P124Callable{valid,arity,symbol}: valid


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
def p126s_float(bits: U32) -> F32:
  match bits:
    case U32{word}: F32{word}


@unsafe
def p126s_decision(+word: String, values: List<&2,U32>, +index: U32) -> List<&2,P113DStmt>:
  match values:
    case Nil{}: []
    case Con{bits,Nil{}}: [P113DResult{[N111Const{bits,0}]}]
    case Con{bits,rest}:
      +condition = "p126_select_" ++ U32.show(index)
      [P113DScalar{N111Bin{condition,N111U64{},"eq",N111Local{word},N111Const{index,0}}},
       P113DIf{N111Local{condition},[P113DResult{[N111Const{bits,0}]}],p126s_decision(word,rest,U32.inc(index))}]


@unsafe
def p126s_cells_cons(bits: U32, rest: Maybe<&2,List<&2,U32>>) -> Maybe<&2,List<&2,U32>>:
  match rest:
    case None{}: None{}
    case Some{values}: Some{Con{bits,values}}


@unsafe
def p126s_data(values: List<&2,U32>) -> List<&2,P111QDatum>:
  match values:
    case Nil{}: []
    case Con{bits,rest}: Con{P111QLong{bits,0},p126s_data(rest)}


@unsafe
def p126i_lookup(tables: List<&2,P126ITable>, +name: String) -> Maybe<&2,U32>:
  match tables:
    case Nil{}: None{}
    case Con{P126ITable{key,last},rest}:
      nt_choose(Maybe<&2,U32>,agy_str_eq(key,name),u => Some{last},u => p126i_lookup(rest,name))


@unsafe
def p126i_present(found: Maybe<&2,U32>) -> Bool:
  match found:
    case Some{last}: True{}
    case None{}: False{}


@unsafe
def p126sc_name(function: P113DFunction) -> String:
  match function:
    case P113DFunction{name,params,result,public,body}: name


@unsafe
def p126sc_params(function: P113DFunction) -> List<&2,NC_Binding>:
  match function:
    case P113DFunction{name,params,result,public,body}: params


@unsafe
def p126sc_body(function: P113DFunction) -> List<&2,P113DStmt>:
  match function:
    case P113DFunction{name,params,result,public,body}: body


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
def p126sc_zeros(count: U32) -> List<&2,N111Value>:
  match count:
    case 0: []
    case _: Con{N111Const{0,0},p126sc_zeros(U32.sub(count,1))}


@unsafe
def p126sc_lane_params(+count: U32, +index: U32) -> List<&2,NC_Binding>:
  nt_choose(List<&2,NC_Binding>,U32.is_eq(count,index),u => [],u =>
    Con{NC_Binding{index,"p126scc_arg_" ++ U32.show(index),N_W64{}},p126sc_lane_params(count,U32.inc(index))})


@unsafe
def p126sc_param_values(params: List<&2,NC_Binding>) -> List<&2,N111Value>:
  match params:
    case Nil{}: []
    case Con{NC_Binding{id,word,kind},rest}: Con{N111Local{word},p126sc_param_values(rest)}


@unsafe
def p126sc_call_terms(calls: List<&2,String>) -> List<&2,KTerm>:
  match calls:
    case Nil{}: []
    case Con{name,rest}: Con{kt("Ref",name,0,0,[]),p126sc_call_terms(rest)}


@unsafe
def p128bs_owned(owner: String) -> String:
  "$p128borrow.owned." ++ owner


@unsafe
def p128bs_leaf(body: List<&2,P113DStmt>) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{P113DCall{destinations,target,args},rest}: False{}
    case Con{P113DIf{condition,yes,no},rest}: p128bs_leaf(yes) && p128bs_leaf(no) && p128bs_leaf(rest)
    case Con{head,rest}: p128bs_leaf(rest)


@unsafe
def p128br_helpers(c: NO_Context) -> List<&2,P128BRHelper>:
  match c:
    case NO_Context{book,owner,schema,helpers}: helpers


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
def p130m_valid(+mode: U32) -> Bool:
  U32.is_eq(mode,1) || U32.is_eq(mode,2)


@unsafe
def p130m_status(valid: Bool, mode: U32) -> U32:
  match valid:
    case True{}: mode
    case False{}: 0


@unsafe
def p130m_initial_choice(word: Bool) -> U32:
  match word:
    case True{}: 2
    case False{}: 1


@unsafe
def p130m_word_gate(tail: String, lo: U32, hi: U32, valid: Bool) -> P88Number:
  match valid:
    case True{}: P88Number{P88Cursor{tail,2},U32.add(U32.sub(lo,65536),U32.mul(U32.sub(hi,65536),65536))}
    case False{}: P88Number{P88Cursor{"",0},0}


@unsafe
def p130m_number_read(nodes: Array<P88Node>, strings: Array<String>, made: U32, sn: U32, begin: U32, end: U32, text: String, mode: U32, n: U32, valid: Bool) -> P88Step:
  match valid:
    case True{}: P88Step{P88State{P88Cursor{text,mode},nodes,strings,made,sn,begin,end},P88Word{n}}
    case False{}: P88Step{P88State{P88Cursor{"",0},nodes,strings,made,sn,begin,end},P88Bad{}}


def p131a_add(a: U32, b: U32) -> U32:
  U32.min(2,U32.add(a,b))


def p131u_absent(entries: List<&2,P131UEntry>, +mode: U32) -> List<&2,P131UEntry>:
  match entries mode:
    case values 0: values
    case Nil{} other: []
    case Con{P131UEntry{id,low,high},rest} other:
      Con{P131UEntry{id,0,high},p131u_absent(rest,mode)}



def p131u_max_loop(entries: List<&2,P131UEntry>, +id: U32, order: Cmp, value: U32) -> U32:
  match entries order:
    case values EQ{}: value
    case values GT{}: 0
    case Nil{} LT{}: 0
    case Con{P131UEntry{key,low,high},rest} LT{}:
      p131u_max_loop(rest,id,U32.cmp(key,id),high)



@unsafe
def w5c_p131i_join(bit: U32, +stored: U32, +tree: KDef, +d: KDef, +hash: U32, +mask: U32) -> KDef:
  match bit:
    case 0: KIndexNode{stored, mask, KIndexLeaf{hash, [d]}, tree}
    case _: KIndexNode{stored, mask, tree, KIndexLeaf{hash, [d]}}

@unsafe
def p131p_parameter(+id: U32, params: List<&2,KTerm>) -> Bool:
  match params:
    case Nil{}: False{}
    case Con{p,rest}: U32.is_eq(ix(p),id) || p131p_parameter(id,rest)


@unsafe
def p131rg_opaque() -> String:
  "$p131.borrowed.opaque"


@unsafe
def p131rg_width(+width: U32) -> Bool:
  U32.is_eq(width,0) || (U32.is_ge(width,2) && U32.is_le(width,16))


@unsafe
def p134v_list(~A: Data, ~eq: A -> A -> Bool, a: List<&2,A>, b: List<&2,A>) -> Bool:
  match a b:
    case Nil{} Nil{}: True{}
    case Con{x,xs} Con{y,ys}: eq(x,y) && p134v_list(~A,~eq,xs,ys)
    case _ _: False{}


def p134v_type(a: N111Type, b: N111Type) -> Bool:
  match a b:
    case N111U32{} N111U32{}: True{}
    case N111U64{} N111U64{}: True{}
    case N111Ptr{} N111Ptr{}: True{}
    case _ _: False{}


def p134v_value(a: N111Value, b: N111Value) -> Bool:
  match a b:
    case N111Local{x} N111Local{y}: p88_string_eq(x,y)
    case N111Const{xl,xh} N111Const{yl,yh}: U32.is_eq(xl,yl) && U32.is_eq(xh,yh)
    case N111Symbol{x} N111Symbol{y}: p88_string_eq(x,y)
    case N111FuncId{x} N111FuncId{y}: p88_string_eq(x,y)
    case N111CtorId{x} N111CtorId{y}: p88_string_eq(x,y)
    case _ _: False{}


@unsafe
def p137qi_wide_args(args: List<&2,N111Arg>) -> Bool:
  match args:
    case Con{N111Arg{N111Ptr{},state},Con{N111Arg{N111U64{},term},Con{N111Arg{N111Ptr{},buffer},Con{N111Arg{N111U32{},N111Const{+count,0}},Nil{}}}}}:
      U32.is_ge(count,9) && U32.is_le(count,16)
    case _: False{}


def p143cs_events(plan: P143CSchedule) -> List<&2,P143CEvent>:
  match plan:
    case P143CSchedule{index,events}: events


@unsafe
def p144o_term(term: KTerm) -> P144OFacts:
  match term:
    case KTerm{tag,name,id,version,kids,names,begin,end}:
      nt_choose(P144OFacts,p88_string_eq(tag,"P144Ownership") && p88_string_eq(name,"") &&
        U32.is_eq(id,0) && U32.is_eq(version,1) && List.is_empty(&2,KTerm,kids) &&
        U32.is_eq(begin,0) && U32.is_eq(end,0),
        u => P144OFacts{names,True{}},u => P144OFacts{[],False{}})
    case _: P144OFacts{[],False{}}


def p164a_arg(index: U32) -> String:
  "p164_arg_" ++ U32.show(index)



@unsafe
def p167l_private(functions: List<&2,P113DFunction>) -> List<&2,P113DFunction>:
  match functions:
    case Nil{}: []
    case Con{P113DFunction{name,params,result,public,body},rest}:
      Con{P113DFunction{name,params,result,False{},body},p167l_private(rest)}



# Catalogue records bind exact identities to source declarations. dx is proposed
# adapter eligibility, never a verifier certificate. No symbol is decoded.
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
def w6_push(+st: W6CState, +s: String) -> W6CState:
  match st:
    case W6CState{locals,next,chunks,fuel}: W6CState{locals,next,Con{s,chunks},fuel}

@unsafe
def w6_st_locals(+st: W6CState) -> List<&2,W6Local>:
  match st:
    case W6CState{locals,next,chunks,fuel}: locals

@unsafe
def w6_st_fuel(+st: W6CState) -> U32:
  match st:
    case W6CState{locals,next,chunks,fuel}: fuel

@unsafe
def w6_dec_fuel(+st: W6CState) -> W6CState:
  match st:
    case W6CState{locals,next,chunks,fuel}: W6CState{locals,next,chunks,U32.sub(fuel,1)}

def p167l_complete(built: P167Built, demands: U32) -> P167Built:
  match built:
    case P167Built{segments,present,adapters,fresh,families,factories,wrappers,old_demands,error}:
      P167Built{segments,present,adapters,fresh,families,factories,wrappers,demands,error}



def p167l_finished(nodes: List<&2,P112SNode>, functions: List<&2,P113DFunction>, adapters: KDef,
    stats: List<&2,U32>, result: P111Result) -> P167Lowered:
  match result:
    case P111Result{program,error}: P167Lowered{P113DProgram{P112StaticProgram{program,nodes},functions},adapters,error,stats}



@unsafe
def p167v_private(functions: List<&2,P113DFunction>) -> Bool:
  match functions:
    case Nil{}: True{}
    case Con{P113DFunction{name,params,result,public,body},rest}:
      Bool.not(public) && p167v_private(rest)


# Additive attribution control: identical demand lowering/final admission and
# inherited segment/direct emission; only the checked live-register bit differs.
# p111q_segment_chunks still invokes the existing generic registry internally;
# retaining that behavior isolates this control from a no-registry treatment.
# Exact adapters are authenticated by p167v_final before this renderer is used.

@unsafe
def p169s_fail(error: String) -> P169Prepared:
  P169Prepared{[],P134End{},error}



@unsafe
def p169q_metadata(+arity: U32, +result: U32, +incoming: U32, +flags: U32) -> Bool:
  U32.is_eq(incoming,0) && U32.is_eq(flags,0) && U32.is_eq(result,1) && U32.is_le(arity,64)



@unsafe
def w4c_fn_name(f: P113DFunction) -> String:
  match f:
    case P113DFunction{name,_,_,_,_}: name

@unsafe
def w4i_is_borrow_worker(+name: String) -> Bool:
  String.starts_with(name,"$p118borrow.") || String.starts_with(name,"$p128borrow.")


@unsafe
def p169o_certified(+mode: U32, certificate: P113ACertificate) -> U32:
  nt_choose(U32,U32.is_eq(mode,1),u => 2,u => mode)


# Optional same-request cold metadata restoration after the existing full
# verifier and array/transport namespace gates. No emitted body or ID changes.
@unsafe
def p169c_scalar(certificate: P113ACertificate) -> Bool:
  match certificate:
    case P113ACertificate{scalar,unshared}: scalar



@unsafe
def p177s_reverse(terms: List<&2,KTerm>, done: List<&2,KTerm>) -> List<&2,KTerm>:
  match terms:
    case Nil{}: done
    case Con{head,rest}: p177s_reverse(rest,Con{head,done})

def p177s_visit_state(variable: Bool, hit: Bool) -> U32:
  match variable:
    case False{}: 2
    case True{}:
      match hit:
        case False{}: 4
        case True{}: 1

def p177s_rebuild_state(application: Bool) -> U32:
  match application:
    case False{}: 7
    case True{}: 6

def p177s_leaf_state(application: Bool) -> U32:
  match application:
    case False{}: 4
    case True{}: 6

def p177s_apply_state(lambda: Bool) -> U32:
  match lambda:
    case False{}: 9
    case True{}: 8

@unsafe
def p185cc_class(+count: U32) -> U32:
  nt_choose(U32,U32.is_eq(count,1),u => 0,u => nt_choose(U32,U32.is_eq(count,2),v => 1,v => 2))

# p111_program is the immutable descriptor passed by the emitted main to
# p111_rt_main. Its fixed offsets are checked independently of the state
# layout. Capability 8 authorizes unsealed cold publication; bit 1 requires
# the selected sequential host ABI (LANE_STEP=1).
@unsafe
def p185pt_word(word: N111Value) -> Bool:
  match word:
    case N111Local{name}: Bool.not(String.starts_with(name,"p185pt_"))
    case N111Const{lo,hi}: True{}
    case _: False{}

@unsafe
def p185pt_name(site: U32, role: String) -> String:
  "p185pt_" ++ U32.show(site) ++ "_" ++ role

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

def p185cb_number(item: P111QDatum) -> U32:
  match item:
    case P111QLong{lo,0}: lo
    case _: 4294967295

@unsafe
def p185cb_ref(item: P111QDatum, +name: String) -> Bool:
  match item:
    case P111QReloc{symbol,0}: agy_str_eq(symbol,name)
    case _: False{}

@unsafe
def p186rt_jump(dest: String, fid: String) -> List<&2,N111Stmt>:
  [N111Store{N111U32{},N111Local{"state"},28,N111Const{0,0}},
   N111Store{N111U32{},N111Local{"state"},32,N111FuncId{fid}},
   N111Set{dest,N111U64{},N111Const{0,0}}]

@unsafe
def p186ch_expand(+stmt: N111Stmt) -> P114TExpansion:
  match stmt:
    case N111Call{+dest,N111U64{},+symbol,
      Con{N111Arg{N111Ptr{},N111Local{+state}},
      Con{N111Arg{N111U32{},N111Const{5,0}},
      Con{N111Arg{N111U64{},+word},
      Con{N111Arg{N111Ptr{},N111Local{+buffer}},
      Con{N111Arg{N111U32{},N111Const{1,0}},Nil{}}}}}}}:
        nt_choose(P114TExpansion,agy_str_eq(symbol,"p111_rt_special_take") && agy_str_eq(state,"state") &&
          Bool.not(agy_str_eq(buffer,"state")),
          u => P114TExpansion{[N111Store{N111U64{},N111Local{buffer},0,word},
            N111Set{dest,N111U64{},N111Const{1,0}}],True{}},
          u => P114TExpansion{[stmt],False{}})
    case N111Call{+dest,N111U64{},+symbol,
      Con{N111Arg{N111Ptr{},N111Local{+state}},
      Con{N111Arg{N111U32{},N111Const{5,0}},
      Con{N111Arg{N111Ptr{},N111Local{+buffer}},
      Con{N111Arg{N111U32{},N111Const{1,0}},Nil{}}}}}}:
        nt_choose(P114TExpansion,agy_str_eq(symbol,"p111_rt_special_ctor") && agy_str_eq(state,"state") &&
          Bool.not(agy_str_eq(buffer,"state")),
          u => P114TExpansion{[N111Load{dest,N111U64{},N111Local{buffer},0}],True{}},
          u => P114TExpansion{[stmt],False{}})
    case N111Call{+dest,N111U64{},+symbol,
      Con{N111Arg{N111Ptr{},N111Local{+state}},
      Con{N111Arg{N111U32{},N111Const{+kind,0}},
      Con{N111Arg{N111Ptr{},N111Local{+buffer}},
      Con{N111Arg{N111U32{},N111Const{0,0}},Nil{}}}}}}:
        nt_choose(P114TExpansion,agy_str_eq(symbol,"p111_rt_special_ctor") && agy_str_eq(state,"state") &&
          Bool.not(agy_str_eq(buffer,"state")) && U32.is_ge(kind,1) && U32.is_le(kind,3),
          u => P114TExpansion{[N111Set{dest,N111U64{},N111Const{Bool.to_u32(U32.is_eq(kind,2)),0}}],True{}},
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

def x188_empty(code: X188Seq) -> Bool:
  match code:
    case X188Empty{}: True{}
    case _: False{}

def x188_cat(left: X188Seq, right: X188Seq) -> X188Seq:
  match left right:
    case X188Empty{} r: r
    case l X188Empty{}: l
    case l r: X188Join{l,r}

def x188_i0(op: String) -> X188Seq:
  X188One{PInst{X187Instruction{op,[]}}}

def x188_i1(op: String, a: X187Operand) -> X188Seq:
  X188One{PInst{X187Instruction{op,[a]}}}

def x188_i2(op: String, a: X187Operand, b: X187Operand) -> X188Seq:
  X188One{PInst{X187Instruction{op,[a,b]}}}

def x188_reg(index: U32, width: U32) -> X187Operand:
  X187Reg{index,width,False{}}

def x188_xmm(index: U32) -> X187Operand:
  X187Reg{index,128,True{}}

def x188_label(name: String) -> X188Seq:
  X188One{PLabel{name}}

def x188_error(message: String) -> X188Seq:
  X188One{PError{message}}

def x188_operand_same(a: X187Operand, b: X187Operand) -> Bool:
  match a b:
    case X187Reg{ai,aw,av} X187Reg{bi,bw,bv}:
      U32.is_eq(ai,bi) && U32.is_eq(aw,bw) && Bool.not(Bool.xor(av,bv))
    case _ _: False{}

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

@unsafe
def x188_bytes_text(bytes: List<&2,U32>) -> String:
  match bytes:
    case Nil{}: ""
    case Con{head,rest}: ".byte " ++ U32.show(head) ++ "\n" ++ x188_bytes_text(rest)

@unsafe
def x187_e_signed32(+lo: U32, +hi: U32) -> Bool:
  (U32.is_eq(hi,0) && U32.is_le(lo,2147483647)) || (U32.is_eq(hi,4294967295) && U32.is_ge(lo,2147483648))
law x181_add:
  for +text: X188Seq
  for +code: X181Code
  X181Code
law x181_error:
  for +text: String
  for +code: X181Code
  X181Code
law x181_label:
  for n: U32
  for frame: X181Frame
  String
# Placement for already verified native statements. Offsets are positive rbp
# displacements; the first forty bytes belong to the five saved registers.
# The caller reserves outgoing space separately and aligns the complete frame.

def x181_frame_alignment(+alignment: U32) -> U32:
  nt_choose(U32,U32.is_eq(alignment,4),u => 4,
    u => nt_choose(U32,U32.is_eq(alignment,8),v => 8,v => 16))

def x181_frame_align(bytes: U32, +alignment: U32) -> U32:
  U32.mul(U32.div(U32.add(bytes,U32.sub(alignment,1)),alignment),alignment)

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

def x186_u32_float_enabled() -> Bool: True{}

def x192_float_conversions_enabled() -> Bool: True{}

def x192_float_unary(+id: U32) -> Bool:
  U32.is_eq(id,23) || U32.is_eq(id,58)

# Keep the runtime's initial COMISS against zero, including its MXCSR invalid
# (any NaN) and denormal behavior. Positive finite raw F32 bits have the
# same unsigned order as their values. All negative encodings, NaNs, infinities
# and values >=2^32 are >=0x4f800000. Sanitize them BEFORE conversion, so even
# unmasked invalid exceptions cannot arise from a speculative conversion.
# Signed64 CVTT is required: signed32 would reject valid values >=2^31.
def x185_float_enabled() -> Bool: True{}

def x185_float_arithmetic(id: U32) -> String:
  match id:
    case 26: "addss"
    case 27: "subss"
    case 28: "mulss"
    case _: "divss"

# ucomiss(a,b): unordered sets ZF/PF/CF. Collect both conditions before
# combining bytes changes flags; equality/order exclude unordered, ne includes
# it. Above/above-equal already exclude unordered without a second predicate.
def x186_float_narrow(physical: X185Physical) -> Maybe<&2,X187Operand>:
  match physical:
    case X185Physical{wide,narrow,byte}: Some{narrow}
    case X185PhysicalNone{}: None{}

def x186_float_present(home: Maybe<&2,X187Operand>) -> Bool:
  match home:
    case Some{operand}: True{}
    case None{}: False{}

def x186_float_operand(home: Maybe<&2,X187Operand>, fallback: X187Operand) -> X187Operand:
  match home:
    case Some{operand}: operand
    case None{}: fallback

def x195s_enabled() -> Bool: True{}

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

def agy_ctor_inline_enabled() -> Bool: True{}
def agy_take_inline_enabled() -> Bool: True{}

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

def x186_call_arguments_enabled() -> Bool: True{}

@unsafe
def x186_call_capacity(plan: X186CallPlan, +bytes: U32, +calls: U32) -> X186CallPlan:
  match plan:
    case X186CallPlan{kind,+count}:
      nt_choose(X186CallPlan,U32.is_ge(bytes,40) && U32.is_le(calls,2147483000) &&
          U32.is_le(bytes,U32.sub(2147483583,calls)) && U32.is_ge(calls,U32.mul(count,16)),
        u => X186CallPlan{kind,count},u => X186CallPlan{0,count})

def agy_call_phys_reg(index: U32) -> U32:
  match index:
    case 0: 7
    case 1: 6
    case 2: 2
    case 3: 1
    case 4: 8
    case _: 9

def agy_call_treg(index: U32) -> U32:
  match index:
    case 0: 7
    case 1: 6
    case 2: 2
    case 3: 8
    case _: 9

def agy_call_pick_cons(m: AgyCallMove, p: AgyCallPick) -> AgyCallPick:
  match p:
    case AgyCallPick{chosen,rest}: AgyCallPick{chosen,Con{m,rest}}
    case _: AgyCallPickNone{}

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

def x185_machine_enabled() -> Bool: True{}

# Immediate forms keep operand width, comparison signedness and x86 shift masks.
# Full-width constants that cannot use signed32 retain the materialization path.
@unsafe
def w4_pow2_log(+d: U32, +shift: U32) -> U32:
  nt_choose(U32,U32.is_le(d,1),u => shift,u => w4_pow2_log(U32.shrn(d,1n),U32.inc(shift)))

law x181_scalar_rows:
  for +rows: List<&2,N111Stmt>
  List<&2,P113DStmt>

@unsafe
def x181_scalar_row(stmt: N111Stmt) -> P113DStmt:
  match stmt:
    case N111If{condition,yes,no}: P113DIf{condition,x181_scalar_rows(yes),x181_scalar_rows(no)}
    case _: P113DScalar{stmt}

@unsafe
def x181_scalar_rows(rows):
  match rows:
    case Nil{}: []
    case Con{head,rest}: Con{x181_scalar_row(head),x181_scalar_rows(rest)}

# Existing late runtime templates expressed as the same structured statements.
# A fresh site is reserved for every original scalar; generated fallbacks are
# copied once and never fed back through this expansion hook.
def x185_late_enabled() -> Bool: True{}

# Independent admission switch for the shared cold-constructor experiment.
def x185_ctor_enabled() -> Bool: False{}

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

def x186_transport_enabled() -> Bool: True{}

# W5-R4 Pass 1: Inline fast-path for P111_SPECIAL_SUCC (kind == 4, arity 1)
# with exact NAT_IMM = (1<<48)-1 = 0x0000FFFFFFFFFFFF overflow guard -> slow fallback.
@unsafe
def x181_register_reserved(+name: String) -> Bool:
  agy_str_eq(name,"state") || agy_str_eq(name,"scratch") || String.starts_with(name,"__x181")

def x181_read_increment(+count: U32) -> U32:
  match count:
    case 4294967295: 4294967295
    case _: U32.inc(count)

def x190_register_policy() -> U32: 2

@unsafe
def x190_register_loop(body: List<&2,P113DStmt>) -> Bool:
  match body:
    case Nil{}: False{}
    case Con{P113DAgain{values},rest}: True{}
    case Con{P113DIf{condition,yes,no},rest}:
      x190_register_loop(yes) || x190_register_loop(no) || x190_register_loop(rest)
    case Con{head,rest}: x190_register_loop(rest)

# Assume eight loop traversals when valuing a single syntactic read against
# a saved-register pair; no minimum trip count is asserted. The second policy
# favors homes excluded by transient allocation. Scores saturate at overflow.
def x190_register_score(+reads: U32, loopState: Bool, policy: U32) -> U32:
  +weight = nt_choose(U32,U32.is_eq(policy,2) && loopState,u => 32,u => 8)
  nt_choose(U32,U32.is_gt(reads,U32.div(4294967295,weight)),
    u => 4294967295,u => U32.mul(reads,weight))

def x185_copy_enabled() -> Bool: True{}

def x185_fact_enabled() -> Bool: True{}

def x185_fact_result(scan: P113KBody) -> List<&2,P113DStmt>:
  match scan:
    case P113KBody{body,facts,terminal}: body

# p113k is a private-body pass: scalar Return is outside its terminal model.
# Public segments can contain Return in either branch form and must retain the
# original statement sequence instead of using that private-only simplifier.
@unsafe
def x185_fact_scalar_returns(body: List<&2,N111Stmt>) -> Bool:
  match body:
    case Nil{}: False{}
    case Con{N111Return{value},rest}: True{}
    case Con{N111If{condition,yes,no},rest}:
      x185_fact_scalar_returns(yes) || x185_fact_scalar_returns(no) || x185_fact_scalar_returns(rest)
    case Con{head,rest}: x185_fact_scalar_returns(rest)

def x185_transient_enabled() -> Bool: True{}

def x185_t_next(scan: X185TScan) -> X185TScan:
  match scan:
    case X185TScan{ranges,names,position,region}:
      X185TScan{ranges,names,U32.inc(position),region}

def x185_t_cut(scan: X185TScan) -> X185TScan:
  match scan:
    case X185TScan{ranges,names,position,region}:
      X185TScan{ranges,names,U32.inc(position),U32.inc(region)}

# A condition belongs to the preceding region. Each arm and the continuation
# then receives a distinct region; any name crossing one of these is blocked.
@unsafe
def w4c_sel_val(v: N111Value) -> Bool:
  match v:
    case N111Local{_}: True{}
    case N111Const{_,_}: True{}
    case _: False{}

def w4c_sel_width(t: N111Type) -> Bool:
  match t:
    case N111U32{}: True{}
    case N111U64{}: True{}
    case _: False{}

@unsafe
def w4c_sel_arm_scalar(stmt: N111Stmt) -> W4CSelArm:
  match stmt:
    case N111Set{n,t,v}: W4CSelArm{n,t,v}
    case _: W4CSelArmNone{}

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

def x185_dead_enabled() -> Bool: True{}

def x185_d_result(scan: X185Dead) -> List<&2,P113DStmt>:
  match scan:
    case X185Dead{body,live}: body

def x185_register_binary_enabled() -> Bool: True{}
def x190_operands_enabled() -> Bool: True{}

def x194_cr_enabled() -> Bool: True{}
def x194_cr_op(+op: String) -> Bool:
  p88_string_eq(op,"add") || p88_string_eq(op,"mul") || p88_string_eq(op,"and") ||
    p88_string_eq(op,"or") || p88_string_eq(op,"xor")

def x185_scratch_enabled() -> Bool: True{}

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

@unsafe
def x198w_lt(dest: String,x: N111Value,other: Maybe<&2,N111Value>) -> Maybe<&2,N111Stmt>:
  match other:
    case Some{y}: Some{N111Bin{dest,N111U64{},"ult",x,y}}
    case _: None{}

# ABI11102 opcode 24 is a full-word copy, whereas 25 zeros the high word.
# Only substitute the stored source when its exact snapshot still dominates.
@unsafe
def agy_has_mem_scalars(body: List<&2,N111Stmt>) -> Bool:
  match body:
    case Nil{}: False{}
    case Con{N111Load{n,t,b,o},rest}: True{}
    case Con{N111Store{t,b,o,v},rest}: True{}
    case Con{N111Offset{n,b,by},rest}: True{}
    case Con{N111Alloca{n,by,al},rest}: True{}
    case Con{N111If{c,yes,no},rest}: agy_has_mem_scalars(yes) || agy_has_mem_scalars(no) || agy_has_mem_scalars(rest)
    case Con{head,rest}: agy_has_mem_scalars(rest)

def x186_saves_enabled() -> Bool: True{}

def x186_saves_offset(reg: U32) -> U32:
  match reg:
    case 0: 16
    case 1: 8
    case 2: 24
    case 3: 32
    case _: 40

def x186_private_enabled() -> Bool: True{}

# The decimal offset prefix ends at the first colon; arbitrary buffer text
# cannot collide with a different offset/name pair.
def x186_m_key(buffer: String, offset: U32) -> String:
  U32.show(offset) ++ ":" ++ buffer

def x186_parallel_enabled() -> Bool: True{}

def x186_p_pick_cons(move: X186Move, picked: X186Pick) -> X186Pick:
  match picked:
    case X186Pick{chosen,rest}: X186Pick{chosen,Con{move,rest}}
    case _: X186PickNone{}

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

def x186_float_values_enabled() -> Bool: True{}

def x186_f_admitted(operation: X186InlineOp) -> Bool:
  match operation:
    case X186InlineF32{destination,id,buffer}: True{}
    case X186InlineNone{}: False{}

@unsafe
def x186_f_values(stmt: N111Stmt, destination: String, id: U32,
    left: Maybe<&2,N111Value>, right: Maybe<&2,N111Value>) -> X186FloatNode:
  match left right:
    case Some{a} Some{b}: X186FloatValues{destination,id,a,b}
    case _ _: X186FloatPlain{P113DScalar{stmt}}

def x186_f_facts(step: X185ScratchStep) -> List<&2,X185ScratchCell>:
  match step:
    case X185ScratchStep{stmt,facts}: facts

law x186_f_placement_rows:
  for nodes: List<&2,X186FloatNode>
  List<&2,P113DStmt>

@unsafe
def x186_f_placement_row(node: X186FloatNode) -> P113DStmt:
  match node:
    case X186FloatPlain{stmt}: stmt
    case X186FloatBranch{condition,yes,no}: P113DIf{condition,x186_f_placement_rows(yes),x186_f_placement_rows(no)}
    case X186FloatValues{destination,id,left,right}: P113DScalar{N111Bin{destination,N111U64{},"add",left,right}}

@unsafe
def x186_f_placement_rows(nodes):
  match nodes:
    case Nil{}: []
    case Con{node,rest}: Con{x186_f_placement_row(node),x186_f_placement_rows(rest)}

# Once reads have been discharged by current facts, the F32 node reads only
# its two values. The proven footprint excludes its former buffer; unknown
# operations and all other loads/escapes retain their full original footprint.
def x186_xmm_enabled() -> Bool: True{}

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
def w4_u32_mem(+x: U32, xs: List<&2,U32>) -> Bool:
  match xs:
    case Nil{}: False{}
    case Con{h,rest}: U32.is_eq(x,h) || w4_u32_mem(x,rest)

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
def w2c_is_mem(op: Maybe<&2,X187Operand>) -> Bool:
  match op:
    case Some{X187Mem{b,d}}: True{}
    case _: False{}

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
def w2_dstmt_terminal(stmt: P113DStmt) -> Bool:
  match stmt:
    case P113DResult{vals}: True{}
    case P113DAgain{vals}: True{}
    case P113DScalar{N111Return{v}}: True{}
    case _: False{}

# Returns True if `name` is definitely NOT read before being overwritten or terminating,
# across `nodes` followed by outer continuation `tail` (with bounded fuel).
@unsafe
def w2_val_eq(a: N111Value, b: N111Value) -> Bool:
  match a b:
    case N111Local{x} N111Local{y}: agy_str_eq(x,y)
    case N111Const{la,ha} N111Const{lb,hb}: U32.is_eq(la,lb) && U32.is_eq(ha,hb)
    case _ _: False{}

@unsafe
def w2_nodes_term(nodes: List<&2,X186FloatNode>) -> Bool:
  match nodes:
    case Nil{}: False{}
    case Con{X186FloatPlain{P113DResult{v}},Nil{}}: True{}
    case Con{X186FloatPlain{P113DAgain{v}},Nil{}}: True{}
    case Con{X186FloatPlain{P113DScalar{N111Return{v}}},Nil{}}: True{}
    case Con{X186FloatBranch{c,yes,no},Nil{}}: w2_nodes_term(yes) && w2_nodes_term(no)
    case Con{head,rest}: w2_nodes_term(rest)

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
def w2_code_next(code: X181Code) -> U32:
  match code:
    case X181Code{chunks,next,terminal,error}: next

@unsafe
def w2_xl_safe_scalar(stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Call{d,t,sym,args}: agy_str_eq(sym,"p111_rt_fail")
    case N111If{c,yes,no}: False{}
    case _: True{}

law w2_xl_has_again:
  for nodes: List<&2,X186FloatNode>
  Bool

@unsafe
def w2_xl_has_again(nodes):
  match nodes:
    case Nil{}: False{}
    case Con{X186FloatPlain{P113DAgain{vs}},rest}: True{}
    case Con{X186FloatBranch{c,y,n},rest}: w2_xl_has_again(y) || w2_xl_has_again(n) || w2_xl_has_again(rest)
    case Con{h,rest}: w2_xl_has_again(rest)

@unsafe
def w2_xl_same_local(found: Maybe<&2,N111Value>, name: String) -> Bool:
  match found:
    case Some{N111Local{x}}: agy_str_eq(x,name)
    case _: False{}

@unsafe
def w2_xl_u32_in(+x: U32, xs: List<&2,U32>) -> Bool:
  match xs:
    case Nil{}: False{}
    case Con{h,rest}: U32.is_eq(h,x) || w2_xl_u32_in(x,rest)

@unsafe
def w2_xl_tail_skip(params: List<&2,String>) -> List<&2,String>:
  match params:
    case Nil{}: []
    case Con{+head,+rest}:
      nt_choose(List<&2,String>,agy_str_eq(head,"__x181_result_out"),u => rest,u => params)

@unsafe
def w4_plan_carried(plan: W2XLoopPlan) -> List<&2,W4Carried>:
  match plan:
    case W2XLoopPlan{homes,pre,carried,active}: carried

@unsafe
def w4_xl_alloc_plan(st: W2XLAlloc) -> W2XLoopPlan:
  match st:
    case W2XLAlloc{h1,p1,r1}: W2XLoopPlan{h1,p1,[],True{}}

@unsafe
def w4b_u32_len(xs: List<&2,U32>, +acc: U32) -> U32:
  match xs:
    case Nil{}: acc
    case Con{_,rest}: w4b_u32_len(rest,U32.inc(acc))

def x194fv_enabled() -> Bool: True{}

def x194fv_name(name: String) -> Bool:
  Bool.not(String.starts_with(name,"p194fv_"))

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

def x190_liveness_enabled() -> Bool: True{}

@unsafe
def w5b_u32_if_nz(cond: U32, val: U32) -> U32:
  match cond:
    case 0: 0
    case _: val

@unsafe
def x190_l_block(rows: List<&2,U32>, +blocked: U32, +bit: U32) -> List<&2,U32>:
  match rows:
    case Nil{}: []
    case Con{row,rest}: Con{U32.or(row,U32.and(blocked,bit)),x190_l_block(rest,blocked,U32.shl(bit))}

@unsafe
def x190_l_zeros(names: List<&2,String>) -> List<&2,U32>:
  match names:
    case Nil{}: []
    case Con{name,rest}: Con{0,x190_l_zeros(rest)}

@unsafe
def x190_l_position(+name: String, params: List<&2,String>, +index: U32) -> U32:
  match params:
    case Nil{}: 4294967295
    case Con{head,rest}: nt_choose(U32,agy_str_eq(name,head),u => index,u => x190_l_position(name,rest,U32.inc(index)))

def x190_l_abi(register: U32) -> U32:
  match register:
    case 0: 0
    case 1: 1
    case 2: 2
    case 3: 4
    case _: 5

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

def x190_joint_registers_enabled() -> Bool: True{}

def x190_j_edges(+bit: U32, +edges: U32, color: U32) -> U32:
  nt_choose(U32,U32.is_lt(color,4),u => U32.and(edges,U32.not(bit)),u => edges)

def x190_caller_first_enabled() -> Bool: True{}

@unsafe
def x190_j_callers(groups: List<&2,U32>) -> List<&2,U32>:
  match groups:
    case Con{a,Con{b,Con{c,Con{d,rest}}}}: rest
    case _: []

def x190_coalescing_enabled() -> Bool: True{}

@unsafe
def x190_j_home(groups: List<&2,U32>, +bit: U32, +color: U32) -> U32:
  match groups:
    case Nil{}: 9
    case Con{mask,rest}: nt_choose(U32,U32.is_eq(U32.and(mask,bit),0),
      u => x190_j_home(rest,bit,U32.inc(color)),u => color)

def w5c_intv_disjoint(+first: U32, +last: U32, list: List<&2,W5CIntv>) -> Bool:
  match list:
    case Nil{}: True{}
    case Con{W5CIntv{a,b},rest}:
      (U32.is_lt(last,a) || U32.is_lt(b,first)) && w5c_intv_disjoint(first,last,rest)

@unsafe
def w5c_occ_add(occ: List<&2,List<&2,W5CIntv>>, +idx: U32, +intv: W5CIntv) -> List<&2,List<&2,W5CIntv>>:
  match occ:
    case Nil{}: []
    case Con{+head,+rest}:
      nt_choose(List<&2,List<&2,W5CIntv>>,U32.is_eq(idx,0),
        u => Con{Con{intv,head},rest},
        u => Con{head,w5c_occ_add(rest,U32.sub(idx,1),intv)})

def x191_loop_profitability_enabled() -> Bool: True{}

@unsafe
def x191_again_identity(parameter: String, value: N111Value) -> Bool:
  match value:
    case N111Local{name}: agy_str_eq(parameter,name)
    case _: False{}

@unsafe
def w7b_stmts_has_call(xs: List<&2,P113DStmt>) -> Bool:
  match xs:
    case Nil{}: False{}
    case Con{P113DCall{_, _, _}, _}: True{}
    case Con{P113DIf{_, yes, no}, rest}:
      w7b_stmts_has_call(yes) || w7b_stmts_has_call(no) || w7b_stmts_has_call(rest)
    case Con{_, rest}:
      w7b_stmts_has_call(rest)

def x190_branch_enabled() -> Bool: True{}
def x190_branch_reuse_enabled() -> Bool: True{}
def x190_branch_complements_enabled() -> Bool: True{}

@unsafe
def x190_branch_counted(reads: X181ReadCounts, writes: KDef, pairs: KDef, protected: KDef) -> X190BranchFacts:
  match reads:
    case X181ReadCounts{counts,names}: X190BranchFacts{counts,writes,pairs,protected}

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

def x191_address_enabled() -> Bool: True{}
def x191_memory_alu_enabled() -> Bool: True{}

def x191_shift_scale(n: U32) -> U32:
  match n:
    case 0: 1
    case 1: 2
    case 2: 4
    case _: 8

@unsafe
def x191_alu(+op: String) -> Bool:
  agy_str_eq(op,"add") || agy_str_eq(op,"sub") || agy_str_eq(op,"and") ||
    agy_str_eq(op,"or") || agy_str_eq(op,"xor") || agy_str_eq(op,"mul")

@unsafe
def x191_reads(address: X191Address) -> List<&2,P113DStmt>:
  match address:
    case X191Address{base,index,scale,disp}: [P113DScalar{N111Store{N111U64{},base,0,index}}]

@unsafe
def x191_reg_home(home: X185Physical, fallback: U32) -> U32:
  match home:
    case X185Physical{X187Reg{index,width,vector},narrow,byte}: index
    case _: fallback

@unsafe
def x191_aliases(+reg: U32, memory: X187Operand) -> Bool:
  match memory:
    case X187Mem{base,disp}: U32.is_eq(reg,base)
    case X187Indexed{base,index,scale,disp}: U32.is_eq(reg,base) || U32.is_eq(reg,index)
    case _: True{}

def x192_shared_address_enabled() -> Bool: True{}

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
def x192_address_displacement(address: X191Address, offset: U32) -> X191Address:
  match address:
    case X191Address{base,index,scale,disp}: X191Address{base,index,scale,offset}

# Fusion remains adjacent and width-exact; the loaded name's global certificate
# is the Phase191 rule. This does not move a load across an intervening store.
def x191_frame_forward_enabled() -> Bool: True{}

def x191_ff_register(+register: U32) -> Bool:
  U32.is_lt(register,16) && Bool.not(U32.is_eq(register,4)) && Bool.not(U32.is_eq(register,5))

def x191_ff_private(+displacement: U32) -> Bool:
  U32.is_ge(displacement,2147483648) && U32.is_le(displacement,4294967288) &&
    U32.is_eq(U32.mod(displacement,8),0)

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
def w4_qm_pick_load0(found: Maybe<&2,X187Operand>, +arg: U32, rest: List<&2,X188Seq>, rest2: List<&2,X188Seq>) -> W4QMDividend:
  match found:
    case Some{op}: W4QMDividend{op,rest2}
    case None{}: W4QMDividend{X187Mem{5,arg},rest}

@unsafe
def w2c_movd_inverse(prev: X188Seq, +r: U32, +x: U32) -> Bool:
  match prev:
    case X188One{PInst{X187Instruction{op,[X187Reg{px,128,True{}},X187Reg{pr,32,False{}}]}}}:
      agy_str_eq(op,"movd") && U32.is_eq(pr,r) && U32.is_eq(px,x)
    case _: False{}

@unsafe
def x197d_next(todo: List<&2,X188Seq>) -> Maybe<&2,X197DHead>:
  match todo:
    case Nil{}: None{}
    case Con{X188Empty{},rest}: x197d_next(rest)
    case Con{X188Join{left,right},rest}: x197d_next(Con{left,Con{right,rest}})
    case Con{X188One{item},rest}: Some{X197DHead{item,rest}}

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
def w4_peep_is_setcc(+op: String) -> Bool:
  String.starts_with(op,"set")

@unsafe
def w4_peep_flags_pass_op(+op: String) -> Bool:
  agy_str_eq(op,"movq") || agy_str_eq(op,"movl") || agy_str_eq(op,"movabsq") ||
  agy_str_eq(op,"movzbl") || agy_str_eq(op,"leaq") || agy_str_eq(op,"pushq") || agy_str_eq(op,"popq")

@unsafe
def w4_peep_op_uses_reg(op: X187Operand, +r: U32) -> Bool:
  match op:
    case X187Reg{idx,_,False{}}: U32.is_eq(idx,r)
    case X187Mem{base,_}: U32.is_eq(base,r)
    case X187Indexed{base,index,_,_}: U32.is_eq(base,r) || U32.is_eq(index,r)
    case _: False{}

@unsafe
def w4_peep_dst_kills(dst: X187Operand, +r: U32) -> Bool:
  match dst:
    case X187Reg{dr,_,False{}}: U32.is_eq(dr,r)
    case _: False{}

@unsafe
def w4_peep_xor_self_kills(src: X187Operand, dst: X187Operand, +r: U32) -> Bool:
  match src dst:
    case X187Reg{sr,_,False{}} X187Reg{dr,_,False{}}: U32.is_eq(sr,dr) && U32.is_eq(sr,r)
    case _ _: False{}

@unsafe
def w4_leaf_is_callee(+r: U32, +disp: U32) -> Bool:
  (U32.is_eq(r,12) && U32.is_eq(disp,4294967280)) ||
  (U32.is_eq(r,3)  && U32.is_eq(disp,4294967288)) ||
  (U32.is_eq(r,13) && U32.is_eq(disp,4294967272)) ||
  (U32.is_eq(r,14) && U32.is_eq(disp,4294967264)) ||
  (U32.is_eq(r,15) && U32.is_eq(disp,4294967256))

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
def w4_leaf_arg_bad(arg: X187Operand) -> Bool:
  match arg:
    case X187Reg{i,_,False{}}: U32.is_eq(i,4) || U32.is_eq(i,5)
    case X187Mem{b,_}: U32.is_eq(b,4) || U32.is_eq(b,5)
    case X187Indexed{b,i,_,_}: U32.is_eq(b,4) || U32.is_eq(b,5) || U32.is_eq(i,4) || U32.is_eq(i,5)
    case _: False{}

@unsafe
def w4_leaf_wrap_prefix(prefix: List<&2,X187Parsed>) -> List<&2,X188Seq>:
  match prefix:
    case Nil{}: []
    case Con{h,rest}: Con{X188One{h},w4_leaf_wrap_prefix(rest)}

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
def w4_leaf_arg_uses_r12(arg: X187Operand) -> Bool:
  match arg:
    case X187Reg{12,_,False{}}: True{}
    case X187Mem{12,_}: True{}
    case X187Indexed{b,i,_,_}: U32.is_eq(b,12) || U32.is_eq(i,12)
    case _: False{}

@unsafe
def w4_leaf_drop_r12_list(saved: List<&2,U32>) -> List<&2,U32>:
  match saved:
    case Nil{}: []
    case Con{+r,+rest}: nt_choose(List<&2,U32>,U32.is_eq(r,12),u => w4_leaf_drop_r12_list(rest),u => Con{r,w4_leaf_drop_r12_list(rest)})

@unsafe
def w4_leaf_has_r12(saved: List<&2,U32>) -> Bool:
  match saved:
    case Nil{}: False{}
    case Con{r,rest}: U32.is_eq(r,12) || w4_leaf_has_r12(rest)

@unsafe
def w4b_op_reads_reg(+r: U32, op: X187Operand) -> Bool:
  match op:
    case X187Reg{i,_,False{}}: U32.is_eq(i,r)
    case X187Mem{b,_}: U32.is_eq(b,r)
    case X187Indexed{b,i,_,_}: U32.is_eq(b,r) || U32.is_eq(i,r)
    case _: False{}

@unsafe
def w5c_is_wo_c(u: U32, +op: String) -> Bool:
  match u:
    case 109: String.eq(op,"movq") || String.eq(op,"movl") || String.eq(op,"movabsq") || String.eq(op,"movzbl") || String.eq(op,"movd")
    case 108: String.eq(op,"leaq")
    case _: False{}

@unsafe
def w5c_is_alu_c(u: U32, +op: String) -> Bool:
  match u:
    case 97: String.eq(op,"addl") || String.eq(op,"addq") || String.eq(op,"andl") || String.eq(op,"andq")
    case 115: String.eq(op,"subl") || String.eq(op,"subq") || String.eq(op,"shll") || String.eq(op,"shlq") || String.eq(op,"shrl") || String.eq(op,"shrq") || String.eq(op,"sarl") || String.eq(op,"sarq") || String.starts_with(op,"set")
    case 105: String.eq(op,"imull") || String.eq(op,"imulq")
    case 111: String.eq(op,"orl") || String.eq(op,"orq")
    case 120: String.eq(op,"xorl") || String.eq(op,"xorq")
    case 99: String.eq(op,"cmpl") || String.eq(op,"cmpq") || String.starts_with(op,"cmov")
    case 116: String.eq(op,"testl") || String.eq(op,"testq")
    case _: False{}

@unsafe
def w5c_is_alu32_c(u: U32, +op: String) -> Bool:
  match u:
    case 97: String.eq(op,"addl") || String.eq(op,"andl")
    case 115: String.eq(op,"subl")
    case 105: String.eq(op,"imull")
    case 111: String.eq(op,"orl")
    case 120: String.eq(op,"xorl")
    case _: False{}

@unsafe
def w5b_dead_movzbl(+r: U32, rest: List<&2,X187Parsed>) -> Bool:
  match rest:
    case Con{PInst{X187Instruction{mop,Con{X187Reg{ms,8,False{}},Con{X187Reg{md,32,False{}},Nil{}}}}},_}:
      String.eq(mop,"movzbl") && U32.is_eq(ms,r) && U32.is_eq(md,r)
    case _: False{}

law w5c_lbl_bkt_find:
  for items: List<&2,W5BLblEntry>
  for +lbl: String
  Maybe<&2,List<&2,X187Parsed>>

@unsafe
def w5c_lbl_bkt_if(eq: Bool, t: List<&2,X187Parsed>, rest: List<&2,W5BLblEntry>, +lbl: String) -> Maybe<&2,List<&2,X187Parsed>>:
  match eq:
    case True{}: Some{t}
    case False{}: w5c_lbl_bkt_find(rest,lbl)

@unsafe
def w5c_lbl_bkt_find(items, lbl):
  match items:
    case Nil{}: None{}
    case Con{W5BLblEntry{k,t},rest}: w5c_lbl_bkt_if(String.eq(k,lbl),t,rest,lbl)

@unsafe
def w5c_lbl_join_br(bit: U32, +trie: W5BLblTrie, +entry: W5BLblEntry, +h: U32, +stored: U32, +mask: U32) -> W5BLblTrie:
  match bit:
    case 0: W5BLNode{stored,mask,W5BLLeaf{h,[entry]},trie}
    case _: W5BLNode{stored,mask,trie,W5BLLeaf{h,[entry]}}

@unsafe
def w5c_rd_ret_if_t(isRet: Bool, +r: U32) -> Bool:
  match isRet:
    case True{}: Bool.not(U32.is_eq(r,0))
    case False{}: False{}

law w4b_find_label:
  for +lbl: String
  for items: List<&2,X187Parsed>
  Maybe<&2,List<&2,X187Parsed>>

@unsafe
def w5c_find_lbl_if(eq: Bool, rest: List<&2,X187Parsed>, +lbl: String) -> Maybe<&2,List<&2,X187Parsed>>:
  match eq:
    case True{}: Some{rest}
    case False{}: w4b_find_label(lbl,rest)

@unsafe
def w4b_find_label(lbl, items):
  match items:
    case Nil{}: None{}
    case Con{PLabel{l},+rest}: w5c_find_lbl_if(String.eq(l,lbl),rest,lbl)
    case Con{_,rest}: w4b_find_label(lbl,rest)

@unsafe
def w4b_as_rr(item: X187Parsed) -> W4BRR:
  match item:
    case PInst{X187Instruction{op,args}}:
      match args:
        case Con{X187Reg{s,ws,False{}},Con{X187Reg{d,wd,False{}},Nil{}}}: W4BRR{op,s,ws,d,wd}
        case _: W4BRRNone{}
    case _: W4BRRNone{}

@unsafe
def w4b_as_imm_reg(item: X187Parsed) -> W4BImmReg:
  match item:
    case PInst{X187Instruction{op,args}}:
      match args:
        case Con{X187Imm{lo,hi},Con{X187Reg{r,w,False{}},Nil{}}}: W4BImmReg{op,lo,hi,r,w}
        case _: W4BImmRegNone{}
    case _: W4BImmRegNone{}

@unsafe
def w4b_as_branch(item: X187Parsed) -> W4BBranch:
  match item:
    case PInst{X187Instruction{op,args}}:
      match args:
        case Con{X187Target{tgt},Nil{}}: W4BBranch{op,tgt}
        case _: W4BBranchNone{}
    case _: W4BBranchNone{}

@unsafe
def w4b_is_ret(item: X187Parsed) -> Bool:
  match item:
    case PInst{X187Instruction{op,Nil{}}}: agy_str_eq(op,"ret")
    case _: False{}

@unsafe
def w5c_peep_seq(res: W5BPeepOut) -> List<&2,X188Seq>:
  match res:
    case W5BPeepOut{_,seq}: seq

@unsafe
def w4b_bit(+r: U32) -> U32:
  U32.shln(1,U32.to_nat(r))

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
def w4b_has_jmp_to(+lbl: String, items: List<&2,X187Parsed>) -> Bool:
  match items:
    case Nil{}: False{}
    case Con{PInst{X187Instruction{op,Con{X187Target{t},Nil{}}}},rest}:
      (String.eq(t,lbl) && String.eq(op,"jmp")) || w4b_has_jmp_to(lbl,rest)
    case Con{_,rest}: w4b_has_jmp_to(lbl,rest)

@unsafe
def w4b_has_any_branch_to(+lbl: String, items: List<&2,X187Parsed>) -> Bool:
  match items:
    case Nil{}: False{}
    case Con{PInst{X187Instruction{op,Con{X187Target{t},Nil{}}}},rest}:
      (String.eq(t,lbl) && String.starts_with(op,"j")) || w4b_has_any_branch_to(lbl,rest)
    case Con{_,rest}: w4b_has_any_branch_to(lbl,rest)

@unsafe
def w4b_has_non_jmp_to(+lbl: String, items: List<&2,X187Parsed>) -> Bool:
  match items:
    case Nil{}: False{}
    case Con{PInst{X187Instruction{op,Con{X187Target{t},Nil{}}}},rest}:
      (String.eq(t,lbl) && String.starts_with(op,"j") && Bool.not(String.eq(op,"jmp"))) || w4b_has_non_jmp_to(lbl,rest)
    case Con{_,rest}: w4b_has_non_jmp_to(lbl,rest)

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
def w4b_pair_magics(ms: List<&2,U32>, rs: List<&2,U32>) -> List<&2,W4BMagicMap>:
  match ms rs:
    case Con{m,mr} Con{r,rr}: Con{W4BMagicEntry{m,r},w4b_pair_magics(mr,rr)}
    case _ _: []

@unsafe
def w4b_lookup_magic(+m: U32, mp: List<&2,W4BMagicMap>) -> Maybe<&2,U32>:
  match mp:
    case Nil{}: None{}
    case Con{W4BMagicEntry{imm,reg},rest}:
      nt_choose(Maybe<&2,U32>,U32.is_eq(imm,m),u => Some{reg},u => w4b_lookup_magic(m,rest))

@unsafe
def w4b_hoist_inits(mp: List<&2,W4BMagicMap>) -> List<&2,X187Parsed>:
  match mp:
    case Nil{}: []
    case Con{W4BMagicEntry{m,r},rest}:
      Con{PInst{X187Instruction{"movl",[X187Imm{m,0},X187Reg{r,32,False{}}]}},w4b_hoist_inits(rest)}

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
def w5b_is_pinst(x: X187Parsed) -> Bool:
  match x:
    case PInst{_}: True{}
    case _: False{}

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
def w5_mov_args_ok(args: List<&2,X187Operand>, +r: U32) -> Bool:
  match args:
    case Con{_,Con{X187Reg{dr,_,False{}},Nil{}}}: Bool.not(U32.is_eq(dr,r))
    case Con{_,Con{X187Mem{_,_},Nil{}}}: True{}
    case _: False{}

@unsafe
def w5_check_testq_r(rr: W4BRR, +r: U32) -> Bool:
  match rr:
    case W4BRR{+top,+ts,64,+td,64}:
      agy_str_eq(top,"testq") && U32.is_eq(ts,td) && U32.is_eq(ts,r)
    case _: False{}

@unsafe
def w4c_slot_key(+disp: U32) -> U32:
  U32.sub(0,disp)

@unsafe
def w4c_is_neg_rbp(+base: U32, +disp: U32) -> Bool:
  U32.is_eq(base,5) && U32.is_ge(disp,2147483648)

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
def w4c_op_has_rbp(op: X187Operand) -> Bool:
  match op:
    case X187Mem{b,_}: U32.is_eq(b,5)
    case X187Indexed{b,i,_,_}: U32.is_eq(b,5) || U32.is_eq(i,5)
    case _: False{}

@unsafe
def w4c_op_is_xmm(+r: U32, op: X187Operand) -> Bool:
  match op:
    case X187Reg{i,_,True{}}: U32.is_eq(i,r)
    case _: False{}

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
def w4c_op_is_slot(+disp: U32, op: X187Operand) -> Bool:
  match op:
    case X187Mem{b,d}: U32.is_eq(b,5) && U32.is_eq(d,disp)
    case _: False{}

@unsafe
def w4c_inst_writes_xmm1(inst: X187Instruction) -> Bool:
  match inst:
    case X187Instruction{_,Con{_,Con{X187Reg{dr,_,True{}},Nil{}}}}: U32.is_eq(dr,1)
    case _: False{}

@unsafe
def w4c_or_peep(res: Maybe<&2,List<&2,X187Parsed>>, fallback: Unit -> List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match res:
    case Some{out}: out
    case None{}: fallback(Unit{})

@unsafe
def w4c_replace_op(+from: U32, +to: U32, op: X187Operand) -> X187Operand:
  match op:
    case X187Mem{+b,+d}: nt_choose(X187Operand,U32.is_eq(b,5) && U32.is_eq(d,from),u => X187Mem{5,to},u => X187Mem{b,d})
    case _: op

@unsafe
def w5_op_is_slot(+disp: U32, op: X187Operand) -> Bool:
  match op:
    case X187Mem{b,d}: U32.is_eq(b,5) && U32.is_eq(d,disp)
    case _: False{}

@unsafe
def w5_inst_writes_slot(+disp: U32, item: X187Parsed) -> Bool:
  match item:
    case PInst{X187Instruction{op,Con{_,Con{X187Mem{b,d},Nil{}}}}}:
      U32.is_eq(b,5) && U32.is_eq(d,disp) &&
      Bool.not(String.eq(op,"cmpq") || String.eq(op,"cmpl") || String.eq(op,"testq") || String.eq(op,"testl") || String.eq(op,"ucomiss"))
    case _: False{}

@unsafe
def w4c_gpr_in_op(+r: U32, op: X187Operand) -> Bool:
  match op:
    case X187Reg{i,_,False{}}: U32.is_eq(i,r)
    case X187Mem{b,_}: U32.is_eq(b,r)
    case X187Indexed{b,i,_,_}: U32.is_eq(b,r) || U32.is_eq(i,r)
    case _: False{}

@unsafe
def w5_inc_if(b: Bool, +x: U32) -> U32:
  match b:
    case True{}: U32.inc(x)
    case False{}: x

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
def w4c_or_peep_opt(res: Maybe<&2,List<&2,X187Parsed>>,
    fallback: Unit -> Maybe<&2,List<&2,X187Parsed>>) -> Maybe<&2,List<&2,X187Parsed>>:
  match res:
    case Some{out}: Some{out}
    case None{}: fallback(Unit{})

# X7: movaps A,B; <fop> src,B; movq B,disp(%rbp) (A,B dead) -> <fop> src,A; movq A,disp(%rbp)
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
def w5_not_scratch(+r: U32) -> Bool:
  Bool.not(U32.is_eq(r,0)) && Bool.not(U32.is_eq(r,10)) && Bool.not(U32.is_eq(r,11))

@unsafe
def w5b_g1_src_ok(+rA: U32, +rB: U32, op: X187Operand) -> Bool:
  match op:
    case X187Mem{b,_}: U32.is_eq(b,5)
    case X187Reg{r,64,False{}}: Bool.not(U32.is_eq(r,rA)) && Bool.not(U32.is_eq(r,rB)) && Bool.not(U32.is_eq(r,5))
    case _: False{}

@unsafe
def w5_g11_inv_jcc(+op: String) -> String:
  nt_choose(String,agy_str_eq(op,"jne") || agy_str_eq(op,"jnz"),u => "cmoveq",
    u => nt_choose(String,agy_str_eq(op,"je") || agy_str_eq(op,"jz"),v => "cmovneq",v => ""))

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
def w5_bit_if(b: Bool, +bit: U32, +acc: U32) -> U32:
  match b:
    case True{}: U32.or(acc,bit)
    case False{}: acc

@unsafe
def w5_flat_rev_seq(todo: List<&2,X188Seq>, acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match todo:
    case Nil{}: acc
    case Con{X188Empty{},rest}: w5_flat_rev_seq(rest,acc)
    case Con{X188Join{a,b},rest}: w5_flat_rev_seq(Con{b,Con{a,rest}},acc)
    case Con{X188One{item},rest}: w5_flat_rev_seq(rest,Con{item,acc})

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
def w5b_is_gpr64_or_imm(op: X187Operand) -> Bool:
  match op:
    case X187Reg{_,64,False{}}: True{}
    case X187Imm{_,_}: True{}
    case _: False{}

@unsafe
def w5b_is_gpr64_reg(op: X187Operand) -> Bool:
  match op:
    case X187Reg{_,64,False{}}: True{}
    case _: False{}

@unsafe
def w5b_is_plabel(h: X187Parsed) -> Bool:
  match h:
    case PLabel{_}: True{}
    case _: False{}

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
def w5c_is_imm(op: X187Operand) -> Bool:
  match op:
    case X187Imm{_,_}: True{}
    case _: False{}

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
def w7_gpr_changed(r: W5BGprOut) -> Bool:
  match r:
    case W5BGprUnchanged{}: False{}
    case W5BGprChanged{_}: True{}

@unsafe
def w7_is_loop(split: W4BLoopSplit) -> Bool:
  match split:
    case W4BLoopNone{}: False{}
    case W4BLoopSplit{_,_,_}: True{}

@unsafe
def w7_len_gt(items: List<&2,X187Parsed>, +limit: U32) -> Bool:
  match items:
    case Nil{}: False{}
    case Con{_,rest}:
      nt_choose(Bool,U32.is_eq(limit,0),u => True{},u => w7_len_gt(rest,U32.sub(limit,1)))

def x199s_touches(arg: X187Operand, +reg: U32) -> Bool:
  match arg:
    case X187Reg{index,width,False{}}: U32.is_eq(index,reg)
    case X187Mem{base,disp}: U32.is_eq(base,reg)
    case X187Indexed{base,index,scale,disp}: U32.is_eq(base,reg) || U32.is_eq(index,reg)
    case _: False{}

@unsafe
def x199s_count_arg(arg: X187Operand, +disp: U32, +wide: Bool) -> U32:
  match arg:
    case X187Mem{5,+offset}: Bool.to_u32(U32.is_lt(U32.sub(offset,disp),8) ||
      U32.is_lt(U32.sub(disp,offset),nt_choose(U32,wide,u => 32,u => 8)))
    case X187Reg{5,width,False{}}: 3
    case X187Indexed{5,index,scale,offset}: 3
    case X187Indexed{base,5,scale,offset}: 3
    case _: 0

def x200s_regnum(arg: X187Operand) -> U32:
  match arg:
    case X187Reg{i,64,False{}}: i
    case _: 16

@unsafe
def x199s_lookup(found: List<&2,X191FrameStore>, +offset: U32) -> U32:
  match found:
    case Nil{}: 16
    case Con{X191FrameStore{r,d},rest}: nt_choose(U32,U32.is_eq(d,offset),u => r,u => x199s_lookup(rest,offset))
    case Con{X191FrameStoreNone{},rest}: x199s_lookup(rest,offset)

def x191_conditional_select_enabled() -> Bool: True{}

def x191_select_value(value: N111Value) -> Bool:
  match value:
    case N111Local{name}: True{}
    case N111Const{lo,hi}: True{}
    case _: False{}

@unsafe
def x191_select_names(name: String, rest: Maybe<&2,List<&2,String>>) -> Maybe<&2,List<&2,String>>:
  match rest:
    case Some{names}: Some{Con{name,names}}
    case None{}: None{}

# Every subsequent copy must read its immediately preceding destination.
# Mixed widths, unequal writes, calls, loads, stores and control flow refuse.
def x194_ps_enabled() -> Bool: True{}

@unsafe
def x194_ps_member(names: List<&2,String>, +name: String) -> Bool:
  match names:
    case Nil{}: False{}
    case Con{head,rest}: agy_str_eq(head,name) || x194_ps_member(rest,name)

def x197ms_enabled() -> Bool: True{}

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
def x181_add(text,code):
  match code:
    case X181Code{chunks,next,terminal,error}: X181Code{Con{text,chunks},next,terminal,error}

def x181_error(text,code):
  match code:
    case X181Code{chunks,next,terminal,error}: X181Code{chunks,next,terminal,text}

def x181_label(n,frame):
  match frame:
    case X181Frame{slots,bytes,calls,params,symbol}: ".L" ++ symbol ++ "_b" ++ U32.show(n)

def x181_loop_label(frame: X181Frame) -> String:
  match frame:
    case X181Frame{slots,bytes,calls,params,symbol}: ".L" ++ symbol ++ "_loop"

@unsafe
def x181_args(values: List<&2,N111Value>) -> List<&2,N111Arg>:
  match values:
    case Nil{}: []
    case Con{head,rest}: Con{N111Arg{N111U64{},head},x181_args(rest)}

@unsafe
def x181_tail_skip(params: List<&2,String>) -> List<&2,String>:
  match params:
    case Nil{}: []
    case Con{+head,+rest}:
      nt_choose(List<&2,String>,agy_str_eq(head,"__x181_result_out"),u => rest,u => params)

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

law w2_asr_strip_self:
  for body: List<&2,P113DStmt>
  List<&2,P113DStmt>

@unsafe
def w2_asr_strip_self(body):
  match body:
    case Nil{}: []
    case Con{P113DScalar{N111Set{+a,N111U64{},N111Local{+b}}},+rest}:
      nt_choose(List<&2,P113DStmt>,agy_str_eq(a,b),u => w2_asr_strip_self(rest),
        u => Con{P113DScalar{N111Set{a,N111U64{},N111Local{b}}},w2_asr_strip_self(rest)})
    case Con{P113DIf{c,yes,no},rest}:
      Con{P113DIf{c,w2_asr_strip_self(yes),w2_asr_strip_self(no)},w2_asr_strip_self(rest)}
    case Con{P113DScalar{N111Bin{+d,+t,+op,N111Const{2,0},+x}},+rest}:
      nt_choose(List<&2,P113DStmt>,agy_str_eq(op,"mul"),
        u => Con{P113DScalar{N111Bin{d,t,"add",x,x}},w2_asr_strip_self(rest)},
        u => Con{P113DScalar{N111Bin{d,t,op,N111Const{2,0},x}},w2_asr_strip_self(rest)})
    case Con{P113DScalar{N111Bin{+d,+t,+op,+x,N111Const{2,0}}},+rest}:
      nt_choose(List<&2,P113DStmt>,agy_str_eq(op,"mul"),
        u => Con{P113DScalar{N111Bin{d,t,"add",x,x}},w2_asr_strip_self(rest)},
        u => Con{P113DScalar{N111Bin{d,t,op,x,N111Const{2,0}}},w2_asr_strip_self(rest)})
    case Con{head,rest}: Con{head,w2_asr_strip_self(rest)}

@unsafe
def w5_insert_before_again(stmts: List<&2,P113DStmt>, +subStmt: P113DStmt) -> List<&2,P113DStmt>:
  match stmts:
    case Nil{}: [subStmt]
    case Con{P113DAgain{vs},Nil{}}: Con{subStmt,[P113DAgain{vs}]}
    case Con{h,rest}: Con{h,w5_insert_before_again(rest,subStmt)}

def x185_loop_registers_enabled() -> Bool: True{}

# A positive countdown may enter an absorbing state before it exhausts its fuel.
# Certify one predecessor of a shared Again, then set only its next fuel to zero.
# All original copies, the other predecessor, and the zero-fuel result stay live.
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

def x190_frame_params(frame: X181Frame) -> List<&2,String>:
  match frame:
    case X181Frame{slots,bytes,calls,params,symbol}: params
# Structured x86 consumer of the existing closed P114H plan.
# No new recursive-region recognizer and no native self-recursion. Runtime
# continuation frames remain authoritative. All transfers use one local loop.
# Caller must preserve mode/direct-public precedence before querying this path.
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

def agy_z_v(s: String) -> AgyZipPat: AgyZVar{s}

@unsafe
def agy_zip_or(s1: X198PWState, s2: X198PWState) -> X198PWState:
  match s1:
    case X198PWState{r,v}: X198PWState{r,v}
    case _: s2

def agy_zip_add(p: AgyZipPlan, acc: List<&2,AgyZipPlan>) -> List<&2,AgyZipPlan>:
  match p:
    case AgyZipNone{}: acc
    case AgyZipPlan{o,l,n}: Con{AgyZipPlan{o,l,n},acc}

def agy_zip_key(owner: String) -> String: "$agy.zipper/" ++ owner

def agy_ro_key(owner: String) -> String:
  "$agy.rorec/" ++ owner

def agy_ro_rev_u32(xs: List<&2,U32>, acc: List<&2,U32>) -> List<&2,U32>:
  match xs:
    case Nil{}: acc
    case Con{h,t}: agy_ro_rev_u32(t,Con{h,acc})

@unsafe
def agy_ro_parse_bin_r(+op: String, ea: KTerm, rb: Maybe<&2,KTerm>) -> Maybe<&2,KTerm>:
  match rb:
    case None{}: None{}
    case Some{eb}: Some{kt("RoBin",op,0,0,[ea,eb])}

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

def x199s_enabled() -> Bool: True{}

def agy_dp_pair(+a: U32, +b: U32, +x: U32, +y: U32) -> Bool:
  (U32.is_eq(a,x) && U32.is_eq(b,y)) || (U32.is_eq(a,y) && U32.is_eq(b,x))

def agy_dp_is_j(+t: U32) -> Bool:
  U32.is_eq(t,2) || U32.is_eq(t,11)

def agy_dp_is_ai(+t: U32) -> Bool:
  U32.is_eq(t,3) || U32.is_eq(t,12)

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
def w5_lcu_local_opt(mv: Maybe<&2,N111Value>) -> String:
  match mv:
    case Some{N111Local{n}}: n
    case _: ""

# Match `N111Call{dest, N111U64{}, "p111_rt_ctor", [state, N111CtorId{C}, N111Local{buf}, N111Const{A, 0}]}`
@unsafe
def w5_lcu_finish_ctor_vals(+c: String, +a: U32, +buf: String, +aName: String, mv: Maybe<&2,List<&2,N111Value>>) -> W5LcuCtor:
  match mv:
    case Some{vs}: W5LcuYes{c,a,buf,vs,aName}
    case None{}: W5LcuNo{}

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
def w5_lcu_field_name(+depth: U32, +i: U32) -> String:
  "w5_lcu_" ++ U32.show(depth) ++ "_" ++ U32.show(i)

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
def agy_f32_finish_again(ry: Maybe<&2,KTerm>, rh: Maybe<&2,KTerm>, obs: Maybe<&2,KTerm>) -> AgyF32Plan:
  match ry rh:
    case Some{ye} Some{he}: AgyF32Yes{ye,obs,he}
    case _ _: AgyF32No{}

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
    agy_str_eq(name,"p111_FID_109_97_105_110_") ||
    agy_str_eq(name,"p113d_FID_109_97_105_110_") ||
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
def w10_if_word(+n: U32) -> String:
  SCon{Chr{U32.add(65536, U32.and(n, 65535))}, SCon{Chr{U32.add(65536, U32.shrn(n, 16n))}, SNil{}}}

@unsafe
def w10_if_str_len(s: String, acc: U32) -> U32:
  match s:
    case SNil{}: acc
    case SCon{_, rest}: w10_if_str_len(rest, U32.inc(acc))

@unsafe
def w10_if_enc_empty() -> W10IfEnc:
  W10IfEnc{missing(), Nil{}, 0, missing(), Nil{}, 0}

@unsafe
def w10_if_res_enc(r: W10IfRes) -> W10IfEnc:
  match r:
    case W10IfRes{enc, _}: enc

@unsafe
def w10_if_res_id(r: W10IfRes) -> U32:
  match r:
    case W10IfRes{_, id}: id

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

@unsafe
def w8_tr_ms(t0: Nat, t1: Nat) -> String:
  Nat.show(Nat.sub(t1,t0)) ++ "ms"

