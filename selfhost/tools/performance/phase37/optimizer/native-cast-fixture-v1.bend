# Phase37 authored F32 recurrence with U32 state observation at every step.
# Each operation rounds separately to F32; no transcendental library tolerance.
import Base

def p37.numeric(n: Nat, +x: F32, h: U32) -> U32:
  match n:
    case 0n:
      h
    case 1n+p:
      +y = F32.mul(F32.mul(3.75, x), F32.sub(1.0, x))
      p37.numeric(p, y,
        U32.xor(U32.mul(h, 16777619), F32.to_u32(F32.mul(y, 1000000.0))))

def bench(size: U32, +seed: U32) -> U32:
  p37.numeric(U32.to_nat(size), F32.div(U32.to_f32(U32.add(U32.mod(seed, 97), 1)), 100.0), seed)

# Actual compiler ownership controls: retain the unchanged recurrence above.
def cast.steps(n: Nat, +x: F32, h: U32) -> U32:
  match n:
    case 0n:
      h
    case 1n+p:
      cast.steps(p, x, U32.xor(U32.mul(h, 16777619), F32.to_u32(x)))

def cast.probe(x: F32) -> U32:
  cast.steps(1n, x, 0)

def cast.order(x: F32, y: F32) -> U32:
  U32.add(cast.steps(1n, x, 0), cast.steps(1n, y, 0))

def cast.once(x: F32) -> U32:
  cast.steps(1n, F32.add(x, 0.25), 0)

def cast.unused(x: F32) -> U32:
  ignored = cast.steps(1n, x, 0)
  17

def cast.staged(x: F32) -> U32 -> U32:
  h => U32.add(F32.to_u32(x), h)
