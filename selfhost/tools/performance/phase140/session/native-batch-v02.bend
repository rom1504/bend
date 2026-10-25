# Five LF lines per job: physical source, output frame, relative UTF16 hint,
# semantic owner, warm|cold. At most64 jobs; a final LF is optional.
type P140NBJob is Data:
  P140NBJob{+source: String, +output: String, +hint: U32, +owner: String, +warm: Bool}
type P140NBJobs is Data:
  P140NBError{+error: String}
  P140NBReady{+jobs: List<&2,P140NBJob>}

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
