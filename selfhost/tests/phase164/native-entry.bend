# Explicit experimental request chain. Existing six-string source/Base protocol;
# source checking and cached/live Base preparation are unchanged. This does not
# claim session/batch support or install a new compiler selection.

@unsafe
def p164n_prepared(+path: String, +source: String, prepared: P86Preparation) -> P111Emission:
  match prepared:
    case P86PreparationError{error}: P111Emission{[],error}
    case P86PreparationReady{seed}: p164h_emit_plan(p86_plan(seed,path,source))

@unsafe
def p164n_compile(+path: String, +source: String, +base_path: String, +base: String,
    +carrier: String, +stamp: String, +cached: Bool) -> P111Emission:
  p164n_prepared(path,source,nt_choose(P86Preparation,cached,
    u => p88_cache_prepare(base_path,base,carrier,stamp),
    u => p86_prepare(base_path,base)))

@unsafe
def p164n_request(+path: String, +base_path: String, +cache_path: String,
    +stamp: String, +cached: Bool) -> IO(U32):
  do IO<U32>:
    +source : String <- p86_read_file(path)
    +base : String <- p86_read_file(base_path)
    nt_choose(IO(U32),cached,
      u => do IO<U32>:
        carrier : String <- p86_read_file(cache_path)
        p111_print_emission(p164n_compile(path,source,base_path,base,carrier,stamp,True{})),
      u => p111_print_emission(p164n_compile(path,source,base_path,base,"",stamp,False{})))

@unsafe
def p164n_args(args: List<&1,String>) -> IO(U32):
  match args:
    case Con{program,Con{+path,Con{+base,Con{+mode,Con{+cache,Con{+stamp,Nil{}}}}}}}:
      nt_choose(IO(U32),String.starts_with(path,"/") && String.starts_with(base,"/") &&
        (String.eq(mode,"live") || (String.eq(mode,"cache") && String.starts_with(cache,"/"))),
        u => p164n_request(path,base,cache,stamp,String.eq(mode,"cache")),
        u => IO.die(U32,2,"expected absolute input/Base paths and live|cache mode"))
    case _: IO.die(U32,2,"usage: phase164 ABS_INPUT ABS_BASE live|cache ABS_CARRIER STAMP; no session/batch commands")

@unsafe
def main() -> IO(U32):
  do IO<U32>:
    args : List<&1,String> <- IO.args()
    p164n_args(args)
