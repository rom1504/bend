# Exact Phase168 import-seeded emission preparation, with text left in the
# maintained cursor until IO consumes it. This record is not a certificate:
# normal entry constructs it only after both unchanged actual-program gates.
type P169Prepared is Data:
  P169Prepared{+forwarders: List<&2,String>, +cursor: P134Cursor, +error: String}

@unsafe
def p169s_fail(error: String) -> P169Prepared:
  P169Prepared{[],P134End{},error}

@unsafe
def p169s_registered(+segments: List<&2,N111Segment>, +functions: List<&2,P113DFunction>,
    ids: N111Ids, index: P112FusionIndex, heap: U32, mode: U32,
    tables: List<&2,P111QData>, +registry: P112RegionRegistry) -> P169Prepared:
  match registry:
    case P112RegionRegistry{ready,symbols,entries,workers,fusions}:
      P169Prepared{p168j_forwards(functions,ready,[]),
        p134e_registered(segments,functions,ids,index,heap,mode,tables,registry),""}

# Same ids, full fusion index, seeded discovery and capabilities as p168j_seeded.
# Only p134e_collect_cursor has moved out of the preparation boundary.
@unsafe
def p169s_seeded(+program: P111Program, +nodes: List<&2,P112SNode>,
    +functions: List<&2,P113DFunction>, live: Bool) -> P169Prepared:
  match program:
    case P111Program{+segments,constructors,show,names,effects,pure}:
      +ids = p111q_ids(program)
      +index = p112f_index(segments)
      +tables = nt_choose(List<&2,P111QData>,List.is_empty(&2,P112SNode,nodes),
        u => p111q_tables(program,ids),u => p112s_tables(program,nodes,ids))
      +mode = nt_choose(U32,List.is_empty(&2,P113DFunction,functions),u => 0,u => 1)
      +tables = nt_choose(List<&2,P111QData>,live,u => p118z_tables(tables),u => tables)
      p169s_registered(segments,functions,ids,index,p113a_heap_min(nodes),mode,p118c_tables(tables),
        p168j_registry(segments,index,p168j_imports(segments,p113e_signatures(functions,missing()),
          P112RegionRegistry{missing(),missing(),[],0,0})))

@unsafe
def p169s_checked(original: P111Program, nodes: List<&2,P112SNode>,
    functions: List<&2,P113DFunction>, live: Bool, +error: String) -> P169Prepared:
  nt_choose(P169Prepared,String.is_empty(error),
    u => p169s_seeded(original,nodes,functions,live),
    u => p169s_fail("adapter imports view verification: " ++ error))

@unsafe
def p169s_view(+program: P113DProgram, adapters: KDef) -> P169Prepared:
  match program:
    case P113DProgram{P112StaticProgram{+original,nodes},functions}:
      +view = p168v_functions(functions,adapters)
      p169s_checked(original,nodes,view,p167live_eligible(program),p118b_verify_functions(view,original))

@unsafe
def p169s_verified(program: P113DProgram, adapters: KDef, +error: String) -> P169Prepared:
  nt_choose(P169Prepared,String.is_empty(error),u => p169s_view(program,adapters),
    u => p169s_fail("adapter renderer original final IR: " ++ error))

@unsafe
def p169s_lowered(request: NR_Request, lowered: P167Lowered) -> P169Prepared:
  match request lowered:
    case NR_Request{source,+book,+names,paths,scope,bound} P167Lowered{+program,+adapters,+error,stats}:
      nt_choose(P169Prepared,String.is_empty(error),
        u => p169s_verified(program,adapters,
          p167ob_final(book,nc_bangs_names(book,names),adapters,program)),
        u => p169s_fail("adapter renderer lowering: " ++ error))

@unsafe
def p169s_admitted(+request: NR_Request, +error: String) -> P169Prepared:
  nt_choose(P169Prepared,String.is_empty(error),
    u => p169s_lowered(request,p168_request_mode(1,request)),
    u => p169s_fail("adapter renderer runtime: " ++ error))

@unsafe
def p169s_plan(plan: P86Plan) -> P169Prepared:
  match plan:
    case P86PlanError{error}: p169s_fail(error)
    case P86PlanReady{+request,verdict}: p169s_admitted(request,p111_runtime_admission(request))

# Hosted equality gate only: this deliberately materializes the old exact chunks.
@unsafe
def p169s_collect(prepared: P169Prepared) -> P111Emission:
  match prepared:
    case P169Prepared{forwarders,cursor,+error}:
      nt_choose(P111Emission,String.is_empty(error),
        u => P111Emission{nt_append(String,forwarders,p134e_collect_cursor(cursor,[],[])),""},
        u => P111Emission{[],error})

@unsafe
def p169s_collect_plan(plan: P86Plan) -> P111Emission:
  p169s_collect(p169s_plan(plan))

@unsafe
def p169s_prefix_written(pair: File & Result<&1,&1,U32 & String,Unit>,
    rest: List<&2,String>, cursor: P134Cursor) -> IO(U32):
  (file,result) = pair
  match result:
    case Done{unit}: p169s_prefix(file,rest,cursor)
    case Fail{error}:
      do IO<U32>:
        Unit <- File.close(file)
        IO.pass(U32,Fail{error})

@unsafe
def p169s_prefix(file: File, chunks: List<&2,String>, cursor: P134Cursor) -> IO(U32):
  match chunks:
    case Nil{}: p134w_drain(file,cursor)
    case Con{head,rest}:
      do IO<U32>:
        pair : File & Result<&1,&1,U32 & String,Unit> <- File.write(file,head ++ "\n")
        p169s_prefix_written(pair,rest,cursor)

# One File owns both prefix and cursor output: mixing buffered IO.print with
# descriptor writes could reorder bytes. Preserve the old exact line boundaries.
# The large compiler body is rendered/written by the existing cursor IO chain.
@unsafe
def p169s_print(prepared: P169Prepared) -> IO(U32):
  match prepared:
    case P169Prepared{forwarders,cursor,+error}:
      nt_choose(IO(U32),String.is_empty(error),u => do IO<U32>:
        file : File <- IO.try(File,File.open("/dev/stdout","a"))
        p169s_prefix(file,forwarders,cursor),u => IO.die(U32,1,error))

@unsafe
def p169s_error_control(emission: P111Emission) -> Bool:
  match emission:
    case P111Emission{chunks,error}:
      List.is_empty(&2,String,chunks) && String.eq(error,"stream-control")
    case _: False{}

@unsafe
def p169s_controls() -> List<&2,String>:
  [nt_choose(String,p169s_error_control(p169s_collect_plan(P86PlanError{"stream-control"})),
     u => "stream-plan-error:pass",u => "stream-plan-error:FAIL"),
   nt_choose(String,p169s_error_control(p169s_collect(P169Prepared{["must-not-emit"],P134Main{},"stream-control"})),
     u => "stream-error-discards-prefix-and-cursor:pass",u => "stream-error-discards-prefix-and-cursor:FAIL")]
