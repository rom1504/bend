# Private two-revision process. A and B use logical path A; B bytes are read
# from B's physical path. The supervisor authenticates both files and transport.
# Cache publication occurs only after successful framed output and File.close.
type P140NCache is Data:
  P140NCache{+session: P140SCache, +registry: P140GCache, +render: P140RCache}

type P140NMarks is Data:
  P140NMarks{+started: Nat, +frontend: Nat, +raw: Nat, +backend: Nat, +registry: Nat, +written: Nat}

type P140NResult is Data:
  P140NResult{+cache: P140NCache, +marks: P140NMarks, +stats: List<&2,U32>}

def p140n_empty() -> P140NCache:
  P140NCache{p140s_empty(),P140GCache{[]},P140REmpty{}}

def p140n_select(warm: Bool, cache: P140NCache) -> P140NCache:
  match warm:
    case True{}: cache
    case False{}: p140n_empty()

@unsafe
def p140n_paths(+a: String, +b: String, +base: String, +carrier: String,
    +out_a: String, +out_b: String, +mode: String, +owner: String) -> Bool:
  String.starts_with(a,"/") && String.starts_with(b,"/") && String.starts_with(base,"/") && String.starts_with(carrier,"/") &&
  String.starts_with(out_a,"/") && String.starts_with(out_b,"/") && Bool.not(String.eq(out_a,out_b)) &&
  Bool.not(String.eq(out_a,a) || String.eq(out_a,b) || String.eq(out_a,base) || String.eq(out_a,carrier)) &&
  Bool.not(String.eq(out_b,a) || String.eq(out_b,b) || String.eq(out_b,base) || String.eq(out_b,carrier)) &&
  (String.eq(mode,"warm") || String.eq(mode,"cold")) && Bool.not(String.is_empty(owner))

@unsafe
def p140n_compile(seed: P86Seed, path: String, text: String, previous: P140NCache,
    warm: Bool, hint: U32, owner: String, output: String) -> IO(P140NResult):
  do IO<P140NResult>:
    started : Nat <- IO.now()
    p140n_cached(started,seed,path,text,p140n_select(warm,previous),hint,owner,output)

@unsafe
def p140n_cached(started: Nat, seed: P86Seed, path: String, text: String, +previous: P140NCache,
    hint: U32, owner: String, output: String) -> IO(P140NResult):
  match previous:
    case P140NCache{session,registry,render}:
      match session:
        case P140SCache{front,raw,back}:
          p140n_front(started,previous,output,p140f_named(seed,path,text,front,hint,owner))

@unsafe
def p140n_front(started: Nat, previous: P140NCache, output: String, front: P140FResult) -> IO(P140NResult):
  match front:
    case P140FResult{plan,cache,stats}:
      match plan:
        case P86PlanError{error}: IO.die(P140NResult,1,error)
        case P86PlanReady{+request,verdict}:
          do IO<P140NResult>:
            frontend : Nat <- IO.now()
            p140n_admitted(started,frontend,previous,output,cache,stats,request,p111_runtime_admission(request))

@unsafe
def p140n_admitted(+started: Nat, +frontend: Nat, +previous: P140NCache, +output: String,
    +front: P140FCache, +stats: List<&2,U32>, +request: NR_Request, +error: String) -> IO(P140NResult):
  match previous:
    case P140NCache{session,registry,render}:
      match session:
        case P140SCache{old_front,raw,back}:
          nt_choose(IO(P140NResult),String.is_empty(error),
            u => p140n_raw(started,frontend,previous,output,front,stats,request,p140or_lower(request,raw)),
            u => IO.die(P140NResult,1,"compile: " ++ error))

@unsafe
def p140n_raw(started: Nat, frontend: Nat, previous: P140NCache, output: String,
    front: P140FCache, stats: List<&2,U32>, request: NR_Request, result: P140ORResult) -> IO(P140NResult):
  match previous:
    case P140NCache{+session,registry,render}:
      match session:
        case P140SCache{old_front,old_raw,back}:
          match result:
            case P140ORResult{lowering,cache,counts}:
              do IO<P140NResult>:
                raw : Nat <- IO.now()
                p140n_backend(started,frontend,raw,registry,render,output,
                  p140s_finished(session,front,cache,nt_append(U32,stats,counts),p140b_session(request,back,lowering)))

@unsafe
def p140n_backend(started: Nat, frontend: Nat, raw: Nat, registry: P140GCache, render: P140RCache,
    output: String, result: P140SResult) -> IO(P140NResult):
  match result:
    case P140SResult{emission,session,stats}:
      match emission:
        case P134Planned{plan}:
          do IO<P140NResult>:
            backend : Nat <- IO.now()
            p140n_registry(started,frontend,raw,backend,session,render,output,stats,p140g_prepare(plan,registry))
        case P111Emission{chunks,+error}:
          IO.die(P140NResult,1,nt_choose(String,String.is_empty(error),u => "session requires a sealed emission plan",u => error))

@unsafe
def p140n_registry(started: Nat, frontend: Nat, raw: Nat, backend: Nat, session: P140SCache,
    render: P140RCache, output: String, stats: List<&2,U32>, prepared: P140GPrepared) -> IO(P140NResult):
  match prepared:
    case P140GPrepared{cursor,cache,hits,misses}:
      do IO<P140NResult>:
        registry : Nat <- IO.now()
        file : File <- IO.try(File,File.open(output,"w"))
        written : P140RWritten <- p140rw_drain(file,0,p140r_begin_cursor(cursor,render))
        p140n_written(started,frontend,raw,backend,registry,session,cache,nt_append(U32,stats,[hits,misses]),written)

@unsafe
def p140n_written(started: Nat, frontend: Nat, raw: Nat, backend: Nat, registry: Nat,
    session: P140SCache, plans: P140GCache, stats: List<&2,U32>, result: P140RWritten) -> IO(P140NResult):
  match result:
    case P140RWritten{cache,hits,misses,pieces}:
      do IO<P140NResult>:
        written : Nat <- IO.now()
        IO.pure(P140NResult,P140NResult{P140NCache{session,plans,cache},P140NMarks{started,frontend,raw,backend,registry,written},nt_append(U32,stats,[hits,misses,pieces])})

@unsafe
def p140n_numbers(values: List<&2,U32>) -> String:
  match values:
    case Nil{}: ""
    case Con{head,tail}: U32.show(head) ++ " " ++ p140n_numbers(tail)

@unsafe
def p140n_line(label: String, marks: P140NMarks) -> String:
  match marks:
    case P140NMarks{+started,+frontend,+raw,+backend,+registry,+written}:
      "phase140 stages " ++ label ++ " frontend_ms=" ++ Nat.show(Nat.sub(frontend,started)) ++
      " raw_ms=" ++ Nat.show(Nat.sub(raw,frontend)) ++ " backend_ms=" ++ Nat.show(Nat.sub(backend,raw)) ++
      " registry_ms=" ++ Nat.show(Nat.sub(registry,backend)) ++ " render_close_ms=" ++ Nat.show(Nat.sub(written,registry)) ++
      " total_ms=" ++ Nat.show(Nat.sub(written,started))

@unsafe
def p140n_report(prepare_ms: Nat, a_marks: P140NMarks, a_stats: List<&2,U32>, result: P140NResult) -> IO(U32):
  match result:
    case P140NResult{cache,marks,stats}:
      do IO<U32>:
        Unit <- IO.print("phase140 prepare_ms " ++ Nat.show(prepare_ms))
        Unit <- IO.print("phase140 A " ++ p140n_numbers(a_stats))
        Unit <- IO.print("phase140 B " ++ p140n_numbers(stats))
        Unit <- IO.print(p140n_line("A",a_marks))
        Unit <- IO.print(p140n_line("B",marks))
        IO.pure(U32,0)

@unsafe
def p140n_second(prepare_ms: Nat, seed: P86Seed, logical: String, source_b: String, out_b: String,
    warm: Bool, hint: U32, owner: String, result: P140NResult) -> IO(U32):
  match result:
    case P140NResult{cache,marks,stats}:
      do IO<U32>:
        result_b : P140NResult <- p140n_compile(seed,logical,source_b,cache,warm,hint,owner,out_b)
        p140n_report(prepare_ms,marks,stats,result_b)

@unsafe
def p140n_sources(+started: Nat, +seed: P86Seed, +a: String, +source_a: String, +source_b: String,
    +out_a: String, +out_b: String, +warm: Bool, +relative: U32, +owner: String) -> IO(U32):
  match seed:
    case P86Seed{+base,book,fresh,ready,world}:
      +begin = f_source_end(base)
      nt_choose(IO(U32),U32.is_le(relative,p86_width(source_a,0)) && U32.is_le(relative,p86_width(source_b,0)) && U32.is_le(relative,U32.sub(4294967295,begin)),
        u => do IO<U32>:
          ready_time : Nat <- IO.now()
          result_a : P140NResult <- p140n_compile(seed,a,source_a,p140n_empty(),False{},U32.add(begin,relative),owner,out_a)
          p140n_second(Nat.sub(ready_time,started),seed,a,source_b,out_b,warm,U32.add(begin,relative),owner,result_a),
        u => IO.die(U32,2,"session hint exceeds source UTF16 span"))

@unsafe
def p140n_prepared(started: Nat, +a: String, b: String, out_a: String, out_b: String,
    warm: Bool, relative: U32, owner: String, prepared: P86Preparation) -> IO(U32):
  match prepared:
    case P86PreparationError{error}: IO.die(U32,1,error)
    case P86PreparationReady{seed}:
      do IO<U32>:
        source_a : String <- p86_read_file(a)
        source_b : String <- p86_read_file(b)
        p140n_sources(started,seed,a,source_a,source_b,out_a,out_b,warm,relative,owner)

@unsafe
def p140n_start(a: String, b: String, +base: String, carrier: String, stamp: String,
    out_a: String, out_b: String, warm: Bool, relative: U32, owner: String) -> IO(U32):
  do IO<U32>:
    started : Nat <- IO.now()
    base_text : String <- p86_read_file(base)
    carrier_text : String <- p86_read_file(carrier)
    p140n_prepared(started,a,b,out_a,out_b,warm,relative,owner,p88_cache_prepare(base,base_text,carrier_text,stamp))

@unsafe
def p140n_args(a: String, b: String, base: String, carrier: String, stamp: String,
    out_a: String, out_b: String, warm: Bool, +hint: String, owner: String, parsed: Maybe<&2,U32>) -> IO(U32):
  match parsed:
    case None{}: IO.die(U32,2,"session requires a canonical U32 UTF16 hint")
    case Some{+relative}:
      nt_choose(IO(U32),String.eq(hint,U32.show(relative)),
        u => p140n_start(a,b,base,carrier,stamp,out_a,out_b,warm,relative,owner),
        u => IO.die(U32,2,"session requires a canonical U32 UTF16 hint"))

@unsafe
def p111_native_args(args: List<&1,String>) -> IO(U32):
  match args:
    case Con{program,Con{+logical,Con{+base,Con{+carrier,Con{+stamp,Con{+jobfile,Con{version,Nil{}}}}}}}}:
      nt_choose(IO(U32),String.eq(program,"phase140-batch") && String.eq(version,"v1") &&
        String.starts_with(logical,"/") && String.starts_with(base,"/") && String.starts_with(carrier,"/") && String.starts_with(jobfile,"/"),
        u => p140nb_start(logical,base,carrier,stamp,jobfile),
        u => IO.die(U32,2,"batch expects absolute logical/Base/carrier/jobfile paths and v1"))
    case Con{program,Con{+a,Con{+b,Con{+base,Con{+carrier,Con{+stamp,Con{+out_a,Con{+out_b,Con{+mode,Con{+hint,Con{+owner,Nil{}}}}}}}}}}}}:
      nt_choose(IO(U32),String.eq(program,"phase140-session") && p140n_paths(a,b,base,carrier,out_a,out_b,mode,owner),
        u => p140n_args(a,b,base,carrier,stamp,out_a,out_b,String.eq(mode,"warm"),hint,owner,U32.read(hint)),
        u => IO.die(U32,2,"session expects absolute distinct paths, warm|cold, hint and owner"))
    case Con{program,Con{+path,Con{+base,Con{+mode,Con{+cache,Con{+stamp,Nil{}}}}}}}:
      nt_choose(IO(U32),String.starts_with(path,"/") && String.starts_with(base,"/") &&
        (String.eq(mode,"live") || (String.eq(mode,"cache") && String.starts_with(cache,"/"))),
        u => p111_native_request(path,base,cache,stamp,String.eq(mode,"cache")),
        u => IO.die(U32,2,"expected absolute input/Base paths and live|cache mode"))
    case _: IO.die(U32,2,"usage: phase111 ABS_INPUT ABS_BASE live|cache ABS_CARRIER STAMP")
