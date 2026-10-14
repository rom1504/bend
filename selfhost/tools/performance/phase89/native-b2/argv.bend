# Observe the exact list, without assuming that the program name is present.
import Base

def p89_args(xs: List<&1, String>, +index: U32) -> IO(Unit):
  match xs:
    case Nil{}: IO.print("END")
    case Con{head, tail}:
      do IO<Unit>:
        Unit <- IO.print("arg[" ++ U32.show(index) ++ "]=" ++ head)
        p89_args(tail, U32.inc(index))

def main() -> IO(Unit):
  do IO<Unit>:
    args : List<&1, String> <- IO.args()
    p89_args(args, 0)
