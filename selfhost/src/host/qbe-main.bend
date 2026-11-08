
@unsafe
def main() -> IO(U32):
  do IO<U32>:
    args : List<&1,String> <- IO.args()
    p111_native_args(List.tail(&1,String,args))
