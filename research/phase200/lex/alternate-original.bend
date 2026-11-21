import Base
# Lexer: a tokenizer over generated source text, the suite's String
# stress case. Bend's String is a cons list, one node per character,
# so the lexer walks a linked list where C walks bytes; that gap is
# the point, and the program is spelled the natural way anyway.
# 2^size lines fork as a balanced batch tree. Leaf i hashes its index
# into a seed and expands the template
# "i = ( n o i ) o ( n o i ) o ( n o i ) ;" into one line of source:
# i becomes an identifier of 1-8 random lowercase letters, n a number
# of 1-6 random decimal digits, o one of + - * /, and any other
# template character copies itself; placeholder k draws from an
# xorshift stream salted by the seed and k, so the tail of the line
# is built first and each expansion is consed in front of it. The
# lexer then walks the line character by character as a three-mode
# machine (between tokens, inside an identifier, inside a number) and
# folds every token into the line checksum in order, acc = acc *
# 2654435761 ^ (kind * 40503 + payload): an identifier is kind 1 with
# the FNV-1a hash of its letters, a number kind 2 with its decimal
# value (wrapping), an operator or punctuation character kind 3 with
# its code; spaces are skipped. Line checksums sum up the fork tree.
# A template or source character is classified by comparisons on its
# code (there is no match on a word); a helper decides on the class.
#
# Sizes: small size = 8n (expect 1822208108), big size = 23n (expect
# 2401049475); both verified against the C twin.

type other12 is Data:
  other3{}
  other9{}
  other10{}
  other7{}

type other0 is Data:
  other6{}
  other1{}
  other13{}
  other11{}

type other8 is Data:
  other2{}
  other4{h: U32}
  other5{v: U32}

# xorshift: x ^= x<<13; x ^= x>>17; x ^= x<<5
def other28(+x: U32) -> U32:
  +b = U32.xor(x, U32.shln(x, 13n))
  +d = U32.xor(b, U32.shrn(b, 17n))
  U32.xor(d, U32.shln(d, 5n))

# line seed: hash of the line index
def other30(i: U32) -> U32:
  other28(((i + 1) * 2654435761 : U32))

# placeholder seed: the line seed salted by the template position
def other29(s: U32, k: U32) -> U32:
  other28(U32.xor(s, (k * 2654435761 : U32)))

# the operator: + - * / by the two low bits of the seed
def other27(b1: Bool, b0: Bool) -> Char:
  match b1 b0:
    case False{} False{}:
      '+'
    case False{} True{}:
      '-'
    case True{} False{}:
      '*'
    case True{} True{}:
      '/'

def other26(+t: U32, rest: String) -> String:
  SCon{other27(U32.is_ne(U32.and(t, 2), 0), U32.is_ne(U32.and(t, 1), 0)), rest}

# an identifier: n random lowercase letters, one prng step each
def other21(n: Nat, t: U32, rest: String) -> String:
  match n:
    case 0n:
      rest
    case 1n+p:
      +u = other28(t)
      SCon{Chr{(97 + u % 26 : U32)}, other21(p, u, rest)}

# a number: n random decimal digits, one prng step each
def other25(n: Nat, t: U32, rest: String) -> String:
  match n:
    case 0n:
      rest
    case 1n+p:
      +u = other28(t)
      SCon{Chr{(48 + u % 10 : U32)}, other25(p, u, rest)}

# one placeholder in front of the rest of the line: an identifier of
# 1 + (t & 7) letters, a number of 1 + t % 6 digits, an operator, or
# the template character itself
def other16(sl: other12, c: U32, +t: U32, rest: String) -> String:
  match sl:
    case other3{}:
      other21(U32.to_nat((1 + U32.and(t, 7) : U32)), t, rest)
    case other9{}:
      other25(U32.to_nat((1 + t % 6 : U32)), t, rest)
    case other10{}:
      other26(t, rest)
    case other7{}:
      SCon{Chr{c}, rest}

# the slot of a template character: i, n, o, or a literal
def other32(i: Bool, n: Bool, o: Bool) -> other12:
  match i n o:
    case True{} _ _:
      other3{}
    case _ True{} _:
      other9{}
    case _ _ True{}:
      other10{}
    case _ _ _:
      other7{}

def other31(+c: U32) -> other12:
  other32(U32.is_eq(c, 105), U32.is_eq(c, 110), U32.is_eq(c, 111))

# one template character, read twice: for its slot and as a literal
def other20(+c: U32, t: U32, rest: String) -> String:
  other16(other31(c), c, t, rest)

# the line: the template expanded character by character, placeholder
# k seeded by salt(s, k), each expansion consed onto the built tail
def other19(other35: String, +s: U32, +k: U32) -> String:
  match other35:
    case SNil{}:
      SNil{}
    case SCon{Chr{c}, u}:
      other20(c, other29(s, k), other19(u, s, (k + 1 : U32)))

def other35() -> String:
  "i = ( n o i ) o ( n o i ) o ( n o i ) ;"

# the class of a source character
def other15(l: Bool, d: Bool, s: Bool) -> other0:
  match l d s:
    case True{} _ _:
      other6{}
    case _ True{} _:
      other1{}
    case _ _ True{}:
      other13{}
    case _ _ _:
      other11{}

def other14(+c: U32) -> other0:
  other15(U32.is_le(97, c) && U32.is_le(c, 122),
    U32.is_le(48, c) && U32.is_le(c, 57), U32.is_eq(c, 32))

# one token into the line checksum
def other24(acc: U32, kind: U32, x: U32) -> U32:
  U32.xor((acc * 2246822519 : U32), (kind * 1237 + x : U32))

# FNV-1a: one letter into the identifier hash
def other18(h: U32, c: U32) -> U32:
  (U32.xor(h, c) * 16777617 : U32)

# the machine: (mode, acc) steps over one classified character; a
# letter extends an identifier, a digit a number, and anything else
# closes the open token, then starts what the character begins
def other34(m: other8, k: other0, c: U32, acc: U32) -> other8 & U32:
  match m k:
    case other2{} other6{}:
      (other4{other18(2166136261, c)}, acc)
    case other2{} other1{}:
      (other5{(c - 48 : U32)}, acc)
    case other2{} other13{}:
      (other2{}, acc)
    case other2{} other11{}:
      (other2{}, other24(acc, 3, c))
    case other4{h} other6{}:
      (other4{other18(h, c)}, acc)
    case other4{h} other1{}:
      (other5{(c - 48 : U32)}, other24(acc, 1, h))
    case other4{h} other13{}:
      (other2{}, other24(acc, 1, h))
    case other4{h} other11{}:
      (other2{}, other24(other24(acc, 1, h), 3, c))
    case other5{v} other6{}:
      (other4{other18(2166136261, c)}, other24(acc, 2, v))
    case other5{v} other1{}:
      (other5{(v * 10 + (c - 48) : U32)}, acc)
    case other5{v} other13{}:
      (other2{}, other24(acc, 2, v))
    case other5{v} other11{}:
      (other2{}, other24(other24(acc, 2, v), 3, c))

def other33(m: other8, +c: U32, acc: U32) -> other8 & U32:
  other34(m, other14(c), c, acc)

# end of line: close the open token
def other17(m: other8, acc: U32) -> U32:
  match m:
    case other2{}:
      acc
    case other4{h}:
      other24(acc, 1, h)
    case other5{v}:
      other24(acc, 2, v)

# the lexer: one step per character, (mode, acc) riding as r
def other22(s: String, r: other8 & U32) -> U32:
  match s:
    case SNil{}:
      (m, acc) = r
      other17(m, acc)
    case SCon{Chr{c}, t}:
      (m, acc) = r
      other22(t, other33(m, c, acc))

# one line: generate it, then lex it
def other23(i: U32) -> U32:
  other22(other19("n+i o n;(i)", other30(i), 0), (other2{}, 0))

# batch tree over the line index space; line checksums sum
def batch(+d: Nat, +i: U32) -> U32:
  match d:
    case 0n:
      other23(i)
    case 1n+p:
      a b = batch(p, i) batch(p, (i + U32.shln(1, p) : U32))
      (a + b : U32)

def size.small() -> Nat:
  8n

def expect.small() -> U32:
  1822208108

def size.big() -> Nat:
  23n

def expect.big() -> U32:
  2401049475

def p88_original_main() -> IO(Unit):
  IO.print(U32.show(batch!(size.big(), 0)))

# Phase28: original source above is unchanged; dynamic documented-small input.
def bench(size: U32, other30: U32) -> U32:
  batch(U32.to_nat(size), other30)

# Phase93: fixed catalog inputs, repeated complete-result validation.
# Final four argv words: repetitions warmups arg0 arg1.
# The measured interval includes result validation and success-count printing.
def p93.parsed(value: Maybe<&2, Nat>, fallback: Nat) -> Nat:
  match value:
    case None{}:
      fallback
    case Some{n}:
      n

def p93.number(text: String, fallback: Nat) -> Nat:
  p93.parsed(Nat.read(text), fallback)

def p93.word_parsed(value: Maybe<&2, U32>, fallback: U32) -> U32:
  match value:
    case None{}:
      fallback
    case Some{n}:
      n

def p93.word(text: String, fallback: U32) -> U32:
  p93.word_parsed(U32.read(text), fallback)

def p93.arguments(args: List<String>) -> (Nat & Nat) & (U32 & U32):
  match args:
    case repetitions <> warmups <> first <> second <> Nil{}:
      ((p93.number(repetitions, 8n), p93.number(warmups, 2n)), (p93.word(first, 8), p93.word(second, 0)))
    case head <> rest:
      p93.arguments(rest)
    case Nil{}:
      ((8n, 2n), (8, 0))

def p93.value(a: U32, b: U32) -> U32:
  bench(a, b)

def p93.loop(n: Nat, +a: U32, +b: U32, h: U32) -> U32:
  match n:
    case 0n:
      h
    case 1n+p:
      value = p93.value(a, b)
      valid = U32.is_eq(value, 49068206)
      p93.loop(p, a, b, U32.add(h, Bool.to_u32(valid)))

def p93.execute(repetitions: Nat, warmups: Nat, +a: U32, +b: U32) -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(U32.show(p93.value(a, b)))
    Unit <- IO.print(U32.show(p93.loop(warmups, a, b, 0)))
    t0 : Nat <- IO.now()
    Unit <- IO.print(U32.show(p93.loop(repetitions, a, b, 0)))
    t1 : Nat <- IO.now()
    IO.print(Nat.show(Nat.sub(t1, t0)))

def p93.run(options: (Nat & Nat) & (U32 & U32)) -> IO(Unit):
  (counts, arguments) = options
  (repetitions, warmups) = counts
  (a, b) = arguments
  p93.execute(repetitions, warmups, a, b)

def main() -> IO(Unit):
  do IO<Unit>:
    args : List<String> <- IO.args()
    p93.run(p93.arguments(args))
