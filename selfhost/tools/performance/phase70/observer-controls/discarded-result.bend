import Base
import ./strand.bend as S

def only_value(p: S.Strand & U32) -> U32:
  (root, value) = p
  value

def main() -> U32:
  +xs : S.Strand = S.make(2)
  observed = only_value(S.probe(xs, 1n))
  U32.add(observed, S.hash(xs, 0))

#|715
