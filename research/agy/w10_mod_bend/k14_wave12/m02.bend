# Module m02 (K=14 acyclic topological split of wave12_unified/compiler.bend)
# defs=847 laws=75 sccs=679 deps=[m00a,m00b,m01] cross_imports=713 fid_base=11800..16799

law core_subst_stable_app_kids:
  for +kids: List<&2, KTerm>
  Bool

# Module: src/core/term.bend:454
law norm_exact_lists:
  for +as: List<&2, KTerm>
  for +bs: List<&2, KTerm>
  Bool

# Module: src/core/normalize.bend:415
law g_shared_term:
  for +rest: List<&2, KTerm>
  for +done: List<&2, KTerm>
  for +r: GResult
  GTerms

# Module: src/core/graph.bend:40
law kr_refs:
  for +t: KTerm
  for +todo: List<&2, String>
  List<&2, String>

# Module: src/core/reach.bend:59
law kr_refs_list:
  for terms: List<&2, KTerm>
  for +todo: List<&2, String>
  List<&2, String>

# Module: src/core/reach.bend:64
law kp_float_text:
  for +s: String
  String

# Module: src/core/pretty.bend:23
law kp_let_names:
  for ts: List<&2, KTerm>
  String

# Module: src/core/pretty.bend:126
law prefix_state_exact_terms:
  for +left: List<&2,KTerm>
  for +right: List<&2,KTerm>
  Bool

# Module: src/check/prefix-state.bend:75
law f_kind_token:
  for +ts: FInput
  U32

# Module: src/front/parser.bend:31
law fpe_error:
  for +ts: FInput
  for +legacy: String
  for +expected: String
  FParsed

# Module: src/front/parser.bend:524
law fpe_legacy:
  for +ts: FInput
  for +legacy: String
  for +expected: String
  FParsed

# Module: src/front/declarations.bend:9
law ff_parallel:
  for +t: KTerm
  for +vars: List<&2, KTerm>
  for +r: FFlatten
  FFlatten

# Module: src/front/flatten.bend:28
law f_subs:
  for +ts: List<&2, KTerm>
  for +id: U32
  for +v: KTerm
  List<&2, KTerm>

# Module: src/front/elaborate.bend:18
law f_first_ctor:
  for +rows: List<&2, KTerm>
  KTerm

# Module: src/front/elaborate.bend:22
law f_miss_rows:
  for +rows: List<&2, KTerm>
  for +name: String
  List<&2, KTerm>

# Module: src/front/elaborate.bend:51
law f_decode_unicode:
  for +s: String
  for +code: U32
  for +count: U32
  FDecoded

# Module: src/front/unicode.bend:23
law f_char_decoded:
  for +d: FDecoded
  KTerm

# Module: src/front/literals_arrays.bend:3
law f_float_read:
  for +m: Maybe<&2, F32>
  KTerm

# Module: src/front/literals_arrays.bend:16
law f_power_bits:
  for +n: U32
  for +d: U32
  KTerm

# Module: src/front/literals_arrays.bend:41
law f_rename_var:
  for +t: KTerm
  for +env: List<&2, KTerm>
  KTerm

# Module: src/front/freshen.bend:19
law f_path_terms:
  for +ts: List<&2, KTerm>
  for +dir: String
  List<&2, KTerm>

# Module: src/front/families.bend:3
law f_adt_fill:
  for +t: KTerm
  for +args: List<&2, KTerm>
  for +arity: U32
  for +g: U32
  KTerm

# Module: src/front/families.bend:16
law f_mark_rows:
  for +rows: List<&2, KTerm>
  for +q: U32
  U32

# Module: src/front/families.bend:26
law f_reserved:
  for +s: String
  Bool

# Module: src/front/validate.bend:7
law f_name_chars:
  for +s: String
  Bool

# Module: src/front/validate.bend:152
law f_path_push:
  for +part: String
  for +parts: List<&2,String>
  List<&2,String>

# Module: src/load/graph.bend:19
law f_alias:
  for +name: String
  for +imports: List<&2, KTerm>
  String

# Module: src/load/modules.bend:17
law dg_quant_error:
  for +world: KWorld
  for +message: String
  for +name: String
  for +allowed: U32
  for +used: U32
  KChecking

# Module: src/diagnostic/produce.bend:24
law j_u32_node:
  for +t: KTerm
  Maybe<&2, U32>

# Module: src/back/common/literals.bend:30
law j_escape_char:
  for +c: Char
  String

# Module: src/back/js/shared-text.bend:24
law nt_replace_go:
  for +s: String
  for +key: String
  for +value: String
  for +acc: String
  String

# Module: src/back/native/identity.bend:6
law nc_ctor_decode:
  for +rest: String
  for +acc: U32
  for +digits: U32
  for +out: String
  for +original: String
  String

# Module: src/back/native/identity.bend:27
law nc_ctor_decode_step:
  for +h: Char
  for +rest: String
  for +acc: U32
  for +digits: U32
  for +out: String
  for +original: String
  String

# Module: src/back/native/erase.bend:1
law nw_same:
  for +a: KTerm
  for +b: KTerm
  for +pairs: List<&2, KTerm>
  Bool

# Module: src/back/native/word-pattern.bend:95
law nc_atomic:
  for +k: String
  U32

# Module: src/back/native/book.bend:1
law nc_refs:
  for +t: KTerm
  List<&2, String>

# Module: src/back/native/book.bend:233
law noa_virtual:
  for +t: KTerm
  for +env: List<&2, KTerm>
  KTerm

# Module: src/driver/report.bend:21
law dr_verdict:
  for +names: List<&2,String>
  String

# Module: src/driver/report.bend:25
@unsafe
def dn(
  +d: KDef,
) -> String:
  match d:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      name
    case KIndexLeaf{hash, bucket}: ""
    case KIndexNode{hash, mask, left, right}: ""

# Module: src/core/term.bend:194
@unsafe
def dk(
  +d: KDef,
) -> String:
  match d:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      kind
    case KIndexLeaf{hash, bucket}: "IndexLeaf"
    case KIndexNode{hash, mask, left, right}: "IndexNode"

# Module: src/core/term.bend:204
@unsafe
def da(
  +d: KDef,
) -> U32:
  match d:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      arity
    case KIndexLeaf{hash, bucket}: hash
    case KIndexNode{hash, mask, left, right}: hash

# Module: src/core/term.bend:214
@unsafe
def dx(
  +d: KDef,
) -> U32:
  match d:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      templates
    case KIndexLeaf{hash, bucket}: 0
    case KIndexNode{hash, mask, left, right}: mask

# Module: src/core/term.bend:224
@unsafe
def dt(
  +d: KDef,
) -> KTerm:
  match d:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      typ
    case KIndexLeaf{hash, bucket}: {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}
    case KIndexNode{hash, mask, left, right}: {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}

# Module: src/core/term.bend:234
@unsafe
def dv(
  +d: KDef,
) -> KTerm:
  match d:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      value
    case KIndexLeaf{hash, bucket}: {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}
    case KIndexNode{hash, mask, left, right}: {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}

# Module: src/core/term.bend:244
@unsafe
def dc(
  +d: KDef,
) -> List<&2, KDef>:
  match d:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      ctors
    case KIndexLeaf{hash, bucket}: bucket
    case KIndexNode{hash, mask, left, right}: Con{left, Con{right, Nil{}}}

# Module: src/core/term.bend:254
@unsafe
def db(
  +d: KDef,
) -> Bool:
  match d:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      native
    case KIndexLeaf{hash, bucket}: True{}
    case KIndexNode{hash, mask, left, right}: True{}

# Module: src/core/term.bend:264
@unsafe
def du(
  +d: KDef,
) -> Bool:
  match d:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      unsafe
    case KIndexLeaf{hash, bucket}: False{}
    case KIndexNode{hash, mask, left, right}: False{}

# Module: src/core/term.bend:274
@unsafe
def core_subst_stable_app_kids(kids):
  match kids:
    case Nil{}: False{}
    case Con{f, tail}: core_subst_stable_app_tail(f, tail)

# Module: src/core/term.bend:478
@unsafe
def w7_br_7(w7_c: Bool, +t: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      w7_br_5(U32.is_eq(kl_number(t), 0), t)
    case False{}:
      w7_br_6(p88_string_eq(nm(t), "String"), t)

@unsafe
def index_child(
  +tree: KDef,
  +right: Bool,
) -> KDef:
  match tree:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      index_child_list(ctors, right)
    case KIndexLeaf{hash, bucket}: index_child_list(bucket, right)
    case KIndexNode{hash, mask, left, next}:
      match right:
        case False{}: left
        case True{}: next

# Module: src/core/index.bend:51
@unsafe
def w7_br_13(w7_c: Bool, +t: KTerm, +args: List<&2, KTerm>) -> KTerm:
  match w7_c:
    case True{}:
      norm_apply(kt_span("ADT", nm(t), 0, 0, Nil{}, kb(t), ke(t)), args)
    case False{}:
      norm_apply(t, args)

@unsafe
def w12_u32_lit_val(+x: KTerm) -> Maybe<&2, U32>:
  kc(Maybe<&2, U32>, core_literal(x) && p88_string_eq(nm(x), "U32"),
    u => Some{kl_number(x)},
    u => kc(Maybe<&2, U32>, p98_tag_eq(x, "Ctr") && p88_string_eq(nm(x), "U32") && U32.is_eq(terms_len(ks(x)), 1),
      u => w12_word_u32(kid(x, 0), 1, 32, 0),
      u => None{}))

@unsafe
def w7_br_24(w7_c: Bool, +t: KTerm, +x: KTerm, +args: List<&2, KTerm>, +fallback: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      norm_apply(app(t, x), args)
    case False{}:
      fallback

@unsafe
def w7_br_29(w7_c: Bool, +a: KTerm, +b: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      w7_br_28(U32.is_eq(qt(b), 2), a, b)
    case False{}:
      kt("Min", "", 0, 0, Con{a, Con{b, Nil{}}})

@unsafe
def w7_br_32(w7_c: Bool, +as: List<&2, String>, +bs: List<&2, String>) -> Bool:
  match w7_c:
    case True{}:
      norm_subset(as, bs)
    case False{}:
      Bool.and(U32.is_eq(norm_names_len(as), norm_names_len(bs)), norm_subset(as, bs))

@unsafe
def norm_exact_lists(as, bs):
  match as bs:
    case Nil{} Nil{}:
      True{}
    case Con{a, ar} Con{b, br}:
      kc(Bool, norm_exact_head(a, b), u => norm_exact_lists(norm_join(ks(a), ar), norm_join(ks(b), br)), u => False{})
    case other_a other_b:
      False{}

# Module: src/core/normalize.bend:440
@unsafe
def g_class_raise(+classes: GClasses, +id: U32, +rank: U32, +raise: Bool) -> GClasses:
  w7_br_66(raise, classes, id, rank)

# Only distinct roots are linked. Rank strictly increases along every link,
# ruling out class cycles without inspecting or rewriting any term value.
@unsafe
def g_class_same(+st: GState, +left: U32, +right: U32) -> Bool:
  +classes = g_classes(st)
  U32.is_eq(g_class_root(classes,left),g_class_root(classes,right))

# Module: src/core/graph.bend:225
@unsafe
def g_share_terms(
  +st: GState,
  +ts: List<&2, KTerm>,
  +done: List<&2, KTerm>,
) -> GTerms:
  match ts:
    case Nil{}:
      GTerms{st, List.reverse(&2, KTerm, done)}
    case Con{h, rest}:
      g_shared_term(rest, done, g_share(st, h))

# Module: src/core/graph.bend:303
@unsafe
def g_shared_term(rest, done, r):
  g_share_terms(g_state(r), rest, Con{g_term(r), done})

# Module: src/core/graph.bend:307
@unsafe
def kr_refs(t, todo):
  kr_refs_list(ks(t), kc(List<&2, String>, p98_tag_eq(t, "Ref") || p98_tag_eq(t, "ADT") || p98_tag_eq(t, "Ctr") || p98_tag_eq(t, "Mat"), u => kr_push(nm(t), todo), u => todo))

# Module: src/core/reach.bend:122
@unsafe
def kr_refs_list(terms, todo):
  match terms:
    case Nil{}: todo
    case Con{h, rest}: kr_refs(h, kr_refs_list(rest, todo))

# Module: src/core/reach.bend:128
@unsafe
def kp_file_name(+ns: String, +aliases: List<&2,KTerm>, +name: String, +parts: List<&2,String>) -> String:
  match parts:
    case Con{owner, Con{local, rest}}: kc(String, p88_string_eq(ns, owner), u => local, u => kp_alias_name(aliases, owner, local, name))
    case _: kc(String, String.is_empty(ns), u => name, u => kp_alias_name(aliases, "", name, name))

# Module: src/core/pretty.bend:189
@unsafe
def w7_br_98(w7_c: Bool, +t: KTerm, +name: String, +arity: U32, +acc: List<&2, KTerm>) -> KPChain:
  match w7_c:
    case True{}:
      kp_chain(kid(t, U32.sub(arity, 1)), name, arity, Con{kid(t, 0), acc})
    case False{}:
      KPChain{List.reverse(&2, KTerm, acc), t}

@unsafe
def kp_chain(
  +t: KTerm,
  +name: String,
  +arity: U32,
  +acc: List<&2, KTerm>,
) -> KPChain:
  w7_br_98(kp_is(t, "Ctr", name) && U32.is_eq(terms_len(ks(t)), arity), t, name, arity, acc)

# Module: src/core/pretty.bend:269
@unsafe
def kp_word(
  +t: KTerm,
  +bit: U32,
  +left: U32,
  +acc: U32,
) -> Maybe<&2, U32>:
  kc(Maybe<&2, U32>, U32.is_eq(left, 0),
    u => kc(Maybe<&2, U32>, kp_is(t, "Ctr", "WNil"), u => Some{acc}, u => None{}),
    u => kc(Maybe<&2, U32>, kp_is(t, "Ctr", "WCon") && U32.is_eq(terms_len(ks(t)), 2) && (kp_is(kid(t, 0), "Ctr", "True") || kp_is(kid(t, 0), "Ctr", "False")),
      u => kp_word(kid(t, 1), U32.shl(bit), U32.sub(left, 1), kc(U32, kp_is(kid(t, 0), "Ctr", "True"), u => U32.or(acc, bit), u => acc)), u => None{}))

# Module: src/core/pretty.bend:320
@unsafe
def kp_float_text(s):
  w7_br_100(String.contains(s, ".") || String.contains(s, "n"), s)

# Module: src/core/pretty.bend:343
@unsafe
def w7_br_102(w7_c: Bool, +n: U32) -> String:
  match w7_c:
    case True{}:
      "\\u{" ++ kp_hex(n) ++ "}"
    case False{}:
      Char.show(Char.from_u32(n))

@unsafe
def kp_array(
  +t: KTerm,
) -> Maybe<&2, List<&2, KTerm>>:
  kc(Maybe<&2, List<&2, KTerm>>, kp_is(t, "Ctr", "ALeaf"), u => Some{[kid(t, 0)]},
    u => kc(Maybe<&2, List<&2, KTerm>>, kp_is(t, "Ctr", "ANode"), u => kp_array_join(kp_array(kid(t, 0)), kp_array(kid(t, 1))), u => None{}))

# Module: src/core/pretty.bend:430
@unsafe
def kp_let_names(ts):
  match ts:
    case Nil{}: ""
    case Con{+h, +rest}: kc(String, U32.is_eq(terms_len(rest), 0), u => "", u => kp_quant(qt(h)) ++ nm(h) ++ kc(String, U32.is_eq(terms_len(rest), 1), u => "", u => " " ++ kp_let_names(rest)))

# Module: src/core/pretty.bend:544
@unsafe
def uses_merge(
  +a: List<&2, KTerm>,
  +b: List<&2, KTerm>,
  +join: Bool,
) -> List<&2, KTerm>:
  match a:
    case Nil{}:
      b
    case Con{h, t}:
      Con{kt("Use", "", ix(h), kc(U32, join, u => qjoin(qt(h), uses_get(b, ix(h))), u => qadd(qt(h), uses_get(b, ix(h)))), Nil{}), uses_merge(t, uses_del(b, ix(h)), join)}

# Module: src/check/quantity.bend:107
@unsafe
def strip(
  +t: KTerm,
) -> KTerm:
  core_force(t)

# Module: src/check/quantity.bend:113
@unsafe
def ct(
  +r: KChecking,
) -> KTerm:
  match r:
    case KChecking{term, typ, uses, error, world, consumed}:
      term

# Module: src/check/kernel.bend:521
@unsafe
def cy(
  +r: KChecking,
) -> KTerm:
  match r:
    case KChecking{term, typ, uses, error, world, consumed}:
      typ

# Module: src/check/kernel.bend:529
@unsafe
def cs(
  +r: KChecking,
) -> List<&2, KTerm>:
  match r:
    case KChecking{term, typ, uses, error, world, consumed}:
      uses

# Module: src/check/kernel.bend:537
@unsafe
def ce(
  +r: KChecking,
) -> String:
  match r:
    case KChecking{term, typ, uses, error, world, consumed}:
      error

# Module: src/check/kernel.bend:545
@unsafe
def w7_if_infer_var(ok_t: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +dem: U32) -> KChecking:
  match ok_t:
    case True{}:
      infer_var(e, ctx, t, dem)
    case False{}:
      bad(cw(e), "cannot infer: annotation required")

@unsafe
def w7_if_infer_qnt(ok_t: Bool, +tag: String, +e: KEnv, +t: KTerm) -> KChecking:
  match ok_t:
    case True{}:
      ok(cw(e), t, typ(1), Nil{})
    case False{}:
      w7_if_infer_qua(p88_string_eq(tag, "Qua"), e, t)

@unsafe
def rw(+r: KChecking) -> KWorld:
  match r:
    case KChecking{term, typ, uses, error, world, consumed}: world

# Module: src/check/kernel.bend:1243
@unsafe
def rx(+r: KChecking) -> U32:
  match r:
    case KChecking{term, typ, uses, error, world, consumed}: consumed

# Module: src/check/kernel.bend:1248
@unsafe
def sp_len(+s: String) -> U32:
  sk_width(s, 0)

# Module: src/check/specialize.bend:98
@unsafe
def sk_width(+s: String, +n: U32) -> U32:
  match s:
    case SNil{}: n
    case SCon{c, rest}: sk_width(rest, U32.add(n, dg_units(c)))

# Module: src/check/specialize.bend:104
@unsafe
def sk_char(+c: Char, +n: U32) -> String:
  match n:
    case 34: "\\\""
    case 92: "\\\\"
    case 8: "\\b"
    case 9: "\\t"
    case 10: "\\n"
    case 12: "\\f"
    case 13: "\\r"
    case other:
      kc(String, U32.is_lt(n, 32), u => "\\u00" ++ kc(String, U32.is_lt(n, 16), u => "0", u => "") ++ kp_hex(n),
        u => kc(String, U32.is_ge(n, 55296) && U32.is_le(n, 57343), u => "\\u" ++ kp_hex(n), u => Char.show(c)))

# Module: src/check/specialize.bend:128
@unsafe
def prefix_state_exact_term(+left: KTerm, +right: KTerm) -> Bool:
  U32.is_eq(prefix_state_variant(left), prefix_state_variant(right)) && norm_exact_head(left, right) && Bool.not(Bool.xor(k_quantity_present(left), k_quantity_present(right))) && U32.is_eq(kb(left), kb(right)) && U32.is_eq(ke(left), ke(right)) && prefix_state_exact_terms(ks(left), ks(right))

# Module: src/check/prefix-state.bend:33
@unsafe
def prefix_state_exact_terms(left, right):
  match left right:
    case Nil{} Nil{}: True{}
    case Con{a, ar} Con{b, br}: kc(Bool, prefix_state_exact_term(a, b), u => prefix_state_exact_terms(ar, br), u => False{})
    case other_left other_right: False{}

# Module: src/check/prefix-state.bend:40
@unsafe
def w7_br_290(w7_c: Bool) -> KTerm:
  match w7_c:
    case True{}:
      typ(1)
    case False{}:
      {KTerm{"Error", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}

@unsafe
def w7_lex_ident(isId: Bool, +head: Char, +rest: String, +l: U32, +c: U32, +d: U32, +acc: List<&2, FToken>, +offset: U32, +previous: U32) -> List<&2, FToken>:
  match isId:
    case True{}:
      p150l_word_done(p150l_word(rest, SCon{head, ""}, 1, head), l, c, d, acc, offset, previous)
    case False{}:
      p150l_other(head, rest, l, c, d, acc, offset, previous)

@unsafe
def w7_lex_quote(isQ: Bool, +head: Char, +rest: String, +l: U32, +c: U32, +d: U32, +acc: List<&2, FToken>, +offset: U32, +previous: U32) -> List<&2, FToken>:
  match isQ:
    case True{}:
      p150l_quoted(p150l_quote(rest, head, SCon{head, ""}, 1, 1, l, U32.add(c, 1)), l, c, d, acc, offset, previous)
    case False{}:
      w7_lex_ident(f_ident(head) && Bool.not(Char.is_eq(head, '.')), head, rest, l, c, d, acc, offset, previous)

@unsafe
def w7_lex_comment(isHash: Bool, +head: Char, +rest: String, +l: U32, +c: U32, +d: U32, +acc: List<&2, FToken>, +offset: U32, +previous: U32, +code: U32) -> List<&2, FToken>:
  match isHash:
    case True{}:
      p150l_comment(rest, l, c, d, acc, f_cursor_add(offset, 1), previous)
    case False{}:
      w7_lex_quote(U32.is_eq(code, 34) || U32.is_eq(code, 39), head, rest, l, c, d, acc, offset, previous)

@unsafe
def w7_lex_space(isSp: Bool, +head: Char, +rest: String, +l: U32, +c: U32, +d: U32, +acc: List<&2, FToken>, +offset: U32, +previous: U32, +code: U32) -> List<&2, FToken>:
  match isSp:
    case True{}:
      p150l_cursor(rest, l, U32.add(c, 1), d, acc, f_cursor_add(offset, dg_units(head)), previous)
    case False{}:
      w7_lex_comment(U32.is_eq(code, 35), head, rest, l, c, d, acc, offset, previous, code)

@unsafe
def w7_lex_nl(isNl: Bool, +head: Char, +rest: String, +l: U32, +c: U32, +d: U32, +acc: List<&2, FToken>, +offset: U32, +previous: U32, +code: U32) -> List<&2, FToken>:
  match isNl:
    case True{}:
      p150l_newline(rest, l, c, d, acc, offset, previous)
    case False{}:
      w7_lex_space(f_ascii_space_code(code), head, rest, l, c, d, acc, offset, previous, code)

@unsafe
def w7_lex_nl_emit(isZero: Bool, +rest: String, +l: U32, +c: U32, +d: U32, +acc: List<&2, FToken>, +offset: U32, +previous: U32) -> List<&2, FToken>:
  match isZero:
    case True{}:
      p150l_cursor(rest, U32.add(l, 1), 0, d, Con{FToken{"
", l, c, 0, offset, f_cursor_add(offset, 1), previous}, acc}, f_cursor_add(offset, 1), previous)
    case False{}:
      p150l_cursor(rest, U32.add(l, 1), 0, d, acc, f_cursor_add(offset, 1), previous)

@unsafe
def w7_lex_cmt_nl(isNl: Bool, +head: Char, +rest: String, +l: U32, +c: U32, +d: U32, +acc: List<&2, FToken>, +offset: U32, +previous: U32) -> List<&2, FToken>:
  match isNl:
    case True{}:
      p150l_newline(rest, l, c, d, acc, offset, previous)
    case False{}:
      p150l_comment(rest, l, c, d, acc, f_cursor_add(offset, dg_units(head)), previous)

@unsafe
def w7_lex_word_ok(isZero: Bool, +word: String, +rest: String, +size: U32, +l: U32, +c: U32, +d: U32, +acc: List<&2, FToken>, +offset: U32, +previous: U32) -> List<&2, FToken>:
  match isZero:
    case True{}:
      p150l_unterminated(l, c, acc, offset, previous)
    case False{}:
      p150l_word_end(word, rest, l, c, d, acc, offset, previous, size, f_cursor_add(offset, size))

@unsafe
def w7_lex_q_eq(isEq: Bool, +head: Char, +rest: String, +quote: Char, +acc: String, +n: U32, +width: U32, +l: U32, +c: U32) -> P150LQuoted:
  match isEq:
    case True{}:
      P150LQuoted{String.reverse(SCon{head, acc}), rest, U32.add(n, 1), U32.add(width, 1), l, U32.add(c, 1)}
    case False{}:
      p150l_quote(rest, quote, SCon{head, acc}, U32.add(n, 1), U32.add(width, dg_units(head)), l, U32.add(c, 1))

@unsafe
def w7_lex_q_nl(isNl: Bool, +head: Char, +rest: String, +quote: Char, +acc: String, +n: U32, +width: U32, +l: U32, +c: U32) -> P150LQuoted:
  match isNl:
    case True{}:
      p150l_quote(rest, quote, SCon{head, acc}, U32.add(n, 1), U32.add(width, 1), U32.add(l, 1), 0)
    case False{}:
      w7_lex_q_eq(Char.is_eq(head, quote), head, rest, quote, acc, n, width, l, c)

@unsafe
def w7_lex_q_esc(isEsc: Bool, +head: Char, +rest: String, +quote: Char, +acc: String, +n: U32, +width: U32, +l: U32, +c: U32) -> P150LQuoted:
  match isEsc:
    case True{}:
      p150l_escape(rest, quote, acc, n, width, l, c)
    case False{}:
      w7_lex_q_nl(f_ascii_char_eq(head, '
'), head, rest, quote, acc, n, width, l, c)

@unsafe
def p150l_cursor(+s: String, +l: U32, +c: U32, +d: U32, +acc: List<&2,FToken>, +offset: U32, +previous: U32) -> List<&2,FToken>:
  match s:
    case SNil{}:
      w7_lex_eof(U32.is_eq(offset, 0), acc, offset, previous)
    case SCon{+head,+rest}:
      +code = Char.to_u32(head)
      w7_lex_nl(U32.is_eq(code, 10), head, rest, l, c, d, acc, offset, previous, code)

@unsafe
def p150l_newline(rest: String, +l: U32, +c: U32, +d: U32, +acc: List<&2,FToken>, +offset: U32, +previous: U32) -> List<&2,FToken>:
  w7_lex_nl_emit(U32.is_eq(d, 0), rest, l, c, d, acc, offset, previous)

# Comment bytes advance the indexed cursor, deliberately not the physical column.
@unsafe
def p150l_comment(s: String, +l: U32, +c: U32, +d: U32, +acc: List<&2,FToken>, +offset: U32, +previous: U32) -> List<&2,FToken>:
  match s:
    case SNil{}: p150l_cursor("",l,c,d,acc,offset,previous)
    case SCon{+head,+rest}:
      w7_lex_cmt_nl(f_ascii_char_eq(head, '\n'), head, rest, l, c, d, acc, offset, previous)

@unsafe
def p150l_word(+s: String, +acc: String, +n: U32, +last: Char) -> FScanned:
  p170ls_word(s,s,acc,n,last)


@unsafe
def p150l_word_done(sc: FScanned, +l: U32, +c: U32, +d: U32, +acc: List<&2,FToken>, +offset: U32, +previous: U32) -> List<&2,FToken>:
  match sc:
    case FScanned{word,rest,+size}:
      w7_lex_word_ok(U32.is_eq(size, 0), word, rest, size, l, c, d, acc, offset, previous)

@unsafe
def p150l_word_end(+word: String, rest: String, +l: U32, +c: U32, d: U32, acc: List<&2,FToken>, +offset: U32, previous: U32, size: U32, +end: U32) -> List<&2,FToken>:
  p150l_cursor(rest,l,U32.add(c,size),d,Con{FToken{word,l,c,1,offset,end,previous},acc},end,end)

# Metadata is accumulated with raw U32 addition, then added to the opening
# cursor once. Applying f_cursor_add per quote character changes wrap-to-zero.
# Only the entry's single/double quote calls reach these private scanners.
@unsafe
def p150l_quote(s: String, +quote: Char, +acc: String, +n: U32, +width: U32, +l: U32, +c: U32) -> P150LQuoted:
  match s:
    case SNil{}: P150LQuoted{"","",0,0,0,0}
    case SCon{+head,+rest}:
      w7_lex_q_esc(f_ascii_char_eq(head, '\\'), head, rest, quote, acc, n, width, l, c)

@unsafe
def p150l_escape(s: String, +quote: Char, +acc: String, +n: U32, +width: U32, +l: U32, +c: U32) -> P150LQuoted:
  match s:
    case SNil{}: P150LQuoted{"","",0,0,0,0}
    case SCon{+head,+rest}:
      f_choose(P150LQuoted,f_ascii_char_eq(head,'\n'),
        u => p150l_quote(rest,quote,SCon{head,SCon{'\\',acc}},U32.add(n,2),U32.add(width,2),U32.add(l,1),0),
        u => p150l_quote(rest,quote,SCon{head,SCon{'\\',acc}},U32.add(n,2),U32.add(width,U32.add(1,dg_units(head))),l,U32.add(c,2)))

@unsafe
def p150l_quoted(sc: P150LQuoted, +l: U32, +c: U32, +d: U32, +acc: List<&2,FToken>, +offset: U32, +previous: U32) -> List<&2,FToken>:
  match sc:
    case P150LQuoted{word,rest,size,width,line,column}:
      f_choose(List<&2,FToken>,U32.is_eq(size,0),
        u => p150l_unterminated(l,c,acc,offset,previous),
        u => p150l_quote_end(word,rest,l,c,d,acc,offset,previous,line,column,f_cursor_add(offset,width)))

@unsafe
def p150l_quote_end(word: String, rest: String, l: U32, c: U32, d: U32, acc: List<&2,FToken>, offset: U32, previous: U32, line: U32, column: U32, +end: U32) -> List<&2,FToken>:
  p150l_cursor(rest,line,column,d,Con{FToken{word,l,c,2,offset,end,previous},acc},end,end)

@unsafe
def p150l_other(+head: Char, +rest: String, +l: U32, +c: U32, +d: U32, +acc: List<&2,FToken>, +offset: U32, +previous: U32) -> List<&2,FToken>:
  p170ls_other(head,rest,rest,l,c,d,acc,offset,previous)


@unsafe
def p150l_triple(+a: Char, +b: Char, +c: Char) -> Bool:
  w7_br_301(f_ascii_char_eq(a,'.'), a, b, c)

@unsafe
def p150l_other_plain(+head: Char, +rest: String, +l: U32, +c: U32, +d: U32, +acc: List<&2,FToken>, +offset: U32, +previous: U32) -> List<&2,FToken>:
  f_choose(List<&2,FToken>,f_ascii_char_eq(head,'.'),u => p150l_word_done(p150l_word(rest,".",1,'.'),l,c,d,acc,offset,previous),
  u => f_choose(List<&2,FToken>,f_ascii_char_eq(head,'+'),u => p150l_plus(rest,l,c,d,acc,offset,previous,p150l_edge(acc)),
  u => f_choose(List<&2,FToken>,f_ascii_char_eq(head,'>'),u => p150l_greater(rest,l,c,d,acc,offset,previous,p150l_edge(acc)),
    u => p150l_symbol(head,rest,l,c,d,acc,offset,previous))))

# The old adjacency rule uses the stored token text, including >op/+bind,
# and no line check. One scan obtains length and the final character together.
@unsafe
def p150l_plus(+rest: String, +l: U32, +c: U32, +d: U32, +acc: List<&2,FToken>, +offset: U32, +previous: U32, edge: P150LEdge) -> List<&2,FToken>:
  match edge:
    case P150LEdge{column,natural}: p150l_plus_at(rest,l,c,d,acc,offset,previous,natural && U32.is_eq(c,column))

@unsafe
def p150l_plus_at(+rest: String, +l: U32, +c: U32, +d: U32, +acc: List<&2,FToken>, +offset: U32, +previous: U32, +contiguous: Bool) -> List<&2,FToken>:
  p170ls_plus(rest,rest,l,c,d,acc,offset,previous,contiguous)


@unsafe
def p150l_greater(+rest: String, +l: U32, +c: U32, +d: U32, +acc: List<&2,FToken>, +offset: U32, +previous: U32, edge: P150LEdge) -> List<&2,FToken>:
  match edge:
    case P150LEdge{column,natural}: p150l_greater_at(rest,l,c,d,acc,offset,previous,U32.is_gt(c,column))

@unsafe
def p150l_greater_at(+rest: String, +l: U32, +c: U32, +d: U32, +acc: List<&2,FToken>, +offset: U32, +previous: U32, +gap: Bool) -> List<&2,FToken>:
  p170ls_greater(rest,rest,l,c,d,acc,offset,previous,gap)


@unsafe
def p150l_symbol(+head: Char, +rest: String, +l: U32, +c: U32, +d: U32, +acc: List<&2,FToken>, +offset: U32, +previous: U32) -> List<&2,FToken>:
  p170ls_symbol(head,rest,rest,l,c,d,acc,offset,previous)


# Scalar predicates avoid expanding Char literal patterns into bit patterns.
@unsafe
def p150l_single(+head: Char, rest: String, l: U32, c: U32, d: U32, acc: List<&2,FToken>, offset: U32, previous: U32) -> List<&2,FToken>:
  p150l_emit(SCon{head,""},rest,l,c,p150l_depth(head,d),acc,offset,previous,1,dg_units(head))

@unsafe
def p150l_emit(text: String, rest: String, +l: U32, +c: U32, d: U32, acc: List<&2,FToken>, +offset: U32, previous: U32, columns: U32, width: U32) -> List<&2,FToken>:
  p150l_emitted(text,rest,l,c,d,acc,offset,previous,columns,f_cursor_add(offset,width))

@unsafe
def p150l_emitted(text: String, rest: String, +l: U32, +c: U32, d: U32, acc: List<&2,FToken>, offset: U32, previous: U32, columns: U32, +end: U32) -> List<&2,FToken>:
  p150l_cursor(rest,l,U32.add(c,columns),d,Con{FToken{text,l,c,0,offset,end,previous},acc},end,end)


# Composite Phase152: preserve the public lexer contract and all old helper laws.
@unsafe
def f_skip(+input: FInput) -> FInput:
  match input:
    case FInput{tokens, context}:
      f_choose(FInput, f_eq(f_raw_tx(tokens), "\n") || f_eq(f_raw_tx(tokens), ";"),
        u => FInput{f_raw_skip(tokens), context}, u => input)

# Module: src/front/lexer.bend:393
@unsafe
def f_space(+input: FInput) -> FInput:
  match input:
    case FInput{tokens, context}:
      f_choose(FInput, f_eq(f_raw_tx(tokens), "\n"),
        u => FInput{f_raw_space(tokens), context}, u => input)

# Resolution selects the declaration table named by the syntax. A local def
# named Done must not hide Base's Done constructor, or vice versa.
@unsafe
def f_context_name_resolved(+term: KTerm, +input: FInput, +resolved: KTerm) -> FParsed:
  match input:
    case FInput{tokens, context}:
      match context:
        case FParseContext{scope, env, next}:
          f_choose(FParsed, p98_tag_eq(resolved, "Error"), u => f_context_error_at(resolved, input, ke(term)), u => f_choose(FParsed, String.contains(nm(term), "."), u => FParsed{resolved, input},
            u => FParsed{kt_span("FName", nm(term), 0, 1, [kt_span("Var", nm(term), next, 1, Nil{}, kb(term), ke(term)), resolved], kb(term), ke(term)), FInput{tokens, FParseContext{scope, env, U32.add(next, 1)}}}))

# Module: src/front/contextual.bend:34
@unsafe
def f_context_call_head(+term: KTerm) -> KTerm:
  w7_br_302(p98_tag_eq(term, "FName"), term)

# Module: src/front/contextual.bend:76
@unsafe
def f_context_error_at(+error: KTerm, +input: FInput, +cursor: U32) -> FParsed:
  FParsed{error, f_prepend(FToken{"", f_line(input), f_col(input), 0, cursor, cursor, cursor}, f_empty(input))}

# Module: src/front/contextual.bend:90
@unsafe
def f_context_pattern_checked(+pattern: KTerm, +input: FInput, +cursor: U32, +error: Maybe<&2,KTerm>) -> FParsed:
  match error:
    case Some{error}: f_context_error_at(error, input, cursor)
    case None{}: f_context_open(pattern, input)

# Module: src/front/contextual.bend:118
@unsafe
def w7_br_306(w7_c: Bool, +term: KTerm, +input: FInput, +resolved: KTerm) -> FParsed:
  match w7_c:
    case True{}:
      f_context_error_at(resolved, input, f_previous_end(input))
    case False{}:
      FParsed{kt_span("Ctr", nm(resolved), 0, 1, ks(term), kb(term), ke(term)), input}

@unsafe
def f_context_syntax(+term: KTerm) -> KTerm:
  w7_br_307(f_eq(tg(term), "FName"), term)

# Module: src/front/contextual.bend:328
@unsafe
def f_atid(
  +ts: FInput,
) -> U32:
  U32.add(U32.mul(f_line(ts), 65536), f_col(ts))

# Module: src/front/parser.bend:162
@unsafe
def f_err(
  +ts: FInput,
  +msg: String,
) -> FParsed:
  FParsed{kt("Error", "line " ++ U32.show(f_line(ts)) ++ ":" ++ U32.show(f_col(ts)) ++ ": " ++ msg ++ "; got " ++ f_tx(ts), 0, 0, Nil{}), f_empty(ts)}

# Module: src/front/parser.bend:169
@unsafe
def f_kind_token(ts):
  f_kind(ts)

# Module: src/front/parser.bend:282
@unsafe
def w7_br_322(w7_c: Bool, +ts: FInput) -> U32:
  match w7_c:
    case True{}:
      0
    case False{}:
      w7_br_321(f_eq(f_tx(ts), "+") || f_eq(f_tx(ts), "+bind"))

@unsafe
def f_quant(
  +ts: FInput,
) -> U32:
  w7_br_322(f_eq(f_tx(ts), "-") || f_eq(f_tx(ts), "~"), ts)

# Module: src/front/parser.bend:302
@unsafe
def w7_br_328(w7_c: Bool, +s: String) -> U32:
  match w7_c:
    case True{}:
      10
    case False{}:
      w7_br_327(f_eq(s, "+") || f_eq(s, "-"), s)

@unsafe
def w7_br_345(w7_c: Bool, +s: String) -> String:
  match w7_c:
    case True{}:
      ".and"
    case False{}:
      w7_br_344(f_eq(s, ".|."), s)

@unsafe
def fpe_error(ts, legacy, expected):
  fpe_legacy(ts, nm(f_pn(f_err(ts, legacy))), expected)

# Keep an already formatted fallback unchanged; expectation is explicit input.

# Module: src/front/parser.bend:561
@unsafe
def fpe_legacy(ts, legacy, expected):
  FParsed{kt("Error", legacy, f_line(ts), f_col(ts), [kt("ParseExpected", expected, 0, 0, Nil{}), kt("ParseToken", f_tx(ts), 0, 0, Nil{})]), f_context_failure_rest(ts, ts)}

# Module: src/front/parser.bend:565
@unsafe
def fpe_span(+start: FInput, +end: FInput, +legacy: String, +expected: String, +observed: String) -> FParsed:
  FParsed{kt("Error", nm(f_pn(f_err(start, legacy))), f_line(start), f_col(start), [kt("ParseExpected", expected, 0, 0, Nil{}), kt("ParseToken", f_tx(start), 0, 0, Nil{}), kt("ParseRange", observed, f_line(end), f_col(end), Nil{})]), f_context_failure_rest(start, end)}

# Module: src/front/parser.bend:586
@unsafe
def w7_br_383(w7_c: Bool, +t: KTerm, +begin: U32, +end: U32) -> KTerm:
  match w7_c:
    case True{}:
      f_span_created(t, begin, end)
    case False{}:
      k_with_span(t, begin, end)

@unsafe
def f_located_term(+t: KTerm, +begin: U32, +end: U32, +created: Bool) -> KTerm:
  w7_br_383(created, t, begin, end)

# Module: src/front/parser.bend:642
@unsafe
def fpe_line(+ts: FInput, +legacy: String, +expected: String) -> KTerm:
  kt("Error", legacy, f_line(ts), f_col(ts), [kt("ParseExpected", expected, 0, 0, Nil{}), kt("ParseToken", f_tx(ts), 0, 0, Nil{}), atom("ParseLine")])

# Module: src/front/parser.bend:707
@unsafe
def fpe_point_observed(+source: String, +offset: U32) -> String:
  match source:
    case SNil{}: "end of input"
    case SCon{c, rest}:
      f_choose(String, U32.is_lt(offset, dg_units(c)),
        u => f_choose(String, U32.is_le(Char.to_u32(c), 65535), u => "'" ++ SCon{c, ""} ++ "'", u => ""),
        u => fpe_point_observed(rest, U32.sub(offset, dg_units(c))))

# Module: src/front/parser.bend:726
@unsafe
def fpe_match_message(+text: String, +mode: U32) -> String:
  "'" ++ text ++ "' can't be matched" ++ f_choose(String, U32.is_eq(mode, 0),
    u => " in this position (it is matched after a local statement or after a match on a later binder, it was already matched, or it is a def)",
    u => f_choose(String, (f_ascii_alpha(f_head(text)) || Char.is_eq(f_head(text), '_')) && fpe_name_text(text),
      u => " here (match it in the same match as the pattern that introduced it)",
      u => " (this value is already a constructor: bind its fields directly)"))

# Module: src/front/parser.bend:762
@unsafe
def fpe_name_text(+text: String) -> Bool:
  match text:
    case SNil{}: True{}
    case SCon{c, rest}: f_ident(c) && fpe_name_text(rest)

# Authentic parser spans are UTF16 scalar boundaries, not String character counts.

# Module: src/front/parser.bend:769
@unsafe
def fpe_source_slice(+source: String, +begin: U32, +end: U32) -> String:
  match source:
    case SNil{}: ""
    case SCon{c, rest}:
      f_choose(String, U32.is_ge(begin, dg_units(c)),
        u => fpe_source_slice(rest, U32.sub(begin, dg_units(c)), U32.sub(end, dg_units(c))),
        u => f_choose(String, U32.is_ge(end, dg_units(c)), u => SCon{c, fpe_source_slice(rest, 0, U32.sub(end, dg_units(c)))}, u => ""))

# Module: src/front/declarations.bend:234
@unsafe
def w7_br_404(w7_c: Bool, +ts: FInput) -> KTerm:
  match w7_c:
    case True{}:
      kt("Error", "foreign import requires a quoted .c or .js path", 0, 0, Nil{})
    case False{}:
      f_pn(fpe_legacy(ts, "foreign import requires a quoted .c or .js path", "'\"'"))

@unsafe
def ff_parallel(t, vars, r):
  match r:
    case FFlatten{body, next}:
      f_choose(FFlatten, ff_failed(body), u => FFlatten{body, next}, u => FFlatten{f_lbind(vars, kt_span("Let", "", 0, 1, norm_join(f_parallel_binds(ks(kid(t, 0)), ks(kid(t, 1))), [f_unlamb(body, terms_len(ks(kid(t, 0))))]), kb(t), ke(t))), next})

# Module: src/front/flatten.bend:126
@unsafe
def w12_rows_have_ctor(rows: List<&2, KTerm>, +name: String) -> Bool:
  match rows:
    case Nil{}: False{}
    case Con{+r, rs}:
      (f_eq(tg(f_rowpat(r)), "Ctr") && f_eq(nm(f_rowpat(r)), name)) || w12_rows_have_ctor(rs, name)

@unsafe
def w12_miss_rows(+rows: List<&2, KTerm>, +c: KTerm) -> List<&2, KTerm>:
  match rows:
    case Nil{}:
      Nil{}
    case Con{+r, +rs}:
      f_choose(List<&2, KTerm>, f_eq(tg(f_rowpat(r)), "Ctr") && w12_ctor_same(f_rowpat(r), c), u => w12_miss_rows(rs, c), u => Con{r, w12_miss_rows(rs, c)})

# Module: src/front/flatten.bend:172
@unsafe
def w7_br_412(w7_c: Bool, +t: KTerm, +id: U32, +v: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      w7_br_411(U32.is_eq(kb(v), 0) && U32.is_eq(ke(v), 0) && Bool.not(f_eq(tg(v), "FUnboundVar")), t, v)
    case False{}:
      k_with_children(t, f_subs(ks(t), id, v))

@unsafe
def f_sub(
  +t: KTerm,
  +id: U32,
  +v: KTerm,
) -> KTerm:
  w7_br_412(f_eq(tg(t), "Var") && U32.is_eq(ix(t), id), t, id, v)

# Module: src/front/elaborate.bend:96
@unsafe
def f_subs(ts, id, v):
  match ts:
    case Nil{}:
      Nil{}
    case Con{t, rest}:
      Con{f_sub(t, id, v), f_subs(rest, id, v)}

# Module: src/front/elaborate.bend:104
@unsafe
def f_first_ctor(rows):
  match rows:
    case Nil{}:
      {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}
    case Con{+r, rs}:
      f_choose(KTerm, f_eq(tg(f_rowpat(r)), "Ctr"), u => f_rowpat(r), u => f_first_ctor(rs))

# Module: src/front/elaborate.bend:118
@unsafe
def f_miss_rows(rows, name):
  match rows:
    case Nil{}:
      Nil{}
    case Con{+r, rs}:
      f_choose(List<&2, KTerm>, f_eq(tg(f_rowpat(r)), "Ctr") && f_eq(nm(f_rowpat(r)), name), u => f_miss_rows(rs, name), u => Con{r, f_miss_rows(rs, name)})

# Module: src/front/elaborate.bend:154
@unsafe
def f_nat(
  +n: U32,
) -> KTerm:
  core_nat_make(n)

# Module: src/front/elaborate.bend:166
@unsafe
def w7_br_413(w7_c: Bool, +s: String, +acc: U32) -> KTerm:
  match w7_c:
    case True{}:
      f_number(f_tail(s), U32.add(U32.mul(acc, 10), U32.sub(Char.to_u32(f_head(s)), 48)))
    case False{}:
      kt("Error", "invalid or unsupported numeric literal", 0, 0, Nil{})

@unsafe
def w7_br_414(w7_c: Bool, +s: String, +acc: U32) -> KTerm:
  match w7_c:
    case True{}:
      f_nat(acc)
    case False{}:
      w7_br_413(Char.is_digit(f_head(s)) && (U32.is_lt(acc, 429496729) || (U32.is_eq(acc, 429496729) && U32.is_le(Char.to_u32(f_head(s)), 53))), s, acc)

@unsafe
def w7_br_415(w7_c: Bool, +s: String, +acc: U32) -> KTerm:
  match w7_c:
    case True{}:
      f_u32(acc)
    case False{}:
      w7_br_414(f_eq(s, "n"), s, acc)

@unsafe
def f_number(
  +s: String,
  +acc: U32,
) -> KTerm:
  w7_br_415(String.is_empty(s), s, acc)

# Module: src/front/elaborate.bend:173
@unsafe
def w7_br_421(w7_c: Bool, +c: Char) -> U32:
  match w7_c:
    case True{}:
      9
    case False{}:
      w7_br_420(Char.is_eq(c, 'r'), c)

@unsafe
def w7_br_422(w7_c: Bool, +c: Char) -> U32:
  match w7_c:
    case True{}:
      10
    case False{}:
      w7_br_421(Char.is_eq(c, 't'), c)

@unsafe
def w7c_pat_sub_term(hit: Bool, +tag: String, +name: String, +tid: U32, +quant: U32, +kids: List<&2,KTerm>, +rem: List<&2,String>, +ob: U32, +oe: U32, +t: KTerm, +id: U32, +value: KTerm) -> KTerm:
  match hit:
    case True{}:
      f_pattern_value(value, ob, oe)
    case False{}:
      match kids:
        case Nil{}:
          t
        case Con{k0, r0}:
          match r0:
            case Nil{}:
              KTerm{tag, name, tid, quant, Con{f_pattern_sub(k0, id, value), Nil{}}, rem, ob, oe}
            case Con{k1, r1}:
              match r1:
                case Nil{}:
                  KTerm{tag, name, tid, quant, Con{f_pattern_sub(k0, id, value), Con{f_pattern_sub(k1, id, value), Nil{}}}, rem, ob, oe}
                case Con{_, _}:
                  KTerm{tag, name, tid, quant, Con{f_pattern_sub(k0, id, value), Con{f_pattern_sub(k1, id, value), f_pattern_subs(r1, id, value)}}, rem, ob, oe}

@unsafe
def f_pattern_sub(+t: KTerm, +id: U32, +value: KTerm) -> KTerm:
  match t:
    case KLiteral{_, _, _, _, _}:
      t
    case KLambda{name, lid, quant, kids, rem, ob, oe, pres}:
      match kids:
        case Nil{}: t
        case Con{k0, r0}:
          match r0:
            case Nil{}: KLambda{name, lid, quant, Con{f_pattern_sub(k0, id, value), Nil{}}, rem, ob, oe, pres}
            case Con{_, _}: KLambda{name, lid, quant, Con{f_pattern_sub(k0, id, value), f_pattern_subs(r0, id, value)}, rem, ob, oe, pres}
    case KTerm{tag, name, tid, quant, kids, rem, ob, oe}:
      w7c_pat_sub_term(U32.is_eq(tid, id) && f_eq(tag, "Var"), tag, name, tid, quant, kids, rem, ob, oe, t, id, value)

# Module: src/front/elaborate.bend:194
@unsafe
def f_pattern_subs(+terms: List<&2,KTerm>, +id: U32, +value: KTerm) -> List<&2,KTerm>:
  match terms:
    case Nil{}: Nil{}
    case Con{head, rest}: Con{f_pattern_sub(head, id, value), f_pattern_subs(rest, id, value)}

@unsafe
def f_pattern_value(+t: KTerm, +begin: U32, +end: U32) -> KTerm:
  w7c_pat_val_branch(U32.is_gt(begin, 0), t, begin, end)

# Module: src/front/elaborate.bend:214
@unsafe
def f_pattern_values(+terms: List<&2,KTerm>, +begin: U32, +end: U32) -> List<&2,KTerm>:
  match terms:
    case Nil{}: Nil{}
    case Con{head, rest}: Con{f_pattern_value(head, begin, end), f_pattern_values(rest, begin, end)}

# Module: src/front/elaborate.bend:220
@unsafe
def w7_br_426(w7_c: Bool, +origin: KTerm, +rest: String, +offset: U32, +legacy: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      fpe_expected_at(origin, nm(legacy), "a u32 literal up to 4294967295 (got " ++ nm(origin) ++ ")", "'" ++ nm(origin) ++ "'")
    case False{}:
      w7_br_425((Char.is_eq(f_head(rest), '.') && f_ascii_digit(f_head(f_tail(rest)))) || Char.is_eq(f_head(rest), 'n'), origin, rest, offset, legacy)

@unsafe
def f_do_bind_types(+types: List<&2,KTerm>, +ty: KTerm) -> List<&2,KTerm>:
  match types:
    case Nil{}: [ty]
    case Con{head, rest}: norm_join(f_init(types), [ty, f_last(types)])

# Module: src/front/sugar.bend:64
@unsafe
def f_error_term(
  +t: KTerm,
) -> String:
  nm(fpe_term(t))

# Module: src/front/sugar.bend:191
@unsafe
def f_hex(
  +c: Char,
) -> U32:
  w7_br_447(Char.is_digit(c), c)

# Upstream permits one to eight hex digits, including non-scalar U32 values.
# The digit limit rejects overflow spellings before U32 accumulation can wrap.
# Module: src/front/unicode.bend:50
@unsafe
def w7_br_448(w7_c: Bool, +s: String, +code: U32, +count: U32) -> FDecoded:
  match w7_c:
    case True{}:
      f_decode_unicode(f_tail(s), U32.add(U32.mul(code, 16), f_hex(f_head(s))), U32.add(count, 1))
    case False{}:
      FDecoded{0, s, "invalid Unicode escape"}

@unsafe
def w7_br_449(w7_c: Bool, +s: String, +code: U32, +count: U32) -> FDecoded:
  match w7_c:
    case True{}:
      FDecoded{code, f_tail(s), ""}
    case False{}:
      w7_br_448(U32.is_lt(f_hex(f_head(s)), 16) && U32.is_lt(count, 8), s, code, count)

@unsafe
def f_decode_unicode(s, code, count):
  w7_br_449(Char.is_eq(f_head(s), '}') && U32.is_gt(count, 0), s, code, count)

# Module: src/front/unicode.bend:54
@unsafe
def f_char_decoded(d):
  match d:
    case FDecoded{code, +rest, +err}:
      f_choose(KTerm, String.is_empty(err) && f_eq(rest, "'"), u => kt("Ctr", "Chr", 0, 1, [f_u32(code)]), u => kt("Error", "character literal requires one character and a closing quote", 0, 0, Nil{}))

# Module: src/front/unicode.bend:64
@unsafe
def f_float_bits(
  +bits: U32,
) -> KTerm:
  w7_br_450(U32.is_eq(U32.and(bits, 2139095040), 2139095040), bits)

# Module: src/front/unicode.bend:71
@unsafe
def w7_br_452(w7_c: Bool, +code: U32, +tail: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      kl_make("String", 0, SCon{Char.from_u32(code), kl_text(tail)})
    case False{}:
      kt("Ctr", "SCon", 0, 1, [kt("Ctr", "Chr", 0, 1, [f_u32(code)]), tail])

@unsafe
def f_float_read(m):
  match m:
    case None{}:
      kt("Error", "invalid f32 literal", 0, 0, Nil{})
    case Some{v}:
      f_float_bits(F32.bits(v))

# Module: src/front/literals_arrays.bend:77
@unsafe
def w7_br_459(w7_c: Bool, +n: U32, +d: U32) -> KTerm:
  match w7_c:
    case True{}:
      kt("Error", "array count must be a positive power of two", 0, 0, Nil{})
    case False{}:
      f_power_bits(U32.shrn(n, 1n), U32.add(d, 1))

@unsafe
def w7_br_460(w7_c: Bool, +n: U32, +d: U32) -> KTerm:
  match w7_c:
    case True{}:
      f_nat(d)
    case False{}:
      w7_br_459(U32.is_eq(n, 0) || U32.is_eq(U32.and(n, 1), 1), n, d)

@unsafe
def f_power_bits(n, d):
  w7_br_460(U32.is_eq(n, 1), n, d)

# Module: src/front/literals_arrays.bend:104
@unsafe
def w7_br_464(w7_c: Bool, +a: KTerm, +b: KTerm, +value: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      kt("Literal", U32.show(U32.add(kl_number(a), kl_number(value))) ++ "n", 0, 1, Nil{})
    case False{}:
      w7_br_463(core_nat(a) && U32.is_le(kl_number(a), 256), a, b)

@unsafe
def f_array_depth_at(+size: KTerm, +value: KTerm) -> KTerm:
  w7_br_467(f_eq(tg(value), "Error"), size, value)

# Module: src/front/literals_arrays.bend:159
@unsafe
def f_context_namespace_app(+term: KTerm, +head: KTerm, +arg: KTerm) -> KTerm:
  w7_br_478(f_context_stop(head), term, head, arg)

# Module: src/front/literals_arrays.bend:201
@unsafe
def f_context_namespace_resolved(+origin: KTerm, +resolved: KTerm) -> KTerm:
  w7_br_479(f_context_stop(resolved), origin, resolved)

# Only index-write syntax starts at its array binder; an explicit call does not.

# Module: src/front/literals_arrays.bend:216
@unsafe
def w7_br_480(w7_c: Bool, +term: KTerm, +begin: U32) -> KTerm:
  match w7_c:
    case True{}:
      f_context_write_var(kid(kid(kid(term, 0), 0), 1), begin)
    case False{}:
      {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}

@unsafe
def w7_br_482(w7_c: Bool, +term: KTerm, +body: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      body
    case False{}:
      k_with_children(term, norm_join(f_init(ks(term)), [body]))

@unsafe
def f_context_namespace_let(+term: KTerm, +body: KTerm) -> KTerm:
  w7_br_482(f_context_stop(body), term, body)
# The higher pass visits eager children and beta-reduces an applied lambda.
# Lowering forces deferred binder children only when its caller demands them.

# Module: src/front/literals_arrays.bend:230
@unsafe
def w7_rename_hit(hit: Bool, +t: KTerm, +m: KTerm, +ms: List<&2, KTerm>) -> KTerm:
  match hit:
    case True{}:
      w7_rename_ref(p98_tag_eq(kid(m, 0), "Ref"), t, m)
    case False{}:
      f_rename_var(t, ms)

@unsafe
def f_rename_var(t, env):
  match env:
    case Nil{}:
      t
    case Con{+m, ms}:
      w7_rename_hit(U32.is_eq(ix(t), ix(m)), t, m, ms)

# Module: src/front/freshen.bend:38
@unsafe
def f_path_dir(
  +path: String,
) -> String:
  f_path_scan(path, "", "")

# Module: src/load/paths.bend:37
@unsafe
def w7_br_494(w7_c: Bool, +t: KTerm, +dir: String) -> KTerm:
  match w7_c:
    case True{}:
      t
    case False{}:
      k_rebuild(t, f_choose(String, f_eq(tg(t), "Path"), u => f_path_join(dir, nm(t)), u => nm(t)), ix(t), qt(t), f_path_terms(ks(t), dir), rm(t), kb(t), ke(t))

@unsafe
def f_path_term(
  +t: KTerm,
  +dir: String,
) -> KTerm:
  w7_br_494(core_literal(t), t, dir)

# Module: src/load/paths.bend:56
@unsafe
def f_path_terms(ts, dir):
  match ts:
    case Nil{}:
      Nil{}
    case Con{t, rest}:
      Con{f_path_term(t, dir), f_path_terms(rest, dir)}

# Module: src/load/paths.bend:64
@unsafe
def w7_br_497(w7_c: Bool, +t: KTerm, +args: List<&2, KTerm>, +g: U32) -> KTerm:
  match w7_c:
    case True{}:
      KTerm{"ADT", nm(t), ix(t), qt(t), norm_join(f_quants(g, f_choose(U32, U32.is_eq(qt(t), 2), u => 2, u => 1), t), args), rm(t), kb(t), ke(t)}
    case False{}:
      KTerm{"ADT", nm(t), ix(t), qt(t), f_choose(List<&2,KTerm>, U32.is_eq(qt(t), 2), u => norm_join(f_quants(g, 2, t), f_drop_terms(args, g)), u => args), rm(t), kb(t), ke(t)}

@unsafe
def f_adt_fill(t, args, arity, g):
  w7_br_497(U32.is_eq(U32.add(terms_len(args), g), arity), t, args, g)

# Module: src/front/families.bend:57
@unsafe
def w7_br_498(w7_c: Bool, +f: KTerm, +x: KTerm, +begin: U32, +end: U32) -> KTerm:
  match w7_c:
    case True{}:
      f_sub(kid(f, 0), ix(f), x)
    case False{}:
      kt_span("App", "", 0, 0, [f, x], begin, end)

@unsafe
def f_mark_rows(rows, q):
  match rows:
    case Nil{}:
      q
    case Con{+r, rs}:
      f_mark_rows(rs, f_choose(U32, f_eq(tg(f_rowpat(r)), "Var") && U32.is_eq(qt(f_rowpat(r)), 2), u => 2, u => q))

# Module: src/front/families.bend:73
@unsafe
def f_reserved(s):
  w7_reserved_c(w7_char0(s), s)

# Module: src/front/validate.bend:29
@unsafe
def w7_br_501(w7_c: Bool, +a: KTerm, +body: KTerm, +cursor: U32) -> KTerm:
  match w7_c:
    case True{}:
      w7_br_500(String.contains(nm(a), "."), a, body, cursor)
    case False{}:
      fpe_point_at(kt_span("LambdaCursor", "", 0, 0, Nil{}, cursor, cursor), "a lambda binder must be a non-reserved name", "a lambda binder (one name: k => body)")

@unsafe
def w7_br_507(w7_c: Bool, +s: String) -> Bool:
  match w7_c:
    case True{}:
      True{}
    case False{}:
      f_ident(f_head(s)) && (Bool.not(Char.is_eq(f_head(s), '.')) || f_ascii_alpha(f_head(f_tail(s))) || Char.is_eq(f_head(f_tail(s)), '_')) && f_name_chars(f_tail(s))

@unsafe
def f_name_chars(s):
  w7_br_507(String.is_empty(s), s)

# Module: src/front/validate.bend:164
@unsafe
def f_import_header_error(+ts: FInput) -> KTerm:
  fpe_line(ts, "a module import requires as followed by an alias", "an import ('import Base', or 'import <path> as <Name>')")

# Module: src/load/imports.bend:28
@unsafe
def w7_br_510(w7_c: Bool, +path: String) -> Bool:
  match w7_c:
    case True{}:
      f_import_segments(f_tail(path), True{})
    case False{}:
      f_import_parents(path)

@unsafe
def w7_br_511(w7_c: Bool, +path: String) -> Bool:
  match w7_c:
    case True{}:
      f_import_parents(f_drop_chars(path, 3))
    case False{}:
      f_import_segments(path, True{})

@unsafe
def f_import_parents(+path: String) -> Bool:
  w7_br_511(String.starts_with(path, "../"), path)

# Module: src/load/imports.bend:50
@unsafe
def w7_br_512(w7_c: Bool, +ts: FInput) -> String:
  match w7_c:
    case True{}:
      ">>"
    case False{}:
      f_tx(ts)

@unsafe
def w7_br_513(w7_c: Bool, +ts: FInput) -> String:
  match w7_c:
    case True{}:
      ">"
    case False{}:
      w7_br_512(f_eq(f_tx(ts), ">>op"), ts)

@unsafe
def f_path_push(part, parts):
  f_choose(List<&2,String>, String.is_empty(part) || f_eq(part, "."), u => parts, u => f_choose(List<&2,String>, f_eq(part, ".."), u => f_path_parent(parts), u => Con{part, parts}))

# Module: src/load/graph.bend:103
@unsafe
def f_strip_bend(
  +s: String,
) -> String:
  String.reverse(f_drop_chars(String.reverse(s), 5))

# Module: src/load/graph.bend:132
@unsafe
def f_relative_parts(+root: List<&2,String>, +file: List<&2,String>) -> String:
  match root file:
    case Con{r, rs} Con{f, fs}:
      f_choose(String, p88_string_eq(r, f), u => f_relative_parts(rs, fs), u => f_relative_parents(root) ++ f_path_join_parts(file, ""))
    case _ _:
      f_relative_parents(root) ++ f_path_join_parts(file, "")

# Module: src/load/graph.bend:423
@unsafe
def f_path_segments(+path: String) -> List<&2,String>:
  f_path_nonempty(String.split(path, '/'))

# Module: src/load/graph.bend:437
@unsafe
def f_alias(name, imports):
  match imports:
    case Nil{}:
      name
    case Con{+im, rest}:
      f_choose(String, U32.is_gt(terms_len(ks(im)), 0) && f_prefix(name, nm(kid(im, 0)) ++ "."), u => nm(im) ++ ":" ++ f_drop_prefix(name, nm(kid(im, 0)) ++ "."), u => f_alias(name, rest))

# Module: src/load/modules.bend:64
@unsafe
def f_header_line(+source: String, +acc: String, +size: U32) -> FScanned:
  match source:
    case SNil{}: FScanned{String.reverse(acc), "", size}
    case SCon{c, rest}:
      f_choose(FScanned, Char.is_eq(c, '\n'), u => FScanned{String.reverse(SCon{c, acc}), rest, U32.add(size, 1)}, u => f_header_line(rest, SCon{c, acc}, U32.add(size, dg_units(c))))

# Module: src/load/modules.bend:165
@unsafe
def w7_br_539(w7_c: Bool, +source: String) -> String:
  match w7_c:
    case True{}:
      f_header_space(f_tail(source))
    case False{}:
      source

@unsafe
def f_header_space(+source: String) -> String:
  w7_br_539(Bool.not(String.is_empty(source)) && f_ascii_space(f_head(source)), source)

# Module: src/load/modules.bend:169
@unsafe
def f_header_prefix(+line: String) -> Bool:
  +text = f_header_space(line)
  String.is_empty(text) || Char.is_eq(f_head(text), '#') || Char.is_eq(f_head(text), '\n') || (String.starts_with(text, "import") && (String.is_empty(f_drop_chars(text, 6)) || f_ascii_space(f_head(f_drop_chars(text, 6))) || Char.is_eq(f_head(f_drop_chars(text, 6)), '\n')))

# Module: src/load/modules.bend:174
@unsafe
def f_complete_seed(+source: FSource, +graph: FGraph, +path: String, +text: String, +book: List<&2,KDef>) -> FCompletion:
  match graph:
    case FGraph{prior, error, done}:
      f_choose(FCompletion, String.is_empty(error),
        u => f_choose(FCompletion, f_seed_matches(source, path, text),
          u => FCompletion{fs_inject(graph, FSeed{path, book, ""}), FResult{Nil{}, "", Nil{}}},
          u => FCompletion{f_graph_error(graph, "Base seed source mismatch"), FResult{Nil{}, "Base seed source mismatch", Nil{}}}),
        u => FCompletion{graph, FResult{Nil{}, error, Nil{}}})

# Module: src/load/prefix.bend:15
@unsafe
def f_fresh_prefix_exact_terms(+left: List<&2,KTerm>, +right: List<&2,KTerm>) -> Bool:
  match left right:
    case Nil{} Nil{}: True{}
    case Con{a, ar} Con{b, br}:
      kc(Bool, U32.is_eq(f_fresh_prefix_variant(a), f_fresh_prefix_variant(b)) && norm_exact_head(a, b) && Bool.not(Bool.xor(k_quantity_present(a), k_quantity_present(b))) && U32.is_eq(kb(a), kb(b)) && U32.is_eq(ke(a), ke(b)),
        u => f_fresh_prefix_exact_terms(norm_join(ks(a), ar), norm_join(ks(b), br)), u => False{})
    case other_left other_right: False{}

# Module: src/load/prefix.bend:33
@unsafe
def f_prefix_seed_completed(+prior: FGraph, +ns: String, +prior_ready: Bool, +prefix: List<&2,KDef>, +completion: FCompletion) -> FPrefixCompletion:
  match prior completion:
    case FGraph{book, error, done} FCompletion{graph, parsed}:
      f_prefix_seed_graph(graph, parsed, prefix, Bool.not(prior_ready) && List.is_empty(&2, KDef, book) && List.is_empty(&2, KTerm, done) && String.is_empty(error) && String.is_empty(ns))

# Module: src/load/prefix.bend:154
@unsafe
def dg_width(
  +s: String,
) -> U32:
  match s:
    case SNil{}: 0
    case SCon{c, rest}: U32.add(dg_units(c), dg_width(rest))

# Module: src/diagnostic/render.bend:57
@unsafe
def dg_line_at(
  +s: String,
  +offset: U32,
  +line: U32,
) -> U32:
  match s:
    case SNil{}: line
    case SCon{c, rest}:
      kc(U32, U32.is_lt(offset, dg_units(c)), u => line, u => dg_line_at(rest, U32.sub(offset, dg_units(c)), kc(U32, Char.is_eq(c, '\n'), u => U32.add(line, 1), u => line)))

# Module: src/diagnostic/render.bend:68
@unsafe
def dg_lpad(
  +s: String,
  +width: U32,
) -> String:
  dg_padding(kc(U32, U32.is_gt(width, dg_width(s)), u => U32.sub(width, dg_width(s)), u => 0)) ++ s

# Module: src/diagnostic/render.bend:88
@unsafe
def dg_marker_left(
  +source: String,
  +offset: U32,
  +left: String,
) -> String:
  match source:
    case SNil{}: left
    case SCon{c, rest}:
      kc(String, U32.is_eq(offset, 0), u => left, u => kc(String, U32.is_lt(offset, dg_units(c)), u => left ++ dg_padding(offset), u => dg_marker_left(rest, U32.sub(offset, dg_units(c)), kc(String, Char.is_eq(c, '\n'), u => "", u => left ++ kc(String, Char.is_eq(c, '\t'), u => "\t", u => dg_padding(dg_units(c)))))))

# Module: src/diagnostic/render.bend:115
@unsafe
def dg_marker(
  +text: String,
  +width: U32,
  +left: String,
  +length: U32,
) -> String:
  dg_padding(width) ++ " | " ++ left ++ dg_carets(norm_max(1, U32.min(length, kc(U32, U32.is_gt(dg_width(text), dg_width(left)), u => U32.sub(dg_width(text), dg_width(left)), u => 0))))

# Module: src/diagnostic/render.bend:130
@unsafe
def w7_br_558(w7_c: Bool, +term: KTerm, +error: String, +name: String) -> DDiagnostic:
  match w7_c:
    case True{}:
      DDiagnostic{dg_as_expr(kid(term, 0)), dg_as_expr(kid(term, 1)), U32.is_eq(qt(term), 1), ks(kid(term, 2)), nm(term), DNoSpan{}, nm(kid(term, 5)), ks(kid(term, 4))}
    case False{}:
      dg_no_report(name, error)

@unsafe
def diagnostic_locate(
  +diagnostic: DDiagnostic,
  +origins: List<&2, DOrigin>,
) -> DDiagnostic:
  match diagnostic:
    case DDiagnostic{expected, observed, has_observed, context, definition, span, note, trail}:
      DDiagnostic{expected, observed, has_observed, context, definition, kc(DSpan, dg_has_span(span), u => span, u => dg_origin_trail(origins, definition, trail)), note, trail}

# Module: src/diagnostic/produce.bend:90
@unsafe
def dg_quant_error(world, message, name, allowed, used):
  dg_bad_detail(world, message, dg_text(kp_quant(allowed) ++ name), dg_text(kc(String, U32.is_eq(used, 2), u => name ++ " (consumed more than once)", u => kp_quant(used) ++ name)))

# Module: src/diagnostic/produce.bend:179
@unsafe
def j_u32_node(t):
  kc(Maybe<&2,U32>, core_literal(t) && p88_string_eq(nm(t), "U32"), u => Some{kl_number(t)}, u => kc(Maybe<&2, U32>, p98_tag_eq(t, "Ctr") && p88_string_eq(nm(t), "U32"), u => j_word(j_strip(kid(t, 0)), 0, 0), u => None{}))

# Module: src/back/common/literals.bend:37
@unsafe
def j_escape_char(c):
  j_escape_char_on(c, Char.to_u32(c))

# Module: src/back/js/shared-text.bend:30
@unsafe
def j_layout_array_name(+name: String) -> Bool:
  w7_br_604(p88_string_eq(name, "Array.new") || p88_string_eq(name, "Array.set") || p88_string_eq(name, "Array.get") || p88_string_eq(name, "Array.get_unchecked") || p88_string_eq(name, "Array.swap") || p88_string_eq(name, "Array.size"), name)

# Module: src/back/js/validate.bend:266
@unsafe
def j_primitive_input(+name: String, +at: U32) -> String:
  w7_br_608(p88_string_eq(name, "U32.from_nat") || ((p88_string_eq(name, "U32.shln") || p88_string_eq(name, "U32.shrn")) && U32.is_eq(at, 1)), name)

# Module: src/back/js/primitive.bend:19
@unsafe
def w7_br_611(w7_c: Bool, +name: String) -> String:
  match w7_c:
    case True{}:
      "Bool"
    case False{}:
      w7_br_610(p88_string_eq(name, "U32.to_nat"), name)

@unsafe
def j_primitive_result(+name: String) -> String:
  w7_br_611(String.starts_with(name, "U32.is_") || String.starts_with(name, "F32.is_"), name)

# Module: src/back/js/primitive.bend:25
@unsafe
def w7_br_616(w7_c: Bool, +ty: KTerm, +left: U32) -> KTerm:
  match w7_c:
    case True{}:
      w7_br_614(U32.is_eq(left, 2), ty)
    case False{}:
      w7_br_615(U32.is_eq(left, 2), ty)

@unsafe
def j_callback_capture_u32(+t: KTerm) -> KTerm:
  +h = j_strip(t)
  +s = j_call_spine(h, Nil{})
  kc(KTerm, j_fusion_call(s, "U32.from_nat", 1), u => kid(s, 0), u =>
    kc(KTerm, p98_tag_eq(h, "App"),
      u => k_with_children(h, j_callback_capture_u32_terms(ks(h))), u => h))

# Module: src/back/js/region.bend:1172
@unsafe
def j_callback_capture_u32_terms(+ts: List<&2,KTerm>) -> List<&2,KTerm>:
  match ts:
    case Nil{}: Nil{}
    case Con{h, rest}: Con{j_callback_capture_u32(h), j_callback_capture_u32_terms(rest)}

# Module: src/back/js/region.bend:1239
@unsafe
def w5c2_clean_if(ok: Bool, +s: String) -> String:
  match ok:
    case True{}: s
    case False{}: w5c2_clean_slow(s)

@unsafe
def nt_replace_step(+s: String, +key: String, +value: String, +acc: String) -> String:
  match s:
    case SNil{}: acc
    case SCon{h, t}: acc ++ SCon{h, nt_replace(t, key, value)}

@unsafe
def nt_replace_go(s, key, value, acc):
  acc ++ nt_replace(s, key, value)

# Module: src/back/native/text.bend:97
@unsafe
def w7_br_629(w7_c: Bool, +name: String) -> String:
  match w7_c:
    case True{}:
      name
    case False{}:
      nc_ctor_encode(name)

@unsafe
def w7_br_630(w7_c: Bool, +name: String) -> String:
  match w7_c:
    case True{}:
      nc_ctor_decode(String.drop(name, String.length("$ctor.")), 0, 0, "", name)
    case False{}:
      name

@unsafe
def nc_ctor_decode(rest, acc, digits, out, original):
  match rest:
    case SNil{}:
      kc(String, U32.is_eq(digits, 0) && p88_string_eq(nc_ctor_encode(out), original), u => out, u => original)
    case SCon{h, tail}:
      nc_ctor_decode_step(h, tail, acc, digits, out, original)

# Module: src/back/native/identity.bend:82
@unsafe
def w7_br_631(w7_c: Bool, +rest: String, +acc: U32, +out: String, +original: String) -> String:
  match w7_c:
    case True{}:
      nc_ctor_decode(rest, 0, 0, out ++ Char.show(Char.from_u32(acc)), original)
    case False{}:
      original

@unsafe
def w7_br_632(w7_c: Bool, +h: Char, +rest: String, +acc: U32, +digits: U32, +out: String, +original: String) -> String:
  match w7_c:
    case True{}:
      nc_ctor_decode(rest, U32.add(U32.mul(acc, 10), U32.sub(Char.to_u32(h), 48)), U32.add(digits, 1), out, original)
    case False{}:
      original

@unsafe
def w7_br_633(w7_c: Bool, +h: Char, +rest: String, +acc: U32, +digits: U32, +out: String, +original: String) -> String:
  match w7_c:
    case True{}:
      w7_br_631(U32.is_gt(digits, 0) && U32.is_le(acc, 1114111) && Bool.not(U32.is_ge(acc, 55296) && U32.is_le(acc, 57343)), rest, acc, out, original)
    case False{}:
      w7_br_632(U32.is_ge(Char.to_u32(h), 48) && U32.is_le(Char.to_u32(h), 57) && U32.is_lt(digits, 7), h, rest, acc, digits, out, original)

@unsafe
def nc_ctor_decode_step(h, rest, acc, digits, out, original):
  w7_br_633(Char.is_eq(h, '_'), h, rest, acc, digits, out, original)

@unsafe
def nk_value(+value: KTerm, +env: List<&2, NC_Binding>) -> N_WordKind:
  w7_br_635(p98_tag_eq(value, "Var"), value, env)

# Module: src/back/native/layout.bend:26
@unsafe
def w5c2_ni_u32_2(+k: String) -> String:
  w5c2_str_pick(String.eq(k, "u32_inc"), "U32_BIN($0, +, 1)",
  w5c2_str_pick(String.eq(k, "u32_shl"), "U32_BIN($0, <<, 1)",
  w5c2_str_pick(String.eq(k, "u32_shr"), "U32_BIN($0, >>, 1)",
  w5c2_str_pick(String.eq(k, "u32_shln"), "($1 >= 32 ? 0 : U32_BIN($0, <<, $1))",
  w5c2_str_pick(String.eq(k, "u32_shrn"), "($1 >= 32 ? 0 : U32_BIN($0, >>, $1))",
  w5c2_str_pick(String.eq(k, "u32_div"), "((u32)($1) == 0 ? 0 : (u64)U32_QUO((u32)($0), (u32)($1)))",
  w5c2_str_pick(String.eq(k, "u32_mod"), "((u32)($1) == 0 ? $0 : U32_BIN($0, -, U32_QUO((u32)($0), (u32)($1)) * $1))",
    w5c2_ni_u32_3(k))))))))

@unsafe
def w5c2_ni_f32_2(+k: String) -> String:
  w5c2_str_pick(String.eq(k, "f32_sqrt"), "f32_rewrap((f32)sqrt(f32_unbox($0)))",
  w5c2_str_pick(String.eq(k, "f32_exp"), "f32_rewrap((f32)exp(f32_unbox($0)))",
  w5c2_str_pick(String.eq(k, "f32_log"), "f32_rewrap((f32)log(f32_unbox($0)))",
  w5c2_str_pick(String.eq(k, "f32_log2"), "f32_rewrap((f32)log2(f32_unbox($0)))",
  w5c2_str_pick(String.eq(k, "f32_log10"), "f32_rewrap((f32)log10(f32_unbox($0)))",
  w5c2_str_pick(String.eq(k, "f32_sin"), "f32_rewrap((f32)sin(f32_unbox($0)))",
  w5c2_str_pick(String.eq(k, "f32_cos"), "f32_rewrap((f32)cos(f32_unbox($0)))",
  w5c2_str_pick(String.eq(k, "f32_tan"), "f32_rewrap((f32)tan(f32_unbox($0)))",
  w5c2_str_pick(String.eq(k, "f32_asin"), "f32_rewrap((f32)asin(f32_unbox($0)))",
  w5c2_str_pick(String.eq(k, "f32_acos"), "f32_rewrap((f32)acos(f32_unbox($0)))",
  w5c2_str_pick(String.eq(k, "f32_atan"), "f32_rewrap((f32)atan(f32_unbox($0)))",
  w5c2_str_pick(String.eq(k, "f32_sinh"), "f32_rewrap((f32)sinh(f32_unbox($0)))",
  w5c2_str_pick(String.eq(k, "f32_cosh"), "f32_rewrap((f32)cosh(f32_unbox($0)))",
  w5c2_str_pick(String.eq(k, "f32_tanh"), "f32_rewrap((f32)tanh(f32_unbox($0)))",
    w5c2_ni_f32_3(k)))))))))))))))

@unsafe
def w5c2_ni_b(ok: Bool, +k: String) -> String:
  match ok:
    case True{}: w5c2_ni_bool(k)
    case False{}: ""

law nu_insert:
  for +s: NU_Set
  for +key: U32
  for +split: U32
  NU_Set

@unsafe
def w5c2_nu_ins_lr(go_l: Bool, +mask: U32, +left: NU_Set, +right: NU_Set, +key: U32, +split: U32) -> NU_Set:
  match go_l:
    case True{}: NU_Node{mask, nu_insert(left, key, split), right}
    case False{}: NU_Node{mask, left, nu_insert(right, key, split)}

@unsafe
def w5c2_nu_ins_lt(lt: Bool, +s: NU_Set, +mask: U32, +left: NU_Set, +right: NU_Set, +key: U32, +split: U32) -> NU_Set:
  match lt:
    case True{}: nu_join(s, key, split)
    case False{}: w5c2_nu_ins_lr(U32.is_eq(U32.and(key, mask), 0), mask, left, right, key, split)

@unsafe
def nu_insert(s, key, split):
  match s:
    case NU_Empty{}: NU_Leaf{key}
    case NU_Leaf{stored}: nu_join(s, key, split)
    case NU_Node{+mask, +left, +right}:
      w5c2_nu_ins_lt(U32.is_lt(split, mask), s, mask, left, right, key, split)

# Module: src/back/native/uses.bend:33
@unsafe
def w5c2_nu_add_if(z: Bool, +s: NU_Set, +key: U32, +split: U32) -> NU_Set:
  match z:
    case True{}: s
    case False{}: nu_insert(s, key, split)

@unsafe
def nct_cat(+left: NC_Text, right: NC_Text) -> NC_Text:
  nct_cat_left(left, right, nct_empty(left))

@unsafe
def nc_first_error(+a: NC_Code, +b: NC_Code) -> String:
  w7_br_648(p88_string_eq(nc_error(a), ""), a, b)

# Module: src/back/native/bridge.bend:72
@unsafe
def nc_prepend(code: String, x: NC_Code) -> NC_Code:
  match x:
    case NC_Code{body, segs, fresh, err, edges}: NC_Code{nct_cat(nct_leaf(code), body), segs, fresh, err, edges}

# Module: src/back/native/bridge.bend:313
@unsafe
def w5c2_clean_lower(s: String) -> String:
  match s:
    case SNil{}: ""
    case SCon{+h, t}:
      +c = Char.to_u32(h)
      SCon{w5c2_cl_ch_up(U32.is_ge(c, 65) && U32.is_le(c, 90), c, h), w5c2_clean_lower(t)}

@unsafe
def w7_br_667(w7_c: Bool, +k: String, +n: U32, +i: U32) -> KTerm:
  match w7_c:
    case True{}:
      kt("NOp", k, 0, 0, nc_prim_args(n, 0))
    case False{}:
      k_lam("", U32.add(4000000000, i), 1, [nc_prim_lambdas(k, n, U32.inc(i))], 0, 0, False{})

@unsafe
def nc_prim_lambdas(+k: String, +n: U32, +i: U32) -> KTerm:
  w7_br_667(U32.is_eq(i, n), k, n, i)

# Module: src/back/native/bridge.bend:545
@unsafe
def w7_br_674(w7_c: Bool, +t: KTerm) -> NC_Literal:
  match w7_c:
    case True{}:
      nc_word_literal(kid(t, 0), 0, 0)
    case False{}:
      nc_nat_literal(t, 0)

@unsafe
def nd_beta(+head: KTerm, args: List<&2, KTerm>) -> KTerm:
  match args:
    case Nil{}: head
    case Con{+arg, +rest}:
      nt_choose(KTerm, p98_tag_eq(head, "Lam"),
        u => nt_choose(KTerm, p98_tag_eq(arg, "Var"),
          u => nd_beta(nq_layout_subst(kid(head, 0), ix(head), arg), rest),
          u => nc_mklet(ix(head), arg, nd_beta(kid(head, 0), rest))),
        u => nd_reapply(head, Con{arg, rest}))

# Remaining matcher arguments are already evaluated. Fresh aliases let the
# ordinary sharing prelude retain a scrutinee also used by another argument or
# by a captured branch before matching consumes its own reference.

# Module: src/back/native/direct.bend:122
@unsafe
def nd_comb_linear(params: List<&2, NC_Binding>, +body: KTerm) -> Bool:
  match params:
    case Nil{}: True{}
    case Con{NC_Binding{+id, word, +kind}, +rest}:
      nt_choose(Bool, p88_string_eq(nc_word(id, rest), "NATIVE_UNBOUND_VARIABLE") && U32.is_eq(nd_comb_uses(body, id), 1), u => nd_comb_linear(rest, body), u => False{})

# Refuse even malformed raw-ID collisions before using the ordinary substitution
# helper. Syntax-only substitution leaves demand-preserving beta to lowering.

# Module: src/back/native/direct.bend:184
@unsafe
def w7_br_688(w7_c: Bool, +t: KTerm, +n: U32, +left: U32) -> KTerm:
  match w7_c:
    case True{}:
      t
    case False{}:
      k_lam("", nc_id(n), 1, [nd_comb_rename(nq_layout_subst(kid(t, 0), ix(t), var("", nc_id(n))), U32.inc(n), U32.sub(left, 1))], 0, 0, False{})

@unsafe
def nd_comb_rename(+t: KTerm, +n: U32, +left: U32) -> KTerm:
  w7_br_688(U32.is_eq(left, 0), t, n, left)

# Module: src/back/native/direct.bend:195
@unsafe
def nd_comb_fill(+body: KTerm, args: List<&2, KTerm>) -> KTerm:
  match args:
    case Nil{}: body
    case Con{+h, +rest}:
      nt_choose(KTerm, p98_tag_eq(h, "Lam"),
        u => nd_comb_fill(nq_layout_subst(kid(body, 0), ix(body), h), rest),
        u => nc_mklet(ix(body), h, nd_comb_fill(kid(body, 0), rest)))

# Module: src/back/native/direct.bend:204
@unsafe
def w4c_decode_kind(+bits: U32) -> N_WordKind:
  w7_br_691(U32.is_eq(bits, 1), bits)

@unsafe
def w4c_shape_kinds(+left: U32, +mask: U32, +i: U32) -> List<&2, N_WordKind>:
  nt_choose(List<&2, N_WordKind>, U32.is_eq(left, 0), u => Nil{},
    u => Con{w4c_decode_kind(U32.and(U32.shrn(mask, U32.to_nat(U32.mul(i, 2))), 3)),
             w4c_shape_kinds(U32.sub(left, 1), mask, U32.inc(i))})

@unsafe
def w4c_bundle_params_kinds(+left: U32, +n: U32, +mask: U32, +i: U32) -> List<&2, NC_Binding>:
  nt_choose(List<&2, NC_Binding>, U32.is_eq(left, 0), u => Nil{},
    u =>
      +id = nc_id(n)
      +k = w4c_decode_kind(U32.and(U32.shrn(mask, U32.to_nat(U32.mul(i, 2))), 3))
      Con{NC_Binding{id, "v_" ++ U32.show(id), k},
          w4c_bundle_params_kinds(U32.sub(left, 1), U32.inc(n), mask, U32.inc(i))})

# Module: src/back/native/flat.bend:125
@unsafe
def nq_layout_leaf(+field: KTerm, +owner: KTerm, +seen: List<&2, U32>) -> Bool:
  Bool.not(p98_tag_eq(field, "Absent") || p98_tag_eq(field, "Ref")) && Bool.not(nq_layout_dep(field, seen)) && Bool.not(p98_tag_eq(field, "ADT") && p88_string_eq(nm(field), nm(owner)))

# A small syntax-only head query. Constant-lambda beta covers nondependent
# Sigma families; dependent or unknown applications decline without evaluation.

# Module: src/back/native/product-layout.bend:53
@unsafe
def nq_layout_subst_small(+body: KTerm, +arg: KTerm) -> Bool:
  U32.is_le(U32.mul(nq_layout_size([body], 4097), nq_layout_size([arg], 4097)), 4096)

# Module: src/back/native/product-layout.bend:101
@unsafe
def nq_shape_words(shapes: List<&2, KTerm>) -> U32:
  match shapes:
    case Nil{}: 0
    case Con{h, rest}: U32.add(nq_width(h), nq_shape_words(rest))

# Module: src/back/native/product.bend:305
@unsafe
def nq_entry(shapes: List<&2, KTerm>, +i: U32, +n: U32) -> NQ_Entry:
  match shapes:
    case Nil{}: NQ_Entry{Nil{}, Nil{}, n}
    case Con{+shape, rest}:
      +params = nt_choose(List<&2, NC_Binding>, p98_tag_eq(shape, "NQShape"), u => nq_bundle_params(ix(shape), n), u => [nc_binding(nc_id(i))])
      +arg = nt_choose(KTerm, p98_tag_eq(shape, "NQShape"), u => kt("NQBundle", nm(shape), 0, 0, nd_entry_args(params)), u => var("", nc_id(i)))
      nq_entry_cons(params, arg, nq_entry(rest, U32.inc(i), U32.add(n, nt_choose(U32, p98_tag_eq(shape, "NQShape"), u => ix(shape), u => 0))))

# Module: src/back/native/product.bend:364
@unsafe
def nw_same_list(as: List<&2, KTerm>, bs: List<&2, KTerm>, +pairs: List<&2, KTerm>) -> Bool:
  match as, bs:
    case Nil{}, Nil{}: True{}
    case Con{a, ar}, Con{b, br}: nt_choose(Bool, nw_same(a, b, pairs), u => nw_same_list(ar, br, pairs), u => False{})
    case _, _: False{}

# Module: src/back/native/word-pattern.bend:36
@unsafe
def w7_br_717(w7_c: Bool, +a: KTerm, +b: KTerm, +pairs: List<&2, KTerm>) -> Bool:
  match w7_c:
    case True{}:
      nw_same(kid(a, 0), kid(b, 0), Con{kt("NWPair", "", ix(a), ix(b), Nil{}), pairs})
    case False{}:
      norm_exact_head(a, b) && nw_same_list(ks(a), ks(b), pairs)

@unsafe
def w7_br_718(w7_c: Bool, +a: KTerm, +b: KTerm, +pairs: List<&2, KTerm>) -> Bool:
  match w7_c:
    case True{}:
      nw_var_same(ix(a), ix(b), pairs) && List.is_empty(&2, KTerm, ks(a)) && List.is_empty(&2, KTerm, ks(b))
    case False{}:
      w7_br_717(p98_tag_eq(a, "Lam") && U32.is_eq(terms_len(ks(a)), 1) && U32.is_eq(terms_len(ks(b)), 1), a, b, pairs)

@unsafe
def w7_br_719(w7_c: Bool, +a: KTerm, +b: KTerm, +pairs: List<&2, KTerm>) -> Bool:
  match w7_c:
    case True{}:
      w7_br_718(p98_tag_eq(a, "Var"), a, b, pairs)
    case False{}:
      False{}

@unsafe
def nw_same(a, b, pairs):
  w7_br_719(p98_tag_eq(a, tg(b)) && U32.is_eq(qt(a), qt(b)), a, b, pairs)

# Module: src/back/native/word-pattern.bend:45
@unsafe
def w7_br_731(w7_c: Bool, +mat: KTerm) -> Bool:
  match w7_c:
    case True{}:
      w7_br_730(p88_string_eq(nm(mat), "U32") || p88_string_eq(nm(mat), "F32"), mat)
    case False{}:
      False{}

@unsafe
def nc_atomic(k):
  match k:
    case SNil{}: 0
    case SCon{h, _}: w5c2_nc_atomic_go(U32.is_eq(Char.to_u32(h), 97), k)

# Module: src/back/native/array.bend:26
@unsafe
def nc_refs_go(todo: List<&2, KTerm>, +acc: List<&2, String>) -> List<&2, String>:
  match todo:
    case Nil{}: nt_reverse(String, acc, Nil{})
    case Con{+h, +rest}:
      nc_refs_go(nt_append(KTerm, ks(h), rest), nt_choose(List<&2, String>, p98_tag_eq(h, "Ref"), u => Con{nm(h), acc}, u => acc))

# Module: src/back/native/book.bend:49
@unsafe
def nc_refs(t):
  nc_refs_go([t], Nil{})

# Module: src/back/native/book.bend:53
@unsafe
def ns_image_terms(ws: List<&2, String>) -> List<&2, KTerm>:
  ns_image_terms_rev(ws, Nil{})

@unsafe
def w7_br_741(w7_c: Bool, +t: KTerm) -> Bool:
  match w7_c:
    case True{}:
      True{}
    case False{}:
      w7_br_740(p98_tag_eq(t, "NWord"), t)

@unsafe
def w7_br_747(w7_c: Bool, +n: U32) -> NC_Code:
  match w7_c:
    case True{}:
      NC_Code{nct_leaf("err_post(e.mem, ERR_FIDS); return 0;\n"), Nil{}, n, "", Nil{}}
    case False{}:
      nc_fail("observer: unsupported residual syntax", n)

@unsafe
def no_wrapper_once(+wrapper: KTerm, env: List<&2, NC_Binding>) -> Bool:
  match env:
    case Nil{}: True{}
    case Con{NC_Binding{id, word, kind}, rest}: U32.is_le(nq_uses(wrapper, id), 1) && no_wrapper_once(wrapper, rest)

# Module: src/back/native/observer-adapter.bend:48
@unsafe
def noa_origin(+value: KTerm) -> KTerm:
  w7_br_764(p98_tag_eq(value, "OA"), value)

# Module: src/back/native/observer-analysis.bend:107
@unsafe
def noa_value_type(+ctx: NO_Context, +v: KTerm) -> String:
  w7_br_766(p98_tag_eq(v, "OA"), ctx, v)

# Module: src/back/native/observer-analysis.bend:222
@unsafe
def noa_match_join(key: String, word: KTerm, fields: List<&2, KTerm>, yes: NO_Analysis, +no: NO_Analysis) -> NO_Analysis:
  NO_Analysis{kt("NO_Match", key, 0, 0, [word, kt("NO_Fields", "", 0, 0, noa_value_words(fields)), noa_body(yes), noa_body(no)]), noa_fresh(no), noa_fuel(no), noa_error(no)}

# Module: src/back/native/observer-analysis.bend:352
@unsafe
def w7_br_774(w7_c: Bool, +a: KTerm, +b: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      kt("OResult", "", 0, 0, nt_append(KTerm, ks(a), ks(b)))
    case False{}:
      {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}

@unsafe
def noa_finish_merge(+a: KTerm, +b: KTerm) -> KTerm:
  w7_br_774(p98_tag_eq(a, "OResult") && p98_tag_eq(b, "OResult"), a, b)

# Module: src/back/native/observer-analysis.bend:388
@unsafe
def noa_virtual_fields(ts: List<&2, KTerm>, +env: List<&2, KTerm>) -> List<&2, KTerm>:
  match ts:
    case Nil{}: Nil{}
    case Con{+h, +rest}: Con{noa_virtual(h, env), noa_virtual_fields(rest, env)}

# Module: src/back/native/observer-analysis.bend:442
@unsafe
def w7_br_782(w7_c: Bool, +t: KTerm, +env: List<&2, KTerm>) -> KTerm:
  match w7_c:
    case True{}:
      noa_env(ix(t), env)
    case False{}:
      kt("OC", nm(t), 0, 0, noa_virtual_fields(ks(t), env))

@unsafe
def noa_virtual(t, env):
  w7_br_782(p98_tag_eq(t, "Var"), t, env)

# Module: src/back/native/observer-analysis.bend:446
@unsafe
def dr_verdict(names):
  match names:
    case Nil{}: "ALL PROOFS CHECK\nUse --verdict for mathematical validity.\n"
    case Con{+name, +rest}:
      "SOME PROOFS FAIL\nError: " ++ U32.show(dr_count(names)) ++
      kc(String, U32.is_eq(dr_count(names), 1), u => " def relies", u => " defs rely") ++
      " on unsafe or foreign code:\n" ++ dr_lines(names)

# Module: src/driver/report.bend:73
@unsafe
def p88_u32(cursor: P88Cursor) -> P88Number:
  match cursor:
    case P88Cursor{text,1}: p88_digits(text,0,0)
    case P88Cursor{text,2}: p130m_word(text)
    case other: P88Number{P88Cursor{"",0},0}

@unsafe
def p88_text_size(read: P88Number) -> P88TextRead:
  match read:
    case P88Number{P88Cursor{text,+mode},+size}:
      p88_text_gate(text,size,mode,p130m_valid(mode) && U32.is_le(size,1048576))

@unsafe
def p88_number(state: P88State) -> P88Step:
  match state:
    case P88State{cursor, nodes, strings, made, sn, begin, end}:
      p88_number_read(nodes, strings, made, sn, begin, end, p88_u32(cursor))

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:106
@unsafe
def p88_roles(tag: U32) -> List<&2,U32>:
  p151_roles(tag)

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:131
@unsafe
def p88_node_at(state: P88State, +id: U32, role: U32) -> P88Step:
  match state:
    case P88State{cursor, nodes, strings, +made, sn, begin, end}:
      p88_node_gate(cursor, nodes, strings, made, sn, begin, end, id, role, U32.is_lt(id, made))

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:174
@unsafe
def p88_node_gate(cursor: P88Cursor, nodes: Array<P88Node>, strings: Array<String>, made: U32, sn: U32, begin: U32, end: U32, id: U32, role: U32, ok: Bool) -> P88Step:
  match ok:
    case False{}: P88Step{P88State{P88Cursor{"",0},nodes,strings,made,sn,begin,end},P88Bad{}}
    case True{}: p88_node_got(cursor,strings,made,sn,begin,end,role,Array.get(P88Node,nodes,id))

@unsafe
def p88_string_at(state: P88State, +id: U32) -> P88Step:
  match state:
    case P88State{cursor, nodes, strings, made, +sn, begin, end}:
      p88_string_gate(cursor, nodes, strings, made, sn, begin, end, id, U32.is_lt(id, sn))

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:191
@unsafe
def p86_width(text: String, count: U32) -> U32:
  match text:
    case SNil{}: count
    case SCon{char, rest}: p86_width(rest, U32.add(count, dg_units(char)))

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:420
@unsafe
def w7_br_792(w7_c: Bool, +t: KTerm, +kind: String) -> Bool:
  match w7_c:
    case True{}:
      p98_tag_eq(t,"ADT") && agy_str_eq(nm(t),"List") && U32.is_eq(terms_len(ks(t)),2) && p98_tag_eq(kid(t,0),"Qua") && U32.is_eq(qt(kid(t,0)),2) && p198e_owner(kid(t,1),"String")
    case False{}:
      p198e_owner(t,kind)

@unsafe
def p205_ty(+t: KTerm, +kind: String) -> Bool:
  w7_br_792(agy_str_eq(kind,"Strings"), t, kind)

@unsafe
def p205z_build(+base: U32, +rep: KTerm, +join: KTerm, +split: KTerm) -> KTerm:
  +countId = U32.add(base,1)
  +blockId = U32.add(base,2)
  +predId = U32.add(base,3)
  +sigId = U32.add(base,4)
  countArg = kt("Ann","",0,0,[kid(rep,0),ref("Nat")])
  blockArg = kt("Ann","",0,0,[kid(rep,1),ref("String")])
  mapped = p205_pair(nm(join),kid(join,0),p205_pair(nm(split),kid(split,0),var("$block",blockId)))
  positive = p205_pair(nm(rep),kt("Ctr","Succ",0,0,[var("$pred",predId)]),mapped)
  onSucc = kt("Lam","$pred",predId,1,[positive])
  cases = kt("Mat","Zero",0,0,[kt("Ctr","SNil",0,0,[]),kt("Mat","Succ",0,0,[onSucc,atom("Efq")])])
  signature = all(1,"$count",sigId,ref("Nat"),ref("String"))
  dispatch = app(kt("Ann","",0,0,[cases,signature]),var("$count",countId))
  kt("Let","",0,0,[kt("Bind","$count",countId,1,[countArg]),kt("Bind","$block",blockId,1,[blockArg]),dispatch])

@unsafe
def p205u_call(+t: KTerm, +owner: String) -> KTerm:
  +call = j_call_spine(t,[])
  kc(KTerm,p98_tag_eq(call,"Call") && agy_str_eq(nm(call),owner),u => call,u => p205u_call_fields(ks(t),owner))
@unsafe
def p205u_call_fields( +xs: List<&2,KTerm>, +owner: String) -> KTerm:
  match xs:
    case Nil{}: atom("Absent")
    case Con{x,rest}:
      +found = p205u_call(x,owner)
      kc(KTerm,p98_tag_eq(found,"Absent"),u => p205u_call_fields(rest,owner),u => found)
@unsafe
def p205u_children(+t: KTerm) -> List<&2,KTerm>:
  w5c3_p205u_ch_ann(p98_tag_eq(t,"Ann"), t)
@unsafe
def w7_br_823(w7_c: Bool, +t: KTerm) -> Bool:
  match w7_c:
    case True{}:
      p205_returns_string(kid(t,1))
    case False{}:
      p198e_owner(t,"String")

@unsafe
def p205_returns_string(+t: KTerm) -> Bool:
  w7_br_823(p98_tag_eq(t,"All"), t)

@unsafe
def ctfe_prim_arity(+name: String) -> U32:
  w7_br_827(agy_str_eq(name, "u32_add") || agy_str_eq(name, "u32_sub") || agy_str_eq(name, "u32_mul") || agy_str_eq(name, "u32_div") || agy_str_eq(name, "u32_mod") || agy_str_eq(name, "u32_and") || agy_str_eq(name, "u32_or") || agy_str_eq(name, "u32_xor") || agy_str_eq(name, "u32_shln") || agy_str_eq(name, "u32_shrn") || agy_str_eq(name, "u32_is_eq") || agy_str_eq(name, "u32_is_ne") || agy_str_eq(name, "u32_is_lt") || agy_str_eq(name, "u32_is_le") || agy_str_eq(name, "u32_is_gt") || agy_str_eq(name, "u32_is_ge") || agy_str_eq(name, "u32_cmp") || agy_str_eq(name, "nat_add") || agy_str_eq(name, "nat_sub") || agy_str_eq(name, "nat_mul") || agy_str_eq(name, "nat_div") || agy_str_eq(name, "nat_mod") || agy_str_eq(name, "nat_is_eq") || agy_str_eq(name, "nat_is_lt") || agy_str_eq(name, "nat_is_le") || agy_str_eq(name, "nat_cmp") || agy_str_eq(name, "f32_add") || agy_str_eq(name, "f32_sub") || agy_str_eq(name, "f32_mul") || agy_str_eq(name, "f32_div") || agy_str_eq(name, "f32_is_eq") || agy_str_eq(name, "f32_is_ne") || agy_str_eq(name, "f32_is_lt") || agy_str_eq(name, "f32_is_le") || agy_str_eq(name, "f32_is_gt") || agy_str_eq(name, "f32_is_ge"), name)

@unsafe
def w7_br_831(w7_c: Bool, +op: String, +a: U32, +b: U32) -> CtfeVal:
  match w7_c:
    case True{}:
      ctfe_bool(U32.is_ge(a, b))
    case False{}:
      w7_br_830(agy_str_eq(op, "u32_cmp"), a, b)

@unsafe
def w7_br_832(w7_c: Bool, +op: String, +a: U32, +b: U32) -> CtfeVal:
  match w7_c:
    case True{}:
      ctfe_bool(U32.is_gt(a, b))
    case False{}:
      w7_br_831(agy_str_eq(op, "u32_is_ge"), op, a, b)

@unsafe
def w7_br_850(w7_c: Bool, +op: String, +a: U32, +b: U32) -> CtfeVal:
  match w7_c:
    case True{}:
      ctfe_bool(U32.is_le(a, b))
    case False{}:
      w7_br_849(agy_str_eq(op, "nat_cmp"), a, b)

@unsafe
def w7_br_851(w7_c: Bool, +op: String, +a: U32, +b: U32) -> CtfeVal:
  match w7_c:
    case True{}:
      ctfe_bool(U32.is_lt(a, b))
    case False{}:
      w7_br_850(agy_str_eq(op, "nat_is_le"), op, a, b)

@unsafe
def w7_br_859(w7_c: Bool, +op: String, +a: F32, +b: F32) -> CtfeVal:
  match w7_c:
    case True{}:
      ctfe_bool(F32.is_gt(a, b))
    case False{}:
      w7_br_858(agy_str_eq(op, "f32_is_ge"), a, b)

@unsafe
def ctfe_run_prim1(+op: String, +a: CtfeVal) -> CtfeVal:
  match a:
    case CVU32{x}:
      kc(CtfeVal, agy_str_eq(op, "u32_inc"), u => CVU32{U32.inc(x)}, u =>
      kc(CtfeVal, agy_str_eq(op, "u32_dec"), u => CVU32{U32.sub(x, 1)}, u =>
      kc(CtfeVal, agy_str_eq(op, "u32_is_zero"), u => ctfe_bool(U32.is_eq(x, 0)), u =>
      kc(CtfeVal, agy_str_eq(op, "u32_to_nat"), u => CVNat{x}, u =>
      kc(CtfeVal, agy_str_eq(op, "u32_to_f32"), u => CVF32{U32.to_f32(x)}, u => CVFail{})))))
    case CVF32{x}:
      kc(CtfeVal, agy_str_eq(op, "f32_to_u32"), u => CVU32{F32.to_u32(x)}, u =>
      kc(CtfeVal, agy_str_eq(op, "f32_neg"), u => CVF32{F32.neg(x)}, u =>
      kc(CtfeVal, agy_str_eq(op, "f32_abs"), u => CVF32{F32.abs(x)}, u =>
      kc(CtfeVal, agy_str_eq(op, "f32_bits"), u => CVU32{F32.bits(x)}, u => CVFail{}))))
    case _:
      kc(CtfeVal, agy_str_eq(op, "u32_from_nat"), u => ctfe_nat_to_u32(ctfe_as_nat(a, 0)), u => CVFail{})

@unsafe
def ctfe_pack_ctr_one(+cname: String, +vs: List<&2, CtfeVal>) -> CtfeVal:
  match vs:
    case Con{w, Nil{}}: ctfe_pack_word(cname, vs, ctfe_bits_to_u32(w, 0, 0))
    case _: CVCtr{cname, vs}

@unsafe
def w7_br_871(w7_c: Bool, +cname: String, +vs: List<&2, CtfeVal>) -> CtfeVal:
  match w7_c:
    case True{}:
      ctfe_pack_ctr_one(cname, vs)
    case False{}:
      CVCtr{cname, vs}

@unsafe
def w7_br_874(w7_c: Bool, +v: CtfeVal) -> KTerm:
  match w7_c:
    case True{}:
      ctfe_reify_str(ctfe_str_val(v, 256))
    case False{}:
      atom("Absent")

@unsafe
def ctfe_ground_owner(+ty: KTerm) -> String:
  +t = j_strip(ty)
  kc(String, ctfe_is_owner(t, "U32"), u => "U32", u =>
  kc(String, ctfe_is_owner(t, "Nat"), u => "Nat", u =>
  kc(String, ctfe_is_owner(t, "F32"), u => "F32", u =>
  kc(String, ctfe_is_owner(t, "Bool"), u => "Bool", u =>
  kc(String, ctfe_is_owner(t, "Char"), u => "Char", u =>
  kc(String, ctfe_is_owner(t, "String"), u => "String", u => ""))))))

@unsafe
def agy_abs_check_call_args(+args: List<&2,KTerm>, +r_lams: List<&2,KTerm>, +st_idx: U32, +cur: U32) -> KTerm:
  match args r_lams:
    case Nil{} Nil{}: atom("Absent")
    case Con{+a,+ar} Con{+l,+lr}:
      kc(KTerm,U32.is_eq(cur,st_idx),
        u => kc(KTerm,agy_abs_check_rest_inv(ar,lr),v => a,v => atom("Absent")),
        u => kc(KTerm,agy_abs_is_var(a,ix(l)),
          v => agy_abs_check_call_args(ar,lr,st_idx,U32.inc(cur)),
          v => atom("Absent")))
    case _ _: atom("Absent")

@unsafe
def agy_abs_rec_call(+fname: String, +p_lam: KTerm, +r_lams: List<&2,KTerm>, +st_idx: U32, +next_st: KTerm) -> KTerm:
  agy_abs_apps(ref(fname),Con{var(nm(p_lam),ix(p_lam)),agy_abs_build_args(r_lams,st_idx,0,next_st)})

@unsafe
def agy_abs_build_sbr_app(+p_lam: KTerm, +r_lams: List<&2,KTerm>, +st_idx: U32, +m2: KTerm) -> KTerm:
  +st_lam = p205u_at(r_lams,st_idx)
  agy_abs_lam(nm(p_lam),ix(p_lam),qt(p_lam),agy_abs_wrap_lams(r_lams,app(m2,var(nm(st_lam),ix(st_lam)))))

@unsafe
def agy_bf_type_rest(+t: KTerm, +count: U32) -> U32:
  +ty = j_strip(t)
  kc(U32,p98_tag_eq(ty,"All") && U32.is_lt(count,18),
    u => kc(U32,U32.is_eq(qt(ty),2),
      v => agy_bf_type_rest(kid(ty,1),U32.inc(count)),
      v => 0),
    u => kc(U32,p198e_owner(ty,"U32"),v => count,v => 0))

@unsafe
def agy_bf_type_second(+t: KTerm) -> U32:
  +t1 = j_strip(t)
  kc(U32,p98_tag_eq(t1,"All") && U32.is_eq(qt(t1),2) && p198e_owner(kid(t1,0),"U32"),
    u => agy_bf_type_rest(kid(t1,1),2),
    u => 0)

@unsafe
def agy_bf_is_shln(+t: KTerm, +pid: U32) -> AgyStep:
  +c = j_call_spine(t,[])
  kc(AgyStep,p98_tag_eq(c,"Call") && agy_str_eq(nm(c),"U32.shln") && U32.is_eq(terms_len(ks(c)),2),
    u => agy_bf_is_shln_args(kid(c,0),kid(c,1),pid),
    u => AgyStep{0,False{}})

@unsafe
def agy_bf_check_add(+t: KTerm, +aid: U32, +bid: U32) -> Bool:
  +c = j_call_spine(t,[])
  p98_tag_eq(c,"Call") && agy_str_eq(nm(c),"U32.add") && U32.is_eq(terms_len(ks(c)),2) &&
    ((agy_bf_is_var(kid(c,0),aid) && agy_bf_is_var(kid(c,1),bid)) ||
     (agy_bf_is_var(kid(c,0),bid) && agy_bf_is_var(kid(c,1),aid)))

@unsafe
def agy_bf_check_left(+call: KTerm, +fname: String, +lams1: List<&2,KTerm>) -> Bool:
  +c = j_call_spine(call,[])
  p98_tag_eq(c,"Call") && agy_str_eq(nm(c),fname) && agy_bf_vars_match(ks(c),lams1)

@unsafe
def agy_bf_build_loop(+hname: String, +orig_ty: KTerm, +arity: U32, +lams0: List<&2,KTerm>, +base_expr: KTerm, +step: U32, +bid: U32) -> KDef:
  +zvars = agy_bf_fresh_lams(arity,U32.add(bid,1),0)
  +acc_z = p205u_at(zvars,1)
  +zero_case = agy_bf_wrap_vars(zvars,acc_z)
  +qid = U32.add(bid,30)
  +acc_id = U32.add(bid,31)
  +x0 = p205u_at(lams0,0)
  +tail_lams0 = List.tail(&2,KTerm,lams0)
  +x_next = app(app(ref("U32.add"),var(nm(x0),ix(x0))),agy_bf_u32(step))
  +acc_next = app(app(ref("U32.add"),var("agy_acc",acc_id)),base_expr)
  +rec_call = agy_bf_apps(ref(hname),Con{var("agy_q",qid),Con{x_next,Con{acc_next,agy_bf_lams_to_vars(tail_lams0)}}})
  +succ_inner = agy_bf_lam(nm(x0),ix(x0),2,agy_bf_lam("agy_acc",acc_id,2,agy_bf_wrap_lams(tail_lams0,rec_call)))
  +succ_case = agy_bf_lam("agy_q",qid,2,succ_inner)
  +body = kt("Mat","Zero",0,0,[zero_case,kt("Mat","Succ",0,0,[succ_case,atom("Efq")])])
  KDef{hname,"Def",U32.inc(arity),0,agy_bf_loop_type(orig_ty,bid),body,[],False{},False{}}

@unsafe
def agy_bf_build_disp_helper(+dname: String, +orig_ty: KTerm, +hname: String, +oname: String, +arity: U32, +bid: U32) -> KDef:
  +zvs = agy_bf_fresh_lams(arity,U32.add(bid,60),0)
  +zvd = p205u_at(zvs,0)
  +zvx = p205u_at(zvs,1)
  +zvrest = List.tail(&2,KTerm,List.tail(&2,KTerm,zvs))
  +rem = app(ref("U32.to_nat"),app(app(ref("U32.shln"),agy_bf_u32(1)),zvd))
  +fast = agy_bf_apps(ref(hname),Con{rem,Con{zvx,Con{agy_bf_u32(0),zvrest}}})
  +zero_case = agy_bf_wrap_vars(zvs,fast)
  +svs = agy_bf_fresh_lams(arity,U32.add(bid,90),0)
  +slow = agy_bf_apps(ref(oname),svs)
  +succ_case = agy_bf_lam("$agy_u",U32.add(bid,89),1,agy_bf_wrap_vars(svs,slow))
  +body = kt("Mat","Zero",0,0,[zero_case,kt("Mat","Succ",0,0,[succ_case,atom("Efq")])])
  KDef{dname,"Def",U32.inc(arity),0,agy_bf_disp_type(orig_ty,U32.add(bid,59)),body,[],False{},False{}}

@unsafe
def w5c3_ar_and(m: Bool, +op: String, +a: U32, +b: U32) -> KTerm:
  match m:
    case True{}: KLiteral{"U32",U32.and(a,b),"",0,0}
    case False{}: w5c3_ar_or(String.eq(op,"u32_or"), a, b)

@unsafe
def w5c2_rcmp_ne(m: Bool, +la: U32, +ha: U32, +lb: U32, +hb: U32) -> KTerm:
  match m:
    case True{}: w5c2_rcmp_b(U32.is_lt(ha,lb) || U32.is_gt(la,hb), True{})
    case False{}: atom("Absent")

@unsafe
def w5c3_bval_ctr(ok: Bool, +s: KTerm) -> U32:
  match ok:
    case False{}: 0
    case True{}:
      +n = nm(s)
      w5c3_bval_true(String.eq(n,"True"), n)

@unsafe
def p205v_bool_val(+t: KTerm) -> U32:
  +s = j_strip(t)
  w5c3_bval_ctr(p98_tag_eq(s,"Ctr") && List.is_empty(&2,KTerm,ks(s)), s)

@unsafe
def p205v_typed(+result: P205UResult, +ty: KTerm) -> P205UResult:
  match result:
    case P205UResult{term,next,steps,ok}:
      +need = p98_tag_eq(term,"Let") || (p98_tag_eq(term,"App") && p98_tag_eq(j_strip(kid(term,0)),"Mat"))
      P205UResult{kc(KTerm,need,u => p205u_typed_arg(term,ty),u => term),next,steps,ok}
@unsafe
def w7_br_916(w7_c: Bool, +t: KTerm, +call: KTerm) -> W2StepExtract:
  match w7_c:
    case True{}:
      W2StepExtract{p205u_at(ks(call),1),True{}}
    case False{}:
      W2StepExtract{t,False{}}

@unsafe
def w2d_check_builder_ty(+t: KTerm, +rem: U32) -> Bool:
  +s = j_strip(t)
  kc(Bool,U32.is_eq(rem,0),u => p198e_owner(s,"String"),u =>
  kc(Bool,U32.is_eq(rem,1),v => p98_tag_eq(s,"All") && p198e_owner(kid(s,0),"String") && p198e_owner(kid(s,1),"String"),v =>
    p98_tag_eq(s,"All") && w2d_check_builder_ty(kid(s,1),U32.sub(rem,1))))

@unsafe
def w2d_no_var_list(xs: List<&2,KTerm>, +id: U32) -> Bool:
  match xs:
    case Nil{}: True{}
    case Con{x,rest}: U32.is_eq(p205u_vars(x,id),0) && w2d_no_var_list(rest,id)

@unsafe
def w2d_no_ref_list(xs: List<&2,KTerm>, +name: String) -> Bool:
  match xs:
    case Nil{}: True{}
    case Con{x,rest}: U32.is_eq(p205u_refs(x,name),0) && w2d_no_ref_list(rest,name)

@unsafe
def w2d_check_rec_call(+pname: String, +ar: U32, +lams0: List<&2,KTerm>, +lams1: List<&2,KTerm>, +bs: List<&2,KTerm>, +ch_expr: KTerm, +rid: U32, +call: KTerm) -> W2Builder:
  w7_br_920(p98_tag_eq(call,"Call") && agy_str_eq(nm(call),pname) && U32.is_eq(terms_len(ks(call)),ar) && agy_bf_is_var(w2d_last(ks(call)),rid) && w2d_no_var_list(w2d_init(ks(call)),rid) && w2d_no_ref_list(ks(call),pname), pname, ar, lams0, lams1, bs, ch_expr, call)

@unsafe
def w2d_check_self_arm_ctr(+cname: String, +hid: U32, +rargs: List<&2,KTerm>, +m_expr: KTerm, +acc_id: U32) -> W2UnboxArm:
  w7_br_922(p98_tag_eq(m_expr,"Ctr") && agy_str_eq(nm(m_expr),cname) && U32.is_eq(terms_len(ks(m_expr)),1) && U32.is_eq(p205u_vars(kid(m_expr,0),acc_id),0), cname, hid, rargs, m_expr)

@unsafe
def w7_br_925(w7_c: Bool, +t: KTerm, +rargs: List<&2,KTerm>, +st: KTerm, +cname: String, +iname: String) -> KTerm:
  match w7_c:
    case True{}:
      kt("Ctr","Tuple",0,1,[ kt("Ctr",cname,0,1,[agy_bf_apps(ref(iname),nt_append(KTerm,rargs,[kid(j_strip(kid(st,0)),0)]))]), kid(st,1)])
    case False{}:
      t

@unsafe
def w2d_wrap_rec_in_step(+t: KTerm, +hname: String, +rargs: List<&2,KTerm>, +bs: List<&2,KTerm>) -> KTerm:
  +s = j_strip(t)
  kc(KTerm,p98_tag_eq(s,"Mat") && agy_str_eq(nm(s),"Tuple") && U32.is_eq(terms_len(ks(s)),2) &&
    p98_tag_eq(kid(s,0),"Lam") && p98_tag_eq(kid(kid(s,0),0),"Lam"),
    u => k_with_children(s,[
           k_with_children(kid(s,0),[
             k_with_children(kid(kid(s,0),0),[
               w2d_wrap_lets(bs,agy_bf_apps(ref(hname),nt_append(KTerm,rargs,[kid(kid(kid(s,0),0),0)])))])]),
           kid(s,1)]),
    u => kc(KTerm,p98_tag_eq(s,"Lam"),
           v => k_with_children(s,[w2d_wrap_lets(bs,agy_bf_apps(ref(hname),nt_append(KTerm,rargs,[kid(s,0)])))]),
           v => atom("Absent")))

@unsafe
def w2d_rebind_senv(+senv: List<&2,W2Bind>, +body: KTerm) -> KTerm:
  match senv:
    case Nil{}: body
    case Con{W2Bind{bid,rhs},rest}:
      kc(KTerm,U32.is_gt(p205u_vars(body,bid),0),
        u => kt("Let","",0,0,[kt("Bind","$w2r",bid,2,[rhs]),w2d_rebind_senv(rest,body)]),
        u => w2d_rebind_senv(rest,body))

@unsafe
def w7_br_931(w7_c: Bool, +call: KTerm) -> KTerm:
  match w7_c:
    case True{}:
      kid(j_strip(p205u_at(ks(call),3)),0)
    case False{}:
      atom("Absent")

@unsafe
def w2d_push_fallback(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +senv: List<&2,W2Bind>, +next: U32, +fold: W2Fold, +prod: KTerm, +st: KTerm) -> W2State:
  match fold:
    case W2Fold{fname,_,_,_,_}:
      W2State{ctx,added,next,w2d_rebind_senv(senv,app(app(ref(fname),prod),st)),True{}}

@unsafe
def w2d_walk_ann_res(+orig: KTerm, +r: W2State) -> W2State:
  match r:
    case W2State{ctx2,added2,next2,t2,ch2}:
      W2State{ctx2,added2,next2,w5c3_w2d_ann_out(ch2, orig, t2),ch2}

@unsafe
def p86_read_limit(file: File, size: U32, allowed: Bool) -> IO(String):
  match allowed:
    case True{}:
      do IO<String>:
        read : File & Result<&1,&1,U32 & String,String> <- File.read(file, size)
        p86_read_more(read)
    case False{}:
      do IO<String>:
        Unit <- File.close(file)
        IO.die(String, 1, "input exceeds 16 MiB")

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:737
@unsafe
def nbc_expand(+body: KTerm, args: List<&2, KTerm>) -> KTerm:
  match args:
    case Nil{}: body
    case Con{+arg, +rest}:
      nt_choose(KTerm, p98_tag_eq(body, "Lam"),
        u => nbc_expand(nq_layout_subst(kid(body, 0), ix(body), arg), rest),
        u => app(nbc_expand_match(body, rest), arg))

@unsafe
def nbc_expand_match(+body: KTerm, +args: List<&2, KTerm>) -> KTerm:
  nt_choose(KTerm, p98_tag_eq(body, "Efq"), u => body, u =>
    k_rebuild(body, nm(body), ix(body), qt(body), [nbc_expand(kid(body, 0), args), nbc_expand_match(kid(body, 1), args)], rm(body), kb(body), ke(body)))

@unsafe
def nbc_evaluate(+body: KTerm, args: List<&2, KTerm>, +acc: List<&2, KTerm>, +n: U32) -> KTerm:
  match args:
    case Nil{}: nbc_expand(body, nt_reverse(KTerm, acc, Nil{}))
    case Con{+arg, +rest}:
      nt_choose(KTerm, p98_tag_eq(arg, "Lam"),
        u => nbc_evaluate(body, rest, Con{arg, acc}, U32.inc(n)),
        u => nc_mklet(nc_id(n), arg, nbc_evaluate(body, rest, Con{var("", nc_id(n)), acc}, U32.inc(n))))

@unsafe
def ntr_params(+target: NC_Target) -> U32:
  match target:
    case NC_Scheduler{}: 0
    case NC_Destination{words, shape, join, owner, +params, tail, signatures}: nt_count(NC_Binding, params)

@unsafe
def p111_show_resolve_all(cells: List<&2, P111ShowCell>, +offsets: List<&2, U32>, +constructors: List<&2, N_Constructor>) -> P111ShowWords:
  match cells:
    case Nil{}: P111ShowWords{Nil{}, ""}
    case Con{head, rest}: p111_show_words_join(p111_show_resolve(head, offsets, constructors), p111_show_resolve_all(rest, offsets, constructors))

@unsafe
def w5c2_opid_u(+k: String) -> U32:
  w5c2_u32_pick(String.eq(k, "u32_add"), 1,
  w5c2_u32_pick(String.eq(k, "u32_sub"), 2,
  w5c2_u32_pick(String.eq(k, "u32_and"), 3,
  w5c2_u32_pick(String.eq(k, "u32_or"), 4,
  w5c2_u32_pick(String.eq(k, "u32_xor"), 5,
  w5c2_u32_pick(String.eq(k, "u32_mul"), 6,
  w5c2_u32_pick(String.eq(k, "u32_is_eq"), 7,
  w5c2_u32_pick(String.eq(k, "u32_is_ne"), 8,
  w5c2_u32_pick(String.eq(k, "u32_is_lt"), 9,
  w5c2_u32_pick(String.eq(k, "u32_is_le"), 10,
  w5c2_u32_pick(String.eq(k, "u32_is_gt"), 11,
  w5c2_u32_pick(String.eq(k, "u32_is_ge"), 12, w5c2_opid_u2(k)))))))))))))

@unsafe
def w5c2_opid_f2(+k: String) -> U32:
  w5c2_u32_pick(String.eq(k, "f32_sqrt"), 36,
  w5c2_u32_pick(String.eq(k, "f32_exp"), 37,
  w5c2_u32_pick(String.eq(k, "f32_log"), 38,
  w5c2_u32_pick(String.eq(k, "f32_log2"), 39,
  w5c2_u32_pick(String.eq(k, "f32_log10"), 40,
  w5c2_u32_pick(String.eq(k, "f32_sin"), 41,
  w5c2_u32_pick(String.eq(k, "f32_cos"), 42,
  w5c2_u32_pick(String.eq(k, "f32_tan"), 43,
  w5c2_u32_pick(String.eq(k, "f32_asin"), 44,
  w5c2_u32_pick(String.eq(k, "f32_acos"), 45,
  w5c2_u32_pick(String.eq(k, "f32_atan"), 46,
  w5c2_u32_pick(String.eq(k, "f32_sinh"), 47,
  w5c2_u32_pick(String.eq(k, "f32_cosh"), 48,
  w5c2_u32_pick(String.eq(k, "f32_tanh"), 49, w5c2_opid_f3(k)))))))))))))))

@unsafe
def w5c2_opid_da(ok: Bool, +c: U32, +k: String) -> U32:
  match ok:
    case True{}: w5c2_opid_a(k)
    case False{}: w5c2_opid_b(U32.is_eq(c, 98), k)

@unsafe
def p111_prepend(prefix: List<&2, N111Stmt>, code: P111Code) -> P111Code:
  match code:
    case P111Code{+body, +segments, +fresh, +error}: P111Code{nt_append(N111Stmt, prefix, body), segments, fresh, error}

@unsafe
def p111_jump(+name: String, +values: List<&2, N111Value>, +n: U32) -> P111Code:
  P111Code{nt_append(N111Stmt, p111_store(values, 0), [N111Call{"reply", N111U64{}, "p111_rt_jump", [p111_state(), N111Arg{N111U32{}, N111FuncId{name}}, p111_scratch(), p111_u32(nt_count(N111Value, values))]}, N111Return{N111Local{"reply"}}]), Nil{}, n, ""}

@unsafe
def w5c2_part_used(used: Bool, +id: U32, +word: String, +kind: N_WordKind, +live: List<&2, NC_Binding>, +drop: List<&2, N111Stmt>) -> P111Partition:
  match used:
    case True{}: P111Partition{Con{NC_Binding{id, word, kind}, live}, drop}
    case False{}: w5c2_part_nonown(p112to_nonowning(kind), word, live, drop)

@unsafe
def p111_partition_step(+id: U32, +word: String, +kind: N_WordKind, +used: Bool, parts: P111Partition) -> P111Partition:
  match parts:
    case P111Partition{+live, +drop}:
      w5c2_part_used(used, id, word, kind, live, drop)

@unsafe
def p111_segment(+name: String, +params: List<&2, NC_Binding>, +held: U32, +incoming: U32, +body: List<&2, N111Stmt>) -> N111Segment:
  +start = nt_choose(List<&2, N111Stmt>, U32.is_eq(held, 0), u => Nil{}, u => [N111Call{"ignored", N111U64{}, "p111_rt_stack_pop", [p111_state(), p111_u32(held)]}])
  N111Segment{name, nt_count(NC_Binding, params), 1, incoming, 0, Con{N111Alloca{"scratch", 2048, 8}, nt_append(N111Stmt, start, nt_append(N111Stmt, p111_params(params, held, 0, 0), body))}}

@unsafe
def p111_frame(+held: List<&2, NC_Binding>, +next: String) -> List<&2, N111Stmt>:
  nt_append(N111Stmt, p111_store(p111_env_words(held), 0), [N111Call{"ignored", N111U64{}, "p111_rt_frame", [p111_state(), N111Arg{N111U32{}, N111FuncId{next}}, p111_scratch(), p111_u32(nt_count(NC_Binding, held))]}])

@unsafe
def p111_value_return(value: P111ValueCode, +n: U32) -> P111Code:
  match value:
    case P111ValueCode{+body, +word, +error}:
      nt_choose(P111Code, agy_str_eq(error, ""), u => p111_prepend(body, p111_return(word, n)), u => p111_fail(error, n))


# Phase111 module: selfhost/tools/performance/phase111/segment/lower-value.bend
# Native special constructors and primitive calls remain ordered operations.
@unsafe
def p111_entry_join(+base: P111Code, +body: P111Code, +name: String, +params: List<&2, NC_Binding>) -> P111Code:
  P111Code{p111_body(base), nt_append(N111Segment, p111_segments(base), Con{p111_segment(nd_name(name), params, 0, 0, p111_body(body)), p111_segments(body)}), p111_fresh(body), p111_first(p111_error(base), p111_error(body))}

def p111v_type(typ: N111Type) -> U32:
  match typ:
    case N111U32{}: 1
    case N111U64{}: 2
    case N111Ptr{}: 3

@unsafe
def w5c3_sig15(m: Bool, +s: String) -> List<&2,U32>:
  match m:
    case True{}: [3,1,3,1]
    case False{}: w5c3_sig16(String.eq(s,"p111_rt_special_test"), s)

@unsafe
def w5c3_sig14(m: Bool, +s: String) -> List<&2,U32>:
  match m:
    case True{}: [3,1]
    case False{}: w5c3_sig15(String.eq(s,"p111_rt_op") || String.eq(s,"p111_rt_special_ctor"), s)

@unsafe
def w5c3_arg_step(z: Bool, +value: N111Value, rest: List<&2,N111Arg>, +index: U32) -> N111Value:
  match z:
    case True{}: value
    case False{}: p111v_arg(rest,U32.sub(index,1))

@unsafe
def p111v_arg(+args: List<&2,N111Arg>, +index: U32) -> N111Value:
  match args:
    case Nil{}: N111Symbol{"invalid"}
    case Con{N111Arg{typ,value},rest}: w5c3_arg_step(U32.is_eq(index,0), value, rest, index)

@unsafe
def p111v_special_arity(+kind: U32) -> U32:
  w5c3_spec_arity_if(U32.is_gt(kind,0) && U32.is_lt(kind,10), kind)

@unsafe
def p111q_u64(+lo: U32, +hi: U32) -> String:
  nt_choose(String,U32.is_eq(hi,0),u => U32.show(lo),u => p111q_decimal_go(lo,hi,""))


# Phase111 module: selfhost/tools/performance/phase111/qbe/data.bend
# Linkable QBE data: exact words, byte arrays and explicit symbol relocations.
# This model describes output layout; it never embeds C source or C expressions.
def p111q_symbol(name: String) -> String:
  "p111_" ++ nt_fid(name)


# Phase111 module: selfhost/tools/performance/phase111/qbe/program.bend
# Assemble separately emitted functions and ABI data. IDs use a Patricia index
# built once; emitting a reference never scans all previously emitted segments.

@unsafe
def p111q_segment_datum(name: String, arity: U32, incoming: U32, flags: U32, kind: U32) -> P111QDatum:
  match kind:
    case 0: P111QReloc{p111q_symbol(name),0}
    case 1: P111QByte{arity}
    case 2: P111QByte{flags}
    case _: P111QByte{incoming}

@unsafe
def p111q_ctor_names(constructors: List<&2,N_Constructor>) -> List<&2,String>:
  p111q_ctor_names_go(constructors,[])

@unsafe
def p111q_words(items: List<&2,U32>) -> List<&2,P111QDatum>:
  p111q_words_go(items,[])

# Strings are UTF-8 bytes with explicit trailing zero, independently of the
# host C source encoding, linker escaping, or JavaScript number representation.
@unsafe
def p111q_string_defs(names: List<&2,String>, +prefix: String, +index: U32, acc: List<&2,P111QData>) -> List<&2,P111QData>:
  match names:
    case Nil{}: nt_reverse(P111QData,acc,[])
    case Con{name,rest}:
      p111q_string_defs(rest,prefix,U32.inc(index),Con{P111QData{prefix ++ "_" ++ U32.show(index),1,False{},p111q_utf8(name,[])},acc})

@unsafe
def p111q_width(segments: List<&2,N111Segment>, +results_only: Bool, +acc: U32) -> U32:
  match segments:
    case Nil{}: acc
    case Con{N111Segment{name,arity,result,incoming,flags,body},rest}:
      p111q_width(rest,results_only,nb_max(acc,nt_choose(U32,results_only,u => result,u => nb_max(arity,result))))

@unsafe
def p112_scalar_binary(op: String, a: N111Value, b: N111Value) -> P111ValueCode:
  p112_scalar_result(p112_scalar_operands(a, b,
    [N111Bin{"value", N111U64{}, op, N111Local{"p112_s_a"}, N111Local{"p112_s_b"}},
     N111Bin{"value", N111U64{}, "and", N111Local{"value"}, p112_scalar_mask()}]))


@unsafe
def p112_scalar_compare(op: String, a: N111Value, b: N111Value) -> P111ValueCode:
  p112_scalar_result(p112_scalar_operands(a, b,
    [N111Bin{"p112_s_test", N111U64{}, op, N111Local{"p112_s_a"}, N111Local{"p112_s_b"}},
     N111If{N111Local{"p112_s_test"},
       [N111Set{"value", N111U64{}, N111Const{1, 0}}],
       [N111Set{"value", N111U64{}, N111Const{0, 0}}]}]))

# The shift count is a full Nat word. Inspect it before narrowing; in particular
# 2^32 must produce zero, not behave like a zero shift. Both branches avoid a
# machine shift by an out-of-range count.


@unsafe
def p112_scalar_dispatch(+id: U32, +values: List<&2, N111Value>) -> P111ValueCode:
  +a = p111_head(values)
  +b = p111_head(p111_tail(values))
  nt_choose(P111ValueCode, U32.is_le(id, 6), u => p112_scalar_binary(p112_scalar_op(id), a, b), u =>
  nt_choose(P111ValueCode, U32.is_le(id, 12), u => p112_scalar_compare(p112_scalar_op(id), a, b), u =>
  nt_choose(P111ValueCode, U32.is_eq(id, 13), u => p112_scalar_binary("add", a, N111Const{1, 0}), u =>
  nt_choose(P111ValueCode, U32.is_eq(id, 14), u => p112_scalar_binary("shl", a, N111Const{1, 0}), u =>
  nt_choose(P111ValueCode, U32.is_eq(id, 15), u => p112_scalar_binary("shr", a, N111Const{1, 0}), u =>
  nt_choose(P111ValueCode, U32.is_eq(id, 16), u => p112_scalar_shift("shl", a, b), u =>
  nt_choose(P111ValueCode, U32.is_eq(id, 17), u => p112_scalar_shift("shr", a, b), u =>
  nt_choose(P111ValueCode, U32.is_eq(id, 20), u => p112_scalar_binary("xor", a, p112_scalar_mask()),
    u => p112_scalar_compare("eq", a, N111Const{0, 0})))))))))


@unsafe
def p112t_prelude(body: List<&2,N111Stmt>, +arity: U32) -> P112TailPrelude:
  match body:
    case Con{N111Alloca{name,bytes,align},+rest}:
      nt_choose(P112TailPrelude,agy_str_eq(name,"scratch") && U32.is_eq(bytes,2048) && U32.is_eq(align,8),
        u => p112t_params(rest,arity,0,[],[N111Alloca{"scratch",2048,8}]),
        u => P112TailPrelude{False{},[],[],[]})
    case _: P112TailPrelude{False{},[],[],[]}


@unsafe
def p112t_tail(+body: List<&2,N111Stmt>, +owner: String, +arity: U32, +index: U32) -> Bool:
  nt_choose(Bool,U32.is_eq(index,arity),u => p112t_jump(body,owner,arity),
    u => p112t_tail_store(body,owner,arity,index))


@unsafe
def p112t_tail_store(body: List<&2,N111Stmt>, +owner: String, +arity: U32, +index: U32) -> Bool:
  match body:
    case Con{N111Store{N111U64{},N111Local{base},offset,value},rest}:
      agy_str_eq(base,"scratch") && U32.is_eq(offset,U32.mul(index,8)) &&
        p112t_tail(rest,owner,arity,U32.inc(index))
    case _: False{}

# The exact stores are retained. Again snapshots every slot before rebinding.


@unsafe
def p112t_scalar_safe(stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Set{name,N111Ptr{},value}: False{}
    case N111Set{name,typ,value}: True{}
    case N111Bin{name,N111Ptr{},op,left,right}: False{}
    case N111Bin{name,typ,op,left,right}: True{}
    case N111Call{name,N111U64{},symbol,args}: p112t_runtime_call(symbol) && p112t_runtime_args(args)
    case N111Load{name,N111U64{},N111Local{base},offset}: agy_str_eq(base,"scratch")
    case N111Store{N111U64{},N111Local{base},offset,value}: agy_str_eq(base,"scratch")
    case _: False{}

@unsafe
def p112_special_bool(+word: N111Value, invert: Bool) -> List<&2, N111Stmt>:
  nt_append(N111Stmt,
    [N111Bin{"p112_b_raw", N111U64{}, "eq", word, N111Const{1, 0}},
     N111Bin{"p112_b_bits", N111U64{}, "shr", word, N111Const{40, 0}},
     N111Bin{"p112_b_bits", N111U64{}, "and", N111Local{"p112_b_bits"}, N111Const{8388607, 0}},
     N111Bin{"p112_b_expected", N111U64{}, "or", N111CtorId{"True"}, N111Const{65536, 0}},
     N111Bin{"p112_b_boxed", N111U64{}, "eq", N111Local{"p112_b_bits"}, N111Local{"p112_b_expected"}},
     N111Bin{"match_condition", N111U32{}, "or", N111Local{"p112_b_raw"}, N111Local{"p112_b_boxed"}}],
    nt_choose(List<&2, N111Stmt>, invert,
      u => [N111Bin{"match_condition", N111U32{}, "xor", N111Local{"match_condition"}, N111Const{1, 0}}], u => []))


# Bool primitives share the special-pattern truth predicate, including packed
# True with arbitrary location/RFC bits. Snapshot both inputs before any helper
# writes; renaming keeps its U32 comparisons separate from the input U64 words.
# The reserved prefix refuses synthetic IR collisions through the old runtime.
@unsafe
def p112_special_selected(+kind: U32, +word: N111Value) -> List<&2, N111Stmt>:
  nt_choose(List<&2, N111Stmt>, U32.is_le(kind, 2), u => p112_special_bool(word, U32.is_eq(kind, 1)), u =>
  nt_choose(List<&2, N111Stmt>, U32.is_eq(kind, 3), u => [N111Bin{"match_condition", N111U64{}, "eq", word, N111Const{0, 0}}], u =>
  nt_choose(List<&2, N111Stmt>, U32.is_eq(kind, 4), u => [N111Bin{"match_condition", N111U64{}, "ne", word, N111Const{0, 0}}],
    u => [N111Bin{"match_condition", N111U64{}, "eq", word, word}])))


@unsafe
def p112w_symbol(name: String) -> String:
  "p112w_" ++ nt_fid(name)


@unsafe
def p112s_size(nodes: List<&2,P112SNode>, total: U32) -> U32:
  match nodes:
    case Nil{}: total
    case Con{P112SNode{offset,name,fields},rest}: p112s_size(rest,U32.add(total,nt_count(P112SWord,fields)))


@unsafe
def p112s_fields(terms: List<&2,KTerm>) -> List<&2,P112SWord>:
  match terms:
    case Nil{}: []
    case Con{head,rest}: Con{p112s_term_word(head),p112s_fields(rest)}


@unsafe
def p112s_fields_key(fields: List<&2,P112SWord>) -> String:
  match fields:
    case Nil{}: ""
    case Con{head,rest}: p112s_word_key(head) ++ p112s_fields_key(rest)


@unsafe
def p112s_patch_data(+data: P111QData, +size: U32) -> P111QData:
  match data:
    case P111QData{+name,alignment,exported,items}:
      nt_choose(P111QData,agy_str_eq(name,"p111_program"),
        u => P111QData{name,alignment,exported,p112s_descriptor_items(items,0,size,[])},u => data)


@unsafe
def p112s_patch_tables(tables: List<&2,P111QData>, +size: U32, acc: List<&2,P111QData>) -> List<&2,P111QData>:
  match tables:
    case Nil{}: nt_reverse(P111QData,acc,[])
    case Con{head,rest}: p112s_patch_tables(rest,size,Con{p112s_patch_data(head,size),acc})


law p112f_index_find:
  for tree: P112FusionIndex
  for +name: String
  for +hash: U32
  Maybe<&2,N111Segment>

@unsafe
def w7c_p112f_find_lr(bit: U32, left: P112FusionIndex, right: P112FusionIndex, +name: String, +hash: U32) -> Maybe<&2,N111Segment>:
  match bit:
    case 0: p112f_index_find(left,name,hash)
    case _: p112f_index_find(right,name,hash)

@unsafe
def p112f_index_find(tree, name, hash):
  match tree:
    case P112FusionEmpty{}: None{}
    case P112FusionLeaf{+stored,+bucket}:
      w7c_p112f_find_leaf(U32.is_eq(hash,stored),bucket,name)
    case P112FusionNode{+mask,+left,+right}:
      w7c_p112f_find_lr(U32.and(hash,mask),left,right,name,hash)


@unsafe
def w7c_p112f_ins_leaf(z: U32, +tree: P112FusionIndex, +bucket: List<&2,N111Segment>, +segment: N111Segment, +hash: U32, +split: U32) -> P112FusionIndex:
  match z:
    case 0: P112FusionLeaf{hash,p112f_index_bucket_add(bucket,segment)}
    case _: p112f_index_join(tree,segment,hash,split)

@unsafe
def p112f_clean_args(args: List<&2,N111Arg>) -> Bool:
  match args:
    case Nil{}: True{}
    case Con{N111Arg{+typ,+value},+rest}: p112f_clean_value(value) && p112f_clean_args(rest)


@unsafe
def p112f_transition(body: List<&2,N111Stmt>) -> Bool:
  match body:
    case Con{N111Call{+dest,N111U64{},+symbol,+args},Con{N111Return{N111Local{+word}},Nil{}}}:
      agy_str_eq(dest,word) && p112t_runtime_args(args) &&
        (agy_str_eq(symbol,"p111_rt_jump") || agy_str_eq(symbol,"p111_rt_return") || agy_str_eq(symbol,"p111_rt_apply") || agy_str_eq(symbol,"p111_rt_fail"))
    case _: False{}


@unsafe
def p112f_values(body: List<&2,N111Stmt>, left: U32) -> List<&2,N111Value>:
  match body left:
    case _ 0: []
    case Con{N111Store{+typ,+base,+offset,+value},+rest} _: Con{value,p112f_values(rest,U32.sub(left,1))}
    case _ _: []


@unsafe
def p112m_join(+row: KTerm, +base: U32, +yes: P111Code, +no: P111Code) -> P111Code:
  +masked = "p112m_mask_" ++ U32.show(base)
  +condition = "p112m_hit_" ++ U32.show(base)
  P111Code{[N111Bin{masked,N111U64{},"and",N111Local{"v_" ++ U32.show(nc_id(base))},N111Const{p112m_mask(ix(row)),0}},
    N111Bin{condition,N111U64{},"eq",N111Local{masked},N111Const{nw_value(row),0}},
    N111If{N111Local{condition},p111_body(yes),p111_body(no)}],
    nt_append(N111Segment,p111_segments(yes),p111_segments(no)),p111_fresh(no),p111_first(p111_error(yes),p111_error(no))}


@unsafe
def p112r_buffers(args: List<&2,N111Arg>, +sites: U32) -> Bool:
  match args:
    case Nil{}: True{}
    case Con{N111Arg{N111Ptr{},N111Local{+name}},+rest}: p112r_buffer(name,sites) && p112r_buffers(rest,sites)
    case Con{N111Arg{N111Ptr{},+value},+rest}: False{}
    case Con{+arg,+rest}: p112r_buffers(rest,sites)


@unsafe
def p112r_failure_frame(stmt: N111Stmt, +sites: U32) -> Bool:
  match stmt:
    case N111Call{+name,N111U64{},+symbol,Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111U32{},N111FuncId{+target}},Con{N111Arg{N111Ptr{},N111Local{+scratch}},Con{N111Arg{N111U32{},N111Const{+count,0}},Nil{}}}}}}:
      agy_str_eq(symbol,"p111_rt_frame") && agy_str_eq(state,"state") && p112r_buffer(scratch,sites) && U32.is_le(count,255)
    case _: False{}

# The exact CPU fail-stop runtime prerequisite is inherited, never generalized.


@unsafe
def p112r_result(body: List<&2,N111Stmt>, +sites: U32) -> Bool:
  match body:
    case Con{N111Store{N111U64{},N111Local{+base},0,+value},Con{N111Call{+dest,N111U64{},+symbol,Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111Ptr{},N111Local{+scratch}},Con{N111Arg{N111U32{},N111Const{1,0}},Nil{}}}}},Con{N111Return{N111Local{+word}},Nil{}}}}:
      p112r_buffer(base,sites) && agy_str_eq(base,scratch) && agy_str_eq(state,"state") && agy_str_eq(symbol,"p111_rt_return") && agy_str_eq(dest,word)
    case _: False{}


@unsafe
def p112r_target(body: List<&2,N111Stmt>, +sites: U32) -> String:
  match body:
    case Con{N111Store{N111U64{},N111Local{+base},+offset,+value},+rest}:
      nt_choose(String,p112r_buffer(base,sites),u => p112r_target(rest,sites),u => "")
    case Con{N111Call{+dest,N111U64{},+symbol,Con{+state,Con{N111Arg{N111U32{},N111FuncId{+name}},+rest}}},Con{N111Return{+value},Nil{}}}:
      nt_choose(String,agy_str_eq(symbol,"p111_rt_jump"),u => name,u => "")
    case _: ""


def p112g_word_type(typ: N111Type) -> Bool:
  match typ:
    case N111U32{}: True{}
    case N111U64{}: True{}
    case _: False{}


@unsafe
def p112g_name(+name: String) -> Bool:
  Bool.not(agy_str_eq(name,"state") || p112r_buffer(name,8))


@unsafe
def p112g_splice(+body: List<&2,N111Stmt>, +left: U32, +gap: List<&2,N111Stmt>) -> Maybe<&2,List<&2,N111Stmt>>:
  nt_choose(Maybe<&2,List<&2,N111Stmt>>,U32.is_eq(left,0),u => Some{nt_append(N111Stmt,gap,body)},
    u => p112g_splice_next(body,left,gap))


@unsafe
def p112g_splice_next(body: List<&2,N111Stmt>, +left: U32, +gap: List<&2,N111Stmt>) -> Maybe<&2,List<&2,N111Stmt>>:
  match body:
    case Nil{}: None{}
    case Con{+stmt,+rest}: p112g_prepend(stmt,p112g_splice(rest,U32.sub(left,1),gap))


@unsafe
def p112g_found(+gap: List<&2,N111Stmt>, +captures: U32, found: Maybe<&2,List<&2,N111Stmt>>) -> Maybe<&2,List<&2,N111Stmt>>:
  match found:
    case None{}: None{}
    case Some{+body}: p112g_splice(body,U32.inc(captures),gap)


@unsafe
def p113d_prepend(prefix: List<&2,N111Stmt>, code: P113DCode) -> P113DCode:
  match code:
    case P113DCode{body,fresh,error,calls}: P113DCode{nt_append(P113DStmt,p113d_scalars(prefix),body),fresh,error,calls}


@unsafe
def p113d_join(+first: P113DCode, +second: P113DCode) -> P113DCode:
  P113DCode{nt_append(P113DStmt,p113d_body(first),p113d_body(second)),p113d_fresh(second),
    p111_first(p113d_error(first),p113d_error(second)),nt_append(String,p113d_calls(first),p113d_calls(second))}


@unsafe
def p113d_emitted(+target: P113DTarget, +n: U32, value: P111ValueCode) -> P113DCode:
  match value:
    case P111ValueCode{body,word,+error}:
      nt_choose(P113DCode,String.is_empty(error),u => p113d_prepend(body,p113d_result(word,target,n)),u => p113d_fail(error,n))


@unsafe
def p113d_branch(condition: N111Value, +yes: P113DCode, +no: P113DCode) -> P113DCode:
  P113DCode{[P113DIf{condition,p113d_body(yes),p113d_body(no)}],p113d_fresh(no),
    p111_first(p113d_error(yes),p113d_error(no)),nt_append(String,p113d_calls(yes),p113d_calls(no))}


law p113i_size:
  for body: List<&2,P113DStmt>
  U32

@unsafe
def w7_self_rec_ok(+name: String, +body: List<&2,P113DStmt>) -> Bool:
  nt_choose(Bool,w6_body_calls_self(name,body),u => U32.is_le(p113i_size(body),1536),u => True{})

@unsafe
def p113dm_join(+row: KTerm, +base: U32, +yes: P113DCode, +no: P113DCode) -> P113DCode:
  +masked = "p112m_mask_" ++ U32.show(base)
  +condition = "p112m_hit_" ++ U32.show(base)
  p113d_prepend([N111Bin{masked,N111U64{},"and",N111Local{"v_" ++ U32.show(nc_id(base))},N111Const{p112m_mask(ix(row)),0}},
    N111Bin{condition,N111U64{},"eq",N111Local{masked},N111Const{nw_value(row),0}}],p113d_branch(N111Local{condition},yes,no))

@unsafe
def p113e_signature(function: P113DFunction) -> KDef:
  match function:
    case P113DFunction{name,params,result,public,body}:
      KDef{name,"P113Direct",nt_count(NC_Binding,params),result,atom("Absent"),kt("P113Public","",Bool.to_u32(public),0,[]),[],False{},False{}}


@unsafe
def p113e_runtime_args(args: List<&2,N111Arg>) -> Bool:
  match args:
    case Con{N111Arg{N111Ptr{},N111Local{name}},rest}: agy_str_eq(name,"state") && p113e_buffers(rest)
    case _: False{}


def p113e_symbol(name: String) -> String:
  "p113d_" ++ nt_fid(name)


@unsafe
def p113p_words(shapes: List<&2,KTerm>, args: List<&2,KTerm>, +env: List<&2,NC_Binding>) -> List<&2,N111Value>:
  match shapes args:
    case Con{+shape,+rest} Con{+arg,+more}:
      nt_append(N111Value,nt_choose(List<&2,N111Value>,p113p_known(shape),
        u => p111_values(ks(arg),env),u => [N111Local{nc_word(ix(arg),env)}]),p113p_words(rest,more,env))
    case _ _: []

# Both maximum and minimum uses are required: no duplication or conditional
# disappearance of the virtual shell. Dropped/shared/escaping shells use the
# mature ordinary boxed fallback at their original evaluation point.


@unsafe
def p113p_bindable(+body: KTerm, +id: U32) -> Bool:
  U32.is_eq(nq_uses(body,id),1) && U32.is_eq(nq_min_uses(body,id),1)


@unsafe
def p113p_pair_code(+id: U32, +values: List<&2,N111Value>, +n: U32) -> P113PValueCode:
  +out = "p113p_out_" ++ U32.show(n)
  +first = "p113p_first_" ++ U32.show(n)
  +second = "p113p_second_" ++ U32.show(n)
  P113PValueCode{Con{p113ai_snapshot(values,n),nt_append(N111Stmt,p111_store(values,0),[
    N111Alloca{out,16,8},
    N111Call{"p113p_status_" ++ U32.show(n),N111U64{},"p113_rt_array_pair",
      [p111_state(),p111_u32(id),p111_scratch(),p111_u32(nt_count(N111Value,values)),N111Arg{N111Ptr{},N111Local{out}},p111_u32(2)]},
    N111Set{first,N111U64{},N111Local{"p113ai_array_" ++ U32.show(n)}},
    N111Load{second,N111U64{},N111Local{out},8}])},
    [N111Local{first},N111Local{second}],""}

@unsafe
def p113pl_candidate_code(name: String, params: List<&2,NC_Binding>, shape: KTerm, public: Bool, code: P113DCode) -> P113DCandidate:
  match code:
    case P113DCode{body,fresh,error,calls}: P113DCandidate{P113DFunction{name,params,nq_width(shape),public,body},error,calls}


@unsafe
def p113pm_join(+row: KTerm, +base: U32, +yes: P113DCode, +no: P113DCode) -> P113DCode:
  +masked = "p112m_mask_" ++ U32.show(base)
  +condition = "p112m_hit_" ++ U32.show(base)
  p113d_prepend([N111Bin{masked,N111U64{},"and",N111Local{"v_" ++ U32.show(nc_id(base))},N111Const{p112m_mask(ix(row)),0}},
    N111Bin{condition,N111U64{},"eq",N111Local{masked},N111Const{nw_value(row),0}}],p113d_branch(N111Local{condition},yes,no))

@unsafe
def p113df_bundle_env(+mat: KTerm, +bundle: KTerm, +env: List<&2,NC_Binding>) -> List<&2,NC_Binding>:
  +fields = ks(bundle)
  +bindings = nq_field_bindings(fields,env)
  nt_choose(List<&2,NC_Binding>,agy_str_eq(tg(bundle),"NQBundle") && agy_str_eq(nm(mat),nm(bundle)) && p113df_vars(fields),
    u => p113df_refine(bindings,p113df_mask(mat,terms_len(fields)),0),
    u => bindings)


@unsafe
def p113i_values(values: List<&2,N111Value>) -> Bool:
  match values:
    case Nil{}: True{}
    case Con{head,rest}: p113i_value(head) && p113i_values(rest)


@unsafe
def p113i_args(args: List<&2,N111Arg>) -> Bool:
  match args:
    case Nil{}: True{}
    case Con{N111Arg{typ,value},rest}: p113i_value(value) && p113i_args(rest)


@unsafe
def p113i_size(body):
  match body:
    case Nil{}: 0
    case Con{P113DScalar{stmt},rest}: p113i_add(p113i_scalar_size(stmt),p113i_size(rest))
    case Con{P113DIf{condition,yes,no},rest}: p113i_add(1,p113i_add(p113i_size(yes),p113i_add(p113i_size(no),p113i_size(rest))))
    case Con{stmt,rest}: p113i_add(1,p113i_size(rest))


@unsafe
def p113i_stack(body: List<&2,P113DStmt>) -> U32:
  match body:
    case Nil{}: 0
    case Con{P113DScalar{stmt},rest}: p113i_stack_add(p113i_scalar_stack(stmt),p113i_stack(rest))
    case Con{P113DIf{condition,yes,no},rest}: p113i_stack_add(p113i_stack(yes),p113i_stack_add(p113i_stack(no),p113i_stack(rest)))
    case Con{stmt,rest}: p113i_stack(rest)


@unsafe
def p113i_join(prefix: List<&2,P113DStmt>, scan: P113IScan) -> P113IScan:
  match scan:
    case P113IScan{body,next,budget}: P113IScan{nt_append(P113DStmt,prefix,body),next,budget}


@unsafe
def w4c_is_dp_stencil(+params: List<&2,NC_Binding>, +result: U32, +body: List<&2,P113DStmt>) -> Bool:
  U32.is_eq(result,4) && U32.is_eq(nt_count(NC_Binding,params),7) &&
    w4c_body_has_again(body) && w4c_body_has_arr_pair(body)

@unsafe
def p113j_scratch_args(args: List<&2,N111Arg>) -> U32:
  match args:
    case Nil{}: 0
    case Con{N111Arg{typ,value},rest}: U32.add(Bool.to_u32(p113j_is_scratch(value)),p113j_scratch_args(rest))


@unsafe
def p113j_expanded_size(body: List<&2,P113DStmt>) -> U32:
  match body:
    case Nil{}: 0
    case Con{P113DResult{values},rest}: U32.mul(nt_count(N111Value,values),2)
    case Con{P113DScalar{stmt},rest}: p113i_add(p113i_scalar_size(stmt),p113j_expanded_size(rest))
    case Con{P113DIf{condition,yes,no},rest}:
      p113i_add(1,p113i_add(p113j_expanded_size(yes),p113i_add(p113j_expanded_size(no),p113j_expanded_size(rest))))
    case Con{stmt,rest}: p113i_add(1,p113j_expanded_size(rest))


@unsafe
def p113j_array_call(+symbol: String, args: List<&2,N111Arg>) -> Bool:
  match args:
    case Con{N111Arg{N111Ptr{},N111Local{state}},
      Con{N111Arg{N111U32{},N111Const{+id,0}},
      Con{N111Arg{N111Ptr{},N111Local{input}},
      Con{N111Arg{N111U32{},N111Const{count,0}},
      Con{N111Arg{N111Ptr{},N111Local{output}},
      Con{N111Arg{N111U32{},N111Const{2,0}},Nil{}}}}}}}:
        agy_str_eq(symbol,"p113_rt_array_pair") && agy_str_eq(state,"state") &&
        p113j_buffer_origin(input,True{}) && p113j_buffer_origin(output,False{}) &&
        U32.is_gt(p113p_array_arity(id),0) && U32.is_eq(p113p_array_arity(id),count)
    case _: False{}


@unsafe
def p113a_inputs(+id: U32, +input: N111Value, +n: U32) -> List<&2,N111Stmt>:
  nt_append(N111Stmt,[N111Load{p113a_name(n,"array"),N111U64{},input,0}],
    nt_choose(List<&2,N111Stmt>,U32.is_eq(id,75),u => [],u =>
      nt_append(N111Stmt,[N111Load{p113a_name(n,"index"),N111U64{},input,8}],
        nt_choose(List<&2,N111Stmt>,U32.is_eq(id,73) || U32.is_eq(id,74),
          v => [N111Load{p113a_name(n,"new"),N111U64{},input,16}],v => []))))


@unsafe
def p113a_class(+n: U32) -> List<&2,N111Stmt>:
  [N111Bin{p113a_name(n,"class"),N111U64{},"shr",p113a_value(n,"array"),N111Const{40,0}},
   N111Bin{p113a_name(n,"class"),N111U64{},"and",p113a_value(n,"class"),N111Const{31,0}},
   N111Bin{p113a_name(n,"size"),N111U64{},"shl",N111Const{1,0},p113a_value(n,"class")}]


@unsafe
def p113a_pair_store(+destination: String, +output: N111Value, +second: N111Value, +n: U32) -> List<&2,N111Stmt>:
  [N111Store{N111U64{},output,0,p113a_value(n,"array")},
   N111Store{N111U64{},output,8,second},
   N111Set{destination,N111U64{},N111Const{0,0}}]


@unsafe
def p113a_success(+id: U32, +destination: String, +output: N111Value, +n: U32) -> List<&2,N111Stmt>:
  nt_choose(List<&2,N111Stmt>,U32.is_eq(id,72),
    u => p113a_pair_store(destination,output,p113a_value(n,"old"),n),u =>
    nt_append(N111Stmt,[N111Store{N111U32{},p113a_value(n,"cell"),0,p113a_value(n,"new")}],
      nt_choose(List<&2,N111Stmt>,U32.is_eq(id,73),
        v => [N111Set{destination,N111U64{},p113a_value(n,"array")}],
        v => p113a_pair_store(destination,output,p113a_value(n,"old"),n))))

@unsafe
def p113a_sunk_sets(+id: U32, +n: U32, +v0: N111Value, +v1: N111Value, +v2: N111Value) -> List<&2,N111Stmt>:
  nt_append(N111Stmt,[N111Set{p113a_name(n,"array"),N111U64{},v0}],
    nt_choose(List<&2,N111Stmt>,U32.is_eq(id,75),u => [],u =>
      nt_append(N111Stmt,[N111Set{p113a_name(n,"index"),N111U64{},v1}],
        nt_choose(List<&2,N111Stmt>,U32.is_eq(id,73) || U32.is_eq(id,74),
          v => [N111Set{p113a_name(n,"new"),N111U64{},v2}],v => []))))


@unsafe
def p113a_sunk_stores(+id: U32, +input: N111Value, +n: U32) -> List<&2,N111Stmt>:
  nt_append(N111Stmt,[N111Store{N111U64{},input,0,p113a_value(n,"array")}],
    nt_choose(List<&2,N111Stmt>,U32.is_eq(id,75),u => [],u =>
      nt_append(N111Stmt,[N111Store{N111U64{},input,8,p113a_value(n,"index")}],
        nt_choose(List<&2,N111Stmt>,U32.is_eq(id,73) || U32.is_eq(id,74),
          v => [N111Store{N111U64{},input,16,p113a_value(n,"new")}],v => []))))


@unsafe
def p113a_scalar_names(stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Set{name,typ,value}: p113a_local_name(name)
    case N111Bin{name,typ,op,left,right}: p113a_local_name(name)
    case N111Call{name,typ,symbol,args}: p113a_local_name(name)
    case N111If{condition,yes,no}: p113a_scalar_list_names(yes) && p113a_scalar_list_names(no)
    case N111Load{name,typ,base,offset}: p113a_local_name(name)
    case N111Offset{name,base,bytes}: p113a_local_name(name)
    case N111Alloca{name,bytes,align}: p113a_local_name(name)
    case _: True{}


@unsafe
def p113a_scalar_list_names(body: List<&2,N111Stmt>) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{head,rest}: p113a_scalar_names(head) && p113a_scalar_list_names(rest)


@unsafe
def p113a_prefix(prefix: List<&2,P113DStmt>, scan: P113ABody) -> P113ABody:
  match scan:
    case P113ABody{body,next}: P113ABody{nt_append(P113DStmt,prefix,body),next}


@unsafe
def p113a_heap_min(nodes: List<&2,P112SNode>) -> U32:
  U32.add(51413504,U32.and(U32.add(p112s_size(nodes,0),127),4294967168))


@unsafe
def w5c2_bits4(ge16: Bool, +v: U32, +b: U32) -> U32:
  match ge16:
    case True{}:
      +v1 = U32.shrn(v, 4n)
      w5c2_bits2(U32.is_ge(v1, 4), v1, U32.add(b, 4))
    case False{}: w5c2_bits2(U32.is_ge(v, 4), v, b)

@unsafe
def w5c2_bits8(ge256: Bool, +v: U32, +b: U32) -> U32:
  match ge256:
    case True{}:
      +v1 = U32.shrn(v, 8n)
      w5c2_bits4(U32.is_ge(v1, 16), v1, U32.add(b, 8))
    case False{}: w5c2_bits4(U32.is_ge(v, 16), v, b)

@unsafe
def p113k_width(typ: N111Type) -> U32:
  match typ:
    case N111U32{}: 32
    case _: 64


@unsafe
def w5c2_mask_cov_if(le32: Bool, +bits: U32, +lo: U32, +hi: U32) -> Bool:
  match le32:
    case True{}:
      +m = p113k_ones(bits)
      U32.is_eq(U32.and(lo, m), m)
    case False{}:
      +m = p113k_ones(U32.sub(bits, 32))
      U32.is_eq(lo, 4294967295) && U32.is_eq(U32.and(hi, m), m)

@unsafe
def p113k_mask_covers(+bits: U32, mask: P113KFact) -> Bool:
  match mask:
    case P113KFact{_, exact, +lo, +hi}:
      exact && w5c2_mask_cov_if(U32.is_le(bits, 32), bits, lo, hi)

@unsafe
def w5c2_res_ty_if(is_cmp: Bool, +typ: N111Type) -> N111Type:
  match is_cmp:
    case True{}: N111U32{}
    case False{}: typ

@unsafe
def w5c2_bs_7(ok: Bool, +name: String, +typ: N111Type, +op: String, +left: N111Value, +right: N111Value) -> N111Stmt:
  match ok:
    case True{}: N111Set{name, typ, right}
    case False{}: N111Bin{name, typ, op, left, right}

@unsafe
def p113k_scalar_append(prefix: List<&2,N111Stmt>, result: P113KScalar) -> P113KScalar:
  match result:
    case P113KScalar{body,facts}: P113KScalar{nt_append(N111Stmt,prefix,body),facts}


@unsafe
def p113k_body_append(prefix: List<&2,P113DStmt>, result: P113KBody) -> P113KBody:
  match result:
    case P113KBody{body,facts,terminal}: P113KBody{nt_append(P113DStmt,prefix,body),facts,terminal}


@unsafe
def w4g_cscalars_join(pre: List<&2,N111Stmt>, postRes: W4GCopySc) -> W4GCopySc:
  match postRes:
    case W4GCopySc{post,env2}: W4GCopySc{nt_append(N111Stmt,pre,post),env2}


@unsafe
def w4g_cbody_join(pre: List<&2,P113DStmt>, postRes: W4GCopyBd) -> W4GCopyBd:
  match postRes:
    case W4GCopyBd{post,env2}: W4GCopyBd{nt_append(P113DStmt,pre,post),env2}


@unsafe
def p113ai_set_done(+values: List<&2,N111Value>, +n: U32, original: P111ValueCode) -> P111ValueCode:
  match original:
    case P111ValueCode{body,value,error}:
      P111ValueCode{Con{p113ai_snapshot(values,n),nt_append(N111Stmt,body,[
        N111Set{"p113ai_result_" ++ U32.show(n),N111U64{},N111Local{"p113ai_array_" ++ U32.show(n)}}])},
        N111Local{"p113ai_result_" ++ U32.show(n)},error}


@unsafe
def p185k_call_fact(typ: N111Type, +symbol: String, args: List<&2,N111Arg>) -> P113KFact:
  match typ args:
    case N111U64{} Con{N111Arg{N111Ptr{},N111Local{state}},
      Con{N111Arg{N111U32{},N111Const{id,0}},
      Con{N111Arg{N111Ptr{},N111Local{buffer}},
      Con{N111Arg{N111U32{},N111Const{count,0}},Nil{}}}}}:
      p113k_bound(nt_choose(U32,agy_str_eq(symbol,"p111_rt_op") && agy_str_eq(state,"state") &&
        agy_str_eq(buffer,"scratch") && p185k_bool_primitive(id,count),u => 1,u => 64))
    case _ _: p113k_bound(64)


@unsafe
def p114p_original_constructor(+name: String, +values: List<&2, N111Value>) -> P111ValueCode:
  +kind = p111_special(name)
  +call = nt_choose(N111Stmt, U32.is_eq(kind, 0),
    u => N111Call{"value", N111U64{}, "p111_rt_ctor", [p111_state(), N111Arg{N111U32{}, N111CtorId{name}}, p111_scratch(), p111_u32(nt_count(N111Value, values))]},
    u => N111Call{"value", N111U64{}, "p111_rt_special_ctor", [p111_state(), p111_u32(kind), p111_scratch(), p111_u32(nt_count(N111Value, values))]})
  P111ValueCode{nt_append(N111Stmt, p111_store(values, 0), [call]), N111Local{"value"}, ""}


@unsafe
def p114p_constructor(+name: String, +values: List<&2,N111Value>) -> P111ValueCode:
  match values:
    case Con{+field,Nil{}}:
      nt_choose(P111ValueCode,p114p_ordinary(name),
        u => p114p_single(name,field),u => p114p_original_constructor(name,values))
    case _: p114p_original_constructor(name,values)


def p114r_result_word(body: List<&2,N111Stmt>) -> N111Value:
  match body:
    case Con{N111Store{typ,base,offset,value},rest}: value
    case _: N111Const{0,0}


@unsafe
def p114r_symbol(name: String) -> String:
  "p114r_" ++ nt_fid(name)


def p114g_branch(condition: N111Value, yes: P114GBody, no: P114GBody, rest: P114GBody) -> P114GBody:
  match yes no rest:
    case P114GBody{yv,yf,yb} P114GBody{nv,nf,nb} P114GBody{rv,rf,rb}:
      P114GBody{yv && nv && rv,nt_append(P114GFrame,yf,nt_append(P114GFrame,nf,rf)),Con{P114RIf{condition,yb,nb},rb}}


def p114h_clean_args(args: List<&2,N111Arg>) -> Bool:
  match args:
    case Nil{}: True{}
    case Con{N111Arg{typ,value},rest}: p114h_clean_value(value) && p114h_clean_args(rest)


@unsafe
def p114h_call(+body: List<&2,N111Stmt>, target: String, +count: U32) -> P114GBody:
  P114GBody{True{},[],p114h_scalars(p114r_prefix(body,count),
    p114h_scalars(p114h_call_loads(count,0),[
      P114RScalar{N111Call{"p114h_call_result",N111U64{},p112w_symbol(target),Con{p111_state(),p114h_call_args(count,0)}}},
      P114RResult{N111Local{"p114h_call_result"}}]))}


@unsafe
def p114h_count(cases: List<&2,P114HCase>, +name: String) -> U32:
  match cases:
    case Nil{}: 4294967295
    case Con{P114HCase{key,captures,result,pop,body},rest}:
      nt_choose(U32,agy_str_eq(key,name),u => nt_count(String,captures),u => p114h_count(rest,name))


@unsafe
def p114t_buffer(+name: String) -> Bool:
  p113j_buffer_origin(name,True{}) || p114t_fusion_buffer(name,0)


@unsafe
def p114t_captures(+buffer: String, +count: U32, +index: U32, +site: U32) -> List<&2,N111Stmt>:
  nt_choose(List<&2,N111Stmt>,U32.is_eq(index,count),u => [],u =>
    Con{N111Load{p114t_name(site,"capture"),N111U64{},N111Local{buffer},U32.mul(index,8)},
    Con{N111Store{N111U64{},p114t_local(site,"sp"),U32.mul(index,8),p114t_local(site,"capture")},
      p114t_captures(buffer,count,U32.inc(index),site)}})


@unsafe
def p114t_frame(+dest: String, fid: String, buffer: String, +count: U32, +site: U32) -> List<&2,N111Stmt>:
  Con{N111Load{p114t_name(site,"sp"),N111Ptr{},N111Local{"state"},16},
    nt_append(N111Stmt,p114t_captures(buffer,count,0,site),[
      N111Store{N111U64{},p114t_local(site,"sp"),U32.mul(count,8),N111FuncId{fid}},
      N111Offset{p114t_name(site,"next_sp"),p114t_local(site,"sp"),N111Const{U32.mul(U32.inc(count),8),0}},
      N111Store{N111Ptr{},N111Local{"state"},16,p114t_local(site,"next_sp")},
      N111Set{dest,N111U64{},N111Const{0,0}}])}


@unsafe
def p114t_pop(dest: String, count: U32, +site: U32) -> List<&2,N111Stmt>:
  [N111Load{p114t_name(site,"sp"),N111Ptr{},N111Local{"state"},16},
   N111Offset{p114t_name(site,"next_sp"),p114t_local(site,"sp"),p114t_negative_bytes(count)},
   N111Store{N111Ptr{},N111Local{"state"},16,p114t_local(site,"next_sp")},
   N111Set{dest,N111U64{},N111Const{0,0}}]


@unsafe
def p114t_get(dest: String, index: U32, +site: U32) -> List<&2,N111Stmt>:
  [N111Load{p114t_name(site,"sp"),N111Ptr{},N111Local{"state"},16},
   N111Load{dest,N111U64{},p114t_local(site,"sp"),U32.mul(index,8)}]


@unsafe
def p114t_names(names: List<&2,String>) -> Bool:
  p114ts_names(names,True{})

@unsafe
def p114t_params(params: List<&2,NC_Binding>) -> Bool:
  p114ts_params(params,True{})

@unsafe
def p114t_scalar_names(stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Set{name,typ,value}: p114t_local_name(name)
    case N111Bin{name,typ,op,left,right}: p114t_local_name(name)
    case N111Call{name,typ,symbol,args}: p114t_local_name(name)
    case N111If{condition,yes,no}: p114t_scalar_list_names(yes) && p114t_scalar_list_names(no)
    case N111Load{name,typ,base,offset}: p114t_local_name(name)
    case N111Offset{name,base,bytes}: p114t_local_name(name)
    case N111Alloca{name,bytes,align}: p114t_local_name(name)
    case _: True{}


@unsafe
def p114t_scalar_list_names(body: List<&2,N111Stmt>) -> Bool:
  p114ts_scalar_list(body,True{})

@unsafe
def p114ts_scalar_list(body: List<&2,N111Stmt>, valid: Bool) -> Bool:
  match body:
    case Nil{}: valid
    case Con{head,rest}: p114ts_scalar_list(rest,valid && p114t_scalar_names(head))


@unsafe
def p117p_table(data: P111QData) -> P111QData:
  match data:
    case P111QData{+name,alignment,exported,items}:
      P111QData{name,alignment,exported,nt_choose(List<&2,P111QDatum>,agy_str_eq(name,"p111_program"),u => p117p_items(items,0,[]),u => items)}


@unsafe
def p117p_tables(tables: List<&2,P111QData>, acc: List<&2,P111QData>) -> List<&2,P111QData>:
  match tables:
    case Nil{}: nt_reverse(P111QData,acc,[])
    case Con{head,rest}: p117p_tables(rest,Con{p117p_table(head),acc})


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
def p117h_buffer(+name: String) -> Bool:
  p113j_buffer_origin(name,True{}) || p113j_buffer_origin(name,False{})


@unsafe
def p117h_ref(origin: U32, role: String) -> N111Value:
  N111Local{p117h_name(origin,role)}


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
def w5_set_loc_st(st: P113DStmt) -> W5SetLoc:
  match st:
    case P113DScalar{sc}: w5_set_loc_sc(sc)
    case _: W5SetLocNone{}

@unsafe
def w5_arm_loc_pair(s1: W5SetLoc, h2: P113DStmt) -> W5SetLoc:
  match s1:
    case W5SetLoc{t,src}: w5_arm_loc_pair2(t,src,w5_set_loc_st(h2))
    case W5SetLocNone{}: W5SetLocNone{}

@unsafe
def p118t_original_done(+values: List<&2,N111Value>, +target: P113PTarget, +n: U32) -> P113DCode:
  match target:
    case P113PTarget{+destinations,+shape,+tail,owner,signatures}:
      +width = nt_count(N111Value,values)
      +temps = p113pl_names("p113p_move_" ++ U32.show(n),width,0)
      nt_choose(P113DCode,U32.is_eq(width,nq_width(shape)),
        u => nt_choose(P113DCode,tail,u => P113DCode{[P113DResult{values}],n,"",[]},u =>
          nt_choose(P113DCode,U32.is_eq(width,nt_count(String,destinations)),
            v => P113DCode{p113d_scalars(nt_append(N111Stmt,p113pl_sets(temps,values),p113pl_sets(destinations,p113pl_locals(temps)))),U32.inc(n),"",[]},
            v => p113d_fail("product destination width mismatch",n))),
        u => p113d_fail("product value width mismatch",n))


@unsafe
def p118t_tail_args(args: List<&2,N111Value>) -> List<&2,N111Value>:
  nt_append(N111Value,args,p118t_state())


@unsafe
def p118t_completed(+n: U32, value: P113PValueCode) -> P113DCode:
  match value:
    case P113PValueCode{body,values,+error}:
      nt_choose(P113DCode,String.is_empty(error),
        u => p113d_prepend(body,p118t_finish(values,n)),u => p113d_fail(error,n))


@unsafe
def p118t_extend(+t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  +values = p111_values(ks(t),env)
  +count = ix(t)
  +node = "p118_node_" ++ U32.show(n)
  +root = "p118_next_root_" ++ U32.show(n)
  +empty = "p118_root_empty_" ++ U32.show(n)
  +valid = p118t_target(target) && nd_match_vars(ks(t)) && U32.is_ge(count,1) && U32.is_le(count,7) &&
    U32.is_eq(terms_len(ks(t)),U32.add(count,ix(p113pl_shape(target)))) && U32.is_eq(p111_special(nm(t)),0)
  nt_choose(P113DCode,valid,u =>
    p113d_prepend(nt_append(N111Stmt,p111_store(p118t_prefix(values,count),0),[
      N111Call{node,N111U64{},"p118_rt_extend",[p111_state(),p111_word(N111Local{"p118_parent"}),
        N111Arg{N111U32{},N111CtorId{nm(t)}},p111_scratch(),p111_u32(count)]},
      N111Bin{empty,N111U64{},"eq",N111Local{"p118_root"},N111Const{0,0}},
      N111If{N111Local{empty},[N111Set{root,N111U64{},N111Local{node}}],[N111Set{root,N111U64{},N111Local{"p118_root"}}]}]),
      P113DCode{[P113DAgain{nt_append(N111Value,p118t_rest(values,count),[N111Local{root},N111Local{node}])}],U32.inc(n),"",[]}),
    u => p113d_fail("TRMC invalid private construction",n))


@unsafe
def p118t_has_extend(body: List<&2,P113DStmt>) -> Bool:
  match body:
    case Nil{}: False{}
    case Con{P113DScalar{N111Call{name,typ,symbol,args}},rest}:
      agy_str_eq(symbol,"p118_rt_extend") || p118t_has_extend(rest)
    case Con{P113DIf{condition,yes,no},rest}: p118t_has_extend(yes) || p118t_has_extend(no) || p118t_has_extend(rest)
    case Con{stmt,rest}: p118t_has_extend(rest)


@unsafe
def p118b_root_once(+wrapper: KTerm, params: List<&2,KTerm>, +roots: List<&2,U32>, +i: U32) -> Bool:
  match params:
    case Nil{}: True{}
    case Con{p,rest}:
      (Bool.not(no_root_index(roots,i)) || U32.is_eq(nq_uses(wrapper,ix(p)),1)) &&
        p118b_root_once(wrapper,rest,roots,U32.inc(i))


@unsafe
def p118b_args_tail(+n: U32, +first: P113DCode, tail: P118BValues) -> P118BValues:
  match tail:
    case P118BValues{body,+values,next,error}:
      P118BValues{nt_append(P113DStmt,p113d_body(first),body),
        Con{N111Local{p118b_value_name(n)},values},next,p111_first(p113d_error(first),error)}


@unsafe
def p118b_terminal(+loop: Bool, args: P118BValues) -> P113DCode:
  match args:
    case P118BValues{body,+values,next,error}:
      P113DCode{nt_append(P113DStmt,body,
        [nt_choose(P113DStmt,loop,u => P113DAgain{values},u => P113DResult{values})]),next,error,[]}


@unsafe
def p118b_field_loads(fields: List<&2,KTerm>, +yesTerm: KTerm, +i: U32) -> List<&2,N111Stmt>:
  match fields:
    case Nil{}: []
    case Con{+field,+rest}:
      nt_choose(List<&2,N111Stmt>,U32.is_gt(nq_uses(yesTerm,ix(field)),0),
        u => Con{N111Load{"v_" ++ U32.show(ix(field)),N111U64{},N111Local{"scratch"},U32.mul(i,8)},p118b_field_loads(rest,yesTerm,U32.inc(i))},
        u => p118b_field_loads(rest,yesTerm,U32.inc(i)))


@unsafe
def p118c_has_cold(tables: List<&2,P111QData>) -> Bool:
  match tables:
    case Nil{}: False{}
    case Con{P111QData{+name,alignment,exported,items},rest}:
      (agy_str_eq(name,"p111_cid_hot") && p118c_zero_byte(items)) || p118c_has_cold(rest)


@unsafe
def p118c_cap_tables(tables: List<&2,P111QData>) -> List<&2,P111QData>:
  match tables:
    case Nil{}: []
    case Con{P111QData{+name,alignment,exported,+items},rest}:
      Con{P111QData{name,alignment,exported,nt_choose(List<&2,P111QDatum>,agy_str_eq(name,"p111_program"),
        u => p118c_cap_items(items,0),u => items)},p118c_cap_tables(rest)}


@unsafe
def w7_patch_prog_tables_go(tables: List<&2,P111QData>, +set3: Bool, +or_flags: U32) -> List<&2,P111QData>:
  match tables:
    case Nil{}: []
    case Con{P111QData{+name,+alignment,+exported,+items},+rest}:
      nt_choose(List<&2,P111QData>,agy_str_eq(name,"p111_program"),
        v => Con{P111QData{name,alignment,exported,w7_patch_prog_items(items,0,set3,or_flags)},rest},
        v => Con{P111QData{name,alignment,exported,items},w7_patch_prog_tables_go(rest,set3,or_flags)})

@unsafe
def p118c_tables(+tables: List<&2,P111QData>) -> List<&2,P111QData>:
  nt_choose(List<&2,P111QData>,p118c_has_cold(tables),u => p118c_cap_tables(tables),u => tables)

# The sole override. Existing p111_emit_plan still performs runtime admission;
# lower_request retains source/bound checking and the original lowering passes.
# The original full verifier runs once before either derived transformation.

@unsafe
def p118z_nonpointer(typ: N111Type) -> Bool:
  match typ:
    case N111Ptr{}: False{}
    case _: True{}


@unsafe
def p118z_tables(tables: List<&2,P111QData>) -> List<&2,P111QData>:
  match tables:
    case Nil{}: []
    case Con{P111QData{+name,alignment,exported,+items},rest}:
      Con{P111QData{name,alignment,exported,nt_choose(List<&2,P111QDatum>,agy_str_eq(name,"p111_program"),
        u => p118z_cap_items(items,0),u => items)},p118z_tables(rest)}


@unsafe
def p118ns_ctor_names(ctors: List<&2,N_Constructor>, +hot: List<&2,String>, +reversed: List<&2,String>) -> List<&2,String>:
  match ctors:
    case Nil{}: nt_reverse(String,reversed,[])
    case Con{N_Constructor{+name,+arity,was_hot},rest}:
      next = nt_choose(List<&2,String>,U32.is_gt(arity,0) && p118c_ordinary(name) && Bool.not(nb_contains(hot,"ctor:" ++ name)),
        u => Con{name,reversed},u => reversed)
      p118ns_ctor_names(rest,hot,next)


@unsafe
def p121f_budget(todo: List<&2,KTerm>, +fuel: U32) -> Bool:
  match todo:
    case Nil{}: True{}
    case Con{+item,rest}:
      nt_choose(Bool,U32.is_gt(fuel,0) && U32.is_lt(ix(item),64),u =>
        p121f_budget(nt_append(KTerm,p121f_children(ks(kid(item,0)),U32.inc(ix(item))),rest),U32.sub(fuel,1)),u => False{})


@unsafe
def p121f_bounded(term: KTerm) -> Bool:
  p121f_budget([kt("P121Depth","",0,0,[term])],2048)

# Total private list pipeline -> scalar native loop. Semantic admission reuses
# the JS backend predicates; scalar evaluation reuses the native IR lowerer.
# Original generic segments and every ordinary verifier remain unchanged.

@unsafe
def p198e_action(+op: String, +left: Bool) -> P113DCode:
  nt_choose(P113DCode,agy_str_eq(op,"U32.mul"),u =>
    p113d_prepend([p198e_bin("emul","mul",p121f_ref("em"),p121f_ref("esibling")),
      p198e_mask("enewm","emul")],p198e_again("enewm","ebias")),u =>
    p113d_prepend([p198e_bin("ecross","mul",p121f_ref("em"),p121f_ref("esibling")),
      p198e_bin("eplus",nt_choose(String,agy_str_eq(op,"U32.sub") && left,v => "sub",v => "add"),
        p121f_ref("ebias"),p121f_ref("ecross")),p198e_mask("enewb","eplus")],
      nt_choose(P113DCode,agy_str_eq(op,"U32.sub") && Bool.not(left),v =>
        p113d_prepend([p198e_bin("eneg","sub",N111Const{0,0},p121f_ref("em")),
          p198e_mask("enewm","eneg")],p198e_again("enewm","enewb")),v => p198e_again("em","enewb"))))

@unsafe
def agy_p124r_call_args(+count: U32, +symbol: String) -> List<&2,N111Arg>:
  +base = p114h_call_args(count,0)
  nt_choose(List<&2,N111Arg>,String.starts_with(symbol,"p114r_"),
    u => nt_append(N111Arg,base,[N111Arg{N111U64{},N111Const{0,0}},N111Arg{N111U64{},N111Const{0,0}},N111Arg{N111U64{},N111Const{0,0}}]),
    u => base)

@unsafe
def p124r_call_nodes(body: List<&2,N111Stmt>, +count: U32, +symbol: String) -> List<&2,N111Stmt>:
  nt_append(N111Stmt,p114r_without_transition(body),nt_append(N111Stmt,p114h_call_loads(count,0),[
    N111Call{"p114h_call_result",N111U64{},symbol,Con{p111_state(),agy_p124r_call_args(count,symbol)}}]))


@unsafe
def p125p_wrap(+owner: String, +empty: String, +link: String, +candidate: P113DCandidate) -> P113DCandidate:
  match candidate:
    case P113DCandidate{P113DFunction{+name,+params,1,True{},+body},+error,+calls}:
      p125p_params(owner,empty,link,candidate,name,params,body,error,calls)
    case _: candidate


@unsafe
def p125p_params(+owner: String, +empty: String, +link: String, +old: P113DCandidate,
  +name: String, +params: List<&2,NC_Binding>, +body: List<&2,P113DStmt>, +error: String, +calls: List<&2,String>) -> P113DCandidate:
  match params:
    case Con{NC_Binding{a,+left,ak},Con{NC_Binding{b,+right,bk},Nil{}}}:
      nt_choose(P113DCandidate,agy_str_eq(owner,name) && String.is_empty(error) && p125p_forward(body) &&
        Bool.not(String.starts_with(left,"p125_concat_")) && Bool.not(String.starts_with(right,"p125_concat_")),
        u => P113DCandidate{P113DFunction{name,params,1,True{},p125p_body(left,right,empty,link,body)},error,calls},u => old)
    case _: old


@unsafe
def p126s_atom(+term: KTerm, +kind: String) -> KTerm:
  nt_choose(KTerm,core_literal(term) && agy_str_eq(nm(term),kind),
    u => p126s_literal(kind,Some{kl_number(term)}),u =>
    nt_choose(KTerm,agy_str_eq(tg(term),"Ctr") && agy_str_eq(nm(term),kind) && U32.is_eq(terms_len(ks(term)),1),
      u => p126s_literal(kind,j_word(j_strip(kid(term,0)),0,0)),u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}))


@unsafe
def p126s_result(+op: String, +a: U32, +b: U32) -> KTerm:
  +value = nt_choose(F32,agy_str_eq(op,"U32.to_f32"),u => U32.to_f32(a),u =>
    nt_choose(F32,agy_str_eq(op,"F32.add"),u => F32.add(p126s_float(a),p126s_float(b)),u =>
    nt_choose(F32,agy_str_eq(op,"F32.sub"),u => F32.sub(p126s_float(a),p126s_float(b)),u =>
    nt_choose(F32,agy_str_eq(op,"F32.mul"),u => F32.mul(p126s_float(a),p126s_float(b)),u => F32.div(p126s_float(a),p126s_float(b))))))
  p126s_literal("F32",Some{F32.bits(value)})


@unsafe
def p126s_primitive_second(+op: String, +first: KTerm, +second: KTerm) -> KTerm:
  nt_choose(KTerm,core_literal(second),u => p126s_result(op,kl_number(first),kl_number(second)),u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})


@unsafe
def p126s_has_cells(cells: Maybe<&2,List<&2,U32>>) -> Bool:
  match cells:
    case Some{values}: U32.is_ge(nt_count(U32,values),4)
    case _: False{}


@unsafe
def p126s_is_table(function: P113DFunction) -> Bool:
  match function:
    case P113DFunction{name,[NC_Binding{id,+word,kind}],result,public,body}:
      U32.is_eq(result,1) && p126s_has_cells(p126s_cells(word,body,0))
    case _: False{}

@unsafe
def p126nt_expand(+stmt: N111Stmt, +site: U32) -> P114TExpansion:
  match stmt:
    case N111Call{+dest,N111U64{},+symbol,
      Con{N111Arg{N111Ptr{},N111Local{+state}},
      Con{N111Arg{N111U32{},N111Const{4,0}},
      Con{N111Arg{N111U64{},+term},
      Con{N111Arg{N111Ptr{},N111Local{+buffer}},
      Con{N111Arg{N111U32{},N111Const{1,0}},Nil{}}}}}}}:
        nt_choose(P114TExpansion,agy_str_eq(symbol,"p111_rt_special_take") && agy_str_eq(state,"state") &&
          Bool.not(agy_str_eq(buffer,"state")) && U32.is_le(site,4294967292),
          u => P114TExpansion{[
            N111Bin{p114t_name(site,"nat_pred"),N111U64{},"sub",term,N111Const{1,0}},
            N111Store{N111U64{},N111Local{buffer},0,p114t_local(site,"nat_pred")},
            N111Set{dest,N111U64{},N111Const{1,0}}],True{}},
          u => P114TExpansion{[stmt],False{}})
    case _: P114TExpansion{[stmt],False{}}

@unsafe
def p126i_cells(+name: String, cells: Maybe<&2,List<&2,U32>>, +acc: List<&2,P126ITable>) -> List<&2,P126ITable>:
  match cells:
    case None{}: acc
    case Some{values}:
      +count = nt_count(U32,values)
      nt_choose(List<&2,P126ITable>,U32.is_ge(count,4),
        u => Con{P126ITable{name,U32.sub(count,1)},acc},u => acc)


@unsafe
def p126i_add(function: P113DFunction, +acc: List<&2,P126ITable>) -> List<&2,P126ITable>:
  match function:
    case P113DFunction{name,[NC_Binding{id,+word,kind}],result,public,body}:
      nt_choose(List<&2,P126ITable>,U32.is_eq(result,1),
        u => p126i_cells(name,p126s_cells(word,body,0),acc),u => acc)
    case _: acc


@unsafe
def p126i_calls_walk(body: List<&2,P113DStmt>, +pending: List<&2,List<&2,P113DStmt>>, +tables: List<&2,P126ITable>) -> Bool:
  match body pending:
    case Nil{} Nil{}: False{}
    case Nil{} Con{more,rest}: p126i_calls_walk(more,rest,tables)
    case Con{P113DCall{names,target,values},rest} _:
      nt_choose(Bool,p126i_recognized(names,target,values,tables),
        u => True{},u => p126i_calls_walk(rest,pending,tables))
    case Con{P113DIf{condition,yes,no},rest} _:
      p126i_calls_walk(yes,Con{no,Con{rest,pending}},tables)
    case Con{stmt,rest} _: p126i_calls_walk(rest,pending,tables)


@unsafe
def p126i_table_name(name: String) -> String:
  "p126s_table_" ++ nt_fid(name)

@unsafe
def p126sc_shape(function: P113DFunction) -> Bool:
  match function:
    case P113DFunction{name,+params,result,public,body}:
      U32.is_eq(result,1) && U32.is_le(nt_count(NC_Binding,params),8)


@unsafe
def p126sc_safe(body: List<&2,P113DStmt>, +left: String, +right: String, +la: U32, +ra: U32, +self_arity: U32) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{P113DCall{+destinations,+target,+args},+rest}:
      nt_choose(Bool,p126sc_internal(target,left,right),
        u => p126sc_tail(destinations,rest) && U32.is_eq(nt_count(N111Value,args),nt_choose(U32,agy_str_eq(target,left),v => la,v => ra)),
        u => p126sc_safe(rest,left,right,la,ra,self_arity))
    case Con{P113DIf{condition,yes,no},rest}:
      p126sc_safe(yes,left,right,la,ra,self_arity) && p126sc_safe(no,left,right,la,ra,self_arity) && p126sc_safe(rest,left,right,la,ra,self_arity)
    case Con{P113DAgain{values},rest}: U32.is_eq(nt_count(P113DStmt,rest),0) && U32.is_eq(nt_count(N111Value,values),self_arity)
    case Con{stmt,rest}: p126sc_safe(rest,left,right,la,ra,self_arity)


@unsafe
def p126sc_pair_safe(+left: P113DFunction, +right: P113DFunction) -> Bool:
  +ln = p126sc_name(left)
  +rn = p126sc_name(right)
  +la = nt_count(NC_Binding,p126sc_params(left))
  +ra = nt_count(NC_Binding,p126sc_params(right))
  nt_choose(Bool,Bool.not(agy_str_eq(ln,rn)) && p126sc_shape(left) && p126sc_shape(right),
    u => nt_choose(Bool,p126sc_has(p113j_calls(p126sc_body(left)),rn) && p126sc_has(p113j_calls(p126sc_body(right)),ln),
      v => p126sc_safe(p126sc_body(left),ln,rn,la,ra,la) && p126sc_safe(p126sc_body(right),ln,rn,la,ra,ra),
      v => False{}),u => False{})


@unsafe
def p126sc_lanes(+tag: U32, +args: List<&2,N111Value>, +width: U32) -> List<&2,N111Value>:
  Con{N111Const{tag,0},nt_append(N111Value,args,p126sc_zeros(U32.sub(width,nt_count(N111Value,args))))}


@unsafe
def p126sc_wrapper(function: P113DFunction, +worker: String, +tag: U32, +width: U32) -> P113DCandidate:
  match function:
    case P113DFunction{name,+params,result,public,body}:
      P113DCandidate{P113DFunction{name,params,result,public,[
        P113DCall{["p126scc_result"],worker,p126sc_lanes(tag,p126sc_param_values(params),width)},
        P113DResult{[N111Local{"p126scc_result"}]}]},"",[worker]}

@unsafe
def p128br_eval_call(+name: String, +n: U32, args: P118BValues) -> P113DCode:
  match args:
    case P118BValues{body,values,next,error}:
      P113DCode{nt_append(P113DStmt,body,[P113DCall{[p118b_value_name(n)],name,values}]),next,error,[name]}


@unsafe
def p128br_seed(+owner: String, +schema: NO_Schema, workers: P118BWorkers) -> List<&2,P128BRHelper>:
  match workers:
    case P118BWorkers{+functions,+error}:
      +wrapper = no_schema_wrapper(schema)
      +params = no_schema_params(schema)
      +result = no_schema_result(schema)
      +count = nt_count(P113DFunction,functions)
      nt_choose(List<&2,P128BRHelper>,String.is_empty(error) &&
        nt_choose(Bool,agy_str_eq(tg(wrapper),"Var"),u => U32.is_eq(count,3),u => U32.is_ge(count,2) && U32.is_le(count,3)) &&
        Bool.not(p131p_parameter(result,params)) && p131p_wrapper_ok(wrapper,params,result,0) &&
        p131p_reader(p118b_read_name(owner),nt_count(KTerm,params),functions),
        u => [P128BRHelper{owner,params,no_schema_roots(schema),no_schema_observation(schema),p118b_read_name(owner),wrapper,result}],u => [])

@unsafe
def p128br_join(first: P128BRPatches, second: P128BRPatches) -> P128BRPatches:
  match first second:
    case P128BRPatches{a,ae} P128BRPatches{b,be}: P128BRPatches{nt_append(P128BRPatch,a,b),p111_first(ae,be)}


@unsafe
def p128bi_pattern(value: N111Value, params: List<&2,NC_Binding>) -> KTerm:
  match value:
    case N111Local{name}: p128bi_parameter(name,params,0)
    case N111Const{lo,hi}: kt("P128BIConstant","",lo,hi,[])
    case _: {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}


@unsafe
def p128bi_once(+patterns: KTerm, +count: U32, +i: U32) -> Bool:
  nt_choose(Bool,U32.is_eq(i,count),u => True{},
    u => U32.is_eq(nq_uses(patterns,i),1) && p128bi_once(patterns,count,U32.inc(i)))

# Each rule is immutable source-derived semantic metadata in the existing
# hash index: name=old public entry, type=callee identity, value=argument pattern.
# Constant low/high words remain exact; variables name original parameter slots.

@unsafe
def p128bi_matches(patterns: List<&2,KTerm>, args: List<&2,N111Value>) -> Bool:
  match patterns args:
    case Nil{} Nil{}: True{}
    case Con{pattern,rest} Con{value,more}: p128bi_match_value(pattern,value) && p128bi_matches(rest,more)
    case _ _: False{}


@unsafe
def p128bf_guard(+term: N111Value, +ctor: String, +site: U32) -> List<&2,N111Stmt>:
  [N111Set{p114t_name(site,"borrow_word"),N111U64{},term},
   N111Bin{p114t_name(site,"borrow_aux_bits"),N111U64{},"shr",p114t_local(site,"borrow_word"),N111Const{40,0}},
   N111Bin{p114t_name(site,"borrow_tag_aux"),N111U64{},"and",p114t_local(site,"borrow_aux_bits"),N111Const{8388607,0}},
   N111Bin{p114t_name(site,"borrow_aux_sub"),N111U64{},"sub",p114t_local(site,"borrow_tag_aux"),N111Const{131072,0}},
   N111Bin{p114t_name(site,"borrow_guard"),N111U32{},"eq",p114t_local(site,"borrow_aux_sub"),N111CtorId{ctor}}]

# rfc_view's exact low/high word layout. The selected CPU runtime has no
# concurrent refcount mutation; this is not a concurrent/device template.

@unsafe
def p128bf_rfc(+site: U32) -> List<&2,N111Stmt>:
  [N111Bin{p114t_name(site,"borrow_header_bytes"),N111U64{},"shl",p114t_local(site,"borrow_location"),N111Const{3,0}},
   N111Offset{p114t_name(site,"borrow_header"),p114t_local(site,"borrow_heap"),p114t_local(site,"borrow_header_bytes")},
   N111Load{p114t_name(site,"borrow_header_word"),N111U64{},p114t_local(site,"borrow_header"),0},
   N111Bin{p114t_name(site,"borrow_location"),N111U64{},"shr",p114t_local(site,"borrow_header_word"),N111Const{24,0}}]


@unsafe
def p128bf_fields(+buffer: String, +count: U32, +site: U32, +index: U32, +mask: U32) -> List<&2,N111Stmt>:
  nt_choose(List<&2,N111Stmt>,U32.is_eq(index,count),u => [],u =>
    nt_choose(List<&2,N111Stmt>,U32.is_ne(U32.and(mask,U32.shln(1,U32.to_nat(index))),0),
      v => Con{N111Load{p114t_name(site,"borrow_field_" ++ U32.show(index)),N111U64{},p114t_local(site,"borrow_fields"),U32.mul(index,8)},
           Con{N111Store{N111U64{},N111Local{buffer},U32.mul(index,8),p114t_local(site,"borrow_field_" ++ U32.show(index))},
             p128bf_fields(buffer,count,site,U32.inc(index),mask)}},
      v => p128bf_fields(buffer,count,site,U32.inc(index),mask)))


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

def p131u_merge_loop(+left: List<&2,P131UEntry>, +right: List<&2,P131UEntry>, +mode: U32, order: Cmp, +li: U32, +ll: U32, +lh: U32, +ri: U32, +rl: U32, +rh: U32) -> List<&2,P131UEntry>:
  match left right order:
    case Nil{} values LT{}:
      Con{P131UEntry{li,p131a_low(mode,ll,0),p131a_high(mode,lh,0)},p131u_absent(Con{P131UEntry{ri,rl,rh},values},mode)}
    case Con{P131UEntry{+ni,nl,nh},rest} values LT{}:
      Con{P131UEntry{li,p131a_low(mode,ll,0),p131a_high(mode,lh,0)},p131u_merge_loop(rest,values,mode,U32.cmp(ni,ri),ni,nl,nh,ri,rl,rh)}
    case values Nil{} GT{}:
      Con{P131UEntry{ri,p131a_low(mode,0,rl),p131a_high(mode,0,rh)},p131u_absent(Con{P131UEntry{li,ll,lh},values},mode)}
    case values Con{P131UEntry{+ni,nl,nh},rest} GT{}:
      Con{P131UEntry{ri,p131a_low(mode,0,rl),p131a_high(mode,0,rh)},p131u_merge_loop(values,rest,mode,U32.cmp(li,ni),li,ll,lh,ni,nl,nh)}
    case Nil{} values EQ{}:
      Con{P131UEntry{li,p131a_low(mode,ll,rl),p131a_high(mode,lh,rh)},p131u_absent(values,mode)}
    case values Nil{} EQ{}:
      Con{P131UEntry{li,p131a_low(mode,ll,rl),p131a_high(mode,lh,rh)},p131u_absent(values,mode)}
    case Con{P131UEntry{+ni,nl,nh},xs} Con{P131UEntry{+mi,ml,mh},ys} EQ{}:
      Con{P131UEntry{li,p131a_low(mode,ll,rl),p131a_high(mode,lh,rh)},p131u_merge_loop(xs,ys,mode,U32.cmp(ni,mi),ni,nl,nh,mi,ml,mh)}



def p131u_merge(left: List<&2,P131UEntry>, right: List<&2,P131UEntry>, +mode: U32) -> List<&2,P131UEntry>:
  match left right:
    case Nil{} values: p131u_absent(values,mode)
    case values Nil{}: p131u_absent(values,mode)
    case Con{P131UEntry{+li,ll,lh},lr} Con{P131UEntry{+ri,rl,rh},rr}:
      p131u_merge_loop(lr,rr,mode,U32.cmp(li,ri),li,ll,lh,ri,rl,rh)


@unsafe
def p131p_virtual_fields(fields: List<&2,KTerm>, +params: List<&2,KTerm>, +args: List<&2,KTerm>, +result: U32, +scalar: KTerm) -> List<&2,KTerm>:
  match fields:
    case Nil{}: []
    case Con{head,rest}: Con{p131p_virtual(head,params,args,result,scalar),p131p_virtual_fields(rest,params,args,result,scalar)}


@unsafe
def p131p_virtual(+t: KTerm, +params: List<&2,KTerm>, +args: List<&2,KTerm>, +result: U32, +scalar: KTerm) -> KTerm:
  nt_choose(KTerm,agy_str_eq(tg(t),"Var"),u =>
    nt_choose(KTerm,U32.is_eq(ix(t),result),v => scalar,v => p131p_argument(ix(t),params,args)),u =>
    nt_choose(KTerm,agy_str_eq(tg(t),"Ctr"),v => kt("OC",nm(t),0,0,p131p_virtual_fields(ks(t),params,args,result,scalar)),v => atom("Absent")))


@unsafe
def p131p_reader(+reader: String, +arity: U32, functions: List<&2,P113DFunction>) -> Bool:
  match functions:
    case Nil{}: False{}
    case Con{P113DFunction{name,params,result,public,body},rest}:
      nt_choose(Bool,agy_str_eq(name,reader),u => Bool.not(public) && U32.is_eq(result,1) &&
        U32.is_eq(nt_count(NC_Binding,params),arity),u => p131p_reader(reader,arity,rest))

@unsafe
def p131rg_join(first: P128BLNode, tail: P128BLNode) -> P128BLNode:
  match first tail:
    case P128BLNode{a,ac,+ae} P128BLNode{b,bc,be}:
      P128BLNode{nt_append(NO_Spec,a,b),nt_append(KTerm,ac,bc),p111_first(ae,be)}


@unsafe
def p134v_scalar(a: N111Stmt, b: N111Stmt) -> Bool:
  match a b:
    case N111Set{an,at,av} N111Set{bn,bt,bv}: agy_str_eq(an,bn) && p134v_type(at,bt) && p134v_value(av,bv)
    case N111Bin{an,at,ao,al,ar} N111Bin{bn,bt,bo,bl,br}:
      agy_str_eq(an,bn) && p134v_type(at,bt) && agy_str_eq(ao,bo) && p134v_value(al,bl) && p134v_value(ar,br)
    case N111Call{an,at,as,aa} N111Call{bn,bt,bs,ba}:
      agy_str_eq(an,bn) && p134v_type(at,bt) && agy_str_eq(as,bs) && p134v_list(~N111Arg,~p134v_arg,aa,ba)
    case N111If{ac,ay,an} N111If{bc,by,bn}:
      p134v_value(ac,bc) && p134v_list(~N111Stmt,~p134v_scalar,ay,by) && p134v_list(~N111Stmt,~p134v_scalar,an,bn)
    case N111Return{av} N111Return{bv}: p134v_value(av,bv)
    case N111Load{an,at,ab,ao} N111Load{bn,bt,bb,bo}:
      agy_str_eq(an,bn) && p134v_type(at,bt) && p134v_value(ab,bb) && U32.is_eq(ao,bo)
    case N111Store{at,ab,ao,av} N111Store{bt,bb,bo,bv}:
      p134v_type(at,bt) && p134v_value(ab,bb) && U32.is_eq(ao,bo) && p134v_value(av,bv)
    case N111Offset{an,ab,ax} N111Offset{bn,bb,bx}:
      agy_str_eq(an,bn) && p134v_value(ab,bb) && p134v_value(ax,bx)
    case N111Alloca{an,ab,aa} N111Alloca{bn,bb,ba}: agy_str_eq(an,bn) && U32.is_eq(ab,bb) && U32.is_eq(aa,ba)
    case _ _: False{}

@unsafe
def p137qi_scalar(stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Call{name,typ,symbol,args}:
      Bool.not(agy_str_eq(symbol,"p111_rt_take") && p137qi_wide_args(args))
    case N111If{condition,yes,no}: p137qi_scalars(yes) && p137qi_scalars(no)
    case _: True{}


@unsafe
def p137qi_scalars(body: List<&2,N111Stmt>) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{head,rest}: p137qi_scalar(head) && p137qi_scalars(rest)

# Same shape walk as p113j_plain/p113j_returns. Add the profitability test while
# visiting existing scalar nodes, rather than starting a second whole-body walk.

@unsafe
def p137q_name_eq(key: String, record: KDef) -> Bool:
  match record:
    case KDef{name,kind,arity,templates,typ,value,ctors,native,unsafe}: agy_str_eq(name,key)
    case KIndexLeaf{hash,bucket}: agy_str_eq("",key)
    case KIndexNode{hash,mask,left,right}: agy_str_eq("",key)


@unsafe
def p137q_key_eq(key: String, record: KDef) -> Bool:
  match record:
    case KDef{name,kind,arity,templates,typ,value,ctors,native,unsafe}: p88_string_eq(key,name)
    case KIndexLeaf{hash,bucket}: p88_string_eq(key,"")
    case KIndexNode{hash,mask,left,right}: p88_string_eq(key,"")


@unsafe
def p137q_is_cache(record: KDef) -> Bool:
  match record:
    case KDef{name,kind,arity,templates,typ,value,ctors,native,unsafe}: p88_string_eq(kind,"BookCache")
    case KIndexLeaf{hash,bucket}: False{}
    case KIndexNode{hash,mask,left,right}: False{}


@unsafe
def p137q_is_adt(record: KDef) -> Bool:
  match record:
    case KDef{name,kind,arity,templates,typ,value,ctors,native,unsafe}: p88_string_eq(kind,"ADT")
    case KIndexLeaf{hash,bucket}: False{}
    case KIndexNode{hash,mask,left,right}: False{}


@unsafe
def p137q_is_ctr(record: KDef) -> Bool:
  match record:
    case KDef{name,kind,arity,templates,typ,value,ctors,native,unsafe}: p88_string_eq(kind,"Ctr")
    case KIndexLeaf{hash,bucket}: False{}
    case KIndexNode{hash,mask,left,right}: False{}

@unsafe
def p143cp_regular(todo: List<&2,KDef>) -> Bool:
  match todo:
    case Nil{}: True{}
    case Con{KDef{name,+kind,arity,templates,typ,value,ctors,native,unsafe},rest}:
      Bool.not(p88_string_eq(kind,"BookCache")) && p143cp_regular(rest)
    case Con{other,rest}: False{}


@unsafe
def p143o_range_term(+t: KTerm, +n: U32, +left: U32) -> Bool:
  nt_choose(Bool,p98_tag_eq(t,"Var"),u => p143o_in_range(ix(t),n,left),
    u => p143o_range_terms(ks(t),n,left))


@unsafe
def p143o_range_terms(terms: List<&2,KTerm>, +n: U32, +left: U32) -> Bool:
  match terms:
    case Nil{}: False{}
    case Con{head,rest}: p143o_range_term(head,n,left) || p143o_range_terms(rest,n,left)

# Preserve first-match nc_word and its literal sentinel semantics. This loop
# has the same U32 sequence and termination budget as nd_comb_fresh.

@unsafe
def p143o_range(+body: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +n: U32, +left: U32) -> Bool:
  nt_choose(Bool,U32.is_eq(left,0),u => True{},u =>
    Bool.not(p143o_range_term(body,n,left)) && Bool.not(p143o_range_terms(args,n,left)) &&
      p143o_range_env(env,n,left))

@unsafe
def p144o_payload(context: KDef) -> P144OFacts:
  match context:
    case KDef{name,kind,arity,templates,typ,value,children,native,uns}:
      nt_choose(P144OFacts,p88_string_eq(name,"$native.ctors") && p88_string_eq(kind,"NativeCtorIndex") &&
        U32.is_eq(arity,0) && U32.is_eq(templates,0) && Bool.not(native) && Bool.not(uns),
        u => p144o_term(typ),u => P144OFacts{[],False{}})
    case _: P144OFacts{[],False{}}


@unsafe
def p164a_body(owner: String, +arity: U32) -> List<&2,N111Stmt>:
  Con{N111Alloca{"p164_adapter_out",8,8},
    nt_append(N111Stmt,p164a_loads(arity,0),[
      N111Call{"p164_value",N111U64{},p113e_symbol(owner),Con{p111_state(),p164a_args(arity,0)}},
      N111Store{N111U64{},N111Local{"p164_adapter_out"},0,N111Local{"p164_value"}},
      N111Call{"p164_reply",N111U64{},"p111_rt_return",[
        p111_state(),N111Arg{N111Ptr{},N111Local{"p164_adapter_out"}},p111_u32(1)]},
      N111Return{N111Local{"p164_reply"}}])}



@unsafe
def w6_type_tag(typ: N111Type) -> String:
  match typ:
    case N111U32{}: "3"
    case N111U64{}: "6"
    case N111Ptr{}: "p"

@unsafe
def w6_canon_val(+locals: List<&2,W6Local>, val: N111Value) -> String:
  match val:
    case N111Local{name}: w6_use_local(locals,name)
    case N111Const{lo,hi}: "c:" ++ U32.show(lo) ++ ":" ++ U32.show(hi)
    case N111Symbol{name}: "s:" ++ name
    case N111FuncId{name}: "f:" ++ name
    case N111CtorId{name}: "k:" ++ name

@unsafe
def p168_stats(lowered: P167Lowered, extra: List<&2,U32>) -> P167Lowered:
  match lowered:
    case P167Lowered{program,adapters,error,stats}:
      P167Lowered{program,adapters,error,nt_append(U32,stats,extra)}



@unsafe
def w4p_finish_box(+orig: P113DFunction, +name: String, +params: List<&2,NC_Binding>,
    +pre: List<&2,N111Stmt>, +prodName: String, +flatArgs: List<&2,N111Value>,
    +retNames: List<&2,String>, boxed: P111ValueCode) -> P113DFunction:
  match boxed:
    case P111ValueCode{+bstmts,+bword,+berr}:
      nt_choose(P113DFunction,String.is_empty(berr),
        u => P113DFunction{name,params,1,True{},
          nt_append(P113DStmt,p113d_scalars(pre),
            Con{P113DCall{retNames,prodName,flatArgs},
              nt_append(P113DStmt,p113d_scalars(bstmts),[P113DResult{[bword]}])})},
        u => orig)

@unsafe
def w4p_cand_of(+fn: P113DFunction) -> P113DCandidate:
  match fn:
    case P113DFunction{n2,p2,r2,pub2,+b2}: P113DCandidate{fn,"",p113j_calls(b2)}

@unsafe
def p168j_forward(+name: String, +arity: U32) -> String:
  "function l $" ++ p112w_symbol(name) ++ "(" ++ p112w_call_args(arity,0,"l %state") ++ ") {\n@entry\n" ++
  "%p164_forward =l call $" ++ p113e_symbol(name) ++ "(" ++ p112w_call_args(arity,0,"l %state") ++ ")\nret %p164_forward\n}\n"



@unsafe
def p170ls_word(inspected: String, +original: String, +acc: String, +n: U32, +last: Char) -> FScanned:
  match inspected:
    case SNil{}: FScanned{String.reverse(acc),"",n}
    case SCon{+head,+rest}:
      f_choose(FScanned,f_choose(Bool,f_ident(head),u => True{},u =>
        (Char.is_eq(head,'+') || Char.is_eq(head,'-')) &&
          (Char.is_eq(last,'e') || Char.is_eq(last,'E')) && p150l_digit(rest)),
        u => p150l_word(rest,SCon{head,acc},U32.add(n,1),head),
        u => FScanned{String.reverse(acc),original,n})

@unsafe
def p170ls_other(+head: Char, inspected: String, +original: String, +l: U32, +c: U32, +d: U32, +acc: List<&2,FToken>, +offset: U32, +previous: U32) -> List<&2,FToken>:
  match inspected:
    case SCon{+second,SCon{+third,tail}}:
      f_choose(List<&2,FToken>,p150l_triple(head,second,third),
        u => p150l_emit(SCon{head,SCon{second,SCon{third,""}}},tail,l,c,d,acc,offset,previous,3,3),
        u => p150l_other_plain(head,original,l,c,d,acc,offset,previous))
    case _: p150l_other_plain(head,original,l,c,d,acc,offset,previous)

@unsafe
def p170ls_symbol(+head: Char, inspected: String, +original: String, +l: U32, +c: U32, +d: U32, +acc: List<&2,FToken>, +offset: U32, +previous: U32) -> List<&2,FToken>:
  match inspected:
    case SNil{}: p150l_single(head,"",l,c,d,acc,offset,previous)
    case SCon{+second,tail}:
      f_choose(List<&2,FToken>,p150l_pair(head,second),
        u => p150l_emit(SCon{head,SCon{second,""}},tail,l,c,d,acc,offset,previous,2,2),
        u => p150l_single(head,original,l,c,d,acc,offset,previous))

@unsafe
def p170ls_plus(inspected: String, +original: String, +l: U32, +c: U32, +d: U32, +acc: List<&2,FToken>, +offset: U32, +previous: U32, +contiguous: Bool) -> List<&2,FToken>:
  match inspected:
    case SNil{}: p150l_emit("+","",l,c,d,acc,offset,previous,1,1)
    case SCon{+head,tail}:
      f_choose(List<&2,FToken>,f_ascii_char_eq(head,'+'),
        u => f_choose(List<&2,FToken>,contiguous,
          v => p150l_emit("+",original,l,c,d,acc,offset,previous,1,1),
          v => p150l_emit("++",tail,l,c,d,acc,offset,previous,2,2)),
        u => p150l_emit(f_choose(String,f_ascii_alpha(head) && Bool.not(contiguous),v => "+bind",v => "+"),original,l,c,d,acc,offset,previous,1,1))

@unsafe
def p170ls_greater(inspected: String, +original: String, +l: U32, +c: U32, +d: U32, +acc: List<&2,FToken>, +offset: U32, +previous: U32, +gap: Bool) -> List<&2,FToken>:
  match inspected:
    case SNil{}: p150l_emit(f_choose(String,gap,u => ">op",u => ">"),"",l,c,d,acc,offset,previous,1,1)
    case SCon{+head,+tail}:
      f_choose(List<&2,FToken>,f_ascii_char_eq(head,'>'),
        u => p150l_emit(f_choose(String,gap,v => ">>op",v => ">>"),tail,l,c,d,acc,offset,previous,2,2),
      u => f_choose(List<&2,FToken>,f_ascii_char_eq(head,'='),u => p150l_emit(">=",tail,l,c,d,acc,offset,previous,2,2),
        u => p150l_emit(f_choose(String,gap,v => ">op",v => ">"),original,l,c,d,acc,offset,previous,1,1)))

@unsafe
def p171sc_attach(schema: NO_Schema, catalogue: List<&2,NO_Spec>) -> NO_Schema:
  match schema:
    case NO_Schema{params,roots,wrapper,result,observation,specs,fresh,error}:
      NO_Schema{params,roots,wrapper,result,observation,nt_append(NO_Spec,specs,catalogue),fresh,error}

law w7c_subst:
  for +t: KTerm
  for +id: U32
  for +value: KTerm
  for +depth: U32
  KTerm

@unsafe
def w7c_subst_list(+ts: List<&2,KTerm>, +id: U32, +value: KTerm, +depth: U32) -> List<&2,KTerm>:
  match ts:
    case Nil{}: Nil{}
    case Con{h, rest}: Con{w7c_subst(h, id, value, depth), w7c_subst_list(rest, id, value, depth)}

@unsafe
def w7c_subst_beta(isLam: Bool, +r0: KTerm, +r1: KTerm, +b: U32, +e: U32, +depth: U32) -> KTerm:
  match isLam:
    case True{}:
      w7c_subst(kid(r0, 0), ix(r0), r1, depth)
    case False{}:
      KTerm{"App", "", 0, 0, Con{r0, Con{r1, Nil{}}}, Nil{}, b, e}

@unsafe
def w7c_subst_app2(isApp: Bool, +tag: String, +name: String, +n: U32, +quant: U32, +r0: KTerm, +r1: KTerm, +rem: List<&2,String>, +b: U32, +e: U32, +depth: U32) -> KTerm:
  match isApp:
    case True{}:
      w7c_subst_beta(p98_tag_eq(r0, "Lam"), r0, r1, b, e, depth)
    case False{}:
      KTerm{tag, name, n, quant, Con{r0, Con{r1, Nil{}}}, rem, b, e}

@unsafe
def w7c_subst_app_gen(isApp: Bool, +tag: String, +name: String, +n: U32, +quant: U32, +rkids: List<&2,KTerm>, +rem: List<&2,String>, +b: U32, +e: U32, +depth: U32) -> KTerm:
  match isApp:
    case True{}:
      w7c_subst_beta(p98_tag_eq(terms_at(rkids, 0), "Lam"), terms_at(rkids, 0), terms_at(rkids, 1), b, e, depth)
    case False{}:
      KTerm{tag, name, n, quant, rkids, rem, b, e}

@unsafe
def w7c_subst_app_nil(isApp: Bool, +t: KTerm, +b: U32, +e: U32, +depth: U32) -> KTerm:
  match isApp:
    case True{}:
      w7c_subst_beta(p98_tag_eq(terms_at(Nil{}, 0), "Lam"), terms_at(Nil{}, 0), terms_at(Nil{}, 1), b, e, depth)
    case False{}:
      t

@unsafe
def w7c_subst_var(isVar: Bool, +tag: String, +name: String, +n: U32, +quant: U32, +kids: List<&2,KTerm>, +rem: List<&2,String>, +b: U32, +e: U32, +t: KTerm, +id: U32, +value: KTerm, +d1: U32) -> KTerm:
  match isVar:
    case True{}:
      value
    case False{}:
      match kids:
        case Nil{}:
          w7c_subst_app_nil(p88_string_eq(tag, "App"), t, b, e, d1)
        case Con{k0, r0}:
          match r0:
            case Nil{}:
              +s0 = w7c_subst(k0, id, value, d1)
              w7c_subst_app_gen(p88_string_eq(tag, "App"), tag, name, n, quant, Con{s0, Nil{}}, rem, b, e, d1)
            case Con{k1, r1}:
              match r1:
                case Nil{}:
                  +s0 = w7c_subst(k0, id, value, d1)
                  +s1 = w7c_subst(k1, id, value, d1)
                  w7c_subst_app2(p88_string_eq(tag, "App"), tag, name, n, quant, s0, s1, rem, b, e, d1)
                case Con{_, _}:
                  +s0 = w7c_subst(k0, id, value, d1)
                  +s1 = w7c_subst(k1, id, value, d1)
                  w7c_subst_app_gen(p88_string_eq(tag, "App"), tag, name, n, quant, Con{s0, Con{s1, w7c_subst_list(r1, id, value, d1)}}, rem, b, e, d1)

@unsafe
def w7c_subst_go(deep: Bool, +t: KTerm, +id: U32, +value: KTerm, +d1: U32) -> KTerm:
  match deep:
    case True{}:
      p177s_loop(0, t, Nil{}, id, value, Nil{})
    case False{}:
      match t:
        case KLiteral{_, _, _, _, _}:
          t
        case KLambda{name, n, quant, kids, rem, b, e, pres}:
          match kids:
            case Nil{}: t
            case Con{k0, r0}:
              match r0:
                case Nil{}: KLambda{name, n, quant, Con{w7c_subst(k0, id, value, d1), Nil{}}, rem, b, e, pres}
                case Con{_, _}: KLambda{name, n, quant, Con{w7c_subst(k0, id, value, d1), w7c_subst_list(r0, id, value, d1)}, rem, b, e, pres}
        case KTerm{tag, name, n, quant, kids, rem, b, e}:
          w7c_subst_var(U32.is_eq(n, id) && p88_string_eq(tag, "Var"), tag, name, n, quant, kids, rem, b, e, t, id, value, d1)

@unsafe
def w7c_subst(t, id, value, depth):
  w7c_subst_go(U32.is_ge(depth, 512), t, id, value, U32.add(depth, 1))

@unsafe
def p185cc_guard(+site: U32) -> List<&2,N111Stmt>:
  [N111Load{p114t_name(site,"cold_abi"),N111U64{},N111Symbol{"p111_program"},0},
   N111Load{p114t_name(site,"cold_descriptor"),N111U64{},N111Symbol{"p111_program"},8},
   N111Load{p114t_name(site,"cold_caps"),N111U64{},N111Symbol{"p111_program"},88},
   N111Bin{p114t_name(site,"cold_abi_ok"),N111U64{},"eq",p114t_local(site,"cold_abi"),N111Const{11102,0}},
   N111Bin{p114t_name(site,"cold_descriptor_ok"),N111U64{},"eq",p114t_local(site,"cold_descriptor"),N111Const{192,0}},
   N111Bin{p114t_name(site,"cold_caps_bits"),N111U64{},"and",p114t_local(site,"cold_caps"),N111Const{9,0}},
   N111Bin{p114t_name(site,"cold_caps_ok"),N111U64{},"eq",p114t_local(site,"cold_caps_bits"),N111Const{9,0}},
   N111Bin{p114t_name(site,"cold_layout_ok"),N111U32{},"and",p114t_local(site,"cold_abi_ok"),p114t_local(site,"cold_descriptor_ok")},
   N111Bin{p114t_name(site,"cold_guard"),N111U32{},"and",p114t_local(site,"cold_layout_ok"),p114t_local(site,"cold_caps_ok")}]

@unsafe
def p185cc_writes(+count: U32, +site: U32, +index: U32) -> List<&2,N111Stmt>:
  nt_choose(List<&2,N111Stmt>,U32.is_eq(index,count),u => [],u =>
    Con{N111Store{N111U64{},p114t_local(site,"cold_fields"),U32.mul(index,8),p114t_local(site,"cold_field_" ++ U32.show(index))},
      p185cc_writes(count,site,U32.inc(index))})

# The nonempty heap_alloc branch is copied exactly: pop mem[head] and remove
# 2^class words from ALC_LEN. Snapshot verified stack scratch before mutation;
# no field is retained, sunk, sealed, or reordered relative to another field.
# No allocator miss, shared cell, or hot publication is admitted here.
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
def p185pt_previous(+name: String, +word: N111Value, +count: U32, +n: U32) -> List<&2,N111Stmt>:
  +kind = p111_special(name)
  nt_choose(List<&2,N111Stmt>,U32.is_eq(count,0),u => Nil{},
    u => Con{nt_choose(N111Stmt,U32.is_eq(kind,0),
      v => N111Call{"ignored",N111U64{},"p111_rt_take",[p111_state(),p111_word(word),p111_scratch(),p111_u32(count)]},
      v => N111Call{"ignored",N111U64{},"p111_rt_special_take",[p111_state(),p111_u32(kind),p111_word(word),p111_scratch(),p111_u32(count)]}),p111_load_fields(count,0,n)})

@unsafe
def p185pt_admitted(+name: String, word: N111Value, +count: U32) -> Bool:
  p114p_ordinary(name) && U32.is_eq(count,1) && p185pt_word(word)

@unsafe
def p185pt_single(+name: String, +word: N111Value, +n: U32) -> List<&2,N111Stmt>:
  nt_append(N111Stmt,
    [N111Set{p185pt_name(n,"word"),N111U64{},word},
     N111Bin{p185pt_name(n,"bits"),N111U64{},"shr",p185pt_local(n,"word"),N111Const{40,0}},
     N111Bin{p185pt_name(n,"shape"),N111U64{},"and",p185pt_local(n,"bits"),N111Const{8388607,0}},
     N111Bin{p185pt_name(n,"expected"),N111U64{},"or",N111CtorId{name},N111Const{65536,0}},
     N111Bin{p185pt_name(n,"guard"),N111U64{},"eq",p185pt_local(n,"shape"),p185pt_local(n,"expected")},
     N111If{p185pt_local(n,"guard"),[
       N111Bin{p185pt_name(n,"payload"),N111U64{},"and",p185pt_local(n,"word"),N111Const{4294967295,255}},
       N111Store{N111U64{},N111Local{"scratch"},0,p185pt_local(n,"payload")},
       N111Set{"ignored",N111U64{},N111Const{1,0}}],[
       N111Call{"ignored",N111U64{},"p111_rt_take",[p111_state(),p111_word(word),p111_scratch(),p111_u32(1)]}]}],
    p111_load_fields(1,0,n))

@unsafe
def p185cb_header(+tables: List<&2,P111QData>, +header: List<&2,P111QDatum>) -> Bool:
  +caps = p185cb_number(p185cb_at(header,11))
  U32.is_eq(nt_count(P111QDatum,header),24) &&
    p185cb_unique(tables,"p111_program",False{}) && p185cb_unique(tables,"p111_cid_arity",False{}) &&
    p185cb_unique(tables,"p111_cid_hot",False{}) && U32.is_eq(p185cb_number(p185cb_at(header,0)),11102) &&
    U32.is_eq(p185cb_number(p185cb_at(header,1)),192) && U32.is_ge(caps,9) && U32.is_le(caps,15) &&
    U32.is_eq(U32.and(caps,1),1) && p185cb_ref(p185cb_at(header,16),"p111_cid_arity") &&
    p185cb_ref(p185cb_at(header,17),"p111_cid_hot")

# One linear table pass builds a numeric-CID index. The later constructor
# index walk performs bounded trie lookups, never a table scan per constructor.
@unsafe
def p186rt_writes(+count: U32, +site: U32, +index: U32) -> List<&2,N111Stmt>:
  nt_choose(List<&2,N111Stmt>,U32.is_eq(index,count),u => [],u =>
    Con{N111Store{N111U64{},N111Local{"state"},U32.add(40,U32.mul(index,8)),p114t_local(site,"transfer_word_" ++ U32.show(index))},
      p186rt_writes(count,site,U32.inc(index))})

@unsafe
def p186rt_return(dest: String, count: U32, +site: U32) -> List<&2,N111Stmt>:
  [N111Store{N111U32{},N111Local{"state"},28,N111Const{count,0}},
   N111Load{p114t_name(site,"transfer_sp"),N111Ptr{},N111Local{"state"},16},
   N111Offset{p114t_name(site,"transfer_previous"),p114t_local(site,"transfer_sp"),N111Const{4294967288,4294967295}},
   N111Store{N111Ptr{},N111Local{"state"},16,p114t_local(site,"transfer_previous")},
   N111Load{p114t_name(site,"transfer_next"),N111U64{},p114t_local(site,"transfer_previous"),0},
   N111Store{N111U32{},N111Local{"state"},32,p114t_local(site,"transfer_next")},
   N111Set{dest,N111U64{},N111Const{0,0}}]

@unsafe
def p186rt_guard(stmt: N111Stmt, buffer: String, +count: U32, +site: U32, finish: List<&2,N111Stmt>) -> P114TExpansion:
  P114TExpansion{[
    N111Load{p114t_name(site,"transfer_caps"),N111U64{},N111Symbol{"p111_program"},88},
    N111Bin{p114t_name(site,"transfer_live"),N111U64{},"and",p114t_local(site,"transfer_caps"),N111Const{4,0}},
    N111If{p114t_local(site,"transfer_live"),
      nt_append(N111Stmt,p186rt_reads(buffer,count,site,0),
        nt_append(N111Stmt,p186rt_writes(count,site,0),finish)),[stmt]}],True{}}

@unsafe
def w11_p186ch_take_a3(+stmt: N111Stmt, +dest: String, +word: N111Value, m3: Maybe<&2,String>, a4: N111Arg) -> P114TExpansion:
  match m3:
    case Some{+buffer}:
      nt_choose(P114TExpansion,Bool.not(agy_str_eq(buffer,"state")),
        u => w11_p186ch_take_a4(stmt,dest,word,buffer,w11_arg_u32_const(a4)),
        u => P114TExpansion{[stmt],False{}})
    case _: P114TExpansion{[stmt],False{}}

@unsafe
def w11_p186ch_ctor_a2(+stmt: N111Stmt, +dest: String, +kind: U32, m2: Maybe<&2,String>, a3: N111Arg) -> P114TExpansion:
  match m2:
    case Some{+buffer}:
      nt_choose(P114TExpansion,Bool.not(agy_str_eq(buffer,"state")),
        u => w11_p186ch_ctor_a3(stmt,dest,kind,buffer,w11_arg_u32_const(a3)),
        u => P114TExpansion{[stmt],False{}})
    case _: P114TExpansion{[stmt],False{}}

@unsafe
def x188_finish(chunks: List<&2,X188Seq>) -> X188Seq:
  x188_finish_go(chunks,X188Empty{})

@unsafe
def x188_many(chunks: List<&2,X188Seq>) -> X188Seq:
  x188_finish(nt_reverse(X188Seq,chunks,[]))

def x188_width_reg(typ: N111Type, index: U32) -> X187Operand:
  match typ:
    case N111U32{}: x188_reg(index,32)
    case _: x188_reg(index,64)

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

def x188_datum_text(datum: P111QDatum) -> String:
  match datum:
    case P111QByte{value}: ".byte " ++ U32.show(value) ++ "\n"
    case P111QWord{value}: ".long " ++ U32.show(value) ++ "\n"
    case P111QLong{lo,hi}: ".quad " ++ p111q_u64(lo,hi) ++ "\n"
    case P111QReloc{symbol,offset}: ".quad " ++ symbol ++ "+" ++ U32.show(offset) ++ "\n"
    case P111QZeros{bytes}: ".zero " ++ U32.show(bytes) ++ "\n"

law w4_scalars_state:
  for ss: List<&2,N111Stmt>
  Bool

@unsafe
def w4_scalar_state(s: N111Stmt) -> Bool:
  match s:
    case N111Set{n,_,v}: agy_str_eq(n,"state") || w4_val_state(v)
    case N111Bin{n,_,_,l,r}: agy_str_eq(n,"state") || w4_val_state(l) || w4_val_state(r)
    case N111Offset{n,b,y}: agy_str_eq(n,"state") || w4_val_state(b) || w4_val_state(y)
    case N111Load{n,_,b,_}: agy_str_eq(n,"state") || w4_val_state(b)
    case N111Store{_,b,_,v}: w4_val_state(b) || w4_val_state(v)
    case N111Call{n,_,_,args}: agy_str_eq(n,"state") || w4_args_state(args)
    case N111Return{v}: w4_val_state(v)
    case N111If{c,yes,no}: w4_val_state(c) || w4_scalars_state(yes) || w4_scalars_state(no)
    case N111Alloca{n,_,_}: agy_str_eq(n,"state")

@unsafe
def w4_scalars_state(ss):
  match ss:
    case Nil{}: False{}
    case Con{h,t}: w4_scalar_state(h) || w4_scalars_state(t)

@unsafe
def x186_inline_op(stmt: N111Stmt) -> X186InlineOp:
  x186_inline_op_when(x185_float_enabled(),stmt)
# Exact ABI11102 U32.to_f32. The unchanged verifier proves a readable U64
# buffer cell and authenticated state/import signature. Reading the low32 as
# unsigned before signed64 conversion covers all U32 values, including bit31.
# MOVD to r10d clears the entire published upper word. No host FP computation
# or constant folding is involved. Other passes still treat this IR as a call.
law agy_reuse_nstmts_use:
  for +target: String
  for stmts: List<&2,N111Stmt>
  Bool

@unsafe
def agy_reuse_nstmt_uses(+target: String, stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Set{n,t,v}: agy_reuse_val_uses(target,v)
    case N111Bin{n,t,op,l,r}: agy_reuse_val_uses(target,l) || agy_reuse_val_uses(target,r)
    case N111Call{n,t,sym,args}: agy_reuse_args_use(target,args)
    case N111If{c,yes,no}: agy_reuse_val_uses(target,c) || agy_reuse_nstmts_use(target,yes) || agy_reuse_nstmts_use(target,no)
    case N111Return{v}: agy_reuse_val_uses(target,v)
    case N111Load{n,t,b,off}: agy_reuse_val_uses(target,b)
    case N111Store{t,b,off,v}: agy_reuse_val_uses(target,b) || agy_reuse_val_uses(target,v)
    case N111Offset{n,b,bytes}: agy_reuse_val_uses(target,b) || agy_reuse_val_uses(target,bytes)
    case N111Alloca{n,b,a}: False{}

@unsafe
def agy_reuse_nstmts_use(target,stmts):
  match stmts:
    case Nil{}: False{}
    case Con{s,rest}: agy_reuse_nstmt_uses(target,s) || agy_reuse_nstmts_use(target,rest)

@unsafe
def x186_call_mask(typ: N111Type, +reg: X187Operand) -> X188Seq:
  match typ:
    case N111U32{}: x188_i2("movl",reg,reg)
    case _: X188Empty{}

# kind 0 refuses a malformed placement, 1 uses direct loads, 2 snapshots.
@unsafe
def x186_call_place(+count: U32, +base: U32, +index: U32) -> X188Seq:
  nt_choose(X188Seq,U32.is_eq(index,count),u => X188Empty{},u =>
    x188_cat(nt_choose(X188Seq,U32.is_lt(index,6),
      v => x188_i2("movq",X187Mem{4,U32.add(base,U32.mul(index,8))},x181_argreg(index)),
      v => x188_cat(x188_i2("movq",X187Mem{4,U32.add(base,U32.mul(index,8))},x188_reg(10,64)),
        x188_i2("movq",x188_reg(10,64),X187Mem{4,U32.mul(U32.sub(index,6),8)}))),
      x186_call_place(count,base,U32.inc(index))))

@unsafe
def agy_call_other_reads(+reg: U32, +skipIdx: U32, moves: List<&2,AgyCallMove>) -> Bool:
  match moves:
    case Nil{}: False{}
    case Con{AgyCallMove{dstIdx,dstReg,srcReg,typ,value},rest}:
      (Bool.not(U32.is_eq(dstIdx,skipIdx)) && U32.is_eq(srcReg,reg)) || agy_call_other_reads(reg,skipIdx,rest)

@unsafe
def agy_call_rewrite_src(moves: List<&2,AgyCallMove>, +oldReg: U32, +newReg: U32) -> List<&2,AgyCallMove>:
  match moves:
    case Nil{}: []
    case Con{AgyCallMove{dstIdx,dstReg,+srcReg,typ,value},rest}:
      Con{AgyCallMove{dstIdx,dstReg,nt_choose(U32,U32.is_eq(srcReg,oldReg),u => newReg,u => srcReg),typ,value},
        agy_call_rewrite_src(rest,oldReg,newReg)}

@unsafe
def x181_width(typ: N111Type, wide: String, narrow: String) -> String:
  match typ:
    case N111U32{}: narrow
    case _: wide

@unsafe
def x181_mask(typ: N111Type, +reg32: X187Operand) -> X188Seq:
  match typ:
    case N111U32{}: x188_i2("movl",reg32,reg32)
    case _: X188Empty{}

@unsafe
def x185_late_accessors(rows: List<&2,N111Stmt>) -> List<&2,N111Stmt>:
  match rows:
    case Nil{}: []
    case Con{head,rest}: nt_append(N111Stmt,p112a_expand(3,head),x185_late_accessors(rest))

@unsafe
def x185_late_transport(expansion: P114TExpansion) -> List<&2,N111Stmt>:
  match expansion:
    case P114TExpansion{body,changed}: x185_late_accessors(body)

@unsafe
def w4_bf_scan_loads(+buf: String, +count: U32, body: List<&2,P113DStmt>, +mask: U32) -> U32:
  match body:
    case Con{P113DScalar{N111Load{+d,N111U64{},N111Local{+b},+off}},+rest}:
      nt_choose(U32,agy_str_eq(b,buf) && U32.is_eq(U32.mod(off,8),0) && U32.is_lt(U32.div(off,8),count),
        u => w4_bf_scan_loads(buf,count,rest,U32.or(mask,U32.shln(1,U32.to_nat(U32.div(off,8))))),
        u => nt_choose(U32,w4_bf_no_buf_load(buf,Con{P113DScalar{N111Load{d,N111U64{},N111Local{b},off}},rest}),u2 => mask,u2 => 255))
    case _:
      nt_choose(U32,w4_bf_no_buf_load(buf,body),u => mask,u => 255)

@unsafe
def w5_succ_args(+stmt: N111Stmt, +dest: String, +site: U32, args: List<&2,N111Arg>) -> P114TExpansion:
  match args:
    case Con{N111Arg{N111Ptr{},N111Local{+state}},
         Con{N111Arg{N111U32{},N111Const{4,0}},
         Con{N111Arg{N111Ptr{},N111Local{+buffer}},
         Con{N111Arg{N111U32{},N111Const{1,0}},Nil{}}}}}:
      nt_choose(P114TExpansion,agy_str_eq(state,"state") && Bool.not(agy_str_eq(buffer,"state")),
        u => P114TExpansion{[
          N111Load{p114t_name(site,"succ_in"),N111U64{},N111Local{buffer},0},
          N111Bin{p114t_name(site,"succ_ok"),N111U64{},"ult",p114t_local(site,"succ_in"),N111Const{4294967295,65535}},
          N111If{p114t_local(site,"succ_ok"),
            [N111Bin{dest,N111U64{},"add",p114t_local(site,"succ_in"),N111Const{1,0}}],
            [stmt]}],True{}},
        u => P114TExpansion{[stmt],False{}})
    case _: P114TExpansion{[stmt],False{}}

@unsafe
def w5_succ_expand(+stmt: N111Stmt, +site: U32) -> P114TExpansion:
  match stmt:
    case N111Call{+dest,N111U64{},+symbol,args}:
      nt_choose(P114TExpansion,agy_str_eq(symbol,"p111_rt_special_ctor"),
        u => w5_succ_args(stmt,dest,site,args),
        u => P114TExpansion{[stmt],False{}})
    case _: P114TExpansion{[stmt],False{}}

@unsafe
def w5b_match_succ_pair(+styp: N111Type, +sbuf: String, +sval: N111Value,
    +dest: String, +sym: String, +args: List<&2,N111Arg>, +site: U32) -> Maybe<&2,List<&2,P113DStmt>>:
  match args:
    case Con{N111Arg{N111Ptr{},N111Local{+state}},
         Con{N111Arg{N111U32{},N111Const{4,0}},
         Con{N111Arg{N111Ptr{},N111Local{+cbuf}},
         Con{N111Arg{N111U32{},N111Const{1,0}},Nil{}}}}}:
      nt_choose(Maybe<&2,List<&2,P113DStmt>>,
        agy_str_eq(sym,"p111_rt_special_ctor") && agy_str_eq(state,"state") &&
        agy_str_eq(sbuf,cbuf) && Bool.not(agy_str_eq(sbuf,"state")),
        u => Some{[
          P113DScalar{N111Bin{p114t_name(site,"succ_ok"),N111U64{},"ult",sval,N111Const{4294967295,65535}}},
          P113DIf{p114t_local(site,"succ_ok"),
            [P113DScalar{N111Bin{dest,N111U64{},"add",sval,N111Const{1,0}}}],
            [P113DScalar{N111Store{styp,N111Local{sbuf},0,sval}},
             P113DScalar{N111Call{dest,N111U64{},sym,args}}]}]},
        u => None{})
    case _: None{}

@unsafe
def w12_bf_rfc_rows(+site: U32, +heapVal: N111Value) -> List<&2,P113DStmt>:
  x181_scalar_rows([
    N111Bin{p114t_name(site,"borrow_header_bytes"),N111U64{},"shl",p114t_local(site,"borrow_location"),N111Const{3,0}},
    N111Offset{p114t_name(site,"borrow_header"),heapVal,p114t_local(site,"borrow_header_bytes")},
    N111Load{p114t_name(site,"borrow_header_word"),N111U64{},p114t_local(site,"borrow_header"),0},
    N111Bin{p114t_name(site,"borrow_location"),N111U64{},"shr",p114t_local(site,"borrow_header_word"),N111Const{24,0}}])

@unsafe
def w12_bf_fast_direct(+dest: String, +count: U32, +site: U32, +hasHeap: Bool,
    +loads: List<&2,N111Stmt>) -> List<&2,P113DStmt>:
  +heapVal : N111Value = nt_choose(N111Value,hasHeap,
    u => N111Local{"p114t_borrow_heap"},
    u => p114t_local(site,"borrow_heap"))
  +pre : List<&2,P113DStmt> = nt_choose(List<&2,P113DStmt>,hasHeap,
    u => [],
    u => [P113DScalar{N111Load{p114t_name(site,"borrow_heap"),N111Ptr{},N111Local{"state"},0}}])
  +mid : List<&2,P113DStmt> = [
    P113DScalar{N111Bin{p114t_name(site,"borrow_location"),N111U64{},"and",p114t_local(site,"borrow_word"),N111Const{4294967295,255}}},
    P113DScalar{N111Bin{p114t_name(site,"borrow_rfc_bit"),N111U64{},"shr",p114t_local(site,"borrow_word"),N111Const{63,0}}},
    P113DIf{p114t_local(site,"borrow_rfc_bit"),w12_bf_rfc_rows(site,heapVal),[]},
    P113DScalar{N111Bin{p114t_name(site,"borrow_field_bytes"),N111U64{},"shl",p114t_local(site,"borrow_location"),N111Const{3,0}}},
    P113DScalar{N111Offset{p114t_name(site,"borrow_fields"),heapVal,p114t_local(site,"borrow_field_bytes")}}]
  +post = nt_append(P113DStmt,w12_bf_direct_loads(loads,p114t_local(site,"borrow_fields")),
            [P113DScalar{N111Set{dest,N111U64{},N111Const{count,0}}}])
  nt_append(P113DStmt,pre,nt_append(P113DStmt,mid,post))

@unsafe
def x181_register_slot(+slot: KDef, register: U32) -> KDef:
  match slot:
    case KDef{name,kind,arity,bytes,typ,value,children,native,uns}:
      KDef{name,"X181Register",register,bytes,typ,value,children,native,uns}
    case _: slot

def x185_t_slot(slot: KDef, register: U32) -> KDef:
  match slot:
    case KDef{name,kind,arity,bytes,typ,value,children,native,uns}:
      KDef{name,"X185Transient",register,bytes,typ,value,children,native,uns}
    case _: slot

def x185_physical_callee(index: U32) -> X185Physical:
  match index:
    case 0: x188_physical(12)
    case 1: x188_physical(3)
    case 2: x188_physical(13)
    case 3: x188_physical(14)
    case _: x188_physical(15)

def x185_physical_transient(index: U32) -> X185Physical:
  match index:
    case 0: x188_physical(7)
    case 1: x188_physical(6)
    case 2: x188_physical(2)
    case 3: x188_physical(8)
    case 4: x188_physical(9)
    case _: x188_physical(1)

def x188_physical_width(typ: N111Type, wide: X187Operand, narrow: X187Operand) -> X187Operand:
  match typ:
    case N111U32{}: narrow
    case _: wide

def x185_sf_width(typ: N111Type) -> U32:
  match typ:
    case N111U32{}: 4
    case _: 8

@unsafe
def x185_sf_written(facts: List<&2,X185ScratchCell>, +name: String) -> List<&2,X185ScratchCell>:
  match facts:
    case Nil{}: []
    case Con{+cell,+rest}:
      match cell:
        case X185ScratchCell{buffer,offset,typ,value}:
          nt_choose(List<&2,X185ScratchCell>,x185_sf_source(value,name),
            u => x185_sf_written(rest,name),u => Con{cell,x185_sf_written(rest,name)})

@unsafe
def x185_sf_insert(cell: X185ScratchCell, +facts: List<&2,X185ScratchCell>) -> List<&2,X185ScratchCell>:
  nt_choose(List<&2,X185ScratchCell>,U32.is_lt(nt_count(X185ScratchCell,facts),16),
    u => Con{cell,facts},u => facts)

def x185_sf_loaded(stmt: N111Stmt, name: String, typ: N111Type, found: Maybe<&2,N111Value>) -> P113DStmt:
  match found:
    case None{}: P113DScalar{stmt}
    case Some{value}: P113DScalar{N111Set{name,typ,value}}

# A different fixed frame allocation cannot mutate remembered cells. Drop only
# facts for the declared identity or facts that captured its previous address.
@unsafe
def x186_sf_allocated(facts: List<&2,X185ScratchCell>, +name: String) -> List<&2,X185ScratchCell>:
  match facts:
    case Nil{}: []
    case Con{+cell,+rest}:
      match cell:
        case X185ScratchCell{buffer,offset,typ,value}:
          nt_choose(List<&2,X185ScratchCell>,agy_str_eq(buffer,name) || x185_sf_source(value,name),
            u => x186_sf_allocated(rest,name),u => Con{cell,x186_sf_allocated(rest,name)})

law x186_saves_tree:
  for slots: KDef
  U32

@unsafe
def x186_saves_bucket(slots: List<&2,KDef>) -> U32:
  match slots:
    case Nil{}: 0
    case Con{head,rest}: U32.or(x186_saves_tree(head),x186_saves_bucket(rest))

@unsafe
def x186_saves_tree(slots):
  match slots:
    case KIndexLeaf{hash,bucket}: x186_saves_bucket(bucket)
    case KIndexNode{hash,mask,left,right}: U32.or(x186_saves_tree(left),x186_saves_tree(right))
    case KDef{name,+kind,+reg,bytes,typ,value,children,native,uns}:
      nt_choose(U32,agy_str_eq(kind,"X181Register"),
        u => nt_choose(U32,U32.is_lt(reg,5),v => U32.shln(1,U32.to_nat(reg)),v => 31),u =>
          nt_choose(U32,agy_str_eq(kind,"X181Stack") || agy_str_eq(kind,"X181Buffer") ||
            agy_str_eq(kind,"X185Transient") || agy_str_eq(kind,"X186SavedMask") ||
            agy_str_eq(kind,"X181UnusedState") || agy_str_eq(kind,"Absent"),
            v => 0,v => 31))
    case _: 0

@unsafe
def x186_saves_text(+mask: U32, +reg: U32, +restore: Bool) -> X188Seq:
  nt_choose(X188Seq,U32.is_ge(reg,5),u => X188Empty{},u =>
    x188_cat(nt_choose(X188Seq,U32.is_eq(U32.and(mask,U32.shln(1,U32.to_nat(reg))),0),v => X188Empty{},v =>
      nt_choose(X188Seq,restore,
        w => x188_i2("movq",X187Mem{5,U32.sub(0,x186_saves_offset(reg))},x181_reg(reg)),
        w => x188_i2("movq",x181_reg(reg),X187Mem{5,U32.sub(0,x186_saves_offset(reg))}))),
      x186_saves_text(mask,U32.inc(reg),restore)))
# Globally unobserved cells of private fixed frame buffers. Any use of a buffer
# address outside direct bounded loads/stores (or the exact inline-F32 summary)
# excludes that whole buffer. Read footprints include setup and every branch,
# so no control-flow or loop-carried memory assumption is needed.
@unsafe
def w5b_ft_ins_leaf(+mask: U32, +trie: X186FactTrie, +item: X186Expr, +h: U32, +stored: U32, items: List<&2,X186Expr>) -> X186FactTrie:
  match mask:
    case 0: X186FTLeaf{h,Con{item,items}}
    case _: x186_ft_join(trie,item,h,stored,mask)

@unsafe
def w5b_at_ins_leaf(+mask: U32, +trie: X186AliasTrie, +item: X186Alias, +h: U32, +stored: U32, items: List<&2,X186Alias>) -> X186AliasTrie:
  match mask:
    case 0: X186ATLeaf{h,Con{item,items}}
    case _: x186_at_join(trie,item,h,stored,mask)

@unsafe
def x186_e_alias_t(aliasTrie: X186AliasTrie, +name: String) -> N111Value:
  x186_e_alias(x186_at_find(aliasTrie,index_hash(name,2166136261)),name)

law x186_e_kill_facts:
  for facts: List<&2,X186Expr>
  for +name: String
  List<&2,X186Expr>

@unsafe
def w5_kill_fact_if(drop: Bool, fact: X186Expr, rest: List<&2,X186Expr>, +name: String) -> List<&2,X186Expr>:
  match drop:
    case True{}: x186_e_kill_facts(rest,name)
    case False{}: Con{fact,x186_e_kill_facts(rest,name)}

@unsafe
def x186_e_kill_facts(facts, name):
  match facts:
    case Nil{}: []
    case Con{+fact,+rest}:
      match fact:
        case X186Expr{result,kind,typ,op,left,right}:
          w5_kill_fact_if(String.eq(result,name) || x185_sf_source(left,name) || x185_sf_source(right,name),fact,rest,name)

@unsafe
def w5b_at_prune(trie: X186AliasTrie, +name: String) -> X186AliasTrie:
  match trie:
    case X186ATNil{}: X186ATNil{}
    case X186ATLeaf{stored,items}: w5b_at_leaf_wrap(stored,x186_e_kill_aliases(items,name))
    case X186ATNode{stored,split,l,r}: w5b_at_node(stored,split,w5b_at_prune(l,name),w5b_at_prune(r,name))

@unsafe
def x186_e_result_type(+kind: U32, typ: N111Type, op: String) -> N111Type:
  nt_choose(N111Type,U32.is_eq(kind,1),u => N111Ptr{},
    u => nt_choose(N111Type,p111v_comparison(op),v => N111U32{},v => typ))

@unsafe
def w5_sel_last(s: W5Sel) -> W4CLastDst:
  match s:
    case W5Sel{_,dst,typ,_,_}: W4CLast{dst,typ}
    case W5SelNone{}: W4CLastNone{}

@unsafe
def w5_sel_rename(s: W5Sel, +newDst: String, orig: P113DStmt) -> P113DStmt:
  match s:
    case W5Sel{c,_,+typ,va,vb}:
      P113DIf{c,[P113DScalar{N111Set{newDst,typ,va}}],[P113DScalar{N111Set{newDst,typ,vb}}]}
    case W5SelNone{}: orig

law w5_elim_nat_fail:
  for body: List<&2,P113DStmt>
  List<&2,P113DStmt>

@unsafe
def w5_elim_nf_pair(+s1: P113DStmt, +c1: String, +x: String, s2: P113DStmt, +rest: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  match s2:
    case P113DIf{+cond,+yes,+no}:
      nt_choose(List<&2,P113DStmt>,Bool.not(String.is_empty(x)) && Bool.not(agy_str_eq(c1,x)) && w5_val_eq_name(cond,c1),
        u => Con{s1,Con{P113DIf{cond,w5_elim_nat_fail(yes),w5_elim_nat_fail(w5_unwrap_ne0(no,x))},w5_elim_nat_fail(rest)}},
        u => Con{s1,Con{P113DIf{cond,w5_elim_nat_fail(yes),w5_elim_nat_fail(no)},w5_elim_nat_fail(rest)}})
    case _: Con{s1,w5_elim_nat_fail(Con{s2,rest})}

@unsafe
def w5_elim_nat_fail(body):
  match body:
    case Nil{}: []
    case Con{P113DScalar{N111Bin{+c1,+t1,+op1,+l1,+r1}},Con{+s2,+rest}}:
      +s1 : P113DStmt = P113DScalar{N111Bin{c1,t1,op1,l1,r1}}
      w5_elim_nf_pair(s1,c1,w5_is_cmp0_local(op1,"eq",l1,r1),s2,rest)
    case Con{P113DIf{cond,yes,no},rest}:
      Con{P113DIf{cond,w5_elim_nat_fail(yes),w5_elim_nat_fail(no)},w5_elim_nat_fail(rest)}
    case Con{h,rest}: Con{h,w5_elim_nat_fail(rest)}

# Zero-temp Nat-match chain lowering:
# Turns nested `eq(x,0) -> dst=v0; x1=sub(x,1); eq(x1,0) -> dst=v1; ...; dst=vN`
# into `dst=vN; c=eq(x,N-1); if c dst=v_{N-1} else dst=dst; ...; c=eq(x,0); if c dst=v0 else dst=dst`.
@unsafe
def x190_v_value(value: N111Value, state: X190Values) -> N111Value:
  match state:
    case X190Values{aliases,widths}: x186_e_value(value,aliases)

@unsafe
def x190_v_alias(+name: String, +value: N111Value, state: X190Values) -> X190Values:
  match state:
    case X190Values{+aliases,widths}:
      X190Values{nt_choose(List<&2,X186Alias>,Bool.not(x185_sf_source(value,name)) && U32.is_lt(nt_count(X186Alias,aliases),32),
        u => Con{X186Alias{name,value},aliases},u => aliases),widths}

@unsafe
def w5b_split_trailing_sets(body: List<&2,P113DStmt>) -> W5BSplitSets:
  w5b_take_sets_rev(nt_reverse(P113DStmt,body,[]),[])

@unsafe
def w2_args_reads(+name: String, args: List<&2,N111Arg>) -> Bool:
  match args:
    case Nil{}: False{}
    case Con{N111Arg{typ,v},rest}: w2_val_reads(name,v) || w2_args_reads(name,rest)

law w2b_strip_true_check:
  for nodes: List<&2,X186FloatNode>
  for +word: N111Value
  List<&2,X186FloatNode>

@unsafe
def w2b_strip_true_check(nodes,word):
  match nodes:
    case Con{X186FloatPlain{P113DScalar{N111Bin{b1,t1,op1,+w1,N111Const{40,0}}}},
         Con{X186FloatPlain{P113DScalar{N111Bin{b2,t2,op2,N111Local{b1b},N111Const{8388607,0}}}},
         Con{X186FloatPlain{P113DScalar{N111Bin{bx,t3,op3,N111Local{b2b},N111Local{ex}}}},
         Con{X186FloatPlain{P113DScalar{N111Bin{mc,t4,op4,N111Local{raw},N111Local{bxb}}}},
         Con{X186FloatBranch{N111Local{mcb},+yes2,no2},+tail2}}}}}:
      nt_choose(List<&2,X186FloatNode>,
        agy_str_eq(b1,"p112_b_bits") && agy_str_eq(op1,"shr") && w2_val_eq(w1,word) &&
        agy_str_eq(b2,"p112_b_bits") && agy_str_eq(op2,"and") && agy_str_eq(b1b,"p112_b_bits") &&
        agy_str_eq(bx,"p112_b_boxed") && agy_str_eq(op3,"eq") && agy_str_eq(b2b,"p112_b_bits") && agy_str_eq(ex,"p112_b_expected") &&
        agy_str_eq(mc,"match_condition") && agy_str_eq(op4,"or") && agy_str_eq(raw,"p112_b_raw") && agy_str_eq(bxb,"p112_b_boxed") &&
        agy_str_eq(mcb,"match_condition"),
        u => nt_append(X186FloatNode,yes2,tail2),
        u => nodes)
    case Con{X186FloatPlain{P113DScalar{N111Set{s1,ts1,N111Local{s1b}}}},+more}:
      nt_choose(List<&2,X186FloatNode>,agy_str_eq(s1,"p112_b_raw") && agy_str_eq(s1b,"p112_b_raw"),
        u => w2b_strip_true_check(more,word),
        u => nodes)
    case _: nodes

law w2_xl_safe_nodes:
  for nodes: List<&2,X186FloatNode>
  Bool

@unsafe
def w2_xl_safe_nodes(nodes):
  match nodes:
    case Nil{}: True{}
    case Con{X186FloatPlain{s},rest}: w2_xl_safe_stmt(s) && w2_xl_safe_nodes(rest)
    case Con{X186FloatBranch{c,y,n},rest}: w2_xl_safe_nodes(y) && w2_xl_safe_nodes(n) && w2_xl_safe_nodes(rest)
    case Con{X186FloatValues{d,id,l,r},rest}: w2_xl_safe_nodes(rest)

law w2_xl_param_inv:
  for +name: String
  for +idx: U32
  for nodes: List<&2,X186FloatNode>
  Bool

@unsafe
def w2_xl_param_inv(name,idx,nodes):
  match nodes:
    case Nil{}: True{}
    case Con{X186FloatValues{dest,id,l,r},rest}:
      Bool.not(agy_str_eq(dest,name)) && w2_xl_param_inv(name,idx,rest)
    case Con{X186FloatBranch{c,y,n},rest}:
      w2_xl_param_inv(name,idx,y) && w2_xl_param_inv(name,idx,n) && w2_xl_param_inv(name,idx,rest)
    case Con{X186FloatPlain{P113DAgain{vals}},rest}:
      w2_xl_same_local(w2_xl_nth(vals,idx),name) && w2_xl_param_inv(name,idx,rest)
    case Con{X186FloatPlain{stmt},rest}:
      Bool.not(w2_dstmt_writes(name,stmt)) && w2_xl_param_inv(name,idx,rest)

law w2_xl_param_nowrite:
  for +name: String
  for nodes: List<&2,X186FloatNode>
  Bool

@unsafe
def w2_xl_param_nowrite(name,nodes):
  match nodes:
    case Nil{}: True{}
    case Con{X186FloatValues{dest,id,l,r},rest}:
      Bool.not(agy_str_eq(dest,name)) && w2_xl_param_nowrite(name,rest)
    case Con{X186FloatBranch{c,y,n},rest}:
      w2_xl_param_nowrite(name,y) && w2_xl_param_nowrite(name,n) && w2_xl_param_nowrite(name,rest)
    case Con{X186FloatPlain{stmt},rest}:
      Bool.not(w2_dstmt_writes(name,stmt)) && w2_xl_param_nowrite(name,rest)

law w2_xl_consts:
  for nodes: List<&2,X186FloatNode>
  for +acc: List<&2,U32>
  List<&2,U32>

@unsafe
def w2_xl_consts(nodes,acc):
  match nodes:
    case Nil{}: acc
    case Con{X186FloatValues{dest,+id,l,r},+rest}:
      nt_choose(List<&2,U32>,U32.is_eq(id,23),
        u => w2_xl_consts(rest,acc),
        u => w2_xl_consts(rest,w2_xl_add_const(r,w2_xl_add_const(l,acc))))
    case Con{X186FloatBranch{c,y,n},rest}:
      w2_xl_consts(rest,w2_xl_consts(n,w2_xl_consts(y,acc)))
    case Con{h,rest}: w2_xl_consts(rest,acc)

law w4_xl_again_indep:
  for +self: String
  for +idx: U32
  for +tparams: List<&2,String>
  for nodes: List<&2,X186FloatNode>
  Bool

@unsafe
def w4_xl_again_indep(self,idx,tparams,nodes):
  match nodes:
    case Nil{}: True{}
    case Con{X186FloatPlain{P113DAgain{vals}},rest}:
      w4_xl_val_not_other_param(w2_xl_nth(vals,idx),self,tparams) && w4_xl_again_indep(self,idx,tparams,rest)
    case Con{X186FloatBranch{c,y,n},rest}:
      w4_xl_again_indep(self,idx,tparams,y) && w4_xl_again_indep(self,idx,tparams,n) && w4_xl_again_indep(self,idx,tparams,rest)
    case Con{h,rest}: w4_xl_again_indep(self,idx,tparams,rest)

law w4b_xl_hot_consts:
  for nodes: List<&2,X186FloatNode>
  for +acc: List<&2,U32>
  List<&2,U32>

@unsafe
def w4b_xl_hot_consts(nodes,acc):
  match nodes:
    case Nil{}: acc
    case Con{X186FloatValues{dest,+id,l,r},+rest}:
      nt_choose(List<&2,U32>,U32.is_eq(id,23),
        u => w4b_xl_hot_consts(rest,acc),
        u => w4b_xl_hot_consts(rest,w2_xl_add_const(r,w2_xl_add_const(l,acc))))
    case Con{X186FloatBranch{c,+y,+n},+rest}:
      +inRest = w2_xl_has_again(rest)
      +acc1 = nt_choose(List<&2,U32>,inRest || w2_xl_has_again(y),u => w4b_xl_hot_consts(y,acc),u => acc)
      +acc2 = nt_choose(List<&2,U32>,inRest || w2_xl_has_again(n),u => w4b_xl_hot_consts(n,acc1),u => acc1)
      w4b_xl_hot_consts(rest,acc2)
    case Con{h,rest}: w4b_xl_hot_consts(rest,acc)

@unsafe
def x194fv_clean_values(values: List<&2,N111Value>) -> Bool:
  match values:
    case Nil{}: True{}
    case Con{value,rest}: x194fv_clean_value(value) && x194fv_clean_values(rest)

@unsafe
def x194fv_clean_args(args: List<&2,N111Arg>) -> Bool:
  match args:
    case Nil{}: True{}
    case Con{N111Arg{typ,value},rest}: x194fv_clean_value(value) && x194fv_clean_args(rest)

@unsafe
def w2_fc_eval_unary(+id: U32, +a: U32) -> Maybe<&2,U32>:
  nt_choose(Maybe<&2,U32>,U32.is_eq(id,23),u => Some{F32.bits(U32.to_f32(a))},u =>
    nt_choose(Maybe<&2,U32>,U32.is_eq(id,36),
      v => nt_choose(Maybe<&2,U32>,j_private_float_finite(a) && U32.is_lt(a,2147483648),
        w => w2_fc_finite_some(F32.bits(F32.sqrt(p126s_float(a)))),w => None{}),
      v => nt_choose(Maybe<&2,U32>,U32.is_eq(id,58),
        w => nt_choose(Maybe<&2,U32>,U32.is_lt(a,1333788672),
          z => Some{F32.to_u32(p126s_float(a))},z => Some{0}),
        w => None{})))

@unsafe
def w2_fc_eval_bin(+id: U32, +a: U32, +b: U32) -> Maybe<&2,U32>:
  nt_choose(Maybe<&2,U32>,j_private_float_finite(a) && j_private_float_finite(b),
    u => nt_choose(Maybe<&2,U32>,U32.is_eq(id,26),v => w2_fc_finite_some(F32.bits(F32.add(p126s_float(a),p126s_float(b)))),
      v => nt_choose(Maybe<&2,U32>,U32.is_eq(id,27),w => w2_fc_finite_some(F32.bits(F32.sub(p126s_float(a),p126s_float(b)))),
      w => nt_choose(Maybe<&2,U32>,U32.is_eq(id,28),z => w2_fc_finite_some(F32.bits(F32.mul(p126s_float(a),p126s_float(b)))),
      z => nt_choose(Maybe<&2,U32>,U32.is_eq(id,29) && Bool.not(U32.is_eq(U32.and(b,2147483647),0)),
        q => w2_fc_finite_some(F32.bits(F32.div(p126s_float(a),p126s_float(b)))),q => None{})))),
    u => None{})

@unsafe
def w2_fc_try_fold(+id: U32, +left: N111Value, +right: N111Value) -> Maybe<&2,U32>:
  match left right:
    case N111Const{a,0} N111Const{b,0}:
      nt_choose(Maybe<&2,U32>,x200r_float_unary(id),u => w2_fc_eval_unary(id,a),u => w2_fc_eval_bin(id,a,b))
    case N111Const{a,0} _:
      nt_choose(Maybe<&2,U32>,x200r_float_unary(id),u => w2_fc_eval_unary(id,a),u => None{})
    case _ _: None{}

law x190_l_safe_body:
  for body: List<&2,P113DStmt>
  Bool

# The whitelist follows the scalar selector, including its implicit scratch
# rcx for variable shifts. A multiplication is two-operand imul; division is
# not admitted. The shared inline F32 contract avoids conservative call-clobber marking.
@unsafe
def x190_l_safe_scalar(stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Set{name,typ,value}: True{}
    case N111Bin{name,typ,+op,left,right}:
      Bool.not(String.is_empty(x181_alu(op))) || Bool.not(String.is_empty(x181_condition(op)))
    case N111Load{name,typ,base,offset}: True{}
    case N111Store{typ,base,offset,value}: True{}
    case N111Offset{name,base,bytes}: True{}
    case N111Alloca{name,bytes,align}: True{}
    case N111Return{value}: True{}
    case N111If{condition,yes,no}: x190_l_safe_body(x181_scalar_rows(yes)) && x190_l_safe_body(x181_scalar_rows(no))
    case N111Call{name,typ,symbol,args}: True{}

@unsafe
def x190_l_safe_body(body):
  match body:
    case Nil{}: True{}
    case Con{P113DScalar{stmt},rest}: x190_l_safe_scalar(stmt) && x190_l_safe_body(rest)
    case Con{P113DIf{condition,yes,no},rest}: x190_l_safe_body(yes) && x190_l_safe_body(no) && x190_l_safe_body(rest)
    case Con{P113DCall{names,target,args},rest}: x190_l_safe_body(rest)
    case Con{head,rest}: x190_l_safe_body(rest)

@unsafe
def w5b_l_edges_go(rows: List<&2,U32>, +bit: U32, +before: U32, +after: U32, +writes: U32, +aw: U32, +any: U32) -> List<&2,U32>:
  match rows:
    case Nil{}: []
    case Con{old,rest}:
      Con{w5b_l_edges_row(U32.and(bit,any),old,bit,before,after,writes,aw),
        w5b_l_edges_go(rest,U32.shl(bit),before,after,writes,aw,any)}

@unsafe
def w5b_l_edges_start(+any: U32, rows: List<&2,U32>, +bit: U32, +before: U32, +after: U32, +writes: U32, +aw: U32) -> List<&2,U32>:
  match any:
    case 0: rows
    case _: w5b_l_edges_go(rows,bit,before,after,writes,aw,any)

@unsafe
def x190_l_color(names: List<&2,String>, rows: List<&2,U32>, +params: List<&2,String>,
    +bit: U32, +groups: List<&2,U32>) -> List<&2,U32>:
  match names rows:
    case Con{name,rest} Con{+edges,more}:
      x190_l_color(rest,more,params,U32.shl(bit),
        nt_choose(List<&2,U32>,U32.is_eq(U32.and(bit,edges),0),
          u => x190_l_group(groups,x190_l_pick(groups,edges,x190_l_position(name,params,0),0),bit),u => groups))
    case _ _: groups

# A separate post-color check rejects location conflicts, duplicate group
# membership and incoming ABI violations before changing any frame slot.
@unsafe
def x190_l_valid(names: List<&2,String>, rows: List<&2,U32>, +params: List<&2,String>,
    +bit: U32, +groups: List<&2,U32>) -> Bool:
  match names rows:
    case Nil{} Nil{}: True{}
    case Con{name,rest} Con{edges,more}:
      x190_l_valid_groups(groups,bit,edges,x190_l_position(name,params,0),0,False{}) &&
        x190_l_valid(rest,more,params,U32.shl(bit),groups)
    case _ _: False{}

@unsafe
def x190_j_pick(groups: List<&2,U32>, +bit: U32, +edges: U32, +position: U32, +color: U32, +nParams: U32) -> U32:
  match groups:
    case Nil{}: 9
    case Con{mask,rest}:
      nt_choose(U32,x190_j_allowed(bit,edges,position,color,nParams) &&
          U32.is_eq(U32.and(mask,x190_j_edges(bit,edges,color)),0),
        u => color,u => x190_j_pick(rest,bit,edges,position,U32.inc(color),nParams))

@unsafe
def x190_j_choose(+groups: List<&2,U32>, +bit: U32, +edges: U32, +position: U32, enabled: Bool, +nParams: U32) -> U32:
  +caller = nt_choose(U32,enabled,u => x190_j_pick(x190_j_callers(groups),bit,edges,position,4,nParams),u => 9)
  nt_choose(U32,U32.is_lt(caller,9),u => caller,u => x190_j_pick(groups,bit,edges,position,0,nParams))

@unsafe
def x190_a_pick(groups: List<&2,U32>, +partners: U32, +bit: U32, +edges: U32, +position: U32, +color: U32, +nParams: U32) -> U32:
  match groups:
    case Nil{}: 9
    case Con{+mask,rest}:
      nt_choose(U32,Bool.not(U32.is_eq(U32.and(mask,partners),0)) && x190_j_allowed(bit,edges,position,color,nParams) &&
          U32.is_eq(U32.and(mask,x190_j_edges(bit,edges,color)),0),
        u => color,u => x190_a_pick(rest,partners,bit,edges,position,U32.inc(color),nParams))

@unsafe
def x190_j_valid_groups(groups: List<&2,U32>, +bit: U32, +edges: U32,
    +position: U32, +color: U32, +seen: Bool, +nParams: U32) -> Bool:
  match groups:
    case Nil{}: True{}
    case Con{+mask,rest}:
      +here = Bool.not(U32.is_eq(U32.and(mask,bit),0))
      (Bool.not(here) || (Bool.not(seen) && x190_j_allowed(bit,edges,position,color,nParams) &&
        U32.is_eq(U32.and(mask,x190_j_edges(bit,edges,color)),0))) &&
          x190_j_valid_groups(rest,bit,edges,position,U32.inc(color),seen || here,nParams)

@unsafe
def x190_j_valid(names: List<&2,String>, rows: List<&2,U32>, +params: List<&2,String>,
    +bit: U32, +groups: List<&2,U32>) -> Bool:
  match names rows:
    case Nil{} Nil{}: U32.is_eq(nt_count(U32,groups),9)
    case Con{name,rest} Con{edges,more}:
      x190_j_valid_groups(groups,bit,edges,x190_l_position(name,params,0),0,False{},nt_count(String,params)) &&
        x190_j_valid(rest,more,params,U32.shl(bit),groups)
    case _ _: False{}

@unsafe
def w12g_body_var_shift(xs: List<&2,P113DStmt>) -> Bool:
  match xs:
    case Nil{}: False{}
    case Con{P113DScalar{sc},t}: w12g_scalar_var_shift(sc) || w12g_body_var_shift(t)
    case Con{P113DIf{_,yes,no},t}: w12g_body_var_shift(yes) || w12g_body_var_shift(no) || w12g_body_var_shift(t)
    case Con{_,t}: w12g_body_var_shift(t)

def x190_branch_width(typ: N111Type) -> Bool:
  match typ:
    case N111U32{}: True{}
    case N111U64{}: True{}
    case _: False{}

@unsafe
def x190_branch_append(+chosen: List<&2,P113DStmt>, rest: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  nt_choose(List<&2,P113DStmt>,x190_branch_terminal(chosen),u => chosen,u => nt_append(P113DStmt,chosen,rest))

# An arm begins immediately after the outer comparison. Exact typed operands
# have not changed, so an identical/complementary inner predicate is known.
# The inner Boolean may disappear only under the same global read certificate.
# This helper inspects one arm head and never recursively simplifies its result.
@unsafe
def x198h_finish(body: List<&2,P113DStmt>, +dest: String, +fid: String) -> Bool:
  match body:
    case [P113DScalar{N111Store{N111U32{},N111Local{+s1},28,N111Const{0,0}}},
          P113DScalar{N111Store{N111U32{},N111Local{+s2},32,N111FuncId{+target}}},
          P113DScalar{N111Set{+name,N111U64{},N111Const{0,0}}}]:
      agy_str_eq(s1,"state") && agy_str_eq(s2,"state") && agy_str_eq(target,fid) && agy_str_eq(name,dest)
    case Con{P113DScalar{N111Load{name,typ,base,offset}},rest}: x198h_finish(rest,dest,fid)
    case Con{P113DScalar{N111Store{typ,base,offset,value}},rest}: x198h_finish(rest,dest,fid)
    case _: False{}

@unsafe
def w12_i_st_if(body: List<&2,P113DStmt>, +orig: List<&2,P113DStmt>, +mc: String) -> List<&2,P113DStmt>:
  match body:
    case Con{P113DIf{N111Local{mcb},+yes2,no2},+tail2}:
      nt_choose(List<&2,P113DStmt>,agy_str_eq(mcb,mc),u => x190_branch_append(yes2,tail2),u => orig)
    case _: orig

@unsafe
def x191_alu_left(+name: String, +op: String, +left: N111Value, +right: N111Value) -> Maybe<&2,N111Value>:
  nt_choose(Maybe<&2,N111Value>,x185_sf_source(right,name) && Bool.not(x185_sf_source(left,name)),
    u => Some{left},u => nt_choose(Maybe<&2,N111Value>,x191_commutative(op) &&
      x185_sf_source(left,name) && Bool.not(x185_sf_source(right,name)),u => Some{right},u => None{}))

@unsafe
def x191_alu_found(found: Maybe<&2,N111Value>, rest: List<&2,P113DStmt>, name: String,
    typ: N111Type, op: String, address: X191Address) -> Maybe<&2,X191Pick>:
  match found:
    case Some{left}: Some{X191Pick{rest,X191MemoryAlu{name,typ,op,left,address}}}
    case None{}: None{}

# The load moves only across its immediately following ALU. No stores, calls,
# branches or other observable effects are crossed. Widths agree exactly.
@unsafe
def x191_load_chosen(fused: Maybe<&2,X191Pick>, rest: List<&2,P113DStmt>, name: String,
    typ: N111Type, address: X191Address) -> Maybe<&2,X191Pick>:
  match fused:
    case Some{pick}: Some{pick}
    case None{}: Some{X191Pick{rest,X191Load{name,typ,address}}}

@unsafe
def x191_rows(operation: X191Operation) -> List<&2,P113DStmt>:
  match operation:
    case X191Load{name,typ,X191Address{base,index,scale,disp}}:
      [P113DScalar{N111Bin{name,typ,"add",base,index}}]
    case X191Store{typ,+address,value}:
      match address:
        case X191Address{base,index,scale,disp}:
          nt_append(P113DStmt,x191_reads(address),[P113DScalar{N111Store{typ,base,0,value}}])
    case X191MemoryAlu{name,typ,op,left,+address}:
      match address:
        case X191Address{base,index,scale,disp}:
          nt_append(P113DStmt,x191_reads(address),[P113DScalar{N111Bin{name,typ,op,left,base}}])

@unsafe
def x192_address_write(+name: String, scaled: String, index: N111Value,
    aliases: List<&2,X192AddressAlias>) -> Bool:
  Bool.not(agy_str_eq(name,scaled) || x185_sf_source(index,name) || x192_address_writes_alias(aliases,name))

@unsafe
def x192_address_fuse_left(left: Maybe<&2,N111Value>, +load: X191Operation,
    +stmt: P113DStmt, name: String, typ: N111Type, op: String, address: X191Address,
    rest: List<&2,X192AddressRow>) -> List<&2,X192AddressRow>:
  match left:
    case Some{value}: Con{X192AddressMemory{X191MemoryAlu{name,typ,op,value,address}},rest}
    case None{}: Con{X192AddressMemory{load},Con{X192AddressPlain{stmt},rest}}

@unsafe
def w4_qm_dividend(+arg: U32, +rest: List<&2,X188Seq>) -> W4QMDividend:
  match rest:
    case Con{s0,Con{l0,Con{a0,rest2}}}:
      nt_choose(W4QMDividend,w4_qm_store0_r11(s0) && U32.is_eq(x198qm_lea(a0,10),arg),
        u => w4_qm_pick_load0(w4_qm_load0_src(l0),arg,rest,rest2),
        u => nt_choose(W4QMDividend,U32.is_eq(x198qm_lea(l0,10),arg),
          v => w4_qm_pick_load0(w4_qm_store0_direct(s0),arg,rest,Con{a0,rest2}),
          v => W4QMDividend{X187Mem{5,arg},rest}))
    case Con{s0,Con{a0,rest2}}:
      nt_choose(W4QMDividend,U32.is_eq(x198qm_lea(a0,10),arg),
        u => w4_qm_pick_load0(w4_qm_store0_direct(s0),arg,rest,rest2),
        u => W4QMDividend{X187Mem{5,arg},rest})
    case _: W4QMDividend{X187Mem{5,arg},rest}

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
def w4_peep_flags_dead_list(items: List<&2,X187Parsed>, +budget: U32) -> Bool:
  match items:
    case Nil{}: True{}
    case Con{PLabel{_},_}: True{}
    case Con{PInst{X187Instruction{+op,_}},rest}:
      nt_choose(Bool,U32.is_eq(budget,0),u => False{},u =>
        nt_choose(Bool,w4_peep_flags_kill_op(op),v => True{},v =>
          nt_choose(Bool,w4_peep_flags_pass_op(op),w => w4_peep_flags_dead_list(rest,U32.sub(budget,1)),w => False{})))
    case _: False{}

@unsafe
def w4_leaf_parse_prologue(items: List<&2,X187Parsed>, +prefix: List<&2,X187Parsed>) -> W4LeafPrologue:
  match items:
    case Con{PInst{X187Instruction{p1,[X187Reg{5,64,False{}}]}},
         Con{PInst{X187Instruction{p2,[X187Reg{4,64,False{}},X187Reg{5,64,False{}}]}},
         Con{PInst{X187Instruction{p3,[X187Imm{_,0},X187Reg{4,64,False{}}]}},rest}}}:
      nt_choose(W4LeafPrologue,agy_str_eq(p1,"pushq") && agy_str_eq(p2,"movq") && agy_str_eq(p3,"subq"),
        u => w4_leaf_collect_saves(rest,nt_reverse(X187Parsed,prefix,[]),[]),
        u => W4LeafNone{})
    case Con{PLabel{l},rest}: w4_leaf_parse_prologue(rest,Con{PLabel{l},prefix})
    case Con{PSection{s},rest}: w4_leaf_parse_prologue(rest,Con{PSection{s},prefix})
    case Con{PGlobal{g},rest}: w4_leaf_parse_prologue(rest,Con{PGlobal{g},prefix})
    case Con{PType{t,k},rest}: w4_leaf_parse_prologue(rest,Con{PType{t,k},prefix})
    case _: W4LeafNone{}

law w4_leaf_rewrite:
  for items: List<&2,X187Parsed>
  for +saved: List<&2,U32>
  for +epilogue: X188Seq
  for +out: List<&2,X188Seq>
  Maybe<&2,List<&2,X188Seq>>

@unsafe
def w4_leaf_rewrite_item(items: List<&2,X187Parsed>, +saved: List<&2,U32>, +epilogue: X188Seq, +out: List<&2,X188Seq>) -> Maybe<&2,List<&2,X188Seq>>:
  match items:
    case Nil{}: Some{out}
    case Con{PInst{X187Instruction{+op,+args}},rest}:
      nt_choose(Maybe<&2,List<&2,X188Seq>>,agy_str_eq(op,"call") || agy_str_eq(op,"ret") || w4_leaf_args_bad(args),
        u => None{},
        u => w4_leaf_rewrite(rest,saved,epilogue,Con{X188One{PInst{X187Instruction{op,args}}},out}))
    case Con{h,rest}: w4_leaf_rewrite(rest,saved,epilogue,Con{X188One{h},out})

@unsafe
def w4_leaf_rewrite_step(matched: Maybe<&2,List<&2,X187Parsed>>, items: List<&2,X187Parsed>,
    +saved: List<&2,U32>, +epilogue: X188Seq, +out: List<&2,X188Seq>) -> Maybe<&2,List<&2,X188Seq>>:
  match matched:
    case Some{rest}: w4_leaf_rewrite(rest,saved,epilogue,Con{epilogue,out})
    case None{}: w4_leaf_rewrite_item(items,saved,epilogue,out)

@unsafe
def w4_leaf_rewrite(items,saved,epilogue,out):
  match items:
    case Nil{}: Some{out}
    case Con{+h,+t}: w4_leaf_rewrite_step(w4_leaf_match_restores(saved,Con{h,t}),Con{h,t},saved,epilogue,out)

@unsafe
def w4_leaf_finish(res: Maybe<&2,List<&2,X188Seq>>, original: X188Seq) -> X188Seq:
  match res:
    case Some{out}: x188_finish(out)
    case None{}: original

@unsafe
def w4_leaf_item_uses_r12(h: X187Parsed) -> Bool:
  match h:
    case PInst{X187Instruction{_,args}}: w4_leaf_args_use_r12(args)
    case _: False{}

@unsafe
def w4_leaf_body_uses_r12(items: List<&2,X187Parsed>) -> Bool:
  match items:
    case Nil{}: False{}
    case Con{+h,+rest}:
      nt_choose(Bool,w4_leaf_is_r12_init(h) || w4_leaf_is_r12_restore(h),
        u => w4_leaf_body_uses_r12(rest),
        u => w4_leaf_item_uses_r12(h) || w4_leaf_body_uses_r12(rest))

law w5c_lbl_find:
  for trie: W5BLblTrie
  for +lbl: String
  for +h: U32
  Maybe<&2,List<&2,X187Parsed>>

@unsafe
def w5c_lbl_find_br(bit: U32, l: W5BLblTrie, r: W5BLblTrie, +lbl: String, +h: U32) -> Maybe<&2,List<&2,X187Parsed>>:
  match bit:
    case 0: w5c_lbl_find(l,lbl,h)
    case _: w5c_lbl_find(r,lbl,h)

@unsafe
def w5c_lbl_find(trie, lbl, h):
  match trie:
    case W5BLNil{}: None{}
    case W5BLLeaf{stored,items}: w5c_lbl_find_leaf(U32.is_eq(stored,h),items,lbl)
    case W5BLNode{stored,mask,l,r}: w5c_lbl_find_br(U32.and(h,mask),l,r,lbl,h)

law w5c_lbl_insert:
  for +trie: W5BLblTrie
  for +entry: W5BLblEntry
  for +h: U32
  W5BLblTrie

@unsafe
def w5c_lbl_ins_leaf(+mask: U32, +trie: W5BLblTrie, +entry: W5BLblEntry, +h: U32, +stored: U32, items: List<&2,W5BLblEntry>) -> W5BLblTrie:
  match mask:
    case 0: W5BLLeaf{h,Con{entry,items}}
    case _: w5c_lbl_join(trie,entry,h,stored,mask)

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

law w4b_reg_dead_step:
  for +r: U32
  for items: List<&2,X187Parsed>
  for +fnItems: List<&2,X187Parsed>
  for +budget: U32
  for +hops: U32
  for +seen: List<&2,String>
  Bool

@unsafe
def w4b_reg_dead_at_lbl(+r: U32, found: Maybe<&2,List<&2,X187Parsed>>, +fnItems: List<&2,X187Parsed>,
    +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match found:
    case Some{atTgt}: w4b_reg_dead_step(r,atTgt,fnItems,budget,hops,seen)
    case None{}: False{}

@unsafe
def w5c_rd_cont_f(stop: Bool, +r: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match stop:
    case True{}: False{}
    case False{}: w4b_reg_dead_step(r,rest,fnItems,U32.sub(budget,1),hops,seen)

@unsafe
def w5c_rd_kill_f(kill: Bool, +r: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match kill:
    case True{}: True{}
    case False{}: w4b_reg_dead_step(r,rest,fnItems,U32.sub(budget,1),hops,seen)

@unsafe
def w5c_rd_wr_if_f(reads: Bool, +dr: U32, +dw: U32, +r: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match reads:
    case True{}: False{}
    case False{}: w5c_rd_kill_f(U32.is_eq(dr,r) && U32.is_ge(dw,32),r,rest,fnItems,budget,hops,seen)

@unsafe
def w4b_reg_dead_write(+r: U32, args: List<&2,X187Operand>, +rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match args:
    case Con{+src,Con{X187Reg{+dr,+dw,False{}},Nil{}}}:
      w5c_rd_wr_if_f(w4b_op_reads_reg(r,src),dr,dw,r,rest,fnItems,budget,hops,seen)
    case _: w5c_rd_cont_f(w4b_args_read_reg(r,args),r,rest,fnItems,budget,hops,seen)

@unsafe
def w5c_rd_br_seen_hops_f(+hops: U32, +r: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +budget: U32, +seen: List<&2,String>) -> Bool:
  match hops:
    case 0: False{}
    case _: w4b_reg_dead_step(r,rest,fnItems,U32.sub(budget,1),U32.sub(hops,1),seen)

@unsafe
def w5c_rd_br_seen_jmp_f(isJmp: Bool, +r: U32, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match isJmp:
    case True{}: True{}
    case False{}: w5c_rd_br_seen_hops_f(hops,r,rest,fnItems,budget,seen)

@unsafe
def w5c_rd_br_both_f(ok: Bool, +r: U32, +tgt: String, +fnItems: List<&2,X187Parsed>, +nb: U32, +nh: U32, +seen: List<&2,String>) -> Bool:
  match ok:
    case False{}: False{}
    case True{}: w4b_reg_dead_at_lbl(r,w4b_find_label(tgt,fnItems),fnItems,nb,nh,Con{tgt,seen})

@unsafe
def w5c_rd_br_jmp_f(isJmp: Bool, +r: U32, +tgt: String, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +nb: U32, +nh: U32, +seen: List<&2,String>) -> Bool:
  match isJmp:
    case True{}: w4b_reg_dead_at_lbl(r,w4b_find_label(tgt,fnItems),fnItems,nb,nh,Con{tgt,seen})
    case False{}: w5c_rd_br_both_f(w4b_reg_dead_step(r,rest,fnItems,nb,nh,seen),r,tgt,fnItems,nb,nh,seen)

@unsafe
def w5c_rd_br_hops_f(+hops: U32, +r: U32, +op: String, +tgt: String, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +budget: U32, +seen: List<&2,String>) -> Bool:
  match hops:
    case 0: False{}
    case _: w5c_rd_br_jmp_f(String.eq(op,"jmp"),r,tgt,rest,fnItems,U32.sub(budget,1),U32.sub(hops,1),seen)

@unsafe
def w5c_rd_br_seen_f(isSeen: Bool, +r: U32, +op: String, +tgt: String, rest: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match isSeen:
    case True{}: w5c_rd_br_seen_jmp_f(String.eq(op,"jmp"),r,rest,fnItems,budget,hops,seen)
    case False{}: w5c_rd_br_hops_f(hops,r,op,tgt,rest,fnItems,budget,seen)

@unsafe
def w4b_reg_dead_branch(+r: U32, +op: String, args: List<&2,X187Operand>, +rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match args:
    case Con{X187Target{+tgt},Nil{}}: w5c_rd_br_seen_f(nb_contains(seen,tgt),r,op,tgt,rest,fnItems,budget,hops,seen)
    case _: False{}

@unsafe
def w4b_reg_dead_pop(+r: U32, args: List<&2,X187Operand>, +rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match args:
    case Con{X187Reg{+dr,+dw,False{}},Nil{}}:
      w5c_rd_kill_f(U32.is_eq(dr,r) && U32.is_ge(dw,32),r,rest,fnItems,budget,hops,seen)
    case _: False{}

@unsafe
def w5c_rd_alu_if_f(isAlu: Bool, +r: U32, args: List<&2,X187Operand>, rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match isAlu:
    case False{}: False{}
    case True{}: w5c_rd_cont_f(w4b_args_read_reg(r,args),r,rest,fnItems,budget,hops,seen)

@unsafe
def w5c_rd_setcc_if_f(killed: Bool, +r: U32, +op: String, args: List<&2,X187Operand>, rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match killed:
    case True{}: True{}
    case False{}: w5c_rd_alu_if_f(w4b_is_simple_alu(op),r,args,rest,fnItems,budget,hops,seen)

@unsafe
def w5c_rd_wo_if_f(isWo: Bool, +r: U32, +op: String, +args: List<&2,X187Operand>, rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match isWo:
    case True{}: w4b_reg_dead_write(r,args,rest,fnItems,budget,hops,seen)
    case False{}: w5c_rd_alu_if_f(w4b_is_simple_alu(op),r,args,rest,fnItems,budget,hops,seen)

@unsafe
def w5c_rd_pop_if_f(isPop: Bool, +r: U32, args: List<&2,X187Operand>, rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match isPop:
    case True{}: w4b_reg_dead_pop(r,args,rest,fnItems,budget,hops,seen)
    case False{}: False{}

@unsafe
def w5c_rd_inst_c_f(u: U32, +r: U32, +op: String, +args: List<&2,X187Operand>, +rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match u:
    case 114: w5c_rd_ret_if_t(String.eq(op,"ret"),r)
    case 112: w5c_rd_pop_if_f(String.eq(op,"popq"),r,args,rest,fnItems,budget,hops,seen)
    case 106: w4b_reg_dead_branch(r,op,args,rest,fnItems,budget,hops,seen)
    case 115: w5c_rd_setcc_if_f(String.starts_with(op,"set") && w5b_dead_after_setcc(r,args,rest),r,op,args,rest,fnItems,budget,hops,seen)
    case _: w5c_rd_wo_if_f(w4b_is_write_only_op(op),r,op,args,rest,fnItems,budget,hops,seen)

@unsafe
def w5c_rd_inst_f(+r: U32, +op: String, +args: List<&2,X187Operand>, +rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match op:
    case SCon{c,_}: w5c_rd_inst_c_f(Char.to_u32(c),r,op,args,rest,fnItems,budget,hops,seen)
    case SNil{}: False{}

@unsafe
def w5c_rd_lbl_seen_f(isSeen: Bool, +r: U32, +lbl: String, rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match isSeen:
    case True{}: True{}
    case False{}: w4b_reg_dead_step(r,rest,fnItems,U32.sub(budget,1),hops,Con{lbl,seen})

@unsafe
def w4b_reg_dead_go(+r: U32, items: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>,
    +budget: U32, +hops: U32, +seen: List<&2,String>) -> Bool:
  match items:
    case Nil{}: False{}
    case Con{PLabel{+lbl},rest}: w5c_rd_lbl_seen_f(nb_contains(seen,lbl),r,lbl,rest,fnItems,budget,hops,seen)
    case Con{PInst{X187Instruction{op,args}},rest}: w5c_rd_inst_f(r,op,args,rest,fnItems,budget,hops,seen)
    case _: False{}

@unsafe
def w4b_reg_dead_step(r,items,fnItems,budget,hops,seen):
  match budget:
    case 0: False{}
    case _: w4b_reg_dead_go(r,items,fnItems,budget,hops,seen)

@unsafe
def w4b_reg_dead(+r: U32, items: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +budget: U32) -> Bool:
  w4b_reg_dead_step(r,items,fnItems,budget,8,[])

# Shallow instruction extractors (keep bend.ts case trees O(1)).
@unsafe
def w12_store_info(item: X187Parsed) -> W12StoreInfo:
  match item:
    case PInst{X187Instruction{op,args}}:
      nt_choose(W12StoreInfo,String.eq(op,"movq"),u => w12_store_info_args(args),u => W12StoreNo{})
    case _: W12StoreNo{}

@unsafe
def w12_fwd_classify(+r0: U32, +d0: U32, item: X187Parsed) -> W12FwdAct:
  match item:
    case PInst{X187Instruction{op,args}}: w12_fwd_classify_args(r0,d0,op,args)
    case _: W12FwdStop{}

@unsafe
def w4b_args_reg_mask(args: List<&2,X187Operand>, +acc: U32) -> U32:
  match args:
    case Nil{}: acc
    case Con{a,rest}: w4b_args_reg_mask(rest,U32.or(acc,w4b_op_reg_mask(a)))

@unsafe
def w4b_items_reg_mask(items: List<&2,X187Parsed>, +acc: U32) -> U32:
  match items:
    case Nil{}: acc
    case Con{PInst{X187Instruction{_,args}},rest}: w4b_items_reg_mask(rest,w4b_args_reg_mask(args,acc))
    case Con{_,rest}: w4b_items_reg_mask(rest,acc)

@unsafe
def w4b_licm_finish(mp: List<&2,W4BMagicMap>, before: List<&2,X187Parsed>, lbl: String,
    body: List<&2,X187Parsed>, orig: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match mp:
    case Nil{}: orig
    case Con{+h,+t}:
      nt_append(X187Parsed,before,
        nt_append(X187Parsed,w4b_hoist_inits(Con{h,t}),
          Con{PLabel{lbl},w4b_rewrite_magics(body,Con{h,t})}))

law w5_take_exit_gen:
  for items: List<&2,X187Parsed>
  for +loopLbl: String
  for +bodyLbl: String
  for +acc: List<&2,X187Parsed>
  for +fuel: U32
  W4BExitSplit

@unsafe
def w5_take_exit_step(items: List<&2,X187Parsed>, +loopLbl: String, +bodyLbl: String,
    +acc: List<&2,X187Parsed>, +fuel: U32) -> W4BExitSplit:
  match items:
    case Nil{}: W4BExitNone{}
    case Con{PLabel{+lbl},rest}:
      nt_choose(W4BExitSplit,agy_str_eq(lbl,bodyLbl) || agy_str_eq(lbl,loopLbl),
        v => W4BExitNone{},
        v => w5_take_exit_gen(rest,loopLbl,bodyLbl,Con{PLabel{lbl},acc},U32.sub(fuel,1)))
    case Con{PInst{X187Instruction{+op,+args}},+rest}:
      nt_choose(W4BExitSplit,agy_str_eq(op,"ret"),
        v => w4b_take_exit_ret(rest,bodyLbl,acc),
        v => nt_choose(W4BExitSplit,String.starts_with(op,"j") && w5_args_jump_to(args,loopLbl,bodyLbl),
          w => W4BExitNone{},
          w => w5_take_exit_gen(rest,loopLbl,bodyLbl,Con{PInst{X187Instruction{op,args}},acc},U32.sub(fuel,1))))
    case _: W4BExitNone{}

@unsafe
def w5_take_exit_gen(items,loopLbl,bodyLbl,acc,fuel):
  nt_choose(W4BExitSplit,U32.is_eq(fuel,0),u => W4BExitNone{},
    u => w5_take_exit_step(items,loopLbl,bodyLbl,acc,fuel))

@unsafe
def w4b_take_exit_clean(items: List<&2,X187Parsed>, +bodyLbl: String, +acc: List<&2,X187Parsed>) -> W4BExitSplit:
  w5_take_exit_gen(items,"",bodyLbl,acc,256)

@unsafe
def w4b_taildup_check(revBody: List<&2,X187Parsed>, +body: List<&2,X187Parsed>, +exitLbl: String) -> List<&2,X187Parsed>:
  match revBody:
    case Con{+jne,Con{+tst,Con{+mv,Con{PLabel{+m1},Con{PLabel{+m2},_}}}}}:
      nt_choose(List<&2,X187Parsed>,w5b_is_pinst(jne) && w5b_is_pinst(tst) && w5b_is_pinst(mv),
        w =>
          +b1 = nt_choose(List<&2,X187Parsed>,w4b_has_jmp_to(m1,body),u => w4b_taildup_replace(body,m1,mv,tst,jne,exitLbl),u => body)
          nt_choose(List<&2,X187Parsed>,w4b_has_jmp_to(m2,b1),u => w4b_taildup_replace(b1,m2,mv,tst,jne,exitLbl),u => b1),
        w => body)
    case Con{+jne,Con{+tst,Con{+mv,Con{PLabel{+mergeLbl},_}}}}:
      nt_choose(List<&2,X187Parsed>,w5b_is_pinst(jne) && w5b_is_pinst(tst) && w5b_is_pinst(mv) && w4b_has_jmp_to(mergeLbl,body),
        u => w4b_taildup_replace(body,mergeLbl,mv,tst,jne,exitLbl),
        u => body)
    case Con{+jne,Con{+tst,Con{+mv2,Con{+mv1,Con{PLabel{+m1},Con{PLabel{+m2},_}}}}}}:
      nt_choose(List<&2,X187Parsed>,w5b_is_pinst(jne) && w5b_is_pinst(tst) && w5b_is_pinst(mv2) && w5b_is_pinst(mv1),
        w =>
          +b1 = nt_choose(List<&2,X187Parsed>,w4b_has_jmp_to(m1,body),u => w4c_taildup_replace2(body,m1,mv1,mv2,tst,jne,exitLbl),u => body)
          nt_choose(List<&2,X187Parsed>,w4b_has_jmp_to(m2,b1),u => w4c_taildup_replace2(b1,m2,mv1,mv2,tst,jne,exitLbl),u => b1),
        w => body)
    case Con{+jne,Con{+tst,Con{+mv2,Con{+mv1,Con{PLabel{+mergeLbl},_}}}}}:
      nt_choose(List<&2,X187Parsed>,w5b_is_pinst(jne) && w5b_is_pinst(tst) && w5b_is_pinst(mv2) && w5b_is_pinst(mv1) && w4b_has_jmp_to(mergeLbl,body),
        u => w4c_taildup_replace2(body,mergeLbl,mv1,mv2,tst,jne,exitLbl),
        u => body)
    case _: body

@unsafe
def w4b_wrap_items(items: List<&2,X187Parsed>, +acc: List<&2,X188Seq>) -> X188Seq:
  match items:
    case Nil{}: x188_finish(acc)
    case Con{h,rest}: w4b_wrap_items(rest,Con{X188One{h},acc})

# W4-10 Pass 3: CFG-aware machine peepholes (addl $c, m32; andl $M, %r32; subq+testq+jne).
@unsafe
def w5_is_jz_jnz_item(item: X187Parsed) -> Bool:
  w5_check_jz_jnz(w4b_as_branch(item))

@unsafe
def w4c_inc_cnt(m: W4CMap, +disp: U32) -> W4CMap:
  +k = w4c_slot_key(disp)
  w4c_map_inc(m,k,k,0)

@unsafe
def w4c_inst_is_leaq_rbp(item: X187Parsed) -> Bool:
  match item:
    case PInst{X187Instruction{op,args}}: agy_str_eq(op,"leaq") && w4c_args_has_rbp(args)
    case _: False{}

@unsafe
def w4c_has_leaq_rbp(items: List<&2,X187Parsed>) -> Bool:
  match items:
    case Nil{}: False{}
    case Con{h,rest}: w4c_inst_is_leaq_rbp(h) || w4c_has_leaq_rbp(rest)

# Count reads and writes of negative-%rbp slots across an instruction list.
law w4c_xmm_dead:
  for +r: U32
  for items: List<&2,X187Parsed>
  for +fnItems: List<&2,X187Parsed>
  for +fuel: U32
  for +hops: U32
  Bool

@unsafe
def w4c_xmm_dead_lbl(+r: U32, found: Maybe<&2,List<&2,X187Parsed>>, +fnItems: List<&2,X187Parsed>, +fuel: U32, +hops: U32) -> Bool:
  match found:
    case Some{atTgt}: w4c_xmm_dead(r,atTgt,fnItems,fuel,hops)
    case None{}: False{}

@unsafe
def w4c_xmm_dead_args(+r: U32, +op: String, args: List<&2,X187Operand>, +rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +fuel: U32, +hops: U32) -> Bool:
  match args:
    case Con{+src,Con{X187Reg{+dr,_,True{}},Nil{}}}:
      nt_choose(Bool,agy_str_eq(op,"pxor") && U32.is_eq(dr,r) && w4c_op_is_xmm(r,src),
        w => True{},
        w => nt_choose(Bool,w4c_op_is_xmm(r,src),
          x => False{},
          x => nt_choose(Bool,w4c_is_xmm_write_only(op) && U32.is_eq(dr,r),
            y => True{},
            y => nt_choose(Bool,U32.is_eq(dr,r),z => False{},z => w4c_xmm_dead(r,rest,fnItems,U32.sub(fuel,1),hops)))))
    case _: nt_choose(Bool,w4c_args_read_xmm(r,args),w => False{},w => w4c_xmm_dead(r,rest,fnItems,U32.sub(fuel,1),hops))

@unsafe
def w4c_xmm_dead_ctrl(+r: U32, +op: String, args: List<&2,X187Operand>, +rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +fuel: U32, +hops: U32) -> Bool:
  match args:
    case Con{X187Target{+lbl},Nil{}}:
      nt_choose(Bool,U32.is_gt(hops,0),
        u => nt_choose(Bool,agy_str_eq(op,"jmp"),
          v => w4c_xmm_dead_lbl(r,w4b_find_label(lbl,fnItems),fnItems,U32.sub(fuel,1),U32.sub(hops,1)),
          v => w4c_xmm_dead(r,rest,fnItems,U32.sub(fuel,1),U32.sub(hops,1)) &&
               w4c_xmm_dead_lbl(r,w4b_find_label(lbl,fnItems),fnItems,U32.sub(fuel,1),U32.sub(hops,1))),
        u => False{})
    case _: False{}

@unsafe
def w4c_xmm_dead_inst(+r: U32, inst: X187Instruction, +rest: List<&2,X187Parsed>,
    +fnItems: List<&2,X187Parsed>, +fuel: U32, +hops: U32) -> Bool:
  match inst:
    case X187Instruction{+op,+args}:
      nt_choose(Bool,agy_str_eq(op,"call") || agy_str_eq(op,"ret"),
        u => True{},
        u => nt_choose(Bool,w4c_is_ctrl(op),
          v => w4c_xmm_dead_ctrl(r,op,args,rest,fnItems,fuel,hops),
          v => w4c_xmm_dead_args(r,op,args,rest,fnItems,fuel,hops)))

@unsafe
def w4c_xmm_dead_go(+r: U32, items: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +fuel: U32, +hops: U32) -> Bool:
  match items:
    case Nil{}: True{}
    case Con{PLabel{_},rest}: w4c_xmm_dead(r,rest,fnItems,U32.sub(fuel,1),hops)
    case Con{PInst{inst},rest}: w4c_xmm_dead_inst(r,inst,rest,fnItems,fuel,hops)
    case Con{_,_}: False{}

@unsafe
def w4c_xmm_dead(r,items,fnItems,fuel,hops):
  nt_choose(Bool,U32.is_eq(fuel,0),u => False{},u => w4c_xmm_dead_go(r,items,fnItems,fuel,hops))

# Classified instruction views for 1-scrutinee XMM peephole
@unsafe
def w4c_join_bbs(bbs: List<&2,List<&2,X187Parsed>>) -> List<&2,X187Parsed>:
  match bbs:
    case Nil{}: []
    case Con{b,rest}: nt_append(X187Parsed,b,w4c_join_bbs(rest))

@unsafe
def w4c_replace_inst(+from: U32, +to: U32, item: X187Parsed) -> X187Parsed:
  match item:
    case PInst{X187Instruction{op,args}}: PInst{X187Instruction{op,w4c_replace_args(from,to,args)}}
    case other: other

@unsafe
def w4c_slot_touched(+disp: U32, items: List<&2,X187Parsed>) -> Bool:
  match items:
    case Nil{}: False{}
    case Con{PInst{X187Instruction{_,args}},rest}: w5_args_touch_slot(disp,args) || w4c_slot_touched(disp,rest)
    case Con{_,rest}: w4c_slot_touched(disp,rest)

@unsafe
def w4c_gpr_touched(+r: U32, items: List<&2,X187Parsed>) -> Bool:
  match items:
    case Nil{}: False{}
    case Con{PInst{X187Instruction{_,args}},rest}: w4c_gpr_in_args(r,args) || w4c_gpr_touched(r,rest)
    case Con{_,rest}: w4c_gpr_touched(r,rest)

# Match movq src(%rbp), %r10
@unsafe
def w4c_as_store_r10(item: X187Parsed) -> W4CStoreR10:
  match item:
    case PInst{X187Instruction{op,Con{X187Reg{r,w,False{}},Con{dst,Nil{}}}}}:
      nt_choose(W4CStoreR10,agy_str_eq(op,"movq") && U32.is_eq(r,10) && U32.is_eq(w,64),
        u => w4c_as_store_r10_dst(dst),
        u => W4CSRNo{})
    case _: W4CSRNo{}

# Sub-pass C2: Forward movq src(%rbp), %r10; movq %r10, dst(%rbp) within a basic block
law w5_count_slot_reads:
  for +disp: U32
  for items: List<&2,X187Parsed>
  for +acc: U32
  U32

@unsafe
def w5_count_slot_reads_wo(isWo: Bool, +disp: U32, +src: X187Operand, +b: U32, +d: U32, rest: List<&2,X187Parsed>, +acc: U32) -> U32:
  match isWo:
    case True{}: w5_count_slot_reads(disp,rest,w5_inc_if(w5_op_is_slot(disp,src),acc))
    case False{}:
      +a1 = w5_inc_if(w5_op_is_slot(disp,src),acc)
      w5_count_slot_reads(disp,rest,w5_inc_if(U32.is_eq(b,5) && U32.is_eq(d,disp),a1))

@unsafe
def w5_count_slot_reads(disp, items, acc):
  match items:
    case Nil{}: acc
    case Con{PInst{X187Instruction{+op,+args}},rest}:
      match args:
        case Con{+src,Con{X187Mem{+b,+d},Nil{}}}:
          w5_count_slot_reads_wo(w4c_is_write_only_mem(op),disp,src,b,d,rest,acc)
        case _: w5_count_slot_reads(disp,rest,w5_count_slot_reads_args(disp,args,acc))
    case Con{_,rest}: w5_count_slot_reads(disp,rest,acc)

@unsafe
def w4c_find_def_back_f(+disp: U32, revPrefix: List<&2,X187Parsed>, +between: List<&2,X187Parsed>, +fuel: U32) -> W4CDefSplit:
  match revPrefix:
    case Nil{}: W4CDSNo{}
    case Con{+h,+rest}:
      nt_choose(W4CDefSplit,U32.is_eq(fuel,0),
        z => W4CDSNo{},
        z => nt_choose(W4CDefSplit,w4c_inst_writes_slot(disp,h),
          u => W4CDSYes{between,h,rest},
          u => w4c_find_def_back_f(disp,rest,Con{h,between},U32.sub(fuel,1))))

@unsafe
def w4c_find_def_back(+disp: U32, revPrefix: List<&2,X187Parsed>, +between: List<&2,X187Parsed>) -> W4CDefSplit:
  w4c_find_def_back_f(disp,revPrefix,between,64)

@unsafe
def w4c_is_dead_store(item: X187Parsed, +reads: W4CMap) -> Bool:
  match item:
    case PInst{X187Instruction{op,Con{_,Con{X187Mem{b,d},Nil{}}}}}:
      w4c_is_write_only_mem(op) && w4c_is_neg_rbp(b,d) && U32.is_eq(w4c_get_cnt(reads,d),0)
    case _: False{}

@unsafe
def w5b_g12_safe_mid(+rC: U32, item: X187Parsed) -> Bool:
  match item:
    case PInst{X187Instruction{+op,+args}}:
      (w4b_is_write_only_op(op) || w4b_is_simple_alu(op)) &&
      Bool.not(w4b_args_read_reg(rC,args))
    case _: False{}

@unsafe
def w5_args_flags(args: List<&2,X187Operand>, +acc: U32) -> U32:
  match args:
    case Nil{}: acc
    case Con{a,rest}: w5_args_flags(rest,U32.or(acc,w5_op_flags(a)))

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
def w5b_reg_used(+r: U32, items: List<&2,X187Parsed>) -> Bool:
  match items:
    case Nil{}: False{}
    case Con{PInst{X187Instruction{_,args}},rest}:
      w4b_args_read_reg(r,args) || w5b_reg_used(r,rest)
    case Con{_,rest}: w5b_reg_used(r,rest)

@unsafe
def w5b_item_uses_r12(h: X187Parsed) -> Bool:
  match h:
    case PInst{X187Instruction{_,args}}: w4b_args_read_reg(12,args)
    case _: False{}

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
def w5b_mark_bad_op(op: X187Operand, +bad: W4CMap) -> W4CMap:
  match op:
    case X187Mem{b,+d}:
      nt_choose(W4CMap,w4c_is_neg_rbp(b,d),
        u => w4c_map_inc(bad,w4c_slot_key(d),w4c_slot_key(d),0),
        u => bad)
    case _: bad

@unsafe
def w5b_map_inc8(m: W4CMap, +k: U32) -> W4CMap:
  w4c_map_inc(w4c_map_inc(w4c_map_inc(w4c_map_inc(
    w4c_map_inc(w4c_map_inc(w4c_map_inc(w4c_map_inc(m,k,k,0),k,k,0),k,k,0),k,k,0),
    k,k,0),k,k,0),k,k,0),k,k,0)

@unsafe
def w5b_rew_args(+disp: U32, +rFree: U32, args: List<&2,X187Operand>) -> List<&2,X187Operand>:
  match args:
    case Nil{}: []
    case Con{a,rest}: Con{w5b_rew_op(disp,rFree,a),w5b_rew_args(disp,rFree,rest)}

@unsafe
def w5b_rew_one(+disp: U32, +rFree: U32, h: X187Parsed) -> X187Parsed:
  match h:
    case PInst{X187Instruction{op,args}}: PInst{X187Instruction{op,w5b_rew_args(disp,rFree,args)}}
    case other: other

@unsafe
def w5b_try_jcc_jmp(+op: String, +l1: String, rest: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match rest:
    case Con{PInst{X187Instruction{opJ,Con{X187Target{+l2},Nil{}}}},Con{PLabel{+l3},+tail}}:
      +cc = w5b_jcc_name(op)
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,
        Bool.not(String.is_empty(cc)) && agy_str_eq(opJ,"jmp") && agy_str_eq(l1,l3),
        u => Some{Con{PInst{X187Instruction{w5b_j_cc(cc,True{}),[X187Target{l2}]}},Con{PLabel{l3},tail}}},
        u => None{})
    case _: None{}

# Shallow instruction-matching helpers (eliminates -O2 x187_pub cliff in m04)
@unsafe
def w11_inst_jcc(item: X187Parsed) -> Maybe<&2,W11Jcc>:
  match item:
    case PInst{X187Instruction{+op,ops}}:
      +isE = agy_str_eq(op,"je") || agy_str_eq(op,"jz")
      +isN = agy_str_eq(op,"jne") || agy_str_eq(op,"jnz")
      nt_choose(Maybe<&2,W11Jcc>,isE || isN,u => w11_ops1_jcc(isN,ops),u => None{})
    case _: None{}

# Try 16-bit rotate pattern R1 (shr-first)
@unsafe
def x199s_tail(items: List<&2,X187Parsed>, +label: String, +fuel: U32) -> Bool:
  match items:
    case Con{PInst{X187Instruction{op,[X187Target{dest}]}},rest}: agy_str_eq(op,"jmp") && agy_str_eq(dest,label)
    case Con{PInst{X187Instruction{op,[a,b]}},rest}: nt_choose(Bool,U32.is_gt(fuel,0) && x199s_plain(op),u => x199s_tail(rest,label,U32.sub(fuel,1)),u => False{})
    case _: False{}

@unsafe
def x199s_count(items: List<&2,X187Parsed>, +disp: U32, +seen: U32) -> U32:
  match items:
    case Nil{}: seen
    case Con{PInst{X187Instruction{+op,+args}},rest}:
      nt_choose(U32,U32.is_gt(seen,2),u => 3,u => x199s_count(rest,disp,U32.add(seen,
        nt_choose(U32,x200s_canonical(op,args),v => 0,v => x199s_count_args(args,disp,Bool.not(x199s_plain(op)))))))
    case Con{other,rest}: x199s_count(rest,disp,seen)

@unsafe
def x199s_item(+item: X187Parsed, found: List<&2,X191FrameStore>) -> X188Seq:
  match item:
    case PInst{X187Instruction{op,[X187Reg{r,64,False{}},X187Mem{5,d}]}}:
      nt_choose(X188Seq,U32.is_lt(x199s_lookup(found,d),16),u => X188Empty{},u => X188One{item})
    case PInst{X187Instruction{op,[X187Mem{5,d},X187Reg{dst,64,False{}}]}}:
      x199s_load(item,dst,x199s_lookup(found,d))
    case _: X188One{item}

@unsafe
def x199s_emit(items: List<&2,X187Parsed>, +found: List<&2,X191FrameStore>, out: List<&2,X188Seq>) -> X188Seq:
  match items:
    case Nil{}: x188_finish(out)
    case Con{item,rest}: x199s_emit(rest,found,Con{x199s_item(item,found),out})

def x191_select_width(typ: N111Type) -> Bool:
  match typ:
    case N111U32{}: True{}
    case N111U64{}: True{}
    case _: False{}

@unsafe
def x191_select_ready(typ: N111Type, yes: N111Value, no: N111Value,
    names: Maybe<&2,List<&2,String>>) -> Maybe<&2,X191SelectPlan>:
  match names:
    case Some{destinations}: Some{X191SelectPlan{typ,yes,no,destinations}}
    case None{}: None{}

@unsafe
def x194_ps_finish(plan: Maybe<&2,X191SelectPlan>, condition: N111Value,
    rest: List<&2,P113DStmt>, +typ: N111Type, +op: String, +left: N111Value,
    +right: N111Value, +current: String, invert: Bool, +names: List<&2,String>) -> Maybe<&2,X194Select>:
  match plan:
    case Some{+selected}:
      match selected:
        case X191SelectPlan{st,yes,no,destinations}:
          nt_choose(Maybe<&2,X194Select>,x185_sf_source(condition,current) &&
              Bool.not(x194_ps_source(names,left) || x194_ps_source(names,right) ||
                x194_ps_source(names,yes) || x194_ps_source(names,no)) &&
              x194_ps_disjoint(destinations,names),
            u => Some{X194Select{rest,typ,op,left,right,invert,selected,names}},u => None{})
    case None{}: None{}

# Exact empty branches on the current predicate are crossed and their extra
# condition reads are counted. No branch body or unrelated condition is crossed.
# Only exact 0/1 copies and xor1 are otherwise crossed. Any other row, including a source
# overwrite, memory access, call, allocation or control edge, refuses the plan.
@unsafe
def x192_p_chain(names: List<&2,String>, +typ: N111Type, +value: N111Value, invert: Bool) -> List<&2,P113DStmt>:
  match names:
    case Nil{}: []
    case Con{+name,rest}: Con{P113DScalar{nt_choose(N111Stmt,invert,
      u => N111Bin{name,typ,"xor",value,N111Const{1,0}},u => N111Set{name,typ,value})},
      x192_p_chain(rest,typ,N111Local{name},False{})}

# Certificate result is the exact replacement rows. None keeps the branch.
@unsafe
def w2_asr_match_sel(sel: Maybe<&2,X194Select>, +s2: String, +mask: U32) -> Maybe<&2,String>:
  match sel:
    case Some{X194Select{rest,typ,op,left,right,invert,X191SelectPlan{st,yes,no,names},removed}}:
      nt_choose(Maybe<&2,String>,
        agy_str_eq(op,"eq") && agy_str_eq(w2_asr_val_local(left),s2) && w2_asr_is_const(right,0) &&
        ((Bool.not(invert) && w2_asr_is_const(yes,0) && w2_asr_is_const(no,mask)) ||
         (invert && w2_asr_is_const(yes,mask) && w2_asr_is_const(no,0))),
        u => w2_asr_head(names),
        u => None{})
    case None{}: None{}

@unsafe
def w2_asr_sel_rest(sel: Maybe<&2,X194Select>) -> List<&2,P113DStmt>:
  match sel:
    case Some{X194Select{rest,typ,op,left,right,invert,plan,removed}}: rest
    case None{}: []

@unsafe
def w2_asr_rewrite_or(+rest: List<&2,P113DStmt>, +s1: String, +m: String, +v: N111Value, +k: U32) -> List<&2,P113DStmt>:
  match rest:
    case Con{P113DScalar{N111Bin{dest,typ,op,+l,+r}},+tail}:
      nt_choose(List<&2,P113DStmt>,agy_str_eq(op,"or") &&
          ((agy_str_eq(w2_asr_val_local(l),s1) && agy_str_eq(w2_asr_val_local(r),m)) ||
           (agy_str_eq(w2_asr_val_local(l),m) && agy_str_eq(w2_asr_val_local(r),s1))),
        u => Con{P113DScalar{N111Bin{dest,N111U32{},"sar",v,N111Const{k,0}}},tail},
        u => rest)
    case _: rest

@unsafe
def w2_asr_v_written(v: N111Value, stmt: P113DStmt) -> Bool:
  match v:
    case N111Local{vname}: w2_dstmt_writes(vname,stmt)
    case _: False{}

law w2_asr_strip_self:
  for body: List<&2,P113DStmt>
  List<&2,P113DStmt>

@unsafe
def w11_asr_strip_scalar(+s: N111Stmt, +rest: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  match s:
    case N111Set{+a,typ,val}:
      nt_choose(List<&2,P113DStmt>,w11_n111_is_u64(typ) && w11_val_local_eq(val,a),
        u => w2_asr_strip_self(rest),
        u => Con{P113DScalar{s},w2_asr_strip_self(rest)})
    case N111Bin{+d,+t,+op,+left,+right}:
      nt_choose(List<&2,P113DStmt>,agy_str_eq(op,"mul") && w11_val_is_const2(left),
        u => Con{P113DScalar{N111Bin{d,t,"add",right,right}},w2_asr_strip_self(rest)},
        u => nt_choose(List<&2,P113DStmt>,agy_str_eq(op,"mul") && w11_val_is_const2(right),
          v => Con{P113DScalar{N111Bin{d,t,"add",left,left}},w2_asr_strip_self(rest)},
          v => Con{P113DScalar{s},w2_asr_strip_self(rest)}))
    case _: Con{P113DScalar{s},w2_asr_strip_self(rest)}

@unsafe
def w11_asr_strip_head(head: P113DStmt, rest: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  match head:
    case P113DScalar{s}: w11_asr_strip_scalar(s,rest)
    case P113DIf{c,yes,no}: Con{P113DIf{c,w2_asr_strip_self(yes),w2_asr_strip_self(no)},w2_asr_strip_self(rest)}
    case other: Con{other,w2_asr_strip_self(rest)}

@unsafe
def w2_asr_strip_self(body):
  match body:
    case Nil{}: []
    case Con{head,rest}: w11_asr_strip_head(head,rest)

@unsafe
def agy_has_asr_or_strip(body: List<&2,P113DStmt>) -> Bool:
  match body:
    case Nil{}: False{}
    case Con{P113DScalar{N111Bin{name,typ,op,left,right}},rest}:
      p88_string_eq(op,"shr") || p88_string_eq(op,"mul") || agy_has_asr_or_strip(rest)
    case Con{P113DScalar{N111Set{a,N111U64{},N111Local{b}}},rest}:
      p88_string_eq(a,b) || agy_has_asr_or_strip(rest)
    case Con{P113DIf{c,yes,no},rest}:
      agy_has_asr_or_strip(yes) || agy_has_asr_or_strip(no) || agy_has_asr_or_strip(rest)
    case Con{head,rest}: agy_has_asr_or_strip(rest)

@unsafe
def w5_scalar_safe(sc: N111Stmt, +p: String, +n: String) -> Bool:
  match sc:
    case N111Set{+dst,_,v}:
      Bool.not(agy_str_eq(dst,p)) && Bool.not(agy_str_eq(dst,n)) && Bool.not(w5_val_is(v,p))
    case N111Bin{+dst,_,_,l,r}:
      Bool.not(agy_str_eq(dst,p)) && Bool.not(agy_str_eq(dst,n)) &&
        Bool.not(w5_val_is(l,p)) && Bool.not(w5_val_is(r,p))
    case N111Offset{+dst,b,by}:
      Bool.not(agy_str_eq(dst,p)) && Bool.not(agy_str_eq(dst,n)) &&
        Bool.not(w5_val_is(b,p)) && Bool.not(w5_val_is(by,p))
    case N111Load{+dst,_,b,_}:
      Bool.not(agy_str_eq(dst,p)) && Bool.not(agy_str_eq(dst,n)) && Bool.not(w5_val_is(b,p))
    case N111Store{_,b,_,v}:
      Bool.not(w5_val_is(b,p)) && Bool.not(w5_val_is(v,p))
    case N111Alloca{+dst,_,_}:
      Bool.not(agy_str_eq(dst,p)) && Bool.not(agy_str_eq(dst,n))
    case N111Call{+dst,_,_,args}:
      Bool.not(agy_str_eq(dst,p)) && Bool.not(agy_str_eq(dst,n)) && Bool.not(w5_args_has(args,p))
    case N111Return{v}:
      Bool.not(w5_val_is(v,p))
    case _: False{}

@unsafe
def x198a_outputs(values: List<&2,N111Value>, +params: List<&2,String>) -> Bool:
  match values:
    case Nil{}: True{}
    case Con{value,rest}: x198a_word(value,params) && x198a_outputs(rest,params)

@unsafe
def x198a_free(+name: String, loop: X198ACountdown) -> Bool:
  match loop:
    case X198ACountdown{params,fuel,pred,buffer,ids}:
      x198a_temp(name,params) && Bool.not(agy_str_eq(name,pred) || agy_str_eq(name,buffer))

# Resolve every taken-arm copy to a constant or incoming parameter. A lookup
# never points at another temporary, even when the arm reassigns a prior name.
law agy_da_scalars_use:
  for ss: List<&2,N111Stmt>
  for +name: String
  Bool

@unsafe
def agy_da_scalar_uses(s: N111Stmt, +name: String) -> Bool:
  match s:
    case N111Set{_,_,v}: agy_da_val_uses(v,name)
    case N111Bin{_,_,_,l,r}: agy_da_val_uses(l,name) || agy_da_val_uses(r,name)
    case N111Offset{_,b,y}: agy_da_val_uses(b,name) || agy_da_val_uses(y,name)
    case N111Load{_,_,b,_}: agy_da_val_uses(b,name)
    case N111Store{_,b,_,v}: agy_da_val_uses(b,name) || agy_da_val_uses(v,name)
    case N111Call{_,_,_,args}: agy_da_args_use(args,name)
    case N111Return{v}: agy_da_val_uses(v,name)
    case N111If{c,yes,no}: agy_da_val_uses(c,name) || agy_da_scalars_use(yes,name) || agy_da_scalars_use(no,name)
    case _: False{}

@unsafe
def agy_da_scalars_use(ss, name):
  match ss:
    case Nil{}: False{}
    case Con{h,t}: agy_da_scalar_uses(h,name) || agy_da_scalars_use(t,name)

law x181_hygiene_scalars:
  for body: List<&2,N111Stmt>
  String

@unsafe
def x181_hygiene_scalar(stmt: N111Stmt) -> String:
  match stmt:
    case N111Set{name,typ,value}: x181_hygiene_name(name)
    case N111Bin{name,typ,op,left,right}: x181_hygiene_name(name)
    case N111Call{name,typ,symbol,args}: x181_hygiene_name(name)
    case N111If{condition,yes,no}: p111_first(x181_hygiene_scalars(yes),x181_hygiene_scalars(no))
    case N111Load{name,typ,base,offset}: x181_hygiene_name(name)
    case N111Offset{name,base,bytes}: x181_hygiene_name(name)
    case N111Alloca{name,bytes,align}: x181_hygiene_name(name)
    case _: ""

@unsafe
def x181_hygiene_scalars(body):
  match body:
    case Nil{}: ""
    case Con{head,rest}: p111_first(x181_hygiene_scalar(head),x181_hygiene_scalars(rest))

@unsafe
def x198n_width(+value: X198NFact, typ: N111Type) -> X198NFact:
  match value typ:
    case X198NConst{lo,hi} N111U32{}: X198NConst{lo,0}
    case X198NAlias{name,narrow} N111U32{}: nt_choose(X198NFact,narrow,u => value,u => X198NUnknown{})
    case X198NNonzero{narrow} N111U32{}: nt_choose(X198NFact,narrow,u => value,u => X198NUnknown{})
    case X198NPredecessor{} N111U32{}: X198NUnknown{}
    case _ _: value

@unsafe
def x198n_join(left: X198NState, right: X198NState) -> X198NState:
  match left right:
    case X198NState{a,+xs} X198NState{b,+ys}:
      X198NState{a && b,x198n_join_rows(nt_append(X198NBinding,xs,ys),xs,ys,[])}

@unsafe
def x198n_back(params: List<&2,String>, values: List<&2,N111Value>, +env: List<&2,X198NBinding>, +fuel: String, +mode: String) -> Bool:
  match params values:
    case Nil{} Nil{}: True{}
    case Con{+name,ps} Con{value,vs}:
      +fact = x198n_value(value,env)
      nt_choose(Bool,agy_str_eq(name,fuel),u => x198n_pred(fact),u =>
        nt_choose(Bool,agy_str_eq(name,mode),v => x198n_low_nonzero(fact),v => x198n_identity(fact,name))) && x198n_back(ps,vs,env,fuel,mode)
    case _ _: False{}

@unsafe
def x198o_join(left: X198AState, right: X198AState) -> X198AState:
  match left right:
    case X198AState{a,+xs} X198AState{b,+ys}: X198AState{a && b,x198o_join_rows(nt_append(X198ABinding,xs,ys),xs,ys,[])}

@unsafe
def x198o_back(params: List<&2,String>, values: List<&2,N111Value>, +env: List<&2,X198ABinding>, +fuel: String, +counter: String) -> Bool:
  match params values:
    case Nil{} Nil{}: True{}
    case Con{+name,ps} Con{value,vs}:
      U32.is_eq(x198o_value(value,env),nt_choose(U32,agy_str_eq(name,fuel),u => 3,u => nt_choose(U32,agy_str_eq(name,counter),v => 2,v => 1))) && x198o_back(ps,vs,env,fuel,counter)
    case _ _: False{}

@unsafe
def w4_x198o_guards_opt(+guards: List<&2,P113DStmt>, +params: List<&2,String>, +values: List<&2,N111Value>, +fuel: String, +counter: String) -> List<&2,P113DStmt>:
  match guards:
    case Con{P113DScalar{N111Bin{_,typ,op,l,r}},Con{_,Nil{}}}:
      [P113DScalar{N111Bin{"p198a_same",typ,op,l,r}},
       P113DIf{N111Local{"p198a_same"},x198o_fast(params,values,fuel,counter),[P113DAgain{values}]}]
    case _:
      Con{P113DScalar{N111Set{"p198a_same",N111U32{},N111Const{1,0}}},
        nt_append(P113DStmt,guards,[P113DIf{N111Local{"p198a_same"},x198o_fast(params,values,fuel,counter),[P113DAgain{values}]}])}

@unsafe
def x198o_unwrap(+body: List<&2,P113DStmt>, +params: List<&2,NC_Binding>, +fuel: String) -> List<&2,P113DStmt>:
  match body:
    case [P113DScalar{N111Bin{+name,N111U64{},+op,+left,+right}},P113DIf{+condition,+yes,no}]:
      nt_choose(List<&2,P113DStmt>,agy_str_eq(op,"ne") && x198n_name(name,x181_param_names(params)) && x185_sf_source(left,fuel) && x192_p_constant(right,0) && x185_sf_source(condition,name),u => yes,u => body)
    case _: body

@unsafe
def x198o_progress_back(params: List<&2,String>, values: List<&2,N111Value>, +env: List<&2,X198OProgressBinding>, +fuel: String, +counter: String) -> Bool:
  match params values:
    case Con{+name,ps} Con{value,vs}:
      (Bool.not(agy_str_eq(name,fuel) || agy_str_eq(name,counter)) && x198o_progress_is(x198o_progress_value(value,env),name)) || x198o_progress_back(ps,vs,env,fuel,counter)
    case _ _: False{}

@unsafe
def agy_la_has_finish_b(stmts: List<&2,P113DStmt>, +bname: String) -> Bool:
  match stmts:
    case Nil{}: False{}
    case Con{P113DScalar{N111Call{dst,t,sym,args}},+rest}:
      agy_str_eq(sym,"p118_rt_finish") && agy_la_finish_arg4(args,bname)
    case Con{P113DResult{_},Nil{}}: False{}
    case _: False{}

@unsafe
def agy_la_scan_con(stmts: List<&2,P113DStmt>, +aname: String, +bname: String, +con_name: String,
    +saw_take: Bool, +saw_ext: Bool, +saw_again: Bool) -> Bool:
  match stmts:
    case Nil{}: saw_take && saw_ext && saw_again
    case Con{P113DScalar{N111Call{dst,t,sym,args}},+rest}:
      nt_choose(Bool,agy_str_eq(sym,"p111_rt_take"),u =>
        agy_la_scan_con(rest,aname,bname,con_name,True{},saw_ext,saw_again),u =>
      nt_choose(Bool,agy_str_eq(sym,"p118_rt_extend"),u =>
        agy_la_ext_arg3(args,con_name) &&
          agy_la_scan_con(rest,aname,bname,con_name,saw_take,True{},saw_again),
        u => False{}))
    case Con{P113DScalar{N111Load{_,_,_,_}},rest}:
      agy_la_scan_con(rest,aname,bname,con_name,saw_take,saw_ext,saw_again)
    case Con{P113DScalar{N111Store{_,_,_,_}},rest}:
      agy_la_scan_con(rest,aname,bname,con_name,saw_take,saw_ext,saw_again)
    case Con{P113DScalar{N111Bin{_,_,_,_,_}},rest}:
      agy_la_scan_con(rest,aname,bname,con_name,saw_take,saw_ext,saw_again)
    case Con{P113DScalar{N111If{_,_,_}},rest}:
      agy_la_scan_con(rest,aname,bname,con_name,saw_take,saw_ext,saw_again)
    case Con{P113DScalar{N111Set{_,_,_}},rest}:
      agy_la_scan_con(rest,aname,bname,con_name,saw_take,saw_ext,saw_again)
    case Con{P113DScalar{N111Offset{_,_,_}},rest}:
      agy_la_scan_con(rest,aname,bname,con_name,saw_take,saw_ext,saw_again)
    case Con{P113DScalar{N111Alloca{_,_,_}},rest}:
      agy_la_scan_con(rest,aname,bname,con_name,saw_take,saw_ext,saw_again)
    case Con{P113DAgain{Con{_,Con{v2,Con{_,Con{_,Nil{}}}}}},Nil{}}:
      agy_la_is_local(v2,bname) && agy_la_scan_con(Nil{},aname,bname,con_name,saw_take,saw_ext,True{})
    case _: False{}

@unsafe
def x202k_tail(rows: List<&2,N111Stmt>, +saved: String) -> Bool:
  match rows:
    case Con{N111Load{+incoming,N111U64{},N111Local{base},40},
      Con{N111Set{+alias,N111U64{},N111Local{src}},Con{N111Call{dest,N111U64{},symbol,Con{N111Arg{N111Ptr{},N111Local{state}},
        Con{N111Arg{N111U64{},N111Local{first}},Con{N111Arg{N111U64{},N111Local{second}},Nil{}}}}},
      Con{N111Return{N111Local{reply}},Nil{}}}}}:
      agy_str_eq(base,"state") && agy_str_eq(state,"state") && agy_str_eq(dest,"reply") && agy_str_eq(reply,"reply") &&
        agy_str_eq(symbol,"p111_rt_apply") && x202k_digit_name(incoming) && x202k_digit_name(saved) &&
        x202k_digit_name(alias) && agy_str_eq(saved,src) && Bool.not(agy_str_eq(saved,incoming) || agy_str_eq(alias,incoming) || agy_str_eq(alias,saved)) &&
        agy_str_eq(first,incoming) && agy_str_eq(second,alias)
    case _: False{}

# The same register read arrives as a runtime call before late expansion.
# Normalize just that operand through the existing expander and require the
# original complete continuation contract before selecting its typed template.
@unsafe
def x192h_formals(params: List<&2,String>) -> List<&2,String>:
  Con{"state",nt_append(String,params,["p114h_mode","p114r_depth","p114r_value"])}

# x181_tail_args excludes the invariant leading state formal. Again therefore
# carries params+mode+depth+value, not state. Its existing parallel move/snapshot
# path protects cycles and aliases between parameters and result operands.
@unsafe
def x192h_transfer(values: List<&2,N111Value>, mode: U32, value: N111Value) -> P113DStmt:
  P113DAgain{nt_append(N111Value,values,[x192h_c(mode),x192h_v("p114r_depth"),value])}

@unsafe
def x192h_result(params: List<&2,String>, value: N111Value) -> P113DStmt:
  x192h_transfer(x192h_values(params),1,value)

@unsafe
def x192h_again(arguments: List<&2,N111Stmt>, +params: List<&2,String>, +buffer: String) -> List<&2,P113DStmt>:
  +count = nt_count(String,params)
  nt_append(P113DStmt,x181_scalar_rows(arguments),nt_append(P113DStmt,x192h_snapshots(count,0,buffer),
    [x192h_transfer(x192h_edges(count,0),0,x192h_v("p114r_value"))]))

@unsafe
def x192h_public_loads(params: List<&2,String>, +index: U32) -> List<&2,P113DStmt>:
  match params:
    case Nil{}: []
    case Con{name,rest}:
      Con{x192h_stack("p111_rt_reg_get",name,index),x192h_public_loads(rest,U32.inc(index))}

@unsafe
def x192h_adapter(name: String, +params: List<&2,String>) -> List<&2,P113DStmt>:
  Con{P113DScalar{N111Alloca{"p114r_outer_out",8,8}},nt_append(P113DStmt,x192h_public_loads(params,0),[
    P113DScalar{N111Call{"p114r_outer_value",N111U64{},p114r_symbol(name),Con{p111_state(),x192h_public_args(params)}}},
    P113DScalar{N111Store{N111U64{},x192h_v("p114r_outer_out"),0,x192h_v("p114r_outer_value")}},
    P113DScalar{N111Call{"p114r_outer_reply",N111U64{},"p111_rt_return",[
      p111_state(),N111Arg{N111Ptr{},x192h_v("p114r_outer_out")},p111_u32(1)]}},
    P113DResult{[x192h_v("p114r_outer_reply")]}])}

def x198pw_root_node() -> X198PWPattern:
  x198pw_two("node","a","b",x198pw_two("node","c","d1",X198PWLam{"d",
    X198PWLet2{x198pw_recur("a","c"),x198pw_recur("b","d1"),X198PWCall{"join",[x198pw_v("res0"),x198pw_v("res1")]}}}))

def x198pw_order(case_: String,a: String,b: String) -> X198PWPattern:
  X198PWLam{"a",X198PWLam{"b",X198PWCase{case_,x198pw_node(x198pw_leaf(a),x198pw_leaf(b))}}}

@unsafe
def agy_ro_ctor_fields(+t: KTerm, +adt: String, +acc: List<&2,U32>) -> Maybe<&2,List<&2,U32>>:
  # Returns field kinds (1 = U32, 2 = ADT) in reverse order, or None if unsupported
  +u = nc_unann(t)
  nt_choose(Maybe<&2,List<&2,U32>>,agy_str_eq(tg(u),"All") && U32.is_gt(qt(u),0) && U32.is_eq(terms_len(ks(u)),2),
    v => nt_choose(Maybe<&2,List<&2,U32>>,agy_ro_ty(kid(u,0),"U32"),
      w => agy_ro_ctor_fields(kid(u,1),adt,Con{1,acc}),
      w => nt_choose(Maybe<&2,List<&2,U32>>,agy_ro_ty(kid(u,0),adt),
        z => agy_ro_ctor_fields(kid(u,1),adt,Con{2,acc}),
        z => None{})),
    v => nt_choose(Maybe<&2,List<&2,U32>>,agy_ro_ty(u,adt),
      w => Some{acc},
      w => None{}))

def agy_fl_pat_z_leaf() -> X198PWPattern:
  X198PWCase{"zero",X198PWLam{"s",X198PWCase{"leaf",X198PWLam{"v",x198pw_leaf("v")}}}}

def agy_fl_pat_s_leaf() -> X198PWPattern:
  X198PWCase{"succ",X198PWLam{"p",X198PWLam{"s",X198PWCase{"leaf",X198PWLam{"v",x198pw_leaf("v")}}}}}

def agy_fl_pat_wn_leaf() -> X198PWPattern:
  X198PWCase{"leaf",X198PWLam{"v",X198PWLam{"s",x198pw_leaf("v")}}}

@unsafe
def x193f_clean_args(args: List<&2,N111Arg>) -> Bool:
  match args:
    case Nil{}: True{}
    case Con{N111Arg{typ,value},rest}: x193f_clean_value(value) && x193f_clean_args(rest)

@unsafe
def x193f_call(target: String, +count: U32) -> List<&2,N111Stmt>:
  nt_append(N111Stmt,x193f_loads(count,0),[
    N111Call{"p193f_result",N111U64{},p112w_symbol(target),Con{p111_state(),x193f_args(count,0)}},
    N111Store{N111U64{},N111Local{"scratch"},0,N111Local{"p193f_result"}},
    N111Call{"p193f_reply",N111U64{},"p111_rt_return",[p111_state(),p111_scratch(),p111_u32(1)]},
    N111Return{N111Local{"p193f_reply"}}])

@unsafe
def x193f_join(first: X193FBody, second: X193FBody) -> X193FBody:
  match first second:
    case X193FBody{a,ac,ae} X193FBody{b,bc,be}:
      X193FBody{nt_append(N111Stmt,a,b),U32.add(ac,bc),p111_first(ae,be)}

@unsafe
def x195t_clean_values(values: List<&2,N111Value>) -> Bool:
  match values:
    case Nil{}: True{}
    case Con{value,rest}: x195t_clean_value(value) && x195t_clean_values(rest)

@unsafe
def x195t_clean_args(args: List<&2,N111Arg>) -> Bool:
  match args:
    case Nil{}: True{}
    case Con{N111Arg{typ,value},rest}: x195t_clean_value(value) && x195t_clean_args(rest)

@unsafe
def x195t_load(name: String, target: String, +value: N111Value, +last: U32) -> List<&2,P113DStmt>:
  [P113DScalar{N111Bin{"p195t_inside",N111U64{},"ult",value,N111Const{last,0}}},
   P113DIf{N111Local{"p195t_inside"},
     [P113DScalar{N111Set{"p195t_index",N111U64{},value}}],
     [P113DScalar{N111Set{"p195t_index",N111U64{},N111Const{last,0}}}]},
   P113DScalar{N111Bin{"p195t_bytes",N111U64{},"shl",N111Local{"p195t_index"},N111Const{3,0}}},
   P113DScalar{N111Offset{"p195t_address",N111Symbol{p126i_table_name(target)},N111Local{"p195t_bytes"}}},
   P113DScalar{N111Load{name,N111U64{},N111Local{"p195t_address"},0}}]

@unsafe
def x181_program_join(first: X181Output, second: X181Output) -> X181Output:
  match first second:
    case X181Output{a,ae} X181Output{b,be}: X181Output{nt_append(X188Seq,a,b),p111_first(ae,be)}

# The shared cursor retains the original private bodies. Array templates were
# previously selected only by the QBE renderer. Reuse the existing structured
# admission, rewrite and setup factories under that same mode=2 certificate.
# Their fallback keeps the complete original runtime operation and ownership.
def x199s_bin(typ: N111Type, +op: String, +a: U32, +b: U32) -> U32:
  match typ:
    case N111U32{}:
      nt_choose(U32,p88_string_eq(op,"add") && x199s_pair(x199s_narrow(a),x199s_narrow(b),11,8),u => 12,u =>
        nt_choose(U32,p88_string_eq(op,"add") && x199s_pair(x199s_narrow(a),x199s_narrow(b),17,16),v => 18,v =>
          nt_choose(U32,p88_string_eq(op,"xor") && x199s_pair(x199s_narrow(a),x199s_narrow(b),18,11),w => 19,w => 0)))
    case N111U64{}:
      nt_choose(U32,p88_string_eq(op,"sub") && U32.is_eq(a,1) && U32.is_eq(b,8),u => 10,u =>
        nt_choose(U32,p88_string_eq(op,"and") && (x199s_pair(a,b,2,6) || x199s_pair(a,b,11,6)),v => 13,v =>
          nt_choose(U32,p88_string_eq(op,"mul") && x199s_pair(a,b,13,9),w => 14,w =>
            nt_choose(U32,p88_string_eq(op,"xor") && x199s_pair(a,b,18,11),z => 19,z => 0))))
    case _: 0

@unsafe
def x199s_free(+name: String, params: List<&2,String>) -> Bool:
  Bool.not(String.is_empty(name) || nb_contains(params,name) ||
    agy_str_eq(name,p117h_name(3,"base")) || agy_str_eq(name,p117h_name(3,"mask")))

@unsafe
def x199s_call(fuel: String, index: String, array: String, +carry: String) -> List<&2,P113DStmt>:
  [P113DScalar{N111Call{carry,N111U64{},"p199_rt_u32_scan4",[
    N111Arg{N111Ptr{},p117h_ref(3,"base")},N111Arg{N111U64{},p117h_ref(3,"mask")},
    N111Arg{N111U64{},N111Local{fuel}},N111Arg{N111U64{},N111Local{index}},N111Arg{N111U64{},N111Local{carry}}]}},
    P113DResult{[N111Local{array},N111Local{carry}]}]

def agy_dp_bin(typ: N111Type, +op: String, +a: U32, +b: U32) -> U32:
  match typ:
    case N111U32{}:
      nt_choose(U32,p88_string_eq(op,"add") && agy_dp_pair(agy_dp_narrow(a),agy_dp_narrow(b),11,51),u => 13,u =>
        nt_choose(U32,p88_string_eq(op,"add") && agy_dp_pair(agy_dp_narrow(a),agy_dp_narrow(b),28,51),v => 33,v =>
          nt_choose(U32,p88_string_eq(op,"add") && agy_dp_pair(agy_dp_narrow(a),agy_dp_narrow(b),32,51),w => 34,w =>
            nt_choose(U32,p88_string_eq(op,"add") && agy_dp_pair(agy_dp_narrow(a),agy_dp_narrow(b),24,20),z => 37,z =>
              nt_choose(U32,p88_string_eq(op,"xor") && agy_dp_pair(a,b,18,51),q => 19,q =>
                nt_choose(U32,p88_string_eq(op,"xor") && agy_dp_pair(a,b,19,51),r => 20,r => 0))))))
    case N111U64{}:
      nt_choose(U32,p88_string_eq(op,"sub") && U32.is_eq(a,1) && U32.is_eq(b,51),u => 10,u =>
        nt_choose(U32,p88_string_eq(op,"xor") && agy_dp_pair(a,b,19,51),t0 => 20,t0 =>
        nt_choose(U32,p88_string_eq(op,"xor") && agy_dp_pair(a,b,18,51),t1 => 19,t1 =>
        nt_choose(U32,p88_string_eq(op,"and") && (agy_dp_pair(a,b,2,5) || agy_dp_pair(a,b,11,5)),v => 14,v =>
          nt_choose(U32,p88_string_eq(op,"mul") && agy_dp_pair(a,b,14,52),w => 15,w =>
            nt_choose(U32,p88_string_eq(op,"ne") && ((agy_dp_is_ai(a) && U32.is_eq(b,17)) || (agy_dp_is_ai(b) && U32.is_eq(a,17))),z => 18,z =>
              nt_choose(U32,p88_string_eq(op,"and") && (agy_dp_pair(a,b,2,7) || agy_dp_pair(a,b,11,7)),q => 21,q =>
                nt_choose(U32,p88_string_eq(op,"mul") && agy_dp_pair(a,b,21,52),r => 22,r =>
                  nt_choose(U32,p88_string_eq(op,"and") && agy_dp_pair(a,b,13,7),s => 25,s =>
                    nt_choose(U32,p88_string_eq(op,"mul") && agy_dp_pair(a,b,25,52),t => 26,t =>
                      nt_choose(U32,p88_string_eq(op,"and") && (agy_dp_pair(a,b,2,9) || agy_dp_pair(a,b,11,9)),k => 29,k =>
                        nt_choose(U32,p88_string_eq(op,"mul") && agy_dp_pair(a,b,29,52),m => 30,m =>
                          nt_choose(U32,p88_string_eq(op,"ult") && U32.is_eq(a,33) && U32.is_eq(b,34),p => 35,p =>
                            nt_choose(U32,p88_string_eq(op,"ult") && U32.is_eq(a,36) && U32.is_eq(b,37),n => 38,n =>
                              nt_choose(U32,p88_string_eq(op,"and") && agy_dp_pair(a,b,13,9),g => 40,g =>
                                nt_choose(U32,p88_string_eq(op,"mul") && agy_dp_pair(a,b,40,52),h => 41,h => 0))))))))))))))))
    case _: 0

@unsafe
def agy_dp_free(+name: String, params: List<&2,String>) -> Bool:
  Bool.not(String.is_empty(name) || nb_contains(params,name) ||
    agy_str_eq(name,p117h_name(5,"base")) || agy_str_eq(name,p117h_name(5,"mask")) ||
    agy_str_eq(name,p117h_name(6,"base")) || agy_str_eq(name,p117h_name(6,"mask")) ||
    agy_str_eq(name,p117h_name(7,"base")) || agy_str_eq(name,p117h_name(7,"mask")))

@unsafe
def w5_lcu_n111_reads(+name: String, s: N111Stmt) -> Bool:
  match s:
    case N111Set{_,_,v}: w5_lcu_val_is(name,v)
    case N111Bin{_,_,_,l,r}: w5_lcu_val_is(name,l) || w5_lcu_val_is(name,r)
    case N111Load{_,_,b,_}: w5_lcu_val_is(name,b)
    case N111Store{_,b,_,v}: w5_lcu_val_is(name,b) || w5_lcu_val_is(name,v)
    case N111Offset{_,b,by}: w5_lcu_val_is(name,b) || w5_lcu_val_is(name,by)
    case N111Alloca{_,_,_}: False{}
    case N111Return{v}: w5_lcu_val_is(name,v)
    case N111Call{_,_,_,args}: w5_lcu_args_has(name,args)
    case N111If{_,_,_}: True{}

law w5_lcu_check_n111_list:
  for xs: List<&2,N111Stmt>
  for +pName: String
  for +arity: U32
  for +acc: W5LcuUse
  W5LcuUse

@unsafe
def w5_lcu_check_n111(stmt: N111Stmt, +pName: String, +arity: U32, +acc: W5LcuUse) -> W5LcuUse:
  match stmt:
    case N111Set{d,_,v}:
      nt_choose(W5LcuUse,agy_str_eq(d,pName) || w5_lcu_val_is(pName,v),u => w5_lcu_use_fail(acc),u => acc)
    case N111Bin{d,_,_,l,r}:
      nt_choose(W5LcuUse,agy_str_eq(d,pName) || w5_lcu_val_is(pName,l) || w5_lcu_val_is(pName,r),u => w5_lcu_use_fail(acc),u => acc)
    case N111Load{d,_,b,_}:
      nt_choose(W5LcuUse,agy_str_eq(d,pName) || w5_lcu_val_is(pName,b),u => w5_lcu_use_fail(acc),u => acc)
    case N111Store{_,b,_,v}:
      nt_choose(W5LcuUse,w5_lcu_val_is(pName,b) || w5_lcu_val_is(pName,v),u => w5_lcu_use_fail(acc),u => acc)
    case N111Offset{d,b,by}:
      nt_choose(W5LcuUse,agy_str_eq(d,pName) || w5_lcu_val_is(pName,b) || w5_lcu_val_is(pName,by),u => w5_lcu_use_fail(acc),u => acc)
    case N111Alloca{d,_,_}:
      nt_choose(W5LcuUse,agy_str_eq(d,pName),u => w5_lcu_use_fail(acc),u => acc)
    case N111Return{v}:
      nt_choose(W5LcuUse,w5_lcu_val_is(pName,v),u => w5_lcu_use_fail(acc),u => acc)
    case N111If{c,yes,no}:
      nt_choose(W5LcuUse,w5_lcu_val_is(pName,c),u => w5_lcu_use_fail(acc),
        u => w5_lcu_check_n111_list(no,pName,arity,w5_lcu_check_n111_list(yes,pName,arity,acc)))
    case N111Call{+d,_,+sym,+args}:
      nt_choose(W5LcuUse,agy_str_eq(d,pName),u => w5_lcu_use_fail(acc),
        u => nt_choose(W5LcuUse,Bool.not(w5_lcu_args_has(pName,args)),w => acc,
          w => nt_choose(W5LcuUse,w5_lcu_is_take_call(pName,arity,sym,args),z => w5_lcu_use_take(acc),
            z => nt_choose(W5LcuUse,w5_lcu_is_tag_call(pName,sym,args) || w5_lcu_is_sink_call(pName,sym,args),
              q => acc,q => w5_lcu_use_fail(acc)))))
    case _: acc

@unsafe
def w5_lcu_check_n111_list(xs,pName,arity,acc):
  match xs:
    case Nil{}: acc
    case Con{h,rest}: w5_lcu_check_n111_list(rest,pName,arity,w5_lcu_check_n111(h,pName,arity,acc))

@unsafe
def w5_lcu_splice_params(params: List<&2,NC_Binding>, +idx: U32, +ins: List<&2,NC_Binding>) -> List<&2,NC_Binding>:
  match params:
    case Nil{}: []
    case Con{h,+rest}:
      nt_choose(List<&2,NC_Binding>,U32.is_eq(idx,0),
        u => nt_append(NC_Binding,ins,rest),
        u => Con{h,w5_lcu_splice_params(rest,U32.sub(idx,1),ins)})

@unsafe
def w5_lcu_splice_vals(vals: List<&2,N111Value>, +idx: U32, +ins: List<&2,N111Value>) -> List<&2,N111Value>:
  match vals:
    case Nil{}: []
    case Con{h,+rest}:
      nt_choose(List<&2,N111Value>,U32.is_eq(idx,0),
        u => nt_append(N111Value,ins,rest),
        u => Con{h,w5_lcu_splice_vals(rest,U32.sub(idx,1),ins)})

@unsafe
def w5_lcu_splice_args(params: List<&2,NC_Binding>, +idx: U32, +ins: List<&2,N111Arg>) -> List<&2,N111Arg>:
  match params:
    case Nil{}: []
    case Con{NC_Binding{_,word,_},+rest}:
      nt_choose(List<&2,N111Arg>,U32.is_eq(idx,0),
        u => nt_append(N111Arg,ins,x185_array_arguments(rest)),
        u => Con{N111Arg{N111U64{},N111Local{word}},w5_lcu_splice_args(rest,U32.sub(idx,1),ins)})

@unsafe
def w5_lcu_materialize(+dest: String, +ctor: String, +arity: U32, +depth: U32) -> List<&2,P113DStmt>:
  +buf = "w5_lcu_box_" ++ U32.show(depth)
  Con{P113DScalar{N111Alloca{buf,U32.mul(arity,8),8}},
    nt_append(P113DStmt,w5_lcu_field_stores(buf,depth,0,arity),
      [P113DScalar{N111Call{dest,N111U64{},"p111_rt_ctor",[p111_state(),N111Arg{N111U32{},N111CtorId{ctor}},N111Arg{N111Ptr{},N111Local{buf}},p111_u32(arity)]}}])}

# Fold consecutive `Load(dst, N111U64{}, tbuf, 8*i)` right after a rewritten `p111_rt_take` into `Set(dst, f_i)`
@unsafe
def w5_lcu_fold_loads(rest: List<&2,P113DStmt>, +tbuf: String, +arity: U32, +depth: U32, +revOut: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  match rest:
    case Con{P113DScalar{N111Load{+dst,N111U64{},N111Local{+b},+off}},+more}:
      +fidx = U32.div(off,8)
      nt_choose(List<&2,P113DStmt>,agy_str_eq(b,tbuf) && U32.is_eq(U32.mod(off,8),0) && U32.is_lt(fidx,arity),
        u => w5_lcu_fold_loads(more,tbuf,arity,depth,Con{P113DScalar{N111Set{dst,N111U64{},N111Local{w5_lcu_field_name(depth,fidx)}}},revOut}),
        u => nt_append(P113DStmt,nt_reverse(P113DStmt,revOut,[]),Con{P113DScalar{N111Load{dst,N111U64{},N111Local{b},off}},more}))
    case other: nt_append(P113DStmt,nt_reverse(P113DStmt,revOut,[]),other)

law w5_lcu_remove_ctor_go:
  for revAcc: List<&2,P113DStmt>
  for +aName: String
  for +a: U32
  for +skippedRev: List<&2,P113DStmt>
  List<&2,P113DStmt>

@unsafe
def w5_lcu_remove_ctor_step(mc: W5LcuCtor, +s0: P113DStmt, +rest: List<&2,P113DStmt>, +aName: String, +a: U32, +skippedRev: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  match mc:
    case W5LcuYes{_,_,_,_,_}:
      w5_lcu_prepend_rev(skippedRev,w5_lcu_drop_n(rest,a))
    case W5LcuNo{}:
      nt_choose(List<&2,P113DStmt>,w5_lcu_is_set_to(aName,s0),
        u => w5_lcu_prepend_rev(skippedRev,w5_lcu_drop_n(rest,U32.inc(a))),
        u => w5_lcu_remove_ctor_go(rest,aName,a,Con{s0,skippedRev}))

@unsafe
def w5_lcu_remove_ctor_go(revAcc,aName,a,skippedRev):
  match revAcc:
    case Nil{}: nt_reverse(P113DStmt,skippedRev,[])
    case Con{+s0,+rest}:
      w5_lcu_remove_ctor_step(w5_lcu_match_ctor_stmt(aName,s0),s0,rest,aName,a,skippedRev)

@unsafe
def agy_f32_opt_depth(opt: Maybe<&2,KTerm>) -> U32:
  match opt:
    case None{}: 0
    case Some{e}: agy_f32_depth(e)

@unsafe
def agy_f32_subst_y(+e: KTerm, +ye: KTerm) -> KTerm:
  nt_choose(KTerm,agy_f32_same(e,ye),
    u => kt("FVarY","",0,0,[]),
    u => nt_choose(KTerm,agy_str_eq(tg(e),"FBin") && U32.is_eq(terms_len(ks(e)),2),
      v => kt("FBin",nm(e),0,0,[agy_f32_subst_y(kid(e,0),ye),agy_f32_subst_y(kid(e,1),ye)]),
      v => e))

law w5b_f32_scan_scalars:
  for body: List<&2,N111Stmt>
  for +acc: U32
  U32

@unsafe
def w5b_f32_sc_cont(+a1: U32, rest: List<&2,N111Stmt>) -> U32:
  match a1:
    case 4: 4
    case _: w5b_f32_scan_scalars(rest,a1)

@unsafe
def w5b_f32_scan_scalar(stmt: N111Stmt, +acc: U32) -> U32:
  match stmt:
    case N111Call{_,_,sym,args}:
      nt_choose(U32,String.eq(sym,"p111_rt_op"),
        u => w5b_or_if(w7_f32_args_ok(args),2,acc),
        u => 4)
    case N111If{_,yes,no}: w5b_f32_sc_cont(w5b_f32_scan_scalars(yes,acc),no)
    case _: acc

@unsafe
def w5b_f32_scan_scalars(body, acc):
  match body:
    case Nil{}: acc
    case Con{s,rest}: w5b_f32_sc_cont(w5b_f32_scan_scalar(s,acc),rest)

law agy_map_stmts_has_ctor:
  for stmts: List<&2,N111Stmt>
  for +cname: String
  Bool

@unsafe
def agy_map_stmt_has_ctor(stmt: N111Stmt, +cname: String) -> Bool:
  match stmt:
    case N111Set{n,t,v}: agy_map_val_is_ctor(v,cname)
    case N111Bin{n,t,op,l,r}: agy_map_val_is_ctor(l,cname) || agy_map_val_is_ctor(r,cname)
    case N111Call{n,t,s,args}: agy_map_args_has_ctor(args,cname)
    case N111If{c,yes,no}: agy_map_stmts_has_ctor(yes,cname) || agy_map_stmts_has_ctor(no,cname)
    case N111Store{t,b,o,v}: agy_map_val_is_ctor(v,cname)
    case _: False{}

@unsafe
def agy_map_stmts_has_ctor(stmts,cname):
  match stmts:
    case Nil{}: False{}
    case Con{h,rest}: agy_map_stmt_has_ctor(h,cname) || agy_map_stmts_has_ctor(rest,cname)

law agy_map_stmts_has_func:
  for stmts: List<&2,N111Stmt>
  for +fname: String
  Bool

@unsafe
def agy_map_stmt_has_func(stmt: N111Stmt, +fname: String) -> Bool:
  match stmt:
    case N111Set{n,t,v}: agy_map_val_has_func(v,fname)
    case N111Call{n,t,s,args}: agy_map_args_has_func(args,fname)
    case N111If{c,yes,no}: agy_map_stmts_has_func(yes,fname) || agy_map_stmts_has_func(no,fname)
    case N111Store{t,b,o,v}: agy_map_val_has_func(v,fname)
    case _: False{}

@unsafe
def agy_map_stmts_has_func(stmts,fname):
  match stmts:
    case Nil{}: False{}
    case Con{h,rest}: agy_map_stmt_has_func(h,fname) || agy_map_stmts_has_func(rest,fname)

law agy_bp_term:
  for +t: KTerm
  for +h: U32
  U32

@unsafe
def agy_bp_terms(xs: List<&2,KTerm>, +h: U32) -> U32:
  match xs:
    case Nil{}: agy_bp_mix(h,254)
    case Con{x,rest}: agy_bp_terms(rest,agy_bp_term(x,h))

@unsafe
def agy_bp_term(t, h):
  +s = j_strip(t)
  +h1 = agy_bp_str(tg(s),h)
  +h2 = agy_bp_str(nm(s),h1)
  +h3 = nt_choose(U32,core_literal(s),
    u => agy_bp_str(kl_text(s),agy_bp_mix(h2,kl_number(s))),
    u => h2)
  agy_bp_terms(ks(s),h3)

@unsafe
def x187_e_imm(+lo: U32, hi: U32, +width: U32) -> List<&2,U32>:
  nt_choose(List<&2,U32>,U32.is_eq(width,64),u => nt_append(U32,x187_e_le(lo,4),x187_e_le(hi,4)),
    u => x187_e_le(lo,nt_choose(U32,U32.is_eq(width,8),v => 1,v => 4)))

@unsafe
def x187_e_prefix(+legacy: U32, wide: Bool, reg: U32, +operand: X187Operand, force: Bool) -> List<&2,U32>:
  +rex = U32.add(64,U32.add(w5b_b2u(wide,8),U32.add(
    w5b_b2u(U32.is_ge(reg,8),4),U32.add(x191_e_rex_x(operand),
      w5b_b2u(U32.is_ge(x187_e_index(operand),8),1)))))
  w5b_e_prefix_rex(U32.is_gt(rex,64) || force,legacy,rex)

@unsafe
def x187_e_mem(+base: U32, +disp: U32, +reg: U32) -> List<&2,U32>:
  +low = U32.mod(base,8)
  +mode = w5b_e_mem_mode(U32.is_eq(disp,0) && Bool.not(U32.is_eq(low,5)),disp)
  Con{U32.add(U32.mul(mode,64),U32.add(U32.mul(U32.mod(reg,8),8),low)),
    w5b_e_mem_sib(low,w5b_e_mem_disp(mode,disp))}

@unsafe
def x187_e_finish(prefix: List<&2,U32>, tail: List<&2,U32>, rm: X187RM) -> X187Encoded:
  match rm:
    case X187RM{bytes,relocations,error}: X187Encoded{nt_append(U32,prefix,nt_append(U32,bytes,tail)),relocations,error}

@unsafe
def x187_e_branch(operand: X187Operand, +code: U32, +extra: U32, +offset: U32) -> X187Encoded:
  match operand:
    case X187Target{+symbol}:
      +codes: List<&2,U32> = nt_choose(List<&2,U32>,U32.is_eq(code,15),u => [15,extra],u => [code])
      nt_choose(X187Encoded,Bool.not(String.is_empty(symbol)),u =>
        X187Encoded{nt_append(U32,codes,[0,0,0,0]),[X187Relocation{1,U32.add(offset,nt_count(U32,codes)),
          nt_choose(U32,U32.is_eq(code,232),v => 4,v => 2),symbol,4294967292,4294967295}],""},u => x187_e_error())
    case _: x187_e_error()

@unsafe
def x187_elf_cat(a: List<&2,U32>, b: List<&2,U32>) -> List<&2,U32>:
  nt_append(U32,a,b)

@unsafe
def x187_elf_u64(lo: U32, hi: U32) -> List<&2,U32>:
  x187_elf_cat(x187_elf_u32(lo),x187_elf_u32(hi))

@unsafe
def w7_bb_sec(section: U32, out: List<&2,U32>, +count: U32, +build: X187Build,
    t: List<&2,U32>, r: List<&2,U32>, d: List<&2,U32>, +ts: U32, +rs: U32, +ds: U32,
    symbols: KDef, names: List<&2,String>, relocs: List<&2,X187Relocation>, error: String) -> X187Build:
  match section:
    case 1: X187Build{1,out,r,d,U32.add(ts,count),rs,ds,symbols,names,relocs,error}
    case 2: X187Build{2,t,out,d,ts,U32.add(rs,count),ds,symbols,names,relocs,error}
    case 3: X187Build{3,t,r,out,ts,rs,U32.add(ds,count),symbols,names,relocs,error}
    case _: x187_build_error("invalid object section",build)

@unsafe
def w7c_push_mem(+rex: U32, +opcode: U32, +reg: U32, +base: U32, +disp: U32,
    t: List<&2,U32>, r: List<&2,U32>, d: List<&2,U32>, +ts: U32, +rs: U32, +ds: U32,
    symbols: KDef, names: List<&2,String>, relocs: List<&2,X187Relocation>, error: String) -> X187Build:
  +low = U32.and(base,7)
  +rlow = U32.mul(U32.and(reg,7),8)
  +zero = U32.is_eq(disp,0) && Bool.not(U32.is_eq(low,5))
  +short = U32.is_le(disp,127) || U32.is_ge(disp,4294967168)
  +mode = nt_choose(U32,zero,u => 0,u => nt_choose(U32,short,v => 1,v => 2))
  +modrm = U32.add(U32.mul(mode,64),U32.add(rlow,low))
  +t0 : List<&2,U32> = Con{modrm,Con{opcode,Con{rex,t}}}
  +t1 = nt_choose(List<&2,U32>,U32.is_eq(low,4),u => Con{36,t0},u => t0)
  +n1 = nt_choose(U32,U32.is_eq(low,4),u => 4,u => 3)
  w7c_push_mem_mode(mode,disp,t1,r,d,ts,n1,rs,ds,symbols,names,relocs,error)

@unsafe
def x201f_apply(+raw: List<&2,U32>, +patches: List<&2,X187Relocation>, end: U32,
    +acc: List<&2,U32>) -> X187Encoded:
  match patches:
    case Nil{}: X187Encoded{nt_reverse(U32,raw,acc),[],""}
    case Con{X187Relocation{s,+offset,k,n,word,hi},rest}:
      x201f_span(U32.sub(U32.sub(end,offset),4),raw,rest,offset,word,acc)

# end is the first byte above the unconsumed raw prefix. The descending input
# list supplies ordinary bytes high-address first. Consing each byte produces
# the final forward-order suffix and consumes each original cell once.
@unsafe
def x201f_span(+count: U32, raw: List<&2,U32>, +patches: List<&2,X187Relocation>,
    +offset: U32, +word: U32, +acc: List<&2,U32>) -> X187Encoded:
  match count:
    case 0:
      match raw:
        case Con{0,Con{0,Con{0,Con{0,rest}}}}:
          x201f_apply(rest,patches,offset,x187_elf_cat(x187_elf_u32(word),acc))
        case _: X187Encoded{[],[],"invalid local branch placeholder"}
    case _:
      match raw:
        case Nil{}: X187Encoded{[],[],"local branch fixup outside text"}
        case Con{head,rest}: x201f_span(U32.sub(count,1),rest,patches,offset,word,Con{head,acc})

@unsafe
def x181_function_fast_done(+symbol: String, code: X181Code) -> X181Output:
  match code:
    case X181Code{chunks,next,+terminal,+error}:
      X181Output{[x188_cat(x188_finish(chunks),X188One{PSize{symbol}})],
        nt_choose(String,String.is_empty(error) && Bool.not(terminal),u => "x86 unterminated function",u => error)}

@unsafe
def x187_print_result(result: X187ObjectResult) -> IO(U32):
  match result:
    case X187ObjectResult{bytes,+error}:
      nt_choose(IO(U32),String.is_empty(error),u => do IO<U32>:
        file : File <- IO.try(File,File.open("/dev/stdout","w"))
        pair : File & Result<&1,&1,U32 & String,Unit> <- File.write_bytes(file,bytes)
        x187_print_written(pair),u => IO.die(U32,1,error))

@unsafe
def agy_lpt_priv_weight(+fn: P113DFunction) -> U32:
  match fn:
    case P113DFunction{n,p,r,pub,body}: U32.add(1,agy_lpt_p113_list(body,0))

@unsafe
def agy_lpt_pub_wrap(+segs: List<&2,N111Segment>, +acc: List<&2,AgyLptPub>) -> List<&2,AgyLptPub>:
  match segs:
    case Nil{}: acc
    case Con{+head,rest}: agy_lpt_pub_wrap(rest,Con{AgyLptPub{agy_lpt_pub_weight(head),head},acc})

@unsafe
def w8_shift_fids_bucket(bucket: List<&2,KDef>, +fid_base: U32) -> List<&2,KDef>:
  match bucket:
    case Nil{}: []
    case Con{head,rest}: Con{w8_shift_fids_tree(head,fid_base),w8_shift_fids_bucket(rest,fid_base)}

@unsafe
def w8_shift_fids_tree(+tree: KDef, +fid_base: U32) -> KDef:
  match tree:
    case KIndexLeaf{hash,bucket}: KIndexLeaf{hash,w8_shift_fids_bucket(bucket,fid_base)}
    case KIndexNode{hash,mask,left,right}:
      KIndexNode{hash,mask,w8_shift_fids_tree(left,fid_base),w8_shift_fids_tree(right,fid_base)}
    case KDef{name,+kind,cid,arity,typ,value,children,native,unsafe}:
      nt_choose(KDef,agy_str_eq(kind,"N111Id"),
        u => KDef{name,kind,U32.add(cid,fid_base),arity,typ,value,children,native,unsafe},
        u => KDef{name,kind,cid,arity,typ,value,w8_shift_fids_bucket(children,fid_base),native,unsafe})

@unsafe
def w8_relocate_table(data: P111QData, +fid_base: U32, +mod_name: String) -> P111QData:
  match data:
    case P111QData{+name,alignment,exported,items}:
      nt_choose(P111QData,agy_str_eq(name,"p111_segments") || agy_str_eq(name,"p111_fid_arity") ||
          agy_str_eq(name,"p111_fid_flags") || agy_str_eq(name,"p111_fid_results"),
        u => P111QData{"p111_mod_" ++ mod_name ++ "_" ++ name,alignment,True{},items},
        u => nt_choose(P111QData,agy_str_eq(name,"p111_program"),
          v => P111QData{"p111_mod_" ++ mod_name ++ "_program",alignment,True{},
            w8_patch_prog_items(items,0,fid_base,mod_name)},
          v => P111QData{name,alignment,exported,items}))

@unsafe
def w8_cursor_seg_count(cursor: P134Cursor) -> U32:
  match cursor:
    case P134Private{fns,ctx,next}: w8_cursor_seg_count(next)
    case P134Legacy{es,ctx,next}: w8_cursor_seg_count(next)
    case P134Public{segs,ctx,next}: nt_count(N111Segment,segs)
    case _: 0

@unsafe
def w10_if_h_str(+h: W10IfHash, +s: String) -> W10IfHash:
  match s:
    case SNil{}: w10_if_h_byte(h, 255)
    case SCon{c, +rest}:
      +u = Char.to_u32(c)
      nt_choose(W10IfHash, U32.is_lt(u, 256),
        k => w10_if_h_str(w10_if_h_byte(h, u), rest),
        k => w10_if_h_str(w10_if_h_u32(h, u), rest))

@unsafe
def w10_if_stamp_str(h: W10IfHash) -> String:
  match h:
    case W10IfHash{h1, h2}:
      "p130-word-pair-v1:w10-iface-v1:" ++ w10_if_hex8(h1) ++ w10_if_hex8(h2)

@unsafe
def w10_if_enc_book_join(+id1: U32, pair: W10IfRes & W10IfAbi) -> W10IfRes & W10IfAbi:
  (+r2, caches) = pair
  (w10_if_enc_con(w10_if_res_enc(r2), id1, w10_if_res_id(r2)), caches)

@unsafe
def w10_if_enc_book_join1(+id1: U32, pair: W10IfRes & KDef) -> W10IfRes & KDef:
  (+r2, cache2) = pair
  (w10_if_enc_con(w10_if_res_enc(r2), id1, w10_if_res_id(r2)), cache2)

law w10_if_write_list:
  for file: File
  for xs: List<&2, String>
  IO(File & Result<&1, &1, U32 & String, Unit>)

@unsafe
def w10_if_write_list_next(pair: File & Result<&1, &1, U32 & String, Unit>, rest: List<&2, String>) -> IO(File & Result<&1, &1, U32 & String, Unit>):
  (file2, res) = pair
  match res:
    case Done{_}: w10_if_write_list(file2, rest)
    case Fail{err}: IO.pure(File & Result<&1, &1, U32 & String, Unit>, (file2, Fail{err}))

@unsafe
def w10_if_write_batch(file: File, batch: String & List<&2, String>) -> IO(File & Result<&1, &1, U32 & String, Unit>):
  (chunk, rest) = batch
  do IO<File & Result<&1, &1, U32 & String, Unit>>:
    pair : File & Result<&1, &1, U32 & String, Unit> <- File.write(file, chunk)
    w10_if_write_list_next(pair, rest)

@unsafe
def w10_if_write_list(file, xs):
  match xs:
    case Nil{}: IO.pure(File & Result<&1, &1, U32 & String, Unit>, (file, Done{Unit{}}))
    case Con{h, t}: w10_if_write_batch(file, w10_if_take_batch(Con{h, t}, 128, ""))

@unsafe
def w10_if_stream_s3(pair: File & Result<&1, &1, U32 & String, Unit>, +trailer: String, +stamp: String) -> IO(U32):
  (f3, res2) = pair
  match res2:
    case Fail{e2}:
      do IO<U32>:
        Unit <- File.close(f3)
        IO.pass(U32, Fail{e2})
    case Done{_}:
      do IO<U32>:
        p3 : File & Result<&1, &1, U32 & String, Unit> <- File.write(f3, trailer)
        w10_if_stream_finish(p3, stamp)

law w10_if_peel_stub:
  for +name: String
  for +t0: KTerm
  for +k: U32
  U32

@unsafe
def w10_if_peel_stub_cur(+name: String, +t: KTerm, +k: U32) -> U32:
  match t:
    case KLambda{_, _, _, Con{body, _}, _, _, _, _}:
      w10_if_peel_stub(name, body, U32.inc(k))
    case _:
      nt_choose(U32, w10_if_is_direct_call(name, t, k),
        u => U32.add(1000, k),
        u =>
          +b0 = w10_if_strip_ann(kid(t, 0))
          nt_choose(U32, p98_tag_eq(t, "Let") && p98_tag_eq(b0, "Bind") && agy_str_eq(nm(b0), "_f") && w10_if_is_direct_call(name, kid(t, 1), k),
            v => 2,
            v => 0))

@unsafe
def w10_if_peel_stub(name, t0, k):
  w10_if_peel_stub_cur(name, w10_if_strip_ann(t0), k)

@unsafe
def w8_tr_compile_done(+trace: Bool, +t2: Nat, +t3: Nat, prepared: P169Prepared, +weak_set: KDef) -> IO(W10TrCompiled):
  match prepared:
    case P169Prepared{fw,+cur,+err}:
      do IO<W10TrCompiled>:
        +segs : U32 = w8_cursor_seg_count(cur)
        _ : Unit <- w8_tr_log(trace,"stage=x198pw_plan ms=" ++ w8_tr_ms(t2,t3) ++ " segs=" ++ U32.show(segs))
        IO.pure(W10TrCompiled,W10TrCompiled{P169Prepared{fw,cur,err},weak_set})

