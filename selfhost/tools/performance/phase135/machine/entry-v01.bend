@unsafe
def p111_native_args(args: List<&1,String>) -> IO(U32):
  match args:
    case Con{+program,Con{+a,Con{+b,Con{+base,Con{+carrier,Con{+stamp,Con{+out_a,Con{+out_b,Con{+mode,Nil{}}}}}}}}}}:
      nt_choose(IO(U32),(String.eq(program,"phase134-session") || String.eq(program,"phase135-units")) && p134ns_paths(a,b,base,carrier,out_a,out_b,mode),
        u => p135m_start(String.eq(program,"phase135-units"),a,b,base,carrier,stamp,out_a,out_b,String.eq(mode,"warm")),
        u => IO.die(U32,2,"session expects absolute, distinct output paths and warm|cold"))
    case Con{program,Con{+path,Con{+base,Con{+mode,Con{+cache,Con{+stamp,Nil{}}}}}}}:
      nt_choose(IO(U32),String.starts_with(path,"/") && String.starts_with(base,"/") &&
        (String.eq(mode,"live") || (String.eq(mode,"cache") && String.starts_with(cache,"/"))),
        u => p111_native_request(path,base,cache,stamp,String.eq(mode,"cache")),
        u => IO.die(U32,2,"expected absolute input/Base paths and live|cache mode"))
    case _: IO.die(U32,2,"usage: phase111 ABS_INPUT ABS_BASE live|cache ABS_CARRIER STAMP")

