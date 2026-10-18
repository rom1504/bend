import Base
import ./candidate.bend as H

# One parent and its two separately accounted child cells. A heap child's
# aliases count is additional owners beyond the one edge/handle being moved.
# Strings stand for immutable object identities/payload observations, not C
# pointers. Trivial children have no refcount. All counts are structural Nat.
type NxoLawChild is Data:
  NxoLawTrivial{value: String}
  NxoLawHeapChild{value: String, aliases: Nat}

# Shared{extra,...} has 2+extra parent owners before consumption, hence
# 1+extra afterwards. Static parents admit only trivial children, as in the
# actual Phase109/110 entry contract. Unique includes a last-owner redirect.
type NxoLawParent is Data:
  NxoLawUnique{first: NxoLawChild, second: NxoLawChild}
  NxoLawShared{extra: Nat, first: NxoLawChild, second: NxoLawChild}
  NxoLawImmortal{first: String, second: String}

type NxoLawAliases is Data:
  NxoLawGone{}
  NxoLawLiveAliases{owners: Nat, first: String, second: String}
  NxoLawStaticAliases{first: String, second: String}

type NxoLawTaken is Data:
  NxoLawTaken{storage: H.NxoLawStorage, aliases: NxoLawAliases, first: NxoLawChild, second: NxoLawChild}

# Complete modeled result: reuse decision, reconstructed constructor/tag,
# exact remaining child and all root counts, externally visible old-parent
# contents/owner count, and scratch transfer state. No checksum projection.
type NxoLawResult is Data:
  NxoLawResult{reuse: Bool, tag: U32, kept: NxoLawChild, other: NxoLawChild, remaining: NxoLawChild, aliases: NxoLawAliases, pending: Bool}

def nxo_law_child_value(child: NxoLawChild) -> String:
  match child:
    case NxoLawTrivial{value}: value
    case NxoLawHeapChild{value, aliases}: value

def nxo_law_claim(child: NxoLawChild) -> NxoLawChild:
  match child:
    case NxoLawTrivial{value}: NxoLawTrivial{value}
    case NxoLawHeapChild{value, aliases}: NxoLawHeapChild{value, 1n+aliases}

def nxo_law_take(parent: NxoLawParent) -> NxoLawTaken:
  match parent:
    case NxoLawUnique{first, second}:
      NxoLawTaken{H.NxoLawUniqueDynamic{}, NxoLawGone{}, first, second}
    case NxoLawShared{extra, +first, +second}:
      NxoLawTaken{H.NxoLawSharedDynamic{},
        NxoLawLiveAliases{1n+extra, nxo_law_child_value(first), nxo_law_child_value(second)},
        nxo_law_claim(first), nxo_law_claim(second)}
    case NxoLawImmortal{+first, +second}:
      NxoLawTaken{H.NxoLawStatic{}, NxoLawStaticAliases{first, second},
        NxoLawTrivial{first}, NxoLawTrivial{second}}

# The actual source-connected selector determines which whole child ownership
# record enters the new constructor and which one escapes through scratch.
def nxo_law_build_transfer(tag: U32, selection: H.NxoLawSelection<NxoLawChild>, other: NxoLawChild, aliases: NxoLawAliases, reuse: Bool) -> NxoLawResult:
  match selection:
    case H.NxoLawSelection{index, retained, remaining}:
      NxoLawResult{reuse, tag, retained, other, remaining, aliases, False{}}

def nxo_law_after_take(tag: U32, keep_first: Bool, other: NxoLawChild, taken: NxoLawTaken) -> NxoLawResult:
  match taken:
    case NxoLawTaken{storage, aliases, first, second}:
      nxo_law_build_transfer(tag, H.nxo_law_select(NxoLawChild, keep_first, first, second), other, aliases, H.nxo_law_reuse(storage))

def nxo_law_fused(tag: U32, keep_first: Bool, parent: NxoLawParent, other: NxoLawChild) -> NxoLawResult:
  nxo_law_after_take(tag, keep_first, other, nxo_law_take(parent))
