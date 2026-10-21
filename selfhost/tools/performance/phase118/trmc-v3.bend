# Allocation-only, structured tail recursion modulo a final constructor field.
# The generic P112 program remains intact. New direct workers have two hidden
# full-word formals; neither is exposed to source liveness/ownership inference.
# Runtime helpers own the pending destination protocol, with ordinary sealing.

@unsafe
def p118t_target(+target: P113PTarget) -> Bool:
  p113pl_tail(target) && String.eq(tg(p113pl_shape(target)),"P118TRMC")

def p118t_state() -> List<&2,N111Value>:
  [N111Local{"p118_root"},N111Local{"p118_parent"}]

@unsafe
def p118t_tail_args(args: List<&2,N111Value>) -> List<&2,N111Value>:
  nt_append(N111Value,args,p118t_state())

@unsafe
def p118t_eligible(+term: KTerm, +target: P113PTarget, +n: U32) -> Bool:
  +shape = p113pl_shape(target)
  p118t_target(target) && ntr_eligible(term,
    NC_Destination{[],atom("NTRMC"),"",nm(shape),nd_entry_params(ix(shape),0),True{},[]},n)

@unsafe
def p118t_prefix(values: List<&2,N111Value>, +count: U32) -> List<&2,N111Value>:
  match values count:
    case _ 0: []
    case Con{head,rest} _: Con{head,p118t_prefix(rest,U32.sub(count,1))}
    case _ _: []

@unsafe
def p118t_rest(+values: List<&2,N111Value>, +count: U32) -> List<&2,N111Value>:
  match values count:
    case _ 0: values
    case Con{head,rest} _: p118t_rest(rest,U32.sub(count,1))
    case _ _: []

@unsafe
def p118t_finish(values: List<&2,N111Value>, +n: U32) -> P113DCode:
  match values:
    case Con{word,Nil{}}:
      +result = "p118_finished_" ++ U32.show(n)
      P113DCode{[
        P113DScalar{N111Call{result,N111U64{},"p118_rt_finish",
          [p111_state(),p111_word(N111Local{"p118_root"}),p111_word(N111Local{"p118_parent"}),p111_word(word)]}},
        P113DResult{[N111Local{result}]}],U32.inc(n),"",[]}
    case _: p113d_fail("TRMC terminal result must be boxed",n)

@unsafe
def p118t_completed(+n: U32, value: P113PValueCode) -> P113DCode:
  match value:
    case P113PValueCode{body,values,+error}:
      nt_choose(P113DCode,String.is_empty(error),
        u => p113d_prepend(body,p118t_finish(values,n)),u => p113d_fail(error,n))

@unsafe
def p113pl_output(+shape: KTerm, +values: List<&2,N111Value>, +target: P113PTarget, +n: U32) -> P113DCode:
  nt_choose(P113DCode,p118t_target(target),
    u => p118t_completed(n,p113p_transfer(shape,atom("Absent"),values)),
    u => p113pl_emitted(target,n,p113p_transfer(shape,p113pl_shape(target),values)))

@unsafe
def p113pl_done(+values: List<&2,N111Value>, +target: P113PTarget, +n: U32) -> P113DCode:
  nt_choose(P113DCode,p118t_target(target),u => p118t_finish(values,n),
    u => p118t_original_done(values,target,n))

@unsafe
def p113pl_call_result(+name: String, +args: List<&2,N111Value>, +shape: KTerm, +target: P113PTarget, +n: U32) -> P113DCode:
  nt_choose(P113DCode,p118t_target(target) && String.eq(name,p113pl_owner(target)),
    u => nt_choose(P113DCode,String.eq(tg(shape),"Absent"),
      v => P113DCode{[P113DAgain{p118t_tail_args(args)}],n,"",[]},
      v => p113d_fail("TRMC self call must retain boxed ABI",n)),
    u => p118t_original_call_result(name,args,shape,target,n))

@unsafe
def p113pl_ctor(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32, literal: NC_Literal) -> P113DCode:
  nt_choose(P113DCode,p118t_eligible(t,target,n),u =>
    p113pl_lower(book,ntr_sequence(nm(t),terms_len(ntr_prefix(ks(t))),
      nt_append(KTerm,ntr_prefix(ks(t)),nd_args(ntr_last(ks(t)),[])),[],n),
      env,target,U32.add(n,U32.add(terms_len(ntr_prefix(ks(t))),ix(p113pl_shape(target))))),
    u => p118t_original_ctor(book,t,env,target,n,literal))

@unsafe
def p118t_extend(+t: KTerm, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  +values = p111_values(ks(t),env)
  +count = ix(t)
  +node = "p118_node_" ++ U32.show(n)
  +root = "p118_next_root_" ++ U32.show(n)
  +empty = "p118_root_empty_" ++ U32.show(n)
  +valid = p118t_target(target) && nd_match_vars(ks(t)) && U32.is_ge(count,1) && U32.is_le(count,7) &&
    U32.is_eq(terms_len(ks(t)),U32.add(count,ix(p113pl_shape(target)))) && U32.is_eq(p111_special(nm(t)),0)
  nt_choose(P113DCode,valid,u =>
    p113d_prepend(nt_append(N111Stmt,p111_store(p118t_prefix(values,count),0),[
      N111Call{node,N111U64{},"p118_rt_extend",[p111_state(),p111_word(N111Local{"p118_parent"}),
        N111Arg{N111U32{},N111CtorId{nm(t)}},p111_scratch(),p111_u32(count)]},
      N111Bin{empty,N111U64{},"eq",N111Local{"p118_root"},N111Const{0,0}},
      N111If{N111Local{empty},[N111Set{root,N111U64{},N111Local{node}}],[N111Set{root,N111U64{},N111Local{"p118_root"}}]}]),
      P113DCode{[P113DAgain{nt_append(N111Value,p118t_rest(values,count),[N111Local{root},N111Local{node}])}],U32.inc(n),"",[]}),
    u => p113d_fail("TRMC invalid private construction",n))

@unsafe
def p113pl_live(book,t,env,target,n):
  nt_choose(P113DCode,String.eq(tg(t),"NTRCons"),u => p118t_extend(t,env,target,n),
    u => p118t_original_live(book,t,env,target,n))

@unsafe
def p118t_has_extend(body: List<&2,P113DStmt>) -> Bool:
  match body:
    case Nil{}: False{}
    case Con{P113DScalar{N111Call{name,typ,symbol,args}},rest}:
      String.eq(symbol,"p118_rt_extend") || p118t_has_extend(rest)
    case Con{P113DIf{condition,yes,no},rest}: p118t_has_extend(yes) || p118t_has_extend(no) || p118t_has_extend(rest)
    case Con{stmt,rest}: p118t_has_extend(rest)

@unsafe
def p118t_ready(+name: String, +params: List<&2,NC_Binding>, +old: P113DCandidate, code: P113DCode) -> List<&2,P113DCandidate>:
  match code:
    case P113DCode{+body,fresh,+error,+calls}:
      +private = "$p118.trmc." ++ name
      +arity = nt_count(NC_Binding,params)
      +hidden = [NC_Binding{nc_id(arity),"p118_root",N_W64{}},NC_Binding{nc_id(U32.inc(arity)),"p118_parent",N_W64{}}]
      nt_choose(List<&2,P113DCandidate>,String.is_empty(error) && p118t_has_extend(body),u => [
        P113DCandidate{P113DFunction{private,nt_append(NC_Binding,params,hidden),1,False{},body},"",calls},
        P113DCandidate{P113DFunction{name,params,1,True{},[
          P113DCall{["p118_public_result"],private,nt_append(N111Value,p113pl_locals(nc_words(params)),[N111Const{0,0},N111Const{0,0}])},
          P113DResult{[N111Local{"p118_public_result"}]}]},"",[private]}],u => [old])

@unsafe
def p118t_retry(+book: List<&2,KDef>, +name: String, +old: P113DCandidate) -> List<&2,P113DCandidate>:
  match old:
    case P113DCandidate{P113DFunction{+owner,+params,result,public,body},+error,calls}:
      +arity = nt_count(NC_Binding,params)
      nt_choose(List<&2,P113DCandidate>,String.eq(error,"product non-tail self call") &&
        Bool.not(String.starts_with(name,"$")) && U32.is_ge(arity,1) && U32.is_le(arity,8),u =>
        p118t_retry_body(book,name,owner,params,old,nc_compact_definition(book,lookup(book,name),0)),u => [old])

@unsafe
def p118t_retry_body(+book: List<&2,KDef>, +name: String, +owner: String, +params: List<&2,NC_Binding>, +old: P113DCandidate, +body: KTerm) -> List<&2,P113DCandidate>:
  +arity = nt_count(NC_Binding,params)
  nt_choose(List<&2,P113DCandidate>,U32.is_gt(nq_layout_remaining([body],513),0),u =>
    p118t_ready(owner,params,old,p113pl_lower(book,nd_reapply(body,nd_entry_args(params)),params,
      P113PTarget{[],kt("P118TRMC",name,arity,0,[]),True{},owner,[]},arity)),u => [old])

@unsafe
def p113pl_candidates(+book: List<&2,KDef>, names: List<&2,String>, +bangs: List<&2,String>, +signatures: List<&2,KDef>) -> List<&2,P113DCandidate>:
  match names:
    case Nil{}: []
    case Con{+name,+rest}:
      +definition = lookup(book,name)
      +info = lookup(signatures,name)
      nt_choose(List<&2,P113DCandidate>,String.eq(dk(definition),"Def") &&
        Bool.not(nc_native_def(definition) || nc_foreign(definition) || nb_contains(bangs,name)) && U32.is_le(nd_arity(book,name),32),
        u => nt_append(P113DCandidate,p118t_retry(book,name,p113pl_boxed_candidate(book,name,signatures)),
          nt_choose(List<&2,P113DCandidate>,String.eq(tg(dv(info)),"NQSig"),
            v => Con{p113pl_flat_candidate(book,name,signatures),p113pl_candidates(book,rest,bangs,signatures)},
            v => p113pl_candidates(book,rest,bangs,signatures))),
        u => p113pl_candidates(book,rest,bangs,signatures))

# Additive direct-only import contracts. Generic segment import authority is
# unchanged. The source retry owns the hole protocol; this checker owns machine
# signatures, definite assignment, constructor arity, and local-buffer bounds.
@unsafe
def p118t_import(+symbol: String) -> Bool:
  String.eq(symbol,"p118_rt_extend") || String.eq(symbol,"p118_rt_finish")

@unsafe
def p118t_import_contract(+symbol: String, +args: List<&2,N111Arg>, +live: KDef, +ids: N111Ids) -> Bool:
  nt_choose(Bool,String.eq(symbol,"p118_rt_extend"),u =>
    p118t_extend_contract(args,live,ids,p111v_target(p111v_arg(args,2),ids,True{})),u =>
    String.eq(symbol,"p118_rt_finish") && p111v_args(args,[3,2,2,2],live,ids))

@unsafe
def p118t_extend_contract(+args: List<&2,N111Arg>, +live: KDef, +ids: N111Ids, +constructor: KDef) -> Bool:
  +count = p111v_literal(p111v_arg(args,4))
  p111v_args(args,[3,2,1,3,1],live,ids) && U32.is_ge(count,1) && U32.is_le(count,7) &&
    Bool.not(String.eq(dk(constructor),"Absent")) && U32.is_eq(da(constructor),U32.inc(count)) &&
    p111v_buffer(args,3,count,live)

@unsafe
def p118t_import_call(+name: String, +typ: N111Type, +symbol: String, +args: List<&2,N111Arg>, +schema: KDef, +live: KDef, +ids: N111Ids) -> P111VFlow:
  p111v_step(U32.is_eq(p111v_type(typ),2) && p113e_runtime_args(args) && p118t_import_contract(symbol,args,live,ids),
    name,schema,live,"TRMC import signature/constructor/capacity mismatch")

@unsafe
def p113e_scalar_safe(+stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Call{name,N111U64{},+symbol,+args}:
      nt_choose(Bool,p118t_import(symbol),u => p113e_runtime_args(args),u =>
        nt_choose(Bool,String.eq(symbol,"p113_rt_array_pair"),v => p113p_array_call(symbol,args) && p113e_runtime_args(args),v => p113e_base_scalar_safe(stmt)))
    case _: p113e_base_scalar_safe(stmt)

@unsafe
def p113e_stmt(+stmt: P113DStmt, +schema: KDef, +live: KDef, +ids: N111Ids, +ready: KDef, +arity: U32, +result: U32) -> P111VFlow:
  match stmt:
    case P113DScalar{N111Call{+name,+typ,+symbol,+args}}:
      nt_choose(P111VFlow,p118t_import(symbol),u => p118t_import_call(name,typ,symbol,args,schema,live,ids),u =>
        nt_choose(P111VFlow,String.eq(symbol,"p113_rt_array_pair"),v => p113e_product_call(name,typ,symbol,args,schema,live,ids),
          v => p113e_base_stmt(stmt,schema,live,ids,ready,arity,result)))
    case _: p113e_base_stmt(stmt,schema,live,ids,ready,arity,result)
