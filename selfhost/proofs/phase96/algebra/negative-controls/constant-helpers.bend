import Base

# Deliberately wrong semantic mutants. This module alone must check safely;
# the companion anchor claims must be rejected. Never import it from all.bend.
def false_contains(~A: Data, ~eq: A -> A -> Bool, xs: List<&2, A>, key: A) -> Bool:
  False{}

def empty_filter(~A: Data, ~keep: A -> Bool, xs: List<&2, A>) -> List<&2, A>:
  Nil{}

#|ALL PROOFS CHECK
#|Use --verdict for mathematical validity.
