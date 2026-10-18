import Base
import ./candidate.bend as H
import ./reference.bend as R

law last_dynamic_raw_reserves:
  for cid: U32
  for target: Nat
  for cell: Nat
  {H.spare_reserve(H.SpareRaw{cid, target}, H.SpareLastDynamic{cell}) == H.SpareHeld{cell} : H.SpareToken}

def last_dynamic_raw_reserves(cid, target, cell): {==}

# Arbitrary incoming words cannot turn a shared or static parent into an
# exclusive wrapper resource. Shared has at least one other parent owner.
law shared_parent_cannot_reserve:
  for incoming: H.SpareIncoming
  for cell: Nat
  for extra: Nat
  {H.spare_reserve(incoming, H.SpareSharedDynamic{cell, extra}) == H.SpareEmpty{} : H.SpareToken}

def shared_parent_cannot_reserve(incoming, cell, extra):
  match incoming:
    case H.SpareImmediate{value}: {==}
    case H.SpareRaw{cid, target}: {==}
    case H.SpareReference{cid, cell}: {==}

law static_parent_cannot_reserve:
  for incoming: H.SpareIncoming
  for redirected: Bool
  for cell: Nat
  {H.spare_reserve(incoming, H.SpareStaticShell{redirected, cell}) == H.SpareEmpty{} : H.SpareToken}

def static_parent_cannot_reserve(incoming, redirected, cell):
  match incoming:
    case H.SpareImmediate{value}: {==}
    case H.SpareRaw{cid, target}: {==}
    case H.SpareReference{cid, cell}: {==}

law raw_parent_has_no_wrapper:
  for incoming: H.SpareIncoming
  {H.spare_reserve(incoming, H.SpareRawDynamic{}) == H.SpareEmpty{} : H.SpareToken}

def raw_parent_has_no_wrapper(incoming):
  match incoming:
    case H.SpareImmediate{value}: {==}
    case H.SpareRaw{cid, target}: {==}
    case H.SpareReference{cid, cell}: {==}

law existing_redirect_needs_no_spare:
  for cid: U32
  for cell: Nat
  for parent: H.SpareParent
  {H.spare_reserve(H.SpareReference{cid, cell}, parent) == H.SpareEmpty{} : H.SpareToken}

def existing_redirect_needs_no_spare(cid, cell, parent): {==}

law immediate_needs_no_spare:
  for value: String
  for parent: H.SpareParent
  {H.spare_reserve(H.SpareImmediate{value}, parent) == H.SpareEmpty{} : H.SpareToken}

def immediate_needs_no_spare(value, parent): {==}

# Owner-credit anchor, independent of the observational equivalence below.
law transferred_wrapper_has_one_owner:
  for cid: U32
  for target: Nat
  for retained: H.SpareOwner
  for remaining: H.SpareOwner
  for frame: List<&2, H.SpareOwner>
  for cell: Nat
  {H.spare_owner_count(H.spare_store(cid, target, retained, remaining, frame, H.SpareHeld{cell})) == 1n : Nat}

def transferred_wrapper_has_one_owner(cid, target, retained, remaining, frame, cell): {==}

# Universal complete ownership observation under the explicit last-dynamic/raw
# premises. Arbitrary fresh address makes allocator address equality unnecessary.
# All retained/remaining/external ownership records are preserved, not checksums.
law spare_transfer_complete:
  for +cid: U32
  for +target: Nat
  for retained: H.SpareOwner
  for remaining: H.SpareOwner
  for frame: List<&2, H.SpareOwner>
  for old_cell: Nat
  for fresh: Nat
  {H.spare_observe(H.spare_store(cid, target, retained, remaining, frame, H.spare_reserve(H.SpareRaw{cid, target}, H.SpareLastDynamic{old_cell}))) == H.spare_observe(R.spare_free_then_wrap(fresh, cid, target, retained, remaining, frame)) : H.SpareObservation}

def spare_transfer_complete(cid, target, retained, remaining, frame, old_cell, fresh): {==}

# The returned token state cannot be spent a second time. This is a statement
# about the transition result, not a claim that Nat names enforce linear use.
law consumed_spare_cannot_wrap_twice:
  for +cid: U32
  for +target: Nat
  for +retained: H.SpareOwner
  for +remaining: H.SpareOwner
  for +frame: List<&2, H.SpareOwner>
  for cell: Nat
  {H.spare_store(cid, target, retained, remaining, frame, H.spare_pending(H.spare_store(cid, target, retained, remaining, frame, H.SpareHeld{cell}))) == H.SpareRefused{retained, remaining, frame} : H.SpareResult}

def consumed_spare_cannot_wrap_twice(cid, target, retained, remaining, frame, cell): {==}

#|ALL PROOFS CHECK
#|Use --verdict for mathematical validity.
