# Tokenization is implemented in Bend, retaining source f_line and column.
type FToken is Data:
  FToken{+text: String, f_line: U32, f_col: U32, f_kind: U32}

type FScanned is Data:
  FScanned{+word: String, +rest: String, size: U32}

law f_choose:
  for -A: Type
  for +b: Bool
  for yes: Unit -> A
  for no: Unit -> A
  A

law f_eq:
  for +a: String
  for +b: String
  Bool

law f_tx:
  for +ts: List<&2, FToken>
  String

law f_tl:
  for +ts: List<&2, FToken>
  List<&2, FToken>

law f_line:
  for +ts: List<&2, FToken>
  U32

law f_col:
  for +ts: List<&2, FToken>
  U32

law f_kind:
  for +ts: List<&2, FToken>
  U32

law f_skip:
  for +ts: List<&2, FToken>
  List<&2, FToken>

law f_head:
  for +s: String
  Char

law f_tail:
  for +s: String
  String

law f_ident:
  for +c: Char
  Bool

law f_scan_word:
  for +s: String
  for +acc: String
  for +n: U32
  FScanned

law f_scan_comment:
  for +s: String
  String

law f_scan_quote:
  for +s: String
  for +quote: Char
  for +acc: String
  for +n: U32
  FScanned

law f_two:
  for +s: String
  String

law f_pair_op:
  for +s: String
  Bool

law f_lex_scanned:
  for +sc: FScanned
  for +l: U32
  for +c: U32
  for +d: U32
  for +k: U32
  for +acc: List<&2, FToken>
  List<&2, FToken>

law f_lex_symbol:
  for +s: String
  for +l: U32
  for +c: U32
  for +d: U32
  for +acc: List<&2, FToken>
  List<&2, FToken>

law f_lex:
  for +s: String
  for +l: U32
  for +c: U32
  for +d: U32
  for +acc: List<&2, FToken>
  List<&2, FToken>

law f_three:
  for +s: String
  String

law f_triple_op:
  for +s: String
  Bool

law f_symbol_text:
  for +s: String
  for +c: U32
  for +acc: List<&2, FToken>
  String

@unsafe
def f_choose(A, b, yes, no):
  match b:
    case True{}:
      yes(Unit{})
    case False{}:
      no(Unit{})

@unsafe
def f_eq(a, b):
  String.eq(a, b)

@unsafe
def f_tx(ts):
  match ts:
    case Nil{}:
      "<eof>"
    case Con{FToken{t, l, c, k}, rest}:
      t

@unsafe
def f_tl(ts):
  match ts:
    case Nil{}:
      Nil{}
    case Con{t, rest}:
      rest

@unsafe
def f_line(ts):
  match ts:
    case Nil{}:
      0
    case Con{FToken{t, l, c, k}, rest}:
      l

@unsafe
def f_col(ts):
  match ts:
    case Nil{}:
      0
    case Con{FToken{t, l, c, k}, rest}:
      c

@unsafe
def f_kind(ts):
  match ts:
    case Nil{}:
      0
    case Con{FToken{t, l, c, k}, rest}:
      k

@unsafe
def f_skip(ts):
  f_choose(List<&2, FToken>, Bool.or(f_eq(f_tx(ts), "\n"), f_eq(f_tx(ts), ";")),
    u => f_skip(f_tl(ts)), u => ts)

@unsafe
def f_head(s):
  match s:
    case SNil{}:
      '\0'
    case SCon{h, t}:
      h

@unsafe
def f_tail(s):
  match s:
    case SNil{}:
      ""
    case SCon{h, t}:
      t

@unsafe
def f_ident(c):
  Char.is_alpha(c) || Char.is_digit(c) || Char.is_eq(c, '_') || Char.is_eq(c, '.')

@unsafe
def f_scan_word(s, acc, n):
  f_choose(FScanned, f_ident(f_head(s)) || ((Char.is_eq(f_head(s), '+') || Char.is_eq(f_head(s), '-')) && (Char.is_eq(f_head(acc), 'e') || Char.is_eq(f_head(acc), 'E')) && Char.is_digit(f_head(f_tail(s)))),
    u => f_scan_word(f_tail(s), SCon{f_head(s), acc}, U32.add(n, 1)),
    u => FScanned{String.reverse(acc), s, n})

@unsafe
def f_scan_comment(s):
  f_choose(String, String.is_empty(s) || Char.is_eq(f_head(s), '\n'),
    u => s, u => f_scan_comment(f_tail(s)))

@unsafe
def f_scan_quote(s, quote, acc, n):
  f_choose(FScanned, String.is_empty(s),
    u => FScanned{"", "", 0},
    u => f_choose(FScanned, Char.is_eq(f_head(s), quote),
      u => FScanned{String.reverse(SCon{quote, acc}), f_tail(s), U32.add(n, 1)},
      u => f_choose(FScanned, Char.is_eq(f_head(s), '\\'),
        u => f_scan_quote(f_tail(f_tail(s)), quote, SCon{f_head(f_tail(s)), SCon{'\\', acc}}, U32.add(n, 2)),
        u => f_scan_quote(f_tail(s), quote, SCon{f_head(s), acc}, U32.add(n, 1)))))

@unsafe
def f_two(s):
  SCon{f_head(s), SCon{f_head(f_tail(s)), ""}}

@unsafe
def f_pair_op(s):
  f_eq(s, "->") || f_eq(s, "=>") || f_eq(s, "<-") || f_eq(s, "++") || f_eq(s, "<>") || f_eq(s, "==") || f_eq(s, "!=") || f_eq(s, "<=") || f_eq(s, ">=") || f_eq(s, "&&") || f_eq(s, "||") || f_eq(s, "<<") || f_eq(s, ">>")

@unsafe
def f_lex_scanned(sc, l, c, d, k, acc):
  match sc:
    case FScanned{word, rest, size}:
      f_choose(List<&2, FToken>, U32.is_eq(size, 0),
        u => List.reverse(&2, FToken, Con{FToken{"unterminated string", l, c, 3}, acc}),
        u => f_lex(rest, l, U32.add(c, size), d, Con{FToken{word, l, c, k}, acc}))

@unsafe
def f_lex_symbol(s, l, c, d, acc):
  f_choose(List<&2, FToken>, f_pair_op(f_two(s)) && Bool.not(f_eq(f_two(s), "++") && String.ends_with(f_tx(acc), "n") && U32.is_eq(c, U32.add(f_col(acc), U32.from_nat(String.length(f_tx(acc)))))),
    u => f_lex(f_tail(f_tail(s)), l, U32.add(c, 2), d, Con{FToken{f_choose(String, f_eq(f_two(s), ">>") && U32.is_gt(c, U32.add(f_col(acc), U32.from_nat(String.length(f_tx(acc))))), u => ">>op", u => f_two(s)), l, c, 0}, acc}),
    u => f_lex(f_tail(s), l, U32.add(c, 1),
      f_choose(U32, Char.is_eq(f_head(s), '(') || Char.is_eq(f_head(s), '[') || Char.is_eq(f_head(s), '{'),
        u => U32.add(d, 1),
        u => f_choose(U32, Char.is_eq(f_head(s), ')') || Char.is_eq(f_head(s), ']') || Char.is_eq(f_head(s), '}'),
          u => U32.sub(d, 1), u => d)),
      Con{FToken{f_symbol_text(s, c, acc), l, c, 0}, acc}))

@unsafe
def f_lex(s, l, c, d, acc):
  f_choose(List<&2, FToken>, String.is_empty(s),
    u => List.reverse(&2, FToken, acc),
    u => f_choose(List<&2, FToken>, Char.is_eq(f_head(s), '\n'),
      u => f_lex(f_tail(s), U32.add(l, 1), 0, d,
        f_choose(List<&2, FToken>, U32.is_eq(d, 0), u => Con{FToken{"\n", l, c, 0}, acc}, u => acc)),
      u => f_choose(List<&2, FToken>, Char.is_space(f_head(s)),
        u => f_lex(f_tail(s), l, U32.add(c, 1), d, acc),
        u => f_choose(List<&2, FToken>, Char.is_eq(f_head(s), '#'),
          u => f_lex(f_scan_comment(s), l, c, d, acc),
          u => f_choose(List<&2, FToken>, Char.is_eq(f_head(s), '"') || Char.is_eq(f_head(s), '\''),
            u => f_lex_scanned(f_scan_quote(f_tail(s), f_head(s), SCon{f_head(s), ""}, 1), l, c, d, 2, acc),
            u => f_choose(List<&2, FToken>, f_triple_op(s),
              u => f_lex(f_tail(f_tail(f_tail(s))), l, U32.add(c, 3), d, Con{FToken{f_three(s), l, c, 0}, acc}),
            u => f_choose(List<&2, FToken>, f_ident(f_head(s)),
              u => f_lex_scanned(f_scan_word(s, "", 0), l, c, d, 1, acc),
              u => f_lex_symbol(s, l, c, d, acc))))))))

@unsafe
def f_three(s):
  SCon{f_head(s), SCon{f_head(f_tail(s)), SCon{f_head(f_tail(f_tail(s))), ""}}}

@unsafe
def f_triple_op(s):
  f_eq(f_three(s), ".&.") || f_eq(f_three(s), ".|.") || f_eq(f_three(s), ".^.") || f_eq(f_three(s), "<&>")

@unsafe
def f_symbol_text(s, c, acc):
  f_choose(String, Char.is_eq(f_head(s), '+') && Char.is_alpha(f_head(f_tail(s))) && Bool.not(String.ends_with(f_tx(acc), "n") && U32.is_eq(U32.add(f_col(acc), U32.from_nat(String.length(f_tx(acc)))), c)),
    u => "+bind", u => f_choose(String, Char.is_eq(f_head(s), '>') && U32.is_gt(c, U32.add(f_col(acc), U32.from_nat(String.length(f_tx(acc))))), u => ">op", u => SCon{f_head(s), ""}))

