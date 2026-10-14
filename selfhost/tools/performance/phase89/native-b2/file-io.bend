# Phase89 entry-shaped file IO falsifier. The reader/writer helpers below are
# exact Phase88 entry source with p86_ renamed to p89_; kc is copied unchanged.
# This is a fixture, not a host or broader effect permission.
import Base

@unsafe
def kc(
  -A: Type,
  +b: Bool,
  yes: Unit -> A,
  no: Unit -> A,
) -> A:
  match b:
    case True{}:
      yes(Unit{})
    case False{}:
      no(Unit{})

# Sized read plus EOF verification, adapted from the historical rapid host.
@unsafe
def p89_read_eof(pair: File & Result<&1,&1,U32 & String,String>, text: String) -> IO(String):
  (file, result) = pair
  do IO<String>:
    Unit <- File.close(file)
    tail : String <- IO.pass(String, result)
    kc(IO(String), String.is_empty(tail), u => IO.pure(String, text),
      u => IO.die(String, 1, "input was not completely read"))

@unsafe
def p89_read_more(pair: File & Result<&1,&1,U32 & String,String>) -> IO(String):
  (file, result) = pair
  match result:
    case Done{text}:
      do IO<String>:
        tail : File & Result<&1,&1,U32 & String,String> <- File.read(file, 1)
        p89_read_eof(tail, text)
    case Fail{error}:
      do IO<String>:
        Unit <- File.close(file)
        IO.pass(String, Fail{error})

@unsafe
def p89_read_sized(pair: File & Result<&1,&1,U32 & String,U32>) -> IO(String):
  (file, result) = pair
  match result:
    case Done{+size}:
      p89_read_limit(file, size, U32.is_le(size, 16777216))
    case Fail{error}:
      do IO<String>:
        Unit <- File.close(file)
        IO.pass(String, Fail{error})

@unsafe
def p89_read_limit(file: File, size: U32, allowed: Bool) -> IO(String):
  match allowed:
    case True{}:
      do IO<String>:
        read : File & Result<&1,&1,U32 & String,String> <- File.read(file, size)
        p89_read_more(read)
    case False{}:
      do IO<String>:
        Unit <- File.close(file)
        IO.die(String, 1, "input exceeds 16 MiB")

@unsafe
def p89_read_file(path: String) -> IO(String):
  do IO<String>:
    file : File <- IO.try(File, File.open(path, "r"))
    pair : File & Result<&1,&1,U32 & String,U32> <- File.size(file)
    p89_read_sized(pair)

@unsafe
def p89_write_close(pair: File & Result<&1,&1,U32 & String,Unit>) -> IO(Unit):
  (file, result) = pair
  do IO<Unit>:
    Unit <- File.close(file)
    IO.pass(Unit, result)

@unsafe
def p89_write_file(path: String, text: String) -> IO(Unit):
  do IO<Unit>:
    file : File <- IO.try(File, File.open(path, "w"))
    pair : File & Result<&1,&1,U32 & String,Unit> <- File.write(file, text)
    p89_write_close(pair)

@unsafe
def p89_copy_checked(same: Bool, clock: Bool) -> IO(U32):
  match same clock:
    case True{} True{}:
      do IO<U32>:
        Unit <- IO.print_err("file-control-ok")
        Unit <- IO.print("copy-ok")
        IO.pure(U32, 0)
    case other other_clock: IO.die(U32, 3, "copy or monotonic clock mismatch")

@unsafe
def p89_copy(+input: String, +output: String) -> IO(U32):
  do IO<U32>:
    before : Nat <- IO.now()
    +text : String <- p89_read_file(input)
    Unit <- p89_write_file(output, text)
    actual : String <- p89_read_file(output)
    after : Nat <- IO.now()
    p89_copy_checked(String.eq(text, actual), Nat.is_ge(after, before))

# Deliberately request one byte, then exercise the entry's real EOF refusal.
@unsafe
def p89_early_eof(input: String) -> IO(U32):
  do IO<U32>:
    file : File <- IO.try(File, File.open(input, "r"))
    pair : File & Result<&1,&1,U32 & String,String> <- File.read(file, 1)
    unexpected : String <- p89_read_more(pair)
    IO.die(U32, 2, "unexpected EOF acceptance")

@unsafe
def p89_cli(args: List<&1,String>) -> IO(U32):
  match args:
    case Con{program, Con{+mode, Con{+input, Con{+output, Nil{}}}}}:
      kc(IO(U32), String.eq(mode, "copy"),
        u => p89_copy(input, output),
        u => kc(IO(U32), String.eq(mode, "early-eof"),
          v => p89_early_eof(input), v => IO.die(U32, 4, "unknown file control mode")))
    case other: IO.die(U32, 4, "expected PROGRAM MODE INPUT OUTPUT")

@unsafe
def main() -> IO(U32):
  do IO<U32>:
    args : List<&1,String> <- IO.args()
    p89_cli(args)
