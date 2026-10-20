# Original definite-assignment verification precedes this namespace guard.
# Thus guarding every definition also guards every original local use.
@unsafe
def p114rt_local_name(+name: String) -> Bool:
  Bool.not(String.starts_with(name,"p114rt_") || String.starts_with(name,"p113a_"))

@unsafe
def p114rt_names(names: List<&2,String>) -> Bool:
  match names:
    case Nil{}: True{}
    case Con{name,rest}: p114rt_local_name(name) && p114rt_names(rest)

@unsafe
def p114rt_params(params: List<&2,NC_Binding>) -> Bool:
  match params:
    case Nil{}: True{}
    case Con{NC_Binding{id,word,kind},rest}: p114rt_local_name(word) && p114rt_params(rest)

@unsafe
def p114rt_scalar_names(stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Set{name,typ,value}: p114rt_local_name(name)
    case N111Bin{name,typ,op,left,right}: p114rt_local_name(name)
    case N111Call{name,typ,symbol,args}: p114rt_local_name(name)
    case N111If{condition,yes,no}: p114rt_scalar_list_names(yes) && p114rt_scalar_list_names(no)
    case N111Load{name,typ,base,offset}: p114rt_local_name(name)
    case N111Offset{name,base,bytes}: p114rt_local_name(name)
    case N111Alloca{name,bytes,align}: p114rt_local_name(name)
    case _: True{}

@unsafe
def p114rt_scalar_list_names(body: List<&2,N111Stmt>) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{head,rest}: p114rt_scalar_names(head) && p114rt_scalar_list_names(rest)

@unsafe
def p114rt_body_names(body: List<&2,P113DStmt>) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{P113DScalar{stmt},rest}: p114rt_scalar_names(stmt) && p114rt_body_names(rest)
    case Con{P113DIf{condition,yes,no},rest}: p114rt_body_names(yes) && p114rt_body_names(no) && p114rt_body_names(rest)
    case Con{P113DCall{destinations,target,args},rest}: p114rt_names(destinations) && p114rt_body_names(rest)
    case Con{head,rest}: p114rt_body_names(rest)

@unsafe
def p114rt_function_names(functions: List<&2,P113DFunction>) -> Bool:
  match functions:
    case Nil{}: True{}
    case Con{P113DFunction{name,params,result,public,body},rest}:
      Bool.not(String.starts_with(name,"p114rt_")) &&
        p114rt_params(params) && p114rt_body_names(body) && p114rt_function_names(rest)

@unsafe
def p114rt_segment_names(segments: List<&2,N111Segment>) -> Bool:
  match segments:
    case Nil{}: True{}
    case Con{N111Segment{name,arity,result,incoming,flags,body},rest}:
      Bool.not(String.starts_with(name,"p114rt_")) && p114rt_segment_names(rest)

@unsafe
def p114rt_namespace(program: P113DProgram) -> Bool:
  match program:
    case P113DProgram{P112StaticProgram{P111Program{segments,constructors,show,names,effects,pure},nodes},functions}:
      p114rt_segment_names(segments) && p114rt_function_names(functions)

