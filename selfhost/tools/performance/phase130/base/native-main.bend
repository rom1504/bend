# Native timing proxy: parsing/materialization and temporary-table reclamation.
# This small printed observation is NOT a full-product correctness oracle.
# Full graph-aware hosted product equality is a prerequisite to timing it.
@unsafe
def p130b_observe(decoded: P88Decoded) -> IO(U32):
  match decoded:
    case P88DecodeError{error}: IO.die(U32,1,error)
    case P88DecodeReady{P88Products{book,fresh,ready,world}}:
      do IO<U32>:
        IO.print(U32.show(U32.from_nat(List.length(&2,KDef,book))))
        IO.pure(U32,0)

@unsafe
def p130b_proxy_args(args: List<&1,String>) -> IO(U32):
  match args:
    case Con{program,Con{path,Con{stamp,Nil{}}}}:
      do IO<U32>:
        carrier : String <- p86_read_file(path)
        p130b_observe(p88_decode_admitted(carrier,stamp,1,75066))
    case other: IO.die(U32,2,"usage: p130 ABS_CARRIER STAMP")

@unsafe
def main() -> IO(U32):
  do IO<U32>:
    args : List<&1,String> <- IO.args()
    p130b_proxy_args(args)
