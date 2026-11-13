# Optional factory capability for the SAME x185 late traversal/site counter.
# Ordinary callers pass []; only a closed H worker may pass case-buffer names.
# Allocation checks below validate that capability's materialization; names and
# matching allocas alone are NOT authority for arbitrary source-origin buffers.
def x192hf_scope_enabled() -> Bool: True{}

@unsafe
def x192hf_case_buffers(cases: List<&2,P114HCase>, +index: U32) -> List<&2,String>:
  match cases:
    case Nil{}: []
    case Con{head,rest}: Con{p112f_name(p114h_prefix(index),"scratch"),x192hf_case_buffers(rest,U32.inc(index))}

@unsafe
def x192hf_allocations(setup: List<&2,P113DStmt>, +name: String) -> U32:
  match setup:
    case Nil{}: 0
    case Con{P113DScalar{N111Alloca{other,bytes,align}},rest}:
      U32.add(nt_choose(U32,String.eq(other,name) && U32.is_eq(bytes,2048) && U32.is_eq(align,8),
        u => 1,u => 0),x192hf_allocations(rest,name))
    case Con{head,rest}: x192hf_allocations(rest,name)

@unsafe
def x192hf_scope_members(scope: List<&2,String>, +setup: List<&2,P113DStmt>, +buffers: KDef) -> Bool:
  match scope:
    case Nil{}: True{}
    case Con{+name,+rest}:
      +entry = p111v_get(buffers,name)
      p185fr_buffer(name,0) && Bool.not(nb_contains(rest,name)) &&
        U32.is_eq(x192hf_allocations(setup,name),1) &&
        String.eq(dk(entry),"X185ScratchBuffer") && U32.is_eq(da(entry),2048) &&
        x192hf_scope_members(rest,setup,buffers)

# Empty scope returns immediately without allocation/definition scans.
@unsafe
def x192hf_scope(+scope: List<&2,String>, params: List<&2,String>, +setup: List<&2,P113DStmt>,
    body: List<&2,P113DStmt>) -> List<&2,String>:
  match scope:
    case Nil{}: []
    case Con{head,rest}:
      nt_choose(List<&2,String>,x192hf_scope_enabled() && U32.is_le(nt_count(String,scope),8) &&
          x192hf_scope_members(scope,setup,x185_sf_buffers(body,x185_sf_buffers(setup,x185_sf_blocks(params,missing())))),
        u => scope,u => [])

# Extract only a possible buffer operand. ALL semantic admission stays in
# canonical p185fr_expand, including symbol/types/state/FID/count/site checks.
def x192hf_call_buffer(stmt: N111Stmt) -> String:
  match stmt:
    case N111Call{name,typ,symbol,Con{a,Con{b,Con{N111Arg{bt,N111Local{buffer}},rest}}}}: buffer
    case _: ""

@unsafe
def x192hf_expanded(+stmt: N111Stmt, +ids: N111Ids, +site: U32, expansion: P114TExpansion) -> List<&2,N111Stmt>:
  match expansion:
    case P114TExpansion{body,changed}:
      nt_choose(List<&2,N111Stmt>,changed,u => x185_late_accessors(body),u => x185_late_scalar(stmt,ids,site))

@unsafe
def x192hf_scalar(+stmt: N111Stmt, +ids: N111Ids, +site: U32, +scope: List<&2,String>) -> List<&2,N111Stmt>:
  match scope:
    case Nil{}: x185_late_scalar(stmt,ids,site)
    case Con{head,rest}:
      +buffer = x192hf_call_buffer(stmt)
      nt_choose(List<&2,N111Stmt>,U32.is_lt(site,4294967200) && nb_contains(scope,buffer),
        u => x192hf_expanded(stmt,ids,site,p185fr_expand(stmt,buffer,ids,site)),
        u => x185_late_scalar(stmt,ids,site))

law x192hf_late_stmts:
  for body: List<&2,P113DStmt>
  for +ids: N111Ids
  for +site: U32
  for +scope: List<&2,String>
  P113ABody

@unsafe
def x192hf_late_yes(condition: N111Value, no: List<&2,P113DStmt>, rest: List<&2,P113DStmt>,
    +ids: N111Ids, yes: P113ABody, +scope: List<&2,String>) -> P113ABody:
  match yes:
    case P113ABody{body,next}: x192hf_late_no(condition,body,rest,ids,x192hf_late_stmts(no,ids,next,scope),scope)

@unsafe
def x192hf_late_no(condition: N111Value, yes: List<&2,P113DStmt>, rest: List<&2,P113DStmt>,
    +ids: N111Ids, no: P113ABody, +scope: List<&2,String>) -> P113ABody:
  match no:
    case P113ABody{body,next}: p113a_prefix([P113DIf{condition,yes,body}],x192hf_late_stmts(rest,ids,next,scope))

@unsafe
def x192hf_late_stmts(body,ids,site,scope):
  match body:
    case Nil{}: P113ABody{[],site}
    case Con{P113DScalar{N111If{condition,yes,no}},rest}:
      x192hf_late_yes(condition,x181_scalar_rows(no),rest,ids,x192hf_late_stmts(x181_scalar_rows(yes),ids,site,scope),scope)
    case Con{P113DScalar{stmt},rest}:
      p113a_prefix(x181_scalar_rows(x192hf_scalar(stmt,ids,site,scope)),
        x192hf_late_stmts(rest,ids,nt_choose(U32,U32.is_lt(site,4294967200),u => U32.inc(site),u => site),scope))
    case Con{P113DIf{condition,yes,no},rest}:
      x192hf_late_yes(condition,no,rest,ids,x192hf_late_stmts(yes,ids,site,scope),scope)
    case Con{head,rest}: p113a_prefix([head],x192hf_late_stmts(rest,ids,site,scope))

@unsafe
def x192hf_function_late_setup(symbol: String, params: List<&2,String>, body: List<&2,P113DStmt>,
    +ids: N111Ids, scope: List<&2,String>, setup: P113ABody) -> X181Output:
  match setup:
    case P113ABody{ready,next}: x185_function_late_body(symbol,params,ready,ids,x192hf_late_stmts(body,ids,next,scope))

@unsafe
def x192hf_function_setup(+symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +ids: N111Ids, scope: List<&2,String>) -> X181Output:
  nt_choose(X181Output,x185_late_enabled() && p114t_names(params) && p114t_body_names(setup) && p114t_body_names(body),
    u => x192hf_function_late_setup(symbol,params,body,ids,x192hf_scope(scope,params,setup,body),
      x185_late_stmts(setup,ids,0)),u => x185_function_place(symbol,params,setup,body,ids))
