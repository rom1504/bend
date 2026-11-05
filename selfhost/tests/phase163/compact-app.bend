# Private Phase163 App-only representation overlay. No imports or main.
# Root replaces the named declarations and appends new helpers; production is untouched.
# Legacy kt/kt_span and explicit KTerm records remain unchanged. Native/Bend-only.

type KTerm is Data:
  KTerm{+tag: String, +name: String, +id: U32, +quant: U32, +kids: List<&2, KTerm>, +removed: List<&2, String>, +originBegin: U32, +originEnd: U32}
  KLambda{+name: String, +id: U32, +quant: U32, +kids: List<&2,KTerm>, +removed: List<&2,String>, +originBegin: U32, +originEnd: U32, +quantityPresent: Bool}
  KLiteral{+kind: String, +number: U32, +text: String, +originBegin: U32, +originEnd: U32}
  KApp{+quant: U32, +children: KChildren, +originBegin: U32, +originEnd: U32}

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
    case KApp{quant, children, begin, end}: "App"

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
    case KApp{quant, children, begin, end}: ""

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
    case KApp{quant, children, begin, end}: 0

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
    case KApp{quant, children, begin, end}: quant

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
    case KApp{quant, children, begin, end}: p163c_list(children)

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
    case KApp{quant, children, begin, end}: Nil{}

@unsafe
def kb(+t: KTerm) -> U32:
  match t:
    case KTerm{tag, name, id, quant, kids, removed, originBegin, originEnd}:
      originBegin
    case KLambda{name, id, quant, kids, removed, begin, end, present}:
      begin
    case KLiteral{kind, number, text, literalBegin, literalEnd}:
      literalBegin
    case KApp{quant, children, begin, end}: begin

@unsafe
def ke(+t: KTerm) -> U32:
  match t:
    case KTerm{tag, name, id, quant, kids, removed, originBegin, originEnd}:
      originEnd
    case KLambda{name, id, quant, kids, removed, begin, end, present}:
      end
    case KLiteral{kind, number, text, literalBegin, literalEnd}:
      literalEnd
    case KApp{quant, children, begin, end}: end

@unsafe
def core_literal(+t: KTerm) -> Bool:
  match t:
    case KTerm{tag, name, id, quant, kids, removed, begin, end}: False{}
    case KLambda{name, id, quant, kids, removed, begin, end, present}:
      False{}
    case KLiteral{kind, number, text, begin, end}: True{}
    case KApp{quant, children, begin, end}: False{}

@unsafe
def kl_number(+t: KTerm) -> U32:
  match t:
    case KTerm{tag, name, id, quant, kids, removed, begin, end}: 0
    case KLambda{name, id, quant, kids, removed, begin, end, present}:
      0
    case KLiteral{kind, number, text, begin, end}: number
    case KApp{quant, children, begin, end}: 0

@unsafe
def kl_text(+t: KTerm) -> String:
  match t:
    case KTerm{tag, name, id, quant, kids, removed, begin, end}: ""
    case KLambda{name, id, quant, kids, removed, begin, end, present}:
      ""
    case KLiteral{kind, number, text, begin, end}: text
    case KApp{quant, children, begin, end}: ""

@unsafe
def k_quantity_present(+t: KTerm) -> Bool:
  match t:
    case KTerm{tag, name, id, quant, kids, removed, begin, end}: p88_string_eq(tag, "Lam")
    case KLambda{name, id, quant, kids, removed, begin, end, present}: present
    case KLiteral{kind, number, text, begin, end}: False{}
    case KApp{quant, children, begin, end}: False{}

@unsafe
def k_lambda_presence(+t: KTerm, +present: Bool) -> KTerm:
  match t:
    case KTerm{tag, name, id, quant, kids, removed, begin, end}:
      kc(KTerm, p88_string_eq(tag, "Lam"), u => KLambda{name, id, quant, kids, removed, begin, end, present}, u => t)
    case KLambda{name, id, quant, kids, removed, begin, end, oldPresent}:
      KLambda{name, id, quant, kids, removed, begin, end, present}
    case KLiteral{kind, number, text, begin, end}: t
    case KApp{quant, children, begin, end}: t

def p98_tag_eq_read(term: KTerm, key: String) -> Bool:
  match term:
    case KTerm{tag, name, id, quant, kids, removed, begin, end}:
      p88_string_eq_go(tag, key, True{})
    case KLambda{name, id, quant, kids, removed, begin, end, present}:
      p88_string_eq("Lam", key)
    case KLiteral{kind, number, text, begin, end}:
      p88_string_eq("Lit", key)
    case KApp{quant, children, begin, end}: p88_string_eq("App", key)

@unsafe
def prefix_state_variant(+t: KTerm) -> U32:
  match t:
    case KTerm{tag, name, id, quant, kids, removed, begin, end}: 0
    case KLambda{name, id, quant, kids, removed, begin, end, present}: 1
    case KLiteral{kind, number, text, begin, end}: 2
    case KApp{quant, children, begin, end}: 3

@unsafe
def f_fresh_prefix_variant(+t: KTerm) -> U32:
  match t:
    case KTerm{tag, name, id, quant, kids, removed, begin, end}: 0
    case KLambda{name, id, quant, kids, removed, begin, end, present}: 1
    case KLiteral{kind, number, text, begin, end}: 2
    case KApp{quant, children, begin, end}: 3

def p152c_variant(a: KTerm, b: KTerm) -> Bool:
  match a b:
    case KTerm{a0,a1,a2,a3,a4,a5,a6,a7} KTerm{b0,b1,b2,b3,b4,b5,b6,b7}: True{}
    case KLambda{a0,a1,a2,a3,a4,a5,a6,a7} KLambda{b0,b1,b2,b3,b4,b5,b6,b7}: Bool.not(Bool.xor(a7,b7))
    case KApp{a0,a1,a2,a3} KApp{b0,b1,b2,b3}: True{}
    case _ _: False{}

@unsafe
def k_with_children(+t: KTerm, +newKids: List<&2,KTerm>) -> KTerm:
  match t:
    case KTerm{tag, name, id, quant, oldKids, removed, originBegin, originEnd}:
      KTerm{tag, name, id, quant, newKids, removed, originBegin, originEnd}

    case KLambda{name, id, quant, kids, removed, begin, end, present}:
      KLambda{name, id, quant, newKids, removed, begin, end, present}
    case KLiteral{kind, number, text, literalBegin, literalEnd}:
      t
    case KApp{quant, children, begin, end}: KApp{quant, p163c_children(newKids), begin, end}

@unsafe
def k_with_span(+t: KTerm, +newBegin: U32, +newEnd: U32) -> KTerm:
  match t:
    case KTerm{tag, name, id, quant, kids, removed, oldBegin, oldEnd}:
      KTerm{tag, name, id, quant, kids, removed, newBegin, newEnd}
    case KLambda{name, id, quant, kids, removed, begin, end, present}:
      KLambda{name, id, quant, kids, removed, newBegin, newEnd, present}
    case KLiteral{kind, number, text, literalBegin, literalEnd}:
      KLiteral{kind, number, text, newBegin, newEnd}
    case KApp{quant, children, begin, end}: KApp{quant, children, newBegin, newEnd}

@unsafe
def k_snf_children(+t: KTerm, +kids: List<&2,KTerm>) -> KTerm:
  match t:
    case KTerm{tag, name, id, quant, oldKids, removed, begin, end}:
      kc(KTerm, p88_string_eq(tag, "Lam"), u => KLambda{name, id, quant, kids, removed, begin, end, False{}}, u => KTerm{tag, name, id, quant, kids, removed, begin, end})
    case KLambda{name, id, quant, oldKids, removed, begin, end, present}:
      KLambda{name, id, quant, kids, removed, begin, end, False{}}
    case KLiteral{kind, number, text, begin, end}: t
    case KApp{quant, oldChildren, begin, end}: KApp{quant, p163c_children(kids), begin, end}

@unsafe
def k_rebuild(+t: KTerm, +name: String, +id: U32, +quant: U32, +kids: List<&2,KTerm>, +removed: List<&2,String>, +begin: U32, +end: U32) -> KTerm:
  match t:
    case KTerm{tag, oldName, oldId, oldQuant, oldKids, oldRemoved, oldBegin, oldEnd}:
      KTerm{tag, name, id, quant, kids, removed, begin, end}
    case KLambda{oldName, oldId, oldQuant, oldKids, oldRemoved, oldBegin, oldEnd, present}:
      KLambda{name, id, quant, kids, removed, begin, end, present}
    case KLiteral{kind, number, text, oldBegin, oldEnd}: t
    case KApp{oldQuant, oldChildren, oldBegin, oldEnd}:
      kc(KTerm, String.is_empty(name) && U32.is_eq(id, 0) && List.is_empty(&2, String, removed),
        u => KApp{quant, p163c_children(kids), begin, end},
        u => KTerm{"App", name, id, quant, kids, removed, begin, end})

@unsafe
def subst_node(t, id0, v):
  match t:
    case KTerm{tag, name, n, q, kids, removed, originBegin, originEnd}:
      kc(KTerm, List.is_empty(&2, KTerm, kids) && Bool.not(p88_string_eq(tag, "App")),
        u => t,
        u => core_rebuild(KTerm{tag, name, n, q, subst_terms(kids, id0, v), removed, originBegin, originEnd}))
    case KLambda{name, id, quant, kids, removed, begin, end, present}:
      core_rebuild(KLambda{name, id, quant, subst_terms(kids, id0, v), removed, begin, end, present})
    case KLiteral{kind, number, text, literalBegin, literalEnd}:
      t
    case KApp{quant, children, begin, end}:
      p163c_subst_app(p163c_subst_children(children, id0, v), begin, end)

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
    case KApp{quant, children, begin, end}:
      kc(Bool, p163c_stable_children(children),
        u => kc(Bool, U32.is_eq(quant, 0), u => p163c_stable_app(children), u => False{}),
        u => False{})

@unsafe
def f_span_created(+t: KTerm, +begin: U32, +end: U32) -> KTerm:
  match t:
    case KTerm{tag, name, id, quant, kids, removed, oldBegin, oldEnd}:
      f_choose(KTerm, U32.is_eq(begin, 0) || U32.is_gt(oldBegin, 0), u => t,
        u => KTerm{tag, name, id, quant, f_spans_created(kids, begin, end), removed, begin, end})
    case KLambda{name, id, quant, kids, removed, oldBegin, oldEnd, present}:
      f_choose(KTerm, U32.is_eq(begin, 0) || U32.is_gt(oldBegin, 0), u => t,
        u => KLambda{name, id, quant, f_spans_created(kids, begin, end), removed, begin, end, present})
    case KLiteral{kind, number, text, literalBegin, literalEnd}:
      f_choose(KTerm, U32.is_eq(begin, 0) || U32.is_gt(literalBegin, 0), u => t, u => k_with_span(t, begin, end))
    case KApp{quant, children, oldBegin, oldEnd}:
      f_choose(KTerm, U32.is_eq(begin, 0) || U32.is_gt(oldBegin, 0), u => t,
        u => KApp{quant, p163c_span_children(children, begin, end), begin, end})

@unsafe
def f_pattern_value(+t: KTerm, +begin: U32, +end: U32) -> KTerm:
  match t:
    case KTerm{tag, name, id, quant, kids, removed, oldBegin, oldEnd}:
      KTerm{tag, name, id, quant, f_pattern_values(kids, begin, end), removed,
        f_choose(U32, U32.is_gt(begin, 0), u => begin, u => oldBegin),
        f_choose(U32, U32.is_gt(begin, 0), u => end, u => oldEnd)}
    case KLambda{name, id, quant, kids, removed, oldBegin, oldEnd, present}:
      KLambda{name, id, quant, f_pattern_values(kids, begin, end), removed,
        f_choose(U32, U32.is_gt(begin, 0), u => begin, u => oldBegin),
        f_choose(U32, U32.is_gt(begin, 0), u => end, u => oldEnd), present}
    case KLiteral{kind, number, text, literalBegin, literalEnd}:
      f_choose(KTerm, U32.is_gt(begin, 0), u => k_with_span(t, begin, end), u => t)
    case KApp{quant, children, oldBegin, oldEnd}:
      KApp{quant, p163c_pattern_children(children, begin, end),
        f_choose(U32, U32.is_gt(begin, 0), u => begin, u => oldBegin),
        f_choose(U32, U32.is_gt(begin, 0), u => end, u => oldEnd)}

@unsafe
def kid(+t: KTerm, +n: U32) -> KTerm:
  match t:
    case KTerm{tag, name, id, quant, kids, removed, begin, end}: terms_at(kids, n)
    case KLambda{name, id, quant, kids, removed, begin, end, present}: terms_at(kids, n)
    case KLiteral{kind, number, text, begin, end}: KTerm{"Absent", "", 0, 0, [], [], 0, 0}
    case KApp{quant, children, begin, end}: p163c_at(children, n)

@unsafe
def app(+f: KTerm, +x: KTerm) -> KTerm:
  p163c_app(0, f, x, 0, 0)

@unsafe
def core_apply_span(+f: KTerm, +x: KTerm, +begin: U32, +end: U32) -> KTerm:
  kc(KTerm, p98_tag_eq(f, "Lam"), u => subst(kid(f, 0), ix(f), x), u => p163c_app(0, f, x, begin, end))

@unsafe
def f_app(
  +f: KTerm,
  +xs: List<&2, KTerm>,
) -> KTerm:
  match xs:
    case Nil{}:
      f
    case Con{x, xt}:
      f_app(p163c_app(1, f, x, 0, 0), xt)

@unsafe
def f_app_span(+f: KTerm, +xs: List<&2,KTerm>, +begin: U32, +end: U32) -> KTerm:
  match xs:
    case Nil{}: f
    case Con{x, rest}: f_app_span(p163c_app(1, f, x, begin, end), rest, begin, end)

@unsafe
def f_scope_app_span(+f: KTerm, +x: KTerm, +begin: U32, +end: U32) -> KTerm:
  f_choose(KTerm, f_eq(tg(f), "Lam"), u => f_sub(kid(f, 0), ix(f), x), u => p163c_app(0, f, x, begin, end))

@unsafe
def j_region_app(+head: KTerm, +args: List<&2,KTerm>) -> KTerm:
  match args:
    case Nil{}: head
    case Con{h, rest}: j_region_app(p163c_app(0, head, h, 0, 0), rest)

# Private canonical child storage: Many has at least three children intrinsically.
# The pinned checker declares ADTs whole before checking their field telescopes.
type KChildren is Data:
  KCZero{}
  KCOne{+a: KTerm}
  KCTwo{+a: KTerm, +b: KTerm}
  KCMany{+a: KTerm, +b: KTerm, +c: KTerm, +rest: List<&2,KTerm>}

@unsafe
def p163c_children(+kids: List<&2,KTerm>) -> KChildren:
  match kids:
    case Nil{}: KCZero{}
    case Con{a, rest}: p163c_children_one(a, rest)

@unsafe
def p163c_children_one(+a: KTerm, +rest: List<&2,KTerm>) -> KChildren:
  match rest:
    case Nil{}: KCOne{a}
    case Con{b, tail}: p163c_children_two(a, b, tail)

@unsafe
def p163c_children_two(+a: KTerm, +b: KTerm, +rest: List<&2,KTerm>) -> KChildren:
  match rest:
    case Nil{}: KCTwo{a, b}
    case Con{c, tail}: KCMany{a, b, c, tail}

@unsafe
def p163c_list(+children: KChildren) -> List<&2,KTerm>:
  match children:
    case KCZero{}: []
    case KCOne{a}: [a]
    case KCTwo{a, b}: [a, b]
    case KCMany{a, b, c, rest}: Con{a, Con{b, Con{c, rest}}}

@unsafe
def p163c_app(+quant: U32, +fun: KTerm, +arg: KTerm, +begin: U32, +end: U32) -> KTerm:
  KApp{quant, KCTwo{fun, arg}, begin, end}

@unsafe
def p163c_at(+children: KChildren, +n: U32) -> KTerm:
  match children:
    case KCZero{}: KTerm{"Absent", "", 0, 0, [], [], 0, 0}
    case KCOne{a}:
      kc(KTerm, U32.is_eq(n, 0), u => a, u => KTerm{"Absent", "", 0, 0, [], [], 0, 0})
    case KCTwo{a, b}:
      kc(KTerm, U32.is_eq(n, 0), u => a,
        u => kc(KTerm, U32.is_eq(n, 1), v => b, v => KTerm{"Absent", "", 0, 0, [], [], 0, 0}))
    case KCMany{a, b, c, rest}:
      kc(KTerm, U32.is_eq(n, 0), u => a,
        u => kc(KTerm, U32.is_eq(n, 1), v => b,
          v => kc(KTerm, U32.is_eq(n, 2), w => c, w => terms_at(rest, U32.sub(n, 3)))))

@unsafe
def p163c_subst_children(+children: KChildren, +id: U32, +value: KTerm) -> KChildren:
  match children:
    case KCZero{}: KCZero{}
    case KCOne{a}: KCOne{subst(a, id, value)}
    case KCTwo{a, b}: KCTwo{subst(a, id, value), subst(b, id, value)}
    case KCMany{a, b, c, rest}:
      KCMany{subst(a, id, value), subst(b, id, value), subst(c, id, value), subst_terms(rest, id, value)}

# All original children are substituted before App canonicalization, including
# malformed extra children. Canonicalization retains the original core path.
@unsafe
def p163c_subst_app(+children: KChildren, +begin: U32, +end: U32) -> KTerm:
  core_apply_span(p163c_at(children, 0), p163c_at(children, 1), begin, end)

@unsafe
def p163c_stable_children(+children: KChildren) -> Bool:
  match children:
    case KCZero{}: True{}
    case KCOne{a}: core_subst_stable(a)
    case KCTwo{a, b}:
      kc(Bool, core_subst_stable(a), u => core_subst_stable(b), u => False{})
    case KCMany{a, b, c, rest}:
      kc(Bool, core_subst_stable(a),
        u => kc(Bool, core_subst_stable(b),
          v => kc(Bool, core_subst_stable(c), w => core_subst_stable_terms(rest), w => False{}),
          v => False{}), u => False{})

@unsafe
def p163c_stable_app(+children: KChildren) -> Bool:
  match children:
    case KCTwo{fun, arg}: Bool.not(p98_tag_eq(fun, "Lam"))
    case _: False{}

@unsafe
def p163c_span_children(+children: KChildren, +begin: U32, +end: U32) -> KChildren:
  match children:
    case KCZero{}: KCZero{}
    case KCOne{a}: KCOne{f_span_created(a, begin, end)}
    case KCTwo{a, b}: KCTwo{f_span_created(a, begin, end), f_span_created(b, begin, end)}
    case KCMany{a, b, c, rest}:
      KCMany{f_span_created(a, begin, end), f_span_created(b, begin, end), f_span_created(c, begin, end), f_spans_created(rest, begin, end)}

@unsafe
def p163c_pattern_children(+children: KChildren, +begin: U32, +end: U32) -> KChildren:
  match children:
    case KCZero{}: KCZero{}
    case KCOne{a}: KCOne{f_pattern_value(a, begin, end)}
    case KCTwo{a, b}: KCTwo{f_pattern_value(a, begin, end), f_pattern_value(b, begin, end)}
    case KCMany{a, b, c, rest}:
      KCMany{f_pattern_value(a, begin, end), f_pattern_value(b, begin, end), f_pattern_value(c, begin, end), f_pattern_values(rest, begin, end)}
