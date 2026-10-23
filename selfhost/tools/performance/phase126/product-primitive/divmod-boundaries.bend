# Ordinary full-width Nat witnesses. Zero divisor is valid language input.
import Base

def quotient.text(pair: Nat & Nat) -> String:
  (q, r) = pair
  Nat.show(q) ++ ":" ++ Nat.show(r)

def quotient.product(a: Nat, b: Nat) -> Nat & Nat:
  Nat.divmod(a, b)

def quotient.flat(a: Nat, b: Nat) -> Nat:
  (q, r) = Nat.divmod(a, b)
  Nat.add(q, r)

def quotient.check(+a: Nat, +b: Nat) -> IO(Unit):
  +pair = quotient.product(a, b)
  do IO<Unit>:
    Unit <- IO.print(quotient.text(pair))
    Unit <- IO.print(quotient.text(pair))
    IO.print(Nat.show(quotient.flat(a, b)))

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- quotient.check(0n, 0n)
    Unit <- quotient.check(1n, 0n)
    Unit <- quotient.check(4294967296n, 0n)
    Unit <- quotient.check(281474976710655n, 0n)
    Unit <- quotient.check(281474976710655n, 1n)
    Unit <- quotient.check(281474976710655n, 2n)
    Unit <- quotient.check(281474976710655n, 3n)
    Unit <- quotient.check(281474976710655n, 33n)
    Unit <- quotient.check(4294967296n, 33n)
    Unit <- quotient.check(123456789012345n, 281474976710655n)
    Unit <- quotient.check(281474976710655n, 281474976710655n)
    quotient.check(1000n, 7n)

#| 0:0
#| 0:0
#| 0
#| 0:1
#| 0:1
#| 1
#| 0:4294967296
#| 0:4294967296
#| 4294967296
#| 0:281474976710655
#| 0:281474976710655
#| 281474976710655
#| 281474976710655:0
#| 281474976710655:0
#| 281474976710655
#| 140737488355327:1
#| 140737488355327:1
#| 140737488355328
#| 93824992236885:0
#| 93824992236885:0
#| 93824992236885
#| 8529544748807:24
#| 8529544748807:24
#| 8529544748831
#| 130150524:4
#| 130150524:4
#| 130150528
#| 0:123456789012345
#| 0:123456789012345
#| 123456789012345
#| 1:0
#| 1:0
#| 1
#| 142:6
#| 142:6
#| 148
