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
def x195_p_color(names: List<&2,String>, rows: List<&2,U32>, +params: List<&2,String>,
    +bit: U32, +groups: List<&2,U32>, +affinities: KDef, +shifts: U32) -> List<&2,U32>:
  match names rows:
    case Con{+name,rest} Con{edges,more}:
      x195_p_color(rest,more,params,U32.shl(bit),
        x190_l_group(groups,x195_p_choose(groups,da(p111v_get(affinities,name)),bit,edges,
          x190_l_position(name,params,0),shifts),bit),affinities,shifts)
    case _ _: groups

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
      +affinities = x190_a_body(body,ids,x181_tail_args(frame),x190_a_body(setup,ids,x181_tail_args(frame),missing()))
      x195_ap_eleven(frame,params,setup,body,registerBody,names,graph,ids,affinities,
        x195_pc_color(names,graph,params,1,[0,0,0,0,0,0,0,0,0,0,0],affinities,shifts,11),shifts)


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


# Profitability only. The same independent eleven-color validator authorizes
# either result. Costs are weighted syntactic frame reads/writes, not timings.
type X195APCost is Data:
  X195APCost{+gain: U32, +loss: U32, +state: U32}
type X195APEnv is Data:
  X195APEnv{+ids: KDef, +gained: U32, +lost: U32, +parameters: List<&2,String>, +weighted: Bool}
type X195APFlow is Data:
  X195APFlow{+cost: X195APCost, +reaches: Bool, +falls: Bool}

# False reconstructs the original eleven-color policy without cost walks.
def x195_ap_enabled() -> Bool: True{}
def x195_ap_zero() -> X195APCost: X195APCost{0,0,0}
def x195_ap_add(+a: U32, +b: U32) -> U32:
  nt_choose(U32,U32.is_gt(b,U32.sub(4294967295,a)),u => 4294967295,u => U32.add(a,b))
def x195_ap_eight(+a: U32) -> U32:
  nt_choose(U32,U32.is_gt(a,536870911),u => 4294967295,u => U32.mul(a,8))
def x195_ap_sum(a: X195APCost, b: X195APCost) -> X195APCost:
  match a b:
    case X195APCost{ag,al,ast} X195APCost{bg,bl,bst}:
      X195APCost{x195_ap_add(ag,bg),x195_ap_add(al,bl),x195_ap_add(ast,bst)}
def x195_ap_scale(+cost: X195APCost, hot: Bool, env: X195APEnv) -> X195APCost:
  match cost env:
    case X195APCost{gain,loss,state} X195APEnv{ids,gained,lost,parameters,weighted}:
      nt_choose(X195APCost,hot && weighted,
        u => X195APCost{x195_ap_eight(gain),x195_ap_eight(loss),x195_ap_eight(state)},u => cost)
def x195_ap_take(cost: X195APCost) -> Bool:
  match cost:
    case X195APCost{gain,loss,state}: U32.is_gt(gain,x195_ap_add(loss,state))

@unsafe
def x195_ap_name(+name: String, env: X195APEnv) -> X195APCost:
  match env:
    case X195APEnv{ids,gained,lost,parameters,weighted}:
      +bit = x190_l_bit(name,ids)
      X195APCost{nt_choose(U32,U32.is_eq(U32.and(bit,gained),0),u => 0,u => 1),
        nt_choose(U32,U32.is_eq(U32.and(bit,lost),0),u => 0,u => 1),
        nt_choose(U32,String.eq(name,"state"),u => 1,u => 0)}
@unsafe
def x195_ap_value(value: N111Value, env: X195APEnv) -> X195APCost:
  match value:
    case N111Local{name}: x195_ap_name(name,env)
    case _: x195_ap_zero()
@unsafe
def x195_ap_values(values: List<&2,N111Value>, +env: X195APEnv) -> X195APCost:
  match values:
    case Nil{}: x195_ap_zero()
    case Con{value,rest}: x195_ap_sum(x195_ap_value(value,env),x195_ap_values(rest,env))
@unsafe
def x195_ap_names(names: List<&2,String>, +env: X195APEnv) -> X195APCost:
  match names:
    case Nil{}: x195_ap_zero()
    case Con{name,rest}: x195_ap_sum(x195_ap_name(name,env),x195_ap_names(rest,env))
@unsafe
def x195_ap_args(args: List<&2,N111Arg>, +env: X195APEnv) -> X195APCost:
  match args:
    case Nil{}: x195_ap_zero()
    case Con{N111Arg{typ,value},rest}: x195_ap_sum(x195_ap_value(value,env),x195_ap_args(rest,env))
@unsafe
def x195_ap_again(params: List<&2,String>, values: List<&2,N111Value>, +env: X195APEnv) -> X195APCost:
  match params values:
    case Con{+name,rest} Con{+value,more}:
      x195_ap_sum(nt_choose(X195APCost,x191_again_identity(name,value),u => x195_ap_zero(),
        u => x195_ap_sum(x195_ap_name(name,env),x195_ap_value(value,env))),x195_ap_again(rest,more,env))
    case _ _: x195_ap_zero()

# Inline F32 does not read its syntactic state argument. Ordinary scalar calls
# use explicit args; product calls additionally inject one state argument.
@unsafe
def x195_ap_call(operation: X186InlineOp, name: String, args: List<&2,N111Arg>, +env: X195APEnv) -> X195APCost:
  match operation:
    case X186InlineF32{destination,id,buffer}: x195_ap_sum(x195_ap_name(destination,env),x195_ap_name(buffer,env))
    case _: x195_ap_sum(x195_ap_name(name,env),x195_ap_args(args,env))
@unsafe
def x195_ap_scalar(+stmt: N111Stmt, +env: X195APEnv) -> X195APCost:
  match stmt:
    case N111Set{name,typ,value}: x195_ap_sum(x195_ap_name(name,env),x195_ap_value(value,env))
    case N111Bin{name,typ,op,left,right}:
      x195_ap_sum(x195_ap_name(name,env),x195_ap_sum(x195_ap_value(left,env),x195_ap_value(right,env)))
    case N111Load{name,typ,base,offset}: x195_ap_sum(x195_ap_name(name,env),x195_ap_value(base,env))
    case N111Store{typ,base,offset,value}: x195_ap_sum(x195_ap_value(base,env),x195_ap_value(value,env))
    case N111Offset{name,base,bytes}:
      x195_ap_sum(x195_ap_name(name,env),x195_ap_sum(x195_ap_value(base,env),x195_ap_value(bytes,env)))
    case N111Call{name,typ,symbol,args}: x195_ap_call(x186_inline_op(stmt),name,args,env)
    case N111Return{value}: x195_ap_value(value,env)
    case _: x195_ap_zero()
@unsafe
def x195_ap_event(stmt: P113DStmt, +env: X195APEnv) -> X195APCost:
  match stmt env:
    case P113DScalar{scalar} _: x195_ap_scalar(scalar,env)
    case P113DCall{names,target,args} _:
      x195_ap_sum(x195_ap_name("state",env),x195_ap_sum(x195_ap_names(names,env),x195_ap_values(args,env)))
    case P113DResult{values} _: x195_ap_values(values,env)
    case P113DAgain{values} X195APEnv{ids,gained,lost,parameters,weighted}: x195_ap_again(parameters,values,env)
    case _ _: x195_ap_zero()

law x195_ap_body:
  for body: List<&2,P113DStmt>
  for +env: X195APEnv
  for after: Bool
  X195APFlow

# Same reaches/falls equations as x191_loop_reads. Setup uses weighted=False;
# repeated body paths cost8, while setup, exit-only paths and imports cost1.
@unsafe
def x195_ap_join(condition: N111Value, +env: X195APEnv, yes: X195APFlow, no: X195APFlow) -> X195APFlow:
  match yes no:
    case X195APFlow{a,+hotA,fallA} X195APFlow{b,+hotB,fallB}:
      X195APFlow{x195_ap_sum(x195_ap_scale(x195_ap_value(condition,env),hotA || hotB,env),
        x195_ap_sum(a,b)),hotA || hotB,fallA || fallB}
@unsafe
def x195_ap_stmt(+stmt: P113DStmt, +env: X195APEnv, +after: Bool) -> X195APFlow:
  match stmt:
    case P113DAgain{values}: X195APFlow{x195_ap_scale(x195_ap_event(stmt,env),True{},env),True{},False{}}
    case P113DResult{values}: X195APFlow{x195_ap_event(stmt,env),False{},False{}}
    case P113DScalar{N111Return{value}}: X195APFlow{x195_ap_event(stmt,env),False{},False{}}
    case P113DIf{condition,yes,no}: x195_ap_join(condition,env,x195_ap_body(yes,env,after),x195_ap_body(no,env,after))
    case P113DScalar{N111If{condition,yes,no}}:
      x195_ap_join(condition,env,x195_ap_body(x181_scalar_rows(yes),env,after),x195_ap_body(x181_scalar_rows(no),env,after))
    case _: X195APFlow{x195_ap_scale(x195_ap_event(stmt,env),after,env),after,True{}}
def x195_ap_cons(head: X195APFlow, rest: X195APFlow) -> X195APFlow:
  match head rest:
    case X195APFlow{a,hot,+falls} X195APFlow{b,restHot,restFalls}:
      X195APFlow{x195_ap_sum(a,nt_choose(X195APCost,falls,u => b,u => x195_ap_zero())),hot,falls && restFalls}
@unsafe
def x195_ap_head(head: P113DStmt, env: X195APEnv, +rest: X195APFlow) -> X195APFlow:
  match rest:
    case X195APFlow{cost,hot,falls}: x195_ap_cons(x195_ap_stmt(head,env,hot),rest)
@unsafe
def x195_ap_body(body,env,after):
  match body:
    case Nil{}: X195APFlow{x195_ap_zero(),after,True{}}
    case Con{head,rest}: x195_ap_head(head,env,x195_ap_body(rest,env,after))
def x195_ap_cost(flow: X195APFlow) -> X195APCost:
  match flow:
    case X195APFlow{cost,hot,falls}: cost
@unsafe
def x195_ap_union(groups: List<&2,U32>) -> U32:
  match groups:
    case Nil{}: 0
    case Con{mask,rest}: U32.or(mask,x195_ap_union(rest))

@unsafe
def x195_ap_score(frame: X181Frame, params: List<&2,String>, setup: List<&2,P113DStmt>,
    body: List<&2,P113DStmt>, +ids: KDef, groups10: List<&2,U32>, groups11: List<&2,U32>) -> X195APCost:
  +ten = x195_ap_union(groups10)
  +eleven = x195_ap_union(groups11)
  +gained = U32.and(eleven,U32.not(ten))
  +lost = U32.and(ten,U32.not(eleven))
  +tail = x181_tail_args(frame)
  +cold: X195APEnv = X195APEnv{ids,gained,lost,tail,False{}}
  +hot: X195APEnv = X195APEnv{ids,gained,lost,tail,True{}}
  x195_ap_sum(x195_ap_names(params,cold),
    x195_ap_sum(x195_ap_cost(x195_ap_body(setup,cold,False{})),x195_ap_cost(x195_ap_body(body,hot,False{}))))

@unsafe
def x195_ap_selected(+frame: X181Frame, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, registerBody: List<&2,P113DStmt>, names: List<&2,String>, rows: List<&2,U32>,
    ids: KDef, +groups10: List<&2,U32>, +groups11: List<&2,U32>, shifts: U32) -> X181Frame:
  +cost = x195_ap_score(frame,params,setup,body,ids,groups10,groups11)
  x195_p_checked(frame,params,setup,body,registerBody,names,rows,
    nt_choose(List<&2,U32>,x195_ap_take(cost),u => groups11,u => groups10),shifts)
@unsafe
def x195_ap_eleven(+frame: X181Frame, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +registerBody: List<&2,P113DStmt>, +names: List<&2,String>, +rows: List<&2,U32>,
    +ids: KDef, affinities: KDef, +groups11: List<&2,U32>, +shifts: U32) -> X181Frame:
  nt_choose(X181Frame,x195_ap_enabled() && Bool.not(U32.is_eq(x195_p_group(groups11,10),0)),
    u => x195_ap_selected(frame,params,setup,body,registerBody,names,rows,ids,
      x195_pc_color(names,rows,params,1,[0,0,0,0,0,0,0,0,0,0,0],affinities,shifts,10),groups11,shifts),
    u => x195_p_checked(frame,params,setup,body,registerBody,names,rows,groups11,shifts))

# Sole adaptive override: choose a profitable color construction, then use the
# unchanged checker/state transaction. No extra CFG/graph/fixed-point solve.

