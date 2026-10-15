import Base

# The sum of the two string lengths decreases, but root identities swap.
# This is valid owning code and must be declined by the borrowed-tail analysis.
@unsafe
def p98_origin_swap(a: String, b: String) -> Bool:
  match a:
    case SNil{}: True{}
    case SCon{head, tail}: p98_origin_swap(b, tail)

@unsafe
def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print_err("observer-origin")
    IO.print(U32.show(Bool.to_u32(p98_origin_swap("ab", "xyz"))))

#|1
