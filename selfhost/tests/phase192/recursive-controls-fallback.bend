import Base

# An indirect call is an H refusal boundary unless ordinary lowering has
# independently specialized it. The diagnostic must distinguish these cases.
def recur.fallback(n: Nat, +f: U32 -> U32, +seed: U32) -> U32:
  match n:
    case 0n: f(seed)
    case 1n+p:
      U32.add(recur.fallback(p, f, U32.add(seed, 1)), f(seed))

def recur.fallback.outside(n: Nat, f: U32 -> U32, seed: U32) -> U32:
  U32.xor(recur.fallback(n, f, seed), 1431655765)

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(U32.show(recur.fallback.outside(0n, x => U32.xor(x, 85), 9)))
    Unit <- IO.print(U32.show(recur.fallback.outside(7n, x => U32.xor(x, 85), 9)))
    IO.print(U32.show(recur.fallback.outside(31n, x => U32.mul(x, 19), 4294967281)))
#| 1431655689
#| 1431656337
#| 1431655525
