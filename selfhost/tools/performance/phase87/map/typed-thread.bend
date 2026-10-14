# A composable alternative: each branch consumes k as an argument, not capture.
import Base

def choose_k(b: Bool, yes: (U32 -> U32) -> U32, no: (U32 -> U32) -> U32, k: U32 -> U32) -> U32:
  match b:
    case True{}: yes(k)
    case False{}: no(k)

def route(b: Bool, k: U32 -> U32) -> U32:
  choose_k(b, f => f(1), f => f(2), k)

def run(+seed: U32, b: Bool) -> U32:
  route(b, x => U32.add(seed, x))

def main() -> U32:
  U32.add(run(40, True{}), run(40, False{}))

#|83
