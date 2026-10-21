# Optional Phase124 ablation. Only selected H-plan frame lists pass through this
# hook; the global p114t_buffer predicate and original verifiers stay unchanged.

@unsafe
def p124f_case_buffer(+name: String, +index: U32) -> Bool:
  nt_choose(Bool,U32.is_eq(index,8),u => False{},u =>
    nt_choose(Bool,String.eq(name,p112f_name(p114h_prefix(index),"scratch")),
      v => True{},v => p124f_case_buffer(name,U32.inc(index))))

@unsafe
def p124f_expand(+stmt: N111Stmt, +expected: String, +ids: N111Ids, +site: U32) -> P114TExpansion:
  match stmt:
    case N111Call{+dest,N111U64{},+symbol,
      Con{N111Arg{N111Ptr{},N111Local{+state}},
      Con{N111Arg{N111U32{},N111FuncId{+fid}},
      Con{N111Arg{N111Ptr{},N111Local{+buffer}},
      Con{N111Arg{N111U32{},N111Const{+count,+high}},Nil{}}}}}}:
        nt_choose(P114TExpansion,String.eq(symbol,"p111_rt_frame") && String.eq(state,"state") &&
          String.eq(buffer,expected) && p124f_case_buffer(buffer,0) && U32.is_eq(high,0) &&
          U32.is_le(count,8) && p114t_known_fid(fid,ids),
          u => P114TExpansion{p114t_frame(dest,fid,buffer,count,site),True{}},
          u => P114TExpansion{[stmt],False{}})
    case _: P114TExpansion{[stmt],False{}}

@unsafe
def p124f_render(+stmt: N111Stmt, +ids: N111Ids, +code: P111QCode, expansion: P114TExpansion) -> P111QCode:
  match expansion:
    case P114TExpansion{+body,changed}:
      nt_choose(P111QCode,changed,u => p114t_expanded(P114TExpansion{body,True{}},ids,code),
        u => p111q_stmt(stmt,ids,code))

@unsafe
def p124f_stmts(body: List<&2,N111Stmt>, +buffer: String, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match body code:
    case Nil{} _: code
    case Con{+stmt,+rest} P111QCode{chunks,+next,terminal,+error}:
      nt_choose(P111QCode,Bool.not(String.is_empty(error)),u => code,u =>
        nt_choose(P111QCode,terminal,u => p111q_problem("statement after table-frame transfer",code),
          u => p124f_stmts(rest,buffer,ids,p124f_render(stmt,ids,code,p124f_expand(stmt,buffer,ids,next)))))

@unsafe
def p114h_stmt(+stmt: P114RStmt, +params: List<&2,String>, +buffer: String, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match stmt:
    case P114RIf{condition,yes,no}: p114h_if(condition,yes,no,params,buffer,ids,code)
    case P114RDescend{frame,arguments}:
      p114h_again(arguments,params,buffer,ids,p111q_line("%p114r_depth =l add %p114r_depth, 1\n",p124f_stmts(frame,buffer,ids,code)))
    case P114RAgain{arguments}: p114h_again(arguments,params,buffer,ids,code)
    case P114RResumeReady{frame,call,result}:
      p114r_stmt(P114RResult{result},params,ids,p111q_stmts(call,ids,
        p111q_line("%p114r_depth =l add %p114r_depth, 1\n",p124f_stmts(frame,buffer,ids,code))))
    case _: p114r_stmt(stmt,params,ids,code)
