

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
def p113e_scalar_safe(+stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Call{name,N111U64{},+symbol,+args}:
      nt_choose(Bool,String.eq(symbol,"p126_rt_nat_divmod"),u => p113e_runtime_args(args),u => p126dp_original_scalar_safe(stmt))
    case _: p126dp_original_scalar_safe(stmt)

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
def p113e_stmt(+stmt: P113DStmt, +schema: KDef, +live: KDef, +ids: N111Ids, +ready: KDef, +arity: U32, +result: U32) -> P111VFlow:
  match stmt:
    case P113DScalar{N111Call{+name,+typ,+symbol,+args}}:
      nt_choose(P111VFlow,String.eq(symbol,"p126_rt_nat_divmod"),u => p126dp_import(name,typ,args,schema,live,ids),
        u => p126dp_original_stmt(stmt,schema,live,ids,ready,arity,result))
    case _: p126dp_original_stmt(stmt,schema,live,ids,ready,arity,result)

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


def p113e_symbol(name: String) -> String:
  "p113d_" ++ nt_fid(name)


@unsafe
def p113e_formals(params: List<&2,NC_Binding>, acc: String) -> String:
  match params:
    case Nil{}: acc
    case Con{NC_Binding{id,word,kind},rest}: p113e_formals(rest,acc ++ ", l " ++ p111q_local(word))


@unsafe
def p113e_arguments(values: List<&2,N111Value>, +ids: N111Ids, acc: String) -> String:
  match values:
    case Nil{}: acc
    case Con{head,rest}: p113e_arguments(rest,ids,acc ++ ", l " ++ p111q_value(head,ids))


@unsafe
def p113e_snapshot(values: List<&2,N111Value>, +ids: N111Ids, +index: U32, code: P111QCode) -> P111QCode:
  match values:
    case Nil{}: code
    case Con{head,rest}: p113e_snapshot(rest,ids,U32.inc(index),p111q_line("%p113_again_" ++ U32.show(index) ++ " =l copy " ++ p111q_value(head,ids) ++ "\n",code))


def p113e_again_end(code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,n,terminal,error}: P111QCode{Con{"jmp @p113_loop\n",chunks},n,True{},error}


@unsafe
def p113e_moves(params: List<&2,NC_Binding>, +index: U32, code: P111QCode) -> P111QCode:
  match params:
    case Nil{}: p113e_again_end(code)
    case Con{NC_Binding{id,word,kind},rest}: p113e_moves(rest,U32.inc(index),p111q_line(p111q_local(word) ++ " =l copy %p113_again_" ++ U32.show(index) ++ "\n",code))


@unsafe
def p113e_load_results(names: List<&2,String>, +index: U32, code: P111QCode) -> P111QCode:
  match names code:
    case Nil{} _: code
    case Con{name,rest} P111QCode{chunks,+n,terminal,error}:
      +at = "%p113_result_at_" ++ U32.show(n)
      +prefix : P111QCode = P111QCode{Con{at ++ " =l add %p113_results, " ++ U32.show(U32.mul(index,8)) ++ "\n",chunks},U32.inc(n),terminal,error}
      p113e_load_results(rest,U32.inc(index),p111q_line(p111q_local(name) ++ " =l loadl " ++ at ++ "\n",prefix))


@unsafe
def p113e_call_emit(+destinations: List<&2,String>, +target: String, +args: List<&2,N111Value>, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match destinations:
    case Con{name,Nil{}}: p111q_line(p111q_local(name) ++ " =l call $" ++ p113e_symbol(target) ++ "(" ++ p113e_arguments(args,ids,"l %state") ++ ")\n",code)
    case _: p113e_load_results(destinations,0,p111q_line("%p113_status =l call $" ++ p113e_symbol(target) ++ "(" ++ p113e_arguments(args,ids,"l %state, l %p113_results") ++ ")\n",code))


@unsafe
def p113e_store_results(values: List<&2,N111Value>, +ids: N111Ids, +index: U32, code: P111QCode) -> P111QCode:
  match values code:
    case Nil{} _: p111q_return("0",code)
    case Con{head,rest} P111QCode{chunks,+n,terminal,error}:
      +at = "%p113_output_at_" ++ U32.show(n)
      +prefix : P111QCode = P111QCode{Con{at ++ " =l add %p113_result_out, " ++ U32.show(U32.mul(index,8)) ++ "\n",chunks},U32.inc(n),terminal,error}
      p113e_store_results(rest,ids,U32.inc(index),p111q_line("storel " ++ p111q_value(head,ids) ++ ", " ++ at ++ "\n",prefix))


@unsafe
def p113e_result_emit(values: List<&2,N111Value>, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match values:
    case Con{value,Nil{}}: p111q_return(p111q_value(value,ids),code)
    case _: p113e_store_results(values,ids,0,code)


@unsafe
def p113e_stmts(body: List<&2,P113DStmt>, +params: List<&2,NC_Binding>, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  p113w_stmts(body,params,ids,code)

@unsafe
def p113e_stmt_emit(stmt: P113DStmt, +params: List<&2,NC_Binding>, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match stmt:
    case P113DScalar{scalar}: p111q_stmt(scalar,ids,code)
    case P113DIf{condition,yes,no}: p113e_if(condition,yes,no,params,ids,code)
    case P113DCall{destinations,target,args}: p113e_call_emit(destinations,target,args,ids,code)
    case P113DResult{values}: p113e_result_emit(values,ids,code)
    case P113DAgain{values}: p113e_moves(params,0,p113e_snapshot(values,ids,0,code))


@unsafe
def p113e_if(+condition: N111Value, +yes: List<&2,P113DStmt>, +no: List<&2,P113DStmt>, +params: List<&2,NC_Binding>, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  +diamond = p113bq_direct(yes,no)
  nt_choose(P111QCode,p113bq_ready(diamond,code),u => p113bq_emit(condition,diamond,ids,code),
    u => p113bq_direct_original(condition,yes,no,params,ids,code))

@unsafe
def p113e_if_yes(+label: U32, +no: List<&2,P113DStmt>, +params: List<&2,NC_Binding>, +ids: N111Ids, yes: P111QCode) -> P111QCode:
  match yes:
    case P111QCode{chunks,n,terminal,error}:
      +prefix = nt_choose(List<&2,String>,terminal,u => chunks,u => Con{"jmp " ++ p111q_label(U32.add(label,2)) ++ "\n",chunks})
      p111q_if_done(label,terminal,p113e_stmts(no,params,ids,P111QCode{Con{p111q_label(U32.inc(label)) ++ "\n",prefix},n,False{},error}))


@unsafe
def p113e_allocas(body: List<&2,P113DStmt>, acc: List<&2,String>) -> List<&2,String>:
  match body:
    case Nil{}: acc
    case Con{P113DScalar{stmt},rest}: p113e_allocas(rest,p111q_alloca(stmt,acc))
    case Con{P113DIf{condition,yes,no},rest}: p113e_allocas(rest,p113e_allocas(no,p113e_allocas(yes,acc)))
    case Con{stmt,rest}: p113e_allocas(rest,acc)


@unsafe
def p113e_multi(body: List<&2,P113DStmt>) -> Bool:
  match body:
    case Nil{}: False{}
    case Con{P113DCall{destinations,target,args},rest}: U32.is_gt(nt_count(String,destinations),1) || p113e_multi(rest)
    case Con{P113DIf{condition,yes,no},rest}: p113e_multi(yes) || p113e_multi(no) || p113e_multi(rest)
    case Con{stmt,rest}: p113e_multi(rest)


@unsafe
def p113e_private(function: P113DFunction, +ids: N111Ids) -> String:
  match function:
    case P113DFunction{name,+params,+result,public,+body}:
      +allocas = p113e_allocas(body,["%v_scratch =l alloc8 2048\n"])
      +allocas = nt_choose(List<&2,String>,p113e_multi(body),u => Con{"%p113_results =l alloc8 64\n",allocas},u => allocas)
      "function l $" ++ p113e_symbol(name) ++ "(" ++ p113e_formals(params,nt_choose(String,U32.is_eq(result,1),u => "l %state",u => "l %state, l %p113_result_out")) ++ ") {\n@entry\n" ++
        p144e_body_tail(p113e_stmts(body,params,ids,P111QCode{Con{"@p113_loop\n",Con{"jmp @p113_loop\n",allocas}},0,False{},""}),"}\n")

@unsafe
def p113e_private_chunks(functions: List<&2,P113DFunction>, +ids: N111Ids, acc: List<&2,String>) -> List<&2,String>:
  match functions:
    case Nil{}: nt_reverse(String,acc,[])
    case Con{function,rest}: p113e_private_chunks(rest,ids,Con{p113e_private(function,ids),acc})


@unsafe
def p113e_public_args(+arity: U32, +index: U32, +acc: String) -> String:
  nt_choose(String,U32.is_eq(index,arity),u => acc,u => p113e_public_args(arity,U32.inc(index),acc ++ ", l %p113_arg_" ++ U32.show(index)))


@unsafe
def p113e_public_loads(+arity: U32, +index: U32, +acc: String) -> String:
  nt_choose(String,U32.is_eq(index,arity),u => acc,u =>
    p113e_public_loads(arity,U32.inc(index),acc ++ "%p113_arg_" ++ U32.show(index) ++ " =l call $p111_rt_reg_get(l %state, w " ++ U32.show(index) ++ ")\n"))


@unsafe
def p113e_public(+name: String, +arity: U32) -> String:
  "export function l $" ++ p111q_symbol(name) ++ "(l %state) {\n@entry\n%p113_public_out =l alloc8 8\n" ++
    p113e_public_loads(arity,0,"") ++ "%p113_public_value =l call $" ++ p113e_symbol(name) ++ "(" ++ p113e_public_args(arity,0,"l %state") ++ ")\n" ++
    "storel %p113_public_value, %p113_public_out\n%p113_public_reply =l call $p111_rt_return(l %state, l %p113_public_out, w 1)\nret %p113_public_reply\n}\n"


@unsafe
def p113e_public_chunks(segments: List<&2,N111Segment>, +direct: KDef, index: P112FusionIndex,
    ids: N111Ids, +ready: KDef, acc: List<&2,String>) -> List<&2,String>:
  p124r_public_chunks(segments,direct,index,ids,ready,p124r_view(ready,direct),acc)

@unsafe
def p113e_public_chunk(+segment: N111Segment, +direct: KDef, +index: P112FusionIndex, +ids: N111Ids, +ready: KDef) -> String:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,body}:
      +function = p111v_get(direct,name)
      nt_choose(String,String.eq(dk(function),"P113Direct") && U32.is_eq(ix(dv(function)),1),
        u => p113e_public(name,arity),u => p114hf_planned(segment,index,ids,ready,p114h_plan(segment,index,ready)))

@unsafe
def p113e_old_private(+segment: N111Segment, +plan: P112WorkerPlan, +direct: KDef, +ids: N111Ids) -> String:
  match segment plan:
    case N111Segment{+name,arity,result,incoming,flags,body} P112WorkerPlan{valid,calls,+params,nodes}:
      +function = p111v_get(direct,name)
      nt_choose(String,valid && String.eq(dk(function),"P113Direct") && U32.is_eq(ix(dv(function)),1) && U32.is_eq(da(function),nt_count(String,params)),
        u => "function l $" ++ p112w_symbol(name) ++ "(" ++ p112w_formals(params,"l %state") ++ ") {\n@entry\n%p113_forward =l call $" ++ p113e_symbol(name) ++ "(" ++ p112w_formals(params,"l %state") ++ ")\nret %p113_forward\n}\n",
        u => p112w_private(segment,ids,plan))


@unsafe
def p113e_old_private_chunks(entries: List<&2,P112RegionEntry>, +direct: KDef, +ids: N111Ids, acc: List<&2,String>) -> List<&2,String>:
  match entries:
    case Nil{}: acc
    case Con{P112RegionEntry{segment,plan,rank,sites},rest}: p113e_old_private_chunks(rest,direct,ids,Con{p113e_old_private(segment,plan,direct,ids),acc})


@unsafe
def p113e_registered(+segments: List<&2,N111Segment>, +functions: List<&2,P113DFunction>, +index: P112FusionIndex, +ids: N111Ids, registry: P112RegionRegistry) -> List<&2,String>:
  match registry:
    case P112RegionRegistry{ready,symbols,entries,workers,fusions}:
      +direct = p113e_signatures(functions,missing())
      nt_append(String,p113e_private_chunks(functions,ids,[]),
        p112c_attach(p113e_public_chunks(segments,direct,index,ids,ready,[]),nt_join(p113e_old_private_chunks(entries,direct,ids,[]),"")))


@unsafe
def p113e_segment_chunks(+segments: List<&2,N111Segment>, +functions: List<&2,P113DFunction>, +ids: N111Ids, +index: P112FusionIndex) -> List<&2,String>:
  p113e_registered(segments,functions,index,ids,p112c_index_with(segments,index))


@unsafe
def p113e_admitted_chunks(bundle: P113DProgram) -> List<&2,String>:
  match bundle:
    case P113DProgram{+original,Nil{}}: p112s_chunks(original)
    case P113DProgram{P112StaticProgram{program,nodes},functions}: p113e_bundle_chunks(program,nodes,functions)


@unsafe
def p113e_bundle_chunks(+program: P111Program, +nodes: List<&2,P112SNode>, functions: List<&2,P113DFunction>) -> List<&2,String>:
  match program:
    case P111Program{+segments,constructors,show,names,effects,pure}:
      +ids = p111q_ids(program)
      nt_append(String,p113e_segment_chunks(segments,functions,ids,p112f_index(segments)),
        nt_append(String,p111q_data_chunks(nt_choose(List<&2,P111QData>,List.is_empty(&2,P112SNode,nodes),u => p111q_tables(program,ids),u => p112s_tables(program,nodes,ids))),[p111q_main()]))


@unsafe
def p113e_checked_chunks(+program: P113DProgram, +error: String) -> List<&2,String>:
  nt_choose(List<&2,String>,String.is_empty(error),u => p113e_admitted_chunks(program),u => ["INVALID_P113_PROGRAM: " ++ error ++ "\n"])


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
def p113e_product_call(+name: String, +typ: N111Type, +symbol: String, +args: List<&2,N111Arg>, +schema: KDef, +live: KDef, +ids: N111Ids) -> P111VFlow:
  p111v_step(U32.is_eq(p111v_type(typ),2) && p113p_array_call(symbol,args) && p113e_runtime_args(args) &&
    p111v_args(args,[3,1,3,1,3,1],live,ids) && p111v_buffer(args,2,p111v_literal(p111v_arg(args,3)),live) &&
    p111v_memory(p111v_arg(args,4),8,2,live,ids),name,schema,live,"product array import signature/count/capacity mismatch")
