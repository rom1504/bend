import Base

# Different payload type and a renamed generic user ADT exercise the semantic
# layout/cursor capability independently from string-name membership.
type P128Spine<-A: Data> is Data:
  P128Stop{}
  P128Link{head: A, tail: P128Spine<A>}

def p128x_count(words: List<U32>, count: U32) -> U32:
  match words:
    case Nil{}: count
    case Con{head,tail}: p128x_count(tail,U32.inc(count))

def p128x_sum(spine: P128Spine<U32>, sum: U32) -> U32:
  match spine:
    case P128Stop{}: sum
    case P128Link{head,tail}: p128x_sum(tail,U32.add(sum,head))

# Both List instantiations occur as owning roots in one schema. Its observer
# must refuse rather than treating owner-name equality as type equality.
def p128x_conflicting(words: List<U32>, strings: List<String>) -> Bool:
  True{}

def main() -> IO(Unit):
  +words : List<U32> = [3,5,7]
  +spine : P128Spine<U32> = P128Link{3,P128Link{5,P128Stop{}}}
  do IO<Unit>:
    Unit <- IO.print(U32.show(p128x_count(words,0)))
    Unit <- IO.print(U32.show(p128x_count(words,10)))
    Unit <- IO.print(U32.show(p128x_sum(spine,1)))
    Unit <- IO.print(U32.show(p128x_sum(spine,0)))
    IO.print(U32.show(Bool.to_u32(p128x_conflicting(words,["α","β"]))))

#|3
#|13
#|9
#|8
#|1
