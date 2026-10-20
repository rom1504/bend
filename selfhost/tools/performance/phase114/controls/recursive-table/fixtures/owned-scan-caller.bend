import Base

type Tree is Data:
  Empty{}
  Text{value: String}
  Branch{left: Tree, right: Tree}

# The second alternative keeps this an owned result rather than a one-record
# product. The ordinary EmptyResult behavior is also observed by main.
type ScanResult is Data:
  EmptyResult{}
  Scanned{tree: Tree, count: U32}

def combine(left: ScanResult, right: ScanResult) -> ScanResult:
  match left:
    case EmptyResult{}: right
    case Scanned{left_tree, left_count}:
      match right:
        case EmptyResult{}: Scanned{left_tree, left_count}
        case Scanned{right_tree, right_count}:
          Scanned{Branch{left_tree, right_tree}, U32.add(left_count, right_count)}

# Both recursive children return owning results. The first result must survive
# a continuation that starts the second same-owner recursive descent.
def scan(tree: Tree) -> ScanResult:
  match tree:
    case Empty{}: Scanned{Empty{}, 0}
    case Text{value}: Scanned{Text{value}, 1}
    case Branch{left, right}: combine(scan(left), scan(right))

def show_tree(tree: Tree) -> String:
  match tree:
    case Empty{}: "."
    case Text{value}: value
    case Branch{left, right}: "(" ++ show_tree(left) ++ "," ++ show_tree(right) ++ ")"

def show_result(result: ScanResult) -> String:
  match result:
    case EmptyResult{}: "empty-result"
    case Scanned{tree, count}: show_tree(tree) ++ "#" ++ U32.show(count)

# label is an owning caller capture outside the recursive region. The result
# is used after scan returns and label is used on both sides of its rendering.
def decorate(+label: String, tree: Tree) -> String:
  result = scan(tree)
  label ++ "[" ++ show_result(result) ++ "]" ++ label

def count_result(label: String, result: ScanResult) -> String:
  match result:
    case EmptyResult{}: label ++ ":none"
    case Scanned{tree, count}: label ++ ":" ++ U32.show(count)

def summary(label: String, tree: Tree) -> String:
  result = scan(tree)
  count_result(label, result)

def grow(n: Nat, tree: Tree) -> Tree:
  match n:
    case 0n: tree
    case 1n+p:
      +child = grow(p, tree)
      Branch{child, child}

def shared(+label: String, +tree: Tree) -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(decorate(label, tree))
    Unit <- IO.print(label)
    Unit <- IO.print(show_tree(tree))
    IO.print(decorate(label, tree))

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(decorate("empty", Empty{}))
    Unit <- IO.print(decorate("outer", Text{"λ"}))
    Unit <- IO.print(decorate("pre", Branch{Text{"α"}, Branch{Empty{}, Text{"β🙂"}}}))
    Unit <- shared(String.reverse("λyek"), Branch{Text{String.reverse("tfel")}, Text{String.reverse("🙂β")}})
    Unit <- IO.print(summary(String.reverse("htped"), grow(6n, Text{String.reverse("x")})))
    IO.print(show_result(EmptyResult{}))

#|empty[.#0]empty
#|outer[λ#1]outer
#|pre[(α,(.,β🙂))#2]pre
#|keyλ[(left,β🙂)#2]keyλ
#|keyλ
#|(left,β🙂)
#|keyλ[(left,β🙂)#2]keyλ
#|depth:64
#|empty-result
