import Base

# Run in a fresh guarded directory: this fixture creates one relative file.
def wrote(pair: File & Result<&1, &1, U32 & String, Unit>) -> IO(File):
  (file, result) = pair
  do IO<File>:
    Unit <- IO.pass(Unit, result)
    return file

def read_text(pair: File & Result<&1, &1, U32 & String, String>) -> IO(File):
  (file, result) = pair
  do IO<File>:
    text : String <- IO.pass(String, result)
    IO.print(String.quote(text))
    return file

def main() -> IO(Unit):
  do IO<Unit>:
    f : File <- IO.try(File, File.open("phase182-native.bin", "x"))
    w : File & Result<&1, &1, U32 & String, Unit> <- File.write(f, "ab\ncd")
    f : File <- wrote(w)
    File.close(f)
    f : File <- IO.try(File, File.open("phase182-native.bin", "r+"))
    r : File & Result<&1, &1, U32 & String, String> <- File.read_line(f, 64)
    f : File <- read_text(r)
    w : File & Result<&1, &1, U32 & String, Unit> <- File.write_at(f, 0, [90])
    f : File <- wrote(w)
    r : File & Result<&1, &1, U32 & String, String> <- File.read(f, 64)
    f : File <- read_text(r)
    File.close(f)
    f : File <- IO.try(File, File.open_bytes([112, 104, 97, 115, 101, 49, 56, 50, 45, 110, 97, 116, 105, 118, 101, 46, 98, 105, 110], "r"))
    r : File & Result<&1, &1, U32 & String, String> <- File.read(f, 64)
    f : File <- read_text(r)
    File.close(f)

#|"ab\n"
#|"cd"
#|"Zb\ncd"
