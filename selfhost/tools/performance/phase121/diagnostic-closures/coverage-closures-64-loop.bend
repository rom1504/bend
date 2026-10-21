# closure/HOF pipelines: compose chains (every closure consumed exactly
# once), a recursively BUILT closure chain, and a closure stored in and
# extracted from a constructor field
# ported from bend3: generics become erased Type params, the chain
# counter becomes Nat with its U32 image rebuilt via U32.from_nat
import Base

law compose:
  for -A: Type
  for -B: Type
  for -C: Type
  for  f: A -> B
  for  g: B -> C
  A -> C

def compose(A, B, C, f, g):
  x => g(f(x))

type FBox is Type:
  MkF{f: U32 -> U32}

law chain:
  for +n: Nat
  U32 -> U32

def chain(n):
  match n:
    case 0n:
      x => x
    case 1n+p:
      k = U32.add(1, U32.from_nat(p))
      compose(U32, U32, U32, x => U32.add(x, k), chain(p))

law unbox:
  for b: FBox
  U32

def unbox(b):
  match b:
    case MkF{f}:
      f(4)

law sqr:
  for x: U32
  U32

def sqr(x):
  +y = x
  U32.mul(y, y)

law main.out:
  U32

def main.out():
  a = (compose(U32, U32, U32, compose(U32, U32, U32, x => U32.add(x, 1), x => U32.mul(x, 2)), sqr))(3)
  b = (chain(3n))(10)
  c = unbox(MkF{y => U32.mul(y, 5)})
  U32.add(U32.add(U32.mul(a, 1000), U32.mul(b, 10)), c)

law p88_original_main:
  IO(Unit)

def p88_original_main():
  IO.print(U32.show(main.out()))

#|64180

# Phase37 wrapper: upstream body above is unchanged.
# Build and execute a dynamically sized captured closure chain.
# Diagnostic-only closure construction/application fusion. Preserve descending
# application order and each original U32 operation, including from_nat.
def p121.closure_loop(+n: Nat, value: U32) -> U32:
  match n:
    case 0n:
      value
    case 1n+p:
      p121.closure_loop(p, U32.add(value, U32.add(1, U32.from_nat(p))))

def bench(size: U32, seed: U32) -> U32:
  p121.closure_loop(U32.to_nat(size), seed)

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
      ((p93.number(repetitions, 8n), p93.number(warmups, 2n)), (p93.word(first, 64), p93.word(second, 17)))
    case head <> rest:
      p93.arguments(rest)
    case Nil{}:
      ((8n, 2n), (64, 17))

def p93.value(a: U32, b: U32) -> U32:
  bench(a, b)

def p93.loop(n: Nat, +a: U32, +b: U32, h: U32) -> U32:
  match n:
    case 0n:
      h
    case 1n+p:
      value = p93.value(a, b)
      valid = U32.is_eq(value, 2097)
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
