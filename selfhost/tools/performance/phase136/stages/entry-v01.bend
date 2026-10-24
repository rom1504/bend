@unsafe
def p111_native_args(args: List<&1,String>) -> IO(U32):
  match args:
    case Con{+program,Con{+path,Con{+base,Con{+mode,Con{+cache,Con{+stamp,Con{+output,Nil{}}}}}}}}:
      nt_choose(IO(U32),String.eq(program,"phase136-stages") && String.eq(output,"stderr") &&
        String.starts_with(path,"/") && String.starts_with(base,"/") && String.starts_with(cache,"/") && String.eq(mode,"cache"),
        u => p136s_request(path,base,cache,stamp),
        u => IO.die(U32,2,"stages expects phase136-stages ABS_INPUT ABS_BASE cache ABS_CARRIER STAMP stderr"))
    case Con{program,Con{+path,Con{+base,Con{+mode,Con{+cache,Con{+stamp,Nil{}}}}}}}:
      nt_choose(IO(U32),String.starts_with(path,"/") && String.starts_with(base,"/") &&
        (String.eq(mode,"live") || (String.eq(mode,"cache") && String.starts_with(cache,"/"))),
        u => p111_native_request(path,base,cache,stamp,String.eq(mode,"cache")),
        u => IO.die(U32,2,"expected absolute input/Base paths and live|cache mode"))
    case _: IO.die(U32,2,"usage: phase111 ABS_INPUT ABS_BASE live|cache ABS_CARRIER STAMP")
