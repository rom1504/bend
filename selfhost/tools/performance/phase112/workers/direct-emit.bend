# Private calls return one owning Term. They never return Reply or change the
# dispatcher/continuation state. Public conversion retains rt_return exactly.
@unsafe
def p112w_symbol(name: String) -> String:
  "p112w_" ++ nt_fid(name)

@unsafe
def p112w_formals(params: List<&2,String>, acc: String) -> String:
  match params:
    case Nil{}: acc
    case Con{word,rest}: p112w_formals(rest,acc ++ ", l " ++ p111q_local(word))

@unsafe
def p112w_call_args(+count: U32, +index: U32, +acc: String) -> String:
  nt_choose(String,U32.is_eq(count,index),u => acc,u =>
    p112w_call_args(count,U32.inc(index),acc ++ ", l %p112_arg_" ++ U32.show(index)))

@unsafe
def p112w_call(+target: String, +arity: U32, +public: Bool, +code: P111QCode) -> P111QCode:
  p112w_call_finish(public,p111q_line("%p112_result =l call $" ++ p112w_symbol(target) ++
    "(" ++ p112w_call_args(arity,0,"l %state") ++ ")\n",p112q_snapshots(arity,0,code)))

@unsafe
def p112w_call_finish(+public: Bool, +code: P111QCode) -> P111QCode:
  nt_choose(P111QCode,public,
    u => p111q_return("%p112_reply",p111q_line("%p112_reply =l call $p111_rt_return(l %state, l %v_scratch, w 1)\n",
      p111q_line("storel %p112_result, %v_scratch\n",code))),
    u => p111q_return("%p112_result",code))

@unsafe
def p112w_stmts(body: List<&2,P112WorkerStmt>, +params: List<&2,String>, +public: Bool, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match body:
    case Nil{}: code
    case Con{stmt,rest}: p112w_stmts_head(stmt,rest,params,public,ids,code)

@unsafe
def p112w_stmts_head(+stmt: P112WorkerStmt, +rest: List<&2,P112WorkerStmt>, +params: List<&2,String>,
  +public: Bool, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,n,terminal,error}:
      nt_choose(P111QCode,Bool.not(String.is_empty(error)),u => code,u =>
        nt_choose(P111QCode,terminal,u => p111q_problem("statement follows private worker transfer",code),u =>
          p112w_stmts(rest,params,public,ids,p112w_stmt(stmt,params,public,ids,code))))

@unsafe
def p112w_stmt(stmt: P112WorkerStmt, +params: List<&2,String>, +public: Bool, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match stmt:
    case P112WorkerScalar{scalar}: p111q_stmt(scalar,ids,code)
    case P112WorkerAgain{}: p112q_moves(params,0,p112q_snapshots(nt_count(String,params),0,code))
    case P112WorkerResult{}: p111q_return("%p112_result",p111q_line("%p112_result =l loadl %v_scratch\n",code))
    case P112WorkerCall{target,arity}: p112w_call(target,arity,public,code)
    case P112WorkerIf{condition,yes,no}: p112w_if(condition,yes,no,params,public,ids,code)

@unsafe
def p112w_if(+condition: N111Value, +yes: List<&2,P112WorkerStmt>, +no: List<&2,P112WorkerStmt>,
  +params: List<&2,String>, +public: Bool, +ids: N111Ids, code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,n,terminal,error}:
      p112w_if_yes(n,no,params,public,ids,p112w_stmts(yes,params,public,ids,
        P111QCode{Con{p111q_label(n) ++ "\n",Con{"jnz " ++ p111q_value(condition,ids) ++ ", " ++ p111q_label(n) ++ ", " ++ p111q_label(U32.inc(n)) ++ "\n",chunks}},U32.add(n,3),False{},error}))

@unsafe
def p112w_if_yes(+label: U32, +no: List<&2,P112WorkerStmt>, +params: List<&2,String>, +public: Bool, +ids: N111Ids, yes: P111QCode) -> P111QCode:
  match yes:
    case P111QCode{chunks,n,terminal,error}:
      +prefix = nt_choose(List<&2,String>,terminal,u => chunks,u => Con{"jmp " ++ p111q_label(U32.add(label,2)) ++ "\n",chunks})
      p111q_if_done(label,terminal,p112w_stmts(no,params,public,ids,P111QCode{Con{p111q_label(U32.inc(label)) ++ "\n",prefix},n,False{},error}))

@unsafe
def p112w_private(+segment: N111Segment, +ids: N111Ids, plan: P112WorkerPlan) -> String:
  match segment plan:
    case N111Segment{name,arity,result,incoming,flags,+original} P112WorkerPlan{+valid,calls,+params,+body}:
      nt_choose(String,valid,u => "function l $" ++ p112w_symbol(name) ++ "(" ++ p112w_formals(params,"l %state") ++ ") {\n@entry\n" ++
        p111q_body_text(p112w_stmts(body,params,False{},ids,
          P111QCode{Con{"@p112_again\n",Con{"jmp @p112_again\n",p111q_allocas(original,[])}},0,False{},""})) ++ "}\n",
        u => "INVALID_P112_PRIVATE_PLAN\n")

@unsafe
def p112w_public_segment(+segment: N111Segment, +ids: N111Ids, +ready: KDef) -> String:
  match segment:
    case N111Segment{+name,arity,+result,incoming,+flags,+body}:
      nt_choose(String,p112t_admitted(p112t_plan(segment)),u => p112q_segment(segment,ids),u =>
        nt_choose(String,U32.is_eq(result,1) && U32.is_eq(flags,0),
          u => "export function l $" ++ p111q_symbol(name) ++ "(l %state) {\n@entry\n" ++
            p111q_body_text(p112w_stmts(p112w_public(body,name,ready),[],True{},ids,
              P111QCode{p111q_allocas(body,[]),0,False{},""})) ++ "}\n",
          u => p111q_segment(segment,ids)))

@unsafe
def p112w_chunk(+segment: N111Segment, +ids: N111Ids, +ready: KDef, +targets: KDef) -> String:
  match segment:
    case N111Segment{+name,arity,result,incoming,flags,body}:
      p112w_public_segment(segment,ids,ready) ++ nt_choose(String,p112w_ready(targets,name),
        u => p112w_private(segment,ids,p112w_plan(segment,ready)),u => "")

@unsafe
def p112w_chunks(segments: List<&2,N111Segment>, +ids: N111Ids, +ready: KDef, +targets: KDef, acc: List<&2,String>) -> List<&2,String>:
  match segments:
    case Nil{}: nt_reverse(String,acc,[])
    case Con{segment,rest}: p112w_chunks(rest,ids,ready,targets,Con{p112w_chunk(segment,ids,ready,targets),acc})

@unsafe
def p112w_indexed(+segments: List<&2,N111Segment>, +ids: N111Ids, +ready: KDef, +acc: List<&2,String>) -> List<&2,String>:
  p112w_chunks(segments,ids,ready,p112w_targets(segments,ready,missing()),acc)

@unsafe
def p112w_segment_chunks(+segments: List<&2,N111Segment>, +ids: N111Ids, +acc: List<&2,String>) -> List<&2,String>:
  p112w_indexed(segments,ids,p112w_index(segments),acc)
