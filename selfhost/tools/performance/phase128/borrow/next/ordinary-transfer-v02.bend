import Base

# Different payload type and a renamed generic user ADT exercise the semantic
# layout/cursor capability independently from string-name membership.
type P128Spine<-A: Data> is Data:
  P128Stop{}
  P128Link{head: A, tail: P128Spine<A>}

def p128x_count(words: List<&2,U32>, count: U32) -> U32:
  match words:
    case Nil{}: count
    case Con{head,tail}: p128x_count(tail,U32.inc(count))

def p128x_sum(spine: P128Spine<U32>, sum: U32) -> U32:
  match spine:
    case P128Stop{}: sum
    case P128Link{head,tail}: p128x_sum(tail,U32.add(sum,head))

# Both List instantiations occur as owning roots in one schema. Its observer
# must refuse rather than treating owner-name equality as type equality.
def p128x_conflicting(words: List<&2,U32>, strings: List<&2,String>) -> Bool:
  True{}

# Keep polymorphic constructors under a function's explicit result type. The
# frontend does not always propagate a local binding annotation into nested
# constructor inference; this also localizes any future source diagnostic.
def p128x_words() -> List<&2,U32>:
  [3,5,7]

def p128x_spine() -> P128Spine<U32>:
  P128Link{3,P128Link{5,P128Stop{}}}

def p128x_strings() -> List<&2,String>:
  ["α","β"]

def main() -> IO(Unit):
  +words = p128x_words()
  +spine = p128x_spine()
  do IO<Unit>:
    Unit <- IO.print(U32.show(p128x_count(words,0)))
    Unit <- IO.print(U32.show(p128x_count(words,10)))
    Unit <- IO.print(U32.show(p128x_sum(spine,1)))
    Unit <- IO.print(U32.show(p128x_sum(spine,0)))
    IO.print(U32.show(Bool.to_u32(p128x_conflicting(words,p128x_strings()))))

#|3
#|13
#|9
#|8
#|1
