import Base
import ./strand.bend as S

def combine(p: S.Strand & U32, q: S.Strand & U32) -> U32:
  (a, x) = p
  (b, y) = q
  U32.add(U32.add(S.hash(a, 0), S.hash(b, 0)), U32.add(x, y))

def main() -> U32:
  +xs : S.Strand = S.make(2)
  combine(S.probe(xs, 1n), S.probe(xs, 2n))

#|1434
