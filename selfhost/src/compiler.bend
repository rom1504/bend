import Base

# Bend2 self-hosting compiler. All lexical, syntactic and code-generation
# decisions live in this file. The generated programs use a small JS runtime.

type Token is Data:
  Token{text: String, line: U32, col: U32, kind: U32}

type Node is Data:
  Node{+tag: String, +text: String, +kids: List<&2, Node>}

type Parsed is Data:
  Parsed{+node: Node, +rest: List<&2, Token>}

type Scanned is Data:
  Scanned{+word: String, +rest: String, +size: U32}

law array_start:
  for +ts: List<&2, Token>
  Parsed

law array_after:
  for +p: Parsed
  Parsed

law array_type:
  for +n: Node
  for +ts: List<&2, Token>
  Parsed

law array_end:
  for +n: Node
  for +op: String
  for +p: Parsed
  Parsed

law index_end:
  for +n: Node
  for +p: Parsed
  for +min: U32
  Parsed

law index_set:
  for +n: Node
  for +idx: Node
  for +p: Parsed
  for +min: U32
  Parsed

law parallel_pats:
  for +ts: List<&2, Token>
  for +acc: List<&2, Node>
  Parsed

law parallel_pat:
  for +p: Parsed
  for +acc: List<&2, Node>
  Parsed

law parallel_values:
  for +ts: List<&2, Token>
  for +pats: List<&2, Node>
  for +left: U32
  for +acc: List<&2, Node>
  Parsed

law parallel_value:
  for +p: Parsed
  for +pats: List<&2, Node>
  for +left: U32
  for +acc: List<&2, Node>
  Parsed

law parallel_body:
  for +pats: List<&2, Node>
  for +vals: List<&2, Node>
  for +p: Parsed
  Parsed

law emit_extra:
  for +tag: String
  for +txt: String
  for +xs: List<&2, Node>
  for +ns: String
  for +tailpos: Bool
  String

law matcher_start:
  for +ts: List<&2, Token>
  Parsed

law matcher_branch:
  for +name: String
  for p: Parsed
  Parsed

law matcher_tail:
  for name: String
  for n: Node
  for p: Parsed
  Parsed

law do_mark:
  for p: Parsed
  for name: String
  Parsed

law mark_monad:
  for n: Node
  for +name: String
  Node

law mark_monads:
  for xs: List<&2, Node>
  for +name: String
  List<&2, Node>

law three:
  for +s: String
  String

law triple_op:
  for +s: String
  Bool

law symbol_text:
  for +s: String
  for +c: U32
  for +acc: List<&2, Token>
  String

law matcher_chain:
  for name: String
  for n: Node
  for p: Parsed
  Parsed

law first_error:
  for n: Node
  String

law first_errors:
  for ns: List<&2, Node>
  String

law error_rest:
  for +err: String
  for ns: List<&2, Node>
  String

law skip_annotation:
  for +ts: List<&2, Token>
  for +d: U32
  List<&2, Token>

law choose:
  for -A: Type
  for +b: Bool
  for yes: Unit -> A
  for no: Unit -> A
  A

law eq:
  for +a: String
  for +b: String
  Bool

law node:
  for +tag: String
  for +text: String
  Node

law nt:
  for +n: Node
  String

law ng:
  for +n: Node
  String

law nk:
  for +n: Node
  List<&2, Node>

law tx:
  for +ts: List<&2, Token>
  String

law tl:
  for +ts: List<&2, Token>
  List<&2, Token>

law line:
  for +ts: List<&2, Token>
  U32

law col:
  for +ts: List<&2, Token>
  U32

law kind:
  for +ts: List<&2, Token>
  U32

law fail:
  for +ts: List<&2, Token>
  for +msg: String
  Parsed

law skip:
  for +ts: List<&2, Token>
  List<&2, Token>

law head:
  for +s: String
  Char

law tail:
  for +s: String
  String

law ident:
  for +c: Char
  Bool

law scan_word:
  for +s: String
  for +acc: String
  for +n: U32
  Scanned

law scan_comment:
  for +s: String
  String

law scan_quote:
  for +s: String
  for +quote: Char
  for +acc: String
  for +n: U32
  Scanned

law two:
  for +s: String
  String

law pair_op:
  for +s: String
  Bool

law lex_scanned:
  for +sc: Scanned
  for +l: U32
  for +c: U32
  for +d: U32
  for +k: U32
  for +acc: List<&2, Token>
  List<&2, Token>

law lex_symbol:
  for +s: String
  for +l: U32
  for +c: U32
  for +d: U32
  for +acc: List<&2, Token>
  List<&2, Token>

law lex:
  for +s: String
  for +l: U32
  for +c: U32
  for +d: U32
  for +acc: List<&2, Token>
  List<&2, Token>

law pn:
  for +p: Parsed
  Node

law pr:
  for +p: Parsed
  List<&2, Token>

law expect:
  for +p: Parsed
  for +s: String
  Parsed

law collect:
  for +ts: List<&2, Token>
  for +end: String
  for +acc: List<&2, Node>
  Parsed

law collect_next:
  for +p: Parsed
  for +end: String
  for +acc: List<&2, Node>
  Parsed

law wrap:
  for +p: Parsed
  for +tag: String
  for +text: String
  Parsed

law atom:
  for +ts: List<&2, Token>
  Parsed

law annotation:
  for +p: Parsed
  Parsed

law annotated:
  for +n: Node
  for +p: Parsed
  Parsed

law group:
  for +p: Parsed
  Parsed

law prec:
  for +s: String
  U32

law expr:
  for +ts: List<&2, Token>
  for +min: U32
  Parsed

law grow:
  for +p: Parsed
  for +min: U32
  Parsed

law grow_apply:
  for +n: Node
  for +p: Parsed
  for +op: String
  for +min: U32
  Parsed

law grow_binary:
  for +a: Node
  for +op: String
  for +p: Parsed
  for +min: U32
  Parsed

law skip_type:
  for +ts: List<&2, Token>
  for +depth: U32
  for +end: String
  List<&2, Token>

law params:
  for +ts: List<&2, Token>
  for +end: String
  for +acc: List<&2, Node>
  Parsed

law params_tail:
  for +name: String
  for +ts: List<&2, Token>
  for +end: String
  for +acc: List<&2, Node>
  Parsed

law params_next:
  for +ts: List<&2, Token>
  for +end: String
  for +acc: List<&2, Node>
  Parsed

law body:
  for +ts0: List<&2, Token>
  Parsed

law body_start:
  for +ts: List<&2, Token>
  Parsed

law statement:
  for +p: Parsed
  for +indent: U32
  Parsed

law let_value:
  for +pat: Node
  for +p: Parsed
  Parsed

law let_body:
  for +pat: Node
  for +v: Node
  for +p: Parsed
  Parsed

law match_heads:
  for +ts: List<&2, Token>
  for +indent: U32
  for +acc: List<&2, Node>
  Parsed

law match_head_next:
  for +p: Parsed
  for +indent: U32
  for +acc: List<&2, Node>
  Parsed

law match_cases:
  for +ts: List<&2, Token>
  for +indent: U32
  for +heads: List<&2, Node>
  for +acc: List<&2, Node>
  Parsed

law case_pats:
  for +ts: List<&2, Token>
  for +indent: U32
  for +heads: List<&2, Node>
  for +acc: List<&2, Node>
  for +pats: List<&2, Node>
  Parsed

law case_pat_next:
  for +p: Parsed
  for +indent: U32
  for +heads: List<&2, Node>
  for +acc: List<&2, Node>
  for +pats: List<&2, Node>
  Parsed

law case_body:
  for +p: Parsed
  for +indent: U32
  for +heads: List<&2, Node>
  for +acc: List<&2, Node>
  for +pats: List<&2, Node>
  Parsed

law do_start:
  for +ts: List<&2, Token>
  Parsed

law do_body:
  for +ts: List<&2, Token>
  Parsed

law do_return:
  for +p: Parsed
  Parsed

law do_stmt:
  for +p: Parsed
  for +indent: U32
  Parsed

law do_value:
  for +pat: Node
  for +p: Parsed
  for +pure: Bool
  Parsed

law do_tail:
  for +pat: Node
  for +n: Node
  for +p: Parsed
  for +pure: Bool
  Parsed

law top:
  for +ts0: List<&2, Token>
  for +acc: List<&2, Node>
  Parsed

law top_start:
  for +ts: List<&2, Token>
  for +acc: List<&2, Node>
  Parsed

law top_type:
  for +name: String
  for +ts: List<&2, Token>
  for +acc: List<&2, Node>
  Parsed

law top_ctor:
  for +name: String
  for +ctor: String
  for +p: Parsed
  for +acc: List<&2, Node>
  Parsed

law top_params:
  for +name: String
  for +p: Parsed
  for +acc: List<&2, Node>
  Parsed

law top_body:
  for +name: String
  for +pars: Node
  for +p: Parsed
  for +acc: List<&2, Node>
  Parsed

law jsq:
  for +s: String
  String

law escape:
  for +s: String
  String

law join:
  for +xs: List<&2, String>
  for +sep: String
  String

law nth:
  for +xs: List<&2, Node>
  for +i: U32
  Node

law local:
  for +name: String
  String

law emit_args:
  for +xs: List<&2, Node>
  for +ns: String
  List<&2, String>

law emit:
  for +n: Node
  for +ns: String
  for +tailpos: Bool
  String

law emit_call:
  for +xs: List<&2, Node>
  for +ns: String
  for +tailpos: Bool
  String

law emit_op:
  for +op: String
  for +xs: List<&2, Node>
  for +ns: String
  String

law pattern:
  for +n: Node
  String

law patterns:
  for +xs: List<&2, Node>
  List<&2, String>

law emit_let:
  for +tag: String
  for +txt: String
  for +xs: List<&2, Node>
  for +ns: String
  for +tailpos: Bool
  String

law emit_match:
  for +xs: List<&2, Node>
  for +ns: String
  for +tailpos: Bool
  String

law emit_cases:
  for +xs: List<&2, Node>
  for +ns: String
  for +tailpos: Bool
  String

law param_bind:
  for +xs: List<&2, Node>
  for +i: U32
  String

law count:
  for +xs: List<&2, Node>
  U32

law emit_top:
  for +xs: List<&2, Node>
  String

law param_names:
  for +xs: List<&2, Node>
  List<&2, String>

law read_file:
  for +path: String
  IO(String)

law read_close:
  for pair: File & Result<&1, &1, U32 & String, String>
  IO(String)

law compile_result:
  for +p: Parsed
  for +runtime: String
  IO(Unit)

law compile_path:
  for +path: String
  for +runtime_path: String
  IO(Unit)

law cli:
  for args: List<String>
  IO(Unit)

law main:
  IO(Unit)

law skip_decl:
  for +ts: List<&2, Token>
  List<&2, Token>

law skip_angles:
  for +ts: List<&2, Token>
  for +depth: U32
  List<&2, Token>

@unsafe
def choose(A, b, yes, no):
  match b:
    case True{}:
      yes(Unit{})
    case False{}:
      no(Unit{})

@unsafe
def eq(a, b):
  String.eq(a, b)

@unsafe
def node(tag, text):
  Node{tag, text, Nil{}}

@unsafe
def nt(n):
  match n:
    case Node{tag, text, kids}:
      text

@unsafe
def ng(n):
  match n:
    case Node{tag, text, kids}:
      tag

@unsafe
def nk(n):
  match n:
    case Node{tag, text, kids}:
      kids

@unsafe
def tx(ts):
  match ts:
    case Nil{}:
      "<eof>"
    case Con{Token{t, l, c, k}, rest}:
      t

@unsafe
def tl(ts):
  match ts:
    case Nil{}:
      Nil{}
    case Con{t, rest}:
      rest

@unsafe
def line(ts):
  match ts:
    case Nil{}:
      0
    case Con{Token{t, l, c, k}, rest}:
      l

@unsafe
def col(ts):
  match ts:
    case Nil{}:
      0
    case Con{Token{t, l, c, k}, rest}:
      c

@unsafe
def kind(ts):
  match ts:
    case Nil{}:
      0
    case Con{Token{t, l, c, k}, rest}:
      k

@unsafe
def fail(ts, msg):
  Parsed{node("error", "line " ++ U32.show(line(ts)) ++ ": " ++ msg ++ "; got " ++ tx(ts)), Nil{}}

@unsafe
def skip(ts):
  choose(List<&2, Token>, Bool.or(eq(tx(ts), "\n"), eq(tx(ts), ";")),
    u => skip(tl(ts)), u => ts)

@unsafe
def head(s):
  match s:
    case SNil{}:
      '\0'
    case SCon{h, t}:
      h

@unsafe
def tail(s):
  match s:
    case SNil{}:
      ""
    case SCon{h, t}:
      t

@unsafe
def ident(c):
  Char.is_alpha(c) || Char.is_digit(c) || Char.is_eq(c, '_') || Char.is_eq(c, '.')

@unsafe
def scan_word(s, acc, n):
  choose(Scanned, ident(head(s)) || ((Char.is_eq(head(s), '+') || Char.is_eq(head(s), '-')) && (Char.is_eq(head(acc), 'e') || Char.is_eq(head(acc), 'E')) && Char.is_digit(head(tail(s)))),
    u => scan_word(tail(s), SCon{head(s), acc}, U32.add(n, 1)),
    u => Scanned{String.reverse(acc), s, n})

@unsafe
def scan_comment(s):
  choose(String, String.is_empty(s) || Char.is_eq(head(s), '\n'),
    u => s, u => scan_comment(tail(s)))

@unsafe
def scan_quote(s, quote, acc, n):
  choose(Scanned, String.is_empty(s),
    u => Scanned{"", "", 0},
    u => choose(Scanned, Char.is_eq(head(s), quote),
      u => Scanned{String.reverse(SCon{quote, acc}), tail(s), U32.add(n, 1)},
      u => choose(Scanned, Char.is_eq(head(s), '\\'),
        u => scan_quote(tail(tail(s)), quote, SCon{head(tail(s)), SCon{'\\', acc}}, U32.add(n, 2)),
        u => scan_quote(tail(s), quote, SCon{head(s), acc}, U32.add(n, 1)))))

@unsafe
def two(s):
  SCon{head(s), SCon{head(tail(s)), ""}}

@unsafe
def pair_op(s):
  eq(s, "->") || eq(s, "=>") || eq(s, "<-") || eq(s, "++") || eq(s, "<>") || eq(s, "==") || eq(s, "!=") || eq(s, "<=") || eq(s, ">=") || eq(s, "&&") || eq(s, "||") || eq(s, "<<") || eq(s, ">>")

@unsafe
def lex_scanned(sc, l, c, d, k, acc):
  match sc:
    case Scanned{word, rest, size}:
      choose(List<&2, Token>, U32.is_eq(size, 0),
        u => List.reverse(&2, Token, Con{Token{"unterminated string", l, c, 3}, acc}),
        u => lex(rest, l, U32.add(c, size), d, Con{Token{word, l, c, k}, acc}))

@unsafe
def lex_symbol(s, l, c, d, acc):
  choose(List<&2, Token>, pair_op(two(s)),
    u => lex(tail(tail(s)), l, U32.add(c, 2), d, Con{Token{two(s), l, c, 0}, acc}),
    u => lex(tail(s), l, U32.add(c, 1),
      choose(U32, Char.is_eq(head(s), '(') || Char.is_eq(head(s), '[') || Char.is_eq(head(s), '{'),
        u => U32.add(d, 1),
        u => choose(U32, Char.is_eq(head(s), ')') || Char.is_eq(head(s), ']') || Char.is_eq(head(s), '}'),
          u => U32.sub(d, 1), u => d)),
      Con{Token{symbol_text(s, c, acc), l, c, 0}, acc}))

@unsafe
def lex(s, l, c, d, acc):
  choose(List<&2, Token>, String.is_empty(s),
    u => List.reverse(&2, Token, acc),
    u => choose(List<&2, Token>, Char.is_eq(head(s), '\n'),
      u => lex(tail(s), U32.add(l, 1), 0, d,
        choose(List<&2, Token>, U32.is_eq(d, 0), u => Con{Token{"\n", l, c, 0}, acc}, u => acc)),
      u => choose(List<&2, Token>, Char.is_space(head(s)),
        u => lex(tail(s), l, U32.add(c, 1), d, acc),
        u => choose(List<&2, Token>, Char.is_eq(head(s), '#'),
          u => lex(scan_comment(s), l, c, d, acc),
          u => choose(List<&2, Token>, Char.is_eq(head(s), '"') || Char.is_eq(head(s), '\''),
            u => lex_scanned(scan_quote(tail(s), head(s), SCon{head(s), ""}, 1), l, c, d, 2, acc),
            u => choose(List<&2, Token>, triple_op(s),
              u => lex(tail(tail(tail(s))), l, U32.add(c, 3), d, Con{Token{three(s), l, c, 0}, acc}),
            u => choose(List<&2, Token>, ident(head(s)),
              u => lex_scanned(scan_word(s, "", 0), l, c, d, 1, acc),
              u => lex_symbol(s, l, c, d, acc))))))))

# Parsing uses persistent tokens and explicit result values, including errors.

@unsafe
def pn(p):
  match p:
    case Parsed{n, ts}:
      n

@unsafe
def pr(p):
  match p:
    case Parsed{n, ts}:
      ts

@unsafe
def expect(p, s):
  match p:
    case Parsed{+n, +ts}:
      choose(Parsed, eq(ng(n), "error"), u => Parsed{n, ts},
        u => choose(Parsed, eq(tx(ts), s), u => Parsed{n, tl(ts)}, u => fail(ts, "expected " ++ s)))

@unsafe
def collect(ts, end, acc):
  choose(Parsed, eq(tx(ts), end),
    u => Parsed{Node{"items", "", List.reverse(&2, Node, acc)}, tl(ts)},
    u => collect_next(expr(ts, 0), end, acc))

@unsafe
def collect_next(p, end, acc):
  match p:
    case Parsed{+n, +ts}:
      choose(Parsed, eq(ng(n), "error"), u => Parsed{n, ts},
        u => choose(Parsed, eq(tx(ts), ","),
          u => collect(tl(ts), end, Con{n, acc}),
          u => expect(Parsed{Node{"items", "", List.reverse(&2, Node, Con{n, acc})}, ts}, end)))

@unsafe
def wrap(p, tag, text):
  match p:
    case Parsed{+n, ts}:
      choose(Parsed, eq(ng(n), "error"), u => Parsed{n, ts},
        u => Parsed{Node{tag, text, nk(n)}, ts})

@unsafe
def atom(ts):
  choose(Parsed, eq(tx(ts), "+") || eq(tx(ts), "+bind") || eq(tx(ts), "-") || eq(tx(ts), "~"),
    u => choose(Parsed, eq(tx(ts), "-") && Char.is_digit(head(tx(tl(ts)))),
      u => Parsed{node("lit", "-" ++ tx(tl(ts))), tl(tl(ts))}, u => atom(tl(ts))),
    u => choose(Parsed, eq(tx(ts), "("),
      u => group(expr(tl(ts), 0)),
      u => choose(Parsed, eq(tx(ts), "["),
        u => array_start(tl(ts)),
        u => choose(Parsed, eq(tx(ts), "{"),
          u => choose(Parsed, eq(tx(tl(ts)), "=="),
            u => expect(Parsed{node("lit", "null"), tl(tl(ts))}, "}"),
            u => expect(annotation(expr(tl(ts), 0)), "}")),
          u => choose(Parsed, eq(tx(ts), "&"),
            u => Parsed{node("lit", "null"), tl(tl(ts))},
            u => choose(Parsed, U32.is_eq(kind(ts), 2),
              u => Parsed{node("lit", tx(ts)), tl(ts)},
              u => choose(Parsed, U32.is_eq(kind(ts), 1),
                u => choose(Parsed, Char.is_digit(head(tx(ts))),
                  u => Parsed{node("lit", tx(ts)), tl(ts)},
                  u => Parsed{node("var", tx(ts)), tl(ts)}),
                u => choose(Parsed, eq(tx(ts), "@"),
                  u => Parsed{node("lit", "null"), skip_type(ts, 0, ")")},
                u => choose(Parsed, eq(tx(ts), "\\"),
                  u => matcher_start(tl(tl(ts))),
                  u => fail(ts, "expected expression"))))))))))

@unsafe
def annotation(p):
  match p:
    case Parsed{+n, +ts}:
      choose(Parsed, eq(tx(ts), ":"),
        u => Parsed{Node{"ann", "", [n, node("var", tx(tl(ts)))]}, skip_annotation(tl(ts), 0)}, u => Parsed{n, ts})

@unsafe
def annotated(n, p):
  match p:
    case Parsed{+ty, ts}:
      choose(Parsed, eq(ng(ty), "error"), u => Parsed{ty, ts},
        u => Parsed{Node{"ann", "", [n, ty]}, ts})

@unsafe
def group(p):
  match p:
    case Parsed{+n, +ts}:
      choose(Parsed, eq(tx(ts), ","),
        u => wrap(collect(tl(ts), ")", [n]), "ctor", "Tuple"),
        u => expect(annotation(Parsed{n, ts}), ")"))

# Operator precedences mirror Bend2's ordinary computational expressions.
@unsafe
def prec(s):
  choose(U32, eq(s, "=>"), u => 1,
    u => choose(U32, eq(s, "->"), u => 2,
      u => choose(U32, eq(s, "||"), u => 3,
        u => choose(U32, eq(s, "&&"), u => 4,
          u => choose(U32, eq(s, "<>") || eq(s, "++") || eq(s, "&") || eq(s, "|"), u => 5,
            u => choose(U32, eq(s, "<") || eq(s, ">") || eq(s, "<=") || eq(s, ">=") || eq(s, "==") || eq(s, "!="), u => 6,
              u => choose(U32, eq(s, "+") || eq(s, "-"), u => 8,
                u => choose(U32, eq(s, "*") || eq(s, "/") || eq(s, "%"), u => 9,
                  u => choose(U32, eq(s, ".&.") || eq(s, ".|.") || eq(s, ".^.") || eq(s, "<<") || eq(s, ">>"), u => 7, u => 0)))))))))

@unsafe
def expr(ts, min):
  grow(atom(skip(ts)), min)

@unsafe
def grow(p, min):
  match p:
    case Parsed{+n, +ts}:
      choose(Parsed, eq(ng(n), "error"), u => Parsed{n, ts},
        u => choose(Parsed, eq(tx(ts), "\n") && U32.is_gt(prec(tx(skip(ts))), 0) && U32.is_gt(col(tl(skip(ts))), U32.add(col(skip(ts)), 1)),
          u => grow(Parsed{n, skip(ts)}, min),
        u => choose(Parsed, eq(tx(ts), "(") || eq(tx(ts), "{"),
          u => grow_apply(n, collect(tl(ts), choose(String, eq(tx(ts), "("), u => ")", u => "}"), Nil{}), tx(ts), min),
          u => choose(Parsed, eq(tx(ts), "<") && Char.is_upper(head(nt(n))),
            u => grow(Parsed{node("lit", "null"), skip_angles(tl(ts), 0)}, min),
          u => choose(Parsed, eq(tx(ts), "["),
            u => index_end(n, expect(expr(tl(ts), 0), "]"), min),
          u => choose(Parsed, eq(tx(ts), "!"), u => grow(Parsed{n, tl(ts)}, min),
            u => choose(Parsed, U32.is_gt(prec(tx(ts)), min),
              u => grow_binary(n, tx(ts), expr(tl(ts),
                choose(U32, eq(tx(ts), "=>") || eq(tx(ts), "->") || eq(tx(ts), "<>"), u => U32.sub(prec(tx(ts)), 1), u => prec(tx(ts)))), min),
              u => Parsed{n, ts})))))))

@unsafe
def grow_apply(n, p, op, min):
  match p:
    case Parsed{+args, ts}:
      choose(Parsed, eq(ng(args), "error"), u => Parsed{args, ts},
        u => grow(Parsed{choose(Node, eq(op, "("),
          u => Node{"call", "", Con{n, nk(args)}},
          u => Node{"ctor", nt(n), nk(args)}), ts}, min))

@unsafe
def grow_binary(a, op, p, min):
  match p:
    case Parsed{+b, ts}:
      choose(Parsed, eq(ng(b), "error"), u => Parsed{b, ts},
        u => grow(Parsed{Node{choose(String, eq(op, "=>"), u => "lambda", u => "op"), op, [a, b]}, ts}, min))

# Skip a type annotation structurally. Type checking belongs to the separately
# pinned upstream checker during bootstrap; this compiler does not certify proofs.
@unsafe
def skip_type(ts, depth, end):
  choose(List<&2, Token>, eq(tx(ts), "<eof>"), u => ts,
    u => choose(List<&2, Token>, U32.is_eq(depth, 0) && (eq(tx(ts), end) || eq(tx(ts), ",") || eq(tx(ts), "=") || (eq(end, "\n") && eq(tx(ts), "<-"))), u => ts,
      u => skip_type(tl(ts),
        choose(U32, eq(tx(ts), "(") || eq(tx(ts), "{") || eq(tx(ts), "[") || eq(tx(ts), "<") || eq(tx(ts), "<-"), u => U32.add(depth, 1),
          u => choose(U32, eq(tx(ts), ")") || eq(tx(ts), "}") || eq(tx(ts), "]") || eq(tx(ts), ">"), u => U32.sub(depth, 1), u => choose(U32, eq(tx(ts), ">>"), u => U32.sub(depth, 2), u => depth))), end)))

@unsafe
def params(ts, end, acc):
  choose(Parsed, eq(tx(ts), end),
    u => Parsed{Node{"params", "", List.reverse(&2, Node, acc)}, tl(ts)},
    u => choose(Parsed, eq(tx(ts), "+") || eq(tx(ts), "+bind") || eq(tx(ts), "-") || eq(tx(ts), "~"),
      u => params(tl(ts), end, acc),
      u => params_tail(tx(ts), tl(ts), end, acc)))

@unsafe
def params_tail(name, ts, end, acc):
  params_next(choose(List<&2, Token>, eq(tx(ts), ":"),
    u => skip_type(tl(ts), 0, end), u => ts), end, Con{node("var", name), acc})

@unsafe
def params_next(ts, end, acc):
  choose(Parsed, eq(tx(ts), ","), u => params(tl(ts), end, acc),
    u => choose(Parsed, eq(tx(ts), end), u => params(ts, end, acc), u => fail(ts, "expected parameter delimiter")))

@unsafe
def body(ts0):
  body_start(skip(ts0))

@unsafe
def body_start(ts):
  choose(Parsed, eq(tx(ts), "match"),
    u => match_heads(tl(ts), col(ts), Nil{}),
    u => choose(Parsed, eq(tx(ts), "do"),
      u => do_start(tl(ts)),
      u => statement(expr(ts, 0), col(ts))))

@unsafe
def statement(p, indent):
  match p:
    case Parsed{+n, +ts}:
      choose(Parsed, eq(ng(n), "error"), u => Parsed{n, ts},
        u => choose(Parsed, eq(tx(ts), "="),
          u => let_value(n, expr(tl(ts), 0)),
          u => choose(Parsed, eq(tx(ts), ":"),
            u => statement(Parsed{n, skip_type(tl(ts), 0, "\n")}, indent),
            u => choose(Parsed, eq(ng(n), "set") && U32.is_eq(col(skip(ts)), indent),
              u => let_body(nth(nk(n), 0), n, body(ts)),
              u => choose(Parsed, Bool.not(eq(tx(ts), "\n")) && Bool.not(eq(tx(ts), ";")) && Bool.not(eq(tx(ts), "<eof>")) && Bool.not(eq(tx(ts), ")")) && Bool.not(eq(tx(ts), ",")),
                u => parallel_pats(ts, [n]),
                u => Parsed{n, ts})))))

@unsafe
def let_value(pat, p):
  match p:
    case Parsed{+v, ts}:
      choose(Parsed, eq(ng(v), "error"), u => Parsed{v, ts},
        u => let_body(pat, v, body(ts)))

@unsafe
def let_body(pat, v, p):
  match p:
    case Parsed{+b, ts}:
      choose(Parsed, eq(ng(b), "error"), u => Parsed{b, ts},
        u => Parsed{Node{"let", "", [pat, v, b]}, ts})

@unsafe
def match_heads(ts, indent, acc):
  choose(Parsed, eq(tx(ts), ":"),
    u => match_cases(skip(tl(ts)), indent, List.reverse(&2, Node, acc), Nil{}),
    u => choose(Parsed, eq(tx(ts), ","), u => match_heads(tl(ts), indent, acc),
      u => match_head_next(expr(ts, 0), indent, acc)))

@unsafe
def match_head_next(p, indent, acc):
  match p:
    case Parsed{+n, ts}:
      choose(Parsed, eq(ng(n), "error"), u => Parsed{n, ts},
        u => match_heads(ts, indent, Con{n, acc}))

@unsafe
def match_cases(ts, indent, heads, acc):
  choose(Parsed, eq(tx(ts), "case") && U32.is_gt(col(ts), indent),
    u => case_pats(tl(ts), indent, heads, acc, Nil{}),
    u => Parsed{Node{"match", "", Con{Node{"heads", "", heads}, List.reverse(&2, Node, acc)}}, ts})

@unsafe
def case_pats(ts, indent, heads, acc, pats):
  choose(Parsed, eq(tx(ts), ":"),
    u => case_body(body(tl(ts)), indent, heads, acc, List.reverse(&2, Node, pats)),
    u => choose(Parsed, eq(tx(ts), ","), u => case_pats(tl(ts), indent, heads, acc, pats),
      u => case_pat_next(expr(ts, 0), indent, heads, acc, pats)))

@unsafe
def case_pat_next(p, indent, heads, acc, pats):
  match p:
    case Parsed{+n, ts}:
      choose(Parsed, eq(ng(n), "error"), u => Parsed{n, ts},
        u => case_pats(ts, indent, heads, acc, Con{n, pats}))

@unsafe
def case_body(p, indent, heads, acc, pats):
  match p:
    case Parsed{+n, ts}:
      choose(Parsed, eq(ng(n), "error"), u => Parsed{n, ts},
        u => match_cases(skip(ts), indent, heads, Con{Node{"case", "", [Node{"pats", "", pats}, n]}, acc}))

@unsafe
def do_start(ts):
  do_mark(do_body(skip(tl(skip_type(ts, 0, ":")))), tx(ts))

@unsafe
def do_body(ts):
  choose(Parsed, eq(tx(ts), "return"),
    u => do_return(expr(tl(ts), 0)),
    u => do_stmt(expr(ts, 0), col(ts)))

@unsafe
def do_return(p):
  match p:
    case Parsed{n, ts}:
      Parsed{Node{"pure", "", [n]}, ts}

@unsafe
def do_stmt(p, indent):
  match p:
    case Parsed{+n, +ts}:
      choose(Parsed, eq(ng(n), "error"), u => Parsed{n, ts},
        u => choose(Parsed, eq(tx(ts), ":"),
          u => do_stmt(Parsed{n, skip_type(tl(ts), 0, "\n")}, indent),
          u => choose(Parsed, eq(tx(ts), "<-") || eq(tx(ts), "="),
            u => do_value(n, expr(tl(ts), 0), eq(tx(ts), "=")),
            u => choose(Parsed, U32.is_eq(col(skip(ts)), indent) && Bool.not(eq(tx(skip(ts)), "<eof>")),
              u => do_value(node("var", "_"), Parsed{n, ts}, False{}),
              u => Parsed{n, ts}))))

@unsafe
def do_value(pat, p, pure):
  match p:
    case Parsed{+n, ts}:
      choose(Parsed, eq(ng(n), "error"), u => Parsed{n, ts},
        u => do_tail(pat, n, do_body(skip(ts)), pure))

@unsafe
def do_tail(pat, n, p, pure):
  match p:
    case Parsed{+b, ts}:
      choose(Parsed, eq(ng(b), "error"), u => Parsed{b, ts},
        u => Parsed{Node{choose(String, pure, u => "let", u => "bind"), "", [pat, n, b]}, ts})

@unsafe
def top(ts0, acc):
  top_start(skip(ts0), acc)

@unsafe
def top_start(ts, acc):
  choose(Parsed, eq(tx(ts), "<eof>"),
    u => Parsed{Node{"book", "", List.reverse(&2, Node, acc)}, ts},
    u => choose(Parsed, eq(tx(ts), "@"),
      u => choose(Parsed, eq(tx(tl(ts)), "unsafe"), u => top(tl(tl(ts)), acc), u => fail(ts, "only @unsafe is supported")),
      u => choose(Parsed, eq(tx(ts), "import"),
        u => choose(Parsed, eq(tx(tl(ts)), "Base"), u => top(skip_type(tl(ts), 0, "\n"), acc),
          u => fail(ts, "module imports are not implemented; compile a single file with import Base")),
        u => choose(Parsed, eq(tx(ts), "type"),
          u => top_type(tx(tl(ts)), skip(tl(skip_type(tl(tl(ts)), 0, ":"))), acc),
          u => choose(Parsed, eq(tx(ts), "def"),
            u => top_params(tx(tl(ts)), params(tl(tl(tl(ts))), ")", Nil{}), acc),
            u => choose(Parsed, eq(tx(ts), "law"),
              u => top(skip_decl(skip(tl(skip_type(tl(ts), 0, ":")))), acc),
              u => fail(ts, "expected def, type, law or import")))))))

@unsafe
def top_type(name, ts, acc):
  choose(Parsed, U32.is_gt(col(ts), 0) && Bool.not(eq(tx(ts), "<eof>")),
    u => top_ctor(name, tx(ts), params(tl(tl(ts)), "}", Nil{}), acc),
    u => top(ts, Con{node("type", name), acc}))

@unsafe
def top_ctor(name, ctor, p, acc):
  match p:
    case Parsed{+n, ts}:
      choose(Parsed, eq(ng(n), "error"), u => Parsed{n, ts},
        u => top_type(name, skip(ts), Con{Node{"constructor", ctor, nk(n)}, acc}))

@unsafe
def top_params(name, p, acc):
  match p:
    case Parsed{+n, +ts}:
      choose(Parsed, eq(ng(n), "error"), u => Parsed{n, ts},
        u => top_body(name, n, body(tl(skip_type(ts, 0, ":"))), acc))

@unsafe
def top_body(name, pars, p, acc):
  match p:
    case Parsed{+n, ts}:
      choose(Parsed, eq(ng(n), "error"), u => Parsed{n, ts},
        u => top(ts, Con{Node{"def", name, [pars, n]}, acc}))

# Code generation.
# Functions are curried at the runtime boundary. Tail positions yield a bounce
# object, so generated recursive calls use bounded JavaScript stack space.

@unsafe
def jsq(s):
  "\"" ++ escape(s) ++ "\""

@unsafe
def escape(s):
  match s:
    case SNil{}:
      ""
    case SCon{+h, t}:
      choose(String, Char.is_eq(h, '"'), u => "\\\"",
        u => choose(String, Char.is_eq(h, '\\'), u => "\\\\",
          u => choose(String, Char.is_eq(h, '\n'), u => "\\n",
            u => choose(String, Char.is_eq(h, '\r'), u => "\\r",
              u => choose(String, Char.is_eq(h, '\t'), u => "\\t", u => SCon{h, ""}))))) ++ escape(t)

@unsafe
def join(xs, sep):
  match xs:
    case Nil{}:
      ""
    case Con{h, Nil{}}:
      h
    case Con{h, t}:
      h ++ sep ++ join(t, sep)

@unsafe
def nth(xs, i):
  match xs:
    case Nil{}:
      node("missing", "")
    case Con{+h, +t}:
      choose(Node, U32.is_eq(i, 0), u => h, u => nth(t, U32.sub(i, 1)))

@unsafe
def local(name):
  "v[" ++ jsq(name) ++ "]"

@unsafe
def emit_args(xs, ns):
  match xs:
    case Nil{}:
      Nil{}
    case Con{h, t}:
      Con{emit(h, ns, False{}), emit_args(t, ns)}

@unsafe
def emit(n, ns, tailpos):
  match n:
    case Node{+tag, +txt, +xs}:
      choose(String, eq(tag, "lit"), u => "literal(" ++ jsq(txt) ++ ")",
        u => choose(String, eq(tag, "var"), u => "get(v," ++ jsq(txt) ++ ")",
          u => choose(String, eq(tag, "ann"), u => emit(nth(xs, 0), nt(nth(xs, 1)), tailpos),
            u => choose(String, eq(tag, "ctor"), u => "ctor(" ++ jsq(txt) ++ ",[" ++ join(emit_args(xs, ns), ",") ++ "])",
              u => choose(String, eq(tag, "list"), u => "list([" ++ join(emit_args(xs, ns), ",") ++ "])",
                u => choose(String, eq(tag, "call"),
                  u => emit_call(xs, ns, tailpos),
                  u => choose(String, eq(tag, "lambda"),
                    u => "fn(1,function(a){const v=scope(this);v[" ++ jsq(nt(nth(xs, 0))) ++ "]=a[0];return " ++ emit(nth(xs, 1), ns, True{}) ++ ";},v)",
                    u => choose(String, eq(tag, "op"), u => emit_op(txt, xs, ns),
                      u => choose(String, eq(tag, "let") || eq(tag, "bind"), u => emit_let(tag, txt, xs, ns, tailpos),
                        u => choose(String, eq(tag, "match"), u => emit_match(xs, ns, tailpos),
                          u => choose(String, eq(tag, "pure"), u => "monadpure(" ++ jsq(txt) ++ "," ++ emit(nth(xs, 0), ns, False{}) ++ ")",
                            u => emit_extra(tag, txt, xs, ns, tailpos))))))))))))

@unsafe
def emit_call(xs, ns, tailpos):
  match xs:
    case Nil{}:
      "bad(\"empty call\")"
    case Con{h, t}:
      choose(String, tailpos, u => "jump(", u => "call(") ++ emit(h, ns, False{}) ++ ",[" ++ join(emit_args(t, ns), ",") ++ "])"

@unsafe
def emit_op(op, xs, ns):
  "op(" ++ jsq(op) ++ "," ++ jsq(ns) ++ "," ++ emit(nth(xs, 0), ns, False{}) ++ "," ++ emit(nth(xs, 1), ns, False{}) ++ ")"

@unsafe
def pattern(n):
  match n:
    case Node{+tag, txt, xs}:
      "[" ++ jsq(tag) ++ "," ++ jsq(txt) ++ ",[" ++ join(patterns(xs), ",") ++ "]]"

@unsafe
def patterns(xs):
  match xs:
    case Nil{}:
      Nil{}
    case Con{h, t}:
      Con{pattern(h), patterns(t)}

@unsafe
def emit_let(tag, txt, xs, ns, tailpos):
  choose(String, eq(tag, "bind"),
    u => "monadbind(" ++ jsq(txt) ++ "," ++ emit(nth(xs, 1), ns, False{}) ++ ",(x)=>{const w=scope(v);bindpat(w," ++ pattern(nth(xs, 0)) ++ ",x);return ((v)=>" ++ emit(nth(xs, 2), ns, True{}) ++ ")(w);})",
    u => "((w)=>{bindpat(w," ++ pattern(nth(xs, 0)) ++ "," ++ emit(nth(xs, 1), ns, False{}) ++ ");return ((v)=>" ++ emit(nth(xs, 2), ns, tailpos) ++ ")(w);})(scope(v))")

@unsafe
def emit_match(xs, ns, tailpos):
  match xs:
    case Nil{}:
      "bad(\"empty match\")"
    case Con{heads, cases}:
      "((x)=>{" ++ emit_cases(cases, ns, tailpos) ++ "return bad(\"non-exhaustive match\");})([" ++ join(emit_args(nk(heads), ns), ",") ++ "])"

@unsafe
def emit_cases(xs, ns, tailpos):
  match xs:
    case Nil{}:
      ""
    case Con{+h, t}:
      "{const w=scope(v);if(matchpats(w,[" ++ join(patterns(nk(nth(nk(h), 0))), ",") ++ "],x))return ((v)=>" ++ emit(nth(nk(h), 1), ns, tailpos) ++ ")(w);}" ++ emit_cases(t, ns, tailpos)

@unsafe
def param_bind(xs, i):
  match xs:
    case Nil{}:
      ""
    case Con{h, t}:
      local(nt(h)) ++ "=a[" ++ U32.show(i) ++ "];" ++ param_bind(t, U32.add(i, 1))

@unsafe
def count(xs):
  match xs:
    case Nil{}:
      0
    case Con{h, t}:
      U32.add(1, count(t))

@unsafe
def emit_top(xs):
  match xs:
    case Nil{}:
      ""
    case Con{Node{+tag, +name, +kids}, t}:
      choose(String, eq(tag, "def"),
        u => "G[" ++ jsq(name) ++ "]=fn(" ++ U32.show(count(nk(nth(kids, 0)))) ++ ",function(a){const v=scope(G);" ++ param_bind(nk(nth(kids, 0)), 0) ++ "return " ++ emit(nth(kids, 1), "Nat", True{}) ++ ";});\n",
        u => choose(String, eq(tag, "type"), u => "G[" ++ jsq(name) ++ "]=null;\n",
          u => choose(String, eq(tag, "constructor"),
            u => "constructors[" ++ jsq(name) ++ "]=[" ++ join(param_names(kids), ",") ++ "];\n", u => ""))) ++ emit_top(t)

@unsafe
def param_names(xs):
  match xs:
    case Nil{}:
      Nil{}
    case Con{h, t}:
      Con{jsq(nt(h)), param_names(t)}

# File I/O stays in Bend's ordinary IO API.
@unsafe
def read_file(path):
  do IO<String>:
    f : File <- IO.try(File, File.open(path, "r"))
    pair : File & Result<&1, &1, U32 & String, String> <- File.read(f, 16777216)
    read_close(pair)

@unsafe
def read_close(pair):
  (f, result) = pair
  IO.bind(Unit, String, File.close(f), u => IO.pass(String, result))

@unsafe
def compile_result(p, runtime):
  match p:
    case Parsed{+n, ts}:
      choose(IO(Unit), Bool.not(eq(first_error(n), "")),
        u => IO.die(Unit, 1, first_error(n)),
        u => IO.write(runtime ++ "\n" ++ emit_top(nk(n)) ++ "\nexport {G,call,list};\nif (!process.env.BEND_LIBRARY_MODE) await runmain();\n"))

@unsafe
def compile_path(path, runtime_path):
  do IO<Unit>:
    source : String <- read_file(path)
    runtime : String <- read_file(runtime_path)
    compile_result(top(lex(source, 1, 0, 0, Nil{}), Nil{}), runtime)

@unsafe
def cli(args):
  match args:
    case Con{path, Con{runtime, Nil{}}}:
      compile_path(path, runtime)
    case other:
      IO.die(Unit, 2, "usage: compiler INPUT.bend RUNTIME.mjs > OUTPUT.mjs")

@unsafe
def main():
  IO.bind(List<String>, Unit, IO.args(), cli)

@unsafe
def skip_decl(ts):
  choose(List<&2, Token>, eq(tx(ts), "<eof>") || U32.is_eq(col(ts), 0),
    u => ts, u => skip_decl(skip(tl(ts))))

@unsafe
def skip_angles(ts, depth):
  choose(List<&2, Token>, eq(tx(ts), "<eof>"), u => ts,
    u => choose(List<&2, Token>, (eq(tx(ts), ">") && U32.is_eq(depth, 0)) || (eq(tx(ts), ">>") && U32.is_eq(depth, 1)), u => tl(ts),
      u => skip_angles(tl(ts), choose(U32, eq(tx(ts), "<"), u => U32.add(depth, 1),
        u => choose(U32, eq(tx(ts), ">"), u => U32.sub(depth, 1),
          u => choose(U32, eq(tx(ts), ">>"), u => U32.sub(depth, 2), u => depth))))))

@unsafe
def array_start(ts):
  choose(Parsed, eq(tx(ts), "]"), u => Parsed{Node{"list", "", Nil{}}, tl(ts)},
    u => array_after(expr(ts, 0)))

@unsafe
def array_after(p):
  match p:
    case Parsed{+n, +ts}:
      choose(Parsed, eq(tx(ts), ":"),
        u => array_type(n, tl(ts)),
        u => choose(Parsed, eq(tx(ts), ","),
          u => wrap(collect(tl(ts), "]", [n]), "list", ""),
          u => expect(Parsed{Node{"list", "", [n]}, ts}, "]")))

@unsafe
def array_type(n, ts):
  choose(Parsed, eq(tx(ts), "<eof>") || eq(tx(ts), "]"), u => fail(ts, "expected array size * or ^"),
    u => choose(Parsed, eq(tx(ts), "*") || eq(tx(ts), "^"),
      u => array_end(n, tx(ts), expr(tl(ts), 0)),
      u => array_type(n, tl(ts))))

@unsafe
def array_end(n, op, p):
  match p:
    case Parsed{size, ts}:
      expect(Parsed{Node{"array", op, [n, size]}, ts}, "]")

@unsafe
def index_end(n, p, min):
  match p:
    case Parsed{+idx, +ts}:
      choose(Parsed, eq(tx(ts), "<-"),
        u => index_set(n, idx, expr(tl(ts), 0), min),
        u => grow(Parsed{Node{"index", "", [n, idx]}, ts}, min))

@unsafe
def index_set(n, idx, p, min):
  match p:
    case Parsed{v, ts}:
      grow(Parsed{Node{"set", "", [n, idx, v]}, ts}, min)

@unsafe
def parallel_pats(ts, acc):
  choose(Parsed, eq(tx(ts), "="),
    u => parallel_values(tl(ts), List.reverse(&2, Node, acc), count(acc), Nil{}),
    u => parallel_pat(expr(ts, 0), acc))

@unsafe
def parallel_pat(p, acc):
  match p:
    case Parsed{+n, ts}:
      choose(Parsed, eq(ng(n), "error"), u => Parsed{n, ts},
        u => parallel_pats(ts, Con{n, acc}))

@unsafe
def parallel_values(ts, pats, left, acc):
  choose(Parsed, U32.is_eq(left, 0),
    u => parallel_body(pats, List.reverse(&2, Node, acc), body(ts)),
    u => parallel_value(expr(ts, 0), pats, U32.sub(left, 1), acc))

@unsafe
def parallel_value(p, pats, left, acc):
  match p:
    case Parsed{+n, ts}:
      choose(Parsed, eq(ng(n), "error"), u => Parsed{n, ts},
        u => parallel_values(ts, pats, left, Con{n, acc}))

@unsafe
def parallel_body(pats, vals, p):
  match p:
    case Parsed{b, ts}:
      Parsed{Node{"parallel", "", [Node{"pats", "", pats}, Node{"vals", "", vals}, b]}, ts}

@unsafe
def emit_extra(tag, txt, xs, ns, tailpos):
  choose(String, eq(tag, "array"),
    u => "arrayfill(" ++ emit(nth(xs, 0), ns, False{}) ++ "," ++ emit(nth(xs, 1), ns, False{}) ++ "," ++ jsq(txt) ++ ")",
    u => choose(String, eq(tag, "index"),
      u => "arrayget(" ++ emit(nth(xs, 0), ns, False{}) ++ "," ++ emit(nth(xs, 1), "U32", False{}) ++ ")",
      u => choose(String, eq(tag, "set"),
        u => "arrayset(" ++ emit(nth(xs, 0), ns, False{}) ++ "," ++ emit(nth(xs, 1), "U32", False{}) ++ "," ++ emit(nth(xs, 2), ns, False{}) ++ ")",
        u => choose(String, eq(tag, "parallel"),
          u => "((x)=>{const w=scope(v);if(!matchpats(w,[" ++ join(patterns(nk(nth(xs, 0))), ",") ++ "],x))bad(\"parallel binding mismatch\");return ((v)=>" ++ emit(nth(xs, 2), ns, tailpos) ++ ")(w);})([" ++ join(emit_args(nk(nth(xs, 1)), ns), ",") ++ "])",
          u => choose(String, eq(tag, "matcher"),
            u => "matcher(" ++ jsq(txt) ++ ",()=>" ++ emit(nth(xs, 0), ns, False{}) ++ ",()=>" ++ emit(nth(xs, 1), ns, False{}) ++ ")",
            u => choose(String, eq(tag, "absurd"), u => "fn(1,()=>bad(\"empty match\"))",
              u => "bad(" ++ jsq("unsupported AST " ++ tag) ++ ")"))))))

@unsafe
def matcher_start(ts):
  choose(Parsed, eq(tx(ts), "}"), u => Parsed{node("absurd", ""), tl(ts)},
    u => matcher_branch(tx(ts), expr(tl(tl(ts)), 0)))

@unsafe
def matcher_branch(name, p):
  match p:
    case Parsed{+n, +ts}:
      choose(Parsed, eq(tx(ts), ";"),
        u => choose(Parsed, eq(tx(tl(tl(ts))), ":"),
          u => matcher_chain(name, n, matcher_start(tl(ts))),
          u => matcher_tail(name, n, expr(tl(ts), 0))),
        u => expect(Parsed{Node{"matcher", name, [n, node("absurd", "")]}, ts}, "}"))

@unsafe
def matcher_tail(name, n, p):
  match p:
    case Parsed{other, ts}:
      expect(Parsed{Node{"matcher", name, [n, other]}, ts}, "}")

@unsafe
def do_mark(p, name):
  match p:
    case Parsed{n, ts}:
      Parsed{mark_monad(n, name), ts}

@unsafe
def mark_monad(n, name):
  match n:
    case Node{+tag, +txt, xs}:
      Node{tag, choose(String, (eq(tag, "bind") || eq(tag, "pure")) && eq(txt, ""), u => name, u => txt), mark_monads(xs, name)}

@unsafe
def mark_monads(xs, name):
  match xs:
    case Nil{}:
      Nil{}
    case Con{h, t}:
      Con{mark_monad(h, name), mark_monads(t, name)}

@unsafe
def three(s):
  SCon{head(s), SCon{head(tail(s)), SCon{head(tail(tail(s))), ""}}}

@unsafe
def triple_op(s):
  eq(three(s), ".&.") || eq(three(s), ".|.") || eq(three(s), ".^.") || eq(three(s), "<&>")

@unsafe
def symbol_text(s, c, acc):
  choose(String, Char.is_eq(head(s), '+') && Char.is_alpha(head(tail(s))) && Bool.not(String.ends_with(tx(acc), "n") && U32.is_eq(U32.add(col(acc), U32.from_nat(String.length(tx(acc)))), c)),
    u => "+bind", u => SCon{head(s), ""})

@unsafe
def matcher_chain(name, n, p):
  match p:
    case Parsed{other, ts}:
      Parsed{Node{"matcher", name, [n, other]}, ts}

@unsafe
def first_error(n):
  match n:
    case Node{+tag, +txt, kids}:
      choose(String, eq(tag, "error"), u => txt, u => first_errors(kids))

@unsafe
def first_errors(ns):
  match ns:
    case Nil{}:
      ""
    case Con{h, t}:
      error_rest(first_error(h), t)

@unsafe
def error_rest(err, ns):
  choose(String, eq(err, ""), u => first_errors(ns), u => err)

@unsafe
def skip_annotation(ts, d):
  choose(List<&2, Token>, eq(tx(ts), "<eof>"), u => ts,
    u => choose(List<&2, Token>, U32.is_eq(d, 0) && (eq(tx(ts), ")") || eq(tx(ts), "}") || eq(tx(ts), ",")), u => ts,
      u => skip_annotation(tl(ts), choose(U32, eq(tx(ts), "(") || eq(tx(ts), "{") || eq(tx(ts), "[") || eq(tx(ts), "<") || eq(tx(ts), "<-"), u => U32.add(d, 1),
        u => choose(U32, eq(tx(ts), ")") || eq(tx(ts), "}") || eq(tx(ts), "]") || eq(tx(ts), ">"), u => U32.sub(d, 1),
          u => choose(U32, eq(tx(ts), ">>"), u => U32.sub(d, 2), u => d))))))
