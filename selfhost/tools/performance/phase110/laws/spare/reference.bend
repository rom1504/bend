import Base
import ./candidate.bend as H

# Independent release+allocate specification for the same eligible transition.
# The consumed parent has no remaining owner; fresh is the allocator's chosen
# replacement address. It may differ from the consumed wrapper's address.
# Physical freshness/alias exclusion is an explicit correspondence premise.
def spare_free_then_wrap(fresh: Nat, cid: U32, target: Nat, retained: H.SpareOwner, remaining: H.SpareOwner, frame: List<&2, H.SpareOwner>) -> H.SpareResult:
  H.SpareDone{cid, target, fresh, 1n, 0n, retained, remaining, frame, H.SpareEmpty{}}
