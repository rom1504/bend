# Additive attribution control: identical demand lowering/final admission and
# inherited segment/direct emission; only the checked live-register bit differs.
# p111q_segment_chunks still invokes the existing generic registry internally;
# retaining that behavior isolates this control from a no-registry treatment.
# Exact adapters are authenticated by p167v_final before this renderer is used.

@unsafe
def p167live_eligible(program: P113DProgram) -> Bool:
  match program:
    case P113DProgram{P112StaticProgram{P111Program{segments,ctors,show,names,effects,pure},nodes},+functions}:
      Bool.not(List.is_empty(&2,P113DFunction,functions)) &&
        p118z_segments(p164a_generic(segments,[])) && p118z_functions(functions)

@unsafe
def p167live_chunks(+program: P113DProgram) -> List<&2,String>:
  match program:
    case P113DProgram{P112StaticProgram{+original,+nodes},functions}:
      p167live_indexed(original,nodes,functions,p111q_ids(original),p167live_eligible(program))

@unsafe
def p167live_indexed(+program: P111Program, +nodes: List<&2,P112SNode>, functions: List<&2,P113DFunction>,
    +ids: N111Ids, +live: Bool) -> List<&2,String>:
  match program:
    case P111Program{segments,constructors,show,names,effects,pure}:
      +tables = nt_choose(List<&2,P111QData>,List.is_empty(&2,P112SNode,nodes),
        u => p111q_tables(program,ids),u => p112s_tables(program,nodes,ids))
      nt_append(String,p113e_private_chunks(functions,ids,[]),
        nt_append(String,p111q_segment_chunks(segments,ids,[]),
          nt_append(String,p111q_data_chunks(nt_choose(List<&2,P111QData>,live,
            u => p118z_tables(tables),u => tables)),[p111q_main()])))

@unsafe
def p167live_verified(+program: P113DProgram, +error: String) -> P111Emission:
  nt_choose(P111Emission,String.is_empty(error),u => P111Emission{p167live_chunks(program),""},
    u => P111Emission{[],"demand live final IR: " ++ error})

@unsafe
def p167live_lowered(request: NR_Request, lowered: P167Lowered) -> P111Emission:
  match request lowered:
    case NR_Request{source,+book,+names,paths,scope,bound} P167Lowered{+program,adapters,+error,stats}:
      nt_choose(P111Emission,String.is_empty(error),u =>
        p167live_verified(program,p167v_final(book,nc_bangs_names(book,names),adapters,program)),
        u => P111Emission{[],"demand live lowering: " ++ error})

@unsafe
def p167live_admitted(+request: NR_Request, +mode: U32, +error: String) -> P111Emission:
  nt_choose(P111Emission,String.is_empty(error),u => p167live_lowered(request,p167l_request(request,mode)),
    u => P111Emission{[],"demand live runtime: " ++ error})

@unsafe
def p167live_plan(+mode: U32, plan: P86Plan) -> P111Emission:
  match plan:
    case P86PlanError{error}: P111Emission{[],error}
    case P86PlanReady{+request,verdict}: p167live_admitted(request,mode,p111_runtime_admission(request))
