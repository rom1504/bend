import Base
import ./strand.bend as S

def main() -> U32:
  a : S.Strand = S.Bead{4294967295, S.Void{}}
  b : S.Strand = S.Bead{0, S.Void{}}
  S.finish_two(S.compare(a, b))

#|4294967198
