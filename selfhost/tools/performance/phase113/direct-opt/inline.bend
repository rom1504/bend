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
    case P113DCall{Con{dest,Nil{}},+target,args}:
      nt_choose(P113IScan,U32.is_lt(site,4),
        u => p113i_scan_found(stmt,rest,table,site,budget,dest,args,p113i_get(table,target,index_hash(target,2166136261),0)),
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
