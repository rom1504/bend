# A pending continuation frame is distinct from a recursive descent. Preserve
# its exact stores/call, then continue scanning the remaining computation. This
# composes two pushes before a self descent or an already admitted ready call.
# The old successful plan is returned unchanged. New plans still pass through
# p114h_finish/close: at most eight known cases, exact captures and incoming
# result, reserved-name hygiene, and the original scalar/call restrictions.
#
# Each executed PushFrame increments the private depth once. Existing unwind
# pops its FID and captures once in LIFO order. Recursive work stays in the
# explicit runtime stack; this does not introduce recursive machine calls.
# The node stores no region-state variable: case renaming only renames the
# original frame operands, leaving the emitter-owned depth unchanged.

@unsafe
def p186sf_push(+frame: List<&2,N111Stmt>, +name: String, +count: U32, scanned: P114GBody) -> P114GBody:
  match scanned:
    case P114GBody{valid,frames,body}:
      nt_choose(P114GBody,valid,
        u => P114GBody{True{},Con{P114GFrame{name,count},frames},Con{P114RPushFrame{frame},body}},
        u => P114GBody{False{},[],[]})

@unsafe
def p186sf_retry(+body: List<&2,N111Stmt>, +owner: String, +arity: U32, +ready: KDef, frame: Maybe<&2,P112FusionFrame>) -> P114GBody:
  match frame:
    case Some{P112FusionFrame{captures,name,dest,tail}}:
      +count = nt_count(N111Value,captures)
      nt_choose(P114GBody,U32.is_le(count,8),
        u => p186sf_push(p114r_prefix(body,U32.inc(count)),name,count,p114h_scan(tail,owner,arity,ready)),
        u => P114GBody{False{},[],[]})
    case None{}: P114GBody{False{},[],[]}

@unsafe
def p186sf_retried(previous: P114GBody, proposed: P114GBody) -> P114GBody:
  match proposed:
    case P114GBody{+valid,frames,body}:
      nt_choose(P114GBody,valid,u => P114GBody{valid,frames,body},u => previous)

@unsafe
def p186sf_selected(+body: List<&2,N111Stmt>, +owner: String, +arity: U32, +ready: KDef, +frame: Maybe<&2,P112FusionFrame>, +previous: P114GBody) -> P114GBody:
  match previous:
    case P114GBody{+valid,frames,lowered}:
      nt_choose(P114GBody,valid,u => P114GBody{valid,frames,lowered},
        u => p186sf_retried(previous,p186sf_retry(body,owner,arity,ready,frame)))

@unsafe
def p186sf_frame(+body: List<&2,N111Stmt>, +owner: String, +arity: U32, +ready: KDef, +frame: Maybe<&2,P112FusionFrame>) -> P114GBody:
  p186sf_selected(body,owner,arity,ready,frame,p186sf_previous_frame(body,owner,arity,ready,frame))
