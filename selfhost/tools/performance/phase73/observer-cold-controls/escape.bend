import Base
import ../fixtures-v2/sharing.bend as S

def call(f: S.Chain -> U32, xs: S.Chain) -> U32:
  f(xs)

def main() -> U32:
  +xs = S.make(4n, 2)
  U32.add(call(S.head, xs), S.sum(xs, 0))

#|16
