import Base
import ./sharing.bend as S

def work(seed: U32) -> U32:
  +root = S.make(10000n, seed)
  a b = S.sum(root, 0) S.sum(root, 0)
  U32.add(a, b)

def main() -> U32:
  work!(1)

#|100010000
