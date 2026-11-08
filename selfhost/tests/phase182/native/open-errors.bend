import Base

def failed(result: Result<&1, &1, U32 & String, File>) -> IO(Unit):
  match result:
    case Fail{(code, message)}: IO.print(U32.show(code))
    case Done{file}:
      do IO<Unit>:
        File.close(file)
        IO.print("unexpected file")

def main() -> IO(Unit):
  do IO<Unit>:
    a : Result<&1, &1, U32 & String, File> <- File.open_bytes([256], "r")
    failed(a)
    b : Result<&1, &1, U32 & String, File> <- File.open_bytes([0], "r")
    failed(b)

# Linux errno values: EINVAL and EILSEQ, respectively.
#|22
#|84
