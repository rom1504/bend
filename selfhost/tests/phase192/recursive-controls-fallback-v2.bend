import Base

# Closures are affine Type values: pass f exactly once on each recursive path.
# The base still applies an indirect closure under recursive/external frames.
# A Data flag supplies the same scalar contribution at each unwinding level.
def recur.fallback.value(multiply: Bool, seed: U32) -> U32:
  match multiply:
    case False{}: U32.xor(seed, 85)
    case True{}: U32.mul(seed, 19)

def recur.fallback(n: Nat, f: U32 -> U32, +multiply: Bool, +seed: U32) -> U32:
  match n:
    case 0n: f(seed)
    case 1n+p:
      U32.add(recur.fallback(p, f, multiply, U32.add(seed, 1)), recur.fallback.value(multiply, seed))

def recur.fallback.outside(n: Nat, f: U32 -> U32, multiply: Bool, seed: U32) -> U32:
  U32.xor(recur.fallback(n, f, multiply, seed), 1431655765)

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(U32.show(recur.fallback.outside(0n, x => U32.xor(x, 85), False{}, 9)))
    Unit <- IO.print(U32.show(recur.fallback.outside(7n, x => U32.xor(x, 85), False{}, 9)))
    IO.print(U32.show(recur.fallback.outside(31n, x => U32.mul(x, 19), True{}, 4294967281)))
#| 1431655689
#| 1431656337
#| 1431655525
