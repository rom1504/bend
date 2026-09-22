# Surface expressions preserve proof terms, quantities, and annotations.
# Internal Literal nodes are expanded before checking; Error is never accepted.
type FParsed is Data:
  FParsed{+term: KTerm, +rest: List<&2, FToken>}

law f_pn:
  for +p: FParsed
  KTerm

law f_pr:
  for +p: FParsed
  List<&2, FToken>

law f_atid:
  for +ts: List<&2, FToken>
  U32

law f_err:
  for +ts: List<&2, FToken>
  for +msg: String
  FParsed

law f_expect:
  for +p: FParsed
  for +s: String
  FParsed

law f_app:
  for +f: KTerm
  for +xs: List<&2, KTerm>
  KTerm

law f_args:
  for +ts: List<&2, FToken>
  for +end: String
  for +acc: List<&2, KTerm>
  FParsed

law f_arg_next:
  for +p: FParsed
  for +end: String
  for +acc: List<&2, KTerm>
  FParsed

law f_expr:
  for +ts: List<&2, FToken>
  for +min: U32
  FParsed

law f_atom:
  for +ts: List<&2, FToken>
  FParsed

law f_kind_token:
  for +ts: List<&2, FToken>
  U32

law f_kind_wrap:
  for +p: FParsed
  FParsed

law f_mark:
  for +p: FParsed
  for +q: U32
  FParsed

law f_grade:
  for +ts: List<&2, FToken>
  FParsed

law f_quant:
  for +ts: List<&2, FToken>
  U32

law f_unmark:
  for +ts: List<&2, FToken>
  List<&2, FToken>

law f_all:
  for +ts: List<&2, FToken>
  for +exi: Bool
  FParsed

law f_all_domain:
  for +name: String
  for +id: U32
  for +q: U32
  for +exi: Bool
  for +p: FParsed
  FParsed

law f_all_body:
  for +name: String
  for +id: U32
  for +q: U32
  for +exi: Bool
  for +a: KTerm
  for +p: FParsed
  FParsed

law f_group:
  for +p: FParsed
  FParsed

law f_group_ann:
  for +n: KTerm
  for +p: FParsed
  FParsed

law f_tuple:
  for +n: KTerm
  for +p: FParsed
  FParsed

law f_list:
  for +p: FParsed
  FParsed

law f_list_nodes:
  for +xs: List<&2, KTerm>
  KTerm

law f_brace:
  for +ts: List<&2, FToken>
  FParsed

law f_brace_left:
  for +p: FParsed
  FParsed

law f_equation:
  for +a: KTerm
  for +neg: Bool
  for +p: FParsed
  FParsed

law f_equation_type:
  for +a: KTerm
  for +b: KTerm
  for +neg: Bool
  for +p: FParsed
  FParsed

law f_prec:
  for +s: String
  U32

law f_grow:
  for +p: FParsed
  for +min: U32
  FParsed

law f_grow_args:
  for +n: KTerm
  for +op: String
  for +min: U32
  for +p: FParsed
  FParsed

law f_binary:
  for +a: KTerm
  for +op: String
  for +min: U32
  for +p: FParsed
  FParsed

law f_binary_node:
  for +a: KTerm
  for +op: String
  for +b: KTerm
  KTerm

law f_operator:
  for +s: String
  String

law f_matcher:
  for +ts: List<&2, FToken>
  FParsed

law f_matcher_head:
  for +p: FParsed
  FParsed

law f_matcher_arm:
  for +name: String
  for +p: FParsed
  FParsed

law f_matcher_tail:
  for +name: String
  for +n: KTerm
  for +p: FParsed
  FParsed

@unsafe
def f_pn(p):
  match p:
    case FParsed{n, ts}:
      n

@unsafe
def f_pr(p):
  match p:
    case FParsed{n, ts}:
      ts

@unsafe
def f_atid(ts):
  U32.add(U32.mul(f_line(ts), 65536), f_col(ts))

@unsafe
def f_err(ts, msg):
  FParsed{kt("Error", "line " ++ U32.show(f_line(ts)) ++ ":" ++ U32.show(f_col(ts)) ++ ": " ++ msg ++ "; got " ++ f_tx(ts), 0, 0, Nil{}), Nil{}}

@unsafe
def f_expect(p, s):
  match p:
    case FParsed{+n, +ts}:
      f_choose(FParsed, f_eq(tg(n), "Error") || f_eq(f_tx(ts), s), u => FParsed{n, f_tl(ts)}, u => f_err(ts, "expected " ++ s))

@unsafe
def f_app(f, xs):
  match xs:
    case Nil{}:
      f
    case Con{x, xt}:
      f_app(kt("App", "", 0, 1, [f, x]), xt)

@unsafe
def f_args_base(ts, end, acc):
  +spaced = f_space(ts)
  f_choose(FParsed, f_eq(f_tx(spaced), ";"), u => f_err(spaced, f_choose(String, f_eq(end, "]"), u => "expected term; a list does not use semicolon separators", u => "expected term; arguments do not use semicolon separators")), u => f_choose(FParsed, f_eq(f_tx(spaced), end), u => FParsed{kt("Args", "", 0, 1, List.reverse(&2, KTerm, acc)), f_tl(spaced)}, u => f_arg_next(f_expr(spaced, 0), end, acc)))

@unsafe
def f_arg_next(p, end, acc):
  match p:
    case FParsed{+n, +ts}:
      f_choose(FParsed, f_eq(tg(n), "Error"), u => FParsed{n, ts}, u => f_args(f_choose(List<&2, FToken>, f_eq(f_tx(ts), ","), u => f_tl(ts), u => ts), end, Con{n, acc}))

@unsafe
def f_expr(ts, min):
  f_grow(f_atom(f_skip(ts)), min)

@unsafe
def f_atom_base(ts):
  f_choose(FParsed, f_eq(f_tx(ts), "("), u => f_group(f_body(f_tl(ts))),
    u => f_choose(FParsed, f_eq(f_tx(ts), "{"), u => f_brace(f_tl(ts)),
    u => f_choose(FParsed, f_eq(f_tx(ts), "["), u => f_array(f_tl(ts)),
    u => f_choose(FParsed, f_eq(f_tx(ts), "@"), u => f_all(f_tl(ts), False{}),
    u => f_choose(FParsed, f_eq(f_tx(ts), "&"), u => f_grade(f_tl(ts)),
    u => f_choose(FParsed, f_eq(f_tx(ts), "+") || f_eq(f_tx(ts), "+bind"), u => f_mark(f_atom(f_tl(ts)), 2),
    u => f_choose(FParsed, f_eq(f_tx(ts), "?"), u => FParsed{kt("Hol", f_tx(f_tl(ts)), 0, 0, Nil{}), f_tl(f_tl(ts))},
    u => f_choose(FParsed, f_eq(f_tx(ts), "\\"), u => f_matcher(f_tl(f_tl(ts))),
    u => f_choose(FParsed, f_eq(f_tx(ts), "Type") || f_eq(f_tx(ts), "Data"), u => FParsed{kt("Typ", "", 0, 0, [kt("Qua", "", 0, f_choose(U32, f_eq(f_tx(ts), "Data"), u => 2, u => 1), Nil{})]), f_tl(ts)},
    u => f_choose(FParsed, f_eq(f_tx(ts), "Quant"), u => FParsed{kt("Qnt", "", 0, 0, Nil{}), f_tl(ts)},
    u => f_choose(FParsed, f_eq(f_tx(ts), "Kind"), u => f_kind_wrap(f_expect(f_expr(f_tl(f_tl(ts)), 0), ")")),
    u => f_choose(FParsed, U32.is_eq(f_kind_token(ts), 2), u => FParsed{kt("Literal", f_tx(ts), 0, 1, Nil{}), f_tl(ts)},
    u => f_choose(FParsed, U32.is_eq(f_kind_token(ts), 1) && Bool.not(f_reserved(f_tx(ts))), u => f_atom_name(ts),
    u => f_err(ts, "expected term"))))))))))))))

# A constructor brace belongs to the raw name only when lexically adjacent.
# General term growth must not absorb the next independent braced value.
law f_atom_name:
  for +ts: List<&2, FToken>
  FParsed

@unsafe
def f_atom_name(ts):
  f_choose(FParsed, Bool.not(Char.is_digit(f_head(f_tx(ts)))) && f_eq(f_tx(f_tl(ts)), "{") && U32.is_eq(f_line(ts), f_line(f_tl(ts))) && U32.is_eq(f_col(f_tl(ts)), U32.add(f_col(ts), U32.from_nat(String.length(f_tx(ts))))),
    u => f_atom_constructor(f_tx(ts), f_atid(ts), f_args(f_tl(f_tl(ts)), "}", Nil{})),
    u => FParsed{kt(f_choose(String, Char.is_digit(f_head(f_tx(ts))), u => "Literal", u => "Ref"), f_tx(ts), f_atid(ts), 1, Nil{}), f_tl(ts)})

law f_atom_constructor:
  for +name: String
  for +id: U32
  for +p: FParsed
  FParsed

@unsafe
def f_atom_constructor(name, id, p):
  match p:
    case FParsed{+args, ts}:
      f_choose(FParsed, f_eq(tg(args), "Error"), u => FParsed{args, ts}, u => FParsed{kt("Ctr", name, id, 1, ks(args)), ts})

@unsafe
def f_kind_token(ts):
  f_kind(ts)

@unsafe
def f_kind_wrap(p):
  match p:
    case FParsed{n, ts}:
      FParsed{kt("Typ", "", 0, 0, [n]), ts}

@unsafe
def f_mark(p, q):
  match p:
    case FParsed{+n, ts}:
      f_choose(FParsed, f_eq(tg(n), "Ref") || f_eq(tg(n), "ADT") || f_eq(tg(n), "Error"), u => FParsed{kt(tg(n), nm(n), ix(n), q, ks(n)), ts}, u => f_err(ts, "+ requires a binder or quantified datatype"))

@unsafe
def f_grade(ts):
  f_choose(FParsed, f_eq(f_tx(ts), "0") || f_eq(f_tx(ts), "1") || f_eq(f_tx(ts), "2"), u => FParsed{kt("Qua", "", 0, f_choose(U32, f_eq(f_tx(ts), "0"), u => 0, u => f_choose(U32, f_eq(f_tx(ts), "1"), u => 1, u => 2)), Nil{}), f_tl(ts)}, u => f_all(ts, True{}))

@unsafe
def f_quant(ts):
  f_choose(U32, f_eq(f_tx(ts), "-") || f_eq(f_tx(ts), "~"), u => 0, u => f_choose(U32, f_eq(f_tx(ts), "+") || f_eq(f_tx(ts), "+bind"), u => 2, u => 1))

@unsafe
def f_unmark(ts):
  f_choose(List<&2, FToken>, U32.is_eq(f_quant(ts), 1), u => ts, u => f_tl(ts))

@unsafe
def f_all(ts, exi):
  f_choose(FParsed, f_eq(f_tx(ts), "~"), u => f_err(ts, "~ is only allowed on leading def or law template parameters"), u => f_all_domain(f_tx(f_unmark(ts)), f_atid(ts), f_quant(ts), exi, f_expect(f_expr(f_tl(f_tl(f_unmark(ts))), 1), "->")))

@unsafe
def f_all_domain(name, id, q, exi, p):
  match p:
    case FParsed{a, ts}:
      f_all_body(name, id, q, exi, a, f_expr(ts, 0))

@unsafe
def f_all_body(name, id, q, exi, a, p):
  match p:
    case FParsed{b, ts}:
      FParsed{f_choose(KTerm, exi, u => f_app(kt("Ref", "Exists", 0, 1, Nil{}), [a, kt("Lam", name, id, q, [b])]), u => kt("All", name, id, q, [a, b])), ts}

@unsafe
def f_group(p):
  match p:
    case FParsed{+n, +ts}:
      f_choose(FParsed, f_eq(f_tx(ts), ","), u => f_tuple(n, f_group(f_body(f_tl(ts)))), u => f_choose(FParsed, f_eq(f_tx(ts), ":"), u => f_group_namespace(n, f_expect(f_expr(f_tl(ts), 0), ")")), u => f_expect(FParsed{n, ts}, ")")))

@unsafe
def f_group_ann(n, p):
  match p:
    case FParsed{ty, ts}:
      FParsed{kt("Ann", "", 0, 1, [n, ty]), ts}

@unsafe
def f_tuple(n, p):
  match p:
    case FParsed{m, ts}:
      FParsed{kt("Ctr", "Tuple", 0, 1, [n, m]), ts}

@unsafe
def f_list(p):
  match p:
    case FParsed{+n, ts}:
      FParsed{f_choose(KTerm, f_eq(tg(n), "Error"), u => n, u => f_list_nodes(ks(n))), ts}

@unsafe
def f_list_nodes(xs):
  match xs:
    case Nil{}:
      kt("Ctr", "Nil", 0, 1, Nil{})
    case Con{x, xt}:
      kt("Ctr", "Con", 0, 1, [x, f_list_nodes(xt)])

@unsafe
def f_brace(ts):
  f_choose(FParsed, f_eq(f_tx(ts), "=="), u => f_expect(FParsed{kt("Rfl", "", 0, 1, Nil{}), f_tl(ts)}, "}"), u => f_brace_left(f_expr(ts, 0)))

@unsafe
def f_brace_left(p):
  match p:
    case FParsed{+a, +ts}:
      f_choose(FParsed, f_eq(f_tx(ts), "==") || f_eq(f_tx(ts), "!="), u => f_equation(a, f_eq(f_tx(ts), "!="), f_expect(f_expr(f_tl(ts), 0), ":")), u => f_group_ann(a, f_expect(f_expr(f_pr(f_expect(FParsed{a, ts}, ":")), 0), "}")))

@unsafe
def f_equation(a, neg, p):
  match p:
    case FParsed{b, ts}:
      f_equation_type(a, b, neg, f_expect(f_expr(ts, 0), "}"))

@unsafe
def f_equation_type(a, b, neg, p):
  match p:
    case FParsed{ty, ts}:
      FParsed{f_choose(KTerm, neg, u => kt("All", "_", 0, 1, [kt("Eql", "", 0, 1, [a, b, ty]), kt("Ref", "Empty", 0, 1, Nil{})]), u => kt("Eql", "", 0, 1, [a, b, ty])), ts}

@unsafe
def f_prec(s):
  f_choose(U32, f_eq(s, "=>") || f_eq(s, "->"), u => 1,
    u => f_choose(U32, f_eq(s, "&") || f_eq(s, "|"), u => 2,
    u => f_choose(U32, f_eq(s, "||"), u => 3,
    u => f_choose(U32, f_eq(s, "&&"), u => 4,
    u => f_choose(U32, f_eq(s, "<") || f_eq(s, ">op") || f_eq(s, "<=") || f_eq(s, ">="), u => 5,
    u => f_choose(U32, f_eq(s, "<>") || f_eq(s, "++") || f_eq(s, "<&>"), u => 6,
    u => f_choose(U32, f_eq(s, ".|."), u => 7,
    u => f_choose(U32, f_eq(s, ".^."), u => 8,
    u => f_choose(U32, f_eq(s, ".&."), u => 9,
    u => f_choose(U32, f_eq(s, "<<") || f_eq(s, ">>op"), u => 10,
    u => f_choose(U32, f_eq(s, "+") || f_eq(s, "-"), u => 11,
    u => f_choose(U32, f_eq(s, "*") || f_eq(s, "/") || f_eq(s, "%"), u => 12, u => 0))))))))))))

@unsafe
def f_grow_base(p, min):
  match p:
    case FParsed{+n, +ts}:
      f_choose(FParsed, f_eq(tg(n), "Error"), u => FParsed{n, ts},
        u => f_choose(FParsed, f_eq(f_tx(ts), "(") || (f_eq(f_tx(ts), "<") && Char.is_upper(f_head(nm(n)))),
          u => f_grow_args(n, f_tx(ts), min, f_args(f_tl(ts), f_choose(String, f_eq(f_tx(ts), "("), u => ")", u => ">"), Nil{})),
        u => f_choose(FParsed, U32.is_gt(f_prec(f_tx(ts)), min) && Bool.not((f_eq(f_tx(ts), "%") || f_eq(f_tx(ts), "-")) && U32.is_eq(f_col(f_tl(ts)), U32.add(f_col(ts), 1)) && Char.is_alpha(f_head(f_tx(f_tl(ts))))) && Bool.not(f_eq(f_tx(ts), ">")) && Bool.not(f_eq(f_tx(ts), ">>") && (f_eq(f_tx(f_tl(ts)), ")") || f_eq(f_tx(f_tl(ts)), "}") || f_eq(f_tx(f_tl(ts)), ",") || f_eq(f_tx(f_tl(ts)), ":") || f_eq(f_tx(f_tl(ts)), ">") || f_eq(f_tx(f_tl(ts)), "\n") || f_eq(f_tx(f_tl(ts)), "->") || f_eq(f_tx(f_tl(ts)), "<eof>") || f_eq(f_tx(f_tl(ts)), "]"))),
          u => f_binary(n, f_tx(ts), min, f_rhs_for(n, f_tl(ts), f_tx(ts), f_choose(U32, f_eq(f_tx(ts), "=>") || f_eq(f_tx(ts), "->") || f_eq(f_tx(ts), "<>") || f_eq(f_tx(ts), "&") || f_eq(f_tx(ts), "|"), u => U32.sub(f_prec(f_tx(ts)), 1), u => f_prec(f_tx(ts))))),
          u => FParsed{n, ts})))

@unsafe
def f_grow_args(n, op, min, p):
  match p:
    case FParsed{+args, ts}:
      f_choose(FParsed, f_eq(tg(args), "Error"), u => FParsed{args, ts}, u => f_grow(FParsed{f_choose(KTerm, f_eq(op, "("), u => kt("Call", "", 0, 1, Con{n, ks(args)}), u => kt("ADT", nm(n), ix(n), qt(n), ks(args))), ts}, min))

@unsafe
def f_binary(a, op, min, p):
  match p:
    case FParsed{b, ts}:
      f_grow(FParsed{f_binary_node(a, op, b), ts}, min)

@unsafe
def f_binary_plain(a, op, b):
  f_choose(KTerm, f_eq(op, "=>"), u => f_lambda_valid(a, b),
    u => f_choose(KTerm, f_eq(op, "->"), u => kt("All", "_", ix(a), 1, [a, b]),
    u => f_choose(KTerm, f_eq(op, "<>"), u => kt("Ctr", "Con", 0, 1, [a, b]),
    u => f_choose(KTerm, f_eq(op, "<&>"), u => kt("Min", "", 0, 1, [a, b]),
    u => f_app(kt("Ref", f_operator(op), 0, 1, Nil{}), [a, b])))))

@unsafe
def f_operator(s):
  f_choose(String, f_eq(s, "&"), u => "Pair", u => f_choose(String, f_eq(s, "|"), u => "Or", u => f_choose(String, f_eq(s, "++"), u => "String.append", u => f_choose(String, f_eq(s, "||"), u => "Bool.or", u => f_choose(String, f_eq(s, "&&"), u => "Bool.and", u => f_choose(String, f_eq(s, "+"), u => ".add", u => f_choose(String, f_eq(s, "-"), u => ".sub", u => f_choose(String, f_eq(s, "*"), u => ".mul", u => f_choose(String, f_eq(s, "/"), u => ".div", u => f_choose(String, f_eq(s, "%"), u => ".mod", u => f_choose(String, f_eq(s, "<"), u => ".is_lt", u => f_choose(String, f_eq(s, ">op"), u => ".is_gt", u => f_choose(String, f_eq(s, "<="), u => ".is_le", u => f_choose(String, f_eq(s, ">="), u => ".is_ge", u => f_choose(String, f_eq(s, "<<"), u => ".shln", u => f_choose(String, f_eq(s, ">>op"), u => ".shrn", u => f_choose(String, f_eq(s, ".&."), u => ".and", u => f_choose(String, f_eq(s, ".|."), u => ".or", u => f_choose(String, f_eq(s, ".^."), u => ".xor", u => s)))))))))))))))))))

@unsafe
def f_matcher(ts):
  f_choose(FParsed, f_eq(f_tx(ts), "}"), u => FParsed{kt("Efq", "", 0, 1, Nil{}), f_tl(ts)}, u => f_matcher_head(f_expr(ts, 0)))

@unsafe
def f_matcher_head(p):
  match p:
    case FParsed{+n, +ts}:
      f_choose(FParsed, f_eq(f_tx(ts), ":"), u => f_matcher_arm(nm(n), f_expr(f_tl(ts), 0)), u => f_expect(FParsed{n, ts}, "}"))

@unsafe
def f_matcher_arm(name, p):
  match p:
    case FParsed{n, ts}:
      f_matcher_tail(name, n, f_matcher(f_skip(ts)))

@unsafe
def f_matcher_tail(name, n, p):
  match p:
    case FParsed{m, ts}:
      FParsed{kt("Mat", name, 0, 1, [n, m]), ts}


law f_atom_base:
  for +ts: List<&2, FToken>
  FParsed

@unsafe
def f_atom(ts):
  f_choose(FParsed, f_eq(f_tx(ts), "~"), u => f_template_expr(f_expr(f_tl(ts), 0)), u => f_choose(FParsed, f_eq(f_tx(ts), "do"), u => f_do_start(f_tl(ts)), u => f_choose(FParsed, f_eq(f_tx(ts), "%"), u => f_rewrite(f_tl(ts)), u => f_atom_base(ts))))

law f_args_base:
  for +ts: List<&2, FToken>
  for +end: String
  for +acc: List<&2, KTerm>
  FParsed

@unsafe
def f_args(ts, end, acc):
  f_choose(FParsed, f_eq(end, ">") && f_eq(f_tx(ts), ">>"), u => FParsed{kt("Args", "", 0, 1, List.reverse(&2, KTerm, acc)), Con{FToken{">", f_line(ts), U32.add(f_col(ts), 1), 0}, f_tl(ts)}}, u => f_args_base(ts, end, acc))

law f_grow_base:
  for +p: FParsed
  for +min: U32
  FParsed

@unsafe
def f_grow(p, min):
  match p:
    case FParsed{n, +ts}:
      f_choose(FParsed, f_eq(f_tx(ts), "\n") && U32.is_gt(f_prec(f_tx(f_skip(ts))), 0) && Bool.not((f_eq(f_tx(f_skip(ts)), "%") || f_eq(f_tx(f_skip(ts)), "-")) && U32.is_eq(f_col(f_tl(f_skip(ts))), U32.add(f_col(f_skip(ts)), 1))), u => f_grow_base(FParsed{n, f_skip(ts)}, min), u => f_choose(FParsed, f_eq(f_tx(ts), "!"), u => f_bang(n, ts, min), u => f_choose(FParsed, f_eq(f_tx(ts), "["), u => f_index(n, f_expect(f_expr(f_tl(ts), 0), "]"), min), u => f_grow_base(FParsed{n, ts}, min))))

law f_binary_plain:
  for +a: KTerm
  for +op: String
  for +b: KTerm
  KTerm

@unsafe
def f_binary_node(a, op, b):
  f_choose(KTerm, f_eq(op, "+") && f_eq(tg(a), "Literal") && f_ends_nat(nm(a)), u => f_nat_plus(a, b), u => f_binary_plain(a, op, b))

law f_rhs:
  for +ts: List<&2, FToken>
  for +op: String
  for +min: U32
  FParsed

@unsafe
def f_rhs(ts, op, min):
  f_choose(FParsed, f_eq(op, "=>"), u => f_body(ts), u => f_expr(ts, min))

law f_rhs_for:
  for +left: KTerm
  for +ts: List<&2, FToken>
  for +op: String
  for +min: U32
  FParsed

@unsafe
def f_rhs_for(left, ts, op, min):
  f_choose(FParsed, f_eq(op, "+") && f_eq(tg(left), "Literal") && String.ends_with(nm(left), "n"), u => f_expr(ts, 0), u => f_rhs(ts, op, min))
