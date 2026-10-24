import Base

def written(pair: File & Result<&1,&1,U32 & String,Unit>) -> IO(U32):
  (file,result) = pair
  do IO<U32>:
    Unit <- File.close(file)
    Unit <- IO.pass(Unit,result)
    IO.pure(U32,0)

def first(pair: File & Result<&1,&1,U32 & String,Unit>) -> IO(U32):
  (file,result) = pair
  do IO<U32>:
    Unit <- IO.pass(Unit,result)
    next : File & Result<&1,&1,U32 & String,Unit> <- File.write(file,"two\n")
    written(next)

def main() -> IO(U32):
  do IO<U32>:
    file : File <- IO.try(File,File.open("/dev/stdout","a"))
    next : File & Result<&1,&1,U32 & String,Unit> <- File.write(file,"one:")
    first(next)
