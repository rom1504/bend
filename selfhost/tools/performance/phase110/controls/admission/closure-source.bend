# Synthetic typed-entry closure witnesses; no actual compiler-hotness claim.
import Base

@unsafe
def p110_close_leaf(xs: List<&2,String>) -> List<&2,String>:
  xs

@unsafe
def p110_close_mid(xs: List<&2,String>) -> List<&2,String>:
  p110_close_leaf(xs)

@unsafe
def p110_close_chain(xs: List<&2,String>) -> List<&2,String>:
  p110_close_mid(xs)

@unsafe
def p110_close_string_leaf(s: String) -> String:
  s

@unsafe
def p110_close_string_mid(s: String) -> String:
  p110_close_string_leaf(s)

@unsafe
def p110_close_string(s: String) -> String:
  p110_close_string_mid(s)

@unsafe
def p110_close_mixed(h: String, xs: List<&2,String>) -> List<&2,String>:
  Con{p110_close_string_leaf(h), p110_close_mid(xs)}

@unsafe
def p110_close_choose(xs: List<&2,String>, ys: List<&2,String>) -> List<&2,String>:
  ys

@unsafe
def p110_close_diamond(xs: List<&2,String>, ys: List<&2,String>) -> List<&2,String>:
  p110_close_choose(p110_close_mid(xs), p110_close_leaf(ys))

# Exact generic compiler dependency; the wrapper alone is monomorphic.
@unsafe
def nt_reverse(-A: Data, xs: List<&2, A>, acc: List<&2, A>) -> List<&2, A>:
  match xs:
    case Nil{}: acc
    case Con{h, t}: nt_reverse(A, t, Con{h, acc})

@unsafe
def p110_close_generic(xs: List<&2,String>, ys: List<&2,String>) -> List<&2,String>:
  nt_reverse(String, xs, ys)

# A second negative has a canonical root and an unsupported private Char
# dependency, without relying on erased polymorphism as the refusal reason.
@unsafe
def p110_close_char_identity(c: Char) -> Char:
  c

@unsafe
def p110_close_unsupported_callee(s: String) -> String:
  match s:
    case SNil{}: SNil{}
    case SCon{h,t}: SCon{p110_close_char_identity(h),t}

@unsafe
def p110_close_join(xs: List<&2,String>) -> String:
  match xs:
    case Nil{}: ""
    case Con{h, Nil{}}: h
    case Con{h, t}: h ++ "|" ++ p110_close_join(t)

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(p110_close_join(p110_close_chain(["a", "b"])))
    Unit <- IO.print(p110_close_string("λ🙂"))
    Unit <- IO.print(p110_close_join(p110_close_mixed("h", ["a", "b"])))
    Unit <- IO.print(p110_close_join(p110_close_diamond(["discard"], ["z"])))
    Unit <- IO.print(p110_close_join(p110_close_generic(["a", "b"], ["z"])))
    IO.print(p110_close_unsupported_callee("az"))

#|a|b
#|λ🙂
#|h|a|b
#|z
#|b|a|z
#|az
