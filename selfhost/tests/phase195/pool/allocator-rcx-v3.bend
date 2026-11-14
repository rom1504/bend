# Mechanically assembled by assemble-policy.py; see adjacent inputs receipt.
# Isolated eleven-color experiment: original saved0..3/caller4..8 colors,
# RCX at color9 and R12 at color10. Candidate IDs/graph remain exactly U32.
# R12 use relocates canonical state to one appended Stack word. The existing
# graph still models all calls, structured joins, incoming copies and Again.

def x195_p_saved(+color: U32) -> Bool: U32.is_lt(color,4) || U32.is_eq(color,10)

def x190_l_abi(register: U32) -> U32:
  match register:
    case 0: 0
    case 1: 1
    case 2: 2
    case 3: 4
    case 5: 3
    case _: 5

def x195_p_variable(value: N111Value) -> Bool:
  match value:
    case N111Const{lo,hi}: False{}
    case _: True{}

def x195_p_live(flow: X190LFlow) -> U32:
  match flow:
    case X190LFlow{live,graph}: live

law x195_p_shifts:
  for body: List<&2,P113DStmt>
  for +after: U32
  for +env: X190LEnv
  for blocked: U32
  U32

# Direct variable shifts publish the destination before loading CL. Thus a
# destination in RCX is forbidden even if dead; source-only dying operands may
# use RCX because the existing selector snapshots them before its CL write.
@unsafe
def x195_p_shift_scalar(stmt: N111Stmt, +after: U32, +env: X190LEnv, +blocked: U32) -> U32:
  match stmt env:
    case N111Bin{name,typ,op,left,right} X190LEnv{ids,parameters,header,collect}:
      nt_choose(U32,x181_shift(op) && (x195_p_variable(right) || Bool.not(x185_machine_enabled())),
        u => U32.or(blocked,U32.or(after,x190_l_bit(name,ids))),u => blocked)
    case N111If{condition,yes,no} _:
      x195_p_shifts(x181_scalar_rows(no),after,env,
        x195_p_shifts(x181_scalar_rows(yes),after,env,blocked))
    case _ _: blocked

@unsafe
def x195_p_shift_stmt(stmt: P113DStmt, +after: U32, +env: X190LEnv, blocked: U32) -> U32:
  match stmt:
    case P113DScalar{scalar}: x195_p_shift_scalar(scalar,after,env,blocked)
    case P113DIf{condition,yes,no}: x195_p_shifts(no,after,env,x195_p_shifts(yes,after,env,blocked))
    case _: blocked

# Same fixed point and transfer functions as the certified graph; no lexical
# approximation. This extra clobber walk is bounded by the unchanged256 gate.
@unsafe
def x195_p_shifts(body,after,env,blocked):
  match body:
    case Nil{}: blocked
    case Con{head,+rest}:
      +live = x195_p_live(x190_l_body(rest,X190LFlow{after,[]},env))
      x195_p_shifts(rest,after,env,x195_p_shift_stmt(head,live,env,blocked))

def x195_p_edges(+bit: U32, +edges: U32, color: U32) -> U32:
  nt_choose(U32,x195_p_saved(color),u => U32.and(edges,U32.not(bit)),u => edges)

def x195_p_allowed(+bit: U32, edges: U32, position: U32, +color: U32, shifts: U32) -> Bool:
  nt_choose(Bool,x195_p_saved(color),u => True{},u =>
    U32.is_ge(color,4) && U32.is_lt(color,10) && U32.is_eq(U32.and(bit,edges),0) &&
    U32.is_ge(position,x190_l_abi(U32.sub(color,4))) &&
    (Bool.not(U32.is_eq(color,9)) || U32.is_eq(U32.and(bit,shifts),0)))

@unsafe
def x195_p_pick(groups: List<&2,U32>, +bit: U32, +edges: U32, +position: U32,
    +color: U32, +limit: U32, +shifts: U32) -> U32:
  match groups:
    case Nil{}: 11
    case Con{mask,rest}:
      nt_choose(U32,U32.is_ge(color,limit),u => 11,u =>
        nt_choose(U32,x195_p_allowed(bit,edges,position,color,shifts) &&
            U32.is_eq(U32.and(mask,x195_p_edges(bit,edges,color)),0),
          v => color,v => x195_p_pick(rest,bit,edges,position,U32.inc(color),limit,shifts)))

@unsafe
def x195_p_affinity(groups: List<&2,U32>, +partners: U32, +bit: U32, +edges: U32,
    +position: U32, +color: U32, +shifts: U32) -> U32:
  match groups:
    case Nil{}: 11
    case Con{+mask,rest}:
      nt_choose(U32,Bool.not(U32.is_eq(U32.and(mask,partners),0)) &&
          x195_p_allowed(bit,edges,position,color,shifts) &&
          U32.is_eq(U32.and(mask,x195_p_edges(bit,edges,color)),0),
        u => color,u => x195_p_affinity(rest,partners,bit,edges,position,U32.inc(color),shifts))

@unsafe
def x195_p_plain(+groups: List<&2,U32>, +bit: U32, +edges: U32, +position: U32, +shifts: U32) -> U32:
  +caller = nt_choose(U32,x190_caller_first_enabled(),
    u => x195_p_pick(x190_j_callers(groups),bit,edges,position,4,10,shifts),u => 11)
  nt_choose(U32,U32.is_lt(caller,11),u => caller,
    u => x195_p_pick(groups,bit,edges,position,0,11,shifts))

@unsafe
def x195_p_choose(+groups: List<&2,U32>, partners: U32, +bit: U32, +edges: U32,
    +position: U32, +shifts: U32) -> U32:
  +preferred = nt_choose(U32,x190_coalescing_enabled(),
    u => x195_p_affinity(groups,partners,bit,edges,position,0,shifts),u => 11)
  nt_choose(U32,U32.is_lt(preferred,11),u => preferred,
    u => x195_p_plain(groups,bit,edges,position,shifts))

@unsafe
def x195_p_color(names: List<&2,String>, rows: List<&2,U32>, params: List<&2,String>,
    bit: U32, groups: List<&2,U32>, affinities: KDef, shifts: U32) -> List<&2,U32>:
  x195_pc_color(names,rows,params,bit,groups,affinities,shifts,
    nt_choose(U32,x195_pc_r12_enabled(),u => 11,u => 10))


# Independent final validation repeats uniqueness, graph, calls, ABI and the
# explicit RCX clobber rule; construction is not accepted as its own proof.
@unsafe
def x195_p_valid_groups(groups: List<&2,U32>, +bit: U32, +edges: U32,
    +position: U32, +color: U32, +seen: Bool, +shifts: U32) -> Bool:
  match groups:
    case Nil{}: True{}
    case Con{+mask,rest}:
      +here = Bool.not(U32.is_eq(U32.and(mask,bit),0))
      (Bool.not(here) || (Bool.not(seen) && x195_p_allowed(bit,edges,position,color,shifts) &&
        U32.is_eq(U32.and(mask,x195_p_edges(bit,edges,color)),0))) &&
        x195_p_valid_groups(rest,bit,edges,position,U32.inc(color),seen || here,shifts)

@unsafe
def x195_p_valid(names: List<&2,String>, rows: List<&2,U32>, +params: List<&2,String>,
    +bit: U32, +groups: List<&2,U32>, +shifts: U32) -> Bool:
  match names rows:
    case Nil{} Nil{}: U32.is_eq(nt_count(U32,groups),11)
    case Con{name,rest} Con{edges,more}:
      x195_p_valid_groups(groups,bit,edges,x190_l_position(name,params,0),0,False{},shifts) &&
        x195_p_valid(rest,more,params,U32.shl(bit),groups,shifts)
    case _ _: False{}

@unsafe
def x195_p_group(groups: List<&2,U32>, +index: U32) -> U32:
  match groups:
    case Nil{}: 0
    case Con{mask,rest}: nt_choose(U32,U32.is_eq(index,0),u => mask,
      u => x195_p_group(rest,U32.sub(index,1)))

@unsafe
def x195_p_state_safe(frame: X181Frame) -> Bool:
  match frame:
    case X181Frame{slots,+bytes,+calls,params,symbol}:
      +state = p111v_get(slots,"state")
      String.eq(dk(state),"X181Register") && U32.is_eq(da(state),0) && U32.is_eq(dx(state),8) &&
        U32.is_ge(bytes,40) && U32.is_le(bytes,2147483519) && U32.is_le(calls,2147483000) &&
        U32.is_le(calls,U32.sub(2147483519,bytes))

# Append rather than reuse a canonical Stack offset. Save-mask discovery sees
# any allocated saved0 home. If no name receives R12, keep the old state home.
@unsafe
def x195_p_state(+frame: X181Frame, groups: List<&2,U32>) -> X181Frame:
  match frame:
    case X181Frame{+slots,+bytes,calls,params,symbol}:
      nt_choose(X181Frame,U32.is_eq(x195_p_group(groups,10),0),u => frame,u =>
        X181Frame{p111v_put(slots,"state","X181Stack",x181_frame_align(U32.add(bytes,8),8),8),
          x181_frame_align(U32.add(bytes,8),8),calls,params,symbol})

@unsafe
def x195_p_home(groups: List<&2,U32>, +bit: U32, +color: U32) -> U32:
  match groups:
    case Nil{}: 11
    case Con{mask,rest}: nt_choose(U32,U32.is_eq(U32.and(mask,bit),0),
      u => x195_p_home(rest,bit,U32.inc(color)),u => color)

@unsafe
def x195_p_install(names: List<&2,String>, +groups: List<&2,U32>, +bit: U32, +frame: X181Frame) -> X181Frame:
  match names:
    case Nil{}: frame
    case Con{+name,rest}:
      +color = x195_p_home(groups,bit,0)
      x195_p_install(rest,groups,U32.shl(bit),nt_choose(X181Frame,U32.is_eq(color,10),
        u => x181_register_install(name,0,frame),u =>
        nt_choose(X181Frame,U32.is_lt(color,4),v => x181_register_install(name,U32.inc(color),frame),v =>
          nt_choose(X181Frame,U32.is_ge(color,4) && U32.is_lt(color,10),
            w => x185_t_install(name,U32.sub(color,4),frame),w => frame))))

@unsafe
def x195_p_checked(+frame: X181Frame, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +registerBody: List<&2,P113DStmt>, +names: List<&2,String>,
    rows: List<&2,U32>, +groups: List<&2,U32>, shifts: U32) -> X181Frame:
  nt_choose(X181Frame,U32.is_le(nt_count(String,names),32) && x195_p_state_safe(frame) &&
      x195_p_valid(names,rows,params,1,groups,shifts),
    u => x195_p_install(names,groups,1,x195_p_state(frame,groups)),
    u => x190_allocate_legacy(frame,params,setup,body,registerBody))

@unsafe
def x195_p_graphed(+frame: X181Frame, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, registerBody: List<&2,P113DStmt>, +names: List<&2,String>, +ids: KDef,
    +shifts: U32, flow: X190LFlow) -> X181Frame:
  match flow:
    case X190LFlow{live,+graph}:
      x195_p_checked(frame,params,setup,body,registerBody,names,graph,
        x195_p_color(names,graph,params,1,[0,0,0,0,0,0,0,0,0,0,0],
          x190_a_body(body,ids,x181_tail_args(frame),x190_a_body(setup,ids,x181_tail_args(frame),missing())),shifts),shifts)

# Sole allocator pipeline override. Admission, candidate selection and fixed
# point fuel are original; failed solve/validation keeps complete old fallback.
@unsafe
def x190_j_solved(+frame: X181Frame, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +registerBody: List<&2,P113DStmt>, +names: List<&2,String>,
    +ids: KDef, +parameters: U32, fixed: X190LFixed) -> X181Frame:
  match fixed:
    case X190LFixed{+header,ready}:
      +env: X190LEnv = X190LEnv{ids,parameters,header,True{}}
      +scanEnv: X190LEnv = X190LEnv{ids,parameters,header,False{}}
      nt_choose(X181Frame,ready,
        u => x195_p_graphed(frame,params,setup,body,registerBody,names,ids,
          x195_p_shifts(setup,header,scanEnv,x195_p_shifts(body,0,scanEnv,0)),
          x190_l_incoming(params,x190_l_body(setup,x190_l_body(body,X190LFlow{0,x190_l_zeros(names)},env),env),env)),
        u => x190_allocate_legacy(frame,params,setup,body,registerBody))


# Profitability-only color limit. Always retain eleven group slots, sentinel11,
# original interference masks and the complete eleven-color final validator.
@unsafe
def x195_pc_plain(+groups: List<&2,U32>, +bit: U32, +edges: U32, +position: U32,
    +shifts: U32, +limit: U32) -> U32:
  +caller = nt_choose(U32,x190_caller_first_enabled(),
    u => x195_p_pick(x190_j_callers(groups),bit,edges,position,4,10,shifts),u => 11)
  nt_choose(U32,U32.is_lt(caller,10),u => caller,
    u => x195_p_pick(groups,bit,edges,position,0,limit,shifts))

@unsafe
def x195_pc_choose(+groups: List<&2,U32>, partners: U32, +bit: U32, +edges: U32,
    +position: U32, +shifts: U32, +limit: U32) -> U32:
  +preferred = nt_choose(U32,x190_coalescing_enabled(),
    u => x195_p_affinity(groups,partners,bit,edges,position,0,shifts),u => 11)
  nt_choose(U32,U32.is_lt(preferred,limit),u => preferred,
    u => x195_pc_plain(groups,bit,edges,position,shifts,limit))

@unsafe
def x195_pc_color(names: List<&2,String>, rows: List<&2,U32>, +params: List<&2,String>,
    +bit: U32, +groups: List<&2,U32>, +affinities: KDef, +shifts: U32, +limit: U32) -> List<&2,U32>:
  match names rows:
    case Con{+name,rest} Con{edges,more}:
      x195_pc_color(rest,more,params,U32.shl(bit),
        x190_l_group(groups,x195_pc_choose(groups,da(p111v_get(affinities,name)),bit,edges,
          x190_l_position(name,params,0),shifts,limit),bit),affinities,shifts,limit)
    case _ _: groups


# False is the RCX-only ablation. True reconstructs original eleven-color
# profitability; neither setting changes which forced assignments are legal.
def x195_pc_r12_enabled() -> Bool: False{}


