

@unsafe
def p113i_bucket(name: String, values: List<&2,P113DFunction>) -> Maybe<&2,P113DFunction>:
  match values:
    case Nil{}: None{}
    case Con{+head,rest}: p113i_bucket_head(name,head,rest)


@unsafe
def p113i_bucket_head(+name: String, +head: P113DFunction, rest: List<&2,P113DFunction>) -> Maybe<&2,P113DFunction>:
  match head:
    case P113DFunction{key,params,result,public,body}:
      nt_choose(Maybe<&2,P113DFunction>,String.eq(name,key),u => Some{head},u => p113i_bucket(name,rest))


@unsafe
def p113i_get(table: P113ITable, +name: String, +hash: U32, +depth: U32) -> Maybe<&2,P113DFunction>:
  match table:
    case P113IEmpty{}: None{}
    case P113IBucket{values}: p113i_bucket(name,values)
    case P113INode{zero,one}:
      nt_choose(Maybe<&2,P113DFunction>,U32.is_eq(U32.and(hash,1),0),
        u => p113i_get(zero,name,U32.shr(hash),U32.inc(depth)),
        u => p113i_get(one,name,U32.shr(hash),U32.inc(depth)))


@unsafe
def p113i_put(+table: P113ITable, +function: P113DFunction, +hash: U32, +depth: U32) -> P113ITable:
  nt_choose(P113ITable,U32.is_eq(depth,32),u => p113i_put_leaf(table,function),
    u => p113i_put_node(table,function,hash,depth))


@unsafe
def p113i_put_leaf(table: P113ITable, function: P113DFunction) -> P113ITable:
  match table:
    case P113IBucket{values}: P113IBucket{Con{function,values}}
    case _: P113IBucket{[function]}


@unsafe
def p113i_put_node(table: P113ITable, +function: P113DFunction, +hash: U32, +depth: U32) -> P113ITable:
  match table:
    case P113INode{+zero,+one}: p113i_put_branch(zero,one,function,hash,depth)
    case _: p113i_put_branch(P113IEmpty{},P113IEmpty{},function,hash,depth)


@unsafe
def p113i_put_branch(+zero: P113ITable, +one: P113ITable, +function: P113DFunction, +hash: U32, +depth: U32) -> P113ITable:
  nt_choose(P113ITable,U32.is_eq(U32.and(hash,1),0),
    u => P113INode{p113i_put(zero,function,U32.shr(hash),U32.inc(depth)),one},
    u => P113INode{zero,p113i_put(one,function,U32.shr(hash),U32.inc(depth))})


@unsafe
def p113i_name(+name: String) -> Bool:
  Bool.not(String.starts_with(name,"p113i_"))


@unsafe
def p113i_value(value: N111Value) -> Bool:
  match value:
    case N111Local{name}: p113i_name(name)
    case _: True{}


@unsafe
def p113i_values(values: List<&2,N111Value>) -> Bool:
  match values:
    case Nil{}: True{}
    case Con{head,rest}: p113i_value(head) && p113i_values(rest)


@unsafe
def p113i_names(names: List<&2,String>) -> Bool:
  match names:
    case Nil{}: True{}
    case Con{head,rest}: p113i_name(head) && p113i_names(rest)


@unsafe
def p113i_args(args: List<&2,N111Arg>) -> Bool:
  match args:
    case Nil{}: True{}
    case Con{N111Arg{typ,value},rest}: p113i_value(value) && p113i_args(rest)


@unsafe
def p113i_scalar_clean(stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Set{name,typ,value}: p113i_name(name) && p113i_value(value)
    case N111Bin{name,typ,op,left,right}: p113i_name(name) && p113i_value(left) && p113i_value(right)
    case N111Call{name,typ,symbol,args}: p113i_name(name) && p113i_args(args)
    case N111If{condition,yes,no}: p113i_value(condition) && p113i_scalars_clean(yes) && p113i_scalars_clean(no)
    case N111Load{name,typ,base,offset}: p113i_name(name) && p113i_value(base)
    case N111Store{typ,base,offset,value}: p113i_value(base) && p113i_value(value)
    case N111Offset{name,base,bytes}: p113i_name(name) && p113i_value(base) && p113i_value(bytes)
    case N111Alloca{name,bytes,align}: p113i_name(name)
    case _: False{}


@unsafe
def p113i_scalars_clean(body: List<&2,N111Stmt>) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{head,rest}: p113i_scalar_clean(head) && p113i_scalars_clean(rest)


@unsafe
def p113i_clean(body: List<&2,P113DStmt>) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{P113DScalar{stmt},rest}: p113i_scalar_clean(stmt) && p113i_clean(rest)
    case Con{P113DIf{condition,yes,no},rest}: p113i_value(condition) && p113i_clean(yes) && p113i_clean(no) && p113i_clean(rest)
    case Con{P113DCall{destinations,target,args},rest}: p113i_names(destinations) && p113i_values(args) && p113i_clean(rest)
    case Con{P113DResult{values},rest}: p113i_values(values) && p113i_clean(rest)
    case Con{P113DAgain{values},rest}: p113i_values(values) && p113i_clean(rest)


@unsafe
def p113i_params(params: List<&2,NC_Binding>) -> Bool:
  match params:
    case Nil{}: True{}
    case Con{NC_Binding{id,word,kind},rest}: p113i_name(word) && p113i_params(rest)

# Count nested scalar branches as real nodes. Saturation avoids wraparound and
# keeps budget arithmetic independent of malformed or very large input graphs.


@unsafe
def p113i_add(left: U32, right: U32) -> U32:
  U32.min(4096,U32.add(left,right))


@unsafe
def p113i_scalar_size(stmt: N111Stmt) -> U32:
  match stmt:
    case N111If{condition,yes,no}: p113i_add(1,p113i_add(p113i_scalars_size(yes),p113i_scalars_size(no)))
    case _: 1


@unsafe
def p113i_scalars_size(body: List<&2,N111Stmt>) -> U32:
  match body:
    case Nil{}: 0
    case Con{head,rest}: p113i_add(p113i_scalar_size(head),p113i_scalars_size(rest))


@unsafe
def p113i_size(body: List<&2,P113DStmt>) -> U32:
  match body:
    case Nil{}: 0
    case Con{P113DScalar{stmt},rest}: p113i_add(p113i_scalar_size(stmt),p113i_size(rest))
    case Con{P113DIf{condition,yes,no},rest}: p113i_add(1,p113i_add(p113i_size(yes),p113i_add(p113i_size(no),p113i_size(rest))))
    case Con{stmt,rest}: p113i_add(1,p113i_size(rest))


@unsafe
def p113i_scalar_leaf(stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Alloca{name,bytes,align}: U32.is_le(bytes,2048) && U32.is_eq(align,8)
    case N111Call{name,typ,symbol,args}: Bool.not(String.starts_with(symbol,"p113_"))
    case N111If{condition,yes,no}: p113i_scalars_leaf(yes) && p113i_scalars_leaf(no)
    case _: True{}


@unsafe
def p113i_scalars_leaf(body: List<&2,N111Stmt>) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{head,rest}: p113i_scalar_leaf(head) && p113i_scalars_leaf(rest)

# Before a shared suffix, both branches must fall through. Final branches must
# both return. This deliberately refuses early-return/common-suffix shapes.


@unsafe
def p113i_plain(body: List<&2,P113DStmt>) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{P113DScalar{stmt},rest}: p113i_scalar_leaf(stmt) && p113i_plain(rest)
    case Con{P113DIf{condition,yes,no},rest}: p113i_plain(yes) && p113i_plain(no) && p113i_plain(rest)
    case _: False{}


@unsafe
def p113i_returns(body: List<&2,P113DStmt>) -> Bool:
  match body:
    case Con{P113DResult{Con{value,Nil{}}},Nil{}}: True{}
    case Con{P113DIf{condition,yes,no},Nil{}}: p113i_returns(yes) && p113i_returns(no)
    case Con{P113DIf{condition,yes,no},rest}: p113i_plain(yes) && p113i_plain(no) && p113i_returns(rest)
    case Con{P113DScalar{stmt},rest}: p113i_scalar_leaf(stmt) && p113i_returns(rest)
    case _: False{}


@unsafe
def p113i_eligible(+function: P113DFunction) -> Bool:
  match function:
    case P113DFunction{name,+params,+result,public,+body}:
      Bool.not(p126s_is_table(function)) && U32.is_ge(result,1) && U32.is_le(result,8) && U32.is_le(nt_count(NC_Binding,params),32) &&
        U32.is_le(p113i_size(body),512) && U32.is_le(p113i_stack(body),8192) &&
        p113i_params(params) && p137qi_returns(body,result)

@unsafe
def p113i_original_clean(function: P113DFunction) -> Bool:
  match function:
    case P113DFunction{name,params,result,public,body}: p113i_params(params) && p113i_clean(body)


@unsafe
def p113i_stack_add(left: U32, right: U32) -> U32:
  U32.min(65536,U32.add(left,right))


@unsafe
def p113i_scalar_stack(stmt: N111Stmt) -> U32:
  match stmt:
    case N111Alloca{name,bytes,align}: U32.min(bytes,65536)
    case N111If{condition,yes,no}: p113i_stack_add(p113i_scalars_stack(yes),p113i_scalars_stack(no))
    case _: 0


@unsafe
def p113i_scalars_stack(body: List<&2,N111Stmt>) -> U32:
  match body:
    case Nil{}: 0
    case Con{head,rest}: p113i_stack_add(p113i_scalar_stack(head),p113i_scalars_stack(rest))


@unsafe
def p113i_stack(body: List<&2,P113DStmt>) -> U32:
  match body:
    case Nil{}: 0
    case Con{P113DScalar{stmt},rest}: p113i_stack_add(p113i_scalar_stack(stmt),p113i_stack(rest))
    case Con{P113DIf{condition,yes,no},rest}: p113i_stack_add(p113i_stack(yes),p113i_stack_add(p113i_stack(no),p113i_stack(rest)))
    case Con{stmt,rest}: p113i_stack(rest)


@unsafe
def p113i_bind(params: List<&2,NC_Binding>, args: List<&2,N111Value>, +prefix: String) -> List<&2,P113DStmt>:
  match params args:
    case Con{NC_Binding{id,word,kind},rest} Con{value,tail}:
      Con{P113DScalar{N111Set{p112f_name(prefix,word),N111U64{},value}},p113i_bind(rest,tail,prefix)}
    case _ _: []


@unsafe
def p113i_expand(body: List<&2,P113DStmt>, +prefix: String, +dest: String) -> List<&2,P113DStmt>:
  match body:
    case Nil{}: []
    case Con{P113DScalar{stmt},rest}: Con{P113DScalar{p112f_stmt(stmt,prefix)},p113i_expand(rest,prefix,dest)}
    case Con{P113DIf{condition,yes,no},rest}:
      Con{P113DIf{p112f_value(condition,prefix),p113i_expand(yes,prefix,dest),p113i_expand(no,prefix,dest)},p113i_expand(rest,prefix,dest)}
    case Con{P113DResult{Con{value,Nil{}}},rest}:
      Con{P113DScalar{N111Set{dest,N111U64{},p112f_value(value,prefix)}},p113i_expand(rest,prefix,dest)}
    case _: []


@unsafe
def p113i_inline(function: P113DFunction, +args: List<&2,N111Value>, +dest: String, +prefix: String) -> List<&2,P113DStmt>:
  match function:
    case P113DFunction{name,params,result,public,body}:
      Con{P113DScalar{N111Alloca{p112f_name(prefix,"scratch"),2048,8}},
        nt_append(P113DStmt,p113i_bind(params,args,prefix),p113i_expand(body,prefix,dest))}


@unsafe
def p113i_prepend(stmt: P113DStmt, scan: P113IScan) -> P113IScan:
  match scan:
    case P113IScan{body,next,budget}: P113IScan{Con{stmt,body},next,budget}


@unsafe
def p113i_join(prefix: List<&2,P113DStmt>, scan: P113IScan) -> P113IScan:
  match scan:
    case P113IScan{body,next,budget}: P113IScan{nt_append(P113DStmt,prefix,body),next,budget}


@unsafe
def p113i_scan(body: List<&2,P113DStmt>, +table: P113ITable, +site: U32, +budget: U32) -> P113IScan:
  match body:
    case Nil{}: P113IScan{[],site,budget}
    case Con{P113DIf{condition,yes,no},rest}:
      p113i_scan_yes(condition,no,rest,table,p113i_scan(yes,table,site,budget))
    case Con{+stmt,rest}: p113i_scan_stmt(stmt,rest,table,site,budget)


@unsafe
def p113i_scan_yes(+condition: N111Value, +no: List<&2,P113DStmt>, +rest: List<&2,P113DStmt>, +table: P113ITable, yes: P113IScan) -> P113IScan:
  match yes:
    case P113IScan{body,next,budget}: p113i_scan_no(condition,body,rest,table,p113i_scan(no,table,next,budget))


@unsafe
def p113i_scan_no(+condition: N111Value, +yes: List<&2,P113DStmt>, +rest: List<&2,P113DStmt>, +table: P113ITable, no: P113IScan) -> P113IScan:
  match no:
    case P113IScan{body,next,budget}: p113i_prepend(P113DIf{condition,yes,body},p113i_scan(rest,table,next,budget))


@unsafe
def p113i_scan_stmt(+stmt: P113DStmt, +rest: List<&2,P113DStmt>, +table: P113ITable, +site: U32, +budget: U32) -> P113IScan:
  match stmt:
    case P113DCall{destinations,+target,args}:
      nt_choose(P113IScan,U32.is_lt(site,16),
        u => p113j_scan_found(stmt,rest,table,site,budget,destinations,args,p113i_get(table,target,index_hash(target,2166136261),0)),
        u => p113i_prepend(stmt,p113i_scan(rest,table,site,budget)))
    case _: p113i_prepend(stmt,p113i_scan(rest,table,site,budget))

@unsafe
def p113i_scan_found(+stmt: P113DStmt, +rest: List<&2,P113DStmt>, +table: P113ITable, +site: U32, +budget: U32, +dest: String, +args: List<&2,N111Value>, found: Maybe<&2,P113DFunction>) -> P113IScan:
  match found:
    case None{}: p113i_prepend(stmt,p113i_scan(rest,table,site,budget))
    case Some{+function}: p113i_scan_cost(stmt,rest,table,site,budget,dest,args,function,p113i_cost(function))


@unsafe
def p113i_cost(function: P113DFunction) -> U32:
  match function:
    case P113DFunction{name,params,result,public,body}: U32.add(p113i_size(body),nt_count(NC_Binding,params))


@unsafe
def p113i_scan_cost(+stmt: P113DStmt, +rest: List<&2,P113DStmt>, +table: P113ITable, +site: U32, +budget: U32, +dest: String, +args: List<&2,N111Value>, +function: P113DFunction, +cost: U32) -> P113IScan:
  nt_choose(P113IScan,U32.is_le(cost,budget),
    u => p113i_join(p113i_inline(function,args,dest,"p113i_" ++ U32.show(site) ++ "_"),
      p113i_scan(rest,table,U32.inc(site),U32.sub(budget,cost))),
    u => p113i_prepend(stmt,p113i_scan(rest,table,site,budget)))


@unsafe
def p113i_table_function(+function: P113DFunction, +table: P113ITable) -> P113ITable:
  match function:
    case P113DFunction{+name,params,result,public,body}:
      nt_choose(P113ITable,p113i_eligible(function),
        u => p113i_put(table,function,index_hash(name,2166136261),0),u => table)


@unsafe
def p113i_function(+function: P113DFunction, +table: P113ITable) -> P113DFunction:
  match function:
    case P113DFunction{+name,+params,+result,+public,+body}:
      nt_choose(P113DFunction,p113i_params(params) && p113i_clean(body) && U32.is_le(p113i_size(body),2048),
        u => p113i_function_done(function,name,params,result,public,p113i_scan(body,table,0,1024)),u => function)

@unsafe
def p113i_function_done(+original: P113DFunction, +name: String, +params: List<&2,NC_Binding>, +result: U32, +public: Bool, scan: P113IScan) -> P113DFunction:
  match scan:
    case P113IScan{+body,next,budget}:
      nt_choose(P113DFunction,U32.is_le(p113i_stack(body),16384),
        u => p113k_function(P113DFunction{name,params,result,public,body}),u => original)

@unsafe
def p113i_functions(functions: List<&2,P113DFunction>, +table: P113ITable, acc: List<&2,P113DFunction>) -> List<&2,P113DFunction>:
  match functions:
    case Nil{}: nt_reverse(P113DFunction,acc,[])
    case Con{+head,rest}: p113i_functions_step(head,rest,table,acc,p113i_function(head,table))


@unsafe
def p113i_functions_step(+original: P113DFunction, +rest: List<&2,P113DFunction>, +table: P113ITable, +acc: List<&2,P113DFunction>, +function: P113DFunction) -> List<&2,P113DFunction>:
  p113i_functions(rest,nt_choose(P113ITable,p113i_original_clean(original),
    u => p113i_table_function(function,table),u => table),Con{function,acc})


@unsafe
def p113i_admitted(program: P113DProgram) -> P113DProgram:
  match program:
    case P113DProgram{original,functions}: P113DProgram{original,p113i_functions(functions,P113IEmpty{},[])}


@unsafe
def p113i_verified(+original: P113DProgram, +candidate: P113DProgram) -> P113DProgram:
  nt_choose(P113DProgram,String.is_empty(p113d_verify(candidate)),u => candidate,u => original)


@unsafe
def p113i_optimize(+program: P113DProgram) -> P113DProgram:
  nt_choose(P113DProgram,String.is_empty(p113d_verify(program)),
    u => p113i_verified(program,p113i_admitted(program)),u => program)


@unsafe
def p113i_lowered(+lowered: P113DLowering) -> P113DLowering:
  match lowered:
    case P113DLowered{program,+error}:
      nt_choose(P113DLowering,String.is_empty(error),
        u => P113DLowered{p113i_optimize(program),error},u => lowered)

# Exact scalar entry body with only the declaration renamed. The enhanced
# scalar profile's prepared/lowering helpers remain dynamically selected.


@unsafe
def p113i_scalar_lower_request(request: NR_Request) -> P113DLowering:
  match request:
    case NR_Request{+source,+book,+names,paths,scope,+bound}:
      +error = nc_compile_error_known(source,bound)
      nt_choose(P113DLowering,String.is_empty(error),
        u => p113d_prepared(source,names,p112s_prepare(book,names,nc_add_ctors(nc_default_ctors(),nc_constructors(source,source)))),
        u => P113DLowered{P113DProgram{P112StaticProgram{p111_empty(),[]},[]},error})


@unsafe
def p113j_is_scratch(value: N111Value) -> Bool:
  match value:
    case N111Local{name}: String.eq(name,"scratch")
    case _: False{}


@unsafe
def p113j_scratch_values(values: List<&2,N111Value>) -> Bool:
  match values:
    case Nil{}: False{}
    case Con{head,rest}: p113j_is_scratch(head) || p113j_scratch_values(rest)


@unsafe
def p113j_scratch_args(args: List<&2,N111Arg>) -> U32:
  match args:
    case Nil{}: 0
    case Con{N111Arg{typ,value},rest}: U32.add(Bool.to_u32(p113j_is_scratch(value)),p113j_scratch_args(rest))


@unsafe
def p113j_scratch_count(+args: List<&2,N111Arg>, +position: U32, +count_at: U32) -> U32:
  nt_choose(U32,U32.is_eq(p113j_scratch_args(args),1) && p113j_is_scratch(p111v_arg(args,position)),
    u => p113j_scratch_literal(p111v_arg(args,count_at)),u => 2048)


@unsafe
def p113j_scratch_literal(value: N111Value) -> U32:
  match value:
    case N111Const{+count,0}: nt_choose(U32,U32.is_le(count,256),u => U32.max(8,U32.mul(count,8)),u => 2048)
    case _: 2048


@unsafe
def p113j_scratch_call(+symbol: String, +args: List<&2,N111Arg>) -> U32:
  nt_choose(U32,U32.is_eq(p113j_scratch_args(args),0),u => 0,u =>
  nt_choose(U32,String.eq(symbol,"p111_rt_op") || String.eq(symbol,"p111_rt_ctor") ||
      String.eq(symbol,"p111_rt_take") || String.eq(symbol,"p111_rt_special_ctor") ||
      String.eq(symbol,"p113_rt_array_pair"),
    u => p113j_scratch_count(args,2,3),u =>
  nt_choose(U32,String.eq(symbol,"p111_rt_special_take"),
    u => p113j_scratch_count(args,3,4),u => 2048)))


@unsafe
def p113j_scratch_scalar(stmt: N111Stmt) -> U32:
  match stmt:
    case N111Load{name,typ,+base,+offset}:
      nt_choose(U32,p113j_is_scratch(base),u => U32.min(2048,U32.add(offset,8)),u => 0)
    case N111Store{typ,+base,+offset,+value}:
      nt_choose(U32,p113j_is_scratch(value),u => 2048,u =>
        nt_choose(U32,p113j_is_scratch(base),v => U32.min(2048,U32.add(offset,8)),v => 0))
    case N111Call{name,typ,symbol,args}: p113j_scratch_call(symbol,args)
    case N111If{condition,yes,no}:
      nt_choose(U32,p113j_is_scratch(condition),u => 2048,u => U32.max(p113j_scratch_scalars(yes),p113j_scratch_scalars(no)))
    case N111Set{name,typ,value}: nt_choose(U32,p113j_is_scratch(value),u => 2048,u => 0)
    case N111Bin{name,typ,op,left,right}: nt_choose(U32,p113j_is_scratch(left) || p113j_is_scratch(right),u => 2048,u => 0)
    case N111Offset{name,base,bytes}: nt_choose(U32,p113j_is_scratch(base) || p113j_is_scratch(bytes),u => 2048,u => 0)
    case _: 0


@unsafe
def p113j_scratch_scalars(body: List<&2,N111Stmt>) -> U32:
  match body:
    case Nil{}: 0
    case Con{head,rest}: U32.max(p113j_scratch_scalar(head),p113j_scratch_scalars(rest))


@unsafe
def p113j_scratch(body: List<&2,P113DStmt>) -> U32:
  match body:
    case Nil{}: 0
    case Con{P113DScalar{stmt},rest}: U32.max(p113j_scratch_scalar(stmt),p113j_scratch(rest))
    case Con{P113DIf{condition,yes,no},rest}:
      nt_choose(U32,p113j_is_scratch(condition),u => 2048,u => U32.max(p113j_scratch(yes),U32.max(p113j_scratch(no),p113j_scratch(rest))))
    case Con{P113DCall{destinations,target,args},rest}:
      nt_choose(U32,p113j_scratch_values(args),u => 2048,u => p113j_scratch(rest))
    case Con{P113DResult{values},rest}:
      nt_choose(U32,p113j_scratch_values(values),u => 2048,u => p113j_scratch(rest))
    case Con{P113DAgain{values},rest}:
      nt_choose(U32,p113j_scratch_values(values),u => 2048,u => p113j_scratch(rest))


@unsafe
def p113j_scratch_alloc(+body: List<&2,P113DStmt>, +prefix: String) -> List<&2,P113DStmt>:
  +bytes = p113j_scratch(body)
  nt_choose(List<&2,P113DStmt>,U32.is_eq(bytes,0),u => [],
    u => [P113DScalar{N111Alloca{p112f_name(prefix,"scratch"),U32.mul(U32.div(U32.add(bytes,7),8),8),8}}])


@unsafe
def p113j_plain(body: List<&2,P113DStmt>) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{P113DScalar{stmt},rest}: p113j_plain(rest)
    case Con{P113DCall{destinations,target,args},rest}: p113j_plain(rest)
    case Con{P113DIf{condition,yes,no},rest}: p113j_plain(yes) && p113j_plain(no) && p113j_plain(rest)
    case _: False{}


@unsafe
def p113j_returns(body: List<&2,P113DStmt>, +width: U32) -> Bool:
  match body:
    case Con{P113DResult{values},Nil{}}: U32.is_eq(nt_count(N111Value,values),width)
    case Con{P113DIf{condition,yes,no},Nil{}}: p113j_returns(yes,width) && p113j_returns(no,width)
    case Con{P113DIf{condition,yes,no},rest}: p113j_plain(yes) && p113j_plain(no) && p113j_returns(rest,width)
    case Con{P113DScalar{stmt},rest}: p113j_returns(rest,width)
    case Con{P113DCall{destinations,target,args},rest}: p113j_returns(rest,width)
    case _: False{}


@unsafe
def p113j_names(names: List<&2,String>, +prefix: String) -> List<&2,String>:
  match names:
    case Nil{}: []
    case Con{head,rest}: Con{p112f_name(prefix,head),p113j_names(rest,prefix)}


@unsafe
def p113j_values(values: List<&2,N111Value>, +prefix: String) -> List<&2,N111Value>:
  match values:
    case Nil{}: []
    case Con{head,rest}: Con{p112f_value(head,prefix),p113j_values(rest,prefix)}


@unsafe
def p113j_snapshots(values: List<&2,N111Value>, +prefix: String, +index: U32) -> List<&2,P113DStmt>:
  match values:
    case Nil{}: []
    case Con{value,rest}:
      Con{P113DScalar{N111Set{prefix ++ "result_" ++ U32.show(index),N111U64{},p112f_value(value,prefix)}},
        p113j_snapshots(rest,prefix,U32.inc(index))}


@unsafe
def p113j_assign(destinations: List<&2,String>, +prefix: String, +index: U32) -> List<&2,P113DStmt>:
  match destinations:
    case Nil{}: []
    case Con{dest,rest}:
      Con{P113DScalar{N111Set{dest,N111U64{},N111Local{prefix ++ "result_" ++ U32.show(index)}}},
        p113j_assign(rest,prefix,U32.inc(index))}


@unsafe
def p113j_expand(body: List<&2,P113DStmt>, +prefix: String, +destinations: List<&2,String>) -> List<&2,P113DStmt>:
  match body:
    case Nil{}: []
    case Con{P113DScalar{stmt},rest}: Con{P113DScalar{p112f_stmt(stmt,prefix)},p113j_expand(rest,prefix,destinations)}
    case Con{P113DIf{condition,yes,no},rest}:
      Con{P113DIf{p112f_value(condition,prefix),p113j_expand(yes,prefix,destinations),p113j_expand(no,prefix,destinations)},
        p113j_expand(rest,prefix,destinations)}
    case Con{P113DCall{names,target,args},rest}:
      Con{P113DCall{p113j_names(names,prefix),target,p113j_values(args,prefix)},p113j_expand(rest,prefix,destinations)}
    case Con{P113DResult{values},rest}:
      nt_append(P113DStmt,p113j_snapshots(values,prefix,0),p113j_assign(destinations,prefix,0))
    case _: []


@unsafe
def p113j_expanded_size(body: List<&2,P113DStmt>) -> U32:
  match body:
    case Nil{}: 0
    case Con{P113DResult{values},rest}: U32.mul(nt_count(N111Value,values),2)
    case Con{P113DScalar{stmt},rest}: p113i_add(p113i_scalar_size(stmt),p113j_expanded_size(rest))
    case Con{P113DIf{condition,yes,no},rest}:
      p113i_add(1,p113i_add(p113j_expanded_size(yes),p113i_add(p113j_expanded_size(no),p113j_expanded_size(rest))))
    case Con{stmt,rest}: p113i_add(1,p113j_expanded_size(rest))


@unsafe
def p113j_inline(function: P113DFunction, +args: List<&2,N111Value>, +destinations: List<&2,String>, +prefix: String) -> List<&2,P113DStmt>:
  match function:
    case P113DFunction{name,params,result,public,+body}:
      nt_append(P113DStmt,p113j_scratch_alloc(body,prefix),
        nt_append(P113DStmt,p113i_bind(params,args,prefix),p113j_expand(body,prefix,destinations)))


@unsafe
def p113j_cost(function: P113DFunction) -> U32:
  match function:
    case P113DFunction{name,params,result,public,+body}:
      U32.sub(U32.add(U32.add(p113j_expanded_size(body),nt_count(NC_Binding,params)),
        nt_choose(U32,U32.is_eq(p113j_scratch(body),0),u => 0,u => 1)),1)


@unsafe
def p113j_scan_found(+stmt: P113DStmt, +rest: List<&2,P113DStmt>, +table: P113ITable, +site: U32, +budget: U32, +destinations: List<&2,String>, +args: List<&2,N111Value>, found: Maybe<&2,P113DFunction>) -> P113IScan:
  match found:
    case None{}: p113i_prepend(stmt,p113i_scan(rest,table,site,budget))
    case Some{+function}: p113j_scan_cost(stmt,rest,table,site,budget,destinations,args,function,p113j_cost(function))


@unsafe
def p113j_scan_cost(+stmt: P113DStmt, +rest: List<&2,P113DStmt>, +table: P113ITable, +site: U32, +budget: U32, +destinations: List<&2,String>, +args: List<&2,N111Value>, +function: P113DFunction, +cost: U32) -> P113IScan:
  nt_choose(P113IScan,U32.is_le(cost,budget),
    u => p113i_join(p113j_inline(function,args,destinations,"p113i_" ++ U32.show(site) ++ "_"),
      p113i_scan(rest,table,U32.inc(site),U32.sub(budget,cost))),
    u => p113i_prepend(stmt,p113i_scan(rest,table,site,budget)))


@unsafe
def p113j_buffer_origin(+name: String, +input: Bool) -> Bool:
  nt_choose(Bool,nt_choose(Bool,input,u => String.eq(name,"scratch"),u => String.starts_with(name,"p113p_out_")),
    u => True{},u => p113j_buffer_peel(name,input,0))


@unsafe
def p113j_buffer_peel(+name: String, +input: Bool, +site: U32) -> Bool:
  nt_choose(Bool,U32.is_eq(site,16),u => False{},u =>
    nt_choose(Bool,String.starts_with(name,"p113i_" ++ U32.show(site) ++ "_local_"),
      v => p113j_buffer_origin(String.drop(name,nt_choose(Nat,U32.is_lt(site,10),w => 14n,w => 15n)),input),
      v => p113j_buffer_peel(name,input,U32.inc(site))))


@unsafe
def p113j_array_call(+symbol: String, args: List<&2,N111Arg>) -> Bool:
  match args:
    case Con{N111Arg{N111Ptr{},N111Local{state}},
      Con{N111Arg{N111U32{},N111Const{+id,0}},
      Con{N111Arg{N111Ptr{},N111Local{input}},
      Con{N111Arg{N111U32{},N111Const{count,0}},
      Con{N111Arg{N111Ptr{},N111Local{output}},
      Con{N111Arg{N111U32{},N111Const{2,0}},Nil{}}}}}}}:
        String.eq(symbol,"p113_rt_array_pair") && String.eq(state,"state") &&
        p113j_buffer_origin(input,True{}) && p113j_buffer_origin(output,False{}) &&
        U32.is_gt(p113p_array_arity(id),0) && U32.is_eq(p113p_array_arity(id),count)
    case _: False{}


@unsafe
def p113j_calls(body: List<&2,P113DStmt>) -> List<&2,String>:
  match body:
    case Nil{}: []
    case Con{P113DCall{destinations,target,args},rest}: Con{target,p113j_calls(rest)}
    case Con{P113DIf{condition,yes,no},rest}:
      nt_append(String,p113j_calls(yes),nt_append(String,p113j_calls(no),p113j_calls(rest)))
    case Con{stmt,rest}: p113j_calls(rest)


@unsafe
def p113j_reason(+function: P113DFunction) -> String:
  match function:
    case P113DFunction{name,+params,+result,public,+body}:
      nt_choose(String,p113i_eligible(function),u => "eligible",u =>
      nt_choose(String,U32.is_lt(result,1) || U32.is_gt(result,8),u => "result-width",u =>
      nt_choose(String,U32.is_gt(nt_count(NC_Binding,params),32),u => "argument-count",u =>
      nt_choose(String,p113i_params(params),u =>
      nt_choose(String,p113j_returns(body,result),u => "policy-limit",u => "loop-or-partial-return"),u => "parameter-prefix"))))

@unsafe
def p113j_function_info(+function: P113DFunction) -> String:
  match function:
    case P113DFunction{+name,+params,+result,public,+body}:
      name ++ " args=" ++ U32.show(nt_count(NC_Binding,params)) ++
        " results=" ++ U32.show(result) ++ " nodes=" ++ U32.show(p113i_size(body)) ++
        " stack=" ++ U32.show(p113i_stack(body)) ++ " scratch=" ++ U32.show(p113j_scratch(body)) ++
        " candidate=" ++ p113j_reason(function) ++ " calls=[" ++ nt_join(p113j_calls(body),",") ++ "]\n"


@unsafe
def p113j_function_lines(functions: List<&2,P113DFunction>) -> List<&2,String>:
  match functions:
    case Nil{}: []
    case Con{head,rest}: Con{p113j_function_info(head),p113j_function_lines(rest)}


@unsafe
def p113j_audit(program: P113DProgram) -> String:
  match program:
    case P113DProgram{original,functions}: nt_join(p113j_function_lines(functions),"")
