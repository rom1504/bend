import Base

# Model-only ownership transition. Cell names are symbolic; an exclusive
# resource token is separate from the arbitrary external ownership frame.
# Concrete address disjointness and classification are refinement premises.
type SpareParent is Data:
  SpareRawDynamic{}
  SpareLastDynamic{cell: Nat}
  SpareSharedDynamic{cell: Nat, extra: Nat}
  SpareStaticShell{redirected: Bool, cell: Nat}

type SpareIncoming is Data:
  SpareImmediate{value: String}
  SpareRaw{cid: U32, target: Nat}
  SpareReference{cid: U32, cell: Nat}

type SpareToken is Data:
  SpareEmpty{}
  SpareHeld{cell: Nat}

type SpareOwner is Data:
  SpareOwner{value: String, owners: Nat}

# Existing roots and owner counts are retained verbatim. The old parent wrapper
# has zero owners after consumption; pending records any unconsumed spare.
type SpareResult is Data:
  SpareRefused{retained: SpareOwner, remaining: SpareOwner, frame: List<&2, SpareOwner>}
  SpareDone{cid: U32, target: Nat, cell: Nat, owners: Nat, old_parent_owners: Nat, retained: SpareOwner, remaining: SpareOwner, frame: List<&2, SpareOwner>, pending: SpareToken}

# Erase ONLY the address chosen for the newly live incoming redirect. Keep
# target/tag, credits, untouched roots/frame and any residual resource token.
type SpareObservation is Data:
  SpareObservedRefusal{retained: SpareOwner, remaining: SpareOwner, frame: List<&2, SpareOwner>}
  SpareObserved{cid: U32, target: Nat, owners: Nat, old_parent_owners: Nat, retained: SpareOwner, remaining: SpareOwner, frame: List<&2, SpareOwner>, pending: SpareToken}

def spare_reserve(incoming: SpareIncoming, parent: SpareParent) -> SpareToken:
  match incoming:
    case SpareImmediate{value}: SpareEmpty{}
    case SpareRaw{cid, target}:
      match parent:
        case SpareRawDynamic{}: SpareEmpty{}
        case SpareLastDynamic{cell}: SpareHeld{cell}
        case SpareSharedDynamic{cell, extra}: SpareEmpty{}
        case SpareStaticShell{redirected, cell}: SpareEmpty{}
    case SpareReference{cid, cell}: SpareEmpty{}

def spare_store(cid: U32, target: Nat, retained: SpareOwner, remaining: SpareOwner, frame: List<&2, SpareOwner>, spare: SpareToken) -> SpareResult:
  match spare:
    case SpareEmpty{}: SpareRefused{retained, remaining, frame}
    case SpareHeld{cell}:
      SpareDone{cid, target, cell, 1n, 0n, retained, remaining, frame, SpareEmpty{}}

def spare_observe(result: SpareResult) -> SpareObservation:
  match result:
    case SpareRefused{retained, remaining, frame}: SpareObservedRefusal{retained, remaining, frame}
    case SpareDone{cid, target, cell, owners, old_parent_owners, retained, remaining, frame, pending}:
      SpareObserved{cid, target, owners, old_parent_owners, retained, remaining, frame, pending}

def spare_pending(result: SpareResult) -> SpareToken:
  match result:
    case SpareRefused{retained, remaining, frame}: SpareEmpty{}
    case SpareDone{cid, target, cell, owners, old_parent_owners, retained, remaining, frame, pending}: pending

def spare_owner_count(result: SpareResult) -> Nat:
  match result:
    case SpareRefused{retained, remaining, frame}: 0n
    case SpareDone{cid, target, cell, owners, old_parent_owners, retained, remaining, frame, pending}: owners
