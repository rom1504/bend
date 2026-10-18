import Base

@unsafe
def held_gcd(done: Bool, left: Bool, +a: U32, +b: U32) -> U32:
  match done:
    case True{}: U32.or(a, b)
    case False{}:
      match left:
        case True{}:
          +next = U32.sub(a, b)
          held_gcd(U32.is_zero(next) || U32.is_zero(b), U32.is_gt(next, b), next, b)
        case False{}:
          +next = U32.sub(b, a)
          held_gcd(U32.is_zero(a) || U32.is_zero(next), U32.is_gt(a, next), a, next)

def bench(n: U32, seed: U32) -> U32:
  +a = U32.and(n, 1023)
  +b = U32.and(seed, 1023)
  held_gcd(U32.is_zero(a) || U32.is_zero(b), U32.is_gt(a, b), a, b)

def main() -> U32:
  bench(987, 610)
