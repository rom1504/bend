import Base

type Value is Data:
  LeafA{value: U32}
  LeafB{value: U32}

def number(value: Value) -> U32:
  match value:
    case LeafA{x}: x
    case LeafB{x}: U32.add(x, 100)

def sum_list(values: List<&2, Value>) -> U32:
  match values:
    case Nil{}: 0
    case Con{head, tail}: U32.add(number(head), sum_list(tail))

type Tree is Data:
  Tip{value: Value}
  Fork{left: Tree, right: Tree}

def total(tree: Tree) -> U32:
  match tree:
    case Tip{value}: number(value)
    case Fork{left, right}: U32.add(total(left), total(right))

def grow(n: Nat, tree: Tree) -> Tree:
  match n:
    case 0n: tree
    case 1n+p:
      +child = grow(p, tree)
      Fork{child, child}

def shared(+tree: Tree) -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(U32.show(total(tree)))
    IO.print(U32.show(total(tree)))

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(U32.show(sum_list([])))
    Unit <- IO.print(U32.show(sum_list([LeafA{0}, LeafB{1}, LeafA{4294967295}, LeafB{2}])))
    Unit <- IO.print(U32.show(total(Fork{Tip{LeafA{7}}, Fork{Tip{LeafB{2}}, Tip{LeafA{4294967295}}}})))
    shared(grow(7n, Tip{LeafB{3}}))

#|0
#|202
#|108
#|13184
#|13184
