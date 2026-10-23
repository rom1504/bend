# Stage2 is a bounded concrete-type proof, not a relaxation of nol_plain.
# Each nominal ADT has one exact instantiated KTerm in this observer's reachable
# layout graph. Conflicting instantiations are refused before nominal names are
# used by the existing NO evaluator. Scalar helper summaries remain Stage1's
# nonparameterized checked readers. No borrowed child can escape.

type P128BLGraph is Data:
  P128BLGraph{+types: List<&2,KTerm>, +specs: List<&2,NO_Spec>, +error: String}

type P128BLNode is Data:
  P128BLNode{+specs: List<&2,NO_Spec>, +children: List<&2,KTerm>, +error: String}

@unsafe
def p128bl_type(+name: String, types: List<&2,KTerm>) -> KTerm:
  match types:
    case Nil{}: atom("Absent")
    case Con{+head,rest}: nt_choose(KTerm,String.eq(name,nm(head)),u => head,u => p128bl_type(name,rest))

@unsafe
def p128bl_recursive(+owner: KTerm, fields: List<&2,KTerm>, +count: U32) -> Bool:
  match fields:
    case Nil{}: U32.is_eq(count,1)
    case Con{+head,+rest}:
      nt_choose(Bool,String.eq(nm(head),nm(owner)),
        u => norm_exact(head,owner) && U32.is_eq(count,0) && p128bl_recursive(owner,rest,1),
        u => p128bl_recursive(owner,rest,count))

@unsafe
def p128bl_pair(+book: List<&2,KDef>, +ty: KTerm, +nil: KDef, +cons: KDef) -> P128BLNode:
  +empty = nol_ctor_fields(book,ty,nil)
  +fields = nol_ctor_fields(book,ty,cons)
  nt_choose(P128BLNode,U32.is_eq(da(nil),0) && U32.is_ge(da(cons),2) &&
    String.eq(tg(empty),"NO_Types") && String.eq(tg(fields),"NO_Types") &&
    p128bl_recursive(ty,ks(fields),0),
    u => P128BLNode{[nol_spec(book,nm(ty),nil,"Nullary",[]),
      nol_spec(book,nm(ty),cons,"Boxed",ks(fields))],ks(fields),""},
    u => P128BLNode{[],[],"nested observer: constructor specialization or one recursive child"})

@unsafe
def p128bl_ctors(+book: List<&2,KDef>, +ty: KTerm, ctors: List<&2,KDef>) -> P128BLNode:
  match ctors:
    case Con{+a,Con{+b,Nil{}}}:
      nt_choose(P128BLNode,U32.is_eq(da(a),0),u => p128bl_pair(book,ty,a,b),u => p128bl_pair(book,ty,b,a))
    case _: P128BLNode{[],[],"nested observer: requires finite two-constructor spine"}

@unsafe
def p128bl_node(+book: List<&2,KDef>, +ty: KTerm) -> P128BLNode:
  +owner = lookup(book,nm(ty))
  nt_choose(P128BLNode,nol_owner(book,ty) && (Bool.not(db(owner)) ||
    String.eq(nm(ty),"String") || String.eq(nm(ty),"List")),
    u => p128bl_ctors(book,ty,dc(owner)),
    u => P128BLNode{[],[],"nested observer: unknown or native non-boxed owner"})

@unsafe
def p128bl_graph(+book: List<&2,KDef>, todo: List<&2,KTerm>, +types: List<&2,KTerm>, +specs: List<&2,NO_Spec>, +fuel: U32) -> P128BLGraph:
  match todo:
    case Nil{}: P128BLGraph{types,specs,""}
    case Con{+raw,+rest}:
      +ty = nq_layout_type(book,raw)
      nt_choose(P128BLGraph,U32.is_eq(fuel,0),u => P128BLGraph{[],[],"nested observer: layout budget"},
        u => nt_choose(P128BLGraph,nol_scalar(book,ty),
          v => p128bl_graph(book,rest,types,specs,U32.sub(fuel,1)),
          v => p128bl_seen(book,ty,rest,types,specs,U32.sub(fuel,1),p128bl_type(nm(ty),types))))

@unsafe
def p128bl_seen(+book: List<&2,KDef>, +ty: KTerm, +todo: List<&2,KTerm>, +types: List<&2,KTerm>, +specs: List<&2,NO_Spec>, +fuel: U32, +previous: KTerm) -> P128BLGraph:
  nt_choose(P128BLGraph,String.eq(tg(previous),"Absent"),
    u => p128bl_extend(book,ty,todo,types,specs,fuel,p128bl_node(book,ty)),
    u => nt_choose(P128BLGraph,norm_exact(previous,ty),
      v => p128bl_graph(book,todo,types,specs,fuel),
      v => P128BLGraph{[],[],"nested observer: conflicting instantiations of " ++ nm(ty)}))

@unsafe
def p128bl_extend(+book: List<&2,KDef>, +ty: KTerm, +todo: List<&2,KTerm>, +types: List<&2,KTerm>, +specs: List<&2,NO_Spec>, +fuel: U32, node: P128BLNode) -> P128BLGraph:
  match node:
    case P128BLNode{added,children,+error}:
      nt_choose(P128BLGraph,String.is_empty(error),
        u => p128bl_graph(book,nt_append(KTerm,children,todo),Con{ty,types},nt_append(NO_Spec,added,specs),fuel),
        u => P128BLGraph{[],[],error})

@unsafe
def p128bl_finish(+book: List<&2,KDef>, +params: List<&2,KTerm>, +roots: List<&2,U32>, +fresh: U32, +result: KTerm, graph: P128BLGraph) -> NO_Schema:
  match graph:
    case P128BLGraph{types,specs,+error}:
      nt_choose(NO_Schema,String.is_empty(error),
        u => NO_Schema{params,roots,var(nm(result),nc_id(fresh)),nc_id(fresh),nm(result),
          nt_append(NO_Spec,specs,nol_scalar_specs(book,book)),U32.inc(fresh),""},
        u => nol_failure(error,fresh))

@unsafe
def p128bl_result(+book: List<&2,KDef>, +ty: KTerm, +params: List<&2,KTerm>, +roots: List<&2,U32>, +types: List<&2,KTerm>, +seen: List<&2,U32>, +fresh: U32, +arity: U32) -> NO_Schema:
  nt_choose(NO_Schema,U32.is_eq(terms_len(params),arity) &&
    U32.is_ge(nt_count(U32,roots),1) && U32.is_le(nt_count(U32,roots),2) &&
    Bool.not(nq_layout_dep(ty,seen)) && nol_scalar(book,ty),
    u => p128bl_finish(book,nt_reverse(KTerm,params,[]),nt_reverse(U32,roots,[]),fresh,ty,p128bl_graph(book,types,[],[],64)),
    u => nol_failure("nested observer: scalar result or root count",fresh))

@unsafe
def p128bl_params(+book: List<&2,KDef>, +ty: KTerm, +params: List<&2,KTerm>, +roots: List<&2,U32>, +types: List<&2,KTerm>, +seen: List<&2,U32>, +fresh: U32, +fuel: U32, +arity: U32) -> NO_Schema:
  nt_choose(NO_Schema,U32.is_eq(fuel,0),u => nol_failure("nested observer: telescope budget",fresh),
    u => p128bl_head(book,nq_layout_type(book,ty),params,roots,types,seen,fresh,U32.sub(fuel,1),arity))

@unsafe
def p128bl_head(+book: List<&2,KDef>, +head: KTerm, +params: List<&2,KTerm>, +roots: List<&2,U32>, +types: List<&2,KTerm>, +seen: List<&2,U32>, +fresh: U32, +fuel: U32, +arity: U32) -> NO_Schema:
  nt_choose(NO_Schema,String.eq(tg(head),"All"),
    u => nt_choose(NO_Schema,U32.is_eq(qt(head),0),
      v => p128bl_params(book,kid(head,1),params,roots,types,Con{ix(head),seen},fresh,fuel,arity),
      v => p128bl_param(book,head,nq_layout_type(book,kid(head,0)),params,roots,types,seen,fresh,fuel,arity)),
    u => p128bl_result(book,head,params,roots,types,seen,fresh,arity))

@unsafe
def p128bl_param(+book: List<&2,KDef>, +head: KTerm, +ty: KTerm, +params: List<&2,KTerm>, +roots: List<&2,U32>, +types: List<&2,KTerm>, +seen: List<&2,U32>, +fresh: U32, +fuel: U32, +arity: U32) -> NO_Schema:
  +scalar = nol_scalar(book,ty)
  nt_choose(NO_Schema,nol_owner(book,ty) && Bool.not(nq_layout_dep(ty,seen)) && U32.is_lt(terms_len(params),arity),
    u => p128bl_params(book,kid(head,1),Con{var(nm(ty),nc_id(fresh)),params},
      nt_choose(List<&2,U32>,scalar,v => roots,v => Con{terms_len(params),roots}),
      nt_choose(List<&2,KTerm>,scalar,v => types,v => Con{ty,types}),
      Con{ix(head),seen},U32.inc(fresh),fuel,arity),
    u => nol_failure("nested observer: unsupported or dependent parameter",fresh))

@unsafe
def p128bl_schema(+book: List<&2,KDef>, +owner: String) -> NO_Schema:
  +d = lookup(book,owner)
  nt_choose(NO_Schema,String.eq(dk(d),"Def") && Bool.not(nc_foreign(d) || nc_native_def(d)) && U32.is_le(nd_arity(book,owner),4),
    u => p128bl_params(book,dt(d),[],[],[],[],0,32,nd_arity(book,owner)),
    u => nol_failure("nested observer: unsupported owner",0))

# Stage1 succeeds unchanged on old schemas. Only its schema-refused candidates
# try the finite concrete graph; failed proofs retain an explicit diagnostic.
@unsafe
def p128br_plan(+book: List<&2,KDef>, +owner: String, +helpers: List<&2,P128BRHelper>) -> NO_Plan:
  +ordinary = no_schema(book,lookup(book,owner),0)
  +schema = nt_choose(NO_Schema,String.is_empty(no_schema_error(ordinary)),u => ordinary,u => p128bl_schema(book,owner))
  nt_choose(NO_Plan,String.is_empty(no_schema_error(schema)),
    u => no_plan_result(owner,schema,noa_analyze_ready(NO_Context{book,owner,schema,helpers})),
    u => NO_Plan{owner,schema,noa_fail(no_schema_error(schema),no_schema_fresh(schema),4096),no_schema_error(schema)})
