# Shared by the actual Phase110 lowering and its safe semantic package.
# A selection transfers both inputs exactly once; it cannot discard a child.
type NxoLawSelection<-A: Data> is Data:
  NxoLawSelection{index: U32, retained: A, remaining: A}

def nxo_law_select(-A: Data, keep_first: Bool, a: A, b: A) -> NxoLawSelection<A>:
  match keep_first:
    case True{}: NxoLawSelection{0, a, b}
    case False{}: NxoLawSelection{1, b, a}

# This abstract classification is an explicit premise, not a claim that Bend
# has proved the C heap-address/refcount classification. Shared means at least
# one parent owner remains after consuming the current owner. Static is immortal.
type NxoLawStorage is Data:
  NxoLawUniqueDynamic{}
  NxoLawSharedDynamic{}
  NxoLawStatic{}

def nxo_law_reuse(storage: NxoLawStorage) -> Bool:
  match storage:
    case NxoLawUniqueDynamic{}: True{}
    case NxoLawSharedDynamic{}: False{}
    case NxoLawStatic{}: False{}
