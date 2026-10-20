@unsafe
def p114rt_scan(body: List<&2,P113DStmt>, +n: U32, +heap_min: U32, +constructors: U32) -> P113ABody:
  match body:
    case Nil{}: P113ABody{[],n}
    case Con{P113DScalar{+stmt},+rest}:
      nt_choose(P113ABody,p114rt_take2(stmt),
        u => p113a_prefix(p113d_scalars(p114rt_template(stmt,n,heap_min,constructors)),p114rt_scan(rest,U32.inc(n),heap_min,constructors)),
        u => p113a_prefix([P113DScalar{stmt}],p114rt_scan(rest,n,heap_min,constructors)))
    case Con{P113DIf{condition,yes,no},rest}:
      p114rt_scan_yes(condition,no,rest,heap_min,constructors,p114rt_scan(yes,n,heap_min,constructors))
    case Con{head,rest}: p113a_prefix([head],p114rt_scan(rest,n,heap_min,constructors))

@unsafe
def p114rt_scan_yes(condition: N111Value, no: List<&2,P113DStmt>, rest: List<&2,P113DStmt>, +heap_min: U32, +constructors: U32, yes: P113ABody) -> P113ABody:
  match yes:
    case P113ABody{body,next}: p114rt_scan_no(condition,body,rest,heap_min,constructors,p114rt_scan(no,next,heap_min,constructors))

@unsafe
def p114rt_scan_no(condition: N111Value, yes: List<&2,P113DStmt>, rest: List<&2,P113DStmt>, +heap_min: U32, +constructors: U32, no: P113ABody) -> P113ABody:
  match no:
    case P113ABody{body,next}: p113a_prefix([P113DIf{condition,yes,body}],p114rt_scan(rest,next,heap_min,constructors))

@unsafe
def p114rt_function_ir(function: P113DFunction, +heap_min: U32, +constructors: U32) -> P113DFunction:
  match function:
    case P113DFunction{name,params,result,public,body}:
      p113a_function_done(name,params,result,public,p114rt_scan(body,0,heap_min,constructors))

@unsafe
def p114rt_count_body(body: List<&2,P113DStmt>, count: U32) -> U32:
  match body:
    case Nil{}: count
    case Con{P113DScalar{stmt},rest}:
      p114rt_count_body(rest,U32.add(count,Bool.to_u32(p114rt_take2(stmt))))
    case Con{P113DIf{condition,yes,no},rest}: p114rt_count_body(rest,p114rt_count_body(no,p114rt_count_body(yes,count)))
    case Con{head,rest}: p114rt_count_body(rest,count)

@unsafe
def p114rt_count_functions(functions: List<&2,P113DFunction>, count: U32) -> U32:
  match functions:
    case Nil{}: count
    case Con{P113DFunction{name,params,result,public,body},rest}:
      p114rt_count_functions(rest,p114rt_count_body(body,count))

@unsafe
def p114rt_sites(program: P113AProgram) -> U32:
  match program:
    case P113AProgram{P113DProgram{original,functions},certificate}: p114rt_count_functions(functions,0)

@unsafe
def p114rt_function(+function: P113DFunction, +ids: N111Ids, +heap_min: U32, +constructors: U32, +arrays: Bool) -> String:
  match function:
    case P113DFunction{name,params,result,public,+body}:
      nt_choose(String,U32.is_gt(p114rt_count_body(body,0),0) || (arrays && U32.is_gt(p113a_count_body(body,0),0)),
        u => p113ah_private(p114rt_function_ir(nt_choose(P113DFunction,arrays,
          v => p113a_function(function,heap_min),v => function),heap_min,constructors),ids),
        u => p113e_private(function,ids))

@unsafe
def p114rt_private_chunks(functions: List<&2,P113DFunction>, +ids: N111Ids, +heap_min: U32, +constructors: U32, +arrays: Bool, acc: List<&2,String>) -> List<&2,String>:
  match functions:
    case Nil{}: nt_reverse(String,acc,[])
    case Con{function,rest}: p114rt_private_chunks(rest,ids,heap_min,constructors,arrays,
      Con{p114rt_function(function,ids,heap_min,constructors,arrays),acc})
