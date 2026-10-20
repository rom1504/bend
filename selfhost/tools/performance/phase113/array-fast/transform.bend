# Original definite-assignment verification precedes this namespace guard.
# Thus guarding every definition also guards every original local use.
@unsafe
def p113a_local_name(name: String) -> Bool:
  Bool.not(String.starts_with(name,"p113a_"))

@unsafe
def p113a_names(names: List<&2,String>) -> Bool:
  match names:
    case Nil{}: True{}
    case Con{name,rest}: p113a_local_name(name) && p113a_names(rest)

@unsafe
def p113a_params(params: List<&2,NC_Binding>) -> Bool:
  match params:
    case Nil{}: True{}
    case Con{NC_Binding{id,word,kind},rest}: p113a_local_name(word) && p113a_params(rest)

@unsafe
def p113a_scalar_names(stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Set{name,typ,value}: p113a_local_name(name)
    case N111Bin{name,typ,op,left,right}: p113a_local_name(name)
    case N111Call{name,typ,symbol,args}: p113a_local_name(name)
    case N111If{condition,yes,no}: p113a_scalar_list_names(yes) && p113a_scalar_list_names(no)
    case N111Load{name,typ,base,offset}: p113a_local_name(name)
    case N111Offset{name,base,bytes}: p113a_local_name(name)
    case N111Alloca{name,bytes,align}: p113a_local_name(name)
    case _: True{}

@unsafe
def p113a_scalar_list_names(body: List<&2,N111Stmt>) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{head,rest}: p113a_scalar_names(head) && p113a_scalar_list_names(rest)

@unsafe
def p113a_body_names(body: List<&2,P113DStmt>) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{P113DScalar{stmt},rest}: p113a_scalar_names(stmt) && p113a_body_names(rest)
    case Con{P113DIf{condition,yes,no},rest}: p113a_body_names(yes) && p113a_body_names(no) && p113a_body_names(rest)
    case Con{P113DCall{destinations,target,args},rest}: p113a_names(destinations) && p113a_body_names(rest)
    case Con{head,rest}: p113a_body_names(rest)

@unsafe
def p113a_function_names(functions: List<&2,P113DFunction>) -> Bool:
  match functions:
    case Nil{}: True{}
    case Con{P113DFunction{name,params,result,public,body},rest}:
      p113a_params(params) && p113a_body_names(body) && p113a_function_names(rest)

@unsafe
def p113a_namespace(program: P113DProgram) -> Bool:
  match program:
    case P113DProgram{original,functions}: p113a_function_names(functions)

@unsafe
def p113a_verify_after(+program: P113DProgram, +certificate: P113ACertificate, +error: String) -> String:
  nt_choose(String,Bool.not(String.is_empty(error)),u => error,u =>
    nt_choose(String,Bool.not(p113a_enabled(certificate)) || p113a_namespace(program),
      v => "",v => "reserved private array-template local"))

@unsafe
def p113a_verify(program: P113AProgram) -> String:
  match program:
    case P113AProgram{+original,certificate}: p113a_verify_after(original,certificate,p113d_verify(original))

@unsafe
def p113a_prefix(prefix: List<&2,P113DStmt>, scan: P113ABody) -> P113ABody:
  match scan:
    case P113ABody{body,next}: P113ABody{nt_append(P113DStmt,prefix,body),next}

@unsafe
def p113a_scan(body: List<&2,P113DStmt>, +n: U32, +heap_min: U32) -> P113ABody:
  match body:
    case Nil{}: P113ABody{[],n}
    case Con{P113DScalar{+stmt},+rest}:
      nt_choose(P113ABody,U32.is_gt(p113a_stmt_id(stmt),0),
        u => p113a_prefix(p113d_scalars(p113a_template(stmt,n,heap_min)),p113a_scan(rest,U32.inc(n),heap_min)),
        u => p113a_prefix([P113DScalar{stmt}],p113a_scan(rest,n,heap_min)))
    case Con{P113DIf{condition,yes,no},rest}:
      p113a_scan_yes(condition,no,rest,heap_min,p113a_scan(yes,n,heap_min))
    case Con{head,rest}: p113a_prefix([head],p113a_scan(rest,n,heap_min))

@unsafe
def p113a_scan_yes(condition: N111Value, no: List<&2,P113DStmt>, rest: List<&2,P113DStmt>, +heap_min: U32, yes: P113ABody) -> P113ABody:
  match yes:
    case P113ABody{body,next}: p113a_scan_no(condition,body,rest,heap_min,p113a_scan(no,next,heap_min))

@unsafe
def p113a_scan_no(condition: N111Value, yes: List<&2,P113DStmt>, rest: List<&2,P113DStmt>, +heap_min: U32, no: P113ABody) -> P113ABody:
  match no:
    case P113ABody{body,next}: p113a_prefix([P113DIf{condition,yes,body}],p113a_scan(rest,next,heap_min))

@unsafe
def p113a_function_done(name: String, params: List<&2,NC_Binding>, result: U32, public: Bool, scan: P113ABody) -> P113DFunction:
  match scan:
    case P113ABody{body,next}: P113DFunction{name,params,result,public,body}

@unsafe
def p113a_function(function: P113DFunction, +heap_min: U32) -> P113DFunction:
  match function:
    case P113DFunction{name,params,result,public,body}: p113a_function_done(name,params,result,public,p113a_scan(body,0,heap_min))

@unsafe
def p113a_functions(functions: List<&2,P113DFunction>, +heap_min: U32) -> List<&2,P113DFunction>:
  match functions:
    case Nil{}: []
    case Con{head,rest}: Con{p113a_function(head,heap_min),p113a_functions(rest,heap_min)}

@unsafe
def p113a_count_body(body: List<&2,P113DStmt>, count: U32) -> U32:
  match body:
    case Nil{}: count
    case Con{P113DScalar{stmt},rest}:
      p113a_count_body(rest,U32.add(count,nt_choose(U32,U32.is_gt(p113a_stmt_id(stmt),0),u => 1,u => 0)))
    case Con{P113DIf{condition,yes,no},rest}: p113a_count_body(rest,p113a_count_body(no,p113a_count_body(yes,count)))
    case Con{head,rest}: p113a_count_body(rest,count)

@unsafe
def p113a_count_functions(functions: List<&2,P113DFunction>, count: U32) -> U32:
  match functions:
    case Nil{}: count
    case Con{P113DFunction{name,params,result,public,body},rest}: p113a_count_functions(rest,p113a_count_body(body,count))
