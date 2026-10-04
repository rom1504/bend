# Minimal generic source admission fixture: scalar input/output, fresh owned Map.
# Full structural fixture.bend remains an independent public-value control.
import Base

def p43.map.scalar(+seed: U32) -> U32:
  m = Map.new(&2, U32)
  m = Map.set(&2, U32, m, "a", seed)
  m = Map.set(&2, U32, m, "ab", U32.add(seed, 1))
  m = Map.set(&2, U32, m, "a", U32.add(seed, 2))
  m = Map.set(&2, U32, m, "b", U32.add(seed, 3))
  m = Map.del(&2, U32, m, "absent")
  m = Map.del(&2, U32, m, "ab")
  match Map.get(&2, U32, m, "a"):
    case None{}: 0
    case Some{value}: value
