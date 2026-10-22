import Base

def routing.code(slot: Nat) -> U32:
  match slot:
    case 0n: 2654435769
    case 1n: 7
    case 2n: 4294967295
    case 3n: 123456789
    case 4n: 0
    case 5n: 2147483648
    case 6n: 65537
    case 7n: 97
    case 8n: 2882400001
    case 9n: 4093
    case 10n: 271828183
    case 11n: 314159265
    case 12n+rest: 42

def routing.weight(slot: Nat) -> F32:
  match slot:
    case 0n: 0.0
    case 1n: 0.5
    case 2n: 1.0
    case 3n: F32.sub(0.0, 1.0)
    case 4n: 1.5
    case 5n: 2.0
    case 6n: 3.0
    case 7n+rest: 4.0

def routing.fold(left: Nat, +state: U32, +salt: U32, hash: U32) -> U32:
  match left:
    case 0n: hash
    case 1n+rest:
      +slot = U32.to_nat(U32.and(state, 15))
      code = routing.code(slot)
      weight = F32.bits(routing.weight(slot))
      value = U32.add(U32.add(code, weight), salt)
      next = U32.xor(U32.mul(hash, 65599), value)
      routing.fold(rest, U32.add(U32.mul(state, 1664525), 1013904223), salt, next)

def routing.value(seed: U32, +salt: U32) -> U32:
  routing.fold(1024n, seed, salt, U32.xor(2166136261, salt))

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
      ((p93.number(repetitions, 8n), p93.number(warmups, 2n)), (p93.word(first, 17), p93.word(second, 99)))
    case head <> rest:
      p93.arguments(rest)
    case Nil{}:
      ((8n, 2n), (17, 99))

def p93.value(a: U32, b: U32) -> U32:
  routing.value(a,b)

def p93.loop(n: Nat, +a: U32, +b: U32, h: U32) -> U32:
  match n:
    case 0n:
      h
    case 1n+p:
      value = p93.value(a, b)
      valid = U32.is_eq(value, 1964461478)
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
