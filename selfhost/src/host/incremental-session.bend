

def p140f_empty() -> P140FCache:
  P140FCache{None{},P140CPEmpty{},p140of_empty()}


@unsafe
def p140f_plan(+seed: P86Seed, path: String, text: String, +previous: P140FCache, hint: U32, cut: U32) -> P140FResult:
  match previous:
    case P140FCache{parser,checker,owners}:
      p140f_loaded(seed,previous,cut,p140pl_load(seed,path,text,parser,hint))


@unsafe
def p140f_error(error: String, previous: P140FCache) -> P140FResult:
  P140FResult{P86PlanError{error},previous,[]}


@unsafe
def p140f_loaded(+seed: P86Seed, +previous: P140FCache, +cut: U32, parsed: P140PLoadResult) -> P140FResult:
  match parsed:
    case P140PLoadError{error,cache}: p140f_error(error,previous)
    case P140PLoadReady{+load,cache,hit}: p140f_load(seed,previous,cut,load,cache,hit)


@unsafe
def p140f_load(seed: P86Seed, +previous: P140FCache, cut: U32, +load: FPrefixLoad, parser: Maybe<&2,P140PCache>, hit: Bool) -> P140FResult:
  match seed previous load:
    case P86Seed{base,book,fresh,ready,+world} P140FCache{old_parser,checker,owners} FPrefixLoad{FLoadTrace{FResult{+original,+error,imports},done,sources},prefix,suffix,eligible}:
      nt_choose(P140FResult,String.is_empty(error),
        u => p140f_checked(load,world,previous,parser,hit,original,
          p140cb_check("phase140-fixed-producer-v1",load,world,checker,cut,[])),
        u => p140f_error("parse: " ++ error,previous))


@unsafe
def p140f_checked(+load: FPrefixLoad, +world: KBasePreparedWorld, +previous: P140FCache,
    +parser: Maybe<&2,P140PCache>, +parsed: Bool, +original: List<&2,KDef>, checked: P140CBResult) -> P140FResult:
  match checked:
    case P140CBResult{DResult{+error,+book,diagnostic},+checkpoint,+reused,+skipped,reason}:
      nt_choose(P140FResult,String.is_empty(error),
        u => p140f_reported(load,world,previous,parser,parsed,checkpoint,reused,skipped,book,p140dr_report_data(original)),
        u => p140f_error("check: " ++ error,previous))


@unsafe
def p140f_reported(+load: FPrefixLoad, +world: KBasePreparedWorld, +previous: P140FCache,
    +parser: Maybe<&2,P140PCache>, +parsed: Bool, +checkpoint: P140CPCheckpoint, +reused: Bool, +skipped: U32,
    +book: List<&2,KDef>, report: DR_Report) -> P140FResult:
  match report:
    case DR_Report{verdict,names}:
      p140f_owned(load,world,previous,parser,parsed,checkpoint,reused,skipped,book,verdict,driver_emit_owned(book))


@unsafe
def p140f_owned(+load: FPrefixLoad, +world: KBasePreparedWorld, +previous: P140FCache,
    +parser: Maybe<&2,P140PCache>, +parsed: Bool, +checkpoint: P140CPCheckpoint, +reused: Bool, +skipped: U32,
    +book: List<&2,KDef>, +verdict: String, +error: String) -> P140FResult:
  nt_choose(P140FResult,String.is_empty(error),
    u => p140f_entry(load,world,previous,parser,parsed,checkpoint,reused,skipped,book,verdict,j_compile_error(book)),
    u => p140f_error("compile: " ++ error,previous))


@unsafe
def p140f_entry(load: FPrefixLoad, world: KBasePreparedWorld, +previous: P140FCache,
    parser: Maybe<&2,P140PCache>, parsed: Bool, checkpoint: P140CPCheckpoint, reused: Bool, skipped: U32,
    book: List<&2,KDef>, verdict: String, +error: String) -> P140FResult:
  match previous:
    case P140FCache{old_parser,old_checker,owners}:
      nt_choose(P140FResult,String.is_empty(error),
        u => p140f_owners(previous,parser,parsed,checkpoint,reused,skipped,
          p140of_context(book_context_world(book,load,world),verdict,owners)),
        u => p140f_error("compile: " ++ error,previous))


@unsafe
def p140f_owners(+previous: P140FCache, parser: Maybe<&2,P140PCache>, parsed: Bool,
    checkpoint: P140CPCheckpoint, reused: Bool, skipped: U32, result: P140OFResult) -> P140FResult:
  match result:
    case P140OFResult{+plan,cache,stats}:
      match plan:
        case P86PlanError{error}: p140f_error(error,previous)
        case P86PlanReady{request,verdict}:
          P140FResult{plan,P140FCache{parser,checkpoint,cache},
            Con{Bool.to_u32(parsed),Con{Bool.to_u32(reused),Con{skipped,stats}}}}


@unsafe
def p140f_named(+seed: P86Seed, path: String, text: String, +previous: P140FCache, hint: U32, +owner: String) -> P140FResult:
  match previous:
    case P140FCache{parser,checker,owners}:
      p140f_named_loaded(seed,previous,owner,p140pl_load(seed,path,text,parser,hint))


@unsafe
def p140f_named_loaded(+seed: P86Seed, +previous: P140FCache, +owner: String, parsed: P140PLoadResult) -> P140FResult:
  match parsed:
    case P140PLoadError{error,cache}: p140f_error(error,previous)
    case P140PLoadReady{+load,cache,hit}: p140f_load(seed,previous,p140cb_owner_cut(load,owner),load,cache,hit)


def p140b_empty() -> P140BCache:
  P140BCache{P140VEmpty{},P134UCache{[],[]},P140VEmpty{},p140l_empty()}


@unsafe
def p140b_session(+request: NR_Request, +previous: P140BCache, +lowering: P128RawLowering) -> P140BResult:
  match lowering:
    case P128RawLowering{P113DLowered{+program,+error},+raw}:
      nt_choose(P140BResult,String.is_empty(error),
        u => p140b_open(request,previous,program,raw),
        u => P140BResult{p128raw_session_finish(request,p113a_certificate(request),lowering),previous,[]})


@unsafe
def p140b_open(+request: NR_Request, +previous: P140BCache, program: P113DProgram, raw: List<&2,P113DCandidate>) -> P140BResult:
  match previous:
    case P140BCache{opened,optimized,array,late}:
      p140b_opened(request,previous,raw,p140v_open(program,opened))


@unsafe
def p140b_opened(+request: NR_Request, previous: P140BCache, raw: List<&2,P113DCandidate>, opened: P140VOpened) -> P140BResult:
  match previous opened:
    case P140BCache{old_open,optimized,array,late} P140VOpened{boundary,cache,counts}:
      p140b_optimized(request,raw,cache,array,late,counts,p134u_optimize(boundary,optimized))


@unsafe
def p140b_optimized(+request: NR_Request, raw: List<&2,P113DCandidate>, opened: P140VCache, array: P140VCache, late: P140LCache,
    counts: List<&2,U32>, optimized: P134UOptimized) -> P140BResult:
  match optimized:
    case P134UOptimized{boundary,cache,stats}:
      p140b_lowered(request,raw,opened,cache,array,late,nt_append(U32,counts,stats),
        p113a_finish(p113a_certificate(request),P113DLowered{p114s_close(boundary),""}))


@unsafe
def p140b_lowered(+request: NR_Request, +raw: List<&2,P113DCandidate>, +opened: P140VCache,
    +optimized: P134UCache, +array: P140VCache, +late: P140LCache, +stats: List<&2,U32>, lowered: P113ALowering) -> P140BResult:
  match lowered:
    case P113ALowered{+program,+error}:
      nt_choose(P140BResult,String.is_empty(error),
        u => p140b_array(request,raw,program,opened,optimized,late,stats,p140v_array(program,array)),
        u => P140BResult{P111Emission{[],"array native lowering: " ++ error},P140BCache{opened,optimized,array,late},stats})


@unsafe
def p140b_array(request: NR_Request, raw: List<&2,P113DCandidate>, program: P113AProgram,
    opened: P140VCache, optimized: P134UCache, late: P140LCache, stats: List<&2,U32>, checked: P140VArrayChecked) -> P140BResult:
  match checked:
    case P140VArrayChecked{cache,error,counts}:
      p140b_late(opened,optimized,cache,nt_append(U32,stats,counts),p140le_verified(request,raw,program,error,late))


@unsafe
def p140b_late(opened: P140VCache, optimized: P134UCache, array: P140VCache, stats: List<&2,U32>, late: P140LEmission) -> P140BResult:
  match late:
    case P140LEmission{emission,cache,counts}:
      P140BResult{emission,P140BCache{opened,optimized,array,cache},nt_append(U32,stats,counts)}


def p140s_empty() -> P140SCache:
  P140SCache{p140f_empty(),p140or_empty(),p140b_empty()}


@unsafe
def p140s_plan(seed: P86Seed, path: String, text: String, +previous: P140SCache, hint: U32, cut: U32) -> P140SResult:
  match previous:
    case P140SCache{front,raw,back}: p140s_front(previous,p140f_plan(seed,path,text,front,hint,cut))


@unsafe
def p140s_front(+previous: P140SCache, front: P140FResult) -> P140SResult:
  match front:
    case P140FResult{plan,cache,stats}:
      match plan:
        case P86PlanError{error}: P140SResult{P111Emission{[],error},previous,stats}
        case P86PlanReady{+request,verdict}: p140s_admitted(previous,cache,stats,request,p111_runtime_admission(request))


@unsafe
def p140s_admitted(+previous: P140SCache, +front: P140FCache, +stats: List<&2,U32>, +request: NR_Request, +error: String) -> P140SResult:
  match previous:
    case P140SCache{old,raw,back}:
      nt_choose(P140SResult,String.is_empty(error),
        u => p140s_raw(previous,front,stats,request,p140or_lower(request,raw)),
        u => P140SResult{P111Emission{[],"compile: " ++ error},previous,stats})


@unsafe
def p140s_raw(+previous: P140SCache, front: P140FCache, stats: List<&2,U32>, request: NR_Request, raw: P140ORResult) -> P140SResult:
  match previous raw:
    case P140SCache{old_front,old_raw,back} P140ORResult{lowering,cache,counts}:
      p140s_finished(previous,front,cache,nt_append(U32,stats,counts),p140b_session(request,back,lowering))


@unsafe
def p140s_finished(+previous: P140SCache, +front: P140FCache, +raw: P140ORCache, +stats: List<&2,U32>, back: P140BResult) -> P140SResult:
  match back:
    case P140BResult{+emission,+cache,+counts}:
      match emission:
        case P111Emission{chunks,error}:
          nt_choose(P140SResult,String.is_empty(error),
            u => P140SResult{emission,P140SCache{front,raw,cache},nt_append(U32,stats,counts)},
            u => P140SResult{emission,previous,nt_append(U32,stats,counts)})
        case P134Planned{plan}: P140SResult{emission,P140SCache{front,raw,cache},nt_append(U32,stats,counts)}


@unsafe
def p140s_named(seed: P86Seed, path: String, text: String, +previous: P140SCache, hint: U32, owner: String) -> P140SResult:
  match previous:
    case P140SCache{front,raw,back}: p140s_front(previous,p140f_named(seed,path,text,front,hint,owner))


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
    case P140NCache{session,registry,render}:
      match session:
        case P140SCache{old_front,old_raw,back}:
          match result:
            case P140ORResult{lowering,cache,counts}:
              do IO<P140NResult>:
                raw : Nat <- IO.now()
                p140n_backend(started,frontend,raw,registry,render,output,
                  p144cn_native_result(front,cache,nt_append(U32,stats,counts),p140b_session(request,back,lowering)))

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


def p140nn_parsed(text: String, parsed: Maybe<&2,U32>) -> Bool:
  match parsed:
    case None{}: False{}
    case Some{value}: String.eq(text,U32.show(value))


def p140nn_canonical(+text: String) -> Bool:
  p140nn_parsed(text,U32.read(text))


def p140nn_bounds(+begin: U32, +relative: U32, a: U32, b: U32) -> Bool:
  U32.is_le(relative,a) && U32.is_le(relative,b) && U32.is_le(relative,U32.sub(4294967295,begin))


def p140nn_empty(cache: P140NCache) -> Bool:
  match cache:
    case P140NCache{session,P140GCache{passes},render}: List.is_empty(&2,P140GPass,passes)
    case P140NCache{session,P140GMetadata{passes,p,n,a,l,i,x,t},render}: List.is_empty(&2,P140GPass,passes)


@unsafe
def p140n_controls() -> List<&2,String>:
  +marker: P140NCache = P140NCache{p140s_empty(),P140GCache{[P140GPass{missing(),missing(),1,[]}]},P140REmpty{}}
  [p131u_row(p140n_paths("/a","/b","/base","/carrier","/oa","/ob","warm","owner"),"native-warm-paths"),
   p131u_row(p140n_paths("/a","/b","/base","/carrier","/oa","/ob","cold","owner"),"native-cold-paths"),
   p131u_row(Bool.not(p140n_paths("a","/b","/base","/carrier","/oa","/ob","warm","owner")),"native-relative-input"),
   p131u_row(Bool.not(p140n_paths("/a","/b","/base","/carrier","oa","/ob","warm","owner")),"native-relative-output"),
   p131u_row(Bool.not(p140n_paths("/a","/b","/base","/carrier","/oa","/oa","warm","owner")),"native-output-alias"),
   p131u_row(Bool.not(p140n_paths("/a","/b","/base","/carrier","/a","/ob","warm","owner")),"native-overwrite-input"),
   p131u_row(Bool.not(p140n_paths("/a","/b","/base","/carrier","/oa","/ob","other","owner")),"native-unknown-mode"),
   p131u_row(Bool.not(p140n_paths("/a","/b","/base","/carrier","/oa","/ob","warm","")),"native-empty-owner"),
   p131u_row(p140nn_canonical("0"),"native-hint-zero"),
   p131u_row(p140nn_canonical("37"),"native-hint-number"),
   p131u_row(p140nn_canonical("4294967295"),"native-hint-maximum"),
   p131u_row(Bool.not(p140nn_canonical("")),"native-hint-empty"),
   p131u_row(Bool.not(p140nn_canonical("037")),"native-hint-noncanonical"),
   p131u_row(Bool.not(p140nn_canonical("4294967296")),"native-hint-overflow"),
   p131u_row(p140nn_bounds(10,5,5,5),"native-bound-inclusive"),
   p131u_row(Bool.not(p140nn_bounds(10,6,5,7)),"native-bound-source"),
   p131u_row(Bool.not(p140nn_bounds(4294967295,1,1,1)),"native-bound-add-overflow"),
   p131u_row(p140nn_bounds(4294967295,0,0,0),"native-bound-maximum-zero"),
   p131u_row(p140nn_empty(p140n_select(False{},marker)),"native-cold-clears-cache"),
   p131u_row(Bool.not(p140nn_empty(p140n_select(True{},marker))),"native-warm-keeps-cache")]


@unsafe
def p140nb_finish(jobs: List<&2,P140NBJob>, count: U32) -> P140NBJobs:
  nt_choose(P140NBJobs,U32.is_eq(count,0),u => P140NBError{"empty batch"},u => P140NBReady{nt_reverse(P140NBJob,jobs,[])})

@unsafe
def p140nb_lines(lines: List<&2,String>, jobs: List<&2,P140NBJob>, +count: U32) -> P140NBJobs:
  match lines:
    case Nil{}: p140nb_finish(jobs,count)
    case Con{last,Nil{}}: nt_choose(P140NBJobs,String.is_empty(last),u => p140nb_finish(jobs,count),u => P140NBError{"incomplete batch job"})
    case Con{+source,Con{+output,Con{+hint,Con{+owner,Con{+mode,rest}}}}}:
      p140nb_number(rest,jobs,count,source,output,hint,owner,mode,U32.read(hint))
    case _: P140NBError{"incomplete batch job"}

@unsafe
def p140nb_number(rest: List<&2,String>, jobs: List<&2,P140NBJob>, +count: U32,
    +source: String, +output: String, hint: String, +owner: String, +mode: String, parsed: Maybe<&2,U32>) -> P140NBJobs:
  match parsed:
    case None{}: P140NBError{"invalid batch hint"}
    case Some{+number}:
      nt_choose(P140NBJobs,U32.is_lt(count,64) && String.starts_with(source,"/") && String.starts_with(output,"/") &&
        String.eq(hint,U32.show(number)) && Bool.not(String.is_empty(owner)) && (String.eq(mode,"warm") || String.eq(mode,"cold")),
        u => p140nb_lines(rest,Con{P140NBJob{source,output,number,owner,String.eq(mode,"warm")},jobs},U32.inc(count)),
        u => P140NBError{"invalid batch paths, owner, hint, policy or count"})

@unsafe
def p140nb_parse(+text: String) -> P140NBJobs:
  nt_choose(P140NBJobs,U32.is_le(p86_width(text,0),32768) && Bool.not(String.contains(text,"\r")),
    u => p140nb_lines(String.lines(text),[],0),u => P140NBError{"batch requires at most32768 UTF16 units and LF lines"})

@unsafe
def p140nb_inputs(jobs: List<&2,P140NBJob>, blocked: List<&2,String>) -> List<&2,String>:
  match jobs:
    case Nil{}: blocked
    case Con{P140NBJob{source,output,hint,owner,warm},rest}: p140nb_inputs(rest,Con{source,blocked})

@unsafe
def p140nb_outputs(jobs: List<&2,P140NBJob>, +blocked: List<&2,String>, +used: List<&2,String>) -> Bool:
  match jobs:
    case Nil{}: True{}
    case Con{P140NBJob{source,+output,hint,owner,warm},rest}:
      Bool.not(has_name(blocked,output) || has_name(used,output)) && p140nb_outputs(rest,blocked,Con{output,used})

@unsafe
def p140nb_loop(+seed: P86Seed, +logical: String, jobs: List<&2,P140NBJob>, cache: P140NCache, ordinal: U32) -> IO(U32):
  match jobs:
    case Nil{}: IO.pure(U32,0)
    case Con{P140NBJob{source,output,hint,owner,warm},rest}:
      do IO<U32>:
        started : Nat <- IO.now()
        text : String <- p86_read_file(source)
        p140nb_source(started,seed,logical,rest,cache,ordinal,text,output,hint,owner,warm)

@unsafe
def p140nb_source(started: Nat, +seed: P86Seed, +logical: String, rest: List<&2,P140NBJob>, cache: P140NCache,
    ordinal: U32, +text: String, output: String, +relative: U32, owner: String, warm: Bool) -> IO(U32):
  match seed:
    case P86Seed{base,book,fresh,ready,world}:
      +begin = f_source_end(base)
      nt_choose(IO(U32),U32.is_le(relative,p86_width(text,0)) && U32.is_le(relative,U32.sub(4294967295,begin)),
        u => do IO<U32>:
          ready_time : Nat <- IO.now()
          result : P140NResult <- p140n_compile(seed,logical,text,cache,warm,U32.add(begin,relative),owner,output)
          p140nb_done(seed,logical,rest,ordinal,Nat.sub(ready_time,started),result),
        u => IO.die(U32,2,"batch hint exceeds source UTF16 span"))

@unsafe
def p140nb_done(seed: P86Seed, logical: String, rest: List<&2,P140NBJob>, +ordinal: U32, io_ms: Nat, result: P140NResult) -> IO(U32):
  match result:
    case P140NResult{cache,marks,stats}:
      do IO<U32>:
        Unit <- IO.print("phase140 batch " ++ U32.show(ordinal) ++ " io_ms=" ++ Nat.show(io_ms) ++ " stats=" ++ p140n_numbers(stats))
        Unit <- IO.print(p140n_line(U32.show(ordinal),marks))
        p140nb_loop(seed,logical,rest,cache,U32.inc(ordinal))

@unsafe
def p140nb_ready(started: Nat, logical: String, jobs: List<&2,P140NBJob>, prepared: P86Preparation) -> IO(U32):
  match prepared:
    case P86PreparationError{error}: IO.die(U32,1,error)
    case P86PreparationReady{seed}:
      do IO<U32>:
        ready : Nat <- IO.now()
        Unit <- IO.print("phase140 batch_prepare_ms " ++ Nat.show(Nat.sub(ready,started)))
        p140nb_loop(seed,logical,jobs,p140n_empty(),0)

@unsafe
def p140nb_checked(started: Nat, +logical: String, +base: String, +carrier: String, stamp: String,
    jobfile: String, parsed: P140NBJobs) -> IO(U32):
  match parsed:
    case P140NBError{error}: IO.die(U32,2,error)
    case P140NBReady{+jobs}:
      nt_choose(IO(U32),p140nb_outputs(jobs,p140nb_inputs(jobs,[logical,base,carrier,jobfile]),[]),
        u => do IO<U32>:
          base_text : String <- p86_read_file(base)
          carrier_text : String <- p86_read_file(carrier)
          p140nb_ready(started,logical,jobs,p88_cache_prepare(base,base_text,carrier_text,stamp)),
        u => IO.die(U32,2,"batch output aliases an input or earlier output"))

@unsafe
def p140nb_start(logical: String, base: String, carrier: String, stamp: String, +jobfile: String) -> IO(U32):
  do IO<U32>:
    started : Nat <- IO.now()
    jobs : String <- p86_read_file(jobfile)
    p140nb_checked(started,logical,base,carrier,stamp,jobfile,p140nb_parse(jobs))


@unsafe
def p140nb_controls() -> List<&2,String>:
  +one: String = "/a\n/out-a\n0\nowner\ncold"
  [p131u_row(U32.is_eq(p140nbc_count(p140nb_parse(one)),1),"batch-one-no-final-LF"),
   p131u_row(U32.is_eq(p140nbc_count(p140nb_parse(one ++ "\n")),1),"batch-one-final-LF"),
   p131u_row(U32.is_eq(p140nbc_count(p140nb_parse(one ++ "\n/b\n/out-b\n37\nother\nwarm\n")),2),"batch-two-jobs"),
   p131u_row(U32.is_eq(p140nbc_count(p140nb_parse("")),4294967295),"batch-empty-refused"),
   p131u_row(U32.is_eq(p140nbc_count(p140nb_parse("/a\n/out\n0\nowner")),4294967295),"batch-incomplete-refused"),
   p131u_row(U32.is_eq(p140nbc_count(p140nb_parse(one ++ "\n\n")),4294967295),"batch-extra-blank-refused"),
   p131u_row(U32.is_eq(p140nbc_count(p140nb_parse("/a\n/out\n00\nowner\nwarm")),4294967295),"batch-noncanonical-hint"),
   p131u_row(U32.is_eq(p140nbc_count(p140nb_parse("/a\n/out\n0\nowner\nunknown")),4294967295),"batch-policy-refused"),
   p131u_row(U32.is_eq(p140nbc_count(p140nb_parse("a\n/out\n0\nowner\nwarm")),4294967295),"batch-relative-input-refused"),
   p131u_row(U32.is_eq(p140nbc_count(p140nb_parse(one ++ "\r\n")),4294967295),"batch-CR-refused"),
   p131u_row(p140nbc_outputs(p140nb_parse(one)),"batch-disjoint-output"),
   p131u_row(Bool.not(p140nbc_outputs(p140nb_parse("/a\n/b\n0\none\ncold\n/b\n/out\n0\ntwo\nwarm"))),"batch-output-cannot-clobber-later-input"),
   p131u_row(Bool.not(p140nbc_outputs(p140nb_parse(one ++ "\n/b\n/out-a\n0\nother\nwarm"))),"batch-repeated-output-refused"),
   p131u_row(Bool.not(p140nbc_outputs(p140nb_parse("/a\n/carrier\n0\nowner\nwarm"))),"batch-output-carrier-refused")]
