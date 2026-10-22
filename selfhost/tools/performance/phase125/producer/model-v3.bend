# Typed-runtime variant; source certificate and exact import verification unchanged.
# Phase125: exact checked append equations -> guarded unique-spine append.
# The original candidate remains the failure path. No source/evaluation reorder.
# Runtime success consumes both inputs; refusal consumes/mutates neither input.

@unsafe
def p125p_equations(+d: KDef, +empty: String, +link: String) -> Bool:
  +z = j_fusion_empty(d)
  +s = j_fusion_link(d)
  +body = j_fusion_after(s,3)
  +call = j_call_spine(kid(body,1),[])
  j_fusion_cases(dv(d),empty,link) &&
    p98_tag_eq(j_fusion_binder(z,0),"Lam") &&
    j_fusion_var(j_fusion_after(z,1),ix(j_fusion_binder(z,0))) &&
    p98_tag_eq(j_fusion_binder(s,2),"Lam") && j_fusion_ctor(body,link,2) &&
    j_fusion_var(kid(body,0),ix(j_fusion_binder(s,0))) &&
    j_fusion_call(call,dn(d),2) &&
    j_fusion_var(kid(call,0),ix(j_fusion_binder(s,1))) &&
    j_fusion_var(kid(call,1),ix(j_fusion_binder(s,2)))

@unsafe
def p125p_owner(+book: List<&2,KDef>, +ty: KTerm, +empty: String, +link: String) -> Bool:
  +h = wnf(book,ty)
  +owner = lookup(book,nm(h))
  +z = lookup(dc(owner),empty)
  +c = lookup(dc(owner),link)
  +tel = wnf(book,j_specialize(book,dt(c),ks(h)))
  +tail = wnf(book,kid(tel,1))
  p98_tag_eq(h,"ADT") && String.eq(dk(owner),"ADT") &&
    j_pure_same_closed(book,h,h,64) && U32.is_eq(j_region_def_count(dc(owner)),2) &&
    Bool.not(String.eq(empty,link)) && String.eq(dk(z),"Ctr") && U32.is_eq(da(z),0) &&
    String.eq(dk(c),"Ctr") && U32.is_eq(da(c),2) &&
    j_pure_same_closed(book,j_specialize(book,dt(z),ks(h)),h,64) &&
    p98_tag_eq(tel,"All") && U32.is_eq(qt(tel),1) &&
    p98_tag_eq(tail,"All") && U32.is_eq(qt(tail),1) &&
    j_pure_same_closed(book,kid(tail,0),h,64) &&
    j_pure_same_closed(book,kid(tail,1),h,64)

@unsafe
def p125p_types(+book: List<&2,KDef>, +d: KDef, +empty: String, +link: String) -> Bool:
  +ty = wnf(book,dt(d))
  +rest = wnf(book,kid(ty,1))
  +owner = wnf(book,kid(ty,0))
  p98_tag_eq(ty,"All") && U32.is_eq(qt(ty),1) &&
    p98_tag_eq(rest,"All") && U32.is_eq(qt(rest),1) &&
    j_pure_same_closed(book,kid(rest,0),owner,64) &&
    j_pure_same_closed(book,kid(rest,1),owner,64) && p125p_owner(book,owner,empty,link)

@unsafe
def p125p_admitted(+book: List<&2,KDef>, +d: KDef) -> Bool:
  nt_choose(Bool,j_fusion_def(d,2) && p98_tag_eq(j_strip(dv(d)),"Mat"),u =>
    nt_choose(Bool,p121f_bounded(dv(d)),v =>
      p125p_equations(d,nm(j_strip(dv(d))),nm(j_strip(kid(j_strip(dv(d)),1)))) &&
      p125p_types(book,d,nm(j_strip(dv(d))),nm(j_strip(kid(j_strip(dv(d)),1)))),v => False{}),u => False{})

# Restrict the first prototype to the existing forwarding factory. This makes
# the reserved scratch/result namespace disjoint without trusting source names.
@unsafe
def p125p_forward(body: List<&2,P113DStmt>) -> Bool:
  match body:
    case Con{P113DCall{Con{+dest,Nil{}},target,args},Con{P113DResult{Con{N111Local{returned},Nil{}}},Nil{}}}:
      String.eq(dest,returned) && Bool.not(String.starts_with(dest,"p125_concat_"))
    case _: False{}

# V2 returns the owning List Term directly. Zero is exclusively refusal:
# exact admitted ADT results have nonzero PAK/CTR tags, with or without RFC.
@unsafe
def p125p_body(left: String, right: String, empty: String, link: String, old: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  [P113DScalar{N111Call{"p125_concat_result",N111U64{},"p125_rt_concat_typed",[
     p111_state(),p111_word(N111Local{left}),p111_word(N111Local{right}),
     N111Arg{N111U32{},N111CtorId{empty}},N111Arg{N111U32{},N111CtorId{link}}]}},
   P113DScalar{N111Bin{"p125_concat_yes",N111U64{},"ne",N111Local{"p125_concat_result"},N111Const{0,0}}},
   P113DIf{N111Local{"p125_concat_yes"},[P113DResult{[N111Local{"p125_concat_result"}]}],old}]

@unsafe
def p125p_wrap(+owner: String, +empty: String, +link: String, +candidate: P113DCandidate) -> P113DCandidate:
  match candidate:
    case P113DCandidate{P113DFunction{+name,+params,1,True{},+body},+error,+calls}:
      p125p_params(owner,empty,link,candidate,name,params,body,error,calls)
    case _: candidate

@unsafe
def p125p_params(+owner: String, +empty: String, +link: String, +old: P113DCandidate,
  +name: String, +params: List<&2,NC_Binding>, +body: List<&2,P113DStmt>, +error: String, +calls: List<&2,String>) -> P113DCandidate:
  match params:
    case Con{NC_Binding{a,+left,ak},Con{NC_Binding{b,+right,bk},Nil{}}}:
      nt_choose(P113DCandidate,String.eq(owner,name) && String.is_empty(error) && p125p_forward(body) &&
        Bool.not(String.starts_with(left,"p125_concat_")) && Bool.not(String.starts_with(right,"p125_concat_")),
        u => P113DCandidate{P113DFunction{name,params,1,True{},p125p_body(left,right,empty,link,body)},error,calls},u => old)
    case _: old

@unsafe
def p125p_candidates(+owner: String, +empty: String, +link: String, candidates: List<&2,P113DCandidate>) -> List<&2,P113DCandidate>:
  match candidates:
    case Nil{}: []
    case Con{head,rest}: Con{p125p_wrap(owner,empty,link,head),p125p_candidates(owner,empty,link,rest)}

@unsafe
def p125p_select(+book: List<&2,KDef>, +d: KDef, +candidates: List<&2,P113DCandidate>) -> List<&2,P113DCandidate>:
  nt_choose(List<&2,P113DCandidate>,p125p_admitted(book,d),u =>
    p125p_candidates(p113d_public(book,dn(d)),nm(j_strip(dv(d))),nm(j_strip(kid(j_strip(dv(d)),1))),candidates),u => candidates)

@unsafe
def p125p_previous_selected(+book: List<&2,KDef>, +name: String, +signatures: List<&2,KDef>, plan: P121FPlan) -> List<&2,P113DCandidate>:
  match plan:
    case P121FNone{}:
      +d = lookup(book,name)
      nt_choose(List<&2,P113DCandidate>,p121c_admitted(book,d),u => p121c_functions(book,d),
        u => p118t_retry(book,name,p113pl_boxed_candidate(book,name,signatures)))
    case _: p121f_functions(book,name,plan)

@unsafe
def p121f_selected(+book: List<&2,KDef>, +name: String, signatures: List<&2,KDef>, plan: P121FPlan) -> List<&2,P113DCandidate>:
  p125p_select(book,lookup(book,name),p125p_previous_selected(book,name,signatures,plan))

# Exact new import contract. The original generic verifier is unchanged.
@unsafe
def p125p_import(+name: String, +typ: N111Type, +args: List<&2,N111Arg>, +schema: KDef, +live: KDef, +ids: N111Ids) -> P111VFlow:
  +empty = p111v_target(p111v_arg(args,3),ids,True{})
  +link = p111v_target(p111v_arg(args,4),ids,True{})
  p111v_step(U32.is_eq(p111v_type(typ),2) && p113e_runtime_args(args) &&
    p111v_args(args,[3,2,2,1,1],live,ids) &&
    Bool.not(String.eq(dk(empty),"Absent")) && U32.is_eq(da(empty),0) &&
    Bool.not(String.eq(dk(link),"Absent")) && U32.is_eq(da(link),2) &&
    Bool.not(String.eq(dn(empty),dn(link))),name,schema,live,"concat value import signature/constructor mismatch")

@unsafe
def p125p_previous_scalar_safe(+stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Call{name,N111U64{},+symbol,+args}:
      nt_choose(Bool,p118t_import(symbol),u => p113e_runtime_args(args),u =>
        nt_choose(Bool,String.eq(symbol,"p113_rt_array_pair"),v => p113p_array_call(symbol,args) && p113e_runtime_args(args),v => p113e_base_scalar_safe(stmt)))
    case _: p113e_base_scalar_safe(stmt)

@unsafe
def p113e_scalar_safe(+stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Call{name,N111U64{},+symbol,+args}:
      nt_choose(Bool,String.eq(symbol,"p125_rt_concat_typed"),u => p113e_runtime_args(args),u => p125p_previous_scalar_safe(stmt))
    case _: p125p_previous_scalar_safe(stmt)

@unsafe
def p125p_previous_stmt(+stmt: P113DStmt, +schema: KDef, +live: KDef, +ids: N111Ids, +ready: KDef, +arity: U32, +result: U32) -> P111VFlow:
  match stmt:
    case P113DScalar{N111Call{+name,+typ,+symbol,+args}}:
      nt_choose(P111VFlow,p118t_import(symbol),u => p118t_import_call(name,typ,symbol,args,schema,live,ids),u =>
        nt_choose(P111VFlow,String.eq(symbol,"p113_rt_array_pair"),v => p113e_product_call(name,typ,symbol,args,schema,live,ids),
          v => p113e_base_stmt(stmt,schema,live,ids,ready,arity,result)))
    case _: p113e_base_stmt(stmt,schema,live,ids,ready,arity,result)

@unsafe
def p113e_stmt(+stmt: P113DStmt, +schema: KDef, +live: KDef, +ids: N111Ids, +ready: KDef, +arity: U32, +result: U32) -> P111VFlow:
  match stmt:
    case P113DScalar{N111Call{+name,+typ,+symbol,+args}}:
      nt_choose(P111VFlow,String.eq(symbol,"p125_rt_concat_typed"),u => p125p_import(name,typ,args,schema,live,ids),
        u => p125p_previous_stmt(stmt,schema,live,ids,ready,arity,result))
    case _: p125p_previous_stmt(stmt,schema,live,ids,ready,arity,result)

@unsafe
def p125p_inspect(request: NR_Request, name: String) -> Bool:
  match request:
    case NR_Request{source,book,names,paths,scope,bound}: p125p_admitted(book,lookup(book,name))
