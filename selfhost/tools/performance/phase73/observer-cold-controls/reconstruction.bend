import Base
import ../fixtures-v2/sharing.bend as S

def changed(xs: S.Chain) -> S.Chain:
  match xs:
    case S.Stop{}: S.Stop{}
    case S.Cell{h, t}: S.Cell{U32.add(h, 1), changed(t)}

def main() -> U32:
  +xs = S.make(4n, 2)
  U32.add(S.sum(changed(xs), 0), S.sum(xs, 0))

#|32
