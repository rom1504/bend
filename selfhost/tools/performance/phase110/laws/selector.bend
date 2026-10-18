import Base
import ./candidate.bend as H

# Complete results, universally quantified over the payload type and values.
# The Boolean premise is the checked lowering's keep == first-field decision.
law select_first_complete:
  for -A: Data
  for a: A
  for b: A
  {H.nxo_law_select(A, True{}, a, b) == H.NxoLawSelection{0, a, b} : H.NxoLawSelection<A>}

def select_first_complete(A, a, b): {==}

law select_second_complete:
  for -A: Data
  for a: A
  for b: A
  {H.nxo_law_select(A, False{}, a, b) == H.NxoLawSelection{1, b, a} : H.NxoLawSelection<A>}

def select_second_complete(A, a, b): {==}

law reuse_unique_dynamic:
  {H.nxo_law_reuse(H.NxoLawUniqueDynamic{}) == True{} : Bool}

def reuse_unique_dynamic(): {==}

law allocate_shared_dynamic:
  {H.nxo_law_reuse(H.NxoLawSharedDynamic{}) == False{} : Bool}

def allocate_shared_dynamic(): {==}

law allocate_static:
  {H.nxo_law_reuse(H.NxoLawStatic{}) == False{} : Bool}

def allocate_static(): {==}

#|ALL PROOFS CHECK
#|Use --verdict for mathematical validity.
