import Base
import ./strand.bend as S

def main() -> U32:
  +tail : S.Strand = S.make_tail(2)
  a : S.Strand = S.Bead{2, tail}
  b : S.Strand = S.Bead{3, tail}
  S.finish_two(S.compare(a, b))

#|80771
