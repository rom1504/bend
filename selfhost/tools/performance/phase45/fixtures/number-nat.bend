# Independent boundary controls for a private Number representation of Nat.
# Compact source literals stop at U32; larger values are computed or supplied.
import Base

def nat.keep(-T: Type, value: T) -> T:
  value

def bench(value: U32) -> U32:
  nat.keep(U32, U32.from_nat(Nat.add(4294967295n, U32.to_nat(value))))

def identity(value: Nat) -> Nat:
  nat.keep(Nat, value)

def constructed(value: Nat) -> Nat:
  nat.keep(Nat, Nat.add(4294967295n, value))

def successor(value: Nat) -> Nat:
  nat.keep(Nat, Succ{value})

def add(left: Nat, right: Nat) -> Nat:
  nat.keep(Nat, Nat.add(left, right))

def subtract(left: Nat, right: Nat) -> Nat:
  nat.keep(Nat, Nat.sub(left, right))

def less(left: Nat, right: Nat) -> Bool:
  nat.keep(Bool, Nat.is_lt(left, right))

def nat.first(value: Nat & Nat) -> Nat:
  match value:
    case (first, second): first

def nat.second(value: Nat & Nat) -> Nat:
  match value:
    case (first, second): second

def quotient(left: Nat, right: Nat) -> Nat:
  nat.keep(Nat, nat.first(Nat.divmod(left, right)))

def remainder(left: Nat, right: Nat) -> Nat:
  nat.keep(Nat, nat.second(Nat.divmod(left, right)))

def to_word(value: Nat) -> U32:
  nat.keep(U32, U32.from_nat(value))

def from_word(value: U32) -> Nat:
  nat.keep(Nat, U32.to_nat(value))

def shift_left(value: U32, count: Nat) -> U32:
  nat.keep(U32, U32.shln(value, count))

def shift_right(value: U32, count: Nat) -> U32:
  nat.keep(U32, U32.shrn(value, count))

def nat.descend(count: Nat, seed: Nat) -> Nat:
  match count:
    case 0n: Nat.add(seed, 1n)
    case 1n+rest: nat.descend(rest, seed)

def error_check(seed: Nat) -> Nat:
  nat.keep(Nat, nat.descend(1n, seed))

# A private tagged object containing Nat remains internal to this root.
type Counter is Data:
  Counter{value: Nat}

def nat.open(counter: Counter) -> Nat:
  match counter:
    case Counter{value}: value

def nested(value: Nat) -> Nat:
  nat.open(nat.keep(Counter, Counter{Nat.add(value, 1n)}))

# This object-result export must retain its generic public representation.
def public_counter(value: Nat) -> Counter:
  nat.keep(Counter, Counter{value})
