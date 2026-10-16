import Base

type TypedPair is Data:
  TypedPair{left: String, right: String}

def typed_left(pair: TypedPair) -> String:
  match pair:
    case TypedPair{left, right}: left

def typed_right(pair: TypedPair) -> String:
  match pair:
    case TypedPair{left, right}: right

def typed_positions(left: U32, right: U32) -> U32:
  U32.add(U32.mul(left, 1000), right)

def typed_apply(call: U32 -> U32, value: U32) -> U32:
  call(value)

def typed_factory(left: U32) -> U32 -> U32:
  right => typed_positions(left, right)

# IO keeps this parent outside whole-function NF admission. Shared roots and
# escaped children are all observed after several local value-producing calls.
def typed_report(+text: String) -> IO(Unit):
  +pair = TypedPair{text ++ "|L", text ++ "|R"}
  +left = typed_left(pair)
  ignored = typed_right(pair)
  right = typed_right(pair)
  normal = typed_positions(17, 23)
  swapped = typed_positions(23, 17)
  wrapped = typed_positions(4294967295, 999)
  partial = typed_apply(typed_positions(5), 7)
  dynamic = typed_apply(typed_factory(9), 11)
  do IO<Unit>:
    IO.print(left)
    IO.print(right)
    IO.print(text)
    IO.print(left ++ ":" ++ typed_left(pair))
    IO.print(U32.show(normal) ++ "," ++ U32.show(swapped) ++ "," ++ U32.show(wrapped))
    IO.print(U32.show(partial) ++ "," ++ U32.show(dynamic))

def typed_args(args: List<&1, String>, found: Bool) -> IO(Unit):
  match args found:
    case Nil{} _: typed_report("")
    case Con{text, rest} True{}: typed_report(text)
    case Con{word, rest} False{}: typed_args(rest, String.eq(word, "--text"))

def main() -> IO(Unit):
  do IO<Unit>:
    args : List<&1, String> <- IO.args()
    typed_args(args, False{})
