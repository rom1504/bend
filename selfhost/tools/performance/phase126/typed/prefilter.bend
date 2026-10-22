# Necessary staged filter only. It cannot add a typed formal or change a proof.
# Avoid building alias graphs for nonnumeric functions in the whole compiler.
@unsafe
def p126a_seen_call(found: Maybe<&2,P126TPlan>) -> Bool:
  match found:
    case None{}: False{}
    case Some{plan}: True{}

@unsafe
def p126a_seen(+body: List<&2,P113DStmt>, +plans: List<&2,P126TPlan>) -> Bool:
  p126a_seen_group(body,plans,p114so_group(body))

@unsafe
def p126a_seen_group(+body: List<&2,P113DStmt>, +plans: List<&2,P126TPlan>, group: P114SOGroup) -> Bool:
  match group:
    case P114SOYes{buffer,name,id,left,right,rest}: True{}
    case P114SONo{}: p126a_seen_head(body,plans)

@unsafe
def p126a_seen_head(body: List<&2,P113DStmt>, +plans: List<&2,P126TPlan>) -> Bool:
  match body:
    case Nil{}: False{}
    case Con{P113DIf{condition,yes,no},rest}: p126a_seen(yes,plans) || p126a_seen(no,plans) || p126a_seen(rest,plans)
    case Con{P113DCall{destinations,target,args},rest}: p126a_seen_call(p126t_find(plans,target)) || p126a_seen(rest,plans)
    case Con{head,rest}: p126a_seen(rest,plans)

@unsafe
def p126t_analyze(function: P113DFunction, +plans: List<&2,P126TPlan>) -> List<&2,String>:
  match function:
    case P113DFunction{name,+params,result,public,+body}:
      nt_choose(List<&2,String>,p126a_seen(body,plans) && U32.is_le(nt_count(NC_Binding,params),32) && U32.is_le(p113i_size(body),4096),
        u => nt_choose(List<&2,String>,U32.is_eq(p113a_count_body(body,0),0),
          v => p126a_formals(params,p126a_body(body,params,plans,p114so_buffers(body),missing()),[]),v => []),u => [])
