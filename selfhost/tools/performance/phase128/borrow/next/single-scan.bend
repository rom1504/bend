# Optional Stage1/2 cost recovery. Derive workers and verified helper summaries
# from ONE ordinary observer-plan scan. Preserve immutable schemas for retries;
# only helper-boundary failures, concrete-schema candidates and successful
# scalar observers missing a leaf fallback enter the extended analysis.

type P128BROpen is Data:
  P128BROpen{+functions: List<&2,P113DFunction>, +helpers: List<&2,P128BRHelper>, +retry: List<&2,NO_Plan>, +error: String}

@unsafe
def p128br_retryable(+plan: NO_Plan) -> Bool:
  String.eq(no_plan_error(plan),"observer: helper effect, cycle or depth") ||
    String.eq(no_schema_error(no_plan_schema(plan)),"unsupported or dependent parameter")

@unsafe
def p128br_scan(+book: List<&2,KDef>, names: List<&2,String>, +original: List<&2,P113DFunction>, functions: List<&2,P113DFunction>, helpers: List<&2,P128BRHelper>, retry: List<&2,NO_Plan>) -> P128BROpen:
  match names:
    case Nil{}: P128BROpen{nt_reverse(P113DFunction,functions,[]),nt_reverse(P128BRHelper,helpers,[]),nt_reverse(NO_Plan,retry,[]),""}
    case Con{+name,rest}:
      p128br_scan_plan(book,rest,original,functions,helpers,retry,no_observer_plan(book,name,True{}))

@unsafe
def p128br_scan_plan(+book: List<&2,KDef>, +names: List<&2,String>, +original: List<&2,P113DFunction>, +functions: List<&2,P113DFunction>, +helpers: List<&2,P128BRHelper>, +retry: List<&2,NO_Plan>, +plan: NO_Plan) -> P128BROpen:
  nt_choose(P128BROpen,p118b_eligible(book,plan),
    u => p128br_scan_ready(book,names,original,functions,helpers,retry,plan,False{},p118b_functions(book,no_plan_owner(plan),plan)),
    u => nt_choose(P128BROpen,p128bs_eligible(book,plan),
      v => p128br_scan_ready(book,names,original,functions,helpers,retry,plan,True{},p128bs_find(book,no_plan_owner(plan),plan,original)),
      v => p128br_scan(book,names,original,functions,helpers,
        nt_choose(List<&2,NO_Plan>,p128br_retryable(plan),w => Con{plan,retry},w => retry))))

@unsafe
def p128br_scan_ready(+book: List<&2,KDef>, +names: List<&2,String>, +original: List<&2,P113DFunction>, +functions: List<&2,P113DFunction>, +helpers: List<&2,P128BRHelper>, +retry: List<&2,NO_Plan>, +plan: NO_Plan, +scalar: Bool, +workers: P118BWorkers) -> P128BROpen:
  match workers:
    case P118BWorkers{+added,+error}:
      nt_choose(P128BROpen,String.is_empty(error),
        u => p128br_scan(book,names,original,nt_reverse(P113DFunction,added,functions),
          nt_choose(List<&2,P128BRHelper>,scalar,
            v => nt_reverse(P128BRHelper,p128br_seed(no_plan_owner(plan),no_plan_schema(plan),workers),helpers),v => helpers),
          nt_choose(List<&2,NO_Plan>,scalar && List.is_empty(&2,P113DFunction,added),v => Con{plan,retry},v => retry)),
        u => P128BROpen{[],[],[],error})

@unsafe
def p128br_replan(+book: List<&2,KDef>, +plan: NO_Plan, +helpers: List<&2,P128BRHelper>) -> NO_Plan:
  +schema = no_plan_schema(plan)
  nt_choose(NO_Plan,String.is_empty(no_schema_error(schema)),
    u => no_plan_result(no_plan_owner(plan),schema,noa_analyze_ready(NO_Context{book,no_plan_owner(plan),schema,helpers})),
    u => p128br_plan(book,no_plan_owner(plan),helpers))

@unsafe
def p128br_retry_plans(+book: List<&2,KDef>, plans: List<&2,NO_Plan>, +original: List<&2,P113DFunction>, +helpers: List<&2,P128BRHelper>) -> P128BRPatches:
  match plans:
    case Nil{}: P128BRPatches{[],""}
    case Con{+plan,rest}:
      p128br_join(p128br_candidate(book,no_plan_owner(plan),original,p128br_replan(book,plan,helpers)),
        p128br_retry_plans(book,rest,original,helpers))

@unsafe
def p128br_scanned(+request: NR_Request, +original: P113AProgram, +book: List<&2,KDef>, +source: List<&2,KDef>, +names: List<&2,String>, +cold: Bool, scan: P128BROpen) -> P111Emission:
  match scan:
    case P128BROpen{functions,+helpers,retry,+error}:
      nt_choose(P111Emission,String.is_empty(error),
        u => p128br_finish(request,
          nt_choose(P113AProgram,cold,v => p118e_cold(original,book,source,nh_definitions(book,names,[])),v => original),
          P118BWorkers{functions,""},
          p128br_retry_plans(book,retry,p128bs_original(original),helpers)),
        u => P111Emission{[],"borrowed profile: " ++ error})

@unsafe
def p128br_prepare(+request: NR_Request, +original: P113AProgram, +cold: Bool) -> P111Emission:
  match request:
    case NR_Request{+source,+book,+names,paths,scope,bound}:
      p128br_scanned(request,original,book,source,names,cold,
        p128br_scan(book,no_candidate_names(book,names,nc_bangs_names(book,names)),p128bs_original(original),[],[],[]))
