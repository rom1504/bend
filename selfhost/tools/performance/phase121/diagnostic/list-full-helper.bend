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
