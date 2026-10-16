import Base

# Preserve the input roots across each reconstruction and consume the complete
# reconstructed value through a character sum. IO arguments keep inputs dynamic.
def p99_sum(text: String) -> U32:
  match text:
    case SNil{}: 0
    case SCon{head, tail}: U32.add(Char.to_u32(head), p99_sum(tail))

def p99_append_repeat(left: Nat, +a: String, +b: String, total: U32) -> U32:
  match left:
    case 0n: total
    case 1n+rest:
      p99_append_repeat(rest, a, b, U32.add(total, p99_sum(String.append(a, b))))

def p99_append_inputs(args: List<&1, String>) -> IO(Unit):
  match args:
    case Con{+a, Con{+b, rest}}:
      do IO<Unit>:
        Unit <- IO.print_err("phase99-append")
        Unit <- IO.print(U32.show(p99_append_repeat(1000000n, a, b, 0)))
        Unit <- IO.print(a)
        IO.print(b)
    case _: IO.print("missing input")

def main() -> IO(Unit):
  do IO<Unit>:
    args : List<&1, String> <- IO.args()
    p99_append_inputs(args)
