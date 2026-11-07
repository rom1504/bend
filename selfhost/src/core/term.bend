
# Core syntax, declarations, and structural term operations.

# Module: src/core/term.bend:25
type KTerm is Data:
  KTerm{+tag: String, +name: String, +id: U32, +quant: U32, +kids: List<&2, KTerm>, +removed: List<&2, String>, +originBegin: U32, +originEnd: U32}
  KLambda{+name: String, +id: U32, +quant: U32, +kids: List<&2,KTerm>, +removed: List<&2,String>, +originBegin: U32, +originEnd: U32, +quantityPresent: Bool}
  KLiteral{+kind: String, +number: U32, +text: String, +originBegin: U32, +originEnd: U32}

# Module: src/core/term.bend:30
type KDef is Data:
  KDef{+name: String, +kind: String, +arity: U32, +templates: U32, +typ: KTerm, +value: KTerm, +ctors: List<&2, KDef>, +native: Bool, +unsafe: Bool}
  KIndexLeaf{+hash: U32, +bucket: List<&2,KDef>}
  KIndexNode{+hash: U32, +mask: U32, +left: KDef, +right: KDef}

# The ordinary host supplies JS UTF-16 lengths. This tail loop computes the
# same transport metadata in either execution backend, without dg_width's
# diagnostic-sized recursion on the entire75KiB Base source.

# Module: src/core/term.bend:337
law subst_terms:
  for +ts: List<&2, KTerm>
  for +id: U32
  for +v: KTerm
  List<&2, KTerm>

# Module: src/core/term.bend:343
law core_rebuild:
  for +t: KTerm
  KTerm

# Module: src/core/term.bend:347
law core_apply:
  for +f: KTerm
  for +x: KTerm
  KTerm

# Module: src/core/term.bend:352
law subst_node:
  for +t: KTerm
  for +id: U32
  for +v: KTerm
  KTerm

# Module: src/core/term.bend:417
law core_subst_stable_terms:
  for +ts: List<&2, KTerm>
  Bool

# Module: src/core/term.bend:421
law core_subst_stable_app:
  for +kids: List<&2, KTerm>
  for +removed: List<&2, String>
  Bool

# Module: src/core/term.bend:450
law core_subst_stable_app_kids:
  for +kids: List<&2, KTerm>
  Bool

# Module: src/core/term.bend:454
law core_subst_stable_app_tail:
  for +f: KTerm
  for +tail: List<&2, KTerm>
  Bool

# Module: src/core/term.bend:459
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

# Module: src/core/term.bend:4
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

# Module: src/core/term.bend:124
@unsafe
def terms_at(
  +ts: List<&2, KTerm>,
  +n: U32,
) -> KTerm:
  match ts:
    case Nil{}:
      {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}
    case Con{h, t}:
      kc(KTerm, U32.is_eq(n, 0), u => h, u => terms_at(t, U32.sub(n, 1)))

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
def typ(
  +q: U32,
) -> KTerm:
  kt("Typ", "", 0, 0, Con{qua(q), Nil{}})

# Module: src/core/term.bend:167
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
def missing() -> KDef:
  KDef{"", "Absent", 0, 0,
    KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0},
    KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0},
    Nil{}, False{}, False{}}

@unsafe
def lookup(+book: List<&2,KDef>, +name: String) -> KDef:
  match book:
    case Nil{}: missing()
    case Con{+d,+rest}:
      kc(KDef, p137q_is_cache(d),
        u => index_lookup(d, name),
        u => kc(KDef, p137q_name_eq(name, d),
          v => d, v => lookup(rest, name)))

@unsafe
def lookup_cached(
  +d: KDef,
  +rest: List<&2, KDef>,
  +name: String,
  +cached: Bool,
) -> KDef:
  match cached:
    case True{}: index_lookup(d, name)
    case False{}: lookup_named(d, rest, name, p88_string_eq(dn(d), name))

# Module: src/core/term.bend:300
@unsafe
def lookup_named(
  +d: KDef,
  +rest: List<&2, KDef>,
  +name: String,
  +same: Bool,
) -> KDef:
  match same:
    case True{}: d
    case False{}: lookup(rest, name)

# Module: src/core/term.bend:311
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
def subst(+t: KTerm, +id: U32, +v: KTerm) -> KTerm:
  p177s_entry(t,id,v)

@unsafe
def subst_node(t,id0,v):
  p177s_node_entry(t,id0,v)

# Module: src/core/term.bend:379
@unsafe
def subst_terms(ts, id, v):
  match ts:
    case Nil{}:
      Nil{}
    case Con{h, t}:
      Con{subst(h, id, v), subst_terms(t, id, v)}

# Module: src/core/term.bend:388
@unsafe
def core_force(
  +t: KTerm,
) -> KTerm:
  kc(KTerm, p98_tag_eq(t, "Ann"), u => core_force(kid(t, 0)),
    u => kc(KTerm, p98_tag_eq(t, "Var") && U32.is_gt(terms_len(ks(t)), 0), u => core_force(kid(t, 0)), u => t))

# Module: src/core/term.bend:395
@unsafe
def core_rebuild(t):
  kc(KTerm, p98_tag_eq(t, "App"), u => core_apply_span(kid(t, 0), kid(t, 1), kb(t), ke(t)), u => t)

# Module: src/core/term.bend:399
@unsafe
def core_apply(f, x):
  core_apply_span(f, x, 0, 0)

# Module: src/core/term.bend:403
@unsafe
def core_apply_span(+f: KTerm, +x: KTerm, +begin: U32, +end: U32) -> KTerm:
  kc(KTerm, p98_tag_eq(f, "Lam"), u => subst(kid(f, 0), ix(f), x), u => kt_span("App", "", 0, 0, [f, x], begin, end))

# Module: src/core/term.bend:407
@unsafe
def core_beta(
  +t: KTerm,
) -> KTerm:
  kc(KTerm, p98_tag_eq(t, "App"), u => core_apply_span(core_beta(kid(t, 0)), kid(t, 1), kb(t), ke(t)), u => t)

# Scan in substitution order: Var test, children, then App rebuilding.
# A false fact returns to ordinary substitution, preserving its work and errors.
# A canonical App also survives substitution unchanged if both children do and
# its unchanged function is not Lam. Every metadata/arity check is necessary
# because core_rebuild canonicalizes App nodes even without beta reduction.

# Module: src/core/term.bend:427
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
def core_subst_stable_app_kids(kids):
  match kids:
    case Nil{}: False{}
    case Con{f, tail}: core_subst_stable_app_tail(f, tail)

# Module: src/core/term.bend:478
@unsafe
def core_subst_stable_app_tail(f, tail):
  match tail:
    case Nil{}: False{}
    case Con{x, rest}: core_subst_stable_app_last(f, x, rest)

# Module: src/core/term.bend:484
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
def core_nat(+t: KTerm) -> Bool:
  core_literal(t) && p88_string_eq(nm(t), "Nat")

# Module: src/core/term.bend:521
@unsafe
def core_nat_make(+n: U32) -> KTerm:
  kl_make("Nat", n, "")

# Module: src/core/term.bend:525
@unsafe
def core_literal_type(+book: List<&2,KDef>, +t: KTerm, +ty: KTerm) -> Bool:
  p98_tag_eq(ty, "ADT") && p88_string_eq(nm(ty), nm(t)) && List.is_empty(&2, String, rm(ty)) && db(lookup(book, nm(t)))

# Module: src/core/term.bend:529
@unsafe
def core_literal_word(+n: U32, +bits: U32, +begin: U32, +end: U32) -> KTerm:
  kc(KTerm, U32.is_eq(bits, 0), u => kt_span("Ctr", "WNil", 0, 1, Nil{}, begin, end),
    u => kt_span("Ctr", "WCon", 0, 1, [kt_span("Ctr", kc(String, U32.is_eq(U32.and(n, 1), 0), u => "False", u => "True"), 0, 1, Nil{}, begin, end), core_literal_word(U32.shrn(n, 1n), U32.sub(bits, 1), begin, end)], begin, end))

# Module: src/core/term.bend:534
@unsafe
def core_literal_step(+t: KTerm) -> KTerm:
  kc(KTerm, p88_string_eq(nm(t), "Nat"),
    u => kc(KTerm, U32.is_eq(kl_number(t), 0), u => kt_span("Ctr", "Zero", 0, 1, Nil{}, kb(t), ke(t)), u => kt_span("Ctr", "Succ", 0, 1, [KLiteral{"Nat", U32.sub(kl_number(t), 1), "", kb(t), ke(t)}], kb(t), ke(t))),
    u => kc(KTerm, p88_string_eq(nm(t), "String"), u => core_literal_string(kl_text(t), kb(t), ke(t)),
      u => kt_span("Ctr", nm(t), 0, 1, [core_literal_word(kl_number(t), 32, kb(t), ke(t))], kb(t), ke(t))))

# Module: src/core/term.bend:541
@unsafe
def core_literal_string(+s: String, +begin: U32, +end: U32) -> KTerm:
  match s:
    case SNil{}: kt_span("Ctr", "SNil", 0, 1, Nil{}, begin, end)
    case SCon{c, rest}: kt_span("Ctr", "SCon", 0, 1, [kt_span("Ctr", "Chr", 0, 1, [KLiteral{"U32", Char.to_u32(c), "", begin, end}], begin, end), KLiteral{"String", 0, rest, begin, end}], begin, end)

# Module: src/core/term.bend:547
@unsafe
def core_literal_same(+a: KTerm, +b: KTerm) -> Bool:
  p88_string_eq(nm(a), nm(b)) && U32.is_eq(kl_number(a), kl_number(b)) && p88_string_eq(kl_text(a), kl_text(b))

# Module: src/core/term.bend:551
@unsafe
def compiler_term_abi() -> U32:
  1

# Source ranges are non-semantic metadata. Zero/zero is absent; positive
# inclusive-start/exclusive-end coordinates belong to one source interval.

# Module: src/core/term.bend:557
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

# Module: src/core/term.bend:577
@unsafe
def compiler_span_abi() -> U32:
  3

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

# Strong normalization, unlike alpha-renaming, omits the optional syntax q.

# Module: src/core/term.bend:662
@unsafe
def k_snf_children(+t: KTerm, +kids: List<&2,KTerm>) -> KTerm:
  match t:
    case KTerm{tag, name, id, quant, oldKids, removed, begin, end}:
      kc(KTerm, p88_string_eq(tag, "Lam"), u => KLambda{name, id, quant, kids, removed, begin, end, False{}}, u => KTerm{tag, name, id, quant, kids, removed, begin, end})
    case KLambda{name, id, quant, oldKids, removed, begin, end, present}:
      KLambda{name, id, quant, kids, removed, begin, end, False{}}
    case KLiteral{kind, number, text, begin, end}: t

# Scope flattening rebuilds a binder via a temporary pattern variable. Restore
# only its optional quantity syntax after that existing semantic operation.

# Module: src/core/term.bend:673
@unsafe
def k_lambda_presence(+t: KTerm, +present: Bool) -> KTerm:
  match t:
    case KTerm{tag, name, id, quant, kids, removed, begin, end}:
      kc(KTerm, p88_string_eq(tag, "Lam"), u => KLambda{name, id, quant, kids, removed, begin, end, present}, u => t)
    case KLambda{name, id, quant, kids, removed, begin, end, oldPresent}:
      KLambda{name, id, quant, kids, removed, begin, end, present}
    case KLiteral{kind, number, text, begin, end}: t
law p177s_entry:
  for t: KTerm
  for id: U32
  for value: KTerm
  KTerm

law p177s_node_entry:
  for t: KTerm
  for id: U32
  for value: KTerm
  KTerm
# One recursive owner includes ordinary substitution AND eager App beta work.
# A beta frame restores the enclosing substitution before its next sibling.
type P177SFrame is Data:
  P177SNode{shell: KTerm, rest: List<&2,KTerm>, done: List<&2,KTerm>}
  P177SBeta{oldId: U32, oldValue: KTerm}

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
def p177s_loop(state: U32, +term: KTerm, +terms: List<&2,KTerm>,
  +id: U32, +value: KTerm, stack: List<&1,P177SFrame>) -> KTerm:
  match state:
    case 0:
      p177s_loop(p177s_visit_state(p98_tag_eq(term,"Var"),U32.is_eq(ix(term),id)),
        term,Nil{},id,value,stack)
    case 1:
      p177s_loop(4,value,Nil{},id,value,stack)
    case 2:
      match term:
        case KTerm{tag,name,n,quant,kids,removed,begin,end}:
          match kids:
            case Nil{}:
              p177s_loop(p177s_leaf_state(p88_string_eq(tag,"App")),
                term,Nil{},id,value,stack)
            case Con{head,rest}:
              p177s_loop(0,head,Nil{},id,value,
                Con{P177SNode{KTerm{tag,name,n,quant,Nil{},removed,begin,end},rest,Nil{}},stack})
        case KLambda{name,n,quant,kids,removed,begin,end,present}:
          match kids:
            case Nil{}: p177s_loop(4,term,Nil{},id,value,stack)
            case Con{head,rest}:
              p177s_loop(0,head,Nil{},id,value,
                Con{P177SNode{KLambda{name,n,quant,Nil{},removed,begin,end,present},rest,Nil{}},stack})
        case KLiteral{kind,number,text,begin,end}:
          p177s_loop(4,term,Nil{},id,value,stack)
    case 4:
      match stack:
        case Nil{}: term
        case Con{P177SBeta{oldId,oldValue},tail}:
          p177s_loop(4,term,Nil{},oldId,oldValue,tail)
        case Con{P177SNode{shell,rest,done},tail}:
          match rest:
            case Nil{}:
              p177s_loop(5,shell,p177s_reverse(Con{term,done},Nil{}),id,value,tail)
            case Con{head,pending}:
              p177s_loop(0,head,Nil{},id,value,
                Con{P177SNode{shell,pending,Con{term,done}},tail})
    case 5:
      p177s_loop(p177s_rebuild_state(p98_tag_eq(term,"App")),
        term,terms,id,value,stack)
    case 6:
      p177s_loop(p177s_apply_state(p98_tag_eq(terms_at(terms,0),"Lam")),
        term,terms,id,value,stack)
    case 7:
      p177s_loop(4,k_with_children(term,terms),Nil{},id,value,stack)
    case 8:
      +function = terms_at(terms,0)
      p177s_loop(0,kid(function,0),Nil{},ix(function),terms_at(terms,1),
        Con{P177SBeta{id,value},stack})
    case _:
      p177s_loop(4,kt_span("App","",0,0,[terms_at(terms,0),terms_at(terms,1)],kb(term),ke(term)),
        Nil{},id,value,stack)

@unsafe
def p177s_entry(t,id,value):
  p177s_loop(0,t,Nil{},id,value,Nil{})

@unsafe
def p177s_node_entry(t,id,value):
  p177s_loop(2,t,Nil{},id,value,Nil{})
