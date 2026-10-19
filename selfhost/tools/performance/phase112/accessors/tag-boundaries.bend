# Constructor discrimination with zero, one and two fields, plus retained alias.
import Base

type P112Mark is Data:
  Mark0{}
  Mark1{word: U32}
  Mark2{left: U32, right: U32}

def p112_mark_score(mark: P112Mark) -> U32:
  match mark:
    case Mark0{}: 7
    case Mark1{word}: word
    case Mark2{left, right}: U32.sub(left, right)

def p112_mark_twice(+mark: P112Mark) -> U32:
  U32.add(p112_mark_score(mark), p112_mark_score(mark))

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(U32.show(p112_mark_score(Mark0{})))
    Unit <- IO.print(U32.show(p112_mark_score(Mark1{4294967295})))
    Unit <- IO.print(U32.show(p112_mark_score(Mark2{0, 1})))
    IO.print(U32.show(p112_mark_twice(Mark2{2147483648, 1})))

#|7
#|4294967295
#|4294967295
#|4294967294
