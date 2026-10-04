# Minimal generic source admission fixture: scalar input/output, fresh owned Map.
# Full structural fixture.bend remains an independent public-value control.
import Base

def p43.map.scalar.value(r: Map<&2, U32> & U32) -> U32:
  (m, value) = r
  value

def p43.map.scalar(+seed: U32) -> U32:
  +m: Map<&2, U32> = Map.new(&2, U32)
  +m: Map<&2, U32> = Map.set(&2, U32, m, "a", seed)
  +m: Map<&2, U32> = Map.set(&2, U32, m, "ab", U32.add(seed, 1))
  +m: Map<&2, U32> = Map.set(&2, U32, m, "a", U32.add(seed, 2))
  +m: Map<&2, U32> = Map.set(&2, U32, m, "b", U32.add(seed, 3))
  +m: Map<&2, U32> = Map.del(&2, U32, m, "absent")
  +m: Map<&2, U32> = Map.del(&2, U32, m, "ab")
  p43.map.scalar.value(Map.get(U32, 0, m, "a"))
