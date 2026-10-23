# Finite contract/mutation checks for the candidate additions, separate from
# ordinary semantic controls and selected-worker coverage inspection.

@unsafe
def p128bs_control_row(name: String, +ok: Bool) -> String:
  name ++ nt_choose(String,ok,u => ":pass",u => ":FAIL")

@unsafe
def p128bs_guard_control(+count: U32, typ: N111Type, +state: N111Arg) -> Bool:
  String.is_empty(p113d_error(p128bs_project_guard("guard",typ,
    [state,p111_word(N111Local{"left"}),p111_word(N111Local{"right"}),p111_u32(count)])))

@unsafe
def p128bs_controls() -> List<&2,String>:
  [p128bs_control_row("guard-one-root",p128bs_guard_control(1,N111U64{},p111_state())),
   p128bs_control_row("guard-two-roots",p128bs_guard_control(2,N111U64{},p111_state())),
   p128bs_control_row("guard-zero-refused",Bool.not(p128bs_guard_control(0,N111U64{},p111_state()))),
   p128bs_control_row("guard-three-refused",Bool.not(p128bs_guard_control(3,N111U64{},p111_state()))),
   p128bs_control_row("guard-result-width-refused",Bool.not(p128bs_guard_control(1,N111U32{},p111_state()))),
   p128bs_control_row("guard-state-identity-refused",Bool.not(p128bs_guard_control(1,N111U64{},N111Arg{N111Ptr{},N111Local{"other_state"}}))),
   p128bs_control_row("guard-arity-refused",Bool.not(String.is_empty(p113d_error(p128bs_project_guard("guard",N111U64{},[p111_state()]))))),
   p128bs_control_row("leaf-tail-loop",p128bs_leaf([P113DAgain{[N111Local{"next"}]}])),
   p128bs_control_row("leaf-direct-call-refused",Bool.not(p128bs_leaf([P113DCall{["out"],"helper",[]}]))),
   p128bs_control_row("leaf-nested-call-refused",Bool.not(p128bs_leaf([P113DIf{N111Local{"condition"},[],[P113DCall{["out"],"helper",[]}]}]))),
   p128bs_control_row("transport-new-readonly-guard",p118z_runtime("p118_rt_borrow_scalar_safe")),
   p128bs_control_row("transport-divmod-repair-retained",p118z_runtime("p126_rt_nat_divmod"))]
