# Guard the whole owning worker, before either destructive take. The original
# body remains byte-for-byte in the zero-result branch. Not selected by default.
@unsafe
def p126lr_hygiene(scan: P111VScan) -> Bool:
  match scan:
    case P111VScan{+index,+error,count}:
      String.is_empty(error) && String.eq(dk(p111v_get(index,"p126_reshape_result")),"Absent") &&
        String.eq(dk(p111v_get(index,"p126_reshape_yes")),"Absent")

@unsafe
def p126lr_body(left: String, right: String, cid: String, old: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  [P113DScalar{N111Call{"p126_reshape_result",N111U64{},"p126_rt_transpose2",[
     p111_state(),p111_word(N111Local{left}),p111_word(N111Local{right}),N111Arg{N111U32{},N111CtorId{cid}}]}},
   P113DScalar{N111Bin{"p126_reshape_yes",N111U64{},"ne",N111Local{"p126_reshape_result"},N111Const{0,0}}},
   P113DIf{N111Local{"p126_reshape_yes"},[P113DResult{[N111Local{"p126_reshape_result"}]}],old}]

@unsafe
def p126lr_params(+owner: String, +cid: String, +old: P113DCandidate, +name: String,
  +params: List<&2,NC_Binding>, +body: List<&2,P113DStmt>, +error: String, +calls: List<&2,String>) -> P113DCandidate:
  match params:
    case Con{NC_Binding{a,+left,ak},Con{NC_Binding{b,+right,bk},Nil{}}}:
      nt_choose(P113DCandidate,String.eq(owner,name) && String.is_empty(error),u =>
        nt_choose(P113DCandidate,p126lr_hygiene(p113e_schema(body,p113e_seed(params))),v =>
          P113DCandidate{P113DFunction{name,params,1,True{},p126lr_body(left,right,cid,body)},error,calls},v => old),u => old)
    case _: old

@unsafe
def p126lr_wrap(+owner: String, +cid: String, +candidate: P113DCandidate) -> P113DCandidate:
  match candidate:
    case P113DCandidate{P113DFunction{+name,+params,1,True{},+body},+error,+calls}:
      p126lr_params(owner,cid,candidate,name,params,body,error,calls)
    case _: candidate

@unsafe
def p126lr_candidates(+owner: String, +cid: String, candidates: List<&2,P113DCandidate>) -> List<&2,P113DCandidate>:
  match candidates:
    case Nil{}: []
    case Con{head,rest}: Con{p126lr_wrap(owner,cid,head),p126lr_candidates(owner,cid,rest)}

@unsafe
def p126lr_select(+book: List<&2,KDef>, +d: KDef, +candidates: List<&2,P113DCandidate>) -> List<&2,P113DCandidate>:
  nt_choose(List<&2,P113DCandidate>,p126lr_admitted(book,d),u =>
    p126lr_candidates(p113d_public(book,dn(d)),nc_ctor_identity(book,nm(j_strip(dv(d)))),candidates),u => candidates)

@unsafe
def p126lr_previous_selected(+book: List<&2,KDef>, +name: String, signatures: List<&2,KDef>, plan: P121FPlan) -> List<&2,P113DCandidate>:
  p125p_select(book,lookup(book,name),p125p_previous_selected(book,name,signatures,plan))

@unsafe
def p121f_selected(+book: List<&2,KDef>, +name: String, signatures: List<&2,KDef>, plan: P121FPlan) -> List<&2,P113DCandidate>:
  p126lr_select(book,lookup(book,name),p126lr_previous_selected(book,name,signatures,plan))

# Exact additive import: state, two U64 owning terms, same authenticated
# constructor reference of arity2, U64 result. Generic verifier unchanged.
@unsafe
def p126lr_import(+name: String, +typ: N111Type, +args: List<&2,N111Arg>, +schema: KDef, +live: KDef, +ids: N111Ids) -> P111VFlow:
  +cid = p111v_target(p111v_arg(args,3),ids,True{})
  p111v_step(U32.is_eq(p111v_type(typ),2) && p113e_runtime_args(args) &&
    p111v_args(args,[3,2,2,1],live,ids) && Bool.not(String.eq(dk(cid),"Absent")) && U32.is_eq(da(cid),2),
    name,schema,live,"local reshape value import signature/constructor mismatch")

@unsafe
def p126lr_previous_scalar_safe(+stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Call{name,N111U64{},+symbol,+args}:
      nt_choose(Bool,String.eq(symbol,"p125_rt_concat_typed"),u => p113e_runtime_args(args),u => p125p_previous_scalar_safe(stmt))
    case _: p125p_previous_scalar_safe(stmt)

@unsafe
def p113e_scalar_safe(+stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Call{name,N111U64{},+symbol,+args}:
      nt_choose(Bool,String.eq(symbol,"p126_rt_transpose2"),u => p113e_runtime_args(args),u => p126lr_previous_scalar_safe(stmt))
    case _: p126lr_previous_scalar_safe(stmt)

@unsafe
def p126lr_previous_stmt(+stmt: P113DStmt, +schema: KDef, +live: KDef, +ids: N111Ids, +ready: KDef, +arity: U32, +result: U32) -> P111VFlow:
  match stmt:
    case P113DScalar{N111Call{+name,+typ,+symbol,+args}}:
      nt_choose(P111VFlow,String.eq(symbol,"p125_rt_concat_typed"),u => p125p_import(name,typ,args,schema,live,ids),
        u => p125p_previous_stmt(stmt,schema,live,ids,ready,arity,result))
    case _: p125p_previous_stmt(stmt,schema,live,ids,ready,arity,result)

@unsafe
def p113e_stmt(+stmt: P113DStmt, +schema: KDef, +live: KDef, +ids: N111Ids, +ready: KDef, +arity: U32, +result: U32) -> P111VFlow:
  match stmt:
    case P113DScalar{N111Call{+name,+typ,+symbol,+args}}:
      nt_choose(P111VFlow,String.eq(symbol,"p126_rt_transpose2"),u => p126lr_import(name,typ,args,schema,live,ids),
        u => p126lr_previous_stmt(stmt,schema,live,ids,ready,arity,result))
    case _: p126lr_previous_stmt(stmt,schema,live,ids,ready,arity,result)
