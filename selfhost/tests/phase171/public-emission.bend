# Fuse p112w_public with p112w_stmts([],True,...), preserving all selection and
# emitter operations. No List<P112WorkerStmt> is built on this public path.
# Original planners, private workers, verification and non-public APIs remain.

@unsafe
def p171pe_call(+target: String, +arity: U32, +code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,n,terminal,error}:
      nt_choose(P111QCode,String.is_empty(error),u =>
        nt_choose(P111QCode,terminal,u => p111q_problem("statement follows private worker transfer",code),
          u => p112w_call(target,arity,True{},code)),u => code)

@unsafe
def p171pe_tail_step(+stmt: N111Stmt, +rest: List<&2,N111Stmt>, +left: U32,
    +target: String, +arity: U32, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,n,terminal,error}:
      nt_choose(P111QCode,String.is_empty(error),u =>
        nt_choose(P111QCode,terminal,u => p111q_problem("statement follows private worker transfer",code),
          u => p171pe_tail(rest,U32.sub(left,1),target,arity,ids,p111q_stmt(stmt,ids,code))),u => code)

@unsafe
def p171pe_tail(body,left,target,arity,ids,code):
  match body left:
    case _ 0: p171pe_call(target,arity,code)
    case Con{stmt,rest} _: p171pe_tail_step(stmt,rest,left,target,arity,ids,code)
    case _ _: code

@unsafe
def p171pe_if_yes(+label: U32, +no: List<&2,N111Stmt>, +owner: String,
    +ready: KDef, +ids: N111Ids, yes: P111QCode) -> P111QCode:
  match yes:
    case P111QCode{chunks,n,terminal,error}:
      +prefix = nt_choose(List<&2,String>,terminal,u => chunks,u => Con{"jmp " ++ p111q_label(U32.add(label,2)) ++ "\n",chunks})
      p111q_if_done(label,terminal,p171pe_stmts(no,owner,ready,ids,
        P111QCode{Con{p111q_label(U32.inc(label)) ++ "\n",prefix},n,False{},error}))

@unsafe
def p171pe_if(+condition: N111Value, +yes: List<&2,N111Stmt>, +no: List<&2,N111Stmt>,
    +owner: String, +ready: KDef, +ids: N111Ids, code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,n,terminal,error}:
      p171pe_if_yes(n,no,owner,ready,ids,p171pe_stmts(yes,owner,ready,ids,
        P111QCode{Con{p111q_label(n) ++ "\n",Con{"jnz " ++ p111q_value(condition,ids) ++ ", " ++ p111q_label(n) ++ ", " ++ p111q_label(U32.inc(n)) ++ "\n",chunks}},U32.add(n,3),False{},error}))

@unsafe
def p171pe_next(body: List<&2,N111Stmt>, +owner: String, +ready: KDef,
    +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match body:
    case Nil{}: code
    case Con{N111If{condition,yes,no},rest}:
      p171pe_stmts(rest,owner,ready,ids,p171pe_if(condition,yes,no,owner,ready,ids,code))
    case Con{stmt,rest}: p171pe_stmts(rest,owner,ready,ids,p111q_stmt(stmt,ids,code))

@unsafe
def p171pe_target(+body: List<&2,N111Stmt>, +owner: String, +ready: KDef,
    +ids: N111Ids, +code: P111QCode, +target: String) -> P111QCode:
  +count = da(p111v_get(ready,target))
  nt_choose(P111QCode,p112w_ready(ready,target) && Bool.not(String.eq(owner,target)) && p112t_tail(body,target,count,0),
    u => p171pe_tail(body,count,target,count,ids,code),u => p171pe_next(body,owner,ready,ids,code))

@unsafe
def p171pe_state(+body: List<&2,N111Stmt>, +owner: String, +ready: KDef,
    +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,n,terminal,error}:
      nt_choose(P111QCode,String.is_empty(error),u =>
        nt_choose(P111QCode,terminal,u => p111q_problem("statement follows private worker transfer",code),
          u => p171pe_target(body,owner,ready,ids,code,p112w_target(body))),u => code)

@unsafe
def p171pe_stmts(body,owner,ready,ids,code):
  match body:
    case Nil{}: code
    case Con{head,rest}: p171pe_state(body,owner,ready,ids,code)

@unsafe
def p112w_public_segment(+segment: N111Segment, +ids: N111Ids, +ready: KDef) -> String:
  match segment:
    case N111Segment{+name,arity,+result,incoming,+flags,+body}:
      nt_choose(String,p112t_admitted(p112t_plan(segment)),u => p112q_segment(segment,ids),u =>
        nt_choose(String,U32.is_eq(result,1) && U32.is_eq(flags,0),
          u => "export function l $" ++ p111q_symbol(name) ++ "(l %state) {\n@entry\n" ++
            p144e_body_tail(p171pe_stmts(body,name,ready,ids,
              P111QCode{p111q_allocas(body,[]),0,False{},""}),"}\n"),
          u => p111q_segment(segment,ids)))
