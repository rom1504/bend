# Direct-function legality composes the unchanged N111 scalar type/memory/import
# checker with explicit call signatures and terminal result/loop vectors.
# This is structural verification, not an ownership proof for arbitrary raw IR.
@unsafe
def p113e_signature(function: P113DFunction) -> KDef:
  match function:
    case P113DFunction{name,params,result,public,body}:
      KDef{name,"P113Direct",nt_count(NC_Binding,params),result,atom("Absent"),kt("P113Public","",Bool.to_u32(public),0,[]),[],False{},False{}}

@unsafe
def p113e_insert(+index: KDef, +record: KDef) -> KDef:
  index_set(index,record,index_hash(dn(record),2166136261),32)

@unsafe
def p113e_signatures(functions: List<&2,P113DFunction>, index: KDef) -> KDef:
  match functions:
    case Nil{}: index
    case Con{function,rest}: p113e_signatures(rest,p113e_insert(index,p113e_signature(function)))

@unsafe
def p113e_originals(segments: List<&2,N111Segment>, index: KDef) -> KDef:
  match segments:
    case Nil{}: index
    case Con{N111Segment{name,arity,result,incoming,flags,body},rest}:
      p113e_originals(rest,p113e_insert(index,KDef{name,"P113Original",arity,incoming,atom("Absent"),kt("P113Meta","",flags,result,[]),[],False{},False{}}))

@unsafe
def p113e_seed_params(params: List<&2,NC_Binding>, +scan: P111VScan) -> P111VScan:
  match params scan:
    case Nil{} _: scan
    case Con{NC_Binding{id,+word,kind},rest} P111VScan{+index,error,count}:
      nt_choose(P111VScan,Bool.not(String.eq(dk(p111v_get(index,word)),"Absent")),
        u => P111VScan{index,"duplicate/reserved direct parameter: " ++ word,count},
        u => p113e_seed_params(rest,p111v_decl(word,2,0,False{},scan)))

@unsafe
def p113e_seed(params: List<&2,NC_Binding>) -> P111VScan:
  +state = p111v_put(missing(),"state","parameter",3,2088)
  +scratch = p111v_put(state,"scratch","alloca",3,2048)
  p113e_seed_params(params,P111VScan{scratch,"",2})

@unsafe
def p113e_declare_names(names: List<&2,String>, +scan: P111VScan) -> P111VScan:
  match names:
    case Nil{}: scan
    case Con{head,rest}: p113e_declare_names(rest,p111v_decl(head,2,0,False{},scan))

@unsafe
def p113e_schema(body: List<&2,P113DStmt>, +scan: P111VScan) -> P111VScan:
  match body:
    case Nil{}: scan
    case Con{head,rest}: p113e_schema(rest,p113e_schema_stmt(head,scan))

@unsafe
def p113e_schema_stmt(stmt: P113DStmt, +scan: P111VScan) -> P111VScan:
  match stmt:
    case P113DScalar{scalar}: p111v_schema_stmt(scalar,scan)
    case P113DIf{condition,yes,no}: p113e_schema(no,p113e_schema(yes,scan))
    case P113DCall{destinations,target,args}: p113e_declare_names(destinations,scan)
    case _: scan

@unsafe
def p113e_nonstate_pointer(value: N111Value) -> Bool:
  match value:
    case N111Local{name}: Bool.not(String.eq(name,"state"))
    case _: False{}

@unsafe
def p113e_buffers(args: List<&2,N111Arg>) -> Bool:
  match args:
    case Nil{}: True{}
    case Con{N111Arg{N111Ptr{},value},rest}: p113e_nonstate_pointer(value) && p113e_buffers(rest)
    case Con{arg,rest}: p113e_buffers(rest)

@unsafe
def p113e_runtime_args(args: List<&2,N111Arg>) -> Bool:
  match args:
    case Con{N111Arg{N111Ptr{},N111Local{name}},rest}: String.eq(name,"state") && p113e_buffers(rest)
    case _: False{}

@unsafe
def p113e_scalars(body: List<&2,N111Stmt>) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{head,rest}: p113e_scalar_safe(head) && p113e_scalars(rest)

@unsafe
def p113e_scalar_safe(stmt: N111Stmt) -> Bool:
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
def p113e_values(values: List<&2,N111Value>, +live: KDef, +ids: N111Ids) -> Bool:
  match values:
    case Nil{}: True{}
    case Con{head,rest}: p111v_value(head,2,live,ids) && p113e_values(rest,live,ids)

@unsafe
def p113e_distinct(names: List<&2,String>) -> Bool:
  match names:
    case Nil{}: True{}
    case Con{+head,+rest}: Bool.not(nb_contains(rest,head)) && p113e_distinct(rest)

@unsafe
def p113e_assign_names(names: List<&2,String>, +schema: KDef, live: KDef) -> KDef:
  match names:
    case Nil{}: live
    case Con{head,rest}: p113e_assign_names(rest,schema,p111v_assign(head,schema,live))

@unsafe
def p113e_call(+destinations: List<&2,String>, +target: String, +args: List<&2,N111Value>, +schema: KDef, +live: KDef, +ids: N111Ids, +ready: KDef) -> P111VFlow:
  +signature = p111v_get(ready,target)
  nt_choose(P111VFlow,String.eq(dk(signature),"P113Direct") && U32.is_eq(da(signature),nt_count(N111Value,args)) &&
    U32.is_eq(dx(signature),nt_count(String,destinations)) && p113e_distinct(destinations) && p113e_values(args,live,ids),
    u => P111VFlow{p113e_assign_names(destinations,schema,live),False{},""},
    u => P111VFlow{live,False{},"unknown/cyclic direct call or argument/result mismatch: " ++ target})

@unsafe
def p113e_vector(+values: List<&2,N111Value>, +count: U32, +live: KDef, +ids: N111Ids) -> P111VFlow:
  nt_choose(P111VFlow,U32.is_eq(nt_count(N111Value,values),count) && p113e_values(values,live,ids),
    u => P111VFlow{live,True{},""},u => P111VFlow{live,False{},"direct terminal vector has wrong arity/type or undefined value"})

@unsafe
def p113e_stmt(stmt: P113DStmt, +schema: KDef, +live: KDef, +ids: N111Ids, +ready: KDef, +arity: U32, +result: U32) -> P111VFlow:
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
def p113e_body(body: List<&2,P113DStmt>, +schema: KDef, +flow: P111VFlow, +ids: N111Ids, +ready: KDef, +arity: U32, +result: U32) -> P111VFlow:
  match body flow:
    case Nil{} _: flow
    case Con{head,rest} P111VFlow{live,terminal,+error}:
      nt_choose(P111VFlow,Bool.not(String.is_empty(error)),u => flow,u =>
        nt_choose(P111VFlow,terminal,u => P111VFlow{live,True{},"statement follows direct terminal edge"},
          u => p113e_body(rest,schema,p113e_stmt(head,schema,live,ids,ready,arity,result),ids,ready,arity,result)))

@unsafe
def p113e_flow(+body: List<&2,P113DStmt>, +seed: KDef, +ids: N111Ids, +ready: KDef, +arity: U32, +result: U32, scan: P111VScan) -> String:
  match scan:
    case P111VScan{schema,+error,+count}:
      nt_choose(String,Bool.not(String.is_empty(error)),u => error,u =>
        nt_choose(String,U32.is_gt(count,65535),u => "too many direct locals",
          u => p111v_finish(p113e_body(body,schema,P111VFlow{seed,False{},""},ids,ready,arity,result))))

@unsafe
def p113e_seeded(+body: List<&2,P113DStmt>, +ids: N111Ids, +ready: KDef, +arity: U32, +result: U32, +scan: P111VScan) -> String:
  match scan:
    case P111VScan{seed,error,count}: p113e_flow(body,seed,ids,ready,arity,result,p113e_schema(body,scan))

@unsafe
def p113e_function(+function: P113DFunction, +ids: N111Ids, +ready: KDef) -> String:
  match function ids:
    case P113DFunction{+name,+params,+result,+public,+body} N111Ids{+original,constructors}:
      +old = p111v_get(original,name)
      nt_choose(String,Bool.not(p111v_raw_name(name)) || Bool.not(String.eq(dk(p111v_get(ready,name)),"Absent")),u => "invalid/duplicate direct function identity",u =>
      nt_choose(String,U32.is_gt(nt_count(NC_Binding,params),255) || U32.is_lt(result,1) || U32.is_gt(result,8),u => "direct signature exceeds ABI boundary",u =>
      nt_choose(String,public && (String.eq(dk(old),"Absent") || Bool.not(U32.is_eq(nt_count(NC_Binding,params),da(old))) || Bool.not(U32.is_eq(result,1)) || Bool.not(U32.is_eq(dx(old),0)) || Bool.not(U32.is_eq(ix(dv(old)),0)) || Bool.not(U32.is_eq(qt(dv(old)),1))),
        u => "public direct wrapper does not preserve original scalar ABI",
        u => p113e_seeded(body,ids,ready,nt_count(NC_Binding,params),result,p113e_seed(params)))))

@unsafe
def p113e_functions(functions: List<&2,P113DFunction>, +ids: N111Ids, +ready: KDef) -> String:
  match functions:
    case Nil{}: ""
    case Con{+function,rest}:
      +error = p113e_function(function,ids,ready)
      nt_choose(String,String.is_empty(error),u => p113e_functions(rest,ids,p113e_insert(ready,p113e_signature(function))),u => error)

@unsafe
def p113e_verify_original(original: P111Program, functions: List<&2,P113DFunction>, +error: String) -> String:
  match original:
    case P111Program{segments,constructors,show,names,effects,pure}:
      nt_choose(String,String.is_empty(error),
        u => p113e_functions(functions,N111Ids{p113e_originals(segments,missing()),ns_ctor_index(constructors,missing())},missing()),u => error)

@unsafe
def p113e_verified_original(program: P113DProgram, error: String) -> String:
  match program:
    case P113DProgram{P112StaticProgram{original,nodes},functions}: p113e_verify_original(original,functions,error)

@unsafe
def p113e_verify(+program: P113DProgram) -> String:
  match program:
    case P113DProgram{original,functions}: p113e_verified_original(program,p112s_verify(original))
