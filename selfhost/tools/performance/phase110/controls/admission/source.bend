# Source-only admission controls. Expected verdicts are frozen separately;
# these definitions are ordinary checked language examples, not lowerer code.
import Base

type P110Lookalike is Data:
  P110LookNil{}
  P110LookCon{head: String, tail: P110Lookalike}

def P110StringAlias() -> Data:
  String

@unsafe
def p110_cert_string_identity(x: String) -> String:
  x

@unsafe
def p110_cert_list_identity(xs: List<&2,String>) -> List<&2,String>:
  xs

@unsafe
def p110_cert_mixed_list(h: String, xs: List<&2,String>) -> List<&2,String>:
  xs

@unsafe
def p110_cert_mixed_string(xs: List<&2,String>, h: String) -> String:
  h

@unsafe
def p110_cert_list_u32(xs: List<&2,U32>) -> List<&2,U32>:
  xs

@unsafe
def p110_cert_nat(x: Nat) -> Nat:
  x

@unsafe
def p110_cert_u32(x: U32) -> U32:
  x

@unsafe
def p110_cert_lookalike(x: P110Lookalike) -> P110Lookalike:
  x

@unsafe
def p110_cert_alias(x: P110StringAlias()) -> P110StringAlias():
  x

@unsafe
def p110_cert_dependent(-A: Data, x: A) -> A:
  x

@unsafe
def p110_cert_higher_order(f: String -> String, x: String) -> String:
  f(x)

@unsafe
def p110_cert_function_result(xs: List<&2,String>) -> String -> List<&2,String>:
  h => xs

# Exact compiler declaration: this generic telescope is not a monomorphic
# List<String> certificate, even when a caller supplies erased String.
@unsafe
def nt_reverse(-A: Data, xs: List<&2, A>, acc: List<&2, A>) -> List<&2, A>:
  match xs:
    case Nil{}: acc
    case Con{h, t}: nt_reverse(A, t, Con{h, acc})

@unsafe
def p110_cert_closed_reverse(xs: List<&2,String>, acc: List<&2,String>) -> List<&2,String>:
  nt_reverse(String, xs, acc)

@unsafe
def p110_cert_join(xs: List<&2,String>) -> String:
  match xs:
    case Nil{}: ""
    case Con{h, Nil{}}: h
    case Con{h, t}: h ++ "|" ++ p110_cert_join(t)

@unsafe
def p110_cert_show_lookalike(x: P110Lookalike) -> String:
  match x:
    case P110LookNil{}: "nil"
    case P110LookCon{h, t}: h ++ p110_cert_show_lookalike(t)

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(p110_cert_string_identity("λ🙂"))
    Unit <- IO.print(p110_cert_join(p110_cert_list_identity(["a", "b"])))
    Unit <- IO.print(p110_cert_join(p110_cert_mixed_list("unused", ["m"])))
    Unit <- IO.print(p110_cert_mixed_string(["unused"], "s"))
    Unit <- IO.print(Nat.show(List.length(&2, U32, p110_cert_list_u32([7]))))
    Unit <- IO.print(Nat.show(p110_cert_nat(3n)))
    Unit <- IO.print(U32.show(p110_cert_u32(4)))
    Unit <- IO.print(p110_cert_show_lookalike(p110_cert_lookalike(P110LookCon{"x", P110LookNil{}})))
    Unit <- IO.print(p110_cert_alias("alias"))
    Unit <- IO.print(p110_cert_dependent(String, "generic"))
    Unit <- IO.print(p110_cert_higher_order(p110_cert_string_identity, "call"))
    Unit <- IO.print(p110_cert_join(p110_cert_function_result(["partial"])("unused")))
    IO.print(p110_cert_join(p110_cert_closed_reverse(["a", "b"], ["z"])))

#|λ🙂
#|a|b
#|m
#|s
#|1
#|3
#|4
#|xnil
#|alias
#|generic
#|call
#|partial
#|b|a|z
