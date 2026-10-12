import Base
import ./strand.bend as S

def inspect(xs: S.Strand) -> S.Strand & U32:
  match xs:
    case S.Void{}: (S.Void{}, 0)
    case S.Bead{h, t}: (S.Bead{U32.add(h, 1), t}, 0)

def main() -> U32:
  S.finish_one(inspect(S.make(2)))

#|9970
