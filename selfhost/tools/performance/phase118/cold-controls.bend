import Base

# Duplicating Outer must heat the nested list and user tree constructors even
# though no tree or list parameter is duplicated directly in the source.
type ColdTree is Data:
  ColdLeaf{text: String}
  ColdFork{left: ColdTree, right: ColdTree}

type ColdOuter is Data:
  ColdOuter{trees: List<&2, ColdTree>, label: String}

def tree_text(tree: ColdTree) -> String:
  match tree:
    case ColdLeaf{text}: "leaf(" ++ text ++ ")"
    case ColdFork{left, right}:
      "fork(" ++ tree_text(left) ++ "," ++ tree_text(right) ++ ")"

def trees_text(trees: List<&2, ColdTree>) -> String:
  match trees:
    case Nil{}: ""
    case Con{head, tail}: tree_text(head) ++ "," ++ trees_text(tail)

def outer_text(outer: ColdOuter) -> String:
  match outer:
    case ColdOuter{trees, label}: label ++ "[" ++ trees_text(trees) ++ "]"

def make_outer(first: String, second: String, third: String) -> ColdOuter:
  ColdOuter{[ColdLeaf{first}, ColdFork{ColdLeaf{second}, ColdLeaf{third}}], "outer"}

def observe_outer(+outer: ColdOuter) -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(outer_text(outer))
    IO.print(outer_text(outer))

# This parent itself is never duplicated. Its String field already has a
# retained external owner; omitting a new seal must preserve that shared word.
type ColdEnvelope is Data:
  ColdEnvelope{note: String, stamp: U32}

def envelope_text(envelope: ColdEnvelope) -> String:
  match envelope:
    case ColdEnvelope{note, stamp}: note ++ ":" ++ U32.show(stamp)

def observe_envelope(+note: String) -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(envelope_text(ColdEnvelope{note, 7}))
    IO.print(note)

# One constructor identity is instantiated at both scalar and owned types.
type ColdBox<-A: Data> is Data:
  ColdBox{value: A}

def number_box_text(box: ColdBox<U32>) -> String:
  match box:
    case ColdBox{value}: U32.show(value)

def string_box_text(box: ColdBox<String>) -> String:
  match box:
    case ColdBox{value}: value

def observe_boxes(+number: ColdBox<U32>, +text: ColdBox<String>) -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(number_box_text(number))
    Unit <- IO.print(string_box_text(text))
    Unit <- IO.print(number_box_text(number))
    IO.print(string_box_text(text))

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- observe_outer(make_outer(String.append("α", "one"), String.append("β", "two"), String.append("γ", "three")))
    Unit <- observe_envelope(String.append("δ", "shared"))
    observe_boxes(ColdBox{33}, ColdBox{String.append("ε", "box")})

#|outer[leaf(αone),fork(leaf(βtwo),leaf(γthree)),]
#|outer[leaf(αone),fork(leaf(βtwo),leaf(γthree)),]
#|δshared:7
#|δshared
#|33
#|εbox
#|33
#|εbox
