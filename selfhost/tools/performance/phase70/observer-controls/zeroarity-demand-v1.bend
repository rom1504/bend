import Base
import ./v4/strand.bend as S

# A zero-argument call lowers to a demanded Ref, not a deferred closure.
def fail_scalar() -> Nat:
  S.overflow(16777216)

def inspect(xs: S.Strand) -> S.Strand & U32:
  discarded = fail_scalar()
  (xs, 0)

def main() -> U32:
  S.finish_one(inspect(S.make(2)))

#|bend: a Nat past the largest immediate 2^48-1
#|exit 1
