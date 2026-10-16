import Base

def observer_order(cmp: Cmp) -> String:
  match cmp:
    case LT{}: "lt"
    case EQ{}: "eq"
    case GT{}: "gt"

def observer_result(pair: (String & String) & Cmp) -> IO(Unit):
  ((left, right), cmp) = pair
  do IO<Unit>:
    IO.print(left)
    IO.print(right)
    IO.print(observer_order(cmp))

def observer_shared(+left: String, +right: String) -> IO(Unit):
  result = String.cmp(left, right)
  do IO<Unit>:
    observer_result(result)
    IO.print(left)
    IO.print(right)

# Dynamic roots arrive from IO.args. First compare retains aliases; the last
# compare consumes its roots, then observes the exact returned root contents.
def observer_run(+left: String, +right: String) -> IO(Unit):
  equal = String.eq(left, right)
  do IO<Unit>:
    IO.print(U32.show(Bool.to_u32(equal)))
    observer_shared(left, right)
    observer_result(String.cmp(left, right))

def observer_right(args: List<&1, String>, left: String) -> IO(Unit):
  match args:
    case Con{right, rest}: observer_run(left, right)
    case Nil{}: observer_run(left, "")

def observer_args(args: List<&1, String>) -> IO(Unit):
  match args:
    case Con{left, rest}: observer_right(rest, left)
    case Nil{}: observer_run("", "")

def observer_find(args: List<&1, String>, found: Bool) -> IO(Unit):
  match args found:
    case Nil{} _: observer_run("", "")
    case Con{word, rest} True{}: observer_right(rest, word)
    case Con{word, rest} False{}: observer_find(rest, String.eq(word, "--pair"))

def main() -> IO(Unit):
  do IO<Unit>:
    args : List<&1, String> <- IO.args()
    observer_find(args, False{})
