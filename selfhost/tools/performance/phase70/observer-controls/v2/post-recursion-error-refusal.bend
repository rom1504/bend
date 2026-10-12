import Base
import ./strand.bend as S

# Removing root reconstruction does not turn this into a tail observer: a
# demanded scalar operation follows the recursive call.
def inspect(xs: S.Strand, +n: U32) -> S.Strand & U32:
  match xs:
    case S.Void{}: (S.Void{}, 0)
    case S.Bead{h, t}:
      inspect_more(h, n, inspect(t, n))

def inspect_more(h: U32, n: U32, pair: S.Strand & U32) -> S.Strand & U32:
  (rest, value) = pair
  dead = S.overflow(n)
  (S.Bead{h, rest}, value)

def main() -> U32:
  S.finish_one(inspect(S.make(2), 16777216))

#|bend: a Nat past the largest immediate 2^48-1
#|exit 1
