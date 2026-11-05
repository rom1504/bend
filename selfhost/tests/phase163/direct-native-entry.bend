# Experimental new request chain; NO protected declarations are replaced.
# Select this entry main explicitly and preserve its receipt. Private args/main
# retain the ordinary checked source/Base/cache protocol only. Session/batch
# commands are deliberately excluded: they would retain the baseline optimizer.

@unsafe
def p163n_pure(+request: NR_Request) -> P111Emission:
  match request:
    case NR_Request{+source,book,names,paths,scope,bound}:
      nt_choose(P111Emission,Bool.not(nc_is_io(source,dt(lookup(source,"main")))),
        u => p163d_executable(request),
        u => P111Emission{[],"direct-only native compiler: pure main required"})

@unsafe
def p163n_admitted(+request: NR_Request, +error: String) -> P111Emission:
  nt_choose(P111Emission,String.is_empty(error),u => p163n_pure(request),
    u => P111Emission{[],"direct-only native runtime admission: " ++ error})

@unsafe
def p163n_emit_plan(plan: P86Plan) -> P111Emission:
  match plan:
    case P86PlanError{error}: P111Emission{[],error}
    case P86PlanReady{+request,verdict}:
      p163n_admitted(request,p111_runtime_admission(request))

@unsafe
def p163n_compile_prepared(+path: String, +source: String, prepared: P86Preparation) -> P111Emission:
  match prepared:
    case P86PreparationError{error}: P111Emission{[],error}
    case P86PreparationReady{seed}: p163n_emit_plan(p86_plan(seed,path,source))

@unsafe
def p163n_compile_source(+path: String, +source: String, +base_path: String, +base: String,
    +carrier: String, +stamp: String, +cached: Bool) -> P111Emission:
  p163n_compile_prepared(path,source,nt_choose(P86Preparation,cached,
    u => p88_cache_prepare(base_path,base,carrier,stamp),u => p86_prepare(base_path,base)))

# Only materialized direct chunks are valid. Refusing the planned alternative
# prevents a dormant old production-plan renderer from entering this closure.
@unsafe
def p163n_print(result: P111Emission) -> IO(U32):
  match result:
    case P111Emission{chunks,+error}:
      nt_choose(IO(U32),String.is_empty(error),u => p111_print_chunks(chunks),
        u => IO.die(U32,1,error))
    case P134Planned{plan}: IO.die(U32,1,"direct-only native compiler: unexpected planned emission")

@unsafe
def p163n_request(+path: String, +base_path: String, +cache_path: String,
    +stamp: String, +cached: Bool) -> IO(U32):
  do IO<U32>:
    +source : String <- p86_read_file(path)
    +base : String <- p86_read_file(base_path)
    nt_choose(IO(U32),cached,
      u => do IO<U32>:
        carrier : String <- p86_read_file(cache_path)
        p163n_print(p163n_compile_source(path,source,base_path,base,carrier,stamp,True{})),
      u => p163n_print(p163n_compile_source(path,source,base_path,base,"",stamp,False{})))

# Exact ordinary p111_native_args six-string protocol and path checks. This
# experimental executable does not claim session/batch or full public CLI parity.
@unsafe
def p163n_args(args: List<&1,String>) -> IO(U32):
  match args:
    case Con{program,Con{+path,Con{+base,Con{+mode,Con{+cache,Con{+stamp,Nil{}}}}}}}:
      nt_choose(IO(U32),String.starts_with(path,"/") && String.starts_with(base,"/") &&
        (String.eq(mode,"live") || (String.eq(mode,"cache") && String.starts_with(cache,"/"))),
        u => p163n_request(path,base,cache,stamp,String.eq(mode,"cache")),
        u => IO.die(U32,2,"expected absolute input/Base paths and live|cache mode"))
    case _: IO.die(U32,2,"usage: phase163-direct ABS_INPUT ABS_BASE live|cache ABS_CARRIER STAMP; no session/batch commands")

@unsafe
def main() -> IO(U32):
  do IO<U32>:
    args : List<&1,String> <- IO.args()
    p163n_args(args)
