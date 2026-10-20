# Same operation/casts as the selected p112fp emitter, with explicit operands.
@unsafe
def p114so_text(+id: U32, +name: String, left: N111Value, +right: N111Value, +ids: N111Ids, +n: U32) -> String:
  +a = p111q_tmp(n)
  +af = p111q_tmp(U32.add(n,1))
  +b = p111q_tmp(U32.add(n,2))
  +bf = p111q_tmp(U32.add(n,3))
  +out = p111q_tmp(U32.add(n,4))
  +bits = p111q_tmp(U32.add(n,5))
  +prefix = a ++ " =w copy " ++ p111q_value(left,ids) ++ "\n"
  nt_choose(String,U32.is_eq(id,23),
    u => prefix ++ out ++ " =s uwtof " ++ a ++ "\n" ++ bits ++ " =w cast " ++ out ++ "\n" ++ p111q_local(name) ++ " =l extuw " ++ bits ++ "\n",
    u => prefix ++ af ++ " =s cast " ++ a ++ "\n" ++ b ++ " =w copy " ++ p111q_value(right,ids) ++ "\n" ++ bf ++ " =s cast " ++ b ++ "\n" ++
      nt_choose(String,U32.is_lt(id,30),
        v => out ++ " =s " ++ p112fp_binary(id) ++ " " ++ af ++ ", " ++ bf ++ "\n" ++ bits ++ " =w cast " ++ out ++ "\n" ++ p111q_local(name) ++ " =l extuw " ++ bits ++ "\n",
        v => out ++ " =w " ++ p112fp_binary(id) ++ " " ++ af ++ ", " ++ bf ++ "\n" ++ p111q_local(name) ++ " =l extuw " ++ out ++ "\n"))

@unsafe
def p114so_emit(id: U32, name: String, left: N111Value, right: N111Value, ids: N111Ids, code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,+n,terminal,error}:
      P111QCode{Con{p114so_text(id,name,left,right,ids,n),chunks},U32.add(n,9),terminal,error}

@unsafe
def p114so_room(code: P111QCode) -> Bool:
  match code:
    case P111QCode{chunks,next,terminal,error}: U32.is_le(next,4294967286)

# Whole-function buffers are passed only from the private-function entry.
# Nonmatching statements retain the selected word-width/Boolean emitters.
@unsafe
def p114so_stmts(body: List<&2,P113DStmt>, +buffers: List<&2,String>, +params: List<&2,NC_Binding>, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match body code:
    case Nil{} _: code
    case Con{+head,+rest} P111QCode{chunks,n,terminal,+error}:
      nt_choose(P111QCode,Bool.not(String.is_empty(error)),u => code,u =>
        nt_choose(P111QCode,terminal,u => p111q_problem("statement follows direct transfer",code),
          u => p114so_dispatch(head,rest,buffers,params,ids,code,p114so_group(Con{head,rest}))))

@unsafe
def p114so_dispatch(+head: P113DStmt, +rest: List<&2,P113DStmt>, +buffers: List<&2,String>, +params: List<&2,NC_Binding>, +ids: N111Ids, +code: P111QCode, group: P114SOGroup) -> P111QCode:
  match group:
    case P114SOYes{buffer,name,id,left,right,more}:
      nt_choose(P111QCode,p114so_member(buffers,buffer) && p114so_room(code),
        u => p114so_stmts(more,buffers,params,ids,p114so_emit(id,name,left,right,ids,code)),
        u => p114so_old(head,rest,buffers,params,ids,code))
    case P114SONo{}: p114so_old(head,rest,buffers,params,ids,code)

@unsafe
def p114so_old(+head: P113DStmt, rest: List<&2,P113DStmt>, +buffers: List<&2,String>, +params: List<&2,NC_Binding>, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match rest:
    case Con{+second,+more}:
      nt_choose(P111QCode,p113w_pair(head,second) && p113w_room(code),
        u => p114so_stmts(more,buffers,params,ids,p113w_pair_emit(head,ids,code)),
        u => p114so_stmts(Con{second,more},buffers,params,ids,p113w_one(head,params,ids,code)))
    case Nil{}: p113w_one(head,params,ids,code)

# This first slice does not rewrite nested branch rendering. The original
# p113e_if and every selected public/runtime/recursive hook stay untouched.
@unsafe
def p114so_private(function: P113DFunction, +ids: N111Ids) -> String:
  match function:
    case P113DFunction{name,+params,+result,public,+body}:
      +buffers = p114so_buffers(body)
      +allocas = p113e_allocas(body,["%v_scratch =l alloc8 2048\n"])
      +allocas = nt_choose(List<&2,String>,p113e_multi(body),u => Con{"%p113_results =l alloc8 64\n",allocas},u => allocas)
      "function l $" ++ p113e_symbol(name) ++ "(" ++ p113e_formals(params,nt_choose(String,U32.is_eq(result,1),u => "l %state",u => "l %state, l %p113_result_out")) ++ ") {\n@entry\n" ++
        p111q_body_text(p114so_stmts(body,buffers,params,ids,P111QCode{Con{"@p113_loop\n",Con{"jmp @p113_loop\n",allocas}},0,False{},""})) ++ "}\n"
