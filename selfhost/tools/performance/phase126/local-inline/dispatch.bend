# Exact local dispatch, with a compact immutable table catalogue threaded
# through its context. Only the ordinary direct-call emission is replaced.
@unsafe
def p126i_stmts(body: List<&2,P113DStmt>, +ctx: P126ICtx, +facts: List<&2,P114FLFact>, +code: P111QCode) -> P111QCode:
  match body code:
    case Nil{} _: code
    case Con{+head,+rest} P111QCode{chunks,site,terminal,+error}:
      nt_choose(P111QCode,Bool.not(String.is_empty(error)),u => code,u =>
        nt_choose(P111QCode,terminal,u => p111q_problem("typed statement after transfer",code),
          u => p126i_dispatch(head,rest,ctx,facts,code,p114so_group(Con{head,rest}))))


@unsafe
def p126i_dispatch(+head: P113DStmt, +rest: List<&2,P113DStmt>, +ctx: P126ICtx, +facts: List<&2,P114FLFact>, +code: P111QCode, group: P114SOGroup) -> P111QCode:
  match ctx code group:
    case P126ICtx{params,+buffers,+ids,tables} P111QCode{chunks,+site,terminal,error} P114SOYes{buffer,+name,+id,+left,+right,+more}:
      nt_choose(P111QCode,p114so_member(buffers,buffer) && p114so_room(code),
        u => p126i_stmts(more,ctx,p114fl_result(facts,name,id,site),p114fl_emit(id,name,left,right,facts,ids,code)),
        u => p126i_other(head,rest,ctx,facts,code))
    case _ _ _: p126i_other(head,rest,ctx,facts,code)


@unsafe
def p126i_other(+head: P113DStmt, +rest: List<&2,P113DStmt>, +ctx: P126ICtx, +facts: List<&2,P114FLFact>, +code: P111QCode) -> P111QCode:
  match head ctx:
    case P113DIf{condition,+yes,+no} _:
      p126i_stmts(rest,ctx,p126l_kill(no,p126l_kill(yes,facts)),p126i_if(condition,yes,no,ctx,facts,code))
    case P113DCall{+destinations,target,values} P126ICtx{params,buffers,ids,tables}:
      p126i_stmts(rest,ctx,p126l_forget(destinations,facts),p126i_call(destinations,target,values,tables,ids,code))
    case P113DAgain{values} P126ICtx{+params,buffers,ids,tables}:
      p126l_moves(params,0,p126l_snapshot(params,values,ids,0,code))
    case P113DScalar{scalar} _:
      p126i_width(head,rest,ctx,facts,code)
    case P113DResult{values} P126ICtx{params,buffers,ids,tables}: p113e_result_emit(values,ids,code)


@unsafe
def p126i_width(+head: P113DStmt, +rest: List<&2,P113DStmt>, +ctx: P126ICtx, +facts: List<&2,P114FLFact>, +code: P111QCode) -> P111QCode:
  match rest ctx:
    case Con{+second,+more} P126ICtx{params,buffers,+ids,tables}:
      nt_choose(P111QCode,p113w_pair(head,second) && p113w_room(code),
        u => p126i_stmts(more,ctx,p126l_kill([head,second],facts),p113w_pair_emit(head,ids,code)),
        u => p126i_width_one(head,rest,ctx,facts,code))
    case _ _: p126i_width_one(head,rest,ctx,facts,code)


@unsafe
def p126i_width_one(head: P113DStmt, +rest: List<&2,P113DStmt>, +ctx: P126ICtx, +facts: List<&2,P114FLFact>, +code: P111QCode) -> P111QCode:
  match head ctx:
    case P113DScalar{+scalar} P126ICtx{params,buffers,ids,tables}:
      p126i_stmts(rest,ctx,p126l_scalar_facts(scalar,facts),p113w_one(P113DScalar{scalar},params,ids,code))
    case _ _: p111q_problem("typed width source is not scalar",code)


@unsafe
def p126i_if(+condition: N111Value, +yes: List<&2,P113DStmt>, +no: List<&2,P113DStmt>, +ctx: P126ICtx, +facts: List<&2,P114FLFact>, +code: P111QCode) -> P111QCode:
  match ctx:
    case P126ICtx{params,buffers,+ids,tables}:
      +diamond = p113bq_direct(yes,no)
      nt_choose(P111QCode,p113bq_ready(diamond,code),u => p113bq_emit(condition,diamond,ids,code),
        u => p126i_if_original(condition,yes,no,ctx,facts,code))


@unsafe
def p126i_if_original(+condition: N111Value, +yes: List<&2,P113DStmt>, +no: List<&2,P113DStmt>, +ctx: P126ICtx, +facts: List<&2,P114FLFact>, code: P111QCode) -> P111QCode:
  match ctx code:
    case P126ICtx{params,buffers,ids,tables} P111QCode{chunks,+site,terminal,error}:
      p126i_if_yes(site,no,ctx,facts,p126i_stmts(yes,ctx,facts,P111QCode{
        Con{p111q_label(site) ++ "\n",Con{"jnz " ++ p111q_value(condition,ids) ++ ", " ++ p111q_label(site) ++ ", " ++ p111q_label(U32.inc(site)) ++ "\n",chunks}},U32.add(site,3),False{},error}))


@unsafe
def p126i_if_yes(+label: U32, +no: List<&2,P113DStmt>, +ctx: P126ICtx, +facts: List<&2,P114FLFact>, yes: P111QCode) -> P111QCode:
  match yes:
    case P111QCode{chunks,next,+terminal,error}:
      +prefix = nt_choose(List<&2,String>,terminal,u => chunks,u => Con{"jmp " ++ p111q_label(U32.add(label,2)) ++ "\n",chunks})
      p111q_if_done(label,terminal,p126i_stmts(no,ctx,facts,P111QCode{Con{p111q_label(U32.inc(label)) ++ "\n",prefix},next,False{},error}))
