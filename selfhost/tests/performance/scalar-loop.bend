import Base

# A structurally decreasing Nat controls the loop; its live arithmetic is U32.
# Both inputs arrive at the exported library ABI, preventing constant folding.
def arithmetic(+n: Nat, +acc: U32) -> U32:
  match n:
    case 0n:
      acc
    case 1n+rest:
      +word = U32.from_nat(n)
      arithmetic(rest, U32.add(acc, U32.xor(U32.mul(word, 3), U32.shr(word))))
