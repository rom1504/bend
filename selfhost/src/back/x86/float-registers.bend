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
def x186_x_home(name: String, homes: KDef) -> String:
  +slot = p111v_get(homes,name)
  nt_choose(String,String.eq(dk(slot),"X186Xmm") && U32.is_lt(da(slot),14),
    u => "%xmm" ++ U32.show(U32.add(da(slot),2)),u => "")

@unsafe
def x186_x_source(value: N111Value, homes: KDef) -> String:
  match value:
    case N111Local{name}: x186_x_home(name,homes)
    case _: ""

@unsafe
def x186_x_move(+source: String, +target: String) -> String:
  nt_choose(String,String.eq(source,target),u => "",u => "  movaps " ++ source ++ ", " ++ target ++ "\n")

@unsafe
def x186_x_load(+value: N111Value, ids: N111Ids, frame: X181Frame, homes: KDef, +target: String) -> String:
  +source = x186_x_source(value,homes)
  nt_choose(String,String.is_empty(source),u => x186_float_load(value,ids,frame,target),
    u => x186_x_move(source,target))

# Right is snapshotted first when its home aliases the arithmetic destination.
# The instruction still computes left OP right in the original operand order.
@unsafe
def x186_x_arithmetic(+name: String, id: U32, +left: N111Value, +right: N111Value,
    +ids: N111Ids, +frame: X181Frame, +homes: KDef) -> String:
  +destination = x186_x_home(name,homes)
  +target = nt_choose(String,String.is_empty(destination),u => "%xmm0",u => destination)
  +source = x186_x_source(right,homes)
  +direct = Bool.not(String.is_empty(source)) && Bool.not(String.eq(source,target))
  nt_choose(String,direct,u => "",u => x186_x_load(right,ids,frame,homes,"%xmm1")) ++
    x186_x_load(left,ids,frame,homes,target) ++ "  " ++ x185_float_arithmetic(id) ++ " " ++
    nt_choose(String,direct,u => source,u => "%xmm1") ++ ", " ++ target ++ "\n" ++
    nt_choose(String,String.is_empty(destination),u => x186_float_result(name,frame),u => "")

@unsafe
def x186_x_compare(+name: String, id: U32, left: N111Value, right: N111Value,
    +ids: N111Ids, +frame: X181Frame, +homes: KDef) -> String:
  +destination = x186_x_home(name,homes)
  x186_x_load(left,ids,frame,homes,"%xmm0") ++ x186_x_load(right,ids,frame,homes,"%xmm1") ++
    "  ucomiss %xmm1, %xmm0\n" ++ x185_float_compare(id) ++ "  movzbl %r10b, %r10d\n" ++
    nt_choose(String,String.is_empty(destination),u => x181_store(name,frame,"%r10"),
      u => "  movd %r10d, " ++ destination ++ "\n")

@unsafe
def x186_x_float(+name: String, +id: U32, +left: N111Value, +right: N111Value,
    +ids: N111Ids, +frame: X181Frame, +homes: KDef) -> String:
  nt_choose(String,U32.is_lt(id,30),u => x186_x_arithmetic(name,id,left,right,ids,frame,homes),
    u => x186_x_compare(name,id,left,right,ids,frame,homes))

@unsafe
def x186_x_publish(+name: String, +source: String, +frame: X181Frame, homes: KDef) -> String:
  +destination = x186_x_home(name,homes)
  +physical = x186_float_home(name,frame,False{})
  nt_choose(String,Bool.not(String.is_empty(destination)),u => x186_x_move(source,destination),u =>
    nt_choose(String,String.is_empty(physical),
      v => "  movd " ++ source ++ ", %r10d\n" ++ x181_store(name,frame,"%r10"),
      v => "  movd " ++ source ++ ", " ++ physical ++ "\n"))

@unsafe
def x186_x_copy(+stmt: P113DStmt, +name: String, +value: N111Value, +ids: N111Ids,
    +frame: X181Frame, +homes: KDef, +code: X181Code) -> X181Code:
  +source = x186_x_source(value,homes)
  +destination = x186_x_home(name,homes)
  nt_choose(X181Code,Bool.not(String.is_empty(source)),
    u => x181_add(x186_x_publish(name,source,frame,homes),code),u =>
    nt_choose(X181Code,String.is_empty(destination),v => x181_stmt(stmt,ids,frame,code),
      v => x181_add(x186_float_load(value,ids,frame,destination),code)))

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
        X181Code{Con{x181_load(condition,ids,frame,"%r10") ++ "  testl %r10d, %r10d\n  jz " ++
          x181_label(next,frame) ++ "\n",chunks},U32.add(next,2),False{},error}))

@unsafe
def x186_x_emit_yes(+label: U32, no: List<&2,X186FloatNode>, ids: N111Ids,
    +frame: X181Frame, homes: KDef, yes: X181Code) -> X181Code:
  match yes:
    case X181Code{chunks,next,+terminal,error}:
      x181_if_end(label,terminal,frame,x186_x_emit_nodes(no,ids,frame,homes,
        X181Code{Con{nt_choose(String,terminal,u => "",u => "  jmp " ++ x181_label(U32.inc(label),frame) ++ "\n") ++
          x181_label(label,frame) ++ ":\n",chunks},next,False{},error}))

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
    x181_add(x181_loop_label(frame) ++ ":\n",x181_stmts(setup,ids,frame,X181Code{[x181_prologue(frame)],0,False{},""}))))

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
  x186_x_emit_frame(symbol,params,setup,nodes,ids,x186_saves_frame(x185_transient_frame(
    x181_register_frame(x181_frame(symbol,params,all),
      nt_choose(List<&2,P113DStmt>,x185_loop_registers_enabled(),u => placement,u => all)),params,setup,placement)))

@unsafe
def x186_x_function(+symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +ids: N111Ids) -> X181Output:
  nt_choose(X181Output,x185_float_enabled() && U32.is_lt(p113i_add(p113i_size(setup),p113i_size(body)),4096),
    u => nt_choose(X181Output,x186_f_has_body(body),
      v => x186_x_place(symbol,params,setup,x186_f_ready(params,setup,
        x186_f_plan(body,x186_f_buffers(params,setup,body),[])),ids),
      v => x186_f_ordinary(symbol,params,setup,body,ids)),
    u => x186_f_ordinary(symbol,params,setup,body,ids))
