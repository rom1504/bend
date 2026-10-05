import Base

@unsafe
def orbit.a(n: Nat, x: U32, y: U32) -> U32:
  match n:
    case 0n:
      U32.add(U32.mul(x, 100), y)
    case 1n+p:
      orbit.b(p, y, U32.add(x, 1), 7)

@unsafe
def orbit.b(n: Nat, x: U32, y: U32, bonus: U32) -> U32:
  match n:
    case 0n:
      U32.add(U32.add(U32.mul(x, 100), y), bonus)
    case 1n+p:
      orbit.a(p, y, U32.add(x, bonus))

@unsafe
def capture.a(n: Nat, acc: U32, saved: U32 -> U32) -> U32:
  match n:
    case 0n:
      saved(acc)
    case 1n+p:
      capture.b(p, U32.add(acc, 1), x => saved(U32.add(x, acc)), 2)

@unsafe
def capture.b(n: Nat, acc: U32, saved: U32 -> U32, bias: U32) -> U32:
  match n:
    case 0n:
      saved(acc)
    case 1n+p:
      capture.a(p, U32.add(acc, bias), x => saved(U32.add(x, acc)))

def capture.entry(n: Nat, seed: U32) -> U32:
  capture.a(n, seed, x => x)
