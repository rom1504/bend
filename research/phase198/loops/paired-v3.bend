# Reserve one legal, still uncolored recurrence partner together with its name.
# Existing liveness, clobbers, ABI restrictions and the independent graph check
# remain authoritative. This changes placement only, not IR or loop behavior.
type X198LPair is Data:
  X198LPair{+color: U32, +partner: U32}

def x198lp_enabled() -> Bool: True{}

@unsafe
def x198lp_tail(body: List<&2,P113DStmt>, +ids: KDef, +params: List<&2,String>, pairs: KDef) -> KDef:
  match body:
    case Nil{}: pairs
    case Con{P113DIf{condition,yes,no},rest}:
      x198lp_tail(rest,ids,params,x198lp_tail(no,ids,params,x198lp_tail(yes,ids,params,pairs)))
    case Con{P113DScalar{N111If{condition,yes,no}},rest}:
      x198lp_tail(rest,ids,params,x198lp_tail(x181_scalar_rows(no),ids,params,
        x198lp_tail(x181_scalar_rows(yes),ids,params,pairs)))
    case Con{P113DAgain{values},rest}: x198lp_tail(rest,ids,params,x190_a_tail(params,values,ids,pairs))
    case Con{head,rest}: x198lp_tail(rest,ids,params,pairs)

@unsafe
def x198lp_pick(groups: List<&2,U32>, +bit: U32, +edges: U32, +position: U32,
    +partner: U32, +otherEdges: U32, +otherPosition: U32, +color: U32) -> U32:
  match groups:
    case Nil{}: 9
    case Con{mask,rest}:
      nt_choose(U32,x190_j_allowed(bit,edges,position,color) &&
          x190_j_allowed(partner,otherEdges,otherPosition,color) &&
          U32.is_eq(U32.and(mask,U32.or(x190_j_edges(bit,edges,color),x190_j_edges(partner,otherEdges,color))),0),
        u => color,u => x198lp_pick(rest,bit,edges,position,partner,otherEdges,otherPosition,U32.inc(color)))

@unsafe
def x198lp_choose(+groups: List<&2,U32>, +bit: U32, +edges: U32, +position: U32,
    +partner: U32, +otherEdges: U32, +otherPosition: U32) -> U32:
  +caller = nt_choose(U32,x190_caller_first_enabled(),u =>
    x198lp_pick(x190_j_callers(groups),bit,edges,position,partner,otherEdges,otherPosition,4),u => 9)
  nt_choose(U32,U32.is_lt(caller,9),u => caller,
    u => x198lp_pick(groups,bit,edges,position,partner,otherEdges,otherPosition,0))

law x198lp_partner:
  for names: List<&2,String>
  for rows: List<&2,U32>
  for +params: List<&2,String>
  for +candidate: U32
  for +partners: U32
  for +bit: U32
  for +edges: U32
  for +position: U32
  for +groups: List<&2,U32>
  X198LPair

@unsafe
def x198lp_found(+names: List<&2,String>, +rows: List<&2,U32>, +params: List<&2,String>,
    +candidate: U32, +partners: U32, +bit: U32, +edges: U32, +position: U32,
    +groups: List<&2,U32>, +color: U32) -> X198LPair:
  nt_choose(X198LPair,U32.is_lt(color,9),u => X198LPair{color,candidate},
    u => x198lp_partner(names,rows,params,U32.shl(candidate),partners,bit,edges,position,groups))

@unsafe
def x198lp_partner(names,rows,params,candidate,partners,bit,edges,position,groups):
  match names rows:
    case Con{name,+rest} Con{+otherEdges,+more}:
      nt_choose(X198LPair,Bool.not(U32.is_eq(U32.and(partners,candidate),0)) &&
          U32.is_eq(U32.and(edges,candidate),0) && U32.is_eq(U32.and(otherEdges,bit),0) &&
          U32.is_eq(x190_j_home(groups,candidate,0),9),
        u => x198lp_found(rest,more,params,candidate,partners,bit,edges,position,groups,
          x198lp_choose(groups,bit,edges,position,candidate,otherEdges,x190_l_position(name,params,0))),
        u => x198lp_partner(rest,more,params,U32.shl(candidate),partners,bit,edges,position,groups))
    case _ _: X198LPair{9,0}

@unsafe
def x198lp_group(+name: String, +bit: U32, +edges: U32, +params: List<&2,String>,
    +groups: List<&2,U32>, affinities: KDef, pair: X198LPair) -> List<&2,U32>:
  match pair:
    case X198LPair{+color,partner}:
      nt_choose(List<&2,U32>,U32.is_lt(color,9),
        u => x190_l_group(groups,color,U32.or(bit,partner)),
        u => x190_l_group(groups,x190_a_choose(groups,da(p111v_get(affinities,name)),bit,edges,
          x190_l_position(name,params,0)),bit))

# No-pair functions retain the original linear coloring traversal.
@unsafe
def x198lp_plan(+names: List<&2,String>, +rows: List<&2,U32>, +params: List<&2,String>,
    +candidate: U32, +partners: U32, +bit: U32, +edges: U32, +position: U32,
    +groups: List<&2,U32>) -> X198LPair:
  nt_choose(X198LPair,U32.is_eq(partners,0),u => X198LPair{9,0},
    u => x198lp_partner(names,rows,params,candidate,partners,bit,edges,position,groups))

@unsafe
def x198lp_color(names: List<&2,String>, rows: List<&2,U32>, +params: List<&2,String>,
    +bit: U32, +groups: List<&2,U32>, +affinities: KDef, +pairs: KDef) -> List<&2,U32>:
  match names rows:
    case Con{+name,+rest} Con{+edges,+more}:
      x198lp_color(rest,more,params,U32.shl(bit),
        nt_choose(List<&2,U32>,U32.is_lt(x190_j_home(groups,bit,0),9),u => groups,
          u => x198lp_group(name,bit,edges,params,groups,affinities,
            x198lp_plan(rest,more,params,U32.shl(bit),da(p111v_get(pairs,name)),bit,edges,
              x190_l_position(name,params,0),groups))),affinities,pairs)
    case _ _: groups
