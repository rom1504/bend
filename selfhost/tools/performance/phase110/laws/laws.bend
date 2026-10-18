import Base
import ./candidate.bend as H
import ./model.bend as M
import ./reference.bend as R
import ./selector.bend as S

# This anchor constrains the child claim independently of the reconstruction
# equation. It rejects a missing shared-child retain even for arbitrary counts.
law shared_transfer_claims:
  for value: String
  for aliases: Nat
  {M.nxo_law_claim(M.NxoLawHeapChild{value, aliases}) == M.NxoLawHeapChild{value, 1n+aliases} : M.NxoLawChild}

def shared_transfer_claims(value, aliases): {==}

law trivial_transfer_has_no_count:
  for value: String
  {M.nxo_law_claim(M.NxoLawTrivial{value}) == M.NxoLawTrivial{value} : M.NxoLawChild}

def trivial_transfer_has_no_count(value): {==}

# Unique consumption moves each child owner; it creates no extra ownership.
law unique_take_transfers:
  for first: M.NxoLawChild
  for second: M.NxoLawChild
  {M.nxo_law_take(M.NxoLawUnique{first, second}) == M.NxoLawTaken{H.NxoLawUniqueDynamic{}, M.NxoLawGone{}, first, second} : M.NxoLawTaken}

def unique_take_transfers(first, second): {==}

# Static contents remain observable to every immortal alias and cannot become
# a writable spare. Its child-type premise is encoded in NxoLawImmortal.
law static_take_preserves_aliases:
  for +first: String
  for +second: String
  {M.nxo_law_take(M.NxoLawImmortal{first, second}) == M.NxoLawTaken{H.NxoLawStatic{}, M.NxoLawStaticAliases{first, second}, M.NxoLawTrivial{first}, M.NxoLawTrivial{second}} : M.NxoLawTaken}

def static_take_preserves_aliases(first, second): {==}

# Complete local equivalence for every admitted parent storage/ownership class,
# constructor tag, selected field, child payload, external child root count,
# external parent owner count, and incoming other owner. The independent right
# side states consume/build/transfer directly, without candidate helpers.
law reconstruction_complete:
  for tag: U32
  for keep_first: Bool
  for parent: M.NxoLawParent
  for other: M.NxoLawChild
  {M.nxo_law_fused(tag, keep_first, parent, other) == R.consume_build_transfer(tag, keep_first, parent, other) : M.NxoLawResult}

def reconstruction_complete(tag, keep_first, parent, other):
  match keep_first:
    case True{}:
      match parent:
        case M.NxoLawUnique{first, second}: {==}
        case M.NxoLawShared{extra, first, second}:
          match first:
            case M.NxoLawTrivial{a}:
              match second:
                case M.NxoLawTrivial{b}: {==}
                case M.NxoLawHeapChild{b, n}: {==}
            case M.NxoLawHeapChild{a, n}:
              match second:
                case M.NxoLawTrivial{b}: {==}
                case M.NxoLawHeapChild{b, m}: {==}
        case M.NxoLawImmortal{first, second}: {==}
    case False{}:
      match parent:
        case M.NxoLawUnique{first, second}: {==}
        case M.NxoLawShared{extra, first, second}:
          match first:
            case M.NxoLawTrivial{a}:
              match second:
                case M.NxoLawTrivial{b}: {==}
                case M.NxoLawHeapChild{b, n}: {==}
            case M.NxoLawHeapChild{a, n}:
              match second:
                case M.NxoLawTrivial{b}: {==}
                case M.NxoLawHeapChild{b, m}: {==}
        case M.NxoLawImmortal{first, second}: {==}

#|ALL PROOFS CHECK
#|Use --verdict for mathematical validity.
