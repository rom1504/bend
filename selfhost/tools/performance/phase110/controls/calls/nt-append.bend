# Compiler declarations below are exact slices, including @unsafe.
import Base

@unsafe
def nt_reverse(-A: Data, xs: List<&2, A>, acc: List<&2, A>) -> List<&2, A>:
  match xs:
    case Nil{}: acc
    case Con{h, t}: nt_reverse(A, t, Con{h, acc})

@unsafe
def nt_append(-A: Data, xs: List<&2, A>, ys: List<&2, A>) -> List<&2, A>:
  nt_reverse(A, nt_reverse(A, xs, Nil{}), ys)

@unsafe
def p110_append_join(xs: List<&2,String>) -> String:
  match xs:
    case Nil{}: ""
    case Con{h, Nil{}}: h
    case Con{h, rest}: h ++ "|" ++ p110_append_join(rest)

@unsafe
def p110_append_alias(+xs: List<&2,String>, +ys: List<&2,String>) -> String:
  p110_append_join(nt_append(String, xs, ys)) ++ "/" ++ p110_append_join(xs) ++ "/" ++ p110_append_join(ys)

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(p110_append_join(nt_append(String, [], [])))
    Unit <- IO.print(p110_append_join(nt_append(String, [], ["tail"])))
    Unit <- IO.print(p110_append_join(nt_append(String, ["a", "bc"], [])))
    Unit <- IO.print(p110_append_join(nt_append(String, ["", "λ🙂"], ["Ω"])))
    IO.print(p110_append_alias(["a", "b"], ["tail"]))

#|
#|tail
#|a|bc
#||λ🙂|Ω
#|a|b|tail/a|b/tail
