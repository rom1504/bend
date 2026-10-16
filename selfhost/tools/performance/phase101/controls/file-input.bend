import Base

def p101_codes(text: String) -> String:
  match text:
    case SNil{}: ""
    case SCon{head, tail}: U32.show(Char.to_u32(head)) ++ "," ++ p101_codes(tail)

# Runtime input may span several compact chunks. Both roots remain live while
# appending each overlapping suffix in both orders, then are observed again.
def p101_overlap(+text: String, +offset: Nat) -> IO(Unit):
  +tail : String = String.drop(text, offset)
  do IO<Unit>:
    IO.print("forward-" ++ Nat.show(offset) ++ "\t" ++ p101_codes(text ++ tail))
    IO.print("backward-" ++ Nat.show(offset) ++ "\t" ++ p101_codes(tail ++ text))
    IO.print("root-" ++ Nat.show(offset) ++ "\t" ++ p101_codes(text))
    IO.print("tail-" ++ Nat.show(offset) ++ "\t" ++ p101_codes(tail))

def p101_result(result: Result<&1, &1, U32 & String, String>) -> IO(Unit):
  match result:
    case Fail{error}: IO.print("error\tread")
    case Done{+text}:
      do IO<Unit>:
        IO.print(Nat.show(String.length(text)) ++ "\t" ++ p101_codes(text))
        IO.print(String.reverse(text))
        IO.print(text)
        p101_overlap(text, 60n)
        p101_overlap(text, 61n)
        p101_overlap(text, 62n)

def p101_read_done(pair: File & Result<&1, &1, U32 & String, String>) -> IO(Unit):
  (file, result) = pair
  do IO<Unit>:
    Unit <- File.close(file)
    p101_result(result)

def p101_open_done(result: Result<&1, &1, U32 & String, File>) -> IO(Unit):
  match result:
    case Fail{error}: IO.print("error\topen")
    case Done{file}:
      do IO<Unit>:
        pair : File & Result<&1, &1, U32 & String, String> <- File.read(file, 4096)
        p101_read_done(pair)

def p101_open(path: String) -> IO(Unit):
  do IO<Unit>:
    result : Result<&1, &1, U32 & String, File> <- File.open(path, "r")
    p101_open_done(result)

def p101_args(args: List<&1, String>, found: Bool) -> IO(Unit):
  match args found:
    case Nil{} other: IO.print("usage: --file PATH")
    case Con{path, rest} True{}: p101_open(path)
    case Con{arg, rest} False{}: p101_args(rest, String.eq(arg, "--file"))

def main() -> IO(Unit):
  do IO<Unit>:
    args : List<&1, String> <- IO.args()
    p101_args(args, False{})
