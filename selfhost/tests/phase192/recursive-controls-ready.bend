import Base

# A separate tail-recursive scalar worker is a ready-call candidate. Its
# return must resume the region's saved continuation rather than its caller.
def recur.ready.helper(n: Nat, value: U32) -> U32:
  match n:
    case 0n: value
    case 1n+p:
      recur.ready.helper(p, U32.xor(U32.mul(value, 33), 2654435769))

def recur.ready.owner(n: Nat, +seed: U32) -> U32:
  match n:
    case 0n: recur.ready.helper(19n, seed)
    case 1n+p:
      U32.xor(recur.ready.owner(p, U32.add(seed, 7)), U32.add(seed, 101))

def recur.ready.outside(n: Nat, seed: U32) -> U32:
  U32.add(recur.ready.owner(n, seed), 1234567)

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(U32.show(recur.ready.outside(0n, 23)))
    Unit <- IO.print(U32.show(recur.ready.outside(1n, 23)))
    IO.print(U32.show(recur.ready.outside(67n, 4294967287)))
#| 2784056245
#| 3208607490
#| 2048823751
