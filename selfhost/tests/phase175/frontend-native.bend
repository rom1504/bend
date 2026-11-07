# Native-only frontend diagnostic. No backend emission or machine build runs here.
# Cumulative modes use fresh requests; they are not additive independent stage clocks.
def p175fn_mode(+mode: String) -> Bool:
  String.eq(mode,"parse") || String.eq(mode,"check") || String.eq(mode,"context") ||
    String.eq(mode,"annotation") || String.eq(mode,"request")

@unsafe
def p175fn_observe(mode: String, base_ms: Nat, before: Nat, +after: Nat, value: P175Frontend) -> IO(U32):
  do IO<U32>:
    Unit <- IO.print("phase175 frontend " ++ mode ++ " hash=" ++ U32.show(p175fd_value(value)))
    end : Nat <- IO.now()
    Unit <- IO.print_err("phase175 base_ms=" ++ Nat.show(base_ms) ++
      " frontend_ms=" ++ Nat.show(Nat.sub(after,before)) ++
      " observation_ms=" ++ Nat.show(Nat.sub(end,after)))
    IO.pure(U32,0)

@unsafe
def p175fn_record(mode: String, base_ms: Nat, before: Nat, value: P175Frontend) -> IO(U32):
  do IO<U32>:
    after : Nat <- IO.now()
    p175fn_observe(mode,base_ms,before,after,value)

@unsafe
def p175fn_finished(mode: String, base_ms: Nat, before: Nat, value: P175Frontend) -> IO(U32):
  match value:
    case P175FError{error}: IO.die(U32,1,error)
    case P175FBook{stage,book,verdict}:
      p175fn_record(mode,base_ms,before,P175FBook{stage,book,verdict})
    case P175FRequest{request,verdict}:
      p175fn_record(mode,base_ms,before,P175FRequest{request,verdict})

@unsafe
def p175fn_prepared(+mode: String, path: String, source: String, before: Nat, prepared: P86Preparation) -> IO(U32):
  match prepared:
    case P86PreparationError{error}: IO.die(U32,1,error)
    case P86PreparationReady{seed}:
      do IO<U32>:
        +after : Nat <- IO.now()
        p175fn_finished(mode,Nat.sub(after,before),after,p175fp_plan(mode,seed,path,source))

@unsafe
def p175fn_request(mode: String, +path: String, +base: String, carrier: String, stamp: String) -> IO(U32):
  do IO<U32>:
    source : String <- p86_read_file(path)
    base_text : String <- p86_read_file(base)
    carrier_text : String <- p86_read_file(carrier)
    before : Nat <- IO.now()
    p175fn_prepared(mode,path,source,before,p88_cache_prepare(base,base_text,carrier_text,stamp))

@unsafe
def p175fn_args(args: List<&1,String>) -> IO(U32):
  match args:
    case Con{program,Con{+mode,Con{+path,Con{+base,Con{+carrier,Con{+stamp,Nil{}}}}}}}:
      nt_choose(IO(U32),String.eq(program,"phase175-frontend") && p175fn_mode(mode) &&
        String.starts_with(path,"/") && String.starts_with(base,"/") && String.starts_with(carrier,"/"),
        u => p175fn_request(mode,path,base,carrier,stamp),
        u => IO.die(U32,2,"frontend expects phase175-frontend parse|check|context|annotation|request ABS_INPUT ABS_BASE ABS_CARRIER STAMP"))
    case _: IO.die(U32,2,"frontend expects six arguments")

@unsafe
def main() -> IO(U32):
  do IO<U32>:
    args : List<&1,String> <- IO.args()
    p175fn_args(args)
