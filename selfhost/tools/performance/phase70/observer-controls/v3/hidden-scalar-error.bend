import Base
import ./strand.bend as S

# The root is unchanged, but the unused scalar calculation is still demanded.
def inspect(xs: S.Strand, n: U32) -> S.Strand & U32:
  dead = S.overflow(n)
  (xs, 0)

def main() -> U32:
  S.finish_one(inspect(S.make(2), 16777216))

#|bend: a Nat past the largest immediate 2^48-1
#|exit 1
