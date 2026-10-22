# A conditional scalar preparation step does not change the destination of the
# already authenticated final argument stores and recursive jump. Preserve the
# branch and all its statements; only the eligibility predicate is extended.
# Scope: H-table own descent only. Old R/G and ready-helper admission unchanged.
@unsafe
def p126r_scalar(stmt: N111Stmt) -> Bool:
  match stmt:
    case N111If{condition,yes,no}: p126r_scalars(yes) && p126r_scalars(no)
    case _: p112t_scalar_safe(stmt)

@unsafe
def p126r_scalars(body: List<&2,N111Stmt>) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{head,rest}: p126r_scalar(head) && p126r_scalars(rest)

@unsafe
def p126r_arguments(+body: List<&2,N111Stmt>, +owner: String, +arity: U32) -> Bool:
  nt_choose(Bool,p112t_tail(body,owner,arity,0),u => True{},
    u => p126r_arguments_next(body,owner,arity))

@unsafe
def p126r_arguments_next(body: List<&2,N111Stmt>, +owner: String, +arity: U32) -> Bool:
  match body:
    case Con{head,rest}: p126r_scalar(head) && p126r_arguments(rest,owner,arity)
    case _: False{}

@unsafe
def p114h_scan_frame(+body: List<&2,N111Stmt>, +owner: String, +arity: U32, +ready: KDef, frame: Maybe<&2,P112FusionFrame>) -> P114GBody:
  match frame:
    case Some{P112FusionFrame{captures,+name,dest,+tail}}:
      +count = nt_count(N111Value,captures)
      nt_choose(P114GBody,U32.is_le(count,8) && p126r_arguments(tail,owner,arity),
        u => P114GBody{True{},[P114GFrame{name,count}],[P114RDescend{p114r_prefix(body,U32.inc(count)),p114r_without_transition(tail)}]},
        u => p124r_resume(body,tail,owner,name,count,ready))
    case None{}: p114h_scan_next(body,owner,arity,ready)
