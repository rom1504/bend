# Retain only incoming immutable lane facts whose word name is not assigned in
# either arm. Never invent a join fact; all arm-created lanes remain local.
@unsafe
def p126t_kill_scalar(stmt: N111Stmt, +facts: List<&2,P114FLFact>) -> List<&2,P114FLFact>:
  match stmt:
    case N111Set{name,typ,value}: p114fl_remove(facts,name)
    case N111Bin{name,typ,op,a,b}: p114fl_remove(facts,name)
    case N111Call{name,typ,symbol,args}: p114fl_remove(facts,name)
    case N111Load{name,typ,base,offset}: p114fl_remove(facts,name)
    case N111Offset{name,base,bytes}: p114fl_remove(facts,name)
    case N111Alloca{name,bytes,align}: p114fl_remove(facts,name)
    case N111If{condition,yes,no}: p126t_kill_scalars(no,p126t_kill_scalars(yes,facts))
    case _: facts

@unsafe
def p126t_kill_scalars(body: List<&2,N111Stmt>, facts: List<&2,P114FLFact>) -> List<&2,P114FLFact>:
  match body:
    case Nil{}: facts
    case Con{head,rest}: p126t_kill_scalars(rest,p126t_kill_scalar(head,facts))

@unsafe
def p126t_kill(body: List<&2,P113DStmt>, +facts: List<&2,P114FLFact>) -> List<&2,P114FLFact>:
  match body:
    case Nil{}: facts
    case Con{P113DScalar{scalar},rest}: p126t_kill(rest,p126t_kill_scalar(scalar,facts))
    case Con{P113DIf{condition,yes,no},rest}: p126t_kill(rest,p126t_kill(no,p126t_kill(yes,facts)))
    case Con{P113DCall{names,target,args},rest}: p126t_kill(rest,p126t_forget(names,facts))
    case Con{P113DAgain{values},rest}: []
    case Con{P113DResult{values},rest}: facts

@unsafe
def p126t_scalar_facts(stmt: N111Stmt, +facts: List<&2,P114FLFact>) -> List<&2,P114FLFact>:
  match stmt:
    case N111Set{name,N111U64{},N111Local{source}}: p114fl_copy(facts,name,source)
    case _: p126t_kill_scalar(stmt,facts)

@unsafe
def p126t_other(+head: P113DStmt, +rest: List<&2,P113DStmt>, +ctx: P126TCtx, +facts: List<&2,P114FLFact>, +code: P111QCode) -> P111QCode:
  match head ctx:
    case P113DIf{condition,+yes,+no} _:
      p126t_stmts(rest,ctx,p126t_kill(no,p126t_kill(yes,facts)),p126t_if(condition,yes,no,ctx,facts,code))
    case P113DCall{+destinations,target,values} _:
      p126t_stmts(rest,ctx,p126t_forget(destinations,facts),p126t_call(destinations,target,values,ctx,facts,code))
    case P113DAgain{values} P126TCtx{+params,+floats,plans,buffers,ids}:
      p126t_moves(params,floats,0,p126t_snapshot(params,values,floats,facts,ids,0,code))
    case P113DScalar{scalar} _:
      p126t_width(head,rest,ctx,facts,code)
    case P113DResult{values} P126TCtx{params,floats,plans,buffers,ids}: p113e_result_emit(values,ids,code)

@unsafe
def p126t_width(+head: P113DStmt, +rest: List<&2,P113DStmt>, +ctx: P126TCtx, +facts: List<&2,P114FLFact>, +code: P111QCode) -> P111QCode:
  match rest ctx:
    case Con{+second,+more} P126TCtx{params,floats,plans,buffers,+ids}:
      nt_choose(P111QCode,p113w_pair(head,second) && p113w_room(code),
        u => p126t_stmts(more,ctx,p126t_kill([head,second],facts),p113w_pair_emit(head,ids,code)),
        u => p126t_width_one(head,rest,ctx,facts,code))
    case _ _: p126t_width_one(head,rest,ctx,facts,code)

@unsafe
def p126t_width_one(head: P113DStmt, +rest: List<&2,P113DStmt>, +ctx: P126TCtx, +facts: List<&2,P114FLFact>, +code: P111QCode) -> P111QCode:
  match head ctx:
    case P113DScalar{+scalar} P126TCtx{params,floats,plans,buffers,ids}:
      p126t_stmts(rest,ctx,p126t_scalar_facts(scalar,facts),p113w_one(P113DScalar{scalar},params,ids,code))
    case _ _: p111q_problem("typed width source is not scalar",code)

@unsafe
def p114fl_bind(+facts: List<&2,P114FLFact>, +word: String, +lane: String) -> List<&2,P114FLFact>:
  +remaining = p114fl_remove(facts,word)
  nt_choose(List<&2,P114FLFact>,String.is_empty(lane),u => remaining,
    u => Con{P114FLFact{word,lane},p114fl_limit(remaining,63)})
