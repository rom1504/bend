# Structural plan/renderer controls, separate from native execution qualification.
@unsafe
def p173djc_params() -> List<&2,NC_Binding>:
  [NC_Binding{0,"state_selector",N_W64{}},NC_Binding{1,"x",N_W64{}},NC_Binding{2,"y",N_W64{}}]

@unsafe
def p173djc_swap() -> List<&2,P113DStmt>:
  [P113DScalar{N111Set{"seen",N111U64{},N111Local{"state_selector"}}},
   P113DAgain{[N111Const{7,0},N111Local{"y"},N111Local{"x"}]}]

@unsafe
def p173djc_other() -> List<&2,P113DStmt>:
  [P113DResult{[N111Local{"x"}]}]

@unsafe
def p173djc_chain(+first: List<&2,P113DStmt>, +last: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  [P113DScalar{N111Bin{"test0",N111U64{},"eq",N111Local{"state_selector"},N111Const{0,0}}},
   P113DIf{N111Local{"test0"},first,[
     P113DScalar{N111Bin{"test7",N111U64{},"eq",N111Local{"state_selector"},N111Const{7,0}}},
     P113DIf{N111Local{"test7"},[P113DAgain{[N111Const{9,0},N111Local{"x"},N111Local{"y"}]}],last}]}]

@unsafe
def p173djc_good() -> List<&2,P113DStmt>:
  p173djc_chain(p173djc_swap(),p173djc_other())

@unsafe
def p173djc_code() -> P111QCode:
  P111QCode{["@p113_loop\n","jmp @p113_loop\n"],0,False{},""}

@unsafe
def p173djc_text(+body: List<&2,P113DStmt>, +selected: Bool) -> String:
  p111q_body_text(nt_choose(P111QCode,selected,
    u => p173dj_entry(body,p173djc_params(),N111Ids{missing(),missing()},p173djc_code()),
    u => p113w_stmts(body,p173djc_params(),N111Ids{missing(),missing()},p173djc_code())))

@unsafe
def p173djc_refused(+body: List<&2,P113DStmt>) -> Bool:
  Bool.not(p173dj_valid(p173dj_plan(body,p173djc_params()))) && String.eq(p173djc_text(body,False{}),p173djc_text(body,True{}))

@unsafe
def p173djc_test(+name: String, +op: String, +selector: String, +tag: U32, +hi: U32, +yes: List<&2,P113DStmt>, +no: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  [P113DScalar{N111Bin{name,N111U64{},op,N111Local{selector},N111Const{tag,hi}}},P113DIf{N111Local{name},yes,no}]

@unsafe
def p173djc_verified(+body: List<&2,P113DStmt>) -> Bool:
  +function : P113DFunction = P113DFunction{"ordinary-state-machine",p173djc_params(),1,False{},body}
  String.is_empty(p113e_functions([function],N111Ids{missing(),missing()},missing())) &&
    String.is_empty(p147d_functions([function],N111Ids{missing(),missing()},missing()))

@unsafe
def p173djc_scratch() -> List<&2,P113DStmt>:
  Con{P113DScalar{N111Alloca{"buffer",8,8}},p173djc_chain([
    P113DScalar{N111Store{N111U64{},N111Local{"buffer"},0,N111Local{"x"}}},
    P113DScalar{N111Load{"loaded",N111U64{},N111Local{"buffer"},0}},
    P113DAgain{[N111Const{7,0},N111Local{"y"},N111Local{"loaded"}]}],p173djc_other())}

@unsafe
def p173djc_prefix_refused(+stmt: N111Stmt) -> Bool:
  p173djc_refused(Con{P113DScalar{stmt},p173djc_good()})

@unsafe
def p173djc_dynamic(+high: Bool) -> List<&2,P113DStmt>:
  p173djc_chain([P113DAgain{[nt_choose(N111Value,high,u => N111Const{7,1},u => N111Local{"state_selector"}),N111Local{"y"},N111Local{"x"}]}],p173djc_other())

@unsafe
def p173djc_row(+name: String, +ok: Bool) -> String:
  name ++ nt_choose(String,ok,u => ":pass",u => ":FAIL")

@unsafe
def p173dj_controls() -> List<&2,String>:
  +body = p173djc_good()
  +plan = p173dj_plan(body,p173djc_params())
  +text = p173djc_text(body,True{})
  +ids : N111Ids = N111Ids{missing(),missing()}
  +collision : P111QCode = P111QCode{["@p113_loop\n","@p173dj_arm_0\n"],0,False{},""}
  +nested : P111QCode = P111QCode{["@b_42\n"],43,False{},""}
  +scratch = p173djc_scratch()
  [p173djc_row("dispatch-general-noncanonical-names",p173dj_valid(plan)),
   p173djc_row("dispatch-original-both-verifiers",p173djc_verified(body)),
   p173djc_row("dispatch-known-noncontiguous-tag",String.eq(p173dj_target([N111Const{7,0}],plan),"@p173dj_arm_1")),
   p173djc_row("dispatch-known-default-tag",String.eq(p173dj_target([N111Const{9,0}],plan),"@p173dj_arm_2")),
   p173djc_row("dispatch-dynamic-tag-fallback",String.eq(p173dj_target([N111Local{"state_selector"}],plan),"@p113_loop")),
   p173djc_row("dispatch-high-half-tag-fallback",String.eq(p173dj_target([N111Const{7,1}],plan),"@p113_loop")),
   p173djc_row("dispatch-parallel-swap-fullwords",String.contains(text,"%p113_again_0 =l copy 7\n%p113_again_1 =l copy %v_y\n%p113_again_2 =l copy %v_x\n%v_state_selector =l copy %p113_again_0\n%v_x =l copy %p113_again_1\n%v_y =l copy %p113_again_2\njmp @p173dj_arm_1\n")),
   p173djc_row("dispatch-selector-read-preserved",String.contains(text,"%v_seen =l copy %v_state_selector\n")),
   p173djc_row("dispatch-default-edge-direct",String.contains(text,"%p113_again_0 =l copy 9\n") && String.contains(text,"jmp @p173dj_arm_2\n")),
   p173djc_row("dispatch-dynamic-edge-original-loop",String.contains(p173djc_text(p173djc_dynamic(False{}),True{}),"%v_y =l copy %p113_again_2\njmp @p113_loop\n")),
   p173djc_row("dispatch-wide-edge-original-loop",String.contains(p173djc_text(p173djc_dynamic(True{}),True{}),"%v_y =l copy %p113_again_2\njmp @p113_loop\n")),
   p173djc_row("dispatch-alloca-prefix-admitted",p173dj_valid(p173dj_plan(scratch,p173djc_params())) && p173djc_verified(scratch)),
   p173djc_row("dispatch-alloca-hoist-preserved",String.contains(p113e_private(P113DFunction{"scratch-machine",p173djc_params(),1,False{},scratch},ids),"%v_buffer =l alloc8 8\n")),
   p173djc_row("dispatch-effect-prefix-refused",p173djc_prefix_refused(N111Call{"ignored",N111U64{},"p111_rt_sink",[p111_state(),p111_word(N111Local{"x"})]})),
   p173djc_row("dispatch-set-prefix-refused",p173djc_prefix_refused(N111Set{"x",N111U64{},N111Const{1,0}})),
   p173djc_row("dispatch-load-prefix-refused",p173djc_prefix_refused(N111Load{"x",N111U64{},N111Local{"scratch"},0})),
   p173djc_row("dispatch-observed-test-refused",p173djc_refused(p173djc_chain([P113DResult{[N111Local{"test0"}]}],p173djc_other()))),
   p173djc_row("dispatch-overwritten-test-refused",p173djc_refused(p173djc_chain([P113DScalar{N111Set{"test0",N111U32{},N111Const{1,0}}},P113DResult{[N111Local{"x"}]}],p173djc_other()))),
   p173djc_row("dispatch-test-call-argument-refused",p173djc_refused(p173djc_chain([P113DCall{["answer"],"helper",[N111Local{"test0"}]},P113DResult{[N111Local{"answer"}]}],p173djc_other()))),
   p173djc_row("dispatch-duplicate-state-refused",p173djc_refused(p173djc_test("a","eq","state_selector",0,0,p173djc_swap(),p173djc_test("b","eq","state_selector",0,0,p173djc_swap(),p173djc_other())))),
   p173djc_row("dispatch-duplicate-test-refused",p173djc_refused(p173djc_test("a","eq","state_selector",0,0,p173djc_swap(),p173djc_test("a","eq","state_selector",7,0,p173djc_swap(),p173djc_other())))),
   p173djc_row("dispatch-other-selector-refused",p173djc_refused(p173djc_test("a","eq","state_selector",0,0,p173djc_swap(),p173djc_test("b","eq","x",7,0,p173djc_swap(),p173djc_other())))),
   p173djc_row("dispatch-nonparameter-selector-refused",p173djc_refused(p173djc_test("a","eq","not_parameter",0,0,p173djc_swap(),p173djc_other()))),
   p173djc_row("dispatch-wrong-predicate-refused",p173djc_refused(p173djc_test("a","ne","state_selector",0,0,p173djc_swap(),p173djc_other()))),
   p173djc_row("dispatch-wide-test-constant-refused",p173djc_refused(p173djc_test("a","eq","state_selector",0,1,p173djc_swap(),p173djc_other()))),
   p173djc_row("dispatch-nonterminal-arm-refused",p173djc_refused(p173djc_chain([P113DScalar{N111Set{"x",N111U64{},N111Const{1,0}}}],p173djc_other()))),
   p173djc_row("dispatch-backedge-arity-refused",p173djc_refused(p173djc_chain([P113DAgain{[N111Const{7,0},N111Local{"x"}]}],p173djc_other()))),
   p173djc_row("dispatch-label-namespace-collision-refused",String.eq(p111q_body_text(p173dj_entry(body,p173djc_params(),ids,collision)),p111q_body_text(p113w_stmts(body,p173djc_params(),ids,collision)))),
   p173djc_row("dispatch-nested-entry-refused",String.eq(p111q_body_text(p173dj_entry(body,p173djc_params(),ids,nested)),p111q_body_text(p113w_stmts(body,p173djc_params(),ids,nested)))),
   p173djc_row("dispatch-final-verifier-rejects-alloca-test-overlap",Bool.not(p173djc_verified(Con{P113DScalar{N111Alloca{"test0",8,8}},body}))) ]
