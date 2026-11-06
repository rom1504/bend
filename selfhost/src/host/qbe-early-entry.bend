


# Sole override: the same preparation and p86_plan run once. Accepted requests
# use the unchanged lower/verify/stream path; no text replacement or rechecking.
@unsafe
def p169n_prepared(+path: String, +source: String, prepared: P86Preparation) -> P169Prepared:
  match prepared:
    case P86PreparationError{error}: p169s_fail(error)
    case P86PreparationReady{seed}: p169np_plan(p86_plan(seed,path,source))



@unsafe
def p169n_compile(+path: String, +source: String, +base_path: String, +base: String,
    +carrier: String, +stamp: String, +cached: Bool) -> P169Prepared:
  p169n_prepared(path,source,nt_choose(P86Preparation,cached,
    u => p88_cache_prepare(base_path,base,carrier,stamp),
    u => p86_prepare(base_path,base)))



@unsafe
def p169n_request(+path: String, +base_path: String, +cache_path: String,
    +stamp: String, +cached: Bool) -> IO(U32):
  do IO<U32>:
    +source : String <- p86_read_file(path)
    +base : String <- p86_read_file(base_path)
    nt_choose(IO(U32),cached,
      u => do IO<U32>:
        carrier : String <- p86_read_file(cache_path)
        p169s_print(p169n_compile(path,source,base_path,base,carrier,stamp,True{})),
      u => p169s_print(p169n_compile(path,source,base_path,base,"",stamp,False{})))



@unsafe
def p169n_args(args: List<&1,String>) -> IO(U32):
  match args:
    case Con{program,Con{+path,Con{+base,Con{+mode,Con{+cache,Con{+stamp,Nil{}}}}}}}:
      nt_choose(IO(U32),String.starts_with(path,"/") && String.starts_with(base,"/") &&
        (String.eq(mode,"live") || (String.eq(mode,"cache") && String.starts_with(cache,"/"))),
        u => p169n_request(path,base,cache,stamp,String.eq(mode,"cache")),
        u => IO.die(U32,2,"expected absolute input/Base paths and live|cache mode"))
    case _: IO.die(U32,2,"usage: phase169 ABS_INPUT ABS_BASE live|cache ABS_CARRIER STAMP; no session/batch commands")


# Optional native-entry protocol successor. The hosted p169s_plan contract stays
# unchanged. Frontend/Base errors pass through; runtime admission owns compile:.

@unsafe
def p169np_admitted(+request: NR_Request, +error: String) -> P169Prepared:
  nt_choose(P169Prepared,String.is_empty(error),
    u => p169s_lowered(request,p168_request_mode(1,request)),
    u => p169s_fail("compile: " ++ error))



@unsafe
def p169np_plan(plan: P86Plan) -> P169Prepared:
  match plan:
    case P86PlanError{error}: p169s_fail(error)
    case P86PlanReady{+request,verdict}:
      p169np_admitted(request,p111_runtime_admission(request))
