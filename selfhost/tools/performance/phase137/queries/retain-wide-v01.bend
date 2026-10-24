# Profitability-only ceiling. Preserve direct calls containing a 9..16-field
# owning extraction until the existing borrowed-worker pass has run. The
# independent legality/final-verifier/runtime contracts are unchanged.
@unsafe
def p137qi_wide_args(args: List<&2,N111Arg>) -> Bool:
  match args:
    case Con{N111Arg{N111Ptr{},state},Con{N111Arg{N111U64{},term},Con{N111Arg{N111Ptr{},buffer},Con{N111Arg{N111U32{},N111Const{+count,0}},Nil{}}}}}:
      U32.is_ge(count,9) && U32.is_le(count,16)
    case _: False{}

@unsafe
def p137qi_scalar(stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Call{name,typ,symbol,args}:
      Bool.not(String.eq(symbol,"p111_rt_take") && p137qi_wide_args(args))
    case N111If{condition,yes,no}: p137qi_scalars(yes) && p137qi_scalars(no)
    case _: True{}

@unsafe
def p137qi_scalars(body: List<&2,N111Stmt>) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{head,rest}: p137qi_scalar(head) && p137qi_scalars(rest)

# Same shape walk as p113j_plain/p113j_returns. Add the profitability test while
# visiting existing scalar nodes, rather than starting a second whole-body walk.
@unsafe
def p137qi_plain(body: List<&2,P113DStmt>) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{P113DScalar{stmt},rest}: p137qi_scalar(stmt) && p137qi_plain(rest)
    case Con{P113DCall{destinations,target,args},rest}: p137qi_plain(rest)
    case Con{P113DIf{condition,yes,no},rest}: p137qi_plain(yes) && p137qi_plain(no) && p137qi_plain(rest)
    case _: False{}

@unsafe
def p137qi_returns(body: List<&2,P113DStmt>, +width: U32) -> Bool:
  match body:
    case Con{P113DResult{values},Nil{}}: U32.is_eq(nt_count(N111Value,values),width)
    case Con{P113DIf{condition,yes,no},Nil{}}: p137qi_returns(yes,width) && p137qi_returns(no,width)
    case Con{P113DIf{condition,yes,no},rest}: p137qi_plain(yes) && p137qi_plain(no) && p137qi_returns(rest,width)
    case Con{P113DScalar{stmt},rest}: p137qi_scalar(stmt) && p137qi_returns(rest,width)
    case Con{P113DCall{destinations,target,args},rest}: p137qi_returns(rest,width)
    case _: False{}

@unsafe
def p113i_eligible(+function: P113DFunction) -> Bool:
  match function:
    case P113DFunction{name,+params,+result,public,+body}:
      Bool.not(p126s_is_table(function)) && U32.is_ge(result,1) && U32.is_le(result,8) && U32.is_le(nt_count(NC_Binding,params),32) &&
        U32.is_le(p113i_size(body),512) && U32.is_le(p113i_stack(body),8192) &&
        p113i_params(params) && p137qi_returns(body,result)
