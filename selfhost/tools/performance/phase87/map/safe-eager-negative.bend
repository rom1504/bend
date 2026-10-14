# This must not be accepted as affine code: both separately built thunks own k.
import Base

def choose(-A: Type, b: Bool, yes: Unit -> A, no: Unit -> A) -> A:
  match b:
    case True{}: yes(Unit{})
    case False{}: no(Unit{})

def route(b: Bool, k: U32 -> U32) -> U32:
  choose(U32, b, u => k(1), u => k(2))

def run(+seed: U32, b: Bool) -> U32:
  route(b, x => U32.add(seed, x))

def main() -> U32:
  U32.add(run(40, True{}), run(40, False{}))
