# Ordinary full-width Nat witnesses. Zero divisor is valid language input.
import Base

def quotient.text(pair: Nat & Nat) -> String:
  (q, r) = pair
  Nat.show(q) ++ ":" ++ Nat.show(r)

def quotient.product(a: Nat, b: Nat) -> Nat & Nat:
  Nat.divmod(a, b)

def quotient.sum(pair: Nat & Nat) -> Nat:
  (q, r) = pair
  Nat.add(q, r)

def quotient.flat(a: Nat, b: Nat) -> Nat:
  quotient.sum(Nat.divmod(a, b))

def quotient.wide(hi: Nat, lo: Nat) -> Nat:
  Nat.add(Nat.mul(hi, 65536n), lo)

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
    Unit <- quotient.check(quotient.wide(65536n, 0n), 0n)
    Unit <- quotient.check(quotient.wide(4294967295n, 65535n), 0n)
    Unit <- quotient.check(quotient.wide(4294967295n, 65535n), 1n)
    Unit <- quotient.check(quotient.wide(4294967295n, 65535n), 2n)
    Unit <- quotient.check(quotient.wide(4294967295n, 65535n), 3n)
    Unit <- quotient.check(quotient.wide(4294967295n, 65535n), 33n)
    Unit <- quotient.check(quotient.wide(65536n, 0n), 33n)
    Unit <- quotient.check(quotient.wide(1883801101n, 57209n), quotient.wide(4294967295n, 65535n))
    Unit <- quotient.check(quotient.wide(4294967295n, 65535n), quotient.wide(4294967295n, 65535n))
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
