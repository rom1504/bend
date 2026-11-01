import Base

type Tree is Data:
  Leaf{value: U32}
  Branch{left: Tree, right: Tree}

def total(t: Tree) -> U32:
  match t:
    case Leaf{x}:
      x
    case Branch{l, r}:
      a b = total(l) total(r)
      (a + b : U32)

def main() -> IO(Unit):
  tree = {Branch{Leaf{20}, Branch{Leaf{15}, Leaf{7}}} : Tree}
  IO.print(U32.show(total(tree)))
