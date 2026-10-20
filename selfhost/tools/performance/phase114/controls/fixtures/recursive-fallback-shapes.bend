import Base

# Two recursive children remain an ordinary valid fallback case.
type Tree is Data:
  Leaf{value: U32}
  Node{left: Tree, right: Tree}

def copy_tree(tree: Tree) -> Tree:
  match tree:
    case Leaf{value}: Leaf{U32.add(value, 1)}
    case Node{left, right}: Node{copy_tree(left), copy_tree(right)}

def total(tree: Tree) -> U32:
  match tree:
    case Leaf{value}: value
    case Node{left, right}: U32.add(total(left), total(right))

# The recursive result occupies the first, not the final constructor field.
type Chain is Data:
  End{}
  Link{tail: Chain, text: String}

def copy_chain(chain: Chain) -> Chain:
  match chain:
    case End{}: End{}
    case Link{tail, text}: Link{copy_chain(tail), String.reverse(text)}

def show_chain(chain: Chain) -> String:
  match chain:
    case End{}: "end"
    case Link{tail, text}: text ++ ":" ++ show_chain(tail)

# The recursive result is projected after the call, rather than reconstructed.
def rest(items: List<String>) -> List<String>:
  match items:
    case Nil{}: []
    case Con{head, tail}: tail

def after(items: List<String>) -> List<String>:
  match items:
    case Nil{}: ["seed"]
    case Con{head, tail}: rest(after(tail))

def length(items: List<String>) -> Nat:
  match items:
    case Nil{}: 0n
    case Con{head, tail}: Nat.add(1n, length(tail))

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(U32.show(total(copy_tree(Node{Leaf{2}, Node{Leaf{7}, Leaf{4294967295}}}))))
    Unit <- IO.print(show_chain(copy_chain(Link{Link{End{}, "🙂β"}, "α"})))
    Unit <- IO.print(Nat.show(length(after([]))))
    IO.print(Nat.show(length(after(["a", "b", "c"]))))

#|11
#|α:β🙂:end
#|1
#|0
