import Base
import ./candidate.bend as H

# Exact contracts over the safe helper extracted from the actual inliner.
# These do not prove freshness, recursion, traversal, or whole-pass semantics.
law continuation_set:
  for +target: String
  for +value: H.NxExpr
  for +ret: String
  {H.nx_i_continuation(H.NxSet{target, value}, ret) == H.NxSet{target, H.NxVar{ret}} : H.NxStmt}

def continuation_set(target, value, ret): {==}

law continuation_return:
  for +value: H.NxExpr
  for +ret: String
  {H.nx_i_continuation(H.NxReturn{value}, ret) == H.NxReturn{H.NxVar{ret}} : H.NxStmt}

def continuation_return(value, ret): {==}

#|ALL PROOFS CHECK
#|Use --verdict for mathematical validity.
