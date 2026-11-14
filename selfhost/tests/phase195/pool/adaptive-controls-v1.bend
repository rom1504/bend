# Additional finite controls for profitability arithmetic, separate from the
# unchanged legal-assignment and independent machine observers.
@unsafe
def p195ap_label(name: String, pass: Bool) -> String:
  name ++ "=" ++ nt_choose(String,pass,u => "1",u => "0")
@unsafe
def p195ap_env(weighted: Bool) -> X195APEnv:
  X195APEnv{p111v_put(p111v_put(missing(),"a","X190LBit",1,0),"b","X190LBit",2,0),1,2,["a"],weighted}
def p195ap_equal(cost: X195APCost, g: U32, l: U32, s: U32) -> Bool:
  match cost:
    case X195APCost{gain,loss,state}: U32.is_eq(gain,g) && U32.is_eq(loss,l) && U32.is_eq(state,s)
def p195ap_set(name: String) -> P113DStmt: P113DScalar{N111Set{name,N111U64{},N111Const{1,0}}}
@unsafe
def p195ap_loop(weighted: Bool) -> X195APCost:
  x195_ap_cost(x195_ap_body([p195ap_set("a"),P113DAgain{[N111Local{"a"}]}],p195ap_env(weighted),False{}))
def p195ap_inline() -> N111Stmt:
  N111Call{"a",N111U64{},"p111_rt_op",[
    N111Arg{N111Ptr{},N111Local{"state"}},N111Arg{N111U32{},N111Const{26,0}},
    N111Arg{N111Ptr{},N111Local{"b"}},N111Arg{N111U32{},N111Const{2,0}}]}
@unsafe
def p195ap_branch() -> X195APCost:
  x195_ap_cost(x195_ap_body([P113DIf{N111Local{"state"},
    [p195ap_set("a"),P113DAgain{[N111Local{"a"}]}],
    [p195ap_set("b"),P113DResult{[N111Local{"state"}]}]}],p195ap_env(True{}),False{}))
@unsafe
def p195ap_controls() -> List<&2,String>:
  [p195ap_label("policy-rcx-construction-excludes-r12",U32.is_eq(x195_pc_choose([1,1,1,1,1,1,1,1,1,1,0],0,2,1,4294967295,0,10),11)),
   p195ap_label("policy-eleven-construction-allows-r12",U32.is_eq(x195_pc_choose([1,1,1,1,1,1,1,1,1,1,0],0,2,1,4294967295,0,11),10)),
   p195ap_label("policy-tie-refuses-state-spill",Bool.not(x195_ap_take(X195APCost{10,2,8}))),
   p195ap_label("policy-positive-margin-admits",x195_ap_take(X195APCost{11,2,8})),
   p195ap_label("policy-saturating-cost",U32.is_eq(x195_ap_add(4294967295,1),4294967295)),
   p195ap_label("policy-loop-weight-eight",p195ap_equal(p195ap_loop(True{}),8,0,0)),
   p195ap_label("policy-setup-weight-one",p195ap_equal(p195ap_loop(False{}),1,0,0)),
   p195ap_label("policy-identity-again-no-charge",p195ap_equal(x195_ap_event(P113DAgain{[N111Local{"a"}]},p195ap_env(True{})),0,0,0)),
   p195ap_label("policy-implicit-product-state",p195ap_equal(x195_ap_event(P113DCall{["a"],"callee",[N111Local{"b"}]},p195ap_env(True{})),1,1,1)),
   p195ap_label("policy-inline-f32-no-state",p195ap_equal(x195_ap_scalar(p195ap_inline(),p195ap_env(True{})),1,1,0)),
   p195ap_label("policy-ordinary-call-state",p195ap_equal(x195_ap_scalar(N111Call{"a",N111U64{},"callee",[N111Arg{N111Ptr{},N111Local{"state"}}]},p195ap_env(True{})),1,0,1)),
   p195ap_label("policy-import-state-store",p195ap_equal(x195_ap_names(["state","a"],p195ap_env(False{})),1,0,1)),
   p195ap_label("policy-branch-weighting",p195ap_equal(p195ap_branch(),8,1,9))]
