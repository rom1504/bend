import Base

def bump(xs: List<&2, U32>) -> List<&2, U32>:
  match xs:
    case Nil{}: Nil{}
    case Con{head, rest}:
      tail = bump(rest)
      Con{U32.inc(head), tail}

def total(xs: List<&2, U32>) -> U32:
  match xs:
    case Nil{}: 0
    case Con{head, rest}:
      subtotal = total(rest)
      U32.add(head, subtotal)

def main() -> IO(Unit):
  IO.print("list=" ++ U32.show(total(bump([1, 2, 3, 4]))))

#|list=14
