@unsafe
def p114b_render(+name: String, +original: List<&2,N111Stmt>, +ids: N111Ids, result: P114BBody) -> String:
  match result:
    case P114BBody{body,next}:
      "export function l $" ++ p111q_symbol(name) ++ "(l %state) {\n@entry\n" ++
        p111q_body_text(p112w_stmts(body,[],True{},ids,
          P111QCode{p111q_allocas(original,[]),0,False{},""})) ++ "}\n"

# The original self-tail plan wins before bridging. Existing terminal legacy
# private calls stay P112WorkerCall nodes and are not rewritten by p114b_scan.
@unsafe
def p114b_public_segment(+segment: N111Segment, +direct: KDef, +ids: N111Ids, +ready: KDef) -> String:
  match segment:
    case N111Segment{+name,arity,+result,incoming,+flags,+body}:
      nt_choose(String,p112t_admitted(p112t_plan(segment)),u => p112q_segment(segment,ids),u =>
        nt_choose(String,U32.is_eq(result,1) && U32.is_eq(flags,0),
          u => p114b_render(name,body,ids,p114b_scan(p112w_public(body,name,ready),direct,0)),
          u => p111q_segment(segment,ids)))

@unsafe
def p114b_fused(+segment: N111Segment, +direct: KDef, +ids: N111Ids, +ready: KDef, plan: P112FusionBody) -> String:
  match segment plan:
    case N111Segment{+name,+arity,+result,+incoming,+flags,original} P112FusionBody{body,+count,next}:
      nt_choose(String,U32.is_eq(count,0),u => p114b_public_segment(segment,direct,ids,ready),
        u => p114b_public_segment(N111Segment{name,arity,result,incoming,flags,body},direct,ids,ready))

# Preserve the selected G02 and narrow04 choices before generic bridging.
@unsafe
def p114b_general(+segment: N111Segment, +direct: KDef, +index: P112FusionIndex,
    +ids: N111Ids, +ready: KDef, +plan: P114GPlan) -> String:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,+body}:
      nt_choose(String,p114g_hygiene(body,index,plan),
        u => p114r_public(name,arity) ++ p114g_private(name,ids,plan),
        u => p114b_fused(segment,direct,ids,ready,p112c_plan_index(segment,index,ready)))

@unsafe
def p114b_narrow(+segment: N111Segment, +direct: KDef, +index: P112FusionIndex,
    +ids: N111Ids, +ready: KDef, +plan: P114RPlan) -> String:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,+body}:
      nt_choose(String,p114r_hygiene(body,index,plan),
        u => p114r_public(name,arity) ++ p114r_private(name,ids,plan),
        u => p114b_general(segment,direct,index,ids,ready,p114g_plan(segment,index,ready)))
