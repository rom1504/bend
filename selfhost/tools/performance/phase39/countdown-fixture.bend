import Base

# Exactly one predecessor use, solely the saturated self-tail argument.
def p39.count(n: Nat, h: U32) -> U32:
  match n:
    case 0n: h
    case 1n+p: p39.count(p, U32.add(h, 3))

def count_check(n: U32, seed: U32) -> U32:
  p39.count(U32.to_nat(n), seed)

# A second scalar shape with a Nat result. The accumulated Nat is unchanged;
# its public representation must remain BigInt even if the counter narrows.
def p39.keep(n: Nat, h: Nat) -> Nat:
  match n:
    case 0n: h
    case 1n+p: p39.keep(p, h)

def keep_check(n: U32, value: Nat) -> Nat:
  p39.keep(U32.to_nat(n), value)

# The predecessor escapes as another argument and eventually a Nat result.
# +n permits duplication; the Number-counter proof must refuse it.
def p39.escape(+n: Nat, h: Nat) -> Nat:
  match n:
    case 0n: h
    case 1n+p: p39.escape(p, p)

def escape_check(n: U32, value: Nat) -> Nat:
  p39.escape(U32.to_nat(n), value)

# Extra predecessor use in arithmetic must also retain the BigInt countdown.
def p39.observe(+n: Nat, h: U32) -> U32:
  match n:
    case 0n: h
    case 1n+p: p39.observe(p, U32.add(h, U32.from_nat(p)))

def observe_check(n: U32, seed: U32) -> U32:
  p39.observe(U32.to_nat(n), seed)
