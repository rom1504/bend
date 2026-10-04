# Acyclic user helper with ordinary scalar branching, unrelated public names.
import Base

def quartz.branch(x: U32, y: U32, flag: Bool) -> U32:
  match flag:
    case True{}: U32.add(x, 7)
    case False{}: U32.sub(y, 3)

def glint(+x: U32, +y: U32) -> U32:
  quartz.branch(x, y, U32.is_lt(U32.xor(x, 5), y))
