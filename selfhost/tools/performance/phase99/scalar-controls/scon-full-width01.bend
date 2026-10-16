import Base

# Do not render these arbitrary U32 characters as UTF-8: observe every bit.
def p99_head(text: String) -> U32:
  match text:
    case SNil{}: 0
    case SCon{head, tail}: Char.to_u32(head)

def p99_second(text: String) -> U32:
  match text:
    case SNil{}: 0
    case SCon{head, tail}: p99_head(tail)

def main() -> IO(Unit):
  +source : String = SCon{Char.from_u32(4294967295), SCon{Char.from_u32(2147483648), "λ"}}
  +copy : String = String.append(source, "!")
  do IO<Unit>:
    IO.print_err("scalar-control")
    IO.print(U32.show(p99_head(copy)))
    IO.print(U32.show(p99_second(copy)))
    IO.print(U32.show(p99_head(source)))
    IO.print(U32.show(p99_second(source)))

#|4294967295
#|2147483648
#|4294967295
#|2147483648
