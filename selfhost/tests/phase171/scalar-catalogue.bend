# Private nested schemas omit only the request-global scalar suffix.
# The retry loop attaches the genuine immutable catalogue lazily, once.

type P171SCPlan is Data:
  P171SCPlan{+plan: NO_Plan, +catalogue: Maybe<&2,List<&2,NO_Spec>>}

@unsafe
def p171sc_finish(+book: List<&2,KDef>, +params: List<&2,KTerm>, +roots: List<&2,U32>, +fresh: U32, +result: KTerm, graph: P128BLGraph) -> NO_Schema:
  match graph:
    case P128BLGraph{types,specs,+error}:
      nt_choose(NO_Schema,String.is_empty(error),
        u => NO_Schema{params,roots,var(nm(result),nc_id(fresh)),nc_id(fresh),nm(result),
          specs,U32.inc(fresh),""},
        u => nol_failure(error,fresh))

@unsafe
def p171sc_result(+book: List<&2,KDef>, +ty: KTerm, +params: List<&2,KTerm>, +roots: List<&2,U32>, +types: List<&2,KTerm>, +seen: List<&2,U32>, +fresh: U32, +arity: U32) -> NO_Schema:
  nt_choose(NO_Schema,U32.is_eq(terms_len(params),arity) &&
    U32.is_ge(nt_count(U32,roots),1) && U32.is_le(nt_count(U32,roots),2) &&
    Bool.not(nq_layout_dep(ty,seen)) && nol_scalar(book,ty),
    u => p171sc_finish(book,nt_reverse(KTerm,params,[]),nt_reverse(U32,roots,[]),fresh,ty,p128bl_graph(book,types,[],[],64)),
    u => nol_failure("nested observer: scalar result or root count",fresh))

@unsafe
def p171sc_param(+book: List<&2,KDef>, +head: KTerm, +ty: KTerm, +params: List<&2,KTerm>, +roots: List<&2,U32>, +types: List<&2,KTerm>, +seen: List<&2,U32>, +fresh: U32, +fuel: U32, +arity: U32) -> NO_Schema:
  +scalar = nol_scalar(book,ty)
  nt_choose(NO_Schema,nol_owner(book,ty) && Bool.not(nq_layout_dep(ty,seen)) && U32.is_lt(terms_len(params),arity),
    u => p171sc_params(book,kid(head,1),Con{var(nm(ty),nc_id(fresh)),params},
      nt_choose(List<&2,U32>,scalar,v => roots,v => Con{terms_len(params),roots}),
      nt_choose(List<&2,KTerm>,scalar,v => types,v => Con{ty,types}),
      Con{ix(head),seen},U32.inc(fresh),fuel,arity),
    u => nol_failure("nested observer: unsupported or dependent parameter",fresh))

@unsafe
def p171sc_head(+book: List<&2,KDef>, +head: KTerm, +params: List<&2,KTerm>, +roots: List<&2,U32>, +types: List<&2,KTerm>, +seen: List<&2,U32>, +fresh: U32, +fuel: U32, +arity: U32) -> NO_Schema:
  nt_choose(NO_Schema,String.eq(tg(head),"All"),
    u => nt_choose(NO_Schema,U32.is_eq(qt(head),0),
      v => p171sc_params(book,kid(head,1),params,roots,types,Con{ix(head),seen},fresh,fuel,arity),
      v => p171sc_param(book,head,nq_layout_type(book,kid(head,0)),params,roots,types,seen,fresh,fuel,arity)),
    u => p171sc_result(book,head,params,roots,types,seen,fresh,arity))

@unsafe
def p171sc_params(book,ty,params,roots,types,seen,fresh,fuel,arity):
  nt_choose(NO_Schema,U32.is_eq(fuel,0),u => nol_failure("nested observer: telescope budget",fresh),
    u => p171sc_head(book,nq_layout_type(book,ty),params,roots,types,seen,fresh,U32.sub(fuel,1),arity))

@unsafe
def p171sc_schema(+book: List<&2,KDef>, +owner: String) -> NO_Schema:
  +d = lookup(book,owner)
  nt_choose(NO_Schema,String.eq(dk(d),"Def") && Bool.not(nc_foreign(d) || nc_native_def(d)) && U32.is_le(nd_arity(book,owner),4),
    u => p171sc_params(book,dt(d),[],[],[],[],0,32,nd_arity(book,owner)),
    u => nol_failure("nested observer: unsupported owner",0))

@unsafe
def p171sc_attach(schema: NO_Schema, catalogue: List<&2,NO_Spec>) -> NO_Schema:
  match schema:
    case NO_Schema{params,roots,wrapper,result,observation,specs,fresh,error}:
      NO_Schema{params,roots,wrapper,result,observation,nt_append(NO_Spec,specs,catalogue),fresh,error}

@unsafe
def p171sc_analyzed(+book: List<&2,KDef>, +owner: String, +helpers: List<&2,P128BRHelper>,
    catalogue: Maybe<&2,List<&2,NO_Spec>>, +schema: NO_Schema) -> P171SCPlan:
  P171SCPlan{no_plan_result(owner,schema,noa_analyze_ready(NO_Context{book,owner,schema,helpers})),catalogue}

@unsafe
def p171sc_cached(+book: List<&2,KDef>, +owner: String, +helpers: List<&2,P128BRHelper>,
    local: NO_Schema, +specs: List<&2,NO_Spec>) -> P171SCPlan:
  p171sc_analyzed(book,owner,helpers,Some{specs},p171sc_attach(local,specs))

@unsafe
def p171sc_catalogue(+book: List<&2,KDef>, +owner: String, +helpers: List<&2,P128BRHelper>,
    +local: NO_Schema, catalogue: Maybe<&2,List<&2,NO_Spec>>) -> P171SCPlan:
  match catalogue:
    case None{}: p171sc_cached(book,owner,helpers,local,nol_scalar_specs(book,book))
    case Some{specs}: p171sc_cached(book,owner,helpers,local,specs)

@unsafe
def p171sc_local_ready(+book: List<&2,KDef>, +owner: String, +helpers: List<&2,P128BRHelper>,
    +catalogue: Maybe<&2,List<&2,NO_Spec>>, +local: NO_Schema) -> P171SCPlan:
  nt_choose(P171SCPlan,String.is_empty(no_schema_error(local)),
    u => p171sc_catalogue(book,owner,helpers,local,catalogue),
    u => P171SCPlan{NO_Plan{owner,local,noa_fail(no_schema_error(local),no_schema_fresh(local),4096),no_schema_error(local)},catalogue})

@unsafe
def p171sc_ordinary(+book: List<&2,KDef>, +owner: String, +helpers: List<&2,P128BRHelper>,
    +catalogue: Maybe<&2,List<&2,NO_Spec>>, +ordinary: NO_Schema) -> P171SCPlan:
  nt_choose(P171SCPlan,String.is_empty(no_schema_error(ordinary)),
    u => p171sc_analyzed(book,owner,helpers,catalogue,ordinary),
    u => p171sc_local_ready(book,owner,helpers,catalogue,p171sc_schema(book,owner)))

@unsafe
def p171sc_replan(+book: List<&2,KDef>, +plan: NO_Plan, +helpers: List<&2,P128BRHelper>,
    +catalogue: Maybe<&2,List<&2,NO_Spec>>) -> P171SCPlan:
  nt_choose(P171SCPlan,String.is_empty(no_schema_error(no_plan_schema(plan))),
    u => P171SCPlan{p128br_replan(book,plan,helpers),catalogue},
    u => p171sc_ordinary(book,no_plan_owner(plan),helpers,catalogue,no_schema(book,lookup(book,no_plan_owner(plan)),0)))

@unsafe
def p171sc_retry_step(+book: List<&2,KDef>, +rest: List<&2,NO_Plan>,
    +original: List<&2,P113DFunction>, +helpers: List<&2,P128BRHelper>, planned: P171SCPlan) -> P128BRPatches:
  match planned:
    case P171SCPlan{+plan,catalogue}:
      p128br_join(p128br_candidate(book,no_plan_owner(plan),original,plan),
        p171sc_retry(book,rest,original,helpers,catalogue))

@unsafe
def p171sc_retry(book,plans,original,helpers,catalogue):
  match plans:
    case Nil{}: P128BRPatches{[],""}
    case Con{plan,rest}:
      p171sc_retry_step(book,rest,original,helpers,p171sc_replan(book,plan,helpers,catalogue))

@unsafe
def p128br_retry_plans(+book: List<&2,KDef>, plans: List<&2,NO_Plan>, +original: List<&2,P113DFunction>, +helpers: List<&2,P128BRHelper>) -> P128BRPatches:
  p171sc_retry(book,plans,original,helpers,None{})
