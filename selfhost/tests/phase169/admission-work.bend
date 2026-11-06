# Private Phase169 successor. No producer-owned Boolean authorizes machine code:
# the unchanged eligibility predicate is evaluated against this exact prepared
# book and immutable plan, then reused only before those inputs can change.

@unsafe
def p169q_metadata(+arity: U32, +result: U32, +incoming: U32, +flags: U32) -> Bool:
  U32.is_eq(incoming,0) && U32.is_eq(flags,0) && U32.is_eq(result,1) && U32.is_le(arity,32)

@unsafe
def p169q_import(+name: String, +arity: U32, direct: KDef) -> Bool:
  +function = p111v_get(direct,name)
  String.eq(dk(function),"P113Direct") && U32.is_eq(da(function),arity) &&
    U32.is_eq(dx(function),1) && U32.is_eq(ix(dv(function)),1)

# Metadata failure cannot be repaired by any direct-map entry. Avoid its name
# hash and lookup entirely, instead of relying on eager Bool conjunction.
@unsafe
def p168j_eligible(segment: N111Segment, +direct: KDef) -> Bool:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,body}:
      nt_choose(Bool,p169q_metadata(arity,result,incoming,flags),
        u => p169q_import(name,arity,direct),u => False{})

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

type P169ScalarPlan is Data:
  P169ScalarPlan{+plan: NO_Plan, +eligible: Bool}

@unsafe
def p169q_plans(+book: List<&2,KDef>, plans: List<&2,NO_Plan>) -> List<&2,P169ScalarPlan>:
  match plans:
    case Nil{}: []
    case Con{+plan,rest}:
      Con{P169ScalarPlan{plan,p128bs_eligible(book,plan)},p169q_plans(book,rest)}

@unsafe
def p169q_selection(+book: List<&2,KDef>, plans: List<&2,P169ScalarPlan>,
    blocked: KDef, +targets: KDef) -> P168TSelection:
  match plans:
    case Nil{}: P168TSelection{blocked,targets}
    case Con{P169ScalarPlan{plan,eligible},rest}:
      +owner = p113d_public(book,no_plan_owner(plan))
      p169q_selection(book,rest,p167l_mark(blocked,owner),
        nt_choose(KDef,eligible,u => p167l_mark(targets,owner),u => targets))

@unsafe
def p169q_scalars(+book: List<&2,KDef>, plans: List<&2,P169ScalarPlan>,
    +original: List<&2,P113DFunction>, functions: List<&2,P113DFunction>,
    helpers: List<&2,P128BRHelper>, retry: List<&2,NO_Plan>) -> P128BROpen:
  match plans:
    case Nil{}: P128BROpen{nt_reverse(P113DFunction,functions,[]),
      nt_reverse(P128BRHelper,helpers,[]),nt_reverse(NO_Plan,retry,[]),""}
    case Con{P169ScalarPlan{+plan,eligible},rest}:
      p169q_scalar_ready(book,rest,original,functions,helpers,retry,plan,
        nt_choose(P118BWorkers,eligible,
          u => p128bs_find(book,no_plan_owner(plan),plan,original),u => P118BWorkers{[],""}))

@unsafe
def p169q_scalar_ready(+book: List<&2,KDef>, +rest: List<&2,P169ScalarPlan>,
    +original: List<&2,P113DFunction>, +functions: List<&2,P113DFunction>,
    +helpers: List<&2,P128BRHelper>, +retry: List<&2,NO_Plan>,
    +plan: NO_Plan, +workers: P118BWorkers) -> P128BROpen:
  match workers:
    case P118BWorkers{+added,+error}:
      nt_choose(P128BROpen,String.is_empty(error),
        u => p169q_scalars(book,rest,original,nt_reverse(P113DFunction,added,functions),
          nt_reverse(P128BRHelper,p128br_seed(no_plan_owner(plan),no_plan_schema(plan),workers),helpers),
          nt_choose(List<&2,NO_Plan>,List.is_empty(&2,P113DFunction,added),v => Con{plan,retry},v => retry)),
        u => P128BROpen{[],[],[],error})

@unsafe
def p169q_inlined(source: List<&2,KDef>, +book: List<&2,KDef>, names: List<&2,String>,
    constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>, bangs: List<&2,String>,
    stats: List<&2,U32>, helpers: List<&2,P128BRHelper>, plans: List<&2,P169ScalarPlan>,
    +functions: List<&2,P113DFunction>) -> P167Lowered:
  p168_scalar_result(source,book,names,constructors,nodes,bangs,stats,functions,
    p169q_scalars(book,plans,functions,[],nt_reverse(P128BRHelper,helpers,[]),[]))

@unsafe
def p169q_closed(source: List<&2,KDef>, +book: List<&2,KDef>, names: List<&2,String>,
    constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>, bangs: List<&2,String>,
    stats: List<&2,U32>, helpers: List<&2,P128BRHelper>, +plans: List<&2,P169ScalarPlan>,
    seeds: KDef, functions: List<&2,P113DFunction>) -> P167Lowered:
  p169q_inlined(source,book,names,constructors,nodes,bangs,stats,helpers,plans,
    p168t_selected(functions,seeds,p169q_selection(book,plans,missing(),missing())))

# Mode0 is byte-for-byte the old call policy. Mode1 reuses one exact predicate
# result across selection and scalar materialization. The initial observer scan
# stays unchanged, and consumer retry replans remain independently recomputed.
@unsafe
def p168_closed(+mode: U32, +source: List<&2,KDef>, +book: List<&2,KDef>, +names: List<&2,String>,
    +constructors: List<&2,N_Constructor>, +nodes: List<&2,P112SNode>, +bangs: List<&2,String>,
    +stats: List<&2,U32>, +helpers: List<&2,P128BRHelper>, +retry: List<&2,NO_Plan>,
    +seeds: KDef, +functions: List<&2,P113DFunction>) -> P167Lowered:
  +stats = nt_append(U32,stats,[nt_count(P113DFunction,functions)])
  nt_choose(P167Lowered,U32.is_eq(mode,1),
    u => p169q_closed(source,book,names,constructors,nodes,bangs,stats,helpers,
      p169q_plans(book,retry),seeds,functions),
    u => p168_inlined(source,book,names,constructors,nodes,bangs,stats,helpers,retry,functions))
