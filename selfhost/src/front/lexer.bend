
# Module: src/front/lexer.bend:2
type FToken is Data:
  FToken{+text: String, f_line: U32, f_col: U32, f_kind: U32, begin: U32, end: U32, previousEnd: U32}

# Module: src/front/lexer.bend:5
type FScanned is Data:
  FScanned{+word: String, +rest: String, size: U32}

# Module: src/front/lexer.bend:323
type FParseContext is Data:
  FParseContext{+scope: FParseScope, +env: List<&2,KTerm>, next: U32}

# Module: src/front/lexer.bend:325
type FInput is Data:
  FInput{+tokens: List<&2,FToken>, +context: FParseContext}

# Module: src/front/lexer.bend:8
law f_three:
  for +s: String
  String

# Module: src/front/lexer.bend:12
law f_triple_op:
  for +s: String
  Bool

# Module: src/front/lexer.bend:16
law f_symbol_text:
  for +s: String
  for +c: U32
  for +acc: List<&2, FToken>
  String

# Module: src/front/lexer.bend:22
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
law f_ascii_space:
  for +c: Char
  Bool

# Module: src/front/lexer.bend:39
law f_ascii_ident_code:
  for +code: U32
  Bool

# Module: src/front/lexer.bend:43
law f_ascii_space_code:
  for +code: U32
  Bool

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
  p88_string_eq(a, b)

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
def f_raw_skip(
  +ts: List<&2, FToken>,
) -> List<&2, FToken>:
  f_choose(List<&2, FToken>, Bool.or(f_eq(f_raw_tx(ts), "\n"), f_eq(f_raw_tx(ts), ";")),
    u => f_raw_skip(f_raw_tl(ts)), u => ts)

# Module: src/front/lexer.bend:125
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
def f_ident(
  +c: Char,
) -> Bool:
  f_ascii_ident_code(Char.to_u32(c))

# Module: src/front/lexer.bend:151
@unsafe
def f_scan_word(
  +s: String,
  +acc: String,
  +n: U32,
) -> FScanned:
  f_choose(FScanned, f_choose(Bool, f_ident(f_head(s)), u => True{}, u => (f_ascii_char_eq(f_head(s), '+') || f_ascii_char_eq(f_head(s), '-')) && (f_ascii_char_eq(f_head(acc), 'e') || f_ascii_char_eq(f_head(acc), 'E')) && f_ascii_digit(f_head(f_tail(s)))),
    u => f_scan_word(f_tail(s), SCon{f_head(s), acc}, U32.add(n, 1)),
    u => FScanned{String.reverse(acc), s, n})

# Module: src/front/lexer.bend:161
@unsafe
def f_scan_quote(
  +s: String,
  +quote: Char,
  +acc: String,
  +n: U32,
) -> FScanned:
  f_choose(FScanned, String.is_empty(s),
    u => FScanned{"", "", 0},
    u => f_choose(FScanned, f_ascii_char_eq(f_head(s), quote),
      u => FScanned{String.reverse(SCon{quote, acc}), f_tail(s), U32.add(n, 1)},
      u => f_choose(FScanned, f_ascii_char_eq(f_head(s), '\\'),
        u => f_scan_quote(f_tail(f_tail(s)), quote, SCon{f_head(f_tail(s)), SCon{'\\', acc}}, U32.add(n, 2)),
        u => f_scan_quote(f_tail(s), quote, SCon{f_head(s), acc}, U32.add(n, 1)))))

# Module: src/front/lexer.bend:176
@unsafe
def f_two(
  +s: String,
) -> String:
  SCon{f_head(s), SCon{f_head(f_tail(s)), ""}}

# Module: src/front/lexer.bend:182
@unsafe
def f_pair_op(
  +s: String,
) -> Bool:
  f_eq(s, "->") || f_eq(s, "=>") || f_eq(s, "<-") || f_eq(s, "++") || f_eq(s, "<>") || f_eq(s, "==") || f_eq(s, "!=") || f_eq(s, "<=") || f_eq(s, ">=") || f_eq(s, "&&") || f_eq(s, "||") || f_eq(s, "<<") || f_eq(s, ">>")

# Zero disables cursor metadata and preserves the legacy token list.

# Module: src/front/lexer.bend:189
@unsafe
def f_cursor_add(+offset: U32, +size: U32) -> U32:
  f_choose(U32, U32.is_eq(offset, 0), u => 0, u => U32.add(offset, size))

# Module: src/front/lexer.bend:193
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

# Module: src/front/lexer.bend:211
@unsafe
def f_lex_scanned(
  +sc: FScanned, +l: U32, +c: U32, +d: U32, +k: U32,
  +acc: List<&2,FToken>, +offset: U32, +previous: U32,
) -> List<&2,FToken>:
  match sc:
    case FScanned{word, rest, size}:
      +end = f_cursor_add(offset, f_choose(U32, U32.is_eq(offset, 0), u => 0, u => f_choose(U32, U32.is_eq(k, 1), u => size, u => dg_width(word))))
      f_choose(List<&2,FToken>, U32.is_eq(size, 0),
        u => List.reverse(&2, FToken, Con{FToken{"unterminated string", l, c, 3, offset, offset, previous}, acc}),
        u => f_choose(List<&2,FToken>, U32.is_eq(k, 2),
          u => f_lex_quote_end(word, rest, l, c, d, Con{FToken{word, l, c, k, offset, end, previous}, acc}, end),
          u => f_lex_cursor(rest, l, U32.add(c, size), d, Con{FToken{word, l, c, k, offset, end, previous}, acc}, end, end)))

# Preserve legacy physical columns while indexed cursors count UTF16 units.

# Module: src/front/lexer.bend:226
@unsafe
def f_lex_quote_end(
  +word: String, +rest: String, +line: U32, +column: U32, +depth: U32,
  +tokens: List<&2,FToken>, +end: U32,
) -> List<&2,FToken>:
  match word:
    case SNil{}: f_lex_cursor(rest, line, column, depth, tokens, end, end)
    case SCon{head, tail}: f_choose(List<&2,FToken>, Char.is_eq(head, '\n'), u => f_lex_quote_end(tail, rest, U32.add(line, 1), 0, depth, tokens, end), u => f_lex_quote_end(tail, rest, line, U32.add(column, 1), depth, tokens, end))

# Module: src/front/lexer.bend:235
@unsafe
def f_lex_symbol(
  +s: String, +l: U32, +c: U32, +d: U32,
  +acc: List<&2,FToken>, +offset: U32, +previous: U32,
) -> List<&2,FToken>:
  f_choose(List<&2,FToken>, f_pair_op(f_two(s)) && Bool.not(f_eq(f_two(s), "++") && String.ends_with(f_raw_tx(acc), "n") && U32.is_eq(c, U32.add(f_raw_col(acc), U32.from_nat(String.length(f_raw_tx(acc)))))),
    u => f_lex_cursor(f_tail(f_tail(s)), l, U32.add(c, 2), d, Con{FToken{f_choose(String, f_eq(f_two(s), ">>") && U32.is_gt(c, U32.add(f_raw_col(acc), U32.from_nat(String.length(f_raw_tx(acc))))), u => ">>op", u => f_two(s)), l, c, 0, offset, f_cursor_add(offset, 2), previous}, acc}, f_cursor_add(offset, 2), f_cursor_add(offset, 2)),
    u => f_lex_cursor(f_tail(s), l, U32.add(c, 1),
      f_choose(U32, f_ascii_char_eq(f_head(s), '(') || f_ascii_char_eq(f_head(s), '[') || f_ascii_char_eq(f_head(s), '{'),
        u => U32.add(d, 1),
        u => f_choose(U32, f_ascii_char_eq(f_head(s), ')') || f_ascii_char_eq(f_head(s), ']') || f_ascii_char_eq(f_head(s), '}'), u => U32.sub(d, 1), u => d)),
      Con{FToken{f_symbol_text(s, c, acc), l, c, 0, offset, f_cursor_add(offset, dg_units(f_head(s))), previous}, acc}, f_cursor_add(offset, dg_units(f_head(s))), f_cursor_add(offset, dg_units(f_head(s)))))

# Module: src/front/lexer.bend:248
@unsafe
def f_lex_comment(+s: String, +l: U32, +c: U32, +d: U32, +acc: List<&2,FToken>, +offset: U32, +previous: U32) -> List<&2,FToken>:
  f_choose(List<&2,FToken>, String.is_empty(s) || f_ascii_char_eq(f_head(s), '\n'),
    u => f_lex_cursor(s, l, c, d, acc, offset, previous),
    u => f_lex_comment(f_tail(s), l, c, d, acc, f_cursor_add(offset, dg_units(f_head(s))), previous))

# Module: src/front/lexer.bend:254
@unsafe
def f_lex_cursor(+s: String, +l: U32, +c: U32, +d: U32, +acc: List<&2,FToken>, +offset: U32, +previous: U32) -> List<&2,FToken>:
  f_choose(List<&2,FToken>, String.is_empty(s),
    u => List.reverse(&2, FToken, f_choose(List<&2,FToken>, U32.is_eq(offset, 0), u => acc, u => Con{FToken{"<eof>", 0, 0, 0, offset, offset, previous}, acc})),
    u => f_choose(List<&2,FToken>, f_ascii_char_eq(f_head(s), '\n'),
      u => f_lex_cursor(f_tail(s), U32.add(l, 1), 0, d, f_choose(List<&2,FToken>, U32.is_eq(d, 0), u => Con{FToken{"\n", l, c, 0, offset, f_cursor_add(offset, 1), previous}, acc}, u => acc), f_cursor_add(offset, 1), previous),
      u => f_choose(List<&2,FToken>, f_ascii_space(f_head(s)),
        u => f_lex_cursor(f_tail(s), l, U32.add(c, 1), d, acc, f_cursor_add(offset, dg_units(f_head(s))), previous),
        u => f_choose(List<&2,FToken>, f_ascii_char_eq(f_head(s), '#'),
          u => f_lex_comment(s, l, c, d, acc, offset, previous),
          u => f_choose(List<&2,FToken>, f_ascii_char_eq(f_head(s), '"') || f_ascii_char_eq(f_head(s), '\''),
            u => f_lex_scanned(f_scan_quote(f_tail(s), f_head(s), SCon{f_head(s), ""}, 1), l, c, d, 2, acc, offset, previous),
            u => f_choose(List<&2,FToken>, f_ident(f_head(s)) && Bool.not(f_ascii_char_eq(f_head(s), '.')),
              u => f_lex_scanned(f_scan_word(s, "", 0), l, c, d, 1, acc, offset, previous),
              u => f_choose(List<&2,FToken>, f_triple_op(s),
                u => f_lex_cursor(f_tail(f_tail(f_tail(s))), l, U32.add(c, 3), d, Con{FToken{f_three(s), l, c, 0, offset, f_cursor_add(offset, 3), previous}, acc}, f_cursor_add(offset, 3), f_cursor_add(offset, 3)),
                u => f_choose(List<&2,FToken>, f_ident(f_head(s)),
                  u => f_lex_scanned(f_scan_word(s, "", 0), l, c, d, 1, acc, offset, previous),
                  u => f_lex_symbol(s, l, c, d, acc, offset, previous)))))))))

# Module: src/front/lexer.bend:274
@unsafe
def f_three(s):
  SCon{f_head(s), SCon{f_head(f_tail(s)), SCon{f_head(f_tail(f_tail(s))), ""}}}

# Module: src/front/lexer.bend:278
@unsafe
def f_triple_op(s):
  f_eq(f_three(s), ".&.") || f_eq(f_three(s), ".|.") || f_eq(f_three(s), ".^.") || f_eq(f_three(s), "<&>")

# Module: src/front/lexer.bend:282
@unsafe
def f_symbol_text(s, c, acc):
  f_choose(String, f_ascii_char_eq(f_head(s), '+') && f_ascii_alpha(f_head(f_tail(s))) && Bool.not(String.ends_with(f_raw_tx(acc), "n") && U32.is_eq(U32.add(f_raw_col(acc), U32.from_nat(String.length(f_raw_tx(acc)))), c)),
    u => "+bind", u => f_choose(String, f_ascii_char_eq(f_head(s), '>') && U32.is_gt(c, U32.add(f_raw_col(acc), U32.from_nat(String.length(f_raw_tx(acc))))), u => ">op", u => SCon{f_head(s), ""}))


# Compiler-local ASCII classification. Unsigned subtraction tests a bounded
# ASCII range; setting bit 5 folds uppercase ASCII into lowercase. Other Unicode
# codepoints cannot enter either ASCII range, including isolated surrogates.
# Base Char workers and exported runtime primitive semantics remain unchanged.

# Module: src/front/lexer.bend:292
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
def f_ascii_space(c):
  f_ascii_space_code(Char.to_u32(c))

# Module: src/front/lexer.bend:308
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
def f_raw_space(
  +ts: List<&2,FToken>,
) -> List<&2,FToken>:
  f_choose(List<&2,FToken>, f_eq(f_raw_tx(ts), "\n"), u => f_raw_space(f_raw_tl(ts)), u => ts)

# Stage18 representation ablation: the shared context is inert.

# Module: src/front/lexer.bend:329
@unsafe
def f_input(+tokens: List<&2,FToken>) -> FInput:
  FInput{tokens, FParseContext{f_parse_scope_empty(), Nil{}, 0}}

# Module: src/front/lexer.bend:333
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
def f_tx(+input: FInput) -> String:
  match input:
    case FInput{tokens, context}: f_raw_tx(tokens)

# Module: src/front/lexer.bend:348
@unsafe
def f_line(+input: FInput) -> U32:
  match input:
    case FInput{tokens, context}: f_raw_line(tokens)

# Module: src/front/lexer.bend:353
@unsafe
def f_col(+input: FInput) -> U32:
  match input:
    case FInput{tokens, context}: f_raw_col(tokens)

# Module: src/front/lexer.bend:358
@unsafe
def f_kind(+input: FInput) -> U32:
  match input:
    case FInput{tokens, context}: f_raw_kind(tokens)

# Module: src/front/lexer.bend:363
@unsafe
def f_begin(+input: FInput) -> U32:
  match input:
    case FInput{tokens, context}: f_raw_begin(tokens)

# Module: src/front/lexer.bend:368
@unsafe
def f_end(+input: FInput) -> U32:
  match input:
    case FInput{tokens, context}: f_raw_end(tokens)

# Module: src/front/lexer.bend:373
@unsafe
def f_previous_end(+input: FInput) -> U32:
  match input:
    case FInput{tokens, context}: f_raw_previous_end(tokens)

# Module: src/front/lexer.bend:378
@unsafe
def f_tl(+input: FInput) -> FInput:
  match input:
    case FInput{tokens, context}:
      match tokens:
        case Nil{}: input
        case Con{token, rest}: FInput{rest, context}

# Module: src/front/lexer.bend:386
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
