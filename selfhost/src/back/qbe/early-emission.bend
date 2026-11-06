

# Renderer-only callable metadata experiment. The semantic program remains
# private and must pass p167ob_final unchanged before this copy is constructed.
# Only an actual authenticated adapter can grant a public renderer signature.

@unsafe
def p168v_callable(+name: String, arity: U32, result: U32, +entry: KDef) -> Bool:
  String.eq(dk(entry),"P164Adapter") && String.eq(dn(entry),name) &&
    String.eq(tg(dt(entry)),"Ref") && U32.is_eq(da(entry),arity) &&
    U32.is_eq(dx(entry),0) && U32.is_eq(result,1)



@unsafe
def p168v_functions(functions: List<&2,P113DFunction>, +adapters: KDef) -> List<&2,P113DFunction>:
  match functions:
    case Nil{}: []
    case Con{P113DFunction{+name,+params,+result,public,body},rest}:
      Con{P113DFunction{name,params,result,
        p168v_callable(name,nt_count(NC_Binding,params),result,p111v_get(adapters,name)),body},
        p168v_functions(rest,adapters)}



# Metadata failure cannot be repaired by any direct-map entry. Avoid its name
# hash and lookup entirely, instead of relying on eager Bool conjunction.
@unsafe
def p168j_eligible(segment: N111Segment, +direct: KDef) -> Bool:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,body}:
      nt_choose(Bool,p169q_metadata(arity,result,incoming,flags),
        u => p169q_import(name,arity,direct),u => False{})



@unsafe
def p168j_insert(segment: N111Segment, registry: P112RegionRegistry) -> P112RegionRegistry:
  match segment registry:
    case N111Segment{+name,+arity,result,incoming,flags,body} P112RegionRegistry{ready,symbols,entries,workers,fusions}:
      P112RegionRegistry{p111v_put(ready,name,"P112Worker",arity,0),
        p111v_put(symbols,p112w_symbol(name),"P112RegionSymbol",arity,0),entries,U32.inc(workers),fusions}



@unsafe
def p168j_imports(segments: List<&2,N111Segment>, +direct: KDef, +registry: P112RegionRegistry) -> P112RegionRegistry:
  match segments:
    case Nil{}: registry
    case Con{+head,rest}:
      p168j_imports(rest,direct,nt_choose(P112RegionRegistry,p168j_eligible(head,direct),
        u => p168j_insert(head,registry),u => registry))



@unsafe
def p168j_candidates(segments: List<&2,N111Segment>, +imports: KDef,
    +acc: List<&2,P112MultiCandidate>) -> List<&2,P112MultiCandidate>:
  match segments:
    case Nil{}: nt_reverse(P112MultiCandidate,acc,[])
    case Con{+segment,+rest}:
      match segment:
        case N111Segment{+name,arity,result,incoming,flags,body}:
          nt_choose(List<&2,P112MultiCandidate>,p169q_metadata(arity,result,incoming,flags),
            u => nt_choose(List<&2,P112MultiCandidate>,p112w_ready(imports,name),
              v => p168j_candidates(rest,imports,acc),
              v => nt_choose(List<&2,P112MultiCandidate>,p112c_candidate(segment),
                w => p168j_candidates(rest,imports,Con{P112MultiCandidate{segment},acc}),
                w => p168j_candidates(rest,imports,acc))),
            u => p168j_candidates(rest,imports,acc))



@unsafe
def p168j_registry(segments: List<&2,N111Segment>, +index: P112FusionIndex,
    +registry: P112RegionRegistry) -> P112RegionRegistry:
  match registry:
    case P112RegionRegistry{ready,symbols,entries,workers,fusions}:
      p112c_passes(p168j_candidates(segments,ready,[]),index,registry,1,6)



@unsafe
def p168j_forward(+name: String, +arity: U32) -> String:
  "function l $" ++ p112w_symbol(name) ++ "(" ++ p112w_call_args(arity,0,"l %state") ++ ") {\n@entry\n" ++
  "%p164_forward =l call $" ++ p113e_symbol(name) ++ "(" ++ p112w_call_args(arity,0,"l %state") ++ ")\nret %p164_forward\n}\n"



@unsafe
def p168j_forward_if(function: P113DFunction, ready: KDef) -> String:
  match function:
    case P113DFunction{+name,+params,result,public,body}:
      +entry = p111v_get(ready,name)
      nt_choose(String,String.eq(dk(entry),"P112Worker") && U32.is_eq(dx(entry),0),
        u => p168j_forward(name,nt_count(NC_Binding,params)),u => "")



@unsafe
def p168j_forwards(functions: List<&2,P113DFunction>, +ready: KDef,
    acc: List<&2,String>) -> List<&2,String>:
  match functions:
    case Nil{}: nt_reverse(String,acc,[])
    case Con{head,rest}: p168j_forwards(rest,ready,Con{p168j_forward_if(head,ready),acc})


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



# Sole override. Keep actual source/generic/static/adapter/private and complete
# borrowed/direct verification. Extra namespace checks precede mode2 emission.
@unsafe
def p169s_lowered(+request: NR_Request, lowered: P167Lowered) -> P169Prepared:
  match request lowered:
    case NR_Request{source,+book,names,paths,scope,bound} P167Lowered{+program,+adapters,+error,stats}:
      nt_choose(P169Prepared,String.is_empty(error),
        u => p169a_original(request,adapters,program,
          p167v_original(book,nc_bangs_names(book,names),program,adapters)),
        u => p169s_fail("adapter renderer lowering: " ++ error))



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


# Optional private Phase169 successor: original/static/adapter admission and
# private-input discipline stay unchanged. The SAME flag-only renderer view
# receives the full unchanged borrowed/direct body verifier exactly once.
# Public flags only add the existing original-wrapper ABI obligation; body
# projection and dependency-call contracts do not consume signature public bits.
# No producer certificate, body hash or trusted Boolean replaces verification.

@unsafe
def p169sv_refused(+view_error: String, +original_error: String) -> P169Prepared:
  nt_choose(P169Prepared,String.is_empty(original_error),
    u => p169s_fail("adapter imports view verification: " ++ view_error),
    u => p169s_fail("adapter renderer original final IR: " ++ original_error))


# Optional restoration of the maintained source-authorized mode2 renderer.
# The actual request derives its certificate; no workload/name selects a mode.

@unsafe
def p169a_seeded(+program: P111Program, +nodes: List<&2,P112SNode>,
    +functions: List<&2,P113DFunction>, +live: Bool, arrays: Bool) -> P169Prepared:
  match program:
    case P111Program{+segments,constructors,show,names,effects,pure}:
      +enabled = arrays && Bool.not(List.is_empty(&2,P113DFunction,functions))
      +ids = p111q_ids(program)
      +index = p112f_index(segments)
      +tables = nt_choose(List<&2,P111QData>,List.is_empty(&2,P112SNode,nodes),
        u => p111q_tables(program,ids),u => p112s_tables(program,nodes,ids))
      +mode = nt_choose(U32,List.is_empty(&2,P113DFunction,functions),u => 0,
        u => nt_choose(U32,enabled,v => 2,v => 1))
      +tables = nt_choose(List<&2,P111QData>,enabled,u => p117p_tables(tables,[]),u => tables)
      +tables = nt_choose(List<&2,P111QData>,live,u => p118z_tables(tables),u => tables)
      p169s_registered(segments,functions,ids,index,p113a_heap_min(nodes),mode,p118c_tables(tables),
        p168j_registry(segments,index,p168j_imports(segments,p113e_signatures(functions,missing()),
          P112RegionRegistry{missing(),missing(),[],0,0})))



@unsafe
def p169a_namespace(+original: P111Program, +nodes: List<&2,P112SNode>,
    +view: List<&2,P113DFunction>, +certificate: P113ACertificate) -> String:
  +direct : P113DProgram = P113DProgram{P112StaticProgram{original,nodes},view}
  p114t_verify_done(P113AProgram{direct,certificate},p113a_verify_after(direct,certificate,""))



# The certificate is constructed by unchanged p169a_view from this exact
# request. scalar=False implies p118c_plan's ns_definitions permission=False;
# skip only that redundant failed derivation. unshared is not cold authority.
@unsafe
def p169a_checked(+request: NR_Request, +adapters: KDef, +program: P113DProgram,
    +original: P111Program, +nodes: List<&2,P112SNode>, +view: List<&2,P113DFunction>,
    +certificate: P113ACertificate, +error: String) -> P169Prepared:
  match request:
    case NR_Request{source,+book,+names,paths,scope,bound}:
      nt_choose(P169Prepared,String.is_empty(error),
        u => p169c_emitted(request,P113AProgram{P113DProgram{P112StaticProgram{original,nodes},view},certificate},
          p167live_eligible(program),nt_choose(String,p113a_enabled(certificate),
            v => p169a_namespace(original,nodes,view,certificate),v => "")),
        u => p169sv_refused(error,p167ob_final(book,nc_bangs_names(book,names),adapters,program)))



@unsafe
def p169a_view(+request: NR_Request, +adapters: KDef, +program: P113DProgram) -> P169Prepared:
  match program:
    case P113DProgram{P112StaticProgram{+original,+nodes},functions}:
      +view = p168v_functions(functions,adapters)
      p169a_checked(request,adapters,program,original,nodes,view,p113a_certificate(request),
        p118b_verify_functions(view,original))



@unsafe
def p169a_original(request: NR_Request, adapters: KDef, +program: P113DProgram,
    +error: String) -> P169Prepared:
  match program:
    case P113DProgram{original,+functions}:
      nt_choose(P169Prepared,String.is_empty(error),u =>
        nt_choose(P169Prepared,p167v_private(functions),
          v => p169a_view(request,adapters,program),
          v => p169s_fail("adapter renderer original final IR: observer first final worker must be private")),
        u => p169s_fail("adapter renderer original final IR: " ++ error))


# Optional same-request cold metadata restoration after the existing full
# verifier and array/transport namespace gates. No emitted body or ID changes.
@unsafe
def p169c_scalar(certificate: P113ACertificate) -> Bool:
  match certificate:
    case P113ACertificate{scalar,unshared}: scalar



@unsafe
def p169c_selected(+request: NR_Request, +admitted: P113AProgram) -> P113AProgram:
  match admitted:
    case P113AProgram{program,certificate}:
      nt_choose(P113AProgram,p169c_scalar(certificate),
        u => p118c_apply_plan(admitted,p118c_plan(request)),u => admitted)



@unsafe
def p169c_output(admitted: P113AProgram, +live: Bool) -> P169Prepared:
  match admitted:
    case P113AProgram{P113DProgram{P112StaticProgram{+original,+nodes},+view},certificate}:
      nt_choose(P169Prepared,p113a_enabled(certificate),
        u => p169a_seeded(original,nodes,view,live,True{}),
        u => p169s_seeded(original,nodes,view,live))



@unsafe
def p169c_emitted(request: NR_Request, admitted: P113AProgram, live: Bool,
    +error: String) -> P169Prepared:
  nt_choose(P169Prepared,String.is_empty(error),
    u => p169c_output(p169c_selected(request,admitted),live),
    u => p169s_fail("adapter imports view verification: " ++ error))
