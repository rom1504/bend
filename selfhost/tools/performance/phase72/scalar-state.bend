# Scalar state is transported as fields; zero and nonzero returns differ.
import Base

def state72(n: Nat, state: U32 & U32) -> U32:
  match n:
    case 0n:
      (a, b) = state
      U32.add(U32.mul(a, 1000), b)
    case 1n+p:
      (a, b) = state
      state72(p, (b, U32.add(a, 1)))

def drop72(flag: Bool, state: U32 & U32) -> U32:
  match flag:
    case False{}: 13
    case True{}: state72(4n, state)

def main() -> U32:
  U32.add(drop72(False{}, (19, 31)), drop72(True{}, (19, 31)))

#|21046
