# Wave 8: Pure-Bend live build tracing & stage profiler (`--trace`).
# Uses native IO.now() and IO.print_err() effects; stdout .o bytes are untouched.

@unsafe
def w8_tr_ms(t0: Nat, t1: Nat) -> String:
  Nat.show(Nat.sub(t1,t0)) ++ "ms"

@unsafe
def w8_tr_log(+enabled: Bool, +msg: String) -> IO(Unit):
  nt_choose(IO(Unit),enabled,
    u => IO.print_err("[bend-trace] " ++ msg ++ "\n"),
    u => IO.pure(Unit,Unit{}))

@unsafe
def w8_tr_compile_done(+trace: Bool, +t2: Nat, +t3: Nat, prepared: P169Prepared) -> IO(P169Prepared):
  match prepared:
    case P169Prepared{fw,+cur,+err}:
      do IO<P169Prepared>:
        +segs : U32 = w8_cursor_seg_count(cur)
        _ : Unit <- w8_tr_log(trace,"stage=x198pw_plan ms=" ++ w8_tr_ms(t2,t3) ++ " segs=" ++ U32.show(segs))
        IO.pure(P169Prepared,P169Prepared{fw,cur,err})

@unsafe
def w8_tr_compile_prep(+trace: Bool, +path: String, +source: String, +t1: Nat, prep: P86Preparation) -> IO(P169Prepared):
  match prep:
    case P86PreparationError{error}:
      do IO<P169Prepared>:
        _ : Unit <- w8_tr_log(trace,"stage=prep_error msg=" ++ error)
        IO.pure(P169Prepared,p169s_fail(error))
    case P86PreparationReady{seed}:
      do IO<P169Prepared>:
        +plan : P86Plan <- IO.pure(P86Plan,p86_plan(seed,path,source))
        +t2 : Nat <- IO.now()
        _ : Unit <- w8_tr_log(trace,"stage=p86_plan ms=" ++ w8_tr_ms(t1,t2))
        +prepared : P169Prepared <- IO.pure(P169Prepared,x198pw_plan(plan))
        +t3 : Nat <- IO.now()
        w8_tr_compile_done(trace,t2,t3,prepared)

@unsafe
def w8_tr_compile(+trace: Bool, +path: String, +source: String, +base_path: String,
    +base: String, +carrier: String, +stamp: String, +cached: Bool) -> IO(P169Prepared):
  do IO<P169Prepared>:
    +t0 : Nat <- IO.now()
    +prep : P86Preparation <- IO.pure(P86Preparation,
      nt_choose(P86Preparation,cached,
        u => p88_cache_prepare(base_path,base,carrier,stamp),
        u => p86_prepare(base_path,base)))
    +t1 : Nat <- IO.now()
    _ : Unit <- w8_tr_log(trace,"stage=prep ms=" ++ w8_tr_ms(t0,t1))
    w8_tr_compile_prep(trace,path,source,t1,prep)

@unsafe
def w8_tr_emit_cursor(+trace: Bool, +fast: Bool, +is_mod: Bool, +t_start: Nat,
    +cursor: P134Cursor, +avail: KDef, +build: X187Build, +priv_n: U32, +pub_n: U32, +total_segs: U32) -> IO(U32):
  nt_choose(IO(U32),String.is_empty(x187_build_message(build)),
    u => w8_tr_emit_good(trace,fast,is_mod,t_start,cursor,avail,build,priv_n,pub_n,total_segs),
    u => IO.die(U32,1,x187_build_message(build)))

@unsafe
def w8_tr_emit_priv(+trace: Bool, +fast: Bool, +is_mod: Bool, +t_start: Nat,
    +head: P113DFunction, rest: List<&2,P113DFunction>, +ctx: P134Context, next: P134Cursor,
    +avail: KDef, +build: X187Build, +priv_n: U32, +pub_n: U32, +total_segs: U32) -> IO(U32):
  do IO<U32>:
    +out : X181Output = nt_choose(X181Output,fast,
      u => x181_program_private_fast(head,ctx,avail),
      u => x181_program_private(head,ctx,avail))
    +b2 : X187Build = x187_output(out,build)
    +n2 : U32 = U32.inc(priv_n)
    _ : Unit <- nt_choose(IO(Unit),trace && U32.is_eq(U32.mod(n2,500),0),
      u => do IO<Unit>:
        +tn : Nat <- IO.now()
        w8_tr_log(True{},"stage=x187_priv done=" ++ U32.show(n2) ++ " elapsed=" ++ w8_tr_ms(t_start,tn)),
      u => IO.pure(Unit,Unit{}))
    w8_tr_emit_cursor(trace,fast,is_mod,t_start,P134Private{rest,ctx,next},avail,b2,n2,pub_n,total_segs)

@unsafe
def w8_tr_emit_pub(+trace: Bool, +fast: Bool, +is_mod: Bool, +t_start: Nat,
    +head: N111Segment, rest: List<&2,N111Segment>, +ctx: P134Context, next: P134Cursor,
    +avail: KDef, +build: X187Build, +priv_n: U32, +pub_n: U32, +total_segs: U32) -> IO(U32):
  do IO<U32>:
    +out : X181Output = nt_choose(X181Output,fast,
      u => x181_program_public_fast(head,ctx,avail),
      u => x181_program_public(head,ctx,avail))
    +b2 : X187Build = x187_output(out,build)
    +n2 : U32 = U32.inc(pub_n)
    _ : Unit <- nt_choose(IO(Unit),trace && U32.is_eq(U32.mod(n2,2000),0),
      u => do IO<Unit>:
        +tn : Nat <- IO.now()
        w8_tr_log(True{},"stage=x187_pub done=" ++ U32.show(n2) ++ "/" ++ U32.show(total_segs) ++ " elapsed=" ++ w8_tr_ms(t_start,tn)),
      u => IO.pure(Unit,Unit{}))
    w8_tr_emit_cursor(trace,fast,is_mod,t_start,P134Public{rest,ctx,next},avail,b2,priv_n,n2,total_segs)

@unsafe
def w8_tr_emit_good(+trace: Bool, +fast: Bool, +is_mod: Bool, +t_start: Nat,
    +cursor: P134Cursor, +avail: KDef, +build: X187Build, +priv_n: U32, +pub_n: U32, +total_segs: U32) -> IO(U32):
  match cursor:
    case P134Private{Nil{},ctx,next}:
      do IO<U32>:
        +tn : Nat <- IO.now()
        _ : Unit <- w8_tr_log(trace,"stage=x187_priv_done count=" ++ U32.show(priv_n) ++ " elapsed=" ++ w8_tr_ms(t_start,tn))
        w8_tr_emit_cursor(trace,fast,is_mod,t_start,next,avail,build,priv_n,pub_n,total_segs)
    case P134Private{Con{head,rest},ctx,next}:
      w8_tr_emit_priv(trace,fast,is_mod,t_start,head,rest,ctx,next,avail,build,priv_n,pub_n,total_segs)
    case P134Legacy{es,ctx,next}:
      w8_tr_emit_cursor(trace,fast,is_mod,t_start,next,avail,build,priv_n,pub_n,total_segs)
    case P134Public{Nil{},ctx,next}:
      do IO<U32>:
        +tn : Nat <- IO.now()
        _ : Unit <- w8_tr_log(trace,"stage=x187_pub_done count=" ++ U32.show(pub_n) ++ " elapsed=" ++ w8_tr_ms(t_start,tn))
        w8_tr_emit_cursor(trace,fast,is_mod,t_start,next,avail,build,priv_n,pub_n,total_segs)
    case P134Public{Con{head,rest},ctx,next}:
      w8_tr_emit_pub(trace,fast,is_mod,t_start,head,rest,ctx,next,avail,build,priv_n,pub_n,total_segs)
    case P134Tables{Nil{}}:
      w8_tr_emit_cursor(trace,fast,is_mod,t_start,P134Main{},avail,build,priv_n,pub_n,total_segs)
    case P134Tables{Con{head,rest}}:
      w8_tr_emit_cursor(trace,fast,is_mod,t_start,P134Tables{rest},avail,x187_output(x181_program_data(head,avail),build),priv_n,pub_n,total_segs)
    case P134Main{}:
      do IO<U32>:
        +t_elf0 : Nat <- IO.now()
        +b_fin : X187Build = nt_choose(X187Build,is_mod,u => build,u => x187_build_seq(x181_program_main(),build))
        +rc : U32 <- x202p_x201f_finish(b_fin)
        +t_elf1 : Nat <- IO.now()
        _ : Unit <- w8_tr_log(trace,"stage=x187_elf ms=" ++ w8_tr_ms(t_elf0,t_elf1) ++ " total_ms=" ++ w8_tr_ms(t_start,t_elf1))
        IO.pure(U32,rc)
    case _: IO.die(U32,1,"incomplete object cursor")

@unsafe
def w8_tr_run_prepared(+trace: Bool, +fast: Bool, +is_mod: Bool, +fid_base: U32, +mod_name: String,
    +t0: Nat, prepared: P169Prepared) -> IO(U32):
  match prepared:
    case P169Prepared{fw,+cursor,+error}:
      nt_choose(IO(U32),String.is_empty(error),
        u => do IO<U32>:
          +avail : KDef = x181_cursor_index(cursor,missing())
          +segs : U32 = w8_cursor_seg_count(cursor)
          nt_choose(IO(U32),is_mod && U32.is_gt(U32.add(fid_base,segs),65532),
            v => IO.die(U32,1,"x86-module: fid_base + segment_count exceeds 16-bit FID capacity (65532)"),
            v => do IO<U32>:
              +enr : P134Cursor = agy_enrich_cursor(cursor,avail)
              +cur2 : P134Cursor = nt_choose(P134Cursor,is_mod,w => w8_relocate_cursor(enr,fid_base,mod_name),w => enr)
              w8_tr_emit_cursor(trace,fast,is_mod,t0,cur2,avail,x187_build_empty(),0,0,segs)),
        u => IO.die(U32,1,error))

@unsafe
def w8_tr_run_obj(+trace: Bool, +fast: Bool, +is_mod: Bool, +fid_base: U32, +mod_name: String,
    +path: String, +base_path: String, +carrier_path: String, +stamp: String, +cached: Bool) -> IO(U32):
  do IO<U32>:
    +t0 : Nat <- IO.now()
    _ : Unit <- w8_tr_log(trace,"start src=" ++ path ++ nt_choose(String,is_mod,u => " mode=x86-module mod=" ++ mod_name ++ " fid_base=" ++ U32.show(fid_base),u => nt_choose(String,fast,v => " mode=x86-object-fast",v => " mode=x86-object")))
    +source : String <- p86_read_file(path)
    +base : String <- p86_read_file(base_path)
    +carrier : String <- nt_choose(IO(String),cached,u => p86_read_file(carrier_path),u => IO.pure(String,""))
    +t_rd : Nat <- IO.now()
    _ : Unit <- w8_tr_log(trace,"stage=read ms=" ++ w8_tr_ms(t0,t_rd))
    +prepared : P169Prepared <- w8_tr_compile(trace,path,source,base_path,base,carrier,stamp,cached)
    w8_tr_run_prepared(trace,fast,is_mod,fid_base,mod_name,t0,prepared)

@unsafe
def w8_tr_mod_fid(fid_m: Maybe<&2,U32>, +mod_name: String, +path: String, +base: String,
    +carrier: String, +stamp: String, +cached: Bool) -> IO(U32):
  match fid_m:
    case Some{+fb}: w8_tr_run_obj(True{},False{},True{},fb,mod_name,path,base,carrier,stamp,cached)
    case _: IO.die(U32,2,"expected U32 fid_base argument")

@unsafe
def w8_tr_entry(+args: List<&1,String>) -> IO(U32):
  match args:
    case Con{+program,Con{+path,Con{+base,Con{+mode,Con{+carrier,Con{+stamp,Nil{}}}}}}}:
      nt_choose(IO(U32),(agy_str_eq(program,"x86-object") || agy_str_eq(program,"x86-object-fast")) && String.starts_with(path,"/") &&
        String.starts_with(base,"/") &&
        (agy_str_eq(mode,"live") || (agy_str_eq(mode,"cache") && String.starts_with(carrier,"/"))),
        u => w8_tr_run_obj(True{},agy_str_eq(program,"x86-object-fast"),False{},0,"",path,base,carrier,stamp,agy_str_eq(mode,"cache")),
        u => x181_entry_args(args))
    case Con{+program,Con{+path,Con{+base,Con{+mode,Con{+carrier,Con{+stamp,Con{+fid_s,Con{+mod_name,Nil{}}}}}}}}}:
      nt_choose(IO(U32),agy_str_eq(program,"x86-module") && String.starts_with(path,"/") &&
        String.starts_with(base,"/") &&
        (agy_str_eq(mode,"live") || (agy_str_eq(mode,"cache") && String.starts_with(carrier,"/"))),
        u => w8_tr_mod_fid(U32.read(fid_s),mod_name,path,base,carrier,stamp,agy_str_eq(mode,"cache")),
        u => x181_entry_args(args))
    case _: x181_entry_args(args)
