import Base
import ./v4/strand.bend as S

# A discarded native successor still performs a checked 48-bit increment.
def inspect(xs: S.Strand, n: Nat) -> S.Strand & U32:
  discarded = 1n+n
  (xs, 0)

def main() -> U32:
  largest = Nat.add(Nat.mul(16777215n, 16777216n), 16777215n)
  S.finish_one(inspect(S.make(2), largest))

#|bend: a Nat past the largest immediate 2^48-1
#|exit 1
