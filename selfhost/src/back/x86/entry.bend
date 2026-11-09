# Native x86 request protocol. The shared accepted-source and final native-body
# verification path constructs the cursor before emission.
@unsafe
def x181_request(+path: String, +base_path: String, +carrier_path: String,
    +stamp: String, +cached: Bool) -> IO(U32):
  do IO<U32>:
    +source : String <- p86_read_file(path)
    +base : String <- p86_read_file(base_path)
    nt_choose(IO(U32),cached,
      u => do IO<U32>:
        carrier : String <- p86_read_file(carrier_path)
        x181_print(p169n_compile(path,source,base_path,base,carrier,stamp,True{})),
      u => x181_print(p169n_compile(path,source,base_path,base,"",stamp,False{})))

@unsafe
def x181_entry_args(args: List<&1,String>) -> IO(U32):
  match args:
    case Con{program,Con{+path,Con{+base,Con{+mode,Con{+carrier,Con{+stamp,Nil{}}}}}}}:
      nt_choose(IO(U32),String.eq(program,"x86") && String.starts_with(path,"/") &&
        String.starts_with(base,"/") &&
        (String.eq(mode,"live") || (String.eq(mode,"cache") && String.starts_with(carrier,"/"))),
        u => x181_request(path,base,carrier,stamp,String.eq(mode,"cache")),
        u => IO.die(U32,2,"expected x86, absolute input/Base paths and live|cache mode"))
    case _: IO.die(U32,2,"usage: x86 ABS_SOURCE ABS_BASE live|cache ABS_CARRIER_OR_EMPTY STAMP")
