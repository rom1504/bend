import Base

type P112Tree is Data:
  P112Empty{}
  P112Leaf{word: U32}
  P112Fork{left: P112Tree, right: P112Tree}

def p112_static_score(tree: P112Tree) -> U32:
  match tree:
    case P112Empty{}: 0
    case P112Leaf{word}: word
    case P112Fork{left,right}: U32.add(p112_static_score(left),p112_static_score(right))

def p112_static_twice(+tree: P112Tree) -> U32:
  U32.add(p112_static_score(tree),p112_static_score(tree))

def p112_static_drop(tree: P112Tree) -> U32:
  17

def p112_static_dynamic(word: U32) -> P112Tree:
  P112Fork{P112Fork{P112Leaf{7},P112Leaf{11}},P112Leaf{word}}

def p112_static_text(+text: String) -> String:
  String.append(text,text)

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print("")
    Unit <- IO.print("α🍎中")
    Unit <- IO.print(p112_static_text("α🍎中"))
    Unit <- IO.print(U32.show(p112_static_score(P112Empty{})))
    Unit <- IO.print(U32.show(p112_static_score(P112Leaf{4294967295})))
    Unit <- IO.print(U32.show(p112_static_twice(P112Fork{P112Leaf{7},P112Leaf{11}})))
    Unit <- IO.print(U32.show(p112_static_drop(P112Fork{P112Leaf{7},P112Leaf{11}})))
    IO.print(U32.show(p112_static_score(p112_static_dynamic(21))))

#|
#|α🍎中
#|α🍎中α🍎中
#|0
#|4294967295
#|36
#|17
#|39
