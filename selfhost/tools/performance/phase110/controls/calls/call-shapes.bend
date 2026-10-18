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

@unsafe
def p110_call_identity(xs: List<&2,String>) -> List<&2,String>:
  xs

@unsafe
def p110_call_inside_constructor(h: String, xs: List<&2,String>) -> List<&2,String>:
  Con{h, p110_call_identity(xs)}

@unsafe
def p110_call_twice(+xs: List<&2,String>, ys: List<&2,String>) -> List<&2,String>:
  nt_append(String, p110_call_identity(xs), nt_append(String, xs, ys))

@unsafe
def p110_call_discard(xs: List<&2,String>, ys: List<&2,String>) -> List<&2,String>:
  p110_call_identity(ys)

@unsafe
def p110_call_same(+xs: List<&2,String>) -> List<&2,String>:
  nt_append(String, xs, xs)

@unsafe
def p110_call_dynamic(f: List<&2,String> -> List<&2,String>, xs: List<&2,String>) -> List<&2,String>:
  f(xs)

@unsafe
def p110_call_partial(xs: List<&2,String>) -> List<&2,String> -> List<&2,String>:
  nt_append(String, xs)

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(p110_append_join(p110_call_identity(["a", "b"])))
    Unit <- IO.print(p110_append_join(p110_call_inside_constructor("h", ["a", "b"])))
    Unit <- IO.print(p110_append_join(p110_call_twice(["a", "b"], ["z"])))
    Unit <- IO.print(p110_append_join(p110_call_discard(["unused"], ["z"])))
    IO.print(p110_append_join(p110_call_same(["a", "b"])))

#|a|b
#|h|a|b
#|a|b|a|b|z
#|z
#|a|b|a|b
