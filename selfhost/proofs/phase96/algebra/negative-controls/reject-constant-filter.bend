import Base
import ./constant-helpers.bend as M

# Exact public one-step anchor with both filter calls replaced by the
# separately checked always-empty mutant. This is an expected rejection.
law filter_cons_decision_mutant:
  for ~A: Data
  for ~keep: A -> Bool
  for +head: A
  for rest: List<&2, A>
  {M.empty_filter(~A, ~keep, Con{head, rest}) == List.filter.put(A, head, M.empty_filter(~A, ~keep, rest), keep(head)) : List<&2, A>}

def filter_cons_decision_mutant(A, keep, head, rest):
  {==}
