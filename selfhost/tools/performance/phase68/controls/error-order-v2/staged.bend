# A full plain-value helper completes its parameter match before the next let.
# The request tag fails first. Neither overflow nor SECRET is executed.
import Base

def overflow68(+n: U32) -> Nat:
  Nat.mul(U32.to_nat(n), U32.to_nat(n))

def staged68(op: IO.OP<U32>) -> U32:
  match op:
    case Emit{value}:
      value
    case Halt{code, message}:
      code

def main() -> U32:
  first = staged68(IO.print("SECRET")(U32, x => Emit{7}))
  second = overflow68(16777216)
  U32.add(first, U32.from_nat(second))

#|bend: runtime fail-stop
#|exit 1
