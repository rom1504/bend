# A raised full call evaluates its supplied arguments before its matcher body.
# Pinned upstream emit_args therefore reaches Nat overflow before ERR_TAGS.
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
  gate68(IO.print("SECRET")(U32, x => Emit{7}), overflow68(16777216))

#|bend: a Nat past the largest immediate 2^48-1
#|exit 1
