# Optional product-runtime profile. Exact renamed baseline declarations below
# preserve scalar fallback; apply this file only as explicit final overrides.

@unsafe
def p113e_base_scalar_safe(stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Set{name,N111Ptr{},value}: False{}
    case N111Set{name,typ,value}: True{}
    case N111Bin{name,N111Ptr{},op,left,right}: False{}
    case N111Bin{name,typ,op,left,right}: True{}
    case N111Call{name,N111U64{},symbol,args}:
      (p112t_runtime_call(symbol) || String.eq(symbol,"p111_rt_fail")) && p113e_runtime_args(args)
    case N111If{condition,yes,no}: p113e_scalars(yes) && p113e_scalars(no)
    case N111Load{name,N111Ptr{},base,offset}: False{}
    case N111Load{name,typ,base,offset}: p113e_nonstate_pointer(base)
    case N111Store{N111Ptr{},base,offset,value}: False{}
    case N111Store{typ,base,offset,value}: p113e_nonstate_pointer(base)
    case N111Alloca{name,bytes,align}: True{}
    case _: False{}


@unsafe
def p113e_base_stmt(stmt: P113DStmt, +schema: KDef, +live: KDef, +ids: N111Ids, +ready: KDef, +arity: U32, +result: U32) -> P111VFlow:
  match stmt:
    case P113DScalar{+scalar}:
      nt_choose(P111VFlow,p113e_scalar_safe(scalar),
        u => p111v_stmt(scalar,schema,live,ids,arity,0,result),
        u => P111VFlow{live,False{},"scheduler/state/terminal operation in direct scalar block"})
    case P113DIf{+condition,yes,no}:
      nt_choose(P111VFlow,p111v_value(condition,1,live,ids),
        u => p111v_join(p113e_body(yes,schema,P111VFlow{live,False{},""},ids,ready,arity,result),p113e_body(no,schema,P111VFlow{live,False{},""},ids,ready,arity,result)),
        u => P111VFlow{live,False{},"direct condition must be a definitely assigned U32"})
    case P113DCall{destinations,target,args}: p113e_call(destinations,target,args,schema,live,ids,ready)
    case P113DResult{values}: p113e_vector(values,result,live,ids)
    case P113DAgain{values}: p113e_vector(values,arity,live,ids)

@unsafe
def p113e_scalar_safe(+stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Call{name,N111U64{},+symbol,+args}:
      nt_choose(Bool,String.eq(symbol,"p113_rt_array_pair"),u => p113p_array_call(symbol,args) && p113e_runtime_args(args),u => p113e_base_scalar_safe(stmt))
    case _: p113e_base_scalar_safe(stmt)

@unsafe
def p113e_product_call(+name: String, +typ: N111Type, +symbol: String, +args: List<&2,N111Arg>, +schema: KDef, +live: KDef, +ids: N111Ids) -> P111VFlow:
  p111v_step(U32.is_eq(p111v_type(typ),2) && p113p_array_call(symbol,args) && p113e_runtime_args(args) &&
    p111v_args(args,[3,1,3,1,3,1],live,ids) && p111v_buffer(args,2,p111v_literal(p111v_arg(args,3)),live) &&
    p111v_memory(p111v_arg(args,4),8,2,live,ids),name,schema,live,"product array import signature/count/capacity mismatch")

@unsafe
def p113e_stmt(+stmt: P113DStmt, +schema: KDef, +live: KDef, +ids: N111Ids, +ready: KDef, +arity: U32, +result: U32) -> P111VFlow:
  match stmt:
    case P113DScalar{N111Call{name,typ,+symbol,args}}:
      nt_choose(P111VFlow,String.eq(symbol,"p113_rt_array_pair"),u => p113e_product_call(name,typ,symbol,args,schema,live,ids),
        u => p113e_base_stmt(stmt,schema,live,ids,ready,arity,result))
    case _: p113e_base_stmt(stmt,schema,live,ids,ready,arity,result)

