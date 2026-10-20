@unsafe
def p114g_resume_symbol(name: String) -> String:
  "p114g_resume_" ++ nt_fid(name)

@unsafe
def p114g_formals(+count: U32, +index: U32, +acc: String) -> String:
  nt_choose(String,U32.is_eq(count,index),u => acc ++ ", l %p114g_input",u =>
    p114g_formals(count,U32.inc(index),acc ++ ", l %p114g_capture_" ++ U32.show(index)))

@unsafe
def p114g_restore(captures: List<&2,String>, +index: U32, code: P111QCode) -> P111QCode:
  match captures:
    case Nil{}: code
    case Con{name,rest}: p114g_restore(rest,U32.inc(index),
      p111q_line(p111q_local(name) ++ " =l copy %p114g_capture_" ++ U32.show(index) ++ "\n",code))

@unsafe
def p114g_pop(+name: String, +code: P111QCode) -> P111QCode:
  nt_choose(P111QCode,String.is_empty(name),u => code,u => p111q_line(p111q_local(name) ++ " =l copy 0\n",code))

@unsafe
def p114g_stmts(body: List<&2,P112WorkerStmt>, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match body code:
    case Nil{} _: code
    case Con{stmt,rest} P111QCode{chunks,n,terminal,+error}:
      nt_choose(P111QCode,Bool.not(String.is_empty(error)),u => code,u =>
        nt_choose(P111QCode,terminal,u => p111q_problem("statement after local resume return",code),
          u => p114g_stmts(rest,ids,p114g_stmt(stmt,ids,code))))

@unsafe
def p114g_stmt(stmt: P112WorkerStmt, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match stmt:
    case P112WorkerScalar{scalar}: p111q_stmt(scalar,ids,code)
    case P112WorkerIf{condition,yes,no}: p114g_if(condition,yes,no,ids,code)
    case P112WorkerResult{}: p111q_return("%p114g_result",p111q_line("%p114g_result =l loadl %v_scratch\n",code))
    case P112WorkerCall{target,arity}: p112w_call(target,arity,False{},code)
    case P112WorkerAgain{}: p111q_problem("loop in local resume",code)

def p114g_diamond(yes: List<&2,P112WorkerStmt>, no: List<&2,P112WorkerStmt>) -> P113BQDiamond:
  match yes no:
    case Con{P112WorkerScalar{a},Nil{}} Con{P112WorkerScalar{b},Nil{}}: p113bq_scalar([a],[b])
    case _ _: P113BQNo{}

@unsafe
def p114g_if(+condition: N111Value, +yes: List<&2,P112WorkerStmt>, +no: List<&2,P112WorkerStmt>, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  +diamond = p114g_diamond(yes,no)
  nt_choose(P111QCode,p113bq_ready(diamond,code),u => p113bq_emit(condition,diamond,ids,code),
    u => p114g_if_original(condition,yes,no,ids,code))

@unsafe
def p114g_if_original(+condition: N111Value, +yes: List<&2,P112WorkerStmt>, +no: List<&2,P112WorkerStmt>, +ids: N111Ids, code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,n,terminal,error}:
      p114g_if_yes(n,no,ids,p114g_stmts(yes,ids,
        P111QCode{Con{p111q_label(n) ++ "\n",Con{"jnz " ++ p111q_value(condition,ids) ++ ", " ++ p111q_label(n) ++ ", " ++ p111q_label(U32.inc(n)) ++ "\n",chunks}},U32.add(n,3),False{},error}))

@unsafe
def p114g_if_yes(+label: U32, +no: List<&2,P112WorkerStmt>, +ids: N111Ids, yes: P111QCode) -> P111QCode:
  match yes:
    case P111QCode{+chunks,n,terminal,error}:
      +prefix = nt_choose(List<&2,String>,terminal,u => chunks,u => Con{"jmp " ++ p111q_label(U32.add(label,2)) ++ "\n",chunks})
      p111q_if_done(label,terminal,p114g_stmts(no,ids,P111QCode{Con{p111q_label(U32.inc(label)) ++ "\n",prefix},n,False{},error}))

@unsafe
def p114g_resume(+name: String, +captures: List<&2,String>, +result: String, pop: String, body: List<&2,P112WorkerStmt>, +ids: N111Ids) -> String:
  "function l $" ++ p114g_resume_symbol(name) ++ "(" ++ p114g_formals(nt_count(String,captures),0,"l %state") ++ ") {\n@entry\n" ++
    p111q_body_text(p114g_stmts(body,ids,
      p111q_line(p111q_local(result) ++ " =l copy %p114g_input\n",
        p114g_restore(captures,0,p114g_pop(pop,P111QCode{["%v_scratch =l alloc8 2048\n"],0,False{},""}))))) ++ "}\n"

@unsafe
def p114g_loads(+count: U32, +index: U32, +acc: String) -> String:
  nt_choose(String,U32.is_eq(count,index),u => acc,u =>
    p114g_loads(count,U32.inc(index),acc ++ "%p114g_capture_" ++ U32.show(index) ++
      " =l call $p111_rt_stack_get(l %state, w " ++ U32.show(index) ++ ")\n"))

@unsafe
def p114g_args(+count: U32, +index: U32, +acc: String) -> String:
  nt_choose(String,U32.is_eq(count,index),u => acc ++ ", l %p114r_value",u =>
    p114g_args(count,U32.inc(index),acc ++ ", l %p114g_capture_" ++ U32.show(index)))

@unsafe
def p114g_unwind(+name: String, +count: U32, code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,n,terminal,error}:
      P111QCode{Con{"@p114r_unwind\n%p114r_pending =w cnel %p114r_depth, 0\njnz %p114r_pending, @p114r_resume, @p114r_done\n@p114r_resume\n%p114r_depth =l sub %p114r_depth, 1\n%p114g_popped =l call $p111_rt_stack_pop(l %state, w " ++ U32.show(U32.inc(count)) ++ ")\n" ++
        p114g_loads(count,0,"") ++ "%p114r_value =l call $" ++ p114g_resume_symbol(name) ++ "(" ++ p114g_args(count,0,"l %state") ++ ")\njmp @p114r_unwind\n@p114r_done\nret %p114r_value\n",chunks},n,True{},error}

@unsafe
def p114g_private(+name: String, +ids: N111Ids, plan: P114GPlan) -> String:
  match plan:
    case P114GPlan{valid,+params,body,continuation,+captures,result,pop,resume}:
      "function l $" ++ p114r_symbol(name) ++ "(" ++ p112w_formals(params,"l %state") ++ ") {\n@entry\n" ++
        p111q_body_text(p114g_unwind(name,nt_count(String,captures),p114r_stmts(body,params,ids,
          P111QCode{["%v_scratch =l alloc8 2048\n%p114r_depth =l copy 0\njmp @p114r_descend\n@p114r_descend\n"],0,False{},""}))) ++ "}\n" ++
        p114g_resume(name,captures,result,pop,resume,ids)
