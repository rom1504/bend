# Independent ordinary source: binary search, numeric pivots, stored text.
type ODTree is Data:
  ODVacant{}
  ODLeaf{key: U32, text: String}
  ODBranch{pivot: U32, left: ODTree, right: ODTree}

def od_left(pivot: U32, right: ODTree, result: ODTree & Maybe<&2,String>) -> ODTree & Maybe<&2,String>:
  (left, found) = result
  (ODBranch{pivot,left,right},found)

def od_right(pivot: U32, left: ODTree, result: ODTree & Maybe<&2,String>) -> ODTree & Maybe<&2,String>:
  (right, found) = result
  (ODBranch{pivot,left,right},found)

law od_find:
  for tree: ODTree
  for +key: U32
  ODTree & Maybe<&2,String>

def od_leaf(stored: U32, +text: String, equal: Bool) -> ODTree & Maybe<&2,String>:
  match equal:
    case True{}: (ODLeaf{stored,text},Some{text})
    case False{}: (ODLeaf{stored,text},None{})

def od_branch(pivot: U32, left: ODTree, right: ODTree, key: U32, smaller: Bool) -> ODTree & Maybe<&2,String>:
  match smaller:
    case True{}: od_left(pivot,right,od_find(left,key))
    case False{}: od_right(pivot,left,od_find(right,key))

def od_find(tree,key):
  match tree:
    case ODVacant{}: (ODVacant{},None{})
    case ODLeaf{+stored,+text}: od_leaf(stored,text,U32.is_eq(stored,key))
    case ODBranch{+pivot,left,right}: od_branch(pivot,left,right,key,U32.is_lt(key,pivot))

# A changed root must not receive a retained-root certificate.
def od_mutate(tree: ODTree, key: U32) -> ODTree & Maybe<&2,String>:
  match tree:
    case ODVacant{}: (ODVacant{},None{})
    case ODLeaf{stored,+text}: (ODLeaf{U32.add(stored,1),text},Some{text})
    case ODBranch{+pivot,left,right}: od_left(pivot,right,od_find(left,key))

# A fresh non-descendant escape is outside the optional borrowed-field contract.
def od_fresh(tree: ODTree, key: U32) -> ODTree & Maybe<&2,String>:
  (tree,Some{"fresh"})

def od_discard(tree: ODTree, key: U32) -> ODTree & Maybe<&2,String>:
  match tree:
    case ODVacant{}: (ODVacant{},None{})
    case ODLeaf{stored,+text}: (ODLeaf{stored,text},Some{text})
    case ODBranch{pivot,left,right}: od_discard_result(pivot,right,od_discard(left,key))

def od_discard_result(pivot: U32, right: ODTree, result: ODTree & Maybe<&2,String>) -> ODTree & Maybe<&2,String>:
  match result:
    case Tuple{left,found}: (ODBranch{pivot,left,right},None{})

def od_observe(result: ODTree & Maybe<&2,String>) -> U32:
  match result:
    case Tuple{tree,found}:
      match found:
        case None{}: 0
        case Some{text}: 1

def main() -> U32:
  od_observe(od_find(ODBranch{8,ODLeaf{3,"left"},ODLeaf{11,"right"}},3))
