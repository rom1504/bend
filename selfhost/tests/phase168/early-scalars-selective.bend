# Experimental alternative to broad p168_inline. Load after early-scalars.bend
# with the sole explicit experimental override p168_closed. Frozen API01 keeps
# its original policy; in this API mode0 is unchanged and mode1 is selective.

type P168TSelection is Data:
  P168TSelection{+blocked: KDef, +targets: KDef}

@unsafe
def p168t_has(index: KDef, name: String) -> Bool:
  Bool.not(String.eq(dk(p111v_get(index,name)),"Absent"))

# Protect every cached scalar/retry owner, not only successful scalar plans.
# Otherwise an old consumer can be copied before its borrowed replacement exists.
@unsafe
def p168t_selection(+book: List<&2,KDef>, plans: List<&2,NO_Plan>, blocked: KDef,
    +targets: KDef) -> P168TSelection:
  match plans:
    case Nil{}: P168TSelection{blocked,targets}
    case Con{+plan,rest}:
      +owner = p113d_public(book,no_plan_owner(plan))
      p168t_selection(book,rest,p167l_mark(blocked,owner),
        nt_choose(KDef,p128bs_eligible(book,plan),
          u => p167l_mark(targets,owner),u => targets))

@unsafe
def p168t_accept(original: P113DFunction, +candidate: P113DFunction) -> P113DFunction:
  match candidate:
    case P113DFunction{name,params,result,public,body}:
      nt_choose(P113DFunction,p128bs_leaf(body),u => candidate,u => original)

# Preparation is retained only when it establishes the original leaf contract.
# Existing leaf owners, non-target consumers and general observer seeds stay exact.
@unsafe
def p168t_target(+original: P113DFunction, table: P113ITable) -> P113DFunction:
  match original:
    case P113DFunction{name,params,result,public,body}:
      nt_choose(P113DFunction,p128bs_leaf(body),u => original,
        u => p168t_accept(original,p113i_function(original,table)))

@unsafe
def p168t_walk(functions: List<&2,P113DFunction>, +seeds: KDef, +blocked: KDef,
    +targets: KDef, +table: P113ITable, +reversed: List<&2,P113DFunction>) -> List<&2,P113DFunction>:
  match functions:
    case Nil{}: nt_reverse(P113DFunction,reversed,[])
    case Con{+head,+rest}:
      match head:
        case P113DFunction{+name,params,result,public,body}:
          nt_choose(List<&2,P113DFunction>,p113d_ready(seeds,name),
            u => p168t_walk(rest,seeds,blocked,targets,table,Con{head,reversed}),
            u => nt_choose(List<&2,P113DFunction>,p168t_has(blocked,name),
              v => p168t_walk(rest,seeds,blocked,targets,table,
                Con{nt_choose(P113DFunction,p168t_has(targets,name),
                  w => p168t_target(head,table),w => head),reversed}),
              v => p168t_walk(rest,seeds,blocked,targets,
                nt_choose(P113ITable,p113i_original_clean(head) && p128bs_leaf(body),
                  w => p113i_table_function(head,table),w => table),Con{head,reversed})))

@unsafe
def p168t_selected(functions: List<&2,P113DFunction>, seeds: KDef,
    selection: P168TSelection) -> List<&2,P113DFunction>:
  match selection:
    case P168TSelection{blocked,targets}:
      p168t_walk(functions,seeds,blocked,targets,P113IEmpty{},[])

@unsafe
def p168t_prepare(book: List<&2,KDef>, plans: List<&2,NO_Plan>,
    functions: List<&2,P113DFunction>, seeds: KDef) -> List<&2,P113DFunction>:
  p168t_selected(functions,seeds,p168t_selection(book,plans,missing(),missing()))

# This is the only override. All source permission, real fallback construction,
# closed-worker checks, demanded generic/static/adapter obligations and final
# actual-ID borrowed projection remain in the unchanged Phase168/167 pipeline.
@unsafe
def p168_closed(+mode: U32, source: List<&2,KDef>, +book: List<&2,KDef>, names: List<&2,String>,
    constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>, bangs: List<&2,String>,
    stats: List<&2,U32>, helpers: List<&2,P128BRHelper>, +retry: List<&2,NO_Plan>,
    +seeds: KDef, +functions: List<&2,P113DFunction>) -> P167Lowered:
  p168_inlined(source,book,names,constructors,nodes,bangs,
    nt_append(U32,stats,[nt_count(P113DFunction,functions)]),helpers,retry,
    nt_choose(List<&2,P113DFunction>,U32.is_eq(mode,1),
      u => p168t_prepare(book,retry,functions,seeds),u => functions))

@unsafe
def p168t_request(mode: U32, request: NR_Request) -> P167Lowered:
  p168_request_mode(mode,request)

@unsafe
def p168t_plan(mode: U32, plan: P86Plan) -> P111Emission:
  p168_plan(mode,plan)
