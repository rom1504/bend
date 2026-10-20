# The unchanged original verifier checks definite assignment first. Checking
# definitions and direct parameters therefore also covers original local uses.
# Unlike the Take2-only gate, this expansion reaches generic segment bodies.
@unsafe
def p114t_local_name(+name: String) -> Bool:
  Bool.not(String.starts_with(name,"p114t_"))

@unsafe
def p114t_names(names: List<&2,String>) -> Bool:
  match names:
    case Nil{}: True{}
    case Con{name,rest}: p114t_local_name(name) && p114t_names(rest)

@unsafe
def p114t_params(params: List<&2,NC_Binding>) -> Bool:
  match params:
    case Nil{}: True{}
    case Con{NC_Binding{id,word,kind},rest}: p114t_local_name(word) && p114t_params(rest)

@unsafe
def p114t_scalar_names(stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Set{name,typ,value}: p114t_local_name(name)
    case N111Bin{name,typ,op,left,right}: p114t_local_name(name)
    case N111Call{name,typ,symbol,args}: p114t_local_name(name)
    case N111If{condition,yes,no}: p114t_scalar_list_names(yes) && p114t_scalar_list_names(no)
    case N111Load{name,typ,base,offset}: p114t_local_name(name)
    case N111Offset{name,base,bytes}: p114t_local_name(name)
    case N111Alloca{name,bytes,align}: p114t_local_name(name)
    case _: True{}

@unsafe
def p114t_scalar_list_names(body: List<&2,N111Stmt>) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{head,rest}: p114t_scalar_names(head) && p114t_scalar_list_names(rest)

@unsafe
def p114t_body_names(body: List<&2,P113DStmt>) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{P113DScalar{stmt},rest}: p114t_scalar_names(stmt) && p114t_body_names(rest)
    case Con{P113DIf{condition,yes,no},rest}: p114t_body_names(yes) && p114t_body_names(no) && p114t_body_names(rest)
    case Con{P113DCall{destinations,target,args},rest}: p114t_names(destinations) && p114t_body_names(rest)
    case Con{head,rest}: p114t_body_names(rest)

@unsafe
def p114t_function_names(functions: List<&2,P113DFunction>) -> Bool:
  match functions:
    case Nil{}: True{}
    case Con{P113DFunction{name,params,result,public,body},rest}:
      p114t_params(params) && p114t_body_names(body) && p114t_function_names(rest)

@unsafe
def p114t_segment_names(segments: List<&2,N111Segment>) -> Bool:
  match segments:
    case Nil{}: True{}
    case Con{N111Segment{name,arity,result,incoming,flags,body},rest}:
      p114t_scalar_list_names(body) && p114t_segment_names(rest)

@unsafe
def p114t_namespace(program: P113AProgram) -> Bool:
  match program:
    case P113AProgram{P113DProgram{P112StaticProgram{P111Program{segments,constructors,show,names,effects,pure},nodes},functions},certificate}:
      p114t_segment_names(segments) && p114t_function_names(functions)

@unsafe
def p114t_verify_done(+program: P113AProgram, +error: String) -> String:
  nt_choose(String,Bool.not(String.is_empty(error)),u => error,u =>
    nt_choose(String,p114t_namespace(program),v => "",v => "reserved transport-template local"))
