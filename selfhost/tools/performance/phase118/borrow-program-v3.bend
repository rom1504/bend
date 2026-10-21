# Separate experimental entry points. The same checked NR_Request must supply
# ordinary lowering and p118b_plan; the root harness pins that source identity.
# These are compiler-internal products, not a serialized untrusted plan format.
@unsafe
def p118b_rederive(+book: List<&2,KDef>, names: List<&2,String>, +permission: Bool) -> P118BWorkers:
  match names:
    case Nil{}: P118BWorkers{[],""}
    case Con{+name,rest}:
      +plan = no_observer_plan(book,name,permission)
      +here = nt_choose(P118BWorkers,p118b_eligible(book,plan),
        u => p118b_functions(book,name,plan),u => P118BWorkers{[],"borrowed plan no longer admitted: " ++ name})
      p118b_workers_join(here,p118b_rederive(book,rest,permission))

@unsafe
def p118b_new_functions(plan: P118BPlan) -> P118BWorkers:
  match plan:
    case P118BPlan{NR_Request{+source,+book,+names,paths,scope,+bound},selected,+error}:
      +checked = p111_first(error,nc_compile_error_known(source,bound))
      nt_choose(P118BWorkers,String.is_empty(checked),
        u => p118b_rederive(book,selected,ns_definitions(book,names)),
        u => P118BWorkers{[],checked})

@unsafe
def p118b_without(functions: List<&2,P113DFunction>, +replaced: KDef) -> List<&2,P113DFunction>:
  match functions:
    case Nil{}: []
    case Con{+head,+rest}:
      match head:
        case P113DFunction{name,params,result,public,body}:
          nt_choose(List<&2,P113DFunction>,String.eq(dk(p111v_get(replaced,name)),"Absent"),
            u => Con{head,p118b_without(rest,replaced)},u => p118b_without(rest,replaced))

@unsafe
def p118b_compose(+original: P113AProgram, workers: P118BWorkers) -> P111Emission:
  match original workers:
    case P113AProgram{P113DProgram{P112StaticProgram{+program,nodes},functions},certificate} P118BWorkers{+added,+error}:
      +checked = p111_first(error,p118b_verify_functions(added,program))
      +merged = nt_append(P113DFunction,added,p118b_without(functions,p113e_signatures(added,missing())))
      nt_choose(P111Emission,String.is_empty(checked),
        u => P111Emission{p113a_admitted_chunks(P113AProgram{P113DProgram{P112StaticProgram{program,nodes},merged},certificate}),""},
        u => P111Emission{[],"borrowed profile: " ++ checked})

@unsafe
def p118b_emit_verified(+original: P113AProgram, +plan: P118BPlan, +error: String) -> P111Emission:
  nt_choose(P111Emission,String.is_empty(error),u => p118b_compose(original,p118b_new_functions(plan)),
    u => P111Emission{[],"borrowed original: " ++ error})

@unsafe
def p118b_emission_chunks(emitted: P111Emission) -> List<&2,String>:
  match emitted:
    case P111Emission{chunks,+error}:
      nt_choose(List<&2,String>,String.is_empty(error),u => chunks,u => ["INVALID_P118_BORROW: " ++ error ++ "\n"])

@unsafe
def p118b_chunks(+original: P113AProgram, +plan: P118BPlan) -> List<&2,String>:
  p118b_emission_chunks(p118b_emit_verified(original,plan,p113a_verify(original)))

@unsafe
def p118b_emit_lowered(+plan: P118BPlan, lowered: P113ALowering) -> P111Emission:
  match lowered:
    case P113ALowered{+program,+error}:
      nt_choose(P111Emission,String.is_empty(error),u => p118b_emit_verified(program,plan,p113a_verify(program)),
        u => P111Emission{[],"borrowed lowering: " ++ error})

@unsafe
def p118b_emit_request(+request: NR_Request) -> P111Emission:
  p118b_emit_lowered(p118b_plan(request),p113a_lower_request(request))
