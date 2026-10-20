# Product extension: preserve the checked DAG, including calls left inside a
# copied body. Only self-loop edges and partial-return suffixes are refused.
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
