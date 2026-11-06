import Base

# Ordinary valid two-child recursion; results and the shared original survive.
# Complete expected main value: [127, 8128, 8128, 127]. No benchmark-name gate.
type P171Tree is Data:
  P171Leaf{}
  P171Node{+left: P171Tree, +value: U32, +right: P171Tree}

def p171t_make(depth: Nat, +value: U32) -> P171Tree:
  match depth:
    case Zero{}: P171Leaf{}
    case Succ{+n}: P171Node{p171t_make(n,U32.mul(value,2)),value,p171t_make(n,U32.add(U32.mul(value,2),1))}

def p171t_count(tree: P171Tree) -> U32:
  match tree:
    case P171Leaf{}: 0
    case P171Node{left,value,right}: U32.inc(U32.add(p171t_count(left),p171t_count(right)))

def p171t_sum(tree: P171Tree) -> U32:
  match tree:
    case P171Leaf{}: 0
    case P171Node{left,value,right}: U32.add(value,U32.add(p171t_sum(left),p171t_sum(right)))

def main() -> List<&2,U32>:
  +tree = p171t_make(7n,1)
  [p171t_count(tree),p171t_sum(tree),p171t_sum(tree),p171t_count(tree)]
