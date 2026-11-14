# Actual FloatValues surround integer selection; exercise x186_x_place and its
# original XMM homes, GPR allocation, and the hooked final-node consumer.
def p195fc_v(name: String) -> N111Value: N111Local{name}
def p195fc_set(name: String, typ: N111Type, value: N111Value) -> X186FloatNode:
  X186FloatPlain{P113DScalar{N111Set{name,typ,value}}}
def p195fc_store(offset: U32, value: N111Value) -> X186FloatNode:
  X186FloatPlain{P113DScalar{N111Store{N111U64{},p195fc_v("state"),offset,value}}}

@unsafe
def p195fc_corridor(+mode: U32) -> List<&2,X186FloatNode>:
  +typ = nt_choose(N111Type,U32.is_eq(U32.mod(U32.div(mode,10),2),0),u => N111U32{},u => N111U64{})
  +st = nt_choose(N111Type,U32.is_lt(mode,20),u => N111U32{},u => N111U64{})
  [X186FloatPlain{P113DScalar{N111Bin{"condition",typ,p194pc_op(U32.mod(mode,10)),p195fc_v("a"),p195fc_v("b")}}},
    X186FloatBranch{p195fc_v("condition"),
      [p195fc_set("a",st,p195fc_v("a")),p195fc_set("b",st,p195fc_v("a"))],
      [p195fc_set("a",st,p195fc_v("b")),p195fc_set("b",st,p195fc_v("a"))]}]

@unsafe
def p195fc_body(mode: U32) -> List<&2,X186FloatNode>:
  nt_append(X186FloatNode,[
    X186FloatValues{"fp0",26,N111Const{1065353216,0},N111Const{1073741824,0}},
    X186FloatValues{"fp1",28,p195fc_v("fp0"),N111Const{1073741824,0}},
    p195fc_set("savedFloat",N111U64{},p195fc_v("fp1")),
    X186FloatPlain{P113DScalar{N111Load{"a",N111U64{},p195fc_v("state"),0}}},
    X186FloatPlain{P113DScalar{N111Load{"b",N111U64{},p195fc_v("state"),8}}}],
    nt_append(X186FloatNode,nt_choose(List<&2,X186FloatNode>,U32.is_eq(U32.mod(mode,2),0),
      u => p195fc_corridor(mode),u => [X186FloatBranch{N111Const{1,0},p195fc_corridor(mode),[]}]),[
      p195fc_store(16,p195fc_v("a")),p195fc_store(24,p195fc_v("b")),
      X186FloatValues{"fp2",26,N111Const{1065353216,0},N111Const{1073741824,0}},
      X186FloatValues{"fp3",28,p195fc_v("fp2"),N111Const{1073741824,0}},
      p195fc_store(32,p195fc_v("savedFloat")),p195fc_store(40,p195fc_v("fp3")),
      X186FloatPlain{P113DResult{[p195fc_v("b")]}}]))

@unsafe
def p195fc_allowed(pick: Maybe<&2,X195FCPick>, facts: X190BranchFacts) -> Bool:
  match pick:
    case None{}: False{}
    case Some{X195FCPick{X194Select{rest,typ,op,left,right,invert,selected,names},tail}}: x194_ps_allowed(names,facts)

@unsafe
def p195fc_admitted(+nodes: List<&2,X186FloatNode>, params: List<&2,String>, setup: List<&2,P113DStmt>, +homes: KDef) -> Bool:
  p195fc_allowed(x195fc_pick(nodes,homes),x195fc_facts(params,setup,nodes,homes))

@unsafe
def p195fc_modes(+mode: U32) -> List<&2,String>:
  nt_choose(List<&2,String>,U32.is_ge(mode,40),u => [],u =>
    Con{p194pc_row("float-select-" ++ U32.show(mode),p195fc_admitted(p195fc_corridor(mode),[],[],missing())),p195fc_modes(U32.inc(mode))})

@unsafe
def p195fc_controls() -> List<&2,String>:
  nt_append(String,p195fc_modes(0),[
    p194pc_row("xmm-region-used",Bool.not(x195fc_absent(x186_x_home("fp0",x186_x_homes(["state"],[],p195fc_body(0)))))),
    p194pc_row("xmm-input-refused",Bool.not(p195fc_admitted(p195fc_corridor(0),[],[],p111v_put(missing(),"a","X186Xmm",0,0)))),
    p194pc_row("xmm-predicate-refused",Bool.not(p195fc_admitted(p195fc_corridor(0),[],[],p111v_put(missing(),"condition","X186Xmm",0,0)))),
    p194pc_row("parameter-refused",Bool.not(p195fc_admitted(p195fc_corridor(0),["condition"],[],missing()))),
    p194pc_row("setup-refused",Bool.not(p195fc_admitted(p195fc_corridor(0),[],[p194pc_set("condition",N111U64{},N111Const{0,0})],missing()))),
    p194pc_row("float-read-refused",Bool.not(p195fc_admitted(nt_append(X186FloatNode,p195fc_corridor(0),
      [X186FloatValues{"escape",26,p195fc_v("condition"),N111Const{0,0}}]),[],[],missing()))),
    p194pc_row("float-arm-refused",Bool.not(p195fc_present_arm(x195fc_arm([X186FloatValues{"a",26,p195fc_v("a"),p195fc_v("b")}],4)))),
    p194pc_row("repeated-predicate",p195fc_admitted(nt_append(X186FloatNode,p195fc_corridor(0),p195fc_corridor(1)),[],[],missing()))])

def p195fc_present_arm(rows: Maybe<&2,List<&2,P113DStmt>>) -> Bool:
  match rows:
    case Some{values}: True{}
    case None{}: False{}

@unsafe
def p195fc_emit_at(+mode: U32) -> X181Output:
  nt_choose(X181Output,U32.is_ge(mode,40),u => X181Output{[],""},u =>
    x181_program_join(x186_x_place("p195fc_" ++ U32.show(mode),["state"],[],p195fc_body(mode),N111Ids{missing(),missing()}),p195fc_emit_at(U32.inc(mode))))

def p195fc_emit() -> X181Output: p195fc_emit_at(0)
