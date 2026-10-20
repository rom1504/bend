# Compose with the frozen facts renderer. It keeps private definitions for
# fallback public segments even when the first public segment is replaced.
@unsafe
def p113e_public_chunks(segments: List<&2,N111Segment>, +direct: KDef, +index: P112FusionIndex, +ids: N111Ids, +ready: KDef, acc: List<&2,String>) -> List<&2,String>:
  match segments:
    case Nil{}: nt_reverse(String,acc,[])
    case Con{segment,rest}: p113e_public_chunks(rest,direct,index,ids,ready,Con{p113e_public_chunk(segment,direct,index,ids,ready),acc})

@unsafe
def p113e_public_chunk(+segment: N111Segment, +direct: KDef, +index: P112FusionIndex, +ids: N111Ids, +ready: KDef) -> String:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,body}:
      +function = p111v_get(direct,name)
      nt_choose(String,String.eq(dk(function),"P113Direct") && U32.is_eq(ix(dv(function)),1),
        u => p113e_public(name,arity),u => p112f_public(segment,ids,ready,p112c_plan_index(segment,index,ready)))

# Generic/fused callers already invoke qualified p112w private symbols. Keep
# that ABI and forward scalar-compatible entries to the new complete function,
# so those existing callers cannot silently bypass the new implementation.
@unsafe
def p113e_old_private(+segment: N111Segment, +plan: P112WorkerPlan, +direct: KDef, +ids: N111Ids) -> String:
  match segment plan:
    case N111Segment{+name,arity,result,incoming,flags,body} P112WorkerPlan{valid,calls,+params,nodes}:
      +function = p111v_get(direct,name)
      nt_choose(String,valid && String.eq(dk(function),"P113Direct") && U32.is_eq(ix(dv(function)),1) && U32.is_eq(da(function),nt_count(String,params)),
        u => "function l $" ++ p112w_symbol(name) ++ "(" ++ p112w_formals(params,"l %state") ++ ") {\n@entry\n%p113_forward =l call $" ++ p113e_symbol(name) ++ "(" ++ p112w_formals(params,"l %state") ++ ")\nret %p113_forward\n}\n",
        u => p112w_private(segment,ids,plan))

@unsafe
def p113e_old_private_chunks(entries: List<&2,P112RegionEntry>, +direct: KDef, +ids: N111Ids, acc: List<&2,String>) -> List<&2,String>:
  match entries:
    case Nil{}: acc
    case Con{P112RegionEntry{segment,plan,rank,sites},rest}: p113e_old_private_chunks(rest,direct,ids,Con{p113e_old_private(segment,plan,direct,ids),acc})

@unsafe
def p113e_registered(+segments: List<&2,N111Segment>, +functions: List<&2,P113DFunction>, +index: P112FusionIndex, +ids: N111Ids, registry: P112RegionRegistry) -> List<&2,String>:
  match registry:
    case P112RegionRegistry{ready,symbols,entries,workers,fusions}:
      +direct = p113e_signatures(functions,missing())
      nt_append(String,p113e_private_chunks(functions,ids,[]),
        p112c_attach(p113e_public_chunks(segments,direct,index,ids,ready,[]),nt_join(p113e_old_private_chunks(entries,direct,ids,[]),"")))

@unsafe
def p113e_segment_chunks(+segments: List<&2,N111Segment>, +functions: List<&2,P113DFunction>, +ids: N111Ids, +index: P112FusionIndex) -> List<&2,String>:
  p113e_registered(segments,functions,index,ids,p112c_index_with(segments,index))

@unsafe
def p113e_admitted_chunks(bundle: P113DProgram) -> List<&2,String>:
  match bundle:
    case P113DProgram{+original,Nil{}}: p112s_chunks(original)
    case P113DProgram{P112StaticProgram{program,nodes},functions}: p113e_bundle_chunks(program,nodes,functions)

@unsafe
def p113e_bundle_chunks(+program: P111Program, +nodes: List<&2,P112SNode>, functions: List<&2,P113DFunction>) -> List<&2,String>:
  match program:
    case P111Program{+segments,constructors,show,names,effects,pure}:
      +ids = p111q_ids(program)
      nt_append(String,p113e_segment_chunks(segments,functions,ids,p112f_index(segments)),
        nt_append(String,p111q_data_chunks(nt_choose(List<&2,P111QData>,List.is_empty(&2,P112SNode,nodes),u => p111q_tables(program,ids),u => p112s_tables(program,nodes,ids))),[p111q_main()]))

@unsafe
def p113d_verify(program: P113DProgram) -> String:
  p113e_verify(program)

@unsafe
def p113e_checked_chunks(+program: P113DProgram, +error: String) -> List<&2,String>:
  nt_choose(List<&2,String>,String.is_empty(error),u => p113e_admitted_chunks(program),u => ["INVALID_P113_PROGRAM: " ++ error ++ "\n"])

@unsafe
def p113d_chunks(+program: P113DProgram) -> List<&2,String>:
  p113e_checked_chunks(program,p113d_verify(program))

@unsafe
def p113d_text(program: P113DProgram) -> String:
  nt_text_finish(nt_reverse(String,p113d_chunks(program),[]),"")
