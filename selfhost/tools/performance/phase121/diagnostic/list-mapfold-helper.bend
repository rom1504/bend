# Diagnostic ceiling only: fuse one private map into its following left fold.
# U32.mul and U32.add retain their original wrapping points and element order.
def p121.mapfold(xs: List<&2, U32>, acc: U32) -> U32:
  match xs:
    case Nil{}:
      acc
    case h <> t:
      p121.mapfold(t, U32.add(acc, U32.mul(h, 2)))
