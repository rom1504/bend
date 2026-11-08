# Experimental native-only request entry. The existing accepted-source and
# final native-body verification path constructs the cursor before emission.
@unsafe
def x181_request(+path: String, +base_path: String, +carrier_path: String, +stamp: String) -> IO(U32):
  do IO<U32>:
    source : String <- p86_read_file(path)
    base : String <- p86_read_file(base_path)
    carrier : String <- p86_read_file(carrier_path)
    x181_print(p169n_compile(path,source,base_path,base,carrier,stamp,True{}))

@unsafe
def x181_entry_args(args: List<&1,String>) -> IO(U32):
  match args:
    case Con{program,Con{+path,Con{+base,Con{+carrier,Con{+stamp,Nil{}}}}}}:
      nt_choose(IO(U32),String.eq(program,"phase181-x86") && String.starts_with(path,"/") &&
        String.starts_with(base,"/") && String.starts_with(carrier,"/"),
        u => x181_request(path,base,carrier,stamp),
        u => IO.die(U32,2,"x86 expects phase181-x86 ABS_SOURCE ABS_BASE ABS_CARRIER STAMP"))
    case _: IO.die(U32,2,"x86 expects five arguments")

@unsafe
def main() -> IO(U32):
  do IO<U32>:
    args : List<&1,String> <- IO.args()
    x181_entry_args(args)
