# Optional stack-safe flat traversals. Predicate helpers and the original
# verification gate remain unchanged; only pure conjunction is accumulated.
@unsafe
def p114ts_names(names: List<&2,String>, valid: Bool) -> Bool:
  match names:
    case Nil{}: valid
    case Con{name,rest}: p114ts_names(rest,valid && p114t_local_name(name))

@unsafe
def p114t_names(names: List<&2,String>) -> Bool:
  p114ts_names(names,True{})

@unsafe
def p114ts_params(params: List<&2,NC_Binding>, valid: Bool) -> Bool:
  match params:
    case Nil{}: valid
    case Con{NC_Binding{id,word,kind},rest}: p114ts_params(rest,valid && p114t_local_name(word))

@unsafe
def p114t_params(params: List<&2,NC_Binding>) -> Bool:
  p114ts_params(params,True{})

@unsafe
def p114ts_scalar_list(body: List<&2,N111Stmt>, valid: Bool) -> Bool:
  match body:
    case Nil{}: valid
    case Con{head,rest}: p114ts_scalar_list(rest,valid && p114t_scalar_names(head))

@unsafe
def p114t_scalar_list_names(body: List<&2,N111Stmt>) -> Bool:
  p114ts_scalar_list(body,True{})

@unsafe
def p114ts_body(body: List<&2,P113DStmt>, valid: Bool) -> Bool:
  match body:
    case Nil{}: valid
    case Con{P113DScalar{stmt},rest}: p114ts_body(rest,valid && p114t_scalar_names(stmt))
    case Con{P113DIf{condition,yes,no},rest}:
      p114ts_body(rest,valid && p114t_body_names(yes) && p114t_body_names(no))
    case Con{P113DCall{destinations,target,args},rest}: p114ts_body(rest,valid && p114t_names(destinations))
    case Con{head,rest}: p114ts_body(rest,valid)

@unsafe
def p114t_body_names(body: List<&2,P113DStmt>) -> Bool:
  p114ts_body(body,True{})

@unsafe
def p114ts_functions(functions: List<&2,P113DFunction>, valid: Bool) -> Bool:
  match functions:
    case Nil{}: valid
    case Con{P113DFunction{name,params,result,public,body},rest}:
      p114ts_functions(rest,valid && p114t_params(params) && p114t_body_names(body))

@unsafe
def p114t_function_names(functions: List<&2,P113DFunction>) -> Bool:
  p114ts_functions(functions,True{})

@unsafe
def p114ts_segments(segments: List<&2,N111Segment>, valid: Bool) -> Bool:
  match segments:
    case Nil{}: valid
    case Con{N111Segment{name,arity,result,incoming,flags,body},rest}:
      p114ts_segments(rest,valid && p114t_scalar_list_names(body))

@unsafe
def p114t_segment_names(segments: List<&2,N111Segment>) -> Bool:
  p114ts_segments(segments,True{})
