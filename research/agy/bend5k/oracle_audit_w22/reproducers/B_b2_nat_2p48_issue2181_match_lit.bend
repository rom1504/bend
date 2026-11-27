import Base
def pick(n: Nat, a: U32, b: Nat) -> U32:
  match n:
    case 0n: a
    case 1n+_: U32.from_nat(b)
def main() -> IO(Unit):
  IO.print(U32.show(pick(0n, 7, Nat.mul(16777216n, 16777216n))))
