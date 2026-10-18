# Native checked source -> structured segments -> direct QBE.
# The host transports source bytes only. No unchecked semantic certificate is
# accepted by this public entry, and failures never select the C backend.
type P111Emission is Data:
  P111Emission{+chunks: List<&2,String>, +error: String}

@unsafe
def p111_emit_verified(+program: P111Program, +error: String) -> P111Emission:
  nt_choose(P111Emission,String.is_empty(error),u => P111Emission{p111q_chunks(program),""},
    u => P111Emission{[],"structured IR: " ++ error})

@unsafe
def p111_emit_lowered(result: P111Result) -> P111Emission:
  match result:
    case P111Result{+program,+error}:
      nt_choose(P111Emission,String.is_empty(error),u => p111_emit_verified(program,p111_verify_program(program)),
        u => P111Emission{[],"native lowering: " ++ error})

@unsafe
def p111_emit_plan(plan: P86Plan) -> P111Emission:
  match plan:
    case P86PlanError{error}: P111Emission{[],error}
    case P86PlanReady{request,verdict}: p111_emit_lowered(p111_lower_request(request))

@unsafe
def p111_compile_prepared(+path: String, +source: String, prepared: P86Preparation) -> P111Emission:
  match prepared:
    case P86PreparationError{error}: P111Emission{[],error}
    case P86PreparationReady{seed}: p111_emit_plan(p86_plan(seed,path,source))

@unsafe
def p111_compile_source(+path: String, +source: String, +base_path: String, +base: String,
  +carrier: String, +stamp: String, +cached: Bool) -> P111Emission:
  p111_compile_prepared(path,source,nt_choose(P86Preparation,cached,
    u => p88_cache_prepare(base_path,base,carrier,stamp),u => p86_prepare(base_path,base)))

@unsafe
def p111_print_chunks(chunks: List<&2,String>) -> IO(U32):
  match chunks:
    case Nil{}: IO.pure(U32,0)
    case Con{head,rest}:
      do IO<U32>:
        Unit <- IO.print(head)
        p111_print_chunks(rest)

@unsafe
def p111_print_emission(result: P111Emission) -> IO(U32):
  match result:
    case P111Emission{chunks,+error}:
      nt_choose(IO(U32),String.is_empty(error),u => p111_print_chunks(chunks),
        u => IO.die(U32,1,error))

@unsafe
def p111_native_request(+path: String, +base_path: String, +cache_path: String,
  +stamp: String, +cached: Bool) -> IO(U32):
  do IO<U32>:
    +source : String <- p86_read_file(path)
    +base : String <- p86_read_file(base_path)
    nt_choose(IO(U32),cached,
      u => do IO<U32>:
        carrier : String <- p86_read_file(cache_path)
        p111_print_emission(p111_compile_source(path,source,base_path,base,carrier,stamp,True{})),
      u => p111_print_emission(p111_compile_source(path,source,base_path,base,"","",False{})))

@unsafe
def p111_native_args(args: List<&1,String>) -> IO(U32):
  match args:
    case Con{program,Con{+path,Con{+base,Con{+mode,Con{+cache,Con{+stamp,Nil{}}}}}}}:
      nt_choose(IO(U32),String.starts_with(path,"/") && String.starts_with(base,"/") &&
        (String.eq(mode,"live") || (String.eq(mode,"cache") && String.starts_with(cache,"/"))),
        u => p111_native_request(path,base,cache,stamp,String.eq(mode,"cache")),
        u => IO.die(U32,2,"expected absolute input/Base paths and live|cache mode"))
    case _: IO.die(U32,2,"usage: phase111 ABS_INPUT ABS_BASE live|cache ABS_CARRIER STAMP")

@unsafe
def main() -> IO(U32):
  do IO<U32>:
    args : List<&1,String> <- IO.args()
    p111_native_args(args)
