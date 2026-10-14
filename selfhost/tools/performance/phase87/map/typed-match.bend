# A fully affine, safe version: the continuation is used once on either arm.
import Base

def route(b: Bool, k: U32 -> U32) -> U32:
  match b:
    case True{}: k(1)
    case False{}: k(2)

def run(+seed: U32, b: Bool) -> U32:
  route(b, x => U32.add(seed, x))

def main() -> U32:
  U32.add(run(40, True{}), run(40, False{}))

#|83
