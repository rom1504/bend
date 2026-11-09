# IO.args includes argv[0] under bend-rts-v1. The request starts after it.
@unsafe
def main() -> IO(U32):
  do IO<U32>:
    args : List<&1,String> <- IO.args()
    x181_entry_args(List.tail(&1,String,args))
