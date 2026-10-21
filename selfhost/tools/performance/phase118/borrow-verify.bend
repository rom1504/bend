# Structural projection only: the extra readonly copy has the same buffer/Term
# signature as Take. This projection is NOT a semantic equality claim. Borrow
# legality comes from re-deriving NO_Plan and validating its complete residual;
# all original functions are independently checked by unchanged p113a_verify.
@unsafe
def p118b_project_call(+stmt: N111Stmt, +ids: N111Ids) -> P113DCode:
  match stmt:
    case N111Call{+name,+typ,+symbol,+args}:
      nt_choose(P113DCode,String.eq(symbol,"p118_rt_borrow_fields"),
        u => p118b_project_borrow(name,typ,args,ids),
        u => P113DCode{[P113DScalar{stmt}],0,"",[]})
    case _: P113DCode{[P113DScalar{stmt}],0,"",[]}

@unsafe
def p118b_project_borrow(+name: String, +typ: N111Type, +args: List<&2,N111Arg>, +ids: N111Ids) -> P113DCode:
  +ctor = p111v_target(p111v_arg(args,3),ids,True{})
  +count = p111v_literal(p111v_arg(args,4))
  +ok = U32.is_eq(nt_count(N111Arg,args),5) && U32.is_eq(p111v_type(typ),2) &&
    Bool.not(String.eq(dk(ctor),"Absent")) && U32.is_eq(da(ctor),count) &&
    U32.is_ge(count,2) && U32.is_le(count,8)
  +projected : N111Stmt = N111Call{name,typ,"p111_rt_take",[
    p111_state(),p111_word(p111v_arg(args,1)),N111Arg{N111Ptr{},p111v_arg(args,2)},p111_u32(count)]}
  nt_choose(P113DCode,ok && p111v_state_argument(args),
    u => P113DCode{[P113DScalar{projected}],0,"",[]},
    u => p113d_fail("borrowed import: constructor/count contract",0))

@unsafe
def p118b_project(body: List<&2,P113DStmt>, +ids: N111Ids) -> P113DCode:
  match body:
    case Nil{}: P113DCode{[],0,"",[]}
    case Con{P113DScalar{stmt},rest}: p113d_join(p118b_project_call(stmt,ids),p118b_project(rest,ids))
    case Con{P113DIf{condition,yes,no},rest}:
      p113d_join(p113d_branch(condition,p118b_project(yes,ids),p118b_project(no,ids)),p118b_project(rest,ids))
    case Con{head,rest}: p113d_join(P113DCode{[head],0,"",[]},p118b_project(rest,ids))

@unsafe
def p118b_project_function(+function: P113DFunction, +ids: N111Ids) -> P118BWorkers:
  match function:
    case P113DFunction{name,params,result,public,body}:
      +projected = p118b_project(body,ids)
      P118BWorkers{[P113DFunction{name,params,result,public,p113d_body(projected)}],p113d_error(projected)}

@unsafe
def p118b_workers_join(+first: P118BWorkers, +second: P118BWorkers) -> P118BWorkers:
  match first second:
    case P118BWorkers{a,ae} P118BWorkers{b,be}: P118BWorkers{nt_append(P113DFunction,a,b),p111_first(ae,be)}

@unsafe
def p118b_project_functions(functions: List<&2,P113DFunction>, +ids: N111Ids) -> P118BWorkers:
  match functions:
    case Nil{}: P118BWorkers{[],""}
    case Con{head,rest}: p118b_workers_join(p118b_project_function(head,ids),p118b_project_functions(rest,ids))

@unsafe
def p118b_verify_projected(+ids: N111Ids, workers: P118BWorkers) -> String:
  match workers:
    case P118BWorkers{functions,+error}:
      nt_choose(String,String.is_empty(error),u => p113e_functions(functions,ids,missing()),u => error)

@unsafe
def p118b_verify_functions(+functions: List<&2,P113DFunction>, +original: P111Program) -> String:
  match original:
    case P111Program{segments,constructors,show,names,effects,pure}:
      +ids : N111Ids = N111Ids{p113e_originals(segments,missing()),ns_ctor_index(constructors,missing())}
      p118b_verify_projected(ids,p118b_project_functions(functions,ids))
