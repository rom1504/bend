# Optional diagnostics; normal compilation does not build this text.
@unsafe
def p113j_calls(body: List<&2,P113DStmt>) -> List<&2,String>:
  match body:
    case Nil{}: []
    case Con{P113DCall{destinations,target,args},rest}: Con{target,p113j_calls(rest)}
    case Con{P113DIf{condition,yes,no},rest}:
      nt_append(String,p113j_calls(yes),nt_append(String,p113j_calls(no),p113j_calls(rest)))
    case Con{stmt,rest}: p113j_calls(rest)

@unsafe
def p113j_reason(function: P113DFunction) -> String:
  match function:
    case P113DFunction{name,+params,+result,public,+body}:
      nt_choose(String,U32.is_lt(result,1) || U32.is_gt(result,8),u => "result-width",u =>
      nt_choose(String,U32.is_gt(nt_count(NC_Binding,params),32),u => "argument-count",u =>
      nt_choose(String,U32.is_gt(p113i_size(body),192),u => "node-budget",u =>
      nt_choose(String,U32.is_gt(p113i_stack(body),8192),u => "stack-budget",u =>
      nt_choose(String,Bool.not(p113i_params(params)),u => "parameter-prefix",u =>
      nt_choose(String,Bool.not(p113j_returns(body,result)),u => "loop-or-partial-return",u => "eligible"))))))

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
