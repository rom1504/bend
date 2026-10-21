# Ordinary source control: renamed helpers, overflow-heavy mapping and a
# noncommutative left fold. No compiler-private names or benchmark recognition.
import Base

def scatter(n: Nat, +seed: U32) -> List<&2, U32>:
  match n:
    case 0n:
      Nil{}
    case 1n+p:
      seed <> scatter(p, U32.add(U32.mul(seed, 1664525), 1013904223))

def selected(head: U32, rest: List<&2, U32>, keep: Bool) -> List<&2, U32>:
  match keep:
    case True{}:
      head <> rest
    case False{}:
      rest

def accepted(xs: List<&2, U32>) -> List<&2, U32>:
  match xs:
    case Nil{}:
      Nil{}
    case h0 <> t:
      +h = {h0 : U32}
      selected(h, accepted(t), U32.is_gt(U32.mod(h, 5), 1))

def remapped(xs: List<&2, U32>) -> List<&2, U32>:
  match xs:
    case Nil{}:
      Nil{}
    case h <> t:
      U32.add(U32.mul(h, 4294967291), 4294967280) <> remapped(t)

def accumulated(xs: List<&2, U32>, acc: U32) -> U32:
  match xs:
    case Nil{}:
      acc
    case h <> t:
      accumulated(t, U32.add(U32.mul(acc, 33), h))

def renamed(size: U32, seed: U32) -> U32:
  accumulated(remapped(accepted(scatter(U32.to_nat(size), seed))), 4294967295)

# These preserve ordinary supported semantics but must refuse the new nested,
# single-consumer fusion admission. The shared value is consumed by two folds.
def shared(size: U32, seed: U32) -> U32:
  +xs = {remapped(accepted(scatter(U32.to_nat(size), seed))) : List<&2, U32>}
  U32.add(accumulated(xs, 1), accumulated(xs, 2))

def returned(size: U32, seed: U32) -> List<&2, U32>:
  remapped(accepted(scatter(U32.to_nat(size), seed)))

# Native-looking user spelling is deliberately not the builtin U32.add.
# Matching a normalized emitter symbol rather than native identity is wrong.
def u32_add(a: U32, b: U32) -> U32:
  a

def user_mapped(xs: List<&2, U32>) -> List<&2, U32>:
  match xs:
    case Nil{}:
      Nil{}
    case h <> t:
      u32_add(h, 123) <> user_mapped(t)

def user_named(size: U32, seed: U32) -> U32:
  accumulated(user_mapped(accepted(scatter(U32.to_nat(size), seed))), 4294967295)

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(U32.show(0))
    Unit <- IO.print(U32.show(0))
    Unit <- IO.print(U32.show(renamed(0, 0)))
    Unit <- IO.print(U32.show(shared(0, 0)))
    Unit <- IO.print(U32.show(accumulated(returned(0, 0), 27)))
    Unit <- IO.print(U32.show(user_named(0, 0)))
    Unit <- IO.print(U32.show(0))
    Unit <- IO.print(U32.show(1))
    Unit <- IO.print(U32.show(renamed(0, 1)))
    Unit <- IO.print(U32.show(shared(0, 1)))
    Unit <- IO.print(U32.show(accumulated(returned(0, 1), 27)))
    Unit <- IO.print(U32.show(user_named(0, 1)))
    Unit <- IO.print(U32.show(0))
    Unit <- IO.print(U32.show(4294967295))
    Unit <- IO.print(U32.show(renamed(0, 4294967295)))
    Unit <- IO.print(U32.show(shared(0, 4294967295)))
    Unit <- IO.print(U32.show(accumulated(returned(0, 4294967295), 27)))
    Unit <- IO.print(U32.show(user_named(0, 4294967295)))
    Unit <- IO.print(U32.show(1))
    Unit <- IO.print(U32.show(0))
    Unit <- IO.print(U32.show(renamed(1, 0)))
    Unit <- IO.print(U32.show(shared(1, 0)))
    Unit <- IO.print(U32.show(accumulated(returned(1, 0), 27)))
    Unit <- IO.print(U32.show(user_named(1, 0)))
    Unit <- IO.print(U32.show(1))
    Unit <- IO.print(U32.show(1))
    Unit <- IO.print(U32.show(renamed(1, 1)))
    Unit <- IO.print(U32.show(shared(1, 1)))
    Unit <- IO.print(U32.show(accumulated(returned(1, 1), 27)))
    Unit <- IO.print(U32.show(user_named(1, 1)))
    Unit <- IO.print(U32.show(1))
    Unit <- IO.print(U32.show(4294967295))
    Unit <- IO.print(U32.show(renamed(1, 4294967295)))
    Unit <- IO.print(U32.show(shared(1, 4294967295)))
    Unit <- IO.print(U32.show(accumulated(returned(1, 4294967295), 27)))
    Unit <- IO.print(U32.show(user_named(1, 4294967295)))
    Unit <- IO.print(U32.show(2))
    Unit <- IO.print(U32.show(0))
    Unit <- IO.print(U32.show(renamed(2, 0)))
    Unit <- IO.print(U32.show(shared(2, 0)))
    Unit <- IO.print(U32.show(accumulated(returned(2, 0), 27)))
    Unit <- IO.print(U32.show(user_named(2, 0)))
    Unit <- IO.print(U32.show(2))
    Unit <- IO.print(U32.show(1))
    Unit <- IO.print(U32.show(renamed(2, 1)))
    Unit <- IO.print(U32.show(shared(2, 1)))
    Unit <- IO.print(U32.show(accumulated(returned(2, 1), 27)))
    Unit <- IO.print(U32.show(user_named(2, 1)))
    Unit <- IO.print(U32.show(2))
    Unit <- IO.print(U32.show(4294967295))
    Unit <- IO.print(U32.show(renamed(2, 4294967295)))
    Unit <- IO.print(U32.show(shared(2, 4294967295)))
    Unit <- IO.print(U32.show(accumulated(returned(2, 4294967295), 27)))
    Unit <- IO.print(U32.show(user_named(2, 4294967295)))
    Unit <- IO.print(U32.show(17))
    Unit <- IO.print(U32.show(0))
    Unit <- IO.print(U32.show(renamed(17, 0)))
    Unit <- IO.print(U32.show(shared(17, 0)))
    Unit <- IO.print(U32.show(accumulated(returned(17, 0), 27)))
    Unit <- IO.print(U32.show(user_named(17, 0)))
    Unit <- IO.print(U32.show(17))
    Unit <- IO.print(U32.show(1))
    Unit <- IO.print(U32.show(renamed(17, 1)))
    Unit <- IO.print(U32.show(shared(17, 1)))
    Unit <- IO.print(U32.show(accumulated(returned(17, 1), 27)))
    Unit <- IO.print(U32.show(user_named(17, 1)))
    Unit <- IO.print(U32.show(17))
    Unit <- IO.print(U32.show(4294967295))
    Unit <- IO.print(U32.show(renamed(17, 4294967295)))
    Unit <- IO.print(U32.show(shared(17, 4294967295)))
    Unit <- IO.print(U32.show(accumulated(returned(17, 4294967295), 27)))
    Unit <- IO.print(U32.show(user_named(17, 4294967295)))
    Unit <- IO.print(U32.show(257))
    Unit <- IO.print(U32.show(0))
    Unit <- IO.print(U32.show(renamed(257, 0)))
    Unit <- IO.print(U32.show(shared(257, 0)))
    Unit <- IO.print(U32.show(accumulated(returned(257, 0), 27)))
    Unit <- IO.print(U32.show(user_named(257, 0)))
    Unit <- IO.print(U32.show(257))
    Unit <- IO.print(U32.show(1))
    Unit <- IO.print(U32.show(renamed(257, 1)))
    Unit <- IO.print(U32.show(shared(257, 1)))
    Unit <- IO.print(U32.show(accumulated(returned(257, 1), 27)))
    Unit <- IO.print(U32.show(user_named(257, 1)))
    Unit <- IO.print(U32.show(257))
    Unit <- IO.print(U32.show(4294967295))
    Unit <- IO.print(U32.show(renamed(257, 4294967295)))
    Unit <- IO.print(U32.show(shared(257, 4294967295)))
    Unit <- IO.print(U32.show(accumulated(returned(257, 4294967295), 27)))
    IO.print(U32.show(user_named(257, 4294967295)))
