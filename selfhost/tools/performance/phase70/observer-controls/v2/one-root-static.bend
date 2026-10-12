import Base
import ./strand.bend as S

def main() -> U32:
  xs : S.Strand = S.Bead{2, S.Bead{7, S.Bead{11, S.Void{}}}}
  S.finish_one(S.probe(xs, 1n))

#|7087
