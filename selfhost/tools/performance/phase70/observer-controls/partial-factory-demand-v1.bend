import Base
import ./v4/strand.bend as S

# Arity raising must stop at the demanded Let before the returned lambda.
def make_failing(n: U32) -> U32 -> U32:
  discarded = S.overflow(n)
  x => x

def inspect(xs: S.Strand) -> S.Strand & U32:
  unused_function = make_failing(16777216)
  (xs, 0)

def main() -> U32:
  S.finish_one(inspect(S.make(2)))

#|bend: a Nat past the largest immediate 2^48-1
#|exit 1
