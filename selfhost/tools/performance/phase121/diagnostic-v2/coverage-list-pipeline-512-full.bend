# bend3's list_map_fold_ops intent -- map/filter/fold/any/all over a
# list and map/fold over a Map -- in bend's dialect. bend3 rode base
# comp (~) templates; those are ruled out whole here, and generic
# List.map is not affine-checkable, so each template call becomes a
# local first-order recursion at U32 (the walk bend3's splice would
# have minted). The seven checks and their sum are the original's.
import Base

law b2u:
  for b: Bool
  U32

def b2u(b):
  match b:
    case False{}:
      0
    case True{}:
      1

law dbl:
  for xs: List<&2, U32>
  List<&2, U32>

def dbl(xs):
  match xs:
    case Nil{}:
      Nil{}
    case h <> t:
      U32.mul(h, 2) <> dbl(t)

law keep_gt1:
  for xs: List<&2, U32>
  List<&2, U32>

law keep_gt1.at:
  for h: U32
  for r: List<&2, U32>
  for z: Bool
  List<&2, U32>

def keep_gt1.at(h, r, z):
  match z:
    case True{}:
      h <> r
    case False{}:
      r

def keep_gt1(xs):
  match xs:
    case Nil{}:
      Nil{}
    case h0 <> t:
      +h = {h0 : U32}
      keep_gt1.at(h, keep_gt1(t), U32.is_gt(h, 1))

law suma:
  for xs  : List<&2, U32>
  for acc : U32
  U32

def suma(xs, acc):
  match xs:
    case Nil{}:
      acc
    case h <> t:
      suma(t, U32.add(acc, h))

law anyeq2:
  for xs: List<&2, U32>
  Bool

law anyeq2.at:
  for r: Bool
  for z: Bool
  Bool

def anyeq2.at(r, z):
  match z:
    case True{}:
      True{}
    case False{}:
      r

def anyeq2(xs):
  match xs:
    case Nil{}:
      False{}
    case h <> t:
      anyeq2.at(anyeq2(t), U32.is_eq(h, 2))

law allpos:
  for xs: List<&2, U32>
  Bool

law allpos.at:
  for r: Bool
  for z: Bool
  Bool

def allpos.at(r, z):
  match z:
    case True{}:
      r
    case False{}:
      False{}

def allpos(xs):
  match xs:
    case Nil{}:
      True{}
    case h <> t:
      allpos.at(allpos(t), U32.is_gt(h, 0))

law mmul10:
  for m: Map<&2, U32>
  Map<&2, U32>

def mmul10(m):
  match m:
    case MTip{}:
      MTip{}
    case MLeaf{k, v}:
      MLeaf{k, U32.mul(v, 10)}
    case MNode{pos, lo, hi}:
      MNode{pos, mmul10(lo), mmul10(hi)}

law mfold:
  for m   : Map<&2, U32>
  for acc : U32
  U32

def mfold(m, acc):
  match m:
    case MTip{}:
      acc
    case MLeaf{k, v}:
      U32.add(acc, U32.add(v, U32.from_nat(String.length(k))))
    case MNode{pos, lo, hi}:
      mfold(hi, mfold(lo, acc))

law main.out:
  U32

def main.out():
  a = b2u(U32.is_eq(suma(dbl([1, 2, 3]), 0), 12))
  b = b2u(U32.is_eq(suma(keep_gt1([1, 2, 3]), 0), 5))
  c = b2u(U32.is_eq(suma([1, 2, 3], 100), 106))
  d = b2u(anyeq2([1, 2, 3]))
  e = b2u(allpos([1, 2, 3]))
  g = b2u(U32.is_eq(mfold(mmul10(Map.from_list(&2, U32, [("a", 1), ("b", 2)])), 0), 32))
  U32.add(U32.add(U32.add(U32.mul(a, 1000000), U32.mul(b, 100000)), U32.add(U32.mul(c, 10000), U32.mul(d, 1000))), U32.add(U32.add(U32.mul(e, 100), U32.mul(g, 10)), 1))

law p88_original_main:
  IO(Unit)

def p88_original_main():
  IO.print(U32.show(main.out()))

#|1111111

# Phase37 wrapper: upstream body above is unchanged.
def p37.list(n: Nat, +seed: U32) -> List<&2, U32>:
  match n:
    case 0n:
      Nil{}
    case 1n+p:
      U32.mod(seed, 16) <> p37.list(p, U32.add(U32.mul(seed, 1664525), 1013904223))

# Diagnostic ceiling only: erase the generator/filter/map intermediate lists.
# Total U32 primitives retain each wrapping point; fold order remains left to right.
def p121.accumulate(h: U32, acc: U32, keep: Bool) -> U32:
  match keep:
    case False{}:
      acc
    case True{}:
      U32.add(acc, U32.mul(h, 2))

def p121.pipeline(n: Nat, +seed: U32, acc: U32) -> U32:
  match n:
    case 0n:
      acc
    case 1n+p:
      +h = {U32.mod(seed, 16) : U32}
      next = U32.add(U32.mul(seed, 1664525), 1013904223)
      p121.pipeline(p, next, p121.accumulate(h, acc, U32.is_gt(h, 1)))

def bench(size: U32, seed: U32) -> U32:
  p121.pipeline(U32.to_nat(size), seed, 0)

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
      ((p93.number(repetitions, 8n), p93.number(warmups, 2n)), (p93.word(first, 512), p93.word(second, 123)))
    case head <> rest:
      p93.arguments(rest)
    case Nil{}:
      ((8n, 2n), (512, 123))

def p93.value(a: U32, b: U32) -> U32:
  bench(a, b)

def p93.loop(n: Nat, +a: U32, +b: U32, h: U32) -> U32:
  match n:
    case 0n:
      h
    case 1n+p:
      value = p93.value(a, b)
      valid = U32.is_eq(value, 7616)
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
