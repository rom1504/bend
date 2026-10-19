# Only private Again and branch traversal differ from the ordinary emitter.
# Scalar instructions still use p111q_stmt. Caller verifies original IR first.
@unsafe
def p112q_snapshots(+count: U32, +index: U32, +code: P111QCode) -> P111QCode:
  nt_choose(P111QCode,U32.is_eq(index,count),u => code,u =>
    p112q_snapshot(count,index,code))

@unsafe
def p112q_snapshot(+count: U32, +index: U32, code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,n,terminal,error}:
      p112q_snapshots(count,U32.inc(index),P111QCode{
        Con{"%p112_arg_" ++ U32.show(index) ++ " =l loadl %p112_at_" ++ U32.show(index) ++ "\n",
        Con{"%p112_at_" ++ U32.show(index) ++ " =l add %v_scratch, " ++ U32.show(U32.mul(index,8)) ++ "\n",chunks}},n,terminal,error})

@unsafe
def p112q_moves(params: List<&2,String>, +index: U32, +code: P111QCode) -> P111QCode:
  match params:
    case Nil{}: p112q_again(code)
    case Con{word,rest}:
      p112q_moves(rest,U32.inc(index),p111q_line(p111q_local(word) ++ " =l copy %p112_arg_" ++ U32.show(index) ++ "\n",code))

def p112q_again(code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,n,terminal,error}: P111QCode{Con{"jmp @p112_again\n",chunks},n,True{},error}

@unsafe
def p112q_stmts(body: List<&2,P112TailStmt>, +params: List<&2,String>, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match body:
    case Nil{}: code
    case Con{stmt,rest}: p112q_stmts_head(stmt,rest,params,ids,code)

@unsafe
def p112q_stmts_head(+stmt: P112TailStmt, +rest: List<&2,P112TailStmt>, +params: List<&2,String>,
  +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,n,terminal,error}:
      nt_choose(P111QCode,Bool.not(String.is_empty(error)),u => code,u =>
        nt_choose(P111QCode,terminal,u => p111q_problem("statement follows private loop transfer",code),u =>
          p112q_stmts(rest,params,ids,p112q_stmt(stmt,params,ids,code))))

@unsafe
def p112q_stmt(stmt: P112TailStmt, +params: List<&2,String>, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match stmt:
    case P112TailScalar{scalar}: p111q_stmt(scalar,ids,code)
    case P112TailAgain{}: p112q_moves(params,0,p112q_snapshots(nt_count(String,params),0,code))
    case P112TailIf{condition,yes,no}: p112q_if(condition,yes,no,params,ids,code)

@unsafe
def p112q_if(+condition: N111Value, +yes: List<&2,P112TailStmt>, +no: List<&2,P112TailStmt>,
  +params: List<&2,String>, +ids: N111Ids, code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,n,terminal,error}:
      p112q_if_yes(n,no,params,ids,p112q_stmts(yes,params,ids,
        P111QCode{Con{p111q_label(n) ++ "\n",Con{"jnz " ++ p111q_value(condition,ids) ++ ", " ++ p111q_label(n) ++ ", " ++ p111q_label(U32.inc(n)) ++ "\n",chunks}},U32.add(n,3),False{},error}))

@unsafe
def p112q_if_yes(+label: U32, +no: List<&2,P112TailStmt>, +params: List<&2,String>, +ids: N111Ids, yes: P111QCode) -> P111QCode:
  match yes:
    case P111QCode{chunks,n,terminal,error}:
      +prefix = nt_choose(List<&2,String>,terminal,u => chunks,u => Con{"jmp " ++ p111q_label(U32.add(label,2)) ++ "\n",chunks})
      p111q_if_done(label,terminal,p112q_stmts(no,params,ids,P111QCode{Con{p111q_label(U32.inc(label)) ++ "\n",prefix},n,False{},error}))

@unsafe
def p112q_loop_body(+body: List<&2,P112TailStmt>, +params: List<&2,String>, +ids: N111Ids, code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,n,terminal,error}:
      p112q_stmts(body,params,ids,P111QCode{Con{"@p112_again\n",Con{"jmp @p112_again\n",chunks}},n,False{},error})

@unsafe
def p112q_planned(+segment: N111Segment, +ids: N111Ids, plan: P112TailPlan) -> String:
  match segment plan:
    case N111Segment{+name,arity,result,incoming,flags,+original} P112TailPlan{valid,loops,+params,+prefix,+body}:
      nt_choose(String,valid,
        u => "export function l $" ++ p111q_symbol(name) ++ "(l %state) {\n@entry\n" ++
          p111q_body_text(p112q_loop_body(body,params,ids,
            p111q_stmts(prefix,ids,P111QCode{p111q_allocas(original,[]),0,False{},""}))) ++ "}\n",
        u => p111q_segment(segment,ids))

@unsafe
def p112q_segment(+segment: N111Segment, +ids: N111Ids) -> String:
  p112q_planned(segment,ids,p112t_plan(segment))

# Exact one-function override used by the source assembler. Public chunks,
# metadata tables, scalar emitter and mandatory verifier remain unchanged.
@unsafe
def p112q_segment_chunks(segments: List<&2,N111Segment>, +ids: N111Ids, acc: List<&2,String>) -> List<&2,String>:
  match segments:
    case Nil{}: nt_reverse(String,acc,[])
    case Con{segment,rest}: p112q_segment_chunks(rest,ids,Con{p112q_segment(segment,ids),acc})
