# Bounded caller-register allocation for bounded structured bodies and call-free live ranges.
# Input has saved homes installed but no transient homes yet.
# Candidate IDs are bits; noncandidates keep their existing frame homes. The
# loop header is a least fixed point, Again defines its parameter vector in
# parallel, and setup/incoming writes participate in the same interference.
# Every admitted operation preserves rdi/rsi/rdx/r8/r9 except its destination.
# Call-crossing values keep their old homes; size/validation refusal retains the old placer.
type X190LCandidates is Data:
  X190LCandidates{+names: List<&2,String>, +ids: KDef}

type X190LFlow is Data:
  X190LFlow{+live: U32, +graph: List<&2,U32>}

type X190LEnv is Data:
  X190LEnv{+ids: KDef, +parameters: U32, +header: U32, +collect: Bool}

type X190LFixed is Data:
  X190LFixed{+header: U32, +ready: Bool}

def x190_liveness_enabled() -> Bool: True{}

law x190_l_safe_body:
  for body: List<&2,P113DStmt>
  Bool

# The whitelist follows the scalar selector, including its implicit scratch
# rcx for variable shifts. A multiplication is two-operand imul; division is
# not admitted. The shared inline F32 contract avoids conservative call-clobber marking.
@unsafe
def x190_l_safe_scalar(stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Set{name,typ,value}: True{}
    case N111Bin{name,typ,+op,left,right}:
      Bool.not(String.is_empty(x181_alu(op))) || Bool.not(String.is_empty(x181_condition(op)))
    case N111Load{name,typ,base,offset}: True{}
    case N111Store{typ,base,offset,value}: True{}
    case N111Offset{name,base,bytes}: True{}
    case N111Alloca{name,bytes,align}: True{}
    case N111Return{value}: True{}
    case N111If{condition,yes,no}: x190_l_safe_body(x181_scalar_rows(yes)) && x190_l_safe_body(x181_scalar_rows(no))
    case N111Call{name,typ,symbol,args}: True{}

@unsafe
def x190_l_safe_body(body):
  match body:
    case Nil{}: True{}
    case Con{P113DScalar{stmt},rest}: x190_l_safe_scalar(stmt) && x190_l_safe_body(rest)
    case Con{P113DIf{condition,yes,no},rest}: x190_l_safe_body(yes) && x190_l_safe_body(no) && x190_l_safe_body(rest)
    case Con{P113DCall{names,target,args},rest}: x190_l_safe_body(rest)
    case Con{head,rest}: x190_l_safe_body(rest)

@unsafe
def x190_l_bit(name: String, ids: KDef) -> U32: da(p111v_get(ids,name))

@unsafe
def x190_l_value(value: N111Value, ids: KDef) -> U32:
  match value:
    case N111Local{name}: x190_l_bit(name,ids)
    case _: 0

@unsafe
def x190_l_values(values: List<&2,N111Value>, +ids: KDef) -> U32:
  match values:
    case Nil{}: 0
    case Con{value,rest}: U32.or(x190_l_value(value,ids),x190_l_values(rest,ids))

@unsafe
def x190_l_names(names: List<&2,String>, +ids: KDef) -> U32:
  match names:
    case Nil{}: 0
    case Con{name,rest}: U32.or(x190_l_bit(name,ids),x190_l_names(rest,ids))

# Greedy priority is total body/setup read count, with body encounter ties. Saved homes are
# already installed and never enter this candidate pool. At most 32 names are
# considered; zero-read writes still matter whenever their name is a candidate.
law x190_l_candidates:
  for +names: List<&2,String>
  for +counts: KDef
  for +slots: KDef
  for +bit: U32
  for +fuel: U32
  for +ids: KDef
  for +reversed: List<&2,String>
  X190LCandidates

@unsafe
def x190_l_candidate_chosen(+names: List<&2,String>, +counts: KDef, +slots: KDef,
    +bit: U32, +fuel: U32, +ids: KDef, +reversed: List<&2,String>, choice: X181RegisterChoice) -> X190LCandidates:
  match choice:
    case X181RegisterChoice{+name,reads}:
      nt_choose(X190LCandidates,U32.is_eq(reads,0),u => X190LCandidates{nt_reverse(String,reversed,[]),ids},u =>
        x190_l_candidates(names,p111v_put(counts,name,"X181Reads",0,0),slots,U32.shl(bit),U32.sub(fuel,1),
          p111v_put(ids,name,"X190LBit",bit,0),Con{name,reversed}))

@unsafe
def x190_l_candidates(names,counts,slots,bit,fuel,ids,reversed):
  nt_choose(X190LCandidates,U32.is_eq(fuel,0),u => X190LCandidates{nt_reverse(String,reversed,[]),ids},u =>
    x190_l_candidate_chosen(names,counts,slots,bit,fuel,ids,reversed,
      x181_register_best(names,counts,slots,X181RegisterChoice{"",0})))

# Update a symmetric interference matrix. Co-live values conflict, and every
# write conflicts with live-out even when the written value is dead. A source
# consumed by this instruction may share its destination: all selectors read
# sources before publication, with right operands snapshotted by direct ALU.
@unsafe
def x190_l_edges(rows: List<&2,U32>, +bit: U32, +before: U32, +after: U32, +writes: U32) -> List<&2,U32>:
  match rows:
    case Nil{}: []
    case Con{old,rest}:
      +a = nt_choose(U32,U32.is_eq(U32.and(bit,before),0),u => 0,u => before)
      +b = nt_choose(U32,U32.is_eq(U32.and(bit,after),0),u => 0,u => U32.or(after,writes))
      +c = nt_choose(U32,U32.is_eq(U32.and(bit,writes),0),u => 0,u => after)
      Con{U32.or(old,U32.and(U32.or(a,U32.or(b,c)),U32.not(bit))),
        x190_l_edges(rest,U32.shl(bit),before,after,writes)}

@unsafe
def x190_l_event(reads: U32, +writes: U32, flow: X190LFlow, env: X190LEnv) -> X190LFlow:
  match flow env:
    case X190LFlow{+after,+graph} X190LEnv{ids,parameters,header,+collect}:
      +before = U32.or(reads,U32.and(after,U32.not(writes)))
      X190LFlow{before,nt_choose(List<&2,U32>,collect,
        u => x190_l_edges(graph,1,before,after,writes),u => graph)}

# A real call is a fixed-register clobber. Self edges mark values live across
# it as unallocatable. Arguments are snapshotted by x186_call_arguments when
# any source is transient; multi-results are modelled as simultaneous writes.
@unsafe
def x190_l_args(args: List<&2,N111Arg>, +ids: KDef) -> U32:
  match args:
    case Nil{}: 0
    case Con{N111Arg{typ,value},rest}: U32.or(x190_l_value(value,ids),x190_l_args(rest,ids))

@unsafe
def x190_l_block(rows: List<&2,U32>, +blocked: U32, +bit: U32) -> List<&2,U32>:
  match rows:
    case Nil{}: []
    case Con{row,rest}: Con{U32.or(row,U32.and(blocked,bit)),x190_l_block(rest,blocked,U32.shl(bit))}

@unsafe
def x190_l_call(reads: U32, +writes: U32, flow: X190LFlow, +env: X190LEnv) -> X190LFlow:
  match flow env:
    case X190LFlow{+live,+graph} X190LEnv{ids,parameters,header,collect}:
      x190_l_event(reads,writes,X190LFlow{live,nt_choose(List<&2,U32>,collect,
        u => x190_l_block(graph,U32.and(live,U32.not(writes)),1),u => graph)},env)

law x190_l_body:
  for body: List<&2,P113DStmt>
  for +flow: X190LFlow
  for +env: X190LEnv
  X190LFlow

@unsafe
def x190_l_join(condition: N111Value, no: List<&2,P113DStmt>, +after: U32,
    +env: X190LEnv, yes: X190LFlow) -> X190LFlow:
  match env yes:
    case X190LEnv{+ids,parameters,header,collect} X190LFlow{live,graph}:
      x190_l_joined(x190_l_value(condition,ids),live,env,x190_l_body(no,X190LFlow{after,graph},env))

@unsafe
def x190_l_joined(reads: U32, yes: U32, env: X190LEnv, no: X190LFlow) -> X190LFlow:
  match no:
    case X190LFlow{live,graph}: x190_l_event(U32.or(reads,yes),0,X190LFlow{live,graph},env)

@unsafe
def x190_l_if(condition: N111Value, yes: List<&2,P113DStmt>, no: List<&2,P113DStmt>,
    flow: X190LFlow, +env: X190LEnv) -> X190LFlow:
  match flow:
    case X190LFlow{+live,graph}: x190_l_join(condition,no,live,env,x190_l_body(yes,X190LFlow{live,graph},env))

@unsafe
def x190_l_terminal(reads: U32, flow: X190LFlow, env: X190LEnv) -> X190LFlow:
  match flow:
    case X190LFlow{live,graph}: x190_l_event(reads,0,X190LFlow{0,graph},env)

@unsafe
def x190_l_again(values: List<&2,N111Value>, flow: X190LFlow, +env: X190LEnv) -> X190LFlow:
  match flow env:
    case X190LFlow{live,graph} X190LEnv{ids,+parameters,header,collect}:
      x190_l_event(x190_l_values(values,ids),parameters,X190LFlow{U32.or(header,parameters),graph},env)

@unsafe
def x190_l_inline(operation: X186InlineOp, reads: U32, writes: U32, flow: X190LFlow, +env: X190LEnv) -> X190LFlow:
  match operation env:
    case X186InlineF32{name,id,buffer} X190LEnv{+ids,parameters,header,collect}:
      x190_l_event(x190_l_bit(buffer,ids),x190_l_bit(name,ids),flow,env)
    case _ _: x190_l_call(reads,writes,flow,env)

@unsafe
def x190_l_scalar_ids(+stmt: N111Stmt, +flow: X190LFlow, +env: X190LEnv, +ids: KDef) -> X190LFlow:
  match stmt:
    case N111Set{name,typ,value}: x190_l_event(x190_l_value(value,ids),x190_l_bit(name,ids),flow,env)
    case N111Bin{name,typ,op,left,right}:
      x190_l_event(U32.or(x190_l_value(left,ids),x190_l_value(right,ids)),x190_l_bit(name,ids),flow,env)
    case N111Load{name,typ,base,offset}: x190_l_event(x190_l_value(base,ids),x190_l_bit(name,ids),flow,env)
    case N111Store{typ,base,offset,value}: x190_l_event(U32.or(x190_l_value(base,ids),x190_l_value(value,ids)),0,flow,env)
    case N111Offset{name,base,bytes}:
      x190_l_event(U32.or(x190_l_value(base,ids),x190_l_value(bytes,ids)),x190_l_bit(name,ids),flow,env)
    case N111Alloca{name,bytes,align}: flow
    case N111Return{value}: x190_l_terminal(x190_l_value(value,ids),flow,env)
    case N111If{condition,yes,no}: x190_l_if(condition,x181_scalar_rows(yes),x181_scalar_rows(no),flow,env)
    case N111Call{name,typ,symbol,args}:
      x190_l_inline(x186_inline_op(stmt),x190_l_args(args,ids),x190_l_bit(name,ids),flow,env)

@unsafe
def x190_l_scalar(stmt: N111Stmt, flow: X190LFlow, +env: X190LEnv) -> X190LFlow:
  match env:
    case X190LEnv{ids,parameters,header,collect}: x190_l_scalar_ids(stmt,flow,env,ids)

@unsafe
def x190_l_stmt(stmt: P113DStmt, +flow: X190LFlow, +env: X190LEnv) -> X190LFlow:
  match stmt env:
    case P113DScalar{scalar} _: x190_l_scalar(scalar,flow,env)
    case P113DIf{condition,yes,no} _: x190_l_if(condition,yes,no,flow,env)
    case P113DResult{values} X190LEnv{ids,parameters,header,collect}: x190_l_terminal(x190_l_values(values,ids),flow,env)
    case P113DAgain{values} _: x190_l_again(values,flow,env)
    case P113DCall{names,target,args} X190LEnv{+ids,parameters,header,collect}:
      x190_l_call(x190_l_values(args,ids),x190_l_names(names,ids),flow,env)

@unsafe
def x190_l_body(body,flow,env):
  match body:
    case Nil{}: flow
    case Con{head,rest}: x190_l_stmt(head,x190_l_body(rest,flow,env),env)

law x190_l_fixed:
  for +body: List<&2,P113DStmt>
  for +ids: KDef
  for +parameters: U32
  for +header: U32
  for +fuel: U32
  X190LFixed

@unsafe
def x190_l_fixed_step(+body: List<&2,P113DStmt>, +ids: KDef, +parameters: U32,
    +header: U32, +fuel: U32, flow: X190LFlow) -> X190LFixed:
  match flow:
    case X190LFlow{+live,graph}:
      nt_choose(X190LFixed,U32.is_eq(live,header),u => X190LFixed{header,True{}},
        u => x190_l_fixed(body,ids,parameters,U32.or(header,live),U32.sub(fuel,1)))

@unsafe
def x190_l_fixed(body,ids,parameters,header,fuel):
  nt_choose(X190LFixed,U32.is_eq(fuel,0),u => X190LFixed{header,False{}},u =>
    x190_l_fixed_step(body,ids,parameters,header,fuel,x190_l_body(body,X190LFlow{0,[]},X190LEnv{ids,parameters,header,False{}})))

@unsafe
def x190_l_zeros(names: List<&2,String>) -> List<&2,U32>:
  match names:
    case Nil{}: []
    case Con{name,rest}: Con{0,x190_l_zeros(rest)}

@unsafe
def x190_l_incoming(params: List<&2,String>, flow: X190LFlow, +env: X190LEnv) -> X190LFlow:
  match params env:
    case Nil{} _: flow
    case Con{name,rest} X190LEnv{+ids,parameters,header,collect}:
      x190_l_event(0,x190_l_bit(name,ids),x190_l_incoming(rest,flow,env),env)

# Prologue copies read ABI arguments in order. A candidate parameter may use
# only a source register already consumed at that point. Nonparameters begin
# after the prologue and have no such restriction.
@unsafe
def x190_l_position(+name: String, params: List<&2,String>, +index: U32) -> U32:
  match params:
    case Nil{}: 4294967295
    case Con{head,rest}: nt_choose(U32,String.eq(name,head),u => index,u => x190_l_position(name,rest,U32.inc(index)))

def x190_l_abi(register: U32) -> U32:
  match register:
    case 0: 0
    case 1: 1
    case 2: 2
    case 3: 4
    case _: 5

@unsafe
def x190_l_pick(groups: List<&2,U32>, +edges: U32, +position: U32, +register: U32) -> U32:
  match groups:
    case Nil{}: 5
    case Con{mask,rest}:
      nt_choose(U32,U32.is_eq(U32.and(mask,edges),0) && U32.is_ge(position,x190_l_abi(register)),
        u => register,u => x190_l_pick(rest,edges,position,U32.inc(register)))

@unsafe
def x190_l_group(groups: List<&2,U32>, +register: U32, +bit: U32) -> List<&2,U32>:
  match groups:
    case Nil{}: []
    case Con{+mask,+rest}: nt_choose(List<&2,U32>,U32.is_eq(register,0),
      u => Con{U32.or(mask,bit),rest},u => Con{mask,x190_l_group(rest,U32.sub(register,1),bit)})

@unsafe
def x190_l_color(names: List<&2,String>, rows: List<&2,U32>, +params: List<&2,String>,
    +bit: U32, +groups: List<&2,U32>) -> List<&2,U32>:
  match names rows:
    case Con{name,rest} Con{+edges,more}:
      x190_l_color(rest,more,params,U32.shl(bit),
        nt_choose(List<&2,U32>,U32.is_eq(U32.and(bit,edges),0),
          u => x190_l_group(groups,x190_l_pick(groups,edges,x190_l_position(name,params,0),0),bit),u => groups))
    case _ _: groups

# A separate post-color check rejects location conflicts, duplicate group
# membership and incoming ABI violations before changing any frame slot.
@unsafe
def x190_l_valid_groups(groups: List<&2,U32>, +bit: U32, +edges: U32,
    +position: U32, +register: U32, +seen: Bool) -> Bool:
  match groups:
    case Nil{}: True{}
    case Con{+mask,rest}:
      +here = Bool.not(U32.is_eq(U32.and(mask,bit),0))
      (Bool.not(here) || (Bool.not(seen) && U32.is_eq(U32.and(mask,edges),0) && U32.is_ge(position,x190_l_abi(register)))) &&
        x190_l_valid_groups(rest,bit,edges,position,U32.inc(register),seen || here)

@unsafe
def x190_l_valid(names: List<&2,String>, rows: List<&2,U32>, +params: List<&2,String>,
    +bit: U32, +groups: List<&2,U32>) -> Bool:
  match names rows:
    case Nil{} Nil{}: True{}
    case Con{name,rest} Con{edges,more}:
      x190_l_valid_groups(groups,bit,edges,x190_l_position(name,params,0),0,False{}) &&
        x190_l_valid(rest,more,params,U32.shl(bit),groups)
    case _ _: False{}

@unsafe
def x190_l_home(groups: List<&2,U32>, +bit: U32, +register: U32) -> U32:
  match groups:
    case Nil{}: 5
    case Con{mask,rest}: nt_choose(U32,U32.is_eq(U32.and(mask,bit),0),
      u => x190_l_home(rest,bit,U32.inc(register)),u => register)

@unsafe
def x190_l_install(names: List<&2,String>, +groups: List<&2,U32>, +bit: U32, +frame: X181Frame) -> X181Frame:
  match names:
    case Nil{}: frame
    case Con{+name,rest}:
      +register = x190_l_home(groups,bit,0)
      x190_l_install(rest,groups,U32.shl(bit),nt_choose(X181Frame,U32.is_lt(register,5),
        u => x185_t_install(name,register,frame),u => frame))

@unsafe
def x190_l_checked(+frame: X181Frame, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +names: List<&2,String>, +rows: List<&2,U32>, +groups: List<&2,U32>) -> X181Frame:
  nt_choose(X181Frame,x190_l_valid(names,rows,params,1,groups),
    u => x190_l_install(names,groups,1,frame),u => x185_transient_frame(frame,params,setup,body))

@unsafe
def x190_l_graphed(frame: X181Frame, +params: List<&2,String>, setup: List<&2,P113DStmt>,
    body: List<&2,P113DStmt>, +names: List<&2,String>, flow: X190LFlow) -> X181Frame:
  match flow:
    case X190LFlow{live,+graph}:
      x190_l_checked(frame,params,setup,body,names,graph,x190_l_color(names,graph,params,1,[0,0,0,0,0]))

@unsafe
def x190_l_solved(+frame: X181Frame, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +names: List<&2,String>, +ids: KDef, +parameters: U32, fixed: X190LFixed) -> X181Frame:
  match fixed:
    case X190LFixed{+header,ready}:
      +env: X190LEnv = X190LEnv{ids,parameters,header,True{}}
      nt_choose(X181Frame,ready,u => x190_l_graphed(frame,params,setup,body,names,
        x190_l_incoming(params,x190_l_body(setup,x190_l_body(body,X190LFlow{0,x190_l_zeros(names)},env),env),env)),
        u => x185_transient_frame(frame,params,setup,body))

@unsafe
def x190_l_selected(+frame: X181Frame, +params: List<&2,String>, setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, candidates: X190LCandidates) -> X181Frame:
  match candidates:
    case X190LCandidates{names,+ids}:
      +parameters = x190_l_names(x181_tail_args(frame),ids)
      x190_l_solved(frame,params,setup,body,names,ids,parameters,x190_l_fixed(body,ids,parameters,0,33))

@unsafe
def x190_l_counted(+frame: X181Frame, params: List<&2,String>, setup: List<&2,P113DStmt>,
    body: List<&2,P113DStmt>, counts: X181ReadCounts) -> X181Frame:
  match frame counts:
    case X181Frame{slots,bytes,calls,words,symbol} X181ReadCounts{reads,names}:
      x190_l_selected(frame,params,setup,body,x190_l_candidates(nt_reverse(String,names,[]),reads,slots,1,32,missing(),[]))

@unsafe
def x190_liveness_frame(+frame: X181Frame, +params: List<&2,String>, +setup: List<&2,P113DStmt>, +body: List<&2,P113DStmt>) -> X181Frame:
  nt_choose(X181Frame,x190_liveness_enabled() && U32.is_le(p113i_add(p113i_size(setup),p113i_size(body)),256) &&
      U32.is_le(nt_count(String,params),64) && x190_l_safe_body(setup) && x190_l_safe_body(body),
    u => x190_l_counted(frame,params,setup,body,x181_reads_stmts(setup,x181_reads_stmts(body,X181ReadCounts{missing(),[]}))),
    u => x185_transient_frame(frame,params,setup,body))

# Optional joint coloring starts from x181_frame, before fixed placement.
# Colors 0..3 are saved homes 1..4; colors 4..8 are the five caller homes.
# The same graph controls both pools. A self edge is a call-clobber marker,
# removed only when considering a callee-saved color; all other edges survive.
def x190_joint_registers_enabled() -> Bool: True{}

def x190_j_edges(+bit: U32, +edges: U32, color: U32) -> U32:
  nt_choose(U32,U32.is_lt(color,4),u => U32.and(edges,U32.not(bit)),u => edges)

def x190_j_allowed(bit: U32, edges: U32, position: U32, +color: U32) -> Bool:
  nt_choose(Bool,U32.is_lt(color,4),u => True{},u =>
    U32.is_lt(color,9) && U32.is_eq(U32.and(bit,edges),0) && U32.is_ge(position,x190_l_abi(U32.sub(color,4))))

@unsafe
def x190_j_pick(groups: List<&2,U32>, +bit: U32, +edges: U32, +position: U32, +color: U32) -> U32:
  match groups:
    case Nil{}: 9
    case Con{mask,rest}:
      nt_choose(U32,x190_j_allowed(bit,edges,position,color) &&
          U32.is_eq(U32.and(mask,x190_j_edges(bit,edges,color)),0),
        u => color,u => x190_j_pick(rest,bit,edges,position,U32.inc(color)))

def x190_caller_first_enabled() -> Bool: True{}

@unsafe
def x190_j_callers(groups: List<&2,U32>) -> List<&2,U32>:
  match groups:
    case Con{a,Con{b,Con{c,Con{d,rest}}}}: rest
    case _: []

@unsafe
def x190_j_choose(+groups: List<&2,U32>, +bit: U32, +edges: U32, +position: U32, enabled: Bool) -> U32:
  +caller = nt_choose(U32,enabled,u => x190_j_pick(x190_j_callers(groups),bit,edges,position,4),u => 9)
  nt_choose(U32,U32.is_lt(caller,9),u => caller,u => x190_j_pick(groups,bit,edges,position,0))

@unsafe
def x190_j_color(names: List<&2,String>, rows: List<&2,U32>, +params: List<&2,String>,
    +bit: U32, +groups: List<&2,U32>) -> List<&2,U32>:
  match names rows:
    case Con{name,rest} Con{edges,more}:
      x190_j_color(rest,more,params,U32.shl(bit),
        x190_l_group(groups,x190_j_choose(groups,bit,edges,x190_l_position(name,params,0),x190_caller_first_enabled()),bit))
    case _ _: groups

# Affinities only choose among already legal colors; they never merge names
# or alter interference. A narrow copy may share a dead source, while the
# unchanged write/live-out edges prevent truncating a source that survives.
def x190_coalescing_enabled() -> Bool: True{}

@unsafe
def x190_a_pair(+name: String, value: N111Value, +ids: KDef, +affinities: KDef) -> KDef:
  match value:
    case N111Local{+source}:
      +destinationBit = x190_l_bit(name,ids)
      +sourceBit = x190_l_bit(source,ids)
      nt_choose(KDef,U32.is_gt(destinationBit,0) && U32.is_gt(sourceBit,0),u =>
        p111v_put(p111v_put(affinities,name,"X190Affinity",U32.or(da(p111v_get(affinities,name)),sourceBit),0),
          source,"X190Affinity",U32.or(da(p111v_get(affinities,source)),destinationBit),0),u => affinities)
    case _: affinities

@unsafe
def x190_a_tail(params: List<&2,String>, values: List<&2,N111Value>, +ids: KDef, affinities: KDef) -> KDef:
  match params values:
    case Con{name,rest} Con{value,more}: x190_a_tail(rest,more,ids,x190_a_pair(name,value,ids,affinities))
    case _ _: affinities

@unsafe
def x190_a_body(body: List<&2,P113DStmt>, +ids: KDef, +params: List<&2,String>, affinities: KDef) -> KDef:
  match body:
    case Nil{}: affinities
    case Con{P113DScalar{N111Set{name,typ,value}},rest}:
      x190_a_body(rest,ids,params,x190_a_pair(name,value,ids,affinities))
    case Con{P113DScalar{N111If{condition,yes,no}},rest}:
      x190_a_body(rest,ids,params,x190_a_body(x181_scalar_rows(no),ids,params,
        x190_a_body(x181_scalar_rows(yes),ids,params,affinities)))
    case Con{P113DIf{condition,yes,no},rest}:
      x190_a_body(rest,ids,params,x190_a_body(no,ids,params,x190_a_body(yes,ids,params,affinities)))
    case Con{P113DAgain{values},rest}: x190_a_body(rest,ids,params,x190_a_tail(params,values,ids,affinities))
    case Con{head,rest}: x190_a_body(rest,ids,params,affinities)

@unsafe
def x190_a_pick(groups: List<&2,U32>, +partners: U32, +bit: U32, +edges: U32, +position: U32, +color: U32) -> U32:
  match groups:
    case Nil{}: 9
    case Con{+mask,rest}:
      nt_choose(U32,Bool.not(U32.is_eq(U32.and(mask,partners),0)) && x190_j_allowed(bit,edges,position,color) &&
          U32.is_eq(U32.and(mask,x190_j_edges(bit,edges,color)),0),
        u => color,u => x190_a_pick(rest,partners,bit,edges,position,U32.inc(color)))

@unsafe
def x190_a_choose(+groups: List<&2,U32>, partners: U32, +bit: U32, +edges: U32, +position: U32) -> U32:
  +preferred = x190_a_pick(groups,partners,bit,edges,position,0)
  nt_choose(U32,U32.is_lt(preferred,9),u => preferred,
    u => x190_j_choose(groups,bit,edges,position,x190_caller_first_enabled()))

@unsafe
def x190_a_color(names: List<&2,String>, rows: List<&2,U32>, +params: List<&2,String>,
    +bit: U32, +groups: List<&2,U32>, +affinities: KDef) -> List<&2,U32>:
  match names rows:
    case Con{+name,rest} Con{edges,more}:
      x190_a_color(rest,more,params,U32.shl(bit),
        x190_l_group(groups,x190_a_choose(groups,da(p111v_get(affinities,name)),bit,edges,x190_l_position(name,params,0)),bit),affinities)
    case _ _: groups

@unsafe
def x190_j_valid_groups(groups: List<&2,U32>, +bit: U32, +edges: U32,
    +position: U32, +color: U32, +seen: Bool) -> Bool:
  match groups:
    case Nil{}: True{}
    case Con{+mask,rest}:
      +here = Bool.not(U32.is_eq(U32.and(mask,bit),0))
      (Bool.not(here) || (Bool.not(seen) && x190_j_allowed(bit,edges,position,color) &&
        U32.is_eq(U32.and(mask,x190_j_edges(bit,edges,color)),0))) &&
          x190_j_valid_groups(rest,bit,edges,position,U32.inc(color),seen || here)

@unsafe
def x190_j_valid(names: List<&2,String>, rows: List<&2,U32>, +params: List<&2,String>,
    +bit: U32, +groups: List<&2,U32>) -> Bool:
  match names rows:
    case Nil{} Nil{}: U32.is_eq(nt_count(U32,groups),9)
    case Con{name,rest} Con{edges,more}:
      x190_j_valid_groups(groups,bit,edges,x190_l_position(name,params,0),0,False{}) &&
        x190_j_valid(rest,more,params,U32.shl(bit),groups)
    case _ _: False{}

@unsafe
def x190_j_home(groups: List<&2,U32>, +bit: U32, +color: U32) -> U32:
  match groups:
    case Nil{}: 9
    case Con{mask,rest}: nt_choose(U32,U32.is_eq(U32.and(mask,bit),0),
      u => x190_j_home(rest,bit,U32.inc(color)),u => color)

@unsafe
def x190_j_install(names: List<&2,String>, +groups: List<&2,U32>, +bit: U32, +frame: X181Frame) -> X181Frame:
  match names:
    case Nil{}: frame
    case Con{+name,rest}:
      +color = x190_j_home(groups,bit,0)
      x190_j_install(rest,groups,U32.shl(bit),nt_choose(X181Frame,U32.is_lt(color,4),
        u => x181_register_install(name,U32.inc(color),frame),u =>
          nt_choose(X181Frame,U32.is_lt(color,9),v => x185_t_install(name,U32.sub(color,4),frame),v => frame)))

# Every refusal returns through the complete previous allocator, including its
# saved-home selection. Never leave a fresh stack-only frame on a joint refusal.
@unsafe
def x190_allocate_legacy(frame: X181Frame, params: List<&2,String>, setup: List<&2,P113DStmt>,
    body: List<&2,P113DStmt>, registerBody: List<&2,P113DStmt>) -> X181Frame:
  x190_liveness_frame(x181_register_frame(frame,registerBody),params,setup,body)

@unsafe
def x190_j_checked(+frame: X181Frame, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +registerBody: List<&2,P113DStmt>, +names: List<&2,String>,
    +rows: List<&2,U32>, +groups: List<&2,U32>) -> X181Frame:
  nt_choose(X181Frame,x190_j_valid(names,rows,params,1,groups),
    u => x190_j_install(names,groups,1,frame),u => x190_allocate_legacy(frame,params,setup,body,registerBody))

@unsafe
def x190_j_graphed(+frame: X181Frame, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, registerBody: List<&2,P113DStmt>, +names: List<&2,String>, +ids: KDef, flow: X190LFlow) -> X181Frame:
  match flow:
    case X190LFlow{live,+graph}:
      x190_j_checked(frame,params,setup,body,registerBody,names,graph,
        nt_choose(List<&2,U32>,x190_coalescing_enabled(),u =>
          x190_a_color(names,graph,params,1,[0,0,0,0,0,0,0,0,0],
            x190_a_body(body,ids,x181_tail_args(frame),x190_a_body(setup,ids,x181_tail_args(frame),missing()))),
          u => x190_j_color(names,graph,params,1,[0,0,0,0,0,0,0,0,0])))

@unsafe
def x190_j_solved(+frame: X181Frame, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +registerBody: List<&2,P113DStmt>, +names: List<&2,String>,
    +ids: KDef, +parameters: U32, fixed: X190LFixed) -> X181Frame:
  match fixed:
    case X190LFixed{+header,ready}:
      +env: X190LEnv = X190LEnv{ids,parameters,header,True{}}
      nt_choose(X181Frame,ready,u => x190_j_graphed(frame,params,setup,body,registerBody,names,ids,
        x190_l_incoming(params,x190_l_body(setup,x190_l_body(body,X190LFlow{0,x190_l_zeros(names)},env),env),env)),
        u => x190_allocate_legacy(frame,params,setup,body,registerBody))

@unsafe
def x190_j_selected(+frame: X181Frame, +params: List<&2,String>, setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, registerBody: List<&2,P113DStmt>, candidates: X190LCandidates) -> X181Frame:
  match candidates:
    case X190LCandidates{names,+ids}:
      +parameters = x190_l_names(x181_tail_args(frame),ids)
      x190_j_solved(frame,params,setup,body,registerBody,names,ids,parameters,x190_l_fixed(body,ids,parameters,0,33))

@unsafe
def x190_j_counted(+frame: X181Frame, params: List<&2,String>, setup: List<&2,P113DStmt>,
    body: List<&2,P113DStmt>, registerBody: List<&2,P113DStmt>, counts: X181ReadCounts) -> X181Frame:
  match frame counts:
    case X181Frame{slots,bytes,calls,words,symbol} X181ReadCounts{reads,names}:
      x190_j_selected(frame,params,setup,body,registerBody,
        x190_l_candidates(nt_reverse(String,names,[]),reads,slots,1,32,missing(),[]))

# Prefer repeated body uses over once-only setup reads when admitting the
# bounded candidate set. This changes priority only, never graph legality.
@unsafe
def x190_j_weighted(reads: X181ReadCounts) -> X181ReadCounts:
  match reads:
    case X181ReadCounts{counts,+names}:
      X181ReadCounts{x190_register_scores(names,missing(),[],1,counts),names}

@unsafe
def x190_joint_frame(+frame: X181Frame, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +registerBody: List<&2,P113DStmt>) -> X181Frame:
  nt_choose(X181Frame,U32.is_le(p113i_add(p113i_size(setup),p113i_size(body)),256) &&
      U32.is_le(nt_count(String,params),64) && x190_l_safe_body(setup) && x190_l_safe_body(body),
    u => x190_j_counted(frame,params,setup,body,registerBody,
      x181_reads_stmts(setup,x190_j_weighted(x181_reads_stmts(body,X181ReadCounts{missing(),[]})))),
    u => x190_allocate_legacy(frame,params,setup,body,registerBody))

@unsafe
def x190_allocate_frame(+frame: X181Frame, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +registerBody: List<&2,P113DStmt>) -> X181Frame:
  nt_choose(X181Frame,x190_joint_registers_enabled(),
    u => x190_joint_frame(frame,params,setup,body,registerBody),
    u => x190_allocate_legacy(frame,params,setup,body,registerBody))
