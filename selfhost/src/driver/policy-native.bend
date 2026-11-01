# Experimental request policy lives in Bend. The caller authenticates the same
# source, Base, carrier and executing image as the ordinary request contract.
# MASK is canonical decimal: bit 0 disables inlining, bit 1 disables helper
# synthesis, bits 2..3 select current / H plus generic / generic public regions.
# Timing is optional and written separately from the complete QBE byte stream.

@unsafe
def p149n_parsed(+text: String, parsed: Maybe<&2,U32>) -> Maybe<&2,U32>:
  match parsed:
    case None{}: None{}
    case Some{+code}:
      nt_choose(Maybe<&2,U32>,String.eq(text,U32.show(code)) && p149p_valid(code),
        u => Some{code},u => None{})

@unsafe
def p149n_parse(+text: String) -> Maybe<&2,U32>:
  p149n_parsed(text,U32.read(text))

@unsafe
def p149n_emission(regions: U32, result: P111Emission) -> IO(U32):
  match result:
    case P111Emission{chunks,+error}:
      nt_choose(IO(U32),String.is_empty(error),u => p111_print_chunks(chunks),
        u => IO.die(U32,1,error))
    case P134Planned{plan}: p149rw_plan(regions,plan)

@unsafe
def p149n_finish(+code: U32, +timing: String, +started: Nat, +read: Nat, +finished: Nat, +status: U32) -> IO(U32):
  nt_choose(IO(U32),String.is_empty(timing),u => IO.pure(U32,status),
    u => do IO<U32>:
      Unit <- p86_write_file(timing,
        "phase149_policy=" ++ U32.show(code) ++ "\n" ++
        "reads_ms=" ++ Nat.show(Nat.sub(read,started)) ++ "\n" ++
        "compile_emit_ms=" ++ Nat.show(Nat.sub(finished,read)) ++ "\n" ++
        "request_ms=" ++ Nat.show(Nat.sub(finished,started)) ++ "\n")
      IO.pure(U32,status))

# The first interval includes all bounded reads. The second includes preparation,
# checking, lowering, rendering and completed output writes/close. The final
# telemetry-file write and process shutdown remain in the outer process clock.
@unsafe
def p149n_compile(+code: U32, path: String, source: String, base_path: String, base: String,
    carrier: String, stamp: String, cached: Bool, timing: String, started: Nat) -> IO(U32):
  do IO<U32>:
    read : Nat <- IO.now()
    status : U32 <- p149n_emission(p149p_regions(code),
      p149p_compile_source(code,path,source,base_path,base,carrier,stamp,cached))
    finished : Nat <- IO.now()
    p149n_finish(code,timing,started,read,finished,status)

@unsafe
def p149n_carrier(path: String, cached: Bool) -> IO(String):
  match cached:
    case True{}: p86_read_file(path)
    case False{}: IO.pure(String,"")

@unsafe
def p149n_request(code: U32, +path: String, +base_path: String, cache_path: String,
    stamp: String, +cached: Bool, timing: String) -> IO(U32):
  do IO<U32>:
    started : Nat <- IO.now()
    source : String <- p86_read_file(path)
    base : String <- p86_read_file(base_path)
    carrier : String <- p149n_carrier(cache_path,cached)
    p149n_compile(code,path,source,base_path,base,carrier,stamp,cached,timing,started)

def p149n_paths(+path: String, +base: String, +mode: String, +cache: String, +timing: String) -> Bool:
  String.starts_with(path,"/") && String.starts_with(base,"/") &&
    (String.eq(mode,"live") || (String.eq(mode,"cache") && String.starts_with(cache,"/"))) &&
    (String.is_empty(timing) || (String.starts_with(timing,"/") &&
      Bool.not(String.eq(timing,path)) && Bool.not(String.eq(timing,base)) && Bool.not(String.eq(timing,cache))))

@unsafe
def p149n_checked(parsed: Maybe<&2,U32>, +path: String, +base: String, +mode: String,
    +cache: String, stamp: String, +timing: String) -> IO(U32):
  match parsed:
    case None{}: IO.die(U32,2,"phase149 policy must be canonical decimal 0..11")
    case Some{code}:
      nt_choose(IO(U32),p149n_paths(path,base,mode,cache,timing),
        u => p149n_request(code,path,base,cache,stamp,String.eq(mode,"cache"),timing),
        u => IO.die(U32,2,"phase149 expects absolute input/Base paths, live|cache mode, and a distinct absolute timing path"))

@unsafe
def p149n_args(args: List<&1,String>) -> IO(U32):
  match args:
    case Con{mask,Con{path,Con{base,Con{mode,Con{cache,Con{stamp,Nil{}}}}}}}:
      p149n_checked(p149n_parse(mask),path,base,mode,cache,stamp,"")
    case Con{mask,Con{path,Con{base,Con{mode,Con{cache,Con{stamp,Con{timing,Nil{}}}}}}}}:
      p149n_checked(p149n_parse(mask),path,base,mode,cache,stamp,timing)
    case _: IO.die(U32,2,"usage: phase149 MASK ABS_INPUT ABS_BASE live|cache ABS_CARRIER STAMP [ABS_TIMING]")

@unsafe
def p149_native_args(args: List<&1,String>) -> IO(U32):
  match args:
    case Con{+program,+rest}:
      nt_choose(IO(U32),String.eq(program,"phase149"),u => p149n_args(rest),
        u => p111_native_args(Con{program,rest}))
    case Nil{}: p111_native_args([])

@unsafe
def p149nc_decoded(parsed: Maybe<&2,U32>, code: U32, inline: U32, helpers: U32, regions: U32) -> Bool:
  match parsed:
    case None{}: False{}
    case Some{+value}:
      U32.is_eq(value,code) && U32.is_eq(U32.and(value,1),inline) &&
        U32.is_eq(U32.and(U32.shr(value),1),helpers) && U32.is_eq(p149p_regions(value),regions)

@unsafe
def p149nc_code(text: String, code: U32, inline: U32, helpers: U32, regions: U32) -> Bool:
  p149nc_decoded(p149n_parse(text),code,inline,helpers,regions)

@unsafe
def p149nc_is_rejected(parsed: Maybe<&2,U32>) -> Bool:
  match parsed:
    case None{}: True{}
    case Some{value}: False{}

@unsafe
def p149nc_rejected(text: String) -> Bool:
  p149nc_is_rejected(p149n_parse(text))

@unsafe
def p149n_controls() -> List<&2,String>:
  [p113ft_row("policy-code-0-current",p149nc_code("0",0,0,0,0)),
   p113ft_row("policy-code-1-no-inline",p149nc_code("1",1,1,0,0)),
   p113ft_row("policy-code-2-no-helpers",p149nc_code("2",2,0,1,0)),
   p113ft_row("policy-code-3-no-inline-helpers",p149nc_code("3",3,1,1,0)),
   p113ft_row("policy-code-4-h-generic",p149nc_code("4",4,0,0,1)),
   p113ft_row("policy-code-5-h-no-inline",p149nc_code("5",5,1,0,1)),
   p113ft_row("policy-code-6-h-no-helpers",p149nc_code("6",6,0,1,1)),
   p113ft_row("policy-code-7-h-no-inline-helpers",p149nc_code("7",7,1,1,1)),
   p113ft_row("policy-code-8-generic",p149nc_code("8",8,0,0,2)),
   p113ft_row("policy-code-9-generic-no-inline",p149nc_code("9",9,1,0,2)),
   p113ft_row("policy-code-10-generic-no-helpers",p149nc_code("10",10,0,1,2)),
   p113ft_row("policy-code-11-generic-no-inline-helpers",p149nc_code("11",11,1,1,2)),
   p113ft_row("policy-reject-out-of-range",p149nc_rejected("12") && p149nc_rejected("4294967295") && p149nc_rejected("4294967296")),
   p113ft_row("policy-reject-noncanonical",p149nc_rejected("00") && p149nc_rejected("01") && p149nc_rejected("+1") && p149nc_rejected("-1")),
   p113ft_row("policy-reject-nondecimal",p149nc_rejected("") && p149nc_rejected("1x") && p149nc_rejected("1.0") && p149nc_rejected(" 1")),
   p113ft_row("policy-paths-live",p149n_paths("/source","/base","live","","")),
   p113ft_row("policy-paths-cache",p149n_paths("/source","/base","cache","/carrier","/timing")),
   p113ft_row("policy-reject-paths",Bool.not(p149n_paths("source","/base","live","","")) &&
     Bool.not(p149n_paths("/source","/base","cache","carrier","")) &&
     Bool.not(p149n_paths("/source","/base","invalid","/carrier",""))),
   p113ft_row("policy-reject-timing-input",Bool.not(p149n_paths("/source","/base","cache","/carrier","/source")) &&
     Bool.not(p149n_paths("/source","/base","cache","/carrier","/base")) &&
     Bool.not(p149n_paths("/source","/base","cache","/carrier","/carrier")))]
