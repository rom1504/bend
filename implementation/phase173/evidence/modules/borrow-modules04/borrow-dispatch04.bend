# Revision04: pass verified constructor metadata into the shared template.
# Shared whole-region admission for the selected typed emitters. The admitted
# region terminates, so no facts flow out. Refusal delegates with the identical
# ctx/facts/code to the exact prior dispatcher, retaining invalidation rules.

@unsafe
def p173b_attempt_plan(+body: List<&2,P113DStmt>, +ids: N111Ids,
  +code: P111QCode, +plan: P173BPlan) -> Maybe<&2,P111QCode>:
  match code:
    case P111QCode{chunks,+next,terminal,error}:
      nt_choose(Maybe<&2,P111QCode>,Bool.not(terminal) && String.is_empty(error) &&
        U32.is_le(next,4294966200) && p173b_profitable(plan),
        u => Some{p111q_stmts(p173b_template(plan,body,ids,next),ids,
          P111QCode{chunks,U32.inc(next),terminal,error})},u => None{})

@unsafe
def p173b_attempt(+body: List<&2,P113DStmt>, +ids: N111Ids, +code: P111QCode) -> Maybe<&2,P111QCode>:
  p173b_attempt_plan(body,ids,code,p173b_plan(body,ids))

@unsafe
def p173b_i_previous(+body: List<&2,P113DStmt>, +ctx: P126ICtx,
  +facts: List<&2,P114FLFact>, +code: P111QCode) -> P111QCode:
  match body code:
    case Nil{} _: code
    case Con{+head,+rest} P111QCode{chunks,site,terminal,+error}:
      nt_choose(P111QCode,String.is_empty(error),u =>
        nt_choose(P111QCode,terminal,u => p111q_problem("typed statement after transfer",code),
          u => p126i_dispatch(head,rest,ctx,facts,code,p114so_group(Con{head,rest}))),u => code)

@unsafe
def p173b_l_previous(+body: List<&2,P113DStmt>, +ctx: P126LCtx,
  +facts: List<&2,P114FLFact>, +code: P111QCode) -> P111QCode:
  match body code:
    case Nil{} _: code
    case Con{+head,+rest} P111QCode{chunks,site,terminal,+error}:
      nt_choose(P111QCode,String.is_empty(error),u =>
        nt_choose(P111QCode,terminal,u => p111q_problem("typed statement after transfer",code),
          u => p126l_dispatch(head,rest,ctx,facts,code,p114so_group(Con{head,rest}))),u => code)

@unsafe
def p173b_i_selected(body: List<&2,P113DStmt>, ctx: P126ICtx,
  facts: List<&2,P114FLFact>, code: P111QCode, selected: Maybe<&2,P111QCode>) -> P111QCode:
  match selected:
    case Some{emitted}: emitted
    case None{}: p173b_i_previous(body,ctx,facts,code)

@unsafe
def p173b_l_selected(body: List<&2,P113DStmt>, ctx: P126LCtx,
  facts: List<&2,P114FLFact>, code: P111QCode, selected: Maybe<&2,P111QCode>) -> P111QCode:
  match selected:
    case Some{emitted}: emitted
    case None{}: p173b_l_previous(body,ctx,facts,code)

@unsafe
def p173b_i_stmts(body, ctx, facts, code):
  match ctx:
    case P126ICtx{params,buffers,ids,tables}:
      p173b_i_selected(body,ctx,facts,code,p173b_attempt(body,ids,code))

@unsafe
def p173b_l_stmts(body, ctx, facts, code):
  match ctx:
    case P126LCtx{params,buffers,ids}:
      p173b_l_selected(body,ctx,facts,code,p173b_attempt(body,ids,code))

@unsafe
def p173bd_text(+body: List<&2,P113DStmt>, +facts: List<&2,P114FLFact>, typed: Bool) -> String:
  +code : P111QCode = P111QCode{[],0,False{},""}
  nt_choose(String,typed,
    u => p111q_body_text(p173b_i_stmts(body,P126ICtx{[],[],p173bt_ids(),[]},facts,code)),
    u => p111q_body_text(p173b_l_stmts(body,P126LCtx{[],[],p173bt_ids()},facts,code)))

@unsafe
def p173b_dispatch_controls() -> List<&2,String>:
  +normal = p173bt_body([p173bt_sink(1)],p173bt_stores(N111Local{"replacement"}))
  +plain = p173bt_text(normal)
  +facts : List<&2,P114FLFact> = [P114FLFact{"unrelated_float","prior_lane"}]
  +scalar : List<&2,P113DStmt> = [P113DScalar{N111Set{"result",N111U64{},N111Const{7,0}}},P113DResult{[N111Local{"result"}]}]
  +branch : List<&2,P113DStmt> = [P113DIf{N111Const{1,0},normal,[P113DResult{[N111Const{0,0}]}]}]
  [p113ft_row("record-typed-table-dispatch",String.eq(plain,p173bd_text(normal,[],True{}))),
   p113ft_row("record-typed-lane-dispatch",String.eq(plain,p173bd_text(normal,[],False{}))),
   p113ft_row("record-typed-table-terminal-facts",String.eq(plain,p173bd_text(normal,facts,True{}))),
   p113ft_row("record-typed-lane-terminal-facts",String.eq(plain,p173bd_text(normal,facts,False{}))),
   p113ft_row("record-typed-table-refusal-identical",String.eq(p173bt_text(scalar),p173bd_text(scalar,facts,True{}))),
   p113ft_row("record-typed-lane-refusal-identical",String.eq(p173bt_text(scalar),p173bd_text(scalar,facts,False{}))),
   p113ft_row("record-typed-table-nested-branch",String.contains(p173bd_text(branch,[],True{}),"_p173borrow_")),
   p113ft_row("record-typed-lane-nested-branch",String.contains(p173bd_text(branch,[],False{}),"_p173borrow_"))]
