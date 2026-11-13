import Base

type RecurTree is Data:
  RecurLeaf{value: U32}
  RecurNode{left: RecurTree, right: RecurTree}

def recur.tree.make(+n: Nat, +seed: U32) -> RecurTree:
  match n:
    case 0n: RecurLeaf{seed}
    case 1n+p:
      RecurNode{recur.tree.make(p, U32.add(seed, 3)), recur.tree.make(p, U32.add(seed, 11))}

# The right subtree is owned by the first continuation; its result and the
# first result are then combined in another continuation of the same owner.
def recur.tree.eval(tree: RecurTree) -> U32:
  match tree:
    case RecurLeaf{value}: value
    case RecurNode{left, right}:
      U32.xor(U32.mul(recur.tree.eval(left), 3), U32.add(recur.tree.eval(right), 7))

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(U32.show(recur.tree.eval(recur.tree.make(0n, 13))))
    Unit <- IO.print(U32.show(recur.tree.eval(recur.tree.make(3n, 13))))
    IO.print(U32.show(recur.tree.eval(recur.tree.make(8n, 4294967281))))
#| 13
#| 723
#| 18755
