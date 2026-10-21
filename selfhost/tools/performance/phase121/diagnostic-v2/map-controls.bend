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

def bench(+size: U32, +seed: U32) -> U32:
  m = p37.map.fill(U32.to_nat(size), 0, seed, Map.new(&2, U32))
  m = p37.map.update(U32.to_nat(U32.div(U32.add(size, 2), 3)), 0, seed, m)
  m = p37.map.remove(U32.to_nat(U32.div(U32.add(size, 3), 4)), 0, m)
  p37.map.digest(Map.to_list(&2, U32, m), 2166136261)


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

def p121.treefold_bench(+size: U32, +seed: U32) -> U32:
  m = p37.map.fill(U32.to_nat(size), 0, seed, Map.new(&2, U32))
  m = p37.map.update(U32.to_nat(U32.div(U32.add(size, 2), 3)), 0, seed, m)
  m = p37.map.remove(U32.to_nat(U32.div(U32.add(size, 3), 4)), 0, m)
  p121.map_digest(m, 2166136261)


def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(U32.show(0))
    Unit <- IO.print(U32.show(0))
    Unit <- IO.print(U32.show(bench(0, 0)))
    Unit <- IO.print(U32.show(p121.treefold_bench(0, 0)))
    Unit <- IO.print(U32.show(0))
    Unit <- IO.print(U32.show(1))
    Unit <- IO.print(U32.show(bench(0, 1)))
    Unit <- IO.print(U32.show(p121.treefold_bench(0, 1)))
    Unit <- IO.print(U32.show(0))
    Unit <- IO.print(U32.show(4294967295))
    Unit <- IO.print(U32.show(bench(0, 4294967295)))
    Unit <- IO.print(U32.show(p121.treefold_bench(0, 4294967295)))
    Unit <- IO.print(U32.show(1))
    Unit <- IO.print(U32.show(0))
    Unit <- IO.print(U32.show(bench(1, 0)))
    Unit <- IO.print(U32.show(p121.treefold_bench(1, 0)))
    Unit <- IO.print(U32.show(1))
    Unit <- IO.print(U32.show(1))
    Unit <- IO.print(U32.show(bench(1, 1)))
    Unit <- IO.print(U32.show(p121.treefold_bench(1, 1)))
    Unit <- IO.print(U32.show(1))
    Unit <- IO.print(U32.show(4294967295))
    Unit <- IO.print(U32.show(bench(1, 4294967295)))
    Unit <- IO.print(U32.show(p121.treefold_bench(1, 4294967295)))
    Unit <- IO.print(U32.show(2))
    Unit <- IO.print(U32.show(0))
    Unit <- IO.print(U32.show(bench(2, 0)))
    Unit <- IO.print(U32.show(p121.treefold_bench(2, 0)))
    Unit <- IO.print(U32.show(2))
    Unit <- IO.print(U32.show(1))
    Unit <- IO.print(U32.show(bench(2, 1)))
    Unit <- IO.print(U32.show(p121.treefold_bench(2, 1)))
    Unit <- IO.print(U32.show(2))
    Unit <- IO.print(U32.show(4294967295))
    Unit <- IO.print(U32.show(bench(2, 4294967295)))
    Unit <- IO.print(U32.show(p121.treefold_bench(2, 4294967295)))
    Unit <- IO.print(U32.show(17))
    Unit <- IO.print(U32.show(0))
    Unit <- IO.print(U32.show(bench(17, 0)))
    Unit <- IO.print(U32.show(p121.treefold_bench(17, 0)))
    Unit <- IO.print(U32.show(17))
    Unit <- IO.print(U32.show(1))
    Unit <- IO.print(U32.show(bench(17, 1)))
    Unit <- IO.print(U32.show(p121.treefold_bench(17, 1)))
    Unit <- IO.print(U32.show(17))
    Unit <- IO.print(U32.show(4294967295))
    Unit <- IO.print(U32.show(bench(17, 4294967295)))
    Unit <- IO.print(U32.show(p121.treefold_bench(17, 4294967295)))
    Unit <- IO.print(U32.show(129))
    Unit <- IO.print(U32.show(0))
    Unit <- IO.print(U32.show(bench(129, 0)))
    Unit <- IO.print(U32.show(p121.treefold_bench(129, 0)))
    Unit <- IO.print(U32.show(129))
    Unit <- IO.print(U32.show(1))
    Unit <- IO.print(U32.show(bench(129, 1)))
    Unit <- IO.print(U32.show(p121.treefold_bench(129, 1)))
    Unit <- IO.print(U32.show(129))
    Unit <- IO.print(U32.show(4294967295))
    Unit <- IO.print(U32.show(bench(129, 4294967295)))
    IO.print(U32.show(p121.treefold_bench(129, 4294967295)))
