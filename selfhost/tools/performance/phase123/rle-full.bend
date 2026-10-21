# run-length encoding: list -> (count, value) pairs -> expanded back;
# the round trip is the pin
# ported from bend3: bend-base's List helpers are inlined over bend's
# List (Nil/Con); strict -- the run and expand helpers folded into
# their callers' case trees, the shared code list a + binder over a
# List<&2, ..> of reusable pairs
import Base

law P2:
  Data

def P2(): Sigma<&2, &2, U32, _ => U32>

law bu:
  for b: Bool
  U32

def bu(b):
  match b:
    case False{}:
      0
    case True{}:
      1

law lconcat:
  for xs: List<&2, U32>
  for ys: List<&2, U32>
  List<&2, U32>

def lconcat(xs, ys):
  match xs:
    case Nil{}:
      ys
    case h <> t:
      h <> lconcat(t, ys)

law lrepeat:
  for  n: Nat
  for +v: U32
  List<&2, U32>

def lrepeat(n, v):
  match n:
    case 0n:
      Nil{}
    case 1n+p:
      v <> lrepeat(p, v)

law lrevp.go:
  for xs  : List<&2, P2()>
  for acc : List<&2, P2()>
  List<&2, P2()>

def lrevp.go(xs, acc):
  match xs:
    case Nil{}:
      acc
    case h <> t:
      lrevp.go(t, h <> acc)

law lrevp:
  for xs: List<&2, P2()>
  List<&2, P2()>

def lrevp(xs):
  lrevp.go(xs, Nil{})

law llenp:
  for xs: List<&2, P2()>
  U32

def llenp(xs):
  match xs:
    case Nil{}:
      0
    case h <> t:
      U32.add(1, llenp(t))

law rle.step:
  for +cur : U32
  for +h   : U32
  for n    : U32
  for acc  : List<&2, P2()>
  for e    : Bool
  U32 & U32 & List<&2, P2()>

def rle.step(cur, h, n, acc, e):
  match e:
    case False{}:
      (h, 1, (n, cur) <> acc)
    case True{}:
      (cur, U32.add(n, 1), acc)

# Diagnostic: all three state fields cross the loop edge as arguments.
law p123.runs.full:
  for xs: List<&2, U32>
  for +cur: U32
  for n: U32
  for acc: List<&2, P2()>
  List<&2, P2()>

def p123.runs.full(xs, cur, n, acc):
  match xs:
    case Nil{}:
      lrevp((n, cur) <> acc)
    case h0 <> t:
      +h = {h0 : U32}
      match U32.is_eq(h, cur):
        case False{}:
          p123.runs.full(t, h, 1, (n, cur) <> acc)
        case True{}:
          p123.runs.full(t, cur, U32.add(n, 1), acc)

law rle:
  for xs: List<&2, U32>
  for st: U32 & U32 & List<&2, P2()>
  List<&2, P2()>

def rle(xs, st):
  (cur, n, acc) = st
  p123.runs.full(xs, cur, n, acc)

law expand:
  for ps: List<&2, P2()>
  List<&2, U32>

def expand(ps):
  match ps:
    case Nil{}:
      Nil{}
    case (n, v) <> t:
      lconcat(lrepeat(U32.to_nat(n), v), expand(t))

law digest.go:
  for xs  : List<&2, U32>
  for acc : U32
  U32

def digest.go(xs, acc):
  match xs:
    case Nil{}:
      acc
    case h <> t:
      digest.go(t, U32.add(U32.mul(acc, 10), h))

law digest:
  for xs: List<&2, U32>
  U32

def digest(xs):
  digest.go(xs, 0)

law go:
  for xs: List<&2, U32>
  U32

def go(xs):
  match xs:
    case h <> t:
      +code = {rle(t, (h, 1, Nil{})) : List<&2, P2()>}
      U32.add(U32.mul(bu(U32.is_eq(llenp(code), 3)), 10), bu(U32.is_eq(digest(expand(code)), 777299)))
    case Nil{}:
      0

law main.out:
  U32

def main.out():
  go([7, 7, 7, 2, 9, 9])

law p88_original_main:
  IO(Unit)

def p88_original_main():
  IO.print(U32.show(main.out()))

#|11

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
      ((p93.number(repetitions, 8n), p93.number(warmups, 2n)), (p93.word(first, 0), p93.word(second, 0)))
    case head <> rest:
      p93.arguments(rest)
    case Nil{}:
      ((8n, 2n), (0, 0))

def p93.value(a: U32, b: U32) -> U32:
  main.out()

def p93.loop(n: Nat, +a: U32, +b: U32, h: U32) -> U32:
  match n:
    case 0n:
      h
    case 1n+p:
      value = p93.value(a, b)
      valid = U32.is_eq(value, 11)
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
