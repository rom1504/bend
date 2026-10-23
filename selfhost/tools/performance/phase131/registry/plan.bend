# Only avoid the legacy fusion scan when it cannot recognize a frame site.
# A direct worker's existence alone is insufficient: legacy admission/ranks
# still affect other callers, so every existing plan and freeze check remains.

@unsafe
def p131rg_no_frame(+body: List<&2,N111Stmt>) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{N111Call{dest,typ,+symbol,args},+rest}:
      nt_choose(Bool,String.eq(symbol,"p111_rt_frame"),u => False{},
        u => p131rg_no_frame(rest))
    case Con{N111If{condition,yes,no},rest}:
      p131rg_no_frame(yes) && p131rg_no_frame(no) && p131rg_no_frame(rest)
    case Con{stmt,rest}: p131rg_no_frame(rest)

@unsafe
def p131rg_scan(+body: List<&2,N111Stmt>, +index: P112FusionIndex, +ready: KDef, +site: U32) -> P112FusionBody:
  nt_choose(P112FusionBody,p131rg_no_frame(body),
    u => P112FusionBody{body,0,site},
    u => p112c_scan(body,index,ready,site))

# Exact original signature and all admission/registry operations retained.
# p131rg_scan is called once per candidate/round, never at every suffix.
@unsafe
def p112c_add(+segment: N111Segment, +index: P112FusionIndex, +old: KDef, +symbols: KDef, +rank: U32, +next: P112RegionRegistry) -> P112RegionRegistry:
  match segment:
    case N111Segment{+name,+arity,+result,+incoming,+flags,+body}:
      nt_choose(P112RegionRegistry,p112w_ready(old,name),u => next,u =>
        p112c_fused(segment,old,symbols,rank,next,p131rg_scan(body,index,old,0)))
