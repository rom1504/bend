@unsafe
def p114h_prefix(index: U32) -> String:
  "p114h_case_" ++ U32.show(index) ++ "_"

@unsafe
def p114h_rename(body: List<&2,P114RStmt>, +prefix: String) -> List<&2,P114RStmt>:
  match body:
    case Nil{}: []
    case Con{stmt,rest}: Con{p114h_rename_stmt(stmt,prefix),p114h_rename(rest,prefix)}

@unsafe
def p114h_rename_stmt(stmt: P114RStmt, +prefix: String) -> P114RStmt:
  match stmt:
    case P114RScalar{scalar}: P114RScalar{p112f_stmt(scalar,prefix)}
    case P114RIf{condition,yes,no}: P114RIf{p112f_value(condition,prefix),p114h_rename(yes,prefix),p114h_rename(no,prefix)}
    case P114RDescend{frame,arguments}: P114RDescend{p112f_rename(frame,prefix),p112f_rename(arguments,prefix)}
    case P114RAgain{arguments}: P114RAgain{p112f_rename(arguments,prefix)}
    case P114RResult{value}: P114RResult{p112f_value(value,prefix)}
    case P114RFailure{body}: P114RFailure{p112f_rename(body,prefix)}

@unsafe
def p114h_snapshots(+buffer: String, +count: U32, +index: U32, +code: P111QCode) -> P111QCode:
  nt_choose(P111QCode,U32.is_eq(count,index),u => code,u =>
    p114h_snapshots(buffer,count,U32.inc(index),p111q_line("%p114h_slot_" ++ U32.show(index) ++ " =l add " ++
      p111q_local(buffer) ++ ", " ++ U32.show(U32.mul(index,8)) ++ "\n%p114h_edge_" ++ U32.show(index) ++
      " =l loadl %p114h_slot_" ++ U32.show(index) ++ "\n",code)))

@unsafe
def p114h_moves(params: List<&2,String>, +index: U32, code: P111QCode) -> P111QCode:
  match params:
    case Nil{}: p114r_jump("@p114r_descend",code)
    case Con{name,rest}: p114h_moves(rest,U32.inc(index),
      p111q_line(p111q_local(name) ++ " =l copy %p114h_edge_" ++ U32.show(index) ++ "\n",code))

@unsafe
def p114h_again(arguments: List<&2,N111Stmt>, +params: List<&2,String>, buffer: String, ids: N111Ids, code: P111QCode) -> P111QCode:
  p114h_moves(params,0,p114h_snapshots(buffer,nt_count(String,params),0,p111q_stmts(arguments,ids,code)))

@unsafe
def p114h_stmts(body: List<&2,P114RStmt>, +params: List<&2,String>, +buffer: String, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match body code:
    case Nil{} _: code
    case Con{stmt,rest} P111QCode{chunks,n,terminal,+error}:
      nt_choose(P111QCode,Bool.not(String.is_empty(error)),u => code,u =>
        nt_choose(P111QCode,terminal,u => p111q_problem("statement after table-region transfer",code),
          u => p114h_stmts(rest,params,buffer,ids,p114h_stmt(stmt,params,buffer,ids,code))))

@unsafe
def p114h_stmt(+stmt: P114RStmt, +params: List<&2,String>, +buffer: String, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match stmt:
    case P114RIf{condition,yes,no}: p114h_if(condition,yes,no,params,buffer,ids,code)
    case P114RDescend{frame,arguments}:
      p114h_again(arguments,params,buffer,ids,p111q_line("%p114r_depth =l add %p114r_depth, 1\n",p111q_stmts(frame,ids,code)))
    case P114RAgain{arguments}: p114h_again(arguments,params,buffer,ids,code)
    case _: p114r_stmt(stmt,params,ids,code)

@unsafe
def p114h_if(+condition: N111Value, +yes: List<&2,P114RStmt>, +no: List<&2,P114RStmt>,
    +params: List<&2,String>, +buffer: String, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  +diamond = p114r_diamond(yes,no)
  nt_choose(P111QCode,p113bq_ready(diamond,code),u => p113bq_emit(condition,diamond,ids,code),
    u => p114h_if_original(condition,yes,no,params,buffer,ids,code))

@unsafe
def p114h_if_original(+condition: N111Value, +yes: List<&2,P114RStmt>, +no: List<&2,P114RStmt>,
    +params: List<&2,String>, +buffer: String, +ids: N111Ids, code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,n,terminal,error}:
      p114h_if_yes(n,no,params,buffer,ids,p114h_stmts(yes,params,buffer,ids,
        P111QCode{Con{p111q_label(n) ++ "\n",Con{"jnz " ++ p111q_value(condition,ids) ++ ", " ++ p111q_label(n) ++ ", " ++ p111q_label(U32.inc(n)) ++ "\n",chunks}},U32.add(n,3),False{},error}))

@unsafe
def p114h_if_yes(+label: U32, +no: List<&2,P114RStmt>, +params: List<&2,String>, +buffer: String, +ids: N111Ids, yes: P111QCode) -> P111QCode:
  match yes:
    case P111QCode{+chunks,n,terminal,error}:
      +prefix = nt_choose(List<&2,String>,terminal,u => chunks,u => Con{"jmp " ++ p111q_label(U32.add(label,2)) ++ "\n",chunks})
      p111q_if_done(label,terminal,p114h_stmts(no,params,buffer,ids,
        P111QCode{Con{p111q_label(U32.inc(label)) ++ "\n",prefix},n,False{},error}))

@unsafe
def p114h_terminal(+code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,n,terminal,error}:
      nt_choose(P111QCode,terminal,u => code,u => p111q_problem("unterminated table-region block",code))

@unsafe
def p114h_buffers(+count: U32, +index: U32, +acc: String) -> String:
  nt_choose(String,U32.is_eq(count,index),u => acc,u =>
    p114h_buffers(count,U32.inc(index),acc ++ p111q_local(p112f_name(p114h_prefix(index),"scratch")) ++ " =l alloc8 2048\n"))

@unsafe
def p114h_dispatch(cases: List<&2,P114HCase>, +index: U32, +ids: N111Ids, acc: String) -> String:
  match cases:
    case Nil{}: acc ++ "%p114h_bad =l call $p111_rt_fail(l %state, w 4)\nret %p114h_bad\n"
    case Con{P114HCase{name,captures,result,pop,body},rest}:
      p114h_dispatch(rest,U32.inc(index),ids,acc ++ "%p114h_test_" ++ U32.show(index) ++
        " =w ceql %p114h_fid, " ++ p111q_value(N111FuncId{name},ids) ++ "\njnz %p114h_test_" ++ U32.show(index) ++
        ", @p114h_case_" ++ U32.show(index) ++ ", @p114h_next_" ++ U32.show(index) ++ "\n@p114h_next_" ++ U32.show(index) ++ "\n")

@unsafe
def p114h_restore(captures: List<&2,String>, +index: U32, +prefix: String, acc: String) -> String:
  match captures:
    case Nil{}: acc
    case Con{name,rest}: p114h_restore(rest,U32.inc(index),prefix,acc ++ p111q_local(p112f_name(prefix,name)) ++
      " =l call $p111_rt_stack_get(l %state, w " ++ U32.show(index) ++ ")\n")

@unsafe
def p114h_pop_text(+pop: String, +prefix: String) -> String:
  nt_choose(String,String.is_empty(pop),u => "",u => p111q_local(p112f_name(prefix,pop)) ++ " =l copy 0\n")

@unsafe
def p114h_case_prefix(+captures: List<&2,String>, result: String, pop: String, +index: U32) -> String:
  +count = nt_count(String,captures)
  "@p114h_case_" ++ U32.show(index) ++ "\n" ++
    nt_choose(String,U32.is_eq(count,0),u => "",u => "%p114h_popped =l call $p111_rt_stack_pop(l %state, w " ++ U32.show(count) ++ ")\n") ++
    p114h_pop_text(pop,p114h_prefix(index)) ++ p114h_restore(captures,0,p114h_prefix(index),"") ++
    p111q_local(p112f_name(p114h_prefix(index),result)) ++ " =l copy %p114r_value\n"

@unsafe
def p114h_cases(cases: List<&2,P114HCase>, +index: U32, +params: List<&2,String>, +ids: N111Ids, code: P111QCode) -> P111QCode:
  match cases code:
    case Nil{} _: code
    case Con{P114HCase{name,captures,result,pop,body},rest} P111QCode{chunks,n,terminal,error}:
      p114h_cases(rest,U32.inc(index),params,ids,p114h_terminal(p114h_stmts(p114h_rename(body,p114h_prefix(index)),params,
        p112f_name(p114h_prefix(index),"scratch"),ids,
        P111QCode{Con{p114h_case_prefix(captures,result,pop,index),chunks},n,False{},error})))

@unsafe
def p114h_unwind(+cases: List<&2,P114HCase>, +params: List<&2,String>, +ids: N111Ids, code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,n,terminal,error}:
      p114h_cases(cases,0,params,ids,P111QCode{Con{
        "@p114r_unwind\n%p114r_pending =w cnel %p114r_depth, 0\njnz %p114r_pending, @p114h_dispatch, @p114h_done\n@p114h_done\nret %p114r_value\n@p114h_dispatch\n%p114r_depth =l sub %p114r_depth, 1\n%p114h_popped =l call $p111_rt_stack_pop(l %state, w 1)\n%p114h_fid =l call $p111_rt_stack_get(l %state, w 0)\n" ++
        p114h_dispatch(cases,0,ids,""),chunks},n,True{},error})

@unsafe
def p114h_private(+name: String, +ids: N111Ids, plan: P114HPlan) -> String:
  match plan:
    case P114HPlan{valid,+params,body,+cases}:
      "function l $" ++ p114r_symbol(name) ++ "(" ++ p112w_formals(params,"l %state") ++ ") {\n@entry\n" ++
        p111q_body_text(p114h_unwind(cases,params,ids,p114h_terminal(p114h_stmts(body,params,"scratch",ids,
          P111QCode{["%v_scratch =l alloc8 2048\n" ++ p114h_buffers(nt_count(P114HCase,cases),0,"") ++
            "%p114r_depth =l copy 0\njmp @p114r_descend\n@p114r_descend\n"],0,False{},""})))) ++ "}\n"
