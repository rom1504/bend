# Integer selection consumes only actual plain nodes, never float metadata rows.
type X195FCPick is Data:
  X195FCPick{+plan: X194Select, +rest: List<&2,X186FloatNode>}

def x195fc_enabled() -> Bool: True{}

def x195fc_absent(home: Maybe<&2,X187Operand>) -> Bool:
  match home:
    case None{}: True{}
    case Some{operand}: False{}

@unsafe
def x195fc_value(value: N111Value, homes: KDef) -> Bool:
  match value:
    case N111Local{name}: x195fc_absent(x186_x_home(name,homes))
    case _: True{}

@unsafe
def x195fc_names(names: List<&2,String>, +homes: KDef) -> Bool:
  match names:
    case Nil{}: True{}
    case Con{name,rest}: x195fc_absent(x186_x_home(name,homes)) && x195fc_names(rest,homes)

@unsafe
def x195fc_cons(stmt: P113DStmt, rows: Maybe<&2,List<&2,P113DStmt>>) -> Maybe<&2,List<&2,P113DStmt>>:
  match rows:
    case None{}: None{}
    case Some{rest}: Some{Con{stmt,rest}}

@unsafe
def x195fc_arm(nodes: List<&2,X186FloatNode>, +fuel: U32) -> Maybe<&2,List<&2,P113DStmt>>:
  match nodes:
    case Nil{}: Some{[]}
    case Con{X186FloatPlain{P113DScalar{N111Set{name,typ,value}}},rest}:
      nt_choose(Maybe<&2,List<&2,P113DStmt>>,U32.is_gt(fuel,0),
        u => x195fc_cons(P113DScalar{N111Set{name,typ,value}},x195fc_arm(rest,U32.sub(fuel,1))),u => None{})
    case _: None{}

@unsafe
def x195fc_plain(plan: X194Select, +homes: KDef) -> Bool:
  match plan:
    case X194Select{rest,typ,op,left,right,invert,X191SelectPlan{st,yes,no,names},removed}:
      x195fc_value(left,homes) && x195fc_value(right,homes) &&
      x195fc_value(yes,homes) && x195fc_value(no,homes) &&
      x195fc_names(names,homes) && x195fc_names(removed,homes)

@unsafe
def x195fc_ready(pick: Maybe<&2,X194Select>, rest: List<&2,X186FloatNode>, homes: KDef) -> Maybe<&2,X195FCPick>:
  match pick:
    case None{}: None{}
    case Some{+plan}: nt_choose(Maybe<&2,X195FCPick>,x195fc_plain(plan,homes),
      u => Some{X195FCPick{plan,rest}},u => None{})

@unsafe
def x195fc_arms(stmt: P113DStmt, condition: N111Value,
    yes: Maybe<&2,List<&2,P113DStmt>>, no: Maybe<&2,List<&2,P113DStmt>>,
    rest: List<&2,X186FloatNode>, homes: KDef) -> Maybe<&2,X195FCPick>:
  match yes no:
    case Some{a} Some{b}: x195fc_ready(x194_ps_pick([stmt,P113DIf{condition,a,b}]),rest,homes)
    case _ _: None{}

@unsafe
def x195fc_pick(nodes: List<&2,X186FloatNode>, homes: KDef) -> Maybe<&2,X195FCPick>:
  match nodes:
    case Con{X186FloatPlain{P113DScalar{N111Bin{name,typ,op,left,right}}},Con{X186FloatBranch{condition,yes,no},rest}}:
      x195fc_arms(P113DScalar{N111Bin{name,typ,op,left,right}},condition,x195fc_arm(yes,4),x195fc_arm(no,4),rest,homes)
    case _: None{}

# Count actual node reads, including float operands. No invented integer op
# substitutes for FloatValues, and no float row enters x194_ps_pick.
law x195fc_reads:
  for nodes: List<&2,X186FloatNode>
  for counts: X181ReadCounts
  X181ReadCounts

@unsafe
def x195fc_read_node(node: X186FloatNode, counts: X181ReadCounts) -> X181ReadCounts:
  match node:
    case X186FloatPlain{stmt}: x181_reads_stmt(stmt,counts)
    case X186FloatValues{name,id,left,right}: x181_reads_values([left,right],counts)
    case X186FloatBranch{condition,yes,no}: x195fc_reads(no,x195fc_reads(yes,x181_reads_value(condition,counts)))

@unsafe
def x195fc_reads(nodes,counts):
  match nodes:
    case Nil{}: counts
    case Con{head,rest}: x195fc_reads(rest,x195fc_read_node(head,counts))

@unsafe
def x195fc_count(pick: Maybe<&2,X195FCPick>, pairs: KDef) -> KDef:
  match pick:
    case None{}: pairs
    case Some{X195FCPick{X194Select{rest,typ,op,left,right,invert,selected,names},tail}}: x194_ps_count(names,pairs)

law x195fc_pairs:
  for +nodes: List<&2,X186FloatNode>
  for +homes: KDef
  for pairs: KDef
  KDef

@unsafe
def x195fc_nested(node: X186FloatNode, +homes: KDef, pairs: KDef) -> KDef:
  match node:
    case X186FloatBranch{condition,yes,no}: x195fc_pairs(no,homes,x195fc_pairs(yes,homes,pairs))
    case _: pairs

@unsafe
def x195fc_pairs(nodes,homes,pairs):
  match nodes:
    case Nil{}: pairs
    case Con{head,rest}: x195fc_pairs(rest,homes,x195fc_nested(head,homes,x195fc_count(x195fc_pick(nodes,homes),pairs)))

@unsafe
def x195fc_facts(params: List<&2,String>, +setup: List<&2,P113DStmt>, +nodes: List<&2,X186FloatNode>, homes: KDef) -> X190BranchFacts:
  x190_branch_counted(x195fc_reads(nodes,x181_reads_stmts(setup,X181ReadCounts{missing(),[]})),missing(),
    x195fc_pairs(nodes,homes,missing()),x185_copy_writes(setup,x185_copy_writes_names(params,missing())))

law x195fc_emit:
  for +nodes: List<&2,X186FloatNode>
  for +facts: X190BranchFacts
  for +ids: N111Ids
  for +frame: X181Frame
  for +homes: KDef
  for +code: X181Code
  X181Code

@unsafe
def x195fc_emit_yes(+label: U32, no: List<&2,X186FloatNode>, facts: X190BranchFacts,
    ids: N111Ids, +frame: X181Frame, homes: KDef, yes: X181Code) -> X181Code:
  match yes:
    case X181Code{chunks,next,+terminal,error}:
      x181_if_end(label,terminal,frame,x195fc_emit(no,facts,ids,frame,homes,
        X181Code{Con{x188_cat(nt_choose(X188Seq,terminal,u => X188Empty{},
          u => x188_i1("jmp",X187Target{x181_label(U32.inc(label),frame)})),
          x188_label(x181_label(label,frame))),chunks},next,False{},error}))

@unsafe
def x195fc_node(+node: X186FloatNode, +facts: X190BranchFacts, +ids: N111Ids,
    +frame: X181Frame, +homes: KDef, +code: X181Code) -> X181Code:
  match node code:
    case X186FloatBranch{condition,yes,no} X181Code{chunks,+next,terminal,error}:
      x195fc_emit_yes(next,no,facts,ids,frame,homes,x195fc_emit(yes,facts,ids,frame,homes,
        X181Code{Con{x188_many([x181_load(condition,ids,frame,x188_reg(10,64)),
          x188_i2("testl",x188_reg(10,32),x188_reg(10,32)),
          x188_i1("jz",X187Target{x181_label(next,frame)})]),chunks},U32.add(next,2),False{},error}))
    case _ _: x186_x_emit_node(node,ids,frame,homes,code)

@unsafe
def x195fc_previous(nodes: List<&2,X186FloatNode>, +facts: X190BranchFacts,
    +ids: N111Ids, +frame: X181Frame, +homes: KDef, code: X181Code) -> X181Code:
  match nodes:
    case Nil{}: code
    case Con{head,rest}: x195fc_emit(rest,facts,ids,frame,homes,x195fc_node(head,facts,ids,frame,homes,code))

@unsafe
def x195fc_step(pick: Maybe<&2,X195FCPick>, +nodes: List<&2,X186FloatNode>, +facts: X190BranchFacts,
    +ids: N111Ids, +frame: X181Frame, +homes: KDef, +code: X181Code) -> X181Code:
  match pick:
    case None{}: x195fc_previous(nodes,facts,ids,frame,homes,code)
    case Some{X195FCPick{X194Select{tail,typ,op,left,right,invert,selected,+names},rest}}:
      nt_choose(X181Code,x194_ps_allowed(names,facts),
        u => x195fc_emit(rest,facts,ids,frame,homes,
          x181_add(x194_ps_emit(X194Select{tail,typ,op,left,right,invert,selected,names},ids,frame),code)),
        u => x195fc_previous(nodes,facts,ids,frame,homes,code))

@unsafe
def x195fc_emit(nodes,facts,ids,frame,homes,code):
  match nodes code:
    case Nil{} _: code
    case Con{head,rest} X181Code{chunks,next,+terminal,+error}:
      nt_choose(X181Code,String.is_empty(error),u =>
        nt_choose(X181Code,terminal,u => x181_error("x86 XMM plan statement after terminal",code),
          u => x195fc_step(x195fc_pick(nodes,homes),nodes,facts,ids,frame,homes,code)),u => code)

@unsafe
def x195fc_frame(+symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +nodes: List<&2,X186FloatNode>, +ids: N111Ids, +frame: X181Frame) -> X181Output:
  +homes = x186_x_homes(params,setup,nodes)
  x181_function_done(symbol,x195fc_emit(nodes,x195fc_facts(params,setup,nodes,homes),ids,frame,homes,
    x181_add(x188_label(x181_loop_label(frame)),x181_stmts(setup,ids,frame,X181Code{[x181_prologue(frame)],0,False{},""}))))

@unsafe
def x195fc_frame_previous(+symbol: String, params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +nodes: List<&2,X186FloatNode>, +ids: N111Ids, +frame: X181Frame) -> X181Output:
  x181_function_done(symbol,x186_x_emit_nodes(nodes,ids,frame,x186_x_homes(params,setup,nodes),
    x181_add(x188_label(x181_loop_label(frame)),x181_stmts(setup,ids,frame,X181Code{[x181_prologue(frame)],0,False{},""}))))
