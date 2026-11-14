# Experiment: larger body admission with the unchanged 32-name graph/verifier.
def x195_allocation_limit() -> U32: 1024

@unsafe
def x190_liveness_frame(+frame: X181Frame, +params: List<&2,String>, +setup: List<&2,P113DStmt>, +body: List<&2,P113DStmt>) -> X181Frame:
  nt_choose(X181Frame,x190_liveness_enabled() && U32.is_le(p113i_add(p113i_size(setup),p113i_size(body)),x195_allocation_limit()) &&
      U32.is_le(nt_count(String,params),64) && x190_l_safe_body(setup) && x190_l_safe_body(body),
    u => x190_l_counted(frame,params,setup,body,x181_reads_stmts(setup,x181_reads_stmts(body,X181ReadCounts{missing(),[]}))),
    u => x185_transient_frame(frame,params,setup,body))

# Optional joint coloring starts from x181_frame, before fixed placement.
# Colors 0..3 are saved homes 1..4; colors 4..8 are the five caller homes.
# The same graph controls both pools. A self edge is a call-clobber marker,
# removed only when considering a callee-saved color; all other edges survive.

@unsafe
def x190_joint_frame(+frame: X181Frame, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +registerBody: List<&2,P113DStmt>) -> X181Frame:
  nt_choose(X181Frame,U32.is_le(p113i_add(p113i_size(setup),p113i_size(body)),x195_allocation_limit()) &&
      U32.is_le(nt_count(String,params),64) && x190_l_safe_body(setup) && x190_l_safe_body(body),
    u => x190_j_counted(frame,params,setup,body,registerBody,
      x191_joint_reads(setup,body,x181_tail_args(frame))),
    u => x190_allocate_legacy(frame,params,setup,body,registerBody))
