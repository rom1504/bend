# XMM homes belong only to closed straight-line F32/canonical-copy regions.
# Every ordinary operation cuts the region. Existing inclusive ranges exclude
# all names read/written across a cut, parameters, setup and reserved names.
# A name with ANY noncanonical definition is excluded globally. Thus an XMM
# value always denotes the entire canonical zero-extended64 word, not merely
# the low bits of an arbitrary word. Original GPR frame metadata is unchanged.
type X186XScan is Data:
  X186XScan{+ranges: X185TScan, +canonical: KDef}

def x186_xmm_enabled() -> Bool: True{}

@unsafe
def x186_x_canonical(value: N111Value, canonical: KDef) -> Bool:
  match value:
    case N111Local{name}: U32.is_gt(da(p111v_get(canonical,name)),0)
    case _: False{}

@unsafe
def x186_x_cut(scan: X186XScan) -> X186XScan:
  match scan:
    case X186XScan{ranges,canonical}: X186XScan{x185_t_cut(ranges),missing()}

@unsafe
def x186_x_noncanonical(stmt: P113DStmt, scan: X185TScan) -> X185TScan:
  match scan:
    case X185TScan{ranges,names,position,region}:
      X185TScan{x185_copy_writes([stmt],ranges),names,position,region}

@unsafe
def x186_x_plain(+stmt: P113DStmt, scan: X186XScan) -> X186XScan:
  match stmt scan:
    case P113DScalar{N111Set{+name,N111U64{},+value}} X186XScan{+ranges,+canonical}:
      +good = x186_x_canonical(value,canonical)
      X186XScan{x185_t_next(nt_choose(X185TScan,good,
        u => x185_t_event(name,True{},x185_t_read(value,ranges)),
        u => x185_t_forbid(name,x185_t_read(value,ranges)))),
        p111v_put(canonical,name,"X186Canonical",nt_choose(U32,good,u => 1,u => 0),0)}
    case _ X186XScan{ranges,canonical}:
      X186XScan{x185_t_cut(x186_x_noncanonical(stmt,x185_t_stmt(stmt,x185_t_cut(ranges)))),missing()}

law x186_x_scan:
  for nodes: List<&2,X186FloatNode>
  for scan: X186XScan
  X186XScan

@unsafe
def x186_x_node(node: X186FloatNode, +scan: X186XScan) -> X186XScan:
  match node scan:
    case X186FloatValues{+destination,id,left,right} X186XScan{ranges,canonical}:
      X186XScan{x185_t_next(x185_t_event(destination,True{},x185_t_reads([left,right],ranges))),
        p111v_put(canonical,destination,"X186Canonical",1,0)}
    case X186FloatBranch{condition,yes,no} X186XScan{ranges,canonical}:
      x186_x_cut(x186_x_scan(no,x186_x_cut(x186_x_scan(yes,
        X186XScan{x185_t_cut(x185_t_read(condition,x185_t_cut(ranges))),missing()}))))
    case X186FloatPlain{stmt} _: x186_x_plain(stmt,scan)

@unsafe
def x186_x_scan(nodes,scan):
  match nodes:
    case Nil{}: scan
    case Con{head,rest}: x186_x_scan(rest,x186_x_node(head,scan))

@unsafe
def x186_x_pick(ends: List<&2,U32>, +first: U32, +index: U32) -> U32:
  match ends:
    case Nil{}: 14
    case Con{last,rest}: nt_choose(U32,U32.is_lt(last,first),u => index,
      u => x186_x_pick(rest,first,U32.inc(index)))

law x186_x_place_names:
  for names: List<&2,String>
  for +ranges: KDef
  for +homes: KDef
  for +ends: List<&2,U32>
  KDef

@unsafe
def x186_x_chosen(name: String, +rest: List<&2,String>, +ranges: KDef, +homes: KDef,
    +ends: List<&2,U32>, +index: U32, last: U32) -> KDef:
  nt_choose(KDef,U32.is_lt(index,14),
    u => x186_x_place_names(rest,ranges,p111v_put(homes,name,"X186Xmm",index,0),x185_t_end(ends,index,last)),
    u => x186_x_place_names(rest,ranges,homes,ends))

@unsafe
def x186_x_place_names(names,ranges,homes,ends):
  match names:
    case Nil{}: homes
    case Con{+name,+rest}:
      +range = p111v_get(ranges,name)
      nt_choose(KDef,String.eq(dk(range),"X185TRange"),
        u => x186_x_chosen(name,rest,ranges,homes,ends,x186_x_pick(ends,da(range),0),dx(range)),
        u => x186_x_place_names(rest,ranges,homes,ends))

@unsafe
def x186_x_scanned(scan: X186XScan) -> KDef:
  match scan:
    case X186XScan{X185TScan{ranges,names,position,region},canonical}:
      x186_x_place_names(nt_reverse(String,names,[]),ranges,missing(),[0,0,0,0,0,0,0,0,0,0,0,0,0,0])

@unsafe
def x186_x_homes(params: List<&2,String>, setup: List<&2,P113DStmt>, nodes: List<&2,X186FloatNode>) -> KDef:
  x186_x_scanned(x186_x_scan(nodes,X186XScan{
    X185TScan{x185_copy_writes_names(params,x185_copy_writes(setup,missing())),[],1,0},missing()}))

@unsafe
def x186_x_home(name: String, homes: KDef) -> Maybe<&2,X187Operand>:
  +slot = p111v_get(homes,name)
  nt_choose(Maybe<&2,X187Operand>,String.eq(dk(slot),"X186Xmm") && U32.is_lt(da(slot),14),
    u => Some{x188_xmm(U32.add(da(slot),2))},u => None{})

@unsafe
def x186_x_source(value: N111Value, homes: KDef) -> Maybe<&2,X187Operand>:
  match value:
    case N111Local{name}: x186_x_home(name,homes)
    case _: None{}

@unsafe
def x186_x_move(+source: X187Operand, +target: X187Operand) -> X188Seq:
  nt_choose(X188Seq,x188_operand_same(source,target),u => X188Empty{},u => x188_i2("movaps",source,target))

@unsafe
def x186_x_load_from(source: Maybe<&2,X187Operand>, value: N111Value, ids: N111Ids,
    frame: X181Frame, target: X187Operand) -> X188Seq:
  match source:
    case Some{operand}: x186_x_move(operand,target)
    case None{}: x186_float_load(value,ids,frame,target)

@unsafe
def x186_x_load(+value: N111Value, ids: N111Ids, frame: X181Frame, homes: KDef, target: X187Operand) -> X188Seq:
  x186_x_load_from(x186_x_source(value,homes),value,ids,frame,target)

@unsafe
def x186_x_direct(source: Maybe<&2,X187Operand>, target: X187Operand) -> Bool:
  match source:
    case Some{operand}: Bool.not(x188_operand_same(operand,target))
    case None{}: False{}

# Right is snapshotted first when its home aliases the arithmetic destination.
# The instruction still computes left OP right in the original operand order.
@unsafe
def x186_x_arithmetic(+name: String, id: U32, +left: N111Value, +right: N111Value,
    +ids: N111Ids, +frame: X181Frame, +homes: KDef) -> X188Seq:
  +destination = x186_x_home(name,homes)
  +target = x186_float_operand(destination,x188_xmm(0))
  +source = x186_x_source(right,homes)
  +direct = x186_x_direct(source,target)
  x188_many([
    nt_choose(X188Seq,direct,u => X188Empty{},u => x186_x_load(right,ids,frame,homes,x188_xmm(1))),
    x186_x_load(left,ids,frame,homes,target),
    x188_i2(x185_float_arithmetic(id),
      nt_choose(X187Operand,direct,u => x186_float_operand(source,x188_xmm(1)),u => x188_xmm(1)),target),
    nt_choose(X188Seq,x186_float_present(destination),u => X188Empty{},u => x186_float_result(name,frame))])

@unsafe
def x186_x_compare_result(destination: Maybe<&2,X187Operand>, name: String, frame: X181Frame) -> X188Seq:
  match destination:
    case Some{operand}: x188_i2("movd",x188_reg(10,32),operand)
    case None{}: x181_store(name,frame,x188_reg(10,64))

@unsafe
def x186_x_compare(+name: String, id: U32, left: N111Value, right: N111Value,
    +ids: N111Ids, +frame: X181Frame, +homes: KDef) -> X188Seq:
  +destination = x186_x_home(name,homes)
  x188_many([x186_x_load(left,ids,frame,homes,x188_xmm(0)),x186_x_load(right,ids,frame,homes,x188_xmm(1)),
    x188_i2("ucomiss",x188_xmm(1),x188_xmm(0)),x185_float_compare(id),
    x188_i2("movzbl",x188_reg(10,8),x188_reg(10,32)),x186_x_compare_result(destination,name,frame)])

@unsafe
def x186_x_float(+name: String, +id: U32, +left: N111Value, +right: N111Value,
    +ids: N111Ids, +frame: X181Frame, +homes: KDef) -> X188Seq:
  nt_choose(X188Seq,x192_float_unary(id),u => x192_float_conversion(name,id,left,ids,frame,homes),
    u => nt_choose(X188Seq,U32.is_lt(id,30),v => x186_x_arithmetic(name,id,left,right,ids,frame,homes),
      v => x186_x_compare(name,id,left,right,ids,frame,homes)))

@unsafe
def x186_x_publish_to(destination: Maybe<&2,X187Operand>, name: String, source: X187Operand, frame: X181Frame) -> X188Seq:
  match destination:
    case Some{operand}: x186_x_move(source,operand)
    case None{}: x186_float_publish(name,source,frame)

@unsafe
def x186_x_publish(+name: String, source: X187Operand, frame: X181Frame, homes: KDef) -> X188Seq:
  x186_x_publish_to(x186_x_home(name,homes),name,source,frame)

@unsafe
def x186_x_copy_homes(source: Maybe<&2,X187Operand>, destination: Maybe<&2,X187Operand>,
    stmt: P113DStmt, name: String, value: N111Value, ids: N111Ids,
    frame: X181Frame, homes: KDef, code: X181Code) -> X181Code:
  match source destination:
    case Some{operand} _: x181_add(x186_x_publish(name,operand,frame,homes),code)
    case None{} None{}: x181_stmt(stmt,ids,frame,code)
    case None{} Some{operand}: x181_add(x186_float_load(value,ids,frame,operand),code)

@unsafe
def x186_x_copy(stmt: P113DStmt, +name: String, +value: N111Value, ids: N111Ids,
    frame: X181Frame, +homes: KDef, code: X181Code) -> X181Code:
  x186_x_copy_homes(x186_x_source(value,homes),x186_x_home(name,homes),stmt,name,value,ids,frame,homes,code)

law x186_x_emit_nodes:
  for nodes: List<&2,X186FloatNode>
  for +ids: N111Ids
  for +frame: X181Frame
  for +homes: KDef
  for +code: X181Code
  X181Code

@unsafe
def x186_x_emit_if(condition: N111Value, yes: List<&2,X186FloatNode>, no: List<&2,X186FloatNode>,
    +ids: N111Ids, +frame: X181Frame, +homes: KDef, code: X181Code) -> X181Code:
  match code:
    case X181Code{chunks,+next,terminal,error}:
      x186_x_emit_yes(next,no,ids,frame,homes,x186_x_emit_nodes(yes,ids,frame,homes,
        X181Code{Con{x188_many([x181_load(condition,ids,frame,x188_reg(10,64)),
          x188_i2("testl",x188_reg(10,32),x188_reg(10,32)),
          x188_i1("jz",X187Target{x181_label(next,frame)})]),chunks},U32.add(next,2),False{},error}))

@unsafe
def x186_x_emit_yes(+label: U32, no: List<&2,X186FloatNode>, ids: N111Ids,
    +frame: X181Frame, homes: KDef, yes: X181Code) -> X181Code:
  match yes:
    case X181Code{chunks,next,+terminal,error}:
      x181_if_end(label,terminal,frame,x186_x_emit_nodes(no,ids,frame,homes,
        X181Code{Con{x188_cat(nt_choose(X188Seq,terminal,u => X188Empty{},
          u => x188_i1("jmp",X187Target{x181_label(U32.inc(label),frame)})),
          x188_label(x181_label(label,frame))),chunks},next,False{},error}))

@unsafe
def x186_x_emit_node(+node: X186FloatNode, +ids: N111Ids, +frame: X181Frame, +homes: KDef, code: X181Code) -> X181Code:
  match node:
    case X186FloatValues{name,id,left,right}: x181_add(x186_x_float(name,id,left,right,ids,frame,homes),code)
    case X186FloatPlain{+stmt}:
      match stmt:
        case P113DScalar{N111Set{name,N111U64{},value}}: x186_x_copy(stmt,name,value,ids,frame,homes,code)
        case _: x181_stmt(stmt,ids,frame,code)
    case X186FloatBranch{condition,yes,no}: x186_x_emit_if(condition,yes,no,ids,frame,homes,code)

@unsafe
def x186_x_emit_nodes(nodes,ids,frame,homes,code):
  match nodes code:
    case Nil{} _: code
    case Con{head,rest} X181Code{chunks,next,+terminal,+error}:
      nt_choose(X181Code,String.is_empty(error),u =>
        nt_choose(X181Code,terminal,u => x181_error("x86 XMM plan statement after terminal",code),
          u => x186_x_emit_nodes(rest,ids,frame,homes,x186_x_emit_node(head,ids,frame,homes,code))),u => code)

@unsafe
def x186_x_emit_frame(+symbol: String, params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +nodes: List<&2,X186FloatNode>, +ids: N111Ids, +frame: X181Frame) -> X181Output:
  x181_function_done(symbol,x186_x_emit_nodes(nodes,ids,frame,x186_x_homes(params,setup,nodes),
    x181_add(x188_label(x181_loop_label(frame)),x181_stmts(setup,ids,frame,X181Code{[x181_prologue(frame)],0,False{},""}))))

@unsafe
def x186_x_select_frame(+symbol: String, params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +nodes: List<&2,X186FloatNode>, +ids: N111Ids, +frame: X181Frame) -> X181Output:
  nt_choose(X181Output,x186_xmm_enabled(),u => x186_x_emit_frame(symbol,params,setup,nodes,ids,frame),
    u => x186_f_emit_frame(symbol,setup,nodes,ids,frame))

@unsafe
def x186_x_place(+symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +nodes: List<&2,X186FloatNode>, ids: N111Ids) -> X181Output:
  +placement = x186_f_placement_rows(nodes)
  +all = nt_append(P113DStmt,setup,placement)
  x186_x_emit_frame(symbol,params,setup,nodes,ids,x186_saves_frame(x190_allocate_frame(
    x181_frame(symbol,params,all),params,setup,placement,
      nt_choose(List<&2,P113DStmt>,x185_loop_registers_enabled(),u => placement,u => all))))

@unsafe
def x186_x_function(+symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +ids: N111Ids) -> X181Output:
  nt_choose(X181Output,x185_float_enabled() && U32.is_lt(p113i_add(p113i_size(setup),p113i_size(body)),4096),
    u => nt_choose(X181Output,x186_f_has_body(body),
      v => x186_x_place(symbol,params,setup,x186_f_ready(params,setup,
        x186_f_plan(body,x186_f_buffers(params,setup,body),[])),ids),
      v => x186_f_ordinary(symbol,params,setup,body,ids)),
    u => x186_f_ordinary(symbol,params,setup,body,ids))
