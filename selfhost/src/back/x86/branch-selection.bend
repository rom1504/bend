# Adjacent comparison/branch selection over the complete function's local
# read/write facts. The original single-use rule remains the fast path. An
# optional bounded certificate admits repeated names only when every read is
# paired with its own adjacent comparison. Parameters/setup stay protected;
# continuations, branch arms and Again arguments all contribute to read counts.
type X190BranchFacts is Data:
  X190BranchFacts{+reads: KDef, +writes: KDef, +pairs: KDef, +protected: KDef}

def x190_branch_enabled() -> Bool: True{}
def x190_branch_reuse_enabled() -> Bool: True{}
def x190_branch_complements_enabled() -> Bool: True{}

def x190_branch_width(typ: N111Type) -> Bool:
  match typ:
    case N111U32{}: True{}
    case N111U64{}: True{}
    case _: False{}

@unsafe
def x190_branch_shape(+name: String, typ: N111Type, op: String, condition: N111Value) -> Bool:
  match condition:
    case N111Local{other}:
      String.eq(name,other) && x190_branch_width(typ) && Bool.not(x181_register_reserved(name)) &&
        Bool.not(String.is_empty(x181_condition(op)))
    case _: False{}

# Count a subset of actual reads: each is a branch immediately preceded by
# the comparison defining its condition. Scan every original node once, also
# descending into both arms; counting a pair never skips the branch's body.
@unsafe
def x190_branch_pair_record(+name: String, +pairs: KDef) -> KDef:
  p111v_put(pairs,name,"X190BranchPairs",x181_read_increment(da(p111v_get(pairs,name))),0)

@unsafe
def x190_branch_pair(body: List<&2,P113DStmt>, +pairs: KDef) -> KDef:
  match body:
    case Con{P113DScalar{N111Bin{+name,typ,op,left,right}},Con{P113DIf{condition,yes,no},rest}}:
      nt_choose(KDef,x190_branch_shape(name,typ,op,condition),u => x190_branch_pair_record(name,pairs),u => pairs)
    case Con{P113DScalar{N111Bin{+name,typ,op,left,right}},Con{P113DScalar{N111If{condition,yes,no}},rest}}:
      nt_choose(KDef,x190_branch_shape(name,typ,op,condition),u => x190_branch_pair_record(name,pairs),u => pairs)
    case _: pairs

law x190_branch_pairs:
  for +body: List<&2,P113DStmt>
  for pairs: KDef
  KDef

@unsafe
def x190_branch_pairs_stmt(stmt: P113DStmt, pairs: KDef) -> KDef:
  match stmt:
    case P113DIf{condition,yes,no}: x190_branch_pairs(no,x190_branch_pairs(yes,pairs))
    case P113DScalar{N111If{condition,yes,no}}:
      x190_branch_pairs(x181_scalar_rows(no),x190_branch_pairs(x181_scalar_rows(yes),pairs))
    case _: pairs

@unsafe
def x190_branch_pairs(body,pairs):
  match body:
    case Nil{}: pairs
    case Con{head,rest}: x190_branch_pairs(rest,x190_branch_pairs_stmt(head,x190_branch_pair(body,pairs)))

@unsafe
def x190_branch_counted(reads: X181ReadCounts, writes: KDef, pairs: KDef, protected: KDef) -> X190BranchFacts:
  match reads:
    case X181ReadCounts{counts,names}: X190BranchFacts{counts,writes,pairs,protected}

@unsafe
def x190_branch_facts_when(+reuse: Bool, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>) -> X190BranchFacts:
  nt_choose(X190BranchFacts,x190_branch_enabled(),u =>
    x190_branch_counted(x181_reads_stmts(body,x181_reads_stmts(setup,X181ReadCounts{missing(),[]})),
      x185_copy_writes(body,x185_copy_writes(setup,x185_copy_writes_names(params,missing()))),
      nt_choose(KDef,reuse && U32.is_lt(p113i_size(body),4096),
        v => x190_branch_pairs(body,missing()),v => missing()),
      nt_choose(KDef,reuse,v => x185_copy_writes(setup,x185_copy_writes_names(params,missing())),v => missing())),
    u => X190BranchFacts{missing(),missing(),missing(),missing()})

@unsafe
def x190_branch_facts(params: List<&2,String>, setup: List<&2,P113DStmt>, body: List<&2,P113DStmt>) -> X190BranchFacts:
  x190_branch_facts_when(x190_branch_reuse_enabled(),params,setup,body)

# Equality between total reads and paired-condition reads is a global use
# certificate: every observable read has its own immediately preceding
# comparison. This remains true through nested branches and Again. Any use in
# an operand, continuation, call, result or backedge adds an unpaired read and
# refuses reuse. Extra writes are harmless because every read has a fresh
# paired producer. Parameter/setup/reserved names remain excluded explicitly.
@unsafe
def x190_branch_allowed_when(reuse: Bool, +name: String, typ: N111Type, op: String,
    condition: N111Value, facts: X190BranchFacts) -> Bool:
  match facts:
    case X190BranchFacts{reads,writes,pairs,protected}:
      +count = da(p111v_get(reads,name))
      +paired = da(p111v_get(pairs,name))
      x190_branch_enabled() && x190_branch_shape(name,typ,op,condition) &&
        ((U32.is_eq(count,1) && U32.is_eq(da(p111v_get(writes,name)),1)) ||
          (reuse && U32.is_gt(paired,0) && U32.is_eq(count,paired) &&
            U32.is_eq(da(p111v_get(protected,name)),0)))

@unsafe
def x190_branch_allowed(name: String, typ: N111Type, op: String,
    condition: N111Value, facts: X190BranchFacts) -> Bool:
  x190_branch_allowed_when(x190_branch_reuse_enabled(),name,typ,op,condition,facts)

# The existing layout falls through to yes and jumps to no. Invert the exact
# signed/unsigned predicate; no complementary-condition or dominance inference.
@unsafe
def x190_branch_inverse(+op: String) -> String:
  nt_choose(String,String.eq(op,"eq"),u => "jne",u =>
  nt_choose(String,String.eq(op,"ne"),u => "je",u =>
  nt_choose(String,String.eq(op,"ult"),u => "jae",u =>
  nt_choose(String,String.eq(op,"ule"),u => "ja",u =>
  nt_choose(String,String.eq(op,"ugt"),u => "jbe",u =>
  nt_choose(String,String.eq(op,"uge"),u => "jb",u =>
  nt_choose(String,String.eq(op,"slt"),u => "jge",u =>
  nt_choose(String,String.eq(op,"sle"),u => "jg",u =>
  nt_choose(String,String.eq(op,"sgt"),u => "jle",u =>
  nt_choose(String,String.eq(op,"sge"),u => "jl",u => ""))))))))))

@unsafe
def x190_branch_immediate_to(+typ: N111Type, value: N111Value, destination: X187Operand) -> X188Seq:
  match value:
    case N111Const{+lo,hi}:
      nt_choose(X188Seq,U32.is_eq(hi,0) &&
          (U32.is_eq(p111v_type(typ),1) || U32.is_le(lo,2147483647)),
        u => x188_i2(x181_width(typ,"cmpq","cmpl"),X187Imm{lo,0},destination),
        u => X188Empty{})
    case _: X188Empty{}

@unsafe
def x190_branch_immediate(+typ: N111Type, value: N111Value) -> X188Seq:
  x190_branch_immediate_to(typ,value,x188_width_reg(typ,10))

def x190_branch_operand(typ: N111Type, physical: X185Physical, fallback: X187Operand) -> X187Operand:
  match physical:
    case X185Physical{wide,narrow,byte}: x188_physical_width(typ,wide,narrow)
    case _: fallback

@unsafe
def x190_branch_load(value: N111Value, ids: N111Ids, frame: X181Frame, physical: X185Physical, scratch: X187Operand) -> X188Seq:
  match physical:
    case X185Physical{wide,narrow,byte}: X188Empty{}
    case _: x181_load(value,ids,frame,scratch)

# Comparisons preserve both physical operands, including equal homes. Unknown
# operands use distinct reserved scratch registers outside the allocated pool.
@unsafe
def x190_branch_test(+typ: N111Type, op: String, +left: N111Value, +right: N111Value,
    label: U32, +ids: N111Ids, +frame: X181Frame) -> X188Seq:
  +lh = nt_choose(X185Physical,x190_operands_enabled(),u => x190_value_home(left,frame),u => X185PhysicalNone{})
  +rh = nt_choose(X185Physical,x190_operands_enabled(),u => x190_value_home(right,frame),u => X185PhysicalNone{})
  +destination = x190_branch_operand(typ,lh,x188_width_reg(typ,10))
  +immediate = nt_choose(X188Seq,x185_machine_enabled(),u => x190_branch_immediate_to(typ,right,destination),u => X188Empty{})
  x188_many([x190_branch_load(left,ids,frame,lh,x188_reg(10,64)),
    nt_choose(X188Seq,x188_empty(immediate),u =>
      x188_cat(x190_branch_load(right,ids,frame,rh,x188_reg(11,64)),
        x188_i2(x181_width(typ,"cmpq","cmpl"),x190_branch_operand(typ,rh,x188_width_reg(typ,11)),destination)),u => immediate),
    x188_i1(x190_branch_inverse(op),X187Target{x181_label(label,frame)})])

law x190_stmts:
  for body: List<&2,P113DStmt>
  for +facts: X190BranchFacts
  for +ids: N111Ids
  for +frame: X181Frame
  for +code: X181Code
  X181Code

@unsafe
def x190_if_prefix(prefix: X188Seq, yes: List<&2,P113DStmt>, no: List<&2,P113DStmt>,
    +facts: X190BranchFacts, +ids: N111Ids, +frame: X181Frame, code: X181Code) -> X181Code:
  match code:
    case X181Code{chunks,+next,terminal,error}:
      x190_if_yes(next,no,facts,ids,frame,x190_stmts(yes,facts,ids,frame,
        X181Code{Con{prefix,chunks},U32.add(next,2),False{},error}))

@unsafe
def x190_if_yes(+label: U32, no: List<&2,P113DStmt>, facts: X190BranchFacts,
    ids: N111Ids, +frame: X181Frame, yes: X181Code) -> X181Code:
  match yes:
    case X181Code{chunks,next,+terminal,error}:
      x181_if_end(label,terminal,frame,x190_stmts(no,facts,ids,frame,
        X181Code{Con{x188_cat(nt_choose(X188Seq,terminal,u => X188Empty{},
          u => x188_i1("jmp",X187Target{x181_label(U32.inc(label),frame)})),
          x188_label(x181_label(label,frame))),chunks},next,False{},error}))

@unsafe
def x190_if(condition: N111Value, yes: List<&2,P113DStmt>, no: List<&2,P113DStmt>,
    facts: X190BranchFacts, +ids: N111Ids, +frame: X181Frame, +code: X181Code) -> X181Code:
  match code:
    case X181Code{chunks,next,terminal,error}:
      x190_if_prefix(x188_many([x181_load(condition,ids,frame,x188_reg(10,64)),
        x188_i2("testl",x188_reg(10,32),x188_reg(10,32)),
        x188_i1("jz",X187Target{x181_label(next,frame)})]),yes,no,facts,ids,frame,code)

# A chosen terminal arm must not expose the original fallthrough continuation
# as statements after Return/Again. Inspect termination without rewriting IR.
@unsafe
def x190_branch_terminal(body: List<&2,P113DStmt>) -> Bool:
  match body:
    case Nil{}: False{}
    case Con{P113DResult{values},rest}: True{}
    case Con{P113DAgain{values},rest}: True{}
    case Con{P113DScalar{N111Return{value}},rest}: True{}
    case Con{P113DIf{condition,yes,no},rest}:
      (x190_branch_terminal(yes) && x190_branch_terminal(no)) || x190_branch_terminal(rest)
    case Con{P113DScalar{N111If{condition,yes,no}},rest}:
      (x190_branch_terminal(x181_scalar_rows(yes)) && x190_branch_terminal(x181_scalar_rows(no))) || x190_branch_terminal(rest)
    case Con{head,rest}: x190_branch_terminal(rest)

@unsafe
def x190_branch_append(+chosen: List<&2,P113DStmt>, rest: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  nt_choose(List<&2,P113DStmt>,x190_branch_terminal(chosen),u => chosen,u => nt_append(P113DStmt,chosen,rest))

# An arm begins immediately after the outer comparison. Exact typed operands
# have not changed, so an identical/complementary inner predicate is known.
# The inner Boolean may disappear only under the same global read certificate.
# This helper inspects one arm head and never recursively simplifies its result.
@unsafe
def x190_branch_arm_when(enabled: Bool, +typ: N111Type, +op: String,
    +left: N111Value, +right: N111Value, +truth: Bool, +arm: List<&2,P113DStmt>, +facts: X190BranchFacts) -> List<&2,P113DStmt>:
  match arm:
    case Con{P113DScalar{N111Bin{name,+innerType,+innerOp,a,b}},Con{P113DIf{condition,yes,no},rest}}:
      +same = String.eq(op,innerOp)
      nt_choose(List<&2,P113DStmt>,enabled && U32.is_eq(p111v_type(typ),p111v_type(innerType)) &&
          x186_e_equal(left,a) && x186_e_equal(right,b) &&
          (same || String.eq(x190_branch_inverse(op),"j" ++ x181_condition(innerOp))) &&
          x190_branch_allowed(name,innerType,innerOp,condition,facts),
        u => x190_branch_append(nt_choose(List<&2,P113DStmt>,Bool.not(Bool.xor(same,truth)),v => yes,v => no),rest),
        u => arm)
    case _: arm

@unsafe
def x190_branch_arm(typ: N111Type, op: String, left: N111Value, right: N111Value,
    truth: Bool, arm: List<&2,P113DStmt>, facts: X190BranchFacts) -> List<&2,P113DStmt>:
  x190_branch_arm_when(x190_branch_complements_enabled(),typ,op,left,right,truth,arm,facts)

@unsafe
def x190_fused_if(+typ: N111Type, +op: String, +left: N111Value, +right: N111Value,
    yes: List<&2,P113DStmt>, no: List<&2,P113DStmt>, +facts: X190BranchFacts,
    +ids: N111Ids, +frame: X181Frame, +code: X181Code) -> X181Code:
  match code:
    case X181Code{chunks,next,terminal,error}:
      x190_if_prefix(x190_branch_test(typ,op,left,right,next,ids,frame),
        x190_branch_arm(typ,op,left,right,True{},yes,facts),
        x190_branch_arm(typ,op,left,right,False{},no,facts),facts,ids,frame,code)

@unsafe
def x190_stmt(+stmt: P113DStmt, facts: X190BranchFacts, ids: N111Ids,
    frame: X181Frame, code: X181Code) -> X181Code:
  match stmt:
    case P113DIf{condition,yes,no}: x190_if(condition,yes,no,facts,ids,frame,code)
    case P113DScalar{N111If{condition,yes,no}}:
      x190_if(condition,x181_scalar_rows(yes),x181_scalar_rows(no),facts,ids,frame,code)
    case _: x181_stmt(stmt,ids,frame,code)

@unsafe
def x190_plain_step(body: List<&2,P113DStmt>, +facts: X190BranchFacts,
    +ids: N111Ids, +frame: X181Frame, code: X181Code) -> X181Code:
  match body:
    case Nil{}: code
    case Con{head,rest}: x190_stmts(rest,facts,ids,frame,x190_stmt(head,facts,ids,frame,code))

@unsafe
def x190_step(+body: List<&2,P113DStmt>, +facts: X190BranchFacts,
    +ids: N111Ids, +frame: X181Frame, +code: X181Code) -> X181Code:
  match body:
    case Con{P113DScalar{N111Bin{name,+typ,+op,left,right}},Con{P113DIf{condition,yes,no},rest}}:
      nt_choose(X181Code,x190_branch_allowed(name,typ,op,condition,facts),u =>
        x190_stmts(rest,facts,ids,frame,x190_fused_if(typ,op,left,right,yes,no,facts,ids,frame,code)),
        u => x190_plain_step(body,facts,ids,frame,code))
    case Con{P113DScalar{N111Bin{name,+typ,+op,left,right}},Con{P113DScalar{N111If{condition,yes,no}},rest}}:
      nt_choose(X181Code,x190_branch_allowed(name,typ,op,condition,facts),u =>
        x190_stmts(rest,facts,ids,frame,x190_fused_if(typ,op,left,right,
          x181_scalar_rows(yes),x181_scalar_rows(no),facts,ids,frame,code)),
        u => x190_plain_step(body,facts,ids,frame,code))
    case _: x190_plain_step(body,facts,ids,frame,code)

@unsafe
def x190_stmts(body,facts,ids,frame,code):
  match body code:
    case Nil{} _: code
    case _ X181Code{chunks,next,+terminal,+error}:
      nt_choose(X181Code,String.is_empty(error),u =>
        nt_choose(X181Code,terminal,u => x181_error("x86 statement after terminal",code),
          u => x190_step(body,facts,ids,frame,code)),u => code)
