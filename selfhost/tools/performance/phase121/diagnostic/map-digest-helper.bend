# Diagnostic ceiling only: consume Map directly in Map.to_list order.
# The noncommutative string/value digest remains lo-before-hi; keys are consumed once.
def p121.map_digest(m: Map<&2, U32>, acc: U32) -> U32:
  match m:
    case MTip{}:
      acc
    case MLeaf{k, v}:
      U32.xor(U32.mul(p37.map.string(k, acc), 16777619), v)
    case MNode{pos, lo, hi}:
      p121.map_digest(hi, p121.map_digest(lo, acc))
