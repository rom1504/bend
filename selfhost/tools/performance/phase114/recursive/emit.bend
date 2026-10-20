# Only the exact derived plan reaches this emitter. The original independent
# whole-program verifier remains before public emission. No new runtime ABI.
@unsafe
def p114r_symbol(name: String) -> String:
  "p114r_" ++ nt_fid(name)

def p114r_jump(label: String, code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,n,terminal,error}: P111QCode{Con{"jmp " ++ label ++ "\n",chunks},n,True{},error}

@unsafe
def p114r_again(+arguments: List<&2,N111Stmt>, +params: List<&2,String>, +ids: N111Ids, code: P111QCode) -> P111QCode:
  p114r_moves(params,0,p112q_snapshots(nt_count(String,params),0,p111q_stmts(arguments,ids,code)))

@unsafe
def p114r_moves(params: List<&2,String>, +index: U32, code: P111QCode) -> P111QCode:
  match params:
    case Nil{}: p114r_jump("@p114r_descend",code)
    case Con{name,rest}: p114r_moves(rest,U32.inc(index),
      p111q_line(p111q_local(name) ++ " =l copy %p112_arg_" ++ U32.show(index) ++ "\n",code))

@unsafe
def p114r_stmts(body: List<&2,P114RStmt>, +params: List<&2,String>, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match body code:
    case Nil{} _: code
    case Con{stmt,rest} P111QCode{chunks,n,terminal,+error}:
      nt_choose(P111QCode,Bool.not(String.is_empty(error)),u => code,u =>
        nt_choose(P111QCode,terminal,u => p111q_problem("statement after recursive transfer",code),
          u => p114r_stmts(rest,params,ids,p114r_stmt(stmt,params,ids,code))))

@unsafe
def p114r_stmt(stmt: P114RStmt, +params: List<&2,String>, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match stmt:
    case P114RScalar{scalar}: p111q_stmt(scalar,ids,code)
    case P114RIf{condition,yes,no}: p114r_if(condition,yes,no,params,ids,code)
    case P114RDescend{frame,arguments}:
      p114r_again(arguments,params,ids,p111q_line("%p114r_depth =l add %p114r_depth, 1\n",p111q_stmts(frame,ids,code)))
    case P114RAgain{arguments}: p114r_again(arguments,params,ids,code)
    case P114RResult{value}:
      p114r_jump("@p114r_unwind",p111q_line("%p114r_value =l copy " ++ p111q_value(value,ids) ++ "\n",code))
    case P114RFailure{body}: p111q_stmts(body,ids,code)

@unsafe
def p114r_if(+condition: N111Value, +yes: List<&2,P114RStmt>, +no: List<&2,P114RStmt>,
    +params: List<&2,String>, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  +diamond = p114r_diamond(yes,no)
  nt_choose(P111QCode,p113bq_ready(diamond,code),
    u => p113bq_emit(condition,diamond,ids,code),
    u => p114r_if_original(condition,yes,no,params,ids,code))

def p114r_diamond(yes: List<&2,P114RStmt>, no: List<&2,P114RStmt>) -> P113BQDiamond:
  match yes no:
    case Con{P114RScalar{a},Nil{}} Con{P114RScalar{b},Nil{}}: p113bq_scalar([a],[b])
    case _ _: P113BQNo{}

@unsafe
def p114r_if_original(+condition: N111Value, +yes: List<&2,P114RStmt>, +no: List<&2,P114RStmt>,
    +params: List<&2,String>, +ids: N111Ids, code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,n,terminal,error}:
      p114r_if_yes(n,no,params,ids,p114r_stmts(yes,params,ids,
        P111QCode{Con{p111q_label(n) ++ "\n",Con{"jnz " ++ p111q_value(condition,ids) ++ ", " ++ p111q_label(n) ++ ", " ++ p111q_label(U32.inc(n)) ++ "\n",chunks}},U32.add(n,3),False{},error}))

@unsafe
def p114r_if_yes(+label: U32, +no: List<&2,P114RStmt>, +params: List<&2,String>, +ids: N111Ids, yes: P111QCode) -> P111QCode:
  match yes:
    case P111QCode{+chunks,n,terminal,error}:
      +prefix = nt_choose(List<&2,String>,terminal,u => chunks,u => Con{"jmp " ++ p111q_label(U32.add(label,2)) ++ "\n",chunks})
      p111q_if_done(label,terminal,p114r_stmts(no,params,ids,
        P111QCode{Con{p111q_label(U32.inc(label)) ++ "\n",prefix},n,False{},error}))

def p114r_drop(body: List<&2,N111Stmt>, count: U32) -> List<&2,N111Stmt>:
  match body count:
    case _ 0: body
    case Con{stmt,rest} _: p114r_drop(rest,U32.sub(count,1))
    case _ _: []

# Frame stored [head,FID]. The original rt_return would pop FID, followed by
# the continuation's pop1. Pop2 performs both before stack_get0. The depth
# guard ensures no caller frame is touched. No rn/next/register state is read.
@unsafe
def p114r_unwind(+head: String, +result: String, +body: List<&2,N111Stmt>, +ids: N111Ids, code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,n,terminal,error}:
      +prefix = "@p114r_unwind\n%p114r_pending =w cnel %p114r_depth, 0\njnz %p114r_pending, @p114r_resume, @p114r_done\n@p114r_resume\n%p114r_depth =l sub %p114r_depth, 1\n%p114r_popped =l call $p111_rt_stack_pop(l %state, w 2)\n" ++
        p111q_local(p112f_name("p114r_resume_",head)) ++ " =l call $p111_rt_stack_get(l %state, w 0)\n" ++
        p111q_local(p112f_name("p114r_resume_",result)) ++ " =l copy %p114r_value\n"
      +resumed = p111q_stmts(p112f_rename(p114r_prefix(body,3),"p114r_resume_"),ids,
        P111QCode{Con{prefix,chunks},n,False{},error})
      +value = p112f_value(p114r_result_word(p114r_drop(body,3)),"p114r_resume_")
      p114r_finish_code(p114r_jump("@p114r_unwind",p111q_line("%p114r_value =l copy " ++ p111q_value(value,ids) ++ "\n",resumed)))

def p114r_finish_code(code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,n,terminal,error}:
      P111QCode{Con{"@p114r_done\nret %p114r_value\n",chunks},n,True{},error}

@unsafe
def p114r_private(+name: String, +ids: N111Ids, plan: P114RPlan) -> String:
  match plan:
    case P114RPlan{valid,+params,body,continuation,head,result,unwind}:
      "function l $" ++ p114r_symbol(name) ++ "(" ++ p112w_formals(params,"l %state") ++ ") {\n@entry\n" ++
      p111q_body_text(p114r_unwind(head,result,unwind,ids,p114r_stmts(body,params,ids,
        P111QCode{["%v_scratch =l alloc8 2048\n%v_p114r_resume_local_scratch =l alloc8 2048\n%p114r_depth =l copy 0\njmp @p114r_descend\n@p114r_descend\n"],0,False{},""}))) ++ "}\n"

@unsafe
def p114r_public(+name: String, +arity: U32) -> String:
  "export function l $" ++ p111q_symbol(name) ++ "(l %state) {\n@entry\n%p114r_outer_out =l alloc8 8\n" ++
    p113e_public_loads(arity,0,"") ++ "%p114r_outer_value =l call $" ++ p114r_symbol(name) ++ "(" ++ p113e_public_args(arity,0,"l %state") ++ ")\n" ++
    "storel %p114r_outer_value, %p114r_outer_out\n%p114r_outer_reply =l call $p111_rt_return(l %state, l %p114r_outer_out, w 1)\nret %p114r_outer_reply\n}\n"
