import Base

# The fixed direct-QBE runtime implements these exact foreign names.
def NativeHost.read(path: String, digest: String, limit: U32) -> IO(Result<&1,&1,U32 & String,String>):
  import "../../../../src/host/native-os.c"

def NativeHost.path(path: String) -> IO(Result<&1,&1,U32 & String,String>):
  import "../../../../src/host/native-os.c"

def NativeHost.publish(path: String, text: String) -> IO(Result<&1,&1,U32 & String,Unit>):
  import "../../../../src/host/native-os.c"

def text_result(result: Result<&1,&1,U32 & String,String>) -> IO(U32):
  match result:
    case Done{text}:
      do IO<U32>:
        Unit <- IO.print(text)
        IO.pure(U32,0)
    case Fail{(code,message)}: IO.die(U32,1,message)

def publish_result(result: Result<&1,&1,U32 & String,Unit>) -> IO(U32):
  match result:
    case Done{unit}:
      do IO<U32>:
        Unit <- IO.print("published")
        IO.pure(U32,0)
    case Fail{(code,message)}:
      do IO<U32>:
        Unit <- IO.print(U32.show(code))
        IO.pure(U32,1)

def dispatch(args: List<&1,String>) -> IO(U32):
  match args:
    case Con{"path",Con{path,Nil{}}}:
      do IO<U32>:
        result : Result<&1,&1,U32 & String,String> <- NativeHost.path(path)
        text_result(result)
    case Con{"publish",Con{path,Con{text,Nil{}}}}:
      do IO<U32>:
        result : Result<&1,&1,U32 & String,Unit> <- NativeHost.publish(path,text)
        publish_result(result)
    case Con{"read",Con{path,Nil{}}}:
      do IO<U32>:
        result : Result<&1,&1,U32 & String,String> <- NativeHost.read(path,"",16777216)
        text_result(result)
    case _: IO.die(U32,2,"expected path/publish/read arguments")

def main() -> IO(U32):
  do IO<U32>:
    args : List<&1,String> <- IO.args()
    dispatch(args)
