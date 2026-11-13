import Base

# Different unwind operations expose swapped case IDs and capture order.
def recur.two(n: Nat, odd: Bool, +seed: U32) -> U32:
  match n:
    case 0n: seed
    case 1n+p:
      match odd:
        case True{}:
          U32.xor(recur.two(p, False{}, U32.add(seed, 5)), U32.mul(seed, 17))
        case False{}:
          U32.add(recur.two(p, True{}, U32.add(seed, 3)), U32.xor(seed, 91))

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(U32.show(recur.two(0n, True{}, 4294967295)))
    Unit <- IO.print(U32.show(recur.two(5n, True{}, 19)))
    IO.print(U32.show(recur.two(129n, False{}, 4294967283)))
#| 4294967295
#| 707
#| 13214
