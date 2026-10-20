import Base

# The head is discarded before recursion. Only the returned scalar is needed
# by the continuation; the increment must occur after the recursive call.
def length(items: List<&2, String>) -> U32:
  match items:
    case Nil{}: 0
    case Con{head, tail}: U32.inc(length(tail))

def repeat(n: Nat, +text: String) -> List<&2, String>:
  match n:
    case 0n: []
    case 1n+p: Con{text, repeat(p, text)}

def shared(+items: List<&2, String>) -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(U32.show(length(items)))
    IO.print(U32.show(length(items)))

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(U32.show(length([])))
    Unit <- IO.print(U32.show(length(["oneλ"])))
    Unit <- shared([String.reverse("α"), "", String.reverse("🙂β"), "last"])
    IO.print(U32.show(length(repeat(257n, String.reverse("🙂β")))))

#|0
#|1
#|4
#|4
#|257
