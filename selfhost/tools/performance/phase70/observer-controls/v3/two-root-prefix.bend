import Base
import ./strand.bend as S

def main() -> U32:
  a : S.Strand = S.Bead{2, S.Bead{7, S.Void{}}}
  S.finish_two(S.compare(a, S.make(2)))

#|11181
