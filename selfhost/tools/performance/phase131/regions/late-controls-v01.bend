# Independent malformed-IR controls for the borrowed-aware late boundary.
# These are verifier inputs only; no malformed native code is executed.
@unsafe
def p131rb_control_program(functions: List<&2,P113DFunction>) -> P113AProgram:
  P113AProgram{P113DProgram{p114st_original(),functions},P113ACertificate{False{},False{}}}

@unsafe
def p131rb_control_guard(count: U32) -> P113DFunction:
  P113DFunction{"p131_guard",[NC_Binding{0,"a",N_W64{}}],1,False{},
    [P113DScalar{N111Call{"guard",N111U64{},"p118_rt_borrow_scalar_safe",
      [p111_state(),p111_word(N111Local{"a"}),p111_word(N111Const{0,0}),p111_u32(count)]}},
     P113DResult{[N111Local{"guard"}]}]}

@unsafe
def p131rb_controls() -> List<&2,String>:
  +identity = p114st_identity()
  +unknown : P113DFunction = P113DFunction{"p131_unknown",[],1,False{},
    [P113DScalar{N111Call{"r",N111U64{},"p131_unknown_runtime",[p111_state()]}},
     P113DResult{[N111Local{"r"}]}]}
  +forward : P113DFunction = P113DFunction{"p131_forward",[],1,False{},
    [P113DCall{["r"],"p114_identity",[N111Const{0,0}]},P113DResult{[N111Local{"r"}]}]}
  [p128bs_control_row("late-known-identity-accepted",String.is_empty(p131rb_derived_error(p131rb_control_program([identity])))),
   p128bs_control_row("late-missing-result-refused",Bool.not(String.is_empty(p131rb_derived_error(p131rb_control_program([
     P113DFunction{"p131_bad",[],1,False{},[]}]))))),
   p128bs_control_row("late-unknown-runtime-refused",Bool.not(String.is_empty(p131rb_derived_error(p131rb_control_program([unknown]))))),
   p128bs_control_row("late-valid-borrow-guard-accepted",String.is_empty(p131rb_derived_error(p131rb_control_program([p131rb_control_guard(1)])))),
   p128bs_control_row("late-wrong-borrow-root-count-refused",Bool.not(String.is_empty(p131rb_derived_error(p131rb_control_program([p131rb_control_guard(3)]))))),
   p128bs_control_row("late-forward-call-refused",Bool.not(String.is_empty(p131rb_derived_error(p131rb_control_program([forward,identity]))))),
   p128bs_control_row("late-ready-call-accepted",String.is_empty(p131rb_derived_error(p131rb_control_program([identity,forward]))))]
