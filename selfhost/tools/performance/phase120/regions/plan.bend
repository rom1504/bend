# Numeric regions are copied only after original private-graph verification.
# No loads from state/heap, ownership helpers, private calls, backedges or effects.
@unsafe
def p120nr_number(typ: N111Type) -> Bool:
  match typ:
    case N111U32{}: True{}
    case N111U64{}: True{}
    case _: False{}

@unsafe
def p120nr_operand(value: N111Value, +buffers: List<&2,String>) -> Bool:
  match value:
    case N111Const{lo,hi}: True{}
    case N111Local{name}: Bool.not(String.eq(name,"state")) && Bool.not(p114so_member(buffers,name))
    case _: False{}

@unsafe
def p120nr_operands(values: List<&2,N111Value>, +buffers: List<&2,String>) -> Bool:
  match values:
    case Nil{}: True{}
    case Con{head,rest}: p120nr_operand(head,buffers) && p120nr_operands(rest,buffers)

@unsafe
def p120nr_runtime(+symbol: String, args: List<&2,N111Arg>, +buffers: List<&2,String>) -> Bool:
  match args:
    case [N111Arg{N111Ptr{},N111Local{state}},N111Arg{N111U32{},N111Const{id,0}},N111Arg{N111Ptr{},N111Local{buffer}},N111Arg{N111U32{},N111Const{count,0}}]:
      String.eq(symbol,"p111_rt_op") && String.eq(state,"state") && Bool.not(String.eq(buffer,"state")) &&
        p114so_member(buffers,buffer) && ((U32.is_ge(id,23) && U32.is_le(id,25) && U32.is_eq(count,1)) ||
          (U32.is_ge(id,26) && U32.is_le(id,35) && U32.is_eq(count,2)) || (U32.is_eq(id,36) && U32.is_eq(count,1)))
    case [N111Arg{N111Ptr{},N111Local{state}},N111Arg{N111U32{},N111Const{4,0}}]:
      String.eq(symbol,"p111_rt_fail") && String.eq(state,"state")
    case _: False{}

@unsafe
def p120nr_scalar(stmt: N111Stmt, +buffers: List<&2,String>) -> Bool:
  match stmt:
    case N111Set{name,typ,value}: p120nr_operand(N111Local{name},buffers) && p120nr_number(typ) && p120nr_operand(value,buffers)
    case N111Bin{name,typ,op,left,right}: p120nr_operand(N111Local{name},buffers) && p120nr_number(typ) && p120nr_operand(left,buffers) && p120nr_operand(right,buffers)
    case N111Alloca{name,bytes,align}: Bool.not(String.eq(name,"state")) && U32.is_le(bytes,2048) && U32.is_eq(align,8)
    case N111Store{N111U64{},N111Local{buffer},offset,value}:
      Bool.not(String.eq(buffer,"state")) && p114so_member(buffers,buffer) &&
        (U32.is_eq(offset,0) || U32.is_eq(offset,8)) && p120nr_operand(value,buffers)
    case N111Call{name,N111U64{},symbol,args}: p120nr_operand(N111Local{name},buffers) && p120nr_runtime(symbol,args,buffers)
    case _: False{}

@unsafe
def p120nr_body(body: List<&2,P113DStmt>, +buffers: List<&2,String>) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{P113DScalar{stmt},rest}: p120nr_scalar(stmt,buffers) && p120nr_body(rest,buffers)
    case Con{P113DIf{condition,yes,no},rest}:
      p120nr_operand(condition,buffers) && p120nr_body(yes,buffers) && p120nr_body(no,buffers) && p120nr_body(rest,buffers)
    case Con{P113DResult{values},Nil{}}: p120nr_operands(values,buffers)
    case _: False{}

@unsafe
def p120nr_seen(body: List<&2,P113DStmt>) -> Bool:
  match body:
    case Nil{}: False{}
    case Con{P113DScalar{N111Call{name,typ,symbol,[N111Arg{a,state},N111Arg{b,N111Const{id,0}},N111Arg{c,buffer},N111Arg{d,count}]}},rest}:
      (String.eq(symbol,"p111_rt_op") && (U32.is_eq(id,23) || (U32.is_ge(id,26) && U32.is_le(id,36)))) || p120nr_seen(rest)
    case Con{P113DIf{condition,yes,no},rest}: p120nr_seen(yes) || p120nr_seen(no) || p120nr_seen(rest)
    case Con{head,rest}: p120nr_seen(rest)

@unsafe
def p120nr_eligible(function: P113DFunction) -> Bool:
  match function:
    case P113DFunction{name,+params,+result,public,+body}:
      U32.is_ge(result,1) && U32.is_le(result,8) && U32.is_le(nt_count(NC_Binding,params),32) &&
        U32.is_le(p113i_size(body),512) && U32.is_le(p113i_stack(body),8192) &&
        p113j_returns(body,result) && p120nr_seen(body) && p120nr_body(body,p114so_allocations(body,["scratch"]))

@unsafe
def p120nr_table(functions: List<&2,P113DFunction>, +table: P113ITable) -> P113ITable:
  match functions:
    case Nil{}: table
    case Con{+head,rest}: p120nr_table(rest,p120nr_table_step(head,table,p120nr_eligible(head)))

@unsafe
def p120nr_table_step(+head: P113DFunction, +table: P113ITable, good: Bool) -> P113ITable:
  match head good:
    case P113DFunction{+name,params,result,public,body} True{}:
      p113i_put(table,head,index_hash(name,2166136261),0)
    case _ False{}: table

@unsafe
def p120nr_scan(body: List<&2,P113DStmt>, +table: P113ITable, +site: U32, +budget: U32) -> P113IScan:
  match body:
    case Nil{}: P113IScan{[],site,budget}
    case Con{P113DIf{condition,yes,no},rest}: p120nr_scan_yes(condition,no,rest,table,p120nr_scan(yes,table,site,budget))
    case Con{+stmt,rest}: p120nr_scan_stmt(stmt,rest,table,site,budget)

@unsafe
def p120nr_scan_yes(+condition: N111Value, +no: List<&2,P113DStmt>, +rest: List<&2,P113DStmt>, +table: P113ITable, yes: P113IScan) -> P113IScan:
  match yes:
    case P113IScan{body,next,budget}: p120nr_scan_no(condition,body,rest,table,p120nr_scan(no,table,next,budget))

@unsafe
def p120nr_scan_no(+condition: N111Value, +yes: List<&2,P113DStmt>, +rest: List<&2,P113DStmt>, +table: P113ITable, no: P113IScan) -> P113IScan:
  match no:
    case P113IScan{body,next,budget}: p113i_prepend(P113DIf{condition,yes,body},p120nr_scan(rest,table,next,budget))

@unsafe
def p120nr_scan_stmt(+stmt: P113DStmt, +rest: List<&2,P113DStmt>, +table: P113ITable, +site: U32, +budget: U32) -> P113IScan:
  match stmt:
    case P113DCall{destinations,+target,args}:
      nt_choose(P113IScan,U32.is_lt(site,4),
        u => p120nr_found(stmt,rest,table,site,budget,destinations,args,p113i_get(table,target,index_hash(target,2166136261),0)),
        u => p113i_prepend(stmt,p120nr_scan(rest,table,site,budget)))
    case _: p113i_prepend(stmt,p120nr_scan(rest,table,site,budget))

@unsafe
def p120nr_found(+stmt: P113DStmt, +rest: List<&2,P113DStmt>, +table: P113ITable, +site: U32, +budget: U32, +destinations: List<&2,String>, +args: List<&2,N111Value>, found: Maybe<&2,P113DFunction>) -> P113IScan:
  match found:
    case None{}: p113i_prepend(stmt,p120nr_scan(rest,table,site,budget))
    case Some{+function}: p120nr_cost(stmt,rest,table,site,budget,destinations,args,function,p113j_cost(function))

@unsafe
def p120nr_cost(+stmt: P113DStmt, +rest: List<&2,P113DStmt>, +table: P113ITable, +site: U32, +budget: U32, +destinations: List<&2,String>, +args: List<&2,N111Value>, +function: P113DFunction, +cost: U32) -> P113IScan:
  nt_choose(P113IScan,U32.is_le(cost,budget),
    u => p113i_join(p113j_inline(function,args,destinations,"p120nr_" ++ U32.show(site) ++ "_"),
      p120nr_scan(rest,table,U32.inc(site),U32.sub(budget,cost))),
    u => p113i_prepend(stmt,p120nr_scan(rest,table,site,budget)))

@unsafe
def p120nr_function(+function: P113DFunction, +table: P113ITable) -> P113DFunction:
  match function:
    case P113DFunction{+name,+params,+result,+public,+body}:
      nt_choose(P113DFunction,p120nr_params(params) && p120nr_clean(body) && U32.is_le(p113i_size(body),4096),
        u => p113i_function_done(function,name,params,result,public,p120nr_scan(body,table,0,1024)),u => function)

@unsafe
def p120nr_functions(functions: List<&2,P113DFunction>, +table: P113ITable, acc: List<&2,P113DFunction>) -> List<&2,P113DFunction>:
  match functions:
    case Nil{}: nt_reverse(P113DFunction,acc,[])
    case Con{head,rest}: p120nr_functions(rest,table,Con{p120nr_function(head,table),acc})

@unsafe
def p120nr_boundary(+boundary: P114SBoundary) -> P114SBoundary:
  match boundary:
    case P114SBoundary{original,ids,+functions,valid}:
      nt_choose(P114SBoundary,valid,
        u => p114s_commit(boundary,p120nr_functions(functions,p120nr_table(functions,P113IEmpty{}),[])),u => boundary)
