import Base

def increment(xs: List<&2, U32>) -> List<&2, U32>:
  match xs:
    case Nil{}: Nil{}
    case Con{head, tail}:
      rest = increment(tail)
      Con{U32.add(head, 1), rest}

def weighted(xs: List<&2, U32>, +weight: U32) -> U32:
  match xs:
    case Nil{}: 0
    case Con{head, tail}:
      subtotal = weighted(tail, U32.add(weight, 1))
      U32.add(U32.mul(head, weight), subtotal)

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(U32.show(weighted(increment([]), 1)))
    Unit <- IO.print(U32.show(weighted(increment([4294967295]), 1)))
    IO.print(U32.show(weighted(increment([1, 4, 2, 8]), 1)))

#|0
#|0
#|57
