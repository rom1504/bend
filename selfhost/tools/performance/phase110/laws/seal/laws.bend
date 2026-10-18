import Base
import ./candidate.bend as H

# Semantic anchor: a raw word is not silently declared stored. The complete
# result includes exactly one wrapper with initial count 1 and its allocation.
law raw_seal_allocates_one:
  for cid: U32
  for location: Nat
  for +next: Nat
  for allocations: List<&2, H.SealAllocation>
  {H.seal_word_operation(H.SealRaw{cid, location}, H.SealState{next, allocations}) == H.SealDone{H.SealRef{cid, next}, H.SealState{1n+next, H.SealAllocation{next, location, 1n} <> allocations}} : H.SealResult}

def raw_seal_allocates_one(cid, location, next, allocations): {==}

# The stored-field invariant is derived from the constructor writer's seal;
# neither a pre-assumed fixed point nor an unvalidated caller Boolean is used.
law writer_establishes_stored_representation:
  for word: H.SealWord
  for state: H.SealState
  {H.seal_representation(H.seal_result_word(H.seal_word_operation(word, state))) == True{} : Bool}

def writer_establishes_stored_representation(word, state):
  match word:
    case H.SealImmediate{value}: {==}
    case H.SealRaw{cid, location}:
      match state:
        case H.SealState{next, allocations}: {==}
    case H.SealRef{cid, cell}:
      match state:
        case H.SealState{next, allocations}: {==}

# Stronger than same-state idempotence: intervening field seals or wrapper
# allocations may have changed the ledger. A stored word still has no sealing
# effects in any later state, including arbitrary unrelated prior allocations.
law stored_field_fixed_in_later_state:
  for +word: H.SealWord
  for +writer_state: H.SealState
  for +later_state: H.SealState
  {H.seal_word_operation(H.seal_result_word(H.seal_word_operation(word, writer_state)), later_state) == H.SealDone{H.seal_result_word(H.seal_word_operation(word, writer_state)), later_state} : H.SealResult}

def stored_field_fixed_in_later_state(word, writer_state, later_state):
  match word:
    case H.SealImmediate{value}: {==}
    case H.SealRaw{cid, location}:
      match writer_state:
        case H.SealState{next, allocations}: {==}
    case H.SealRef{cid, cell}: {==}

# The retained word comes from the modeled dynamic writer; other is arbitrary.
# Equality covers both rebuilt words, remaining word and complete allocation
# state. Thus omitting the incoming other's seal is observably incorrect.
law retained_seal_omission_complete:
  for +word: H.SealWord
  for +writer_state: H.SealState
  for +later_state: H.SealState
  for +other: H.SealWord
  for +remaining: H.SealWord
  {H.seal_rebuild_original(H.seal_result_word(H.seal_word_operation(word, writer_state)), other, remaining, later_state) == H.seal_rebuild_omit(H.seal_result_word(H.seal_word_operation(word, writer_state)), other, remaining, later_state) : H.SealRebuildResult}

def retained_seal_omission_complete(word, writer_state, later_state, other, remaining):
  Equal.cong(H.SealResult, H.SealRebuildResult,
    result => H.seal_rebuild_after_keep(other, remaining, result),
    H.seal_word_operation(H.seal_result_word(H.seal_word_operation(word, writer_state)), later_state),
    H.SealDone{H.seal_result_word(H.seal_word_operation(word, writer_state)), later_state},
    stored_field_fixed_in_later_state(word, writer_state, later_state))

#|ALL PROOFS CHECK
#|Use --verdict for mathematical validity.
