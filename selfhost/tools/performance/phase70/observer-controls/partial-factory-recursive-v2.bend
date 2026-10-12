import Base
import ./v4/strand.bend as S

# Arity raising stops at this demanded Let before the returned lambda.
def make_failing(n: U32) -> U32 -> U32:
  discarded : Nat = S.overflow(n)
  x => x

# Restoration after recursion keeps this off the ordinary flat-worker route.
def inspect(xs: S.Strand, +n: U32) -> S.Strand & U32:
  match xs:
    case S.Void{}:
      (S.Void{}, 0)
    case S.Bead{word, rest}:
      unused_function = make_failing(n)
      S.probe_more(word, inspect(rest, n))

def main() -> U32:
  S.finish_one(inspect(S.make(2), 16777216))

#|bend: a Nat past the largest immediate 2^48-1
#|exit 1
