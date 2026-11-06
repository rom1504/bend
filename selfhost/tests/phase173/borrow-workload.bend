import Base

# Ordinary source-program oracle and loop workload. No custom runtime probes.
# Complete record-return helpers plus a recursive persistent tree consumer.
# The optimizer must recognize structure, not these names or fixture constants.

type BorrowRecord is Data:
  BorrowRecord{+name: String, +begin: U32, +end: U32,
    +children: List<&2,U32>, +padding: List<&2,U32>}

type BorrowTree is Data:
  BorrowLeaf{+value: U32}
  BorrowBranch{+left: BorrowTree, +right: BorrowTree, +weight: U32, +label: String}

@unsafe
def p173w_list(n: Nat, +value: U32) -> List<&2,U32>:
  match n:
    case 0n: []
    case 1n+p: Con{value,p173w_list(p,U32.inc(value))}

@unsafe
def p173w_sum(values: List<&2,U32>) -> U32:
  match values:
    case Nil{}: 0
    case Con{value,rest}: U32.add(value,p173w_sum(rest))

def p173w_make() -> BorrowRecord:
  BorrowRecord{U32.show(7),0,0,p173w_list(7n,1),[7,8]}

def p173w_span(record: BorrowRecord, begin: U32, end: U32) -> BorrowRecord:
  match record:
    case BorrowRecord{name,oldBegin,oldEnd,children,padding}:
      BorrowRecord{name,begin,end,children,padding}

def p173w_children(record: BorrowRecord, children: List<&2,U32>) -> BorrowRecord:
  match record:
    case BorrowRecord{name,begin,end,oldChildren,padding}:
      BorrowRecord{name,begin,end,children,padding}

def p173w_get_children(record: BorrowRecord) -> List<&2,U32>:
  match record:
    case BorrowRecord{name,begin,end,children,padding}: children

def p173w_score(record: BorrowRecord) -> U32:
  match record:
    case BorrowRecord{name,begin,end,children,padding}:
      U32.add(U32.from_nat(String.length(name)),U32.add(begin,
        U32.add(end,U32.add(p173w_sum(children),p173w_sum(padding)))))

@unsafe
def p173w_spans(n: Nat, record: BorrowRecord, +value: U32) -> BorrowRecord:
  match n:
    case 0n: record
    case 1n+p: p173w_spans(p,p173w_span(record,value,U32.inc(value)),U32.inc(value))

def p173w_unique() -> U32:
  p173w_score(p173w_spans(100000n,p173w_make(),1))

def p173w_shared() -> U32:
  +record = p173w_make()
  U32.add(p173w_score(p173w_span(record,11,12)),p173w_score(record))

def p173w_static() -> U32:
  p173w_score(p173w_span(BorrowRecord{"static",3,4,[1,2],[]},5,6))

def p173w_unique_rfc() -> U32:
  +record = p173w_make()
  +observed = p173w_score(record)
  U32.add(observed,p173w_score(p173w_span(record,observed,U32.inc(observed))))

def p173w_same_child() -> U32:
  +children = p173w_list(7n,1)
  record : BorrowRecord = BorrowRecord{"alias",1,2,children,[7,8]}
  p173w_score(p173w_children(record,children))

def p173w_new_child() -> U32:
  p173w_score(p173w_children(p173w_make(),p173w_list(10n,1)))

def p173w_static_child() -> U32:
  p173w_score(p173w_children(p173w_make(),[1,2,3]))

def p173w_shared_child() -> U32:
  +record = p173w_make()
  children = p173w_get_children(record)
  U32.add(p173w_score(p173w_children(record,children)),p173w_score(record))

@unsafe
def p173w_tree(n: Nat, +depth: U32) -> BorrowTree:
  match n:
    case 0n: BorrowLeaf{0}
    case 1n+p: BorrowBranch{p173w_tree(p,U32.sub(depth,1)),BorrowLeaf{depth},depth,"branch"}

def p173w_left(+tree: BorrowTree, left: BorrowTree) -> BorrowTree:
  match tree:
    case BorrowLeaf{value}: tree
    case BorrowBranch{oldLeft,right,weight,label}: BorrowBranch{left,right,weight,label}

@unsafe
def p173w_change(+tree: BorrowTree) -> BorrowTree:
  match tree:
    case BorrowLeaf{value}: BorrowLeaf{U32.inc(value)}
    case BorrowBranch{left,right,weight,label}: p173w_left(tree,p173w_change(left))

@unsafe
def p173w_tree_score(tree: BorrowTree) -> U32:
  match tree:
    case BorrowLeaf{value}: value
    case BorrowBranch{left,right,weight,label}:
      U32.add(p173w_tree_score(left),U32.add(p173w_tree_score(right),
        U32.add(weight,U32.from_nat(String.length(label)))))

@unsafe
def p173w_changes(n: Nat, tree: BorrowTree) -> BorrowTree:
  match n:
    case 0n: tree
    case 1n+p: p173w_changes(p,p173w_change(tree))

def p173w_recursive() -> U32:
  p173w_tree_score(p173w_changes(10000n,p173w_tree(4n,4)))

def main() -> List<&2,U32>:
  [p173w_unique(),p173w_shared(),p173w_static(),p173w_unique_rfc(),
    p173w_same_child(),p173w_new_child(),p173w_static_child(),p173w_shared_child(),p173w_recursive()]
