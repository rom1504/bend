# Source-only fallback: not selected by modules.txt or the current entry.
# Keep all admission gates before the first byte, then consume one output unit.
@unsafe
def p111s_print_data(tables: List<&2,P111QData>) -> IO(U32):
  match tables:
    case Nil{}:
      do IO<U32>:
        Unit <- IO.print(p111q_main())
        IO.pure(U32,0)
    case Con{head,rest}:
      do IO<U32>:
        Unit <- IO.print(p111q_data(head))
        p111s_print_data(rest)

@unsafe
def p111s_print_segments(segments: List<&2,N111Segment>, +ids: N111Ids, tables: List<&2,P111QData>) -> IO(U32):
  match segments:
    case Nil{}: p111s_print_data(tables)
    case Con{head,rest}:
      do IO<U32>:
        Unit <- IO.print(p111q_segment(head,ids))
        p111s_print_segments(rest,ids,tables)

# Affine program ownership matters: the print continuation must not retain the
# outer program or already emitted bodies. Detached tables contain no bodies.
@unsafe
def p111s_print_ready(program: P111Program, ids: N111Ids, tables: List<&2,P111QData>) -> IO(U32):
  match program:
    case P111Program{segments,constructors,show,show_names,effects,pure}:
      p111s_print_segments(segments,ids,tables)

@unsafe
def p111s_print_indexed(+program: P111Program, +ids: N111Ids) -> IO(U32):
  p111s_print_ready(program,ids,p111q_tables(program,ids))

@unsafe
def p111s_print_verified(+program: P111Program, +error: String) -> IO(U32):
  nt_choose(IO(U32),String.is_empty(error),u => p111s_print_indexed(program,p111q_ids(program)),
    u => IO.die(U32,1,"structured IR: " ++ error))

@unsafe
def p111s_print_lowered(result: P111Result) -> IO(U32):
  match result:
    case P111Result{+program,+error}:
      nt_choose(IO(U32),String.is_empty(error),u => p111s_print_verified(program,p111_verify_program(program)),
        u => IO.die(U32,1,"native lowering: " ++ error))

@unsafe
def p111s_print_admitted(+request: NR_Request, +error: String) -> IO(U32):
  nt_choose(IO(U32),String.is_empty(error),u => p111s_print_lowered(p111_lower_request(request)),
    u => IO.die(U32,1,"compile: " ++ error))

@unsafe
def p111s_print_plan(plan: P86Plan) -> IO(U32):
  match plan:
    case P86PlanError{error}: IO.die(U32,1,error)
    case P86PlanReady{+request,verdict}: p111s_print_admitted(request,p111_runtime_admission(request))

@unsafe
def p111s_compile_prepared(+path: String, +source: String, prepared: P86Preparation) -> IO(U32):
  match prepared:
    case P86PreparationError{error}: IO.die(U32,1,error)
    case P86PreparationReady{seed}: p111s_print_plan(p86_plan(seed,path,source))

@unsafe
def p111s_compile_source(+path: String, +source: String, +base_path: String, +base: String,
  +carrier: String, +stamp: String, +cached: Bool) -> IO(U32):
  p111s_compile_prepared(path,source,nt_choose(P86Preparation,cached,
    u => p88_cache_prepare(base_path,base,carrier,stamp),u => p86_prepare(base_path,base)))

@unsafe
def p111s_native_request(+path: String, +base_path: String, +cache_path: String,
  +stamp: String, +cached: Bool) -> IO(U32):
  do IO<U32>:
    +source : String <- p86_read_file(path)
    +base : String <- p86_read_file(base_path)
    nt_choose(IO(U32),cached,
      u => do IO<U32>:
        carrier : String <- p86_read_file(cache_path)
        p111s_compile_source(path,source,base_path,base,carrier,stamp,True{}),
      u => p111s_compile_source(path,source,base_path,base,"","",False{}))
