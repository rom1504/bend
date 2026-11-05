# Bounded materialized emission. Every chunk is produced only after final
# independent admission. No region registry, rediscovery or late optimization.
@unsafe
def p167e_chunks(+program: P113DProgram) -> List<&2,String>:
  match program:
    case P113DProgram{P112StaticProgram{+original,+nodes},functions}:
      p167e_indexed(original,nodes,functions,p111q_ids(original))

@unsafe
def p167e_indexed(+program: P111Program, +nodes: List<&2,P112SNode>, functions: List<&2,P113DFunction>, +ids: N111Ids) -> List<&2,String>:
  match program:
    case P111Program{segments,constructors,show,names,effects,pure}:
      nt_append(String,p113e_private_chunks(functions,ids,[]),
        nt_append(String,p111q_segment_chunks(segments,ids,[]),
          nt_append(String,p111q_data_chunks(nt_choose(List<&2,P111QData>,List.is_empty(&2,P112SNode,nodes),
            u => p111q_tables(program,ids),u => p112s_tables(program,nodes,ids))),[p111q_main()])))

@unsafe
def p167e_verified(+program: P113DProgram, +error: String) -> P111Emission:
  nt_choose(P111Emission,String.is_empty(error),u => P111Emission{p167e_chunks(program),""},
    u => P111Emission{[],"demand final IR: " ++ error})

@unsafe
def p167e_lowered(request: NR_Request, lowered: P167Lowered) -> P111Emission:
  match request lowered:
    case NR_Request{source,+book,+names,paths,scope,bound} P167Lowered{+program,adapters,+error,stats}:
      nt_choose(P111Emission,String.is_empty(error),u =>
        p167e_verified(program,p167v_final(book,nc_bangs_names(book,names),adapters,program)),
        u => P111Emission{[],"demand lowering: " ++ error})

@unsafe
def p167e_admitted(+request: NR_Request, +mode: U32, +error: String) -> P111Emission:
  nt_choose(P111Emission,String.is_empty(error),u => p167e_lowered(request,p167l_request(request,mode)),
    u => P111Emission{[],"demand runtime: " ++ error})

@unsafe
def p167e_plan(+mode: U32, plan: P86Plan) -> P111Emission:
  match plan:
    case P86PlanError{error}: P111Emission{[],error}
    case P86PlanReady{+request,verdict}: p167e_admitted(request,mode,p111_runtime_admission(request))
