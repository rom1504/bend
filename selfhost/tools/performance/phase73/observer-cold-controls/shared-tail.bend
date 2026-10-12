import Base
import ../fixtures-v2/sharing.bend as S

def main() -> U32:
  +tail = S.make(3n, 2)
  root = {S.Cell{7, tail} : S.Chain}
  U32.add(S.sum(root, 0), S.sum(tail, 0))

#|25
