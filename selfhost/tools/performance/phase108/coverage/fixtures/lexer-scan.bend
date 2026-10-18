# Exact lexer declarations; source and declaration hashes are in manifest.json.
import Base

type FScanned is Data:
  FScanned{+word: String, +rest: String, size: U32}

law f_ascii_char_eq:
  for +a: Char
  for +b: Char
  Bool

law f_ascii_digit:
  for +c: Char
  Bool

law f_ascii_ident_code:
  for +code: U32
  Bool

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

@unsafe
def f_head(
  +s: String,
) -> Char:
  match s:
    case SNil{}:
      '\0'
    case SCon{h, t}:
      h

@unsafe
def f_tail(
  +s: String,
) -> String:
  match s:
    case SNil{}:
      ""
    case SCon{h, t}:
      t

@unsafe
def f_ident(
  +c: Char,
) -> Bool:
  f_ascii_ident_code(Char.to_u32(c))

@unsafe
def f_scan_word(
  +s: String,
  +acc: String,
  +n: U32,
) -> FScanned:
  f_choose(FScanned, f_choose(Bool, f_ident(f_head(s)), u => True{}, u => (f_ascii_char_eq(f_head(s), '+') || f_ascii_char_eq(f_head(s), '-')) && (f_ascii_char_eq(f_head(acc), 'e') || f_ascii_char_eq(f_head(acc), 'E')) && f_ascii_digit(f_head(f_tail(s)))),
    u => f_scan_word(f_tail(s), SCon{f_head(s), acc}, U32.add(n, 1)),
    u => FScanned{String.reverse(acc), s, n})

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

@unsafe
def f_ascii_char_eq(a, b):
  U32.is_eq(Char.to_u32(a), Char.to_u32(b))

@unsafe
def f_ascii_digit(c):
  U32.is_le(U32.sub(Char.to_u32(c), 48), 9)

@unsafe
def f_ascii_ident_code(code):
  U32.is_le(U32.sub(U32.or(code, 32), 97), 25) || U32.is_le(U32.sub(code, 48), 9) || U32.is_eq(code, 95) || U32.is_eq(code, 46)

@unsafe
def p108_scanned(sc: FScanned) -> String:
  match sc:
    case FScanned{word, rest, size}: word ++ "/" ++ rest ++ "/" ++ U32.show(size)

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(p108_scanned(f_scan_word("abc_9.rest+", "", 0)))
    Unit <- IO.print(p108_scanned(f_scan_word("1e-3+", "", 0)))
    Unit <- IO.print(p108_scanned(f_scan_word("1e+x", "", 0)))
    Unit <- IO.print(p108_scanned(f_scan_word("x-y", "", 0)))
    Unit <- IO.print(p108_scanned(f_scan_word("λa", "", 0)))
    Unit <- IO.print(p108_scanned(f_scan_word("c!", "ba", 2)))
    IO.print(p108_scanned(f_scan_quote("abc", '"', "", 0)))

#|abc_9.rest/+/10
#|1e-3/+/4
#|1e/+x/2
#|x/-y/1
#|/λa/0
#|abc/!/3
#|//0
