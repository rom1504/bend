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

# This second maintained check authenticates public ABI flags against actual
# original headers as well as retaining all borrowed/direct body checks.
@unsafe
def p168v_checked(original: P111Program, nodes: List<&2,P112SNode>,
    functions: List<&2,P113DFunction>, live: Bool, +error: String) -> P111Emission:
  nt_choose(P111Emission,String.is_empty(error),
    u => P111Emission{p134e_collect_cursor(p134e_prepare(original,nodes,functions,False{},live),[],[]),""},
    u => P111Emission{[],"adapter renderer view verification: " ++ error})

@unsafe
def p168v_prepare(mode: U32, +program: P113DProgram, adapters: KDef) -> P111Emission:
  match program:
    case P113DProgram{P112StaticProgram{+original,nodes},+functions}:
      +view = nt_choose(List<&2,P113DFunction>,U32.is_eq(mode,1),
        u => p168v_functions(functions,adapters),u => functions)
      p168v_checked(original,nodes,view,p167live_eligible(program),p118b_verify_functions(view,original))

@unsafe
def p168v_verified(mode: U32, program: P113DProgram, adapters: KDef, +error: String) -> P111Emission:
  nt_choose(P111Emission,String.is_empty(error),u => p168v_prepare(mode,program,adapters),
    u => P111Emission{[],"adapter renderer original final IR: " ++ error})

@unsafe
def p168v_lowered(mode: U32, request: NR_Request, lowered: P167Lowered) -> P111Emission:
  match request lowered:
    case NR_Request{source,+book,+names,paths,scope,bound} P167Lowered{+program,+adapters,+error,stats}:
      nt_choose(P111Emission,String.is_empty(error),
        u => p168v_verified(mode,program,adapters,
          p167ob_final(book,nc_bangs_names(book,names),adapters,program)),
        u => P111Emission{[],"adapter renderer lowering: " ++ error})

@unsafe
def p168v_admitted(mode: U32, +request: NR_Request, +error: String) -> P111Emission:
  nt_choose(P111Emission,String.is_empty(error),
    u => p168v_lowered(mode,request,p168_request_mode(1,request)),
    u => P111Emission{[],"adapter renderer runtime: " ++ error})

# Both modes share the same selective scalar producer, actual final checks,
# registry/continuation renderer and live capability. Only the metadata differs.
@unsafe
def p168v_plan(+mode: U32, plan: P86Plan) -> P111Emission:
  match plan:
    case P86PlanError{error}: P111Emission{[],error}
    case P86PlanReady{+request,verdict}:
      nt_choose(P111Emission,U32.is_le(mode,1),
        u => p168v_admitted(mode,request,p111_runtime_admission(request)),
        u => P111Emission{[],"adapter renderer mode must be 0 or 1"})
