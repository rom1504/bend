import Base
# Diagnostic only; outside native45.
# Same twelve multiply/add terms and XOR reduction order; calculate-and-reduce versus all terms live before reduction. Final machine schedules may converge.

def p194.step(+x: U32, i: U32) -> U32:
  v1 = U32.mul(U32.add(x, 1), 3)
  v2 = U32.mul(U32.add(x, 2), 5)
  v3 = U32.mul(U32.add(x, 3), 7)
  v4 = U32.mul(U32.add(x, 4), 9)
  v5 = U32.mul(U32.add(x, 5), 11)
  v6 = U32.mul(U32.add(x, 6), 13)
  v7 = U32.mul(U32.add(x, 7), 15)
  v8 = U32.mul(U32.add(x, 8), 17)
  v9 = U32.mul(U32.add(x, 9), 19)
  v10 = U32.mul(U32.add(x, 10), 21)
  v11 = U32.mul(U32.add(x, 11), 23)
  v12 = U32.mul(U32.add(x, 12), 25)
  U32.xor(U32.xor(U32.xor(U32.xor(U32.xor(U32.xor(U32.xor(U32.xor(U32.xor(U32.xor(U32.xor(v1, v2), v3), v4), v5), v6), v7), v8), v9), v10), v11), v12)

def p194.kernel(n: Nat, +i: U32, x: U32) -> U32:
  match n:
    case 0n: x
    case 1n+p: p194.kernel(p, U32.inc(i), p194.step(x, i))

def bench(size: U32, seed: U32) -> U32:
  p194.kernel(U32.to_nat(size), 0, seed)

# Phase194: native45 four-argv/four-line timing protocol.
# Only (size,seed)=(32,17) and (1024,17) are declared oracle points.

# Final four argv words: repetitions warmups arg0 arg1.
# The measured interval includes result validation and success-count printing.
def p194.parsed(value: Maybe<&2, Nat>, fallback: Nat) -> Nat:
  match value:
    case None{}:
      fallback
    case Some{n}:
      n

def p194.number(text: String, fallback: Nat) -> Nat:
  p194.parsed(Nat.read(text), fallback)

def p194.word_parsed(value: Maybe<&2, U32>, fallback: U32) -> U32:
  match value:
    case None{}:
      fallback
    case Some{n}:
      n

def p194.word(text: String, fallback: U32) -> U32:
  p194.word_parsed(U32.read(text), fallback)

def p194.arguments(args: List<String>) -> (Nat & Nat) & (U32 & U32):
  match args:
    case repetitions <> warmups <> first <> second <> Nil{}:
      ((p194.number(repetitions, 1n), p194.number(warmups, 0n)), (p194.word(first, 32), p194.word(second, 17)))
    case head <> rest:
      p194.arguments(rest)
    case Nil{}:
      ((1n, 0n), (32, 17))

def p194.value(a: U32, b: U32) -> U32:
  bench(a, b)

def p194.loop(n: Nat, +a: U32, +b: U32, h: U32) -> U32:
  match n:
    case 0n:
      h
    case 1n+p:
      +value = p194.value(a, b)
      valid = U32.is_eq(b, 17) &&
        ((U32.is_eq(a, 32) && U32.is_eq(value, 343597400)) ||
         (U32.is_eq(a, 1024) && U32.is_eq(value, 343597400)))
      p194.loop(p, a, b, U32.add(h, Bool.to_u32(valid)))

def p194.execute(repetitions: Nat, warmups: Nat, +a: U32, +b: U32) -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(U32.show(p194.value(a, b)))
    Unit <- IO.print(U32.show(p194.loop(warmups, a, b, 0)))
    t0 : Nat <- IO.now()
    Unit <- IO.print(U32.show(p194.loop(repetitions, a, b, 0)))
    t1 : Nat <- IO.now()
    IO.print(Nat.show(Nat.sub(t1, t0)))

def p194.run(options: (Nat & Nat) & (U32 & U32)) -> IO(Unit):
  (counts, arguments) = options
  (repetitions, warmups) = counts
  (a, b) = arguments
  p194.execute(repetitions, warmups, a, b)

def main() -> IO(Unit):
  do IO<Unit>:
    args : List<String> <- IO.args()
    p194.run(p194.arguments(args))
