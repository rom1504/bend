import Base
import ./strand.bend as S

# The observer's root remains alive while another job reads a shared owner.
# This exercises real pool execution but is not by itself cancellation proof.
def work(seed: U32) -> U32:
  +xs : S.Strand = S.make(seed)
  a b = S.finish_one(S.probe(xs, 1n)) S.hash(xs, 0)
  U32.add(a, b)

def main() -> U32:
  work!(2)

#|7795
