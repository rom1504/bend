# Additive plain-emission contrast. The earlier p167e path is preserved:
# p111q_segment_chunks calls p112c_segment_chunks and builds a registry.
# This loop deliberately calls the individual scalar segment renderer instead.
# All chunks remain materialized and their construction/destruction is charged.
@unsafe
def p167plain_segments(segments: List<&2,N111Segment>, +ids: N111Ids, acc: List<&2,String>) -> List<&2,String>:
  match segments:
    case Nil{}: nt_reverse(String,acc,[])
    case Con{segment,rest}:
      p167plain_segments(rest,ids,Con{p111q_segment(segment,ids),acc})

@unsafe
def p167plain_indexed(+program: P111Program, +nodes: List<&2,P112SNode>, functions: List<&2,P113DFunction>,
    +ids: N111Ids, +live: Bool) -> List<&2,String>:
  match program:
    case P111Program{segments,constructors,show,names,effects,pure}:
      +tables = nt_choose(List<&2,P111QData>,List.is_empty(&2,P112SNode,nodes),
        u => p111q_tables(program,ids),u => p112s_tables(program,nodes,ids))
      nt_append(String,p113e_private_chunks(functions,ids,[]),
        nt_append(String,p167plain_segments(segments,ids,[]),
          nt_append(String,p111q_data_chunks(nt_choose(List<&2,P111QData>,live,
            u => p118z_tables(tables),u => tables)),[p111q_main()])))

@unsafe
def p167plain_chunks(+program: P113DProgram, +live: Bool) -> List<&2,String>:
  match program:
    case P113DProgram{P112StaticProgram{+original,nodes},functions}:
      p167plain_indexed(original,nodes,functions,p111q_ids(original),
        nt_choose(Bool,live,u => p167live_eligible(program),u => False{}))

@unsafe
def p167plain_verified(+program: P113DProgram, +live: Bool, +error: String) -> P111Emission:
  nt_choose(P111Emission,String.is_empty(error),u => P111Emission{p167plain_chunks(program,live),""},
    u => P111Emission{[],"demand plain final IR: " ++ error})

@unsafe
def p167plain_lowered(request: NR_Request, +live: Bool, lowered: P167Lowered) -> P111Emission:
  match request lowered:
    case NR_Request{source,+book,+names,paths,scope,bound} P167Lowered{+program,adapters,+error,stats}:
      nt_choose(P111Emission,String.is_empty(error),u =>
        p167plain_verified(program,live,p167v_final(book,nc_bangs_names(book,names),adapters,program)),
        u => P111Emission{[],"demand plain lowering: " ++ error})

@unsafe
def p167plain_admitted(+request: NR_Request, +mode: U32, +live: Bool, +error: String) -> P111Emission:
  nt_choose(P111Emission,String.is_empty(error),u => p167plain_lowered(request,live,p167l_request(request,mode)),
    u => P111Emission{[],"demand plain runtime: " ++ error})

@unsafe
def p167plain_policy(+mode: U32, +live: Bool, plan: P86Plan) -> P111Emission:
  match plan:
    case P86PlanError{error}: P111Emission{[],error}
    case P86PlanReady{+request,verdict}: p167plain_admitted(request,mode,live,p111_runtime_admission(request))

@unsafe
def p167plain_plan(mode: U32, plan: P86Plan) -> P111Emission:
  p167plain_policy(mode,False{},plan)

@unsafe
def p167plainlive_plan(mode: U32, plan: P86Plan) -> P111Emission:
  p167plain_policy(mode,True{},plan)
