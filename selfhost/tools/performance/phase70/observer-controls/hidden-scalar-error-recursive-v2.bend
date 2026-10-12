import Base
import ./v4/strand.bend as S

# Reconstruct after recursion so ordinary non-tail worker admission declines.
# The unused primitive must still be evaluated before descending into the tail.
def inspect(xs: S.Strand, +n: U32) -> S.Strand & U32:
  match xs:
    case S.Void{}:
      (S.Void{}, 0)
    case S.Bead{word, rest}:
      discarded : Nat = S.overflow(n)
      S.probe_more(word, inspect(rest, n))

def main() -> U32:
  S.finish_one(inspect(S.make(2), 16777216))

#|bend: a Nat past the largest immediate 2^48-1
#|exit 1
