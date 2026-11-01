import Base
import ./constant-helpers.bend as M
import ../membership.bend as P

# Exact public singleton anchor with its membership callee replaced by the
# separately checked always-False mutant. This is an expected rejection.
law contains_singleton_mutant:
  for ~A: Data
  for ~eq: A -> A -> Bool
  for head: A
  for +key: A
  {M.false_contains(~A, ~eq, Con{head, Nil{}}, key) == eq(head, key) : Bool}

def contains_singleton_mutant(A, eq, head, key):
  P.or_right_identity(eq(head, key))
