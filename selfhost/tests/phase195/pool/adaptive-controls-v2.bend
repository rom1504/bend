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
def p195ap_controls_base() -> List<&2,String>:
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

# Eleven simultaneously live values create real eleven-color pressure. These
# fixtures go through admission, candidate selection, fixed point, graph,
# adaptive decision, validation and installation; no forced groups are passed.
@unsafe
def p195ap_definitions(+n: U32) -> List<&2,P113DStmt>:
  nt_choose(List<&2,P113DStmt>,U32.is_ge(n,11),u => [],u =>
    Con{p195ap_set("policy_live" ++ U32.show(n)),p195ap_definitions(U32.inc(n))})
@unsafe
def p195ap_reduction(+n: U32) -> List<&2,P113DStmt>:
  nt_choose(List<&2,P113DStmt>,U32.is_ge(n,11),u => [],u =>
    Con{P113DScalar{N111Bin{"policy_live0",N111U64{},"add",N111Local{"policy_live0"},
      N111Local{"policy_live" ++ U32.show(n)}}},p195ap_reduction(U32.inc(n))})
def p195ap_state_call() -> P113DStmt:
  P113DScalar{N111Call{"policy_unused",N111U64{},"p195pm_effect",[
    N111Arg{N111Ptr{},N111Local{"state"}},N111Arg{N111U64{},N111Const{1,0}},
    N111Arg{N111U64{},N111Const{2,0}}]}}
@unsafe
def p195ap_pressure_body(heavy: Bool) -> List<&2,P113DStmt>:
  nt_append(P113DStmt,p195ap_definitions(0),nt_append(P113DStmt,p195ap_reduction(1),
    nt_append(P113DStmt,nt_choose(List<&2,P113DStmt>,heavy,
      u => [p195ap_state_call(),p195ap_state_call()],u => []),[P113DResult{[N111Local{"policy_live0"}]}])))
@unsafe
def p195ap_frame_outcome(frame: X181Frame, +oldBytes: U32, wantR12: Bool) -> Bool:
  match frame:
    case X181Frame{+slots,+bytes,calls,params,symbol}:
      +state = p111v_get(slots,"state")
      +last = p111v_get(slots,"policy_live10")
      nt_choose(Bool,wantR12,
        u => String.eq(dk(state),"X181Stack") && U32.is_eq(dx(state),8) &&
          U32.is_eq(da(state),x181_frame_align(U32.add(oldBytes,8),8)) &&
          U32.is_eq(bytes,da(state)) && String.eq(dk(last),"X181Register") && U32.is_eq(da(last),0),
        u => String.eq(dk(state),"X181Register") && U32.is_eq(da(state),0) &&
          U32.is_eq(bytes,oldBytes) && String.eq(dk(last),"X181Stack"))
@unsafe
def p195ap_fresh_outcome(fresh: X181Frame, allocated: X181Frame, wantR12: Bool) -> Bool:
  match fresh:
    case X181Frame{slots,bytes,calls,params,symbol}: p195ap_frame_outcome(allocated,bytes,wantR12)
@unsafe
def p195ap_actual(+heavy: Bool) -> Bool:
  +body = p195ap_pressure_body(heavy)
  +frame = x181_frame("policy_pressure",["state"],body)
  p195ap_fresh_outcome(frame,x190_joint_frame(frame,["state"],[],body,body),Bool.not(heavy))
@unsafe
def p195ap_controls() -> List<&2,String>:
  nt_append(String,p195ap_controls_base(),[
    p195ap_label("policy-actual-profitable-r12-frame",p195ap_actual(False{})),
    p195ap_label("policy-actual-state-heavy-ten-frame",p195ap_actual(True{}))])
