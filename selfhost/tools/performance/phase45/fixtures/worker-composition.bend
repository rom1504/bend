# Independent first-order worker controls, unrelated to timed source names.
# Unsafe marks separate backend execution tests from a mutual-termination proof.
import Base

def conduit(-T: Type, value: T) -> T:
  value

# NON-tail cycle: the pending operations differ, and retain the caller's seed.
@unsafe
def azimuth(n: Nat, +seed: U32) -> U32:
  match n:
    case 0n: seed
    case 1n+rest:
      answer = meridian(rest, U32.add(seed, 3))
      U32.sub(U32.mul(answer, 3), seed)

@unsafe
def meridian(n: Nat, +seed: U32) -> U32:
  match n:
    case 0n: U32.add(seed, 13)
    case 1n+rest:
      answer = azimuth(rest, U32.add(seed, 5))
      U32.add(answer, U32.mul(seed, 7))

def bench(size: U32, seed: U32) -> U32:
  conduit(U32, azimuth(U32.to_nat(size), seed))

# Same source cycle pattern, different operations and pure tail transfers.
@unsafe
def port(n: Nat, seed: U32) -> U32:
  match n:
    case 0n: seed
    case 1n+rest: starboard(rest, U32.add(seed, 3))

@unsafe
def starboard(n: Nat, seed: U32) -> U32:
  match n:
    case 0n: U32.add(seed, 13)
    case 1n+rest: port(rest, U32.add(seed, 5))

def tail_check(size: U32, seed: U32) -> U32:
  conduit(U32, port(U32.to_nat(size), seed))

type Ribbon is Data:
  RibbonEnd{value: U32}
  RibbonMark{value: U32, rest: Ribbon}

# The recursive result must return before constructing its caller's mark.
@unsafe
def willow(n: Nat, +seed: U32) -> Ribbon:
  match n:
    case 0n: RibbonEnd{seed}
    case 1n+rest:
      child = juniper(rest, U32.add(seed, 3))
      RibbonMark{U32.add(seed, 1), child}

@unsafe
def juniper(n: Nat, +seed: U32) -> Ribbon:
  match n:
    case 0n: RibbonEnd{U32.add(seed, 11)}
    case 1n+rest:
      child = willow(rest, U32.add(seed, 5))
      RibbonMark{U32.xor(seed, 85), child}

def ribbon.sum(value: Ribbon, total: U32) -> U32:
  match value:
    case RibbonEnd{x}: U32.add(total, x)
    case RibbonMark{x, rest}: ribbon.sum(rest, U32.add(total, x))

def tree_check(size: U32, seed: U32) -> U32:
  value = conduit(Ribbon, willow(U32.to_nat(size), seed))
  ribbon.sum(value, 0)

# Public data output checks complete order/values separately from scalar entry.
# Its result type may retain generic entry; do not infer worker activation here.
def tree_value(size: U32, seed: U32) -> Ribbon:
  conduit(Ribbon, willow(U32.to_nat(size), seed))

# Save outer values across the recursive call and a later lexical shadow.
def scope_check(size: U32, +seed: U32) -> U32:
  +carry = U32.add(seed, 2)
  answer = azimuth(U32.to_nat(size), carry)
  outer = carry
  carry = U32.add(seed, 17)
  conduit(U32, U32.sub(U32.add(answer, outer), carry))

# Two demanded child calls occur before a noncommutative combination.
def sibling_check(+size: U32, +seed: U32) -> U32:
  left = azimuth(U32.to_nat(size), seed)
  right = meridian(U32.to_nat(size), U32.add(seed, 1))
  conduit(U32, U32.sub(left, right))
