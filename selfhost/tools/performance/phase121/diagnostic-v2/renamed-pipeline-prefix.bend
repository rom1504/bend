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
