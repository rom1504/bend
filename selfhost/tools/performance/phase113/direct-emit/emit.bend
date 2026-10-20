# Complete direct functions use QBE mutable temporaries/SSA construction.
# Native calls are acyclic; self edges use a local label and parallel moves.
def p113e_symbol(name: String) -> String:
  "p113d_" ++ nt_fid(name)

@unsafe
def p113e_formals(params: List<&2,NC_Binding>, acc: String) -> String:
  match params:
    case Nil{}: acc
    case Con{NC_Binding{id,word,kind},rest}: p113e_formals(rest,acc ++ ", l " ++ p111q_local(word))

@unsafe
def p113e_arguments(values: List<&2,N111Value>, +ids: N111Ids, acc: String) -> String:
  match values:
    case Nil{}: acc
    case Con{head,rest}: p113e_arguments(rest,ids,acc ++ ", l " ++ p111q_value(head,ids))

@unsafe
def p113e_snapshot(values: List<&2,N111Value>, +ids: N111Ids, +index: U32, code: P111QCode) -> P111QCode:
  match values:
    case Nil{}: code
    case Con{head,rest}: p113e_snapshot(rest,ids,U32.inc(index),p111q_line("%p113_again_" ++ U32.show(index) ++ " =l copy " ++ p111q_value(head,ids) ++ "\n",code))

def p113e_again_end(code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,n,terminal,error}: P111QCode{Con{"jmp @p113_loop\n",chunks},n,True{},error}

@unsafe
def p113e_moves(params: List<&2,NC_Binding>, +index: U32, code: P111QCode) -> P111QCode:
  match params:
    case Nil{}: p113e_again_end(code)
    case Con{NC_Binding{id,word,kind},rest}: p113e_moves(rest,U32.inc(index),p111q_line(p111q_local(word) ++ " =l copy %p113_again_" ++ U32.show(index) ++ "\n",code))

@unsafe
def p113e_load_results(names: List<&2,String>, +index: U32, code: P111QCode) -> P111QCode:
  match names code:
    case Nil{} _: code
    case Con{name,rest} P111QCode{chunks,+n,terminal,error}:
      +at = "%p113_result_at_" ++ U32.show(n)
      +prefix : P111QCode = P111QCode{Con{at ++ " =l add %p113_results, " ++ U32.show(U32.mul(index,8)) ++ "\n",chunks},U32.inc(n),terminal,error}
      p113e_load_results(rest,U32.inc(index),p111q_line(p111q_local(name) ++ " =l loadl " ++ at ++ "\n",prefix))

@unsafe
def p113e_call_emit(+destinations: List<&2,String>, +target: String, +args: List<&2,N111Value>, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match destinations:
    case Con{name,Nil{}}: p111q_line(p111q_local(name) ++ " =l call $" ++ p113e_symbol(target) ++ "(" ++ p113e_arguments(args,ids,"l %state") ++ ")\n",code)
    case _: p113e_load_results(destinations,0,p111q_line("%p113_status =l call $" ++ p113e_symbol(target) ++ "(" ++ p113e_arguments(args,ids,"l %state, l %p113_results") ++ ")\n",code))

@unsafe
def p113e_store_results(values: List<&2,N111Value>, +ids: N111Ids, +index: U32, code: P111QCode) -> P111QCode:
  match values code:
    case Nil{} _: p111q_return("0",code)
    case Con{head,rest} P111QCode{chunks,+n,terminal,error}:
      +at = "%p113_output_at_" ++ U32.show(n)
      +prefix : P111QCode = P111QCode{Con{at ++ " =l add %p113_result_out, " ++ U32.show(U32.mul(index,8)) ++ "\n",chunks},U32.inc(n),terminal,error}
      p113e_store_results(rest,ids,U32.inc(index),p111q_line("storel " ++ p111q_value(head,ids) ++ ", " ++ at ++ "\n",prefix))

@unsafe
def p113e_result_emit(values: List<&2,N111Value>, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match values:
    case Con{value,Nil{}}: p111q_return(p111q_value(value,ids),code)
    case _: p113e_store_results(values,ids,0,code)

@unsafe
def p113e_stmts(body: List<&2,P113DStmt>, +params: List<&2,NC_Binding>, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match body code:
    case Nil{} _: code
    case Con{head,rest} P111QCode{chunks,n,terminal,+error}:
      nt_choose(P111QCode,Bool.not(String.is_empty(error)),u => code,u =>
        nt_choose(P111QCode,terminal,u => p111q_problem("statement follows direct transfer",code),
          u => p113e_stmts(rest,params,ids,p113e_stmt_emit(head,params,ids,code))))

@unsafe
def p113e_stmt_emit(stmt: P113DStmt, +params: List<&2,NC_Binding>, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match stmt:
    case P113DScalar{scalar}: p111q_stmt(scalar,ids,code)
    case P113DIf{condition,yes,no}: p113e_if(condition,yes,no,params,ids,code)
    case P113DCall{destinations,target,args}: p113e_call_emit(destinations,target,args,ids,code)
    case P113DResult{values}: p113e_result_emit(values,ids,code)
    case P113DAgain{values}: p113e_moves(params,0,p113e_snapshot(values,ids,0,code))

@unsafe
def p113e_if(+condition: N111Value, +yes: List<&2,P113DStmt>, +no: List<&2,P113DStmt>, +params: List<&2,NC_Binding>, +ids: N111Ids, code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,n,terminal,error}:
      p113e_if_yes(n,no,params,ids,p113e_stmts(yes,params,ids,
        P111QCode{Con{p111q_label(n) ++ "\n",Con{"jnz " ++ p111q_value(condition,ids) ++ ", " ++ p111q_label(n) ++ ", " ++ p111q_label(U32.inc(n)) ++ "\n",chunks}},U32.add(n,3),False{},error}))

@unsafe
def p113e_if_yes(+label: U32, +no: List<&2,P113DStmt>, +params: List<&2,NC_Binding>, +ids: N111Ids, yes: P111QCode) -> P111QCode:
  match yes:
    case P111QCode{chunks,n,terminal,error}:
      +prefix = nt_choose(List<&2,String>,terminal,u => chunks,u => Con{"jmp " ++ p111q_label(U32.add(label,2)) ++ "\n",chunks})
      p111q_if_done(label,terminal,p113e_stmts(no,params,ids,P111QCode{Con{p111q_label(U32.inc(label)) ++ "\n",prefix},n,False{},error}))

@unsafe
def p113e_allocas(body: List<&2,P113DStmt>, acc: List<&2,String>) -> List<&2,String>:
  match body:
    case Nil{}: acc
    case Con{P113DScalar{stmt},rest}: p113e_allocas(rest,p111q_alloca(stmt,acc))
    case Con{P113DIf{condition,yes,no},rest}: p113e_allocas(rest,p113e_allocas(no,p113e_allocas(yes,acc)))
    case Con{stmt,rest}: p113e_allocas(rest,acc)

@unsafe
def p113e_multi(body: List<&2,P113DStmt>) -> Bool:
  match body:
    case Nil{}: False{}
    case Con{P113DCall{destinations,target,args},rest}: U32.is_gt(nt_count(String,destinations),1) || p113e_multi(rest)
    case Con{P113DIf{condition,yes,no},rest}: p113e_multi(yes) || p113e_multi(no) || p113e_multi(rest)
    case Con{stmt,rest}: p113e_multi(rest)

@unsafe
def p113e_private(function: P113DFunction, +ids: N111Ids) -> String:
  match function:
    case P113DFunction{name,+params,+result,public,+body}:
      +allocas = p113e_allocas(body,["%v_scratch =l alloc8 2048\n"])
      +allocas = nt_choose(List<&2,String>,p113e_multi(body),u => Con{"%p113_results =l alloc8 64\n",allocas},u => allocas)
      "function l $" ++ p113e_symbol(name) ++ "(" ++ p113e_formals(params,nt_choose(String,U32.is_eq(result,1),u => "l %state",u => "l %state, l %p113_result_out")) ++ ") {\n@entry\n" ++
        p111q_body_text(p113e_stmts(body,params,ids,P111QCode{Con{"@p113_loop\n",Con{"jmp @p113_loop\n",allocas}},0,False{},""})) ++ "}\n"

@unsafe
def p113e_private_chunks(functions: List<&2,P113DFunction>, +ids: N111Ids, acc: List<&2,String>) -> List<&2,String>:
  match functions:
    case Nil{}: nt_reverse(String,acc,[])
    case Con{function,rest}: p113e_private_chunks(rest,ids,Con{p113e_private(function,ids),acc})

@unsafe
def p113e_public_args(+arity: U32, +index: U32, +acc: String) -> String:
  nt_choose(String,U32.is_eq(index,arity),u => acc,u => p113e_public_args(arity,U32.inc(index),acc ++ ", l %p113_arg_" ++ U32.show(index)))

@unsafe
def p113e_public_loads(+arity: U32, +index: U32, +acc: String) -> String:
  nt_choose(String,U32.is_eq(index,arity),u => acc,u =>
    p113e_public_loads(arity,U32.inc(index),acc ++ "%p113_arg_" ++ U32.show(index) ++ " =l call $p111_rt_reg_get(l %state, w " ++ U32.show(index) ++ ")\n"))

@unsafe
def p113e_public(+name: String, +arity: U32) -> String:
  "export function l $" ++ p111q_symbol(name) ++ "(l %state) {\n@entry\n%p113_public_out =l alloc8 8\n" ++
    p113e_public_loads(arity,0,"") ++ "%p113_public_value =l call $" ++ p113e_symbol(name) ++ "(" ++ p113e_public_args(arity,0,"l %state") ++ ")\n" ++
    "storel %p113_public_value, %p113_public_out\n%p113_public_reply =l call $p111_rt_return(l %state, l %p113_public_out, w 1)\nret %p113_public_reply\n}\n"
