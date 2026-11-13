import Base

# One captured scalar continuation. The wrapper remains pending even when the
# region starts at depth zero; the deep case must use bounded native stack.
def recur.one(n: Nat, +seed: U32) -> U32:
  match n:
    case 0n: seed
    case 1n+p:
      U32.add(recur.one(p, U32.add(seed, 3)), U32.xor(seed, 17))

def recur.outside(n: Nat, seed: U32) -> U32:
  U32.xor(recur.one(n, seed), 2779096485)

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(U32.show(recur.outside(0n, 7)))
    Unit <- IO.print(U32.show(recur.outside(1n, 7)))
    IO.print(U32.show(recur.outside(4096n, 4294967289)))
#| 2779096482
#| 2779096453
#| 2765750876
