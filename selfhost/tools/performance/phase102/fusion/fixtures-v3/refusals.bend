import Base

type LeftTree is Data:
  Leaf{}
  Left{+child: LeftTree, +value: U32}
  Fork{+left: LeftTree, +right: LeftTree}

# Nonfinal recursive field must retain ordinary lowering.
def nonfinal(n: Nat) -> LeftTree:
  match n:
    case 0n: Leaf{}
    case 1n+rest: Left{nonfinal(rest), 1}

# Two recursive occurrences must retain ordinary lowering.
def branching(n: Nat) -> LeftTree:
  match n:
    case 0n: Leaf{}
    case Succ{+rest}: Fork{branching(rest), branching(rest)}

def tree_sum(xs: LeftTree) -> U32:
  match xs:
    case Leaf{}: 1
    case Left{child, value}: U32.add(tree_sum(child), value)
    case Fork{left, right}: U32.add(tree_sum(left), tree_sum(right))

# The recursive SCC remains outside the direct-self TRMC admission.
def mutual_a(n: Nat) -> String:
  match n:
    case 0n: ""
    case 1n+rest: SCon{Char.from_u32(97), mutual_b(rest)}

def mutual_b(n: Nat) -> String:
  match n:
    case 0n: ""
    case 1n+rest: SCon{Char.from_u32(98), mutual_a(rest)}

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(U32.show(tree_sum(nonfinal(12n))))
    Unit <- IO.print(U32.show(tree_sum(branching(8n))))
    IO.print(mutual_a(6n))

#|13
#|256
#|ababab
