# An explicit match is a sequencing boundary: the request tag is refused
# before either branch computes the overflow argument. SECRET never executes.
import Base

def overflow68(+n: U32) -> Nat:
  Nat.mul(U32.to_nat(n), U32.to_nat(n))

def gate68(op: IO.OP<U32>) -> Nat -> U32:
  match op:
    case Emit{value}:
      n => U32.add(value, U32.from_nat(n))
    case Halt{code, message}:
      n => U32.add(code, U32.from_nat(n))

def main() -> U32:
  op = IO.print("SECRET")(U32, x => Emit{7})
  match op:
    case Emit{value}:
      U32.add(value, U32.from_nat(overflow68(16777216)))
    case Halt{code, message}:
      U32.add(code, U32.from_nat(overflow68(16777216)))

#|bend: runtime fail-stop
#|exit 1
