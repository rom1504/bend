# string algorithms: replace the FIRST occurrence via find/take/drop,
# replace-all-chars via split/join, count occurrences by walking finds
# ported from bend3: bend-base's String helpers are inlined (find as
# Maybe<&2, U32>, split by char code); occurrence fuel becomes Nat; strict
# -- the continuation defs folded into their callers' case trees, and
# shared strings ride + binders (String is Data)
import Base

law bu:
  for b: Bool
  U32

def bu(b):
  match b:
    case False{}:
      0
    case True{}:
      1

law seq_:
  for a: String
  for b: String
  Bool

def seq_(a, b):
  match a b:
    case SNil{} SNil{}:
      True{}
    case SNil{} SCon{h, t}:
      False{}
    case SCon{h, t} SNil{}:
      False{}
    case SCon{Chr{x}, t1} SCon{Chr{y}, t2}:
      Bool.and(U32.is_eq(x, y), seq_(t1, t2))

law starts:
  for p: String
  for s: String
  Bool

def starts(p, s):
  match p s:
    case SNil{} _:
      True{}
    case SCon{h, t} SNil{}:
      False{}
    case SCon{Chr{x}, t1} SCon{Chr{y}, t2}:
      Bool.and(U32.is_eq(x, y), starts(t1, t2))

law sfind:
  for +p: String
  for  s: String
  Maybe<&2, U32>

law sfind.nil:
  for z: Bool
  Maybe<&2, U32>

def sfind.nil(z):
  match z:
    case True{}:
      Some{0}
    case False{}:
      None{}

law sfind.bump:
  for o: Maybe<&2, U32>
  Maybe<&2, U32>

def sfind.bump(o):
  match o:
    case None{}:
      None{}
    case Some{i}:
      Some{U32.add(i, 1)}

law sfind.pick:
  for rec : Maybe<&2, U32>
  for z   : Bool
  Maybe<&2, U32>

def sfind.pick(rec, z):
  match z:
    case True{}:
      Some{0}
    case False{}:
      sfind.bump(rec)

def sfind(p, s):
  match s:
    case SNil{}:
      sfind.nil(starts(p, SNil{}))
    case SCon{h, t0}:
      +t = {t0 : String}
      sfind.pick(sfind(p, t), starts(p, SCon{h, t}))

law stake:
  for n: Nat
  for s: String
  String

def stake(n, s):
  match n s:
    case 0n _:
      SNil{}
    case 1n+p SNil{}:
      SNil{}
    case 1n+p SCon{h, t}:
      SCon{h, stake(p, t)}

law sdrop:
  for n: Nat
  for s: String
  String

def sdrop(n, s):
  match n s:
    case 0n s2:
      s2
    case 1n+p SNil{}:
      SNil{}
    case 1n+p SCon{h, t}:
      sdrop(p, t)

law ssplit.push:
  for c  : Char
  for ps : List<&2, String>
  List<&2, String>

def ssplit.push(c, ps):
  match ps:
    case Nil{}:
      [SCon{c, SNil{}}]
    case h <> t:
      SCon{c, h} <> t

law ssplit:
  for +sep : U32
  for s    : String
  List<&2, String>

law ssplit.pick:
  for +x  : U32
  for rec : List<&2, String>
  for z   : Bool
  List<&2, String>

def ssplit.pick(x, rec, z):
  match z:
    case True{}:
      SNil{} <> rec
    case False{}:
      ssplit.push(Chr{x}, rec)

def ssplit(sep, s):
  match s:
    case SNil{}:
      [SNil{}]
    case SCon{Chr{x0}, t}:
      +x = {x0 : U32}
      ssplit.pick(x, ssplit(sep, t), U32.is_eq(x, sep))

law sjoin.go:
  for +sep : String
  for t    : List<&2, String>
  for h    : String
  String

def sjoin.go(sep, t, h):
  match t:
    case Nil{}:
      h
    case h2 <> t2:
      String.append(h, String.append(sep, sjoin.go(sep, t2, h2)))

law sjoin:
  for +sep : String
  for xs   : List<&2, String>
  String

def sjoin(sep, xs):
  match xs:
    case Nil{}:
      SNil{}
    case h <> t:
      sjoin.go(sep, t, h)

law replace1:
  for +s  : String
  for +at : U32
  for n   : U32
  for w   : String
  String

def replace1(s, at, n, w):
  String.append(stake(U32.to_nat(at), s), String.append(w, sdrop(U32.to_nat(U32.add(at, n)), s)))

law occurs:
  for fuel : Nat
  for +p   : String
  for +s   : String
  U32

law occurs.step:
  for +s  : String
  for acc : U32
  for o   : Maybe<&2, U32>
  U32 & String & Bool

def occurs.step(s, acc, o):
  match o:
    case Some{i}:
      (U32.add(acc, 1), sdrop(U32.to_nat(U32.add(i, 1)), s), True{})
    case None{}:
      (acc, s, False{})

law occurs.go:
  for fuel : Nat
  for +p   : String
  for st   : U32 & String & Bool
  U32 & String & Bool

def occurs.go(fuel, p, st):
  match fuel:
    case 0n:
      st
    case 1n+f:
      match st:
        case (acc, s0, True{}):
          +s = {s0 : String}
          occurs.go(f, p, occurs.step(s, acc, sfind(p, s)))
        case (acc, s0, False{}):
          occurs.go(f, p, (acc, s0, False{}))

law occurs.fin:
  for st: U32 & String & Bool
  U32

def occurs.fin(st):
  match st:
    case (acc, s, True{}):
      99
    case (acc, s, False{}):
      acc

def occurs(fuel, p, s):
  occurs.fin(occurs.go(fuel, p, (0, s, True{})))

law main.out:
  U32

def main.out():
  b0 = bu(seq_(replace1("banana", Maybe.default(&2, U32, sfind("an", "banana"), 99), 2, "X"), "bXana"))
  b1 = bu(seq_(sjoin("-", ssplit(44, "a,b,c")), "a-b-c"))
  b2 = bu(U32.is_eq(occurs(5n, "an", "banana"), 2))
  b3 = bu(U32.is_eq(occurs(5n, "zz", "banana"), 0))
  U32.add(U32.add(U32.add(b0, b1), b2), b3)

law p88_original_main:
  IO(Unit)

def p88_original_main():
  IO.print(U32.show(main.out()))

#|4

# Phase37 wrapper: upstream body above is unchanged.
def p37.text.repeat(n: Nat, +block: String) -> String:
  match n:
    case 0n:
      SNil{}
    case 1n+p:
      String.append(block, p37.text.repeat(p, block))

def bench(size: U32, seed: U32) -> String:
  text = p37.text.repeat(U32.to_nat(size), String.append("α,β,🍎,中,", String.append(U32.show(seed), ",")))
  sjoin("|", ssplit(44, text))

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
      ((p93.number(repetitions, 8n), p93.number(warmups, 2n)), (p93.word(first, 64), p93.word(second, 123)))
    case head <> rest:
      p93.arguments(rest)
    case Nil{}:
      ((8n, 2n), (64, 123))

def p93.value(a: U32, b: U32) -> String:
  bench(a, b)

def p93.loop(n: Nat, +a: U32, +b: U32, h: U32) -> U32:
  match n:
    case 0n:
      h
    case 1n+p:
      value = p93.value(a, b)
      valid = String.eq(value, "α|β|🍎|中|123|α|β|🍎|中|123|α|β|🍎|中|123|α|β|🍎|中|123|α|β|🍎|中|123|α|β|🍎|中|123|α|β|🍎|中|123|α|β|🍎|中|123|α|β|🍎|中|123|α|β|🍎|中|123|α|β|🍎|中|123|α|β|🍎|中|123|α|β|🍎|中|123|α|β|🍎|中|123|α|β|🍎|中|123|α|β|🍎|中|123|α|β|🍎|中|123|α|β|🍎|中|123|α|β|🍎|中|123|α|β|🍎|中|123|α|β|🍎|中|123|α|β|🍎|中|123|α|β|🍎|中|123|α|β|🍎|中|123|α|β|🍎|中|123|α|β|🍎|中|123|α|β|🍎|中|123|α|β|🍎|中|123|α|β|🍎|中|123|α|β|🍎|中|123|α|β|🍎|中|123|α|β|🍎|中|123|α|β|🍎|中|123|α|β|🍎|中|123|α|β|🍎|中|123|α|β|🍎|中|123|α|β|🍎|中|123|α|β|🍎|中|123|α|β|🍎|中|123|α|β|🍎|中|123|α|β|🍎|中|123|α|β|🍎|中|123|α|β|🍎|中|123|α|β|🍎|中|123|α|β|🍎|中|123|α|β|🍎|中|123|α|β|🍎|中|123|α|β|🍎|中|123|α|β|🍎|中|123|α|β|🍎|中|123|α|β|🍎|中|123|α|β|🍎|中|123|α|β|🍎|中|123|α|β|🍎|中|123|α|β|🍎|中|123|α|β|🍎|中|123|α|β|🍎|中|123|α|β|🍎|中|123|α|β|🍎|中|123|α|β|🍎|中|123|α|β|🍎|中|123|α|β|🍎|中|123|α|β|🍎|中|123|α|β|🍎|中|123|")
      p93.loop(p, a, b, U32.add(h, Bool.to_u32(valid)))

def p93.execute(repetitions: Nat, warmups: Nat, +a: U32, +b: U32) -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(p93.value(a, b))
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
