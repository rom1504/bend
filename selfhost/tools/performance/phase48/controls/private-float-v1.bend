import Base

# Renamed finite recurrence. Each primitive rounds separately; every constant
# stays at its original demand site in the private helper.
def drift.loop(+n: Nat, +x: F32) -> F32:
  match n:
    case 0n: x
    case 1n+q:
      drift.loop(q, F32.add(F32.mul(x, 1.25), 0.125))

def walk(+n: U32, +x: F32) -> F32:
  drift.loop(U32.to_nat(n), x)

# Smallest positive F32 subnormal, written without exponent token syntax.
def grain.loop(+n: Nat, +x: F32) -> F32:
  match n:
    case 0n: x
    case 1n+q:
      grain.loop(q, F32.add(x, 0.000000000000000000000000000000000000000000001401298464324817))

def tiny(+n: U32, +x: F32) -> F32:
  grain.loop(U32.to_nat(n), x)

# Largest positive finite F32, followed by ordinary primitive overflow if used
# more than once. The literal itself is finite.
def crest.loop(+n: Nat, +x: F32) -> F32:
  match n:
    case 0n: x
    case 1n+q:
      crest.loop(q, F32.mul(x, 340282346638528859811704183484516925440.0))

def huge(+n: U32, +x: F32) -> F32:
  crest.loop(U32.to_nat(n), x)

# Signed zero originates from the primitive; infinities and NaNs are runtime
# values, because the source frontend rejects nonfinite compact literals.
def zero.loop(+n: Nat, +x: F32) -> F32:
  match n:
    case 0n: x
    case 1n+q: zero.loop(q, F32.neg(0.0))

def negative_zero(+n: U32, +x: F32) -> F32:
  zero.loop(U32.to_nat(n), x)

def quotient.loop(+n: Nat, +x: F32, +v: F32) -> F32:
  match n:
    case 0n: x
    case 1n+q: quotient.loop(q, F32.div(v, 0.0), v)

def nonfinite(+n: U32, +x: F32, +v: F32) -> F32:
  quotient.loop(U32.to_nat(n), x, v)

# Plain exported literals intentionally retain the ordinary conversion path;
# hooks can retain the module's shared DataView through this public function.
def public_literal() -> F32:
  0.25

def main() -> U32:
  0
