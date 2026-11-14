# Replace exactly these three original definitions for the experimental API.
# No new facts walk: preserve original da counts and add independent dx counts.
@unsafe
def x190_branch_pair_record(+name: String, +pairs: KDef) -> KDef:
  +old = p111v_get(pairs,name)
  p111v_put(pairs,name,"X190BranchPairs",x181_read_increment(da(old)),dx(old))

@unsafe
def x190_branch_pairs(body,pairs):
  match body:
    case Nil{}: pairs
    case Con{head,rest}: x190_branch_pairs(rest,x190_branch_pairs_stmt(head,
      x194_ps_count_pick(x194_ps_pick(body),x190_branch_pair(body,pairs))))

@unsafe
def x190_step(+body: List<&2,P113DStmt>, +facts: X190BranchFacts,
    +ids: N111Ids, +frame: X181Frame, +code: X181Code) -> X181Code:
  x194_ps_step(x194_ps_pick(body),body,facts,ids,frame,code)
