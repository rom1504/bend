import Base

# Unequal live arities; the callback runs while the component owns live state.
@unsafe
def relay.a(n: Nat, +acc: U32, +observe: U32 -> U32) -> U32:
  match n:
    case 0n:
      acc
    case 1n+p:
      relay.b(p, observe(acc), observe, 3)

@unsafe
def relay.b(n: Nat, +acc: U32, +observe: U32 -> U32, +bias: U32) -> U32:
  match n:
    case 0n:
      acc
    case 1n+p:
      relay.a(p, observe(U32.add(acc, bias)), observe)

# The next iteration must retain the previous iteration's lexical value.
# The terminal source callback is an unknown closure tail, not a named transfer.
@unsafe
def stash.a(n: Nat, +value: U32, +peek: Unit -> U32) -> U32:
  match n:
    case 0n:
      peek(Unit{})
    case 1n+p:
      stash.b(p, U32.add(value, 1), u => value)

@unsafe
def stash.b(n: Nat, +value: U32, +peek: Unit -> U32) -> U32:
  match n:
    case 0n:
      peek(Unit{})
    case 1n+p:
      stash.a(p, U32.add(value, 1), u => value)

# Program mode has this one root and reaches only the relay component's leader.
def main() -> U32:
  relay.a(100000n, 7, x => x)
