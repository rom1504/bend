# Finite analysis fixtures, not native execution inputs. Expected bodies are
# independent literal structure; host tests compare body data and live sets.
type P118DControl is Data:
  P118DControl{+name: String, +actual: List<&2,P113DStmt>, +expected: List<&2,P113DStmt>, +live: List<&2,String>, +expected_live: List<&2,String>}

@unsafe
def p118d_control_done(name: String, expected: List<&2,P113DStmt>, expected_live: List<&2,String>, scan: P118DBody) -> P118DControl:
  match scan:
    case P118DBody{body,live}: P118DControl{name,body,expected,live,expected_live}

@unsafe
def p118d_control(name: String, input: List<&2,P113DStmt>, expected: List<&2,P113DStmt>, expected_live: List<&2,String>) -> P118DControl:
  p118d_control_done(name,expected,expected_live,p118d_body(input,[]))

@unsafe
def p118d_test_set(name: String, value: N111Value) -> P113DStmt:
  P113DScalar{N111Set{name,N111U64{},value}}

@unsafe
def p118d_test_const(name: String, value: U32) -> P113DStmt:
  p118d_test_set(name,N111Const{value,0})

@unsafe
def p118d_test_result(name: String) -> P113DStmt:
  P113DResult{[N111Local{name}]}

@unsafe
def p118d_controls(_: Unit) -> List<&2,P118DControl>:
  +ret_zero : P113DStmt = P113DResult{[N111Const{0,0}]}
  +update : P113DStmt = P113DScalar{N111Bin{"x",N111U64{},"add",N111Local{"x"},N111Const{1,0}}}
  +partial : P113DStmt = P113DIf{N111Local{"c"},[p118d_test_const("x",2)],[]}
  +complete : P113DStmt = P113DIf{N111Local{"c"},[p118d_test_const("x",2)],[p118d_test_const("x",3)]}
  +terminal : P113DStmt = P113DIf{N111Local{"c"},[p118d_test_result("x")],[p118d_test_const("x",2)]}
  +mutate : P113DStmt = P113DIf{N111Local{"c"},[p118d_test_const("c",0)],[p118d_test_const("c",1)]}
  +again : P113DStmt = P113DAgain{[N111Local{"b"},N111Local{"a"}]}
  +call : P113DStmt = P113DCall{["x","y"],"callee",[N111Local{"y"},N111Local{"x"}]}
  +nested : P113DStmt = P113DScalar{N111If{N111Local{"c"},
    [N111Set{"dead",N111U64{},N111Const{7,0}},N111Set{"x",N111U64{},N111Const{2,0}}],
    [N111Set{"x",N111U64{},N111Const{3,0}}]}}
  +nested_expected : P113DStmt = P113DScalar{N111If{N111Local{"c"},
    [N111Set{"x",N111U64{},N111Const{2,0}}],
    [N111Set{"x",N111U64{},N111Const{3,0}}]}}
  +effect : P113DStmt = P113DScalar{N111Call{"ignored",N111U64{},"p111_rt_sink",[p111_state(),p111_word(N111Local{"root"})]}}
  +fp : P113DStmt = P113DScalar{N111Call{"ignored_fp",N111U64{},"p111_rt_op",[p111_state(),p111_u32(36),N111Arg{N111Ptr{},N111Local{"scratch"}},p111_u32(1)]}}
  +alloca : P113DStmt = P113DScalar{N111Alloca{"buffer",8,8}}
  +store : P113DStmt = P113DScalar{N111Store{N111U64{},N111Local{"buffer"},0,N111Local{"input"}}}
  +load : P113DStmt = P113DScalar{N111Load{"unused",N111U64{},N111Local{"buffer"},0}}
  +high : P113DStmt = P113DIf{N111Local{"c"},
    [p118d_test_const("dead",2),p118d_test_set("x",N111Const{1,4294967295})],
    [p118d_test_set("x",N111Const{7,2147483648})]}
  +high_expected : P113DStmt = P113DIf{N111Local{"c"},
    [p118d_test_set("x",N111Const{1,4294967295})],
    [p118d_test_set("x",N111Const{7,2147483648})]}
  +bool_diamond : P113DStmt = P113DIf{N111Local{"c"},
    [p118d_test_const("unused",0),p118d_test_const("out",0)],
    [P113DScalar{N111Bin{"unused_bits",N111U64{},"or",N111Const{1,0},N111Const{65536,0}}},p118d_test_const("unused",1),p118d_test_const("out",1)]}
  +bool_expected : P113DStmt = P113DIf{N111Local{"c"},[p118d_test_const("out",0)],[p118d_test_const("out",1)]}
  [p118d_control("dead-chain",[p118d_test_const("x",1),p118d_test_set("y",N111Local{"x"}),ret_zero],[ret_zero],[]),
   p118d_control("overwritten",[p118d_test_const("x",1),p118d_test_const("x",2),p118d_test_result("x")],[p118d_test_const("x",2),p118d_test_result("x")],[]),
   p118d_control("self-update",[p118d_test_const("x",1),update,p118d_test_result("x")],[p118d_test_const("x",1),update,p118d_test_result("x")],[]),
   p118d_control("partial-branch-definition",[p118d_test_const("x",1),partial,p118d_test_result("x")],[p118d_test_const("x",1),partial,p118d_test_result("x")],["c"]),
   p118d_control("both-branches-define",[p118d_test_const("x",1),complete,p118d_test_result("x")],[complete,p118d_test_result("x")],["c"]),
   p118d_control("terminal-arm",[p118d_test_const("x",1),terminal,p118d_test_result("x")],[p118d_test_const("x",1),terminal,p118d_test_result("x")],["c"]),
   p118d_control("mutable-condition",[mutate,p118d_test_result("c")],[mutate,p118d_test_result("c")],["c"]),
   p118d_control("parallel-again",[p118d_test_const("a",1),p118d_test_const("b",2),again],[p118d_test_const("a",1),p118d_test_const("b",2),again],[]),
   p118d_control("parallel-call-overlap",[call,p118d_test_result("x")],[call,p118d_test_result("x")],["x","y"]),
   p118d_control("scalar-if",[nested,p118d_test_result("x")],[nested_expected,p118d_test_result("x")],["c"]),
   p118d_control("ownership-call",[p118d_test_const("dead",1),effect,ret_zero],[effect,ret_zero],["state","root"]),
   p118d_control("unused-float-call",[fp,ret_zero],[fp,ret_zero],["state","scratch"]),
   p118d_control("memory-is-retained",[alloca,store,load,ret_zero],[alloca,store,load,ret_zero],["input"]),
   p118d_control("high-word-payload",[high,p118d_test_result("x")],[high_expected,p118d_test_result("x")],["c"]),
   p118d_control("exposes-bool-diamond",[bool_diamond,p118d_test_result("out")],[bool_expected,p118d_test_result("out")],["c"])]

# Deliberately conservative exclusions, even where a later proof could admit
# them. No division, memory, or floating operation is executed by these checks.
@unsafe
def p118d_policy_controls(_: Unit) -> List<&2,Bool>:
  [p118d_total("add"),p118d_total("or"),p118d_total("ult"),
   Bool.not(p118d_total("div")),Bool.not(p118d_total("rem")),
   Bool.not(p118d_total("udiv")),Bool.not(p118d_total("fadd")),
   Bool.not(p118d_total("shl")),Bool.not(p118d_integer(N111Ptr{}))]
