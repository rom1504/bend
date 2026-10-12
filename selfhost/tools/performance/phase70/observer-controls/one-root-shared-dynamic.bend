import Base
import ./strand.bend as S

def main() -> U32:
  +xs : S.Strand = S.make(2)
  (a, x) = S.probe(xs, 1n)
  (b, y) = S.probe(xs, 2n)
  U32.add(U32.add(S.hash(a, 0), S.hash(b, 0)), U32.add(x, y))

#|1434
