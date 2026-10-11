# make_g fails while computing the second capture. The first literal's body
# must remain delayed; it would instead reach a request-tag fail-stop.
import Base

def before(f: U32 -> U32, g: U32 -> U32, x: U32) -> U32:
  g(f(x))

def request(op: IO.OP<U32>) -> U32:
  match op:
    case Emit{value}:
      value
    case Halt{code, message}:
      code

def make_g(+n: U32) -> U32 -> U32:
  value = Nat.mul(U32.to_nat(n), U32.to_nat(n))
  x => U32.add(x, U32.from_nat(value))

def main() -> U32:
  f = {before(x => request(IO.print("SECRET")(U32, y => Emit{7})), make_g(16777216)) : U32 -> U32}
  f(0)

#|bend: a Nat past the largest immediate 2^48-1
#|exit 1
