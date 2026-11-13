# A private final-emission plan. The checked source IR remains P113DStmt;
# these nodes never enter the source verifier or integer value optimizers.
# Exact current scratch facts discharge the two memory reads of an admitted
# F32 operation. All other operations keep their original statement.
type X186FloatNode is Data:
  X186FloatPlain{+stmt: P113DStmt}
  X186FloatBranch{+condition: N111Value, +yes: List<&2,X186FloatNode>, +no: List<&2,X186FloatNode>}
  X186FloatValues{+destination: String, +id: U32, +left: N111Value, +right: N111Value}

type X186FloatStep is Data:
  X186FloatStep{+node: X186FloatNode, +facts: List<&2,X185ScratchCell>}

def x186_float_values_enabled() -> Bool: True{}

def x186_f_admitted(operation: X186InlineOp) -> Bool:
  match operation:
    case X186InlineF32{destination,id,buffer}: True{}
    case X186InlineNone{}: False{}

law x186_f_has_scalars:
  for body: List<&2,N111Stmt>
  Bool

@unsafe
def x186_f_has_scalar(+stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Call{name,typ,symbol,args}: x186_f_admitted(x186_inline_op(stmt))
    case N111If{condition,yes,no}:
      nt_choose(Bool,x186_f_has_scalars(yes),u => True{},u => x186_f_has_scalars(no))
    case _: False{}

@unsafe
def x186_f_has_scalars(body):
  match body:
    case Nil{}: False{}
    case Con{head,rest}: nt_choose(Bool,x186_f_has_scalar(head),u => True{},u => x186_f_has_scalars(rest))

law x186_f_has_body:
  for body: List<&2,P113DStmt>
  Bool

@unsafe
def x186_f_has_stmt(stmt: P113DStmt) -> Bool:
  match stmt:
    case P113DScalar{scalar}: x186_f_has_scalar(scalar)
    case P113DIf{condition,yes,no}:
      nt_choose(Bool,x186_f_has_body(yes),u => True{},u => x186_f_has_body(no))
    case _: False{}

@unsafe
def x186_f_has_body(body):
  match body:
    case Nil{}: False{}
    case Con{head,rest}: nt_choose(Bool,x186_f_has_stmt(head),u => True{},u => x186_f_has_body(rest))

@unsafe
def x186_f_values(stmt: N111Stmt, destination: String, id: U32,
    left: Maybe<&2,N111Value>, right: Maybe<&2,N111Value>) -> X186FloatNode:
  match left right:
    case Some{a} Some{b}: X186FloatValues{destination,id,a,b}
    case _ _: X186FloatPlain{P113DScalar{stmt}}

@unsafe
def x186_f_operation(stmt: N111Stmt, +facts: List<&2,X185ScratchCell>, operation: X186InlineOp) -> X186FloatNode:
  match operation:
    case X186InlineF32{destination,id,+buffer}:
      x186_f_values(stmt,destination,id,x185_sf_find(facts,buffer,0,N111U64{}),x185_sf_find(facts,buffer,8,N111U64{}))
    case X186InlineNone{}: X186FloatPlain{P113DScalar{stmt}}

def x186_f_facts(step: X185ScratchStep) -> List<&2,X185ScratchCell>:
  match step:
    case X185ScratchStep{stmt,facts}: facts

@unsafe
def x186_f_scalar(+stmt: N111Stmt, buffers: KDef, +facts: List<&2,X185ScratchCell>) -> X186FloatStep:
  X186FloatStep{x186_f_operation(stmt,facts,x186_inline_op(stmt)),x186_f_facts(x185_sf_scalar(stmt,buffers,facts))}

law x186_f_plan:
  for body: List<&2,P113DStmt>
  for +buffers: KDef
  for facts: List<&2,X185ScratchCell>
  List<&2,X186FloatNode>

@unsafe
def x186_f_after(rest: List<&2,P113DStmt>, buffers: KDef, step: X186FloatStep) -> List<&2,X186FloatNode>:
  match step:
    case X186FloatStep{node,facts}: Con{node,x186_f_plan(rest,buffers,facts)}

@unsafe
def x186_f_branch(condition: N111Value, yes: List<&2,P113DStmt>, no: List<&2,P113DStmt>,
    rest: List<&2,P113DStmt>, +buffers: KDef) -> List<&2,X186FloatNode>:
  Con{X186FloatBranch{condition,x186_f_plan(yes,buffers,[]),x186_f_plan(no,buffers,[])},x186_f_plan(rest,buffers,[])}

@unsafe
def x186_f_plan(body,buffers,facts):
  match body:
    case Nil{}: []
    case Con{P113DScalar{N111If{condition,yes,no}},rest}:
      x186_f_branch(condition,x181_scalar_rows(yes),x181_scalar_rows(no),rest,buffers)
    case Con{P113DIf{condition,yes,no},rest}: x186_f_branch(condition,yes,no,rest,buffers)
    case Con{P113DScalar{stmt},rest}: x186_f_after(rest,buffers,x186_f_scalar(stmt,buffers,facts))
    case Con{head,rest}: Con{X186FloatPlain{head},x186_f_plan(rest,buffers,[])}

# Metadata only: a binary node has exactly the same local reads and single
# destination write, at one inclusive endpoint. Its integer result has NO
# relationship to F32. These rows are consumed only by frame/read-score/range
# collection, or by the address-escape/read-footprint scan below. They must
# never be emitted, value-folded, copied, or fed to an optimizer.
law x186_f_placement_rows:
  for nodes: List<&2,X186FloatNode>
  List<&2,P113DStmt>

@unsafe
def x186_f_placement_row(node: X186FloatNode) -> P113DStmt:
  match node:
    case X186FloatPlain{stmt}: stmt
    case X186FloatBranch{condition,yes,no}: P113DIf{condition,x186_f_placement_rows(yes),x186_f_placement_rows(no)}
    case X186FloatValues{destination,id,left,right}: P113DScalar{N111Bin{destination,N111U64{},"add",left,right}}

@unsafe
def x186_f_placement_rows(nodes):
  match nodes:
    case Nil{}: []
    case Con{node,rest}: Con{x186_f_placement_row(node),x186_f_placement_rows(rest)}

# Once reads have been discharged by current facts, the F32 node reads only
# its two values. The proven footprint excludes its former buffer; unknown
# operations and all other loads/escapes retain their full original footprint.
@unsafe
def x186_f_proven_read_footprints(nodes: List<&2,X186FloatNode>) -> List<&2,P113DStmt>:
  x186_f_placement_rows(nodes)

@unsafe
def x186_f_buffers(params: List<&2,String>, setup: List<&2,P113DStmt>, body: List<&2,P113DStmt>) -> KDef:
  x185_sf_buffers(body,x185_sf_buffers(setup,x185_sf_blocks(params,
    p111v_put(missing(),"scratch","X185ScratchBuffer",2048,0))))

@unsafe
def x186_f_read_scan(params: List<&2,String>, +setup: List<&2,P113DStmt>, nodes: List<&2,X186FloatNode>) -> X186Memory:
  +reads = x186_f_proven_read_footprints(nodes)
  x186_m_scan(reads,x186_m_scan(setup,X186Memory{x186_f_buffers(params,setup,reads),missing(),missing()}))

law x186_f_prune:
  for nodes: List<&2,X186FloatNode>
  for +scan: X186Memory
  List<&2,X186FloatNode>

@unsafe
def x186_f_prune(nodes,scan):
  match nodes:
    case Nil{}: []
    case Con{X186FloatPlain{P113DScalar{N111Store{+typ,N111Local{+buffer},+offset,+value}}},+rest}:
      nt_choose(List<&2,X186FloatNode>,x186_m_dead_cell(buffer,offset,typ,scan),u => x186_f_prune(rest,scan),
        u => Con{X186FloatPlain{P113DScalar{N111Store{typ,N111Local{buffer},offset,value}}},x186_f_prune(rest,scan)})
    case Con{X186FloatPlain{P113DScalar{N111Alloca{+name,+bytes,+align}}},+rest}:
      nt_choose(List<&2,X186FloatNode>,x186_m_dead_buffer(name,scan),u => x186_f_prune(rest,scan),
        u => Con{X186FloatPlain{P113DScalar{N111Alloca{name,bytes,align}}},x186_f_prune(rest,scan)})
    case Con{X186FloatBranch{condition,yes,no},rest}:
      Con{X186FloatBranch{condition,x186_f_prune(yes,scan),x186_f_prune(no,scan)},x186_f_prune(rest,scan)}
    case Con{head,rest}: Con{head,x186_f_prune(rest,scan)}

@unsafe
def x186_f_ready(params: List<&2,String>, setup: List<&2,P113DStmt>, +nodes: List<&2,X186FloatNode>) -> List<&2,X186FloatNode>:
  nt_choose(List<&2,X186FloatNode>,x186_private_enabled(),u => x186_f_prune(nodes,x186_f_read_scan(params,setup,nodes)),u => nodes)

@unsafe
def x186_f_values_text(name: String, +id: U32, left: N111Value, right: N111Value,
    +ids: N111Ids, +frame: X181Frame) -> X188Seq:
  x188_many([x186_float_load(left,ids,frame,x188_xmm(0)),x186_float_load(right,ids,frame,x188_xmm(1)),
    x186_float_finish(name,id,frame)])

law x186_f_emit_nodes:
  for nodes: List<&2,X186FloatNode>
  for +ids: N111Ids
  for +frame: X181Frame
  for +code: X181Code
  X181Code

@unsafe
def x186_f_emit_if(condition: N111Value, yes: List<&2,X186FloatNode>, no: List<&2,X186FloatNode>,
    +ids: N111Ids, +frame: X181Frame, code: X181Code) -> X181Code:
  match code:
    case X181Code{chunks,+next,terminal,error}:
      x186_f_emit_yes(next,no,ids,frame,x186_f_emit_nodes(yes,ids,frame,
        X181Code{Con{x188_many([x181_load(condition,ids,frame,x188_reg(10,64)),
          x188_i2("testl",x188_reg(10,32),x188_reg(10,32)),
          x188_i1("jz",X187Target{x181_label(next,frame)})]),chunks},U32.add(next,2),False{},error}))

@unsafe
def x186_f_emit_yes(+label: U32, no: List<&2,X186FloatNode>, ids: N111Ids,
    +frame: X181Frame, yes: X181Code) -> X181Code:
  match yes:
    case X181Code{chunks,next,+terminal,error}:
      x181_if_end(label,terminal,frame,x186_f_emit_nodes(no,ids,frame,
        X181Code{Con{x188_cat(nt_choose(X188Seq,terminal,u => X188Empty{},
          u => x188_i1("jmp",X187Target{x181_label(U32.inc(label),frame)})),
          x188_label(x181_label(label,frame))),chunks},next,False{},error}))

@unsafe
def x186_f_emit_node(node: X186FloatNode, ids: N111Ids, frame: X181Frame, code: X181Code) -> X181Code:
  match node:
    case X186FloatPlain{stmt}: x181_stmt(stmt,ids,frame,code)
    case X186FloatBranch{condition,yes,no}: x186_f_emit_if(condition,yes,no,ids,frame,code)
    case X186FloatValues{destination,id,left,right}: x181_add(x186_f_values_text(destination,id,left,right,ids,frame),code)

@unsafe
def x186_f_emit_nodes(nodes,ids,frame,code):
  match nodes code:
    case Nil{} _: code
    case Con{head,rest} X181Code{chunks,next,+terminal,+error}:
      nt_choose(X181Code,String.is_empty(error),u =>
        nt_choose(X181Code,terminal,u => x181_error("x86 float plan statement after terminal",code),
          u => x186_f_emit_nodes(rest,ids,frame,x186_f_emit_node(head,ids,frame,code))),u => code)

# The frame is derived only from placement metadata. Emission receives the
# distinct private nodes, never those metadata rows.
@unsafe
def x186_f_emit_frame(+symbol: String, setup: List<&2,P113DStmt>, nodes: List<&2,X186FloatNode>,
    +ids: N111Ids, +frame: X181Frame) -> X181Output:
  x181_function_done(symbol,x186_f_emit_nodes(nodes,ids,frame,x181_add(x188_label(x181_loop_label(frame)),
    x181_stmts(setup,ids,frame,X181Code{[x181_prologue(frame)],0,False{},""}))))

@unsafe
def x186_f_place(+symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +nodes: List<&2,X186FloatNode>, ids: N111Ids) -> X181Output:
  +placement = x186_f_placement_rows(nodes)
  +all = nt_append(P113DStmt,setup,placement)
  x186_x_select_frame(symbol,params,setup,nodes,ids,x186_saves_frame(x190_allocate_frame(
    x181_frame(symbol,params,all),params,setup,placement,
      nt_choose(List<&2,P113DStmt>,x185_loop_registers_enabled(),u => placement,u => all))))

@unsafe
def x186_f_ordinary(+symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +ids: N111Ids) -> X181Output:
  +all = nt_append(P113DStmt,setup,body)
  nt_choose(X181Output,x191_address_enabled() || x191_memory_alu_enabled(),
    u => x191_ordinary(symbol,params,setup,body,ids),
    u => x185_function_frame(symbol,setup,body,ids,x190_allocate_frame(
    x181_frame(symbol,params,all),params,setup,body,
      nt_choose(List<&2,P113DStmt>,x185_loop_registers_enabled(),u => body,u => all))))

@unsafe
def x186_float_function(+symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +ids: N111Ids) -> X181Output:
  nt_choose(X181Output,x186_float_values_enabled() && x185_float_enabled() &&
      U32.is_lt(p113i_add(p113i_size(setup),p113i_size(body)),4096),
    u => nt_choose(X181Output,x186_f_has_body(body),
      v => x186_f_place(symbol,params,setup,x186_f_ready(params,setup,
        x186_f_plan(body,x186_f_buffers(params,setup,body),[])),ids),
      v => x186_f_ordinary(symbol,params,setup,body,ids)),
    u => x186_f_ordinary(symbol,params,setup,body,ids))
