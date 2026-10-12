import Base
import ./strand.bend as S

def main() -> U32:
  +xs : S.Strand = S.make(2)
  S.finish_two(S.compare(xs, xs))

#|77880
