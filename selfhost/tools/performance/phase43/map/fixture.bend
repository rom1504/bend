# Literal correctness fixture; no source-name optimization permission.
import Base
def p43.map.fixture() -> List<&2, Sigma<&2, &2, String, _ => U32>>:
  m = Map.new(&2, U32)
  m = Map.set(&2, U32, m, "a", 1)
  m = Map.set(&2, U32, m, "ab", 2)
  m = Map.set(&2, U32, m, "a", 3)
  m = Map.set(&2, U32, m, "b", 4)
  m = Map.del(&2, U32, m, "absent")
  m = Map.del(&2, U32, m, "ab")
  Map.to_list(&2, U32, m)
