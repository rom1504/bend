import Base

# Safe model of the admitted Char/constructor/reference representation classes.
# Locations are symbolic Nat tokens. Allocation records expose wrapper effects;
# no claim about physical addresses, finite counters or allocator correctness.
type SealWord is Data:
  SealImmediate{value: String}
  SealRaw{cid: U32, location: Nat}
  SealRef{cid: U32, cell: Nat}

type SealAllocation is Data:
  SealAllocation{cell: Nat, target: Nat, count: Nat}

type SealState is Data:
  SealState{next: Nat, allocations: List<&2, SealAllocation>}

type SealResult is Data:
  SealDone{word: SealWord, state: SealState}

type SealRebuildResult is Data:
  SealRebuilt{retained: SealWord, other: SealWord, remaining: SealWord, state: SealState}

# A raw constructor gains one redirect carrying count 1. Sealing an existing
# reference does not add a reference count, allocate, or change its word.
def seal_wrap_raw(cid: U32, location: Nat, state: SealState) -> SealResult:
  match state:
    case SealState{+next, allocations}:
      SealDone{SealRef{cid, next}, SealState{1n+next, SealAllocation{next, location, 1n} <> allocations}}

def seal_word_operation(word: SealWord, state: SealState) -> SealResult:
  match word:
    case SealImmediate{value}: SealDone{SealImmediate{value}, state}
    case SealRaw{cid, location}: seal_wrap_raw(cid, location, state)
    case SealRef{cid, cell}: SealDone{SealRef{cid, cell}, state}

def seal_result_word(result: SealResult) -> SealWord:
  match result:
    case SealDone{word, state}: word

def seal_representation(word: SealWord) -> Bool:
  match word:
    case SealImmediate{value}: True{}
    case SealRaw{cid, location}: False{}
    case SealRef{cid, cell}: True{}

def seal_rebuild_finish(retained: SealWord, remaining: SealWord, result: SealResult) -> SealRebuildResult:
  match result:
    case SealDone{other, state}: SealRebuilt{retained, other, remaining, state}

def seal_rebuild_after_keep(other: SealWord, remaining: SealWord, result: SealResult) -> SealRebuildResult:
  match result:
    case SealDone{retained, state}:
      seal_rebuild_finish(retained, remaining, seal_word_operation(other, state))

def seal_rebuild_original(retained: SealWord, other: SealWord, remaining: SealWord, state: SealState) -> SealRebuildResult:
  seal_rebuild_after_keep(other, remaining, seal_word_operation(retained, state))

# The proposed optimization omits only the retained field's seal operation.
# The independent incoming owner may still be raw and must always be sealed.
def seal_rebuild_omit(retained: SealWord, other: SealWord, remaining: SealWord, state: SealState) -> SealRebuildResult:
  seal_rebuild_finish(retained, remaining, seal_word_operation(other, state))
