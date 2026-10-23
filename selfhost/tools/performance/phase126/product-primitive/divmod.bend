# Phase126: exact Nat.divmod product without a temporary Tuple.
# Original generic verifiers and shared C shape query remain unchanged.

@unsafe
def p126dp_original_let(+book: List<&2,KDef>, +value: KTerm, +body: KTerm, +env: List<&2,NC_Binding>, +id: U32, +target: P113PTarget, +n: U32) -> P113DCode:
  +shape = nt_choose(KTerm,String.eq(tg(value),"NPCall"),
    u => nq_call_shape(book,nm(value),ks(value),p113pl_view(target)),
    u => nq_value_shape(book,value,p113pl_view(target)))
  nt_choose(P113DCode,p113p_known(shape) && p113p_bindable(body,id),
    u => p113pl_bind_flat(book,value,body,env,id,target,n,shape),
    u => p113pl_bind_boxed(book,value,body,env,id,target,n))

@unsafe
def p126dp_original_live_let(+book: List<&2,KDef>, +value: KTerm, +rest: P112Liveness, +env: List<&2,NC_Binding>, +id: U32, +target: P113PTarget, +n: U32) -> P113DCode:
  +shape = nt_choose(KTerm,String.eq(tg(value),"NPCall"),
    u => nq_call_shape(book,nm(value),ks(value),p113pl_view(target)),
    u => nq_value_shape(book,value,p113pl_view(target)))
  nt_choose(P113DCode,p113p_known(shape),
    u => p113px_known(book,value,rest,env,id,target,n,shape),
    u => p113px_boxed(book,value,rest,env,id,target,n))

@unsafe
def p126dp_original_primitive(+name: String, +values: List<&2,N111Value>, +wanted: KTerm, +n: U32) -> P113PValueCode:
  nt_choose(P113PValueCode,p113p_array_pair(name,nt_count(N111Value,values)) && p113p_known(wanted) && String.eq(nm(wanted),"Tuple") && U32.is_eq(ix(wanted),2),
    u => p113p_pair_code(p111_op_id(name),values,n),
    u => nt_choose(P113PValueCode,p113p_known(wanted),
      v => P113PValueCode{[],[],"primitive product shape unsupported"},
      v => p113p_boxed(p113ai_intrinsic(name,values,n))))

@unsafe
def p126dp_original_scalar_safe(+stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Call{name,N111U64{},+symbol,+args}:
      nt_choose(Bool,String.eq(symbol,"p125_rt_concat_typed"),u => p113e_runtime_args(args),u => p125p_previous_scalar_safe(stmt))
    case _: p125p_previous_scalar_safe(stmt)

@unsafe
def p126dp_original_stmt(+stmt: P113DStmt, +schema: KDef, +live: KDef, +ids: N111Ids, +ready: KDef, +arity: U32, +result: U32) -> P111VFlow:
  match stmt:
    case P113DScalar{N111Call{+name,+typ,+symbol,+args}}:
      nt_choose(P111VFlow,String.eq(symbol,"p125_rt_concat_typed"),u => p125p_import(name,typ,args,schema,live,ids),
        u => p125p_previous_stmt(stmt,schema,live,ids,ready,arity,result))
    case _: p125p_previous_stmt(stmt,schema,live,ids,ready,arity,result)

@unsafe
def p126dp_value_shape(+book: List<&2,KDef>, +value: KTerm, +target: NC_Target) -> KTerm:
  nt_choose(KTerm,String.eq(tg(value),"NOp") && U32.is_eq(p111_op_id(nm(value)),70) && U32.is_eq(terms_len(ks(value)),2),
    u => kt("NQShape","Tuple",2,0,[]),u => nq_value_shape(book,value,target))

@unsafe
def p113pl_let(+book: List<&2,KDef>, +value: KTerm, +body: KTerm, +env: List<&2,NC_Binding>, +id: U32, +target: P113PTarget, +n: U32) -> P113DCode:
  +shape = nt_choose(KTerm,String.eq(tg(value),"NPCall"),
    u => nq_call_shape(book,nm(value),ks(value),p113pl_view(target)),
    u => p126dp_value_shape(book,value,p113pl_view(target)))
  nt_choose(P113DCode,p113p_known(shape) && p113p_bindable(body,id),
    u => p113pl_bind_flat(book,value,body,env,id,target,n,shape),
    u => p113pl_bind_boxed(book,value,body,env,id,target,n))

@unsafe
def p113px_let(+book: List<&2,KDef>, +value: KTerm, +rest: P112Liveness, +env: List<&2,NC_Binding>, +id: U32, +target: P113PTarget, +n: U32) -> P113DCode:
  +shape = nt_choose(KTerm,String.eq(tg(value),"NPCall"),
    u => nq_call_shape(book,nm(value),ks(value),p113pl_view(target)),
    u => p126dp_value_shape(book,value,p113pl_view(target)))
  nt_choose(P113DCode,p113p_known(shape),
    u => p113px_known(book,value,rest,env,id,target,n,shape),
    u => p113px_boxed(book,value,rest,env,id,target,n))

@unsafe
def p126dp_code(+left: N111Value, +right: N111Value, +n: U32) -> P113PValueCode:
  +out = "p126dp_out_" ++ U32.show(n)
  +first = "p126dp_first_" ++ U32.show(n)
  +second = "p126dp_second_" ++ U32.show(n)
  P113PValueCode{[
    N111Alloca{out,16,8},
    N111Call{"p126dp_status_" ++ U32.show(n),N111U64{},"p126_rt_nat_divmod",
      [p111_state(),p111_word(left),p111_word(right),N111Arg{N111Ptr{},N111Local{out}}]},
    N111Load{first,N111U64{},N111Local{out},0},
    N111Load{second,N111U64{},N111Local{out},8}],
    [N111Local{first},N111Local{second}],""}

@unsafe
def p126dp_selected(+name: String, +values: List<&2,N111Value>, +wanted: KTerm) -> Bool:
  U32.is_eq(p111_op_id(name),70) && U32.is_eq(nt_count(N111Value,values),2) &&
    p113p_known(wanted) && String.eq(nm(wanted),"Tuple") && U32.is_eq(ix(wanted),2)

@unsafe
def p113p_primitive(+name: String, +values: List<&2,N111Value>, +wanted: KTerm, +n: U32) -> P113PValueCode:
  nt_choose(P113PValueCode,p126dp_selected(name,values,wanted),
    u => p126dp_code(p111_head(values),p111_head(p111_tail(values)),n),
    u => p126dp_original_primitive(name,values,wanted,n))

# Exact additive direct import: original generic N111 call rules are not changed.
@unsafe
def p126dp_import(+name: String, +typ: N111Type, +args: List<&2,N111Arg>, +schema: KDef, +live: KDef, +ids: N111Ids) -> P111VFlow:
  p111v_step(U32.is_eq(p111v_type(typ),2) && p113e_runtime_args(args) &&
    p111v_args(args,[3,2,2,3],live,ids) && p111v_memory(p111v_arg(args,3),8,2,live,ids),
    name,schema,live,"Nat.divmod product import signature/output capacity mismatch")

@unsafe
def p113e_scalar_safe(+stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Call{name,N111U64{},+symbol,+args}:
      nt_choose(Bool,String.eq(symbol,"p126_rt_nat_divmod"),u => p113e_runtime_args(args),u => p126dp_original_scalar_safe(stmt))
    case _: p126dp_original_scalar_safe(stmt)

@unsafe
def p113e_stmt(+stmt: P113DStmt, +schema: KDef, +live: KDef, +ids: N111Ids, +ready: KDef, +arity: U32, +result: U32) -> P111VFlow:
  match stmt:
    case P113DScalar{N111Call{+name,+typ,+symbol,+args}}:
      nt_choose(P111VFlow,String.eq(symbol,"p126_rt_nat_divmod"),u => p126dp_import(name,typ,args,schema,live,ids),
        u => p126dp_original_stmt(stmt,schema,live,ids,ready,arity,result))
    case _: p126dp_original_stmt(stmt,schema,live,ids,ready,arity,result)
