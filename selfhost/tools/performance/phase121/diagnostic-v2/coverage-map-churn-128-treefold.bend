# Phase37 authored collection workload; uses the pinned Base Map implementation.
# Build many keys, replace every third value, remove every fourth key, then
# observe the entire ordered key/value content through a wrapping digest.
import Base

def p37.map.key(i: U32) -> String:
  String.append("key", U32.show(i))

def p37.map.fill(n: Nat, +i: U32, +seed: U32, m: Map<&2, U32>) -> Map<&2, U32>:
  match n:
    case 0n:
      m
    case 1n+p:
      p37.map.fill(p, U32.add(i, 1), seed,
        Map.set(&2, U32, m, p37.map.key(i), U32.add(seed, U32.mul(i, 17))))

def p37.map.update(n: Nat, +i: U32, +seed: U32, m: Map<&2, U32>) -> Map<&2, U32>:
  match n:
    case 0n:
      m
    case 1n+p:
      p37.map.update(p, U32.add(i, 3), seed,
        Map.set(&2, U32, m, p37.map.key(i), U32.xor(seed, U32.mul(i, 31))))

def p37.map.remove(n: Nat, +i: U32, m: Map<&2, U32>) -> Map<&2, U32>:
  match n:
    case 0n:
      m
    case 1n+p:
      p37.map.remove(p, U32.add(i, 4), Map.del(&2, U32, m, p37.map.key(i)))

def p37.map.string(s: String, acc: U32) -> U32:
  match s:
    case SNil{}:
      acc
    case SCon{Chr{x}, t}:
      p37.map.string(t, U32.add(U32.mul(acc, 31), x))

def p37.map.digest(xs: List<&2, Sigma<&2, &2, String, _ => U32>>, acc: U32) -> U32:
  match xs:
    case Nil{}:
      acc
    case (k, v) <> t:
      p37.map.digest(t, U32.xor(U32.mul(p37.map.string(k, acc), 16777619), v))

# Diagnostic ceiling only: consume Map directly in Map.to_list order.
# The noncommutative string/value digest remains lo-before-hi; keys are consumed once.
def p121.map_digest(m: Map<&2, U32>, acc: U32) -> U32:
  match m:
    case MTip{}:
      acc
    case MLeaf{k, v}:
      U32.xor(U32.mul(p37.map.string(k, acc), 16777619), v)
    case MNode{pos, lo, hi}:
      p121.map_digest(hi, p121.map_digest(lo, acc))

def bench(+size: U32, +seed: U32) -> U32:
  m = p37.map.fill(U32.to_nat(size), 0, seed, Map.new(&2, U32))
  m = p37.map.update(U32.to_nat(U32.div(U32.add(size, 2), 3)), 0, seed, m)
  m = p37.map.remove(U32.to_nat(U32.div(U32.add(size, 3), 4)), 0, m)
  p121.map_digest(m, 2166136261)

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
      ((p93.number(repetitions, 8n), p93.number(warmups, 2n)), (p93.word(first, 128), p93.word(second, 123)))
    case head <> rest:
      p93.arguments(rest)
    case Nil{}:
      ((8n, 2n), (128, 123))

def p93.value(a: U32, b: U32) -> U32:
  bench(a, b)

def p93.loop(n: Nat, +a: U32, +b: U32, h: U32) -> U32:
  match n:
    case 0n:
      h
    case 1n+p:
      value = p93.value(a, b)
      valid = U32.is_eq(value, 3714872484)
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
